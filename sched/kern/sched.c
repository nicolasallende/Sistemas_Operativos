#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

void sched_halt(void);

extern uint32_t total_envs_created;
extern uint32_t total_scheduler_calls;
extern uint32_t calls_to_envs_of_each_priority[8];

// Implement simple round-robin scheduling.
//
// Search through 'envs' for an ENV_RUNNABLE environment in
// circular fashion starting just after the env this CPU was
// last running.  Switch to the first such environment found.
//
// If no envs are runnable, but the environment previously
// running on this CPU is still ENV_RUNNING, it's okay to
// choose that environment.
//
// Never choose an environment that's currently running on
// another CPU (env_status == ENV_RUNNING). If there are
// no runnable environments, simply drop through to the code
// below to halt the cpu.
static void
run_round_robbin()
{
	struct Env *idle;
	int32_t env_num = 0;
	if(curenv!=NULL){
		env_num = ENVX(curenv->env_id);
		}
	
	//Empiezo desde el siguiente al que corrí, hasta el ultimo de la lista
	for(int i=0; i<NENV; i++){
		idle = envs + ((env_num + i ) % NENV);
		if (idle->env_status == ENV_RUNNABLE){
			env_run(idle);
		}
	}
	

	//Si llego hasta aca, si el curenv es distinto de NULL entonces solo existe 1 proceso en el cpu actual y es el que estaba corriendo.
	//Chequeo que no se terminara todavia y lo corro 
	if(curenv != NULL && curenv->env_status == ENV_RUNNING){
		env_run(curenv);
	}
}


static void
run_MLFQ(){
	total_scheduler_calls++;
	struct Env *idle;
	int32_t env_num = 0;
	if(curenv!=NULL){
		env_num = ENVX(curenv->env_id);
	}
	
	struct Env *runnable_envs[7]; //In runnable_envs[N-1], first found enviroment with priority N. 
	for(int i=0;i<7;i++){
		runnable_envs[i] = NULL;
	}
	//Empiezo desde el siguiente al que corrí, hasta el ultimo de la lista
	for(int i=0; i<NENV; i++){
		idle = envs + ((env_num + i ) % NENV);
		if (idle->env_status == ENV_RUNNABLE){
			if(idle->env_priority == AMOUNT_QUEUES){ 	//If max priority Env found, run inmediatly, else, save to see wich one has higher priority later
				calls_to_envs_of_each_priority[AMOUNT_QUEUES-1]++;
				env_run(idle);
			}
			if(runnable_envs[idle->env_priority-1] == NULL) //Only save if it's the FIRST enviroment found with said priority
				runnable_envs[idle->env_priority-1] = idle;
		}
	}

	for(int i=6; i>=0; i--){
		if(runnable_envs[i] != NULL){
			calls_to_envs_of_each_priority[(runnable_envs[i]->env_priority)-1]++;
			env_run(runnable_envs[i]);
		}
	}
	

	//Si llego hasta aca, si el curenv es distinto de NULL entonces solo existe 1 proceso en el cpu actual y es el que estaba corriendo.
	//Chequeo que no se terminara todavia y lo corro 
	if(curenv != NULL && curenv->env_status == ENV_RUNNING){
		calls_to_envs_of_each_priority[curenv->env_priority-1]++;
		env_run(curenv);
	}
}

// Choose a user environment to run and run it.
void
sched_yield(void)
{
// To run with round robin: make grade ROUND_ROBIN=true
#ifdef ROUND_ROBIN
	run_round_robbin();
 #else
	run_MLFQ();
#endif
	// sched_halt never returns
	sched_halt();
}


// Once the scheduler has finishied it's work, print statistics on performance.
void 
my_stats(void)
{
	cprintf("----------------------Stats---------------------------------------\n");
	cprintf("Enviroments created: %d \n", total_envs_created);
	cprintf("Scheduler calls: %d \n", total_scheduler_calls);
	for(int i=7; i>=0; i--){
		cprintf("----------------------------| queue|n calls|\n");
		cprintf("Enviroments called in queue:| %d    | %d     |\n", i+1, calls_to_envs_of_each_priority[i]);
	}
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
#ifdef STATS
		my_stats();
#endif
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile("movl $0, %%ebp\n"
	             "movl %0, %%esp\n"
	             "pushl $0\n"
	             "pushl $0\n"
	             "sti\n"
	             "1:\n"
	             "hlt\n"
	             "jmp 1b\n"
	             :
	             : "a"(thiscpu->cpu_ts.ts_esp0));
}
