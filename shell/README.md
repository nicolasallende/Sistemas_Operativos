# lab-shell

Repositorio para el esqueleto del [lab shell](https://fisop.github.io/7508/lab/shell) del curso Mendez-Fresia de **Sistemas Operativos (7508) - FIUBA**

## Compilar y ejecutar

```bash
$ make run
```

## Respuestas teóricas

Utilizar el archivo `shell.md` provisto en el repositorio

## Linter

```bash
$ make format
```


Para correr los test primero en donde se encuentre la shell hacer:
-make clean
-make -B -e SHELL_TEST=true

despues en la carpeta de test para la shell :

-TARGET_SHELL=(aca poner el path a la carpeta donde se encuentra la shell)/sh make test