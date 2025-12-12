#include <stdio.h>
#include <stdlib.h>

int main(int argc, const char *argv[])
{
    // Array of all passwords to convert
    const char* passwords[] = {
        "",
        "ThisIsAVeryLongPasswordWithMoreThan20Characters",
        "AB",
        "aa",
        "1",
        "123",
        "Tom456",
        "gmail.com",
        "Tom_le_fou_67",
        "Damiano",
        "A"
    };
    int num_passwords = sizeof(passwords) / sizeof(passwords[0]);

    // Convert each password
    for (int pwd_idx = 0; pwd_idx < num_passwords; pwd_idx++)
    {
        printf("password_user%d:\n    ", pwd_idx);
        
        const char* str = passwords[pwd_idx];
        for (int i = 0;; i++)
        {
            switch (i%4)
            {
                case 0:
                    printf("LONG(0x%X", (unsigned char) str[i]);
                    break;
                case 1:
                case 2:
                    printf("%X", (unsigned char) str[i]);
                    break;
                case 3:
                    printf("%X) ", (unsigned char) str[i]);
                    break;
            }
            if (!str[i+1]) // end of the string
            {
                switch (i%4)
                {
                    case 0:
                        printf("000000)");
                        break;
                    case 1:
                        printf("0000)");
                        break;
                    case 2:
                        printf("00)");
                        break;
                    case 3:
                        printf("LONG(0x0)");
                        break;
                }
                break; // break out of the "for" loop
            }
        }
        printf("\n\n");
    }
    
    return EXIT_SUCCESS;
}
