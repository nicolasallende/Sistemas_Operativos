
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 7b 01 00 00       	call   8001c2 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 fc 01 00 00       	call   800252 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800070:	e8 02 01 00 00       	call   800177 <sys_getenvid>
	if (id >= 0)
  800075:	85 c0                	test   %eax,%eax
  800077:	78 12                	js     80008b <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800079:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007e:	c1 e0 07             	shl    $0x7,%eax
  800081:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800086:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008b:	85 db                	test   %ebx,%ebx
  80008d:	7e 07                	jle    800096 <libmain+0x31>
		binaryname = argv[0];
  80008f:	8b 06                	mov    (%esi),%eax
  800091:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
  80009b:	e8 93 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0a 00 00 00       	call   8000af <exit>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b5:	6a 00                	push   $0x0
  8000b7:	e8 99 00 00 00       	call   800155 <sys_env_destroy>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 1c             	sub    $0x1c,%esp
  8000ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000d0:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000db:	8b 75 14             	mov    0x14(%ebp),%esi
  8000de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000e4:	74 04                	je     8000ea <syscall+0x29>
  8000e6:	85 c0                	test   %eax,%eax
  8000e8:	7f 08                	jg     8000f2 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5f                   	pop    %edi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    
  8000f2:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	52                   	push   %edx
  8000fa:	68 8a 0e 80 00       	push   $0x800e8a
  8000ff:	6a 23                	push   $0x23
  800101:	68 a7 0e 80 00       	push   $0x800ea7
  800106:	e8 b1 01 00 00       	call   8002bc <_panic>

0080010b <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800111:	6a 00                	push   $0x0
  800113:	6a 00                	push   $0x0
  800115:	6a 00                	push   $0x0
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 00 00 00 00       	mov    $0x0,%eax
  800127:	e8 95 ff ff ff       	call   8000c1 <syscall>
}
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	c9                   	leave  
  800130:	c3                   	ret    

00800131 <sys_cgetc>:

int
sys_cgetc(void)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800137:	6a 00                	push   $0x0
  800139:	6a 00                	push   $0x0
  80013b:	6a 00                	push   $0x0
  80013d:	6a 00                	push   $0x0
  80013f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800144:	ba 00 00 00 00       	mov    $0x0,%edx
  800149:	b8 01 00 00 00       	mov    $0x1,%eax
  80014e:	e8 6e ff ff ff       	call   8000c1 <syscall>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80015b:	6a 00                	push   $0x0
  80015d:	6a 00                	push   $0x0
  80015f:	6a 00                	push   $0x0
  800161:	6a 00                	push   $0x0
  800163:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800166:	ba 01 00 00 00       	mov    $0x1,%edx
  80016b:	b8 03 00 00 00       	mov    $0x3,%eax
  800170:	e8 4c ff ff ff       	call   8000c1 <syscall>
}
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80017d:	6a 00                	push   $0x0
  80017f:	6a 00                	push   $0x0
  800181:	6a 00                	push   $0x0
  800183:	6a 00                	push   $0x0
  800185:	b9 00 00 00 00       	mov    $0x0,%ecx
  80018a:	ba 00 00 00 00       	mov    $0x0,%edx
  80018f:	b8 02 00 00 00       	mov    $0x2,%eax
  800194:	e8 28 ff ff ff       	call   8000c1 <syscall>
}
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <sys_yield>:

void
sys_yield(void)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001a1:	6a 00                	push   $0x0
  8001a3:	6a 00                	push   $0x0
  8001a5:	6a 00                	push   $0x0
  8001a7:	6a 00                	push   $0x0
  8001a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001b8:	e8 04 ff ff ff       	call   8000c1 <syscall>
}
  8001bd:	83 c4 10             	add    $0x10,%esp
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    

008001c2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001c8:	6a 00                	push   $0x0
  8001ca:	6a 00                	push   $0x0
  8001cc:	ff 75 10             	pushl  0x10(%ebp)
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001da:	b8 04 00 00 00       	mov    $0x4,%eax
  8001df:	e8 dd fe ff ff       	call   8000c1 <syscall>
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001ec:	ff 75 18             	pushl  0x18(%ebp)
  8001ef:	ff 75 14             	pushl  0x14(%ebp)
  8001f2:	ff 75 10             	pushl  0x10(%ebp)
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fb:	ba 01 00 00 00       	mov    $0x1,%edx
  800200:	b8 05 00 00 00       	mov    $0x5,%eax
  800205:	e8 b7 fe ff ff       	call   8000c1 <syscall>
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800212:	6a 00                	push   $0x0
  800214:	6a 00                	push   $0x0
  800216:	6a 00                	push   $0x0
  800218:	ff 75 0c             	pushl  0xc(%ebp)
  80021b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021e:	ba 01 00 00 00       	mov    $0x1,%edx
  800223:	b8 06 00 00 00       	mov    $0x6,%eax
  800228:	e8 94 fe ff ff       	call   8000c1 <syscall>
}
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800235:	6a 00                	push   $0x0
  800237:	6a 00                	push   $0x0
  800239:	6a 00                	push   $0x0
  80023b:	ff 75 0c             	pushl  0xc(%ebp)
  80023e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800241:	ba 01 00 00 00       	mov    $0x1,%edx
  800246:	b8 08 00 00 00       	mov    $0x8,%eax
  80024b:	e8 71 fe ff ff       	call   8000c1 <syscall>
}
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800258:	6a 00                	push   $0x0
  80025a:	6a 00                	push   $0x0
  80025c:	6a 00                	push   $0x0
  80025e:	ff 75 0c             	pushl  0xc(%ebp)
  800261:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800264:	ba 01 00 00 00       	mov    $0x1,%edx
  800269:	b8 09 00 00 00       	mov    $0x9,%eax
  80026e:	e8 4e fe ff ff       	call   8000c1 <syscall>
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80027b:	6a 00                	push   $0x0
  80027d:	ff 75 14             	pushl  0x14(%ebp)
  800280:	ff 75 10             	pushl  0x10(%ebp)
  800283:	ff 75 0c             	pushl  0xc(%ebp)
  800286:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
  80028e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800293:	e8 29 fe ff ff       	call   8000c1 <syscall>
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002a0:	6a 00                	push   $0x0
  8002a2:	6a 00                	push   $0x0
  8002a4:	6a 00                	push   $0x0
  8002a6:	6a 00                	push   $0x0
  8002a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ab:	ba 01 00 00 00       	mov    $0x1,%edx
  8002b0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002b5:	e8 07 fe ff ff       	call   8000c1 <syscall>
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002c1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002ca:	e8 a8 fe ff ff       	call   800177 <sys_getenvid>
  8002cf:	83 ec 0c             	sub    $0xc,%esp
  8002d2:	ff 75 0c             	pushl  0xc(%ebp)
  8002d5:	ff 75 08             	pushl  0x8(%ebp)
  8002d8:	56                   	push   %esi
  8002d9:	50                   	push   %eax
  8002da:	68 b8 0e 80 00       	push   $0x800eb8
  8002df:	e8 b3 00 00 00       	call   800397 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e4:	83 c4 18             	add    $0x18,%esp
  8002e7:	53                   	push   %ebx
  8002e8:	ff 75 10             	pushl  0x10(%ebp)
  8002eb:	e8 56 00 00 00       	call   800346 <vcprintf>
	cprintf("\n");
  8002f0:	c7 04 24 dc 0e 80 00 	movl   $0x800edc,(%esp)
  8002f7:	e8 9b 00 00 00       	call   800397 <cprintf>
  8002fc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ff:	cc                   	int3   
  800300:	eb fd                	jmp    8002ff <_panic+0x43>

00800302 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	53                   	push   %ebx
  800306:	83 ec 04             	sub    $0x4,%esp
  800309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80030c:	8b 13                	mov    (%ebx),%edx
  80030e:	8d 42 01             	lea    0x1(%edx),%eax
  800311:	89 03                	mov    %eax,(%ebx)
  800313:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800316:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80031a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031f:	74 09                	je     80032a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800321:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800328:	c9                   	leave  
  800329:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	68 ff 00 00 00       	push   $0xff
  800332:	8d 43 08             	lea    0x8(%ebx),%eax
  800335:	50                   	push   %eax
  800336:	e8 d0 fd ff ff       	call   80010b <sys_cputs>
		b->idx = 0;
  80033b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800341:	83 c4 10             	add    $0x10,%esp
  800344:	eb db                	jmp    800321 <putch+0x1f>

00800346 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80034f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800356:	00 00 00 
	b.cnt = 0;
  800359:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800360:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800363:	ff 75 0c             	pushl  0xc(%ebp)
  800366:	ff 75 08             	pushl  0x8(%ebp)
  800369:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80036f:	50                   	push   %eax
  800370:	68 02 03 80 00       	push   $0x800302
  800375:	e8 86 01 00 00       	call   800500 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80037a:	83 c4 08             	add    $0x8,%esp
  80037d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800383:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800389:	50                   	push   %eax
  80038a:	e8 7c fd ff ff       	call   80010b <sys_cputs>

	return b.cnt;
}
  80038f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800395:	c9                   	leave  
  800396:	c3                   	ret    

00800397 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80039d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a0:	50                   	push   %eax
  8003a1:	ff 75 08             	pushl  0x8(%ebp)
  8003a4:	e8 9d ff ff ff       	call   800346 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	57                   	push   %edi
  8003af:	56                   	push   %esi
  8003b0:	53                   	push   %ebx
  8003b1:	83 ec 1c             	sub    $0x1c,%esp
  8003b4:	89 c7                	mov    %eax,%edi
  8003b6:	89 d6                	mov    %edx,%esi
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003cf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003d2:	39 d3                	cmp    %edx,%ebx
  8003d4:	72 05                	jb     8003db <printnum+0x30>
  8003d6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003d9:	77 7a                	ja     800455 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003db:	83 ec 0c             	sub    $0xc,%esp
  8003de:	ff 75 18             	pushl  0x18(%ebp)
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003e7:	53                   	push   %ebx
  8003e8:	ff 75 10             	pushl  0x10(%ebp)
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003f4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003fa:	e8 41 08 00 00       	call   800c40 <__udivdi3>
  8003ff:	83 c4 18             	add    $0x18,%esp
  800402:	52                   	push   %edx
  800403:	50                   	push   %eax
  800404:	89 f2                	mov    %esi,%edx
  800406:	89 f8                	mov    %edi,%eax
  800408:	e8 9e ff ff ff       	call   8003ab <printnum>
  80040d:	83 c4 20             	add    $0x20,%esp
  800410:	eb 13                	jmp    800425 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	56                   	push   %esi
  800416:	ff 75 18             	pushl  0x18(%ebp)
  800419:	ff d7                	call   *%edi
  80041b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80041e:	83 eb 01             	sub    $0x1,%ebx
  800421:	85 db                	test   %ebx,%ebx
  800423:	7f ed                	jg     800412 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	56                   	push   %esi
  800429:	83 ec 04             	sub    $0x4,%esp
  80042c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042f:	ff 75 e0             	pushl  -0x20(%ebp)
  800432:	ff 75 dc             	pushl  -0x24(%ebp)
  800435:	ff 75 d8             	pushl  -0x28(%ebp)
  800438:	e8 23 09 00 00       	call   800d60 <__umoddi3>
  80043d:	83 c4 14             	add    $0x14,%esp
  800440:	0f be 80 de 0e 80 00 	movsbl 0x800ede(%eax),%eax
  800447:	50                   	push   %eax
  800448:	ff d7                	call   *%edi
}
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800450:	5b                   	pop    %ebx
  800451:	5e                   	pop    %esi
  800452:	5f                   	pop    %edi
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    
  800455:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800458:	eb c4                	jmp    80041e <printnum+0x73>

0080045a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80045d:	83 fa 01             	cmp    $0x1,%edx
  800460:	7e 0e                	jle    800470 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800462:	8b 10                	mov    (%eax),%edx
  800464:	8d 4a 08             	lea    0x8(%edx),%ecx
  800467:	89 08                	mov    %ecx,(%eax)
  800469:	8b 02                	mov    (%edx),%eax
  80046b:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  80046e:	5d                   	pop    %ebp
  80046f:	c3                   	ret    
	else if (lflag)
  800470:	85 d2                	test   %edx,%edx
  800472:	75 10                	jne    800484 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800474:	8b 10                	mov    (%eax),%edx
  800476:	8d 4a 04             	lea    0x4(%edx),%ecx
  800479:	89 08                	mov    %ecx,(%eax)
  80047b:	8b 02                	mov    (%edx),%eax
  80047d:	ba 00 00 00 00       	mov    $0x0,%edx
  800482:	eb ea                	jmp    80046e <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 4a 04             	lea    0x4(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	ba 00 00 00 00       	mov    $0x0,%edx
  800492:	eb da                	jmp    80046e <getuint+0x14>

00800494 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800497:	83 fa 01             	cmp    $0x1,%edx
  80049a:	7e 0e                	jle    8004aa <getint+0x16>
		return va_arg(*ap, long long);
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 02                	mov    (%edx),%eax
  8004a5:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  8004a8:	5d                   	pop    %ebp
  8004a9:	c3                   	ret    
	else if (lflag)
  8004aa:	85 d2                	test   %edx,%edx
  8004ac:	75 0c                	jne    8004ba <getint+0x26>
		return va_arg(*ap, int);
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 02                	mov    (%edx),%eax
  8004b7:	99                   	cltd   
  8004b8:	eb ee                	jmp    8004a8 <getint+0x14>
		return va_arg(*ap, long);
  8004ba:	8b 10                	mov    (%eax),%edx
  8004bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bf:	89 08                	mov    %ecx,(%eax)
  8004c1:	8b 02                	mov    (%edx),%eax
  8004c3:	99                   	cltd   
  8004c4:	eb e2                	jmp    8004a8 <getint+0x14>

008004c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d0:	8b 10                	mov    (%eax),%edx
  8004d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d5:	73 0a                	jae    8004e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004da:	89 08                	mov    %ecx,(%eax)
  8004dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8004df:	88 02                	mov    %al,(%edx)
}
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <printfmt>:
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ec:	50                   	push   %eax
  8004ed:	ff 75 10             	pushl  0x10(%ebp)
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	ff 75 08             	pushl  0x8(%ebp)
  8004f6:	e8 05 00 00 00       	call   800500 <vprintfmt>
}
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	c9                   	leave  
  8004ff:	c3                   	ret    

00800500 <vprintfmt>:
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	57                   	push   %edi
  800504:	56                   	push   %esi
  800505:	53                   	push   %ebx
  800506:	83 ec 2c             	sub    $0x2c,%esp
  800509:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80050c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80050f:	89 f7                	mov    %esi,%edi
  800511:	89 de                	mov    %ebx,%esi
  800513:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800516:	e9 9e 02 00 00       	jmp    8007b9 <vprintfmt+0x2b9>
		padc = ' ';
  80051b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80051f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800526:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80052d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800534:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8d 43 01             	lea    0x1(%ebx),%eax
  80053c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053f:	0f b6 0b             	movzbl (%ebx),%ecx
  800542:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800545:	3c 55                	cmp    $0x55,%al
  800547:	0f 87 e8 02 00 00    	ja     800835 <vprintfmt+0x335>
  80054d:	0f b6 c0             	movzbl %al,%eax
  800550:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  800557:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80055a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80055e:	eb d9                	jmp    800539 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800563:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800567:	eb d0                	jmp    800539 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800569:	0f b6 c9             	movzbl %cl,%ecx
  80056c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80056f:	b8 00 00 00 00       	mov    $0x0,%eax
  800574:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800577:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80057a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80057e:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800581:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800584:	83 fa 09             	cmp    $0x9,%edx
  800587:	77 52                	ja     8005db <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800589:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80058c:	eb e9                	jmp    800577 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 48 04             	lea    0x4(%eax),%ecx
  800594:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80059f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a3:	79 94                	jns    800539 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005b2:	eb 85                	jmp    800539 <vprintfmt+0x39>
  8005b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	0f 49 c8             	cmovns %eax,%ecx
  8005c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005c7:	e9 6d ff ff ff       	jmp    800539 <vprintfmt+0x39>
  8005cc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8005cf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005d6:	e9 5e ff ff ff       	jmp    800539 <vprintfmt+0x39>
  8005db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005de:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e1:	eb bc                	jmp    80059f <vprintfmt+0x9f>
			lflag++;
  8005e3:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8005e9:	e9 4b ff ff ff       	jmp    800539 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	57                   	push   %edi
  8005fb:	ff 30                	pushl  (%eax)
  8005fd:	ff d6                	call   *%esi
			break;
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	e9 af 01 00 00       	jmp    8007b6 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	99                   	cltd   
  800613:	31 d0                	xor    %edx,%eax
  800615:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800617:	83 f8 08             	cmp    $0x8,%eax
  80061a:	7f 20                	jg     80063c <vprintfmt+0x13c>
  80061c:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  800623:	85 d2                	test   %edx,%edx
  800625:	74 15                	je     80063c <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800627:	52                   	push   %edx
  800628:	68 ff 0e 80 00       	push   $0x800eff
  80062d:	57                   	push   %edi
  80062e:	56                   	push   %esi
  80062f:	e8 af fe ff ff       	call   8004e3 <printfmt>
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	e9 7a 01 00 00       	jmp    8007b6 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  80063c:	50                   	push   %eax
  80063d:	68 f6 0e 80 00       	push   $0x800ef6
  800642:	57                   	push   %edi
  800643:	56                   	push   %esi
  800644:	e8 9a fe ff ff       	call   8004e3 <printfmt>
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	e9 65 01 00 00       	jmp    8007b6 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
  80065a:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  80065c:	85 db                	test   %ebx,%ebx
  80065e:	b8 ef 0e 80 00       	mov    $0x800eef,%eax
  800663:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  800666:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80066a:	0f 8e bd 00 00 00    	jle    80072d <vprintfmt+0x22d>
  800670:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800674:	75 0e                	jne    800684 <vprintfmt+0x184>
  800676:	89 75 08             	mov    %esi,0x8(%ebp)
  800679:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067c:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80067f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800682:	eb 6d                	jmp    8006f1 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	ff 75 d0             	pushl  -0x30(%ebp)
  80068a:	53                   	push   %ebx
  80068b:	e8 4d 02 00 00       	call   8008dd <strnlen>
  800690:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800693:	29 c1                	sub    %eax,%ecx
  800695:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800698:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80069b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80069f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a2:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8006a5:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a7:	eb 0f                	jmp    8006b8 <vprintfmt+0x1b8>
					putch(padc, putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	57                   	push   %edi
  8006ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	83 eb 01             	sub    $0x1,%ebx
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	85 db                	test   %ebx,%ebx
  8006ba:	7f ed                	jg     8006a9 <vprintfmt+0x1a9>
  8006bc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006bf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006c2:	85 c9                	test   %ecx,%ecx
  8006c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c9:	0f 49 c1             	cmovns %ecx,%eax
  8006cc:	29 c1                	sub    %eax,%ecx
  8006ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d4:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006d7:	89 cf                	mov    %ecx,%edi
  8006d9:	eb 16                	jmp    8006f1 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8006db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006df:	75 31                	jne    800712 <vprintfmt+0x212>
					putch(ch, putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	50                   	push   %eax
  8006e8:	ff 55 08             	call   *0x8(%ebp)
  8006eb:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ee:	83 ef 01             	sub    $0x1,%edi
  8006f1:	83 c3 01             	add    $0x1,%ebx
  8006f4:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8006f8:	0f be c2             	movsbl %dl,%eax
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	74 50                	je     80074f <vprintfmt+0x24f>
  8006ff:	85 f6                	test   %esi,%esi
  800701:	78 d8                	js     8006db <vprintfmt+0x1db>
  800703:	83 ee 01             	sub    $0x1,%esi
  800706:	79 d3                	jns    8006db <vprintfmt+0x1db>
  800708:	89 fb                	mov    %edi,%ebx
  80070a:	8b 75 08             	mov    0x8(%ebp),%esi
  80070d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800710:	eb 37                	jmp    800749 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  800712:	0f be d2             	movsbl %dl,%edx
  800715:	83 ea 20             	sub    $0x20,%edx
  800718:	83 fa 5e             	cmp    $0x5e,%edx
  80071b:	76 c4                	jbe    8006e1 <vprintfmt+0x1e1>
					putch('?', putdat);
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	ff 75 0c             	pushl  0xc(%ebp)
  800723:	6a 3f                	push   $0x3f
  800725:	ff 55 08             	call   *0x8(%ebp)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	eb c1                	jmp    8006ee <vprintfmt+0x1ee>
  80072d:	89 75 08             	mov    %esi,0x8(%ebp)
  800730:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800733:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800736:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800739:	eb b6                	jmp    8006f1 <vprintfmt+0x1f1>
				putch(' ', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	57                   	push   %edi
  80073f:	6a 20                	push   $0x20
  800741:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800743:	83 eb 01             	sub    $0x1,%ebx
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	85 db                	test   %ebx,%ebx
  80074b:	7f ee                	jg     80073b <vprintfmt+0x23b>
  80074d:	eb 67                	jmp    8007b6 <vprintfmt+0x2b6>
  80074f:	89 fb                	mov    %edi,%ebx
  800751:	8b 75 08             	mov    0x8(%ebp),%esi
  800754:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800757:	eb f0                	jmp    800749 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800759:	8d 45 14             	lea    0x14(%ebp),%eax
  80075c:	e8 33 fd ff ff       	call   800494 <getint>
  800761:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800764:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800767:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  80076c:	85 d2                	test   %edx,%edx
  80076e:	79 2c                	jns    80079c <vprintfmt+0x29c>
				putch('-', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	57                   	push   %edi
  800774:	6a 2d                	push   $0x2d
  800776:	ff d6                	call   *%esi
				num = -(long long) num;
  800778:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80077e:	f7 d8                	neg    %eax
  800780:	83 d2 00             	adc    $0x0,%edx
  800783:	f7 da                	neg    %edx
  800785:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800788:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80078d:	eb 0d                	jmp    80079c <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 c3 fc ff ff       	call   80045a <getuint>
			base = 10;
  800797:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80079c:	83 ec 0c             	sub    $0xc,%esp
  80079f:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  8007a3:	53                   	push   %ebx
  8007a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a7:	51                   	push   %ecx
  8007a8:	52                   	push   %edx
  8007a9:	50                   	push   %eax
  8007aa:	89 fa                	mov    %edi,%edx
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	e8 f8 fb ff ff       	call   8003ab <printnum>
			break;
  8007b3:	83 c4 20             	add    $0x20,%esp
{
  8007b6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007b9:	83 c3 01             	add    $0x1,%ebx
  8007bc:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8007c0:	83 f8 25             	cmp    $0x25,%eax
  8007c3:	0f 84 52 fd ff ff    	je     80051b <vprintfmt+0x1b>
			if (ch == '\0')
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	0f 84 84 00 00 00    	je     800855 <vprintfmt+0x355>
			putch(ch, putdat);
  8007d1:	83 ec 08             	sub    $0x8,%esp
  8007d4:	57                   	push   %edi
  8007d5:	50                   	push   %eax
  8007d6:	ff d6                	call   *%esi
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb dc                	jmp    8007b9 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e0:	e8 75 fc ff ff       	call   80045a <getuint>
			base = 8;
  8007e5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007ea:	eb b0                	jmp    80079c <vprintfmt+0x29c>
			putch('0', putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	57                   	push   %edi
  8007f0:	6a 30                	push   $0x30
  8007f2:	ff d6                	call   *%esi
			putch('x', putdat);
  8007f4:	83 c4 08             	add    $0x8,%esp
  8007f7:	57                   	push   %edi
  8007f8:	6a 78                	push   $0x78
  8007fa:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8d 50 04             	lea    0x4(%eax),%edx
  800802:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800805:	8b 00                	mov    (%eax),%eax
  800807:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  80080c:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80080f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800814:	eb 86                	jmp    80079c <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
  800819:	e8 3c fc ff ff       	call   80045a <getuint>
			base = 16;
  80081e:	b9 10 00 00 00       	mov    $0x10,%ecx
  800823:	e9 74 ff ff ff       	jmp    80079c <vprintfmt+0x29c>
			putch(ch, putdat);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	57                   	push   %edi
  80082c:	6a 25                	push   $0x25
  80082e:	ff d6                	call   *%esi
			break;
  800830:	83 c4 10             	add    $0x10,%esp
  800833:	eb 81                	jmp    8007b6 <vprintfmt+0x2b6>
			putch('%', putdat);
  800835:	83 ec 08             	sub    $0x8,%esp
  800838:	57                   	push   %edi
  800839:	6a 25                	push   $0x25
  80083b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083d:	83 c4 10             	add    $0x10,%esp
  800840:	89 d8                	mov    %ebx,%eax
  800842:	eb 03                	jmp    800847 <vprintfmt+0x347>
  800844:	83 e8 01             	sub    $0x1,%eax
  800847:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80084b:	75 f7                	jne    800844 <vprintfmt+0x344>
  80084d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800850:	e9 61 ff ff ff       	jmp    8007b6 <vprintfmt+0x2b6>
}
  800855:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5f                   	pop    %edi
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	83 ec 18             	sub    $0x18,%esp
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800869:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800870:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800873:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087a:	85 c0                	test   %eax,%eax
  80087c:	74 26                	je     8008a4 <vsnprintf+0x47>
  80087e:	85 d2                	test   %edx,%edx
  800880:	7e 22                	jle    8008a4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800882:	ff 75 14             	pushl  0x14(%ebp)
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	68 c6 04 80 00       	push   $0x8004c6
  800891:	e8 6a fc ff ff       	call   800500 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800896:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800899:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089f:	83 c4 10             	add    $0x10,%esp
}
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    
		return -E_INVAL;
  8008a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a9:	eb f7                	jmp    8008a2 <vsnprintf+0x45>

008008ab <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b4:	50                   	push   %eax
  8008b5:	ff 75 10             	pushl  0x10(%ebp)
  8008b8:	ff 75 0c             	pushl  0xc(%ebp)
  8008bb:	ff 75 08             	pushl  0x8(%ebp)
  8008be:	e8 9a ff ff ff       	call   80085d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    

008008c5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d0:	eb 03                	jmp    8008d5 <strlen+0x10>
		n++;
  8008d2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008d5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d9:	75 f7                	jne    8008d2 <strlen+0xd>
	return n;
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	eb 03                	jmp    8008f0 <strnlen+0x13>
		n++;
  8008ed:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f0:	39 d0                	cmp    %edx,%eax
  8008f2:	74 06                	je     8008fa <strnlen+0x1d>
  8008f4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008f8:	75 f3                	jne    8008ed <strnlen+0x10>
	return n;
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	53                   	push   %ebx
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800906:	89 c2                	mov    %eax,%edx
  800908:	83 c1 01             	add    $0x1,%ecx
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800912:	88 5a ff             	mov    %bl,-0x1(%edx)
  800915:	84 db                	test   %bl,%bl
  800917:	75 ef                	jne    800908 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800919:	5b                   	pop    %ebx
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	53                   	push   %ebx
  800920:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800923:	53                   	push   %ebx
  800924:	e8 9c ff ff ff       	call   8008c5 <strlen>
  800929:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80092c:	ff 75 0c             	pushl  0xc(%ebp)
  80092f:	01 d8                	add    %ebx,%eax
  800931:	50                   	push   %eax
  800932:	e8 c5 ff ff ff       	call   8008fc <strcpy>
	return dst;
}
  800937:	89 d8                	mov    %ebx,%eax
  800939:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80093c:	c9                   	leave  
  80093d:	c3                   	ret    

0080093e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 75 08             	mov    0x8(%ebp),%esi
  800946:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800949:	89 f3                	mov    %esi,%ebx
  80094b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094e:	89 f2                	mov    %esi,%edx
  800950:	eb 0f                	jmp    800961 <strncpy+0x23>
		*dst++ = *src;
  800952:	83 c2 01             	add    $0x1,%edx
  800955:	0f b6 01             	movzbl (%ecx),%eax
  800958:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095b:	80 39 01             	cmpb   $0x1,(%ecx)
  80095e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800961:	39 da                	cmp    %ebx,%edx
  800963:	75 ed                	jne    800952 <strncpy+0x14>
	}
	return ret;
}
  800965:	89 f0                	mov    %esi,%eax
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 75 08             	mov    0x8(%ebp),%esi
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
  800976:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800979:	89 f0                	mov    %esi,%eax
  80097b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097f:	85 c9                	test   %ecx,%ecx
  800981:	75 0b                	jne    80098e <strlcpy+0x23>
  800983:	eb 17                	jmp    80099c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800985:	83 c2 01             	add    $0x1,%edx
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80098e:	39 d8                	cmp    %ebx,%eax
  800990:	74 07                	je     800999 <strlcpy+0x2e>
  800992:	0f b6 0a             	movzbl (%edx),%ecx
  800995:	84 c9                	test   %cl,%cl
  800997:	75 ec                	jne    800985 <strlcpy+0x1a>
		*dst = '\0';
  800999:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099c:	29 f0                	sub    %esi,%eax
}
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ab:	eb 06                	jmp    8009b3 <strcmp+0x11>
		p++, q++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	84 c0                	test   %al,%al
  8009b8:	74 04                	je     8009be <strcmp+0x1c>
  8009ba:	3a 02                	cmp    (%edx),%al
  8009bc:	74 ef                	je     8009ad <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009be:	0f b6 c0             	movzbl %al,%eax
  8009c1:	0f b6 12             	movzbl (%edx),%edx
  8009c4:	29 d0                	sub    %edx,%eax
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	53                   	push   %ebx
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d2:	89 c3                	mov    %eax,%ebx
  8009d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d7:	eb 06                	jmp    8009df <strncmp+0x17>
		n--, p++, q++;
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009df:	39 d8                	cmp    %ebx,%eax
  8009e1:	74 16                	je     8009f9 <strncmp+0x31>
  8009e3:	0f b6 08             	movzbl (%eax),%ecx
  8009e6:	84 c9                	test   %cl,%cl
  8009e8:	74 04                	je     8009ee <strncmp+0x26>
  8009ea:	3a 0a                	cmp    (%edx),%cl
  8009ec:	74 eb                	je     8009d9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ee:	0f b6 00             	movzbl (%eax),%eax
  8009f1:	0f b6 12             	movzbl (%edx),%edx
  8009f4:	29 d0                	sub    %edx,%eax
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    
		return 0;
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fe:	eb f6                	jmp    8009f6 <strncmp+0x2e>

00800a00 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0a:	0f b6 10             	movzbl (%eax),%edx
  800a0d:	84 d2                	test   %dl,%dl
  800a0f:	74 09                	je     800a1a <strchr+0x1a>
		if (*s == c)
  800a11:	38 ca                	cmp    %cl,%dl
  800a13:	74 0a                	je     800a1f <strchr+0x1f>
	for (; *s; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	eb f0                	jmp    800a0a <strchr+0xa>
			return (char *) s;
	return 0;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2b:	eb 03                	jmp    800a30 <strfind+0xf>
  800a2d:	83 c0 01             	add    $0x1,%eax
  800a30:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a33:	38 ca                	cmp    %cl,%dl
  800a35:	74 04                	je     800a3b <strfind+0x1a>
  800a37:	84 d2                	test   %dl,%dl
  800a39:	75 f2                	jne    800a2d <strfind+0xc>
			break;
	return (char *) s;
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 55 08             	mov    0x8(%ebp),%edx
  800a46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a49:	85 c9                	test   %ecx,%ecx
  800a4b:	74 12                	je     800a5f <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4d:	f6 c2 03             	test   $0x3,%dl
  800a50:	75 05                	jne    800a57 <memset+0x1a>
  800a52:	f6 c1 03             	test   $0x3,%cl
  800a55:	74 0f                	je     800a66 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a57:	89 d7                	mov    %edx,%edi
  800a59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5c:	fc                   	cld    
  800a5d:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a5f:	89 d0                	mov    %edx,%eax
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    
		c &= 0xFF;
  800a66:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6a:	89 d8                	mov    %ebx,%eax
  800a6c:	c1 e0 08             	shl    $0x8,%eax
  800a6f:	89 df                	mov    %ebx,%edi
  800a71:	c1 e7 18             	shl    $0x18,%edi
  800a74:	89 de                	mov    %ebx,%esi
  800a76:	c1 e6 10             	shl    $0x10,%esi
  800a79:	09 f7                	or     %esi,%edi
  800a7b:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a80:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a82:	89 d7                	mov    %edx,%edi
  800a84:	fc                   	cld    
  800a85:	f3 ab                	rep stos %eax,%es:(%edi)
  800a87:	eb d6                	jmp    800a5f <memset+0x22>

00800a89 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	57                   	push   %edi
  800a8d:	56                   	push   %esi
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a97:	39 c6                	cmp    %eax,%esi
  800a99:	73 35                	jae    800ad0 <memmove+0x47>
  800a9b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9e:	39 c2                	cmp    %eax,%edx
  800aa0:	76 2e                	jbe    800ad0 <memmove+0x47>
		s += n;
		d += n;
  800aa2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa5:	89 d6                	mov    %edx,%esi
  800aa7:	09 fe                	or     %edi,%esi
  800aa9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aaf:	74 0c                	je     800abd <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab1:	83 ef 01             	sub    $0x1,%edi
  800ab4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ab7:	fd                   	std    
  800ab8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aba:	fc                   	cld    
  800abb:	eb 21                	jmp    800ade <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abd:	f6 c1 03             	test   $0x3,%cl
  800ac0:	75 ef                	jne    800ab1 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac2:	83 ef 04             	sub    $0x4,%edi
  800ac5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800acb:	fd                   	std    
  800acc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ace:	eb ea                	jmp    800aba <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad0:	89 f2                	mov    %esi,%edx
  800ad2:	09 c2                	or     %eax,%edx
  800ad4:	f6 c2 03             	test   $0x3,%dl
  800ad7:	74 09                	je     800ae2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad9:	89 c7                	mov    %eax,%edi
  800adb:	fc                   	cld    
  800adc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae2:	f6 c1 03             	test   $0x3,%cl
  800ae5:	75 f2                	jne    800ad9 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aea:	89 c7                	mov    %eax,%edi
  800aec:	fc                   	cld    
  800aed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aef:	eb ed                	jmp    800ade <memmove+0x55>

00800af1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af4:	ff 75 10             	pushl  0x10(%ebp)
  800af7:	ff 75 0c             	pushl  0xc(%ebp)
  800afa:	ff 75 08             	pushl  0x8(%ebp)
  800afd:	e8 87 ff ff ff       	call   800a89 <memmove>
}
  800b02:	c9                   	leave  
  800b03:	c3                   	ret    

00800b04 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0f:	89 c6                	mov    %eax,%esi
  800b11:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b14:	39 f0                	cmp    %esi,%eax
  800b16:	74 1c                	je     800b34 <memcmp+0x30>
		if (*s1 != *s2)
  800b18:	0f b6 08             	movzbl (%eax),%ecx
  800b1b:	0f b6 1a             	movzbl (%edx),%ebx
  800b1e:	38 d9                	cmp    %bl,%cl
  800b20:	75 08                	jne    800b2a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b22:	83 c0 01             	add    $0x1,%eax
  800b25:	83 c2 01             	add    $0x1,%edx
  800b28:	eb ea                	jmp    800b14 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b2a:	0f b6 c1             	movzbl %cl,%eax
  800b2d:	0f b6 db             	movzbl %bl,%ebx
  800b30:	29 d8                	sub    %ebx,%eax
  800b32:	eb 05                	jmp    800b39 <memcmp+0x35>
	}

	return 0;
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b46:	89 c2                	mov    %eax,%edx
  800b48:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b4b:	39 d0                	cmp    %edx,%eax
  800b4d:	73 09                	jae    800b58 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4f:	38 08                	cmp    %cl,(%eax)
  800b51:	74 05                	je     800b58 <memfind+0x1b>
	for (; s < ends; s++)
  800b53:	83 c0 01             	add    $0x1,%eax
  800b56:	eb f3                	jmp    800b4b <memfind+0xe>
			break;
	return (void *) s;
}
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b66:	eb 03                	jmp    800b6b <strtol+0x11>
		s++;
  800b68:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b6b:	0f b6 01             	movzbl (%ecx),%eax
  800b6e:	3c 20                	cmp    $0x20,%al
  800b70:	74 f6                	je     800b68 <strtol+0xe>
  800b72:	3c 09                	cmp    $0x9,%al
  800b74:	74 f2                	je     800b68 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b76:	3c 2b                	cmp    $0x2b,%al
  800b78:	74 2e                	je     800ba8 <strtol+0x4e>
	int neg = 0;
  800b7a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b7f:	3c 2d                	cmp    $0x2d,%al
  800b81:	74 2f                	je     800bb2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b83:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b89:	75 05                	jne    800b90 <strtol+0x36>
  800b8b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8e:	74 2c                	je     800bbc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b90:	85 db                	test   %ebx,%ebx
  800b92:	75 0a                	jne    800b9e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b94:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b99:	80 39 30             	cmpb   $0x30,(%ecx)
  800b9c:	74 28                	je     800bc6 <strtol+0x6c>
		base = 10;
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ba6:	eb 50                	jmp    800bf8 <strtol+0x9e>
		s++;
  800ba8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bab:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb0:	eb d1                	jmp    800b83 <strtol+0x29>
		s++, neg = 1;
  800bb2:	83 c1 01             	add    $0x1,%ecx
  800bb5:	bf 01 00 00 00       	mov    $0x1,%edi
  800bba:	eb c7                	jmp    800b83 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bc0:	74 0e                	je     800bd0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bc2:	85 db                	test   %ebx,%ebx
  800bc4:	75 d8                	jne    800b9e <strtol+0x44>
		s++, base = 8;
  800bc6:	83 c1 01             	add    $0x1,%ecx
  800bc9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bce:	eb ce                	jmp    800b9e <strtol+0x44>
		s += 2, base = 16;
  800bd0:	83 c1 02             	add    $0x2,%ecx
  800bd3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd8:	eb c4                	jmp    800b9e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bda:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bdd:	89 f3                	mov    %esi,%ebx
  800bdf:	80 fb 19             	cmp    $0x19,%bl
  800be2:	77 29                	ja     800c0d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800be4:	0f be d2             	movsbl %dl,%edx
  800be7:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bea:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bed:	7d 30                	jge    800c1f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bef:	83 c1 01             	add    $0x1,%ecx
  800bf2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bf6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bf8:	0f b6 11             	movzbl (%ecx),%edx
  800bfb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bfe:	89 f3                	mov    %esi,%ebx
  800c00:	80 fb 09             	cmp    $0x9,%bl
  800c03:	77 d5                	ja     800bda <strtol+0x80>
			dig = *s - '0';
  800c05:	0f be d2             	movsbl %dl,%edx
  800c08:	83 ea 30             	sub    $0x30,%edx
  800c0b:	eb dd                	jmp    800bea <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c10:	89 f3                	mov    %esi,%ebx
  800c12:	80 fb 19             	cmp    $0x19,%bl
  800c15:	77 08                	ja     800c1f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c17:	0f be d2             	movsbl %dl,%edx
  800c1a:	83 ea 37             	sub    $0x37,%edx
  800c1d:	eb cb                	jmp    800bea <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c23:	74 05                	je     800c2a <strtol+0xd0>
		*endptr = (char *) s;
  800c25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c28:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c2a:	89 c2                	mov    %eax,%edx
  800c2c:	f7 da                	neg    %edx
  800c2e:	85 ff                	test   %edi,%edi
  800c30:	0f 45 c2             	cmovne %edx,%eax
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    
  800c38:	66 90                	xchg   %ax,%ax
  800c3a:	66 90                	xchg   %ax,%ax
  800c3c:	66 90                	xchg   %ax,%ax
  800c3e:	66 90                	xchg   %ax,%ax

00800c40 <__udivdi3>:
  800c40:	55                   	push   %ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 1c             	sub    $0x1c,%esp
  800c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c57:	85 d2                	test   %edx,%edx
  800c59:	75 35                	jne    800c90 <__udivdi3+0x50>
  800c5b:	39 f3                	cmp    %esi,%ebx
  800c5d:	0f 87 bd 00 00 00    	ja     800d20 <__udivdi3+0xe0>
  800c63:	85 db                	test   %ebx,%ebx
  800c65:	89 d9                	mov    %ebx,%ecx
  800c67:	75 0b                	jne    800c74 <__udivdi3+0x34>
  800c69:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6e:	31 d2                	xor    %edx,%edx
  800c70:	f7 f3                	div    %ebx
  800c72:	89 c1                	mov    %eax,%ecx
  800c74:	31 d2                	xor    %edx,%edx
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	f7 f1                	div    %ecx
  800c7a:	89 c6                	mov    %eax,%esi
  800c7c:	89 e8                	mov    %ebp,%eax
  800c7e:	89 f7                	mov    %esi,%edi
  800c80:	f7 f1                	div    %ecx
  800c82:	89 fa                	mov    %edi,%edx
  800c84:	83 c4 1c             	add    $0x1c,%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
  800c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c90:	39 f2                	cmp    %esi,%edx
  800c92:	77 7c                	ja     800d10 <__udivdi3+0xd0>
  800c94:	0f bd fa             	bsr    %edx,%edi
  800c97:	83 f7 1f             	xor    $0x1f,%edi
  800c9a:	0f 84 98 00 00 00    	je     800d38 <__udivdi3+0xf8>
  800ca0:	89 f9                	mov    %edi,%ecx
  800ca2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ca7:	29 f8                	sub    %edi,%eax
  800ca9:	d3 e2                	shl    %cl,%edx
  800cab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800caf:	89 c1                	mov    %eax,%ecx
  800cb1:	89 da                	mov    %ebx,%edx
  800cb3:	d3 ea                	shr    %cl,%edx
  800cb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cb9:	09 d1                	or     %edx,%ecx
  800cbb:	89 f2                	mov    %esi,%edx
  800cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc1:	89 f9                	mov    %edi,%ecx
  800cc3:	d3 e3                	shl    %cl,%ebx
  800cc5:	89 c1                	mov    %eax,%ecx
  800cc7:	d3 ea                	shr    %cl,%edx
  800cc9:	89 f9                	mov    %edi,%ecx
  800ccb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ccf:	d3 e6                	shl    %cl,%esi
  800cd1:	89 eb                	mov    %ebp,%ebx
  800cd3:	89 c1                	mov    %eax,%ecx
  800cd5:	d3 eb                	shr    %cl,%ebx
  800cd7:	09 de                	or     %ebx,%esi
  800cd9:	89 f0                	mov    %esi,%eax
  800cdb:	f7 74 24 08          	divl   0x8(%esp)
  800cdf:	89 d6                	mov    %edx,%esi
  800ce1:	89 c3                	mov    %eax,%ebx
  800ce3:	f7 64 24 0c          	mull   0xc(%esp)
  800ce7:	39 d6                	cmp    %edx,%esi
  800ce9:	72 0c                	jb     800cf7 <__udivdi3+0xb7>
  800ceb:	89 f9                	mov    %edi,%ecx
  800ced:	d3 e5                	shl    %cl,%ebp
  800cef:	39 c5                	cmp    %eax,%ebp
  800cf1:	73 5d                	jae    800d50 <__udivdi3+0x110>
  800cf3:	39 d6                	cmp    %edx,%esi
  800cf5:	75 59                	jne    800d50 <__udivdi3+0x110>
  800cf7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cfa:	31 ff                	xor    %edi,%edi
  800cfc:	89 fa                	mov    %edi,%edx
  800cfe:	83 c4 1c             	add    $0x1c,%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
  800d06:	8d 76 00             	lea    0x0(%esi),%esi
  800d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d10:	31 ff                	xor    %edi,%edi
  800d12:	31 c0                	xor    %eax,%eax
  800d14:	89 fa                	mov    %edi,%edx
  800d16:	83 c4 1c             	add    $0x1c,%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
  800d1e:	66 90                	xchg   %ax,%ax
  800d20:	31 ff                	xor    %edi,%edi
  800d22:	89 e8                	mov    %ebp,%eax
  800d24:	89 f2                	mov    %esi,%edx
  800d26:	f7 f3                	div    %ebx
  800d28:	89 fa                	mov    %edi,%edx
  800d2a:	83 c4 1c             	add    $0x1c,%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
  800d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d38:	39 f2                	cmp    %esi,%edx
  800d3a:	72 06                	jb     800d42 <__udivdi3+0x102>
  800d3c:	31 c0                	xor    %eax,%eax
  800d3e:	39 eb                	cmp    %ebp,%ebx
  800d40:	77 d2                	ja     800d14 <__udivdi3+0xd4>
  800d42:	b8 01 00 00 00       	mov    $0x1,%eax
  800d47:	eb cb                	jmp    800d14 <__udivdi3+0xd4>
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	89 d8                	mov    %ebx,%eax
  800d52:	31 ff                	xor    %edi,%edi
  800d54:	eb be                	jmp    800d14 <__udivdi3+0xd4>
  800d56:	66 90                	xchg   %ax,%ax
  800d58:	66 90                	xchg   %ax,%ax
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__umoddi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d77:	85 ed                	test   %ebp,%ebp
  800d79:	89 f0                	mov    %esi,%eax
  800d7b:	89 da                	mov    %ebx,%edx
  800d7d:	75 19                	jne    800d98 <__umoddi3+0x38>
  800d7f:	39 df                	cmp    %ebx,%edi
  800d81:	0f 86 b1 00 00 00    	jbe    800e38 <__umoddi3+0xd8>
  800d87:	f7 f7                	div    %edi
  800d89:	89 d0                	mov    %edx,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	83 c4 1c             	add    $0x1c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	39 dd                	cmp    %ebx,%ebp
  800d9a:	77 f1                	ja     800d8d <__umoddi3+0x2d>
  800d9c:	0f bd cd             	bsr    %ebp,%ecx
  800d9f:	83 f1 1f             	xor    $0x1f,%ecx
  800da2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800da6:	0f 84 b4 00 00 00    	je     800e60 <__umoddi3+0x100>
  800dac:	b8 20 00 00 00       	mov    $0x20,%eax
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800db7:	29 c2                	sub    %eax,%edx
  800db9:	89 c1                	mov    %eax,%ecx
  800dbb:	89 f8                	mov    %edi,%eax
  800dbd:	d3 e5                	shl    %cl,%ebp
  800dbf:	89 d1                	mov    %edx,%ecx
  800dc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dc5:	d3 e8                	shr    %cl,%eax
  800dc7:	09 c5                	or     %eax,%ebp
  800dc9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dcd:	89 c1                	mov    %eax,%ecx
  800dcf:	d3 e7                	shl    %cl,%edi
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	d3 ef                	shr    %cl,%edi
  800ddb:	89 c1                	mov    %eax,%ecx
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	d3 e3                	shl    %cl,%ebx
  800de1:	89 d1                	mov    %edx,%ecx
  800de3:	89 fa                	mov    %edi,%edx
  800de5:	d3 e8                	shr    %cl,%eax
  800de7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dec:	09 d8                	or     %ebx,%eax
  800dee:	f7 f5                	div    %ebp
  800df0:	d3 e6                	shl    %cl,%esi
  800df2:	89 d1                	mov    %edx,%ecx
  800df4:	f7 64 24 08          	mull   0x8(%esp)
  800df8:	39 d1                	cmp    %edx,%ecx
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	72 06                	jb     800e06 <__umoddi3+0xa6>
  800e00:	75 0e                	jne    800e10 <__umoddi3+0xb0>
  800e02:	39 c6                	cmp    %eax,%esi
  800e04:	73 0a                	jae    800e10 <__umoddi3+0xb0>
  800e06:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e0a:	19 ea                	sbb    %ebp,%edx
  800e0c:	89 d7                	mov    %edx,%edi
  800e0e:	89 c3                	mov    %eax,%ebx
  800e10:	89 ca                	mov    %ecx,%edx
  800e12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e17:	29 de                	sub    %ebx,%esi
  800e19:	19 fa                	sbb    %edi,%edx
  800e1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e1f:	89 d0                	mov    %edx,%eax
  800e21:	d3 e0                	shl    %cl,%eax
  800e23:	89 d9                	mov    %ebx,%ecx
  800e25:	d3 ee                	shr    %cl,%esi
  800e27:	d3 ea                	shr    %cl,%edx
  800e29:	09 f0                	or     %esi,%eax
  800e2b:	83 c4 1c             	add    $0x1c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    
  800e33:	90                   	nop
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	85 ff                	test   %edi,%edi
  800e3a:	89 f9                	mov    %edi,%ecx
  800e3c:	75 0b                	jne    800e49 <__umoddi3+0xe9>
  800e3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e43:	31 d2                	xor    %edx,%edx
  800e45:	f7 f7                	div    %edi
  800e47:	89 c1                	mov    %eax,%ecx
  800e49:	89 d8                	mov    %ebx,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f1                	div    %ecx
  800e4f:	89 f0                	mov    %esi,%eax
  800e51:	f7 f1                	div    %ecx
  800e53:	e9 31 ff ff ff       	jmp    800d89 <__umoddi3+0x29>
  800e58:	90                   	nop
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	39 dd                	cmp    %ebx,%ebp
  800e62:	72 08                	jb     800e6c <__umoddi3+0x10c>
  800e64:	39 f7                	cmp    %esi,%edi
  800e66:	0f 87 21 ff ff ff    	ja     800d8d <__umoddi3+0x2d>
  800e6c:	89 da                	mov    %ebx,%edx
  800e6e:	89 f0                	mov    %esi,%eax
  800e70:	29 f8                	sub    %edi,%eax
  800e72:	19 ea                	sbb    %ebp,%edx
  800e74:	e9 14 ff ff ff       	jmp    800d8d <__umoddi3+0x2d>
