#define FUSE_USE_VERSION 30

#include <fuse.h>
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

#define DEFAULT_PERSISTED_FILENAME_DATA "data.fisopfs"
char * persisted_filename_data;

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
	char data[4096];
};

struct directory_file{
	bool available;
	int current_childs;
	struct file* childs[MAX_DIRECTORIES];
};

struct file root_file;
struct directory_file root_directory_file;

static void list_files(struct file* file, int indentationLevel){
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

static void free_file(struct file* file_to_delete){
	if(file_to_delete->st.st_mode == TYPE_REG){
		free(file_to_delete->regular_file);
	}else{
		printf("Libero memoria del directory\n");
		free(file_to_delete->directory_file);
	}
	free(file_to_delete);
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

	printf("CREATE FILE \n");
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
	printf("CREATE DIRECTORY FILE \n");
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
static struct file* create_new_file(struct file* parent_directory, const char* new_file_name){
	bool slot_available = false;
	struct file* new_file = create_file();
	struct regular_file* new_regular_file = create_regular_file();
	struct directory_file* parent_directories = parent_directory->directory_file;
	if(new_regular_file==NULL || new_file==NULL){
		return NULL;
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
			strncpy(new_file->name, new_file_name, strlen(new_file_name));
			parent_directories->childs[i] = new_file;
			new_file->st.st_mtime = time(0);
			return new_file;
		}
		i++;
	}
	printf("ERROR NO HAY ESPACIO PARA OTRO ARCHIVO");
	return NULL;
}

static int fisops_mkdir(const char* path, mode_t mode){ //No se que hace mode y le valta validar que no cree archivos con el mismo nombre en un mismo directorio
	printf("recibi %s\n",path);
	char new_path[256];
	clean_char_array(new_path, 256);
	cut_last_file_from_path(path, new_path);//Me creo un path pero sacandole la ultima carpeta: Si quiero crear una carpeta "dea" en prueba/hola/dea, 

	struct file* parent_directory = find_file(&root_file, new_path);
	if(parent_directory==NULL){
		printf("No se encontró el directorio\n");
		return -ENOENT; //Para indicar error
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

static int fisopfs_truncate(const char *path , off_t offset, struct fuse_file_info *fi){

	struct file* file = find_file(&root_file, path);
	if(file==NULL){
		printf("No se encontró el archivo");
		return -ENOENT; //Para indicar error
	}
	
	struct regular_file* regular_file = file->regular_file;
	regular_file->used_data = offset;
	file->st.st_mtime = time(NULL);
	return 0;
}


static int fisopfs_utimens(const char* path,  struct timespec tv[2], struct fuse_file_info *fi){

	printf("utimens se le paso el path:%s\n", path);
	
	//Esto de aca nos da fecha actual, hay que ver como modificar los stats de los archivos 
	printf("antes de tratar de transformarlo\n");
	printf("Raw timespec.time_t: %jd\n", (intmax_t)tv->tv_sec);
    printf("Raw timespec.tv_nsec: %09ld\n", tv->tv_nsec);
    /*
    timespec_get(tv, TIME_UTC);
    printf("Despues de transformarlo\n");
    // char buff[100];
    //strftime(buff, sizeof buff, "%D %T", gmtime(&tv->tv_sec));
    //printf("Current time: %s.%09ld UTC\n", buff, tv->tv_nsec);
    printf("Raw timespec.time_t: %jd\n", (intmax_t)tv->tv_sec);
    printf("Raw timespec.tv_nsec: %09ld\n", tv->tv_nsec);
	*/

	//fue un intento a modificar lo que sale por stat
	struct file* file_to_change_date = find_file(&root_file, path);
	//-----------------------------no entiendo por que no modifica el tiempo cuando lo pedimos con stat--------------------------------

	file_to_change_date->st.st_atime = time(NULL);//timespec_get(tv, TIME_UTC);
	file_to_change_date->st.st_mtime = time(NULL);//timespec_get(tv, TIME_UTC);;
	printf("hice lo del tiempo\n");


	
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
	free_file(file_to_delete);
}

static int fisopfs_rmdir(const char *DirName){
	printf("OK Tengo que eliminar \n");
	
	//Busco el directorio
	struct file* dir_to_delete = find_file(&root_file, DirName);
	printf("Controlo que sea el directorio que busco: %s\n",dir_to_delete->name);
	struct directory_file* Inside_dir = dir_to_delete->directory_file;
	
	if(Inside_dir->current_childs != 0 ){
		perror("Directory not empty");
		return -ENOTEMPTY;
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
		return -ENOENT; //Para indicar error
	}

	printf("Directorio recortado del padre vale:%s. Que deberia ser igual al que guarda el padre:%s.\n", new_path, parent_directory->name);
	const char* new_directory = get_last_file_from_path(path);
	printf("new_directory: %s\n", new_directory);
	if(create_new_file(parent_directory, new_directory) == NULL){
		perror("Supero la cantidad de archivos permitidos");
		return -ENFILE;
	}

	printf("Muestro el arbol actual de directorios y archivos:\n");
	list_files(&root_file,0);
	printf("Fin del arbol de directorios y archivos\n");
	return 0;
}


static int
fisopfs_getattr(const char *path, struct stat *st) //Ver bien que hace, se la llama muy seguido. Creo que lo que hace es hacer que el stat recibido apunte al file buscado. Crreeeeo
{
	printf("[debug] fisopfs_getattr(%s)\n", path);
	struct file* file;
	if(path[0]=='/' && path[1]=='\0'){
		file = &root_file;
	}else{
		file = find_file(&root_file, path);
	}
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
			st->st_size = file->regular_file->used_data;
			st->st_nlink = 1;
			return 0;
		}
	}else{
		printf("no encontre nada\n");
	}
	return -ENOENT;
}

static int
fisopfs_readdir(const char *path,
                void *buffer,
                fuse_fill_dir_t filler,
                off_t offset,
                struct fuse_file_info *fi)
{
	printf("[debug] fisopfs_readdir(%s)\n", path);

	// Los directorios '.' y '..'
	filler(buffer, ".", NULL, 0);
	filler(buffer, "..", NULL, 0);

	// Si nos preguntan por el directorio raiz, solo tenemos un archivo
	if (strcmp(path, "/fisop") == 0) {
		filler(buffer, "fisop", NULL, 0);
		return 0;
	}

	printf("[debug] fisopfs_readdir\n  path:%s.\n buffer:%p.\n", path, buffer);
	struct file* file;
	if(path[0]=='/' && path[1]=='\0'){
		file = &root_file;
	}else{
		file = find_file(&root_file, path);
	}
	if(file==NULL){
		printf("No se encontró el directorio");
		return -ENOENT; //Para indicar error 
	}
	file->st.st_atime = time(NULL);

	//aca trato de cargar la lista de archivos contenida en el directorio
	struct directory_file *LstOfFile = file->directory_file;
	for(int i=0;i<MAX_DIRECTORIES;i++){
	if(LstOfFile->childs[i] != NULL){
		if(filler(buffer, LstOfFile->childs[i]->name+1, NULL, 0) != 0){
			return -ENOMEM;
			}
		}
	}
	return 0;
}

static int
fisopfs_read(const char *path,
             char *buffer,
             size_t size,
             off_t offset,
             struct fuse_file_info *fi)
{

	printf("[debug] fisopfs_read\n  path:%s.\n buffer:%s.\nsize:%li\noffset:%lu\n", path, buffer, size, offset);
	struct file* file = find_file(&root_file, path);
	if(file==NULL){
		printf("No se encontró el directorio");
		return -ENOENT; //Para indicar error
	}
	file->st.st_atime = time(NULL);
	strncpy(buffer, file->regular_file->data+offset, size); //Acá tendria que sumarle el +offset al segundo parametro (para moverme offset chars) pero si lo hago asinomas falla
	printf("El archivo+offset dice %s\n", file->regular_file->data+offset);
	printf("El archivo dice %s\n", file->regular_file->data);
	printf("El buffer ahora dice: %s\n", buffer);
	printf("El archivo tiene %i bytes usados\n", file->regular_file->used_data);
	return size; //Deberia devolver siempre el size? No hay chance que llegue a leer menos?
}


static int
fisopfs_write(const char *path,
             const char *buffer,
             size_t size,
             off_t offset,
             struct fuse_file_info *fi)
{
	printf("[debug] fisopfs_write\n  path:%s.\n buffer:%s.\n  Size:%lu\nOffset:%lu\n", path, buffer, size, offset);
	struct file* file = find_file(&root_file, path);
	if(file==NULL){
		printf("No se encontró el directorio");
		return -ENOENT; //Para indicar error
	}
	file->st.st_mtime = time(NULL);
	struct regular_file* regular_file = file->regular_file;
	if((regular_file->used_data + size) > 4096){
		return -ENOMEM;
	}
	regular_file->used_data+=size;
	strncpy(regular_file->data+offset, buffer, size);//Acá tendria que sumarle el +offset al segundo parametro (para moverme offset chars) pero si lo hago asinomas falla
	return size; //Acá no deberia devolevr siempre size, podria darse que no haya llegado a leer todo lo que me piden si, por ejemplo, offset+size> len(texto)
}

//Estructura de file en disco
struct persisted_file{
	char name[NAME_SIZE];
	struct stat st;
};


static void persist_info(struct file* file, FILE * fp){
	struct persisted_file persisted_file;
	strncpy(persisted_file.name, file->name, NAME_SIZE);
	persisted_file.st = file->st;

	fwrite(&persisted_file, sizeof(struct persisted_file), 1, fp);

	if(persisted_file.st.st_mode==TYPE_REG){
		int used_data = file->regular_file->used_data;
		fwrite(&used_data, sizeof(int), 1, fp);
		fwrite(&file->regular_file->data, used_data, 1, fp);
	}else{
		int cant_childs = file->directory_file->current_childs;
		fwrite(&cant_childs, sizeof(int), 1, fp);
		for(int i=0;i<cant_childs;i++){
			persist_info(file->directory_file->childs[i], fp);
			free_file(file->directory_file->childs[i]);
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
		file->regular_file = create_regular_file();
		fread(&file->regular_file->used_data, sizeof(int),1,fp);
		fread(file->regular_file->data, file->regular_file->used_data,1,fp);
	}else{
		if(file->directory_file==NULL){ //Validacion necesaria xq si estoy en el file root, ya tengo un directory file y x lo tanto no tengo que crearme otro con malloc
			file->directory_file = create_directory_file();
		}
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


static void fisopfs_destroy(){
	FILE* fp = fopen (persisted_filename_data, "w");
	persist_info(&root_file, fp);
	fclose(fp);
}


static struct fuse_operations operations = {
	.getattr = fisopfs_getattr,
	.readdir = fisopfs_readdir,
	.read = fisopfs_read,
	.write = fisopfs_write,
	.mkdir = fisops_mkdir,
	.mknod = fisops_mknod,
	.rmdir = fisopfs_rmdir,
	.unlink = fisopfs_unlink,
	.utimens = fisopfs_utimens,
	.destroy = fisopfs_destroy,
	.truncate = fisopfs_truncate,
};

static void init_mount_point(int argc, char *argv[]){
	//Inicializo mi root, que va a ser el primer memory_file de mi array
	root_file.available = false;
	root_file.st.st_mode = TYPE_DIR;
	root_file.name[0] = '/';
	root_file.name[1] = '\0';

	root_file.directory_file = &root_directory_file;
	root_directory_file.available = false;

	//Get filename of persisted_data:
	if(argc==3){
		persisted_filename_data = &DEFAULT_PERSISTED_FILENAME_DATA;
	}else{
		persisted_filename_data = argv[3];
	}
	printf("persisted_filename_data es %s\n",persisted_filename_data);

	//mount persisted data
	FILE* fp = fopen (persisted_filename_data, "r");
	if(fp){
 		read_persisted_info(&root_file,fp,0);
		fclose(fp);
	}
}

int
main(int argc, char *argv[])
{
	init_mount_point(argc, argv);
	return fuse_main(argc, argv, &operations, NULL);
}

