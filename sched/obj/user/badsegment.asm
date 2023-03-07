
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800049:	e8 02 01 00 00       	call   800150 <sys_getenvid>
	if (id >= 0)
  80004e:	85 c0                	test   %eax,%eax
  800050:	78 12                	js     800064 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	c1 e0 07             	shl    $0x7,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x31>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 99 00 00 00       	call   80012e <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
  8000a0:	83 ec 1c             	sub    $0x1c,%esp
  8000a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000a9:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000b4:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000bd:	74 04                	je     8000c3 <syscall+0x29>
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f 08                	jg     8000cb <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c6:	5b                   	pop    %ebx
  8000c7:	5e                   	pop    %esi
  8000c8:	5f                   	pop    %edi
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    
  8000cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	50                   	push   %eax
  8000d2:	52                   	push   %edx
  8000d3:	68 6a 0e 80 00       	push   $0x800e6a
  8000d8:	6a 23                	push   $0x23
  8000da:	68 87 0e 80 00       	push   $0x800e87
  8000df:	e8 b1 01 00 00       	call   800295 <_panic>

008000e4 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000ea:	6a 00                	push   $0x0
  8000ec:	6a 00                	push   $0x0
  8000ee:	6a 00                	push   $0x0
  8000f0:	ff 75 0c             	pushl  0xc(%ebp)
  8000f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800100:	e8 95 ff ff ff       	call   80009a <syscall>
}
  800105:	83 c4 10             	add    $0x10,%esp
  800108:	c9                   	leave  
  800109:	c3                   	ret    

0080010a <sys_cgetc>:

int
sys_cgetc(void)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800110:	6a 00                	push   $0x0
  800112:	6a 00                	push   $0x0
  800114:	6a 00                	push   $0x0
  800116:	6a 00                	push   $0x0
  800118:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 01 00 00 00       	mov    $0x1,%eax
  800127:	e8 6e ff ff ff       	call   80009a <syscall>
}
  80012c:	c9                   	leave  
  80012d:	c3                   	ret    

0080012e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800134:	6a 00                	push   $0x0
  800136:	6a 00                	push   $0x0
  800138:	6a 00                	push   $0x0
  80013a:	6a 00                	push   $0x0
  80013c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013f:	ba 01 00 00 00       	mov    $0x1,%edx
  800144:	b8 03 00 00 00       	mov    $0x3,%eax
  800149:	e8 4c ff ff ff       	call   80009a <syscall>
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800156:	6a 00                	push   $0x0
  800158:	6a 00                	push   $0x0
  80015a:	6a 00                	push   $0x0
  80015c:	6a 00                	push   $0x0
  80015e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800163:	ba 00 00 00 00       	mov    $0x0,%edx
  800168:	b8 02 00 00 00       	mov    $0x2,%eax
  80016d:	e8 28 ff ff ff       	call   80009a <syscall>
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <sys_yield>:

void
sys_yield(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80017a:	6a 00                	push   $0x0
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	6a 00                	push   $0x0
  800182:	b9 00 00 00 00       	mov    $0x0,%ecx
  800187:	ba 00 00 00 00       	mov    $0x0,%edx
  80018c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800191:	e8 04 ff ff ff       	call   80009a <syscall>
}
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001a1:	6a 00                	push   $0x0
  8001a3:	6a 00                	push   $0x0
  8001a5:	ff 75 10             	pushl  0x10(%ebp)
  8001a8:	ff 75 0c             	pushl  0xc(%ebp)
  8001ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ae:	ba 01 00 00 00       	mov    $0x1,%edx
  8001b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b8:	e8 dd fe ff ff       	call   80009a <syscall>
}
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    

008001bf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001c5:	ff 75 18             	pushl  0x18(%ebp)
  8001c8:	ff 75 14             	pushl  0x14(%ebp)
  8001cb:	ff 75 10             	pushl  0x10(%ebp)
  8001ce:	ff 75 0c             	pushl  0xc(%ebp)
  8001d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d4:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8001de:	e8 b7 fe ff ff       	call   80009a <syscall>
}
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001eb:	6a 00                	push   $0x0
  8001ed:	6a 00                	push   $0x0
  8001ef:	6a 00                	push   $0x0
  8001f1:	ff 75 0c             	pushl  0xc(%ebp)
  8001f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f7:	ba 01 00 00 00       	mov    $0x1,%edx
  8001fc:	b8 06 00 00 00       	mov    $0x6,%eax
  800201:	e8 94 fe ff ff       	call   80009a <syscall>
}
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80020e:	6a 00                	push   $0x0
  800210:	6a 00                	push   $0x0
  800212:	6a 00                	push   $0x0
  800214:	ff 75 0c             	pushl  0xc(%ebp)
  800217:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021a:	ba 01 00 00 00       	mov    $0x1,%edx
  80021f:	b8 08 00 00 00       	mov    $0x8,%eax
  800224:	e8 71 fe ff ff       	call   80009a <syscall>
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800231:	6a 00                	push   $0x0
  800233:	6a 00                	push   $0x0
  800235:	6a 00                	push   $0x0
  800237:	ff 75 0c             	pushl  0xc(%ebp)
  80023a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023d:	ba 01 00 00 00       	mov    $0x1,%edx
  800242:	b8 09 00 00 00       	mov    $0x9,%eax
  800247:	e8 4e fe ff ff       	call   80009a <syscall>
}
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800254:	6a 00                	push   $0x0
  800256:	ff 75 14             	pushl  0x14(%ebp)
  800259:	ff 75 10             	pushl  0x10(%ebp)
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800262:	ba 00 00 00 00       	mov    $0x0,%edx
  800267:	b8 0b 00 00 00       	mov    $0xb,%eax
  80026c:	e8 29 fe ff ff       	call   80009a <syscall>
}
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800279:	6a 00                	push   $0x0
  80027b:	6a 00                	push   $0x0
  80027d:	6a 00                	push   $0x0
  80027f:	6a 00                	push   $0x0
  800281:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800284:	ba 01 00 00 00       	mov    $0x1,%edx
  800289:	b8 0c 00 00 00       	mov    $0xc,%eax
  80028e:	e8 07 fe ff ff       	call   80009a <syscall>
}
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80029d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002a3:	e8 a8 fe ff ff       	call   800150 <sys_getenvid>
  8002a8:	83 ec 0c             	sub    $0xc,%esp
  8002ab:	ff 75 0c             	pushl  0xc(%ebp)
  8002ae:	ff 75 08             	pushl  0x8(%ebp)
  8002b1:	56                   	push   %esi
  8002b2:	50                   	push   %eax
  8002b3:	68 98 0e 80 00       	push   $0x800e98
  8002b8:	e8 b3 00 00 00       	call   800370 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002bd:	83 c4 18             	add    $0x18,%esp
  8002c0:	53                   	push   %ebx
  8002c1:	ff 75 10             	pushl  0x10(%ebp)
  8002c4:	e8 56 00 00 00       	call   80031f <vcprintf>
	cprintf("\n");
  8002c9:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  8002d0:	e8 9b 00 00 00       	call   800370 <cprintf>
  8002d5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d8:	cc                   	int3   
  8002d9:	eb fd                	jmp    8002d8 <_panic+0x43>

008002db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	53                   	push   %ebx
  8002df:	83 ec 04             	sub    $0x4,%esp
  8002e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e5:	8b 13                	mov    (%ebx),%edx
  8002e7:	8d 42 01             	lea    0x1(%edx),%eax
  8002ea:	89 03                	mov    %eax,(%ebx)
  8002ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f8:	74 09                	je     800303 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002fa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800301:	c9                   	leave  
  800302:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	68 ff 00 00 00       	push   $0xff
  80030b:	8d 43 08             	lea    0x8(%ebx),%eax
  80030e:	50                   	push   %eax
  80030f:	e8 d0 fd ff ff       	call   8000e4 <sys_cputs>
		b->idx = 0;
  800314:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	eb db                	jmp    8002fa <putch+0x1f>

0080031f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800328:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032f:	00 00 00 
	b.cnt = 0;
  800332:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800339:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800348:	50                   	push   %eax
  800349:	68 db 02 80 00       	push   $0x8002db
  80034e:	e8 86 01 00 00       	call   8004d9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800353:	83 c4 08             	add    $0x8,%esp
  800356:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800362:	50                   	push   %eax
  800363:	e8 7c fd ff ff       	call   8000e4 <sys_cputs>

	return b.cnt;
}
  800368:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800376:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800379:	50                   	push   %eax
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 9d ff ff ff       	call   80031f <vcprintf>
	va_end(ap);

	return cnt;
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
  80038a:	83 ec 1c             	sub    $0x1c,%esp
  80038d:	89 c7                	mov    %eax,%edi
  80038f:	89 d6                	mov    %edx,%esi
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	8b 55 0c             	mov    0xc(%ebp),%edx
  800397:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ab:	39 d3                	cmp    %edx,%ebx
  8003ad:	72 05                	jb     8003b4 <printnum+0x30>
  8003af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b2:	77 7a                	ja     80042e <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b4:	83 ec 0c             	sub    $0xc,%esp
  8003b7:	ff 75 18             	pushl  0x18(%ebp)
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c0:	53                   	push   %ebx
  8003c1:	ff 75 10             	pushl  0x10(%ebp)
  8003c4:	83 ec 08             	sub    $0x8,%esp
  8003c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d3:	e8 48 08 00 00       	call   800c20 <__udivdi3>
  8003d8:	83 c4 18             	add    $0x18,%esp
  8003db:	52                   	push   %edx
  8003dc:	50                   	push   %eax
  8003dd:	89 f2                	mov    %esi,%edx
  8003df:	89 f8                	mov    %edi,%eax
  8003e1:	e8 9e ff ff ff       	call   800384 <printnum>
  8003e6:	83 c4 20             	add    $0x20,%esp
  8003e9:	eb 13                	jmp    8003fe <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	56                   	push   %esi
  8003ef:	ff 75 18             	pushl  0x18(%ebp)
  8003f2:	ff d7                	call   *%edi
  8003f4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003f7:	83 eb 01             	sub    $0x1,%ebx
  8003fa:	85 db                	test   %ebx,%ebx
  8003fc:	7f ed                	jg     8003eb <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	56                   	push   %esi
  800402:	83 ec 04             	sub    $0x4,%esp
  800405:	ff 75 e4             	pushl  -0x1c(%ebp)
  800408:	ff 75 e0             	pushl  -0x20(%ebp)
  80040b:	ff 75 dc             	pushl  -0x24(%ebp)
  80040e:	ff 75 d8             	pushl  -0x28(%ebp)
  800411:	e8 2a 09 00 00       	call   800d40 <__umoddi3>
  800416:	83 c4 14             	add    $0x14,%esp
  800419:	0f be 80 be 0e 80 00 	movsbl 0x800ebe(%eax),%eax
  800420:	50                   	push   %eax
  800421:	ff d7                	call   *%edi
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800429:	5b                   	pop    %ebx
  80042a:	5e                   	pop    %esi
  80042b:	5f                   	pop    %edi
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800431:	eb c4                	jmp    8003f7 <printnum+0x73>

00800433 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800436:	83 fa 01             	cmp    $0x1,%edx
  800439:	7e 0e                	jle    800449 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043b:	8b 10                	mov    (%eax),%edx
  80043d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800440:	89 08                	mov    %ecx,(%eax)
  800442:	8b 02                	mov    (%edx),%eax
  800444:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800447:	5d                   	pop    %ebp
  800448:	c3                   	ret    
	else if (lflag)
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 10                	jne    80045d <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  80044d:	8b 10                	mov    (%eax),%edx
  80044f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800452:	89 08                	mov    %ecx,(%eax)
  800454:	8b 02                	mov    (%edx),%eax
  800456:	ba 00 00 00 00       	mov    $0x0,%edx
  80045b:	eb ea                	jmp    800447 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  80045d:	8b 10                	mov    (%eax),%edx
  80045f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800462:	89 08                	mov    %ecx,(%eax)
  800464:	8b 02                	mov    (%edx),%eax
  800466:	ba 00 00 00 00       	mov    $0x0,%edx
  80046b:	eb da                	jmp    800447 <getuint+0x14>

0080046d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800470:	83 fa 01             	cmp    $0x1,%edx
  800473:	7e 0e                	jle    800483 <getint+0x16>
		return va_arg(*ap, long long);
  800475:	8b 10                	mov    (%eax),%edx
  800477:	8d 4a 08             	lea    0x8(%edx),%ecx
  80047a:	89 08                	mov    %ecx,(%eax)
  80047c:	8b 02                	mov    (%edx),%eax
  80047e:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800481:	5d                   	pop    %ebp
  800482:	c3                   	ret    
	else if (lflag)
  800483:	85 d2                	test   %edx,%edx
  800485:	75 0c                	jne    800493 <getint+0x26>
		return va_arg(*ap, int);
  800487:	8b 10                	mov    (%eax),%edx
  800489:	8d 4a 04             	lea    0x4(%edx),%ecx
  80048c:	89 08                	mov    %ecx,(%eax)
  80048e:	8b 02                	mov    (%edx),%eax
  800490:	99                   	cltd   
  800491:	eb ee                	jmp    800481 <getint+0x14>
		return va_arg(*ap, long);
  800493:	8b 10                	mov    (%eax),%edx
  800495:	8d 4a 04             	lea    0x4(%edx),%ecx
  800498:	89 08                	mov    %ecx,(%eax)
  80049a:	8b 02                	mov    (%edx),%eax
  80049c:	99                   	cltd   
  80049d:	eb e2                	jmp    800481 <getint+0x14>

0080049f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ae:	73 0a                	jae    8004ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b8:	88 02                	mov    %al,(%edx)
}
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    

008004bc <printfmt>:
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c5:	50                   	push   %eax
  8004c6:	ff 75 10             	pushl  0x10(%ebp)
  8004c9:	ff 75 0c             	pushl  0xc(%ebp)
  8004cc:	ff 75 08             	pushl  0x8(%ebp)
  8004cf:	e8 05 00 00 00       	call   8004d9 <vprintfmt>
}
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	c9                   	leave  
  8004d8:	c3                   	ret    

008004d9 <vprintfmt>:
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	57                   	push   %edi
  8004dd:	56                   	push   %esi
  8004de:	53                   	push   %ebx
  8004df:	83 ec 2c             	sub    $0x2c,%esp
  8004e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004e8:	89 f7                	mov    %esi,%edi
  8004ea:	89 de                	mov    %ebx,%esi
  8004ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004ef:	e9 9e 02 00 00       	jmp    800792 <vprintfmt+0x2b9>
		padc = ' ';
  8004f4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004f8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8004ff:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800506:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80050d:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8d 43 01             	lea    0x1(%ebx),%eax
  800515:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800518:	0f b6 0b             	movzbl (%ebx),%ecx
  80051b:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80051e:	3c 55                	cmp    $0x55,%al
  800520:	0f 87 e8 02 00 00    	ja     80080e <vprintfmt+0x335>
  800526:	0f b6 c0             	movzbl %al,%eax
  800529:	ff 24 85 80 0f 80 00 	jmp    *0x800f80(,%eax,4)
  800530:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800533:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800537:	eb d9                	jmp    800512 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  80053c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800540:	eb d0                	jmp    800512 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800542:	0f b6 c9             	movzbl %cl,%ecx
  800545:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800548:	b8 00 00 00 00       	mov    $0x0,%eax
  80054d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800550:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800553:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800557:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80055a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80055d:	83 fa 09             	cmp    $0x9,%edx
  800560:	77 52                	ja     8005b4 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800562:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800565:	eb e9                	jmp    800550 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 48 04             	lea    0x4(%eax),%ecx
  80056d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800578:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057c:	79 94                	jns    800512 <vprintfmt+0x39>
				width = precision, precision = -1;
  80057e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800581:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800584:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80058b:	eb 85                	jmp    800512 <vprintfmt+0x39>
  80058d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800590:	85 c0                	test   %eax,%eax
  800592:	b9 00 00 00 00       	mov    $0x0,%ecx
  800597:	0f 49 c8             	cmovns %eax,%ecx
  80059a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a0:	e9 6d ff ff ff       	jmp    800512 <vprintfmt+0x39>
  8005a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8005a8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005af:	e9 5e ff ff ff       	jmp    800512 <vprintfmt+0x39>
  8005b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ba:	eb bc                	jmp    800578 <vprintfmt+0x9f>
			lflag++;
  8005bc:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8005c2:	e9 4b ff ff ff       	jmp    800512 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	57                   	push   %edi
  8005d4:	ff 30                	pushl  (%eax)
  8005d6:	ff d6                	call   *%esi
			break;
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	e9 af 01 00 00       	jmp    80078f <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	99                   	cltd   
  8005ec:	31 d0                	xor    %edx,%eax
  8005ee:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f0:	83 f8 08             	cmp    $0x8,%eax
  8005f3:	7f 20                	jg     800615 <vprintfmt+0x13c>
  8005f5:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	74 15                	je     800615 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800600:	52                   	push   %edx
  800601:	68 df 0e 80 00       	push   $0x800edf
  800606:	57                   	push   %edi
  800607:	56                   	push   %esi
  800608:	e8 af fe ff ff       	call   8004bc <printfmt>
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	e9 7a 01 00 00       	jmp    80078f <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800615:	50                   	push   %eax
  800616:	68 d6 0e 80 00       	push   $0x800ed6
  80061b:	57                   	push   %edi
  80061c:	56                   	push   %esi
  80061d:	e8 9a fe ff ff       	call   8004bc <printfmt>
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	e9 65 01 00 00       	jmp    80078f <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800635:	85 db                	test   %ebx,%ebx
  800637:	b8 cf 0e 80 00       	mov    $0x800ecf,%eax
  80063c:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  80063f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800643:	0f 8e bd 00 00 00    	jle    800706 <vprintfmt+0x22d>
  800649:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80064d:	75 0e                	jne    80065d <vprintfmt+0x184>
  80064f:	89 75 08             	mov    %esi,0x8(%ebp)
  800652:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800655:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800658:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80065b:	eb 6d                	jmp    8006ca <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	ff 75 d0             	pushl  -0x30(%ebp)
  800663:	53                   	push   %ebx
  800664:	e8 4d 02 00 00       	call   8008b6 <strnlen>
  800669:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80066c:	29 c1                	sub    %eax,%ecx
  80066e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800674:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800678:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80067b:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80067e:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800680:	eb 0f                	jmp    800691 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	57                   	push   %edi
  800686:	ff 75 e0             	pushl  -0x20(%ebp)
  800689:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80068b:	83 eb 01             	sub    $0x1,%ebx
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	85 db                	test   %ebx,%ebx
  800693:	7f ed                	jg     800682 <vprintfmt+0x1a9>
  800695:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800698:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80069b:	85 c9                	test   %ecx,%ecx
  80069d:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a2:	0f 49 c1             	cmovns %ecx,%eax
  8006a5:	29 c1                	sub    %eax,%ecx
  8006a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8006aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ad:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006b0:	89 cf                	mov    %ecx,%edi
  8006b2:	eb 16                	jmp    8006ca <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8006b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006b8:	75 31                	jne    8006eb <vprintfmt+0x212>
					putch(ch, putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	ff 75 0c             	pushl  0xc(%ebp)
  8006c0:	50                   	push   %eax
  8006c1:	ff 55 08             	call   *0x8(%ebp)
  8006c4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c7:	83 ef 01             	sub    $0x1,%edi
  8006ca:	83 c3 01             	add    $0x1,%ebx
  8006cd:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8006d1:	0f be c2             	movsbl %dl,%eax
  8006d4:	85 c0                	test   %eax,%eax
  8006d6:	74 50                	je     800728 <vprintfmt+0x24f>
  8006d8:	85 f6                	test   %esi,%esi
  8006da:	78 d8                	js     8006b4 <vprintfmt+0x1db>
  8006dc:	83 ee 01             	sub    $0x1,%esi
  8006df:	79 d3                	jns    8006b4 <vprintfmt+0x1db>
  8006e1:	89 fb                	mov    %edi,%ebx
  8006e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006e9:	eb 37                	jmp    800722 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8006eb:	0f be d2             	movsbl %dl,%edx
  8006ee:	83 ea 20             	sub    $0x20,%edx
  8006f1:	83 fa 5e             	cmp    $0x5e,%edx
  8006f4:	76 c4                	jbe    8006ba <vprintfmt+0x1e1>
					putch('?', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	ff 75 0c             	pushl  0xc(%ebp)
  8006fc:	6a 3f                	push   $0x3f
  8006fe:	ff 55 08             	call   *0x8(%ebp)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	eb c1                	jmp    8006c7 <vprintfmt+0x1ee>
  800706:	89 75 08             	mov    %esi,0x8(%ebp)
  800709:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070c:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80070f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800712:	eb b6                	jmp    8006ca <vprintfmt+0x1f1>
				putch(' ', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	57                   	push   %edi
  800718:	6a 20                	push   $0x20
  80071a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80071c:	83 eb 01             	sub    $0x1,%ebx
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	85 db                	test   %ebx,%ebx
  800724:	7f ee                	jg     800714 <vprintfmt+0x23b>
  800726:	eb 67                	jmp    80078f <vprintfmt+0x2b6>
  800728:	89 fb                	mov    %edi,%ebx
  80072a:	8b 75 08             	mov    0x8(%ebp),%esi
  80072d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800730:	eb f0                	jmp    800722 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
  800735:	e8 33 fd ff ff       	call   80046d <getint>
  80073a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800740:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800745:	85 d2                	test   %edx,%edx
  800747:	79 2c                	jns    800775 <vprintfmt+0x29c>
				putch('-', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	57                   	push   %edi
  80074d:	6a 2d                	push   $0x2d
  80074f:	ff d6                	call   *%esi
				num = -(long long) num;
  800751:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800754:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800757:	f7 d8                	neg    %eax
  800759:	83 d2 00             	adc    $0x0,%edx
  80075c:	f7 da                	neg    %edx
  80075e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800761:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800766:	eb 0d                	jmp    800775 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
  80076b:	e8 c3 fc ff ff       	call   800433 <getuint>
			base = 10;
  800770:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800775:	83 ec 0c             	sub    $0xc,%esp
  800778:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80077c:	53                   	push   %ebx
  80077d:	ff 75 e0             	pushl  -0x20(%ebp)
  800780:	51                   	push   %ecx
  800781:	52                   	push   %edx
  800782:	50                   	push   %eax
  800783:	89 fa                	mov    %edi,%edx
  800785:	89 f0                	mov    %esi,%eax
  800787:	e8 f8 fb ff ff       	call   800384 <printnum>
			break;
  80078c:	83 c4 20             	add    $0x20,%esp
{
  80078f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800792:	83 c3 01             	add    $0x1,%ebx
  800795:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800799:	83 f8 25             	cmp    $0x25,%eax
  80079c:	0f 84 52 fd ff ff    	je     8004f4 <vprintfmt+0x1b>
			if (ch == '\0')
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	0f 84 84 00 00 00    	je     80082e <vprintfmt+0x355>
			putch(ch, putdat);
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	57                   	push   %edi
  8007ae:	50                   	push   %eax
  8007af:	ff d6                	call   *%esi
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	eb dc                	jmp    800792 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b9:	e8 75 fc ff ff       	call   800433 <getuint>
			base = 8;
  8007be:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007c3:	eb b0                	jmp    800775 <vprintfmt+0x29c>
			putch('0', putdat);
  8007c5:	83 ec 08             	sub    $0x8,%esp
  8007c8:	57                   	push   %edi
  8007c9:	6a 30                	push   $0x30
  8007cb:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cd:	83 c4 08             	add    $0x8,%esp
  8007d0:	57                   	push   %edi
  8007d1:	6a 78                	push   $0x78
  8007d3:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 50 04             	lea    0x4(%eax),%edx
  8007db:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007de:	8b 00                	mov    (%eax),%eax
  8007e0:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8007e5:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007e8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ed:	eb 86                	jmp    800775 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f2:	e8 3c fc ff ff       	call   800433 <getuint>
			base = 16;
  8007f7:	b9 10 00 00 00       	mov    $0x10,%ecx
  8007fc:	e9 74 ff ff ff       	jmp    800775 <vprintfmt+0x29c>
			putch(ch, putdat);
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	57                   	push   %edi
  800805:	6a 25                	push   $0x25
  800807:	ff d6                	call   *%esi
			break;
  800809:	83 c4 10             	add    $0x10,%esp
  80080c:	eb 81                	jmp    80078f <vprintfmt+0x2b6>
			putch('%', putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	57                   	push   %edi
  800812:	6a 25                	push   $0x25
  800814:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	89 d8                	mov    %ebx,%eax
  80081b:	eb 03                	jmp    800820 <vprintfmt+0x347>
  80081d:	83 e8 01             	sub    $0x1,%eax
  800820:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800824:	75 f7                	jne    80081d <vprintfmt+0x344>
  800826:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800829:	e9 61 ff ff ff       	jmp    80078f <vprintfmt+0x2b6>
}
  80082e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	5f                   	pop    %edi
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	83 ec 18             	sub    $0x18,%esp
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800842:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800845:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800849:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80084c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800853:	85 c0                	test   %eax,%eax
  800855:	74 26                	je     80087d <vsnprintf+0x47>
  800857:	85 d2                	test   %edx,%edx
  800859:	7e 22                	jle    80087d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085b:	ff 75 14             	pushl  0x14(%ebp)
  80085e:	ff 75 10             	pushl  0x10(%ebp)
  800861:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	68 9f 04 80 00       	push   $0x80049f
  80086a:	e8 6a fc ff ff       	call   8004d9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80086f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800872:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800875:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800878:	83 c4 10             	add    $0x10,%esp
}
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    
		return -E_INVAL;
  80087d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800882:	eb f7                	jmp    80087b <vsnprintf+0x45>

00800884 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80088a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80088d:	50                   	push   %eax
  80088e:	ff 75 10             	pushl  0x10(%ebp)
  800891:	ff 75 0c             	pushl  0xc(%ebp)
  800894:	ff 75 08             	pushl  0x8(%ebp)
  800897:	e8 9a ff ff ff       	call   800836 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089c:	c9                   	leave  
  80089d:	c3                   	ret    

0080089e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a9:	eb 03                	jmp    8008ae <strlen+0x10>
		n++;
  8008ab:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b2:	75 f7                	jne    8008ab <strlen+0xd>
	return n;
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb 03                	jmp    8008c9 <strnlen+0x13>
		n++;
  8008c6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c9:	39 d0                	cmp    %edx,%eax
  8008cb:	74 06                	je     8008d3 <strnlen+0x1d>
  8008cd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d1:	75 f3                	jne    8008c6 <strnlen+0x10>
	return n;
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008df:	89 c2                	mov    %eax,%edx
  8008e1:	83 c1 01             	add    $0x1,%ecx
  8008e4:	83 c2 01             	add    $0x1,%edx
  8008e7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008eb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ee:	84 db                	test   %bl,%bl
  8008f0:	75 ef                	jne    8008e1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	53                   	push   %ebx
  8008f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fc:	53                   	push   %ebx
  8008fd:	e8 9c ff ff ff       	call   80089e <strlen>
  800902:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800905:	ff 75 0c             	pushl  0xc(%ebp)
  800908:	01 d8                	add    %ebx,%eax
  80090a:	50                   	push   %eax
  80090b:	e8 c5 ff ff ff       	call   8008d5 <strcpy>
	return dst;
}
  800910:	89 d8                	mov    %ebx,%eax
  800912:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 75 08             	mov    0x8(%ebp),%esi
  80091f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800922:	89 f3                	mov    %esi,%ebx
  800924:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800927:	89 f2                	mov    %esi,%edx
  800929:	eb 0f                	jmp    80093a <strncpy+0x23>
		*dst++ = *src;
  80092b:	83 c2 01             	add    $0x1,%edx
  80092e:	0f b6 01             	movzbl (%ecx),%eax
  800931:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800934:	80 39 01             	cmpb   $0x1,(%ecx)
  800937:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80093a:	39 da                	cmp    %ebx,%edx
  80093c:	75 ed                	jne    80092b <strncpy+0x14>
	}
	return ret;
}
  80093e:	89 f0                	mov    %esi,%eax
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 75 08             	mov    0x8(%ebp),%esi
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800952:	89 f0                	mov    %esi,%eax
  800954:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	75 0b                	jne    800967 <strlcpy+0x23>
  80095c:	eb 17                	jmp    800975 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095e:	83 c2 01             	add    $0x1,%edx
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800967:	39 d8                	cmp    %ebx,%eax
  800969:	74 07                	je     800972 <strlcpy+0x2e>
  80096b:	0f b6 0a             	movzbl (%edx),%ecx
  80096e:	84 c9                	test   %cl,%cl
  800970:	75 ec                	jne    80095e <strlcpy+0x1a>
		*dst = '\0';
  800972:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800975:	29 f0                	sub    %esi,%eax
}
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800981:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800984:	eb 06                	jmp    80098c <strcmp+0x11>
		p++, q++;
  800986:	83 c1 01             	add    $0x1,%ecx
  800989:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80098c:	0f b6 01             	movzbl (%ecx),%eax
  80098f:	84 c0                	test   %al,%al
  800991:	74 04                	je     800997 <strcmp+0x1c>
  800993:	3a 02                	cmp    (%edx),%al
  800995:	74 ef                	je     800986 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800997:	0f b6 c0             	movzbl %al,%eax
  80099a:	0f b6 12             	movzbl (%edx),%edx
  80099d:	29 d0                	sub    %edx,%eax
}
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ab:	89 c3                	mov    %eax,%ebx
  8009ad:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b0:	eb 06                	jmp    8009b8 <strncmp+0x17>
		n--, p++, q++;
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b8:	39 d8                	cmp    %ebx,%eax
  8009ba:	74 16                	je     8009d2 <strncmp+0x31>
  8009bc:	0f b6 08             	movzbl (%eax),%ecx
  8009bf:	84 c9                	test   %cl,%cl
  8009c1:	74 04                	je     8009c7 <strncmp+0x26>
  8009c3:	3a 0a                	cmp    (%edx),%cl
  8009c5:	74 eb                	je     8009b2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c7:	0f b6 00             	movzbl (%eax),%eax
  8009ca:	0f b6 12             	movzbl (%edx),%edx
  8009cd:	29 d0                	sub    %edx,%eax
}
  8009cf:	5b                   	pop    %ebx
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    
		return 0;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d7:	eb f6                	jmp    8009cf <strncmp+0x2e>

008009d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e3:	0f b6 10             	movzbl (%eax),%edx
  8009e6:	84 d2                	test   %dl,%dl
  8009e8:	74 09                	je     8009f3 <strchr+0x1a>
		if (*s == c)
  8009ea:	38 ca                	cmp    %cl,%dl
  8009ec:	74 0a                	je     8009f8 <strchr+0x1f>
	for (; *s; s++)
  8009ee:	83 c0 01             	add    $0x1,%eax
  8009f1:	eb f0                	jmp    8009e3 <strchr+0xa>
			return (char *) s;
	return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a04:	eb 03                	jmp    800a09 <strfind+0xf>
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a0c:	38 ca                	cmp    %cl,%dl
  800a0e:	74 04                	je     800a14 <strfind+0x1a>
  800a10:	84 d2                	test   %dl,%dl
  800a12:	75 f2                	jne    800a06 <strfind+0xc>
			break;
	return (char *) s;
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	57                   	push   %edi
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a22:	85 c9                	test   %ecx,%ecx
  800a24:	74 12                	je     800a38 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a26:	f6 c2 03             	test   $0x3,%dl
  800a29:	75 05                	jne    800a30 <memset+0x1a>
  800a2b:	f6 c1 03             	test   $0x3,%cl
  800a2e:	74 0f                	je     800a3f <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a30:	89 d7                	mov    %edx,%edi
  800a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a35:	fc                   	cld    
  800a36:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a38:	89 d0                	mov    %edx,%eax
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    
		c &= 0xFF;
  800a3f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a43:	89 d8                	mov    %ebx,%eax
  800a45:	c1 e0 08             	shl    $0x8,%eax
  800a48:	89 df                	mov    %ebx,%edi
  800a4a:	c1 e7 18             	shl    $0x18,%edi
  800a4d:	89 de                	mov    %ebx,%esi
  800a4f:	c1 e6 10             	shl    $0x10,%esi
  800a52:	09 f7                	or     %esi,%edi
  800a54:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800a56:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a59:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a5b:	89 d7                	mov    %edx,%edi
  800a5d:	fc                   	cld    
  800a5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a60:	eb d6                	jmp    800a38 <memset+0x22>

00800a62 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a70:	39 c6                	cmp    %eax,%esi
  800a72:	73 35                	jae    800aa9 <memmove+0x47>
  800a74:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a77:	39 c2                	cmp    %eax,%edx
  800a79:	76 2e                	jbe    800aa9 <memmove+0x47>
		s += n;
		d += n;
  800a7b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7e:	89 d6                	mov    %edx,%esi
  800a80:	09 fe                	or     %edi,%esi
  800a82:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a88:	74 0c                	je     800a96 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a8a:	83 ef 01             	sub    $0x1,%edi
  800a8d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a90:	fd                   	std    
  800a91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a93:	fc                   	cld    
  800a94:	eb 21                	jmp    800ab7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	75 ef                	jne    800a8a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a9b:	83 ef 04             	sub    $0x4,%edi
  800a9e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aa4:	fd                   	std    
  800aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa7:	eb ea                	jmp    800a93 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa9:	89 f2                	mov    %esi,%edx
  800aab:	09 c2                	or     %eax,%edx
  800aad:	f6 c2 03             	test   $0x3,%dl
  800ab0:	74 09                	je     800abb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab2:	89 c7                	mov    %eax,%edi
  800ab4:	fc                   	cld    
  800ab5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abb:	f6 c1 03             	test   $0x3,%cl
  800abe:	75 f2                	jne    800ab2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ac3:	89 c7                	mov    %eax,%edi
  800ac5:	fc                   	cld    
  800ac6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac8:	eb ed                	jmp    800ab7 <memmove+0x55>

00800aca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800acd:	ff 75 10             	pushl  0x10(%ebp)
  800ad0:	ff 75 0c             	pushl  0xc(%ebp)
  800ad3:	ff 75 08             	pushl  0x8(%ebp)
  800ad6:	e8 87 ff ff ff       	call   800a62 <memmove>
}
  800adb:	c9                   	leave  
  800adc:	c3                   	ret    

00800add <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae8:	89 c6                	mov    %eax,%esi
  800aea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aed:	39 f0                	cmp    %esi,%eax
  800aef:	74 1c                	je     800b0d <memcmp+0x30>
		if (*s1 != *s2)
  800af1:	0f b6 08             	movzbl (%eax),%ecx
  800af4:	0f b6 1a             	movzbl (%edx),%ebx
  800af7:	38 d9                	cmp    %bl,%cl
  800af9:	75 08                	jne    800b03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800afb:	83 c0 01             	add    $0x1,%eax
  800afe:	83 c2 01             	add    $0x1,%edx
  800b01:	eb ea                	jmp    800aed <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b03:	0f b6 c1             	movzbl %cl,%eax
  800b06:	0f b6 db             	movzbl %bl,%ebx
  800b09:	29 d8                	sub    %ebx,%eax
  800b0b:	eb 05                	jmp    800b12 <memcmp+0x35>
	}

	return 0;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b24:	39 d0                	cmp    %edx,%eax
  800b26:	73 09                	jae    800b31 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b28:	38 08                	cmp    %cl,(%eax)
  800b2a:	74 05                	je     800b31 <memfind+0x1b>
	for (; s < ends; s++)
  800b2c:	83 c0 01             	add    $0x1,%eax
  800b2f:	eb f3                	jmp    800b24 <memfind+0xe>
			break;
	return (void *) s;
}
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3f:	eb 03                	jmp    800b44 <strtol+0x11>
		s++;
  800b41:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b44:	0f b6 01             	movzbl (%ecx),%eax
  800b47:	3c 20                	cmp    $0x20,%al
  800b49:	74 f6                	je     800b41 <strtol+0xe>
  800b4b:	3c 09                	cmp    $0x9,%al
  800b4d:	74 f2                	je     800b41 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b4f:	3c 2b                	cmp    $0x2b,%al
  800b51:	74 2e                	je     800b81 <strtol+0x4e>
	int neg = 0;
  800b53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b58:	3c 2d                	cmp    $0x2d,%al
  800b5a:	74 2f                	je     800b8b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b62:	75 05                	jne    800b69 <strtol+0x36>
  800b64:	80 39 30             	cmpb   $0x30,(%ecx)
  800b67:	74 2c                	je     800b95 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b69:	85 db                	test   %ebx,%ebx
  800b6b:	75 0a                	jne    800b77 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b6d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b72:	80 39 30             	cmpb   $0x30,(%ecx)
  800b75:	74 28                	je     800b9f <strtol+0x6c>
		base = 10;
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b7f:	eb 50                	jmp    800bd1 <strtol+0x9e>
		s++;
  800b81:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b84:	bf 00 00 00 00       	mov    $0x0,%edi
  800b89:	eb d1                	jmp    800b5c <strtol+0x29>
		s++, neg = 1;
  800b8b:	83 c1 01             	add    $0x1,%ecx
  800b8e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b93:	eb c7                	jmp    800b5c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b95:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b99:	74 0e                	je     800ba9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b9b:	85 db                	test   %ebx,%ebx
  800b9d:	75 d8                	jne    800b77 <strtol+0x44>
		s++, base = 8;
  800b9f:	83 c1 01             	add    $0x1,%ecx
  800ba2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ba7:	eb ce                	jmp    800b77 <strtol+0x44>
		s += 2, base = 16;
  800ba9:	83 c1 02             	add    $0x2,%ecx
  800bac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb1:	eb c4                	jmp    800b77 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bb3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb6:	89 f3                	mov    %esi,%ebx
  800bb8:	80 fb 19             	cmp    $0x19,%bl
  800bbb:	77 29                	ja     800be6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bbd:	0f be d2             	movsbl %dl,%edx
  800bc0:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bc6:	7d 30                	jge    800bf8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bc8:	83 c1 01             	add    $0x1,%ecx
  800bcb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bcf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bd1:	0f b6 11             	movzbl (%ecx),%edx
  800bd4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bd7:	89 f3                	mov    %esi,%ebx
  800bd9:	80 fb 09             	cmp    $0x9,%bl
  800bdc:	77 d5                	ja     800bb3 <strtol+0x80>
			dig = *s - '0';
  800bde:	0f be d2             	movsbl %dl,%edx
  800be1:	83 ea 30             	sub    $0x30,%edx
  800be4:	eb dd                	jmp    800bc3 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800be6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be9:	89 f3                	mov    %esi,%ebx
  800beb:	80 fb 19             	cmp    $0x19,%bl
  800bee:	77 08                	ja     800bf8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bf0:	0f be d2             	movsbl %dl,%edx
  800bf3:	83 ea 37             	sub    $0x37,%edx
  800bf6:	eb cb                	jmp    800bc3 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfc:	74 05                	je     800c03 <strtol+0xd0>
		*endptr = (char *) s;
  800bfe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c01:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c03:	89 c2                	mov    %eax,%edx
  800c05:	f7 da                	neg    %edx
  800c07:	85 ff                	test   %edi,%edi
  800c09:	0f 45 c2             	cmovne %edx,%eax
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    
  800c11:	66 90                	xchg   %ax,%ax
  800c13:	66 90                	xchg   %ax,%ax
  800c15:	66 90                	xchg   %ax,%ax
  800c17:	66 90                	xchg   %ax,%ax
  800c19:	66 90                	xchg   %ax,%ax
  800c1b:	66 90                	xchg   %ax,%ax
  800c1d:	66 90                	xchg   %ax,%ax
  800c1f:	90                   	nop

00800c20 <__udivdi3>:
  800c20:	55                   	push   %ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 1c             	sub    $0x1c,%esp
  800c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c2b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c33:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c37:	85 d2                	test   %edx,%edx
  800c39:	75 35                	jne    800c70 <__udivdi3+0x50>
  800c3b:	39 f3                	cmp    %esi,%ebx
  800c3d:	0f 87 bd 00 00 00    	ja     800d00 <__udivdi3+0xe0>
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	89 d9                	mov    %ebx,%ecx
  800c47:	75 0b                	jne    800c54 <__udivdi3+0x34>
  800c49:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4e:	31 d2                	xor    %edx,%edx
  800c50:	f7 f3                	div    %ebx
  800c52:	89 c1                	mov    %eax,%ecx
  800c54:	31 d2                	xor    %edx,%edx
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	f7 f1                	div    %ecx
  800c5a:	89 c6                	mov    %eax,%esi
  800c5c:	89 e8                	mov    %ebp,%eax
  800c5e:	89 f7                	mov    %esi,%edi
  800c60:	f7 f1                	div    %ecx
  800c62:	89 fa                	mov    %edi,%edx
  800c64:	83 c4 1c             	add    $0x1c,%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    
  800c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c70:	39 f2                	cmp    %esi,%edx
  800c72:	77 7c                	ja     800cf0 <__udivdi3+0xd0>
  800c74:	0f bd fa             	bsr    %edx,%edi
  800c77:	83 f7 1f             	xor    $0x1f,%edi
  800c7a:	0f 84 98 00 00 00    	je     800d18 <__udivdi3+0xf8>
  800c80:	89 f9                	mov    %edi,%ecx
  800c82:	b8 20 00 00 00       	mov    $0x20,%eax
  800c87:	29 f8                	sub    %edi,%eax
  800c89:	d3 e2                	shl    %cl,%edx
  800c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	89 da                	mov    %ebx,%edx
  800c93:	d3 ea                	shr    %cl,%edx
  800c95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c99:	09 d1                	or     %edx,%ecx
  800c9b:	89 f2                	mov    %esi,%edx
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f9                	mov    %edi,%ecx
  800ca3:	d3 e3                	shl    %cl,%ebx
  800ca5:	89 c1                	mov    %eax,%ecx
  800ca7:	d3 ea                	shr    %cl,%edx
  800ca9:	89 f9                	mov    %edi,%ecx
  800cab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800caf:	d3 e6                	shl    %cl,%esi
  800cb1:	89 eb                	mov    %ebp,%ebx
  800cb3:	89 c1                	mov    %eax,%ecx
  800cb5:	d3 eb                	shr    %cl,%ebx
  800cb7:	09 de                	or     %ebx,%esi
  800cb9:	89 f0                	mov    %esi,%eax
  800cbb:	f7 74 24 08          	divl   0x8(%esp)
  800cbf:	89 d6                	mov    %edx,%esi
  800cc1:	89 c3                	mov    %eax,%ebx
  800cc3:	f7 64 24 0c          	mull   0xc(%esp)
  800cc7:	39 d6                	cmp    %edx,%esi
  800cc9:	72 0c                	jb     800cd7 <__udivdi3+0xb7>
  800ccb:	89 f9                	mov    %edi,%ecx
  800ccd:	d3 e5                	shl    %cl,%ebp
  800ccf:	39 c5                	cmp    %eax,%ebp
  800cd1:	73 5d                	jae    800d30 <__udivdi3+0x110>
  800cd3:	39 d6                	cmp    %edx,%esi
  800cd5:	75 59                	jne    800d30 <__udivdi3+0x110>
  800cd7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cda:	31 ff                	xor    %edi,%edi
  800cdc:	89 fa                	mov    %edi,%edx
  800cde:	83 c4 1c             	add    $0x1c,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    
  800ce6:	8d 76 00             	lea    0x0(%esi),%esi
  800ce9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cf0:	31 ff                	xor    %edi,%edi
  800cf2:	31 c0                	xor    %eax,%eax
  800cf4:	89 fa                	mov    %edi,%edx
  800cf6:	83 c4 1c             	add    $0x1c,%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
  800cfe:	66 90                	xchg   %ax,%ax
  800d00:	31 ff                	xor    %edi,%edi
  800d02:	89 e8                	mov    %ebp,%eax
  800d04:	89 f2                	mov    %esi,%edx
  800d06:	f7 f3                	div    %ebx
  800d08:	89 fa                	mov    %edi,%edx
  800d0a:	83 c4 1c             	add    $0x1c,%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
  800d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d18:	39 f2                	cmp    %esi,%edx
  800d1a:	72 06                	jb     800d22 <__udivdi3+0x102>
  800d1c:	31 c0                	xor    %eax,%eax
  800d1e:	39 eb                	cmp    %ebp,%ebx
  800d20:	77 d2                	ja     800cf4 <__udivdi3+0xd4>
  800d22:	b8 01 00 00 00       	mov    $0x1,%eax
  800d27:	eb cb                	jmp    800cf4 <__udivdi3+0xd4>
  800d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d30:	89 d8                	mov    %ebx,%eax
  800d32:	31 ff                	xor    %edi,%edi
  800d34:	eb be                	jmp    800cf4 <__udivdi3+0xd4>
  800d36:	66 90                	xchg   %ax,%ax
  800d38:	66 90                	xchg   %ax,%ax
  800d3a:	66 90                	xchg   %ax,%ax
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__umoddi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d57:	85 ed                	test   %ebp,%ebp
  800d59:	89 f0                	mov    %esi,%eax
  800d5b:	89 da                	mov    %ebx,%edx
  800d5d:	75 19                	jne    800d78 <__umoddi3+0x38>
  800d5f:	39 df                	cmp    %ebx,%edi
  800d61:	0f 86 b1 00 00 00    	jbe    800e18 <__umoddi3+0xd8>
  800d67:	f7 f7                	div    %edi
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	83 c4 1c             	add    $0x1c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
  800d75:	8d 76 00             	lea    0x0(%esi),%esi
  800d78:	39 dd                	cmp    %ebx,%ebp
  800d7a:	77 f1                	ja     800d6d <__umoddi3+0x2d>
  800d7c:	0f bd cd             	bsr    %ebp,%ecx
  800d7f:	83 f1 1f             	xor    $0x1f,%ecx
  800d82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d86:	0f 84 b4 00 00 00    	je     800e40 <__umoddi3+0x100>
  800d8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d97:	29 c2                	sub    %eax,%edx
  800d99:	89 c1                	mov    %eax,%ecx
  800d9b:	89 f8                	mov    %edi,%eax
  800d9d:	d3 e5                	shl    %cl,%ebp
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800da5:	d3 e8                	shr    %cl,%eax
  800da7:	09 c5                	or     %eax,%ebp
  800da9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dad:	89 c1                	mov    %eax,%ecx
  800daf:	d3 e7                	shl    %cl,%edi
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800db7:	89 df                	mov    %ebx,%edi
  800db9:	d3 ef                	shr    %cl,%edi
  800dbb:	89 c1                	mov    %eax,%ecx
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	d3 e3                	shl    %cl,%ebx
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 fa                	mov    %edi,%edx
  800dc5:	d3 e8                	shr    %cl,%eax
  800dc7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dcc:	09 d8                	or     %ebx,%eax
  800dce:	f7 f5                	div    %ebp
  800dd0:	d3 e6                	shl    %cl,%esi
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	f7 64 24 08          	mull   0x8(%esp)
  800dd8:	39 d1                	cmp    %edx,%ecx
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 d7                	mov    %edx,%edi
  800dde:	72 06                	jb     800de6 <__umoddi3+0xa6>
  800de0:	75 0e                	jne    800df0 <__umoddi3+0xb0>
  800de2:	39 c6                	cmp    %eax,%esi
  800de4:	73 0a                	jae    800df0 <__umoddi3+0xb0>
  800de6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dea:	19 ea                	sbb    %ebp,%edx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	89 c3                	mov    %eax,%ebx
  800df0:	89 ca                	mov    %ecx,%edx
  800df2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800df7:	29 de                	sub    %ebx,%esi
  800df9:	19 fa                	sbb    %edi,%edx
  800dfb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	d3 e0                	shl    %cl,%eax
  800e03:	89 d9                	mov    %ebx,%ecx
  800e05:	d3 ee                	shr    %cl,%esi
  800e07:	d3 ea                	shr    %cl,%edx
  800e09:	09 f0                	or     %esi,%eax
  800e0b:	83 c4 1c             	add    $0x1c,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
  800e13:	90                   	nop
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	85 ff                	test   %edi,%edi
  800e1a:	89 f9                	mov    %edi,%ecx
  800e1c:	75 0b                	jne    800e29 <__umoddi3+0xe9>
  800e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e23:	31 d2                	xor    %edx,%edx
  800e25:	f7 f7                	div    %edi
  800e27:	89 c1                	mov    %eax,%ecx
  800e29:	89 d8                	mov    %ebx,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 f0                	mov    %esi,%eax
  800e31:	f7 f1                	div    %ecx
  800e33:	e9 31 ff ff ff       	jmp    800d69 <__umoddi3+0x29>
  800e38:	90                   	nop
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 dd                	cmp    %ebx,%ebp
  800e42:	72 08                	jb     800e4c <__umoddi3+0x10c>
  800e44:	39 f7                	cmp    %esi,%edi
  800e46:	0f 87 21 ff ff ff    	ja     800d6d <__umoddi3+0x2d>
  800e4c:	89 da                	mov    %ebx,%edx
  800e4e:	89 f0                	mov    %esi,%eax
  800e50:	29 f8                	sub    %edi,%eax
  800e52:	19 ea                	sbb    %ebp,%edx
  800e54:	e9 14 ff ff ff       	jmp    800d6d <__umoddi3+0x2d>
