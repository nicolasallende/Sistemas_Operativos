
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 f3 10 00 00       	call   80113f <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 00 15 80 00       	push   $0x801500
  800060:	e8 ca 01 00 00       	call   80022f <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 90 0f 00 00       	call   800ffa <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	78 30                	js     8000a3 <primeproc+0x70>
		panic("fork: %e", id);
	if (id == 0)
  800073:	85 c0                	test   %eax,%eax
  800075:	74 c8                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800077:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007a:	83 ec 04             	sub    $0x4,%esp
  80007d:	6a 00                	push   $0x0
  80007f:	6a 00                	push   $0x0
  800081:	56                   	push   %esi
  800082:	e8 b8 10 00 00       	call   80113f <ipc_recv>
  800087:	89 c1                	mov    %eax,%ecx
		if (i % p)
  800089:	99                   	cltd   
  80008a:	f7 fb                	idiv   %ebx
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	85 d2                	test   %edx,%edx
  800091:	74 e7                	je     80007a <primeproc+0x47>
			ipc_send(id, i, 0, 0);
  800093:	6a 00                	push   $0x0
  800095:	6a 00                	push   $0x0
  800097:	51                   	push   %ecx
  800098:	57                   	push   %edi
  800099:	e8 fd 10 00 00       	call   80119b <ipc_send>
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	eb d7                	jmp    80007a <primeproc+0x47>
		panic("fork: %e", id);
  8000a3:	50                   	push   %eax
  8000a4:	68 68 19 80 00       	push   $0x801968
  8000a9:	6a 1a                	push   $0x1a
  8000ab:	68 0c 15 80 00       	push   $0x80150c
  8000b0:	e8 9f 00 00 00       	call   800154 <_panic>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 3b 0f 00 00       	call   800ffa <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	78 1c                	js     8000e1 <umain+0x2c>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000c5:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	74 25                	je     8000f3 <umain+0x3e>
		ipc_send(id, i, 0, 0);
  8000ce:	6a 00                	push   $0x0
  8000d0:	6a 00                	push   $0x0
  8000d2:	53                   	push   %ebx
  8000d3:	56                   	push   %esi
  8000d4:	e8 c2 10 00 00       	call   80119b <ipc_send>
	for (i = 2; ; i++)
  8000d9:	83 c3 01             	add    $0x1,%ebx
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	eb ed                	jmp    8000ce <umain+0x19>
		panic("fork: %e", id);
  8000e1:	50                   	push   %eax
  8000e2:	68 68 19 80 00       	push   $0x801968
  8000e7:	6a 2d                	push   $0x2d
  8000e9:	68 0c 15 80 00       	push   $0x80150c
  8000ee:	e8 61 00 00 00       	call   800154 <_panic>
		primeproc();
  8000f3:	e8 3b ff ff ff       	call   800033 <primeproc>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  800103:	e8 7e 0a 00 00       	call   800b86 <sys_getenvid>
	if (id >= 0)
  800108:	85 c0                	test   %eax,%eax
  80010a:	78 12                	js     80011e <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  80010c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800111:	c1 e0 07             	shl    $0x7,%eax
  800114:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800119:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011e:	85 db                	test   %ebx,%ebx
  800120:	7e 07                	jle    800129 <libmain+0x31>
		binaryname = argv[0];
  800122:	8b 06                	mov    (%esi),%eax
  800124:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
  80012e:	e8 82 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  800133:	e8 0a 00 00 00       	call   800142 <exit>
}
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    

00800142 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800148:	6a 00                	push   $0x0
  80014a:	e8 15 0a 00 00       	call   800b64 <sys_env_destroy>
}
  80014f:	83 c4 10             	add    $0x10,%esp
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800159:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800162:	e8 1f 0a 00 00       	call   800b86 <sys_getenvid>
  800167:	83 ec 0c             	sub    $0xc,%esp
  80016a:	ff 75 0c             	pushl  0xc(%ebp)
  80016d:	ff 75 08             	pushl  0x8(%ebp)
  800170:	56                   	push   %esi
  800171:	50                   	push   %eax
  800172:	68 24 15 80 00       	push   $0x801524
  800177:	e8 b3 00 00 00       	call   80022f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017c:	83 c4 18             	add    $0x18,%esp
  80017f:	53                   	push   %ebx
  800180:	ff 75 10             	pushl  0x10(%ebp)
  800183:	e8 56 00 00 00       	call   8001de <vcprintf>
	cprintf("\n");
  800188:	c7 04 24 47 15 80 00 	movl   $0x801547,(%esp)
  80018f:	e8 9b 00 00 00       	call   80022f <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800197:	cc                   	int3   
  800198:	eb fd                	jmp    800197 <_panic+0x43>

0080019a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	53                   	push   %ebx
  80019e:	83 ec 04             	sub    $0x4,%esp
  8001a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a4:	8b 13                	mov    (%ebx),%edx
  8001a6:	8d 42 01             	lea    0x1(%edx),%eax
  8001a9:	89 03                	mov    %eax,(%ebx)
  8001ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b7:	74 09                	je     8001c2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c2:	83 ec 08             	sub    $0x8,%esp
  8001c5:	68 ff 00 00 00       	push   $0xff
  8001ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cd:	50                   	push   %eax
  8001ce:	e8 47 09 00 00       	call   800b1a <sys_cputs>
		b->idx = 0;
  8001d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	eb db                	jmp    8001b9 <putch+0x1f>

008001de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ee:	00 00 00 
	b.cnt = 0;
  8001f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	68 9a 01 80 00       	push   $0x80019a
  80020d:	e8 86 01 00 00       	call   800398 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800212:	83 c4 08             	add    $0x8,%esp
  800215:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800221:	50                   	push   %eax
  800222:	e8 f3 08 00 00       	call   800b1a <sys_cputs>

	return b.cnt;
}
  800227:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800235:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800238:	50                   	push   %eax
  800239:	ff 75 08             	pushl  0x8(%ebp)
  80023c:	e8 9d ff ff ff       	call   8001de <vcprintf>
	va_end(ap);

	return cnt;
}
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	57                   	push   %edi
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
  800249:	83 ec 1c             	sub    $0x1c,%esp
  80024c:	89 c7                	mov    %eax,%edi
  80024e:	89 d6                	mov    %edx,%esi
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	8b 55 0c             	mov    0xc(%ebp),%edx
  800256:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800259:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80025f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800264:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800267:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026a:	39 d3                	cmp    %edx,%ebx
  80026c:	72 05                	jb     800273 <printnum+0x30>
  80026e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800271:	77 7a                	ja     8002ed <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	ff 75 18             	pushl  0x18(%ebp)
  800279:	8b 45 14             	mov    0x14(%ebp),%eax
  80027c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80027f:	53                   	push   %ebx
  800280:	ff 75 10             	pushl  0x10(%ebp)
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	ff 75 e4             	pushl  -0x1c(%ebp)
  800289:	ff 75 e0             	pushl  -0x20(%ebp)
  80028c:	ff 75 dc             	pushl  -0x24(%ebp)
  80028f:	ff 75 d8             	pushl  -0x28(%ebp)
  800292:	e8 19 10 00 00       	call   8012b0 <__udivdi3>
  800297:	83 c4 18             	add    $0x18,%esp
  80029a:	52                   	push   %edx
  80029b:	50                   	push   %eax
  80029c:	89 f2                	mov    %esi,%edx
  80029e:	89 f8                	mov    %edi,%eax
  8002a0:	e8 9e ff ff ff       	call   800243 <printnum>
  8002a5:	83 c4 20             	add    $0x20,%esp
  8002a8:	eb 13                	jmp    8002bd <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	56                   	push   %esi
  8002ae:	ff 75 18             	pushl  0x18(%ebp)
  8002b1:	ff d7                	call   *%edi
  8002b3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b6:	83 eb 01             	sub    $0x1,%ebx
  8002b9:	85 db                	test   %ebx,%ebx
  8002bb:	7f ed                	jg     8002aa <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bd:	83 ec 08             	sub    $0x8,%esp
  8002c0:	56                   	push   %esi
  8002c1:	83 ec 04             	sub    $0x4,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 fb 10 00 00       	call   8013d0 <__umoddi3>
  8002d5:	83 c4 14             	add    $0x14,%esp
  8002d8:	0f be 80 49 15 80 00 	movsbl 0x801549(%eax),%eax
  8002df:	50                   	push   %eax
  8002e0:	ff d7                	call   *%edi
}
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e8:	5b                   	pop    %ebx
  8002e9:	5e                   	pop    %esi
  8002ea:	5f                   	pop    %edi
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    
  8002ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f0:	eb c4                	jmp    8002b6 <printnum+0x73>

008002f2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f5:	83 fa 01             	cmp    $0x1,%edx
  8002f8:	7e 0e                	jle    800308 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    
	else if (lflag)
  800308:	85 d2                	test   %edx,%edx
  80030a:	75 10                	jne    80031c <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
  80031a:	eb ea                	jmp    800306 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800321:	89 08                	mov    %ecx,(%eax)
  800323:	8b 02                	mov    (%edx),%eax
  800325:	ba 00 00 00 00       	mov    $0x0,%edx
  80032a:	eb da                	jmp    800306 <getuint+0x14>

0080032c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032f:	83 fa 01             	cmp    $0x1,%edx
  800332:	7e 0e                	jle    800342 <getint+0x16>
		return va_arg(*ap, long long);
  800334:	8b 10                	mov    (%eax),%edx
  800336:	8d 4a 08             	lea    0x8(%edx),%ecx
  800339:	89 08                	mov    %ecx,(%eax)
  80033b:	8b 02                	mov    (%edx),%eax
  80033d:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    
	else if (lflag)
  800342:	85 d2                	test   %edx,%edx
  800344:	75 0c                	jne    800352 <getint+0x26>
		return va_arg(*ap, int);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	99                   	cltd   
  800350:	eb ee                	jmp    800340 <getint+0x14>
		return va_arg(*ap, long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 04             	lea    0x4(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	99                   	cltd   
  80035c:	eb e2                	jmp    800340 <getint+0x14>

0080035e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800364:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	3b 50 04             	cmp    0x4(%eax),%edx
  80036d:	73 0a                	jae    800379 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800372:	89 08                	mov    %ecx,(%eax)
  800374:	8b 45 08             	mov    0x8(%ebp),%eax
  800377:	88 02                	mov    %al,(%edx)
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <printfmt>:
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800381:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800384:	50                   	push   %eax
  800385:	ff 75 10             	pushl  0x10(%ebp)
  800388:	ff 75 0c             	pushl  0xc(%ebp)
  80038b:	ff 75 08             	pushl  0x8(%ebp)
  80038e:	e8 05 00 00 00       	call   800398 <vprintfmt>
}
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <vprintfmt>:
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	57                   	push   %edi
  80039c:	56                   	push   %esi
  80039d:	53                   	push   %ebx
  80039e:	83 ec 2c             	sub    $0x2c,%esp
  8003a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003a7:	89 f7                	mov    %esi,%edi
  8003a9:	89 de                	mov    %ebx,%esi
  8003ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ae:	e9 9e 02 00 00       	jmp    800651 <vprintfmt+0x2b9>
		padc = ' ';
  8003b3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003cc:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8d 43 01             	lea    0x1(%ebx),%eax
  8003d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d7:	0f b6 0b             	movzbl (%ebx),%ecx
  8003da:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8003dd:	3c 55                	cmp    $0x55,%al
  8003df:	0f 87 e8 02 00 00    	ja     8006cd <vprintfmt+0x335>
  8003e5:	0f b6 c0             	movzbl %al,%eax
  8003e8:	ff 24 85 00 16 80 00 	jmp    *0x801600(,%eax,4)
  8003ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  8003f2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003f6:	eb d9                	jmp    8003d1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  8003fb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ff:	eb d0                	jmp    8003d1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800401:	0f b6 c9             	movzbl %cl,%ecx
  800404:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80040f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800412:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800416:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800419:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80041c:	83 fa 09             	cmp    $0x9,%edx
  80041f:	77 52                	ja     800473 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800421:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800424:	eb e9                	jmp    80040f <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 48 04             	lea    0x4(%eax),%ecx
  80042c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80042f:	8b 00                	mov    (%eax),%eax
  800431:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800437:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043b:	79 94                	jns    8003d1 <vprintfmt+0x39>
				width = precision, precision = -1;
  80043d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800443:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044a:	eb 85                	jmp    8003d1 <vprintfmt+0x39>
  80044c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80044f:	85 c0                	test   %eax,%eax
  800451:	b9 00 00 00 00       	mov    $0x0,%ecx
  800456:	0f 49 c8             	cmovns %eax,%ecx
  800459:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80045f:	e9 6d ff ff ff       	jmp    8003d1 <vprintfmt+0x39>
  800464:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800467:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80046e:	e9 5e ff ff ff       	jmp    8003d1 <vprintfmt+0x39>
  800473:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800476:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800479:	eb bc                	jmp    800437 <vprintfmt+0x9f>
			lflag++;
  80047b:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800481:	e9 4b ff ff ff       	jmp    8003d1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800486:	8b 45 14             	mov    0x14(%ebp),%eax
  800489:	8d 50 04             	lea    0x4(%eax),%edx
  80048c:	89 55 14             	mov    %edx,0x14(%ebp)
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	57                   	push   %edi
  800493:	ff 30                	pushl  (%eax)
  800495:	ff d6                	call   *%esi
			break;
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	e9 af 01 00 00       	jmp    80064e <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8d 50 04             	lea    0x4(%eax),%edx
  8004a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a8:	8b 00                	mov    (%eax),%eax
  8004aa:	99                   	cltd   
  8004ab:	31 d0                	xor    %edx,%eax
  8004ad:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004af:	83 f8 08             	cmp    $0x8,%eax
  8004b2:	7f 20                	jg     8004d4 <vprintfmt+0x13c>
  8004b4:	8b 14 85 60 17 80 00 	mov    0x801760(,%eax,4),%edx
  8004bb:	85 d2                	test   %edx,%edx
  8004bd:	74 15                	je     8004d4 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  8004bf:	52                   	push   %edx
  8004c0:	68 6a 15 80 00       	push   $0x80156a
  8004c5:	57                   	push   %edi
  8004c6:	56                   	push   %esi
  8004c7:	e8 af fe ff ff       	call   80037b <printfmt>
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	e9 7a 01 00 00       	jmp    80064e <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8004d4:	50                   	push   %eax
  8004d5:	68 61 15 80 00       	push   $0x801561
  8004da:	57                   	push   %edi
  8004db:	56                   	push   %esi
  8004dc:	e8 9a fe ff ff       	call   80037b <printfmt>
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	e9 65 01 00 00       	jmp    80064e <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8d 50 04             	lea    0x4(%eax),%edx
  8004ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f2:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  8004f4:	85 db                	test   %ebx,%ebx
  8004f6:	b8 5a 15 80 00       	mov    $0x80155a,%eax
  8004fb:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  8004fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800502:	0f 8e bd 00 00 00    	jle    8005c5 <vprintfmt+0x22d>
  800508:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050c:	75 0e                	jne    80051c <vprintfmt+0x184>
  80050e:	89 75 08             	mov    %esi,0x8(%ebp)
  800511:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800514:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800517:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80051a:	eb 6d                	jmp    800589 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	ff 75 d0             	pushl  -0x30(%ebp)
  800522:	53                   	push   %ebx
  800523:	e8 4d 02 00 00       	call   800775 <strnlen>
  800528:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052b:	29 c1                	sub    %eax,%ecx
  80052d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800530:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800533:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800537:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80053d:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	eb 0f                	jmp    800550 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	57                   	push   %edi
  800545:	ff 75 e0             	pushl  -0x20(%ebp)
  800548:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80054a:	83 eb 01             	sub    $0x1,%ebx
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	85 db                	test   %ebx,%ebx
  800552:	7f ed                	jg     800541 <vprintfmt+0x1a9>
  800554:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800557:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80055a:	85 c9                	test   %ecx,%ecx
  80055c:	b8 00 00 00 00       	mov    $0x0,%eax
  800561:	0f 49 c1             	cmovns %ecx,%eax
  800564:	29 c1                	sub    %eax,%ecx
  800566:	89 75 08             	mov    %esi,0x8(%ebp)
  800569:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056c:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80056f:	89 cf                	mov    %ecx,%edi
  800571:	eb 16                	jmp    800589 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800573:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800577:	75 31                	jne    8005aa <vprintfmt+0x212>
					putch(ch, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	50                   	push   %eax
  800580:	ff 55 08             	call   *0x8(%ebp)
  800583:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800586:	83 ef 01             	sub    $0x1,%edi
  800589:	83 c3 01             	add    $0x1,%ebx
  80058c:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  800590:	0f be c2             	movsbl %dl,%eax
  800593:	85 c0                	test   %eax,%eax
  800595:	74 50                	je     8005e7 <vprintfmt+0x24f>
  800597:	85 f6                	test   %esi,%esi
  800599:	78 d8                	js     800573 <vprintfmt+0x1db>
  80059b:	83 ee 01             	sub    $0x1,%esi
  80059e:	79 d3                	jns    800573 <vprintfmt+0x1db>
  8005a0:	89 fb                	mov    %edi,%ebx
  8005a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005a8:	eb 37                	jmp    8005e1 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8005aa:	0f be d2             	movsbl %dl,%edx
  8005ad:	83 ea 20             	sub    $0x20,%edx
  8005b0:	83 fa 5e             	cmp    $0x5e,%edx
  8005b3:	76 c4                	jbe    800579 <vprintfmt+0x1e1>
					putch('?', putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	ff 75 0c             	pushl  0xc(%ebp)
  8005bb:	6a 3f                	push   $0x3f
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	eb c1                	jmp    800586 <vprintfmt+0x1ee>
  8005c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005ce:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005d1:	eb b6                	jmp    800589 <vprintfmt+0x1f1>
				putch(' ', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	57                   	push   %edi
  8005d7:	6a 20                	push   $0x20
  8005d9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005db:	83 eb 01             	sub    $0x1,%ebx
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	85 db                	test   %ebx,%ebx
  8005e3:	7f ee                	jg     8005d3 <vprintfmt+0x23b>
  8005e5:	eb 67                	jmp    80064e <vprintfmt+0x2b6>
  8005e7:	89 fb                	mov    %edi,%ebx
  8005e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ec:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005ef:	eb f0                	jmp    8005e1 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  8005f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f4:	e8 33 fd ff ff       	call   80032c <getint>
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800604:	85 d2                	test   %edx,%edx
  800606:	79 2c                	jns    800634 <vprintfmt+0x29c>
				putch('-', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	57                   	push   %edi
  80060c:	6a 2d                	push   $0x2d
  80060e:	ff d6                	call   *%esi
				num = -(long long) num;
  800610:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800613:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800616:	f7 d8                	neg    %eax
  800618:	83 d2 00             	adc    $0x0,%edx
  80061b:	f7 da                	neg    %edx
  80061d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800620:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800625:	eb 0d                	jmp    800634 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800627:	8d 45 14             	lea    0x14(%ebp),%eax
  80062a:	e8 c3 fc ff ff       	call   8002f2 <getuint>
			base = 10;
  80062f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800634:	83 ec 0c             	sub    $0xc,%esp
  800637:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80063b:	53                   	push   %ebx
  80063c:	ff 75 e0             	pushl  -0x20(%ebp)
  80063f:	51                   	push   %ecx
  800640:	52                   	push   %edx
  800641:	50                   	push   %eax
  800642:	89 fa                	mov    %edi,%edx
  800644:	89 f0                	mov    %esi,%eax
  800646:	e8 f8 fb ff ff       	call   800243 <printnum>
			break;
  80064b:	83 c4 20             	add    $0x20,%esp
{
  80064e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800651:	83 c3 01             	add    $0x1,%ebx
  800654:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800658:	83 f8 25             	cmp    $0x25,%eax
  80065b:	0f 84 52 fd ff ff    	je     8003b3 <vprintfmt+0x1b>
			if (ch == '\0')
  800661:	85 c0                	test   %eax,%eax
  800663:	0f 84 84 00 00 00    	je     8006ed <vprintfmt+0x355>
			putch(ch, putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	57                   	push   %edi
  80066d:	50                   	push   %eax
  80066e:	ff d6                	call   *%esi
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	eb dc                	jmp    800651 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
  800678:	e8 75 fc ff ff       	call   8002f2 <getuint>
			base = 8;
  80067d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800682:	eb b0                	jmp    800634 <vprintfmt+0x29c>
			putch('0', putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	57                   	push   %edi
  800688:	6a 30                	push   $0x30
  80068a:	ff d6                	call   *%esi
			putch('x', putdat);
  80068c:	83 c4 08             	add    $0x8,%esp
  80068f:	57                   	push   %edi
  800690:	6a 78                	push   $0x78
  800692:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80069d:	8b 00                	mov    (%eax),%eax
  80069f:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8006a4:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8006a7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ac:	eb 86                	jmp    800634 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8006ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b1:	e8 3c fc ff ff       	call   8002f2 <getuint>
			base = 16;
  8006b6:	b9 10 00 00 00       	mov    $0x10,%ecx
  8006bb:	e9 74 ff ff ff       	jmp    800634 <vprintfmt+0x29c>
			putch(ch, putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	57                   	push   %edi
  8006c4:	6a 25                	push   $0x25
  8006c6:	ff d6                	call   *%esi
			break;
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	eb 81                	jmp    80064e <vprintfmt+0x2b6>
			putch('%', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	57                   	push   %edi
  8006d1:	6a 25                	push   $0x25
  8006d3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	89 d8                	mov    %ebx,%eax
  8006da:	eb 03                	jmp    8006df <vprintfmt+0x347>
  8006dc:	83 e8 01             	sub    $0x1,%eax
  8006df:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e3:	75 f7                	jne    8006dc <vprintfmt+0x344>
  8006e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e8:	e9 61 ff ff ff       	jmp    80064e <vprintfmt+0x2b6>
}
  8006ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5f                   	pop    %edi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800704:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800708:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800712:	85 c0                	test   %eax,%eax
  800714:	74 26                	je     80073c <vsnprintf+0x47>
  800716:	85 d2                	test   %edx,%edx
  800718:	7e 22                	jle    80073c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071a:	ff 75 14             	pushl  0x14(%ebp)
  80071d:	ff 75 10             	pushl  0x10(%ebp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	68 5e 03 80 00       	push   $0x80035e
  800729:	e8 6a fc ff ff       	call   800398 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800731:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800737:	83 c4 10             	add    $0x10,%esp
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    
		return -E_INVAL;
  80073c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800741:	eb f7                	jmp    80073a <vsnprintf+0x45>

00800743 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074c:	50                   	push   %eax
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	ff 75 08             	pushl  0x8(%ebp)
  800756:	e8 9a ff ff ff       	call   8006f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	eb 03                	jmp    80076d <strlen+0x10>
		n++;
  80076a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80076d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800771:	75 f7                	jne    80076a <strlen+0xd>
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
  800783:	eb 03                	jmp    800788 <strnlen+0x13>
		n++;
  800785:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800788:	39 d0                	cmp    %edx,%eax
  80078a:	74 06                	je     800792 <strnlen+0x1d>
  80078c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800790:	75 f3                	jne    800785 <strnlen+0x10>
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ef                	jne    8007a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bb:	53                   	push   %ebx
  8007bc:	e8 9c ff ff ff       	call   80075d <strlen>
  8007c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	01 d8                	add    %ebx,%eax
  8007c9:	50                   	push   %eax
  8007ca:	e8 c5 ff ff ff       	call   800794 <strcpy>
	return dst;
}
  8007cf:	89 d8                	mov    %ebx,%eax
  8007d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 75 08             	mov    0x8(%ebp),%esi
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	89 f3                	mov    %esi,%ebx
  8007e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e6:	89 f2                	mov    %esi,%edx
  8007e8:	eb 0f                	jmp    8007f9 <strncpy+0x23>
		*dst++ = *src;
  8007ea:	83 c2 01             	add    $0x1,%edx
  8007ed:	0f b6 01             	movzbl (%ecx),%eax
  8007f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007f9:	39 da                	cmp    %ebx,%edx
  8007fb:	75 ed                	jne    8007ea <strncpy+0x14>
	}
	return ret;
}
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800811:	89 f0                	mov    %esi,%eax
  800813:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800817:	85 c9                	test   %ecx,%ecx
  800819:	75 0b                	jne    800826 <strlcpy+0x23>
  80081b:	eb 17                	jmp    800834 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	83 c0 01             	add    $0x1,%eax
  800823:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800826:	39 d8                	cmp    %ebx,%eax
  800828:	74 07                	je     800831 <strlcpy+0x2e>
  80082a:	0f b6 0a             	movzbl (%edx),%ecx
  80082d:	84 c9                	test   %cl,%cl
  80082f:	75 ec                	jne    80081d <strlcpy+0x1a>
		*dst = '\0';
  800831:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800834:	29 f0                	sub    %esi,%eax
}
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800840:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800843:	eb 06                	jmp    80084b <strcmp+0x11>
		p++, q++;
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80084b:	0f b6 01             	movzbl (%ecx),%eax
  80084e:	84 c0                	test   %al,%al
  800850:	74 04                	je     800856 <strcmp+0x1c>
  800852:	3a 02                	cmp    (%edx),%al
  800854:	74 ef                	je     800845 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800856:	0f b6 c0             	movzbl %al,%eax
  800859:	0f b6 12             	movzbl (%edx),%edx
  80085c:	29 d0                	sub    %edx,%eax
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	53                   	push   %ebx
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	89 c3                	mov    %eax,%ebx
  80086c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086f:	eb 06                	jmp    800877 <strncmp+0x17>
		n--, p++, q++;
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800877:	39 d8                	cmp    %ebx,%eax
  800879:	74 16                	je     800891 <strncmp+0x31>
  80087b:	0f b6 08             	movzbl (%eax),%ecx
  80087e:	84 c9                	test   %cl,%cl
  800880:	74 04                	je     800886 <strncmp+0x26>
  800882:	3a 0a                	cmp    (%edx),%cl
  800884:	74 eb                	je     800871 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800886:	0f b6 00             	movzbl (%eax),%eax
  800889:	0f b6 12             	movzbl (%edx),%edx
  80088c:	29 d0                	sub    %edx,%eax
}
  80088e:	5b                   	pop    %ebx
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb f6                	jmp    80088e <strncmp+0x2e>

00800898 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a2:	0f b6 10             	movzbl (%eax),%edx
  8008a5:	84 d2                	test   %dl,%dl
  8008a7:	74 09                	je     8008b2 <strchr+0x1a>
		if (*s == c)
  8008a9:	38 ca                	cmp    %cl,%dl
  8008ab:	74 0a                	je     8008b7 <strchr+0x1f>
	for (; *s; s++)
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	eb f0                	jmp    8008a2 <strchr+0xa>
			return (char *) s;
	return 0;
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c3:	eb 03                	jmp    8008c8 <strfind+0xf>
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cb:	38 ca                	cmp    %cl,%dl
  8008cd:	74 04                	je     8008d3 <strfind+0x1a>
  8008cf:	84 d2                	test   %dl,%dl
  8008d1:	75 f2                	jne    8008c5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	57                   	push   %edi
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 55 08             	mov    0x8(%ebp),%edx
  8008de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008e1:	85 c9                	test   %ecx,%ecx
  8008e3:	74 12                	je     8008f7 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e5:	f6 c2 03             	test   $0x3,%dl
  8008e8:	75 05                	jne    8008ef <memset+0x1a>
  8008ea:	f6 c1 03             	test   $0x3,%cl
  8008ed:	74 0f                	je     8008fe <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ef:	89 d7                	mov    %edx,%edi
  8008f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f4:	fc                   	cld    
  8008f5:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008f7:	89 d0                	mov    %edx,%eax
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    
		c &= 0xFF;
  8008fe:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800902:	89 d8                	mov    %ebx,%eax
  800904:	c1 e0 08             	shl    $0x8,%eax
  800907:	89 df                	mov    %ebx,%edi
  800909:	c1 e7 18             	shl    $0x18,%edi
  80090c:	89 de                	mov    %ebx,%esi
  80090e:	c1 e6 10             	shl    $0x10,%esi
  800911:	09 f7                	or     %esi,%edi
  800913:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800915:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800918:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80091a:	89 d7                	mov    %edx,%edi
  80091c:	fc                   	cld    
  80091d:	f3 ab                	rep stos %eax,%es:(%edi)
  80091f:	eb d6                	jmp    8008f7 <memset+0x22>

00800921 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092f:	39 c6                	cmp    %eax,%esi
  800931:	73 35                	jae    800968 <memmove+0x47>
  800933:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800936:	39 c2                	cmp    %eax,%edx
  800938:	76 2e                	jbe    800968 <memmove+0x47>
		s += n;
		d += n;
  80093a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093d:	89 d6                	mov    %edx,%esi
  80093f:	09 fe                	or     %edi,%esi
  800941:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800947:	74 0c                	je     800955 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800949:	83 ef 01             	sub    $0x1,%edi
  80094c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80094f:	fd                   	std    
  800950:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800952:	fc                   	cld    
  800953:	eb 21                	jmp    800976 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 ef                	jne    800949 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095a:	83 ef 04             	sub    $0x4,%edi
  80095d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800960:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800963:	fd                   	std    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb ea                	jmp    800952 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800968:	89 f2                	mov    %esi,%edx
  80096a:	09 c2                	or     %eax,%edx
  80096c:	f6 c2 03             	test   $0x3,%dl
  80096f:	74 09                	je     80097a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 f2                	jne    800971 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb ed                	jmp    800976 <memmove+0x55>

00800989 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098c:	ff 75 10             	pushl  0x10(%ebp)
  80098f:	ff 75 0c             	pushl  0xc(%ebp)
  800992:	ff 75 08             	pushl  0x8(%ebp)
  800995:	e8 87 ff ff ff       	call   800921 <memmove>
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a7:	89 c6                	mov    %eax,%esi
  8009a9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ac:	39 f0                	cmp    %esi,%eax
  8009ae:	74 1c                	je     8009cc <memcmp+0x30>
		if (*s1 != *s2)
  8009b0:	0f b6 08             	movzbl (%eax),%ecx
  8009b3:	0f b6 1a             	movzbl (%edx),%ebx
  8009b6:	38 d9                	cmp    %bl,%cl
  8009b8:	75 08                	jne    8009c2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	83 c2 01             	add    $0x1,%edx
  8009c0:	eb ea                	jmp    8009ac <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009c2:	0f b6 c1             	movzbl %cl,%eax
  8009c5:	0f b6 db             	movzbl %bl,%ebx
  8009c8:	29 d8                	sub    %ebx,%eax
  8009ca:	eb 05                	jmp    8009d1 <memcmp+0x35>
	}

	return 0;
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009de:	89 c2                	mov    %eax,%edx
  8009e0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e3:	39 d0                	cmp    %edx,%eax
  8009e5:	73 09                	jae    8009f0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e7:	38 08                	cmp    %cl,(%eax)
  8009e9:	74 05                	je     8009f0 <memfind+0x1b>
	for (; s < ends; s++)
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	eb f3                	jmp    8009e3 <memfind+0xe>
			break;
	return (void *) s;
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	57                   	push   %edi
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fe:	eb 03                	jmp    800a03 <strtol+0x11>
		s++;
  800a00:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a03:	0f b6 01             	movzbl (%ecx),%eax
  800a06:	3c 20                	cmp    $0x20,%al
  800a08:	74 f6                	je     800a00 <strtol+0xe>
  800a0a:	3c 09                	cmp    $0x9,%al
  800a0c:	74 f2                	je     800a00 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a0e:	3c 2b                	cmp    $0x2b,%al
  800a10:	74 2e                	je     800a40 <strtol+0x4e>
	int neg = 0;
  800a12:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a17:	3c 2d                	cmp    $0x2d,%al
  800a19:	74 2f                	je     800a4a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a21:	75 05                	jne    800a28 <strtol+0x36>
  800a23:	80 39 30             	cmpb   $0x30,(%ecx)
  800a26:	74 2c                	je     800a54 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a28:	85 db                	test   %ebx,%ebx
  800a2a:	75 0a                	jne    800a36 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a31:	80 39 30             	cmpb   $0x30,(%ecx)
  800a34:	74 28                	je     800a5e <strtol+0x6c>
		base = 10;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a3e:	eb 50                	jmp    800a90 <strtol+0x9e>
		s++;
  800a40:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a43:	bf 00 00 00 00       	mov    $0x0,%edi
  800a48:	eb d1                	jmp    800a1b <strtol+0x29>
		s++, neg = 1;
  800a4a:	83 c1 01             	add    $0x1,%ecx
  800a4d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a52:	eb c7                	jmp    800a1b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a54:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a58:	74 0e                	je     800a68 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a5a:	85 db                	test   %ebx,%ebx
  800a5c:	75 d8                	jne    800a36 <strtol+0x44>
		s++, base = 8;
  800a5e:	83 c1 01             	add    $0x1,%ecx
  800a61:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a66:	eb ce                	jmp    800a36 <strtol+0x44>
		s += 2, base = 16;
  800a68:	83 c1 02             	add    $0x2,%ecx
  800a6b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a70:	eb c4                	jmp    800a36 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a72:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a75:	89 f3                	mov    %esi,%ebx
  800a77:	80 fb 19             	cmp    $0x19,%bl
  800a7a:	77 29                	ja     800aa5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a7c:	0f be d2             	movsbl %dl,%edx
  800a7f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a82:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a85:	7d 30                	jge    800ab7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a87:	83 c1 01             	add    $0x1,%ecx
  800a8a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a90:	0f b6 11             	movzbl (%ecx),%edx
  800a93:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a96:	89 f3                	mov    %esi,%ebx
  800a98:	80 fb 09             	cmp    $0x9,%bl
  800a9b:	77 d5                	ja     800a72 <strtol+0x80>
			dig = *s - '0';
  800a9d:	0f be d2             	movsbl %dl,%edx
  800aa0:	83 ea 30             	sub    $0x30,%edx
  800aa3:	eb dd                	jmp    800a82 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800aa5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa8:	89 f3                	mov    %esi,%ebx
  800aaa:	80 fb 19             	cmp    $0x19,%bl
  800aad:	77 08                	ja     800ab7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aaf:	0f be d2             	movsbl %dl,%edx
  800ab2:	83 ea 37             	sub    $0x37,%edx
  800ab5:	eb cb                	jmp    800a82 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abb:	74 05                	je     800ac2 <strtol+0xd0>
		*endptr = (char *) s;
  800abd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac2:	89 c2                	mov    %eax,%edx
  800ac4:	f7 da                	neg    %edx
  800ac6:	85 ff                	test   %edi,%edi
  800ac8:	0f 45 c2             	cmovne %edx,%eax
}
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
  800ad6:	83 ec 1c             	sub    $0x1c,%esp
  800ad9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800adc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800adf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae7:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aea:	8b 75 14             	mov    0x14(%ebp),%esi
  800aed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800af3:	74 04                	je     800af9 <syscall+0x29>
  800af5:	85 c0                	test   %eax,%eax
  800af7:	7f 08                	jg     800b01 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    
  800b01:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800b04:	83 ec 0c             	sub    $0xc,%esp
  800b07:	50                   	push   %eax
  800b08:	52                   	push   %edx
  800b09:	68 84 17 80 00       	push   $0x801784
  800b0e:	6a 23                	push   $0x23
  800b10:	68 a1 17 80 00       	push   $0x8017a1
  800b15:	e8 3a f6 ff ff       	call   800154 <_panic>

00800b1a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b20:	6a 00                	push   $0x0
  800b22:	6a 00                	push   $0x0
  800b24:	6a 00                	push   $0x0
  800b26:	ff 75 0c             	pushl  0xc(%ebp)
  800b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	e8 95 ff ff ff       	call   800ad0 <syscall>
}
  800b3b:	83 c4 10             	add    $0x10,%esp
  800b3e:	c9                   	leave  
  800b3f:	c3                   	ret    

00800b40 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b46:	6a 00                	push   $0x0
  800b48:	6a 00                	push   $0x0
  800b4a:	6a 00                	push   $0x0
  800b4c:	6a 00                	push   $0x0
  800b4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5d:	e8 6e ff ff ff       	call   800ad0 <syscall>
}
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b6a:	6a 00                	push   $0x0
  800b6c:	6a 00                	push   $0x0
  800b6e:	6a 00                	push   $0x0
  800b70:	6a 00                	push   $0x0
  800b72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b75:	ba 01 00 00 00       	mov    $0x1,%edx
  800b7a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7f:	e8 4c ff ff ff       	call   800ad0 <syscall>
}
  800b84:	c9                   	leave  
  800b85:	c3                   	ret    

00800b86 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b8c:	6a 00                	push   $0x0
  800b8e:	6a 00                	push   $0x0
  800b90:	6a 00                	push   $0x0
  800b92:	6a 00                	push   $0x0
  800b94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b99:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9e:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba3:	e8 28 ff ff ff       	call   800ad0 <syscall>
}
  800ba8:	c9                   	leave  
  800ba9:	c3                   	ret    

00800baa <sys_yield>:

void
sys_yield(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bb0:	6a 00                	push   $0x0
  800bb2:	6a 00                	push   $0x0
  800bb4:	6a 00                	push   $0x0
  800bb6:	6a 00                	push   $0x0
  800bb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc7:	e8 04 ff ff ff       	call   800ad0 <syscall>
}
  800bcc:	83 c4 10             	add    $0x10,%esp
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bd7:	6a 00                	push   $0x0
  800bd9:	6a 00                	push   $0x0
  800bdb:	ff 75 10             	pushl  0x10(%ebp)
  800bde:	ff 75 0c             	pushl  0xc(%ebp)
  800be1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be4:	ba 01 00 00 00       	mov    $0x1,%edx
  800be9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bee:	e8 dd fe ff ff       	call   800ad0 <syscall>
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bfb:	ff 75 18             	pushl  0x18(%ebp)
  800bfe:	ff 75 14             	pushl  0x14(%ebp)
  800c01:	ff 75 10             	pushl  0x10(%ebp)
  800c04:	ff 75 0c             	pushl  0xc(%ebp)
  800c07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c14:	e8 b7 fe ff ff       	call   800ad0 <syscall>
}
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c21:	6a 00                	push   $0x0
  800c23:	6a 00                	push   $0x0
  800c25:	6a 00                	push   $0x0
  800c27:	ff 75 0c             	pushl  0xc(%ebp)
  800c2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c32:	b8 06 00 00 00       	mov    $0x6,%eax
  800c37:	e8 94 fe ff ff       	call   800ad0 <syscall>
}
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c44:	6a 00                	push   $0x0
  800c46:	6a 00                	push   $0x0
  800c48:	6a 00                	push   $0x0
  800c4a:	ff 75 0c             	pushl  0xc(%ebp)
  800c4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c50:	ba 01 00 00 00       	mov    $0x1,%edx
  800c55:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5a:	e8 71 fe ff ff       	call   800ad0 <syscall>
}
  800c5f:	c9                   	leave  
  800c60:	c3                   	ret    

00800c61 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c67:	6a 00                	push   $0x0
  800c69:	6a 00                	push   $0x0
  800c6b:	6a 00                	push   $0x0
  800c6d:	ff 75 0c             	pushl  0xc(%ebp)
  800c70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c73:	ba 01 00 00 00       	mov    $0x1,%edx
  800c78:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7d:	e8 4e fe ff ff       	call   800ad0 <syscall>
}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c8a:	6a 00                	push   $0x0
  800c8c:	ff 75 14             	pushl  0x14(%ebp)
  800c8f:	ff 75 10             	pushl  0x10(%ebp)
  800c92:	ff 75 0c             	pushl  0xc(%ebp)
  800c95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c98:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca2:	e8 29 fe ff ff       	call   800ad0 <syscall>
}
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800caf:	6a 00                	push   $0x0
  800cb1:	6a 00                	push   $0x0
  800cb3:	6a 00                	push   $0x0
  800cb5:	6a 00                	push   $0x0
  800cb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cba:	ba 01 00 00 00       	mov    $0x1,%edx
  800cbf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc4:	e8 07 fe ff ff       	call   800ad0 <syscall>
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
	int r;

	void *addr = (void*)(pn << PGSHIFT);
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800cd5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800cdc:	89 ca                	mov    %ecx,%edx
  800cde:	83 e2 05             	and    $0x5,%edx
  800ce1:	83 fa 05             	cmp    $0x5,%edx
  800ce4:	75 5a                	jne    800d40 <duppage+0x75>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800ce6:	89 ca                	mov    %ecx,%edx
  800ce8:	83 e2 18             	and    $0x18,%edx
		perm |= PTE_PCD | PTE_PWT;
  800ceb:	83 fa 01             	cmp    $0x1,%edx
  800cee:	19 d2                	sbb    %edx,%edx
  800cf0:	83 e2 e8             	and    $0xffffffe8,%edx
  800cf3:	83 c2 1d             	add    $0x1d,%edx


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800cf6:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800cfc:	74 68                	je     800d66 <duppage+0x9b>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800cfe:	89 d3                	mov    %edx,%ebx
  800d00:	80 cf 08             	or     $0x8,%bh
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	53                   	push   %ebx
  800d07:	56                   	push   %esi
  800d08:	50                   	push   %eax
  800d09:	56                   	push   %esi
  800d0a:	6a 00                	push   $0x0
  800d0c:	e8 e4 fe ff ff       	call   800bf5 <sys_page_map>
  800d11:	83 c4 20             	add    $0x20,%esp
  800d14:	85 c0                	test   %eax,%eax
  800d16:	78 3c                	js     800d54 <duppage+0x89>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	53                   	push   %ebx
  800d1c:	56                   	push   %esi
  800d1d:	6a 00                	push   $0x0
  800d1f:	56                   	push   %esi
  800d20:	6a 00                	push   $0x0
  800d22:	e8 ce fe ff ff       	call   800bf5 <sys_page_map>
  800d27:	83 c4 20             	add    $0x20,%esp
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	79 4d                	jns    800d7b <duppage+0xb0>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800d2e:	50                   	push   %eax
  800d2f:	68 0c 18 80 00       	push   $0x80180c
  800d34:	6a 57                	push   $0x57
  800d36:	68 04 19 80 00       	push   $0x801904
  800d3b:	e8 14 f4 ff ff       	call   800154 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800d40:	83 ec 04             	sub    $0x4,%esp
  800d43:	68 b0 17 80 00       	push   $0x8017b0
  800d48:	6a 47                	push   $0x47
  800d4a:	68 04 19 80 00       	push   $0x801904
  800d4f:	e8 00 f4 ff ff       	call   800154 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800d54:	50                   	push   %eax
  800d55:	68 e0 17 80 00       	push   $0x8017e0
  800d5a:	6a 53                	push   $0x53
  800d5c:	68 04 19 80 00       	push   $0x801904
  800d61:	e8 ee f3 ff ff       	call   800154 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	52                   	push   %edx
  800d6a:	56                   	push   %esi
  800d6b:	50                   	push   %eax
  800d6c:	56                   	push   %esi
  800d6d:	6a 00                	push   $0x0
  800d6f:	e8 81 fe ff ff       	call   800bf5 <sys_page_map>
  800d74:	83 c4 20             	add    $0x20,%esp
  800d77:	85 c0                	test   %eax,%eax
  800d79:	78 0c                	js     800d87 <duppage+0xbc>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800d87:	50                   	push   %eax
  800d88:	68 34 18 80 00       	push   $0x801834
  800d8d:	6a 5b                	push   $0x5b
  800d8f:	68 04 19 80 00       	push   $0x801904
  800d94:	e8 bb f3 ff ff       	call   800154 <_panic>

00800d99 <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void*)(pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800da4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800dab:	a8 01                	test   $0x1,%al
  800dad:	74 38                	je     800de7 <dup_or_share+0x4e>
  800daf:	89 cb                	mov    %ecx,%ebx
  800db1:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800db3:	21 c3                	and    %eax,%ebx
  800db5:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
  800db8:	89 c1                	mov    %eax,%ecx
  800dba:	83 e1 18             	and    $0x18,%ecx
		perm |= PTE_PCD | PTE_PWT;
  800dbd:	89 da                	mov    %ebx,%edx
  800dbf:	83 ca 18             	or     $0x18,%edx
  800dc2:	85 c9                	test   %ecx,%ecx
  800dc4:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void*)(pnum << PGSHIFT);
  800dc7:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800dca:	83 e0 1a             	and    $0x1a,%eax
  800dcd:	83 f8 02             	cmp    $0x2,%eax
  800dd0:	74 32                	je     800e04 <dup_or_share+0x6b>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	53                   	push   %ebx
  800dd6:	56                   	push   %esi
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	6a 00                	push   $0x0
  800ddb:	e8 15 fe ff ff       	call   800bf5 <sys_page_map>
  800de0:	83 c4 20             	add    $0x20,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	78 08                	js     800def <dup_or_share+0x56>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800de7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800def:	50                   	push   %eax
  800df0:	68 60 18 80 00       	push   $0x801860
  800df5:	68 84 00 00 00       	push   $0x84
  800dfa:	68 04 19 80 00       	push   $0x801904
  800dff:	e8 50 f3 ff ff       	call   800154 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800e04:	83 ec 04             	sub    $0x4,%esp
  800e07:	53                   	push   %ebx
  800e08:	56                   	push   %esi
  800e09:	57                   	push   %edi
  800e0a:	e8 c2 fd ff ff       	call   800bd1 <sys_page_alloc>
  800e0f:	83 c4 10             	add    $0x10,%esp
  800e12:	85 c0                	test   %eax,%eax
  800e14:	78 57                	js     800e6d <dup_or_share+0xd4>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	53                   	push   %ebx
  800e1a:	68 00 00 40 00       	push   $0x400000
  800e1f:	6a 00                	push   $0x0
  800e21:	56                   	push   %esi
  800e22:	57                   	push   %edi
  800e23:	e8 cd fd ff ff       	call   800bf5 <sys_page_map>
  800e28:	83 c4 20             	add    $0x20,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	78 53                	js     800e82 <dup_or_share+0xe9>
		memmove(UTEMP, addr, PGSIZE);
  800e2f:	83 ec 04             	sub    $0x4,%esp
  800e32:	68 00 10 00 00       	push   $0x1000
  800e37:	56                   	push   %esi
  800e38:	68 00 00 40 00       	push   $0x400000
  800e3d:	e8 df fa ff ff       	call   800921 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e42:	83 c4 08             	add    $0x8,%esp
  800e45:	68 00 00 40 00       	push   $0x400000
  800e4a:	6a 00                	push   $0x0
  800e4c:	e8 ca fd ff ff       	call   800c1b <sys_page_unmap>
  800e51:	83 c4 10             	add    $0x10,%esp
  800e54:	85 c0                	test   %eax,%eax
  800e56:	79 8f                	jns    800de7 <dup_or_share+0x4e>
			panic("sys_page_unmap: %e", r);
  800e58:	50                   	push   %eax
  800e59:	68 4e 19 80 00       	push   $0x80194e
  800e5e:	68 8d 00 00 00       	push   $0x8d
  800e63:	68 04 19 80 00       	push   $0x801904
  800e68:	e8 e7 f2 ff ff       	call   800154 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800e6d:	50                   	push   %eax
  800e6e:	68 80 18 80 00       	push   $0x801880
  800e73:	68 88 00 00 00       	push   $0x88
  800e78:	68 04 19 80 00       	push   $0x801904
  800e7d:	e8 d2 f2 ff ff       	call   800154 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e82:	50                   	push   %eax
  800e83:	68 60 18 80 00       	push   $0x801860
  800e88:	68 8a 00 00 00       	push   $0x8a
  800e8d:	68 04 19 80 00       	push   $0x801904
  800e92:	e8 bd f2 ff ff       	call   800154 <_panic>

00800e97 <pgfault>:
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	53                   	push   %ebx
  800e9b:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t)addr) >> PGSHIFT];
  800ea3:	89 d8                	mov    %ebx,%eax
  800ea5:	c1 e8 0c             	shr    $0xc,%eax
  800ea8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800eaf:	6a 07                	push   $0x7
  800eb1:	68 00 f0 7f 00       	push   $0x7ff000
  800eb6:	6a 00                	push   $0x0
  800eb8:	e8 14 fd ff ff       	call   800bd1 <sys_page_alloc>
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	78 51                	js     800f15 <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800ec4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	68 00 10 00 00       	push   $0x1000
  800ed2:	53                   	push   %ebx
  800ed3:	68 00 f0 7f 00       	push   $0x7ff000
  800ed8:	e8 44 fa ff ff       	call   800921 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800edd:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ee4:	53                   	push   %ebx
  800ee5:	6a 00                	push   $0x0
  800ee7:	68 00 f0 7f 00       	push   $0x7ff000
  800eec:	6a 00                	push   $0x0
  800eee:	e8 02 fd ff ff       	call   800bf5 <sys_page_map>
  800ef3:	83 c4 20             	add    $0x20,%esp
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	78 2d                	js     800f27 <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800efa:	83 ec 08             	sub    $0x8,%esp
  800efd:	68 00 f0 7f 00       	push   $0x7ff000
  800f02:	6a 00                	push   $0x0
  800f04:	e8 12 fd ff ff       	call   800c1b <sys_page_unmap>
  800f09:	83 c4 10             	add    $0x10,%esp
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	78 29                	js     800f39 <pgfault+0xa2>
}
  800f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800f15:	50                   	push   %eax
  800f16:	68 0f 19 80 00       	push   $0x80190f
  800f1b:	6a 27                	push   $0x27
  800f1d:	68 04 19 80 00       	push   $0x801904
  800f22:	e8 2d f2 ff ff       	call   800154 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800f27:	50                   	push   %eax
  800f28:	68 2b 19 80 00       	push   $0x80192b
  800f2d:	6a 2c                	push   $0x2c
  800f2f:	68 04 19 80 00       	push   $0x801904
  800f34:	e8 1b f2 ff ff       	call   800154 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800f39:	50                   	push   %eax
  800f3a:	68 45 19 80 00       	push   $0x801945
  800f3f:	6a 2f                	push   $0x2f
  800f41:	68 04 19 80 00       	push   $0x801904
  800f46:	e8 09 f2 ff ff       	call   800154 <_panic>

00800f4b <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f54:	b8 07 00 00 00       	mov    $0x7,%eax
  800f59:	cd 30                	int    $0x30
  800f5b:	89 c7                	mov    %eax,%edi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 24                	js     800f85 <fork_v0+0x3a>
  800f61:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f63:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	75 39                	jne    800fa5 <fork_v0+0x5a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f6c:	e8 15 fc ff ff       	call   800b86 <sys_getenvid>
  800f71:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f76:	c1 e0 07             	shl    $0x7,%eax
  800f79:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f7e:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f83:	eb 56                	jmp    800fdb <fork_v0+0x90>
		panic("sys_exofork: %e", envid);
  800f85:	50                   	push   %eax
  800f86:	68 61 19 80 00       	push   $0x801961
  800f8b:	68 a2 00 00 00       	push   $0xa2
  800f90:	68 04 19 80 00       	push   $0x801904
  800f95:	e8 ba f1 ff ff       	call   800154 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f9a:	83 c3 01             	add    $0x1,%ebx
  800f9d:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800fa3:	74 24                	je     800fc9 <fork_v0+0x7e>
		pde_t pde = uvpd[pnum >> 10];
  800fa5:	89 d8                	mov    %ebx,%eax
  800fa7:	c1 e8 0a             	shr    $0xa,%eax
  800faa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800fb1:	83 e0 05             	and    $0x5,%eax
  800fb4:	83 f8 05             	cmp    $0x5,%eax
  800fb7:	75 e1                	jne    800f9a <fork_v0+0x4f>
			continue;
		dup_or_share(envid, pnum, perm);
  800fb9:	b9 07 00 00 00       	mov    $0x7,%ecx
  800fbe:	89 da                	mov    %ebx,%edx
  800fc0:	89 f0                	mov    %esi,%eax
  800fc2:	e8 d2 fd ff ff       	call   800d99 <dup_or_share>
  800fc7:	eb d1                	jmp    800f9a <fork_v0+0x4f>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800fc9:	83 ec 08             	sub    $0x8,%esp
  800fcc:	6a 02                	push   $0x2
  800fce:	57                   	push   %edi
  800fcf:	e8 6a fc ff ff       	call   800c3e <sys_env_set_status>
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 0a                	js     800fe5 <fork_v0+0x9a>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800fdb:	89 f8                	mov    %edi,%eax
  800fdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800fe5:	50                   	push   %eax
  800fe6:	68 71 19 80 00       	push   $0x801971
  800feb:	68 b8 00 00 00       	push   $0xb8
  800ff0:	68 04 19 80 00       	push   $0x801904
  800ff5:	e8 5a f1 ff ff       	call   800154 <_panic>

00800ffa <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	57                   	push   %edi
  800ffe:	56                   	push   %esi
  800fff:	53                   	push   %ebx
  801000:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  801003:	68 97 0e 80 00       	push   $0x800e97
  801008:	e8 2b 02 00 00       	call   801238 <set_pgfault_handler>
  80100d:	b8 07 00 00 00       	mov    $0x7,%eax
  801012:	cd 30                	int    $0x30
  801014:	89 c7                	mov    %eax,%edi

	envid_t envid = sys_exofork();
	if (envid < 0)
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 27                	js     801044 <fork+0x4a>
  80101d:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  80101f:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  801024:	85 c0                	test   %eax,%eax
  801026:	75 44                	jne    80106c <fork+0x72>
		thisenv = &envs[ENVX(sys_getenvid())];
  801028:	e8 59 fb ff ff       	call   800b86 <sys_getenvid>
  80102d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801032:	c1 e0 07             	shl    $0x7,%eax
  801035:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80103a:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80103f:	e9 98 00 00 00       	jmp    8010dc <fork+0xe2>
		panic("sys_exofork: %e", envid);
  801044:	50                   	push   %eax
  801045:	68 61 19 80 00       	push   $0x801961
  80104a:	68 d6 00 00 00       	push   $0xd6
  80104f:	68 04 19 80 00       	push   $0x801904
  801054:	e8 fb f0 ff ff       	call   800154 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  801059:	83 c3 01             	add    $0x1,%ebx
  80105c:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801062:	77 36                	ja     80109a <fork+0xa0>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  801064:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80106a:	74 ed                	je     801059 <fork+0x5f>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	c1 e8 0a             	shr    $0xa,%eax
  801071:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  801078:	83 e0 05             	and    $0x5,%eax
  80107b:	83 f8 05             	cmp    $0x5,%eax
  80107e:	75 d9                	jne    801059 <fork+0x5f>
			continue;

		pte_t pte = uvpt[pnum];
  801080:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  801087:	83 e0 05             	and    $0x5,%eax
  80108a:	83 f8 05             	cmp    $0x5,%eax
  80108d:	75 ca                	jne    801059 <fork+0x5f>
			continue;
		duppage(envid, pnum);
  80108f:	89 da                	mov    %ebx,%edx
  801091:	89 f0                	mov    %esi,%eax
  801093:	e8 33 fc ff ff       	call   800ccb <duppage>
  801098:	eb bf                	jmp    801059 <fork+0x5f>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void*)exstk, PTE_U | PTE_P | PTE_W);
  80109a:	83 ec 04             	sub    $0x4,%esp
  80109d:	6a 07                	push   $0x7
  80109f:	68 00 f0 bf ee       	push   $0xeebff000
  8010a4:	57                   	push   %edi
  8010a5:	e8 27 fb ff ff       	call   800bd1 <sys_page_alloc>
	if (r < 0)
  8010aa:	83 c4 10             	add    $0x10,%esp
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	78 35                	js     8010e6 <fork+0xec>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010b1:	a1 04 20 80 00       	mov    0x802004,%eax
  8010b6:	8b 40 68             	mov    0x68(%eax),%eax
  8010b9:	83 ec 08             	sub    $0x8,%esp
  8010bc:	50                   	push   %eax
  8010bd:	57                   	push   %edi
  8010be:	e8 9e fb ff ff       	call   800c61 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	78 31                	js     8010fb <fork+0x101>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010ca:	83 ec 08             	sub    $0x8,%esp
  8010cd:	6a 02                	push   $0x2
  8010cf:	57                   	push   %edi
  8010d0:	e8 69 fb ff ff       	call   800c3e <sys_env_set_status>
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 34                	js     801110 <fork+0x116>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  8010dc:	89 f8                	mov    %edi,%eax
  8010de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  8010e6:	50                   	push   %eax
  8010e7:	68 a4 18 80 00       	push   $0x8018a4
  8010ec:	68 f3 00 00 00       	push   $0xf3
  8010f1:	68 04 19 80 00       	push   $0x801904
  8010f6:	e8 59 f0 ff ff       	call   800154 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  8010fb:	50                   	push   %eax
  8010fc:	68 d0 18 80 00       	push   $0x8018d0
  801101:	68 f6 00 00 00       	push   $0xf6
  801106:	68 04 19 80 00       	push   $0x801904
  80110b:	e8 44 f0 ff ff       	call   800154 <_panic>
		panic("sys_env_set_status: %e", r);
  801110:	50                   	push   %eax
  801111:	68 71 19 80 00       	push   $0x801971
  801116:	68 f9 00 00 00       	push   $0xf9
  80111b:	68 04 19 80 00       	push   $0x801904
  801120:	e8 2f f0 ff ff       	call   800154 <_panic>

00801125 <sfork>:

// Challenge!
int
sfork(void)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80112b:	68 88 19 80 00       	push   $0x801988
  801130:	68 02 01 00 00       	push   $0x102
  801135:	68 04 19 80 00       	push   $0x801904
  80113a:	e8 15 f0 ff ff       	call   800154 <_panic>

0080113f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	8b 75 08             	mov    0x8(%ebp),%esi
  801147:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int err = sys_ipc_recv(pg);
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	ff 75 0c             	pushl  0xc(%ebp)
  801150:	e8 54 fb ff ff       	call   800ca9 <sys_ipc_recv>

	if (from_env_store)
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	85 f6                	test   %esi,%esi
  80115a:	74 14                	je     801170 <ipc_recv+0x31>
		*from_env_store = (!err) ? thisenv->env_ipc_from : 0;
  80115c:	ba 00 00 00 00       	mov    $0x0,%edx
  801161:	85 c0                	test   %eax,%eax
  801163:	75 09                	jne    80116e <ipc_recv+0x2f>
  801165:	8b 15 04 20 80 00    	mov    0x802004,%edx
  80116b:	8b 52 78             	mov    0x78(%edx),%edx
  80116e:	89 16                	mov    %edx,(%esi)

	if (perm_store)
  801170:	85 db                	test   %ebx,%ebx
  801172:	74 14                	je     801188 <ipc_recv+0x49>
		*perm_store = (!err) ? thisenv->env_ipc_perm : 0;
  801174:	ba 00 00 00 00       	mov    $0x0,%edx
  801179:	85 c0                	test   %eax,%eax
  80117b:	75 09                	jne    801186 <ipc_recv+0x47>
  80117d:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801183:	8b 52 7c             	mov    0x7c(%edx),%edx
  801186:	89 13                	mov    %edx,(%ebx)

	if (!err) err = thisenv->env_ipc_value;
  801188:	85 c0                	test   %eax,%eax
  80118a:	75 08                	jne    801194 <ipc_recv+0x55>
  80118c:	a1 04 20 80 00       	mov    0x802004,%eax
  801191:	8b 40 74             	mov    0x74(%eax),%eax
	
	return err;
}
  801194:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    

0080119b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	57                   	push   %edi
  80119f:	56                   	push   %esi
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011aa:	8b 7d 14             	mov    0x14(%ebp),%edi
	if (!pg)
  8011ad:	85 db                	test   %ebx,%ebx
		pg = (void*) UTOP;
  8011af:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011b4:	0f 44 d8             	cmove  %eax,%ebx
	int r = sys_ipc_try_send(to_env, val, pg, perm);
  8011b7:	57                   	push   %edi
  8011b8:	53                   	push   %ebx
  8011b9:	56                   	push   %esi
  8011ba:	ff 75 08             	pushl  0x8(%ebp)
  8011bd:	e8 c2 fa ff ff       	call   800c84 <sys_ipc_try_send>
	while (r == -E_IPC_NOT_RECV) {
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	eb 13                	jmp    8011da <ipc_send+0x3f>
		sys_yield();
  8011c7:	e8 de f9 ff ff       	call   800baa <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011cc:	57                   	push   %edi
  8011cd:	53                   	push   %ebx
  8011ce:	56                   	push   %esi
  8011cf:	ff 75 08             	pushl  0x8(%ebp)
  8011d2:	e8 ad fa ff ff       	call   800c84 <sys_ipc_try_send>
  8011d7:	83 c4 10             	add    $0x10,%esp
	while (r == -E_IPC_NOT_RECV) {
  8011da:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011dd:	74 e8                	je     8011c7 <ipc_send+0x2c>
	}

	if (r < 0) panic("ipc_send: %e", r);
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 08                	js     8011eb <ipc_send+0x50>
}
  8011e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    
	if (r < 0) panic("ipc_send: %e", r);
  8011eb:	50                   	push   %eax
  8011ec:	68 9e 19 80 00       	push   $0x80199e
  8011f1:	6a 39                	push   $0x39
  8011f3:	68 ab 19 80 00       	push   $0x8019ab
  8011f8:	e8 57 ef ff ff       	call   800154 <_panic>

008011fd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801203:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801208:	89 c2                	mov    %eax,%edx
  80120a:	c1 e2 07             	shl    $0x7,%edx
  80120d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801213:	8b 52 50             	mov    0x50(%edx),%edx
  801216:	39 ca                	cmp    %ecx,%edx
  801218:	74 11                	je     80122b <ipc_find_env+0x2e>
	for (i = 0; i < NENV; i++)
  80121a:	83 c0 01             	add    $0x1,%eax
  80121d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801222:	75 e4                	jne    801208 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801224:	b8 00 00 00 00       	mov    $0x0,%eax
  801229:	eb 0b                	jmp    801236 <ipc_find_env+0x39>
			return envs[i].env_id;
  80122b:	c1 e0 07             	shl    $0x7,%eax
  80122e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801233:	8b 40 48             	mov    0x48(%eax),%eax
}
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80123e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801245:	74 0a                	je     801251 <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801247:	8b 45 08             	mov    0x8(%ebp),%eax
  80124a:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80124f:	c9                   	leave  
  801250:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	6a 07                	push   $0x7
  801256:	68 00 f0 bf ee       	push   $0xeebff000
  80125b:	6a 00                	push   $0x0
  80125d:	e8 6f f9 ff ff       	call   800bd1 <sys_page_alloc>
		if (r < 0) return;
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	78 e6                	js     80124f <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801269:	83 ec 08             	sub    $0x8,%esp
  80126c:	68 81 12 80 00       	push   $0x801281
  801271:	6a 00                	push   $0x0
  801273:	e8 e9 f9 ff ff       	call   800c61 <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	79 c8                	jns    801247 <set_pgfault_handler+0xf>
  80127f:	eb ce                	jmp    80124f <set_pgfault_handler+0x17>

00801281 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801281:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801282:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801287:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801289:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  80128c:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801290:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  801294:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  801297:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  801299:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  80129d:	58                   	pop    %eax
	popl %eax
  80129e:	58                   	pop    %eax
	popal
  80129f:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  8012a0:	83 c4 04             	add    $0x4,%esp
	popfl
  8012a3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  8012a4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  8012a5:	c3                   	ret    
  8012a6:	66 90                	xchg   %ax,%ax
  8012a8:	66 90                	xchg   %ax,%ax
  8012aa:	66 90                	xchg   %ax,%ax
  8012ac:	66 90                	xchg   %ax,%ax
  8012ae:	66 90                	xchg   %ax,%ax

008012b0 <__udivdi3>:
  8012b0:	55                   	push   %ebp
  8012b1:	57                   	push   %edi
  8012b2:	56                   	push   %esi
  8012b3:	53                   	push   %ebx
  8012b4:	83 ec 1c             	sub    $0x1c,%esp
  8012b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012bb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8012bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012c3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8012c7:	85 d2                	test   %edx,%edx
  8012c9:	75 35                	jne    801300 <__udivdi3+0x50>
  8012cb:	39 f3                	cmp    %esi,%ebx
  8012cd:	0f 87 bd 00 00 00    	ja     801390 <__udivdi3+0xe0>
  8012d3:	85 db                	test   %ebx,%ebx
  8012d5:	89 d9                	mov    %ebx,%ecx
  8012d7:	75 0b                	jne    8012e4 <__udivdi3+0x34>
  8012d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8012de:	31 d2                	xor    %edx,%edx
  8012e0:	f7 f3                	div    %ebx
  8012e2:	89 c1                	mov    %eax,%ecx
  8012e4:	31 d2                	xor    %edx,%edx
  8012e6:	89 f0                	mov    %esi,%eax
  8012e8:	f7 f1                	div    %ecx
  8012ea:	89 c6                	mov    %eax,%esi
  8012ec:	89 e8                	mov    %ebp,%eax
  8012ee:	89 f7                	mov    %esi,%edi
  8012f0:	f7 f1                	div    %ecx
  8012f2:	89 fa                	mov    %edi,%edx
  8012f4:	83 c4 1c             	add    $0x1c,%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5f                   	pop    %edi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    
  8012fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801300:	39 f2                	cmp    %esi,%edx
  801302:	77 7c                	ja     801380 <__udivdi3+0xd0>
  801304:	0f bd fa             	bsr    %edx,%edi
  801307:	83 f7 1f             	xor    $0x1f,%edi
  80130a:	0f 84 98 00 00 00    	je     8013a8 <__udivdi3+0xf8>
  801310:	89 f9                	mov    %edi,%ecx
  801312:	b8 20 00 00 00       	mov    $0x20,%eax
  801317:	29 f8                	sub    %edi,%eax
  801319:	d3 e2                	shl    %cl,%edx
  80131b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80131f:	89 c1                	mov    %eax,%ecx
  801321:	89 da                	mov    %ebx,%edx
  801323:	d3 ea                	shr    %cl,%edx
  801325:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801329:	09 d1                	or     %edx,%ecx
  80132b:	89 f2                	mov    %esi,%edx
  80132d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801331:	89 f9                	mov    %edi,%ecx
  801333:	d3 e3                	shl    %cl,%ebx
  801335:	89 c1                	mov    %eax,%ecx
  801337:	d3 ea                	shr    %cl,%edx
  801339:	89 f9                	mov    %edi,%ecx
  80133b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80133f:	d3 e6                	shl    %cl,%esi
  801341:	89 eb                	mov    %ebp,%ebx
  801343:	89 c1                	mov    %eax,%ecx
  801345:	d3 eb                	shr    %cl,%ebx
  801347:	09 de                	or     %ebx,%esi
  801349:	89 f0                	mov    %esi,%eax
  80134b:	f7 74 24 08          	divl   0x8(%esp)
  80134f:	89 d6                	mov    %edx,%esi
  801351:	89 c3                	mov    %eax,%ebx
  801353:	f7 64 24 0c          	mull   0xc(%esp)
  801357:	39 d6                	cmp    %edx,%esi
  801359:	72 0c                	jb     801367 <__udivdi3+0xb7>
  80135b:	89 f9                	mov    %edi,%ecx
  80135d:	d3 e5                	shl    %cl,%ebp
  80135f:	39 c5                	cmp    %eax,%ebp
  801361:	73 5d                	jae    8013c0 <__udivdi3+0x110>
  801363:	39 d6                	cmp    %edx,%esi
  801365:	75 59                	jne    8013c0 <__udivdi3+0x110>
  801367:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80136a:	31 ff                	xor    %edi,%edi
  80136c:	89 fa                	mov    %edi,%edx
  80136e:	83 c4 1c             	add    $0x1c,%esp
  801371:	5b                   	pop    %ebx
  801372:	5e                   	pop    %esi
  801373:	5f                   	pop    %edi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    
  801376:	8d 76 00             	lea    0x0(%esi),%esi
  801379:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801380:	31 ff                	xor    %edi,%edi
  801382:	31 c0                	xor    %eax,%eax
  801384:	89 fa                	mov    %edi,%edx
  801386:	83 c4 1c             	add    $0x1c,%esp
  801389:	5b                   	pop    %ebx
  80138a:	5e                   	pop    %esi
  80138b:	5f                   	pop    %edi
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    
  80138e:	66 90                	xchg   %ax,%ax
  801390:	31 ff                	xor    %edi,%edi
  801392:	89 e8                	mov    %ebp,%eax
  801394:	89 f2                	mov    %esi,%edx
  801396:	f7 f3                	div    %ebx
  801398:	89 fa                	mov    %edi,%edx
  80139a:	83 c4 1c             	add    $0x1c,%esp
  80139d:	5b                   	pop    %ebx
  80139e:	5e                   	pop    %esi
  80139f:	5f                   	pop    %edi
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    
  8013a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013a8:	39 f2                	cmp    %esi,%edx
  8013aa:	72 06                	jb     8013b2 <__udivdi3+0x102>
  8013ac:	31 c0                	xor    %eax,%eax
  8013ae:	39 eb                	cmp    %ebp,%ebx
  8013b0:	77 d2                	ja     801384 <__udivdi3+0xd4>
  8013b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013b7:	eb cb                	jmp    801384 <__udivdi3+0xd4>
  8013b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	89 d8                	mov    %ebx,%eax
  8013c2:	31 ff                	xor    %edi,%edi
  8013c4:	eb be                	jmp    801384 <__udivdi3+0xd4>
  8013c6:	66 90                	xchg   %ax,%ax
  8013c8:	66 90                	xchg   %ax,%ax
  8013ca:	66 90                	xchg   %ax,%ax
  8013cc:	66 90                	xchg   %ax,%ax
  8013ce:	66 90                	xchg   %ax,%ax

008013d0 <__umoddi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 1c             	sub    $0x1c,%esp
  8013d7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8013db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8013df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8013e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013e7:	85 ed                	test   %ebp,%ebp
  8013e9:	89 f0                	mov    %esi,%eax
  8013eb:	89 da                	mov    %ebx,%edx
  8013ed:	75 19                	jne    801408 <__umoddi3+0x38>
  8013ef:	39 df                	cmp    %ebx,%edi
  8013f1:	0f 86 b1 00 00 00    	jbe    8014a8 <__umoddi3+0xd8>
  8013f7:	f7 f7                	div    %edi
  8013f9:	89 d0                	mov    %edx,%eax
  8013fb:	31 d2                	xor    %edx,%edx
  8013fd:	83 c4 1c             	add    $0x1c,%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5f                   	pop    %edi
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    
  801405:	8d 76 00             	lea    0x0(%esi),%esi
  801408:	39 dd                	cmp    %ebx,%ebp
  80140a:	77 f1                	ja     8013fd <__umoddi3+0x2d>
  80140c:	0f bd cd             	bsr    %ebp,%ecx
  80140f:	83 f1 1f             	xor    $0x1f,%ecx
  801412:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801416:	0f 84 b4 00 00 00    	je     8014d0 <__umoddi3+0x100>
  80141c:	b8 20 00 00 00       	mov    $0x20,%eax
  801421:	89 c2                	mov    %eax,%edx
  801423:	8b 44 24 04          	mov    0x4(%esp),%eax
  801427:	29 c2                	sub    %eax,%edx
  801429:	89 c1                	mov    %eax,%ecx
  80142b:	89 f8                	mov    %edi,%eax
  80142d:	d3 e5                	shl    %cl,%ebp
  80142f:	89 d1                	mov    %edx,%ecx
  801431:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801435:	d3 e8                	shr    %cl,%eax
  801437:	09 c5                	or     %eax,%ebp
  801439:	8b 44 24 04          	mov    0x4(%esp),%eax
  80143d:	89 c1                	mov    %eax,%ecx
  80143f:	d3 e7                	shl    %cl,%edi
  801441:	89 d1                	mov    %edx,%ecx
  801443:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801447:	89 df                	mov    %ebx,%edi
  801449:	d3 ef                	shr    %cl,%edi
  80144b:	89 c1                	mov    %eax,%ecx
  80144d:	89 f0                	mov    %esi,%eax
  80144f:	d3 e3                	shl    %cl,%ebx
  801451:	89 d1                	mov    %edx,%ecx
  801453:	89 fa                	mov    %edi,%edx
  801455:	d3 e8                	shr    %cl,%eax
  801457:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80145c:	09 d8                	or     %ebx,%eax
  80145e:	f7 f5                	div    %ebp
  801460:	d3 e6                	shl    %cl,%esi
  801462:	89 d1                	mov    %edx,%ecx
  801464:	f7 64 24 08          	mull   0x8(%esp)
  801468:	39 d1                	cmp    %edx,%ecx
  80146a:	89 c3                	mov    %eax,%ebx
  80146c:	89 d7                	mov    %edx,%edi
  80146e:	72 06                	jb     801476 <__umoddi3+0xa6>
  801470:	75 0e                	jne    801480 <__umoddi3+0xb0>
  801472:	39 c6                	cmp    %eax,%esi
  801474:	73 0a                	jae    801480 <__umoddi3+0xb0>
  801476:	2b 44 24 08          	sub    0x8(%esp),%eax
  80147a:	19 ea                	sbb    %ebp,%edx
  80147c:	89 d7                	mov    %edx,%edi
  80147e:	89 c3                	mov    %eax,%ebx
  801480:	89 ca                	mov    %ecx,%edx
  801482:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801487:	29 de                	sub    %ebx,%esi
  801489:	19 fa                	sbb    %edi,%edx
  80148b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80148f:	89 d0                	mov    %edx,%eax
  801491:	d3 e0                	shl    %cl,%eax
  801493:	89 d9                	mov    %ebx,%ecx
  801495:	d3 ee                	shr    %cl,%esi
  801497:	d3 ea                	shr    %cl,%edx
  801499:	09 f0                	or     %esi,%eax
  80149b:	83 c4 1c             	add    $0x1c,%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    
  8014a3:	90                   	nop
  8014a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a8:	85 ff                	test   %edi,%edi
  8014aa:	89 f9                	mov    %edi,%ecx
  8014ac:	75 0b                	jne    8014b9 <__umoddi3+0xe9>
  8014ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b3:	31 d2                	xor    %edx,%edx
  8014b5:	f7 f7                	div    %edi
  8014b7:	89 c1                	mov    %eax,%ecx
  8014b9:	89 d8                	mov    %ebx,%eax
  8014bb:	31 d2                	xor    %edx,%edx
  8014bd:	f7 f1                	div    %ecx
  8014bf:	89 f0                	mov    %esi,%eax
  8014c1:	f7 f1                	div    %ecx
  8014c3:	e9 31 ff ff ff       	jmp    8013f9 <__umoddi3+0x29>
  8014c8:	90                   	nop
  8014c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014d0:	39 dd                	cmp    %ebx,%ebp
  8014d2:	72 08                	jb     8014dc <__umoddi3+0x10c>
  8014d4:	39 f7                	cmp    %esi,%edi
  8014d6:	0f 87 21 ff ff ff    	ja     8013fd <__umoddi3+0x2d>
  8014dc:	89 da                	mov    %ebx,%edx
  8014de:	89 f0                	mov    %esi,%eax
  8014e0:	29 f8                	sub    %edi,%eax
  8014e2:	19 ea                	sbb    %ebp,%edx
  8014e4:	e9 14 ff ff ff       	jmp    8013fd <__umoddi3+0x2d>
