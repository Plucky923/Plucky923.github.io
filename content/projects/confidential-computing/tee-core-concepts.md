---
title: "TEE core concepts"
date: 2026-08-08T00:00:00+08:00
draft: false
description: "Isolation, confidentiality, integrity, remote attestation, and the root of trust behind a Trusted Execution Environment."
tags: ["Confidential Computing", "TEE", "Remote Attestation"]
weight: 10
---

A Trusted Execution Environment (TEE) is a protected execution environment that runs alongside a device's main operating system, often called the Rich Execution Environment (REE). It provides security services to Trusted Applications (TAs) while protecting their code and data with hardware-enforced isolation. A TEE can also produce evidence about the code and state it is running for a remote verifier.

The defining boundary is enforced by hardware, not by a convention followed by the operating system. Under the assumed hardware and threat model, compromising the REE does not give an attacker access to a TEE's code or data. A familiar example is fingerprint payment on a phone: the biometric template is kept in a region that ordinary applications and the main OS cannot access.

## What makes an environment a TEE

In the strict definition used here, an environment is a TEE only when it provides all four of these properties:

| Property | Meaning | Example mechanism |
| --- | --- | --- |
| Isolation | Hardware enforces an access boundary. Code outside the TEE cannot access its code or data, or execute code inside it. | TrustZone bus security bit; SGX CPU boundary checks |
| Confidentiality | Unauthorized parties cannot read protected data. A memory-encryption design keeps its encryption keys inside the CPU. | Memory encryption |
| Integrity | Unauthorized parties cannot modify code or data without detection. | Hashes, MACs, and signatures checked at load time or during execution |
| Attestation | The environment can provide cryptographic evidence that it is genuine hardware running the claimed code. | A hardware-backed signature over the measured internal state |

Isolation, confidentiality, and integrity answer different questions. Isolation asks who can cross the boundary. Confidentiality asks whether someone who sees the content can understand it. Integrity asks whether someone can change it. Locking a diary in a drawer creates an isolation boundary. A roommate reading it through an open window is a confidentiality failure. If the drawer is pried open, isolation has failed, although a diary written in a private code may still preserve confidentiality.

Attestation has a different role. The first three properties describe the protection the environment is meant to provide. Attestation gives a remote party evidence that it is communicating with a particular protected environment running particular code. Evidence is useful only when there is meaningful protection behind it.

## How remote attestation works

Remote attestation does not ask the verifier to accept a self-report. The verifier checks cryptographic evidence itself. The following EK/AK example uses the Endorsement Key and Attestation Key terminology from the TPM reference listed below.

1. Establish a root of trust. At manufacture, an Endorsement Key (EK) is created and protected by the chip. Software cannot read or replace its private key, and the chip uses it only for allowed cryptographic operations.
2. Delegate the everyday signing key. The EK does not need to sign every report. It signs the public key of an Attestation Key (AK), producing an AK certificate. The verifier checks that certificate against the EK public key before trusting the AK.
3. Produce a quote. The protected environment measures its code and configuration state, signs the resulting hash with the AK, and sends the hash, signature, and AK certificate to the verifier.
4. Verify the evidence. The verifier validates the certificate chain with the manufacturer's public key, verifies the quote with the AK public key, and compares the measurement with the expected code and configuration.

The certificate chain separates the long-lived root key from routine attestation. A compromised or retired AK can be revoked without retiring the underlying chip. Under the cryptographic assumptions of the scheme, an attacker who lacks the protected private key cannot produce a quote that verifies as if it had come from that key.

## Root of trust and chain of trust

The root of trust is the small set of components accepted without further verification. The chain of trust is the sequence that transfers trust from that starting point. A common boot chain has ROM verify a bootloader, the bootloader verify the operating system, and the operating system verify applications.

Trust needs a starting point. A root of trust cannot establish its own integrity by referring only to itself, so the design depends on an initial anchor. In a hardware-rooted design, that anchor may include a protected device key and boot code stored in ROM. The manufacturer creates and provisions those components, but the useful property is their physical immutability after provisioning rather than an ongoing assumption that the manufacturer will behave honestly.

The threat model remains important. This discussion assumes trusted provisioning and considers the system after manufacture. It does not claim protection against physical decapping attacks. Design transparency and process controls can reduce the amount of trust placed in a manufacturer: an auditable hardware design such as OpenTitan permits broader review, while controlled key-generation environments, multi-party oversight, and logging help constrain the provisioning process.

## References

- [GlobalPlatform, TEE System Architecture](https://globalplatform.org/specs-library/tee-system-architecture/)
- [Sabt et al., *TEE: What It Is, and What It Is Not*](https://ieeexplore.ieee.org/document/7349447)
- [TCG, TPM Library Specification](https://trustedcomputinggroup.org/resource/tpm-library-specification/)
- [TCG, Roots of Trust](https://trustedcomputinggroup.org/resource/roots-of-trust/)
- [NIST IR 8320, *Hardware-Enabled Security*](https://doi.org/10.6028/NIST.IR.8320)
- [OpenTitan](https://opentitan.org/)
