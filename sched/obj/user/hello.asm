
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 80 0e 80 00       	push   $0x800e80
  80003e:	e8 0c 01 00 00       	call   80014f <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 8e 0e 80 00       	push   $0x800e8e
  800054:	e8 f6 00 00 00       	call   80014f <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800069:	e8 38 0a 00 00       	call   800aa6 <sys_getenvid>
	if (id >= 0)
  80006e:	85 c0                	test   %eax,%eax
  800070:	78 12                	js     800084 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800072:	25 ff 03 00 00       	and    $0x3ff,%eax
  800077:	c1 e0 07             	shl    $0x7,%eax
  80007a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800084:	85 db                	test   %ebx,%ebx
  800086:	7e 07                	jle    80008f <libmain+0x31>
		binaryname = argv[0];
  800088:	8b 06                	mov    (%esi),%eax
  80008a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008f:	83 ec 08             	sub    $0x8,%esp
  800092:	56                   	push   %esi
  800093:	53                   	push   %ebx
  800094:	e8 9a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a4:	5b                   	pop    %ebx
  8000a5:	5e                   	pop    %esi
  8000a6:	5d                   	pop    %ebp
  8000a7:	c3                   	ret    

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 cf 09 00 00       	call   800a84 <sys_env_destroy>
}
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	53                   	push   %ebx
  8000be:	83 ec 04             	sub    $0x4,%esp
  8000c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c4:	8b 13                	mov    (%ebx),%edx
  8000c6:	8d 42 01             	lea    0x1(%edx),%eax
  8000c9:	89 03                	mov    %eax,(%ebx)
  8000cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ce:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d7:	74 09                	je     8000e2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	68 ff 00 00 00       	push   $0xff
  8000ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ed:	50                   	push   %eax
  8000ee:	e8 47 09 00 00       	call   800a3a <sys_cputs>
		b->idx = 0;
  8000f3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f9:	83 c4 10             	add    $0x10,%esp
  8000fc:	eb db                	jmp    8000d9 <putch+0x1f>

008000fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800107:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010e:	00 00 00 
	b.cnt = 0;
  800111:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800118:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011b:	ff 75 0c             	pushl  0xc(%ebp)
  80011e:	ff 75 08             	pushl  0x8(%ebp)
  800121:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800127:	50                   	push   %eax
  800128:	68 ba 00 80 00       	push   $0x8000ba
  80012d:	e8 86 01 00 00       	call   8002b8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 f3 08 00 00       	call   800a3a <sys_cputs>

	return b.cnt;
}
  800147:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800155:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800158:	50                   	push   %eax
  800159:	ff 75 08             	pushl  0x8(%ebp)
  80015c:	e8 9d ff ff ff       	call   8000fe <vcprintf>
	va_end(ap);

	return cnt;
}
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 1c             	sub    $0x1c,%esp
  80016c:	89 c7                	mov    %eax,%edi
  80016e:	89 d6                	mov    %edx,%esi
  800170:	8b 45 08             	mov    0x8(%ebp),%eax
  800173:	8b 55 0c             	mov    0xc(%ebp),%edx
  800176:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800179:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800184:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800187:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018a:	39 d3                	cmp    %edx,%ebx
  80018c:	72 05                	jb     800193 <printnum+0x30>
  80018e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800191:	77 7a                	ja     80020d <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	ff 75 18             	pushl  0x18(%ebp)
  800199:	8b 45 14             	mov    0x14(%ebp),%eax
  80019c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019f:	53                   	push   %ebx
  8001a0:	ff 75 10             	pushl  0x10(%ebp)
  8001a3:	83 ec 08             	sub    $0x8,%esp
  8001a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8001af:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b2:	e8 89 0a 00 00       	call   800c40 <__udivdi3>
  8001b7:	83 c4 18             	add    $0x18,%esp
  8001ba:	52                   	push   %edx
  8001bb:	50                   	push   %eax
  8001bc:	89 f2                	mov    %esi,%edx
  8001be:	89 f8                	mov    %edi,%eax
  8001c0:	e8 9e ff ff ff       	call   800163 <printnum>
  8001c5:	83 c4 20             	add    $0x20,%esp
  8001c8:	eb 13                	jmp    8001dd <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ca:	83 ec 08             	sub    $0x8,%esp
  8001cd:	56                   	push   %esi
  8001ce:	ff 75 18             	pushl  0x18(%ebp)
  8001d1:	ff d7                	call   *%edi
  8001d3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d6:	83 eb 01             	sub    $0x1,%ebx
  8001d9:	85 db                	test   %ebx,%ebx
  8001db:	7f ed                	jg     8001ca <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001dd:	83 ec 08             	sub    $0x8,%esp
  8001e0:	56                   	push   %esi
  8001e1:	83 ec 04             	sub    $0x4,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 6b 0b 00 00       	call   800d60 <__umoddi3>
  8001f5:	83 c4 14             	add    $0x14,%esp
  8001f8:	0f be 80 af 0e 80 00 	movsbl 0x800eaf(%eax),%eax
  8001ff:	50                   	push   %eax
  800200:	ff d7                	call   *%edi
}
  800202:	83 c4 10             	add    $0x10,%esp
  800205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5f                   	pop    %edi
  80020b:	5d                   	pop    %ebp
  80020c:	c3                   	ret    
  80020d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800210:	eb c4                	jmp    8001d6 <printnum+0x73>

00800212 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800215:	83 fa 01             	cmp    $0x1,%edx
  800218:	7e 0e                	jle    800228 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021a:	8b 10                	mov    (%eax),%edx
  80021c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021f:	89 08                	mov    %ecx,(%eax)
  800221:	8b 02                	mov    (%edx),%eax
  800223:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    
	else if (lflag)
  800228:	85 d2                	test   %edx,%edx
  80022a:	75 10                	jne    80023c <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  80022c:	8b 10                	mov    (%eax),%edx
  80022e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800231:	89 08                	mov    %ecx,(%eax)
  800233:	8b 02                	mov    (%edx),%eax
  800235:	ba 00 00 00 00       	mov    $0x0,%edx
  80023a:	eb ea                	jmp    800226 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  80023c:	8b 10                	mov    (%eax),%edx
  80023e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800241:	89 08                	mov    %ecx,(%eax)
  800243:	8b 02                	mov    (%edx),%eax
  800245:	ba 00 00 00 00       	mov    $0x0,%edx
  80024a:	eb da                	jmp    800226 <getuint+0x14>

0080024c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024f:	83 fa 01             	cmp    $0x1,%edx
  800252:	7e 0e                	jle    800262 <getint+0x16>
		return va_arg(*ap, long long);
  800254:	8b 10                	mov    (%eax),%edx
  800256:	8d 4a 08             	lea    0x8(%edx),%ecx
  800259:	89 08                	mov    %ecx,(%eax)
  80025b:	8b 02                	mov    (%edx),%eax
  80025d:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800260:	5d                   	pop    %ebp
  800261:	c3                   	ret    
	else if (lflag)
  800262:	85 d2                	test   %edx,%edx
  800264:	75 0c                	jne    800272 <getint+0x26>
		return va_arg(*ap, int);
  800266:	8b 10                	mov    (%eax),%edx
  800268:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 02                	mov    (%edx),%eax
  80026f:	99                   	cltd   
  800270:	eb ee                	jmp    800260 <getint+0x14>
		return va_arg(*ap, long);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 04             	lea    0x4(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	99                   	cltd   
  80027c:	eb e2                	jmp    800260 <getint+0x14>

0080027e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800284:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800288:	8b 10                	mov    (%eax),%edx
  80028a:	3b 50 04             	cmp    0x4(%eax),%edx
  80028d:	73 0a                	jae    800299 <sprintputch+0x1b>
		*b->buf++ = ch;
  80028f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 45 08             	mov    0x8(%ebp),%eax
  800297:	88 02                	mov    %al,(%edx)
}
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <printfmt>:
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a4:	50                   	push   %eax
  8002a5:	ff 75 10             	pushl  0x10(%ebp)
  8002a8:	ff 75 0c             	pushl  0xc(%ebp)
  8002ab:	ff 75 08             	pushl  0x8(%ebp)
  8002ae:	e8 05 00 00 00       	call   8002b8 <vprintfmt>
}
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <vprintfmt>:
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 2c             	sub    $0x2c,%esp
  8002c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002c7:	89 f7                	mov    %esi,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ce:	e9 9e 02 00 00       	jmp    800571 <vprintfmt+0x2b9>
		padc = ' ';
  8002d3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002d7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002de:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002e5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ec:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8002f1:	8d 43 01             	lea    0x1(%ebx),%eax
  8002f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f7:	0f b6 0b             	movzbl (%ebx),%ecx
  8002fa:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8002fd:	3c 55                	cmp    $0x55,%al
  8002ff:	0f 87 e8 02 00 00    	ja     8005ed <vprintfmt+0x335>
  800305:	0f b6 c0             	movzbl %al,%eax
  800308:	ff 24 85 80 0f 80 00 	jmp    *0x800f80(,%eax,4)
  80030f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800312:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800316:	eb d9                	jmp    8002f1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800318:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  80031b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031f:	eb d0                	jmp    8002f1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800321:	0f b6 c9             	movzbl %cl,%ecx
  800324:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800327:	b8 00 00 00 00       	mov    $0x0,%eax
  80032c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80032f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800332:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800336:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800339:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80033c:	83 fa 09             	cmp    $0x9,%edx
  80033f:	77 52                	ja     800393 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800341:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800344:	eb e9                	jmp    80032f <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800346:	8b 45 14             	mov    0x14(%ebp),%eax
  800349:	8d 48 04             	lea    0x4(%eax),%ecx
  80034c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80034f:	8b 00                	mov    (%eax),%eax
  800351:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800357:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035b:	79 94                	jns    8002f1 <vprintfmt+0x39>
				width = precision, precision = -1;
  80035d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800360:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800363:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036a:	eb 85                	jmp    8002f1 <vprintfmt+0x39>
  80036c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036f:	85 c0                	test   %eax,%eax
  800371:	b9 00 00 00 00       	mov    $0x0,%ecx
  800376:	0f 49 c8             	cmovns %eax,%ecx
  800379:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80037f:	e9 6d ff ff ff       	jmp    8002f1 <vprintfmt+0x39>
  800384:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800387:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038e:	e9 5e ff ff ff       	jmp    8002f1 <vprintfmt+0x39>
  800393:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800396:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800399:	eb bc                	jmp    800357 <vprintfmt+0x9f>
			lflag++;
  80039b:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003a1:	e9 4b ff ff ff       	jmp    8002f1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	57                   	push   %edi
  8003b3:	ff 30                	pushl  (%eax)
  8003b5:	ff d6                	call   *%esi
			break;
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	e9 af 01 00 00       	jmp    80056e <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8d 50 04             	lea    0x4(%eax),%edx
  8003c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c8:	8b 00                	mov    (%eax),%eax
  8003ca:	99                   	cltd   
  8003cb:	31 d0                	xor    %edx,%eax
  8003cd:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cf:	83 f8 08             	cmp    $0x8,%eax
  8003d2:	7f 20                	jg     8003f4 <vprintfmt+0x13c>
  8003d4:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  8003db:	85 d2                	test   %edx,%edx
  8003dd:	74 15                	je     8003f4 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  8003df:	52                   	push   %edx
  8003e0:	68 d0 0e 80 00       	push   $0x800ed0
  8003e5:	57                   	push   %edi
  8003e6:	56                   	push   %esi
  8003e7:	e8 af fe ff ff       	call   80029b <printfmt>
  8003ec:	83 c4 10             	add    $0x10,%esp
  8003ef:	e9 7a 01 00 00       	jmp    80056e <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8003f4:	50                   	push   %eax
  8003f5:	68 c7 0e 80 00       	push   $0x800ec7
  8003fa:	57                   	push   %edi
  8003fb:	56                   	push   %esi
  8003fc:	e8 9a fe ff ff       	call   80029b <printfmt>
  800401:	83 c4 10             	add    $0x10,%esp
  800404:	e9 65 01 00 00       	jmp    80056e <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800414:	85 db                	test   %ebx,%ebx
  800416:	b8 c0 0e 80 00       	mov    $0x800ec0,%eax
  80041b:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  80041e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800422:	0f 8e bd 00 00 00    	jle    8004e5 <vprintfmt+0x22d>
  800428:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042c:	75 0e                	jne    80043c <vprintfmt+0x184>
  80042e:	89 75 08             	mov    %esi,0x8(%ebp)
  800431:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800434:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800437:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80043a:	eb 6d                	jmp    8004a9 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 d0             	pushl  -0x30(%ebp)
  800442:	53                   	push   %ebx
  800443:	e8 4d 02 00 00       	call   800695 <strnlen>
  800448:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044b:	29 c1                	sub    %eax,%ecx
  80044d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800450:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800453:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80045d:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	eb 0f                	jmp    800470 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	57                   	push   %edi
  800465:	ff 75 e0             	pushl  -0x20(%ebp)
  800468:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	83 eb 01             	sub    $0x1,%ebx
  80046d:	83 c4 10             	add    $0x10,%esp
  800470:	85 db                	test   %ebx,%ebx
  800472:	7f ed                	jg     800461 <vprintfmt+0x1a9>
  800474:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800477:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80047a:	85 c9                	test   %ecx,%ecx
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	0f 49 c1             	cmovns %ecx,%eax
  800484:	29 c1                	sub    %eax,%ecx
  800486:	89 75 08             	mov    %esi,0x8(%ebp)
  800489:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048c:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80048f:	89 cf                	mov    %ecx,%edi
  800491:	eb 16                	jmp    8004a9 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800493:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800497:	75 31                	jne    8004ca <vprintfmt+0x212>
					putch(ch, putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	ff 75 0c             	pushl  0xc(%ebp)
  80049f:	50                   	push   %eax
  8004a0:	ff 55 08             	call   *0x8(%ebp)
  8004a3:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a6:	83 ef 01             	sub    $0x1,%edi
  8004a9:	83 c3 01             	add    $0x1,%ebx
  8004ac:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8004b0:	0f be c2             	movsbl %dl,%eax
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	74 50                	je     800507 <vprintfmt+0x24f>
  8004b7:	85 f6                	test   %esi,%esi
  8004b9:	78 d8                	js     800493 <vprintfmt+0x1db>
  8004bb:	83 ee 01             	sub    $0x1,%esi
  8004be:	79 d3                	jns    800493 <vprintfmt+0x1db>
  8004c0:	89 fb                	mov    %edi,%ebx
  8004c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004c8:	eb 37                	jmp    800501 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ca:	0f be d2             	movsbl %dl,%edx
  8004cd:	83 ea 20             	sub    $0x20,%edx
  8004d0:	83 fa 5e             	cmp    $0x5e,%edx
  8004d3:	76 c4                	jbe    800499 <vprintfmt+0x1e1>
					putch('?', putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 0c             	pushl  0xc(%ebp)
  8004db:	6a 3f                	push   $0x3f
  8004dd:	ff 55 08             	call   *0x8(%ebp)
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	eb c1                	jmp    8004a6 <vprintfmt+0x1ee>
  8004e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004eb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004ee:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004f1:	eb b6                	jmp    8004a9 <vprintfmt+0x1f1>
				putch(' ', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	57                   	push   %edi
  8004f7:	6a 20                	push   $0x20
  8004f9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004fb:	83 eb 01             	sub    $0x1,%ebx
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 db                	test   %ebx,%ebx
  800503:	7f ee                	jg     8004f3 <vprintfmt+0x23b>
  800505:	eb 67                	jmp    80056e <vprintfmt+0x2b6>
  800507:	89 fb                	mov    %edi,%ebx
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80050f:	eb f0                	jmp    800501 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800511:	8d 45 14             	lea    0x14(%ebp),%eax
  800514:	e8 33 fd ff ff       	call   80024c <getint>
  800519:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80051f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800524:	85 d2                	test   %edx,%edx
  800526:	79 2c                	jns    800554 <vprintfmt+0x29c>
				putch('-', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	57                   	push   %edi
  80052c:	6a 2d                	push   $0x2d
  80052e:	ff d6                	call   *%esi
				num = -(long long) num;
  800530:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800533:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800536:	f7 d8                	neg    %eax
  800538:	83 d2 00             	adc    $0x0,%edx
  80053b:	f7 da                	neg    %edx
  80053d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800540:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800545:	eb 0d                	jmp    800554 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800547:	8d 45 14             	lea    0x14(%ebp),%eax
  80054a:	e8 c3 fc ff ff       	call   800212 <getuint>
			base = 10;
  80054f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800554:	83 ec 0c             	sub    $0xc,%esp
  800557:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80055b:	53                   	push   %ebx
  80055c:	ff 75 e0             	pushl  -0x20(%ebp)
  80055f:	51                   	push   %ecx
  800560:	52                   	push   %edx
  800561:	50                   	push   %eax
  800562:	89 fa                	mov    %edi,%edx
  800564:	89 f0                	mov    %esi,%eax
  800566:	e8 f8 fb ff ff       	call   800163 <printnum>
			break;
  80056b:	83 c4 20             	add    $0x20,%esp
{
  80056e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800571:	83 c3 01             	add    $0x1,%ebx
  800574:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800578:	83 f8 25             	cmp    $0x25,%eax
  80057b:	0f 84 52 fd ff ff    	je     8002d3 <vprintfmt+0x1b>
			if (ch == '\0')
  800581:	85 c0                	test   %eax,%eax
  800583:	0f 84 84 00 00 00    	je     80060d <vprintfmt+0x355>
			putch(ch, putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	57                   	push   %edi
  80058d:	50                   	push   %eax
  80058e:	ff d6                	call   *%esi
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	eb dc                	jmp    800571 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  800595:	8d 45 14             	lea    0x14(%ebp),%eax
  800598:	e8 75 fc ff ff       	call   800212 <getuint>
			base = 8;
  80059d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005a2:	eb b0                	jmp    800554 <vprintfmt+0x29c>
			putch('0', putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	57                   	push   %edi
  8005a8:	6a 30                	push   $0x30
  8005aa:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ac:	83 c4 08             	add    $0x8,%esp
  8005af:	57                   	push   %edi
  8005b0:	6a 78                	push   $0x78
  8005b2:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8005c4:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005c7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005cc:	eb 86                	jmp    800554 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 3c fc ff ff       	call   800212 <getuint>
			base = 16;
  8005d6:	b9 10 00 00 00       	mov    $0x10,%ecx
  8005db:	e9 74 ff ff ff       	jmp    800554 <vprintfmt+0x29c>
			putch(ch, putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	57                   	push   %edi
  8005e4:	6a 25                	push   $0x25
  8005e6:	ff d6                	call   *%esi
			break;
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	eb 81                	jmp    80056e <vprintfmt+0x2b6>
			putch('%', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	57                   	push   %edi
  8005f1:	6a 25                	push   $0x25
  8005f3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005f5:	83 c4 10             	add    $0x10,%esp
  8005f8:	89 d8                	mov    %ebx,%eax
  8005fa:	eb 03                	jmp    8005ff <vprintfmt+0x347>
  8005fc:	83 e8 01             	sub    $0x1,%eax
  8005ff:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800603:	75 f7                	jne    8005fc <vprintfmt+0x344>
  800605:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800608:	e9 61 ff ff ff       	jmp    80056e <vprintfmt+0x2b6>
}
  80060d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800610:	5b                   	pop    %ebx
  800611:	5e                   	pop    %esi
  800612:	5f                   	pop    %edi
  800613:	5d                   	pop    %ebp
  800614:	c3                   	ret    

00800615 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800615:	55                   	push   %ebp
  800616:	89 e5                	mov    %esp,%ebp
  800618:	83 ec 18             	sub    $0x18,%esp
  80061b:	8b 45 08             	mov    0x8(%ebp),%eax
  80061e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800621:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800624:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800628:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80062b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800632:	85 c0                	test   %eax,%eax
  800634:	74 26                	je     80065c <vsnprintf+0x47>
  800636:	85 d2                	test   %edx,%edx
  800638:	7e 22                	jle    80065c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80063a:	ff 75 14             	pushl  0x14(%ebp)
  80063d:	ff 75 10             	pushl  0x10(%ebp)
  800640:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800643:	50                   	push   %eax
  800644:	68 7e 02 80 00       	push   $0x80027e
  800649:	e8 6a fc ff ff       	call   8002b8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80064e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800651:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800654:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800657:	83 c4 10             	add    $0x10,%esp
}
  80065a:	c9                   	leave  
  80065b:	c3                   	ret    
		return -E_INVAL;
  80065c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800661:	eb f7                	jmp    80065a <vsnprintf+0x45>

00800663 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
  800666:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80066c:	50                   	push   %eax
  80066d:	ff 75 10             	pushl  0x10(%ebp)
  800670:	ff 75 0c             	pushl  0xc(%ebp)
  800673:	ff 75 08             	pushl  0x8(%ebp)
  800676:	e8 9a ff ff ff       	call   800615 <vsnprintf>
	va_end(ap);

	return rc;
}
  80067b:	c9                   	leave  
  80067c:	c3                   	ret    

0080067d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	eb 03                	jmp    80068d <strlen+0x10>
		n++;
  80068a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80068d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800691:	75 f7                	jne    80068a <strlen+0xd>
	return n;
}
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80069e:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a3:	eb 03                	jmp    8006a8 <strnlen+0x13>
		n++;
  8006a5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006a8:	39 d0                	cmp    %edx,%eax
  8006aa:	74 06                	je     8006b2 <strnlen+0x1d>
  8006ac:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006b0:	75 f3                	jne    8006a5 <strnlen+0x10>
	return n;
}
  8006b2:	5d                   	pop    %ebp
  8006b3:	c3                   	ret    

008006b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	53                   	push   %ebx
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006be:	89 c2                	mov    %eax,%edx
  8006c0:	83 c1 01             	add    $0x1,%ecx
  8006c3:	83 c2 01             	add    $0x1,%edx
  8006c6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006ca:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006cd:	84 db                	test   %bl,%bl
  8006cf:	75 ef                	jne    8006c0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006d1:	5b                   	pop    %ebx
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	53                   	push   %ebx
  8006d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006db:	53                   	push   %ebx
  8006dc:	e8 9c ff ff ff       	call   80067d <strlen>
  8006e1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	01 d8                	add    %ebx,%eax
  8006e9:	50                   	push   %eax
  8006ea:	e8 c5 ff ff ff       	call   8006b4 <strcpy>
	return dst;
}
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	56                   	push   %esi
  8006fa:	53                   	push   %ebx
  8006fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800701:	89 f3                	mov    %esi,%ebx
  800703:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800706:	89 f2                	mov    %esi,%edx
  800708:	eb 0f                	jmp    800719 <strncpy+0x23>
		*dst++ = *src;
  80070a:	83 c2 01             	add    $0x1,%edx
  80070d:	0f b6 01             	movzbl (%ecx),%eax
  800710:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800713:	80 39 01             	cmpb   $0x1,(%ecx)
  800716:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800719:	39 da                	cmp    %ebx,%edx
  80071b:	75 ed                	jne    80070a <strncpy+0x14>
	}
	return ret;
}
  80071d:	89 f0                	mov    %esi,%eax
  80071f:	5b                   	pop    %ebx
  800720:	5e                   	pop    %esi
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	56                   	push   %esi
  800727:	53                   	push   %ebx
  800728:	8b 75 08             	mov    0x8(%ebp),%esi
  80072b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80072e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800731:	89 f0                	mov    %esi,%eax
  800733:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800737:	85 c9                	test   %ecx,%ecx
  800739:	75 0b                	jne    800746 <strlcpy+0x23>
  80073b:	eb 17                	jmp    800754 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80073d:	83 c2 01             	add    $0x1,%edx
  800740:	83 c0 01             	add    $0x1,%eax
  800743:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800746:	39 d8                	cmp    %ebx,%eax
  800748:	74 07                	je     800751 <strlcpy+0x2e>
  80074a:	0f b6 0a             	movzbl (%edx),%ecx
  80074d:	84 c9                	test   %cl,%cl
  80074f:	75 ec                	jne    80073d <strlcpy+0x1a>
		*dst = '\0';
  800751:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800754:	29 f0                	sub    %esi,%eax
}
  800756:	5b                   	pop    %ebx
  800757:	5e                   	pop    %esi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800760:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800763:	eb 06                	jmp    80076b <strcmp+0x11>
		p++, q++;
  800765:	83 c1 01             	add    $0x1,%ecx
  800768:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80076b:	0f b6 01             	movzbl (%ecx),%eax
  80076e:	84 c0                	test   %al,%al
  800770:	74 04                	je     800776 <strcmp+0x1c>
  800772:	3a 02                	cmp    (%edx),%al
  800774:	74 ef                	je     800765 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800776:	0f b6 c0             	movzbl %al,%eax
  800779:	0f b6 12             	movzbl (%edx),%edx
  80077c:	29 d0                	sub    %edx,%eax
}
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078a:	89 c3                	mov    %eax,%ebx
  80078c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80078f:	eb 06                	jmp    800797 <strncmp+0x17>
		n--, p++, q++;
  800791:	83 c0 01             	add    $0x1,%eax
  800794:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800797:	39 d8                	cmp    %ebx,%eax
  800799:	74 16                	je     8007b1 <strncmp+0x31>
  80079b:	0f b6 08             	movzbl (%eax),%ecx
  80079e:	84 c9                	test   %cl,%cl
  8007a0:	74 04                	je     8007a6 <strncmp+0x26>
  8007a2:	3a 0a                	cmp    (%edx),%cl
  8007a4:	74 eb                	je     800791 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a6:	0f b6 00             	movzbl (%eax),%eax
  8007a9:	0f b6 12             	movzbl (%edx),%edx
  8007ac:	29 d0                	sub    %edx,%eax
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    
		return 0;
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	eb f6                	jmp    8007ae <strncmp+0x2e>

008007b8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007c2:	0f b6 10             	movzbl (%eax),%edx
  8007c5:	84 d2                	test   %dl,%dl
  8007c7:	74 09                	je     8007d2 <strchr+0x1a>
		if (*s == c)
  8007c9:	38 ca                	cmp    %cl,%dl
  8007cb:	74 0a                	je     8007d7 <strchr+0x1f>
	for (; *s; s++)
  8007cd:	83 c0 01             	add    $0x1,%eax
  8007d0:	eb f0                	jmp    8007c2 <strchr+0xa>
			return (char *) s;
	return 0;
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e3:	eb 03                	jmp    8007e8 <strfind+0xf>
  8007e5:	83 c0 01             	add    $0x1,%eax
  8007e8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007eb:	38 ca                	cmp    %cl,%dl
  8007ed:	74 04                	je     8007f3 <strfind+0x1a>
  8007ef:	84 d2                	test   %dl,%dl
  8007f1:	75 f2                	jne    8007e5 <strfind+0xc>
			break;
	return (char *) s;
}
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	57                   	push   %edi
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8007fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800801:	85 c9                	test   %ecx,%ecx
  800803:	74 12                	je     800817 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800805:	f6 c2 03             	test   $0x3,%dl
  800808:	75 05                	jne    80080f <memset+0x1a>
  80080a:	f6 c1 03             	test   $0x3,%cl
  80080d:	74 0f                	je     80081e <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80080f:	89 d7                	mov    %edx,%edi
  800811:	8b 45 0c             	mov    0xc(%ebp),%eax
  800814:	fc                   	cld    
  800815:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800817:	89 d0                	mov    %edx,%eax
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5f                   	pop    %edi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    
		c &= 0xFF;
  80081e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800822:	89 d8                	mov    %ebx,%eax
  800824:	c1 e0 08             	shl    $0x8,%eax
  800827:	89 df                	mov    %ebx,%edi
  800829:	c1 e7 18             	shl    $0x18,%edi
  80082c:	89 de                	mov    %ebx,%esi
  80082e:	c1 e6 10             	shl    $0x10,%esi
  800831:	09 f7                	or     %esi,%edi
  800833:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800835:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800838:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80083a:	89 d7                	mov    %edx,%edi
  80083c:	fc                   	cld    
  80083d:	f3 ab                	rep stos %eax,%es:(%edi)
  80083f:	eb d6                	jmp    800817 <memset+0x22>

00800841 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	57                   	push   %edi
  800845:	56                   	push   %esi
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 75 0c             	mov    0xc(%ebp),%esi
  80084c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80084f:	39 c6                	cmp    %eax,%esi
  800851:	73 35                	jae    800888 <memmove+0x47>
  800853:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800856:	39 c2                	cmp    %eax,%edx
  800858:	76 2e                	jbe    800888 <memmove+0x47>
		s += n;
		d += n;
  80085a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80085d:	89 d6                	mov    %edx,%esi
  80085f:	09 fe                	or     %edi,%esi
  800861:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800867:	74 0c                	je     800875 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800869:	83 ef 01             	sub    $0x1,%edi
  80086c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80086f:	fd                   	std    
  800870:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800872:	fc                   	cld    
  800873:	eb 21                	jmp    800896 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800875:	f6 c1 03             	test   $0x3,%cl
  800878:	75 ef                	jne    800869 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80087a:	83 ef 04             	sub    $0x4,%edi
  80087d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800880:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800883:	fd                   	std    
  800884:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800886:	eb ea                	jmp    800872 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800888:	89 f2                	mov    %esi,%edx
  80088a:	09 c2                	or     %eax,%edx
  80088c:	f6 c2 03             	test   $0x3,%dl
  80088f:	74 09                	je     80089a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800891:	89 c7                	mov    %eax,%edi
  800893:	fc                   	cld    
  800894:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800896:	5e                   	pop    %esi
  800897:	5f                   	pop    %edi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089a:	f6 c1 03             	test   $0x3,%cl
  80089d:	75 f2                	jne    800891 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80089f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008a2:	89 c7                	mov    %eax,%edi
  8008a4:	fc                   	cld    
  8008a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a7:	eb ed                	jmp    800896 <memmove+0x55>

008008a9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ac:	ff 75 10             	pushl  0x10(%ebp)
  8008af:	ff 75 0c             	pushl  0xc(%ebp)
  8008b2:	ff 75 08             	pushl  0x8(%ebp)
  8008b5:	e8 87 ff ff ff       	call   800841 <memmove>
}
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c7:	89 c6                	mov    %eax,%esi
  8008c9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008cc:	39 f0                	cmp    %esi,%eax
  8008ce:	74 1c                	je     8008ec <memcmp+0x30>
		if (*s1 != *s2)
  8008d0:	0f b6 08             	movzbl (%eax),%ecx
  8008d3:	0f b6 1a             	movzbl (%edx),%ebx
  8008d6:	38 d9                	cmp    %bl,%cl
  8008d8:	75 08                	jne    8008e2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008da:	83 c0 01             	add    $0x1,%eax
  8008dd:	83 c2 01             	add    $0x1,%edx
  8008e0:	eb ea                	jmp    8008cc <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8008e2:	0f b6 c1             	movzbl %cl,%eax
  8008e5:	0f b6 db             	movzbl %bl,%ebx
  8008e8:	29 d8                	sub    %ebx,%eax
  8008ea:	eb 05                	jmp    8008f1 <memcmp+0x35>
	}

	return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008fe:	89 c2                	mov    %eax,%edx
  800900:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800903:	39 d0                	cmp    %edx,%eax
  800905:	73 09                	jae    800910 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800907:	38 08                	cmp    %cl,(%eax)
  800909:	74 05                	je     800910 <memfind+0x1b>
	for (; s < ends; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	eb f3                	jmp    800903 <memfind+0xe>
			break;
	return (void *) s;
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80091e:	eb 03                	jmp    800923 <strtol+0x11>
		s++;
  800920:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800923:	0f b6 01             	movzbl (%ecx),%eax
  800926:	3c 20                	cmp    $0x20,%al
  800928:	74 f6                	je     800920 <strtol+0xe>
  80092a:	3c 09                	cmp    $0x9,%al
  80092c:	74 f2                	je     800920 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80092e:	3c 2b                	cmp    $0x2b,%al
  800930:	74 2e                	je     800960 <strtol+0x4e>
	int neg = 0;
  800932:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800937:	3c 2d                	cmp    $0x2d,%al
  800939:	74 2f                	je     80096a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80093b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800941:	75 05                	jne    800948 <strtol+0x36>
  800943:	80 39 30             	cmpb   $0x30,(%ecx)
  800946:	74 2c                	je     800974 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800948:	85 db                	test   %ebx,%ebx
  80094a:	75 0a                	jne    800956 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80094c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800951:	80 39 30             	cmpb   $0x30,(%ecx)
  800954:	74 28                	je     80097e <strtol+0x6c>
		base = 10;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80095e:	eb 50                	jmp    8009b0 <strtol+0x9e>
		s++;
  800960:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800963:	bf 00 00 00 00       	mov    $0x0,%edi
  800968:	eb d1                	jmp    80093b <strtol+0x29>
		s++, neg = 1;
  80096a:	83 c1 01             	add    $0x1,%ecx
  80096d:	bf 01 00 00 00       	mov    $0x1,%edi
  800972:	eb c7                	jmp    80093b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800974:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800978:	74 0e                	je     800988 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80097a:	85 db                	test   %ebx,%ebx
  80097c:	75 d8                	jne    800956 <strtol+0x44>
		s++, base = 8;
  80097e:	83 c1 01             	add    $0x1,%ecx
  800981:	bb 08 00 00 00       	mov    $0x8,%ebx
  800986:	eb ce                	jmp    800956 <strtol+0x44>
		s += 2, base = 16;
  800988:	83 c1 02             	add    $0x2,%ecx
  80098b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800990:	eb c4                	jmp    800956 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800992:	8d 72 9f             	lea    -0x61(%edx),%esi
  800995:	89 f3                	mov    %esi,%ebx
  800997:	80 fb 19             	cmp    $0x19,%bl
  80099a:	77 29                	ja     8009c5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80099c:	0f be d2             	movsbl %dl,%edx
  80099f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009a2:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009a5:	7d 30                	jge    8009d7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8009a7:	83 c1 01             	add    $0x1,%ecx
  8009aa:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009ae:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009b0:	0f b6 11             	movzbl (%ecx),%edx
  8009b3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b6:	89 f3                	mov    %esi,%ebx
  8009b8:	80 fb 09             	cmp    $0x9,%bl
  8009bb:	77 d5                	ja     800992 <strtol+0x80>
			dig = *s - '0';
  8009bd:	0f be d2             	movsbl %dl,%edx
  8009c0:	83 ea 30             	sub    $0x30,%edx
  8009c3:	eb dd                	jmp    8009a2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  8009c5:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009c8:	89 f3                	mov    %esi,%ebx
  8009ca:	80 fb 19             	cmp    $0x19,%bl
  8009cd:	77 08                	ja     8009d7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009cf:	0f be d2             	movsbl %dl,%edx
  8009d2:	83 ea 37             	sub    $0x37,%edx
  8009d5:	eb cb                	jmp    8009a2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009db:	74 05                	je     8009e2 <strtol+0xd0>
		*endptr = (char *) s;
  8009dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8009e2:	89 c2                	mov    %eax,%edx
  8009e4:	f7 da                	neg    %edx
  8009e6:	85 ff                	test   %edi,%edi
  8009e8:	0f 45 c2             	cmovne %edx,%eax
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5f                   	pop    %edi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	57                   	push   %edi
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	83 ec 1c             	sub    $0x1c,%esp
  8009f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009ff:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a07:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a0a:	8b 75 14             	mov    0x14(%ebp),%esi
  800a0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a0f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a13:	74 04                	je     800a19 <syscall+0x29>
  800a15:	85 c0                	test   %eax,%eax
  800a17:	7f 08                	jg     800a21 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a1c:	5b                   	pop    %ebx
  800a1d:	5e                   	pop    %esi
  800a1e:	5f                   	pop    %edi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    
  800a21:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800a24:	83 ec 0c             	sub    $0xc,%esp
  800a27:	50                   	push   %eax
  800a28:	52                   	push   %edx
  800a29:	68 04 11 80 00       	push   $0x801104
  800a2e:	6a 23                	push   $0x23
  800a30:	68 21 11 80 00       	push   $0x801121
  800a35:	e8 b1 01 00 00       	call   800beb <_panic>

00800a3a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800a40:	6a 00                	push   $0x0
  800a42:	6a 00                	push   $0x0
  800a44:	6a 00                	push   $0x0
  800a46:	ff 75 0c             	pushl  0xc(%ebp)
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
  800a56:	e8 95 ff ff ff       	call   8009f0 <syscall>
}
  800a5b:	83 c4 10             	add    $0x10,%esp
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a66:	6a 00                	push   $0x0
  800a68:	6a 00                	push   $0x0
  800a6a:	6a 00                	push   $0x0
  800a6c:	6a 00                	push   $0x0
  800a6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a73:	ba 00 00 00 00       	mov    $0x0,%edx
  800a78:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7d:	e8 6e ff ff ff       	call   8009f0 <syscall>
}
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800a8a:	6a 00                	push   $0x0
  800a8c:	6a 00                	push   $0x0
  800a8e:	6a 00                	push   $0x0
  800a90:	6a 00                	push   $0x0
  800a92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a95:	ba 01 00 00 00       	mov    $0x1,%edx
  800a9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9f:	e8 4c ff ff ff       	call   8009f0 <syscall>
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800aac:	6a 00                	push   $0x0
  800aae:	6a 00                	push   $0x0
  800ab0:	6a 00                	push   $0x0
  800ab2:	6a 00                	push   $0x0
  800ab4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac3:	e8 28 ff ff ff       	call   8009f0 <syscall>
}
  800ac8:	c9                   	leave  
  800ac9:	c3                   	ret    

00800aca <sys_yield>:

void
sys_yield(void)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ad0:	6a 00                	push   $0x0
  800ad2:	6a 00                	push   $0x0
  800ad4:	6a 00                	push   $0x0
  800ad6:	6a 00                	push   $0x0
  800ad8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae7:	e8 04 ff ff ff       	call   8009f0 <syscall>
}
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	c9                   	leave  
  800af0:	c3                   	ret    

00800af1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800af7:	6a 00                	push   $0x0
  800af9:	6a 00                	push   $0x0
  800afb:	ff 75 10             	pushl  0x10(%ebp)
  800afe:	ff 75 0c             	pushl  0xc(%ebp)
  800b01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b04:	ba 01 00 00 00       	mov    $0x1,%edx
  800b09:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0e:	e8 dd fe ff ff       	call   8009f0 <syscall>
}
  800b13:	c9                   	leave  
  800b14:	c3                   	ret    

00800b15 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b1b:	ff 75 18             	pushl  0x18(%ebp)
  800b1e:	ff 75 14             	pushl  0x14(%ebp)
  800b21:	ff 75 10             	pushl  0x10(%ebp)
  800b24:	ff 75 0c             	pushl  0xc(%ebp)
  800b27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2a:	ba 01 00 00 00       	mov    $0x1,%edx
  800b2f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b34:	e8 b7 fe ff ff       	call   8009f0 <syscall>
}
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b41:	6a 00                	push   $0x0
  800b43:	6a 00                	push   $0x0
  800b45:	6a 00                	push   $0x0
  800b47:	ff 75 0c             	pushl  0xc(%ebp)
  800b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4d:	ba 01 00 00 00       	mov    $0x1,%edx
  800b52:	b8 06 00 00 00       	mov    $0x6,%eax
  800b57:	e8 94 fe ff ff       	call   8009f0 <syscall>
}
  800b5c:	c9                   	leave  
  800b5d:	c3                   	ret    

00800b5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b64:	6a 00                	push   $0x0
  800b66:	6a 00                	push   $0x0
  800b68:	6a 00                	push   $0x0
  800b6a:	ff 75 0c             	pushl  0xc(%ebp)
  800b6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b70:	ba 01 00 00 00       	mov    $0x1,%edx
  800b75:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7a:	e8 71 fe ff ff       	call   8009f0 <syscall>
}
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	ff 75 0c             	pushl  0xc(%ebp)
  800b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b93:	ba 01 00 00 00       	mov    $0x1,%edx
  800b98:	b8 09 00 00 00       	mov    $0x9,%eax
  800b9d:	e8 4e fe ff ff       	call   8009f0 <syscall>
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800baa:	6a 00                	push   $0x0
  800bac:	ff 75 14             	pushl  0x14(%ebp)
  800baf:	ff 75 10             	pushl  0x10(%ebp)
  800bb2:	ff 75 0c             	pushl  0xc(%ebp)
  800bb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc2:	e8 29 fe ff ff       	call   8009f0 <syscall>
}
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800bcf:	6a 00                	push   $0x0
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bda:	ba 01 00 00 00       	mov    $0x1,%edx
  800bdf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800be4:	e8 07 fe ff ff       	call   8009f0 <syscall>
}
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800bf0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bf3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800bf9:	e8 a8 fe ff ff       	call   800aa6 <sys_getenvid>
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	ff 75 0c             	pushl  0xc(%ebp)
  800c04:	ff 75 08             	pushl  0x8(%ebp)
  800c07:	56                   	push   %esi
  800c08:	50                   	push   %eax
  800c09:	68 30 11 80 00       	push   $0x801130
  800c0e:	e8 3c f5 ff ff       	call   80014f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c13:	83 c4 18             	add    $0x18,%esp
  800c16:	53                   	push   %ebx
  800c17:	ff 75 10             	pushl  0x10(%ebp)
  800c1a:	e8 df f4 ff ff       	call   8000fe <vcprintf>
	cprintf("\n");
  800c1f:	c7 04 24 8c 0e 80 00 	movl   $0x800e8c,(%esp)
  800c26:	e8 24 f5 ff ff       	call   80014f <cprintf>
  800c2b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c2e:	cc                   	int3   
  800c2f:	eb fd                	jmp    800c2e <_panic+0x43>
  800c31:	66 90                	xchg   %ax,%ax
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
