# fisopfs

Sistema de archivos tipo FUSE.


----------------------------------------------------------------------------------

Pruebas
--

Se considera que ya fue montado previamente haciendo: 

mkdir prueba // en caso de que no exista un directorio pruebas previo
./fisopfs prueba
cd prueba



Cada modulo de prueba fue pensado independientemente entre si, por un lado probar los touch y rm (o unlink), por otro los mkdir y rmdir, por otro mas el cat, less y more, y asi
sucesivamente.

----------------------------------------------------- touch y rm---------------------------------------------------------------

Considerando que este vacio desde el principio 

------------------------------------------Probamos hacer un archivo y eliminarlo---------------------------

$ ls

$ touch a
$ ls 
a

$ touch a // no se tiene que pasar nada
$ ls 
a

$ unlink a 
$ ls 



----------------------------------------------------mkdir  y rmdir  --------------------------------------------------------------

Considerando que este vacio desde el principio 

------------------------------------------Probamos que se haga un directorio ---------------------
$ ls

$ mkdir a
$ ls 
a
-------------Probamos que se puedan hacer mas directorio dentro del original ---------------
$ cd a
$ ls 

$ mkdir b 
$ mkdir c
$ ls 
b c

$ cd b
$ ls 

$ cd ..
$ ls 
b c

------------Probamos que no se pueda hacer otra carpeta con el mismo nombre-------------------

$ mkdir b 
mkdir: cannot create directory ‘a’: File exists
$ ls


-------------------------Probamos eliminar un directorio---------------------------

$ ls
b c
$ rmdir b 
$ ls
c
$ rmdir b
rmdir: failed to remove 'a': No such file or directory

--------------------------Probamos eliminar un directorio con cosas dentro-------------------

$ cd ..
$ ls
a
$ rmdir a
rmdir: failed to remove 'a': Invalid argument
$ cd a 
$ rmdir c 
$ cd ..
$ rmdir a 
$ ls 


---------------------------------------------------- cat, more y less------------------------------------------------------------------

Considerando que este vacio desde el principio 

--------------------------------------------- Probamos leer un archivo con cat ------------------

$ touch texto
$ echo "Algo con que llenar el texto" >> texto
$ cat texto
Algo con que llenar el texto
$ echo "Otra cosa mas que se tenia que agregar" >> texto
$ cat texto
Algo con que llenar el texto
Otra cosa mas que se tenia que agregar

$ rm texto

---------------------------------------------Probamos leer usando el comando more------------------

$ touch texto 

$ echo "El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico." >> texto 

$ echo "El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico." >> texto 

$ echo "El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico." >> texto 

$ echo "El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico." >> texto 

$ echo "El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico." >> texto 

$ echo "El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico." >> texto 


$ more texto 

El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego imple
--More--(98%)

//salir de este modo de lectura apretando enter o como prefieran




-------------------------------------------------- Probar leer usando less ------------------------------------------


$ less texto 
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
El sistema de archivo implementado debe existir en memoria RAM durante su operación. La estructura en memoria que se utilice para lograr tal funcionalidad es enteramente a diseño del grupo. Deberá explicarse claramente, con ayuda de diagramas, en el informe del trabajo (i.e. el archivo TP3.md); las decisiones tomadas y el razonamiento detrás de las mismas.La primera parte de la entrega, consistirá en el diseño de las estructuras que almacenarán toda la información, y cómo las mismas se accederán en cada una de las operaciones. Para luego implementarlas en la segunda parte del trabajo práctico.
(END)

//usar algun comando de less para chequear que funcione como por ejemplo: /sistema y esto deberia resaltar todas las veces que aparece la palabra en el texto

$ rm texto 

----------------------------------------------------------------------------------------------------------------------------------

Informacion sobre el codigo
--

---------------------------------------------
	// Estructura que se usa para la persistencia en el disco
struct persisted_file{
	char name[NAME_SIZE];
	struct stat st;
};


//Estructura principal de archivos ya sea directorio o file

struct file{
	bool available;							
	struct file* father;					//Archivo padre, el del directorio raiz es NULL
	char name[NAME_SIZE];					//Nombre del archivo
	int flags; 								//Permisos, si es solo de lectura o tammbien de escritura, ignorar x ahora
	struct stat st; 						//st->mode = TYPE_REG(si es un archivo comun de datos) | TYPE_DIR (si es un directorio);
	struct regular_file* regular_file; 		//If is a file
	struct directory_file* directory_file;	//If is a directory
};

//Estructura para un file  

struct regular_file{
	bool available;
	int used_data;							//Cantidad de datos almacenados
	char data[4096];						//La informacion almacenada
};

//Estructura para un directorio

struct directory_file{
	bool available;
	int current_childs;						//Cantidad de archivos/directorios dentro del directorio actual
	struct file* childs[MAX_DIRECTORIES];	//Array con los archivos/directorios dentro del directorio actual
};


Ver Imagen structs
