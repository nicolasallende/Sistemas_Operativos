#include "builtin.h"

// returns true if the 'exit' call
// should be performed
//
// (It must not be called from here)
int
exit_shell(char *cmd)
{
	// Your code here
	if ((strstr(cmd, "exit")) != NULL) {
		return 1;
	}


	return 0;
}

// returns true if "chdir" was performed
//  this means that if 'cmd' contains:
// 	1. $ cd directory (change to 'directory')
// 	2. $ cd (change to $HOME)
//  it has to be executed and then return true
//
//  Remember to update the 'prompt' with the
//  	new directory.
//
// Examples:
//  1. cmd = ['c','d', ' ', '/', 'b', 'i', 'n', '\0']
//  2. cmd = ['c','d', '\0']
int
cd(char *cmd)
{  //

	// Check if they gave the cd command
	if ((strstr(cmd, "cd")) == NULL) {
		return 0;
	}

	char *token[2];
	char *rest = cmd;
	int idx = 0;
	// separo el cd del posible directorio
	while ((token[idx] = strtok_r(rest, " ", &rest)) && idx < 2) {
		idx++;
	}

	if (idx == 1) {
		char *HomDir = getenv("HOME");  // consigo la direccion de $HOME
		int itWorked = chdir(
		        HomDir);  // Cambio la direccion del directorio a $HOME

		if (itWorked < 0) {
			perror("Error");
			return 0;
		}

		strcpy(prompt,
		       HomDir);  // Cambio el prompt que aparece en pantalla por el de $HOME
		return 1;
	}

	// si escribieron un directorio
	if (idx > 1) {
		char dir[strlen(token[1])];
		strcpy(dir, token[1]);
		int itWorked = chdir(dir);

		if (itWorked < 0) {
			perror("Error");
			return 0;
		}

		strcat(prompt, "/");
		strcat(prompt, dir);
		return 1;
	}

	return 0;
}

// returns true if 'pwd' was invoked
// in the command line
//
// (It has to be executed here and then
// 	return true)
int
pwd(char *cmd)
{
	char pathname[256];
	if (strcmp(cmd, "pwd") == 0) {
		printf("%s\n", getcwd(pathname, 256));
		return 1;
	}

	return 0;
}
