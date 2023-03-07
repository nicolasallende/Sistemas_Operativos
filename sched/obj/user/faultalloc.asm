
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 60 0f 80 00       	push   $0x800f60
  800045:	e8 b7 01 00 00       	call   800201 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 45 0b 00 00       	call   800ba3 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 ac 0f 80 00       	push   $0x800fac
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 a2 06 00 00       	call   800715 <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 80 0f 80 00       	push   $0x800f80
  800085:	6a 0e                	push   $0xe
  800087:	68 6a 0f 80 00       	push   $0x800f6a
  80008c:	e8 95 00 00 00       	call   800126 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 fc 0b 00 00       	call   800c9d <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 7c 0f 80 00       	push   $0x800f7c
  8000ae:	e8 4e 01 00 00       	call   800201 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 7c 0f 80 00       	push   $0x800f7c
  8000c0:	e8 3c 01 00 00       	call   800201 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000d5:	e8 7e 0a 00 00       	call   800b58 <sys_getenvid>
	if (id >= 0)
  8000da:	85 c0                	test   %eax,%eax
  8000dc:	78 12                	js     8000f0 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8000de:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e3:	c1 e0 07             	shl    $0x7,%eax
  8000e6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000eb:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f0:	85 db                	test   %ebx,%ebx
  8000f2:	7e 07                	jle    8000fb <libmain+0x31>
		binaryname = argv[0];
  8000f4:	8b 06                	mov    (%esi),%eax
  8000f6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fb:	83 ec 08             	sub    $0x8,%esp
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	e8 8c ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800105:	e8 0a 00 00 00       	call   800114 <exit>
}
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800110:	5b                   	pop    %ebx
  800111:	5e                   	pop    %esi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80011a:	6a 00                	push   $0x0
  80011c:	e8 15 0a 00 00       	call   800b36 <sys_env_destroy>
}
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	c9                   	leave  
  800125:	c3                   	ret    

00800126 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800134:	e8 1f 0a 00 00       	call   800b58 <sys_getenvid>
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	ff 75 0c             	pushl  0xc(%ebp)
  80013f:	ff 75 08             	pushl  0x8(%ebp)
  800142:	56                   	push   %esi
  800143:	50                   	push   %eax
  800144:	68 d8 0f 80 00       	push   $0x800fd8
  800149:	e8 b3 00 00 00       	call   800201 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014e:	83 c4 18             	add    $0x18,%esp
  800151:	53                   	push   %ebx
  800152:	ff 75 10             	pushl  0x10(%ebp)
  800155:	e8 56 00 00 00       	call   8001b0 <vcprintf>
	cprintf("\n");
  80015a:	c7 04 24 7e 0f 80 00 	movl   $0x800f7e,(%esp)
  800161:	e8 9b 00 00 00       	call   800201 <cprintf>
  800166:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800169:	cc                   	int3   
  80016a:	eb fd                	jmp    800169 <_panic+0x43>

0080016c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	53                   	push   %ebx
  800170:	83 ec 04             	sub    $0x4,%esp
  800173:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800176:	8b 13                	mov    (%ebx),%edx
  800178:	8d 42 01             	lea    0x1(%edx),%eax
  80017b:	89 03                	mov    %eax,(%ebx)
  80017d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800180:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800184:	3d ff 00 00 00       	cmp    $0xff,%eax
  800189:	74 09                	je     800194 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80018b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800192:	c9                   	leave  
  800193:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800194:	83 ec 08             	sub    $0x8,%esp
  800197:	68 ff 00 00 00       	push   $0xff
  80019c:	8d 43 08             	lea    0x8(%ebx),%eax
  80019f:	50                   	push   %eax
  8001a0:	e8 47 09 00 00       	call   800aec <sys_cputs>
		b->idx = 0;
  8001a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ab:	83 c4 10             	add    $0x10,%esp
  8001ae:	eb db                	jmp    80018b <putch+0x1f>

008001b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c0:	00 00 00 
	b.cnt = 0;
  8001c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cd:	ff 75 0c             	pushl  0xc(%ebp)
  8001d0:	ff 75 08             	pushl  0x8(%ebp)
  8001d3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d9:	50                   	push   %eax
  8001da:	68 6c 01 80 00       	push   $0x80016c
  8001df:	e8 86 01 00 00       	call   80036a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e4:	83 c4 08             	add    $0x8,%esp
  8001e7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f3:	50                   	push   %eax
  8001f4:	e8 f3 08 00 00       	call   800aec <sys_cputs>

	return b.cnt;
}
  8001f9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    

00800201 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800207:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020a:	50                   	push   %eax
  80020b:	ff 75 08             	pushl  0x8(%ebp)
  80020e:	e8 9d ff ff ff       	call   8001b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 1c             	sub    $0x1c,%esp
  80021e:	89 c7                	mov    %eax,%edi
  800220:	89 d6                	mov    %edx,%esi
  800222:	8b 45 08             	mov    0x8(%ebp),%eax
  800225:	8b 55 0c             	mov    0xc(%ebp),%edx
  800228:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800231:	bb 00 00 00 00       	mov    $0x0,%ebx
  800236:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800239:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023c:	39 d3                	cmp    %edx,%ebx
  80023e:	72 05                	jb     800245 <printnum+0x30>
  800240:	39 45 10             	cmp    %eax,0x10(%ebp)
  800243:	77 7a                	ja     8002bf <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	ff 75 18             	pushl  0x18(%ebp)
  80024b:	8b 45 14             	mov    0x14(%ebp),%eax
  80024e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800251:	53                   	push   %ebx
  800252:	ff 75 10             	pushl  0x10(%ebp)
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025b:	ff 75 e0             	pushl  -0x20(%ebp)
  80025e:	ff 75 dc             	pushl  -0x24(%ebp)
  800261:	ff 75 d8             	pushl  -0x28(%ebp)
  800264:	e8 a7 0a 00 00       	call   800d10 <__udivdi3>
  800269:	83 c4 18             	add    $0x18,%esp
  80026c:	52                   	push   %edx
  80026d:	50                   	push   %eax
  80026e:	89 f2                	mov    %esi,%edx
  800270:	89 f8                	mov    %edi,%eax
  800272:	e8 9e ff ff ff       	call   800215 <printnum>
  800277:	83 c4 20             	add    $0x20,%esp
  80027a:	eb 13                	jmp    80028f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	56                   	push   %esi
  800280:	ff 75 18             	pushl  0x18(%ebp)
  800283:	ff d7                	call   *%edi
  800285:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800288:	83 eb 01             	sub    $0x1,%ebx
  80028b:	85 db                	test   %ebx,%ebx
  80028d:	7f ed                	jg     80027c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	83 ec 04             	sub    $0x4,%esp
  800296:	ff 75 e4             	pushl  -0x1c(%ebp)
  800299:	ff 75 e0             	pushl  -0x20(%ebp)
  80029c:	ff 75 dc             	pushl  -0x24(%ebp)
  80029f:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a2:	e8 89 0b 00 00       	call   800e30 <__umoddi3>
  8002a7:	83 c4 14             	add    $0x14,%esp
  8002aa:	0f be 80 fc 0f 80 00 	movsbl 0x800ffc(%eax),%eax
  8002b1:	50                   	push   %eax
  8002b2:	ff d7                	call   *%edi
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5e                   	pop    %esi
  8002bc:	5f                   	pop    %edi
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    
  8002bf:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c2:	eb c4                	jmp    800288 <printnum+0x73>

008002c4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c7:	83 fa 01             	cmp    $0x1,%edx
  8002ca:	7e 0e                	jle    8002da <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    
	else if (lflag)
  8002da:	85 d2                	test   %edx,%edx
  8002dc:	75 10                	jne    8002ee <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ec:	eb ea                	jmp    8002d8 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fc:	eb da                	jmp    8002d8 <getuint+0x14>

008002fe <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800301:	83 fa 01             	cmp    $0x1,%edx
  800304:	7e 0e                	jle    800314 <getint+0x16>
		return va_arg(*ap, long long);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    
	else if (lflag)
  800314:	85 d2                	test   %edx,%edx
  800316:	75 0c                	jne    800324 <getint+0x26>
		return va_arg(*ap, int);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	99                   	cltd   
  800322:	eb ee                	jmp    800312 <getint+0x14>
		return va_arg(*ap, long);
  800324:	8b 10                	mov    (%eax),%edx
  800326:	8d 4a 04             	lea    0x4(%edx),%ecx
  800329:	89 08                	mov    %ecx,(%eax)
  80032b:	8b 02                	mov    (%edx),%eax
  80032d:	99                   	cltd   
  80032e:	eb e2                	jmp    800312 <getint+0x14>

00800330 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800336:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	3b 50 04             	cmp    0x4(%eax),%edx
  80033f:	73 0a                	jae    80034b <sprintputch+0x1b>
		*b->buf++ = ch;
  800341:	8d 4a 01             	lea    0x1(%edx),%ecx
  800344:	89 08                	mov    %ecx,(%eax)
  800346:	8b 45 08             	mov    0x8(%ebp),%eax
  800349:	88 02                	mov    %al,(%edx)
}
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <printfmt>:
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800353:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800356:	50                   	push   %eax
  800357:	ff 75 10             	pushl  0x10(%ebp)
  80035a:	ff 75 0c             	pushl  0xc(%ebp)
  80035d:	ff 75 08             	pushl  0x8(%ebp)
  800360:	e8 05 00 00 00       	call   80036a <vprintfmt>
}
  800365:	83 c4 10             	add    $0x10,%esp
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <vprintfmt>:
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 2c             	sub    $0x2c,%esp
  800373:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800376:	8b 75 0c             	mov    0xc(%ebp),%esi
  800379:	89 f7                	mov    %esi,%edi
  80037b:	89 de                	mov    %ebx,%esi
  80037d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800380:	e9 9e 02 00 00       	jmp    800623 <vprintfmt+0x2b9>
		padc = ' ';
  800385:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800389:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800390:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800397:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80039e:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a9:	0f b6 0b             	movzbl (%ebx),%ecx
  8003ac:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8003af:	3c 55                	cmp    $0x55,%al
  8003b1:	0f 87 e8 02 00 00    	ja     80069f <vprintfmt+0x335>
  8003b7:	0f b6 c0             	movzbl %al,%eax
  8003ba:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8003c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  8003c4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003c8:	eb d9                	jmp    8003a3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  8003cd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d1:	eb d0                	jmp    8003a3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	0f b6 c9             	movzbl %cl,%ecx
  8003d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  8003d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003e1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e8:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8003eb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ee:	83 fa 09             	cmp    $0x9,%edx
  8003f1:	77 52                	ja     800445 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  8003f3:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8003f6:	eb e9                	jmp    8003e1 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800401:	8b 00                	mov    (%eax),%eax
  800403:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800409:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040d:	79 94                	jns    8003a3 <vprintfmt+0x39>
				width = precision, precision = -1;
  80040f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800412:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800415:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041c:	eb 85                	jmp    8003a3 <vprintfmt+0x39>
  80041e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800421:	85 c0                	test   %eax,%eax
  800423:	b9 00 00 00 00       	mov    $0x0,%ecx
  800428:	0f 49 c8             	cmovns %eax,%ecx
  80042b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800431:	e9 6d ff ff ff       	jmp    8003a3 <vprintfmt+0x39>
  800436:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800439:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800440:	e9 5e ff ff ff       	jmp    8003a3 <vprintfmt+0x39>
  800445:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800448:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80044b:	eb bc                	jmp    800409 <vprintfmt+0x9f>
			lflag++;
  80044d:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800453:	e9 4b ff ff ff       	jmp    8003a3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8d 50 04             	lea    0x4(%eax),%edx
  80045e:	89 55 14             	mov    %edx,0x14(%ebp)
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	57                   	push   %edi
  800465:	ff 30                	pushl  (%eax)
  800467:	ff d6                	call   *%esi
			break;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	e9 af 01 00 00       	jmp    800620 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 50 04             	lea    0x4(%eax),%edx
  800477:	89 55 14             	mov    %edx,0x14(%ebp)
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	99                   	cltd   
  80047d:	31 d0                	xor    %edx,%eax
  80047f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800481:	83 f8 08             	cmp    $0x8,%eax
  800484:	7f 20                	jg     8004a6 <vprintfmt+0x13c>
  800486:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80048d:	85 d2                	test   %edx,%edx
  80048f:	74 15                	je     8004a6 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800491:	52                   	push   %edx
  800492:	68 1d 10 80 00       	push   $0x80101d
  800497:	57                   	push   %edi
  800498:	56                   	push   %esi
  800499:	e8 af fe ff ff       	call   80034d <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	e9 7a 01 00 00       	jmp    800620 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8004a6:	50                   	push   %eax
  8004a7:	68 14 10 80 00       	push   $0x801014
  8004ac:	57                   	push   %edi
  8004ad:	56                   	push   %esi
  8004ae:	e8 9a fe ff ff       	call   80034d <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	e9 65 01 00 00       	jmp    800620 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 50 04             	lea    0x4(%eax),%edx
  8004c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c4:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  8004c6:	85 db                	test   %ebx,%ebx
  8004c8:	b8 0d 10 80 00       	mov    $0x80100d,%eax
  8004cd:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  8004d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d4:	0f 8e bd 00 00 00    	jle    800597 <vprintfmt+0x22d>
  8004da:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004de:	75 0e                	jne    8004ee <vprintfmt+0x184>
  8004e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e6:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004e9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004ec:	eb 6d                	jmp    80055b <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004f4:	53                   	push   %ebx
  8004f5:	e8 4d 02 00 00       	call   800747 <strnlen>
  8004fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fd:	29 c1                	sub    %eax,%ecx
  8004ff:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800502:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800505:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800509:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80050f:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	eb 0f                	jmp    800522 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	57                   	push   %edi
  800517:	ff 75 e0             	pushl  -0x20(%ebp)
  80051a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80051c:	83 eb 01             	sub    $0x1,%ebx
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	85 db                	test   %ebx,%ebx
  800524:	7f ed                	jg     800513 <vprintfmt+0x1a9>
  800526:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800529:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80052c:	85 c9                	test   %ecx,%ecx
  80052e:	b8 00 00 00 00       	mov    $0x0,%eax
  800533:	0f 49 c1             	cmovns %ecx,%eax
  800536:	29 c1                	sub    %eax,%ecx
  800538:	89 75 08             	mov    %esi,0x8(%ebp)
  80053b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053e:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800541:	89 cf                	mov    %ecx,%edi
  800543:	eb 16                	jmp    80055b <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800545:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800549:	75 31                	jne    80057c <vprintfmt+0x212>
					putch(ch, putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	ff 75 0c             	pushl  0xc(%ebp)
  800551:	50                   	push   %eax
  800552:	ff 55 08             	call   *0x8(%ebp)
  800555:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800558:	83 ef 01             	sub    $0x1,%edi
  80055b:	83 c3 01             	add    $0x1,%ebx
  80055e:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  800562:	0f be c2             	movsbl %dl,%eax
  800565:	85 c0                	test   %eax,%eax
  800567:	74 50                	je     8005b9 <vprintfmt+0x24f>
  800569:	85 f6                	test   %esi,%esi
  80056b:	78 d8                	js     800545 <vprintfmt+0x1db>
  80056d:	83 ee 01             	sub    $0x1,%esi
  800570:	79 d3                	jns    800545 <vprintfmt+0x1db>
  800572:	89 fb                	mov    %edi,%ebx
  800574:	8b 75 08             	mov    0x8(%ebp),%esi
  800577:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80057a:	eb 37                	jmp    8005b3 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  80057c:	0f be d2             	movsbl %dl,%edx
  80057f:	83 ea 20             	sub    $0x20,%edx
  800582:	83 fa 5e             	cmp    $0x5e,%edx
  800585:	76 c4                	jbe    80054b <vprintfmt+0x1e1>
					putch('?', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	ff 75 0c             	pushl  0xc(%ebp)
  80058d:	6a 3f                	push   $0x3f
  80058f:	ff 55 08             	call   *0x8(%ebp)
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	eb c1                	jmp    800558 <vprintfmt+0x1ee>
  800597:	89 75 08             	mov    %esi,0x8(%ebp)
  80059a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059d:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005a0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005a3:	eb b6                	jmp    80055b <vprintfmt+0x1f1>
				putch(' ', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	57                   	push   %edi
  8005a9:	6a 20                	push   $0x20
  8005ab:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005ad:	83 eb 01             	sub    $0x1,%ebx
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7f ee                	jg     8005a5 <vprintfmt+0x23b>
  8005b7:	eb 67                	jmp    800620 <vprintfmt+0x2b6>
  8005b9:	89 fb                	mov    %edi,%ebx
  8005bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005be:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005c1:	eb f0                	jmp    8005b3 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  8005c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c6:	e8 33 fd ff ff       	call   8002fe <getint>
  8005cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	79 2c                	jns    800606 <vprintfmt+0x29c>
				putch('-', putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	57                   	push   %edi
  8005de:	6a 2d                	push   $0x2d
  8005e0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e8:	f7 d8                	neg    %eax
  8005ea:	83 d2 00             	adc    $0x0,%edx
  8005ed:	f7 da                	neg    %edx
  8005ef:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f7:	eb 0d                	jmp    800606 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fc:	e8 c3 fc ff ff       	call   8002c4 <getuint>
			base = 10;
  800601:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 e0             	pushl  -0x20(%ebp)
  800611:	51                   	push   %ecx
  800612:	52                   	push   %edx
  800613:	50                   	push   %eax
  800614:	89 fa                	mov    %edi,%edx
  800616:	89 f0                	mov    %esi,%eax
  800618:	e8 f8 fb ff ff       	call   800215 <printnum>
			break;
  80061d:	83 c4 20             	add    $0x20,%esp
{
  800620:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800623:	83 c3 01             	add    $0x1,%ebx
  800626:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  80062a:	83 f8 25             	cmp    $0x25,%eax
  80062d:	0f 84 52 fd ff ff    	je     800385 <vprintfmt+0x1b>
			if (ch == '\0')
  800633:	85 c0                	test   %eax,%eax
  800635:	0f 84 84 00 00 00    	je     8006bf <vprintfmt+0x355>
			putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	57                   	push   %edi
  80063f:	50                   	push   %eax
  800640:	ff d6                	call   *%esi
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	eb dc                	jmp    800623 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 75 fc ff ff       	call   8002c4 <getuint>
			base = 8;
  80064f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800654:	eb b0                	jmp    800606 <vprintfmt+0x29c>
			putch('0', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	57                   	push   %edi
  80065a:	6a 30                	push   $0x30
  80065c:	ff d6                	call   *%esi
			putch('x', putdat);
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	57                   	push   %edi
  800662:	6a 78                	push   $0x78
  800664:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800676:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800679:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80067e:	eb 86                	jmp    800606 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	e8 3c fc ff ff       	call   8002c4 <getuint>
			base = 16;
  800688:	b9 10 00 00 00       	mov    $0x10,%ecx
  80068d:	e9 74 ff ff ff       	jmp    800606 <vprintfmt+0x29c>
			putch(ch, putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	57                   	push   %edi
  800696:	6a 25                	push   $0x25
  800698:	ff d6                	call   *%esi
			break;
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	eb 81                	jmp    800620 <vprintfmt+0x2b6>
			putch('%', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	57                   	push   %edi
  8006a3:	6a 25                	push   $0x25
  8006a5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	89 d8                	mov    %ebx,%eax
  8006ac:	eb 03                	jmp    8006b1 <vprintfmt+0x347>
  8006ae:	83 e8 01             	sub    $0x1,%eax
  8006b1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b5:	75 f7                	jne    8006ae <vprintfmt+0x344>
  8006b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ba:	e9 61 ff ff ff       	jmp    800620 <vprintfmt+0x2b6>
}
  8006bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c2:	5b                   	pop    %ebx
  8006c3:	5e                   	pop    %esi
  8006c4:	5f                   	pop    %edi
  8006c5:	5d                   	pop    %ebp
  8006c6:	c3                   	ret    

008006c7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c7:	55                   	push   %ebp
  8006c8:	89 e5                	mov    %esp,%ebp
  8006ca:	83 ec 18             	sub    $0x18,%esp
  8006cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 26                	je     80070e <vsnprintf+0x47>
  8006e8:	85 d2                	test   %edx,%edx
  8006ea:	7e 22                	jle    80070e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ec:	ff 75 14             	pushl  0x14(%ebp)
  8006ef:	ff 75 10             	pushl  0x10(%ebp)
  8006f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f5:	50                   	push   %eax
  8006f6:	68 30 03 80 00       	push   $0x800330
  8006fb:	e8 6a fc ff ff       	call   80036a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800700:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800703:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800709:	83 c4 10             	add    $0x10,%esp
}
  80070c:	c9                   	leave  
  80070d:	c3                   	ret    
		return -E_INVAL;
  80070e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800713:	eb f7                	jmp    80070c <vsnprintf+0x45>

00800715 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071e:	50                   	push   %eax
  80071f:	ff 75 10             	pushl  0x10(%ebp)
  800722:	ff 75 0c             	pushl  0xc(%ebp)
  800725:	ff 75 08             	pushl  0x8(%ebp)
  800728:	e8 9a ff ff ff       	call   8006c7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
  80073a:	eb 03                	jmp    80073f <strlen+0x10>
		n++;
  80073c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80073f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800743:	75 f7                	jne    80073c <strlen+0xd>
	return n;
}
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800750:	b8 00 00 00 00       	mov    $0x0,%eax
  800755:	eb 03                	jmp    80075a <strnlen+0x13>
		n++;
  800757:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075a:	39 d0                	cmp    %edx,%eax
  80075c:	74 06                	je     800764 <strnlen+0x1d>
  80075e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800762:	75 f3                	jne    800757 <strnlen+0x10>
	return n;
}
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	53                   	push   %ebx
  80076a:	8b 45 08             	mov    0x8(%ebp),%eax
  80076d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800770:	89 c2                	mov    %eax,%edx
  800772:	83 c1 01             	add    $0x1,%ecx
  800775:	83 c2 01             	add    $0x1,%edx
  800778:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80077c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80077f:	84 db                	test   %bl,%bl
  800781:	75 ef                	jne    800772 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800783:	5b                   	pop    %ebx
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	53                   	push   %ebx
  80078a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078d:	53                   	push   %ebx
  80078e:	e8 9c ff ff ff       	call   80072f <strlen>
  800793:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800796:	ff 75 0c             	pushl  0xc(%ebp)
  800799:	01 d8                	add    %ebx,%eax
  80079b:	50                   	push   %eax
  80079c:	e8 c5 ff ff ff       	call   800766 <strcpy>
	return dst;
}
  8007a1:	89 d8                	mov    %ebx,%eax
  8007a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b3:	89 f3                	mov    %esi,%ebx
  8007b5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b8:	89 f2                	mov    %esi,%edx
  8007ba:	eb 0f                	jmp    8007cb <strncpy+0x23>
		*dst++ = *src;
  8007bc:	83 c2 01             	add    $0x1,%edx
  8007bf:	0f b6 01             	movzbl (%ecx),%eax
  8007c2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c8:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007cb:	39 da                	cmp    %ebx,%edx
  8007cd:	75 ed                	jne    8007bc <strncpy+0x14>
	}
	return ret;
}
  8007cf:	89 f0                	mov    %esi,%eax
  8007d1:	5b                   	pop    %ebx
  8007d2:	5e                   	pop    %esi
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	56                   	push   %esi
  8007d9:	53                   	push   %ebx
  8007da:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007e3:	89 f0                	mov    %esi,%eax
  8007e5:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e9:	85 c9                	test   %ecx,%ecx
  8007eb:	75 0b                	jne    8007f8 <strlcpy+0x23>
  8007ed:	eb 17                	jmp    800806 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ef:	83 c2 01             	add    $0x1,%edx
  8007f2:	83 c0 01             	add    $0x1,%eax
  8007f5:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8007f8:	39 d8                	cmp    %ebx,%eax
  8007fa:	74 07                	je     800803 <strlcpy+0x2e>
  8007fc:	0f b6 0a             	movzbl (%edx),%ecx
  8007ff:	84 c9                	test   %cl,%cl
  800801:	75 ec                	jne    8007ef <strlcpy+0x1a>
		*dst = '\0';
  800803:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800806:	29 f0                	sub    %esi,%eax
}
  800808:	5b                   	pop    %ebx
  800809:	5e                   	pop    %esi
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800815:	eb 06                	jmp    80081d <strcmp+0x11>
		p++, q++;
  800817:	83 c1 01             	add    $0x1,%ecx
  80081a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80081d:	0f b6 01             	movzbl (%ecx),%eax
  800820:	84 c0                	test   %al,%al
  800822:	74 04                	je     800828 <strcmp+0x1c>
  800824:	3a 02                	cmp    (%edx),%al
  800826:	74 ef                	je     800817 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800828:	0f b6 c0             	movzbl %al,%eax
  80082b:	0f b6 12             	movzbl (%edx),%edx
  80082e:	29 d0                	sub    %edx,%eax
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	53                   	push   %ebx
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083c:	89 c3                	mov    %eax,%ebx
  80083e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800841:	eb 06                	jmp    800849 <strncmp+0x17>
		n--, p++, q++;
  800843:	83 c0 01             	add    $0x1,%eax
  800846:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800849:	39 d8                	cmp    %ebx,%eax
  80084b:	74 16                	je     800863 <strncmp+0x31>
  80084d:	0f b6 08             	movzbl (%eax),%ecx
  800850:	84 c9                	test   %cl,%cl
  800852:	74 04                	je     800858 <strncmp+0x26>
  800854:	3a 0a                	cmp    (%edx),%cl
  800856:	74 eb                	je     800843 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800858:	0f b6 00             	movzbl (%eax),%eax
  80085b:	0f b6 12             	movzbl (%edx),%edx
  80085e:	29 d0                	sub    %edx,%eax
}
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    
		return 0;
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	eb f6                	jmp    800860 <strncmp+0x2e>

0080086a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800874:	0f b6 10             	movzbl (%eax),%edx
  800877:	84 d2                	test   %dl,%dl
  800879:	74 09                	je     800884 <strchr+0x1a>
		if (*s == c)
  80087b:	38 ca                	cmp    %cl,%dl
  80087d:	74 0a                	je     800889 <strchr+0x1f>
	for (; *s; s++)
  80087f:	83 c0 01             	add    $0x1,%eax
  800882:	eb f0                	jmp    800874 <strchr+0xa>
			return (char *) s;
	return 0;
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800895:	eb 03                	jmp    80089a <strfind+0xf>
  800897:	83 c0 01             	add    $0x1,%eax
  80089a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80089d:	38 ca                	cmp    %cl,%dl
  80089f:	74 04                	je     8008a5 <strfind+0x1a>
  8008a1:	84 d2                	test   %dl,%dl
  8008a3:	75 f2                	jne    800897 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	57                   	push   %edi
  8008ab:	56                   	push   %esi
  8008ac:	53                   	push   %ebx
  8008ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008b3:	85 c9                	test   %ecx,%ecx
  8008b5:	74 12                	je     8008c9 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b7:	f6 c2 03             	test   $0x3,%dl
  8008ba:	75 05                	jne    8008c1 <memset+0x1a>
  8008bc:	f6 c1 03             	test   $0x3,%cl
  8008bf:	74 0f                	je     8008d0 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c1:	89 d7                	mov    %edx,%edi
  8008c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c6:	fc                   	cld    
  8008c7:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008c9:	89 d0                	mov    %edx,%eax
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5f                   	pop    %edi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    
		c &= 0xFF;
  8008d0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d4:	89 d8                	mov    %ebx,%eax
  8008d6:	c1 e0 08             	shl    $0x8,%eax
  8008d9:	89 df                	mov    %ebx,%edi
  8008db:	c1 e7 18             	shl    $0x18,%edi
  8008de:	89 de                	mov    %ebx,%esi
  8008e0:	c1 e6 10             	shl    $0x10,%esi
  8008e3:	09 f7                	or     %esi,%edi
  8008e5:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  8008e7:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ea:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008ec:	89 d7                	mov    %edx,%edi
  8008ee:	fc                   	cld    
  8008ef:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f1:	eb d6                	jmp    8008c9 <memset+0x22>

008008f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	57                   	push   %edi
  8008f7:	56                   	push   %esi
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800901:	39 c6                	cmp    %eax,%esi
  800903:	73 35                	jae    80093a <memmove+0x47>
  800905:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800908:	39 c2                	cmp    %eax,%edx
  80090a:	76 2e                	jbe    80093a <memmove+0x47>
		s += n;
		d += n;
  80090c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090f:	89 d6                	mov    %edx,%esi
  800911:	09 fe                	or     %edi,%esi
  800913:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800919:	74 0c                	je     800927 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80091b:	83 ef 01             	sub    $0x1,%edi
  80091e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800921:	fd                   	std    
  800922:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800924:	fc                   	cld    
  800925:	eb 21                	jmp    800948 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 ef                	jne    80091b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80092c:	83 ef 04             	sub    $0x4,%edi
  80092f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800932:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800935:	fd                   	std    
  800936:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800938:	eb ea                	jmp    800924 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093a:	89 f2                	mov    %esi,%edx
  80093c:	09 c2                	or     %eax,%edx
  80093e:	f6 c2 03             	test   $0x3,%dl
  800941:	74 09                	je     80094c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800943:	89 c7                	mov    %eax,%edi
  800945:	fc                   	cld    
  800946:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800948:	5e                   	pop    %esi
  800949:	5f                   	pop    %edi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	f6 c1 03             	test   $0x3,%cl
  80094f:	75 f2                	jne    800943 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800951:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800954:	89 c7                	mov    %eax,%edi
  800956:	fc                   	cld    
  800957:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800959:	eb ed                	jmp    800948 <memmove+0x55>

0080095b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095e:	ff 75 10             	pushl  0x10(%ebp)
  800961:	ff 75 0c             	pushl  0xc(%ebp)
  800964:	ff 75 08             	pushl  0x8(%ebp)
  800967:	e8 87 ff ff ff       	call   8008f3 <memmove>
}
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
  800979:	89 c6                	mov    %eax,%esi
  80097b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	39 f0                	cmp    %esi,%eax
  800980:	74 1c                	je     80099e <memcmp+0x30>
		if (*s1 != *s2)
  800982:	0f b6 08             	movzbl (%eax),%ecx
  800985:	0f b6 1a             	movzbl (%edx),%ebx
  800988:	38 d9                	cmp    %bl,%cl
  80098a:	75 08                	jne    800994 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	83 c2 01             	add    $0x1,%edx
  800992:	eb ea                	jmp    80097e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800994:	0f b6 c1             	movzbl %cl,%eax
  800997:	0f b6 db             	movzbl %bl,%ebx
  80099a:	29 d8                	sub    %ebx,%eax
  80099c:	eb 05                	jmp    8009a3 <memcmp+0x35>
	}

	return 0;
  80099e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a3:	5b                   	pop    %ebx
  8009a4:	5e                   	pop    %esi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b0:	89 c2                	mov    %eax,%edx
  8009b2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b5:	39 d0                	cmp    %edx,%eax
  8009b7:	73 09                	jae    8009c2 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b9:	38 08                	cmp    %cl,(%eax)
  8009bb:	74 05                	je     8009c2 <memfind+0x1b>
	for (; s < ends; s++)
  8009bd:	83 c0 01             	add    $0x1,%eax
  8009c0:	eb f3                	jmp    8009b5 <memfind+0xe>
			break;
	return (void *) s;
}
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d0:	eb 03                	jmp    8009d5 <strtol+0x11>
		s++;
  8009d2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009d5:	0f b6 01             	movzbl (%ecx),%eax
  8009d8:	3c 20                	cmp    $0x20,%al
  8009da:	74 f6                	je     8009d2 <strtol+0xe>
  8009dc:	3c 09                	cmp    $0x9,%al
  8009de:	74 f2                	je     8009d2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009e0:	3c 2b                	cmp    $0x2b,%al
  8009e2:	74 2e                	je     800a12 <strtol+0x4e>
	int neg = 0;
  8009e4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009e9:	3c 2d                	cmp    $0x2d,%al
  8009eb:	74 2f                	je     800a1c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ed:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f3:	75 05                	jne    8009fa <strtol+0x36>
  8009f5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f8:	74 2c                	je     800a26 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009fa:	85 db                	test   %ebx,%ebx
  8009fc:	75 0a                	jne    800a08 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a03:	80 39 30             	cmpb   $0x30,(%ecx)
  800a06:	74 28                	je     800a30 <strtol+0x6c>
		base = 10;
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a10:	eb 50                	jmp    800a62 <strtol+0x9e>
		s++;
  800a12:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a15:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1a:	eb d1                	jmp    8009ed <strtol+0x29>
		s++, neg = 1;
  800a1c:	83 c1 01             	add    $0x1,%ecx
  800a1f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a24:	eb c7                	jmp    8009ed <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a26:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2a:	74 0e                	je     800a3a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a2c:	85 db                	test   %ebx,%ebx
  800a2e:	75 d8                	jne    800a08 <strtol+0x44>
		s++, base = 8;
  800a30:	83 c1 01             	add    $0x1,%ecx
  800a33:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a38:	eb ce                	jmp    800a08 <strtol+0x44>
		s += 2, base = 16;
  800a3a:	83 c1 02             	add    $0x2,%ecx
  800a3d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a42:	eb c4                	jmp    800a08 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a44:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a47:	89 f3                	mov    %esi,%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 29                	ja     800a77 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a4e:	0f be d2             	movsbl %dl,%edx
  800a51:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a54:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a57:	7d 30                	jge    800a89 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a59:	83 c1 01             	add    $0x1,%ecx
  800a5c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a60:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a62:	0f b6 11             	movzbl (%ecx),%edx
  800a65:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a68:	89 f3                	mov    %esi,%ebx
  800a6a:	80 fb 09             	cmp    $0x9,%bl
  800a6d:	77 d5                	ja     800a44 <strtol+0x80>
			dig = *s - '0';
  800a6f:	0f be d2             	movsbl %dl,%edx
  800a72:	83 ea 30             	sub    $0x30,%edx
  800a75:	eb dd                	jmp    800a54 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a77:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7a:	89 f3                	mov    %esi,%ebx
  800a7c:	80 fb 19             	cmp    $0x19,%bl
  800a7f:	77 08                	ja     800a89 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a81:	0f be d2             	movsbl %dl,%edx
  800a84:	83 ea 37             	sub    $0x37,%edx
  800a87:	eb cb                	jmp    800a54 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8d:	74 05                	je     800a94 <strtol+0xd0>
		*endptr = (char *) s;
  800a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a92:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a94:	89 c2                	mov    %eax,%edx
  800a96:	f7 da                	neg    %edx
  800a98:	85 ff                	test   %edi,%edi
  800a9a:	0f 45 c2             	cmovne %edx,%eax
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	83 ec 1c             	sub    $0x1c,%esp
  800aab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800aae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ab1:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab9:	8b 7d 10             	mov    0x10(%ebp),%edi
  800abc:	8b 75 14             	mov    0x14(%ebp),%esi
  800abf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ac5:	74 04                	je     800acb <syscall+0x29>
  800ac7:	85 c0                	test   %eax,%eax
  800ac9:	7f 08                	jg     800ad3 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    
  800ad3:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad6:	83 ec 0c             	sub    $0xc,%esp
  800ad9:	50                   	push   %eax
  800ada:	52                   	push   %edx
  800adb:	68 44 12 80 00       	push   $0x801244
  800ae0:	6a 23                	push   $0x23
  800ae2:	68 61 12 80 00       	push   $0x801261
  800ae7:	e8 3a f6 ff ff       	call   800126 <_panic>

00800aec <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800af2:	6a 00                	push   $0x0
  800af4:	6a 00                	push   $0x0
  800af6:	6a 00                	push   $0x0
  800af8:	ff 75 0c             	pushl  0xc(%ebp)
  800afb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afe:	ba 00 00 00 00       	mov    $0x0,%edx
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	e8 95 ff ff ff       	call   800aa2 <syscall>
}
  800b0d:	83 c4 10             	add    $0x10,%esp
  800b10:	c9                   	leave  
  800b11:	c3                   	ret    

00800b12 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b18:	6a 00                	push   $0x0
  800b1a:	6a 00                	push   $0x0
  800b1c:	6a 00                	push   $0x0
  800b1e:	6a 00                	push   $0x0
  800b20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2f:	e8 6e ff ff ff       	call   800aa2 <syscall>
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b3c:	6a 00                	push   $0x0
  800b3e:	6a 00                	push   $0x0
  800b40:	6a 00                	push   $0x0
  800b42:	6a 00                	push   $0x0
  800b44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b47:	ba 01 00 00 00       	mov    $0x1,%edx
  800b4c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b51:	e8 4c ff ff ff       	call   800aa2 <syscall>
}
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b5e:	6a 00                	push   $0x0
  800b60:	6a 00                	push   $0x0
  800b62:	6a 00                	push   $0x0
  800b64:	6a 00                	push   $0x0
  800b66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 02 00 00 00       	mov    $0x2,%eax
  800b75:	e8 28 ff ff ff       	call   800aa2 <syscall>
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <sys_yield>:

void
sys_yield(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b82:	6a 00                	push   $0x0
  800b84:	6a 00                	push   $0x0
  800b86:	6a 00                	push   $0x0
  800b88:	6a 00                	push   $0x0
  800b8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b99:	e8 04 ff ff ff       	call   800aa2 <syscall>
}
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	ff 75 10             	pushl  0x10(%ebp)
  800bb0:	ff 75 0c             	pushl  0xc(%ebp)
  800bb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb6:	ba 01 00 00 00       	mov    $0x1,%edx
  800bbb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc0:	e8 dd fe ff ff       	call   800aa2 <syscall>
}
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bcd:	ff 75 18             	pushl  0x18(%ebp)
  800bd0:	ff 75 14             	pushl  0x14(%ebp)
  800bd3:	ff 75 10             	pushl  0x10(%ebp)
  800bd6:	ff 75 0c             	pushl  0xc(%ebp)
  800bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdc:	ba 01 00 00 00       	mov    $0x1,%edx
  800be1:	b8 05 00 00 00       	mov    $0x5,%eax
  800be6:	e8 b7 fe ff ff       	call   800aa2 <syscall>
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bf3:	6a 00                	push   $0x0
  800bf5:	6a 00                	push   $0x0
  800bf7:	6a 00                	push   $0x0
  800bf9:	ff 75 0c             	pushl  0xc(%ebp)
  800bfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bff:	ba 01 00 00 00       	mov    $0x1,%edx
  800c04:	b8 06 00 00 00       	mov    $0x6,%eax
  800c09:	e8 94 fe ff ff       	call   800aa2 <syscall>
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c16:	6a 00                	push   $0x0
  800c18:	6a 00                	push   $0x0
  800c1a:	6a 00                	push   $0x0
  800c1c:	ff 75 0c             	pushl  0xc(%ebp)
  800c1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c22:	ba 01 00 00 00       	mov    $0x1,%edx
  800c27:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2c:	e8 71 fe ff ff       	call   800aa2 <syscall>
}
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c39:	6a 00                	push   $0x0
  800c3b:	6a 00                	push   $0x0
  800c3d:	6a 00                	push   $0x0
  800c3f:	ff 75 0c             	pushl  0xc(%ebp)
  800c42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c45:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4f:	e8 4e fe ff ff       	call   800aa2 <syscall>
}
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c5c:	6a 00                	push   $0x0
  800c5e:	ff 75 14             	pushl  0x14(%ebp)
  800c61:	ff 75 10             	pushl  0x10(%ebp)
  800c64:	ff 75 0c             	pushl  0xc(%ebp)
  800c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c74:	e8 29 fe ff ff       	call   800aa2 <syscall>
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c81:	6a 00                	push   $0x0
  800c83:	6a 00                	push   $0x0
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c96:	e8 07 fe ff ff       	call   800aa2 <syscall>
}
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    

00800c9d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ca3:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800caa:	74 0a                	je     800cb6 <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  800cb6:	83 ec 04             	sub    $0x4,%esp
  800cb9:	6a 07                	push   $0x7
  800cbb:	68 00 f0 bf ee       	push   $0xeebff000
  800cc0:	6a 00                	push   $0x0
  800cc2:	e8 dc fe ff ff       	call   800ba3 <sys_page_alloc>
		if (r < 0) return;
  800cc7:	83 c4 10             	add    $0x10,%esp
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	78 e6                	js     800cb4 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800cce:	83 ec 08             	sub    $0x8,%esp
  800cd1:	68 e6 0c 80 00       	push   $0x800ce6
  800cd6:	6a 00                	push   $0x0
  800cd8:	e8 56 ff ff ff       	call   800c33 <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  800cdd:	83 c4 10             	add    $0x10,%esp
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	79 c8                	jns    800cac <set_pgfault_handler+0xf>
  800ce4:	eb ce                	jmp    800cb4 <set_pgfault_handler+0x17>

00800ce6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ce6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ce7:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800cec:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800cee:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  800cf1:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  800cf5:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800cf9:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  800cfc:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  800cfe:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  800d02:	58                   	pop    %eax
	popl %eax
  800d03:	58                   	pop    %eax
	popal
  800d04:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  800d05:	83 c4 04             	add    $0x4,%esp
	popfl
  800d08:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  800d09:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  800d0a:	c3                   	ret    
  800d0b:	66 90                	xchg   %ax,%ax
  800d0d:	66 90                	xchg   %ax,%ax
  800d0f:	90                   	nop

00800d10 <__udivdi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d1b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d23:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d27:	85 d2                	test   %edx,%edx
  800d29:	75 35                	jne    800d60 <__udivdi3+0x50>
  800d2b:	39 f3                	cmp    %esi,%ebx
  800d2d:	0f 87 bd 00 00 00    	ja     800df0 <__udivdi3+0xe0>
  800d33:	85 db                	test   %ebx,%ebx
  800d35:	89 d9                	mov    %ebx,%ecx
  800d37:	75 0b                	jne    800d44 <__udivdi3+0x34>
  800d39:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3e:	31 d2                	xor    %edx,%edx
  800d40:	f7 f3                	div    %ebx
  800d42:	89 c1                	mov    %eax,%ecx
  800d44:	31 d2                	xor    %edx,%edx
  800d46:	89 f0                	mov    %esi,%eax
  800d48:	f7 f1                	div    %ecx
  800d4a:	89 c6                	mov    %eax,%esi
  800d4c:	89 e8                	mov    %ebp,%eax
  800d4e:	89 f7                	mov    %esi,%edi
  800d50:	f7 f1                	div    %ecx
  800d52:	89 fa                	mov    %edi,%edx
  800d54:	83 c4 1c             	add    $0x1c,%esp
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    
  800d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d60:	39 f2                	cmp    %esi,%edx
  800d62:	77 7c                	ja     800de0 <__udivdi3+0xd0>
  800d64:	0f bd fa             	bsr    %edx,%edi
  800d67:	83 f7 1f             	xor    $0x1f,%edi
  800d6a:	0f 84 98 00 00 00    	je     800e08 <__udivdi3+0xf8>
  800d70:	89 f9                	mov    %edi,%ecx
  800d72:	b8 20 00 00 00       	mov    $0x20,%eax
  800d77:	29 f8                	sub    %edi,%eax
  800d79:	d3 e2                	shl    %cl,%edx
  800d7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d7f:	89 c1                	mov    %eax,%ecx
  800d81:	89 da                	mov    %ebx,%edx
  800d83:	d3 ea                	shr    %cl,%edx
  800d85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d89:	09 d1                	or     %edx,%ecx
  800d8b:	89 f2                	mov    %esi,%edx
  800d8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	d3 e3                	shl    %cl,%ebx
  800d95:	89 c1                	mov    %eax,%ecx
  800d97:	d3 ea                	shr    %cl,%edx
  800d99:	89 f9                	mov    %edi,%ecx
  800d9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d9f:	d3 e6                	shl    %cl,%esi
  800da1:	89 eb                	mov    %ebp,%ebx
  800da3:	89 c1                	mov    %eax,%ecx
  800da5:	d3 eb                	shr    %cl,%ebx
  800da7:	09 de                	or     %ebx,%esi
  800da9:	89 f0                	mov    %esi,%eax
  800dab:	f7 74 24 08          	divl   0x8(%esp)
  800daf:	89 d6                	mov    %edx,%esi
  800db1:	89 c3                	mov    %eax,%ebx
  800db3:	f7 64 24 0c          	mull   0xc(%esp)
  800db7:	39 d6                	cmp    %edx,%esi
  800db9:	72 0c                	jb     800dc7 <__udivdi3+0xb7>
  800dbb:	89 f9                	mov    %edi,%ecx
  800dbd:	d3 e5                	shl    %cl,%ebp
  800dbf:	39 c5                	cmp    %eax,%ebp
  800dc1:	73 5d                	jae    800e20 <__udivdi3+0x110>
  800dc3:	39 d6                	cmp    %edx,%esi
  800dc5:	75 59                	jne    800e20 <__udivdi3+0x110>
  800dc7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dca:	31 ff                	xor    %edi,%edi
  800dcc:	89 fa                	mov    %edi,%edx
  800dce:	83 c4 1c             	add    $0x1c,%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    
  800dd6:	8d 76 00             	lea    0x0(%esi),%esi
  800dd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800de0:	31 ff                	xor    %edi,%edi
  800de2:	31 c0                	xor    %eax,%eax
  800de4:	89 fa                	mov    %edi,%edx
  800de6:	83 c4 1c             	add    $0x1c,%esp
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    
  800dee:	66 90                	xchg   %ax,%ax
  800df0:	31 ff                	xor    %edi,%edi
  800df2:	89 e8                	mov    %ebp,%eax
  800df4:	89 f2                	mov    %esi,%edx
  800df6:	f7 f3                	div    %ebx
  800df8:	89 fa                	mov    %edi,%edx
  800dfa:	83 c4 1c             	add    $0x1c,%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    
  800e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e08:	39 f2                	cmp    %esi,%edx
  800e0a:	72 06                	jb     800e12 <__udivdi3+0x102>
  800e0c:	31 c0                	xor    %eax,%eax
  800e0e:	39 eb                	cmp    %ebp,%ebx
  800e10:	77 d2                	ja     800de4 <__udivdi3+0xd4>
  800e12:	b8 01 00 00 00       	mov    $0x1,%eax
  800e17:	eb cb                	jmp    800de4 <__udivdi3+0xd4>
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	89 d8                	mov    %ebx,%eax
  800e22:	31 ff                	xor    %edi,%edi
  800e24:	eb be                	jmp    800de4 <__udivdi3+0xd4>
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__umoddi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 ed                	test   %ebp,%ebp
  800e49:	89 f0                	mov    %esi,%eax
  800e4b:	89 da                	mov    %ebx,%edx
  800e4d:	75 19                	jne    800e68 <__umoddi3+0x38>
  800e4f:	39 df                	cmp    %ebx,%edi
  800e51:	0f 86 b1 00 00 00    	jbe    800f08 <__umoddi3+0xd8>
  800e57:	f7 f7                	div    %edi
  800e59:	89 d0                	mov    %edx,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	83 c4 1c             	add    $0x1c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
  800e65:	8d 76 00             	lea    0x0(%esi),%esi
  800e68:	39 dd                	cmp    %ebx,%ebp
  800e6a:	77 f1                	ja     800e5d <__umoddi3+0x2d>
  800e6c:	0f bd cd             	bsr    %ebp,%ecx
  800e6f:	83 f1 1f             	xor    $0x1f,%ecx
  800e72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e76:	0f 84 b4 00 00 00    	je     800f30 <__umoddi3+0x100>
  800e7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e81:	89 c2                	mov    %eax,%edx
  800e83:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e87:	29 c2                	sub    %eax,%edx
  800e89:	89 c1                	mov    %eax,%ecx
  800e8b:	89 f8                	mov    %edi,%eax
  800e8d:	d3 e5                	shl    %cl,%ebp
  800e8f:	89 d1                	mov    %edx,%ecx
  800e91:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e95:	d3 e8                	shr    %cl,%eax
  800e97:	09 c5                	or     %eax,%ebp
  800e99:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e9d:	89 c1                	mov    %eax,%ecx
  800e9f:	d3 e7                	shl    %cl,%edi
  800ea1:	89 d1                	mov    %edx,%ecx
  800ea3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	d3 ef                	shr    %cl,%edi
  800eab:	89 c1                	mov    %eax,%ecx
  800ead:	89 f0                	mov    %esi,%eax
  800eaf:	d3 e3                	shl    %cl,%ebx
  800eb1:	89 d1                	mov    %edx,%ecx
  800eb3:	89 fa                	mov    %edi,%edx
  800eb5:	d3 e8                	shr    %cl,%eax
  800eb7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ebc:	09 d8                	or     %ebx,%eax
  800ebe:	f7 f5                	div    %ebp
  800ec0:	d3 e6                	shl    %cl,%esi
  800ec2:	89 d1                	mov    %edx,%ecx
  800ec4:	f7 64 24 08          	mull   0x8(%esp)
  800ec8:	39 d1                	cmp    %edx,%ecx
  800eca:	89 c3                	mov    %eax,%ebx
  800ecc:	89 d7                	mov    %edx,%edi
  800ece:	72 06                	jb     800ed6 <__umoddi3+0xa6>
  800ed0:	75 0e                	jne    800ee0 <__umoddi3+0xb0>
  800ed2:	39 c6                	cmp    %eax,%esi
  800ed4:	73 0a                	jae    800ee0 <__umoddi3+0xb0>
  800ed6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800eda:	19 ea                	sbb    %ebp,%edx
  800edc:	89 d7                	mov    %edx,%edi
  800ede:	89 c3                	mov    %eax,%ebx
  800ee0:	89 ca                	mov    %ecx,%edx
  800ee2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ee7:	29 de                	sub    %ebx,%esi
  800ee9:	19 fa                	sbb    %edi,%edx
  800eeb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800eef:	89 d0                	mov    %edx,%eax
  800ef1:	d3 e0                	shl    %cl,%eax
  800ef3:	89 d9                	mov    %ebx,%ecx
  800ef5:	d3 ee                	shr    %cl,%esi
  800ef7:	d3 ea                	shr    %cl,%edx
  800ef9:	09 f0                	or     %esi,%eax
  800efb:	83 c4 1c             	add    $0x1c,%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    
  800f03:	90                   	nop
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	85 ff                	test   %edi,%edi
  800f0a:	89 f9                	mov    %edi,%ecx
  800f0c:	75 0b                	jne    800f19 <__umoddi3+0xe9>
  800f0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f13:	31 d2                	xor    %edx,%edx
  800f15:	f7 f7                	div    %edi
  800f17:	89 c1                	mov    %eax,%ecx
  800f19:	89 d8                	mov    %ebx,%eax
  800f1b:	31 d2                	xor    %edx,%edx
  800f1d:	f7 f1                	div    %ecx
  800f1f:	89 f0                	mov    %esi,%eax
  800f21:	f7 f1                	div    %ecx
  800f23:	e9 31 ff ff ff       	jmp    800e59 <__umoddi3+0x29>
  800f28:	90                   	nop
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	39 dd                	cmp    %ebx,%ebp
  800f32:	72 08                	jb     800f3c <__umoddi3+0x10c>
  800f34:	39 f7                	cmp    %esi,%edi
  800f36:	0f 87 21 ff ff ff    	ja     800e5d <__umoddi3+0x2d>
  800f3c:	89 da                	mov    %ebx,%edx
  800f3e:	89 f0                	mov    %esi,%eax
  800f40:	29 f8                	sub    %edi,%eax
  800f42:	19 ea                	sbb    %ebp,%edx
  800f44:	e9 14 ff ff ff       	jmp    800e5d <__umoddi3+0x2d>
