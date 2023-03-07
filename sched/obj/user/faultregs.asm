
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 ae 05 00 00       	call   8005df <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 91 14 80 00       	push   $0x801491
  800049:	68 60 14 80 00       	push   $0x801460
  80004e:	e8 c3 06 00 00       	call   800716 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 70 14 80 00       	push   $0x801470
  80005c:	68 74 14 80 00       	push   $0x801474
  800061:	e8 b0 06 00 00       	call   800716 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 31 02 00 00    	je     8002a4 <check_regs+0x271>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 88 14 80 00       	push   $0x801488
  80007b:	e8 96 06 00 00       	call   800716 <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 92 14 80 00       	push   $0x801492
  800093:	68 74 14 80 00       	push   $0x801474
  800098:	e8 79 06 00 00       	call   800716 <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 12 02 00 00    	je     8002be <check_regs+0x28b>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 88 14 80 00       	push   $0x801488
  8000b4:	e8 5d 06 00 00       	call   800716 <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 96 14 80 00       	push   $0x801496
  8000cc:	68 74 14 80 00       	push   $0x801474
  8000d1:	e8 40 06 00 00       	call   800716 <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 ee 01 00 00    	je     8002d3 <check_regs+0x2a0>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 88 14 80 00       	push   $0x801488
  8000ed:	e8 24 06 00 00       	call   800716 <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 9a 14 80 00       	push   $0x80149a
  800105:	68 74 14 80 00       	push   $0x801474
  80010a:	e8 07 06 00 00       	call   800716 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 ca 01 00 00    	je     8002e8 <check_regs+0x2b5>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 88 14 80 00       	push   $0x801488
  800126:	e8 eb 05 00 00       	call   800716 <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 9e 14 80 00       	push   $0x80149e
  80013e:	68 74 14 80 00       	push   $0x801474
  800143:	e8 ce 05 00 00       	call   800716 <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a6 01 00 00    	je     8002fd <check_regs+0x2ca>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 88 14 80 00       	push   $0x801488
  80015f:	e8 b2 05 00 00       	call   800716 <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 a2 14 80 00       	push   $0x8014a2
  800177:	68 74 14 80 00       	push   $0x801474
  80017c:	e8 95 05 00 00       	call   800716 <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 82 01 00 00    	je     800312 <check_regs+0x2df>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 88 14 80 00       	push   $0x801488
  800198:	e8 79 05 00 00       	call   800716 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 a6 14 80 00       	push   $0x8014a6
  8001b0:	68 74 14 80 00       	push   $0x801474
  8001b5:	e8 5c 05 00 00       	call   800716 <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5e 01 00 00    	je     800327 <check_regs+0x2f4>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 88 14 80 00       	push   $0x801488
  8001d1:	e8 40 05 00 00       	call   800716 <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 aa 14 80 00       	push   $0x8014aa
  8001e9:	68 74 14 80 00       	push   $0x801474
  8001ee:	e8 23 05 00 00       	call   800716 <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 3a 01 00 00    	je     80033c <check_regs+0x309>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 88 14 80 00       	push   $0x801488
  80020a:	e8 07 05 00 00       	call   800716 <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 ae 14 80 00       	push   $0x8014ae
  800222:	68 74 14 80 00       	push   $0x801474
  800227:	e8 ea 04 00 00       	call   800716 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 16 01 00 00    	je     800351 <check_regs+0x31e>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 88 14 80 00       	push   $0x801488
  800243:	e8 ce 04 00 00       	call   800716 <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 b5 14 80 00       	push   $0x8014b5
  800253:	68 74 14 80 00       	push   $0x801474
  800258:	e8 b9 04 00 00       	call   800716 <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 88 14 80 00       	push   $0x801488
  800274:	e8 9d 04 00 00       	call   800716 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 b9 14 80 00       	push   $0x8014b9
  800284:	e8 8d 04 00 00       	call   800716 <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 88 14 80 00       	push   $0x801488
  800294:	e8 7d 04 00 00       	call   800716 <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5e                   	pop    %esi
  8002a1:	5f                   	pop    %edi
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    
	CHECK(edi, regs.reg_edi);
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 84 14 80 00       	push   $0x801484
  8002ac:	e8 65 04 00 00       	call   800716 <cprintf>
  8002b1:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b9:	e9 ca fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002be:	83 ec 0c             	sub    $0xc,%esp
  8002c1:	68 84 14 80 00       	push   $0x801484
  8002c6:	e8 4b 04 00 00       	call   800716 <cprintf>
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	e9 ee fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	68 84 14 80 00       	push   $0x801484
  8002db:	e8 36 04 00 00       	call   800716 <cprintf>
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	e9 12 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 84 14 80 00       	push   $0x801484
  8002f0:	e8 21 04 00 00       	call   800716 <cprintf>
  8002f5:	83 c4 10             	add    $0x10,%esp
  8002f8:	e9 36 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fd:	83 ec 0c             	sub    $0xc,%esp
  800300:	68 84 14 80 00       	push   $0x801484
  800305:	e8 0c 04 00 00       	call   800716 <cprintf>
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	e9 5a fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	68 84 14 80 00       	push   $0x801484
  80031a:	e8 f7 03 00 00       	call   800716 <cprintf>
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	e9 7e fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	68 84 14 80 00       	push   $0x801484
  80032f:	e8 e2 03 00 00       	call   800716 <cprintf>
  800334:	83 c4 10             	add    $0x10,%esp
  800337:	e9 a2 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	68 84 14 80 00       	push   $0x801484
  800344:	e8 cd 03 00 00       	call   800716 <cprintf>
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	e9 c6 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  800351:	83 ec 0c             	sub    $0xc,%esp
  800354:	68 84 14 80 00       	push   $0x801484
  800359:	e8 b8 03 00 00       	call   800716 <cprintf>
	CHECK(esp, esp);
  80035e:	ff 73 28             	pushl  0x28(%ebx)
  800361:	ff 76 28             	pushl  0x28(%esi)
  800364:	68 b5 14 80 00       	push   $0x8014b5
  800369:	68 74 14 80 00       	push   $0x801474
  80036e:	e8 a3 03 00 00       	call   800716 <cprintf>
  800373:	83 c4 20             	add    $0x20,%esp
  800376:	8b 43 28             	mov    0x28(%ebx),%eax
  800379:	39 46 28             	cmp    %eax,0x28(%esi)
  80037c:	0f 85 ea fe ff ff    	jne    80026c <check_regs+0x239>
  800382:	83 ec 0c             	sub    $0xc,%esp
  800385:	68 84 14 80 00       	push   $0x801484
  80038a:	e8 87 03 00 00       	call   800716 <cprintf>
	cprintf("Registers %s ", testname);
  80038f:	83 c4 08             	add    $0x8,%esp
  800392:	ff 75 0c             	pushl  0xc(%ebp)
  800395:	68 b9 14 80 00       	push   $0x8014b9
  80039a:	e8 77 03 00 00       	call   800716 <cprintf>
	if (!mismatch)
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	85 ff                	test   %edi,%edi
  8003a4:	0f 85 e2 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	68 84 14 80 00       	push   $0x801484
  8003b2:	e8 5f 03 00 00       	call   800716 <cprintf>
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	e9 dd fe ff ff       	jmp    80029c <check_regs+0x269>
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 84 14 80 00       	push   $0x801484
  8003c7:	e8 4a 03 00 00       	call   800716 <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 b9 14 80 00       	push   $0x8014b9
  8003d7:	e8 3a 03 00 00       	call   800716 <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f5:	0f 85 a3 00 00 00    	jne    80049e <pgfault+0xba>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003fb:	8b 50 08             	mov    0x8(%eax),%edx
  8003fe:	89 15 60 20 80 00    	mov    %edx,0x802060
  800404:	8b 50 0c             	mov    0xc(%eax),%edx
  800407:	89 15 64 20 80 00    	mov    %edx,0x802064
  80040d:	8b 50 10             	mov    0x10(%eax),%edx
  800410:	89 15 68 20 80 00    	mov    %edx,0x802068
  800416:	8b 50 14             	mov    0x14(%eax),%edx
  800419:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  80041f:	8b 50 18             	mov    0x18(%eax),%edx
  800422:	89 15 70 20 80 00    	mov    %edx,0x802070
  800428:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042b:	89 15 74 20 80 00    	mov    %edx,0x802074
  800431:	8b 50 20             	mov    0x20(%eax),%edx
  800434:	89 15 78 20 80 00    	mov    %edx,0x802078
  80043a:	8b 50 24             	mov    0x24(%eax),%edx
  80043d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800443:	8b 50 28             	mov    0x28(%eax),%edx
  800446:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  80044c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80044f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800455:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80045b:	8b 40 30             	mov    0x30(%eax),%eax
  80045e:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	68 df 14 80 00       	push   $0x8014df
  80046b:	68 ed 14 80 00       	push   $0x8014ed
  800470:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800475:	ba d8 14 80 00       	mov    $0x8014d8,%edx
  80047a:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80047f:	e8 af fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800484:	83 c4 0c             	add    $0xc,%esp
  800487:	6a 07                	push   $0x7
  800489:	68 00 00 40 00       	push   $0x400000
  80048e:	6a 00                	push   $0x0
  800490:	e8 23 0c 00 00       	call   8010b8 <sys_page_alloc>
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	85 c0                	test   %eax,%eax
  80049a:	78 1a                	js     8004b6 <pgfault+0xd2>
		panic("sys_page_alloc: %e", r);
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	ff 70 28             	pushl  0x28(%eax)
  8004a4:	52                   	push   %edx
  8004a5:	68 20 15 80 00       	push   $0x801520
  8004aa:	6a 51                	push   $0x51
  8004ac:	68 c7 14 80 00       	push   $0x8014c7
  8004b1:	e8 85 01 00 00       	call   80063b <_panic>
		panic("sys_page_alloc: %e", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 f4 14 80 00       	push   $0x8014f4
  8004bc:	6a 5c                	push   $0x5c
  8004be:	68 c7 14 80 00       	push   $0x8014c7
  8004c3:	e8 73 01 00 00       	call   80063b <_panic>

008004c8 <umain>:

void
umain(int argc, char **argv)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004ce:	68 e4 03 80 00       	push   $0x8003e4
  8004d3:	e8 da 0c 00 00       	call   8011b2 <set_pgfault_handler>

	asm volatile(
  8004d8:	50                   	push   %eax
  8004d9:	9c                   	pushf  
  8004da:	58                   	pop    %eax
  8004db:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e0:	50                   	push   %eax
  8004e1:	9d                   	popf   
  8004e2:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004e7:	8d 05 22 05 80 00    	lea    0x800522,%eax
  8004ed:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004f2:	58                   	pop    %eax
  8004f3:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004f9:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004ff:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  800505:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  80050b:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800511:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  800517:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  80051c:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  800522:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800529:	00 00 00 
  80052c:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800532:	89 35 24 20 80 00    	mov    %esi,0x802024
  800538:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  80053e:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800544:	89 15 34 20 80 00    	mov    %edx,0x802034
  80054a:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800550:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800555:	89 25 48 20 80 00    	mov    %esp,0x802048
  80055b:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800561:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800567:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80056d:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800573:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800579:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  80057f:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800584:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80058a:	50                   	push   %eax
  80058b:	9c                   	pushf  
  80058c:	58                   	pop    %eax
  80058d:	a3 44 20 80 00       	mov    %eax,0x802044
  800592:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80059d:	74 10                	je     8005af <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  80059f:	83 ec 0c             	sub    $0xc,%esp
  8005a2:	68 54 15 80 00       	push   $0x801554
  8005a7:	e8 6a 01 00 00       	call   800716 <cprintf>
  8005ac:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  8005af:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  8005b4:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	68 07 15 80 00       	push   $0x801507
  8005c1:	68 18 15 80 00       	push   $0x801518
  8005c6:	b9 20 20 80 00       	mov    $0x802020,%ecx
  8005cb:	ba d8 14 80 00       	mov    $0x8014d8,%edx
  8005d0:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  8005d5:	e8 59 fa ff ff       	call   800033 <check_regs>
}
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	c9                   	leave  
  8005de:	c3                   	ret    

008005df <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	56                   	push   %esi
  8005e3:	53                   	push   %ebx
  8005e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t id = sys_getenvid();
  8005ea:	e8 7e 0a 00 00       	call   80106d <sys_getenvid>
	if (id >= 0)
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	78 12                	js     800605 <libmain+0x26>
		thisenv = &envs[ENVX(id)];
  8005f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005f8:	c1 e0 07             	shl    $0x7,%eax
  8005fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800600:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800605:	85 db                	test   %ebx,%ebx
  800607:	7e 07                	jle    800610 <libmain+0x31>
		binaryname = argv[0];
  800609:	8b 06                	mov    (%esi),%eax
  80060b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	e8 ae fe ff ff       	call   8004c8 <umain>

	// exit gracefully
	exit();
  80061a:	e8 0a 00 00 00       	call   800629 <exit>
}
  80061f:	83 c4 10             	add    $0x10,%esp
  800622:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800625:	5b                   	pop    %ebx
  800626:	5e                   	pop    %esi
  800627:	5d                   	pop    %ebp
  800628:	c3                   	ret    

00800629 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800629:	55                   	push   %ebp
  80062a:	89 e5                	mov    %esp,%ebp
  80062c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80062f:	6a 00                	push   $0x0
  800631:	e8 15 0a 00 00       	call   80104b <sys_env_destroy>
}
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	c9                   	leave  
  80063a:	c3                   	ret    

0080063b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	56                   	push   %esi
  80063f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800640:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800643:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800649:	e8 1f 0a 00 00       	call   80106d <sys_getenvid>
  80064e:	83 ec 0c             	sub    $0xc,%esp
  800651:	ff 75 0c             	pushl  0xc(%ebp)
  800654:	ff 75 08             	pushl  0x8(%ebp)
  800657:	56                   	push   %esi
  800658:	50                   	push   %eax
  800659:	68 80 15 80 00       	push   $0x801580
  80065e:	e8 b3 00 00 00       	call   800716 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800663:	83 c4 18             	add    $0x18,%esp
  800666:	53                   	push   %ebx
  800667:	ff 75 10             	pushl  0x10(%ebp)
  80066a:	e8 56 00 00 00       	call   8006c5 <vcprintf>
	cprintf("\n");
  80066f:	c7 04 24 90 14 80 00 	movl   $0x801490,(%esp)
  800676:	e8 9b 00 00 00       	call   800716 <cprintf>
  80067b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80067e:	cc                   	int3   
  80067f:	eb fd                	jmp    80067e <_panic+0x43>

00800681 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	53                   	push   %ebx
  800685:	83 ec 04             	sub    $0x4,%esp
  800688:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80068b:	8b 13                	mov    (%ebx),%edx
  80068d:	8d 42 01             	lea    0x1(%edx),%eax
  800690:	89 03                	mov    %eax,(%ebx)
  800692:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800695:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800699:	3d ff 00 00 00       	cmp    $0xff,%eax
  80069e:	74 09                	je     8006a9 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006a0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a7:	c9                   	leave  
  8006a8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	68 ff 00 00 00       	push   $0xff
  8006b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8006b4:	50                   	push   %eax
  8006b5:	e8 47 09 00 00       	call   801001 <sys_cputs>
		b->idx = 0;
  8006ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb db                	jmp    8006a0 <putch+0x1f>

008006c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006d5:	00 00 00 
	b.cnt = 0;
  8006d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	ff 75 08             	pushl  0x8(%ebp)
  8006e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006ee:	50                   	push   %eax
  8006ef:	68 81 06 80 00       	push   $0x800681
  8006f4:	e8 86 01 00 00       	call   80087f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006f9:	83 c4 08             	add    $0x8,%esp
  8006fc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800702:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	e8 f3 08 00 00       	call   801001 <sys_cputs>

	return b.cnt;
}
  80070e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800714:	c9                   	leave  
  800715:	c3                   	ret    

00800716 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80071c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80071f:	50                   	push   %eax
  800720:	ff 75 08             	pushl  0x8(%ebp)
  800723:	e8 9d ff ff ff       	call   8006c5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	57                   	push   %edi
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
  800730:	83 ec 1c             	sub    $0x1c,%esp
  800733:	89 c7                	mov    %eax,%edi
  800735:	89 d6                	mov    %edx,%esi
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800740:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800743:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800746:	bb 00 00 00 00       	mov    $0x0,%ebx
  80074b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80074e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800751:	39 d3                	cmp    %edx,%ebx
  800753:	72 05                	jb     80075a <printnum+0x30>
  800755:	39 45 10             	cmp    %eax,0x10(%ebp)
  800758:	77 7a                	ja     8007d4 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80075a:	83 ec 0c             	sub    $0xc,%esp
  80075d:	ff 75 18             	pushl  0x18(%ebp)
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800766:	53                   	push   %ebx
  800767:	ff 75 10             	pushl  0x10(%ebp)
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800770:	ff 75 e0             	pushl  -0x20(%ebp)
  800773:	ff 75 dc             	pushl  -0x24(%ebp)
  800776:	ff 75 d8             	pushl  -0x28(%ebp)
  800779:	e8 a2 0a 00 00       	call   801220 <__udivdi3>
  80077e:	83 c4 18             	add    $0x18,%esp
  800781:	52                   	push   %edx
  800782:	50                   	push   %eax
  800783:	89 f2                	mov    %esi,%edx
  800785:	89 f8                	mov    %edi,%eax
  800787:	e8 9e ff ff ff       	call   80072a <printnum>
  80078c:	83 c4 20             	add    $0x20,%esp
  80078f:	eb 13                	jmp    8007a4 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	56                   	push   %esi
  800795:	ff 75 18             	pushl  0x18(%ebp)
  800798:	ff d7                	call   *%edi
  80079a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80079d:	83 eb 01             	sub    $0x1,%ebx
  8007a0:	85 db                	test   %ebx,%ebx
  8007a2:	7f ed                	jg     800791 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	56                   	push   %esi
  8007a8:	83 ec 04             	sub    $0x4,%esp
  8007ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8007b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8007b7:	e8 84 0b 00 00       	call   801340 <__umoddi3>
  8007bc:	83 c4 14             	add    $0x14,%esp
  8007bf:	0f be 80 a4 15 80 00 	movsbl 0x8015a4(%eax),%eax
  8007c6:	50                   	push   %eax
  8007c7:	ff d7                	call   *%edi
}
  8007c9:	83 c4 10             	add    $0x10,%esp
  8007cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007cf:	5b                   	pop    %ebx
  8007d0:	5e                   	pop    %esi
  8007d1:	5f                   	pop    %edi
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    
  8007d4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8007d7:	eb c4                	jmp    80079d <printnum+0x73>

008007d9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007dc:	83 fa 01             	cmp    $0x1,%edx
  8007df:	7e 0e                	jle    8007ef <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007e1:	8b 10                	mov    (%eax),%edx
  8007e3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007e6:	89 08                	mov    %ecx,(%eax)
  8007e8:	8b 02                	mov    (%edx),%eax
  8007ea:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    
	else if (lflag)
  8007ef:	85 d2                	test   %edx,%edx
  8007f1:	75 10                	jne    800803 <getuint+0x2a>
		return va_arg(*ap, unsigned int);
  8007f3:	8b 10                	mov    (%eax),%edx
  8007f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007f8:	89 08                	mov    %ecx,(%eax)
  8007fa:	8b 02                	mov    (%edx),%eax
  8007fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800801:	eb ea                	jmp    8007ed <getuint+0x14>
		return va_arg(*ap, unsigned long);
  800803:	8b 10                	mov    (%eax),%edx
  800805:	8d 4a 04             	lea    0x4(%edx),%ecx
  800808:	89 08                	mov    %ecx,(%eax)
  80080a:	8b 02                	mov    (%edx),%eax
  80080c:	ba 00 00 00 00       	mov    $0x0,%edx
  800811:	eb da                	jmp    8007ed <getuint+0x14>

00800813 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800816:	83 fa 01             	cmp    $0x1,%edx
  800819:	7e 0e                	jle    800829 <getint+0x16>
		return va_arg(*ap, long long);
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800820:	89 08                	mov    %ecx,(%eax)
  800822:	8b 02                	mov    (%edx),%eax
  800824:	8b 52 04             	mov    0x4(%edx),%edx
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    
	else if (lflag)
  800829:	85 d2                	test   %edx,%edx
  80082b:	75 0c                	jne    800839 <getint+0x26>
		return va_arg(*ap, int);
  80082d:	8b 10                	mov    (%eax),%edx
  80082f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800832:	89 08                	mov    %ecx,(%eax)
  800834:	8b 02                	mov    (%edx),%eax
  800836:	99                   	cltd   
  800837:	eb ee                	jmp    800827 <getint+0x14>
		return va_arg(*ap, long);
  800839:	8b 10                	mov    (%eax),%edx
  80083b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80083e:	89 08                	mov    %ecx,(%eax)
  800840:	8b 02                	mov    (%edx),%eax
  800842:	99                   	cltd   
  800843:	eb e2                	jmp    800827 <getint+0x14>

00800845 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80084b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	3b 50 04             	cmp    0x4(%eax),%edx
  800854:	73 0a                	jae    800860 <sprintputch+0x1b>
		*b->buf++ = ch;
  800856:	8d 4a 01             	lea    0x1(%edx),%ecx
  800859:	89 08                	mov    %ecx,(%eax)
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	88 02                	mov    %al,(%edx)
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <printfmt>:
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80086b:	50                   	push   %eax
  80086c:	ff 75 10             	pushl  0x10(%ebp)
  80086f:	ff 75 0c             	pushl  0xc(%ebp)
  800872:	ff 75 08             	pushl  0x8(%ebp)
  800875:	e8 05 00 00 00       	call   80087f <vprintfmt>
}
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    

0080087f <vprintfmt>:
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	57                   	push   %edi
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	83 ec 2c             	sub    $0x2c,%esp
  800888:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80088b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088e:	89 f7                	mov    %esi,%edi
  800890:	89 de                	mov    %ebx,%esi
  800892:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800895:	e9 9e 02 00 00       	jmp    800b38 <vprintfmt+0x2b9>
		padc = ' ';
  80089a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80089e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8008a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8008ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8008b3:	ba 00 00 00 00       	mov    $0x0,%edx
		switch (ch = *(unsigned char *) fmt++) {
  8008b8:	8d 43 01             	lea    0x1(%ebx),%eax
  8008bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008be:	0f b6 0b             	movzbl (%ebx),%ecx
  8008c1:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8008c4:	3c 55                	cmp    $0x55,%al
  8008c6:	0f 87 e8 02 00 00    	ja     800bb4 <vprintfmt+0x335>
  8008cc:	0f b6 c0             	movzbl %al,%eax
  8008cf:	ff 24 85 60 16 80 00 	jmp    *0x801660(,%eax,4)
  8008d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  8008d9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8008dd:	eb d9                	jmp    8008b8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8008df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '0';
  8008e2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008e6:	eb d0                	jmp    8008b8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8008e8:	0f b6 c9             	movzbl %cl,%ecx
  8008eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8008f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008f9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8008fd:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800900:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800903:	83 fa 09             	cmp    $0x9,%edx
  800906:	77 52                	ja     80095a <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  800908:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80090b:	eb e9                	jmp    8008f6 <vprintfmt+0x77>
			precision = va_arg(ap, int);
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8d 48 04             	lea    0x4(%eax),%ecx
  800913:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800916:	8b 00                	mov    (%eax),%eax
  800918:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80091e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800922:	79 94                	jns    8008b8 <vprintfmt+0x39>
				width = precision, precision = -1;
  800924:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800927:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80092a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800931:	eb 85                	jmp    8008b8 <vprintfmt+0x39>
  800933:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800936:	85 c0                	test   %eax,%eax
  800938:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093d:	0f 49 c8             	cmovns %eax,%ecx
  800940:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800943:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800946:	e9 6d ff ff ff       	jmp    8008b8 <vprintfmt+0x39>
  80094b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80094e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800955:	e9 5e ff ff ff       	jmp    8008b8 <vprintfmt+0x39>
  80095a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80095d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800960:	eb bc                	jmp    80091e <vprintfmt+0x9f>
			lflag++;
  800962:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800965:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800968:	e9 4b ff ff ff       	jmp    8008b8 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80096d:	8b 45 14             	mov    0x14(%ebp),%eax
  800970:	8d 50 04             	lea    0x4(%eax),%edx
  800973:	89 55 14             	mov    %edx,0x14(%ebp)
  800976:	83 ec 08             	sub    $0x8,%esp
  800979:	57                   	push   %edi
  80097a:	ff 30                	pushl  (%eax)
  80097c:	ff d6                	call   *%esi
			break;
  80097e:	83 c4 10             	add    $0x10,%esp
  800981:	e9 af 01 00 00       	jmp    800b35 <vprintfmt+0x2b6>
			err = va_arg(ap, int);
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	8d 50 04             	lea    0x4(%eax),%edx
  80098c:	89 55 14             	mov    %edx,0x14(%ebp)
  80098f:	8b 00                	mov    (%eax),%eax
  800991:	99                   	cltd   
  800992:	31 d0                	xor    %edx,%eax
  800994:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800996:	83 f8 08             	cmp    $0x8,%eax
  800999:	7f 20                	jg     8009bb <vprintfmt+0x13c>
  80099b:	8b 14 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%edx
  8009a2:	85 d2                	test   %edx,%edx
  8009a4:	74 15                	je     8009bb <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  8009a6:	52                   	push   %edx
  8009a7:	68 c5 15 80 00       	push   $0x8015c5
  8009ac:	57                   	push   %edi
  8009ad:	56                   	push   %esi
  8009ae:	e8 af fe ff ff       	call   800862 <printfmt>
  8009b3:	83 c4 10             	add    $0x10,%esp
  8009b6:	e9 7a 01 00 00       	jmp    800b35 <vprintfmt+0x2b6>
				printfmt(putch, putdat, "error %d", err);
  8009bb:	50                   	push   %eax
  8009bc:	68 bc 15 80 00       	push   $0x8015bc
  8009c1:	57                   	push   %edi
  8009c2:	56                   	push   %esi
  8009c3:	e8 9a fe ff ff       	call   800862 <printfmt>
  8009c8:	83 c4 10             	add    $0x10,%esp
  8009cb:	e9 65 01 00 00       	jmp    800b35 <vprintfmt+0x2b6>
			if ((p = va_arg(ap, char *)) == NULL)
  8009d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d3:	8d 50 04             	lea    0x4(%eax),%edx
  8009d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d9:	8b 18                	mov    (%eax),%ebx
				p = "(null)";
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	b8 b5 15 80 00       	mov    $0x8015b5,%eax
  8009e2:	0f 44 d8             	cmove  %eax,%ebx
			if (width > 0 && padc != '-')
  8009e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009e9:	0f 8e bd 00 00 00    	jle    800aac <vprintfmt+0x22d>
  8009ef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009f3:	75 0e                	jne    800a03 <vprintfmt+0x184>
  8009f5:	89 75 08             	mov    %esi,0x8(%ebp)
  8009f8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009fb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8009fe:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800a01:	eb 6d                	jmp    800a70 <vprintfmt+0x1f1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a03:	83 ec 08             	sub    $0x8,%esp
  800a06:	ff 75 d0             	pushl  -0x30(%ebp)
  800a09:	53                   	push   %ebx
  800a0a:	e8 4d 02 00 00       	call   800c5c <strnlen>
  800a0f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a12:	29 c1                	sub    %eax,%ecx
  800a14:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a17:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a1a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a21:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800a24:	89 cb                	mov    %ecx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800a26:	eb 0f                	jmp    800a37 <vprintfmt+0x1b8>
					putch(padc, putdat);
  800a28:	83 ec 08             	sub    $0x8,%esp
  800a2b:	57                   	push   %edi
  800a2c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a2f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800a31:	83 eb 01             	sub    $0x1,%ebx
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	85 db                	test   %ebx,%ebx
  800a39:	7f ed                	jg     800a28 <vprintfmt+0x1a9>
  800a3b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a3e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a41:	85 c9                	test   %ecx,%ecx
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
  800a48:	0f 49 c1             	cmovns %ecx,%eax
  800a4b:	29 c1                	sub    %eax,%ecx
  800a4d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a50:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a53:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a56:	89 cf                	mov    %ecx,%edi
  800a58:	eb 16                	jmp    800a70 <vprintfmt+0x1f1>
				if (altflag && (ch < ' ' || ch > '~'))
  800a5a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a5e:	75 31                	jne    800a91 <vprintfmt+0x212>
					putch(ch, putdat);
  800a60:	83 ec 08             	sub    $0x8,%esp
  800a63:	ff 75 0c             	pushl  0xc(%ebp)
  800a66:	50                   	push   %eax
  800a67:	ff 55 08             	call   *0x8(%ebp)
  800a6a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a6d:	83 ef 01             	sub    $0x1,%edi
  800a70:	83 c3 01             	add    $0x1,%ebx
  800a73:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
  800a77:	0f be c2             	movsbl %dl,%eax
  800a7a:	85 c0                	test   %eax,%eax
  800a7c:	74 50                	je     800ace <vprintfmt+0x24f>
  800a7e:	85 f6                	test   %esi,%esi
  800a80:	78 d8                	js     800a5a <vprintfmt+0x1db>
  800a82:	83 ee 01             	sub    $0x1,%esi
  800a85:	79 d3                	jns    800a5a <vprintfmt+0x1db>
  800a87:	89 fb                	mov    %edi,%ebx
  800a89:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a8f:	eb 37                	jmp    800ac8 <vprintfmt+0x249>
				if (altflag && (ch < ' ' || ch > '~'))
  800a91:	0f be d2             	movsbl %dl,%edx
  800a94:	83 ea 20             	sub    $0x20,%edx
  800a97:	83 fa 5e             	cmp    $0x5e,%edx
  800a9a:	76 c4                	jbe    800a60 <vprintfmt+0x1e1>
					putch('?', putdat);
  800a9c:	83 ec 08             	sub    $0x8,%esp
  800a9f:	ff 75 0c             	pushl  0xc(%ebp)
  800aa2:	6a 3f                	push   $0x3f
  800aa4:	ff 55 08             	call   *0x8(%ebp)
  800aa7:	83 c4 10             	add    $0x10,%esp
  800aaa:	eb c1                	jmp    800a6d <vprintfmt+0x1ee>
  800aac:	89 75 08             	mov    %esi,0x8(%ebp)
  800aaf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ab2:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800ab5:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800ab8:	eb b6                	jmp    800a70 <vprintfmt+0x1f1>
				putch(' ', putdat);
  800aba:	83 ec 08             	sub    $0x8,%esp
  800abd:	57                   	push   %edi
  800abe:	6a 20                	push   $0x20
  800ac0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800ac2:	83 eb 01             	sub    $0x1,%ebx
  800ac5:	83 c4 10             	add    $0x10,%esp
  800ac8:	85 db                	test   %ebx,%ebx
  800aca:	7f ee                	jg     800aba <vprintfmt+0x23b>
  800acc:	eb 67                	jmp    800b35 <vprintfmt+0x2b6>
  800ace:	89 fb                	mov    %edi,%ebx
  800ad0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ad6:	eb f0                	jmp    800ac8 <vprintfmt+0x249>
			num = getint(&ap, lflag);
  800ad8:	8d 45 14             	lea    0x14(%ebp),%eax
  800adb:	e8 33 fd ff ff       	call   800813 <getint>
  800ae0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800ae6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800aeb:	85 d2                	test   %edx,%edx
  800aed:	79 2c                	jns    800b1b <vprintfmt+0x29c>
				putch('-', putdat);
  800aef:	83 ec 08             	sub    $0x8,%esp
  800af2:	57                   	push   %edi
  800af3:	6a 2d                	push   $0x2d
  800af5:	ff d6                	call   *%esi
				num = -(long long) num;
  800af7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800afa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800afd:	f7 d8                	neg    %eax
  800aff:	83 d2 00             	adc    $0x0,%edx
  800b02:	f7 da                	neg    %edx
  800b04:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800b07:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b0c:	eb 0d                	jmp    800b1b <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800b0e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b11:	e8 c3 fc ff ff       	call   8007d9 <getuint>
			base = 10;
  800b16:	b9 0a 00 00 00       	mov    $0xa,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800b1b:	83 ec 0c             	sub    $0xc,%esp
  800b1e:	0f be 5d d4          	movsbl -0x2c(%ebp),%ebx
  800b22:	53                   	push   %ebx
  800b23:	ff 75 e0             	pushl  -0x20(%ebp)
  800b26:	51                   	push   %ecx
  800b27:	52                   	push   %edx
  800b28:	50                   	push   %eax
  800b29:	89 fa                	mov    %edi,%edx
  800b2b:	89 f0                	mov    %esi,%eax
  800b2d:	e8 f8 fb ff ff       	call   80072a <printnum>
			break;
  800b32:	83 c4 20             	add    $0x20,%esp
{
  800b35:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b38:	83 c3 01             	add    $0x1,%ebx
  800b3b:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  800b3f:	83 f8 25             	cmp    $0x25,%eax
  800b42:	0f 84 52 fd ff ff    	je     80089a <vprintfmt+0x1b>
			if (ch == '\0')
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	0f 84 84 00 00 00    	je     800bd4 <vprintfmt+0x355>
			putch(ch, putdat);
  800b50:	83 ec 08             	sub    $0x8,%esp
  800b53:	57                   	push   %edi
  800b54:	50                   	push   %eax
  800b55:	ff d6                	call   *%esi
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	eb dc                	jmp    800b38 <vprintfmt+0x2b9>
			num = getuint(&ap, lflag);
  800b5c:	8d 45 14             	lea    0x14(%ebp),%eax
  800b5f:	e8 75 fc ff ff       	call   8007d9 <getuint>
			base = 8;
  800b64:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b69:	eb b0                	jmp    800b1b <vprintfmt+0x29c>
			putch('0', putdat);
  800b6b:	83 ec 08             	sub    $0x8,%esp
  800b6e:	57                   	push   %edi
  800b6f:	6a 30                	push   $0x30
  800b71:	ff d6                	call   *%esi
			putch('x', putdat);
  800b73:	83 c4 08             	add    $0x8,%esp
  800b76:	57                   	push   %edi
  800b77:	6a 78                	push   $0x78
  800b79:	ff d6                	call   *%esi
				(uintptr_t) va_arg(ap, void *);
  800b7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7e:	8d 50 04             	lea    0x4(%eax),%edx
  800b81:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800b84:	8b 00                	mov    (%eax),%eax
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;
  800b8b:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800b8e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b93:	eb 86                	jmp    800b1b <vprintfmt+0x29c>
			num = getuint(&ap, lflag);
  800b95:	8d 45 14             	lea    0x14(%ebp),%eax
  800b98:	e8 3c fc ff ff       	call   8007d9 <getuint>
			base = 16;
  800b9d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ba2:	e9 74 ff ff ff       	jmp    800b1b <vprintfmt+0x29c>
			putch(ch, putdat);
  800ba7:	83 ec 08             	sub    $0x8,%esp
  800baa:	57                   	push   %edi
  800bab:	6a 25                	push   $0x25
  800bad:	ff d6                	call   *%esi
			break;
  800baf:	83 c4 10             	add    $0x10,%esp
  800bb2:	eb 81                	jmp    800b35 <vprintfmt+0x2b6>
			putch('%', putdat);
  800bb4:	83 ec 08             	sub    $0x8,%esp
  800bb7:	57                   	push   %edi
  800bb8:	6a 25                	push   $0x25
  800bba:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bbc:	83 c4 10             	add    $0x10,%esp
  800bbf:	89 d8                	mov    %ebx,%eax
  800bc1:	eb 03                	jmp    800bc6 <vprintfmt+0x347>
  800bc3:	83 e8 01             	sub    $0x1,%eax
  800bc6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800bca:	75 f7                	jne    800bc3 <vprintfmt+0x344>
  800bcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bcf:	e9 61 ff ff ff       	jmp    800b35 <vprintfmt+0x2b6>
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 18             	sub    $0x18,%esp
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800be8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800beb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bf2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	74 26                	je     800c23 <vsnprintf+0x47>
  800bfd:	85 d2                	test   %edx,%edx
  800bff:	7e 22                	jle    800c23 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c01:	ff 75 14             	pushl  0x14(%ebp)
  800c04:	ff 75 10             	pushl  0x10(%ebp)
  800c07:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c0a:	50                   	push   %eax
  800c0b:	68 45 08 80 00       	push   $0x800845
  800c10:	e8 6a fc ff ff       	call   80087f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c18:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1e:	83 c4 10             	add    $0x10,%esp
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    
		return -E_INVAL;
  800c23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c28:	eb f7                	jmp    800c21 <vsnprintf+0x45>

00800c2a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c30:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c33:	50                   	push   %eax
  800c34:	ff 75 10             	pushl  0x10(%ebp)
  800c37:	ff 75 0c             	pushl  0xc(%ebp)
  800c3a:	ff 75 08             	pushl  0x8(%ebp)
  800c3d:	e8 9a ff ff ff       	call   800bdc <vsnprintf>
	va_end(ap);

	return rc;
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4f:	eb 03                	jmp    800c54 <strlen+0x10>
		n++;
  800c51:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800c54:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c58:	75 f7                	jne    800c51 <strlen+0xd>
	return n;
}
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c62:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c65:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6a:	eb 03                	jmp    800c6f <strnlen+0x13>
		n++;
  800c6c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6f:	39 d0                	cmp    %edx,%eax
  800c71:	74 06                	je     800c79 <strnlen+0x1d>
  800c73:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c77:	75 f3                	jne    800c6c <strnlen+0x10>
	return n;
}
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c85:	89 c2                	mov    %eax,%edx
  800c87:	83 c1 01             	add    $0x1,%ecx
  800c8a:	83 c2 01             	add    $0x1,%edx
  800c8d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c91:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c94:	84 db                	test   %bl,%bl
  800c96:	75 ef                	jne    800c87 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c98:	5b                   	pop    %ebx
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	53                   	push   %ebx
  800c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ca2:	53                   	push   %ebx
  800ca3:	e8 9c ff ff ff       	call   800c44 <strlen>
  800ca8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800cab:	ff 75 0c             	pushl  0xc(%ebp)
  800cae:	01 d8                	add    %ebx,%eax
  800cb0:	50                   	push   %eax
  800cb1:	e8 c5 ff ff ff       	call   800c7b <strcpy>
	return dst;
}
  800cb6:	89 d8                	mov    %ebx,%eax
  800cb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cbb:	c9                   	leave  
  800cbc:	c3                   	ret    

00800cbd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	89 f3                	mov    %esi,%ebx
  800cca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ccd:	89 f2                	mov    %esi,%edx
  800ccf:	eb 0f                	jmp    800ce0 <strncpy+0x23>
		*dst++ = *src;
  800cd1:	83 c2 01             	add    $0x1,%edx
  800cd4:	0f b6 01             	movzbl (%ecx),%eax
  800cd7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cda:	80 39 01             	cmpb   $0x1,(%ecx)
  800cdd:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800ce0:	39 da                	cmp    %ebx,%edx
  800ce2:	75 ed                	jne    800cd1 <strncpy+0x14>
	}
	return ret;
}
  800ce4:	89 f0                	mov    %esi,%eax
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	8b 75 08             	mov    0x8(%ebp),%esi
  800cf2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cf5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cf8:	89 f0                	mov    %esi,%eax
  800cfa:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cfe:	85 c9                	test   %ecx,%ecx
  800d00:	75 0b                	jne    800d0d <strlcpy+0x23>
  800d02:	eb 17                	jmp    800d1b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d04:	83 c2 01             	add    $0x1,%edx
  800d07:	83 c0 01             	add    $0x1,%eax
  800d0a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800d0d:	39 d8                	cmp    %ebx,%eax
  800d0f:	74 07                	je     800d18 <strlcpy+0x2e>
  800d11:	0f b6 0a             	movzbl (%edx),%ecx
  800d14:	84 c9                	test   %cl,%cl
  800d16:	75 ec                	jne    800d04 <strlcpy+0x1a>
		*dst = '\0';
  800d18:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d1b:	29 f0                	sub    %esi,%eax
}
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d27:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d2a:	eb 06                	jmp    800d32 <strcmp+0x11>
		p++, q++;
  800d2c:	83 c1 01             	add    $0x1,%ecx
  800d2f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800d32:	0f b6 01             	movzbl (%ecx),%eax
  800d35:	84 c0                	test   %al,%al
  800d37:	74 04                	je     800d3d <strcmp+0x1c>
  800d39:	3a 02                	cmp    (%edx),%al
  800d3b:	74 ef                	je     800d2c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d3d:	0f b6 c0             	movzbl %al,%eax
  800d40:	0f b6 12             	movzbl (%edx),%edx
  800d43:	29 d0                	sub    %edx,%eax
}
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	53                   	push   %ebx
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d51:	89 c3                	mov    %eax,%ebx
  800d53:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d56:	eb 06                	jmp    800d5e <strncmp+0x17>
		n--, p++, q++;
  800d58:	83 c0 01             	add    $0x1,%eax
  800d5b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800d5e:	39 d8                	cmp    %ebx,%eax
  800d60:	74 16                	je     800d78 <strncmp+0x31>
  800d62:	0f b6 08             	movzbl (%eax),%ecx
  800d65:	84 c9                	test   %cl,%cl
  800d67:	74 04                	je     800d6d <strncmp+0x26>
  800d69:	3a 0a                	cmp    (%edx),%cl
  800d6b:	74 eb                	je     800d58 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d6d:	0f b6 00             	movzbl (%eax),%eax
  800d70:	0f b6 12             	movzbl (%edx),%edx
  800d73:	29 d0                	sub    %edx,%eax
}
  800d75:	5b                   	pop    %ebx
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
		return 0;
  800d78:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7d:	eb f6                	jmp    800d75 <strncmp+0x2e>

00800d7f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d89:	0f b6 10             	movzbl (%eax),%edx
  800d8c:	84 d2                	test   %dl,%dl
  800d8e:	74 09                	je     800d99 <strchr+0x1a>
		if (*s == c)
  800d90:	38 ca                	cmp    %cl,%dl
  800d92:	74 0a                	je     800d9e <strchr+0x1f>
	for (; *s; s++)
  800d94:	83 c0 01             	add    $0x1,%eax
  800d97:	eb f0                	jmp    800d89 <strchr+0xa>
			return (char *) s;
	return 0;
  800d99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
  800da6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800daa:	eb 03                	jmp    800daf <strfind+0xf>
  800dac:	83 c0 01             	add    $0x1,%eax
  800daf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800db2:	38 ca                	cmp    %cl,%dl
  800db4:	74 04                	je     800dba <strfind+0x1a>
  800db6:	84 d2                	test   %dl,%dl
  800db8:	75 f2                	jne    800dac <strfind+0xc>
			break;
	return (char *) s;
}
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800dc8:	85 c9                	test   %ecx,%ecx
  800dca:	74 12                	je     800dde <memset+0x22>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dcc:	f6 c2 03             	test   $0x3,%dl
  800dcf:	75 05                	jne    800dd6 <memset+0x1a>
  800dd1:	f6 c1 03             	test   $0x3,%cl
  800dd4:	74 0f                	je     800de5 <memset+0x29>
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd6:	89 d7                	mov    %edx,%edi
  800dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddb:	fc                   	cld    
  800ddc:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800dde:	89 d0                	mov    %edx,%eax
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
		c &= 0xFF;
  800de5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800de9:	89 d8                	mov    %ebx,%eax
  800deb:	c1 e0 08             	shl    $0x8,%eax
  800dee:	89 df                	mov    %ebx,%edi
  800df0:	c1 e7 18             	shl    $0x18,%edi
  800df3:	89 de                	mov    %ebx,%esi
  800df5:	c1 e6 10             	shl    $0x10,%esi
  800df8:	09 f7                	or     %esi,%edi
  800dfa:	09 fb                	or     %edi,%ebx
			: "D" (p), "a" (c), "c" (n/4)
  800dfc:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800e01:	89 d7                	mov    %edx,%edi
  800e03:	fc                   	cld    
  800e04:	f3 ab                	rep stos %eax,%es:(%edi)
  800e06:	eb d6                	jmp    800dde <memset+0x22>

00800e08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e16:	39 c6                	cmp    %eax,%esi
  800e18:	73 35                	jae    800e4f <memmove+0x47>
  800e1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e1d:	39 c2                	cmp    %eax,%edx
  800e1f:	76 2e                	jbe    800e4f <memmove+0x47>
		s += n;
		d += n;
  800e21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e24:	89 d6                	mov    %edx,%esi
  800e26:	09 fe                	or     %edi,%esi
  800e28:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e2e:	74 0c                	je     800e3c <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e30:	83 ef 01             	sub    $0x1,%edi
  800e33:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800e36:	fd                   	std    
  800e37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e39:	fc                   	cld    
  800e3a:	eb 21                	jmp    800e5d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e3c:	f6 c1 03             	test   $0x3,%cl
  800e3f:	75 ef                	jne    800e30 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e41:	83 ef 04             	sub    $0x4,%edi
  800e44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e47:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800e4a:	fd                   	std    
  800e4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e4d:	eb ea                	jmp    800e39 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e4f:	89 f2                	mov    %esi,%edx
  800e51:	09 c2                	or     %eax,%edx
  800e53:	f6 c2 03             	test   $0x3,%dl
  800e56:	74 09                	je     800e61 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e58:	89 c7                	mov    %eax,%edi
  800e5a:	fc                   	cld    
  800e5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e61:	f6 c1 03             	test   $0x3,%cl
  800e64:	75 f2                	jne    800e58 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e66:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800e69:	89 c7                	mov    %eax,%edi
  800e6b:	fc                   	cld    
  800e6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e6e:	eb ed                	jmp    800e5d <memmove+0x55>

00800e70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e73:	ff 75 10             	pushl  0x10(%ebp)
  800e76:	ff 75 0c             	pushl  0xc(%ebp)
  800e79:	ff 75 08             	pushl  0x8(%ebp)
  800e7c:	e8 87 ff ff ff       	call   800e08 <memmove>
}
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8e:	89 c6                	mov    %eax,%esi
  800e90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e93:	39 f0                	cmp    %esi,%eax
  800e95:	74 1c                	je     800eb3 <memcmp+0x30>
		if (*s1 != *s2)
  800e97:	0f b6 08             	movzbl (%eax),%ecx
  800e9a:	0f b6 1a             	movzbl (%edx),%ebx
  800e9d:	38 d9                	cmp    %bl,%cl
  800e9f:	75 08                	jne    800ea9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ea1:	83 c0 01             	add    $0x1,%eax
  800ea4:	83 c2 01             	add    $0x1,%edx
  800ea7:	eb ea                	jmp    800e93 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ea9:	0f b6 c1             	movzbl %cl,%eax
  800eac:	0f b6 db             	movzbl %bl,%ebx
  800eaf:	29 d8                	sub    %ebx,%eax
  800eb1:	eb 05                	jmp    800eb8 <memcmp+0x35>
	}

	return 0;
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800eca:	39 d0                	cmp    %edx,%eax
  800ecc:	73 09                	jae    800ed7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ece:	38 08                	cmp    %cl,(%eax)
  800ed0:	74 05                	je     800ed7 <memfind+0x1b>
	for (; s < ends; s++)
  800ed2:	83 c0 01             	add    $0x1,%eax
  800ed5:	eb f3                	jmp    800eca <memfind+0xe>
			break;
	return (void *) s;
}
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	57                   	push   %edi
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
  800edf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee5:	eb 03                	jmp    800eea <strtol+0x11>
		s++;
  800ee7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800eea:	0f b6 01             	movzbl (%ecx),%eax
  800eed:	3c 20                	cmp    $0x20,%al
  800eef:	74 f6                	je     800ee7 <strtol+0xe>
  800ef1:	3c 09                	cmp    $0x9,%al
  800ef3:	74 f2                	je     800ee7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ef5:	3c 2b                	cmp    $0x2b,%al
  800ef7:	74 2e                	je     800f27 <strtol+0x4e>
	int neg = 0;
  800ef9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800efe:	3c 2d                	cmp    $0x2d,%al
  800f00:	74 2f                	je     800f31 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f02:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f08:	75 05                	jne    800f0f <strtol+0x36>
  800f0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800f0d:	74 2c                	je     800f3b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f0f:	85 db                	test   %ebx,%ebx
  800f11:	75 0a                	jne    800f1d <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f13:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800f18:	80 39 30             	cmpb   $0x30,(%ecx)
  800f1b:	74 28                	je     800f45 <strtol+0x6c>
		base = 10;
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f22:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f25:	eb 50                	jmp    800f77 <strtol+0x9e>
		s++;
  800f27:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800f2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f2f:	eb d1                	jmp    800f02 <strtol+0x29>
		s++, neg = 1;
  800f31:	83 c1 01             	add    $0x1,%ecx
  800f34:	bf 01 00 00 00       	mov    $0x1,%edi
  800f39:	eb c7                	jmp    800f02 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f3f:	74 0e                	je     800f4f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800f41:	85 db                	test   %ebx,%ebx
  800f43:	75 d8                	jne    800f1d <strtol+0x44>
		s++, base = 8;
  800f45:	83 c1 01             	add    $0x1,%ecx
  800f48:	bb 08 00 00 00       	mov    $0x8,%ebx
  800f4d:	eb ce                	jmp    800f1d <strtol+0x44>
		s += 2, base = 16;
  800f4f:	83 c1 02             	add    $0x2,%ecx
  800f52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f57:	eb c4                	jmp    800f1d <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800f59:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f5c:	89 f3                	mov    %esi,%ebx
  800f5e:	80 fb 19             	cmp    $0x19,%bl
  800f61:	77 29                	ja     800f8c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800f63:	0f be d2             	movsbl %dl,%edx
  800f66:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f69:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f6c:	7d 30                	jge    800f9e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800f6e:	83 c1 01             	add    $0x1,%ecx
  800f71:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f75:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800f77:	0f b6 11             	movzbl (%ecx),%edx
  800f7a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f7d:	89 f3                	mov    %esi,%ebx
  800f7f:	80 fb 09             	cmp    $0x9,%bl
  800f82:	77 d5                	ja     800f59 <strtol+0x80>
			dig = *s - '0';
  800f84:	0f be d2             	movsbl %dl,%edx
  800f87:	83 ea 30             	sub    $0x30,%edx
  800f8a:	eb dd                	jmp    800f69 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800f8c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f8f:	89 f3                	mov    %esi,%ebx
  800f91:	80 fb 19             	cmp    $0x19,%bl
  800f94:	77 08                	ja     800f9e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800f96:	0f be d2             	movsbl %dl,%edx
  800f99:	83 ea 37             	sub    $0x37,%edx
  800f9c:	eb cb                	jmp    800f69 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800f9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fa2:	74 05                	je     800fa9 <strtol+0xd0>
		*endptr = (char *) s;
  800fa4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fa7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800fa9:	89 c2                	mov    %eax,%edx
  800fab:	f7 da                	neg    %edx
  800fad:	85 ff                	test   %edi,%edi
  800faf:	0f 45 c2             	cmovne %edx,%eax
}
  800fb2:	5b                   	pop    %ebx
  800fb3:	5e                   	pop    %esi
  800fb4:	5f                   	pop    %edi
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	57                   	push   %edi
  800fbb:	56                   	push   %esi
  800fbc:	53                   	push   %ebx
  800fbd:	83 ec 1c             	sub    $0x1c,%esp
  800fc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fc3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800fc6:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fce:	8b 7d 10             	mov    0x10(%ebp),%edi
  800fd1:	8b 75 14             	mov    0x14(%ebp),%esi
  800fd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fd6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fda:	74 04                	je     800fe0 <syscall+0x29>
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	7f 08                	jg     800fe8 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800fe0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe3:	5b                   	pop    %ebx
  800fe4:	5e                   	pop    %esi
  800fe5:	5f                   	pop    %edi
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    
  800fe8:	8b 55 e0             	mov    -0x20(%ebp),%edx
		panic("syscall %d returned %d (> 0)", num, ret);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	50                   	push   %eax
  800fef:	52                   	push   %edx
  800ff0:	68 e4 17 80 00       	push   $0x8017e4
  800ff5:	6a 23                	push   $0x23
  800ff7:	68 01 18 80 00       	push   $0x801801
  800ffc:	e8 3a f6 ff ff       	call   80063b <_panic>

00801001 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801007:	6a 00                	push   $0x0
  801009:	6a 00                	push   $0x0
  80100b:	6a 00                	push   $0x0
  80100d:	ff 75 0c             	pushl  0xc(%ebp)
  801010:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801013:	ba 00 00 00 00       	mov    $0x0,%edx
  801018:	b8 00 00 00 00       	mov    $0x0,%eax
  80101d:	e8 95 ff ff ff       	call   800fb7 <syscall>
}
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <sys_cgetc>:

int
sys_cgetc(void)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80102d:	6a 00                	push   $0x0
  80102f:	6a 00                	push   $0x0
  801031:	6a 00                	push   $0x0
  801033:	6a 00                	push   $0x0
  801035:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103a:	ba 00 00 00 00       	mov    $0x0,%edx
  80103f:	b8 01 00 00 00       	mov    $0x1,%eax
  801044:	e8 6e ff ff ff       	call   800fb7 <syscall>
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801051:	6a 00                	push   $0x0
  801053:	6a 00                	push   $0x0
  801055:	6a 00                	push   $0x0
  801057:	6a 00                	push   $0x0
  801059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105c:	ba 01 00 00 00       	mov    $0x1,%edx
  801061:	b8 03 00 00 00       	mov    $0x3,%eax
  801066:	e8 4c ff ff ff       	call   800fb7 <syscall>
}
  80106b:	c9                   	leave  
  80106c:	c3                   	ret    

0080106d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801073:	6a 00                	push   $0x0
  801075:	6a 00                	push   $0x0
  801077:	6a 00                	push   $0x0
  801079:	6a 00                	push   $0x0
  80107b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801080:	ba 00 00 00 00       	mov    $0x0,%edx
  801085:	b8 02 00 00 00       	mov    $0x2,%eax
  80108a:	e8 28 ff ff ff       	call   800fb7 <syscall>
}
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <sys_yield>:

void
sys_yield(void)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801097:	6a 00                	push   $0x0
  801099:	6a 00                	push   $0x0
  80109b:	6a 00                	push   $0x0
  80109d:	6a 00                	push   $0x0
  80109f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ae:	e8 04 ff ff ff       	call   800fb7 <syscall>
}
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8010be:	6a 00                	push   $0x0
  8010c0:	6a 00                	push   $0x0
  8010c2:	ff 75 10             	pushl  0x10(%ebp)
  8010c5:	ff 75 0c             	pushl  0xc(%ebp)
  8010c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cb:	ba 01 00 00 00       	mov    $0x1,%edx
  8010d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010d5:	e8 dd fe ff ff       	call   800fb7 <syscall>
}
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010e2:	ff 75 18             	pushl  0x18(%ebp)
  8010e5:	ff 75 14             	pushl  0x14(%ebp)
  8010e8:	ff 75 10             	pushl  0x10(%ebp)
  8010eb:	ff 75 0c             	pushl  0xc(%ebp)
  8010ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f1:	ba 01 00 00 00       	mov    $0x1,%edx
  8010f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8010fb:	e8 b7 fe ff ff       	call   800fb7 <syscall>
}
  801100:	c9                   	leave  
  801101:	c3                   	ret    

00801102 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801108:	6a 00                	push   $0x0
  80110a:	6a 00                	push   $0x0
  80110c:	6a 00                	push   $0x0
  80110e:	ff 75 0c             	pushl  0xc(%ebp)
  801111:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801114:	ba 01 00 00 00       	mov    $0x1,%edx
  801119:	b8 06 00 00 00       	mov    $0x6,%eax
  80111e:	e8 94 fe ff ff       	call   800fb7 <syscall>
}
  801123:	c9                   	leave  
  801124:	c3                   	ret    

00801125 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80112b:	6a 00                	push   $0x0
  80112d:	6a 00                	push   $0x0
  80112f:	6a 00                	push   $0x0
  801131:	ff 75 0c             	pushl  0xc(%ebp)
  801134:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801137:	ba 01 00 00 00       	mov    $0x1,%edx
  80113c:	b8 08 00 00 00       	mov    $0x8,%eax
  801141:	e8 71 fe ff ff       	call   800fb7 <syscall>
}
  801146:	c9                   	leave  
  801147:	c3                   	ret    

00801148 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80114e:	6a 00                	push   $0x0
  801150:	6a 00                	push   $0x0
  801152:	6a 00                	push   $0x0
  801154:	ff 75 0c             	pushl  0xc(%ebp)
  801157:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115a:	ba 01 00 00 00       	mov    $0x1,%edx
  80115f:	b8 09 00 00 00       	mov    $0x9,%eax
  801164:	e8 4e fe ff ff       	call   800fb7 <syscall>
}
  801169:	c9                   	leave  
  80116a:	c3                   	ret    

0080116b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801171:	6a 00                	push   $0x0
  801173:	ff 75 14             	pushl  0x14(%ebp)
  801176:	ff 75 10             	pushl  0x10(%ebp)
  801179:	ff 75 0c             	pushl  0xc(%ebp)
  80117c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117f:	ba 00 00 00 00       	mov    $0x0,%edx
  801184:	b8 0b 00 00 00       	mov    $0xb,%eax
  801189:	e8 29 fe ff ff       	call   800fb7 <syscall>
}
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801196:	6a 00                	push   $0x0
  801198:	6a 00                	push   $0x0
  80119a:	6a 00                	push   $0x0
  80119c:	6a 00                	push   $0x0
  80119e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a1:	ba 01 00 00 00       	mov    $0x1,%edx
  8011a6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011ab:	e8 07 fe ff ff       	call   800fb7 <syscall>
}
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011b8:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  8011bf:	74 0a                	je     8011cb <set_pgfault_handler+0x19>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		if (r < 0) return;
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c4:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8011c9:	c9                   	leave  
  8011ca:	c3                   	ret    
		r = sys_page_alloc(0, (void*)exstk, perm);
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	6a 07                	push   $0x7
  8011d0:	68 00 f0 bf ee       	push   $0xeebff000
  8011d5:	6a 00                	push   $0x0
  8011d7:	e8 dc fe ff ff       	call   8010b8 <sys_page_alloc>
		if (r < 0) return;
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 e6                	js     8011c9 <set_pgfault_handler+0x17>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	68 fb 11 80 00       	push   $0x8011fb
  8011eb:	6a 00                	push   $0x0
  8011ed:	e8 56 ff ff ff       	call   801148 <sys_env_set_pgfault_upcall>
		if (r < 0) return;
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	79 c8                	jns    8011c1 <set_pgfault_handler+0xf>
  8011f9:	eb ce                	jmp    8011c9 <set_pgfault_handler+0x17>

008011fb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011fb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011fc:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801201:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801203:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 40(%esp), %eax	// trap-time %epi -> %eax 
  801206:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	// trap-time %esp -> %ebx
  80120a:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80120e:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, 0(%ebx)	// push %eip in trap-time stack
  801211:	89 03                	mov    %eax,(%ebx)

	movl %ebx, 48(%esp)
  801213:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	popl %eax
  801217:	58                   	pop    %eax
	popl %eax
  801218:	58                   	pop    %eax
	popal
  801219:	61                   	popa   
	

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  80121a:	83 c4 04             	add    $0x4,%esp
	popfl
  80121d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  80121e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  80121f:	c3                   	ret    

00801220 <__udivdi3>:
  801220:	55                   	push   %ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 1c             	sub    $0x1c,%esp
  801227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80122b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80122f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801233:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801237:	85 d2                	test   %edx,%edx
  801239:	75 35                	jne    801270 <__udivdi3+0x50>
  80123b:	39 f3                	cmp    %esi,%ebx
  80123d:	0f 87 bd 00 00 00    	ja     801300 <__udivdi3+0xe0>
  801243:	85 db                	test   %ebx,%ebx
  801245:	89 d9                	mov    %ebx,%ecx
  801247:	75 0b                	jne    801254 <__udivdi3+0x34>
  801249:	b8 01 00 00 00       	mov    $0x1,%eax
  80124e:	31 d2                	xor    %edx,%edx
  801250:	f7 f3                	div    %ebx
  801252:	89 c1                	mov    %eax,%ecx
  801254:	31 d2                	xor    %edx,%edx
  801256:	89 f0                	mov    %esi,%eax
  801258:	f7 f1                	div    %ecx
  80125a:	89 c6                	mov    %eax,%esi
  80125c:	89 e8                	mov    %ebp,%eax
  80125e:	89 f7                	mov    %esi,%edi
  801260:	f7 f1                	div    %ecx
  801262:	89 fa                	mov    %edi,%edx
  801264:	83 c4 1c             	add    $0x1c,%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5f                   	pop    %edi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	39 f2                	cmp    %esi,%edx
  801272:	77 7c                	ja     8012f0 <__udivdi3+0xd0>
  801274:	0f bd fa             	bsr    %edx,%edi
  801277:	83 f7 1f             	xor    $0x1f,%edi
  80127a:	0f 84 98 00 00 00    	je     801318 <__udivdi3+0xf8>
  801280:	89 f9                	mov    %edi,%ecx
  801282:	b8 20 00 00 00       	mov    $0x20,%eax
  801287:	29 f8                	sub    %edi,%eax
  801289:	d3 e2                	shl    %cl,%edx
  80128b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80128f:	89 c1                	mov    %eax,%ecx
  801291:	89 da                	mov    %ebx,%edx
  801293:	d3 ea                	shr    %cl,%edx
  801295:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801299:	09 d1                	or     %edx,%ecx
  80129b:	89 f2                	mov    %esi,%edx
  80129d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012a1:	89 f9                	mov    %edi,%ecx
  8012a3:	d3 e3                	shl    %cl,%ebx
  8012a5:	89 c1                	mov    %eax,%ecx
  8012a7:	d3 ea                	shr    %cl,%edx
  8012a9:	89 f9                	mov    %edi,%ecx
  8012ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012af:	d3 e6                	shl    %cl,%esi
  8012b1:	89 eb                	mov    %ebp,%ebx
  8012b3:	89 c1                	mov    %eax,%ecx
  8012b5:	d3 eb                	shr    %cl,%ebx
  8012b7:	09 de                	or     %ebx,%esi
  8012b9:	89 f0                	mov    %esi,%eax
  8012bb:	f7 74 24 08          	divl   0x8(%esp)
  8012bf:	89 d6                	mov    %edx,%esi
  8012c1:	89 c3                	mov    %eax,%ebx
  8012c3:	f7 64 24 0c          	mull   0xc(%esp)
  8012c7:	39 d6                	cmp    %edx,%esi
  8012c9:	72 0c                	jb     8012d7 <__udivdi3+0xb7>
  8012cb:	89 f9                	mov    %edi,%ecx
  8012cd:	d3 e5                	shl    %cl,%ebp
  8012cf:	39 c5                	cmp    %eax,%ebp
  8012d1:	73 5d                	jae    801330 <__udivdi3+0x110>
  8012d3:	39 d6                	cmp    %edx,%esi
  8012d5:	75 59                	jne    801330 <__udivdi3+0x110>
  8012d7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8012da:	31 ff                	xor    %edi,%edi
  8012dc:	89 fa                	mov    %edi,%edx
  8012de:	83 c4 1c             	add    $0x1c,%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    
  8012e6:	8d 76 00             	lea    0x0(%esi),%esi
  8012e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8012f0:	31 ff                	xor    %edi,%edi
  8012f2:	31 c0                	xor    %eax,%eax
  8012f4:	89 fa                	mov    %edi,%edx
  8012f6:	83 c4 1c             	add    $0x1c,%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5f                   	pop    %edi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    
  8012fe:	66 90                	xchg   %ax,%ax
  801300:	31 ff                	xor    %edi,%edi
  801302:	89 e8                	mov    %ebp,%eax
  801304:	89 f2                	mov    %esi,%edx
  801306:	f7 f3                	div    %ebx
  801308:	89 fa                	mov    %edi,%edx
  80130a:	83 c4 1c             	add    $0x1c,%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5f                   	pop    %edi
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    
  801312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801318:	39 f2                	cmp    %esi,%edx
  80131a:	72 06                	jb     801322 <__udivdi3+0x102>
  80131c:	31 c0                	xor    %eax,%eax
  80131e:	39 eb                	cmp    %ebp,%ebx
  801320:	77 d2                	ja     8012f4 <__udivdi3+0xd4>
  801322:	b8 01 00 00 00       	mov    $0x1,%eax
  801327:	eb cb                	jmp    8012f4 <__udivdi3+0xd4>
  801329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801330:	89 d8                	mov    %ebx,%eax
  801332:	31 ff                	xor    %edi,%edi
  801334:	eb be                	jmp    8012f4 <__udivdi3+0xd4>
  801336:	66 90                	xchg   %ax,%ax
  801338:	66 90                	xchg   %ax,%ax
  80133a:	66 90                	xchg   %ax,%ax
  80133c:	66 90                	xchg   %ax,%ax
  80133e:	66 90                	xchg   %ax,%ax

00801340 <__umoddi3>:
  801340:	55                   	push   %ebp
  801341:	57                   	push   %edi
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	83 ec 1c             	sub    $0x1c,%esp
  801347:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80134b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80134f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801357:	85 ed                	test   %ebp,%ebp
  801359:	89 f0                	mov    %esi,%eax
  80135b:	89 da                	mov    %ebx,%edx
  80135d:	75 19                	jne    801378 <__umoddi3+0x38>
  80135f:	39 df                	cmp    %ebx,%edi
  801361:	0f 86 b1 00 00 00    	jbe    801418 <__umoddi3+0xd8>
  801367:	f7 f7                	div    %edi
  801369:	89 d0                	mov    %edx,%eax
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	83 c4 1c             	add    $0x1c,%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    
  801375:	8d 76 00             	lea    0x0(%esi),%esi
  801378:	39 dd                	cmp    %ebx,%ebp
  80137a:	77 f1                	ja     80136d <__umoddi3+0x2d>
  80137c:	0f bd cd             	bsr    %ebp,%ecx
  80137f:	83 f1 1f             	xor    $0x1f,%ecx
  801382:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801386:	0f 84 b4 00 00 00    	je     801440 <__umoddi3+0x100>
  80138c:	b8 20 00 00 00       	mov    $0x20,%eax
  801391:	89 c2                	mov    %eax,%edx
  801393:	8b 44 24 04          	mov    0x4(%esp),%eax
  801397:	29 c2                	sub    %eax,%edx
  801399:	89 c1                	mov    %eax,%ecx
  80139b:	89 f8                	mov    %edi,%eax
  80139d:	d3 e5                	shl    %cl,%ebp
  80139f:	89 d1                	mov    %edx,%ecx
  8013a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013a5:	d3 e8                	shr    %cl,%eax
  8013a7:	09 c5                	or     %eax,%ebp
  8013a9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013ad:	89 c1                	mov    %eax,%ecx
  8013af:	d3 e7                	shl    %cl,%edi
  8013b1:	89 d1                	mov    %edx,%ecx
  8013b3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013b7:	89 df                	mov    %ebx,%edi
  8013b9:	d3 ef                	shr    %cl,%edi
  8013bb:	89 c1                	mov    %eax,%ecx
  8013bd:	89 f0                	mov    %esi,%eax
  8013bf:	d3 e3                	shl    %cl,%ebx
  8013c1:	89 d1                	mov    %edx,%ecx
  8013c3:	89 fa                	mov    %edi,%edx
  8013c5:	d3 e8                	shr    %cl,%eax
  8013c7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013cc:	09 d8                	or     %ebx,%eax
  8013ce:	f7 f5                	div    %ebp
  8013d0:	d3 e6                	shl    %cl,%esi
  8013d2:	89 d1                	mov    %edx,%ecx
  8013d4:	f7 64 24 08          	mull   0x8(%esp)
  8013d8:	39 d1                	cmp    %edx,%ecx
  8013da:	89 c3                	mov    %eax,%ebx
  8013dc:	89 d7                	mov    %edx,%edi
  8013de:	72 06                	jb     8013e6 <__umoddi3+0xa6>
  8013e0:	75 0e                	jne    8013f0 <__umoddi3+0xb0>
  8013e2:	39 c6                	cmp    %eax,%esi
  8013e4:	73 0a                	jae    8013f0 <__umoddi3+0xb0>
  8013e6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8013ea:	19 ea                	sbb    %ebp,%edx
  8013ec:	89 d7                	mov    %edx,%edi
  8013ee:	89 c3                	mov    %eax,%ebx
  8013f0:	89 ca                	mov    %ecx,%edx
  8013f2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8013f7:	29 de                	sub    %ebx,%esi
  8013f9:	19 fa                	sbb    %edi,%edx
  8013fb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8013ff:	89 d0                	mov    %edx,%eax
  801401:	d3 e0                	shl    %cl,%eax
  801403:	89 d9                	mov    %ebx,%ecx
  801405:	d3 ee                	shr    %cl,%esi
  801407:	d3 ea                	shr    %cl,%edx
  801409:	09 f0                	or     %esi,%eax
  80140b:	83 c4 1c             	add    $0x1c,%esp
  80140e:	5b                   	pop    %ebx
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	85 ff                	test   %edi,%edi
  80141a:	89 f9                	mov    %edi,%ecx
  80141c:	75 0b                	jne    801429 <__umoddi3+0xe9>
  80141e:	b8 01 00 00 00       	mov    $0x1,%eax
  801423:	31 d2                	xor    %edx,%edx
  801425:	f7 f7                	div    %edi
  801427:	89 c1                	mov    %eax,%ecx
  801429:	89 d8                	mov    %ebx,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	f7 f1                	div    %ecx
  80142f:	89 f0                	mov    %esi,%eax
  801431:	f7 f1                	div    %ecx
  801433:	e9 31 ff ff ff       	jmp    801369 <__umoddi3+0x29>
  801438:	90                   	nop
  801439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801440:	39 dd                	cmp    %ebx,%ebp
  801442:	72 08                	jb     80144c <__umoddi3+0x10c>
  801444:	39 f7                	cmp    %esi,%edi
  801446:	0f 87 21 ff ff ff    	ja     80136d <__umoddi3+0x2d>
  80144c:	89 da                	mov    %ebx,%edx
  80144e:	89 f0                	mov    %esi,%eax
  801450:	29 f8                	sub    %edi,%eax
  801452:	19 ea                	sbb    %ebp,%edx
  801454:	e9 14 ff ff ff       	jmp    80136d <__umoddi3+0x2d>
