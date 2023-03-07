#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
// antes tenia solo void
int
main(void)
{
	int fdsPAdreAHijo[2];  // Filde descriptor donde padre escribe, hijo lee
	int fdsHijoAPadre[2];  // File descriptor donde hijo escribe, padre lee

	// Controlo que los pipe se hagan correctamente
	int r1 = pipe(fdsPAdreAHijo);
	int r2 = pipe(fdsHijoAPadre);
	if (r1 < 0 || r2 < 0) {
		perror("Error en pipe");
		exit(-1);
	}

	printf("Hola, soy PID %d:\n", getpid());
	printf(" - primer pipe me devuelve: [%d, %d]\n",
	       fdsPAdreAHijo[0],
	       fdsPAdreAHijo[1]);
	printf(" - segundo pipe me devuelve: [%d, %d]\n",
	       fdsHijoAPadre[0],
	       fdsHijoAPadre[1]);
	printf("\n");

	// Controlo que el fork se haga correctamente
	int i = fork();
	if (i < 0) {
		perror("Error en el fork");
		exit(-1);
	}

	if (i == 0) {                     // este es el hijo
		close(fdsPAdreAHijo[1]);  // hijo no escribe en este pipe
		close(fdsHijoAPadre[0]);  // hijo no lee en este pipe

		int recive = 0;
		int leido1 = read(fdsPAdreAHijo[0],
		                  &recive,
		                  sizeof(recive));  // lee lo que escribio padre
		if (leido1 < 0) {
			perror("Error en el read");
			exit(-1);
		}

		printf("Donde fork me devuelve 0:\n");
		printf(" - getpid me devuelve: %d\n", getpid());
		printf(" - getppid me devuelve: %d\n", getppid());
		printf(" - recibo valor %d vía fd =%d\n", recive, fdsPAdreAHijo[0]);
		close(fdsPAdreAHijo[0]);

		int escrito2 = write(fdsHijoAPadre[1],
		                     &recive,
		                     sizeof(recive));  // escribo para el padre
		if (escrito2 < 0) {
			perror("Error en el read");
			exit(-1);
		}

		printf(" - reenvío valor en fd=%d y termino\n", fdsHijoAPadre[1]);
		close(fdsHijoAPadre[1]);
		printf("\n");


	} else {                          // este es el padre
		close(fdsPAdreAHijo[0]);  // Padre no lee en este pipe
		close(fdsHijoAPadre[1]);  // Padre no escribe en este pipe

		printf("Donde fork me devuelve %d:\n", i);
		printf(" - getpid me devuelve: %d\n", getpid());
		printf(" - getppid me devuelve: %d\n", getppid());

		srand(time(NULL));
		int valor = rand() % 11;
		printf(" - random me devuelve: %d\n", valor);
		int escrito1 = write(fdsPAdreAHijo[1], &valor, sizeof(valor));
		if (escrito1 < 0) {
			perror("Error en el read");
			exit(-1);
		}

		printf(" - envío valor %d a través de fd=%d\n",
		       valor,
		       fdsPAdreAHijo[1]);
		close(fdsPAdreAHijo[1]);
		printf("\n");

		wait(NULL);
		int devuelve = 0;
		int leido2 = read(fdsHijoAPadre[0], &devuelve, sizeof(devuelve));
		if (leido2 < 0) {
			perror("Error en el read");
			exit(-1);
		}

		printf("Hola, de nuevo PID %d\n", getpid());
		printf("  - recibí valor %d vía fd=%d\n",
		       devuelve,
		       fdsHijoAPadre[0]);
		close(fdsHijoAPadre[0]);
		printf("\n");
	}
	return 0;
}