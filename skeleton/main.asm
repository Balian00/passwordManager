.include beta.uasm

|; Constants. DO NOT DEFINE NEW CONSTANTS IN YOUR CODE, THESE ARE JUST FOR THE TABLE T AND PASSWORDHASHES
|; You do not have to use them in your code.
nSubTablesConst = 20
|; Here, 1 block is (generally) 1 character of the password.
blockSizeInBitsConst = 8
TSizeConst = nSubTablesConst * (1 << blockSizeInBitsConst)
maxNbUsersConst = 10

|; bootstrap
CMOVE(stack__, SP)
MOVE(SP, BP)
BR(main)

.include util.asm
.include table.asm
.include password.asm
.include hash.asm

nSubTables:
    LONG(nSubTablesConst)

blockSizeInBits:
    LONG(blockSizeInBitsConst)

maxNbUsers:
    LONG(maxNbUsersConst)

|; *---------------------------------------------------------------------*
|; |                                                                     |
|; |          4 example passwords to test your implementation.           |
|; |                  (you can set up to 10 passwords)                   |
|; |                                                                     |
|; *---------------------------------------------------------------------*

password_user0:
    LONG(0x0000000)

password_user1:
    LONG(0x54686973) LONG(0x49734156) LONG(0x6572794C) LONG(0x6F6E6750) LONG(0x61737377) LONG(0x6F726457) LONG(0x6974684D) LONG(0x6F726554) LONG(0x68616E32) LONG(0x30436861) LONG(0x72616374) LONG(0x65727300)

password_user0_old:
    LONG(0x44616D69) LONG(0x616E6F00)

password_user1_old:
    LONG(0x41000000)

password_user2:
    LONG(0x41420000)

password_user3:
    LONG(0x61610000)

password_user4:
    LONG(0x31000000)

password_user5:
    LONG(0x31323300)

password_user6:
    LONG(0x546F6D34) LONG(0x35360000)

password_user7:
    LONG(0x676D6169) LONG(0x6C2E636F) LONG(0x6D000000)

password_user8:
    LONG(0x546F6D5F) LONG(0x6C655F66) LONG(0x6F755F36) LONG(0x37000000)

password_bad:
    LONG(0x42616450) LONG(0x61737377) LONG(0x6F726400)

main:

    |; *---------------------------------------------------------------------*
    |; |                                                                     |
    |; |                        Initialization steps.                        |
    |; |                                                                     |
    |; *---------------------------------------------------------------------*


    |; initRandomTable(nSubTables, 1 << blockSizeInBits);
    LD(blockSizeInBits, R0)
    CMOVE(1, R1)
    SHL(R1, R0, R1)
    PUSH(R1)
    LD(nSubTables, R0)
    PUSH(R0)
    CALL(initRandomTable, 2)

    |; *---------------------------------------------------------------------*
    |; |                                                                     |
    |; |              Example code to test your implementation.              |
    |; |                                                                     |
    |; *---------------------------------------------------------------------*

    |; setPassword(0, password_user0) - empty string test
    CMOVE(password_user0, R1)
    PUSH(R1)
    PUSH(R31)
    CALL(setPassword, 2)

    |; setPassword(1, password_user1) - very long password test
    CMOVE(password_user1, R1)
    PUSH(R1)
    CMOVE(1, R0)
    PUSH(R0)
    CALL(setPassword, 2)

    |; |; setPassword(0, password_user0_old) - "Damiano" (commented)
    |; CMOVE(password_user0_old, R1)
    |; PUSH(R1)
    |; PUSH(R31)
    |; CALL(setPassword, 2)

    |; |; setPassword(1, password_user1_old) - "A" (commented)
    |; CMOVE(password_user1_old, R1)
    |; PUSH(R1)
    |; CMOVE(1, R0)
    |; PUSH(R0)
    |; CALL(setPassword, 2)

    |; setPassword(2, password_user2) - "AB"
    CMOVE(password_user2, R1)
    PUSH(R1)
    CMOVE(2, R0)
    PUSH(R0)
    CALL(setPassword, 2)

    |; setPassword(3, password_user3) - "aa"
    CMOVE(password_user3, R1)
    PUSH(R1)
    CMOVE(3, R0)
    PUSH(R0)
    CALL(setPassword, 2)

    |; setPassword(4, password_user4) - "1"
    CMOVE(password_user4, R1)
    PUSH(R1)
    CMOVE(4, R0)
    PUSH(R0)
    CALL(setPassword, 2)

    |; setPassword(5, password_user5) - "123"
    CMOVE(password_user5, R1)
    PUSH(R1)
    CMOVE(5, R0)
    PUSH(R0)
    CALL(setPassword, 2)

    |; setPassword(6, password_user6) - "Tom456"
    CMOVE(password_user6, R1)
    PUSH(R1)
    CMOVE(6, R0)
    PUSH(R0)
    CALL(setPassword, 2)

    |; setPassword(7, password_user7) - "gmail.com"
    CMOVE(password_user7, R1)
    PUSH(R1)
    CMOVE(7, R0)
    PUSH(R0)
    CALL(setPassword, 2)

    |; setPassword(8, password_user8) - "Tom_le_fou_67"
    CMOVE(password_user8, R1)
    PUSH(R1)
    CMOVE(8, R0)
    PUSH(R0)
    CALL(setPassword, 2)

    |; *---------------------------------------------------------------------*
    |; |                                                                     |
    |; |                    Verification tests                               |
    |; |                                                                     |
    |; *---------------------------------------------------------------------*
    |; Expected R0 sequence (after each CALL):
    |; 1 0   (user0 correct/wrong)
    |; 1 0 0 (user1 correct, wrong-empty, wrong-A)
    |; 1 0   (user2 correct/wrong)
    |; 1 0   (user3 correct/wrong)
    |; 1 0   (user4 correct/wrong)
    |; 1 0   (user5 correct/wrong)
    |; 1 0   (user6 correct/wrong)
    |; 1 0   (user7 correct/wrong)
    |; 1 0   (user8 correct/wrong)
    |; 0     (out-of-bounds user10)

        |; verifyPassword(0, password_user0) -> expected 1 (empty string correct)
        CMOVE(password_user0, R1)
        PUSH(R1)
        PUSH(R31)                        |; userId = 0
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 1
    
        |; verifyPassword(0, password_user1) -> expected 0 (wrong password for user 0)
        CMOVE(password_user1, R2)
        PUSH(R2)
        PUSH(R31)                        |; userId = 0
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

        |; verifyPassword(1, password_user1) -> expected 1 (long password correct)
        CMOVE(password_user1, R2)
        PUSH(R2)
        CMOVE(1, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 1

        |; verifyPassword(1, password_user0) -> expected 0 (wrong password for user 1)
        CMOVE(password_user0, R1)
        PUSH(R1)
        CMOVE(1, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

        |; verifyPassword(1, password_user1_old) -> expected 0 (wrong password - "A")
        CMOVE(password_user1_old, R2)
        PUSH(R2)
        CMOVE(1, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

        |; verifyPassword(2, password_user2) -> expected 1 (correct password)
        CMOVE(password_user2, R1)
        PUSH(R1)
        CMOVE(2, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 1

        |; verifyPassword(2, password_user1) -> expected 0 (wrong password)
        CMOVE(password_user1, R2)
        PUSH(R2)
        CMOVE(2, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

        |; verifyPassword(3, password_user3) -> expected 1
        CMOVE(password_user3, R1)
        PUSH(R1)
        CMOVE(3, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 1

        |; verifyPassword(3, password_user1) -> expected 0
        CMOVE(password_user1, R2)
        PUSH(R2)
        CMOVE(3, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

        |; verifyPassword(4, password_user4) -> expected 1
        CMOVE(password_user4, R1)
        PUSH(R1)
        CMOVE(4, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 1

        |; verifyPassword(4, password_user1) -> expected 0
        CMOVE(password_user1, R2)
        PUSH(R2)
        CMOVE(4, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

        |; verifyPassword(5, password_user5) -> expected 1
        CMOVE(password_user5, R1)
        PUSH(R1)
        CMOVE(5, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 1

        |; verifyPassword(5, password_user1) -> expected 0
        CMOVE(password_user1, R2)
        PUSH(R2)
        CMOVE(5, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

        |; verifyPassword(6, password_user6) -> expected 1
        CMOVE(password_user6, R1)
        PUSH(R1)
        CMOVE(6, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 1

        |; verifyPassword(6, password_user1) -> expected 0
        CMOVE(password_user1, R2)
        PUSH(R2)
        CMOVE(6, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

        |; verifyPassword(7, password_user7) -> expected 1
        CMOVE(password_user7, R1)
        PUSH(R1)
        CMOVE(7, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 1

        |; verifyPassword(7, password_user1) -> expected 0
        CMOVE(password_user1, R2)
        PUSH(R2)
        CMOVE(7, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

        |; verifyPassword(8, password_user8) -> expected 1
        CMOVE(password_user8, R1)
        PUSH(R1)
        CMOVE(8, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 1

        |; verifyPassword(8, password_user1) -> expected 0
        CMOVE(password_user1, R2)
        PUSH(R2)
        CMOVE(8, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

        |; setPassword(10, password_bad) - out of bounds userId
        CMOVE(password_bad, R1)
        PUSH(R1)
        CMOVE(10, R0)
        PUSH(R0)
        CALL(setPassword, 2)

        |; verifyPassword(10, password_bad) -> expected 0 (userId out of bounds)
        CMOVE(password_bad, R2)
        PUSH(R2)
        CMOVE(10, R0)
        PUSH(R0)
        CALL(verifyPassword, 2)
        .breakpoint
        |; R0 expected: 0

    |; Updated expected R0 sequence: 0 1 1 1 0 1 0 0

    HALT()





    |; check for 0xDEADCAFE in the memory explorer
    |; to find the base of the stack
    LONG(0xDEADCAFE)
stack__:
    STORAGE(1024)
