#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	envid_t who;

	if ((who = fork()) != 0) {
		// get the ball rolling

		//cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
		cprintf("The Father priority is %d \n", sys_get_env_priority(sys_getenvid()));
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
		//cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
		cprintf("The Son priority is %d \n", sys_get_env_priority(sys_getenvid()));
		if (i == 10)
			return;
		i++;
		ipc_send(who, i, 0, 0);
		if (i == 10)
			return;
	}

}