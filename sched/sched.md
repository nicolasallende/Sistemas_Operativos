# sched.md

Lugar para respuestas en prosa, seguimientos con GDB y documentacion del TP

# Parte 3
Para correr las pruebas utilizando el Round Robin se debe aclarar ROUND_ROBIN=true 
ej: make grade ROUND_ROBIN=true. 

Para correr codigo viendo los stats Usar STATS=true 
ej: make run-hello-nox STATS=true.

Para la parte 3 se decidió realizar una version simplificada de la Multi Level Feedback Queue. La misma consistirá de 8 niveles. siendo 8 la cola de mayor prioridad y 1 la de menor.

Dicha implementacion de colas se verá impactada en la estructura de los enviroments, agregando un nuevo parametro env_priority, que indicará la cola en la que se encontrará cada enviroment en ese momento.

El seteo de la prioridad se realiza en el metodo env_alloc al momento de ser inicializado cada enviroment.

La logica de la iteracion dentro del metodo sched-yield será similar a la del round robbin, con un iterador que al momento de encontrar un proceso con la maxima prioridad lo correrá inmediatamente, pero mientras lo busca tambien guardará el primer enviroment encontrado de cada una de las demás prioridades, así en caso de no encontrar uno de la maxima prioridad, ya tendrá un listado con el primer enviroment encontrado de las demas prioridades para correr, y de este listado eligira el mas prioritario.

La politica de bajado de prioridad se simplificó a la MLFQ original, una vez que un enviroment en ejecución detuvo su ejecucion, baja su prioridad en 1 sin importar si el motivo de detencion del mismo fue una finalizacion de su time-slice o una operacion de I/O.

Optamos por esta simplificacion por la simplesa y restricciones de tiempo del grupo.Por el mismo motivo decidimos tambien dejarle asignada la misma prioridad del proceso padre al proceso hijo.

Se agregaron 2 syscalls en syscall.c,SYS_get_env_priority y sys_set_env_priority, destinadas al manejo de la prioridad.

En sched para mayor claridad del codigo se creo las funciones run_round_robin, run_MLFQ. Tambien se creo una funcion my_stats que muestra el total de: enviroments creados,  llamadas al scheduler y la cantidad de llamados a enviroments en cada queue. 

