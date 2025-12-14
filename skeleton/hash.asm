hashPassword:
|; Function that computes the hash of a password using a recursive approach
|; Parameters :
|;  - passwordPointer (pointer to the null-terminated password string)
|; Returns :
|;  - R0 : computed hash value

    |; Set up stack frame and save registers
    PUSH(LP)
    PUSH(BP)
    MOVE(SP, BP)
    PUSH(R1)

    |; Loading parameters
    LD(BP, -12, R1)                       |; R1 = passwordPointer

    |; Call recursive helper function
    PUSH(R1)                              |; Push passwordPointer as argument
    PUSH(R31)                             |; recursionDepth = 0
    CALL(hashPasswordRec, 2)              |; R0 = hashPasswordRec(passwordPointer, 0)
    POP(R1)

    |; Restore registers and clean up stack frame
    MOVE(BP, SP)                   
    POP(BP)                           
    POP(LP)                           
    JMP(LP, R31)                     

hashPasswordRec:
|; Recursive helper function for hashPassword
|; Parameters :
|;  - passwordPointer (pointer to the null-terminated password string)
|;  - recursionDepth (current depth of recursion, starting at 0)
|; Returns :
|;  - R0 : computed hash value

    |; Set up stack frame and save registers
    PUSH(LP)
    PUSH(BP)
    MOVE(SP, BP)
    PUSH(R1)
    PUSH(R2)
    PUSH(R3)
    PUSH(R4)
    PUSH(R5)

    |; Loading parameters
    LD(BP, -32, R0)                      |; R0 = passwordPointer = adress of current character
    LD(BP, -36, R1)                      |; R1 = recursionDepth

    |; Load current character
    ANDC(R0, 0XFFFFFFFC, R2)             |; R2 = aligned address of current character (address & 0xFFFFFFFC)
    LD(R2, 0, R2)                        |; R2 = word containing current character
    CMOVE(4, R4)
    MOD(R0, R4, R3)                      |; R3 = current_adress % 4 (use R4 as divisor, R3 as result)
    MULC(R3, -1, R3)                     |; R3 = - (current_adress % 4)
    ADDC(R3, 3, R3)                      |; R3 = 3 + (- (current_adress % 4))
    SHLC(R3, 3, R3)                      |; R3 = R3 * 2^3 = R3 * 8 = nb_bits_to_shift
    SHR(R2, R3, R2)                      |; R2 = R2 >> nb_bits_to_shift
    CMOVE(0xFF, R4)                      |; mask for low byte
    AND(R2, R4, R4)                      |; R4 = current character (R2 & 0x000000FF)

    |; Base case: if current character is null terminator, return 0
    CMPEQC(R4, 0, R3)                     |; R3 = (*passwordPointer == 0) ? 1 if true, 0 if false
    BT(R3, terminal_base)                |; if end of string, return 0

    |; Recursive case
    LD(nSubTables, R5)                   |; R5 = nSubTables (20)
    MOD(R1, R5, R2)                      |; R2 = recursionDepth % nSubTables
    DOUBLE_ARR_OFFSET(R4, R2, R3)        |; R3 = 1D index in T (use R4 = current char!)
    SHLC(R3, 2, R3)                      |; R3 = index * 4 (byte offset)
    ADDC(R3, T, R3)                      |; R3 = address of T[current char][recursionDepth % nSubTables]
    LD(R3, 0, R5)                        |; R5 = currentDepthHash
    ADDC(R0, 1, R0)                      |; R0 = passwordPointer + 1 (next byte!)
    ADDC(R1, 1, R1)                      |; R1 = recursionDepth + 1
    PUSH(R0)
    PUSH(R1)
    CALL(hashPasswordRec, 2)             |; R0 = hashPasswordRec(passwordPointer + 1, recursionDepth + 1)

    |; XOR currentDepthHash with recursiveHash
    XOR(R0, R5, R0)                      |; R0 = currentDepthHash ^ recursiveHash
    BR(end_hashPasswordRec)

terminal_base:
    |; Base case: if current character is null terminator, return 0
    CMOVE(0, R0)                        
    BR(end_hashPasswordRec)

end_hashPasswordRec:
    |; Restore registers and clean up stack frame
    POP(R5)
    POP(R4)
    POP(R3)
    POP(R2)
    POP(R1)
    MOVE(BP, SP)                    
    POP(BP)                          
    POP(LP)                       
    JMP(LP, R31)                     

checkHash:
|; Function that checks if the given hash matches the stored hash for a user
|; Parameters :
|;  - userId (ID of the user whose password hash to verify)
|;  - hashToCheck (hash value to compare against the stored hash)
|; Returns :
|;  - R0 : 1 if the hashes match, 0 otherwise

    |; Set up stack frame and save registers
    PUSH(LP)                            
    PUSH(BP)                              
    MOVE(SP, BP)                  
    PUSH(R1)
    PUSH(R2)

    |; Loading parameters
    LD(BP, -12, R0)                      |; R0 = userId
    LD(BP, -16, R1)                      |; R1 = hashToCheck

    |; Check userId validity
    CMPLTC(R0, maxNbUsers, R2)          |; R2 = (userId < maxNbUsers)
    BT(R2, checkHash_valid_user)       |; if userId >= maxNbUsers, skip to return 0

    |; Return 0 for invalid userId
    CMOVE(0, R0)                         
    BR(checkHash_end)

checkHash_valid_user:
    SHLC(R0, 2, R0)                      |; R0 = userId * 4 (byte offset)
    ADDC(R0, passwordHashes, R0)         |; R0 = address of passwordHashes[userId]
    LD(R0, 0, R0)                        |; R0 = passwordHashes[userId] (stored hash)

    CMPEQ(R0, R1, R0)                    |; R0 = (storedHash == hashToCheck) ? 1 if match, 0 if not
    
checkHash_end:
    |; Restore registers and clean up stack frame
    POP(R2)
    POP(R1)
    MOVE(BP, SP)                 
    POP(BP)                          
    POP(LP)                            
    JMP(LP, R31)                    

