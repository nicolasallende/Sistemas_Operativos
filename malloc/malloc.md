# TP: malloc
--------------------------------------------------------------------------------------------PARTE 1----------------------------------------------------------------------------------------------------------
Para la primera parte se implementó un malloc basico, con un unico bloque de memoria y el header de cada chunk inalterado del recibido en el ejemplo, compuesto por un booleano que indica si a region está libre, su tamaño, y un puntero al siguiente chunk libre (en caso de que sea un bloque libre).

La logica del malloc consistió en inicialmente intentar buscar un chunk libre dentro de una lista de chunks libres. En caso de no encontrar, si no encontraron ninguno y pasaron por chunks libres, se asume que no queda espacio para satisfacer a solicitud del usuario y se devuelve nulo, en caso contrario, si no se pasó por chunks libres  se debía a ser la primera vez que se entraba en malloc, por lo que se solicitaba memoria con mmap por primera vez.
Spliteo de chunks:
	Aún en el malloc, y ya obtenido el nuevo chunk a devolver, se lo setea como ocupado y se obtiene el chunk libre que apuntaba a este como su next, y se hace que apunte al que apunta el next de que voy a devolver, removiendo este de la lista de chunks libres. Alternativamente, en caso de estar devolviendo un chunk que supere demasiado el tamaño solicitado por el usuario, se lo splitea en dos chunks, uno para devolverle al usuario y otro con el resto, y se agrega un nuevo header en este resto para que apunte al que apunta el que voy a devolver, y se hace que el anterior apunte a este nuevo, removiendolo también asi de la lista de chunks libres.


Free:
	Durante la implementacion del free, es necesario iterar la lista de chunks libres para encontrar el lugar correcto de la lista donde colocar este, recientemente liberado, chunk. Y una vez realizado esto, es necesario implementar la coalesion de chunks: En caso de que la direccion del proximo chunk sea igual a la del chunk que estoy por librerar sumado su propio tamaño, entonces puedo asegurar que son contiguos, el chunk que estoy liberando pasa a apuntar al que apuntaba su siguiente, y si tamaño aumenta en relacion al tamaño que tenia el de adelante.

--------------------------------------------------------------------------------------------PARTE 2----------------------------------------------------------------------------------------------------------
En la segunda parte, tuvimos que modificar varias partes realizadas en la parte anterior ya que todo estaba pensado para 1 solo bloque de memoria, originalmente tratamos de hacer una lisita de bloques de memoria que a su vez contenga la lista de memoria propiamente pero por complicaciones terminamos optando por implementar un arreglo que contenga las distintas listas de memoria.

Generamos nuevas constantes para los distintos tamanos que pueden tomar los bloques y un tamano maximo para el arreglo (fue tomado 10 de forma arbitraria).

Al struc region se le agrego una variable block que contiene a que posicion del arreglo pertenece.

Ademas se realizo en esta parte la funcion unmap_free_block que elimina la memoria seteada cuando ya no se laa necesita mas.

Para poder saber si se quiere liberar totalmente esa memoria se creo el struct  mapped_block que lo usamos para saber si esta sin elementos el bloque( con chunks_in_use) y ademas contiene la informacion necesaria para poder realizar el unmap. 

Tuvimos especial problema a la hora de adaptar el best fit para varios bloques, ya que tardamos en darnos cuenta que solo estaba asignando memoria del primer bloque y cada vez que se le pedia mas memoria de la que tenia el primero, en vez de utilizar la memoria disponible que podria tener el segundo bloque, creaba uno nuevo.

--------------------------------------------------------------------------------------------PARTE 3----------------------------------------------------------------------------------------------------------
La implementacion de best_fit como tecnica de búsqueda de regiones resultó incluso mas sencilla que la de first_fit, dado que obligatoriamente se debían recorrer todos los espacios de memoria libres disponibles, las condiciones de corte de los loops fueron mas sencillas para determinar cuando habia que dejar de recorrer la memoria.
En cuanto a la lógica en sí del metodo, consiste en recorrer todos los espacios de memoria libre en cada bloque existente y devolver el bloque de menor tamaño que sea lo suficientemente grande para satisfacer la solicitud del usuario. Esto significa que el bloque solicitado debía superar en tamaño la suma de lo solicitado por el usuario sumado al tamaño necesario para el header.


--------------------------------------------------------------------------------------------PARTE 4----------------------------------------------------------------------------------------------------------
Hicimos el calloc y realloc casi juntos y seteamos errno para cuando fallen malloc, calloc y realloc.

Se modifico la funcion should_split y se la transformo en split, que se la utiliza tanto en el malloc como en el realloc.

Creamos una constante nueva que indica el maximo de memoria que estamos dispuestos a asignar(MAX_MEMORY_ALLOWED), asique nuestra implementacion tiene dos limitaciones, 1 el tamano del arreglo y 2 el maximo de memoria.
