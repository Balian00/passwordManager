|; This file is setting up a random table T used to hash passwords.
T:
    STORAGE(TSizeConst)   |; STORAGE(n) allocates n 32-bits words


|; Function that initialize the random table T before filling it with random values
initRandomTable:
|; Function that initializes the random table T used for hashing
|; Parameters :
|;  - nbSubTables (number of subtables, first argument)
|;  - subTableSize (size of each subtable, second argument)
|; Returns : nothing

    |; Set up stack frame and save registers
    PUSH(LP)                      
    PUSH(BP)                      
    MOVE(SP, BP)                      
    PUSH(R0)
    PUSH(R1)
    PUSH(R2)
    PUSH(R3)
    PUSH(R4)
    PUSH(R5)

    |; Loading parameters
    LD(BP, -12, R0)                      |; R0 = nbSubTables (first arg)
    LD(BP, -16, R1)                      |; R1 = subTableSize (second arg)
    MUL(R0, R1, R1)                      |; R1 = total size

    CMOVE(0, R2)                         |; R2 = i = 0 (loop counter)
    CMOVE(T, R4)                         |; R4 = base address of T

loop_initRandomTable:
    |; Loop condition
    CMPLT(R2, R1, R3)                    |; R3 = (i < total_size)   | 1 if true, 0 if false
    BF(R3, end_initRandomTable)          |; if i >= total_size, exit loop   | BF = branching if false

    |; T[i] = random()
    SHLC(R2, 2, R5)                      |; R5 = i * 4 (byte offset)
    ADD(R4, R5, R5)                      |; R5 = address of T[i]
    RANDOM()                             |; R0 = random 32-bit value
    ST(R0, 0, R5)                        |; T[i] = random value

    |; T[i] = i (for tests)
    |; SHLC(R2, 2, R5)                      |; R5 = i * 4 (byte offset)    
    |; ADD(R4, R5, R5)                      |; R5 = address of T[i]
    |; ST(R2, 0, R5)                        |; T[i] = i (testing)

    |; Increment and return to loop start
    ADDC(R2, 1, R2)                      |; i++
    BR(loop_initRandomTable)             |; loop back (branching because we do not need to save the return adress)

end_initRandomTable:
    |; Restore registers and clean up stack frame
    POP(R5)
    POP(R4)
    POP(R3)
    POP(R2)
    POP(R1)
    POP(R0)

    MOVE(BP, SP)                          |; SP = BP
    POP(BP)                               |; Restore BP
    POP(LP)                               |; Restore LP
    JMP(LP, R31)                          |; Return