
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 00 0f 80 00       	push   $0x800f00
  80003e:	e8 d0 01 00 00       	call   800213 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	75 63                	jne    8000b8 <umain+0x85>
	for (i = 0; i < ARRAYSIZE; i++)
  800055:	83 c0 01             	add    $0x1,%eax
  800058:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80005d:	75 ec                	jne    80004b <umain+0x18>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80005f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800064:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006b:	83 c0 01             	add    $0x1,%eax
  80006e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800073:	75 ef                	jne    800064 <umain+0x31>
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007a:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800081:	75 47                	jne    8000ca <umain+0x97>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 ed                	jne    80007a <umain+0x47>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	68 48 0f 80 00       	push   $0x800f48
  800095:	e8 79 01 00 00       	call   800213 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009a:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000a1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	68 a7 0f 80 00       	push   $0x800fa7
  8000ac:	6a 1a                	push   $0x1a
  8000ae:	68 98 0f 80 00       	push   $0x800f98
  8000b3:	e8 80 00 00 00       	call   800138 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b8:	50                   	push   %eax
  8000b9:	68 7b 0f 80 00       	push   $0x800f7b
  8000be:	6a 11                	push   $0x11
  8000c0:	68 98 0f 80 00       	push   $0x800f98
  8000c5:	e8 6e 00 00 00       	call   800138 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ca:	50                   	push   %eax
  8000cb:	68 20 0f 80 00       	push   $0x800f20
  8000d0:	6a 16                	push   $0x16
  8000d2:	68 98 0f 80 00       	push   $0x800f98
  8000d7:	e8 5c 00 00 00       	call   800138 <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000e7:	e8 7e 0a 00 00       	call   800b6a <sys_getenvid>
	if (id >= 0)
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	78 12                	js     800102 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8000f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f5:	c1 e0 07             	shl    $0x7,%eax
  8000f8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fd:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800102:	85 db                	test   %ebx,%ebx
  800104:	7e 07                	jle    80010d <libmain+0x31>
		binaryname = argv[0];
  800106:	8b 06                	mov    (%esi),%eax
  800108:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010d:	83 ec 08             	sub    $0x8,%esp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	e8 1c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800117:	e8 0a 00 00 00       	call   800126 <exit>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012c:	6a 00                	push   $0x0
  80012e:	e8 15 0a 00 00       	call   800b48 <sys_env_destroy>
}
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800140:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800146:	e8 1f 0a 00 00       	call   800b6a <sys_getenvid>
  80014b:	83 ec 0c             	sub    $0xc,%esp
  80014e:	ff 75 0c             	pushl  0xc(%ebp)
  800151:	ff 75 08             	pushl  0x8(%ebp)
  800154:	56                   	push   %esi
  800155:	50                   	push   %eax
  800156:	68 c8 0f 80 00       	push   $0x800fc8
  80015b:	e8 b3 00 00 00       	call   800213 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800160:	83 c4 18             	add    $0x18,%esp
  800163:	53                   	push   %ebx
  800164:	ff 75 10             	pushl  0x10(%ebp)
  800167:	e8 56 00 00 00       	call   8001c2 <vcprintf>
	cprintf("\n");
  80016c:	c7 04 24 96 0f 80 00 	movl   $0x800f96,(%esp)
  800173:	e8 9b 00 00 00       	call   800213 <cprintf>
  800178:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017b:	cc                   	int3   
  80017c:	eb fd                	jmp    80017b <_panic+0x43>

0080017e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	53                   	push   %ebx
  800182:	83 ec 04             	sub    $0x4,%esp
  800185:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800188:	8b 13                	mov    (%ebx),%edx
  80018a:	8d 42 01             	lea    0x1(%edx),%eax
  80018d:	89 03                	mov    %eax,(%ebx)
  80018f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800192:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800196:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019b:	74 09                	je     8001a6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80019d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a6:	83 ec 08             	sub    $0x8,%esp
  8001a9:	68 ff 00 00 00       	push   $0xff
  8001ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b1:	50                   	push   %eax
  8001b2:	e8 47 09 00 00       	call   800afe <sys_cputs>
		b->idx = 0;
  8001b7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bd:	83 c4 10             	add    $0x10,%esp
  8001c0:	eb db                	jmp    80019d <putch+0x1f>

008001c2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d2:	00 00 00 
	b.cnt = 0;
  8001d5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001eb:	50                   	push   %eax
  8001ec:	68 7e 01 80 00       	push   $0x80017e
  8001f1:	e8 86 01 00 00       	call   80037c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f6:	83 c4 08             	add    $0x8,%esp
  8001f9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800205:	50                   	push   %eax
  800206:	e8 f3 08 00 00       	call   800afe <sys_cputs>

	return b.cnt;
}
  80020b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800219:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021c:	50                   	push   %eax
  80021d:	ff 75 08             	pushl  0x8(%ebp)
  800220:	e8 9d ff ff ff       	call   8001c2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 1c             	sub    $0x1c,%esp
  800230:	89 c7                	mov    %eax,%edi
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 45 08             	mov    0x8(%ebp),%eax
  800237:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800243:	bb 00 00 00 00       	mov    $0x0,%ebx
  800248:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024e:	39 d3                	cmp    %edx,%ebx
  800250:	72 05                	jb     800257 <printnum+0x30>
  800252:	39 45 10             	cmp    %eax,0x10(%ebp)
  800255:	77 7a                	ja     8002d1 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 18             	pushl  0x18(%ebp)
  80025d:	8b 45 14             	mov    0x14(%ebp),%eax
  800260:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800263:	53                   	push   %ebx
  800264:	ff 75 10             	pushl  0x10(%ebp)
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026d:	ff 75 e0             	pushl  -0x20(%ebp)
  800270:	ff 75 dc             	pushl  -0x24(%ebp)
  800273:	ff 75 d8             	pushl  -0x28(%ebp)
  800276:	e8 35 0a 00 00       	call   800cb0 <__udivdi3>
  80027b:	83 c4 18             	add    $0x18,%esp
  80027e:	52                   	push   %edx
  80027f:	50                   	push   %eax
  800280:	89 f2                	mov    %esi,%edx
  800282:	89 f8                	mov    %edi,%eax
  800284:	e8 9e ff ff ff       	call   800227 <printnum>
  800289:	83 c4 20             	add    $0x20,%esp
  80028c:	eb 13                	jmp    8002a1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	ff 75 18             	pushl  0x18(%ebp)
  800295:	ff d7                	call   *%edi
  800297:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80029a:	83 eb 01             	sub    $0x1,%ebx
  80029d:	85 db                	test   %ebx,%ebx
  80029f:	7f ed                	jg     80028e <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	83 ec 04             	sub    $0x4,%esp
  8002a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b4:	e8 17 0b 00 00       	call   800dd0 <__umoddi3>
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	0f be 80 ec 0f 80 00 	movsbl 0x800fec(%eax),%eax
  8002c3:	50                   	push   %eax
  8002c4:	ff d7                	call   *%edi
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cc:	5b                   	pop    %ebx
  8002cd:	5e                   	pop    %esi
  8002ce:	5f                   	pop    %edi
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    
  8002d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d4:	eb c4                	jmp    80029a <printnum+0x73>

008002d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d9:	83 fa 01             	cmp    $0x1,%edx
  8002dc:	7e 0e                	jle    8002ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    
	else if (lflag)
  8002ec:	85 d2                	test   %edx,%edx
  8002ee:	75 10                	jne    800300 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	eb ea                	jmp    8002ea <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	eb da                	jmp    8002ea <getuint+0x14>

00800310 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800313:	83 fa 01             	cmp    $0x1,%edx
  800316:	7e 0e                	jle    800326 <getint+0x16>
		return va_arg(*ap, long long);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    
	else if (lflag)
  800326:	85 d2                	test   %edx,%edx
  800328:	75 0c                	jne    800336 <getint+0x26>
		return va_arg(*ap, int);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	99                   	cltd   
  800334:	eb ee                	jmp    800324 <getint+0x14>
		return va_arg(*ap, long);
  800336:	8b 10                	mov    (%eax),%edx
  800338:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	99                   	cltd   
  800340:	eb e2                	jmp    800324 <getint+0x14>

00800342 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800348:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	3b 50 04             	cmp    0x4(%eax),%edx
  800351:	73 0a                	jae    80035d <sprintputch+0x1b>
		*b->buf++ = ch;
  800353:	8d 4a 01             	lea    0x1(%edx),%ecx
  800356:	89 08                	mov    %ecx,(%eax)
  800358:	8b 45 08             	mov    0x8(%ebp),%eax
  80035b:	88 02                	mov    %al,(%edx)
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <printfmt>:
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800365:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800368:	50                   	push   %eax
  800369:	ff 75 10             	pushl  0x10(%ebp)
  80036c:	ff 75 0c             	pushl  0xc(%ebp)
  80036f:	ff 75 08             	pushl  0x8(%ebp)
  800372:	e8 05 00 00 00       	call   80037c <vprintfmt>
}
  800377:	83 c4 10             	add    $0x10,%esp
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <vprintfmt>:
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	57                   	push   %edi
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
  800382:	83 ec 2c             	sub    $0x2c,%esp
  800385:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800388:	8b 75 0c             	mov    0xc(%ebp),%esi
  80038b:	89 f7                	mov    %esi,%edi
  80038d:	89 de                	mov    %ebx,%esi
  80038f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800392:	e9 9e 02 00 00       	jmp    800635 <vprintfmt+0x2b9>
		padc = ' ';
  800397:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80039b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003a2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003a9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003b0:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8d 43 01             	lea    0x1(%ebx),%eax
  8003b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bb:	0f b6 0b             	movzbl (%ebx),%ecx
  8003be:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8003c1:	3c 55                	cmp    $0x55,%al
  8003c3:	0f 87 e8 02 00 00    	ja     8006b1 <vprintfmt+0x335>
  8003c9:	0f b6 c0             	movzbl %al,%eax
  8003cc:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8003d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  8003d6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003da:	eb d9                	jmp    8003b5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  8003df:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e3:	eb d0                	jmp    8003b5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	0f b6 c9             	movzbl %cl,%ecx
  8003e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  8003eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003f3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fa:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8003fd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800400:	83 fa 09             	cmp    $0x9,%edx
  800403:	77 52                	ja     800457 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800405:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800408:	eb e9                	jmp    8003f3 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 48 04             	lea    0x4(%eax),%ecx
  800410:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80041b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041f:	79 94                	jns    8003b5 <vprintfmt+0x39>
				width = precision, precision = -1;
  800421:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800424:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800427:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042e:	eb 85                	jmp    8003b5 <vprintfmt+0x39>
  800430:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800433:	85 c0                	test   %eax,%eax
  800435:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043a:	0f 49 c8             	cmovns %eax,%ecx
  80043d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800443:	e9 6d ff ff ff       	jmp    8003b5 <vprintfmt+0x39>
  800448:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80044b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800452:	e9 5e ff ff ff       	jmp    8003b5 <vprintfmt+0x39>
  800457:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80045a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80045d:	eb bc                	jmp    80041b <vprintfmt+0x9f>
			lflag++;
  80045f:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800465:	e9 4b ff ff ff       	jmp    8003b5 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	57                   	push   %edi
  800477:	ff 30                	pushl  (%eax)
  800479:	ff d6                	call   *%esi
			break;
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	e9 af 01 00 00       	jmp    800632 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 50 04             	lea    0x4(%eax),%edx
  800489:	89 55 14             	mov    %edx,0x14(%ebp)
  80048c:	8b 00                	mov    (%eax),%eax
  80048e:	99                   	cltd   
  80048f:	31 d0                	xor    %edx,%eax
  800491:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800493:	83 f8 08             	cmp    $0x8,%eax
  800496:	7f 20                	jg     8004b8 <vprintfmt+0x13c>
  800498:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80049f:	85 d2                	test   %edx,%edx
  8004a1:	74 15                	je     8004b8 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  8004a3:	52                   	push   %edx
  8004a4:	68 0d 10 80 00       	push   $0x80100d
  8004a9:	57                   	push   %edi
  8004aa:	56                   	push   %esi
  8004ab:	e8 af fe ff ff       	call   80035f <printfmt>
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	e9 7a 01 00 00       	jmp    800632 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8004b8:	50                   	push   %eax
  8004b9:	68 04 10 80 00       	push   $0x801004
  8004be:	57                   	push   %edi
  8004bf:	56                   	push   %esi
  8004c0:	e8 9a fe ff ff       	call   80035f <printfmt>
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	e9 65 01 00 00       	jmp    800632 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 50 04             	lea    0x4(%eax),%edx
  8004d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d6:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  8004d8:	85 db                	test   %ebx,%ebx
  8004da:	b8 fd 0f 80 00       	mov    $0x800ffd,%eax
  8004df:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  8004e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e6:	0f 8e bd 00 00 00    	jle    8005a9 <vprintfmt+0x22d>
  8004ec:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f0:	75 0e                	jne    800500 <vprintfmt+0x184>
  8004f2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004fb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004fe:	eb 6d                	jmp    80056d <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	ff 75 d0             	pushl  -0x30(%ebp)
  800506:	53                   	push   %ebx
  800507:	e8 4d 02 00 00       	call   800759 <strnlen>
  80050c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050f:	29 c1                	sub    %eax,%ecx
  800511:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800514:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800517:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800521:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	eb 0f                	jmp    800534 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	57                   	push   %edi
  800529:	ff 75 e0             	pushl  -0x20(%ebp)
  80052c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80052e:	83 eb 01             	sub    $0x1,%ebx
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	85 db                	test   %ebx,%ebx
  800536:	7f ed                	jg     800525 <vprintfmt+0x1a9>
  800538:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80053b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80053e:	85 c9                	test   %ecx,%ecx
  800540:	b8 00 00 00 00       	mov    $0x0,%eax
  800545:	0f 49 c1             	cmovns %ecx,%eax
  800548:	29 c1                	sub    %eax,%ecx
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800550:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800553:	89 cf                	mov    %ecx,%edi
  800555:	eb 16                	jmp    80056d <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800557:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055b:	75 31                	jne    80058e <vprintfmt+0x212>
					putch(ch, putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	ff 75 0c             	pushl  0xc(%ebp)
  800563:	50                   	push   %eax
  800564:	ff 55 08             	call   *0x8(%ebp)
  800567:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056a:	83 ef 01             	sub    $0x1,%edi
  80056d:	83 c3 01             	add    $0x1,%ebx
  800570:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  800574:	0f be c2             	movsbl %dl,%eax
  800577:	85 c0                	test   %eax,%eax
  800579:	74 50                	je     8005cb <vprintfmt+0x24f>
  80057b:	85 f6                	test   %esi,%esi
  80057d:	78 d8                	js     800557 <vprintfmt+0x1db>
  80057f:	83 ee 01             	sub    $0x1,%esi
  800582:	79 d3                	jns    800557 <vprintfmt+0x1db>
  800584:	89 fb                	mov    %edi,%ebx
  800586:	8b 75 08             	mov    0x8(%ebp),%esi
  800589:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80058c:	eb 37                	jmp    8005c5 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  80058e:	0f be d2             	movsbl %dl,%edx
  800591:	83 ea 20             	sub    $0x20,%edx
  800594:	83 fa 5e             	cmp    $0x5e,%edx
  800597:	76 c4                	jbe    80055d <vprintfmt+0x1e1>
					putch('?', putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	ff 75 0c             	pushl  0xc(%ebp)
  80059f:	6a 3f                	push   $0x3f
  8005a1:	ff 55 08             	call   *0x8(%ebp)
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	eb c1                	jmp    80056a <vprintfmt+0x1ee>
  8005a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005af:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005b2:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005b5:	eb b6                	jmp    80056d <vprintfmt+0x1f1>
				putch(' ', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	6a 20                	push   $0x20
  8005bd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005bf:	83 eb 01             	sub    $0x1,%ebx
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	85 db                	test   %ebx,%ebx
  8005c7:	7f ee                	jg     8005b7 <vprintfmt+0x23b>
  8005c9:	eb 67                	jmp    800632 <vprintfmt+0x2b6>
  8005cb:	89 fb                	mov    %edi,%ebx
  8005cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005d3:	eb f0                	jmp    8005c5 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  8005d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d8:	e8 33 fd ff ff       	call   800310 <getint>
  8005dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	79 2c                	jns    800618 <vprintfmt+0x29c>
				putch('-', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	57                   	push   %edi
  8005f0:	6a 2d                	push   $0x2d
  8005f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fa:	f7 d8                	neg    %eax
  8005fc:	83 d2 00             	adc    $0x0,%edx
  8005ff:	f7 da                	neg    %edx
  800601:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800604:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800609:	eb 0d                	jmp    800618 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 c3 fc ff ff       	call   8002d6 <getuint>
			base = 10;
  800613:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800618:	83 ec 0c             	sub    $0xc,%esp
  80061b:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80061f:	53                   	push   %ebx
  800620:	ff 75 e0             	pushl  -0x20(%ebp)
  800623:	51                   	push   %ecx
  800624:	52                   	push   %edx
  800625:	50                   	push   %eax
  800626:	89 fa                	mov    %edi,%edx
  800628:	89 f0                	mov    %esi,%eax
  80062a:	e8 f8 fb ff ff       	call   800227 <printnum>
			break;
  80062f:	83 c4 20             	add    $0x20,%esp
{
  800632:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800635:	83 c3 01             	add    $0x1,%ebx
  800638:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  80063c:	83 f8 25             	cmp    $0x25,%eax
  80063f:	0f 84 52 fd ff ff    	je     800397 <vprintfmt+0x1b>
			if (ch == '\0')
  800645:	85 c0                	test   %eax,%eax
  800647:	0f 84 84 00 00 00    	je     8006d1 <vprintfmt+0x355>
			putch(ch, putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	57                   	push   %edi
  800651:	50                   	push   %eax
  800652:	ff d6                	call   *%esi
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb dc                	jmp    800635 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  800659:	8d 45 14             	lea    0x14(%ebp),%eax
  80065c:	e8 75 fc ff ff       	call   8002d6 <getuint>
			base = 8;
  800661:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800666:	eb b0                	jmp    800618 <vprintfmt+0x29c>
			putch('0', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	57                   	push   %edi
  80066c:	6a 30                	push   $0x30
  80066e:	ff d6                	call   *%esi
			putch('x', putdat);
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	57                   	push   %edi
  800674:	6a 78                	push   $0x78
  800676:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800681:	8b 00                	mov    (%eax),%eax
  800683:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800688:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80068b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800690:	eb 86                	jmp    800618 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800692:	8d 45 14             	lea    0x14(%ebp),%eax
  800695:	e8 3c fc ff ff       	call   8002d6 <getuint>
			base = 16;
  80069a:	b9 10 00 00 00       	mov    $0x10,%ecx
  80069f:	e9 74 ff ff ff       	jmp    800618 <vprintfmt+0x29c>
			putch(ch, putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	57                   	push   %edi
  8006a8:	6a 25                	push   $0x25
  8006aa:	ff d6                	call   *%esi
			break;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 81                	jmp    800632 <vprintfmt+0x2b6>
			putch('%', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	57                   	push   %edi
  8006b5:	6a 25                	push   $0x25
  8006b7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	89 d8                	mov    %ebx,%eax
  8006be:	eb 03                	jmp    8006c3 <vprintfmt+0x347>
  8006c0:	83 e8 01             	sub    $0x1,%eax
  8006c3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c7:	75 f7                	jne    8006c0 <vprintfmt+0x344>
  8006c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cc:	e9 61 ff ff ff       	jmp    800632 <vprintfmt+0x2b6>
}
  8006d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d4:	5b                   	pop    %ebx
  8006d5:	5e                   	pop    %esi
  8006d6:	5f                   	pop    %edi
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 18             	sub    $0x18,%esp
  8006df:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ec:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	74 26                	je     800720 <vsnprintf+0x47>
  8006fa:	85 d2                	test   %edx,%edx
  8006fc:	7e 22                	jle    800720 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fe:	ff 75 14             	pushl  0x14(%ebp)
  800701:	ff 75 10             	pushl  0x10(%ebp)
  800704:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800707:	50                   	push   %eax
  800708:	68 42 03 80 00       	push   $0x800342
  80070d:	e8 6a fc ff ff       	call   80037c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800712:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800715:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800718:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071b:	83 c4 10             	add    $0x10,%esp
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    
		return -E_INVAL;
  800720:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800725:	eb f7                	jmp    80071e <vsnprintf+0x45>

00800727 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800730:	50                   	push   %eax
  800731:	ff 75 10             	pushl  0x10(%ebp)
  800734:	ff 75 0c             	pushl  0xc(%ebp)
  800737:	ff 75 08             	pushl  0x8(%ebp)
  80073a:	e8 9a ff ff ff       	call   8006d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 03                	jmp    800751 <strlen+0x10>
		n++;
  80074e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800751:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800755:	75 f7                	jne    80074e <strlen+0xd>
	return n;
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800762:	b8 00 00 00 00       	mov    $0x0,%eax
  800767:	eb 03                	jmp    80076c <strnlen+0x13>
		n++;
  800769:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076c:	39 d0                	cmp    %edx,%eax
  80076e:	74 06                	je     800776 <strnlen+0x1d>
  800770:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800774:	75 f3                	jne    800769 <strnlen+0x10>
	return n;
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c1 01             	add    $0x1,%ecx
  800787:	83 c2 01             	add    $0x1,%edx
  80078a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800791:	84 db                	test   %bl,%bl
  800793:	75 ef                	jne    800784 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800795:	5b                   	pop    %ebx
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079f:	53                   	push   %ebx
  8007a0:	e8 9c ff ff ff       	call   800741 <strlen>
  8007a5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a8:	ff 75 0c             	pushl  0xc(%ebp)
  8007ab:	01 d8                	add    %ebx,%eax
  8007ad:	50                   	push   %eax
  8007ae:	e8 c5 ff ff ff       	call   800778 <strcpy>
	return dst;
}
  8007b3:	89 d8                	mov    %ebx,%eax
  8007b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	56                   	push   %esi
  8007be:	53                   	push   %ebx
  8007bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c5:	89 f3                	mov    %esi,%ebx
  8007c7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ca:	89 f2                	mov    %esi,%edx
  8007cc:	eb 0f                	jmp    8007dd <strncpy+0x23>
		*dst++ = *src;
  8007ce:	83 c2 01             	add    $0x1,%edx
  8007d1:	0f b6 01             	movzbl (%ecx),%eax
  8007d4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007da:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007dd:	39 da                	cmp    %ebx,%edx
  8007df:	75 ed                	jne    8007ce <strncpy+0x14>
	}
	return ret;
}
  8007e1:	89 f0                	mov    %esi,%eax
  8007e3:	5b                   	pop    %ebx
  8007e4:	5e                   	pop    %esi
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	56                   	push   %esi
  8007eb:	53                   	push   %ebx
  8007ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007f5:	89 f0                	mov    %esi,%eax
  8007f7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fb:	85 c9                	test   %ecx,%ecx
  8007fd:	75 0b                	jne    80080a <strlcpy+0x23>
  8007ff:	eb 17                	jmp    800818 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	83 c0 01             	add    $0x1,%eax
  800807:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80080a:	39 d8                	cmp    %ebx,%eax
  80080c:	74 07                	je     800815 <strlcpy+0x2e>
  80080e:	0f b6 0a             	movzbl (%edx),%ecx
  800811:	84 c9                	test   %cl,%cl
  800813:	75 ec                	jne    800801 <strlcpy+0x1a>
		*dst = '\0';
  800815:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800818:	29 f0                	sub    %esi,%eax
}
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800827:	eb 06                	jmp    80082f <strcmp+0x11>
		p++, q++;
  800829:	83 c1 01             	add    $0x1,%ecx
  80082c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80082f:	0f b6 01             	movzbl (%ecx),%eax
  800832:	84 c0                	test   %al,%al
  800834:	74 04                	je     80083a <strcmp+0x1c>
  800836:	3a 02                	cmp    (%edx),%al
  800838:	74 ef                	je     800829 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083a:	0f b6 c0             	movzbl %al,%eax
  80083d:	0f b6 12             	movzbl (%edx),%edx
  800840:	29 d0                	sub    %edx,%eax
}
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	53                   	push   %ebx
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	89 c3                	mov    %eax,%ebx
  800850:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800853:	eb 06                	jmp    80085b <strncmp+0x17>
		n--, p++, q++;
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80085b:	39 d8                	cmp    %ebx,%eax
  80085d:	74 16                	je     800875 <strncmp+0x31>
  80085f:	0f b6 08             	movzbl (%eax),%ecx
  800862:	84 c9                	test   %cl,%cl
  800864:	74 04                	je     80086a <strncmp+0x26>
  800866:	3a 0a                	cmp    (%edx),%cl
  800868:	74 eb                	je     800855 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086a:	0f b6 00             	movzbl (%eax),%eax
  80086d:	0f b6 12             	movzbl (%edx),%edx
  800870:	29 d0                	sub    %edx,%eax
}
  800872:	5b                   	pop    %ebx
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    
		return 0;
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
  80087a:	eb f6                	jmp    800872 <strncmp+0x2e>

0080087c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800886:	0f b6 10             	movzbl (%eax),%edx
  800889:	84 d2                	test   %dl,%dl
  80088b:	74 09                	je     800896 <strchr+0x1a>
		if (*s == c)
  80088d:	38 ca                	cmp    %cl,%dl
  80088f:	74 0a                	je     80089b <strchr+0x1f>
	for (; *s; s++)
  800891:	83 c0 01             	add    $0x1,%eax
  800894:	eb f0                	jmp    800886 <strchr+0xa>
			return (char *) s;
	return 0;
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a7:	eb 03                	jmp    8008ac <strfind+0xf>
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008af:	38 ca                	cmp    %cl,%dl
  8008b1:	74 04                	je     8008b7 <strfind+0x1a>
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	75 f2                	jne    8008a9 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	57                   	push   %edi
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	74 12                	je     8008db <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c9:	f6 c2 03             	test   $0x3,%dl
  8008cc:	75 05                	jne    8008d3 <memset+0x1a>
  8008ce:	f6 c1 03             	test   $0x3,%cl
  8008d1:	74 0f                	je     8008e2 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d3:	89 d7                	mov    %edx,%edi
  8008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d8:	fc                   	cld    
  8008d9:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008db:	89 d0                	mov    %edx,%eax
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5f                   	pop    %edi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    
		c &= 0xFF;
  8008e2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e6:	89 d8                	mov    %ebx,%eax
  8008e8:	c1 e0 08             	shl    $0x8,%eax
  8008eb:	89 df                	mov    %ebx,%edi
  8008ed:	c1 e7 18             	shl    $0x18,%edi
  8008f0:	89 de                	mov    %ebx,%esi
  8008f2:	c1 e6 10             	shl    $0x10,%esi
  8008f5:	09 f7                	or     %esi,%edi
  8008f7:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  8008f9:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008fe:	89 d7                	mov    %edx,%edi
  800900:	fc                   	cld    
  800901:	f3 ab                	rep stos %eax,%es:(%edi)
  800903:	eb d6                	jmp    8008db <memset+0x22>

00800905 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800913:	39 c6                	cmp    %eax,%esi
  800915:	73 35                	jae    80094c <memmove+0x47>
  800917:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091a:	39 c2                	cmp    %eax,%edx
  80091c:	76 2e                	jbe    80094c <memmove+0x47>
		s += n;
		d += n;
  80091e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800921:	89 d6                	mov    %edx,%esi
  800923:	09 fe                	or     %edi,%esi
  800925:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092b:	74 0c                	je     800939 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092d:	83 ef 01             	sub    $0x1,%edi
  800930:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800933:	fd                   	std    
  800934:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800936:	fc                   	cld    
  800937:	eb 21                	jmp    80095a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 ef                	jne    80092d <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093e:	83 ef 04             	sub    $0x4,%edi
  800941:	8d 72 fc             	lea    -0x4(%edx),%esi
  800944:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800947:	fd                   	std    
  800948:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094a:	eb ea                	jmp    800936 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	89 f2                	mov    %esi,%edx
  80094e:	09 c2                	or     %eax,%edx
  800950:	f6 c2 03             	test   $0x3,%dl
  800953:	74 09                	je     80095e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800955:	89 c7                	mov    %eax,%edi
  800957:	fc                   	cld    
  800958:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095a:	5e                   	pop    %esi
  80095b:	5f                   	pop    %edi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095e:	f6 c1 03             	test   $0x3,%cl
  800961:	75 f2                	jne    800955 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800963:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800966:	89 c7                	mov    %eax,%edi
  800968:	fc                   	cld    
  800969:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096b:	eb ed                	jmp    80095a <memmove+0x55>

0080096d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800970:	ff 75 10             	pushl  0x10(%ebp)
  800973:	ff 75 0c             	pushl  0xc(%ebp)
  800976:	ff 75 08             	pushl  0x8(%ebp)
  800979:	e8 87 ff ff ff       	call   800905 <memmove>
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098b:	89 c6                	mov    %eax,%esi
  80098d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	39 f0                	cmp    %esi,%eax
  800992:	74 1c                	je     8009b0 <memcmp+0x30>
		if (*s1 != *s2)
  800994:	0f b6 08             	movzbl (%eax),%ecx
  800997:	0f b6 1a             	movzbl (%edx),%ebx
  80099a:	38 d9                	cmp    %bl,%cl
  80099c:	75 08                	jne    8009a6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80099e:	83 c0 01             	add    $0x1,%eax
  8009a1:	83 c2 01             	add    $0x1,%edx
  8009a4:	eb ea                	jmp    800990 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009a6:	0f b6 c1             	movzbl %cl,%eax
  8009a9:	0f b6 db             	movzbl %bl,%ebx
  8009ac:	29 d8                	sub    %ebx,%eax
  8009ae:	eb 05                	jmp    8009b5 <memcmp+0x35>
	}

	return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c2:	89 c2                	mov    %eax,%edx
  8009c4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c7:	39 d0                	cmp    %edx,%eax
  8009c9:	73 09                	jae    8009d4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	38 08                	cmp    %cl,(%eax)
  8009cd:	74 05                	je     8009d4 <memfind+0x1b>
	for (; s < ends; s++)
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	eb f3                	jmp    8009c7 <memfind+0xe>
			break;
	return (void *) s;
}
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	57                   	push   %edi
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e2:	eb 03                	jmp    8009e7 <strtol+0x11>
		s++;
  8009e4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009e7:	0f b6 01             	movzbl (%ecx),%eax
  8009ea:	3c 20                	cmp    $0x20,%al
  8009ec:	74 f6                	je     8009e4 <strtol+0xe>
  8009ee:	3c 09                	cmp    $0x9,%al
  8009f0:	74 f2                	je     8009e4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009f2:	3c 2b                	cmp    $0x2b,%al
  8009f4:	74 2e                	je     800a24 <strtol+0x4e>
	int neg = 0;
  8009f6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009fb:	3c 2d                	cmp    $0x2d,%al
  8009fd:	74 2f                	je     800a2e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a05:	75 05                	jne    800a0c <strtol+0x36>
  800a07:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0a:	74 2c                	je     800a38 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0c:	85 db                	test   %ebx,%ebx
  800a0e:	75 0a                	jne    800a1a <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a10:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a15:	80 39 30             	cmpb   $0x30,(%ecx)
  800a18:	74 28                	je     800a42 <strtol+0x6c>
		base = 10;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a22:	eb 50                	jmp    800a74 <strtol+0x9e>
		s++;
  800a24:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a27:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2c:	eb d1                	jmp    8009ff <strtol+0x29>
		s++, neg = 1;
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	bf 01 00 00 00       	mov    $0x1,%edi
  800a36:	eb c7                	jmp    8009ff <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a38:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3c:	74 0e                	je     800a4c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a3e:	85 db                	test   %ebx,%ebx
  800a40:	75 d8                	jne    800a1a <strtol+0x44>
		s++, base = 8;
  800a42:	83 c1 01             	add    $0x1,%ecx
  800a45:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a4a:	eb ce                	jmp    800a1a <strtol+0x44>
		s += 2, base = 16;
  800a4c:	83 c1 02             	add    $0x2,%ecx
  800a4f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a54:	eb c4                	jmp    800a1a <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a56:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a59:	89 f3                	mov    %esi,%ebx
  800a5b:	80 fb 19             	cmp    $0x19,%bl
  800a5e:	77 29                	ja     800a89 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a60:	0f be d2             	movsbl %dl,%edx
  800a63:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a66:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a69:	7d 30                	jge    800a9b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a6b:	83 c1 01             	add    $0x1,%ecx
  800a6e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a72:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a74:	0f b6 11             	movzbl (%ecx),%edx
  800a77:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7a:	89 f3                	mov    %esi,%ebx
  800a7c:	80 fb 09             	cmp    $0x9,%bl
  800a7f:	77 d5                	ja     800a56 <strtol+0x80>
			dig = *s - '0';
  800a81:	0f be d2             	movsbl %dl,%edx
  800a84:	83 ea 30             	sub    $0x30,%edx
  800a87:	eb dd                	jmp    800a66 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a89:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 19             	cmp    $0x19,%bl
  800a91:	77 08                	ja     800a9b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a93:	0f be d2             	movsbl %dl,%edx
  800a96:	83 ea 37             	sub    $0x37,%edx
  800a99:	eb cb                	jmp    800a66 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9f:	74 05                	je     800aa6 <strtol+0xd0>
		*endptr = (char *) s;
  800aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aa6:	89 c2                	mov    %eax,%edx
  800aa8:	f7 da                	neg    %edx
  800aaa:	85 ff                	test   %edi,%edi
  800aac:	0f 45 c2             	cmovne %edx,%eax
}
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	83 ec 1c             	sub    $0x1c,%esp
  800abd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ac0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ac3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800acb:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ace:	8b 75 14             	mov    0x14(%ebp),%esi
  800ad1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ad7:	74 04                	je     800add <syscall+0x29>
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	7f 08                	jg     800ae5 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800add:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    
  800ae5:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae8:	83 ec 0c             	sub    $0xc,%esp
  800aeb:	50                   	push   %eax
  800aec:	52                   	push   %edx
  800aed:	68 44 12 80 00       	push   $0x801244
  800af2:	6a 23                	push   $0x23
  800af4:	68 61 12 80 00       	push   $0x801261
  800af9:	e8 3a f6 ff ff       	call   800138 <_panic>

00800afe <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b04:	6a 00                	push   $0x0
  800b06:	6a 00                	push   $0x0
  800b08:	6a 00                	push   $0x0
  800b0a:	ff 75 0c             	pushl  0xc(%ebp)
  800b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1a:	e8 95 ff ff ff       	call   800ab4 <syscall>
}
  800b1f:	83 c4 10             	add    $0x10,%esp
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b2a:	6a 00                	push   $0x0
  800b2c:	6a 00                	push   $0x0
  800b2e:	6a 00                	push   $0x0
  800b30:	6a 00                	push   $0x0
  800b32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b37:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b41:	e8 6e ff ff ff       	call   800ab4 <syscall>
}
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b4e:	6a 00                	push   $0x0
  800b50:	6a 00                	push   $0x0
  800b52:	6a 00                	push   $0x0
  800b54:	6a 00                	push   $0x0
  800b56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b59:	ba 01 00 00 00       	mov    $0x1,%edx
  800b5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b63:	e8 4c ff ff ff       	call   800ab4 <syscall>
}
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b70:	6a 00                	push   $0x0
  800b72:	6a 00                	push   $0x0
  800b74:	6a 00                	push   $0x0
  800b76:	6a 00                	push   $0x0
  800b78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b82:	b8 02 00 00 00       	mov    $0x2,%eax
  800b87:	e8 28 ff ff ff       	call   800ab4 <syscall>
}
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <sys_yield>:

void
sys_yield(void)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b94:	6a 00                	push   $0x0
  800b96:	6a 00                	push   $0x0
  800b98:	6a 00                	push   $0x0
  800b9a:	6a 00                	push   $0x0
  800b9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bab:	e8 04 ff ff ff       	call   800ab4 <syscall>
}
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	c9                   	leave  
  800bb4:	c3                   	ret    

00800bb5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bbb:	6a 00                	push   $0x0
  800bbd:	6a 00                	push   $0x0
  800bbf:	ff 75 10             	pushl  0x10(%ebp)
  800bc2:	ff 75 0c             	pushl  0xc(%ebp)
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bcd:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd2:	e8 dd fe ff ff       	call   800ab4 <syscall>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bdf:	ff 75 18             	pushl  0x18(%ebp)
  800be2:	ff 75 14             	pushl  0x14(%ebp)
  800be5:	ff 75 10             	pushl  0x10(%ebp)
  800be8:	ff 75 0c             	pushl  0xc(%ebp)
  800beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bee:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf3:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf8:	e8 b7 fe ff ff       	call   800ab4 <syscall>
}
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c05:	6a 00                	push   $0x0
  800c07:	6a 00                	push   $0x0
  800c09:	6a 00                	push   $0x0
  800c0b:	ff 75 0c             	pushl  0xc(%ebp)
  800c0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c11:	ba 01 00 00 00       	mov    $0x1,%edx
  800c16:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1b:	e8 94 fe ff ff       	call   800ab4 <syscall>
}
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c28:	6a 00                	push   $0x0
  800c2a:	6a 00                	push   $0x0
  800c2c:	6a 00                	push   $0x0
  800c2e:	ff 75 0c             	pushl  0xc(%ebp)
  800c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c34:	ba 01 00 00 00       	mov    $0x1,%edx
  800c39:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3e:	e8 71 fe ff ff       	call   800ab4 <syscall>
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c4b:	6a 00                	push   $0x0
  800c4d:	6a 00                	push   $0x0
  800c4f:	6a 00                	push   $0x0
  800c51:	ff 75 0c             	pushl  0xc(%ebp)
  800c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c57:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c61:	e8 4e fe ff ff       	call   800ab4 <syscall>
}
  800c66:	c9                   	leave  
  800c67:	c3                   	ret    

00800c68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c6e:	6a 00                	push   $0x0
  800c70:	ff 75 14             	pushl  0x14(%ebp)
  800c73:	ff 75 10             	pushl  0x10(%ebp)
  800c76:	ff 75 0c             	pushl  0xc(%ebp)
  800c79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c81:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c86:	e8 29 fe ff ff       	call   800ab4 <syscall>
}
  800c8b:	c9                   	leave  
  800c8c:	c3                   	ret    

00800c8d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c93:	6a 00                	push   $0x0
  800c95:	6a 00                	push   $0x0
  800c97:	6a 00                	push   $0x0
  800c99:	6a 00                	push   $0x0
  800c9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9e:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca8:	e8 07 fe ff ff       	call   800ab4 <syscall>
}
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    
  800caf:	90                   	nop

00800cb0 <__udivdi3>:
  800cb0:	55                   	push   %ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 1c             	sub    $0x1c,%esp
  800cb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800cbb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cc3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cc7:	85 d2                	test   %edx,%edx
  800cc9:	75 35                	jne    800d00 <__udivdi3+0x50>
  800ccb:	39 f3                	cmp    %esi,%ebx
  800ccd:	0f 87 bd 00 00 00    	ja     800d90 <__udivdi3+0xe0>
  800cd3:	85 db                	test   %ebx,%ebx
  800cd5:	89 d9                	mov    %ebx,%ecx
  800cd7:	75 0b                	jne    800ce4 <__udivdi3+0x34>
  800cd9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cde:	31 d2                	xor    %edx,%edx
  800ce0:	f7 f3                	div    %ebx
  800ce2:	89 c1                	mov    %eax,%ecx
  800ce4:	31 d2                	xor    %edx,%edx
  800ce6:	89 f0                	mov    %esi,%eax
  800ce8:	f7 f1                	div    %ecx
  800cea:	89 c6                	mov    %eax,%esi
  800cec:	89 e8                	mov    %ebp,%eax
  800cee:	89 f7                	mov    %esi,%edi
  800cf0:	f7 f1                	div    %ecx
  800cf2:	89 fa                	mov    %edi,%edx
  800cf4:	83 c4 1c             	add    $0x1c,%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
  800cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d00:	39 f2                	cmp    %esi,%edx
  800d02:	77 7c                	ja     800d80 <__udivdi3+0xd0>
  800d04:	0f bd fa             	bsr    %edx,%edi
  800d07:	83 f7 1f             	xor    $0x1f,%edi
  800d0a:	0f 84 98 00 00 00    	je     800da8 <__udivdi3+0xf8>
  800d10:	89 f9                	mov    %edi,%ecx
  800d12:	b8 20 00 00 00       	mov    $0x20,%eax
  800d17:	29 f8                	sub    %edi,%eax
  800d19:	d3 e2                	shl    %cl,%edx
  800d1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d1f:	89 c1                	mov    %eax,%ecx
  800d21:	89 da                	mov    %ebx,%edx
  800d23:	d3 ea                	shr    %cl,%edx
  800d25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d29:	09 d1                	or     %edx,%ecx
  800d2b:	89 f2                	mov    %esi,%edx
  800d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d31:	89 f9                	mov    %edi,%ecx
  800d33:	d3 e3                	shl    %cl,%ebx
  800d35:	89 c1                	mov    %eax,%ecx
  800d37:	d3 ea                	shr    %cl,%edx
  800d39:	89 f9                	mov    %edi,%ecx
  800d3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d3f:	d3 e6                	shl    %cl,%esi
  800d41:	89 eb                	mov    %ebp,%ebx
  800d43:	89 c1                	mov    %eax,%ecx
  800d45:	d3 eb                	shr    %cl,%ebx
  800d47:	09 de                	or     %ebx,%esi
  800d49:	89 f0                	mov    %esi,%eax
  800d4b:	f7 74 24 08          	divl   0x8(%esp)
  800d4f:	89 d6                	mov    %edx,%esi
  800d51:	89 c3                	mov    %eax,%ebx
  800d53:	f7 64 24 0c          	mull   0xc(%esp)
  800d57:	39 d6                	cmp    %edx,%esi
  800d59:	72 0c                	jb     800d67 <__udivdi3+0xb7>
  800d5b:	89 f9                	mov    %edi,%ecx
  800d5d:	d3 e5                	shl    %cl,%ebp
  800d5f:	39 c5                	cmp    %eax,%ebp
  800d61:	73 5d                	jae    800dc0 <__udivdi3+0x110>
  800d63:	39 d6                	cmp    %edx,%esi
  800d65:	75 59                	jne    800dc0 <__udivdi3+0x110>
  800d67:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d6a:	31 ff                	xor    %edi,%edi
  800d6c:	89 fa                	mov    %edi,%edx
  800d6e:	83 c4 1c             	add    $0x1c,%esp
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    
  800d76:	8d 76 00             	lea    0x0(%esi),%esi
  800d79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d80:	31 ff                	xor    %edi,%edi
  800d82:	31 c0                	xor    %eax,%eax
  800d84:	89 fa                	mov    %edi,%edx
  800d86:	83 c4 1c             	add    $0x1c,%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    
  800d8e:	66 90                	xchg   %ax,%ax
  800d90:	31 ff                	xor    %edi,%edi
  800d92:	89 e8                	mov    %ebp,%eax
  800d94:	89 f2                	mov    %esi,%edx
  800d96:	f7 f3                	div    %ebx
  800d98:	89 fa                	mov    %edi,%edx
  800d9a:	83 c4 1c             	add    $0x1c,%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    
  800da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800da8:	39 f2                	cmp    %esi,%edx
  800daa:	72 06                	jb     800db2 <__udivdi3+0x102>
  800dac:	31 c0                	xor    %eax,%eax
  800dae:	39 eb                	cmp    %ebp,%ebx
  800db0:	77 d2                	ja     800d84 <__udivdi3+0xd4>
  800db2:	b8 01 00 00 00       	mov    $0x1,%eax
  800db7:	eb cb                	jmp    800d84 <__udivdi3+0xd4>
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	89 d8                	mov    %ebx,%eax
  800dc2:	31 ff                	xor    %edi,%edi
  800dc4:	eb be                	jmp    800d84 <__udivdi3+0xd4>
  800dc6:	66 90                	xchg   %ax,%ax
  800dc8:	66 90                	xchg   %ax,%ax
  800dca:	66 90                	xchg   %ax,%ax
  800dcc:	66 90                	xchg   %ax,%ax
  800dce:	66 90                	xchg   %ax,%ax

00800dd0 <__umoddi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 1c             	sub    $0x1c,%esp
  800dd7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ddb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ddf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800de7:	85 ed                	test   %ebp,%ebp
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	89 da                	mov    %ebx,%edx
  800ded:	75 19                	jne    800e08 <__umoddi3+0x38>
  800def:	39 df                	cmp    %ebx,%edi
  800df1:	0f 86 b1 00 00 00    	jbe    800ea8 <__umoddi3+0xd8>
  800df7:	f7 f7                	div    %edi
  800df9:	89 d0                	mov    %edx,%eax
  800dfb:	31 d2                	xor    %edx,%edx
  800dfd:	83 c4 1c             	add    $0x1c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	39 dd                	cmp    %ebx,%ebp
  800e0a:	77 f1                	ja     800dfd <__umoddi3+0x2d>
  800e0c:	0f bd cd             	bsr    %ebp,%ecx
  800e0f:	83 f1 1f             	xor    $0x1f,%ecx
  800e12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e16:	0f 84 b4 00 00 00    	je     800ed0 <__umoddi3+0x100>
  800e1c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e21:	89 c2                	mov    %eax,%edx
  800e23:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e27:	29 c2                	sub    %eax,%edx
  800e29:	89 c1                	mov    %eax,%ecx
  800e2b:	89 f8                	mov    %edi,%eax
  800e2d:	d3 e5                	shl    %cl,%ebp
  800e2f:	89 d1                	mov    %edx,%ecx
  800e31:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e35:	d3 e8                	shr    %cl,%eax
  800e37:	09 c5                	or     %eax,%ebp
  800e39:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e3d:	89 c1                	mov    %eax,%ecx
  800e3f:	d3 e7                	shl    %cl,%edi
  800e41:	89 d1                	mov    %edx,%ecx
  800e43:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e47:	89 df                	mov    %ebx,%edi
  800e49:	d3 ef                	shr    %cl,%edi
  800e4b:	89 c1                	mov    %eax,%ecx
  800e4d:	89 f0                	mov    %esi,%eax
  800e4f:	d3 e3                	shl    %cl,%ebx
  800e51:	89 d1                	mov    %edx,%ecx
  800e53:	89 fa                	mov    %edi,%edx
  800e55:	d3 e8                	shr    %cl,%eax
  800e57:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e5c:	09 d8                	or     %ebx,%eax
  800e5e:	f7 f5                	div    %ebp
  800e60:	d3 e6                	shl    %cl,%esi
  800e62:	89 d1                	mov    %edx,%ecx
  800e64:	f7 64 24 08          	mull   0x8(%esp)
  800e68:	39 d1                	cmp    %edx,%ecx
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	89 d7                	mov    %edx,%edi
  800e6e:	72 06                	jb     800e76 <__umoddi3+0xa6>
  800e70:	75 0e                	jne    800e80 <__umoddi3+0xb0>
  800e72:	39 c6                	cmp    %eax,%esi
  800e74:	73 0a                	jae    800e80 <__umoddi3+0xb0>
  800e76:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e7a:	19 ea                	sbb    %ebp,%edx
  800e7c:	89 d7                	mov    %edx,%edi
  800e7e:	89 c3                	mov    %eax,%ebx
  800e80:	89 ca                	mov    %ecx,%edx
  800e82:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e87:	29 de                	sub    %ebx,%esi
  800e89:	19 fa                	sbb    %edi,%edx
  800e8b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e8f:	89 d0                	mov    %edx,%eax
  800e91:	d3 e0                	shl    %cl,%eax
  800e93:	89 d9                	mov    %ebx,%ecx
  800e95:	d3 ee                	shr    %cl,%esi
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	09 f0                	or     %esi,%eax
  800e9b:	83 c4 1c             	add    $0x1c,%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    
  800ea3:	90                   	nop
  800ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	85 ff                	test   %edi,%edi
  800eaa:	89 f9                	mov    %edi,%ecx
  800eac:	75 0b                	jne    800eb9 <__umoddi3+0xe9>
  800eae:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	f7 f7                	div    %edi
  800eb7:	89 c1                	mov    %eax,%ecx
  800eb9:	89 d8                	mov    %ebx,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f1                	div    %ecx
  800ebf:	89 f0                	mov    %esi,%eax
  800ec1:	f7 f1                	div    %ecx
  800ec3:	e9 31 ff ff ff       	jmp    800df9 <__umoddi3+0x29>
  800ec8:	90                   	nop
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	39 dd                	cmp    %ebx,%ebp
  800ed2:	72 08                	jb     800edc <__umoddi3+0x10c>
  800ed4:	39 f7                	cmp    %esi,%edi
  800ed6:	0f 87 21 ff ff ff    	ja     800dfd <__umoddi3+0x2d>
  800edc:	89 da                	mov    %ebx,%edx
  800ede:	89 f0                	mov    %esi,%eax
  800ee0:	29 f8                	sub    %edi,%eax
  800ee2:	19 ea                	sbb    %ebp,%edx
  800ee4:	e9 14 ff ff ff       	jmp    800dfd <__umoddi3+0x2d>
