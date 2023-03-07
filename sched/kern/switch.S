/*
 * Your code here for context_switch
 *
 * It should restores the register values in the Trapframe with the 'iret' instruction.
 * This exits the kernel and starts executing some environment's code.
 *
 * This function does not return.
 */

.globl context_switch;
context_switch:
    movl 4(%esp),%esp   #avanza una posicion el stack pointer
    popal               #carga todos los PushReg
    popl %es            #carga es
    popl %ds            #carga ds
    addl $0x8,%esp      #saltamos el trapno y err
    iret
spin:
	jmp spin
