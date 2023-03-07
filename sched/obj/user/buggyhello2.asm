
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 ab 00 00 00       	call   8000f4 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800059:	e8 02 01 00 00       	call   800160 <sys_getenvid>
	if (id >= 0)
  80005e:	85 c0                	test   %eax,%eax
  800060:	78 12                	js     800074 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	c1 e0 07             	shl    $0x7,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 db                	test   %ebx,%ebx
  800076:	7e 07                	jle    80007f <libmain+0x31>
		binaryname = argv[0];
  800078:	8b 06                	mov    (%esi),%eax
  80007a:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	e8 aa ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800089:	e8 0a 00 00 00       	call   800098 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 99 00 00 00       	call   80013e <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 1c             	sub    $0x1c,%esp
  8000b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b9:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c4:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cd:	74 04                	je     8000d3 <syscall+0x29>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f 08                	jg     8000db <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    
  8000db:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  8000de:	83 ec 0c             	sub    $0xc,%esp
  8000e1:	50                   	push   %eax
  8000e2:	52                   	push   %edx
  8000e3:	68 98 0e 80 00       	push   $0x800e98
  8000e8:	6a 23                	push   $0x23
  8000ea:	68 b5 0e 80 00       	push   $0x800eb5
  8000ef:	e8 b1 01 00 00       	call   8002a5 <_panic>

008000f4 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000fa:	6a 00                	push   $0x0
  8000fc:	6a 00                	push   $0x0
  8000fe:	6a 00                	push   $0x0
  800100:	ff 75 0c             	pushl  0xc(%ebp)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	ba 00 00 00 00       	mov    $0x0,%edx
  80010b:	b8 00 00 00 00       	mov    $0x0,%eax
  800110:	e8 95 ff ff ff       	call   8000aa <syscall>
}
  800115:	83 c4 10             	add    $0x10,%esp
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <sys_cgetc>:

int
sys_cgetc(void)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800120:	6a 00                	push   $0x0
  800122:	6a 00                	push   $0x0
  800124:	6a 00                	push   $0x0
  800126:	6a 00                	push   $0x0
  800128:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012d:	ba 00 00 00 00       	mov    $0x0,%edx
  800132:	b8 01 00 00 00       	mov    $0x1,%eax
  800137:	e8 6e ff ff ff       	call   8000aa <syscall>
}
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800144:	6a 00                	push   $0x0
  800146:	6a 00                	push   $0x0
  800148:	6a 00                	push   $0x0
  80014a:	6a 00                	push   $0x0
  80014c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014f:	ba 01 00 00 00       	mov    $0x1,%edx
  800154:	b8 03 00 00 00       	mov    $0x3,%eax
  800159:	e8 4c ff ff ff       	call   8000aa <syscall>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800166:	6a 00                	push   $0x0
  800168:	6a 00                	push   $0x0
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800173:	ba 00 00 00 00       	mov    $0x0,%edx
  800178:	b8 02 00 00 00       	mov    $0x2,%eax
  80017d:	e8 28 ff ff ff       	call   8000aa <syscall>
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <sys_yield>:

void
sys_yield(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80018a:	6a 00                	push   $0x0
  80018c:	6a 00                	push   $0x0
  80018e:	6a 00                	push   $0x0
  800190:	6a 00                	push   $0x0
  800192:	b9 00 00 00 00       	mov    $0x0,%ecx
  800197:	ba 00 00 00 00       	mov    $0x0,%edx
  80019c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001a1:	e8 04 ff ff ff       	call   8000aa <syscall>
}
  8001a6:	83 c4 10             	add    $0x10,%esp
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001b1:	6a 00                	push   $0x0
  8001b3:	6a 00                	push   $0x0
  8001b5:	ff 75 10             	pushl  0x10(%ebp)
  8001b8:	ff 75 0c             	pushl  0xc(%ebp)
  8001bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001be:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c8:	e8 dd fe ff ff       	call   8000aa <syscall>
}
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001d5:	ff 75 18             	pushl  0x18(%ebp)
  8001d8:	ff 75 14             	pushl  0x14(%ebp)
  8001db:	ff 75 10             	pushl  0x10(%ebp)
  8001de:	ff 75 0c             	pushl  0xc(%ebp)
  8001e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e4:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ee:	e8 b7 fe ff ff       	call   8000aa <syscall>
}
  8001f3:	c9                   	leave  
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001fb:	6a 00                	push   $0x0
  8001fd:	6a 00                	push   $0x0
  8001ff:	6a 00                	push   $0x0
  800201:	ff 75 0c             	pushl  0xc(%ebp)
  800204:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800207:	ba 01 00 00 00       	mov    $0x1,%edx
  80020c:	b8 06 00 00 00       	mov    $0x6,%eax
  800211:	e8 94 fe ff ff       	call   8000aa <syscall>
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80021e:	6a 00                	push   $0x0
  800220:	6a 00                	push   $0x0
  800222:	6a 00                	push   $0x0
  800224:	ff 75 0c             	pushl  0xc(%ebp)
  800227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022a:	ba 01 00 00 00       	mov    $0x1,%edx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	e8 71 fe ff ff       	call   8000aa <syscall>
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800241:	6a 00                	push   $0x0
  800243:	6a 00                	push   $0x0
  800245:	6a 00                	push   $0x0
  800247:	ff 75 0c             	pushl  0xc(%ebp)
  80024a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024d:	ba 01 00 00 00       	mov    $0x1,%edx
  800252:	b8 09 00 00 00       	mov    $0x9,%eax
  800257:	e8 4e fe ff ff       	call   8000aa <syscall>
}
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    

0080025e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800264:	6a 00                	push   $0x0
  800266:	ff 75 14             	pushl  0x14(%ebp)
  800269:	ff 75 10             	pushl  0x10(%ebp)
  80026c:	ff 75 0c             	pushl  0xc(%ebp)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	ba 00 00 00 00       	mov    $0x0,%edx
  800277:	b8 0b 00 00 00       	mov    $0xb,%eax
  80027c:	e8 29 fe ff ff       	call   8000aa <syscall>
}
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800289:	6a 00                	push   $0x0
  80028b:	6a 00                	push   $0x0
  80028d:	6a 00                	push   $0x0
  80028f:	6a 00                	push   $0x0
  800291:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800294:	ba 01 00 00 00       	mov    $0x1,%edx
  800299:	b8 0c 00 00 00       	mov    $0xc,%eax
  80029e:	e8 07 fe ff ff       	call   8000aa <syscall>
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002aa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ad:	8b 35 04 20 80 00    	mov    0x802004,%esi
  8002b3:	e8 a8 fe ff ff       	call   800160 <sys_getenvid>
  8002b8:	83 ec 0c             	sub    $0xc,%esp
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	56                   	push   %esi
  8002c2:	50                   	push   %eax
  8002c3:	68 c4 0e 80 00       	push   $0x800ec4
  8002c8:	e8 b3 00 00 00       	call   800380 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002cd:	83 c4 18             	add    $0x18,%esp
  8002d0:	53                   	push   %ebx
  8002d1:	ff 75 10             	pushl  0x10(%ebp)
  8002d4:	e8 56 00 00 00       	call   80032f <vcprintf>
	cprintf("\n");
  8002d9:	c7 04 24 8c 0e 80 00 	movl   $0x800e8c,(%esp)
  8002e0:	e8 9b 00 00 00       	call   800380 <cprintf>
  8002e5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e8:	cc                   	int3   
  8002e9:	eb fd                	jmp    8002e8 <_panic+0x43>

008002eb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	53                   	push   %ebx
  8002ef:	83 ec 04             	sub    $0x4,%esp
  8002f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f5:	8b 13                	mov    (%ebx),%edx
  8002f7:	8d 42 01             	lea    0x1(%edx),%eax
  8002fa:	89 03                	mov    %eax,(%ebx)
  8002fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800303:	3d ff 00 00 00       	cmp    $0xff,%eax
  800308:	74 09                	je     800313 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80030a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80030e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800311:	c9                   	leave  
  800312:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800313:	83 ec 08             	sub    $0x8,%esp
  800316:	68 ff 00 00 00       	push   $0xff
  80031b:	8d 43 08             	lea    0x8(%ebx),%eax
  80031e:	50                   	push   %eax
  80031f:	e8 d0 fd ff ff       	call   8000f4 <sys_cputs>
		b->idx = 0;
  800324:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80032a:	83 c4 10             	add    $0x10,%esp
  80032d:	eb db                	jmp    80030a <putch+0x1f>

0080032f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800338:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033f:	00 00 00 
	b.cnt = 0;
  800342:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800349:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80034c:	ff 75 0c             	pushl  0xc(%ebp)
  80034f:	ff 75 08             	pushl  0x8(%ebp)
  800352:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800358:	50                   	push   %eax
  800359:	68 eb 02 80 00       	push   $0x8002eb
  80035e:	e8 86 01 00 00       	call   8004e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800363:	83 c4 08             	add    $0x8,%esp
  800366:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80036c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800372:	50                   	push   %eax
  800373:	e8 7c fd ff ff       	call   8000f4 <sys_cputs>

	return b.cnt;
}
  800378:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800386:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800389:	50                   	push   %eax
  80038a:	ff 75 08             	pushl  0x8(%ebp)
  80038d:	e8 9d ff ff ff       	call   80032f <vcprintf>
	va_end(ap);

	return cnt;
}
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 1c             	sub    $0x1c,%esp
  80039d:	89 c7                	mov    %eax,%edi
  80039f:	89 d6                	mov    %edx,%esi
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003b8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003bb:	39 d3                	cmp    %edx,%ebx
  8003bd:	72 05                	jb     8003c4 <printnum+0x30>
  8003bf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003c2:	77 7a                	ja     80043e <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003c4:	83 ec 0c             	sub    $0xc,%esp
  8003c7:	ff 75 18             	pushl  0x18(%ebp)
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003d0:	53                   	push   %ebx
  8003d1:	ff 75 10             	pushl  0x10(%ebp)
  8003d4:	83 ec 08             	sub    $0x8,%esp
  8003d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003da:	ff 75 e0             	pushl  -0x20(%ebp)
  8003dd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e3:	e8 48 08 00 00       	call   800c30 <__udivdi3>
  8003e8:	83 c4 18             	add    $0x18,%esp
  8003eb:	52                   	push   %edx
  8003ec:	50                   	push   %eax
  8003ed:	89 f2                	mov    %esi,%edx
  8003ef:	89 f8                	mov    %edi,%eax
  8003f1:	e8 9e ff ff ff       	call   800394 <printnum>
  8003f6:	83 c4 20             	add    $0x20,%esp
  8003f9:	eb 13                	jmp    80040e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	56                   	push   %esi
  8003ff:	ff 75 18             	pushl  0x18(%ebp)
  800402:	ff d7                	call   *%edi
  800404:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800407:	83 eb 01             	sub    $0x1,%ebx
  80040a:	85 db                	test   %ebx,%ebx
  80040c:	7f ed                	jg     8003fb <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	56                   	push   %esi
  800412:	83 ec 04             	sub    $0x4,%esp
  800415:	ff 75 e4             	pushl  -0x1c(%ebp)
  800418:	ff 75 e0             	pushl  -0x20(%ebp)
  80041b:	ff 75 dc             	pushl  -0x24(%ebp)
  80041e:	ff 75 d8             	pushl  -0x28(%ebp)
  800421:	e8 2a 09 00 00       	call   800d50 <__umoddi3>
  800426:	83 c4 14             	add    $0x14,%esp
  800429:	0f be 80 e8 0e 80 00 	movsbl 0x800ee8(%eax),%eax
  800430:	50                   	push   %eax
  800431:	ff d7                	call   *%edi
}
  800433:	83 c4 10             	add    $0x10,%esp
  800436:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800439:	5b                   	pop    %ebx
  80043a:	5e                   	pop    %esi
  80043b:	5f                   	pop    %edi
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    
  80043e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800441:	eb c4                	jmp    800407 <printnum+0x73>

00800443 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800443:	55                   	push   %ebp
  800444:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800446:	83 fa 01             	cmp    $0x1,%edx
  800449:	7e 0e                	jle    800459 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80044b:	8b 10                	mov    (%eax),%edx
  80044d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800450:	89 08                	mov    %ecx,(%eax)
  800452:	8b 02                	mov    (%edx),%eax
  800454:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800457:	5d                   	pop    %ebp
  800458:	c3                   	ret    
	else if (lflag)
  800459:	85 d2                	test   %edx,%edx
  80045b:	75 10                	jne    80046d <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  80045d:	8b 10                	mov    (%eax),%edx
  80045f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800462:	89 08                	mov    %ecx,(%eax)
  800464:	8b 02                	mov    (%edx),%eax
  800466:	ba 00 00 00 00       	mov    $0x0,%edx
  80046b:	eb ea                	jmp    800457 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  80046d:	8b 10                	mov    (%eax),%edx
  80046f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800472:	89 08                	mov    %ecx,(%eax)
  800474:	8b 02                	mov    (%edx),%eax
  800476:	ba 00 00 00 00       	mov    $0x0,%edx
  80047b:	eb da                	jmp    800457 <getuint+0x14>

0080047d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800480:	83 fa 01             	cmp    $0x1,%edx
  800483:	7e 0e                	jle    800493 <getint+0x16>
		return va_arg(*ap, long long);
  800485:	8b 10                	mov    (%eax),%edx
  800487:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048a:	89 08                	mov    %ecx,(%eax)
  80048c:	8b 02                	mov    (%edx),%eax
  80048e:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800491:	5d                   	pop    %ebp
  800492:	c3                   	ret    
	else if (lflag)
  800493:	85 d2                	test   %edx,%edx
  800495:	75 0c                	jne    8004a3 <getint+0x26>
		return va_arg(*ap, int);
  800497:	8b 10                	mov    (%eax),%edx
  800499:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049c:	89 08                	mov    %ecx,(%eax)
  80049e:	8b 02                	mov    (%edx),%eax
  8004a0:	99                   	cltd   
  8004a1:	eb ee                	jmp    800491 <getint+0x14>
		return va_arg(*ap, long);
  8004a3:	8b 10                	mov    (%eax),%edx
  8004a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a8:	89 08                	mov    %ecx,(%eax)
  8004aa:	8b 02                	mov    (%edx),%eax
  8004ac:	99                   	cltd   
  8004ad:	eb e2                	jmp    800491 <getint+0x14>

008004af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b9:	8b 10                	mov    (%eax),%edx
  8004bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8004be:	73 0a                	jae    8004ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c3:	89 08                	mov    %ecx,(%eax)
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c8:	88 02                	mov    %al,(%edx)
}
  8004ca:	5d                   	pop    %ebp
  8004cb:	c3                   	ret    

008004cc <printfmt>:
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d5:	50                   	push   %eax
  8004d6:	ff 75 10             	pushl  0x10(%ebp)
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	ff 75 08             	pushl  0x8(%ebp)
  8004df:	e8 05 00 00 00       	call   8004e9 <vprintfmt>
}
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	c9                   	leave  
  8004e8:	c3                   	ret    

008004e9 <vprintfmt>:
{
  8004e9:	55                   	push   %ebp
  8004ea:	89 e5                	mov    %esp,%ebp
  8004ec:	57                   	push   %edi
  8004ed:	56                   	push   %esi
  8004ee:	53                   	push   %ebx
  8004ef:	83 ec 2c             	sub    $0x2c,%esp
  8004f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004f8:	89 f7                	mov    %esi,%edi
  8004fa:	89 de                	mov    %ebx,%esi
  8004fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004ff:	e9 9e 02 00 00       	jmp    8007a2 <vprintfmt+0x2b9>
		padc = ' ';
  800504:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800508:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80050f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800516:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80051d:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800522:	8d 43 01             	lea    0x1(%ebx),%eax
  800525:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800528:	0f b6 0b             	movzbl (%ebx),%ecx
  80052b:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80052e:	3c 55                	cmp    $0x55,%al
  800530:	0f 87 e8 02 00 00    	ja     80081e <vprintfmt+0x335>
  800536:	0f b6 c0             	movzbl %al,%eax
  800539:	ff 24 85 a0 0f 80 00 	jmp    *0x800fa0(,%eax,4)
  800540:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800543:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800547:	eb d9                	jmp    800522 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  80054c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800550:	eb d0                	jmp    800522 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800552:	0f b6 c9             	movzbl %cl,%ecx
  800555:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800558:	b8 00 00 00 00       	mov    $0x0,%eax
  80055d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800560:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800563:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800567:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80056a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80056d:	83 fa 09             	cmp    $0x9,%edx
  800570:	77 52                	ja     8005c4 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800572:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800575:	eb e9                	jmp    800560 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 48 04             	lea    0x4(%eax),%ecx
  80057d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800588:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058c:	79 94                	jns    800522 <vprintfmt+0x39>
				width = precision, precision = -1;
  80058e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800591:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800594:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059b:	eb 85                	jmp    800522 <vprintfmt+0x39>
  80059d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a0:	85 c0                	test   %eax,%eax
  8005a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a7:	0f 49 c8             	cmovns %eax,%ecx
  8005aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005b0:	e9 6d ff ff ff       	jmp    800522 <vprintfmt+0x39>
  8005b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8005b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005bf:	e9 5e ff ff ff       	jmp    800522 <vprintfmt+0x39>
  8005c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ca:	eb bc                	jmp    800588 <vprintfmt+0x9f>
			lflag++;
  8005cc:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8005d2:	e9 4b ff ff ff       	jmp    800522 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 50 04             	lea    0x4(%eax),%edx
  8005dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	57                   	push   %edi
  8005e4:	ff 30                	pushl  (%eax)
  8005e6:	ff d6                	call   *%esi
			break;
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	e9 af 01 00 00       	jmp    80079f <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 50 04             	lea    0x4(%eax),%edx
  8005f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f9:	8b 00                	mov    (%eax),%eax
  8005fb:	99                   	cltd   
  8005fc:	31 d0                	xor    %edx,%eax
  8005fe:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800600:	83 f8 08             	cmp    $0x8,%eax
  800603:	7f 20                	jg     800625 <vprintfmt+0x13c>
  800605:	8b 14 85 00 11 80 00 	mov    0x801100(,%eax,4),%edx
  80060c:	85 d2                	test   %edx,%edx
  80060e:	74 15                	je     800625 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800610:	52                   	push   %edx
  800611:	68 09 0f 80 00       	push   $0x800f09
  800616:	57                   	push   %edi
  800617:	56                   	push   %esi
  800618:	e8 af fe ff ff       	call   8004cc <printfmt>
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	e9 7a 01 00 00       	jmp    80079f <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800625:	50                   	push   %eax
  800626:	68 00 0f 80 00       	push   $0x800f00
  80062b:	57                   	push   %edi
  80062c:	56                   	push   %esi
  80062d:	e8 9a fe ff ff       	call   8004cc <printfmt>
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	e9 65 01 00 00       	jmp    80079f <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800645:	85 db                	test   %ebx,%ebx
  800647:	b8 f9 0e 80 00       	mov    $0x800ef9,%eax
  80064c:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  80064f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800653:	0f 8e bd 00 00 00    	jle    800716 <vprintfmt+0x22d>
  800659:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80065d:	75 0e                	jne    80066d <vprintfmt+0x184>
  80065f:	89 75 08             	mov    %esi,0x8(%ebp)
  800662:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800665:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800668:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80066b:	eb 6d                	jmp    8006da <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	ff 75 d0             	pushl  -0x30(%ebp)
  800673:	53                   	push   %ebx
  800674:	e8 4d 02 00 00       	call   8008c6 <strnlen>
  800679:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80067c:	29 c1                	sub    %eax,%ecx
  80067e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800681:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800684:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800688:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80068b:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80068e:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800690:	eb 0f                	jmp    8006a1 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	57                   	push   %edi
  800696:	ff 75 e0             	pushl  -0x20(%ebp)
  800699:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80069b:	83 eb 01             	sub    $0x1,%ebx
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	85 db                	test   %ebx,%ebx
  8006a3:	7f ed                	jg     800692 <vprintfmt+0x1a9>
  8006a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006a8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006ab:	85 c9                	test   %ecx,%ecx
  8006ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b2:	0f 49 c1             	cmovns %ecx,%eax
  8006b5:	29 c1                	sub    %eax,%ecx
  8006b7:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ba:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006bd:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006c0:	89 cf                	mov    %ecx,%edi
  8006c2:	eb 16                	jmp    8006da <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8006c4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c8:	75 31                	jne    8006fb <vprintfmt+0x212>
					putch(ch, putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	ff 75 0c             	pushl  0xc(%ebp)
  8006d0:	50                   	push   %eax
  8006d1:	ff 55 08             	call   *0x8(%ebp)
  8006d4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d7:	83 ef 01             	sub    $0x1,%edi
  8006da:	83 c3 01             	add    $0x1,%ebx
  8006dd:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8006e1:	0f be c2             	movsbl %dl,%eax
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 50                	je     800738 <vprintfmt+0x24f>
  8006e8:	85 f6                	test   %esi,%esi
  8006ea:	78 d8                	js     8006c4 <vprintfmt+0x1db>
  8006ec:	83 ee 01             	sub    $0x1,%esi
  8006ef:	79 d3                	jns    8006c4 <vprintfmt+0x1db>
  8006f1:	89 fb                	mov    %edi,%ebx
  8006f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006f9:	eb 37                	jmp    800732 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8006fb:	0f be d2             	movsbl %dl,%edx
  8006fe:	83 ea 20             	sub    $0x20,%edx
  800701:	83 fa 5e             	cmp    $0x5e,%edx
  800704:	76 c4                	jbe    8006ca <vprintfmt+0x1e1>
					putch('?', putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	ff 75 0c             	pushl  0xc(%ebp)
  80070c:	6a 3f                	push   $0x3f
  80070e:	ff 55 08             	call   *0x8(%ebp)
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	eb c1                	jmp    8006d7 <vprintfmt+0x1ee>
  800716:	89 75 08             	mov    %esi,0x8(%ebp)
  800719:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071c:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80071f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800722:	eb b6                	jmp    8006da <vprintfmt+0x1f1>
				putch(' ', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	57                   	push   %edi
  800728:	6a 20                	push   $0x20
  80072a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80072c:	83 eb 01             	sub    $0x1,%ebx
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 db                	test   %ebx,%ebx
  800734:	7f ee                	jg     800724 <vprintfmt+0x23b>
  800736:	eb 67                	jmp    80079f <vprintfmt+0x2b6>
  800738:	89 fb                	mov    %edi,%ebx
  80073a:	8b 75 08             	mov    0x8(%ebp),%esi
  80073d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800740:	eb f0                	jmp    800732 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
  800745:	e8 33 fd ff ff       	call   80047d <getint>
  80074a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800750:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800755:	85 d2                	test   %edx,%edx
  800757:	79 2c                	jns    800785 <vprintfmt+0x29c>
				putch('-', putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	57                   	push   %edi
  80075d:	6a 2d                	push   $0x2d
  80075f:	ff d6                	call   *%esi
				num = -(long long) num;
  800761:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800764:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800767:	f7 d8                	neg    %eax
  800769:	83 d2 00             	adc    $0x0,%edx
  80076c:	f7 da                	neg    %edx
  80076e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800771:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800776:	eb 0d                	jmp    800785 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800778:	8d 45 14             	lea    0x14(%ebp),%eax
  80077b:	e8 c3 fc ff ff       	call   800443 <getuint>
			base = 10;
  800780:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800785:	83 ec 0c             	sub    $0xc,%esp
  800788:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80078c:	53                   	push   %ebx
  80078d:	ff 75 e0             	pushl  -0x20(%ebp)
  800790:	51                   	push   %ecx
  800791:	52                   	push   %edx
  800792:	50                   	push   %eax
  800793:	89 fa                	mov    %edi,%edx
  800795:	89 f0                	mov    %esi,%eax
  800797:	e8 f8 fb ff ff       	call   800394 <printnum>
			break;
  80079c:	83 c4 20             	add    $0x20,%esp
{
  80079f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a2:	83 c3 01             	add    $0x1,%ebx
  8007a5:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8007a9:	83 f8 25             	cmp    $0x25,%eax
  8007ac:	0f 84 52 fd ff ff    	je     800504 <vprintfmt+0x1b>
			if (ch == '\0')
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	0f 84 84 00 00 00    	je     80083e <vprintfmt+0x355>
			putch(ch, putdat);
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	57                   	push   %edi
  8007be:	50                   	push   %eax
  8007bf:	ff d6                	call   *%esi
  8007c1:	83 c4 10             	add    $0x10,%esp
  8007c4:	eb dc                	jmp    8007a2 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 75 fc ff ff       	call   800443 <getuint>
			base = 8;
  8007ce:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007d3:	eb b0                	jmp    800785 <vprintfmt+0x29c>
			putch('0', putdat);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	57                   	push   %edi
  8007d9:	6a 30                	push   $0x30
  8007db:	ff d6                	call   *%esi
			putch('x', putdat);
  8007dd:	83 c4 08             	add    $0x8,%esp
  8007e0:	57                   	push   %edi
  8007e1:	6a 78                	push   $0x78
  8007e3:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8d 50 04             	lea    0x4(%eax),%edx
  8007eb:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007ee:	8b 00                	mov    (%eax),%eax
  8007f0:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8007f5:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007f8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007fd:	eb 86                	jmp    800785 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800802:	e8 3c fc ff ff       	call   800443 <getuint>
			base = 16;
  800807:	b9 10 00 00 00       	mov    $0x10,%ecx
  80080c:	e9 74 ff ff ff       	jmp    800785 <vprintfmt+0x29c>
			putch(ch, putdat);
  800811:	83 ec 08             	sub    $0x8,%esp
  800814:	57                   	push   %edi
  800815:	6a 25                	push   $0x25
  800817:	ff d6                	call   *%esi
			break;
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	eb 81                	jmp    80079f <vprintfmt+0x2b6>
			putch('%', putdat);
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	57                   	push   %edi
  800822:	6a 25                	push   $0x25
  800824:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	89 d8                	mov    %ebx,%eax
  80082b:	eb 03                	jmp    800830 <vprintfmt+0x347>
  80082d:	83 e8 01             	sub    $0x1,%eax
  800830:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800834:	75 f7                	jne    80082d <vprintfmt+0x344>
  800836:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800839:	e9 61 ff ff ff       	jmp    80079f <vprintfmt+0x2b6>
}
  80083e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800841:	5b                   	pop    %ebx
  800842:	5e                   	pop    %esi
  800843:	5f                   	pop    %edi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 18             	sub    $0x18,%esp
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800852:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800855:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800859:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800863:	85 c0                	test   %eax,%eax
  800865:	74 26                	je     80088d <vsnprintf+0x47>
  800867:	85 d2                	test   %edx,%edx
  800869:	7e 22                	jle    80088d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086b:	ff 75 14             	pushl  0x14(%ebp)
  80086e:	ff 75 10             	pushl  0x10(%ebp)
  800871:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	68 af 04 80 00       	push   $0x8004af
  80087a:	e8 6a fc ff ff       	call   8004e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800882:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800888:	83 c4 10             	add    $0x10,%esp
}
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    
		return -E_INVAL;
  80088d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800892:	eb f7                	jmp    80088b <vsnprintf+0x45>

00800894 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089d:	50                   	push   %eax
  80089e:	ff 75 10             	pushl  0x10(%ebp)
  8008a1:	ff 75 0c             	pushl  0xc(%ebp)
  8008a4:	ff 75 08             	pushl  0x8(%ebp)
  8008a7:	e8 9a ff ff ff       	call   800846 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b9:	eb 03                	jmp    8008be <strlen+0x10>
		n++;
  8008bb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c2:	75 f7                	jne    8008bb <strlen+0xd>
	return n;
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	eb 03                	jmp    8008d9 <strnlen+0x13>
		n++;
  8008d6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d9:	39 d0                	cmp    %edx,%eax
  8008db:	74 06                	je     8008e3 <strnlen+0x1d>
  8008dd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e1:	75 f3                	jne    8008d6 <strnlen+0x10>
	return n;
}
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	53                   	push   %ebx
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ef:	89 c2                	mov    %eax,%edx
  8008f1:	83 c1 01             	add    $0x1,%ecx
  8008f4:	83 c2 01             	add    $0x1,%edx
  8008f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fe:	84 db                	test   %bl,%bl
  800900:	75 ef                	jne    8008f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800902:	5b                   	pop    %ebx
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	53                   	push   %ebx
  800909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090c:	53                   	push   %ebx
  80090d:	e8 9c ff ff ff       	call   8008ae <strlen>
  800912:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	01 d8                	add    %ebx,%eax
  80091a:	50                   	push   %eax
  80091b:	e8 c5 ff ff ff       	call   8008e5 <strcpy>
	return dst;
}
  800920:	89 d8                	mov    %ebx,%eax
  800922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 75 08             	mov    0x8(%ebp),%esi
  80092f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800932:	89 f3                	mov    %esi,%ebx
  800934:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800937:	89 f2                	mov    %esi,%edx
  800939:	eb 0f                	jmp    80094a <strncpy+0x23>
		*dst++ = *src;
  80093b:	83 c2 01             	add    $0x1,%edx
  80093e:	0f b6 01             	movzbl (%ecx),%eax
  800941:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800944:	80 39 01             	cmpb   $0x1,(%ecx)
  800947:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80094a:	39 da                	cmp    %ebx,%edx
  80094c:	75 ed                	jne    80093b <strncpy+0x14>
	}
	return ret;
}
  80094e:	89 f0                	mov    %esi,%eax
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	8b 75 08             	mov    0x8(%ebp),%esi
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800962:	89 f0                	mov    %esi,%eax
  800964:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800968:	85 c9                	test   %ecx,%ecx
  80096a:	75 0b                	jne    800977 <strlcpy+0x23>
  80096c:	eb 17                	jmp    800985 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096e:	83 c2 01             	add    $0x1,%edx
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800977:	39 d8                	cmp    %ebx,%eax
  800979:	74 07                	je     800982 <strlcpy+0x2e>
  80097b:	0f b6 0a             	movzbl (%edx),%ecx
  80097e:	84 c9                	test   %cl,%cl
  800980:	75 ec                	jne    80096e <strlcpy+0x1a>
		*dst = '\0';
  800982:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800985:	29 f0                	sub    %esi,%eax
}
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800994:	eb 06                	jmp    80099c <strcmp+0x11>
		p++, q++;
  800996:	83 c1 01             	add    $0x1,%ecx
  800999:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80099c:	0f b6 01             	movzbl (%ecx),%eax
  80099f:	84 c0                	test   %al,%al
  8009a1:	74 04                	je     8009a7 <strcmp+0x1c>
  8009a3:	3a 02                	cmp    (%edx),%al
  8009a5:	74 ef                	je     800996 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a7:	0f b6 c0             	movzbl %al,%eax
  8009aa:	0f b6 12             	movzbl (%edx),%edx
  8009ad:	29 d0                	sub    %edx,%eax
}
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	53                   	push   %ebx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	89 c3                	mov    %eax,%ebx
  8009bd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c0:	eb 06                	jmp    8009c8 <strncmp+0x17>
		n--, p++, q++;
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c8:	39 d8                	cmp    %ebx,%eax
  8009ca:	74 16                	je     8009e2 <strncmp+0x31>
  8009cc:	0f b6 08             	movzbl (%eax),%ecx
  8009cf:	84 c9                	test   %cl,%cl
  8009d1:	74 04                	je     8009d7 <strncmp+0x26>
  8009d3:	3a 0a                	cmp    (%edx),%cl
  8009d5:	74 eb                	je     8009c2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d7:	0f b6 00             	movzbl (%eax),%eax
  8009da:	0f b6 12             	movzbl (%edx),%edx
  8009dd:	29 d0                	sub    %edx,%eax
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    
		return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e7:	eb f6                	jmp    8009df <strncmp+0x2e>

008009e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f3:	0f b6 10             	movzbl (%eax),%edx
  8009f6:	84 d2                	test   %dl,%dl
  8009f8:	74 09                	je     800a03 <strchr+0x1a>
		if (*s == c)
  8009fa:	38 ca                	cmp    %cl,%dl
  8009fc:	74 0a                	je     800a08 <strchr+0x1f>
	for (; *s; s++)
  8009fe:	83 c0 01             	add    $0x1,%eax
  800a01:	eb f0                	jmp    8009f3 <strchr+0xa>
			return (char *) s;
	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a14:	eb 03                	jmp    800a19 <strfind+0xf>
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	74 04                	je     800a24 <strfind+0x1a>
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 f2                	jne    800a16 <strfind+0xc>
			break;
	return (char *) s;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a32:	85 c9                	test   %ecx,%ecx
  800a34:	74 12                	je     800a48 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a36:	f6 c2 03             	test   $0x3,%dl
  800a39:	75 05                	jne    800a40 <memset+0x1a>
  800a3b:	f6 c1 03             	test   $0x3,%cl
  800a3e:	74 0f                	je     800a4f <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a40:	89 d7                	mov    %edx,%edi
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a45:	fc                   	cld    
  800a46:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a48:	89 d0                	mov    %edx,%eax
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    
		c &= 0xFF;
  800a4f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a53:	89 d8                	mov    %ebx,%eax
  800a55:	c1 e0 08             	shl    $0x8,%eax
  800a58:	89 df                	mov    %ebx,%edi
  800a5a:	c1 e7 18             	shl    $0x18,%edi
  800a5d:	89 de                	mov    %ebx,%esi
  800a5f:	c1 e6 10             	shl    $0x10,%esi
  800a62:	09 f7                	or     %esi,%edi
  800a64:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800a66:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a69:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a6b:	89 d7                	mov    %edx,%edi
  800a6d:	fc                   	cld    
  800a6e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a70:	eb d6                	jmp    800a48 <memset+0x22>

00800a72 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a80:	39 c6                	cmp    %eax,%esi
  800a82:	73 35                	jae    800ab9 <memmove+0x47>
  800a84:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a87:	39 c2                	cmp    %eax,%edx
  800a89:	76 2e                	jbe    800ab9 <memmove+0x47>
		s += n;
		d += n;
  800a8b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8e:	89 d6                	mov    %edx,%esi
  800a90:	09 fe                	or     %edi,%esi
  800a92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a98:	74 0c                	je     800aa6 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9a:	83 ef 01             	sub    $0x1,%edi
  800a9d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa0:	fd                   	std    
  800aa1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa3:	fc                   	cld    
  800aa4:	eb 21                	jmp    800ac7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	f6 c1 03             	test   $0x3,%cl
  800aa9:	75 ef                	jne    800a9a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aab:	83 ef 04             	sub    $0x4,%edi
  800aae:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab4:	fd                   	std    
  800ab5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab7:	eb ea                	jmp    800aa3 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab9:	89 f2                	mov    %esi,%edx
  800abb:	09 c2                	or     %eax,%edx
  800abd:	f6 c2 03             	test   $0x3,%dl
  800ac0:	74 09                	je     800acb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac2:	89 c7                	mov    %eax,%edi
  800ac4:	fc                   	cld    
  800ac5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acb:	f6 c1 03             	test   $0x3,%cl
  800ace:	75 f2                	jne    800ac2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	fc                   	cld    
  800ad6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad8:	eb ed                	jmp    800ac7 <memmove+0x55>

00800ada <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800add:	ff 75 10             	pushl  0x10(%ebp)
  800ae0:	ff 75 0c             	pushl  0xc(%ebp)
  800ae3:	ff 75 08             	pushl  0x8(%ebp)
  800ae6:	e8 87 ff ff ff       	call   800a72 <memmove>
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af8:	89 c6                	mov    %eax,%esi
  800afa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afd:	39 f0                	cmp    %esi,%eax
  800aff:	74 1c                	je     800b1d <memcmp+0x30>
		if (*s1 != *s2)
  800b01:	0f b6 08             	movzbl (%eax),%ecx
  800b04:	0f b6 1a             	movzbl (%edx),%ebx
  800b07:	38 d9                	cmp    %bl,%cl
  800b09:	75 08                	jne    800b13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b0b:	83 c0 01             	add    $0x1,%eax
  800b0e:	83 c2 01             	add    $0x1,%edx
  800b11:	eb ea                	jmp    800afd <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b13:	0f b6 c1             	movzbl %cl,%eax
  800b16:	0f b6 db             	movzbl %bl,%ebx
  800b19:	29 d8                	sub    %ebx,%eax
  800b1b:	eb 05                	jmp    800b22 <memcmp+0x35>
	}

	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b34:	39 d0                	cmp    %edx,%eax
  800b36:	73 09                	jae    800b41 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b38:	38 08                	cmp    %cl,(%eax)
  800b3a:	74 05                	je     800b41 <memfind+0x1b>
	for (; s < ends; s++)
  800b3c:	83 c0 01             	add    $0x1,%eax
  800b3f:	eb f3                	jmp    800b34 <memfind+0xe>
			break;
	return (void *) s;
}
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4f:	eb 03                	jmp    800b54 <strtol+0x11>
		s++;
  800b51:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b54:	0f b6 01             	movzbl (%ecx),%eax
  800b57:	3c 20                	cmp    $0x20,%al
  800b59:	74 f6                	je     800b51 <strtol+0xe>
  800b5b:	3c 09                	cmp    $0x9,%al
  800b5d:	74 f2                	je     800b51 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b5f:	3c 2b                	cmp    $0x2b,%al
  800b61:	74 2e                	je     800b91 <strtol+0x4e>
	int neg = 0;
  800b63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b68:	3c 2d                	cmp    $0x2d,%al
  800b6a:	74 2f                	je     800b9b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b72:	75 05                	jne    800b79 <strtol+0x36>
  800b74:	80 39 30             	cmpb   $0x30,(%ecx)
  800b77:	74 2c                	je     800ba5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b79:	85 db                	test   %ebx,%ebx
  800b7b:	75 0a                	jne    800b87 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b82:	80 39 30             	cmpb   $0x30,(%ecx)
  800b85:	74 28                	je     800baf <strtol+0x6c>
		base = 10;
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b8f:	eb 50                	jmp    800be1 <strtol+0x9e>
		s++;
  800b91:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b94:	bf 00 00 00 00       	mov    $0x0,%edi
  800b99:	eb d1                	jmp    800b6c <strtol+0x29>
		s++, neg = 1;
  800b9b:	83 c1 01             	add    $0x1,%ecx
  800b9e:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba3:	eb c7                	jmp    800b6c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba9:	74 0e                	je     800bb9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bab:	85 db                	test   %ebx,%ebx
  800bad:	75 d8                	jne    800b87 <strtol+0x44>
		s++, base = 8;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb7:	eb ce                	jmp    800b87 <strtol+0x44>
		s += 2, base = 16;
  800bb9:	83 c1 02             	add    $0x2,%ecx
  800bbc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc1:	eb c4                	jmp    800b87 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bc3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bc6:	89 f3                	mov    %esi,%ebx
  800bc8:	80 fb 19             	cmp    $0x19,%bl
  800bcb:	77 29                	ja     800bf6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bcd:	0f be d2             	movsbl %dl,%edx
  800bd0:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd6:	7d 30                	jge    800c08 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd8:	83 c1 01             	add    $0x1,%ecx
  800bdb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bdf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800be1:	0f b6 11             	movzbl (%ecx),%edx
  800be4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be7:	89 f3                	mov    %esi,%ebx
  800be9:	80 fb 09             	cmp    $0x9,%bl
  800bec:	77 d5                	ja     800bc3 <strtol+0x80>
			dig = *s - '0';
  800bee:	0f be d2             	movsbl %dl,%edx
  800bf1:	83 ea 30             	sub    $0x30,%edx
  800bf4:	eb dd                	jmp    800bd3 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bf6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf9:	89 f3                	mov    %esi,%ebx
  800bfb:	80 fb 19             	cmp    $0x19,%bl
  800bfe:	77 08                	ja     800c08 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c00:	0f be d2             	movsbl %dl,%edx
  800c03:	83 ea 37             	sub    $0x37,%edx
  800c06:	eb cb                	jmp    800bd3 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0c:	74 05                	je     800c13 <strtol+0xd0>
		*endptr = (char *) s;
  800c0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c11:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c13:	89 c2                	mov    %eax,%edx
  800c15:	f7 da                	neg    %edx
  800c17:	85 ff                	test   %edi,%edi
  800c19:	0f 45 c2             	cmovne %edx,%eax
}
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    
  800c21:	66 90                	xchg   %ax,%ax
  800c23:	66 90                	xchg   %ax,%ax
  800c25:	66 90                	xchg   %ax,%ax
  800c27:	66 90                	xchg   %ax,%ax
  800c29:	66 90                	xchg   %ax,%ax
  800c2b:	66 90                	xchg   %ax,%ax
  800c2d:	66 90                	xchg   %ax,%ax
  800c2f:	90                   	nop

00800c30 <__udivdi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 1c             	sub    $0x1c,%esp
  800c37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c47:	85 d2                	test   %edx,%edx
  800c49:	75 35                	jne    800c80 <__udivdi3+0x50>
  800c4b:	39 f3                	cmp    %esi,%ebx
  800c4d:	0f 87 bd 00 00 00    	ja     800d10 <__udivdi3+0xe0>
  800c53:	85 db                	test   %ebx,%ebx
  800c55:	89 d9                	mov    %ebx,%ecx
  800c57:	75 0b                	jne    800c64 <__udivdi3+0x34>
  800c59:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5e:	31 d2                	xor    %edx,%edx
  800c60:	f7 f3                	div    %ebx
  800c62:	89 c1                	mov    %eax,%ecx
  800c64:	31 d2                	xor    %edx,%edx
  800c66:	89 f0                	mov    %esi,%eax
  800c68:	f7 f1                	div    %ecx
  800c6a:	89 c6                	mov    %eax,%esi
  800c6c:	89 e8                	mov    %ebp,%eax
  800c6e:	89 f7                	mov    %esi,%edi
  800c70:	f7 f1                	div    %ecx
  800c72:	89 fa                	mov    %edi,%edx
  800c74:	83 c4 1c             	add    $0x1c,%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    
  800c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c80:	39 f2                	cmp    %esi,%edx
  800c82:	77 7c                	ja     800d00 <__udivdi3+0xd0>
  800c84:	0f bd fa             	bsr    %edx,%edi
  800c87:	83 f7 1f             	xor    $0x1f,%edi
  800c8a:	0f 84 98 00 00 00    	je     800d28 <__udivdi3+0xf8>
  800c90:	89 f9                	mov    %edi,%ecx
  800c92:	b8 20 00 00 00       	mov    $0x20,%eax
  800c97:	29 f8                	sub    %edi,%eax
  800c99:	d3 e2                	shl    %cl,%edx
  800c9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c9f:	89 c1                	mov    %eax,%ecx
  800ca1:	89 da                	mov    %ebx,%edx
  800ca3:	d3 ea                	shr    %cl,%edx
  800ca5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ca9:	09 d1                	or     %edx,%ecx
  800cab:	89 f2                	mov    %esi,%edx
  800cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb1:	89 f9                	mov    %edi,%ecx
  800cb3:	d3 e3                	shl    %cl,%ebx
  800cb5:	89 c1                	mov    %eax,%ecx
  800cb7:	d3 ea                	shr    %cl,%edx
  800cb9:	89 f9                	mov    %edi,%ecx
  800cbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cbf:	d3 e6                	shl    %cl,%esi
  800cc1:	89 eb                	mov    %ebp,%ebx
  800cc3:	89 c1                	mov    %eax,%ecx
  800cc5:	d3 eb                	shr    %cl,%ebx
  800cc7:	09 de                	or     %ebx,%esi
  800cc9:	89 f0                	mov    %esi,%eax
  800ccb:	f7 74 24 08          	divl   0x8(%esp)
  800ccf:	89 d6                	mov    %edx,%esi
  800cd1:	89 c3                	mov    %eax,%ebx
  800cd3:	f7 64 24 0c          	mull   0xc(%esp)
  800cd7:	39 d6                	cmp    %edx,%esi
  800cd9:	72 0c                	jb     800ce7 <__udivdi3+0xb7>
  800cdb:	89 f9                	mov    %edi,%ecx
  800cdd:	d3 e5                	shl    %cl,%ebp
  800cdf:	39 c5                	cmp    %eax,%ebp
  800ce1:	73 5d                	jae    800d40 <__udivdi3+0x110>
  800ce3:	39 d6                	cmp    %edx,%esi
  800ce5:	75 59                	jne    800d40 <__udivdi3+0x110>
  800ce7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cea:	31 ff                	xor    %edi,%edi
  800cec:	89 fa                	mov    %edi,%edx
  800cee:	83 c4 1c             	add    $0x1c,%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
  800cf6:	8d 76 00             	lea    0x0(%esi),%esi
  800cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d00:	31 ff                	xor    %edi,%edi
  800d02:	31 c0                	xor    %eax,%eax
  800d04:	89 fa                	mov    %edi,%edx
  800d06:	83 c4 1c             	add    $0x1c,%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    
  800d0e:	66 90                	xchg   %ax,%ax
  800d10:	31 ff                	xor    %edi,%edi
  800d12:	89 e8                	mov    %ebp,%eax
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	f7 f3                	div    %ebx
  800d18:	89 fa                	mov    %edi,%edx
  800d1a:	83 c4 1c             	add    $0x1c,%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
  800d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d28:	39 f2                	cmp    %esi,%edx
  800d2a:	72 06                	jb     800d32 <__udivdi3+0x102>
  800d2c:	31 c0                	xor    %eax,%eax
  800d2e:	39 eb                	cmp    %ebp,%ebx
  800d30:	77 d2                	ja     800d04 <__udivdi3+0xd4>
  800d32:	b8 01 00 00 00       	mov    $0x1,%eax
  800d37:	eb cb                	jmp    800d04 <__udivdi3+0xd4>
  800d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d40:	89 d8                	mov    %ebx,%eax
  800d42:	31 ff                	xor    %edi,%edi
  800d44:	eb be                	jmp    800d04 <__udivdi3+0xd4>
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__umoddi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
  800d57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d67:	85 ed                	test   %ebp,%ebp
  800d69:	89 f0                	mov    %esi,%eax
  800d6b:	89 da                	mov    %ebx,%edx
  800d6d:	75 19                	jne    800d88 <__umoddi3+0x38>
  800d6f:	39 df                	cmp    %ebx,%edi
  800d71:	0f 86 b1 00 00 00    	jbe    800e28 <__umoddi3+0xd8>
  800d77:	f7 f7                	div    %edi
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	83 c4 1c             	add    $0x1c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
  800d88:	39 dd                	cmp    %ebx,%ebp
  800d8a:	77 f1                	ja     800d7d <__umoddi3+0x2d>
  800d8c:	0f bd cd             	bsr    %ebp,%ecx
  800d8f:	83 f1 1f             	xor    $0x1f,%ecx
  800d92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d96:	0f 84 b4 00 00 00    	je     800e50 <__umoddi3+0x100>
  800d9c:	b8 20 00 00 00       	mov    $0x20,%eax
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800da7:	29 c2                	sub    %eax,%edx
  800da9:	89 c1                	mov    %eax,%ecx
  800dab:	89 f8                	mov    %edi,%eax
  800dad:	d3 e5                	shl    %cl,%ebp
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800db5:	d3 e8                	shr    %cl,%eax
  800db7:	09 c5                	or     %eax,%ebp
  800db9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dbd:	89 c1                	mov    %eax,%ecx
  800dbf:	d3 e7                	shl    %cl,%edi
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	d3 ef                	shr    %cl,%edi
  800dcb:	89 c1                	mov    %eax,%ecx
  800dcd:	89 f0                	mov    %esi,%eax
  800dcf:	d3 e3                	shl    %cl,%ebx
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 fa                	mov    %edi,%edx
  800dd5:	d3 e8                	shr    %cl,%eax
  800dd7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ddc:	09 d8                	or     %ebx,%eax
  800dde:	f7 f5                	div    %ebp
  800de0:	d3 e6                	shl    %cl,%esi
  800de2:	89 d1                	mov    %edx,%ecx
  800de4:	f7 64 24 08          	mull   0x8(%esp)
  800de8:	39 d1                	cmp    %edx,%ecx
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	72 06                	jb     800df6 <__umoddi3+0xa6>
  800df0:	75 0e                	jne    800e00 <__umoddi3+0xb0>
  800df2:	39 c6                	cmp    %eax,%esi
  800df4:	73 0a                	jae    800e00 <__umoddi3+0xb0>
  800df6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dfa:	19 ea                	sbb    %ebp,%edx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	89 c3                	mov    %eax,%ebx
  800e00:	89 ca                	mov    %ecx,%edx
  800e02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e07:	29 de                	sub    %ebx,%esi
  800e09:	19 fa                	sbb    %edi,%edx
  800e0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e0f:	89 d0                	mov    %edx,%eax
  800e11:	d3 e0                	shl    %cl,%eax
  800e13:	89 d9                	mov    %ebx,%ecx
  800e15:	d3 ee                	shr    %cl,%esi
  800e17:	d3 ea                	shr    %cl,%edx
  800e19:	09 f0                	or     %esi,%eax
  800e1b:	83 c4 1c             	add    $0x1c,%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    
  800e23:	90                   	nop
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	85 ff                	test   %edi,%edi
  800e2a:	89 f9                	mov    %edi,%ecx
  800e2c:	75 0b                	jne    800e39 <__umoddi3+0xe9>
  800e2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e33:	31 d2                	xor    %edx,%edx
  800e35:	f7 f7                	div    %edi
  800e37:	89 c1                	mov    %eax,%ecx
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	f7 f1                	div    %ecx
  800e3f:	89 f0                	mov    %esi,%eax
  800e41:	f7 f1                	div    %ecx
  800e43:	e9 31 ff ff ff       	jmp    800d79 <__umoddi3+0x29>
  800e48:	90                   	nop
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	39 dd                	cmp    %ebx,%ebp
  800e52:	72 08                	jb     800e5c <__umoddi3+0x10c>
  800e54:	39 f7                	cmp    %esi,%edi
  800e56:	0f 87 21 ff ff ff    	ja     800d7d <__umoddi3+0x2d>
  800e5c:	89 da                	mov    %ebx,%edx
  800e5e:	89 f0                	mov    %esi,%eax
  800e60:	29 f8                	sub    %edi,%eax
  800e62:	19 ea                	sbb    %ebp,%edx
  800e64:	e9 14 ff ff ff       	jmp    800d7d <__umoddi3+0x2d>
