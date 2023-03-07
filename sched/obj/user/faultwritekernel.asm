
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80004d:	e8 02 01 00 00       	call   800154 <sys_getenvid>
	if (id >= 0)
  800052:	85 c0                	test   %eax,%eax
  800054:	78 12                	js     800068 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800056:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005b:	c1 e0 07             	shl    $0x7,%eax
  80005e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800063:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800068:	85 db                	test   %ebx,%ebx
  80006a:	7e 07                	jle    800073 <libmain+0x31>
		binaryname = argv[0];
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800073:	83 ec 08             	sub    $0x8,%esp
  800076:	56                   	push   %esi
  800077:	53                   	push   %ebx
  800078:	e8 b6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007d:	e8 0a 00 00 00       	call   80008c <exit>
}
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800088:	5b                   	pop    %ebx
  800089:	5e                   	pop    %esi
  80008a:	5d                   	pop    %ebp
  80008b:	c3                   	ret    

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 99 00 00 00       	call   800132 <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
  8000a4:	83 ec 1c             	sub    $0x1c,%esp
  8000a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000ad:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000b5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000b8:	8b 75 14             	mov    0x14(%ebp),%esi
  8000bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c1:	74 04                	je     8000c7 <syscall+0x29>
  8000c3:	85 c0                	test   %eax,%eax
  8000c5:	7f 08                	jg     8000cf <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    
  8000cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d2:	83 ec 0c             	sub    $0xc,%esp
  8000d5:	50                   	push   %eax
  8000d6:	52                   	push   %edx
  8000d7:	68 6a 0e 80 00       	push   $0x800e6a
  8000dc:	6a 23                	push   $0x23
  8000de:	68 87 0e 80 00       	push   $0x800e87
  8000e3:	e8 b1 01 00 00       	call   800299 <_panic>

008000e8 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000ee:	6a 00                	push   $0x0
  8000f0:	6a 00                	push   $0x0
  8000f2:	6a 00                	push   $0x0
  8000f4:	ff 75 0c             	pushl  0xc(%ebp)
  8000f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800104:	e8 95 ff ff ff       	call   80009e <syscall>
}
  800109:	83 c4 10             	add    $0x10,%esp
  80010c:	c9                   	leave  
  80010d:	c3                   	ret    

0080010e <sys_cgetc>:

int
sys_cgetc(void)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800114:	6a 00                	push   $0x0
  800116:	6a 00                	push   $0x0
  800118:	6a 00                	push   $0x0
  80011a:	6a 00                	push   $0x0
  80011c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800121:	ba 00 00 00 00       	mov    $0x0,%edx
  800126:	b8 01 00 00 00       	mov    $0x1,%eax
  80012b:	e8 6e ff ff ff       	call   80009e <syscall>
}
  800130:	c9                   	leave  
  800131:	c3                   	ret    

00800132 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800138:	6a 00                	push   $0x0
  80013a:	6a 00                	push   $0x0
  80013c:	6a 00                	push   $0x0
  80013e:	6a 00                	push   $0x0
  800140:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800143:	ba 01 00 00 00       	mov    $0x1,%edx
  800148:	b8 03 00 00 00       	mov    $0x3,%eax
  80014d:	e8 4c ff ff ff       	call   80009e <syscall>
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80015a:	6a 00                	push   $0x0
  80015c:	6a 00                	push   $0x0
  80015e:	6a 00                	push   $0x0
  800160:	6a 00                	push   $0x0
  800162:	b9 00 00 00 00       	mov    $0x0,%ecx
  800167:	ba 00 00 00 00       	mov    $0x0,%edx
  80016c:	b8 02 00 00 00       	mov    $0x2,%eax
  800171:	e8 28 ff ff ff       	call   80009e <syscall>
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <sys_yield>:

void
sys_yield(void)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80017e:	6a 00                	push   $0x0
  800180:	6a 00                	push   $0x0
  800182:	6a 00                	push   $0x0
  800184:	6a 00                	push   $0x0
  800186:	b9 00 00 00 00       	mov    $0x0,%ecx
  80018b:	ba 00 00 00 00       	mov    $0x0,%edx
  800190:	b8 0a 00 00 00       	mov    $0xa,%eax
  800195:	e8 04 ff ff ff       	call   80009e <syscall>
}
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001a5:	6a 00                	push   $0x0
  8001a7:	6a 00                	push   $0x0
  8001a9:	ff 75 10             	pushl  0x10(%ebp)
  8001ac:	ff 75 0c             	pushl  0xc(%ebp)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	ba 01 00 00 00       	mov    $0x1,%edx
  8001b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8001bc:	e8 dd fe ff ff       	call   80009e <syscall>
}
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001c9:	ff 75 18             	pushl  0x18(%ebp)
  8001cc:	ff 75 14             	pushl  0x14(%ebp)
  8001cf:	ff 75 10             	pushl  0x10(%ebp)
  8001d2:	ff 75 0c             	pushl  0xc(%ebp)
  8001d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d8:	ba 01 00 00 00       	mov    $0x1,%edx
  8001dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e2:	e8 b7 fe ff ff       	call   80009e <syscall>
}
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001ef:	6a 00                	push   $0x0
  8001f1:	6a 00                	push   $0x0
  8001f3:	6a 00                	push   $0x0
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fb:	ba 01 00 00 00       	mov    $0x1,%edx
  800200:	b8 06 00 00 00       	mov    $0x6,%eax
  800205:	e8 94 fe ff ff       	call   80009e <syscall>
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800212:	6a 00                	push   $0x0
  800214:	6a 00                	push   $0x0
  800216:	6a 00                	push   $0x0
  800218:	ff 75 0c             	pushl  0xc(%ebp)
  80021b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021e:	ba 01 00 00 00       	mov    $0x1,%edx
  800223:	b8 08 00 00 00       	mov    $0x8,%eax
  800228:	e8 71 fe ff ff       	call   80009e <syscall>
}
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800235:	6a 00                	push   $0x0
  800237:	6a 00                	push   $0x0
  800239:	6a 00                	push   $0x0
  80023b:	ff 75 0c             	pushl  0xc(%ebp)
  80023e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800241:	ba 01 00 00 00       	mov    $0x1,%edx
  800246:	b8 09 00 00 00       	mov    $0x9,%eax
  80024b:	e8 4e fe ff ff       	call   80009e <syscall>
}
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800258:	6a 00                	push   $0x0
  80025a:	ff 75 14             	pushl  0x14(%ebp)
  80025d:	ff 75 10             	pushl  0x10(%ebp)
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800266:	ba 00 00 00 00       	mov    $0x0,%edx
  80026b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800270:	e8 29 fe ff ff       	call   80009e <syscall>
}
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80027d:	6a 00                	push   $0x0
  80027f:	6a 00                	push   $0x0
  800281:	6a 00                	push   $0x0
  800283:	6a 00                	push   $0x0
  800285:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800288:	ba 01 00 00 00       	mov    $0x1,%edx
  80028d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800292:	e8 07 fe ff ff       	call   80009e <syscall>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002a7:	e8 a8 fe ff ff       	call   800154 <sys_getenvid>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	ff 75 0c             	pushl  0xc(%ebp)
  8002b2:	ff 75 08             	pushl  0x8(%ebp)
  8002b5:	56                   	push   %esi
  8002b6:	50                   	push   %eax
  8002b7:	68 98 0e 80 00       	push   $0x800e98
  8002bc:	e8 b3 00 00 00       	call   800374 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c1:	83 c4 18             	add    $0x18,%esp
  8002c4:	53                   	push   %ebx
  8002c5:	ff 75 10             	pushl  0x10(%ebp)
  8002c8:	e8 56 00 00 00       	call   800323 <vcprintf>
	cprintf("\n");
  8002cd:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  8002d4:	e8 9b 00 00 00       	call   800374 <cprintf>
  8002d9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002dc:	cc                   	int3   
  8002dd:	eb fd                	jmp    8002dc <_panic+0x43>

008002df <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	53                   	push   %ebx
  8002e3:	83 ec 04             	sub    $0x4,%esp
  8002e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e9:	8b 13                	mov    (%ebx),%edx
  8002eb:	8d 42 01             	lea    0x1(%edx),%eax
  8002ee:	89 03                	mov    %eax,(%ebx)
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fc:	74 09                	je     800307 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002fe:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800305:	c9                   	leave  
  800306:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	68 ff 00 00 00       	push   $0xff
  80030f:	8d 43 08             	lea    0x8(%ebx),%eax
  800312:	50                   	push   %eax
  800313:	e8 d0 fd ff ff       	call   8000e8 <sys_cputs>
		b->idx = 0;
  800318:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80031e:	83 c4 10             	add    $0x10,%esp
  800321:	eb db                	jmp    8002fe <putch+0x1f>

00800323 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80032c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800333:	00 00 00 
	b.cnt = 0;
  800336:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	ff 75 08             	pushl  0x8(%ebp)
  800346:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80034c:	50                   	push   %eax
  80034d:	68 df 02 80 00       	push   $0x8002df
  800352:	e8 86 01 00 00       	call   8004dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800357:	83 c4 08             	add    $0x8,%esp
  80035a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800360:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800366:	50                   	push   %eax
  800367:	e8 7c fd ff ff       	call   8000e8 <sys_cputs>

	return b.cnt;
}
  80036c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800372:	c9                   	leave  
  800373:	c3                   	ret    

00800374 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80037a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037d:	50                   	push   %eax
  80037e:	ff 75 08             	pushl  0x8(%ebp)
  800381:	e8 9d ff ff ff       	call   800323 <vcprintf>
	va_end(ap);

	return cnt;
}
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	57                   	push   %edi
  80038c:	56                   	push   %esi
  80038d:	53                   	push   %ebx
  80038e:	83 ec 1c             	sub    $0x1c,%esp
  800391:	89 c7                	mov    %eax,%edi
  800393:	89 d6                	mov    %edx,%esi
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003ac:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003af:	39 d3                	cmp    %edx,%ebx
  8003b1:	72 05                	jb     8003b8 <printnum+0x30>
  8003b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b6:	77 7a                	ja     800432 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b8:	83 ec 0c             	sub    $0xc,%esp
  8003bb:	ff 75 18             	pushl  0x18(%ebp)
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c4:	53                   	push   %ebx
  8003c5:	ff 75 10             	pushl  0x10(%ebp)
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d7:	e8 44 08 00 00       	call   800c20 <__udivdi3>
  8003dc:	83 c4 18             	add    $0x18,%esp
  8003df:	52                   	push   %edx
  8003e0:	50                   	push   %eax
  8003e1:	89 f2                	mov    %esi,%edx
  8003e3:	89 f8                	mov    %edi,%eax
  8003e5:	e8 9e ff ff ff       	call   800388 <printnum>
  8003ea:	83 c4 20             	add    $0x20,%esp
  8003ed:	eb 13                	jmp    800402 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	56                   	push   %esi
  8003f3:	ff 75 18             	pushl  0x18(%ebp)
  8003f6:	ff d7                	call   *%edi
  8003f8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003fb:	83 eb 01             	sub    $0x1,%ebx
  8003fe:	85 db                	test   %ebx,%ebx
  800400:	7f ed                	jg     8003ef <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	56                   	push   %esi
  800406:	83 ec 04             	sub    $0x4,%esp
  800409:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040c:	ff 75 e0             	pushl  -0x20(%ebp)
  80040f:	ff 75 dc             	pushl  -0x24(%ebp)
  800412:	ff 75 d8             	pushl  -0x28(%ebp)
  800415:	e8 26 09 00 00       	call   800d40 <__umoddi3>
  80041a:	83 c4 14             	add    $0x14,%esp
  80041d:	0f be 80 be 0e 80 00 	movsbl 0x800ebe(%eax),%eax
  800424:	50                   	push   %eax
  800425:	ff d7                	call   *%edi
}
  800427:	83 c4 10             	add    $0x10,%esp
  80042a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042d:	5b                   	pop    %ebx
  80042e:	5e                   	pop    %esi
  80042f:	5f                   	pop    %edi
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    
  800432:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800435:	eb c4                	jmp    8003fb <printnum+0x73>

00800437 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80043a:	83 fa 01             	cmp    $0x1,%edx
  80043d:	7e 0e                	jle    80044d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043f:	8b 10                	mov    (%eax),%edx
  800441:	8d 4a 08             	lea    0x8(%edx),%ecx
  800444:	89 08                	mov    %ecx,(%eax)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  80044b:	5d                   	pop    %ebp
  80044c:	c3                   	ret    
	else if (lflag)
  80044d:	85 d2                	test   %edx,%edx
  80044f:	75 10                	jne    800461 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800451:	8b 10                	mov    (%eax),%edx
  800453:	8d 4a 04             	lea    0x4(%edx),%ecx
  800456:	89 08                	mov    %ecx,(%eax)
  800458:	8b 02                	mov    (%edx),%eax
  80045a:	ba 00 00 00 00       	mov    $0x0,%edx
  80045f:	eb ea                	jmp    80044b <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800461:	8b 10                	mov    (%eax),%edx
  800463:	8d 4a 04             	lea    0x4(%edx),%ecx
  800466:	89 08                	mov    %ecx,(%eax)
  800468:	8b 02                	mov    (%edx),%eax
  80046a:	ba 00 00 00 00       	mov    $0x0,%edx
  80046f:	eb da                	jmp    80044b <getuint+0x14>

00800471 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800474:	83 fa 01             	cmp    $0x1,%edx
  800477:	7e 0e                	jle    800487 <getint+0x16>
		return va_arg(*ap, long long);
  800479:	8b 10                	mov    (%eax),%edx
  80047b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80047e:	89 08                	mov    %ecx,(%eax)
  800480:	8b 02                	mov    (%edx),%eax
  800482:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800485:	5d                   	pop    %ebp
  800486:	c3                   	ret    
	else if (lflag)
  800487:	85 d2                	test   %edx,%edx
  800489:	75 0c                	jne    800497 <getint+0x26>
		return va_arg(*ap, int);
  80048b:	8b 10                	mov    (%eax),%edx
  80048d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800490:	89 08                	mov    %ecx,(%eax)
  800492:	8b 02                	mov    (%edx),%eax
  800494:	99                   	cltd   
  800495:	eb ee                	jmp    800485 <getint+0x14>
		return va_arg(*ap, long);
  800497:	8b 10                	mov    (%eax),%edx
  800499:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049c:	89 08                	mov    %ecx,(%eax)
  80049e:	8b 02                	mov    (%edx),%eax
  8004a0:	99                   	cltd   
  8004a1:	eb e2                	jmp    800485 <getint+0x14>

008004a3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a3:	55                   	push   %ebp
  8004a4:	89 e5                	mov    %esp,%ebp
  8004a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ad:	8b 10                	mov    (%eax),%edx
  8004af:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b2:	73 0a                	jae    8004be <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b7:	89 08                	mov    %ecx,(%eax)
  8004b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bc:	88 02                	mov    %al,(%edx)
}
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <printfmt>:
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004c6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c9:	50                   	push   %eax
  8004ca:	ff 75 10             	pushl  0x10(%ebp)
  8004cd:	ff 75 0c             	pushl  0xc(%ebp)
  8004d0:	ff 75 08             	pushl  0x8(%ebp)
  8004d3:	e8 05 00 00 00       	call   8004dd <vprintfmt>
}
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	c9                   	leave  
  8004dc:	c3                   	ret    

008004dd <vprintfmt>:
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
  8004e0:	57                   	push   %edi
  8004e1:	56                   	push   %esi
  8004e2:	53                   	push   %ebx
  8004e3:	83 ec 2c             	sub    $0x2c,%esp
  8004e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004ec:	89 f7                	mov    %esi,%edi
  8004ee:	89 de                	mov    %ebx,%esi
  8004f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004f3:	e9 9e 02 00 00       	jmp    800796 <vprintfmt+0x2b9>
		padc = ' ';
  8004f8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004fc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800503:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80050a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800511:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8d 43 01             	lea    0x1(%ebx),%eax
  800519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80051c:	0f b6 0b             	movzbl (%ebx),%ecx
  80051f:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800522:	3c 55                	cmp    $0x55,%al
  800524:	0f 87 e8 02 00 00    	ja     800812 <vprintfmt+0x335>
  80052a:	0f b6 c0             	movzbl %al,%eax
  80052d:	ff 24 85 80 0f 80 00 	jmp    *0x800f80(,%eax,4)
  800534:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800537:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80053b:	eb d9                	jmp    800516 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800540:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800544:	eb d0                	jmp    800516 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800546:	0f b6 c9             	movzbl %cl,%ecx
  800549:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80054c:	b8 00 00 00 00       	mov    $0x0,%eax
  800551:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800554:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800557:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80055b:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80055e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800561:	83 fa 09             	cmp    $0x9,%edx
  800564:	77 52                	ja     8005b8 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800566:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800569:	eb e9                	jmp    800554 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 48 04             	lea    0x4(%eax),%ecx
  800571:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80057c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800580:	79 94                	jns    800516 <vprintfmt+0x39>
				width = precision, precision = -1;
  800582:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800585:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800588:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80058f:	eb 85                	jmp    800516 <vprintfmt+0x39>
  800591:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800594:	85 c0                	test   %eax,%eax
  800596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059b:	0f 49 c8             	cmovns %eax,%ecx
  80059e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a4:	e9 6d ff ff ff       	jmp    800516 <vprintfmt+0x39>
  8005a9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8005ac:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b3:	e9 5e ff ff ff       	jmp    800516 <vprintfmt+0x39>
  8005b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005be:	eb bc                	jmp    80057c <vprintfmt+0x9f>
			lflag++;
  8005c0:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8005c6:	e9 4b ff ff ff       	jmp    800516 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	57                   	push   %edi
  8005d8:	ff 30                	pushl  (%eax)
  8005da:	ff d6                	call   *%esi
			break;
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	e9 af 01 00 00       	jmp    800793 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	99                   	cltd   
  8005f0:	31 d0                	xor    %edx,%eax
  8005f2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f4:	83 f8 08             	cmp    $0x8,%eax
  8005f7:	7f 20                	jg     800619 <vprintfmt+0x13c>
  8005f9:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  800600:	85 d2                	test   %edx,%edx
  800602:	74 15                	je     800619 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800604:	52                   	push   %edx
  800605:	68 df 0e 80 00       	push   $0x800edf
  80060a:	57                   	push   %edi
  80060b:	56                   	push   %esi
  80060c:	e8 af fe ff ff       	call   8004c0 <printfmt>
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	e9 7a 01 00 00       	jmp    800793 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800619:	50                   	push   %eax
  80061a:	68 d6 0e 80 00       	push   $0x800ed6
  80061f:	57                   	push   %edi
  800620:	56                   	push   %esi
  800621:	e8 9a fe ff ff       	call   8004c0 <printfmt>
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	e9 65 01 00 00       	jmp    800793 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800639:	85 db                	test   %ebx,%ebx
  80063b:	b8 cf 0e 80 00       	mov    $0x800ecf,%eax
  800640:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  800643:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800647:	0f 8e bd 00 00 00    	jle    80070a <vprintfmt+0x22d>
  80064d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800651:	75 0e                	jne    800661 <vprintfmt+0x184>
  800653:	89 75 08             	mov    %esi,0x8(%ebp)
  800656:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800659:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80065c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80065f:	eb 6d                	jmp    8006ce <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	ff 75 d0             	pushl  -0x30(%ebp)
  800667:	53                   	push   %ebx
  800668:	e8 4d 02 00 00       	call   8008ba <strnlen>
  80066d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800670:	29 c1                	sub    %eax,%ecx
  800672:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800675:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800678:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80067c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80067f:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800682:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800684:	eb 0f                	jmp    800695 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	57                   	push   %edi
  80068a:	ff 75 e0             	pushl  -0x20(%ebp)
  80068d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	83 eb 01             	sub    $0x1,%ebx
  800692:	83 c4 10             	add    $0x10,%esp
  800695:	85 db                	test   %ebx,%ebx
  800697:	7f ed                	jg     800686 <vprintfmt+0x1a9>
  800699:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80069c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80069f:	85 c9                	test   %ecx,%ecx
  8006a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a6:	0f 49 c1             	cmovns %ecx,%eax
  8006a9:	29 c1                	sub    %eax,%ecx
  8006ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b1:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006b4:	89 cf                	mov    %ecx,%edi
  8006b6:	eb 16                	jmp    8006ce <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8006b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006bc:	75 31                	jne    8006ef <vprintfmt+0x212>
					putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	50                   	push   %eax
  8006c5:	ff 55 08             	call   *0x8(%ebp)
  8006c8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cb:	83 ef 01             	sub    $0x1,%edi
  8006ce:	83 c3 01             	add    $0x1,%ebx
  8006d1:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8006d5:	0f be c2             	movsbl %dl,%eax
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	74 50                	je     80072c <vprintfmt+0x24f>
  8006dc:	85 f6                	test   %esi,%esi
  8006de:	78 d8                	js     8006b8 <vprintfmt+0x1db>
  8006e0:	83 ee 01             	sub    $0x1,%esi
  8006e3:	79 d3                	jns    8006b8 <vprintfmt+0x1db>
  8006e5:	89 fb                	mov    %edi,%ebx
  8006e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006ed:	eb 37                	jmp    800726 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ef:	0f be d2             	movsbl %dl,%edx
  8006f2:	83 ea 20             	sub    $0x20,%edx
  8006f5:	83 fa 5e             	cmp    $0x5e,%edx
  8006f8:	76 c4                	jbe    8006be <vprintfmt+0x1e1>
					putch('?', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	ff 75 0c             	pushl  0xc(%ebp)
  800700:	6a 3f                	push   $0x3f
  800702:	ff 55 08             	call   *0x8(%ebp)
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	eb c1                	jmp    8006cb <vprintfmt+0x1ee>
  80070a:	89 75 08             	mov    %esi,0x8(%ebp)
  80070d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800710:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800713:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800716:	eb b6                	jmp    8006ce <vprintfmt+0x1f1>
				putch(' ', putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	57                   	push   %edi
  80071c:	6a 20                	push   $0x20
  80071e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800720:	83 eb 01             	sub    $0x1,%ebx
  800723:	83 c4 10             	add    $0x10,%esp
  800726:	85 db                	test   %ebx,%ebx
  800728:	7f ee                	jg     800718 <vprintfmt+0x23b>
  80072a:	eb 67                	jmp    800793 <vprintfmt+0x2b6>
  80072c:	89 fb                	mov    %edi,%ebx
  80072e:	8b 75 08             	mov    0x8(%ebp),%esi
  800731:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800734:	eb f0                	jmp    800726 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
  800739:	e8 33 fd ff ff       	call   800471 <getint>
  80073e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800741:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800744:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800749:	85 d2                	test   %edx,%edx
  80074b:	79 2c                	jns    800779 <vprintfmt+0x29c>
				putch('-', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	57                   	push   %edi
  800751:	6a 2d                	push   $0x2d
  800753:	ff d6                	call   *%esi
				num = -(long long) num;
  800755:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800758:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80075b:	f7 d8                	neg    %eax
  80075d:	83 d2 00             	adc    $0x0,%edx
  800760:	f7 da                	neg    %edx
  800762:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800765:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80076a:	eb 0d                	jmp    800779 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
  80076f:	e8 c3 fc ff ff       	call   800437 <getuint>
			base = 10;
  800774:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800779:	83 ec 0c             	sub    $0xc,%esp
  80077c:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  800780:	53                   	push   %ebx
  800781:	ff 75 e0             	pushl  -0x20(%ebp)
  800784:	51                   	push   %ecx
  800785:	52                   	push   %edx
  800786:	50                   	push   %eax
  800787:	89 fa                	mov    %edi,%edx
  800789:	89 f0                	mov    %esi,%eax
  80078b:	e8 f8 fb ff ff       	call   800388 <printnum>
			break;
  800790:	83 c4 20             	add    $0x20,%esp
{
  800793:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800796:	83 c3 01             	add    $0x1,%ebx
  800799:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  80079d:	83 f8 25             	cmp    $0x25,%eax
  8007a0:	0f 84 52 fd ff ff    	je     8004f8 <vprintfmt+0x1b>
			if (ch == '\0')
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	0f 84 84 00 00 00    	je     800832 <vprintfmt+0x355>
			putch(ch, putdat);
  8007ae:	83 ec 08             	sub    $0x8,%esp
  8007b1:	57                   	push   %edi
  8007b2:	50                   	push   %eax
  8007b3:	ff d6                	call   *%esi
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	eb dc                	jmp    800796 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bd:	e8 75 fc ff ff       	call   800437 <getuint>
			base = 8;
  8007c2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007c7:	eb b0                	jmp    800779 <vprintfmt+0x29c>
			putch('0', putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	57                   	push   %edi
  8007cd:	6a 30                	push   $0x30
  8007cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8007d1:	83 c4 08             	add    $0x8,%esp
  8007d4:	57                   	push   %edi
  8007d5:	6a 78                	push   $0x78
  8007d7:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 04             	lea    0x4(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007e2:	8b 00                	mov    (%eax),%eax
  8007e4:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8007e9:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007ec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007f1:	eb 86                	jmp    800779 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f6:	e8 3c fc ff ff       	call   800437 <getuint>
			base = 16;
  8007fb:	b9 10 00 00 00       	mov    $0x10,%ecx
  800800:	e9 74 ff ff ff       	jmp    800779 <vprintfmt+0x29c>
			putch(ch, putdat);
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	57                   	push   %edi
  800809:	6a 25                	push   $0x25
  80080b:	ff d6                	call   *%esi
			break;
  80080d:	83 c4 10             	add    $0x10,%esp
  800810:	eb 81                	jmp    800793 <vprintfmt+0x2b6>
			putch('%', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	57                   	push   %edi
  800816:	6a 25                	push   $0x25
  800818:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	89 d8                	mov    %ebx,%eax
  80081f:	eb 03                	jmp    800824 <vprintfmt+0x347>
  800821:	83 e8 01             	sub    $0x1,%eax
  800824:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800828:	75 f7                	jne    800821 <vprintfmt+0x344>
  80082a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80082d:	e9 61 ff ff ff       	jmp    800793 <vprintfmt+0x2b6>
}
  800832:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5f                   	pop    %edi
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	83 ec 18             	sub    $0x18,%esp
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800846:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800849:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80084d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800850:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800857:	85 c0                	test   %eax,%eax
  800859:	74 26                	je     800881 <vsnprintf+0x47>
  80085b:	85 d2                	test   %edx,%edx
  80085d:	7e 22                	jle    800881 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085f:	ff 75 14             	pushl  0x14(%ebp)
  800862:	ff 75 10             	pushl  0x10(%ebp)
  800865:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	68 a3 04 80 00       	push   $0x8004a3
  80086e:	e8 6a fc ff ff       	call   8004dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800873:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800876:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800879:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087c:	83 c4 10             	add    $0x10,%esp
}
  80087f:	c9                   	leave  
  800880:	c3                   	ret    
		return -E_INVAL;
  800881:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800886:	eb f7                	jmp    80087f <vsnprintf+0x45>

00800888 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80088e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800891:	50                   	push   %eax
  800892:	ff 75 10             	pushl  0x10(%ebp)
  800895:	ff 75 0c             	pushl  0xc(%ebp)
  800898:	ff 75 08             	pushl  0x8(%ebp)
  80089b:	e8 9a ff ff ff       	call   80083a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ad:	eb 03                	jmp    8008b2 <strlen+0x10>
		n++;
  8008af:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b6:	75 f7                	jne    8008af <strlen+0xd>
	return n;
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 03                	jmp    8008cd <strnlen+0x13>
		n++;
  8008ca:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cd:	39 d0                	cmp    %edx,%eax
  8008cf:	74 06                	je     8008d7 <strnlen+0x1d>
  8008d1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d5:	75 f3                	jne    8008ca <strnlen+0x10>
	return n;
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	53                   	push   %ebx
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e3:	89 c2                	mov    %eax,%edx
  8008e5:	83 c1 01             	add    $0x1,%ecx
  8008e8:	83 c2 01             	add    $0x1,%edx
  8008eb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ef:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	75 ef                	jne    8008e5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	53                   	push   %ebx
  8008fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800900:	53                   	push   %ebx
  800901:	e8 9c ff ff ff       	call   8008a2 <strlen>
  800906:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800909:	ff 75 0c             	pushl  0xc(%ebp)
  80090c:	01 d8                	add    %ebx,%eax
  80090e:	50                   	push   %eax
  80090f:	e8 c5 ff ff ff       	call   8008d9 <strcpy>
	return dst;
}
  800914:	89 d8                	mov    %ebx,%eax
  800916:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800919:	c9                   	leave  
  80091a:	c3                   	ret    

0080091b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 75 08             	mov    0x8(%ebp),%esi
  800923:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800926:	89 f3                	mov    %esi,%ebx
  800928:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092b:	89 f2                	mov    %esi,%edx
  80092d:	eb 0f                	jmp    80093e <strncpy+0x23>
		*dst++ = *src;
  80092f:	83 c2 01             	add    $0x1,%edx
  800932:	0f b6 01             	movzbl (%ecx),%eax
  800935:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800938:	80 39 01             	cmpb   $0x1,(%ecx)
  80093b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80093e:	39 da                	cmp    %ebx,%edx
  800940:	75 ed                	jne    80092f <strncpy+0x14>
	}
	return ret;
}
  800942:	89 f0                	mov    %esi,%eax
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 75 08             	mov    0x8(%ebp),%esi
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800956:	89 f0                	mov    %esi,%eax
  800958:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095c:	85 c9                	test   %ecx,%ecx
  80095e:	75 0b                	jne    80096b <strlcpy+0x23>
  800960:	eb 17                	jmp    800979 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800962:	83 c2 01             	add    $0x1,%edx
  800965:	83 c0 01             	add    $0x1,%eax
  800968:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80096b:	39 d8                	cmp    %ebx,%eax
  80096d:	74 07                	je     800976 <strlcpy+0x2e>
  80096f:	0f b6 0a             	movzbl (%edx),%ecx
  800972:	84 c9                	test   %cl,%cl
  800974:	75 ec                	jne    800962 <strlcpy+0x1a>
		*dst = '\0';
  800976:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800979:	29 f0                	sub    %esi,%eax
}
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800985:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800988:	eb 06                	jmp    800990 <strcmp+0x11>
		p++, q++;
  80098a:	83 c1 01             	add    $0x1,%ecx
  80098d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800990:	0f b6 01             	movzbl (%ecx),%eax
  800993:	84 c0                	test   %al,%al
  800995:	74 04                	je     80099b <strcmp+0x1c>
  800997:	3a 02                	cmp    (%edx),%al
  800999:	74 ef                	je     80098a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80099b:	0f b6 c0             	movzbl %al,%eax
  80099e:	0f b6 12             	movzbl (%edx),%edx
  8009a1:	29 d0                	sub    %edx,%eax
}
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	89 c3                	mov    %eax,%ebx
  8009b1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b4:	eb 06                	jmp    8009bc <strncmp+0x17>
		n--, p++, q++;
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009bc:	39 d8                	cmp    %ebx,%eax
  8009be:	74 16                	je     8009d6 <strncmp+0x31>
  8009c0:	0f b6 08             	movzbl (%eax),%ecx
  8009c3:	84 c9                	test   %cl,%cl
  8009c5:	74 04                	je     8009cb <strncmp+0x26>
  8009c7:	3a 0a                	cmp    (%edx),%cl
  8009c9:	74 eb                	je     8009b6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cb:	0f b6 00             	movzbl (%eax),%eax
  8009ce:	0f b6 12             	movzbl (%edx),%edx
  8009d1:	29 d0                	sub    %edx,%eax
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    
		return 0;
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	eb f6                	jmp    8009d3 <strncmp+0x2e>

008009dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e7:	0f b6 10             	movzbl (%eax),%edx
  8009ea:	84 d2                	test   %dl,%dl
  8009ec:	74 09                	je     8009f7 <strchr+0x1a>
		if (*s == c)
  8009ee:	38 ca                	cmp    %cl,%dl
  8009f0:	74 0a                	je     8009fc <strchr+0x1f>
	for (; *s; s++)
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	eb f0                	jmp    8009e7 <strchr+0xa>
			return (char *) s;
	return 0;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a08:	eb 03                	jmp    800a0d <strfind+0xf>
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a10:	38 ca                	cmp    %cl,%dl
  800a12:	74 04                	je     800a18 <strfind+0x1a>
  800a14:	84 d2                	test   %dl,%dl
  800a16:	75 f2                	jne    800a0a <strfind+0xc>
			break;
	return (char *) s;
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	57                   	push   %edi
  800a1e:	56                   	push   %esi
  800a1f:	53                   	push   %ebx
  800a20:	8b 55 08             	mov    0x8(%ebp),%edx
  800a23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a26:	85 c9                	test   %ecx,%ecx
  800a28:	74 12                	je     800a3c <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2a:	f6 c2 03             	test   $0x3,%dl
  800a2d:	75 05                	jne    800a34 <memset+0x1a>
  800a2f:	f6 c1 03             	test   $0x3,%cl
  800a32:	74 0f                	je     800a43 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a34:	89 d7                	mov    %edx,%edi
  800a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a39:	fc                   	cld    
  800a3a:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a3c:	89 d0                	mov    %edx,%eax
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    
		c &= 0xFF;
  800a43:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a47:	89 d8                	mov    %ebx,%eax
  800a49:	c1 e0 08             	shl    $0x8,%eax
  800a4c:	89 df                	mov    %ebx,%edi
  800a4e:	c1 e7 18             	shl    $0x18,%edi
  800a51:	89 de                	mov    %ebx,%esi
  800a53:	c1 e6 10             	shl    $0x10,%esi
  800a56:	09 f7                	or     %esi,%edi
  800a58:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800a5a:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a5f:	89 d7                	mov    %edx,%edi
  800a61:	fc                   	cld    
  800a62:	f3 ab                	rep stos %eax,%es:(%edi)
  800a64:	eb d6                	jmp    800a3c <memset+0x22>

00800a66 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a71:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a74:	39 c6                	cmp    %eax,%esi
  800a76:	73 35                	jae    800aad <memmove+0x47>
  800a78:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7b:	39 c2                	cmp    %eax,%edx
  800a7d:	76 2e                	jbe    800aad <memmove+0x47>
		s += n;
		d += n;
  800a7f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a82:	89 d6                	mov    %edx,%esi
  800a84:	09 fe                	or     %edi,%esi
  800a86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8c:	74 0c                	je     800a9a <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a8e:	83 ef 01             	sub    $0x1,%edi
  800a91:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a94:	fd                   	std    
  800a95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a97:	fc                   	cld    
  800a98:	eb 21                	jmp    800abb <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9a:	f6 c1 03             	test   $0x3,%cl
  800a9d:	75 ef                	jne    800a8e <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a9f:	83 ef 04             	sub    $0x4,%edi
  800aa2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aa8:	fd                   	std    
  800aa9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aab:	eb ea                	jmp    800a97 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aad:	89 f2                	mov    %esi,%edx
  800aaf:	09 c2                	or     %eax,%edx
  800ab1:	f6 c2 03             	test   $0x3,%dl
  800ab4:	74 09                	je     800abf <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab6:	89 c7                	mov    %eax,%edi
  800ab8:	fc                   	cld    
  800ab9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abf:	f6 c1 03             	test   $0x3,%cl
  800ac2:	75 f2                	jne    800ab6 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ac7:	89 c7                	mov    %eax,%edi
  800ac9:	fc                   	cld    
  800aca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acc:	eb ed                	jmp    800abb <memmove+0x55>

00800ace <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ad1:	ff 75 10             	pushl  0x10(%ebp)
  800ad4:	ff 75 0c             	pushl  0xc(%ebp)
  800ad7:	ff 75 08             	pushl  0x8(%ebp)
  800ada:	e8 87 ff ff ff       	call   800a66 <memmove>
}
  800adf:	c9                   	leave  
  800ae0:	c3                   	ret    

00800ae1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aec:	89 c6                	mov    %eax,%esi
  800aee:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af1:	39 f0                	cmp    %esi,%eax
  800af3:	74 1c                	je     800b11 <memcmp+0x30>
		if (*s1 != *s2)
  800af5:	0f b6 08             	movzbl (%eax),%ecx
  800af8:	0f b6 1a             	movzbl (%edx),%ebx
  800afb:	38 d9                	cmp    %bl,%cl
  800afd:	75 08                	jne    800b07 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	83 c2 01             	add    $0x1,%edx
  800b05:	eb ea                	jmp    800af1 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b07:	0f b6 c1             	movzbl %cl,%eax
  800b0a:	0f b6 db             	movzbl %bl,%ebx
  800b0d:	29 d8                	sub    %ebx,%eax
  800b0f:	eb 05                	jmp    800b16 <memcmp+0x35>
	}

	return 0;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b28:	39 d0                	cmp    %edx,%eax
  800b2a:	73 09                	jae    800b35 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b2c:	38 08                	cmp    %cl,(%eax)
  800b2e:	74 05                	je     800b35 <memfind+0x1b>
	for (; s < ends; s++)
  800b30:	83 c0 01             	add    $0x1,%eax
  800b33:	eb f3                	jmp    800b28 <memfind+0xe>
			break;
	return (void *) s;
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b43:	eb 03                	jmp    800b48 <strtol+0x11>
		s++;
  800b45:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b48:	0f b6 01             	movzbl (%ecx),%eax
  800b4b:	3c 20                	cmp    $0x20,%al
  800b4d:	74 f6                	je     800b45 <strtol+0xe>
  800b4f:	3c 09                	cmp    $0x9,%al
  800b51:	74 f2                	je     800b45 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b53:	3c 2b                	cmp    $0x2b,%al
  800b55:	74 2e                	je     800b85 <strtol+0x4e>
	int neg = 0;
  800b57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b5c:	3c 2d                	cmp    $0x2d,%al
  800b5e:	74 2f                	je     800b8f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b60:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b66:	75 05                	jne    800b6d <strtol+0x36>
  800b68:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6b:	74 2c                	je     800b99 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6d:	85 db                	test   %ebx,%ebx
  800b6f:	75 0a                	jne    800b7b <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b71:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b76:	80 39 30             	cmpb   $0x30,(%ecx)
  800b79:	74 28                	je     800ba3 <strtol+0x6c>
		base = 10;
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b80:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b83:	eb 50                	jmp    800bd5 <strtol+0x9e>
		s++;
  800b85:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b88:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8d:	eb d1                	jmp    800b60 <strtol+0x29>
		s++, neg = 1;
  800b8f:	83 c1 01             	add    $0x1,%ecx
  800b92:	bf 01 00 00 00       	mov    $0x1,%edi
  800b97:	eb c7                	jmp    800b60 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b99:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b9d:	74 0e                	je     800bad <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b9f:	85 db                	test   %ebx,%ebx
  800ba1:	75 d8                	jne    800b7b <strtol+0x44>
		s++, base = 8;
  800ba3:	83 c1 01             	add    $0x1,%ecx
  800ba6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bab:	eb ce                	jmp    800b7b <strtol+0x44>
		s += 2, base = 16;
  800bad:	83 c1 02             	add    $0x2,%ecx
  800bb0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb5:	eb c4                	jmp    800b7b <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bb7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bba:	89 f3                	mov    %esi,%ebx
  800bbc:	80 fb 19             	cmp    $0x19,%bl
  800bbf:	77 29                	ja     800bea <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bc1:	0f be d2             	movsbl %dl,%edx
  800bc4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bca:	7d 30                	jge    800bfc <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bcc:	83 c1 01             	add    $0x1,%ecx
  800bcf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bd5:	0f b6 11             	movzbl (%ecx),%edx
  800bd8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdb:	89 f3                	mov    %esi,%ebx
  800bdd:	80 fb 09             	cmp    $0x9,%bl
  800be0:	77 d5                	ja     800bb7 <strtol+0x80>
			dig = *s - '0';
  800be2:	0f be d2             	movsbl %dl,%edx
  800be5:	83 ea 30             	sub    $0x30,%edx
  800be8:	eb dd                	jmp    800bc7 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bea:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bed:	89 f3                	mov    %esi,%ebx
  800bef:	80 fb 19             	cmp    $0x19,%bl
  800bf2:	77 08                	ja     800bfc <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bf4:	0f be d2             	movsbl %dl,%edx
  800bf7:	83 ea 37             	sub    $0x37,%edx
  800bfa:	eb cb                	jmp    800bc7 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c00:	74 05                	je     800c07 <strtol+0xd0>
		*endptr = (char *) s;
  800c02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c05:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c07:	89 c2                	mov    %eax,%edx
  800c09:	f7 da                	neg    %edx
  800c0b:	85 ff                	test   %edi,%edi
  800c0d:	0f 45 c2             	cmovne %edx,%eax
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    
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
