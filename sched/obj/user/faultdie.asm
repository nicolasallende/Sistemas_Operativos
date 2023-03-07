
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 20 0f 80 00       	push   $0x800f20
  80004a:	e8 22 01 00 00       	call   800171 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 74 0a 00 00       	call   800ac8 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 4a 0a 00 00       	call   800aa6 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 9c 0b 00 00       	call   800c0d <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80008b:	e8 38 0a 00 00       	call   800ac8 <sys_getenvid>
	if (id >= 0)
  800090:	85 c0                	test   %eax,%eax
  800092:	78 12                	js     8000a6 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800094:	25 ff 03 00 00       	and    $0x3ff,%eax
  800099:	c1 e0 07             	shl    $0x7,%eax
  80009c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a1:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a6:	85 db                	test   %ebx,%ebx
  8000a8:	7e 07                	jle    8000b1 <libmain+0x31>
		binaryname = argv[0];
  8000aa:	8b 06                	mov    (%esi),%eax
  8000ac:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b1:	83 ec 08             	sub    $0x8,%esp
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
  8000b6:	e8 a6 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000bb:	e8 0a 00 00 00       	call   8000ca <exit>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c6:	5b                   	pop    %ebx
  8000c7:	5e                   	pop    %esi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d0:	6a 00                	push   $0x0
  8000d2:	e8 cf 09 00 00       	call   800aa6 <sys_env_destroy>
}
  8000d7:	83 c4 10             	add    $0x10,%esp
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	53                   	push   %ebx
  8000e0:	83 ec 04             	sub    $0x4,%esp
  8000e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e6:	8b 13                	mov    (%ebx),%edx
  8000e8:	8d 42 01             	lea    0x1(%edx),%eax
  8000eb:	89 03                	mov    %eax,(%ebx)
  8000ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f9:	74 09                	je     800104 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800102:	c9                   	leave  
  800103:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800104:	83 ec 08             	sub    $0x8,%esp
  800107:	68 ff 00 00 00       	push   $0xff
  80010c:	8d 43 08             	lea    0x8(%ebx),%eax
  80010f:	50                   	push   %eax
  800110:	e8 47 09 00 00       	call   800a5c <sys_cputs>
		b->idx = 0;
  800115:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	eb db                	jmp    8000fb <putch+0x1f>

00800120 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800129:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800130:	00 00 00 
	b.cnt = 0;
  800133:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013d:	ff 75 0c             	pushl  0xc(%ebp)
  800140:	ff 75 08             	pushl  0x8(%ebp)
  800143:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800149:	50                   	push   %eax
  80014a:	68 dc 00 80 00       	push   $0x8000dc
  80014f:	e8 86 01 00 00       	call   8002da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800154:	83 c4 08             	add    $0x8,%esp
  800157:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800163:	50                   	push   %eax
  800164:	e8 f3 08 00 00       	call   800a5c <sys_cputs>

	return b.cnt;
}
  800169:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800177:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017a:	50                   	push   %eax
  80017b:	ff 75 08             	pushl  0x8(%ebp)
  80017e:	e8 9d ff ff ff       	call   800120 <vcprintf>
	va_end(ap);

	return cnt;
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	83 ec 1c             	sub    $0x1c,%esp
  80018e:	89 c7                	mov    %eax,%edi
  800190:	89 d6                	mov    %edx,%esi
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	8b 55 0c             	mov    0xc(%ebp),%edx
  800198:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ac:	39 d3                	cmp    %edx,%ebx
  8001ae:	72 05                	jb     8001b5 <printnum+0x30>
  8001b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b3:	77 7a                	ja     80022f <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b5:	83 ec 0c             	sub    $0xc,%esp
  8001b8:	ff 75 18             	pushl  0x18(%ebp)
  8001bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c1:	53                   	push   %ebx
  8001c2:	ff 75 10             	pushl  0x10(%ebp)
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d4:	e8 f7 0a 00 00       	call   800cd0 <__udivdi3>
  8001d9:	83 c4 18             	add    $0x18,%esp
  8001dc:	52                   	push   %edx
  8001dd:	50                   	push   %eax
  8001de:	89 f2                	mov    %esi,%edx
  8001e0:	89 f8                	mov    %edi,%eax
  8001e2:	e8 9e ff ff ff       	call   800185 <printnum>
  8001e7:	83 c4 20             	add    $0x20,%esp
  8001ea:	eb 13                	jmp    8001ff <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	56                   	push   %esi
  8001f0:	ff 75 18             	pushl  0x18(%ebp)
  8001f3:	ff d7                	call   *%edi
  8001f5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f8:	83 eb 01             	sub    $0x1,%ebx
  8001fb:	85 db                	test   %ebx,%ebx
  8001fd:	7f ed                	jg     8001ec <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	56                   	push   %esi
  800203:	83 ec 04             	sub    $0x4,%esp
  800206:	ff 75 e4             	pushl  -0x1c(%ebp)
  800209:	ff 75 e0             	pushl  -0x20(%ebp)
  80020c:	ff 75 dc             	pushl  -0x24(%ebp)
  80020f:	ff 75 d8             	pushl  -0x28(%ebp)
  800212:	e8 d9 0b 00 00       	call   800df0 <__umoddi3>
  800217:	83 c4 14             	add    $0x14,%esp
  80021a:	0f be 80 46 0f 80 00 	movsbl 0x800f46(%eax),%eax
  800221:	50                   	push   %eax
  800222:	ff d7                	call   *%edi
}
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    
  80022f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800232:	eb c4                	jmp    8001f8 <printnum+0x73>

00800234 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800237:	83 fa 01             	cmp    $0x1,%edx
  80023a:	7e 0e                	jle    80024a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023c:	8b 10                	mov    (%eax),%edx
  80023e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800241:	89 08                	mov    %ecx,(%eax)
  800243:	8b 02                	mov    (%edx),%eax
  800245:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    
	else if (lflag)
  80024a:	85 d2                	test   %edx,%edx
  80024c:	75 10                	jne    80025e <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  80024e:	8b 10                	mov    (%eax),%edx
  800250:	8d 4a 04             	lea    0x4(%edx),%ecx
  800253:	89 08                	mov    %ecx,(%eax)
  800255:	8b 02                	mov    (%edx),%eax
  800257:	ba 00 00 00 00       	mov    $0x0,%edx
  80025c:	eb ea                	jmp    800248 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	8d 4a 04             	lea    0x4(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 02                	mov    (%edx),%eax
  800267:	ba 00 00 00 00       	mov    $0x0,%edx
  80026c:	eb da                	jmp    800248 <getuint+0x14>

0080026e <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800271:	83 fa 01             	cmp    $0x1,%edx
  800274:	7e 0e                	jle    800284 <getint+0x16>
		return va_arg(*ap, long long);
  800276:	8b 10                	mov    (%eax),%edx
  800278:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027b:	89 08                	mov    %ecx,(%eax)
  80027d:	8b 02                	mov    (%edx),%eax
  80027f:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    
	else if (lflag)
  800284:	85 d2                	test   %edx,%edx
  800286:	75 0c                	jne    800294 <getint+0x26>
		return va_arg(*ap, int);
  800288:	8b 10                	mov    (%eax),%edx
  80028a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028d:	89 08                	mov    %ecx,(%eax)
  80028f:	8b 02                	mov    (%edx),%eax
  800291:	99                   	cltd   
  800292:	eb ee                	jmp    800282 <getint+0x14>
		return va_arg(*ap, long);
  800294:	8b 10                	mov    (%eax),%edx
  800296:	8d 4a 04             	lea    0x4(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 02                	mov    (%edx),%eax
  80029d:	99                   	cltd   
  80029e:	eb e2                	jmp    800282 <getint+0x14>

008002a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002aa:	8b 10                	mov    (%eax),%edx
  8002ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8002af:	73 0a                	jae    8002bb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b9:	88 02                	mov    %al,(%edx)
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <printfmt>:
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002c3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c6:	50                   	push   %eax
  8002c7:	ff 75 10             	pushl  0x10(%ebp)
  8002ca:	ff 75 0c             	pushl  0xc(%ebp)
  8002cd:	ff 75 08             	pushl  0x8(%ebp)
  8002d0:	e8 05 00 00 00       	call   8002da <vprintfmt>
}
  8002d5:	83 c4 10             	add    $0x10,%esp
  8002d8:	c9                   	leave  
  8002d9:	c3                   	ret    

008002da <vprintfmt>:
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 2c             	sub    $0x2c,%esp
  8002e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002e9:	89 f7                	mov    %esi,%edi
  8002eb:	89 de                	mov    %ebx,%esi
  8002ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f0:	e9 9e 02 00 00       	jmp    800593 <vprintfmt+0x2b9>
		padc = ' ';
  8002f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800300:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800307:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80030e:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800313:	8d 43 01             	lea    0x1(%ebx),%eax
  800316:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800319:	0f b6 0b             	movzbl (%ebx),%ecx
  80031c:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80031f:	3c 55                	cmp    $0x55,%al
  800321:	0f 87 e8 02 00 00    	ja     80060f <vprintfmt+0x335>
  800327:	0f b6 c0             	movzbl %al,%eax
  80032a:	ff 24 85 00 10 80 00 	jmp    *0x801000(,%eax,4)
  800331:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800334:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800338:	eb d9                	jmp    800313 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  80033d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800341:	eb d0                	jmp    800313 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800343:	0f b6 c9             	movzbl %cl,%ecx
  800346:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800349:	b8 00 00 00 00       	mov    $0x0,%eax
  80034e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800351:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800354:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800358:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80035b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035e:	83 fa 09             	cmp    $0x9,%edx
  800361:	77 52                	ja     8003b5 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800363:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800366:	eb e9                	jmp    800351 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8d 48 04             	lea    0x4(%eax),%ecx
  80036e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800371:	8b 00                	mov    (%eax),%eax
  800373:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800379:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037d:	79 94                	jns    800313 <vprintfmt+0x39>
				width = precision, precision = -1;
  80037f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800382:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800385:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038c:	eb 85                	jmp    800313 <vprintfmt+0x39>
  80038e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800391:	85 c0                	test   %eax,%eax
  800393:	b9 00 00 00 00       	mov    $0x0,%ecx
  800398:	0f 49 c8             	cmovns %eax,%ecx
  80039b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003a1:	e9 6d ff ff ff       	jmp    800313 <vprintfmt+0x39>
  8003a6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003a9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b0:	e9 5e ff ff ff       	jmp    800313 <vprintfmt+0x39>
  8003b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003bb:	eb bc                	jmp    800379 <vprintfmt+0x9f>
			lflag++;
  8003bd:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003c3:	e9 4b ff ff ff       	jmp    800313 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d1:	83 ec 08             	sub    $0x8,%esp
  8003d4:	57                   	push   %edi
  8003d5:	ff 30                	pushl  (%eax)
  8003d7:	ff d6                	call   *%esi
			break;
  8003d9:	83 c4 10             	add    $0x10,%esp
  8003dc:	e9 af 01 00 00       	jmp    800590 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 50 04             	lea    0x4(%eax),%edx
  8003e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	99                   	cltd   
  8003ed:	31 d0                	xor    %edx,%eax
  8003ef:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f1:	83 f8 08             	cmp    $0x8,%eax
  8003f4:	7f 20                	jg     800416 <vprintfmt+0x13c>
  8003f6:	8b 14 85 60 11 80 00 	mov    0x801160(,%eax,4),%edx
  8003fd:	85 d2                	test   %edx,%edx
  8003ff:	74 15                	je     800416 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800401:	52                   	push   %edx
  800402:	68 67 0f 80 00       	push   $0x800f67
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	e8 af fe ff ff       	call   8002bd <printfmt>
  80040e:	83 c4 10             	add    $0x10,%esp
  800411:	e9 7a 01 00 00       	jmp    800590 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800416:	50                   	push   %eax
  800417:	68 5e 0f 80 00       	push   $0x800f5e
  80041c:	57                   	push   %edi
  80041d:	56                   	push   %esi
  80041e:	e8 9a fe ff ff       	call   8002bd <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	e9 65 01 00 00       	jmp    800590 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800436:	85 db                	test   %ebx,%ebx
  800438:	b8 57 0f 80 00       	mov    $0x800f57,%eax
  80043d:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  800440:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800444:	0f 8e bd 00 00 00    	jle    800507 <vprintfmt+0x22d>
  80044a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044e:	75 0e                	jne    80045e <vprintfmt+0x184>
  800450:	89 75 08             	mov    %esi,0x8(%ebp)
  800453:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800456:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800459:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80045c:	eb 6d                	jmp    8004cb <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	ff 75 d0             	pushl  -0x30(%ebp)
  800464:	53                   	push   %ebx
  800465:	e8 4d 02 00 00       	call   8006b7 <strnlen>
  80046a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800475:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80047f:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	eb 0f                	jmp    800492 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	57                   	push   %edi
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	83 eb 01             	sub    $0x1,%ebx
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 db                	test   %ebx,%ebx
  800494:	7f ed                	jg     800483 <vprintfmt+0x1a9>
  800496:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800499:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049c:	85 c9                	test   %ecx,%ecx
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	0f 49 c1             	cmovns %ecx,%eax
  8004a6:	29 c1                	sub    %eax,%ecx
  8004a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ae:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004b1:	89 cf                	mov    %ecx,%edi
  8004b3:	eb 16                	jmp    8004cb <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b9:	75 31                	jne    8004ec <vprintfmt+0x212>
					putch(ch, putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	ff 75 0c             	pushl  0xc(%ebp)
  8004c1:	50                   	push   %eax
  8004c2:	ff 55 08             	call   *0x8(%ebp)
  8004c5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c8:	83 ef 01             	sub    $0x1,%edi
  8004cb:	83 c3 01             	add    $0x1,%ebx
  8004ce:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8004d2:	0f be c2             	movsbl %dl,%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 50                	je     800529 <vprintfmt+0x24f>
  8004d9:	85 f6                	test   %esi,%esi
  8004db:	78 d8                	js     8004b5 <vprintfmt+0x1db>
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	79 d3                	jns    8004b5 <vprintfmt+0x1db>
  8004e2:	89 fb                	mov    %edi,%ebx
  8004e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004ea:	eb 37                	jmp    800523 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	0f be d2             	movsbl %dl,%edx
  8004ef:	83 ea 20             	sub    $0x20,%edx
  8004f2:	83 fa 5e             	cmp    $0x5e,%edx
  8004f5:	76 c4                	jbe    8004bb <vprintfmt+0x1e1>
					putch('?', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	6a 3f                	push   $0x3f
  8004ff:	ff 55 08             	call   *0x8(%ebp)
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	eb c1                	jmp    8004c8 <vprintfmt+0x1ee>
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050d:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800510:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800513:	eb b6                	jmp    8004cb <vprintfmt+0x1f1>
				putch(' ', putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	57                   	push   %edi
  800519:	6a 20                	push   $0x20
  80051b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80051d:	83 eb 01             	sub    $0x1,%ebx
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	85 db                	test   %ebx,%ebx
  800525:	7f ee                	jg     800515 <vprintfmt+0x23b>
  800527:	eb 67                	jmp    800590 <vprintfmt+0x2b6>
  800529:	89 fb                	mov    %edi,%ebx
  80052b:	8b 75 08             	mov    0x8(%ebp),%esi
  80052e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800531:	eb f0                	jmp    800523 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800533:	8d 45 14             	lea    0x14(%ebp),%eax
  800536:	e8 33 fd ff ff       	call   80026e <getint>
  80053b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800541:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800546:	85 d2                	test   %edx,%edx
  800548:	79 2c                	jns    800576 <vprintfmt+0x29c>
				putch('-', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	57                   	push   %edi
  80054e:	6a 2d                	push   $0x2d
  800550:	ff d6                	call   *%esi
				num = -(long long) num;
  800552:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800555:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800558:	f7 d8                	neg    %eax
  80055a:	83 d2 00             	adc    $0x0,%edx
  80055d:	f7 da                	neg    %edx
  80055f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800562:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800567:	eb 0d                	jmp    800576 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800569:	8d 45 14             	lea    0x14(%ebp),%eax
  80056c:	e8 c3 fc ff ff       	call   800234 <getuint>
			base = 10;
  800571:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800576:	83 ec 0c             	sub    $0xc,%esp
  800579:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80057d:	53                   	push   %ebx
  80057e:	ff 75 e0             	pushl  -0x20(%ebp)
  800581:	51                   	push   %ecx
  800582:	52                   	push   %edx
  800583:	50                   	push   %eax
  800584:	89 fa                	mov    %edi,%edx
  800586:	89 f0                	mov    %esi,%eax
  800588:	e8 f8 fb ff ff       	call   800185 <printnum>
			break;
  80058d:	83 c4 20             	add    $0x20,%esp
{
  800590:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800593:	83 c3 01             	add    $0x1,%ebx
  800596:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  80059a:	83 f8 25             	cmp    $0x25,%eax
  80059d:	0f 84 52 fd ff ff    	je     8002f5 <vprintfmt+0x1b>
			if (ch == '\0')
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	0f 84 84 00 00 00    	je     80062f <vprintfmt+0x355>
			putch(ch, putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	57                   	push   %edi
  8005af:	50                   	push   %eax
  8005b0:	ff d6                	call   *%esi
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	eb dc                	jmp    800593 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8005b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ba:	e8 75 fc ff ff       	call   800234 <getuint>
			base = 8;
  8005bf:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005c4:	eb b0                	jmp    800576 <vprintfmt+0x29c>
			putch('0', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	57                   	push   %edi
  8005ca:	6a 30                	push   $0x30
  8005cc:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ce:	83 c4 08             	add    $0x8,%esp
  8005d1:	57                   	push   %edi
  8005d2:	6a 78                	push   $0x78
  8005d4:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8005e6:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005e9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005ee:	eb 86                	jmp    800576 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f3:	e8 3c fc ff ff       	call   800234 <getuint>
			base = 16;
  8005f8:	b9 10 00 00 00       	mov    $0x10,%ecx
  8005fd:	e9 74 ff ff ff       	jmp    800576 <vprintfmt+0x29c>
			putch(ch, putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	57                   	push   %edi
  800606:	6a 25                	push   $0x25
  800608:	ff d6                	call   *%esi
			break;
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	eb 81                	jmp    800590 <vprintfmt+0x2b6>
			putch('%', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	57                   	push   %edi
  800613:	6a 25                	push   $0x25
  800615:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	89 d8                	mov    %ebx,%eax
  80061c:	eb 03                	jmp    800621 <vprintfmt+0x347>
  80061e:	83 e8 01             	sub    $0x1,%eax
  800621:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800625:	75 f7                	jne    80061e <vprintfmt+0x344>
  800627:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80062a:	e9 61 ff ff ff       	jmp    800590 <vprintfmt+0x2b6>
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	83 ec 18             	sub    $0x18,%esp
  80063d:	8b 45 08             	mov    0x8(%ebp),%eax
  800640:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800643:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800646:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80064a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800654:	85 c0                	test   %eax,%eax
  800656:	74 26                	je     80067e <vsnprintf+0x47>
  800658:	85 d2                	test   %edx,%edx
  80065a:	7e 22                	jle    80067e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80065c:	ff 75 14             	pushl  0x14(%ebp)
  80065f:	ff 75 10             	pushl  0x10(%ebp)
  800662:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800665:	50                   	push   %eax
  800666:	68 a0 02 80 00       	push   $0x8002a0
  80066b:	e8 6a fc ff ff       	call   8002da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800670:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800673:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800676:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800679:	83 c4 10             	add    $0x10,%esp
}
  80067c:	c9                   	leave  
  80067d:	c3                   	ret    
		return -E_INVAL;
  80067e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800683:	eb f7                	jmp    80067c <vsnprintf+0x45>

00800685 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068e:	50                   	push   %eax
  80068f:	ff 75 10             	pushl  0x10(%ebp)
  800692:	ff 75 0c             	pushl  0xc(%ebp)
  800695:	ff 75 08             	pushl  0x8(%ebp)
  800698:	e8 9a ff ff ff       	call   800637 <vsnprintf>
	va_end(ap);

	return rc;
}
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006aa:	eb 03                	jmp    8006af <strlen+0x10>
		n++;
  8006ac:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b3:	75 f7                	jne    8006ac <strlen+0xd>
	return n;
}
  8006b5:	5d                   	pop    %ebp
  8006b6:	c3                   	ret    

008006b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c5:	eb 03                	jmp    8006ca <strnlen+0x13>
		n++;
  8006c7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ca:	39 d0                	cmp    %edx,%eax
  8006cc:	74 06                	je     8006d4 <strnlen+0x1d>
  8006ce:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006d2:	75 f3                	jne    8006c7 <strnlen+0x10>
	return n;
}
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	53                   	push   %ebx
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006e0:	89 c2                	mov    %eax,%edx
  8006e2:	83 c1 01             	add    $0x1,%ecx
  8006e5:	83 c2 01             	add    $0x1,%edx
  8006e8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006ec:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006ef:	84 db                	test   %bl,%bl
  8006f1:	75 ef                	jne    8006e2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f3:	5b                   	pop    %ebx
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	53                   	push   %ebx
  8006fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fd:	53                   	push   %ebx
  8006fe:	e8 9c ff ff ff       	call   80069f <strlen>
  800703:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800706:	ff 75 0c             	pushl  0xc(%ebp)
  800709:	01 d8                	add    %ebx,%eax
  80070b:	50                   	push   %eax
  80070c:	e8 c5 ff ff ff       	call   8006d6 <strcpy>
	return dst;
}
  800711:	89 d8                	mov    %ebx,%eax
  800713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	56                   	push   %esi
  80071c:	53                   	push   %ebx
  80071d:	8b 75 08             	mov    0x8(%ebp),%esi
  800720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800723:	89 f3                	mov    %esi,%ebx
  800725:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800728:	89 f2                	mov    %esi,%edx
  80072a:	eb 0f                	jmp    80073b <strncpy+0x23>
		*dst++ = *src;
  80072c:	83 c2 01             	add    $0x1,%edx
  80072f:	0f b6 01             	movzbl (%ecx),%eax
  800732:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800735:	80 39 01             	cmpb   $0x1,(%ecx)
  800738:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80073b:	39 da                	cmp    %ebx,%edx
  80073d:	75 ed                	jne    80072c <strncpy+0x14>
	}
	return ret;
}
  80073f:	89 f0                	mov    %esi,%eax
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	56                   	push   %esi
  800749:	53                   	push   %ebx
  80074a:	8b 75 08             	mov    0x8(%ebp),%esi
  80074d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800750:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800753:	89 f0                	mov    %esi,%eax
  800755:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800759:	85 c9                	test   %ecx,%ecx
  80075b:	75 0b                	jne    800768 <strlcpy+0x23>
  80075d:	eb 17                	jmp    800776 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80075f:	83 c2 01             	add    $0x1,%edx
  800762:	83 c0 01             	add    $0x1,%eax
  800765:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800768:	39 d8                	cmp    %ebx,%eax
  80076a:	74 07                	je     800773 <strlcpy+0x2e>
  80076c:	0f b6 0a             	movzbl (%edx),%ecx
  80076f:	84 c9                	test   %cl,%cl
  800771:	75 ec                	jne    80075f <strlcpy+0x1a>
		*dst = '\0';
  800773:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800776:	29 f0                	sub    %esi,%eax
}
  800778:	5b                   	pop    %ebx
  800779:	5e                   	pop    %esi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800785:	eb 06                	jmp    80078d <strcmp+0x11>
		p++, q++;
  800787:	83 c1 01             	add    $0x1,%ecx
  80078a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80078d:	0f b6 01             	movzbl (%ecx),%eax
  800790:	84 c0                	test   %al,%al
  800792:	74 04                	je     800798 <strcmp+0x1c>
  800794:	3a 02                	cmp    (%edx),%al
  800796:	74 ef                	je     800787 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800798:	0f b6 c0             	movzbl %al,%eax
  80079b:	0f b6 12             	movzbl (%edx),%edx
  80079e:	29 d0                	sub    %edx,%eax
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	53                   	push   %ebx
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 c3                	mov    %eax,%ebx
  8007ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b1:	eb 06                	jmp    8007b9 <strncmp+0x17>
		n--, p++, q++;
  8007b3:	83 c0 01             	add    $0x1,%eax
  8007b6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007b9:	39 d8                	cmp    %ebx,%eax
  8007bb:	74 16                	je     8007d3 <strncmp+0x31>
  8007bd:	0f b6 08             	movzbl (%eax),%ecx
  8007c0:	84 c9                	test   %cl,%cl
  8007c2:	74 04                	je     8007c8 <strncmp+0x26>
  8007c4:	3a 0a                	cmp    (%edx),%cl
  8007c6:	74 eb                	je     8007b3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c8:	0f b6 00             	movzbl (%eax),%eax
  8007cb:	0f b6 12             	movzbl (%edx),%edx
  8007ce:	29 d0                	sub    %edx,%eax
}
  8007d0:	5b                   	pop    %ebx
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    
		return 0;
  8007d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d8:	eb f6                	jmp    8007d0 <strncmp+0x2e>

008007da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e4:	0f b6 10             	movzbl (%eax),%edx
  8007e7:	84 d2                	test   %dl,%dl
  8007e9:	74 09                	je     8007f4 <strchr+0x1a>
		if (*s == c)
  8007eb:	38 ca                	cmp    %cl,%dl
  8007ed:	74 0a                	je     8007f9 <strchr+0x1f>
	for (; *s; s++)
  8007ef:	83 c0 01             	add    $0x1,%eax
  8007f2:	eb f0                	jmp    8007e4 <strchr+0xa>
			return (char *) s;
	return 0;
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800805:	eb 03                	jmp    80080a <strfind+0xf>
  800807:	83 c0 01             	add    $0x1,%eax
  80080a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80080d:	38 ca                	cmp    %cl,%dl
  80080f:	74 04                	je     800815 <strfind+0x1a>
  800811:	84 d2                	test   %dl,%dl
  800813:	75 f2                	jne    800807 <strfind+0xc>
			break;
	return (char *) s;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	57                   	push   %edi
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 55 08             	mov    0x8(%ebp),%edx
  800820:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800823:	85 c9                	test   %ecx,%ecx
  800825:	74 12                	je     800839 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800827:	f6 c2 03             	test   $0x3,%dl
  80082a:	75 05                	jne    800831 <memset+0x1a>
  80082c:	f6 c1 03             	test   $0x3,%cl
  80082f:	74 0f                	je     800840 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800831:	89 d7                	mov    %edx,%edi
  800833:	8b 45 0c             	mov    0xc(%ebp),%eax
  800836:	fc                   	cld    
  800837:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800839:	89 d0                	mov    %edx,%eax
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5f                   	pop    %edi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    
		c &= 0xFF;
  800840:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800844:	89 d8                	mov    %ebx,%eax
  800846:	c1 e0 08             	shl    $0x8,%eax
  800849:	89 df                	mov    %ebx,%edi
  80084b:	c1 e7 18             	shl    $0x18,%edi
  80084e:	89 de                	mov    %ebx,%esi
  800850:	c1 e6 10             	shl    $0x10,%esi
  800853:	09 f7                	or     %esi,%edi
  800855:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800857:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80085c:	89 d7                	mov    %edx,%edi
  80085e:	fc                   	cld    
  80085f:	f3 ab                	rep stos %eax,%es:(%edi)
  800861:	eb d6                	jmp    800839 <memset+0x22>

00800863 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	57                   	push   %edi
  800867:	56                   	push   %esi
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80086e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800871:	39 c6                	cmp    %eax,%esi
  800873:	73 35                	jae    8008aa <memmove+0x47>
  800875:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800878:	39 c2                	cmp    %eax,%edx
  80087a:	76 2e                	jbe    8008aa <memmove+0x47>
		s += n;
		d += n;
  80087c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80087f:	89 d6                	mov    %edx,%esi
  800881:	09 fe                	or     %edi,%esi
  800883:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800889:	74 0c                	je     800897 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80088b:	83 ef 01             	sub    $0x1,%edi
  80088e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800891:	fd                   	std    
  800892:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800894:	fc                   	cld    
  800895:	eb 21                	jmp    8008b8 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800897:	f6 c1 03             	test   $0x3,%cl
  80089a:	75 ef                	jne    80088b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80089c:	83 ef 04             	sub    $0x4,%edi
  80089f:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008a2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008a5:	fd                   	std    
  8008a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a8:	eb ea                	jmp    800894 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008aa:	89 f2                	mov    %esi,%edx
  8008ac:	09 c2                	or     %eax,%edx
  8008ae:	f6 c2 03             	test   $0x3,%dl
  8008b1:	74 09                	je     8008bc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b3:	89 c7                	mov    %eax,%edi
  8008b5:	fc                   	cld    
  8008b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008b8:	5e                   	pop    %esi
  8008b9:	5f                   	pop    %edi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bc:	f6 c1 03             	test   $0x3,%cl
  8008bf:	75 f2                	jne    8008b3 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008c1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008c4:	89 c7                	mov    %eax,%edi
  8008c6:	fc                   	cld    
  8008c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c9:	eb ed                	jmp    8008b8 <memmove+0x55>

008008cb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ce:	ff 75 10             	pushl  0x10(%ebp)
  8008d1:	ff 75 0c             	pushl  0xc(%ebp)
  8008d4:	ff 75 08             	pushl  0x8(%ebp)
  8008d7:	e8 87 ff ff ff       	call   800863 <memmove>
}
  8008dc:	c9                   	leave  
  8008dd:	c3                   	ret    

008008de <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e9:	89 c6                	mov    %eax,%esi
  8008eb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ee:	39 f0                	cmp    %esi,%eax
  8008f0:	74 1c                	je     80090e <memcmp+0x30>
		if (*s1 != *s2)
  8008f2:	0f b6 08             	movzbl (%eax),%ecx
  8008f5:	0f b6 1a             	movzbl (%edx),%ebx
  8008f8:	38 d9                	cmp    %bl,%cl
  8008fa:	75 08                	jne    800904 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008fc:	83 c0 01             	add    $0x1,%eax
  8008ff:	83 c2 01             	add    $0x1,%edx
  800902:	eb ea                	jmp    8008ee <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800904:	0f b6 c1             	movzbl %cl,%eax
  800907:	0f b6 db             	movzbl %bl,%ebx
  80090a:	29 d8                	sub    %ebx,%eax
  80090c:	eb 05                	jmp    800913 <memcmp+0x35>
	}

	return 0;
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800920:	89 c2                	mov    %eax,%edx
  800922:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800925:	39 d0                	cmp    %edx,%eax
  800927:	73 09                	jae    800932 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800929:	38 08                	cmp    %cl,(%eax)
  80092b:	74 05                	je     800932 <memfind+0x1b>
	for (; s < ends; s++)
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	eb f3                	jmp    800925 <memfind+0xe>
			break;
	return (void *) s;
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800940:	eb 03                	jmp    800945 <strtol+0x11>
		s++;
  800942:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800945:	0f b6 01             	movzbl (%ecx),%eax
  800948:	3c 20                	cmp    $0x20,%al
  80094a:	74 f6                	je     800942 <strtol+0xe>
  80094c:	3c 09                	cmp    $0x9,%al
  80094e:	74 f2                	je     800942 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800950:	3c 2b                	cmp    $0x2b,%al
  800952:	74 2e                	je     800982 <strtol+0x4e>
	int neg = 0;
  800954:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800959:	3c 2d                	cmp    $0x2d,%al
  80095b:	74 2f                	je     80098c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80095d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800963:	75 05                	jne    80096a <strtol+0x36>
  800965:	80 39 30             	cmpb   $0x30,(%ecx)
  800968:	74 2c                	je     800996 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80096a:	85 db                	test   %ebx,%ebx
  80096c:	75 0a                	jne    800978 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80096e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800973:	80 39 30             	cmpb   $0x30,(%ecx)
  800976:	74 28                	je     8009a0 <strtol+0x6c>
		base = 10;
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
  80097d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800980:	eb 50                	jmp    8009d2 <strtol+0x9e>
		s++;
  800982:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800985:	bf 00 00 00 00       	mov    $0x0,%edi
  80098a:	eb d1                	jmp    80095d <strtol+0x29>
		s++, neg = 1;
  80098c:	83 c1 01             	add    $0x1,%ecx
  80098f:	bf 01 00 00 00       	mov    $0x1,%edi
  800994:	eb c7                	jmp    80095d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800996:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80099a:	74 0e                	je     8009aa <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80099c:	85 db                	test   %ebx,%ebx
  80099e:	75 d8                	jne    800978 <strtol+0x44>
		s++, base = 8;
  8009a0:	83 c1 01             	add    $0x1,%ecx
  8009a3:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009a8:	eb ce                	jmp    800978 <strtol+0x44>
		s += 2, base = 16;
  8009aa:	83 c1 02             	add    $0x2,%ecx
  8009ad:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b2:	eb c4                	jmp    800978 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8009b4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009b7:	89 f3                	mov    %esi,%ebx
  8009b9:	80 fb 19             	cmp    $0x19,%bl
  8009bc:	77 29                	ja     8009e7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8009be:	0f be d2             	movsbl %dl,%edx
  8009c1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009c4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009c7:	7d 30                	jge    8009f9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009d0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009d2:	0f b6 11             	movzbl (%ecx),%edx
  8009d5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009d8:	89 f3                	mov    %esi,%ebx
  8009da:	80 fb 09             	cmp    $0x9,%bl
  8009dd:	77 d5                	ja     8009b4 <strtol+0x80>
			dig = *s - '0';
  8009df:	0f be d2             	movsbl %dl,%edx
  8009e2:	83 ea 30             	sub    $0x30,%edx
  8009e5:	eb dd                	jmp    8009c4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  8009e7:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009ea:	89 f3                	mov    %esi,%ebx
  8009ec:	80 fb 19             	cmp    $0x19,%bl
  8009ef:	77 08                	ja     8009f9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009f1:	0f be d2             	movsbl %dl,%edx
  8009f4:	83 ea 37             	sub    $0x37,%edx
  8009f7:	eb cb                	jmp    8009c4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009fd:	74 05                	je     800a04 <strtol+0xd0>
		*endptr = (char *) s;
  8009ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a02:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a04:	89 c2                	mov    %eax,%edx
  800a06:	f7 da                	neg    %edx
  800a08:	85 ff                	test   %edi,%edi
  800a0a:	0f 45 c2             	cmovne %edx,%eax
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5f                   	pop    %edi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	83 ec 1c             	sub    $0x1c,%esp
  800a1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a1e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a21:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a29:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a2c:	8b 75 14             	mov    0x14(%ebp),%esi
  800a2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a31:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a35:	74 04                	je     800a3b <syscall+0x29>
  800a37:	85 c0                	test   %eax,%eax
  800a39:	7f 08                	jg     800a43 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    
  800a43:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800a46:	83 ec 0c             	sub    $0xc,%esp
  800a49:	50                   	push   %eax
  800a4a:	52                   	push   %edx
  800a4b:	68 84 11 80 00       	push   $0x801184
  800a50:	6a 23                	push   $0x23
  800a52:	68 a1 11 80 00       	push   $0x8011a1
  800a57:	e8 1f 02 00 00       	call   800c7b <_panic>

00800a5c <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800a62:	6a 00                	push   $0x0
  800a64:	6a 00                	push   $0x0
  800a66:	6a 00                	push   $0x0
  800a68:	ff 75 0c             	pushl  0xc(%ebp)
  800a6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	e8 95 ff ff ff       	call   800a12 <syscall>
}
  800a7d:	83 c4 10             	add    $0x10,%esp
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800a88:	6a 00                	push   $0x0
  800a8a:	6a 00                	push   $0x0
  800a8c:	6a 00                	push   $0x0
  800a8e:	6a 00                	push   $0x0
  800a90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a95:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9f:	e8 6e ff ff ff       	call   800a12 <syscall>
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800aac:	6a 00                	push   $0x0
  800aae:	6a 00                	push   $0x0
  800ab0:	6a 00                	push   $0x0
  800ab2:	6a 00                	push   $0x0
  800ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab7:	ba 01 00 00 00       	mov    $0x1,%edx
  800abc:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac1:	e8 4c ff ff ff       	call   800a12 <syscall>
}
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ace:	6a 00                	push   $0x0
  800ad0:	6a 00                	push   $0x0
  800ad2:	6a 00                	push   $0x0
  800ad4:	6a 00                	push   $0x0
  800ad6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae5:	e8 28 ff ff ff       	call   800a12 <syscall>
}
  800aea:	c9                   	leave  
  800aeb:	c3                   	ret    

00800aec <sys_yield>:

void
sys_yield(void)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800af2:	6a 00                	push   $0x0
  800af4:	6a 00                	push   $0x0
  800af6:	6a 00                	push   $0x0
  800af8:	6a 00                	push   $0x0
  800afa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aff:	ba 00 00 00 00       	mov    $0x0,%edx
  800b04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b09:	e8 04 ff ff ff       	call   800a12 <syscall>
}
  800b0e:	83 c4 10             	add    $0x10,%esp
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b19:	6a 00                	push   $0x0
  800b1b:	6a 00                	push   $0x0
  800b1d:	ff 75 10             	pushl  0x10(%ebp)
  800b20:	ff 75 0c             	pushl  0xc(%ebp)
  800b23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b26:	ba 01 00 00 00       	mov    $0x1,%edx
  800b2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b30:	e8 dd fe ff ff       	call   800a12 <syscall>
}
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b3d:	ff 75 18             	pushl  0x18(%ebp)
  800b40:	ff 75 14             	pushl  0x14(%ebp)
  800b43:	ff 75 10             	pushl  0x10(%ebp)
  800b46:	ff 75 0c             	pushl  0xc(%ebp)
  800b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b51:	b8 05 00 00 00       	mov    $0x5,%eax
  800b56:	e8 b7 fe ff ff       	call   800a12 <syscall>
}
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b63:	6a 00                	push   $0x0
  800b65:	6a 00                	push   $0x0
  800b67:	6a 00                	push   $0x0
  800b69:	ff 75 0c             	pushl  0xc(%ebp)
  800b6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b74:	b8 06 00 00 00       	mov    $0x6,%eax
  800b79:	e8 94 fe ff ff       	call   800a12 <syscall>
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800b86:	6a 00                	push   $0x0
  800b88:	6a 00                	push   $0x0
  800b8a:	6a 00                	push   $0x0
  800b8c:	ff 75 0c             	pushl  0xc(%ebp)
  800b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b92:	ba 01 00 00 00       	mov    $0x1,%edx
  800b97:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9c:	e8 71 fe ff ff       	call   800a12 <syscall>
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	ff 75 0c             	pushl  0xc(%ebp)
  800bb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb5:	ba 01 00 00 00       	mov    $0x1,%edx
  800bba:	b8 09 00 00 00       	mov    $0x9,%eax
  800bbf:	e8 4e fe ff ff       	call   800a12 <syscall>
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800bcc:	6a 00                	push   $0x0
  800bce:	ff 75 14             	pushl  0x14(%ebp)
  800bd1:	ff 75 10             	pushl  0x10(%ebp)
  800bd4:	ff 75 0c             	pushl  0xc(%ebp)
  800bd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be4:	e8 29 fe ff ff       	call   800a12 <syscall>
}
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800bf1:	6a 00                	push   $0x0
  800bf3:	6a 00                	push   $0x0
  800bf5:	6a 00                	push   $0x0
  800bf7:	6a 00                	push   $0x0
  800bf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfc:	ba 01 00 00 00       	mov    $0x1,%edx
  800c01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c06:	e8 07 fe ff ff       	call   800a12 <syscall>
}
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800c13:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800c1a:	74 0a                	je     800c26 <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  800c26:	83 ec 04             	sub    $0x4,%esp
  800c29:	6a 07                	push   $0x7
  800c2b:	68 00 f0 bf ee       	push   $0xeebff000
  800c30:	6a 00                	push   $0x0
  800c32:	e8 dc fe ff ff       	call   800b13 <sys_page_alloc>
		if (r < 0) return;
  800c37:	83 c4 10             	add    $0x10,%esp
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	78 e6                	js     800c24 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800c3e:	83 ec 08             	sub    $0x8,%esp
  800c41:	68 56 0c 80 00       	push   $0x800c56
  800c46:	6a 00                	push   $0x0
  800c48:	e8 56 ff ff ff       	call   800ba3 <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	85 c0                	test   %eax,%eax
  800c52:	79 c8                	jns    800c1c <set_pgfault_handler+0xf>
  800c54:	eb ce                	jmp    800c24 <set_pgfault_handler+0x17>

00800c56 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800c56:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800c57:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800c5c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800c5e:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  800c61:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  800c65:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800c69:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  800c6c:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  800c6e:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  800c72:	58                   	pop    %eax
	popl %eax
  800c73:	58                   	pop    %eax
	popal
  800c74:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  800c75:	83 c4 04             	add    $0x4,%esp
	popfl
  800c78:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  800c79:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  800c7a:	c3                   	ret    

00800c7b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c80:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c83:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c89:	e8 3a fe ff ff       	call   800ac8 <sys_getenvid>
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	ff 75 0c             	pushl  0xc(%ebp)
  800c94:	ff 75 08             	pushl  0x8(%ebp)
  800c97:	56                   	push   %esi
  800c98:	50                   	push   %eax
  800c99:	68 b0 11 80 00       	push   $0x8011b0
  800c9e:	e8 ce f4 ff ff       	call   800171 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ca3:	83 c4 18             	add    $0x18,%esp
  800ca6:	53                   	push   %ebx
  800ca7:	ff 75 10             	pushl  0x10(%ebp)
  800caa:	e8 71 f4 ff ff       	call   800120 <vcprintf>
	cprintf("\n");
  800caf:	c7 04 24 3a 0f 80 00 	movl   $0x800f3a,(%esp)
  800cb6:	e8 b6 f4 ff ff       	call   800171 <cprintf>
  800cbb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cbe:	cc                   	int3   
  800cbf:	eb fd                	jmp    800cbe <_panic+0x43>
  800cc1:	66 90                	xchg   %ax,%ax
  800cc3:	66 90                	xchg   %ax,%ax
  800cc5:	66 90                	xchg   %ax,%ax
  800cc7:	66 90                	xchg   %ax,%ax
  800cc9:	66 90                	xchg   %ax,%ax
  800ccb:	66 90                	xchg   %ax,%ax
  800ccd:	66 90                	xchg   %ax,%ax
  800ccf:	90                   	nop

00800cd0 <__udivdi3>:
  800cd0:	55                   	push   %ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 1c             	sub    $0x1c,%esp
  800cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800cdb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ce3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ce7:	85 d2                	test   %edx,%edx
  800ce9:	75 35                	jne    800d20 <__udivdi3+0x50>
  800ceb:	39 f3                	cmp    %esi,%ebx
  800ced:	0f 87 bd 00 00 00    	ja     800db0 <__udivdi3+0xe0>
  800cf3:	85 db                	test   %ebx,%ebx
  800cf5:	89 d9                	mov    %ebx,%ecx
  800cf7:	75 0b                	jne    800d04 <__udivdi3+0x34>
  800cf9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfe:	31 d2                	xor    %edx,%edx
  800d00:	f7 f3                	div    %ebx
  800d02:	89 c1                	mov    %eax,%ecx
  800d04:	31 d2                	xor    %edx,%edx
  800d06:	89 f0                	mov    %esi,%eax
  800d08:	f7 f1                	div    %ecx
  800d0a:	89 c6                	mov    %eax,%esi
  800d0c:	89 e8                	mov    %ebp,%eax
  800d0e:	89 f7                	mov    %esi,%edi
  800d10:	f7 f1                	div    %ecx
  800d12:	89 fa                	mov    %edi,%edx
  800d14:	83 c4 1c             	add    $0x1c,%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
  800d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d20:	39 f2                	cmp    %esi,%edx
  800d22:	77 7c                	ja     800da0 <__udivdi3+0xd0>
  800d24:	0f bd fa             	bsr    %edx,%edi
  800d27:	83 f7 1f             	xor    $0x1f,%edi
  800d2a:	0f 84 98 00 00 00    	je     800dc8 <__udivdi3+0xf8>
  800d30:	89 f9                	mov    %edi,%ecx
  800d32:	b8 20 00 00 00       	mov    $0x20,%eax
  800d37:	29 f8                	sub    %edi,%eax
  800d39:	d3 e2                	shl    %cl,%edx
  800d3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d3f:	89 c1                	mov    %eax,%ecx
  800d41:	89 da                	mov    %ebx,%edx
  800d43:	d3 ea                	shr    %cl,%edx
  800d45:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d49:	09 d1                	or     %edx,%ecx
  800d4b:	89 f2                	mov    %esi,%edx
  800d4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	d3 e3                	shl    %cl,%ebx
  800d55:	89 c1                	mov    %eax,%ecx
  800d57:	d3 ea                	shr    %cl,%edx
  800d59:	89 f9                	mov    %edi,%ecx
  800d5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d5f:	d3 e6                	shl    %cl,%esi
  800d61:	89 eb                	mov    %ebp,%ebx
  800d63:	89 c1                	mov    %eax,%ecx
  800d65:	d3 eb                	shr    %cl,%ebx
  800d67:	09 de                	or     %ebx,%esi
  800d69:	89 f0                	mov    %esi,%eax
  800d6b:	f7 74 24 08          	divl   0x8(%esp)
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	89 c3                	mov    %eax,%ebx
  800d73:	f7 64 24 0c          	mull   0xc(%esp)
  800d77:	39 d6                	cmp    %edx,%esi
  800d79:	72 0c                	jb     800d87 <__udivdi3+0xb7>
  800d7b:	89 f9                	mov    %edi,%ecx
  800d7d:	d3 e5                	shl    %cl,%ebp
  800d7f:	39 c5                	cmp    %eax,%ebp
  800d81:	73 5d                	jae    800de0 <__udivdi3+0x110>
  800d83:	39 d6                	cmp    %edx,%esi
  800d85:	75 59                	jne    800de0 <__udivdi3+0x110>
  800d87:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d8a:	31 ff                	xor    %edi,%edi
  800d8c:	89 fa                	mov    %edi,%edx
  800d8e:	83 c4 1c             	add    $0x1c,%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    
  800d96:	8d 76 00             	lea    0x0(%esi),%esi
  800d99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800da0:	31 ff                	xor    %edi,%edi
  800da2:	31 c0                	xor    %eax,%eax
  800da4:	89 fa                	mov    %edi,%edx
  800da6:	83 c4 1c             	add    $0x1c,%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    
  800dae:	66 90                	xchg   %ax,%ax
  800db0:	31 ff                	xor    %edi,%edi
  800db2:	89 e8                	mov    %ebp,%eax
  800db4:	89 f2                	mov    %esi,%edx
  800db6:	f7 f3                	div    %ebx
  800db8:	89 fa                	mov    %edi,%edx
  800dba:	83 c4 1c             	add    $0x1c,%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    
  800dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dc8:	39 f2                	cmp    %esi,%edx
  800dca:	72 06                	jb     800dd2 <__udivdi3+0x102>
  800dcc:	31 c0                	xor    %eax,%eax
  800dce:	39 eb                	cmp    %ebp,%ebx
  800dd0:	77 d2                	ja     800da4 <__udivdi3+0xd4>
  800dd2:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd7:	eb cb                	jmp    800da4 <__udivdi3+0xd4>
  800dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de0:	89 d8                	mov    %ebx,%eax
  800de2:	31 ff                	xor    %edi,%edi
  800de4:	eb be                	jmp    800da4 <__udivdi3+0xd4>
  800de6:	66 90                	xchg   %ax,%ax
  800de8:	66 90                	xchg   %ax,%ax
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	66 90                	xchg   %ax,%ax
  800dee:	66 90                	xchg   %ax,%ax

00800df0 <__umoddi3>:
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 1c             	sub    $0x1c,%esp
  800df7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800dfb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e07:	85 ed                	test   %ebp,%ebp
  800e09:	89 f0                	mov    %esi,%eax
  800e0b:	89 da                	mov    %ebx,%edx
  800e0d:	75 19                	jne    800e28 <__umoddi3+0x38>
  800e0f:	39 df                	cmp    %ebx,%edi
  800e11:	0f 86 b1 00 00 00    	jbe    800ec8 <__umoddi3+0xd8>
  800e17:	f7 f7                	div    %edi
  800e19:	89 d0                	mov    %edx,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	83 c4 1c             	add    $0x1c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	39 dd                	cmp    %ebx,%ebp
  800e2a:	77 f1                	ja     800e1d <__umoddi3+0x2d>
  800e2c:	0f bd cd             	bsr    %ebp,%ecx
  800e2f:	83 f1 1f             	xor    $0x1f,%ecx
  800e32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e36:	0f 84 b4 00 00 00    	je     800ef0 <__umoddi3+0x100>
  800e3c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e41:	89 c2                	mov    %eax,%edx
  800e43:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e47:	29 c2                	sub    %eax,%edx
  800e49:	89 c1                	mov    %eax,%ecx
  800e4b:	89 f8                	mov    %edi,%eax
  800e4d:	d3 e5                	shl    %cl,%ebp
  800e4f:	89 d1                	mov    %edx,%ecx
  800e51:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e55:	d3 e8                	shr    %cl,%eax
  800e57:	09 c5                	or     %eax,%ebp
  800e59:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e5d:	89 c1                	mov    %eax,%ecx
  800e5f:	d3 e7                	shl    %cl,%edi
  800e61:	89 d1                	mov    %edx,%ecx
  800e63:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e67:	89 df                	mov    %ebx,%edi
  800e69:	d3 ef                	shr    %cl,%edi
  800e6b:	89 c1                	mov    %eax,%ecx
  800e6d:	89 f0                	mov    %esi,%eax
  800e6f:	d3 e3                	shl    %cl,%ebx
  800e71:	89 d1                	mov    %edx,%ecx
  800e73:	89 fa                	mov    %edi,%edx
  800e75:	d3 e8                	shr    %cl,%eax
  800e77:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e7c:	09 d8                	or     %ebx,%eax
  800e7e:	f7 f5                	div    %ebp
  800e80:	d3 e6                	shl    %cl,%esi
  800e82:	89 d1                	mov    %edx,%ecx
  800e84:	f7 64 24 08          	mull   0x8(%esp)
  800e88:	39 d1                	cmp    %edx,%ecx
  800e8a:	89 c3                	mov    %eax,%ebx
  800e8c:	89 d7                	mov    %edx,%edi
  800e8e:	72 06                	jb     800e96 <__umoddi3+0xa6>
  800e90:	75 0e                	jne    800ea0 <__umoddi3+0xb0>
  800e92:	39 c6                	cmp    %eax,%esi
  800e94:	73 0a                	jae    800ea0 <__umoddi3+0xb0>
  800e96:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e9a:	19 ea                	sbb    %ebp,%edx
  800e9c:	89 d7                	mov    %edx,%edi
  800e9e:	89 c3                	mov    %eax,%ebx
  800ea0:	89 ca                	mov    %ecx,%edx
  800ea2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ea7:	29 de                	sub    %ebx,%esi
  800ea9:	19 fa                	sbb    %edi,%edx
  800eab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800eaf:	89 d0                	mov    %edx,%eax
  800eb1:	d3 e0                	shl    %cl,%eax
  800eb3:	89 d9                	mov    %ebx,%ecx
  800eb5:	d3 ee                	shr    %cl,%esi
  800eb7:	d3 ea                	shr    %cl,%edx
  800eb9:	09 f0                	or     %esi,%eax
  800ebb:	83 c4 1c             	add    $0x1c,%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    
  800ec3:	90                   	nop
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	85 ff                	test   %edi,%edi
  800eca:	89 f9                	mov    %edi,%ecx
  800ecc:	75 0b                	jne    800ed9 <__umoddi3+0xe9>
  800ece:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f7                	div    %edi
  800ed7:	89 c1                	mov    %eax,%ecx
  800ed9:	89 d8                	mov    %ebx,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f1                	div    %ecx
  800edf:	89 f0                	mov    %esi,%eax
  800ee1:	f7 f1                	div    %ecx
  800ee3:	e9 31 ff ff ff       	jmp    800e19 <__umoddi3+0x29>
  800ee8:	90                   	nop
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	39 dd                	cmp    %ebx,%ebp
  800ef2:	72 08                	jb     800efc <__umoddi3+0x10c>
  800ef4:	39 f7                	cmp    %esi,%edi
  800ef6:	0f 87 21 ff ff ff    	ja     800e1d <__umoddi3+0x2d>
  800efc:	89 da                	mov    %ebx,%edx
  800efe:	89 f0                	mov    %esi,%eax
  800f00:	29 f8                	sub    %edi,%eax
  800f02:	19 ea                	sbb    %ebp,%edx
  800f04:	e9 14 ff ff ff       	jmp    800e1d <__umoddi3+0x2d>
