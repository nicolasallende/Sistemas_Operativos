
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 80 0e 80 00       	push   $0x800e80
  800044:	e8 f6 00 00 00       	call   80013f <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800059:	e8 38 0a 00 00       	call   800a96 <sys_getenvid>
	if (id >= 0)
  80005e:	85 c0                	test   %eax,%eax
  800060:	78 12                	js     800074 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	c1 e0 07             	shl    $0x7,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 db                	test   %ebx,%ebx
  800076:	7e 07                	jle    80007f <libmain+0x31>
		binaryname = argv[0];
  800078:	8b 06                	mov    (%esi),%eax
  80007a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	e8 aa ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800089:	e8 0a 00 00 00       	call   800098 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 cf 09 00 00       	call   800a74 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	53                   	push   %ebx
  8000ae:	83 ec 04             	sub    $0x4,%esp
  8000b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b4:	8b 13                	mov    (%ebx),%edx
  8000b6:	8d 42 01             	lea    0x1(%edx),%eax
  8000b9:	89 03                	mov    %eax,(%ebx)
  8000bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000be:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c7:	74 09                	je     8000d2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000c9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	68 ff 00 00 00       	push   $0xff
  8000da:	8d 43 08             	lea    0x8(%ebx),%eax
  8000dd:	50                   	push   %eax
  8000de:	e8 47 09 00 00       	call   800a2a <sys_cputs>
		b->idx = 0;
  8000e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	eb db                	jmp    8000c9 <putch+0x1f>

008000ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fe:	00 00 00 
	b.cnt = 0;
  800101:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800108:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010b:	ff 75 0c             	pushl  0xc(%ebp)
  80010e:	ff 75 08             	pushl  0x8(%ebp)
  800111:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800117:	50                   	push   %eax
  800118:	68 aa 00 80 00       	push   $0x8000aa
  80011d:	e8 86 01 00 00       	call   8002a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800122:	83 c4 08             	add    $0x8,%esp
  800125:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800131:	50                   	push   %eax
  800132:	e8 f3 08 00 00       	call   800a2a <sys_cputs>

	return b.cnt;
}
  800137:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800145:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800148:	50                   	push   %eax
  800149:	ff 75 08             	pushl  0x8(%ebp)
  80014c:	e8 9d ff ff ff       	call   8000ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
  800159:	83 ec 1c             	sub    $0x1c,%esp
  80015c:	89 c7                	mov    %eax,%edi
  80015e:	89 d6                	mov    %edx,%esi
  800160:	8b 45 08             	mov    0x8(%ebp),%eax
  800163:	8b 55 0c             	mov    0xc(%ebp),%edx
  800166:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800169:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80016f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800174:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800177:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017a:	39 d3                	cmp    %edx,%ebx
  80017c:	72 05                	jb     800183 <printnum+0x30>
  80017e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800181:	77 7a                	ja     8001fd <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	ff 75 18             	pushl  0x18(%ebp)
  800189:	8b 45 14             	mov    0x14(%ebp),%eax
  80018c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80018f:	53                   	push   %ebx
  800190:	ff 75 10             	pushl  0x10(%ebp)
  800193:	83 ec 08             	sub    $0x8,%esp
  800196:	ff 75 e4             	pushl  -0x1c(%ebp)
  800199:	ff 75 e0             	pushl  -0x20(%ebp)
  80019c:	ff 75 dc             	pushl  -0x24(%ebp)
  80019f:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a2:	e8 89 0a 00 00       	call   800c30 <__udivdi3>
  8001a7:	83 c4 18             	add    $0x18,%esp
  8001aa:	52                   	push   %edx
  8001ab:	50                   	push   %eax
  8001ac:	89 f2                	mov    %esi,%edx
  8001ae:	89 f8                	mov    %edi,%eax
  8001b0:	e8 9e ff ff ff       	call   800153 <printnum>
  8001b5:	83 c4 20             	add    $0x20,%esp
  8001b8:	eb 13                	jmp    8001cd <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ba:	83 ec 08             	sub    $0x8,%esp
  8001bd:	56                   	push   %esi
  8001be:	ff 75 18             	pushl  0x18(%ebp)
  8001c1:	ff d7                	call   *%edi
  8001c3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001c6:	83 eb 01             	sub    $0x1,%ebx
  8001c9:	85 db                	test   %ebx,%ebx
  8001cb:	7f ed                	jg     8001ba <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cd:	83 ec 08             	sub    $0x8,%esp
  8001d0:	56                   	push   %esi
  8001d1:	83 ec 04             	sub    $0x4,%esp
  8001d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001da:	ff 75 dc             	pushl  -0x24(%ebp)
  8001dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e0:	e8 6b 0b 00 00       	call   800d50 <__umoddi3>
  8001e5:	83 c4 14             	add    $0x14,%esp
  8001e8:	0f be 80 b1 0e 80 00 	movsbl 0x800eb1(%eax),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff d7                	call   *%edi
}
  8001f2:	83 c4 10             	add    $0x10,%esp
  8001f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f8:	5b                   	pop    %ebx
  8001f9:	5e                   	pop    %esi
  8001fa:	5f                   	pop    %edi
  8001fb:	5d                   	pop    %ebp
  8001fc:	c3                   	ret    
  8001fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800200:	eb c4                	jmp    8001c6 <printnum+0x73>

00800202 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800205:	83 fa 01             	cmp    $0x1,%edx
  800208:	7e 0e                	jle    800218 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020a:	8b 10                	mov    (%eax),%edx
  80020c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80020f:	89 08                	mov    %ecx,(%eax)
  800211:	8b 02                	mov    (%edx),%eax
  800213:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    
	else if (lflag)
  800218:	85 d2                	test   %edx,%edx
  80021a:	75 10                	jne    80022c <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800221:	89 08                	mov    %ecx,(%eax)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	ba 00 00 00 00       	mov    $0x0,%edx
  80022a:	eb ea                	jmp    800216 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  80022c:	8b 10                	mov    (%eax),%edx
  80022e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800231:	89 08                	mov    %ecx,(%eax)
  800233:	8b 02                	mov    (%edx),%eax
  800235:	ba 00 00 00 00       	mov    $0x0,%edx
  80023a:	eb da                	jmp    800216 <getuint+0x14>

0080023c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023f:	83 fa 01             	cmp    $0x1,%edx
  800242:	7e 0e                	jle    800252 <getint+0x16>
		return va_arg(*ap, long long);
  800244:	8b 10                	mov    (%eax),%edx
  800246:	8d 4a 08             	lea    0x8(%edx),%ecx
  800249:	89 08                	mov    %ecx,(%eax)
  80024b:	8b 02                	mov    (%edx),%eax
  80024d:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    
	else if (lflag)
  800252:	85 d2                	test   %edx,%edx
  800254:	75 0c                	jne    800262 <getint+0x26>
		return va_arg(*ap, int);
  800256:	8b 10                	mov    (%eax),%edx
  800258:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025b:	89 08                	mov    %ecx,(%eax)
  80025d:	8b 02                	mov    (%edx),%eax
  80025f:	99                   	cltd   
  800260:	eb ee                	jmp    800250 <getint+0x14>
		return va_arg(*ap, long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 04             	lea    0x4(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	99                   	cltd   
  80026c:	eb e2                	jmp    800250 <getint+0x14>

0080026e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800274:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	3b 50 04             	cmp    0x4(%eax),%edx
  80027d:	73 0a                	jae    800289 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 45 08             	mov    0x8(%ebp),%eax
  800287:	88 02                	mov    %al,(%edx)
}
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <printfmt>:
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800291:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800294:	50                   	push   %eax
  800295:	ff 75 10             	pushl  0x10(%ebp)
  800298:	ff 75 0c             	pushl  0xc(%ebp)
  80029b:	ff 75 08             	pushl  0x8(%ebp)
  80029e:	e8 05 00 00 00       	call   8002a8 <vprintfmt>
}
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <vprintfmt>:
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 2c             	sub    $0x2c,%esp
  8002b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002b7:	89 f7                	mov    %esi,%edi
  8002b9:	89 de                	mov    %ebx,%esi
  8002bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002be:	e9 9e 02 00 00       	jmp    800561 <vprintfmt+0x2b9>
		padc = ' ';
  8002c3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002dc:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8d 43 01             	lea    0x1(%ebx),%eax
  8002e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e7:	0f b6 0b             	movzbl (%ebx),%ecx
  8002ea:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8002ed:	3c 55                	cmp    $0x55,%al
  8002ef:	0f 87 e8 02 00 00    	ja     8005dd <vprintfmt+0x335>
  8002f5:	0f b6 c0             	movzbl %al,%eax
  8002f8:	ff 24 85 80 0f 80 00 	jmp    *0x800f80(,%eax,4)
  8002ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800302:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800306:	eb d9                	jmp    8002e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800308:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  80030b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030f:	eb d0                	jmp    8002e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800311:	0f b6 c9             	movzbl %cl,%ecx
  800314:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800317:	b8 00 00 00 00       	mov    $0x0,%eax
  80031c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80031f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800322:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800326:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800329:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80032c:	83 fa 09             	cmp    $0x9,%edx
  80032f:	77 52                	ja     800383 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800331:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800334:	eb e9                	jmp    80031f <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800336:	8b 45 14             	mov    0x14(%ebp),%eax
  800339:	8d 48 04             	lea    0x4(%eax),%ecx
  80033c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80033f:	8b 00                	mov    (%eax),%eax
  800341:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800347:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034b:	79 94                	jns    8002e1 <vprintfmt+0x39>
				width = precision, precision = -1;
  80034d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800350:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800353:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035a:	eb 85                	jmp    8002e1 <vprintfmt+0x39>
  80035c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035f:	85 c0                	test   %eax,%eax
  800361:	b9 00 00 00 00       	mov    $0x0,%ecx
  800366:	0f 49 c8             	cmovns %eax,%ecx
  800369:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80036f:	e9 6d ff ff ff       	jmp    8002e1 <vprintfmt+0x39>
  800374:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800377:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037e:	e9 5e ff ff ff       	jmp    8002e1 <vprintfmt+0x39>
  800383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800386:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800389:	eb bc                	jmp    800347 <vprintfmt+0x9f>
			lflag++;
  80038b:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800391:	e9 4b ff ff ff       	jmp    8002e1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8d 50 04             	lea    0x4(%eax),%edx
  80039c:	89 55 14             	mov    %edx,0x14(%ebp)
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	57                   	push   %edi
  8003a3:	ff 30                	pushl  (%eax)
  8003a5:	ff d6                	call   *%esi
			break;
  8003a7:	83 c4 10             	add    $0x10,%esp
  8003aa:	e9 af 01 00 00       	jmp    80055e <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8d 50 04             	lea    0x4(%eax),%edx
  8003b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	99                   	cltd   
  8003bb:	31 d0                	xor    %edx,%eax
  8003bd:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bf:	83 f8 08             	cmp    $0x8,%eax
  8003c2:	7f 20                	jg     8003e4 <vprintfmt+0x13c>
  8003c4:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	74 15                	je     8003e4 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  8003cf:	52                   	push   %edx
  8003d0:	68 d2 0e 80 00       	push   $0x800ed2
  8003d5:	57                   	push   %edi
  8003d6:	56                   	push   %esi
  8003d7:	e8 af fe ff ff       	call   80028b <printfmt>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 7a 01 00 00       	jmp    80055e <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8003e4:	50                   	push   %eax
  8003e5:	68 c9 0e 80 00       	push   $0x800ec9
  8003ea:	57                   	push   %edi
  8003eb:	56                   	push   %esi
  8003ec:	e8 9a fe ff ff       	call   80028b <printfmt>
  8003f1:	83 c4 10             	add    $0x10,%esp
  8003f4:	e9 65 01 00 00       	jmp    80055e <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 50 04             	lea    0x4(%eax),%edx
  8003ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800402:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800404:	85 db                	test   %ebx,%ebx
  800406:	b8 c2 0e 80 00       	mov    $0x800ec2,%eax
  80040b:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  80040e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800412:	0f 8e bd 00 00 00    	jle    8004d5 <vprintfmt+0x22d>
  800418:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041c:	75 0e                	jne    80042c <vprintfmt+0x184>
  80041e:	89 75 08             	mov    %esi,0x8(%ebp)
  800421:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800424:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800427:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80042a:	eb 6d                	jmp    800499 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042c:	83 ec 08             	sub    $0x8,%esp
  80042f:	ff 75 d0             	pushl  -0x30(%ebp)
  800432:	53                   	push   %ebx
  800433:	e8 4d 02 00 00       	call   800685 <strnlen>
  800438:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043b:	29 c1                	sub    %eax,%ecx
  80043d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800440:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800443:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800447:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80044d:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80044f:	eb 0f                	jmp    800460 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	57                   	push   %edi
  800455:	ff 75 e0             	pushl  -0x20(%ebp)
  800458:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045a:	83 eb 01             	sub    $0x1,%ebx
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	85 db                	test   %ebx,%ebx
  800462:	7f ed                	jg     800451 <vprintfmt+0x1a9>
  800464:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800467:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80046a:	85 c9                	test   %ecx,%ecx
  80046c:	b8 00 00 00 00       	mov    $0x0,%eax
  800471:	0f 49 c1             	cmovns %ecx,%eax
  800474:	29 c1                	sub    %eax,%ecx
  800476:	89 75 08             	mov    %esi,0x8(%ebp)
  800479:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80047c:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80047f:	89 cf                	mov    %ecx,%edi
  800481:	eb 16                	jmp    800499 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800483:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800487:	75 31                	jne    8004ba <vprintfmt+0x212>
					putch(ch, putdat);
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	ff 75 0c             	pushl  0xc(%ebp)
  80048f:	50                   	push   %eax
  800490:	ff 55 08             	call   *0x8(%ebp)
  800493:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800496:	83 ef 01             	sub    $0x1,%edi
  800499:	83 c3 01             	add    $0x1,%ebx
  80049c:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8004a0:	0f be c2             	movsbl %dl,%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	74 50                	je     8004f7 <vprintfmt+0x24f>
  8004a7:	85 f6                	test   %esi,%esi
  8004a9:	78 d8                	js     800483 <vprintfmt+0x1db>
  8004ab:	83 ee 01             	sub    $0x1,%esi
  8004ae:	79 d3                	jns    800483 <vprintfmt+0x1db>
  8004b0:	89 fb                	mov    %edi,%ebx
  8004b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004b8:	eb 37                	jmp    8004f1 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ba:	0f be d2             	movsbl %dl,%edx
  8004bd:	83 ea 20             	sub    $0x20,%edx
  8004c0:	83 fa 5e             	cmp    $0x5e,%edx
  8004c3:	76 c4                	jbe    800489 <vprintfmt+0x1e1>
					putch('?', putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	ff 75 0c             	pushl  0xc(%ebp)
  8004cb:	6a 3f                	push   $0x3f
  8004cd:	ff 55 08             	call   *0x8(%ebp)
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	eb c1                	jmp    800496 <vprintfmt+0x1ee>
  8004d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004db:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004de:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e1:	eb b6                	jmp    800499 <vprintfmt+0x1f1>
				putch(' ', putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	57                   	push   %edi
  8004e7:	6a 20                	push   $0x20
  8004e9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004eb:	83 eb 01             	sub    $0x1,%ebx
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	85 db                	test   %ebx,%ebx
  8004f3:	7f ee                	jg     8004e3 <vprintfmt+0x23b>
  8004f5:	eb 67                	jmp    80055e <vprintfmt+0x2b6>
  8004f7:	89 fb                	mov    %edi,%ebx
  8004f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004ff:	eb f0                	jmp    8004f1 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800501:	8d 45 14             	lea    0x14(%ebp),%eax
  800504:	e8 33 fd ff ff       	call   80023c <getint>
  800509:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80050f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800514:	85 d2                	test   %edx,%edx
  800516:	79 2c                	jns    800544 <vprintfmt+0x29c>
				putch('-', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	57                   	push   %edi
  80051c:	6a 2d                	push   $0x2d
  80051e:	ff d6                	call   *%esi
				num = -(long long) num;
  800520:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800523:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800526:	f7 d8                	neg    %eax
  800528:	83 d2 00             	adc    $0x0,%edx
  80052b:	f7 da                	neg    %edx
  80052d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800530:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800535:	eb 0d                	jmp    800544 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800537:	8d 45 14             	lea    0x14(%ebp),%eax
  80053a:	e8 c3 fc ff ff       	call   800202 <getuint>
			base = 10;
  80053f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800544:	83 ec 0c             	sub    $0xc,%esp
  800547:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80054b:	53                   	push   %ebx
  80054c:	ff 75 e0             	pushl  -0x20(%ebp)
  80054f:	51                   	push   %ecx
  800550:	52                   	push   %edx
  800551:	50                   	push   %eax
  800552:	89 fa                	mov    %edi,%edx
  800554:	89 f0                	mov    %esi,%eax
  800556:	e8 f8 fb ff ff       	call   800153 <printnum>
			break;
  80055b:	83 c4 20             	add    $0x20,%esp
{
  80055e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800561:	83 c3 01             	add    $0x1,%ebx
  800564:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800568:	83 f8 25             	cmp    $0x25,%eax
  80056b:	0f 84 52 fd ff ff    	je     8002c3 <vprintfmt+0x1b>
			if (ch == '\0')
  800571:	85 c0                	test   %eax,%eax
  800573:	0f 84 84 00 00 00    	je     8005fd <vprintfmt+0x355>
			putch(ch, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	57                   	push   %edi
  80057d:	50                   	push   %eax
  80057e:	ff d6                	call   *%esi
  800580:	83 c4 10             	add    $0x10,%esp
  800583:	eb dc                	jmp    800561 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  800585:	8d 45 14             	lea    0x14(%ebp),%eax
  800588:	e8 75 fc ff ff       	call   800202 <getuint>
			base = 8;
  80058d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800592:	eb b0                	jmp    800544 <vprintfmt+0x29c>
			putch('0', putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	57                   	push   %edi
  800598:	6a 30                	push   $0x30
  80059a:	ff d6                	call   *%esi
			putch('x', putdat);
  80059c:	83 c4 08             	add    $0x8,%esp
  80059f:	57                   	push   %edi
  8005a0:	6a 78                	push   $0x78
  8005a2:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8005b4:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005b7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005bc:	eb 86                	jmp    800544 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c1:	e8 3c fc ff ff       	call   800202 <getuint>
			base = 16;
  8005c6:	b9 10 00 00 00       	mov    $0x10,%ecx
  8005cb:	e9 74 ff ff ff       	jmp    800544 <vprintfmt+0x29c>
			putch(ch, putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	57                   	push   %edi
  8005d4:	6a 25                	push   $0x25
  8005d6:	ff d6                	call   *%esi
			break;
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	eb 81                	jmp    80055e <vprintfmt+0x2b6>
			putch('%', putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	57                   	push   %edi
  8005e1:	6a 25                	push   $0x25
  8005e3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005e5:	83 c4 10             	add    $0x10,%esp
  8005e8:	89 d8                	mov    %ebx,%eax
  8005ea:	eb 03                	jmp    8005ef <vprintfmt+0x347>
  8005ec:	83 e8 01             	sub    $0x1,%eax
  8005ef:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8005f3:	75 f7                	jne    8005ec <vprintfmt+0x344>
  8005f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f8:	e9 61 ff ff ff       	jmp    80055e <vprintfmt+0x2b6>
}
  8005fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800600:	5b                   	pop    %ebx
  800601:	5e                   	pop    %esi
  800602:	5f                   	pop    %edi
  800603:	5d                   	pop    %ebp
  800604:	c3                   	ret    

00800605 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	83 ec 18             	sub    $0x18,%esp
  80060b:	8b 45 08             	mov    0x8(%ebp),%eax
  80060e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800611:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800614:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800618:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80061b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800622:	85 c0                	test   %eax,%eax
  800624:	74 26                	je     80064c <vsnprintf+0x47>
  800626:	85 d2                	test   %edx,%edx
  800628:	7e 22                	jle    80064c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80062a:	ff 75 14             	pushl  0x14(%ebp)
  80062d:	ff 75 10             	pushl  0x10(%ebp)
  800630:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800633:	50                   	push   %eax
  800634:	68 6e 02 80 00       	push   $0x80026e
  800639:	e8 6a fc ff ff       	call   8002a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80063e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800641:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800644:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800647:	83 c4 10             	add    $0x10,%esp
}
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    
		return -E_INVAL;
  80064c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800651:	eb f7                	jmp    80064a <vsnprintf+0x45>

00800653 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
  800656:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800659:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80065c:	50                   	push   %eax
  80065d:	ff 75 10             	pushl  0x10(%ebp)
  800660:	ff 75 0c             	pushl  0xc(%ebp)
  800663:	ff 75 08             	pushl  0x8(%ebp)
  800666:	e8 9a ff ff ff       	call   800605 <vsnprintf>
	va_end(ap);

	return rc;
}
  80066b:	c9                   	leave  
  80066c:	c3                   	ret    

0080066d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800673:	b8 00 00 00 00       	mov    $0x0,%eax
  800678:	eb 03                	jmp    80067d <strlen+0x10>
		n++;
  80067a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80067d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800681:	75 f7                	jne    80067a <strlen+0xd>
	return n;
}
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    

00800685 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80068b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80068e:	b8 00 00 00 00       	mov    $0x0,%eax
  800693:	eb 03                	jmp    800698 <strnlen+0x13>
		n++;
  800695:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800698:	39 d0                	cmp    %edx,%eax
  80069a:	74 06                	je     8006a2 <strnlen+0x1d>
  80069c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006a0:	75 f3                	jne    800695 <strnlen+0x10>
	return n;
}
  8006a2:	5d                   	pop    %ebp
  8006a3:	c3                   	ret    

008006a4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	53                   	push   %ebx
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ae:	89 c2                	mov    %eax,%edx
  8006b0:	83 c1 01             	add    $0x1,%ecx
  8006b3:	83 c2 01             	add    $0x1,%edx
  8006b6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006ba:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006bd:	84 db                	test   %bl,%bl
  8006bf:	75 ef                	jne    8006b0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006c1:	5b                   	pop    %ebx
  8006c2:	5d                   	pop    %ebp
  8006c3:	c3                   	ret    

008006c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	53                   	push   %ebx
  8006c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006cb:	53                   	push   %ebx
  8006cc:	e8 9c ff ff ff       	call   80066d <strlen>
  8006d1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006d4:	ff 75 0c             	pushl  0xc(%ebp)
  8006d7:	01 d8                	add    %ebx,%eax
  8006d9:	50                   	push   %eax
  8006da:	e8 c5 ff ff ff       	call   8006a4 <strcpy>
	return dst;
}
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	56                   	push   %esi
  8006ea:	53                   	push   %ebx
  8006eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006f1:	89 f3                	mov    %esi,%ebx
  8006f3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006f6:	89 f2                	mov    %esi,%edx
  8006f8:	eb 0f                	jmp    800709 <strncpy+0x23>
		*dst++ = *src;
  8006fa:	83 c2 01             	add    $0x1,%edx
  8006fd:	0f b6 01             	movzbl (%ecx),%eax
  800700:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800703:	80 39 01             	cmpb   $0x1,(%ecx)
  800706:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800709:	39 da                	cmp    %ebx,%edx
  80070b:	75 ed                	jne    8006fa <strncpy+0x14>
	}
	return ret;
}
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	5b                   	pop    %ebx
  800710:	5e                   	pop    %esi
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	56                   	push   %esi
  800717:	53                   	push   %ebx
  800718:	8b 75 08             	mov    0x8(%ebp),%esi
  80071b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80071e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800721:	89 f0                	mov    %esi,%eax
  800723:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800727:	85 c9                	test   %ecx,%ecx
  800729:	75 0b                	jne    800736 <strlcpy+0x23>
  80072b:	eb 17                	jmp    800744 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80072d:	83 c2 01             	add    $0x1,%edx
  800730:	83 c0 01             	add    $0x1,%eax
  800733:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800736:	39 d8                	cmp    %ebx,%eax
  800738:	74 07                	je     800741 <strlcpy+0x2e>
  80073a:	0f b6 0a             	movzbl (%edx),%ecx
  80073d:	84 c9                	test   %cl,%cl
  80073f:	75 ec                	jne    80072d <strlcpy+0x1a>
		*dst = '\0';
  800741:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800744:	29 f0                	sub    %esi,%eax
}
  800746:	5b                   	pop    %ebx
  800747:	5e                   	pop    %esi
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    

0080074a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800750:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800753:	eb 06                	jmp    80075b <strcmp+0x11>
		p++, q++;
  800755:	83 c1 01             	add    $0x1,%ecx
  800758:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80075b:	0f b6 01             	movzbl (%ecx),%eax
  80075e:	84 c0                	test   %al,%al
  800760:	74 04                	je     800766 <strcmp+0x1c>
  800762:	3a 02                	cmp    (%edx),%al
  800764:	74 ef                	je     800755 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800766:	0f b6 c0             	movzbl %al,%eax
  800769:	0f b6 12             	movzbl (%edx),%edx
  80076c:	29 d0                	sub    %edx,%eax
}
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077a:	89 c3                	mov    %eax,%ebx
  80077c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80077f:	eb 06                	jmp    800787 <strncmp+0x17>
		n--, p++, q++;
  800781:	83 c0 01             	add    $0x1,%eax
  800784:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800787:	39 d8                	cmp    %ebx,%eax
  800789:	74 16                	je     8007a1 <strncmp+0x31>
  80078b:	0f b6 08             	movzbl (%eax),%ecx
  80078e:	84 c9                	test   %cl,%cl
  800790:	74 04                	je     800796 <strncmp+0x26>
  800792:	3a 0a                	cmp    (%edx),%cl
  800794:	74 eb                	je     800781 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800796:	0f b6 00             	movzbl (%eax),%eax
  800799:	0f b6 12             	movzbl (%edx),%edx
  80079c:	29 d0                	sub    %edx,%eax
}
  80079e:	5b                   	pop    %ebx
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    
		return 0;
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	eb f6                	jmp    80079e <strncmp+0x2e>

008007a8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007b2:	0f b6 10             	movzbl (%eax),%edx
  8007b5:	84 d2                	test   %dl,%dl
  8007b7:	74 09                	je     8007c2 <strchr+0x1a>
		if (*s == c)
  8007b9:	38 ca                	cmp    %cl,%dl
  8007bb:	74 0a                	je     8007c7 <strchr+0x1f>
	for (; *s; s++)
  8007bd:	83 c0 01             	add    $0x1,%eax
  8007c0:	eb f0                	jmp    8007b2 <strchr+0xa>
			return (char *) s;
	return 0;
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007d3:	eb 03                	jmp    8007d8 <strfind+0xf>
  8007d5:	83 c0 01             	add    $0x1,%eax
  8007d8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007db:	38 ca                	cmp    %cl,%dl
  8007dd:	74 04                	je     8007e3 <strfind+0x1a>
  8007df:	84 d2                	test   %dl,%dl
  8007e1:	75 f2                	jne    8007d5 <strfind+0xc>
			break;
	return (char *) s;
}
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	57                   	push   %edi
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8007f1:	85 c9                	test   %ecx,%ecx
  8007f3:	74 12                	je     800807 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007f5:	f6 c2 03             	test   $0x3,%dl
  8007f8:	75 05                	jne    8007ff <memset+0x1a>
  8007fa:	f6 c1 03             	test   $0x3,%cl
  8007fd:	74 0f                	je     80080e <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007ff:	89 d7                	mov    %edx,%edi
  800801:	8b 45 0c             	mov    0xc(%ebp),%eax
  800804:	fc                   	cld    
  800805:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800807:	89 d0                	mov    %edx,%eax
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5f                   	pop    %edi
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    
		c &= 0xFF;
  80080e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800812:	89 d8                	mov    %ebx,%eax
  800814:	c1 e0 08             	shl    $0x8,%eax
  800817:	89 df                	mov    %ebx,%edi
  800819:	c1 e7 18             	shl    $0x18,%edi
  80081c:	89 de                	mov    %ebx,%esi
  80081e:	c1 e6 10             	shl    $0x10,%esi
  800821:	09 f7                	or     %esi,%edi
  800823:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800825:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800828:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80082a:	89 d7                	mov    %edx,%edi
  80082c:	fc                   	cld    
  80082d:	f3 ab                	rep stos %eax,%es:(%edi)
  80082f:	eb d6                	jmp    800807 <memset+0x22>

00800831 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	57                   	push   %edi
  800835:	56                   	push   %esi
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	8b 75 0c             	mov    0xc(%ebp),%esi
  80083c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80083f:	39 c6                	cmp    %eax,%esi
  800841:	73 35                	jae    800878 <memmove+0x47>
  800843:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800846:	39 c2                	cmp    %eax,%edx
  800848:	76 2e                	jbe    800878 <memmove+0x47>
		s += n;
		d += n;
  80084a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80084d:	89 d6                	mov    %edx,%esi
  80084f:	09 fe                	or     %edi,%esi
  800851:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800857:	74 0c                	je     800865 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800859:	83 ef 01             	sub    $0x1,%edi
  80085c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80085f:	fd                   	std    
  800860:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800862:	fc                   	cld    
  800863:	eb 21                	jmp    800886 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800865:	f6 c1 03             	test   $0x3,%cl
  800868:	75 ef                	jne    800859 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80086a:	83 ef 04             	sub    $0x4,%edi
  80086d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800870:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800873:	fd                   	std    
  800874:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800876:	eb ea                	jmp    800862 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800878:	89 f2                	mov    %esi,%edx
  80087a:	09 c2                	or     %eax,%edx
  80087c:	f6 c2 03             	test   $0x3,%dl
  80087f:	74 09                	je     80088a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800881:	89 c7                	mov    %eax,%edi
  800883:	fc                   	cld    
  800884:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80088a:	f6 c1 03             	test   $0x3,%cl
  80088d:	75 f2                	jne    800881 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80088f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800892:	89 c7                	mov    %eax,%edi
  800894:	fc                   	cld    
  800895:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800897:	eb ed                	jmp    800886 <memmove+0x55>

00800899 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80089c:	ff 75 10             	pushl  0x10(%ebp)
  80089f:	ff 75 0c             	pushl  0xc(%ebp)
  8008a2:	ff 75 08             	pushl  0x8(%ebp)
  8008a5:	e8 87 ff ff ff       	call   800831 <memmove>
}
  8008aa:	c9                   	leave  
  8008ab:	c3                   	ret    

008008ac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	56                   	push   %esi
  8008b0:	53                   	push   %ebx
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b7:	89 c6                	mov    %eax,%esi
  8008b9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008bc:	39 f0                	cmp    %esi,%eax
  8008be:	74 1c                	je     8008dc <memcmp+0x30>
		if (*s1 != *s2)
  8008c0:	0f b6 08             	movzbl (%eax),%ecx
  8008c3:	0f b6 1a             	movzbl (%edx),%ebx
  8008c6:	38 d9                	cmp    %bl,%cl
  8008c8:	75 08                	jne    8008d2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008ca:	83 c0 01             	add    $0x1,%eax
  8008cd:	83 c2 01             	add    $0x1,%edx
  8008d0:	eb ea                	jmp    8008bc <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8008d2:	0f b6 c1             	movzbl %cl,%eax
  8008d5:	0f b6 db             	movzbl %bl,%ebx
  8008d8:	29 d8                	sub    %ebx,%eax
  8008da:	eb 05                	jmp    8008e1 <memcmp+0x35>
	}

	return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008ee:	89 c2                	mov    %eax,%edx
  8008f0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008f3:	39 d0                	cmp    %edx,%eax
  8008f5:	73 09                	jae    800900 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008f7:	38 08                	cmp    %cl,(%eax)
  8008f9:	74 05                	je     800900 <memfind+0x1b>
	for (; s < ends; s++)
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	eb f3                	jmp    8008f3 <memfind+0xe>
			break;
	return (void *) s;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80090e:	eb 03                	jmp    800913 <strtol+0x11>
		s++;
  800910:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800913:	0f b6 01             	movzbl (%ecx),%eax
  800916:	3c 20                	cmp    $0x20,%al
  800918:	74 f6                	je     800910 <strtol+0xe>
  80091a:	3c 09                	cmp    $0x9,%al
  80091c:	74 f2                	je     800910 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80091e:	3c 2b                	cmp    $0x2b,%al
  800920:	74 2e                	je     800950 <strtol+0x4e>
	int neg = 0;
  800922:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800927:	3c 2d                	cmp    $0x2d,%al
  800929:	74 2f                	je     80095a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80092b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800931:	75 05                	jne    800938 <strtol+0x36>
  800933:	80 39 30             	cmpb   $0x30,(%ecx)
  800936:	74 2c                	je     800964 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800938:	85 db                	test   %ebx,%ebx
  80093a:	75 0a                	jne    800946 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80093c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800941:	80 39 30             	cmpb   $0x30,(%ecx)
  800944:	74 28                	je     80096e <strtol+0x6c>
		base = 10;
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80094e:	eb 50                	jmp    8009a0 <strtol+0x9e>
		s++;
  800950:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800953:	bf 00 00 00 00       	mov    $0x0,%edi
  800958:	eb d1                	jmp    80092b <strtol+0x29>
		s++, neg = 1;
  80095a:	83 c1 01             	add    $0x1,%ecx
  80095d:	bf 01 00 00 00       	mov    $0x1,%edi
  800962:	eb c7                	jmp    80092b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800964:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800968:	74 0e                	je     800978 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80096a:	85 db                	test   %ebx,%ebx
  80096c:	75 d8                	jne    800946 <strtol+0x44>
		s++, base = 8;
  80096e:	83 c1 01             	add    $0x1,%ecx
  800971:	bb 08 00 00 00       	mov    $0x8,%ebx
  800976:	eb ce                	jmp    800946 <strtol+0x44>
		s += 2, base = 16;
  800978:	83 c1 02             	add    $0x2,%ecx
  80097b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800980:	eb c4                	jmp    800946 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800982:	8d 72 9f             	lea    -0x61(%edx),%esi
  800985:	89 f3                	mov    %esi,%ebx
  800987:	80 fb 19             	cmp    $0x19,%bl
  80098a:	77 29                	ja     8009b5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80098c:	0f be d2             	movsbl %dl,%edx
  80098f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800992:	3b 55 10             	cmp    0x10(%ebp),%edx
  800995:	7d 30                	jge    8009c7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800997:	83 c1 01             	add    $0x1,%ecx
  80099a:	0f af 45 10          	imul   0x10(%ebp),%eax
  80099e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009a0:	0f b6 11             	movzbl (%ecx),%edx
  8009a3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009a6:	89 f3                	mov    %esi,%ebx
  8009a8:	80 fb 09             	cmp    $0x9,%bl
  8009ab:	77 d5                	ja     800982 <strtol+0x80>
			dig = *s - '0';
  8009ad:	0f be d2             	movsbl %dl,%edx
  8009b0:	83 ea 30             	sub    $0x30,%edx
  8009b3:	eb dd                	jmp    800992 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  8009b5:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009b8:	89 f3                	mov    %esi,%ebx
  8009ba:	80 fb 19             	cmp    $0x19,%bl
  8009bd:	77 08                	ja     8009c7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009bf:	0f be d2             	movsbl %dl,%edx
  8009c2:	83 ea 37             	sub    $0x37,%edx
  8009c5:	eb cb                	jmp    800992 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009cb:	74 05                	je     8009d2 <strtol+0xd0>
		*endptr = (char *) s;
  8009cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8009d2:	89 c2                	mov    %eax,%edx
  8009d4:	f7 da                	neg    %edx
  8009d6:	85 ff                	test   %edi,%edi
  8009d8:	0f 45 c2             	cmovne %edx,%eax
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5f                   	pop    %edi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	83 ec 1c             	sub    $0x1c,%esp
  8009e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009ef:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009fa:	8b 75 14             	mov    0x14(%ebp),%esi
  8009fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8009ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a03:	74 04                	je     800a09 <syscall+0x29>
  800a05:	85 c0                	test   %eax,%eax
  800a07:	7f 08                	jg     800a11 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a0c:	5b                   	pop    %ebx
  800a0d:	5e                   	pop    %esi
  800a0e:	5f                   	pop    %edi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    
  800a11:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	50                   	push   %eax
  800a18:	52                   	push   %edx
  800a19:	68 04 11 80 00       	push   $0x801104
  800a1e:	6a 23                	push   $0x23
  800a20:	68 21 11 80 00       	push   $0x801121
  800a25:	e8 b1 01 00 00       	call   800bdb <_panic>

00800a2a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800a30:	6a 00                	push   $0x0
  800a32:	6a 00                	push   $0x0
  800a34:	6a 00                	push   $0x0
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
  800a46:	e8 95 ff ff ff       	call   8009e0 <syscall>
}
  800a4b:	83 c4 10             	add    $0x10,%esp
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a56:	6a 00                	push   $0x0
  800a58:	6a 00                	push   $0x0
  800a5a:	6a 00                	push   $0x0
  800a5c:	6a 00                	push   $0x0
  800a5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6d:	e8 6e ff ff ff       	call   8009e0 <syscall>
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800a7a:	6a 00                	push   $0x0
  800a7c:	6a 00                	push   $0x0
  800a7e:	6a 00                	push   $0x0
  800a80:	6a 00                	push   $0x0
  800a82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a85:	ba 01 00 00 00       	mov    $0x1,%edx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	e8 4c ff ff ff       	call   8009e0 <syscall>
}
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800a9c:	6a 00                	push   $0x0
  800a9e:	6a 00                	push   $0x0
  800aa0:	6a 00                	push   $0x0
  800aa2:	6a 00                	push   $0x0
  800aa4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	b8 02 00 00 00       	mov    $0x2,%eax
  800ab3:	e8 28 ff ff ff       	call   8009e0 <syscall>
}
  800ab8:	c9                   	leave  
  800ab9:	c3                   	ret    

00800aba <sys_yield>:

void
sys_yield(void)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ac0:	6a 00                	push   $0x0
  800ac2:	6a 00                	push   $0x0
  800ac4:	6a 00                	push   $0x0
  800ac6:	6a 00                	push   $0x0
  800ac8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ad7:	e8 04 ff ff ff       	call   8009e0 <syscall>
}
  800adc:	83 c4 10             	add    $0x10,%esp
  800adf:	c9                   	leave  
  800ae0:	c3                   	ret    

00800ae1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ae7:	6a 00                	push   $0x0
  800ae9:	6a 00                	push   $0x0
  800aeb:	ff 75 10             	pushl  0x10(%ebp)
  800aee:	ff 75 0c             	pushl  0xc(%ebp)
  800af1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af4:	ba 01 00 00 00       	mov    $0x1,%edx
  800af9:	b8 04 00 00 00       	mov    $0x4,%eax
  800afe:	e8 dd fe ff ff       	call   8009e0 <syscall>
}
  800b03:	c9                   	leave  
  800b04:	c3                   	ret    

00800b05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b0b:	ff 75 18             	pushl  0x18(%ebp)
  800b0e:	ff 75 14             	pushl  0x14(%ebp)
  800b11:	ff 75 10             	pushl  0x10(%ebp)
  800b14:	ff 75 0c             	pushl  0xc(%ebp)
  800b17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1a:	ba 01 00 00 00       	mov    $0x1,%edx
  800b1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b24:	e8 b7 fe ff ff       	call   8009e0 <syscall>
}
  800b29:	c9                   	leave  
  800b2a:	c3                   	ret    

00800b2b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b31:	6a 00                	push   $0x0
  800b33:	6a 00                	push   $0x0
  800b35:	6a 00                	push   $0x0
  800b37:	ff 75 0c             	pushl  0xc(%ebp)
  800b3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3d:	ba 01 00 00 00       	mov    $0x1,%edx
  800b42:	b8 06 00 00 00       	mov    $0x6,%eax
  800b47:	e8 94 fe ff ff       	call   8009e0 <syscall>
}
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b54:	6a 00                	push   $0x0
  800b56:	6a 00                	push   $0x0
  800b58:	6a 00                	push   $0x0
  800b5a:	ff 75 0c             	pushl  0xc(%ebp)
  800b5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b60:	ba 01 00 00 00       	mov    $0x1,%edx
  800b65:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6a:	e8 71 fe ff ff       	call   8009e0 <syscall>
}
  800b6f:	c9                   	leave  
  800b70:	c3                   	ret    

00800b71 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800b77:	6a 00                	push   $0x0
  800b79:	6a 00                	push   $0x0
  800b7b:	6a 00                	push   $0x0
  800b7d:	ff 75 0c             	pushl  0xc(%ebp)
  800b80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b83:	ba 01 00 00 00       	mov    $0x1,%edx
  800b88:	b8 09 00 00 00       	mov    $0x9,%eax
  800b8d:	e8 4e fe ff ff       	call   8009e0 <syscall>
}
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    

00800b94 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800b9a:	6a 00                	push   $0x0
  800b9c:	ff 75 14             	pushl  0x14(%ebp)
  800b9f:	ff 75 10             	pushl  0x10(%ebp)
  800ba2:	ff 75 0c             	pushl  0xc(%ebp)
  800ba5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb2:	e8 29 fe ff ff       	call   8009e0 <syscall>
}
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800bbf:	6a 00                	push   $0x0
  800bc1:	6a 00                	push   $0x0
  800bc3:	6a 00                	push   $0x0
  800bc5:	6a 00                	push   $0x0
  800bc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bca:	ba 01 00 00 00       	mov    $0x1,%edx
  800bcf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bd4:	e8 07 fe ff ff       	call   8009e0 <syscall>
}
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800be0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800be3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800be9:	e8 a8 fe ff ff       	call   800a96 <sys_getenvid>
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	ff 75 0c             	pushl  0xc(%ebp)
  800bf4:	ff 75 08             	pushl  0x8(%ebp)
  800bf7:	56                   	push   %esi
  800bf8:	50                   	push   %eax
  800bf9:	68 30 11 80 00       	push   $0x801130
  800bfe:	e8 3c f5 ff ff       	call   80013f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c03:	83 c4 18             	add    $0x18,%esp
  800c06:	53                   	push   %ebx
  800c07:	ff 75 10             	pushl  0x10(%ebp)
  800c0a:	e8 df f4 ff ff       	call   8000ee <vcprintf>
	cprintf("\n");
  800c0f:	c7 04 24 54 11 80 00 	movl   $0x801154,(%esp)
  800c16:	e8 24 f5 ff ff       	call   80013f <cprintf>
  800c1b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c1e:	cc                   	int3   
  800c1f:	eb fd                	jmp    800c1e <_panic+0x43>
  800c21:	66 90                	xchg   %ax,%ax
  800c23:	66 90                	xchg   %ax,%ax
  800c25:	66 90                	xchg   %ax,%ax
  800c27:	66 90                	xchg   %ax,%ax
  800c29:	66 90                	xchg   %ax,%ax
  800c2b:	66 90                	xchg   %ax,%ax
  800c2d:	66 90                	xchg   %ax,%ax
  800c2f:	90                   	nop

00800c30 <__udivdi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 1c             	sub    $0x1c,%esp
  800c37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c47:	85 d2                	test   %edx,%edx
  800c49:	75 35                	jne    800c80 <__udivdi3+0x50>
  800c4b:	39 f3                	cmp    %esi,%ebx
  800c4d:	0f 87 bd 00 00 00    	ja     800d10 <__udivdi3+0xe0>
  800c53:	85 db                	test   %ebx,%ebx
  800c55:	89 d9                	mov    %ebx,%ecx
  800c57:	75 0b                	jne    800c64 <__udivdi3+0x34>
  800c59:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5e:	31 d2                	xor    %edx,%edx
  800c60:	f7 f3                	div    %ebx
  800c62:	89 c1                	mov    %eax,%ecx
  800c64:	31 d2                	xor    %edx,%edx
  800c66:	89 f0                	mov    %esi,%eax
  800c68:	f7 f1                	div    %ecx
  800c6a:	89 c6                	mov    %eax,%esi
  800c6c:	89 e8                	mov    %ebp,%eax
  800c6e:	89 f7                	mov    %esi,%edi
  800c70:	f7 f1                	div    %ecx
  800c72:	89 fa                	mov    %edi,%edx
  800c74:	83 c4 1c             	add    $0x1c,%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    
  800c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c80:	39 f2                	cmp    %esi,%edx
  800c82:	77 7c                	ja     800d00 <__udivdi3+0xd0>
  800c84:	0f bd fa             	bsr    %edx,%edi
  800c87:	83 f7 1f             	xor    $0x1f,%edi
  800c8a:	0f 84 98 00 00 00    	je     800d28 <__udivdi3+0xf8>
  800c90:	89 f9                	mov    %edi,%ecx
  800c92:	b8 20 00 00 00       	mov    $0x20,%eax
  800c97:	29 f8                	sub    %edi,%eax
  800c99:	d3 e2                	shl    %cl,%edx
  800c9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c9f:	89 c1                	mov    %eax,%ecx
  800ca1:	89 da                	mov    %ebx,%edx
  800ca3:	d3 ea                	shr    %cl,%edx
  800ca5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ca9:	09 d1                	or     %edx,%ecx
  800cab:	89 f2                	mov    %esi,%edx
  800cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb1:	89 f9                	mov    %edi,%ecx
  800cb3:	d3 e3                	shl    %cl,%ebx
  800cb5:	89 c1                	mov    %eax,%ecx
  800cb7:	d3 ea                	shr    %cl,%edx
  800cb9:	89 f9                	mov    %edi,%ecx
  800cbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cbf:	d3 e6                	shl    %cl,%esi
  800cc1:	89 eb                	mov    %ebp,%ebx
  800cc3:	89 c1                	mov    %eax,%ecx
  800cc5:	d3 eb                	shr    %cl,%ebx
  800cc7:	09 de                	or     %ebx,%esi
  800cc9:	89 f0                	mov    %esi,%eax
  800ccb:	f7 74 24 08          	divl   0x8(%esp)
  800ccf:	89 d6                	mov    %edx,%esi
  800cd1:	89 c3                	mov    %eax,%ebx
  800cd3:	f7 64 24 0c          	mull   0xc(%esp)
  800cd7:	39 d6                	cmp    %edx,%esi
  800cd9:	72 0c                	jb     800ce7 <__udivdi3+0xb7>
  800cdb:	89 f9                	mov    %edi,%ecx
  800cdd:	d3 e5                	shl    %cl,%ebp
  800cdf:	39 c5                	cmp    %eax,%ebp
  800ce1:	73 5d                	jae    800d40 <__udivdi3+0x110>
  800ce3:	39 d6                	cmp    %edx,%esi
  800ce5:	75 59                	jne    800d40 <__udivdi3+0x110>
  800ce7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cea:	31 ff                	xor    %edi,%edi
  800cec:	89 fa                	mov    %edi,%edx
  800cee:	83 c4 1c             	add    $0x1c,%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
  800cf6:	8d 76 00             	lea    0x0(%esi),%esi
  800cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d00:	31 ff                	xor    %edi,%edi
  800d02:	31 c0                	xor    %eax,%eax
  800d04:	89 fa                	mov    %edi,%edx
  800d06:	83 c4 1c             	add    $0x1c,%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    
  800d0e:	66 90                	xchg   %ax,%ax
  800d10:	31 ff                	xor    %edi,%edi
  800d12:	89 e8                	mov    %ebp,%eax
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	f7 f3                	div    %ebx
  800d18:	89 fa                	mov    %edi,%edx
  800d1a:	83 c4 1c             	add    $0x1c,%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
  800d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d28:	39 f2                	cmp    %esi,%edx
  800d2a:	72 06                	jb     800d32 <__udivdi3+0x102>
  800d2c:	31 c0                	xor    %eax,%eax
  800d2e:	39 eb                	cmp    %ebp,%ebx
  800d30:	77 d2                	ja     800d04 <__udivdi3+0xd4>
  800d32:	b8 01 00 00 00       	mov    $0x1,%eax
  800d37:	eb cb                	jmp    800d04 <__udivdi3+0xd4>
  800d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d40:	89 d8                	mov    %ebx,%eax
  800d42:	31 ff                	xor    %edi,%edi
  800d44:	eb be                	jmp    800d04 <__udivdi3+0xd4>
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__umoddi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
  800d57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d67:	85 ed                	test   %ebp,%ebp
  800d69:	89 f0                	mov    %esi,%eax
  800d6b:	89 da                	mov    %ebx,%edx
  800d6d:	75 19                	jne    800d88 <__umoddi3+0x38>
  800d6f:	39 df                	cmp    %ebx,%edi
  800d71:	0f 86 b1 00 00 00    	jbe    800e28 <__umoddi3+0xd8>
  800d77:	f7 f7                	div    %edi
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	83 c4 1c             	add    $0x1c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
  800d88:	39 dd                	cmp    %ebx,%ebp
  800d8a:	77 f1                	ja     800d7d <__umoddi3+0x2d>
  800d8c:	0f bd cd             	bsr    %ebp,%ecx
  800d8f:	83 f1 1f             	xor    $0x1f,%ecx
  800d92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d96:	0f 84 b4 00 00 00    	je     800e50 <__umoddi3+0x100>
  800d9c:	b8 20 00 00 00       	mov    $0x20,%eax
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800da7:	29 c2                	sub    %eax,%edx
  800da9:	89 c1                	mov    %eax,%ecx
  800dab:	89 f8                	mov    %edi,%eax
  800dad:	d3 e5                	shl    %cl,%ebp
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800db5:	d3 e8                	shr    %cl,%eax
  800db7:	09 c5                	or     %eax,%ebp
  800db9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dbd:	89 c1                	mov    %eax,%ecx
  800dbf:	d3 e7                	shl    %cl,%edi
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	d3 ef                	shr    %cl,%edi
  800dcb:	89 c1                	mov    %eax,%ecx
  800dcd:	89 f0                	mov    %esi,%eax
  800dcf:	d3 e3                	shl    %cl,%ebx
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 fa                	mov    %edi,%edx
  800dd5:	d3 e8                	shr    %cl,%eax
  800dd7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ddc:	09 d8                	or     %ebx,%eax
  800dde:	f7 f5                	div    %ebp
  800de0:	d3 e6                	shl    %cl,%esi
  800de2:	89 d1                	mov    %edx,%ecx
  800de4:	f7 64 24 08          	mull   0x8(%esp)
  800de8:	39 d1                	cmp    %edx,%ecx
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	72 06                	jb     800df6 <__umoddi3+0xa6>
  800df0:	75 0e                	jne    800e00 <__umoddi3+0xb0>
  800df2:	39 c6                	cmp    %eax,%esi
  800df4:	73 0a                	jae    800e00 <__umoddi3+0xb0>
  800df6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dfa:	19 ea                	sbb    %ebp,%edx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	89 c3                	mov    %eax,%ebx
  800e00:	89 ca                	mov    %ecx,%edx
  800e02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e07:	29 de                	sub    %ebx,%esi
  800e09:	19 fa                	sbb    %edi,%edx
  800e0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e0f:	89 d0                	mov    %edx,%eax
  800e11:	d3 e0                	shl    %cl,%eax
  800e13:	89 d9                	mov    %ebx,%ecx
  800e15:	d3 ee                	shr    %cl,%esi
  800e17:	d3 ea                	shr    %cl,%edx
  800e19:	09 f0                	or     %esi,%eax
  800e1b:	83 c4 1c             	add    $0x1c,%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    
  800e23:	90                   	nop
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	85 ff                	test   %edi,%edi
  800e2a:	89 f9                	mov    %edi,%ecx
  800e2c:	75 0b                	jne    800e39 <__umoddi3+0xe9>
  800e2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e33:	31 d2                	xor    %edx,%edx
  800e35:	f7 f7                	div    %edi
  800e37:	89 c1                	mov    %eax,%ecx
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	f7 f1                	div    %ecx
  800e3f:	89 f0                	mov    %esi,%eax
  800e41:	f7 f1                	div    %ecx
  800e43:	e9 31 ff ff ff       	jmp    800d79 <__umoddi3+0x29>
  800e48:	90                   	nop
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	39 dd                	cmp    %ebx,%ebp
  800e52:	72 08                	jb     800e5c <__umoddi3+0x10c>
  800e54:	39 f7                	cmp    %esi,%edi
  800e56:	0f 87 21 ff ff ff    	ja     800d7d <__umoddi3+0x2d>
  800e5c:	89 da                	mov    %ebx,%edx
  800e5e:	89 f0                	mov    %esi,%eax
  800e60:	29 f8                	sub    %edi,%eax
  800e62:	19 ea                	sbb    %ebp,%edx
  800e64:	e9 14 ff ff ff       	jmp    800d7d <__umoddi3+0x2d>
