
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 7a 01 00 00       	call   8001ab <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 29 10 00 00       	call   801067 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 a4 00 00 00    	jne    8000ed <umain+0xba>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 50 11 00 00       	call   8011ac <ipc_recv>
		cprintf("%x got message from %x: %s\n",
			thisenv->env_id, who, TEMP_ADDR_CHILD);
  80005c:	a1 0c 20 80 00       	mov    0x80200c,%eax
		cprintf("%x got message from %x: %s\n",
  800061:	8b 40 48             	mov    0x48(%eax),%eax
  800064:	68 00 00 b0 00       	push   $0xb00000
  800069:	ff 75 f4             	pushl  -0xc(%ebp)
  80006c:	50                   	push   %eax
  80006d:	68 a0 15 80 00       	push   $0x8015a0
  800072:	e8 25 02 00 00       	call   80029c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	ff 35 04 20 80 00    	pushl  0x802004
  800080:	e8 45 07 00 00       	call   8007ca <strlen>
  800085:	83 c4 0c             	add    $0xc,%esp
  800088:	50                   	push   %eax
  800089:	ff 35 04 20 80 00    	pushl  0x802004
  80008f:	68 00 00 b0 00       	push   $0xb00000
  800094:	e8 34 08 00 00       	call   8008cd <strncmp>
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	85 c0                	test   %eax,%eax
  80009e:	74 3b                	je     8000db <umain+0xa8>
			cprintf("child received correct message\n");

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000a0:	83 ec 0c             	sub    $0xc,%esp
  8000a3:	ff 35 00 20 80 00    	pushl  0x802000
  8000a9:	e8 1c 07 00 00       	call   8007ca <strlen>
  8000ae:	83 c4 0c             	add    $0xc,%esp
  8000b1:	83 c0 01             	add    $0x1,%eax
  8000b4:	50                   	push   %eax
  8000b5:	ff 35 00 20 80 00    	pushl  0x802000
  8000bb:	68 00 00 b0 00       	push   $0xb00000
  8000c0:	e8 31 09 00 00       	call   8009f6 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000c5:	6a 07                	push   $0x7
  8000c7:	68 00 00 b0 00       	push   $0xb00000
  8000cc:	6a 00                	push   $0x0
  8000ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8000d1:	e8 32 11 00 00       	call   801208 <ipc_send>
		return;
  8000d6:	83 c4 20             	add    $0x20,%esp
	cprintf("%x got message from %x: %s\n",
		thisenv->env_id, who, TEMP_ADDR);
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
		cprintf("parent received correct message\n");
	return;
}
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    
			cprintf("child received correct message\n");
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	68 bc 15 80 00       	push   $0x8015bc
  8000e3:	e8 b4 01 00 00       	call   80029c <cprintf>
  8000e8:	83 c4 10             	add    $0x10,%esp
  8000eb:	eb b3                	jmp    8000a0 <umain+0x6d>
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000ed:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000f2:	8b 40 48             	mov    0x48(%eax),%eax
  8000f5:	83 ec 04             	sub    $0x4,%esp
  8000f8:	6a 07                	push   $0x7
  8000fa:	68 00 00 a0 00       	push   $0xa00000
  8000ff:	50                   	push   %eax
  800100:	e8 39 0b 00 00       	call   800c3e <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800105:	83 c4 04             	add    $0x4,%esp
  800108:	ff 35 04 20 80 00    	pushl  0x802004
  80010e:	e8 b7 06 00 00       	call   8007ca <strlen>
  800113:	83 c4 0c             	add    $0xc,%esp
  800116:	83 c0 01             	add    $0x1,%eax
  800119:	50                   	push   %eax
  80011a:	ff 35 04 20 80 00    	pushl  0x802004
  800120:	68 00 00 a0 00       	push   $0xa00000
  800125:	e8 cc 08 00 00       	call   8009f6 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80012a:	6a 07                	push   $0x7
  80012c:	68 00 00 a0 00       	push   $0xa00000
  800131:	6a 00                	push   $0x0
  800133:	ff 75 f4             	pushl  -0xc(%ebp)
  800136:	e8 cd 10 00 00       	call   801208 <ipc_send>
	ipc_recv(&who, TEMP_ADDR, 0);
  80013b:	83 c4 1c             	add    $0x1c,%esp
  80013e:	6a 00                	push   $0x0
  800140:	68 00 00 a0 00       	push   $0xa00000
  800145:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800148:	50                   	push   %eax
  800149:	e8 5e 10 00 00       	call   8011ac <ipc_recv>
		thisenv->env_id, who, TEMP_ADDR);
  80014e:	a1 0c 20 80 00       	mov    0x80200c,%eax
	cprintf("%x got message from %x: %s\n",
  800153:	8b 40 48             	mov    0x48(%eax),%eax
  800156:	68 00 00 a0 00       	push   $0xa00000
  80015b:	ff 75 f4             	pushl  -0xc(%ebp)
  80015e:	50                   	push   %eax
  80015f:	68 a0 15 80 00       	push   $0x8015a0
  800164:	e8 33 01 00 00       	call   80029c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  800169:	83 c4 14             	add    $0x14,%esp
  80016c:	ff 35 00 20 80 00    	pushl  0x802000
  800172:	e8 53 06 00 00       	call   8007ca <strlen>
  800177:	83 c4 0c             	add    $0xc,%esp
  80017a:	50                   	push   %eax
  80017b:	ff 35 00 20 80 00    	pushl  0x802000
  800181:	68 00 00 a0 00       	push   $0xa00000
  800186:	e8 42 07 00 00       	call   8008cd <strncmp>
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	85 c0                	test   %eax,%eax
  800190:	0f 85 43 ff ff ff    	jne    8000d9 <umain+0xa6>
		cprintf("parent received correct message\n");
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	68 dc 15 80 00       	push   $0x8015dc
  80019e:	e8 f9 00 00 00       	call   80029c <cprintf>
  8001a3:	83 c4 10             	add    $0x10,%esp
  8001a6:	e9 2e ff ff ff       	jmp    8000d9 <umain+0xa6>

008001ab <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001b3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8001b6:	e8 38 0a 00 00       	call   800bf3 <sys_getenvid>
	if (id >= 0)
  8001bb:	85 c0                	test   %eax,%eax
  8001bd:	78 12                	js     8001d1 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8001bf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001c4:	c1 e0 07             	shl    $0x7,%eax
  8001c7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001cc:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001d1:	85 db                	test   %ebx,%ebx
  8001d3:	7e 07                	jle    8001dc <libmain+0x31>
		binaryname = argv[0];
  8001d5:	8b 06                	mov    (%esi),%eax
  8001d7:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	e8 4d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001e6:	e8 0a 00 00 00       	call   8001f5 <exit>
}
  8001eb:	83 c4 10             	add    $0x10,%esp
  8001ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001f1:	5b                   	pop    %ebx
  8001f2:	5e                   	pop    %esi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001fb:	6a 00                	push   $0x0
  8001fd:	e8 cf 09 00 00       	call   800bd1 <sys_env_destroy>
}
  800202:	83 c4 10             	add    $0x10,%esp
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	53                   	push   %ebx
  80020b:	83 ec 04             	sub    $0x4,%esp
  80020e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800211:	8b 13                	mov    (%ebx),%edx
  800213:	8d 42 01             	lea    0x1(%edx),%eax
  800216:	89 03                	mov    %eax,(%ebx)
  800218:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80021f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800224:	74 09                	je     80022f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800226:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	68 ff 00 00 00       	push   $0xff
  800237:	8d 43 08             	lea    0x8(%ebx),%eax
  80023a:	50                   	push   %eax
  80023b:	e8 47 09 00 00       	call   800b87 <sys_cputs>
		b->idx = 0;
  800240:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800246:	83 c4 10             	add    $0x10,%esp
  800249:	eb db                	jmp    800226 <putch+0x1f>

0080024b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800254:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025b:	00 00 00 
	b.cnt = 0;
  80025e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800265:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800274:	50                   	push   %eax
  800275:	68 07 02 80 00       	push   $0x800207
  80027a:	e8 86 01 00 00       	call   800405 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027f:	83 c4 08             	add    $0x8,%esp
  800282:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800288:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028e:	50                   	push   %eax
  80028f:	e8 f3 08 00 00       	call   800b87 <sys_cputs>

	return b.cnt;
}
  800294:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a5:	50                   	push   %eax
  8002a6:	ff 75 08             	pushl  0x8(%ebp)
  8002a9:	e8 9d ff ff ff       	call   80024b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 1c             	sub    $0x1c,%esp
  8002b9:	89 c7                	mov    %eax,%edi
  8002bb:	89 d6                	mov    %edx,%esi
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002d4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002d7:	39 d3                	cmp    %edx,%ebx
  8002d9:	72 05                	jb     8002e0 <printnum+0x30>
  8002db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002de:	77 7a                	ja     80035a <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	ff 75 18             	pushl  0x18(%ebp)
  8002e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ec:	53                   	push   %ebx
  8002ed:	ff 75 10             	pushl  0x10(%ebp)
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ff:	e8 5c 10 00 00       	call   801360 <__udivdi3>
  800304:	83 c4 18             	add    $0x18,%esp
  800307:	52                   	push   %edx
  800308:	50                   	push   %eax
  800309:	89 f2                	mov    %esi,%edx
  80030b:	89 f8                	mov    %edi,%eax
  80030d:	e8 9e ff ff ff       	call   8002b0 <printnum>
  800312:	83 c4 20             	add    $0x20,%esp
  800315:	eb 13                	jmp    80032a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800317:	83 ec 08             	sub    $0x8,%esp
  80031a:	56                   	push   %esi
  80031b:	ff 75 18             	pushl  0x18(%ebp)
  80031e:	ff d7                	call   *%edi
  800320:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800323:	83 eb 01             	sub    $0x1,%ebx
  800326:	85 db                	test   %ebx,%ebx
  800328:	7f ed                	jg     800317 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	56                   	push   %esi
  80032e:	83 ec 04             	sub    $0x4,%esp
  800331:	ff 75 e4             	pushl  -0x1c(%ebp)
  800334:	ff 75 e0             	pushl  -0x20(%ebp)
  800337:	ff 75 dc             	pushl  -0x24(%ebp)
  80033a:	ff 75 d8             	pushl  -0x28(%ebp)
  80033d:	e8 3e 11 00 00       	call   801480 <__umoddi3>
  800342:	83 c4 14             	add    $0x14,%esp
  800345:	0f be 80 54 16 80 00 	movsbl 0x801654(%eax),%eax
  80034c:	50                   	push   %eax
  80034d:	ff d7                	call   *%edi
}
  80034f:	83 c4 10             	add    $0x10,%esp
  800352:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800355:	5b                   	pop    %ebx
  800356:	5e                   	pop    %esi
  800357:	5f                   	pop    %edi
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    
  80035a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035d:	eb c4                	jmp    800323 <printnum+0x73>

0080035f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800362:	83 fa 01             	cmp    $0x1,%edx
  800365:	7e 0e                	jle    800375 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 08             	lea    0x8(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    
	else if (lflag)
  800375:	85 d2                	test   %edx,%edx
  800377:	75 10                	jne    800389 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb ea                	jmp    800373 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
  800397:	eb da                	jmp    800373 <getuint+0x14>

00800399 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80039c:	83 fa 01             	cmp    $0x1,%edx
  80039f:	7e 0e                	jle    8003af <getint+0x16>
		return va_arg(*ap, long long);
  8003a1:	8b 10                	mov    (%eax),%edx
  8003a3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a6:	89 08                	mov    %ecx,(%eax)
  8003a8:	8b 02                	mov    (%edx),%eax
  8003aa:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    
	else if (lflag)
  8003af:	85 d2                	test   %edx,%edx
  8003b1:	75 0c                	jne    8003bf <getint+0x26>
		return va_arg(*ap, int);
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b8:	89 08                	mov    %ecx,(%eax)
  8003ba:	8b 02                	mov    (%edx),%eax
  8003bc:	99                   	cltd   
  8003bd:	eb ee                	jmp    8003ad <getint+0x14>
		return va_arg(*ap, long);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	99                   	cltd   
  8003c9:	eb e2                	jmp    8003ad <getint+0x14>

008003cb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d5:	8b 10                	mov    (%eax),%edx
  8003d7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003da:	73 0a                	jae    8003e6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003dc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e4:	88 02                	mov    %al,(%edx)
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <printfmt>:
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003ee:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f1:	50                   	push   %eax
  8003f2:	ff 75 10             	pushl  0x10(%ebp)
  8003f5:	ff 75 0c             	pushl  0xc(%ebp)
  8003f8:	ff 75 08             	pushl  0x8(%ebp)
  8003fb:	e8 05 00 00 00       	call   800405 <vprintfmt>
}
  800400:	83 c4 10             	add    $0x10,%esp
  800403:	c9                   	leave  
  800404:	c3                   	ret    

00800405 <vprintfmt>:
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	57                   	push   %edi
  800409:	56                   	push   %esi
  80040a:	53                   	push   %ebx
  80040b:	83 ec 2c             	sub    $0x2c,%esp
  80040e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800411:	8b 75 0c             	mov    0xc(%ebp),%esi
  800414:	89 f7                	mov    %esi,%edi
  800416:	89 de                	mov    %ebx,%esi
  800418:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80041b:	e9 9e 02 00 00       	jmp    8006be <vprintfmt+0x2b9>
		padc = ' ';
  800420:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800424:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80042b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800432:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800439:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8d 43 01             	lea    0x1(%ebx),%eax
  800441:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800444:	0f b6 0b             	movzbl (%ebx),%ecx
  800447:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80044a:	3c 55                	cmp    $0x55,%al
  80044c:	0f 87 e8 02 00 00    	ja     80073a <vprintfmt+0x335>
  800452:	0f b6 c0             	movzbl %al,%eax
  800455:	ff 24 85 20 17 80 00 	jmp    *0x801720(,%eax,4)
  80045c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80045f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800463:	eb d9                	jmp    80043e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  800468:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046c:	eb d0                	jmp    80043e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	0f b6 c9             	movzbl %cl,%ecx
  800471:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80047c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800483:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800486:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800489:	83 fa 09             	cmp    $0x9,%edx
  80048c:	77 52                	ja     8004e0 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  80048e:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800491:	eb e9                	jmp    80047c <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 48 04             	lea    0x4(%eax),%ecx
  800499:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80049c:	8b 00                	mov    (%eax),%eax
  80049e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  8004a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a8:	79 94                	jns    80043e <vprintfmt+0x39>
				width = precision, precision = -1;
  8004aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b7:	eb 85                	jmp    80043e <vprintfmt+0x39>
  8004b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c3:	0f 49 c8             	cmovns %eax,%ecx
  8004c6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004cc:	e9 6d ff ff ff       	jmp    80043e <vprintfmt+0x39>
  8004d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004d4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004db:	e9 5e ff ff ff       	jmp    80043e <vprintfmt+0x39>
  8004e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004e6:	eb bc                	jmp    8004a4 <vprintfmt+0x9f>
			lflag++;
  8004e8:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004ee:	e9 4b ff ff ff       	jmp    80043e <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8d 50 04             	lea    0x4(%eax),%edx
  8004f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	57                   	push   %edi
  800500:	ff 30                	pushl  (%eax)
  800502:	ff d6                	call   *%esi
			break;
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	e9 af 01 00 00       	jmp    8006bb <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8d 50 04             	lea    0x4(%eax),%edx
  800512:	89 55 14             	mov    %edx,0x14(%ebp)
  800515:	8b 00                	mov    (%eax),%eax
  800517:	99                   	cltd   
  800518:	31 d0                	xor    %edx,%eax
  80051a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051c:	83 f8 08             	cmp    $0x8,%eax
  80051f:	7f 20                	jg     800541 <vprintfmt+0x13c>
  800521:	8b 14 85 80 18 80 00 	mov    0x801880(,%eax,4),%edx
  800528:	85 d2                	test   %edx,%edx
  80052a:	74 15                	je     800541 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80052c:	52                   	push   %edx
  80052d:	68 75 16 80 00       	push   $0x801675
  800532:	57                   	push   %edi
  800533:	56                   	push   %esi
  800534:	e8 af fe ff ff       	call   8003e8 <printfmt>
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	e9 7a 01 00 00       	jmp    8006bb <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  800541:	50                   	push   %eax
  800542:	68 6c 16 80 00       	push   $0x80166c
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	e8 9a fe ff ff       	call   8003e8 <printfmt>
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	e9 65 01 00 00       	jmp    8006bb <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  800561:	85 db                	test   %ebx,%ebx
  800563:	b8 65 16 80 00       	mov    $0x801665,%eax
  800568:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  80056b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80056f:	0f 8e bd 00 00 00    	jle    800632 <vprintfmt+0x22d>
  800575:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800579:	75 0e                	jne    800589 <vprintfmt+0x184>
  80057b:	89 75 08             	mov    %esi,0x8(%ebp)
  80057e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800581:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800584:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800587:	eb 6d                	jmp    8005f6 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	ff 75 d0             	pushl  -0x30(%ebp)
  80058f:	53                   	push   %ebx
  800590:	e8 4d 02 00 00       	call   8007e2 <strnlen>
  800595:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800598:	29 c1                	sub    %eax,%ecx
  80059a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80059d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a7:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8005aa:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ac:	eb 0f                	jmp    8005bd <vprintfmt+0x1b8>
					putch(padc, putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	57                   	push   %edi
  8005b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b7:	83 eb 01             	sub    $0x1,%ebx
  8005ba:	83 c4 10             	add    $0x10,%esp
  8005bd:	85 db                	test   %ebx,%ebx
  8005bf:	7f ed                	jg     8005ae <vprintfmt+0x1a9>
  8005c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005c4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c7:	85 c9                	test   %ecx,%ecx
  8005c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ce:	0f 49 c1             	cmovns %ecx,%eax
  8005d1:	29 c1                	sub    %eax,%ecx
  8005d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d9:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005dc:	89 cf                	mov    %ecx,%edi
  8005de:	eb 16                	jmp    8005f6 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e4:	75 31                	jne    800617 <vprintfmt+0x212>
					putch(ch, putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ec:	50                   	push   %eax
  8005ed:	ff 55 08             	call   *0x8(%ebp)
  8005f0:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f3:	83 ef 01             	sub    $0x1,%edi
  8005f6:	83 c3 01             	add    $0x1,%ebx
  8005f9:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  8005fd:	0f be c2             	movsbl %dl,%eax
  800600:	85 c0                	test   %eax,%eax
  800602:	74 50                	je     800654 <vprintfmt+0x24f>
  800604:	85 f6                	test   %esi,%esi
  800606:	78 d8                	js     8005e0 <vprintfmt+0x1db>
  800608:	83 ee 01             	sub    $0x1,%esi
  80060b:	79 d3                	jns    8005e0 <vprintfmt+0x1db>
  80060d:	89 fb                	mov    %edi,%ebx
  80060f:	8b 75 08             	mov    0x8(%ebp),%esi
  800612:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800615:	eb 37                	jmp    80064e <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  800617:	0f be d2             	movsbl %dl,%edx
  80061a:	83 ea 20             	sub    $0x20,%edx
  80061d:	83 fa 5e             	cmp    $0x5e,%edx
  800620:	76 c4                	jbe    8005e6 <vprintfmt+0x1e1>
					putch('?', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	ff 75 0c             	pushl  0xc(%ebp)
  800628:	6a 3f                	push   $0x3f
  80062a:	ff 55 08             	call   *0x8(%ebp)
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb c1                	jmp    8005f3 <vprintfmt+0x1ee>
  800632:	89 75 08             	mov    %esi,0x8(%ebp)
  800635:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800638:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80063b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80063e:	eb b6                	jmp    8005f6 <vprintfmt+0x1f1>
				putch(' ', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	57                   	push   %edi
  800644:	6a 20                	push   $0x20
  800646:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800648:	83 eb 01             	sub    $0x1,%ebx
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	85 db                	test   %ebx,%ebx
  800650:	7f ee                	jg     800640 <vprintfmt+0x23b>
  800652:	eb 67                	jmp    8006bb <vprintfmt+0x2b6>
  800654:	89 fb                	mov    %edi,%ebx
  800656:	8b 75 08             	mov    0x8(%ebp),%esi
  800659:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80065c:	eb f0                	jmp    80064e <vprintfmt+0x249>
			num = getint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 33 fd ff ff       	call   800399 <getint>
  800666:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800669:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80066c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800671:	85 d2                	test   %edx,%edx
  800673:	79 2c                	jns    8006a1 <vprintfmt+0x29c>
				putch('-', putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	57                   	push   %edi
  800679:	6a 2d                	push   $0x2d
  80067b:	ff d6                	call   *%esi
				num = -(long long) num;
  80067d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800680:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800683:	f7 d8                	neg    %eax
  800685:	83 d2 00             	adc    $0x0,%edx
  800688:	f7 da                	neg    %edx
  80068a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80068d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800692:	eb 0d                	jmp    8006a1 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800694:	8d 45 14             	lea    0x14(%ebp),%eax
  800697:	e8 c3 fc ff ff       	call   80035f <getuint>
			base = 10;
  80069c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8006a1:	83 ec 0c             	sub    $0xc,%esp
  8006a4:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  8006a8:	53                   	push   %ebx
  8006a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ac:	51                   	push   %ecx
  8006ad:	52                   	push   %edx
  8006ae:	50                   	push   %eax
  8006af:	89 fa                	mov    %edi,%edx
  8006b1:	89 f0                	mov    %esi,%eax
  8006b3:	e8 f8 fb ff ff       	call   8002b0 <printnum>
			break;
  8006b8:	83 c4 20             	add    $0x20,%esp
{
  8006bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006be:	83 c3 01             	add    $0x1,%ebx
  8006c1:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8006c5:	83 f8 25             	cmp    $0x25,%eax
  8006c8:	0f 84 52 fd ff ff    	je     800420 <vprintfmt+0x1b>
			if (ch == '\0')
  8006ce:	85 c0                	test   %eax,%eax
  8006d0:	0f 84 84 00 00 00    	je     80075a <vprintfmt+0x355>
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	57                   	push   %edi
  8006da:	50                   	push   %eax
  8006db:	ff d6                	call   *%esi
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb dc                	jmp    8006be <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e5:	e8 75 fc ff ff       	call   80035f <getuint>
			base = 8;
  8006ea:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006ef:	eb b0                	jmp    8006a1 <vprintfmt+0x29c>
			putch('0', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	57                   	push   %edi
  8006f5:	6a 30                	push   $0x30
  8006f7:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f9:	83 c4 08             	add    $0x8,%esp
  8006fc:	57                   	push   %edi
  8006fd:	6a 78                	push   $0x78
  8006ff:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800711:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800714:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800719:	eb 86                	jmp    8006a1 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	e8 3c fc ff ff       	call   80035f <getuint>
			base = 16;
  800723:	b9 10 00 00 00       	mov    $0x10,%ecx
  800728:	e9 74 ff ff ff       	jmp    8006a1 <vprintfmt+0x29c>
			putch(ch, putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	57                   	push   %edi
  800731:	6a 25                	push   $0x25
  800733:	ff d6                	call   *%esi
			break;
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 81                	jmp    8006bb <vprintfmt+0x2b6>
			putch('%', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	57                   	push   %edi
  80073e:	6a 25                	push   $0x25
  800740:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	89 d8                	mov    %ebx,%eax
  800747:	eb 03                	jmp    80074c <vprintfmt+0x347>
  800749:	83 e8 01             	sub    $0x1,%eax
  80074c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800750:	75 f7                	jne    800749 <vprintfmt+0x344>
  800752:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800755:	e9 61 ff ff ff       	jmp    8006bb <vprintfmt+0x2b6>
}
  80075a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075d:	5b                   	pop    %ebx
  80075e:	5e                   	pop    %esi
  80075f:	5f                   	pop    %edi
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 18             	sub    $0x18,%esp
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800771:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800775:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800778:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077f:	85 c0                	test   %eax,%eax
  800781:	74 26                	je     8007a9 <vsnprintf+0x47>
  800783:	85 d2                	test   %edx,%edx
  800785:	7e 22                	jle    8007a9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800787:	ff 75 14             	pushl  0x14(%ebp)
  80078a:	ff 75 10             	pushl  0x10(%ebp)
  80078d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800790:	50                   	push   %eax
  800791:	68 cb 03 80 00       	push   $0x8003cb
  800796:	e8 6a fc ff ff       	call   800405 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a4:	83 c4 10             	add    $0x10,%esp
}
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    
		return -E_INVAL;
  8007a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ae:	eb f7                	jmp    8007a7 <vsnprintf+0x45>

008007b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	ff 75 08             	pushl  0x8(%ebp)
  8007c3:	e8 9a ff ff ff       	call   800762 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d5:	eb 03                	jmp    8007da <strlen+0x10>
		n++;
  8007d7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007de:	75 f7                	jne    8007d7 <strlen+0xd>
	return n;
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f0:	eb 03                	jmp    8007f5 <strnlen+0x13>
		n++;
  8007f2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f5:	39 d0                	cmp    %edx,%eax
  8007f7:	74 06                	je     8007ff <strnlen+0x1d>
  8007f9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007fd:	75 f3                	jne    8007f2 <strnlen+0x10>
	return n;
}
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	53                   	push   %ebx
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080b:	89 c2                	mov    %eax,%edx
  80080d:	83 c1 01             	add    $0x1,%ecx
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800817:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081a:	84 db                	test   %bl,%bl
  80081c:	75 ef                	jne    80080d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80081e:	5b                   	pop    %ebx
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	53                   	push   %ebx
  800825:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800828:	53                   	push   %ebx
  800829:	e8 9c ff ff ff       	call   8007ca <strlen>
  80082e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800831:	ff 75 0c             	pushl  0xc(%ebp)
  800834:	01 d8                	add    %ebx,%eax
  800836:	50                   	push   %eax
  800837:	e8 c5 ff ff ff       	call   800801 <strcpy>
	return dst;
}
  80083c:	89 d8                	mov    %ebx,%eax
  80083e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 75 08             	mov    0x8(%ebp),%esi
  80084b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084e:	89 f3                	mov    %esi,%ebx
  800850:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800853:	89 f2                	mov    %esi,%edx
  800855:	eb 0f                	jmp    800866 <strncpy+0x23>
		*dst++ = *src;
  800857:	83 c2 01             	add    $0x1,%edx
  80085a:	0f b6 01             	movzbl (%ecx),%eax
  80085d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800860:	80 39 01             	cmpb   $0x1,(%ecx)
  800863:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800866:	39 da                	cmp    %ebx,%edx
  800868:	75 ed                	jne    800857 <strncpy+0x14>
	}
	return ret;
}
  80086a:	89 f0                	mov    %esi,%eax
  80086c:	5b                   	pop    %ebx
  80086d:	5e                   	pop    %esi
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	56                   	push   %esi
  800874:	53                   	push   %ebx
  800875:	8b 75 08             	mov    0x8(%ebp),%esi
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80087e:	89 f0                	mov    %esi,%eax
  800880:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800884:	85 c9                	test   %ecx,%ecx
  800886:	75 0b                	jne    800893 <strlcpy+0x23>
  800888:	eb 17                	jmp    8008a1 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088a:	83 c2 01             	add    $0x1,%edx
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800893:	39 d8                	cmp    %ebx,%eax
  800895:	74 07                	je     80089e <strlcpy+0x2e>
  800897:	0f b6 0a             	movzbl (%edx),%ecx
  80089a:	84 c9                	test   %cl,%cl
  80089c:	75 ec                	jne    80088a <strlcpy+0x1a>
		*dst = '\0';
  80089e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a1:	29 f0                	sub    %esi,%eax
}
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b0:	eb 06                	jmp    8008b8 <strcmp+0x11>
		p++, q++;
  8008b2:	83 c1 01             	add    $0x1,%ecx
  8008b5:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008b8:	0f b6 01             	movzbl (%ecx),%eax
  8008bb:	84 c0                	test   %al,%al
  8008bd:	74 04                	je     8008c3 <strcmp+0x1c>
  8008bf:	3a 02                	cmp    (%edx),%al
  8008c1:	74 ef                	je     8008b2 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c3:	0f b6 c0             	movzbl %al,%eax
  8008c6:	0f b6 12             	movzbl (%edx),%edx
  8008c9:	29 d0                	sub    %edx,%eax
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	53                   	push   %ebx
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d7:	89 c3                	mov    %eax,%ebx
  8008d9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008dc:	eb 06                	jmp    8008e4 <strncmp+0x17>
		n--, p++, q++;
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e4:	39 d8                	cmp    %ebx,%eax
  8008e6:	74 16                	je     8008fe <strncmp+0x31>
  8008e8:	0f b6 08             	movzbl (%eax),%ecx
  8008eb:	84 c9                	test   %cl,%cl
  8008ed:	74 04                	je     8008f3 <strncmp+0x26>
  8008ef:	3a 0a                	cmp    (%edx),%cl
  8008f1:	74 eb                	je     8008de <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f3:	0f b6 00             	movzbl (%eax),%eax
  8008f6:	0f b6 12             	movzbl (%edx),%edx
  8008f9:	29 d0                	sub    %edx,%eax
}
  8008fb:	5b                   	pop    %ebx
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    
		return 0;
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800903:	eb f6                	jmp    8008fb <strncmp+0x2e>

00800905 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090f:	0f b6 10             	movzbl (%eax),%edx
  800912:	84 d2                	test   %dl,%dl
  800914:	74 09                	je     80091f <strchr+0x1a>
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 0a                	je     800924 <strchr+0x1f>
	for (; *s; s++)
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	eb f0                	jmp    80090f <strchr+0xa>
			return (char *) s;
	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800930:	eb 03                	jmp    800935 <strfind+0xf>
  800932:	83 c0 01             	add    $0x1,%eax
  800935:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800938:	38 ca                	cmp    %cl,%dl
  80093a:	74 04                	je     800940 <strfind+0x1a>
  80093c:	84 d2                	test   %dl,%dl
  80093e:	75 f2                	jne    800932 <strfind+0xc>
			break;
	return (char *) s;
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	57                   	push   %edi
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 55 08             	mov    0x8(%ebp),%edx
  80094b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80094e:	85 c9                	test   %ecx,%ecx
  800950:	74 12                	je     800964 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800952:	f6 c2 03             	test   $0x3,%dl
  800955:	75 05                	jne    80095c <memset+0x1a>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	74 0f                	je     80096b <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095c:	89 d7                	mov    %edx,%edi
  80095e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800961:	fc                   	cld    
  800962:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800964:	89 d0                	mov    %edx,%eax
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    
		c &= 0xFF;
  80096b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096f:	89 d8                	mov    %ebx,%eax
  800971:	c1 e0 08             	shl    $0x8,%eax
  800974:	89 df                	mov    %ebx,%edi
  800976:	c1 e7 18             	shl    $0x18,%edi
  800979:	89 de                	mov    %ebx,%esi
  80097b:	c1 e6 10             	shl    $0x10,%esi
  80097e:	09 f7                	or     %esi,%edi
  800980:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800982:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800985:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800987:	89 d7                	mov    %edx,%edi
  800989:	fc                   	cld    
  80098a:	f3 ab                	rep stos %eax,%es:(%edi)
  80098c:	eb d6                	jmp    800964 <memset+0x22>

0080098e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 75 0c             	mov    0xc(%ebp),%esi
  800999:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099c:	39 c6                	cmp    %eax,%esi
  80099e:	73 35                	jae    8009d5 <memmove+0x47>
  8009a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a3:	39 c2                	cmp    %eax,%edx
  8009a5:	76 2e                	jbe    8009d5 <memmove+0x47>
		s += n;
		d += n;
  8009a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	89 d6                	mov    %edx,%esi
  8009ac:	09 fe                	or     %edi,%esi
  8009ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b4:	74 0c                	je     8009c2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b6:	83 ef 01             	sub    $0x1,%edi
  8009b9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009bc:	fd                   	std    
  8009bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bf:	fc                   	cld    
  8009c0:	eb 21                	jmp    8009e3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c2:	f6 c1 03             	test   $0x3,%cl
  8009c5:	75 ef                	jne    8009b6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c7:	83 ef 04             	sub    $0x4,%edi
  8009ca:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d0:	fd                   	std    
  8009d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d3:	eb ea                	jmp    8009bf <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d5:	89 f2                	mov    %esi,%edx
  8009d7:	09 c2                	or     %eax,%edx
  8009d9:	f6 c2 03             	test   $0x3,%dl
  8009dc:	74 09                	je     8009e7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009de:	89 c7                	mov    %eax,%edi
  8009e0:	fc                   	cld    
  8009e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e3:	5e                   	pop    %esi
  8009e4:	5f                   	pop    %edi
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	75 f2                	jne    8009de <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ec:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ef:	89 c7                	mov    %eax,%edi
  8009f1:	fc                   	cld    
  8009f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f4:	eb ed                	jmp    8009e3 <memmove+0x55>

008009f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f9:	ff 75 10             	pushl  0x10(%ebp)
  8009fc:	ff 75 0c             	pushl  0xc(%ebp)
  8009ff:	ff 75 08             	pushl  0x8(%ebp)
  800a02:	e8 87 ff ff ff       	call   80098e <memmove>
}
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a14:	89 c6                	mov    %eax,%esi
  800a16:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a19:	39 f0                	cmp    %esi,%eax
  800a1b:	74 1c                	je     800a39 <memcmp+0x30>
		if (*s1 != *s2)
  800a1d:	0f b6 08             	movzbl (%eax),%ecx
  800a20:	0f b6 1a             	movzbl (%edx),%ebx
  800a23:	38 d9                	cmp    %bl,%cl
  800a25:	75 08                	jne    800a2f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a27:	83 c0 01             	add    $0x1,%eax
  800a2a:	83 c2 01             	add    $0x1,%edx
  800a2d:	eb ea                	jmp    800a19 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a2f:	0f b6 c1             	movzbl %cl,%eax
  800a32:	0f b6 db             	movzbl %bl,%ebx
  800a35:	29 d8                	sub    %ebx,%eax
  800a37:	eb 05                	jmp    800a3e <memcmp+0x35>
	}

	return 0;
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a50:	39 d0                	cmp    %edx,%eax
  800a52:	73 09                	jae    800a5d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a54:	38 08                	cmp    %cl,(%eax)
  800a56:	74 05                	je     800a5d <memfind+0x1b>
	for (; s < ends; s++)
  800a58:	83 c0 01             	add    $0x1,%eax
  800a5b:	eb f3                	jmp    800a50 <memfind+0xe>
			break;
	return (void *) s;
}
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6b:	eb 03                	jmp    800a70 <strtol+0x11>
		s++;
  800a6d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a70:	0f b6 01             	movzbl (%ecx),%eax
  800a73:	3c 20                	cmp    $0x20,%al
  800a75:	74 f6                	je     800a6d <strtol+0xe>
  800a77:	3c 09                	cmp    $0x9,%al
  800a79:	74 f2                	je     800a6d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a7b:	3c 2b                	cmp    $0x2b,%al
  800a7d:	74 2e                	je     800aad <strtol+0x4e>
	int neg = 0;
  800a7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a84:	3c 2d                	cmp    $0x2d,%al
  800a86:	74 2f                	je     800ab7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a88:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8e:	75 05                	jne    800a95 <strtol+0x36>
  800a90:	80 39 30             	cmpb   $0x30,(%ecx)
  800a93:	74 2c                	je     800ac1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a95:	85 db                	test   %ebx,%ebx
  800a97:	75 0a                	jne    800aa3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a99:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	74 28                	je     800acb <strtol+0x6c>
		base = 10;
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aab:	eb 50                	jmp    800afd <strtol+0x9e>
		s++;
  800aad:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ab0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab5:	eb d1                	jmp    800a88 <strtol+0x29>
		s++, neg = 1;
  800ab7:	83 c1 01             	add    $0x1,%ecx
  800aba:	bf 01 00 00 00       	mov    $0x1,%edi
  800abf:	eb c7                	jmp    800a88 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac5:	74 0e                	je     800ad5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ac7:	85 db                	test   %ebx,%ebx
  800ac9:	75 d8                	jne    800aa3 <strtol+0x44>
		s++, base = 8;
  800acb:	83 c1 01             	add    $0x1,%ecx
  800ace:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad3:	eb ce                	jmp    800aa3 <strtol+0x44>
		s += 2, base = 16;
  800ad5:	83 c1 02             	add    $0x2,%ecx
  800ad8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800add:	eb c4                	jmp    800aa3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800adf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae2:	89 f3                	mov    %esi,%ebx
  800ae4:	80 fb 19             	cmp    $0x19,%bl
  800ae7:	77 29                	ja     800b12 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae9:	0f be d2             	movsbl %dl,%edx
  800aec:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aef:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af2:	7d 30                	jge    800b24 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800af4:	83 c1 01             	add    $0x1,%ecx
  800af7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800afd:	0f b6 11             	movzbl (%ecx),%edx
  800b00:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b03:	89 f3                	mov    %esi,%ebx
  800b05:	80 fb 09             	cmp    $0x9,%bl
  800b08:	77 d5                	ja     800adf <strtol+0x80>
			dig = *s - '0';
  800b0a:	0f be d2             	movsbl %dl,%edx
  800b0d:	83 ea 30             	sub    $0x30,%edx
  800b10:	eb dd                	jmp    800aef <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b12:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b15:	89 f3                	mov    %esi,%ebx
  800b17:	80 fb 19             	cmp    $0x19,%bl
  800b1a:	77 08                	ja     800b24 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b1c:	0f be d2             	movsbl %dl,%edx
  800b1f:	83 ea 37             	sub    $0x37,%edx
  800b22:	eb cb                	jmp    800aef <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b28:	74 05                	je     800b2f <strtol+0xd0>
		*endptr = (char *) s;
  800b2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	f7 da                	neg    %edx
  800b33:	85 ff                	test   %edi,%edi
  800b35:	0f 45 c2             	cmovne %edx,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	83 ec 1c             	sub    $0x1c,%esp
  800b46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b49:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b4c:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b54:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b57:	8b 75 14             	mov    0x14(%ebp),%esi
  800b5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b60:	74 04                	je     800b66 <syscall+0x29>
  800b62:	85 c0                	test   %eax,%eax
  800b64:	7f 08                	jg     800b6e <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    
  800b6e:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	50                   	push   %eax
  800b75:	52                   	push   %edx
  800b76:	68 a4 18 80 00       	push   $0x8018a4
  800b7b:	6a 23                	push   $0x23
  800b7d:	68 c1 18 80 00       	push   $0x8018c1
  800b82:	e8 1e 07 00 00       	call   8012a5 <_panic>

00800b87 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b8d:	6a 00                	push   $0x0
  800b8f:	6a 00                	push   $0x0
  800b91:	6a 00                	push   $0x0
  800b93:	ff 75 0c             	pushl  0xc(%ebp)
  800b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b99:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	e8 95 ff ff ff       	call   800b3d <syscall>
}
  800ba8:	83 c4 10             	add    $0x10,%esp
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <sys_cgetc>:

int
sys_cgetc(void)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bb3:	6a 00                	push   $0x0
  800bb5:	6a 00                	push   $0x0
  800bb7:	6a 00                	push   $0x0
  800bb9:	6a 00                	push   $0x0
  800bbb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bca:	e8 6e ff ff ff       	call   800b3d <syscall>
}
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bd7:	6a 00                	push   $0x0
  800bd9:	6a 00                	push   $0x0
  800bdb:	6a 00                	push   $0x0
  800bdd:	6a 00                	push   $0x0
  800bdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be2:	ba 01 00 00 00       	mov    $0x1,%edx
  800be7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bec:	e8 4c ff ff ff       	call   800b3d <syscall>
}
  800bf1:	c9                   	leave  
  800bf2:	c3                   	ret    

00800bf3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bf9:	6a 00                	push   $0x0
  800bfb:	6a 00                	push   $0x0
  800bfd:	6a 00                	push   $0x0
  800bff:	6a 00                	push   $0x0
  800c01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c06:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c10:	e8 28 ff ff ff       	call   800b3d <syscall>
}
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <sys_yield>:

void
sys_yield(void)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c1d:	6a 00                	push   $0x0
  800c1f:	6a 00                	push   $0x0
  800c21:	6a 00                	push   $0x0
  800c23:	6a 00                	push   $0x0
  800c25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c34:	e8 04 ff ff ff       	call   800b3d <syscall>
}
  800c39:	83 c4 10             	add    $0x10,%esp
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c44:	6a 00                	push   $0x0
  800c46:	6a 00                	push   $0x0
  800c48:	ff 75 10             	pushl  0x10(%ebp)
  800c4b:	ff 75 0c             	pushl  0xc(%ebp)
  800c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c51:	ba 01 00 00 00       	mov    $0x1,%edx
  800c56:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5b:	e8 dd fe ff ff       	call   800b3d <syscall>
}
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c68:	ff 75 18             	pushl  0x18(%ebp)
  800c6b:	ff 75 14             	pushl  0x14(%ebp)
  800c6e:	ff 75 10             	pushl  0x10(%ebp)
  800c71:	ff 75 0c             	pushl  0xc(%ebp)
  800c74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c77:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c81:	e8 b7 fe ff ff       	call   800b3d <syscall>
}
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c8e:	6a 00                	push   $0x0
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	ff 75 0c             	pushl  0xc(%ebp)
  800c97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c9f:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca4:	e8 94 fe ff ff       	call   800b3d <syscall>
}
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cb1:	6a 00                	push   $0x0
  800cb3:	6a 00                	push   $0x0
  800cb5:	6a 00                	push   $0x0
  800cb7:	ff 75 0c             	pushl  0xc(%ebp)
  800cba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbd:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc2:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc7:	e8 71 fe ff ff       	call   800b3d <syscall>
}
  800ccc:	c9                   	leave  
  800ccd:	c3                   	ret    

00800cce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cd4:	6a 00                	push   $0x0
  800cd6:	6a 00                	push   $0x0
  800cd8:	6a 00                	push   $0x0
  800cda:	ff 75 0c             	pushl  0xc(%ebp)
  800cdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cea:	e8 4e fe ff ff       	call   800b3d <syscall>
}
  800cef:	c9                   	leave  
  800cf0:	c3                   	ret    

00800cf1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cf7:	6a 00                	push   $0x0
  800cf9:	ff 75 14             	pushl  0x14(%ebp)
  800cfc:	ff 75 10             	pushl  0x10(%ebp)
  800cff:	ff 75 0c             	pushl  0xc(%ebp)
  800d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d05:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0f:	e8 29 fe ff ff       	call   800b3d <syscall>
}
  800d14:	c9                   	leave  
  800d15:	c3                   	ret    

00800d16 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d1c:	6a 00                	push   $0x0
  800d1e:	6a 00                	push   $0x0
  800d20:	6a 00                	push   $0x0
  800d22:	6a 00                	push   $0x0
  800d24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d27:	ba 01 00 00 00       	mov    $0x1,%edx
  800d2c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d31:	e8 07 fe ff ff       	call   800b3d <syscall>
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
	int r;

	void *addr = (void*)(pn << PGSHIFT);
  800d3d:	89 d6                	mov    %edx,%esi
  800d3f:	c1 e6 0c             	shl    $0xc,%esi

	pte_t pte = uvpt[pn];
  800d42:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx

	if (!(pte & PTE_P) || !(pte & PTE_U))
  800d49:	89 ca                	mov    %ecx,%edx
  800d4b:	83 e2 05             	and    $0x5,%edx
  800d4e:	83 fa 05             	cmp    $0x5,%edx
  800d51:	75 5a                	jne    800dad <duppage+0x75>
		panic("duppage: copy a non-present or non-user page");

	int perm = PTE_U | PTE_P;
	// Verifico permisos para páginas de IO
	if (pte & (PTE_PCD | PTE_PWT))
  800d53:	89 ca                	mov    %ecx,%edx
  800d55:	83 e2 18             	and    $0x18,%edx
		perm |= PTE_PCD | PTE_PWT;
  800d58:	83 fa 01             	cmp    $0x1,%edx
  800d5b:	19 d2                	sbb    %edx,%edx
  800d5d:	83 e2 e8             	and    $0xffffffe8,%edx
  800d60:	83 c2 1d             	add    $0x1d,%edx


	// Si es de escritura o copy-on-write y NO es de IO
	if ((pte & PTE_W) || (pte & PTE_COW)) {
  800d63:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800d69:	74 68                	je     800dd3 <duppage+0x9b>
		// Mappeo en el hijo la página
		if ((r = sys_page_map(0, addr, envid, addr, perm | PTE_COW)) < 0)
  800d6b:	89 d3                	mov    %edx,%ebx
  800d6d:	80 cf 08             	or     $0x8,%bh
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	53                   	push   %ebx
  800d74:	56                   	push   %esi
  800d75:	50                   	push   %eax
  800d76:	56                   	push   %esi
  800d77:	6a 00                	push   $0x0
  800d79:	e8 e4 fe ff ff       	call   800c62 <sys_page_map>
  800d7e:	83 c4 20             	add    $0x20,%esp
  800d81:	85 c0                	test   %eax,%eax
  800d83:	78 3c                	js     800dc1 <duppage+0x89>
			panic("duppage: sys_page_map on childern COW: %e", r);

		// Cambio los permisos del padre
		if ((r = sys_page_map(0, addr, 0, addr, perm | PTE_COW)) < 0)
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	53                   	push   %ebx
  800d89:	56                   	push   %esi
  800d8a:	6a 00                	push   $0x0
  800d8c:	56                   	push   %esi
  800d8d:	6a 00                	push   $0x0
  800d8f:	e8 ce fe ff ff       	call   800c62 <sys_page_map>
  800d94:	83 c4 20             	add    $0x20,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	79 4d                	jns    800de8 <duppage+0xb0>
			panic("duppage: sys_page_map on parent COW: %e", r);
  800d9b:	50                   	push   %eax
  800d9c:	68 2c 19 80 00       	push   $0x80192c
  800da1:	6a 57                	push   $0x57
  800da3:	68 21 1a 80 00       	push   $0x801a21
  800da8:	e8 f8 04 00 00       	call   8012a5 <_panic>
		panic("duppage: copy a non-present or non-user page");
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	68 d0 18 80 00       	push   $0x8018d0
  800db5:	6a 47                	push   $0x47
  800db7:	68 21 1a 80 00       	push   $0x801a21
  800dbc:	e8 e4 04 00 00       	call   8012a5 <_panic>
			panic("duppage: sys_page_map on childern COW: %e", r);
  800dc1:	50                   	push   %eax
  800dc2:	68 00 19 80 00       	push   $0x801900
  800dc7:	6a 53                	push   $0x53
  800dc9:	68 21 1a 80 00       	push   $0x801a21
  800dce:	e8 d2 04 00 00       	call   8012a5 <_panic>
	} else {
		// Solo mappeo la página de solo lectura
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	52                   	push   %edx
  800dd7:	56                   	push   %esi
  800dd8:	50                   	push   %eax
  800dd9:	56                   	push   %esi
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 81 fe ff ff       	call   800c62 <sys_page_map>
  800de1:	83 c4 20             	add    $0x20,%esp
  800de4:	85 c0                	test   %eax,%eax
  800de6:	78 0c                	js     800df4 <duppage+0xbc>
			panic("duppage: sys_page_map on childern RO: %e", r);
	}

	// panic("duppage not implemented");
	return 0;
}
  800de8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ded:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    
			panic("duppage: sys_page_map on childern RO: %e", r);
  800df4:	50                   	push   %eax
  800df5:	68 54 19 80 00       	push   $0x801954
  800dfa:	6a 5b                	push   $0x5b
  800dfc:	68 21 1a 80 00       	push   $0x801a21
  800e01:	e8 9f 04 00 00       	call   8012a5 <_panic>

00800e06 <dup_or_share>:
 *
 * Hace uso de uvpd y uvpt para chequear permisos.
 */
static void
dup_or_share(envid_t envid, uint32_t pnum, int perm)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 0c             	sub    $0xc,%esp
  800e0f:	89 c7                	mov    %eax,%edi
	int r;
	void *addr = (void*)(pnum << PGSHIFT);

	pte_t pte = uvpt[pnum];
  800e11:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax

	if (!(pte & PTE_P))
  800e18:	a8 01                	test   $0x1,%al
  800e1a:	74 38                	je     800e54 <dup_or_share+0x4e>
  800e1c:	89 cb                	mov    %ecx,%ebx
  800e1e:	89 d6                	mov    %edx,%esi
		return;

	// Filtro permisos
	perm &= (pte & PTE_W);
  800e20:	21 c3                	and    %eax,%ebx
  800e22:	83 e3 02             	and    $0x2,%ebx
	perm &= PTE_SYSCALL;


	if (pte & (PTE_PCD | PTE_PWT))
  800e25:	89 c1                	mov    %eax,%ecx
  800e27:	83 e1 18             	and    $0x18,%ecx
		perm |= PTE_PCD | PTE_PWT;
  800e2a:	89 da                	mov    %ebx,%edx
  800e2c:	83 ca 18             	or     $0x18,%edx
  800e2f:	85 c9                	test   %ecx,%ecx
  800e31:	0f 45 da             	cmovne %edx,%ebx
	void *addr = (void*)(pnum << PGSHIFT);
  800e34:	c1 e6 0c             	shl    $0xc,%esi

	// Si tengo que copiar
	if (!(pte & PTE_W) || (pte & (PTE_PCD | PTE_PWT))) {
  800e37:	83 e0 1a             	and    $0x1a,%eax
  800e3a:	83 f8 02             	cmp    $0x2,%eax
  800e3d:	74 32                	je     800e71 <dup_or_share+0x6b>
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	53                   	push   %ebx
  800e43:	56                   	push   %esi
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	6a 00                	push   $0x0
  800e48:	e8 15 fe ff ff       	call   800c62 <sys_page_map>
  800e4d:	83 c4 20             	add    $0x20,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	78 08                	js     800e5c <dup_or_share+0x56>
			panic("dup_or_share: sys_page_map: %e", r);
		memmove(UTEMP, addr, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap: %e", r);
	}
}
  800e54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    
			panic("dup_or_share: sys_page_map: %e", r);
  800e5c:	50                   	push   %eax
  800e5d:	68 80 19 80 00       	push   $0x801980
  800e62:	68 84 00 00 00       	push   $0x84
  800e67:	68 21 1a 80 00       	push   $0x801a21
  800e6c:	e8 34 04 00 00       	call   8012a5 <_panic>
		if ((r = sys_page_alloc(envid, addr, perm)) < 0)
  800e71:	83 ec 04             	sub    $0x4,%esp
  800e74:	53                   	push   %ebx
  800e75:	56                   	push   %esi
  800e76:	57                   	push   %edi
  800e77:	e8 c2 fd ff ff       	call   800c3e <sys_page_alloc>
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	78 57                	js     800eda <dup_or_share+0xd4>
		if ((r = sys_page_map(envid, addr, 0, UTEMP, perm)) < 0)
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	53                   	push   %ebx
  800e87:	68 00 00 40 00       	push   $0x400000
  800e8c:	6a 00                	push   $0x0
  800e8e:	56                   	push   %esi
  800e8f:	57                   	push   %edi
  800e90:	e8 cd fd ff ff       	call   800c62 <sys_page_map>
  800e95:	83 c4 20             	add    $0x20,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	78 53                	js     800eef <dup_or_share+0xe9>
		memmove(UTEMP, addr, PGSIZE);
  800e9c:	83 ec 04             	sub    $0x4,%esp
  800e9f:	68 00 10 00 00       	push   $0x1000
  800ea4:	56                   	push   %esi
  800ea5:	68 00 00 40 00       	push   $0x400000
  800eaa:	e8 df fa ff ff       	call   80098e <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800eaf:	83 c4 08             	add    $0x8,%esp
  800eb2:	68 00 00 40 00       	push   $0x400000
  800eb7:	6a 00                	push   $0x0
  800eb9:	e8 ca fd ff ff       	call   800c88 <sys_page_unmap>
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	79 8f                	jns    800e54 <dup_or_share+0x4e>
			panic("sys_page_unmap: %e", r);
  800ec5:	50                   	push   %eax
  800ec6:	68 6b 1a 80 00       	push   $0x801a6b
  800ecb:	68 8d 00 00 00       	push   $0x8d
  800ed0:	68 21 1a 80 00       	push   $0x801a21
  800ed5:	e8 cb 03 00 00       	call   8012a5 <_panic>
			panic("dup_or_share: sys_page_alloc: %e", r);
  800eda:	50                   	push   %eax
  800edb:	68 a0 19 80 00       	push   $0x8019a0
  800ee0:	68 88 00 00 00       	push   $0x88
  800ee5:	68 21 1a 80 00       	push   $0x801a21
  800eea:	e8 b6 03 00 00       	call   8012a5 <_panic>
			panic("dup_or_share: sys_page_map: %e", r);
  800eef:	50                   	push   %eax
  800ef0:	68 80 19 80 00       	push   $0x801980
  800ef5:	68 8a 00 00 00       	push   $0x8a
  800efa:	68 21 1a 80 00       	push   $0x801a21
  800eff:	e8 a1 03 00 00       	call   8012a5 <_panic>

00800f04 <pgfault>:
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	53                   	push   %ebx
  800f08:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  800f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0e:	8b 18                	mov    (%eax),%ebx
	pte_t fault_pte = uvpt[((uint32_t)addr) >> PGSHIFT];
  800f10:	89 d8                	mov    %ebx,%eax
  800f12:	c1 e8 0c             	shr    $0xc,%eax
  800f15:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((r = sys_page_alloc(0, PFTEMP, perm)) < 0)
  800f1c:	6a 07                	push   $0x7
  800f1e:	68 00 f0 7f 00       	push   $0x7ff000
  800f23:	6a 00                	push   $0x0
  800f25:	e8 14 fd ff ff       	call   800c3e <sys_page_alloc>
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 51                	js     800f82 <pgfault+0x7e>
	addr = ROUNDDOWN(addr, PGSIZE);
  800f31:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f37:	83 ec 04             	sub    $0x4,%esp
  800f3a:	68 00 10 00 00       	push   $0x1000
  800f3f:	53                   	push   %ebx
  800f40:	68 00 f0 7f 00       	push   $0x7ff000
  800f45:	e8 44 fa ff ff       	call   80098e <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, perm)) < 0)
  800f4a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f51:	53                   	push   %ebx
  800f52:	6a 00                	push   $0x0
  800f54:	68 00 f0 7f 00       	push   $0x7ff000
  800f59:	6a 00                	push   $0x0
  800f5b:	e8 02 fd ff ff       	call   800c62 <sys_page_map>
  800f60:	83 c4 20             	add    $0x20,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	78 2d                	js     800f94 <pgfault+0x90>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f67:	83 ec 08             	sub    $0x8,%esp
  800f6a:	68 00 f0 7f 00       	push   $0x7ff000
  800f6f:	6a 00                	push   $0x0
  800f71:	e8 12 fd ff ff       	call   800c88 <sys_page_unmap>
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 29                	js     800fa6 <pgfault+0xa2>
}
  800f7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    
		panic("pgfault: sys_page_alloc: %e", r);
  800f82:	50                   	push   %eax
  800f83:	68 2c 1a 80 00       	push   $0x801a2c
  800f88:	6a 27                	push   $0x27
  800f8a:	68 21 1a 80 00       	push   $0x801a21
  800f8f:	e8 11 03 00 00       	call   8012a5 <_panic>
		panic("pgfault: sys_page_map: %e", r);
  800f94:	50                   	push   %eax
  800f95:	68 48 1a 80 00       	push   $0x801a48
  800f9a:	6a 2c                	push   $0x2c
  800f9c:	68 21 1a 80 00       	push   $0x801a21
  800fa1:	e8 ff 02 00 00       	call   8012a5 <_panic>
		panic("pgfault: sys_page_unmap: %e", r);
  800fa6:	50                   	push   %eax
  800fa7:	68 62 1a 80 00       	push   $0x801a62
  800fac:	6a 2f                	push   $0x2f
  800fae:	68 21 1a 80 00       	push   $0x801a21
  800fb3:	e8 ed 02 00 00       	call   8012a5 <_panic>

00800fb8 <fork_v0>:
 *  	-- Para ello se utiliza la funcion dup_or_share()
 *  	-- Se copian todas las paginas desde 0 hasta UTOP
 */
envid_t
fork_v0(void)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	57                   	push   %edi
  800fbc:	56                   	push   %esi
  800fbd:	53                   	push   %ebx
  800fbe:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fc1:	b8 07 00 00 00       	mov    $0x7,%eax
  800fc6:	cd 30                	int    $0x30
  800fc8:	89 c7                	mov    %eax,%edi
	envid_t envid = sys_exofork();
	if (envid < 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	78 24                	js     800ff2 <fork_v0+0x3a>
  800fce:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);
	int perm = PTE_P | PTE_U | PTE_W;

	for (pnum = 0; pnum < pnum_end; pnum++) {
  800fd0:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	75 39                	jne    801012 <fork_v0+0x5a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd9:	e8 15 fc ff ff       	call   800bf3 <sys_getenvid>
  800fde:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe3:	c1 e0 07             	shl    $0x7,%eax
  800fe6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800feb:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  800ff0:	eb 56                	jmp    801048 <fork_v0+0x90>
		panic("sys_exofork: %e", envid);
  800ff2:	50                   	push   %eax
  800ff3:	68 7e 1a 80 00       	push   $0x801a7e
  800ff8:	68 a2 00 00 00       	push   $0xa2
  800ffd:	68 21 1a 80 00       	push   $0x801a21
  801002:	e8 9e 02 00 00       	call   8012a5 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  801007:	83 c3 01             	add    $0x1,%ebx
  80100a:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  801010:	74 24                	je     801036 <fork_v0+0x7e>
		pde_t pde = uvpd[pnum >> 10];
  801012:	89 d8                	mov    %ebx,%eax
  801014:	c1 e8 0a             	shr    $0xa,%eax
  801017:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  80101e:	83 e0 05             	and    $0x5,%eax
  801021:	83 f8 05             	cmp    $0x5,%eax
  801024:	75 e1                	jne    801007 <fork_v0+0x4f>
			continue;
		dup_or_share(envid, pnum, perm);
  801026:	b9 07 00 00 00       	mov    $0x7,%ecx
  80102b:	89 da                	mov    %ebx,%edx
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	e8 d2 fd ff ff       	call   800e06 <dup_or_share>
  801034:	eb d1                	jmp    801007 <fork_v0+0x4f>
	}


	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801036:	83 ec 08             	sub    $0x8,%esp
  801039:	6a 02                	push   $0x2
  80103b:	57                   	push   %edi
  80103c:	e8 6a fc ff ff       	call   800cab <sys_env_set_status>
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	78 0a                	js     801052 <fork_v0+0x9a>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  801048:	89 f8                	mov    %edi,%eax
  80104a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  801052:	50                   	push   %eax
  801053:	68 8e 1a 80 00       	push   $0x801a8e
  801058:	68 b8 00 00 00       	push   $0xb8
  80105d:	68 21 1a 80 00       	push   $0x801a21
  801062:	e8 3e 02 00 00       	call   8012a5 <_panic>

00801067 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	57                   	push   %edi
  80106b:	56                   	push   %esi
  80106c:	53                   	push   %ebx
  80106d:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  801070:	68 04 0f 80 00       	push   $0x800f04
  801075:	e8 71 02 00 00       	call   8012eb <set_pgfault_handler>
  80107a:	b8 07 00 00 00       	mov    $0x7,%eax
  80107f:	cd 30                	int    $0x30
  801081:	89 c7                	mov    %eax,%edi

	envid_t envid = sys_exofork();
	if (envid < 0)
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	78 27                	js     8010b1 <fork+0x4a>
  80108a:	89 c6                	mov    %eax,%esi
	// Parent
	uint32_t pnum = 0;
	uint32_t pnum_end = (UTOP >> PGSHIFT);

	// Handle all pages below UTOP
	for (pnum = 0; pnum < pnum_end; pnum++) {
  80108c:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  801091:	85 c0                	test   %eax,%eax
  801093:	75 44                	jne    8010d9 <fork+0x72>
		thisenv = &envs[ENVX(sys_getenvid())];
  801095:	e8 59 fb ff ff       	call   800bf3 <sys_getenvid>
  80109a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80109f:	c1 e0 07             	shl    $0x7,%eax
  8010a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a7:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  8010ac:	e9 98 00 00 00       	jmp    801149 <fork+0xe2>
		panic("sys_exofork: %e", envid);
  8010b1:	50                   	push   %eax
  8010b2:	68 7e 1a 80 00       	push   $0x801a7e
  8010b7:	68 d6 00 00 00       	push   $0xd6
  8010bc:	68 21 1a 80 00       	push   $0x801a21
  8010c1:	e8 df 01 00 00       	call   8012a5 <_panic>
	for (pnum = 0; pnum < pnum_end; pnum++) {
  8010c6:	83 c3 01             	add    $0x1,%ebx
  8010c9:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8010cf:	77 36                	ja     801107 <fork+0xa0>
		if (pnum == ((UXSTACKTOP >> PGSHIFT) - 1))
  8010d1:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8010d7:	74 ed                	je     8010c6 <fork+0x5f>
			continue;

		pde_t pde = uvpd[pnum >> 10];
  8010d9:	89 d8                	mov    %ebx,%eax
  8010db:	c1 e8 0a             	shr    $0xa,%eax
  8010de:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		if (!(pde & PTE_P) || !(pde & PTE_U))
  8010e5:	83 e0 05             	and    $0x5,%eax
  8010e8:	83 f8 05             	cmp    $0x5,%eax
  8010eb:	75 d9                	jne    8010c6 <fork+0x5f>
			continue;

		pte_t pte = uvpt[pnum];
  8010ed:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		if (!(pte & PTE_P) || !(pte & PTE_U))
  8010f4:	83 e0 05             	and    $0x5,%eax
  8010f7:	83 f8 05             	cmp    $0x5,%eax
  8010fa:	75 ca                	jne    8010c6 <fork+0x5f>
			continue;
		duppage(envid, pnum);
  8010fc:	89 da                	mov    %ebx,%edx
  8010fe:	89 f0                	mov    %esi,%eax
  801100:	e8 33 fc ff ff       	call   800d38 <duppage>
  801105:	eb bf                	jmp    8010c6 <fork+0x5f>
	}

	uint32_t exstk = (UXSTACKTOP - PGSIZE);
	int r = sys_page_alloc(envid, (void*)exstk, PTE_U | PTE_P | PTE_W);
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	6a 07                	push   $0x7
  80110c:	68 00 f0 bf ee       	push   $0xeebff000
  801111:	57                   	push   %edi
  801112:	e8 27 fb ff ff       	call   800c3e <sys_page_alloc>
	if (r < 0)
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 35                	js     801153 <fork+0xec>
		panic("fork: sys_page_alloc of exception stk: %e", r);
	r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80111e:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801123:	8b 40 68             	mov    0x68(%eax),%eax
  801126:	83 ec 08             	sub    $0x8,%esp
  801129:	50                   	push   %eax
  80112a:	57                   	push   %edi
  80112b:	e8 9e fb ff ff       	call   800cce <sys_env_set_pgfault_upcall>
	if (r < 0)
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	78 31                	js     801168 <fork+0x101>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801137:	83 ec 08             	sub    $0x8,%esp
  80113a:	6a 02                	push   $0x2
  80113c:	57                   	push   %edi
  80113d:	e8 69 fb ff ff       	call   800cab <sys_env_set_status>
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	85 c0                	test   %eax,%eax
  801147:	78 34                	js     80117d <fork+0x116>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  801149:	89 f8                	mov    %edi,%eax
  80114b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    
		panic("fork: sys_page_alloc of exception stk: %e", r);
  801153:	50                   	push   %eax
  801154:	68 c4 19 80 00       	push   $0x8019c4
  801159:	68 f3 00 00 00       	push   $0xf3
  80115e:	68 21 1a 80 00       	push   $0x801a21
  801163:	e8 3d 01 00 00       	call   8012a5 <_panic>
		panic("fork: sys_env_set_pgfault_upcall on childern: %e", r);
  801168:	50                   	push   %eax
  801169:	68 f0 19 80 00       	push   $0x8019f0
  80116e:	68 f6 00 00 00       	push   $0xf6
  801173:	68 21 1a 80 00       	push   $0x801a21
  801178:	e8 28 01 00 00       	call   8012a5 <_panic>
		panic("sys_env_set_status: %e", r);
  80117d:	50                   	push   %eax
  80117e:	68 8e 1a 80 00       	push   $0x801a8e
  801183:	68 f9 00 00 00       	push   $0xf9
  801188:	68 21 1a 80 00       	push   $0x801a21
  80118d:	e8 13 01 00 00       	call   8012a5 <_panic>

00801192 <sfork>:

// Challenge!
int
sfork(void)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801198:	68 a5 1a 80 00       	push   $0x801aa5
  80119d:	68 02 01 00 00       	push   $0x102
  8011a2:	68 21 1a 80 00       	push   $0x801a21
  8011a7:	e8 f9 00 00 00       	call   8012a5 <_panic>

008011ac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	56                   	push   %esi
  8011b0:	53                   	push   %ebx
  8011b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int err = sys_ipc_recv(pg);
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	ff 75 0c             	pushl  0xc(%ebp)
  8011bd:	e8 54 fb ff ff       	call   800d16 <sys_ipc_recv>

	if (from_env_store)
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	85 f6                	test   %esi,%esi
  8011c7:	74 14                	je     8011dd <ipc_recv+0x31>
		*from_env_store = (!err) ? thisenv->env_ipc_from : 0;
  8011c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	75 09                	jne    8011db <ipc_recv+0x2f>
  8011d2:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  8011d8:	8b 52 78             	mov    0x78(%edx),%edx
  8011db:	89 16                	mov    %edx,(%esi)

	if (perm_store)
  8011dd:	85 db                	test   %ebx,%ebx
  8011df:	74 14                	je     8011f5 <ipc_recv+0x49>
		*perm_store = (!err) ? thisenv->env_ipc_perm : 0;
  8011e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	75 09                	jne    8011f3 <ipc_recv+0x47>
  8011ea:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  8011f0:	8b 52 7c             	mov    0x7c(%edx),%edx
  8011f3:	89 13                	mov    %edx,(%ebx)

	if (!err) err = thisenv->env_ipc_value;
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	75 08                	jne    801201 <ipc_recv+0x55>
  8011f9:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8011fe:	8b 40 74             	mov    0x74(%eax),%eax
	
	return err;
}
  801201:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 0c             	sub    $0xc,%esp
  801211:	8b 75 0c             	mov    0xc(%ebp),%esi
  801214:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801217:	8b 7d 14             	mov    0x14(%ebp),%edi
	if (!pg)
  80121a:	85 db                	test   %ebx,%ebx
		pg = (void*) UTOP;
  80121c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801221:	0f 44 d8             	cmove  %eax,%ebx
	int r = sys_ipc_try_send(to_env, val, pg, perm);
  801224:	57                   	push   %edi
  801225:	53                   	push   %ebx
  801226:	56                   	push   %esi
  801227:	ff 75 08             	pushl  0x8(%ebp)
  80122a:	e8 c2 fa ff ff       	call   800cf1 <sys_ipc_try_send>
	while (r == -E_IPC_NOT_RECV) {
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	eb 13                	jmp    801247 <ipc_send+0x3f>
		sys_yield();
  801234:	e8 de f9 ff ff       	call   800c17 <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801239:	57                   	push   %edi
  80123a:	53                   	push   %ebx
  80123b:	56                   	push   %esi
  80123c:	ff 75 08             	pushl  0x8(%ebp)
  80123f:	e8 ad fa ff ff       	call   800cf1 <sys_ipc_try_send>
  801244:	83 c4 10             	add    $0x10,%esp
	while (r == -E_IPC_NOT_RECV) {
  801247:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80124a:	74 e8                	je     801234 <ipc_send+0x2c>
	}

	if (r < 0) panic("ipc_send: %e", r);
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 08                	js     801258 <ipc_send+0x50>
}
  801250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801253:	5b                   	pop    %ebx
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    
	if (r < 0) panic("ipc_send: %e", r);
  801258:	50                   	push   %eax
  801259:	68 bb 1a 80 00       	push   $0x801abb
  80125e:	6a 39                	push   $0x39
  801260:	68 c8 1a 80 00       	push   $0x801ac8
  801265:	e8 3b 00 00 00       	call   8012a5 <_panic>

0080126a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801275:	89 c2                	mov    %eax,%edx
  801277:	c1 e2 07             	shl    $0x7,%edx
  80127a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801280:	8b 52 50             	mov    0x50(%edx),%edx
  801283:	39 ca                	cmp    %ecx,%edx
  801285:	74 11                	je     801298 <ipc_find_env+0x2e>
	for (i = 0; i < NENV; i++)
  801287:	83 c0 01             	add    $0x1,%eax
  80128a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80128f:	75 e4                	jne    801275 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	eb 0b                	jmp    8012a3 <ipc_find_env+0x39>
			return envs[i].env_id;
  801298:	c1 e0 07             	shl    $0x7,%eax
  80129b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012a0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	56                   	push   %esi
  8012a9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8012aa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012ad:	8b 35 08 20 80 00    	mov    0x802008,%esi
  8012b3:	e8 3b f9 ff ff       	call   800bf3 <sys_getenvid>
  8012b8:	83 ec 0c             	sub    $0xc,%esp
  8012bb:	ff 75 0c             	pushl  0xc(%ebp)
  8012be:	ff 75 08             	pushl  0x8(%ebp)
  8012c1:	56                   	push   %esi
  8012c2:	50                   	push   %eax
  8012c3:	68 d4 1a 80 00       	push   $0x801ad4
  8012c8:	e8 cf ef ff ff       	call   80029c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012cd:	83 c4 18             	add    $0x18,%esp
  8012d0:	53                   	push   %ebx
  8012d1:	ff 75 10             	pushl  0x10(%ebp)
  8012d4:	e8 72 ef ff ff       	call   80024b <vcprintf>
	cprintf("\n");
  8012d9:	c7 04 24 ba 15 80 00 	movl   $0x8015ba,(%esp)
  8012e0:	e8 b7 ef ff ff       	call   80029c <cprintf>
  8012e5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012e8:	cc                   	int3   
  8012e9:	eb fd                	jmp    8012e8 <_panic+0x43>

008012eb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012f1:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  8012f8:	74 0a                	je     801304 <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fd:	a3 10 20 80 00       	mov    %eax,0x802010
}
  801302:	c9                   	leave  
  801303:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  801304:	83 ec 04             	sub    $0x4,%esp
  801307:	6a 07                	push   $0x7
  801309:	68 00 f0 bf ee       	push   $0xeebff000
  80130e:	6a 00                	push   $0x0
  801310:	e8 29 f9 ff ff       	call   800c3e <sys_page_alloc>
		if (r < 0) return;
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 e6                	js     801302 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	68 34 13 80 00       	push   $0x801334
  801324:	6a 00                	push   $0x0
  801326:	e8 a3 f9 ff ff       	call   800cce <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	79 c8                	jns    8012fa <set_pgfault_handler+0xf>
  801332:	eb ce                	jmp    801302 <set_pgfault_handler+0x17>

00801334 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801334:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801335:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  80133a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80133c:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  80133f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  801343:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  801347:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  80134a:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  80134c:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  801350:	58                   	pop    %eax
	popl %eax
  801351:	58                   	pop    %eax
	popal
  801352:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  801353:	83 c4 04             	add    $0x4,%esp
	popfl
  801356:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  801357:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  801358:	c3                   	ret    
  801359:	66 90                	xchg   %ax,%ax
  80135b:	66 90                	xchg   %ax,%ax
  80135d:	66 90                	xchg   %ax,%ax
  80135f:	90                   	nop

00801360 <__udivdi3>:
  801360:	55                   	push   %ebp
  801361:	57                   	push   %edi
  801362:	56                   	push   %esi
  801363:	53                   	push   %ebx
  801364:	83 ec 1c             	sub    $0x1c,%esp
  801367:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80136b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80136f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801373:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801377:	85 d2                	test   %edx,%edx
  801379:	75 35                	jne    8013b0 <__udivdi3+0x50>
  80137b:	39 f3                	cmp    %esi,%ebx
  80137d:	0f 87 bd 00 00 00    	ja     801440 <__udivdi3+0xe0>
  801383:	85 db                	test   %ebx,%ebx
  801385:	89 d9                	mov    %ebx,%ecx
  801387:	75 0b                	jne    801394 <__udivdi3+0x34>
  801389:	b8 01 00 00 00       	mov    $0x1,%eax
  80138e:	31 d2                	xor    %edx,%edx
  801390:	f7 f3                	div    %ebx
  801392:	89 c1                	mov    %eax,%ecx
  801394:	31 d2                	xor    %edx,%edx
  801396:	89 f0                	mov    %esi,%eax
  801398:	f7 f1                	div    %ecx
  80139a:	89 c6                	mov    %eax,%esi
  80139c:	89 e8                	mov    %ebp,%eax
  80139e:	89 f7                	mov    %esi,%edi
  8013a0:	f7 f1                	div    %ecx
  8013a2:	89 fa                	mov    %edi,%edx
  8013a4:	83 c4 1c             	add    $0x1c,%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	5f                   	pop    %edi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    
  8013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	39 f2                	cmp    %esi,%edx
  8013b2:	77 7c                	ja     801430 <__udivdi3+0xd0>
  8013b4:	0f bd fa             	bsr    %edx,%edi
  8013b7:	83 f7 1f             	xor    $0x1f,%edi
  8013ba:	0f 84 98 00 00 00    	je     801458 <__udivdi3+0xf8>
  8013c0:	89 f9                	mov    %edi,%ecx
  8013c2:	b8 20 00 00 00       	mov    $0x20,%eax
  8013c7:	29 f8                	sub    %edi,%eax
  8013c9:	d3 e2                	shl    %cl,%edx
  8013cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013cf:	89 c1                	mov    %eax,%ecx
  8013d1:	89 da                	mov    %ebx,%edx
  8013d3:	d3 ea                	shr    %cl,%edx
  8013d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013d9:	09 d1                	or     %edx,%ecx
  8013db:	89 f2                	mov    %esi,%edx
  8013dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013e1:	89 f9                	mov    %edi,%ecx
  8013e3:	d3 e3                	shl    %cl,%ebx
  8013e5:	89 c1                	mov    %eax,%ecx
  8013e7:	d3 ea                	shr    %cl,%edx
  8013e9:	89 f9                	mov    %edi,%ecx
  8013eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013ef:	d3 e6                	shl    %cl,%esi
  8013f1:	89 eb                	mov    %ebp,%ebx
  8013f3:	89 c1                	mov    %eax,%ecx
  8013f5:	d3 eb                	shr    %cl,%ebx
  8013f7:	09 de                	or     %ebx,%esi
  8013f9:	89 f0                	mov    %esi,%eax
  8013fb:	f7 74 24 08          	divl   0x8(%esp)
  8013ff:	89 d6                	mov    %edx,%esi
  801401:	89 c3                	mov    %eax,%ebx
  801403:	f7 64 24 0c          	mull   0xc(%esp)
  801407:	39 d6                	cmp    %edx,%esi
  801409:	72 0c                	jb     801417 <__udivdi3+0xb7>
  80140b:	89 f9                	mov    %edi,%ecx
  80140d:	d3 e5                	shl    %cl,%ebp
  80140f:	39 c5                	cmp    %eax,%ebp
  801411:	73 5d                	jae    801470 <__udivdi3+0x110>
  801413:	39 d6                	cmp    %edx,%esi
  801415:	75 59                	jne    801470 <__udivdi3+0x110>
  801417:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80141a:	31 ff                	xor    %edi,%edi
  80141c:	89 fa                	mov    %edi,%edx
  80141e:	83 c4 1c             	add    $0x1c,%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    
  801426:	8d 76 00             	lea    0x0(%esi),%esi
  801429:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801430:	31 ff                	xor    %edi,%edi
  801432:	31 c0                	xor    %eax,%eax
  801434:	89 fa                	mov    %edi,%edx
  801436:	83 c4 1c             	add    $0x1c,%esp
  801439:	5b                   	pop    %ebx
  80143a:	5e                   	pop    %esi
  80143b:	5f                   	pop    %edi
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    
  80143e:	66 90                	xchg   %ax,%ax
  801440:	31 ff                	xor    %edi,%edi
  801442:	89 e8                	mov    %ebp,%eax
  801444:	89 f2                	mov    %esi,%edx
  801446:	f7 f3                	div    %ebx
  801448:	89 fa                	mov    %edi,%edx
  80144a:	83 c4 1c             	add    $0x1c,%esp
  80144d:	5b                   	pop    %ebx
  80144e:	5e                   	pop    %esi
  80144f:	5f                   	pop    %edi
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    
  801452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801458:	39 f2                	cmp    %esi,%edx
  80145a:	72 06                	jb     801462 <__udivdi3+0x102>
  80145c:	31 c0                	xor    %eax,%eax
  80145e:	39 eb                	cmp    %ebp,%ebx
  801460:	77 d2                	ja     801434 <__udivdi3+0xd4>
  801462:	b8 01 00 00 00       	mov    $0x1,%eax
  801467:	eb cb                	jmp    801434 <__udivdi3+0xd4>
  801469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801470:	89 d8                	mov    %ebx,%eax
  801472:	31 ff                	xor    %edi,%edi
  801474:	eb be                	jmp    801434 <__udivdi3+0xd4>
  801476:	66 90                	xchg   %ax,%ax
  801478:	66 90                	xchg   %ax,%ax
  80147a:	66 90                	xchg   %ax,%ax
  80147c:	66 90                	xchg   %ax,%ax
  80147e:	66 90                	xchg   %ax,%ax

00801480 <__umoddi3>:
  801480:	55                   	push   %ebp
  801481:	57                   	push   %edi
  801482:	56                   	push   %esi
  801483:	53                   	push   %ebx
  801484:	83 ec 1c             	sub    $0x1c,%esp
  801487:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80148b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80148f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801493:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801497:	85 ed                	test   %ebp,%ebp
  801499:	89 f0                	mov    %esi,%eax
  80149b:	89 da                	mov    %ebx,%edx
  80149d:	75 19                	jne    8014b8 <__umoddi3+0x38>
  80149f:	39 df                	cmp    %ebx,%edi
  8014a1:	0f 86 b1 00 00 00    	jbe    801558 <__umoddi3+0xd8>
  8014a7:	f7 f7                	div    %edi
  8014a9:	89 d0                	mov    %edx,%eax
  8014ab:	31 d2                	xor    %edx,%edx
  8014ad:	83 c4 1c             	add    $0x1c,%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    
  8014b5:	8d 76 00             	lea    0x0(%esi),%esi
  8014b8:	39 dd                	cmp    %ebx,%ebp
  8014ba:	77 f1                	ja     8014ad <__umoddi3+0x2d>
  8014bc:	0f bd cd             	bsr    %ebp,%ecx
  8014bf:	83 f1 1f             	xor    $0x1f,%ecx
  8014c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014c6:	0f 84 b4 00 00 00    	je     801580 <__umoddi3+0x100>
  8014cc:	b8 20 00 00 00       	mov    $0x20,%eax
  8014d1:	89 c2                	mov    %eax,%edx
  8014d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014d7:	29 c2                	sub    %eax,%edx
  8014d9:	89 c1                	mov    %eax,%ecx
  8014db:	89 f8                	mov    %edi,%eax
  8014dd:	d3 e5                	shl    %cl,%ebp
  8014df:	89 d1                	mov    %edx,%ecx
  8014e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014e5:	d3 e8                	shr    %cl,%eax
  8014e7:	09 c5                	or     %eax,%ebp
  8014e9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014ed:	89 c1                	mov    %eax,%ecx
  8014ef:	d3 e7                	shl    %cl,%edi
  8014f1:	89 d1                	mov    %edx,%ecx
  8014f3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014f7:	89 df                	mov    %ebx,%edi
  8014f9:	d3 ef                	shr    %cl,%edi
  8014fb:	89 c1                	mov    %eax,%ecx
  8014fd:	89 f0                	mov    %esi,%eax
  8014ff:	d3 e3                	shl    %cl,%ebx
  801501:	89 d1                	mov    %edx,%ecx
  801503:	89 fa                	mov    %edi,%edx
  801505:	d3 e8                	shr    %cl,%eax
  801507:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80150c:	09 d8                	or     %ebx,%eax
  80150e:	f7 f5                	div    %ebp
  801510:	d3 e6                	shl    %cl,%esi
  801512:	89 d1                	mov    %edx,%ecx
  801514:	f7 64 24 08          	mull   0x8(%esp)
  801518:	39 d1                	cmp    %edx,%ecx
  80151a:	89 c3                	mov    %eax,%ebx
  80151c:	89 d7                	mov    %edx,%edi
  80151e:	72 06                	jb     801526 <__umoddi3+0xa6>
  801520:	75 0e                	jne    801530 <__umoddi3+0xb0>
  801522:	39 c6                	cmp    %eax,%esi
  801524:	73 0a                	jae    801530 <__umoddi3+0xb0>
  801526:	2b 44 24 08          	sub    0x8(%esp),%eax
  80152a:	19 ea                	sbb    %ebp,%edx
  80152c:	89 d7                	mov    %edx,%edi
  80152e:	89 c3                	mov    %eax,%ebx
  801530:	89 ca                	mov    %ecx,%edx
  801532:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801537:	29 de                	sub    %ebx,%esi
  801539:	19 fa                	sbb    %edi,%edx
  80153b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80153f:	89 d0                	mov    %edx,%eax
  801541:	d3 e0                	shl    %cl,%eax
  801543:	89 d9                	mov    %ebx,%ecx
  801545:	d3 ee                	shr    %cl,%esi
  801547:	d3 ea                	shr    %cl,%edx
  801549:	09 f0                	or     %esi,%eax
  80154b:	83 c4 1c             	add    $0x1c,%esp
  80154e:	5b                   	pop    %ebx
  80154f:	5e                   	pop    %esi
  801550:	5f                   	pop    %edi
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    
  801553:	90                   	nop
  801554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801558:	85 ff                	test   %edi,%edi
  80155a:	89 f9                	mov    %edi,%ecx
  80155c:	75 0b                	jne    801569 <__umoddi3+0xe9>
  80155e:	b8 01 00 00 00       	mov    $0x1,%eax
  801563:	31 d2                	xor    %edx,%edx
  801565:	f7 f7                	div    %edi
  801567:	89 c1                	mov    %eax,%ecx
  801569:	89 d8                	mov    %ebx,%eax
  80156b:	31 d2                	xor    %edx,%edx
  80156d:	f7 f1                	div    %ecx
  80156f:	89 f0                	mov    %esi,%eax
  801571:	f7 f1                	div    %ecx
  801573:	e9 31 ff ff ff       	jmp    8014a9 <__umoddi3+0x29>
  801578:	90                   	nop
  801579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801580:	39 dd                	cmp    %ebx,%ebp
  801582:	72 08                	jb     80158c <__umoddi3+0x10c>
  801584:	39 f7                	cmp    %esi,%edi
  801586:	0f 87 21 ff ff ff    	ja     8014ad <__umoddi3+0x2d>
  80158c:	89 da                	mov    %ebx,%edx
  80158e:	89 f0                	mov    %esi,%eax
  801590:	29 f8                	sub    %edi,%eax
  801592:	19 ea                	sbb    %ebp,%edx
  801594:	e9 14 ff ff ff       	jmp    8014ad <__umoddi3+0x2d>
