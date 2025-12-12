#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#define N_SUB_TABLES 20
// Here, 1 block is (generally) 1 character of the password.
#define BLOCK_SIZE_IN_BITS 8
#define MAX_NB_USERS 10

// Array to store the password hashes
int32_t passwordHashes[MAX_NB_USERS];

// Secret table of random numbers used for tabulation hashing
int32_t T[N_SUB_TABLES * (1 << BLOCK_SIZE_IN_BITS)];


static void initRandomTable(int32_t nbSubTables, int32_t subTableSize);
static int32_t verifyPassword(int32_t userId, uint8_t *password);
static int32_t hashPassword(uint8_t *password);
static int32_t hashPasswordRec(uint8_t *password, int32_t recursionDepth);
static int32_t checkHash(int32_t userId, int32_t hash);
static void setPassword(int32_t userId, uint8_t *password);


// "inline" means that function calls are replaced with the actual code in
// memory. Thus, you need to translate this into a macro in beta-assembly.
/* Translate coordinates (x,y) into a single index */
static inline uint32_t doubleTableIndex(uint32_t x, uint32_t y) {
    return y * (1 << BLOCK_SIZE_IN_BITS) + x;
}

/* Initialize the random table T with random values.
 * nbSubTables:  number of sub-tables in T
 * subTableSize: size of each sub-table
 */
static void initRandomTable(int32_t nbSubTables, int32_t subTableSize)
{
    for (int32_t i = 0; i < nbSubTables * subTableSize; i++)
    {
        // T[i] = (int32_t) rand();
        T[i] = i;
    }
}

/* Verify if the provided password is correct for the given user ID.
 * userId:   ID of the user whose password is to be verified
 * password: pointer to the password to verify
 * return:   1 if the password is correct, 0 otherwise
*/
static int32_t verifyPassword(int32_t userId, uint8_t *password)
{
    if (userId >= MAX_NB_USERS)
    {
        return 0;
    }

    int32_t hash = hashPassword(password);
    return checkHash(userId, hash);
}

/* Compute the hash of the given password.
 * password: pointer to the password to hash
 * return:   computed hash value
*/
static int32_t hashPassword(uint8_t *password)
{
    return hashPasswordRec(password, 0);
}

/* Recursive helper function to compute the hash of the password.
 * password:       pointer to the current character in the password
 * recursionDepth: current depth of recursion (used to select sub-table)
 * return:         intermediate hash value
*/
static int32_t hashPasswordRec(uint8_t *password, int32_t recursionDepth)
{
    // This function is a bit tricky to translate. Check out section 3.2 of the
    // statement before trying to do this... or don't, if you like challenges :)

    if (!password[0])
    {
        return 0;
    }

    int32_t currentDepthHash = T[doubleTableIndex(password[0], recursionDepth % N_SUB_TABLES)];
    return currentDepthHash ^ hashPasswordRec(password + 1, recursionDepth + 1);
}

/* Check if the computed hash matches the stored hash for the user.
 * userId: ID of the user
 * hash:   computed hash value
 * return: 1 if the hashes match, 0 otherwise
*/
static int32_t checkHash(int32_t userId, int32_t hash)
{
    if (userId >= MAX_NB_USERS)
    {
        return 0;
    }
    return passwordHashes[userId] == hash;
}

/* Set a new password for the given user ID.
 * userId:   ID of the user
 * password: pointer to the new password
*/
static void setPassword(int32_t userId, uint8_t *password)
{
    if (userId >= MAX_NB_USERS)
    {
        return;
    }
    int32_t hash = hashPassword(password);
    printf("Setting password hash for user %d: 0x%X\n", userId, hash);
    passwordHashes[userId] = hash;
}

int main(void)
{
    initRandomTable(N_SUB_TABLES, 1 << BLOCK_SIZE_IN_BITS);

    // Test 1: Empty string
    setPassword(0, (uint8_t*) "");
    printf("Test 1 - Empty string: %s\n", 
           verifyPassword(0, (uint8_t*) "") ? "PASS" : "FAIL");
    
    // Test 2: Very long password (>20 chars)
    setPassword(1, (uint8_t*) "ThisIsAVeryLongPasswordWithMoreThan20Characters");
    printf("Test 2 - Very long password: %s\n", 
           verifyPassword(1, (uint8_t*) "ThisIsAVeryLongPasswordWithMoreThan20Characters") ? "PASS" : "FAIL");
    
    /* // Test OLD 1: Single character (commented)
    setPassword(0, (uint8_t*) "A");
    printf("Test 1 - Single char 'A': %s\n", 
           verifyPassword(0, (uint8_t*) "A") ? "PASS" : "FAIL");
    
    // Test OLD 2: Empty string (commented)
    setPassword(1, (uint8_t*) "");
    printf("Test 2 - Empty string: %s\n", 
           verifyPassword(1, (uint8_t*) "") ? "PASS" : "FAIL");
    */
    
    // Test 3: Two characters
    setPassword(2, (uint8_t*) "AB");
    printf("Test 3 - Two chars 'AB': %s\n", 
           verifyPassword(2, (uint8_t*) "AB") ? "PASS" : "FAIL");
    
    // Test 4: Three characters
    setPassword(3, (uint8_t*) "XYZ");
    printf("Test 4 - Three chars 'XYZ': %s\n", 
           verifyPassword(3, (uint8_t*) "XYZ") ? "PASS" : "FAIL");
    
    // Test 5: Long password (>20 chars = more recursion levels than subtables)
    setPassword(4, (uint8_t*) "ThisIsAVeryLongPassword123");
    printf("Test 5 - Long password: %s\n", 
           verifyPassword(4, (uint8_t*) "ThisIsAVeryLongPassword123") ? "PASS" : "FAIL");
    
    // Test 6: All same character
    setPassword(5, (uint8_t*) "aaaaaaa");
    printf("Test 6 - Repeated 'a': %s\n", 
           verifyPassword(5, (uint8_t*) "aaaaaaa") ? "PASS" : "FAIL");
    
    // Test 7: Wrong password check
    setPassword(6, (uint8_t*) "correct");
    printf("Test 7 - Wrong password: %s\n", 
           !verifyPassword(6, (uint8_t*) "incorrect") ? "PASS" : "FAIL");
    
    // Test 8: Special characters
    setPassword(7, (uint8_t*) "P@ss!#$");
    printf("Test 8 - Special chars: %s\n", 
           verifyPassword(7, (uint8_t*) "P@ss!#$") ? "PASS" : "FAIL");
    
    // Test 9: Numbers only
    setPassword(8, (uint8_t*) "12345");
    printf("Test 9 - Numbers '12345': %s\n", 
           verifyPassword(8, (uint8_t*) "12345") ? "PASS" : "FAIL");

    // Test 11: Test if the code works if we try to set a password for userId >= MAX_NB_USERS
    setPassword(10, (uint8_t*) "OutOfBounds");
    // Print the hashPassword if setPassword worked incorrectly
    printf("Password hash for out of bounds userId 10: 0x%X\n", passwordHashes[10]);
    printf("Test 10 - Out of bounds userId set: %s\n", 
           !verifyPassword(10, (uint8_t*) "OutOfBounds") ? "PASS" : "FAIL");

    

    return EXIT_SUCCESS;
}
