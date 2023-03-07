
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800045:	e8 02 01 00 00       	call   80014c <sys_getenvid>
	if (id >= 0)
  80004a:	85 c0                	test   %eax,%eax
  80004c:	78 12                	js     800060 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	c1 e0 07             	shl    $0x7,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x31>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 99 00 00 00       	call   80012a <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	83 ec 1c             	sub    $0x1c,%esp
  80009f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000a2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000a5:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ad:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000b0:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000b9:	74 04                	je     8000bf <syscall+0x29>
  8000bb:	85 c0                	test   %eax,%eax
  8000bd:	7f 08                	jg     8000c7 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
  8000c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ca:	83 ec 0c             	sub    $0xc,%esp
  8000cd:	50                   	push   %eax
  8000ce:	52                   	push   %edx
  8000cf:	68 6a 0e 80 00       	push   $0x800e6a
  8000d4:	6a 23                	push   $0x23
  8000d6:	68 87 0e 80 00       	push   $0x800e87
  8000db:	e8 b1 01 00 00       	call   800291 <_panic>

008000e0 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	6a 00                	push   $0x0
  8000ea:	6a 00                	push   $0x0
  8000ec:	ff 75 0c             	pushl  0xc(%ebp)
  8000ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fc:	e8 95 ff ff ff       	call   800096 <syscall>
}
  800101:	83 c4 10             	add    $0x10,%esp
  800104:	c9                   	leave  
  800105:	c3                   	ret    

00800106 <sys_cgetc>:

int
sys_cgetc(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80010c:	6a 00                	push   $0x0
  80010e:	6a 00                	push   $0x0
  800110:	6a 00                	push   $0x0
  800112:	6a 00                	push   $0x0
  800114:	b9 00 00 00 00       	mov    $0x0,%ecx
  800119:	ba 00 00 00 00       	mov    $0x0,%edx
  80011e:	b8 01 00 00 00       	mov    $0x1,%eax
  800123:	e8 6e ff ff ff       	call   800096 <syscall>
}
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800130:	6a 00                	push   $0x0
  800132:	6a 00                	push   $0x0
  800134:	6a 00                	push   $0x0
  800136:	6a 00                	push   $0x0
  800138:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013b:	ba 01 00 00 00       	mov    $0x1,%edx
  800140:	b8 03 00 00 00       	mov    $0x3,%eax
  800145:	e8 4c ff ff ff       	call   800096 <syscall>
}
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800152:	6a 00                	push   $0x0
  800154:	6a 00                	push   $0x0
  800156:	6a 00                	push   $0x0
  800158:	6a 00                	push   $0x0
  80015a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	b8 02 00 00 00       	mov    $0x2,%eax
  800169:	e8 28 ff ff ff       	call   800096 <syscall>
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <sys_yield>:

void
sys_yield(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800176:	6a 00                	push   $0x0
  800178:	6a 00                	push   $0x0
  80017a:	6a 00                	push   $0x0
  80017c:	6a 00                	push   $0x0
  80017e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800183:	ba 00 00 00 00       	mov    $0x0,%edx
  800188:	b8 0a 00 00 00       	mov    $0xa,%eax
  80018d:	e8 04 ff ff ff       	call   800096 <syscall>
}
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80019d:	6a 00                	push   $0x0
  80019f:	6a 00                	push   $0x0
  8001a1:	ff 75 10             	pushl  0x10(%ebp)
  8001a4:	ff 75 0c             	pushl  0xc(%ebp)
  8001a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001aa:	ba 01 00 00 00       	mov    $0x1,%edx
  8001af:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b4:	e8 dd fe ff ff       	call   800096 <syscall>
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001c1:	ff 75 18             	pushl  0x18(%ebp)
  8001c4:	ff 75 14             	pushl  0x14(%ebp)
  8001c7:	ff 75 10             	pushl  0x10(%ebp)
  8001ca:	ff 75 0c             	pushl  0xc(%ebp)
  8001cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d0:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001da:	e8 b7 fe ff ff       	call   800096 <syscall>
}
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001e7:	6a 00                	push   $0x0
  8001e9:	6a 00                	push   $0x0
  8001eb:	6a 00                	push   $0x0
  8001ed:	ff 75 0c             	pushl  0xc(%ebp)
  8001f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f3:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fd:	e8 94 fe ff ff       	call   800096 <syscall>
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80020a:	6a 00                	push   $0x0
  80020c:	6a 00                	push   $0x0
  80020e:	6a 00                	push   $0x0
  800210:	ff 75 0c             	pushl  0xc(%ebp)
  800213:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800216:	ba 01 00 00 00       	mov    $0x1,%edx
  80021b:	b8 08 00 00 00       	mov    $0x8,%eax
  800220:	e8 71 fe ff ff       	call   800096 <syscall>
}
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80022d:	6a 00                	push   $0x0
  80022f:	6a 00                	push   $0x0
  800231:	6a 00                	push   $0x0
  800233:	ff 75 0c             	pushl  0xc(%ebp)
  800236:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800239:	ba 01 00 00 00       	mov    $0x1,%edx
  80023e:	b8 09 00 00 00       	mov    $0x9,%eax
  800243:	e8 4e fe ff ff       	call   800096 <syscall>
}
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800250:	6a 00                	push   $0x0
  800252:	ff 75 14             	pushl  0x14(%ebp)
  800255:	ff 75 10             	pushl  0x10(%ebp)
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025e:	ba 00 00 00 00       	mov    $0x0,%edx
  800263:	b8 0b 00 00 00       	mov    $0xb,%eax
  800268:	e8 29 fe ff ff       	call   800096 <syscall>
}
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800275:	6a 00                	push   $0x0
  800277:	6a 00                	push   $0x0
  800279:	6a 00                	push   $0x0
  80027b:	6a 00                	push   $0x0
  80027d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800280:	ba 01 00 00 00       	mov    $0x1,%edx
  800285:	b8 0c 00 00 00       	mov    $0xc,%eax
  80028a:	e8 07 fe ff ff       	call   800096 <syscall>
}
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800296:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800299:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80029f:	e8 a8 fe ff ff       	call   80014c <sys_getenvid>
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	ff 75 0c             	pushl  0xc(%ebp)
  8002aa:	ff 75 08             	pushl  0x8(%ebp)
  8002ad:	56                   	push   %esi
  8002ae:	50                   	push   %eax
  8002af:	68 98 0e 80 00       	push   $0x800e98
  8002b4:	e8 b3 00 00 00       	call   80036c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002b9:	83 c4 18             	add    $0x18,%esp
  8002bc:	53                   	push   %ebx
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	e8 56 00 00 00       	call   80031b <vcprintf>
	cprintf("\n");
  8002c5:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  8002cc:	e8 9b 00 00 00       	call   80036c <cprintf>
  8002d1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d4:	cc                   	int3   
  8002d5:	eb fd                	jmp    8002d4 <_panic+0x43>

008002d7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	53                   	push   %ebx
  8002db:	83 ec 04             	sub    $0x4,%esp
  8002de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e1:	8b 13                	mov    (%ebx),%edx
  8002e3:	8d 42 01             	lea    0x1(%edx),%eax
  8002e6:	89 03                	mov    %eax,(%ebx)
  8002e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002eb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f4:	74 09                	je     8002ff <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002f6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	68 ff 00 00 00       	push   $0xff
  800307:	8d 43 08             	lea    0x8(%ebx),%eax
  80030a:	50                   	push   %eax
  80030b:	e8 d0 fd ff ff       	call   8000e0 <sys_cputs>
		b->idx = 0;
  800310:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800316:	83 c4 10             	add    $0x10,%esp
  800319:	eb db                	jmp    8002f6 <putch+0x1f>

0080031b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800324:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032b:	00 00 00 
	b.cnt = 0;
  80032e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800335:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	ff 75 08             	pushl  0x8(%ebp)
  80033e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800344:	50                   	push   %eax
  800345:	68 d7 02 80 00       	push   $0x8002d7
  80034a:	e8 86 01 00 00       	call   8004d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80034f:	83 c4 08             	add    $0x8,%esp
  800352:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800358:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80035e:	50                   	push   %eax
  80035f:	e8 7c fd ff ff       	call   8000e0 <sys_cputs>

	return b.cnt;
}
  800364:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800372:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800375:	50                   	push   %eax
  800376:	ff 75 08             	pushl  0x8(%ebp)
  800379:	e8 9d ff ff ff       	call   80031b <vcprintf>
	va_end(ap);

	return cnt;
}
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
  800386:	83 ec 1c             	sub    $0x1c,%esp
  800389:	89 c7                	mov    %eax,%edi
  80038b:	89 d6                	mov    %edx,%esi
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	8b 55 0c             	mov    0xc(%ebp),%edx
  800393:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800396:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800399:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80039c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003a7:	39 d3                	cmp    %edx,%ebx
  8003a9:	72 05                	jb     8003b0 <printnum+0x30>
  8003ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ae:	77 7a                	ja     80042a <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b0:	83 ec 0c             	sub    $0xc,%esp
  8003b3:	ff 75 18             	pushl  0x18(%ebp)
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003bc:	53                   	push   %ebx
  8003bd:	ff 75 10             	pushl  0x10(%ebp)
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8003cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cf:	e8 3c 08 00 00       	call   800c10 <__udivdi3>
  8003d4:	83 c4 18             	add    $0x18,%esp
  8003d7:	52                   	push   %edx
  8003d8:	50                   	push   %eax
  8003d9:	89 f2                	mov    %esi,%edx
  8003db:	89 f8                	mov    %edi,%eax
  8003dd:	e8 9e ff ff ff       	call   800380 <printnum>
  8003e2:	83 c4 20             	add    $0x20,%esp
  8003e5:	eb 13                	jmp    8003fa <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	56                   	push   %esi
  8003eb:	ff 75 18             	pushl  0x18(%ebp)
  8003ee:	ff d7                	call   *%edi
  8003f0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003f3:	83 eb 01             	sub    $0x1,%ebx
  8003f6:	85 db                	test   %ebx,%ebx
  8003f8:	7f ed                	jg     8003e7 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	56                   	push   %esi
  8003fe:	83 ec 04             	sub    $0x4,%esp
  800401:	ff 75 e4             	pushl  -0x1c(%ebp)
  800404:	ff 75 e0             	pushl  -0x20(%ebp)
  800407:	ff 75 dc             	pushl  -0x24(%ebp)
  80040a:	ff 75 d8             	pushl  -0x28(%ebp)
  80040d:	e8 1e 09 00 00       	call   800d30 <__umoddi3>
  800412:	83 c4 14             	add    $0x14,%esp
  800415:	0f be 80 be 0e 80 00 	movsbl 0x800ebe(%eax),%eax
  80041c:	50                   	push   %eax
  80041d:	ff d7                	call   *%edi
}
  80041f:	83 c4 10             	add    $0x10,%esp
  800422:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800425:	5b                   	pop    %ebx
  800426:	5e                   	pop    %esi
  800427:	5f                   	pop    %edi
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    
  80042a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80042d:	eb c4                	jmp    8003f3 <printnum+0x73>

0080042f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800432:	83 fa 01             	cmp    $0x1,%edx
  800435:	7e 0e                	jle    800445 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800437:	8b 10                	mov    (%eax),%edx
  800439:	8d 4a 08             	lea    0x8(%edx),%ecx
  80043c:	89 08                	mov    %ecx,(%eax)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    
	else if (lflag)
  800445:	85 d2                	test   %edx,%edx
  800447:	75 10                	jne    800459 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 02                	mov    (%edx),%eax
  800452:	ba 00 00 00 00       	mov    $0x0,%edx
  800457:	eb ea                	jmp    800443 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800459:	8b 10                	mov    (%eax),%edx
  80045b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045e:	89 08                	mov    %ecx,(%eax)
  800460:	8b 02                	mov    (%edx),%eax
  800462:	ba 00 00 00 00       	mov    $0x0,%edx
  800467:	eb da                	jmp    800443 <getuint+0x14>

00800469 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046c:	83 fa 01             	cmp    $0x1,%edx
  80046f:	7e 0e                	jle    80047f <getint+0x16>
		return va_arg(*ap, long long);
  800471:	8b 10                	mov    (%eax),%edx
  800473:	8d 4a 08             	lea    0x8(%edx),%ecx
  800476:	89 08                	mov    %ecx,(%eax)
  800478:	8b 02                	mov    (%edx),%eax
  80047a:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  80047d:	5d                   	pop    %ebp
  80047e:	c3                   	ret    
	else if (lflag)
  80047f:	85 d2                	test   %edx,%edx
  800481:	75 0c                	jne    80048f <getint+0x26>
		return va_arg(*ap, int);
  800483:	8b 10                	mov    (%eax),%edx
  800485:	8d 4a 04             	lea    0x4(%edx),%ecx
  800488:	89 08                	mov    %ecx,(%eax)
  80048a:	8b 02                	mov    (%edx),%eax
  80048c:	99                   	cltd   
  80048d:	eb ee                	jmp    80047d <getint+0x14>
		return va_arg(*ap, long);
  80048f:	8b 10                	mov    (%eax),%edx
  800491:	8d 4a 04             	lea    0x4(%edx),%ecx
  800494:	89 08                	mov    %ecx,(%eax)
  800496:	8b 02                	mov    (%edx),%eax
  800498:	99                   	cltd   
  800499:	eb e2                	jmp    80047d <getint+0x14>

0080049b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049b:	55                   	push   %ebp
  80049c:	89 e5                	mov    %esp,%ebp
  80049e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004aa:	73 0a                	jae    8004b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b4:	88 02                	mov    %al,(%edx)
}
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <printfmt>:
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c1:	50                   	push   %eax
  8004c2:	ff 75 10             	pushl  0x10(%ebp)
  8004c5:	ff 75 0c             	pushl  0xc(%ebp)
  8004c8:	ff 75 08             	pushl  0x8(%ebp)
  8004cb:	e8 05 00 00 00       	call   8004d5 <vprintfmt>
}
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	c9                   	leave  
  8004d4:	c3                   	ret    

008004d5 <vprintfmt>:
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	57                   	push   %edi
  8004d9:	56                   	push   %esi
  8004da:	53                   	push   %ebx
  8004db:	83 ec 2c             	sub    $0x2c,%esp
  8004de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004e4:	89 f7                	mov    %esi,%edi
  8004e6:	89 de                	mov    %ebx,%esi
  8004e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004eb:	e9 9e 02 00 00       	jmp    80078e <vprintfmt+0x2b9>
		padc = ' ';
  8004f0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8004fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800502:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800509:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8d 43 01             	lea    0x1(%ebx),%eax
  800511:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800514:	0f b6 0b             	movzbl (%ebx),%ecx
  800517:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80051a:	3c 55                	cmp    $0x55,%al
  80051c:	0f 87 e8 02 00 00    	ja     80080a <vprintfmt+0x335>
  800522:	0f b6 c0             	movzbl %al,%eax
  800525:	ff 24 85 80 0f 80 00 	jmp    *0x800f80(,%eax,4)
  80052c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80052f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800533:	eb d9                	jmp    80050e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800538:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80053c:	eb d0                	jmp    80050e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	0f b6 c9             	movzbl %cl,%ecx
  800541:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800544:	b8 00 00 00 00       	mov    $0x0,%eax
  800549:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80054c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80054f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800553:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800556:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800559:	83 fa 09             	cmp    $0x9,%edx
  80055c:	77 52                	ja     8005b0 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  80055e:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800561:	eb e9                	jmp    80054c <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 48 04             	lea    0x4(%eax),%ecx
  800569:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800574:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800578:	79 94                	jns    80050e <vprintfmt+0x39>
				width = precision, precision = -1;
  80057a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80057d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800580:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800587:	eb 85                	jmp    80050e <vprintfmt+0x39>
  800589:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058c:	85 c0                	test   %eax,%eax
  80058e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800593:	0f 49 c8             	cmovns %eax,%ecx
  800596:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800599:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80059c:	e9 6d ff ff ff       	jmp    80050e <vprintfmt+0x39>
  8005a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8005a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ab:	e9 5e ff ff ff       	jmp    80050e <vprintfmt+0x39>
  8005b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005b6:	eb bc                	jmp    800574 <vprintfmt+0x9f>
			lflag++;
  8005b8:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8005be:	e9 4b ff ff ff       	jmp    80050e <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 04             	lea    0x4(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	57                   	push   %edi
  8005d0:	ff 30                	pushl  (%eax)
  8005d2:	ff d6                	call   *%esi
			break;
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	e9 af 01 00 00       	jmp    80078b <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	99                   	cltd   
  8005e8:	31 d0                	xor    %edx,%eax
  8005ea:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ec:	83 f8 08             	cmp    $0x8,%eax
  8005ef:	7f 20                	jg     800611 <vprintfmt+0x13c>
  8005f1:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  8005f8:	85 d2                	test   %edx,%edx
  8005fa:	74 15                	je     800611 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  8005fc:	52                   	push   %edx
  8005fd:	68 df 0e 80 00       	push   $0x800edf
  800602:	57                   	push   %edi
  800603:	56                   	push   %esi
  800604:	e8 af fe ff ff       	call   8004b8 <printfmt>
  800609:	83 c4 10             	add    $0x10,%esp
  80060c:	e9 7a 01 00 00       	jmp    80078b <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800611:	50                   	push   %eax
  800612:	68 d6 0e 80 00       	push   $0x800ed6
  800617:	57                   	push   %edi
  800618:	56                   	push   %esi
  800619:	e8 9a fe ff ff       	call   8004b8 <printfmt>
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	e9 65 01 00 00       	jmp    80078b <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800631:	85 db                	test   %ebx,%ebx
  800633:	b8 cf 0e 80 00       	mov    $0x800ecf,%eax
  800638:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  80063b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80063f:	0f 8e bd 00 00 00    	jle    800702 <vprintfmt+0x22d>
  800645:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800649:	75 0e                	jne    800659 <vprintfmt+0x184>
  80064b:	89 75 08             	mov    %esi,0x8(%ebp)
  80064e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800651:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800654:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800657:	eb 6d                	jmp    8006c6 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 d0             	pushl  -0x30(%ebp)
  80065f:	53                   	push   %ebx
  800660:	e8 4d 02 00 00       	call   8008b2 <strnlen>
  800665:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800668:	29 c1                	sub    %eax,%ecx
  80066a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80066d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800670:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800674:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800677:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80067a:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80067c:	eb 0f                	jmp    80068d <vprintfmt+0x1b8>
					putch(padc, putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	57                   	push   %edi
  800682:	ff 75 e0             	pushl  -0x20(%ebp)
  800685:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800687:	83 eb 01             	sub    $0x1,%ebx
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	85 db                	test   %ebx,%ebx
  80068f:	7f ed                	jg     80067e <vprintfmt+0x1a9>
  800691:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800694:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800697:	85 c9                	test   %ecx,%ecx
  800699:	b8 00 00 00 00       	mov    $0x0,%eax
  80069e:	0f 49 c1             	cmovns %ecx,%eax
  8006a1:	29 c1                	sub    %eax,%ecx
  8006a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a9:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006ac:	89 cf                	mov    %ecx,%edi
  8006ae:	eb 16                	jmp    8006c6 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8006b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006b4:	75 31                	jne    8006e7 <vprintfmt+0x212>
					putch(ch, putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	ff 75 0c             	pushl  0xc(%ebp)
  8006bc:	50                   	push   %eax
  8006bd:	ff 55 08             	call   *0x8(%ebp)
  8006c0:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c3:	83 ef 01             	sub    $0x1,%edi
  8006c6:	83 c3 01             	add    $0x1,%ebx
  8006c9:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8006cd:	0f be c2             	movsbl %dl,%eax
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 50                	je     800724 <vprintfmt+0x24f>
  8006d4:	85 f6                	test   %esi,%esi
  8006d6:	78 d8                	js     8006b0 <vprintfmt+0x1db>
  8006d8:	83 ee 01             	sub    $0x1,%esi
  8006db:	79 d3                	jns    8006b0 <vprintfmt+0x1db>
  8006dd:	89 fb                	mov    %edi,%ebx
  8006df:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006e5:	eb 37                	jmp    80071e <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8006e7:	0f be d2             	movsbl %dl,%edx
  8006ea:	83 ea 20             	sub    $0x20,%edx
  8006ed:	83 fa 5e             	cmp    $0x5e,%edx
  8006f0:	76 c4                	jbe    8006b6 <vprintfmt+0x1e1>
					putch('?', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	6a 3f                	push   $0x3f
  8006fa:	ff 55 08             	call   *0x8(%ebp)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	eb c1                	jmp    8006c3 <vprintfmt+0x1ee>
  800702:	89 75 08             	mov    %esi,0x8(%ebp)
  800705:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800708:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80070b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80070e:	eb b6                	jmp    8006c6 <vprintfmt+0x1f1>
				putch(' ', putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	57                   	push   %edi
  800714:	6a 20                	push   $0x20
  800716:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800718:	83 eb 01             	sub    $0x1,%ebx
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	85 db                	test   %ebx,%ebx
  800720:	7f ee                	jg     800710 <vprintfmt+0x23b>
  800722:	eb 67                	jmp    80078b <vprintfmt+0x2b6>
  800724:	89 fb                	mov    %edi,%ebx
  800726:	8b 75 08             	mov    0x8(%ebp),%esi
  800729:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80072c:	eb f0                	jmp    80071e <vprintfmt+0x249>
			num = getint(&ap, lflag);
  80072e:	8d 45 14             	lea    0x14(%ebp),%eax
  800731:	e8 33 fd ff ff       	call   800469 <getint>
  800736:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800739:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80073c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800741:	85 d2                	test   %edx,%edx
  800743:	79 2c                	jns    800771 <vprintfmt+0x29c>
				putch('-', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	57                   	push   %edi
  800749:	6a 2d                	push   $0x2d
  80074b:	ff d6                	call   *%esi
				num = -(long long) num;
  80074d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800750:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800753:	f7 d8                	neg    %eax
  800755:	83 d2 00             	adc    $0x0,%edx
  800758:	f7 da                	neg    %edx
  80075a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80075d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800762:	eb 0d                	jmp    800771 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
  800767:	e8 c3 fc ff ff       	call   80042f <getuint>
			base = 10;
  80076c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800771:	83 ec 0c             	sub    $0xc,%esp
  800774:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  800778:	53                   	push   %ebx
  800779:	ff 75 e0             	pushl  -0x20(%ebp)
  80077c:	51                   	push   %ecx
  80077d:	52                   	push   %edx
  80077e:	50                   	push   %eax
  80077f:	89 fa                	mov    %edi,%edx
  800781:	89 f0                	mov    %esi,%eax
  800783:	e8 f8 fb ff ff       	call   800380 <printnum>
			break;
  800788:	83 c4 20             	add    $0x20,%esp
{
  80078b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078e:	83 c3 01             	add    $0x1,%ebx
  800791:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800795:	83 f8 25             	cmp    $0x25,%eax
  800798:	0f 84 52 fd ff ff    	je     8004f0 <vprintfmt+0x1b>
			if (ch == '\0')
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	0f 84 84 00 00 00    	je     80082a <vprintfmt+0x355>
			putch(ch, putdat);
  8007a6:	83 ec 08             	sub    $0x8,%esp
  8007a9:	57                   	push   %edi
  8007aa:	50                   	push   %eax
  8007ab:	ff d6                	call   *%esi
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	eb dc                	jmp    80078e <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b5:	e8 75 fc ff ff       	call   80042f <getuint>
			base = 8;
  8007ba:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007bf:	eb b0                	jmp    800771 <vprintfmt+0x29c>
			putch('0', putdat);
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	57                   	push   %edi
  8007c5:	6a 30                	push   $0x30
  8007c7:	ff d6                	call   *%esi
			putch('x', putdat);
  8007c9:	83 c4 08             	add    $0x8,%esp
  8007cc:	57                   	push   %edi
  8007cd:	6a 78                	push   $0x78
  8007cf:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 50 04             	lea    0x4(%eax),%edx
  8007d7:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007da:	8b 00                	mov    (%eax),%eax
  8007dc:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8007e1:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007e4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007e9:	eb 86                	jmp    800771 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8007eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ee:	e8 3c fc ff ff       	call   80042f <getuint>
			base = 16;
  8007f3:	b9 10 00 00 00       	mov    $0x10,%ecx
  8007f8:	e9 74 ff ff ff       	jmp    800771 <vprintfmt+0x29c>
			putch(ch, putdat);
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	57                   	push   %edi
  800801:	6a 25                	push   $0x25
  800803:	ff d6                	call   *%esi
			break;
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	eb 81                	jmp    80078b <vprintfmt+0x2b6>
			putch('%', putdat);
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	57                   	push   %edi
  80080e:	6a 25                	push   $0x25
  800810:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	89 d8                	mov    %ebx,%eax
  800817:	eb 03                	jmp    80081c <vprintfmt+0x347>
  800819:	83 e8 01             	sub    $0x1,%eax
  80081c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800820:	75 f7                	jne    800819 <vprintfmt+0x344>
  800822:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800825:	e9 61 ff ff ff       	jmp    80078b <vprintfmt+0x2b6>
}
  80082a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	5f                   	pop    %edi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	83 ec 18             	sub    $0x18,%esp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80083e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800841:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800845:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800848:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80084f:	85 c0                	test   %eax,%eax
  800851:	74 26                	je     800879 <vsnprintf+0x47>
  800853:	85 d2                	test   %edx,%edx
  800855:	7e 22                	jle    800879 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800857:	ff 75 14             	pushl  0x14(%ebp)
  80085a:	ff 75 10             	pushl  0x10(%ebp)
  80085d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	68 9b 04 80 00       	push   $0x80049b
  800866:	e8 6a fc ff ff       	call   8004d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80086b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80086e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800874:	83 c4 10             	add    $0x10,%esp
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    
		return -E_INVAL;
  800879:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087e:	eb f7                	jmp    800877 <vsnprintf+0x45>

00800880 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800886:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800889:	50                   	push   %eax
  80088a:	ff 75 10             	pushl  0x10(%ebp)
  80088d:	ff 75 0c             	pushl  0xc(%ebp)
  800890:	ff 75 08             	pushl  0x8(%ebp)
  800893:	e8 9a ff ff ff       	call   800832 <vsnprintf>
	va_end(ap);

	return rc;
}
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a5:	eb 03                	jmp    8008aa <strlen+0x10>
		n++;
  8008a7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ae:	75 f7                	jne    8008a7 <strlen+0xd>
	return n;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c0:	eb 03                	jmp    8008c5 <strnlen+0x13>
		n++;
  8008c2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	39 d0                	cmp    %edx,%eax
  8008c7:	74 06                	je     8008cf <strnlen+0x1d>
  8008c9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cd:	75 f3                	jne    8008c2 <strnlen+0x10>
	return n;
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	53                   	push   %ebx
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008db:	89 c2                	mov    %eax,%edx
  8008dd:	83 c1 01             	add    $0x1,%ecx
  8008e0:	83 c2 01             	add    $0x1,%edx
  8008e3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008e7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ea:	84 db                	test   %bl,%bl
  8008ec:	75 ef                	jne    8008dd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f8:	53                   	push   %ebx
  8008f9:	e8 9c ff ff ff       	call   80089a <strlen>
  8008fe:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800901:	ff 75 0c             	pushl  0xc(%ebp)
  800904:	01 d8                	add    %ebx,%eax
  800906:	50                   	push   %eax
  800907:	e8 c5 ff ff ff       	call   8008d1 <strcpy>
	return dst;
}
  80090c:	89 d8                	mov    %ebx,%eax
  80090e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 75 08             	mov    0x8(%ebp),%esi
  80091b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091e:	89 f3                	mov    %esi,%ebx
  800920:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800923:	89 f2                	mov    %esi,%edx
  800925:	eb 0f                	jmp    800936 <strncpy+0x23>
		*dst++ = *src;
  800927:	83 c2 01             	add    $0x1,%edx
  80092a:	0f b6 01             	movzbl (%ecx),%eax
  80092d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800930:	80 39 01             	cmpb   $0x1,(%ecx)
  800933:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800936:	39 da                	cmp    %ebx,%edx
  800938:	75 ed                	jne    800927 <strncpy+0x14>
	}
	return ret;
}
  80093a:	89 f0                	mov    %esi,%eax
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 75 08             	mov    0x8(%ebp),%esi
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80094e:	89 f0                	mov    %esi,%eax
  800950:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800954:	85 c9                	test   %ecx,%ecx
  800956:	75 0b                	jne    800963 <strlcpy+0x23>
  800958:	eb 17                	jmp    800971 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095a:	83 c2 01             	add    $0x1,%edx
  80095d:	83 c0 01             	add    $0x1,%eax
  800960:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800963:	39 d8                	cmp    %ebx,%eax
  800965:	74 07                	je     80096e <strlcpy+0x2e>
  800967:	0f b6 0a             	movzbl (%edx),%ecx
  80096a:	84 c9                	test   %cl,%cl
  80096c:	75 ec                	jne    80095a <strlcpy+0x1a>
		*dst = '\0';
  80096e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800971:	29 f0                	sub    %esi,%eax
}
  800973:	5b                   	pop    %ebx
  800974:	5e                   	pop    %esi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800980:	eb 06                	jmp    800988 <strcmp+0x11>
		p++, q++;
  800982:	83 c1 01             	add    $0x1,%ecx
  800985:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800988:	0f b6 01             	movzbl (%ecx),%eax
  80098b:	84 c0                	test   %al,%al
  80098d:	74 04                	je     800993 <strcmp+0x1c>
  80098f:	3a 02                	cmp    (%edx),%al
  800991:	74 ef                	je     800982 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800993:	0f b6 c0             	movzbl %al,%eax
  800996:	0f b6 12             	movzbl (%edx),%edx
  800999:	29 d0                	sub    %edx,%eax
}
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a7:	89 c3                	mov    %eax,%ebx
  8009a9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ac:	eb 06                	jmp    8009b4 <strncmp+0x17>
		n--, p++, q++;
  8009ae:	83 c0 01             	add    $0x1,%eax
  8009b1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b4:	39 d8                	cmp    %ebx,%eax
  8009b6:	74 16                	je     8009ce <strncmp+0x31>
  8009b8:	0f b6 08             	movzbl (%eax),%ecx
  8009bb:	84 c9                	test   %cl,%cl
  8009bd:	74 04                	je     8009c3 <strncmp+0x26>
  8009bf:	3a 0a                	cmp    (%edx),%cl
  8009c1:	74 eb                	je     8009ae <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c3:	0f b6 00             	movzbl (%eax),%eax
  8009c6:	0f b6 12             	movzbl (%edx),%edx
  8009c9:	29 d0                	sub    %edx,%eax
}
  8009cb:	5b                   	pop    %ebx
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    
		return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d3:	eb f6                	jmp    8009cb <strncmp+0x2e>

008009d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009df:	0f b6 10             	movzbl (%eax),%edx
  8009e2:	84 d2                	test   %dl,%dl
  8009e4:	74 09                	je     8009ef <strchr+0x1a>
		if (*s == c)
  8009e6:	38 ca                	cmp    %cl,%dl
  8009e8:	74 0a                	je     8009f4 <strchr+0x1f>
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	eb f0                	jmp    8009df <strchr+0xa>
			return (char *) s;
	return 0;
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a00:	eb 03                	jmp    800a05 <strfind+0xf>
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a08:	38 ca                	cmp    %cl,%dl
  800a0a:	74 04                	je     800a10 <strfind+0x1a>
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	75 f2                	jne    800a02 <strfind+0xc>
			break;
	return (char *) s;
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a1e:	85 c9                	test   %ecx,%ecx
  800a20:	74 12                	je     800a34 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a22:	f6 c2 03             	test   $0x3,%dl
  800a25:	75 05                	jne    800a2c <memset+0x1a>
  800a27:	f6 c1 03             	test   $0x3,%cl
  800a2a:	74 0f                	je     800a3b <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a2c:	89 d7                	mov    %edx,%edi
  800a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a31:	fc                   	cld    
  800a32:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a34:	89 d0                	mov    %edx,%eax
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    
		c &= 0xFF;
  800a3b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3f:	89 d8                	mov    %ebx,%eax
  800a41:	c1 e0 08             	shl    $0x8,%eax
  800a44:	89 df                	mov    %ebx,%edi
  800a46:	c1 e7 18             	shl    $0x18,%edi
  800a49:	89 de                	mov    %ebx,%esi
  800a4b:	c1 e6 10             	shl    $0x10,%esi
  800a4e:	09 f7                	or     %esi,%edi
  800a50:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800a52:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a55:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a57:	89 d7                	mov    %edx,%edi
  800a59:	fc                   	cld    
  800a5a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a5c:	eb d6                	jmp    800a34 <memset+0x22>

00800a5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a6c:	39 c6                	cmp    %eax,%esi
  800a6e:	73 35                	jae    800aa5 <memmove+0x47>
  800a70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a73:	39 c2                	cmp    %eax,%edx
  800a75:	76 2e                	jbe    800aa5 <memmove+0x47>
		s += n;
		d += n;
  800a77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7a:	89 d6                	mov    %edx,%esi
  800a7c:	09 fe                	or     %edi,%esi
  800a7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a84:	74 0c                	je     800a92 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a86:	83 ef 01             	sub    $0x1,%edi
  800a89:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a8c:	fd                   	std    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8f:	fc                   	cld    
  800a90:	eb 21                	jmp    800ab3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	f6 c1 03             	test   $0x3,%cl
  800a95:	75 ef                	jne    800a86 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a97:	83 ef 04             	sub    $0x4,%edi
  800a9a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aa0:	fd                   	std    
  800aa1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa3:	eb ea                	jmp    800a8f <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa5:	89 f2                	mov    %esi,%edx
  800aa7:	09 c2                	or     %eax,%edx
  800aa9:	f6 c2 03             	test   $0x3,%dl
  800aac:	74 09                	je     800ab7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aae:	89 c7                	mov    %eax,%edi
  800ab0:	fc                   	cld    
  800ab1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab3:	5e                   	pop    %esi
  800ab4:	5f                   	pop    %edi
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab7:	f6 c1 03             	test   $0x3,%cl
  800aba:	75 f2                	jne    800aae <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800abf:	89 c7                	mov    %eax,%edi
  800ac1:	fc                   	cld    
  800ac2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac4:	eb ed                	jmp    800ab3 <memmove+0x55>

00800ac6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ac9:	ff 75 10             	pushl  0x10(%ebp)
  800acc:	ff 75 0c             	pushl  0xc(%ebp)
  800acf:	ff 75 08             	pushl  0x8(%ebp)
  800ad2:	e8 87 ff ff ff       	call   800a5e <memmove>
}
  800ad7:	c9                   	leave  
  800ad8:	c3                   	ret    

00800ad9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae4:	89 c6                	mov    %eax,%esi
  800ae6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae9:	39 f0                	cmp    %esi,%eax
  800aeb:	74 1c                	je     800b09 <memcmp+0x30>
		if (*s1 != *s2)
  800aed:	0f b6 08             	movzbl (%eax),%ecx
  800af0:	0f b6 1a             	movzbl (%edx),%ebx
  800af3:	38 d9                	cmp    %bl,%cl
  800af5:	75 08                	jne    800aff <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af7:	83 c0 01             	add    $0x1,%eax
  800afa:	83 c2 01             	add    $0x1,%edx
  800afd:	eb ea                	jmp    800ae9 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800aff:	0f b6 c1             	movzbl %cl,%eax
  800b02:	0f b6 db             	movzbl %bl,%ebx
  800b05:	29 d8                	sub    %ebx,%eax
  800b07:	eb 05                	jmp    800b0e <memcmp+0x35>
	}

	return 0;
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1b:	89 c2                	mov    %eax,%edx
  800b1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b20:	39 d0                	cmp    %edx,%eax
  800b22:	73 09                	jae    800b2d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b24:	38 08                	cmp    %cl,(%eax)
  800b26:	74 05                	je     800b2d <memfind+0x1b>
	for (; s < ends; s++)
  800b28:	83 c0 01             	add    $0x1,%eax
  800b2b:	eb f3                	jmp    800b20 <memfind+0xe>
			break;
	return (void *) s;
}
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3b:	eb 03                	jmp    800b40 <strtol+0x11>
		s++;
  800b3d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b40:	0f b6 01             	movzbl (%ecx),%eax
  800b43:	3c 20                	cmp    $0x20,%al
  800b45:	74 f6                	je     800b3d <strtol+0xe>
  800b47:	3c 09                	cmp    $0x9,%al
  800b49:	74 f2                	je     800b3d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b4b:	3c 2b                	cmp    $0x2b,%al
  800b4d:	74 2e                	je     800b7d <strtol+0x4e>
	int neg = 0;
  800b4f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b54:	3c 2d                	cmp    $0x2d,%al
  800b56:	74 2f                	je     800b87 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b58:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5e:	75 05                	jne    800b65 <strtol+0x36>
  800b60:	80 39 30             	cmpb   $0x30,(%ecx)
  800b63:	74 2c                	je     800b91 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b65:	85 db                	test   %ebx,%ebx
  800b67:	75 0a                	jne    800b73 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b69:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b6e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b71:	74 28                	je     800b9b <strtol+0x6c>
		base = 10;
  800b73:	b8 00 00 00 00       	mov    $0x0,%eax
  800b78:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b7b:	eb 50                	jmp    800bcd <strtol+0x9e>
		s++;
  800b7d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b80:	bf 00 00 00 00       	mov    $0x0,%edi
  800b85:	eb d1                	jmp    800b58 <strtol+0x29>
		s++, neg = 1;
  800b87:	83 c1 01             	add    $0x1,%ecx
  800b8a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b8f:	eb c7                	jmp    800b58 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b91:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b95:	74 0e                	je     800ba5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b97:	85 db                	test   %ebx,%ebx
  800b99:	75 d8                	jne    800b73 <strtol+0x44>
		s++, base = 8;
  800b9b:	83 c1 01             	add    $0x1,%ecx
  800b9e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ba3:	eb ce                	jmp    800b73 <strtol+0x44>
		s += 2, base = 16;
  800ba5:	83 c1 02             	add    $0x2,%ecx
  800ba8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bad:	eb c4                	jmp    800b73 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800baf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb2:	89 f3                	mov    %esi,%ebx
  800bb4:	80 fb 19             	cmp    $0x19,%bl
  800bb7:	77 29                	ja     800be2 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bb9:	0f be d2             	movsbl %dl,%edx
  800bbc:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bbf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bc2:	7d 30                	jge    800bf4 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bc4:	83 c1 01             	add    $0x1,%ecx
  800bc7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bcb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bcd:	0f b6 11             	movzbl (%ecx),%edx
  800bd0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bd3:	89 f3                	mov    %esi,%ebx
  800bd5:	80 fb 09             	cmp    $0x9,%bl
  800bd8:	77 d5                	ja     800baf <strtol+0x80>
			dig = *s - '0';
  800bda:	0f be d2             	movsbl %dl,%edx
  800bdd:	83 ea 30             	sub    $0x30,%edx
  800be0:	eb dd                	jmp    800bbf <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800be2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be5:	89 f3                	mov    %esi,%ebx
  800be7:	80 fb 19             	cmp    $0x19,%bl
  800bea:	77 08                	ja     800bf4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bec:	0f be d2             	movsbl %dl,%edx
  800bef:	83 ea 37             	sub    $0x37,%edx
  800bf2:	eb cb                	jmp    800bbf <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf8:	74 05                	je     800bff <strtol+0xd0>
		*endptr = (char *) s;
  800bfa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bff:	89 c2                	mov    %eax,%edx
  800c01:	f7 da                	neg    %edx
  800c03:	85 ff                	test   %edi,%edi
  800c05:	0f 45 c2             	cmovne %edx,%eax
}
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    
  800c0d:	66 90                	xchg   %ax,%ax
  800c0f:	90                   	nop

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
