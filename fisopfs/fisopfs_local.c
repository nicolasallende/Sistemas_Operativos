#define FUSE_USE_VERSION 30

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <stdbool.h>

#define ARRAY_SIZE 256
#define MAX_DIRECTORIES 20
#define NAME_SIZE 50

#define TYPE_DIR 0755
#define TYPE_REG 0644

//Estructuras de file en memoria
struct file{
	bool available;
	struct file* father;
	char name[NAME_SIZE];
	int flags; //Permisos, si es solo de lectura o tammbien de escritura, ignorar x ahora
	struct stat st; //st->mode = TYPE_REG(si es un archivo comun de datos) | TYPE_DIR (si es un directorio);
	struct regular_file* regular_file; //If is a file
	struct directory_file* directory_file;//If is a directory
};

struct regular_file{
	bool available;
	int used_data;
	char available_data[1024];
};

struct directory_file{
	bool available;
	int current_childs;
	struct file* childs[MAX_DIRECTORIES];
};

struct file root_file;
struct directory_file root_directory_file;

//Estructuas de file en disco: (pendientes XD)

static void list_files(struct file* file, int indentationLevel){
	//printf(".............................................................\n");
	bool directory_type = file->st.st_mode == TYPE_DIR;
	for(int i=0; i<indentationLevel;i++){
		printf("  ");
	}
	printf("%s.", file->name);
	if(directory_type){
		printf(" - %s-direccion: %p - directory_info: %p. Childs: %i \n", directory_type? "directory" : "regular", &file, &file->directory_file, file->directory_file->current_childs);
	}else{
		printf(" - %s-direccion: %p\n", directory_type? "directory" : "regular", &file);
	}
	if(directory_type){
		struct directory_file* directory_file = file->directory_file; 
		for(int i=0; i<MAX_DIRECTORIES;i++){
			if(directory_file->childs[i]!=NULL){
				//printf("padre: %s llama hijo: %s con indentacion de %i\n", file->name, file->childs[i]->name, indentationLevel+1);
				list_files(directory_file->childs[i], indentationLevel+1);
			}
		}
	}
}


/**
 * Llena el array recibido con \0
 * */
static void clean_char_array(char* array, int len){
	for(int i=0;i<len;i++){
		array[i]='\0';
	}
}

/** Recibo un path y devuelvo la copia del mismo pero con el ultimo file (archivo o carpeta) recortado.
 * Ej: Recibo /fisop/prueba, devuelvo solo /fisop. 	Recibo /fisop, devuelvo vacío
 * */
static void cut_last_file_from_path(const char* path, char* new_path){
	int last_slash_found = 0;
	int i=0;
	while(path[i]!='\0'){
		if(path[i]=='/'){
			last_slash_found=i;
		}
		i++;
	}
	if(last_slash_found>0){
		strncpy(new_path, path, last_slash_found);
	}
}

/** Inverso al cut_last_file_from_path: recibo un path y devuelvo recortado el ultimo file (archivo o carpeta).
 * Ej: Recibo /fisop/prueba, devuelvo /prueba. 	Recibo /fisop, devuelvo vacío
 * */
static const char* get_last_file_from_path(const char* path){
	int last_slash_found = 0;
	int i=0;
	while(path[i]!='\0'){
		if(path[i]=='/'){
			last_slash_found=i;
		}
		i++;
	}
	return &path[last_slash_found];
}

/**
 * Busca en el directorio recibido un file (regular o directorio) que se llame como el primer directorio del path 
 * y la devuelve o NULL si no existe
 * */
static struct file* find_child(struct file *file,const char* path){
	char first_path_part[51]; //desde el principio hasta el primer / encontrado (o que termine al path)
	clean_char_array(first_path_part, 51);
	int i=1;
	first_path_part[0]='/';
	while(path[i]!='\0' && path[i]!='/'){
		first_path_part[i]=path[i];
		i++;
	}
	i=0;
	struct directory_file* directory_file = file->directory_file; 
	while(i<MAX_DIRECTORIES){
		struct file* child = directory_file->childs[i];
		if((child!=NULL) && (strcmp(first_path_part, child->name)==0))
			return child;
		i++;
	}
	//printf("EL DIRECTORIO NO EXISTE");
	return NULL;
}

/**
 * Devuelve la siguiente carpeta del path, o NULL si ya está en el ultimo nivel del path.
 * Ej: Si me llega /fisops/nuevo, me devuelta un puntero a /nuevo
 * Pero si me llega /nuevo, devuelvo NULL
 * */
static const char* get_next_path(const char* path){
	for(int i=1;i<strlen(path); i++){
		if(path[i]=='/'){
			return &path[i];
		}
	}
	return NULL;
}

/** Este metodo creo que se tendria que llamar al principio de todas las funciones
 * Recibe un path y busca en él el file correspondiente al mismo o devuelve si no existe
 * */
static struct file* find_file(struct file *directory, const char* path){
	if(path[0]=='\0'){
		printf("entre en el findfile\n");
		return directory; //Ya estoy en el ultimo nivel
	}else{
		struct file* child_file = find_child(directory, path);
		if(child_file==NULL){
			return NULL;
		}
		if(child_file->st.st_mode == TYPE_REG){ //Si lo que encontré no es un directorio sobre el cual seguir explorando, devolver eso
			return child_file;
		}
		const char* shorted_path = get_next_path(path);

		if(shorted_path==NULL){
			return child_file;
		}
		else{
			return find_file(child_file, shorted_path);
		}
	}
	return directory;
}




/**
 * Devuelve algun file libre dentro de la lista de directorios existentes o NULL si no hay
 * */
static struct file* create_file(){

	/*for(int i=1; i<ARRAY_SIZE; i++){
		if(files[i].available==true){
			return &files[i];
		}
	}
	return NULL;
	*/
	
	struct file *file = (struct file*)malloc(sizeof(struct file));
	file->available=true; //Sigue siendo necesario esto?
	for(int i=0; i<NAME_SIZE;i++){
		file->name[0]='\0';
	}
	return file;
}

/**
 * Devuelve algun directory_file libre dentro de la lista de directorios existentes o NULL si no hay
 * */
static struct directory_file* create_directory_file(){

	/*for(int i=1; i<ARRAY_SIZE; i++){
		if(directory_files[i].available==true){
			return &directory_files[i];
		}
	}
	return NULL;*/
	struct directory_file* directory_file = (struct directory_file*)malloc(sizeof(struct directory_file));
	directory_file->available=true; //Sigue siendo necesario esto?
	directory_file->current_childs = 0;
	for(int j=0;j<MAX_DIRECTORIES; j++){
		directory_file->childs[j] = NULL;
	}	
	return directory_file;
}

/**
 * Devuelve algun regular_file libre dentro de la lista de directorios existentes o NULL si no hay
 * */
static struct regular_file* create_regular_file(){

	/*for(int i=1; i<ARRAY_SIZE; i++){
		if(regular_files[i].available==true){
			return &regular_files[i];
		}
	}
	return NULL;*/
	struct regular_file* regular_file = (struct regular_file*)malloc(sizeof(struct regular_file));
	regular_file->available=true; //Sigue siendo necesario esto?
	regular_file->used_data = 0;
	return regular_file;
}



/**
 * Crea y devuelve un nuevo directorio en el directorio padre recibido o NULL si no pudo
 * */
static struct file* create_new_directory(struct file* parent_directory, const char* new_file_name){
	bool slot_available = false;
	struct file* new_file = create_file();
	struct directory_file* new_directory_file = create_directory_file();
	struct directory_file* parent_directories = parent_directory->directory_file;
	if(new_directory_file==NULL || new_file==NULL){
		return NULL;
	}
	int i=0;
	while(i<MAX_DIRECTORIES && !slot_available){
		if(parent_directories->childs[i] == NULL){
			new_file->available=false;
			new_file->st.st_mode = TYPE_DIR;
			new_file->father = parent_directory;
			parent_directory->directory_file->current_childs++;
			new_file->directory_file = new_directory_file;
			new_directory_file->available = false;
			strncpy(new_file->name, new_file_name, strlen(new_file_name));
			parent_directories->childs[i] = new_file;
			new_file->st.st_mtime = time(0);
			return new_file;
		}
		i++;
	}
	return NULL;
}

/**
 * Crea y devuelve un nuevo archivo de datos en el directorio padre recibido o NULL si no pudo
 * */
static int create_new_file(struct file* parent_directory, const char* new_file_name){
	bool slot_available = false;
	struct file* new_file = create_file();
	strncpy(new_file->name, new_file_name, strlen(new_file_name));
	struct regular_file* new_regular_file = create_regular_file();
	struct directory_file* parent_directories = parent_directory->directory_file;
	if(new_regular_file==NULL || new_file==NULL){
		return -1;
	}
	int i=0;
	while(i<MAX_DIRECTORIES && !slot_available){
		if(parent_directories->childs[i] == NULL){
			new_file->available=false;
			new_file->st.st_mode = TYPE_REG;
			new_file->father = parent_directory;
			parent_directory->directory_file->current_childs++;
			new_file->regular_file = new_regular_file;
			new_regular_file->available = false;
			parent_directories->childs[i] = new_file;
			new_file->st.st_mtime = time(0);
			return 0;
		}
		i++;
	}
	return -1;
}

static int fisops_mkdir(const char* path, mode_t mode){ //No se que hace mode y le valta validar que no cree archivos con el mismo nombre en un mismo directorio
	char new_path[256];
	clean_char_array(new_path, 256);
	cut_last_file_from_path(path, new_path);//Me creo un path pero sacandole la ultima carpeta: Si quiero crear una carpeta "dea" en prueba/hola/dea, 

	struct file* parent_directory = find_file(&root_file, new_path);
	if(parent_directory==NULL){
		printf("No se encontró el directorio");
		return -1; //Para indicar error
	}

	//printf("Directorio recortado del padre vale:%s. Que deberia ser igual al que guarda el padre:%s.\n", new_path, parent_directory->name);
	const char* new_directory = get_last_file_from_path(path);
	//printf("new_directory: %s\n", new_directory);
	create_new_directory(parent_directory, new_directory);

	printf("Muestro el arbol actual de directorios y archivos:\n");
	list_files(&root_file,0);
	printf("Fin del arbol de directorios y archivos\n");
	return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//1-Primero borro la conexion del padre al hijo
//struct directory_file* directory_father = father->directory_file;
static void remove_directory_connection_to_father(struct file* file_to_delete, struct file* father){
	struct directory_file* directory_father = father->directory_file; 
	for(int j=0; j<MAX_DIRECTORIES;j++){
		if(directory_father->childs[j]!=NULL && directory_father->childs[j] == file_to_delete){
			printf("Encontre un match asique borro la conexion del padre al file a borrar\n");
			directory_father->childs[j]=NULL;
			directory_father->current_childs--;
		}
	}
}

static void remove_file_and_anidated_files(struct file* file_to_delete, bool file_is_directory){
	/*if(file_is_directory){
		struct directory_file* directory_file = file_to_delete->directory_file; 
		for(int j=0; j<MAX_DIRECTORIES; j++){
			if(directory_file->childs[j]!=NULL){
				remove_file_and_anidated_files(directory_file->childs[j], directory_file->childs[j]->st.st_mode==__S_IFREG);
			}
			directory_file->childs[j]=NULL;
		}
		directory_file->current_childs=0;
		directory_file->available = true;
	}*/
	file_to_delete->available = true; 
	for(int i=0;i<NAME_SIZE;i++){
		file_to_delete->name[i]='\0';
	}


	if(file_to_delete->st.st_mode == TYPE_REG){ //Si lo que encontré no es un directorio sobre el cual seguir explorando, devolver eso
			free(file_to_delete->regular_file);
	}else{
		free(file_to_delete->directory_file);
	}
	free(file_to_delete);
	//Acá cuando lo pase a malloc en lugar de setearlo como available tendria que llamar al free(). 
	//Implementar una funcion que verifique que borré todo bien
}

static int fisopfs_rmdir(const char *DirName){
	printf("OK Tengo que eliminar \n");
	
	//Busco el directorio
	struct file* dir_to_delete = find_file(&root_file, DirName);
	printf("Controlo que sea el directorio que busco: %s\n",dir_to_delete->name);
	struct directory_file* Inside_dir = dir_to_delete->directory_file;
	
	if(Inside_dir->current_childs != 0 ){
		perror("Directory not empty");
		return -1;
	}

	struct file* dir_father = dir_to_delete->father;
	if(dir_father != NULL){
		remove_directory_connection_to_father(dir_to_delete, dir_father); //Remuevo la conexion de lo que estoy por borrar con el padre
		remove_file_and_anidated_files(dir_to_delete, true);
	}else {
		printf("Es NULL ver que hacer en ese caso");
	}
	

	return 0;
}

static int fisopfs_unlink(const char *DirName){
	printf("OK Tengo que eliminar \n");
	
	//Busco el directorio
	struct file* file_to_delete = find_file(&root_file, DirName);
	printf("Controlo que sea el directorio que busco: %s\n",file_to_delete->name);
	struct file* dir_father = file_to_delete->father;
	if(dir_father != NULL){
		remove_directory_connection_to_father(file_to_delete, dir_father); //Remuevo la conexion de lo que estoy por borrar con el padre
		remove_file_and_anidated_files(file_to_delete, false);
	}else {
		printf("Es NULL ver que hacer en ese caso");
	}
	

	return 0;
}

static int fisops_mknod(const char* path, mode_t mode, dev_t rdev){ //El usado en touch
	char new_path[256];
	clean_char_array(new_path, 256);
	cut_last_file_from_path(path, new_path);//Me creo un path pero sacandole la ultima carpeta: Si quiero crear una carpeta "dea" en prueba/hola/dea, 

	struct file* parent_directory = find_file(&root_file, new_path);
	if(parent_directory==NULL){
		printf("No se encontró el directorio");
		return -1; //Para indicar error
	}

	printf("Directorio recortado del padre vale:%s. Que deberia ser igual al que guarda el padre:%s.\n", new_path, parent_directory->name);
	const char* new_directory = get_last_file_from_path(path);
	printf("new_directory: %s\n", new_directory);
	create_new_file(parent_directory, new_directory);

	printf("Muestro el arbol actual de directorios y archivos:\n");
	list_files(&root_file,0);
	printf("Fin del arbol de directorios y archivos\n");
	return 0;
}


static int
fisopfs_getattr(const char *path, struct stat *st) //Ver bien que hace, se la llama muy seguido. Creo que lo que hace es hacer que el stat recibido apunte al file buscado. Crreeeeo
{
	printf("[debug] fisopfs_getattr(%s)\n", path);
	if(strcmp(path,"/fisop")==0){
		st->st_uid = 1818;
		st->st_mode = __S_IFREG | 0644;
		st->st_size = 2048;
		st->st_nlink = 1;
		return 0;
	}

	struct file* file = find_file(&root_file, path);
	if(file!=NULL){ //Era un directorio y lo encontré
		if(file->st.st_mode == TYPE_DIR){
			printf("Encontre un directorio\n");
			st->st_uid = 1717; //Numero cualquiera x ahora?
			st->st_mode = __S_IFDIR | 0755;
			st->st_nlink = 2; //Cualquier cosa x ahora? 
			return 0;
		}else{
			printf("Encontre un archivo\n");
			st->st_uid = 1818;
			st->st_mode = __S_IFREG | 0644;
			st->st_size = 2048;
			st->st_nlink = 1;
			return 0;
		}
	}
	return -ENOENT;
}

#define MAX_CONTENIDO
static char fisop_file_contenidos[MAX_CONTENIDO] = "hola fisopfs!\n";

static int
fisopfs_read(const char *path,
             char *buffer,
             size_t size,
             off_t offset,
             struct fuse_file_info *fi)
{

	printf("[debug] fisopfs_read\n  path:%s.\n buffer:%s.\nsize:%li\noffset:%lu", path, buffer, size, offset);
	struct file* file = find_file(&root_file, path);
	if(file==NULL){
		printf("No se encontró el directorio");
		return -1; //Para indicar error
	}
	file->st.st_atime = time(0);
	strncpy(buffer, file->regular_file->available_data, size); //Acá tendria que sumarle el +offset al segundo parametro (para moverme offset chars) pero si lo hago asinomas falla
	printf("El archivo dice %s\n", file->regular_file->available_data);
	return size; //Deberia devolver siempre el size? No hay chance que llegue a leer menos?
}


static int
fisopfs_write(const char *path,
             const char *buffer,
             size_t size,
             off_t offset,
             struct fuse_file_info *fi)
{
	printf("[debug] fisopfs_write\n  path:%s.\n buffer:%s.\n  Size:%lu\nOffset:%lu", path, buffer, size, offset);
	struct file* file = find_file(&root_file, path);
	if(file==NULL){
		printf("No se encontró el directorio");
		return -1; //Para indicar error
	}
	file->st.st_mtime = time(0);
	struct regular_file* regular_file = file->regular_file;
	strncpy(regular_file->available_data, buffer, size);//Acá tendria que sumarle el +offset al segundo parametro (para moverme offset chars) pero si lo hago asinomas falla
	return size; //Acá no deberia devolevr siempre size, podria darse que no haya llegado a leer todo lo que me piden si, por ejemplo, offset+size> len(texto)
}


//Estructuas de file en disco: (pendientes XD)
struct persisted_file{
	char name[NAME_SIZE];
	struct stat st;
};
struct persisted_regular_file{
	int used_data;
	char available_data[1024];
};
struct persisted_directory_file{
	int child_directories;
};

//Lo llamo con el struct root y el fopen ("data.txt", "w")
static void persist_info(struct file* file, FILE * fp){ //Deberia agregarle un struct file* father para la recursividad? Creo que eso solo para el read. O que devuelva el achivo creado, asi el padre lo asocia?
	struct persisted_file persisted_file;
	strncpy(persisted_file.name, file->name, NAME_SIZE);
	persisted_file.st = file->st;

	fwrite(&persisted_file, sizeof(struct persisted_file), 1, fp);

	if(persisted_file.st.st_mode==TYPE_REG){
		int used_data = file->regular_file->used_data;
		fwrite(&used_data, sizeof(int), 1, fp);
		fwrite(&file->regular_file->available_data, used_data, 1, fp);
	}else{
		int cant_childs = file->directory_file->current_childs;
		fwrite(&cant_childs, sizeof(int), 1, fp);
		for(int i=0;i<cant_childs;i++){
			persist_info(file->directory_file->childs[i], fp);
		}
	}
}

static void link_child_to_father(struct file* parent, struct file* child){
	int i=0;
	bool slot_available_found = false;
	struct directory_file* parent_directory = parent->directory_file;
	while(i<MAX_DIRECTORIES && !slot_available_found){
		if(parent_directory->childs[i] == NULL){
			slot_available_found = true;
			child->available=false;
			child->father = parent;
			parent_directory->current_childs++;
			parent_directory->childs[i] = child;
			child->st.st_mtime = time(0);
		}
		i++;
	}

}

static void indentar(int index){
	for(int i=0; i<index;i++){
		printf("   ");
	}
}

static void read_persisted_info(struct file* file, FILE* fp, int index){ //el "file" que recibe es el "nuevo" archivo
	struct persisted_file persisted_file;
	fread(&persisted_file, sizeof(struct persisted_file), 1, fp);
	
	strncpy(file->name, persisted_file.name, NAME_SIZE);
	file->st = persisted_file.st;

	indentar(index);
	printf("Lei el nombre:%s. de persisted file\n", file->name);
	
	if(persisted_file.st.st_mode==TYPE_REG){
		struct regular_file* regular_file = create_regular_file();
		file->regular_file = regular_file;
		int used_data;
		fread(&used_data, sizeof(int),1,fp);
		fread(file->regular_file->available_data, used_data,1,fp);
	}else{
		struct directory_file* directory_file = create_directory_file();
		file->directory_file = directory_file;
		int cant_childs;
		fread(&cant_childs, sizeof(int), 1, fp);
		indentar(index);
		printf("el file: %s tiene %i hijos\n",file->name, cant_childs);
		for(int i=0;i<cant_childs;i++){
			indentar(index);
			printf("Creo uno de los hijos\n");
			struct file* new_file = create_file();
			indentar(index);
			printf("Lo linkeo\n");
			link_child_to_father(file, new_file);
			indentar(index);
			printf("Llamo al padre\n");
			read_persisted_info(new_file, fp, index+1);
		}
	}

}


static void init_mount_point(){
	//Inicializo mi root, que va a ser el primer memory_file de mi array
	root_file.available = false;
	root_file.st.st_mode = TYPE_DIR;
	root_file.name[0] = '/';
	root_file.name[1] = '\0';

	root_file.directory_file = &root_directory_file;
	root_directory_file.available = false;
}

int
main(int argc, char *argv[])
{
	init_mount_point();
	bool running = true;
	while(running){
		printf("escribe un comando, o 0 para salir, 1 para listar directorios\n");
		char str[100];
		fgets(str, sizeof str, stdin);
		if(str[0]=='0'){
			running = false;
		}
		else if(str[0]=='1'){
			list_files(&root_file,0);
		}else{
			if(str[0]=='m' && str[1]=='k' && str[2]=='d' && str[3]=='i' && str[4]=='r' && str[5]==' ' && str[6]=='/'){
				str[strlen(str)-1]='\0';
				printf("llamo a mkdir con:%s. Mide %i \n", &str[6], strlen(str));
				fisops_mkdir(&str[6], NULL);
			}else if(str[0]=='t' && str[1]=='o' && str[2]=='u' && str[3]=='c' && str[4]=='h' && str[5]==' ' && str[6]=='/'){
				str[strlen(str)-1]='\0';
				printf("llamo a mknod con:%s\n", &str[6]);
				fisops_mknod(&str[6], NULL, NULL);
			}else if(str[0]=='r' && str[1]=='m' && str[2]=='d' && str[3]=='i' && str[4]=='r' && str[5]==' ' && str[6]=='/'){
				str[strlen(str)-1]='\0';
				printf("llamo a rmdir con:%s\n", &str[6]);
				fisopfs_rmdir(&str[6]);
			}else if(str[0]=='r' && str[1]=='m' && str[2]==' ' && str[3]=='/'){
				str[strlen(str)-1]='\0';
				printf("llamo a unlink con:%s\n", &str[3]);
				fisopfs_unlink(&str[3]);
			}else if(str[0]=='m' && str[1]=='o' && str[2]=='u' && str[3]=='n' && str[4]=='t'){
				printf("mount\n");
 				FILE* fp = fopen ("data.fisopfs", "r");
 				if(fp){
 					read_persisted_info(&root_file,fp,0);
 					fclose(fp);
 				}
			}else if(str[0]=='u' && str[1]=='n' && str[2]=='m' && str[3]=='o' && str[4]=='u' && str[5]=='n' && str[6]=='t'){
				printf("unmount\n");
				FILE* fp = fopen ("data.fisopfs", "w");
				persist_info(&root_file, fp);
				fclose(fp);
			} else{
				printf("COMANDO DESCONOCIDO\n");
			}
		}
	}
	return 0;
}
