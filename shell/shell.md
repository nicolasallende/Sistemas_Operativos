# Lab: shell

### Búsqueda en $PATH
Las diferencias estan en como se haya el programa, como son especificados los argumentos y de donde viene el ambiente. Todas las funciones de la familia exec() (execl, execlp, execle, execv, execvp, execvpe ) son segun el manual, front-end para la funcion  execve


La llamada a exec(3) puede fallar, en esos casos devuelve un -1 y errno es seteado para indicar el tipo de error.

### Comandos built-in
El pwd podria ser implementada sin necesidad de ser built-in, ya existe una funcion getcwd() que hace justamente eso, nos da el directorio actual.
La ventaja de hacerlo de esta forma es porque en el built-in es capaz de recordar como accedio al directorio de enlaces simbólicos.
La funcion en cambio solo sabe cual es tu directorio actual, no como llegaste, por eso da el "camino real". 

---

### Variables de entorno adicionales

Porque si no lo hacemos despues del fork, estariamos modificando el entorno de la shell, agregandole las variables nuevas en vez de hacerlas solo temporales.

El comportamiento resultaria el mismo ya que las funciones execle, execve y execvpe tienen un puntero environ que apunta a un arreglo de strings de la forma clave=valor, con eso se puede especificar el enviroment del programa ejecutado.

Se podria chequear si nos pasan nuevas variables de entorno, en caso de que si den nuevas variables, usando execvep por ejemplo le pasamos esas nuevas variables y se ejecuta el resto como siempre.
 

### Procesos en segundo plano
Realizar un proceso en segundo plano consiste en una vez que se sabe que se desea correr en segundo plano en el runcmd se genera un primer fork y ahi el padre "espera" con un waitpid con el flag WNOHANG asi el proceso padre no se bloquea y para que cuando termine el proceso hijo se lo pueda levantar y no quede defunc.
El hijo por su parte llama al exec_cmd y ejecuta los comandos pasados.
Asi el padre deberia poder seguir funcionando mientras que el hijo ejecuta el proceso en segundo plano.

WNOHANG: este flag especifica que el waitpid deberia regresar inmediatamente en vez de esperar, si es que no hay un proceso hijo listo para ser notado.



---

### Flujo estándar
El 2>&1 se utiliza cuando se quiere combinar la salida de stderr y stdout en la salida normal para poder manipular los errores.
El 1 representa la stdout y el 2 la stderr, se le agrega el & al 1 para poder diferenciar la stdout de un archivo cualquiera llamado 1.



--Esto en el bash

Luego de ejecutar los comandos: "ls -C /home /noexiste >out.txt 2>&1" 
la salida: "cat out.txt" creo el archivo out.txt y escribio en el out.txt: 
	cannot access '/noexiste': No such file or directory
	/home: nicolas

Invirtiendo el orden de los comandos: "ls -C /home /noexiste 2>&1 >out.txt"
	me paso primero por pantalla: "ls: cannot access '/noexiste': No such file or directory"
	Y al hacer el "cat out.txt" solo se veia que tenia escrito adentro el "/home: nicolas"

--Esto en mi shell

Dio igual que en el bash esta parte pero al invertir siguio dando lo mismo que esta aca abajo.
Luego de ejecutar los comandos: "ls -C /home /noexiste >out.txt 2>&1" 
la salida: "cat out.txt" creo el archivo out.txt y escribio en el out.txt: 
	cannot access '/noexiste': No such file or directory
	/home: nicolas






### Tuberías simples (pipes)

Al ejecutarse un pipe el codigo de salida reportado suele ser el el estado de salida del ultimo comando, a menos que se active la opcion "pipefail", en tal caso el estado de salida es el del comando de mas a la derecha que que no haya tenido salida 0, o 0 en caso de que todo funcionara correctamente.  

Si alguno de los comandos pasados por un pipe falla, por ejemplo el comando no existe, el pipe va a seguir tratando de ejecutar el resto y va a indicar que no encontro el comando que no existia.

-----En bash 

nicolas@ok:~/sisop_2022b_allende/shell$ ls -l | wd |echo hi
hi
wd: command not found


Tambien puede tratar de dar sugerencias sobre posibles comandos:

nicolas@ok:~/sisop_2022b_allende/shell$ ls -l | ech Doc | wc

Command 'ech' not found, did you mean:

  command 'ecc' from deb ecere-dev
  command 'ecp' from deb ecere-dev
  command 'ecl' from deb ecl
  command 'echo' from deb coreutils
  command 'sch' from deb scheme2c
  command 'ecj' from deb ecj
  command 'ecs' from deb ecere-dev
  command 'ecm' from deb gmp-ecm
  command 'dch' from deb devscripts
  command 'bch' from deb bikeshed

Try: sudo apt install <deb name>

      0       0       0

-----En mi shell 

(/home/nicolas) 
$ ls -l | ech Doc | wc
      0       0       0

(/home/nicolas) 
$ ls -l | wd |echo hi
hi




### Pseudo-variables


1) $$ Nos devuelve el PID de la shell actual 

------En mi shell 1
nicolas@ok:~$ echo $$
7273

------En mi shell 2
nicolas@ok:~$ echo $$
7300
nicolas@ok:~$ echo $$
7300


2) $0  expande al nombre de la shell o del shell 
-----En mi shell 
nicolas@ok:~/Desktop$ echo $0
bash


3) $1, $2, $3, .... Devuelve el parametro que le fue pasado, 1 es para el primer parametro 2 para el segundo, etc.


----En mi shell

nicolas@ok:~/Desktop$ ./positional.sh hola y chau pero 
hola es el primer parametro posicional.

y es el segundo parametro posicional.

chau es el tercer parametro posicional.

Mi PID es: 9418 

El nombre del script es: ./positional.sh


el script que use:

----------------------------------
#!/bin/bash
echo "$1 es el primer parametro posicional."
echo
echo "$2 es el segundo parametro posicional." 
echo
echo "$3 es el tercer parametro posicional."
echo
echo "Mi PID es: $$ "
echo
echo "El nombre del script es: $0"
----------------------------------





