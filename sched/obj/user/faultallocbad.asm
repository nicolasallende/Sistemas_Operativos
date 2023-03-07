
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 40 0f 80 00       	push   $0x800f40
  800045:	e8 a2 01 00 00       	call   8001ec <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 30 0b 00 00       	call   800b8e <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 8c 0f 80 00       	push   $0x800f8c
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 8d 06 00 00       	call   800700 <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 60 0f 80 00       	push   $0x800f60
  800085:	6a 0f                	push   $0xf
  800087:	68 4a 0f 80 00       	push   $0x800f4a
  80008c:	e8 80 00 00 00       	call   800111 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 e7 0b 00 00       	call   800c88 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 27 0a 00 00       	call   800ad7 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000c0:	e8 7e 0a 00 00       	call   800b43 <sys_getenvid>
	if (id >= 0)
  8000c5:	85 c0                	test   %eax,%eax
  8000c7:	78 12                	js     8000db <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8000c9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ce:	c1 e0 07             	shl    $0x7,%eax
  8000d1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d6:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000db:	85 db                	test   %ebx,%ebx
  8000dd:	7e 07                	jle    8000e6 <libmain+0x31>
		binaryname = argv[0];
  8000df:	8b 06                	mov    (%esi),%eax
  8000e1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	e8 a1 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000f0:	e8 0a 00 00 00       	call   8000ff <exit>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800105:	6a 00                	push   $0x0
  800107:	e8 15 0a 00 00       	call   800b21 <sys_env_destroy>
}
  80010c:	83 c4 10             	add    $0x10,%esp
  80010f:	c9                   	leave  
  800110:	c3                   	ret    

00800111 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800116:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800119:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80011f:	e8 1f 0a 00 00       	call   800b43 <sys_getenvid>
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	ff 75 0c             	pushl  0xc(%ebp)
  80012a:	ff 75 08             	pushl  0x8(%ebp)
  80012d:	56                   	push   %esi
  80012e:	50                   	push   %eax
  80012f:	68 b8 0f 80 00       	push   $0x800fb8
  800134:	e8 b3 00 00 00       	call   8001ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800139:	83 c4 18             	add    $0x18,%esp
  80013c:	53                   	push   %ebx
  80013d:	ff 75 10             	pushl  0x10(%ebp)
  800140:	e8 56 00 00 00       	call   80019b <vcprintf>
	cprintf("\n");
  800145:	c7 04 24 48 0f 80 00 	movl   $0x800f48,(%esp)
  80014c:	e8 9b 00 00 00       	call   8001ec <cprintf>
  800151:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800154:	cc                   	int3   
  800155:	eb fd                	jmp    800154 <_panic+0x43>

00800157 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	53                   	push   %ebx
  80015b:	83 ec 04             	sub    $0x4,%esp
  80015e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800161:	8b 13                	mov    (%ebx),%edx
  800163:	8d 42 01             	lea    0x1(%edx),%eax
  800166:	89 03                	mov    %eax,(%ebx)
  800168:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800174:	74 09                	je     80017f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800176:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80017f:	83 ec 08             	sub    $0x8,%esp
  800182:	68 ff 00 00 00       	push   $0xff
  800187:	8d 43 08             	lea    0x8(%ebx),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 47 09 00 00       	call   800ad7 <sys_cputs>
		b->idx = 0;
  800190:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	eb db                	jmp    800176 <putch+0x1f>

0080019b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	ff 75 0c             	pushl  0xc(%ebp)
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c4:	50                   	push   %eax
  8001c5:	68 57 01 80 00       	push   $0x800157
  8001ca:	e8 86 01 00 00       	call   800355 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cf:	83 c4 08             	add    $0x8,%esp
  8001d2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	e8 f3 08 00 00       	call   800ad7 <sys_cputs>

	return b.cnt;
}
  8001e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f5:	50                   	push   %eax
  8001f6:	ff 75 08             	pushl  0x8(%ebp)
  8001f9:	e8 9d ff ff ff       	call   80019b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 1c             	sub    $0x1c,%esp
  800209:	89 c7                	mov    %eax,%edi
  80020b:	89 d6                	mov    %edx,%esi
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	8b 55 0c             	mov    0xc(%ebp),%edx
  800213:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800216:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800219:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800221:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800224:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800227:	39 d3                	cmp    %edx,%ebx
  800229:	72 05                	jb     800230 <printnum+0x30>
  80022b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80022e:	77 7a                	ja     8002aa <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	8b 45 14             	mov    0x14(%ebp),%eax
  800239:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023c:	53                   	push   %ebx
  80023d:	ff 75 10             	pushl  0x10(%ebp)
  800240:	83 ec 08             	sub    $0x8,%esp
  800243:	ff 75 e4             	pushl  -0x1c(%ebp)
  800246:	ff 75 e0             	pushl  -0x20(%ebp)
  800249:	ff 75 dc             	pushl  -0x24(%ebp)
  80024c:	ff 75 d8             	pushl  -0x28(%ebp)
  80024f:	e8 ac 0a 00 00       	call   800d00 <__udivdi3>
  800254:	83 c4 18             	add    $0x18,%esp
  800257:	52                   	push   %edx
  800258:	50                   	push   %eax
  800259:	89 f2                	mov    %esi,%edx
  80025b:	89 f8                	mov    %edi,%eax
  80025d:	e8 9e ff ff ff       	call   800200 <printnum>
  800262:	83 c4 20             	add    $0x20,%esp
  800265:	eb 13                	jmp    80027a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	ff 75 18             	pushl  0x18(%ebp)
  80026e:	ff d7                	call   *%edi
  800270:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800273:	83 eb 01             	sub    $0x1,%ebx
  800276:	85 db                	test   %ebx,%ebx
  800278:	7f ed                	jg     800267 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	56                   	push   %esi
  80027e:	83 ec 04             	sub    $0x4,%esp
  800281:	ff 75 e4             	pushl  -0x1c(%ebp)
  800284:	ff 75 e0             	pushl  -0x20(%ebp)
  800287:	ff 75 dc             	pushl  -0x24(%ebp)
  80028a:	ff 75 d8             	pushl  -0x28(%ebp)
  80028d:	e8 8e 0b 00 00       	call   800e20 <__umoddi3>
  800292:	83 c4 14             	add    $0x14,%esp
  800295:	0f be 80 dc 0f 80 00 	movsbl 0x800fdc(%eax),%eax
  80029c:	50                   	push   %eax
  80029d:	ff d7                	call   *%edi
}
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a5:	5b                   	pop    %ebx
  8002a6:	5e                   	pop    %esi
  8002a7:	5f                   	pop    %edi
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    
  8002aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ad:	eb c4                	jmp    800273 <printnum+0x73>

008002af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b2:	83 fa 01             	cmp    $0x1,%edx
  8002b5:	7e 0e                	jle    8002c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    
	else if (lflag)
  8002c5:	85 d2                	test   %edx,%edx
  8002c7:	75 10                	jne    8002d9 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d7:	eb ea                	jmp    8002c3 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e7:	eb da                	jmp    8002c3 <getuint+0x14>

008002e9 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getint+0x16>
		return va_arg(*ap, long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	75 0c                	jne    80030f <getint+0x26>
		return va_arg(*ap, int);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	99                   	cltd   
  80030d:	eb ee                	jmp    8002fd <getint+0x14>
		return va_arg(*ap, long);
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	8d 4a 04             	lea    0x4(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 02                	mov    (%edx),%eax
  800318:	99                   	cltd   
  800319:	eb e2                	jmp    8002fd <getint+0x14>

0080031b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800321:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800325:	8b 10                	mov    (%eax),%edx
  800327:	3b 50 04             	cmp    0x4(%eax),%edx
  80032a:	73 0a                	jae    800336 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	88 02                	mov    %al,(%edx)
}
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <printfmt>:
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80033e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800341:	50                   	push   %eax
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	ff 75 0c             	pushl  0xc(%ebp)
  800348:	ff 75 08             	pushl  0x8(%ebp)
  80034b:	e8 05 00 00 00       	call   800355 <vprintfmt>
}
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	c9                   	leave  
  800354:	c3                   	ret    

00800355 <vprintfmt>:
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	57                   	push   %edi
  800359:	56                   	push   %esi
  80035a:	53                   	push   %ebx
  80035b:	83 ec 2c             	sub    $0x2c,%esp
  80035e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800361:	8b 75 0c             	mov    0xc(%ebp),%esi
  800364:	89 f7                	mov    %esi,%edi
  800366:	89 de                	mov    %ebx,%esi
  800368:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036b:	e9 9e 02 00 00       	jmp    80060e <vprintfmt+0x2b9>
		padc = ' ';
  800370:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800374:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80037b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800382:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8d 43 01             	lea    0x1(%ebx),%eax
  800391:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800394:	0f b6 0b             	movzbl (%ebx),%ecx
  800397:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80039a:	3c 55                	cmp    $0x55,%al
  80039c:	0f 87 e8 02 00 00    	ja     80068a <vprintfmt+0x335>
  8003a2:	0f b6 c0             	movzbl %al,%eax
  8003a5:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  8003ac:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  8003af:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003b3:	eb d9                	jmp    80038e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  8003b8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bc:	eb d0                	jmp    80038e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	0f b6 c9             	movzbl %cl,%ecx
  8003c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  8003c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d3:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8003d6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d9:	83 fa 09             	cmp    $0x9,%edx
  8003dc:	77 52                	ja     800430 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  8003de:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8003e1:	eb e9                	jmp    8003cc <vprintfmt+0x77>
			precision = va_arg(ap, int);
  8003e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ec:	8b 00                	mov    (%eax),%eax
  8003ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  8003f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f8:	79 94                	jns    80038e <vprintfmt+0x39>
				width = precision, precision = -1;
  8003fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800400:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800407:	eb 85                	jmp    80038e <vprintfmt+0x39>
  800409:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040c:	85 c0                	test   %eax,%eax
  80040e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800413:	0f 49 c8             	cmovns %eax,%ecx
  800416:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80041c:	e9 6d ff ff ff       	jmp    80038e <vprintfmt+0x39>
  800421:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800424:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042b:	e9 5e ff ff ff       	jmp    80038e <vprintfmt+0x39>
  800430:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800433:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800436:	eb bc                	jmp    8003f4 <vprintfmt+0x9f>
			lflag++;
  800438:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80043e:	e9 4b ff ff ff       	jmp    80038e <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	57                   	push   %edi
  800450:	ff 30                	pushl  (%eax)
  800452:	ff d6                	call   *%esi
			break;
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	e9 af 01 00 00       	jmp    80060b <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 00                	mov    (%eax),%eax
  800467:	99                   	cltd   
  800468:	31 d0                	xor    %edx,%eax
  80046a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046c:	83 f8 08             	cmp    $0x8,%eax
  80046f:	7f 20                	jg     800491 <vprintfmt+0x13c>
  800471:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	74 15                	je     800491 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80047c:	52                   	push   %edx
  80047d:	68 fd 0f 80 00       	push   $0x800ffd
  800482:	57                   	push   %edi
  800483:	56                   	push   %esi
  800484:	e8 af fe ff ff       	call   800338 <printfmt>
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	e9 7a 01 00 00       	jmp    80060b <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800491:	50                   	push   %eax
  800492:	68 f4 0f 80 00       	push   $0x800ff4
  800497:	57                   	push   %edi
  800498:	56                   	push   %esi
  800499:	e8 9a fe ff ff       	call   800338 <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	e9 65 01 00 00       	jmp    80060b <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8004af:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  8004b1:	85 db                	test   %ebx,%ebx
  8004b3:	b8 ed 0f 80 00       	mov    $0x800fed,%eax
  8004b8:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  8004bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bf:	0f 8e bd 00 00 00    	jle    800582 <vprintfmt+0x22d>
  8004c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c9:	75 0e                	jne    8004d9 <vprintfmt+0x184>
  8004cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d1:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004d4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004d7:	eb 6d                	jmp    800546 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004df:	53                   	push   %ebx
  8004e0:	e8 4d 02 00 00       	call   800732 <strnlen>
  8004e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e8:	29 c1                	sub    %eax,%ecx
  8004ea:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f7:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004fa:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	eb 0f                	jmp    80050d <vprintfmt+0x1b8>
					putch(padc, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	57                   	push   %edi
  800502:	ff 75 e0             	pushl  -0x20(%ebp)
  800505:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800507:	83 eb 01             	sub    $0x1,%ebx
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	85 db                	test   %ebx,%ebx
  80050f:	7f ed                	jg     8004fe <vprintfmt+0x1a9>
  800511:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800514:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800517:	85 c9                	test   %ecx,%ecx
  800519:	b8 00 00 00 00       	mov    $0x0,%eax
  80051e:	0f 49 c1             	cmovns %ecx,%eax
  800521:	29 c1                	sub    %eax,%ecx
  800523:	89 75 08             	mov    %esi,0x8(%ebp)
  800526:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800529:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80052c:	89 cf                	mov    %ecx,%edi
  80052e:	eb 16                	jmp    800546 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800530:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800534:	75 31                	jne    800567 <vprintfmt+0x212>
					putch(ch, putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	ff 75 0c             	pushl  0xc(%ebp)
  80053c:	50                   	push   %eax
  80053d:	ff 55 08             	call   *0x8(%ebp)
  800540:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800543:	83 ef 01             	sub    $0x1,%edi
  800546:	83 c3 01             	add    $0x1,%ebx
  800549:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  80054d:	0f be c2             	movsbl %dl,%eax
  800550:	85 c0                	test   %eax,%eax
  800552:	74 50                	je     8005a4 <vprintfmt+0x24f>
  800554:	85 f6                	test   %esi,%esi
  800556:	78 d8                	js     800530 <vprintfmt+0x1db>
  800558:	83 ee 01             	sub    $0x1,%esi
  80055b:	79 d3                	jns    800530 <vprintfmt+0x1db>
  80055d:	89 fb                	mov    %edi,%ebx
  80055f:	8b 75 08             	mov    0x8(%ebp),%esi
  800562:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800565:	eb 37                	jmp    80059e <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  800567:	0f be d2             	movsbl %dl,%edx
  80056a:	83 ea 20             	sub    $0x20,%edx
  80056d:	83 fa 5e             	cmp    $0x5e,%edx
  800570:	76 c4                	jbe    800536 <vprintfmt+0x1e1>
					putch('?', putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	ff 75 0c             	pushl  0xc(%ebp)
  800578:	6a 3f                	push   $0x3f
  80057a:	ff 55 08             	call   *0x8(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	eb c1                	jmp    800543 <vprintfmt+0x1ee>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800588:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80058b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80058e:	eb b6                	jmp    800546 <vprintfmt+0x1f1>
				putch(' ', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	57                   	push   %edi
  800594:	6a 20                	push   $0x20
  800596:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800598:	83 eb 01             	sub    $0x1,%ebx
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	85 db                	test   %ebx,%ebx
  8005a0:	7f ee                	jg     800590 <vprintfmt+0x23b>
  8005a2:	eb 67                	jmp    80060b <vprintfmt+0x2b6>
  8005a4:	89 fb                	mov    %edi,%ebx
  8005a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005ac:	eb f0                	jmp    80059e <vprintfmt+0x249>
			num = getint(&ap, lflag);
  8005ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b1:	e8 33 fd ff ff       	call   8002e9 <getint>
  8005b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8005c1:	85 d2                	test   %edx,%edx
  8005c3:	79 2c                	jns    8005f1 <vprintfmt+0x29c>
				putch('-', putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	57                   	push   %edi
  8005c9:	6a 2d                	push   $0x2d
  8005cb:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d3:	f7 d8                	neg    %eax
  8005d5:	83 d2 00             	adc    $0x0,%edx
  8005d8:	f7 da                	neg    %edx
  8005da:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e2:	eb 0d                	jmp    8005f1 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e7:	e8 c3 fc ff ff       	call   8002af <getuint>
			base = 10;
  8005ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  8005f8:	53                   	push   %ebx
  8005f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fc:	51                   	push   %ecx
  8005fd:	52                   	push   %edx
  8005fe:	50                   	push   %eax
  8005ff:	89 fa                	mov    %edi,%edx
  800601:	89 f0                	mov    %esi,%eax
  800603:	e8 f8 fb ff ff       	call   800200 <printnum>
			break;
  800608:	83 c4 20             	add    $0x20,%esp
{
  80060b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80060e:	83 c3 01             	add    $0x1,%ebx
  800611:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800615:	83 f8 25             	cmp    $0x25,%eax
  800618:	0f 84 52 fd ff ff    	je     800370 <vprintfmt+0x1b>
			if (ch == '\0')
  80061e:	85 c0                	test   %eax,%eax
  800620:	0f 84 84 00 00 00    	je     8006aa <vprintfmt+0x355>
			putch(ch, putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	57                   	push   %edi
  80062a:	50                   	push   %eax
  80062b:	ff d6                	call   *%esi
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb dc                	jmp    80060e <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 75 fc ff ff       	call   8002af <getuint>
			base = 8;
  80063a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80063f:	eb b0                	jmp    8005f1 <vprintfmt+0x29c>
			putch('0', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	57                   	push   %edi
  800645:	6a 30                	push   $0x30
  800647:	ff d6                	call   *%esi
			putch('x', putdat);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	57                   	push   %edi
  80064d:	6a 78                	push   $0x78
  80064f:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800661:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800664:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800669:	eb 86                	jmp    8005f1 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 3c fc ff ff       	call   8002af <getuint>
			base = 16;
  800673:	b9 10 00 00 00       	mov    $0x10,%ecx
  800678:	e9 74 ff ff ff       	jmp    8005f1 <vprintfmt+0x29c>
			putch(ch, putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	57                   	push   %edi
  800681:	6a 25                	push   $0x25
  800683:	ff d6                	call   *%esi
			break;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	eb 81                	jmp    80060b <vprintfmt+0x2b6>
			putch('%', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	57                   	push   %edi
  80068e:	6a 25                	push   $0x25
  800690:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800692:	83 c4 10             	add    $0x10,%esp
  800695:	89 d8                	mov    %ebx,%eax
  800697:	eb 03                	jmp    80069c <vprintfmt+0x347>
  800699:	83 e8 01             	sub    $0x1,%eax
  80069c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a0:	75 f7                	jne    800699 <vprintfmt+0x344>
  8006a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a5:	e9 61 ff ff ff       	jmp    80060b <vprintfmt+0x2b6>
}
  8006aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ad:	5b                   	pop    %ebx
  8006ae:	5e                   	pop    %esi
  8006af:	5f                   	pop    %edi
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 18             	sub    $0x18,%esp
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 26                	je     8006f9 <vsnprintf+0x47>
  8006d3:	85 d2                	test   %edx,%edx
  8006d5:	7e 22                	jle    8006f9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d7:	ff 75 14             	pushl  0x14(%ebp)
  8006da:	ff 75 10             	pushl  0x10(%ebp)
  8006dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e0:	50                   	push   %eax
  8006e1:	68 1b 03 80 00       	push   $0x80031b
  8006e6:	e8 6a fc ff ff       	call   800355 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ee:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f4:	83 c4 10             	add    $0x10,%esp
}
  8006f7:	c9                   	leave  
  8006f8:	c3                   	ret    
		return -E_INVAL;
  8006f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fe:	eb f7                	jmp    8006f7 <vsnprintf+0x45>

00800700 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800709:	50                   	push   %eax
  80070a:	ff 75 10             	pushl  0x10(%ebp)
  80070d:	ff 75 0c             	pushl  0xc(%ebp)
  800710:	ff 75 08             	pushl  0x8(%ebp)
  800713:	e8 9a ff ff ff       	call   8006b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800720:	b8 00 00 00 00       	mov    $0x0,%eax
  800725:	eb 03                	jmp    80072a <strlen+0x10>
		n++;
  800727:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80072a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072e:	75 f7                	jne    800727 <strlen+0xd>
	return n;
}
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800738:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
  800740:	eb 03                	jmp    800745 <strnlen+0x13>
		n++;
  800742:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800745:	39 d0                	cmp    %edx,%eax
  800747:	74 06                	je     80074f <strnlen+0x1d>
  800749:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80074d:	75 f3                	jne    800742 <strnlen+0x10>
	return n;
}
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	53                   	push   %ebx
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075b:	89 c2                	mov    %eax,%edx
  80075d:	83 c1 01             	add    $0x1,%ecx
  800760:	83 c2 01             	add    $0x1,%edx
  800763:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800767:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076a:	84 db                	test   %bl,%bl
  80076c:	75 ef                	jne    80075d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80076e:	5b                   	pop    %ebx
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	53                   	push   %ebx
  800775:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800778:	53                   	push   %ebx
  800779:	e8 9c ff ff ff       	call   80071a <strlen>
  80077e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800781:	ff 75 0c             	pushl  0xc(%ebp)
  800784:	01 d8                	add    %ebx,%eax
  800786:	50                   	push   %eax
  800787:	e8 c5 ff ff ff       	call   800751 <strcpy>
	return dst;
}
  80078c:	89 d8                	mov    %ebx,%eax
  80078e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800791:	c9                   	leave  
  800792:	c3                   	ret    

00800793 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	56                   	push   %esi
  800797:	53                   	push   %ebx
  800798:	8b 75 08             	mov    0x8(%ebp),%esi
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079e:	89 f3                	mov    %esi,%ebx
  8007a0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a3:	89 f2                	mov    %esi,%edx
  8007a5:	eb 0f                	jmp    8007b6 <strncpy+0x23>
		*dst++ = *src;
  8007a7:	83 c2 01             	add    $0x1,%edx
  8007aa:	0f b6 01             	movzbl (%ecx),%eax
  8007ad:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b0:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b3:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007b6:	39 da                	cmp    %ebx,%edx
  8007b8:	75 ed                	jne    8007a7 <strncpy+0x14>
	}
	return ret;
}
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	5b                   	pop    %ebx
  8007bd:	5e                   	pop    %esi
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	56                   	push   %esi
  8007c4:	53                   	push   %ebx
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007ce:	89 f0                	mov    %esi,%eax
  8007d0:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d4:	85 c9                	test   %ecx,%ecx
  8007d6:	75 0b                	jne    8007e3 <strlcpy+0x23>
  8007d8:	eb 17                	jmp    8007f1 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007da:	83 c2 01             	add    $0x1,%edx
  8007dd:	83 c0 01             	add    $0x1,%eax
  8007e0:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8007e3:	39 d8                	cmp    %ebx,%eax
  8007e5:	74 07                	je     8007ee <strlcpy+0x2e>
  8007e7:	0f b6 0a             	movzbl (%edx),%ecx
  8007ea:	84 c9                	test   %cl,%cl
  8007ec:	75 ec                	jne    8007da <strlcpy+0x1a>
		*dst = '\0';
  8007ee:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f1:	29 f0                	sub    %esi,%eax
}
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800800:	eb 06                	jmp    800808 <strcmp+0x11>
		p++, q++;
  800802:	83 c1 01             	add    $0x1,%ecx
  800805:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800808:	0f b6 01             	movzbl (%ecx),%eax
  80080b:	84 c0                	test   %al,%al
  80080d:	74 04                	je     800813 <strcmp+0x1c>
  80080f:	3a 02                	cmp    (%edx),%al
  800811:	74 ef                	je     800802 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800813:	0f b6 c0             	movzbl %al,%eax
  800816:	0f b6 12             	movzbl (%edx),%edx
  800819:	29 d0                	sub    %edx,%eax
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	53                   	push   %ebx
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
  800827:	89 c3                	mov    %eax,%ebx
  800829:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80082c:	eb 06                	jmp    800834 <strncmp+0x17>
		n--, p++, q++;
  80082e:	83 c0 01             	add    $0x1,%eax
  800831:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800834:	39 d8                	cmp    %ebx,%eax
  800836:	74 16                	je     80084e <strncmp+0x31>
  800838:	0f b6 08             	movzbl (%eax),%ecx
  80083b:	84 c9                	test   %cl,%cl
  80083d:	74 04                	je     800843 <strncmp+0x26>
  80083f:	3a 0a                	cmp    (%edx),%cl
  800841:	74 eb                	je     80082e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 00             	movzbl (%eax),%eax
  800846:	0f b6 12             	movzbl (%edx),%edx
  800849:	29 d0                	sub    %edx,%eax
}
  80084b:	5b                   	pop    %ebx
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    
		return 0;
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
  800853:	eb f6                	jmp    80084b <strncmp+0x2e>

00800855 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085f:	0f b6 10             	movzbl (%eax),%edx
  800862:	84 d2                	test   %dl,%dl
  800864:	74 09                	je     80086f <strchr+0x1a>
		if (*s == c)
  800866:	38 ca                	cmp    %cl,%dl
  800868:	74 0a                	je     800874 <strchr+0x1f>
	for (; *s; s++)
  80086a:	83 c0 01             	add    $0x1,%eax
  80086d:	eb f0                	jmp    80085f <strchr+0xa>
			return (char *) s;
	return 0;
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800880:	eb 03                	jmp    800885 <strfind+0xf>
  800882:	83 c0 01             	add    $0x1,%eax
  800885:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	74 04                	je     800890 <strfind+0x1a>
  80088c:	84 d2                	test   %dl,%dl
  80088e:	75 f2                	jne    800882 <strfind+0xc>
			break;
	return (char *) s;
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 55 08             	mov    0x8(%ebp),%edx
  80089b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80089e:	85 c9                	test   %ecx,%ecx
  8008a0:	74 12                	je     8008b4 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a2:	f6 c2 03             	test   $0x3,%dl
  8008a5:	75 05                	jne    8008ac <memset+0x1a>
  8008a7:	f6 c1 03             	test   $0x3,%cl
  8008aa:	74 0f                	je     8008bb <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ac:	89 d7                	mov    %edx,%edi
  8008ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b1:	fc                   	cld    
  8008b2:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008b4:	89 d0                	mov    %edx,%eax
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5f                   	pop    %edi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    
		c &= 0xFF;
  8008bb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bf:	89 d8                	mov    %ebx,%eax
  8008c1:	c1 e0 08             	shl    $0x8,%eax
  8008c4:	89 df                	mov    %ebx,%edi
  8008c6:	c1 e7 18             	shl    $0x18,%edi
  8008c9:	89 de                	mov    %ebx,%esi
  8008cb:	c1 e6 10             	shl    $0x10,%esi
  8008ce:	09 f7                	or     %esi,%edi
  8008d0:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  8008d2:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d5:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008d7:	89 d7                	mov    %edx,%edi
  8008d9:	fc                   	cld    
  8008da:	f3 ab                	rep stos %eax,%es:(%edi)
  8008dc:	eb d6                	jmp    8008b4 <memset+0x22>

008008de <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	57                   	push   %edi
  8008e2:	56                   	push   %esi
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ec:	39 c6                	cmp    %eax,%esi
  8008ee:	73 35                	jae    800925 <memmove+0x47>
  8008f0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f3:	39 c2                	cmp    %eax,%edx
  8008f5:	76 2e                	jbe    800925 <memmove+0x47>
		s += n;
		d += n;
  8008f7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fa:	89 d6                	mov    %edx,%esi
  8008fc:	09 fe                	or     %edi,%esi
  8008fe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800904:	74 0c                	je     800912 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800906:	83 ef 01             	sub    $0x1,%edi
  800909:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80090c:	fd                   	std    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090f:	fc                   	cld    
  800910:	eb 21                	jmp    800933 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 ef                	jne    800906 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800917:	83 ef 04             	sub    $0x4,%edi
  80091a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800920:	fd                   	std    
  800921:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800923:	eb ea                	jmp    80090f <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800925:	89 f2                	mov    %esi,%edx
  800927:	09 c2                	or     %eax,%edx
  800929:	f6 c2 03             	test   $0x3,%dl
  80092c:	74 09                	je     800937 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092e:	89 c7                	mov    %eax,%edi
  800930:	fc                   	cld    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 f2                	jne    80092e <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80093c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80093f:	89 c7                	mov    %eax,%edi
  800941:	fc                   	cld    
  800942:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800944:	eb ed                	jmp    800933 <memmove+0x55>

00800946 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800949:	ff 75 10             	pushl  0x10(%ebp)
  80094c:	ff 75 0c             	pushl  0xc(%ebp)
  80094f:	ff 75 08             	pushl  0x8(%ebp)
  800952:	e8 87 ff ff ff       	call   8008de <memmove>
}
  800957:	c9                   	leave  
  800958:	c3                   	ret    

00800959 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	56                   	push   %esi
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 55 0c             	mov    0xc(%ebp),%edx
  800964:	89 c6                	mov    %eax,%esi
  800966:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800969:	39 f0                	cmp    %esi,%eax
  80096b:	74 1c                	je     800989 <memcmp+0x30>
		if (*s1 != *s2)
  80096d:	0f b6 08             	movzbl (%eax),%ecx
  800970:	0f b6 1a             	movzbl (%edx),%ebx
  800973:	38 d9                	cmp    %bl,%cl
  800975:	75 08                	jne    80097f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800977:	83 c0 01             	add    $0x1,%eax
  80097a:	83 c2 01             	add    $0x1,%edx
  80097d:	eb ea                	jmp    800969 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80097f:	0f b6 c1             	movzbl %cl,%eax
  800982:	0f b6 db             	movzbl %bl,%ebx
  800985:	29 d8                	sub    %ebx,%eax
  800987:	eb 05                	jmp    80098e <memcmp+0x35>
	}

	return 0;
  800989:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098e:	5b                   	pop    %ebx
  80098f:	5e                   	pop    %esi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80099b:	89 c2                	mov    %eax,%edx
  80099d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a0:	39 d0                	cmp    %edx,%eax
  8009a2:	73 09                	jae    8009ad <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a4:	38 08                	cmp    %cl,(%eax)
  8009a6:	74 05                	je     8009ad <memfind+0x1b>
	for (; s < ends; s++)
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	eb f3                	jmp    8009a0 <memfind+0xe>
			break;
	return (void *) s;
}
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bb:	eb 03                	jmp    8009c0 <strtol+0x11>
		s++;
  8009bd:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009c0:	0f b6 01             	movzbl (%ecx),%eax
  8009c3:	3c 20                	cmp    $0x20,%al
  8009c5:	74 f6                	je     8009bd <strtol+0xe>
  8009c7:	3c 09                	cmp    $0x9,%al
  8009c9:	74 f2                	je     8009bd <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009cb:	3c 2b                	cmp    $0x2b,%al
  8009cd:	74 2e                	je     8009fd <strtol+0x4e>
	int neg = 0;
  8009cf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009d4:	3c 2d                	cmp    $0x2d,%al
  8009d6:	74 2f                	je     800a07 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009de:	75 05                	jne    8009e5 <strtol+0x36>
  8009e0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e3:	74 2c                	je     800a11 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e5:	85 db                	test   %ebx,%ebx
  8009e7:	75 0a                	jne    8009f3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8009ee:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f1:	74 28                	je     800a1b <strtol+0x6c>
		base = 10;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009fb:	eb 50                	jmp    800a4d <strtol+0x9e>
		s++;
  8009fd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a00:	bf 00 00 00 00       	mov    $0x0,%edi
  800a05:	eb d1                	jmp    8009d8 <strtol+0x29>
		s++, neg = 1;
  800a07:	83 c1 01             	add    $0x1,%ecx
  800a0a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a0f:	eb c7                	jmp    8009d8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a11:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a15:	74 0e                	je     800a25 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a17:	85 db                	test   %ebx,%ebx
  800a19:	75 d8                	jne    8009f3 <strtol+0x44>
		s++, base = 8;
  800a1b:	83 c1 01             	add    $0x1,%ecx
  800a1e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a23:	eb ce                	jmp    8009f3 <strtol+0x44>
		s += 2, base = 16;
  800a25:	83 c1 02             	add    $0x2,%ecx
  800a28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2d:	eb c4                	jmp    8009f3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a2f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a32:	89 f3                	mov    %esi,%ebx
  800a34:	80 fb 19             	cmp    $0x19,%bl
  800a37:	77 29                	ja     800a62 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a39:	0f be d2             	movsbl %dl,%edx
  800a3c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a3f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a42:	7d 30                	jge    800a74 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a44:	83 c1 01             	add    $0x1,%ecx
  800a47:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a4b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a4d:	0f b6 11             	movzbl (%ecx),%edx
  800a50:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a53:	89 f3                	mov    %esi,%ebx
  800a55:	80 fb 09             	cmp    $0x9,%bl
  800a58:	77 d5                	ja     800a2f <strtol+0x80>
			dig = *s - '0';
  800a5a:	0f be d2             	movsbl %dl,%edx
  800a5d:	83 ea 30             	sub    $0x30,%edx
  800a60:	eb dd                	jmp    800a3f <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a62:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 19             	cmp    $0x19,%bl
  800a6a:	77 08                	ja     800a74 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 37             	sub    $0x37,%edx
  800a72:	eb cb                	jmp    800a3f <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a78:	74 05                	je     800a7f <strtol+0xd0>
		*endptr = (char *) s;
  800a7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a7f:	89 c2                	mov    %eax,%edx
  800a81:	f7 da                	neg    %edx
  800a83:	85 ff                	test   %edi,%edi
  800a85:	0f 45 c2             	cmovne %edx,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	83 ec 1c             	sub    $0x1c,%esp
  800a96:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a9c:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa4:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aa7:	8b 75 14             	mov    0x14(%ebp),%esi
  800aaa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ab0:	74 04                	je     800ab6 <syscall+0x29>
  800ab2:	85 c0                	test   %eax,%eax
  800ab4:	7f 08                	jg     800abe <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800ab6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    
  800abe:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac1:	83 ec 0c             	sub    $0xc,%esp
  800ac4:	50                   	push   %eax
  800ac5:	52                   	push   %edx
  800ac6:	68 24 12 80 00       	push   $0x801224
  800acb:	6a 23                	push   $0x23
  800acd:	68 41 12 80 00       	push   $0x801241
  800ad2:	e8 3a f6 ff ff       	call   800111 <_panic>

00800ad7 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800add:	6a 00                	push   $0x0
  800adf:	6a 00                	push   $0x0
  800ae1:	6a 00                	push   $0x0
  800ae3:	ff 75 0c             	pushl  0xc(%ebp)
  800ae6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
  800af3:	e8 95 ff ff ff       	call   800a8d <syscall>
}
  800af8:	83 c4 10             	add    $0x10,%esp
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <sys_cgetc>:

int
sys_cgetc(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b03:	6a 00                	push   $0x0
  800b05:	6a 00                	push   $0x0
  800b07:	6a 00                	push   $0x0
  800b09:	6a 00                	push   $0x0
  800b0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1a:	e8 6e ff ff ff       	call   800a8d <syscall>
}
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b27:	6a 00                	push   $0x0
  800b29:	6a 00                	push   $0x0
  800b2b:	6a 00                	push   $0x0
  800b2d:	6a 00                	push   $0x0
  800b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b32:	ba 01 00 00 00       	mov    $0x1,%edx
  800b37:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3c:	e8 4c ff ff ff       	call   800a8d <syscall>
}
  800b41:	c9                   	leave  
  800b42:	c3                   	ret    

00800b43 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b49:	6a 00                	push   $0x0
  800b4b:	6a 00                	push   $0x0
  800b4d:	6a 00                	push   $0x0
  800b4f:	6a 00                	push   $0x0
  800b51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b60:	e8 28 ff ff ff       	call   800a8d <syscall>
}
  800b65:	c9                   	leave  
  800b66:	c3                   	ret    

00800b67 <sys_yield>:

void
sys_yield(void)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	6a 00                	push   $0x0
  800b75:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b84:	e8 04 ff ff ff       	call   800a8d <syscall>
}
  800b89:	83 c4 10             	add    $0x10,%esp
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b94:	6a 00                	push   $0x0
  800b96:	6a 00                	push   $0x0
  800b98:	ff 75 10             	pushl  0x10(%ebp)
  800b9b:	ff 75 0c             	pushl  0xc(%ebp)
  800b9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba1:	ba 01 00 00 00       	mov    $0x1,%edx
  800ba6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bab:	e8 dd fe ff ff       	call   800a8d <syscall>
}
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bb8:	ff 75 18             	pushl  0x18(%ebp)
  800bbb:	ff 75 14             	pushl  0x14(%ebp)
  800bbe:	ff 75 10             	pushl  0x10(%ebp)
  800bc1:	ff 75 0c             	pushl  0xc(%ebp)
  800bc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc7:	ba 01 00 00 00       	mov    $0x1,%edx
  800bcc:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd1:	e8 b7 fe ff ff       	call   800a8d <syscall>
}
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bde:	6a 00                	push   $0x0
  800be0:	6a 00                	push   $0x0
  800be2:	6a 00                	push   $0x0
  800be4:	ff 75 0c             	pushl  0xc(%ebp)
  800be7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bea:	ba 01 00 00 00       	mov    $0x1,%edx
  800bef:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf4:	e8 94 fe ff ff       	call   800a8d <syscall>
}
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c01:	6a 00                	push   $0x0
  800c03:	6a 00                	push   $0x0
  800c05:	6a 00                	push   $0x0
  800c07:	ff 75 0c             	pushl  0xc(%ebp)
  800c0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c12:	b8 08 00 00 00       	mov    $0x8,%eax
  800c17:	e8 71 fe ff ff       	call   800a8d <syscall>
}
  800c1c:	c9                   	leave  
  800c1d:	c3                   	ret    

00800c1e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c24:	6a 00                	push   $0x0
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	ff 75 0c             	pushl  0xc(%ebp)
  800c2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c30:	ba 01 00 00 00       	mov    $0x1,%edx
  800c35:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3a:	e8 4e fe ff ff       	call   800a8d <syscall>
}
  800c3f:	c9                   	leave  
  800c40:	c3                   	ret    

00800c41 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c47:	6a 00                	push   $0x0
  800c49:	ff 75 14             	pushl  0x14(%ebp)
  800c4c:	ff 75 10             	pushl  0x10(%ebp)
  800c4f:	ff 75 0c             	pushl  0xc(%ebp)
  800c52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c5f:	e8 29 fe ff ff       	call   800a8d <syscall>
}
  800c64:	c9                   	leave  
  800c65:	c3                   	ret    

00800c66 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c6c:	6a 00                	push   $0x0
  800c6e:	6a 00                	push   $0x0
  800c70:	6a 00                	push   $0x0
  800c72:	6a 00                	push   $0x0
  800c74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c77:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c81:	e8 07 fe ff ff       	call   800a8d <syscall>
}
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800c8e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800c95:	74 0a                	je     800ca1 <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800c9f:	c9                   	leave  
  800ca0:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  800ca1:	83 ec 04             	sub    $0x4,%esp
  800ca4:	6a 07                	push   $0x7
  800ca6:	68 00 f0 bf ee       	push   $0xeebff000
  800cab:	6a 00                	push   $0x0
  800cad:	e8 dc fe ff ff       	call   800b8e <sys_page_alloc>
		if (r < 0) return;
  800cb2:	83 c4 10             	add    $0x10,%esp
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	78 e6                	js     800c9f <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800cb9:	83 ec 08             	sub    $0x8,%esp
  800cbc:	68 d1 0c 80 00       	push   $0x800cd1
  800cc1:	6a 00                	push   $0x0
  800cc3:	e8 56 ff ff ff       	call   800c1e <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	79 c8                	jns    800c97 <set_pgfault_handler+0xf>
  800ccf:	eb ce                	jmp    800c9f <set_pgfault_handler+0x17>

00800cd1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800cd1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800cd2:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800cd7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800cd9:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  800cdc:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  800ce0:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800ce4:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  800ce7:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  800ce9:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  800ced:	58                   	pop    %eax
	popl %eax
  800cee:	58                   	pop    %eax
	popal
  800cef:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  800cf0:	83 c4 04             	add    $0x4,%esp
	popfl
  800cf3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  800cf4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  800cf5:	c3                   	ret    
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	66 90                	xchg   %ax,%ax
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
  800cfe:	66 90                	xchg   %ax,%ax

00800d00 <__udivdi3>:
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 1c             	sub    $0x1c,%esp
  800d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d0b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d13:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d17:	85 d2                	test   %edx,%edx
  800d19:	75 35                	jne    800d50 <__udivdi3+0x50>
  800d1b:	39 f3                	cmp    %esi,%ebx
  800d1d:	0f 87 bd 00 00 00    	ja     800de0 <__udivdi3+0xe0>
  800d23:	85 db                	test   %ebx,%ebx
  800d25:	89 d9                	mov    %ebx,%ecx
  800d27:	75 0b                	jne    800d34 <__udivdi3+0x34>
  800d29:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2e:	31 d2                	xor    %edx,%edx
  800d30:	f7 f3                	div    %ebx
  800d32:	89 c1                	mov    %eax,%ecx
  800d34:	31 d2                	xor    %edx,%edx
  800d36:	89 f0                	mov    %esi,%eax
  800d38:	f7 f1                	div    %ecx
  800d3a:	89 c6                	mov    %eax,%esi
  800d3c:	89 e8                	mov    %ebp,%eax
  800d3e:	89 f7                	mov    %esi,%edi
  800d40:	f7 f1                	div    %ecx
  800d42:	89 fa                	mov    %edi,%edx
  800d44:	83 c4 1c             	add    $0x1c,%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    
  800d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d50:	39 f2                	cmp    %esi,%edx
  800d52:	77 7c                	ja     800dd0 <__udivdi3+0xd0>
  800d54:	0f bd fa             	bsr    %edx,%edi
  800d57:	83 f7 1f             	xor    $0x1f,%edi
  800d5a:	0f 84 98 00 00 00    	je     800df8 <__udivdi3+0xf8>
  800d60:	89 f9                	mov    %edi,%ecx
  800d62:	b8 20 00 00 00       	mov    $0x20,%eax
  800d67:	29 f8                	sub    %edi,%eax
  800d69:	d3 e2                	shl    %cl,%edx
  800d6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d6f:	89 c1                	mov    %eax,%ecx
  800d71:	89 da                	mov    %ebx,%edx
  800d73:	d3 ea                	shr    %cl,%edx
  800d75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d79:	09 d1                	or     %edx,%ecx
  800d7b:	89 f2                	mov    %esi,%edx
  800d7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d81:	89 f9                	mov    %edi,%ecx
  800d83:	d3 e3                	shl    %cl,%ebx
  800d85:	89 c1                	mov    %eax,%ecx
  800d87:	d3 ea                	shr    %cl,%edx
  800d89:	89 f9                	mov    %edi,%ecx
  800d8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d8f:	d3 e6                	shl    %cl,%esi
  800d91:	89 eb                	mov    %ebp,%ebx
  800d93:	89 c1                	mov    %eax,%ecx
  800d95:	d3 eb                	shr    %cl,%ebx
  800d97:	09 de                	or     %ebx,%esi
  800d99:	89 f0                	mov    %esi,%eax
  800d9b:	f7 74 24 08          	divl   0x8(%esp)
  800d9f:	89 d6                	mov    %edx,%esi
  800da1:	89 c3                	mov    %eax,%ebx
  800da3:	f7 64 24 0c          	mull   0xc(%esp)
  800da7:	39 d6                	cmp    %edx,%esi
  800da9:	72 0c                	jb     800db7 <__udivdi3+0xb7>
  800dab:	89 f9                	mov    %edi,%ecx
  800dad:	d3 e5                	shl    %cl,%ebp
  800daf:	39 c5                	cmp    %eax,%ebp
  800db1:	73 5d                	jae    800e10 <__udivdi3+0x110>
  800db3:	39 d6                	cmp    %edx,%esi
  800db5:	75 59                	jne    800e10 <__udivdi3+0x110>
  800db7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dba:	31 ff                	xor    %edi,%edi
  800dbc:	89 fa                	mov    %edi,%edx
  800dbe:	83 c4 1c             	add    $0x1c,%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    
  800dc6:	8d 76 00             	lea    0x0(%esi),%esi
  800dc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800dd0:	31 ff                	xor    %edi,%edi
  800dd2:	31 c0                	xor    %eax,%eax
  800dd4:	89 fa                	mov    %edi,%edx
  800dd6:	83 c4 1c             	add    $0x1c,%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    
  800dde:	66 90                	xchg   %ax,%ax
  800de0:	31 ff                	xor    %edi,%edi
  800de2:	89 e8                	mov    %ebp,%eax
  800de4:	89 f2                	mov    %esi,%edx
  800de6:	f7 f3                	div    %ebx
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	39 f2                	cmp    %esi,%edx
  800dfa:	72 06                	jb     800e02 <__udivdi3+0x102>
  800dfc:	31 c0                	xor    %eax,%eax
  800dfe:	39 eb                	cmp    %ebp,%ebx
  800e00:	77 d2                	ja     800dd4 <__udivdi3+0xd4>
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	eb cb                	jmp    800dd4 <__udivdi3+0xd4>
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	31 ff                	xor    %edi,%edi
  800e14:	eb be                	jmp    800dd4 <__udivdi3+0xd4>
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	66 90                	xchg   %ax,%ax
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	66 90                	xchg   %ax,%ax
  800e1e:	66 90                	xchg   %ax,%ax

00800e20 <__umoddi3>:
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 1c             	sub    $0x1c,%esp
  800e27:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e2b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e2f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e37:	85 ed                	test   %ebp,%ebp
  800e39:	89 f0                	mov    %esi,%eax
  800e3b:	89 da                	mov    %ebx,%edx
  800e3d:	75 19                	jne    800e58 <__umoddi3+0x38>
  800e3f:	39 df                	cmp    %ebx,%edi
  800e41:	0f 86 b1 00 00 00    	jbe    800ef8 <__umoddi3+0xd8>
  800e47:	f7 f7                	div    %edi
  800e49:	89 d0                	mov    %edx,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	83 c4 1c             	add    $0x1c,%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
  800e55:	8d 76 00             	lea    0x0(%esi),%esi
  800e58:	39 dd                	cmp    %ebx,%ebp
  800e5a:	77 f1                	ja     800e4d <__umoddi3+0x2d>
  800e5c:	0f bd cd             	bsr    %ebp,%ecx
  800e5f:	83 f1 1f             	xor    $0x1f,%ecx
  800e62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e66:	0f 84 b4 00 00 00    	je     800f20 <__umoddi3+0x100>
  800e6c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e71:	89 c2                	mov    %eax,%edx
  800e73:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e77:	29 c2                	sub    %eax,%edx
  800e79:	89 c1                	mov    %eax,%ecx
  800e7b:	89 f8                	mov    %edi,%eax
  800e7d:	d3 e5                	shl    %cl,%ebp
  800e7f:	89 d1                	mov    %edx,%ecx
  800e81:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e85:	d3 e8                	shr    %cl,%eax
  800e87:	09 c5                	or     %eax,%ebp
  800e89:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e8d:	89 c1                	mov    %eax,%ecx
  800e8f:	d3 e7                	shl    %cl,%edi
  800e91:	89 d1                	mov    %edx,%ecx
  800e93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e97:	89 df                	mov    %ebx,%edi
  800e99:	d3 ef                	shr    %cl,%edi
  800e9b:	89 c1                	mov    %eax,%ecx
  800e9d:	89 f0                	mov    %esi,%eax
  800e9f:	d3 e3                	shl    %cl,%ebx
  800ea1:	89 d1                	mov    %edx,%ecx
  800ea3:	89 fa                	mov    %edi,%edx
  800ea5:	d3 e8                	shr    %cl,%eax
  800ea7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eac:	09 d8                	or     %ebx,%eax
  800eae:	f7 f5                	div    %ebp
  800eb0:	d3 e6                	shl    %cl,%esi
  800eb2:	89 d1                	mov    %edx,%ecx
  800eb4:	f7 64 24 08          	mull   0x8(%esp)
  800eb8:	39 d1                	cmp    %edx,%ecx
  800eba:	89 c3                	mov    %eax,%ebx
  800ebc:	89 d7                	mov    %edx,%edi
  800ebe:	72 06                	jb     800ec6 <__umoddi3+0xa6>
  800ec0:	75 0e                	jne    800ed0 <__umoddi3+0xb0>
  800ec2:	39 c6                	cmp    %eax,%esi
  800ec4:	73 0a                	jae    800ed0 <__umoddi3+0xb0>
  800ec6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800eca:	19 ea                	sbb    %ebp,%edx
  800ecc:	89 d7                	mov    %edx,%edi
  800ece:	89 c3                	mov    %eax,%ebx
  800ed0:	89 ca                	mov    %ecx,%edx
  800ed2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ed7:	29 de                	sub    %ebx,%esi
  800ed9:	19 fa                	sbb    %edi,%edx
  800edb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800edf:	89 d0                	mov    %edx,%eax
  800ee1:	d3 e0                	shl    %cl,%eax
  800ee3:	89 d9                	mov    %ebx,%ecx
  800ee5:	d3 ee                	shr    %cl,%esi
  800ee7:	d3 ea                	shr    %cl,%edx
  800ee9:	09 f0                	or     %esi,%eax
  800eeb:	83 c4 1c             	add    $0x1c,%esp
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    
  800ef3:	90                   	nop
  800ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef8:	85 ff                	test   %edi,%edi
  800efa:	89 f9                	mov    %edi,%ecx
  800efc:	75 0b                	jne    800f09 <__umoddi3+0xe9>
  800efe:	b8 01 00 00 00       	mov    $0x1,%eax
  800f03:	31 d2                	xor    %edx,%edx
  800f05:	f7 f7                	div    %edi
  800f07:	89 c1                	mov    %eax,%ecx
  800f09:	89 d8                	mov    %ebx,%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	f7 f1                	div    %ecx
  800f0f:	89 f0                	mov    %esi,%eax
  800f11:	f7 f1                	div    %ecx
  800f13:	e9 31 ff ff ff       	jmp    800e49 <__umoddi3+0x29>
  800f18:	90                   	nop
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	39 dd                	cmp    %ebx,%ebp
  800f22:	72 08                	jb     800f2c <__umoddi3+0x10c>
  800f24:	39 f7                	cmp    %esi,%edi
  800f26:	0f 87 21 ff ff ff    	ja     800e4d <__umoddi3+0x2d>
  800f2c:	89 da                	mov    %ebx,%edx
  800f2e:	89 f0                	mov    %esi,%eax
  800f30:	29 f8                	sub    %edi,%eax
  800f32:	19 ea                	sbb    %ebp,%edx
  800f34:	e9 14 ff ff ff       	jmp    800e4d <__umoddi3+0x2d>
