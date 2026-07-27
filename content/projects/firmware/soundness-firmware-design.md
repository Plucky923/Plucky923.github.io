---
title: "Soundness Firmware Design"
date: 2026-07-26T00:00:00+08:00
draft: false
description: ""
tags: []
weight: 20
---

# Why SBI Firmware Needs Internal Privilege Separation

RISC-V SBI firmware occupies a uniquely privileged position in a RISC-V system. Running in M-mode, it establishes the execution environment for next-stage software during boot and services SBI requests from S/VS-mode software at runtime. These responsibilities require direct control of traps, CSRs, physical-memory ranges, PMP state, MMIO devices, and cross-hart state.

The SBI specification defines the calling convention and extension semantics across the privilege boundary. An ABI-conformant but adversarial S/VS caller can therefore use legal arguments, call sequences, and concurrent interleavings to expose an insufficiently constrained internal interface. The danger is concrete. A faulty interface might let a service treat an S/VS-owned buffer as a normal Rust object, even though the caller can still change that buffer while the firmware uses it. Or it might expose saved trap state, allowing a service to change the return address or return privilege. Both mistakes break the preconditions on which safe Rust relies, even when the policy code itself contains no `unsafe` Rust.

We propose an internal privilege-separation design that keeps raw machine privileges in a small `machine` layer. Under the platform and toolchain assumptions defined below, this layer is the software trusted computing base (TCB) for memory safety. The remaining M-mode policy code uses only safe Rust and the restricted public interfaces of `machine`. This is not hardware isolation because all components still execute in M-mode.

# Soundness and Threat Model

## Memory-Safety Property

In this work, firmware memory-safety soundness is the following conditional property:

Given a target platform whose RISC-V hardware and device-isolation mechanisms behave as specified, a previous-stage handoff that satisfies its stated contract, and policy code restricted to safe Rust and the public APIs of `machine`, no sequence of SBI calls from less-privileged software can cause the M-mode firmware to execute Rust undefined behavior. This includes arbitrary ABI-conformant arguments, call sequences, cross-hart interleavings, and concurrent modification of caller-owned shared memory where the SBI interface permits it.

This definition concerns memory safety only. It does not imply:

- **Functional correctness:** that every SBI operation implements its specified semantics.
- **General security:** confidentiality, side-channel resistance, denial-of-service resilience, or protection against malicious device firmware.
- **Availability or liveness:** that every hart makes progress or every device responds.
- **Isolation from arbitrary M-mode code:** code with unrestricted M-mode privileges is part of the trusted computing base or outside the scope of this work.

Establishing any of these stronger properties requires separate specifications, threat models, and formal verification. They do not follow from the memory-safety argument presented here.

## Threat Model

We treat all S/VS-mode software as untrusted. It may call any supported SBI function with arbitrary ABI-conformant arguments, in any order, and from multiple harts at the same time.

For an SBI function that accepts a physical address range, the supplied range remains outside M-mode ownership. Another S/VS hart, and, where the platform permits it, a DMA-capable device may change its contents while the firmware accesses it.

The argument makes three assumptions.

1. **Initial privilege boundary.** The adversary starts in S/VS mode. Before using an SBI interface, it cannot execute M-mode code or read or write storage reserved for the firmware, including firmware code, stacks, trap state, and heap objects.
2. **Trusted execution foundation.** The Rust toolchain, the target RISC-V hardware, and the previous-stage boot handoff satisfy their stated contracts. In particular, the handoff gives `machine` a valid initial execution environment.
3. **DMA containment.** A DMA-capable device may change an external range while the firmware uses it, but its DMA accesses are confined to ranges that `machine` has made available to the device. A device that can write firmware-private memory, or bypass this restriction, is outside the threat model unless its control path is part of the TCB.

## Undefined Behavior

Following `Asterinas`, we analyze three routes by which a system can reach Rust undefined behavior. Only the first is a Rust language category. The other two are system-level failures: they break conditions that `machine`'s unsafe code relies on and can thereby lead to Rust undefined behavior.

- **Language-level UB** arises when `machine` uses an unsafe operation without meeting its Rust requirements, such as pointer validity, aliasing, lifetime, or value-validity rules.
- **Environment-level failure** arises when an actor outside Rust ownership changes or reassigns memory backing a live Rust object.
- **Architecture-level failure** arises when a privileged-state transition makes later firmware execution violate its memory or control-flow assumptions.

The following design keeps these three conditions under `machine` control.

# Overview

The design implements internal privilege separation around operations that can change the M-mode execution environment, rather than around SBI extensions.

![Internal privilege separation overview](../soundness-privilege-separation.png)

The `machine` layer owns raw operations that can change the M-mode execution environment. The policy layer also runs in M-mode, so the boundary relies on safe Rust and `machine`'s restricted public interfaces rather than a separate CPU privilege level.

The boundary follows three principles:

1. **Least privilege.** Each `machine` interface grants only the privilege needed for one operation, never raw register identifiers, trap stacks, or arbitrary physical addresses.
2. **Single ownership of critical state.** `machine` is the only component that stores and installs live state controlling the M-mode execution environment.
3. **Retention of safety-critical resources.** A resource remains in `machine` when its misuse could break M-mode memory safety; other resources are exposed only through operations with bounded effects.

# Boot

> **Invariant 1. Raw boot state and machine privileges do not cross the `machine` boundary.**

At boot, the previous stage provides raw state, including entry registers, hart identifiers, physical addresses, the next-stage entry point, and the DTB location. `machine` alone imports this state, validates the conditions needed to construct firmware-owned state, and copies the required facts into a normalized `BootInfo`. The policy layer receives boot facts and restricted capabilities, not raw pointers, direct physical-memory access, PMP control, or final-handoff authority.

In the prototype, this boundary is reflected by a safe entry point:

```rust
#[machine::entry]
fn main(boot: machine::BootInfo) -> ! {
    rustsbi_prototyper::run(boot)
}
```

# Runtime

## Trap Entry and Return

> **Invariant 2. Policy code may determine an SBI service result, but only `machine` controls trap entry and return.**

When an SBI `ecall` reaches an M-mode SBI implementation, the processor records the trap cause, interrupted instruction address, and return privilege state before transferring control to the M-mode trap entry. The `machine` layer switches to a private M-mode stack and saves the caller registers in private storage.

Before invoking policy code, `machine` checks that the trap is an accepted SBI call and extracts only the extension identifier, function identifier, and argument values needed to interpret it. These values are passed as firmware-owned data. Policy code receives no reference or writable access to saved registers, trap storage, or the machine CSRs from which they were obtained.

Policy code dispatches the accepted call to a supported SBI service and returns a service-level result. It cannot access or alter the saved trap state, return program counter, return privilege, or restoration sequence. `machine` translates the result into ABI-defined effects, restores the saved state, and performs the privilege return.

## CPU

> **Invariant 3. Only `machine` may install or modify live M-mode CPU control state.**

Privileged CPU state determines control flow, privilege transitions, trap delivery, interrupt behavior, and the protection context of subsequent firmware instructions. Unrestricted writes to `mstatus`, `mepc`, `mtvec`, `mscratch`, or machine interrupt and delegation CSRs could redirect execution, replace the trap-entry path, alter privilege return, or invalidate assumptions required by safe Rust.

Accordingly, `machine` exposes no generic CSR read or write interface. A subsystem requests a semantic action, and `machine` validates the request against platform state and performs the corresponding architectural transition.

## Memory

Physical addresses do not encode ownership, permitted access, or whether the underlying bytes can safely back a Rust object. The memory boundary therefore distinguishes M-mode-owned memory, externally mutable S/VS memory, and the privilege to install PMP state. DMA access is a separate access condition addressed in the device section.

> **Invariant 4. Storage backing live M-mode state remains M-mode-owned for its lifetime.**

Any range containing live M-mode code, stacks, trap storage, heap objects, or firmware metadata remains M-mode-owned until those objects are no longer live. On a target platform that uses PMP to protect M-mode memory, `machine` installs a configuration on every relevant hart before admitting S/VS execution; that configuration denies lower-privilege read, write, and execute access to these ranges.

PMP does not isolate components that both execute in M-mode. The internal boundary is enforced separately: policy code receives neither arbitrary physical-memory access nor the ability to reclassify M-mode-owned ranges. Only `machine` can turn a raw physical range into M-mode-owned storage or change a range's ownership classification. Policy code may use safe allocations that `machine` provides, but it cannot choose their backing physical ranges.

> **Invariant 5. S/VS-provided memory never becomes firmware-owned memory.**

Consider a DBCN call that supplies a physical address `p` and a length `n` for console output. The policy layer may carry `p` and `n` as untrusted integers, but it cannot use them as a pointer. It asks `machine` to create a direction-specific external-memory capability. Only `machine` can create that capability, after checking that `[p, p + n)` does not overflow, is ordinary memory that the caller may use in the requested direction, and does not overlap M-mode-owned memory, reserved memory, or MMIO.

Conceptually, the interface has this shape:

```rust
let reader = machine::external_reader(p, n)?;
let mut scratch = [0u8; 64];
let count = reader.read_into(0, &mut scratch)?;
console.write(&scratch[..count]);
```

An `ExternalReader` copies checked external bytes into M-mode-owned storage; an `ExternalWriter` performs the reverse transfer. Neither type exposes `as_ptr`, `as_slice`, or a typed view of the external range.

A caller may change a console buffer from `hello` to `world` while `read_into` is running. The resulting `scratch` buffer may contain bytes from both versions. This can change console output or make a structured request invalid, but it cannot modify a live M-mode Rust object. If a service needs to parse a descriptor or another structured value, it parses only `scratch` after validating the copied bytes. A normal reader or writer is tied to one SBI call and cannot be retained after return. An extension that needs longer access requires a separate type with an explicit ownership, lifetime, and synchronization contract.

> **Invariant 6. Only `machine` encodes and commits PMP state.**

PMP entries determine which physical ranges lower-privilege harts may access. An RTOS or secure monitor may need to decide the policy: for example, it may request that a specified domain receive read/write access to a range it is allowed to manage. That request is expressed in terms of a domain, range capabilities, permissions, and target harts. The caller cannot select PMP CSRs, encode address ranges, choose entry priority, or install state on a hart.

`machine` is the only component that translates this logical request into PMP entries and commits the result. It checks that the caller may manage the range, the request does not expose M-mode-owned memory or another domain's memory, and the requested policy can be represented exactly with the platform's PMP granularity, entry count, and priority rules. It also synchronizes all relevant harts and preserves protection throughout the transition.

If the request cannot be represented exactly or cannot be installed consistently, `machine` rejects it rather than widening access.

## Device

Device privilege separation is based on a device operation's effects, not its name. An operation remains in `machine` if it can affect M-mode-owned memory or M-mode execution; only operations excluding both effects may be exposed to policy code.

### MMIO

> **Invariant 7. Each MMIO range has one `machine` owner.**

From trusted platform information, `machine` identifies the physical range occupied by each device's registers. Before it creates an MMIO access object, it claims that range in its range registry. A claim means that no RAM object, reserved region, firmware-private region, or other device object may overlap the range. A second claim for an overlapping range is rejected.

`IoMem` is created only for a claimed range and remains an internal `machine` type. It keeps the range bounds private and permits only volatile scalar reads and writes with the required width, alignment, and ordering. It does not implement `Deref`, return a Rust reference, or otherwise present device registers as normal memory.

This invariant establishes physical identity and exclusive access: an `IoMem` operation reaches one identified device register range, and no other writable memory abstraction covers the same bytes. It does not establish that every register in the range is safe to use.

### M-mode Interrupt Entry

An M-mode interrupt is an asynchronous event delivered to M-mode. The hart transfers control to the entry selected by `mtvec`; `machine` switches stacks, saves state, and later restores state and executes `mret`. After saving the trap state, it may decode the cause and invoke a safe Rust handler with a restricted event value rather than the live trap frame or raw interrupt state.

> **Invariant 8. Only `machine` configures an interrupt source that can enter M-mode.**

For a source delivered to M-mode, `machine` alone controls enablement, target hart, and delegation. Policy code cannot change the M-mode trap route or raw interrupt configuration. This applies only to events that enter M-mode; directly delegated S/VS interrupts are outside this invariant.

### DMA Memory Access

> **Invariant 9. A DMA-capable device can access only untyped memory.**

A DMA-capable device may modify any memory range that its DMA mapping permits at any time. That range therefore cannot host a live Rust object: a device write would invalidate `&T` or `&mut T` references held by the firmware. Following Asterinas, `machine` separates physical storage into typed and untyped memory. Typed memory hosts firmware code, stacks, trap storage, heap objects, and other Rust objects; it is never mapped for DMA. Untyped memory is externally mutable storage for DMA and other shared uses.

Untyped memory is not exposed as `&[u8]`, `&mut [u8]`, or `&T`. `machine` exposes only a reader/writer interface that copies bytes or plain-old-data values without creating references to the untyped range. A device may change those bytes concurrently, producing an incorrect value for the protocol, but it cannot violate Rust aliasing or lifetime rules because the range never has Rust object semantics.

`machine` configures the IOMMU, IOPMP, or equivalent platform mechanism so that a device's DMA mappings cover untyped memory only. If the platform cannot enforce that restriction, this work cannot claim that a buggy driver or device is outside the memory-safety TCB. Reclassifying untyped memory as M-mode typed storage requires a separate ownership-transition argument; it is not assumed by this invariant.

# Conclusion

This design uses privilege separation to keep raw M-mode authority in `machine` and to let the remaining firmware operate only through restricted abstractions. The invariants define the boundary that the implementation must preserve to support the stated memory-safety goal.

This overview does not yet define the concrete abstractions or their interfaces. The following design sections will specify how `BootInfo`, trap events, external-memory readers and writers, PMP policy requests, MMIO objects, and DMA memory are constructed, what authority each interface exposes, and how `machine` checks each operation.
