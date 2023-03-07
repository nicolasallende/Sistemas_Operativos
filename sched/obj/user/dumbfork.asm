
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 a3 01 00 00       	call   8001d4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 63 0c 00 00       	call   800cad <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	78 4a                	js     80009b <duppage+0x68>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800051:	83 ec 0c             	sub    $0xc,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 40 00       	push   $0x400000
  80005b:	6a 00                	push   $0x0
  80005d:	53                   	push   %ebx
  80005e:	56                   	push   %esi
  80005f:	e8 6d 0c 00 00       	call   800cd1 <sys_page_map>
  800064:	83 c4 20             	add    $0x20,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	78 42                	js     8000ad <duppage+0x7a>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006b:	83 ec 04             	sub    $0x4,%esp
  80006e:	68 00 10 00 00       	push   $0x1000
  800073:	53                   	push   %ebx
  800074:	68 00 00 40 00       	push   $0x400000
  800079:	e8 7f 09 00 00       	call   8009fd <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80007e:	83 c4 08             	add    $0x8,%esp
  800081:	68 00 00 40 00       	push   $0x400000
  800086:	6a 00                	push   $0x0
  800088:	e8 6a 0c 00 00       	call   800cf7 <sys_page_unmap>
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	85 c0                	test   %eax,%eax
  800092:	78 2b                	js     8000bf <duppage+0x8c>
		panic("sys_page_unmap: %e", r);
}
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80009b:	50                   	push   %eax
  80009c:	68 00 10 80 00       	push   $0x801000
  8000a1:	6a 20                	push   $0x20
  8000a3:	68 13 10 80 00       	push   $0x801013
  8000a8:	e8 83 01 00 00       	call   800230 <_panic>
		panic("sys_page_map: %e", r);
  8000ad:	50                   	push   %eax
  8000ae:	68 23 10 80 00       	push   $0x801023
  8000b3:	6a 22                	push   $0x22
  8000b5:	68 13 10 80 00       	push   $0x801013
  8000ba:	e8 71 01 00 00       	call   800230 <_panic>
		panic("sys_page_unmap: %e", r);
  8000bf:	50                   	push   %eax
  8000c0:	68 34 10 80 00       	push   $0x801034
  8000c5:	6a 25                	push   $0x25
  8000c7:	68 13 10 80 00       	push   $0x801013
  8000cc:	e8 5f 01 00 00       	call   800230 <_panic>

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	78 0f                	js     8000f5 <dumbfork+0x24>
  8000e6:	89 c6                	mov    %eax,%esi
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	74 1b                	je     800107 <dumbfork+0x36>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8000ec:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8000f3:	eb 3f                	jmp    800134 <dumbfork+0x63>
		panic("sys_exofork: %e", envid);
  8000f5:	50                   	push   %eax
  8000f6:	68 47 10 80 00       	push   $0x801047
  8000fb:	6a 37                	push   $0x37
  8000fd:	68 13 10 80 00       	push   $0x801013
  800102:	e8 29 01 00 00       	call   800230 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  800107:	e8 56 0b 00 00       	call   800c62 <sys_getenvid>
  80010c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800111:	c1 e0 07             	shl    $0x7,%eax
  800114:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800119:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80011e:	eb 43                	jmp    800163 <dumbfork+0x92>
		duppage(envid, addr);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	52                   	push   %edx
  800124:	56                   	push   %esi
  800125:	e8 09 ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800137:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  80013d:	72 e1                	jb     800120 <dumbfork+0x4f>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80013f:	83 ec 08             	sub    $0x8,%esp
  800142:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800145:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014a:	50                   	push   %eax
  80014b:	53                   	push   %ebx
  80014c:	e8 e2 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800151:	83 c4 08             	add    $0x8,%esp
  800154:	6a 02                	push   $0x2
  800156:	53                   	push   %ebx
  800157:	e8 be 0b 00 00       	call   800d1a <sys_env_set_status>
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	85 c0                	test   %eax,%eax
  800161:	78 09                	js     80016c <dumbfork+0x9b>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800163:	89 d8                	mov    %ebx,%eax
  800165:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  80016c:	50                   	push   %eax
  80016d:	68 57 10 80 00       	push   $0x801057
  800172:	6a 4c                	push   $0x4c
  800174:	68 13 10 80 00       	push   $0x801013
  800179:	e8 b2 00 00 00       	call   800230 <_panic>

0080017e <umain>:
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800187:	e8 45 ff ff ff       	call   8000d1 <dumbfork>
  80018c:	89 c7                	mov    %eax,%edi
  80018e:	85 c0                	test   %eax,%eax
  800190:	be 6e 10 80 00       	mov    $0x80106e,%esi
  800195:	b8 75 10 80 00       	mov    $0x801075,%eax
  80019a:	0f 44 f0             	cmove  %eax,%esi
	for (i = 0; i < (who ? 10 : 20); i++) {
  80019d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a2:	eb 1f                	jmp    8001c3 <umain+0x45>
  8001a4:	83 fb 13             	cmp    $0x13,%ebx
  8001a7:	7f 23                	jg     8001cc <umain+0x4e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 7b 10 80 00       	push   $0x80107b
  8001b3:	e8 53 01 00 00       	call   80030b <cprintf>
		sys_yield();
  8001b8:	e8 c9 0a 00 00       	call   800c86 <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 dd                	je     8001a4 <umain+0x26>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x2b>
}
  8001cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	5f                   	pop    %edi
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    

008001d4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8001df:	e8 7e 0a 00 00       	call   800c62 <sys_getenvid>
	if (id >= 0)
  8001e4:	85 c0                	test   %eax,%eax
  8001e6:	78 12                	js     8001fa <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8001e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ed:	c1 e0 07             	shl    $0x7,%eax
  8001f0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f5:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fa:	85 db                	test   %ebx,%ebx
  8001fc:	7e 07                	jle    800205 <libmain+0x31>
		binaryname = argv[0];
  8001fe:	8b 06                	mov    (%esi),%eax
  800200:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	e8 6f ff ff ff       	call   80017e <umain>

	// exit gracefully
	exit();
  80020f:	e8 0a 00 00 00       	call   80021e <exit>
}
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800224:	6a 00                	push   $0x0
  800226:	e8 15 0a 00 00       	call   800c40 <sys_env_destroy>
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800235:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800238:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80023e:	e8 1f 0a 00 00       	call   800c62 <sys_getenvid>
  800243:	83 ec 0c             	sub    $0xc,%esp
  800246:	ff 75 0c             	pushl  0xc(%ebp)
  800249:	ff 75 08             	pushl  0x8(%ebp)
  80024c:	56                   	push   %esi
  80024d:	50                   	push   %eax
  80024e:	68 98 10 80 00       	push   $0x801098
  800253:	e8 b3 00 00 00       	call   80030b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800258:	83 c4 18             	add    $0x18,%esp
  80025b:	53                   	push   %ebx
  80025c:	ff 75 10             	pushl  0x10(%ebp)
  80025f:	e8 56 00 00 00       	call   8002ba <vcprintf>
	cprintf("\n");
  800264:	c7 04 24 8b 10 80 00 	movl   $0x80108b,(%esp)
  80026b:	e8 9b 00 00 00       	call   80030b <cprintf>
  800270:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800273:	cc                   	int3   
  800274:	eb fd                	jmp    800273 <_panic+0x43>

00800276 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	53                   	push   %ebx
  80027a:	83 ec 04             	sub    $0x4,%esp
  80027d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800280:	8b 13                	mov    (%ebx),%edx
  800282:	8d 42 01             	lea    0x1(%edx),%eax
  800285:	89 03                	mov    %eax,(%ebx)
  800287:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800293:	74 09                	je     80029e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800295:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	68 ff 00 00 00       	push   $0xff
  8002a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a9:	50                   	push   %eax
  8002aa:	e8 47 09 00 00       	call   800bf6 <sys_cputs>
		b->idx = 0;
  8002af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb db                	jmp    800295 <putch+0x1f>

008002ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ca:	00 00 00 
	b.cnt = 0;
  8002cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d7:	ff 75 0c             	pushl  0xc(%ebp)
  8002da:	ff 75 08             	pushl  0x8(%ebp)
  8002dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	68 76 02 80 00       	push   $0x800276
  8002e9:	e8 86 01 00 00       	call   800474 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ee:	83 c4 08             	add    $0x8,%esp
  8002f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fd:	50                   	push   %eax
  8002fe:	e8 f3 08 00 00       	call   800bf6 <sys_cputs>

	return b.cnt;
}
  800303:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800311:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 08             	pushl  0x8(%ebp)
  800318:	e8 9d ff ff ff       	call   8002ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80031d:	c9                   	leave  
  80031e:	c3                   	ret    

0080031f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	57                   	push   %edi
  800323:	56                   	push   %esi
  800324:	53                   	push   %ebx
  800325:	83 ec 1c             	sub    $0x1c,%esp
  800328:	89 c7                	mov    %eax,%edi
  80032a:	89 d6                	mov    %edx,%esi
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800332:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800335:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800338:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800340:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800343:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800346:	39 d3                	cmp    %edx,%ebx
  800348:	72 05                	jb     80034f <printnum+0x30>
  80034a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80034d:	77 7a                	ja     8003c9 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034f:	83 ec 0c             	sub    $0xc,%esp
  800352:	ff 75 18             	pushl  0x18(%ebp)
  800355:	8b 45 14             	mov    0x14(%ebp),%eax
  800358:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035b:	53                   	push   %ebx
  80035c:	ff 75 10             	pushl  0x10(%ebp)
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	ff 75 e4             	pushl  -0x1c(%ebp)
  800365:	ff 75 e0             	pushl  -0x20(%ebp)
  800368:	ff 75 dc             	pushl  -0x24(%ebp)
  80036b:	ff 75 d8             	pushl  -0x28(%ebp)
  80036e:	e8 3d 0a 00 00       	call   800db0 <__udivdi3>
  800373:	83 c4 18             	add    $0x18,%esp
  800376:	52                   	push   %edx
  800377:	50                   	push   %eax
  800378:	89 f2                	mov    %esi,%edx
  80037a:	89 f8                	mov    %edi,%eax
  80037c:	e8 9e ff ff ff       	call   80031f <printnum>
  800381:	83 c4 20             	add    $0x20,%esp
  800384:	eb 13                	jmp    800399 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	56                   	push   %esi
  80038a:	ff 75 18             	pushl  0x18(%ebp)
  80038d:	ff d7                	call   *%edi
  80038f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800392:	83 eb 01             	sub    $0x1,%ebx
  800395:	85 db                	test   %ebx,%ebx
  800397:	7f ed                	jg     800386 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	56                   	push   %esi
  80039d:	83 ec 04             	sub    $0x4,%esp
  8003a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ac:	e8 1f 0b 00 00       	call   800ed0 <__umoddi3>
  8003b1:	83 c4 14             	add    $0x14,%esp
  8003b4:	0f be 80 bc 10 80 00 	movsbl 0x8010bc(%eax),%eax
  8003bb:	50                   	push   %eax
  8003bc:	ff d7                	call   *%edi
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c4:	5b                   	pop    %ebx
  8003c5:	5e                   	pop    %esi
  8003c6:	5f                   	pop    %edi
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    
  8003c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003cc:	eb c4                	jmp    800392 <printnum+0x73>

008003ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d1:	83 fa 01             	cmp    $0x1,%edx
  8003d4:	7e 0e                	jle    8003e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d6:	8b 10                	mov    (%eax),%edx
  8003d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003db:	89 08                	mov    %ecx,(%eax)
  8003dd:	8b 02                	mov    (%edx),%eax
  8003df:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    
	else if (lflag)
  8003e4:	85 d2                	test   %edx,%edx
  8003e6:	75 10                	jne    8003f8 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f6:	eb ea                	jmp    8003e2 <getuint+0x14>
		return va_arg(*ap, unsigned long);
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 02                	mov    (%edx),%eax
  800401:	ba 00 00 00 00       	mov    $0x0,%edx
  800406:	eb da                	jmp    8003e2 <getuint+0x14>

00800408 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80040b:	83 fa 01             	cmp    $0x1,%edx
  80040e:	7e 0e                	jle    80041e <getint+0x16>
		return va_arg(*ap, long long);
  800410:	8b 10                	mov    (%eax),%edx
  800412:	8d 4a 08             	lea    0x8(%edx),%ecx
  800415:	89 08                	mov    %ecx,(%eax)
  800417:	8b 02                	mov    (%edx),%eax
  800419:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  80041c:	5d                   	pop    %ebp
  80041d:	c3                   	ret    
	else if (lflag)
  80041e:	85 d2                	test   %edx,%edx
  800420:	75 0c                	jne    80042e <getint+0x26>
		return va_arg(*ap, int);
  800422:	8b 10                	mov    (%eax),%edx
  800424:	8d 4a 04             	lea    0x4(%edx),%ecx
  800427:	89 08                	mov    %ecx,(%eax)
  800429:	8b 02                	mov    (%edx),%eax
  80042b:	99                   	cltd   
  80042c:	eb ee                	jmp    80041c <getint+0x14>
		return va_arg(*ap, long);
  80042e:	8b 10                	mov    (%eax),%edx
  800430:	8d 4a 04             	lea    0x4(%edx),%ecx
  800433:	89 08                	mov    %ecx,(%eax)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	99                   	cltd   
  800438:	eb e2                	jmp    80041c <getint+0x14>

0080043a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800440:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800444:	8b 10                	mov    (%eax),%edx
  800446:	3b 50 04             	cmp    0x4(%eax),%edx
  800449:	73 0a                	jae    800455 <sprintputch+0x1b>
		*b->buf++ = ch;
  80044b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 45 08             	mov    0x8(%ebp),%eax
  800453:	88 02                	mov    %al,(%edx)
}
  800455:	5d                   	pop    %ebp
  800456:	c3                   	ret    

00800457 <printfmt>:
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80045d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800460:	50                   	push   %eax
  800461:	ff 75 10             	pushl  0x10(%ebp)
  800464:	ff 75 0c             	pushl  0xc(%ebp)
  800467:	ff 75 08             	pushl  0x8(%ebp)
  80046a:	e8 05 00 00 00       	call   800474 <vprintfmt>
}
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	c9                   	leave  
  800473:	c3                   	ret    

00800474 <vprintfmt>:
{
  800474:	55                   	push   %ebp
  800475:	89 e5                	mov    %esp,%ebp
  800477:	57                   	push   %edi
  800478:	56                   	push   %esi
  800479:	53                   	push   %ebx
  80047a:	83 ec 2c             	sub    $0x2c,%esp
  80047d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800480:	8b 75 0c             	mov    0xc(%ebp),%esi
  800483:	89 f7                	mov    %esi,%edi
  800485:	89 de                	mov    %ebx,%esi
  800487:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80048a:	e9 9e 02 00 00       	jmp    80072d <vprintfmt+0x2b9>
		padc = ' ';
  80048f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800493:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80049a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8004a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004a8:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8d 43 01             	lea    0x1(%ebx),%eax
  8004b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b3:	0f b6 0b             	movzbl (%ebx),%ecx
  8004b6:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8004b9:	3c 55                	cmp    $0x55,%al
  8004bb:	0f 87 e8 02 00 00    	ja     8007a9 <vprintfmt+0x335>
  8004c1:	0f b6 c0             	movzbl %al,%eax
  8004c4:	ff 24 85 80 11 80 00 	jmp    *0x801180(,%eax,4)
  8004cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  8004ce:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004d2:	eb d9                	jmp    8004ad <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  8004d7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004db:	eb d0                	jmp    8004ad <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	0f b6 c9             	movzbl %cl,%ecx
  8004e0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  8004e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ee:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004f2:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8004f5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004f8:	83 fa 09             	cmp    $0x9,%edx
  8004fb:	77 52                	ja     80054f <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  8004fd:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800500:	eb e9                	jmp    8004eb <vprintfmt+0x77>
			precision = va_arg(ap, int);
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	8d 48 04             	lea    0x4(%eax),%ecx
  800508:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800513:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800517:	79 94                	jns    8004ad <vprintfmt+0x39>
				width = precision, precision = -1;
  800519:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80051c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800526:	eb 85                	jmp    8004ad <vprintfmt+0x39>
  800528:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052b:	85 c0                	test   %eax,%eax
  80052d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800532:	0f 49 c8             	cmovns %eax,%ecx
  800535:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053b:	e9 6d ff ff ff       	jmp    8004ad <vprintfmt+0x39>
  800540:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800543:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80054a:	e9 5e ff ff ff       	jmp    8004ad <vprintfmt+0x39>
  80054f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800552:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800555:	eb bc                	jmp    800513 <vprintfmt+0x9f>
			lflag++;
  800557:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80055d:	e9 4b ff ff ff       	jmp    8004ad <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 50 04             	lea    0x4(%eax),%edx
  800568:	89 55 14             	mov    %edx,0x14(%ebp)
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	57                   	push   %edi
  80056f:	ff 30                	pushl  (%eax)
  800571:	ff d6                	call   *%esi
			break;
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	e9 af 01 00 00       	jmp    80072a <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 04             	lea    0x4(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 00                	mov    (%eax),%eax
  800586:	99                   	cltd   
  800587:	31 d0                	xor    %edx,%eax
  800589:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80058b:	83 f8 08             	cmp    $0x8,%eax
  80058e:	7f 20                	jg     8005b0 <vprintfmt+0x13c>
  800590:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  800597:	85 d2                	test   %edx,%edx
  800599:	74 15                	je     8005b0 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80059b:	52                   	push   %edx
  80059c:	68 dd 10 80 00       	push   $0x8010dd
  8005a1:	57                   	push   %edi
  8005a2:	56                   	push   %esi
  8005a3:	e8 af fe ff ff       	call   800457 <printfmt>
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	e9 7a 01 00 00       	jmp    80072a <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8005b0:	50                   	push   %eax
  8005b1:	68 d4 10 80 00       	push   $0x8010d4
  8005b6:	57                   	push   %edi
  8005b7:	56                   	push   %esi
  8005b8:	e8 9a fe ff ff       	call   800457 <printfmt>
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	e9 65 01 00 00       	jmp    80072a <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 04             	lea    0x4(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  8005d0:	85 db                	test   %ebx,%ebx
  8005d2:	b8 cd 10 80 00       	mov    $0x8010cd,%eax
  8005d7:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  8005da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005de:	0f 8e bd 00 00 00    	jle    8006a1 <vprintfmt+0x22d>
  8005e4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e8:	75 0e                	jne    8005f8 <vprintfmt+0x184>
  8005ea:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f0:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005f6:	eb 6d                	jmp    800665 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8005fe:	53                   	push   %ebx
  8005ff:	e8 4d 02 00 00       	call   800851 <strnlen>
  800604:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800607:	29 c1                	sub    %eax,%ecx
  800609:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80060c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80060f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800613:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800616:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800619:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80061b:	eb 0f                	jmp    80062c <vprintfmt+0x1b8>
					putch(padc, putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	57                   	push   %edi
  800621:	ff 75 e0             	pushl  -0x20(%ebp)
  800624:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800626:	83 eb 01             	sub    $0x1,%ebx
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	85 db                	test   %ebx,%ebx
  80062e:	7f ed                	jg     80061d <vprintfmt+0x1a9>
  800630:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800633:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800636:	85 c9                	test   %ecx,%ecx
  800638:	b8 00 00 00 00       	mov    $0x0,%eax
  80063d:	0f 49 c1             	cmovns %ecx,%eax
  800640:	29 c1                	sub    %eax,%ecx
  800642:	89 75 08             	mov    %esi,0x8(%ebp)
  800645:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800648:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80064b:	89 cf                	mov    %ecx,%edi
  80064d:	eb 16                	jmp    800665 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  80064f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800653:	75 31                	jne    800686 <vprintfmt+0x212>
					putch(ch, putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	ff 75 0c             	pushl  0xc(%ebp)
  80065b:	50                   	push   %eax
  80065c:	ff 55 08             	call   *0x8(%ebp)
  80065f:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	83 c3 01             	add    $0x1,%ebx
  800668:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  80066c:	0f be c2             	movsbl %dl,%eax
  80066f:	85 c0                	test   %eax,%eax
  800671:	74 50                	je     8006c3 <vprintfmt+0x24f>
  800673:	85 f6                	test   %esi,%esi
  800675:	78 d8                	js     80064f <vprintfmt+0x1db>
  800677:	83 ee 01             	sub    $0x1,%esi
  80067a:	79 d3                	jns    80064f <vprintfmt+0x1db>
  80067c:	89 fb                	mov    %edi,%ebx
  80067e:	8b 75 08             	mov    0x8(%ebp),%esi
  800681:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800684:	eb 37                	jmp    8006bd <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  800686:	0f be d2             	movsbl %dl,%edx
  800689:	83 ea 20             	sub    $0x20,%edx
  80068c:	83 fa 5e             	cmp    $0x5e,%edx
  80068f:	76 c4                	jbe    800655 <vprintfmt+0x1e1>
					putch('?', putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	ff 75 0c             	pushl  0xc(%ebp)
  800697:	6a 3f                	push   $0x3f
  800699:	ff 55 08             	call   *0x8(%ebp)
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	eb c1                	jmp    800662 <vprintfmt+0x1ee>
  8006a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a7:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006aa:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ad:	eb b6                	jmp    800665 <vprintfmt+0x1f1>
				putch(' ', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	57                   	push   %edi
  8006b3:	6a 20                	push   $0x20
  8006b5:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006b7:	83 eb 01             	sub    $0x1,%ebx
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	85 db                	test   %ebx,%ebx
  8006bf:	7f ee                	jg     8006af <vprintfmt+0x23b>
  8006c1:	eb 67                	jmp    80072a <vprintfmt+0x2b6>
  8006c3:	89 fb                	mov    %edi,%ebx
  8006c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006cb:	eb f0                	jmp    8006bd <vprintfmt+0x249>
			num = getint(&ap, lflag);
  8006cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d0:	e8 33 fd ff ff       	call   800408 <getint>
  8006d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8006db:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8006e0:	85 d2                	test   %edx,%edx
  8006e2:	79 2c                	jns    800710 <vprintfmt+0x29c>
				putch('-', putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	57                   	push   %edi
  8006e8:	6a 2d                	push   $0x2d
  8006ea:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006f2:	f7 d8                	neg    %eax
  8006f4:	83 d2 00             	adc    $0x0,%edx
  8006f7:	f7 da                	neg    %edx
  8006f9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800701:	eb 0d                	jmp    800710 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 c3 fc ff ff       	call   8003ce <getuint>
			base = 10;
  80070b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800710:	83 ec 0c             	sub    $0xc,%esp
  800713:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  800717:	53                   	push   %ebx
  800718:	ff 75 e0             	pushl  -0x20(%ebp)
  80071b:	51                   	push   %ecx
  80071c:	52                   	push   %edx
  80071d:	50                   	push   %eax
  80071e:	89 fa                	mov    %edi,%edx
  800720:	89 f0                	mov    %esi,%eax
  800722:	e8 f8 fb ff ff       	call   80031f <printnum>
			break;
  800727:	83 c4 20             	add    $0x20,%esp
{
  80072a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80072d:	83 c3 01             	add    $0x1,%ebx
  800730:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800734:	83 f8 25             	cmp    $0x25,%eax
  800737:	0f 84 52 fd ff ff    	je     80048f <vprintfmt+0x1b>
			if (ch == '\0')
  80073d:	85 c0                	test   %eax,%eax
  80073f:	0f 84 84 00 00 00    	je     8007c9 <vprintfmt+0x355>
			putch(ch, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	57                   	push   %edi
  800749:	50                   	push   %eax
  80074a:	ff d6                	call   *%esi
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb dc                	jmp    80072d <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
  800754:	e8 75 fc ff ff       	call   8003ce <getuint>
			base = 8;
  800759:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80075e:	eb b0                	jmp    800710 <vprintfmt+0x29c>
			putch('0', putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	57                   	push   %edi
  800764:	6a 30                	push   $0x30
  800766:	ff d6                	call   *%esi
			putch('x', putdat);
  800768:	83 c4 08             	add    $0x8,%esp
  80076b:	57                   	push   %edi
  80076c:	6a 78                	push   $0x78
  80076e:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8d 50 04             	lea    0x4(%eax),%edx
  800776:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800779:	8b 00                	mov    (%eax),%eax
  80077b:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800780:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800783:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800788:	eb 86                	jmp    800710 <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
  80078d:	e8 3c fc ff ff       	call   8003ce <getuint>
			base = 16;
  800792:	b9 10 00 00 00       	mov    $0x10,%ecx
  800797:	e9 74 ff ff ff       	jmp    800710 <vprintfmt+0x29c>
			putch(ch, putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	57                   	push   %edi
  8007a0:	6a 25                	push   $0x25
  8007a2:	ff d6                	call   *%esi
			break;
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	eb 81                	jmp    80072a <vprintfmt+0x2b6>
			putch('%', putdat);
  8007a9:	83 ec 08             	sub    $0x8,%esp
  8007ac:	57                   	push   %edi
  8007ad:	6a 25                	push   $0x25
  8007af:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	89 d8                	mov    %ebx,%eax
  8007b6:	eb 03                	jmp    8007bb <vprintfmt+0x347>
  8007b8:	83 e8 01             	sub    $0x1,%eax
  8007bb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007bf:	75 f7                	jne    8007b8 <vprintfmt+0x344>
  8007c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007c4:	e9 61 ff ff ff       	jmp    80072a <vprintfmt+0x2b6>
}
  8007c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007cc:	5b                   	pop    %ebx
  8007cd:	5e                   	pop    %esi
  8007ce:	5f                   	pop    %edi
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	83 ec 18             	sub    $0x18,%esp
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	74 26                	je     800818 <vsnprintf+0x47>
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	7e 22                	jle    800818 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f6:	ff 75 14             	pushl  0x14(%ebp)
  8007f9:	ff 75 10             	pushl  0x10(%ebp)
  8007fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ff:	50                   	push   %eax
  800800:	68 3a 04 80 00       	push   $0x80043a
  800805:	e8 6a fc ff ff       	call   800474 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80080d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800810:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800813:	83 c4 10             	add    $0x10,%esp
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    
		return -E_INVAL;
  800818:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081d:	eb f7                	jmp    800816 <vsnprintf+0x45>

0080081f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800825:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800828:	50                   	push   %eax
  800829:	ff 75 10             	pushl  0x10(%ebp)
  80082c:	ff 75 0c             	pushl  0xc(%ebp)
  80082f:	ff 75 08             	pushl  0x8(%ebp)
  800832:	e8 9a ff ff ff       	call   8007d1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
  800844:	eb 03                	jmp    800849 <strlen+0x10>
		n++;
  800846:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800849:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80084d:	75 f7                	jne    800846 <strlen+0xd>
	return n;
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
  80085f:	eb 03                	jmp    800864 <strnlen+0x13>
		n++;
  800861:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800864:	39 d0                	cmp    %edx,%eax
  800866:	74 06                	je     80086e <strnlen+0x1d>
  800868:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086c:	75 f3                	jne    800861 <strnlen+0x10>
	return n;
}
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	53                   	push   %ebx
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80087a:	89 c2                	mov    %eax,%edx
  80087c:	83 c1 01             	add    $0x1,%ecx
  80087f:	83 c2 01             	add    $0x1,%edx
  800882:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800886:	88 5a ff             	mov    %bl,-0x1(%edx)
  800889:	84 db                	test   %bl,%bl
  80088b:	75 ef                	jne    80087c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80088d:	5b                   	pop    %ebx
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800897:	53                   	push   %ebx
  800898:	e8 9c ff ff ff       	call   800839 <strlen>
  80089d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a0:	ff 75 0c             	pushl  0xc(%ebp)
  8008a3:	01 d8                	add    %ebx,%eax
  8008a5:	50                   	push   %eax
  8008a6:	e8 c5 ff ff ff       	call   800870 <strcpy>
	return dst;
}
  8008ab:	89 d8                	mov    %ebx,%eax
  8008ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	89 f3                	mov    %esi,%ebx
  8008bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c2:	89 f2                	mov    %esi,%edx
  8008c4:	eb 0f                	jmp    8008d5 <strncpy+0x23>
		*dst++ = *src;
  8008c6:	83 c2 01             	add    $0x1,%edx
  8008c9:	0f b6 01             	movzbl (%ecx),%eax
  8008cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008d5:	39 da                	cmp    %ebx,%edx
  8008d7:	75 ed                	jne    8008c6 <strncpy+0x14>
	}
	return ret;
}
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ed:	89 f0                	mov    %esi,%eax
  8008ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	75 0b                	jne    800902 <strlcpy+0x23>
  8008f7:	eb 17                	jmp    800910 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f9:	83 c2 01             	add    $0x1,%edx
  8008fc:	83 c0 01             	add    $0x1,%eax
  8008ff:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800902:	39 d8                	cmp    %ebx,%eax
  800904:	74 07                	je     80090d <strlcpy+0x2e>
  800906:	0f b6 0a             	movzbl (%edx),%ecx
  800909:	84 c9                	test   %cl,%cl
  80090b:	75 ec                	jne    8008f9 <strlcpy+0x1a>
		*dst = '\0';
  80090d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800910:	29 f0                	sub    %esi,%eax
}
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091f:	eb 06                	jmp    800927 <strcmp+0x11>
		p++, q++;
  800921:	83 c1 01             	add    $0x1,%ecx
  800924:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800927:	0f b6 01             	movzbl (%ecx),%eax
  80092a:	84 c0                	test   %al,%al
  80092c:	74 04                	je     800932 <strcmp+0x1c>
  80092e:	3a 02                	cmp    (%edx),%al
  800930:	74 ef                	je     800921 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800932:	0f b6 c0             	movzbl %al,%eax
  800935:	0f b6 12             	movzbl (%edx),%edx
  800938:	29 d0                	sub    %edx,%eax
}
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	53                   	push   %ebx
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
  800946:	89 c3                	mov    %eax,%ebx
  800948:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80094b:	eb 06                	jmp    800953 <strncmp+0x17>
		n--, p++, q++;
  80094d:	83 c0 01             	add    $0x1,%eax
  800950:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800953:	39 d8                	cmp    %ebx,%eax
  800955:	74 16                	je     80096d <strncmp+0x31>
  800957:	0f b6 08             	movzbl (%eax),%ecx
  80095a:	84 c9                	test   %cl,%cl
  80095c:	74 04                	je     800962 <strncmp+0x26>
  80095e:	3a 0a                	cmp    (%edx),%cl
  800960:	74 eb                	je     80094d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800962:	0f b6 00             	movzbl (%eax),%eax
  800965:	0f b6 12             	movzbl (%edx),%edx
  800968:	29 d0                	sub    %edx,%eax
}
  80096a:	5b                   	pop    %ebx
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    
		return 0;
  80096d:	b8 00 00 00 00       	mov    $0x0,%eax
  800972:	eb f6                	jmp    80096a <strncmp+0x2e>

00800974 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097e:	0f b6 10             	movzbl (%eax),%edx
  800981:	84 d2                	test   %dl,%dl
  800983:	74 09                	je     80098e <strchr+0x1a>
		if (*s == c)
  800985:	38 ca                	cmp    %cl,%dl
  800987:	74 0a                	je     800993 <strchr+0x1f>
	for (; *s; s++)
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	eb f0                	jmp    80097e <strchr+0xa>
			return (char *) s;
	return 0;
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099f:	eb 03                	jmp    8009a4 <strfind+0xf>
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a7:	38 ca                	cmp    %cl,%dl
  8009a9:	74 04                	je     8009af <strfind+0x1a>
  8009ab:	84 d2                	test   %dl,%dl
  8009ad:	75 f2                	jne    8009a1 <strfind+0xc>
			break;
	return (char *) s;
}
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	57                   	push   %edi
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8009bd:	85 c9                	test   %ecx,%ecx
  8009bf:	74 12                	je     8009d3 <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c1:	f6 c2 03             	test   $0x3,%dl
  8009c4:	75 05                	jne    8009cb <memset+0x1a>
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	74 0f                	je     8009da <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009cb:	89 d7                	mov    %edx,%edi
  8009cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d0:	fc                   	cld    
  8009d1:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8009d3:	89 d0                	mov    %edx,%eax
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5f                   	pop    %edi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    
		c &= 0xFF;
  8009da:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009de:	89 d8                	mov    %ebx,%eax
  8009e0:	c1 e0 08             	shl    $0x8,%eax
  8009e3:	89 df                	mov    %ebx,%edi
  8009e5:	c1 e7 18             	shl    $0x18,%edi
  8009e8:	89 de                	mov    %ebx,%esi
  8009ea:	c1 e6 10             	shl    $0x10,%esi
  8009ed:	09 f7                	or     %esi,%edi
  8009ef:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  8009f1:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8009f6:	89 d7                	mov    %edx,%edi
  8009f8:	fc                   	cld    
  8009f9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fb:	eb d6                	jmp    8009d3 <memset+0x22>

008009fd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	57                   	push   %edi
  800a01:	56                   	push   %esi
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0b:	39 c6                	cmp    %eax,%esi
  800a0d:	73 35                	jae    800a44 <memmove+0x47>
  800a0f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a12:	39 c2                	cmp    %eax,%edx
  800a14:	76 2e                	jbe    800a44 <memmove+0x47>
		s += n;
		d += n;
  800a16:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a19:	89 d6                	mov    %edx,%esi
  800a1b:	09 fe                	or     %edi,%esi
  800a1d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a23:	74 0c                	je     800a31 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a25:	83 ef 01             	sub    $0x1,%edi
  800a28:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a2b:	fd                   	std    
  800a2c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2e:	fc                   	cld    
  800a2f:	eb 21                	jmp    800a52 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a31:	f6 c1 03             	test   $0x3,%cl
  800a34:	75 ef                	jne    800a25 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a36:	83 ef 04             	sub    $0x4,%edi
  800a39:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a3f:	fd                   	std    
  800a40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a42:	eb ea                	jmp    800a2e <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a44:	89 f2                	mov    %esi,%edx
  800a46:	09 c2                	or     %eax,%edx
  800a48:	f6 c2 03             	test   $0x3,%dl
  800a4b:	74 09                	je     800a56 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4d:	89 c7                	mov    %eax,%edi
  800a4f:	fc                   	cld    
  800a50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a56:	f6 c1 03             	test   $0x3,%cl
  800a59:	75 f2                	jne    800a4d <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a5e:	89 c7                	mov    %eax,%edi
  800a60:	fc                   	cld    
  800a61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a63:	eb ed                	jmp    800a52 <memmove+0x55>

00800a65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a68:	ff 75 10             	pushl  0x10(%ebp)
  800a6b:	ff 75 0c             	pushl  0xc(%ebp)
  800a6e:	ff 75 08             	pushl  0x8(%ebp)
  800a71:	e8 87 ff ff ff       	call   8009fd <memmove>
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a83:	89 c6                	mov    %eax,%esi
  800a85:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a88:	39 f0                	cmp    %esi,%eax
  800a8a:	74 1c                	je     800aa8 <memcmp+0x30>
		if (*s1 != *s2)
  800a8c:	0f b6 08             	movzbl (%eax),%ecx
  800a8f:	0f b6 1a             	movzbl (%edx),%ebx
  800a92:	38 d9                	cmp    %bl,%cl
  800a94:	75 08                	jne    800a9e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	83 c2 01             	add    $0x1,%edx
  800a9c:	eb ea                	jmp    800a88 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a9e:	0f b6 c1             	movzbl %cl,%eax
  800aa1:	0f b6 db             	movzbl %bl,%ebx
  800aa4:	29 d8                	sub    %ebx,%eax
  800aa6:	eb 05                	jmp    800aad <memcmp+0x35>
	}

	return 0;
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800abf:	39 d0                	cmp    %edx,%eax
  800ac1:	73 09                	jae    800acc <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac3:	38 08                	cmp    %cl,(%eax)
  800ac5:	74 05                	je     800acc <memfind+0x1b>
	for (; s < ends; s++)
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	eb f3                	jmp    800abf <memfind+0xe>
			break;
	return (void *) s;
}
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ada:	eb 03                	jmp    800adf <strtol+0x11>
		s++;
  800adc:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800adf:	0f b6 01             	movzbl (%ecx),%eax
  800ae2:	3c 20                	cmp    $0x20,%al
  800ae4:	74 f6                	je     800adc <strtol+0xe>
  800ae6:	3c 09                	cmp    $0x9,%al
  800ae8:	74 f2                	je     800adc <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800aea:	3c 2b                	cmp    $0x2b,%al
  800aec:	74 2e                	je     800b1c <strtol+0x4e>
	int neg = 0;
  800aee:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800af3:	3c 2d                	cmp    $0x2d,%al
  800af5:	74 2f                	je     800b26 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afd:	75 05                	jne    800b04 <strtol+0x36>
  800aff:	80 39 30             	cmpb   $0x30,(%ecx)
  800b02:	74 2c                	je     800b30 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b04:	85 db                	test   %ebx,%ebx
  800b06:	75 0a                	jne    800b12 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b08:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b10:	74 28                	je     800b3a <strtol+0x6c>
		base = 10;
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b1a:	eb 50                	jmp    800b6c <strtol+0x9e>
		s++;
  800b1c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b24:	eb d1                	jmp    800af7 <strtol+0x29>
		s++, neg = 1;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	bf 01 00 00 00       	mov    $0x1,%edi
  800b2e:	eb c7                	jmp    800af7 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b30:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b34:	74 0e                	je     800b44 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b36:	85 db                	test   %ebx,%ebx
  800b38:	75 d8                	jne    800b12 <strtol+0x44>
		s++, base = 8;
  800b3a:	83 c1 01             	add    $0x1,%ecx
  800b3d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b42:	eb ce                	jmp    800b12 <strtol+0x44>
		s += 2, base = 16;
  800b44:	83 c1 02             	add    $0x2,%ecx
  800b47:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4c:	eb c4                	jmp    800b12 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b4e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b51:	89 f3                	mov    %esi,%ebx
  800b53:	80 fb 19             	cmp    $0x19,%bl
  800b56:	77 29                	ja     800b81 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b58:	0f be d2             	movsbl %dl,%edx
  800b5b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b5e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b61:	7d 30                	jge    800b93 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b6a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b6c:	0f b6 11             	movzbl (%ecx),%edx
  800b6f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b72:	89 f3                	mov    %esi,%ebx
  800b74:	80 fb 09             	cmp    $0x9,%bl
  800b77:	77 d5                	ja     800b4e <strtol+0x80>
			dig = *s - '0';
  800b79:	0f be d2             	movsbl %dl,%edx
  800b7c:	83 ea 30             	sub    $0x30,%edx
  800b7f:	eb dd                	jmp    800b5e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b81:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b84:	89 f3                	mov    %esi,%ebx
  800b86:	80 fb 19             	cmp    $0x19,%bl
  800b89:	77 08                	ja     800b93 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b8b:	0f be d2             	movsbl %dl,%edx
  800b8e:	83 ea 37             	sub    $0x37,%edx
  800b91:	eb cb                	jmp    800b5e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b97:	74 05                	je     800b9e <strtol+0xd0>
		*endptr = (char *) s;
  800b99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b9e:	89 c2                	mov    %eax,%edx
  800ba0:	f7 da                	neg    %edx
  800ba2:	85 ff                	test   %edi,%edi
  800ba4:	0f 45 c2             	cmovne %edx,%eax
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 1c             	sub    $0x1c,%esp
  800bb5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bb8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800bbb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc3:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bc6:	8b 75 14             	mov    0x14(%ebp),%esi
  800bc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800bcf:	74 04                	je     800bd5 <syscall+0x29>
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	7f 08                	jg     800bdd <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    
  800bdd:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	52                   	push   %edx
  800be5:	68 04 13 80 00       	push   $0x801304
  800bea:	6a 23                	push   $0x23
  800bec:	68 21 13 80 00       	push   $0x801321
  800bf1:	e8 3a f6 ff ff       	call   800230 <_panic>

00800bf6 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bfc:	6a 00                	push   $0x0
  800bfe:	6a 00                	push   $0x0
  800c00:	6a 00                	push   $0x0
  800c02:	ff 75 0c             	pushl  0xc(%ebp)
  800c05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c08:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c12:	e8 95 ff ff ff       	call   800bac <syscall>
}
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    

00800c1c <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c22:	6a 00                	push   $0x0
  800c24:	6a 00                	push   $0x0
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c34:	b8 01 00 00 00       	mov    $0x1,%eax
  800c39:	e8 6e ff ff ff       	call   800bac <syscall>
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c46:	6a 00                	push   $0x0
  800c48:	6a 00                	push   $0x0
  800c4a:	6a 00                	push   $0x0
  800c4c:	6a 00                	push   $0x0
  800c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c51:	ba 01 00 00 00       	mov    $0x1,%edx
  800c56:	b8 03 00 00 00       	mov    $0x3,%eax
  800c5b:	e8 4c ff ff ff       	call   800bac <syscall>
}
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c68:	6a 00                	push   $0x0
  800c6a:	6a 00                	push   $0x0
  800c6c:	6a 00                	push   $0x0
  800c6e:	6a 00                	push   $0x0
  800c70:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7f:	e8 28 ff ff ff       	call   800bac <syscall>
}
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <sys_yield>:

void
sys_yield(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c8c:	6a 00                	push   $0x0
  800c8e:	6a 00                	push   $0x0
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c99:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca3:	e8 04 ff ff ff       	call   800bac <syscall>
}
  800ca8:	83 c4 10             	add    $0x10,%esp
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800cb3:	6a 00                	push   $0x0
  800cb5:	6a 00                	push   $0x0
  800cb7:	ff 75 10             	pushl  0x10(%ebp)
  800cba:	ff 75 0c             	pushl  0xc(%ebp)
  800cbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc0:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc5:	b8 04 00 00 00       	mov    $0x4,%eax
  800cca:	e8 dd fe ff ff       	call   800bac <syscall>
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    

00800cd1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800cd7:	ff 75 18             	pushl  0x18(%ebp)
  800cda:	ff 75 14             	pushl  0x14(%ebp)
  800cdd:	ff 75 10             	pushl  0x10(%ebp)
  800ce0:	ff 75 0c             	pushl  0xc(%ebp)
  800ce3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce6:	ba 01 00 00 00       	mov    $0x1,%edx
  800ceb:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf0:	e8 b7 fe ff ff       	call   800bac <syscall>
}
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cfd:	6a 00                	push   $0x0
  800cff:	6a 00                	push   $0x0
  800d01:	6a 00                	push   $0x0
  800d03:	ff 75 0c             	pushl  0xc(%ebp)
  800d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d09:	ba 01 00 00 00       	mov    $0x1,%edx
  800d0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d13:	e8 94 fe ff ff       	call   800bac <syscall>
}
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    

00800d1a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d20:	6a 00                	push   $0x0
  800d22:	6a 00                	push   $0x0
  800d24:	6a 00                	push   $0x0
  800d26:	ff 75 0c             	pushl  0xc(%ebp)
  800d29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d31:	b8 08 00 00 00       	mov    $0x8,%eax
  800d36:	e8 71 fe ff ff       	call   800bac <syscall>
}
  800d3b:	c9                   	leave  
  800d3c:	c3                   	ret    

00800d3d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d43:	6a 00                	push   $0x0
  800d45:	6a 00                	push   $0x0
  800d47:	6a 00                	push   $0x0
  800d49:	ff 75 0c             	pushl  0xc(%ebp)
  800d4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4f:	ba 01 00 00 00       	mov    $0x1,%edx
  800d54:	b8 09 00 00 00       	mov    $0x9,%eax
  800d59:	e8 4e fe ff ff       	call   800bac <syscall>
}
  800d5e:	c9                   	leave  
  800d5f:	c3                   	ret    

00800d60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d66:	6a 00                	push   $0x0
  800d68:	ff 75 14             	pushl  0x14(%ebp)
  800d6b:	ff 75 10             	pushl  0x10(%ebp)
  800d6e:	ff 75 0c             	pushl  0xc(%ebp)
  800d71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d74:	ba 00 00 00 00       	mov    $0x0,%edx
  800d79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7e:	e8 29 fe ff ff       	call   800bac <syscall>
}
  800d83:	c9                   	leave  
  800d84:	c3                   	ret    

00800d85 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d8b:	6a 00                	push   $0x0
  800d8d:	6a 00                	push   $0x0
  800d8f:	6a 00                	push   $0x0
  800d91:	6a 00                	push   $0x0
  800d93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d96:	ba 01 00 00 00       	mov    $0x1,%edx
  800d9b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da0:	e8 07 fe ff ff       	call   800bac <syscall>
}
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    
  800da7:	66 90                	xchg   %ax,%ax
  800da9:	66 90                	xchg   %ax,%ax
  800dab:	66 90                	xchg   %ax,%ax
  800dad:	66 90                	xchg   %ax,%ax
  800daf:	90                   	nop

00800db0 <__udivdi3>:
  800db0:	55                   	push   %ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 1c             	sub    $0x1c,%esp
  800db7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dbb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800dc3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dc7:	85 d2                	test   %edx,%edx
  800dc9:	75 35                	jne    800e00 <__udivdi3+0x50>
  800dcb:	39 f3                	cmp    %esi,%ebx
  800dcd:	0f 87 bd 00 00 00    	ja     800e90 <__udivdi3+0xe0>
  800dd3:	85 db                	test   %ebx,%ebx
  800dd5:	89 d9                	mov    %ebx,%ecx
  800dd7:	75 0b                	jne    800de4 <__udivdi3+0x34>
  800dd9:	b8 01 00 00 00       	mov    $0x1,%eax
  800dde:	31 d2                	xor    %edx,%edx
  800de0:	f7 f3                	div    %ebx
  800de2:	89 c1                	mov    %eax,%ecx
  800de4:	31 d2                	xor    %edx,%edx
  800de6:	89 f0                	mov    %esi,%eax
  800de8:	f7 f1                	div    %ecx
  800dea:	89 c6                	mov    %eax,%esi
  800dec:	89 e8                	mov    %ebp,%eax
  800dee:	89 f7                	mov    %esi,%edi
  800df0:	f7 f1                	div    %ecx
  800df2:	89 fa                	mov    %edi,%edx
  800df4:	83 c4 1c             	add    $0x1c,%esp
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    
  800dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e00:	39 f2                	cmp    %esi,%edx
  800e02:	77 7c                	ja     800e80 <__udivdi3+0xd0>
  800e04:	0f bd fa             	bsr    %edx,%edi
  800e07:	83 f7 1f             	xor    $0x1f,%edi
  800e0a:	0f 84 98 00 00 00    	je     800ea8 <__udivdi3+0xf8>
  800e10:	89 f9                	mov    %edi,%ecx
  800e12:	b8 20 00 00 00       	mov    $0x20,%eax
  800e17:	29 f8                	sub    %edi,%eax
  800e19:	d3 e2                	shl    %cl,%edx
  800e1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e1f:	89 c1                	mov    %eax,%ecx
  800e21:	89 da                	mov    %ebx,%edx
  800e23:	d3 ea                	shr    %cl,%edx
  800e25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e29:	09 d1                	or     %edx,%ecx
  800e2b:	89 f2                	mov    %esi,%edx
  800e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e31:	89 f9                	mov    %edi,%ecx
  800e33:	d3 e3                	shl    %cl,%ebx
  800e35:	89 c1                	mov    %eax,%ecx
  800e37:	d3 ea                	shr    %cl,%edx
  800e39:	89 f9                	mov    %edi,%ecx
  800e3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e3f:	d3 e6                	shl    %cl,%esi
  800e41:	89 eb                	mov    %ebp,%ebx
  800e43:	89 c1                	mov    %eax,%ecx
  800e45:	d3 eb                	shr    %cl,%ebx
  800e47:	09 de                	or     %ebx,%esi
  800e49:	89 f0                	mov    %esi,%eax
  800e4b:	f7 74 24 08          	divl   0x8(%esp)
  800e4f:	89 d6                	mov    %edx,%esi
  800e51:	89 c3                	mov    %eax,%ebx
  800e53:	f7 64 24 0c          	mull   0xc(%esp)
  800e57:	39 d6                	cmp    %edx,%esi
  800e59:	72 0c                	jb     800e67 <__udivdi3+0xb7>
  800e5b:	89 f9                	mov    %edi,%ecx
  800e5d:	d3 e5                	shl    %cl,%ebp
  800e5f:	39 c5                	cmp    %eax,%ebp
  800e61:	73 5d                	jae    800ec0 <__udivdi3+0x110>
  800e63:	39 d6                	cmp    %edx,%esi
  800e65:	75 59                	jne    800ec0 <__udivdi3+0x110>
  800e67:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e6a:	31 ff                	xor    %edi,%edi
  800e6c:	89 fa                	mov    %edi,%edx
  800e6e:	83 c4 1c             	add    $0x1c,%esp
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    
  800e76:	8d 76 00             	lea    0x0(%esi),%esi
  800e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e80:	31 ff                	xor    %edi,%edi
  800e82:	31 c0                	xor    %eax,%eax
  800e84:	89 fa                	mov    %edi,%edx
  800e86:	83 c4 1c             	add    $0x1c,%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    
  800e8e:	66 90                	xchg   %ax,%ax
  800e90:	31 ff                	xor    %edi,%edi
  800e92:	89 e8                	mov    %ebp,%eax
  800e94:	89 f2                	mov    %esi,%edx
  800e96:	f7 f3                	div    %ebx
  800e98:	89 fa                	mov    %edi,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea8:	39 f2                	cmp    %esi,%edx
  800eaa:	72 06                	jb     800eb2 <__udivdi3+0x102>
  800eac:	31 c0                	xor    %eax,%eax
  800eae:	39 eb                	cmp    %ebp,%ebx
  800eb0:	77 d2                	ja     800e84 <__udivdi3+0xd4>
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	eb cb                	jmp    800e84 <__udivdi3+0xd4>
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	89 d8                	mov    %ebx,%eax
  800ec2:	31 ff                	xor    %edi,%edi
  800ec4:	eb be                	jmp    800e84 <__udivdi3+0xd4>
  800ec6:	66 90                	xchg   %ax,%ax
  800ec8:	66 90                	xchg   %ax,%ax
  800eca:	66 90                	xchg   %ax,%ax
  800ecc:	66 90                	xchg   %ax,%ax
  800ece:	66 90                	xchg   %ax,%ax

00800ed0 <__umoddi3>:
  800ed0:	55                   	push   %ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 1c             	sub    $0x1c,%esp
  800ed7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800edb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800edf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ee7:	85 ed                	test   %ebp,%ebp
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	89 da                	mov    %ebx,%edx
  800eed:	75 19                	jne    800f08 <__umoddi3+0x38>
  800eef:	39 df                	cmp    %ebx,%edi
  800ef1:	0f 86 b1 00 00 00    	jbe    800fa8 <__umoddi3+0xd8>
  800ef7:	f7 f7                	div    %edi
  800ef9:	89 d0                	mov    %edx,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	83 c4 1c             	add    $0x1c,%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    
  800f05:	8d 76 00             	lea    0x0(%esi),%esi
  800f08:	39 dd                	cmp    %ebx,%ebp
  800f0a:	77 f1                	ja     800efd <__umoddi3+0x2d>
  800f0c:	0f bd cd             	bsr    %ebp,%ecx
  800f0f:	83 f1 1f             	xor    $0x1f,%ecx
  800f12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f16:	0f 84 b4 00 00 00    	je     800fd0 <__umoddi3+0x100>
  800f1c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f21:	89 c2                	mov    %eax,%edx
  800f23:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f27:	29 c2                	sub    %eax,%edx
  800f29:	89 c1                	mov    %eax,%ecx
  800f2b:	89 f8                	mov    %edi,%eax
  800f2d:	d3 e5                	shl    %cl,%ebp
  800f2f:	89 d1                	mov    %edx,%ecx
  800f31:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f35:	d3 e8                	shr    %cl,%eax
  800f37:	09 c5                	or     %eax,%ebp
  800f39:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f3d:	89 c1                	mov    %eax,%ecx
  800f3f:	d3 e7                	shl    %cl,%edi
  800f41:	89 d1                	mov    %edx,%ecx
  800f43:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f47:	89 df                	mov    %ebx,%edi
  800f49:	d3 ef                	shr    %cl,%edi
  800f4b:	89 c1                	mov    %eax,%ecx
  800f4d:	89 f0                	mov    %esi,%eax
  800f4f:	d3 e3                	shl    %cl,%ebx
  800f51:	89 d1                	mov    %edx,%ecx
  800f53:	89 fa                	mov    %edi,%edx
  800f55:	d3 e8                	shr    %cl,%eax
  800f57:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f5c:	09 d8                	or     %ebx,%eax
  800f5e:	f7 f5                	div    %ebp
  800f60:	d3 e6                	shl    %cl,%esi
  800f62:	89 d1                	mov    %edx,%ecx
  800f64:	f7 64 24 08          	mull   0x8(%esp)
  800f68:	39 d1                	cmp    %edx,%ecx
  800f6a:	89 c3                	mov    %eax,%ebx
  800f6c:	89 d7                	mov    %edx,%edi
  800f6e:	72 06                	jb     800f76 <__umoddi3+0xa6>
  800f70:	75 0e                	jne    800f80 <__umoddi3+0xb0>
  800f72:	39 c6                	cmp    %eax,%esi
  800f74:	73 0a                	jae    800f80 <__umoddi3+0xb0>
  800f76:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f7a:	19 ea                	sbb    %ebp,%edx
  800f7c:	89 d7                	mov    %edx,%edi
  800f7e:	89 c3                	mov    %eax,%ebx
  800f80:	89 ca                	mov    %ecx,%edx
  800f82:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f87:	29 de                	sub    %ebx,%esi
  800f89:	19 fa                	sbb    %edi,%edx
  800f8b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f8f:	89 d0                	mov    %edx,%eax
  800f91:	d3 e0                	shl    %cl,%eax
  800f93:	89 d9                	mov    %ebx,%ecx
  800f95:	d3 ee                	shr    %cl,%esi
  800f97:	d3 ea                	shr    %cl,%edx
  800f99:	09 f0                	or     %esi,%eax
  800f9b:	83 c4 1c             	add    $0x1c,%esp
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    
  800fa3:	90                   	nop
  800fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	85 ff                	test   %edi,%edi
  800faa:	89 f9                	mov    %edi,%ecx
  800fac:	75 0b                	jne    800fb9 <__umoddi3+0xe9>
  800fae:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb3:	31 d2                	xor    %edx,%edx
  800fb5:	f7 f7                	div    %edi
  800fb7:	89 c1                	mov    %eax,%ecx
  800fb9:	89 d8                	mov    %ebx,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	f7 f1                	div    %ecx
  800fbf:	89 f0                	mov    %esi,%eax
  800fc1:	f7 f1                	div    %ecx
  800fc3:	e9 31 ff ff ff       	jmp    800ef9 <__umoddi3+0x29>
  800fc8:	90                   	nop
  800fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	39 dd                	cmp    %ebx,%ebp
  800fd2:	72 08                	jb     800fdc <__umoddi3+0x10c>
  800fd4:	39 f7                	cmp    %esi,%edi
  800fd6:	0f 87 21 ff ff ff    	ja     800efd <__umoddi3+0x2d>
  800fdc:	89 da                	mov    %ebx,%edx
  800fde:	89 f0                	mov    %esi,%eax
  800fe0:	29 f8                	sub    %edi,%eax
  800fe2:	19 ea                	sbb    %ebp,%edx
  800fe4:	e9 14 ff ff ff       	jmp    800efd <__umoddi3+0x2d>
