
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800044:	e8 02 01 00 00       	call   80014b <sys_getenvid>
	if (id >= 0)
  800049:	85 c0                	test   %eax,%eax
  80004b:	78 12                	js     80005f <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  80004d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800052:	c1 e0 07             	shl    $0x7,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x31>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0a 00 00 00       	call   800083 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007f:	5b                   	pop    %ebx
  800080:	5e                   	pop    %esi
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800089:	6a 00                	push   $0x0
  80008b:	e8 99 00 00 00       	call   800129 <sys_env_destroy>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	57                   	push   %edi
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
  80009b:	83 ec 1c             	sub    $0x1c,%esp
  80009e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000a4:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ac:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000af:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000b8:	74 04                	je     8000be <syscall+0x29>
  8000ba:	85 c0                	test   %eax,%eax
  8000bc:	7f 08                	jg     8000c6 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    
  8000c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  8000c9:	83 ec 0c             	sub    $0xc,%esp
  8000cc:	50                   	push   %eax
  8000cd:	52                   	push   %edx
  8000ce:	68 6a 0e 80 00       	push   $0x800e6a
  8000d3:	6a 23                	push   $0x23
  8000d5:	68 87 0e 80 00       	push   $0x800e87
  8000da:	e8 b1 01 00 00       	call   800290 <_panic>

008000df <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	6a 00                	push   $0x0
  8000eb:	ff 75 0c             	pushl  0xc(%ebp)
  8000ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fb:	e8 95 ff ff ff       	call   800095 <syscall>
}
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <sys_cgetc>:

int
sys_cgetc(void)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80010b:	6a 00                	push   $0x0
  80010d:	6a 00                	push   $0x0
  80010f:	6a 00                	push   $0x0
  800111:	6a 00                	push   $0x0
  800113:	b9 00 00 00 00       	mov    $0x0,%ecx
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	b8 01 00 00 00       	mov    $0x1,%eax
  800122:	e8 6e ff ff ff       	call   800095 <syscall>
}
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80012f:	6a 00                	push   $0x0
  800131:	6a 00                	push   $0x0
  800133:	6a 00                	push   $0x0
  800135:	6a 00                	push   $0x0
  800137:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013a:	ba 01 00 00 00       	mov    $0x1,%edx
  80013f:	b8 03 00 00 00       	mov    $0x3,%eax
  800144:	e8 4c ff ff ff       	call   800095 <syscall>
}
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	6a 00                	push   $0x0
  800157:	6a 00                	push   $0x0
  800159:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015e:	ba 00 00 00 00       	mov    $0x0,%edx
  800163:	b8 02 00 00 00       	mov    $0x2,%eax
  800168:	e8 28 ff ff ff       	call   800095 <syscall>
}
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <sys_yield>:

void
sys_yield(void)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800175:	6a 00                	push   $0x0
  800177:	6a 00                	push   $0x0
  800179:	6a 00                	push   $0x0
  80017b:	6a 00                	push   $0x0
  80017d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800182:	ba 00 00 00 00       	mov    $0x0,%edx
  800187:	b8 0a 00 00 00       	mov    $0xa,%eax
  80018c:	e8 04 ff ff ff       	call   800095 <syscall>
}
  800191:	83 c4 10             	add    $0x10,%esp
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80019c:	6a 00                	push   $0x0
  80019e:	6a 00                	push   $0x0
  8001a0:	ff 75 10             	pushl  0x10(%ebp)
  8001a3:	ff 75 0c             	pushl  0xc(%ebp)
  8001a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ae:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b3:	e8 dd fe ff ff       	call   800095 <syscall>
}
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff 75 14             	pushl  0x14(%ebp)
  8001c6:	ff 75 10             	pushl  0x10(%ebp)
  8001c9:	ff 75 0c             	pushl  0xc(%ebp)
  8001cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cf:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d9:	e8 b7 fe ff ff       	call   800095 <syscall>
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001e6:	6a 00                	push   $0x0
  8001e8:	6a 00                	push   $0x0
  8001ea:	6a 00                	push   $0x0
  8001ec:	ff 75 0c             	pushl  0xc(%ebp)
  8001ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f2:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fc:	e8 94 fe ff ff       	call   800095 <syscall>
}
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800209:	6a 00                	push   $0x0
  80020b:	6a 00                	push   $0x0
  80020d:	6a 00                	push   $0x0
  80020f:	ff 75 0c             	pushl  0xc(%ebp)
  800212:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800215:	ba 01 00 00 00       	mov    $0x1,%edx
  80021a:	b8 08 00 00 00       	mov    $0x8,%eax
  80021f:	e8 71 fe ff ff       	call   800095 <syscall>
}
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80022c:	6a 00                	push   $0x0
  80022e:	6a 00                	push   $0x0
  800230:	6a 00                	push   $0x0
  800232:	ff 75 0c             	pushl  0xc(%ebp)
  800235:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800238:	ba 01 00 00 00       	mov    $0x1,%edx
  80023d:	b8 09 00 00 00       	mov    $0x9,%eax
  800242:	e8 4e fe ff ff       	call   800095 <syscall>
}
  800247:	c9                   	leave  
  800248:	c3                   	ret    

00800249 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80024f:	6a 00                	push   $0x0
  800251:	ff 75 14             	pushl  0x14(%ebp)
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	ff 75 0c             	pushl  0xc(%ebp)
  80025a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025d:	ba 00 00 00 00       	mov    $0x0,%edx
  800262:	b8 0b 00 00 00       	mov    $0xb,%eax
  800267:	e8 29 fe ff ff       	call   800095 <syscall>
}
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800274:	6a 00                	push   $0x0
  800276:	6a 00                	push   $0x0
  800278:	6a 00                	push   $0x0
  80027a:	6a 00                	push   $0x0
  80027c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027f:	ba 01 00 00 00       	mov    $0x1,%edx
  800284:	b8 0c 00 00 00       	mov    $0xc,%eax
  800289:	e8 07 fe ff ff       	call   800095 <syscall>
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800295:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800298:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80029e:	e8 a8 fe ff ff       	call   80014b <sys_getenvid>
  8002a3:	83 ec 0c             	sub    $0xc,%esp
  8002a6:	ff 75 0c             	pushl  0xc(%ebp)
  8002a9:	ff 75 08             	pushl  0x8(%ebp)
  8002ac:	56                   	push   %esi
  8002ad:	50                   	push   %eax
  8002ae:	68 98 0e 80 00       	push   $0x800e98
  8002b3:	e8 b3 00 00 00       	call   80036b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002b8:	83 c4 18             	add    $0x18,%esp
  8002bb:	53                   	push   %ebx
  8002bc:	ff 75 10             	pushl  0x10(%ebp)
  8002bf:	e8 56 00 00 00       	call   80031a <vcprintf>
	cprintf("\n");
  8002c4:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  8002cb:	e8 9b 00 00 00       	call   80036b <cprintf>
  8002d0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d3:	cc                   	int3   
  8002d4:	eb fd                	jmp    8002d3 <_panic+0x43>

008002d6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 04             	sub    $0x4,%esp
  8002dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e0:	8b 13                	mov    (%ebx),%edx
  8002e2:	8d 42 01             	lea    0x1(%edx),%eax
  8002e5:	89 03                	mov    %eax,(%ebx)
  8002e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f3:	74 09                	je     8002fe <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002f5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002fe:	83 ec 08             	sub    $0x8,%esp
  800301:	68 ff 00 00 00       	push   $0xff
  800306:	8d 43 08             	lea    0x8(%ebx),%eax
  800309:	50                   	push   %eax
  80030a:	e8 d0 fd ff ff       	call   8000df <sys_cputs>
		b->idx = 0;
  80030f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800315:	83 c4 10             	add    $0x10,%esp
  800318:	eb db                	jmp    8002f5 <putch+0x1f>

0080031a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800323:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032a:	00 00 00 
	b.cnt = 0;
  80032d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800334:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800337:	ff 75 0c             	pushl  0xc(%ebp)
  80033a:	ff 75 08             	pushl  0x8(%ebp)
  80033d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800343:	50                   	push   %eax
  800344:	68 d6 02 80 00       	push   $0x8002d6
  800349:	e8 86 01 00 00       	call   8004d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80034e:	83 c4 08             	add    $0x8,%esp
  800351:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800357:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80035d:	50                   	push   %eax
  80035e:	e8 7c fd ff ff       	call   8000df <sys_cputs>

	return b.cnt;
}
  800363:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800369:	c9                   	leave  
  80036a:	c3                   	ret    

0080036b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800371:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800374:	50                   	push   %eax
  800375:	ff 75 08             	pushl  0x8(%ebp)
  800378:	e8 9d ff ff ff       	call   80031a <vcprintf>
	va_end(ap);

	return cnt;
}
  80037d:	c9                   	leave  
  80037e:	c3                   	ret    

0080037f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	57                   	push   %edi
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
  800385:	83 ec 1c             	sub    $0x1c,%esp
  800388:	89 c7                	mov    %eax,%edi
  80038a:	89 d6                	mov    %edx,%esi
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
  80038f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800392:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800395:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800398:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80039b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003a6:	39 d3                	cmp    %edx,%ebx
  8003a8:	72 05                	jb     8003af <printnum+0x30>
  8003aa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ad:	77 7a                	ja     800429 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003af:	83 ec 0c             	sub    $0xc,%esp
  8003b2:	ff 75 18             	pushl  0x18(%ebp)
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003bb:	53                   	push   %ebx
  8003bc:	ff 75 10             	pushl  0x10(%ebp)
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ce:	e8 3d 08 00 00       	call   800c10 <__udivdi3>
  8003d3:	83 c4 18             	add    $0x18,%esp
  8003d6:	52                   	push   %edx
  8003d7:	50                   	push   %eax
  8003d8:	89 f2                	mov    %esi,%edx
  8003da:	89 f8                	mov    %edi,%eax
  8003dc:	e8 9e ff ff ff       	call   80037f <printnum>
  8003e1:	83 c4 20             	add    $0x20,%esp
  8003e4:	eb 13                	jmp    8003f9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003e6:	83 ec 08             	sub    $0x8,%esp
  8003e9:	56                   	push   %esi
  8003ea:	ff 75 18             	pushl  0x18(%ebp)
  8003ed:	ff d7                	call   *%edi
  8003ef:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003f2:	83 eb 01             	sub    $0x1,%ebx
  8003f5:	85 db                	test   %ebx,%ebx
  8003f7:	7f ed                	jg     8003e6 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	56                   	push   %esi
  8003fd:	83 ec 04             	sub    $0x4,%esp
  800400:	ff 75 e4             	pushl  -0x1c(%ebp)
  800403:	ff 75 e0             	pushl  -0x20(%ebp)
  800406:	ff 75 dc             	pushl  -0x24(%ebp)
  800409:	ff 75 d8             	pushl  -0x28(%ebp)
  80040c:	e8 1f 09 00 00       	call   800d30 <__umoddi3>
  800411:	83 c4 14             	add    $0x14,%esp
  800414:	0f be 80 be 0e 80 00 	movsbl 0x800ebe(%eax),%eax
  80041b:	50                   	push   %eax
  80041c:	ff d7                	call   *%edi
}
  80041e:	83 c4 10             	add    $0x10,%esp
  800421:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800424:	5b                   	pop    %ebx
  800425:	5e                   	pop    %esi
  800426:	5f                   	pop    %edi
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    
  800429:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80042c:	eb c4                	jmp    8003f2 <printnum+0x73>

0080042e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800431:	83 fa 01             	cmp    $0x1,%edx
  800434:	7e 0e                	jle    800444 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800436:	8b 10                	mov    (%eax),%edx
  800438:	8d 4a 08             	lea    0x8(%edx),%ecx
  80043b:	89 08                	mov    %ecx,(%eax)
  80043d:	8b 02                	mov    (%edx),%eax
  80043f:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    
	else if (lflag)
  800444:	85 d2                	test   %edx,%edx
  800446:	75 10                	jne    800458 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800448:	8b 10                	mov    (%eax),%edx
  80044a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044d:	89 08                	mov    %ecx,(%eax)
  80044f:	8b 02                	mov    (%edx),%eax
  800451:	ba 00 00 00 00       	mov    $0x0,%edx
  800456:	eb ea                	jmp    800442 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800458:	8b 10                	mov    (%eax),%edx
  80045a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045d:	89 08                	mov    %ecx,(%eax)
  80045f:	8b 02                	mov    (%edx),%eax
  800461:	ba 00 00 00 00       	mov    $0x0,%edx
  800466:	eb da                	jmp    800442 <getuint+0x14>

00800468 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046b:	83 fa 01             	cmp    $0x1,%edx
  80046e:	7e 0e                	jle    80047e <getint+0x16>
		return va_arg(*ap, long long);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 08             	lea    0x8(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    
	else if (lflag)
  80047e:	85 d2                	test   %edx,%edx
  800480:	75 0c                	jne    80048e <getint+0x26>
		return va_arg(*ap, int);
  800482:	8b 10                	mov    (%eax),%edx
  800484:	8d 4a 04             	lea    0x4(%edx),%ecx
  800487:	89 08                	mov    %ecx,(%eax)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	99                   	cltd   
  80048c:	eb ee                	jmp    80047c <getint+0x14>
		return va_arg(*ap, long);
  80048e:	8b 10                	mov    (%eax),%edx
  800490:	8d 4a 04             	lea    0x4(%edx),%ecx
  800493:	89 08                	mov    %ecx,(%eax)
  800495:	8b 02                	mov    (%edx),%eax
  800497:	99                   	cltd   
  800498:	eb e2                	jmp    80047c <getint+0x14>

0080049a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  80049d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a4:	8b 10                	mov    (%eax),%edx
  8004a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a9:	73 0a                	jae    8004b5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b3:	88 02                	mov    %al,(%edx)
}
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    

008004b7 <printfmt>:
{
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
  8004ba:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c0:	50                   	push   %eax
  8004c1:	ff 75 10             	pushl  0x10(%ebp)
  8004c4:	ff 75 0c             	pushl  0xc(%ebp)
  8004c7:	ff 75 08             	pushl  0x8(%ebp)
  8004ca:	e8 05 00 00 00       	call   8004d4 <vprintfmt>
}
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	c9                   	leave  
  8004d3:	c3                   	ret    

008004d4 <vprintfmt>:
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	57                   	push   %edi
  8004d8:	56                   	push   %esi
  8004d9:	53                   	push   %ebx
  8004da:	83 ec 2c             	sub    $0x2c,%esp
  8004dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004e3:	89 f7                	mov    %esi,%edi
  8004e5:	89 de                	mov    %ebx,%esi
  8004e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004ea:	e9 9e 02 00 00       	jmp    80078d <vprintfmt+0x2b9>
		padc = ' ';
  8004ef:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004f3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8004fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800501:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800508:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8d 43 01             	lea    0x1(%ebx),%eax
  800510:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800513:	0f b6 0b             	movzbl (%ebx),%ecx
  800516:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800519:	3c 55                	cmp    $0x55,%al
  80051b:	0f 87 e8 02 00 00    	ja     800809 <vprintfmt+0x335>
  800521:	0f b6 c0             	movzbl %al,%eax
  800524:	ff 24 85 80 0f 80 00 	jmp    *0x800f80(,%eax,4)
  80052b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80052e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800532:	eb d9                	jmp    80050d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800534:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800537:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80053b:	eb d0                	jmp    80050d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	0f b6 c9             	movzbl %cl,%ecx
  800540:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80054b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80054e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800552:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800555:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800558:	83 fa 09             	cmp    $0x9,%edx
  80055b:	77 52                	ja     8005af <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  80055d:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800560:	eb e9                	jmp    80054b <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 48 04             	lea    0x4(%eax),%ecx
  800568:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800573:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800577:	79 94                	jns    80050d <vprintfmt+0x39>
				width = precision, precision = -1;
  800579:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80057c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800586:	eb 85                	jmp    80050d <vprintfmt+0x39>
  800588:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058b:	85 c0                	test   %eax,%eax
  80058d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800592:	0f 49 c8             	cmovns %eax,%ecx
  800595:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80059b:	e9 6d ff ff ff       	jmp    80050d <vprintfmt+0x39>
  8005a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8005a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005aa:	e9 5e ff ff ff       	jmp    80050d <vprintfmt+0x39>
  8005af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005b5:	eb bc                	jmp    800573 <vprintfmt+0x9f>
			lflag++;
  8005b7:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8005bd:	e9 4b ff ff ff       	jmp    80050d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	57                   	push   %edi
  8005cf:	ff 30                	pushl  (%eax)
  8005d1:	ff d6                	call   *%esi
			break;
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	e9 af 01 00 00       	jmp    80078a <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	99                   	cltd   
  8005e7:	31 d0                	xor    %edx,%eax
  8005e9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005eb:	83 f8 08             	cmp    $0x8,%eax
  8005ee:	7f 20                	jg     800610 <vprintfmt+0x13c>
  8005f0:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  8005f7:	85 d2                	test   %edx,%edx
  8005f9:	74 15                	je     800610 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  8005fb:	52                   	push   %edx
  8005fc:	68 df 0e 80 00       	push   $0x800edf
  800601:	57                   	push   %edi
  800602:	56                   	push   %esi
  800603:	e8 af fe ff ff       	call   8004b7 <printfmt>
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	e9 7a 01 00 00       	jmp    80078a <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800610:	50                   	push   %eax
  800611:	68 d6 0e 80 00       	push   $0x800ed6
  800616:	57                   	push   %edi
  800617:	56                   	push   %esi
  800618:	e8 9a fe ff ff       	call   8004b7 <printfmt>
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	e9 65 01 00 00       	jmp    80078a <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 04             	lea    0x4(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800630:	85 db                	test   %ebx,%ebx
  800632:	b8 cf 0e 80 00       	mov    $0x800ecf,%eax
  800637:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  80063a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80063e:	0f 8e bd 00 00 00    	jle    800701 <vprintfmt+0x22d>
  800644:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800648:	75 0e                	jne    800658 <vprintfmt+0x184>
  80064a:	89 75 08             	mov    %esi,0x8(%ebp)
  80064d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800650:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800653:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800656:	eb 6d                	jmp    8006c5 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	ff 75 d0             	pushl  -0x30(%ebp)
  80065e:	53                   	push   %ebx
  80065f:	e8 4d 02 00 00       	call   8008b1 <strnlen>
  800664:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800667:	29 c1                	sub    %eax,%ecx
  800669:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80066c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80066f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800673:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800676:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800679:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80067b:	eb 0f                	jmp    80068c <vprintfmt+0x1b8>
					putch(padc, putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	57                   	push   %edi
  800681:	ff 75 e0             	pushl  -0x20(%ebp)
  800684:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800686:	83 eb 01             	sub    $0x1,%ebx
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	85 db                	test   %ebx,%ebx
  80068e:	7f ed                	jg     80067d <vprintfmt+0x1a9>
  800690:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800693:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800696:	85 c9                	test   %ecx,%ecx
  800698:	b8 00 00 00 00       	mov    $0x0,%eax
  80069d:	0f 49 c1             	cmovns %ecx,%eax
  8006a0:	29 c1                	sub    %eax,%ecx
  8006a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006ab:	89 cf                	mov    %ecx,%edi
  8006ad:	eb 16                	jmp    8006c5 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8006af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006b3:	75 31                	jne    8006e6 <vprintfmt+0x212>
					putch(ch, putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	ff 75 0c             	pushl  0xc(%ebp)
  8006bb:	50                   	push   %eax
  8006bc:	ff 55 08             	call   *0x8(%ebp)
  8006bf:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c2:	83 ef 01             	sub    $0x1,%edi
  8006c5:	83 c3 01             	add    $0x1,%ebx
  8006c8:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8006cc:	0f be c2             	movsbl %dl,%eax
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 50                	je     800723 <vprintfmt+0x24f>
  8006d3:	85 f6                	test   %esi,%esi
  8006d5:	78 d8                	js     8006af <vprintfmt+0x1db>
  8006d7:	83 ee 01             	sub    $0x1,%esi
  8006da:	79 d3                	jns    8006af <vprintfmt+0x1db>
  8006dc:	89 fb                	mov    %edi,%ebx
  8006de:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006e4:	eb 37                	jmp    80071d <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8006e6:	0f be d2             	movsbl %dl,%edx
  8006e9:	83 ea 20             	sub    $0x20,%edx
  8006ec:	83 fa 5e             	cmp    $0x5e,%edx
  8006ef:	76 c4                	jbe    8006b5 <vprintfmt+0x1e1>
					putch('?', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	ff 75 0c             	pushl  0xc(%ebp)
  8006f7:	6a 3f                	push   $0x3f
  8006f9:	ff 55 08             	call   *0x8(%ebp)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb c1                	jmp    8006c2 <vprintfmt+0x1ee>
  800701:	89 75 08             	mov    %esi,0x8(%ebp)
  800704:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800707:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80070a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80070d:	eb b6                	jmp    8006c5 <vprintfmt+0x1f1>
				putch(' ', putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	57                   	push   %edi
  800713:	6a 20                	push   $0x20
  800715:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800717:	83 eb 01             	sub    $0x1,%ebx
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	85 db                	test   %ebx,%ebx
  80071f:	7f ee                	jg     80070f <vprintfmt+0x23b>
  800721:	eb 67                	jmp    80078a <vprintfmt+0x2b6>
  800723:	89 fb                	mov    %edi,%ebx
  800725:	8b 75 08             	mov    0x8(%ebp),%esi
  800728:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80072b:	eb f0                	jmp    80071d <vprintfmt+0x249>
			num = getint(&ap, lflag);
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
  800730:	e8 33 fd ff ff       	call   800468 <getint>
  800735:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800738:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80073b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800740:	85 d2                	test   %edx,%edx
  800742:	79 2c                	jns    800770 <vprintfmt+0x29c>
				putch('-', putdat);
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	57                   	push   %edi
  800748:	6a 2d                	push   $0x2d
  80074a:	ff d6                	call   *%esi
				num = -(long long) num;
  80074c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80074f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800752:	f7 d8                	neg    %eax
  800754:	83 d2 00             	adc    $0x0,%edx
  800757:	f7 da                	neg    %edx
  800759:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80075c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800761:	eb 0d                	jmp    800770 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
  800766:	e8 c3 fc ff ff       	call   80042e <getuint>
			base = 10;
  80076b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800770:	83 ec 0c             	sub    $0xc,%esp
  800773:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  800777:	53                   	push   %ebx
  800778:	ff 75 e0             	pushl  -0x20(%ebp)
  80077b:	51                   	push   %ecx
  80077c:	52                   	push   %edx
  80077d:	50                   	push   %eax
  80077e:	89 fa                	mov    %edi,%edx
  800780:	89 f0                	mov    %esi,%eax
  800782:	e8 f8 fb ff ff       	call   80037f <printnum>
			break;
  800787:	83 c4 20             	add    $0x20,%esp
{
  80078a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078d:	83 c3 01             	add    $0x1,%ebx
  800790:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800794:	83 f8 25             	cmp    $0x25,%eax
  800797:	0f 84 52 fd ff ff    	je     8004ef <vprintfmt+0x1b>
			if (ch == '\0')
  80079d:	85 c0                	test   %eax,%eax
  80079f:	0f 84 84 00 00 00    	je     800829 <vprintfmt+0x355>
			putch(ch, putdat);
  8007a5:	83 ec 08             	sub    $0x8,%esp
  8007a8:	57                   	push   %edi
  8007a9:	50                   	push   %eax
  8007aa:	ff d6                	call   *%esi
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	eb dc                	jmp    80078d <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8007b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b4:	e8 75 fc ff ff       	call   80042e <getuint>
			base = 8;
  8007b9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007be:	eb b0                	jmp    800770 <vprintfmt+0x29c>
			putch('0', putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	57                   	push   %edi
  8007c4:	6a 30                	push   $0x30
  8007c6:	ff d6                	call   *%esi
			putch('x', putdat);
  8007c8:	83 c4 08             	add    $0x8,%esp
  8007cb:	57                   	push   %edi
  8007cc:	6a 78                	push   $0x78
  8007ce:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8d 50 04             	lea    0x4(%eax),%edx
  8007d6:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007d9:	8b 00                	mov    (%eax),%eax
  8007db:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8007e0:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007e3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007e8:	eb 86                	jmp    800770 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ed:	e8 3c fc ff ff       	call   80042e <getuint>
			base = 16;
  8007f2:	b9 10 00 00 00       	mov    $0x10,%ecx
  8007f7:	e9 74 ff ff ff       	jmp    800770 <vprintfmt+0x29c>
			putch(ch, putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	57                   	push   %edi
  800800:	6a 25                	push   $0x25
  800802:	ff d6                	call   *%esi
			break;
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	eb 81                	jmp    80078a <vprintfmt+0x2b6>
			putch('%', putdat);
  800809:	83 ec 08             	sub    $0x8,%esp
  80080c:	57                   	push   %edi
  80080d:	6a 25                	push   $0x25
  80080f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800811:	83 c4 10             	add    $0x10,%esp
  800814:	89 d8                	mov    %ebx,%eax
  800816:	eb 03                	jmp    80081b <vprintfmt+0x347>
  800818:	83 e8 01             	sub    $0x1,%eax
  80081b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80081f:	75 f7                	jne    800818 <vprintfmt+0x344>
  800821:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800824:	e9 61 ff ff ff       	jmp    80078a <vprintfmt+0x2b6>
}
  800829:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80082c:	5b                   	pop    %ebx
  80082d:	5e                   	pop    %esi
  80082e:	5f                   	pop    %edi
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	83 ec 18             	sub    $0x18,%esp
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80083d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800840:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800844:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800847:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80084e:	85 c0                	test   %eax,%eax
  800850:	74 26                	je     800878 <vsnprintf+0x47>
  800852:	85 d2                	test   %edx,%edx
  800854:	7e 22                	jle    800878 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800856:	ff 75 14             	pushl  0x14(%ebp)
  800859:	ff 75 10             	pushl  0x10(%ebp)
  80085c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	68 9a 04 80 00       	push   $0x80049a
  800865:	e8 6a fc ff ff       	call   8004d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80086a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80086d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800870:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800873:	83 c4 10             	add    $0x10,%esp
}
  800876:	c9                   	leave  
  800877:	c3                   	ret    
		return -E_INVAL;
  800878:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087d:	eb f7                	jmp    800876 <vsnprintf+0x45>

0080087f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800885:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800888:	50                   	push   %eax
  800889:	ff 75 10             	pushl  0x10(%ebp)
  80088c:	ff 75 0c             	pushl  0xc(%ebp)
  80088f:	ff 75 08             	pushl  0x8(%ebp)
  800892:	e8 9a ff ff ff       	call   800831 <vsnprintf>
	va_end(ap);

	return rc;
}
  800897:	c9                   	leave  
  800898:	c3                   	ret    

00800899 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a4:	eb 03                	jmp    8008a9 <strlen+0x10>
		n++;
  8008a6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008a9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ad:	75 f7                	jne    8008a6 <strlen+0xd>
	return n;
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bf:	eb 03                	jmp    8008c4 <strnlen+0x13>
		n++;
  8008c1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c4:	39 d0                	cmp    %edx,%eax
  8008c6:	74 06                	je     8008ce <strnlen+0x1d>
  8008c8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cc:	75 f3                	jne    8008c1 <strnlen+0x10>
	return n;
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008da:	89 c2                	mov    %eax,%edx
  8008dc:	83 c1 01             	add    $0x1,%ecx
  8008df:	83 c2 01             	add    $0x1,%edx
  8008e2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e9:	84 db                	test   %bl,%bl
  8008eb:	75 ef                	jne    8008dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ed:	5b                   	pop    %ebx
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f7:	53                   	push   %ebx
  8008f8:	e8 9c ff ff ff       	call   800899 <strlen>
  8008fd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800900:	ff 75 0c             	pushl  0xc(%ebp)
  800903:	01 d8                	add    %ebx,%eax
  800905:	50                   	push   %eax
  800906:	e8 c5 ff ff ff       	call   8008d0 <strcpy>
	return dst;
}
  80090b:	89 d8                	mov    %ebx,%eax
  80090d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800910:	c9                   	leave  
  800911:	c3                   	ret    

00800912 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 75 08             	mov    0x8(%ebp),%esi
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091d:	89 f3                	mov    %esi,%ebx
  80091f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800922:	89 f2                	mov    %esi,%edx
  800924:	eb 0f                	jmp    800935 <strncpy+0x23>
		*dst++ = *src;
  800926:	83 c2 01             	add    $0x1,%edx
  800929:	0f b6 01             	movzbl (%ecx),%eax
  80092c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092f:	80 39 01             	cmpb   $0x1,(%ecx)
  800932:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800935:	39 da                	cmp    %ebx,%edx
  800937:	75 ed                	jne    800926 <strncpy+0x14>
	}
	return ret;
}
  800939:	89 f0                	mov    %esi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 75 08             	mov    0x8(%ebp),%esi
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80094d:	89 f0                	mov    %esi,%eax
  80094f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800953:	85 c9                	test   %ecx,%ecx
  800955:	75 0b                	jne    800962 <strlcpy+0x23>
  800957:	eb 17                	jmp    800970 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800959:	83 c2 01             	add    $0x1,%edx
  80095c:	83 c0 01             	add    $0x1,%eax
  80095f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800962:	39 d8                	cmp    %ebx,%eax
  800964:	74 07                	je     80096d <strlcpy+0x2e>
  800966:	0f b6 0a             	movzbl (%edx),%ecx
  800969:	84 c9                	test   %cl,%cl
  80096b:	75 ec                	jne    800959 <strlcpy+0x1a>
		*dst = '\0';
  80096d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800970:	29 f0                	sub    %esi,%eax
}
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097f:	eb 06                	jmp    800987 <strcmp+0x11>
		p++, q++;
  800981:	83 c1 01             	add    $0x1,%ecx
  800984:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800987:	0f b6 01             	movzbl (%ecx),%eax
  80098a:	84 c0                	test   %al,%al
  80098c:	74 04                	je     800992 <strcmp+0x1c>
  80098e:	3a 02                	cmp    (%edx),%al
  800990:	74 ef                	je     800981 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800992:	0f b6 c0             	movzbl %al,%eax
  800995:	0f b6 12             	movzbl (%edx),%edx
  800998:	29 d0                	sub    %edx,%eax
}
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	53                   	push   %ebx
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a6:	89 c3                	mov    %eax,%ebx
  8009a8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ab:	eb 06                	jmp    8009b3 <strncmp+0x17>
		n--, p++, q++;
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b3:	39 d8                	cmp    %ebx,%eax
  8009b5:	74 16                	je     8009cd <strncmp+0x31>
  8009b7:	0f b6 08             	movzbl (%eax),%ecx
  8009ba:	84 c9                	test   %cl,%cl
  8009bc:	74 04                	je     8009c2 <strncmp+0x26>
  8009be:	3a 0a                	cmp    (%edx),%cl
  8009c0:	74 eb                	je     8009ad <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c2:	0f b6 00             	movzbl (%eax),%eax
  8009c5:	0f b6 12             	movzbl (%edx),%edx
  8009c8:	29 d0                	sub    %edx,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    
		return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d2:	eb f6                	jmp    8009ca <strncmp+0x2e>

008009d4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009de:	0f b6 10             	movzbl (%eax),%edx
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	74 09                	je     8009ee <strchr+0x1a>
		if (*s == c)
  8009e5:	38 ca                	cmp    %cl,%dl
  8009e7:	74 0a                	je     8009f3 <strchr+0x1f>
	for (; *s; s++)
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	eb f0                	jmp    8009de <strchr+0xa>
			return (char *) s;
	return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ff:	eb 03                	jmp    800a04 <strfind+0xf>
  800a01:	83 c0 01             	add    $0x1,%eax
  800a04:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a07:	38 ca                	cmp    %cl,%dl
  800a09:	74 04                	je     800a0f <strfind+0x1a>
  800a0b:	84 d2                	test   %dl,%dl
  800a0d:	75 f2                	jne    800a01 <strfind+0xc>
			break;
	return (char *) s;
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	57                   	push   %edi
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
  800a17:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a1d:	85 c9                	test   %ecx,%ecx
  800a1f:	74 12                	je     800a33 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a21:	f6 c2 03             	test   $0x3,%dl
  800a24:	75 05                	jne    800a2b <memset+0x1a>
  800a26:	f6 c1 03             	test   $0x3,%cl
  800a29:	74 0f                	je     800a3a <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a2b:	89 d7                	mov    %edx,%edi
  800a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a30:	fc                   	cld    
  800a31:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a33:	89 d0                	mov    %edx,%eax
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    
		c &= 0xFF;
  800a3a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3e:	89 d8                	mov    %ebx,%eax
  800a40:	c1 e0 08             	shl    $0x8,%eax
  800a43:	89 df                	mov    %ebx,%edi
  800a45:	c1 e7 18             	shl    $0x18,%edi
  800a48:	89 de                	mov    %ebx,%esi
  800a4a:	c1 e6 10             	shl    $0x10,%esi
  800a4d:	09 f7                	or     %esi,%edi
  800a4f:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800a51:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a54:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a56:	89 d7                	mov    %edx,%edi
  800a58:	fc                   	cld    
  800a59:	f3 ab                	rep stos %eax,%es:(%edi)
  800a5b:	eb d6                	jmp    800a33 <memset+0x22>

00800a5d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a68:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a6b:	39 c6                	cmp    %eax,%esi
  800a6d:	73 35                	jae    800aa4 <memmove+0x47>
  800a6f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a72:	39 c2                	cmp    %eax,%edx
  800a74:	76 2e                	jbe    800aa4 <memmove+0x47>
		s += n;
		d += n;
  800a76:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a79:	89 d6                	mov    %edx,%esi
  800a7b:	09 fe                	or     %edi,%esi
  800a7d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a83:	74 0c                	je     800a91 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a85:	83 ef 01             	sub    $0x1,%edi
  800a88:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a8b:	fd                   	std    
  800a8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8e:	fc                   	cld    
  800a8f:	eb 21                	jmp    800ab2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a91:	f6 c1 03             	test   $0x3,%cl
  800a94:	75 ef                	jne    800a85 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a96:	83 ef 04             	sub    $0x4,%edi
  800a99:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a9f:	fd                   	std    
  800aa0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa2:	eb ea                	jmp    800a8e <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	89 f2                	mov    %esi,%edx
  800aa6:	09 c2                	or     %eax,%edx
  800aa8:	f6 c2 03             	test   $0x3,%dl
  800aab:	74 09                	je     800ab6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aad:	89 c7                	mov    %eax,%edi
  800aaf:	fc                   	cld    
  800ab0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab6:	f6 c1 03             	test   $0x3,%cl
  800ab9:	75 f2                	jne    800aad <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800abe:	89 c7                	mov    %eax,%edi
  800ac0:	fc                   	cld    
  800ac1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac3:	eb ed                	jmp    800ab2 <memmove+0x55>

00800ac5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ac8:	ff 75 10             	pushl  0x10(%ebp)
  800acb:	ff 75 0c             	pushl  0xc(%ebp)
  800ace:	ff 75 08             	pushl  0x8(%ebp)
  800ad1:	e8 87 ff ff ff       	call   800a5d <memmove>
}
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae3:	89 c6                	mov    %eax,%esi
  800ae5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae8:	39 f0                	cmp    %esi,%eax
  800aea:	74 1c                	je     800b08 <memcmp+0x30>
		if (*s1 != *s2)
  800aec:	0f b6 08             	movzbl (%eax),%ecx
  800aef:	0f b6 1a             	movzbl (%edx),%ebx
  800af2:	38 d9                	cmp    %bl,%cl
  800af4:	75 08                	jne    800afe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af6:	83 c0 01             	add    $0x1,%eax
  800af9:	83 c2 01             	add    $0x1,%edx
  800afc:	eb ea                	jmp    800ae8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800afe:	0f b6 c1             	movzbl %cl,%eax
  800b01:	0f b6 db             	movzbl %bl,%ebx
  800b04:	29 d8                	sub    %ebx,%eax
  800b06:	eb 05                	jmp    800b0d <memcmp+0x35>
	}

	return 0;
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1a:	89 c2                	mov    %eax,%edx
  800b1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1f:	39 d0                	cmp    %edx,%eax
  800b21:	73 09                	jae    800b2c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b23:	38 08                	cmp    %cl,(%eax)
  800b25:	74 05                	je     800b2c <memfind+0x1b>
	for (; s < ends; s++)
  800b27:	83 c0 01             	add    $0x1,%eax
  800b2a:	eb f3                	jmp    800b1f <memfind+0xe>
			break;
	return (void *) s;
}
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3a:	eb 03                	jmp    800b3f <strtol+0x11>
		s++;
  800b3c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b3f:	0f b6 01             	movzbl (%ecx),%eax
  800b42:	3c 20                	cmp    $0x20,%al
  800b44:	74 f6                	je     800b3c <strtol+0xe>
  800b46:	3c 09                	cmp    $0x9,%al
  800b48:	74 f2                	je     800b3c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b4a:	3c 2b                	cmp    $0x2b,%al
  800b4c:	74 2e                	je     800b7c <strtol+0x4e>
	int neg = 0;
  800b4e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b53:	3c 2d                	cmp    $0x2d,%al
  800b55:	74 2f                	je     800b86 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b57:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5d:	75 05                	jne    800b64 <strtol+0x36>
  800b5f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b62:	74 2c                	je     800b90 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b64:	85 db                	test   %ebx,%ebx
  800b66:	75 0a                	jne    800b72 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b68:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b70:	74 28                	je     800b9a <strtol+0x6c>
		base = 10;
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
  800b77:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b7a:	eb 50                	jmp    800bcc <strtol+0x9e>
		s++;
  800b7c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b84:	eb d1                	jmp    800b57 <strtol+0x29>
		s++, neg = 1;
  800b86:	83 c1 01             	add    $0x1,%ecx
  800b89:	bf 01 00 00 00       	mov    $0x1,%edi
  800b8e:	eb c7                	jmp    800b57 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b90:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b94:	74 0e                	je     800ba4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b96:	85 db                	test   %ebx,%ebx
  800b98:	75 d8                	jne    800b72 <strtol+0x44>
		s++, base = 8;
  800b9a:	83 c1 01             	add    $0x1,%ecx
  800b9d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ba2:	eb ce                	jmp    800b72 <strtol+0x44>
		s += 2, base = 16;
  800ba4:	83 c1 02             	add    $0x2,%ecx
  800ba7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bac:	eb c4                	jmp    800b72 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb1:	89 f3                	mov    %esi,%ebx
  800bb3:	80 fb 19             	cmp    $0x19,%bl
  800bb6:	77 29                	ja     800be1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bb8:	0f be d2             	movsbl %dl,%edx
  800bbb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bbe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bc1:	7d 30                	jge    800bf3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bc3:	83 c1 01             	add    $0x1,%ecx
  800bc6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bca:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bcc:	0f b6 11             	movzbl (%ecx),%edx
  800bcf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bd2:	89 f3                	mov    %esi,%ebx
  800bd4:	80 fb 09             	cmp    $0x9,%bl
  800bd7:	77 d5                	ja     800bae <strtol+0x80>
			dig = *s - '0';
  800bd9:	0f be d2             	movsbl %dl,%edx
  800bdc:	83 ea 30             	sub    $0x30,%edx
  800bdf:	eb dd                	jmp    800bbe <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800be1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be4:	89 f3                	mov    %esi,%ebx
  800be6:	80 fb 19             	cmp    $0x19,%bl
  800be9:	77 08                	ja     800bf3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800beb:	0f be d2             	movsbl %dl,%edx
  800bee:	83 ea 37             	sub    $0x37,%edx
  800bf1:	eb cb                	jmp    800bbe <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf7:	74 05                	je     800bfe <strtol+0xd0>
		*endptr = (char *) s;
  800bf9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bfe:	89 c2                	mov    %eax,%edx
  800c00:	f7 da                	neg    %edx
  800c02:	85 ff                	test   %edi,%edi
  800c04:	0f 45 c2             	cmovne %edx,%eax
}
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    
  800c0c:	66 90                	xchg   %ax,%ax
  800c0e:	66 90                	xchg   %ax,%ax

00800c10 <__udivdi3>:
  800c10:	55                   	push   %ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 1c             	sub    $0x1c,%esp
  800c17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c1b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c23:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c27:	85 d2                	test   %edx,%edx
  800c29:	75 35                	jne    800c60 <__udivdi3+0x50>
  800c2b:	39 f3                	cmp    %esi,%ebx
  800c2d:	0f 87 bd 00 00 00    	ja     800cf0 <__udivdi3+0xe0>
  800c33:	85 db                	test   %ebx,%ebx
  800c35:	89 d9                	mov    %ebx,%ecx
  800c37:	75 0b                	jne    800c44 <__udivdi3+0x34>
  800c39:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3e:	31 d2                	xor    %edx,%edx
  800c40:	f7 f3                	div    %ebx
  800c42:	89 c1                	mov    %eax,%ecx
  800c44:	31 d2                	xor    %edx,%edx
  800c46:	89 f0                	mov    %esi,%eax
  800c48:	f7 f1                	div    %ecx
  800c4a:	89 c6                	mov    %eax,%esi
  800c4c:	89 e8                	mov    %ebp,%eax
  800c4e:	89 f7                	mov    %esi,%edi
  800c50:	f7 f1                	div    %ecx
  800c52:	89 fa                	mov    %edi,%edx
  800c54:	83 c4 1c             	add    $0x1c,%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    
  800c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c60:	39 f2                	cmp    %esi,%edx
  800c62:	77 7c                	ja     800ce0 <__udivdi3+0xd0>
  800c64:	0f bd fa             	bsr    %edx,%edi
  800c67:	83 f7 1f             	xor    $0x1f,%edi
  800c6a:	0f 84 98 00 00 00    	je     800d08 <__udivdi3+0xf8>
  800c70:	89 f9                	mov    %edi,%ecx
  800c72:	b8 20 00 00 00       	mov    $0x20,%eax
  800c77:	29 f8                	sub    %edi,%eax
  800c79:	d3 e2                	shl    %cl,%edx
  800c7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c7f:	89 c1                	mov    %eax,%ecx
  800c81:	89 da                	mov    %ebx,%edx
  800c83:	d3 ea                	shr    %cl,%edx
  800c85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c89:	09 d1                	or     %edx,%ecx
  800c8b:	89 f2                	mov    %esi,%edx
  800c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c91:	89 f9                	mov    %edi,%ecx
  800c93:	d3 e3                	shl    %cl,%ebx
  800c95:	89 c1                	mov    %eax,%ecx
  800c97:	d3 ea                	shr    %cl,%edx
  800c99:	89 f9                	mov    %edi,%ecx
  800c9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800c9f:	d3 e6                	shl    %cl,%esi
  800ca1:	89 eb                	mov    %ebp,%ebx
  800ca3:	89 c1                	mov    %eax,%ecx
  800ca5:	d3 eb                	shr    %cl,%ebx
  800ca7:	09 de                	or     %ebx,%esi
  800ca9:	89 f0                	mov    %esi,%eax
  800cab:	f7 74 24 08          	divl   0x8(%esp)
  800caf:	89 d6                	mov    %edx,%esi
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	f7 64 24 0c          	mull   0xc(%esp)
  800cb7:	39 d6                	cmp    %edx,%esi
  800cb9:	72 0c                	jb     800cc7 <__udivdi3+0xb7>
  800cbb:	89 f9                	mov    %edi,%ecx
  800cbd:	d3 e5                	shl    %cl,%ebp
  800cbf:	39 c5                	cmp    %eax,%ebp
  800cc1:	73 5d                	jae    800d20 <__udivdi3+0x110>
  800cc3:	39 d6                	cmp    %edx,%esi
  800cc5:	75 59                	jne    800d20 <__udivdi3+0x110>
  800cc7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cca:	31 ff                	xor    %edi,%edi
  800ccc:	89 fa                	mov    %edi,%edx
  800cce:	83 c4 1c             	add    $0x1c,%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    
  800cd6:	8d 76 00             	lea    0x0(%esi),%esi
  800cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ce0:	31 ff                	xor    %edi,%edi
  800ce2:	31 c0                	xor    %eax,%eax
  800ce4:	89 fa                	mov    %edi,%edx
  800ce6:	83 c4 1c             	add    $0x1c,%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    
  800cee:	66 90                	xchg   %ax,%ax
  800cf0:	31 ff                	xor    %edi,%edi
  800cf2:	89 e8                	mov    %ebp,%eax
  800cf4:	89 f2                	mov    %esi,%edx
  800cf6:	f7 f3                	div    %ebx
  800cf8:	89 fa                	mov    %edi,%edx
  800cfa:	83 c4 1c             	add    $0x1c,%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
  800d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d08:	39 f2                	cmp    %esi,%edx
  800d0a:	72 06                	jb     800d12 <__udivdi3+0x102>
  800d0c:	31 c0                	xor    %eax,%eax
  800d0e:	39 eb                	cmp    %ebp,%ebx
  800d10:	77 d2                	ja     800ce4 <__udivdi3+0xd4>
  800d12:	b8 01 00 00 00       	mov    $0x1,%eax
  800d17:	eb cb                	jmp    800ce4 <__udivdi3+0xd4>
  800d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d20:	89 d8                	mov    %ebx,%eax
  800d22:	31 ff                	xor    %edi,%edi
  800d24:	eb be                	jmp    800ce4 <__udivdi3+0xd4>
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	66 90                	xchg   %ax,%ax
  800d2a:	66 90                	xchg   %ax,%ax
  800d2c:	66 90                	xchg   %ax,%ax
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__umoddi3>:
  800d30:	55                   	push   %ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 1c             	sub    $0x1c,%esp
  800d37:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d47:	85 ed                	test   %ebp,%ebp
  800d49:	89 f0                	mov    %esi,%eax
  800d4b:	89 da                	mov    %ebx,%edx
  800d4d:	75 19                	jne    800d68 <__umoddi3+0x38>
  800d4f:	39 df                	cmp    %ebx,%edi
  800d51:	0f 86 b1 00 00 00    	jbe    800e08 <__umoddi3+0xd8>
  800d57:	f7 f7                	div    %edi
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	83 c4 1c             	add    $0x1c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
  800d68:	39 dd                	cmp    %ebx,%ebp
  800d6a:	77 f1                	ja     800d5d <__umoddi3+0x2d>
  800d6c:	0f bd cd             	bsr    %ebp,%ecx
  800d6f:	83 f1 1f             	xor    $0x1f,%ecx
  800d72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d76:	0f 84 b4 00 00 00    	je     800e30 <__umoddi3+0x100>
  800d7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d81:	89 c2                	mov    %eax,%edx
  800d83:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d87:	29 c2                	sub    %eax,%edx
  800d89:	89 c1                	mov    %eax,%ecx
  800d8b:	89 f8                	mov    %edi,%eax
  800d8d:	d3 e5                	shl    %cl,%ebp
  800d8f:	89 d1                	mov    %edx,%ecx
  800d91:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d95:	d3 e8                	shr    %cl,%eax
  800d97:	09 c5                	or     %eax,%ebp
  800d99:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d9d:	89 c1                	mov    %eax,%ecx
  800d9f:	d3 e7                	shl    %cl,%edi
  800da1:	89 d1                	mov    %edx,%ecx
  800da3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800da7:	89 df                	mov    %ebx,%edi
  800da9:	d3 ef                	shr    %cl,%edi
  800dab:	89 c1                	mov    %eax,%ecx
  800dad:	89 f0                	mov    %esi,%eax
  800daf:	d3 e3                	shl    %cl,%ebx
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 fa                	mov    %edi,%edx
  800db5:	d3 e8                	shr    %cl,%eax
  800db7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dbc:	09 d8                	or     %ebx,%eax
  800dbe:	f7 f5                	div    %ebp
  800dc0:	d3 e6                	shl    %cl,%esi
  800dc2:	89 d1                	mov    %edx,%ecx
  800dc4:	f7 64 24 08          	mull   0x8(%esp)
  800dc8:	39 d1                	cmp    %edx,%ecx
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	89 d7                	mov    %edx,%edi
  800dce:	72 06                	jb     800dd6 <__umoddi3+0xa6>
  800dd0:	75 0e                	jne    800de0 <__umoddi3+0xb0>
  800dd2:	39 c6                	cmp    %eax,%esi
  800dd4:	73 0a                	jae    800de0 <__umoddi3+0xb0>
  800dd6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dda:	19 ea                	sbb    %ebp,%edx
  800ddc:	89 d7                	mov    %edx,%edi
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	89 ca                	mov    %ecx,%edx
  800de2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800de7:	29 de                	sub    %ebx,%esi
  800de9:	19 fa                	sbb    %edi,%edx
  800deb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800def:	89 d0                	mov    %edx,%eax
  800df1:	d3 e0                	shl    %cl,%eax
  800df3:	89 d9                	mov    %ebx,%ecx
  800df5:	d3 ee                	shr    %cl,%esi
  800df7:	d3 ea                	shr    %cl,%edx
  800df9:	09 f0                	or     %esi,%eax
  800dfb:	83 c4 1c             	add    $0x1c,%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
  800e03:	90                   	nop
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	85 ff                	test   %edi,%edi
  800e0a:	89 f9                	mov    %edi,%ecx
  800e0c:	75 0b                	jne    800e19 <__umoddi3+0xe9>
  800e0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e13:	31 d2                	xor    %edx,%edx
  800e15:	f7 f7                	div    %edi
  800e17:	89 c1                	mov    %eax,%ecx
  800e19:	89 d8                	mov    %ebx,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	f7 f1                	div    %ecx
  800e1f:	89 f0                	mov    %esi,%eax
  800e21:	f7 f1                	div    %ecx
  800e23:	e9 31 ff ff ff       	jmp    800d59 <__umoddi3+0x29>
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	39 dd                	cmp    %ebx,%ebp
  800e32:	72 08                	jb     800e3c <__umoddi3+0x10c>
  800e34:	39 f7                	cmp    %esi,%edi
  800e36:	0f 87 21 ff ff ff    	ja     800d5d <__umoddi3+0x2d>
  800e3c:	89 da                	mov    %ebx,%edx
  800e3e:	89 f0                	mov    %esi,%eax
  800e40:	29 f8                	sub    %edi,%eax
  800e42:	19 ea                	sbb    %ebp,%edx
  800e44:	e9 14 ff ff ff       	jmp    800d5d <__umoddi3+0x2d>
