
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 e9 0a 00 00       	call   800b2b <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 e0 13 80 00       	push   $0x8013e0
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 7f 06 00 00       	call   800702 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7e 07                	jle    800092 <forkchild+0x23>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	89 f0                	mov    %esi,%eax
  800097:	0f be f0             	movsbl %al,%esi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	68 f1 13 80 00       	push   $0x8013f1
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 3c 06 00 00       	call   8006e8 <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 eb 0e 00 00       	call   800f9f <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 64 00 00 00       	call   80012d <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb bd                	jmp    80008b <forkchild+0x1c>

008000ce <umain>:

void
umain(int argc, char **argv)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d4:	68 f0 13 80 00       	push   $0x8013f0
  8000d9:	e8 55 ff ff ff       	call   800033 <forktree>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8000ee:	e8 38 0a 00 00       	call   800b2b <sys_getenvid>
	if (id >= 0)
  8000f3:	85 c0                	test   %eax,%eax
  8000f5:	78 12                	js     800109 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8000f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fc:	c1 e0 07             	shl    $0x7,%eax
  8000ff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800104:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800109:	85 db                	test   %ebx,%ebx
  80010b:	7e 07                	jle    800114 <libmain+0x31>
		binaryname = argv[0];
  80010d:	8b 06                	mov    (%esi),%eax
  80010f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	e8 b0 ff ff ff       	call   8000ce <umain>

	// exit gracefully
	exit();
  80011e:	e8 0a 00 00 00       	call   80012d <exit>
}
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800133:	6a 00                	push   $0x0
  800135:	e8 cf 09 00 00       	call   800b09 <sys_env_destroy>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	53                   	push   %ebx
  800143:	83 ec 04             	sub    $0x4,%esp
  800146:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800149:	8b 13                	mov    (%ebx),%edx
  80014b:	8d 42 01             	lea    0x1(%edx),%eax
  80014e:	89 03                	mov    %eax,(%ebx)
  800150:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800153:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800157:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015c:	74 09                	je     800167 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80015e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800165:	c9                   	leave  
  800166:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800167:	83 ec 08             	sub    $0x8,%esp
  80016a:	68 ff 00 00 00       	push   $0xff
  80016f:	8d 43 08             	lea    0x8(%ebx),%eax
  800172:	50                   	push   %eax
  800173:	e8 47 09 00 00       	call   800abf <sys_cputs>
		b->idx = 0;
  800178:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017e:	83 c4 10             	add    $0x10,%esp
  800181:	eb db                	jmp    80015e <putch+0x1f>

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 3f 01 80 00       	push   $0x80013f
  8001b2:	e8 86 01 00 00       	call   80033d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 f3 08 00 00       	call   800abf <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 7a                	ja     800292 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 64 0f 00 00       	call   8011a0 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 13                	jmp    800262 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80025b:	83 eb 01             	sub    $0x1,%ebx
  80025e:	85 db                	test   %ebx,%ebx
  800260:	7f ed                	jg     80024f <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	56                   	push   %esi
  800266:	83 ec 04             	sub    $0x4,%esp
  800269:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026c:	ff 75 e0             	pushl  -0x20(%ebp)
  80026f:	ff 75 dc             	pushl  -0x24(%ebp)
  800272:	ff 75 d8             	pushl  -0x28(%ebp)
  800275:	e8 46 10 00 00       	call   8012c0 <__umoddi3>
  80027a:	83 c4 14             	add    $0x14,%esp
  80027d:	0f be 80 00 14 80 00 	movsbl 0x801400(%eax),%eax
  800284:	50                   	push   %eax
  800285:	ff d7                	call   *%edi
}
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    
  800292:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800295:	eb c4                	jmp    80025b <printnum+0x73>

00800297 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029a:	83 fa 01             	cmp    $0x1,%edx
  80029d:	7e 0e                	jle    8002ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    
	else if (lflag)
  8002ad:	85 d2                	test   %edx,%edx
  8002af:	75 10                	jne    8002c1 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  8002b1:	8b 10                	mov    (%eax),%edx
  8002b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b6:	89 08                	mov    %ecx,(%eax)
  8002b8:	8b 02                	mov    (%edx),%eax
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	eb ea                	jmp    8002ab <getuint+0x14>
		return va_arg(*ap, unsigned long);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cf:	eb da                	jmp    8002ab <getuint+0x14>

008002d1 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d4:	83 fa 01             	cmp    $0x1,%edx
  8002d7:	7e 0e                	jle    8002e7 <getint+0x16>
		return va_arg(*ap, long long);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    
	else if (lflag)
  8002e7:	85 d2                	test   %edx,%edx
  8002e9:	75 0c                	jne    8002f7 <getint+0x26>
		return va_arg(*ap, int);
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f0:	89 08                	mov    %ecx,(%eax)
  8002f2:	8b 02                	mov    (%edx),%eax
  8002f4:	99                   	cltd   
  8002f5:	eb ee                	jmp    8002e5 <getint+0x14>
		return va_arg(*ap, long);
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 02                	mov    (%edx),%eax
  800300:	99                   	cltd   
  800301:	eb e2                	jmp    8002e5 <getint+0x14>

00800303 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800309:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	3b 50 04             	cmp    0x4(%eax),%edx
  800312:	73 0a                	jae    80031e <sprintputch+0x1b>
		*b->buf++ = ch;
  800314:	8d 4a 01             	lea    0x1(%edx),%ecx
  800317:	89 08                	mov    %ecx,(%eax)
  800319:	8b 45 08             	mov    0x8(%ebp),%eax
  80031c:	88 02                	mov    %al,(%edx)
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <printfmt>:
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800326:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800329:	50                   	push   %eax
  80032a:	ff 75 10             	pushl  0x10(%ebp)
  80032d:	ff 75 0c             	pushl  0xc(%ebp)
  800330:	ff 75 08             	pushl  0x8(%ebp)
  800333:	e8 05 00 00 00       	call   80033d <vprintfmt>
}
  800338:	83 c4 10             	add    $0x10,%esp
  80033b:	c9                   	leave  
  80033c:	c3                   	ret    

0080033d <vprintfmt>:
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 2c             	sub    $0x2c,%esp
  800346:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800349:	8b 75 0c             	mov    0xc(%ebp),%esi
  80034c:	89 f7                	mov    %esi,%edi
  80034e:	89 de                	mov    %ebx,%esi
  800350:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800353:	e9 9e 02 00 00       	jmp    8005f6 <vprintfmt+0x2b9>
		padc = ' ';
  800358:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80035c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800363:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80036a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8d 43 01             	lea    0x1(%ebx),%eax
  800379:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037c:	0f b6 0b             	movzbl (%ebx),%ecx
  80037f:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800382:	3c 55                	cmp    $0x55,%al
  800384:	0f 87 e8 02 00 00    	ja     800672 <vprintfmt+0x335>
  80038a:	0f b6 c0             	movzbl %al,%eax
  80038d:	ff 24 85 c0 14 80 00 	jmp    *0x8014c0(,%eax,4)
  800394:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800397:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80039b:	eb d9                	jmp    800376 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  8003a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a4:	eb d0                	jmp    800376 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	0f b6 c9             	movzbl %cl,%ecx
  8003a9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  8003ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003b4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bb:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8003be:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c1:	83 fa 09             	cmp    $0x9,%edx
  8003c4:	77 52                	ja     800418 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  8003c6:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  8003c9:	eb e9                	jmp    8003b4 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  8003dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e0:	79 94                	jns    800376 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ef:	eb 85                	jmp    800376 <vprintfmt+0x39>
  8003f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	0f 49 c8             	cmovns %eax,%ecx
  8003fe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800404:	e9 6d ff ff ff       	jmp    800376 <vprintfmt+0x39>
  800409:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80040c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800413:	e9 5e ff ff ff       	jmp    800376 <vprintfmt+0x39>
  800418:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80041e:	eb bc                	jmp    8003dc <vprintfmt+0x9f>
			lflag++;
  800420:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800426:	e9 4b ff ff ff       	jmp    800376 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	57                   	push   %edi
  800438:	ff 30                	pushl  (%eax)
  80043a:	ff d6                	call   *%esi
			break;
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	e9 af 01 00 00       	jmp    8005f3 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 50 04             	lea    0x4(%eax),%edx
  80044a:	89 55 14             	mov    %edx,0x14(%ebp)
  80044d:	8b 00                	mov    (%eax),%eax
  80044f:	99                   	cltd   
  800450:	31 d0                	xor    %edx,%eax
  800452:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800454:	83 f8 08             	cmp    $0x8,%eax
  800457:	7f 20                	jg     800479 <vprintfmt+0x13c>
  800459:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  800460:	85 d2                	test   %edx,%edx
  800462:	74 15                	je     800479 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800464:	52                   	push   %edx
  800465:	68 21 14 80 00       	push   $0x801421
  80046a:	57                   	push   %edi
  80046b:	56                   	push   %esi
  80046c:	e8 af fe ff ff       	call   800320 <printfmt>
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	e9 7a 01 00 00       	jmp    8005f3 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800479:	50                   	push   %eax
  80047a:	68 18 14 80 00       	push   $0x801418
  80047f:	57                   	push   %edi
  800480:	56                   	push   %esi
  800481:	e8 9a fe ff ff       	call   800320 <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	e9 65 01 00 00       	jmp    8005f3 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8d 50 04             	lea    0x4(%eax),%edx
  800494:	89 55 14             	mov    %edx,0x14(%ebp)
  800497:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800499:	85 db                	test   %ebx,%ebx
  80049b:	b8 11 14 80 00       	mov    $0x801411,%eax
  8004a0:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  8004a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a7:	0f 8e bd 00 00 00    	jle    80056a <vprintfmt+0x22d>
  8004ad:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b1:	75 0e                	jne    8004c1 <vprintfmt+0x184>
  8004b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b9:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004bf:	eb 6d                	jmp    80052e <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c7:	53                   	push   %ebx
  8004c8:	e8 4d 02 00 00       	call   80071a <strnlen>
  8004cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d0:	29 c1                	sub    %eax,%ecx
  8004d2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004df:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004e2:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e4:	eb 0f                	jmp    8004f5 <vprintfmt+0x1b8>
					putch(padc, putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	57                   	push   %edi
  8004ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ed:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	83 eb 01             	sub    $0x1,%ebx
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	85 db                	test   %ebx,%ebx
  8004f7:	7f ed                	jg     8004e6 <vprintfmt+0x1a9>
  8004f9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004fc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ff:	85 c9                	test   %ecx,%ecx
  800501:	b8 00 00 00 00       	mov    $0x0,%eax
  800506:	0f 49 c1             	cmovns %ecx,%eax
  800509:	29 c1                	sub    %eax,%ecx
  80050b:	89 75 08             	mov    %esi,0x8(%ebp)
  80050e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800511:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800514:	89 cf                	mov    %ecx,%edi
  800516:	eb 16                	jmp    80052e <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800518:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051c:	75 31                	jne    80054f <vprintfmt+0x212>
					putch(ch, putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	ff 75 0c             	pushl  0xc(%ebp)
  800524:	50                   	push   %eax
  800525:	ff 55 08             	call   *0x8(%ebp)
  800528:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052b:	83 ef 01             	sub    $0x1,%edi
  80052e:	83 c3 01             	add    $0x1,%ebx
  800531:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  800535:	0f be c2             	movsbl %dl,%eax
  800538:	85 c0                	test   %eax,%eax
  80053a:	74 50                	je     80058c <vprintfmt+0x24f>
  80053c:	85 f6                	test   %esi,%esi
  80053e:	78 d8                	js     800518 <vprintfmt+0x1db>
  800540:	83 ee 01             	sub    $0x1,%esi
  800543:	79 d3                	jns    800518 <vprintfmt+0x1db>
  800545:	89 fb                	mov    %edi,%ebx
  800547:	8b 75 08             	mov    0x8(%ebp),%esi
  80054a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80054d:	eb 37                	jmp    800586 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	0f be d2             	movsbl %dl,%edx
  800552:	83 ea 20             	sub    $0x20,%edx
  800555:	83 fa 5e             	cmp    $0x5e,%edx
  800558:	76 c4                	jbe    80051e <vprintfmt+0x1e1>
					putch('?', putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	ff 75 0c             	pushl  0xc(%ebp)
  800560:	6a 3f                	push   $0x3f
  800562:	ff 55 08             	call   *0x8(%ebp)
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	eb c1                	jmp    80052b <vprintfmt+0x1ee>
  80056a:	89 75 08             	mov    %esi,0x8(%ebp)
  80056d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800570:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800573:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800576:	eb b6                	jmp    80052e <vprintfmt+0x1f1>
				putch(' ', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	57                   	push   %edi
  80057c:	6a 20                	push   $0x20
  80057e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800580:	83 eb 01             	sub    $0x1,%ebx
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	85 db                	test   %ebx,%ebx
  800588:	7f ee                	jg     800578 <vprintfmt+0x23b>
  80058a:	eb 67                	jmp    8005f3 <vprintfmt+0x2b6>
  80058c:	89 fb                	mov    %edi,%ebx
  80058e:	8b 75 08             	mov    0x8(%ebp),%esi
  800591:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800594:	eb f0                	jmp    800586 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800596:	8d 45 14             	lea    0x14(%ebp),%eax
  800599:	e8 33 fd ff ff       	call   8002d1 <getint>
  80059e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	79 2c                	jns    8005d9 <vprintfmt+0x29c>
				putch('-', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	57                   	push   %edi
  8005b1:	6a 2d                	push   $0x2d
  8005b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005bb:	f7 d8                	neg    %eax
  8005bd:	83 d2 00             	adc    $0x0,%edx
  8005c0:	f7 da                	neg    %edx
  8005c2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ca:	eb 0d                	jmp    8005d9 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  8005cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cf:	e8 c3 fc ff ff       	call   800297 <getuint>
			base = 10;
  8005d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8005d9:	83 ec 0c             	sub    $0xc,%esp
  8005dc:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  8005e0:	53                   	push   %ebx
  8005e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e4:	51                   	push   %ecx
  8005e5:	52                   	push   %edx
  8005e6:	50                   	push   %eax
  8005e7:	89 fa                	mov    %edi,%edx
  8005e9:	89 f0                	mov    %esi,%eax
  8005eb:	e8 f8 fb ff ff       	call   8001e8 <printnum>
			break;
  8005f0:	83 c4 20             	add    $0x20,%esp
{
  8005f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005f6:	83 c3 01             	add    $0x1,%ebx
  8005f9:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005fd:	83 f8 25             	cmp    $0x25,%eax
  800600:	0f 84 52 fd ff ff    	je     800358 <vprintfmt+0x1b>
			if (ch == '\0')
  800606:	85 c0                	test   %eax,%eax
  800608:	0f 84 84 00 00 00    	je     800692 <vprintfmt+0x355>
			putch(ch, putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	57                   	push   %edi
  800612:	50                   	push   %eax
  800613:	ff d6                	call   *%esi
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	eb dc                	jmp    8005f6 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 75 fc ff ff       	call   800297 <getuint>
			base = 8;
  800622:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800627:	eb b0                	jmp    8005d9 <vprintfmt+0x29c>
			putch('0', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	57                   	push   %edi
  80062d:	6a 30                	push   $0x30
  80062f:	ff d6                	call   *%esi
			putch('x', putdat);
  800631:	83 c4 08             	add    $0x8,%esp
  800634:	57                   	push   %edi
  800635:	6a 78                	push   $0x78
  800637:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 50 04             	lea    0x4(%eax),%edx
  80063f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800642:	8b 00                	mov    (%eax),%eax
  800644:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800649:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80064c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800651:	eb 86                	jmp    8005d9 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 3c fc ff ff       	call   800297 <getuint>
			base = 16;
  80065b:	b9 10 00 00 00       	mov    $0x10,%ecx
  800660:	e9 74 ff ff ff       	jmp    8005d9 <vprintfmt+0x29c>
			putch(ch, putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	57                   	push   %edi
  800669:	6a 25                	push   $0x25
  80066b:	ff d6                	call   *%esi
			break;
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	eb 81                	jmp    8005f3 <vprintfmt+0x2b6>
			putch('%', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	57                   	push   %edi
  800676:	6a 25                	push   $0x25
  800678:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	89 d8                	mov    %ebx,%eax
  80067f:	eb 03                	jmp    800684 <vprintfmt+0x347>
  800681:	83 e8 01             	sub    $0x1,%eax
  800684:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800688:	75 f7                	jne    800681 <vprintfmt+0x344>
  80068a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80068d:	e9 61 ff ff ff       	jmp    8005f3 <vprintfmt+0x2b6>
}
  800692:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800695:	5b                   	pop    %ebx
  800696:	5e                   	pop    %esi
  800697:	5f                   	pop    %edi
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 18             	sub    $0x18,%esp
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	74 26                	je     8006e1 <vsnprintf+0x47>
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	7e 22                	jle    8006e1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bf:	ff 75 14             	pushl  0x14(%ebp)
  8006c2:	ff 75 10             	pushl  0x10(%ebp)
  8006c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c8:	50                   	push   %eax
  8006c9:	68 03 03 80 00       	push   $0x800303
  8006ce:	e8 6a fc ff ff       	call   80033d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dc:	83 c4 10             	add    $0x10,%esp
}
  8006df:	c9                   	leave  
  8006e0:	c3                   	ret    
		return -E_INVAL;
  8006e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e6:	eb f7                	jmp    8006df <vsnprintf+0x45>

008006e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f1:	50                   	push   %eax
  8006f2:	ff 75 10             	pushl  0x10(%ebp)
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	ff 75 08             	pushl  0x8(%ebp)
  8006fb:	e8 9a ff ff ff       	call   80069a <vsnprintf>
	va_end(ap);

	return rc;
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800708:	b8 00 00 00 00       	mov    $0x0,%eax
  80070d:	eb 03                	jmp    800712 <strlen+0x10>
		n++;
  80070f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800712:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800716:	75 f7                	jne    80070f <strlen+0xd>
	return n;
}
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800723:	b8 00 00 00 00       	mov    $0x0,%eax
  800728:	eb 03                	jmp    80072d <strnlen+0x13>
		n++;
  80072a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072d:	39 d0                	cmp    %edx,%eax
  80072f:	74 06                	je     800737 <strnlen+0x1d>
  800731:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800735:	75 f3                	jne    80072a <strnlen+0x10>
	return n;
}
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800743:	89 c2                	mov    %eax,%edx
  800745:	83 c1 01             	add    $0x1,%ecx
  800748:	83 c2 01             	add    $0x1,%edx
  80074b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800752:	84 db                	test   %bl,%bl
  800754:	75 ef                	jne    800745 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800756:	5b                   	pop    %ebx
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800760:	53                   	push   %ebx
  800761:	e8 9c ff ff ff       	call   800702 <strlen>
  800766:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	50                   	push   %eax
  80076f:	e8 c5 ff ff ff       	call   800739 <strcpy>
	return dst;
}
  800774:	89 d8                	mov    %ebx,%eax
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800786:	89 f3                	mov    %esi,%ebx
  800788:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078b:	89 f2                	mov    %esi,%edx
  80078d:	eb 0f                	jmp    80079e <strncpy+0x23>
		*dst++ = *src;
  80078f:	83 c2 01             	add    $0x1,%edx
  800792:	0f b6 01             	movzbl (%ecx),%eax
  800795:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800798:	80 39 01             	cmpb   $0x1,(%ecx)
  80079b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80079e:	39 da                	cmp    %ebx,%edx
  8007a0:	75 ed                	jne    80078f <strncpy+0x14>
	}
	return ret;
}
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	5b                   	pop    %ebx
  8007a5:	5e                   	pop    %esi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007b6:	89 f0                	mov    %esi,%eax
  8007b8:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bc:	85 c9                	test   %ecx,%ecx
  8007be:	75 0b                	jne    8007cb <strlcpy+0x23>
  8007c0:	eb 17                	jmp    8007d9 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	83 c0 01             	add    $0x1,%eax
  8007c8:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8007cb:	39 d8                	cmp    %ebx,%eax
  8007cd:	74 07                	je     8007d6 <strlcpy+0x2e>
  8007cf:	0f b6 0a             	movzbl (%edx),%ecx
  8007d2:	84 c9                	test   %cl,%cl
  8007d4:	75 ec                	jne    8007c2 <strlcpy+0x1a>
		*dst = '\0';
  8007d6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d9:	29 f0                	sub    %esi,%eax
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e8:	eb 06                	jmp    8007f0 <strcmp+0x11>
		p++, q++;
  8007ea:	83 c1 01             	add    $0x1,%ecx
  8007ed:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007f0:	0f b6 01             	movzbl (%ecx),%eax
  8007f3:	84 c0                	test   %al,%al
  8007f5:	74 04                	je     8007fb <strcmp+0x1c>
  8007f7:	3a 02                	cmp    (%edx),%al
  8007f9:	74 ef                	je     8007ea <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fb:	0f b6 c0             	movzbl %al,%eax
  8007fe:	0f b6 12             	movzbl (%edx),%edx
  800801:	29 d0                	sub    %edx,%eax
}
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	53                   	push   %ebx
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080f:	89 c3                	mov    %eax,%ebx
  800811:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800814:	eb 06                	jmp    80081c <strncmp+0x17>
		n--, p++, q++;
  800816:	83 c0 01             	add    $0x1,%eax
  800819:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80081c:	39 d8                	cmp    %ebx,%eax
  80081e:	74 16                	je     800836 <strncmp+0x31>
  800820:	0f b6 08             	movzbl (%eax),%ecx
  800823:	84 c9                	test   %cl,%cl
  800825:	74 04                	je     80082b <strncmp+0x26>
  800827:	3a 0a                	cmp    (%edx),%cl
  800829:	74 eb                	je     800816 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082b:	0f b6 00             	movzbl (%eax),%eax
  80082e:	0f b6 12             	movzbl (%edx),%edx
  800831:	29 d0                	sub    %edx,%eax
}
  800833:	5b                   	pop    %ebx
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    
		return 0;
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb f6                	jmp    800833 <strncmp+0x2e>

0080083d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800847:	0f b6 10             	movzbl (%eax),%edx
  80084a:	84 d2                	test   %dl,%dl
  80084c:	74 09                	je     800857 <strchr+0x1a>
		if (*s == c)
  80084e:	38 ca                	cmp    %cl,%dl
  800850:	74 0a                	je     80085c <strchr+0x1f>
	for (; *s; s++)
  800852:	83 c0 01             	add    $0x1,%eax
  800855:	eb f0                	jmp    800847 <strchr+0xa>
			return (char *) s;
	return 0;
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800868:	eb 03                	jmp    80086d <strfind+0xf>
  80086a:	83 c0 01             	add    $0x1,%eax
  80086d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800870:	38 ca                	cmp    %cl,%dl
  800872:	74 04                	je     800878 <strfind+0x1a>
  800874:	84 d2                	test   %dl,%dl
  800876:	75 f2                	jne    80086a <strfind+0xc>
			break;
	return (char *) s;
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	57                   	push   %edi
  80087e:	56                   	push   %esi
  80087f:	53                   	push   %ebx
  800880:	8b 55 08             	mov    0x8(%ebp),%edx
  800883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800886:	85 c9                	test   %ecx,%ecx
  800888:	74 12                	je     80089c <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088a:	f6 c2 03             	test   $0x3,%dl
  80088d:	75 05                	jne    800894 <memset+0x1a>
  80088f:	f6 c1 03             	test   $0x3,%cl
  800892:	74 0f                	je     8008a3 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800894:	89 d7                	mov    %edx,%edi
  800896:	8b 45 0c             	mov    0xc(%ebp),%eax
  800899:	fc                   	cld    
  80089a:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80089c:	89 d0                	mov    %edx,%eax
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5f                   	pop    %edi
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    
		c &= 0xFF;
  8008a3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a7:	89 d8                	mov    %ebx,%eax
  8008a9:	c1 e0 08             	shl    $0x8,%eax
  8008ac:	89 df                	mov    %ebx,%edi
  8008ae:	c1 e7 18             	shl    $0x18,%edi
  8008b1:	89 de                	mov    %ebx,%esi
  8008b3:	c1 e6 10             	shl    $0x10,%esi
  8008b6:	09 f7                	or     %esi,%edi
  8008b8:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  8008ba:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008bf:	89 d7                	mov    %edx,%edi
  8008c1:	fc                   	cld    
  8008c2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c4:	eb d6                	jmp    80089c <memset+0x22>

008008c6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	57                   	push   %edi
  8008ca:	56                   	push   %esi
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d4:	39 c6                	cmp    %eax,%esi
  8008d6:	73 35                	jae    80090d <memmove+0x47>
  8008d8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008db:	39 c2                	cmp    %eax,%edx
  8008dd:	76 2e                	jbe    80090d <memmove+0x47>
		s += n;
		d += n;
  8008df:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e2:	89 d6                	mov    %edx,%esi
  8008e4:	09 fe                	or     %edi,%esi
  8008e6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ec:	74 0c                	je     8008fa <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ee:	83 ef 01             	sub    $0x1,%edi
  8008f1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008f4:	fd                   	std    
  8008f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f7:	fc                   	cld    
  8008f8:	eb 21                	jmp    80091b <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 ef                	jne    8008ee <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ff:	83 ef 04             	sub    $0x4,%edi
  800902:	8d 72 fc             	lea    -0x4(%edx),%esi
  800905:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800908:	fd                   	std    
  800909:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090b:	eb ea                	jmp    8008f7 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090d:	89 f2                	mov    %esi,%edx
  80090f:	09 c2                	or     %eax,%edx
  800911:	f6 c2 03             	test   $0x3,%dl
  800914:	74 09                	je     80091f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800916:	89 c7                	mov    %eax,%edi
  800918:	fc                   	cld    
  800919:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091b:	5e                   	pop    %esi
  80091c:	5f                   	pop    %edi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091f:	f6 c1 03             	test   $0x3,%cl
  800922:	75 f2                	jne    800916 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800924:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800927:	89 c7                	mov    %eax,%edi
  800929:	fc                   	cld    
  80092a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092c:	eb ed                	jmp    80091b <memmove+0x55>

0080092e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800931:	ff 75 10             	pushl  0x10(%ebp)
  800934:	ff 75 0c             	pushl  0xc(%ebp)
  800937:	ff 75 08             	pushl  0x8(%ebp)
  80093a:	e8 87 ff ff ff       	call   8008c6 <memmove>
}
  80093f:	c9                   	leave  
  800940:	c3                   	ret    

00800941 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 c6                	mov    %eax,%esi
  80094e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800951:	39 f0                	cmp    %esi,%eax
  800953:	74 1c                	je     800971 <memcmp+0x30>
		if (*s1 != *s2)
  800955:	0f b6 08             	movzbl (%eax),%ecx
  800958:	0f b6 1a             	movzbl (%edx),%ebx
  80095b:	38 d9                	cmp    %bl,%cl
  80095d:	75 08                	jne    800967 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	83 c2 01             	add    $0x1,%edx
  800965:	eb ea                	jmp    800951 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800967:	0f b6 c1             	movzbl %cl,%eax
  80096a:	0f b6 db             	movzbl %bl,%ebx
  80096d:	29 d8                	sub    %ebx,%eax
  80096f:	eb 05                	jmp    800976 <memcmp+0x35>
	}

	return 0;
  800971:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800983:	89 c2                	mov    %eax,%edx
  800985:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800988:	39 d0                	cmp    %edx,%eax
  80098a:	73 09                	jae    800995 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098c:	38 08                	cmp    %cl,(%eax)
  80098e:	74 05                	je     800995 <memfind+0x1b>
	for (; s < ends; s++)
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	eb f3                	jmp    800988 <memfind+0xe>
			break;
	return (void *) s;
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a3:	eb 03                	jmp    8009a8 <strtol+0x11>
		s++;
  8009a5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009a8:	0f b6 01             	movzbl (%ecx),%eax
  8009ab:	3c 20                	cmp    $0x20,%al
  8009ad:	74 f6                	je     8009a5 <strtol+0xe>
  8009af:	3c 09                	cmp    $0x9,%al
  8009b1:	74 f2                	je     8009a5 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009b3:	3c 2b                	cmp    $0x2b,%al
  8009b5:	74 2e                	je     8009e5 <strtol+0x4e>
	int neg = 0;
  8009b7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009bc:	3c 2d                	cmp    $0x2d,%al
  8009be:	74 2f                	je     8009ef <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c6:	75 05                	jne    8009cd <strtol+0x36>
  8009c8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cb:	74 2c                	je     8009f9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009cd:	85 db                	test   %ebx,%ebx
  8009cf:	75 0a                	jne    8009db <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d1:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8009d6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d9:	74 28                	je     800a03 <strtol+0x6c>
		base = 10;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009e3:	eb 50                	jmp    800a35 <strtol+0x9e>
		s++;
  8009e5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ed:	eb d1                	jmp    8009c0 <strtol+0x29>
		s++, neg = 1;
  8009ef:	83 c1 01             	add    $0x1,%ecx
  8009f2:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f7:	eb c7                	jmp    8009c0 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009fd:	74 0e                	je     800a0d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009ff:	85 db                	test   %ebx,%ebx
  800a01:	75 d8                	jne    8009db <strtol+0x44>
		s++, base = 8;
  800a03:	83 c1 01             	add    $0x1,%ecx
  800a06:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a0b:	eb ce                	jmp    8009db <strtol+0x44>
		s += 2, base = 16;
  800a0d:	83 c1 02             	add    $0x2,%ecx
  800a10:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a15:	eb c4                	jmp    8009db <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a17:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a1a:	89 f3                	mov    %esi,%ebx
  800a1c:	80 fb 19             	cmp    $0x19,%bl
  800a1f:	77 29                	ja     800a4a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a21:	0f be d2             	movsbl %dl,%edx
  800a24:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2a:	7d 30                	jge    800a5c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a2c:	83 c1 01             	add    $0x1,%ecx
  800a2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a33:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a35:	0f b6 11             	movzbl (%ecx),%edx
  800a38:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3b:	89 f3                	mov    %esi,%ebx
  800a3d:	80 fb 09             	cmp    $0x9,%bl
  800a40:	77 d5                	ja     800a17 <strtol+0x80>
			dig = *s - '0';
  800a42:	0f be d2             	movsbl %dl,%edx
  800a45:	83 ea 30             	sub    $0x30,%edx
  800a48:	eb dd                	jmp    800a27 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a4a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a4d:	89 f3                	mov    %esi,%ebx
  800a4f:	80 fb 19             	cmp    $0x19,%bl
  800a52:	77 08                	ja     800a5c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a54:	0f be d2             	movsbl %dl,%edx
  800a57:	83 ea 37             	sub    $0x37,%edx
  800a5a:	eb cb                	jmp    800a27 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a60:	74 05                	je     800a67 <strtol+0xd0>
		*endptr = (char *) s;
  800a62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a65:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a67:	89 c2                	mov    %eax,%edx
  800a69:	f7 da                	neg    %edx
  800a6b:	85 ff                	test   %edi,%edi
  800a6d:	0f 45 c2             	cmovne %edx,%eax
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	57                   	push   %edi
  800a79:	56                   	push   %esi
  800a7a:	53                   	push   %ebx
  800a7b:	83 ec 1c             	sub    $0x1c,%esp
  800a7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a81:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a84:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a8c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a8f:	8b 75 14             	mov    0x14(%ebp),%esi
  800a92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a94:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a98:	74 04                	je     800a9e <syscall+0x29>
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	7f 08                	jg     800aa6 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    
  800aa6:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa9:	83 ec 0c             	sub    $0xc,%esp
  800aac:	50                   	push   %eax
  800aad:	52                   	push   %edx
  800aae:	68 44 16 80 00       	push   $0x801644
  800ab3:	6a 23                	push   $0x23
  800ab5:	68 61 16 80 00       	push   $0x801661
  800aba:	e8 25 06 00 00       	call   8010e4 <_panic>

00800abf <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ac5:	6a 00                	push   $0x0
  800ac7:	6a 00                	push   $0x0
  800ac9:	6a 00                	push   $0x0
  800acb:	ff 75 0c             	pushl  0xc(%ebp)
  800ace:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  800adb:	e8 95 ff ff ff       	call   800a75 <syscall>
}
  800ae0:	83 c4 10             	add    $0x10,%esp
  800ae3:	c9                   	leave  
  800ae4:	c3                   	ret    

00800ae5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800aeb:	6a 00                	push   $0x0
  800aed:	6a 00                	push   $0x0
  800aef:	6a 00                	push   $0x0
  800af1:	6a 00                	push   $0x0
  800af3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 01 00 00 00       	mov    $0x1,%eax
  800b02:	e8 6e ff ff ff       	call   800a75 <syscall>
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b0f:	6a 00                	push   $0x0
  800b11:	6a 00                	push   $0x0
  800b13:	6a 00                	push   $0x0
  800b15:	6a 00                	push   $0x0
  800b17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1a:	ba 01 00 00 00       	mov    $0x1,%edx
  800b1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b24:	e8 4c ff ff ff       	call   800a75 <syscall>
}
  800b29:	c9                   	leave  
  800b2a:	c3                   	ret    

00800b2b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b31:	6a 00                	push   $0x0
  800b33:	6a 00                	push   $0x0
  800b35:	6a 00                	push   $0x0
  800b37:	6a 00                	push   $0x0
  800b39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 02 00 00 00       	mov    $0x2,%eax
  800b48:	e8 28 ff ff ff       	call   800a75 <syscall>
}
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <sys_yield>:

void
sys_yield(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	6a 00                	push   $0x0
  800b5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6c:	e8 04 ff ff ff       	call   800a75 <syscall>
}
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b7c:	6a 00                	push   $0x0
  800b7e:	6a 00                	push   $0x0
  800b80:	ff 75 10             	pushl  0x10(%ebp)
  800b83:	ff 75 0c             	pushl  0xc(%ebp)
  800b86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b89:	ba 01 00 00 00       	mov    $0x1,%edx
  800b8e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b93:	e8 dd fe ff ff       	call   800a75 <syscall>
}
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800ba0:	ff 75 18             	pushl  0x18(%ebp)
  800ba3:	ff 75 14             	pushl  0x14(%ebp)
  800ba6:	ff 75 10             	pushl  0x10(%ebp)
  800ba9:	ff 75 0c             	pushl  0xc(%ebp)
  800bac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800baf:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb4:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb9:	e8 b7 fe ff ff       	call   800a75 <syscall>
}
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bc6:	6a 00                	push   $0x0
  800bc8:	6a 00                	push   $0x0
  800bca:	6a 00                	push   $0x0
  800bcc:	ff 75 0c             	pushl  0xc(%ebp)
  800bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd2:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bdc:	e8 94 fe ff ff       	call   800a75 <syscall>
}
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	6a 00                	push   $0x0
  800bef:	ff 75 0c             	pushl  0xc(%ebp)
  800bf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf5:	ba 01 00 00 00       	mov    $0x1,%edx
  800bfa:	b8 08 00 00 00       	mov    $0x8,%eax
  800bff:	e8 71 fe ff ff       	call   800a75 <syscall>
}
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c0c:	6a 00                	push   $0x0
  800c0e:	6a 00                	push   $0x0
  800c10:	6a 00                	push   $0x0
  800c12:	ff 75 0c             	pushl  0xc(%ebp)
  800c15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c18:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c22:	e8 4e fe ff ff       	call   800a75 <syscall>
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c2f:	6a 00                	push   $0x0
  800c31:	ff 75 14             	pushl  0x14(%ebp)
  800c34:	ff 75 10             	pushl  0x10(%ebp)
  800c37:	ff 75 0c             	pushl  0xc(%ebp)
  800c3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c47:	e8 29 fe ff ff       	call   800a75 <syscall>
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c54:	6a 00                	push   $0x0
  800c56:	6a 00                	push   $0x0
  800c58:	6a 00                	push   $0x0
  800c5a:	6a 00                	push   $0x0
  800c5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c64:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c69:	e8 07 fe ff ff       	call   800a75 <syscall>
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
	int r;

	void *addr = (void*)(pn << PGSHIFT);
  800c75:	89 d6                	mov    %edx,%esi
  800c77:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800c7a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800c81:	89 ca                	mov    %ecx,%edx
  800c83:	83 e2 05             	and    $0x5,%edx
  800c86:	83 fa 05             	cmp    $0x5,%edx
  800c89:	75 5a                	jne    800ce5 <duppage+0x75>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800c8b:	89 ca                	mov    %ecx,%edx
  800c8d:	83 e2 18             	and    $0x18,%edx
		perm |= PTE_PCD | PTE_PWT;
  800c90:	83 fa 01             	cmp    $0x1,%edx
  800c93:	19 d2                	sbb    %edx,%edx
  800c95:	83 e2 e8             	and    $0xffffffe8,%edx
  800c98:	83 c2 1d             	add    $0x1d,%edx


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800c9b:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800ca1:	74 68                	je     800d0b <duppage+0x9b>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800ca3:	89 d3                	mov    %edx,%ebx
  800ca5:	80 cf 08             	or     $0x8,%bh
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	53                   	push   %ebx
  800cac:	56                   	push   %esi
  800cad:	50                   	push   %eax
  800cae:	56                   	push   %esi
  800caf:	6a 00                	push   $0x0
  800cb1:	e8 e4 fe ff ff       	call   800b9a <sys_page_map>
  800cb6:	83 c4 20             	add    $0x20,%esp
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	78 3c                	js     800cf9 <duppage+0x89>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	53                   	push   %ebx
  800cc1:	56                   	push   %esi
  800cc2:	6a 00                	push   $0x0
  800cc4:	56                   	push   %esi
  800cc5:	6a 00                	push   $0x0
  800cc7:	e8 ce fe ff ff       	call   800b9a <sys_page_map>
  800ccc:	83 c4 20             	add    $0x20,%esp
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	79 4d                	jns    800d20 <duppage+0xb0>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800cd3:	50                   	push   %eax
  800cd4:	68 cc 16 80 00       	push   $0x8016cc
  800cd9:	6a 57                	push   $0x57
  800cdb:	68 c1 17 80 00       	push   $0x8017c1
  800ce0:	e8 ff 03 00 00       	call   8010e4 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800ce5:	83 ec 04             	sub    $0x4,%esp
  800ce8:	68 70 16 80 00       	push   $0x801670
  800ced:	6a 47                	push   $0x47
  800cef:	68 c1 17 80 00       	push   $0x8017c1
  800cf4:	e8 eb 03 00 00       	call   8010e4 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800cf9:	50                   	push   %eax
  800cfa:	68 a0 16 80 00       	push   $0x8016a0
  800cff:	6a 53                	push   $0x53
  800d01:	68 c1 17 80 00       	push   $0x8017c1
  800d06:	e8 d9 03 00 00       	call   8010e4 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	52                   	push   %edx
  800d0f:	56                   	push   %esi
  800d10:	50                   	push   %eax
  800d11:	56                   	push   %esi
  800d12:	6a 00                	push   $0x0
  800d14:	e8 81 fe ff ff       	call   800b9a <sys_page_map>
  800d19:	83 c4 20             	add    $0x20,%esp
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	78 0c                	js     800d2c <duppage+0xbc>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800d20:	b8 00 00 00 00       	mov    $0x0,%eax
  800d25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800d2c:	50                   	push   %eax
  800d2d:	68 f4 16 80 00       	push   $0x8016f4
  800d32:	6a 5b                	push   $0x5b
  800d34:	68 c1 17 80 00       	push   $0x8017c1
  800d39:	e8 a6 03 00 00       	call   8010e4 <_panic>

00800d3e <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void*)(pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800d49:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800d50:	a8 01                	test   $0x1,%al
  800d52:	74 38                	je     800d8c <dup_or_share+0x4e>
  800d54:	89 cb                	mov    %ecx,%ebx
  800d56:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800d58:	21 c3                	and    %eax,%ebx
  800d5a:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
  800d5d:	89 c1                	mov    %eax,%ecx
  800d5f:	83 e1 18             	and    $0x18,%ecx
		perm |= PTE_PCD | PTE_PWT;
  800d62:	89 da                	mov    %ebx,%edx
  800d64:	83 ca 18             	or     $0x18,%edx
  800d67:	85 c9                	test   %ecx,%ecx
  800d69:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void*)(pnum << PGSHIFT);
  800d6c:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800d6f:	83 e0 1a             	and    $0x1a,%eax
  800d72:	83 f8 02             	cmp    $0x2,%eax
  800d75:	74 32                	je     800da9 <dup_or_share+0x6b>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	53                   	push   %ebx
  800d7b:	56                   	push   %esi
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	6a 00                	push   $0x0
  800d80:	e8 15 fe ff ff       	call   800b9a <sys_page_map>
  800d85:	83 c4 20             	add    $0x20,%esp
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	78 08                	js     800d94 <dup_or_share+0x56>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800d94:	50                   	push   %eax
  800d95:	68 20 17 80 00       	push   $0x801720
  800d9a:	68 84 00 00 00       	push   $0x84
  800d9f:	68 c1 17 80 00       	push   $0x8017c1
  800da4:	e8 3b 03 00 00       	call   8010e4 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800da9:	83 ec 04             	sub    $0x4,%esp
  800dac:	53                   	push   %ebx
  800dad:	56                   	push   %esi
  800dae:	57                   	push   %edi
  800daf:	e8 c2 fd ff ff       	call   800b76 <sys_page_alloc>
  800db4:	83 c4 10             	add    $0x10,%esp
  800db7:	85 c0                	test   %eax,%eax
  800db9:	78 57                	js     800e12 <dup_or_share+0xd4>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	53                   	push   %ebx
  800dbf:	68 00 00 40 00       	push   $0x400000
  800dc4:	6a 00                	push   $0x0
  800dc6:	56                   	push   %esi
  800dc7:	57                   	push   %edi
  800dc8:	e8 cd fd ff ff       	call   800b9a <sys_page_map>
  800dcd:	83 c4 20             	add    $0x20,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	78 53                	js     800e27 <dup_or_share+0xe9>
		memmove(UTEMP, addr, PGSIZE);
  800dd4:	83 ec 04             	sub    $0x4,%esp
  800dd7:	68 00 10 00 00       	push   $0x1000
  800ddc:	56                   	push   %esi
  800ddd:	68 00 00 40 00       	push   $0x400000
  800de2:	e8 df fa ff ff       	call   8008c6 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800de7:	83 c4 08             	add    $0x8,%esp
  800dea:	68 00 00 40 00       	push   $0x400000
  800def:	6a 00                	push   $0x0
  800df1:	e8 ca fd ff ff       	call   800bc0 <sys_page_unmap>
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	79 8f                	jns    800d8c <dup_or_share+0x4e>
			panic("sys_page_unmap: %e", r);
  800dfd:	50                   	push   %eax
  800dfe:	68 0b 18 80 00       	push   $0x80180b
  800e03:	68 8d 00 00 00       	push   $0x8d
  800e08:	68 c1 17 80 00       	push   $0x8017c1
  800e0d:	e8 d2 02 00 00       	call   8010e4 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800e12:	50                   	push   %eax
  800e13:	68 40 17 80 00       	push   $0x801740
  800e18:	68 88 00 00 00       	push   $0x88
  800e1d:	68 c1 17 80 00       	push   $0x8017c1
  800e22:	e8 bd 02 00 00       	call   8010e4 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800e27:	50                   	push   %eax
  800e28:	68 20 17 80 00       	push   $0x801720
  800e2d:	68 8a 00 00 00       	push   $0x8a
  800e32:	68 c1 17 80 00       	push   $0x8017c1
  800e37:	e8 a8 02 00 00       	call   8010e4 <_panic>

00800e3c <pgfault>:
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t)addr) >> PGSHIFT];
  800e48:	89 d8                	mov    %ebx,%eax
  800e4a:	c1 e8 0c             	shr    $0xc,%eax
  800e4d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800e54:	6a 07                	push   $0x7
  800e56:	68 00 f0 7f 00       	push   $0x7ff000
  800e5b:	6a 00                	push   $0x0
  800e5d:	e8 14 fd ff ff       	call   800b76 <sys_page_alloc>
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	78 51                	js     800eba <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800e69:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e6f:	83 ec 04             	sub    $0x4,%esp
  800e72:	68 00 10 00 00       	push   $0x1000
  800e77:	53                   	push   %ebx
  800e78:	68 00 f0 7f 00       	push   $0x7ff000
  800e7d:	e8 44 fa ff ff       	call   8008c6 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800e82:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e89:	53                   	push   %ebx
  800e8a:	6a 00                	push   $0x0
  800e8c:	68 00 f0 7f 00       	push   $0x7ff000
  800e91:	6a 00                	push   $0x0
  800e93:	e8 02 fd ff ff       	call   800b9a <sys_page_map>
  800e98:	83 c4 20             	add    $0x20,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	78 2d                	js     800ecc <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	68 00 f0 7f 00       	push   $0x7ff000
  800ea7:	6a 00                	push   $0x0
  800ea9:	e8 12 fd ff ff       	call   800bc0 <sys_page_unmap>
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	78 29                	js     800ede <pgfault+0xa2>
}
  800eb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800eba:	50                   	push   %eax
  800ebb:	68 cc 17 80 00       	push   $0x8017cc
  800ec0:	6a 27                	push   $0x27
  800ec2:	68 c1 17 80 00       	push   $0x8017c1
  800ec7:	e8 18 02 00 00       	call   8010e4 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800ecc:	50                   	push   %eax
  800ecd:	68 e8 17 80 00       	push   $0x8017e8
  800ed2:	6a 2c                	push   $0x2c
  800ed4:	68 c1 17 80 00       	push   $0x8017c1
  800ed9:	e8 06 02 00 00       	call   8010e4 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800ede:	50                   	push   %eax
  800edf:	68 02 18 80 00       	push   $0x801802
  800ee4:	6a 2f                	push   $0x2f
  800ee6:	68 c1 17 80 00       	push   $0x8017c1
  800eeb:	e8 f4 01 00 00       	call   8010e4 <_panic>

00800ef0 <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef9:	b8 07 00 00 00       	mov    $0x7,%eax
  800efe:	cd 30                	int    $0x30
  800f00:	89 c7                	mov    %eax,%edi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800f02:	85 c0                	test   %eax,%eax
  800f04:	78 24                	js     800f2a <fork_v0+0x3a>
  800f06:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f08:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	75 39                	jne    800f4a <fork_v0+0x5a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f11:	e8 15 fc ff ff       	call   800b2b <sys_getenvid>
  800f16:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f1b:	c1 e0 07             	shl    $0x7,%eax
  800f1e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f23:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f28:	eb 56                	jmp    800f80 <fork_v0+0x90>
		panic("sys_exofork: %e", envid);
  800f2a:	50                   	push   %eax
  800f2b:	68 1e 18 80 00       	push   $0x80181e
  800f30:	68 a2 00 00 00       	push   $0xa2
  800f35:	68 c1 17 80 00       	push   $0x8017c1
  800f3a:	e8 a5 01 00 00       	call   8010e4 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800f3f:	83 c3 01             	add    $0x1,%ebx
  800f42:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  800f48:	74 24                	je     800f6e <fork_v0+0x7e>
		pde_t pde = uvpd[pnum >> 10];
  800f4a:	89 d8                	mov    %ebx,%eax
  800f4c:	c1 e8 0a             	shr    $0xa,%eax
  800f4f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  800f56:	83 e0 05             	and    $0x5,%eax
  800f59:	83 f8 05             	cmp    $0x5,%eax
  800f5c:	75 e1                	jne    800f3f <fork_v0+0x4f>
			continue;
		dup_or_share(envid, pnum, perm);
  800f5e:	b9 07 00 00 00       	mov    $0x7,%ecx
  800f63:	89 da                	mov    %ebx,%edx
  800f65:	89 f0                	mov    %esi,%eax
  800f67:	e8 d2 fd ff ff       	call   800d3e <dup_or_share>
  800f6c:	eb d1                	jmp    800f3f <fork_v0+0x4f>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	6a 02                	push   $0x2
  800f73:	57                   	push   %edi
  800f74:	e8 6a fc ff ff       	call   800be3 <sys_env_set_status>
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 0a                	js     800f8a <fork_v0+0x9a>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800f80:	89 f8                	mov    %edi,%eax
  800f82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800f8a:	50                   	push   %eax
  800f8b:	68 2e 18 80 00       	push   $0x80182e
  800f90:	68 b8 00 00 00       	push   $0xb8
  800f95:	68 c1 17 80 00       	push   $0x8017c1
  800f9a:	e8 45 01 00 00       	call   8010e4 <_panic>

00800f9f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800fa8:	68 3c 0e 80 00       	push   $0x800e3c
  800fad:	e8 78 01 00 00       	call   80112a <set_pgfault_handler>
  800fb2:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb7:	cd 30                	int    $0x30
  800fb9:	89 c7                	mov    %eax,%edi

	envid_t envid = sys_exofork();
	if (envid < 0)
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 27                	js     800fe9 <fork+0x4a>
  800fc2:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fc4:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	75 44                	jne    801011 <fork+0x72>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fcd:	e8 59 fb ff ff       	call   800b2b <sys_getenvid>
  800fd2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd7:	c1 e0 07             	shl    $0x7,%eax
  800fda:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fdf:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800fe4:	e9 98 00 00 00       	jmp    801081 <fork+0xe2>
		panic("sys_exofork: %e", envid);
  800fe9:	50                   	push   %eax
  800fea:	68 1e 18 80 00       	push   $0x80181e
  800fef:	68 d6 00 00 00       	push   $0xd6
  800ff4:	68 c1 17 80 00       	push   $0x8017c1
  800ff9:	e8 e6 00 00 00       	call   8010e4 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  800ffe:	83 c3 01             	add    $0x1,%ebx
  801001:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801007:	77 36                	ja     80103f <fork+0xa0>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  801009:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80100f:	74 ed                	je     800ffe <fork+0x5f>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  801011:	89 d8                	mov    %ebx,%eax
  801013:	c1 e8 0a             	shr    $0xa,%eax
  801016:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  80101d:	83 e0 05             	and    $0x5,%eax
  801020:	83 f8 05             	cmp    $0x5,%eax
  801023:	75 d9                	jne    800ffe <fork+0x5f>
			continue;

		pte_t pte = uvpt[pnum];
  801025:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  80102c:	83 e0 05             	and    $0x5,%eax
  80102f:	83 f8 05             	cmp    $0x5,%eax
  801032:	75 ca                	jne    800ffe <fork+0x5f>
			continue;
		duppage(envid, pnum);
  801034:	89 da                	mov    %ebx,%edx
  801036:	89 f0                	mov    %esi,%eax
  801038:	e8 33 fc ff ff       	call   800c70 <duppage>
  80103d:	eb bf                	jmp    800ffe <fork+0x5f>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void*)exstk, PTE_U | PTE_P | PTE_W);
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	6a 07                	push   $0x7
  801044:	68 00 f0 bf ee       	push   $0xeebff000
  801049:	57                   	push   %edi
  80104a:	e8 27 fb ff ff       	call   800b76 <sys_page_alloc>
	if (r < 0)
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	78 35                	js     80108b <fork+0xec>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801056:	a1 04 20 80 00       	mov    0x802004,%eax
  80105b:	8b 40 68             	mov    0x68(%eax),%eax
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	50                   	push   %eax
  801062:	57                   	push   %edi
  801063:	e8 9e fb ff ff       	call   800c06 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 31                	js     8010a0 <fork+0x101>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	6a 02                	push   $0x2
  801074:	57                   	push   %edi
  801075:	e8 69 fb ff ff       	call   800be3 <sys_env_set_status>
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	78 34                	js     8010b5 <fork+0x116>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  801081:	89 f8                	mov    %edi,%eax
  801083:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801086:	5b                   	pop    %ebx
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  80108b:	50                   	push   %eax
  80108c:	68 64 17 80 00       	push   $0x801764
  801091:	68 f3 00 00 00       	push   $0xf3
  801096:	68 c1 17 80 00       	push   $0x8017c1
  80109b:	e8 44 00 00 00       	call   8010e4 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  8010a0:	50                   	push   %eax
  8010a1:	68 90 17 80 00       	push   $0x801790
  8010a6:	68 f6 00 00 00       	push   $0xf6
  8010ab:	68 c1 17 80 00       	push   $0x8017c1
  8010b0:	e8 2f 00 00 00       	call   8010e4 <_panic>
		panic("sys_env_set_status: %e", r);
  8010b5:	50                   	push   %eax
  8010b6:	68 2e 18 80 00       	push   $0x80182e
  8010bb:	68 f9 00 00 00       	push   $0xf9
  8010c0:	68 c1 17 80 00       	push   $0x8017c1
  8010c5:	e8 1a 00 00 00       	call   8010e4 <_panic>

008010ca <sfork>:

// Challenge!
int
sfork(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010d0:	68 45 18 80 00       	push   $0x801845
  8010d5:	68 02 01 00 00       	push   $0x102
  8010da:	68 c1 17 80 00       	push   $0x8017c1
  8010df:	e8 00 00 00 00       	call   8010e4 <_panic>

008010e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010ec:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010f2:	e8 34 fa ff ff       	call   800b2b <sys_getenvid>
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	ff 75 0c             	pushl  0xc(%ebp)
  8010fd:	ff 75 08             	pushl  0x8(%ebp)
  801100:	56                   	push   %esi
  801101:	50                   	push   %eax
  801102:	68 5c 18 80 00       	push   $0x80185c
  801107:	e8 c8 f0 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80110c:	83 c4 18             	add    $0x18,%esp
  80110f:	53                   	push   %ebx
  801110:	ff 75 10             	pushl  0x10(%ebp)
  801113:	e8 6b f0 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801118:	c7 04 24 ef 13 80 00 	movl   $0x8013ef,(%esp)
  80111f:	e8 b0 f0 ff ff       	call   8001d4 <cprintf>
  801124:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801127:	cc                   	int3   
  801128:	eb fd                	jmp    801127 <_panic+0x43>

0080112a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801130:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801137:	74 0a                	je     801143 <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801141:	c9                   	leave  
  801142:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  801143:	83 ec 04             	sub    $0x4,%esp
  801146:	6a 07                	push   $0x7
  801148:	68 00 f0 bf ee       	push   $0xeebff000
  80114d:	6a 00                	push   $0x0
  80114f:	e8 22 fa ff ff       	call   800b76 <sys_page_alloc>
		if (r < 0) return;
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	78 e6                	js     801141 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	68 73 11 80 00       	push   $0x801173
  801163:	6a 00                	push   $0x0
  801165:	e8 9c fa ff ff       	call   800c06 <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	85 c0                	test   %eax,%eax
  80116f:	79 c8                	jns    801139 <set_pgfault_handler+0xf>
  801171:	eb ce                	jmp    801141 <set_pgfault_handler+0x17>

00801173 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801173:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801174:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801179:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80117b:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  80117e:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801182:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  801186:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  801189:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  80118b:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  80118f:	58                   	pop    %eax
	popl %eax
  801190:	58                   	pop    %eax
	popal
  801191:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  801192:	83 c4 04             	add    $0x4,%esp
	popfl
  801195:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  801196:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  801197:	c3                   	ret    
  801198:	66 90                	xchg   %ax,%ax
  80119a:	66 90                	xchg   %ax,%ax
  80119c:	66 90                	xchg   %ax,%ax
  80119e:	66 90                	xchg   %ax,%ax

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
