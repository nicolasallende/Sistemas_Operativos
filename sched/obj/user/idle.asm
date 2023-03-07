
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 20 80 00 60 	movl   $0x800e60,0x802000
  800040:	0e 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 38 01 00 00       	call   800180 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800055:	e8 02 01 00 00       	call   80015c <sys_getenvid>
	if (id >= 0)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	78 12                	js     800070 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x31>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 99 00 00 00       	call   80013a <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 1c             	sub    $0x1c,%esp
  8000af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b5:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c0:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c9:	74 04                	je     8000cf <syscall+0x29>
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7f 08                	jg     8000d7 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    
  8000d7:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	50                   	push   %eax
  8000de:	52                   	push   %edx
  8000df:	68 6f 0e 80 00       	push   $0x800e6f
  8000e4:	6a 23                	push   $0x23
  8000e6:	68 8c 0e 80 00       	push   $0x800e8c
  8000eb:	e8 b1 01 00 00       	call   8002a1 <_panic>

008000f0 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f6:	6a 00                	push   $0x0
  8000f8:	6a 00                	push   $0x0
  8000fa:	6a 00                	push   $0x0
  8000fc:	ff 75 0c             	pushl  0xc(%ebp)
  8000ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800102:	ba 00 00 00 00       	mov    $0x0,%edx
  800107:	b8 00 00 00 00       	mov    $0x0,%eax
  80010c:	e8 95 ff ff ff       	call   8000a6 <syscall>
}
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	c9                   	leave  
  800115:	c3                   	ret    

00800116 <sys_cgetc>:

int
sys_cgetc(void)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80011c:	6a 00                	push   $0x0
  80011e:	6a 00                	push   $0x0
  800120:	6a 00                	push   $0x0
  800122:	6a 00                	push   $0x0
  800124:	b9 00 00 00 00       	mov    $0x0,%ecx
  800129:	ba 00 00 00 00       	mov    $0x0,%edx
  80012e:	b8 01 00 00 00       	mov    $0x1,%eax
  800133:	e8 6e ff ff ff       	call   8000a6 <syscall>
}
  800138:	c9                   	leave  
  800139:	c3                   	ret    

0080013a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800140:	6a 00                	push   $0x0
  800142:	6a 00                	push   $0x0
  800144:	6a 00                	push   $0x0
  800146:	6a 00                	push   $0x0
  800148:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014b:	ba 01 00 00 00       	mov    $0x1,%edx
  800150:	b8 03 00 00 00       	mov    $0x3,%eax
  800155:	e8 4c ff ff ff       	call   8000a6 <syscall>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800162:	6a 00                	push   $0x0
  800164:	6a 00                	push   $0x0
  800166:	6a 00                	push   $0x0
  800168:	6a 00                	push   $0x0
  80016a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80016f:	ba 00 00 00 00       	mov    $0x0,%edx
  800174:	b8 02 00 00 00       	mov    $0x2,%eax
  800179:	e8 28 ff ff ff       	call   8000a6 <syscall>
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <sys_yield>:

void
sys_yield(void)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800186:	6a 00                	push   $0x0
  800188:	6a 00                	push   $0x0
  80018a:	6a 00                	push   $0x0
  80018c:	6a 00                	push   $0x0
  80018e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800193:	ba 00 00 00 00       	mov    $0x0,%edx
  800198:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019d:	e8 04 ff ff ff       	call   8000a6 <syscall>
}
  8001a2:	83 c4 10             	add    $0x10,%esp
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001ad:	6a 00                	push   $0x0
  8001af:	6a 00                	push   $0x0
  8001b1:	ff 75 10             	pushl  0x10(%ebp)
  8001b4:	ff 75 0c             	pushl  0xc(%ebp)
  8001b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ba:	ba 01 00 00 00       	mov    $0x1,%edx
  8001bf:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c4:	e8 dd fe ff ff       	call   8000a6 <syscall>
}
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001d1:	ff 75 18             	pushl  0x18(%ebp)
  8001d4:	ff 75 14             	pushl  0x14(%ebp)
  8001d7:	ff 75 10             	pushl  0x10(%ebp)
  8001da:	ff 75 0c             	pushl  0xc(%ebp)
  8001dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e0:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ea:	e8 b7 fe ff ff       	call   8000a6 <syscall>
}
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001f7:	6a 00                	push   $0x0
  8001f9:	6a 00                	push   $0x0
  8001fb:	6a 00                	push   $0x0
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800203:	ba 01 00 00 00       	mov    $0x1,%edx
  800208:	b8 06 00 00 00       	mov    $0x6,%eax
  80020d:	e8 94 fe ff ff       	call   8000a6 <syscall>
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80021a:	6a 00                	push   $0x0
  80021c:	6a 00                	push   $0x0
  80021e:	6a 00                	push   $0x0
  800220:	ff 75 0c             	pushl  0xc(%ebp)
  800223:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800226:	ba 01 00 00 00       	mov    $0x1,%edx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	e8 71 fe ff ff       	call   8000a6 <syscall>
}
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80023d:	6a 00                	push   $0x0
  80023f:	6a 00                	push   $0x0
  800241:	6a 00                	push   $0x0
  800243:	ff 75 0c             	pushl  0xc(%ebp)
  800246:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800249:	ba 01 00 00 00       	mov    $0x1,%edx
  80024e:	b8 09 00 00 00       	mov    $0x9,%eax
  800253:	e8 4e fe ff ff       	call   8000a6 <syscall>
}
  800258:	c9                   	leave  
  800259:	c3                   	ret    

0080025a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800260:	6a 00                	push   $0x0
  800262:	ff 75 14             	pushl  0x14(%ebp)
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026e:	ba 00 00 00 00       	mov    $0x0,%edx
  800273:	b8 0b 00 00 00       	mov    $0xb,%eax
  800278:	e8 29 fe ff ff       	call   8000a6 <syscall>
}
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800285:	6a 00                	push   $0x0
  800287:	6a 00                	push   $0x0
  800289:	6a 00                	push   $0x0
  80028b:	6a 00                	push   $0x0
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	ba 01 00 00 00       	mov    $0x1,%edx
  800295:	b8 0c 00 00 00       	mov    $0xc,%eax
  80029a:	e8 07 fe ff ff       	call   8000a6 <syscall>
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002a6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a9:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002af:	e8 a8 fe ff ff       	call   80015c <sys_getenvid>
  8002b4:	83 ec 0c             	sub    $0xc,%esp
  8002b7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ba:	ff 75 08             	pushl  0x8(%ebp)
  8002bd:	56                   	push   %esi
  8002be:	50                   	push   %eax
  8002bf:	68 9c 0e 80 00       	push   $0x800e9c
  8002c4:	e8 b3 00 00 00       	call   80037c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c9:	83 c4 18             	add    $0x18,%esp
  8002cc:	53                   	push   %ebx
  8002cd:	ff 75 10             	pushl  0x10(%ebp)
  8002d0:	e8 56 00 00 00       	call   80032b <vcprintf>
	cprintf("\n");
  8002d5:	c7 04 24 c0 0e 80 00 	movl   $0x800ec0,(%esp)
  8002dc:	e8 9b 00 00 00       	call   80037c <cprintf>
  8002e1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e4:	cc                   	int3   
  8002e5:	eb fd                	jmp    8002e4 <_panic+0x43>

008002e7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	53                   	push   %ebx
  8002eb:	83 ec 04             	sub    $0x4,%esp
  8002ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f1:	8b 13                	mov    (%ebx),%edx
  8002f3:	8d 42 01             	lea    0x1(%edx),%eax
  8002f6:	89 03                	mov    %eax,(%ebx)
  8002f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800304:	74 09                	je     80030f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800306:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80030a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80030f:	83 ec 08             	sub    $0x8,%esp
  800312:	68 ff 00 00 00       	push   $0xff
  800317:	8d 43 08             	lea    0x8(%ebx),%eax
  80031a:	50                   	push   %eax
  80031b:	e8 d0 fd ff ff       	call   8000f0 <sys_cputs>
		b->idx = 0;
  800320:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800326:	83 c4 10             	add    $0x10,%esp
  800329:	eb db                	jmp    800306 <putch+0x1f>

0080032b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800334:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033b:	00 00 00 
	b.cnt = 0;
  80033e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800345:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800348:	ff 75 0c             	pushl  0xc(%ebp)
  80034b:	ff 75 08             	pushl  0x8(%ebp)
  80034e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800354:	50                   	push   %eax
  800355:	68 e7 02 80 00       	push   $0x8002e7
  80035a:	e8 86 01 00 00       	call   8004e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80035f:	83 c4 08             	add    $0x8,%esp
  800362:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800368:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80036e:	50                   	push   %eax
  80036f:	e8 7c fd ff ff       	call   8000f0 <sys_cputs>

	return b.cnt;
}
  800374:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800382:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800385:	50                   	push   %eax
  800386:	ff 75 08             	pushl  0x8(%ebp)
  800389:	e8 9d ff ff ff       	call   80032b <vcprintf>
	va_end(ap);

	return cnt;
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 1c             	sub    $0x1c,%esp
  800399:	89 c7                	mov    %eax,%edi
  80039b:	89 d6                	mov    %edx,%esi
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003b4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003b7:	39 d3                	cmp    %edx,%ebx
  8003b9:	72 05                	jb     8003c0 <printnum+0x30>
  8003bb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003be:	77 7a                	ja     80043a <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003c0:	83 ec 0c             	sub    $0xc,%esp
  8003c3:	ff 75 18             	pushl  0x18(%ebp)
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003cc:	53                   	push   %ebx
  8003cd:	ff 75 10             	pushl  0x10(%ebp)
  8003d0:	83 ec 08             	sub    $0x8,%esp
  8003d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8003dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8003df:	e8 3c 08 00 00       	call   800c20 <__udivdi3>
  8003e4:	83 c4 18             	add    $0x18,%esp
  8003e7:	52                   	push   %edx
  8003e8:	50                   	push   %eax
  8003e9:	89 f2                	mov    %esi,%edx
  8003eb:	89 f8                	mov    %edi,%eax
  8003ed:	e8 9e ff ff ff       	call   800390 <printnum>
  8003f2:	83 c4 20             	add    $0x20,%esp
  8003f5:	eb 13                	jmp    80040a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	56                   	push   %esi
  8003fb:	ff 75 18             	pushl  0x18(%ebp)
  8003fe:	ff d7                	call   *%edi
  800400:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800403:	83 eb 01             	sub    $0x1,%ebx
  800406:	85 db                	test   %ebx,%ebx
  800408:	7f ed                	jg     8003f7 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	56                   	push   %esi
  80040e:	83 ec 04             	sub    $0x4,%esp
  800411:	ff 75 e4             	pushl  -0x1c(%ebp)
  800414:	ff 75 e0             	pushl  -0x20(%ebp)
  800417:	ff 75 dc             	pushl  -0x24(%ebp)
  80041a:	ff 75 d8             	pushl  -0x28(%ebp)
  80041d:	e8 1e 09 00 00       	call   800d40 <__umoddi3>
  800422:	83 c4 14             	add    $0x14,%esp
  800425:	0f be 80 c2 0e 80 00 	movsbl 0x800ec2(%eax),%eax
  80042c:	50                   	push   %eax
  80042d:	ff d7                	call   *%edi
}
  80042f:	83 c4 10             	add    $0x10,%esp
  800432:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800435:	5b                   	pop    %ebx
  800436:	5e                   	pop    %esi
  800437:	5f                   	pop    %edi
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    
  80043a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80043d:	eb c4                	jmp    800403 <printnum+0x73>

0080043f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800442:	83 fa 01             	cmp    $0x1,%edx
  800445:	7e 0e                	jle    800455 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800447:	8b 10                	mov    (%eax),%edx
  800449:	8d 4a 08             	lea    0x8(%edx),%ecx
  80044c:	89 08                	mov    %ecx,(%eax)
  80044e:	8b 02                	mov    (%edx),%eax
  800450:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    
	else if (lflag)
  800455:	85 d2                	test   %edx,%edx
  800457:	75 10                	jne    800469 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800459:	8b 10                	mov    (%eax),%edx
  80045b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045e:	89 08                	mov    %ecx,(%eax)
  800460:	8b 02                	mov    (%edx),%eax
  800462:	ba 00 00 00 00       	mov    $0x0,%edx
  800467:	eb ea                	jmp    800453 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800469:	8b 10                	mov    (%eax),%edx
  80046b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046e:	89 08                	mov    %ecx,(%eax)
  800470:	8b 02                	mov    (%edx),%eax
  800472:	ba 00 00 00 00       	mov    $0x0,%edx
  800477:	eb da                	jmp    800453 <getuint+0x14>

00800479 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800479:	55                   	push   %ebp
  80047a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80047c:	83 fa 01             	cmp    $0x1,%edx
  80047f:	7e 0e                	jle    80048f <getint+0x16>
		return va_arg(*ap, long long);
  800481:	8b 10                	mov    (%eax),%edx
  800483:	8d 4a 08             	lea    0x8(%edx),%ecx
  800486:	89 08                	mov    %ecx,(%eax)
  800488:	8b 02                	mov    (%edx),%eax
  80048a:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  80048d:	5d                   	pop    %ebp
  80048e:	c3                   	ret    
	else if (lflag)
  80048f:	85 d2                	test   %edx,%edx
  800491:	75 0c                	jne    80049f <getint+0x26>
		return va_arg(*ap, int);
  800493:	8b 10                	mov    (%eax),%edx
  800495:	8d 4a 04             	lea    0x4(%edx),%ecx
  800498:	89 08                	mov    %ecx,(%eax)
  80049a:	8b 02                	mov    (%edx),%eax
  80049c:	99                   	cltd   
  80049d:	eb ee                	jmp    80048d <getint+0x14>
		return va_arg(*ap, long);
  80049f:	8b 10                	mov    (%eax),%edx
  8004a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a4:	89 08                	mov    %ecx,(%eax)
  8004a6:	8b 02                	mov    (%edx),%eax
  8004a8:	99                   	cltd   
  8004a9:	eb e2                	jmp    80048d <getint+0x14>

008004ab <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b5:	8b 10                	mov    (%eax),%edx
  8004b7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ba:	73 0a                	jae    8004c6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004bc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004bf:	89 08                	mov    %ecx,(%eax)
  8004c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c4:	88 02                	mov    %al,(%edx)
}
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <printfmt>:
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d1:	50                   	push   %eax
  8004d2:	ff 75 10             	pushl  0x10(%ebp)
  8004d5:	ff 75 0c             	pushl  0xc(%ebp)
  8004d8:	ff 75 08             	pushl  0x8(%ebp)
  8004db:	e8 05 00 00 00       	call   8004e5 <vprintfmt>
}
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	c9                   	leave  
  8004e4:	c3                   	ret    

008004e5 <vprintfmt>:
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	57                   	push   %edi
  8004e9:	56                   	push   %esi
  8004ea:	53                   	push   %ebx
  8004eb:	83 ec 2c             	sub    $0x2c,%esp
  8004ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004f4:	89 f7                	mov    %esi,%edi
  8004f6:	89 de                	mov    %ebx,%esi
  8004f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004fb:	e9 9e 02 00 00       	jmp    80079e <vprintfmt+0x2b9>
		padc = ' ';
  800500:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800504:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80050b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800512:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800519:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8d 43 01             	lea    0x1(%ebx),%eax
  800521:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800524:	0f b6 0b             	movzbl (%ebx),%ecx
  800527:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80052a:	3c 55                	cmp    $0x55,%al
  80052c:	0f 87 e8 02 00 00    	ja     80081a <vprintfmt+0x335>
  800532:	0f b6 c0             	movzbl %al,%eax
  800535:	ff 24 85 80 0f 80 00 	jmp    *0x800f80(,%eax,4)
  80053c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80053f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800543:	eb d9                	jmp    80051e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800548:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80054c:	eb d0                	jmp    80051e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	0f b6 c9             	movzbl %cl,%ecx
  800551:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800554:	b8 00 00 00 00       	mov    $0x0,%eax
  800559:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80055c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800563:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800566:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800569:	83 fa 09             	cmp    $0x9,%edx
  80056c:	77 52                	ja     8005c0 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  80056e:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800571:	eb e9                	jmp    80055c <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 48 04             	lea    0x4(%eax),%ecx
  800579:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80057c:	8b 00                	mov    (%eax),%eax
  80057e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800584:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800588:	79 94                	jns    80051e <vprintfmt+0x39>
				width = precision, precision = -1;
  80058a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80058d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800590:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800597:	eb 85                	jmp    80051e <vprintfmt+0x39>
  800599:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059c:	85 c0                	test   %eax,%eax
  80059e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a3:	0f 49 c8             	cmovns %eax,%ecx
  8005a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ac:	e9 6d ff ff ff       	jmp    80051e <vprintfmt+0x39>
  8005b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8005b4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005bb:	e9 5e ff ff ff       	jmp    80051e <vprintfmt+0x39>
  8005c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c6:	eb bc                	jmp    800584 <vprintfmt+0x9f>
			lflag++;
  8005c8:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8005ce:	e9 4b ff ff ff       	jmp    80051e <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 04             	lea    0x4(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	57                   	push   %edi
  8005e0:	ff 30                	pushl  (%eax)
  8005e2:	ff d6                	call   *%esi
			break;
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	e9 af 01 00 00       	jmp    80079b <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	99                   	cltd   
  8005f8:	31 d0                	xor    %edx,%eax
  8005fa:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fc:	83 f8 08             	cmp    $0x8,%eax
  8005ff:	7f 20                	jg     800621 <vprintfmt+0x13c>
  800601:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  800608:	85 d2                	test   %edx,%edx
  80060a:	74 15                	je     800621 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80060c:	52                   	push   %edx
  80060d:	68 e3 0e 80 00       	push   $0x800ee3
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	e8 af fe ff ff       	call   8004c8 <printfmt>
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	e9 7a 01 00 00       	jmp    80079b <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800621:	50                   	push   %eax
  800622:	68 da 0e 80 00       	push   $0x800eda
  800627:	57                   	push   %edi
  800628:	56                   	push   %esi
  800629:	e8 9a fe ff ff       	call   8004c8 <printfmt>
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	e9 65 01 00 00       	jmp    80079b <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 50 04             	lea    0x4(%eax),%edx
  80063c:	89 55 14             	mov    %edx,0x14(%ebp)
  80063f:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800641:	85 db                	test   %ebx,%ebx
  800643:	b8 d3 0e 80 00       	mov    $0x800ed3,%eax
  800648:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  80064b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80064f:	0f 8e bd 00 00 00    	jle    800712 <vprintfmt+0x22d>
  800655:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800659:	75 0e                	jne    800669 <vprintfmt+0x184>
  80065b:	89 75 08             	mov    %esi,0x8(%ebp)
  80065e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800661:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800664:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800667:	eb 6d                	jmp    8006d6 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	ff 75 d0             	pushl  -0x30(%ebp)
  80066f:	53                   	push   %ebx
  800670:	e8 4d 02 00 00       	call   8008c2 <strnlen>
  800675:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800678:	29 c1                	sub    %eax,%ecx
  80067a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80067d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800680:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800684:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800687:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80068a:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80068c:	eb 0f                	jmp    80069d <vprintfmt+0x1b8>
					putch(padc, putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	57                   	push   %edi
  800692:	ff 75 e0             	pushl  -0x20(%ebp)
  800695:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800697:	83 eb 01             	sub    $0x1,%ebx
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	85 db                	test   %ebx,%ebx
  80069f:	7f ed                	jg     80068e <vprintfmt+0x1a9>
  8006a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006a4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006a7:	85 c9                	test   %ecx,%ecx
  8006a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ae:	0f 49 c1             	cmovns %ecx,%eax
  8006b1:	29 c1                	sub    %eax,%ecx
  8006b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b9:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006bc:	89 cf                	mov    %ecx,%edi
  8006be:	eb 16                	jmp    8006d6 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8006c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c4:	75 31                	jne    8006f7 <vprintfmt+0x212>
					putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	ff 75 0c             	pushl  0xc(%ebp)
  8006cc:	50                   	push   %eax
  8006cd:	ff 55 08             	call   *0x8(%ebp)
  8006d0:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d3:	83 ef 01             	sub    $0x1,%edi
  8006d6:	83 c3 01             	add    $0x1,%ebx
  8006d9:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8006dd:	0f be c2             	movsbl %dl,%eax
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 50                	je     800734 <vprintfmt+0x24f>
  8006e4:	85 f6                	test   %esi,%esi
  8006e6:	78 d8                	js     8006c0 <vprintfmt+0x1db>
  8006e8:	83 ee 01             	sub    $0x1,%esi
  8006eb:	79 d3                	jns    8006c0 <vprintfmt+0x1db>
  8006ed:	89 fb                	mov    %edi,%ebx
  8006ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006f5:	eb 37                	jmp    80072e <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f7:	0f be d2             	movsbl %dl,%edx
  8006fa:	83 ea 20             	sub    $0x20,%edx
  8006fd:	83 fa 5e             	cmp    $0x5e,%edx
  800700:	76 c4                	jbe    8006c6 <vprintfmt+0x1e1>
					putch('?', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	6a 3f                	push   $0x3f
  80070a:	ff 55 08             	call   *0x8(%ebp)
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	eb c1                	jmp    8006d3 <vprintfmt+0x1ee>
  800712:	89 75 08             	mov    %esi,0x8(%ebp)
  800715:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800718:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80071b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80071e:	eb b6                	jmp    8006d6 <vprintfmt+0x1f1>
				putch(' ', putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	57                   	push   %edi
  800724:	6a 20                	push   $0x20
  800726:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800728:	83 eb 01             	sub    $0x1,%ebx
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 db                	test   %ebx,%ebx
  800730:	7f ee                	jg     800720 <vprintfmt+0x23b>
  800732:	eb 67                	jmp    80079b <vprintfmt+0x2b6>
  800734:	89 fb                	mov    %edi,%ebx
  800736:	8b 75 08             	mov    0x8(%ebp),%esi
  800739:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80073c:	eb f0                	jmp    80072e <vprintfmt+0x249>
			num = getint(&ap, lflag);
  80073e:	8d 45 14             	lea    0x14(%ebp),%eax
  800741:	e8 33 fd ff ff       	call   800479 <getint>
  800746:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800749:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80074c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800751:	85 d2                	test   %edx,%edx
  800753:	79 2c                	jns    800781 <vprintfmt+0x29c>
				putch('-', putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	57                   	push   %edi
  800759:	6a 2d                	push   $0x2d
  80075b:	ff d6                	call   *%esi
				num = -(long long) num;
  80075d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800760:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800763:	f7 d8                	neg    %eax
  800765:	83 d2 00             	adc    $0x0,%edx
  800768:	f7 da                	neg    %edx
  80076a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80076d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800772:	eb 0d                	jmp    800781 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800774:	8d 45 14             	lea    0x14(%ebp),%eax
  800777:	e8 c3 fc ff ff       	call   80043f <getuint>
			base = 10;
  80077c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800781:	83 ec 0c             	sub    $0xc,%esp
  800784:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  800788:	53                   	push   %ebx
  800789:	ff 75 e0             	pushl  -0x20(%ebp)
  80078c:	51                   	push   %ecx
  80078d:	52                   	push   %edx
  80078e:	50                   	push   %eax
  80078f:	89 fa                	mov    %edi,%edx
  800791:	89 f0                	mov    %esi,%eax
  800793:	e8 f8 fb ff ff       	call   800390 <printnum>
			break;
  800798:	83 c4 20             	add    $0x20,%esp
{
  80079b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80079e:	83 c3 01             	add    $0x1,%ebx
  8007a1:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8007a5:	83 f8 25             	cmp    $0x25,%eax
  8007a8:	0f 84 52 fd ff ff    	je     800500 <vprintfmt+0x1b>
			if (ch == '\0')
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	0f 84 84 00 00 00    	je     80083a <vprintfmt+0x355>
			putch(ch, putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	57                   	push   %edi
  8007ba:	50                   	push   %eax
  8007bb:	ff d6                	call   *%esi
  8007bd:	83 c4 10             	add    $0x10,%esp
  8007c0:	eb dc                	jmp    80079e <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c5:	e8 75 fc ff ff       	call   80043f <getuint>
			base = 8;
  8007ca:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007cf:	eb b0                	jmp    800781 <vprintfmt+0x29c>
			putch('0', putdat);
  8007d1:	83 ec 08             	sub    $0x8,%esp
  8007d4:	57                   	push   %edi
  8007d5:	6a 30                	push   $0x30
  8007d7:	ff d6                	call   *%esi
			putch('x', putdat);
  8007d9:	83 c4 08             	add    $0x8,%esp
  8007dc:	57                   	push   %edi
  8007dd:	6a 78                	push   $0x78
  8007df:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 50 04             	lea    0x4(%eax),%edx
  8007e7:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007ea:	8b 00                	mov    (%eax),%eax
  8007ec:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8007f1:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007f4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007f9:	eb 86                	jmp    800781 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fe:	e8 3c fc ff ff       	call   80043f <getuint>
			base = 16;
  800803:	b9 10 00 00 00       	mov    $0x10,%ecx
  800808:	e9 74 ff ff ff       	jmp    800781 <vprintfmt+0x29c>
			putch(ch, putdat);
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	57                   	push   %edi
  800811:	6a 25                	push   $0x25
  800813:	ff d6                	call   *%esi
			break;
  800815:	83 c4 10             	add    $0x10,%esp
  800818:	eb 81                	jmp    80079b <vprintfmt+0x2b6>
			putch('%', putdat);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	57                   	push   %edi
  80081e:	6a 25                	push   $0x25
  800820:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	89 d8                	mov    %ebx,%eax
  800827:	eb 03                	jmp    80082c <vprintfmt+0x347>
  800829:	83 e8 01             	sub    $0x1,%eax
  80082c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800830:	75 f7                	jne    800829 <vprintfmt+0x344>
  800832:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800835:	e9 61 ff ff ff       	jmp    80079b <vprintfmt+0x2b6>
}
  80083a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5f                   	pop    %edi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	83 ec 18             	sub    $0x18,%esp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800851:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800855:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800858:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085f:	85 c0                	test   %eax,%eax
  800861:	74 26                	je     800889 <vsnprintf+0x47>
  800863:	85 d2                	test   %edx,%edx
  800865:	7e 22                	jle    800889 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800867:	ff 75 14             	pushl  0x14(%ebp)
  80086a:	ff 75 10             	pushl  0x10(%ebp)
  80086d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	68 ab 04 80 00       	push   $0x8004ab
  800876:	e8 6a fc ff ff       	call   8004e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800884:	83 c4 10             	add    $0x10,%esp
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    
		return -E_INVAL;
  800889:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088e:	eb f7                	jmp    800887 <vsnprintf+0x45>

00800890 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800899:	50                   	push   %eax
  80089a:	ff 75 10             	pushl  0x10(%ebp)
  80089d:	ff 75 0c             	pushl  0xc(%ebp)
  8008a0:	ff 75 08             	pushl  0x8(%ebp)
  8008a3:	e8 9a ff ff ff       	call   800842 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b5:	eb 03                	jmp    8008ba <strlen+0x10>
		n++;
  8008b7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008ba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008be:	75 f7                	jne    8008b7 <strlen+0xd>
	return n;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d0:	eb 03                	jmp    8008d5 <strnlen+0x13>
		n++;
  8008d2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d5:	39 d0                	cmp    %edx,%eax
  8008d7:	74 06                	je     8008df <strnlen+0x1d>
  8008d9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008dd:	75 f3                	jne    8008d2 <strnlen+0x10>
	return n;
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008eb:	89 c2                	mov    %eax,%edx
  8008ed:	83 c1 01             	add    $0x1,%ecx
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fa:	84 db                	test   %bl,%bl
  8008fc:	75 ef                	jne    8008ed <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008fe:	5b                   	pop    %ebx
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800908:	53                   	push   %ebx
  800909:	e8 9c ff ff ff       	call   8008aa <strlen>
  80090e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800911:	ff 75 0c             	pushl  0xc(%ebp)
  800914:	01 d8                	add    %ebx,%eax
  800916:	50                   	push   %eax
  800917:	e8 c5 ff ff ff       	call   8008e1 <strcpy>
	return dst;
}
  80091c:	89 d8                	mov    %ebx,%eax
  80091e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 75 08             	mov    0x8(%ebp),%esi
  80092b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092e:	89 f3                	mov    %esi,%ebx
  800930:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800933:	89 f2                	mov    %esi,%edx
  800935:	eb 0f                	jmp    800946 <strncpy+0x23>
		*dst++ = *src;
  800937:	83 c2 01             	add    $0x1,%edx
  80093a:	0f b6 01             	movzbl (%ecx),%eax
  80093d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800940:	80 39 01             	cmpb   $0x1,(%ecx)
  800943:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800946:	39 da                	cmp    %ebx,%edx
  800948:	75 ed                	jne    800937 <strncpy+0x14>
	}
	return ret;
}
  80094a:	89 f0                	mov    %esi,%eax
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	8b 75 08             	mov    0x8(%ebp),%esi
  800958:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80095e:	89 f0                	mov    %esi,%eax
  800960:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800964:	85 c9                	test   %ecx,%ecx
  800966:	75 0b                	jne    800973 <strlcpy+0x23>
  800968:	eb 17                	jmp    800981 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096a:	83 c2 01             	add    $0x1,%edx
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800973:	39 d8                	cmp    %ebx,%eax
  800975:	74 07                	je     80097e <strlcpy+0x2e>
  800977:	0f b6 0a             	movzbl (%edx),%ecx
  80097a:	84 c9                	test   %cl,%cl
  80097c:	75 ec                	jne    80096a <strlcpy+0x1a>
		*dst = '\0';
  80097e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800981:	29 f0                	sub    %esi,%eax
}
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800990:	eb 06                	jmp    800998 <strcmp+0x11>
		p++, q++;
  800992:	83 c1 01             	add    $0x1,%ecx
  800995:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800998:	0f b6 01             	movzbl (%ecx),%eax
  80099b:	84 c0                	test   %al,%al
  80099d:	74 04                	je     8009a3 <strcmp+0x1c>
  80099f:	3a 02                	cmp    (%edx),%al
  8009a1:	74 ef                	je     800992 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a3:	0f b6 c0             	movzbl %al,%eax
  8009a6:	0f b6 12             	movzbl (%edx),%edx
  8009a9:	29 d0                	sub    %edx,%eax
}
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	53                   	push   %ebx
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b7:	89 c3                	mov    %eax,%ebx
  8009b9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009bc:	eb 06                	jmp    8009c4 <strncmp+0x17>
		n--, p++, q++;
  8009be:	83 c0 01             	add    $0x1,%eax
  8009c1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c4:	39 d8                	cmp    %ebx,%eax
  8009c6:	74 16                	je     8009de <strncmp+0x31>
  8009c8:	0f b6 08             	movzbl (%eax),%ecx
  8009cb:	84 c9                	test   %cl,%cl
  8009cd:	74 04                	je     8009d3 <strncmp+0x26>
  8009cf:	3a 0a                	cmp    (%edx),%cl
  8009d1:	74 eb                	je     8009be <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d3:	0f b6 00             	movzbl (%eax),%eax
  8009d6:	0f b6 12             	movzbl (%edx),%edx
  8009d9:	29 d0                	sub    %edx,%eax
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    
		return 0;
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e3:	eb f6                	jmp    8009db <strncmp+0x2e>

008009e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ef:	0f b6 10             	movzbl (%eax),%edx
  8009f2:	84 d2                	test   %dl,%dl
  8009f4:	74 09                	je     8009ff <strchr+0x1a>
		if (*s == c)
  8009f6:	38 ca                	cmp    %cl,%dl
  8009f8:	74 0a                	je     800a04 <strchr+0x1f>
	for (; *s; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	eb f0                	jmp    8009ef <strchr+0xa>
			return (char *) s;
	return 0;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a10:	eb 03                	jmp    800a15 <strfind+0xf>
  800a12:	83 c0 01             	add    $0x1,%eax
  800a15:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a18:	38 ca                	cmp    %cl,%dl
  800a1a:	74 04                	je     800a20 <strfind+0x1a>
  800a1c:	84 d2                	test   %dl,%dl
  800a1e:	75 f2                	jne    800a12 <strfind+0xc>
			break;
	return (char *) s;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a2e:	85 c9                	test   %ecx,%ecx
  800a30:	74 12                	je     800a44 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a32:	f6 c2 03             	test   $0x3,%dl
  800a35:	75 05                	jne    800a3c <memset+0x1a>
  800a37:	f6 c1 03             	test   $0x3,%cl
  800a3a:	74 0f                	je     800a4b <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3c:	89 d7                	mov    %edx,%edi
  800a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a41:	fc                   	cld    
  800a42:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a44:	89 d0                	mov    %edx,%eax
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    
		c &= 0xFF;
  800a4b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4f:	89 d8                	mov    %ebx,%eax
  800a51:	c1 e0 08             	shl    $0x8,%eax
  800a54:	89 df                	mov    %ebx,%edi
  800a56:	c1 e7 18             	shl    $0x18,%edi
  800a59:	89 de                	mov    %ebx,%esi
  800a5b:	c1 e6 10             	shl    $0x10,%esi
  800a5e:	09 f7                	or     %esi,%edi
  800a60:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800a62:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a65:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a67:	89 d7                	mov    %edx,%edi
  800a69:	fc                   	cld    
  800a6a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6c:	eb d6                	jmp    800a44 <memset+0x22>

00800a6e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7c:	39 c6                	cmp    %eax,%esi
  800a7e:	73 35                	jae    800ab5 <memmove+0x47>
  800a80:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a83:	39 c2                	cmp    %eax,%edx
  800a85:	76 2e                	jbe    800ab5 <memmove+0x47>
		s += n;
		d += n;
  800a87:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8a:	89 d6                	mov    %edx,%esi
  800a8c:	09 fe                	or     %edi,%esi
  800a8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a94:	74 0c                	je     800aa2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a96:	83 ef 01             	sub    $0x1,%edi
  800a99:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a9c:	fd                   	std    
  800a9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9f:	fc                   	cld    
  800aa0:	eb 21                	jmp    800ac3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa2:	f6 c1 03             	test   $0x3,%cl
  800aa5:	75 ef                	jne    800a96 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa7:	83 ef 04             	sub    $0x4,%edi
  800aaa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aad:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab0:	fd                   	std    
  800ab1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab3:	eb ea                	jmp    800a9f <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab5:	89 f2                	mov    %esi,%edx
  800ab7:	09 c2                	or     %eax,%edx
  800ab9:	f6 c2 03             	test   $0x3,%dl
  800abc:	74 09                	je     800ac7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800abe:	89 c7                	mov    %eax,%edi
  800ac0:	fc                   	cld    
  800ac1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac7:	f6 c1 03             	test   $0x3,%cl
  800aca:	75 f2                	jne    800abe <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800acc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800acf:	89 c7                	mov    %eax,%edi
  800ad1:	fc                   	cld    
  800ad2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad4:	eb ed                	jmp    800ac3 <memmove+0x55>

00800ad6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ad9:	ff 75 10             	pushl  0x10(%ebp)
  800adc:	ff 75 0c             	pushl  0xc(%ebp)
  800adf:	ff 75 08             	pushl  0x8(%ebp)
  800ae2:	e8 87 ff ff ff       	call   800a6e <memmove>
}
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af4:	89 c6                	mov    %eax,%esi
  800af6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	39 f0                	cmp    %esi,%eax
  800afb:	74 1c                	je     800b19 <memcmp+0x30>
		if (*s1 != *s2)
  800afd:	0f b6 08             	movzbl (%eax),%ecx
  800b00:	0f b6 1a             	movzbl (%edx),%ebx
  800b03:	38 d9                	cmp    %bl,%cl
  800b05:	75 08                	jne    800b0f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b07:	83 c0 01             	add    $0x1,%eax
  800b0a:	83 c2 01             	add    $0x1,%edx
  800b0d:	eb ea                	jmp    800af9 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b0f:	0f b6 c1             	movzbl %cl,%eax
  800b12:	0f b6 db             	movzbl %bl,%ebx
  800b15:	29 d8                	sub    %ebx,%eax
  800b17:	eb 05                	jmp    800b1e <memcmp+0x35>
	}

	return 0;
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b30:	39 d0                	cmp    %edx,%eax
  800b32:	73 09                	jae    800b3d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b34:	38 08                	cmp    %cl,(%eax)
  800b36:	74 05                	je     800b3d <memfind+0x1b>
	for (; s < ends; s++)
  800b38:	83 c0 01             	add    $0x1,%eax
  800b3b:	eb f3                	jmp    800b30 <memfind+0xe>
			break;
	return (void *) s;
}
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4b:	eb 03                	jmp    800b50 <strtol+0x11>
		s++;
  800b4d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b50:	0f b6 01             	movzbl (%ecx),%eax
  800b53:	3c 20                	cmp    $0x20,%al
  800b55:	74 f6                	je     800b4d <strtol+0xe>
  800b57:	3c 09                	cmp    $0x9,%al
  800b59:	74 f2                	je     800b4d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b5b:	3c 2b                	cmp    $0x2b,%al
  800b5d:	74 2e                	je     800b8d <strtol+0x4e>
	int neg = 0;
  800b5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b64:	3c 2d                	cmp    $0x2d,%al
  800b66:	74 2f                	je     800b97 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b68:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6e:	75 05                	jne    800b75 <strtol+0x36>
  800b70:	80 39 30             	cmpb   $0x30,(%ecx)
  800b73:	74 2c                	je     800ba1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b75:	85 db                	test   %ebx,%ebx
  800b77:	75 0a                	jne    800b83 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b79:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b7e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b81:	74 28                	je     800bab <strtol+0x6c>
		base = 10;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b8b:	eb 50                	jmp    800bdd <strtol+0x9e>
		s++;
  800b8d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b90:	bf 00 00 00 00       	mov    $0x0,%edi
  800b95:	eb d1                	jmp    800b68 <strtol+0x29>
		s++, neg = 1;
  800b97:	83 c1 01             	add    $0x1,%ecx
  800b9a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b9f:	eb c7                	jmp    800b68 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba5:	74 0e                	je     800bb5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ba7:	85 db                	test   %ebx,%ebx
  800ba9:	75 d8                	jne    800b83 <strtol+0x44>
		s++, base = 8;
  800bab:	83 c1 01             	add    $0x1,%ecx
  800bae:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb3:	eb ce                	jmp    800b83 <strtol+0x44>
		s += 2, base = 16;
  800bb5:	83 c1 02             	add    $0x2,%ecx
  800bb8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bbd:	eb c4                	jmp    800b83 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bbf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bc2:	89 f3                	mov    %esi,%ebx
  800bc4:	80 fb 19             	cmp    $0x19,%bl
  800bc7:	77 29                	ja     800bf2 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bc9:	0f be d2             	movsbl %dl,%edx
  800bcc:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd2:	7d 30                	jge    800c04 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd4:	83 c1 01             	add    $0x1,%ecx
  800bd7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bdb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bdd:	0f b6 11             	movzbl (%ecx),%edx
  800be0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be3:	89 f3                	mov    %esi,%ebx
  800be5:	80 fb 09             	cmp    $0x9,%bl
  800be8:	77 d5                	ja     800bbf <strtol+0x80>
			dig = *s - '0';
  800bea:	0f be d2             	movsbl %dl,%edx
  800bed:	83 ea 30             	sub    $0x30,%edx
  800bf0:	eb dd                	jmp    800bcf <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bf2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf5:	89 f3                	mov    %esi,%ebx
  800bf7:	80 fb 19             	cmp    $0x19,%bl
  800bfa:	77 08                	ja     800c04 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bfc:	0f be d2             	movsbl %dl,%edx
  800bff:	83 ea 37             	sub    $0x37,%edx
  800c02:	eb cb                	jmp    800bcf <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c08:	74 05                	je     800c0f <strtol+0xd0>
		*endptr = (char *) s;
  800c0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c0f:	89 c2                	mov    %eax,%edx
  800c11:	f7 da                	neg    %edx
  800c13:	85 ff                	test   %edi,%edi
  800c15:	0f 45 c2             	cmovne %edx,%eax
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    
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
