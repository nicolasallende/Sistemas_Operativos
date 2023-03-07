
obj/user/faultnostack:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 ab 02 80 00       	push   $0x8002ab
  80003e:	6a 00                	push   $0x0
  800040:	e8 fc 01 00 00       	call   800241 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80005f:	e8 02 01 00 00       	call   800166 <sys_getenvid>
	if (id >= 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	78 12                	js     80007a <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	c1 e0 07             	shl    $0x7,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	7e 07                	jle    800085 <libmain+0x31>
		binaryname = argv[0];
  80007e:	8b 06                	mov    (%esi),%eax
  800080:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	56                   	push   %esi
  800089:	53                   	push   %ebx
  80008a:	e8 a4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008f:	e8 0a 00 00 00       	call   80009e <exit>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a4:	6a 00                	push   $0x0
  8000a6:	e8 99 00 00 00       	call   800144 <sys_env_destroy>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
  8000b6:	83 ec 1c             	sub    $0x1c,%esp
  8000b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000bf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000ca:	8b 75 14             	mov    0x14(%ebp),%esi
  8000cd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000d3:	74 04                	je     8000d9 <syscall+0x29>
  8000d5:	85 c0                	test   %eax,%eax
  8000d7:	7f 08                	jg     8000e1 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    
  8000e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e4:	83 ec 0c             	sub    $0xc,%esp
  8000e7:	50                   	push   %eax
  8000e8:	52                   	push   %edx
  8000e9:	68 ea 0e 80 00       	push   $0x800eea
  8000ee:	6a 23                	push   $0x23
  8000f0:	68 07 0f 80 00       	push   $0x800f07
  8000f5:	e8 d6 01 00 00       	call   8002d0 <_panic>

008000fa <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800100:	6a 00                	push   $0x0
  800102:	6a 00                	push   $0x0
  800104:	6a 00                	push   $0x0
  800106:	ff 75 0c             	pushl  0xc(%ebp)
  800109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010c:	ba 00 00 00 00       	mov    $0x0,%edx
  800111:	b8 00 00 00 00       	mov    $0x0,%eax
  800116:	e8 95 ff ff ff       	call   8000b0 <syscall>
}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <sys_cgetc>:

int
sys_cgetc(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800126:	6a 00                	push   $0x0
  800128:	6a 00                	push   $0x0
  80012a:	6a 00                	push   $0x0
  80012c:	6a 00                	push   $0x0
  80012e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800133:	ba 00 00 00 00       	mov    $0x0,%edx
  800138:	b8 01 00 00 00       	mov    $0x1,%eax
  80013d:	e8 6e ff ff ff       	call   8000b0 <syscall>
}
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014a:	6a 00                	push   $0x0
  80014c:	6a 00                	push   $0x0
  80014e:	6a 00                	push   $0x0
  800150:	6a 00                	push   $0x0
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	ba 01 00 00 00       	mov    $0x1,%edx
  80015a:	b8 03 00 00 00       	mov    $0x3,%eax
  80015f:	e8 4c ff ff ff       	call   8000b0 <syscall>
}
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80016c:	6a 00                	push   $0x0
  80016e:	6a 00                	push   $0x0
  800170:	6a 00                	push   $0x0
  800172:	6a 00                	push   $0x0
  800174:	b9 00 00 00 00       	mov    $0x0,%ecx
  800179:	ba 00 00 00 00       	mov    $0x0,%edx
  80017e:	b8 02 00 00 00       	mov    $0x2,%eax
  800183:	e8 28 ff ff ff       	call   8000b0 <syscall>
}
  800188:	c9                   	leave  
  800189:	c3                   	ret    

0080018a <sys_yield>:

void
sys_yield(void)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800190:	6a 00                	push   $0x0
  800192:	6a 00                	push   $0x0
  800194:	6a 00                	push   $0x0
  800196:	6a 00                	push   $0x0
  800198:	b9 00 00 00 00       	mov    $0x0,%ecx
  80019d:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001a7:	e8 04 ff ff ff       	call   8000b0 <syscall>
}
  8001ac:	83 c4 10             	add    $0x10,%esp
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001b7:	6a 00                	push   $0x0
  8001b9:	6a 00                	push   $0x0
  8001bb:	ff 75 10             	pushl  0x10(%ebp)
  8001be:	ff 75 0c             	pushl  0xc(%ebp)
  8001c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c4:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c9:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ce:	e8 dd fe ff ff       	call   8000b0 <syscall>
}
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	ff 75 14             	pushl  0x14(%ebp)
  8001e1:	ff 75 10             	pushl  0x10(%ebp)
  8001e4:	ff 75 0c             	pushl  0xc(%ebp)
  8001e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ea:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f4:	e8 b7 fe ff ff       	call   8000b0 <syscall>
}
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800201:	6a 00                	push   $0x0
  800203:	6a 00                	push   $0x0
  800205:	6a 00                	push   $0x0
  800207:	ff 75 0c             	pushl  0xc(%ebp)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	ba 01 00 00 00       	mov    $0x1,%edx
  800212:	b8 06 00 00 00       	mov    $0x6,%eax
  800217:	e8 94 fe ff ff       	call   8000b0 <syscall>
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800224:	6a 00                	push   $0x0
  800226:	6a 00                	push   $0x0
  800228:	6a 00                	push   $0x0
  80022a:	ff 75 0c             	pushl  0xc(%ebp)
  80022d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800230:	ba 01 00 00 00       	mov    $0x1,%edx
  800235:	b8 08 00 00 00       	mov    $0x8,%eax
  80023a:	e8 71 fe ff ff       	call   8000b0 <syscall>
}
  80023f:	c9                   	leave  
  800240:	c3                   	ret    

00800241 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800247:	6a 00                	push   $0x0
  800249:	6a 00                	push   $0x0
  80024b:	6a 00                	push   $0x0
  80024d:	ff 75 0c             	pushl  0xc(%ebp)
  800250:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800253:	ba 01 00 00 00       	mov    $0x1,%edx
  800258:	b8 09 00 00 00       	mov    $0x9,%eax
  80025d:	e8 4e fe ff ff       	call   8000b0 <syscall>
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80026a:	6a 00                	push   $0x0
  80026c:	ff 75 14             	pushl  0x14(%ebp)
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	ff 75 0c             	pushl  0xc(%ebp)
  800275:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800278:	ba 00 00 00 00       	mov    $0x0,%edx
  80027d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800282:	e8 29 fe ff ff       	call   8000b0 <syscall>
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80028f:	6a 00                	push   $0x0
  800291:	6a 00                	push   $0x0
  800293:	6a 00                	push   $0x0
  800295:	6a 00                	push   $0x0
  800297:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029a:	ba 01 00 00 00       	mov    $0x1,%edx
  80029f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002a4:	e8 07 fe ff ff       	call   8000b0 <syscall>
}
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8002ab:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8002ac:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8002b1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8002b3:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  8002b6:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  8002ba:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  8002be:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  8002c1:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  8002c3:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  8002c7:	58                   	pop    %eax
	popl %eax
  8002c8:	58                   	pop    %eax
	popal
  8002c9:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  8002ca:	83 c4 04             	add    $0x4,%esp
	popfl
  8002cd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  8002ce:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  8002cf:	c3                   	ret    

008002d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002de:	e8 83 fe ff ff       	call   800166 <sys_getenvid>
  8002e3:	83 ec 0c             	sub    $0xc,%esp
  8002e6:	ff 75 0c             	pushl  0xc(%ebp)
  8002e9:	ff 75 08             	pushl  0x8(%ebp)
  8002ec:	56                   	push   %esi
  8002ed:	50                   	push   %eax
  8002ee:	68 18 0f 80 00       	push   $0x800f18
  8002f3:	e8 b3 00 00 00       	call   8003ab <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f8:	83 c4 18             	add    $0x18,%esp
  8002fb:	53                   	push   %ebx
  8002fc:	ff 75 10             	pushl  0x10(%ebp)
  8002ff:	e8 56 00 00 00       	call   80035a <vcprintf>
	cprintf("\n");
  800304:	c7 04 24 3c 0f 80 00 	movl   $0x800f3c,(%esp)
  80030b:	e8 9b 00 00 00       	call   8003ab <cprintf>
  800310:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800313:	cc                   	int3   
  800314:	eb fd                	jmp    800313 <_panic+0x43>

00800316 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	53                   	push   %ebx
  80031a:	83 ec 04             	sub    $0x4,%esp
  80031d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800320:	8b 13                	mov    (%ebx),%edx
  800322:	8d 42 01             	lea    0x1(%edx),%eax
  800325:	89 03                	mov    %eax,(%ebx)
  800327:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800333:	74 09                	je     80033e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800335:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800339:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80033e:	83 ec 08             	sub    $0x8,%esp
  800341:	68 ff 00 00 00       	push   $0xff
  800346:	8d 43 08             	lea    0x8(%ebx),%eax
  800349:	50                   	push   %eax
  80034a:	e8 ab fd ff ff       	call   8000fa <sys_cputs>
		b->idx = 0;
  80034f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800355:	83 c4 10             	add    $0x10,%esp
  800358:	eb db                	jmp    800335 <putch+0x1f>

0080035a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800363:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80036a:	00 00 00 
	b.cnt = 0;
  80036d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800374:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800383:	50                   	push   %eax
  800384:	68 16 03 80 00       	push   $0x800316
  800389:	e8 86 01 00 00       	call   800514 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80038e:	83 c4 08             	add    $0x8,%esp
  800391:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800397:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80039d:	50                   	push   %eax
  80039e:	e8 57 fd ff ff       	call   8000fa <sys_cputs>

	return b.cnt;
}
  8003a3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003b1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b4:	50                   	push   %eax
  8003b5:	ff 75 08             	pushl  0x8(%ebp)
  8003b8:	e8 9d ff ff ff       	call   80035a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003bd:	c9                   	leave  
  8003be:	c3                   	ret    

008003bf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	57                   	push   %edi
  8003c3:	56                   	push   %esi
  8003c4:	53                   	push   %ebx
  8003c5:	83 ec 1c             	sub    $0x1c,%esp
  8003c8:	89 c7                	mov    %eax,%edi
  8003ca:	89 d6                	mov    %edx,%esi
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003e0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003e3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003e6:	39 d3                	cmp    %edx,%ebx
  8003e8:	72 05                	jb     8003ef <printnum+0x30>
  8003ea:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ed:	77 7a                	ja     800469 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ef:	83 ec 0c             	sub    $0xc,%esp
  8003f2:	ff 75 18             	pushl  0x18(%ebp)
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003fb:	53                   	push   %ebx
  8003fc:	ff 75 10             	pushl  0x10(%ebp)
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	ff 75 e4             	pushl  -0x1c(%ebp)
  800405:	ff 75 e0             	pushl  -0x20(%ebp)
  800408:	ff 75 dc             	pushl  -0x24(%ebp)
  80040b:	ff 75 d8             	pushl  -0x28(%ebp)
  80040e:	e8 8d 08 00 00       	call   800ca0 <__udivdi3>
  800413:	83 c4 18             	add    $0x18,%esp
  800416:	52                   	push   %edx
  800417:	50                   	push   %eax
  800418:	89 f2                	mov    %esi,%edx
  80041a:	89 f8                	mov    %edi,%eax
  80041c:	e8 9e ff ff ff       	call   8003bf <printnum>
  800421:	83 c4 20             	add    $0x20,%esp
  800424:	eb 13                	jmp    800439 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	56                   	push   %esi
  80042a:	ff 75 18             	pushl  0x18(%ebp)
  80042d:	ff d7                	call   *%edi
  80042f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800432:	83 eb 01             	sub    $0x1,%ebx
  800435:	85 db                	test   %ebx,%ebx
  800437:	7f ed                	jg     800426 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	56                   	push   %esi
  80043d:	83 ec 04             	sub    $0x4,%esp
  800440:	ff 75 e4             	pushl  -0x1c(%ebp)
  800443:	ff 75 e0             	pushl  -0x20(%ebp)
  800446:	ff 75 dc             	pushl  -0x24(%ebp)
  800449:	ff 75 d8             	pushl  -0x28(%ebp)
  80044c:	e8 6f 09 00 00       	call   800dc0 <__umoddi3>
  800451:	83 c4 14             	add    $0x14,%esp
  800454:	0f be 80 3e 0f 80 00 	movsbl 0x800f3e(%eax),%eax
  80045b:	50                   	push   %eax
  80045c:	ff d7                	call   *%edi
}
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800464:	5b                   	pop    %ebx
  800465:	5e                   	pop    %esi
  800466:	5f                   	pop    %edi
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    
  800469:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80046c:	eb c4                	jmp    800432 <printnum+0x73>

0080046e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800471:	83 fa 01             	cmp    $0x1,%edx
  800474:	7e 0e                	jle    800484 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800476:	8b 10                	mov    (%eax),%edx
  800478:	8d 4a 08             	lea    0x8(%edx),%ecx
  80047b:	89 08                	mov    %ecx,(%eax)
  80047d:	8b 02                	mov    (%edx),%eax
  80047f:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800482:	5d                   	pop    %ebp
  800483:	c3                   	ret    
	else if (lflag)
  800484:	85 d2                	test   %edx,%edx
  800486:	75 10                	jne    800498 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800488:	8b 10                	mov    (%eax),%edx
  80048a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80048d:	89 08                	mov    %ecx,(%eax)
  80048f:	8b 02                	mov    (%edx),%eax
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb ea                	jmp    800482 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 02                	mov    (%edx),%eax
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a6:	eb da                	jmp    800482 <getuint+0x14>

008004a8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ab:	83 fa 01             	cmp    $0x1,%edx
  8004ae:	7e 0e                	jle    8004be <getint+0x16>
		return va_arg(*ap, long long);
  8004b0:	8b 10                	mov    (%eax),%edx
  8004b2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b5:	89 08                	mov    %ecx,(%eax)
  8004b7:	8b 02                	mov    (%edx),%eax
  8004b9:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    
	else if (lflag)
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	75 0c                	jne    8004ce <getint+0x26>
		return va_arg(*ap, int);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	99                   	cltd   
  8004cc:	eb ee                	jmp    8004bc <getint+0x14>
		return va_arg(*ap, long);
  8004ce:	8b 10                	mov    (%eax),%edx
  8004d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d3:	89 08                	mov    %ecx,(%eax)
  8004d5:	8b 02                	mov    (%edx),%eax
  8004d7:	99                   	cltd   
  8004d8:	eb e2                	jmp    8004bc <getint+0x14>

008004da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004da:	55                   	push   %ebp
  8004db:	89 e5                	mov    %esp,%ebp
  8004dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e4:	8b 10                	mov    (%eax),%edx
  8004e6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e9:	73 0a                	jae    8004f5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004eb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ee:	89 08                	mov    %ecx,(%eax)
  8004f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f3:	88 02                	mov    %al,(%edx)
}
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <printfmt>:
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800500:	50                   	push   %eax
  800501:	ff 75 10             	pushl  0x10(%ebp)
  800504:	ff 75 0c             	pushl  0xc(%ebp)
  800507:	ff 75 08             	pushl  0x8(%ebp)
  80050a:	e8 05 00 00 00       	call   800514 <vprintfmt>
}
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	c9                   	leave  
  800513:	c3                   	ret    

00800514 <vprintfmt>:
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	57                   	push   %edi
  800518:	56                   	push   %esi
  800519:	53                   	push   %ebx
  80051a:	83 ec 2c             	sub    $0x2c,%esp
  80051d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800520:	8b 75 0c             	mov    0xc(%ebp),%esi
  800523:	89 f7                	mov    %esi,%edi
  800525:	89 de                	mov    %ebx,%esi
  800527:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80052a:	e9 9e 02 00 00       	jmp    8007cd <vprintfmt+0x2b9>
		padc = ' ';
  80052f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800533:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80053a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800541:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800548:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8d 43 01             	lea    0x1(%ebx),%eax
  800550:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800553:	0f b6 0b             	movzbl (%ebx),%ecx
  800556:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800559:	3c 55                	cmp    $0x55,%al
  80055b:	0f 87 e8 02 00 00    	ja     800849 <vprintfmt+0x335>
  800561:	0f b6 c0             	movzbl %al,%eax
  800564:	ff 24 85 00 10 80 00 	jmp    *0x801000(,%eax,4)
  80056b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80056e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800572:	eb d9                	jmp    80054d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800577:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80057b:	eb d0                	jmp    80054d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	0f b6 c9             	movzbl %cl,%ecx
  800580:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800583:	b8 00 00 00 00       	mov    $0x0,%eax
  800588:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80058b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80058e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800592:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800595:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800598:	83 fa 09             	cmp    $0x9,%edx
  80059b:	77 52                	ja     8005ef <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  80059d:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8005a0:	eb e9                	jmp    80058b <vprintfmt+0x77>
			precision = va_arg(ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 48 04             	lea    0x4(%eax),%ecx
  8005a8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  8005b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b7:	79 94                	jns    80054d <vprintfmt+0x39>
				width = precision, precision = -1;
  8005b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005bf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c6:	eb 85                	jmp    80054d <vprintfmt+0x39>
  8005c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	0f 49 c8             	cmovns %eax,%ecx
  8005d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005db:	e9 6d ff ff ff       	jmp    80054d <vprintfmt+0x39>
  8005e0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8005e3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ea:	e9 5e ff ff ff       	jmp    80054d <vprintfmt+0x39>
  8005ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005f5:	eb bc                	jmp    8005b3 <vprintfmt+0x9f>
			lflag++;
  8005f7:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8005fd:	e9 4b ff ff ff       	jmp    80054d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 50 04             	lea    0x4(%eax),%edx
  800608:	89 55 14             	mov    %edx,0x14(%ebp)
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	57                   	push   %edi
  80060f:	ff 30                	pushl  (%eax)
  800611:	ff d6                	call   *%esi
			break;
  800613:	83 c4 10             	add    $0x10,%esp
  800616:	e9 af 01 00 00       	jmp    8007ca <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	99                   	cltd   
  800627:	31 d0                	xor    %edx,%eax
  800629:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062b:	83 f8 08             	cmp    $0x8,%eax
  80062e:	7f 20                	jg     800650 <vprintfmt+0x13c>
  800630:	8b 14 85 60 11 80 00 	mov    0x801160(,%eax,4),%edx
  800637:	85 d2                	test   %edx,%edx
  800639:	74 15                	je     800650 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80063b:	52                   	push   %edx
  80063c:	68 5f 0f 80 00       	push   $0x800f5f
  800641:	57                   	push   %edi
  800642:	56                   	push   %esi
  800643:	e8 af fe ff ff       	call   8004f7 <printfmt>
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	e9 7a 01 00 00       	jmp    8007ca <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800650:	50                   	push   %eax
  800651:	68 56 0f 80 00       	push   $0x800f56
  800656:	57                   	push   %edi
  800657:	56                   	push   %esi
  800658:	e8 9a fe ff ff       	call   8004f7 <printfmt>
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	e9 65 01 00 00       	jmp    8007ca <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 04             	lea    0x4(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800670:	85 db                	test   %ebx,%ebx
  800672:	b8 4f 0f 80 00       	mov    $0x800f4f,%eax
  800677:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  80067a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067e:	0f 8e bd 00 00 00    	jle    800741 <vprintfmt+0x22d>
  800684:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800688:	75 0e                	jne    800698 <vprintfmt+0x184>
  80068a:	89 75 08             	mov    %esi,0x8(%ebp)
  80068d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800690:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800693:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800696:	eb 6d                	jmp    800705 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	ff 75 d0             	pushl  -0x30(%ebp)
  80069e:	53                   	push   %ebx
  80069f:	e8 4d 02 00 00       	call   8008f1 <strnlen>
  8006a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006a7:	29 c1                	sub    %eax,%ecx
  8006a9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006ac:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006af:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b6:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8006b9:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bb:	eb 0f                	jmp    8006cc <vprintfmt+0x1b8>
					putch(padc, putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	57                   	push   %edi
  8006c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c6:	83 eb 01             	sub    $0x1,%ebx
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	85 db                	test   %ebx,%ebx
  8006ce:	7f ed                	jg     8006bd <vprintfmt+0x1a9>
  8006d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006d3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006d6:	85 c9                	test   %ecx,%ecx
  8006d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006dd:	0f 49 c1             	cmovns %ecx,%eax
  8006e0:	29 c1                	sub    %eax,%ecx
  8006e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006eb:	89 cf                	mov    %ecx,%edi
  8006ed:	eb 16                	jmp    800705 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f3:	75 31                	jne    800726 <vprintfmt+0x212>
					putch(ch, putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	ff 75 0c             	pushl  0xc(%ebp)
  8006fb:	50                   	push   %eax
  8006fc:	ff 55 08             	call   *0x8(%ebp)
  8006ff:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800702:	83 ef 01             	sub    $0x1,%edi
  800705:	83 c3 01             	add    $0x1,%ebx
  800708:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  80070c:	0f be c2             	movsbl %dl,%eax
  80070f:	85 c0                	test   %eax,%eax
  800711:	74 50                	je     800763 <vprintfmt+0x24f>
  800713:	85 f6                	test   %esi,%esi
  800715:	78 d8                	js     8006ef <vprintfmt+0x1db>
  800717:	83 ee 01             	sub    $0x1,%esi
  80071a:	79 d3                	jns    8006ef <vprintfmt+0x1db>
  80071c:	89 fb                	mov    %edi,%ebx
  80071e:	8b 75 08             	mov    0x8(%ebp),%esi
  800721:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800724:	eb 37                	jmp    80075d <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  800726:	0f be d2             	movsbl %dl,%edx
  800729:	83 ea 20             	sub    $0x20,%edx
  80072c:	83 fa 5e             	cmp    $0x5e,%edx
  80072f:	76 c4                	jbe    8006f5 <vprintfmt+0x1e1>
					putch('?', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	ff 75 0c             	pushl  0xc(%ebp)
  800737:	6a 3f                	push   $0x3f
  800739:	ff 55 08             	call   *0x8(%ebp)
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	eb c1                	jmp    800702 <vprintfmt+0x1ee>
  800741:	89 75 08             	mov    %esi,0x8(%ebp)
  800744:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800747:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80074a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80074d:	eb b6                	jmp    800705 <vprintfmt+0x1f1>
				putch(' ', putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	57                   	push   %edi
  800753:	6a 20                	push   $0x20
  800755:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800757:	83 eb 01             	sub    $0x1,%ebx
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	85 db                	test   %ebx,%ebx
  80075f:	7f ee                	jg     80074f <vprintfmt+0x23b>
  800761:	eb 67                	jmp    8007ca <vprintfmt+0x2b6>
  800763:	89 fb                	mov    %edi,%ebx
  800765:	8b 75 08             	mov    0x8(%ebp),%esi
  800768:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80076b:	eb f0                	jmp    80075d <vprintfmt+0x249>
			num = getint(&ap, lflag);
  80076d:	8d 45 14             	lea    0x14(%ebp),%eax
  800770:	e8 33 fd ff ff       	call   8004a8 <getint>
  800775:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800778:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80077b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800780:	85 d2                	test   %edx,%edx
  800782:	79 2c                	jns    8007b0 <vprintfmt+0x29c>
				putch('-', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	57                   	push   %edi
  800788:	6a 2d                	push   $0x2d
  80078a:	ff d6                	call   *%esi
				num = -(long long) num;
  80078c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80078f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800792:	f7 d8                	neg    %eax
  800794:	83 d2 00             	adc    $0x0,%edx
  800797:	f7 da                	neg    %edx
  800799:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80079c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a1:	eb 0d                	jmp    8007b0 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 c3 fc ff ff       	call   80046e <getuint>
			base = 10;
  8007ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8007b0:	83 ec 0c             	sub    $0xc,%esp
  8007b3:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  8007b7:	53                   	push   %ebx
  8007b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007bb:	51                   	push   %ecx
  8007bc:	52                   	push   %edx
  8007bd:	50                   	push   %eax
  8007be:	89 fa                	mov    %edi,%edx
  8007c0:	89 f0                	mov    %esi,%eax
  8007c2:	e8 f8 fb ff ff       	call   8003bf <printnum>
			break;
  8007c7:	83 c4 20             	add    $0x20,%esp
{
  8007ca:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007cd:	83 c3 01             	add    $0x1,%ebx
  8007d0:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8007d4:	83 f8 25             	cmp    $0x25,%eax
  8007d7:	0f 84 52 fd ff ff    	je     80052f <vprintfmt+0x1b>
			if (ch == '\0')
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	0f 84 84 00 00 00    	je     800869 <vprintfmt+0x355>
			putch(ch, putdat);
  8007e5:	83 ec 08             	sub    $0x8,%esp
  8007e8:	57                   	push   %edi
  8007e9:	50                   	push   %eax
  8007ea:	ff d6                	call   *%esi
  8007ec:	83 c4 10             	add    $0x10,%esp
  8007ef:	eb dc                	jmp    8007cd <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8007f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f4:	e8 75 fc ff ff       	call   80046e <getuint>
			base = 8;
  8007f9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007fe:	eb b0                	jmp    8007b0 <vprintfmt+0x29c>
			putch('0', putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	57                   	push   %edi
  800804:	6a 30                	push   $0x30
  800806:	ff d6                	call   *%esi
			putch('x', putdat);
  800808:	83 c4 08             	add    $0x8,%esp
  80080b:	57                   	push   %edi
  80080c:	6a 78                	push   $0x78
  80080e:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8d 50 04             	lea    0x4(%eax),%edx
  800816:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800819:	8b 00                	mov    (%eax),%eax
  80081b:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800820:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800823:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800828:	eb 86                	jmp    8007b0 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80082a:	8d 45 14             	lea    0x14(%ebp),%eax
  80082d:	e8 3c fc ff ff       	call   80046e <getuint>
			base = 16;
  800832:	b9 10 00 00 00       	mov    $0x10,%ecx
  800837:	e9 74 ff ff ff       	jmp    8007b0 <vprintfmt+0x29c>
			putch(ch, putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	57                   	push   %edi
  800840:	6a 25                	push   $0x25
  800842:	ff d6                	call   *%esi
			break;
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	eb 81                	jmp    8007ca <vprintfmt+0x2b6>
			putch('%', putdat);
  800849:	83 ec 08             	sub    $0x8,%esp
  80084c:	57                   	push   %edi
  80084d:	6a 25                	push   $0x25
  80084f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	89 d8                	mov    %ebx,%eax
  800856:	eb 03                	jmp    80085b <vprintfmt+0x347>
  800858:	83 e8 01             	sub    $0x1,%eax
  80085b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80085f:	75 f7                	jne    800858 <vprintfmt+0x344>
  800861:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800864:	e9 61 ff ff ff       	jmp    8007ca <vprintfmt+0x2b6>
}
  800869:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086c:	5b                   	pop    %ebx
  80086d:	5e                   	pop    %esi
  80086e:	5f                   	pop    %edi
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	83 ec 18             	sub    $0x18,%esp
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800880:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800884:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800887:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088e:	85 c0                	test   %eax,%eax
  800890:	74 26                	je     8008b8 <vsnprintf+0x47>
  800892:	85 d2                	test   %edx,%edx
  800894:	7e 22                	jle    8008b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800896:	ff 75 14             	pushl  0x14(%ebp)
  800899:	ff 75 10             	pushl  0x10(%ebp)
  80089c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80089f:	50                   	push   %eax
  8008a0:	68 da 04 80 00       	push   $0x8004da
  8008a5:	e8 6a fc ff ff       	call   800514 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b3:	83 c4 10             	add    $0x10,%esp
}
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    
		return -E_INVAL;
  8008b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008bd:	eb f7                	jmp    8008b6 <vsnprintf+0x45>

008008bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008c8:	50                   	push   %eax
  8008c9:	ff 75 10             	pushl  0x10(%ebp)
  8008cc:	ff 75 0c             	pushl  0xc(%ebp)
  8008cf:	ff 75 08             	pushl  0x8(%ebp)
  8008d2:	e8 9a ff ff ff       	call   800871 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008d7:	c9                   	leave  
  8008d8:	c3                   	ret    

008008d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e4:	eb 03                	jmp    8008e9 <strlen+0x10>
		n++;
  8008e6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ed:	75 f7                	jne    8008e6 <strlen+0xd>
	return n;
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ff:	eb 03                	jmp    800904 <strnlen+0x13>
		n++;
  800901:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800904:	39 d0                	cmp    %edx,%eax
  800906:	74 06                	je     80090e <strnlen+0x1d>
  800908:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80090c:	75 f3                	jne    800901 <strnlen+0x10>
	return n;
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	53                   	push   %ebx
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80091a:	89 c2                	mov    %eax,%edx
  80091c:	83 c1 01             	add    $0x1,%ecx
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800926:	88 5a ff             	mov    %bl,-0x1(%edx)
  800929:	84 db                	test   %bl,%bl
  80092b:	75 ef                	jne    80091c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80092d:	5b                   	pop    %ebx
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	53                   	push   %ebx
  800934:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800937:	53                   	push   %ebx
  800938:	e8 9c ff ff ff       	call   8008d9 <strlen>
  80093d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800940:	ff 75 0c             	pushl  0xc(%ebp)
  800943:	01 d8                	add    %ebx,%eax
  800945:	50                   	push   %eax
  800946:	e8 c5 ff ff ff       	call   800910 <strcpy>
	return dst;
}
  80094b:	89 d8                	mov    %ebx,%eax
  80094d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 75 08             	mov    0x8(%ebp),%esi
  80095a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095d:	89 f3                	mov    %esi,%ebx
  80095f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800962:	89 f2                	mov    %esi,%edx
  800964:	eb 0f                	jmp    800975 <strncpy+0x23>
		*dst++ = *src;
  800966:	83 c2 01             	add    $0x1,%edx
  800969:	0f b6 01             	movzbl (%ecx),%eax
  80096c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80096f:	80 39 01             	cmpb   $0x1,(%ecx)
  800972:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800975:	39 da                	cmp    %ebx,%edx
  800977:	75 ed                	jne    800966 <strncpy+0x14>
	}
	return ret;
}
  800979:	89 f0                	mov    %esi,%eax
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 75 08             	mov    0x8(%ebp),%esi
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80098d:	89 f0                	mov    %esi,%eax
  80098f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800993:	85 c9                	test   %ecx,%ecx
  800995:	75 0b                	jne    8009a2 <strlcpy+0x23>
  800997:	eb 17                	jmp    8009b0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800999:	83 c2 01             	add    $0x1,%edx
  80099c:	83 c0 01             	add    $0x1,%eax
  80099f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009a2:	39 d8                	cmp    %ebx,%eax
  8009a4:	74 07                	je     8009ad <strlcpy+0x2e>
  8009a6:	0f b6 0a             	movzbl (%edx),%ecx
  8009a9:	84 c9                	test   %cl,%cl
  8009ab:	75 ec                	jne    800999 <strlcpy+0x1a>
		*dst = '\0';
  8009ad:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009b0:	29 f0                	sub    %esi,%eax
}
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009bf:	eb 06                	jmp    8009c7 <strcmp+0x11>
		p++, q++;
  8009c1:	83 c1 01             	add    $0x1,%ecx
  8009c4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009c7:	0f b6 01             	movzbl (%ecx),%eax
  8009ca:	84 c0                	test   %al,%al
  8009cc:	74 04                	je     8009d2 <strcmp+0x1c>
  8009ce:	3a 02                	cmp    (%edx),%al
  8009d0:	74 ef                	je     8009c1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d2:	0f b6 c0             	movzbl %al,%eax
  8009d5:	0f b6 12             	movzbl (%edx),%edx
  8009d8:	29 d0                	sub    %edx,%eax
}
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	53                   	push   %ebx
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e6:	89 c3                	mov    %eax,%ebx
  8009e8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009eb:	eb 06                	jmp    8009f3 <strncmp+0x17>
		n--, p++, q++;
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009f3:	39 d8                	cmp    %ebx,%eax
  8009f5:	74 16                	je     800a0d <strncmp+0x31>
  8009f7:	0f b6 08             	movzbl (%eax),%ecx
  8009fa:	84 c9                	test   %cl,%cl
  8009fc:	74 04                	je     800a02 <strncmp+0x26>
  8009fe:	3a 0a                	cmp    (%edx),%cl
  800a00:	74 eb                	je     8009ed <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a02:	0f b6 00             	movzbl (%eax),%eax
  800a05:	0f b6 12             	movzbl (%edx),%edx
  800a08:	29 d0                	sub    %edx,%eax
}
  800a0a:	5b                   	pop    %ebx
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    
		return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	eb f6                	jmp    800a0a <strncmp+0x2e>

00800a14 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1e:	0f b6 10             	movzbl (%eax),%edx
  800a21:	84 d2                	test   %dl,%dl
  800a23:	74 09                	je     800a2e <strchr+0x1a>
		if (*s == c)
  800a25:	38 ca                	cmp    %cl,%dl
  800a27:	74 0a                	je     800a33 <strchr+0x1f>
	for (; *s; s++)
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	eb f0                	jmp    800a1e <strchr+0xa>
			return (char *) s;
	return 0;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a3f:	eb 03                	jmp    800a44 <strfind+0xf>
  800a41:	83 c0 01             	add    $0x1,%eax
  800a44:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a47:	38 ca                	cmp    %cl,%dl
  800a49:	74 04                	je     800a4f <strfind+0x1a>
  800a4b:	84 d2                	test   %dl,%dl
  800a4d:	75 f2                	jne    800a41 <strfind+0xc>
			break;
	return (char *) s;
}
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	57                   	push   %edi
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a5d:	85 c9                	test   %ecx,%ecx
  800a5f:	74 12                	je     800a73 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a61:	f6 c2 03             	test   $0x3,%dl
  800a64:	75 05                	jne    800a6b <memset+0x1a>
  800a66:	f6 c1 03             	test   $0x3,%cl
  800a69:	74 0f                	je     800a7a <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6b:	89 d7                	mov    %edx,%edi
  800a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a70:	fc                   	cld    
  800a71:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a73:	89 d0                	mov    %edx,%eax
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    
		c &= 0xFF;
  800a7a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7e:	89 d8                	mov    %ebx,%eax
  800a80:	c1 e0 08             	shl    $0x8,%eax
  800a83:	89 df                	mov    %ebx,%edi
  800a85:	c1 e7 18             	shl    $0x18,%edi
  800a88:	89 de                	mov    %ebx,%esi
  800a8a:	c1 e6 10             	shl    $0x10,%esi
  800a8d:	09 f7                	or     %esi,%edi
  800a8f:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800a91:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a94:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a96:	89 d7                	mov    %edx,%edi
  800a98:	fc                   	cld    
  800a99:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9b:	eb d6                	jmp    800a73 <memset+0x22>

00800a9d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aab:	39 c6                	cmp    %eax,%esi
  800aad:	73 35                	jae    800ae4 <memmove+0x47>
  800aaf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab2:	39 c2                	cmp    %eax,%edx
  800ab4:	76 2e                	jbe    800ae4 <memmove+0x47>
		s += n;
		d += n;
  800ab6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab9:	89 d6                	mov    %edx,%esi
  800abb:	09 fe                	or     %edi,%esi
  800abd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ac3:	74 0c                	je     800ad1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac5:	83 ef 01             	sub    $0x1,%edi
  800ac8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800acb:	fd                   	std    
  800acc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ace:	fc                   	cld    
  800acf:	eb 21                	jmp    800af2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad1:	f6 c1 03             	test   $0x3,%cl
  800ad4:	75 ef                	jne    800ac5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad6:	83 ef 04             	sub    $0x4,%edi
  800ad9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800adc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800adf:	fd                   	std    
  800ae0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae2:	eb ea                	jmp    800ace <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae4:	89 f2                	mov    %esi,%edx
  800ae6:	09 c2                	or     %eax,%edx
  800ae8:	f6 c2 03             	test   $0x3,%dl
  800aeb:	74 09                	je     800af6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aed:	89 c7                	mov    %eax,%edi
  800aef:	fc                   	cld    
  800af0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af6:	f6 c1 03             	test   $0x3,%cl
  800af9:	75 f2                	jne    800aed <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800afb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800afe:	89 c7                	mov    %eax,%edi
  800b00:	fc                   	cld    
  800b01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b03:	eb ed                	jmp    800af2 <memmove+0x55>

00800b05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b08:	ff 75 10             	pushl  0x10(%ebp)
  800b0b:	ff 75 0c             	pushl  0xc(%ebp)
  800b0e:	ff 75 08             	pushl  0x8(%ebp)
  800b11:	e8 87 ff ff ff       	call   800a9d <memmove>
}
  800b16:	c9                   	leave  
  800b17:	c3                   	ret    

00800b18 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b23:	89 c6                	mov    %eax,%esi
  800b25:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b28:	39 f0                	cmp    %esi,%eax
  800b2a:	74 1c                	je     800b48 <memcmp+0x30>
		if (*s1 != *s2)
  800b2c:	0f b6 08             	movzbl (%eax),%ecx
  800b2f:	0f b6 1a             	movzbl (%edx),%ebx
  800b32:	38 d9                	cmp    %bl,%cl
  800b34:	75 08                	jne    800b3e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b36:	83 c0 01             	add    $0x1,%eax
  800b39:	83 c2 01             	add    $0x1,%edx
  800b3c:	eb ea                	jmp    800b28 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b3e:	0f b6 c1             	movzbl %cl,%eax
  800b41:	0f b6 db             	movzbl %bl,%ebx
  800b44:	29 d8                	sub    %ebx,%eax
  800b46:	eb 05                	jmp    800b4d <memcmp+0x35>
	}

	return 0;
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b5a:	89 c2                	mov    %eax,%edx
  800b5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b5f:	39 d0                	cmp    %edx,%eax
  800b61:	73 09                	jae    800b6c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b63:	38 08                	cmp    %cl,(%eax)
  800b65:	74 05                	je     800b6c <memfind+0x1b>
	for (; s < ends; s++)
  800b67:	83 c0 01             	add    $0x1,%eax
  800b6a:	eb f3                	jmp    800b5f <memfind+0xe>
			break;
	return (void *) s;
}
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7a:	eb 03                	jmp    800b7f <strtol+0x11>
		s++;
  800b7c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b7f:	0f b6 01             	movzbl (%ecx),%eax
  800b82:	3c 20                	cmp    $0x20,%al
  800b84:	74 f6                	je     800b7c <strtol+0xe>
  800b86:	3c 09                	cmp    $0x9,%al
  800b88:	74 f2                	je     800b7c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b8a:	3c 2b                	cmp    $0x2b,%al
  800b8c:	74 2e                	je     800bbc <strtol+0x4e>
	int neg = 0;
  800b8e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b93:	3c 2d                	cmp    $0x2d,%al
  800b95:	74 2f                	je     800bc6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b97:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b9d:	75 05                	jne    800ba4 <strtol+0x36>
  800b9f:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba2:	74 2c                	je     800bd0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba4:	85 db                	test   %ebx,%ebx
  800ba6:	75 0a                	jne    800bb2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba8:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bad:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb0:	74 28                	je     800bda <strtol+0x6c>
		base = 10;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bba:	eb 50                	jmp    800c0c <strtol+0x9e>
		s++;
  800bbc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bbf:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc4:	eb d1                	jmp    800b97 <strtol+0x29>
		s++, neg = 1;
  800bc6:	83 c1 01             	add    $0x1,%ecx
  800bc9:	bf 01 00 00 00       	mov    $0x1,%edi
  800bce:	eb c7                	jmp    800b97 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd4:	74 0e                	je     800be4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bd6:	85 db                	test   %ebx,%ebx
  800bd8:	75 d8                	jne    800bb2 <strtol+0x44>
		s++, base = 8;
  800bda:	83 c1 01             	add    $0x1,%ecx
  800bdd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800be2:	eb ce                	jmp    800bb2 <strtol+0x44>
		s += 2, base = 16;
  800be4:	83 c1 02             	add    $0x2,%ecx
  800be7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bec:	eb c4                	jmp    800bb2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bee:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bf1:	89 f3                	mov    %esi,%ebx
  800bf3:	80 fb 19             	cmp    $0x19,%bl
  800bf6:	77 29                	ja     800c21 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bf8:	0f be d2             	movsbl %dl,%edx
  800bfb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bfe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c01:	7d 30                	jge    800c33 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c03:	83 c1 01             	add    $0x1,%ecx
  800c06:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c0a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c0c:	0f b6 11             	movzbl (%ecx),%edx
  800c0f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c12:	89 f3                	mov    %esi,%ebx
  800c14:	80 fb 09             	cmp    $0x9,%bl
  800c17:	77 d5                	ja     800bee <strtol+0x80>
			dig = *s - '0';
  800c19:	0f be d2             	movsbl %dl,%edx
  800c1c:	83 ea 30             	sub    $0x30,%edx
  800c1f:	eb dd                	jmp    800bfe <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c21:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c24:	89 f3                	mov    %esi,%ebx
  800c26:	80 fb 19             	cmp    $0x19,%bl
  800c29:	77 08                	ja     800c33 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c2b:	0f be d2             	movsbl %dl,%edx
  800c2e:	83 ea 37             	sub    $0x37,%edx
  800c31:	eb cb                	jmp    800bfe <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c37:	74 05                	je     800c3e <strtol+0xd0>
		*endptr = (char *) s;
  800c39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c3e:	89 c2                	mov    %eax,%edx
  800c40:	f7 da                	neg    %edx
  800c42:	85 ff                	test   %edi,%edi
  800c44:	0f 45 c2             	cmovne %edx,%eax
}
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800c52:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800c59:	74 0a                	je     800c65 <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800c63:	c9                   	leave  
  800c64:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  800c65:	83 ec 04             	sub    $0x4,%esp
  800c68:	6a 07                	push   $0x7
  800c6a:	68 00 f0 bf ee       	push   $0xeebff000
  800c6f:	6a 00                	push   $0x0
  800c71:	e8 3b f5 ff ff       	call   8001b1 <sys_page_alloc>
		if (r < 0) return;
  800c76:	83 c4 10             	add    $0x10,%esp
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	78 e6                	js     800c63 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800c7d:	83 ec 08             	sub    $0x8,%esp
  800c80:	68 ab 02 80 00       	push   $0x8002ab
  800c85:	6a 00                	push   $0x0
  800c87:	e8 b5 f5 ff ff       	call   800241 <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  800c8c:	83 c4 10             	add    $0x10,%esp
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	79 c8                	jns    800c5b <set_pgfault_handler+0xf>
  800c93:	eb ce                	jmp    800c63 <set_pgfault_handler+0x17>
  800c95:	66 90                	xchg   %ax,%ax
  800c97:	66 90                	xchg   %ax,%ax
  800c99:	66 90                	xchg   %ax,%ax
  800c9b:	66 90                	xchg   %ax,%ax
  800c9d:	66 90                	xchg   %ax,%ax
  800c9f:	90                   	nop

00800ca0 <__udivdi3>:
  800ca0:	55                   	push   %ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 1c             	sub    $0x1c,%esp
  800ca7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800cab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800caf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cb7:	85 d2                	test   %edx,%edx
  800cb9:	75 35                	jne    800cf0 <__udivdi3+0x50>
  800cbb:	39 f3                	cmp    %esi,%ebx
  800cbd:	0f 87 bd 00 00 00    	ja     800d80 <__udivdi3+0xe0>
  800cc3:	85 db                	test   %ebx,%ebx
  800cc5:	89 d9                	mov    %ebx,%ecx
  800cc7:	75 0b                	jne    800cd4 <__udivdi3+0x34>
  800cc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cce:	31 d2                	xor    %edx,%edx
  800cd0:	f7 f3                	div    %ebx
  800cd2:	89 c1                	mov    %eax,%ecx
  800cd4:	31 d2                	xor    %edx,%edx
  800cd6:	89 f0                	mov    %esi,%eax
  800cd8:	f7 f1                	div    %ecx
  800cda:	89 c6                	mov    %eax,%esi
  800cdc:	89 e8                	mov    %ebp,%eax
  800cde:	89 f7                	mov    %esi,%edi
  800ce0:	f7 f1                	div    %ecx
  800ce2:	89 fa                	mov    %edi,%edx
  800ce4:	83 c4 1c             	add    $0x1c,%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
  800cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	39 f2                	cmp    %esi,%edx
  800cf2:	77 7c                	ja     800d70 <__udivdi3+0xd0>
  800cf4:	0f bd fa             	bsr    %edx,%edi
  800cf7:	83 f7 1f             	xor    $0x1f,%edi
  800cfa:	0f 84 98 00 00 00    	je     800d98 <__udivdi3+0xf8>
  800d00:	89 f9                	mov    %edi,%ecx
  800d02:	b8 20 00 00 00       	mov    $0x20,%eax
  800d07:	29 f8                	sub    %edi,%eax
  800d09:	d3 e2                	shl    %cl,%edx
  800d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d0f:	89 c1                	mov    %eax,%ecx
  800d11:	89 da                	mov    %ebx,%edx
  800d13:	d3 ea                	shr    %cl,%edx
  800d15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d19:	09 d1                	or     %edx,%ecx
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d21:	89 f9                	mov    %edi,%ecx
  800d23:	d3 e3                	shl    %cl,%ebx
  800d25:	89 c1                	mov    %eax,%ecx
  800d27:	d3 ea                	shr    %cl,%edx
  800d29:	89 f9                	mov    %edi,%ecx
  800d2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d2f:	d3 e6                	shl    %cl,%esi
  800d31:	89 eb                	mov    %ebp,%ebx
  800d33:	89 c1                	mov    %eax,%ecx
  800d35:	d3 eb                	shr    %cl,%ebx
  800d37:	09 de                	or     %ebx,%esi
  800d39:	89 f0                	mov    %esi,%eax
  800d3b:	f7 74 24 08          	divl   0x8(%esp)
  800d3f:	89 d6                	mov    %edx,%esi
  800d41:	89 c3                	mov    %eax,%ebx
  800d43:	f7 64 24 0c          	mull   0xc(%esp)
  800d47:	39 d6                	cmp    %edx,%esi
  800d49:	72 0c                	jb     800d57 <__udivdi3+0xb7>
  800d4b:	89 f9                	mov    %edi,%ecx
  800d4d:	d3 e5                	shl    %cl,%ebp
  800d4f:	39 c5                	cmp    %eax,%ebp
  800d51:	73 5d                	jae    800db0 <__udivdi3+0x110>
  800d53:	39 d6                	cmp    %edx,%esi
  800d55:	75 59                	jne    800db0 <__udivdi3+0x110>
  800d57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d5a:	31 ff                	xor    %edi,%edi
  800d5c:	89 fa                	mov    %edi,%edx
  800d5e:	83 c4 1c             	add    $0x1c,%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
  800d66:	8d 76 00             	lea    0x0(%esi),%esi
  800d69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d70:	31 ff                	xor    %edi,%edi
  800d72:	31 c0                	xor    %eax,%eax
  800d74:	89 fa                	mov    %edi,%edx
  800d76:	83 c4 1c             	add    $0x1c,%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
  800d7e:	66 90                	xchg   %ax,%ax
  800d80:	31 ff                	xor    %edi,%edi
  800d82:	89 e8                	mov    %ebp,%eax
  800d84:	89 f2                	mov    %esi,%edx
  800d86:	f7 f3                	div    %ebx
  800d88:	89 fa                	mov    %edi,%edx
  800d8a:	83 c4 1c             	add    $0x1c,%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
  800d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d98:	39 f2                	cmp    %esi,%edx
  800d9a:	72 06                	jb     800da2 <__udivdi3+0x102>
  800d9c:	31 c0                	xor    %eax,%eax
  800d9e:	39 eb                	cmp    %ebp,%ebx
  800da0:	77 d2                	ja     800d74 <__udivdi3+0xd4>
  800da2:	b8 01 00 00 00       	mov    $0x1,%eax
  800da7:	eb cb                	jmp    800d74 <__udivdi3+0xd4>
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	89 d8                	mov    %ebx,%eax
  800db2:	31 ff                	xor    %edi,%edi
  800db4:	eb be                	jmp    800d74 <__udivdi3+0xd4>
  800db6:	66 90                	xchg   %ax,%ax
  800db8:	66 90                	xchg   %ax,%ax
  800dba:	66 90                	xchg   %ax,%ax
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__umoddi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
  800dc7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800dcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dd7:	85 ed                	test   %ebp,%ebp
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	89 da                	mov    %ebx,%edx
  800ddd:	75 19                	jne    800df8 <__umoddi3+0x38>
  800ddf:	39 df                	cmp    %ebx,%edi
  800de1:	0f 86 b1 00 00 00    	jbe    800e98 <__umoddi3+0xd8>
  800de7:	f7 f7                	div    %edi
  800de9:	89 d0                	mov    %edx,%eax
  800deb:	31 d2                	xor    %edx,%edx
  800ded:	83 c4 1c             	add    $0x1c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	39 dd                	cmp    %ebx,%ebp
  800dfa:	77 f1                	ja     800ded <__umoddi3+0x2d>
  800dfc:	0f bd cd             	bsr    %ebp,%ecx
  800dff:	83 f1 1f             	xor    $0x1f,%ecx
  800e02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e06:	0f 84 b4 00 00 00    	je     800ec0 <__umoddi3+0x100>
  800e0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e11:	89 c2                	mov    %eax,%edx
  800e13:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e17:	29 c2                	sub    %eax,%edx
  800e19:	89 c1                	mov    %eax,%ecx
  800e1b:	89 f8                	mov    %edi,%eax
  800e1d:	d3 e5                	shl    %cl,%ebp
  800e1f:	89 d1                	mov    %edx,%ecx
  800e21:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e25:	d3 e8                	shr    %cl,%eax
  800e27:	09 c5                	or     %eax,%ebp
  800e29:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e2d:	89 c1                	mov    %eax,%ecx
  800e2f:	d3 e7                	shl    %cl,%edi
  800e31:	89 d1                	mov    %edx,%ecx
  800e33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e37:	89 df                	mov    %ebx,%edi
  800e39:	d3 ef                	shr    %cl,%edi
  800e3b:	89 c1                	mov    %eax,%ecx
  800e3d:	89 f0                	mov    %esi,%eax
  800e3f:	d3 e3                	shl    %cl,%ebx
  800e41:	89 d1                	mov    %edx,%ecx
  800e43:	89 fa                	mov    %edi,%edx
  800e45:	d3 e8                	shr    %cl,%eax
  800e47:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e4c:	09 d8                	or     %ebx,%eax
  800e4e:	f7 f5                	div    %ebp
  800e50:	d3 e6                	shl    %cl,%esi
  800e52:	89 d1                	mov    %edx,%ecx
  800e54:	f7 64 24 08          	mull   0x8(%esp)
  800e58:	39 d1                	cmp    %edx,%ecx
  800e5a:	89 c3                	mov    %eax,%ebx
  800e5c:	89 d7                	mov    %edx,%edi
  800e5e:	72 06                	jb     800e66 <__umoddi3+0xa6>
  800e60:	75 0e                	jne    800e70 <__umoddi3+0xb0>
  800e62:	39 c6                	cmp    %eax,%esi
  800e64:	73 0a                	jae    800e70 <__umoddi3+0xb0>
  800e66:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e6a:	19 ea                	sbb    %ebp,%edx
  800e6c:	89 d7                	mov    %edx,%edi
  800e6e:	89 c3                	mov    %eax,%ebx
  800e70:	89 ca                	mov    %ecx,%edx
  800e72:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e77:	29 de                	sub    %ebx,%esi
  800e79:	19 fa                	sbb    %edi,%edx
  800e7b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e7f:	89 d0                	mov    %edx,%eax
  800e81:	d3 e0                	shl    %cl,%eax
  800e83:	89 d9                	mov    %ebx,%ecx
  800e85:	d3 ee                	shr    %cl,%esi
  800e87:	d3 ea                	shr    %cl,%edx
  800e89:	09 f0                	or     %esi,%eax
  800e8b:	83 c4 1c             	add    $0x1c,%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    
  800e93:	90                   	nop
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	85 ff                	test   %edi,%edi
  800e9a:	89 f9                	mov    %edi,%ecx
  800e9c:	75 0b                	jne    800ea9 <__umoddi3+0xe9>
  800e9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  800ea5:	f7 f7                	div    %edi
  800ea7:	89 c1                	mov    %eax,%ecx
  800ea9:	89 d8                	mov    %ebx,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f1                	div    %ecx
  800eaf:	89 f0                	mov    %esi,%eax
  800eb1:	f7 f1                	div    %ecx
  800eb3:	e9 31 ff ff ff       	jmp    800de9 <__umoddi3+0x29>
  800eb8:	90                   	nop
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	39 dd                	cmp    %ebx,%ebp
  800ec2:	72 08                	jb     800ecc <__umoddi3+0x10c>
  800ec4:	39 f7                	cmp    %esi,%edi
  800ec6:	0f 87 21 ff ff ff    	ja     800ded <__umoddi3+0x2d>
  800ecc:	89 da                	mov    %ebx,%edx
  800ece:	89 f0                	mov    %esi,%eax
  800ed0:	29 f8                	sub    %edi,%eax
  800ed2:	19 ea                	sbb    %ebp,%edx
  800ed4:	e9 14 ff ff ff       	jmp    800ded <__umoddi3+0x2d>
