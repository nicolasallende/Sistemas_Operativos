
obj/user/alloczero:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <write>:

#include <inc/lib.h>

void
write(uint16_t *addr, uint16_t value)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;

	if ((r = sys_page_alloc(0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	6a 00                	push   $0x0
  800046:	e8 c2 0b 00 00       	call   800c0d <sys_page_alloc>
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	78 1c                	js     80006e <write+0x3b>
		panic("sys_page_alloc: %e", r);
	addr[0] = value;
  800052:	66 89 33             	mov    %si,(%ebx)
	if ((r = sys_page_unmap(0, addr)) < 0)
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	53                   	push   %ebx
  800059:	6a 00                	push   $0x0
  80005b:	e8 f7 0b 00 00       	call   800c57 <sys_page_unmap>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	78 19                	js     800080 <write+0x4d>
		panic("sys_page_unmap: %e", r);
}
  800067:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80006a:	5b                   	pop    %ebx
  80006b:	5e                   	pop    %esi
  80006c:	5d                   	pop    %ebp
  80006d:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80006e:	50                   	push   %eax
  80006f:	68 60 0f 80 00       	push   $0x800f60
  800074:	6a 0b                	push   $0xb
  800076:	68 73 0f 80 00       	push   $0x800f73
  80007b:	e8 10 01 00 00       	call   800190 <_panic>
		panic("sys_page_unmap: %e", r);
  800080:	50                   	push   %eax
  800081:	68 84 0f 80 00       	push   $0x800f84
  800086:	6a 0e                	push   $0xe
  800088:	68 73 0f 80 00       	push   $0x800f73
  80008d:	e8 fe 00 00 00       	call   800190 <_panic>

00800092 <check>:

void
check(uint16_t *addr)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	53                   	push   %ebx
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;

	if ((r = sys_page_alloc(0, addr, PTE_P|PTE_U)) < 0)
  80009c:	6a 05                	push   $0x5
  80009e:	53                   	push   %ebx
  80009f:	6a 00                	push   $0x0
  8000a1:	e8 67 0b 00 00       	call   800c0d <sys_page_alloc>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	85 c0                	test   %eax,%eax
  8000ab:	78 1d                	js     8000ca <check+0x38>
		panic("sys_page_alloc: %e", r);
	if (addr[0] != '\0')
  8000ad:	66 83 3b 00          	cmpw   $0x0,(%ebx)
  8000b1:	75 29                	jne    8000dc <check+0x4a>
		panic("The allocated memory is not initialized to zero");
	if ((r = sys_page_unmap(0, addr)) < 0)
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	53                   	push   %ebx
  8000b7:	6a 00                	push   $0x0
  8000b9:	e8 99 0b 00 00       	call   800c57 <sys_page_unmap>
  8000be:	83 c4 10             	add    $0x10,%esp
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	78 2b                	js     8000f0 <check+0x5e>
		panic("sys_page_unmap: %e", r);
}
  8000c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8000ca:	50                   	push   %eax
  8000cb:	68 60 0f 80 00       	push   $0x800f60
  8000d0:	6a 17                	push   $0x17
  8000d2:	68 73 0f 80 00       	push   $0x800f73
  8000d7:	e8 b4 00 00 00       	call   800190 <_panic>
		panic("The allocated memory is not initialized to zero");
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	68 98 0f 80 00       	push   $0x800f98
  8000e4:	6a 19                	push   $0x19
  8000e6:	68 73 0f 80 00       	push   $0x800f73
  8000eb:	e8 a0 00 00 00       	call   800190 <_panic>
		panic("sys_page_unmap: %e", r);
  8000f0:	50                   	push   %eax
  8000f1:	68 84 0f 80 00       	push   $0x800f84
  8000f6:	6a 1b                	push   $0x1b
  8000f8:	68 73 0f 80 00       	push   $0x800f73
  8000fd:	e8 8e 00 00 00       	call   800190 <_panic>

00800102 <umain>:

void
umain(int argc, char **argv)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	83 ec 10             	sub    $0x10,%esp
	write(UTEMP, 0x7508);
  800108:	68 08 75 00 00       	push   $0x7508
  80010d:	68 00 00 40 00       	push   $0x400000
  800112:	e8 1c ff ff ff       	call   800033 <write>
	check(UTEMP);
  800117:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  80011e:	e8 6f ff ff ff       	call   800092 <check>
	cprintf("The allocated memory is initialized to zero\n");
  800123:	c7 04 24 c8 0f 80 00 	movl   $0x800fc8,(%esp)
  80012a:	e8 3c 01 00 00       	call   80026b <cprintf>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  80013f:	e8 7e 0a 00 00       	call   800bc2 <sys_getenvid>
	if (id >= 0)
  800144:	85 c0                	test   %eax,%eax
  800146:	78 12                	js     80015a <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  800148:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014d:	c1 e0 07             	shl    $0x7,%eax
  800150:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800155:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015a:	85 db                	test   %ebx,%ebx
  80015c:	7e 07                	jle    800165 <libmain+0x31>
		binaryname = argv[0];
  80015e:	8b 06                	mov    (%esi),%eax
  800160:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
  80016a:	e8 93 ff ff ff       	call   800102 <umain>

	// exit gracefully
	exit();
  80016f:	e8 0a 00 00 00       	call   80017e <exit>
}
  800174:	83 c4 10             	add    $0x10,%esp
  800177:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017a:	5b                   	pop    %ebx
  80017b:	5e                   	pop    %esi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800184:	6a 00                	push   $0x0
  800186:	e8 15 0a 00 00       	call   800ba0 <sys_env_destroy>
}
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	56                   	push   %esi
  800194:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800195:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800198:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80019e:	e8 1f 0a 00 00       	call   800bc2 <sys_getenvid>
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	ff 75 0c             	pushl  0xc(%ebp)
  8001a9:	ff 75 08             	pushl  0x8(%ebp)
  8001ac:	56                   	push   %esi
  8001ad:	50                   	push   %eax
  8001ae:	68 00 10 80 00       	push   $0x801000
  8001b3:	e8 b3 00 00 00       	call   80026b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b8:	83 c4 18             	add    $0x18,%esp
  8001bb:	53                   	push   %ebx
  8001bc:	ff 75 10             	pushl  0x10(%ebp)
  8001bf:	e8 56 00 00 00       	call   80021a <vcprintf>
	cprintf("\n");
  8001c4:	c7 04 24 24 10 80 00 	movl   $0x801024,(%esp)
  8001cb:	e8 9b 00 00 00       	call   80026b <cprintf>
  8001d0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d3:	cc                   	int3   
  8001d4:	eb fd                	jmp    8001d3 <_panic+0x43>

008001d6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	53                   	push   %ebx
  8001da:	83 ec 04             	sub    $0x4,%esp
  8001dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e0:	8b 13                	mov    (%ebx),%edx
  8001e2:	8d 42 01             	lea    0x1(%edx),%eax
  8001e5:	89 03                	mov    %eax,(%ebx)
  8001e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f3:	74 09                	je     8001fe <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001fc:	c9                   	leave  
  8001fd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	68 ff 00 00 00       	push   $0xff
  800206:	8d 43 08             	lea    0x8(%ebx),%eax
  800209:	50                   	push   %eax
  80020a:	e8 47 09 00 00       	call   800b56 <sys_cputs>
		b->idx = 0;
  80020f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	eb db                	jmp    8001f5 <putch+0x1f>

0080021a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800223:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022a:	00 00 00 
	b.cnt = 0;
  80022d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800234:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800237:	ff 75 0c             	pushl  0xc(%ebp)
  80023a:	ff 75 08             	pushl  0x8(%ebp)
  80023d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800243:	50                   	push   %eax
  800244:	68 d6 01 80 00       	push   $0x8001d6
  800249:	e8 86 01 00 00       	call   8003d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024e:	83 c4 08             	add    $0x8,%esp
  800251:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800257:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025d:	50                   	push   %eax
  80025e:	e8 f3 08 00 00       	call   800b56 <sys_cputs>

	return b.cnt;
}
  800263:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800271:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 08             	pushl  0x8(%ebp)
  800278:	e8 9d ff ff ff       	call   80021a <vcprintf>
	va_end(ap);

	return cnt;
}
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 1c             	sub    $0x1c,%esp
  800288:	89 c7                	mov    %eax,%edi
  80028a:	89 d6                	mov    %edx,%esi
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800292:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800295:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800298:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a6:	39 d3                	cmp    %edx,%ebx
  8002a8:	72 05                	jb     8002af <printnum+0x30>
  8002aa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ad:	77 7a                	ja     800329 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002af:	83 ec 0c             	sub    $0xc,%esp
  8002b2:	ff 75 18             	pushl  0x18(%ebp)
  8002b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bb:	53                   	push   %ebx
  8002bc:	ff 75 10             	pushl  0x10(%ebp)
  8002bf:	83 ec 08             	sub    $0x8,%esp
  8002c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ce:	e8 3d 0a 00 00       	call   800d10 <__udivdi3>
  8002d3:	83 c4 18             	add    $0x18,%esp
  8002d6:	52                   	push   %edx
  8002d7:	50                   	push   %eax
  8002d8:	89 f2                	mov    %esi,%edx
  8002da:	89 f8                	mov    %edi,%eax
  8002dc:	e8 9e ff ff ff       	call   80027f <printnum>
  8002e1:	83 c4 20             	add    $0x20,%esp
  8002e4:	eb 13                	jmp    8002f9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e6:	83 ec 08             	sub    $0x8,%esp
  8002e9:	56                   	push   %esi
  8002ea:	ff 75 18             	pushl  0x18(%ebp)
  8002ed:	ff d7                	call   *%edi
  8002ef:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f2:	83 eb 01             	sub    $0x1,%ebx
  8002f5:	85 db                	test   %ebx,%ebx
  8002f7:	7f ed                	jg     8002e6 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f9:	83 ec 08             	sub    $0x8,%esp
  8002fc:	56                   	push   %esi
  8002fd:	83 ec 04             	sub    $0x4,%esp
  800300:	ff 75 e4             	pushl  -0x1c(%ebp)
  800303:	ff 75 e0             	pushl  -0x20(%ebp)
  800306:	ff 75 dc             	pushl  -0x24(%ebp)
  800309:	ff 75 d8             	pushl  -0x28(%ebp)
  80030c:	e8 1f 0b 00 00       	call   800e30 <__umoddi3>
  800311:	83 c4 14             	add    $0x14,%esp
  800314:	0f be 80 26 10 80 00 	movsbl 0x801026(%eax),%eax
  80031b:	50                   	push   %eax
  80031c:	ff d7                	call   *%edi
}
  80031e:	83 c4 10             	add    $0x10,%esp
  800321:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    
  800329:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80032c:	eb c4                	jmp    8002f2 <printnum+0x73>

0080032e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800331:	83 fa 01             	cmp    $0x1,%edx
  800334:	7e 0e                	jle    800344 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800336:	8b 10                	mov    (%eax),%edx
  800338:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    
	else if (lflag)
  800344:	85 d2                	test   %edx,%edx
  800346:	75 10                	jne    800358 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800348:	8b 10                	mov    (%eax),%edx
  80034a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 02                	mov    (%edx),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	eb ea                	jmp    800342 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	eb da                	jmp    800342 <getuint+0x14>

00800368 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036b:	83 fa 01             	cmp    $0x1,%edx
  80036e:	7e 0e                	jle    80037e <getint+0x16>
		return va_arg(*ap, long long);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 08             	lea    0x8(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    
	else if (lflag)
  80037e:	85 d2                	test   %edx,%edx
  800380:	75 0c                	jne    80038e <getint+0x26>
		return va_arg(*ap, int);
  800382:	8b 10                	mov    (%eax),%edx
  800384:	8d 4a 04             	lea    0x4(%edx),%ecx
  800387:	89 08                	mov    %ecx,(%eax)
  800389:	8b 02                	mov    (%edx),%eax
  80038b:	99                   	cltd   
  80038c:	eb ee                	jmp    80037c <getint+0x14>
		return va_arg(*ap, long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 04             	lea    0x4(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	99                   	cltd   
  800398:	eb e2                	jmp    80037c <getint+0x14>

0080039a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a4:	8b 10                	mov    (%eax),%edx
  8003a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a9:	73 0a                	jae    8003b5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ae:	89 08                	mov    %ecx,(%eax)
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b3:	88 02                	mov    %al,(%edx)
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <printfmt>:
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c0:	50                   	push   %eax
  8003c1:	ff 75 10             	pushl  0x10(%ebp)
  8003c4:	ff 75 0c             	pushl  0xc(%ebp)
  8003c7:	ff 75 08             	pushl  0x8(%ebp)
  8003ca:	e8 05 00 00 00       	call   8003d4 <vprintfmt>
}
  8003cf:	83 c4 10             	add    $0x10,%esp
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <vprintfmt>:
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	57                   	push   %edi
  8003d8:	56                   	push   %esi
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 2c             	sub    $0x2c,%esp
  8003dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003e3:	89 f7                	mov    %esi,%edi
  8003e5:	89 de                	mov    %ebx,%esi
  8003e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ea:	e9 9e 02 00 00       	jmp    80068d <vprintfmt+0x2b9>
		padc = ' ';
  8003ef:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003f3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800401:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800408:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8d 43 01             	lea    0x1(%ebx),%eax
  800410:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800413:	0f b6 0b             	movzbl (%ebx),%ecx
  800416:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800419:	3c 55                	cmp    $0x55,%al
  80041b:	0f 87 e8 02 00 00    	ja     800709 <vprintfmt+0x335>
  800421:	0f b6 c0             	movzbl %al,%eax
  800424:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  80042b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80042e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800432:	eb d9                	jmp    80040d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800437:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80043b:	eb d0                	jmp    80040d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	0f b6 c9             	movzbl %cl,%ecx
  800440:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80044b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800452:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800455:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800458:	83 fa 09             	cmp    $0x9,%edx
  80045b:	77 52                	ja     8004af <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  80045d:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800460:	eb e9                	jmp    80044b <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 48 04             	lea    0x4(%eax),%ecx
  800468:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80046b:	8b 00                	mov    (%eax),%eax
  80046d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800473:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800477:	79 94                	jns    80040d <vprintfmt+0x39>
				width = precision, precision = -1;
  800479:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80047c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800486:	eb 85                	jmp    80040d <vprintfmt+0x39>
  800488:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80048b:	85 c0                	test   %eax,%eax
  80048d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800492:	0f 49 c8             	cmovns %eax,%ecx
  800495:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80049b:	e9 6d ff ff ff       	jmp    80040d <vprintfmt+0x39>
  8004a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004aa:	e9 5e ff ff ff       	jmp    80040d <vprintfmt+0x39>
  8004af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004b5:	eb bc                	jmp    800473 <vprintfmt+0x9f>
			lflag++;
  8004b7:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004bd:	e9 4b ff ff ff       	jmp    80040d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	57                   	push   %edi
  8004cf:	ff 30                	pushl  (%eax)
  8004d1:	ff d6                	call   *%esi
			break;
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	e9 af 01 00 00       	jmp    80068a <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	99                   	cltd   
  8004e7:	31 d0                	xor    %edx,%eax
  8004e9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004eb:	83 f8 08             	cmp    $0x8,%eax
  8004ee:	7f 20                	jg     800510 <vprintfmt+0x13c>
  8004f0:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	74 15                	je     800510 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  8004fb:	52                   	push   %edx
  8004fc:	68 47 10 80 00       	push   $0x801047
  800501:	57                   	push   %edi
  800502:	56                   	push   %esi
  800503:	e8 af fe ff ff       	call   8003b7 <printfmt>
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	e9 7a 01 00 00       	jmp    80068a <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800510:	50                   	push   %eax
  800511:	68 3e 10 80 00       	push   $0x80103e
  800516:	57                   	push   %edi
  800517:	56                   	push   %esi
  800518:	e8 9a fe ff ff       	call   8003b7 <printfmt>
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	e9 65 01 00 00       	jmp    80068a <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 04             	lea    0x4(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800530:	85 db                	test   %ebx,%ebx
  800532:	b8 37 10 80 00       	mov    $0x801037,%eax
  800537:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  80053a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053e:	0f 8e bd 00 00 00    	jle    800601 <vprintfmt+0x22d>
  800544:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800548:	75 0e                	jne    800558 <vprintfmt+0x184>
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800550:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800553:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800556:	eb 6d                	jmp    8005c5 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	ff 75 d0             	pushl  -0x30(%ebp)
  80055e:	53                   	push   %ebx
  80055f:	e8 4d 02 00 00       	call   8007b1 <strnlen>
  800564:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800567:	29 c1                	sub    %eax,%ecx
  800569:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800573:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800576:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800579:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	eb 0f                	jmp    80058c <vprintfmt+0x1b8>
					putch(padc, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	57                   	push   %edi
  800581:	ff 75 e0             	pushl  -0x20(%ebp)
  800584:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	83 eb 01             	sub    $0x1,%ebx
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f ed                	jg     80057d <vprintfmt+0x1a9>
  800590:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800593:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800596:	85 c9                	test   %ecx,%ecx
  800598:	b8 00 00 00 00       	mov    $0x0,%eax
  80059d:	0f 49 c1             	cmovns %ecx,%eax
  8005a0:	29 c1                	sub    %eax,%ecx
  8005a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005ab:	89 cf                	mov    %ecx,%edi
  8005ad:	eb 16                	jmp    8005c5 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8005af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b3:	75 31                	jne    8005e6 <vprintfmt+0x212>
					putch(ch, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	ff 75 0c             	pushl  0xc(%ebp)
  8005bb:	50                   	push   %eax
  8005bc:	ff 55 08             	call   *0x8(%ebp)
  8005bf:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c2:	83 ef 01             	sub    $0x1,%edi
  8005c5:	83 c3 01             	add    $0x1,%ebx
  8005c8:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8005cc:	0f be c2             	movsbl %dl,%eax
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	74 50                	je     800623 <vprintfmt+0x24f>
  8005d3:	85 f6                	test   %esi,%esi
  8005d5:	78 d8                	js     8005af <vprintfmt+0x1db>
  8005d7:	83 ee 01             	sub    $0x1,%esi
  8005da:	79 d3                	jns    8005af <vprintfmt+0x1db>
  8005dc:	89 fb                	mov    %edi,%ebx
  8005de:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005e4:	eb 37                	jmp    80061d <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e6:	0f be d2             	movsbl %dl,%edx
  8005e9:	83 ea 20             	sub    $0x20,%edx
  8005ec:	83 fa 5e             	cmp    $0x5e,%edx
  8005ef:	76 c4                	jbe    8005b5 <vprintfmt+0x1e1>
					putch('?', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	ff 75 0c             	pushl  0xc(%ebp)
  8005f7:	6a 3f                	push   $0x3f
  8005f9:	ff 55 08             	call   *0x8(%ebp)
  8005fc:	83 c4 10             	add    $0x10,%esp
  8005ff:	eb c1                	jmp    8005c2 <vprintfmt+0x1ee>
  800601:	89 75 08             	mov    %esi,0x8(%ebp)
  800604:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800607:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80060a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80060d:	eb b6                	jmp    8005c5 <vprintfmt+0x1f1>
				putch(' ', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	57                   	push   %edi
  800613:	6a 20                	push   $0x20
  800615:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800617:	83 eb 01             	sub    $0x1,%ebx
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	85 db                	test   %ebx,%ebx
  80061f:	7f ee                	jg     80060f <vprintfmt+0x23b>
  800621:	eb 67                	jmp    80068a <vprintfmt+0x2b6>
  800623:	89 fb                	mov    %edi,%ebx
  800625:	8b 75 08             	mov    0x8(%ebp),%esi
  800628:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80062b:	eb f0                	jmp    80061d <vprintfmt+0x249>
			num = getint(&ap, lflag);
  80062d:	8d 45 14             	lea    0x14(%ebp),%eax
  800630:	e8 33 fd ff ff       	call   800368 <getint>
  800635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800638:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80063b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800640:	85 d2                	test   %edx,%edx
  800642:	79 2c                	jns    800670 <vprintfmt+0x29c>
				putch('-', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	57                   	push   %edi
  800648:	6a 2d                	push   $0x2d
  80064a:	ff d6                	call   *%esi
				num = -(long long) num;
  80064c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800652:	f7 d8                	neg    %eax
  800654:	83 d2 00             	adc    $0x0,%edx
  800657:	f7 da                	neg    %edx
  800659:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80065c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800661:	eb 0d                	jmp    800670 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 c3 fc ff ff       	call   80032e <getuint>
			base = 10;
  80066b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800670:	83 ec 0c             	sub    $0xc,%esp
  800673:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  800677:	53                   	push   %ebx
  800678:	ff 75 e0             	pushl  -0x20(%ebp)
  80067b:	51                   	push   %ecx
  80067c:	52                   	push   %edx
  80067d:	50                   	push   %eax
  80067e:	89 fa                	mov    %edi,%edx
  800680:	89 f0                	mov    %esi,%eax
  800682:	e8 f8 fb ff ff       	call   80027f <printnum>
			break;
  800687:	83 c4 20             	add    $0x20,%esp
{
  80068a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068d:	83 c3 01             	add    $0x1,%ebx
  800690:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800694:	83 f8 25             	cmp    $0x25,%eax
  800697:	0f 84 52 fd ff ff    	je     8003ef <vprintfmt+0x1b>
			if (ch == '\0')
  80069d:	85 c0                	test   %eax,%eax
  80069f:	0f 84 84 00 00 00    	je     800729 <vprintfmt+0x355>
			putch(ch, putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	57                   	push   %edi
  8006a9:	50                   	push   %eax
  8006aa:	ff d6                	call   *%esi
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb dc                	jmp    80068d <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 75 fc ff ff       	call   80032e <getuint>
			base = 8;
  8006b9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006be:	eb b0                	jmp    800670 <vprintfmt+0x29c>
			putch('0', putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	57                   	push   %edi
  8006c4:	6a 30                	push   $0x30
  8006c6:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c8:	83 c4 08             	add    $0x8,%esp
  8006cb:	57                   	push   %edi
  8006cc:	6a 78                	push   $0x78
  8006ce:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 50 04             	lea    0x4(%eax),%edx
  8006d6:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006d9:	8b 00                	mov    (%eax),%eax
  8006db:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  8006e0:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8006e3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006e8:	eb 86                	jmp    800670 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 3c fc ff ff       	call   80032e <getuint>
			base = 16;
  8006f2:	b9 10 00 00 00       	mov    $0x10,%ecx
  8006f7:	e9 74 ff ff ff       	jmp    800670 <vprintfmt+0x29c>
			putch(ch, putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	57                   	push   %edi
  800700:	6a 25                	push   $0x25
  800702:	ff d6                	call   *%esi
			break;
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb 81                	jmp    80068a <vprintfmt+0x2b6>
			putch('%', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	57                   	push   %edi
  80070d:	6a 25                	push   $0x25
  80070f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	89 d8                	mov    %ebx,%eax
  800716:	eb 03                	jmp    80071b <vprintfmt+0x347>
  800718:	83 e8 01             	sub    $0x1,%eax
  80071b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80071f:	75 f7                	jne    800718 <vprintfmt+0x344>
  800721:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800724:	e9 61 ff ff ff       	jmp    80068a <vprintfmt+0x2b6>
}
  800729:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072c:	5b                   	pop    %ebx
  80072d:	5e                   	pop    %esi
  80072e:	5f                   	pop    %edi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 18             	sub    $0x18,%esp
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800740:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800744:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800747:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074e:	85 c0                	test   %eax,%eax
  800750:	74 26                	je     800778 <vsnprintf+0x47>
  800752:	85 d2                	test   %edx,%edx
  800754:	7e 22                	jle    800778 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800756:	ff 75 14             	pushl  0x14(%ebp)
  800759:	ff 75 10             	pushl  0x10(%ebp)
  80075c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075f:	50                   	push   %eax
  800760:	68 9a 03 80 00       	push   $0x80039a
  800765:	e8 6a fc ff ff       	call   8003d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800770:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800773:	83 c4 10             	add    $0x10,%esp
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    
		return -E_INVAL;
  800778:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077d:	eb f7                	jmp    800776 <vsnprintf+0x45>

0080077f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800785:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800788:	50                   	push   %eax
  800789:	ff 75 10             	pushl  0x10(%ebp)
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	ff 75 08             	pushl  0x8(%ebp)
  800792:	e8 9a ff ff ff       	call   800731 <vsnprintf>
	va_end(ap);

	return rc;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	eb 03                	jmp    8007a9 <strlen+0x10>
		n++;
  8007a6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007a9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ad:	75 f7                	jne    8007a6 <strlen+0xd>
	return n;
}
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bf:	eb 03                	jmp    8007c4 <strnlen+0x13>
		n++;
  8007c1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c4:	39 d0                	cmp    %edx,%eax
  8007c6:	74 06                	je     8007ce <strnlen+0x1d>
  8007c8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cc:	75 f3                	jne    8007c1 <strnlen+0x10>
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007da:	89 c2                	mov    %eax,%edx
  8007dc:	83 c1 01             	add    $0x1,%ecx
  8007df:	83 c2 01             	add    $0x1,%edx
  8007e2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e9:	84 db                	test   %bl,%bl
  8007eb:	75 ef                	jne    8007dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ed:	5b                   	pop    %ebx
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f7:	53                   	push   %ebx
  8007f8:	e8 9c ff ff ff       	call   800799 <strlen>
  8007fd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800800:	ff 75 0c             	pushl  0xc(%ebp)
  800803:	01 d8                	add    %ebx,%eax
  800805:	50                   	push   %eax
  800806:	e8 c5 ff ff ff       	call   8007d0 <strcpy>
	return dst;
}
  80080b:	89 d8                	mov    %ebx,%eax
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	89 f3                	mov    %esi,%ebx
  80081f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800822:	89 f2                	mov    %esi,%edx
  800824:	eb 0f                	jmp    800835 <strncpy+0x23>
		*dst++ = *src;
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	0f b6 01             	movzbl (%ecx),%eax
  80082c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082f:	80 39 01             	cmpb   $0x1,(%ecx)
  800832:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800835:	39 da                	cmp    %ebx,%edx
  800837:	75 ed                	jne    800826 <strncpy+0x14>
	}
	return ret;
}
  800839:	89 f0                	mov    %esi,%eax
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 75 08             	mov    0x8(%ebp),%esi
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800853:	85 c9                	test   %ecx,%ecx
  800855:	75 0b                	jne    800862 <strlcpy+0x23>
  800857:	eb 17                	jmp    800870 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800859:	83 c2 01             	add    $0x1,%edx
  80085c:	83 c0 01             	add    $0x1,%eax
  80085f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800862:	39 d8                	cmp    %ebx,%eax
  800864:	74 07                	je     80086d <strlcpy+0x2e>
  800866:	0f b6 0a             	movzbl (%edx),%ecx
  800869:	84 c9                	test   %cl,%cl
  80086b:	75 ec                	jne    800859 <strlcpy+0x1a>
		*dst = '\0';
  80086d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800870:	29 f0                	sub    %esi,%eax
}
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087f:	eb 06                	jmp    800887 <strcmp+0x11>
		p++, q++;
  800881:	83 c1 01             	add    $0x1,%ecx
  800884:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800887:	0f b6 01             	movzbl (%ecx),%eax
  80088a:	84 c0                	test   %al,%al
  80088c:	74 04                	je     800892 <strcmp+0x1c>
  80088e:	3a 02                	cmp    (%edx),%al
  800890:	74 ef                	je     800881 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800892:	0f b6 c0             	movzbl %al,%eax
  800895:	0f b6 12             	movzbl (%edx),%edx
  800898:	29 d0                	sub    %edx,%eax
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	53                   	push   %ebx
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	89 c3                	mov    %eax,%ebx
  8008a8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ab:	eb 06                	jmp    8008b3 <strncmp+0x17>
		n--, p++, q++;
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b3:	39 d8                	cmp    %ebx,%eax
  8008b5:	74 16                	je     8008cd <strncmp+0x31>
  8008b7:	0f b6 08             	movzbl (%eax),%ecx
  8008ba:	84 c9                	test   %cl,%cl
  8008bc:	74 04                	je     8008c2 <strncmp+0x26>
  8008be:	3a 0a                	cmp    (%edx),%cl
  8008c0:	74 eb                	je     8008ad <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c2:	0f b6 00             	movzbl (%eax),%eax
  8008c5:	0f b6 12             	movzbl (%edx),%edx
  8008c8:	29 d0                	sub    %edx,%eax
}
  8008ca:	5b                   	pop    %ebx
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    
		return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d2:	eb f6                	jmp    8008ca <strncmp+0x2e>

008008d4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	0f b6 10             	movzbl (%eax),%edx
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	74 09                	je     8008ee <strchr+0x1a>
		if (*s == c)
  8008e5:	38 ca                	cmp    %cl,%dl
  8008e7:	74 0a                	je     8008f3 <strchr+0x1f>
	for (; *s; s++)
  8008e9:	83 c0 01             	add    $0x1,%eax
  8008ec:	eb f0                	jmp    8008de <strchr+0xa>
			return (char *) s;
	return 0;
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ff:	eb 03                	jmp    800904 <strfind+0xf>
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 04                	je     80090f <strfind+0x1a>
  80090b:	84 d2                	test   %dl,%dl
  80090d:	75 f2                	jne    800901 <strfind+0xc>
			break;
	return (char *) s;
}
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	57                   	push   %edi
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 55 08             	mov    0x8(%ebp),%edx
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80091d:	85 c9                	test   %ecx,%ecx
  80091f:	74 12                	je     800933 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800921:	f6 c2 03             	test   $0x3,%dl
  800924:	75 05                	jne    80092b <memset+0x1a>
  800926:	f6 c1 03             	test   $0x3,%cl
  800929:	74 0f                	je     80093a <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092b:	89 d7                	mov    %edx,%edi
  80092d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800930:	fc                   	cld    
  800931:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800933:	89 d0                	mov    %edx,%eax
  800935:	5b                   	pop    %ebx
  800936:	5e                   	pop    %esi
  800937:	5f                   	pop    %edi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    
		c &= 0xFF;
  80093a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093e:	89 d8                	mov    %ebx,%eax
  800940:	c1 e0 08             	shl    $0x8,%eax
  800943:	89 df                	mov    %ebx,%edi
  800945:	c1 e7 18             	shl    $0x18,%edi
  800948:	89 de                	mov    %ebx,%esi
  80094a:	c1 e6 10             	shl    $0x10,%esi
  80094d:	09 f7                	or     %esi,%edi
  80094f:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800951:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800954:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800956:	89 d7                	mov    %edx,%edi
  800958:	fc                   	cld    
  800959:	f3 ab                	rep stos %eax,%es:(%edi)
  80095b:	eb d6                	jmp    800933 <memset+0x22>

0080095d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	57                   	push   %edi
  800961:	56                   	push   %esi
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8b 75 0c             	mov    0xc(%ebp),%esi
  800968:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096b:	39 c6                	cmp    %eax,%esi
  80096d:	73 35                	jae    8009a4 <memmove+0x47>
  80096f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800972:	39 c2                	cmp    %eax,%edx
  800974:	76 2e                	jbe    8009a4 <memmove+0x47>
		s += n;
		d += n;
  800976:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800979:	89 d6                	mov    %edx,%esi
  80097b:	09 fe                	or     %edi,%esi
  80097d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800983:	74 0c                	je     800991 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800985:	83 ef 01             	sub    $0x1,%edi
  800988:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80098b:	fd                   	std    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098e:	fc                   	cld    
  80098f:	eb 21                	jmp    8009b2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 ef                	jne    800985 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800996:	83 ef 04             	sub    $0x4,%edi
  800999:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80099f:	fd                   	std    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb ea                	jmp    80098e <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	89 f2                	mov    %esi,%edx
  8009a6:	09 c2                	or     %eax,%edx
  8009a8:	f6 c2 03             	test   $0x3,%dl
  8009ab:	74 09                	je     8009b6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ad:	89 c7                	mov    %eax,%edi
  8009af:	fc                   	cld    
  8009b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b2:	5e                   	pop    %esi
  8009b3:	5f                   	pop    %edi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b6:	f6 c1 03             	test   $0x3,%cl
  8009b9:	75 f2                	jne    8009ad <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009be:	89 c7                	mov    %eax,%edi
  8009c0:	fc                   	cld    
  8009c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c3:	eb ed                	jmp    8009b2 <memmove+0x55>

008009c5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c8:	ff 75 10             	pushl  0x10(%ebp)
  8009cb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ce:	ff 75 08             	pushl  0x8(%ebp)
  8009d1:	e8 87 ff ff ff       	call   80095d <memmove>
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e3:	89 c6                	mov    %eax,%esi
  8009e5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e8:	39 f0                	cmp    %esi,%eax
  8009ea:	74 1c                	je     800a08 <memcmp+0x30>
		if (*s1 != *s2)
  8009ec:	0f b6 08             	movzbl (%eax),%ecx
  8009ef:	0f b6 1a             	movzbl (%edx),%ebx
  8009f2:	38 d9                	cmp    %bl,%cl
  8009f4:	75 08                	jne    8009fe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	83 c2 01             	add    $0x1,%edx
  8009fc:	eb ea                	jmp    8009e8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009fe:	0f b6 c1             	movzbl %cl,%eax
  800a01:	0f b6 db             	movzbl %bl,%ebx
  800a04:	29 d8                	sub    %ebx,%eax
  800a06:	eb 05                	jmp    800a0d <memcmp+0x35>
	}

	return 0;
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1a:	89 c2                	mov    %eax,%edx
  800a1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1f:	39 d0                	cmp    %edx,%eax
  800a21:	73 09                	jae    800a2c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a23:	38 08                	cmp    %cl,(%eax)
  800a25:	74 05                	je     800a2c <memfind+0x1b>
	for (; s < ends; s++)
  800a27:	83 c0 01             	add    $0x1,%eax
  800a2a:	eb f3                	jmp    800a1f <memfind+0xe>
			break;
	return (void *) s;
}
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3a:	eb 03                	jmp    800a3f <strtol+0x11>
		s++;
  800a3c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a3f:	0f b6 01             	movzbl (%ecx),%eax
  800a42:	3c 20                	cmp    $0x20,%al
  800a44:	74 f6                	je     800a3c <strtol+0xe>
  800a46:	3c 09                	cmp    $0x9,%al
  800a48:	74 f2                	je     800a3c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a4a:	3c 2b                	cmp    $0x2b,%al
  800a4c:	74 2e                	je     800a7c <strtol+0x4e>
	int neg = 0;
  800a4e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a53:	3c 2d                	cmp    $0x2d,%al
  800a55:	74 2f                	je     800a86 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a57:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5d:	75 05                	jne    800a64 <strtol+0x36>
  800a5f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a62:	74 2c                	je     800a90 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	75 0a                	jne    800a72 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a68:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a70:	74 28                	je     800a9a <strtol+0x6c>
		base = 10;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a7a:	eb 50                	jmp    800acc <strtol+0x9e>
		s++;
  800a7c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a84:	eb d1                	jmp    800a57 <strtol+0x29>
		s++, neg = 1;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8e:	eb c7                	jmp    800a57 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a90:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a94:	74 0e                	je     800aa4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a96:	85 db                	test   %ebx,%ebx
  800a98:	75 d8                	jne    800a72 <strtol+0x44>
		s++, base = 8;
  800a9a:	83 c1 01             	add    $0x1,%ecx
  800a9d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa2:	eb ce                	jmp    800a72 <strtol+0x44>
		s += 2, base = 16;
  800aa4:	83 c1 02             	add    $0x2,%ecx
  800aa7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aac:	eb c4                	jmp    800a72 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 29                	ja     800ae1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac1:	7d 30                	jge    800af3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac3:	83 c1 01             	add    $0x1,%ecx
  800ac6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aca:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800acc:	0f b6 11             	movzbl (%ecx),%edx
  800acf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad2:	89 f3                	mov    %esi,%ebx
  800ad4:	80 fb 09             	cmp    $0x9,%bl
  800ad7:	77 d5                	ja     800aae <strtol+0x80>
			dig = *s - '0';
  800ad9:	0f be d2             	movsbl %dl,%edx
  800adc:	83 ea 30             	sub    $0x30,%edx
  800adf:	eb dd                	jmp    800abe <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ae1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae4:	89 f3                	mov    %esi,%ebx
  800ae6:	80 fb 19             	cmp    $0x19,%bl
  800ae9:	77 08                	ja     800af3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aeb:	0f be d2             	movsbl %dl,%edx
  800aee:	83 ea 37             	sub    $0x37,%edx
  800af1:	eb cb                	jmp    800abe <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af7:	74 05                	je     800afe <strtol+0xd0>
		*endptr = (char *) s;
  800af9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800afe:	89 c2                	mov    %eax,%edx
  800b00:	f7 da                	neg    %edx
  800b02:	85 ff                	test   %edi,%edi
  800b04:	0f 45 c2             	cmovne %edx,%eax
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 1c             	sub    $0x1c,%esp
  800b15:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b18:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b1b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b23:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b26:	8b 75 14             	mov    0x14(%ebp),%esi
  800b29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b2f:	74 04                	je     800b35 <syscall+0x29>
  800b31:	85 c0                	test   %eax,%eax
  800b33:	7f 08                	jg     800b3d <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    
  800b3d:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	52                   	push   %edx
  800b45:	68 64 12 80 00       	push   $0x801264
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 81 12 80 00       	push   $0x801281
  800b51:	e8 3a f6 ff ff       	call   800190 <_panic>

00800b56 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b5c:	6a 00                	push   $0x0
  800b5e:	6a 00                	push   $0x0
  800b60:	6a 00                	push   $0x0
  800b62:	ff 75 0c             	pushl  0xc(%ebp)
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b72:	e8 95 ff ff ff       	call   800b0c <syscall>
}
  800b77:	83 c4 10             	add    $0x10,%esp
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b82:	6a 00                	push   $0x0
  800b84:	6a 00                	push   $0x0
  800b86:	6a 00                	push   $0x0
  800b88:	6a 00                	push   $0x0
  800b8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	b8 01 00 00 00       	mov    $0x1,%eax
  800b99:	e8 6e ff ff ff       	call   800b0c <syscall>
}
  800b9e:	c9                   	leave  
  800b9f:	c3                   	ret    

00800ba0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ba6:	6a 00                	push   $0x0
  800ba8:	6a 00                	push   $0x0
  800baa:	6a 00                	push   $0x0
  800bac:	6a 00                	push   $0x0
  800bae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb1:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb6:	b8 03 00 00 00       	mov    $0x3,%eax
  800bbb:	e8 4c ff ff ff       	call   800b0c <syscall>
}
  800bc0:	c9                   	leave  
  800bc1:	c3                   	ret    

00800bc2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bc8:	6a 00                	push   $0x0
  800bca:	6a 00                	push   $0x0
  800bcc:	6a 00                	push   $0x0
  800bce:	6a 00                	push   $0x0
  800bd0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bda:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdf:	e8 28 ff ff ff       	call   800b0c <syscall>
}
  800be4:	c9                   	leave  
  800be5:	c3                   	ret    

00800be6 <sys_yield>:

void
sys_yield(void)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bec:	6a 00                	push   $0x0
  800bee:	6a 00                	push   $0x0
  800bf0:	6a 00                	push   $0x0
  800bf2:	6a 00                	push   $0x0
  800bf4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c03:	e8 04 ff ff ff       	call   800b0c <syscall>
}
  800c08:	83 c4 10             	add    $0x10,%esp
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c13:	6a 00                	push   $0x0
  800c15:	6a 00                	push   $0x0
  800c17:	ff 75 10             	pushl  0x10(%ebp)
  800c1a:	ff 75 0c             	pushl  0xc(%ebp)
  800c1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c20:	ba 01 00 00 00       	mov    $0x1,%edx
  800c25:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2a:	e8 dd fe ff ff       	call   800b0c <syscall>
}
  800c2f:	c9                   	leave  
  800c30:	c3                   	ret    

00800c31 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c37:	ff 75 18             	pushl  0x18(%ebp)
  800c3a:	ff 75 14             	pushl  0x14(%ebp)
  800c3d:	ff 75 10             	pushl  0x10(%ebp)
  800c40:	ff 75 0c             	pushl  0xc(%ebp)
  800c43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c46:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c50:	e8 b7 fe ff ff       	call   800b0c <syscall>
}
  800c55:	c9                   	leave  
  800c56:	c3                   	ret    

00800c57 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c5d:	6a 00                	push   $0x0
  800c5f:	6a 00                	push   $0x0
  800c61:	6a 00                	push   $0x0
  800c63:	ff 75 0c             	pushl  0xc(%ebp)
  800c66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c69:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c73:	e8 94 fe ff ff       	call   800b0c <syscall>
}
  800c78:	c9                   	leave  
  800c79:	c3                   	ret    

00800c7a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c80:	6a 00                	push   $0x0
  800c82:	6a 00                	push   $0x0
  800c84:	6a 00                	push   $0x0
  800c86:	ff 75 0c             	pushl  0xc(%ebp)
  800c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c91:	b8 08 00 00 00       	mov    $0x8,%eax
  800c96:	e8 71 fe ff ff       	call   800b0c <syscall>
}
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ca3:	6a 00                	push   $0x0
  800ca5:	6a 00                	push   $0x0
  800ca7:	6a 00                	push   $0x0
  800ca9:	ff 75 0c             	pushl  0xc(%ebp)
  800cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800caf:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb9:	e8 4e fe ff ff       	call   800b0c <syscall>
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cc6:	6a 00                	push   $0x0
  800cc8:	ff 75 14             	pushl  0x14(%ebp)
  800ccb:	ff 75 10             	pushl  0x10(%ebp)
  800cce:	ff 75 0c             	pushl  0xc(%ebp)
  800cd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cde:	e8 29 fe ff ff       	call   800b0c <syscall>
}
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    

00800ce5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ceb:	6a 00                	push   $0x0
  800ced:	6a 00                	push   $0x0
  800cef:	6a 00                	push   $0x0
  800cf1:	6a 00                	push   $0x0
  800cf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf6:	ba 01 00 00 00       	mov    $0x1,%edx
  800cfb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d00:	e8 07 fe ff ff       	call   800b0c <syscall>
}
  800d05:	c9                   	leave  
  800d06:	c3                   	ret    
  800d07:	66 90                	xchg   %ax,%ax
  800d09:	66 90                	xchg   %ax,%ax
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
