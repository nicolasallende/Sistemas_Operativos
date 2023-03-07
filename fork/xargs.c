#ifndef NARGS
#define NARGS 4
#endif
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

int
main(int argc, char *argv[])
{
	if (argc < 2) {
		perror("Error, falta pasar un comando, recomiendo echo");
		exit(-1);
	}


	size_t numero_bytes;
	char *cadena;
	numero_bytes = 0;
	cadena = 0;
	int i = 0;

	int largo = 400;  // Esto se que no esta bien que este hardcodeado pero
	char *algo[largo];  // no se como hacer que funcione sino

	while (getline(&cadena, &numero_bytes, stdin) != -1) {
		cadena[strcspn(cadena, "\n")] = 0;  // quito si tiene el \n
		algo[i + 1] = cadena;               // copio en el pal es tring


		// la posicion 0 tiene qe tener el comando

		for (i = 1; i < NARGS; i++) {
			if (getline(&algo[i + 1], &numero_bytes, stdin) != -1) {
				algo[i + 1][strcspn(algo[i + 1], "\n")] =
				        0;  // quito si tiene el \n

			} else {
				break;  // se termino lo que habia para leer salgo
			}
		}

		algo[i + 1] =
		        (char *) NULL;  // la ultima posicion tiene que tener null
		algo[0] = argv[1];      // le paso el comando

		int difurcacion = fork();
		if (difurcacion == 0) {
			execvp(argv[1], algo);
			perror("Error en el execvp");
		} else {
			wait(NULL);
		}
	}

	free(cadena);
	exit(0);
}