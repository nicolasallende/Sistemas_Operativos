
obj/user/spin:     file format elf32-i386


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

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 c0 13 80 00       	push   $0x8013c0
  80003f:	e8 62 01 00 00       	call   8001a6 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 28 0f 00 00       	call   800f71 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 38 14 80 00       	push   $0x801438
  800058:	e8 49 01 00 00       	call   8001a6 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 e8 13 80 00       	push   $0x8013e8
  80006c:	e8 35 01 00 00       	call   8001a6 <cprintf>
	sys_yield();
  800071:	e8 ab 0a 00 00       	call   800b21 <sys_yield>
	sys_yield();
  800076:	e8 a6 0a 00 00       	call   800b21 <sys_yield>
	sys_yield();
  80007b:	e8 a1 0a 00 00       	call   800b21 <sys_yield>
	sys_yield();
  800080:	e8 9c 0a 00 00       	call   800b21 <sys_yield>
	sys_yield();
  800085:	e8 97 0a 00 00       	call   800b21 <sys_yield>
	sys_yield();
  80008a:	e8 92 0a 00 00       	call   800b21 <sys_yield>
	sys_yield();
  80008f:	e8 8d 0a 00 00       	call   800b21 <sys_yield>
	sys_yield();
  800094:	e8 88 0a 00 00       	call   800b21 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 10 14 80 00 	movl   $0x801410,(%esp)
  8000a0:	e8 01 01 00 00       	call   8001a6 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 2e 0a 00 00       	call   800adb <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
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
  8000c0:	e8 38 0a 00 00       	call   800afd <sys_getenvid>
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
  8000eb:	e8 43 ff ff ff       	call   800033 <umain>

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
  800107:	e8 cf 09 00 00       	call   800adb <sys_env_destroy>
}
  80010c:	83 c4 10             	add    $0x10,%esp
  80010f:	c9                   	leave  
  800110:	c3                   	ret    

00800111 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	53                   	push   %ebx
  800115:	83 ec 04             	sub    $0x4,%esp
  800118:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011b:	8b 13                	mov    (%ebx),%edx
  80011d:	8d 42 01             	lea    0x1(%edx),%eax
  800120:	89 03                	mov    %eax,(%ebx)
  800122:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800125:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800129:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012e:	74 09                	je     800139 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800130:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800134:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800137:	c9                   	leave  
  800138:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	68 ff 00 00 00       	push   $0xff
  800141:	8d 43 08             	lea    0x8(%ebx),%eax
  800144:	50                   	push   %eax
  800145:	e8 47 09 00 00       	call   800a91 <sys_cputs>
		b->idx = 0;
  80014a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	eb db                	jmp    800130 <putch+0x1f>

00800155 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800165:	00 00 00 
	b.cnt = 0;
  800168:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800172:	ff 75 0c             	pushl  0xc(%ebp)
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017e:	50                   	push   %eax
  80017f:	68 11 01 80 00       	push   $0x800111
  800184:	e8 86 01 00 00       	call   80030f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800189:	83 c4 08             	add    $0x8,%esp
  80018c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800192:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800198:	50                   	push   %eax
  800199:	e8 f3 08 00 00       	call   800a91 <sys_cputs>

	return b.cnt;
}
  80019e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ac:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001af:	50                   	push   %eax
  8001b0:	ff 75 08             	pushl  0x8(%ebp)
  8001b3:	e8 9d ff ff ff       	call   800155 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	57                   	push   %edi
  8001be:	56                   	push   %esi
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 1c             	sub    $0x1c,%esp
  8001c3:	89 c7                	mov    %eax,%edi
  8001c5:	89 d6                	mov    %edx,%esi
  8001c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001de:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e1:	39 d3                	cmp    %edx,%ebx
  8001e3:	72 05                	jb     8001ea <printnum+0x30>
  8001e5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e8:	77 7a                	ja     800264 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	ff 75 18             	pushl  0x18(%ebp)
  8001f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f6:	53                   	push   %ebx
  8001f7:	ff 75 10             	pushl  0x10(%ebp)
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800200:	ff 75 e0             	pushl  -0x20(%ebp)
  800203:	ff 75 dc             	pushl  -0x24(%ebp)
  800206:	ff 75 d8             	pushl  -0x28(%ebp)
  800209:	e8 62 0f 00 00       	call   801170 <__udivdi3>
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	52                   	push   %edx
  800212:	50                   	push   %eax
  800213:	89 f2                	mov    %esi,%edx
  800215:	89 f8                	mov    %edi,%eax
  800217:	e8 9e ff ff ff       	call   8001ba <printnum>
  80021c:	83 c4 20             	add    $0x20,%esp
  80021f:	eb 13                	jmp    800234 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	56                   	push   %esi
  800225:	ff 75 18             	pushl  0x18(%ebp)
  800228:	ff d7                	call   *%edi
  80022a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022d:	83 eb 01             	sub    $0x1,%ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f ed                	jg     800221 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	56                   	push   %esi
  800238:	83 ec 04             	sub    $0x4,%esp
  80023b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023e:	ff 75 e0             	pushl  -0x20(%ebp)
  800241:	ff 75 dc             	pushl  -0x24(%ebp)
  800244:	ff 75 d8             	pushl  -0x28(%ebp)
  800247:	e8 44 10 00 00       	call   801290 <__umoddi3>
  80024c:	83 c4 14             	add    $0x14,%esp
  80024f:	0f be 80 60 14 80 00 	movsbl 0x801460(%eax),%eax
  800256:	50                   	push   %eax
  800257:	ff d7                	call   *%edi
}
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    
  800264:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800267:	eb c4                	jmp    80022d <printnum+0x73>

00800269 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026c:	83 fa 01             	cmp    $0x1,%edx
  80026f:	7e 0e                	jle    80027f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 08             	lea    0x8(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    
	else if (lflag)
  80027f:	85 d2                	test   %edx,%edx
  800281:	75 10                	jne    800293 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800283:	8b 10                	mov    (%eax),%edx
  800285:	8d 4a 04             	lea    0x4(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	ba 00 00 00 00       	mov    $0x0,%edx
  800291:	eb ea                	jmp    80027d <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800293:	8b 10                	mov    (%eax),%edx
  800295:	8d 4a 04             	lea    0x4(%edx),%ecx
  800298:	89 08                	mov    %ecx,(%eax)
  80029a:	8b 02                	mov    (%edx),%eax
  80029c:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a1:	eb da                	jmp    80027d <getuint+0x14>

008002a3 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a6:	83 fa 01             	cmp    $0x1,%edx
  8002a9:	7e 0e                	jle    8002b9 <getint+0x16>
		return va_arg(*ap, long long);
  8002ab:	8b 10                	mov    (%eax),%edx
  8002ad:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b0:	89 08                	mov    %ecx,(%eax)
  8002b2:	8b 02                	mov    (%edx),%eax
  8002b4:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    
	else if (lflag)
  8002b9:	85 d2                	test   %edx,%edx
  8002bb:	75 0c                	jne    8002c9 <getint+0x26>
		return va_arg(*ap, int);
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 02                	mov    (%edx),%eax
  8002c6:	99                   	cltd   
  8002c7:	eb ee                	jmp    8002b7 <getint+0x14>
		return va_arg(*ap, long);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	99                   	cltd   
  8002d3:	eb e2                	jmp    8002b7 <getint+0x14>

008002d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e4:	73 0a                	jae    8002f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	88 02                	mov    %al,(%edx)
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <printfmt>:
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fb:	50                   	push   %eax
  8002fc:	ff 75 10             	pushl  0x10(%ebp)
  8002ff:	ff 75 0c             	pushl  0xc(%ebp)
  800302:	ff 75 08             	pushl  0x8(%ebp)
  800305:	e8 05 00 00 00       	call   80030f <vprintfmt>
}
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <vprintfmt>:
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 2c             	sub    $0x2c,%esp
  800318:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80031b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80031e:	89 f7                	mov    %esi,%edi
  800320:	89 de                	mov    %ebx,%esi
  800322:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800325:	e9 9e 02 00 00       	jmp    8005c8 <vprintfmt+0x2b9>
		padc = ' ';
  80032a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80032e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800335:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80033c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800343:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8d 43 01             	lea    0x1(%ebx),%eax
  80034b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034e:	0f b6 0b             	movzbl (%ebx),%ecx
  800351:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800354:	3c 55                	cmp    $0x55,%al
  800356:	0f 87 e8 02 00 00    	ja     800644 <vprintfmt+0x335>
  80035c:	0f b6 c0             	movzbl %al,%eax
  80035f:	ff 24 85 20 15 80 00 	jmp    *0x801520(,%eax,4)
  800366:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800369:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80036d:	eb d9                	jmp    800348 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800372:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800376:	eb d0                	jmp    800348 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800378:	0f b6 c9             	movzbl %cl,%ecx
  80037b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80037e:	b8 00 00 00 00       	mov    $0x0,%eax
  800383:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800386:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800389:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80038d:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800390:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800393:	83 fa 09             	cmp    $0x9,%edx
  800396:	77 52                	ja     8003ea <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800398:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80039b:	eb e9                	jmp    800386 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003a6:	8b 00                	mov    (%eax),%eax
  8003a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  8003ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b2:	79 94                	jns    800348 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c1:	eb 85                	jmp    800348 <vprintfmt+0x39>
  8003c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c6:	85 c0                	test   %eax,%eax
  8003c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cd:	0f 49 c8             	cmovns %eax,%ecx
  8003d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003d6:	e9 6d ff ff ff       	jmp    800348 <vprintfmt+0x39>
  8003db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003de:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e5:	e9 5e ff ff ff       	jmp    800348 <vprintfmt+0x39>
  8003ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f0:	eb bc                	jmp    8003ae <vprintfmt+0x9f>
			lflag++;
  8003f2:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003f8:	e9 4b ff ff ff       	jmp    800348 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 50 04             	lea    0x4(%eax),%edx
  800403:	89 55 14             	mov    %edx,0x14(%ebp)
  800406:	83 ec 08             	sub    $0x8,%esp
  800409:	57                   	push   %edi
  80040a:	ff 30                	pushl  (%eax)
  80040c:	ff d6                	call   *%esi
			break;
  80040e:	83 c4 10             	add    $0x10,%esp
  800411:	e9 af 01 00 00       	jmp    8005c5 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 50 04             	lea    0x4(%eax),%edx
  80041c:	89 55 14             	mov    %edx,0x14(%ebp)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	99                   	cltd   
  800422:	31 d0                	xor    %edx,%eax
  800424:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800426:	83 f8 08             	cmp    $0x8,%eax
  800429:	7f 20                	jg     80044b <vprintfmt+0x13c>
  80042b:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  800432:	85 d2                	test   %edx,%edx
  800434:	74 15                	je     80044b <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800436:	52                   	push   %edx
  800437:	68 81 14 80 00       	push   $0x801481
  80043c:	57                   	push   %edi
  80043d:	56                   	push   %esi
  80043e:	e8 af fe ff ff       	call   8002f2 <printfmt>
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	e9 7a 01 00 00       	jmp    8005c5 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  80044b:	50                   	push   %eax
  80044c:	68 78 14 80 00       	push   $0x801478
  800451:	57                   	push   %edi
  800452:	56                   	push   %esi
  800453:	e8 9a fe ff ff       	call   8002f2 <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	e9 65 01 00 00       	jmp    8005c5 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  80046b:	85 db                	test   %ebx,%ebx
  80046d:	b8 71 14 80 00       	mov    $0x801471,%eax
  800472:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  800475:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800479:	0f 8e bd 00 00 00    	jle    80053c <vprintfmt+0x22d>
  80047f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800483:	75 0e                	jne    800493 <vprintfmt+0x184>
  800485:	89 75 08             	mov    %esi,0x8(%ebp)
  800488:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80048e:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800491:	eb 6d                	jmp    800500 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	ff 75 d0             	pushl  -0x30(%ebp)
  800499:	53                   	push   %ebx
  80049a:	e8 4d 02 00 00       	call   8006ec <strnlen>
  80049f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a2:	29 c1                	sub    %eax,%ecx
  8004a4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004a7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004aa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b1:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004b4:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b6:	eb 0f                	jmp    8004c7 <vprintfmt+0x1b8>
					putch(padc, putdat);
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	57                   	push   %edi
  8004bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bf:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	83 eb 01             	sub    $0x1,%ebx
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	85 db                	test   %ebx,%ebx
  8004c9:	7f ed                	jg     8004b8 <vprintfmt+0x1a9>
  8004cb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004ce:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d1:	85 c9                	test   %ecx,%ecx
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	0f 49 c1             	cmovns %ecx,%eax
  8004db:	29 c1                	sub    %eax,%ecx
  8004dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004e6:	89 cf                	mov    %ecx,%edi
  8004e8:	eb 16                	jmp    800500 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ee:	75 31                	jne    800521 <vprintfmt+0x212>
					putch(ch, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 0c             	pushl  0xc(%ebp)
  8004f6:	50                   	push   %eax
  8004f7:	ff 55 08             	call   *0x8(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fd:	83 ef 01             	sub    $0x1,%edi
  800500:	83 c3 01             	add    $0x1,%ebx
  800503:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  800507:	0f be c2             	movsbl %dl,%eax
  80050a:	85 c0                	test   %eax,%eax
  80050c:	74 50                	je     80055e <vprintfmt+0x24f>
  80050e:	85 f6                	test   %esi,%esi
  800510:	78 d8                	js     8004ea <vprintfmt+0x1db>
  800512:	83 ee 01             	sub    $0x1,%esi
  800515:	79 d3                	jns    8004ea <vprintfmt+0x1db>
  800517:	89 fb                	mov    %edi,%ebx
  800519:	8b 75 08             	mov    0x8(%ebp),%esi
  80051c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80051f:	eb 37                	jmp    800558 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	0f be d2             	movsbl %dl,%edx
  800524:	83 ea 20             	sub    $0x20,%edx
  800527:	83 fa 5e             	cmp    $0x5e,%edx
  80052a:	76 c4                	jbe    8004f0 <vprintfmt+0x1e1>
					putch('?', putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 0c             	pushl  0xc(%ebp)
  800532:	6a 3f                	push   $0x3f
  800534:	ff 55 08             	call   *0x8(%ebp)
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	eb c1                	jmp    8004fd <vprintfmt+0x1ee>
  80053c:	89 75 08             	mov    %esi,0x8(%ebp)
  80053f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800542:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800545:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800548:	eb b6                	jmp    800500 <vprintfmt+0x1f1>
				putch(' ', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	57                   	push   %edi
  80054e:	6a 20                	push   $0x20
  800550:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800552:	83 eb 01             	sub    $0x1,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	85 db                	test   %ebx,%ebx
  80055a:	7f ee                	jg     80054a <vprintfmt+0x23b>
  80055c:	eb 67                	jmp    8005c5 <vprintfmt+0x2b6>
  80055e:	89 fb                	mov    %edi,%ebx
  800560:	8b 75 08             	mov    0x8(%ebp),%esi
  800563:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800566:	eb f0                	jmp    800558 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800568:	8d 45 14             	lea    0x14(%ebp),%eax
  80056b:	e8 33 fd ff ff       	call   8002a3 <getint>
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800576:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  80057b:	85 d2                	test   %edx,%edx
  80057d:	79 2c                	jns    8005ab <vprintfmt+0x29c>
				putch('-', putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	57                   	push   %edi
  800583:	6a 2d                	push   $0x2d
  800585:	ff d6                	call   *%esi
				num = -(long long) num;
  800587:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80058a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058d:	f7 d8                	neg    %eax
  80058f:	83 d2 00             	adc    $0x0,%edx
  800592:	f7 da                	neg    %edx
  800594:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800597:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80059c:	eb 0d                	jmp    8005ab <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80059e:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a1:	e8 c3 fc ff ff       	call   800269 <getuint>
			base = 10;
  8005a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8005ab:	83 ec 0c             	sub    $0xc,%esp
  8005ae:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  8005b2:	53                   	push   %ebx
  8005b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b6:	51                   	push   %ecx
  8005b7:	52                   	push   %edx
  8005b8:	50                   	push   %eax
  8005b9:	89 fa                	mov    %edi,%edx
  8005bb:	89 f0                	mov    %esi,%eax
  8005bd:	e8 f8 fb ff ff       	call   8001ba <printnum>
			break;
  8005c2:	83 c4 20             	add    $0x20,%esp
{
  8005c5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005c8:	83 c3 01             	add    $0x1,%ebx
  8005cb:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005cf:	83 f8 25             	cmp    $0x25,%eax
  8005d2:	0f 84 52 fd ff ff    	je     80032a <vprintfmt+0x1b>
			if (ch == '\0')
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	0f 84 84 00 00 00    	je     800664 <vprintfmt+0x355>
			putch(ch, putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	57                   	push   %edi
  8005e4:	50                   	push   %eax
  8005e5:	ff d6                	call   *%esi
  8005e7:	83 c4 10             	add    $0x10,%esp
  8005ea:	eb dc                	jmp    8005c8 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 75 fc ff ff       	call   800269 <getuint>
			base = 8;
  8005f4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005f9:	eb b0                	jmp    8005ab <vprintfmt+0x29c>
			putch('0', putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	57                   	push   %edi
  8005ff:	6a 30                	push   $0x30
  800601:	ff d6                	call   *%esi
			putch('x', putdat);
  800603:	83 c4 08             	add    $0x8,%esp
  800606:	57                   	push   %edi
  800607:	6a 78                	push   $0x78
  800609:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  80061b:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80061e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800623:	eb 86                	jmp    8005ab <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800625:	8d 45 14             	lea    0x14(%ebp),%eax
  800628:	e8 3c fc ff ff       	call   800269 <getuint>
			base = 16;
  80062d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800632:	e9 74 ff ff ff       	jmp    8005ab <vprintfmt+0x29c>
			putch(ch, putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	57                   	push   %edi
  80063b:	6a 25                	push   $0x25
  80063d:	ff d6                	call   *%esi
			break;
  80063f:	83 c4 10             	add    $0x10,%esp
  800642:	eb 81                	jmp    8005c5 <vprintfmt+0x2b6>
			putch('%', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	57                   	push   %edi
  800648:	6a 25                	push   $0x25
  80064a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	89 d8                	mov    %ebx,%eax
  800651:	eb 03                	jmp    800656 <vprintfmt+0x347>
  800653:	83 e8 01             	sub    $0x1,%eax
  800656:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80065a:	75 f7                	jne    800653 <vprintfmt+0x344>
  80065c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80065f:	e9 61 ff ff ff       	jmp    8005c5 <vprintfmt+0x2b6>
}
  800664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800667:	5b                   	pop    %ebx
  800668:	5e                   	pop    %esi
  800669:	5f                   	pop    %edi
  80066a:	5d                   	pop    %ebp
  80066b:	c3                   	ret    

0080066c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	83 ec 18             	sub    $0x18,%esp
  800672:	8b 45 08             	mov    0x8(%ebp),%eax
  800675:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800678:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800682:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800689:	85 c0                	test   %eax,%eax
  80068b:	74 26                	je     8006b3 <vsnprintf+0x47>
  80068d:	85 d2                	test   %edx,%edx
  80068f:	7e 22                	jle    8006b3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800691:	ff 75 14             	pushl  0x14(%ebp)
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069a:	50                   	push   %eax
  80069b:	68 d5 02 80 00       	push   $0x8002d5
  8006a0:	e8 6a fc ff ff       	call   80030f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ae:	83 c4 10             	add    $0x10,%esp
}
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    
		return -E_INVAL;
  8006b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b8:	eb f7                	jmp    8006b1 <vsnprintf+0x45>

008006ba <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c3:	50                   	push   %eax
  8006c4:	ff 75 10             	pushl  0x10(%ebp)
  8006c7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ca:	ff 75 08             	pushl  0x8(%ebp)
  8006cd:	e8 9a ff ff ff       	call   80066c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
  8006df:	eb 03                	jmp    8006e4 <strlen+0x10>
		n++;
  8006e1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006e4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e8:	75 f7                	jne    8006e1 <strlen+0xd>
	return n;
}
  8006ea:	5d                   	pop    %ebp
  8006eb:	c3                   	ret    

008006ec <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fa:	eb 03                	jmp    8006ff <strnlen+0x13>
		n++;
  8006fc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ff:	39 d0                	cmp    %edx,%eax
  800701:	74 06                	je     800709 <strnlen+0x1d>
  800703:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800707:	75 f3                	jne    8006fc <strnlen+0x10>
	return n;
}
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	53                   	push   %ebx
  80070f:	8b 45 08             	mov    0x8(%ebp),%eax
  800712:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800715:	89 c2                	mov    %eax,%edx
  800717:	83 c1 01             	add    $0x1,%ecx
  80071a:	83 c2 01             	add    $0x1,%edx
  80071d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800721:	88 5a ff             	mov    %bl,-0x1(%edx)
  800724:	84 db                	test   %bl,%bl
  800726:	75 ef                	jne    800717 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800728:	5b                   	pop    %ebx
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	53                   	push   %ebx
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800732:	53                   	push   %ebx
  800733:	e8 9c ff ff ff       	call   8006d4 <strlen>
  800738:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80073b:	ff 75 0c             	pushl  0xc(%ebp)
  80073e:	01 d8                	add    %ebx,%eax
  800740:	50                   	push   %eax
  800741:	e8 c5 ff ff ff       	call   80070b <strcpy>
	return dst;
}
  800746:	89 d8                	mov    %ebx,%eax
  800748:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074b:	c9                   	leave  
  80074c:	c3                   	ret    

0080074d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	56                   	push   %esi
  800751:	53                   	push   %ebx
  800752:	8b 75 08             	mov    0x8(%ebp),%esi
  800755:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800758:	89 f3                	mov    %esi,%ebx
  80075a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075d:	89 f2                	mov    %esi,%edx
  80075f:	eb 0f                	jmp    800770 <strncpy+0x23>
		*dst++ = *src;
  800761:	83 c2 01             	add    $0x1,%edx
  800764:	0f b6 01             	movzbl (%ecx),%eax
  800767:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076a:	80 39 01             	cmpb   $0x1,(%ecx)
  80076d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800770:	39 da                	cmp    %ebx,%edx
  800772:	75 ed                	jne    800761 <strncpy+0x14>
	}
	return ret;
}
  800774:	89 f0                	mov    %esi,%eax
  800776:	5b                   	pop    %ebx
  800777:	5e                   	pop    %esi
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	56                   	push   %esi
  80077e:	53                   	push   %ebx
  80077f:	8b 75 08             	mov    0x8(%ebp),%esi
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
  800785:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800788:	89 f0                	mov    %esi,%eax
  80078a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078e:	85 c9                	test   %ecx,%ecx
  800790:	75 0b                	jne    80079d <strlcpy+0x23>
  800792:	eb 17                	jmp    8007ab <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800794:	83 c2 01             	add    $0x1,%edx
  800797:	83 c0 01             	add    $0x1,%eax
  80079a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80079d:	39 d8                	cmp    %ebx,%eax
  80079f:	74 07                	je     8007a8 <strlcpy+0x2e>
  8007a1:	0f b6 0a             	movzbl (%edx),%ecx
  8007a4:	84 c9                	test   %cl,%cl
  8007a6:	75 ec                	jne    800794 <strlcpy+0x1a>
		*dst = '\0';
  8007a8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ab:	29 f0                	sub    %esi,%eax
}
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ba:	eb 06                	jmp    8007c2 <strcmp+0x11>
		p++, q++;
  8007bc:	83 c1 01             	add    $0x1,%ecx
  8007bf:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007c2:	0f b6 01             	movzbl (%ecx),%eax
  8007c5:	84 c0                	test   %al,%al
  8007c7:	74 04                	je     8007cd <strcmp+0x1c>
  8007c9:	3a 02                	cmp    (%edx),%al
  8007cb:	74 ef                	je     8007bc <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cd:	0f b6 c0             	movzbl %al,%eax
  8007d0:	0f b6 12             	movzbl (%edx),%edx
  8007d3:	29 d0                	sub    %edx,%eax
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e1:	89 c3                	mov    %eax,%ebx
  8007e3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e6:	eb 06                	jmp    8007ee <strncmp+0x17>
		n--, p++, q++;
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007ee:	39 d8                	cmp    %ebx,%eax
  8007f0:	74 16                	je     800808 <strncmp+0x31>
  8007f2:	0f b6 08             	movzbl (%eax),%ecx
  8007f5:	84 c9                	test   %cl,%cl
  8007f7:	74 04                	je     8007fd <strncmp+0x26>
  8007f9:	3a 0a                	cmp    (%edx),%cl
  8007fb:	74 eb                	je     8007e8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fd:	0f b6 00             	movzbl (%eax),%eax
  800800:	0f b6 12             	movzbl (%edx),%edx
  800803:	29 d0                	sub    %edx,%eax
}
  800805:	5b                   	pop    %ebx
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    
		return 0;
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
  80080d:	eb f6                	jmp    800805 <strncmp+0x2e>

0080080f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800819:	0f b6 10             	movzbl (%eax),%edx
  80081c:	84 d2                	test   %dl,%dl
  80081e:	74 09                	je     800829 <strchr+0x1a>
		if (*s == c)
  800820:	38 ca                	cmp    %cl,%dl
  800822:	74 0a                	je     80082e <strchr+0x1f>
	for (; *s; s++)
  800824:	83 c0 01             	add    $0x1,%eax
  800827:	eb f0                	jmp    800819 <strchr+0xa>
			return (char *) s;
	return 0;
  800829:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083a:	eb 03                	jmp    80083f <strfind+0xf>
  80083c:	83 c0 01             	add    $0x1,%eax
  80083f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800842:	38 ca                	cmp    %cl,%dl
  800844:	74 04                	je     80084a <strfind+0x1a>
  800846:	84 d2                	test   %dl,%dl
  800848:	75 f2                	jne    80083c <strfind+0xc>
			break;
	return (char *) s;
}
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	57                   	push   %edi
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	8b 55 08             	mov    0x8(%ebp),%edx
  800855:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	74 12                	je     80086e <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085c:	f6 c2 03             	test   $0x3,%dl
  80085f:	75 05                	jne    800866 <memset+0x1a>
  800861:	f6 c1 03             	test   $0x3,%cl
  800864:	74 0f                	je     800875 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800866:	89 d7                	mov    %edx,%edi
  800868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086b:	fc                   	cld    
  80086c:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80086e:	89 d0                	mov    %edx,%eax
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5f                   	pop    %edi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    
		c &= 0xFF;
  800875:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800879:	89 d8                	mov    %ebx,%eax
  80087b:	c1 e0 08             	shl    $0x8,%eax
  80087e:	89 df                	mov    %ebx,%edi
  800880:	c1 e7 18             	shl    $0x18,%edi
  800883:	89 de                	mov    %ebx,%esi
  800885:	c1 e6 10             	shl    $0x10,%esi
  800888:	09 f7                	or     %esi,%edi
  80088a:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  80088c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800891:	89 d7                	mov    %edx,%edi
  800893:	fc                   	cld    
  800894:	f3 ab                	rep stos %eax,%es:(%edi)
  800896:	eb d6                	jmp    80086e <memset+0x22>

00800898 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a6:	39 c6                	cmp    %eax,%esi
  8008a8:	73 35                	jae    8008df <memmove+0x47>
  8008aa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ad:	39 c2                	cmp    %eax,%edx
  8008af:	76 2e                	jbe    8008df <memmove+0x47>
		s += n;
		d += n;
  8008b1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b4:	89 d6                	mov    %edx,%esi
  8008b6:	09 fe                	or     %edi,%esi
  8008b8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008be:	74 0c                	je     8008cc <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c0:	83 ef 01             	sub    $0x1,%edi
  8008c3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008c6:	fd                   	std    
  8008c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c9:	fc                   	cld    
  8008ca:	eb 21                	jmp    8008ed <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cc:	f6 c1 03             	test   $0x3,%cl
  8008cf:	75 ef                	jne    8008c0 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008d1:	83 ef 04             	sub    $0x4,%edi
  8008d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008da:	fd                   	std    
  8008db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dd:	eb ea                	jmp    8008c9 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008df:	89 f2                	mov    %esi,%edx
  8008e1:	09 c2                	or     %eax,%edx
  8008e3:	f6 c2 03             	test   $0x3,%dl
  8008e6:	74 09                	je     8008f1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e8:	89 c7                	mov    %eax,%edi
  8008ea:	fc                   	cld    
  8008eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ed:	5e                   	pop    %esi
  8008ee:	5f                   	pop    %edi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 f2                	jne    8008e8 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008f6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008f9:	89 c7                	mov    %eax,%edi
  8008fb:	fc                   	cld    
  8008fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fe:	eb ed                	jmp    8008ed <memmove+0x55>

00800900 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800903:	ff 75 10             	pushl  0x10(%ebp)
  800906:	ff 75 0c             	pushl  0xc(%ebp)
  800909:	ff 75 08             	pushl  0x8(%ebp)
  80090c:	e8 87 ff ff ff       	call   800898 <memmove>
}
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091e:	89 c6                	mov    %eax,%esi
  800920:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800923:	39 f0                	cmp    %esi,%eax
  800925:	74 1c                	je     800943 <memcmp+0x30>
		if (*s1 != *s2)
  800927:	0f b6 08             	movzbl (%eax),%ecx
  80092a:	0f b6 1a             	movzbl (%edx),%ebx
  80092d:	38 d9                	cmp    %bl,%cl
  80092f:	75 08                	jne    800939 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800931:	83 c0 01             	add    $0x1,%eax
  800934:	83 c2 01             	add    $0x1,%edx
  800937:	eb ea                	jmp    800923 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800939:	0f b6 c1             	movzbl %cl,%eax
  80093c:	0f b6 db             	movzbl %bl,%ebx
  80093f:	29 d8                	sub    %ebx,%eax
  800941:	eb 05                	jmp    800948 <memcmp+0x35>
	}

	return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800955:	89 c2                	mov    %eax,%edx
  800957:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80095a:	39 d0                	cmp    %edx,%eax
  80095c:	73 09                	jae    800967 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095e:	38 08                	cmp    %cl,(%eax)
  800960:	74 05                	je     800967 <memfind+0x1b>
	for (; s < ends; s++)
  800962:	83 c0 01             	add    $0x1,%eax
  800965:	eb f3                	jmp    80095a <memfind+0xe>
			break;
	return (void *) s;
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
  80096f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800972:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800975:	eb 03                	jmp    80097a <strtol+0x11>
		s++;
  800977:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80097a:	0f b6 01             	movzbl (%ecx),%eax
  80097d:	3c 20                	cmp    $0x20,%al
  80097f:	74 f6                	je     800977 <strtol+0xe>
  800981:	3c 09                	cmp    $0x9,%al
  800983:	74 f2                	je     800977 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800985:	3c 2b                	cmp    $0x2b,%al
  800987:	74 2e                	je     8009b7 <strtol+0x4e>
	int neg = 0;
  800989:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80098e:	3c 2d                	cmp    $0x2d,%al
  800990:	74 2f                	je     8009c1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800992:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800998:	75 05                	jne    80099f <strtol+0x36>
  80099a:	80 39 30             	cmpb   $0x30,(%ecx)
  80099d:	74 2c                	je     8009cb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80099f:	85 db                	test   %ebx,%ebx
  8009a1:	75 0a                	jne    8009ad <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009a3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8009a8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ab:	74 28                	je     8009d5 <strtol+0x6c>
		base = 10;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009b5:	eb 50                	jmp    800a07 <strtol+0x9e>
		s++;
  8009b7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8009bf:	eb d1                	jmp    800992 <strtol+0x29>
		s++, neg = 1;
  8009c1:	83 c1 01             	add    $0x1,%ecx
  8009c4:	bf 01 00 00 00       	mov    $0x1,%edi
  8009c9:	eb c7                	jmp    800992 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009cf:	74 0e                	je     8009df <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009d1:	85 db                	test   %ebx,%ebx
  8009d3:	75 d8                	jne    8009ad <strtol+0x44>
		s++, base = 8;
  8009d5:	83 c1 01             	add    $0x1,%ecx
  8009d8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009dd:	eb ce                	jmp    8009ad <strtol+0x44>
		s += 2, base = 16;
  8009df:	83 c1 02             	add    $0x2,%ecx
  8009e2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e7:	eb c4                	jmp    8009ad <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8009e9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ec:	89 f3                	mov    %esi,%ebx
  8009ee:	80 fb 19             	cmp    $0x19,%bl
  8009f1:	77 29                	ja     800a1c <strtol+0xb3>
			dig = *s - 'a' + 10;
  8009f3:	0f be d2             	movsbl %dl,%edx
  8009f6:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009f9:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009fc:	7d 30                	jge    800a2e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a05:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a07:	0f b6 11             	movzbl (%ecx),%edx
  800a0a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	80 fb 09             	cmp    $0x9,%bl
  800a12:	77 d5                	ja     8009e9 <strtol+0x80>
			dig = *s - '0';
  800a14:	0f be d2             	movsbl %dl,%edx
  800a17:	83 ea 30             	sub    $0x30,%edx
  800a1a:	eb dd                	jmp    8009f9 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a1c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	80 fb 19             	cmp    $0x19,%bl
  800a24:	77 08                	ja     800a2e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a26:	0f be d2             	movsbl %dl,%edx
  800a29:	83 ea 37             	sub    $0x37,%edx
  800a2c:	eb cb                	jmp    8009f9 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a32:	74 05                	je     800a39 <strtol+0xd0>
		*endptr = (char *) s;
  800a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a37:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a39:	89 c2                	mov    %eax,%edx
  800a3b:	f7 da                	neg    %edx
  800a3d:	85 ff                	test   %edi,%edi
  800a3f:	0f 45 c2             	cmovne %edx,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	83 ec 1c             	sub    $0x1c,%esp
  800a50:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a53:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a56:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a61:	8b 75 14             	mov    0x14(%ebp),%esi
  800a64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a66:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a6a:	74 04                	je     800a70 <syscall+0x29>
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	7f 08                	jg     800a78 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a73:	5b                   	pop    %ebx
  800a74:	5e                   	pop    %esi
  800a75:	5f                   	pop    %edi
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    
  800a78:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7b:	83 ec 0c             	sub    $0xc,%esp
  800a7e:	50                   	push   %eax
  800a7f:	52                   	push   %edx
  800a80:	68 a4 16 80 00       	push   $0x8016a4
  800a85:	6a 23                	push   $0x23
  800a87:	68 c1 16 80 00       	push   $0x8016c1
  800a8c:	e8 25 06 00 00       	call   8010b6 <_panic>

00800a91 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800a97:	6a 00                	push   $0x0
  800a99:	6a 00                	push   $0x0
  800a9b:	6a 00                	push   $0x0
  800a9d:	ff 75 0c             	pushl  0xc(%ebp)
  800aa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aad:	e8 95 ff ff ff       	call   800a47 <syscall>
}
  800ab2:	83 c4 10             	add    $0x10,%esp
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    

00800ab7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800abd:	6a 00                	push   $0x0
  800abf:	6a 00                	push   $0x0
  800ac1:	6a 00                	push   $0x0
  800ac3:	6a 00                	push   $0x0
  800ac5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aca:	ba 00 00 00 00       	mov    $0x0,%edx
  800acf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad4:	e8 6e ff ff ff       	call   800a47 <syscall>
}
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ae1:	6a 00                	push   $0x0
  800ae3:	6a 00                	push   $0x0
  800ae5:	6a 00                	push   $0x0
  800ae7:	6a 00                	push   $0x0
  800ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aec:	ba 01 00 00 00       	mov    $0x1,%edx
  800af1:	b8 03 00 00 00       	mov    $0x3,%eax
  800af6:	e8 4c ff ff ff       	call   800a47 <syscall>
}
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b03:	6a 00                	push   $0x0
  800b05:	6a 00                	push   $0x0
  800b07:	6a 00                	push   $0x0
  800b09:	6a 00                	push   $0x0
  800b0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1a:	e8 28 ff ff ff       	call   800a47 <syscall>
}
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <sys_yield>:

void
sys_yield(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b27:	6a 00                	push   $0x0
  800b29:	6a 00                	push   $0x0
  800b2b:	6a 00                	push   $0x0
  800b2d:	6a 00                	push   $0x0
  800b2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3e:	e8 04 ff ff ff       	call   800a47 <syscall>
}
  800b43:	83 c4 10             	add    $0x10,%esp
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b4e:	6a 00                	push   $0x0
  800b50:	6a 00                	push   $0x0
  800b52:	ff 75 10             	pushl  0x10(%ebp)
  800b55:	ff 75 0c             	pushl  0xc(%ebp)
  800b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5b:	ba 01 00 00 00       	mov    $0x1,%edx
  800b60:	b8 04 00 00 00       	mov    $0x4,%eax
  800b65:	e8 dd fe ff ff       	call   800a47 <syscall>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b72:	ff 75 18             	pushl  0x18(%ebp)
  800b75:	ff 75 14             	pushl  0x14(%ebp)
  800b78:	ff 75 10             	pushl  0x10(%ebp)
  800b7b:	ff 75 0c             	pushl  0xc(%ebp)
  800b7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b81:	ba 01 00 00 00       	mov    $0x1,%edx
  800b86:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8b:	e8 b7 fe ff ff       	call   800a47 <syscall>
}
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b98:	6a 00                	push   $0x0
  800b9a:	6a 00                	push   $0x0
  800b9c:	6a 00                	push   $0x0
  800b9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ba1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba4:	ba 01 00 00 00       	mov    $0x1,%edx
  800ba9:	b8 06 00 00 00       	mov    $0x6,%eax
  800bae:	e8 94 fe ff ff       	call   800a47 <syscall>
}
  800bb3:	c9                   	leave  
  800bb4:	c3                   	ret    

00800bb5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800bbb:	6a 00                	push   $0x0
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	ff 75 0c             	pushl  0xc(%ebp)
  800bc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc7:	ba 01 00 00 00       	mov    $0x1,%edx
  800bcc:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd1:	e8 71 fe ff ff       	call   800a47 <syscall>
}
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800bde:	6a 00                	push   $0x0
  800be0:	6a 00                	push   $0x0
  800be2:	6a 00                	push   $0x0
  800be4:	ff 75 0c             	pushl  0xc(%ebp)
  800be7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bea:	ba 01 00 00 00       	mov    $0x1,%edx
  800bef:	b8 09 00 00 00       	mov    $0x9,%eax
  800bf4:	e8 4e fe ff ff       	call   800a47 <syscall>
}
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c01:	6a 00                	push   $0x0
  800c03:	ff 75 14             	pushl  0x14(%ebp)
  800c06:	ff 75 10             	pushl  0x10(%ebp)
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c14:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c19:	e8 29 fe ff ff       	call   800a47 <syscall>
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	6a 00                	push   $0x0
  800c2c:	6a 00                	push   $0x0
  800c2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c31:	ba 01 00 00 00       	mov    $0x1,%edx
  800c36:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c3b:	e8 07 fe ff ff       	call   800a47 <syscall>
}
  800c40:	c9                   	leave  
  800c41:	c3                   	ret    

00800c42 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
	int r;

	void *addr = (void*)(pn << PGSHIFT);
  800c47:	89 d6                	mov    %edx,%esi
  800c49:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800c4c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800c53:	89 ca                	mov    %ecx,%edx
  800c55:	83 e2 05             	and    $0x5,%edx
  800c58:	83 fa 05             	cmp    $0x5,%edx
  800c5b:	75 5a                	jne    800cb7 <duppage+0x75>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800c5d:	89 ca                	mov    %ecx,%edx
  800c5f:	83 e2 18             	and    $0x18,%edx
		perm |= PTE_PCD | PTE_PWT;
  800c62:	83 fa 01             	cmp    $0x1,%edx
  800c65:	19 d2                	sbb    %edx,%edx
  800c67:	83 e2 e8             	and    $0xffffffe8,%edx
  800c6a:	83 c2 1d             	add    $0x1d,%edx


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800c6d:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800c73:	74 68                	je     800cdd <duppage+0x9b>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800c75:	89 d3                	mov    %edx,%ebx
  800c77:	80 cf 08             	or     $0x8,%bh
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	53                   	push   %ebx
  800c7e:	56                   	push   %esi
  800c7f:	50                   	push   %eax
  800c80:	56                   	push   %esi
  800c81:	6a 00                	push   $0x0
  800c83:	e8 e4 fe ff ff       	call   800b6c <sys_page_map>
  800c88:	83 c4 20             	add    $0x20,%esp
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	78 3c                	js     800ccb <duppage+0x89>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	53                   	push   %ebx
  800c93:	56                   	push   %esi
  800c94:	6a 00                	push   $0x0
  800c96:	56                   	push   %esi
  800c97:	6a 00                	push   $0x0
  800c99:	e8 ce fe ff ff       	call   800b6c <sys_page_map>
  800c9e:	83 c4 20             	add    $0x20,%esp
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	79 4d                	jns    800cf2 <duppage+0xb0>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800ca5:	50                   	push   %eax
  800ca6:	68 2c 17 80 00       	push   $0x80172c
  800cab:	6a 57                	push   $0x57
  800cad:	68 21 18 80 00       	push   $0x801821
  800cb2:	e8 ff 03 00 00       	call   8010b6 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800cb7:	83 ec 04             	sub    $0x4,%esp
  800cba:	68 d0 16 80 00       	push   $0x8016d0
  800cbf:	6a 47                	push   $0x47
  800cc1:	68 21 18 80 00       	push   $0x801821
  800cc6:	e8 eb 03 00 00       	call   8010b6 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800ccb:	50                   	push   %eax
  800ccc:	68 00 17 80 00       	push   $0x801700
  800cd1:	6a 53                	push   $0x53
  800cd3:	68 21 18 80 00       	push   $0x801821
  800cd8:	e8 d9 03 00 00       	call   8010b6 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800cdd:	83 ec 0c             	sub    $0xc,%esp
  800ce0:	52                   	push   %edx
  800ce1:	56                   	push   %esi
  800ce2:	50                   	push   %eax
  800ce3:	56                   	push   %esi
  800ce4:	6a 00                	push   $0x0
  800ce6:	e8 81 fe ff ff       	call   800b6c <sys_page_map>
  800ceb:	83 c4 20             	add    $0x20,%esp
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	78 0c                	js     800cfe <duppage+0xbc>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800cfe:	50                   	push   %eax
  800cff:	68 54 17 80 00       	push   $0x801754
  800d04:	6a 5b                	push   $0x5b
  800d06:	68 21 18 80 00       	push   $0x801821
  800d0b:	e8 a6 03 00 00       	call   8010b6 <_panic>

00800d10 <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 0c             	sub    $0xc,%esp
  800d19:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void*)(pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800d1b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800d22:	a8 01                	test   $0x1,%al
  800d24:	74 38                	je     800d5e <dup_or_share+0x4e>
  800d26:	89 cb                	mov    %ecx,%ebx
  800d28:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800d2a:	21 c3                	and    %eax,%ebx
  800d2c:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
  800d2f:	89 c1                	mov    %eax,%ecx
  800d31:	83 e1 18             	and    $0x18,%ecx
		perm |= PTE_PCD | PTE_PWT;
  800d34:	89 da                	mov    %ebx,%edx
  800d36:	83 ca 18             	or     $0x18,%edx
  800d39:	85 c9                	test   %ecx,%ecx
  800d3b:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void*)(pnum << PGSHIFT);
  800d3e:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800d41:	83 e0 1a             	and    $0x1a,%eax
  800d44:	83 f8 02             	cmp    $0x2,%eax
  800d47:	74 32                	je     800d7b <dup_or_share+0x6b>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	53                   	push   %ebx
  800d4d:	56                   	push   %esi
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	6a 00                	push   $0x0
  800d52:	e8 15 fe ff ff       	call   800b6c <sys_page_map>
  800d57:	83 c4 20             	add    $0x20,%esp
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	78 08                	js     800d66 <dup_or_share+0x56>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800d66:	50                   	push   %eax
  800d67:	68 80 17 80 00       	push   $0x801780
  800d6c:	68 84 00 00 00       	push   $0x84
  800d71:	68 21 18 80 00       	push   $0x801821
  800d76:	e8 3b 03 00 00       	call   8010b6 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800d7b:	83 ec 04             	sub    $0x4,%esp
  800d7e:	53                   	push   %ebx
  800d7f:	56                   	push   %esi
  800d80:	57                   	push   %edi
  800d81:	e8 c2 fd ff ff       	call   800b48 <sys_page_alloc>
  800d86:	83 c4 10             	add    $0x10,%esp
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	78 57                	js     800de4 <dup_or_share+0xd4>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	53                   	push   %ebx
  800d91:	68 00 00 40 00       	push   $0x400000
  800d96:	6a 00                	push   $0x0
  800d98:	56                   	push   %esi
  800d99:	57                   	push   %edi
  800d9a:	e8 cd fd ff ff       	call   800b6c <sys_page_map>
  800d9f:	83 c4 20             	add    $0x20,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	78 53                	js     800df9 <dup_or_share+0xe9>
		memmove(UTEMP, addr, PGSIZE);
  800da6:	83 ec 04             	sub    $0x4,%esp
  800da9:	68 00 10 00 00       	push   $0x1000
  800dae:	56                   	push   %esi
  800daf:	68 00 00 40 00       	push   $0x400000
  800db4:	e8 df fa ff ff       	call   800898 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800db9:	83 c4 08             	add    $0x8,%esp
  800dbc:	68 00 00 40 00       	push   $0x400000
  800dc1:	6a 00                	push   $0x0
  800dc3:	e8 ca fd ff ff       	call   800b92 <sys_page_unmap>
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	79 8f                	jns    800d5e <dup_or_share+0x4e>
			panic("sys_page_unmap: %e", r);
  800dcf:	50                   	push   %eax
  800dd0:	68 6b 18 80 00       	push   $0x80186b
  800dd5:	68 8d 00 00 00       	push   $0x8d
  800dda:	68 21 18 80 00       	push   $0x801821
  800ddf:	e8 d2 02 00 00       	call   8010b6 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800de4:	50                   	push   %eax
  800de5:	68 a0 17 80 00       	push   $0x8017a0
  800dea:	68 88 00 00 00       	push   $0x88
  800def:	68 21 18 80 00       	push   $0x801821
  800df4:	e8 bd 02 00 00       	call   8010b6 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800df9:	50                   	push   %eax
  800dfa:	68 80 17 80 00       	push   $0x801780
  800dff:	68 8a 00 00 00       	push   $0x8a
  800e04:	68 21 18 80 00       	push   $0x801821
  800e09:	e8 a8 02 00 00       	call   8010b6 <_panic>

00800e0e <pgfault>:
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	53                   	push   %ebx
  800e12:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t)addr) >> PGSHIFT];
  800e1a:	89 d8                	mov    %ebx,%eax
  800e1c:	c1 e8 0c             	shr    $0xc,%eax
  800e1f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800e26:	6a 07                	push   $0x7
  800e28:	68 00 f0 7f 00       	push   $0x7ff000
  800e2d:	6a 00                	push   $0x0
  800e2f:	e8 14 fd ff ff       	call   800b48 <sys_page_alloc>
  800e34:	83 c4 10             	add    $0x10,%esp
  800e37:	85 c0                	test   %eax,%eax
  800e39:	78 51                	js     800e8c <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800e3b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e41:	83 ec 04             	sub    $0x4,%esp
  800e44:	68 00 10 00 00       	push   $0x1000
  800e49:	53                   	push   %ebx
  800e4a:	68 00 f0 7f 00       	push   $0x7ff000
  800e4f:	e8 44 fa ff ff       	call   800898 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800e54:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e5b:	53                   	push   %ebx
  800e5c:	6a 00                	push   $0x0
  800e5e:	68 00 f0 7f 00       	push   $0x7ff000
  800e63:	6a 00                	push   $0x0
  800e65:	e8 02 fd ff ff       	call   800b6c <sys_page_map>
  800e6a:	83 c4 20             	add    $0x20,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	78 2d                	js     800e9e <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	68 00 f0 7f 00       	push   $0x7ff000
  800e79:	6a 00                	push   $0x0
  800e7b:	e8 12 fd ff ff       	call   800b92 <sys_page_unmap>
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	85 c0                	test   %eax,%eax
  800e85:	78 29                	js     800eb0 <pgfault+0xa2>
}
  800e87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800e8c:	50                   	push   %eax
  800e8d:	68 2c 18 80 00       	push   $0x80182c
  800e92:	6a 27                	push   $0x27
  800e94:	68 21 18 80 00       	push   $0x801821
  800e99:	e8 18 02 00 00       	call   8010b6 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800e9e:	50                   	push   %eax
  800e9f:	68 48 18 80 00       	push   $0x801848
  800ea4:	6a 2c                	push   $0x2c
  800ea6:	68 21 18 80 00       	push   $0x801821
  800eab:	e8 06 02 00 00       	call   8010b6 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800eb0:	50                   	push   %eax
  800eb1:	68 62 18 80 00       	push   $0x801862
  800eb6:	6a 2f                	push   $0x2f
  800eb8:	68 21 18 80 00       	push   $0x801821
  800ebd:	e8 f4 01 00 00       	call   8010b6 <_panic>

00800ec2 <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ecb:	b8 07 00 00 00       	mov    $0x7,%eax
  800ed0:	cd 30                	int    $0x30
  800ed2:	89 c7                	mov    %eax,%edi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	78 24                	js     800efc <fork_v0+0x3a>
  800ed8:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800eda:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	75 39                	jne    800f1c <fork_v0+0x5a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ee3:	e8 15 fc ff ff       	call   800afd <sys_getenvid>
  800ee8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eed:	c1 e0 07             	shl    $0x7,%eax
  800ef0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ef5:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800efa:	eb 56                	jmp    800f52 <fork_v0+0x90>
		panic("sys_exofork: %e", envid);
  800efc:	50                   	push   %eax
  800efd:	68 7e 18 80 00       	push   $0x80187e
  800f02:	68 a2 00 00 00       	push   $0xa2
  800f07:	68 21 18 80 00       	push   $0x801821
  800f0c:	e8 a5 01 00 00       	call   8010b6 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f11:	83 c3 01             	add    $0x1,%ebx
  800f14:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800f1a:	74 24                	je     800f40 <fork_v0+0x7e>
		pde_t pde = uvpd[pnum >> 10];
  800f1c:	89 d8                	mov    %ebx,%eax
  800f1e:	c1 e8 0a             	shr    $0xa,%eax
  800f21:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800f28:	83 e0 05             	and    $0x5,%eax
  800f2b:	83 f8 05             	cmp    $0x5,%eax
  800f2e:	75 e1                	jne    800f11 <fork_v0+0x4f>
			continue;
		dup_or_share(envid, pnum, perm);
  800f30:	b9 07 00 00 00       	mov    $0x7,%ecx
  800f35:	89 da                	mov    %ebx,%edx
  800f37:	89 f0                	mov    %esi,%eax
  800f39:	e8 d2 fd ff ff       	call   800d10 <dup_or_share>
  800f3e:	eb d1                	jmp    800f11 <fork_v0+0x4f>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800f40:	83 ec 08             	sub    $0x8,%esp
  800f43:	6a 02                	push   $0x2
  800f45:	57                   	push   %edi
  800f46:	e8 6a fc ff ff       	call   800bb5 <sys_env_set_status>
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 0a                	js     800f5c <fork_v0+0x9a>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800f52:	89 f8                	mov    %edi,%eax
  800f54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f57:	5b                   	pop    %ebx
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800f5c:	50                   	push   %eax
  800f5d:	68 8e 18 80 00       	push   $0x80188e
  800f62:	68 b8 00 00 00       	push   $0xb8
  800f67:	68 21 18 80 00       	push   $0x801821
  800f6c:	e8 45 01 00 00       	call   8010b6 <_panic>

00800f71 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800f7a:	68 0e 0e 80 00       	push   $0x800e0e
  800f7f:	e8 78 01 00 00       	call   8010fc <set_pgfault_handler>
  800f84:	b8 07 00 00 00       	mov    $0x7,%eax
  800f89:	cd 30                	int    $0x30
  800f8b:	89 c7                	mov    %eax,%edi

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 27                	js     800fbb <fork+0x4a>
  800f94:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f96:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	75 44                	jne    800fe3 <fork+0x72>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f9f:	e8 59 fb ff ff       	call   800afd <sys_getenvid>
  800fa4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa9:	c1 e0 07             	shl    $0x7,%eax
  800fac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fb1:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800fb6:	e9 98 00 00 00       	jmp    801053 <fork+0xe2>
		panic("sys_exofork: %e", envid);
  800fbb:	50                   	push   %eax
  800fbc:	68 7e 18 80 00       	push   $0x80187e
  800fc1:	68 d6 00 00 00       	push   $0xd6
  800fc6:	68 21 18 80 00       	push   $0x801821
  800fcb:	e8 e6 00 00 00       	call   8010b6 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fd0:	83 c3 01             	add    $0x1,%ebx
  800fd3:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800fd9:	77 36                	ja     801011 <fork+0xa0>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  800fdb:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800fe1:	74 ed                	je     800fd0 <fork+0x5f>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  800fe3:	89 d8                	mov    %ebx,%eax
  800fe5:	c1 e8 0a             	shr    $0xa,%eax
  800fe8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800fef:	83 e0 05             	and    $0x5,%eax
  800ff2:	83 f8 05             	cmp    $0x5,%eax
  800ff5:	75 d9                	jne    800fd0 <fork+0x5f>
			continue;

		pte_t pte = uvpt[pnum];
  800ff7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  800ffe:	83 e0 05             	and    $0x5,%eax
  801001:	83 f8 05             	cmp    $0x5,%eax
  801004:	75 ca                	jne    800fd0 <fork+0x5f>
			continue;
		duppage(envid, pnum);
  801006:	89 da                	mov    %ebx,%edx
  801008:	89 f0                	mov    %esi,%eax
  80100a:	e8 33 fc ff ff       	call   800c42 <duppage>
  80100f:	eb bf                	jmp    800fd0 <fork+0x5f>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void*)exstk, PTE_U | PTE_P | PTE_W);
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	6a 07                	push   $0x7
  801016:	68 00 f0 bf ee       	push   $0xeebff000
  80101b:	57                   	push   %edi
  80101c:	e8 27 fb ff ff       	call   800b48 <sys_page_alloc>
	if (r < 0)
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	78 35                	js     80105d <fork+0xec>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801028:	a1 04 20 80 00       	mov    0x802004,%eax
  80102d:	8b 40 68             	mov    0x68(%eax),%eax
  801030:	83 ec 08             	sub    $0x8,%esp
  801033:	50                   	push   %eax
  801034:	57                   	push   %edi
  801035:	e8 9e fb ff ff       	call   800bd8 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 31                	js     801072 <fork+0x101>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801041:	83 ec 08             	sub    $0x8,%esp
  801044:	6a 02                	push   $0x2
  801046:	57                   	push   %edi
  801047:	e8 69 fb ff ff       	call   800bb5 <sys_env_set_status>
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 34                	js     801087 <fork+0x116>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  801053:	89 f8                	mov    %edi,%eax
  801055:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  80105d:	50                   	push   %eax
  80105e:	68 c4 17 80 00       	push   $0x8017c4
  801063:	68 f3 00 00 00       	push   $0xf3
  801068:	68 21 18 80 00       	push   $0x801821
  80106d:	e8 44 00 00 00       	call   8010b6 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  801072:	50                   	push   %eax
  801073:	68 f0 17 80 00       	push   $0x8017f0
  801078:	68 f6 00 00 00       	push   $0xf6
  80107d:	68 21 18 80 00       	push   $0x801821
  801082:	e8 2f 00 00 00       	call   8010b6 <_panic>
		panic("sys_env_set_status: %e", r);
  801087:	50                   	push   %eax
  801088:	68 8e 18 80 00       	push   $0x80188e
  80108d:	68 f9 00 00 00       	push   $0xf9
  801092:	68 21 18 80 00       	push   $0x801821
  801097:	e8 1a 00 00 00       	call   8010b6 <_panic>

0080109c <sfork>:

// Challenge!
int
sfork(void)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010a2:	68 a5 18 80 00       	push   $0x8018a5
  8010a7:	68 02 01 00 00       	push   $0x102
  8010ac:	68 21 18 80 00       	push   $0x801821
  8010b1:	e8 00 00 00 00       	call   8010b6 <_panic>

008010b6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	56                   	push   %esi
  8010ba:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010bb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010be:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010c4:	e8 34 fa ff ff       	call   800afd <sys_getenvid>
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	ff 75 0c             	pushl  0xc(%ebp)
  8010cf:	ff 75 08             	pushl  0x8(%ebp)
  8010d2:	56                   	push   %esi
  8010d3:	50                   	push   %eax
  8010d4:	68 bc 18 80 00       	push   $0x8018bc
  8010d9:	e8 c8 f0 ff ff       	call   8001a6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010de:	83 c4 18             	add    $0x18,%esp
  8010e1:	53                   	push   %ebx
  8010e2:	ff 75 10             	pushl  0x10(%ebp)
  8010e5:	e8 6b f0 ff ff       	call   800155 <vcprintf>
	cprintf("\n");
  8010ea:	c7 04 24 54 14 80 00 	movl   $0x801454,(%esp)
  8010f1:	e8 b0 f0 ff ff       	call   8001a6 <cprintf>
  8010f6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010f9:	cc                   	int3   
  8010fa:	eb fd                	jmp    8010f9 <_panic+0x43>

008010fc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801102:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801109:	74 0a                	je     801115 <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801113:	c9                   	leave  
  801114:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	6a 07                	push   $0x7
  80111a:	68 00 f0 bf ee       	push   $0xeebff000
  80111f:	6a 00                	push   $0x0
  801121:	e8 22 fa ff ff       	call   800b48 <sys_page_alloc>
		if (r < 0) return;
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 e6                	js     801113 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	68 45 11 80 00       	push   $0x801145
  801135:	6a 00                	push   $0x0
  801137:	e8 9c fa ff ff       	call   800bd8 <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	79 c8                	jns    80110b <set_pgfault_handler+0xf>
  801143:	eb ce                	jmp    801113 <set_pgfault_handler+0x17>

00801145 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801145:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801146:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80114b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80114d:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801150:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801154:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  801158:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  80115b:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  80115d:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  801161:	58                   	pop    %eax
	popl %eax
  801162:	58                   	pop    %eax
	popal
  801163:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  801164:	83 c4 04             	add    $0x4,%esp
	popfl
  801167:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  801168:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  801169:	c3                   	ret    
  80116a:	66 90                	xchg   %ax,%ax
  80116c:	66 90                	xchg   %ax,%ax
  80116e:	66 90                	xchg   %ax,%ax

00801170 <__udivdi3>:
  801170:	55                   	push   %ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 1c             	sub    $0x1c,%esp
  801177:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80117b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80117f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801183:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801187:	85 d2                	test   %edx,%edx
  801189:	75 35                	jne    8011c0 <__udivdi3+0x50>
  80118b:	39 f3                	cmp    %esi,%ebx
  80118d:	0f 87 bd 00 00 00    	ja     801250 <__udivdi3+0xe0>
  801193:	85 db                	test   %ebx,%ebx
  801195:	89 d9                	mov    %ebx,%ecx
  801197:	75 0b                	jne    8011a4 <__udivdi3+0x34>
  801199:	b8 01 00 00 00       	mov    $0x1,%eax
  80119e:	31 d2                	xor    %edx,%edx
  8011a0:	f7 f3                	div    %ebx
  8011a2:	89 c1                	mov    %eax,%ecx
  8011a4:	31 d2                	xor    %edx,%edx
  8011a6:	89 f0                	mov    %esi,%eax
  8011a8:	f7 f1                	div    %ecx
  8011aa:	89 c6                	mov    %eax,%esi
  8011ac:	89 e8                	mov    %ebp,%eax
  8011ae:	89 f7                	mov    %esi,%edi
  8011b0:	f7 f1                	div    %ecx
  8011b2:	89 fa                	mov    %edi,%edx
  8011b4:	83 c4 1c             	add    $0x1c,%esp
  8011b7:	5b                   	pop    %ebx
  8011b8:	5e                   	pop    %esi
  8011b9:	5f                   	pop    %edi
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    
  8011bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	39 f2                	cmp    %esi,%edx
  8011c2:	77 7c                	ja     801240 <__udivdi3+0xd0>
  8011c4:	0f bd fa             	bsr    %edx,%edi
  8011c7:	83 f7 1f             	xor    $0x1f,%edi
  8011ca:	0f 84 98 00 00 00    	je     801268 <__udivdi3+0xf8>
  8011d0:	89 f9                	mov    %edi,%ecx
  8011d2:	b8 20 00 00 00       	mov    $0x20,%eax
  8011d7:	29 f8                	sub    %edi,%eax
  8011d9:	d3 e2                	shl    %cl,%edx
  8011db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8011df:	89 c1                	mov    %eax,%ecx
  8011e1:	89 da                	mov    %ebx,%edx
  8011e3:	d3 ea                	shr    %cl,%edx
  8011e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011e9:	09 d1                	or     %edx,%ecx
  8011eb:	89 f2                	mov    %esi,%edx
  8011ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011f1:	89 f9                	mov    %edi,%ecx
  8011f3:	d3 e3                	shl    %cl,%ebx
  8011f5:	89 c1                	mov    %eax,%ecx
  8011f7:	d3 ea                	shr    %cl,%edx
  8011f9:	89 f9                	mov    %edi,%ecx
  8011fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011ff:	d3 e6                	shl    %cl,%esi
  801201:	89 eb                	mov    %ebp,%ebx
  801203:	89 c1                	mov    %eax,%ecx
  801205:	d3 eb                	shr    %cl,%ebx
  801207:	09 de                	or     %ebx,%esi
  801209:	89 f0                	mov    %esi,%eax
  80120b:	f7 74 24 08          	divl   0x8(%esp)
  80120f:	89 d6                	mov    %edx,%esi
  801211:	89 c3                	mov    %eax,%ebx
  801213:	f7 64 24 0c          	mull   0xc(%esp)
  801217:	39 d6                	cmp    %edx,%esi
  801219:	72 0c                	jb     801227 <__udivdi3+0xb7>
  80121b:	89 f9                	mov    %edi,%ecx
  80121d:	d3 e5                	shl    %cl,%ebp
  80121f:	39 c5                	cmp    %eax,%ebp
  801221:	73 5d                	jae    801280 <__udivdi3+0x110>
  801223:	39 d6                	cmp    %edx,%esi
  801225:	75 59                	jne    801280 <__udivdi3+0x110>
  801227:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80122a:	31 ff                	xor    %edi,%edi
  80122c:	89 fa                	mov    %edi,%edx
  80122e:	83 c4 1c             	add    $0x1c,%esp
  801231:	5b                   	pop    %ebx
  801232:	5e                   	pop    %esi
  801233:	5f                   	pop    %edi
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    
  801236:	8d 76 00             	lea    0x0(%esi),%esi
  801239:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801240:	31 ff                	xor    %edi,%edi
  801242:	31 c0                	xor    %eax,%eax
  801244:	89 fa                	mov    %edi,%edx
  801246:	83 c4 1c             	add    $0x1c,%esp
  801249:	5b                   	pop    %ebx
  80124a:	5e                   	pop    %esi
  80124b:	5f                   	pop    %edi
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    
  80124e:	66 90                	xchg   %ax,%ax
  801250:	31 ff                	xor    %edi,%edi
  801252:	89 e8                	mov    %ebp,%eax
  801254:	89 f2                	mov    %esi,%edx
  801256:	f7 f3                	div    %ebx
  801258:	89 fa                	mov    %edi,%edx
  80125a:	83 c4 1c             	add    $0x1c,%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    
  801262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801268:	39 f2                	cmp    %esi,%edx
  80126a:	72 06                	jb     801272 <__udivdi3+0x102>
  80126c:	31 c0                	xor    %eax,%eax
  80126e:	39 eb                	cmp    %ebp,%ebx
  801270:	77 d2                	ja     801244 <__udivdi3+0xd4>
  801272:	b8 01 00 00 00       	mov    $0x1,%eax
  801277:	eb cb                	jmp    801244 <__udivdi3+0xd4>
  801279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 d8                	mov    %ebx,%eax
  801282:	31 ff                	xor    %edi,%edi
  801284:	eb be                	jmp    801244 <__udivdi3+0xd4>
  801286:	66 90                	xchg   %ax,%ax
  801288:	66 90                	xchg   %ax,%ax
  80128a:	66 90                	xchg   %ax,%ax
  80128c:	66 90                	xchg   %ax,%ax
  80128e:	66 90                	xchg   %ax,%ax

00801290 <__umoddi3>:
  801290:	55                   	push   %ebp
  801291:	57                   	push   %edi
  801292:	56                   	push   %esi
  801293:	53                   	push   %ebx
  801294:	83 ec 1c             	sub    $0x1c,%esp
  801297:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80129b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80129f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8012a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012a7:	85 ed                	test   %ebp,%ebp
  8012a9:	89 f0                	mov    %esi,%eax
  8012ab:	89 da                	mov    %ebx,%edx
  8012ad:	75 19                	jne    8012c8 <__umoddi3+0x38>
  8012af:	39 df                	cmp    %ebx,%edi
  8012b1:	0f 86 b1 00 00 00    	jbe    801368 <__umoddi3+0xd8>
  8012b7:	f7 f7                	div    %edi
  8012b9:	89 d0                	mov    %edx,%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	83 c4 1c             	add    $0x1c,%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    
  8012c5:	8d 76 00             	lea    0x0(%esi),%esi
  8012c8:	39 dd                	cmp    %ebx,%ebp
  8012ca:	77 f1                	ja     8012bd <__umoddi3+0x2d>
  8012cc:	0f bd cd             	bsr    %ebp,%ecx
  8012cf:	83 f1 1f             	xor    $0x1f,%ecx
  8012d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012d6:	0f 84 b4 00 00 00    	je     801390 <__umoddi3+0x100>
  8012dc:	b8 20 00 00 00       	mov    $0x20,%eax
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8012e7:	29 c2                	sub    %eax,%edx
  8012e9:	89 c1                	mov    %eax,%ecx
  8012eb:	89 f8                	mov    %edi,%eax
  8012ed:	d3 e5                	shl    %cl,%ebp
  8012ef:	89 d1                	mov    %edx,%ecx
  8012f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012f5:	d3 e8                	shr    %cl,%eax
  8012f7:	09 c5                	or     %eax,%ebp
  8012f9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8012fd:	89 c1                	mov    %eax,%ecx
  8012ff:	d3 e7                	shl    %cl,%edi
  801301:	89 d1                	mov    %edx,%ecx
  801303:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801307:	89 df                	mov    %ebx,%edi
  801309:	d3 ef                	shr    %cl,%edi
  80130b:	89 c1                	mov    %eax,%ecx
  80130d:	89 f0                	mov    %esi,%eax
  80130f:	d3 e3                	shl    %cl,%ebx
  801311:	89 d1                	mov    %edx,%ecx
  801313:	89 fa                	mov    %edi,%edx
  801315:	d3 e8                	shr    %cl,%eax
  801317:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80131c:	09 d8                	or     %ebx,%eax
  80131e:	f7 f5                	div    %ebp
  801320:	d3 e6                	shl    %cl,%esi
  801322:	89 d1                	mov    %edx,%ecx
  801324:	f7 64 24 08          	mull   0x8(%esp)
  801328:	39 d1                	cmp    %edx,%ecx
  80132a:	89 c3                	mov    %eax,%ebx
  80132c:	89 d7                	mov    %edx,%edi
  80132e:	72 06                	jb     801336 <__umoddi3+0xa6>
  801330:	75 0e                	jne    801340 <__umoddi3+0xb0>
  801332:	39 c6                	cmp    %eax,%esi
  801334:	73 0a                	jae    801340 <__umoddi3+0xb0>
  801336:	2b 44 24 08          	sub    0x8(%esp),%eax
  80133a:	19 ea                	sbb    %ebp,%edx
  80133c:	89 d7                	mov    %edx,%edi
  80133e:	89 c3                	mov    %eax,%ebx
  801340:	89 ca                	mov    %ecx,%edx
  801342:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801347:	29 de                	sub    %ebx,%esi
  801349:	19 fa                	sbb    %edi,%edx
  80134b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80134f:	89 d0                	mov    %edx,%eax
  801351:	d3 e0                	shl    %cl,%eax
  801353:	89 d9                	mov    %ebx,%ecx
  801355:	d3 ee                	shr    %cl,%esi
  801357:	d3 ea                	shr    %cl,%edx
  801359:	09 f0                	or     %esi,%eax
  80135b:	83 c4 1c             	add    $0x1c,%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5f                   	pop    %edi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    
  801363:	90                   	nop
  801364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801368:	85 ff                	test   %edi,%edi
  80136a:	89 f9                	mov    %edi,%ecx
  80136c:	75 0b                	jne    801379 <__umoddi3+0xe9>
  80136e:	b8 01 00 00 00       	mov    $0x1,%eax
  801373:	31 d2                	xor    %edx,%edx
  801375:	f7 f7                	div    %edi
  801377:	89 c1                	mov    %eax,%ecx
  801379:	89 d8                	mov    %ebx,%eax
  80137b:	31 d2                	xor    %edx,%edx
  80137d:	f7 f1                	div    %ecx
  80137f:	89 f0                	mov    %esi,%eax
  801381:	f7 f1                	div    %ecx
  801383:	e9 31 ff ff ff       	jmp    8012b9 <__umoddi3+0x29>
  801388:	90                   	nop
  801389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801390:	39 dd                	cmp    %ebx,%ebp
  801392:	72 08                	jb     80139c <__umoddi3+0x10c>
  801394:	39 f7                	cmp    %esi,%edi
  801396:	0f 87 21 ff ff ff    	ja     8012bd <__umoddi3+0x2d>
  80139c:	89 da                	mov    %ebx,%edx
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	29 f8                	sub    %edi,%eax
  8013a2:	19 ea                	sbb    %ebp,%edx
  8013a4:	e9 14 ff ff ff       	jmp    8012bd <__umoddi3+0x2d>
