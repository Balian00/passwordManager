|; This files is intermediary between hash.asm and main.asm
|; It contains the storage for password hashes and functions to set and verify passwords
passwordHashes:
    STORAGE(maxNbUsersConst)   |; STORAGE(n) allocates n 32-bits words


verifyPassword:
|; Function that hash a given password and verify it against the stored hash for a user
|; Parameters :
|;  - userId (ID of the user whose password to verify)
|;  - passwordPtr (pointer to the password string in memory)
|; Returns :
|;  - R0 : 1 if the password is correct, 0 otherwise

    |; Set up stack frame and save registers
    PUSH(LP)
    PUSH(BP)                           
    MOVE(SP, BP)                      
    PUSH(R1)
    PUSH(R2)

    |; Loading parameters
    LD(BP, -12, R0)                      |; R0 = userId
    LD(BP, -16, R1)                      |; R1 = passwordPtr

    |; Check userId validity
    LD(maxNbUsers, R3)
    CMPLT(R0, R3, R2)                    |; R2 = (userId < maxNbUsers)
    BT(R2, verify_valid_user)            |; if userId < maxNbUsers, continue

    |; Invalid userId case, return 0 in R0
    CMOVE(0, R0)                         |; else return 0
    BR(end_verifyPassword)
    
verify_valid_user:
    MOVE(R0, R2)                          |; Keep userId copy for offset

    |; Hash the provided password
    PUSH(R1)                              |; Push parameter for hashPassword : passwordPtr
    CALL(hashPassword, 1)                 |; Return R0 = hashPassword(passwordPtr)

    |; Verify the computed hash against the stored hash
    PUSH(R0)                              |; Push computed hash first (arg1)
    PUSH(R2)                              |; Push userId second (arg2)
    CALL(checkHash, 2)                    |; R0 = checkHash(userId, hash)

end_verifyPassword:
    |; Restore registers and clean up stack frame
    POP(R2)
    POP(R1)
    MOVE(BP, SP)                     
    POP(BP)                        
    POP(LP)                        
    JMP(LP, R31)                 

setPassword:
|; Function that sets the password for a given user by hashing it and storing the hash
|; Parameters :
|;  - userId (ID of the user whose password to set)
|;  - passwordPtr (pointer to the password string in memory)
|; Returns : nothing

    |; Set up stack frame and save registers
    PUSH(LP)                        
    PUSH(BP)                        
    MOVE(SP, BP)                    
    PUSH(R1)
    PUSH(R2)
    PUSH(R3)
    PUSH(R4)

    |; Loading parameters
    LD(BP, -12, R0)                      |; R0 = userId (a number)
    LD(BP, -16, R1)                      |; R1 = passwordPtr

    |; Check userId validity
    LD(maxNbUsers, R3)
    CMPLT(R0, R3, R2)                   |; R2 = (userId < maxNbUsers)

    |; If invalid userId, just skip setting password
    BF(R2, end_setPassword)             

    MOVE(R0, R2)                         |; keep userId copy for offset

    |; Hash the provided password
    PUSH(R1)                              |; Push passwordPtr
    CALL(hashPassword, 1)                 |; R0 = hashPassword(passwordPtr)
    SHLC(R2, 2, R2)                       |; R2 = userId * 2^2 (byte offset)
    CMOVE(passwordHashes, R4)             |; R4 = base address of passwordHashes
    ADD(R4, R2, R2)                       |; R2 = address of passwordHashes[userId]
    ST(R0, 0, R2)                         |; passwordHashes[userId] = hash

end_setPassword:
    |; Restore registers and clean up stack frame
    POP(R4)
    POP(R3)
    POP(R2)
    POP(R1)
    MOVE(BP, SP)                        
    POP(BP)                             
    POP(LP)                            
    JMP(LP, R31)                      