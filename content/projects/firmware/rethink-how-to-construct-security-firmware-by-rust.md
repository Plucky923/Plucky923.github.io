---
title: "Rethinking Secure Firmware Construction with Rust"
date: 2026-07-20T19:45:00+08:00
draft: false
description: ""
tags: []
---

# RustSBI Prototyper: Intra-Firmware Privilege Separation

[Firmware](https://people.inf.ethz.ch/troscoe/pubs/caste-sosp-2025.pdf)
is privileged system software that executes at the highest CPU
privilege level and directly initializes or manages hardware resources.
In native RISC-V ecosystem,
[SBI firmware](https://docs.riscv.org/reference/sbi/index.html)
runs in the M-mode, the highest architectural privilege level,
while the operating system usually runs in S-mode.  
Because M-mode firmware controls security-critical machine state
and physical resources, an attacker who obtains arbitrary code execution
in SBI firmware may compromise the confidentiality and integrity
of the operating system and other higher-level software.

Like much system softwares, firmware traditinally been implemented by
C language. But the C language is memory-unsafe language.
It do not provide language-level protection against errors such as
out-of-bounds memory accesses,use-after-free and invalid pointer
dereferences. Such errors constitute a major source of security
vulnerablities in large systems.For examples,
[the Chromium project](https://www.chromium.org/Home/chromium-security/memory-safety/)
reports that approximately 70% of its high-severity security bugs have resulted
from memory-safety violations. In highly privileged firmware, exploiting such
a vulnerability may allow an attacker to obtain machine-level privileges
and compromise the security of the software stack above it.

Memory-safe languages such as [Rust](https://www.rust-lang.org/) offer
a promising alternative for implementing system software.
Rust is increasingly being adopted in operating systems, kernels,
and firmware because its ownership and type systems prevent many
classes of memory-safety errors at compile time.
Projects such as [Rust for Linux](https://rust-for-linux.com/),
[Tock](https://www.tockos.org/), and [Asterinas](https://asterinas.github.io/)
demonstrate that Rust can be used to build practical low-level systems.
However, Rust does not eliminate all security vulnerabilities:
its guarantees depend on the soundness of `unsafe` code.

Prior studies have demonstrated that this risk occurs in real-world Rust software. 
[RUDRA](https://dl.acm.org/doi/10.1145/3477132.3483570)
analyzed unsafe abstractions across the Rust ecosystem
and discovered previously unknown memory-safety bugs
in widely used Rust libraries.
[TRust](https://www.usenix.org/conference/usenixsecurity23/presentation/bang)
further showed that unsafe Rust and foreign-language libraries can undermine
the safety guarantees of safe Rust code within the same process.
[An empirical study of Rust-for-Linux](https://www.usenix.org/conference/atc24/presentation/li-hongyu)
identified soundness bugs in kernel abstraction layers,
including bugs that could break memory and thread safety.
More recently, 
[Detecting Type Confusion Bugs in Rust Programs](https://www.usenix.org/conference/usenixsecurity25/presentation/chen-hung-mao) demonstrated that unsafe pointer conversions can
introduce severe type-confusion and memory-corruption vulnerabilities.

These findings motivate treating memory safety as a system-wide
property rather than only a language guarantee.
[Asterinas](https://www.usenix.org/conference/atc25/presentation/peng-yuke)
introduces the *framekernel* architecture, which separates a privileged
OS framework from de-privileged OS services. The framework confines low-level
`unsafe` operations and exposes safe APIs to the rest of the kernel.
Asterinas further analyzes unsoundness at three levels: language-level,
environment-level, and architecture-level.

Among existing open-source SBI implementations,
[OpenSBI](https://github.com/riscv-software-src/opensbi)
and [RustSBI](https://github.com/rustsbi/rustsbi) represent two
prominent design approaches. OpenSBI is a mature reference
implementation written primarily in C. Although using C
does not make OpenSBI inherently vulnerable,
its memory safety relies largely on manual reasoning, code review, and testing
rather than language-level guarantees.[RustSBI Prototyper](https://github.com/rustsbi/rustsbi/tree/main/prototyper) 
instead use Rust to eliminate many classes of language-level memory errors.
However, adopting Rust alone does not establish a sound firmware architecture,
and the current public design does not provide a systematic soundness argument
comparable to [Asterinas](https://www.usenix.org/conference/atc25/presentation/peng-yuke).
This motivates us to investigate how to construct Rust-based SBI firmware to provide
soundness guarantee.

We propose an intra-firmware privilege-separation architecture that divides
M-mode firmware into two layers. The machine layer forms the trusted computing
base (TCB). It encapsulates architecture- and hardware-specific operations
and exposes sound, typed, and capability-restricted interfaces to the upper layer.
The prototyper layer uses these interfaces to implement M-mode services,
such as SBI firmware, an RTOS runtime, or a security monitor, without directly
manipulating raw machine state.

![](../image.png)

This figure presents the overall architecture of our intra-firmware
privilege-separation design. The entire firmware executes within a single
M-mode protection domain, but its authority is divided into two layers.
The lower machine layer forms the TCB and exclusively manages raw hardware
resources, including boot state, traps, physical memory, PMP,
harts, interrupts, timers, and MMIO devices. It encapsulates the private
unsafe implementation and exposes only typed, capability-based safe Rust interfaces.

The upper rustsbi-prototyper layer implements platform policy and
SBI services using these capabilities.
During boot, machine initializes the platform and passes a BootContext
with owned capabilities to Prototyper. At runtime, an S-mode ecall first enters
the machine trap subsystem, which decodes it into a typed SupervisorCall and
forwards it to the SBI dispatcher. Prototyper then invokes the required machine
operations through the capability interfaces, after which machine restores the
execution context and returns to S-mode with mret. We defer the detailed design
of individual interfaces and subsystems to later sections.
