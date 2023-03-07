
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 80 0e 80 00       	push   $0x800e80
  800056:	e8 f6 00 00 00       	call   800151 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80006b:	e8 38 0a 00 00       	call   800aa8 <sys_getenvid>
	if (id >= 0)
  800070:	85 c0                	test   %eax,%eax
  800072:	78 12                	js     800086 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800074:	25 ff 03 00 00       	and    $0x3ff,%eax
  800079:	c1 e0 07             	shl    $0x7,%eax
  80007c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800081:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800086:	85 db                	test   %ebx,%ebx
  800088:	7e 07                	jle    800091 <libmain+0x31>
		binaryname = argv[0];
  80008a:	8b 06                	mov    (%esi),%eax
  80008c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	56                   	push   %esi
  800095:	53                   	push   %ebx
  800096:	e8 98 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009b:	e8 0a 00 00 00       	call   8000aa <exit>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a6:	5b                   	pop    %ebx
  8000a7:	5e                   	pop    %esi
  8000a8:	5d                   	pop    %ebp
  8000a9:	c3                   	ret    

008000aa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b0:	6a 00                	push   $0x0
  8000b2:	e8 cf 09 00 00       	call   800a86 <sys_env_destroy>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	53                   	push   %ebx
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c6:	8b 13                	mov    (%ebx),%edx
  8000c8:	8d 42 01             	lea    0x1(%edx),%eax
  8000cb:	89 03                	mov    %eax,(%ebx)
  8000cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d9:	74 09                	je     8000e4 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000db:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e4:	83 ec 08             	sub    $0x8,%esp
  8000e7:	68 ff 00 00 00       	push   $0xff
  8000ec:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ef:	50                   	push   %eax
  8000f0:	e8 47 09 00 00       	call   800a3c <sys_cputs>
		b->idx = 0;
  8000f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fb:	83 c4 10             	add    $0x10,%esp
  8000fe:	eb db                	jmp    8000db <putch+0x1f>

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 bc 00 80 00       	push   $0x8000bc
  80012f:	e8 86 01 00 00       	call   8002ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 f3 08 00 00       	call   800a3c <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018c:	39 d3                	cmp    %edx,%ebx
  80018e:	72 05                	jb     800195 <printnum+0x30>
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 7a                	ja     80020f <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	8b 45 14             	mov    0x14(%ebp),%eax
  80019e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a1:	53                   	push   %ebx
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 87 0a 00 00       	call   800c40 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 13                	jmp    8001df <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	85 db                	test   %ebx,%ebx
  8001dd:	7f ed                	jg     8001cc <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f2:	e8 69 0b 00 00       	call   800d60 <__umoddi3>
  8001f7:	83 c4 14             	add    $0x14,%esp
  8001fa:	0f be 80 98 0e 80 00 	movsbl 0x800e98(%eax),%eax
  800201:	50                   	push   %eax
  800202:	ff d7                	call   *%edi
}
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    
  80020f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800212:	eb c4                	jmp    8001d8 <printnum+0x73>

00800214 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800217:	83 fa 01             	cmp    $0x1,%edx
  80021a:	7e 0e                	jle    80022a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800221:	89 08                	mov    %ecx,(%eax)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    
	else if (lflag)
  80022a:	85 d2                	test   %edx,%edx
  80022c:	75 10                	jne    80023e <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
  80023c:	eb ea                	jmp    800228 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 04             	lea    0x4(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	ba 00 00 00 00       	mov    $0x0,%edx
  80024c:	eb da                	jmp    800228 <getuint+0x14>

0080024e <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800251:	83 fa 01             	cmp    $0x1,%edx
  800254:	7e 0e                	jle    800264 <getint+0x16>
		return va_arg(*ap, long long);
  800256:	8b 10                	mov    (%eax),%edx
  800258:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025b:	89 08                	mov    %ecx,(%eax)
  80025d:	8b 02                	mov    (%edx),%eax
  80025f:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    
	else if (lflag)
  800264:	85 d2                	test   %edx,%edx
  800266:	75 0c                	jne    800274 <getint+0x26>
		return va_arg(*ap, int);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	99                   	cltd   
  800272:	eb ee                	jmp    800262 <getint+0x14>
		return va_arg(*ap, long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	99                   	cltd   
  80027e:	eb e2                	jmp    800262 <getint+0x14>

00800280 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800286:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	3b 50 04             	cmp    0x4(%eax),%edx
  80028f:	73 0a                	jae    80029b <sprintputch+0x1b>
		*b->buf++ = ch;
  800291:	8d 4a 01             	lea    0x1(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	88 02                	mov    %al,(%edx)
}
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <printfmt>:
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a6:	50                   	push   %eax
  8002a7:	ff 75 10             	pushl  0x10(%ebp)
  8002aa:	ff 75 0c             	pushl  0xc(%ebp)
  8002ad:	ff 75 08             	pushl  0x8(%ebp)
  8002b0:	e8 05 00 00 00       	call   8002ba <vprintfmt>
}
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <vprintfmt>:
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	57                   	push   %edi
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 2c             	sub    $0x2c,%esp
  8002c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002c9:	89 f7                	mov    %esi,%edi
  8002cb:	89 de                	mov    %ebx,%esi
  8002cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d0:	e9 9e 02 00 00       	jmp    800573 <vprintfmt+0x2b9>
		padc = ' ';
  8002d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8002f3:	8d 43 01             	lea    0x1(%ebx),%eax
  8002f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f9:	0f b6 0b             	movzbl (%ebx),%ecx
  8002fc:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8002ff:	3c 55                	cmp    $0x55,%al
  800301:	0f 87 e8 02 00 00    	ja     8005ef <vprintfmt+0x335>
  800307:	0f b6 c0             	movzbl %al,%eax
  80030a:	ff 24 85 60 0f 80 00 	jmp    *0x800f60(,%eax,4)
  800311:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800314:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800318:	eb d9                	jmp    8002f3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  80031d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800321:	eb d0                	jmp    8002f3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800323:	0f b6 c9             	movzbl %cl,%ecx
  800326:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800329:	b8 00 00 00 00       	mov    $0x0,%eax
  80032e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800331:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800334:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800338:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80033b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80033e:	83 fa 09             	cmp    $0x9,%edx
  800341:	77 52                	ja     800395 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800343:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800346:	eb e9                	jmp    800331 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800348:	8b 45 14             	mov    0x14(%ebp),%eax
  80034b:	8d 48 04             	lea    0x4(%eax),%ecx
  80034e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800351:	8b 00                	mov    (%eax),%eax
  800353:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800359:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035d:	79 94                	jns    8002f3 <vprintfmt+0x39>
				width = precision, precision = -1;
  80035f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800362:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	eb 85                	jmp    8002f3 <vprintfmt+0x39>
  80036e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800371:	85 c0                	test   %eax,%eax
  800373:	b9 00 00 00 00       	mov    $0x0,%ecx
  800378:	0f 49 c8             	cmovns %eax,%ecx
  80037b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800381:	e9 6d ff ff ff       	jmp    8002f3 <vprintfmt+0x39>
  800386:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800389:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800390:	e9 5e ff ff ff       	jmp    8002f3 <vprintfmt+0x39>
  800395:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039b:	eb bc                	jmp    800359 <vprintfmt+0x9f>
			lflag++;
  80039d:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003a3:	e9 4b ff ff ff       	jmp    8002f3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 50 04             	lea    0x4(%eax),%edx
  8003ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	57                   	push   %edi
  8003b5:	ff 30                	pushl  (%eax)
  8003b7:	ff d6                	call   *%esi
			break;
  8003b9:	83 c4 10             	add    $0x10,%esp
  8003bc:	e9 af 01 00 00       	jmp    800570 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 50 04             	lea    0x4(%eax),%edx
  8003c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	99                   	cltd   
  8003cd:	31 d0                	xor    %edx,%eax
  8003cf:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d1:	83 f8 08             	cmp    $0x8,%eax
  8003d4:	7f 20                	jg     8003f6 <vprintfmt+0x13c>
  8003d6:	8b 14 85 c0 10 80 00 	mov    0x8010c0(,%eax,4),%edx
  8003dd:	85 d2                	test   %edx,%edx
  8003df:	74 15                	je     8003f6 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  8003e1:	52                   	push   %edx
  8003e2:	68 b9 0e 80 00       	push   $0x800eb9
  8003e7:	57                   	push   %edi
  8003e8:	56                   	push   %esi
  8003e9:	e8 af fe ff ff       	call   80029d <printfmt>
  8003ee:	83 c4 10             	add    $0x10,%esp
  8003f1:	e9 7a 01 00 00       	jmp    800570 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8003f6:	50                   	push   %eax
  8003f7:	68 b0 0e 80 00       	push   $0x800eb0
  8003fc:	57                   	push   %edi
  8003fd:	56                   	push   %esi
  8003fe:	e8 9a fe ff ff       	call   80029d <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	e9 65 01 00 00       	jmp    800570 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 50 04             	lea    0x4(%eax),%edx
  800411:	89 55 14             	mov    %edx,0x14(%ebp)
  800414:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800416:	85 db                	test   %ebx,%ebx
  800418:	b8 a9 0e 80 00       	mov    $0x800ea9,%eax
  80041d:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  800420:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800424:	0f 8e bd 00 00 00    	jle    8004e7 <vprintfmt+0x22d>
  80042a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042e:	75 0e                	jne    80043e <vprintfmt+0x184>
  800430:	89 75 08             	mov    %esi,0x8(%ebp)
  800433:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800436:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800439:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80043c:	eb 6d                	jmp    8004ab <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	ff 75 d0             	pushl  -0x30(%ebp)
  800444:	53                   	push   %ebx
  800445:	e8 4d 02 00 00       	call   800697 <strnlen>
  80044a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044d:	29 c1                	sub    %eax,%ecx
  80044f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800452:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800455:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800459:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80045f:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800461:	eb 0f                	jmp    800472 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	57                   	push   %edi
  800467:	ff 75 e0             	pushl  -0x20(%ebp)
  80046a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046c:	83 eb 01             	sub    $0x1,%ebx
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	85 db                	test   %ebx,%ebx
  800474:	7f ed                	jg     800463 <vprintfmt+0x1a9>
  800476:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800479:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80047c:	85 c9                	test   %ecx,%ecx
  80047e:	b8 00 00 00 00       	mov    $0x0,%eax
  800483:	0f 49 c1             	cmovns %ecx,%eax
  800486:	29 c1                	sub    %eax,%ecx
  800488:	89 75 08             	mov    %esi,0x8(%ebp)
  80048b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048e:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800491:	89 cf                	mov    %ecx,%edi
  800493:	eb 16                	jmp    8004ab <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800495:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800499:	75 31                	jne    8004cc <vprintfmt+0x212>
					putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 0c             	pushl  0xc(%ebp)
  8004a1:	50                   	push   %eax
  8004a2:	ff 55 08             	call   *0x8(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a8:	83 ef 01             	sub    $0x1,%edi
  8004ab:	83 c3 01             	add    $0x1,%ebx
  8004ae:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8004b2:	0f be c2             	movsbl %dl,%eax
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	74 50                	je     800509 <vprintfmt+0x24f>
  8004b9:	85 f6                	test   %esi,%esi
  8004bb:	78 d8                	js     800495 <vprintfmt+0x1db>
  8004bd:	83 ee 01             	sub    $0x1,%esi
  8004c0:	79 d3                	jns    800495 <vprintfmt+0x1db>
  8004c2:	89 fb                	mov    %edi,%ebx
  8004c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004ca:	eb 37                	jmp    800503 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cc:	0f be d2             	movsbl %dl,%edx
  8004cf:	83 ea 20             	sub    $0x20,%edx
  8004d2:	83 fa 5e             	cmp    $0x5e,%edx
  8004d5:	76 c4                	jbe    80049b <vprintfmt+0x1e1>
					putch('?', putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	6a 3f                	push   $0x3f
  8004df:	ff 55 08             	call   *0x8(%ebp)
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	eb c1                	jmp    8004a8 <vprintfmt+0x1ee>
  8004e7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ea:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ed:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004f0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004f3:	eb b6                	jmp    8004ab <vprintfmt+0x1f1>
				putch(' ', putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	57                   	push   %edi
  8004f9:	6a 20                	push   $0x20
  8004fb:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004fd:	83 eb 01             	sub    $0x1,%ebx
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	85 db                	test   %ebx,%ebx
  800505:	7f ee                	jg     8004f5 <vprintfmt+0x23b>
  800507:	eb 67                	jmp    800570 <vprintfmt+0x2b6>
  800509:	89 fb                	mov    %edi,%ebx
  80050b:	8b 75 08             	mov    0x8(%ebp),%esi
  80050e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800511:	eb f0                	jmp    800503 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800513:	8d 45 14             	lea    0x14(%ebp),%eax
  800516:	e8 33 fd ff ff       	call   80024e <getint>
  80051b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800521:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800526:	85 d2                	test   %edx,%edx
  800528:	79 2c                	jns    800556 <vprintfmt+0x29c>
				putch('-', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	57                   	push   %edi
  80052e:	6a 2d                	push   $0x2d
  800530:	ff d6                	call   *%esi
				num = -(long long) num;
  800532:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800535:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800538:	f7 d8                	neg    %eax
  80053a:	83 d2 00             	adc    $0x0,%edx
  80053d:	f7 da                	neg    %edx
  80053f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800542:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800547:	eb 0d                	jmp    800556 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800549:	8d 45 14             	lea    0x14(%ebp),%eax
  80054c:	e8 c3 fc ff ff       	call   800214 <getuint>
			base = 10;
  800551:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800556:	83 ec 0c             	sub    $0xc,%esp
  800559:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80055d:	53                   	push   %ebx
  80055e:	ff 75 e0             	pushl  -0x20(%ebp)
  800561:	51                   	push   %ecx
  800562:	52                   	push   %edx
  800563:	50                   	push   %eax
  800564:	89 fa                	mov    %edi,%edx
  800566:	89 f0                	mov    %esi,%eax
  800568:	e8 f8 fb ff ff       	call   800165 <printnum>
			break;
  80056d:	83 c4 20             	add    $0x20,%esp
{
  800570:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800573:	83 c3 01             	add    $0x1,%ebx
  800576:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  80057a:	83 f8 25             	cmp    $0x25,%eax
  80057d:	0f 84 52 fd ff ff    	je     8002d5 <vprintfmt+0x1b>
			if (ch == '\0')
  800583:	85 c0                	test   %eax,%eax
  800585:	0f 84 84 00 00 00    	je     80060f <vprintfmt+0x355>
			putch(ch, putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	57                   	push   %edi
  80058f:	50                   	push   %eax
  800590:	ff d6                	call   *%esi
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	eb dc                	jmp    800573 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  800597:	8d 45 14             	lea    0x14(%ebp),%eax
  80059a:	e8 75 fc ff ff       	call   800214 <getuint>
			base = 8;
  80059f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005a4:	eb b0                	jmp    800556 <vprintfmt+0x29c>
			putch('0', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	57                   	push   %edi
  8005aa:	6a 30                	push   $0x30
  8005ac:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ae:	83 c4 08             	add    $0x8,%esp
  8005b1:	57                   	push   %edi
  8005b2:	6a 78                	push   $0x78
  8005b4:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8005c6:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005c9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005ce:	eb 86                	jmp    800556 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d3:	e8 3c fc ff ff       	call   800214 <getuint>
			base = 16;
  8005d8:	b9 10 00 00 00       	mov    $0x10,%ecx
  8005dd:	e9 74 ff ff ff       	jmp    800556 <vprintfmt+0x29c>
			putch(ch, putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	57                   	push   %edi
  8005e6:	6a 25                	push   $0x25
  8005e8:	ff d6                	call   *%esi
			break;
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	eb 81                	jmp    800570 <vprintfmt+0x2b6>
			putch('%', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	57                   	push   %edi
  8005f3:	6a 25                	push   $0x25
  8005f5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	89 d8                	mov    %ebx,%eax
  8005fc:	eb 03                	jmp    800601 <vprintfmt+0x347>
  8005fe:	83 e8 01             	sub    $0x1,%eax
  800601:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800605:	75 f7                	jne    8005fe <vprintfmt+0x344>
  800607:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80060a:	e9 61 ff ff ff       	jmp    800570 <vprintfmt+0x2b6>
}
  80060f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800612:	5b                   	pop    %ebx
  800613:	5e                   	pop    %esi
  800614:	5f                   	pop    %edi
  800615:	5d                   	pop    %ebp
  800616:	c3                   	ret    

00800617 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800617:	55                   	push   %ebp
  800618:	89 e5                	mov    %esp,%ebp
  80061a:	83 ec 18             	sub    $0x18,%esp
  80061d:	8b 45 08             	mov    0x8(%ebp),%eax
  800620:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800623:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800626:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80062a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80062d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800634:	85 c0                	test   %eax,%eax
  800636:	74 26                	je     80065e <vsnprintf+0x47>
  800638:	85 d2                	test   %edx,%edx
  80063a:	7e 22                	jle    80065e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80063c:	ff 75 14             	pushl  0x14(%ebp)
  80063f:	ff 75 10             	pushl  0x10(%ebp)
  800642:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	68 80 02 80 00       	push   $0x800280
  80064b:	e8 6a fc ff ff       	call   8002ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800650:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800653:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800659:	83 c4 10             	add    $0x10,%esp
}
  80065c:	c9                   	leave  
  80065d:	c3                   	ret    
		return -E_INVAL;
  80065e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800663:	eb f7                	jmp    80065c <vsnprintf+0x45>

00800665 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80066e:	50                   	push   %eax
  80066f:	ff 75 10             	pushl  0x10(%ebp)
  800672:	ff 75 0c             	pushl  0xc(%ebp)
  800675:	ff 75 08             	pushl  0x8(%ebp)
  800678:	e8 9a ff ff ff       	call   800617 <vsnprintf>
	va_end(ap);

	return rc;
}
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800685:	b8 00 00 00 00       	mov    $0x0,%eax
  80068a:	eb 03                	jmp    80068f <strlen+0x10>
		n++;
  80068c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80068f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800693:	75 f7                	jne    80068c <strlen+0xd>
	return n;
}
  800695:	5d                   	pop    %ebp
  800696:	c3                   	ret    

00800697 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a5:	eb 03                	jmp    8006aa <strnlen+0x13>
		n++;
  8006a7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006aa:	39 d0                	cmp    %edx,%eax
  8006ac:	74 06                	je     8006b4 <strnlen+0x1d>
  8006ae:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006b2:	75 f3                	jne    8006a7 <strnlen+0x10>
	return n;
}
  8006b4:	5d                   	pop    %ebp
  8006b5:	c3                   	ret    

008006b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	53                   	push   %ebx
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006c0:	89 c2                	mov    %eax,%edx
  8006c2:	83 c1 01             	add    $0x1,%ecx
  8006c5:	83 c2 01             	add    $0x1,%edx
  8006c8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006cc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006cf:	84 db                	test   %bl,%bl
  8006d1:	75 ef                	jne    8006c2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006d3:	5b                   	pop    %ebx
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	53                   	push   %ebx
  8006da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006dd:	53                   	push   %ebx
  8006de:	e8 9c ff ff ff       	call   80067f <strlen>
  8006e3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006e6:	ff 75 0c             	pushl  0xc(%ebp)
  8006e9:	01 d8                	add    %ebx,%eax
  8006eb:	50                   	push   %eax
  8006ec:	e8 c5 ff ff ff       	call   8006b6 <strcpy>
	return dst;
}
  8006f1:	89 d8                	mov    %ebx,%eax
  8006f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f6:	c9                   	leave  
  8006f7:	c3                   	ret    

008006f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	56                   	push   %esi
  8006fc:	53                   	push   %ebx
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800703:	89 f3                	mov    %esi,%ebx
  800705:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800708:	89 f2                	mov    %esi,%edx
  80070a:	eb 0f                	jmp    80071b <strncpy+0x23>
		*dst++ = *src;
  80070c:	83 c2 01             	add    $0x1,%edx
  80070f:	0f b6 01             	movzbl (%ecx),%eax
  800712:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800715:	80 39 01             	cmpb   $0x1,(%ecx)
  800718:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80071b:	39 da                	cmp    %ebx,%edx
  80071d:	75 ed                	jne    80070c <strncpy+0x14>
	}
	return ret;
}
  80071f:	89 f0                	mov    %esi,%eax
  800721:	5b                   	pop    %ebx
  800722:	5e                   	pop    %esi
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	56                   	push   %esi
  800729:	53                   	push   %ebx
  80072a:	8b 75 08             	mov    0x8(%ebp),%esi
  80072d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800730:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800733:	89 f0                	mov    %esi,%eax
  800735:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800739:	85 c9                	test   %ecx,%ecx
  80073b:	75 0b                	jne    800748 <strlcpy+0x23>
  80073d:	eb 17                	jmp    800756 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80073f:	83 c2 01             	add    $0x1,%edx
  800742:	83 c0 01             	add    $0x1,%eax
  800745:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800748:	39 d8                	cmp    %ebx,%eax
  80074a:	74 07                	je     800753 <strlcpy+0x2e>
  80074c:	0f b6 0a             	movzbl (%edx),%ecx
  80074f:	84 c9                	test   %cl,%cl
  800751:	75 ec                	jne    80073f <strlcpy+0x1a>
		*dst = '\0';
  800753:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800756:	29 f0                	sub    %esi,%eax
}
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800762:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800765:	eb 06                	jmp    80076d <strcmp+0x11>
		p++, q++;
  800767:	83 c1 01             	add    $0x1,%ecx
  80076a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80076d:	0f b6 01             	movzbl (%ecx),%eax
  800770:	84 c0                	test   %al,%al
  800772:	74 04                	je     800778 <strcmp+0x1c>
  800774:	3a 02                	cmp    (%edx),%al
  800776:	74 ef                	je     800767 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800778:	0f b6 c0             	movzbl %al,%eax
  80077b:	0f b6 12             	movzbl (%edx),%edx
  80077e:	29 d0                	sub    %edx,%eax
}
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	53                   	push   %ebx
  800786:	8b 45 08             	mov    0x8(%ebp),%eax
  800789:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078c:	89 c3                	mov    %eax,%ebx
  80078e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800791:	eb 06                	jmp    800799 <strncmp+0x17>
		n--, p++, q++;
  800793:	83 c0 01             	add    $0x1,%eax
  800796:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800799:	39 d8                	cmp    %ebx,%eax
  80079b:	74 16                	je     8007b3 <strncmp+0x31>
  80079d:	0f b6 08             	movzbl (%eax),%ecx
  8007a0:	84 c9                	test   %cl,%cl
  8007a2:	74 04                	je     8007a8 <strncmp+0x26>
  8007a4:	3a 0a                	cmp    (%edx),%cl
  8007a6:	74 eb                	je     800793 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a8:	0f b6 00             	movzbl (%eax),%eax
  8007ab:	0f b6 12             	movzbl (%edx),%edx
  8007ae:	29 d0                	sub    %edx,%eax
}
  8007b0:	5b                   	pop    %ebx
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    
		return 0;
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b8:	eb f6                	jmp    8007b0 <strncmp+0x2e>

008007ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007c4:	0f b6 10             	movzbl (%eax),%edx
  8007c7:	84 d2                	test   %dl,%dl
  8007c9:	74 09                	je     8007d4 <strchr+0x1a>
		if (*s == c)
  8007cb:	38 ca                	cmp    %cl,%dl
  8007cd:	74 0a                	je     8007d9 <strchr+0x1f>
	for (; *s; s++)
  8007cf:	83 c0 01             	add    $0x1,%eax
  8007d2:	eb f0                	jmp    8007c4 <strchr+0xa>
			return (char *) s;
	return 0;
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e5:	eb 03                	jmp    8007ea <strfind+0xf>
  8007e7:	83 c0 01             	add    $0x1,%eax
  8007ea:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007ed:	38 ca                	cmp    %cl,%dl
  8007ef:	74 04                	je     8007f5 <strfind+0x1a>
  8007f1:	84 d2                	test   %dl,%dl
  8007f3:	75 f2                	jne    8007e7 <strfind+0xc>
			break;
	return (char *) s;
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	57                   	push   %edi
  8007fb:	56                   	push   %esi
  8007fc:	53                   	push   %ebx
  8007fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800800:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800803:	85 c9                	test   %ecx,%ecx
  800805:	74 12                	je     800819 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800807:	f6 c2 03             	test   $0x3,%dl
  80080a:	75 05                	jne    800811 <memset+0x1a>
  80080c:	f6 c1 03             	test   $0x3,%cl
  80080f:	74 0f                	je     800820 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800811:	89 d7                	mov    %edx,%edi
  800813:	8b 45 0c             	mov    0xc(%ebp),%eax
  800816:	fc                   	cld    
  800817:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800819:	89 d0                	mov    %edx,%eax
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5f                   	pop    %edi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    
		c &= 0xFF;
  800820:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800824:	89 d8                	mov    %ebx,%eax
  800826:	c1 e0 08             	shl    $0x8,%eax
  800829:	89 df                	mov    %ebx,%edi
  80082b:	c1 e7 18             	shl    $0x18,%edi
  80082e:	89 de                	mov    %ebx,%esi
  800830:	c1 e6 10             	shl    $0x10,%esi
  800833:	09 f7                	or     %esi,%edi
  800835:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800837:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80083c:	89 d7                	mov    %edx,%edi
  80083e:	fc                   	cld    
  80083f:	f3 ab                	rep stos %eax,%es:(%edi)
  800841:	eb d6                	jmp    800819 <memset+0x22>

00800843 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	57                   	push   %edi
  800847:	56                   	push   %esi
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80084e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800851:	39 c6                	cmp    %eax,%esi
  800853:	73 35                	jae    80088a <memmove+0x47>
  800855:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800858:	39 c2                	cmp    %eax,%edx
  80085a:	76 2e                	jbe    80088a <memmove+0x47>
		s += n;
		d += n;
  80085c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80085f:	89 d6                	mov    %edx,%esi
  800861:	09 fe                	or     %edi,%esi
  800863:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800869:	74 0c                	je     800877 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80086b:	83 ef 01             	sub    $0x1,%edi
  80086e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800871:	fd                   	std    
  800872:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800874:	fc                   	cld    
  800875:	eb 21                	jmp    800898 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800877:	f6 c1 03             	test   $0x3,%cl
  80087a:	75 ef                	jne    80086b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80087c:	83 ef 04             	sub    $0x4,%edi
  80087f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800882:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800885:	fd                   	std    
  800886:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800888:	eb ea                	jmp    800874 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80088a:	89 f2                	mov    %esi,%edx
  80088c:	09 c2                	or     %eax,%edx
  80088e:	f6 c2 03             	test   $0x3,%dl
  800891:	74 09                	je     80089c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800893:	89 c7                	mov    %eax,%edi
  800895:	fc                   	cld    
  800896:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800898:	5e                   	pop    %esi
  800899:	5f                   	pop    %edi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089c:	f6 c1 03             	test   $0x3,%cl
  80089f:	75 f2                	jne    800893 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008a4:	89 c7                	mov    %eax,%edi
  8008a6:	fc                   	cld    
  8008a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a9:	eb ed                	jmp    800898 <memmove+0x55>

008008ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ae:	ff 75 10             	pushl  0x10(%ebp)
  8008b1:	ff 75 0c             	pushl  0xc(%ebp)
  8008b4:	ff 75 08             	pushl  0x8(%ebp)
  8008b7:	e8 87 ff ff ff       	call   800843 <memmove>
}
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    

008008be <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c9:	89 c6                	mov    %eax,%esi
  8008cb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ce:	39 f0                	cmp    %esi,%eax
  8008d0:	74 1c                	je     8008ee <memcmp+0x30>
		if (*s1 != *s2)
  8008d2:	0f b6 08             	movzbl (%eax),%ecx
  8008d5:	0f b6 1a             	movzbl (%edx),%ebx
  8008d8:	38 d9                	cmp    %bl,%cl
  8008da:	75 08                	jne    8008e4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008dc:	83 c0 01             	add    $0x1,%eax
  8008df:	83 c2 01             	add    $0x1,%edx
  8008e2:	eb ea                	jmp    8008ce <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8008e4:	0f b6 c1             	movzbl %cl,%eax
  8008e7:	0f b6 db             	movzbl %bl,%ebx
  8008ea:	29 d8                	sub    %ebx,%eax
  8008ec:	eb 05                	jmp    8008f3 <memcmp+0x35>
	}

	return 0;
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800900:	89 c2                	mov    %eax,%edx
  800902:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800905:	39 d0                	cmp    %edx,%eax
  800907:	73 09                	jae    800912 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800909:	38 08                	cmp    %cl,(%eax)
  80090b:	74 05                	je     800912 <memfind+0x1b>
	for (; s < ends; s++)
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	eb f3                	jmp    800905 <memfind+0xe>
			break;
	return (void *) s;
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800920:	eb 03                	jmp    800925 <strtol+0x11>
		s++;
  800922:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800925:	0f b6 01             	movzbl (%ecx),%eax
  800928:	3c 20                	cmp    $0x20,%al
  80092a:	74 f6                	je     800922 <strtol+0xe>
  80092c:	3c 09                	cmp    $0x9,%al
  80092e:	74 f2                	je     800922 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800930:	3c 2b                	cmp    $0x2b,%al
  800932:	74 2e                	je     800962 <strtol+0x4e>
	int neg = 0;
  800934:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800939:	3c 2d                	cmp    $0x2d,%al
  80093b:	74 2f                	je     80096c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80093d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800943:	75 05                	jne    80094a <strtol+0x36>
  800945:	80 39 30             	cmpb   $0x30,(%ecx)
  800948:	74 2c                	je     800976 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80094a:	85 db                	test   %ebx,%ebx
  80094c:	75 0a                	jne    800958 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80094e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800953:	80 39 30             	cmpb   $0x30,(%ecx)
  800956:	74 28                	je     800980 <strtol+0x6c>
		base = 10;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
  80095d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800960:	eb 50                	jmp    8009b2 <strtol+0x9e>
		s++;
  800962:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800965:	bf 00 00 00 00       	mov    $0x0,%edi
  80096a:	eb d1                	jmp    80093d <strtol+0x29>
		s++, neg = 1;
  80096c:	83 c1 01             	add    $0x1,%ecx
  80096f:	bf 01 00 00 00       	mov    $0x1,%edi
  800974:	eb c7                	jmp    80093d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800976:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80097a:	74 0e                	je     80098a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80097c:	85 db                	test   %ebx,%ebx
  80097e:	75 d8                	jne    800958 <strtol+0x44>
		s++, base = 8;
  800980:	83 c1 01             	add    $0x1,%ecx
  800983:	bb 08 00 00 00       	mov    $0x8,%ebx
  800988:	eb ce                	jmp    800958 <strtol+0x44>
		s += 2, base = 16;
  80098a:	83 c1 02             	add    $0x2,%ecx
  80098d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800992:	eb c4                	jmp    800958 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800994:	8d 72 9f             	lea    -0x61(%edx),%esi
  800997:	89 f3                	mov    %esi,%ebx
  800999:	80 fb 19             	cmp    $0x19,%bl
  80099c:	77 29                	ja     8009c7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80099e:	0f be d2             	movsbl %dl,%edx
  8009a1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009a4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009a7:	7d 30                	jge    8009d9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8009a9:	83 c1 01             	add    $0x1,%ecx
  8009ac:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009b0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009b2:	0f b6 11             	movzbl (%ecx),%edx
  8009b5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b8:	89 f3                	mov    %esi,%ebx
  8009ba:	80 fb 09             	cmp    $0x9,%bl
  8009bd:	77 d5                	ja     800994 <strtol+0x80>
			dig = *s - '0';
  8009bf:	0f be d2             	movsbl %dl,%edx
  8009c2:	83 ea 30             	sub    $0x30,%edx
  8009c5:	eb dd                	jmp    8009a4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  8009c7:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009ca:	89 f3                	mov    %esi,%ebx
  8009cc:	80 fb 19             	cmp    $0x19,%bl
  8009cf:	77 08                	ja     8009d9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009d1:	0f be d2             	movsbl %dl,%edx
  8009d4:	83 ea 37             	sub    $0x37,%edx
  8009d7:	eb cb                	jmp    8009a4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009dd:	74 05                	je     8009e4 <strtol+0xd0>
		*endptr = (char *) s;
  8009df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8009e4:	89 c2                	mov    %eax,%edx
  8009e6:	f7 da                	neg    %edx
  8009e8:	85 ff                	test   %edi,%edi
  8009ea:	0f 45 c2             	cmovne %edx,%eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	57                   	push   %edi
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	83 ec 1c             	sub    $0x1c,%esp
  8009fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a01:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a09:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a0c:	8b 75 14             	mov    0x14(%ebp),%esi
  800a0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a11:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a15:	74 04                	je     800a1b <syscall+0x29>
  800a17:	85 c0                	test   %eax,%eax
  800a19:	7f 08                	jg     800a23 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5f                   	pop    %edi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    
  800a23:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800a26:	83 ec 0c             	sub    $0xc,%esp
  800a29:	50                   	push   %eax
  800a2a:	52                   	push   %edx
  800a2b:	68 e4 10 80 00       	push   $0x8010e4
  800a30:	6a 23                	push   $0x23
  800a32:	68 01 11 80 00       	push   $0x801101
  800a37:	e8 b1 01 00 00       	call   800bed <_panic>

00800a3c <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800a42:	6a 00                	push   $0x0
  800a44:	6a 00                	push   $0x0
  800a46:	6a 00                	push   $0x0
  800a48:	ff 75 0c             	pushl  0xc(%ebp)
  800a4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
  800a58:	e8 95 ff ff ff       	call   8009f2 <syscall>
}
  800a5d:	83 c4 10             	add    $0x10,%esp
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a68:	6a 00                	push   $0x0
  800a6a:	6a 00                	push   $0x0
  800a6c:	6a 00                	push   $0x0
  800a6e:	6a 00                	push   $0x0
  800a70:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a75:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7f:	e8 6e ff ff ff       	call   8009f2 <syscall>
}
  800a84:	c9                   	leave  
  800a85:	c3                   	ret    

00800a86 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800a8c:	6a 00                	push   $0x0
  800a8e:	6a 00                	push   $0x0
  800a90:	6a 00                	push   $0x0
  800a92:	6a 00                	push   $0x0
  800a94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a97:	ba 01 00 00 00       	mov    $0x1,%edx
  800a9c:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa1:	e8 4c ff ff ff       	call   8009f2 <syscall>
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800aae:	6a 00                	push   $0x0
  800ab0:	6a 00                	push   $0x0
  800ab2:	6a 00                	push   $0x0
  800ab4:	6a 00                	push   $0x0
  800ab6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac5:	e8 28 ff ff ff       	call   8009f2 <syscall>
}
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    

00800acc <sys_yield>:

void
sys_yield(void)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ad2:	6a 00                	push   $0x0
  800ad4:	6a 00                	push   $0x0
  800ad6:	6a 00                	push   $0x0
  800ad8:	6a 00                	push   $0x0
  800ada:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae9:	e8 04 ff ff ff       	call   8009f2 <syscall>
}
  800aee:	83 c4 10             	add    $0x10,%esp
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800af9:	6a 00                	push   $0x0
  800afb:	6a 00                	push   $0x0
  800afd:	ff 75 10             	pushl  0x10(%ebp)
  800b00:	ff 75 0c             	pushl  0xc(%ebp)
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	ba 01 00 00 00       	mov    $0x1,%edx
  800b0b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b10:	e8 dd fe ff ff       	call   8009f2 <syscall>
}
  800b15:	c9                   	leave  
  800b16:	c3                   	ret    

00800b17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b1d:	ff 75 18             	pushl  0x18(%ebp)
  800b20:	ff 75 14             	pushl  0x14(%ebp)
  800b23:	ff 75 10             	pushl  0x10(%ebp)
  800b26:	ff 75 0c             	pushl  0xc(%ebp)
  800b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b31:	b8 05 00 00 00       	mov    $0x5,%eax
  800b36:	e8 b7 fe ff ff       	call   8009f2 <syscall>
}
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b43:	6a 00                	push   $0x0
  800b45:	6a 00                	push   $0x0
  800b47:	6a 00                	push   $0x0
  800b49:	ff 75 0c             	pushl  0xc(%ebp)
  800b4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b54:	b8 06 00 00 00       	mov    $0x6,%eax
  800b59:	e8 94 fe ff ff       	call   8009f2 <syscall>
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b66:	6a 00                	push   $0x0
  800b68:	6a 00                	push   $0x0
  800b6a:	6a 00                	push   $0x0
  800b6c:	ff 75 0c             	pushl  0xc(%ebp)
  800b6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b72:	ba 01 00 00 00       	mov    $0x1,%edx
  800b77:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7c:	e8 71 fe ff ff       	call   8009f2 <syscall>
}
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	6a 00                	push   $0x0
  800b8f:	ff 75 0c             	pushl  0xc(%ebp)
  800b92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b95:	ba 01 00 00 00       	mov    $0x1,%edx
  800b9a:	b8 09 00 00 00       	mov    $0x9,%eax
  800b9f:	e8 4e fe ff ff       	call   8009f2 <syscall>
}
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    

00800ba6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800bac:	6a 00                	push   $0x0
  800bae:	ff 75 14             	pushl  0x14(%ebp)
  800bb1:	ff 75 10             	pushl  0x10(%ebp)
  800bb4:	ff 75 0c             	pushl  0xc(%ebp)
  800bb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bba:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc4:	e8 29 fe ff ff       	call   8009f2 <syscall>
}
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	6a 00                	push   $0x0
  800bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdc:	ba 01 00 00 00       	mov    $0x1,%edx
  800be1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800be6:	e8 07 fe ff ff       	call   8009f2 <syscall>
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800bf2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bf5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800bfb:	e8 a8 fe ff ff       	call   800aa8 <sys_getenvid>
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	ff 75 0c             	pushl  0xc(%ebp)
  800c06:	ff 75 08             	pushl  0x8(%ebp)
  800c09:	56                   	push   %esi
  800c0a:	50                   	push   %eax
  800c0b:	68 10 11 80 00       	push   $0x801110
  800c10:	e8 3c f5 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c15:	83 c4 18             	add    $0x18,%esp
  800c18:	53                   	push   %ebx
  800c19:	ff 75 10             	pushl  0x10(%ebp)
  800c1c:	e8 df f4 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  800c21:	c7 04 24 8c 0e 80 00 	movl   $0x800e8c,(%esp)
  800c28:	e8 24 f5 ff ff       	call   800151 <cprintf>
  800c2d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c30:	cc                   	int3   
  800c31:	eb fd                	jmp    800c30 <_panic+0x43>
  800c33:	66 90                	xchg   %ax,%ax
  800c35:	66 90                	xchg   %ax,%ax
  800c37:	66 90                	xchg   %ax,%ax
  800c39:	66 90                	xchg   %ax,%ax
  800c3b:	66 90                	xchg   %ax,%ax
  800c3d:	66 90                	xchg   %ax,%ax
  800c3f:	90                   	nop

00800c40 <__udivdi3>:
  800c40:	55                   	push   %ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 1c             	sub    $0x1c,%esp
  800c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c57:	85 d2                	test   %edx,%edx
  800c59:	75 35                	jne    800c90 <__udivdi3+0x50>
  800c5b:	39 f3                	cmp    %esi,%ebx
  800c5d:	0f 87 bd 00 00 00    	ja     800d20 <__udivdi3+0xe0>
  800c63:	85 db                	test   %ebx,%ebx
  800c65:	89 d9                	mov    %ebx,%ecx
  800c67:	75 0b                	jne    800c74 <__udivdi3+0x34>
  800c69:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6e:	31 d2                	xor    %edx,%edx
  800c70:	f7 f3                	div    %ebx
  800c72:	89 c1                	mov    %eax,%ecx
  800c74:	31 d2                	xor    %edx,%edx
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	f7 f1                	div    %ecx
  800c7a:	89 c6                	mov    %eax,%esi
  800c7c:	89 e8                	mov    %ebp,%eax
  800c7e:	89 f7                	mov    %esi,%edi
  800c80:	f7 f1                	div    %ecx
  800c82:	89 fa                	mov    %edi,%edx
  800c84:	83 c4 1c             	add    $0x1c,%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
  800c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c90:	39 f2                	cmp    %esi,%edx
  800c92:	77 7c                	ja     800d10 <__udivdi3+0xd0>
  800c94:	0f bd fa             	bsr    %edx,%edi
  800c97:	83 f7 1f             	xor    $0x1f,%edi
  800c9a:	0f 84 98 00 00 00    	je     800d38 <__udivdi3+0xf8>
  800ca0:	89 f9                	mov    %edi,%ecx
  800ca2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ca7:	29 f8                	sub    %edi,%eax
  800ca9:	d3 e2                	shl    %cl,%edx
  800cab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800caf:	89 c1                	mov    %eax,%ecx
  800cb1:	89 da                	mov    %ebx,%edx
  800cb3:	d3 ea                	shr    %cl,%edx
  800cb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cb9:	09 d1                	or     %edx,%ecx
  800cbb:	89 f2                	mov    %esi,%edx
  800cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc1:	89 f9                	mov    %edi,%ecx
  800cc3:	d3 e3                	shl    %cl,%ebx
  800cc5:	89 c1                	mov    %eax,%ecx
  800cc7:	d3 ea                	shr    %cl,%edx
  800cc9:	89 f9                	mov    %edi,%ecx
  800ccb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ccf:	d3 e6                	shl    %cl,%esi
  800cd1:	89 eb                	mov    %ebp,%ebx
  800cd3:	89 c1                	mov    %eax,%ecx
  800cd5:	d3 eb                	shr    %cl,%ebx
  800cd7:	09 de                	or     %ebx,%esi
  800cd9:	89 f0                	mov    %esi,%eax
  800cdb:	f7 74 24 08          	divl   0x8(%esp)
  800cdf:	89 d6                	mov    %edx,%esi
  800ce1:	89 c3                	mov    %eax,%ebx
  800ce3:	f7 64 24 0c          	mull   0xc(%esp)
  800ce7:	39 d6                	cmp    %edx,%esi
  800ce9:	72 0c                	jb     800cf7 <__udivdi3+0xb7>
  800ceb:	89 f9                	mov    %edi,%ecx
  800ced:	d3 e5                	shl    %cl,%ebp
  800cef:	39 c5                	cmp    %eax,%ebp
  800cf1:	73 5d                	jae    800d50 <__udivdi3+0x110>
  800cf3:	39 d6                	cmp    %edx,%esi
  800cf5:	75 59                	jne    800d50 <__udivdi3+0x110>
  800cf7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cfa:	31 ff                	xor    %edi,%edi
  800cfc:	89 fa                	mov    %edi,%edx
  800cfe:	83 c4 1c             	add    $0x1c,%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
  800d06:	8d 76 00             	lea    0x0(%esi),%esi
  800d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d10:	31 ff                	xor    %edi,%edi
  800d12:	31 c0                	xor    %eax,%eax
  800d14:	89 fa                	mov    %edi,%edx
  800d16:	83 c4 1c             	add    $0x1c,%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
  800d1e:	66 90                	xchg   %ax,%ax
  800d20:	31 ff                	xor    %edi,%edi
  800d22:	89 e8                	mov    %ebp,%eax
  800d24:	89 f2                	mov    %esi,%edx
  800d26:	f7 f3                	div    %ebx
  800d28:	89 fa                	mov    %edi,%edx
  800d2a:	83 c4 1c             	add    $0x1c,%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
  800d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d38:	39 f2                	cmp    %esi,%edx
  800d3a:	72 06                	jb     800d42 <__udivdi3+0x102>
  800d3c:	31 c0                	xor    %eax,%eax
  800d3e:	39 eb                	cmp    %ebp,%ebx
  800d40:	77 d2                	ja     800d14 <__udivdi3+0xd4>
  800d42:	b8 01 00 00 00       	mov    $0x1,%eax
  800d47:	eb cb                	jmp    800d14 <__udivdi3+0xd4>
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	89 d8                	mov    %ebx,%eax
  800d52:	31 ff                	xor    %edi,%edi
  800d54:	eb be                	jmp    800d14 <__udivdi3+0xd4>
  800d56:	66 90                	xchg   %ax,%ax
  800d58:	66 90                	xchg   %ax,%ax
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__umoddi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d77:	85 ed                	test   %ebp,%ebp
  800d79:	89 f0                	mov    %esi,%eax
  800d7b:	89 da                	mov    %ebx,%edx
  800d7d:	75 19                	jne    800d98 <__umoddi3+0x38>
  800d7f:	39 df                	cmp    %ebx,%edi
  800d81:	0f 86 b1 00 00 00    	jbe    800e38 <__umoddi3+0xd8>
  800d87:	f7 f7                	div    %edi
  800d89:	89 d0                	mov    %edx,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	83 c4 1c             	add    $0x1c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	39 dd                	cmp    %ebx,%ebp
  800d9a:	77 f1                	ja     800d8d <__umoddi3+0x2d>
  800d9c:	0f bd cd             	bsr    %ebp,%ecx
  800d9f:	83 f1 1f             	xor    $0x1f,%ecx
  800da2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800da6:	0f 84 b4 00 00 00    	je     800e60 <__umoddi3+0x100>
  800dac:	b8 20 00 00 00       	mov    $0x20,%eax
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800db7:	29 c2                	sub    %eax,%edx
  800db9:	89 c1                	mov    %eax,%ecx
  800dbb:	89 f8                	mov    %edi,%eax
  800dbd:	d3 e5                	shl    %cl,%ebp
  800dbf:	89 d1                	mov    %edx,%ecx
  800dc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dc5:	d3 e8                	shr    %cl,%eax
  800dc7:	09 c5                	or     %eax,%ebp
  800dc9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dcd:	89 c1                	mov    %eax,%ecx
  800dcf:	d3 e7                	shl    %cl,%edi
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	d3 ef                	shr    %cl,%edi
  800ddb:	89 c1                	mov    %eax,%ecx
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	d3 e3                	shl    %cl,%ebx
  800de1:	89 d1                	mov    %edx,%ecx
  800de3:	89 fa                	mov    %edi,%edx
  800de5:	d3 e8                	shr    %cl,%eax
  800de7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dec:	09 d8                	or     %ebx,%eax
  800dee:	f7 f5                	div    %ebp
  800df0:	d3 e6                	shl    %cl,%esi
  800df2:	89 d1                	mov    %edx,%ecx
  800df4:	f7 64 24 08          	mull   0x8(%esp)
  800df8:	39 d1                	cmp    %edx,%ecx
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	72 06                	jb     800e06 <__umoddi3+0xa6>
  800e00:	75 0e                	jne    800e10 <__umoddi3+0xb0>
  800e02:	39 c6                	cmp    %eax,%esi
  800e04:	73 0a                	jae    800e10 <__umoddi3+0xb0>
  800e06:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e0a:	19 ea                	sbb    %ebp,%edx
  800e0c:	89 d7                	mov    %edx,%edi
  800e0e:	89 c3                	mov    %eax,%ebx
  800e10:	89 ca                	mov    %ecx,%edx
  800e12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e17:	29 de                	sub    %ebx,%esi
  800e19:	19 fa                	sbb    %edi,%edx
  800e1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e1f:	89 d0                	mov    %edx,%eax
  800e21:	d3 e0                	shl    %cl,%eax
  800e23:	89 d9                	mov    %ebx,%ecx
  800e25:	d3 ee                	shr    %cl,%esi
  800e27:	d3 ea                	shr    %cl,%edx
  800e29:	09 f0                	or     %esi,%eax
  800e2b:	83 c4 1c             	add    $0x1c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    
  800e33:	90                   	nop
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	85 ff                	test   %edi,%edi
  800e3a:	89 f9                	mov    %edi,%ecx
  800e3c:	75 0b                	jne    800e49 <__umoddi3+0xe9>
  800e3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e43:	31 d2                	xor    %edx,%edx
  800e45:	f7 f7                	div    %edi
  800e47:	89 c1                	mov    %eax,%ecx
  800e49:	89 d8                	mov    %ebx,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f1                	div    %ecx
  800e4f:	89 f0                	mov    %esi,%eax
  800e51:	f7 f1                	div    %ecx
  800e53:	e9 31 ff ff ff       	jmp    800d89 <__umoddi3+0x29>
  800e58:	90                   	nop
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	39 dd                	cmp    %ebx,%ebp
  800e62:	72 08                	jb     800e6c <__umoddi3+0x10c>
  800e64:	39 f7                	cmp    %esi,%edi
  800e66:	0f 87 21 ff ff ff    	ja     800d8d <__umoddi3+0x2d>
  800e6c:	89 da                	mov    %ebx,%edx
  800e6e:	89 f0                	mov    %esi,%eax
  800e70:	29 f8                	sub    %edi,%eax
  800e72:	19 ea                	sbb    %ebp,%edx
  800e74:	e9 14 ff ff ff       	jmp    800d8d <__umoddi3+0x2d>
