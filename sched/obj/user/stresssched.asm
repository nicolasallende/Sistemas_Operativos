
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 b7 00 00 00       	call   8000e8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 39 0b 00 00       	call   800b76 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 a1 0f 00 00       	call   800fea <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 40 0b 00 00       	call   800b9a <sys_yield>
		return;
  80005a:	eb 6e                	jmp    8000ca <umain+0x97>
	if (i == 20) {
  80005c:	83 fb 14             	cmp    $0x14,%ebx
  80005f:	74 f4                	je     800055 <umain+0x22>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800061:	89 f0                	mov    %esi,%eax
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	c1 e0 07             	shl    $0x7,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	eb 02                	jmp    800074 <umain+0x41>
		asm volatile("pause");
  800072:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800074:	8b 50 54             	mov    0x54(%eax),%edx
  800077:	85 d2                	test   %edx,%edx
  800079:	75 f7                	jne    800072 <umain+0x3f>
  80007b:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800080:	e8 15 0b 00 00       	call   800b9a <sys_yield>
  800085:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008a:	a1 04 20 80 00       	mov    0x802004,%eax
  80008f:	83 c0 01             	add    $0x1,%eax
  800092:	a3 04 20 80 00       	mov    %eax,0x802004
		for (j = 0; j < 10000; j++)
  800097:	83 ea 01             	sub    $0x1,%edx
  80009a:	75 ee                	jne    80008a <umain+0x57>
	for (i = 0; i < 10; i++) {
  80009c:	83 eb 01             	sub    $0x1,%ebx
  80009f:	75 df                	jne    800080 <umain+0x4d>
	}

	if (counter != 10*10000)
  8000a1:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a6:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000ab:	75 24                	jne    8000d1 <umain+0x9e>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ad:	a1 08 20 80 00       	mov    0x802008,%eax
  8000b2:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b5:	8b 40 48             	mov    0x48(%eax),%eax
  8000b8:	83 ec 04             	sub    $0x4,%esp
  8000bb:	52                   	push   %edx
  8000bc:	50                   	push   %eax
  8000bd:	68 1b 14 80 00       	push   $0x80141b
  8000c2:	e8 58 01 00 00       	call   80021f <cprintf>
  8000c7:	83 c4 10             	add    $0x10,%esp

}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d1:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d6:	50                   	push   %eax
  8000d7:	68 e0 13 80 00       	push   $0x8013e0
  8000dc:	6a 21                	push   $0x21
  8000de:	68 08 14 80 00       	push   $0x801408
  8000e3:	e8 5c 00 00 00       	call   800144 <_panic>

008000e8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000f3:	e8 7e 0a 00 00       	call   800b76 <sys_getenvid>
	if (id >= 0)
  8000f8:	85 c0                	test   %eax,%eax
  8000fa:	78 12                	js     80010e <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8000fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800101:	c1 e0 07             	shl    $0x7,%eax
  800104:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800109:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010e:	85 db                	test   %ebx,%ebx
  800110:	7e 07                	jle    800119 <libmain+0x31>
		binaryname = argv[0];
  800112:	8b 06                	mov    (%esi),%eax
  800114:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	e8 10 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800123:	e8 0a 00 00 00       	call   800132 <exit>
}
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800138:	6a 00                	push   $0x0
  80013a:	e8 15 0a 00 00       	call   800b54 <sys_env_destroy>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800149:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800152:	e8 1f 0a 00 00       	call   800b76 <sys_getenvid>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	56                   	push   %esi
  800161:	50                   	push   %eax
  800162:	68 44 14 80 00       	push   $0x801444
  800167:	e8 b3 00 00 00       	call   80021f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016c:	83 c4 18             	add    $0x18,%esp
  80016f:	53                   	push   %ebx
  800170:	ff 75 10             	pushl  0x10(%ebp)
  800173:	e8 56 00 00 00       	call   8001ce <vcprintf>
	cprintf("\n");
  800178:	c7 04 24 37 14 80 00 	movl   $0x801437,(%esp)
  80017f:	e8 9b 00 00 00       	call   80021f <cprintf>
  800184:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800187:	cc                   	int3   
  800188:	eb fd                	jmp    800187 <_panic+0x43>

0080018a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	53                   	push   %ebx
  80018e:	83 ec 04             	sub    $0x4,%esp
  800191:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800194:	8b 13                	mov    (%ebx),%edx
  800196:	8d 42 01             	lea    0x1(%edx),%eax
  800199:	89 03                	mov    %eax,(%ebx)
  80019b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a7:	74 09                	je     8001b2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 47 09 00 00       	call   800b0a <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
  8001cc:	eb db                	jmp    8001a9 <putch+0x1f>

008001ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001de:	00 00 00 
	b.cnt = 0;
  8001e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001eb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ee:	ff 75 08             	pushl  0x8(%ebp)
  8001f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	68 8a 01 80 00       	push   $0x80018a
  8001fd:	e8 86 01 00 00       	call   800388 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800202:	83 c4 08             	add    $0x8,%esp
  800205:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800211:	50                   	push   %eax
  800212:	e8 f3 08 00 00       	call   800b0a <sys_cputs>

	return b.cnt;
}
  800217:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800225:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800228:	50                   	push   %eax
  800229:	ff 75 08             	pushl  0x8(%ebp)
  80022c:	e8 9d ff ff ff       	call   8001ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 1c             	sub    $0x1c,%esp
  80023c:	89 c7                	mov    %eax,%edi
  80023e:	89 d6                	mov    %edx,%esi
  800240:	8b 45 08             	mov    0x8(%ebp),%eax
  800243:	8b 55 0c             	mov    0xc(%ebp),%edx
  800246:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800249:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800254:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800257:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025a:	39 d3                	cmp    %edx,%ebx
  80025c:	72 05                	jb     800263 <printnum+0x30>
  80025e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800261:	77 7a                	ja     8002dd <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	ff 75 18             	pushl  0x18(%ebp)
  800269:	8b 45 14             	mov    0x14(%ebp),%eax
  80026c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	ff 75 e4             	pushl  -0x1c(%ebp)
  800279:	ff 75 e0             	pushl  -0x20(%ebp)
  80027c:	ff 75 dc             	pushl  -0x24(%ebp)
  80027f:	ff 75 d8             	pushl  -0x28(%ebp)
  800282:	e8 19 0f 00 00       	call   8011a0 <__udivdi3>
  800287:	83 c4 18             	add    $0x18,%esp
  80028a:	52                   	push   %edx
  80028b:	50                   	push   %eax
  80028c:	89 f2                	mov    %esi,%edx
  80028e:	89 f8                	mov    %edi,%eax
  800290:	e8 9e ff ff ff       	call   800233 <printnum>
  800295:	83 c4 20             	add    $0x20,%esp
  800298:	eb 13                	jmp    8002ad <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	56                   	push   %esi
  80029e:	ff 75 18             	pushl  0x18(%ebp)
  8002a1:	ff d7                	call   *%edi
  8002a3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a6:	83 eb 01             	sub    $0x1,%ebx
  8002a9:	85 db                	test   %ebx,%ebx
  8002ab:	7f ed                	jg     80029a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	83 ec 04             	sub    $0x4,%esp
  8002b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c0:	e8 fb 0f 00 00       	call   8012c0 <__umoddi3>
  8002c5:	83 c4 14             	add    $0x14,%esp
  8002c8:	0f be 80 67 14 80 00 	movsbl 0x801467(%eax),%eax
  8002cf:	50                   	push   %eax
  8002d0:	ff d7                	call   *%edi
}
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d8:	5b                   	pop    %ebx
  8002d9:	5e                   	pop    %esi
  8002da:	5f                   	pop    %edi
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    
  8002dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e0:	eb c4                	jmp    8002a6 <printnum+0x73>

008002e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e5:	83 fa 01             	cmp    $0x1,%edx
  8002e8:	7e 0e                	jle    8002f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    
	else if (lflag)
  8002f8:	85 d2                	test   %edx,%edx
  8002fa:	75 10                	jne    80030c <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
  80030a:	eb ea                	jmp    8002f6 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
  80031a:	eb da                	jmp    8002f6 <getuint+0x14>

0080031c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031f:	83 fa 01             	cmp    $0x1,%edx
  800322:	7e 0e                	jle    800332 <getint+0x16>
		return va_arg(*ap, long long);
  800324:	8b 10                	mov    (%eax),%edx
  800326:	8d 4a 08             	lea    0x8(%edx),%ecx
  800329:	89 08                	mov    %ecx,(%eax)
  80032b:	8b 02                	mov    (%edx),%eax
  80032d:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    
	else if (lflag)
  800332:	85 d2                	test   %edx,%edx
  800334:	75 0c                	jne    800342 <getint+0x26>
		return va_arg(*ap, int);
  800336:	8b 10                	mov    (%eax),%edx
  800338:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	99                   	cltd   
  800340:	eb ee                	jmp    800330 <getint+0x14>
		return va_arg(*ap, long);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 4a 04             	lea    0x4(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	99                   	cltd   
  80034c:	eb e2                	jmp    800330 <getint+0x14>

0080034e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800354:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	3b 50 04             	cmp    0x4(%eax),%edx
  80035d:	73 0a                	jae    800369 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800362:	89 08                	mov    %ecx,(%eax)
  800364:	8b 45 08             	mov    0x8(%ebp),%eax
  800367:	88 02                	mov    %al,(%edx)
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <printfmt>:
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800371:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800374:	50                   	push   %eax
  800375:	ff 75 10             	pushl  0x10(%ebp)
  800378:	ff 75 0c             	pushl  0xc(%ebp)
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 05 00 00 00       	call   800388 <vprintfmt>
}
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <vprintfmt>:
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	57                   	push   %edi
  80038c:	56                   	push   %esi
  80038d:	53                   	push   %ebx
  80038e:	83 ec 2c             	sub    $0x2c,%esp
  800391:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800394:	8b 75 0c             	mov    0xc(%ebp),%esi
  800397:	89 f7                	mov    %esi,%edi
  800399:	89 de                	mov    %ebx,%esi
  80039b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039e:	e9 9e 02 00 00       	jmp    800641 <vprintfmt+0x2b9>
		padc = ' ';
  8003a3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003a7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003bc:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 43 01             	lea    0x1(%ebx),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 0b             	movzbl (%ebx),%ecx
  8003ca:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8003cd:	3c 55                	cmp    $0x55,%al
  8003cf:	0f 87 e8 02 00 00    	ja     8006bd <vprintfmt+0x335>
  8003d5:	0f b6 c0             	movzbl %al,%eax
  8003d8:	ff 24 85 20 15 80 00 	jmp    *0x801520(,%eax,4)
  8003df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  8003e2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003e6:	eb d9                	jmp    8003c1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  8003eb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ef:	eb d0                	jmp    8003c1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	0f b6 c9             	movzbl %cl,%ecx
  8003f4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800402:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800406:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800409:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80040c:	83 fa 09             	cmp    $0x9,%edx
  80040f:	77 52                	ja     800463 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800411:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800414:	eb e9                	jmp    8003ff <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 48 04             	lea    0x4(%eax),%ecx
  80041c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800427:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042b:	79 94                	jns    8003c1 <vprintfmt+0x39>
				width = precision, precision = -1;
  80042d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043a:	eb 85                	jmp    8003c1 <vprintfmt+0x39>
  80043c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80043f:	85 c0                	test   %eax,%eax
  800441:	b9 00 00 00 00       	mov    $0x0,%ecx
  800446:	0f 49 c8             	cmovns %eax,%ecx
  800449:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80044f:	e9 6d ff ff ff       	jmp    8003c1 <vprintfmt+0x39>
  800454:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800457:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80045e:	e9 5e ff ff ff       	jmp    8003c1 <vprintfmt+0x39>
  800463:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800466:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800469:	eb bc                	jmp    800427 <vprintfmt+0x9f>
			lflag++;
  80046b:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800471:	e9 4b ff ff ff       	jmp    8003c1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	57                   	push   %edi
  800483:	ff 30                	pushl  (%eax)
  800485:	ff d6                	call   *%esi
			break;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	e9 af 01 00 00       	jmp    80063e <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	99                   	cltd   
  80049b:	31 d0                	xor    %edx,%eax
  80049d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049f:	83 f8 08             	cmp    $0x8,%eax
  8004a2:	7f 20                	jg     8004c4 <vprintfmt+0x13c>
  8004a4:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	74 15                	je     8004c4 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  8004af:	52                   	push   %edx
  8004b0:	68 88 14 80 00       	push   $0x801488
  8004b5:	57                   	push   %edi
  8004b6:	56                   	push   %esi
  8004b7:	e8 af fe ff ff       	call   80036b <printfmt>
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	e9 7a 01 00 00       	jmp    80063e <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8004c4:	50                   	push   %eax
  8004c5:	68 7f 14 80 00       	push   $0x80147f
  8004ca:	57                   	push   %edi
  8004cb:	56                   	push   %esi
  8004cc:	e8 9a fe ff ff       	call   80036b <printfmt>
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	e9 65 01 00 00       	jmp    80063e <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 50 04             	lea    0x4(%eax),%edx
  8004df:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e2:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  8004e4:	85 db                	test   %ebx,%ebx
  8004e6:	b8 78 14 80 00       	mov    $0x801478,%eax
  8004eb:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  8004ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f2:	0f 8e bd 00 00 00    	jle    8005b5 <vprintfmt+0x22d>
  8004f8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fc:	75 0e                	jne    80050c <vprintfmt+0x184>
  8004fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800501:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800504:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800507:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80050a:	eb 6d                	jmp    800579 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	ff 75 d0             	pushl  -0x30(%ebp)
  800512:	53                   	push   %ebx
  800513:	e8 4d 02 00 00       	call   800765 <strnlen>
  800518:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051b:	29 c1                	sub    %eax,%ecx
  80051d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800523:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800527:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80052d:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	eb 0f                	jmp    800540 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	57                   	push   %edi
  800535:	ff 75 e0             	pushl  -0x20(%ebp)
  800538:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80053a:	83 eb 01             	sub    $0x1,%ebx
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	85 db                	test   %ebx,%ebx
  800542:	7f ed                	jg     800531 <vprintfmt+0x1a9>
  800544:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800547:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054a:	85 c9                	test   %ecx,%ecx
  80054c:	b8 00 00 00 00       	mov    $0x0,%eax
  800551:	0f 49 c1             	cmovns %ecx,%eax
  800554:	29 c1                	sub    %eax,%ecx
  800556:	89 75 08             	mov    %esi,0x8(%ebp)
  800559:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055c:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80055f:	89 cf                	mov    %ecx,%edi
  800561:	eb 16                	jmp    800579 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800563:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800567:	75 31                	jne    80059a <vprintfmt+0x212>
					putch(ch, putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	ff 75 0c             	pushl  0xc(%ebp)
  80056f:	50                   	push   %eax
  800570:	ff 55 08             	call   *0x8(%ebp)
  800573:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800576:	83 ef 01             	sub    $0x1,%edi
  800579:	83 c3 01             	add    $0x1,%ebx
  80057c:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  800580:	0f be c2             	movsbl %dl,%eax
  800583:	85 c0                	test   %eax,%eax
  800585:	74 50                	je     8005d7 <vprintfmt+0x24f>
  800587:	85 f6                	test   %esi,%esi
  800589:	78 d8                	js     800563 <vprintfmt+0x1db>
  80058b:	83 ee 01             	sub    $0x1,%esi
  80058e:	79 d3                	jns    800563 <vprintfmt+0x1db>
  800590:	89 fb                	mov    %edi,%ebx
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800598:	eb 37                	jmp    8005d1 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  80059a:	0f be d2             	movsbl %dl,%edx
  80059d:	83 ea 20             	sub    $0x20,%edx
  8005a0:	83 fa 5e             	cmp    $0x5e,%edx
  8005a3:	76 c4                	jbe    800569 <vprintfmt+0x1e1>
					putch('?', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	ff 75 0c             	pushl  0xc(%ebp)
  8005ab:	6a 3f                	push   $0x3f
  8005ad:	ff 55 08             	call   *0x8(%ebp)
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	eb c1                	jmp    800576 <vprintfmt+0x1ee>
  8005b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005bb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005be:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005c1:	eb b6                	jmp    800579 <vprintfmt+0x1f1>
				putch(' ', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	57                   	push   %edi
  8005c7:	6a 20                	push   $0x20
  8005c9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005cb:	83 eb 01             	sub    $0x1,%ebx
  8005ce:	83 c4 10             	add    $0x10,%esp
  8005d1:	85 db                	test   %ebx,%ebx
  8005d3:	7f ee                	jg     8005c3 <vprintfmt+0x23b>
  8005d5:	eb 67                	jmp    80063e <vprintfmt+0x2b6>
  8005d7:	89 fb                	mov    %edi,%ebx
  8005d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005df:	eb f0                	jmp    8005d1 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e4:	e8 33 fd ff ff       	call   80031c <getint>
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	79 2c                	jns    800624 <vprintfmt+0x29c>
				putch('-', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	57                   	push   %edi
  8005fc:	6a 2d                	push   $0x2d
  8005fe:	ff d6                	call   *%esi
				num = -(long long) num;
  800600:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800603:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800606:	f7 d8                	neg    %eax
  800608:	83 d2 00             	adc    $0x0,%edx
  80060b:	f7 da                	neg    %edx
  80060d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800610:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800615:	eb 0d                	jmp    800624 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 c3 fc ff ff       	call   8002e2 <getuint>
			base = 10;
  80061f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800624:	83 ec 0c             	sub    $0xc,%esp
  800627:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80062b:	53                   	push   %ebx
  80062c:	ff 75 e0             	pushl  -0x20(%ebp)
  80062f:	51                   	push   %ecx
  800630:	52                   	push   %edx
  800631:	50                   	push   %eax
  800632:	89 fa                	mov    %edi,%edx
  800634:	89 f0                	mov    %esi,%eax
  800636:	e8 f8 fb ff ff       	call   800233 <printnum>
			break;
  80063b:	83 c4 20             	add    $0x20,%esp
{
  80063e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800641:	83 c3 01             	add    $0x1,%ebx
  800644:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800648:	83 f8 25             	cmp    $0x25,%eax
  80064b:	0f 84 52 fd ff ff    	je     8003a3 <vprintfmt+0x1b>
			if (ch == '\0')
  800651:	85 c0                	test   %eax,%eax
  800653:	0f 84 84 00 00 00    	je     8006dd <vprintfmt+0x355>
			putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	57                   	push   %edi
  80065d:	50                   	push   %eax
  80065e:	ff d6                	call   *%esi
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb dc                	jmp    800641 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  800665:	8d 45 14             	lea    0x14(%ebp),%eax
  800668:	e8 75 fc ff ff       	call   8002e2 <getuint>
			base = 8;
  80066d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800672:	eb b0                	jmp    800624 <vprintfmt+0x29c>
			putch('0', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	57                   	push   %edi
  800678:	6a 30                	push   $0x30
  80067a:	ff d6                	call   *%esi
			putch('x', putdat);
  80067c:	83 c4 08             	add    $0x8,%esp
  80067f:	57                   	push   %edi
  800680:	6a 78                	push   $0x78
  800682:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800694:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800697:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069c:	eb 86                	jmp    800624 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a1:	e8 3c fc ff ff       	call   8002e2 <getuint>
			base = 16;
  8006a6:	b9 10 00 00 00       	mov    $0x10,%ecx
  8006ab:	e9 74 ff ff ff       	jmp    800624 <vprintfmt+0x29c>
			putch(ch, putdat);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	57                   	push   %edi
  8006b4:	6a 25                	push   $0x25
  8006b6:	ff d6                	call   *%esi
			break;
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	eb 81                	jmp    80063e <vprintfmt+0x2b6>
			putch('%', putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	57                   	push   %edi
  8006c1:	6a 25                	push   $0x25
  8006c3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	89 d8                	mov    %ebx,%eax
  8006ca:	eb 03                	jmp    8006cf <vprintfmt+0x347>
  8006cc:	83 e8 01             	sub    $0x1,%eax
  8006cf:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006d3:	75 f7                	jne    8006cc <vprintfmt+0x344>
  8006d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d8:	e9 61 ff ff ff       	jmp    80063e <vprintfmt+0x2b6>
}
  8006dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e0:	5b                   	pop    %ebx
  8006e1:	5e                   	pop    %esi
  8006e2:	5f                   	pop    %edi
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	83 ec 18             	sub    $0x18,%esp
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800702:	85 c0                	test   %eax,%eax
  800704:	74 26                	je     80072c <vsnprintf+0x47>
  800706:	85 d2                	test   %edx,%edx
  800708:	7e 22                	jle    80072c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070a:	ff 75 14             	pushl  0x14(%ebp)
  80070d:	ff 75 10             	pushl  0x10(%ebp)
  800710:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800713:	50                   	push   %eax
  800714:	68 4e 03 80 00       	push   $0x80034e
  800719:	e8 6a fc ff ff       	call   800388 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800721:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800727:	83 c4 10             	add    $0x10,%esp
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    
		return -E_INVAL;
  80072c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800731:	eb f7                	jmp    80072a <vsnprintf+0x45>

00800733 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800739:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073c:	50                   	push   %eax
  80073d:	ff 75 10             	pushl  0x10(%ebp)
  800740:	ff 75 0c             	pushl  0xc(%ebp)
  800743:	ff 75 08             	pushl  0x8(%ebp)
  800746:	e8 9a ff ff ff       	call   8006e5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074b:	c9                   	leave  
  80074c:	c3                   	ret    

0080074d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800753:	b8 00 00 00 00       	mov    $0x0,%eax
  800758:	eb 03                	jmp    80075d <strlen+0x10>
		n++;
  80075a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80075d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800761:	75 f7                	jne    80075a <strlen+0xd>
	return n;
}
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076e:	b8 00 00 00 00       	mov    $0x0,%eax
  800773:	eb 03                	jmp    800778 <strnlen+0x13>
		n++;
  800775:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800778:	39 d0                	cmp    %edx,%eax
  80077a:	74 06                	je     800782 <strnlen+0x1d>
  80077c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800780:	75 f3                	jne    800775 <strnlen+0x10>
	return n;
}
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	53                   	push   %ebx
  800788:	8b 45 08             	mov    0x8(%ebp),%eax
  80078b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078e:	89 c2                	mov    %eax,%edx
  800790:	83 c1 01             	add    $0x1,%ecx
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079d:	84 db                	test   %bl,%bl
  80079f:	75 ef                	jne    800790 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a1:	5b                   	pop    %ebx
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ab:	53                   	push   %ebx
  8007ac:	e8 9c ff ff ff       	call   80074d <strlen>
  8007b1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b4:	ff 75 0c             	pushl  0xc(%ebp)
  8007b7:	01 d8                	add    %ebx,%eax
  8007b9:	50                   	push   %eax
  8007ba:	e8 c5 ff ff ff       	call   800784 <strcpy>
	return dst;
}
  8007bf:	89 d8                	mov    %ebx,%eax
  8007c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d1:	89 f3                	mov    %esi,%ebx
  8007d3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d6:	89 f2                	mov    %esi,%edx
  8007d8:	eb 0f                	jmp    8007e9 <strncpy+0x23>
		*dst++ = *src;
  8007da:	83 c2 01             	add    $0x1,%edx
  8007dd:	0f b6 01             	movzbl (%ecx),%eax
  8007e0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e6:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007e9:	39 da                	cmp    %ebx,%edx
  8007eb:	75 ed                	jne    8007da <strncpy+0x14>
	}
	return ret;
}
  8007ed:	89 f0                	mov    %esi,%eax
  8007ef:	5b                   	pop    %ebx
  8007f0:	5e                   	pop    %esi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	56                   	push   %esi
  8007f7:	53                   	push   %ebx
  8007f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800801:	89 f0                	mov    %esi,%eax
  800803:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800807:	85 c9                	test   %ecx,%ecx
  800809:	75 0b                	jne    800816 <strlcpy+0x23>
  80080b:	eb 17                	jmp    800824 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080d:	83 c2 01             	add    $0x1,%edx
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800816:	39 d8                	cmp    %ebx,%eax
  800818:	74 07                	je     800821 <strlcpy+0x2e>
  80081a:	0f b6 0a             	movzbl (%edx),%ecx
  80081d:	84 c9                	test   %cl,%cl
  80081f:	75 ec                	jne    80080d <strlcpy+0x1a>
		*dst = '\0';
  800821:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800824:	29 f0                	sub    %esi,%eax
}
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800833:	eb 06                	jmp    80083b <strcmp+0x11>
		p++, q++;
  800835:	83 c1 01             	add    $0x1,%ecx
  800838:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80083b:	0f b6 01             	movzbl (%ecx),%eax
  80083e:	84 c0                	test   %al,%al
  800840:	74 04                	je     800846 <strcmp+0x1c>
  800842:	3a 02                	cmp    (%edx),%al
  800844:	74 ef                	je     800835 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800846:	0f b6 c0             	movzbl %al,%eax
  800849:	0f b6 12             	movzbl (%edx),%edx
  80084c:	29 d0                	sub    %edx,%eax
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085a:	89 c3                	mov    %eax,%ebx
  80085c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085f:	eb 06                	jmp    800867 <strncmp+0x17>
		n--, p++, q++;
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800867:	39 d8                	cmp    %ebx,%eax
  800869:	74 16                	je     800881 <strncmp+0x31>
  80086b:	0f b6 08             	movzbl (%eax),%ecx
  80086e:	84 c9                	test   %cl,%cl
  800870:	74 04                	je     800876 <strncmp+0x26>
  800872:	3a 0a                	cmp    (%edx),%cl
  800874:	74 eb                	je     800861 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800876:	0f b6 00             	movzbl (%eax),%eax
  800879:	0f b6 12             	movzbl (%edx),%edx
  80087c:	29 d0                	sub    %edx,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    
		return 0;
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	eb f6                	jmp    80087e <strncmp+0x2e>

00800888 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800892:	0f b6 10             	movzbl (%eax),%edx
  800895:	84 d2                	test   %dl,%dl
  800897:	74 09                	je     8008a2 <strchr+0x1a>
		if (*s == c)
  800899:	38 ca                	cmp    %cl,%dl
  80089b:	74 0a                	je     8008a7 <strchr+0x1f>
	for (; *s; s++)
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	eb f0                	jmp    800892 <strchr+0xa>
			return (char *) s;
	return 0;
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b3:	eb 03                	jmp    8008b8 <strfind+0xf>
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bb:	38 ca                	cmp    %cl,%dl
  8008bd:	74 04                	je     8008c3 <strfind+0x1a>
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f2                	jne    8008b5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	57                   	push   %edi
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008d1:	85 c9                	test   %ecx,%ecx
  8008d3:	74 12                	je     8008e7 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d5:	f6 c2 03             	test   $0x3,%dl
  8008d8:	75 05                	jne    8008df <memset+0x1a>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	74 0f                	je     8008ee <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008df:	89 d7                	mov    %edx,%edi
  8008e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e4:	fc                   	cld    
  8008e5:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    
		c &= 0xFF;
  8008ee:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f2:	89 d8                	mov    %ebx,%eax
  8008f4:	c1 e0 08             	shl    $0x8,%eax
  8008f7:	89 df                	mov    %ebx,%edi
  8008f9:	c1 e7 18             	shl    $0x18,%edi
  8008fc:	89 de                	mov    %ebx,%esi
  8008fe:	c1 e6 10             	shl    $0x10,%esi
  800901:	09 f7                	or     %esi,%edi
  800903:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800905:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800908:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80090a:	89 d7                	mov    %edx,%edi
  80090c:	fc                   	cld    
  80090d:	f3 ab                	rep stos %eax,%es:(%edi)
  80090f:	eb d6                	jmp    8008e7 <memset+0x22>

00800911 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	57                   	push   %edi
  800915:	56                   	push   %esi
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091f:	39 c6                	cmp    %eax,%esi
  800921:	73 35                	jae    800958 <memmove+0x47>
  800923:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800926:	39 c2                	cmp    %eax,%edx
  800928:	76 2e                	jbe    800958 <memmove+0x47>
		s += n;
		d += n;
  80092a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092d:	89 d6                	mov    %edx,%esi
  80092f:	09 fe                	or     %edi,%esi
  800931:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800937:	74 0c                	je     800945 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800939:	83 ef 01             	sub    $0x1,%edi
  80093c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80093f:	fd                   	std    
  800940:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800942:	fc                   	cld    
  800943:	eb 21                	jmp    800966 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 ef                	jne    800939 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094a:	83 ef 04             	sub    $0x4,%edi
  80094d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800950:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800953:	fd                   	std    
  800954:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800956:	eb ea                	jmp    800942 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800958:	89 f2                	mov    %esi,%edx
  80095a:	09 c2                	or     %eax,%edx
  80095c:	f6 c2 03             	test   $0x3,%dl
  80095f:	74 09                	je     80096a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800961:	89 c7                	mov    %eax,%edi
  800963:	fc                   	cld    
  800964:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	f6 c1 03             	test   $0x3,%cl
  80096d:	75 f2                	jne    800961 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb ed                	jmp    800966 <memmove+0x55>

00800979 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097c:	ff 75 10             	pushl  0x10(%ebp)
  80097f:	ff 75 0c             	pushl  0xc(%ebp)
  800982:	ff 75 08             	pushl  0x8(%ebp)
  800985:	e8 87 ff ff ff       	call   800911 <memmove>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
  800997:	89 c6                	mov    %eax,%esi
  800999:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099c:	39 f0                	cmp    %esi,%eax
  80099e:	74 1c                	je     8009bc <memcmp+0x30>
		if (*s1 != *s2)
  8009a0:	0f b6 08             	movzbl (%eax),%ecx
  8009a3:	0f b6 1a             	movzbl (%edx),%ebx
  8009a6:	38 d9                	cmp    %bl,%cl
  8009a8:	75 08                	jne    8009b2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	83 c2 01             	add    $0x1,%edx
  8009b0:	eb ea                	jmp    80099c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009b2:	0f b6 c1             	movzbl %cl,%eax
  8009b5:	0f b6 db             	movzbl %bl,%ebx
  8009b8:	29 d8                	sub    %ebx,%eax
  8009ba:	eb 05                	jmp    8009c1 <memcmp+0x35>
	}

	return 0;
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ce:	89 c2                	mov    %eax,%edx
  8009d0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d3:	39 d0                	cmp    %edx,%eax
  8009d5:	73 09                	jae    8009e0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d7:	38 08                	cmp    %cl,(%eax)
  8009d9:	74 05                	je     8009e0 <memfind+0x1b>
	for (; s < ends; s++)
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	eb f3                	jmp    8009d3 <memfind+0xe>
			break;
	return (void *) s;
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	eb 03                	jmp    8009f3 <strtol+0x11>
		s++;
  8009f0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009f3:	0f b6 01             	movzbl (%ecx),%eax
  8009f6:	3c 20                	cmp    $0x20,%al
  8009f8:	74 f6                	je     8009f0 <strtol+0xe>
  8009fa:	3c 09                	cmp    $0x9,%al
  8009fc:	74 f2                	je     8009f0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009fe:	3c 2b                	cmp    $0x2b,%al
  800a00:	74 2e                	je     800a30 <strtol+0x4e>
	int neg = 0;
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a07:	3c 2d                	cmp    $0x2d,%al
  800a09:	74 2f                	je     800a3a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a11:	75 05                	jne    800a18 <strtol+0x36>
  800a13:	80 39 30             	cmpb   $0x30,(%ecx)
  800a16:	74 2c                	je     800a44 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a18:	85 db                	test   %ebx,%ebx
  800a1a:	75 0a                	jne    800a26 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a21:	80 39 30             	cmpb   $0x30,(%ecx)
  800a24:	74 28                	je     800a4e <strtol+0x6c>
		base = 10;
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a2e:	eb 50                	jmp    800a80 <strtol+0x9e>
		s++;
  800a30:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
  800a38:	eb d1                	jmp    800a0b <strtol+0x29>
		s++, neg = 1;
  800a3a:	83 c1 01             	add    $0x1,%ecx
  800a3d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a42:	eb c7                	jmp    800a0b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a48:	74 0e                	je     800a58 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	75 d8                	jne    800a26 <strtol+0x44>
		s++, base = 8;
  800a4e:	83 c1 01             	add    $0x1,%ecx
  800a51:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a56:	eb ce                	jmp    800a26 <strtol+0x44>
		s += 2, base = 16;
  800a58:	83 c1 02             	add    $0x2,%ecx
  800a5b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a60:	eb c4                	jmp    800a26 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a62:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 19             	cmp    $0x19,%bl
  800a6a:	77 29                	ja     800a95 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a72:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a75:	7d 30                	jge    800aa7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a80:	0f b6 11             	movzbl (%ecx),%edx
  800a83:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 09             	cmp    $0x9,%bl
  800a8b:	77 d5                	ja     800a62 <strtol+0x80>
			dig = *s - '0';
  800a8d:	0f be d2             	movsbl %dl,%edx
  800a90:	83 ea 30             	sub    $0x30,%edx
  800a93:	eb dd                	jmp    800a72 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a95:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a98:	89 f3                	mov    %esi,%ebx
  800a9a:	80 fb 19             	cmp    $0x19,%bl
  800a9d:	77 08                	ja     800aa7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a9f:	0f be d2             	movsbl %dl,%edx
  800aa2:	83 ea 37             	sub    $0x37,%edx
  800aa5:	eb cb                	jmp    800a72 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aab:	74 05                	je     800ab2 <strtol+0xd0>
		*endptr = (char *) s;
  800aad:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	f7 da                	neg    %edx
  800ab6:	85 ff                	test   %edi,%edi
  800ab8:	0f 45 c2             	cmovne %edx,%eax
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 1c             	sub    $0x1c,%esp
  800ac9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800acc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800acf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad7:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ada:	8b 75 14             	mov    0x14(%ebp),%esi
  800add:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800adf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ae3:	74 04                	je     800ae9 <syscall+0x29>
  800ae5:	85 c0                	test   %eax,%eax
  800ae7:	7f 08                	jg     800af1 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    
  800af1:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800af4:	83 ec 0c             	sub    $0xc,%esp
  800af7:	50                   	push   %eax
  800af8:	52                   	push   %edx
  800af9:	68 a4 16 80 00       	push   $0x8016a4
  800afe:	6a 23                	push   $0x23
  800b00:	68 c1 16 80 00       	push   $0x8016c1
  800b05:	e8 3a f6 ff ff       	call   800144 <_panic>

00800b0a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b10:	6a 00                	push   $0x0
  800b12:	6a 00                	push   $0x0
  800b14:	6a 00                	push   $0x0
  800b16:	ff 75 0c             	pushl  0xc(%ebp)
  800b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
  800b26:	e8 95 ff ff ff       	call   800ac0 <syscall>
}
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	c9                   	leave  
  800b2f:	c3                   	ret    

00800b30 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b36:	6a 00                	push   $0x0
  800b38:	6a 00                	push   $0x0
  800b3a:	6a 00                	push   $0x0
  800b3c:	6a 00                	push   $0x0
  800b3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4d:	e8 6e ff ff ff       	call   800ac0 <syscall>
}
  800b52:	c9                   	leave  
  800b53:	c3                   	ret    

00800b54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b5a:	6a 00                	push   $0x0
  800b5c:	6a 00                	push   $0x0
  800b5e:	6a 00                	push   $0x0
  800b60:	6a 00                	push   $0x0
  800b62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b65:	ba 01 00 00 00       	mov    $0x1,%edx
  800b6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6f:	e8 4c ff ff ff       	call   800ac0 <syscall>
}
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b7c:	6a 00                	push   $0x0
  800b7e:	6a 00                	push   $0x0
  800b80:	6a 00                	push   $0x0
  800b82:	6a 00                	push   $0x0
  800b84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b93:	e8 28 ff ff ff       	call   800ac0 <syscall>
}
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <sys_yield>:

void
sys_yield(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ba0:	6a 00                	push   $0x0
  800ba2:	6a 00                	push   $0x0
  800ba4:	6a 00                	push   $0x0
  800ba6:	6a 00                	push   $0x0
  800ba8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb7:	e8 04 ff ff ff       	call   800ac0 <syscall>
}
  800bbc:	83 c4 10             	add    $0x10,%esp
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bc7:	6a 00                	push   $0x0
  800bc9:	6a 00                	push   $0x0
  800bcb:	ff 75 10             	pushl  0x10(%ebp)
  800bce:	ff 75 0c             	pushl  0xc(%ebp)
  800bd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd4:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bde:	e8 dd fe ff ff       	call   800ac0 <syscall>
}
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    

00800be5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800beb:	ff 75 18             	pushl  0x18(%ebp)
  800bee:	ff 75 14             	pushl  0x14(%ebp)
  800bf1:	ff 75 10             	pushl  0x10(%ebp)
  800bf4:	ff 75 0c             	pushl  0xc(%ebp)
  800bf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfa:	ba 01 00 00 00       	mov    $0x1,%edx
  800bff:	b8 05 00 00 00       	mov    $0x5,%eax
  800c04:	e8 b7 fe ff ff       	call   800ac0 <syscall>
}
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    

00800c0b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c11:	6a 00                	push   $0x0
  800c13:	6a 00                	push   $0x0
  800c15:	6a 00                	push   $0x0
  800c17:	ff 75 0c             	pushl  0xc(%ebp)
  800c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c22:	b8 06 00 00 00       	mov    $0x6,%eax
  800c27:	e8 94 fe ff ff       	call   800ac0 <syscall>
}
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c34:	6a 00                	push   $0x0
  800c36:	6a 00                	push   $0x0
  800c38:	6a 00                	push   $0x0
  800c3a:	ff 75 0c             	pushl  0xc(%ebp)
  800c3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c40:	ba 01 00 00 00       	mov    $0x1,%edx
  800c45:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4a:	e8 71 fe ff ff       	call   800ac0 <syscall>
}
  800c4f:	c9                   	leave  
  800c50:	c3                   	ret    

00800c51 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c57:	6a 00                	push   $0x0
  800c59:	6a 00                	push   $0x0
  800c5b:	6a 00                	push   $0x0
  800c5d:	ff 75 0c             	pushl  0xc(%ebp)
  800c60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c63:	ba 01 00 00 00       	mov    $0x1,%edx
  800c68:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6d:	e8 4e fe ff ff       	call   800ac0 <syscall>
}
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c7a:	6a 00                	push   $0x0
  800c7c:	ff 75 14             	pushl  0x14(%ebp)
  800c7f:	ff 75 10             	pushl  0x10(%ebp)
  800c82:	ff 75 0c             	pushl  0xc(%ebp)
  800c85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c88:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c92:	e8 29 fe ff ff       	call   800ac0 <syscall>
}
  800c97:	c9                   	leave  
  800c98:	c3                   	ret    

00800c99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c9f:	6a 00                	push   $0x0
  800ca1:	6a 00                	push   $0x0
  800ca3:	6a 00                	push   $0x0
  800ca5:	6a 00                	push   $0x0
  800ca7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800caa:	ba 01 00 00 00       	mov    $0x1,%edx
  800caf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb4:	e8 07 fe ff ff       	call   800ac0 <syscall>
}
  800cb9:	c9                   	leave  
  800cba:	c3                   	ret    

00800cbb <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
	int r;

	void *addr = (void*)(pn << PGSHIFT);
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800cc5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800ccc:	89 ca                	mov    %ecx,%edx
  800cce:	83 e2 05             	and    $0x5,%edx
  800cd1:	83 fa 05             	cmp    $0x5,%edx
  800cd4:	75 5a                	jne    800d30 <duppage+0x75>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800cd6:	89 ca                	mov    %ecx,%edx
  800cd8:	83 e2 18             	and    $0x18,%edx
		perm |= PTE_PCD | PTE_PWT;
  800cdb:	83 fa 01             	cmp    $0x1,%edx
  800cde:	19 d2                	sbb    %edx,%edx
  800ce0:	83 e2 e8             	and    $0xffffffe8,%edx
  800ce3:	83 c2 1d             	add    $0x1d,%edx


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800ce6:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800cec:	74 68                	je     800d56 <duppage+0x9b>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800cee:	89 d3                	mov    %edx,%ebx
  800cf0:	80 cf 08             	or     $0x8,%bh
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	53                   	push   %ebx
  800cf7:	56                   	push   %esi
  800cf8:	50                   	push   %eax
  800cf9:	56                   	push   %esi
  800cfa:	6a 00                	push   $0x0
  800cfc:	e8 e4 fe ff ff       	call   800be5 <sys_page_map>
  800d01:	83 c4 20             	add    $0x20,%esp
  800d04:	85 c0                	test   %eax,%eax
  800d06:	78 3c                	js     800d44 <duppage+0x89>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	53                   	push   %ebx
  800d0c:	56                   	push   %esi
  800d0d:	6a 00                	push   $0x0
  800d0f:	56                   	push   %esi
  800d10:	6a 00                	push   $0x0
  800d12:	e8 ce fe ff ff       	call   800be5 <sys_page_map>
  800d17:	83 c4 20             	add    $0x20,%esp
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	79 4d                	jns    800d6b <duppage+0xb0>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800d1e:	50                   	push   %eax
  800d1f:	68 2c 17 80 00       	push   $0x80172c
  800d24:	6a 57                	push   $0x57
  800d26:	68 24 18 80 00       	push   $0x801824
  800d2b:	e8 14 f4 ff ff       	call   800144 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800d30:	83 ec 04             	sub    $0x4,%esp
  800d33:	68 d0 16 80 00       	push   $0x8016d0
  800d38:	6a 47                	push   $0x47
  800d3a:	68 24 18 80 00       	push   $0x801824
  800d3f:	e8 00 f4 ff ff       	call   800144 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800d44:	50                   	push   %eax
  800d45:	68 00 17 80 00       	push   $0x801700
  800d4a:	6a 53                	push   $0x53
  800d4c:	68 24 18 80 00       	push   $0x801824
  800d51:	e8 ee f3 ff ff       	call   800144 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	52                   	push   %edx
  800d5a:	56                   	push   %esi
  800d5b:	50                   	push   %eax
  800d5c:	56                   	push   %esi
  800d5d:	6a 00                	push   $0x0
  800d5f:	e8 81 fe ff ff       	call   800be5 <sys_page_map>
  800d64:	83 c4 20             	add    $0x20,%esp
  800d67:	85 c0                	test   %eax,%eax
  800d69:	78 0c                	js     800d77 <duppage+0xbc>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800d77:	50                   	push   %eax
  800d78:	68 54 17 80 00       	push   $0x801754
  800d7d:	6a 5b                	push   $0x5b
  800d7f:	68 24 18 80 00       	push   $0x801824
  800d84:	e8 bb f3 ff ff       	call   800144 <_panic>

00800d89 <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void*)(pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800d94:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800d9b:	a8 01                	test   $0x1,%al
  800d9d:	74 38                	je     800dd7 <dup_or_share+0x4e>
  800d9f:	89 cb                	mov    %ecx,%ebx
  800da1:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800da3:	21 c3                	and    %eax,%ebx
  800da5:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
  800da8:	89 c1                	mov    %eax,%ecx
  800daa:	83 e1 18             	and    $0x18,%ecx
		perm |= PTE_PCD | PTE_PWT;
  800dad:	89 da                	mov    %ebx,%edx
  800daf:	83 ca 18             	or     $0x18,%edx
  800db2:	85 c9                	test   %ecx,%ecx
  800db4:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void*)(pnum << PGSHIFT);
  800db7:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800dba:	83 e0 1a             	and    $0x1a,%eax
  800dbd:	83 f8 02             	cmp    $0x2,%eax
  800dc0:	74 32                	je     800df4 <dup_or_share+0x6b>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	53                   	push   %ebx
  800dc6:	56                   	push   %esi
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	6a 00                	push   $0x0
  800dcb:	e8 15 fe ff ff       	call   800be5 <sys_page_map>
  800dd0:	83 c4 20             	add    $0x20,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	78 08                	js     800ddf <dup_or_share+0x56>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800dd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800ddf:	50                   	push   %eax
  800de0:	68 80 17 80 00       	push   $0x801780
  800de5:	68 84 00 00 00       	push   $0x84
  800dea:	68 24 18 80 00       	push   $0x801824
  800def:	e8 50 f3 ff ff       	call   800144 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800df4:	83 ec 04             	sub    $0x4,%esp
  800df7:	53                   	push   %ebx
  800df8:	56                   	push   %esi
  800df9:	57                   	push   %edi
  800dfa:	e8 c2 fd ff ff       	call   800bc1 <sys_page_alloc>
  800dff:	83 c4 10             	add    $0x10,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	78 57                	js     800e5d <dup_or_share+0xd4>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	53                   	push   %ebx
  800e0a:	68 00 00 40 00       	push   $0x400000
  800e0f:	6a 00                	push   $0x0
  800e11:	56                   	push   %esi
  800e12:	57                   	push   %edi
  800e13:	e8 cd fd ff ff       	call   800be5 <sys_page_map>
  800e18:	83 c4 20             	add    $0x20,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	78 53                	js     800e72 <dup_or_share+0xe9>
		memmove(UTEMP, addr, PGSIZE);
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	68 00 10 00 00       	push   $0x1000
  800e27:	56                   	push   %esi
  800e28:	68 00 00 40 00       	push   $0x400000
  800e2d:	e8 df fa ff ff       	call   800911 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e32:	83 c4 08             	add    $0x8,%esp
  800e35:	68 00 00 40 00       	push   $0x400000
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 ca fd ff ff       	call   800c0b <sys_page_unmap>
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	85 c0                	test   %eax,%eax
  800e46:	79 8f                	jns    800dd7 <dup_or_share+0x4e>
			panic("sys_page_unmap: %e", r);
  800e48:	50                   	push   %eax
  800e49:	68 6e 18 80 00       	push   $0x80186e
  800e4e:	68 8d 00 00 00       	push   $0x8d
  800e53:	68 24 18 80 00       	push   $0x801824
  800e58:	e8 e7 f2 ff ff       	call   800144 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800e5d:	50                   	push   %eax
  800e5e:	68 a0 17 80 00       	push   $0x8017a0
  800e63:	68 88 00 00 00       	push   $0x88
  800e68:	68 24 18 80 00       	push   $0x801824
  800e6d:	e8 d2 f2 ff ff       	call   800144 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e72:	50                   	push   %eax
  800e73:	68 80 17 80 00       	push   $0x801780
  800e78:	68 8a 00 00 00       	push   $0x8a
  800e7d:	68 24 18 80 00       	push   $0x801824
  800e82:	e8 bd f2 ff ff       	call   800144 <_panic>

00800e87 <pgfault>:
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	53                   	push   %ebx
  800e8b:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t)addr) >> PGSHIFT];
  800e93:	89 d8                	mov    %ebx,%eax
  800e95:	c1 e8 0c             	shr    $0xc,%eax
  800e98:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800e9f:	6a 07                	push   $0x7
  800ea1:	68 00 f0 7f 00       	push   $0x7ff000
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 14 fd ff ff       	call   800bc1 <sys_page_alloc>
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	78 51                	js     800f05 <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800eb4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800eba:	83 ec 04             	sub    $0x4,%esp
  800ebd:	68 00 10 00 00       	push   $0x1000
  800ec2:	53                   	push   %ebx
  800ec3:	68 00 f0 7f 00       	push   $0x7ff000
  800ec8:	e8 44 fa ff ff       	call   800911 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800ecd:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ed4:	53                   	push   %ebx
  800ed5:	6a 00                	push   $0x0
  800ed7:	68 00 f0 7f 00       	push   $0x7ff000
  800edc:	6a 00                	push   $0x0
  800ede:	e8 02 fd ff ff       	call   800be5 <sys_page_map>
  800ee3:	83 c4 20             	add    $0x20,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	78 2d                	js     800f17 <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800eea:	83 ec 08             	sub    $0x8,%esp
  800eed:	68 00 f0 7f 00       	push   $0x7ff000
  800ef2:	6a 00                	push   $0x0
  800ef4:	e8 12 fd ff ff       	call   800c0b <sys_page_unmap>
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	85 c0                	test   %eax,%eax
  800efe:	78 29                	js     800f29 <pgfault+0xa2>
}
  800f00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800f05:	50                   	push   %eax
  800f06:	68 2f 18 80 00       	push   $0x80182f
  800f0b:	6a 27                	push   $0x27
  800f0d:	68 24 18 80 00       	push   $0x801824
  800f12:	e8 2d f2 ff ff       	call   800144 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800f17:	50                   	push   %eax
  800f18:	68 4b 18 80 00       	push   $0x80184b
  800f1d:	6a 2c                	push   $0x2c
  800f1f:	68 24 18 80 00       	push   $0x801824
  800f24:	e8 1b f2 ff ff       	call   800144 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800f29:	50                   	push   %eax
  800f2a:	68 65 18 80 00       	push   $0x801865
  800f2f:	6a 2f                	push   $0x2f
  800f31:	68 24 18 80 00       	push   $0x801824
  800f36:	e8 09 f2 ff ff       	call   800144 <_panic>

00800f3b <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	57                   	push   %edi
  800f3f:	56                   	push   %esi
  800f40:	53                   	push   %ebx
  800f41:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f44:	b8 07 00 00 00       	mov    $0x7,%eax
  800f49:	cd 30                	int    $0x30
  800f4b:	89 c7                	mov    %eax,%edi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	78 24                	js     800f75 <fork_v0+0x3a>
  800f51:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f53:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	75 39                	jne    800f95 <fork_v0+0x5a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f5c:	e8 15 fc ff ff       	call   800b76 <sys_getenvid>
  800f61:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f66:	c1 e0 07             	shl    $0x7,%eax
  800f69:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f6e:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800f73:	eb 56                	jmp    800fcb <fork_v0+0x90>
		panic("sys_exofork: %e", envid);
  800f75:	50                   	push   %eax
  800f76:	68 81 18 80 00       	push   $0x801881
  800f7b:	68 a2 00 00 00       	push   $0xa2
  800f80:	68 24 18 80 00       	push   $0x801824
  800f85:	e8 ba f1 ff ff       	call   800144 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f8a:	83 c3 01             	add    $0x1,%ebx
  800f8d:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800f93:	74 24                	je     800fb9 <fork_v0+0x7e>
		pde_t pde = uvpd[pnum >> 10];
  800f95:	89 d8                	mov    %ebx,%eax
  800f97:	c1 e8 0a             	shr    $0xa,%eax
  800f9a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800fa1:	83 e0 05             	and    $0x5,%eax
  800fa4:	83 f8 05             	cmp    $0x5,%eax
  800fa7:	75 e1                	jne    800f8a <fork_v0+0x4f>
			continue;
		dup_or_share(envid, pnum, perm);
  800fa9:	b9 07 00 00 00       	mov    $0x7,%ecx
  800fae:	89 da                	mov    %ebx,%edx
  800fb0:	89 f0                	mov    %esi,%eax
  800fb2:	e8 d2 fd ff ff       	call   800d89 <dup_or_share>
  800fb7:	eb d1                	jmp    800f8a <fork_v0+0x4f>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	6a 02                	push   $0x2
  800fbe:	57                   	push   %edi
  800fbf:	e8 6a fc ff ff       	call   800c2e <sys_env_set_status>
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 0a                	js     800fd5 <fork_v0+0x9a>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800fcb:	89 f8                	mov    %edi,%eax
  800fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800fd5:	50                   	push   %eax
  800fd6:	68 91 18 80 00       	push   $0x801891
  800fdb:	68 b8 00 00 00       	push   $0xb8
  800fe0:	68 24 18 80 00       	push   $0x801824
  800fe5:	e8 5a f1 ff ff       	call   800144 <_panic>

00800fea <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800ff3:	68 87 0e 80 00       	push   $0x800e87
  800ff8:	e8 32 01 00 00       	call   80112f <set_pgfault_handler>
  800ffd:	b8 07 00 00 00       	mov    $0x7,%eax
  801002:	cd 30                	int    $0x30
  801004:	89 c7                	mov    %eax,%edi

	envid_t envid = sys_exofork();
	if (envid < 0)
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 27                	js     801034 <fork+0x4a>
  80100d:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  80100f:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  801014:	85 c0                	test   %eax,%eax
  801016:	75 44                	jne    80105c <fork+0x72>
		thisenv = &envs[ENVX(sys_getenvid())];
  801018:	e8 59 fb ff ff       	call   800b76 <sys_getenvid>
  80101d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801022:	c1 e0 07             	shl    $0x7,%eax
  801025:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80102a:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  80102f:	e9 98 00 00 00       	jmp    8010cc <fork+0xe2>
		panic("sys_exofork: %e", envid);
  801034:	50                   	push   %eax
  801035:	68 81 18 80 00       	push   $0x801881
  80103a:	68 d6 00 00 00       	push   $0xd6
  80103f:	68 24 18 80 00       	push   $0x801824
  801044:	e8 fb f0 ff ff       	call   800144 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  801049:	83 c3 01             	add    $0x1,%ebx
  80104c:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801052:	77 36                	ja     80108a <fork+0xa0>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  801054:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80105a:	74 ed                	je     801049 <fork+0x5f>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  80105c:	89 d8                	mov    %ebx,%eax
  80105e:	c1 e8 0a             	shr    $0xa,%eax
  801061:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  801068:	83 e0 05             	and    $0x5,%eax
  80106b:	83 f8 05             	cmp    $0x5,%eax
  80106e:	75 d9                	jne    801049 <fork+0x5f>
			continue;

		pte_t pte = uvpt[pnum];
  801070:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  801077:	83 e0 05             	and    $0x5,%eax
  80107a:	83 f8 05             	cmp    $0x5,%eax
  80107d:	75 ca                	jne    801049 <fork+0x5f>
			continue;
		duppage(envid, pnum);
  80107f:	89 da                	mov    %ebx,%edx
  801081:	89 f0                	mov    %esi,%eax
  801083:	e8 33 fc ff ff       	call   800cbb <duppage>
  801088:	eb bf                	jmp    801049 <fork+0x5f>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void*)exstk, PTE_U | PTE_P | PTE_W);
  80108a:	83 ec 04             	sub    $0x4,%esp
  80108d:	6a 07                	push   $0x7
  80108f:	68 00 f0 bf ee       	push   $0xeebff000
  801094:	57                   	push   %edi
  801095:	e8 27 fb ff ff       	call   800bc1 <sys_page_alloc>
	if (r < 0)
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	85 c0                	test   %eax,%eax
  80109f:	78 35                	js     8010d6 <fork+0xec>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010a1:	a1 08 20 80 00       	mov    0x802008,%eax
  8010a6:	8b 40 68             	mov    0x68(%eax),%eax
  8010a9:	83 ec 08             	sub    $0x8,%esp
  8010ac:	50                   	push   %eax
  8010ad:	57                   	push   %edi
  8010ae:	e8 9e fb ff ff       	call   800c51 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 31                	js     8010eb <fork+0x101>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	6a 02                	push   $0x2
  8010bf:	57                   	push   %edi
  8010c0:	e8 69 fb ff ff       	call   800c2e <sys_env_set_status>
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 34                	js     801100 <fork+0x116>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  8010cc:	89 f8                	mov    %edi,%eax
  8010ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  8010d6:	50                   	push   %eax
  8010d7:	68 c4 17 80 00       	push   $0x8017c4
  8010dc:	68 f3 00 00 00       	push   $0xf3
  8010e1:	68 24 18 80 00       	push   $0x801824
  8010e6:	e8 59 f0 ff ff       	call   800144 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  8010eb:	50                   	push   %eax
  8010ec:	68 f0 17 80 00       	push   $0x8017f0
  8010f1:	68 f6 00 00 00       	push   $0xf6
  8010f6:	68 24 18 80 00       	push   $0x801824
  8010fb:	e8 44 f0 ff ff       	call   800144 <_panic>
		panic("sys_env_set_status: %e", r);
  801100:	50                   	push   %eax
  801101:	68 91 18 80 00       	push   $0x801891
  801106:	68 f9 00 00 00       	push   $0xf9
  80110b:	68 24 18 80 00       	push   $0x801824
  801110:	e8 2f f0 ff ff       	call   800144 <_panic>

00801115 <sfork>:

// Challenge!
int
sfork(void)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80111b:	68 a8 18 80 00       	push   $0x8018a8
  801120:	68 02 01 00 00       	push   $0x102
  801125:	68 24 18 80 00       	push   $0x801824
  80112a:	e8 15 f0 ff ff       	call   800144 <_panic>

0080112f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801135:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80113c:	74 0a                	je     801148 <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801146:	c9                   	leave  
  801147:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  801148:	83 ec 04             	sub    $0x4,%esp
  80114b:	6a 07                	push   $0x7
  80114d:	68 00 f0 bf ee       	push   $0xeebff000
  801152:	6a 00                	push   $0x0
  801154:	e8 68 fa ff ff       	call   800bc1 <sys_page_alloc>
		if (r < 0) return;
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 e6                	js     801146 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801160:	83 ec 08             	sub    $0x8,%esp
  801163:	68 78 11 80 00       	push   $0x801178
  801168:	6a 00                	push   $0x0
  80116a:	e8 e2 fa ff ff       	call   800c51 <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	79 c8                	jns    80113e <set_pgfault_handler+0xf>
  801176:	eb ce                	jmp    801146 <set_pgfault_handler+0x17>

00801178 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801178:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801179:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80117e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801180:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801183:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801187:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80118b:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  80118e:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  801190:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  801194:	58                   	pop    %eax
	popl %eax
  801195:	58                   	pop    %eax
	popal
  801196:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  801197:	83 c4 04             	add    $0x4,%esp
	popfl
  80119a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  80119b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  80119c:	c3                   	ret    
  80119d:	66 90                	xchg   %ax,%ax
  80119f:	90                   	nop

008011a0 <__udivdi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 1c             	sub    $0x1c,%esp
  8011a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8011ab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8011af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011b3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8011b7:	85 d2                	test   %edx,%edx
  8011b9:	75 35                	jne    8011f0 <__udivdi3+0x50>
  8011bb:	39 f3                	cmp    %esi,%ebx
  8011bd:	0f 87 bd 00 00 00    	ja     801280 <__udivdi3+0xe0>
  8011c3:	85 db                	test   %ebx,%ebx
  8011c5:	89 d9                	mov    %ebx,%ecx
  8011c7:	75 0b                	jne    8011d4 <__udivdi3+0x34>
  8011c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ce:	31 d2                	xor    %edx,%edx
  8011d0:	f7 f3                	div    %ebx
  8011d2:	89 c1                	mov    %eax,%ecx
  8011d4:	31 d2                	xor    %edx,%edx
  8011d6:	89 f0                	mov    %esi,%eax
  8011d8:	f7 f1                	div    %ecx
  8011da:	89 c6                	mov    %eax,%esi
  8011dc:	89 e8                	mov    %ebp,%eax
  8011de:	89 f7                	mov    %esi,%edi
  8011e0:	f7 f1                	div    %ecx
  8011e2:	89 fa                	mov    %edi,%edx
  8011e4:	83 c4 1c             	add    $0x1c,%esp
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5f                   	pop    %edi
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	39 f2                	cmp    %esi,%edx
  8011f2:	77 7c                	ja     801270 <__udivdi3+0xd0>
  8011f4:	0f bd fa             	bsr    %edx,%edi
  8011f7:	83 f7 1f             	xor    $0x1f,%edi
  8011fa:	0f 84 98 00 00 00    	je     801298 <__udivdi3+0xf8>
  801200:	89 f9                	mov    %edi,%ecx
  801202:	b8 20 00 00 00       	mov    $0x20,%eax
  801207:	29 f8                	sub    %edi,%eax
  801209:	d3 e2                	shl    %cl,%edx
  80120b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80120f:	89 c1                	mov    %eax,%ecx
  801211:	89 da                	mov    %ebx,%edx
  801213:	d3 ea                	shr    %cl,%edx
  801215:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801219:	09 d1                	or     %edx,%ecx
  80121b:	89 f2                	mov    %esi,%edx
  80121d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801221:	89 f9                	mov    %edi,%ecx
  801223:	d3 e3                	shl    %cl,%ebx
  801225:	89 c1                	mov    %eax,%ecx
  801227:	d3 ea                	shr    %cl,%edx
  801229:	89 f9                	mov    %edi,%ecx
  80122b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80122f:	d3 e6                	shl    %cl,%esi
  801231:	89 eb                	mov    %ebp,%ebx
  801233:	89 c1                	mov    %eax,%ecx
  801235:	d3 eb                	shr    %cl,%ebx
  801237:	09 de                	or     %ebx,%esi
  801239:	89 f0                	mov    %esi,%eax
  80123b:	f7 74 24 08          	divl   0x8(%esp)
  80123f:	89 d6                	mov    %edx,%esi
  801241:	89 c3                	mov    %eax,%ebx
  801243:	f7 64 24 0c          	mull   0xc(%esp)
  801247:	39 d6                	cmp    %edx,%esi
  801249:	72 0c                	jb     801257 <__udivdi3+0xb7>
  80124b:	89 f9                	mov    %edi,%ecx
  80124d:	d3 e5                	shl    %cl,%ebp
  80124f:	39 c5                	cmp    %eax,%ebp
  801251:	73 5d                	jae    8012b0 <__udivdi3+0x110>
  801253:	39 d6                	cmp    %edx,%esi
  801255:	75 59                	jne    8012b0 <__udivdi3+0x110>
  801257:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80125a:	31 ff                	xor    %edi,%edi
  80125c:	89 fa                	mov    %edi,%edx
  80125e:	83 c4 1c             	add    $0x1c,%esp
  801261:	5b                   	pop    %ebx
  801262:	5e                   	pop    %esi
  801263:	5f                   	pop    %edi
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    
  801266:	8d 76 00             	lea    0x0(%esi),%esi
  801269:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801270:	31 ff                	xor    %edi,%edi
  801272:	31 c0                	xor    %eax,%eax
  801274:	89 fa                	mov    %edi,%edx
  801276:	83 c4 1c             	add    $0x1c,%esp
  801279:	5b                   	pop    %ebx
  80127a:	5e                   	pop    %esi
  80127b:	5f                   	pop    %edi
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    
  80127e:	66 90                	xchg   %ax,%ax
  801280:	31 ff                	xor    %edi,%edi
  801282:	89 e8                	mov    %ebp,%eax
  801284:	89 f2                	mov    %esi,%edx
  801286:	f7 f3                	div    %ebx
  801288:	89 fa                	mov    %edi,%edx
  80128a:	83 c4 1c             	add    $0x1c,%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5f                   	pop    %edi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    
  801292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801298:	39 f2                	cmp    %esi,%edx
  80129a:	72 06                	jb     8012a2 <__udivdi3+0x102>
  80129c:	31 c0                	xor    %eax,%eax
  80129e:	39 eb                	cmp    %ebp,%ebx
  8012a0:	77 d2                	ja     801274 <__udivdi3+0xd4>
  8012a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a7:	eb cb                	jmp    801274 <__udivdi3+0xd4>
  8012a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	89 d8                	mov    %ebx,%eax
  8012b2:	31 ff                	xor    %edi,%edi
  8012b4:	eb be                	jmp    801274 <__udivdi3+0xd4>
  8012b6:	66 90                	xchg   %ax,%ax
  8012b8:	66 90                	xchg   %ax,%ax
  8012ba:	66 90                	xchg   %ax,%ax
  8012bc:	66 90                	xchg   %ax,%ax
  8012be:	66 90                	xchg   %ax,%ax

008012c0 <__umoddi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 1c             	sub    $0x1c,%esp
  8012c7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8012cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8012cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8012d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012d7:	85 ed                	test   %ebp,%ebp
  8012d9:	89 f0                	mov    %esi,%eax
  8012db:	89 da                	mov    %ebx,%edx
  8012dd:	75 19                	jne    8012f8 <__umoddi3+0x38>
  8012df:	39 df                	cmp    %ebx,%edi
  8012e1:	0f 86 b1 00 00 00    	jbe    801398 <__umoddi3+0xd8>
  8012e7:	f7 f7                	div    %edi
  8012e9:	89 d0                	mov    %edx,%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	83 c4 1c             	add    $0x1c,%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5f                   	pop    %edi
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    
  8012f5:	8d 76 00             	lea    0x0(%esi),%esi
  8012f8:	39 dd                	cmp    %ebx,%ebp
  8012fa:	77 f1                	ja     8012ed <__umoddi3+0x2d>
  8012fc:	0f bd cd             	bsr    %ebp,%ecx
  8012ff:	83 f1 1f             	xor    $0x1f,%ecx
  801302:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801306:	0f 84 b4 00 00 00    	je     8013c0 <__umoddi3+0x100>
  80130c:	b8 20 00 00 00       	mov    $0x20,%eax
  801311:	89 c2                	mov    %eax,%edx
  801313:	8b 44 24 04          	mov    0x4(%esp),%eax
  801317:	29 c2                	sub    %eax,%edx
  801319:	89 c1                	mov    %eax,%ecx
  80131b:	89 f8                	mov    %edi,%eax
  80131d:	d3 e5                	shl    %cl,%ebp
  80131f:	89 d1                	mov    %edx,%ecx
  801321:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801325:	d3 e8                	shr    %cl,%eax
  801327:	09 c5                	or     %eax,%ebp
  801329:	8b 44 24 04          	mov    0x4(%esp),%eax
  80132d:	89 c1                	mov    %eax,%ecx
  80132f:	d3 e7                	shl    %cl,%edi
  801331:	89 d1                	mov    %edx,%ecx
  801333:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801337:	89 df                	mov    %ebx,%edi
  801339:	d3 ef                	shr    %cl,%edi
  80133b:	89 c1                	mov    %eax,%ecx
  80133d:	89 f0                	mov    %esi,%eax
  80133f:	d3 e3                	shl    %cl,%ebx
  801341:	89 d1                	mov    %edx,%ecx
  801343:	89 fa                	mov    %edi,%edx
  801345:	d3 e8                	shr    %cl,%eax
  801347:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80134c:	09 d8                	or     %ebx,%eax
  80134e:	f7 f5                	div    %ebp
  801350:	d3 e6                	shl    %cl,%esi
  801352:	89 d1                	mov    %edx,%ecx
  801354:	f7 64 24 08          	mull   0x8(%esp)
  801358:	39 d1                	cmp    %edx,%ecx
  80135a:	89 c3                	mov    %eax,%ebx
  80135c:	89 d7                	mov    %edx,%edi
  80135e:	72 06                	jb     801366 <__umoddi3+0xa6>
  801360:	75 0e                	jne    801370 <__umoddi3+0xb0>
  801362:	39 c6                	cmp    %eax,%esi
  801364:	73 0a                	jae    801370 <__umoddi3+0xb0>
  801366:	2b 44 24 08          	sub    0x8(%esp),%eax
  80136a:	19 ea                	sbb    %ebp,%edx
  80136c:	89 d7                	mov    %edx,%edi
  80136e:	89 c3                	mov    %eax,%ebx
  801370:	89 ca                	mov    %ecx,%edx
  801372:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801377:	29 de                	sub    %ebx,%esi
  801379:	19 fa                	sbb    %edi,%edx
  80137b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80137f:	89 d0                	mov    %edx,%eax
  801381:	d3 e0                	shl    %cl,%eax
  801383:	89 d9                	mov    %ebx,%ecx
  801385:	d3 ee                	shr    %cl,%esi
  801387:	d3 ea                	shr    %cl,%edx
  801389:	09 f0                	or     %esi,%eax
  80138b:	83 c4 1c             	add    $0x1c,%esp
  80138e:	5b                   	pop    %ebx
  80138f:	5e                   	pop    %esi
  801390:	5f                   	pop    %edi
  801391:	5d                   	pop    %ebp
  801392:	c3                   	ret    
  801393:	90                   	nop
  801394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801398:	85 ff                	test   %edi,%edi
  80139a:	89 f9                	mov    %edi,%ecx
  80139c:	75 0b                	jne    8013a9 <__umoddi3+0xe9>
  80139e:	b8 01 00 00 00       	mov    $0x1,%eax
  8013a3:	31 d2                	xor    %edx,%edx
  8013a5:	f7 f7                	div    %edi
  8013a7:	89 c1                	mov    %eax,%ecx
  8013a9:	89 d8                	mov    %ebx,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	f7 f1                	div    %ecx
  8013af:	89 f0                	mov    %esi,%eax
  8013b1:	f7 f1                	div    %ecx
  8013b3:	e9 31 ff ff ff       	jmp    8012e9 <__umoddi3+0x29>
  8013b8:	90                   	nop
  8013b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	39 dd                	cmp    %ebx,%ebp
  8013c2:	72 08                	jb     8013cc <__umoddi3+0x10c>
  8013c4:	39 f7                	cmp    %esi,%edi
  8013c6:	0f 87 21 ff ff ff    	ja     8012ed <__umoddi3+0x2d>
  8013cc:	89 da                	mov    %ebx,%edx
  8013ce:	89 f0                	mov    %esi,%eax
  8013d0:	29 f8                	sub    %edi,%eax
  8013d2:	19 ea                	sbb    %ebp,%edx
  8013d4:	e9 14 ff ff ff       	jmp    8012ed <__umoddi3+0x2d>
