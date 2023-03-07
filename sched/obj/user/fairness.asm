
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 a9 0a 00 00       	call   800ae9 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 80 	cmpl   $0xeec00080,0x802004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 d0 0b 00 00       	call   800c2e <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 c0 0f 80 00       	push   $0x800fc0
  80006a:	e8 23 01 00 00       	call   800192 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 d1 0f 80 00       	push   $0x800fd1
  800083:	e8 0a 01 00 00       	call   800192 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 ee 0b 00 00       	call   800c8a <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000ac:	e8 38 0a 00 00       	call   800ae9 <sys_getenvid>
	if (id >= 0)
  8000b1:	85 c0                	test   %eax,%eax
  8000b3:	78 12                	js     8000c7 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8000b5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ba:	c1 e0 07             	shl    $0x7,%eax
  8000bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c7:	85 db                	test   %ebx,%ebx
  8000c9:	7e 07                	jle    8000d2 <libmain+0x31>
		binaryname = argv[0];
  8000cb:	8b 06                	mov    (%esi),%eax
  8000cd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	e8 57 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000dc:	e8 0a 00 00 00       	call   8000eb <exit>
}
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f1:	6a 00                	push   $0x0
  8000f3:	e8 cf 09 00 00       	call   800ac7 <sys_env_destroy>
}
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	53                   	push   %ebx
  800101:	83 ec 04             	sub    $0x4,%esp
  800104:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800107:	8b 13                	mov    (%ebx),%edx
  800109:	8d 42 01             	lea    0x1(%edx),%eax
  80010c:	89 03                	mov    %eax,(%ebx)
  80010e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800111:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800115:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011a:	74 09                	je     800125 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800123:	c9                   	leave  
  800124:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	68 ff 00 00 00       	push   $0xff
  80012d:	8d 43 08             	lea    0x8(%ebx),%eax
  800130:	50                   	push   %eax
  800131:	e8 47 09 00 00       	call   800a7d <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	eb db                	jmp    80011c <putch+0x1f>

00800141 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800151:	00 00 00 
	b.cnt = 0;
  800154:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016a:	50                   	push   %eax
  80016b:	68 fd 00 80 00       	push   $0x8000fd
  800170:	e8 86 01 00 00       	call   8002fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800175:	83 c4 08             	add    $0x8,%esp
  800178:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800184:	50                   	push   %eax
  800185:	e8 f3 08 00 00       	call   800a7d <sys_cputs>

	return b.cnt;
}
  80018a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800190:	c9                   	leave  
  800191:	c3                   	ret    

00800192 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800198:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019b:	50                   	push   %eax
  80019c:	ff 75 08             	pushl  0x8(%ebp)
  80019f:	e8 9d ff ff ff       	call   800141 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 1c             	sub    $0x1c,%esp
  8001af:	89 c7                	mov    %eax,%edi
  8001b1:	89 d6                	mov    %edx,%esi
  8001b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ca:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cd:	39 d3                	cmp    %edx,%ebx
  8001cf:	72 05                	jb     8001d6 <printnum+0x30>
  8001d1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d4:	77 7a                	ja     800250 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	ff 75 18             	pushl  0x18(%ebp)
  8001dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8001df:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e2:	53                   	push   %ebx
  8001e3:	ff 75 10             	pushl  0x10(%ebp)
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f5:	e8 76 0b 00 00       	call   800d70 <__udivdi3>
  8001fa:	83 c4 18             	add    $0x18,%esp
  8001fd:	52                   	push   %edx
  8001fe:	50                   	push   %eax
  8001ff:	89 f2                	mov    %esi,%edx
  800201:	89 f8                	mov    %edi,%eax
  800203:	e8 9e ff ff ff       	call   8001a6 <printnum>
  800208:	83 c4 20             	add    $0x20,%esp
  80020b:	eb 13                	jmp    800220 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	56                   	push   %esi
  800211:	ff 75 18             	pushl  0x18(%ebp)
  800214:	ff d7                	call   *%edi
  800216:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f ed                	jg     80020d <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 58 0c 00 00       	call   800e90 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 f2 0f 80 00 	movsbl 0x800ff2(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    
  800250:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800253:	eb c4                	jmp    800219 <printnum+0x73>

00800255 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800258:	83 fa 01             	cmp    $0x1,%edx
  80025b:	7e 0e                	jle    80026b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025d:	8b 10                	mov    (%eax),%edx
  80025f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 02                	mov    (%edx),%eax
  800266:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    
	else if (lflag)
  80026b:	85 d2                	test   %edx,%edx
  80026d:	75 10                	jne    80027f <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  80026f:	8b 10                	mov    (%eax),%edx
  800271:	8d 4a 04             	lea    0x4(%edx),%ecx
  800274:	89 08                	mov    %ecx,(%eax)
  800276:	8b 02                	mov    (%edx),%eax
  800278:	ba 00 00 00 00       	mov    $0x0,%edx
  80027d:	eb ea                	jmp    800269 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 04             	lea    0x4(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	ba 00 00 00 00       	mov    $0x0,%edx
  80028d:	eb da                	jmp    800269 <getuint+0x14>

0080028f <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800292:	83 fa 01             	cmp    $0x1,%edx
  800295:	7e 0e                	jle    8002a5 <getint+0x16>
		return va_arg(*ap, long long);
  800297:	8b 10                	mov    (%eax),%edx
  800299:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029c:	89 08                	mov    %ecx,(%eax)
  80029e:	8b 02                	mov    (%edx),%eax
  8002a0:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    
	else if (lflag)
  8002a5:	85 d2                	test   %edx,%edx
  8002a7:	75 0c                	jne    8002b5 <getint+0x26>
		return va_arg(*ap, int);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	99                   	cltd   
  8002b3:	eb ee                	jmp    8002a3 <getint+0x14>
		return va_arg(*ap, long);
  8002b5:	8b 10                	mov    (%eax),%edx
  8002b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ba:	89 08                	mov    %ecx,(%eax)
  8002bc:	8b 02                	mov    (%edx),%eax
  8002be:	99                   	cltd   
  8002bf:	eb e2                	jmp    8002a3 <getint+0x14>

008002c1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d0:	73 0a                	jae    8002dc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002da:	88 02                	mov    %al,(%edx)
}
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <printfmt>:
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e7:	50                   	push   %eax
  8002e8:	ff 75 10             	pushl  0x10(%ebp)
  8002eb:	ff 75 0c             	pushl  0xc(%ebp)
  8002ee:	ff 75 08             	pushl  0x8(%ebp)
  8002f1:	e8 05 00 00 00       	call   8002fb <vprintfmt>
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	c9                   	leave  
  8002fa:	c3                   	ret    

008002fb <vprintfmt>:
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	57                   	push   %edi
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
  800301:	83 ec 2c             	sub    $0x2c,%esp
  800304:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800307:	8b 75 0c             	mov    0xc(%ebp),%esi
  80030a:	89 f7                	mov    %esi,%edi
  80030c:	89 de                	mov    %ebx,%esi
  80030e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800311:	e9 9e 02 00 00       	jmp    8005b4 <vprintfmt+0x2b9>
		padc = ' ';
  800316:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80031a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800321:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800328:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80032f:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8d 43 01             	lea    0x1(%ebx),%eax
  800337:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033a:	0f b6 0b             	movzbl (%ebx),%ecx
  80033d:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800340:	3c 55                	cmp    $0x55,%al
  800342:	0f 87 e8 02 00 00    	ja     800630 <vprintfmt+0x335>
  800348:	0f b6 c0             	movzbl %al,%eax
  80034b:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  800352:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800355:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800359:	eb d9                	jmp    800334 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  80035e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800362:	eb d0                	jmp    800334 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800364:	0f b6 c9             	movzbl %cl,%ecx
  800367:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80036a:	b8 00 00 00 00       	mov    $0x0,%eax
  80036f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800372:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800375:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800379:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80037c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037f:	83 fa 09             	cmp    $0x9,%edx
  800382:	77 52                	ja     8003d6 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800384:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800387:	eb e9                	jmp    800372 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800389:	8b 45 14             	mov    0x14(%ebp),%eax
  80038c:	8d 48 04             	lea    0x4(%eax),%ecx
  80038f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800392:	8b 00                	mov    (%eax),%eax
  800394:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80039a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039e:	79 94                	jns    800334 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ad:	eb 85                	jmp    800334 <vprintfmt+0x39>
  8003af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b9:	0f 49 c8             	cmovns %eax,%ecx
  8003bc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003c2:	e9 6d ff ff ff       	jmp    800334 <vprintfmt+0x39>
  8003c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003ca:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d1:	e9 5e ff ff ff       	jmp    800334 <vprintfmt+0x39>
  8003d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003dc:	eb bc                	jmp    80039a <vprintfmt+0x9f>
			lflag++;
  8003de:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003e4:	e9 4b ff ff ff       	jmp    800334 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 50 04             	lea    0x4(%eax),%edx
  8003ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f2:	83 ec 08             	sub    $0x8,%esp
  8003f5:	57                   	push   %edi
  8003f6:	ff 30                	pushl  (%eax)
  8003f8:	ff d6                	call   *%esi
			break;
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	e9 af 01 00 00       	jmp    8005b1 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 50 04             	lea    0x4(%eax),%edx
  800408:	89 55 14             	mov    %edx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	99                   	cltd   
  80040e:	31 d0                	xor    %edx,%eax
  800410:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800412:	83 f8 08             	cmp    $0x8,%eax
  800415:	7f 20                	jg     800437 <vprintfmt+0x13c>
  800417:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80041e:	85 d2                	test   %edx,%edx
  800420:	74 15                	je     800437 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800422:	52                   	push   %edx
  800423:	68 13 10 80 00       	push   $0x801013
  800428:	57                   	push   %edi
  800429:	56                   	push   %esi
  80042a:	e8 af fe ff ff       	call   8002de <printfmt>
  80042f:	83 c4 10             	add    $0x10,%esp
  800432:	e9 7a 01 00 00       	jmp    8005b1 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800437:	50                   	push   %eax
  800438:	68 0a 10 80 00       	push   $0x80100a
  80043d:	57                   	push   %edi
  80043e:	56                   	push   %esi
  80043f:	e8 9a fe ff ff       	call   8002de <printfmt>
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	e9 65 01 00 00       	jmp    8005b1 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	8d 50 04             	lea    0x4(%eax),%edx
  800452:	89 55 14             	mov    %edx,0x14(%ebp)
  800455:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800457:	85 db                	test   %ebx,%ebx
  800459:	b8 03 10 80 00       	mov    $0x801003,%eax
  80045e:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  800461:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800465:	0f 8e bd 00 00 00    	jle    800528 <vprintfmt+0x22d>
  80046b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046f:	75 0e                	jne    80047f <vprintfmt+0x184>
  800471:	89 75 08             	mov    %esi,0x8(%ebp)
  800474:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800477:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80047a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80047d:	eb 6d                	jmp    8004ec <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	ff 75 d0             	pushl  -0x30(%ebp)
  800485:	53                   	push   %ebx
  800486:	e8 4d 02 00 00       	call   8006d8 <strnlen>
  80048b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048e:	29 c1                	sub    %eax,%ecx
  800490:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800493:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800496:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049d:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004a0:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a2:	eb 0f                	jmp    8004b3 <vprintfmt+0x1b8>
					putch(padc, putdat);
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	57                   	push   %edi
  8004a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ab:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	85 db                	test   %ebx,%ebx
  8004b5:	7f ed                	jg     8004a4 <vprintfmt+0x1a9>
  8004b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004ba:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004bd:	85 c9                	test   %ecx,%ecx
  8004bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c4:	0f 49 c1             	cmovns %ecx,%eax
  8004c7:	29 c1                	sub    %eax,%ecx
  8004c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cf:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004d2:	89 cf                	mov    %ecx,%edi
  8004d4:	eb 16                	jmp    8004ec <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004da:	75 31                	jne    80050d <vprintfmt+0x212>
					putch(ch, putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	ff 75 0c             	pushl  0xc(%ebp)
  8004e2:	50                   	push   %eax
  8004e3:	ff 55 08             	call   *0x8(%ebp)
  8004e6:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e9:	83 ef 01             	sub    $0x1,%edi
  8004ec:	83 c3 01             	add    $0x1,%ebx
  8004ef:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8004f3:	0f be c2             	movsbl %dl,%eax
  8004f6:	85 c0                	test   %eax,%eax
  8004f8:	74 50                	je     80054a <vprintfmt+0x24f>
  8004fa:	85 f6                	test   %esi,%esi
  8004fc:	78 d8                	js     8004d6 <vprintfmt+0x1db>
  8004fe:	83 ee 01             	sub    $0x1,%esi
  800501:	79 d3                	jns    8004d6 <vprintfmt+0x1db>
  800503:	89 fb                	mov    %edi,%ebx
  800505:	8b 75 08             	mov    0x8(%ebp),%esi
  800508:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80050b:	eb 37                	jmp    800544 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  80050d:	0f be d2             	movsbl %dl,%edx
  800510:	83 ea 20             	sub    $0x20,%edx
  800513:	83 fa 5e             	cmp    $0x5e,%edx
  800516:	76 c4                	jbe    8004dc <vprintfmt+0x1e1>
					putch('?', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	ff 75 0c             	pushl  0xc(%ebp)
  80051e:	6a 3f                	push   $0x3f
  800520:	ff 55 08             	call   *0x8(%ebp)
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	eb c1                	jmp    8004e9 <vprintfmt+0x1ee>
  800528:	89 75 08             	mov    %esi,0x8(%ebp)
  80052b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052e:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800531:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800534:	eb b6                	jmp    8004ec <vprintfmt+0x1f1>
				putch(' ', putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	57                   	push   %edi
  80053a:	6a 20                	push   $0x20
  80053c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80053e:	83 eb 01             	sub    $0x1,%ebx
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	85 db                	test   %ebx,%ebx
  800546:	7f ee                	jg     800536 <vprintfmt+0x23b>
  800548:	eb 67                	jmp    8005b1 <vprintfmt+0x2b6>
  80054a:	89 fb                	mov    %edi,%ebx
  80054c:	8b 75 08             	mov    0x8(%ebp),%esi
  80054f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800552:	eb f0                	jmp    800544 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800554:	8d 45 14             	lea    0x14(%ebp),%eax
  800557:	e8 33 fd ff ff       	call   80028f <getint>
  80055c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800562:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800567:	85 d2                	test   %edx,%edx
  800569:	79 2c                	jns    800597 <vprintfmt+0x29c>
				putch('-', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	57                   	push   %edi
  80056f:	6a 2d                	push   $0x2d
  800571:	ff d6                	call   *%esi
				num = -(long long) num;
  800573:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800576:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800579:	f7 d8                	neg    %eax
  80057b:	83 d2 00             	adc    $0x0,%edx
  80057e:	f7 da                	neg    %edx
  800580:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800583:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800588:	eb 0d                	jmp    800597 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80058a:	8d 45 14             	lea    0x14(%ebp),%eax
  80058d:	e8 c3 fc ff ff       	call   800255 <getuint>
			base = 10;
  800592:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800597:	83 ec 0c             	sub    $0xc,%esp
  80059a:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80059e:	53                   	push   %ebx
  80059f:	ff 75 e0             	pushl  -0x20(%ebp)
  8005a2:	51                   	push   %ecx
  8005a3:	52                   	push   %edx
  8005a4:	50                   	push   %eax
  8005a5:	89 fa                	mov    %edi,%edx
  8005a7:	89 f0                	mov    %esi,%eax
  8005a9:	e8 f8 fb ff ff       	call   8001a6 <printnum>
			break;
  8005ae:	83 c4 20             	add    $0x20,%esp
{
  8005b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b4:	83 c3 01             	add    $0x1,%ebx
  8005b7:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005bb:	83 f8 25             	cmp    $0x25,%eax
  8005be:	0f 84 52 fd ff ff    	je     800316 <vprintfmt+0x1b>
			if (ch == '\0')
  8005c4:	85 c0                	test   %eax,%eax
  8005c6:	0f 84 84 00 00 00    	je     800650 <vprintfmt+0x355>
			putch(ch, putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	57                   	push   %edi
  8005d0:	50                   	push   %eax
  8005d1:	ff d6                	call   *%esi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb dc                	jmp    8005b4 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8005d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005db:	e8 75 fc ff ff       	call   800255 <getuint>
			base = 8;
  8005e0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e5:	eb b0                	jmp    800597 <vprintfmt+0x29c>
			putch('0', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	57                   	push   %edi
  8005eb:	6a 30                	push   $0x30
  8005ed:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ef:	83 c4 08             	add    $0x8,%esp
  8005f2:	57                   	push   %edi
  8005f3:	6a 78                	push   $0x78
  8005f5:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800607:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80060a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060f:	eb 86                	jmp    800597 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800611:	8d 45 14             	lea    0x14(%ebp),%eax
  800614:	e8 3c fc ff ff       	call   800255 <getuint>
			base = 16;
  800619:	b9 10 00 00 00       	mov    $0x10,%ecx
  80061e:	e9 74 ff ff ff       	jmp    800597 <vprintfmt+0x29c>
			putch(ch, putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	57                   	push   %edi
  800627:	6a 25                	push   $0x25
  800629:	ff d6                	call   *%esi
			break;
  80062b:	83 c4 10             	add    $0x10,%esp
  80062e:	eb 81                	jmp    8005b1 <vprintfmt+0x2b6>
			putch('%', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	57                   	push   %edi
  800634:	6a 25                	push   $0x25
  800636:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	89 d8                	mov    %ebx,%eax
  80063d:	eb 03                	jmp    800642 <vprintfmt+0x347>
  80063f:	83 e8 01             	sub    $0x1,%eax
  800642:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800646:	75 f7                	jne    80063f <vprintfmt+0x344>
  800648:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80064b:	e9 61 ff ff ff       	jmp    8005b1 <vprintfmt+0x2b6>
}
  800650:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800653:	5b                   	pop    %ebx
  800654:	5e                   	pop    %esi
  800655:	5f                   	pop    %edi
  800656:	5d                   	pop    %ebp
  800657:	c3                   	ret    

00800658 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	83 ec 18             	sub    $0x18,%esp
  80065e:	8b 45 08             	mov    0x8(%ebp),%eax
  800661:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800664:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800667:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800675:	85 c0                	test   %eax,%eax
  800677:	74 26                	je     80069f <vsnprintf+0x47>
  800679:	85 d2                	test   %edx,%edx
  80067b:	7e 22                	jle    80069f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067d:	ff 75 14             	pushl  0x14(%ebp)
  800680:	ff 75 10             	pushl  0x10(%ebp)
  800683:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800686:	50                   	push   %eax
  800687:	68 c1 02 80 00       	push   $0x8002c1
  80068c:	e8 6a fc ff ff       	call   8002fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800691:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800694:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	83 c4 10             	add    $0x10,%esp
}
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    
		return -E_INVAL;
  80069f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a4:	eb f7                	jmp    80069d <vsnprintf+0x45>

008006a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
  8006a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ac:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006af:	50                   	push   %eax
  8006b0:	ff 75 10             	pushl  0x10(%ebp)
  8006b3:	ff 75 0c             	pushl  0xc(%ebp)
  8006b6:	ff 75 08             	pushl  0x8(%ebp)
  8006b9:	e8 9a ff ff ff       	call   800658 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006be:	c9                   	leave  
  8006bf:	c3                   	ret    

008006c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cb:	eb 03                	jmp    8006d0 <strlen+0x10>
		n++;
  8006cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d4:	75 f7                	jne    8006cd <strlen+0xd>
	return n;
}
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e6:	eb 03                	jmp    8006eb <strnlen+0x13>
		n++;
  8006e8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006eb:	39 d0                	cmp    %edx,%eax
  8006ed:	74 06                	je     8006f5 <strnlen+0x1d>
  8006ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006f3:	75 f3                	jne    8006e8 <strnlen+0x10>
	return n;
}
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	53                   	push   %ebx
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800701:	89 c2                	mov    %eax,%edx
  800703:	83 c1 01             	add    $0x1,%ecx
  800706:	83 c2 01             	add    $0x1,%edx
  800709:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800710:	84 db                	test   %bl,%bl
  800712:	75 ef                	jne    800703 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800714:	5b                   	pop    %ebx
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	53                   	push   %ebx
  80071b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071e:	53                   	push   %ebx
  80071f:	e8 9c ff ff ff       	call   8006c0 <strlen>
  800724:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	01 d8                	add    %ebx,%eax
  80072c:	50                   	push   %eax
  80072d:	e8 c5 ff ff ff       	call   8006f7 <strcpy>
	return dst;
}
  800732:	89 d8                	mov    %ebx,%eax
  800734:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	56                   	push   %esi
  80073d:	53                   	push   %ebx
  80073e:	8b 75 08             	mov    0x8(%ebp),%esi
  800741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800744:	89 f3                	mov    %esi,%ebx
  800746:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800749:	89 f2                	mov    %esi,%edx
  80074b:	eb 0f                	jmp    80075c <strncpy+0x23>
		*dst++ = *src;
  80074d:	83 c2 01             	add    $0x1,%edx
  800750:	0f b6 01             	movzbl (%ecx),%eax
  800753:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800756:	80 39 01             	cmpb   $0x1,(%ecx)
  800759:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80075c:	39 da                	cmp    %ebx,%edx
  80075e:	75 ed                	jne    80074d <strncpy+0x14>
	}
	return ret;
}
  800760:	89 f0                	mov    %esi,%eax
  800762:	5b                   	pop    %ebx
  800763:	5e                   	pop    %esi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	56                   	push   %esi
  80076a:	53                   	push   %ebx
  80076b:	8b 75 08             	mov    0x8(%ebp),%esi
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800771:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800774:	89 f0                	mov    %esi,%eax
  800776:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80077a:	85 c9                	test   %ecx,%ecx
  80077c:	75 0b                	jne    800789 <strlcpy+0x23>
  80077e:	eb 17                	jmp    800797 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800780:	83 c2 01             	add    $0x1,%edx
  800783:	83 c0 01             	add    $0x1,%eax
  800786:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800789:	39 d8                	cmp    %ebx,%eax
  80078b:	74 07                	je     800794 <strlcpy+0x2e>
  80078d:	0f b6 0a             	movzbl (%edx),%ecx
  800790:	84 c9                	test   %cl,%cl
  800792:	75 ec                	jne    800780 <strlcpy+0x1a>
		*dst = '\0';
  800794:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800797:	29 f0                	sub    %esi,%eax
}
  800799:	5b                   	pop    %ebx
  80079a:	5e                   	pop    %esi
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a6:	eb 06                	jmp    8007ae <strcmp+0x11>
		p++, q++;
  8007a8:	83 c1 01             	add    $0x1,%ecx
  8007ab:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007ae:	0f b6 01             	movzbl (%ecx),%eax
  8007b1:	84 c0                	test   %al,%al
  8007b3:	74 04                	je     8007b9 <strcmp+0x1c>
  8007b5:	3a 02                	cmp    (%edx),%al
  8007b7:	74 ef                	je     8007a8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b9:	0f b6 c0             	movzbl %al,%eax
  8007bc:	0f b6 12             	movzbl (%edx),%edx
  8007bf:	29 d0                	sub    %edx,%eax
}
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cd:	89 c3                	mov    %eax,%ebx
  8007cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d2:	eb 06                	jmp    8007da <strncmp+0x17>
		n--, p++, q++;
  8007d4:	83 c0 01             	add    $0x1,%eax
  8007d7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007da:	39 d8                	cmp    %ebx,%eax
  8007dc:	74 16                	je     8007f4 <strncmp+0x31>
  8007de:	0f b6 08             	movzbl (%eax),%ecx
  8007e1:	84 c9                	test   %cl,%cl
  8007e3:	74 04                	je     8007e9 <strncmp+0x26>
  8007e5:	3a 0a                	cmp    (%edx),%cl
  8007e7:	74 eb                	je     8007d4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e9:	0f b6 00             	movzbl (%eax),%eax
  8007ec:	0f b6 12             	movzbl (%edx),%edx
  8007ef:	29 d0                	sub    %edx,%eax
}
  8007f1:	5b                   	pop    %ebx
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    
		return 0;
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f9:	eb f6                	jmp    8007f1 <strncmp+0x2e>

008007fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800805:	0f b6 10             	movzbl (%eax),%edx
  800808:	84 d2                	test   %dl,%dl
  80080a:	74 09                	je     800815 <strchr+0x1a>
		if (*s == c)
  80080c:	38 ca                	cmp    %cl,%dl
  80080e:	74 0a                	je     80081a <strchr+0x1f>
	for (; *s; s++)
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	eb f0                	jmp    800805 <strchr+0xa>
			return (char *) s;
	return 0;
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800826:	eb 03                	jmp    80082b <strfind+0xf>
  800828:	83 c0 01             	add    $0x1,%eax
  80082b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80082e:	38 ca                	cmp    %cl,%dl
  800830:	74 04                	je     800836 <strfind+0x1a>
  800832:	84 d2                	test   %dl,%dl
  800834:	75 f2                	jne    800828 <strfind+0xc>
			break;
	return (char *) s;
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	57                   	push   %edi
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	8b 55 08             	mov    0x8(%ebp),%edx
  800841:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800844:	85 c9                	test   %ecx,%ecx
  800846:	74 12                	je     80085a <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800848:	f6 c2 03             	test   $0x3,%dl
  80084b:	75 05                	jne    800852 <memset+0x1a>
  80084d:	f6 c1 03             	test   $0x3,%cl
  800850:	74 0f                	je     800861 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800852:	89 d7                	mov    %edx,%edi
  800854:	8b 45 0c             	mov    0xc(%ebp),%eax
  800857:	fc                   	cld    
  800858:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80085a:	89 d0                	mov    %edx,%eax
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5f                   	pop    %edi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    
		c &= 0xFF;
  800861:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800865:	89 d8                	mov    %ebx,%eax
  800867:	c1 e0 08             	shl    $0x8,%eax
  80086a:	89 df                	mov    %ebx,%edi
  80086c:	c1 e7 18             	shl    $0x18,%edi
  80086f:	89 de                	mov    %ebx,%esi
  800871:	c1 e6 10             	shl    $0x10,%esi
  800874:	09 f7                	or     %esi,%edi
  800876:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800878:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80087d:	89 d7                	mov    %edx,%edi
  80087f:	fc                   	cld    
  800880:	f3 ab                	rep stos %eax,%es:(%edi)
  800882:	eb d6                	jmp    80085a <memset+0x22>

00800884 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	57                   	push   %edi
  800888:	56                   	push   %esi
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800892:	39 c6                	cmp    %eax,%esi
  800894:	73 35                	jae    8008cb <memmove+0x47>
  800896:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800899:	39 c2                	cmp    %eax,%edx
  80089b:	76 2e                	jbe    8008cb <memmove+0x47>
		s += n;
		d += n;
  80089d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a0:	89 d6                	mov    %edx,%esi
  8008a2:	09 fe                	or     %edi,%esi
  8008a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008aa:	74 0c                	je     8008b8 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ac:	83 ef 01             	sub    $0x1,%edi
  8008af:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008b2:	fd                   	std    
  8008b3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008b5:	fc                   	cld    
  8008b6:	eb 21                	jmp    8008d9 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b8:	f6 c1 03             	test   $0x3,%cl
  8008bb:	75 ef                	jne    8008ac <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008bd:	83 ef 04             	sub    $0x4,%edi
  8008c0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008c6:	fd                   	std    
  8008c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c9:	eb ea                	jmp    8008b5 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cb:	89 f2                	mov    %esi,%edx
  8008cd:	09 c2                	or     %eax,%edx
  8008cf:	f6 c2 03             	test   $0x3,%dl
  8008d2:	74 09                	je     8008dd <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d4:	89 c7                	mov    %eax,%edi
  8008d6:	fc                   	cld    
  8008d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008d9:	5e                   	pop    %esi
  8008da:	5f                   	pop    %edi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 f2                	jne    8008d4 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008e2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008e5:	89 c7                	mov    %eax,%edi
  8008e7:	fc                   	cld    
  8008e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ea:	eb ed                	jmp    8008d9 <memmove+0x55>

008008ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ef:	ff 75 10             	pushl  0x10(%ebp)
  8008f2:	ff 75 0c             	pushl  0xc(%ebp)
  8008f5:	ff 75 08             	pushl  0x8(%ebp)
  8008f8:	e8 87 ff ff ff       	call   800884 <memmove>
}
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090a:	89 c6                	mov    %eax,%esi
  80090c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090f:	39 f0                	cmp    %esi,%eax
  800911:	74 1c                	je     80092f <memcmp+0x30>
		if (*s1 != *s2)
  800913:	0f b6 08             	movzbl (%eax),%ecx
  800916:	0f b6 1a             	movzbl (%edx),%ebx
  800919:	38 d9                	cmp    %bl,%cl
  80091b:	75 08                	jne    800925 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	83 c2 01             	add    $0x1,%edx
  800923:	eb ea                	jmp    80090f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800925:	0f b6 c1             	movzbl %cl,%eax
  800928:	0f b6 db             	movzbl %bl,%ebx
  80092b:	29 d8                	sub    %ebx,%eax
  80092d:	eb 05                	jmp    800934 <memcmp+0x35>
	}

	return 0;
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800941:	89 c2                	mov    %eax,%edx
  800943:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800946:	39 d0                	cmp    %edx,%eax
  800948:	73 09                	jae    800953 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80094a:	38 08                	cmp    %cl,(%eax)
  80094c:	74 05                	je     800953 <memfind+0x1b>
	for (; s < ends; s++)
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	eb f3                	jmp    800946 <memfind+0xe>
			break;
	return (void *) s;
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	57                   	push   %edi
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800961:	eb 03                	jmp    800966 <strtol+0x11>
		s++;
  800963:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800966:	0f b6 01             	movzbl (%ecx),%eax
  800969:	3c 20                	cmp    $0x20,%al
  80096b:	74 f6                	je     800963 <strtol+0xe>
  80096d:	3c 09                	cmp    $0x9,%al
  80096f:	74 f2                	je     800963 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800971:	3c 2b                	cmp    $0x2b,%al
  800973:	74 2e                	je     8009a3 <strtol+0x4e>
	int neg = 0;
  800975:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80097a:	3c 2d                	cmp    $0x2d,%al
  80097c:	74 2f                	je     8009ad <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80097e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800984:	75 05                	jne    80098b <strtol+0x36>
  800986:	80 39 30             	cmpb   $0x30,(%ecx)
  800989:	74 2c                	je     8009b7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80098b:	85 db                	test   %ebx,%ebx
  80098d:	75 0a                	jne    800999 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80098f:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800994:	80 39 30             	cmpb   $0x30,(%ecx)
  800997:	74 28                	je     8009c1 <strtol+0x6c>
		base = 10;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
  80099e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009a1:	eb 50                	jmp    8009f3 <strtol+0x9e>
		s++;
  8009a3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ab:	eb d1                	jmp    80097e <strtol+0x29>
		s++, neg = 1;
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009b5:	eb c7                	jmp    80097e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009bb:	74 0e                	je     8009cb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009bd:	85 db                	test   %ebx,%ebx
  8009bf:	75 d8                	jne    800999 <strtol+0x44>
		s++, base = 8;
  8009c1:	83 c1 01             	add    $0x1,%ecx
  8009c4:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009c9:	eb ce                	jmp    800999 <strtol+0x44>
		s += 2, base = 16;
  8009cb:	83 c1 02             	add    $0x2,%ecx
  8009ce:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d3:	eb c4                	jmp    800999 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8009d5:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009d8:	89 f3                	mov    %esi,%ebx
  8009da:	80 fb 19             	cmp    $0x19,%bl
  8009dd:	77 29                	ja     800a08 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8009df:	0f be d2             	movsbl %dl,%edx
  8009e2:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009e5:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009e8:	7d 30                	jge    800a1a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8009ea:	83 c1 01             	add    $0x1,%ecx
  8009ed:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009f3:	0f b6 11             	movzbl (%ecx),%edx
  8009f6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f9:	89 f3                	mov    %esi,%ebx
  8009fb:	80 fb 09             	cmp    $0x9,%bl
  8009fe:	77 d5                	ja     8009d5 <strtol+0x80>
			dig = *s - '0';
  800a00:	0f be d2             	movsbl %dl,%edx
  800a03:	83 ea 30             	sub    $0x30,%edx
  800a06:	eb dd                	jmp    8009e5 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a08:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a0b:	89 f3                	mov    %esi,%ebx
  800a0d:	80 fb 19             	cmp    $0x19,%bl
  800a10:	77 08                	ja     800a1a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a12:	0f be d2             	movsbl %dl,%edx
  800a15:	83 ea 37             	sub    $0x37,%edx
  800a18:	eb cb                	jmp    8009e5 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1e:	74 05                	je     800a25 <strtol+0xd0>
		*endptr = (char *) s;
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a25:	89 c2                	mov    %eax,%edx
  800a27:	f7 da                	neg    %edx
  800a29:	85 ff                	test   %edi,%edi
  800a2b:	0f 45 c2             	cmovne %edx,%eax
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	83 ec 1c             	sub    $0x1c,%esp
  800a3c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a3f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a42:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4a:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a4d:	8b 75 14             	mov    0x14(%ebp),%esi
  800a50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a52:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a56:	74 04                	je     800a5c <syscall+0x29>
  800a58:	85 c0                	test   %eax,%eax
  800a5a:	7f 08                	jg     800a64 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    
  800a64:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800a67:	83 ec 0c             	sub    $0xc,%esp
  800a6a:	50                   	push   %eax
  800a6b:	52                   	push   %edx
  800a6c:	68 44 12 80 00       	push   $0x801244
  800a71:	6a 23                	push   $0x23
  800a73:	68 61 12 80 00       	push   $0x801261
  800a78:	e8 aa 02 00 00       	call   800d27 <_panic>

00800a7d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800a83:	6a 00                	push   $0x0
  800a85:	6a 00                	push   $0x0
  800a87:	6a 00                	push   $0x0
  800a89:	ff 75 0c             	pushl  0xc(%ebp)
  800a8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
  800a99:	e8 95 ff ff ff       	call   800a33 <syscall>
}
  800a9e:	83 c4 10             	add    $0x10,%esp
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800aa9:	6a 00                	push   $0x0
  800aab:	6a 00                	push   $0x0
  800aad:	6a 00                	push   $0x0
  800aaf:	6a 00                	push   $0x0
  800ab1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab6:	ba 00 00 00 00       	mov    $0x0,%edx
  800abb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac0:	e8 6e ff ff ff       	call   800a33 <syscall>
}
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800acd:	6a 00                	push   $0x0
  800acf:	6a 00                	push   $0x0
  800ad1:	6a 00                	push   $0x0
  800ad3:	6a 00                	push   $0x0
  800ad5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad8:	ba 01 00 00 00       	mov    $0x1,%edx
  800add:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae2:	e8 4c ff ff ff       	call   800a33 <syscall>
}
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800aef:	6a 00                	push   $0x0
  800af1:	6a 00                	push   $0x0
  800af3:	6a 00                	push   $0x0
  800af5:	6a 00                	push   $0x0
  800af7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 02 00 00 00       	mov    $0x2,%eax
  800b06:	e8 28 ff ff ff       	call   800a33 <syscall>
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    

00800b0d <sys_yield>:

void
sys_yield(void)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b13:	6a 00                	push   $0x0
  800b15:	6a 00                	push   $0x0
  800b17:	6a 00                	push   $0x0
  800b19:	6a 00                	push   $0x0
  800b1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2a:	e8 04 ff ff ff       	call   800a33 <syscall>
}
  800b2f:	83 c4 10             	add    $0x10,%esp
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b3a:	6a 00                	push   $0x0
  800b3c:	6a 00                	push   $0x0
  800b3e:	ff 75 10             	pushl  0x10(%ebp)
  800b41:	ff 75 0c             	pushl  0xc(%ebp)
  800b44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b47:	ba 01 00 00 00       	mov    $0x1,%edx
  800b4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b51:	e8 dd fe ff ff       	call   800a33 <syscall>
}
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b5e:	ff 75 18             	pushl  0x18(%ebp)
  800b61:	ff 75 14             	pushl  0x14(%ebp)
  800b64:	ff 75 10             	pushl  0x10(%ebp)
  800b67:	ff 75 0c             	pushl  0xc(%ebp)
  800b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800b72:	b8 05 00 00 00       	mov    $0x5,%eax
  800b77:	e8 b7 fe ff ff       	call   800a33 <syscall>
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b84:	6a 00                	push   $0x0
  800b86:	6a 00                	push   $0x0
  800b88:	6a 00                	push   $0x0
  800b8a:	ff 75 0c             	pushl  0xc(%ebp)
  800b8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b90:	ba 01 00 00 00       	mov    $0x1,%edx
  800b95:	b8 06 00 00 00       	mov    $0x6,%eax
  800b9a:	e8 94 fe ff ff       	call   800a33 <syscall>
}
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ba7:	6a 00                	push   $0x0
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	ff 75 0c             	pushl  0xc(%ebp)
  800bb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb3:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbd:	e8 71 fe ff ff       	call   800a33 <syscall>
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800bca:	6a 00                	push   $0x0
  800bcc:	6a 00                	push   $0x0
  800bce:	6a 00                	push   $0x0
  800bd0:	ff 75 0c             	pushl  0xc(%ebp)
  800bd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd6:	ba 01 00 00 00       	mov    $0x1,%edx
  800bdb:	b8 09 00 00 00       	mov    $0x9,%eax
  800be0:	e8 4e fe ff ff       	call   800a33 <syscall>
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800bed:	6a 00                	push   $0x0
  800bef:	ff 75 14             	pushl  0x14(%ebp)
  800bf2:	ff 75 10             	pushl  0x10(%ebp)
  800bf5:	ff 75 0c             	pushl  0xc(%ebp)
  800bf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c05:	e8 29 fe ff ff       	call   800a33 <syscall>
}
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    

00800c0c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c12:	6a 00                	push   $0x0
  800c14:	6a 00                	push   $0x0
  800c16:	6a 00                	push   $0x0
  800c18:	6a 00                	push   $0x0
  800c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c22:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c27:	e8 07 fe ff ff       	call   800a33 <syscall>
}
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	8b 75 08             	mov    0x8(%ebp),%esi
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int err = sys_ipc_recv(pg);
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	ff 75 0c             	pushl  0xc(%ebp)
  800c3f:	e8 c8 ff ff ff       	call   800c0c <sys_ipc_recv>

	if (from_env_store)
  800c44:	83 c4 10             	add    $0x10,%esp
  800c47:	85 f6                	test   %esi,%esi
  800c49:	74 14                	je     800c5f <ipc_recv+0x31>
		*from_env_store = (!err) ? thisenv->env_ipc_from : 0;
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	85 c0                	test   %eax,%eax
  800c52:	75 09                	jne    800c5d <ipc_recv+0x2f>
  800c54:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800c5a:	8b 52 78             	mov    0x78(%edx),%edx
  800c5d:	89 16                	mov    %edx,(%esi)

	if (perm_store)
  800c5f:	85 db                	test   %ebx,%ebx
  800c61:	74 14                	je     800c77 <ipc_recv+0x49>
		*perm_store = (!err) ? thisenv->env_ipc_perm : 0;
  800c63:	ba 00 00 00 00       	mov    $0x0,%edx
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	75 09                	jne    800c75 <ipc_recv+0x47>
  800c6c:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800c72:	8b 52 7c             	mov    0x7c(%edx),%edx
  800c75:	89 13                	mov    %edx,(%ebx)

	if (!err) err = thisenv->env_ipc_value;
  800c77:	85 c0                	test   %eax,%eax
  800c79:	75 08                	jne    800c83 <ipc_recv+0x55>
  800c7b:	a1 04 20 80 00       	mov    0x802004,%eax
  800c80:	8b 40 74             	mov    0x74(%eax),%eax
	
	return err;
}
  800c83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c99:	8b 7d 14             	mov    0x14(%ebp),%edi
	if (!pg)
  800c9c:	85 db                	test   %ebx,%ebx
		pg = (void*) UTOP;
  800c9e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800ca3:	0f 44 d8             	cmove  %eax,%ebx
	int r = sys_ipc_try_send(to_env, val, pg, perm);
  800ca6:	57                   	push   %edi
  800ca7:	53                   	push   %ebx
  800ca8:	56                   	push   %esi
  800ca9:	ff 75 08             	pushl  0x8(%ebp)
  800cac:	e8 36 ff ff ff       	call   800be7 <sys_ipc_try_send>
	while (r == -E_IPC_NOT_RECV) {
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	eb 13                	jmp    800cc9 <ipc_send+0x3f>
		sys_yield();
  800cb6:	e8 52 fe ff ff       	call   800b0d <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800cbb:	57                   	push   %edi
  800cbc:	53                   	push   %ebx
  800cbd:	56                   	push   %esi
  800cbe:	ff 75 08             	pushl  0x8(%ebp)
  800cc1:	e8 21 ff ff ff       	call   800be7 <sys_ipc_try_send>
  800cc6:	83 c4 10             	add    $0x10,%esp
	while (r == -E_IPC_NOT_RECV) {
  800cc9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800ccc:	74 e8                	je     800cb6 <ipc_send+0x2c>
	}

	if (r < 0) panic("ipc_send: %e", r);
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	78 08                	js     800cda <ipc_send+0x50>
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    
	if (r < 0) panic("ipc_send: %e", r);
  800cda:	50                   	push   %eax
  800cdb:	68 6f 12 80 00       	push   $0x80126f
  800ce0:	6a 39                	push   $0x39
  800ce2:	68 7c 12 80 00       	push   $0x80127c
  800ce7:	e8 3b 00 00 00       	call   800d27 <_panic>

00800cec <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800cf2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800cf7:	89 c2                	mov    %eax,%edx
  800cf9:	c1 e2 07             	shl    $0x7,%edx
  800cfc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800d02:	8b 52 50             	mov    0x50(%edx),%edx
  800d05:	39 ca                	cmp    %ecx,%edx
  800d07:	74 11                	je     800d1a <ipc_find_env+0x2e>
	for (i = 0; i < NENV; i++)
  800d09:	83 c0 01             	add    $0x1,%eax
  800d0c:	3d 00 04 00 00       	cmp    $0x400,%eax
  800d11:	75 e4                	jne    800cf7 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800d13:	b8 00 00 00 00       	mov    $0x0,%eax
  800d18:	eb 0b                	jmp    800d25 <ipc_find_env+0x39>
			return envs[i].env_id;
  800d1a:	c1 e0 07             	shl    $0x7,%eax
  800d1d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800d22:	8b 40 48             	mov    0x48(%eax),%eax
}
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d2c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d2f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d35:	e8 af fd ff ff       	call   800ae9 <sys_getenvid>
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	ff 75 0c             	pushl  0xc(%ebp)
  800d40:	ff 75 08             	pushl  0x8(%ebp)
  800d43:	56                   	push   %esi
  800d44:	50                   	push   %eax
  800d45:	68 88 12 80 00       	push   $0x801288
  800d4a:	e8 43 f4 ff ff       	call   800192 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d4f:	83 c4 18             	add    $0x18,%esp
  800d52:	53                   	push   %ebx
  800d53:	ff 75 10             	pushl  0x10(%ebp)
  800d56:	e8 e6 f3 ff ff       	call   800141 <vcprintf>
	cprintf("\n");
  800d5b:	c7 04 24 cf 0f 80 00 	movl   $0x800fcf,(%esp)
  800d62:	e8 2b f4 ff ff       	call   800192 <cprintf>
  800d67:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d6a:	cc                   	int3   
  800d6b:	eb fd                	jmp    800d6a <_panic+0x43>
  800d6d:	66 90                	xchg   %ax,%ax
  800d6f:	90                   	nop

00800d70 <__udivdi3>:
  800d70:	55                   	push   %ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 1c             	sub    $0x1c,%esp
  800d77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d7b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d83:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d87:	85 d2                	test   %edx,%edx
  800d89:	75 35                	jne    800dc0 <__udivdi3+0x50>
  800d8b:	39 f3                	cmp    %esi,%ebx
  800d8d:	0f 87 bd 00 00 00    	ja     800e50 <__udivdi3+0xe0>
  800d93:	85 db                	test   %ebx,%ebx
  800d95:	89 d9                	mov    %ebx,%ecx
  800d97:	75 0b                	jne    800da4 <__udivdi3+0x34>
  800d99:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9e:	31 d2                	xor    %edx,%edx
  800da0:	f7 f3                	div    %ebx
  800da2:	89 c1                	mov    %eax,%ecx
  800da4:	31 d2                	xor    %edx,%edx
  800da6:	89 f0                	mov    %esi,%eax
  800da8:	f7 f1                	div    %ecx
  800daa:	89 c6                	mov    %eax,%esi
  800dac:	89 e8                	mov    %ebp,%eax
  800dae:	89 f7                	mov    %esi,%edi
  800db0:	f7 f1                	div    %ecx
  800db2:	89 fa                	mov    %edi,%edx
  800db4:	83 c4 1c             	add    $0x1c,%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    
  800dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	39 f2                	cmp    %esi,%edx
  800dc2:	77 7c                	ja     800e40 <__udivdi3+0xd0>
  800dc4:	0f bd fa             	bsr    %edx,%edi
  800dc7:	83 f7 1f             	xor    $0x1f,%edi
  800dca:	0f 84 98 00 00 00    	je     800e68 <__udivdi3+0xf8>
  800dd0:	89 f9                	mov    %edi,%ecx
  800dd2:	b8 20 00 00 00       	mov    $0x20,%eax
  800dd7:	29 f8                	sub    %edi,%eax
  800dd9:	d3 e2                	shl    %cl,%edx
  800ddb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	89 da                	mov    %ebx,%edx
  800de3:	d3 ea                	shr    %cl,%edx
  800de5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800de9:	09 d1                	or     %edx,%ecx
  800deb:	89 f2                	mov    %esi,%edx
  800ded:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800df1:	89 f9                	mov    %edi,%ecx
  800df3:	d3 e3                	shl    %cl,%ebx
  800df5:	89 c1                	mov    %eax,%ecx
  800df7:	d3 ea                	shr    %cl,%edx
  800df9:	89 f9                	mov    %edi,%ecx
  800dfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dff:	d3 e6                	shl    %cl,%esi
  800e01:	89 eb                	mov    %ebp,%ebx
  800e03:	89 c1                	mov    %eax,%ecx
  800e05:	d3 eb                	shr    %cl,%ebx
  800e07:	09 de                	or     %ebx,%esi
  800e09:	89 f0                	mov    %esi,%eax
  800e0b:	f7 74 24 08          	divl   0x8(%esp)
  800e0f:	89 d6                	mov    %edx,%esi
  800e11:	89 c3                	mov    %eax,%ebx
  800e13:	f7 64 24 0c          	mull   0xc(%esp)
  800e17:	39 d6                	cmp    %edx,%esi
  800e19:	72 0c                	jb     800e27 <__udivdi3+0xb7>
  800e1b:	89 f9                	mov    %edi,%ecx
  800e1d:	d3 e5                	shl    %cl,%ebp
  800e1f:	39 c5                	cmp    %eax,%ebp
  800e21:	73 5d                	jae    800e80 <__udivdi3+0x110>
  800e23:	39 d6                	cmp    %edx,%esi
  800e25:	75 59                	jne    800e80 <__udivdi3+0x110>
  800e27:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e2a:	31 ff                	xor    %edi,%edi
  800e2c:	89 fa                	mov    %edi,%edx
  800e2e:	83 c4 1c             	add    $0x1c,%esp
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    
  800e36:	8d 76 00             	lea    0x0(%esi),%esi
  800e39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e40:	31 ff                	xor    %edi,%edi
  800e42:	31 c0                	xor    %eax,%eax
  800e44:	89 fa                	mov    %edi,%edx
  800e46:	83 c4 1c             	add    $0x1c,%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    
  800e4e:	66 90                	xchg   %ax,%ax
  800e50:	31 ff                	xor    %edi,%edi
  800e52:	89 e8                	mov    %ebp,%eax
  800e54:	89 f2                	mov    %esi,%edx
  800e56:	f7 f3                	div    %ebx
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	39 f2                	cmp    %esi,%edx
  800e6a:	72 06                	jb     800e72 <__udivdi3+0x102>
  800e6c:	31 c0                	xor    %eax,%eax
  800e6e:	39 eb                	cmp    %ebp,%ebx
  800e70:	77 d2                	ja     800e44 <__udivdi3+0xd4>
  800e72:	b8 01 00 00 00       	mov    $0x1,%eax
  800e77:	eb cb                	jmp    800e44 <__udivdi3+0xd4>
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 d8                	mov    %ebx,%eax
  800e82:	31 ff                	xor    %edi,%edi
  800e84:	eb be                	jmp    800e44 <__udivdi3+0xd4>
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	66 90                	xchg   %ax,%ax
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea7:	85 ed                	test   %ebp,%ebp
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	89 da                	mov    %ebx,%edx
  800ead:	75 19                	jne    800ec8 <__umoddi3+0x38>
  800eaf:	39 df                	cmp    %ebx,%edi
  800eb1:	0f 86 b1 00 00 00    	jbe    800f68 <__umoddi3+0xd8>
  800eb7:	f7 f7                	div    %edi
  800eb9:	89 d0                	mov    %edx,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	83 c4 1c             	add    $0x1c,%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
  800ec8:	39 dd                	cmp    %ebx,%ebp
  800eca:	77 f1                	ja     800ebd <__umoddi3+0x2d>
  800ecc:	0f bd cd             	bsr    %ebp,%ecx
  800ecf:	83 f1 1f             	xor    $0x1f,%ecx
  800ed2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ed6:	0f 84 b4 00 00 00    	je     800f90 <__umoddi3+0x100>
  800edc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee1:	89 c2                	mov    %eax,%edx
  800ee3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ee7:	29 c2                	sub    %eax,%edx
  800ee9:	89 c1                	mov    %eax,%ecx
  800eeb:	89 f8                	mov    %edi,%eax
  800eed:	d3 e5                	shl    %cl,%ebp
  800eef:	89 d1                	mov    %edx,%ecx
  800ef1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ef5:	d3 e8                	shr    %cl,%eax
  800ef7:	09 c5                	or     %eax,%ebp
  800ef9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800efd:	89 c1                	mov    %eax,%ecx
  800eff:	d3 e7                	shl    %cl,%edi
  800f01:	89 d1                	mov    %edx,%ecx
  800f03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f07:	89 df                	mov    %ebx,%edi
  800f09:	d3 ef                	shr    %cl,%edi
  800f0b:	89 c1                	mov    %eax,%ecx
  800f0d:	89 f0                	mov    %esi,%eax
  800f0f:	d3 e3                	shl    %cl,%ebx
  800f11:	89 d1                	mov    %edx,%ecx
  800f13:	89 fa                	mov    %edi,%edx
  800f15:	d3 e8                	shr    %cl,%eax
  800f17:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f1c:	09 d8                	or     %ebx,%eax
  800f1e:	f7 f5                	div    %ebp
  800f20:	d3 e6                	shl    %cl,%esi
  800f22:	89 d1                	mov    %edx,%ecx
  800f24:	f7 64 24 08          	mull   0x8(%esp)
  800f28:	39 d1                	cmp    %edx,%ecx
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	89 d7                	mov    %edx,%edi
  800f2e:	72 06                	jb     800f36 <__umoddi3+0xa6>
  800f30:	75 0e                	jne    800f40 <__umoddi3+0xb0>
  800f32:	39 c6                	cmp    %eax,%esi
  800f34:	73 0a                	jae    800f40 <__umoddi3+0xb0>
  800f36:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f3a:	19 ea                	sbb    %ebp,%edx
  800f3c:	89 d7                	mov    %edx,%edi
  800f3e:	89 c3                	mov    %eax,%ebx
  800f40:	89 ca                	mov    %ecx,%edx
  800f42:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f47:	29 de                	sub    %ebx,%esi
  800f49:	19 fa                	sbb    %edi,%edx
  800f4b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f4f:	89 d0                	mov    %edx,%eax
  800f51:	d3 e0                	shl    %cl,%eax
  800f53:	89 d9                	mov    %ebx,%ecx
  800f55:	d3 ee                	shr    %cl,%esi
  800f57:	d3 ea                	shr    %cl,%edx
  800f59:	09 f0                	or     %esi,%eax
  800f5b:	83 c4 1c             	add    $0x1c,%esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
  800f63:	90                   	nop
  800f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f68:	85 ff                	test   %edi,%edi
  800f6a:	89 f9                	mov    %edi,%ecx
  800f6c:	75 0b                	jne    800f79 <__umoddi3+0xe9>
  800f6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f7                	div    %edi
  800f77:	89 c1                	mov    %eax,%ecx
  800f79:	89 d8                	mov    %ebx,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f1                	div    %ecx
  800f7f:	89 f0                	mov    %esi,%eax
  800f81:	f7 f1                	div    %ecx
  800f83:	e9 31 ff ff ff       	jmp    800eb9 <__umoddi3+0x29>
  800f88:	90                   	nop
  800f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f90:	39 dd                	cmp    %ebx,%ebp
  800f92:	72 08                	jb     800f9c <__umoddi3+0x10c>
  800f94:	39 f7                	cmp    %esi,%edi
  800f96:	0f 87 21 ff ff ff    	ja     800ebd <__umoddi3+0x2d>
  800f9c:	89 da                	mov    %ebx,%edx
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	29 f8                	sub    %edi,%eax
  800fa2:	19 ea                	sbb    %ebp,%edx
  800fa4:	e9 14 ff ff ff       	jmp    800ebd <__umoddi3+0x2d>
