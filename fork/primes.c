#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int funcionsimple(int fdsPipeAnterior);

int
funcionsimple(int fdsPipeAnterior)
{
	int numeroAnterior = 0;
	if (read(fdsPipeAnterior, &numeroAnterior, sizeof(numeroAnterior)) == 0) {
		close(fdsPipeAnterior);  // no se si esto esta bien
		return 0;
	}
	printf("primo %d\n", numeroAnterior);  // imprimo el primo

	int fdsPipeSiguiente[2];
	int numeroNuevo = 0;
	int p1 = pipe(fdsPipeSiguiente);
	if (p1 < 0) {
		perror("Error en pipe");
		exit(-1);
	}
	int dif = fork();
	if (dif < 0) {
		perror("Error den el Fork");
		exit(-1);
	}


	if (dif ==
	    0) {  // este es el hijo, quiero que se le pasen todos los numeros ya filtrados
		close(fdsPipeAnterior);      // El hijo no lee el anterior
		close(fdsPipeSiguiente[1]);  // El hijo no escribe el siguiente
		funcionsimple(fdsPipeSiguiente[0]);
		close(fdsPipeSiguiente[0]);

	} else {  // este es el padre quiero que escriba todos los numeros filtrados al nuevo pipe
		close(fdsPipeSiguiente[0]);

		while (read(fdsPipeAnterior, &numeroNuevo, sizeof(numeroNuevo)) !=
		       0) {
			if (numeroNuevo % numeroAnterior != 0) {
				int a = write(fdsPipeSiguiente[1],
				              &numeroNuevo,
				              sizeof(numeroNuevo));
				if (a < 0) {
					perror("Error en el write");
					exit(-1);
				}
			}
		}

		close(fdsPipeSiguiente[1]);  // ya termino de escribir
		close(fdsPipeAnterior);  // ya terminamos de leer el anterior

		wait(NULL);
	}
	return 0;
}

int
main(int argc, char *argv[])
{
	if (argc != 2) {
		perror("no pasa cantidad correcta");
		exit(-1);
	}
	int Maximo = atoi(argv[1]) +
	             1;  // el numero que recibo por consola lo paso a entero
	int fdsPrimerPipe[2];
	int r1 = pipe(fdsPrimerPipe);
	if (r1 < 0) {
		perror("Error en pipe");
		exit(-1);
	}

	int i = fork();
	if (i < 0) {
		perror("Error den el Fork inicial");
		exit(-1);
	}

	if (i == 0) {
		close(fdsPrimerPipe[1]);
		funcionsimple(fdsPrimerPipe[0]);
		close(fdsPrimerPipe[0]);

	} else {
		close(fdsPrimerPipe[0]);  // el padre nunca va a tratar de leer
		for (int num = 2; num < Maximo; num++) {
			int a = write(fdsPrimerPipe[1], &num, sizeof(num));
			if (a < 0) {
				perror("Error en el write");
				exit(-1);
			}
		}
		close(fdsPrimerPipe[1]);  // cierro porque el padre termino de escribir
		wait(NULL);               // espera hasta que sus hijos terminen
	}

	return 0;
}