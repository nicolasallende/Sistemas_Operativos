#include "exec.h"

// sets "key" with the key part of "arg"
// and null-terminates it
//
// Example:
//  - KEY=value
//  arg = ['K', 'E', 'Y', '=', 'v', 'a', 'l', 'u', 'e', '\0']
//  key = "KEY"
//
static void
get_environ_key(char *arg, char *key)
{
	int i;
	for (i = 0; arg[i] != '='; i++)
		key[i] = arg[i];

	key[i] = END_STRING;
}

// sets "value" with the value part of "arg"
// and null-terminates it
// "idx" should be the index in "arg" where "=" char
// resides
//
// Example:
//  - KEY=value
//  arg = ['K', 'E', 'Y', '=', 'v', 'a', 'l', 'u', 'e', '\0']
//  value = "value"
//
static void
get_environ_value(char *arg, char *value, int idx)
{
	size_t i, j;
	for (i = (idx + 1), j = 0; i < strlen(arg); i++, j++)
		value[j] = arg[i];

	value[j] = END_STRING;
}

// sets the environment variables received
// in the command line
//
// Hints:
// - use 'block_contains()' to
// 	get the index where the '=' is
// - 'get_environ_*()' can be useful here
static void
set_environ_vars(char **eargv, int eargc)
{
	for (int i = 0; i < eargc; i++) {
		char clave[256];
		char valor[256];
		int indice;

		// aca me tira el error en get_environ_key
		get_environ_key(eargv[i], clave);
		printf("Llegue aca bien\n");
		indice = block_contains(eargv[i], '=');
		get_environ_value(eargv[i], valor, indice);
		setenv(clave, valor, 0);  // Esto estaba con // no se si esta bien
	}
}

// opens the file in which the stdin/stdout/stderr
// flow will be redirected, and returns
// the file descriptor
//
// Find out what permissions it needs.
// Does it have to be closed after the execve(2) call?
//
// Hints:
// - if O_CREAT is used, add S_IWUSR and S_IRUSR
// 	to make it a readable normal file
static int
open_redir_fd(char *file, int flags)
{
	if (flags == 3) {
		dup2(1, 2);
		return 0;
	}

	if (flags == 2) {
		int fd = open(file, O_CREAT | O_CLOEXEC | O_RDWR, S_IWUSR | S_IRUSR);
		if (fd < 0) {
			perror("Error");
			_exit(-1);
		}
		dup2(fd, 2);
		close(fd);
		return 0;
	}


	if (flags == 1) {
		// redirecciono donde se escribe
		int fd = open(file,
		              O_TRUNC | O_CREAT | O_CLOEXEC | O_RDWR,
		              S_IWUSR | S_IRUSR);
		if (fd < 0) {
			perror("Error");
			_exit(-1);
		}
		dup2(fd, 1);
		close(fd);
		return 0;
	}

	if (flags == 0) {
		// redirecciono donde lee
		int fd = open(file, O_CLOEXEC | O_RDONLY, S_IRUSR);
		if (fd < 0) {
			perror("Error");
			_exit(-1);
		}
		dup2(fd, 0);
		close(fd);
	}


	return -1;
}

// executes a command - does not return
//
// Hint:
// - check how the 'cmd' structs are defined
// 	in types.h
// - casting could be a good option
void
exec_cmd(struct cmd *cmd)
{
	// To be used in the different cases
	struct execcmd *e;
	struct backcmd *b;
	struct execcmd *r;
	struct pipecmd *p;

	switch (cmd->type) {
	case EXEC:
		e = (struct execcmd *)
		        cmd;  // Uso casteo para convertir de cmd a execcmd

		set_environ_vars(e->eargv, e->eargc);  // No se si esto esta bien


		execvp(e->argv[0],
		       e->argv);  // paso el comando y los argumentos para ejecutar
		// si llega aca algo hice mal
		_exit(-1);
		break;

	case BACK: {
		b = (struct backcmd *) cmd;

		exec_cmd(b->c);

		// si llega aca algo hice mal
		_exit(-1);
		break;
	}

	case REDIR: {
		r = (struct execcmd *) cmd;

		if (strlen(r->out_file) > 0) {
			open_redir_fd(r->out_file, 1);
		}

		if (strlen(r->in_file) > 0) {
			open_redir_fd(r->in_file, 0);
		}

		if (strlen(r->err_file) > 0) {
			if (*r->err_file == *"&1") {
				open_redir_fd(r->err_file, 3);
			} else {
				open_redir_fd(r->err_file, 2);
			}
		}


		execvp(r->argv[0], r->argv);

		// si llega aca algo hice mal
		_exit(-1);
		break;
	}

	case PIPE: {
		p = (struct pipecmd *) cmd;
		int tuberia[2];

		if (pipe(tuberia) < 0) {
			perror("Error en el pipe");
			_exit(-1);
		}

		int difurcacion1 = fork();
		if (difurcacion1 < 0) {
			perror("Error en la difurcacion1");
			_exit(-1);
		}

		if (difurcacion1 ==
		    0) {  // Este primer hijo contiene al hijo izquierdo del cmd
			close(tuberia[0]);  // El primer comando no va a necesitar leer nunca

			// Redirecciono la salida del primer comando a la escritura de la tuberia
			dup2(tuberia[1], 1);
			close(tuberia[1]);

			exec_cmd(p->leftcmd);
		}
		// EL primer hijo ejecuta el exec y no va a llegar aca nunca

		close(tuberia[1]);  // El hijo es el que se encarga de redirigir la escritura

		int difurcacion2 = fork();

		if (difurcacion2 == 0) {
			// Redirecciono la entrada del segudo comando a la lectura de la tuberia
			dup2(tuberia[0], 0);
			close(tuberia[0]);

			exec_cmd(p->rightcmd);
		}
		wait(NULL);  // Espero a que termine el hijo izquierdo
		wait(NULL);  // Espero que termine el hijo derecho

		close(tuberia[0]);  // Ya se termino de redirigir todo

		free_command(parsed_pipe);

		// free the memory allocated
		// for the pipe tree structure


		exit(0);
	}
	}
}
