## Password Manager (Beta ASM + C)

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
