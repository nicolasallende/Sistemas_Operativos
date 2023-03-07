
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 d2 00 00 00       	call   800103 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 a9 10 00 00       	call   8010ea <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 74                	jne    8000bc <umain+0x89>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800048:	83 ec 04             	sub    $0x4,%esp
  80004b:	6a 00                	push   $0x0
  80004d:	6a 00                	push   $0x0
  80004f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	e8 ac 10 00 00       	call   801104 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800058:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80005e:	8b 7b 48             	mov    0x48(%ebx),%edi
  800061:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800064:	a1 04 20 80 00       	mov    0x802004,%eax
  800069:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006c:	e8 da 0a 00 00       	call   800b4b <sys_getenvid>
  800071:	83 c4 08             	add    $0x8,%esp
  800074:	57                   	push   %edi
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007a:	50                   	push   %eax
  80007b:	68 30 15 80 00       	push   $0x801530
  800080:	e8 6f 01 00 00       	call   8001f4 <cprintf>
		if (val == 10)
  800085:	a1 04 20 80 00       	mov    0x802004,%eax
  80008a:	83 c4 20             	add    $0x20,%esp
  80008d:	83 f8 0a             	cmp    $0xa,%eax
  800090:	74 22                	je     8000b4 <umain+0x81>
			return;
		++val;
  800092:	83 c0 01             	add    $0x1,%eax
  800095:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80009a:	6a 00                	push   $0x0
  80009c:	6a 00                	push   $0x0
  80009e:	6a 00                	push   $0x0
  8000a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a3:	e8 b8 10 00 00       	call   801160 <ipc_send>
		if (val == 10)
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000b2:	75 94                	jne    800048 <umain+0x15>
			return;
	}

}
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000bc:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c2:	e8 84 0a 00 00       	call   800b4b <sys_getenvid>
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	50                   	push   %eax
  8000cc:	68 00 15 80 00       	push   $0x801500
  8000d1:	e8 1e 01 00 00       	call   8001f4 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 6d 0a 00 00       	call   800b4b <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 1a 15 80 00       	push   $0x80151a
  8000e8:	e8 07 01 00 00       	call   8001f4 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000f6:	e8 65 10 00 00       	call   801160 <ipc_send>
  8000fb:	83 c4 20             	add    $0x20,%esp
  8000fe:	e9 45 ff ff ff       	jmp    800048 <umain+0x15>

00800103 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80010e:	e8 38 0a 00 00       	call   800b4b <sys_getenvid>
	if (id >= 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	78 12                	js     800129 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800117:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011c:	c1 e0 07             	shl    $0x7,%eax
  80011f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800124:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800129:	85 db                	test   %ebx,%ebx
  80012b:	7e 07                	jle    800134 <libmain+0x31>
		binaryname = argv[0];
  80012d:	8b 06                	mov    (%esi),%eax
  80012f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	e8 f5 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013e:	e8 0a 00 00 00       	call   80014d <exit>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800153:	6a 00                	push   $0x0
  800155:	e8 cf 09 00 00       	call   800b29 <sys_env_destroy>
}
  80015a:	83 c4 10             	add    $0x10,%esp
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	53                   	push   %ebx
  800163:	83 ec 04             	sub    $0x4,%esp
  800166:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800169:	8b 13                	mov    (%ebx),%edx
  80016b:	8d 42 01             	lea    0x1(%edx),%eax
  80016e:	89 03                	mov    %eax,(%ebx)
  800170:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800173:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800177:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017c:	74 09                	je     800187 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800185:	c9                   	leave  
  800186:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 47 09 00 00       	call   800adf <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb db                	jmp    80017e <putch+0x1f>

008001a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	ff 75 0c             	pushl  0xc(%ebp)
  8001c3:	ff 75 08             	pushl  0x8(%ebp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	50                   	push   %eax
  8001cd:	68 5f 01 80 00       	push   $0x80015f
  8001d2:	e8 86 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d7:	83 c4 08             	add    $0x8,%esp
  8001da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e6:	50                   	push   %eax
  8001e7:	e8 f3 08 00 00       	call   800adf <sys_cputs>

	return b.cnt;
}
  8001ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fd:	50                   	push   %eax
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	e8 9d ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	83 ec 1c             	sub    $0x1c,%esp
  800211:	89 c7                	mov    %eax,%edi
  800213:	89 d6                	mov    %edx,%esi
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800221:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800224:	bb 00 00 00 00       	mov    $0x0,%ebx
  800229:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022f:	39 d3                	cmp    %edx,%ebx
  800231:	72 05                	jb     800238 <printnum+0x30>
  800233:	39 45 10             	cmp    %eax,0x10(%ebp)
  800236:	77 7a                	ja     8002b2 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	ff 75 18             	pushl  0x18(%ebp)
  80023e:	8b 45 14             	mov    0x14(%ebp),%eax
  800241:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800244:	53                   	push   %ebx
  800245:	ff 75 10             	pushl  0x10(%ebp)
  800248:	83 ec 08             	sub    $0x8,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 64 10 00 00       	call   8012c0 <__udivdi3>
  80025c:	83 c4 18             	add    $0x18,%esp
  80025f:	52                   	push   %edx
  800260:	50                   	push   %eax
  800261:	89 f2                	mov    %esi,%edx
  800263:	89 f8                	mov    %edi,%eax
  800265:	e8 9e ff ff ff       	call   800208 <printnum>
  80026a:	83 c4 20             	add    $0x20,%esp
  80026d:	eb 13                	jmp    800282 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	56                   	push   %esi
  800273:	ff 75 18             	pushl  0x18(%ebp)
  800276:	ff d7                	call   *%edi
  800278:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80027b:	83 eb 01             	sub    $0x1,%ebx
  80027e:	85 db                	test   %ebx,%ebx
  800280:	7f ed                	jg     80026f <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	56                   	push   %esi
  800286:	83 ec 04             	sub    $0x4,%esp
  800289:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028c:	ff 75 e0             	pushl  -0x20(%ebp)
  80028f:	ff 75 dc             	pushl  -0x24(%ebp)
  800292:	ff 75 d8             	pushl  -0x28(%ebp)
  800295:	e8 46 11 00 00       	call   8013e0 <__umoddi3>
  80029a:	83 c4 14             	add    $0x14,%esp
  80029d:	0f be 80 60 15 80 00 	movsbl 0x801560(%eax),%eax
  8002a4:	50                   	push   %eax
  8002a5:	ff d7                	call   *%edi
}
  8002a7:	83 c4 10             	add    $0x10,%esp
  8002aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    
  8002b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b5:	eb c4                	jmp    80027b <printnum+0x73>

008002b7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ba:	83 fa 01             	cmp    $0x1,%edx
  8002bd:	7e 0e                	jle    8002cd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 02                	mov    (%edx),%eax
  8002c8:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    
	else if (lflag)
  8002cd:	85 d2                	test   %edx,%edx
  8002cf:	75 10                	jne    8002e1 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 02                	mov    (%edx),%eax
  8002da:	ba 00 00 00 00       	mov    $0x0,%edx
  8002df:	eb ea                	jmp    8002cb <getuint+0x14>
		return va_arg(*ap, unsigned long);
  8002e1:	8b 10                	mov    (%eax),%edx
  8002e3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e6:	89 08                	mov    %ecx,(%eax)
  8002e8:	8b 02                	mov    (%edx),%eax
  8002ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ef:	eb da                	jmp    8002cb <getuint+0x14>

008002f1 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f4:	83 fa 01             	cmp    $0x1,%edx
  8002f7:	7e 0e                	jle    800307 <getint+0x16>
		return va_arg(*ap, long long);
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 02                	mov    (%edx),%eax
  800302:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    
	else if (lflag)
  800307:	85 d2                	test   %edx,%edx
  800309:	75 0c                	jne    800317 <getint+0x26>
		return va_arg(*ap, int);
  80030b:	8b 10                	mov    (%eax),%edx
  80030d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800310:	89 08                	mov    %ecx,(%eax)
  800312:	8b 02                	mov    (%edx),%eax
  800314:	99                   	cltd   
  800315:	eb ee                	jmp    800305 <getint+0x14>
		return va_arg(*ap, long);
  800317:	8b 10                	mov    (%eax),%edx
  800319:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031c:	89 08                	mov    %ecx,(%eax)
  80031e:	8b 02                	mov    (%edx),%eax
  800320:	99                   	cltd   
  800321:	eb e2                	jmp    800305 <getint+0x14>

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800369:	8b 75 0c             	mov    0xc(%ebp),%esi
  80036c:	89 f7                	mov    %esi,%edi
  80036e:	89 de                	mov    %ebx,%esi
  800370:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800373:	e9 9e 02 00 00       	jmp    800616 <vprintfmt+0x2b9>
		padc = ' ';
  800378:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80037c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800383:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80038a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800391:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8d 43 01             	lea    0x1(%ebx),%eax
  800399:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039c:	0f b6 0b             	movzbl (%ebx),%ecx
  80039f:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8003a2:	3c 55                	cmp    $0x55,%al
  8003a4:	0f 87 e8 02 00 00    	ja     800692 <vprintfmt+0x335>
  8003aa:	0f b6 c0             	movzbl %al,%eax
  8003ad:	ff 24 85 20 16 80 00 	jmp    *0x801620(,%eax,4)
  8003b4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  8003b7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003bb:	eb d9                	jmp    800396 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  8003c0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c4:	eb d0                	jmp    800396 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	0f b6 c9             	movzbl %cl,%ecx
  8003c9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003db:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8003de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e1:	83 fa 09             	cmp    $0x9,%edx
  8003e4:	77 52                	ja     800438 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  8003e6:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8003e9:	eb e9                	jmp    8003d4 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f4:	8b 00                	mov    (%eax),%eax
  8003f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  8003fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800400:	79 94                	jns    800396 <vprintfmt+0x39>
				width = precision, precision = -1;
  800402:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800405:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800408:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040f:	eb 85                	jmp    800396 <vprintfmt+0x39>
  800411:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800414:	85 c0                	test   %eax,%eax
  800416:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041b:	0f 49 c8             	cmovns %eax,%ecx
  80041e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800424:	e9 6d ff ff ff       	jmp    800396 <vprintfmt+0x39>
  800429:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80042c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800433:	e9 5e ff ff ff       	jmp    800396 <vprintfmt+0x39>
  800438:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80043e:	eb bc                	jmp    8003fc <vprintfmt+0x9f>
			lflag++;
  800440:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800446:	e9 4b ff ff ff       	jmp    800396 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 50 04             	lea    0x4(%eax),%edx
  800451:	89 55 14             	mov    %edx,0x14(%ebp)
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	57                   	push   %edi
  800458:	ff 30                	pushl  (%eax)
  80045a:	ff d6                	call   *%esi
			break;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	e9 af 01 00 00       	jmp    800613 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	8b 00                	mov    (%eax),%eax
  80046f:	99                   	cltd   
  800470:	31 d0                	xor    %edx,%eax
  800472:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800474:	83 f8 08             	cmp    $0x8,%eax
  800477:	7f 20                	jg     800499 <vprintfmt+0x13c>
  800479:	8b 14 85 80 17 80 00 	mov    0x801780(,%eax,4),%edx
  800480:	85 d2                	test   %edx,%edx
  800482:	74 15                	je     800499 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800484:	52                   	push   %edx
  800485:	68 81 15 80 00       	push   $0x801581
  80048a:	57                   	push   %edi
  80048b:	56                   	push   %esi
  80048c:	e8 af fe ff ff       	call   800340 <printfmt>
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	e9 7a 01 00 00       	jmp    800613 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800499:	50                   	push   %eax
  80049a:	68 78 15 80 00       	push   $0x801578
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	e8 9a fe ff ff       	call   800340 <printfmt>
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	e9 65 01 00 00       	jmp    800613 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  8004b9:	85 db                	test   %ebx,%ebx
  8004bb:	b8 71 15 80 00       	mov    $0x801571,%eax
  8004c0:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  8004c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c7:	0f 8e bd 00 00 00    	jle    80058a <vprintfmt+0x22d>
  8004cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d1:	75 0e                	jne    8004e1 <vprintfmt+0x184>
  8004d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d9:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004df:	eb 6d                	jmp    80054e <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	ff 75 d0             	pushl  -0x30(%ebp)
  8004e7:	53                   	push   %ebx
  8004e8:	e8 4d 02 00 00       	call   80073a <strnlen>
  8004ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f0:	29 c1                	sub    %eax,%ecx
  8004f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ff:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800502:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800504:	eb 0f                	jmp    800515 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	57                   	push   %edi
  80050a:	ff 75 e0             	pushl  -0x20(%ebp)
  80050d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80050f:	83 eb 01             	sub    $0x1,%ebx
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	85 db                	test   %ebx,%ebx
  800517:	7f ed                	jg     800506 <vprintfmt+0x1a9>
  800519:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80051c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051f:	85 c9                	test   %ecx,%ecx
  800521:	b8 00 00 00 00       	mov    $0x0,%eax
  800526:	0f 49 c1             	cmovns %ecx,%eax
  800529:	29 c1                	sub    %eax,%ecx
  80052b:	89 75 08             	mov    %esi,0x8(%ebp)
  80052e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800531:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800534:	89 cf                	mov    %ecx,%edi
  800536:	eb 16                	jmp    80054e <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800538:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053c:	75 31                	jne    80056f <vprintfmt+0x212>
					putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	50                   	push   %eax
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054b:	83 ef 01             	sub    $0x1,%edi
  80054e:	83 c3 01             	add    $0x1,%ebx
  800551:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  800555:	0f be c2             	movsbl %dl,%eax
  800558:	85 c0                	test   %eax,%eax
  80055a:	74 50                	je     8005ac <vprintfmt+0x24f>
  80055c:	85 f6                	test   %esi,%esi
  80055e:	78 d8                	js     800538 <vprintfmt+0x1db>
  800560:	83 ee 01             	sub    $0x1,%esi
  800563:	79 d3                	jns    800538 <vprintfmt+0x1db>
  800565:	89 fb                	mov    %edi,%ebx
  800567:	8b 75 08             	mov    0x8(%ebp),%esi
  80056a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80056d:	eb 37                	jmp    8005a6 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  80056f:	0f be d2             	movsbl %dl,%edx
  800572:	83 ea 20             	sub    $0x20,%edx
  800575:	83 fa 5e             	cmp    $0x5e,%edx
  800578:	76 c4                	jbe    80053e <vprintfmt+0x1e1>
					putch('?', putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	ff 75 0c             	pushl  0xc(%ebp)
  800580:	6a 3f                	push   $0x3f
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	eb c1                	jmp    80054b <vprintfmt+0x1ee>
  80058a:	89 75 08             	mov    %esi,0x8(%ebp)
  80058d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800590:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800593:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800596:	eb b6                	jmp    80054e <vprintfmt+0x1f1>
				putch(' ', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	57                   	push   %edi
  80059c:	6a 20                	push   $0x20
  80059e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005a0:	83 eb 01             	sub    $0x1,%ebx
  8005a3:	83 c4 10             	add    $0x10,%esp
  8005a6:	85 db                	test   %ebx,%ebx
  8005a8:	7f ee                	jg     800598 <vprintfmt+0x23b>
  8005aa:	eb 67                	jmp    800613 <vprintfmt+0x2b6>
  8005ac:	89 fb                	mov    %edi,%ebx
  8005ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005b4:	eb f0                	jmp    8005a6 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  8005b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b9:	e8 33 fd ff ff       	call   8002f1 <getint>
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8005c9:	85 d2                	test   %edx,%edx
  8005cb:	79 2c                	jns    8005f9 <vprintfmt+0x29c>
				putch('-', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	57                   	push   %edi
  8005d1:	6a 2d                	push   $0x2d
  8005d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005db:	f7 d8                	neg    %eax
  8005dd:	83 d2 00             	adc    $0x0,%edx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ea:	eb 0d                	jmp    8005f9 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 c3 fc ff ff       	call   8002b7 <getuint>
			base = 10;
  8005f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  800600:	53                   	push   %ebx
  800601:	ff 75 e0             	pushl  -0x20(%ebp)
  800604:	51                   	push   %ecx
  800605:	52                   	push   %edx
  800606:	50                   	push   %eax
  800607:	89 fa                	mov    %edi,%edx
  800609:	89 f0                	mov    %esi,%eax
  80060b:	e8 f8 fb ff ff       	call   800208 <printnum>
			break;
  800610:	83 c4 20             	add    $0x20,%esp
{
  800613:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800616:	83 c3 01             	add    $0x1,%ebx
  800619:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  80061d:	83 f8 25             	cmp    $0x25,%eax
  800620:	0f 84 52 fd ff ff    	je     800378 <vprintfmt+0x1b>
			if (ch == '\0')
  800626:	85 c0                	test   %eax,%eax
  800628:	0f 84 84 00 00 00    	je     8006b2 <vprintfmt+0x355>
			putch(ch, putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	57                   	push   %edi
  800632:	50                   	push   %eax
  800633:	ff d6                	call   *%esi
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	eb dc                	jmp    800616 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 75 fc ff ff       	call   8002b7 <getuint>
			base = 8;
  800642:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800647:	eb b0                	jmp    8005f9 <vprintfmt+0x29c>
			putch('0', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	57                   	push   %edi
  80064d:	6a 30                	push   $0x30
  80064f:	ff d6                	call   *%esi
			putch('x', putdat);
  800651:	83 c4 08             	add    $0x8,%esp
  800654:	57                   	push   %edi
  800655:	6a 78                	push   $0x78
  800657:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 50 04             	lea    0x4(%eax),%edx
  80065f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800662:	8b 00                	mov    (%eax),%eax
  800664:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800669:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80066c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800671:	eb 86                	jmp    8005f9 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 3c fc ff ff       	call   8002b7 <getuint>
			base = 16;
  80067b:	b9 10 00 00 00       	mov    $0x10,%ecx
  800680:	e9 74 ff ff ff       	jmp    8005f9 <vprintfmt+0x29c>
			putch(ch, putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	57                   	push   %edi
  800689:	6a 25                	push   $0x25
  80068b:	ff d6                	call   *%esi
			break;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	eb 81                	jmp    800613 <vprintfmt+0x2b6>
			putch('%', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	57                   	push   %edi
  800696:	6a 25                	push   $0x25
  800698:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	89 d8                	mov    %ebx,%eax
  80069f:	eb 03                	jmp    8006a4 <vprintfmt+0x347>
  8006a1:	83 e8 01             	sub    $0x1,%eax
  8006a4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a8:	75 f7                	jne    8006a1 <vprintfmt+0x344>
  8006aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ad:	e9 61 ff ff ff       	jmp    800613 <vprintfmt+0x2b6>
}
  8006b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b5:	5b                   	pop    %ebx
  8006b6:	5e                   	pop    %esi
  8006b7:	5f                   	pop    %edi
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	83 ec 18             	sub    $0x18,%esp
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	74 26                	je     800701 <vsnprintf+0x47>
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	7e 22                	jle    800701 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006df:	ff 75 14             	pushl  0x14(%ebp)
  8006e2:	ff 75 10             	pushl  0x10(%ebp)
  8006e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e8:	50                   	push   %eax
  8006e9:	68 23 03 80 00       	push   $0x800323
  8006ee:	e8 6a fc ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fc:	83 c4 10             	add    $0x10,%esp
}
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    
		return -E_INVAL;
  800701:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800706:	eb f7                	jmp    8006ff <vsnprintf+0x45>

00800708 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800711:	50                   	push   %eax
  800712:	ff 75 10             	pushl  0x10(%ebp)
  800715:	ff 75 0c             	pushl  0xc(%ebp)
  800718:	ff 75 08             	pushl  0x8(%ebp)
  80071b:	e8 9a ff ff ff       	call   8006ba <vsnprintf>
	va_end(ap);

	return rc;
}
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800728:	b8 00 00 00 00       	mov    $0x0,%eax
  80072d:	eb 03                	jmp    800732 <strlen+0x10>
		n++;
  80072f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800732:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800736:	75 f7                	jne    80072f <strlen+0xd>
	return n;
}
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800740:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	eb 03                	jmp    80074d <strnlen+0x13>
		n++;
  80074a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074d:	39 d0                	cmp    %edx,%eax
  80074f:	74 06                	je     800757 <strnlen+0x1d>
  800751:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800755:	75 f3                	jne    80074a <strnlen+0x10>
	return n;
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800763:	89 c2                	mov    %eax,%edx
  800765:	83 c1 01             	add    $0x1,%ecx
  800768:	83 c2 01             	add    $0x1,%edx
  80076b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800772:	84 db                	test   %bl,%bl
  800774:	75 ef                	jne    800765 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800776:	5b                   	pop    %ebx
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	53                   	push   %ebx
  80077d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800780:	53                   	push   %ebx
  800781:	e8 9c ff ff ff       	call   800722 <strlen>
  800786:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	01 d8                	add    %ebx,%eax
  80078e:	50                   	push   %eax
  80078f:	e8 c5 ff ff ff       	call   800759 <strcpy>
	return dst;
}
  800794:	89 d8                	mov    %ebx,%eax
  800796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a6:	89 f3                	mov    %esi,%ebx
  8007a8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ab:	89 f2                	mov    %esi,%edx
  8007ad:	eb 0f                	jmp    8007be <strncpy+0x23>
		*dst++ = *src;
  8007af:	83 c2 01             	add    $0x1,%edx
  8007b2:	0f b6 01             	movzbl (%ecx),%eax
  8007b5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bb:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007be:	39 da                	cmp    %ebx,%edx
  8007c0:	75 ed                	jne    8007af <strncpy+0x14>
	}
	return ret;
}
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	56                   	push   %esi
  8007cc:	53                   	push   %ebx
  8007cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007d6:	89 f0                	mov    %esi,%eax
  8007d8:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007dc:	85 c9                	test   %ecx,%ecx
  8007de:	75 0b                	jne    8007eb <strlcpy+0x23>
  8007e0:	eb 17                	jmp    8007f9 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e2:	83 c2 01             	add    $0x1,%edx
  8007e5:	83 c0 01             	add    $0x1,%eax
  8007e8:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8007eb:	39 d8                	cmp    %ebx,%eax
  8007ed:	74 07                	je     8007f6 <strlcpy+0x2e>
  8007ef:	0f b6 0a             	movzbl (%edx),%ecx
  8007f2:	84 c9                	test   %cl,%cl
  8007f4:	75 ec                	jne    8007e2 <strlcpy+0x1a>
		*dst = '\0';
  8007f6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f9:	29 f0                	sub    %esi,%eax
}
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800808:	eb 06                	jmp    800810 <strcmp+0x11>
		p++, q++;
  80080a:	83 c1 01             	add    $0x1,%ecx
  80080d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800810:	0f b6 01             	movzbl (%ecx),%eax
  800813:	84 c0                	test   %al,%al
  800815:	74 04                	je     80081b <strcmp+0x1c>
  800817:	3a 02                	cmp    (%edx),%al
  800819:	74 ef                	je     80080a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081b:	0f b6 c0             	movzbl %al,%eax
  80081e:	0f b6 12             	movzbl (%edx),%edx
  800821:	29 d0                	sub    %edx,%eax
}
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082f:	89 c3                	mov    %eax,%ebx
  800831:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800834:	eb 06                	jmp    80083c <strncmp+0x17>
		n--, p++, q++;
  800836:	83 c0 01             	add    $0x1,%eax
  800839:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80083c:	39 d8                	cmp    %ebx,%eax
  80083e:	74 16                	je     800856 <strncmp+0x31>
  800840:	0f b6 08             	movzbl (%eax),%ecx
  800843:	84 c9                	test   %cl,%cl
  800845:	74 04                	je     80084b <strncmp+0x26>
  800847:	3a 0a                	cmp    (%edx),%cl
  800849:	74 eb                	je     800836 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 00             	movzbl (%eax),%eax
  80084e:	0f b6 12             	movzbl (%edx),%edx
  800851:	29 d0                	sub    %edx,%eax
}
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    
		return 0;
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	eb f6                	jmp    800853 <strncmp+0x2e>

0080085d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800867:	0f b6 10             	movzbl (%eax),%edx
  80086a:	84 d2                	test   %dl,%dl
  80086c:	74 09                	je     800877 <strchr+0x1a>
		if (*s == c)
  80086e:	38 ca                	cmp    %cl,%dl
  800870:	74 0a                	je     80087c <strchr+0x1f>
	for (; *s; s++)
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	eb f0                	jmp    800867 <strchr+0xa>
			return (char *) s;
	return 0;
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800888:	eb 03                	jmp    80088d <strfind+0xf>
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800890:	38 ca                	cmp    %cl,%dl
  800892:	74 04                	je     800898 <strfind+0x1a>
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f2                	jne    80088a <strfind+0xc>
			break;
	return (char *) s;
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008a6:	85 c9                	test   %ecx,%ecx
  8008a8:	74 12                	je     8008bc <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008aa:	f6 c2 03             	test   $0x3,%dl
  8008ad:	75 05                	jne    8008b4 <memset+0x1a>
  8008af:	f6 c1 03             	test   $0x3,%cl
  8008b2:	74 0f                	je     8008c3 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b4:	89 d7                	mov    %edx,%edi
  8008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b9:	fc                   	cld    
  8008ba:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008bc:	89 d0                	mov    %edx,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5f                   	pop    %edi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    
		c &= 0xFF;
  8008c3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c7:	89 d8                	mov    %ebx,%eax
  8008c9:	c1 e0 08             	shl    $0x8,%eax
  8008cc:	89 df                	mov    %ebx,%edi
  8008ce:	c1 e7 18             	shl    $0x18,%edi
  8008d1:	89 de                	mov    %ebx,%esi
  8008d3:	c1 e6 10             	shl    $0x10,%esi
  8008d6:	09 f7                	or     %esi,%edi
  8008d8:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  8008da:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008df:	89 d7                	mov    %edx,%edi
  8008e1:	fc                   	cld    
  8008e2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e4:	eb d6                	jmp    8008bc <memset+0x22>

008008e6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	57                   	push   %edi
  8008ea:	56                   	push   %esi
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f4:	39 c6                	cmp    %eax,%esi
  8008f6:	73 35                	jae    80092d <memmove+0x47>
  8008f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fb:	39 c2                	cmp    %eax,%edx
  8008fd:	76 2e                	jbe    80092d <memmove+0x47>
		s += n;
		d += n;
  8008ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800902:	89 d6                	mov    %edx,%esi
  800904:	09 fe                	or     %edi,%esi
  800906:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090c:	74 0c                	je     80091a <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80090e:	83 ef 01             	sub    $0x1,%edi
  800911:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800914:	fd                   	std    
  800915:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800917:	fc                   	cld    
  800918:	eb 21                	jmp    80093b <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091a:	f6 c1 03             	test   $0x3,%cl
  80091d:	75 ef                	jne    80090e <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80091f:	83 ef 04             	sub    $0x4,%edi
  800922:	8d 72 fc             	lea    -0x4(%edx),%esi
  800925:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800928:	fd                   	std    
  800929:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092b:	eb ea                	jmp    800917 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092d:	89 f2                	mov    %esi,%edx
  80092f:	09 c2                	or     %eax,%edx
  800931:	f6 c2 03             	test   $0x3,%dl
  800934:	74 09                	je     80093f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093f:	f6 c1 03             	test   $0x3,%cl
  800942:	75 f2                	jne    800936 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800944:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800947:	89 c7                	mov    %eax,%edi
  800949:	fc                   	cld    
  80094a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094c:	eb ed                	jmp    80093b <memmove+0x55>

0080094e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800951:	ff 75 10             	pushl  0x10(%ebp)
  800954:	ff 75 0c             	pushl  0xc(%ebp)
  800957:	ff 75 08             	pushl  0x8(%ebp)
  80095a:	e8 87 ff ff ff       	call   8008e6 <memmove>
}
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 c6                	mov    %eax,%esi
  80096e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800971:	39 f0                	cmp    %esi,%eax
  800973:	74 1c                	je     800991 <memcmp+0x30>
		if (*s1 != *s2)
  800975:	0f b6 08             	movzbl (%eax),%ecx
  800978:	0f b6 1a             	movzbl (%edx),%ebx
  80097b:	38 d9                	cmp    %bl,%cl
  80097d:	75 08                	jne    800987 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80097f:	83 c0 01             	add    $0x1,%eax
  800982:	83 c2 01             	add    $0x1,%edx
  800985:	eb ea                	jmp    800971 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800987:	0f b6 c1             	movzbl %cl,%eax
  80098a:	0f b6 db             	movzbl %bl,%ebx
  80098d:	29 d8                	sub    %ebx,%eax
  80098f:	eb 05                	jmp    800996 <memcmp+0x35>
	}

	return 0;
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009a3:	89 c2                	mov    %eax,%edx
  8009a5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a8:	39 d0                	cmp    %edx,%eax
  8009aa:	73 09                	jae    8009b5 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ac:	38 08                	cmp    %cl,(%eax)
  8009ae:	74 05                	je     8009b5 <memfind+0x1b>
	for (; s < ends; s++)
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	eb f3                	jmp    8009a8 <memfind+0xe>
			break;
	return (void *) s;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c3:	eb 03                	jmp    8009c8 <strtol+0x11>
		s++;
  8009c5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009c8:	0f b6 01             	movzbl (%ecx),%eax
  8009cb:	3c 20                	cmp    $0x20,%al
  8009cd:	74 f6                	je     8009c5 <strtol+0xe>
  8009cf:	3c 09                	cmp    $0x9,%al
  8009d1:	74 f2                	je     8009c5 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009d3:	3c 2b                	cmp    $0x2b,%al
  8009d5:	74 2e                	je     800a05 <strtol+0x4e>
	int neg = 0;
  8009d7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009dc:	3c 2d                	cmp    $0x2d,%al
  8009de:	74 2f                	je     800a0f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e6:	75 05                	jne    8009ed <strtol+0x36>
  8009e8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009eb:	74 2c                	je     800a19 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ed:	85 db                	test   %ebx,%ebx
  8009ef:	75 0a                	jne    8009fb <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f1:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8009f6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f9:	74 28                	je     800a23 <strtol+0x6c>
		base = 10;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a03:	eb 50                	jmp    800a55 <strtol+0x9e>
		s++;
  800a05:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a08:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0d:	eb d1                	jmp    8009e0 <strtol+0x29>
		s++, neg = 1;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	bf 01 00 00 00       	mov    $0x1,%edi
  800a17:	eb c7                	jmp    8009e0 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a19:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a1d:	74 0e                	je     800a2d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a1f:	85 db                	test   %ebx,%ebx
  800a21:	75 d8                	jne    8009fb <strtol+0x44>
		s++, base = 8;
  800a23:	83 c1 01             	add    $0x1,%ecx
  800a26:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a2b:	eb ce                	jmp    8009fb <strtol+0x44>
		s += 2, base = 16;
  800a2d:	83 c1 02             	add    $0x2,%ecx
  800a30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a35:	eb c4                	jmp    8009fb <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a37:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a3a:	89 f3                	mov    %esi,%ebx
  800a3c:	80 fb 19             	cmp    $0x19,%bl
  800a3f:	77 29                	ja     800a6a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a41:	0f be d2             	movsbl %dl,%edx
  800a44:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a47:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4a:	7d 30                	jge    800a7c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a4c:	83 c1 01             	add    $0x1,%ecx
  800a4f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a53:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a55:	0f b6 11             	movzbl (%ecx),%edx
  800a58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5b:	89 f3                	mov    %esi,%ebx
  800a5d:	80 fb 09             	cmp    $0x9,%bl
  800a60:	77 d5                	ja     800a37 <strtol+0x80>
			dig = *s - '0';
  800a62:	0f be d2             	movsbl %dl,%edx
  800a65:	83 ea 30             	sub    $0x30,%edx
  800a68:	eb dd                	jmp    800a47 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a6a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 19             	cmp    $0x19,%bl
  800a72:	77 08                	ja     800a7c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a74:	0f be d2             	movsbl %dl,%edx
  800a77:	83 ea 37             	sub    $0x37,%edx
  800a7a:	eb cb                	jmp    800a47 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a80:	74 05                	je     800a87 <strtol+0xd0>
		*endptr = (char *) s;
  800a82:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a85:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a87:	89 c2                	mov    %eax,%edx
  800a89:	f7 da                	neg    %edx
  800a8b:	85 ff                	test   %edi,%edi
  800a8d:	0f 45 c2             	cmovne %edx,%eax
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	83 ec 1c             	sub    $0x1c,%esp
  800a9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800aa1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800aa4:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aac:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aaf:	8b 75 14             	mov    0x14(%ebp),%esi
  800ab2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ab8:	74 04                	je     800abe <syscall+0x29>
  800aba:	85 c0                	test   %eax,%eax
  800abc:	7f 08                	jg     800ac6 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800abe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    
  800ac6:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	50                   	push   %eax
  800acd:	52                   	push   %edx
  800ace:	68 a4 17 80 00       	push   $0x8017a4
  800ad3:	6a 23                	push   $0x23
  800ad5:	68 c1 17 80 00       	push   $0x8017c1
  800ada:	e8 1e 07 00 00       	call   8011fd <_panic>

00800adf <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ae5:	6a 00                	push   $0x0
  800ae7:	6a 00                	push   $0x0
  800ae9:	6a 00                	push   $0x0
  800aeb:	ff 75 0c             	pushl  0xc(%ebp)
  800aee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af1:	ba 00 00 00 00       	mov    $0x0,%edx
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	e8 95 ff ff ff       	call   800a95 <syscall>
}
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	c9                   	leave  
  800b04:	c3                   	ret    

00800b05 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b0b:	6a 00                	push   $0x0
  800b0d:	6a 00                	push   $0x0
  800b0f:	6a 00                	push   $0x0
  800b11:	6a 00                	push   $0x0
  800b13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b18:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b22:	e8 6e ff ff ff       	call   800a95 <syscall>
}
  800b27:	c9                   	leave  
  800b28:	c3                   	ret    

00800b29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b2f:	6a 00                	push   $0x0
  800b31:	6a 00                	push   $0x0
  800b33:	6a 00                	push   $0x0
  800b35:	6a 00                	push   $0x0
  800b37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3a:	ba 01 00 00 00       	mov    $0x1,%edx
  800b3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b44:	e8 4c ff ff ff       	call   800a95 <syscall>
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b51:	6a 00                	push   $0x0
  800b53:	6a 00                	push   $0x0
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b63:	b8 02 00 00 00       	mov    $0x2,%eax
  800b68:	e8 28 ff ff ff       	call   800a95 <syscall>
}
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <sys_yield>:

void
sys_yield(void)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b75:	6a 00                	push   $0x0
  800b77:	6a 00                	push   $0x0
  800b79:	6a 00                	push   $0x0
  800b7b:	6a 00                	push   $0x0
  800b7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8c:	e8 04 ff ff ff       	call   800a95 <syscall>
}
  800b91:	83 c4 10             	add    $0x10,%esp
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    

00800b96 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b9c:	6a 00                	push   $0x0
  800b9e:	6a 00                	push   $0x0
  800ba0:	ff 75 10             	pushl  0x10(%ebp)
  800ba3:	ff 75 0c             	pushl  0xc(%ebp)
  800ba6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba9:	ba 01 00 00 00       	mov    $0x1,%edx
  800bae:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb3:	e8 dd fe ff ff       	call   800a95 <syscall>
}
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bc0:	ff 75 18             	pushl  0x18(%ebp)
  800bc3:	ff 75 14             	pushl  0x14(%ebp)
  800bc6:	ff 75 10             	pushl  0x10(%ebp)
  800bc9:	ff 75 0c             	pushl  0xc(%ebp)
  800bcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcf:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd4:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd9:	e8 b7 fe ff ff       	call   800a95 <syscall>
}
  800bde:	c9                   	leave  
  800bdf:	c3                   	ret    

00800be0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800be6:	6a 00                	push   $0x0
  800be8:	6a 00                	push   $0x0
  800bea:	6a 00                	push   $0x0
  800bec:	ff 75 0c             	pushl  0xc(%ebp)
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfc:	e8 94 fe ff ff       	call   800a95 <syscall>
}
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c09:	6a 00                	push   $0x0
  800c0b:	6a 00                	push   $0x0
  800c0d:	6a 00                	push   $0x0
  800c0f:	ff 75 0c             	pushl  0xc(%ebp)
  800c12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c15:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1f:	e8 71 fe ff ff       	call   800a95 <syscall>
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c2c:	6a 00                	push   $0x0
  800c2e:	6a 00                	push   $0x0
  800c30:	6a 00                	push   $0x0
  800c32:	ff 75 0c             	pushl  0xc(%ebp)
  800c35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c38:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c42:	e8 4e fe ff ff       	call   800a95 <syscall>
}
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c4f:	6a 00                	push   $0x0
  800c51:	ff 75 14             	pushl  0x14(%ebp)
  800c54:	ff 75 10             	pushl  0x10(%ebp)
  800c57:	ff 75 0c             	pushl  0xc(%ebp)
  800c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c62:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c67:	e8 29 fe ff ff       	call   800a95 <syscall>
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c74:	6a 00                	push   $0x0
  800c76:	6a 00                	push   $0x0
  800c78:	6a 00                	push   $0x0
  800c7a:	6a 00                	push   $0x0
  800c7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c84:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c89:	e8 07 fe ff ff       	call   800a95 <syscall>
}
  800c8e:	c9                   	leave  
  800c8f:	c3                   	ret    

00800c90 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
	int r;

	void *addr = (void*)(pn << PGSHIFT);
  800c95:	89 d6                	mov    %edx,%esi
  800c97:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800c9a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800ca1:	89 ca                	mov    %ecx,%edx
  800ca3:	83 e2 05             	and    $0x5,%edx
  800ca6:	83 fa 05             	cmp    $0x5,%edx
  800ca9:	75 5a                	jne    800d05 <duppage+0x75>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800cab:	89 ca                	mov    %ecx,%edx
  800cad:	83 e2 18             	and    $0x18,%edx
		perm |= PTE_PCD | PTE_PWT;
  800cb0:	83 fa 01             	cmp    $0x1,%edx
  800cb3:	19 d2                	sbb    %edx,%edx
  800cb5:	83 e2 e8             	and    $0xffffffe8,%edx
  800cb8:	83 c2 1d             	add    $0x1d,%edx


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800cbb:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800cc1:	74 68                	je     800d2b <duppage+0x9b>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800cc3:	89 d3                	mov    %edx,%ebx
  800cc5:	80 cf 08             	or     $0x8,%bh
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	53                   	push   %ebx
  800ccc:	56                   	push   %esi
  800ccd:	50                   	push   %eax
  800cce:	56                   	push   %esi
  800ccf:	6a 00                	push   $0x0
  800cd1:	e8 e4 fe ff ff       	call   800bba <sys_page_map>
  800cd6:	83 c4 20             	add    $0x20,%esp
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	78 3c                	js     800d19 <duppage+0x89>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800cdd:	83 ec 0c             	sub    $0xc,%esp
  800ce0:	53                   	push   %ebx
  800ce1:	56                   	push   %esi
  800ce2:	6a 00                	push   $0x0
  800ce4:	56                   	push   %esi
  800ce5:	6a 00                	push   $0x0
  800ce7:	e8 ce fe ff ff       	call   800bba <sys_page_map>
  800cec:	83 c4 20             	add    $0x20,%esp
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	79 4d                	jns    800d40 <duppage+0xb0>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800cf3:	50                   	push   %eax
  800cf4:	68 2c 18 80 00       	push   $0x80182c
  800cf9:	6a 57                	push   $0x57
  800cfb:	68 21 19 80 00       	push   $0x801921
  800d00:	e8 f8 04 00 00       	call   8011fd <_panic>
		panic("duppage: copy a non-present or non-user page");
  800d05:	83 ec 04             	sub    $0x4,%esp
  800d08:	68 d0 17 80 00       	push   $0x8017d0
  800d0d:	6a 47                	push   $0x47
  800d0f:	68 21 19 80 00       	push   $0x801921
  800d14:	e8 e4 04 00 00       	call   8011fd <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800d19:	50                   	push   %eax
  800d1a:	68 00 18 80 00       	push   $0x801800
  800d1f:	6a 53                	push   $0x53
  800d21:	68 21 19 80 00       	push   $0x801921
  800d26:	e8 d2 04 00 00       	call   8011fd <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	52                   	push   %edx
  800d2f:	56                   	push   %esi
  800d30:	50                   	push   %eax
  800d31:	56                   	push   %esi
  800d32:	6a 00                	push   $0x0
  800d34:	e8 81 fe ff ff       	call   800bba <sys_page_map>
  800d39:	83 c4 20             	add    $0x20,%esp
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	78 0c                	js     800d4c <duppage+0xbc>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
  800d45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800d4c:	50                   	push   %eax
  800d4d:	68 54 18 80 00       	push   $0x801854
  800d52:	6a 5b                	push   $0x5b
  800d54:	68 21 19 80 00       	push   $0x801921
  800d59:	e8 9f 04 00 00       	call   8011fd <_panic>

00800d5e <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void*)(pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800d69:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800d70:	a8 01                	test   $0x1,%al
  800d72:	74 38                	je     800dac <dup_or_share+0x4e>
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800d78:	21 c3                	and    %eax,%ebx
  800d7a:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
  800d7d:	89 c1                	mov    %eax,%ecx
  800d7f:	83 e1 18             	and    $0x18,%ecx
		perm |= PTE_PCD | PTE_PWT;
  800d82:	89 da                	mov    %ebx,%edx
  800d84:	83 ca 18             	or     $0x18,%edx
  800d87:	85 c9                	test   %ecx,%ecx
  800d89:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void*)(pnum << PGSHIFT);
  800d8c:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800d8f:	83 e0 1a             	and    $0x1a,%eax
  800d92:	83 f8 02             	cmp    $0x2,%eax
  800d95:	74 32                	je     800dc9 <dup_or_share+0x6b>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	53                   	push   %ebx
  800d9b:	56                   	push   %esi
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	6a 00                	push   $0x0
  800da0:	e8 15 fe ff ff       	call   800bba <sys_page_map>
  800da5:	83 c4 20             	add    $0x20,%esp
  800da8:	85 c0                	test   %eax,%eax
  800daa:	78 08                	js     800db4 <dup_or_share+0x56>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800db4:	50                   	push   %eax
  800db5:	68 80 18 80 00       	push   $0x801880
  800dba:	68 84 00 00 00       	push   $0x84
  800dbf:	68 21 19 80 00       	push   $0x801921
  800dc4:	e8 34 04 00 00       	call   8011fd <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800dc9:	83 ec 04             	sub    $0x4,%esp
  800dcc:	53                   	push   %ebx
  800dcd:	56                   	push   %esi
  800dce:	57                   	push   %edi
  800dcf:	e8 c2 fd ff ff       	call   800b96 <sys_page_alloc>
  800dd4:	83 c4 10             	add    $0x10,%esp
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	78 57                	js     800e32 <dup_or_share+0xd4>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	53                   	push   %ebx
  800ddf:	68 00 00 40 00       	push   $0x400000
  800de4:	6a 00                	push   $0x0
  800de6:	56                   	push   %esi
  800de7:	57                   	push   %edi
  800de8:	e8 cd fd ff ff       	call   800bba <sys_page_map>
  800ded:	83 c4 20             	add    $0x20,%esp
  800df0:	85 c0                	test   %eax,%eax
  800df2:	78 53                	js     800e47 <dup_or_share+0xe9>
		memmove(UTEMP, addr, PGSIZE);
  800df4:	83 ec 04             	sub    $0x4,%esp
  800df7:	68 00 10 00 00       	push   $0x1000
  800dfc:	56                   	push   %esi
  800dfd:	68 00 00 40 00       	push   $0x400000
  800e02:	e8 df fa ff ff       	call   8008e6 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e07:	83 c4 08             	add    $0x8,%esp
  800e0a:	68 00 00 40 00       	push   $0x400000
  800e0f:	6a 00                	push   $0x0
  800e11:	e8 ca fd ff ff       	call   800be0 <sys_page_unmap>
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	79 8f                	jns    800dac <dup_or_share+0x4e>
			panic("sys_page_unmap: %e", r);
  800e1d:	50                   	push   %eax
  800e1e:	68 6b 19 80 00       	push   $0x80196b
  800e23:	68 8d 00 00 00       	push   $0x8d
  800e28:	68 21 19 80 00       	push   $0x801921
  800e2d:	e8 cb 03 00 00       	call   8011fd <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800e32:	50                   	push   %eax
  800e33:	68 a0 18 80 00       	push   $0x8018a0
  800e38:	68 88 00 00 00       	push   $0x88
  800e3d:	68 21 19 80 00       	push   $0x801921
  800e42:	e8 b6 03 00 00       	call   8011fd <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e47:	50                   	push   %eax
  800e48:	68 80 18 80 00       	push   $0x801880
  800e4d:	68 8a 00 00 00       	push   $0x8a
  800e52:	68 21 19 80 00       	push   $0x801921
  800e57:	e8 a1 03 00 00       	call   8011fd <_panic>

00800e5c <pgfault>:
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
  800e66:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t)addr) >> PGSHIFT];
  800e68:	89 d8                	mov    %ebx,%eax
  800e6a:	c1 e8 0c             	shr    $0xc,%eax
  800e6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800e74:	6a 07                	push   $0x7
  800e76:	68 00 f0 7f 00       	push   $0x7ff000
  800e7b:	6a 00                	push   $0x0
  800e7d:	e8 14 fd ff ff       	call   800b96 <sys_page_alloc>
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	78 51                	js     800eda <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800e89:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e8f:	83 ec 04             	sub    $0x4,%esp
  800e92:	68 00 10 00 00       	push   $0x1000
  800e97:	53                   	push   %ebx
  800e98:	68 00 f0 7f 00       	push   $0x7ff000
  800e9d:	e8 44 fa ff ff       	call   8008e6 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800ea2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ea9:	53                   	push   %ebx
  800eaa:	6a 00                	push   $0x0
  800eac:	68 00 f0 7f 00       	push   $0x7ff000
  800eb1:	6a 00                	push   $0x0
  800eb3:	e8 02 fd ff ff       	call   800bba <sys_page_map>
  800eb8:	83 c4 20             	add    $0x20,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 2d                	js     800eec <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	68 00 f0 7f 00       	push   $0x7ff000
  800ec7:	6a 00                	push   $0x0
  800ec9:	e8 12 fd ff ff       	call   800be0 <sys_page_unmap>
  800ece:	83 c4 10             	add    $0x10,%esp
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	78 29                	js     800efe <pgfault+0xa2>
}
  800ed5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800eda:	50                   	push   %eax
  800edb:	68 2c 19 80 00       	push   $0x80192c
  800ee0:	6a 27                	push   $0x27
  800ee2:	68 21 19 80 00       	push   $0x801921
  800ee7:	e8 11 03 00 00       	call   8011fd <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800eec:	50                   	push   %eax
  800eed:	68 48 19 80 00       	push   $0x801948
  800ef2:	6a 2c                	push   $0x2c
  800ef4:	68 21 19 80 00       	push   $0x801921
  800ef9:	e8 ff 02 00 00       	call   8011fd <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800efe:	50                   	push   %eax
  800eff:	68 62 19 80 00       	push   $0x801962
  800f04:	6a 2f                	push   $0x2f
  800f06:	68 21 19 80 00       	push   $0x801921
  800f0b:	e8 ed 02 00 00       	call   8011fd <_panic>

00800f10 <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	57                   	push   %edi
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f19:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1e:	cd 30                	int    $0x30
  800f20:	89 c7                	mov    %eax,%edi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	78 24                	js     800f4a <fork_v0+0x3a>
  800f26:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f28:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	75 39                	jne    800f6a <fork_v0+0x5a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f31:	e8 15 fc ff ff       	call   800b4b <sys_getenvid>
  800f36:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f3b:	c1 e0 07             	shl    $0x7,%eax
  800f3e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f43:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800f48:	eb 56                	jmp    800fa0 <fork_v0+0x90>
		panic("sys_exofork: %e", envid);
  800f4a:	50                   	push   %eax
  800f4b:	68 7e 19 80 00       	push   $0x80197e
  800f50:	68 a2 00 00 00       	push   $0xa2
  800f55:	68 21 19 80 00       	push   $0x801921
  800f5a:	e8 9e 02 00 00       	call   8011fd <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f5f:	83 c3 01             	add    $0x1,%ebx
  800f62:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800f68:	74 24                	je     800f8e <fork_v0+0x7e>
		pde_t pde = uvpd[pnum >> 10];
  800f6a:	89 d8                	mov    %ebx,%eax
  800f6c:	c1 e8 0a             	shr    $0xa,%eax
  800f6f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800f76:	83 e0 05             	and    $0x5,%eax
  800f79:	83 f8 05             	cmp    $0x5,%eax
  800f7c:	75 e1                	jne    800f5f <fork_v0+0x4f>
			continue;
		dup_or_share(envid, pnum, perm);
  800f7e:	b9 07 00 00 00       	mov    $0x7,%ecx
  800f83:	89 da                	mov    %ebx,%edx
  800f85:	89 f0                	mov    %esi,%eax
  800f87:	e8 d2 fd ff ff       	call   800d5e <dup_or_share>
  800f8c:	eb d1                	jmp    800f5f <fork_v0+0x4f>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800f8e:	83 ec 08             	sub    $0x8,%esp
  800f91:	6a 02                	push   $0x2
  800f93:	57                   	push   %edi
  800f94:	e8 6a fc ff ff       	call   800c03 <sys_env_set_status>
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 0a                	js     800faa <fork_v0+0x9a>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800fa0:	89 f8                	mov    %edi,%eax
  800fa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800faa:	50                   	push   %eax
  800fab:	68 8e 19 80 00       	push   $0x80198e
  800fb0:	68 b8 00 00 00       	push   $0xb8
  800fb5:	68 21 19 80 00       	push   $0x801921
  800fba:	e8 3e 02 00 00       	call   8011fd <_panic>

00800fbf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	57                   	push   %edi
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800fc8:	68 5c 0e 80 00       	push   $0x800e5c
  800fcd:	e8 71 02 00 00       	call   801243 <set_pgfault_handler>
  800fd2:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd7:	cd 30                	int    $0x30
  800fd9:	89 c7                	mov    %eax,%edi

	envid_t envid = sys_exofork();
	if (envid < 0)
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 27                	js     801009 <fork+0x4a>
  800fe2:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fe4:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	75 44                	jne    801031 <fork+0x72>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fed:	e8 59 fb ff ff       	call   800b4b <sys_getenvid>
  800ff2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff7:	c1 e0 07             	shl    $0x7,%eax
  800ffa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fff:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  801004:	e9 98 00 00 00       	jmp    8010a1 <fork+0xe2>
		panic("sys_exofork: %e", envid);
  801009:	50                   	push   %eax
  80100a:	68 7e 19 80 00       	push   $0x80197e
  80100f:	68 d6 00 00 00       	push   $0xd6
  801014:	68 21 19 80 00       	push   $0x801921
  801019:	e8 df 01 00 00       	call   8011fd <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  80101e:	83 c3 01             	add    $0x1,%ebx
  801021:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801027:	77 36                	ja     80105f <fork+0xa0>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  801029:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80102f:	74 ed                	je     80101e <fork+0x5f>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  801031:	89 d8                	mov    %ebx,%eax
  801033:	c1 e8 0a             	shr    $0xa,%eax
  801036:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  80103d:	83 e0 05             	and    $0x5,%eax
  801040:	83 f8 05             	cmp    $0x5,%eax
  801043:	75 d9                	jne    80101e <fork+0x5f>
			continue;

		pte_t pte = uvpt[pnum];
  801045:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  80104c:	83 e0 05             	and    $0x5,%eax
  80104f:	83 f8 05             	cmp    $0x5,%eax
  801052:	75 ca                	jne    80101e <fork+0x5f>
			continue;
		duppage(envid, pnum);
  801054:	89 da                	mov    %ebx,%edx
  801056:	89 f0                	mov    %esi,%eax
  801058:	e8 33 fc ff ff       	call   800c90 <duppage>
  80105d:	eb bf                	jmp    80101e <fork+0x5f>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void*)exstk, PTE_U | PTE_P | PTE_W);
  80105f:	83 ec 04             	sub    $0x4,%esp
  801062:	6a 07                	push   $0x7
  801064:	68 00 f0 bf ee       	push   $0xeebff000
  801069:	57                   	push   %edi
  80106a:	e8 27 fb ff ff       	call   800b96 <sys_page_alloc>
	if (r < 0)
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	78 35                	js     8010ab <fork+0xec>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801076:	a1 08 20 80 00       	mov    0x802008,%eax
  80107b:	8b 40 68             	mov    0x68(%eax),%eax
  80107e:	83 ec 08             	sub    $0x8,%esp
  801081:	50                   	push   %eax
  801082:	57                   	push   %edi
  801083:	e8 9e fb ff ff       	call   800c26 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	78 31                	js     8010c0 <fork+0x101>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80108f:	83 ec 08             	sub    $0x8,%esp
  801092:	6a 02                	push   $0x2
  801094:	57                   	push   %edi
  801095:	e8 69 fb ff ff       	call   800c03 <sys_env_set_status>
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	85 c0                	test   %eax,%eax
  80109f:	78 34                	js     8010d5 <fork+0x116>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  8010a1:	89 f8                	mov    %edi,%eax
  8010a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  8010ab:	50                   	push   %eax
  8010ac:	68 c4 18 80 00       	push   $0x8018c4
  8010b1:	68 f3 00 00 00       	push   $0xf3
  8010b6:	68 21 19 80 00       	push   $0x801921
  8010bb:	e8 3d 01 00 00       	call   8011fd <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  8010c0:	50                   	push   %eax
  8010c1:	68 f0 18 80 00       	push   $0x8018f0
  8010c6:	68 f6 00 00 00       	push   $0xf6
  8010cb:	68 21 19 80 00       	push   $0x801921
  8010d0:	e8 28 01 00 00       	call   8011fd <_panic>
		panic("sys_env_set_status: %e", r);
  8010d5:	50                   	push   %eax
  8010d6:	68 8e 19 80 00       	push   $0x80198e
  8010db:	68 f9 00 00 00       	push   $0xf9
  8010e0:	68 21 19 80 00       	push   $0x801921
  8010e5:	e8 13 01 00 00       	call   8011fd <_panic>

008010ea <sfork>:

// Challenge!
int
sfork(void)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010f0:	68 a5 19 80 00       	push   $0x8019a5
  8010f5:	68 02 01 00 00       	push   $0x102
  8010fa:	68 21 19 80 00       	push   $0x801921
  8010ff:	e8 f9 00 00 00       	call   8011fd <_panic>

00801104 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	56                   	push   %esi
  801108:	53                   	push   %ebx
  801109:	8b 75 08             	mov    0x8(%ebp),%esi
  80110c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int err = sys_ipc_recv(pg);
  80110f:	83 ec 0c             	sub    $0xc,%esp
  801112:	ff 75 0c             	pushl  0xc(%ebp)
  801115:	e8 54 fb ff ff       	call   800c6e <sys_ipc_recv>

	if (from_env_store)
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	85 f6                	test   %esi,%esi
  80111f:	74 14                	je     801135 <ipc_recv+0x31>
		*from_env_store = (!err) ? thisenv->env_ipc_from : 0;
  801121:	ba 00 00 00 00       	mov    $0x0,%edx
  801126:	85 c0                	test   %eax,%eax
  801128:	75 09                	jne    801133 <ipc_recv+0x2f>
  80112a:	8b 15 08 20 80 00    	mov    0x802008,%edx
  801130:	8b 52 78             	mov    0x78(%edx),%edx
  801133:	89 16                	mov    %edx,(%esi)

	if (perm_store)
  801135:	85 db                	test   %ebx,%ebx
  801137:	74 14                	je     80114d <ipc_recv+0x49>
		*perm_store = (!err) ? thisenv->env_ipc_perm : 0;
  801139:	ba 00 00 00 00       	mov    $0x0,%edx
  80113e:	85 c0                	test   %eax,%eax
  801140:	75 09                	jne    80114b <ipc_recv+0x47>
  801142:	8b 15 08 20 80 00    	mov    0x802008,%edx
  801148:	8b 52 7c             	mov    0x7c(%edx),%edx
  80114b:	89 13                	mov    %edx,(%ebx)

	if (!err) err = thisenv->env_ipc_value;
  80114d:	85 c0                	test   %eax,%eax
  80114f:	75 08                	jne    801159 <ipc_recv+0x55>
  801151:	a1 08 20 80 00       	mov    0x802008,%eax
  801156:	8b 40 74             	mov    0x74(%eax),%eax
	
	return err;
}
  801159:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	83 ec 0c             	sub    $0xc,%esp
  801169:	8b 75 0c             	mov    0xc(%ebp),%esi
  80116c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80116f:	8b 7d 14             	mov    0x14(%ebp),%edi
	if (!pg)
  801172:	85 db                	test   %ebx,%ebx
		pg = (void*) UTOP;
  801174:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801179:	0f 44 d8             	cmove  %eax,%ebx
	int r = sys_ipc_try_send(to_env, val, pg, perm);
  80117c:	57                   	push   %edi
  80117d:	53                   	push   %ebx
  80117e:	56                   	push   %esi
  80117f:	ff 75 08             	pushl  0x8(%ebp)
  801182:	e8 c2 fa ff ff       	call   800c49 <sys_ipc_try_send>
	while (r == -E_IPC_NOT_RECV) {
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	eb 13                	jmp    80119f <ipc_send+0x3f>
		sys_yield();
  80118c:	e8 de f9 ff ff       	call   800b6f <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801191:	57                   	push   %edi
  801192:	53                   	push   %ebx
  801193:	56                   	push   %esi
  801194:	ff 75 08             	pushl  0x8(%ebp)
  801197:	e8 ad fa ff ff       	call   800c49 <sys_ipc_try_send>
  80119c:	83 c4 10             	add    $0x10,%esp
	while (r == -E_IPC_NOT_RECV) {
  80119f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011a2:	74 e8                	je     80118c <ipc_send+0x2c>
	}

	if (r < 0) panic("ipc_send: %e", r);
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	78 08                	js     8011b0 <ipc_send+0x50>
}
  8011a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    
	if (r < 0) panic("ipc_send: %e", r);
  8011b0:	50                   	push   %eax
  8011b1:	68 bb 19 80 00       	push   $0x8019bb
  8011b6:	6a 39                	push   $0x39
  8011b8:	68 c8 19 80 00       	push   $0x8019c8
  8011bd:	e8 3b 00 00 00       	call   8011fd <_panic>

008011c2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011c8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011cd:	89 c2                	mov    %eax,%edx
  8011cf:	c1 e2 07             	shl    $0x7,%edx
  8011d2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011d8:	8b 52 50             	mov    0x50(%edx),%edx
  8011db:	39 ca                	cmp    %ecx,%edx
  8011dd:	74 11                	je     8011f0 <ipc_find_env+0x2e>
	for (i = 0; i < NENV; i++)
  8011df:	83 c0 01             	add    $0x1,%eax
  8011e2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011e7:	75 e4                	jne    8011cd <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ee:	eb 0b                	jmp    8011fb <ipc_find_env+0x39>
			return envs[i].env_id;
  8011f0:	c1 e0 07             	shl    $0x7,%eax
  8011f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011f8:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	56                   	push   %esi
  801201:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801202:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801205:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80120b:	e8 3b f9 ff ff       	call   800b4b <sys_getenvid>
  801210:	83 ec 0c             	sub    $0xc,%esp
  801213:	ff 75 0c             	pushl  0xc(%ebp)
  801216:	ff 75 08             	pushl  0x8(%ebp)
  801219:	56                   	push   %esi
  80121a:	50                   	push   %eax
  80121b:	68 d4 19 80 00       	push   $0x8019d4
  801220:	e8 cf ef ff ff       	call   8001f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801225:	83 c4 18             	add    $0x18,%esp
  801228:	53                   	push   %ebx
  801229:	ff 75 10             	pushl  0x10(%ebp)
  80122c:	e8 72 ef ff ff       	call   8001a3 <vcprintf>
	cprintf("\n");
  801231:	c7 04 24 18 15 80 00 	movl   $0x801518,(%esp)
  801238:	e8 b7 ef ff ff       	call   8001f4 <cprintf>
  80123d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801240:	cc                   	int3   
  801241:	eb fd                	jmp    801240 <_panic+0x43>

00801243 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801249:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801250:	74 0a                	je     80125c <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801252:	8b 45 08             	mov    0x8(%ebp),%eax
  801255:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80125a:	c9                   	leave  
  80125b:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  80125c:	83 ec 04             	sub    $0x4,%esp
  80125f:	6a 07                	push   $0x7
  801261:	68 00 f0 bf ee       	push   $0xeebff000
  801266:	6a 00                	push   $0x0
  801268:	e8 29 f9 ff ff       	call   800b96 <sys_page_alloc>
		if (r < 0) return;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	78 e6                	js     80125a <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801274:	83 ec 08             	sub    $0x8,%esp
  801277:	68 8c 12 80 00       	push   $0x80128c
  80127c:	6a 00                	push   $0x0
  80127e:	e8 a3 f9 ff ff       	call   800c26 <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	79 c8                	jns    801252 <set_pgfault_handler+0xf>
  80128a:	eb ce                	jmp    80125a <set_pgfault_handler+0x17>

0080128c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80128c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80128d:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801292:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801294:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801297:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  80129b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80129f:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  8012a2:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  8012a4:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  8012a8:	58                   	pop    %eax
	popl %eax
  8012a9:	58                   	pop    %eax
	popal
  8012aa:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  8012ab:	83 c4 04             	add    $0x4,%esp
	popfl
  8012ae:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  8012af:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  8012b0:	c3                   	ret    
  8012b1:	66 90                	xchg   %ax,%ax
  8012b3:	66 90                	xchg   %ax,%ax
  8012b5:	66 90                	xchg   %ax,%ax
  8012b7:	66 90                	xchg   %ax,%ax
  8012b9:	66 90                	xchg   %ax,%ax
  8012bb:	66 90                	xchg   %ax,%ax
  8012bd:	66 90                	xchg   %ax,%ax
  8012bf:	90                   	nop

008012c0 <__udivdi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 1c             	sub    $0x1c,%esp
  8012c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012cb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8012cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012d3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8012d7:	85 d2                	test   %edx,%edx
  8012d9:	75 35                	jne    801310 <__udivdi3+0x50>
  8012db:	39 f3                	cmp    %esi,%ebx
  8012dd:	0f 87 bd 00 00 00    	ja     8013a0 <__udivdi3+0xe0>
  8012e3:	85 db                	test   %ebx,%ebx
  8012e5:	89 d9                	mov    %ebx,%ecx
  8012e7:	75 0b                	jne    8012f4 <__udivdi3+0x34>
  8012e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ee:	31 d2                	xor    %edx,%edx
  8012f0:	f7 f3                	div    %ebx
  8012f2:	89 c1                	mov    %eax,%ecx
  8012f4:	31 d2                	xor    %edx,%edx
  8012f6:	89 f0                	mov    %esi,%eax
  8012f8:	f7 f1                	div    %ecx
  8012fa:	89 c6                	mov    %eax,%esi
  8012fc:	89 e8                	mov    %ebp,%eax
  8012fe:	89 f7                	mov    %esi,%edi
  801300:	f7 f1                	div    %ecx
  801302:	89 fa                	mov    %edi,%edx
  801304:	83 c4 1c             	add    $0x1c,%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    
  80130c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801310:	39 f2                	cmp    %esi,%edx
  801312:	77 7c                	ja     801390 <__udivdi3+0xd0>
  801314:	0f bd fa             	bsr    %edx,%edi
  801317:	83 f7 1f             	xor    $0x1f,%edi
  80131a:	0f 84 98 00 00 00    	je     8013b8 <__udivdi3+0xf8>
  801320:	89 f9                	mov    %edi,%ecx
  801322:	b8 20 00 00 00       	mov    $0x20,%eax
  801327:	29 f8                	sub    %edi,%eax
  801329:	d3 e2                	shl    %cl,%edx
  80132b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80132f:	89 c1                	mov    %eax,%ecx
  801331:	89 da                	mov    %ebx,%edx
  801333:	d3 ea                	shr    %cl,%edx
  801335:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801339:	09 d1                	or     %edx,%ecx
  80133b:	89 f2                	mov    %esi,%edx
  80133d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801341:	89 f9                	mov    %edi,%ecx
  801343:	d3 e3                	shl    %cl,%ebx
  801345:	89 c1                	mov    %eax,%ecx
  801347:	d3 ea                	shr    %cl,%edx
  801349:	89 f9                	mov    %edi,%ecx
  80134b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80134f:	d3 e6                	shl    %cl,%esi
  801351:	89 eb                	mov    %ebp,%ebx
  801353:	89 c1                	mov    %eax,%ecx
  801355:	d3 eb                	shr    %cl,%ebx
  801357:	09 de                	or     %ebx,%esi
  801359:	89 f0                	mov    %esi,%eax
  80135b:	f7 74 24 08          	divl   0x8(%esp)
  80135f:	89 d6                	mov    %edx,%esi
  801361:	89 c3                	mov    %eax,%ebx
  801363:	f7 64 24 0c          	mull   0xc(%esp)
  801367:	39 d6                	cmp    %edx,%esi
  801369:	72 0c                	jb     801377 <__udivdi3+0xb7>
  80136b:	89 f9                	mov    %edi,%ecx
  80136d:	d3 e5                	shl    %cl,%ebp
  80136f:	39 c5                	cmp    %eax,%ebp
  801371:	73 5d                	jae    8013d0 <__udivdi3+0x110>
  801373:	39 d6                	cmp    %edx,%esi
  801375:	75 59                	jne    8013d0 <__udivdi3+0x110>
  801377:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80137a:	31 ff                	xor    %edi,%edi
  80137c:	89 fa                	mov    %edi,%edx
  80137e:	83 c4 1c             	add    $0x1c,%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    
  801386:	8d 76 00             	lea    0x0(%esi),%esi
  801389:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801390:	31 ff                	xor    %edi,%edi
  801392:	31 c0                	xor    %eax,%eax
  801394:	89 fa                	mov    %edi,%edx
  801396:	83 c4 1c             	add    $0x1c,%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5f                   	pop    %edi
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    
  80139e:	66 90                	xchg   %ax,%ax
  8013a0:	31 ff                	xor    %edi,%edi
  8013a2:	89 e8                	mov    %ebp,%eax
  8013a4:	89 f2                	mov    %esi,%edx
  8013a6:	f7 f3                	div    %ebx
  8013a8:	89 fa                	mov    %edi,%edx
  8013aa:	83 c4 1c             	add    $0x1c,%esp
  8013ad:	5b                   	pop    %ebx
  8013ae:	5e                   	pop    %esi
  8013af:	5f                   	pop    %edi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    
  8013b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013b8:	39 f2                	cmp    %esi,%edx
  8013ba:	72 06                	jb     8013c2 <__udivdi3+0x102>
  8013bc:	31 c0                	xor    %eax,%eax
  8013be:	39 eb                	cmp    %ebp,%ebx
  8013c0:	77 d2                	ja     801394 <__udivdi3+0xd4>
  8013c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c7:	eb cb                	jmp    801394 <__udivdi3+0xd4>
  8013c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	89 d8                	mov    %ebx,%eax
  8013d2:	31 ff                	xor    %edi,%edi
  8013d4:	eb be                	jmp    801394 <__udivdi3+0xd4>
  8013d6:	66 90                	xchg   %ax,%ax
  8013d8:	66 90                	xchg   %ax,%ax
  8013da:	66 90                	xchg   %ax,%ax
  8013dc:	66 90                	xchg   %ax,%ax
  8013de:	66 90                	xchg   %ax,%ax

008013e0 <__umoddi3>:
  8013e0:	55                   	push   %ebp
  8013e1:	57                   	push   %edi
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	83 ec 1c             	sub    $0x1c,%esp
  8013e7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8013eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8013ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8013f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013f7:	85 ed                	test   %ebp,%ebp
  8013f9:	89 f0                	mov    %esi,%eax
  8013fb:	89 da                	mov    %ebx,%edx
  8013fd:	75 19                	jne    801418 <__umoddi3+0x38>
  8013ff:	39 df                	cmp    %ebx,%edi
  801401:	0f 86 b1 00 00 00    	jbe    8014b8 <__umoddi3+0xd8>
  801407:	f7 f7                	div    %edi
  801409:	89 d0                	mov    %edx,%eax
  80140b:	31 d2                	xor    %edx,%edx
  80140d:	83 c4 1c             	add    $0x1c,%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    
  801415:	8d 76 00             	lea    0x0(%esi),%esi
  801418:	39 dd                	cmp    %ebx,%ebp
  80141a:	77 f1                	ja     80140d <__umoddi3+0x2d>
  80141c:	0f bd cd             	bsr    %ebp,%ecx
  80141f:	83 f1 1f             	xor    $0x1f,%ecx
  801422:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801426:	0f 84 b4 00 00 00    	je     8014e0 <__umoddi3+0x100>
  80142c:	b8 20 00 00 00       	mov    $0x20,%eax
  801431:	89 c2                	mov    %eax,%edx
  801433:	8b 44 24 04          	mov    0x4(%esp),%eax
  801437:	29 c2                	sub    %eax,%edx
  801439:	89 c1                	mov    %eax,%ecx
  80143b:	89 f8                	mov    %edi,%eax
  80143d:	d3 e5                	shl    %cl,%ebp
  80143f:	89 d1                	mov    %edx,%ecx
  801441:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801445:	d3 e8                	shr    %cl,%eax
  801447:	09 c5                	or     %eax,%ebp
  801449:	8b 44 24 04          	mov    0x4(%esp),%eax
  80144d:	89 c1                	mov    %eax,%ecx
  80144f:	d3 e7                	shl    %cl,%edi
  801451:	89 d1                	mov    %edx,%ecx
  801453:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801457:	89 df                	mov    %ebx,%edi
  801459:	d3 ef                	shr    %cl,%edi
  80145b:	89 c1                	mov    %eax,%ecx
  80145d:	89 f0                	mov    %esi,%eax
  80145f:	d3 e3                	shl    %cl,%ebx
  801461:	89 d1                	mov    %edx,%ecx
  801463:	89 fa                	mov    %edi,%edx
  801465:	d3 e8                	shr    %cl,%eax
  801467:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80146c:	09 d8                	or     %ebx,%eax
  80146e:	f7 f5                	div    %ebp
  801470:	d3 e6                	shl    %cl,%esi
  801472:	89 d1                	mov    %edx,%ecx
  801474:	f7 64 24 08          	mull   0x8(%esp)
  801478:	39 d1                	cmp    %edx,%ecx
  80147a:	89 c3                	mov    %eax,%ebx
  80147c:	89 d7                	mov    %edx,%edi
  80147e:	72 06                	jb     801486 <__umoddi3+0xa6>
  801480:	75 0e                	jne    801490 <__umoddi3+0xb0>
  801482:	39 c6                	cmp    %eax,%esi
  801484:	73 0a                	jae    801490 <__umoddi3+0xb0>
  801486:	2b 44 24 08          	sub    0x8(%esp),%eax
  80148a:	19 ea                	sbb    %ebp,%edx
  80148c:	89 d7                	mov    %edx,%edi
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	89 ca                	mov    %ecx,%edx
  801492:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801497:	29 de                	sub    %ebx,%esi
  801499:	19 fa                	sbb    %edi,%edx
  80149b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80149f:	89 d0                	mov    %edx,%eax
  8014a1:	d3 e0                	shl    %cl,%eax
  8014a3:	89 d9                	mov    %ebx,%ecx
  8014a5:	d3 ee                	shr    %cl,%esi
  8014a7:	d3 ea                	shr    %cl,%edx
  8014a9:	09 f0                	or     %esi,%eax
  8014ab:	83 c4 1c             	add    $0x1c,%esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5f                   	pop    %edi
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    
  8014b3:	90                   	nop
  8014b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014b8:	85 ff                	test   %edi,%edi
  8014ba:	89 f9                	mov    %edi,%ecx
  8014bc:	75 0b                	jne    8014c9 <__umoddi3+0xe9>
  8014be:	b8 01 00 00 00       	mov    $0x1,%eax
  8014c3:	31 d2                	xor    %edx,%edx
  8014c5:	f7 f7                	div    %edi
  8014c7:	89 c1                	mov    %eax,%ecx
  8014c9:	89 d8                	mov    %ebx,%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	f7 f1                	div    %ecx
  8014cf:	89 f0                	mov    %esi,%eax
  8014d1:	f7 f1                	div    %ecx
  8014d3:	e9 31 ff ff ff       	jmp    801409 <__umoddi3+0x29>
  8014d8:	90                   	nop
  8014d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014e0:	39 dd                	cmp    %ebx,%ebp
  8014e2:	72 08                	jb     8014ec <__umoddi3+0x10c>
  8014e4:	39 f7                	cmp    %esi,%edi
  8014e6:	0f 87 21 ff ff ff    	ja     80140d <__umoddi3+0x2d>
  8014ec:	89 da                	mov    %ebx,%edx
  8014ee:	89 f0                	mov    %esi,%eax
  8014f0:	29 f8                	sub    %edi,%eax
  8014f2:	19 ea                	sbb    %ebp,%edx
  8014f4:	e9 14 ff ff ff       	jmp    80140d <__umoddi3+0x2d>
