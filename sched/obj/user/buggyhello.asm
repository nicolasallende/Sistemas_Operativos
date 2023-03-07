
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 ab 00 00 00       	call   8000ed <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800052:	e8 02 01 00 00       	call   800159 <sys_getenvid>
	if (id >= 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	78 12                	js     80006d <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	c1 e0 07             	shl    $0x7,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 db                	test   %ebx,%ebx
  80006f:	7e 07                	jle    800078 <libmain+0x31>
		binaryname = argv[0];
  800071:	8b 06                	mov    (%esi),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	e8 b1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800082:	e8 0a 00 00 00       	call   800091 <exit>
}
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    

00800091 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800097:	6a 00                	push   $0x0
  800099:	e8 99 00 00 00       	call   800137 <sys_env_destroy>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	57                   	push   %edi
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  8000a9:	83 ec 1c             	sub    $0x1c,%esp
  8000ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000af:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b2:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ba:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000bd:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c6:	74 04                	je     8000cc <syscall+0x29>
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	7f 08                	jg     8000d4 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5f                   	pop    %edi
  8000d2:	5d                   	pop    %ebp
  8000d3:	c3                   	ret    
  8000d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	50                   	push   %eax
  8000db:	52                   	push   %edx
  8000dc:	68 6a 0e 80 00       	push   $0x800e6a
  8000e1:	6a 23                	push   $0x23
  8000e3:	68 87 0e 80 00       	push   $0x800e87
  8000e8:	e8 b1 01 00 00       	call   80029e <_panic>

008000ed <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f3:	6a 00                	push   $0x0
  8000f5:	6a 00                	push   $0x0
  8000f7:	6a 00                	push   $0x0
  8000f9:	ff 75 0c             	pushl  0xc(%ebp)
  8000fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800104:	b8 00 00 00 00       	mov    $0x0,%eax
  800109:	e8 95 ff ff ff       	call   8000a3 <syscall>
}
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	c9                   	leave  
  800112:	c3                   	ret    

00800113 <sys_cgetc>:

int
sys_cgetc(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800119:	6a 00                	push   $0x0
  80011b:	6a 00                	push   $0x0
  80011d:	6a 00                	push   $0x0
  80011f:	6a 00                	push   $0x0
  800121:	b9 00 00 00 00       	mov    $0x0,%ecx
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 01 00 00 00       	mov    $0x1,%eax
  800130:	e8 6e ff ff ff       	call   8000a3 <syscall>
}
  800135:	c9                   	leave  
  800136:	c3                   	ret    

00800137 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80013d:	6a 00                	push   $0x0
  80013f:	6a 00                	push   $0x0
  800141:	6a 00                	push   $0x0
  800143:	6a 00                	push   $0x0
  800145:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800148:	ba 01 00 00 00       	mov    $0x1,%edx
  80014d:	b8 03 00 00 00       	mov    $0x3,%eax
  800152:	e8 4c ff ff ff       	call   8000a3 <syscall>
}
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80015f:	6a 00                	push   $0x0
  800161:	6a 00                	push   $0x0
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	b9 00 00 00 00       	mov    $0x0,%ecx
  80016c:	ba 00 00 00 00       	mov    $0x0,%edx
  800171:	b8 02 00 00 00       	mov    $0x2,%eax
  800176:	e8 28 ff ff ff       	call   8000a3 <syscall>
}
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    

0080017d <sys_yield>:

void
sys_yield(void)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800183:	6a 00                	push   $0x0
  800185:	6a 00                	push   $0x0
  800187:	6a 00                	push   $0x0
  800189:	6a 00                	push   $0x0
  80018b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800190:	ba 00 00 00 00       	mov    $0x0,%edx
  800195:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019a:	e8 04 ff ff ff       	call   8000a3 <syscall>
}
  80019f:	83 c4 10             	add    $0x10,%esp
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001aa:	6a 00                	push   $0x0
  8001ac:	6a 00                	push   $0x0
  8001ae:	ff 75 10             	pushl  0x10(%ebp)
  8001b1:	ff 75 0c             	pushl  0xc(%ebp)
  8001b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b7:	ba 01 00 00 00       	mov    $0x1,%edx
  8001bc:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c1:	e8 dd fe ff ff       	call   8000a3 <syscall>
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001ce:	ff 75 18             	pushl  0x18(%ebp)
  8001d1:	ff 75 14             	pushl  0x14(%ebp)
  8001d4:	ff 75 10             	pushl  0x10(%ebp)
  8001d7:	ff 75 0c             	pushl  0xc(%ebp)
  8001da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001dd:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e7:	e8 b7 fe ff ff       	call   8000a3 <syscall>
}
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001f4:	6a 00                	push   $0x0
  8001f6:	6a 00                	push   $0x0
  8001f8:	6a 00                	push   $0x0
  8001fa:	ff 75 0c             	pushl  0xc(%ebp)
  8001fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800200:	ba 01 00 00 00       	mov    $0x1,%edx
  800205:	b8 06 00 00 00       	mov    $0x6,%eax
  80020a:	e8 94 fe ff ff       	call   8000a3 <syscall>
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800217:	6a 00                	push   $0x0
  800219:	6a 00                	push   $0x0
  80021b:	6a 00                	push   $0x0
  80021d:	ff 75 0c             	pushl  0xc(%ebp)
  800220:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800223:	ba 01 00 00 00       	mov    $0x1,%edx
  800228:	b8 08 00 00 00       	mov    $0x8,%eax
  80022d:	e8 71 fe ff ff       	call   8000a3 <syscall>
}
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80023a:	6a 00                	push   $0x0
  80023c:	6a 00                	push   $0x0
  80023e:	6a 00                	push   $0x0
  800240:	ff 75 0c             	pushl  0xc(%ebp)
  800243:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800246:	ba 01 00 00 00       	mov    $0x1,%edx
  80024b:	b8 09 00 00 00       	mov    $0x9,%eax
  800250:	e8 4e fe ff ff       	call   8000a3 <syscall>
}
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80025d:	6a 00                	push   $0x0
  80025f:	ff 75 14             	pushl  0x14(%ebp)
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	ff 75 0c             	pushl  0xc(%ebp)
  800268:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026b:	ba 00 00 00 00       	mov    $0x0,%edx
  800270:	b8 0b 00 00 00       	mov    $0xb,%eax
  800275:	e8 29 fe ff ff       	call   8000a3 <syscall>
}
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800282:	6a 00                	push   $0x0
  800284:	6a 00                	push   $0x0
  800286:	6a 00                	push   $0x0
  800288:	6a 00                	push   $0x0
  80028a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028d:	ba 01 00 00 00       	mov    $0x1,%edx
  800292:	b8 0c 00 00 00       	mov    $0xc,%eax
  800297:	e8 07 fe ff ff       	call   8000a3 <syscall>
}
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    

0080029e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002a3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a6:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002ac:	e8 a8 fe ff ff       	call   800159 <sys_getenvid>
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	56                   	push   %esi
  8002bb:	50                   	push   %eax
  8002bc:	68 98 0e 80 00       	push   $0x800e98
  8002c1:	e8 b3 00 00 00       	call   800379 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c6:	83 c4 18             	add    $0x18,%esp
  8002c9:	53                   	push   %ebx
  8002ca:	ff 75 10             	pushl  0x10(%ebp)
  8002cd:	e8 56 00 00 00       	call   800328 <vcprintf>
	cprintf("\n");
  8002d2:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  8002d9:	e8 9b 00 00 00       	call   800379 <cprintf>
  8002de:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e1:	cc                   	int3   
  8002e2:	eb fd                	jmp    8002e1 <_panic+0x43>

008002e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 04             	sub    $0x4,%esp
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ee:	8b 13                	mov    (%ebx),%edx
  8002f0:	8d 42 01             	lea    0x1(%edx),%eax
  8002f3:	89 03                	mov    %eax,(%ebx)
  8002f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800301:	74 09                	je     80030c <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800303:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800307:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	68 ff 00 00 00       	push   $0xff
  800314:	8d 43 08             	lea    0x8(%ebx),%eax
  800317:	50                   	push   %eax
  800318:	e8 d0 fd ff ff       	call   8000ed <sys_cputs>
		b->idx = 0;
  80031d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	eb db                	jmp    800303 <putch+0x1f>

00800328 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800331:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800338:	00 00 00 
	b.cnt = 0;
  80033b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800342:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800345:	ff 75 0c             	pushl  0xc(%ebp)
  800348:	ff 75 08             	pushl  0x8(%ebp)
  80034b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800351:	50                   	push   %eax
  800352:	68 e4 02 80 00       	push   $0x8002e4
  800357:	e8 86 01 00 00       	call   8004e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800365:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80036b:	50                   	push   %eax
  80036c:	e8 7c fd ff ff       	call   8000ed <sys_cputs>

	return b.cnt;
}
  800371:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800377:	c9                   	leave  
  800378:	c3                   	ret    

00800379 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80037f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800382:	50                   	push   %eax
  800383:	ff 75 08             	pushl  0x8(%ebp)
  800386:	e8 9d ff ff ff       	call   800328 <vcprintf>
	va_end(ap);

	return cnt;
}
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    

0080038d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	57                   	push   %edi
  800391:	56                   	push   %esi
  800392:	53                   	push   %ebx
  800393:	83 ec 1c             	sub    $0x1c,%esp
  800396:	89 c7                	mov    %eax,%edi
  800398:	89 d6                	mov    %edx,%esi
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003b1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003b4:	39 d3                	cmp    %edx,%ebx
  8003b6:	72 05                	jb     8003bd <printnum+0x30>
  8003b8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003bb:	77 7a                	ja     800437 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003bd:	83 ec 0c             	sub    $0xc,%esp
  8003c0:	ff 75 18             	pushl  0x18(%ebp)
  8003c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c9:	53                   	push   %ebx
  8003ca:	ff 75 10             	pushl  0x10(%ebp)
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003dc:	e8 3f 08 00 00       	call   800c20 <__udivdi3>
  8003e1:	83 c4 18             	add    $0x18,%esp
  8003e4:	52                   	push   %edx
  8003e5:	50                   	push   %eax
  8003e6:	89 f2                	mov    %esi,%edx
  8003e8:	89 f8                	mov    %edi,%eax
  8003ea:	e8 9e ff ff ff       	call   80038d <printnum>
  8003ef:	83 c4 20             	add    $0x20,%esp
  8003f2:	eb 13                	jmp    800407 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f4:	83 ec 08             	sub    $0x8,%esp
  8003f7:	56                   	push   %esi
  8003f8:	ff 75 18             	pushl  0x18(%ebp)
  8003fb:	ff d7                	call   *%edi
  8003fd:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800400:	83 eb 01             	sub    $0x1,%ebx
  800403:	85 db                	test   %ebx,%ebx
  800405:	7f ed                	jg     8003f4 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	56                   	push   %esi
  80040b:	83 ec 04             	sub    $0x4,%esp
  80040e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800411:	ff 75 e0             	pushl  -0x20(%ebp)
  800414:	ff 75 dc             	pushl  -0x24(%ebp)
  800417:	ff 75 d8             	pushl  -0x28(%ebp)
  80041a:	e8 21 09 00 00       	call   800d40 <__umoddi3>
  80041f:	83 c4 14             	add    $0x14,%esp
  800422:	0f be 80 be 0e 80 00 	movsbl 0x800ebe(%eax),%eax
  800429:	50                   	push   %eax
  80042a:	ff d7                	call   *%edi
}
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800432:	5b                   	pop    %ebx
  800433:	5e                   	pop    %esi
  800434:	5f                   	pop    %edi
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    
  800437:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80043a:	eb c4                	jmp    800400 <printnum+0x73>

0080043c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80043f:	83 fa 01             	cmp    $0x1,%edx
  800442:	7e 0e                	jle    800452 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800444:	8b 10                	mov    (%eax),%edx
  800446:	8d 4a 08             	lea    0x8(%edx),%ecx
  800449:	89 08                	mov    %ecx,(%eax)
  80044b:	8b 02                	mov    (%edx),%eax
  80044d:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    
	else if (lflag)
  800452:	85 d2                	test   %edx,%edx
  800454:	75 10                	jne    800466 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800456:	8b 10                	mov    (%eax),%edx
  800458:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045b:	89 08                	mov    %ecx,(%eax)
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	ba 00 00 00 00       	mov    $0x0,%edx
  800464:	eb ea                	jmp    800450 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800466:	8b 10                	mov    (%eax),%edx
  800468:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046b:	89 08                	mov    %ecx,(%eax)
  80046d:	8b 02                	mov    (%edx),%eax
  80046f:	ba 00 00 00 00       	mov    $0x0,%edx
  800474:	eb da                	jmp    800450 <getuint+0x14>

00800476 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800479:	83 fa 01             	cmp    $0x1,%edx
  80047c:	7e 0e                	jle    80048c <getint+0x16>
		return va_arg(*ap, long long);
  80047e:	8b 10                	mov    (%eax),%edx
  800480:	8d 4a 08             	lea    0x8(%edx),%ecx
  800483:	89 08                	mov    %ecx,(%eax)
  800485:	8b 02                	mov    (%edx),%eax
  800487:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  80048a:	5d                   	pop    %ebp
  80048b:	c3                   	ret    
	else if (lflag)
  80048c:	85 d2                	test   %edx,%edx
  80048e:	75 0c                	jne    80049c <getint+0x26>
		return va_arg(*ap, int);
  800490:	8b 10                	mov    (%eax),%edx
  800492:	8d 4a 04             	lea    0x4(%edx),%ecx
  800495:	89 08                	mov    %ecx,(%eax)
  800497:	8b 02                	mov    (%edx),%eax
  800499:	99                   	cltd   
  80049a:	eb ee                	jmp    80048a <getint+0x14>
		return va_arg(*ap, long);
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 02                	mov    (%edx),%eax
  8004a5:	99                   	cltd   
  8004a6:	eb e2                	jmp    80048a <getint+0x14>

008004a8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ae:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b2:	8b 10                	mov    (%eax),%edx
  8004b4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b7:	73 0a                	jae    8004c3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004bc:	89 08                	mov    %ecx,(%eax)
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	88 02                	mov    %al,(%edx)
}
  8004c3:	5d                   	pop    %ebp
  8004c4:	c3                   	ret    

008004c5 <printfmt>:
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004cb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ce:	50                   	push   %eax
  8004cf:	ff 75 10             	pushl  0x10(%ebp)
  8004d2:	ff 75 0c             	pushl  0xc(%ebp)
  8004d5:	ff 75 08             	pushl  0x8(%ebp)
  8004d8:	e8 05 00 00 00       	call   8004e2 <vprintfmt>
}
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	c9                   	leave  
  8004e1:	c3                   	ret    

008004e2 <vprintfmt>:
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	57                   	push   %edi
  8004e6:	56                   	push   %esi
  8004e7:	53                   	push   %ebx
  8004e8:	83 ec 2c             	sub    $0x2c,%esp
  8004eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004f1:	89 f7                	mov    %esi,%edi
  8004f3:	89 de                	mov    %ebx,%esi
  8004f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004f8:	e9 9e 02 00 00       	jmp    80079b <vprintfmt+0x2b9>
		padc = ' ';
  8004fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800501:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800508:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80050f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800516:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8d 43 01             	lea    0x1(%ebx),%eax
  80051e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800521:	0f b6 0b             	movzbl (%ebx),%ecx
  800524:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800527:	3c 55                	cmp    $0x55,%al
  800529:	0f 87 e8 02 00 00    	ja     800817 <vprintfmt+0x335>
  80052f:	0f b6 c0             	movzbl %al,%eax
  800532:	ff 24 85 80 0f 80 00 	jmp    *0x800f80(,%eax,4)
  800539:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80053c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800540:	eb d9                	jmp    80051b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800545:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800549:	eb d0                	jmp    80051b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	0f b6 c9             	movzbl %cl,%ecx
  80054e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800551:	b8 00 00 00 00       	mov    $0x0,%eax
  800556:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800559:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800560:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800563:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800566:	83 fa 09             	cmp    $0x9,%edx
  800569:	77 52                	ja     8005bd <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  80056b:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80056e:	eb e9                	jmp    800559 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 48 04             	lea    0x4(%eax),%ecx
  800576:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800581:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800585:	79 94                	jns    80051b <vprintfmt+0x39>
				width = precision, precision = -1;
  800587:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80058a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800594:	eb 85                	jmp    80051b <vprintfmt+0x39>
  800596:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800599:	85 c0                	test   %eax,%eax
  80059b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a0:	0f 49 c8             	cmovns %eax,%ecx
  8005a3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a9:	e9 6d ff ff ff       	jmp    80051b <vprintfmt+0x39>
  8005ae:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8005b1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b8:	e9 5e ff ff ff       	jmp    80051b <vprintfmt+0x39>
  8005bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c3:	eb bc                	jmp    800581 <vprintfmt+0x9f>
			lflag++;
  8005c5:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8005cb:	e9 4b ff ff ff       	jmp    80051b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	57                   	push   %edi
  8005dd:	ff 30                	pushl  (%eax)
  8005df:	ff d6                	call   *%esi
			break;
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	e9 af 01 00 00       	jmp    800798 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 04             	lea    0x4(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	99                   	cltd   
  8005f5:	31 d0                	xor    %edx,%eax
  8005f7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f9:	83 f8 08             	cmp    $0x8,%eax
  8005fc:	7f 20                	jg     80061e <vprintfmt+0x13c>
  8005fe:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  800605:	85 d2                	test   %edx,%edx
  800607:	74 15                	je     80061e <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800609:	52                   	push   %edx
  80060a:	68 df 0e 80 00       	push   $0x800edf
  80060f:	57                   	push   %edi
  800610:	56                   	push   %esi
  800611:	e8 af fe ff ff       	call   8004c5 <printfmt>
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	e9 7a 01 00 00       	jmp    800798 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  80061e:	50                   	push   %eax
  80061f:	68 d6 0e 80 00       	push   $0x800ed6
  800624:	57                   	push   %edi
  800625:	56                   	push   %esi
  800626:	e8 9a fe ff ff       	call   8004c5 <printfmt>
  80062b:	83 c4 10             	add    $0x10,%esp
  80062e:	e9 65 01 00 00       	jmp    800798 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 50 04             	lea    0x4(%eax),%edx
  800639:	89 55 14             	mov    %edx,0x14(%ebp)
  80063c:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  80063e:	85 db                	test   %ebx,%ebx
  800640:	b8 cf 0e 80 00       	mov    $0x800ecf,%eax
  800645:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  800648:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80064c:	0f 8e bd 00 00 00    	jle    80070f <vprintfmt+0x22d>
  800652:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800656:	75 0e                	jne    800666 <vprintfmt+0x184>
  800658:	89 75 08             	mov    %esi,0x8(%ebp)
  80065b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065e:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800661:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800664:	eb 6d                	jmp    8006d3 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	ff 75 d0             	pushl  -0x30(%ebp)
  80066c:	53                   	push   %ebx
  80066d:	e8 4d 02 00 00       	call   8008bf <strnlen>
  800672:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800675:	29 c1                	sub    %eax,%ecx
  800677:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80067a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80067d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800681:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800684:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800687:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800689:	eb 0f                	jmp    80069a <vprintfmt+0x1b8>
					putch(padc, putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	57                   	push   %edi
  80068f:	ff 75 e0             	pushl  -0x20(%ebp)
  800692:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800694:	83 eb 01             	sub    $0x1,%ebx
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	85 db                	test   %ebx,%ebx
  80069c:	7f ed                	jg     80068b <vprintfmt+0x1a9>
  80069e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006a4:	85 c9                	test   %ecx,%ecx
  8006a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ab:	0f 49 c1             	cmovns %ecx,%eax
  8006ae:	29 c1                	sub    %eax,%ecx
  8006b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b6:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006b9:	89 cf                	mov    %ecx,%edi
  8006bb:	eb 16                	jmp    8006d3 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8006bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c1:	75 31                	jne    8006f4 <vprintfmt+0x212>
					putch(ch, putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	ff 75 0c             	pushl  0xc(%ebp)
  8006c9:	50                   	push   %eax
  8006ca:	ff 55 08             	call   *0x8(%ebp)
  8006cd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d0:	83 ef 01             	sub    $0x1,%edi
  8006d3:	83 c3 01             	add    $0x1,%ebx
  8006d6:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8006da:	0f be c2             	movsbl %dl,%eax
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	74 50                	je     800731 <vprintfmt+0x24f>
  8006e1:	85 f6                	test   %esi,%esi
  8006e3:	78 d8                	js     8006bd <vprintfmt+0x1db>
  8006e5:	83 ee 01             	sub    $0x1,%esi
  8006e8:	79 d3                	jns    8006bd <vprintfmt+0x1db>
  8006ea:	89 fb                	mov    %edi,%ebx
  8006ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ef:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006f2:	eb 37                	jmp    80072b <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f4:	0f be d2             	movsbl %dl,%edx
  8006f7:	83 ea 20             	sub    $0x20,%edx
  8006fa:	83 fa 5e             	cmp    $0x5e,%edx
  8006fd:	76 c4                	jbe    8006c3 <vprintfmt+0x1e1>
					putch('?', putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	ff 75 0c             	pushl  0xc(%ebp)
  800705:	6a 3f                	push   $0x3f
  800707:	ff 55 08             	call   *0x8(%ebp)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	eb c1                	jmp    8006d0 <vprintfmt+0x1ee>
  80070f:	89 75 08             	mov    %esi,0x8(%ebp)
  800712:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800715:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800718:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80071b:	eb b6                	jmp    8006d3 <vprintfmt+0x1f1>
				putch(' ', putdat);
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	57                   	push   %edi
  800721:	6a 20                	push   $0x20
  800723:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800725:	83 eb 01             	sub    $0x1,%ebx
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 db                	test   %ebx,%ebx
  80072d:	7f ee                	jg     80071d <vprintfmt+0x23b>
  80072f:	eb 67                	jmp    800798 <vprintfmt+0x2b6>
  800731:	89 fb                	mov    %edi,%ebx
  800733:	8b 75 08             	mov    0x8(%ebp),%esi
  800736:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800739:	eb f0                	jmp    80072b <vprintfmt+0x249>
			num = getint(&ap, lflag);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	e8 33 fd ff ff       	call   800476 <getint>
  800743:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800746:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800749:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  80074e:	85 d2                	test   %edx,%edx
  800750:	79 2c                	jns    80077e <vprintfmt+0x29c>
				putch('-', putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	57                   	push   %edi
  800756:	6a 2d                	push   $0x2d
  800758:	ff d6                	call   *%esi
				num = -(long long) num;
  80075a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80075d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800760:	f7 d8                	neg    %eax
  800762:	83 d2 00             	adc    $0x0,%edx
  800765:	f7 da                	neg    %edx
  800767:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80076a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80076f:	eb 0d                	jmp    80077e <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 c3 fc ff ff       	call   80043c <getuint>
			base = 10;
  800779:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  80077e:	83 ec 0c             	sub    $0xc,%esp
  800781:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  800785:	53                   	push   %ebx
  800786:	ff 75 e0             	pushl  -0x20(%ebp)
  800789:	51                   	push   %ecx
  80078a:	52                   	push   %edx
  80078b:	50                   	push   %eax
  80078c:	89 fa                	mov    %edi,%edx
  80078e:	89 f0                	mov    %esi,%eax
  800790:	e8 f8 fb ff ff       	call   80038d <printnum>
			break;
  800795:	83 c4 20             	add    $0x20,%esp
{
  800798:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80079b:	83 c3 01             	add    $0x1,%ebx
  80079e:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8007a2:	83 f8 25             	cmp    $0x25,%eax
  8007a5:	0f 84 52 fd ff ff    	je     8004fd <vprintfmt+0x1b>
			if (ch == '\0')
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	0f 84 84 00 00 00    	je     800837 <vprintfmt+0x355>
			putch(ch, putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	57                   	push   %edi
  8007b7:	50                   	push   %eax
  8007b8:	ff d6                	call   *%esi
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb dc                	jmp    80079b <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c2:	e8 75 fc ff ff       	call   80043c <getuint>
			base = 8;
  8007c7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007cc:	eb b0                	jmp    80077e <vprintfmt+0x29c>
			putch('0', putdat);
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	57                   	push   %edi
  8007d2:	6a 30                	push   $0x30
  8007d4:	ff d6                	call   *%esi
			putch('x', putdat);
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	57                   	push   %edi
  8007da:	6a 78                	push   $0x78
  8007dc:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8d 50 04             	lea    0x4(%eax),%edx
  8007e4:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007e7:	8b 00                	mov    (%eax),%eax
  8007e9:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8007ee:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007f1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007f6:	eb 86                	jmp    80077e <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fb:	e8 3c fc ff ff       	call   80043c <getuint>
			base = 16;
  800800:	b9 10 00 00 00       	mov    $0x10,%ecx
  800805:	e9 74 ff ff ff       	jmp    80077e <vprintfmt+0x29c>
			putch(ch, putdat);
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	57                   	push   %edi
  80080e:	6a 25                	push   $0x25
  800810:	ff d6                	call   *%esi
			break;
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	eb 81                	jmp    800798 <vprintfmt+0x2b6>
			putch('%', putdat);
  800817:	83 ec 08             	sub    $0x8,%esp
  80081a:	57                   	push   %edi
  80081b:	6a 25                	push   $0x25
  80081d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	89 d8                	mov    %ebx,%eax
  800824:	eb 03                	jmp    800829 <vprintfmt+0x347>
  800826:	83 e8 01             	sub    $0x1,%eax
  800829:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80082d:	75 f7                	jne    800826 <vprintfmt+0x344>
  80082f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800832:	e9 61 ff ff ff       	jmp    800798 <vprintfmt+0x2b6>
}
  800837:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5f                   	pop    %edi
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	83 ec 18             	sub    $0x18,%esp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800852:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085c:	85 c0                	test   %eax,%eax
  80085e:	74 26                	je     800886 <vsnprintf+0x47>
  800860:	85 d2                	test   %edx,%edx
  800862:	7e 22                	jle    800886 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800864:	ff 75 14             	pushl  0x14(%ebp)
  800867:	ff 75 10             	pushl  0x10(%ebp)
  80086a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	68 a8 04 80 00       	push   $0x8004a8
  800873:	e8 6a fc ff ff       	call   8004e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	83 c4 10             	add    $0x10,%esp
}
  800884:	c9                   	leave  
  800885:	c3                   	ret    
		return -E_INVAL;
  800886:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088b:	eb f7                	jmp    800884 <vsnprintf+0x45>

0080088d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800893:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800896:	50                   	push   %eax
  800897:	ff 75 10             	pushl  0x10(%ebp)
  80089a:	ff 75 0c             	pushl  0xc(%ebp)
  80089d:	ff 75 08             	pushl  0x8(%ebp)
  8008a0:	e8 9a ff ff ff       	call   80083f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b2:	eb 03                	jmp    8008b7 <strlen+0x10>
		n++;
  8008b4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008b7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008bb:	75 f7                	jne    8008b4 <strlen+0xd>
	return n;
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cd:	eb 03                	jmp    8008d2 <strnlen+0x13>
		n++;
  8008cf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d2:	39 d0                	cmp    %edx,%eax
  8008d4:	74 06                	je     8008dc <strnlen+0x1d>
  8008d6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008da:	75 f3                	jne    8008cf <strnlen+0x10>
	return n;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	53                   	push   %ebx
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e8:	89 c2                	mov    %eax,%edx
  8008ea:	83 c1 01             	add    $0x1,%ecx
  8008ed:	83 c2 01             	add    $0x1,%edx
  8008f0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f7:	84 db                	test   %bl,%bl
  8008f9:	75 ef                	jne    8008ea <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008fb:	5b                   	pop    %ebx
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	53                   	push   %ebx
  800902:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800905:	53                   	push   %ebx
  800906:	e8 9c ff ff ff       	call   8008a7 <strlen>
  80090b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80090e:	ff 75 0c             	pushl  0xc(%ebp)
  800911:	01 d8                	add    %ebx,%eax
  800913:	50                   	push   %eax
  800914:	e8 c5 ff ff ff       	call   8008de <strcpy>
	return dst;
}
  800919:	89 d8                	mov    %ebx,%eax
  80091b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	8b 75 08             	mov    0x8(%ebp),%esi
  800928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092b:	89 f3                	mov    %esi,%ebx
  80092d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800930:	89 f2                	mov    %esi,%edx
  800932:	eb 0f                	jmp    800943 <strncpy+0x23>
		*dst++ = *src;
  800934:	83 c2 01             	add    $0x1,%edx
  800937:	0f b6 01             	movzbl (%ecx),%eax
  80093a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093d:	80 39 01             	cmpb   $0x1,(%ecx)
  800940:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800943:	39 da                	cmp    %ebx,%edx
  800945:	75 ed                	jne    800934 <strncpy+0x14>
	}
	return ret;
}
  800947:	89 f0                	mov    %esi,%eax
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	8b 75 08             	mov    0x8(%ebp),%esi
  800955:	8b 55 0c             	mov    0xc(%ebp),%edx
  800958:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80095b:	89 f0                	mov    %esi,%eax
  80095d:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800961:	85 c9                	test   %ecx,%ecx
  800963:	75 0b                	jne    800970 <strlcpy+0x23>
  800965:	eb 17                	jmp    80097e <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800967:	83 c2 01             	add    $0x1,%edx
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800970:	39 d8                	cmp    %ebx,%eax
  800972:	74 07                	je     80097b <strlcpy+0x2e>
  800974:	0f b6 0a             	movzbl (%edx),%ecx
  800977:	84 c9                	test   %cl,%cl
  800979:	75 ec                	jne    800967 <strlcpy+0x1a>
		*dst = '\0';
  80097b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80097e:	29 f0                	sub    %esi,%eax
}
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80098d:	eb 06                	jmp    800995 <strcmp+0x11>
		p++, q++;
  80098f:	83 c1 01             	add    $0x1,%ecx
  800992:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800995:	0f b6 01             	movzbl (%ecx),%eax
  800998:	84 c0                	test   %al,%al
  80099a:	74 04                	je     8009a0 <strcmp+0x1c>
  80099c:	3a 02                	cmp    (%edx),%al
  80099e:	74 ef                	je     80098f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a0:	0f b6 c0             	movzbl %al,%eax
  8009a3:	0f b6 12             	movzbl (%edx),%edx
  8009a6:	29 d0                	sub    %edx,%eax
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	53                   	push   %ebx
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b4:	89 c3                	mov    %eax,%ebx
  8009b6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b9:	eb 06                	jmp    8009c1 <strncmp+0x17>
		n--, p++, q++;
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c1:	39 d8                	cmp    %ebx,%eax
  8009c3:	74 16                	je     8009db <strncmp+0x31>
  8009c5:	0f b6 08             	movzbl (%eax),%ecx
  8009c8:	84 c9                	test   %cl,%cl
  8009ca:	74 04                	je     8009d0 <strncmp+0x26>
  8009cc:	3a 0a                	cmp    (%edx),%cl
  8009ce:	74 eb                	je     8009bb <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d0:	0f b6 00             	movzbl (%eax),%eax
  8009d3:	0f b6 12             	movzbl (%edx),%edx
  8009d6:	29 d0                	sub    %edx,%eax
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    
		return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e0:	eb f6                	jmp    8009d8 <strncmp+0x2e>

008009e2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ec:	0f b6 10             	movzbl (%eax),%edx
  8009ef:	84 d2                	test   %dl,%dl
  8009f1:	74 09                	je     8009fc <strchr+0x1a>
		if (*s == c)
  8009f3:	38 ca                	cmp    %cl,%dl
  8009f5:	74 0a                	je     800a01 <strchr+0x1f>
	for (; *s; s++)
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	eb f0                	jmp    8009ec <strchr+0xa>
			return (char *) s;
	return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0d:	eb 03                	jmp    800a12 <strfind+0xf>
  800a0f:	83 c0 01             	add    $0x1,%eax
  800a12:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a15:	38 ca                	cmp    %cl,%dl
  800a17:	74 04                	je     800a1d <strfind+0x1a>
  800a19:	84 d2                	test   %dl,%dl
  800a1b:	75 f2                	jne    800a0f <strfind+0xc>
			break;
	return (char *) s;
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 55 08             	mov    0x8(%ebp),%edx
  800a28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a2b:	85 c9                	test   %ecx,%ecx
  800a2d:	74 12                	je     800a41 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2f:	f6 c2 03             	test   $0x3,%dl
  800a32:	75 05                	jne    800a39 <memset+0x1a>
  800a34:	f6 c1 03             	test   $0x3,%cl
  800a37:	74 0f                	je     800a48 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a39:	89 d7                	mov    %edx,%edi
  800a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3e:	fc                   	cld    
  800a3f:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a41:	89 d0                	mov    %edx,%eax
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5f                   	pop    %edi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    
		c &= 0xFF;
  800a48:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4c:	89 d8                	mov    %ebx,%eax
  800a4e:	c1 e0 08             	shl    $0x8,%eax
  800a51:	89 df                	mov    %ebx,%edi
  800a53:	c1 e7 18             	shl    $0x18,%edi
  800a56:	89 de                	mov    %ebx,%esi
  800a58:	c1 e6 10             	shl    $0x10,%esi
  800a5b:	09 f7                	or     %esi,%edi
  800a5d:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a62:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a64:	89 d7                	mov    %edx,%edi
  800a66:	fc                   	cld    
  800a67:	f3 ab                	rep stos %eax,%es:(%edi)
  800a69:	eb d6                	jmp    800a41 <memset+0x22>

00800a6b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a79:	39 c6                	cmp    %eax,%esi
  800a7b:	73 35                	jae    800ab2 <memmove+0x47>
  800a7d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a80:	39 c2                	cmp    %eax,%edx
  800a82:	76 2e                	jbe    800ab2 <memmove+0x47>
		s += n;
		d += n;
  800a84:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a87:	89 d6                	mov    %edx,%esi
  800a89:	09 fe                	or     %edi,%esi
  800a8b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a91:	74 0c                	je     800a9f <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a93:	83 ef 01             	sub    $0x1,%edi
  800a96:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a99:	fd                   	std    
  800a9a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9c:	fc                   	cld    
  800a9d:	eb 21                	jmp    800ac0 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9f:	f6 c1 03             	test   $0x3,%cl
  800aa2:	75 ef                	jne    800a93 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa4:	83 ef 04             	sub    $0x4,%edi
  800aa7:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aaa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aad:	fd                   	std    
  800aae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab0:	eb ea                	jmp    800a9c <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab2:	89 f2                	mov    %esi,%edx
  800ab4:	09 c2                	or     %eax,%edx
  800ab6:	f6 c2 03             	test   $0x3,%dl
  800ab9:	74 09                	je     800ac4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	fc                   	cld    
  800abe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	f6 c1 03             	test   $0x3,%cl
  800ac7:	75 f2                	jne    800abb <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800acc:	89 c7                	mov    %eax,%edi
  800ace:	fc                   	cld    
  800acf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad1:	eb ed                	jmp    800ac0 <memmove+0x55>

00800ad3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ad6:	ff 75 10             	pushl  0x10(%ebp)
  800ad9:	ff 75 0c             	pushl  0xc(%ebp)
  800adc:	ff 75 08             	pushl  0x8(%ebp)
  800adf:	e8 87 ff ff ff       	call   800a6b <memmove>
}
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af1:	89 c6                	mov    %eax,%esi
  800af3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af6:	39 f0                	cmp    %esi,%eax
  800af8:	74 1c                	je     800b16 <memcmp+0x30>
		if (*s1 != *s2)
  800afa:	0f b6 08             	movzbl (%eax),%ecx
  800afd:	0f b6 1a             	movzbl (%edx),%ebx
  800b00:	38 d9                	cmp    %bl,%cl
  800b02:	75 08                	jne    800b0c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b04:	83 c0 01             	add    $0x1,%eax
  800b07:	83 c2 01             	add    $0x1,%edx
  800b0a:	eb ea                	jmp    800af6 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b0c:	0f b6 c1             	movzbl %cl,%eax
  800b0f:	0f b6 db             	movzbl %bl,%ebx
  800b12:	29 d8                	sub    %ebx,%eax
  800b14:	eb 05                	jmp    800b1b <memcmp+0x35>
	}

	return 0;
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b2d:	39 d0                	cmp    %edx,%eax
  800b2f:	73 09                	jae    800b3a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b31:	38 08                	cmp    %cl,(%eax)
  800b33:	74 05                	je     800b3a <memfind+0x1b>
	for (; s < ends; s++)
  800b35:	83 c0 01             	add    $0x1,%eax
  800b38:	eb f3                	jmp    800b2d <memfind+0xe>
			break;
	return (void *) s;
}
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b48:	eb 03                	jmp    800b4d <strtol+0x11>
		s++;
  800b4a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b4d:	0f b6 01             	movzbl (%ecx),%eax
  800b50:	3c 20                	cmp    $0x20,%al
  800b52:	74 f6                	je     800b4a <strtol+0xe>
  800b54:	3c 09                	cmp    $0x9,%al
  800b56:	74 f2                	je     800b4a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b58:	3c 2b                	cmp    $0x2b,%al
  800b5a:	74 2e                	je     800b8a <strtol+0x4e>
	int neg = 0;
  800b5c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b61:	3c 2d                	cmp    $0x2d,%al
  800b63:	74 2f                	je     800b94 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6b:	75 05                	jne    800b72 <strtol+0x36>
  800b6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b70:	74 2c                	je     800b9e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b72:	85 db                	test   %ebx,%ebx
  800b74:	75 0a                	jne    800b80 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b76:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b7b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7e:	74 28                	je     800ba8 <strtol+0x6c>
		base = 10;
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
  800b85:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b88:	eb 50                	jmp    800bda <strtol+0x9e>
		s++;
  800b8a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b8d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b92:	eb d1                	jmp    800b65 <strtol+0x29>
		s++, neg = 1;
  800b94:	83 c1 01             	add    $0x1,%ecx
  800b97:	bf 01 00 00 00       	mov    $0x1,%edi
  800b9c:	eb c7                	jmp    800b65 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba2:	74 0e                	je     800bb2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ba4:	85 db                	test   %ebx,%ebx
  800ba6:	75 d8                	jne    800b80 <strtol+0x44>
		s++, base = 8;
  800ba8:	83 c1 01             	add    $0x1,%ecx
  800bab:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb0:	eb ce                	jmp    800b80 <strtol+0x44>
		s += 2, base = 16;
  800bb2:	83 c1 02             	add    $0x2,%ecx
  800bb5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bba:	eb c4                	jmp    800b80 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bbc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bbf:	89 f3                	mov    %esi,%ebx
  800bc1:	80 fb 19             	cmp    $0x19,%bl
  800bc4:	77 29                	ja     800bef <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bc6:	0f be d2             	movsbl %dl,%edx
  800bc9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bcf:	7d 30                	jge    800c01 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd1:	83 c1 01             	add    $0x1,%ecx
  800bd4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bda:	0f b6 11             	movzbl (%ecx),%edx
  800bdd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be0:	89 f3                	mov    %esi,%ebx
  800be2:	80 fb 09             	cmp    $0x9,%bl
  800be5:	77 d5                	ja     800bbc <strtol+0x80>
			dig = *s - '0';
  800be7:	0f be d2             	movsbl %dl,%edx
  800bea:	83 ea 30             	sub    $0x30,%edx
  800bed:	eb dd                	jmp    800bcc <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bef:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf2:	89 f3                	mov    %esi,%ebx
  800bf4:	80 fb 19             	cmp    $0x19,%bl
  800bf7:	77 08                	ja     800c01 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bf9:	0f be d2             	movsbl %dl,%edx
  800bfc:	83 ea 37             	sub    $0x37,%edx
  800bff:	eb cb                	jmp    800bcc <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c05:	74 05                	je     800c0c <strtol+0xd0>
		*endptr = (char *) s;
  800c07:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c0c:	89 c2                	mov    %eax,%edx
  800c0e:	f7 da                	neg    %edx
  800c10:	85 ff                	test   %edi,%edi
  800c12:	0f 45 c2             	cmovne %edx,%eax
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    
  800c1a:	66 90                	xchg   %ax,%ax
  800c1c:	66 90                	xchg   %ax,%ax
  800c1e:	66 90                	xchg   %ax,%ax

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
