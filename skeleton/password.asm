|; The array to store the hashes of the user's passwords
passwordHashes:
    STORAGE(maxNbUsersConst)   |; STORAGE(n) allocates n 32-bits words


verifyPassword:
|; Function that hash a given password and verify it against the stored hash for a user
|; Parameters :
|;  - userId (ID of the user whose password to verify)
|;  - passwordPtr (pointer to the password string in memory)
|; Returns :
|;  - R0 : 1 if the password is correct, 0 otherwise

    PUSH(LP)
    PUSH(BP)                              |; Save frame pointer
    MOVE(SP, BP)                          |; BP = SP (new frame pointer)

    PUSH(R1)
    PUSH(R2)

    LD(BP, -12, R0)                      |; R0 = userId
    LD(BP, -16, R1)                      |; R1 = passwordPtr

    LD(maxNbUsers, R3)
    CMPLT(R0, R3, R2)                   |; R2 = (userId < maxNbUsers)
    BT(R2, verify_valid_user)            |; if userId < maxNbUsers, continue
    CMOVE(0, R0)                         |; else return 0
    BR(end_verifyPassword)
    
verify_valid_user:
    MOVE(R0, R2)                         |; keep userId copy for offset

    PUSH(R1)                              |; Push passwordPtr
    CALL(hashPassword, 1)                 |; R0 = hashPassword(passwordPtr)

    PUSH(R0)                              |; Push computed hash first (arg1)
    PUSH(R2)                              |; Push userId second (arg2)
    CALL(checkHash, 2)                    |; R0 = checkHash(userId, hash)

end_verifyPassword:
    POP(R2)
    POP(R1)

    MOVE(BP, SP)                          |; SP = BP
    POP(BP)                               |; Restore BP
    POP(LP)                               |; Restore LP
    JMP(LP, R31)                          |; Return

setPassword:
|; Function that sets the password for a given user by hashing it and storing the hash
|; Parameters :
|;  - userId (ID of the user whose password to set)
|;  - passwordPtr (pointer to the password string in memory)
|; Returns : nothing

    PUSH(LP)                              |; Save return address
    PUSH(BP)                              |; Save frame pointer
    MOVE(SP, BP)                          |; BP = SP (new frame pointer)

    PUSH(R1)
    PUSH(R2)
    PUSH(R3)
    PUSH(R4)

    LD(BP, -12, R0)                      |; R0 = userId (a number)
    LD(BP, -16, R1)                      |; R1 = passwordPtr

    LD(maxNbUsers, R3)
    CMPLT(R0, R3, R2)                   |; R2 = (userId < maxNbUsers)
    BF(R2, end_setPassword)              |; if userId >= maxNbUsers, skip

    MOVE(R0, R2)                         |; keep userId copy for offset

    PUSH(R1)                              |; Push passwordPtr
    CALL(hashPassword, 1)                 |; R0 = hashPassword(passwordPtr)
    SHLC(R2, 2, R2)                       |; R2 = userId * 2^2 (byte offset)
    ADDC(R2, passwordHashes, R2)          |; R2 = address of passwordHashes[userId]
    ST(R0, 0, R2)                         |; passwordHashes[userId] = hash

end_setPassword:
    POP(R4)
    POP(R3)
    POP(R2)
    POP(R1)

    MOVE(BP, SP)                          |; SP = BP
    POP(BP)                               |; Restore BP
    POP(LP)                               |; Restore LP
    JMP(LP, R31)                          |; Return