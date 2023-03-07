
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 72 00 00 00       	call   8000a3 <libmain>
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
  800037:	83 ec 08             	sub    $0x8,%esp
	int i;

	cprintf("Hello, I am environment %08x, cpu %d\n", thisenv->env_id, thisenv->env_cpunum);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 50 5c             	mov    0x5c(%eax),%edx
  800042:	8b 40 48             	mov    0x48(%eax),%eax
  800045:	52                   	push   %edx
  800046:	50                   	push   %eax
  800047:	68 c0 0e 80 00       	push   $0x800ec0
  80004c:	e8 43 01 00 00       	call   800194 <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800054:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800059:	e8 b1 0a 00 00       	call   800b0f <sys_yield>
		cprintf("Back in environment %08x, iteration %d, cpu %d\n",
			thisenv->env_id, i, thisenv->env_cpunum);
  80005e:	a1 04 20 80 00       	mov    0x802004,%eax
		cprintf("Back in environment %08x, iteration %d, cpu %d\n",
  800063:	8b 50 5c             	mov    0x5c(%eax),%edx
  800066:	8b 40 48             	mov    0x48(%eax),%eax
  800069:	52                   	push   %edx
  80006a:	53                   	push   %ebx
  80006b:	50                   	push   %eax
  80006c:	68 e8 0e 80 00       	push   $0x800ee8
  800071:	e8 1e 01 00 00       	call   800194 <cprintf>
	for (i = 0; i < 5; i++) {
  800076:	83 c3 01             	add    $0x1,%ebx
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d8                	jne    800059 <umain+0x26>
	}
	cprintf("All done in environment %08x, cpu %d\n", thisenv->env_id, thisenv->env_cpunum);
  800081:	a1 04 20 80 00       	mov    0x802004,%eax
  800086:	8b 50 5c             	mov    0x5c(%eax),%edx
  800089:	8b 40 48             	mov    0x48(%eax),%eax
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	52                   	push   %edx
  800090:	50                   	push   %eax
  800091:	68 18 0f 80 00       	push   $0x800f18
  800096:	e8 f9 00 00 00       	call   800194 <cprintf>
}
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
  8000a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000ae:	e8 38 0a 00 00       	call   800aeb <sys_getenvid>
	if (id >= 0)
  8000b3:	85 c0                	test   %eax,%eax
  8000b5:	78 12                	js     8000c9 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	c1 e0 07             	shl    $0x7,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 db                	test   %ebx,%ebx
  8000cb:	7e 07                	jle    8000d4 <libmain+0x31>
		binaryname = argv[0];
  8000cd:	8b 06                	mov    (%esi),%eax
  8000cf:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	e8 55 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000de:	e8 0a 00 00 00       	call   8000ed <exit>
}
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 cf 09 00 00       	call   800ac9 <sys_env_destroy>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	c9                   	leave  
  8000fe:	c3                   	ret    

008000ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	53                   	push   %ebx
  800103:	83 ec 04             	sub    $0x4,%esp
  800106:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800109:	8b 13                	mov    (%ebx),%edx
  80010b:	8d 42 01             	lea    0x1(%edx),%eax
  80010e:	89 03                	mov    %eax,(%ebx)
  800110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800113:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800117:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011c:	74 09                	je     800127 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800122:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800125:	c9                   	leave  
  800126:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800127:	83 ec 08             	sub    $0x8,%esp
  80012a:	68 ff 00 00 00       	push   $0xff
  80012f:	8d 43 08             	lea    0x8(%ebx),%eax
  800132:	50                   	push   %eax
  800133:	e8 47 09 00 00       	call   800a7f <sys_cputs>
		b->idx = 0;
  800138:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	eb db                	jmp    80011e <putch+0x1f>

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 ff 00 80 00       	push   $0x8000ff
  800172:	e8 86 01 00 00       	call   8002fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 f3 08 00 00       	call   800a7f <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 7a                	ja     800252 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 84 0a 00 00       	call   800c80 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 13                	jmp    800222 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021b:	83 eb 01             	sub    $0x1,%ebx
  80021e:	85 db                	test   %ebx,%ebx
  800220:	7f ed                	jg     80020f <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800222:	83 ec 08             	sub    $0x8,%esp
  800225:	56                   	push   %esi
  800226:	83 ec 04             	sub    $0x4,%esp
  800229:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022c:	ff 75 e0             	pushl  -0x20(%ebp)
  80022f:	ff 75 dc             	pushl  -0x24(%ebp)
  800232:	ff 75 d8             	pushl  -0x28(%ebp)
  800235:	e8 66 0b 00 00       	call   800da0 <__umoddi3>
  80023a:	83 c4 14             	add    $0x14,%esp
  80023d:	0f be 80 48 0f 80 00 	movsbl 0x800f48(%eax),%eax
  800244:	50                   	push   %eax
  800245:	ff d7                	call   *%edi
}
  800247:	83 c4 10             	add    $0x10,%esp
  80024a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    
  800252:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800255:	eb c4                	jmp    80021b <printnum+0x73>

00800257 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025a:	83 fa 01             	cmp    $0x1,%edx
  80025d:	7e 0e                	jle    80026d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	8d 4a 08             	lea    0x8(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 02                	mov    (%edx),%eax
  800268:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    
	else if (lflag)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	75 10                	jne    800281 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	eb ea                	jmp    80026b <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
  80028f:	eb da                	jmp    80026b <getuint+0x14>

00800291 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800294:	83 fa 01             	cmp    $0x1,%edx
  800297:	7e 0e                	jle    8002a7 <getint+0x16>
		return va_arg(*ap, long long);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    
	else if (lflag)
  8002a7:	85 d2                	test   %edx,%edx
  8002a9:	75 0c                	jne    8002b7 <getint+0x26>
		return va_arg(*ap, int);
  8002ab:	8b 10                	mov    (%eax),%edx
  8002ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b0:	89 08                	mov    %ecx,(%eax)
  8002b2:	8b 02                	mov    (%edx),%eax
  8002b4:	99                   	cltd   
  8002b5:	eb ee                	jmp    8002a5 <getint+0x14>
		return va_arg(*ap, long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	99                   	cltd   
  8002c1:	eb e2                	jmp    8002a5 <getint+0x14>

008002c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d2:	73 0a                	jae    8002de <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	88 02                	mov    %al,(%edx)
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <printfmt>:
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e9:	50                   	push   %eax
  8002ea:	ff 75 10             	pushl  0x10(%ebp)
  8002ed:	ff 75 0c             	pushl  0xc(%ebp)
  8002f0:	ff 75 08             	pushl  0x8(%ebp)
  8002f3:	e8 05 00 00 00       	call   8002fd <vprintfmt>
}
  8002f8:	83 c4 10             	add    $0x10,%esp
  8002fb:	c9                   	leave  
  8002fc:	c3                   	ret    

008002fd <vprintfmt>:
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 2c             	sub    $0x2c,%esp
  800306:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800309:	8b 75 0c             	mov    0xc(%ebp),%esi
  80030c:	89 f7                	mov    %esi,%edi
  80030e:	89 de                	mov    %ebx,%esi
  800310:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800313:	e9 9e 02 00 00       	jmp    8005b6 <vprintfmt+0x2b9>
		padc = ' ';
  800318:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80031c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800323:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80032a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800331:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8d 43 01             	lea    0x1(%ebx),%eax
  800339:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033c:	0f b6 0b             	movzbl (%ebx),%ecx
  80033f:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800342:	3c 55                	cmp    $0x55,%al
  800344:	0f 87 e8 02 00 00    	ja     800632 <vprintfmt+0x335>
  80034a:	0f b6 c0             	movzbl %al,%eax
  80034d:	ff 24 85 00 10 80 00 	jmp    *0x801000(,%eax,4)
  800354:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800357:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80035b:	eb d9                	jmp    800336 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800360:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800364:	eb d0                	jmp    800336 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800366:	0f b6 c9             	movzbl %cl,%ecx
  800369:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80036c:	b8 00 00 00 00       	mov    $0x0,%eax
  800371:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800374:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800377:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037b:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80037e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800381:	83 fa 09             	cmp    $0x9,%edx
  800384:	77 52                	ja     8003d8 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800386:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800389:	eb e9                	jmp    800374 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8d 48 04             	lea    0x4(%eax),%ecx
  800391:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800394:	8b 00                	mov    (%eax),%eax
  800396:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80039c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a0:	79 94                	jns    800336 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003af:	eb 85                	jmp    800336 <vprintfmt+0x39>
  8003b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b4:	85 c0                	test   %eax,%eax
  8003b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bb:	0f 49 c8             	cmovns %eax,%ecx
  8003be:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003c4:	e9 6d ff ff ff       	jmp    800336 <vprintfmt+0x39>
  8003c9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003cc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d3:	e9 5e ff ff ff       	jmp    800336 <vprintfmt+0x39>
  8003d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003db:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003de:	eb bc                	jmp    80039c <vprintfmt+0x9f>
			lflag++;
  8003e0:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003e6:	e9 4b ff ff ff       	jmp    800336 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 50 04             	lea    0x4(%eax),%edx
  8003f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f4:	83 ec 08             	sub    $0x8,%esp
  8003f7:	57                   	push   %edi
  8003f8:	ff 30                	pushl  (%eax)
  8003fa:	ff d6                	call   *%esi
			break;
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	e9 af 01 00 00       	jmp    8005b3 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 50 04             	lea    0x4(%eax),%edx
  80040a:	89 55 14             	mov    %edx,0x14(%ebp)
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	99                   	cltd   
  800410:	31 d0                	xor    %edx,%eax
  800412:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800414:	83 f8 08             	cmp    $0x8,%eax
  800417:	7f 20                	jg     800439 <vprintfmt+0x13c>
  800419:	8b 14 85 60 11 80 00 	mov    0x801160(,%eax,4),%edx
  800420:	85 d2                	test   %edx,%edx
  800422:	74 15                	je     800439 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800424:	52                   	push   %edx
  800425:	68 69 0f 80 00       	push   $0x800f69
  80042a:	57                   	push   %edi
  80042b:	56                   	push   %esi
  80042c:	e8 af fe ff ff       	call   8002e0 <printfmt>
  800431:	83 c4 10             	add    $0x10,%esp
  800434:	e9 7a 01 00 00       	jmp    8005b3 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800439:	50                   	push   %eax
  80043a:	68 60 0f 80 00       	push   $0x800f60
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	e8 9a fe ff ff       	call   8002e0 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	e9 65 01 00 00       	jmp    8005b3 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 50 04             	lea    0x4(%eax),%edx
  800454:	89 55 14             	mov    %edx,0x14(%ebp)
  800457:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800459:	85 db                	test   %ebx,%ebx
  80045b:	b8 59 0f 80 00       	mov    $0x800f59,%eax
  800460:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  800463:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800467:	0f 8e bd 00 00 00    	jle    80052a <vprintfmt+0x22d>
  80046d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800471:	75 0e                	jne    800481 <vprintfmt+0x184>
  800473:	89 75 08             	mov    %esi,0x8(%ebp)
  800476:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800479:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80047c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80047f:	eb 6d                	jmp    8004ee <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	ff 75 d0             	pushl  -0x30(%ebp)
  800487:	53                   	push   %ebx
  800488:	e8 4d 02 00 00       	call   8006da <strnlen>
  80048d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800490:	29 c1                	sub    %eax,%ecx
  800492:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800495:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800498:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049f:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004a2:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a4:	eb 0f                	jmp    8004b5 <vprintfmt+0x1b8>
					putch(padc, putdat);
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	57                   	push   %edi
  8004aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ad:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	83 eb 01             	sub    $0x1,%ebx
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	85 db                	test   %ebx,%ebx
  8004b7:	7f ed                	jg     8004a6 <vprintfmt+0x1a9>
  8004b9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004bc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004bf:	85 c9                	test   %ecx,%ecx
  8004c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c6:	0f 49 c1             	cmovns %ecx,%eax
  8004c9:	29 c1                	sub    %eax,%ecx
  8004cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d1:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004d4:	89 cf                	mov    %ecx,%edi
  8004d6:	eb 16                	jmp    8004ee <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004dc:	75 31                	jne    80050f <vprintfmt+0x212>
					putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 0c             	pushl  0xc(%ebp)
  8004e4:	50                   	push   %eax
  8004e5:	ff 55 08             	call   *0x8(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004eb:	83 ef 01             	sub    $0x1,%edi
  8004ee:	83 c3 01             	add    $0x1,%ebx
  8004f1:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8004f5:	0f be c2             	movsbl %dl,%eax
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	74 50                	je     80054c <vprintfmt+0x24f>
  8004fc:	85 f6                	test   %esi,%esi
  8004fe:	78 d8                	js     8004d8 <vprintfmt+0x1db>
  800500:	83 ee 01             	sub    $0x1,%esi
  800503:	79 d3                	jns    8004d8 <vprintfmt+0x1db>
  800505:	89 fb                	mov    %edi,%ebx
  800507:	8b 75 08             	mov    0x8(%ebp),%esi
  80050a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80050d:	eb 37                	jmp    800546 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  80050f:	0f be d2             	movsbl %dl,%edx
  800512:	83 ea 20             	sub    $0x20,%edx
  800515:	83 fa 5e             	cmp    $0x5e,%edx
  800518:	76 c4                	jbe    8004de <vprintfmt+0x1e1>
					putch('?', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 0c             	pushl  0xc(%ebp)
  800520:	6a 3f                	push   $0x3f
  800522:	ff 55 08             	call   *0x8(%ebp)
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	eb c1                	jmp    8004eb <vprintfmt+0x1ee>
  80052a:	89 75 08             	mov    %esi,0x8(%ebp)
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800530:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800533:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800536:	eb b6                	jmp    8004ee <vprintfmt+0x1f1>
				putch(' ', putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	57                   	push   %edi
  80053c:	6a 20                	push   $0x20
  80053e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800540:	83 eb 01             	sub    $0x1,%ebx
  800543:	83 c4 10             	add    $0x10,%esp
  800546:	85 db                	test   %ebx,%ebx
  800548:	7f ee                	jg     800538 <vprintfmt+0x23b>
  80054a:	eb 67                	jmp    8005b3 <vprintfmt+0x2b6>
  80054c:	89 fb                	mov    %edi,%ebx
  80054e:	8b 75 08             	mov    0x8(%ebp),%esi
  800551:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800554:	eb f0                	jmp    800546 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800556:	8d 45 14             	lea    0x14(%ebp),%eax
  800559:	e8 33 fd ff ff       	call   800291 <getint>
  80055e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800561:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800564:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800569:	85 d2                	test   %edx,%edx
  80056b:	79 2c                	jns    800599 <vprintfmt+0x29c>
				putch('-', putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	57                   	push   %edi
  800571:	6a 2d                	push   $0x2d
  800573:	ff d6                	call   *%esi
				num = -(long long) num;
  800575:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800578:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057b:	f7 d8                	neg    %eax
  80057d:	83 d2 00             	adc    $0x0,%edx
  800580:	f7 da                	neg    %edx
  800582:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800585:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80058a:	eb 0d                	jmp    800599 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80058c:	8d 45 14             	lea    0x14(%ebp),%eax
  80058f:	e8 c3 fc ff ff       	call   800257 <getuint>
			base = 10;
  800594:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800599:	83 ec 0c             	sub    $0xc,%esp
  80059c:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  8005a0:	53                   	push   %ebx
  8005a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8005a4:	51                   	push   %ecx
  8005a5:	52                   	push   %edx
  8005a6:	50                   	push   %eax
  8005a7:	89 fa                	mov    %edi,%edx
  8005a9:	89 f0                	mov    %esi,%eax
  8005ab:	e8 f8 fb ff ff       	call   8001a8 <printnum>
			break;
  8005b0:	83 c4 20             	add    $0x20,%esp
{
  8005b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b6:	83 c3 01             	add    $0x1,%ebx
  8005b9:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005bd:	83 f8 25             	cmp    $0x25,%eax
  8005c0:	0f 84 52 fd ff ff    	je     800318 <vprintfmt+0x1b>
			if (ch == '\0')
  8005c6:	85 c0                	test   %eax,%eax
  8005c8:	0f 84 84 00 00 00    	je     800652 <vprintfmt+0x355>
			putch(ch, putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	57                   	push   %edi
  8005d2:	50                   	push   %eax
  8005d3:	ff d6                	call   *%esi
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	eb dc                	jmp    8005b6 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8005da:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dd:	e8 75 fc ff ff       	call   800257 <getuint>
			base = 8;
  8005e2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e7:	eb b0                	jmp    800599 <vprintfmt+0x29c>
			putch('0', putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	57                   	push   %edi
  8005ed:	6a 30                	push   $0x30
  8005ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f1:	83 c4 08             	add    $0x8,%esp
  8005f4:	57                   	push   %edi
  8005f5:	6a 78                	push   $0x78
  8005f7:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800609:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80060c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800611:	eb 86                	jmp    800599 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 3c fc ff ff       	call   800257 <getuint>
			base = 16;
  80061b:	b9 10 00 00 00       	mov    $0x10,%ecx
  800620:	e9 74 ff ff ff       	jmp    800599 <vprintfmt+0x29c>
			putch(ch, putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	57                   	push   %edi
  800629:	6a 25                	push   $0x25
  80062b:	ff d6                	call   *%esi
			break;
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb 81                	jmp    8005b3 <vprintfmt+0x2b6>
			putch('%', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	57                   	push   %edi
  800636:	6a 25                	push   $0x25
  800638:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063a:	83 c4 10             	add    $0x10,%esp
  80063d:	89 d8                	mov    %ebx,%eax
  80063f:	eb 03                	jmp    800644 <vprintfmt+0x347>
  800641:	83 e8 01             	sub    $0x1,%eax
  800644:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800648:	75 f7                	jne    800641 <vprintfmt+0x344>
  80064a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80064d:	e9 61 ff ff ff       	jmp    8005b3 <vprintfmt+0x2b6>
}
  800652:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800655:	5b                   	pop    %ebx
  800656:	5e                   	pop    %esi
  800657:	5f                   	pop    %edi
  800658:	5d                   	pop    %ebp
  800659:	c3                   	ret    

0080065a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065a:	55                   	push   %ebp
  80065b:	89 e5                	mov    %esp,%ebp
  80065d:	83 ec 18             	sub    $0x18,%esp
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800666:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800669:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800670:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800677:	85 c0                	test   %eax,%eax
  800679:	74 26                	je     8006a1 <vsnprintf+0x47>
  80067b:	85 d2                	test   %edx,%edx
  80067d:	7e 22                	jle    8006a1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067f:	ff 75 14             	pushl  0x14(%ebp)
  800682:	ff 75 10             	pushl  0x10(%ebp)
  800685:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800688:	50                   	push   %eax
  800689:	68 c3 02 80 00       	push   $0x8002c3
  80068e:	e8 6a fc ff ff       	call   8002fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800693:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800696:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069c:	83 c4 10             	add    $0x10,%esp
}
  80069f:	c9                   	leave  
  8006a0:	c3                   	ret    
		return -E_INVAL;
  8006a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a6:	eb f7                	jmp    80069f <vsnprintf+0x45>

008006a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b1:	50                   	push   %eax
  8006b2:	ff 75 10             	pushl  0x10(%ebp)
  8006b5:	ff 75 0c             	pushl  0xc(%ebp)
  8006b8:	ff 75 08             	pushl  0x8(%ebp)
  8006bb:	e8 9a ff ff ff       	call   80065a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    

008006c2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cd:	eb 03                	jmp    8006d2 <strlen+0x10>
		n++;
  8006cf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d6:	75 f7                	jne    8006cf <strlen+0xd>
	return n;
}
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	eb 03                	jmp    8006ed <strnlen+0x13>
		n++;
  8006ea:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ed:	39 d0                	cmp    %edx,%eax
  8006ef:	74 06                	je     8006f7 <strnlen+0x1d>
  8006f1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006f5:	75 f3                	jne    8006ea <strnlen+0x10>
	return n;
}
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	53                   	push   %ebx
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800703:	89 c2                	mov    %eax,%edx
  800705:	83 c1 01             	add    $0x1,%ecx
  800708:	83 c2 01             	add    $0x1,%edx
  80070b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800712:	84 db                	test   %bl,%bl
  800714:	75 ef                	jne    800705 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800716:	5b                   	pop    %ebx
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	53                   	push   %ebx
  80071d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800720:	53                   	push   %ebx
  800721:	e8 9c ff ff ff       	call   8006c2 <strlen>
  800726:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800729:	ff 75 0c             	pushl  0xc(%ebp)
  80072c:	01 d8                	add    %ebx,%eax
  80072e:	50                   	push   %eax
  80072f:	e8 c5 ff ff ff       	call   8006f9 <strcpy>
	return dst;
}
  800734:	89 d8                	mov    %ebx,%eax
  800736:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800739:	c9                   	leave  
  80073a:	c3                   	ret    

0080073b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	56                   	push   %esi
  80073f:	53                   	push   %ebx
  800740:	8b 75 08             	mov    0x8(%ebp),%esi
  800743:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800746:	89 f3                	mov    %esi,%ebx
  800748:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074b:	89 f2                	mov    %esi,%edx
  80074d:	eb 0f                	jmp    80075e <strncpy+0x23>
		*dst++ = *src;
  80074f:	83 c2 01             	add    $0x1,%edx
  800752:	0f b6 01             	movzbl (%ecx),%eax
  800755:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800758:	80 39 01             	cmpb   $0x1,(%ecx)
  80075b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80075e:	39 da                	cmp    %ebx,%edx
  800760:	75 ed                	jne    80074f <strncpy+0x14>
	}
	return ret;
}
  800762:	89 f0                	mov    %esi,%eax
  800764:	5b                   	pop    %ebx
  800765:	5e                   	pop    %esi
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	56                   	push   %esi
  80076c:	53                   	push   %ebx
  80076d:	8b 75 08             	mov    0x8(%ebp),%esi
  800770:	8b 55 0c             	mov    0xc(%ebp),%edx
  800773:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800776:	89 f0                	mov    %esi,%eax
  800778:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80077c:	85 c9                	test   %ecx,%ecx
  80077e:	75 0b                	jne    80078b <strlcpy+0x23>
  800780:	eb 17                	jmp    800799 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800782:	83 c2 01             	add    $0x1,%edx
  800785:	83 c0 01             	add    $0x1,%eax
  800788:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80078b:	39 d8                	cmp    %ebx,%eax
  80078d:	74 07                	je     800796 <strlcpy+0x2e>
  80078f:	0f b6 0a             	movzbl (%edx),%ecx
  800792:	84 c9                	test   %cl,%cl
  800794:	75 ec                	jne    800782 <strlcpy+0x1a>
		*dst = '\0';
  800796:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800799:	29 f0                	sub    %esi,%eax
}
  80079b:	5b                   	pop    %ebx
  80079c:	5e                   	pop    %esi
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a8:	eb 06                	jmp    8007b0 <strcmp+0x11>
		p++, q++;
  8007aa:	83 c1 01             	add    $0x1,%ecx
  8007ad:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007b0:	0f b6 01             	movzbl (%ecx),%eax
  8007b3:	84 c0                	test   %al,%al
  8007b5:	74 04                	je     8007bb <strcmp+0x1c>
  8007b7:	3a 02                	cmp    (%edx),%al
  8007b9:	74 ef                	je     8007aa <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007bb:	0f b6 c0             	movzbl %al,%eax
  8007be:	0f b6 12             	movzbl (%edx),%edx
  8007c1:	29 d0                	sub    %edx,%eax
}
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	53                   	push   %ebx
  8007c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cf:	89 c3                	mov    %eax,%ebx
  8007d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d4:	eb 06                	jmp    8007dc <strncmp+0x17>
		n--, p++, q++;
  8007d6:	83 c0 01             	add    $0x1,%eax
  8007d9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007dc:	39 d8                	cmp    %ebx,%eax
  8007de:	74 16                	je     8007f6 <strncmp+0x31>
  8007e0:	0f b6 08             	movzbl (%eax),%ecx
  8007e3:	84 c9                	test   %cl,%cl
  8007e5:	74 04                	je     8007eb <strncmp+0x26>
  8007e7:	3a 0a                	cmp    (%edx),%cl
  8007e9:	74 eb                	je     8007d6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007eb:	0f b6 00             	movzbl (%eax),%eax
  8007ee:	0f b6 12             	movzbl (%edx),%edx
  8007f1:	29 d0                	sub    %edx,%eax
}
  8007f3:	5b                   	pop    %ebx
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    
		return 0;
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	eb f6                	jmp    8007f3 <strncmp+0x2e>

008007fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800807:	0f b6 10             	movzbl (%eax),%edx
  80080a:	84 d2                	test   %dl,%dl
  80080c:	74 09                	je     800817 <strchr+0x1a>
		if (*s == c)
  80080e:	38 ca                	cmp    %cl,%dl
  800810:	74 0a                	je     80081c <strchr+0x1f>
	for (; *s; s++)
  800812:	83 c0 01             	add    $0x1,%eax
  800815:	eb f0                	jmp    800807 <strchr+0xa>
			return (char *) s;
	return 0;
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800828:	eb 03                	jmp    80082d <strfind+0xf>
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800830:	38 ca                	cmp    %cl,%dl
  800832:	74 04                	je     800838 <strfind+0x1a>
  800834:	84 d2                	test   %dl,%dl
  800836:	75 f2                	jne    80082a <strfind+0xc>
			break;
	return (char *) s;
}
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	57                   	push   %edi
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
  800843:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800846:	85 c9                	test   %ecx,%ecx
  800848:	74 12                	je     80085c <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084a:	f6 c2 03             	test   $0x3,%dl
  80084d:	75 05                	jne    800854 <memset+0x1a>
  80084f:	f6 c1 03             	test   $0x3,%cl
  800852:	74 0f                	je     800863 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800854:	89 d7                	mov    %edx,%edi
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
  800859:	fc                   	cld    
  80085a:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80085c:	89 d0                	mov    %edx,%eax
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5f                   	pop    %edi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    
		c &= 0xFF;
  800863:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800867:	89 d8                	mov    %ebx,%eax
  800869:	c1 e0 08             	shl    $0x8,%eax
  80086c:	89 df                	mov    %ebx,%edi
  80086e:	c1 e7 18             	shl    $0x18,%edi
  800871:	89 de                	mov    %ebx,%esi
  800873:	c1 e6 10             	shl    $0x10,%esi
  800876:	09 f7                	or     %esi,%edi
  800878:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  80087a:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80087f:	89 d7                	mov    %edx,%edi
  800881:	fc                   	cld    
  800882:	f3 ab                	rep stos %eax,%es:(%edi)
  800884:	eb d6                	jmp    80085c <memset+0x22>

00800886 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	57                   	push   %edi
  80088a:	56                   	push   %esi
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800891:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800894:	39 c6                	cmp    %eax,%esi
  800896:	73 35                	jae    8008cd <memmove+0x47>
  800898:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089b:	39 c2                	cmp    %eax,%edx
  80089d:	76 2e                	jbe    8008cd <memmove+0x47>
		s += n;
		d += n;
  80089f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a2:	89 d6                	mov    %edx,%esi
  8008a4:	09 fe                	or     %edi,%esi
  8008a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ac:	74 0c                	je     8008ba <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ae:	83 ef 01             	sub    $0x1,%edi
  8008b1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008b4:	fd                   	std    
  8008b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008b7:	fc                   	cld    
  8008b8:	eb 21                	jmp    8008db <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ba:	f6 c1 03             	test   $0x3,%cl
  8008bd:	75 ef                	jne    8008ae <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008bf:	83 ef 04             	sub    $0x4,%edi
  8008c2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008c8:	fd                   	std    
  8008c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008cb:	eb ea                	jmp    8008b7 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cd:	89 f2                	mov    %esi,%edx
  8008cf:	09 c2                	or     %eax,%edx
  8008d1:	f6 c2 03             	test   $0x3,%dl
  8008d4:	74 09                	je     8008df <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d6:	89 c7                	mov    %eax,%edi
  8008d8:	fc                   	cld    
  8008d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008db:	5e                   	pop    %esi
  8008dc:	5f                   	pop    %edi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008df:	f6 c1 03             	test   $0x3,%cl
  8008e2:	75 f2                	jne    8008d6 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008e4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008e7:	89 c7                	mov    %eax,%edi
  8008e9:	fc                   	cld    
  8008ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ec:	eb ed                	jmp    8008db <memmove+0x55>

008008ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f1:	ff 75 10             	pushl  0x10(%ebp)
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	ff 75 08             	pushl  0x8(%ebp)
  8008fa:	e8 87 ff ff ff       	call   800886 <memmove>
}
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	89 c6                	mov    %eax,%esi
  80090e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800911:	39 f0                	cmp    %esi,%eax
  800913:	74 1c                	je     800931 <memcmp+0x30>
		if (*s1 != *s2)
  800915:	0f b6 08             	movzbl (%eax),%ecx
  800918:	0f b6 1a             	movzbl (%edx),%ebx
  80091b:	38 d9                	cmp    %bl,%cl
  80091d:	75 08                	jne    800927 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	83 c2 01             	add    $0x1,%edx
  800925:	eb ea                	jmp    800911 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800927:	0f b6 c1             	movzbl %cl,%eax
  80092a:	0f b6 db             	movzbl %bl,%ebx
  80092d:	29 d8                	sub    %ebx,%eax
  80092f:	eb 05                	jmp    800936 <memcmp+0x35>
	}

	return 0;
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800943:	89 c2                	mov    %eax,%edx
  800945:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800948:	39 d0                	cmp    %edx,%eax
  80094a:	73 09                	jae    800955 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80094c:	38 08                	cmp    %cl,(%eax)
  80094e:	74 05                	je     800955 <memfind+0x1b>
	for (; s < ends; s++)
  800950:	83 c0 01             	add    $0x1,%eax
  800953:	eb f3                	jmp    800948 <memfind+0xe>
			break;
	return (void *) s;
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	57                   	push   %edi
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800960:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800963:	eb 03                	jmp    800968 <strtol+0x11>
		s++;
  800965:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800968:	0f b6 01             	movzbl (%ecx),%eax
  80096b:	3c 20                	cmp    $0x20,%al
  80096d:	74 f6                	je     800965 <strtol+0xe>
  80096f:	3c 09                	cmp    $0x9,%al
  800971:	74 f2                	je     800965 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800973:	3c 2b                	cmp    $0x2b,%al
  800975:	74 2e                	je     8009a5 <strtol+0x4e>
	int neg = 0;
  800977:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80097c:	3c 2d                	cmp    $0x2d,%al
  80097e:	74 2f                	je     8009af <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800980:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800986:	75 05                	jne    80098d <strtol+0x36>
  800988:	80 39 30             	cmpb   $0x30,(%ecx)
  80098b:	74 2c                	je     8009b9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80098d:	85 db                	test   %ebx,%ebx
  80098f:	75 0a                	jne    80099b <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800991:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800996:	80 39 30             	cmpb   $0x30,(%ecx)
  800999:	74 28                	je     8009c3 <strtol+0x6c>
		base = 10;
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009a3:	eb 50                	jmp    8009f5 <strtol+0x9e>
		s++;
  8009a5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ad:	eb d1                	jmp    800980 <strtol+0x29>
		s++, neg = 1;
  8009af:	83 c1 01             	add    $0x1,%ecx
  8009b2:	bf 01 00 00 00       	mov    $0x1,%edi
  8009b7:	eb c7                	jmp    800980 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009bd:	74 0e                	je     8009cd <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009bf:	85 db                	test   %ebx,%ebx
  8009c1:	75 d8                	jne    80099b <strtol+0x44>
		s++, base = 8;
  8009c3:	83 c1 01             	add    $0x1,%ecx
  8009c6:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009cb:	eb ce                	jmp    80099b <strtol+0x44>
		s += 2, base = 16;
  8009cd:	83 c1 02             	add    $0x2,%ecx
  8009d0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d5:	eb c4                	jmp    80099b <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8009d7:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009da:	89 f3                	mov    %esi,%ebx
  8009dc:	80 fb 19             	cmp    $0x19,%bl
  8009df:	77 29                	ja     800a0a <strtol+0xb3>
			dig = *s - 'a' + 10;
  8009e1:	0f be d2             	movsbl %dl,%edx
  8009e4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009e7:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009ea:	7d 30                	jge    800a1c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8009ec:	83 c1 01             	add    $0x1,%ecx
  8009ef:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009f5:	0f b6 11             	movzbl (%ecx),%edx
  8009f8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fb:	89 f3                	mov    %esi,%ebx
  8009fd:	80 fb 09             	cmp    $0x9,%bl
  800a00:	77 d5                	ja     8009d7 <strtol+0x80>
			dig = *s - '0';
  800a02:	0f be d2             	movsbl %dl,%edx
  800a05:	83 ea 30             	sub    $0x30,%edx
  800a08:	eb dd                	jmp    8009e7 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a0a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	80 fb 19             	cmp    $0x19,%bl
  800a12:	77 08                	ja     800a1c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a14:	0f be d2             	movsbl %dl,%edx
  800a17:	83 ea 37             	sub    $0x37,%edx
  800a1a:	eb cb                	jmp    8009e7 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a20:	74 05                	je     800a27 <strtol+0xd0>
		*endptr = (char *) s;
  800a22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a25:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a27:	89 c2                	mov    %eax,%edx
  800a29:	f7 da                	neg    %edx
  800a2b:	85 ff                	test   %edi,%edi
  800a2d:	0f 45 c2             	cmovne %edx,%eax
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	83 ec 1c             	sub    $0x1c,%esp
  800a3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a41:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a44:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a4f:	8b 75 14             	mov    0x14(%ebp),%esi
  800a52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a54:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a58:	74 04                	je     800a5e <syscall+0x29>
  800a5a:	85 c0                	test   %eax,%eax
  800a5c:	7f 08                	jg     800a66 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    
  800a66:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800a69:	83 ec 0c             	sub    $0xc,%esp
  800a6c:	50                   	push   %eax
  800a6d:	52                   	push   %edx
  800a6e:	68 84 11 80 00       	push   $0x801184
  800a73:	6a 23                	push   $0x23
  800a75:	68 a1 11 80 00       	push   $0x8011a1
  800a7a:	e8 b1 01 00 00       	call   800c30 <_panic>

00800a7f <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800a85:	6a 00                	push   $0x0
  800a87:	6a 00                	push   $0x0
  800a89:	6a 00                	push   $0x0
  800a8b:	ff 75 0c             	pushl  0xc(%ebp)
  800a8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	e8 95 ff ff ff       	call   800a35 <syscall>
}
  800aa0:	83 c4 10             	add    $0x10,%esp
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800aab:	6a 00                	push   $0x0
  800aad:	6a 00                	push   $0x0
  800aaf:	6a 00                	push   $0x0
  800ab1:	6a 00                	push   $0x0
  800ab3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac2:	e8 6e ff ff ff       	call   800a35 <syscall>
}
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800acf:	6a 00                	push   $0x0
  800ad1:	6a 00                	push   $0x0
  800ad3:	6a 00                	push   $0x0
  800ad5:	6a 00                	push   $0x0
  800ad7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ada:	ba 01 00 00 00       	mov    $0x1,%edx
  800adf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae4:	e8 4c ff ff ff       	call   800a35 <syscall>
}
  800ae9:	c9                   	leave  
  800aea:	c3                   	ret    

00800aeb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800af1:	6a 00                	push   $0x0
  800af3:	6a 00                	push   $0x0
  800af5:	6a 00                	push   $0x0
  800af7:	6a 00                	push   $0x0
  800af9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afe:	ba 00 00 00 00       	mov    $0x0,%edx
  800b03:	b8 02 00 00 00       	mov    $0x2,%eax
  800b08:	e8 28 ff ff ff       	call   800a35 <syscall>
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <sys_yield>:

void
sys_yield(void)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b15:	6a 00                	push   $0x0
  800b17:	6a 00                	push   $0x0
  800b19:	6a 00                	push   $0x0
  800b1b:	6a 00                	push   $0x0
  800b1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2c:	e8 04 ff ff ff       	call   800a35 <syscall>
}
  800b31:	83 c4 10             	add    $0x10,%esp
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b3c:	6a 00                	push   $0x0
  800b3e:	6a 00                	push   $0x0
  800b40:	ff 75 10             	pushl  0x10(%ebp)
  800b43:	ff 75 0c             	pushl  0xc(%ebp)
  800b46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b49:	ba 01 00 00 00       	mov    $0x1,%edx
  800b4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b53:	e8 dd fe ff ff       	call   800a35 <syscall>
}
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b60:	ff 75 18             	pushl  0x18(%ebp)
  800b63:	ff 75 14             	pushl  0x14(%ebp)
  800b66:	ff 75 10             	pushl  0x10(%ebp)
  800b69:	ff 75 0c             	pushl  0xc(%ebp)
  800b6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b74:	b8 05 00 00 00       	mov    $0x5,%eax
  800b79:	e8 b7 fe ff ff       	call   800a35 <syscall>
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800b86:	6a 00                	push   $0x0
  800b88:	6a 00                	push   $0x0
  800b8a:	6a 00                	push   $0x0
  800b8c:	ff 75 0c             	pushl  0xc(%ebp)
  800b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b92:	ba 01 00 00 00       	mov    $0x1,%edx
  800b97:	b8 06 00 00 00       	mov    $0x6,%eax
  800b9c:	e8 94 fe ff ff       	call   800a35 <syscall>
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	ff 75 0c             	pushl  0xc(%ebp)
  800bb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb5:	ba 01 00 00 00       	mov    $0x1,%edx
  800bba:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbf:	e8 71 fe ff ff       	call   800a35 <syscall>
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800bcc:	6a 00                	push   $0x0
  800bce:	6a 00                	push   $0x0
  800bd0:	6a 00                	push   $0x0
  800bd2:	ff 75 0c             	pushl  0xc(%ebp)
  800bd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bdd:	b8 09 00 00 00       	mov    $0x9,%eax
  800be2:	e8 4e fe ff ff       	call   800a35 <syscall>
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800bef:	6a 00                	push   $0x0
  800bf1:	ff 75 14             	pushl  0x14(%ebp)
  800bf4:	ff 75 10             	pushl  0x10(%ebp)
  800bf7:	ff 75 0c             	pushl  0xc(%ebp)
  800bfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800c02:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c07:	e8 29 fe ff ff       	call   800a35 <syscall>
}
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c14:	6a 00                	push   $0x0
  800c16:	6a 00                	push   $0x0
  800c18:	6a 00                	push   $0x0
  800c1a:	6a 00                	push   $0x0
  800c1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c24:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c29:	e8 07 fe ff ff       	call   800a35 <syscall>
}
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c35:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c38:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c3e:	e8 a8 fe ff ff       	call   800aeb <sys_getenvid>
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	ff 75 0c             	pushl  0xc(%ebp)
  800c49:	ff 75 08             	pushl  0x8(%ebp)
  800c4c:	56                   	push   %esi
  800c4d:	50                   	push   %eax
  800c4e:	68 b0 11 80 00       	push   $0x8011b0
  800c53:	e8 3c f5 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c58:	83 c4 18             	add    $0x18,%esp
  800c5b:	53                   	push   %ebx
  800c5c:	ff 75 10             	pushl  0x10(%ebp)
  800c5f:	e8 df f4 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  800c64:	c7 04 24 d4 11 80 00 	movl   $0x8011d4,(%esp)
  800c6b:	e8 24 f5 ff ff       	call   800194 <cprintf>
  800c70:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c73:	cc                   	int3   
  800c74:	eb fd                	jmp    800c73 <_panic+0x43>
  800c76:	66 90                	xchg   %ax,%ax
  800c78:	66 90                	xchg   %ax,%ax
  800c7a:	66 90                	xchg   %ax,%ax
  800c7c:	66 90                	xchg   %ax,%ax
  800c7e:	66 90                	xchg   %ax,%ax

00800c80 <__udivdi3>:
  800c80:	55                   	push   %ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 1c             	sub    $0x1c,%esp
  800c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c8b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c93:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c97:	85 d2                	test   %edx,%edx
  800c99:	75 35                	jne    800cd0 <__udivdi3+0x50>
  800c9b:	39 f3                	cmp    %esi,%ebx
  800c9d:	0f 87 bd 00 00 00    	ja     800d60 <__udivdi3+0xe0>
  800ca3:	85 db                	test   %ebx,%ebx
  800ca5:	89 d9                	mov    %ebx,%ecx
  800ca7:	75 0b                	jne    800cb4 <__udivdi3+0x34>
  800ca9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cae:	31 d2                	xor    %edx,%edx
  800cb0:	f7 f3                	div    %ebx
  800cb2:	89 c1                	mov    %eax,%ecx
  800cb4:	31 d2                	xor    %edx,%edx
  800cb6:	89 f0                	mov    %esi,%eax
  800cb8:	f7 f1                	div    %ecx
  800cba:	89 c6                	mov    %eax,%esi
  800cbc:	89 e8                	mov    %ebp,%eax
  800cbe:	89 f7                	mov    %esi,%edi
  800cc0:	f7 f1                	div    %ecx
  800cc2:	89 fa                	mov    %edi,%edx
  800cc4:	83 c4 1c             	add    $0x1c,%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    
  800ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	39 f2                	cmp    %esi,%edx
  800cd2:	77 7c                	ja     800d50 <__udivdi3+0xd0>
  800cd4:	0f bd fa             	bsr    %edx,%edi
  800cd7:	83 f7 1f             	xor    $0x1f,%edi
  800cda:	0f 84 98 00 00 00    	je     800d78 <__udivdi3+0xf8>
  800ce0:	89 f9                	mov    %edi,%ecx
  800ce2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ce7:	29 f8                	sub    %edi,%eax
  800ce9:	d3 e2                	shl    %cl,%edx
  800ceb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cef:	89 c1                	mov    %eax,%ecx
  800cf1:	89 da                	mov    %ebx,%edx
  800cf3:	d3 ea                	shr    %cl,%edx
  800cf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cf9:	09 d1                	or     %edx,%ecx
  800cfb:	89 f2                	mov    %esi,%edx
  800cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d01:	89 f9                	mov    %edi,%ecx
  800d03:	d3 e3                	shl    %cl,%ebx
  800d05:	89 c1                	mov    %eax,%ecx
  800d07:	d3 ea                	shr    %cl,%edx
  800d09:	89 f9                	mov    %edi,%ecx
  800d0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d0f:	d3 e6                	shl    %cl,%esi
  800d11:	89 eb                	mov    %ebp,%ebx
  800d13:	89 c1                	mov    %eax,%ecx
  800d15:	d3 eb                	shr    %cl,%ebx
  800d17:	09 de                	or     %ebx,%esi
  800d19:	89 f0                	mov    %esi,%eax
  800d1b:	f7 74 24 08          	divl   0x8(%esp)
  800d1f:	89 d6                	mov    %edx,%esi
  800d21:	89 c3                	mov    %eax,%ebx
  800d23:	f7 64 24 0c          	mull   0xc(%esp)
  800d27:	39 d6                	cmp    %edx,%esi
  800d29:	72 0c                	jb     800d37 <__udivdi3+0xb7>
  800d2b:	89 f9                	mov    %edi,%ecx
  800d2d:	d3 e5                	shl    %cl,%ebp
  800d2f:	39 c5                	cmp    %eax,%ebp
  800d31:	73 5d                	jae    800d90 <__udivdi3+0x110>
  800d33:	39 d6                	cmp    %edx,%esi
  800d35:	75 59                	jne    800d90 <__udivdi3+0x110>
  800d37:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d3a:	31 ff                	xor    %edi,%edi
  800d3c:	89 fa                	mov    %edi,%edx
  800d3e:	83 c4 1c             	add    $0x1c,%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    
  800d46:	8d 76 00             	lea    0x0(%esi),%esi
  800d49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d50:	31 ff                	xor    %edi,%edi
  800d52:	31 c0                	xor    %eax,%eax
  800d54:	89 fa                	mov    %edi,%edx
  800d56:	83 c4 1c             	add    $0x1c,%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    
  800d5e:	66 90                	xchg   %ax,%ax
  800d60:	31 ff                	xor    %edi,%edi
  800d62:	89 e8                	mov    %ebp,%eax
  800d64:	89 f2                	mov    %esi,%edx
  800d66:	f7 f3                	div    %ebx
  800d68:	89 fa                	mov    %edi,%edx
  800d6a:	83 c4 1c             	add    $0x1c,%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    
  800d72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d78:	39 f2                	cmp    %esi,%edx
  800d7a:	72 06                	jb     800d82 <__udivdi3+0x102>
  800d7c:	31 c0                	xor    %eax,%eax
  800d7e:	39 eb                	cmp    %ebp,%ebx
  800d80:	77 d2                	ja     800d54 <__udivdi3+0xd4>
  800d82:	b8 01 00 00 00       	mov    $0x1,%eax
  800d87:	eb cb                	jmp    800d54 <__udivdi3+0xd4>
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	89 d8                	mov    %ebx,%eax
  800d92:	31 ff                	xor    %edi,%edi
  800d94:	eb be                	jmp    800d54 <__udivdi3+0xd4>
  800d96:	66 90                	xchg   %ax,%ax
  800d98:	66 90                	xchg   %ax,%ax
  800d9a:	66 90                	xchg   %ax,%ax
  800d9c:	66 90                	xchg   %ax,%ax
  800d9e:	66 90                	xchg   %ax,%ax

00800da0 <__umoddi3>:
  800da0:	55                   	push   %ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 1c             	sub    $0x1c,%esp
  800da7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800dab:	8b 74 24 30          	mov    0x30(%esp),%esi
  800daf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800db7:	85 ed                	test   %ebp,%ebp
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	89 da                	mov    %ebx,%edx
  800dbd:	75 19                	jne    800dd8 <__umoddi3+0x38>
  800dbf:	39 df                	cmp    %ebx,%edi
  800dc1:	0f 86 b1 00 00 00    	jbe    800e78 <__umoddi3+0xd8>
  800dc7:	f7 f7                	div    %edi
  800dc9:	89 d0                	mov    %edx,%eax
  800dcb:	31 d2                	xor    %edx,%edx
  800dcd:	83 c4 1c             	add    $0x1c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	39 dd                	cmp    %ebx,%ebp
  800dda:	77 f1                	ja     800dcd <__umoddi3+0x2d>
  800ddc:	0f bd cd             	bsr    %ebp,%ecx
  800ddf:	83 f1 1f             	xor    $0x1f,%ecx
  800de2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800de6:	0f 84 b4 00 00 00    	je     800ea0 <__umoddi3+0x100>
  800dec:	b8 20 00 00 00       	mov    $0x20,%eax
  800df1:	89 c2                	mov    %eax,%edx
  800df3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800df7:	29 c2                	sub    %eax,%edx
  800df9:	89 c1                	mov    %eax,%ecx
  800dfb:	89 f8                	mov    %edi,%eax
  800dfd:	d3 e5                	shl    %cl,%ebp
  800dff:	89 d1                	mov    %edx,%ecx
  800e01:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e05:	d3 e8                	shr    %cl,%eax
  800e07:	09 c5                	or     %eax,%ebp
  800e09:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e0d:	89 c1                	mov    %eax,%ecx
  800e0f:	d3 e7                	shl    %cl,%edi
  800e11:	89 d1                	mov    %edx,%ecx
  800e13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e17:	89 df                	mov    %ebx,%edi
  800e19:	d3 ef                	shr    %cl,%edi
  800e1b:	89 c1                	mov    %eax,%ecx
  800e1d:	89 f0                	mov    %esi,%eax
  800e1f:	d3 e3                	shl    %cl,%ebx
  800e21:	89 d1                	mov    %edx,%ecx
  800e23:	89 fa                	mov    %edi,%edx
  800e25:	d3 e8                	shr    %cl,%eax
  800e27:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e2c:	09 d8                	or     %ebx,%eax
  800e2e:	f7 f5                	div    %ebp
  800e30:	d3 e6                	shl    %cl,%esi
  800e32:	89 d1                	mov    %edx,%ecx
  800e34:	f7 64 24 08          	mull   0x8(%esp)
  800e38:	39 d1                	cmp    %edx,%ecx
  800e3a:	89 c3                	mov    %eax,%ebx
  800e3c:	89 d7                	mov    %edx,%edi
  800e3e:	72 06                	jb     800e46 <__umoddi3+0xa6>
  800e40:	75 0e                	jne    800e50 <__umoddi3+0xb0>
  800e42:	39 c6                	cmp    %eax,%esi
  800e44:	73 0a                	jae    800e50 <__umoddi3+0xb0>
  800e46:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e4a:	19 ea                	sbb    %ebp,%edx
  800e4c:	89 d7                	mov    %edx,%edi
  800e4e:	89 c3                	mov    %eax,%ebx
  800e50:	89 ca                	mov    %ecx,%edx
  800e52:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e57:	29 de                	sub    %ebx,%esi
  800e59:	19 fa                	sbb    %edi,%edx
  800e5b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e5f:	89 d0                	mov    %edx,%eax
  800e61:	d3 e0                	shl    %cl,%eax
  800e63:	89 d9                	mov    %ebx,%ecx
  800e65:	d3 ee                	shr    %cl,%esi
  800e67:	d3 ea                	shr    %cl,%edx
  800e69:	09 f0                	or     %esi,%eax
  800e6b:	83 c4 1c             	add    $0x1c,%esp
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    
  800e73:	90                   	nop
  800e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e78:	85 ff                	test   %edi,%edi
  800e7a:	89 f9                	mov    %edi,%ecx
  800e7c:	75 0b                	jne    800e89 <__umoddi3+0xe9>
  800e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e83:	31 d2                	xor    %edx,%edx
  800e85:	f7 f7                	div    %edi
  800e87:	89 c1                	mov    %eax,%ecx
  800e89:	89 d8                	mov    %ebx,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	f7 f1                	div    %ecx
  800e8f:	89 f0                	mov    %esi,%eax
  800e91:	f7 f1                	div    %ecx
  800e93:	e9 31 ff ff ff       	jmp    800dc9 <__umoddi3+0x29>
  800e98:	90                   	nop
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	39 dd                	cmp    %ebx,%ebp
  800ea2:	72 08                	jb     800eac <__umoddi3+0x10c>
  800ea4:	39 f7                	cmp    %esi,%edi
  800ea6:	0f 87 21 ff ff ff    	ja     800dcd <__umoddi3+0x2d>
  800eac:	89 da                	mov    %ebx,%edx
  800eae:	89 f0                	mov    %esi,%eax
  800eb0:	29 f8                	sub    %edi,%eax
  800eb2:	19 ea                	sbb    %ebp,%edx
  800eb4:	e9 14 ff ff ff       	jmp    800dcd <__umoddi3+0x2d>
