## Password Manager (Beta ASM + C)

This repository contains a course project completed for **INFO0012-2 —
Computation structures** at the University of Liège (ULiège). The project
explores low-level programming through the implementation of a password
manager in Beta assembly, with a C implementation used as a reference.

Course information: [INFO0012-2 — Computation structures](https://www.programmes.uliege.be/cocoon/20252026/en/cours/INFO0012-2.html).

### Repository structure
- [`C/`](C/) contains the C implementation used as a functional reference.
- [`skeleton/`](skeleton/) contains the Beta assembly implementation and its test entry point.
- [`assignement/`](assignement/) contains the assignment documents and supporting material.

### Prerequisites
- GCC, to compile the string-conversion utility when password test data must be regenerated.
- A Beta assembler and simulator compatible with the course environment.

### 1) Project goal
- Implement a password manager in Beta assembly following the two assignment PDFs.
- The C code (`C/password_management.c`) is the functional reference: same cases (empty and very long passwords, bad indices, correct/incorrect checks) and same hash/storage logic. The ASM must mirror that behavior.

### 2) Run and test `main`
- Generate Beta ASM string constants: `gcc string_to_beta_asm.c -o string_to_beta_asm`, then run it to refresh `LONG(...)` password data if needed.
- For deterministic tests, set the table to `T[i] = i` (no randomness) in `table.asm`/`util.asm` so hashes are reproducible.
- Assemble/load `skeleton/main.asm` in the Beta simulator. Each `CALL(verifyPassword, 2)` is followed by a breakpoint; at every stop read `R0` and compare with the expected sequence in comments.

### 3) Pros and limits
- Pros: easy to audit, exhaustive checks (good/bad passwords, out-of-bounds indices), C reference to validate the ASM.
- Blocking limits for real use: no persistence or at-rest encryption, no memory isolation, weak hashing (no salt/iterations), no hardening against hostile input, and reliance on the Beta simulator (not ready for a real machine without major porting).

This is an academic project intended for the course environment, not a
production-ready password manager.

### Authorship note
This README was drafted with AI assistance and reviewed by the author. The
source code was written entirely without AI assistance as part of the course
project.
