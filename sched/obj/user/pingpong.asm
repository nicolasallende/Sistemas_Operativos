
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 3b 0f 00 00       	call   800f7c <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 4f                	jne    800097 <umain+0x64>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800048:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004b:	83 ec 04             	sub    $0x4,%esp
  80004e:	6a 00                	push   $0x0
  800050:	6a 00                	push   $0x0
  800052:	56                   	push   %esi
  800053:	e8 69 10 00 00       	call   8010c1 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 a6 0a 00 00       	call   800b08 <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 d6 14 80 00       	push   $0x8014d6
  80006a:	e8 42 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  80006f:	83 c4 20             	add    $0x20,%esp
  800072:	83 fb 0a             	cmp    $0xa,%ebx
  800075:	74 18                	je     80008f <umain+0x5c>
			return;
		i++;
  800077:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	53                   	push   %ebx
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 96 10 00 00       	call   80111d <ipc_send>
		if (i == 10)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	83 fb 0a             	cmp    $0xa,%ebx
  80008d:	75 bc                	jne    80004b <umain+0x18>
			return;
	}

}
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
  800097:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800099:	e8 6a 0a 00 00       	call   800b08 <sys_getenvid>
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	50                   	push   %eax
  8000a3:	68 c0 14 80 00       	push   $0x8014c0
  8000a8:	e8 04 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000b6:	e8 62 10 00 00       	call   80111d <ipc_send>
  8000bb:	83 c4 20             	add    $0x20,%esp
  8000be:	eb 88                	jmp    800048 <umain+0x15>

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000cb:	e8 38 0a 00 00       	call   800b08 <sys_getenvid>
	if (id >= 0)
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	78 12                	js     8000e6 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8000d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d9:	c1 e0 07             	shl    $0x7,%eax
  8000dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e1:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e6:	85 db                	test   %ebx,%ebx
  8000e8:	7e 07                	jle    8000f1 <libmain+0x31>
		binaryname = argv[0];
  8000ea:	8b 06                	mov    (%esi),%eax
  8000ec:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f1:	83 ec 08             	sub    $0x8,%esp
  8000f4:	56                   	push   %esi
  8000f5:	53                   	push   %ebx
  8000f6:	e8 38 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000fb:	e8 0a 00 00 00       	call   80010a <exit>
}
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800110:	6a 00                	push   $0x0
  800112:	e8 cf 09 00 00       	call   800ae6 <sys_env_destroy>
}
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	c9                   	leave  
  80011b:	c3                   	ret    

0080011c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	53                   	push   %ebx
  800120:	83 ec 04             	sub    $0x4,%esp
  800123:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800126:	8b 13                	mov    (%ebx),%edx
  800128:	8d 42 01             	lea    0x1(%edx),%eax
  80012b:	89 03                	mov    %eax,(%ebx)
  80012d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800130:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800134:	3d ff 00 00 00       	cmp    $0xff,%eax
  800139:	74 09                	je     800144 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80013b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800142:	c9                   	leave  
  800143:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	68 ff 00 00 00       	push   $0xff
  80014c:	8d 43 08             	lea    0x8(%ebx),%eax
  80014f:	50                   	push   %eax
  800150:	e8 47 09 00 00       	call   800a9c <sys_cputs>
		b->idx = 0;
  800155:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015b:	83 c4 10             	add    $0x10,%esp
  80015e:	eb db                	jmp    80013b <putch+0x1f>

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1c 01 80 00       	push   $0x80011c
  80018f:	e8 86 01 00 00       	call   80031a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 f3 08 00 00       	call   800a9c <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 7a                	ja     80026f <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 57 10 00 00       	call   801270 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 13                	jmp    80023f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	85 db                	test   %ebx,%ebx
  80023d:	7f ed                	jg     80022c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023f:	83 ec 08             	sub    $0x8,%esp
  800242:	56                   	push   %esi
  800243:	83 ec 04             	sub    $0x4,%esp
  800246:	ff 75 e4             	pushl  -0x1c(%ebp)
  800249:	ff 75 e0             	pushl  -0x20(%ebp)
  80024c:	ff 75 dc             	pushl  -0x24(%ebp)
  80024f:	ff 75 d8             	pushl  -0x28(%ebp)
  800252:	e8 39 11 00 00       	call   801390 <__umoddi3>
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	0f be 80 f3 14 80 00 	movsbl 0x8014f3(%eax),%eax
  800261:	50                   	push   %eax
  800262:	ff d7                	call   *%edi
}
  800264:	83 c4 10             	add    $0x10,%esp
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    
  80026f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800272:	eb c4                	jmp    800238 <printnum+0x73>

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	75 10                	jne    80029e <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb ea                	jmp    800288 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ac:	eb da                	jmp    800288 <getuint+0x14>

008002ae <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b1:	83 fa 01             	cmp    $0x1,%edx
  8002b4:	7e 0e                	jle    8002c4 <getint+0x16>
		return va_arg(*ap, long long);
  8002b6:	8b 10                	mov    (%eax),%edx
  8002b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bb:	89 08                	mov    %ecx,(%eax)
  8002bd:	8b 02                	mov    (%edx),%eax
  8002bf:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    
	else if (lflag)
  8002c4:	85 d2                	test   %edx,%edx
  8002c6:	75 0c                	jne    8002d4 <getint+0x26>
		return va_arg(*ap, int);
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 02                	mov    (%edx),%eax
  8002d1:	99                   	cltd   
  8002d2:	eb ee                	jmp    8002c2 <getint+0x14>
		return va_arg(*ap, long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	99                   	cltd   
  8002de:	eb e2                	jmp    8002c2 <getint+0x14>

008002e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ef:	73 0a                	jae    8002fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	88 02                	mov    %al,(%edx)
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <printfmt>:
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800303:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800306:	50                   	push   %eax
  800307:	ff 75 10             	pushl  0x10(%ebp)
  80030a:	ff 75 0c             	pushl  0xc(%ebp)
  80030d:	ff 75 08             	pushl  0x8(%ebp)
  800310:	e8 05 00 00 00       	call   80031a <vprintfmt>
}
  800315:	83 c4 10             	add    $0x10,%esp
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <vprintfmt>:
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 2c             	sub    $0x2c,%esp
  800323:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800326:	8b 75 0c             	mov    0xc(%ebp),%esi
  800329:	89 f7                	mov    %esi,%edi
  80032b:	89 de                	mov    %ebx,%esi
  80032d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800330:	e9 9e 02 00 00       	jmp    8005d3 <vprintfmt+0x2b9>
		padc = ' ';
  800335:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800339:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800340:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800347:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80034e:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8d 43 01             	lea    0x1(%ebx),%eax
  800356:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800359:	0f b6 0b             	movzbl (%ebx),%ecx
  80035c:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80035f:	3c 55                	cmp    $0x55,%al
  800361:	0f 87 e8 02 00 00    	ja     80064f <vprintfmt+0x335>
  800367:	0f b6 c0             	movzbl %al,%eax
  80036a:	ff 24 85 c0 15 80 00 	jmp    *0x8015c0(,%eax,4)
  800371:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800374:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800378:	eb d9                	jmp    800353 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  80037d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800381:	eb d0                	jmp    800353 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800383:	0f b6 c9             	movzbl %cl,%ecx
  800386:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800389:	b8 00 00 00 00       	mov    $0x0,%eax
  80038e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800391:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800394:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800398:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80039b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80039e:	83 fa 09             	cmp    $0x9,%edx
  8003a1:	77 52                	ja     8003f5 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  8003a3:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8003a6:	eb e9                	jmp    800391 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b1:	8b 00                	mov    (%eax),%eax
  8003b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  8003b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003bd:	79 94                	jns    800353 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cc:	eb 85                	jmp    800353 <vprintfmt+0x39>
  8003ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d1:	85 c0                	test   %eax,%eax
  8003d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d8:	0f 49 c8             	cmovns %eax,%ecx
  8003db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003e1:	e9 6d ff ff ff       	jmp    800353 <vprintfmt+0x39>
  8003e6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003e9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f0:	e9 5e ff ff ff       	jmp    800353 <vprintfmt+0x39>
  8003f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003fb:	eb bc                	jmp    8003b9 <vprintfmt+0x9f>
			lflag++;
  8003fd:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800403:	e9 4b ff ff ff       	jmp    800353 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 50 04             	lea    0x4(%eax),%edx
  80040e:	89 55 14             	mov    %edx,0x14(%ebp)
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	57                   	push   %edi
  800415:	ff 30                	pushl  (%eax)
  800417:	ff d6                	call   *%esi
			break;
  800419:	83 c4 10             	add    $0x10,%esp
  80041c:	e9 af 01 00 00       	jmp    8005d0 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 50 04             	lea    0x4(%eax),%edx
  800427:	89 55 14             	mov    %edx,0x14(%ebp)
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	99                   	cltd   
  80042d:	31 d0                	xor    %edx,%eax
  80042f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800431:	83 f8 08             	cmp    $0x8,%eax
  800434:	7f 20                	jg     800456 <vprintfmt+0x13c>
  800436:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  80043d:	85 d2                	test   %edx,%edx
  80043f:	74 15                	je     800456 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800441:	52                   	push   %edx
  800442:	68 14 15 80 00       	push   $0x801514
  800447:	57                   	push   %edi
  800448:	56                   	push   %esi
  800449:	e8 af fe ff ff       	call   8002fd <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	e9 7a 01 00 00       	jmp    8005d0 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800456:	50                   	push   %eax
  800457:	68 0b 15 80 00       	push   $0x80150b
  80045c:	57                   	push   %edi
  80045d:	56                   	push   %esi
  80045e:	e8 9a fe ff ff       	call   8002fd <printfmt>
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	e9 65 01 00 00       	jmp    8005d0 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 50 04             	lea    0x4(%eax),%edx
  800471:	89 55 14             	mov    %edx,0x14(%ebp)
  800474:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800476:	85 db                	test   %ebx,%ebx
  800478:	b8 04 15 80 00       	mov    $0x801504,%eax
  80047d:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  800480:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800484:	0f 8e bd 00 00 00    	jle    800547 <vprintfmt+0x22d>
  80048a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048e:	75 0e                	jne    80049e <vprintfmt+0x184>
  800490:	89 75 08             	mov    %esi,0x8(%ebp)
  800493:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800496:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800499:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80049c:	eb 6d                	jmp    80050b <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a4:	53                   	push   %ebx
  8004a5:	e8 4d 02 00 00       	call   8006f7 <strnlen>
  8004aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ad:	29 c1                	sub    %eax,%ecx
  8004af:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004bf:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	eb 0f                	jmp    8004d2 <vprintfmt+0x1b8>
					putch(padc, putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	57                   	push   %edi
  8004c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ca:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	83 eb 01             	sub    $0x1,%ebx
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 db                	test   %ebx,%ebx
  8004d4:	7f ed                	jg     8004c3 <vprintfmt+0x1a9>
  8004d6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004dc:	85 c9                	test   %ecx,%ecx
  8004de:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e3:	0f 49 c1             	cmovns %ecx,%eax
  8004e6:	29 c1                	sub    %eax,%ecx
  8004e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ee:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004f1:	89 cf                	mov    %ecx,%edi
  8004f3:	eb 16                	jmp    80050b <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f9:	75 31                	jne    80052c <vprintfmt+0x212>
					putch(ch, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	50                   	push   %eax
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	83 ef 01             	sub    $0x1,%edi
  80050b:	83 c3 01             	add    $0x1,%ebx
  80050e:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  800512:	0f be c2             	movsbl %dl,%eax
  800515:	85 c0                	test   %eax,%eax
  800517:	74 50                	je     800569 <vprintfmt+0x24f>
  800519:	85 f6                	test   %esi,%esi
  80051b:	78 d8                	js     8004f5 <vprintfmt+0x1db>
  80051d:	83 ee 01             	sub    $0x1,%esi
  800520:	79 d3                	jns    8004f5 <vprintfmt+0x1db>
  800522:	89 fb                	mov    %edi,%ebx
  800524:	8b 75 08             	mov    0x8(%ebp),%esi
  800527:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80052a:	eb 37                	jmp    800563 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	0f be d2             	movsbl %dl,%edx
  80052f:	83 ea 20             	sub    $0x20,%edx
  800532:	83 fa 5e             	cmp    $0x5e,%edx
  800535:	76 c4                	jbe    8004fb <vprintfmt+0x1e1>
					putch('?', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	6a 3f                	push   $0x3f
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb c1                	jmp    800508 <vprintfmt+0x1ee>
  800547:	89 75 08             	mov    %esi,0x8(%ebp)
  80054a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054d:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800550:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800553:	eb b6                	jmp    80050b <vprintfmt+0x1f1>
				putch(' ', putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	57                   	push   %edi
  800559:	6a 20                	push   $0x20
  80055b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80055d:	83 eb 01             	sub    $0x1,%ebx
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	85 db                	test   %ebx,%ebx
  800565:	7f ee                	jg     800555 <vprintfmt+0x23b>
  800567:	eb 67                	jmp    8005d0 <vprintfmt+0x2b6>
  800569:	89 fb                	mov    %edi,%ebx
  80056b:	8b 75 08             	mov    0x8(%ebp),%esi
  80056e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800571:	eb f0                	jmp    800563 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800573:	8d 45 14             	lea    0x14(%ebp),%eax
  800576:	e8 33 fd ff ff       	call   8002ae <getint>
  80057b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800586:	85 d2                	test   %edx,%edx
  800588:	79 2c                	jns    8005b6 <vprintfmt+0x29c>
				putch('-', putdat);
  80058a:	83 ec 08             	sub    $0x8,%esp
  80058d:	57                   	push   %edi
  80058e:	6a 2d                	push   $0x2d
  800590:	ff d6                	call   *%esi
				num = -(long long) num;
  800592:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800595:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800598:	f7 d8                	neg    %eax
  80059a:	83 d2 00             	adc    $0x0,%edx
  80059d:	f7 da                	neg    %edx
  80059f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005a7:	eb 0d                	jmp    8005b6 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ac:	e8 c3 fc ff ff       	call   800274 <getuint>
			base = 10;
  8005b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8005b6:	83 ec 0c             	sub    $0xc,%esp
  8005b9:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  8005bd:	53                   	push   %ebx
  8005be:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c1:	51                   	push   %ecx
  8005c2:	52                   	push   %edx
  8005c3:	50                   	push   %eax
  8005c4:	89 fa                	mov    %edi,%edx
  8005c6:	89 f0                	mov    %esi,%eax
  8005c8:	e8 f8 fb ff ff       	call   8001c5 <printnum>
			break;
  8005cd:	83 c4 20             	add    $0x20,%esp
{
  8005d0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d3:	83 c3 01             	add    $0x1,%ebx
  8005d6:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005da:	83 f8 25             	cmp    $0x25,%eax
  8005dd:	0f 84 52 fd ff ff    	je     800335 <vprintfmt+0x1b>
			if (ch == '\0')
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	0f 84 84 00 00 00    	je     80066f <vprintfmt+0x355>
			putch(ch, putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	57                   	push   %edi
  8005ef:	50                   	push   %eax
  8005f0:	ff d6                	call   *%esi
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	eb dc                	jmp    8005d3 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 75 fc ff ff       	call   800274 <getuint>
			base = 8;
  8005ff:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800604:	eb b0                	jmp    8005b6 <vprintfmt+0x29c>
			putch('0', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	57                   	push   %edi
  80060a:	6a 30                	push   $0x30
  80060c:	ff d6                	call   *%esi
			putch('x', putdat);
  80060e:	83 c4 08             	add    $0x8,%esp
  800611:	57                   	push   %edi
  800612:	6a 78                	push   $0x78
  800614:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800626:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800629:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80062e:	eb 86                	jmp    8005b6 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800630:	8d 45 14             	lea    0x14(%ebp),%eax
  800633:	e8 3c fc ff ff       	call   800274 <getuint>
			base = 16;
  800638:	b9 10 00 00 00       	mov    $0x10,%ecx
  80063d:	e9 74 ff ff ff       	jmp    8005b6 <vprintfmt+0x29c>
			putch(ch, putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	57                   	push   %edi
  800646:	6a 25                	push   $0x25
  800648:	ff d6                	call   *%esi
			break;
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	eb 81                	jmp    8005d0 <vprintfmt+0x2b6>
			putch('%', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	57                   	push   %edi
  800653:	6a 25                	push   $0x25
  800655:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800657:	83 c4 10             	add    $0x10,%esp
  80065a:	89 d8                	mov    %ebx,%eax
  80065c:	eb 03                	jmp    800661 <vprintfmt+0x347>
  80065e:	83 e8 01             	sub    $0x1,%eax
  800661:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800665:	75 f7                	jne    80065e <vprintfmt+0x344>
  800667:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066a:	e9 61 ff ff ff       	jmp    8005d0 <vprintfmt+0x2b6>
}
  80066f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800672:	5b                   	pop    %ebx
  800673:	5e                   	pop    %esi
  800674:	5f                   	pop    %edi
  800675:	5d                   	pop    %ebp
  800676:	c3                   	ret    

00800677 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	83 ec 18             	sub    $0x18,%esp
  80067d:	8b 45 08             	mov    0x8(%ebp),%eax
  800680:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800686:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800694:	85 c0                	test   %eax,%eax
  800696:	74 26                	je     8006be <vsnprintf+0x47>
  800698:	85 d2                	test   %edx,%edx
  80069a:	7e 22                	jle    8006be <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069c:	ff 75 14             	pushl  0x14(%ebp)
  80069f:	ff 75 10             	pushl  0x10(%ebp)
  8006a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a5:	50                   	push   %eax
  8006a6:	68 e0 02 80 00       	push   $0x8002e0
  8006ab:	e8 6a fc ff ff       	call   80031a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	83 c4 10             	add    $0x10,%esp
}
  8006bc:	c9                   	leave  
  8006bd:	c3                   	ret    
		return -E_INVAL;
  8006be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c3:	eb f7                	jmp    8006bc <vsnprintf+0x45>

008006c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ce:	50                   	push   %eax
  8006cf:	ff 75 10             	pushl  0x10(%ebp)
  8006d2:	ff 75 0c             	pushl  0xc(%ebp)
  8006d5:	ff 75 08             	pushl  0x8(%ebp)
  8006d8:	e8 9a ff ff ff       	call   800677 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ea:	eb 03                	jmp    8006ef <strlen+0x10>
		n++;
  8006ec:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006ef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f3:	75 f7                	jne    8006ec <strlen+0xd>
	return n;
}
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800700:	b8 00 00 00 00       	mov    $0x0,%eax
  800705:	eb 03                	jmp    80070a <strnlen+0x13>
		n++;
  800707:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070a:	39 d0                	cmp    %edx,%eax
  80070c:	74 06                	je     800714 <strnlen+0x1d>
  80070e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800712:	75 f3                	jne    800707 <strnlen+0x10>
	return n;
}
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800720:	89 c2                	mov    %eax,%edx
  800722:	83 c1 01             	add    $0x1,%ecx
  800725:	83 c2 01             	add    $0x1,%edx
  800728:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072f:	84 db                	test   %bl,%bl
  800731:	75 ef                	jne    800722 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800733:	5b                   	pop    %ebx
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073d:	53                   	push   %ebx
  80073e:	e8 9c ff ff ff       	call   8006df <strlen>
  800743:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800746:	ff 75 0c             	pushl  0xc(%ebp)
  800749:	01 d8                	add    %ebx,%eax
  80074b:	50                   	push   %eax
  80074c:	e8 c5 ff ff ff       	call   800716 <strcpy>
	return dst;
}
  800751:	89 d8                	mov    %ebx,%eax
  800753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	56                   	push   %esi
  80075c:	53                   	push   %ebx
  80075d:	8b 75 08             	mov    0x8(%ebp),%esi
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800763:	89 f3                	mov    %esi,%ebx
  800765:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800768:	89 f2                	mov    %esi,%edx
  80076a:	eb 0f                	jmp    80077b <strncpy+0x23>
		*dst++ = *src;
  80076c:	83 c2 01             	add    $0x1,%edx
  80076f:	0f b6 01             	movzbl (%ecx),%eax
  800772:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800775:	80 39 01             	cmpb   $0x1,(%ecx)
  800778:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80077b:	39 da                	cmp    %ebx,%edx
  80077d:	75 ed                	jne    80076c <strncpy+0x14>
	}
	return ret;
}
  80077f:	89 f0                	mov    %esi,%eax
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	56                   	push   %esi
  800789:	53                   	push   %ebx
  80078a:	8b 75 08             	mov    0x8(%ebp),%esi
  80078d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800790:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800793:	89 f0                	mov    %esi,%eax
  800795:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800799:	85 c9                	test   %ecx,%ecx
  80079b:	75 0b                	jne    8007a8 <strlcpy+0x23>
  80079d:	eb 17                	jmp    8007b6 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079f:	83 c2 01             	add    $0x1,%edx
  8007a2:	83 c0 01             	add    $0x1,%eax
  8007a5:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8007a8:	39 d8                	cmp    %ebx,%eax
  8007aa:	74 07                	je     8007b3 <strlcpy+0x2e>
  8007ac:	0f b6 0a             	movzbl (%edx),%ecx
  8007af:	84 c9                	test   %cl,%cl
  8007b1:	75 ec                	jne    80079f <strlcpy+0x1a>
		*dst = '\0';
  8007b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b6:	29 f0                	sub    %esi,%eax
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c5:	eb 06                	jmp    8007cd <strcmp+0x11>
		p++, q++;
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007cd:	0f b6 01             	movzbl (%ecx),%eax
  8007d0:	84 c0                	test   %al,%al
  8007d2:	74 04                	je     8007d8 <strcmp+0x1c>
  8007d4:	3a 02                	cmp    (%edx),%al
  8007d6:	74 ef                	je     8007c7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d8:	0f b6 c0             	movzbl %al,%eax
  8007db:	0f b6 12             	movzbl (%edx),%edx
  8007de:	29 d0                	sub    %edx,%eax
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ec:	89 c3                	mov    %eax,%ebx
  8007ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f1:	eb 06                	jmp    8007f9 <strncmp+0x17>
		n--, p++, q++;
  8007f3:	83 c0 01             	add    $0x1,%eax
  8007f6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007f9:	39 d8                	cmp    %ebx,%eax
  8007fb:	74 16                	je     800813 <strncmp+0x31>
  8007fd:	0f b6 08             	movzbl (%eax),%ecx
  800800:	84 c9                	test   %cl,%cl
  800802:	74 04                	je     800808 <strncmp+0x26>
  800804:	3a 0a                	cmp    (%edx),%cl
  800806:	74 eb                	je     8007f3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800808:	0f b6 00             	movzbl (%eax),%eax
  80080b:	0f b6 12             	movzbl (%edx),%edx
  80080e:	29 d0                	sub    %edx,%eax
}
  800810:	5b                   	pop    %ebx
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    
		return 0;
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
  800818:	eb f6                	jmp    800810 <strncmp+0x2e>

0080081a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800824:	0f b6 10             	movzbl (%eax),%edx
  800827:	84 d2                	test   %dl,%dl
  800829:	74 09                	je     800834 <strchr+0x1a>
		if (*s == c)
  80082b:	38 ca                	cmp    %cl,%dl
  80082d:	74 0a                	je     800839 <strchr+0x1f>
	for (; *s; s++)
  80082f:	83 c0 01             	add    $0x1,%eax
  800832:	eb f0                	jmp    800824 <strchr+0xa>
			return (char *) s;
	return 0;
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800845:	eb 03                	jmp    80084a <strfind+0xf>
  800847:	83 c0 01             	add    $0x1,%eax
  80084a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 04                	je     800855 <strfind+0x1a>
  800851:	84 d2                	test   %dl,%dl
  800853:	75 f2                	jne    800847 <strfind+0xc>
			break;
	return (char *) s;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	57                   	push   %edi
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 55 08             	mov    0x8(%ebp),%edx
  800860:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800863:	85 c9                	test   %ecx,%ecx
  800865:	74 12                	je     800879 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800867:	f6 c2 03             	test   $0x3,%dl
  80086a:	75 05                	jne    800871 <memset+0x1a>
  80086c:	f6 c1 03             	test   $0x3,%cl
  80086f:	74 0f                	je     800880 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800871:	89 d7                	mov    %edx,%edi
  800873:	8b 45 0c             	mov    0xc(%ebp),%eax
  800876:	fc                   	cld    
  800877:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800879:	89 d0                	mov    %edx,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    
		c &= 0xFF;
  800880:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800884:	89 d8                	mov    %ebx,%eax
  800886:	c1 e0 08             	shl    $0x8,%eax
  800889:	89 df                	mov    %ebx,%edi
  80088b:	c1 e7 18             	shl    $0x18,%edi
  80088e:	89 de                	mov    %ebx,%esi
  800890:	c1 e6 10             	shl    $0x10,%esi
  800893:	09 f7                	or     %esi,%edi
  800895:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800897:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80089c:	89 d7                	mov    %edx,%edi
  80089e:	fc                   	cld    
  80089f:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a1:	eb d6                	jmp    800879 <memset+0x22>

008008a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	57                   	push   %edi
  8008a7:	56                   	push   %esi
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b1:	39 c6                	cmp    %eax,%esi
  8008b3:	73 35                	jae    8008ea <memmove+0x47>
  8008b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b8:	39 c2                	cmp    %eax,%edx
  8008ba:	76 2e                	jbe    8008ea <memmove+0x47>
		s += n;
		d += n;
  8008bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bf:	89 d6                	mov    %edx,%esi
  8008c1:	09 fe                	or     %edi,%esi
  8008c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c9:	74 0c                	je     8008d7 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008cb:	83 ef 01             	sub    $0x1,%edi
  8008ce:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008d1:	fd                   	std    
  8008d2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d4:	fc                   	cld    
  8008d5:	eb 21                	jmp    8008f8 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d7:	f6 c1 03             	test   $0x3,%cl
  8008da:	75 ef                	jne    8008cb <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008dc:	83 ef 04             	sub    $0x4,%edi
  8008df:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008e5:	fd                   	std    
  8008e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e8:	eb ea                	jmp    8008d4 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ea:	89 f2                	mov    %esi,%edx
  8008ec:	09 c2                	or     %eax,%edx
  8008ee:	f6 c2 03             	test   $0x3,%dl
  8008f1:	74 09                	je     8008fc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f3:	89 c7                	mov    %eax,%edi
  8008f5:	fc                   	cld    
  8008f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f8:	5e                   	pop    %esi
  8008f9:	5f                   	pop    %edi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fc:	f6 c1 03             	test   $0x3,%cl
  8008ff:	75 f2                	jne    8008f3 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800901:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800904:	89 c7                	mov    %eax,%edi
  800906:	fc                   	cld    
  800907:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800909:	eb ed                	jmp    8008f8 <memmove+0x55>

0080090b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090e:	ff 75 10             	pushl  0x10(%ebp)
  800911:	ff 75 0c             	pushl  0xc(%ebp)
  800914:	ff 75 08             	pushl  0x8(%ebp)
  800917:	e8 87 ff ff ff       	call   8008a3 <memmove>
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	89 c6                	mov    %eax,%esi
  80092b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092e:	39 f0                	cmp    %esi,%eax
  800930:	74 1c                	je     80094e <memcmp+0x30>
		if (*s1 != *s2)
  800932:	0f b6 08             	movzbl (%eax),%ecx
  800935:	0f b6 1a             	movzbl (%edx),%ebx
  800938:	38 d9                	cmp    %bl,%cl
  80093a:	75 08                	jne    800944 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	83 c2 01             	add    $0x1,%edx
  800942:	eb ea                	jmp    80092e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800944:	0f b6 c1             	movzbl %cl,%eax
  800947:	0f b6 db             	movzbl %bl,%ebx
  80094a:	29 d8                	sub    %ebx,%eax
  80094c:	eb 05                	jmp    800953 <memcmp+0x35>
	}

	return 0;
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800960:	89 c2                	mov    %eax,%edx
  800962:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800965:	39 d0                	cmp    %edx,%eax
  800967:	73 09                	jae    800972 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800969:	38 08                	cmp    %cl,(%eax)
  80096b:	74 05                	je     800972 <memfind+0x1b>
	for (; s < ends; s++)
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	eb f3                	jmp    800965 <memfind+0xe>
			break;
	return (void *) s;
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800980:	eb 03                	jmp    800985 <strtol+0x11>
		s++;
  800982:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800985:	0f b6 01             	movzbl (%ecx),%eax
  800988:	3c 20                	cmp    $0x20,%al
  80098a:	74 f6                	je     800982 <strtol+0xe>
  80098c:	3c 09                	cmp    $0x9,%al
  80098e:	74 f2                	je     800982 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800990:	3c 2b                	cmp    $0x2b,%al
  800992:	74 2e                	je     8009c2 <strtol+0x4e>
	int neg = 0;
  800994:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800999:	3c 2d                	cmp    $0x2d,%al
  80099b:	74 2f                	je     8009cc <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a3:	75 05                	jne    8009aa <strtol+0x36>
  8009a5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a8:	74 2c                	je     8009d6 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009aa:	85 db                	test   %ebx,%ebx
  8009ac:	75 0a                	jne    8009b8 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ae:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8009b3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b6:	74 28                	je     8009e0 <strtol+0x6c>
		base = 10;
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009c0:	eb 50                	jmp    800a12 <strtol+0x9e>
		s++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ca:	eb d1                	jmp    80099d <strtol+0x29>
		s++, neg = 1;
  8009cc:	83 c1 01             	add    $0x1,%ecx
  8009cf:	bf 01 00 00 00       	mov    $0x1,%edi
  8009d4:	eb c7                	jmp    80099d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009da:	74 0e                	je     8009ea <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009dc:	85 db                	test   %ebx,%ebx
  8009de:	75 d8                	jne    8009b8 <strtol+0x44>
		s++, base = 8;
  8009e0:	83 c1 01             	add    $0x1,%ecx
  8009e3:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009e8:	eb ce                	jmp    8009b8 <strtol+0x44>
		s += 2, base = 16;
  8009ea:	83 c1 02             	add    $0x2,%ecx
  8009ed:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f2:	eb c4                	jmp    8009b8 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8009f4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009f7:	89 f3                	mov    %esi,%ebx
  8009f9:	80 fb 19             	cmp    $0x19,%bl
  8009fc:	77 29                	ja     800a27 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8009fe:	0f be d2             	movsbl %dl,%edx
  800a01:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a04:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a07:	7d 30                	jge    800a39 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a10:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a12:	0f b6 11             	movzbl (%ecx),%edx
  800a15:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a18:	89 f3                	mov    %esi,%ebx
  800a1a:	80 fb 09             	cmp    $0x9,%bl
  800a1d:	77 d5                	ja     8009f4 <strtol+0x80>
			dig = *s - '0';
  800a1f:	0f be d2             	movsbl %dl,%edx
  800a22:	83 ea 30             	sub    $0x30,%edx
  800a25:	eb dd                	jmp    800a04 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a27:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	80 fb 19             	cmp    $0x19,%bl
  800a2f:	77 08                	ja     800a39 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a31:	0f be d2             	movsbl %dl,%edx
  800a34:	83 ea 37             	sub    $0x37,%edx
  800a37:	eb cb                	jmp    800a04 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3d:	74 05                	je     800a44 <strtol+0xd0>
		*endptr = (char *) s;
  800a3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a42:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a44:	89 c2                	mov    %eax,%edx
  800a46:	f7 da                	neg    %edx
  800a48:	85 ff                	test   %edi,%edi
  800a4a:	0f 45 c2             	cmovne %edx,%eax
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
  800a58:	83 ec 1c             	sub    $0x1c,%esp
  800a5b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a61:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a69:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a6c:	8b 75 14             	mov    0x14(%ebp),%esi
  800a6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a71:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a75:	74 04                	je     800a7b <syscall+0x29>
  800a77:	85 c0                	test   %eax,%eax
  800a79:	7f 08                	jg     800a83 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5f                   	pop    %edi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    
  800a83:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800a86:	83 ec 0c             	sub    $0xc,%esp
  800a89:	50                   	push   %eax
  800a8a:	52                   	push   %edx
  800a8b:	68 44 17 80 00       	push   $0x801744
  800a90:	6a 23                	push   $0x23
  800a92:	68 61 17 80 00       	push   $0x801761
  800a97:	e8 1e 07 00 00       	call   8011ba <_panic>

00800a9c <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800aa2:	6a 00                	push   $0x0
  800aa4:	6a 00                	push   $0x0
  800aa6:	6a 00                	push   $0x0
  800aa8:	ff 75 0c             	pushl  0xc(%ebp)
  800aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aae:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab8:	e8 95 ff ff ff       	call   800a52 <syscall>
}
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ac8:	6a 00                	push   $0x0
  800aca:	6a 00                	push   $0x0
  800acc:	6a 00                	push   $0x0
  800ace:	6a 00                	push   $0x0
  800ad0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 01 00 00 00       	mov    $0x1,%eax
  800adf:	e8 6e ff ff ff       	call   800a52 <syscall>
}
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800aec:	6a 00                	push   $0x0
  800aee:	6a 00                	push   $0x0
  800af0:	6a 00                	push   $0x0
  800af2:	6a 00                	push   $0x0
  800af4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af7:	ba 01 00 00 00       	mov    $0x1,%edx
  800afc:	b8 03 00 00 00       	mov    $0x3,%eax
  800b01:	e8 4c ff ff ff       	call   800a52 <syscall>
}
  800b06:	c9                   	leave  
  800b07:	c3                   	ret    

00800b08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b0e:	6a 00                	push   $0x0
  800b10:	6a 00                	push   $0x0
  800b12:	6a 00                	push   $0x0
  800b14:	6a 00                	push   $0x0
  800b16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b20:	b8 02 00 00 00       	mov    $0x2,%eax
  800b25:	e8 28 ff ff ff       	call   800a52 <syscall>
}
  800b2a:	c9                   	leave  
  800b2b:	c3                   	ret    

00800b2c <sys_yield>:

void
sys_yield(void)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b32:	6a 00                	push   $0x0
  800b34:	6a 00                	push   $0x0
  800b36:	6a 00                	push   $0x0
  800b38:	6a 00                	push   $0x0
  800b3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b44:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b49:	e8 04 ff ff ff       	call   800a52 <syscall>
}
  800b4e:	83 c4 10             	add    $0x10,%esp
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b59:	6a 00                	push   $0x0
  800b5b:	6a 00                	push   $0x0
  800b5d:	ff 75 10             	pushl  0x10(%ebp)
  800b60:	ff 75 0c             	pushl  0xc(%ebp)
  800b63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b66:	ba 01 00 00 00       	mov    $0x1,%edx
  800b6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b70:	e8 dd fe ff ff       	call   800a52 <syscall>
}
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b7d:	ff 75 18             	pushl  0x18(%ebp)
  800b80:	ff 75 14             	pushl  0x14(%ebp)
  800b83:	ff 75 10             	pushl  0x10(%ebp)
  800b86:	ff 75 0c             	pushl  0xc(%ebp)
  800b89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b91:	b8 05 00 00 00       	mov    $0x5,%eax
  800b96:	e8 b7 fe ff ff       	call   800a52 <syscall>
}
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	6a 00                	push   $0x0
  800ba9:	ff 75 0c             	pushl  0xc(%ebp)
  800bac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800baf:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb4:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb9:	e8 94 fe ff ff       	call   800a52 <syscall>
}
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800bc6:	6a 00                	push   $0x0
  800bc8:	6a 00                	push   $0x0
  800bca:	6a 00                	push   $0x0
  800bcc:	ff 75 0c             	pushl  0xc(%ebp)
  800bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd2:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd7:	b8 08 00 00 00       	mov    $0x8,%eax
  800bdc:	e8 71 fe ff ff       	call   800a52 <syscall>
}
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	6a 00                	push   $0x0
  800bef:	ff 75 0c             	pushl  0xc(%ebp)
  800bf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf5:	ba 01 00 00 00       	mov    $0x1,%edx
  800bfa:	b8 09 00 00 00       	mov    $0x9,%eax
  800bff:	e8 4e fe ff ff       	call   800a52 <syscall>
}
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c0c:	6a 00                	push   $0x0
  800c0e:	ff 75 14             	pushl  0x14(%ebp)
  800c11:	ff 75 10             	pushl  0x10(%ebp)
  800c14:	ff 75 0c             	pushl  0xc(%ebp)
  800c17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c24:	e8 29 fe ff ff       	call   800a52 <syscall>
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c31:	6a 00                	push   $0x0
  800c33:	6a 00                	push   $0x0
  800c35:	6a 00                	push   $0x0
  800c37:	6a 00                	push   $0x0
  800c39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c41:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c46:	e8 07 fe ff ff       	call   800a52 <syscall>
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
	int r;

	void *addr = (void*)(pn << PGSHIFT);
  800c52:	89 d6                	mov    %edx,%esi
  800c54:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800c57:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800c5e:	89 ca                	mov    %ecx,%edx
  800c60:	83 e2 05             	and    $0x5,%edx
  800c63:	83 fa 05             	cmp    $0x5,%edx
  800c66:	75 5a                	jne    800cc2 <duppage+0x75>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800c68:	89 ca                	mov    %ecx,%edx
  800c6a:	83 e2 18             	and    $0x18,%edx
		perm |= PTE_PCD | PTE_PWT;
  800c6d:	83 fa 01             	cmp    $0x1,%edx
  800c70:	19 d2                	sbb    %edx,%edx
  800c72:	83 e2 e8             	and    $0xffffffe8,%edx
  800c75:	83 c2 1d             	add    $0x1d,%edx


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800c78:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800c7e:	74 68                	je     800ce8 <duppage+0x9b>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800c80:	89 d3                	mov    %edx,%ebx
  800c82:	80 cf 08             	or     $0x8,%bh
  800c85:	83 ec 0c             	sub    $0xc,%esp
  800c88:	53                   	push   %ebx
  800c89:	56                   	push   %esi
  800c8a:	50                   	push   %eax
  800c8b:	56                   	push   %esi
  800c8c:	6a 00                	push   $0x0
  800c8e:	e8 e4 fe ff ff       	call   800b77 <sys_page_map>
  800c93:	83 c4 20             	add    $0x20,%esp
  800c96:	85 c0                	test   %eax,%eax
  800c98:	78 3c                	js     800cd6 <duppage+0x89>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	53                   	push   %ebx
  800c9e:	56                   	push   %esi
  800c9f:	6a 00                	push   $0x0
  800ca1:	56                   	push   %esi
  800ca2:	6a 00                	push   $0x0
  800ca4:	e8 ce fe ff ff       	call   800b77 <sys_page_map>
  800ca9:	83 c4 20             	add    $0x20,%esp
  800cac:	85 c0                	test   %eax,%eax
  800cae:	79 4d                	jns    800cfd <duppage+0xb0>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800cb0:	50                   	push   %eax
  800cb1:	68 cc 17 80 00       	push   $0x8017cc
  800cb6:	6a 57                	push   $0x57
  800cb8:	68 c1 18 80 00       	push   $0x8018c1
  800cbd:	e8 f8 04 00 00       	call   8011ba <_panic>
		panic("duppage: copy a non-present or non-user page");
  800cc2:	83 ec 04             	sub    $0x4,%esp
  800cc5:	68 70 17 80 00       	push   $0x801770
  800cca:	6a 47                	push   $0x47
  800ccc:	68 c1 18 80 00       	push   $0x8018c1
  800cd1:	e8 e4 04 00 00       	call   8011ba <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800cd6:	50                   	push   %eax
  800cd7:	68 a0 17 80 00       	push   $0x8017a0
  800cdc:	6a 53                	push   $0x53
  800cde:	68 c1 18 80 00       	push   $0x8018c1
  800ce3:	e8 d2 04 00 00       	call   8011ba <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	52                   	push   %edx
  800cec:	56                   	push   %esi
  800ced:	50                   	push   %eax
  800cee:	56                   	push   %esi
  800cef:	6a 00                	push   $0x0
  800cf1:	e8 81 fe ff ff       	call   800b77 <sys_page_map>
  800cf6:	83 c4 20             	add    $0x20,%esp
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	78 0c                	js     800d09 <duppage+0xbc>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800d02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800d09:	50                   	push   %eax
  800d0a:	68 f4 17 80 00       	push   $0x8017f4
  800d0f:	6a 5b                	push   $0x5b
  800d11:	68 c1 18 80 00       	push   $0x8018c1
  800d16:	e8 9f 04 00 00       	call   8011ba <_panic>

00800d1b <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void*)(pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800d26:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800d2d:	a8 01                	test   $0x1,%al
  800d2f:	74 38                	je     800d69 <dup_or_share+0x4e>
  800d31:	89 cb                	mov    %ecx,%ebx
  800d33:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800d35:	21 c3                	and    %eax,%ebx
  800d37:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
  800d3a:	89 c1                	mov    %eax,%ecx
  800d3c:	83 e1 18             	and    $0x18,%ecx
		perm |= PTE_PCD | PTE_PWT;
  800d3f:	89 da                	mov    %ebx,%edx
  800d41:	83 ca 18             	or     $0x18,%edx
  800d44:	85 c9                	test   %ecx,%ecx
  800d46:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void*)(pnum << PGSHIFT);
  800d49:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800d4c:	83 e0 1a             	and    $0x1a,%eax
  800d4f:	83 f8 02             	cmp    $0x2,%eax
  800d52:	74 32                	je     800d86 <dup_or_share+0x6b>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d54:	83 ec 0c             	sub    $0xc,%esp
  800d57:	53                   	push   %ebx
  800d58:	56                   	push   %esi
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	6a 00                	push   $0x0
  800d5d:	e8 15 fe ff ff       	call   800b77 <sys_page_map>
  800d62:	83 c4 20             	add    $0x20,%esp
  800d65:	85 c0                	test   %eax,%eax
  800d67:	78 08                	js     800d71 <dup_or_share+0x56>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800d71:	50                   	push   %eax
  800d72:	68 20 18 80 00       	push   $0x801820
  800d77:	68 84 00 00 00       	push   $0x84
  800d7c:	68 c1 18 80 00       	push   $0x8018c1
  800d81:	e8 34 04 00 00       	call   8011ba <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	53                   	push   %ebx
  800d8a:	56                   	push   %esi
  800d8b:	57                   	push   %edi
  800d8c:	e8 c2 fd ff ff       	call   800b53 <sys_page_alloc>
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	78 57                	js     800def <dup_or_share+0xd4>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	53                   	push   %ebx
  800d9c:	68 00 00 40 00       	push   $0x400000
  800da1:	6a 00                	push   $0x0
  800da3:	56                   	push   %esi
  800da4:	57                   	push   %edi
  800da5:	e8 cd fd ff ff       	call   800b77 <sys_page_map>
  800daa:	83 c4 20             	add    $0x20,%esp
  800dad:	85 c0                	test   %eax,%eax
  800daf:	78 53                	js     800e04 <dup_or_share+0xe9>
		memmove(UTEMP, addr, PGSIZE);
  800db1:	83 ec 04             	sub    $0x4,%esp
  800db4:	68 00 10 00 00       	push   $0x1000
  800db9:	56                   	push   %esi
  800dba:	68 00 00 40 00       	push   $0x400000
  800dbf:	e8 df fa ff ff       	call   8008a3 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800dc4:	83 c4 08             	add    $0x8,%esp
  800dc7:	68 00 00 40 00       	push   $0x400000
  800dcc:	6a 00                	push   $0x0
  800dce:	e8 ca fd ff ff       	call   800b9d <sys_page_unmap>
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	79 8f                	jns    800d69 <dup_or_share+0x4e>
			panic("sys_page_unmap: %e", r);
  800dda:	50                   	push   %eax
  800ddb:	68 0b 19 80 00       	push   $0x80190b
  800de0:	68 8d 00 00 00       	push   $0x8d
  800de5:	68 c1 18 80 00       	push   $0x8018c1
  800dea:	e8 cb 03 00 00       	call   8011ba <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800def:	50                   	push   %eax
  800df0:	68 40 18 80 00       	push   $0x801840
  800df5:	68 88 00 00 00       	push   $0x88
  800dfa:	68 c1 18 80 00       	push   $0x8018c1
  800dff:	e8 b6 03 00 00       	call   8011ba <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e04:	50                   	push   %eax
  800e05:	68 20 18 80 00       	push   $0x801820
  800e0a:	68 8a 00 00 00       	push   $0x8a
  800e0f:	68 c1 18 80 00       	push   $0x8018c1
  800e14:	e8 a1 03 00 00       	call   8011ba <_panic>

00800e19 <pgfault>:
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t)addr) >> PGSHIFT];
  800e25:	89 d8                	mov    %ebx,%eax
  800e27:	c1 e8 0c             	shr    $0xc,%eax
  800e2a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800e31:	6a 07                	push   $0x7
  800e33:	68 00 f0 7f 00       	push   $0x7ff000
  800e38:	6a 00                	push   $0x0
  800e3a:	e8 14 fd ff ff       	call   800b53 <sys_page_alloc>
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	85 c0                	test   %eax,%eax
  800e44:	78 51                	js     800e97 <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800e46:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	68 00 10 00 00       	push   $0x1000
  800e54:	53                   	push   %ebx
  800e55:	68 00 f0 7f 00       	push   $0x7ff000
  800e5a:	e8 44 fa ff ff       	call   8008a3 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800e5f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e66:	53                   	push   %ebx
  800e67:	6a 00                	push   $0x0
  800e69:	68 00 f0 7f 00       	push   $0x7ff000
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 02 fd ff ff       	call   800b77 <sys_page_map>
  800e75:	83 c4 20             	add    $0x20,%esp
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	78 2d                	js     800ea9 <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e7c:	83 ec 08             	sub    $0x8,%esp
  800e7f:	68 00 f0 7f 00       	push   $0x7ff000
  800e84:	6a 00                	push   $0x0
  800e86:	e8 12 fd ff ff       	call   800b9d <sys_page_unmap>
  800e8b:	83 c4 10             	add    $0x10,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 29                	js     800ebb <pgfault+0xa2>
}
  800e92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800e97:	50                   	push   %eax
  800e98:	68 cc 18 80 00       	push   $0x8018cc
  800e9d:	6a 27                	push   $0x27
  800e9f:	68 c1 18 80 00       	push   $0x8018c1
  800ea4:	e8 11 03 00 00       	call   8011ba <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800ea9:	50                   	push   %eax
  800eaa:	68 e8 18 80 00       	push   $0x8018e8
  800eaf:	6a 2c                	push   $0x2c
  800eb1:	68 c1 18 80 00       	push   $0x8018c1
  800eb6:	e8 ff 02 00 00       	call   8011ba <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800ebb:	50                   	push   %eax
  800ebc:	68 02 19 80 00       	push   $0x801902
  800ec1:	6a 2f                	push   $0x2f
  800ec3:	68 c1 18 80 00       	push   $0x8018c1
  800ec8:	e8 ed 02 00 00       	call   8011ba <_panic>

00800ecd <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed6:	b8 07 00 00 00       	mov    $0x7,%eax
  800edb:	cd 30                	int    $0x30
  800edd:	89 c7                	mov    %eax,%edi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	78 24                	js     800f07 <fork_v0+0x3a>
  800ee3:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800ee5:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800eea:	85 c0                	test   %eax,%eax
  800eec:	75 39                	jne    800f27 <fork_v0+0x5a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eee:	e8 15 fc ff ff       	call   800b08 <sys_getenvid>
  800ef3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef8:	c1 e0 07             	shl    $0x7,%eax
  800efb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f00:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f05:	eb 56                	jmp    800f5d <fork_v0+0x90>
		panic("sys_exofork: %e", envid);
  800f07:	50                   	push   %eax
  800f08:	68 1e 19 80 00       	push   $0x80191e
  800f0d:	68 a2 00 00 00       	push   $0xa2
  800f12:	68 c1 18 80 00       	push   $0x8018c1
  800f17:	e8 9e 02 00 00       	call   8011ba <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f1c:	83 c3 01             	add    $0x1,%ebx
  800f1f:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800f25:	74 24                	je     800f4b <fork_v0+0x7e>
		pde_t pde = uvpd[pnum >> 10];
  800f27:	89 d8                	mov    %ebx,%eax
  800f29:	c1 e8 0a             	shr    $0xa,%eax
  800f2c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800f33:	83 e0 05             	and    $0x5,%eax
  800f36:	83 f8 05             	cmp    $0x5,%eax
  800f39:	75 e1                	jne    800f1c <fork_v0+0x4f>
			continue;
		dup_or_share(envid, pnum, perm);
  800f3b:	b9 07 00 00 00       	mov    $0x7,%ecx
  800f40:	89 da                	mov    %ebx,%edx
  800f42:	89 f0                	mov    %esi,%eax
  800f44:	e8 d2 fd ff ff       	call   800d1b <dup_or_share>
  800f49:	eb d1                	jmp    800f1c <fork_v0+0x4f>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800f4b:	83 ec 08             	sub    $0x8,%esp
  800f4e:	6a 02                	push   $0x2
  800f50:	57                   	push   %edi
  800f51:	e8 6a fc ff ff       	call   800bc0 <sys_env_set_status>
  800f56:	83 c4 10             	add    $0x10,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 0a                	js     800f67 <fork_v0+0x9a>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800f5d:	89 f8                	mov    %edi,%eax
  800f5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f62:	5b                   	pop    %ebx
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800f67:	50                   	push   %eax
  800f68:	68 2e 19 80 00       	push   $0x80192e
  800f6d:	68 b8 00 00 00       	push   $0xb8
  800f72:	68 c1 18 80 00       	push   $0x8018c1
  800f77:	e8 3e 02 00 00       	call   8011ba <_panic>

00800f7c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	57                   	push   %edi
  800f80:	56                   	push   %esi
  800f81:	53                   	push   %ebx
  800f82:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800f85:	68 19 0e 80 00       	push   $0x800e19
  800f8a:	e8 71 02 00 00       	call   801200 <set_pgfault_handler>
  800f8f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f94:	cd 30                	int    $0x30
  800f96:	89 c7                	mov    %eax,%edi

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 27                	js     800fc6 <fork+0x4a>
  800f9f:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fa1:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	75 44                	jne    800fee <fork+0x72>
		thisenv = &envs[ENVX(sys_getenvid())];
  800faa:	e8 59 fb ff ff       	call   800b08 <sys_getenvid>
  800faf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb4:	c1 e0 07             	shl    $0x7,%eax
  800fb7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fbc:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800fc1:	e9 98 00 00 00       	jmp    80105e <fork+0xe2>
		panic("sys_exofork: %e", envid);
  800fc6:	50                   	push   %eax
  800fc7:	68 1e 19 80 00       	push   $0x80191e
  800fcc:	68 d6 00 00 00       	push   $0xd6
  800fd1:	68 c1 18 80 00       	push   $0x8018c1
  800fd6:	e8 df 01 00 00       	call   8011ba <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fdb:	83 c3 01             	add    $0x1,%ebx
  800fde:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800fe4:	77 36                	ja     80101c <fork+0xa0>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  800fe6:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800fec:	74 ed                	je     800fdb <fork+0x5f>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  800fee:	89 d8                	mov    %ebx,%eax
  800ff0:	c1 e8 0a             	shr    $0xa,%eax
  800ff3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800ffa:	83 e0 05             	and    $0x5,%eax
  800ffd:	83 f8 05             	cmp    $0x5,%eax
  801000:	75 d9                	jne    800fdb <fork+0x5f>
			continue;

		pte_t pte = uvpt[pnum];
  801002:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  801009:	83 e0 05             	and    $0x5,%eax
  80100c:	83 f8 05             	cmp    $0x5,%eax
  80100f:	75 ca                	jne    800fdb <fork+0x5f>
			continue;
		duppage(envid, pnum);
  801011:	89 da                	mov    %ebx,%edx
  801013:	89 f0                	mov    %esi,%eax
  801015:	e8 33 fc ff ff       	call   800c4d <duppage>
  80101a:	eb bf                	jmp    800fdb <fork+0x5f>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void*)exstk, PTE_U | PTE_P | PTE_W);
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	6a 07                	push   $0x7
  801021:	68 00 f0 bf ee       	push   $0xeebff000
  801026:	57                   	push   %edi
  801027:	e8 27 fb ff ff       	call   800b53 <sys_page_alloc>
	if (r < 0)
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 35                	js     801068 <fork+0xec>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801033:	a1 04 20 80 00       	mov    0x802004,%eax
  801038:	8b 40 68             	mov    0x68(%eax),%eax
  80103b:	83 ec 08             	sub    $0x8,%esp
  80103e:	50                   	push   %eax
  80103f:	57                   	push   %edi
  801040:	e8 9e fb ff ff       	call   800be3 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	78 31                	js     80107d <fork+0x101>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80104c:	83 ec 08             	sub    $0x8,%esp
  80104f:	6a 02                	push   $0x2
  801051:	57                   	push   %edi
  801052:	e8 69 fb ff ff       	call   800bc0 <sys_env_set_status>
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 34                	js     801092 <fork+0x116>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  80105e:	89 f8                	mov    %edi,%eax
  801060:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801063:	5b                   	pop    %ebx
  801064:	5e                   	pop    %esi
  801065:	5f                   	pop    %edi
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  801068:	50                   	push   %eax
  801069:	68 64 18 80 00       	push   $0x801864
  80106e:	68 f3 00 00 00       	push   $0xf3
  801073:	68 c1 18 80 00       	push   $0x8018c1
  801078:	e8 3d 01 00 00       	call   8011ba <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  80107d:	50                   	push   %eax
  80107e:	68 90 18 80 00       	push   $0x801890
  801083:	68 f6 00 00 00       	push   $0xf6
  801088:	68 c1 18 80 00       	push   $0x8018c1
  80108d:	e8 28 01 00 00       	call   8011ba <_panic>
		panic("sys_env_set_status: %e", r);
  801092:	50                   	push   %eax
  801093:	68 2e 19 80 00       	push   $0x80192e
  801098:	68 f9 00 00 00       	push   $0xf9
  80109d:	68 c1 18 80 00       	push   $0x8018c1
  8010a2:	e8 13 01 00 00       	call   8011ba <_panic>

008010a7 <sfork>:

// Challenge!
int
sfork(void)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ad:	68 45 19 80 00       	push   $0x801945
  8010b2:	68 02 01 00 00       	push   $0x102
  8010b7:	68 c1 18 80 00       	push   $0x8018c1
  8010bc:	e8 f9 00 00 00       	call   8011ba <_panic>

008010c1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	56                   	push   %esi
  8010c5:	53                   	push   %ebx
  8010c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8010c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int err = sys_ipc_recv(pg);
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	ff 75 0c             	pushl  0xc(%ebp)
  8010d2:	e8 54 fb ff ff       	call   800c2b <sys_ipc_recv>

	if (from_env_store)
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 f6                	test   %esi,%esi
  8010dc:	74 14                	je     8010f2 <ipc_recv+0x31>
		*from_env_store = (!err) ? thisenv->env_ipc_from : 0;
  8010de:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	75 09                	jne    8010f0 <ipc_recv+0x2f>
  8010e7:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8010ed:	8b 52 78             	mov    0x78(%edx),%edx
  8010f0:	89 16                	mov    %edx,(%esi)

	if (perm_store)
  8010f2:	85 db                	test   %ebx,%ebx
  8010f4:	74 14                	je     80110a <ipc_recv+0x49>
		*perm_store = (!err) ? thisenv->env_ipc_perm : 0;
  8010f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	75 09                	jne    801108 <ipc_recv+0x47>
  8010ff:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801105:	8b 52 7c             	mov    0x7c(%edx),%edx
  801108:	89 13                	mov    %edx,(%ebx)

	if (!err) err = thisenv->env_ipc_value;
  80110a:	85 c0                	test   %eax,%eax
  80110c:	75 08                	jne    801116 <ipc_recv+0x55>
  80110e:	a1 04 20 80 00       	mov    0x802004,%eax
  801113:	8b 40 74             	mov    0x74(%eax),%eax
	
	return err;
}
  801116:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	57                   	push   %edi
  801121:	56                   	push   %esi
  801122:	53                   	push   %ebx
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	8b 75 0c             	mov    0xc(%ebp),%esi
  801129:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80112c:	8b 7d 14             	mov    0x14(%ebp),%edi
	if (!pg)
  80112f:	85 db                	test   %ebx,%ebx
		pg = (void*) UTOP;
  801131:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801136:	0f 44 d8             	cmove  %eax,%ebx
	int r = sys_ipc_try_send(to_env, val, pg, perm);
  801139:	57                   	push   %edi
  80113a:	53                   	push   %ebx
  80113b:	56                   	push   %esi
  80113c:	ff 75 08             	pushl  0x8(%ebp)
  80113f:	e8 c2 fa ff ff       	call   800c06 <sys_ipc_try_send>
	while (r == -E_IPC_NOT_RECV) {
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	eb 13                	jmp    80115c <ipc_send+0x3f>
		sys_yield();
  801149:	e8 de f9 ff ff       	call   800b2c <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80114e:	57                   	push   %edi
  80114f:	53                   	push   %ebx
  801150:	56                   	push   %esi
  801151:	ff 75 08             	pushl  0x8(%ebp)
  801154:	e8 ad fa ff ff       	call   800c06 <sys_ipc_try_send>
  801159:	83 c4 10             	add    $0x10,%esp
	while (r == -E_IPC_NOT_RECV) {
  80115c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80115f:	74 e8                	je     801149 <ipc_send+0x2c>
	}

	if (r < 0) panic("ipc_send: %e", r);
  801161:	85 c0                	test   %eax,%eax
  801163:	78 08                	js     80116d <ipc_send+0x50>
}
  801165:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5f                   	pop    %edi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    
	if (r < 0) panic("ipc_send: %e", r);
  80116d:	50                   	push   %eax
  80116e:	68 5b 19 80 00       	push   $0x80195b
  801173:	6a 39                	push   $0x39
  801175:	68 68 19 80 00       	push   $0x801968
  80117a:	e8 3b 00 00 00       	call   8011ba <_panic>

0080117f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801185:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	c1 e2 07             	shl    $0x7,%edx
  80118f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801195:	8b 52 50             	mov    0x50(%edx),%edx
  801198:	39 ca                	cmp    %ecx,%edx
  80119a:	74 11                	je     8011ad <ipc_find_env+0x2e>
	for (i = 0; i < NENV; i++)
  80119c:	83 c0 01             	add    $0x1,%eax
  80119f:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011a4:	75 e4                	jne    80118a <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8011a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ab:	eb 0b                	jmp    8011b8 <ipc_find_env+0x39>
			return envs[i].env_id;
  8011ad:	c1 e0 07             	shl    $0x7,%eax
  8011b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011b5:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8011bf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011c2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8011c8:	e8 3b f9 ff ff       	call   800b08 <sys_getenvid>
  8011cd:	83 ec 0c             	sub    $0xc,%esp
  8011d0:	ff 75 0c             	pushl  0xc(%ebp)
  8011d3:	ff 75 08             	pushl  0x8(%ebp)
  8011d6:	56                   	push   %esi
  8011d7:	50                   	push   %eax
  8011d8:	68 74 19 80 00       	push   $0x801974
  8011dd:	e8 cf ef ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011e2:	83 c4 18             	add    $0x18,%esp
  8011e5:	53                   	push   %ebx
  8011e6:	ff 75 10             	pushl  0x10(%ebp)
  8011e9:	e8 72 ef ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  8011ee:	c7 04 24 e7 14 80 00 	movl   $0x8014e7,(%esp)
  8011f5:	e8 b7 ef ff ff       	call   8001b1 <cprintf>
  8011fa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011fd:	cc                   	int3   
  8011fe:	eb fd                	jmp    8011fd <_panic+0x43>

00801200 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801206:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80120d:	74 0a                	je     801219 <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80120f:	8b 45 08             	mov    0x8(%ebp),%eax
  801212:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801217:	c9                   	leave  
  801218:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  801219:	83 ec 04             	sub    $0x4,%esp
  80121c:	6a 07                	push   $0x7
  80121e:	68 00 f0 bf ee       	push   $0xeebff000
  801223:	6a 00                	push   $0x0
  801225:	e8 29 f9 ff ff       	call   800b53 <sys_page_alloc>
		if (r < 0) return;
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 e6                	js     801217 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	68 49 12 80 00       	push   $0x801249
  801239:	6a 00                	push   $0x0
  80123b:	e8 a3 f9 ff ff       	call   800be3 <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	79 c8                	jns    80120f <set_pgfault_handler+0xf>
  801247:	eb ce                	jmp    801217 <set_pgfault_handler+0x17>

00801249 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801249:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80124a:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80124f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801251:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801254:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801258:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80125c:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  80125f:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  801261:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  801265:	58                   	pop    %eax
	popl %eax
  801266:	58                   	pop    %eax
	popal
  801267:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  801268:	83 c4 04             	add    $0x4,%esp
	popfl
  80126b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  80126c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  80126d:	c3                   	ret    
  80126e:	66 90                	xchg   %ax,%ax

00801270 <__udivdi3>:
  801270:	55                   	push   %ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 1c             	sub    $0x1c,%esp
  801277:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80127b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80127f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801283:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801287:	85 d2                	test   %edx,%edx
  801289:	75 35                	jne    8012c0 <__udivdi3+0x50>
  80128b:	39 f3                	cmp    %esi,%ebx
  80128d:	0f 87 bd 00 00 00    	ja     801350 <__udivdi3+0xe0>
  801293:	85 db                	test   %ebx,%ebx
  801295:	89 d9                	mov    %ebx,%ecx
  801297:	75 0b                	jne    8012a4 <__udivdi3+0x34>
  801299:	b8 01 00 00 00       	mov    $0x1,%eax
  80129e:	31 d2                	xor    %edx,%edx
  8012a0:	f7 f3                	div    %ebx
  8012a2:	89 c1                	mov    %eax,%ecx
  8012a4:	31 d2                	xor    %edx,%edx
  8012a6:	89 f0                	mov    %esi,%eax
  8012a8:	f7 f1                	div    %ecx
  8012aa:	89 c6                	mov    %eax,%esi
  8012ac:	89 e8                	mov    %ebp,%eax
  8012ae:	89 f7                	mov    %esi,%edi
  8012b0:	f7 f1                	div    %ecx
  8012b2:	89 fa                	mov    %edi,%edx
  8012b4:	83 c4 1c             	add    $0x1c,%esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	5f                   	pop    %edi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    
  8012bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	39 f2                	cmp    %esi,%edx
  8012c2:	77 7c                	ja     801340 <__udivdi3+0xd0>
  8012c4:	0f bd fa             	bsr    %edx,%edi
  8012c7:	83 f7 1f             	xor    $0x1f,%edi
  8012ca:	0f 84 98 00 00 00    	je     801368 <__udivdi3+0xf8>
  8012d0:	89 f9                	mov    %edi,%ecx
  8012d2:	b8 20 00 00 00       	mov    $0x20,%eax
  8012d7:	29 f8                	sub    %edi,%eax
  8012d9:	d3 e2                	shl    %cl,%edx
  8012db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012df:	89 c1                	mov    %eax,%ecx
  8012e1:	89 da                	mov    %ebx,%edx
  8012e3:	d3 ea                	shr    %cl,%edx
  8012e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8012e9:	09 d1                	or     %edx,%ecx
  8012eb:	89 f2                	mov    %esi,%edx
  8012ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f1:	89 f9                	mov    %edi,%ecx
  8012f3:	d3 e3                	shl    %cl,%ebx
  8012f5:	89 c1                	mov    %eax,%ecx
  8012f7:	d3 ea                	shr    %cl,%edx
  8012f9:	89 f9                	mov    %edi,%ecx
  8012fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012ff:	d3 e6                	shl    %cl,%esi
  801301:	89 eb                	mov    %ebp,%ebx
  801303:	89 c1                	mov    %eax,%ecx
  801305:	d3 eb                	shr    %cl,%ebx
  801307:	09 de                	or     %ebx,%esi
  801309:	89 f0                	mov    %esi,%eax
  80130b:	f7 74 24 08          	divl   0x8(%esp)
  80130f:	89 d6                	mov    %edx,%esi
  801311:	89 c3                	mov    %eax,%ebx
  801313:	f7 64 24 0c          	mull   0xc(%esp)
  801317:	39 d6                	cmp    %edx,%esi
  801319:	72 0c                	jb     801327 <__udivdi3+0xb7>
  80131b:	89 f9                	mov    %edi,%ecx
  80131d:	d3 e5                	shl    %cl,%ebp
  80131f:	39 c5                	cmp    %eax,%ebp
  801321:	73 5d                	jae    801380 <__udivdi3+0x110>
  801323:	39 d6                	cmp    %edx,%esi
  801325:	75 59                	jne    801380 <__udivdi3+0x110>
  801327:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80132a:	31 ff                	xor    %edi,%edi
  80132c:	89 fa                	mov    %edi,%edx
  80132e:	83 c4 1c             	add    $0x1c,%esp
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5f                   	pop    %edi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    
  801336:	8d 76 00             	lea    0x0(%esi),%esi
  801339:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801340:	31 ff                	xor    %edi,%edi
  801342:	31 c0                	xor    %eax,%eax
  801344:	89 fa                	mov    %edi,%edx
  801346:	83 c4 1c             	add    $0x1c,%esp
  801349:	5b                   	pop    %ebx
  80134a:	5e                   	pop    %esi
  80134b:	5f                   	pop    %edi
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    
  80134e:	66 90                	xchg   %ax,%ax
  801350:	31 ff                	xor    %edi,%edi
  801352:	89 e8                	mov    %ebp,%eax
  801354:	89 f2                	mov    %esi,%edx
  801356:	f7 f3                	div    %ebx
  801358:	89 fa                	mov    %edi,%edx
  80135a:	83 c4 1c             	add    $0x1c,%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5f                   	pop    %edi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    
  801362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801368:	39 f2                	cmp    %esi,%edx
  80136a:	72 06                	jb     801372 <__udivdi3+0x102>
  80136c:	31 c0                	xor    %eax,%eax
  80136e:	39 eb                	cmp    %ebp,%ebx
  801370:	77 d2                	ja     801344 <__udivdi3+0xd4>
  801372:	b8 01 00 00 00       	mov    $0x1,%eax
  801377:	eb cb                	jmp    801344 <__udivdi3+0xd4>
  801379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801380:	89 d8                	mov    %ebx,%eax
  801382:	31 ff                	xor    %edi,%edi
  801384:	eb be                	jmp    801344 <__udivdi3+0xd4>
  801386:	66 90                	xchg   %ax,%ax
  801388:	66 90                	xchg   %ax,%ax
  80138a:	66 90                	xchg   %ax,%ax
  80138c:	66 90                	xchg   %ax,%ax
  80138e:	66 90                	xchg   %ax,%ax

00801390 <__umoddi3>:
  801390:	55                   	push   %ebp
  801391:	57                   	push   %edi
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	83 ec 1c             	sub    $0x1c,%esp
  801397:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80139b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80139f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8013a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013a7:	85 ed                	test   %ebp,%ebp
  8013a9:	89 f0                	mov    %esi,%eax
  8013ab:	89 da                	mov    %ebx,%edx
  8013ad:	75 19                	jne    8013c8 <__umoddi3+0x38>
  8013af:	39 df                	cmp    %ebx,%edi
  8013b1:	0f 86 b1 00 00 00    	jbe    801468 <__umoddi3+0xd8>
  8013b7:	f7 f7                	div    %edi
  8013b9:	89 d0                	mov    %edx,%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	83 c4 1c             	add    $0x1c,%esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5e                   	pop    %esi
  8013c2:	5f                   	pop    %edi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    
  8013c5:	8d 76 00             	lea    0x0(%esi),%esi
  8013c8:	39 dd                	cmp    %ebx,%ebp
  8013ca:	77 f1                	ja     8013bd <__umoddi3+0x2d>
  8013cc:	0f bd cd             	bsr    %ebp,%ecx
  8013cf:	83 f1 1f             	xor    $0x1f,%ecx
  8013d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013d6:	0f 84 b4 00 00 00    	je     801490 <__umoddi3+0x100>
  8013dc:	b8 20 00 00 00       	mov    $0x20,%eax
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013e7:	29 c2                	sub    %eax,%edx
  8013e9:	89 c1                	mov    %eax,%ecx
  8013eb:	89 f8                	mov    %edi,%eax
  8013ed:	d3 e5                	shl    %cl,%ebp
  8013ef:	89 d1                	mov    %edx,%ecx
  8013f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013f5:	d3 e8                	shr    %cl,%eax
  8013f7:	09 c5                	or     %eax,%ebp
  8013f9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013fd:	89 c1                	mov    %eax,%ecx
  8013ff:	d3 e7                	shl    %cl,%edi
  801401:	89 d1                	mov    %edx,%ecx
  801403:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801407:	89 df                	mov    %ebx,%edi
  801409:	d3 ef                	shr    %cl,%edi
  80140b:	89 c1                	mov    %eax,%ecx
  80140d:	89 f0                	mov    %esi,%eax
  80140f:	d3 e3                	shl    %cl,%ebx
  801411:	89 d1                	mov    %edx,%ecx
  801413:	89 fa                	mov    %edi,%edx
  801415:	d3 e8                	shr    %cl,%eax
  801417:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80141c:	09 d8                	or     %ebx,%eax
  80141e:	f7 f5                	div    %ebp
  801420:	d3 e6                	shl    %cl,%esi
  801422:	89 d1                	mov    %edx,%ecx
  801424:	f7 64 24 08          	mull   0x8(%esp)
  801428:	39 d1                	cmp    %edx,%ecx
  80142a:	89 c3                	mov    %eax,%ebx
  80142c:	89 d7                	mov    %edx,%edi
  80142e:	72 06                	jb     801436 <__umoddi3+0xa6>
  801430:	75 0e                	jne    801440 <__umoddi3+0xb0>
  801432:	39 c6                	cmp    %eax,%esi
  801434:	73 0a                	jae    801440 <__umoddi3+0xb0>
  801436:	2b 44 24 08          	sub    0x8(%esp),%eax
  80143a:	19 ea                	sbb    %ebp,%edx
  80143c:	89 d7                	mov    %edx,%edi
  80143e:	89 c3                	mov    %eax,%ebx
  801440:	89 ca                	mov    %ecx,%edx
  801442:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801447:	29 de                	sub    %ebx,%esi
  801449:	19 fa                	sbb    %edi,%edx
  80144b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80144f:	89 d0                	mov    %edx,%eax
  801451:	d3 e0                	shl    %cl,%eax
  801453:	89 d9                	mov    %ebx,%ecx
  801455:	d3 ee                	shr    %cl,%esi
  801457:	d3 ea                	shr    %cl,%edx
  801459:	09 f0                	or     %esi,%eax
  80145b:	83 c4 1c             	add    $0x1c,%esp
  80145e:	5b                   	pop    %ebx
  80145f:	5e                   	pop    %esi
  801460:	5f                   	pop    %edi
  801461:	5d                   	pop    %ebp
  801462:	c3                   	ret    
  801463:	90                   	nop
  801464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801468:	85 ff                	test   %edi,%edi
  80146a:	89 f9                	mov    %edi,%ecx
  80146c:	75 0b                	jne    801479 <__umoddi3+0xe9>
  80146e:	b8 01 00 00 00       	mov    $0x1,%eax
  801473:	31 d2                	xor    %edx,%edx
  801475:	f7 f7                	div    %edi
  801477:	89 c1                	mov    %eax,%ecx
  801479:	89 d8                	mov    %ebx,%eax
  80147b:	31 d2                	xor    %edx,%edx
  80147d:	f7 f1                	div    %ecx
  80147f:	89 f0                	mov    %esi,%eax
  801481:	f7 f1                	div    %ecx
  801483:	e9 31 ff ff ff       	jmp    8013b9 <__umoddi3+0x29>
  801488:	90                   	nop
  801489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801490:	39 dd                	cmp    %ebx,%ebp
  801492:	72 08                	jb     80149c <__umoddi3+0x10c>
  801494:	39 f7                	cmp    %esi,%edi
  801496:	0f 87 21 ff ff ff    	ja     8013bd <__umoddi3+0x2d>
  80149c:	89 da                	mov    %ebx,%edx
  80149e:	89 f0                	mov    %esi,%eax
  8014a0:	29 f8                	sub    %edi,%eax
  8014a2:	19 ea                	sbb    %ebp,%edx
  8014a4:	e9 14 ff ff ff       	jmp    8013bd <__umoddi3+0x2d>
