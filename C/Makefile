FLAGS = -Wall -pedantic -std=c99 -Wextra

all: password_management string_to_beta_asm

password_management: password_management.c
	gcc $(FLAGS) -o password_management password_management.c

string_to_beta_asm: string_to_beta_asm.c
	gcc $(FLAGS) -o string_to_beta_asm string_to_beta_asm.c

clean:
	rm -f string_to_beta_asm password_management

