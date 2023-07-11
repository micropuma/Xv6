
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	97813103          	ld	sp,-1672(sp) # 80008978 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	c6478793          	addi	a5,a5,-924 # 80005cc0 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e4c78793          	addi	a5,a5,-436 # 80000ef2 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	b3c080e7          	jalr	-1220(ra) # 80000c48 <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	3b6080e7          	jalr	950(ra) # 800024dc <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	796080e7          	jalr	1942(ra) # 800008cc <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	bae080e7          	jalr	-1106(ra) # 80000cfc <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7159                	addi	sp,sp,-112
    80000170:	f486                	sd	ra,104(sp)
    80000172:	f0a2                	sd	s0,96(sp)
    80000174:	eca6                	sd	s1,88(sp)
    80000176:	e8ca                	sd	s2,80(sp)
    80000178:	e4ce                	sd	s3,72(sp)
    8000017a:	e0d2                	sd	s4,64(sp)
    8000017c:	fc56                	sd	s5,56(sp)
    8000017e:	f85a                	sd	s6,48(sp)
    80000180:	f45e                	sd	s7,40(sp)
    80000182:	f062                	sd	s8,32(sp)
    80000184:	ec66                	sd	s9,24(sp)
    80000186:	e86a                	sd	s10,16(sp)
    80000188:	1880                	addi	s0,sp,112
    8000018a:	8aaa                	mv	s5,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000194:	00011517          	auipc	a0,0x11
    80000198:	69c50513          	addi	a0,a0,1692 # 80011830 <cons>
    8000019c:	00001097          	auipc	ra,0x1
    800001a0:	aac080e7          	jalr	-1364(ra) # 80000c48 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a4:	00011497          	auipc	s1,0x11
    800001a8:	68c48493          	addi	s1,s1,1676 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ac:	00011917          	auipc	s2,0x11
    800001b0:	71c90913          	addi	s2,s2,1820 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b4:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b6:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b8:	4ca9                	li	s9,10
  while(n > 0){
    800001ba:	07305863          	blez	s3,8000022a <consoleread+0xbc>
    while(cons.r == cons.w){
    800001be:	0984a783          	lw	a5,152(s1)
    800001c2:	09c4a703          	lw	a4,156(s1)
    800001c6:	02f71463          	bne	a4,a5,800001ee <consoleread+0x80>
      if(myproc()->killed){
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	84a080e7          	jalr	-1974(ra) # 80001a14 <myproc>
    800001d2:	591c                	lw	a5,48(a0)
    800001d4:	e7b5                	bnez	a5,80000240 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	052080e7          	jalr	82(ra) # 8000222c <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fef700e3          	beq	a4,a5,800001ca <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000204:	077d0563          	beq	s10,s7,8000026e <consoleread+0x100>
    cbuf = c;
    80000208:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f9f40613          	addi	a2,s0,-97
    80000212:	85d2                	mv	a1,s4
    80000214:	8556                	mv	a0,s5
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	270080e7          	jalr	624(ra) # 80002486 <either_copyout>
    8000021e:	01850663          	beq	a0,s8,8000022a <consoleread+0xbc>
    dst++;
    80000222:	0a05                	addi	s4,s4,1
    --n;
    80000224:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000226:	f99d1ae3          	bne	s10,s9,800001ba <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	60650513          	addi	a0,a0,1542 # 80011830 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	aca080e7          	jalr	-1334(ra) # 80000cfc <release>

  return target - n;
    8000023a:	413b053b          	subw	a0,s6,s3
    8000023e:	a811                	j	80000252 <consoleread+0xe4>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	5f050513          	addi	a0,a0,1520 # 80011830 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	ab4080e7          	jalr	-1356(ra) # 80000cfc <release>
        return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70a6                	ld	ra,104(sp)
    80000254:	7406                	ld	s0,96(sp)
    80000256:	64e6                	ld	s1,88(sp)
    80000258:	6946                	ld	s2,80(sp)
    8000025a:	69a6                	ld	s3,72(sp)
    8000025c:	6a06                	ld	s4,64(sp)
    8000025e:	7ae2                	ld	s5,56(sp)
    80000260:	7b42                	ld	s6,48(sp)
    80000262:	7ba2                	ld	s7,40(sp)
    80000264:	7c02                	ld	s8,32(sp)
    80000266:	6ce2                	ld	s9,24(sp)
    80000268:	6d42                	ld	s10,16(sp)
    8000026a:	6165                	addi	sp,sp,112
    8000026c:	8082                	ret
      if(n < target){
    8000026e:	0009871b          	sext.w	a4,s3
    80000272:	fb677ce3          	bgeu	a4,s6,8000022a <consoleread+0xbc>
        cons.r--;
    80000276:	00011717          	auipc	a4,0x11
    8000027a:	64f72923          	sw	a5,1618(a4) # 800118c8 <cons+0x98>
    8000027e:	b775                	j	8000022a <consoleread+0xbc>

0000000080000280 <consputc>:
{
    80000280:	1141                	addi	sp,sp,-16
    80000282:	e406                	sd	ra,8(sp)
    80000284:	e022                	sd	s0,0(sp)
    80000286:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000288:	10000793          	li	a5,256
    8000028c:	00f50a63          	beq	a0,a5,800002a0 <consputc+0x20>
    uartputc_sync(c);
    80000290:	00000097          	auipc	ra,0x0
    80000294:	55e080e7          	jalr	1374(ra) # 800007ee <uartputc_sync>
}
    80000298:	60a2                	ld	ra,8(sp)
    8000029a:	6402                	ld	s0,0(sp)
    8000029c:	0141                	addi	sp,sp,16
    8000029e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a0:	4521                	li	a0,8
    800002a2:	00000097          	auipc	ra,0x0
    800002a6:	54c080e7          	jalr	1356(ra) # 800007ee <uartputc_sync>
    800002aa:	02000513          	li	a0,32
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	540080e7          	jalr	1344(ra) # 800007ee <uartputc_sync>
    800002b6:	4521                	li	a0,8
    800002b8:	00000097          	auipc	ra,0x0
    800002bc:	536080e7          	jalr	1334(ra) # 800007ee <uartputc_sync>
    800002c0:	bfe1                	j	80000298 <consputc+0x18>

00000000800002c2 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c2:	1101                	addi	sp,sp,-32
    800002c4:	ec06                	sd	ra,24(sp)
    800002c6:	e822                	sd	s0,16(sp)
    800002c8:	e426                	sd	s1,8(sp)
    800002ca:	e04a                	sd	s2,0(sp)
    800002cc:	1000                	addi	s0,sp,32
    800002ce:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d0:	00011517          	auipc	a0,0x11
    800002d4:	56050513          	addi	a0,a0,1376 # 80011830 <cons>
    800002d8:	00001097          	auipc	ra,0x1
    800002dc:	970080e7          	jalr	-1680(ra) # 80000c48 <acquire>

  switch(c){
    800002e0:	47d5                	li	a5,21
    800002e2:	0af48663          	beq	s1,a5,8000038e <consoleintr+0xcc>
    800002e6:	0297ca63          	blt	a5,s1,8000031a <consoleintr+0x58>
    800002ea:	47a1                	li	a5,8
    800002ec:	0ef48763          	beq	s1,a5,800003da <consoleintr+0x118>
    800002f0:	47c1                	li	a5,16
    800002f2:	10f49a63          	bne	s1,a5,80000406 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f6:	00002097          	auipc	ra,0x2
    800002fa:	23c080e7          	jalr	572(ra) # 80002532 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fe:	00011517          	auipc	a0,0x11
    80000302:	53250513          	addi	a0,a0,1330 # 80011830 <cons>
    80000306:	00001097          	auipc	ra,0x1
    8000030a:	9f6080e7          	jalr	-1546(ra) # 80000cfc <release>
}
    8000030e:	60e2                	ld	ra,24(sp)
    80000310:	6442                	ld	s0,16(sp)
    80000312:	64a2                	ld	s1,8(sp)
    80000314:	6902                	ld	s2,0(sp)
    80000316:	6105                	addi	sp,sp,32
    80000318:	8082                	ret
  switch(c){
    8000031a:	07f00793          	li	a5,127
    8000031e:	0af48e63          	beq	s1,a5,800003da <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000322:	00011717          	auipc	a4,0x11
    80000326:	50e70713          	addi	a4,a4,1294 # 80011830 <cons>
    8000032a:	0a072783          	lw	a5,160(a4)
    8000032e:	09872703          	lw	a4,152(a4)
    80000332:	9f99                	subw	a5,a5,a4
    80000334:	07f00713          	li	a4,127
    80000338:	fcf763e3          	bltu	a4,a5,800002fe <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033c:	47b5                	li	a5,13
    8000033e:	0cf48763          	beq	s1,a5,8000040c <consoleintr+0x14a>
      consputc(c);
    80000342:	8526                	mv	a0,s1
    80000344:	00000097          	auipc	ra,0x0
    80000348:	f3c080e7          	jalr	-196(ra) # 80000280 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000034c:	00011797          	auipc	a5,0x11
    80000350:	4e478793          	addi	a5,a5,1252 # 80011830 <cons>
    80000354:	0a07a703          	lw	a4,160(a5)
    80000358:	0017069b          	addiw	a3,a4,1
    8000035c:	0006861b          	sext.w	a2,a3
    80000360:	0ad7a023          	sw	a3,160(a5)
    80000364:	07f77713          	andi	a4,a4,127
    80000368:	97ba                	add	a5,a5,a4
    8000036a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000036e:	47a9                	li	a5,10
    80000370:	0cf48563          	beq	s1,a5,8000043a <consoleintr+0x178>
    80000374:	4791                	li	a5,4
    80000376:	0cf48263          	beq	s1,a5,8000043a <consoleintr+0x178>
    8000037a:	00011797          	auipc	a5,0x11
    8000037e:	54e7a783          	lw	a5,1358(a5) # 800118c8 <cons+0x98>
    80000382:	0807879b          	addiw	a5,a5,128
    80000386:	f6f61ce3          	bne	a2,a5,800002fe <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000038a:	863e                	mv	a2,a5
    8000038c:	a07d                	j	8000043a <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038e:	00011717          	auipc	a4,0x11
    80000392:	4a270713          	addi	a4,a4,1186 # 80011830 <cons>
    80000396:	0a072783          	lw	a5,160(a4)
    8000039a:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039e:	00011497          	auipc	s1,0x11
    800003a2:	49248493          	addi	s1,s1,1170 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003a6:	4929                	li	s2,10
    800003a8:	f4f70be3          	beq	a4,a5,800002fe <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ac:	37fd                	addiw	a5,a5,-1
    800003ae:	07f7f713          	andi	a4,a5,127
    800003b2:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b4:	01874703          	lbu	a4,24(a4)
    800003b8:	f52703e3          	beq	a4,s2,800002fe <consoleintr+0x3c>
      cons.e--;
    800003bc:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c0:	10000513          	li	a0,256
    800003c4:	00000097          	auipc	ra,0x0
    800003c8:	ebc080e7          	jalr	-324(ra) # 80000280 <consputc>
    while(cons.e != cons.w &&
    800003cc:	0a04a783          	lw	a5,160(s1)
    800003d0:	09c4a703          	lw	a4,156(s1)
    800003d4:	fcf71ce3          	bne	a4,a5,800003ac <consoleintr+0xea>
    800003d8:	b71d                	j	800002fe <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003da:	00011717          	auipc	a4,0x11
    800003de:	45670713          	addi	a4,a4,1110 # 80011830 <cons>
    800003e2:	0a072783          	lw	a5,160(a4)
    800003e6:	09c72703          	lw	a4,156(a4)
    800003ea:	f0f70ae3          	beq	a4,a5,800002fe <consoleintr+0x3c>
      cons.e--;
    800003ee:	37fd                	addiw	a5,a5,-1
    800003f0:	00011717          	auipc	a4,0x11
    800003f4:	4ef72023          	sw	a5,1248(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f8:	10000513          	li	a0,256
    800003fc:	00000097          	auipc	ra,0x0
    80000400:	e84080e7          	jalr	-380(ra) # 80000280 <consputc>
    80000404:	bded                	j	800002fe <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000406:	ee048ce3          	beqz	s1,800002fe <consoleintr+0x3c>
    8000040a:	bf21                	j	80000322 <consoleintr+0x60>
      consputc(c);
    8000040c:	4529                	li	a0,10
    8000040e:	00000097          	auipc	ra,0x0
    80000412:	e72080e7          	jalr	-398(ra) # 80000280 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000416:	00011797          	auipc	a5,0x11
    8000041a:	41a78793          	addi	a5,a5,1050 # 80011830 <cons>
    8000041e:	0a07a703          	lw	a4,160(a5)
    80000422:	0017069b          	addiw	a3,a4,1
    80000426:	0006861b          	sext.w	a2,a3
    8000042a:	0ad7a023          	sw	a3,160(a5)
    8000042e:	07f77713          	andi	a4,a4,127
    80000432:	97ba                	add	a5,a5,a4
    80000434:	4729                	li	a4,10
    80000436:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043a:	00011797          	auipc	a5,0x11
    8000043e:	48c7a923          	sw	a2,1170(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000442:	00011517          	auipc	a0,0x11
    80000446:	48650513          	addi	a0,a0,1158 # 800118c8 <cons+0x98>
    8000044a:	00002097          	auipc	ra,0x2
    8000044e:	f62080e7          	jalr	-158(ra) # 800023ac <wakeup>
    80000452:	b575                	j	800002fe <consoleintr+0x3c>

0000000080000454 <consoleinit>:

void
consoleinit(void)
{
    80000454:	1141                	addi	sp,sp,-16
    80000456:	e406                	sd	ra,8(sp)
    80000458:	e022                	sd	s0,0(sp)
    8000045a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045c:	00008597          	auipc	a1,0x8
    80000460:	bb458593          	addi	a1,a1,-1100 # 80008010 <etext+0x10>
    80000464:	00011517          	auipc	a0,0x11
    80000468:	3cc50513          	addi	a0,a0,972 # 80011830 <cons>
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	74c080e7          	jalr	1868(ra) # 80000bb8 <initlock>

  uartinit();
    80000474:	00000097          	auipc	ra,0x0
    80000478:	32a080e7          	jalr	810(ra) # 8000079e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047c:	00021797          	auipc	a5,0x21
    80000480:	73478793          	addi	a5,a5,1844 # 80021bb0 <devsw>
    80000484:	00000717          	auipc	a4,0x0
    80000488:	cea70713          	addi	a4,a4,-790 # 8000016e <consoleread>
    8000048c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048e:	00000717          	auipc	a4,0x0
    80000492:	c5e70713          	addi	a4,a4,-930 # 800000ec <consolewrite>
    80000496:	ef98                	sd	a4,24(a5)
}
    80000498:	60a2                	ld	ra,8(sp)
    8000049a:	6402                	ld	s0,0(sp)
    8000049c:	0141                	addi	sp,sp,16
    8000049e:	8082                	ret

00000000800004a0 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a0:	7179                	addi	sp,sp,-48
    800004a2:	f406                	sd	ra,40(sp)
    800004a4:	f022                	sd	s0,32(sp)
    800004a6:	ec26                	sd	s1,24(sp)
    800004a8:	e84a                	sd	s2,16(sp)
    800004aa:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ac:	c219                	beqz	a2,800004b2 <printint+0x12>
    800004ae:	08054663          	bltz	a0,8000053a <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b2:	2501                	sext.w	a0,a0
    800004b4:	4881                	li	a7,0
    800004b6:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004ba:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004bc:	2581                	sext.w	a1,a1
    800004be:	00008617          	auipc	a2,0x8
    800004c2:	b8260613          	addi	a2,a2,-1150 # 80008040 <digits>
    800004c6:	883a                	mv	a6,a4
    800004c8:	2705                	addiw	a4,a4,1
    800004ca:	02b577bb          	remuw	a5,a0,a1
    800004ce:	1782                	slli	a5,a5,0x20
    800004d0:	9381                	srli	a5,a5,0x20
    800004d2:	97b2                	add	a5,a5,a2
    800004d4:	0007c783          	lbu	a5,0(a5)
    800004d8:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004dc:	0005079b          	sext.w	a5,a0
    800004e0:	02b5553b          	divuw	a0,a0,a1
    800004e4:	0685                	addi	a3,a3,1
    800004e6:	feb7f0e3          	bgeu	a5,a1,800004c6 <printint+0x26>

  if(sign)
    800004ea:	00088b63          	beqz	a7,80000500 <printint+0x60>
    buf[i++] = '-';
    800004ee:	fe040793          	addi	a5,s0,-32
    800004f2:	973e                	add	a4,a4,a5
    800004f4:	02d00793          	li	a5,45
    800004f8:	fef70823          	sb	a5,-16(a4)
    800004fc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000500:	02e05763          	blez	a4,8000052e <printint+0x8e>
    80000504:	fd040793          	addi	a5,s0,-48
    80000508:	00e784b3          	add	s1,a5,a4
    8000050c:	fff78913          	addi	s2,a5,-1
    80000510:	993a                	add	s2,s2,a4
    80000512:	377d                	addiw	a4,a4,-1
    80000514:	1702                	slli	a4,a4,0x20
    80000516:	9301                	srli	a4,a4,0x20
    80000518:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051c:	fff4c503          	lbu	a0,-1(s1)
    80000520:	00000097          	auipc	ra,0x0
    80000524:	d60080e7          	jalr	-672(ra) # 80000280 <consputc>
  while(--i >= 0)
    80000528:	14fd                	addi	s1,s1,-1
    8000052a:	ff2499e3          	bne	s1,s2,8000051c <printint+0x7c>
}
    8000052e:	70a2                	ld	ra,40(sp)
    80000530:	7402                	ld	s0,32(sp)
    80000532:	64e2                	ld	s1,24(sp)
    80000534:	6942                	ld	s2,16(sp)
    80000536:	6145                	addi	sp,sp,48
    80000538:	8082                	ret
    x = -xx;
    8000053a:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053e:	4885                	li	a7,1
    x = -xx;
    80000540:	bf9d                	j	800004b6 <printint+0x16>

0000000080000542 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000542:	1101                	addi	sp,sp,-32
    80000544:	ec06                	sd	ra,24(sp)
    80000546:	e822                	sd	s0,16(sp)
    80000548:	e426                	sd	s1,8(sp)
    8000054a:	1000                	addi	s0,sp,32
    8000054c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054e:	00011797          	auipc	a5,0x11
    80000552:	3a07a123          	sw	zero,930(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    80000556:	00008517          	auipc	a0,0x8
    8000055a:	ac250513          	addi	a0,a0,-1342 # 80008018 <etext+0x18>
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	02e080e7          	jalr	46(ra) # 8000058c <printf>
  printf(s);
    80000566:	8526                	mv	a0,s1
    80000568:	00000097          	auipc	ra,0x0
    8000056c:	024080e7          	jalr	36(ra) # 8000058c <printf>
  printf("\n");
    80000570:	00008517          	auipc	a0,0x8
    80000574:	b5850513          	addi	a0,a0,-1192 # 800080c8 <digits+0x88>
    80000578:	00000097          	auipc	ra,0x0
    8000057c:	014080e7          	jalr	20(ra) # 8000058c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000580:	4785                	li	a5,1
    80000582:	00009717          	auipc	a4,0x9
    80000586:	a6f72f23          	sw	a5,-1410(a4) # 80009000 <panicked>
  for(;;)
    8000058a:	a001                	j	8000058a <panic+0x48>

000000008000058c <printf>:
{
    8000058c:	7131                	addi	sp,sp,-192
    8000058e:	fc86                	sd	ra,120(sp)
    80000590:	f8a2                	sd	s0,112(sp)
    80000592:	f4a6                	sd	s1,104(sp)
    80000594:	f0ca                	sd	s2,96(sp)
    80000596:	ecce                	sd	s3,88(sp)
    80000598:	e8d2                	sd	s4,80(sp)
    8000059a:	e4d6                	sd	s5,72(sp)
    8000059c:	e0da                	sd	s6,64(sp)
    8000059e:	fc5e                	sd	s7,56(sp)
    800005a0:	f862                	sd	s8,48(sp)
    800005a2:	f466                	sd	s9,40(sp)
    800005a4:	f06a                	sd	s10,32(sp)
    800005a6:	ec6e                	sd	s11,24(sp)
    800005a8:	0100                	addi	s0,sp,128
    800005aa:	8a2a                	mv	s4,a0
    800005ac:	e40c                	sd	a1,8(s0)
    800005ae:	e810                	sd	a2,16(s0)
    800005b0:	ec14                	sd	a3,24(s0)
    800005b2:	f018                	sd	a4,32(s0)
    800005b4:	f41c                	sd	a5,40(s0)
    800005b6:	03043823          	sd	a6,48(s0)
    800005ba:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005be:	00011d97          	auipc	s11,0x11
    800005c2:	332dad83          	lw	s11,818(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005c6:	020d9b63          	bnez	s11,800005fc <printf+0x70>
  if (fmt == 0)
    800005ca:	040a0263          	beqz	s4,8000060e <printf+0x82>
  va_start(ap, fmt);
    800005ce:	00840793          	addi	a5,s0,8
    800005d2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d6:	000a4503          	lbu	a0,0(s4)
    800005da:	14050f63          	beqz	a0,80000738 <printf+0x1ac>
    800005de:	4981                	li	s3,0
    if(c != '%'){
    800005e0:	02500a93          	li	s5,37
    switch(c){
    800005e4:	07000b93          	li	s7,112
  consputc('x');
    800005e8:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ea:	00008b17          	auipc	s6,0x8
    800005ee:	a56b0b13          	addi	s6,s6,-1450 # 80008040 <digits>
    switch(c){
    800005f2:	07300c93          	li	s9,115
    800005f6:	06400c13          	li	s8,100
    800005fa:	a82d                	j	80000634 <printf+0xa8>
    acquire(&pr.lock);
    800005fc:	00011517          	auipc	a0,0x11
    80000600:	2dc50513          	addi	a0,a0,732 # 800118d8 <pr>
    80000604:	00000097          	auipc	ra,0x0
    80000608:	644080e7          	jalr	1604(ra) # 80000c48 <acquire>
    8000060c:	bf7d                	j	800005ca <printf+0x3e>
    panic("null fmt");
    8000060e:	00008517          	auipc	a0,0x8
    80000612:	a1a50513          	addi	a0,a0,-1510 # 80008028 <etext+0x28>
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	f2c080e7          	jalr	-212(ra) # 80000542 <panic>
      consputc(c);
    8000061e:	00000097          	auipc	ra,0x0
    80000622:	c62080e7          	jalr	-926(ra) # 80000280 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000626:	2985                	addiw	s3,s3,1
    80000628:	013a07b3          	add	a5,s4,s3
    8000062c:	0007c503          	lbu	a0,0(a5)
    80000630:	10050463          	beqz	a0,80000738 <printf+0x1ac>
    if(c != '%'){
    80000634:	ff5515e3          	bne	a0,s5,8000061e <printf+0x92>
    c = fmt[++i] & 0xff;
    80000638:	2985                	addiw	s3,s3,1
    8000063a:	013a07b3          	add	a5,s4,s3
    8000063e:	0007c783          	lbu	a5,0(a5)
    80000642:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000646:	cbed                	beqz	a5,80000738 <printf+0x1ac>
    switch(c){
    80000648:	05778a63          	beq	a5,s7,8000069c <printf+0x110>
    8000064c:	02fbf663          	bgeu	s7,a5,80000678 <printf+0xec>
    80000650:	09978863          	beq	a5,s9,800006e0 <printf+0x154>
    80000654:	07800713          	li	a4,120
    80000658:	0ce79563          	bne	a5,a4,80000722 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065c:	f8843783          	ld	a5,-120(s0)
    80000660:	00878713          	addi	a4,a5,8
    80000664:	f8e43423          	sd	a4,-120(s0)
    80000668:	4605                	li	a2,1
    8000066a:	85ea                	mv	a1,s10
    8000066c:	4388                	lw	a0,0(a5)
    8000066e:	00000097          	auipc	ra,0x0
    80000672:	e32080e7          	jalr	-462(ra) # 800004a0 <printint>
      break;
    80000676:	bf45                	j	80000626 <printf+0x9a>
    switch(c){
    80000678:	09578f63          	beq	a5,s5,80000716 <printf+0x18a>
    8000067c:	0b879363          	bne	a5,s8,80000722 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000680:	f8843783          	ld	a5,-120(s0)
    80000684:	00878713          	addi	a4,a5,8
    80000688:	f8e43423          	sd	a4,-120(s0)
    8000068c:	4605                	li	a2,1
    8000068e:	45a9                	li	a1,10
    80000690:	4388                	lw	a0,0(a5)
    80000692:	00000097          	auipc	ra,0x0
    80000696:	e0e080e7          	jalr	-498(ra) # 800004a0 <printint>
      break;
    8000069a:	b771                	j	80000626 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069c:	f8843783          	ld	a5,-120(s0)
    800006a0:	00878713          	addi	a4,a5,8
    800006a4:	f8e43423          	sd	a4,-120(s0)
    800006a8:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006ac:	03000513          	li	a0,48
    800006b0:	00000097          	auipc	ra,0x0
    800006b4:	bd0080e7          	jalr	-1072(ra) # 80000280 <consputc>
  consputc('x');
    800006b8:	07800513          	li	a0,120
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	bc4080e7          	jalr	-1084(ra) # 80000280 <consputc>
    800006c4:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c6:	03c95793          	srli	a5,s2,0x3c
    800006ca:	97da                	add	a5,a5,s6
    800006cc:	0007c503          	lbu	a0,0(a5)
    800006d0:	00000097          	auipc	ra,0x0
    800006d4:	bb0080e7          	jalr	-1104(ra) # 80000280 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d8:	0912                	slli	s2,s2,0x4
    800006da:	34fd                	addiw	s1,s1,-1
    800006dc:	f4ed                	bnez	s1,800006c6 <printf+0x13a>
    800006de:	b7a1                	j	80000626 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e0:	f8843783          	ld	a5,-120(s0)
    800006e4:	00878713          	addi	a4,a5,8
    800006e8:	f8e43423          	sd	a4,-120(s0)
    800006ec:	6384                	ld	s1,0(a5)
    800006ee:	cc89                	beqz	s1,80000708 <printf+0x17c>
      for(; *s; s++)
    800006f0:	0004c503          	lbu	a0,0(s1)
    800006f4:	d90d                	beqz	a0,80000626 <printf+0x9a>
        consputc(*s);
    800006f6:	00000097          	auipc	ra,0x0
    800006fa:	b8a080e7          	jalr	-1142(ra) # 80000280 <consputc>
      for(; *s; s++)
    800006fe:	0485                	addi	s1,s1,1
    80000700:	0004c503          	lbu	a0,0(s1)
    80000704:	f96d                	bnez	a0,800006f6 <printf+0x16a>
    80000706:	b705                	j	80000626 <printf+0x9a>
        s = "(null)";
    80000708:	00008497          	auipc	s1,0x8
    8000070c:	91848493          	addi	s1,s1,-1768 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000710:	02800513          	li	a0,40
    80000714:	b7cd                	j	800006f6 <printf+0x16a>
      consputc('%');
    80000716:	8556                	mv	a0,s5
    80000718:	00000097          	auipc	ra,0x0
    8000071c:	b68080e7          	jalr	-1176(ra) # 80000280 <consputc>
      break;
    80000720:	b719                	j	80000626 <printf+0x9a>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b5c080e7          	jalr	-1188(ra) # 80000280 <consputc>
      consputc(c);
    8000072c:	8526                	mv	a0,s1
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	b52080e7          	jalr	-1198(ra) # 80000280 <consputc>
      break;
    80000736:	bdc5                	j	80000626 <printf+0x9a>
  if(locking)
    80000738:	020d9163          	bnez	s11,8000075a <printf+0x1ce>
}
    8000073c:	70e6                	ld	ra,120(sp)
    8000073e:	7446                	ld	s0,112(sp)
    80000740:	74a6                	ld	s1,104(sp)
    80000742:	7906                	ld	s2,96(sp)
    80000744:	69e6                	ld	s3,88(sp)
    80000746:	6a46                	ld	s4,80(sp)
    80000748:	6aa6                	ld	s5,72(sp)
    8000074a:	6b06                	ld	s6,64(sp)
    8000074c:	7be2                	ld	s7,56(sp)
    8000074e:	7c42                	ld	s8,48(sp)
    80000750:	7ca2                	ld	s9,40(sp)
    80000752:	7d02                	ld	s10,32(sp)
    80000754:	6de2                	ld	s11,24(sp)
    80000756:	6129                	addi	sp,sp,192
    80000758:	8082                	ret
    release(&pr.lock);
    8000075a:	00011517          	auipc	a0,0x11
    8000075e:	17e50513          	addi	a0,a0,382 # 800118d8 <pr>
    80000762:	00000097          	auipc	ra,0x0
    80000766:	59a080e7          	jalr	1434(ra) # 80000cfc <release>
}
    8000076a:	bfc9                	j	8000073c <printf+0x1b0>

000000008000076c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076c:	1101                	addi	sp,sp,-32
    8000076e:	ec06                	sd	ra,24(sp)
    80000770:	e822                	sd	s0,16(sp)
    80000772:	e426                	sd	s1,8(sp)
    80000774:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000776:	00011497          	auipc	s1,0x11
    8000077a:	16248493          	addi	s1,s1,354 # 800118d8 <pr>
    8000077e:	00008597          	auipc	a1,0x8
    80000782:	8ba58593          	addi	a1,a1,-1862 # 80008038 <etext+0x38>
    80000786:	8526                	mv	a0,s1
    80000788:	00000097          	auipc	ra,0x0
    8000078c:	430080e7          	jalr	1072(ra) # 80000bb8 <initlock>
  pr.locking = 1;
    80000790:	4785                	li	a5,1
    80000792:	cc9c                	sw	a5,24(s1)
}
    80000794:	60e2                	ld	ra,24(sp)
    80000796:	6442                	ld	s0,16(sp)
    80000798:	64a2                	ld	s1,8(sp)
    8000079a:	6105                	addi	sp,sp,32
    8000079c:	8082                	ret

000000008000079e <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079e:	1141                	addi	sp,sp,-16
    800007a0:	e406                	sd	ra,8(sp)
    800007a2:	e022                	sd	s0,0(sp)
    800007a4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a6:	100007b7          	lui	a5,0x10000
    800007aa:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ae:	f8000713          	li	a4,-128
    800007b2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b6:	470d                	li	a4,3
    800007b8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007bc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c4:	469d                	li	a3,7
    800007c6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007ca:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ce:	00008597          	auipc	a1,0x8
    800007d2:	88a58593          	addi	a1,a1,-1910 # 80008058 <digits+0x18>
    800007d6:	00011517          	auipc	a0,0x11
    800007da:	12250513          	addi	a0,a0,290 # 800118f8 <uart_tx_lock>
    800007de:	00000097          	auipc	ra,0x0
    800007e2:	3da080e7          	jalr	986(ra) # 80000bb8 <initlock>
}
    800007e6:	60a2                	ld	ra,8(sp)
    800007e8:	6402                	ld	s0,0(sp)
    800007ea:	0141                	addi	sp,sp,16
    800007ec:	8082                	ret

00000000800007ee <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ee:	1101                	addi	sp,sp,-32
    800007f0:	ec06                	sd	ra,24(sp)
    800007f2:	e822                	sd	s0,16(sp)
    800007f4:	e426                	sd	s1,8(sp)
    800007f6:	1000                	addi	s0,sp,32
    800007f8:	84aa                	mv	s1,a0
  push_off();
    800007fa:	00000097          	auipc	ra,0x0
    800007fe:	402080e7          	jalr	1026(ra) # 80000bfc <push_off>

  if(panicked){
    80000802:	00008797          	auipc	a5,0x8
    80000806:	7fe7a783          	lw	a5,2046(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080e:	c391                	beqz	a5,80000812 <uartputc_sync+0x24>
    for(;;)
    80000810:	a001                	j	80000810 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000816:	0207f793          	andi	a5,a5,32
    8000081a:	dfe5                	beqz	a5,80000812 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081c:	0ff4f513          	andi	a0,s1,255
    80000820:	100007b7          	lui	a5,0x10000
    80000824:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000828:	00000097          	auipc	ra,0x0
    8000082c:	474080e7          	jalr	1140(ra) # 80000c9c <pop_off>
}
    80000830:	60e2                	ld	ra,24(sp)
    80000832:	6442                	ld	s0,16(sp)
    80000834:	64a2                	ld	s1,8(sp)
    80000836:	6105                	addi	sp,sp,32
    80000838:	8082                	ret

000000008000083a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000083a:	00008797          	auipc	a5,0x8
    8000083e:	7ca7a783          	lw	a5,1994(a5) # 80009004 <uart_tx_r>
    80000842:	00008717          	auipc	a4,0x8
    80000846:	7c672703          	lw	a4,1990(a4) # 80009008 <uart_tx_w>
    8000084a:	08f70063          	beq	a4,a5,800008ca <uartstart+0x90>
{
    8000084e:	7139                	addi	sp,sp,-64
    80000850:	fc06                	sd	ra,56(sp)
    80000852:	f822                	sd	s0,48(sp)
    80000854:	f426                	sd	s1,40(sp)
    80000856:	f04a                	sd	s2,32(sp)
    80000858:	ec4e                	sd	s3,24(sp)
    8000085a:	e852                	sd	s4,16(sp)
    8000085c:	e456                	sd	s5,8(sp)
    8000085e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000860:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000864:	00011a97          	auipc	s5,0x11
    80000868:	094a8a93          	addi	s5,s5,148 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000086c:	00008497          	auipc	s1,0x8
    80000870:	79848493          	addi	s1,s1,1944 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000874:	00008a17          	auipc	s4,0x8
    80000878:	794a0a13          	addi	s4,s4,1940 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000880:	02077713          	andi	a4,a4,32
    80000884:	cb15                	beqz	a4,800008b8 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r];
    80000886:	00fa8733          	add	a4,s5,a5
    8000088a:	01874983          	lbu	s3,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000088e:	2785                	addiw	a5,a5,1
    80000890:	41f7d71b          	sraiw	a4,a5,0x1f
    80000894:	01b7571b          	srliw	a4,a4,0x1b
    80000898:	9fb9                	addw	a5,a5,a4
    8000089a:	8bfd                	andi	a5,a5,31
    8000089c:	9f99                	subw	a5,a5,a4
    8000089e:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a0:	8526                	mv	a0,s1
    800008a2:	00002097          	auipc	ra,0x2
    800008a6:	b0a080e7          	jalr	-1270(ra) # 800023ac <wakeup>
    
    WriteReg(THR, c);
    800008aa:	01390023          	sb	s3,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ae:	409c                	lw	a5,0(s1)
    800008b0:	000a2703          	lw	a4,0(s4)
    800008b4:	fcf714e3          	bne	a4,a5,8000087c <uartstart+0x42>
  }
}
    800008b8:	70e2                	ld	ra,56(sp)
    800008ba:	7442                	ld	s0,48(sp)
    800008bc:	74a2                	ld	s1,40(sp)
    800008be:	7902                	ld	s2,32(sp)
    800008c0:	69e2                	ld	s3,24(sp)
    800008c2:	6a42                	ld	s4,16(sp)
    800008c4:	6aa2                	ld	s5,8(sp)
    800008c6:	6121                	addi	sp,sp,64
    800008c8:	8082                	ret
    800008ca:	8082                	ret

00000000800008cc <uartputc>:
{
    800008cc:	7179                	addi	sp,sp,-48
    800008ce:	f406                	sd	ra,40(sp)
    800008d0:	f022                	sd	s0,32(sp)
    800008d2:	ec26                	sd	s1,24(sp)
    800008d4:	e84a                	sd	s2,16(sp)
    800008d6:	e44e                	sd	s3,8(sp)
    800008d8:	e052                	sd	s4,0(sp)
    800008da:	1800                	addi	s0,sp,48
    800008dc:	84aa                	mv	s1,a0
  acquire(&uart_tx_lock);
    800008de:	00011517          	auipc	a0,0x11
    800008e2:	01a50513          	addi	a0,a0,26 # 800118f8 <uart_tx_lock>
    800008e6:	00000097          	auipc	ra,0x0
    800008ea:	362080e7          	jalr	866(ra) # 80000c48 <acquire>
  if(panicked){
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	7127a783          	lw	a5,1810(a5) # 80009000 <panicked>
    800008f6:	c391                	beqz	a5,800008fa <uartputc+0x2e>
    for(;;)
    800008f8:	a001                	j	800008f8 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800008fa:	00008697          	auipc	a3,0x8
    800008fe:	70e6a683          	lw	a3,1806(a3) # 80009008 <uart_tx_w>
    80000902:	0016879b          	addiw	a5,a3,1
    80000906:	41f7d71b          	sraiw	a4,a5,0x1f
    8000090a:	01b7571b          	srliw	a4,a4,0x1b
    8000090e:	9fb9                	addw	a5,a5,a4
    80000910:	8bfd                	andi	a5,a5,31
    80000912:	9f99                	subw	a5,a5,a4
    80000914:	00008717          	auipc	a4,0x8
    80000918:	6f072703          	lw	a4,1776(a4) # 80009004 <uart_tx_r>
    8000091c:	04f71363          	bne	a4,a5,80000962 <uartputc+0x96>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000920:	00011a17          	auipc	s4,0x11
    80000924:	fd8a0a13          	addi	s4,s4,-40 # 800118f8 <uart_tx_lock>
    80000928:	00008917          	auipc	s2,0x8
    8000092c:	6dc90913          	addi	s2,s2,1756 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000930:	00008997          	auipc	s3,0x8
    80000934:	6d898993          	addi	s3,s3,1752 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000938:	85d2                	mv	a1,s4
    8000093a:	854a                	mv	a0,s2
    8000093c:	00002097          	auipc	ra,0x2
    80000940:	8f0080e7          	jalr	-1808(ra) # 8000222c <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	0009a683          	lw	a3,0(s3)
    80000948:	0016879b          	addiw	a5,a3,1
    8000094c:	41f7d71b          	sraiw	a4,a5,0x1f
    80000950:	01b7571b          	srliw	a4,a4,0x1b
    80000954:	9fb9                	addw	a5,a5,a4
    80000956:	8bfd                	andi	a5,a5,31
    80000958:	9f99                	subw	a5,a5,a4
    8000095a:	00092703          	lw	a4,0(s2)
    8000095e:	fcf70de3          	beq	a4,a5,80000938 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000962:	00011917          	auipc	s2,0x11
    80000966:	f9690913          	addi	s2,s2,-106 # 800118f8 <uart_tx_lock>
    8000096a:	96ca                	add	a3,a3,s2
    8000096c:	00968c23          	sb	s1,24(a3)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000970:	00008717          	auipc	a4,0x8
    80000974:	68f72c23          	sw	a5,1688(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000978:	00000097          	auipc	ra,0x0
    8000097c:	ec2080e7          	jalr	-318(ra) # 8000083a <uartstart>
      release(&uart_tx_lock);
    80000980:	854a                	mv	a0,s2
    80000982:	00000097          	auipc	ra,0x0
    80000986:	37a080e7          	jalr	890(ra) # 80000cfc <release>
}
    8000098a:	70a2                	ld	ra,40(sp)
    8000098c:	7402                	ld	s0,32(sp)
    8000098e:	64e2                	ld	s1,24(sp)
    80000990:	6942                	ld	s2,16(sp)
    80000992:	69a2                	ld	s3,8(sp)
    80000994:	6a02                	ld	s4,0(sp)
    80000996:	6145                	addi	sp,sp,48
    80000998:	8082                	ret

000000008000099a <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000099a:	1141                	addi	sp,sp,-16
    8000099c:	e422                	sd	s0,8(sp)
    8000099e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009a0:	100007b7          	lui	a5,0x10000
    800009a4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009a8:	8b85                	andi	a5,a5,1
    800009aa:	cb91                	beqz	a5,800009be <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009ac:	100007b7          	lui	a5,0x10000
    800009b0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009b4:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009b8:	6422                	ld	s0,8(sp)
    800009ba:	0141                	addi	sp,sp,16
    800009bc:	8082                	ret
    return -1;
    800009be:	557d                	li	a0,-1
    800009c0:	bfe5                	j	800009b8 <uartgetc+0x1e>

00000000800009c2 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009c2:	1101                	addi	sp,sp,-32
    800009c4:	ec06                	sd	ra,24(sp)
    800009c6:	e822                	sd	s0,16(sp)
    800009c8:	e426                	sd	s1,8(sp)
    800009ca:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009cc:	54fd                	li	s1,-1
    800009ce:	a029                	j	800009d8 <uartintr+0x16>
      break;
    consoleintr(c);
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	8f2080e7          	jalr	-1806(ra) # 800002c2 <consoleintr>
    int c = uartgetc();
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	fc2080e7          	jalr	-62(ra) # 8000099a <uartgetc>
    if(c == -1)
    800009e0:	fe9518e3          	bne	a0,s1,800009d0 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009e4:	00011497          	auipc	s1,0x11
    800009e8:	f1448493          	addi	s1,s1,-236 # 800118f8 <uart_tx_lock>
    800009ec:	8526                	mv	a0,s1
    800009ee:	00000097          	auipc	ra,0x0
    800009f2:	25a080e7          	jalr	602(ra) # 80000c48 <acquire>
  uartstart();
    800009f6:	00000097          	auipc	ra,0x0
    800009fa:	e44080e7          	jalr	-444(ra) # 8000083a <uartstart>
  release(&uart_tx_lock);
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	2fc080e7          	jalr	764(ra) # 80000cfc <release>
}
    80000a08:	60e2                	ld	ra,24(sp)
    80000a0a:	6442                	ld	s0,16(sp)
    80000a0c:	64a2                	ld	s1,8(sp)
    80000a0e:	6105                	addi	sp,sp,32
    80000a10:	8082                	ret

0000000080000a12 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a12:	1101                	addi	sp,sp,-32
    80000a14:	ec06                	sd	ra,24(sp)
    80000a16:	e822                	sd	s0,16(sp)
    80000a18:	e426                	sd	s1,8(sp)
    80000a1a:	e04a                	sd	s2,0(sp)
    80000a1c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a1e:	03451793          	slli	a5,a0,0x34
    80000a22:	ebb9                	bnez	a5,80000a78 <kfree+0x66>
    80000a24:	84aa                	mv	s1,a0
    80000a26:	00025797          	auipc	a5,0x25
    80000a2a:	5da78793          	addi	a5,a5,1498 # 80026000 <end>
    80000a2e:	04f56563          	bltu	a0,a5,80000a78 <kfree+0x66>
    80000a32:	47c5                	li	a5,17
    80000a34:	07ee                	slli	a5,a5,0x1b
    80000a36:	04f57163          	bgeu	a0,a5,80000a78 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a3a:	6605                	lui	a2,0x1
    80000a3c:	4585                	li	a1,1
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	306080e7          	jalr	774(ra) # 80000d44 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a46:	00011917          	auipc	s2,0x11
    80000a4a:	eea90913          	addi	s2,s2,-278 # 80011930 <kmem>
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	1f8080e7          	jalr	504(ra) # 80000c48 <acquire>
  r->next = kmem.freelist;
    80000a58:	01893783          	ld	a5,24(s2)
    80000a5c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a5e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a62:	854a                	mv	a0,s2
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	298080e7          	jalr	664(ra) # 80000cfc <release>
}
    80000a6c:	60e2                	ld	ra,24(sp)
    80000a6e:	6442                	ld	s0,16(sp)
    80000a70:	64a2                	ld	s1,8(sp)
    80000a72:	6902                	ld	s2,0(sp)
    80000a74:	6105                	addi	sp,sp,32
    80000a76:	8082                	ret
    panic("kfree");
    80000a78:	00007517          	auipc	a0,0x7
    80000a7c:	5e850513          	addi	a0,a0,1512 # 80008060 <digits+0x20>
    80000a80:	00000097          	auipc	ra,0x0
    80000a84:	ac2080e7          	jalr	-1342(ra) # 80000542 <panic>

0000000080000a88 <freerange>:
{
    80000a88:	7179                	addi	sp,sp,-48
    80000a8a:	f406                	sd	ra,40(sp)
    80000a8c:	f022                	sd	s0,32(sp)
    80000a8e:	ec26                	sd	s1,24(sp)
    80000a90:	e84a                	sd	s2,16(sp)
    80000a92:	e44e                	sd	s3,8(sp)
    80000a94:	e052                	sd	s4,0(sp)
    80000a96:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a98:	6785                	lui	a5,0x1
    80000a9a:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a9e:	94aa                	add	s1,s1,a0
    80000aa0:	757d                	lui	a0,0xfffff
    80000aa2:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa4:	94be                	add	s1,s1,a5
    80000aa6:	0095ee63          	bltu	a1,s1,80000ac2 <freerange+0x3a>
    80000aaa:	892e                	mv	s2,a1
    kfree(p);
    80000aac:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aae:	6985                	lui	s3,0x1
    kfree(p);
    80000ab0:	01448533          	add	a0,s1,s4
    80000ab4:	00000097          	auipc	ra,0x0
    80000ab8:	f5e080e7          	jalr	-162(ra) # 80000a12 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000abc:	94ce                	add	s1,s1,s3
    80000abe:	fe9979e3          	bgeu	s2,s1,80000ab0 <freerange+0x28>
}
    80000ac2:	70a2                	ld	ra,40(sp)
    80000ac4:	7402                	ld	s0,32(sp)
    80000ac6:	64e2                	ld	s1,24(sp)
    80000ac8:	6942                	ld	s2,16(sp)
    80000aca:	69a2                	ld	s3,8(sp)
    80000acc:	6a02                	ld	s4,0(sp)
    80000ace:	6145                	addi	sp,sp,48
    80000ad0:	8082                	ret

0000000080000ad2 <kinit>:
{
    80000ad2:	1141                	addi	sp,sp,-16
    80000ad4:	e406                	sd	ra,8(sp)
    80000ad6:	e022                	sd	s0,0(sp)
    80000ad8:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ada:	00007597          	auipc	a1,0x7
    80000ade:	58e58593          	addi	a1,a1,1422 # 80008068 <digits+0x28>
    80000ae2:	00011517          	auipc	a0,0x11
    80000ae6:	e4e50513          	addi	a0,a0,-434 # 80011930 <kmem>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	0ce080e7          	jalr	206(ra) # 80000bb8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000af2:	45c5                	li	a1,17
    80000af4:	05ee                	slli	a1,a1,0x1b
    80000af6:	00025517          	auipc	a0,0x25
    80000afa:	50a50513          	addi	a0,a0,1290 # 80026000 <end>
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	f8a080e7          	jalr	-118(ra) # 80000a88 <freerange>
}
    80000b06:	60a2                	ld	ra,8(sp)
    80000b08:	6402                	ld	s0,0(sp)
    80000b0a:	0141                	addi	sp,sp,16
    80000b0c:	8082                	ret

0000000080000b0e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b0e:	1101                	addi	sp,sp,-32
    80000b10:	ec06                	sd	ra,24(sp)
    80000b12:	e822                	sd	s0,16(sp)
    80000b14:	e426                	sd	s1,8(sp)
    80000b16:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b18:	00011497          	auipc	s1,0x11
    80000b1c:	e1848493          	addi	s1,s1,-488 # 80011930 <kmem>
    80000b20:	8526                	mv	a0,s1
    80000b22:	00000097          	auipc	ra,0x0
    80000b26:	126080e7          	jalr	294(ra) # 80000c48 <acquire>
  r = kmem.freelist;
    80000b2a:	6c84                	ld	s1,24(s1)
  if(r)
    80000b2c:	c885                	beqz	s1,80000b5c <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b2e:	609c                	ld	a5,0(s1)
    80000b30:	00011517          	auipc	a0,0x11
    80000b34:	e0050513          	addi	a0,a0,-512 # 80011930 <kmem>
    80000b38:	ed1c                	sd	a5,24(a0)
 release(&kmem.lock);
    80000b3a:	00000097          	auipc	ra,0x0
    80000b3e:	1c2080e7          	jalr	450(ra) # 80000cfc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b42:	6605                	lui	a2,0x1
    80000b44:	4595                	li	a1,5
    80000b46:	8526                	mv	a0,s1
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	1fc080e7          	jalr	508(ra) # 80000d44 <memset>
  return (void*)r;
}
    80000b50:	8526                	mv	a0,s1
    80000b52:	60e2                	ld	ra,24(sp)
    80000b54:	6442                	ld	s0,16(sp)
    80000b56:	64a2                	ld	s1,8(sp)
    80000b58:	6105                	addi	sp,sp,32
    80000b5a:	8082                	ret
 release(&kmem.lock);
    80000b5c:	00011517          	auipc	a0,0x11
    80000b60:	dd450513          	addi	a0,a0,-556 # 80011930 <kmem>
    80000b64:	00000097          	auipc	ra,0x0
    80000b68:	198080e7          	jalr	408(ra) # 80000cfc <release>
  if(r)
    80000b6c:	b7d5                	j	80000b50 <kalloc+0x42>

0000000080000b6e <memcount>:

// Used for sysinfo syscall.
// Returns how many bytes that are free to use.
int memcount()
{
    80000b6e:	1101                	addi	sp,sp,-32
    80000b70:	ec06                	sd	ra,24(sp)
    80000b72:	e822                	sd	s0,16(sp)
    80000b74:	e426                	sd	s1,8(sp)
    80000b76:	1000                	addi	s0,sp,32
  acquire(&kmem.lock);
    80000b78:	00011497          	auipc	s1,0x11
    80000b7c:	db848493          	addi	s1,s1,-584 # 80011930 <kmem>
    80000b80:	8526                	mv	a0,s1
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	0c6080e7          	jalr	198(ra) # 80000c48 <acquire>
  struct run *r;
  r = kmem.freelist;
    80000b8a:	6c9c                	ld	a5,24(s1)
  int count = 0;
  while(r)
    80000b8c:	c785                	beqz	a5,80000bb4 <memcount+0x46>
  int count = 0;
    80000b8e:	4481                	li	s1,0
  {
	  r = r->next;
    80000b90:	639c                	ld	a5,0(a5)
	  count ++;
    80000b92:	2485                	addiw	s1,s1,1
  while(r)
    80000b94:	fff5                	bnez	a5,80000b90 <memcount+0x22>
  }

  release(&kmem.lock);
    80000b96:	00011517          	auipc	a0,0x11
    80000b9a:	d9a50513          	addi	a0,a0,-614 # 80011930 <kmem>
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	15e080e7          	jalr	350(ra) # 80000cfc <release>
  return count * PGSIZE;
}
    80000ba6:	00c4951b          	slliw	a0,s1,0xc
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret
  int count = 0;
    80000bb4:	4481                	li	s1,0
    80000bb6:	b7c5                	j	80000b96 <memcount+0x28>

0000000080000bb8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bb8:	1141                	addi	sp,sp,-16
    80000bba:	e422                	sd	s0,8(sp)
    80000bbc:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bbe:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bc0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bc4:	00053823          	sd	zero,16(a0)
}
    80000bc8:	6422                	ld	s0,8(sp)
    80000bca:	0141                	addi	sp,sp,16
    80000bcc:	8082                	ret

0000000080000bce <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bce:	411c                	lw	a5,0(a0)
    80000bd0:	e399                	bnez	a5,80000bd6 <holding+0x8>
    80000bd2:	4501                	li	a0,0
  return r;
}
    80000bd4:	8082                	ret
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000be0:	6904                	ld	s1,16(a0)
    80000be2:	00001097          	auipc	ra,0x1
    80000be6:	e16080e7          	jalr	-490(ra) # 800019f8 <mycpu>
    80000bea:	40a48533          	sub	a0,s1,a0
    80000bee:	00153513          	seqz	a0,a0
}
    80000bf2:	60e2                	ld	ra,24(sp)
    80000bf4:	6442                	ld	s0,16(sp)
    80000bf6:	64a2                	ld	s1,8(sp)
    80000bf8:	6105                	addi	sp,sp,32
    80000bfa:	8082                	ret

0000000080000bfc <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bfc:	1101                	addi	sp,sp,-32
    80000bfe:	ec06                	sd	ra,24(sp)
    80000c00:	e822                	sd	s0,16(sp)
    80000c02:	e426                	sd	s1,8(sp)
    80000c04:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c06:	100024f3          	csrr	s1,sstatus
    80000c0a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c0e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c10:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c14:	00001097          	auipc	ra,0x1
    80000c18:	de4080e7          	jalr	-540(ra) # 800019f8 <mycpu>
    80000c1c:	5d3c                	lw	a5,120(a0)
    80000c1e:	cf89                	beqz	a5,80000c38 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c20:	00001097          	auipc	ra,0x1
    80000c24:	dd8080e7          	jalr	-552(ra) # 800019f8 <mycpu>
    80000c28:	5d3c                	lw	a5,120(a0)
    80000c2a:	2785                	addiw	a5,a5,1
    80000c2c:	dd3c                	sw	a5,120(a0)
}
    80000c2e:	60e2                	ld	ra,24(sp)
    80000c30:	6442                	ld	s0,16(sp)
    80000c32:	64a2                	ld	s1,8(sp)
    80000c34:	6105                	addi	sp,sp,32
    80000c36:	8082                	ret
    mycpu()->intena = old;
    80000c38:	00001097          	auipc	ra,0x1
    80000c3c:	dc0080e7          	jalr	-576(ra) # 800019f8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c40:	8085                	srli	s1,s1,0x1
    80000c42:	8885                	andi	s1,s1,1
    80000c44:	dd64                	sw	s1,124(a0)
    80000c46:	bfe9                	j	80000c20 <push_off+0x24>

0000000080000c48 <acquire>:
{
    80000c48:	1101                	addi	sp,sp,-32
    80000c4a:	ec06                	sd	ra,24(sp)
    80000c4c:	e822                	sd	s0,16(sp)
    80000c4e:	e426                	sd	s1,8(sp)
    80000c50:	1000                	addi	s0,sp,32
    80000c52:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c54:	00000097          	auipc	ra,0x0
    80000c58:	fa8080e7          	jalr	-88(ra) # 80000bfc <push_off>
  if(holding(lk))
    80000c5c:	8526                	mv	a0,s1
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	f70080e7          	jalr	-144(ra) # 80000bce <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c66:	4705                	li	a4,1
  if(holding(lk))
    80000c68:	e115                	bnez	a0,80000c8c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c6a:	87ba                	mv	a5,a4
    80000c6c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c70:	2781                	sext.w	a5,a5
    80000c72:	ffe5                	bnez	a5,80000c6a <acquire+0x22>
  __sync_synchronize();
    80000c74:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c78:	00001097          	auipc	ra,0x1
    80000c7c:	d80080e7          	jalr	-640(ra) # 800019f8 <mycpu>
    80000c80:	e888                	sd	a0,16(s1)
}
    80000c82:	60e2                	ld	ra,24(sp)
    80000c84:	6442                	ld	s0,16(sp)
    80000c86:	64a2                	ld	s1,8(sp)
    80000c88:	6105                	addi	sp,sp,32
    80000c8a:	8082                	ret
    panic("acquire");
    80000c8c:	00007517          	auipc	a0,0x7
    80000c90:	3e450513          	addi	a0,a0,996 # 80008070 <digits+0x30>
    80000c94:	00000097          	auipc	ra,0x0
    80000c98:	8ae080e7          	jalr	-1874(ra) # 80000542 <panic>

0000000080000c9c <pop_off>:

void
pop_off(void)
{
    80000c9c:	1141                	addi	sp,sp,-16
    80000c9e:	e406                	sd	ra,8(sp)
    80000ca0:	e022                	sd	s0,0(sp)
    80000ca2:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000ca4:	00001097          	auipc	ra,0x1
    80000ca8:	d54080e7          	jalr	-684(ra) # 800019f8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cac:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cb0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cb2:	e78d                	bnez	a5,80000cdc <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cb4:	5d3c                	lw	a5,120(a0)
    80000cb6:	02f05b63          	blez	a5,80000cec <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cba:	37fd                	addiw	a5,a5,-1
    80000cbc:	0007871b          	sext.w	a4,a5
    80000cc0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cc2:	eb09                	bnez	a4,80000cd4 <pop_off+0x38>
    80000cc4:	5d7c                	lw	a5,124(a0)
    80000cc6:	c799                	beqz	a5,80000cd4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cc8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ccc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cd0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cd4:	60a2                	ld	ra,8(sp)
    80000cd6:	6402                	ld	s0,0(sp)
    80000cd8:	0141                	addi	sp,sp,16
    80000cda:	8082                	ret
    panic("pop_off - interruptible");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	39c50513          	addi	a0,a0,924 # 80008078 <digits+0x38>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	85e080e7          	jalr	-1954(ra) # 80000542 <panic>
    panic("pop_off");
    80000cec:	00007517          	auipc	a0,0x7
    80000cf0:	3a450513          	addi	a0,a0,932 # 80008090 <digits+0x50>
    80000cf4:	00000097          	auipc	ra,0x0
    80000cf8:	84e080e7          	jalr	-1970(ra) # 80000542 <panic>

0000000080000cfc <release>:
{
    80000cfc:	1101                	addi	sp,sp,-32
    80000cfe:	ec06                	sd	ra,24(sp)
    80000d00:	e822                	sd	s0,16(sp)
    80000d02:	e426                	sd	s1,8(sp)
    80000d04:	1000                	addi	s0,sp,32
    80000d06:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d08:	00000097          	auipc	ra,0x0
    80000d0c:	ec6080e7          	jalr	-314(ra) # 80000bce <holding>
    80000d10:	c115                	beqz	a0,80000d34 <release+0x38>
  lk->cpu = 0;
    80000d12:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d16:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d1a:	0f50000f          	fence	iorw,ow
    80000d1e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	f7a080e7          	jalr	-134(ra) # 80000c9c <pop_off>
}
    80000d2a:	60e2                	ld	ra,24(sp)
    80000d2c:	6442                	ld	s0,16(sp)
    80000d2e:	64a2                	ld	s1,8(sp)
    80000d30:	6105                	addi	sp,sp,32
    80000d32:	8082                	ret
    panic("release");
    80000d34:	00007517          	auipc	a0,0x7
    80000d38:	36450513          	addi	a0,a0,868 # 80008098 <digits+0x58>
    80000d3c:	00000097          	auipc	ra,0x0
    80000d40:	806080e7          	jalr	-2042(ra) # 80000542 <panic>

0000000080000d44 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d44:	1141                	addi	sp,sp,-16
    80000d46:	e422                	sd	s0,8(sp)
    80000d48:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d4a:	ca19                	beqz	a2,80000d60 <memset+0x1c>
    80000d4c:	87aa                	mv	a5,a0
    80000d4e:	1602                	slli	a2,a2,0x20
    80000d50:	9201                	srli	a2,a2,0x20
    80000d52:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d56:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d5a:	0785                	addi	a5,a5,1
    80000d5c:	fee79de3          	bne	a5,a4,80000d56 <memset+0x12>
  }
  return dst;
}
    80000d60:	6422                	ld	s0,8(sp)
    80000d62:	0141                	addi	sp,sp,16
    80000d64:	8082                	ret

0000000080000d66 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d66:	1141                	addi	sp,sp,-16
    80000d68:	e422                	sd	s0,8(sp)
    80000d6a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d6c:	ca05                	beqz	a2,80000d9c <memcmp+0x36>
    80000d6e:	fff6069b          	addiw	a3,a2,-1
    80000d72:	1682                	slli	a3,a3,0x20
    80000d74:	9281                	srli	a3,a3,0x20
    80000d76:	0685                	addi	a3,a3,1
    80000d78:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d7a:	00054783          	lbu	a5,0(a0)
    80000d7e:	0005c703          	lbu	a4,0(a1)
    80000d82:	00e79863          	bne	a5,a4,80000d92 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d8a:	fed518e3          	bne	a0,a3,80000d7a <memcmp+0x14>
  }

  return 0;
    80000d8e:	4501                	li	a0,0
    80000d90:	a019                	j	80000d96 <memcmp+0x30>
      return *s1 - *s2;
    80000d92:	40e7853b          	subw	a0,a5,a4
}
    80000d96:	6422                	ld	s0,8(sp)
    80000d98:	0141                	addi	sp,sp,16
    80000d9a:	8082                	ret
  return 0;
    80000d9c:	4501                	li	a0,0
    80000d9e:	bfe5                	j	80000d96 <memcmp+0x30>

0000000080000da0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e422                	sd	s0,8(sp)
    80000da4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000da6:	02a5e563          	bltu	a1,a0,80000dd0 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000daa:	fff6069b          	addiw	a3,a2,-1
    80000dae:	ce11                	beqz	a2,80000dca <memmove+0x2a>
    80000db0:	1682                	slli	a3,a3,0x20
    80000db2:	9281                	srli	a3,a3,0x20
    80000db4:	0685                	addi	a3,a3,1
    80000db6:	96ae                	add	a3,a3,a1
    80000db8:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000dba:	0585                	addi	a1,a1,1
    80000dbc:	0785                	addi	a5,a5,1
    80000dbe:	fff5c703          	lbu	a4,-1(a1)
    80000dc2:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000dc6:	fed59ae3          	bne	a1,a3,80000dba <memmove+0x1a>

  return dst;
}
    80000dca:	6422                	ld	s0,8(sp)
    80000dcc:	0141                	addi	sp,sp,16
    80000dce:	8082                	ret
  if(s < d && s + n > d){
    80000dd0:	02061713          	slli	a4,a2,0x20
    80000dd4:	9301                	srli	a4,a4,0x20
    80000dd6:	00e587b3          	add	a5,a1,a4
    80000dda:	fcf578e3          	bgeu	a0,a5,80000daa <memmove+0xa>
    d += n;
    80000dde:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000de0:	fff6069b          	addiw	a3,a2,-1
    80000de4:	d27d                	beqz	a2,80000dca <memmove+0x2a>
    80000de6:	02069613          	slli	a2,a3,0x20
    80000dea:	9201                	srli	a2,a2,0x20
    80000dec:	fff64613          	not	a2,a2
    80000df0:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000df2:	17fd                	addi	a5,a5,-1
    80000df4:	177d                	addi	a4,a4,-1
    80000df6:	0007c683          	lbu	a3,0(a5)
    80000dfa:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000dfe:	fef61ae3          	bne	a2,a5,80000df2 <memmove+0x52>
    80000e02:	b7e1                	j	80000dca <memmove+0x2a>

0000000080000e04 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e04:	1141                	addi	sp,sp,-16
    80000e06:	e406                	sd	ra,8(sp)
    80000e08:	e022                	sd	s0,0(sp)
    80000e0a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e0c:	00000097          	auipc	ra,0x0
    80000e10:	f94080e7          	jalr	-108(ra) # 80000da0 <memmove>
}
    80000e14:	60a2                	ld	ra,8(sp)
    80000e16:	6402                	ld	s0,0(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e22:	ce11                	beqz	a2,80000e3e <strncmp+0x22>
    80000e24:	00054783          	lbu	a5,0(a0)
    80000e28:	cf89                	beqz	a5,80000e42 <strncmp+0x26>
    80000e2a:	0005c703          	lbu	a4,0(a1)
    80000e2e:	00f71a63          	bne	a4,a5,80000e42 <strncmp+0x26>
    n--, p++, q++;
    80000e32:	367d                	addiw	a2,a2,-1
    80000e34:	0505                	addi	a0,a0,1
    80000e36:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e38:	f675                	bnez	a2,80000e24 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e3a:	4501                	li	a0,0
    80000e3c:	a809                	j	80000e4e <strncmp+0x32>
    80000e3e:	4501                	li	a0,0
    80000e40:	a039                	j	80000e4e <strncmp+0x32>
  if(n == 0)
    80000e42:	ca09                	beqz	a2,80000e54 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e44:	00054503          	lbu	a0,0(a0)
    80000e48:	0005c783          	lbu	a5,0(a1)
    80000e4c:	9d1d                	subw	a0,a0,a5
}
    80000e4e:	6422                	ld	s0,8(sp)
    80000e50:	0141                	addi	sp,sp,16
    80000e52:	8082                	ret
    return 0;
    80000e54:	4501                	li	a0,0
    80000e56:	bfe5                	j	80000e4e <strncmp+0x32>

0000000080000e58 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e58:	1141                	addi	sp,sp,-16
    80000e5a:	e422                	sd	s0,8(sp)
    80000e5c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e5e:	872a                	mv	a4,a0
    80000e60:	8832                	mv	a6,a2
    80000e62:	367d                	addiw	a2,a2,-1
    80000e64:	01005963          	blez	a6,80000e76 <strncpy+0x1e>
    80000e68:	0705                	addi	a4,a4,1
    80000e6a:	0005c783          	lbu	a5,0(a1)
    80000e6e:	fef70fa3          	sb	a5,-1(a4)
    80000e72:	0585                	addi	a1,a1,1
    80000e74:	f7f5                	bnez	a5,80000e60 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e76:	86ba                	mv	a3,a4
    80000e78:	00c05c63          	blez	a2,80000e90 <strncpy+0x38>
    *s++ = 0;
    80000e7c:	0685                	addi	a3,a3,1
    80000e7e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e82:	fff6c793          	not	a5,a3
    80000e86:	9fb9                	addw	a5,a5,a4
    80000e88:	010787bb          	addw	a5,a5,a6
    80000e8c:	fef048e3          	bgtz	a5,80000e7c <strncpy+0x24>
  return os;
}
    80000e90:	6422                	ld	s0,8(sp)
    80000e92:	0141                	addi	sp,sp,16
    80000e94:	8082                	ret

0000000080000e96 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e96:	1141                	addi	sp,sp,-16
    80000e98:	e422                	sd	s0,8(sp)
    80000e9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e9c:	02c05363          	blez	a2,80000ec2 <safestrcpy+0x2c>
    80000ea0:	fff6069b          	addiw	a3,a2,-1
    80000ea4:	1682                	slli	a3,a3,0x20
    80000ea6:	9281                	srli	a3,a3,0x20
    80000ea8:	96ae                	add	a3,a3,a1
    80000eaa:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000eac:	00d58963          	beq	a1,a3,80000ebe <safestrcpy+0x28>
    80000eb0:	0585                	addi	a1,a1,1
    80000eb2:	0785                	addi	a5,a5,1
    80000eb4:	fff5c703          	lbu	a4,-1(a1)
    80000eb8:	fee78fa3          	sb	a4,-1(a5)
    80000ebc:	fb65                	bnez	a4,80000eac <safestrcpy+0x16>
    ;
  *s = 0;
    80000ebe:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ec2:	6422                	ld	s0,8(sp)
    80000ec4:	0141                	addi	sp,sp,16
    80000ec6:	8082                	ret

0000000080000ec8 <strlen>:

int
strlen(const char *s)
{
    80000ec8:	1141                	addi	sp,sp,-16
    80000eca:	e422                	sd	s0,8(sp)
    80000ecc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ece:	00054783          	lbu	a5,0(a0)
    80000ed2:	cf91                	beqz	a5,80000eee <strlen+0x26>
    80000ed4:	0505                	addi	a0,a0,1
    80000ed6:	87aa                	mv	a5,a0
    80000ed8:	4685                	li	a3,1
    80000eda:	9e89                	subw	a3,a3,a0
    80000edc:	00f6853b          	addw	a0,a3,a5
    80000ee0:	0785                	addi	a5,a5,1
    80000ee2:	fff7c703          	lbu	a4,-1(a5)
    80000ee6:	fb7d                	bnez	a4,80000edc <strlen+0x14>
    ;
  return n;
}
    80000ee8:	6422                	ld	s0,8(sp)
    80000eea:	0141                	addi	sp,sp,16
    80000eec:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eee:	4501                	li	a0,0
    80000ef0:	bfe5                	j	80000ee8 <strlen+0x20>

0000000080000ef2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ef2:	1141                	addi	sp,sp,-16
    80000ef4:	e406                	sd	ra,8(sp)
    80000ef6:	e022                	sd	s0,0(sp)
    80000ef8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000efa:	00001097          	auipc	ra,0x1
    80000efe:	aee080e7          	jalr	-1298(ra) # 800019e8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f02:	00008717          	auipc	a4,0x8
    80000f06:	10a70713          	addi	a4,a4,266 # 8000900c <started>
  if(cpuid() == 0){
    80000f0a:	c139                	beqz	a0,80000f50 <main+0x5e>
    while(started == 0)
    80000f0c:	431c                	lw	a5,0(a4)
    80000f0e:	2781                	sext.w	a5,a5
    80000f10:	dff5                	beqz	a5,80000f0c <main+0x1a>
      ;
    __sync_synchronize();
    80000f12:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f16:	00001097          	auipc	ra,0x1
    80000f1a:	ad2080e7          	jalr	-1326(ra) # 800019e8 <cpuid>
    80000f1e:	85aa                	mv	a1,a0
    80000f20:	00007517          	auipc	a0,0x7
    80000f24:	19850513          	addi	a0,a0,408 # 800080b8 <digits+0x78>
    80000f28:	fffff097          	auipc	ra,0xfffff
    80000f2c:	664080e7          	jalr	1636(ra) # 8000058c <printf>
    kvminithart();    // turn on paging
    80000f30:	00000097          	auipc	ra,0x0
    80000f34:	0d8080e7          	jalr	216(ra) # 80001008 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	76a080e7          	jalr	1898(ra) # 800026a2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	dc0080e7          	jalr	-576(ra) # 80005d00 <plicinithart>
  }

  scheduler();        
    80000f48:	00001097          	auipc	ra,0x1
    80000f4c:	008080e7          	jalr	8(ra) # 80001f50 <scheduler>
    consoleinit();
    80000f50:	fffff097          	auipc	ra,0xfffff
    80000f54:	504080e7          	jalr	1284(ra) # 80000454 <consoleinit>
    printfinit();
    80000f58:	00000097          	auipc	ra,0x0
    80000f5c:	814080e7          	jalr	-2028(ra) # 8000076c <printfinit>
    printf("\n");
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	16850513          	addi	a0,a0,360 # 800080c8 <digits+0x88>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	624080e7          	jalr	1572(ra) # 8000058c <printf>
    printf("xv6 kernel is booting\n");
    80000f70:	00007517          	auipc	a0,0x7
    80000f74:	13050513          	addi	a0,a0,304 # 800080a0 <digits+0x60>
    80000f78:	fffff097          	auipc	ra,0xfffff
    80000f7c:	614080e7          	jalr	1556(ra) # 8000058c <printf>
    printf("\n");
    80000f80:	00007517          	auipc	a0,0x7
    80000f84:	14850513          	addi	a0,a0,328 # 800080c8 <digits+0x88>
    80000f88:	fffff097          	auipc	ra,0xfffff
    80000f8c:	604080e7          	jalr	1540(ra) # 8000058c <printf>
    kinit();         // physical page allocator
    80000f90:	00000097          	auipc	ra,0x0
    80000f94:	b42080e7          	jalr	-1214(ra) # 80000ad2 <kinit>
    kvminit();       // create kernel page table
    80000f98:	00000097          	auipc	ra,0x0
    80000f9c:	2a0080e7          	jalr	672(ra) # 80001238 <kvminit>
    kvminithart();   // turn on paging
    80000fa0:	00000097          	auipc	ra,0x0
    80000fa4:	068080e7          	jalr	104(ra) # 80001008 <kvminithart>
    procinit();      // process table
    80000fa8:	00001097          	auipc	ra,0x1
    80000fac:	970080e7          	jalr	-1680(ra) # 80001918 <procinit>
    trapinit();      // trap vectors
    80000fb0:	00001097          	auipc	ra,0x1
    80000fb4:	6ca080e7          	jalr	1738(ra) # 8000267a <trapinit>
    trapinithart();  // install kernel trap vector
    80000fb8:	00001097          	auipc	ra,0x1
    80000fbc:	6ea080e7          	jalr	1770(ra) # 800026a2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fc0:	00005097          	auipc	ra,0x5
    80000fc4:	d2a080e7          	jalr	-726(ra) # 80005cea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	d38080e7          	jalr	-712(ra) # 80005d00 <plicinithart>
    binit();         // buffer cache
    80000fd0:	00002097          	auipc	ra,0x2
    80000fd4:	ee2080e7          	jalr	-286(ra) # 80002eb2 <binit>
    iinit();         // inode cache
    80000fd8:	00002097          	auipc	ra,0x2
    80000fdc:	572080e7          	jalr	1394(ra) # 8000354a <iinit>
    fileinit();      // file table
    80000fe0:	00003097          	auipc	ra,0x3
    80000fe4:	50c080e7          	jalr	1292(ra) # 800044ec <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fe8:	00005097          	auipc	ra,0x5
    80000fec:	e20080e7          	jalr	-480(ra) # 80005e08 <virtio_disk_init>
    userinit();      // first user process
    80000ff0:	00001097          	auipc	ra,0x1
    80000ff4:	cee080e7          	jalr	-786(ra) # 80001cde <userinit>
    __sync_synchronize();
    80000ff8:	0ff0000f          	fence
    started = 1;
    80000ffc:	4785                	li	a5,1
    80000ffe:	00008717          	auipc	a4,0x8
    80001002:	00f72723          	sw	a5,14(a4) # 8000900c <started>
    80001006:	b789                	j	80000f48 <main+0x56>

0000000080001008 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001008:	1141                	addi	sp,sp,-16
    8000100a:	e422                	sd	s0,8(sp)
    8000100c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000100e:	00008797          	auipc	a5,0x8
    80001012:	0027b783          	ld	a5,2(a5) # 80009010 <kernel_pagetable>
    80001016:	83b1                	srli	a5,a5,0xc
    80001018:	577d                	li	a4,-1
    8000101a:	177e                	slli	a4,a4,0x3f
    8000101c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000101e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001022:	12000073          	sfence.vma
  sfence_vma();
}
    80001026:	6422                	ld	s0,8(sp)
    80001028:	0141                	addi	sp,sp,16
    8000102a:	8082                	ret

000000008000102c <walk>:
//   30..38 -- 9 bits of level-2 index.
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc) {
    8000102c:	7139                	addi	sp,sp,-64
    8000102e:	fc06                	sd	ra,56(sp)
    80001030:	f822                	sd	s0,48(sp)
    80001032:	f426                	sd	s1,40(sp)
    80001034:	f04a                	sd	s2,32(sp)
    80001036:	ec4e                	sd	s3,24(sp)
    80001038:	e852                	sd	s4,16(sp)
    8000103a:	e456                	sd	s5,8(sp)
    8000103c:	e05a                	sd	s6,0(sp)
    8000103e:	0080                	addi	s0,sp,64
    80001040:	84aa                	mv	s1,a0
    80001042:	89ae                	mv	s3,a1
    80001044:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001046:	57fd                	li	a5,-1
    80001048:	83e9                	srli	a5,a5,0x1a
    8000104a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000104c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000104e:	04b7f263          	bgeu	a5,a1,80001092 <walk+0x66>
    panic("walk");
    80001052:	00007517          	auipc	a0,0x7
    80001056:	07e50513          	addi	a0,a0,126 # 800080d0 <digits+0x90>
    8000105a:	fffff097          	auipc	ra,0xfffff
    8000105e:	4e8080e7          	jalr	1256(ra) # 80000542 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001062:	060a8663          	beqz	s5,800010ce <walk+0xa2>
    80001066:	00000097          	auipc	ra,0x0
    8000106a:	aa8080e7          	jalr	-1368(ra) # 80000b0e <kalloc>
    8000106e:	84aa                	mv	s1,a0
    80001070:	c529                	beqz	a0,800010ba <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001072:	6605                	lui	a2,0x1
    80001074:	4581                	li	a1,0
    80001076:	00000097          	auipc	ra,0x0
    8000107a:	cce080e7          	jalr	-818(ra) # 80000d44 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000107e:	00c4d793          	srli	a5,s1,0xc
    80001082:	07aa                	slli	a5,a5,0xa
    80001084:	0017e793          	ori	a5,a5,1
    80001088:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000108c:	3a5d                	addiw	s4,s4,-9
    8000108e:	036a0063          	beq	s4,s6,800010ae <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001092:	0149d933          	srl	s2,s3,s4
    80001096:	1ff97913          	andi	s2,s2,511
    8000109a:	090e                	slli	s2,s2,0x3
    8000109c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000109e:	00093483          	ld	s1,0(s2)
    800010a2:	0014f793          	andi	a5,s1,1
    800010a6:	dfd5                	beqz	a5,80001062 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010a8:	80a9                	srli	s1,s1,0xa
    800010aa:	04b2                	slli	s1,s1,0xc
    800010ac:	b7c5                	j	8000108c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010ae:	00c9d513          	srli	a0,s3,0xc
    800010b2:	1ff57513          	andi	a0,a0,511
    800010b6:	050e                	slli	a0,a0,0x3
    800010b8:	9526                	add	a0,a0,s1
}
    800010ba:	70e2                	ld	ra,56(sp)
    800010bc:	7442                	ld	s0,48(sp)
    800010be:	74a2                	ld	s1,40(sp)
    800010c0:	7902                	ld	s2,32(sp)
    800010c2:	69e2                	ld	s3,24(sp)
    800010c4:	6a42                	ld	s4,16(sp)
    800010c6:	6aa2                	ld	s5,8(sp)
    800010c8:	6b02                	ld	s6,0(sp)
    800010ca:	6121                	addi	sp,sp,64
    800010cc:	8082                	ret
        return 0;
    800010ce:	4501                	li	a0,0
    800010d0:	b7ed                	j	800010ba <walk+0x8e>

00000000800010d2 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010d2:	57fd                	li	a5,-1
    800010d4:	83e9                	srli	a5,a5,0x1a
    800010d6:	00b7f463          	bgeu	a5,a1,800010de <walkaddr+0xc>
    return 0;
    800010da:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010dc:	8082                	ret
{
    800010de:	1141                	addi	sp,sp,-16
    800010e0:	e406                	sd	ra,8(sp)
    800010e2:	e022                	sd	s0,0(sp)
    800010e4:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010e6:	4601                	li	a2,0
    800010e8:	00000097          	auipc	ra,0x0
    800010ec:	f44080e7          	jalr	-188(ra) # 8000102c <walk>
  if(pte == 0)
    800010f0:	c105                	beqz	a0,80001110 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010f2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010f4:	0117f693          	andi	a3,a5,17
    800010f8:	4745                	li	a4,17
    return 0;
    800010fa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010fc:	00e68663          	beq	a3,a4,80001108 <walkaddr+0x36>
}
    80001100:	60a2                	ld	ra,8(sp)
    80001102:	6402                	ld	s0,0(sp)
    80001104:	0141                	addi	sp,sp,16
    80001106:	8082                	ret
  pa = PTE2PA(*pte);
    80001108:	00a7d513          	srli	a0,a5,0xa
    8000110c:	0532                	slli	a0,a0,0xc
  return pa;
    8000110e:	bfcd                	j	80001100 <walkaddr+0x2e>
    return 0;
    80001110:	4501                	li	a0,0
    80001112:	b7fd                	j	80001100 <walkaddr+0x2e>

0000000080001114 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001114:	1101                	addi	sp,sp,-32
    80001116:	ec06                	sd	ra,24(sp)
    80001118:	e822                	sd	s0,16(sp)
    8000111a:	e426                	sd	s1,8(sp)
    8000111c:	1000                	addi	s0,sp,32
    8000111e:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001120:	1552                	slli	a0,a0,0x34
    80001122:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001126:	4601                	li	a2,0
    80001128:	00008517          	auipc	a0,0x8
    8000112c:	ee853503          	ld	a0,-280(a0) # 80009010 <kernel_pagetable>
    80001130:	00000097          	auipc	ra,0x0
    80001134:	efc080e7          	jalr	-260(ra) # 8000102c <walk>
  if(pte == 0)
    80001138:	cd09                	beqz	a0,80001152 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000113a:	6108                	ld	a0,0(a0)
    8000113c:	00157793          	andi	a5,a0,1
    80001140:	c38d                	beqz	a5,80001162 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001142:	8129                	srli	a0,a0,0xa
    80001144:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001146:	9526                	add	a0,a0,s1
    80001148:	60e2                	ld	ra,24(sp)
    8000114a:	6442                	ld	s0,16(sp)
    8000114c:	64a2                	ld	s1,8(sp)
    8000114e:	6105                	addi	sp,sp,32
    80001150:	8082                	ret
    panic("kvmpa");
    80001152:	00007517          	auipc	a0,0x7
    80001156:	f8650513          	addi	a0,a0,-122 # 800080d8 <digits+0x98>
    8000115a:	fffff097          	auipc	ra,0xfffff
    8000115e:	3e8080e7          	jalr	1000(ra) # 80000542 <panic>
    panic("kvmpa");
    80001162:	00007517          	auipc	a0,0x7
    80001166:	f7650513          	addi	a0,a0,-138 # 800080d8 <digits+0x98>
    8000116a:	fffff097          	auipc	ra,0xfffff
    8000116e:	3d8080e7          	jalr	984(ra) # 80000542 <panic>

0000000080001172 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001172:	715d                	addi	sp,sp,-80
    80001174:	e486                	sd	ra,72(sp)
    80001176:	e0a2                	sd	s0,64(sp)
    80001178:	fc26                	sd	s1,56(sp)
    8000117a:	f84a                	sd	s2,48(sp)
    8000117c:	f44e                	sd	s3,40(sp)
    8000117e:	f052                	sd	s4,32(sp)
    80001180:	ec56                	sd	s5,24(sp)
    80001182:	e85a                	sd	s6,16(sp)
    80001184:	e45e                	sd	s7,8(sp)
    80001186:	0880                	addi	s0,sp,80
    80001188:	8aaa                	mv	s5,a0
    8000118a:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    8000118c:	777d                	lui	a4,0xfffff
    8000118e:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001192:	167d                	addi	a2,a2,-1
    80001194:	00b609b3          	add	s3,a2,a1
    80001198:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000119c:	893e                	mv	s2,a5
    8000119e:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011a2:	6b85                	lui	s7,0x1
    800011a4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011a8:	4605                	li	a2,1
    800011aa:	85ca                	mv	a1,s2
    800011ac:	8556                	mv	a0,s5
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	e7e080e7          	jalr	-386(ra) # 8000102c <walk>
    800011b6:	c51d                	beqz	a0,800011e4 <mappages+0x72>
    if(*pte & PTE_V)
    800011b8:	611c                	ld	a5,0(a0)
    800011ba:	8b85                	andi	a5,a5,1
    800011bc:	ef81                	bnez	a5,800011d4 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011be:	80b1                	srli	s1,s1,0xc
    800011c0:	04aa                	slli	s1,s1,0xa
    800011c2:	0164e4b3          	or	s1,s1,s6
    800011c6:	0014e493          	ori	s1,s1,1
    800011ca:	e104                	sd	s1,0(a0)
    if(a == last)
    800011cc:	03390863          	beq	s2,s3,800011fc <mappages+0x8a>
    a += PGSIZE;
    800011d0:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011d2:	bfc9                	j	800011a4 <mappages+0x32>
      panic("remap");
    800011d4:	00007517          	auipc	a0,0x7
    800011d8:	f0c50513          	addi	a0,a0,-244 # 800080e0 <digits+0xa0>
    800011dc:	fffff097          	auipc	ra,0xfffff
    800011e0:	366080e7          	jalr	870(ra) # 80000542 <panic>
      return -1;
    800011e4:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011e6:	60a6                	ld	ra,72(sp)
    800011e8:	6406                	ld	s0,64(sp)
    800011ea:	74e2                	ld	s1,56(sp)
    800011ec:	7942                	ld	s2,48(sp)
    800011ee:	79a2                	ld	s3,40(sp)
    800011f0:	7a02                	ld	s4,32(sp)
    800011f2:	6ae2                	ld	s5,24(sp)
    800011f4:	6b42                	ld	s6,16(sp)
    800011f6:	6ba2                	ld	s7,8(sp)
    800011f8:	6161                	addi	sp,sp,80
    800011fa:	8082                	ret
  return 0;
    800011fc:	4501                	li	a0,0
    800011fe:	b7e5                	j	800011e6 <mappages+0x74>

0000000080001200 <kvmmap>:
{
    80001200:	1141                	addi	sp,sp,-16
    80001202:	e406                	sd	ra,8(sp)
    80001204:	e022                	sd	s0,0(sp)
    80001206:	0800                	addi	s0,sp,16
    80001208:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000120a:	86ae                	mv	a3,a1
    8000120c:	85aa                	mv	a1,a0
    8000120e:	00008517          	auipc	a0,0x8
    80001212:	e0253503          	ld	a0,-510(a0) # 80009010 <kernel_pagetable>
    80001216:	00000097          	auipc	ra,0x0
    8000121a:	f5c080e7          	jalr	-164(ra) # 80001172 <mappages>
    8000121e:	e509                	bnez	a0,80001228 <kvmmap+0x28>
}
    80001220:	60a2                	ld	ra,8(sp)
    80001222:	6402                	ld	s0,0(sp)
    80001224:	0141                	addi	sp,sp,16
    80001226:	8082                	ret
    panic("kvmmap");
    80001228:	00007517          	auipc	a0,0x7
    8000122c:	ec050513          	addi	a0,a0,-320 # 800080e8 <digits+0xa8>
    80001230:	fffff097          	auipc	ra,0xfffff
    80001234:	312080e7          	jalr	786(ra) # 80000542 <panic>

0000000080001238 <kvminit>:
{
    80001238:	1101                	addi	sp,sp,-32
    8000123a:	ec06                	sd	ra,24(sp)
    8000123c:	e822                	sd	s0,16(sp)
    8000123e:	e426                	sd	s1,8(sp)
    80001240:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001242:	00000097          	auipc	ra,0x0
    80001246:	8cc080e7          	jalr	-1844(ra) # 80000b0e <kalloc>
    8000124a:	00008797          	auipc	a5,0x8
    8000124e:	dca7b323          	sd	a0,-570(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001252:	6605                	lui	a2,0x1
    80001254:	4581                	li	a1,0
    80001256:	00000097          	auipc	ra,0x0
    8000125a:	aee080e7          	jalr	-1298(ra) # 80000d44 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000125e:	4699                	li	a3,6
    80001260:	6605                	lui	a2,0x1
    80001262:	100005b7          	lui	a1,0x10000
    80001266:	10000537          	lui	a0,0x10000
    8000126a:	00000097          	auipc	ra,0x0
    8000126e:	f96080e7          	jalr	-106(ra) # 80001200 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001272:	4699                	li	a3,6
    80001274:	6605                	lui	a2,0x1
    80001276:	100015b7          	lui	a1,0x10001
    8000127a:	10001537          	lui	a0,0x10001
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f82080e7          	jalr	-126(ra) # 80001200 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001286:	4699                	li	a3,6
    80001288:	6641                	lui	a2,0x10
    8000128a:	020005b7          	lui	a1,0x2000
    8000128e:	02000537          	lui	a0,0x2000
    80001292:	00000097          	auipc	ra,0x0
    80001296:	f6e080e7          	jalr	-146(ra) # 80001200 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000129a:	4699                	li	a3,6
    8000129c:	00400637          	lui	a2,0x400
    800012a0:	0c0005b7          	lui	a1,0xc000
    800012a4:	0c000537          	lui	a0,0xc000
    800012a8:	00000097          	auipc	ra,0x0
    800012ac:	f58080e7          	jalr	-168(ra) # 80001200 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012b0:	00007497          	auipc	s1,0x7
    800012b4:	d5048493          	addi	s1,s1,-688 # 80008000 <etext>
    800012b8:	46a9                	li	a3,10
    800012ba:	80007617          	auipc	a2,0x80007
    800012be:	d4660613          	addi	a2,a2,-698 # 8000 <_entry-0x7fff8000>
    800012c2:	4585                	li	a1,1
    800012c4:	05fe                	slli	a1,a1,0x1f
    800012c6:	852e                	mv	a0,a1
    800012c8:	00000097          	auipc	ra,0x0
    800012cc:	f38080e7          	jalr	-200(ra) # 80001200 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012d0:	4699                	li	a3,6
    800012d2:	4645                	li	a2,17
    800012d4:	066e                	slli	a2,a2,0x1b
    800012d6:	8e05                	sub	a2,a2,s1
    800012d8:	85a6                	mv	a1,s1
    800012da:	8526                	mv	a0,s1
    800012dc:	00000097          	auipc	ra,0x0
    800012e0:	f24080e7          	jalr	-220(ra) # 80001200 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012e4:	46a9                	li	a3,10
    800012e6:	6605                	lui	a2,0x1
    800012e8:	00006597          	auipc	a1,0x6
    800012ec:	d1858593          	addi	a1,a1,-744 # 80007000 <_trampoline>
    800012f0:	04000537          	lui	a0,0x4000
    800012f4:	157d                	addi	a0,a0,-1
    800012f6:	0532                	slli	a0,a0,0xc
    800012f8:	00000097          	auipc	ra,0x0
    800012fc:	f08080e7          	jalr	-248(ra) # 80001200 <kvmmap>
}
    80001300:	60e2                	ld	ra,24(sp)
    80001302:	6442                	ld	s0,16(sp)
    80001304:	64a2                	ld	s1,8(sp)
    80001306:	6105                	addi	sp,sp,32
    80001308:	8082                	ret

000000008000130a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000130a:	715d                	addi	sp,sp,-80
    8000130c:	e486                	sd	ra,72(sp)
    8000130e:	e0a2                	sd	s0,64(sp)
    80001310:	fc26                	sd	s1,56(sp)
    80001312:	f84a                	sd	s2,48(sp)
    80001314:	f44e                	sd	s3,40(sp)
    80001316:	f052                	sd	s4,32(sp)
    80001318:	ec56                	sd	s5,24(sp)
    8000131a:	e85a                	sd	s6,16(sp)
    8000131c:	e45e                	sd	s7,8(sp)
    8000131e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001320:	03459793          	slli	a5,a1,0x34
    80001324:	e795                	bnez	a5,80001350 <uvmunmap+0x46>
    80001326:	8a2a                	mv	s4,a0
    80001328:	892e                	mv	s2,a1
    8000132a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000132c:	0632                	slli	a2,a2,0xc
    8000132e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001332:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001334:	6b05                	lui	s6,0x1
    80001336:	0735e263          	bltu	a1,s3,8000139a <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000133a:	60a6                	ld	ra,72(sp)
    8000133c:	6406                	ld	s0,64(sp)
    8000133e:	74e2                	ld	s1,56(sp)
    80001340:	7942                	ld	s2,48(sp)
    80001342:	79a2                	ld	s3,40(sp)
    80001344:	7a02                	ld	s4,32(sp)
    80001346:	6ae2                	ld	s5,24(sp)
    80001348:	6b42                	ld	s6,16(sp)
    8000134a:	6ba2                	ld	s7,8(sp)
    8000134c:	6161                	addi	sp,sp,80
    8000134e:	8082                	ret
    panic("uvmunmap: not aligned");
    80001350:	00007517          	auipc	a0,0x7
    80001354:	da050513          	addi	a0,a0,-608 # 800080f0 <digits+0xb0>
    80001358:	fffff097          	auipc	ra,0xfffff
    8000135c:	1ea080e7          	jalr	490(ra) # 80000542 <panic>
      panic("uvmunmap: walk");
    80001360:	00007517          	auipc	a0,0x7
    80001364:	da850513          	addi	a0,a0,-600 # 80008108 <digits+0xc8>
    80001368:	fffff097          	auipc	ra,0xfffff
    8000136c:	1da080e7          	jalr	474(ra) # 80000542 <panic>
      panic("uvmunmap: not mapped");
    80001370:	00007517          	auipc	a0,0x7
    80001374:	da850513          	addi	a0,a0,-600 # 80008118 <digits+0xd8>
    80001378:	fffff097          	auipc	ra,0xfffff
    8000137c:	1ca080e7          	jalr	458(ra) # 80000542 <panic>
      panic("uvmunmap: not a leaf");
    80001380:	00007517          	auipc	a0,0x7
    80001384:	db050513          	addi	a0,a0,-592 # 80008130 <digits+0xf0>
    80001388:	fffff097          	auipc	ra,0xfffff
    8000138c:	1ba080e7          	jalr	442(ra) # 80000542 <panic>
    *pte = 0;
    80001390:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001394:	995a                	add	s2,s2,s6
    80001396:	fb3972e3          	bgeu	s2,s3,8000133a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000139a:	4601                	li	a2,0
    8000139c:	85ca                	mv	a1,s2
    8000139e:	8552                	mv	a0,s4
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	c8c080e7          	jalr	-884(ra) # 8000102c <walk>
    800013a8:	84aa                	mv	s1,a0
    800013aa:	d95d                	beqz	a0,80001360 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013ac:	6108                	ld	a0,0(a0)
    800013ae:	00157793          	andi	a5,a0,1
    800013b2:	dfdd                	beqz	a5,80001370 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013b4:	3ff57793          	andi	a5,a0,1023
    800013b8:	fd7784e3          	beq	a5,s7,80001380 <uvmunmap+0x76>
    if(do_free){
    800013bc:	fc0a8ae3          	beqz	s5,80001390 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800013c0:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013c2:	0532                	slli	a0,a0,0xc
    800013c4:	fffff097          	auipc	ra,0xfffff
    800013c8:	64e080e7          	jalr	1614(ra) # 80000a12 <kfree>
    800013cc:	b7d1                	j	80001390 <uvmunmap+0x86>

00000000800013ce <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013ce:	1101                	addi	sp,sp,-32
    800013d0:	ec06                	sd	ra,24(sp)
    800013d2:	e822                	sd	s0,16(sp)
    800013d4:	e426                	sd	s1,8(sp)
    800013d6:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013d8:	fffff097          	auipc	ra,0xfffff
    800013dc:	736080e7          	jalr	1846(ra) # 80000b0e <kalloc>
    800013e0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013e2:	c519                	beqz	a0,800013f0 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013e4:	6605                	lui	a2,0x1
    800013e6:	4581                	li	a1,0
    800013e8:	00000097          	auipc	ra,0x0
    800013ec:	95c080e7          	jalr	-1700(ra) # 80000d44 <memset>
  return pagetable;
}
    800013f0:	8526                	mv	a0,s1
    800013f2:	60e2                	ld	ra,24(sp)
    800013f4:	6442                	ld	s0,16(sp)
    800013f6:	64a2                	ld	s1,8(sp)
    800013f8:	6105                	addi	sp,sp,32
    800013fa:	8082                	ret

00000000800013fc <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013fc:	7179                	addi	sp,sp,-48
    800013fe:	f406                	sd	ra,40(sp)
    80001400:	f022                	sd	s0,32(sp)
    80001402:	ec26                	sd	s1,24(sp)
    80001404:	e84a                	sd	s2,16(sp)
    80001406:	e44e                	sd	s3,8(sp)
    80001408:	e052                	sd	s4,0(sp)
    8000140a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000140c:	6785                	lui	a5,0x1
    8000140e:	04f67863          	bgeu	a2,a5,8000145e <uvminit+0x62>
    80001412:	8a2a                	mv	s4,a0
    80001414:	89ae                	mv	s3,a1
    80001416:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001418:	fffff097          	auipc	ra,0xfffff
    8000141c:	6f6080e7          	jalr	1782(ra) # 80000b0e <kalloc>
    80001420:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001422:	6605                	lui	a2,0x1
    80001424:	4581                	li	a1,0
    80001426:	00000097          	auipc	ra,0x0
    8000142a:	91e080e7          	jalr	-1762(ra) # 80000d44 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000142e:	4779                	li	a4,30
    80001430:	86ca                	mv	a3,s2
    80001432:	6605                	lui	a2,0x1
    80001434:	4581                	li	a1,0
    80001436:	8552                	mv	a0,s4
    80001438:	00000097          	auipc	ra,0x0
    8000143c:	d3a080e7          	jalr	-710(ra) # 80001172 <mappages>
  memmove(mem, src, sz);
    80001440:	8626                	mv	a2,s1
    80001442:	85ce                	mv	a1,s3
    80001444:	854a                	mv	a0,s2
    80001446:	00000097          	auipc	ra,0x0
    8000144a:	95a080e7          	jalr	-1702(ra) # 80000da0 <memmove>
}
    8000144e:	70a2                	ld	ra,40(sp)
    80001450:	7402                	ld	s0,32(sp)
    80001452:	64e2                	ld	s1,24(sp)
    80001454:	6942                	ld	s2,16(sp)
    80001456:	69a2                	ld	s3,8(sp)
    80001458:	6a02                	ld	s4,0(sp)
    8000145a:	6145                	addi	sp,sp,48
    8000145c:	8082                	ret
    panic("inituvm: more than a page");
    8000145e:	00007517          	auipc	a0,0x7
    80001462:	cea50513          	addi	a0,a0,-790 # 80008148 <digits+0x108>
    80001466:	fffff097          	auipc	ra,0xfffff
    8000146a:	0dc080e7          	jalr	220(ra) # 80000542 <panic>

000000008000146e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000146e:	1101                	addi	sp,sp,-32
    80001470:	ec06                	sd	ra,24(sp)
    80001472:	e822                	sd	s0,16(sp)
    80001474:	e426                	sd	s1,8(sp)
    80001476:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001478:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000147a:	00b67d63          	bgeu	a2,a1,80001494 <uvmdealloc+0x26>
    8000147e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001480:	6785                	lui	a5,0x1
    80001482:	17fd                	addi	a5,a5,-1
    80001484:	00f60733          	add	a4,a2,a5
    80001488:	767d                	lui	a2,0xfffff
    8000148a:	8f71                	and	a4,a4,a2
    8000148c:	97ae                	add	a5,a5,a1
    8000148e:	8ff1                	and	a5,a5,a2
    80001490:	00f76863          	bltu	a4,a5,800014a0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001494:	8526                	mv	a0,s1
    80001496:	60e2                	ld	ra,24(sp)
    80001498:	6442                	ld	s0,16(sp)
    8000149a:	64a2                	ld	s1,8(sp)
    8000149c:	6105                	addi	sp,sp,32
    8000149e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014a0:	8f99                	sub	a5,a5,a4
    800014a2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014a4:	4685                	li	a3,1
    800014a6:	0007861b          	sext.w	a2,a5
    800014aa:	85ba                	mv	a1,a4
    800014ac:	00000097          	auipc	ra,0x0
    800014b0:	e5e080e7          	jalr	-418(ra) # 8000130a <uvmunmap>
    800014b4:	b7c5                	j	80001494 <uvmdealloc+0x26>

00000000800014b6 <uvmalloc>:
  if(newsz < oldsz)
    800014b6:	0ab66163          	bltu	a2,a1,80001558 <uvmalloc+0xa2>
{
    800014ba:	7139                	addi	sp,sp,-64
    800014bc:	fc06                	sd	ra,56(sp)
    800014be:	f822                	sd	s0,48(sp)
    800014c0:	f426                	sd	s1,40(sp)
    800014c2:	f04a                	sd	s2,32(sp)
    800014c4:	ec4e                	sd	s3,24(sp)
    800014c6:	e852                	sd	s4,16(sp)
    800014c8:	e456                	sd	s5,8(sp)
    800014ca:	0080                	addi	s0,sp,64
    800014cc:	8aaa                	mv	s5,a0
    800014ce:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014d0:	6985                	lui	s3,0x1
    800014d2:	19fd                	addi	s3,s3,-1
    800014d4:	95ce                	add	a1,a1,s3
    800014d6:	79fd                	lui	s3,0xfffff
    800014d8:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014dc:	08c9f063          	bgeu	s3,a2,8000155c <uvmalloc+0xa6>
    800014e0:	894e                	mv	s2,s3
    mem = kalloc();
    800014e2:	fffff097          	auipc	ra,0xfffff
    800014e6:	62c080e7          	jalr	1580(ra) # 80000b0e <kalloc>
    800014ea:	84aa                	mv	s1,a0
    if(mem == 0){
    800014ec:	c51d                	beqz	a0,8000151a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014ee:	6605                	lui	a2,0x1
    800014f0:	4581                	li	a1,0
    800014f2:	00000097          	auipc	ra,0x0
    800014f6:	852080e7          	jalr	-1966(ra) # 80000d44 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014fa:	4779                	li	a4,30
    800014fc:	86a6                	mv	a3,s1
    800014fe:	6605                	lui	a2,0x1
    80001500:	85ca                	mv	a1,s2
    80001502:	8556                	mv	a0,s5
    80001504:	00000097          	auipc	ra,0x0
    80001508:	c6e080e7          	jalr	-914(ra) # 80001172 <mappages>
    8000150c:	e905                	bnez	a0,8000153c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000150e:	6785                	lui	a5,0x1
    80001510:	993e                	add	s2,s2,a5
    80001512:	fd4968e3          	bltu	s2,s4,800014e2 <uvmalloc+0x2c>
  return newsz;
    80001516:	8552                	mv	a0,s4
    80001518:	a809                	j	8000152a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000151a:	864e                	mv	a2,s3
    8000151c:	85ca                	mv	a1,s2
    8000151e:	8556                	mv	a0,s5
    80001520:	00000097          	auipc	ra,0x0
    80001524:	f4e080e7          	jalr	-178(ra) # 8000146e <uvmdealloc>
      return 0;
    80001528:	4501                	li	a0,0
}
    8000152a:	70e2                	ld	ra,56(sp)
    8000152c:	7442                	ld	s0,48(sp)
    8000152e:	74a2                	ld	s1,40(sp)
    80001530:	7902                	ld	s2,32(sp)
    80001532:	69e2                	ld	s3,24(sp)
    80001534:	6a42                	ld	s4,16(sp)
    80001536:	6aa2                	ld	s5,8(sp)
    80001538:	6121                	addi	sp,sp,64
    8000153a:	8082                	ret
      kfree(mem);
    8000153c:	8526                	mv	a0,s1
    8000153e:	fffff097          	auipc	ra,0xfffff
    80001542:	4d4080e7          	jalr	1236(ra) # 80000a12 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001546:	864e                	mv	a2,s3
    80001548:	85ca                	mv	a1,s2
    8000154a:	8556                	mv	a0,s5
    8000154c:	00000097          	auipc	ra,0x0
    80001550:	f22080e7          	jalr	-222(ra) # 8000146e <uvmdealloc>
      return 0;
    80001554:	4501                	li	a0,0
    80001556:	bfd1                	j	8000152a <uvmalloc+0x74>
    return oldsz;
    80001558:	852e                	mv	a0,a1
}
    8000155a:	8082                	ret
  return newsz;
    8000155c:	8532                	mv	a0,a2
    8000155e:	b7f1                	j	8000152a <uvmalloc+0x74>

0000000080001560 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001560:	7179                	addi	sp,sp,-48
    80001562:	f406                	sd	ra,40(sp)
    80001564:	f022                	sd	s0,32(sp)
    80001566:	ec26                	sd	s1,24(sp)
    80001568:	e84a                	sd	s2,16(sp)
    8000156a:	e44e                	sd	s3,8(sp)
    8000156c:	e052                	sd	s4,0(sp)
    8000156e:	1800                	addi	s0,sp,48
    80001570:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001572:	84aa                	mv	s1,a0
    80001574:	6905                	lui	s2,0x1
    80001576:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001578:	4985                	li	s3,1
    8000157a:	a821                	j	80001592 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000157c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000157e:	0532                	slli	a0,a0,0xc
    80001580:	00000097          	auipc	ra,0x0
    80001584:	fe0080e7          	jalr	-32(ra) # 80001560 <freewalk>
      pagetable[i] = 0;
    80001588:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000158c:	04a1                	addi	s1,s1,8
    8000158e:	03248163          	beq	s1,s2,800015b0 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001592:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001594:	00f57793          	andi	a5,a0,15
    80001598:	ff3782e3          	beq	a5,s3,8000157c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000159c:	8905                	andi	a0,a0,1
    8000159e:	d57d                	beqz	a0,8000158c <freewalk+0x2c>
      panic("freewalk: leaf");
    800015a0:	00007517          	auipc	a0,0x7
    800015a4:	bc850513          	addi	a0,a0,-1080 # 80008168 <digits+0x128>
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	f9a080e7          	jalr	-102(ra) # 80000542 <panic>
    }
  }
  kfree((void*)pagetable);
    800015b0:	8552                	mv	a0,s4
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	460080e7          	jalr	1120(ra) # 80000a12 <kfree>
}
    800015ba:	70a2                	ld	ra,40(sp)
    800015bc:	7402                	ld	s0,32(sp)
    800015be:	64e2                	ld	s1,24(sp)
    800015c0:	6942                	ld	s2,16(sp)
    800015c2:	69a2                	ld	s3,8(sp)
    800015c4:	6a02                	ld	s4,0(sp)
    800015c6:	6145                	addi	sp,sp,48
    800015c8:	8082                	ret

00000000800015ca <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015ca:	1101                	addi	sp,sp,-32
    800015cc:	ec06                	sd	ra,24(sp)
    800015ce:	e822                	sd	s0,16(sp)
    800015d0:	e426                	sd	s1,8(sp)
    800015d2:	1000                	addi	s0,sp,32
    800015d4:	84aa                	mv	s1,a0
  if(sz > 0)
    800015d6:	e999                	bnez	a1,800015ec <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015d8:	8526                	mv	a0,s1
    800015da:	00000097          	auipc	ra,0x0
    800015de:	f86080e7          	jalr	-122(ra) # 80001560 <freewalk>
}
    800015e2:	60e2                	ld	ra,24(sp)
    800015e4:	6442                	ld	s0,16(sp)
    800015e6:	64a2                	ld	s1,8(sp)
    800015e8:	6105                	addi	sp,sp,32
    800015ea:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015ec:	6605                	lui	a2,0x1
    800015ee:	167d                	addi	a2,a2,-1
    800015f0:	962e                	add	a2,a2,a1
    800015f2:	4685                	li	a3,1
    800015f4:	8231                	srli	a2,a2,0xc
    800015f6:	4581                	li	a1,0
    800015f8:	00000097          	auipc	ra,0x0
    800015fc:	d12080e7          	jalr	-750(ra) # 8000130a <uvmunmap>
    80001600:	bfe1                	j	800015d8 <uvmfree+0xe>

0000000080001602 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001602:	c679                	beqz	a2,800016d0 <uvmcopy+0xce>
{
    80001604:	715d                	addi	sp,sp,-80
    80001606:	e486                	sd	ra,72(sp)
    80001608:	e0a2                	sd	s0,64(sp)
    8000160a:	fc26                	sd	s1,56(sp)
    8000160c:	f84a                	sd	s2,48(sp)
    8000160e:	f44e                	sd	s3,40(sp)
    80001610:	f052                	sd	s4,32(sp)
    80001612:	ec56                	sd	s5,24(sp)
    80001614:	e85a                	sd	s6,16(sp)
    80001616:	e45e                	sd	s7,8(sp)
    80001618:	0880                	addi	s0,sp,80
    8000161a:	8b2a                	mv	s6,a0
    8000161c:	8aae                	mv	s5,a1
    8000161e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001620:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001622:	4601                	li	a2,0
    80001624:	85ce                	mv	a1,s3
    80001626:	855a                	mv	a0,s6
    80001628:	00000097          	auipc	ra,0x0
    8000162c:	a04080e7          	jalr	-1532(ra) # 8000102c <walk>
    80001630:	c531                	beqz	a0,8000167c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001632:	6118                	ld	a4,0(a0)
    80001634:	00177793          	andi	a5,a4,1
    80001638:	cbb1                	beqz	a5,8000168c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000163a:	00a75593          	srli	a1,a4,0xa
    8000163e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001642:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001646:	fffff097          	auipc	ra,0xfffff
    8000164a:	4c8080e7          	jalr	1224(ra) # 80000b0e <kalloc>
    8000164e:	892a                	mv	s2,a0
    80001650:	c939                	beqz	a0,800016a6 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001652:	6605                	lui	a2,0x1
    80001654:	85de                	mv	a1,s7
    80001656:	fffff097          	auipc	ra,0xfffff
    8000165a:	74a080e7          	jalr	1866(ra) # 80000da0 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000165e:	8726                	mv	a4,s1
    80001660:	86ca                	mv	a3,s2
    80001662:	6605                	lui	a2,0x1
    80001664:	85ce                	mv	a1,s3
    80001666:	8556                	mv	a0,s5
    80001668:	00000097          	auipc	ra,0x0
    8000166c:	b0a080e7          	jalr	-1270(ra) # 80001172 <mappages>
    80001670:	e515                	bnez	a0,8000169c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001672:	6785                	lui	a5,0x1
    80001674:	99be                	add	s3,s3,a5
    80001676:	fb49e6e3          	bltu	s3,s4,80001622 <uvmcopy+0x20>
    8000167a:	a081                	j	800016ba <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000167c:	00007517          	auipc	a0,0x7
    80001680:	afc50513          	addi	a0,a0,-1284 # 80008178 <digits+0x138>
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	ebe080e7          	jalr	-322(ra) # 80000542 <panic>
      panic("uvmcopy: page not present");
    8000168c:	00007517          	auipc	a0,0x7
    80001690:	b0c50513          	addi	a0,a0,-1268 # 80008198 <digits+0x158>
    80001694:	fffff097          	auipc	ra,0xfffff
    80001698:	eae080e7          	jalr	-338(ra) # 80000542 <panic>
      kfree(mem);
    8000169c:	854a                	mv	a0,s2
    8000169e:	fffff097          	auipc	ra,0xfffff
    800016a2:	374080e7          	jalr	884(ra) # 80000a12 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016a6:	4685                	li	a3,1
    800016a8:	00c9d613          	srli	a2,s3,0xc
    800016ac:	4581                	li	a1,0
    800016ae:	8556                	mv	a0,s5
    800016b0:	00000097          	auipc	ra,0x0
    800016b4:	c5a080e7          	jalr	-934(ra) # 8000130a <uvmunmap>
  return -1;
    800016b8:	557d                	li	a0,-1
}
    800016ba:	60a6                	ld	ra,72(sp)
    800016bc:	6406                	ld	s0,64(sp)
    800016be:	74e2                	ld	s1,56(sp)
    800016c0:	7942                	ld	s2,48(sp)
    800016c2:	79a2                	ld	s3,40(sp)
    800016c4:	7a02                	ld	s4,32(sp)
    800016c6:	6ae2                	ld	s5,24(sp)
    800016c8:	6b42                	ld	s6,16(sp)
    800016ca:	6ba2                	ld	s7,8(sp)
    800016cc:	6161                	addi	sp,sp,80
    800016ce:	8082                	ret
  return 0;
    800016d0:	4501                	li	a0,0
}
    800016d2:	8082                	ret

00000000800016d4 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016d4:	1141                	addi	sp,sp,-16
    800016d6:	e406                	sd	ra,8(sp)
    800016d8:	e022                	sd	s0,0(sp)
    800016da:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016dc:	4601                	li	a2,0
    800016de:	00000097          	auipc	ra,0x0
    800016e2:	94e080e7          	jalr	-1714(ra) # 8000102c <walk>
  if(pte == 0)
    800016e6:	c901                	beqz	a0,800016f6 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016e8:	611c                	ld	a5,0(a0)
    800016ea:	9bbd                	andi	a5,a5,-17
    800016ec:	e11c                	sd	a5,0(a0)
}
    800016ee:	60a2                	ld	ra,8(sp)
    800016f0:	6402                	ld	s0,0(sp)
    800016f2:	0141                	addi	sp,sp,16
    800016f4:	8082                	ret
    panic("uvmclear");
    800016f6:	00007517          	auipc	a0,0x7
    800016fa:	ac250513          	addi	a0,a0,-1342 # 800081b8 <digits+0x178>
    800016fe:	fffff097          	auipc	ra,0xfffff
    80001702:	e44080e7          	jalr	-444(ra) # 80000542 <panic>

0000000080001706 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001706:	c6bd                	beqz	a3,80001774 <copyout+0x6e>
{
    80001708:	715d                	addi	sp,sp,-80
    8000170a:	e486                	sd	ra,72(sp)
    8000170c:	e0a2                	sd	s0,64(sp)
    8000170e:	fc26                	sd	s1,56(sp)
    80001710:	f84a                	sd	s2,48(sp)
    80001712:	f44e                	sd	s3,40(sp)
    80001714:	f052                	sd	s4,32(sp)
    80001716:	ec56                	sd	s5,24(sp)
    80001718:	e85a                	sd	s6,16(sp)
    8000171a:	e45e                	sd	s7,8(sp)
    8000171c:	e062                	sd	s8,0(sp)
    8000171e:	0880                	addi	s0,sp,80
    80001720:	8b2a                	mv	s6,a0
    80001722:	8c2e                	mv	s8,a1
    80001724:	8a32                	mv	s4,a2
    80001726:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001728:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000172a:	6a85                	lui	s5,0x1
    8000172c:	a015                	j	80001750 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000172e:	9562                	add	a0,a0,s8
    80001730:	0004861b          	sext.w	a2,s1
    80001734:	85d2                	mv	a1,s4
    80001736:	41250533          	sub	a0,a0,s2
    8000173a:	fffff097          	auipc	ra,0xfffff
    8000173e:	666080e7          	jalr	1638(ra) # 80000da0 <memmove>

    len -= n;
    80001742:	409989b3          	sub	s3,s3,s1
    src += n;
    80001746:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001748:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000174c:	02098263          	beqz	s3,80001770 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001750:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001754:	85ca                	mv	a1,s2
    80001756:	855a                	mv	a0,s6
    80001758:	00000097          	auipc	ra,0x0
    8000175c:	97a080e7          	jalr	-1670(ra) # 800010d2 <walkaddr>
    if(pa0 == 0)
    80001760:	cd01                	beqz	a0,80001778 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001762:	418904b3          	sub	s1,s2,s8
    80001766:	94d6                	add	s1,s1,s5
    if(n > len)
    80001768:	fc99f3e3          	bgeu	s3,s1,8000172e <copyout+0x28>
    8000176c:	84ce                	mv	s1,s3
    8000176e:	b7c1                	j	8000172e <copyout+0x28>
  }
  return 0;
    80001770:	4501                	li	a0,0
    80001772:	a021                	j	8000177a <copyout+0x74>
    80001774:	4501                	li	a0,0
}
    80001776:	8082                	ret
      return -1;
    80001778:	557d                	li	a0,-1
}
    8000177a:	60a6                	ld	ra,72(sp)
    8000177c:	6406                	ld	s0,64(sp)
    8000177e:	74e2                	ld	s1,56(sp)
    80001780:	7942                	ld	s2,48(sp)
    80001782:	79a2                	ld	s3,40(sp)
    80001784:	7a02                	ld	s4,32(sp)
    80001786:	6ae2                	ld	s5,24(sp)
    80001788:	6b42                	ld	s6,16(sp)
    8000178a:	6ba2                	ld	s7,8(sp)
    8000178c:	6c02                	ld	s8,0(sp)
    8000178e:	6161                	addi	sp,sp,80
    80001790:	8082                	ret

0000000080001792 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001792:	caa5                	beqz	a3,80001802 <copyin+0x70>
{
    80001794:	715d                	addi	sp,sp,-80
    80001796:	e486                	sd	ra,72(sp)
    80001798:	e0a2                	sd	s0,64(sp)
    8000179a:	fc26                	sd	s1,56(sp)
    8000179c:	f84a                	sd	s2,48(sp)
    8000179e:	f44e                	sd	s3,40(sp)
    800017a0:	f052                	sd	s4,32(sp)
    800017a2:	ec56                	sd	s5,24(sp)
    800017a4:	e85a                	sd	s6,16(sp)
    800017a6:	e45e                	sd	s7,8(sp)
    800017a8:	e062                	sd	s8,0(sp)
    800017aa:	0880                	addi	s0,sp,80
    800017ac:	8b2a                	mv	s6,a0
    800017ae:	8a2e                	mv	s4,a1
    800017b0:	8c32                	mv	s8,a2
    800017b2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017b4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017b6:	6a85                	lui	s5,0x1
    800017b8:	a01d                	j	800017de <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017ba:	018505b3          	add	a1,a0,s8
    800017be:	0004861b          	sext.w	a2,s1
    800017c2:	412585b3          	sub	a1,a1,s2
    800017c6:	8552                	mv	a0,s4
    800017c8:	fffff097          	auipc	ra,0xfffff
    800017cc:	5d8080e7          	jalr	1496(ra) # 80000da0 <memmove>

    len -= n;
    800017d0:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017d4:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017d6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017da:	02098263          	beqz	s3,800017fe <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017de:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017e2:	85ca                	mv	a1,s2
    800017e4:	855a                	mv	a0,s6
    800017e6:	00000097          	auipc	ra,0x0
    800017ea:	8ec080e7          	jalr	-1812(ra) # 800010d2 <walkaddr>
    if(pa0 == 0)
    800017ee:	cd01                	beqz	a0,80001806 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017f0:	418904b3          	sub	s1,s2,s8
    800017f4:	94d6                	add	s1,s1,s5
    if(n > len)
    800017f6:	fc99f2e3          	bgeu	s3,s1,800017ba <copyin+0x28>
    800017fa:	84ce                	mv	s1,s3
    800017fc:	bf7d                	j	800017ba <copyin+0x28>
  }
  return 0;
    800017fe:	4501                	li	a0,0
    80001800:	a021                	j	80001808 <copyin+0x76>
    80001802:	4501                	li	a0,0
}
    80001804:	8082                	ret
      return -1;
    80001806:	557d                	li	a0,-1
}
    80001808:	60a6                	ld	ra,72(sp)
    8000180a:	6406                	ld	s0,64(sp)
    8000180c:	74e2                	ld	s1,56(sp)
    8000180e:	7942                	ld	s2,48(sp)
    80001810:	79a2                	ld	s3,40(sp)
    80001812:	7a02                	ld	s4,32(sp)
    80001814:	6ae2                	ld	s5,24(sp)
    80001816:	6b42                	ld	s6,16(sp)
    80001818:	6ba2                	ld	s7,8(sp)
    8000181a:	6c02                	ld	s8,0(sp)
    8000181c:	6161                	addi	sp,sp,80
    8000181e:	8082                	ret

0000000080001820 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001820:	c6c5                	beqz	a3,800018c8 <copyinstr+0xa8>
{
    80001822:	715d                	addi	sp,sp,-80
    80001824:	e486                	sd	ra,72(sp)
    80001826:	e0a2                	sd	s0,64(sp)
    80001828:	fc26                	sd	s1,56(sp)
    8000182a:	f84a                	sd	s2,48(sp)
    8000182c:	f44e                	sd	s3,40(sp)
    8000182e:	f052                	sd	s4,32(sp)
    80001830:	ec56                	sd	s5,24(sp)
    80001832:	e85a                	sd	s6,16(sp)
    80001834:	e45e                	sd	s7,8(sp)
    80001836:	0880                	addi	s0,sp,80
    80001838:	8a2a                	mv	s4,a0
    8000183a:	8b2e                	mv	s6,a1
    8000183c:	8bb2                	mv	s7,a2
    8000183e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001840:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001842:	6985                	lui	s3,0x1
    80001844:	a035                	j	80001870 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001846:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000184a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000184c:	0017b793          	seqz	a5,a5
    80001850:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001854:	60a6                	ld	ra,72(sp)
    80001856:	6406                	ld	s0,64(sp)
    80001858:	74e2                	ld	s1,56(sp)
    8000185a:	7942                	ld	s2,48(sp)
    8000185c:	79a2                	ld	s3,40(sp)
    8000185e:	7a02                	ld	s4,32(sp)
    80001860:	6ae2                	ld	s5,24(sp)
    80001862:	6b42                	ld	s6,16(sp)
    80001864:	6ba2                	ld	s7,8(sp)
    80001866:	6161                	addi	sp,sp,80
    80001868:	8082                	ret
    srcva = va0 + PGSIZE;
    8000186a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000186e:	c8a9                	beqz	s1,800018c0 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001870:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001874:	85ca                	mv	a1,s2
    80001876:	8552                	mv	a0,s4
    80001878:	00000097          	auipc	ra,0x0
    8000187c:	85a080e7          	jalr	-1958(ra) # 800010d2 <walkaddr>
    if(pa0 == 0)
    80001880:	c131                	beqz	a0,800018c4 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001882:	41790833          	sub	a6,s2,s7
    80001886:	984e                	add	a6,a6,s3
    if(n > max)
    80001888:	0104f363          	bgeu	s1,a6,8000188e <copyinstr+0x6e>
    8000188c:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000188e:	955e                	add	a0,a0,s7
    80001890:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001894:	fc080be3          	beqz	a6,8000186a <copyinstr+0x4a>
    80001898:	985a                	add	a6,a6,s6
    8000189a:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000189c:	41650633          	sub	a2,a0,s6
    800018a0:	14fd                	addi	s1,s1,-1
    800018a2:	9b26                	add	s6,s6,s1
    800018a4:	00f60733          	add	a4,a2,a5
    800018a8:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800018ac:	df49                	beqz	a4,80001846 <copyinstr+0x26>
        *dst = *p;
    800018ae:	00e78023          	sb	a4,0(a5)
      --max;
    800018b2:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018b6:	0785                	addi	a5,a5,1
    while(n > 0){
    800018b8:	ff0796e3          	bne	a5,a6,800018a4 <copyinstr+0x84>
      dst++;
    800018bc:	8b42                	mv	s6,a6
    800018be:	b775                	j	8000186a <copyinstr+0x4a>
    800018c0:	4781                	li	a5,0
    800018c2:	b769                	j	8000184c <copyinstr+0x2c>
      return -1;
    800018c4:	557d                	li	a0,-1
    800018c6:	b779                	j	80001854 <copyinstr+0x34>
  int got_null = 0;
    800018c8:	4781                	li	a5,0
  if(got_null){
    800018ca:	0017b793          	seqz	a5,a5
    800018ce:	40f00533          	neg	a0,a5
}
    800018d2:	8082                	ret

00000000800018d4 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018d4:	1101                	addi	sp,sp,-32
    800018d6:	ec06                	sd	ra,24(sp)
    800018d8:	e822                	sd	s0,16(sp)
    800018da:	e426                	sd	s1,8(sp)
    800018dc:	1000                	addi	s0,sp,32
    800018de:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018e0:	fffff097          	auipc	ra,0xfffff
    800018e4:	2ee080e7          	jalr	750(ra) # 80000bce <holding>
    800018e8:	c909                	beqz	a0,800018fa <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018ea:	749c                	ld	a5,40(s1)
    800018ec:	00978f63          	beq	a5,s1,8000190a <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018f0:	60e2                	ld	ra,24(sp)
    800018f2:	6442                	ld	s0,16(sp)
    800018f4:	64a2                	ld	s1,8(sp)
    800018f6:	6105                	addi	sp,sp,32
    800018f8:	8082                	ret
    panic("wakeup1");
    800018fa:	00007517          	auipc	a0,0x7
    800018fe:	8ce50513          	addi	a0,a0,-1842 # 800081c8 <digits+0x188>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	c40080e7          	jalr	-960(ra) # 80000542 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    8000190a:	4c98                	lw	a4,24(s1)
    8000190c:	4785                	li	a5,1
    8000190e:	fef711e3          	bne	a4,a5,800018f0 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001912:	4789                	li	a5,2
    80001914:	cc9c                	sw	a5,24(s1)
}
    80001916:	bfe9                	j	800018f0 <wakeup1+0x1c>

0000000080001918 <procinit>:
{
    80001918:	715d                	addi	sp,sp,-80
    8000191a:	e486                	sd	ra,72(sp)
    8000191c:	e0a2                	sd	s0,64(sp)
    8000191e:	fc26                	sd	s1,56(sp)
    80001920:	f84a                	sd	s2,48(sp)
    80001922:	f44e                	sd	s3,40(sp)
    80001924:	f052                	sd	s4,32(sp)
    80001926:	ec56                	sd	s5,24(sp)
    80001928:	e85a                	sd	s6,16(sp)
    8000192a:	e45e                	sd	s7,8(sp)
    8000192c:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    8000192e:	00007597          	auipc	a1,0x7
    80001932:	8a258593          	addi	a1,a1,-1886 # 800081d0 <digits+0x190>
    80001936:	00010517          	auipc	a0,0x10
    8000193a:	01a50513          	addi	a0,a0,26 # 80011950 <pid_lock>
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	27a080e7          	jalr	634(ra) # 80000bb8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001946:	00010917          	auipc	s2,0x10
    8000194a:	42290913          	addi	s2,s2,1058 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    8000194e:	00007b97          	auipc	s7,0x7
    80001952:	88ab8b93          	addi	s7,s7,-1910 # 800081d8 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    80001956:	8b4a                	mv	s6,s2
    80001958:	00006a97          	auipc	s5,0x6
    8000195c:	6a8a8a93          	addi	s5,s5,1704 # 80008000 <etext>
    80001960:	040009b7          	lui	s3,0x4000
    80001964:	19fd                	addi	s3,s3,-1
    80001966:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001968:	00016a17          	auipc	s4,0x16
    8000196c:	000a0a13          	mv	s4,s4
      initlock(&p->lock, "proc");
    80001970:	85de                	mv	a1,s7
    80001972:	854a                	mv	a0,s2
    80001974:	fffff097          	auipc	ra,0xfffff
    80001978:	244080e7          	jalr	580(ra) # 80000bb8 <initlock>
      char *pa = kalloc();
    8000197c:	fffff097          	auipc	ra,0xfffff
    80001980:	192080e7          	jalr	402(ra) # 80000b0e <kalloc>
    80001984:	85aa                	mv	a1,a0
      if(pa == 0)
    80001986:	c929                	beqz	a0,800019d8 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001988:	416904b3          	sub	s1,s2,s6
    8000198c:	8491                	srai	s1,s1,0x4
    8000198e:	000ab783          	ld	a5,0(s5)
    80001992:	02f484b3          	mul	s1,s1,a5
    80001996:	2485                	addiw	s1,s1,1
    80001998:	00d4949b          	slliw	s1,s1,0xd
    8000199c:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019a0:	4699                	li	a3,6
    800019a2:	6605                	lui	a2,0x1
    800019a4:	8526                	mv	a0,s1
    800019a6:	00000097          	auipc	ra,0x0
    800019aa:	85a080e7          	jalr	-1958(ra) # 80001200 <kvmmap>
      p->kstack = va;
    800019ae:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b2:	17090913          	addi	s2,s2,368
    800019b6:	fb491de3          	bne	s2,s4,80001970 <procinit+0x58>
  kvminithart();
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	64e080e7          	jalr	1614(ra) # 80001008 <kvminithart>
}
    800019c2:	60a6                	ld	ra,72(sp)
    800019c4:	6406                	ld	s0,64(sp)
    800019c6:	74e2                	ld	s1,56(sp)
    800019c8:	7942                	ld	s2,48(sp)
    800019ca:	79a2                	ld	s3,40(sp)
    800019cc:	7a02                	ld	s4,32(sp)
    800019ce:	6ae2                	ld	s5,24(sp)
    800019d0:	6b42                	ld	s6,16(sp)
    800019d2:	6ba2                	ld	s7,8(sp)
    800019d4:	6161                	addi	sp,sp,80
    800019d6:	8082                	ret
        panic("kalloc");
    800019d8:	00007517          	auipc	a0,0x7
    800019dc:	80850513          	addi	a0,a0,-2040 # 800081e0 <digits+0x1a0>
    800019e0:	fffff097          	auipc	ra,0xfffff
    800019e4:	b62080e7          	jalr	-1182(ra) # 80000542 <panic>

00000000800019e8 <cpuid>:
{
    800019e8:	1141                	addi	sp,sp,-16
    800019ea:	e422                	sd	s0,8(sp)
    800019ec:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019ee:	8512                	mv	a0,tp
}
    800019f0:	2501                	sext.w	a0,a0
    800019f2:	6422                	ld	s0,8(sp)
    800019f4:	0141                	addi	sp,sp,16
    800019f6:	8082                	ret

00000000800019f8 <mycpu>:
mycpu(void) {
    800019f8:	1141                	addi	sp,sp,-16
    800019fa:	e422                	sd	s0,8(sp)
    800019fc:	0800                	addi	s0,sp,16
    800019fe:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a00:	2781                	sext.w	a5,a5
    80001a02:	079e                	slli	a5,a5,0x7
}
    80001a04:	00010517          	auipc	a0,0x10
    80001a08:	f6450513          	addi	a0,a0,-156 # 80011968 <cpus>
    80001a0c:	953e                	add	a0,a0,a5
    80001a0e:	6422                	ld	s0,8(sp)
    80001a10:	0141                	addi	sp,sp,16
    80001a12:	8082                	ret

0000000080001a14 <myproc>:
myproc(void) {
    80001a14:	1101                	addi	sp,sp,-32
    80001a16:	ec06                	sd	ra,24(sp)
    80001a18:	e822                	sd	s0,16(sp)
    80001a1a:	e426                	sd	s1,8(sp)
    80001a1c:	1000                	addi	s0,sp,32
  push_off();
    80001a1e:	fffff097          	auipc	ra,0xfffff
    80001a22:	1de080e7          	jalr	478(ra) # 80000bfc <push_off>
    80001a26:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a28:	2781                	sext.w	a5,a5
    80001a2a:	079e                	slli	a5,a5,0x7
    80001a2c:	00010717          	auipc	a4,0x10
    80001a30:	f2470713          	addi	a4,a4,-220 # 80011950 <pid_lock>
    80001a34:	97ba                	add	a5,a5,a4
    80001a36:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a38:	fffff097          	auipc	ra,0xfffff
    80001a3c:	264080e7          	jalr	612(ra) # 80000c9c <pop_off>
}
    80001a40:	8526                	mv	a0,s1
    80001a42:	60e2                	ld	ra,24(sp)
    80001a44:	6442                	ld	s0,16(sp)
    80001a46:	64a2                	ld	s1,8(sp)
    80001a48:	6105                	addi	sp,sp,32
    80001a4a:	8082                	ret

0000000080001a4c <forkret>:
{
    80001a4c:	1141                	addi	sp,sp,-16
    80001a4e:	e406                	sd	ra,8(sp)
    80001a50:	e022                	sd	s0,0(sp)
    80001a52:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a54:	00000097          	auipc	ra,0x0
    80001a58:	fc0080e7          	jalr	-64(ra) # 80001a14 <myproc>
    80001a5c:	fffff097          	auipc	ra,0xfffff
    80001a60:	2a0080e7          	jalr	672(ra) # 80000cfc <release>
  if (first) {
    80001a64:	00007797          	auipc	a5,0x7
    80001a68:	ddc7a783          	lw	a5,-548(a5) # 80008840 <first.1>
    80001a6c:	eb89                	bnez	a5,80001a7e <forkret+0x32>
  usertrapret();
    80001a6e:	00001097          	auipc	ra,0x1
    80001a72:	c4c080e7          	jalr	-948(ra) # 800026ba <usertrapret>
}
    80001a76:	60a2                	ld	ra,8(sp)
    80001a78:	6402                	ld	s0,0(sp)
    80001a7a:	0141                	addi	sp,sp,16
    80001a7c:	8082                	ret
    first = 0;
    80001a7e:	00007797          	auipc	a5,0x7
    80001a82:	dc07a123          	sw	zero,-574(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    80001a86:	4505                	li	a0,1
    80001a88:	00002097          	auipc	ra,0x2
    80001a8c:	a42080e7          	jalr	-1470(ra) # 800034ca <fsinit>
    80001a90:	bff9                	j	80001a6e <forkret+0x22>

0000000080001a92 <allocpid>:
allocpid() {
    80001a92:	1101                	addi	sp,sp,-32
    80001a94:	ec06                	sd	ra,24(sp)
    80001a96:	e822                	sd	s0,16(sp)
    80001a98:	e426                	sd	s1,8(sp)
    80001a9a:	e04a                	sd	s2,0(sp)
    80001a9c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a9e:	00010917          	auipc	s2,0x10
    80001aa2:	eb290913          	addi	s2,s2,-334 # 80011950 <pid_lock>
    80001aa6:	854a                	mv	a0,s2
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	1a0080e7          	jalr	416(ra) # 80000c48 <acquire>
  pid = nextpid;
    80001ab0:	00007797          	auipc	a5,0x7
    80001ab4:	d9478793          	addi	a5,a5,-620 # 80008844 <nextpid>
    80001ab8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001aba:	0014871b          	addiw	a4,s1,1
    80001abe:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ac0:	854a                	mv	a0,s2
    80001ac2:	fffff097          	auipc	ra,0xfffff
    80001ac6:	23a080e7          	jalr	570(ra) # 80000cfc <release>
}
    80001aca:	8526                	mv	a0,s1
    80001acc:	60e2                	ld	ra,24(sp)
    80001ace:	6442                	ld	s0,16(sp)
    80001ad0:	64a2                	ld	s1,8(sp)
    80001ad2:	6902                	ld	s2,0(sp)
    80001ad4:	6105                	addi	sp,sp,32
    80001ad6:	8082                	ret

0000000080001ad8 <proc_pagetable>:
{
    80001ad8:	1101                	addi	sp,sp,-32
    80001ada:	ec06                	sd	ra,24(sp)
    80001adc:	e822                	sd	s0,16(sp)
    80001ade:	e426                	sd	s1,8(sp)
    80001ae0:	e04a                	sd	s2,0(sp)
    80001ae2:	1000                	addi	s0,sp,32
    80001ae4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ae6:	00000097          	auipc	ra,0x0
    80001aea:	8e8080e7          	jalr	-1816(ra) # 800013ce <uvmcreate>
    80001aee:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001af0:	c121                	beqz	a0,80001b30 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001af2:	4729                	li	a4,10
    80001af4:	00005697          	auipc	a3,0x5
    80001af8:	50c68693          	addi	a3,a3,1292 # 80007000 <_trampoline>
    80001afc:	6605                	lui	a2,0x1
    80001afe:	040005b7          	lui	a1,0x4000
    80001b02:	15fd                	addi	a1,a1,-1
    80001b04:	05b2                	slli	a1,a1,0xc
    80001b06:	fffff097          	auipc	ra,0xfffff
    80001b0a:	66c080e7          	jalr	1644(ra) # 80001172 <mappages>
    80001b0e:	02054863          	bltz	a0,80001b3e <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b12:	4719                	li	a4,6
    80001b14:	05893683          	ld	a3,88(s2)
    80001b18:	6605                	lui	a2,0x1
    80001b1a:	020005b7          	lui	a1,0x2000
    80001b1e:	15fd                	addi	a1,a1,-1
    80001b20:	05b6                	slli	a1,a1,0xd
    80001b22:	8526                	mv	a0,s1
    80001b24:	fffff097          	auipc	ra,0xfffff
    80001b28:	64e080e7          	jalr	1614(ra) # 80001172 <mappages>
    80001b2c:	02054163          	bltz	a0,80001b4e <proc_pagetable+0x76>
}
    80001b30:	8526                	mv	a0,s1
    80001b32:	60e2                	ld	ra,24(sp)
    80001b34:	6442                	ld	s0,16(sp)
    80001b36:	64a2                	ld	s1,8(sp)
    80001b38:	6902                	ld	s2,0(sp)
    80001b3a:	6105                	addi	sp,sp,32
    80001b3c:	8082                	ret
    uvmfree(pagetable, 0);
    80001b3e:	4581                	li	a1,0
    80001b40:	8526                	mv	a0,s1
    80001b42:	00000097          	auipc	ra,0x0
    80001b46:	a88080e7          	jalr	-1400(ra) # 800015ca <uvmfree>
    return 0;
    80001b4a:	4481                	li	s1,0
    80001b4c:	b7d5                	j	80001b30 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b4e:	4681                	li	a3,0
    80001b50:	4605                	li	a2,1
    80001b52:	040005b7          	lui	a1,0x4000
    80001b56:	15fd                	addi	a1,a1,-1
    80001b58:	05b2                	slli	a1,a1,0xc
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	fffff097          	auipc	ra,0xfffff
    80001b60:	7ae080e7          	jalr	1966(ra) # 8000130a <uvmunmap>
    uvmfree(pagetable, 0);
    80001b64:	4581                	li	a1,0
    80001b66:	8526                	mv	a0,s1
    80001b68:	00000097          	auipc	ra,0x0
    80001b6c:	a62080e7          	jalr	-1438(ra) # 800015ca <uvmfree>
    return 0;
    80001b70:	4481                	li	s1,0
    80001b72:	bf7d                	j	80001b30 <proc_pagetable+0x58>

0000000080001b74 <proc_freepagetable>:
{
    80001b74:	1101                	addi	sp,sp,-32
    80001b76:	ec06                	sd	ra,24(sp)
    80001b78:	e822                	sd	s0,16(sp)
    80001b7a:	e426                	sd	s1,8(sp)
    80001b7c:	e04a                	sd	s2,0(sp)
    80001b7e:	1000                	addi	s0,sp,32
    80001b80:	84aa                	mv	s1,a0
    80001b82:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	040005b7          	lui	a1,0x4000
    80001b8c:	15fd                	addi	a1,a1,-1
    80001b8e:	05b2                	slli	a1,a1,0xc
    80001b90:	fffff097          	auipc	ra,0xfffff
    80001b94:	77a080e7          	jalr	1914(ra) # 8000130a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b98:	4681                	li	a3,0
    80001b9a:	4605                	li	a2,1
    80001b9c:	020005b7          	lui	a1,0x2000
    80001ba0:	15fd                	addi	a1,a1,-1
    80001ba2:	05b6                	slli	a1,a1,0xd
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	fffff097          	auipc	ra,0xfffff
    80001baa:	764080e7          	jalr	1892(ra) # 8000130a <uvmunmap>
  uvmfree(pagetable, sz);
    80001bae:	85ca                	mv	a1,s2
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	00000097          	auipc	ra,0x0
    80001bb6:	a18080e7          	jalr	-1512(ra) # 800015ca <uvmfree>
}
    80001bba:	60e2                	ld	ra,24(sp)
    80001bbc:	6442                	ld	s0,16(sp)
    80001bbe:	64a2                	ld	s1,8(sp)
    80001bc0:	6902                	ld	s2,0(sp)
    80001bc2:	6105                	addi	sp,sp,32
    80001bc4:	8082                	ret

0000000080001bc6 <freeproc>:
{
    80001bc6:	1101                	addi	sp,sp,-32
    80001bc8:	ec06                	sd	ra,24(sp)
    80001bca:	e822                	sd	s0,16(sp)
    80001bcc:	e426                	sd	s1,8(sp)
    80001bce:	1000                	addi	s0,sp,32
    80001bd0:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bd2:	6d28                	ld	a0,88(a0)
    80001bd4:	c509                	beqz	a0,80001bde <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bd6:	fffff097          	auipc	ra,0xfffff
    80001bda:	e3c080e7          	jalr	-452(ra) # 80000a12 <kfree>
  p->trapframe = 0;
    80001bde:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001be2:	68a8                	ld	a0,80(s1)
    80001be4:	c511                	beqz	a0,80001bf0 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001be6:	64ac                	ld	a1,72(s1)
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	f8c080e7          	jalr	-116(ra) # 80001b74 <proc_freepagetable>
  p->pagetable = 0;
    80001bf0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bf4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bf8:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001bfc:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c00:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c04:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c08:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c0c:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c10:	0004ac23          	sw	zero,24(s1)
}
    80001c14:	60e2                	ld	ra,24(sp)
    80001c16:	6442                	ld	s0,16(sp)
    80001c18:	64a2                	ld	s1,8(sp)
    80001c1a:	6105                	addi	sp,sp,32
    80001c1c:	8082                	ret

0000000080001c1e <allocproc>:
{
    80001c1e:	1101                	addi	sp,sp,-32
    80001c20:	ec06                	sd	ra,24(sp)
    80001c22:	e822                	sd	s0,16(sp)
    80001c24:	e426                	sd	s1,8(sp)
    80001c26:	e04a                	sd	s2,0(sp)
    80001c28:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c2a:	00010497          	auipc	s1,0x10
    80001c2e:	13e48493          	addi	s1,s1,318 # 80011d68 <proc>
    80001c32:	00016917          	auipc	s2,0x16
    80001c36:	d3690913          	addi	s2,s2,-714 # 80017968 <tickslock>
    acquire(&p->lock);
    80001c3a:	8526                	mv	a0,s1
    80001c3c:	fffff097          	auipc	ra,0xfffff
    80001c40:	00c080e7          	jalr	12(ra) # 80000c48 <acquire>
    if(p->state == UNUSED) {
    80001c44:	4c9c                	lw	a5,24(s1)
    80001c46:	cf81                	beqz	a5,80001c5e <allocproc+0x40>
      release(&p->lock);
    80001c48:	8526                	mv	a0,s1
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	0b2080e7          	jalr	178(ra) # 80000cfc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c52:	17048493          	addi	s1,s1,368
    80001c56:	ff2492e3          	bne	s1,s2,80001c3a <allocproc+0x1c>
  return 0;
    80001c5a:	4481                	li	s1,0
    80001c5c:	a0b9                	j	80001caa <allocproc+0x8c>
  p->pid = allocpid();
    80001c5e:	00000097          	auipc	ra,0x0
    80001c62:	e34080e7          	jalr	-460(ra) # 80001a92 <allocpid>
    80001c66:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	ea6080e7          	jalr	-346(ra) # 80000b0e <kalloc>
    80001c70:	892a                	mv	s2,a0
    80001c72:	eca8                	sd	a0,88(s1)
    80001c74:	c131                	beqz	a0,80001cb8 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001c76:	8526                	mv	a0,s1
    80001c78:	00000097          	auipc	ra,0x0
    80001c7c:	e60080e7          	jalr	-416(ra) # 80001ad8 <proc_pagetable>
    80001c80:	892a                	mv	s2,a0
    80001c82:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c84:	c129                	beqz	a0,80001cc6 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001c86:	07000613          	li	a2,112
    80001c8a:	4581                	li	a1,0
    80001c8c:	06048513          	addi	a0,s1,96
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	0b4080e7          	jalr	180(ra) # 80000d44 <memset>
  p->context.ra = (uint64)forkret;
    80001c98:	00000797          	auipc	a5,0x0
    80001c9c:	db478793          	addi	a5,a5,-588 # 80001a4c <forkret>
    80001ca0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ca2:	60bc                	ld	a5,64(s1)
    80001ca4:	6705                	lui	a4,0x1
    80001ca6:	97ba                	add	a5,a5,a4
    80001ca8:	f4bc                	sd	a5,104(s1)
}
    80001caa:	8526                	mv	a0,s1
    80001cac:	60e2                	ld	ra,24(sp)
    80001cae:	6442                	ld	s0,16(sp)
    80001cb0:	64a2                	ld	s1,8(sp)
    80001cb2:	6902                	ld	s2,0(sp)
    80001cb4:	6105                	addi	sp,sp,32
    80001cb6:	8082                	ret
    release(&p->lock);
    80001cb8:	8526                	mv	a0,s1
    80001cba:	fffff097          	auipc	ra,0xfffff
    80001cbe:	042080e7          	jalr	66(ra) # 80000cfc <release>
    return 0;
    80001cc2:	84ca                	mv	s1,s2
    80001cc4:	b7dd                	j	80001caa <allocproc+0x8c>
    freeproc(p);
    80001cc6:	8526                	mv	a0,s1
    80001cc8:	00000097          	auipc	ra,0x0
    80001ccc:	efe080e7          	jalr	-258(ra) # 80001bc6 <freeproc>
    release(&p->lock);
    80001cd0:	8526                	mv	a0,s1
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	02a080e7          	jalr	42(ra) # 80000cfc <release>
    return 0;
    80001cda:	84ca                	mv	s1,s2
    80001cdc:	b7f9                	j	80001caa <allocproc+0x8c>

0000000080001cde <userinit>:
{
    80001cde:	1101                	addi	sp,sp,-32
    80001ce0:	ec06                	sd	ra,24(sp)
    80001ce2:	e822                	sd	s0,16(sp)
    80001ce4:	e426                	sd	s1,8(sp)
    80001ce6:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ce8:	00000097          	auipc	ra,0x0
    80001cec:	f36080e7          	jalr	-202(ra) # 80001c1e <allocproc>
    80001cf0:	84aa                	mv	s1,a0
  initproc = p;
    80001cf2:	00007797          	auipc	a5,0x7
    80001cf6:	32a7b323          	sd	a0,806(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cfa:	03400613          	li	a2,52
    80001cfe:	00007597          	auipc	a1,0x7
    80001d02:	b5258593          	addi	a1,a1,-1198 # 80008850 <initcode>
    80001d06:	6928                	ld	a0,80(a0)
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	6f4080e7          	jalr	1780(ra) # 800013fc <uvminit>
  p->sz = PGSIZE;
    80001d10:	6785                	lui	a5,0x1
    80001d12:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d14:	6cb8                	ld	a4,88(s1)
    80001d16:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d1a:	6cb8                	ld	a4,88(s1)
    80001d1c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d1e:	4641                	li	a2,16
    80001d20:	00006597          	auipc	a1,0x6
    80001d24:	4c858593          	addi	a1,a1,1224 # 800081e8 <digits+0x1a8>
    80001d28:	15848513          	addi	a0,s1,344
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	16a080e7          	jalr	362(ra) # 80000e96 <safestrcpy>
  p->cwd = namei("/");
    80001d34:	00006517          	auipc	a0,0x6
    80001d38:	4c450513          	addi	a0,a0,1220 # 800081f8 <digits+0x1b8>
    80001d3c:	00002097          	auipc	ra,0x2
    80001d40:	1b6080e7          	jalr	438(ra) # 80003ef2 <namei>
    80001d44:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d48:	4789                	li	a5,2
    80001d4a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d4c:	8526                	mv	a0,s1
    80001d4e:	fffff097          	auipc	ra,0xfffff
    80001d52:	fae080e7          	jalr	-82(ra) # 80000cfc <release>
}
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	64a2                	ld	s1,8(sp)
    80001d5c:	6105                	addi	sp,sp,32
    80001d5e:	8082                	ret

0000000080001d60 <growproc>:
{
    80001d60:	1101                	addi	sp,sp,-32
    80001d62:	ec06                	sd	ra,24(sp)
    80001d64:	e822                	sd	s0,16(sp)
    80001d66:	e426                	sd	s1,8(sp)
    80001d68:	e04a                	sd	s2,0(sp)
    80001d6a:	1000                	addi	s0,sp,32
    80001d6c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d6e:	00000097          	auipc	ra,0x0
    80001d72:	ca6080e7          	jalr	-858(ra) # 80001a14 <myproc>
    80001d76:	892a                	mv	s2,a0
  sz = p->sz;
    80001d78:	652c                	ld	a1,72(a0)
    80001d7a:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d7e:	00904f63          	bgtz	s1,80001d9c <growproc+0x3c>
  } else if(n < 0){
    80001d82:	0204cc63          	bltz	s1,80001dba <growproc+0x5a>
  p->sz = sz;
    80001d86:	1602                	slli	a2,a2,0x20
    80001d88:	9201                	srli	a2,a2,0x20
    80001d8a:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d8e:	4501                	li	a0,0
}
    80001d90:	60e2                	ld	ra,24(sp)
    80001d92:	6442                	ld	s0,16(sp)
    80001d94:	64a2                	ld	s1,8(sp)
    80001d96:	6902                	ld	s2,0(sp)
    80001d98:	6105                	addi	sp,sp,32
    80001d9a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d9c:	9e25                	addw	a2,a2,s1
    80001d9e:	1602                	slli	a2,a2,0x20
    80001da0:	9201                	srli	a2,a2,0x20
    80001da2:	1582                	slli	a1,a1,0x20
    80001da4:	9181                	srli	a1,a1,0x20
    80001da6:	6928                	ld	a0,80(a0)
    80001da8:	fffff097          	auipc	ra,0xfffff
    80001dac:	70e080e7          	jalr	1806(ra) # 800014b6 <uvmalloc>
    80001db0:	0005061b          	sext.w	a2,a0
    80001db4:	fa69                	bnez	a2,80001d86 <growproc+0x26>
      return -1;
    80001db6:	557d                	li	a0,-1
    80001db8:	bfe1                	j	80001d90 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dba:	9e25                	addw	a2,a2,s1
    80001dbc:	1602                	slli	a2,a2,0x20
    80001dbe:	9201                	srli	a2,a2,0x20
    80001dc0:	1582                	slli	a1,a1,0x20
    80001dc2:	9181                	srli	a1,a1,0x20
    80001dc4:	6928                	ld	a0,80(a0)
    80001dc6:	fffff097          	auipc	ra,0xfffff
    80001dca:	6a8080e7          	jalr	1704(ra) # 8000146e <uvmdealloc>
    80001dce:	0005061b          	sext.w	a2,a0
    80001dd2:	bf55                	j	80001d86 <growproc+0x26>

0000000080001dd4 <fork>:
{
    80001dd4:	7139                	addi	sp,sp,-64
    80001dd6:	fc06                	sd	ra,56(sp)
    80001dd8:	f822                	sd	s0,48(sp)
    80001dda:	f426                	sd	s1,40(sp)
    80001ddc:	f04a                	sd	s2,32(sp)
    80001dde:	ec4e                	sd	s3,24(sp)
    80001de0:	e852                	sd	s4,16(sp)
    80001de2:	e456                	sd	s5,8(sp)
    80001de4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001de6:	00000097          	auipc	ra,0x0
    80001dea:	c2e080e7          	jalr	-978(ra) # 80001a14 <myproc>
    80001dee:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001df0:	00000097          	auipc	ra,0x0
    80001df4:	e2e080e7          	jalr	-466(ra) # 80001c1e <allocproc>
    80001df8:	c57d                	beqz	a0,80001ee6 <fork+0x112>
    80001dfa:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dfc:	048ab603          	ld	a2,72(s5)
    80001e00:	692c                	ld	a1,80(a0)
    80001e02:	050ab503          	ld	a0,80(s5)
    80001e06:	fffff097          	auipc	ra,0xfffff
    80001e0a:	7fc080e7          	jalr	2044(ra) # 80001602 <uvmcopy>
    80001e0e:	04054e63          	bltz	a0,80001e6a <fork+0x96>
  np->sz = p->sz;
    80001e12:	048ab783          	ld	a5,72(s5)
    80001e16:	04fa3423          	sd	a5,72(s4) # 800179b0 <bcache+0x30>
  np->tmask = p->tmask;
    80001e1a:	168aa783          	lw	a5,360(s5)
    80001e1e:	16fa2423          	sw	a5,360(s4)
  np->parent = p;
    80001e22:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e26:	058ab683          	ld	a3,88(s5)
    80001e2a:	87b6                	mv	a5,a3
    80001e2c:	058a3703          	ld	a4,88(s4)
    80001e30:	12068693          	addi	a3,a3,288
    80001e34:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e38:	6788                	ld	a0,8(a5)
    80001e3a:	6b8c                	ld	a1,16(a5)
    80001e3c:	6f90                	ld	a2,24(a5)
    80001e3e:	01073023          	sd	a6,0(a4)
    80001e42:	e708                	sd	a0,8(a4)
    80001e44:	eb0c                	sd	a1,16(a4)
    80001e46:	ef10                	sd	a2,24(a4)
    80001e48:	02078793          	addi	a5,a5,32
    80001e4c:	02070713          	addi	a4,a4,32
    80001e50:	fed792e3          	bne	a5,a3,80001e34 <fork+0x60>
  np->trapframe->a0 = 0;
    80001e54:	058a3783          	ld	a5,88(s4)
    80001e58:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e5c:	0d0a8493          	addi	s1,s5,208
    80001e60:	0d0a0913          	addi	s2,s4,208
    80001e64:	150a8993          	addi	s3,s5,336
    80001e68:	a00d                	j	80001e8a <fork+0xb6>
    freeproc(np);
    80001e6a:	8552                	mv	a0,s4
    80001e6c:	00000097          	auipc	ra,0x0
    80001e70:	d5a080e7          	jalr	-678(ra) # 80001bc6 <freeproc>
    release(&np->lock);
    80001e74:	8552                	mv	a0,s4
    80001e76:	fffff097          	auipc	ra,0xfffff
    80001e7a:	e86080e7          	jalr	-378(ra) # 80000cfc <release>
    return -1;
    80001e7e:	54fd                	li	s1,-1
    80001e80:	a889                	j	80001ed2 <fork+0xfe>
  for(i = 0; i < NOFILE; i++)
    80001e82:	04a1                	addi	s1,s1,8
    80001e84:	0921                	addi	s2,s2,8
    80001e86:	01348b63          	beq	s1,s3,80001e9c <fork+0xc8>
    if(p->ofile[i])
    80001e8a:	6088                	ld	a0,0(s1)
    80001e8c:	d97d                	beqz	a0,80001e82 <fork+0xae>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e8e:	00002097          	auipc	ra,0x2
    80001e92:	6f0080e7          	jalr	1776(ra) # 8000457e <filedup>
    80001e96:	00a93023          	sd	a0,0(s2)
    80001e9a:	b7e5                	j	80001e82 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001e9c:	150ab503          	ld	a0,336(s5)
    80001ea0:	00002097          	auipc	ra,0x2
    80001ea4:	864080e7          	jalr	-1948(ra) # 80003704 <idup>
    80001ea8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eac:	4641                	li	a2,16
    80001eae:	158a8593          	addi	a1,s5,344
    80001eb2:	158a0513          	addi	a0,s4,344
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	fe0080e7          	jalr	-32(ra) # 80000e96 <safestrcpy>
  pid = np->pid;
    80001ebe:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001ec2:	4789                	li	a5,2
    80001ec4:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001ec8:	8552                	mv	a0,s4
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	e32080e7          	jalr	-462(ra) # 80000cfc <release>
}
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	70e2                	ld	ra,56(sp)
    80001ed6:	7442                	ld	s0,48(sp)
    80001ed8:	74a2                	ld	s1,40(sp)
    80001eda:	7902                	ld	s2,32(sp)
    80001edc:	69e2                	ld	s3,24(sp)
    80001ede:	6a42                	ld	s4,16(sp)
    80001ee0:	6aa2                	ld	s5,8(sp)
    80001ee2:	6121                	addi	sp,sp,64
    80001ee4:	8082                	ret
    return -1;
    80001ee6:	54fd                	li	s1,-1
    80001ee8:	b7ed                	j	80001ed2 <fork+0xfe>

0000000080001eea <reparent>:
{
    80001eea:	7179                	addi	sp,sp,-48
    80001eec:	f406                	sd	ra,40(sp)
    80001eee:	f022                	sd	s0,32(sp)
    80001ef0:	ec26                	sd	s1,24(sp)
    80001ef2:	e84a                	sd	s2,16(sp)
    80001ef4:	e44e                	sd	s3,8(sp)
    80001ef6:	e052                	sd	s4,0(sp)
    80001ef8:	1800                	addi	s0,sp,48
    80001efa:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001efc:	00010497          	auipc	s1,0x10
    80001f00:	e6c48493          	addi	s1,s1,-404 # 80011d68 <proc>
      pp->parent = initproc;
    80001f04:	00007a17          	auipc	s4,0x7
    80001f08:	114a0a13          	addi	s4,s4,276 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f0c:	00016997          	auipc	s3,0x16
    80001f10:	a5c98993          	addi	s3,s3,-1444 # 80017968 <tickslock>
    80001f14:	a029                	j	80001f1e <reparent+0x34>
    80001f16:	17048493          	addi	s1,s1,368
    80001f1a:	03348363          	beq	s1,s3,80001f40 <reparent+0x56>
    if(pp->parent == p){
    80001f1e:	709c                	ld	a5,32(s1)
    80001f20:	ff279be3          	bne	a5,s2,80001f16 <reparent+0x2c>
      acquire(&pp->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	d22080e7          	jalr	-734(ra) # 80000c48 <acquire>
      pp->parent = initproc;
    80001f2e:	000a3783          	ld	a5,0(s4)
    80001f32:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f34:	8526                	mv	a0,s1
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	dc6080e7          	jalr	-570(ra) # 80000cfc <release>
    80001f3e:	bfe1                	j	80001f16 <reparent+0x2c>
}
    80001f40:	70a2                	ld	ra,40(sp)
    80001f42:	7402                	ld	s0,32(sp)
    80001f44:	64e2                	ld	s1,24(sp)
    80001f46:	6942                	ld	s2,16(sp)
    80001f48:	69a2                	ld	s3,8(sp)
    80001f4a:	6a02                	ld	s4,0(sp)
    80001f4c:	6145                	addi	sp,sp,48
    80001f4e:	8082                	ret

0000000080001f50 <scheduler>:
{
    80001f50:	715d                	addi	sp,sp,-80
    80001f52:	e486                	sd	ra,72(sp)
    80001f54:	e0a2                	sd	s0,64(sp)
    80001f56:	fc26                	sd	s1,56(sp)
    80001f58:	f84a                	sd	s2,48(sp)
    80001f5a:	f44e                	sd	s3,40(sp)
    80001f5c:	f052                	sd	s4,32(sp)
    80001f5e:	ec56                	sd	s5,24(sp)
    80001f60:	e85a                	sd	s6,16(sp)
    80001f62:	e45e                	sd	s7,8(sp)
    80001f64:	e062                	sd	s8,0(sp)
    80001f66:	0880                	addi	s0,sp,80
    80001f68:	8792                	mv	a5,tp
  int id = r_tp();
    80001f6a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f6c:	00779b13          	slli	s6,a5,0x7
    80001f70:	00010717          	auipc	a4,0x10
    80001f74:	9e070713          	addi	a4,a4,-1568 # 80011950 <pid_lock>
    80001f78:	975a                	add	a4,a4,s6
    80001f7a:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001f7e:	00010717          	auipc	a4,0x10
    80001f82:	9f270713          	addi	a4,a4,-1550 # 80011970 <cpus+0x8>
    80001f86:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f88:	4c0d                	li	s8,3
        c->proc = p;
    80001f8a:	079e                	slli	a5,a5,0x7
    80001f8c:	00010a17          	auipc	s4,0x10
    80001f90:	9c4a0a13          	addi	s4,s4,-1596 # 80011950 <pid_lock>
    80001f94:	9a3e                	add	s4,s4,a5
        found = 1;
    80001f96:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f98:	00016997          	auipc	s3,0x16
    80001f9c:	9d098993          	addi	s3,s3,-1584 # 80017968 <tickslock>
    80001fa0:	a899                	j	80001ff6 <scheduler+0xa6>
      release(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	d58080e7          	jalr	-680(ra) # 80000cfc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fac:	17048493          	addi	s1,s1,368
    80001fb0:	03348963          	beq	s1,s3,80001fe2 <scheduler+0x92>
      acquire(&p->lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	c92080e7          	jalr	-878(ra) # 80000c48 <acquire>
      if(p->state == RUNNABLE) {
    80001fbe:	4c9c                	lw	a5,24(s1)
    80001fc0:	ff2791e3          	bne	a5,s2,80001fa2 <scheduler+0x52>
        p->state = RUNNING;
    80001fc4:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001fc8:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80001fcc:	06048593          	addi	a1,s1,96
    80001fd0:	855a                	mv	a0,s6
    80001fd2:	00000097          	auipc	ra,0x0
    80001fd6:	63e080e7          	jalr	1598(ra) # 80002610 <swtch>
        c->proc = 0;
    80001fda:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001fde:	8ade                	mv	s5,s7
    80001fe0:	b7c9                	j	80001fa2 <scheduler+0x52>
    if(found == 0) {
    80001fe2:	000a9a63          	bnez	s5,80001ff6 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fe6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fee:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001ff2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ff6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ffa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ffe:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002002:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002004:	00010497          	auipc	s1,0x10
    80002008:	d6448493          	addi	s1,s1,-668 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    8000200c:	4909                	li	s2,2
    8000200e:	b75d                	j	80001fb4 <scheduler+0x64>

0000000080002010 <sched>:
{
    80002010:	7179                	addi	sp,sp,-48
    80002012:	f406                	sd	ra,40(sp)
    80002014:	f022                	sd	s0,32(sp)
    80002016:	ec26                	sd	s1,24(sp)
    80002018:	e84a                	sd	s2,16(sp)
    8000201a:	e44e                	sd	s3,8(sp)
    8000201c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	9f6080e7          	jalr	-1546(ra) # 80001a14 <myproc>
    80002026:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	ba6080e7          	jalr	-1114(ra) # 80000bce <holding>
    80002030:	c93d                	beqz	a0,800020a6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002032:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002034:	2781                	sext.w	a5,a5
    80002036:	079e                	slli	a5,a5,0x7
    80002038:	00010717          	auipc	a4,0x10
    8000203c:	91870713          	addi	a4,a4,-1768 # 80011950 <pid_lock>
    80002040:	97ba                	add	a5,a5,a4
    80002042:	0907a703          	lw	a4,144(a5)
    80002046:	4785                	li	a5,1
    80002048:	06f71763          	bne	a4,a5,800020b6 <sched+0xa6>
  if(p->state == RUNNING)
    8000204c:	4c98                	lw	a4,24(s1)
    8000204e:	478d                	li	a5,3
    80002050:	06f70b63          	beq	a4,a5,800020c6 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002054:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002058:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000205a:	efb5                	bnez	a5,800020d6 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000205c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000205e:	00010917          	auipc	s2,0x10
    80002062:	8f290913          	addi	s2,s2,-1806 # 80011950 <pid_lock>
    80002066:	2781                	sext.w	a5,a5
    80002068:	079e                	slli	a5,a5,0x7
    8000206a:	97ca                	add	a5,a5,s2
    8000206c:	0947a983          	lw	s3,148(a5)
    80002070:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002072:	2781                	sext.w	a5,a5
    80002074:	079e                	slli	a5,a5,0x7
    80002076:	00010597          	auipc	a1,0x10
    8000207a:	8fa58593          	addi	a1,a1,-1798 # 80011970 <cpus+0x8>
    8000207e:	95be                	add	a1,a1,a5
    80002080:	06048513          	addi	a0,s1,96
    80002084:	00000097          	auipc	ra,0x0
    80002088:	58c080e7          	jalr	1420(ra) # 80002610 <swtch>
    8000208c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000208e:	2781                	sext.w	a5,a5
    80002090:	079e                	slli	a5,a5,0x7
    80002092:	97ca                	add	a5,a5,s2
    80002094:	0937aa23          	sw	s3,148(a5)
}
    80002098:	70a2                	ld	ra,40(sp)
    8000209a:	7402                	ld	s0,32(sp)
    8000209c:	64e2                	ld	s1,24(sp)
    8000209e:	6942                	ld	s2,16(sp)
    800020a0:	69a2                	ld	s3,8(sp)
    800020a2:	6145                	addi	sp,sp,48
    800020a4:	8082                	ret
    panic("sched p->lock");
    800020a6:	00006517          	auipc	a0,0x6
    800020aa:	15a50513          	addi	a0,a0,346 # 80008200 <digits+0x1c0>
    800020ae:	ffffe097          	auipc	ra,0xffffe
    800020b2:	494080e7          	jalr	1172(ra) # 80000542 <panic>
    panic("sched locks");
    800020b6:	00006517          	auipc	a0,0x6
    800020ba:	15a50513          	addi	a0,a0,346 # 80008210 <digits+0x1d0>
    800020be:	ffffe097          	auipc	ra,0xffffe
    800020c2:	484080e7          	jalr	1156(ra) # 80000542 <panic>
    panic("sched running");
    800020c6:	00006517          	auipc	a0,0x6
    800020ca:	15a50513          	addi	a0,a0,346 # 80008220 <digits+0x1e0>
    800020ce:	ffffe097          	auipc	ra,0xffffe
    800020d2:	474080e7          	jalr	1140(ra) # 80000542 <panic>
    panic("sched interruptible");
    800020d6:	00006517          	auipc	a0,0x6
    800020da:	15a50513          	addi	a0,a0,346 # 80008230 <digits+0x1f0>
    800020de:	ffffe097          	auipc	ra,0xffffe
    800020e2:	464080e7          	jalr	1124(ra) # 80000542 <panic>

00000000800020e6 <exit>:
{
    800020e6:	7179                	addi	sp,sp,-48
    800020e8:	f406                	sd	ra,40(sp)
    800020ea:	f022                	sd	s0,32(sp)
    800020ec:	ec26                	sd	s1,24(sp)
    800020ee:	e84a                	sd	s2,16(sp)
    800020f0:	e44e                	sd	s3,8(sp)
    800020f2:	e052                	sd	s4,0(sp)
    800020f4:	1800                	addi	s0,sp,48
    800020f6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020f8:	00000097          	auipc	ra,0x0
    800020fc:	91c080e7          	jalr	-1764(ra) # 80001a14 <myproc>
    80002100:	89aa                	mv	s3,a0
  if(p == initproc)
    80002102:	00007797          	auipc	a5,0x7
    80002106:	f167b783          	ld	a5,-234(a5) # 80009018 <initproc>
    8000210a:	0d050493          	addi	s1,a0,208
    8000210e:	15050913          	addi	s2,a0,336
    80002112:	02a79363          	bne	a5,a0,80002138 <exit+0x52>
    panic("init exiting");
    80002116:	00006517          	auipc	a0,0x6
    8000211a:	13250513          	addi	a0,a0,306 # 80008248 <digits+0x208>
    8000211e:	ffffe097          	auipc	ra,0xffffe
    80002122:	424080e7          	jalr	1060(ra) # 80000542 <panic>
      fileclose(f);
    80002126:	00002097          	auipc	ra,0x2
    8000212a:	4aa080e7          	jalr	1194(ra) # 800045d0 <fileclose>
      p->ofile[fd] = 0;
    8000212e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002132:	04a1                	addi	s1,s1,8
    80002134:	01248563          	beq	s1,s2,8000213e <exit+0x58>
    if(p->ofile[fd]){
    80002138:	6088                	ld	a0,0(s1)
    8000213a:	f575                	bnez	a0,80002126 <exit+0x40>
    8000213c:	bfdd                	j	80002132 <exit+0x4c>
  begin_op();
    8000213e:	00002097          	auipc	ra,0x2
    80002142:	fc0080e7          	jalr	-64(ra) # 800040fe <begin_op>
  iput(p->cwd);
    80002146:	1509b503          	ld	a0,336(s3)
    8000214a:	00001097          	auipc	ra,0x1
    8000214e:	7b2080e7          	jalr	1970(ra) # 800038fc <iput>
  end_op();
    80002152:	00002097          	auipc	ra,0x2
    80002156:	02c080e7          	jalr	44(ra) # 8000417e <end_op>
  p->cwd = 0;
    8000215a:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000215e:	00007497          	auipc	s1,0x7
    80002162:	eba48493          	addi	s1,s1,-326 # 80009018 <initproc>
    80002166:	6088                	ld	a0,0(s1)
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	ae0080e7          	jalr	-1312(ra) # 80000c48 <acquire>
  wakeup1(initproc);
    80002170:	6088                	ld	a0,0(s1)
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	762080e7          	jalr	1890(ra) # 800018d4 <wakeup1>
  release(&initproc->lock);
    8000217a:	6088                	ld	a0,0(s1)
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	b80080e7          	jalr	-1152(ra) # 80000cfc <release>
  acquire(&p->lock);
    80002184:	854e                	mv	a0,s3
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	ac2080e7          	jalr	-1342(ra) # 80000c48 <acquire>
  struct proc *original_parent = p->parent;
    8000218e:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002192:	854e                	mv	a0,s3
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	b68080e7          	jalr	-1176(ra) # 80000cfc <release>
  acquire(&original_parent->lock);
    8000219c:	8526                	mv	a0,s1
    8000219e:	fffff097          	auipc	ra,0xfffff
    800021a2:	aaa080e7          	jalr	-1366(ra) # 80000c48 <acquire>
  acquire(&p->lock);
    800021a6:	854e                	mv	a0,s3
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	aa0080e7          	jalr	-1376(ra) # 80000c48 <acquire>
  reparent(p);
    800021b0:	854e                	mv	a0,s3
    800021b2:	00000097          	auipc	ra,0x0
    800021b6:	d38080e7          	jalr	-712(ra) # 80001eea <reparent>
  wakeup1(original_parent);
    800021ba:	8526                	mv	a0,s1
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	718080e7          	jalr	1816(ra) # 800018d4 <wakeup1>
  p->xstate = status;
    800021c4:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800021c8:	4791                	li	a5,4
    800021ca:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	b2c080e7          	jalr	-1236(ra) # 80000cfc <release>
  sched();
    800021d8:	00000097          	auipc	ra,0x0
    800021dc:	e38080e7          	jalr	-456(ra) # 80002010 <sched>
  panic("zombie exit");
    800021e0:	00006517          	auipc	a0,0x6
    800021e4:	07850513          	addi	a0,a0,120 # 80008258 <digits+0x218>
    800021e8:	ffffe097          	auipc	ra,0xffffe
    800021ec:	35a080e7          	jalr	858(ra) # 80000542 <panic>

00000000800021f0 <yield>:
{
    800021f0:	1101                	addi	sp,sp,-32
    800021f2:	ec06                	sd	ra,24(sp)
    800021f4:	e822                	sd	s0,16(sp)
    800021f6:	e426                	sd	s1,8(sp)
    800021f8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021fa:	00000097          	auipc	ra,0x0
    800021fe:	81a080e7          	jalr	-2022(ra) # 80001a14 <myproc>
    80002202:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	a44080e7          	jalr	-1468(ra) # 80000c48 <acquire>
  p->state = RUNNABLE;
    8000220c:	4789                	li	a5,2
    8000220e:	cc9c                	sw	a5,24(s1)
  sched();
    80002210:	00000097          	auipc	ra,0x0
    80002214:	e00080e7          	jalr	-512(ra) # 80002010 <sched>
  release(&p->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	ae2080e7          	jalr	-1310(ra) # 80000cfc <release>
}
    80002222:	60e2                	ld	ra,24(sp)
    80002224:	6442                	ld	s0,16(sp)
    80002226:	64a2                	ld	s1,8(sp)
    80002228:	6105                	addi	sp,sp,32
    8000222a:	8082                	ret

000000008000222c <sleep>:
{
    8000222c:	7179                	addi	sp,sp,-48
    8000222e:	f406                	sd	ra,40(sp)
    80002230:	f022                	sd	s0,32(sp)
    80002232:	ec26                	sd	s1,24(sp)
    80002234:	e84a                	sd	s2,16(sp)
    80002236:	e44e                	sd	s3,8(sp)
    80002238:	1800                	addi	s0,sp,48
    8000223a:	89aa                	mv	s3,a0
    8000223c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	7d6080e7          	jalr	2006(ra) # 80001a14 <myproc>
    80002246:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002248:	05250663          	beq	a0,s2,80002294 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	9fc080e7          	jalr	-1540(ra) # 80000c48 <acquire>
    release(lk);
    80002254:	854a                	mv	a0,s2
    80002256:	fffff097          	auipc	ra,0xfffff
    8000225a:	aa6080e7          	jalr	-1370(ra) # 80000cfc <release>
  p->chan = chan;
    8000225e:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002262:	4785                	li	a5,1
    80002264:	cc9c                	sw	a5,24(s1)
  sched();
    80002266:	00000097          	auipc	ra,0x0
    8000226a:	daa080e7          	jalr	-598(ra) # 80002010 <sched>
  p->chan = 0;
    8000226e:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002272:	8526                	mv	a0,s1
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	a88080e7          	jalr	-1400(ra) # 80000cfc <release>
    acquire(lk);
    8000227c:	854a                	mv	a0,s2
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	9ca080e7          	jalr	-1590(ra) # 80000c48 <acquire>
}
    80002286:	70a2                	ld	ra,40(sp)
    80002288:	7402                	ld	s0,32(sp)
    8000228a:	64e2                	ld	s1,24(sp)
    8000228c:	6942                	ld	s2,16(sp)
    8000228e:	69a2                	ld	s3,8(sp)
    80002290:	6145                	addi	sp,sp,48
    80002292:	8082                	ret
  p->chan = chan;
    80002294:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002298:	4785                	li	a5,1
    8000229a:	cd1c                	sw	a5,24(a0)
  sched();
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	d74080e7          	jalr	-652(ra) # 80002010 <sched>
  p->chan = 0;
    800022a4:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022a8:	bff9                	j	80002286 <sleep+0x5a>

00000000800022aa <wait>:
{
    800022aa:	715d                	addi	sp,sp,-80
    800022ac:	e486                	sd	ra,72(sp)
    800022ae:	e0a2                	sd	s0,64(sp)
    800022b0:	fc26                	sd	s1,56(sp)
    800022b2:	f84a                	sd	s2,48(sp)
    800022b4:	f44e                	sd	s3,40(sp)
    800022b6:	f052                	sd	s4,32(sp)
    800022b8:	ec56                	sd	s5,24(sp)
    800022ba:	e85a                	sd	s6,16(sp)
    800022bc:	e45e                	sd	s7,8(sp)
    800022be:	0880                	addi	s0,sp,80
    800022c0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	752080e7          	jalr	1874(ra) # 80001a14 <myproc>
    800022ca:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	97c080e7          	jalr	-1668(ra) # 80000c48 <acquire>
    havekids = 0;
    800022d4:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022d6:	4a11                	li	s4,4
        havekids = 1;
    800022d8:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800022da:	00015997          	auipc	s3,0x15
    800022de:	68e98993          	addi	s3,s3,1678 # 80017968 <tickslock>
    havekids = 0;
    800022e2:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022e4:	00010497          	auipc	s1,0x10
    800022e8:	a8448493          	addi	s1,s1,-1404 # 80011d68 <proc>
    800022ec:	a08d                	j	8000234e <wait+0xa4>
          pid = np->pid;
    800022ee:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022f2:	000b0e63          	beqz	s6,8000230e <wait+0x64>
    800022f6:	4691                	li	a3,4
    800022f8:	03448613          	addi	a2,s1,52
    800022fc:	85da                	mv	a1,s6
    800022fe:	05093503          	ld	a0,80(s2)
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	404080e7          	jalr	1028(ra) # 80001706 <copyout>
    8000230a:	02054263          	bltz	a0,8000232e <wait+0x84>
          freeproc(np);
    8000230e:	8526                	mv	a0,s1
    80002310:	00000097          	auipc	ra,0x0
    80002314:	8b6080e7          	jalr	-1866(ra) # 80001bc6 <freeproc>
          release(&np->lock);
    80002318:	8526                	mv	a0,s1
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	9e2080e7          	jalr	-1566(ra) # 80000cfc <release>
          release(&p->lock);
    80002322:	854a                	mv	a0,s2
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	9d8080e7          	jalr	-1576(ra) # 80000cfc <release>
          return pid;
    8000232c:	a8a9                	j	80002386 <wait+0xdc>
            release(&np->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	9cc080e7          	jalr	-1588(ra) # 80000cfc <release>
            release(&p->lock);
    80002338:	854a                	mv	a0,s2
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	9c2080e7          	jalr	-1598(ra) # 80000cfc <release>
            return -1;
    80002342:	59fd                	li	s3,-1
    80002344:	a089                	j	80002386 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002346:	17048493          	addi	s1,s1,368
    8000234a:	03348463          	beq	s1,s3,80002372 <wait+0xc8>
      if(np->parent == p){
    8000234e:	709c                	ld	a5,32(s1)
    80002350:	ff279be3          	bne	a5,s2,80002346 <wait+0x9c>
        acquire(&np->lock);
    80002354:	8526                	mv	a0,s1
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	8f2080e7          	jalr	-1806(ra) # 80000c48 <acquire>
        if(np->state == ZOMBIE){
    8000235e:	4c9c                	lw	a5,24(s1)
    80002360:	f94787e3          	beq	a5,s4,800022ee <wait+0x44>
        release(&np->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	996080e7          	jalr	-1642(ra) # 80000cfc <release>
        havekids = 1;
    8000236e:	8756                	mv	a4,s5
    80002370:	bfd9                	j	80002346 <wait+0x9c>
    if(!havekids || p->killed){
    80002372:	c701                	beqz	a4,8000237a <wait+0xd0>
    80002374:	03092783          	lw	a5,48(s2)
    80002378:	c39d                	beqz	a5,8000239e <wait+0xf4>
      release(&p->lock);
    8000237a:	854a                	mv	a0,s2
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	980080e7          	jalr	-1664(ra) # 80000cfc <release>
      return -1;
    80002384:	59fd                	li	s3,-1
}
    80002386:	854e                	mv	a0,s3
    80002388:	60a6                	ld	ra,72(sp)
    8000238a:	6406                	ld	s0,64(sp)
    8000238c:	74e2                	ld	s1,56(sp)
    8000238e:	7942                	ld	s2,48(sp)
    80002390:	79a2                	ld	s3,40(sp)
    80002392:	7a02                	ld	s4,32(sp)
    80002394:	6ae2                	ld	s5,24(sp)
    80002396:	6b42                	ld	s6,16(sp)
    80002398:	6ba2                	ld	s7,8(sp)
    8000239a:	6161                	addi	sp,sp,80
    8000239c:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000239e:	85ca                	mv	a1,s2
    800023a0:	854a                	mv	a0,s2
    800023a2:	00000097          	auipc	ra,0x0
    800023a6:	e8a080e7          	jalr	-374(ra) # 8000222c <sleep>
    havekids = 0;
    800023aa:	bf25                	j	800022e2 <wait+0x38>

00000000800023ac <wakeup>:
{
    800023ac:	7139                	addi	sp,sp,-64
    800023ae:	fc06                	sd	ra,56(sp)
    800023b0:	f822                	sd	s0,48(sp)
    800023b2:	f426                	sd	s1,40(sp)
    800023b4:	f04a                	sd	s2,32(sp)
    800023b6:	ec4e                	sd	s3,24(sp)
    800023b8:	e852                	sd	s4,16(sp)
    800023ba:	e456                	sd	s5,8(sp)
    800023bc:	0080                	addi	s0,sp,64
    800023be:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023c0:	00010497          	auipc	s1,0x10
    800023c4:	9a848493          	addi	s1,s1,-1624 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023c8:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023ca:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023cc:	00015917          	auipc	s2,0x15
    800023d0:	59c90913          	addi	s2,s2,1436 # 80017968 <tickslock>
    800023d4:	a811                	j	800023e8 <wakeup+0x3c>
    release(&p->lock);
    800023d6:	8526                	mv	a0,s1
    800023d8:	fffff097          	auipc	ra,0xfffff
    800023dc:	924080e7          	jalr	-1756(ra) # 80000cfc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023e0:	17048493          	addi	s1,s1,368
    800023e4:	03248063          	beq	s1,s2,80002404 <wakeup+0x58>
    acquire(&p->lock);
    800023e8:	8526                	mv	a0,s1
    800023ea:	fffff097          	auipc	ra,0xfffff
    800023ee:	85e080e7          	jalr	-1954(ra) # 80000c48 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800023f2:	4c9c                	lw	a5,24(s1)
    800023f4:	ff3791e3          	bne	a5,s3,800023d6 <wakeup+0x2a>
    800023f8:	749c                	ld	a5,40(s1)
    800023fa:	fd479ee3          	bne	a5,s4,800023d6 <wakeup+0x2a>
      p->state = RUNNABLE;
    800023fe:	0154ac23          	sw	s5,24(s1)
    80002402:	bfd1                	j	800023d6 <wakeup+0x2a>
}
    80002404:	70e2                	ld	ra,56(sp)
    80002406:	7442                	ld	s0,48(sp)
    80002408:	74a2                	ld	s1,40(sp)
    8000240a:	7902                	ld	s2,32(sp)
    8000240c:	69e2                	ld	s3,24(sp)
    8000240e:	6a42                	ld	s4,16(sp)
    80002410:	6aa2                	ld	s5,8(sp)
    80002412:	6121                	addi	sp,sp,64
    80002414:	8082                	ret

0000000080002416 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002416:	7179                	addi	sp,sp,-48
    80002418:	f406                	sd	ra,40(sp)
    8000241a:	f022                	sd	s0,32(sp)
    8000241c:	ec26                	sd	s1,24(sp)
    8000241e:	e84a                	sd	s2,16(sp)
    80002420:	e44e                	sd	s3,8(sp)
    80002422:	1800                	addi	s0,sp,48
    80002424:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002426:	00010497          	auipc	s1,0x10
    8000242a:	94248493          	addi	s1,s1,-1726 # 80011d68 <proc>
    8000242e:	00015997          	auipc	s3,0x15
    80002432:	53a98993          	addi	s3,s3,1338 # 80017968 <tickslock>
    acquire(&p->lock);
    80002436:	8526                	mv	a0,s1
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	810080e7          	jalr	-2032(ra) # 80000c48 <acquire>
    if(p->pid == pid){
    80002440:	5c9c                	lw	a5,56(s1)
    80002442:	01278d63          	beq	a5,s2,8000245c <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002446:	8526                	mv	a0,s1
    80002448:	fffff097          	auipc	ra,0xfffff
    8000244c:	8b4080e7          	jalr	-1868(ra) # 80000cfc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002450:	17048493          	addi	s1,s1,368
    80002454:	ff3491e3          	bne	s1,s3,80002436 <kill+0x20>
  }
  return -1;
    80002458:	557d                	li	a0,-1
    8000245a:	a821                	j	80002472 <kill+0x5c>
      p->killed = 1;
    8000245c:	4785                	li	a5,1
    8000245e:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002460:	4c98                	lw	a4,24(s1)
    80002462:	00f70f63          	beq	a4,a5,80002480 <kill+0x6a>
      release(&p->lock);
    80002466:	8526                	mv	a0,s1
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	894080e7          	jalr	-1900(ra) # 80000cfc <release>
      return 0;
    80002470:	4501                	li	a0,0
}
    80002472:	70a2                	ld	ra,40(sp)
    80002474:	7402                	ld	s0,32(sp)
    80002476:	64e2                	ld	s1,24(sp)
    80002478:	6942                	ld	s2,16(sp)
    8000247a:	69a2                	ld	s3,8(sp)
    8000247c:	6145                	addi	sp,sp,48
    8000247e:	8082                	ret
        p->state = RUNNABLE;
    80002480:	4789                	li	a5,2
    80002482:	cc9c                	sw	a5,24(s1)
    80002484:	b7cd                	j	80002466 <kill+0x50>

0000000080002486 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002486:	7179                	addi	sp,sp,-48
    80002488:	f406                	sd	ra,40(sp)
    8000248a:	f022                	sd	s0,32(sp)
    8000248c:	ec26                	sd	s1,24(sp)
    8000248e:	e84a                	sd	s2,16(sp)
    80002490:	e44e                	sd	s3,8(sp)
    80002492:	e052                	sd	s4,0(sp)
    80002494:	1800                	addi	s0,sp,48
    80002496:	84aa                	mv	s1,a0
    80002498:	892e                	mv	s2,a1
    8000249a:	89b2                	mv	s3,a2
    8000249c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000249e:	fffff097          	auipc	ra,0xfffff
    800024a2:	576080e7          	jalr	1398(ra) # 80001a14 <myproc>
  if(user_dst){
    800024a6:	c08d                	beqz	s1,800024c8 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024a8:	86d2                	mv	a3,s4
    800024aa:	864e                	mv	a2,s3
    800024ac:	85ca                	mv	a1,s2
    800024ae:	6928                	ld	a0,80(a0)
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	256080e7          	jalr	598(ra) # 80001706 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024b8:	70a2                	ld	ra,40(sp)
    800024ba:	7402                	ld	s0,32(sp)
    800024bc:	64e2                	ld	s1,24(sp)
    800024be:	6942                	ld	s2,16(sp)
    800024c0:	69a2                	ld	s3,8(sp)
    800024c2:	6a02                	ld	s4,0(sp)
    800024c4:	6145                	addi	sp,sp,48
    800024c6:	8082                	ret
    memmove((char *)dst, src, len);
    800024c8:	000a061b          	sext.w	a2,s4
    800024cc:	85ce                	mv	a1,s3
    800024ce:	854a                	mv	a0,s2
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	8d0080e7          	jalr	-1840(ra) # 80000da0 <memmove>
    return 0;
    800024d8:	8526                	mv	a0,s1
    800024da:	bff9                	j	800024b8 <either_copyout+0x32>

00000000800024dc <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024dc:	7179                	addi	sp,sp,-48
    800024de:	f406                	sd	ra,40(sp)
    800024e0:	f022                	sd	s0,32(sp)
    800024e2:	ec26                	sd	s1,24(sp)
    800024e4:	e84a                	sd	s2,16(sp)
    800024e6:	e44e                	sd	s3,8(sp)
    800024e8:	e052                	sd	s4,0(sp)
    800024ea:	1800                	addi	s0,sp,48
    800024ec:	892a                	mv	s2,a0
    800024ee:	84ae                	mv	s1,a1
    800024f0:	89b2                	mv	s3,a2
    800024f2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024f4:	fffff097          	auipc	ra,0xfffff
    800024f8:	520080e7          	jalr	1312(ra) # 80001a14 <myproc>
  if(user_src){
    800024fc:	c08d                	beqz	s1,8000251e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024fe:	86d2                	mv	a3,s4
    80002500:	864e                	mv	a2,s3
    80002502:	85ca                	mv	a1,s2
    80002504:	6928                	ld	a0,80(a0)
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	28c080e7          	jalr	652(ra) # 80001792 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000250e:	70a2                	ld	ra,40(sp)
    80002510:	7402                	ld	s0,32(sp)
    80002512:	64e2                	ld	s1,24(sp)
    80002514:	6942                	ld	s2,16(sp)
    80002516:	69a2                	ld	s3,8(sp)
    80002518:	6a02                	ld	s4,0(sp)
    8000251a:	6145                	addi	sp,sp,48
    8000251c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000251e:	000a061b          	sext.w	a2,s4
    80002522:	85ce                	mv	a1,s3
    80002524:	854a                	mv	a0,s2
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	87a080e7          	jalr	-1926(ra) # 80000da0 <memmove>
    return 0;
    8000252e:	8526                	mv	a0,s1
    80002530:	bff9                	j	8000250e <either_copyin+0x32>

0000000080002532 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002532:	715d                	addi	sp,sp,-80
    80002534:	e486                	sd	ra,72(sp)
    80002536:	e0a2                	sd	s0,64(sp)
    80002538:	fc26                	sd	s1,56(sp)
    8000253a:	f84a                	sd	s2,48(sp)
    8000253c:	f44e                	sd	s3,40(sp)
    8000253e:	f052                	sd	s4,32(sp)
    80002540:	ec56                	sd	s5,24(sp)
    80002542:	e85a                	sd	s6,16(sp)
    80002544:	e45e                	sd	s7,8(sp)
    80002546:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002548:	00006517          	auipc	a0,0x6
    8000254c:	b8050513          	addi	a0,a0,-1152 # 800080c8 <digits+0x88>
    80002550:	ffffe097          	auipc	ra,0xffffe
    80002554:	03c080e7          	jalr	60(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002558:	00010497          	auipc	s1,0x10
    8000255c:	96848493          	addi	s1,s1,-1688 # 80011ec0 <proc+0x158>
    80002560:	00015917          	auipc	s2,0x15
    80002564:	56090913          	addi	s2,s2,1376 # 80017ac0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002568:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000256a:	00006997          	auipc	s3,0x6
    8000256e:	cfe98993          	addi	s3,s3,-770 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    80002572:	00006a97          	auipc	s5,0x6
    80002576:	cfea8a93          	addi	s5,s5,-770 # 80008270 <digits+0x230>
    printf("\n");
    8000257a:	00006a17          	auipc	s4,0x6
    8000257e:	b4ea0a13          	addi	s4,s4,-1202 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002582:	00006b97          	auipc	s7,0x6
    80002586:	d26b8b93          	addi	s7,s7,-730 # 800082a8 <states.0>
    8000258a:	a00d                	j	800025ac <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000258c:	ee06a583          	lw	a1,-288(a3)
    80002590:	8556                	mv	a0,s5
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	ffa080e7          	jalr	-6(ra) # 8000058c <printf>
    printf("\n");
    8000259a:	8552                	mv	a0,s4
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	ff0080e7          	jalr	-16(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025a4:	17048493          	addi	s1,s1,368
    800025a8:	03248163          	beq	s1,s2,800025ca <procdump+0x98>
    if(p->state == UNUSED)
    800025ac:	86a6                	mv	a3,s1
    800025ae:	ec04a783          	lw	a5,-320(s1)
    800025b2:	dbed                	beqz	a5,800025a4 <procdump+0x72>
      state = "???";
    800025b4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025b6:	fcfb6be3          	bltu	s6,a5,8000258c <procdump+0x5a>
    800025ba:	1782                	slli	a5,a5,0x20
    800025bc:	9381                	srli	a5,a5,0x20
    800025be:	078e                	slli	a5,a5,0x3
    800025c0:	97de                	add	a5,a5,s7
    800025c2:	6390                	ld	a2,0(a5)
    800025c4:	f661                	bnez	a2,8000258c <procdump+0x5a>
      state = "???";
    800025c6:	864e                	mv	a2,s3
    800025c8:	b7d1                	j	8000258c <procdump+0x5a>
  }
}
    800025ca:	60a6                	ld	ra,72(sp)
    800025cc:	6406                	ld	s0,64(sp)
    800025ce:	74e2                	ld	s1,56(sp)
    800025d0:	7942                	ld	s2,48(sp)
    800025d2:	79a2                	ld	s3,40(sp)
    800025d4:	7a02                	ld	s4,32(sp)
    800025d6:	6ae2                	ld	s5,24(sp)
    800025d8:	6b42                	ld	s6,16(sp)
    800025da:	6ba2                	ld	s7,8(sp)
    800025dc:	6161                	addi	sp,sp,80
    800025de:	8082                	ret

00000000800025e0 <proccount>:

// Used for sysinfo syscall.
// Count how many process are able to use.
int 
proccount(void) {
    800025e0:	1141                	addi	sp,sp,-16
    800025e2:	e422                	sd	s0,8(sp)
    800025e4:	0800                	addi	s0,sp,16
  int count = 0;
  for(int i = 0; i < NPROC; i++)
    800025e6:	0000f797          	auipc	a5,0xf
    800025ea:	79a78793          	addi	a5,a5,1946 # 80011d80 <proc+0x18>
    800025ee:	00015697          	auipc	a3,0x15
    800025f2:	39268693          	addi	a3,a3,914 # 80017980 <bcache>
  int count = 0;
    800025f6:	4501                	li	a0,0
    800025f8:	a029                	j	80002602 <proccount+0x22>
  for(int i = 0; i < NPROC; i++)
    800025fa:	17078793          	addi	a5,a5,368
    800025fe:	00d78663          	beq	a5,a3,8000260a <proccount+0x2a>
  {
	  if(proc[i].state != UNUSED)
    80002602:	4398                	lw	a4,0(a5)
    80002604:	db7d                	beqz	a4,800025fa <proccount+0x1a>
	  {
		  count ++;
    80002606:	2505                	addiw	a0,a0,1
    80002608:	bfcd                	j	800025fa <proccount+0x1a>
	  }
  }

  return count;
}
    8000260a:	6422                	ld	s0,8(sp)
    8000260c:	0141                	addi	sp,sp,16
    8000260e:	8082                	ret

0000000080002610 <swtch>:
    80002610:	00153023          	sd	ra,0(a0)
    80002614:	00253423          	sd	sp,8(a0)
    80002618:	e900                	sd	s0,16(a0)
    8000261a:	ed04                	sd	s1,24(a0)
    8000261c:	03253023          	sd	s2,32(a0)
    80002620:	03353423          	sd	s3,40(a0)
    80002624:	03453823          	sd	s4,48(a0)
    80002628:	03553c23          	sd	s5,56(a0)
    8000262c:	05653023          	sd	s6,64(a0)
    80002630:	05753423          	sd	s7,72(a0)
    80002634:	05853823          	sd	s8,80(a0)
    80002638:	05953c23          	sd	s9,88(a0)
    8000263c:	07a53023          	sd	s10,96(a0)
    80002640:	07b53423          	sd	s11,104(a0)
    80002644:	0005b083          	ld	ra,0(a1)
    80002648:	0085b103          	ld	sp,8(a1)
    8000264c:	6980                	ld	s0,16(a1)
    8000264e:	6d84                	ld	s1,24(a1)
    80002650:	0205b903          	ld	s2,32(a1)
    80002654:	0285b983          	ld	s3,40(a1)
    80002658:	0305ba03          	ld	s4,48(a1)
    8000265c:	0385ba83          	ld	s5,56(a1)
    80002660:	0405bb03          	ld	s6,64(a1)
    80002664:	0485bb83          	ld	s7,72(a1)
    80002668:	0505bc03          	ld	s8,80(a1)
    8000266c:	0585bc83          	ld	s9,88(a1)
    80002670:	0605bd03          	ld	s10,96(a1)
    80002674:	0685bd83          	ld	s11,104(a1)
    80002678:	8082                	ret

000000008000267a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000267a:	1141                	addi	sp,sp,-16
    8000267c:	e406                	sd	ra,8(sp)
    8000267e:	e022                	sd	s0,0(sp)
    80002680:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002682:	00006597          	auipc	a1,0x6
    80002686:	c4e58593          	addi	a1,a1,-946 # 800082d0 <states.0+0x28>
    8000268a:	00015517          	auipc	a0,0x15
    8000268e:	2de50513          	addi	a0,a0,734 # 80017968 <tickslock>
    80002692:	ffffe097          	auipc	ra,0xffffe
    80002696:	526080e7          	jalr	1318(ra) # 80000bb8 <initlock>
}
    8000269a:	60a2                	ld	ra,8(sp)
    8000269c:	6402                	ld	s0,0(sp)
    8000269e:	0141                	addi	sp,sp,16
    800026a0:	8082                	ret

00000000800026a2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026a2:	1141                	addi	sp,sp,-16
    800026a4:	e422                	sd	s0,8(sp)
    800026a6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026a8:	00003797          	auipc	a5,0x3
    800026ac:	58878793          	addi	a5,a5,1416 # 80005c30 <kernelvec>
    800026b0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026b4:	6422                	ld	s0,8(sp)
    800026b6:	0141                	addi	sp,sp,16
    800026b8:	8082                	ret

00000000800026ba <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026ba:	1141                	addi	sp,sp,-16
    800026bc:	e406                	sd	ra,8(sp)
    800026be:	e022                	sd	s0,0(sp)
    800026c0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026c2:	fffff097          	auipc	ra,0xfffff
    800026c6:	352080e7          	jalr	850(ra) # 80001a14 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026ce:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026d4:	00005617          	auipc	a2,0x5
    800026d8:	92c60613          	addi	a2,a2,-1748 # 80007000 <_trampoline>
    800026dc:	00005697          	auipc	a3,0x5
    800026e0:	92468693          	addi	a3,a3,-1756 # 80007000 <_trampoline>
    800026e4:	8e91                	sub	a3,a3,a2
    800026e6:	040007b7          	lui	a5,0x4000
    800026ea:	17fd                	addi	a5,a5,-1
    800026ec:	07b2                	slli	a5,a5,0xc
    800026ee:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026f0:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026f4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026f6:	180026f3          	csrr	a3,satp
    800026fa:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026fc:	6d38                	ld	a4,88(a0)
    800026fe:	6134                	ld	a3,64(a0)
    80002700:	6585                	lui	a1,0x1
    80002702:	96ae                	add	a3,a3,a1
    80002704:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002706:	6d38                	ld	a4,88(a0)
    80002708:	00000697          	auipc	a3,0x0
    8000270c:	13868693          	addi	a3,a3,312 # 80002840 <usertrap>
    80002710:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002712:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002714:	8692                	mv	a3,tp
    80002716:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002718:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000271c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002720:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002724:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002728:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000272a:	6f18                	ld	a4,24(a4)
    8000272c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002730:	692c                	ld	a1,80(a0)
    80002732:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002734:	00005717          	auipc	a4,0x5
    80002738:	95c70713          	addi	a4,a4,-1700 # 80007090 <userret>
    8000273c:	8f11                	sub	a4,a4,a2
    8000273e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002740:	577d                	li	a4,-1
    80002742:	177e                	slli	a4,a4,0x3f
    80002744:	8dd9                	or	a1,a1,a4
    80002746:	02000537          	lui	a0,0x2000
    8000274a:	157d                	addi	a0,a0,-1
    8000274c:	0536                	slli	a0,a0,0xd
    8000274e:	9782                	jalr	a5
}
    80002750:	60a2                	ld	ra,8(sp)
    80002752:	6402                	ld	s0,0(sp)
    80002754:	0141                	addi	sp,sp,16
    80002756:	8082                	ret

0000000080002758 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002758:	1101                	addi	sp,sp,-32
    8000275a:	ec06                	sd	ra,24(sp)
    8000275c:	e822                	sd	s0,16(sp)
    8000275e:	e426                	sd	s1,8(sp)
    80002760:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002762:	00015497          	auipc	s1,0x15
    80002766:	20648493          	addi	s1,s1,518 # 80017968 <tickslock>
    8000276a:	8526                	mv	a0,s1
    8000276c:	ffffe097          	auipc	ra,0xffffe
    80002770:	4dc080e7          	jalr	1244(ra) # 80000c48 <acquire>
  ticks++;
    80002774:	00007517          	auipc	a0,0x7
    80002778:	8ac50513          	addi	a0,a0,-1876 # 80009020 <ticks>
    8000277c:	411c                	lw	a5,0(a0)
    8000277e:	2785                	addiw	a5,a5,1
    80002780:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002782:	00000097          	auipc	ra,0x0
    80002786:	c2a080e7          	jalr	-982(ra) # 800023ac <wakeup>
  release(&tickslock);
    8000278a:	8526                	mv	a0,s1
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	570080e7          	jalr	1392(ra) # 80000cfc <release>
}
    80002794:	60e2                	ld	ra,24(sp)
    80002796:	6442                	ld	s0,16(sp)
    80002798:	64a2                	ld	s1,8(sp)
    8000279a:	6105                	addi	sp,sp,32
    8000279c:	8082                	ret

000000008000279e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000279e:	1101                	addi	sp,sp,-32
    800027a0:	ec06                	sd	ra,24(sp)
    800027a2:	e822                	sd	s0,16(sp)
    800027a4:	e426                	sd	s1,8(sp)
    800027a6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027a8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027ac:	00074d63          	bltz	a4,800027c6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027b0:	57fd                	li	a5,-1
    800027b2:	17fe                	slli	a5,a5,0x3f
    800027b4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027b6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027b8:	06f70363          	beq	a4,a5,8000281e <devintr+0x80>
  }
}
    800027bc:	60e2                	ld	ra,24(sp)
    800027be:	6442                	ld	s0,16(sp)
    800027c0:	64a2                	ld	s1,8(sp)
    800027c2:	6105                	addi	sp,sp,32
    800027c4:	8082                	ret
     (scause & 0xff) == 9){
    800027c6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027ca:	46a5                	li	a3,9
    800027cc:	fed792e3          	bne	a5,a3,800027b0 <devintr+0x12>
    int irq = plic_claim();
    800027d0:	00003097          	auipc	ra,0x3
    800027d4:	568080e7          	jalr	1384(ra) # 80005d38 <plic_claim>
    800027d8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027da:	47a9                	li	a5,10
    800027dc:	02f50763          	beq	a0,a5,8000280a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027e0:	4785                	li	a5,1
    800027e2:	02f50963          	beq	a0,a5,80002814 <devintr+0x76>
    return 1;
    800027e6:	4505                	li	a0,1
    } else if(irq){
    800027e8:	d8f1                	beqz	s1,800027bc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027ea:	85a6                	mv	a1,s1
    800027ec:	00006517          	auipc	a0,0x6
    800027f0:	aec50513          	addi	a0,a0,-1300 # 800082d8 <states.0+0x30>
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	d98080e7          	jalr	-616(ra) # 8000058c <printf>
      plic_complete(irq);
    800027fc:	8526                	mv	a0,s1
    800027fe:	00003097          	auipc	ra,0x3
    80002802:	55e080e7          	jalr	1374(ra) # 80005d5c <plic_complete>
    return 1;
    80002806:	4505                	li	a0,1
    80002808:	bf55                	j	800027bc <devintr+0x1e>
      uartintr();
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	1b8080e7          	jalr	440(ra) # 800009c2 <uartintr>
    80002812:	b7ed                	j	800027fc <devintr+0x5e>
      virtio_disk_intr();
    80002814:	00004097          	auipc	ra,0x4
    80002818:	9c2080e7          	jalr	-1598(ra) # 800061d6 <virtio_disk_intr>
    8000281c:	b7c5                	j	800027fc <devintr+0x5e>
    if(cpuid() == 0){
    8000281e:	fffff097          	auipc	ra,0xfffff
    80002822:	1ca080e7          	jalr	458(ra) # 800019e8 <cpuid>
    80002826:	c901                	beqz	a0,80002836 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002828:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000282c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000282e:	14479073          	csrw	sip,a5
    return 2;
    80002832:	4509                	li	a0,2
    80002834:	b761                	j	800027bc <devintr+0x1e>
      clockintr();
    80002836:	00000097          	auipc	ra,0x0
    8000283a:	f22080e7          	jalr	-222(ra) # 80002758 <clockintr>
    8000283e:	b7ed                	j	80002828 <devintr+0x8a>

0000000080002840 <usertrap>:
{
    80002840:	1101                	addi	sp,sp,-32
    80002842:	ec06                	sd	ra,24(sp)
    80002844:	e822                	sd	s0,16(sp)
    80002846:	e426                	sd	s1,8(sp)
    80002848:	e04a                	sd	s2,0(sp)
    8000284a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000284c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002850:	1007f793          	andi	a5,a5,256
    80002854:	e3ad                	bnez	a5,800028b6 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002856:	00003797          	auipc	a5,0x3
    8000285a:	3da78793          	addi	a5,a5,986 # 80005c30 <kernelvec>
    8000285e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002862:	fffff097          	auipc	ra,0xfffff
    80002866:	1b2080e7          	jalr	434(ra) # 80001a14 <myproc>
    8000286a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000286c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000286e:	14102773          	csrr	a4,sepc
    80002872:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002874:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002878:	47a1                	li	a5,8
    8000287a:	04f71c63          	bne	a4,a5,800028d2 <usertrap+0x92>
    if(p->killed)
    8000287e:	591c                	lw	a5,48(a0)
    80002880:	e3b9                	bnez	a5,800028c6 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002882:	6cb8                	ld	a4,88(s1)
    80002884:	6f1c                	ld	a5,24(a4)
    80002886:	0791                	addi	a5,a5,4
    80002888:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000288a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000288e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002892:	10079073          	csrw	sstatus,a5
    syscall();
    80002896:	00000097          	auipc	ra,0x0
    8000289a:	2e0080e7          	jalr	736(ra) # 80002b76 <syscall>
  if(p->killed)
    8000289e:	589c                	lw	a5,48(s1)
    800028a0:	ebc1                	bnez	a5,80002930 <usertrap+0xf0>
  usertrapret();
    800028a2:	00000097          	auipc	ra,0x0
    800028a6:	e18080e7          	jalr	-488(ra) # 800026ba <usertrapret>
}
    800028aa:	60e2                	ld	ra,24(sp)
    800028ac:	6442                	ld	s0,16(sp)
    800028ae:	64a2                	ld	s1,8(sp)
    800028b0:	6902                	ld	s2,0(sp)
    800028b2:	6105                	addi	sp,sp,32
    800028b4:	8082                	ret
    panic("usertrap: not from user mode");
    800028b6:	00006517          	auipc	a0,0x6
    800028ba:	a4250513          	addi	a0,a0,-1470 # 800082f8 <states.0+0x50>
    800028be:	ffffe097          	auipc	ra,0xffffe
    800028c2:	c84080e7          	jalr	-892(ra) # 80000542 <panic>
      exit(-1);
    800028c6:	557d                	li	a0,-1
    800028c8:	00000097          	auipc	ra,0x0
    800028cc:	81e080e7          	jalr	-2018(ra) # 800020e6 <exit>
    800028d0:	bf4d                	j	80002882 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028d2:	00000097          	auipc	ra,0x0
    800028d6:	ecc080e7          	jalr	-308(ra) # 8000279e <devintr>
    800028da:	892a                	mv	s2,a0
    800028dc:	c501                	beqz	a0,800028e4 <usertrap+0xa4>
  if(p->killed)
    800028de:	589c                	lw	a5,48(s1)
    800028e0:	c3a1                	beqz	a5,80002920 <usertrap+0xe0>
    800028e2:	a815                	j	80002916 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028e4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028e8:	5c90                	lw	a2,56(s1)
    800028ea:	00006517          	auipc	a0,0x6
    800028ee:	a2e50513          	addi	a0,a0,-1490 # 80008318 <states.0+0x70>
    800028f2:	ffffe097          	auipc	ra,0xffffe
    800028f6:	c9a080e7          	jalr	-870(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028fa:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028fe:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002902:	00006517          	auipc	a0,0x6
    80002906:	a4650513          	addi	a0,a0,-1466 # 80008348 <states.0+0xa0>
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	c82080e7          	jalr	-894(ra) # 8000058c <printf>
    p->killed = 1;
    80002912:	4785                	li	a5,1
    80002914:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002916:	557d                	li	a0,-1
    80002918:	fffff097          	auipc	ra,0xfffff
    8000291c:	7ce080e7          	jalr	1998(ra) # 800020e6 <exit>
  if(which_dev == 2)
    80002920:	4789                	li	a5,2
    80002922:	f8f910e3          	bne	s2,a5,800028a2 <usertrap+0x62>
    yield();
    80002926:	00000097          	auipc	ra,0x0
    8000292a:	8ca080e7          	jalr	-1846(ra) # 800021f0 <yield>
    8000292e:	bf95                	j	800028a2 <usertrap+0x62>
  int which_dev = 0;
    80002930:	4901                	li	s2,0
    80002932:	b7d5                	j	80002916 <usertrap+0xd6>

0000000080002934 <kerneltrap>:
{
    80002934:	7179                	addi	sp,sp,-48
    80002936:	f406                	sd	ra,40(sp)
    80002938:	f022                	sd	s0,32(sp)
    8000293a:	ec26                	sd	s1,24(sp)
    8000293c:	e84a                	sd	s2,16(sp)
    8000293e:	e44e                	sd	s3,8(sp)
    80002940:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002942:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002946:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000294a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000294e:	1004f793          	andi	a5,s1,256
    80002952:	cb85                	beqz	a5,80002982 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002954:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002958:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000295a:	ef85                	bnez	a5,80002992 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000295c:	00000097          	auipc	ra,0x0
    80002960:	e42080e7          	jalr	-446(ra) # 8000279e <devintr>
    80002964:	cd1d                	beqz	a0,800029a2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002966:	4789                	li	a5,2
    80002968:	06f50a63          	beq	a0,a5,800029dc <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000296c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002970:	10049073          	csrw	sstatus,s1
}
    80002974:	70a2                	ld	ra,40(sp)
    80002976:	7402                	ld	s0,32(sp)
    80002978:	64e2                	ld	s1,24(sp)
    8000297a:	6942                	ld	s2,16(sp)
    8000297c:	69a2                	ld	s3,8(sp)
    8000297e:	6145                	addi	sp,sp,48
    80002980:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002982:	00006517          	auipc	a0,0x6
    80002986:	9e650513          	addi	a0,a0,-1562 # 80008368 <states.0+0xc0>
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	bb8080e7          	jalr	-1096(ra) # 80000542 <panic>
    panic("kerneltrap: interrupts enabled");
    80002992:	00006517          	auipc	a0,0x6
    80002996:	9fe50513          	addi	a0,a0,-1538 # 80008390 <states.0+0xe8>
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	ba8080e7          	jalr	-1112(ra) # 80000542 <panic>
    printf("scause %p\n", scause);
    800029a2:	85ce                	mv	a1,s3
    800029a4:	00006517          	auipc	a0,0x6
    800029a8:	a0c50513          	addi	a0,a0,-1524 # 800083b0 <states.0+0x108>
    800029ac:	ffffe097          	auipc	ra,0xffffe
    800029b0:	be0080e7          	jalr	-1056(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029b4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029b8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029bc:	00006517          	auipc	a0,0x6
    800029c0:	a0450513          	addi	a0,a0,-1532 # 800083c0 <states.0+0x118>
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	bc8080e7          	jalr	-1080(ra) # 8000058c <printf>
    panic("kerneltrap");
    800029cc:	00006517          	auipc	a0,0x6
    800029d0:	a0c50513          	addi	a0,a0,-1524 # 800083d8 <states.0+0x130>
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	b6e080e7          	jalr	-1170(ra) # 80000542 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029dc:	fffff097          	auipc	ra,0xfffff
    800029e0:	038080e7          	jalr	56(ra) # 80001a14 <myproc>
    800029e4:	d541                	beqz	a0,8000296c <kerneltrap+0x38>
    800029e6:	fffff097          	auipc	ra,0xfffff
    800029ea:	02e080e7          	jalr	46(ra) # 80001a14 <myproc>
    800029ee:	4d18                	lw	a4,24(a0)
    800029f0:	478d                	li	a5,3
    800029f2:	f6f71de3          	bne	a4,a5,8000296c <kerneltrap+0x38>
    yield();
    800029f6:	fffff097          	auipc	ra,0xfffff
    800029fa:	7fa080e7          	jalr	2042(ra) # 800021f0 <yield>
    800029fe:	b7bd                	j	8000296c <kerneltrap+0x38>

0000000080002a00 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a00:	1101                	addi	sp,sp,-32
    80002a02:	ec06                	sd	ra,24(sp)
    80002a04:	e822                	sd	s0,16(sp)
    80002a06:	e426                	sd	s1,8(sp)
    80002a08:	1000                	addi	s0,sp,32
    80002a0a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a0c:	fffff097          	auipc	ra,0xfffff
    80002a10:	008080e7          	jalr	8(ra) # 80001a14 <myproc>
  switch (n) {
    80002a14:	4795                	li	a5,5
    80002a16:	0497e163          	bltu	a5,s1,80002a58 <argraw+0x58>
    80002a1a:	048a                	slli	s1,s1,0x2
    80002a1c:	00006717          	auipc	a4,0x6
    80002a20:	a0c70713          	addi	a4,a4,-1524 # 80008428 <states.0+0x180>
    80002a24:	94ba                	add	s1,s1,a4
    80002a26:	409c                	lw	a5,0(s1)
    80002a28:	97ba                	add	a5,a5,a4
    80002a2a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a2c:	6d3c                	ld	a5,88(a0)
    80002a2e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a30:	60e2                	ld	ra,24(sp)
    80002a32:	6442                	ld	s0,16(sp)
    80002a34:	64a2                	ld	s1,8(sp)
    80002a36:	6105                	addi	sp,sp,32
    80002a38:	8082                	ret
    return p->trapframe->a1;
    80002a3a:	6d3c                	ld	a5,88(a0)
    80002a3c:	7fa8                	ld	a0,120(a5)
    80002a3e:	bfcd                	j	80002a30 <argraw+0x30>
    return p->trapframe->a2;
    80002a40:	6d3c                	ld	a5,88(a0)
    80002a42:	63c8                	ld	a0,128(a5)
    80002a44:	b7f5                	j	80002a30 <argraw+0x30>
    return p->trapframe->a3;
    80002a46:	6d3c                	ld	a5,88(a0)
    80002a48:	67c8                	ld	a0,136(a5)
    80002a4a:	b7dd                	j	80002a30 <argraw+0x30>
    return p->trapframe->a4;
    80002a4c:	6d3c                	ld	a5,88(a0)
    80002a4e:	6bc8                	ld	a0,144(a5)
    80002a50:	b7c5                	j	80002a30 <argraw+0x30>
    return p->trapframe->a5;
    80002a52:	6d3c                	ld	a5,88(a0)
    80002a54:	6fc8                	ld	a0,152(a5)
    80002a56:	bfe9                	j	80002a30 <argraw+0x30>
  panic("argraw");
    80002a58:	00006517          	auipc	a0,0x6
    80002a5c:	99050513          	addi	a0,a0,-1648 # 800083e8 <states.0+0x140>
    80002a60:	ffffe097          	auipc	ra,0xffffe
    80002a64:	ae2080e7          	jalr	-1310(ra) # 80000542 <panic>

0000000080002a68 <fetchaddr>:
{
    80002a68:	1101                	addi	sp,sp,-32
    80002a6a:	ec06                	sd	ra,24(sp)
    80002a6c:	e822                	sd	s0,16(sp)
    80002a6e:	e426                	sd	s1,8(sp)
    80002a70:	e04a                	sd	s2,0(sp)
    80002a72:	1000                	addi	s0,sp,32
    80002a74:	84aa                	mv	s1,a0
    80002a76:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a78:	fffff097          	auipc	ra,0xfffff
    80002a7c:	f9c080e7          	jalr	-100(ra) # 80001a14 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a80:	653c                	ld	a5,72(a0)
    80002a82:	02f4f863          	bgeu	s1,a5,80002ab2 <fetchaddr+0x4a>
    80002a86:	00848713          	addi	a4,s1,8
    80002a8a:	02e7e663          	bltu	a5,a4,80002ab6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a8e:	46a1                	li	a3,8
    80002a90:	8626                	mv	a2,s1
    80002a92:	85ca                	mv	a1,s2
    80002a94:	6928                	ld	a0,80(a0)
    80002a96:	fffff097          	auipc	ra,0xfffff
    80002a9a:	cfc080e7          	jalr	-772(ra) # 80001792 <copyin>
    80002a9e:	00a03533          	snez	a0,a0
    80002aa2:	40a00533          	neg	a0,a0
}
    80002aa6:	60e2                	ld	ra,24(sp)
    80002aa8:	6442                	ld	s0,16(sp)
    80002aaa:	64a2                	ld	s1,8(sp)
    80002aac:	6902                	ld	s2,0(sp)
    80002aae:	6105                	addi	sp,sp,32
    80002ab0:	8082                	ret
    return -1;
    80002ab2:	557d                	li	a0,-1
    80002ab4:	bfcd                	j	80002aa6 <fetchaddr+0x3e>
    80002ab6:	557d                	li	a0,-1
    80002ab8:	b7fd                	j	80002aa6 <fetchaddr+0x3e>

0000000080002aba <fetchstr>:
{
    80002aba:	7179                	addi	sp,sp,-48
    80002abc:	f406                	sd	ra,40(sp)
    80002abe:	f022                	sd	s0,32(sp)
    80002ac0:	ec26                	sd	s1,24(sp)
    80002ac2:	e84a                	sd	s2,16(sp)
    80002ac4:	e44e                	sd	s3,8(sp)
    80002ac6:	1800                	addi	s0,sp,48
    80002ac8:	892a                	mv	s2,a0
    80002aca:	84ae                	mv	s1,a1
    80002acc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ace:	fffff097          	auipc	ra,0xfffff
    80002ad2:	f46080e7          	jalr	-186(ra) # 80001a14 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ad6:	86ce                	mv	a3,s3
    80002ad8:	864a                	mv	a2,s2
    80002ada:	85a6                	mv	a1,s1
    80002adc:	6928                	ld	a0,80(a0)
    80002ade:	fffff097          	auipc	ra,0xfffff
    80002ae2:	d42080e7          	jalr	-702(ra) # 80001820 <copyinstr>
  if(err < 0)
    80002ae6:	00054763          	bltz	a0,80002af4 <fetchstr+0x3a>
  return strlen(buf);
    80002aea:	8526                	mv	a0,s1
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	3dc080e7          	jalr	988(ra) # 80000ec8 <strlen>
}
    80002af4:	70a2                	ld	ra,40(sp)
    80002af6:	7402                	ld	s0,32(sp)
    80002af8:	64e2                	ld	s1,24(sp)
    80002afa:	6942                	ld	s2,16(sp)
    80002afc:	69a2                	ld	s3,8(sp)
    80002afe:	6145                	addi	sp,sp,48
    80002b00:	8082                	ret

0000000080002b02 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b02:	1101                	addi	sp,sp,-32
    80002b04:	ec06                	sd	ra,24(sp)
    80002b06:	e822                	sd	s0,16(sp)
    80002b08:	e426                	sd	s1,8(sp)
    80002b0a:	1000                	addi	s0,sp,32
    80002b0c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b0e:	00000097          	auipc	ra,0x0
    80002b12:	ef2080e7          	jalr	-270(ra) # 80002a00 <argraw>
    80002b16:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b18:	4501                	li	a0,0
    80002b1a:	60e2                	ld	ra,24(sp)
    80002b1c:	6442                	ld	s0,16(sp)
    80002b1e:	64a2                	ld	s1,8(sp)
    80002b20:	6105                	addi	sp,sp,32
    80002b22:	8082                	ret

0000000080002b24 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b24:	1101                	addi	sp,sp,-32
    80002b26:	ec06                	sd	ra,24(sp)
    80002b28:	e822                	sd	s0,16(sp)
    80002b2a:	e426                	sd	s1,8(sp)
    80002b2c:	1000                	addi	s0,sp,32
    80002b2e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b30:	00000097          	auipc	ra,0x0
    80002b34:	ed0080e7          	jalr	-304(ra) # 80002a00 <argraw>
    80002b38:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b3a:	4501                	li	a0,0
    80002b3c:	60e2                	ld	ra,24(sp)
    80002b3e:	6442                	ld	s0,16(sp)
    80002b40:	64a2                	ld	s1,8(sp)
    80002b42:	6105                	addi	sp,sp,32
    80002b44:	8082                	ret

0000000080002b46 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b46:	1101                	addi	sp,sp,-32
    80002b48:	ec06                	sd	ra,24(sp)
    80002b4a:	e822                	sd	s0,16(sp)
    80002b4c:	e426                	sd	s1,8(sp)
    80002b4e:	e04a                	sd	s2,0(sp)
    80002b50:	1000                	addi	s0,sp,32
    80002b52:	84ae                	mv	s1,a1
    80002b54:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b56:	00000097          	auipc	ra,0x0
    80002b5a:	eaa080e7          	jalr	-342(ra) # 80002a00 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b5e:	864a                	mv	a2,s2
    80002b60:	85a6                	mv	a1,s1
    80002b62:	00000097          	auipc	ra,0x0
    80002b66:	f58080e7          	jalr	-168(ra) # 80002aba <fetchstr>
}
    80002b6a:	60e2                	ld	ra,24(sp)
    80002b6c:	6442                	ld	s0,16(sp)
    80002b6e:	64a2                	ld	s1,8(sp)
    80002b70:	6902                	ld	s2,0(sp)
    80002b72:	6105                	addi	sp,sp,32
    80002b74:	8082                	ret

0000000080002b76 <syscall>:
[SYS_sysinfo] sys_sysinfo,
};

void
syscall(void)
{
    80002b76:	7179                	addi	sp,sp,-48
    80002b78:	f406                	sd	ra,40(sp)
    80002b7a:	f022                	sd	s0,32(sp)
    80002b7c:	ec26                	sd	s1,24(sp)
    80002b7e:	e84a                	sd	s2,16(sp)
    80002b80:	e44e                	sd	s3,8(sp)
    80002b82:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	e90080e7          	jalr	-368(ra) # 80001a14 <myproc>
    80002b8c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b8e:	05853903          	ld	s2,88(a0)
    80002b92:	0a893783          	ld	a5,168(s2)
    80002b96:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b9a:	37fd                	addiw	a5,a5,-1
    80002b9c:	4759                	li	a4,22
    80002b9e:	04f76b63          	bltu	a4,a5,80002bf4 <syscall+0x7e>
    80002ba2:	00399713          	slli	a4,s3,0x3
    80002ba6:	00006797          	auipc	a5,0x6
    80002baa:	89a78793          	addi	a5,a5,-1894 # 80008440 <syscalls>
    80002bae:	97ba                	add	a5,a5,a4
    80002bb0:	639c                	ld	a5,0(a5)
    80002bb2:	c3a9                	beqz	a5,80002bf4 <syscall+0x7e>
    p->trapframe->a0 = syscalls[num]();
    80002bb4:	9782                	jalr	a5
    80002bb6:	06a93823          	sd	a0,112(s2)

    // match the trace number, need to trace
    if((p->tmask) & (1 << num))
    80002bba:	1684a783          	lw	a5,360(s1)
    80002bbe:	4137d7bb          	sraw	a5,a5,s3
    80002bc2:	8b85                	andi	a5,a5,1
    80002bc4:	c7b9                	beqz	a5,80002c12 <syscall+0x9c>
    {
      printf("%d: syscall %s -> %d\n", p->pid, syscall_name[num - 1], p->trapframe->a0);
    80002bc6:	6cbc                	ld	a5,88(s1)
    80002bc8:	fff9861b          	addiw	a2,s3,-1
    80002bcc:	00261993          	slli	s3,a2,0x2
    80002bd0:	99b2                	add	s3,s3,a2
    80002bd2:	0986                	slli	s3,s3,0x1
    80002bd4:	7bb4                	ld	a3,112(a5)
    80002bd6:	00006617          	auipc	a2,0x6
    80002bda:	cb260613          	addi	a2,a2,-846 # 80008888 <syscall_name>
    80002bde:	964e                	add	a2,a2,s3
    80002be0:	5c8c                	lw	a1,56(s1)
    80002be2:	00006517          	auipc	a0,0x6
    80002be6:	80e50513          	addi	a0,a0,-2034 # 800083f0 <states.0+0x148>
    80002bea:	ffffe097          	auipc	ra,0xffffe
    80002bee:	9a2080e7          	jalr	-1630(ra) # 8000058c <printf>
    80002bf2:	a005                	j	80002c12 <syscall+0x9c>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bf4:	86ce                	mv	a3,s3
    80002bf6:	15848613          	addi	a2,s1,344
    80002bfa:	5c8c                	lw	a1,56(s1)
    80002bfc:	00006517          	auipc	a0,0x6
    80002c00:	80c50513          	addi	a0,a0,-2036 # 80008408 <states.0+0x160>
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	988080e7          	jalr	-1656(ra) # 8000058c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c0c:	6cbc                	ld	a5,88(s1)
    80002c0e:	577d                	li	a4,-1
    80002c10:	fbb8                	sd	a4,112(a5)
  }
}
    80002c12:	70a2                	ld	ra,40(sp)
    80002c14:	7402                	ld	s0,32(sp)
    80002c16:	64e2                	ld	s1,24(sp)
    80002c18:	6942                	ld	s2,16(sp)
    80002c1a:	69a2                	ld	s3,8(sp)
    80002c1c:	6145                	addi	sp,sp,48
    80002c1e:	8082                	ret

0000000080002c20 <sys_exit>:
extern int proccount(void);
extern int memcount(void); 

uint64 
sys_exit(void)
{
    80002c20:	1101                	addi	sp,sp,-32
    80002c22:	ec06                	sd	ra,24(sp)
    80002c24:	e822                	sd	s0,16(sp)
    80002c26:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c28:	fec40593          	addi	a1,s0,-20
    80002c2c:	4501                	li	a0,0
    80002c2e:	00000097          	auipc	ra,0x0
    80002c32:	ed4080e7          	jalr	-300(ra) # 80002b02 <argint>
    return -1;
    80002c36:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c38:	00054963          	bltz	a0,80002c4a <sys_exit+0x2a>
  exit(n);
    80002c3c:	fec42503          	lw	a0,-20(s0)
    80002c40:	fffff097          	auipc	ra,0xfffff
    80002c44:	4a6080e7          	jalr	1190(ra) # 800020e6 <exit>
  return 0;  // not reached
    80002c48:	4781                	li	a5,0
}
    80002c4a:	853e                	mv	a0,a5
    80002c4c:	60e2                	ld	ra,24(sp)
    80002c4e:	6442                	ld	s0,16(sp)
    80002c50:	6105                	addi	sp,sp,32
    80002c52:	8082                	ret

0000000080002c54 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c54:	1141                	addi	sp,sp,-16
    80002c56:	e406                	sd	ra,8(sp)
    80002c58:	e022                	sd	s0,0(sp)
    80002c5a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	db8080e7          	jalr	-584(ra) # 80001a14 <myproc>
}
    80002c64:	5d08                	lw	a0,56(a0)
    80002c66:	60a2                	ld	ra,8(sp)
    80002c68:	6402                	ld	s0,0(sp)
    80002c6a:	0141                	addi	sp,sp,16
    80002c6c:	8082                	ret

0000000080002c6e <sys_fork>:

uint64
sys_fork(void)
{
    80002c6e:	1141                	addi	sp,sp,-16
    80002c70:	e406                	sd	ra,8(sp)
    80002c72:	e022                	sd	s0,0(sp)
    80002c74:	0800                	addi	s0,sp,16
  return fork();
    80002c76:	fffff097          	auipc	ra,0xfffff
    80002c7a:	15e080e7          	jalr	350(ra) # 80001dd4 <fork>
}
    80002c7e:	60a2                	ld	ra,8(sp)
    80002c80:	6402                	ld	s0,0(sp)
    80002c82:	0141                	addi	sp,sp,16
    80002c84:	8082                	ret

0000000080002c86 <sys_wait>:

uint64
sys_wait(void)
{
    80002c86:	1101                	addi	sp,sp,-32
    80002c88:	ec06                	sd	ra,24(sp)
    80002c8a:	e822                	sd	s0,16(sp)
    80002c8c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c8e:	fe840593          	addi	a1,s0,-24
    80002c92:	4501                	li	a0,0
    80002c94:	00000097          	auipc	ra,0x0
    80002c98:	e90080e7          	jalr	-368(ra) # 80002b24 <argaddr>
    80002c9c:	87aa                	mv	a5,a0
    return -1;
    80002c9e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002ca0:	0007c863          	bltz	a5,80002cb0 <sys_wait+0x2a>
  return wait(p);
    80002ca4:	fe843503          	ld	a0,-24(s0)
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	602080e7          	jalr	1538(ra) # 800022aa <wait>
}
    80002cb0:	60e2                	ld	ra,24(sp)
    80002cb2:	6442                	ld	s0,16(sp)
    80002cb4:	6105                	addi	sp,sp,32
    80002cb6:	8082                	ret

0000000080002cb8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cb8:	7179                	addi	sp,sp,-48
    80002cba:	f406                	sd	ra,40(sp)
    80002cbc:	f022                	sd	s0,32(sp)
    80002cbe:	ec26                	sd	s1,24(sp)
    80002cc0:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002cc2:	fdc40593          	addi	a1,s0,-36
    80002cc6:	4501                	li	a0,0
    80002cc8:	00000097          	auipc	ra,0x0
    80002ccc:	e3a080e7          	jalr	-454(ra) # 80002b02 <argint>
    return -1;
    80002cd0:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002cd2:	00054f63          	bltz	a0,80002cf0 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	d3e080e7          	jalr	-706(ra) # 80001a14 <myproc>
    80002cde:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002ce0:	fdc42503          	lw	a0,-36(s0)
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	07c080e7          	jalr	124(ra) # 80001d60 <growproc>
    80002cec:	00054863          	bltz	a0,80002cfc <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002cf0:	8526                	mv	a0,s1
    80002cf2:	70a2                	ld	ra,40(sp)
    80002cf4:	7402                	ld	s0,32(sp)
    80002cf6:	64e2                	ld	s1,24(sp)
    80002cf8:	6145                	addi	sp,sp,48
    80002cfa:	8082                	ret
    return -1;
    80002cfc:	54fd                	li	s1,-1
    80002cfe:	bfcd                	j	80002cf0 <sys_sbrk+0x38>

0000000080002d00 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d00:	7139                	addi	sp,sp,-64
    80002d02:	fc06                	sd	ra,56(sp)
    80002d04:	f822                	sd	s0,48(sp)
    80002d06:	f426                	sd	s1,40(sp)
    80002d08:	f04a                	sd	s2,32(sp)
    80002d0a:	ec4e                	sd	s3,24(sp)
    80002d0c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d0e:	fcc40593          	addi	a1,s0,-52
    80002d12:	4501                	li	a0,0
    80002d14:	00000097          	auipc	ra,0x0
    80002d18:	dee080e7          	jalr	-530(ra) # 80002b02 <argint>
    return -1;
    80002d1c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d1e:	06054563          	bltz	a0,80002d88 <sys_sleep+0x88>
  acquire(&tickslock);
    80002d22:	00015517          	auipc	a0,0x15
    80002d26:	c4650513          	addi	a0,a0,-954 # 80017968 <tickslock>
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	f1e080e7          	jalr	-226(ra) # 80000c48 <acquire>
  ticks0 = ticks;
    80002d32:	00006917          	auipc	s2,0x6
    80002d36:	2ee92903          	lw	s2,750(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002d3a:	fcc42783          	lw	a5,-52(s0)
    80002d3e:	cf85                	beqz	a5,80002d76 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d40:	00015997          	auipc	s3,0x15
    80002d44:	c2898993          	addi	s3,s3,-984 # 80017968 <tickslock>
    80002d48:	00006497          	auipc	s1,0x6
    80002d4c:	2d848493          	addi	s1,s1,728 # 80009020 <ticks>
    if(myproc()->killed){
    80002d50:	fffff097          	auipc	ra,0xfffff
    80002d54:	cc4080e7          	jalr	-828(ra) # 80001a14 <myproc>
    80002d58:	591c                	lw	a5,48(a0)
    80002d5a:	ef9d                	bnez	a5,80002d98 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d5c:	85ce                	mv	a1,s3
    80002d5e:	8526                	mv	a0,s1
    80002d60:	fffff097          	auipc	ra,0xfffff
    80002d64:	4cc080e7          	jalr	1228(ra) # 8000222c <sleep>
  while(ticks - ticks0 < n){
    80002d68:	409c                	lw	a5,0(s1)
    80002d6a:	412787bb          	subw	a5,a5,s2
    80002d6e:	fcc42703          	lw	a4,-52(s0)
    80002d72:	fce7efe3          	bltu	a5,a4,80002d50 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d76:	00015517          	auipc	a0,0x15
    80002d7a:	bf250513          	addi	a0,a0,-1038 # 80017968 <tickslock>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	f7e080e7          	jalr	-130(ra) # 80000cfc <release>
  return 0;
    80002d86:	4781                	li	a5,0
}
    80002d88:	853e                	mv	a0,a5
    80002d8a:	70e2                	ld	ra,56(sp)
    80002d8c:	7442                	ld	s0,48(sp)
    80002d8e:	74a2                	ld	s1,40(sp)
    80002d90:	7902                	ld	s2,32(sp)
    80002d92:	69e2                	ld	s3,24(sp)
    80002d94:	6121                	addi	sp,sp,64
    80002d96:	8082                	ret
      release(&tickslock);
    80002d98:	00015517          	auipc	a0,0x15
    80002d9c:	bd050513          	addi	a0,a0,-1072 # 80017968 <tickslock>
    80002da0:	ffffe097          	auipc	ra,0xffffe
    80002da4:	f5c080e7          	jalr	-164(ra) # 80000cfc <release>
      return -1;
    80002da8:	57fd                	li	a5,-1
    80002daa:	bff9                	j	80002d88 <sys_sleep+0x88>

0000000080002dac <sys_kill>:

uint64
sys_kill(void)
{
    80002dac:	1101                	addi	sp,sp,-32
    80002dae:	ec06                	sd	ra,24(sp)
    80002db0:	e822                	sd	s0,16(sp)
    80002db2:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002db4:	fec40593          	addi	a1,s0,-20
    80002db8:	4501                	li	a0,0
    80002dba:	00000097          	auipc	ra,0x0
    80002dbe:	d48080e7          	jalr	-696(ra) # 80002b02 <argint>
    80002dc2:	87aa                	mv	a5,a0
    return -1;
    80002dc4:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002dc6:	0007c863          	bltz	a5,80002dd6 <sys_kill+0x2a>
  return kill(pid);
    80002dca:	fec42503          	lw	a0,-20(s0)
    80002dce:	fffff097          	auipc	ra,0xfffff
    80002dd2:	648080e7          	jalr	1608(ra) # 80002416 <kill>
}
    80002dd6:	60e2                	ld	ra,24(sp)
    80002dd8:	6442                	ld	s0,16(sp)
    80002dda:	6105                	addi	sp,sp,32
    80002ddc:	8082                	ret

0000000080002dde <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dde:	1101                	addi	sp,sp,-32
    80002de0:	ec06                	sd	ra,24(sp)
    80002de2:	e822                	sd	s0,16(sp)
    80002de4:	e426                	sd	s1,8(sp)
    80002de6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002de8:	00015517          	auipc	a0,0x15
    80002dec:	b8050513          	addi	a0,a0,-1152 # 80017968 <tickslock>
    80002df0:	ffffe097          	auipc	ra,0xffffe
    80002df4:	e58080e7          	jalr	-424(ra) # 80000c48 <acquire>
  xticks = ticks;
    80002df8:	00006497          	auipc	s1,0x6
    80002dfc:	2284a483          	lw	s1,552(s1) # 80009020 <ticks>
  release(&tickslock);
    80002e00:	00015517          	auipc	a0,0x15
    80002e04:	b6850513          	addi	a0,a0,-1176 # 80017968 <tickslock>
    80002e08:	ffffe097          	auipc	ra,0xffffe
    80002e0c:	ef4080e7          	jalr	-268(ra) # 80000cfc <release>
  return xticks;
}
    80002e10:	02049513          	slli	a0,s1,0x20
    80002e14:	9101                	srli	a0,a0,0x20
    80002e16:	60e2                	ld	ra,24(sp)
    80002e18:	6442                	ld	s0,16(sp)
    80002e1a:	64a2                	ld	s1,8(sp)
    80002e1c:	6105                	addi	sp,sp,32
    80002e1e:	8082                	ret

0000000080002e20 <sys_trace>:

// used for systrace syscall
uint64
sys_trace(void)
{
    80002e20:	1101                	addi	sp,sp,-32
    80002e22:	ec06                	sd	ra,24(sp)
    80002e24:	e822                	sd	s0,16(sp)
    80002e26:	1000                	addi	s0,sp,32
  int n;

  if(argint(0, &n) < 0)
    80002e28:	fec40593          	addi	a1,s0,-20
    80002e2c:	4501                	li	a0,0
    80002e2e:	00000097          	auipc	ra,0x0
    80002e32:	cd4080e7          	jalr	-812(ra) # 80002b02 <argint>
    return -1;
    80002e36:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e38:	00054b63          	bltz	a0,80002e4e <sys_trace+0x2e>

  myproc()->tmask = n;
    80002e3c:	fffff097          	auipc	ra,0xfffff
    80002e40:	bd8080e7          	jalr	-1064(ra) # 80001a14 <myproc>
    80002e44:	fec42783          	lw	a5,-20(s0)
    80002e48:	16f52423          	sw	a5,360(a0)
  return 0;
    80002e4c:	4781                	li	a5,0
}
    80002e4e:	853e                	mv	a0,a5
    80002e50:	60e2                	ld	ra,24(sp)
    80002e52:	6442                	ld	s0,16(sp)
    80002e54:	6105                	addi	sp,sp,32
    80002e56:	8082                	ret

0000000080002e58 <sys_sysinfo>:

// used for sysinfo
uint64 
sys_sysinfo(void)
{
    80002e58:	7179                	addi	sp,sp,-48
    80002e5a:	f406                	sd	ra,40(sp)
    80002e5c:	f022                	sd	s0,32(sp)
    80002e5e:	1800                	addi	s0,sp,48
  struct sysinfo sysinfo;

  // Get the arg virtual address, when sysinfo get updated
  // need to copy out there.
  uint64 sysinfoAddr;
  if(argaddr(0, &sysinfoAddr) != 0)
    80002e60:	fd840593          	addi	a1,s0,-40
    80002e64:	4501                	li	a0,0
    80002e66:	00000097          	auipc	ra,0x0
    80002e6a:	cbe080e7          	jalr	-834(ra) # 80002b24 <argaddr>
    80002e6e:	87aa                	mv	a5,a0
	  return -1;
    80002e70:	557d                	li	a0,-1
  if(argaddr(0, &sysinfoAddr) != 0)
    80002e72:	ef85                	bnez	a5,80002eaa <sys_sysinfo+0x52>
  sysinfo.freemem = memcount();
    80002e74:	ffffe097          	auipc	ra,0xffffe
    80002e78:	cfa080e7          	jalr	-774(ra) # 80000b6e <memcount>
    80002e7c:	fea43023          	sd	a0,-32(s0)
  sysinfo.nproc = proccount();	  
    80002e80:	fffff097          	auipc	ra,0xfffff
    80002e84:	760080e7          	jalr	1888(ra) # 800025e0 <proccount>
    80002e88:	fea43423          	sd	a0,-24(s0)

  struct proc *p = myproc();
    80002e8c:	fffff097          	auipc	ra,0xfffff
    80002e90:	b88080e7          	jalr	-1144(ra) # 80001a14 <myproc>
  if((copyout(p->pagetable, sysinfoAddr, (char *)&sysinfo, sizeof(sysinfo))) < 0)
    80002e94:	46c1                	li	a3,16
    80002e96:	fe040613          	addi	a2,s0,-32
    80002e9a:	fd843583          	ld	a1,-40(s0)
    80002e9e:	6928                	ld	a0,80(a0)
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	866080e7          	jalr	-1946(ra) # 80001706 <copyout>
    80002ea8:	957d                	srai	a0,a0,0x3f
		  return -1;

  return 0;
}
    80002eaa:	70a2                	ld	ra,40(sp)
    80002eac:	7402                	ld	s0,32(sp)
    80002eae:	6145                	addi	sp,sp,48
    80002eb0:	8082                	ret

0000000080002eb2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002eb2:	7179                	addi	sp,sp,-48
    80002eb4:	f406                	sd	ra,40(sp)
    80002eb6:	f022                	sd	s0,32(sp)
    80002eb8:	ec26                	sd	s1,24(sp)
    80002eba:	e84a                	sd	s2,16(sp)
    80002ebc:	e44e                	sd	s3,8(sp)
    80002ebe:	e052                	sd	s4,0(sp)
    80002ec0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ec2:	00005597          	auipc	a1,0x5
    80002ec6:	63e58593          	addi	a1,a1,1598 # 80008500 <syscalls+0xc0>
    80002eca:	00015517          	auipc	a0,0x15
    80002ece:	ab650513          	addi	a0,a0,-1354 # 80017980 <bcache>
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	ce6080e7          	jalr	-794(ra) # 80000bb8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002eda:	0001d797          	auipc	a5,0x1d
    80002ede:	aa678793          	addi	a5,a5,-1370 # 8001f980 <bcache+0x8000>
    80002ee2:	0001d717          	auipc	a4,0x1d
    80002ee6:	d0670713          	addi	a4,a4,-762 # 8001fbe8 <bcache+0x8268>
    80002eea:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002eee:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ef2:	00015497          	auipc	s1,0x15
    80002ef6:	aa648493          	addi	s1,s1,-1370 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    80002efa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002efc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002efe:	00005a17          	auipc	s4,0x5
    80002f02:	60aa0a13          	addi	s4,s4,1546 # 80008508 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002f06:	2b893783          	ld	a5,696(s2)
    80002f0a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f0c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f10:	85d2                	mv	a1,s4
    80002f12:	01048513          	addi	a0,s1,16
    80002f16:	00001097          	auipc	ra,0x1
    80002f1a:	4ac080e7          	jalr	1196(ra) # 800043c2 <initsleeplock>
    bcache.head.next->prev = b;
    80002f1e:	2b893783          	ld	a5,696(s2)
    80002f22:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f24:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f28:	45848493          	addi	s1,s1,1112
    80002f2c:	fd349de3          	bne	s1,s3,80002f06 <binit+0x54>
  }
}
    80002f30:	70a2                	ld	ra,40(sp)
    80002f32:	7402                	ld	s0,32(sp)
    80002f34:	64e2                	ld	s1,24(sp)
    80002f36:	6942                	ld	s2,16(sp)
    80002f38:	69a2                	ld	s3,8(sp)
    80002f3a:	6a02                	ld	s4,0(sp)
    80002f3c:	6145                	addi	sp,sp,48
    80002f3e:	8082                	ret

0000000080002f40 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f40:	7179                	addi	sp,sp,-48
    80002f42:	f406                	sd	ra,40(sp)
    80002f44:	f022                	sd	s0,32(sp)
    80002f46:	ec26                	sd	s1,24(sp)
    80002f48:	e84a                	sd	s2,16(sp)
    80002f4a:	e44e                	sd	s3,8(sp)
    80002f4c:	1800                	addi	s0,sp,48
    80002f4e:	892a                	mv	s2,a0
    80002f50:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f52:	00015517          	auipc	a0,0x15
    80002f56:	a2e50513          	addi	a0,a0,-1490 # 80017980 <bcache>
    80002f5a:	ffffe097          	auipc	ra,0xffffe
    80002f5e:	cee080e7          	jalr	-786(ra) # 80000c48 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f62:	0001d497          	auipc	s1,0x1d
    80002f66:	cd64b483          	ld	s1,-810(s1) # 8001fc38 <bcache+0x82b8>
    80002f6a:	0001d797          	auipc	a5,0x1d
    80002f6e:	c7e78793          	addi	a5,a5,-898 # 8001fbe8 <bcache+0x8268>
    80002f72:	02f48f63          	beq	s1,a5,80002fb0 <bread+0x70>
    80002f76:	873e                	mv	a4,a5
    80002f78:	a021                	j	80002f80 <bread+0x40>
    80002f7a:	68a4                	ld	s1,80(s1)
    80002f7c:	02e48a63          	beq	s1,a4,80002fb0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f80:	449c                	lw	a5,8(s1)
    80002f82:	ff279ce3          	bne	a5,s2,80002f7a <bread+0x3a>
    80002f86:	44dc                	lw	a5,12(s1)
    80002f88:	ff3799e3          	bne	a5,s3,80002f7a <bread+0x3a>
      b->refcnt++;
    80002f8c:	40bc                	lw	a5,64(s1)
    80002f8e:	2785                	addiw	a5,a5,1
    80002f90:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f92:	00015517          	auipc	a0,0x15
    80002f96:	9ee50513          	addi	a0,a0,-1554 # 80017980 <bcache>
    80002f9a:	ffffe097          	auipc	ra,0xffffe
    80002f9e:	d62080e7          	jalr	-670(ra) # 80000cfc <release>
      acquiresleep(&b->lock);
    80002fa2:	01048513          	addi	a0,s1,16
    80002fa6:	00001097          	auipc	ra,0x1
    80002faa:	456080e7          	jalr	1110(ra) # 800043fc <acquiresleep>
      return b;
    80002fae:	a8b9                	j	8000300c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fb0:	0001d497          	auipc	s1,0x1d
    80002fb4:	c804b483          	ld	s1,-896(s1) # 8001fc30 <bcache+0x82b0>
    80002fb8:	0001d797          	auipc	a5,0x1d
    80002fbc:	c3078793          	addi	a5,a5,-976 # 8001fbe8 <bcache+0x8268>
    80002fc0:	00f48863          	beq	s1,a5,80002fd0 <bread+0x90>
    80002fc4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fc6:	40bc                	lw	a5,64(s1)
    80002fc8:	cf81                	beqz	a5,80002fe0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fca:	64a4                	ld	s1,72(s1)
    80002fcc:	fee49de3          	bne	s1,a4,80002fc6 <bread+0x86>
  panic("bget: no buffers");
    80002fd0:	00005517          	auipc	a0,0x5
    80002fd4:	54050513          	addi	a0,a0,1344 # 80008510 <syscalls+0xd0>
    80002fd8:	ffffd097          	auipc	ra,0xffffd
    80002fdc:	56a080e7          	jalr	1386(ra) # 80000542 <panic>
      b->dev = dev;
    80002fe0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fe4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fe8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fec:	4785                	li	a5,1
    80002fee:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ff0:	00015517          	auipc	a0,0x15
    80002ff4:	99050513          	addi	a0,a0,-1648 # 80017980 <bcache>
    80002ff8:	ffffe097          	auipc	ra,0xffffe
    80002ffc:	d04080e7          	jalr	-764(ra) # 80000cfc <release>
      acquiresleep(&b->lock);
    80003000:	01048513          	addi	a0,s1,16
    80003004:	00001097          	auipc	ra,0x1
    80003008:	3f8080e7          	jalr	1016(ra) # 800043fc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000300c:	409c                	lw	a5,0(s1)
    8000300e:	cb89                	beqz	a5,80003020 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003010:	8526                	mv	a0,s1
    80003012:	70a2                	ld	ra,40(sp)
    80003014:	7402                	ld	s0,32(sp)
    80003016:	64e2                	ld	s1,24(sp)
    80003018:	6942                	ld	s2,16(sp)
    8000301a:	69a2                	ld	s3,8(sp)
    8000301c:	6145                	addi	sp,sp,48
    8000301e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003020:	4581                	li	a1,0
    80003022:	8526                	mv	a0,s1
    80003024:	00003097          	auipc	ra,0x3
    80003028:	f28080e7          	jalr	-216(ra) # 80005f4c <virtio_disk_rw>
    b->valid = 1;
    8000302c:	4785                	li	a5,1
    8000302e:	c09c                	sw	a5,0(s1)
  return b;
    80003030:	b7c5                	j	80003010 <bread+0xd0>

0000000080003032 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003032:	1101                	addi	sp,sp,-32
    80003034:	ec06                	sd	ra,24(sp)
    80003036:	e822                	sd	s0,16(sp)
    80003038:	e426                	sd	s1,8(sp)
    8000303a:	1000                	addi	s0,sp,32
    8000303c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000303e:	0541                	addi	a0,a0,16
    80003040:	00001097          	auipc	ra,0x1
    80003044:	456080e7          	jalr	1110(ra) # 80004496 <holdingsleep>
    80003048:	cd01                	beqz	a0,80003060 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000304a:	4585                	li	a1,1
    8000304c:	8526                	mv	a0,s1
    8000304e:	00003097          	auipc	ra,0x3
    80003052:	efe080e7          	jalr	-258(ra) # 80005f4c <virtio_disk_rw>
}
    80003056:	60e2                	ld	ra,24(sp)
    80003058:	6442                	ld	s0,16(sp)
    8000305a:	64a2                	ld	s1,8(sp)
    8000305c:	6105                	addi	sp,sp,32
    8000305e:	8082                	ret
    panic("bwrite");
    80003060:	00005517          	auipc	a0,0x5
    80003064:	4c850513          	addi	a0,a0,1224 # 80008528 <syscalls+0xe8>
    80003068:	ffffd097          	auipc	ra,0xffffd
    8000306c:	4da080e7          	jalr	1242(ra) # 80000542 <panic>

0000000080003070 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003070:	1101                	addi	sp,sp,-32
    80003072:	ec06                	sd	ra,24(sp)
    80003074:	e822                	sd	s0,16(sp)
    80003076:	e426                	sd	s1,8(sp)
    80003078:	e04a                	sd	s2,0(sp)
    8000307a:	1000                	addi	s0,sp,32
    8000307c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000307e:	01050913          	addi	s2,a0,16
    80003082:	854a                	mv	a0,s2
    80003084:	00001097          	auipc	ra,0x1
    80003088:	412080e7          	jalr	1042(ra) # 80004496 <holdingsleep>
    8000308c:	c92d                	beqz	a0,800030fe <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000308e:	854a                	mv	a0,s2
    80003090:	00001097          	auipc	ra,0x1
    80003094:	3c2080e7          	jalr	962(ra) # 80004452 <releasesleep>

  acquire(&bcache.lock);
    80003098:	00015517          	auipc	a0,0x15
    8000309c:	8e850513          	addi	a0,a0,-1816 # 80017980 <bcache>
    800030a0:	ffffe097          	auipc	ra,0xffffe
    800030a4:	ba8080e7          	jalr	-1112(ra) # 80000c48 <acquire>
  b->refcnt--;
    800030a8:	40bc                	lw	a5,64(s1)
    800030aa:	37fd                	addiw	a5,a5,-1
    800030ac:	0007871b          	sext.w	a4,a5
    800030b0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030b2:	eb05                	bnez	a4,800030e2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030b4:	68bc                	ld	a5,80(s1)
    800030b6:	64b8                	ld	a4,72(s1)
    800030b8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800030ba:	64bc                	ld	a5,72(s1)
    800030bc:	68b8                	ld	a4,80(s1)
    800030be:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030c0:	0001d797          	auipc	a5,0x1d
    800030c4:	8c078793          	addi	a5,a5,-1856 # 8001f980 <bcache+0x8000>
    800030c8:	2b87b703          	ld	a4,696(a5)
    800030cc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030ce:	0001d717          	auipc	a4,0x1d
    800030d2:	b1a70713          	addi	a4,a4,-1254 # 8001fbe8 <bcache+0x8268>
    800030d6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030d8:	2b87b703          	ld	a4,696(a5)
    800030dc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030de:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030e2:	00015517          	auipc	a0,0x15
    800030e6:	89e50513          	addi	a0,a0,-1890 # 80017980 <bcache>
    800030ea:	ffffe097          	auipc	ra,0xffffe
    800030ee:	c12080e7          	jalr	-1006(ra) # 80000cfc <release>
}
    800030f2:	60e2                	ld	ra,24(sp)
    800030f4:	6442                	ld	s0,16(sp)
    800030f6:	64a2                	ld	s1,8(sp)
    800030f8:	6902                	ld	s2,0(sp)
    800030fa:	6105                	addi	sp,sp,32
    800030fc:	8082                	ret
    panic("brelse");
    800030fe:	00005517          	auipc	a0,0x5
    80003102:	43250513          	addi	a0,a0,1074 # 80008530 <syscalls+0xf0>
    80003106:	ffffd097          	auipc	ra,0xffffd
    8000310a:	43c080e7          	jalr	1084(ra) # 80000542 <panic>

000000008000310e <bpin>:

void
bpin(struct buf *b) {
    8000310e:	1101                	addi	sp,sp,-32
    80003110:	ec06                	sd	ra,24(sp)
    80003112:	e822                	sd	s0,16(sp)
    80003114:	e426                	sd	s1,8(sp)
    80003116:	1000                	addi	s0,sp,32
    80003118:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000311a:	00015517          	auipc	a0,0x15
    8000311e:	86650513          	addi	a0,a0,-1946 # 80017980 <bcache>
    80003122:	ffffe097          	auipc	ra,0xffffe
    80003126:	b26080e7          	jalr	-1242(ra) # 80000c48 <acquire>
  b->refcnt++;
    8000312a:	40bc                	lw	a5,64(s1)
    8000312c:	2785                	addiw	a5,a5,1
    8000312e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003130:	00015517          	auipc	a0,0x15
    80003134:	85050513          	addi	a0,a0,-1968 # 80017980 <bcache>
    80003138:	ffffe097          	auipc	ra,0xffffe
    8000313c:	bc4080e7          	jalr	-1084(ra) # 80000cfc <release>
}
    80003140:	60e2                	ld	ra,24(sp)
    80003142:	6442                	ld	s0,16(sp)
    80003144:	64a2                	ld	s1,8(sp)
    80003146:	6105                	addi	sp,sp,32
    80003148:	8082                	ret

000000008000314a <bunpin>:

void
bunpin(struct buf *b) {
    8000314a:	1101                	addi	sp,sp,-32
    8000314c:	ec06                	sd	ra,24(sp)
    8000314e:	e822                	sd	s0,16(sp)
    80003150:	e426                	sd	s1,8(sp)
    80003152:	1000                	addi	s0,sp,32
    80003154:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003156:	00015517          	auipc	a0,0x15
    8000315a:	82a50513          	addi	a0,a0,-2006 # 80017980 <bcache>
    8000315e:	ffffe097          	auipc	ra,0xffffe
    80003162:	aea080e7          	jalr	-1302(ra) # 80000c48 <acquire>
  b->refcnt--;
    80003166:	40bc                	lw	a5,64(s1)
    80003168:	37fd                	addiw	a5,a5,-1
    8000316a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000316c:	00015517          	auipc	a0,0x15
    80003170:	81450513          	addi	a0,a0,-2028 # 80017980 <bcache>
    80003174:	ffffe097          	auipc	ra,0xffffe
    80003178:	b88080e7          	jalr	-1144(ra) # 80000cfc <release>
}
    8000317c:	60e2                	ld	ra,24(sp)
    8000317e:	6442                	ld	s0,16(sp)
    80003180:	64a2                	ld	s1,8(sp)
    80003182:	6105                	addi	sp,sp,32
    80003184:	8082                	ret

0000000080003186 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003186:	1101                	addi	sp,sp,-32
    80003188:	ec06                	sd	ra,24(sp)
    8000318a:	e822                	sd	s0,16(sp)
    8000318c:	e426                	sd	s1,8(sp)
    8000318e:	e04a                	sd	s2,0(sp)
    80003190:	1000                	addi	s0,sp,32
    80003192:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003194:	00d5d59b          	srliw	a1,a1,0xd
    80003198:	0001d797          	auipc	a5,0x1d
    8000319c:	ec47a783          	lw	a5,-316(a5) # 8002005c <sb+0x1c>
    800031a0:	9dbd                	addw	a1,a1,a5
    800031a2:	00000097          	auipc	ra,0x0
    800031a6:	d9e080e7          	jalr	-610(ra) # 80002f40 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031aa:	0074f713          	andi	a4,s1,7
    800031ae:	4785                	li	a5,1
    800031b0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031b4:	14ce                	slli	s1,s1,0x33
    800031b6:	90d9                	srli	s1,s1,0x36
    800031b8:	00950733          	add	a4,a0,s1
    800031bc:	05874703          	lbu	a4,88(a4)
    800031c0:	00e7f6b3          	and	a3,a5,a4
    800031c4:	c69d                	beqz	a3,800031f2 <bfree+0x6c>
    800031c6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031c8:	94aa                	add	s1,s1,a0
    800031ca:	fff7c793          	not	a5,a5
    800031ce:	8ff9                	and	a5,a5,a4
    800031d0:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800031d4:	00001097          	auipc	ra,0x1
    800031d8:	100080e7          	jalr	256(ra) # 800042d4 <log_write>
  brelse(bp);
    800031dc:	854a                	mv	a0,s2
    800031de:	00000097          	auipc	ra,0x0
    800031e2:	e92080e7          	jalr	-366(ra) # 80003070 <brelse>
}
    800031e6:	60e2                	ld	ra,24(sp)
    800031e8:	6442                	ld	s0,16(sp)
    800031ea:	64a2                	ld	s1,8(sp)
    800031ec:	6902                	ld	s2,0(sp)
    800031ee:	6105                	addi	sp,sp,32
    800031f0:	8082                	ret
    panic("freeing free block");
    800031f2:	00005517          	auipc	a0,0x5
    800031f6:	34650513          	addi	a0,a0,838 # 80008538 <syscalls+0xf8>
    800031fa:	ffffd097          	auipc	ra,0xffffd
    800031fe:	348080e7          	jalr	840(ra) # 80000542 <panic>

0000000080003202 <balloc>:
{
    80003202:	711d                	addi	sp,sp,-96
    80003204:	ec86                	sd	ra,88(sp)
    80003206:	e8a2                	sd	s0,80(sp)
    80003208:	e4a6                	sd	s1,72(sp)
    8000320a:	e0ca                	sd	s2,64(sp)
    8000320c:	fc4e                	sd	s3,56(sp)
    8000320e:	f852                	sd	s4,48(sp)
    80003210:	f456                	sd	s5,40(sp)
    80003212:	f05a                	sd	s6,32(sp)
    80003214:	ec5e                	sd	s7,24(sp)
    80003216:	e862                	sd	s8,16(sp)
    80003218:	e466                	sd	s9,8(sp)
    8000321a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000321c:	0001d797          	auipc	a5,0x1d
    80003220:	e287a783          	lw	a5,-472(a5) # 80020044 <sb+0x4>
    80003224:	cbd1                	beqz	a5,800032b8 <balloc+0xb6>
    80003226:	8baa                	mv	s7,a0
    80003228:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000322a:	0001db17          	auipc	s6,0x1d
    8000322e:	e16b0b13          	addi	s6,s6,-490 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003232:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003234:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003236:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003238:	6c89                	lui	s9,0x2
    8000323a:	a831                	j	80003256 <balloc+0x54>
    brelse(bp);
    8000323c:	854a                	mv	a0,s2
    8000323e:	00000097          	auipc	ra,0x0
    80003242:	e32080e7          	jalr	-462(ra) # 80003070 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003246:	015c87bb          	addw	a5,s9,s5
    8000324a:	00078a9b          	sext.w	s5,a5
    8000324e:	004b2703          	lw	a4,4(s6)
    80003252:	06eaf363          	bgeu	s5,a4,800032b8 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003256:	41fad79b          	sraiw	a5,s5,0x1f
    8000325a:	0137d79b          	srliw	a5,a5,0x13
    8000325e:	015787bb          	addw	a5,a5,s5
    80003262:	40d7d79b          	sraiw	a5,a5,0xd
    80003266:	01cb2583          	lw	a1,28(s6)
    8000326a:	9dbd                	addw	a1,a1,a5
    8000326c:	855e                	mv	a0,s7
    8000326e:	00000097          	auipc	ra,0x0
    80003272:	cd2080e7          	jalr	-814(ra) # 80002f40 <bread>
    80003276:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003278:	004b2503          	lw	a0,4(s6)
    8000327c:	000a849b          	sext.w	s1,s5
    80003280:	8662                	mv	a2,s8
    80003282:	faa4fde3          	bgeu	s1,a0,8000323c <balloc+0x3a>
      m = 1 << (bi % 8);
    80003286:	41f6579b          	sraiw	a5,a2,0x1f
    8000328a:	01d7d69b          	srliw	a3,a5,0x1d
    8000328e:	00c6873b          	addw	a4,a3,a2
    80003292:	00777793          	andi	a5,a4,7
    80003296:	9f95                	subw	a5,a5,a3
    80003298:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000329c:	4037571b          	sraiw	a4,a4,0x3
    800032a0:	00e906b3          	add	a3,s2,a4
    800032a4:	0586c683          	lbu	a3,88(a3)
    800032a8:	00d7f5b3          	and	a1,a5,a3
    800032ac:	cd91                	beqz	a1,800032c8 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032ae:	2605                	addiw	a2,a2,1
    800032b0:	2485                	addiw	s1,s1,1
    800032b2:	fd4618e3          	bne	a2,s4,80003282 <balloc+0x80>
    800032b6:	b759                	j	8000323c <balloc+0x3a>
  panic("balloc: out of blocks");
    800032b8:	00005517          	auipc	a0,0x5
    800032bc:	29850513          	addi	a0,a0,664 # 80008550 <syscalls+0x110>
    800032c0:	ffffd097          	auipc	ra,0xffffd
    800032c4:	282080e7          	jalr	642(ra) # 80000542 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032c8:	974a                	add	a4,a4,s2
    800032ca:	8fd5                	or	a5,a5,a3
    800032cc:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800032d0:	854a                	mv	a0,s2
    800032d2:	00001097          	auipc	ra,0x1
    800032d6:	002080e7          	jalr	2(ra) # 800042d4 <log_write>
        brelse(bp);
    800032da:	854a                	mv	a0,s2
    800032dc:	00000097          	auipc	ra,0x0
    800032e0:	d94080e7          	jalr	-620(ra) # 80003070 <brelse>
  bp = bread(dev, bno);
    800032e4:	85a6                	mv	a1,s1
    800032e6:	855e                	mv	a0,s7
    800032e8:	00000097          	auipc	ra,0x0
    800032ec:	c58080e7          	jalr	-936(ra) # 80002f40 <bread>
    800032f0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032f2:	40000613          	li	a2,1024
    800032f6:	4581                	li	a1,0
    800032f8:	05850513          	addi	a0,a0,88
    800032fc:	ffffe097          	auipc	ra,0xffffe
    80003300:	a48080e7          	jalr	-1464(ra) # 80000d44 <memset>
  log_write(bp);
    80003304:	854a                	mv	a0,s2
    80003306:	00001097          	auipc	ra,0x1
    8000330a:	fce080e7          	jalr	-50(ra) # 800042d4 <log_write>
  brelse(bp);
    8000330e:	854a                	mv	a0,s2
    80003310:	00000097          	auipc	ra,0x0
    80003314:	d60080e7          	jalr	-672(ra) # 80003070 <brelse>
}
    80003318:	8526                	mv	a0,s1
    8000331a:	60e6                	ld	ra,88(sp)
    8000331c:	6446                	ld	s0,80(sp)
    8000331e:	64a6                	ld	s1,72(sp)
    80003320:	6906                	ld	s2,64(sp)
    80003322:	79e2                	ld	s3,56(sp)
    80003324:	7a42                	ld	s4,48(sp)
    80003326:	7aa2                	ld	s5,40(sp)
    80003328:	7b02                	ld	s6,32(sp)
    8000332a:	6be2                	ld	s7,24(sp)
    8000332c:	6c42                	ld	s8,16(sp)
    8000332e:	6ca2                	ld	s9,8(sp)
    80003330:	6125                	addi	sp,sp,96
    80003332:	8082                	ret

0000000080003334 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003334:	7179                	addi	sp,sp,-48
    80003336:	f406                	sd	ra,40(sp)
    80003338:	f022                	sd	s0,32(sp)
    8000333a:	ec26                	sd	s1,24(sp)
    8000333c:	e84a                	sd	s2,16(sp)
    8000333e:	e44e                	sd	s3,8(sp)
    80003340:	e052                	sd	s4,0(sp)
    80003342:	1800                	addi	s0,sp,48
    80003344:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003346:	47ad                	li	a5,11
    80003348:	04b7fe63          	bgeu	a5,a1,800033a4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000334c:	ff45849b          	addiw	s1,a1,-12
    80003350:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003354:	0ff00793          	li	a5,255
    80003358:	0ae7e363          	bltu	a5,a4,800033fe <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000335c:	08052583          	lw	a1,128(a0)
    80003360:	c5ad                	beqz	a1,800033ca <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003362:	00092503          	lw	a0,0(s2)
    80003366:	00000097          	auipc	ra,0x0
    8000336a:	bda080e7          	jalr	-1062(ra) # 80002f40 <bread>
    8000336e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003370:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003374:	02049593          	slli	a1,s1,0x20
    80003378:	9181                	srli	a1,a1,0x20
    8000337a:	058a                	slli	a1,a1,0x2
    8000337c:	00b784b3          	add	s1,a5,a1
    80003380:	0004a983          	lw	s3,0(s1)
    80003384:	04098d63          	beqz	s3,800033de <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003388:	8552                	mv	a0,s4
    8000338a:	00000097          	auipc	ra,0x0
    8000338e:	ce6080e7          	jalr	-794(ra) # 80003070 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003392:	854e                	mv	a0,s3
    80003394:	70a2                	ld	ra,40(sp)
    80003396:	7402                	ld	s0,32(sp)
    80003398:	64e2                	ld	s1,24(sp)
    8000339a:	6942                	ld	s2,16(sp)
    8000339c:	69a2                	ld	s3,8(sp)
    8000339e:	6a02                	ld	s4,0(sp)
    800033a0:	6145                	addi	sp,sp,48
    800033a2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033a4:	02059493          	slli	s1,a1,0x20
    800033a8:	9081                	srli	s1,s1,0x20
    800033aa:	048a                	slli	s1,s1,0x2
    800033ac:	94aa                	add	s1,s1,a0
    800033ae:	0504a983          	lw	s3,80(s1)
    800033b2:	fe0990e3          	bnez	s3,80003392 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800033b6:	4108                	lw	a0,0(a0)
    800033b8:	00000097          	auipc	ra,0x0
    800033bc:	e4a080e7          	jalr	-438(ra) # 80003202 <balloc>
    800033c0:	0005099b          	sext.w	s3,a0
    800033c4:	0534a823          	sw	s3,80(s1)
    800033c8:	b7e9                	j	80003392 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800033ca:	4108                	lw	a0,0(a0)
    800033cc:	00000097          	auipc	ra,0x0
    800033d0:	e36080e7          	jalr	-458(ra) # 80003202 <balloc>
    800033d4:	0005059b          	sext.w	a1,a0
    800033d8:	08b92023          	sw	a1,128(s2)
    800033dc:	b759                	j	80003362 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800033de:	00092503          	lw	a0,0(s2)
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	e20080e7          	jalr	-480(ra) # 80003202 <balloc>
    800033ea:	0005099b          	sext.w	s3,a0
    800033ee:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800033f2:	8552                	mv	a0,s4
    800033f4:	00001097          	auipc	ra,0x1
    800033f8:	ee0080e7          	jalr	-288(ra) # 800042d4 <log_write>
    800033fc:	b771                	j	80003388 <bmap+0x54>
  panic("bmap: out of range");
    800033fe:	00005517          	auipc	a0,0x5
    80003402:	16a50513          	addi	a0,a0,362 # 80008568 <syscalls+0x128>
    80003406:	ffffd097          	auipc	ra,0xffffd
    8000340a:	13c080e7          	jalr	316(ra) # 80000542 <panic>

000000008000340e <iget>:
{
    8000340e:	7179                	addi	sp,sp,-48
    80003410:	f406                	sd	ra,40(sp)
    80003412:	f022                	sd	s0,32(sp)
    80003414:	ec26                	sd	s1,24(sp)
    80003416:	e84a                	sd	s2,16(sp)
    80003418:	e44e                	sd	s3,8(sp)
    8000341a:	e052                	sd	s4,0(sp)
    8000341c:	1800                	addi	s0,sp,48
    8000341e:	89aa                	mv	s3,a0
    80003420:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003422:	0001d517          	auipc	a0,0x1d
    80003426:	c3e50513          	addi	a0,a0,-962 # 80020060 <icache>
    8000342a:	ffffe097          	auipc	ra,0xffffe
    8000342e:	81e080e7          	jalr	-2018(ra) # 80000c48 <acquire>
  empty = 0;
    80003432:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003434:	0001d497          	auipc	s1,0x1d
    80003438:	c4448493          	addi	s1,s1,-956 # 80020078 <icache+0x18>
    8000343c:	0001e697          	auipc	a3,0x1e
    80003440:	6cc68693          	addi	a3,a3,1740 # 80021b08 <log>
    80003444:	a039                	j	80003452 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003446:	02090b63          	beqz	s2,8000347c <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000344a:	08848493          	addi	s1,s1,136
    8000344e:	02d48a63          	beq	s1,a3,80003482 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003452:	449c                	lw	a5,8(s1)
    80003454:	fef059e3          	blez	a5,80003446 <iget+0x38>
    80003458:	4098                	lw	a4,0(s1)
    8000345a:	ff3716e3          	bne	a4,s3,80003446 <iget+0x38>
    8000345e:	40d8                	lw	a4,4(s1)
    80003460:	ff4713e3          	bne	a4,s4,80003446 <iget+0x38>
      ip->ref++;
    80003464:	2785                	addiw	a5,a5,1
    80003466:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003468:	0001d517          	auipc	a0,0x1d
    8000346c:	bf850513          	addi	a0,a0,-1032 # 80020060 <icache>
    80003470:	ffffe097          	auipc	ra,0xffffe
    80003474:	88c080e7          	jalr	-1908(ra) # 80000cfc <release>
      return ip;
    80003478:	8926                	mv	s2,s1
    8000347a:	a03d                	j	800034a8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000347c:	f7f9                	bnez	a5,8000344a <iget+0x3c>
    8000347e:	8926                	mv	s2,s1
    80003480:	b7e9                	j	8000344a <iget+0x3c>
  if(empty == 0)
    80003482:	02090c63          	beqz	s2,800034ba <iget+0xac>
  ip->dev = dev;
    80003486:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000348a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000348e:	4785                	li	a5,1
    80003490:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003494:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003498:	0001d517          	auipc	a0,0x1d
    8000349c:	bc850513          	addi	a0,a0,-1080 # 80020060 <icache>
    800034a0:	ffffe097          	auipc	ra,0xffffe
    800034a4:	85c080e7          	jalr	-1956(ra) # 80000cfc <release>
}
    800034a8:	854a                	mv	a0,s2
    800034aa:	70a2                	ld	ra,40(sp)
    800034ac:	7402                	ld	s0,32(sp)
    800034ae:	64e2                	ld	s1,24(sp)
    800034b0:	6942                	ld	s2,16(sp)
    800034b2:	69a2                	ld	s3,8(sp)
    800034b4:	6a02                	ld	s4,0(sp)
    800034b6:	6145                	addi	sp,sp,48
    800034b8:	8082                	ret
    panic("iget: no inodes");
    800034ba:	00005517          	auipc	a0,0x5
    800034be:	0c650513          	addi	a0,a0,198 # 80008580 <syscalls+0x140>
    800034c2:	ffffd097          	auipc	ra,0xffffd
    800034c6:	080080e7          	jalr	128(ra) # 80000542 <panic>

00000000800034ca <fsinit>:
fsinit(int dev) {
    800034ca:	7179                	addi	sp,sp,-48
    800034cc:	f406                	sd	ra,40(sp)
    800034ce:	f022                	sd	s0,32(sp)
    800034d0:	ec26                	sd	s1,24(sp)
    800034d2:	e84a                	sd	s2,16(sp)
    800034d4:	e44e                	sd	s3,8(sp)
    800034d6:	1800                	addi	s0,sp,48
    800034d8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034da:	4585                	li	a1,1
    800034dc:	00000097          	auipc	ra,0x0
    800034e0:	a64080e7          	jalr	-1436(ra) # 80002f40 <bread>
    800034e4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034e6:	0001d997          	auipc	s3,0x1d
    800034ea:	b5a98993          	addi	s3,s3,-1190 # 80020040 <sb>
    800034ee:	02000613          	li	a2,32
    800034f2:	05850593          	addi	a1,a0,88
    800034f6:	854e                	mv	a0,s3
    800034f8:	ffffe097          	auipc	ra,0xffffe
    800034fc:	8a8080e7          	jalr	-1880(ra) # 80000da0 <memmove>
  brelse(bp);
    80003500:	8526                	mv	a0,s1
    80003502:	00000097          	auipc	ra,0x0
    80003506:	b6e080e7          	jalr	-1170(ra) # 80003070 <brelse>
  if(sb.magic != FSMAGIC)
    8000350a:	0009a703          	lw	a4,0(s3)
    8000350e:	102037b7          	lui	a5,0x10203
    80003512:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003516:	02f71263          	bne	a4,a5,8000353a <fsinit+0x70>
  initlog(dev, &sb);
    8000351a:	0001d597          	auipc	a1,0x1d
    8000351e:	b2658593          	addi	a1,a1,-1242 # 80020040 <sb>
    80003522:	854a                	mv	a0,s2
    80003524:	00001097          	auipc	ra,0x1
    80003528:	b38080e7          	jalr	-1224(ra) # 8000405c <initlog>
}
    8000352c:	70a2                	ld	ra,40(sp)
    8000352e:	7402                	ld	s0,32(sp)
    80003530:	64e2                	ld	s1,24(sp)
    80003532:	6942                	ld	s2,16(sp)
    80003534:	69a2                	ld	s3,8(sp)
    80003536:	6145                	addi	sp,sp,48
    80003538:	8082                	ret
    panic("invalid file system");
    8000353a:	00005517          	auipc	a0,0x5
    8000353e:	05650513          	addi	a0,a0,86 # 80008590 <syscalls+0x150>
    80003542:	ffffd097          	auipc	ra,0xffffd
    80003546:	000080e7          	jalr	ra # 80000542 <panic>

000000008000354a <iinit>:
{
    8000354a:	7179                	addi	sp,sp,-48
    8000354c:	f406                	sd	ra,40(sp)
    8000354e:	f022                	sd	s0,32(sp)
    80003550:	ec26                	sd	s1,24(sp)
    80003552:	e84a                	sd	s2,16(sp)
    80003554:	e44e                	sd	s3,8(sp)
    80003556:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003558:	00005597          	auipc	a1,0x5
    8000355c:	05058593          	addi	a1,a1,80 # 800085a8 <syscalls+0x168>
    80003560:	0001d517          	auipc	a0,0x1d
    80003564:	b0050513          	addi	a0,a0,-1280 # 80020060 <icache>
    80003568:	ffffd097          	auipc	ra,0xffffd
    8000356c:	650080e7          	jalr	1616(ra) # 80000bb8 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003570:	0001d497          	auipc	s1,0x1d
    80003574:	b1848493          	addi	s1,s1,-1256 # 80020088 <icache+0x28>
    80003578:	0001e997          	auipc	s3,0x1e
    8000357c:	5a098993          	addi	s3,s3,1440 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003580:	00005917          	auipc	s2,0x5
    80003584:	03090913          	addi	s2,s2,48 # 800085b0 <syscalls+0x170>
    80003588:	85ca                	mv	a1,s2
    8000358a:	8526                	mv	a0,s1
    8000358c:	00001097          	auipc	ra,0x1
    80003590:	e36080e7          	jalr	-458(ra) # 800043c2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003594:	08848493          	addi	s1,s1,136
    80003598:	ff3498e3          	bne	s1,s3,80003588 <iinit+0x3e>
}
    8000359c:	70a2                	ld	ra,40(sp)
    8000359e:	7402                	ld	s0,32(sp)
    800035a0:	64e2                	ld	s1,24(sp)
    800035a2:	6942                	ld	s2,16(sp)
    800035a4:	69a2                	ld	s3,8(sp)
    800035a6:	6145                	addi	sp,sp,48
    800035a8:	8082                	ret

00000000800035aa <ialloc>:
{
    800035aa:	715d                	addi	sp,sp,-80
    800035ac:	e486                	sd	ra,72(sp)
    800035ae:	e0a2                	sd	s0,64(sp)
    800035b0:	fc26                	sd	s1,56(sp)
    800035b2:	f84a                	sd	s2,48(sp)
    800035b4:	f44e                	sd	s3,40(sp)
    800035b6:	f052                	sd	s4,32(sp)
    800035b8:	ec56                	sd	s5,24(sp)
    800035ba:	e85a                	sd	s6,16(sp)
    800035bc:	e45e                	sd	s7,8(sp)
    800035be:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800035c0:	0001d717          	auipc	a4,0x1d
    800035c4:	a8c72703          	lw	a4,-1396(a4) # 8002004c <sb+0xc>
    800035c8:	4785                	li	a5,1
    800035ca:	04e7fa63          	bgeu	a5,a4,8000361e <ialloc+0x74>
    800035ce:	8aaa                	mv	s5,a0
    800035d0:	8bae                	mv	s7,a1
    800035d2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035d4:	0001da17          	auipc	s4,0x1d
    800035d8:	a6ca0a13          	addi	s4,s4,-1428 # 80020040 <sb>
    800035dc:	00048b1b          	sext.w	s6,s1
    800035e0:	0044d793          	srli	a5,s1,0x4
    800035e4:	018a2583          	lw	a1,24(s4)
    800035e8:	9dbd                	addw	a1,a1,a5
    800035ea:	8556                	mv	a0,s5
    800035ec:	00000097          	auipc	ra,0x0
    800035f0:	954080e7          	jalr	-1708(ra) # 80002f40 <bread>
    800035f4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035f6:	05850993          	addi	s3,a0,88
    800035fa:	00f4f793          	andi	a5,s1,15
    800035fe:	079a                	slli	a5,a5,0x6
    80003600:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003602:	00099783          	lh	a5,0(s3)
    80003606:	c785                	beqz	a5,8000362e <ialloc+0x84>
    brelse(bp);
    80003608:	00000097          	auipc	ra,0x0
    8000360c:	a68080e7          	jalr	-1432(ra) # 80003070 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003610:	0485                	addi	s1,s1,1
    80003612:	00ca2703          	lw	a4,12(s4)
    80003616:	0004879b          	sext.w	a5,s1
    8000361a:	fce7e1e3          	bltu	a5,a4,800035dc <ialloc+0x32>
  panic("ialloc: no inodes");
    8000361e:	00005517          	auipc	a0,0x5
    80003622:	f9a50513          	addi	a0,a0,-102 # 800085b8 <syscalls+0x178>
    80003626:	ffffd097          	auipc	ra,0xffffd
    8000362a:	f1c080e7          	jalr	-228(ra) # 80000542 <panic>
      memset(dip, 0, sizeof(*dip));
    8000362e:	04000613          	li	a2,64
    80003632:	4581                	li	a1,0
    80003634:	854e                	mv	a0,s3
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	70e080e7          	jalr	1806(ra) # 80000d44 <memset>
      dip->type = type;
    8000363e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003642:	854a                	mv	a0,s2
    80003644:	00001097          	auipc	ra,0x1
    80003648:	c90080e7          	jalr	-880(ra) # 800042d4 <log_write>
      brelse(bp);
    8000364c:	854a                	mv	a0,s2
    8000364e:	00000097          	auipc	ra,0x0
    80003652:	a22080e7          	jalr	-1502(ra) # 80003070 <brelse>
      return iget(dev, inum);
    80003656:	85da                	mv	a1,s6
    80003658:	8556                	mv	a0,s5
    8000365a:	00000097          	auipc	ra,0x0
    8000365e:	db4080e7          	jalr	-588(ra) # 8000340e <iget>
}
    80003662:	60a6                	ld	ra,72(sp)
    80003664:	6406                	ld	s0,64(sp)
    80003666:	74e2                	ld	s1,56(sp)
    80003668:	7942                	ld	s2,48(sp)
    8000366a:	79a2                	ld	s3,40(sp)
    8000366c:	7a02                	ld	s4,32(sp)
    8000366e:	6ae2                	ld	s5,24(sp)
    80003670:	6b42                	ld	s6,16(sp)
    80003672:	6ba2                	ld	s7,8(sp)
    80003674:	6161                	addi	sp,sp,80
    80003676:	8082                	ret

0000000080003678 <iupdate>:
{
    80003678:	1101                	addi	sp,sp,-32
    8000367a:	ec06                	sd	ra,24(sp)
    8000367c:	e822                	sd	s0,16(sp)
    8000367e:	e426                	sd	s1,8(sp)
    80003680:	e04a                	sd	s2,0(sp)
    80003682:	1000                	addi	s0,sp,32
    80003684:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003686:	415c                	lw	a5,4(a0)
    80003688:	0047d79b          	srliw	a5,a5,0x4
    8000368c:	0001d597          	auipc	a1,0x1d
    80003690:	9cc5a583          	lw	a1,-1588(a1) # 80020058 <sb+0x18>
    80003694:	9dbd                	addw	a1,a1,a5
    80003696:	4108                	lw	a0,0(a0)
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	8a8080e7          	jalr	-1880(ra) # 80002f40 <bread>
    800036a0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036a2:	05850793          	addi	a5,a0,88
    800036a6:	40c8                	lw	a0,4(s1)
    800036a8:	893d                	andi	a0,a0,15
    800036aa:	051a                	slli	a0,a0,0x6
    800036ac:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800036ae:	04449703          	lh	a4,68(s1)
    800036b2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800036b6:	04649703          	lh	a4,70(s1)
    800036ba:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800036be:	04849703          	lh	a4,72(s1)
    800036c2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800036c6:	04a49703          	lh	a4,74(s1)
    800036ca:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800036ce:	44f8                	lw	a4,76(s1)
    800036d0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036d2:	03400613          	li	a2,52
    800036d6:	05048593          	addi	a1,s1,80
    800036da:	0531                	addi	a0,a0,12
    800036dc:	ffffd097          	auipc	ra,0xffffd
    800036e0:	6c4080e7          	jalr	1732(ra) # 80000da0 <memmove>
  log_write(bp);
    800036e4:	854a                	mv	a0,s2
    800036e6:	00001097          	auipc	ra,0x1
    800036ea:	bee080e7          	jalr	-1042(ra) # 800042d4 <log_write>
  brelse(bp);
    800036ee:	854a                	mv	a0,s2
    800036f0:	00000097          	auipc	ra,0x0
    800036f4:	980080e7          	jalr	-1664(ra) # 80003070 <brelse>
}
    800036f8:	60e2                	ld	ra,24(sp)
    800036fa:	6442                	ld	s0,16(sp)
    800036fc:	64a2                	ld	s1,8(sp)
    800036fe:	6902                	ld	s2,0(sp)
    80003700:	6105                	addi	sp,sp,32
    80003702:	8082                	ret

0000000080003704 <idup>:
{
    80003704:	1101                	addi	sp,sp,-32
    80003706:	ec06                	sd	ra,24(sp)
    80003708:	e822                	sd	s0,16(sp)
    8000370a:	e426                	sd	s1,8(sp)
    8000370c:	1000                	addi	s0,sp,32
    8000370e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003710:	0001d517          	auipc	a0,0x1d
    80003714:	95050513          	addi	a0,a0,-1712 # 80020060 <icache>
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	530080e7          	jalr	1328(ra) # 80000c48 <acquire>
  ip->ref++;
    80003720:	449c                	lw	a5,8(s1)
    80003722:	2785                	addiw	a5,a5,1
    80003724:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003726:	0001d517          	auipc	a0,0x1d
    8000372a:	93a50513          	addi	a0,a0,-1734 # 80020060 <icache>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	5ce080e7          	jalr	1486(ra) # 80000cfc <release>
}
    80003736:	8526                	mv	a0,s1
    80003738:	60e2                	ld	ra,24(sp)
    8000373a:	6442                	ld	s0,16(sp)
    8000373c:	64a2                	ld	s1,8(sp)
    8000373e:	6105                	addi	sp,sp,32
    80003740:	8082                	ret

0000000080003742 <ilock>:
{
    80003742:	1101                	addi	sp,sp,-32
    80003744:	ec06                	sd	ra,24(sp)
    80003746:	e822                	sd	s0,16(sp)
    80003748:	e426                	sd	s1,8(sp)
    8000374a:	e04a                	sd	s2,0(sp)
    8000374c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000374e:	c115                	beqz	a0,80003772 <ilock+0x30>
    80003750:	84aa                	mv	s1,a0
    80003752:	451c                	lw	a5,8(a0)
    80003754:	00f05f63          	blez	a5,80003772 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003758:	0541                	addi	a0,a0,16
    8000375a:	00001097          	auipc	ra,0x1
    8000375e:	ca2080e7          	jalr	-862(ra) # 800043fc <acquiresleep>
  if(ip->valid == 0){
    80003762:	40bc                	lw	a5,64(s1)
    80003764:	cf99                	beqz	a5,80003782 <ilock+0x40>
}
    80003766:	60e2                	ld	ra,24(sp)
    80003768:	6442                	ld	s0,16(sp)
    8000376a:	64a2                	ld	s1,8(sp)
    8000376c:	6902                	ld	s2,0(sp)
    8000376e:	6105                	addi	sp,sp,32
    80003770:	8082                	ret
    panic("ilock");
    80003772:	00005517          	auipc	a0,0x5
    80003776:	e5e50513          	addi	a0,a0,-418 # 800085d0 <syscalls+0x190>
    8000377a:	ffffd097          	auipc	ra,0xffffd
    8000377e:	dc8080e7          	jalr	-568(ra) # 80000542 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003782:	40dc                	lw	a5,4(s1)
    80003784:	0047d79b          	srliw	a5,a5,0x4
    80003788:	0001d597          	auipc	a1,0x1d
    8000378c:	8d05a583          	lw	a1,-1840(a1) # 80020058 <sb+0x18>
    80003790:	9dbd                	addw	a1,a1,a5
    80003792:	4088                	lw	a0,0(s1)
    80003794:	fffff097          	auipc	ra,0xfffff
    80003798:	7ac080e7          	jalr	1964(ra) # 80002f40 <bread>
    8000379c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000379e:	05850593          	addi	a1,a0,88
    800037a2:	40dc                	lw	a5,4(s1)
    800037a4:	8bbd                	andi	a5,a5,15
    800037a6:	079a                	slli	a5,a5,0x6
    800037a8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037aa:	00059783          	lh	a5,0(a1)
    800037ae:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037b2:	00259783          	lh	a5,2(a1)
    800037b6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037ba:	00459783          	lh	a5,4(a1)
    800037be:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037c2:	00659783          	lh	a5,6(a1)
    800037c6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037ca:	459c                	lw	a5,8(a1)
    800037cc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037ce:	03400613          	li	a2,52
    800037d2:	05b1                	addi	a1,a1,12
    800037d4:	05048513          	addi	a0,s1,80
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	5c8080e7          	jalr	1480(ra) # 80000da0 <memmove>
    brelse(bp);
    800037e0:	854a                	mv	a0,s2
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	88e080e7          	jalr	-1906(ra) # 80003070 <brelse>
    ip->valid = 1;
    800037ea:	4785                	li	a5,1
    800037ec:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037ee:	04449783          	lh	a5,68(s1)
    800037f2:	fbb5                	bnez	a5,80003766 <ilock+0x24>
      panic("ilock: no type");
    800037f4:	00005517          	auipc	a0,0x5
    800037f8:	de450513          	addi	a0,a0,-540 # 800085d8 <syscalls+0x198>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	d46080e7          	jalr	-698(ra) # 80000542 <panic>

0000000080003804 <iunlock>:
{
    80003804:	1101                	addi	sp,sp,-32
    80003806:	ec06                	sd	ra,24(sp)
    80003808:	e822                	sd	s0,16(sp)
    8000380a:	e426                	sd	s1,8(sp)
    8000380c:	e04a                	sd	s2,0(sp)
    8000380e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003810:	c905                	beqz	a0,80003840 <iunlock+0x3c>
    80003812:	84aa                	mv	s1,a0
    80003814:	01050913          	addi	s2,a0,16
    80003818:	854a                	mv	a0,s2
    8000381a:	00001097          	auipc	ra,0x1
    8000381e:	c7c080e7          	jalr	-900(ra) # 80004496 <holdingsleep>
    80003822:	cd19                	beqz	a0,80003840 <iunlock+0x3c>
    80003824:	449c                	lw	a5,8(s1)
    80003826:	00f05d63          	blez	a5,80003840 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000382a:	854a                	mv	a0,s2
    8000382c:	00001097          	auipc	ra,0x1
    80003830:	c26080e7          	jalr	-986(ra) # 80004452 <releasesleep>
}
    80003834:	60e2                	ld	ra,24(sp)
    80003836:	6442                	ld	s0,16(sp)
    80003838:	64a2                	ld	s1,8(sp)
    8000383a:	6902                	ld	s2,0(sp)
    8000383c:	6105                	addi	sp,sp,32
    8000383e:	8082                	ret
    panic("iunlock");
    80003840:	00005517          	auipc	a0,0x5
    80003844:	da850513          	addi	a0,a0,-600 # 800085e8 <syscalls+0x1a8>
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	cfa080e7          	jalr	-774(ra) # 80000542 <panic>

0000000080003850 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003850:	7179                	addi	sp,sp,-48
    80003852:	f406                	sd	ra,40(sp)
    80003854:	f022                	sd	s0,32(sp)
    80003856:	ec26                	sd	s1,24(sp)
    80003858:	e84a                	sd	s2,16(sp)
    8000385a:	e44e                	sd	s3,8(sp)
    8000385c:	e052                	sd	s4,0(sp)
    8000385e:	1800                	addi	s0,sp,48
    80003860:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003862:	05050493          	addi	s1,a0,80
    80003866:	08050913          	addi	s2,a0,128
    8000386a:	a021                	j	80003872 <itrunc+0x22>
    8000386c:	0491                	addi	s1,s1,4
    8000386e:	01248d63          	beq	s1,s2,80003888 <itrunc+0x38>
    if(ip->addrs[i]){
    80003872:	408c                	lw	a1,0(s1)
    80003874:	dde5                	beqz	a1,8000386c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003876:	0009a503          	lw	a0,0(s3)
    8000387a:	00000097          	auipc	ra,0x0
    8000387e:	90c080e7          	jalr	-1780(ra) # 80003186 <bfree>
      ip->addrs[i] = 0;
    80003882:	0004a023          	sw	zero,0(s1)
    80003886:	b7dd                	j	8000386c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003888:	0809a583          	lw	a1,128(s3)
    8000388c:	e185                	bnez	a1,800038ac <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000388e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003892:	854e                	mv	a0,s3
    80003894:	00000097          	auipc	ra,0x0
    80003898:	de4080e7          	jalr	-540(ra) # 80003678 <iupdate>
}
    8000389c:	70a2                	ld	ra,40(sp)
    8000389e:	7402                	ld	s0,32(sp)
    800038a0:	64e2                	ld	s1,24(sp)
    800038a2:	6942                	ld	s2,16(sp)
    800038a4:	69a2                	ld	s3,8(sp)
    800038a6:	6a02                	ld	s4,0(sp)
    800038a8:	6145                	addi	sp,sp,48
    800038aa:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038ac:	0009a503          	lw	a0,0(s3)
    800038b0:	fffff097          	auipc	ra,0xfffff
    800038b4:	690080e7          	jalr	1680(ra) # 80002f40 <bread>
    800038b8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038ba:	05850493          	addi	s1,a0,88
    800038be:	45850913          	addi	s2,a0,1112
    800038c2:	a021                	j	800038ca <itrunc+0x7a>
    800038c4:	0491                	addi	s1,s1,4
    800038c6:	01248b63          	beq	s1,s2,800038dc <itrunc+0x8c>
      if(a[j])
    800038ca:	408c                	lw	a1,0(s1)
    800038cc:	dde5                	beqz	a1,800038c4 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800038ce:	0009a503          	lw	a0,0(s3)
    800038d2:	00000097          	auipc	ra,0x0
    800038d6:	8b4080e7          	jalr	-1868(ra) # 80003186 <bfree>
    800038da:	b7ed                	j	800038c4 <itrunc+0x74>
    brelse(bp);
    800038dc:	8552                	mv	a0,s4
    800038de:	fffff097          	auipc	ra,0xfffff
    800038e2:	792080e7          	jalr	1938(ra) # 80003070 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038e6:	0809a583          	lw	a1,128(s3)
    800038ea:	0009a503          	lw	a0,0(s3)
    800038ee:	00000097          	auipc	ra,0x0
    800038f2:	898080e7          	jalr	-1896(ra) # 80003186 <bfree>
    ip->addrs[NDIRECT] = 0;
    800038f6:	0809a023          	sw	zero,128(s3)
    800038fa:	bf51                	j	8000388e <itrunc+0x3e>

00000000800038fc <iput>:
{
    800038fc:	1101                	addi	sp,sp,-32
    800038fe:	ec06                	sd	ra,24(sp)
    80003900:	e822                	sd	s0,16(sp)
    80003902:	e426                	sd	s1,8(sp)
    80003904:	e04a                	sd	s2,0(sp)
    80003906:	1000                	addi	s0,sp,32
    80003908:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000390a:	0001c517          	auipc	a0,0x1c
    8000390e:	75650513          	addi	a0,a0,1878 # 80020060 <icache>
    80003912:	ffffd097          	auipc	ra,0xffffd
    80003916:	336080e7          	jalr	822(ra) # 80000c48 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000391a:	4498                	lw	a4,8(s1)
    8000391c:	4785                	li	a5,1
    8000391e:	02f70363          	beq	a4,a5,80003944 <iput+0x48>
  ip->ref--;
    80003922:	449c                	lw	a5,8(s1)
    80003924:	37fd                	addiw	a5,a5,-1
    80003926:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003928:	0001c517          	auipc	a0,0x1c
    8000392c:	73850513          	addi	a0,a0,1848 # 80020060 <icache>
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	3cc080e7          	jalr	972(ra) # 80000cfc <release>
}
    80003938:	60e2                	ld	ra,24(sp)
    8000393a:	6442                	ld	s0,16(sp)
    8000393c:	64a2                	ld	s1,8(sp)
    8000393e:	6902                	ld	s2,0(sp)
    80003940:	6105                	addi	sp,sp,32
    80003942:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003944:	40bc                	lw	a5,64(s1)
    80003946:	dff1                	beqz	a5,80003922 <iput+0x26>
    80003948:	04a49783          	lh	a5,74(s1)
    8000394c:	fbf9                	bnez	a5,80003922 <iput+0x26>
    acquiresleep(&ip->lock);
    8000394e:	01048913          	addi	s2,s1,16
    80003952:	854a                	mv	a0,s2
    80003954:	00001097          	auipc	ra,0x1
    80003958:	aa8080e7          	jalr	-1368(ra) # 800043fc <acquiresleep>
    release(&icache.lock);
    8000395c:	0001c517          	auipc	a0,0x1c
    80003960:	70450513          	addi	a0,a0,1796 # 80020060 <icache>
    80003964:	ffffd097          	auipc	ra,0xffffd
    80003968:	398080e7          	jalr	920(ra) # 80000cfc <release>
    itrunc(ip);
    8000396c:	8526                	mv	a0,s1
    8000396e:	00000097          	auipc	ra,0x0
    80003972:	ee2080e7          	jalr	-286(ra) # 80003850 <itrunc>
    ip->type = 0;
    80003976:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000397a:	8526                	mv	a0,s1
    8000397c:	00000097          	auipc	ra,0x0
    80003980:	cfc080e7          	jalr	-772(ra) # 80003678 <iupdate>
    ip->valid = 0;
    80003984:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003988:	854a                	mv	a0,s2
    8000398a:	00001097          	auipc	ra,0x1
    8000398e:	ac8080e7          	jalr	-1336(ra) # 80004452 <releasesleep>
    acquire(&icache.lock);
    80003992:	0001c517          	auipc	a0,0x1c
    80003996:	6ce50513          	addi	a0,a0,1742 # 80020060 <icache>
    8000399a:	ffffd097          	auipc	ra,0xffffd
    8000399e:	2ae080e7          	jalr	686(ra) # 80000c48 <acquire>
    800039a2:	b741                	j	80003922 <iput+0x26>

00000000800039a4 <iunlockput>:
{
    800039a4:	1101                	addi	sp,sp,-32
    800039a6:	ec06                	sd	ra,24(sp)
    800039a8:	e822                	sd	s0,16(sp)
    800039aa:	e426                	sd	s1,8(sp)
    800039ac:	1000                	addi	s0,sp,32
    800039ae:	84aa                	mv	s1,a0
  iunlock(ip);
    800039b0:	00000097          	auipc	ra,0x0
    800039b4:	e54080e7          	jalr	-428(ra) # 80003804 <iunlock>
  iput(ip);
    800039b8:	8526                	mv	a0,s1
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	f42080e7          	jalr	-190(ra) # 800038fc <iput>
}
    800039c2:	60e2                	ld	ra,24(sp)
    800039c4:	6442                	ld	s0,16(sp)
    800039c6:	64a2                	ld	s1,8(sp)
    800039c8:	6105                	addi	sp,sp,32
    800039ca:	8082                	ret

00000000800039cc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039cc:	1141                	addi	sp,sp,-16
    800039ce:	e422                	sd	s0,8(sp)
    800039d0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039d2:	411c                	lw	a5,0(a0)
    800039d4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039d6:	415c                	lw	a5,4(a0)
    800039d8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039da:	04451783          	lh	a5,68(a0)
    800039de:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039e2:	04a51783          	lh	a5,74(a0)
    800039e6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039ea:	04c56783          	lwu	a5,76(a0)
    800039ee:	e99c                	sd	a5,16(a1)
}
    800039f0:	6422                	ld	s0,8(sp)
    800039f2:	0141                	addi	sp,sp,16
    800039f4:	8082                	ret

00000000800039f6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039f6:	457c                	lw	a5,76(a0)
    800039f8:	0ed7e863          	bltu	a5,a3,80003ae8 <readi+0xf2>
{
    800039fc:	7159                	addi	sp,sp,-112
    800039fe:	f486                	sd	ra,104(sp)
    80003a00:	f0a2                	sd	s0,96(sp)
    80003a02:	eca6                	sd	s1,88(sp)
    80003a04:	e8ca                	sd	s2,80(sp)
    80003a06:	e4ce                	sd	s3,72(sp)
    80003a08:	e0d2                	sd	s4,64(sp)
    80003a0a:	fc56                	sd	s5,56(sp)
    80003a0c:	f85a                	sd	s6,48(sp)
    80003a0e:	f45e                	sd	s7,40(sp)
    80003a10:	f062                	sd	s8,32(sp)
    80003a12:	ec66                	sd	s9,24(sp)
    80003a14:	e86a                	sd	s10,16(sp)
    80003a16:	e46e                	sd	s11,8(sp)
    80003a18:	1880                	addi	s0,sp,112
    80003a1a:	8baa                	mv	s7,a0
    80003a1c:	8c2e                	mv	s8,a1
    80003a1e:	8ab2                	mv	s5,a2
    80003a20:	84b6                	mv	s1,a3
    80003a22:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a24:	9f35                	addw	a4,a4,a3
    return 0;
    80003a26:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a28:	08d76f63          	bltu	a4,a3,80003ac6 <readi+0xd0>
  if(off + n > ip->size)
    80003a2c:	00e7f463          	bgeu	a5,a4,80003a34 <readi+0x3e>
    n = ip->size - off;
    80003a30:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a34:	0a0b0863          	beqz	s6,80003ae4 <readi+0xee>
    80003a38:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a3a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a3e:	5cfd                	li	s9,-1
    80003a40:	a82d                	j	80003a7a <readi+0x84>
    80003a42:	020a1d93          	slli	s11,s4,0x20
    80003a46:	020ddd93          	srli	s11,s11,0x20
    80003a4a:	05890793          	addi	a5,s2,88
    80003a4e:	86ee                	mv	a3,s11
    80003a50:	963e                	add	a2,a2,a5
    80003a52:	85d6                	mv	a1,s5
    80003a54:	8562                	mv	a0,s8
    80003a56:	fffff097          	auipc	ra,0xfffff
    80003a5a:	a30080e7          	jalr	-1488(ra) # 80002486 <either_copyout>
    80003a5e:	05950d63          	beq	a0,s9,80003ab8 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003a62:	854a                	mv	a0,s2
    80003a64:	fffff097          	auipc	ra,0xfffff
    80003a68:	60c080e7          	jalr	1548(ra) # 80003070 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a6c:	013a09bb          	addw	s3,s4,s3
    80003a70:	009a04bb          	addw	s1,s4,s1
    80003a74:	9aee                	add	s5,s5,s11
    80003a76:	0569f663          	bgeu	s3,s6,80003ac2 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a7a:	000ba903          	lw	s2,0(s7)
    80003a7e:	00a4d59b          	srliw	a1,s1,0xa
    80003a82:	855e                	mv	a0,s7
    80003a84:	00000097          	auipc	ra,0x0
    80003a88:	8b0080e7          	jalr	-1872(ra) # 80003334 <bmap>
    80003a8c:	0005059b          	sext.w	a1,a0
    80003a90:	854a                	mv	a0,s2
    80003a92:	fffff097          	auipc	ra,0xfffff
    80003a96:	4ae080e7          	jalr	1198(ra) # 80002f40 <bread>
    80003a9a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a9c:	3ff4f613          	andi	a2,s1,1023
    80003aa0:	40cd07bb          	subw	a5,s10,a2
    80003aa4:	413b073b          	subw	a4,s6,s3
    80003aa8:	8a3e                	mv	s4,a5
    80003aaa:	2781                	sext.w	a5,a5
    80003aac:	0007069b          	sext.w	a3,a4
    80003ab0:	f8f6f9e3          	bgeu	a3,a5,80003a42 <readi+0x4c>
    80003ab4:	8a3a                	mv	s4,a4
    80003ab6:	b771                	j	80003a42 <readi+0x4c>
      brelse(bp);
    80003ab8:	854a                	mv	a0,s2
    80003aba:	fffff097          	auipc	ra,0xfffff
    80003abe:	5b6080e7          	jalr	1462(ra) # 80003070 <brelse>
  }
  return tot;
    80003ac2:	0009851b          	sext.w	a0,s3
}
    80003ac6:	70a6                	ld	ra,104(sp)
    80003ac8:	7406                	ld	s0,96(sp)
    80003aca:	64e6                	ld	s1,88(sp)
    80003acc:	6946                	ld	s2,80(sp)
    80003ace:	69a6                	ld	s3,72(sp)
    80003ad0:	6a06                	ld	s4,64(sp)
    80003ad2:	7ae2                	ld	s5,56(sp)
    80003ad4:	7b42                	ld	s6,48(sp)
    80003ad6:	7ba2                	ld	s7,40(sp)
    80003ad8:	7c02                	ld	s8,32(sp)
    80003ada:	6ce2                	ld	s9,24(sp)
    80003adc:	6d42                	ld	s10,16(sp)
    80003ade:	6da2                	ld	s11,8(sp)
    80003ae0:	6165                	addi	sp,sp,112
    80003ae2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ae4:	89da                	mv	s3,s6
    80003ae6:	bff1                	j	80003ac2 <readi+0xcc>
    return 0;
    80003ae8:	4501                	li	a0,0
}
    80003aea:	8082                	ret

0000000080003aec <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aec:	457c                	lw	a5,76(a0)
    80003aee:	10d7e663          	bltu	a5,a3,80003bfa <writei+0x10e>
{
    80003af2:	7159                	addi	sp,sp,-112
    80003af4:	f486                	sd	ra,104(sp)
    80003af6:	f0a2                	sd	s0,96(sp)
    80003af8:	eca6                	sd	s1,88(sp)
    80003afa:	e8ca                	sd	s2,80(sp)
    80003afc:	e4ce                	sd	s3,72(sp)
    80003afe:	e0d2                	sd	s4,64(sp)
    80003b00:	fc56                	sd	s5,56(sp)
    80003b02:	f85a                	sd	s6,48(sp)
    80003b04:	f45e                	sd	s7,40(sp)
    80003b06:	f062                	sd	s8,32(sp)
    80003b08:	ec66                	sd	s9,24(sp)
    80003b0a:	e86a                	sd	s10,16(sp)
    80003b0c:	e46e                	sd	s11,8(sp)
    80003b0e:	1880                	addi	s0,sp,112
    80003b10:	8baa                	mv	s7,a0
    80003b12:	8c2e                	mv	s8,a1
    80003b14:	8ab2                	mv	s5,a2
    80003b16:	8936                	mv	s2,a3
    80003b18:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b1a:	00e687bb          	addw	a5,a3,a4
    80003b1e:	0ed7e063          	bltu	a5,a3,80003bfe <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b22:	00043737          	lui	a4,0x43
    80003b26:	0cf76e63          	bltu	a4,a5,80003c02 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b2a:	0a0b0763          	beqz	s6,80003bd8 <writei+0xec>
    80003b2e:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b30:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b34:	5cfd                	li	s9,-1
    80003b36:	a091                	j	80003b7a <writei+0x8e>
    80003b38:	02099d93          	slli	s11,s3,0x20
    80003b3c:	020ddd93          	srli	s11,s11,0x20
    80003b40:	05848793          	addi	a5,s1,88
    80003b44:	86ee                	mv	a3,s11
    80003b46:	8656                	mv	a2,s5
    80003b48:	85e2                	mv	a1,s8
    80003b4a:	953e                	add	a0,a0,a5
    80003b4c:	fffff097          	auipc	ra,0xfffff
    80003b50:	990080e7          	jalr	-1648(ra) # 800024dc <either_copyin>
    80003b54:	07950263          	beq	a0,s9,80003bb8 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b58:	8526                	mv	a0,s1
    80003b5a:	00000097          	auipc	ra,0x0
    80003b5e:	77a080e7          	jalr	1914(ra) # 800042d4 <log_write>
    brelse(bp);
    80003b62:	8526                	mv	a0,s1
    80003b64:	fffff097          	auipc	ra,0xfffff
    80003b68:	50c080e7          	jalr	1292(ra) # 80003070 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b6c:	01498a3b          	addw	s4,s3,s4
    80003b70:	0129893b          	addw	s2,s3,s2
    80003b74:	9aee                	add	s5,s5,s11
    80003b76:	056a7663          	bgeu	s4,s6,80003bc2 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b7a:	000ba483          	lw	s1,0(s7)
    80003b7e:	00a9559b          	srliw	a1,s2,0xa
    80003b82:	855e                	mv	a0,s7
    80003b84:	fffff097          	auipc	ra,0xfffff
    80003b88:	7b0080e7          	jalr	1968(ra) # 80003334 <bmap>
    80003b8c:	0005059b          	sext.w	a1,a0
    80003b90:	8526                	mv	a0,s1
    80003b92:	fffff097          	auipc	ra,0xfffff
    80003b96:	3ae080e7          	jalr	942(ra) # 80002f40 <bread>
    80003b9a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b9c:	3ff97513          	andi	a0,s2,1023
    80003ba0:	40ad07bb          	subw	a5,s10,a0
    80003ba4:	414b073b          	subw	a4,s6,s4
    80003ba8:	89be                	mv	s3,a5
    80003baa:	2781                	sext.w	a5,a5
    80003bac:	0007069b          	sext.w	a3,a4
    80003bb0:	f8f6f4e3          	bgeu	a3,a5,80003b38 <writei+0x4c>
    80003bb4:	89ba                	mv	s3,a4
    80003bb6:	b749                	j	80003b38 <writei+0x4c>
      brelse(bp);
    80003bb8:	8526                	mv	a0,s1
    80003bba:	fffff097          	auipc	ra,0xfffff
    80003bbe:	4b6080e7          	jalr	1206(ra) # 80003070 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003bc2:	04cba783          	lw	a5,76(s7)
    80003bc6:	0127f463          	bgeu	a5,s2,80003bce <writei+0xe2>
      ip->size = off;
    80003bca:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003bce:	855e                	mv	a0,s7
    80003bd0:	00000097          	auipc	ra,0x0
    80003bd4:	aa8080e7          	jalr	-1368(ra) # 80003678 <iupdate>
  }

  return n;
    80003bd8:	000b051b          	sext.w	a0,s6
}
    80003bdc:	70a6                	ld	ra,104(sp)
    80003bde:	7406                	ld	s0,96(sp)
    80003be0:	64e6                	ld	s1,88(sp)
    80003be2:	6946                	ld	s2,80(sp)
    80003be4:	69a6                	ld	s3,72(sp)
    80003be6:	6a06                	ld	s4,64(sp)
    80003be8:	7ae2                	ld	s5,56(sp)
    80003bea:	7b42                	ld	s6,48(sp)
    80003bec:	7ba2                	ld	s7,40(sp)
    80003bee:	7c02                	ld	s8,32(sp)
    80003bf0:	6ce2                	ld	s9,24(sp)
    80003bf2:	6d42                	ld	s10,16(sp)
    80003bf4:	6da2                	ld	s11,8(sp)
    80003bf6:	6165                	addi	sp,sp,112
    80003bf8:	8082                	ret
    return -1;
    80003bfa:	557d                	li	a0,-1
}
    80003bfc:	8082                	ret
    return -1;
    80003bfe:	557d                	li	a0,-1
    80003c00:	bff1                	j	80003bdc <writei+0xf0>
    return -1;
    80003c02:	557d                	li	a0,-1
    80003c04:	bfe1                	j	80003bdc <writei+0xf0>

0000000080003c06 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c06:	1141                	addi	sp,sp,-16
    80003c08:	e406                	sd	ra,8(sp)
    80003c0a:	e022                	sd	s0,0(sp)
    80003c0c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c0e:	4639                	li	a2,14
    80003c10:	ffffd097          	auipc	ra,0xffffd
    80003c14:	20c080e7          	jalr	524(ra) # 80000e1c <strncmp>
}
    80003c18:	60a2                	ld	ra,8(sp)
    80003c1a:	6402                	ld	s0,0(sp)
    80003c1c:	0141                	addi	sp,sp,16
    80003c1e:	8082                	ret

0000000080003c20 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c20:	7139                	addi	sp,sp,-64
    80003c22:	fc06                	sd	ra,56(sp)
    80003c24:	f822                	sd	s0,48(sp)
    80003c26:	f426                	sd	s1,40(sp)
    80003c28:	f04a                	sd	s2,32(sp)
    80003c2a:	ec4e                	sd	s3,24(sp)
    80003c2c:	e852                	sd	s4,16(sp)
    80003c2e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c30:	04451703          	lh	a4,68(a0)
    80003c34:	4785                	li	a5,1
    80003c36:	00f71a63          	bne	a4,a5,80003c4a <dirlookup+0x2a>
    80003c3a:	892a                	mv	s2,a0
    80003c3c:	89ae                	mv	s3,a1
    80003c3e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c40:	457c                	lw	a5,76(a0)
    80003c42:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c44:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c46:	e79d                	bnez	a5,80003c74 <dirlookup+0x54>
    80003c48:	a8a5                	j	80003cc0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c4a:	00005517          	auipc	a0,0x5
    80003c4e:	9a650513          	addi	a0,a0,-1626 # 800085f0 <syscalls+0x1b0>
    80003c52:	ffffd097          	auipc	ra,0xffffd
    80003c56:	8f0080e7          	jalr	-1808(ra) # 80000542 <panic>
      panic("dirlookup read");
    80003c5a:	00005517          	auipc	a0,0x5
    80003c5e:	9ae50513          	addi	a0,a0,-1618 # 80008608 <syscalls+0x1c8>
    80003c62:	ffffd097          	auipc	ra,0xffffd
    80003c66:	8e0080e7          	jalr	-1824(ra) # 80000542 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c6a:	24c1                	addiw	s1,s1,16
    80003c6c:	04c92783          	lw	a5,76(s2)
    80003c70:	04f4f763          	bgeu	s1,a5,80003cbe <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c74:	4741                	li	a4,16
    80003c76:	86a6                	mv	a3,s1
    80003c78:	fc040613          	addi	a2,s0,-64
    80003c7c:	4581                	li	a1,0
    80003c7e:	854a                	mv	a0,s2
    80003c80:	00000097          	auipc	ra,0x0
    80003c84:	d76080e7          	jalr	-650(ra) # 800039f6 <readi>
    80003c88:	47c1                	li	a5,16
    80003c8a:	fcf518e3          	bne	a0,a5,80003c5a <dirlookup+0x3a>
    if(de.inum == 0)
    80003c8e:	fc045783          	lhu	a5,-64(s0)
    80003c92:	dfe1                	beqz	a5,80003c6a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c94:	fc240593          	addi	a1,s0,-62
    80003c98:	854e                	mv	a0,s3
    80003c9a:	00000097          	auipc	ra,0x0
    80003c9e:	f6c080e7          	jalr	-148(ra) # 80003c06 <namecmp>
    80003ca2:	f561                	bnez	a0,80003c6a <dirlookup+0x4a>
      if(poff)
    80003ca4:	000a0463          	beqz	s4,80003cac <dirlookup+0x8c>
        *poff = off;
    80003ca8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cac:	fc045583          	lhu	a1,-64(s0)
    80003cb0:	00092503          	lw	a0,0(s2)
    80003cb4:	fffff097          	auipc	ra,0xfffff
    80003cb8:	75a080e7          	jalr	1882(ra) # 8000340e <iget>
    80003cbc:	a011                	j	80003cc0 <dirlookup+0xa0>
  return 0;
    80003cbe:	4501                	li	a0,0
}
    80003cc0:	70e2                	ld	ra,56(sp)
    80003cc2:	7442                	ld	s0,48(sp)
    80003cc4:	74a2                	ld	s1,40(sp)
    80003cc6:	7902                	ld	s2,32(sp)
    80003cc8:	69e2                	ld	s3,24(sp)
    80003cca:	6a42                	ld	s4,16(sp)
    80003ccc:	6121                	addi	sp,sp,64
    80003cce:	8082                	ret

0000000080003cd0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cd0:	711d                	addi	sp,sp,-96
    80003cd2:	ec86                	sd	ra,88(sp)
    80003cd4:	e8a2                	sd	s0,80(sp)
    80003cd6:	e4a6                	sd	s1,72(sp)
    80003cd8:	e0ca                	sd	s2,64(sp)
    80003cda:	fc4e                	sd	s3,56(sp)
    80003cdc:	f852                	sd	s4,48(sp)
    80003cde:	f456                	sd	s5,40(sp)
    80003ce0:	f05a                	sd	s6,32(sp)
    80003ce2:	ec5e                	sd	s7,24(sp)
    80003ce4:	e862                	sd	s8,16(sp)
    80003ce6:	e466                	sd	s9,8(sp)
    80003ce8:	1080                	addi	s0,sp,96
    80003cea:	84aa                	mv	s1,a0
    80003cec:	8aae                	mv	s5,a1
    80003cee:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cf0:	00054703          	lbu	a4,0(a0)
    80003cf4:	02f00793          	li	a5,47
    80003cf8:	02f70363          	beq	a4,a5,80003d1e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cfc:	ffffe097          	auipc	ra,0xffffe
    80003d00:	d18080e7          	jalr	-744(ra) # 80001a14 <myproc>
    80003d04:	15053503          	ld	a0,336(a0)
    80003d08:	00000097          	auipc	ra,0x0
    80003d0c:	9fc080e7          	jalr	-1540(ra) # 80003704 <idup>
    80003d10:	89aa                	mv	s3,a0
  while(*path == '/')
    80003d12:	02f00913          	li	s2,47
  len = path - s;
    80003d16:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003d18:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d1a:	4b85                	li	s7,1
    80003d1c:	a865                	j	80003dd4 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003d1e:	4585                	li	a1,1
    80003d20:	4505                	li	a0,1
    80003d22:	fffff097          	auipc	ra,0xfffff
    80003d26:	6ec080e7          	jalr	1772(ra) # 8000340e <iget>
    80003d2a:	89aa                	mv	s3,a0
    80003d2c:	b7dd                	j	80003d12 <namex+0x42>
      iunlockput(ip);
    80003d2e:	854e                	mv	a0,s3
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	c74080e7          	jalr	-908(ra) # 800039a4 <iunlockput>
      return 0;
    80003d38:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d3a:	854e                	mv	a0,s3
    80003d3c:	60e6                	ld	ra,88(sp)
    80003d3e:	6446                	ld	s0,80(sp)
    80003d40:	64a6                	ld	s1,72(sp)
    80003d42:	6906                	ld	s2,64(sp)
    80003d44:	79e2                	ld	s3,56(sp)
    80003d46:	7a42                	ld	s4,48(sp)
    80003d48:	7aa2                	ld	s5,40(sp)
    80003d4a:	7b02                	ld	s6,32(sp)
    80003d4c:	6be2                	ld	s7,24(sp)
    80003d4e:	6c42                	ld	s8,16(sp)
    80003d50:	6ca2                	ld	s9,8(sp)
    80003d52:	6125                	addi	sp,sp,96
    80003d54:	8082                	ret
      iunlock(ip);
    80003d56:	854e                	mv	a0,s3
    80003d58:	00000097          	auipc	ra,0x0
    80003d5c:	aac080e7          	jalr	-1364(ra) # 80003804 <iunlock>
      return ip;
    80003d60:	bfe9                	j	80003d3a <namex+0x6a>
      iunlockput(ip);
    80003d62:	854e                	mv	a0,s3
    80003d64:	00000097          	auipc	ra,0x0
    80003d68:	c40080e7          	jalr	-960(ra) # 800039a4 <iunlockput>
      return 0;
    80003d6c:	89e6                	mv	s3,s9
    80003d6e:	b7f1                	j	80003d3a <namex+0x6a>
  len = path - s;
    80003d70:	40b48633          	sub	a2,s1,a1
    80003d74:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d78:	099c5463          	bge	s8,s9,80003e00 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d7c:	4639                	li	a2,14
    80003d7e:	8552                	mv	a0,s4
    80003d80:	ffffd097          	auipc	ra,0xffffd
    80003d84:	020080e7          	jalr	32(ra) # 80000da0 <memmove>
  while(*path == '/')
    80003d88:	0004c783          	lbu	a5,0(s1)
    80003d8c:	01279763          	bne	a5,s2,80003d9a <namex+0xca>
    path++;
    80003d90:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d92:	0004c783          	lbu	a5,0(s1)
    80003d96:	ff278de3          	beq	a5,s2,80003d90 <namex+0xc0>
    ilock(ip);
    80003d9a:	854e                	mv	a0,s3
    80003d9c:	00000097          	auipc	ra,0x0
    80003da0:	9a6080e7          	jalr	-1626(ra) # 80003742 <ilock>
    if(ip->type != T_DIR){
    80003da4:	04499783          	lh	a5,68(s3)
    80003da8:	f97793e3          	bne	a5,s7,80003d2e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003dac:	000a8563          	beqz	s5,80003db6 <namex+0xe6>
    80003db0:	0004c783          	lbu	a5,0(s1)
    80003db4:	d3cd                	beqz	a5,80003d56 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003db6:	865a                	mv	a2,s6
    80003db8:	85d2                	mv	a1,s4
    80003dba:	854e                	mv	a0,s3
    80003dbc:	00000097          	auipc	ra,0x0
    80003dc0:	e64080e7          	jalr	-412(ra) # 80003c20 <dirlookup>
    80003dc4:	8caa                	mv	s9,a0
    80003dc6:	dd51                	beqz	a0,80003d62 <namex+0x92>
    iunlockput(ip);
    80003dc8:	854e                	mv	a0,s3
    80003dca:	00000097          	auipc	ra,0x0
    80003dce:	bda080e7          	jalr	-1062(ra) # 800039a4 <iunlockput>
    ip = next;
    80003dd2:	89e6                	mv	s3,s9
  while(*path == '/')
    80003dd4:	0004c783          	lbu	a5,0(s1)
    80003dd8:	05279763          	bne	a5,s2,80003e26 <namex+0x156>
    path++;
    80003ddc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dde:	0004c783          	lbu	a5,0(s1)
    80003de2:	ff278de3          	beq	a5,s2,80003ddc <namex+0x10c>
  if(*path == 0)
    80003de6:	c79d                	beqz	a5,80003e14 <namex+0x144>
    path++;
    80003de8:	85a6                	mv	a1,s1
  len = path - s;
    80003dea:	8cda                	mv	s9,s6
    80003dec:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003dee:	01278963          	beq	a5,s2,80003e00 <namex+0x130>
    80003df2:	dfbd                	beqz	a5,80003d70 <namex+0xa0>
    path++;
    80003df4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003df6:	0004c783          	lbu	a5,0(s1)
    80003dfa:	ff279ce3          	bne	a5,s2,80003df2 <namex+0x122>
    80003dfe:	bf8d                	j	80003d70 <namex+0xa0>
    memmove(name, s, len);
    80003e00:	2601                	sext.w	a2,a2
    80003e02:	8552                	mv	a0,s4
    80003e04:	ffffd097          	auipc	ra,0xffffd
    80003e08:	f9c080e7          	jalr	-100(ra) # 80000da0 <memmove>
    name[len] = 0;
    80003e0c:	9cd2                	add	s9,s9,s4
    80003e0e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e12:	bf9d                	j	80003d88 <namex+0xb8>
  if(nameiparent){
    80003e14:	f20a83e3          	beqz	s5,80003d3a <namex+0x6a>
    iput(ip);
    80003e18:	854e                	mv	a0,s3
    80003e1a:	00000097          	auipc	ra,0x0
    80003e1e:	ae2080e7          	jalr	-1310(ra) # 800038fc <iput>
    return 0;
    80003e22:	4981                	li	s3,0
    80003e24:	bf19                	j	80003d3a <namex+0x6a>
  if(*path == 0)
    80003e26:	d7fd                	beqz	a5,80003e14 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e28:	0004c783          	lbu	a5,0(s1)
    80003e2c:	85a6                	mv	a1,s1
    80003e2e:	b7d1                	j	80003df2 <namex+0x122>

0000000080003e30 <dirlink>:
{
    80003e30:	7139                	addi	sp,sp,-64
    80003e32:	fc06                	sd	ra,56(sp)
    80003e34:	f822                	sd	s0,48(sp)
    80003e36:	f426                	sd	s1,40(sp)
    80003e38:	f04a                	sd	s2,32(sp)
    80003e3a:	ec4e                	sd	s3,24(sp)
    80003e3c:	e852                	sd	s4,16(sp)
    80003e3e:	0080                	addi	s0,sp,64
    80003e40:	892a                	mv	s2,a0
    80003e42:	8a2e                	mv	s4,a1
    80003e44:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e46:	4601                	li	a2,0
    80003e48:	00000097          	auipc	ra,0x0
    80003e4c:	dd8080e7          	jalr	-552(ra) # 80003c20 <dirlookup>
    80003e50:	e93d                	bnez	a0,80003ec6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e52:	04c92483          	lw	s1,76(s2)
    80003e56:	c49d                	beqz	s1,80003e84 <dirlink+0x54>
    80003e58:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e5a:	4741                	li	a4,16
    80003e5c:	86a6                	mv	a3,s1
    80003e5e:	fc040613          	addi	a2,s0,-64
    80003e62:	4581                	li	a1,0
    80003e64:	854a                	mv	a0,s2
    80003e66:	00000097          	auipc	ra,0x0
    80003e6a:	b90080e7          	jalr	-1136(ra) # 800039f6 <readi>
    80003e6e:	47c1                	li	a5,16
    80003e70:	06f51163          	bne	a0,a5,80003ed2 <dirlink+0xa2>
    if(de.inum == 0)
    80003e74:	fc045783          	lhu	a5,-64(s0)
    80003e78:	c791                	beqz	a5,80003e84 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e7a:	24c1                	addiw	s1,s1,16
    80003e7c:	04c92783          	lw	a5,76(s2)
    80003e80:	fcf4ede3          	bltu	s1,a5,80003e5a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e84:	4639                	li	a2,14
    80003e86:	85d2                	mv	a1,s4
    80003e88:	fc240513          	addi	a0,s0,-62
    80003e8c:	ffffd097          	auipc	ra,0xffffd
    80003e90:	fcc080e7          	jalr	-52(ra) # 80000e58 <strncpy>
  de.inum = inum;
    80003e94:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e98:	4741                	li	a4,16
    80003e9a:	86a6                	mv	a3,s1
    80003e9c:	fc040613          	addi	a2,s0,-64
    80003ea0:	4581                	li	a1,0
    80003ea2:	854a                	mv	a0,s2
    80003ea4:	00000097          	auipc	ra,0x0
    80003ea8:	c48080e7          	jalr	-952(ra) # 80003aec <writei>
    80003eac:	872a                	mv	a4,a0
    80003eae:	47c1                	li	a5,16
  return 0;
    80003eb0:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eb2:	02f71863          	bne	a4,a5,80003ee2 <dirlink+0xb2>
}
    80003eb6:	70e2                	ld	ra,56(sp)
    80003eb8:	7442                	ld	s0,48(sp)
    80003eba:	74a2                	ld	s1,40(sp)
    80003ebc:	7902                	ld	s2,32(sp)
    80003ebe:	69e2                	ld	s3,24(sp)
    80003ec0:	6a42                	ld	s4,16(sp)
    80003ec2:	6121                	addi	sp,sp,64
    80003ec4:	8082                	ret
    iput(ip);
    80003ec6:	00000097          	auipc	ra,0x0
    80003eca:	a36080e7          	jalr	-1482(ra) # 800038fc <iput>
    return -1;
    80003ece:	557d                	li	a0,-1
    80003ed0:	b7dd                	j	80003eb6 <dirlink+0x86>
      panic("dirlink read");
    80003ed2:	00004517          	auipc	a0,0x4
    80003ed6:	74650513          	addi	a0,a0,1862 # 80008618 <syscalls+0x1d8>
    80003eda:	ffffc097          	auipc	ra,0xffffc
    80003ede:	668080e7          	jalr	1640(ra) # 80000542 <panic>
    panic("dirlink");
    80003ee2:	00005517          	auipc	a0,0x5
    80003ee6:	85650513          	addi	a0,a0,-1962 # 80008738 <syscalls+0x2f8>
    80003eea:	ffffc097          	auipc	ra,0xffffc
    80003eee:	658080e7          	jalr	1624(ra) # 80000542 <panic>

0000000080003ef2 <namei>:

struct inode*
namei(char *path)
{
    80003ef2:	1101                	addi	sp,sp,-32
    80003ef4:	ec06                	sd	ra,24(sp)
    80003ef6:	e822                	sd	s0,16(sp)
    80003ef8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003efa:	fe040613          	addi	a2,s0,-32
    80003efe:	4581                	li	a1,0
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	dd0080e7          	jalr	-560(ra) # 80003cd0 <namex>
}
    80003f08:	60e2                	ld	ra,24(sp)
    80003f0a:	6442                	ld	s0,16(sp)
    80003f0c:	6105                	addi	sp,sp,32
    80003f0e:	8082                	ret

0000000080003f10 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f10:	1141                	addi	sp,sp,-16
    80003f12:	e406                	sd	ra,8(sp)
    80003f14:	e022                	sd	s0,0(sp)
    80003f16:	0800                	addi	s0,sp,16
    80003f18:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f1a:	4585                	li	a1,1
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	db4080e7          	jalr	-588(ra) # 80003cd0 <namex>
}
    80003f24:	60a2                	ld	ra,8(sp)
    80003f26:	6402                	ld	s0,0(sp)
    80003f28:	0141                	addi	sp,sp,16
    80003f2a:	8082                	ret

0000000080003f2c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f2c:	1101                	addi	sp,sp,-32
    80003f2e:	ec06                	sd	ra,24(sp)
    80003f30:	e822                	sd	s0,16(sp)
    80003f32:	e426                	sd	s1,8(sp)
    80003f34:	e04a                	sd	s2,0(sp)
    80003f36:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f38:	0001e917          	auipc	s2,0x1e
    80003f3c:	bd090913          	addi	s2,s2,-1072 # 80021b08 <log>
    80003f40:	01892583          	lw	a1,24(s2)
    80003f44:	02892503          	lw	a0,40(s2)
    80003f48:	fffff097          	auipc	ra,0xfffff
    80003f4c:	ff8080e7          	jalr	-8(ra) # 80002f40 <bread>
    80003f50:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f52:	02c92683          	lw	a3,44(s2)
    80003f56:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f58:	02d05763          	blez	a3,80003f86 <write_head+0x5a>
    80003f5c:	0001e797          	auipc	a5,0x1e
    80003f60:	bdc78793          	addi	a5,a5,-1060 # 80021b38 <log+0x30>
    80003f64:	05c50713          	addi	a4,a0,92
    80003f68:	36fd                	addiw	a3,a3,-1
    80003f6a:	1682                	slli	a3,a3,0x20
    80003f6c:	9281                	srli	a3,a3,0x20
    80003f6e:	068a                	slli	a3,a3,0x2
    80003f70:	0001e617          	auipc	a2,0x1e
    80003f74:	bcc60613          	addi	a2,a2,-1076 # 80021b3c <log+0x34>
    80003f78:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f7a:	4390                	lw	a2,0(a5)
    80003f7c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f7e:	0791                	addi	a5,a5,4
    80003f80:	0711                	addi	a4,a4,4
    80003f82:	fed79ce3          	bne	a5,a3,80003f7a <write_head+0x4e>
  }
  bwrite(buf);
    80003f86:	8526                	mv	a0,s1
    80003f88:	fffff097          	auipc	ra,0xfffff
    80003f8c:	0aa080e7          	jalr	170(ra) # 80003032 <bwrite>
  brelse(buf);
    80003f90:	8526                	mv	a0,s1
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	0de080e7          	jalr	222(ra) # 80003070 <brelse>
}
    80003f9a:	60e2                	ld	ra,24(sp)
    80003f9c:	6442                	ld	s0,16(sp)
    80003f9e:	64a2                	ld	s1,8(sp)
    80003fa0:	6902                	ld	s2,0(sp)
    80003fa2:	6105                	addi	sp,sp,32
    80003fa4:	8082                	ret

0000000080003fa6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fa6:	0001e797          	auipc	a5,0x1e
    80003faa:	b8e7a783          	lw	a5,-1138(a5) # 80021b34 <log+0x2c>
    80003fae:	0af05663          	blez	a5,8000405a <install_trans+0xb4>
{
    80003fb2:	7139                	addi	sp,sp,-64
    80003fb4:	fc06                	sd	ra,56(sp)
    80003fb6:	f822                	sd	s0,48(sp)
    80003fb8:	f426                	sd	s1,40(sp)
    80003fba:	f04a                	sd	s2,32(sp)
    80003fbc:	ec4e                	sd	s3,24(sp)
    80003fbe:	e852                	sd	s4,16(sp)
    80003fc0:	e456                	sd	s5,8(sp)
    80003fc2:	0080                	addi	s0,sp,64
    80003fc4:	0001ea97          	auipc	s5,0x1e
    80003fc8:	b74a8a93          	addi	s5,s5,-1164 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fcc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fce:	0001e997          	auipc	s3,0x1e
    80003fd2:	b3a98993          	addi	s3,s3,-1222 # 80021b08 <log>
    80003fd6:	0189a583          	lw	a1,24(s3)
    80003fda:	014585bb          	addw	a1,a1,s4
    80003fde:	2585                	addiw	a1,a1,1
    80003fe0:	0289a503          	lw	a0,40(s3)
    80003fe4:	fffff097          	auipc	ra,0xfffff
    80003fe8:	f5c080e7          	jalr	-164(ra) # 80002f40 <bread>
    80003fec:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fee:	000aa583          	lw	a1,0(s5)
    80003ff2:	0289a503          	lw	a0,40(s3)
    80003ff6:	fffff097          	auipc	ra,0xfffff
    80003ffa:	f4a080e7          	jalr	-182(ra) # 80002f40 <bread>
    80003ffe:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004000:	40000613          	li	a2,1024
    80004004:	05890593          	addi	a1,s2,88
    80004008:	05850513          	addi	a0,a0,88
    8000400c:	ffffd097          	auipc	ra,0xffffd
    80004010:	d94080e7          	jalr	-620(ra) # 80000da0 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004014:	8526                	mv	a0,s1
    80004016:	fffff097          	auipc	ra,0xfffff
    8000401a:	01c080e7          	jalr	28(ra) # 80003032 <bwrite>
    bunpin(dbuf);
    8000401e:	8526                	mv	a0,s1
    80004020:	fffff097          	auipc	ra,0xfffff
    80004024:	12a080e7          	jalr	298(ra) # 8000314a <bunpin>
    brelse(lbuf);
    80004028:	854a                	mv	a0,s2
    8000402a:	fffff097          	auipc	ra,0xfffff
    8000402e:	046080e7          	jalr	70(ra) # 80003070 <brelse>
    brelse(dbuf);
    80004032:	8526                	mv	a0,s1
    80004034:	fffff097          	auipc	ra,0xfffff
    80004038:	03c080e7          	jalr	60(ra) # 80003070 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000403c:	2a05                	addiw	s4,s4,1
    8000403e:	0a91                	addi	s5,s5,4
    80004040:	02c9a783          	lw	a5,44(s3)
    80004044:	f8fa49e3          	blt	s4,a5,80003fd6 <install_trans+0x30>
}
    80004048:	70e2                	ld	ra,56(sp)
    8000404a:	7442                	ld	s0,48(sp)
    8000404c:	74a2                	ld	s1,40(sp)
    8000404e:	7902                	ld	s2,32(sp)
    80004050:	69e2                	ld	s3,24(sp)
    80004052:	6a42                	ld	s4,16(sp)
    80004054:	6aa2                	ld	s5,8(sp)
    80004056:	6121                	addi	sp,sp,64
    80004058:	8082                	ret
    8000405a:	8082                	ret

000000008000405c <initlog>:
{
    8000405c:	7179                	addi	sp,sp,-48
    8000405e:	f406                	sd	ra,40(sp)
    80004060:	f022                	sd	s0,32(sp)
    80004062:	ec26                	sd	s1,24(sp)
    80004064:	e84a                	sd	s2,16(sp)
    80004066:	e44e                	sd	s3,8(sp)
    80004068:	1800                	addi	s0,sp,48
    8000406a:	892a                	mv	s2,a0
    8000406c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000406e:	0001e497          	auipc	s1,0x1e
    80004072:	a9a48493          	addi	s1,s1,-1382 # 80021b08 <log>
    80004076:	00004597          	auipc	a1,0x4
    8000407a:	5b258593          	addi	a1,a1,1458 # 80008628 <syscalls+0x1e8>
    8000407e:	8526                	mv	a0,s1
    80004080:	ffffd097          	auipc	ra,0xffffd
    80004084:	b38080e7          	jalr	-1224(ra) # 80000bb8 <initlock>
  log.start = sb->logstart;
    80004088:	0149a583          	lw	a1,20(s3)
    8000408c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000408e:	0109a783          	lw	a5,16(s3)
    80004092:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004094:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004098:	854a                	mv	a0,s2
    8000409a:	fffff097          	auipc	ra,0xfffff
    8000409e:	ea6080e7          	jalr	-346(ra) # 80002f40 <bread>
  log.lh.n = lh->n;
    800040a2:	4d34                	lw	a3,88(a0)
    800040a4:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040a6:	02d05563          	blez	a3,800040d0 <initlog+0x74>
    800040aa:	05c50793          	addi	a5,a0,92
    800040ae:	0001e717          	auipc	a4,0x1e
    800040b2:	a8a70713          	addi	a4,a4,-1398 # 80021b38 <log+0x30>
    800040b6:	36fd                	addiw	a3,a3,-1
    800040b8:	1682                	slli	a3,a3,0x20
    800040ba:	9281                	srli	a3,a3,0x20
    800040bc:	068a                	slli	a3,a3,0x2
    800040be:	06050613          	addi	a2,a0,96
    800040c2:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800040c4:	4390                	lw	a2,0(a5)
    800040c6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040c8:	0791                	addi	a5,a5,4
    800040ca:	0711                	addi	a4,a4,4
    800040cc:	fed79ce3          	bne	a5,a3,800040c4 <initlog+0x68>
  brelse(buf);
    800040d0:	fffff097          	auipc	ra,0xfffff
    800040d4:	fa0080e7          	jalr	-96(ra) # 80003070 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800040d8:	00000097          	auipc	ra,0x0
    800040dc:	ece080e7          	jalr	-306(ra) # 80003fa6 <install_trans>
  log.lh.n = 0;
    800040e0:	0001e797          	auipc	a5,0x1e
    800040e4:	a407aa23          	sw	zero,-1452(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	e44080e7          	jalr	-444(ra) # 80003f2c <write_head>
}
    800040f0:	70a2                	ld	ra,40(sp)
    800040f2:	7402                	ld	s0,32(sp)
    800040f4:	64e2                	ld	s1,24(sp)
    800040f6:	6942                	ld	s2,16(sp)
    800040f8:	69a2                	ld	s3,8(sp)
    800040fa:	6145                	addi	sp,sp,48
    800040fc:	8082                	ret

00000000800040fe <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040fe:	1101                	addi	sp,sp,-32
    80004100:	ec06                	sd	ra,24(sp)
    80004102:	e822                	sd	s0,16(sp)
    80004104:	e426                	sd	s1,8(sp)
    80004106:	e04a                	sd	s2,0(sp)
    80004108:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000410a:	0001e517          	auipc	a0,0x1e
    8000410e:	9fe50513          	addi	a0,a0,-1538 # 80021b08 <log>
    80004112:	ffffd097          	auipc	ra,0xffffd
    80004116:	b36080e7          	jalr	-1226(ra) # 80000c48 <acquire>
  while(1){
    if(log.committing){
    8000411a:	0001e497          	auipc	s1,0x1e
    8000411e:	9ee48493          	addi	s1,s1,-1554 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004122:	4979                	li	s2,30
    80004124:	a039                	j	80004132 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004126:	85a6                	mv	a1,s1
    80004128:	8526                	mv	a0,s1
    8000412a:	ffffe097          	auipc	ra,0xffffe
    8000412e:	102080e7          	jalr	258(ra) # 8000222c <sleep>
    if(log.committing){
    80004132:	50dc                	lw	a5,36(s1)
    80004134:	fbed                	bnez	a5,80004126 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004136:	509c                	lw	a5,32(s1)
    80004138:	0017871b          	addiw	a4,a5,1
    8000413c:	0007069b          	sext.w	a3,a4
    80004140:	0027179b          	slliw	a5,a4,0x2
    80004144:	9fb9                	addw	a5,a5,a4
    80004146:	0017979b          	slliw	a5,a5,0x1
    8000414a:	54d8                	lw	a4,44(s1)
    8000414c:	9fb9                	addw	a5,a5,a4
    8000414e:	00f95963          	bge	s2,a5,80004160 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004152:	85a6                	mv	a1,s1
    80004154:	8526                	mv	a0,s1
    80004156:	ffffe097          	auipc	ra,0xffffe
    8000415a:	0d6080e7          	jalr	214(ra) # 8000222c <sleep>
    8000415e:	bfd1                	j	80004132 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004160:	0001e517          	auipc	a0,0x1e
    80004164:	9a850513          	addi	a0,a0,-1624 # 80021b08 <log>
    80004168:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000416a:	ffffd097          	auipc	ra,0xffffd
    8000416e:	b92080e7          	jalr	-1134(ra) # 80000cfc <release>
      break;
    }
  }
}
    80004172:	60e2                	ld	ra,24(sp)
    80004174:	6442                	ld	s0,16(sp)
    80004176:	64a2                	ld	s1,8(sp)
    80004178:	6902                	ld	s2,0(sp)
    8000417a:	6105                	addi	sp,sp,32
    8000417c:	8082                	ret

000000008000417e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000417e:	7139                	addi	sp,sp,-64
    80004180:	fc06                	sd	ra,56(sp)
    80004182:	f822                	sd	s0,48(sp)
    80004184:	f426                	sd	s1,40(sp)
    80004186:	f04a                	sd	s2,32(sp)
    80004188:	ec4e                	sd	s3,24(sp)
    8000418a:	e852                	sd	s4,16(sp)
    8000418c:	e456                	sd	s5,8(sp)
    8000418e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004190:	0001e497          	auipc	s1,0x1e
    80004194:	97848493          	addi	s1,s1,-1672 # 80021b08 <log>
    80004198:	8526                	mv	a0,s1
    8000419a:	ffffd097          	auipc	ra,0xffffd
    8000419e:	aae080e7          	jalr	-1362(ra) # 80000c48 <acquire>
  log.outstanding -= 1;
    800041a2:	509c                	lw	a5,32(s1)
    800041a4:	37fd                	addiw	a5,a5,-1
    800041a6:	0007891b          	sext.w	s2,a5
    800041aa:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041ac:	50dc                	lw	a5,36(s1)
    800041ae:	e7b9                	bnez	a5,800041fc <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041b0:	04091e63          	bnez	s2,8000420c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041b4:	0001e497          	auipc	s1,0x1e
    800041b8:	95448493          	addi	s1,s1,-1708 # 80021b08 <log>
    800041bc:	4785                	li	a5,1
    800041be:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041c0:	8526                	mv	a0,s1
    800041c2:	ffffd097          	auipc	ra,0xffffd
    800041c6:	b3a080e7          	jalr	-1222(ra) # 80000cfc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041ca:	54dc                	lw	a5,44(s1)
    800041cc:	06f04763          	bgtz	a5,8000423a <end_op+0xbc>
    acquire(&log.lock);
    800041d0:	0001e497          	auipc	s1,0x1e
    800041d4:	93848493          	addi	s1,s1,-1736 # 80021b08 <log>
    800041d8:	8526                	mv	a0,s1
    800041da:	ffffd097          	auipc	ra,0xffffd
    800041de:	a6e080e7          	jalr	-1426(ra) # 80000c48 <acquire>
    log.committing = 0;
    800041e2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041e6:	8526                	mv	a0,s1
    800041e8:	ffffe097          	auipc	ra,0xffffe
    800041ec:	1c4080e7          	jalr	452(ra) # 800023ac <wakeup>
    release(&log.lock);
    800041f0:	8526                	mv	a0,s1
    800041f2:	ffffd097          	auipc	ra,0xffffd
    800041f6:	b0a080e7          	jalr	-1270(ra) # 80000cfc <release>
}
    800041fa:	a03d                	j	80004228 <end_op+0xaa>
    panic("log.committing");
    800041fc:	00004517          	auipc	a0,0x4
    80004200:	43450513          	addi	a0,a0,1076 # 80008630 <syscalls+0x1f0>
    80004204:	ffffc097          	auipc	ra,0xffffc
    80004208:	33e080e7          	jalr	830(ra) # 80000542 <panic>
    wakeup(&log);
    8000420c:	0001e497          	auipc	s1,0x1e
    80004210:	8fc48493          	addi	s1,s1,-1796 # 80021b08 <log>
    80004214:	8526                	mv	a0,s1
    80004216:	ffffe097          	auipc	ra,0xffffe
    8000421a:	196080e7          	jalr	406(ra) # 800023ac <wakeup>
  release(&log.lock);
    8000421e:	8526                	mv	a0,s1
    80004220:	ffffd097          	auipc	ra,0xffffd
    80004224:	adc080e7          	jalr	-1316(ra) # 80000cfc <release>
}
    80004228:	70e2                	ld	ra,56(sp)
    8000422a:	7442                	ld	s0,48(sp)
    8000422c:	74a2                	ld	s1,40(sp)
    8000422e:	7902                	ld	s2,32(sp)
    80004230:	69e2                	ld	s3,24(sp)
    80004232:	6a42                	ld	s4,16(sp)
    80004234:	6aa2                	ld	s5,8(sp)
    80004236:	6121                	addi	sp,sp,64
    80004238:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000423a:	0001ea97          	auipc	s5,0x1e
    8000423e:	8fea8a93          	addi	s5,s5,-1794 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004242:	0001ea17          	auipc	s4,0x1e
    80004246:	8c6a0a13          	addi	s4,s4,-1850 # 80021b08 <log>
    8000424a:	018a2583          	lw	a1,24(s4)
    8000424e:	012585bb          	addw	a1,a1,s2
    80004252:	2585                	addiw	a1,a1,1
    80004254:	028a2503          	lw	a0,40(s4)
    80004258:	fffff097          	auipc	ra,0xfffff
    8000425c:	ce8080e7          	jalr	-792(ra) # 80002f40 <bread>
    80004260:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004262:	000aa583          	lw	a1,0(s5)
    80004266:	028a2503          	lw	a0,40(s4)
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	cd6080e7          	jalr	-810(ra) # 80002f40 <bread>
    80004272:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004274:	40000613          	li	a2,1024
    80004278:	05850593          	addi	a1,a0,88
    8000427c:	05848513          	addi	a0,s1,88
    80004280:	ffffd097          	auipc	ra,0xffffd
    80004284:	b20080e7          	jalr	-1248(ra) # 80000da0 <memmove>
    bwrite(to);  // write the log
    80004288:	8526                	mv	a0,s1
    8000428a:	fffff097          	auipc	ra,0xfffff
    8000428e:	da8080e7          	jalr	-600(ra) # 80003032 <bwrite>
    brelse(from);
    80004292:	854e                	mv	a0,s3
    80004294:	fffff097          	auipc	ra,0xfffff
    80004298:	ddc080e7          	jalr	-548(ra) # 80003070 <brelse>
    brelse(to);
    8000429c:	8526                	mv	a0,s1
    8000429e:	fffff097          	auipc	ra,0xfffff
    800042a2:	dd2080e7          	jalr	-558(ra) # 80003070 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042a6:	2905                	addiw	s2,s2,1
    800042a8:	0a91                	addi	s5,s5,4
    800042aa:	02ca2783          	lw	a5,44(s4)
    800042ae:	f8f94ee3          	blt	s2,a5,8000424a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042b2:	00000097          	auipc	ra,0x0
    800042b6:	c7a080e7          	jalr	-902(ra) # 80003f2c <write_head>
    install_trans(); // Now install writes to home locations
    800042ba:	00000097          	auipc	ra,0x0
    800042be:	cec080e7          	jalr	-788(ra) # 80003fa6 <install_trans>
    log.lh.n = 0;
    800042c2:	0001e797          	auipc	a5,0x1e
    800042c6:	8607a923          	sw	zero,-1934(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042ca:	00000097          	auipc	ra,0x0
    800042ce:	c62080e7          	jalr	-926(ra) # 80003f2c <write_head>
    800042d2:	bdfd                	j	800041d0 <end_op+0x52>

00000000800042d4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042d4:	1101                	addi	sp,sp,-32
    800042d6:	ec06                	sd	ra,24(sp)
    800042d8:	e822                	sd	s0,16(sp)
    800042da:	e426                	sd	s1,8(sp)
    800042dc:	e04a                	sd	s2,0(sp)
    800042de:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042e0:	0001e717          	auipc	a4,0x1e
    800042e4:	85472703          	lw	a4,-1964(a4) # 80021b34 <log+0x2c>
    800042e8:	47f5                	li	a5,29
    800042ea:	08e7c063          	blt	a5,a4,8000436a <log_write+0x96>
    800042ee:	84aa                	mv	s1,a0
    800042f0:	0001e797          	auipc	a5,0x1e
    800042f4:	8347a783          	lw	a5,-1996(a5) # 80021b24 <log+0x1c>
    800042f8:	37fd                	addiw	a5,a5,-1
    800042fa:	06f75863          	bge	a4,a5,8000436a <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042fe:	0001e797          	auipc	a5,0x1e
    80004302:	82a7a783          	lw	a5,-2006(a5) # 80021b28 <log+0x20>
    80004306:	06f05a63          	blez	a5,8000437a <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000430a:	0001d917          	auipc	s2,0x1d
    8000430e:	7fe90913          	addi	s2,s2,2046 # 80021b08 <log>
    80004312:	854a                	mv	a0,s2
    80004314:	ffffd097          	auipc	ra,0xffffd
    80004318:	934080e7          	jalr	-1740(ra) # 80000c48 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000431c:	02c92603          	lw	a2,44(s2)
    80004320:	06c05563          	blez	a2,8000438a <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004324:	44cc                	lw	a1,12(s1)
    80004326:	0001e717          	auipc	a4,0x1e
    8000432a:	81270713          	addi	a4,a4,-2030 # 80021b38 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000432e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004330:	4314                	lw	a3,0(a4)
    80004332:	04b68d63          	beq	a3,a1,8000438c <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004336:	2785                	addiw	a5,a5,1
    80004338:	0711                	addi	a4,a4,4
    8000433a:	fec79be3          	bne	a5,a2,80004330 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000433e:	0621                	addi	a2,a2,8
    80004340:	060a                	slli	a2,a2,0x2
    80004342:	0001d797          	auipc	a5,0x1d
    80004346:	7c678793          	addi	a5,a5,1990 # 80021b08 <log>
    8000434a:	963e                	add	a2,a2,a5
    8000434c:	44dc                	lw	a5,12(s1)
    8000434e:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004350:	8526                	mv	a0,s1
    80004352:	fffff097          	auipc	ra,0xfffff
    80004356:	dbc080e7          	jalr	-580(ra) # 8000310e <bpin>
    log.lh.n++;
    8000435a:	0001d717          	auipc	a4,0x1d
    8000435e:	7ae70713          	addi	a4,a4,1966 # 80021b08 <log>
    80004362:	575c                	lw	a5,44(a4)
    80004364:	2785                	addiw	a5,a5,1
    80004366:	d75c                	sw	a5,44(a4)
    80004368:	a83d                	j	800043a6 <log_write+0xd2>
    panic("too big a transaction");
    8000436a:	00004517          	auipc	a0,0x4
    8000436e:	2d650513          	addi	a0,a0,726 # 80008640 <syscalls+0x200>
    80004372:	ffffc097          	auipc	ra,0xffffc
    80004376:	1d0080e7          	jalr	464(ra) # 80000542 <panic>
    panic("log_write outside of trans");
    8000437a:	00004517          	auipc	a0,0x4
    8000437e:	2de50513          	addi	a0,a0,734 # 80008658 <syscalls+0x218>
    80004382:	ffffc097          	auipc	ra,0xffffc
    80004386:	1c0080e7          	jalr	448(ra) # 80000542 <panic>
  for (i = 0; i < log.lh.n; i++) {
    8000438a:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    8000438c:	00878713          	addi	a4,a5,8
    80004390:	00271693          	slli	a3,a4,0x2
    80004394:	0001d717          	auipc	a4,0x1d
    80004398:	77470713          	addi	a4,a4,1908 # 80021b08 <log>
    8000439c:	9736                	add	a4,a4,a3
    8000439e:	44d4                	lw	a3,12(s1)
    800043a0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043a2:	faf607e3          	beq	a2,a5,80004350 <log_write+0x7c>
  }
  release(&log.lock);
    800043a6:	0001d517          	auipc	a0,0x1d
    800043aa:	76250513          	addi	a0,a0,1890 # 80021b08 <log>
    800043ae:	ffffd097          	auipc	ra,0xffffd
    800043b2:	94e080e7          	jalr	-1714(ra) # 80000cfc <release>
}
    800043b6:	60e2                	ld	ra,24(sp)
    800043b8:	6442                	ld	s0,16(sp)
    800043ba:	64a2                	ld	s1,8(sp)
    800043bc:	6902                	ld	s2,0(sp)
    800043be:	6105                	addi	sp,sp,32
    800043c0:	8082                	ret

00000000800043c2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043c2:	1101                	addi	sp,sp,-32
    800043c4:	ec06                	sd	ra,24(sp)
    800043c6:	e822                	sd	s0,16(sp)
    800043c8:	e426                	sd	s1,8(sp)
    800043ca:	e04a                	sd	s2,0(sp)
    800043cc:	1000                	addi	s0,sp,32
    800043ce:	84aa                	mv	s1,a0
    800043d0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043d2:	00004597          	auipc	a1,0x4
    800043d6:	2a658593          	addi	a1,a1,678 # 80008678 <syscalls+0x238>
    800043da:	0521                	addi	a0,a0,8
    800043dc:	ffffc097          	auipc	ra,0xffffc
    800043e0:	7dc080e7          	jalr	2012(ra) # 80000bb8 <initlock>
  lk->name = name;
    800043e4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043ec:	0204a423          	sw	zero,40(s1)
}
    800043f0:	60e2                	ld	ra,24(sp)
    800043f2:	6442                	ld	s0,16(sp)
    800043f4:	64a2                	ld	s1,8(sp)
    800043f6:	6902                	ld	s2,0(sp)
    800043f8:	6105                	addi	sp,sp,32
    800043fa:	8082                	ret

00000000800043fc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043fc:	1101                	addi	sp,sp,-32
    800043fe:	ec06                	sd	ra,24(sp)
    80004400:	e822                	sd	s0,16(sp)
    80004402:	e426                	sd	s1,8(sp)
    80004404:	e04a                	sd	s2,0(sp)
    80004406:	1000                	addi	s0,sp,32
    80004408:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000440a:	00850913          	addi	s2,a0,8
    8000440e:	854a                	mv	a0,s2
    80004410:	ffffd097          	auipc	ra,0xffffd
    80004414:	838080e7          	jalr	-1992(ra) # 80000c48 <acquire>
  while (lk->locked) {
    80004418:	409c                	lw	a5,0(s1)
    8000441a:	cb89                	beqz	a5,8000442c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000441c:	85ca                	mv	a1,s2
    8000441e:	8526                	mv	a0,s1
    80004420:	ffffe097          	auipc	ra,0xffffe
    80004424:	e0c080e7          	jalr	-500(ra) # 8000222c <sleep>
  while (lk->locked) {
    80004428:	409c                	lw	a5,0(s1)
    8000442a:	fbed                	bnez	a5,8000441c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000442c:	4785                	li	a5,1
    8000442e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004430:	ffffd097          	auipc	ra,0xffffd
    80004434:	5e4080e7          	jalr	1508(ra) # 80001a14 <myproc>
    80004438:	5d1c                	lw	a5,56(a0)
    8000443a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000443c:	854a                	mv	a0,s2
    8000443e:	ffffd097          	auipc	ra,0xffffd
    80004442:	8be080e7          	jalr	-1858(ra) # 80000cfc <release>
}
    80004446:	60e2                	ld	ra,24(sp)
    80004448:	6442                	ld	s0,16(sp)
    8000444a:	64a2                	ld	s1,8(sp)
    8000444c:	6902                	ld	s2,0(sp)
    8000444e:	6105                	addi	sp,sp,32
    80004450:	8082                	ret

0000000080004452 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004452:	1101                	addi	sp,sp,-32
    80004454:	ec06                	sd	ra,24(sp)
    80004456:	e822                	sd	s0,16(sp)
    80004458:	e426                	sd	s1,8(sp)
    8000445a:	e04a                	sd	s2,0(sp)
    8000445c:	1000                	addi	s0,sp,32
    8000445e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004460:	00850913          	addi	s2,a0,8
    80004464:	854a                	mv	a0,s2
    80004466:	ffffc097          	auipc	ra,0xffffc
    8000446a:	7e2080e7          	jalr	2018(ra) # 80000c48 <acquire>
  lk->locked = 0;
    8000446e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004472:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004476:	8526                	mv	a0,s1
    80004478:	ffffe097          	auipc	ra,0xffffe
    8000447c:	f34080e7          	jalr	-204(ra) # 800023ac <wakeup>
  release(&lk->lk);
    80004480:	854a                	mv	a0,s2
    80004482:	ffffd097          	auipc	ra,0xffffd
    80004486:	87a080e7          	jalr	-1926(ra) # 80000cfc <release>
}
    8000448a:	60e2                	ld	ra,24(sp)
    8000448c:	6442                	ld	s0,16(sp)
    8000448e:	64a2                	ld	s1,8(sp)
    80004490:	6902                	ld	s2,0(sp)
    80004492:	6105                	addi	sp,sp,32
    80004494:	8082                	ret

0000000080004496 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004496:	7179                	addi	sp,sp,-48
    80004498:	f406                	sd	ra,40(sp)
    8000449a:	f022                	sd	s0,32(sp)
    8000449c:	ec26                	sd	s1,24(sp)
    8000449e:	e84a                	sd	s2,16(sp)
    800044a0:	e44e                	sd	s3,8(sp)
    800044a2:	1800                	addi	s0,sp,48
    800044a4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044a6:	00850913          	addi	s2,a0,8
    800044aa:	854a                	mv	a0,s2
    800044ac:	ffffc097          	auipc	ra,0xffffc
    800044b0:	79c080e7          	jalr	1948(ra) # 80000c48 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044b4:	409c                	lw	a5,0(s1)
    800044b6:	ef99                	bnez	a5,800044d4 <holdingsleep+0x3e>
    800044b8:	4481                	li	s1,0
  release(&lk->lk);
    800044ba:	854a                	mv	a0,s2
    800044bc:	ffffd097          	auipc	ra,0xffffd
    800044c0:	840080e7          	jalr	-1984(ra) # 80000cfc <release>
  return r;
}
    800044c4:	8526                	mv	a0,s1
    800044c6:	70a2                	ld	ra,40(sp)
    800044c8:	7402                	ld	s0,32(sp)
    800044ca:	64e2                	ld	s1,24(sp)
    800044cc:	6942                	ld	s2,16(sp)
    800044ce:	69a2                	ld	s3,8(sp)
    800044d0:	6145                	addi	sp,sp,48
    800044d2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044d4:	0284a983          	lw	s3,40(s1)
    800044d8:	ffffd097          	auipc	ra,0xffffd
    800044dc:	53c080e7          	jalr	1340(ra) # 80001a14 <myproc>
    800044e0:	5d04                	lw	s1,56(a0)
    800044e2:	413484b3          	sub	s1,s1,s3
    800044e6:	0014b493          	seqz	s1,s1
    800044ea:	bfc1                	j	800044ba <holdingsleep+0x24>

00000000800044ec <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044ec:	1141                	addi	sp,sp,-16
    800044ee:	e406                	sd	ra,8(sp)
    800044f0:	e022                	sd	s0,0(sp)
    800044f2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044f4:	00004597          	auipc	a1,0x4
    800044f8:	19458593          	addi	a1,a1,404 # 80008688 <syscalls+0x248>
    800044fc:	0001d517          	auipc	a0,0x1d
    80004500:	75450513          	addi	a0,a0,1876 # 80021c50 <ftable>
    80004504:	ffffc097          	auipc	ra,0xffffc
    80004508:	6b4080e7          	jalr	1716(ra) # 80000bb8 <initlock>
}
    8000450c:	60a2                	ld	ra,8(sp)
    8000450e:	6402                	ld	s0,0(sp)
    80004510:	0141                	addi	sp,sp,16
    80004512:	8082                	ret

0000000080004514 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004514:	1101                	addi	sp,sp,-32
    80004516:	ec06                	sd	ra,24(sp)
    80004518:	e822                	sd	s0,16(sp)
    8000451a:	e426                	sd	s1,8(sp)
    8000451c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000451e:	0001d517          	auipc	a0,0x1d
    80004522:	73250513          	addi	a0,a0,1842 # 80021c50 <ftable>
    80004526:	ffffc097          	auipc	ra,0xffffc
    8000452a:	722080e7          	jalr	1826(ra) # 80000c48 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000452e:	0001d497          	auipc	s1,0x1d
    80004532:	73a48493          	addi	s1,s1,1850 # 80021c68 <ftable+0x18>
    80004536:	0001e717          	auipc	a4,0x1e
    8000453a:	6d270713          	addi	a4,a4,1746 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    8000453e:	40dc                	lw	a5,4(s1)
    80004540:	cf99                	beqz	a5,8000455e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004542:	02848493          	addi	s1,s1,40
    80004546:	fee49ce3          	bne	s1,a4,8000453e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000454a:	0001d517          	auipc	a0,0x1d
    8000454e:	70650513          	addi	a0,a0,1798 # 80021c50 <ftable>
    80004552:	ffffc097          	auipc	ra,0xffffc
    80004556:	7aa080e7          	jalr	1962(ra) # 80000cfc <release>
  return 0;
    8000455a:	4481                	li	s1,0
    8000455c:	a819                	j	80004572 <filealloc+0x5e>
      f->ref = 1;
    8000455e:	4785                	li	a5,1
    80004560:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004562:	0001d517          	auipc	a0,0x1d
    80004566:	6ee50513          	addi	a0,a0,1774 # 80021c50 <ftable>
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	792080e7          	jalr	1938(ra) # 80000cfc <release>
}
    80004572:	8526                	mv	a0,s1
    80004574:	60e2                	ld	ra,24(sp)
    80004576:	6442                	ld	s0,16(sp)
    80004578:	64a2                	ld	s1,8(sp)
    8000457a:	6105                	addi	sp,sp,32
    8000457c:	8082                	ret

000000008000457e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000457e:	1101                	addi	sp,sp,-32
    80004580:	ec06                	sd	ra,24(sp)
    80004582:	e822                	sd	s0,16(sp)
    80004584:	e426                	sd	s1,8(sp)
    80004586:	1000                	addi	s0,sp,32
    80004588:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000458a:	0001d517          	auipc	a0,0x1d
    8000458e:	6c650513          	addi	a0,a0,1734 # 80021c50 <ftable>
    80004592:	ffffc097          	auipc	ra,0xffffc
    80004596:	6b6080e7          	jalr	1718(ra) # 80000c48 <acquire>
  if(f->ref < 1)
    8000459a:	40dc                	lw	a5,4(s1)
    8000459c:	02f05263          	blez	a5,800045c0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045a0:	2785                	addiw	a5,a5,1
    800045a2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045a4:	0001d517          	auipc	a0,0x1d
    800045a8:	6ac50513          	addi	a0,a0,1708 # 80021c50 <ftable>
    800045ac:	ffffc097          	auipc	ra,0xffffc
    800045b0:	750080e7          	jalr	1872(ra) # 80000cfc <release>
  return f;
}
    800045b4:	8526                	mv	a0,s1
    800045b6:	60e2                	ld	ra,24(sp)
    800045b8:	6442                	ld	s0,16(sp)
    800045ba:	64a2                	ld	s1,8(sp)
    800045bc:	6105                	addi	sp,sp,32
    800045be:	8082                	ret
    panic("filedup");
    800045c0:	00004517          	auipc	a0,0x4
    800045c4:	0d050513          	addi	a0,a0,208 # 80008690 <syscalls+0x250>
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	f7a080e7          	jalr	-134(ra) # 80000542 <panic>

00000000800045d0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045d0:	7139                	addi	sp,sp,-64
    800045d2:	fc06                	sd	ra,56(sp)
    800045d4:	f822                	sd	s0,48(sp)
    800045d6:	f426                	sd	s1,40(sp)
    800045d8:	f04a                	sd	s2,32(sp)
    800045da:	ec4e                	sd	s3,24(sp)
    800045dc:	e852                	sd	s4,16(sp)
    800045de:	e456                	sd	s5,8(sp)
    800045e0:	0080                	addi	s0,sp,64
    800045e2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045e4:	0001d517          	auipc	a0,0x1d
    800045e8:	66c50513          	addi	a0,a0,1644 # 80021c50 <ftable>
    800045ec:	ffffc097          	auipc	ra,0xffffc
    800045f0:	65c080e7          	jalr	1628(ra) # 80000c48 <acquire>
  if(f->ref < 1)
    800045f4:	40dc                	lw	a5,4(s1)
    800045f6:	06f05163          	blez	a5,80004658 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045fa:	37fd                	addiw	a5,a5,-1
    800045fc:	0007871b          	sext.w	a4,a5
    80004600:	c0dc                	sw	a5,4(s1)
    80004602:	06e04363          	bgtz	a4,80004668 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004606:	0004a903          	lw	s2,0(s1)
    8000460a:	0094ca83          	lbu	s5,9(s1)
    8000460e:	0104ba03          	ld	s4,16(s1)
    80004612:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004616:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000461a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000461e:	0001d517          	auipc	a0,0x1d
    80004622:	63250513          	addi	a0,a0,1586 # 80021c50 <ftable>
    80004626:	ffffc097          	auipc	ra,0xffffc
    8000462a:	6d6080e7          	jalr	1750(ra) # 80000cfc <release>

  if(ff.type == FD_PIPE){
    8000462e:	4785                	li	a5,1
    80004630:	04f90d63          	beq	s2,a5,8000468a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004634:	3979                	addiw	s2,s2,-2
    80004636:	4785                	li	a5,1
    80004638:	0527e063          	bltu	a5,s2,80004678 <fileclose+0xa8>
    begin_op();
    8000463c:	00000097          	auipc	ra,0x0
    80004640:	ac2080e7          	jalr	-1342(ra) # 800040fe <begin_op>
    iput(ff.ip);
    80004644:	854e                	mv	a0,s3
    80004646:	fffff097          	auipc	ra,0xfffff
    8000464a:	2b6080e7          	jalr	694(ra) # 800038fc <iput>
    end_op();
    8000464e:	00000097          	auipc	ra,0x0
    80004652:	b30080e7          	jalr	-1232(ra) # 8000417e <end_op>
    80004656:	a00d                	j	80004678 <fileclose+0xa8>
    panic("fileclose");
    80004658:	00004517          	auipc	a0,0x4
    8000465c:	04050513          	addi	a0,a0,64 # 80008698 <syscalls+0x258>
    80004660:	ffffc097          	auipc	ra,0xffffc
    80004664:	ee2080e7          	jalr	-286(ra) # 80000542 <panic>
    release(&ftable.lock);
    80004668:	0001d517          	auipc	a0,0x1d
    8000466c:	5e850513          	addi	a0,a0,1512 # 80021c50 <ftable>
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	68c080e7          	jalr	1676(ra) # 80000cfc <release>
  }
}
    80004678:	70e2                	ld	ra,56(sp)
    8000467a:	7442                	ld	s0,48(sp)
    8000467c:	74a2                	ld	s1,40(sp)
    8000467e:	7902                	ld	s2,32(sp)
    80004680:	69e2                	ld	s3,24(sp)
    80004682:	6a42                	ld	s4,16(sp)
    80004684:	6aa2                	ld	s5,8(sp)
    80004686:	6121                	addi	sp,sp,64
    80004688:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000468a:	85d6                	mv	a1,s5
    8000468c:	8552                	mv	a0,s4
    8000468e:	00000097          	auipc	ra,0x0
    80004692:	372080e7          	jalr	882(ra) # 80004a00 <pipeclose>
    80004696:	b7cd                	j	80004678 <fileclose+0xa8>

0000000080004698 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004698:	715d                	addi	sp,sp,-80
    8000469a:	e486                	sd	ra,72(sp)
    8000469c:	e0a2                	sd	s0,64(sp)
    8000469e:	fc26                	sd	s1,56(sp)
    800046a0:	f84a                	sd	s2,48(sp)
    800046a2:	f44e                	sd	s3,40(sp)
    800046a4:	0880                	addi	s0,sp,80
    800046a6:	84aa                	mv	s1,a0
    800046a8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046aa:	ffffd097          	auipc	ra,0xffffd
    800046ae:	36a080e7          	jalr	874(ra) # 80001a14 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046b2:	409c                	lw	a5,0(s1)
    800046b4:	37f9                	addiw	a5,a5,-2
    800046b6:	4705                	li	a4,1
    800046b8:	04f76763          	bltu	a4,a5,80004706 <filestat+0x6e>
    800046bc:	892a                	mv	s2,a0
    ilock(f->ip);
    800046be:	6c88                	ld	a0,24(s1)
    800046c0:	fffff097          	auipc	ra,0xfffff
    800046c4:	082080e7          	jalr	130(ra) # 80003742 <ilock>
    stati(f->ip, &st);
    800046c8:	fb840593          	addi	a1,s0,-72
    800046cc:	6c88                	ld	a0,24(s1)
    800046ce:	fffff097          	auipc	ra,0xfffff
    800046d2:	2fe080e7          	jalr	766(ra) # 800039cc <stati>
    iunlock(f->ip);
    800046d6:	6c88                	ld	a0,24(s1)
    800046d8:	fffff097          	auipc	ra,0xfffff
    800046dc:	12c080e7          	jalr	300(ra) # 80003804 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046e0:	46e1                	li	a3,24
    800046e2:	fb840613          	addi	a2,s0,-72
    800046e6:	85ce                	mv	a1,s3
    800046e8:	05093503          	ld	a0,80(s2)
    800046ec:	ffffd097          	auipc	ra,0xffffd
    800046f0:	01a080e7          	jalr	26(ra) # 80001706 <copyout>
    800046f4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046f8:	60a6                	ld	ra,72(sp)
    800046fa:	6406                	ld	s0,64(sp)
    800046fc:	74e2                	ld	s1,56(sp)
    800046fe:	7942                	ld	s2,48(sp)
    80004700:	79a2                	ld	s3,40(sp)
    80004702:	6161                	addi	sp,sp,80
    80004704:	8082                	ret
  return -1;
    80004706:	557d                	li	a0,-1
    80004708:	bfc5                	j	800046f8 <filestat+0x60>

000000008000470a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000470a:	7179                	addi	sp,sp,-48
    8000470c:	f406                	sd	ra,40(sp)
    8000470e:	f022                	sd	s0,32(sp)
    80004710:	ec26                	sd	s1,24(sp)
    80004712:	e84a                	sd	s2,16(sp)
    80004714:	e44e                	sd	s3,8(sp)
    80004716:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004718:	00854783          	lbu	a5,8(a0)
    8000471c:	c3d5                	beqz	a5,800047c0 <fileread+0xb6>
    8000471e:	84aa                	mv	s1,a0
    80004720:	89ae                	mv	s3,a1
    80004722:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004724:	411c                	lw	a5,0(a0)
    80004726:	4705                	li	a4,1
    80004728:	04e78963          	beq	a5,a4,8000477a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000472c:	470d                	li	a4,3
    8000472e:	04e78d63          	beq	a5,a4,80004788 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004732:	4709                	li	a4,2
    80004734:	06e79e63          	bne	a5,a4,800047b0 <fileread+0xa6>
    ilock(f->ip);
    80004738:	6d08                	ld	a0,24(a0)
    8000473a:	fffff097          	auipc	ra,0xfffff
    8000473e:	008080e7          	jalr	8(ra) # 80003742 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004742:	874a                	mv	a4,s2
    80004744:	5094                	lw	a3,32(s1)
    80004746:	864e                	mv	a2,s3
    80004748:	4585                	li	a1,1
    8000474a:	6c88                	ld	a0,24(s1)
    8000474c:	fffff097          	auipc	ra,0xfffff
    80004750:	2aa080e7          	jalr	682(ra) # 800039f6 <readi>
    80004754:	892a                	mv	s2,a0
    80004756:	00a05563          	blez	a0,80004760 <fileread+0x56>
      f->off += r;
    8000475a:	509c                	lw	a5,32(s1)
    8000475c:	9fa9                	addw	a5,a5,a0
    8000475e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004760:	6c88                	ld	a0,24(s1)
    80004762:	fffff097          	auipc	ra,0xfffff
    80004766:	0a2080e7          	jalr	162(ra) # 80003804 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000476a:	854a                	mv	a0,s2
    8000476c:	70a2                	ld	ra,40(sp)
    8000476e:	7402                	ld	s0,32(sp)
    80004770:	64e2                	ld	s1,24(sp)
    80004772:	6942                	ld	s2,16(sp)
    80004774:	69a2                	ld	s3,8(sp)
    80004776:	6145                	addi	sp,sp,48
    80004778:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000477a:	6908                	ld	a0,16(a0)
    8000477c:	00000097          	auipc	ra,0x0
    80004780:	3f4080e7          	jalr	1012(ra) # 80004b70 <piperead>
    80004784:	892a                	mv	s2,a0
    80004786:	b7d5                	j	8000476a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004788:	02451783          	lh	a5,36(a0)
    8000478c:	03079693          	slli	a3,a5,0x30
    80004790:	92c1                	srli	a3,a3,0x30
    80004792:	4725                	li	a4,9
    80004794:	02d76863          	bltu	a4,a3,800047c4 <fileread+0xba>
    80004798:	0792                	slli	a5,a5,0x4
    8000479a:	0001d717          	auipc	a4,0x1d
    8000479e:	41670713          	addi	a4,a4,1046 # 80021bb0 <devsw>
    800047a2:	97ba                	add	a5,a5,a4
    800047a4:	639c                	ld	a5,0(a5)
    800047a6:	c38d                	beqz	a5,800047c8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047a8:	4505                	li	a0,1
    800047aa:	9782                	jalr	a5
    800047ac:	892a                	mv	s2,a0
    800047ae:	bf75                	j	8000476a <fileread+0x60>
    panic("fileread");
    800047b0:	00004517          	auipc	a0,0x4
    800047b4:	ef850513          	addi	a0,a0,-264 # 800086a8 <syscalls+0x268>
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	d8a080e7          	jalr	-630(ra) # 80000542 <panic>
    return -1;
    800047c0:	597d                	li	s2,-1
    800047c2:	b765                	j	8000476a <fileread+0x60>
      return -1;
    800047c4:	597d                	li	s2,-1
    800047c6:	b755                	j	8000476a <fileread+0x60>
    800047c8:	597d                	li	s2,-1
    800047ca:	b745                	j	8000476a <fileread+0x60>

00000000800047cc <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047cc:	00954783          	lbu	a5,9(a0)
    800047d0:	14078563          	beqz	a5,8000491a <filewrite+0x14e>
{
    800047d4:	715d                	addi	sp,sp,-80
    800047d6:	e486                	sd	ra,72(sp)
    800047d8:	e0a2                	sd	s0,64(sp)
    800047da:	fc26                	sd	s1,56(sp)
    800047dc:	f84a                	sd	s2,48(sp)
    800047de:	f44e                	sd	s3,40(sp)
    800047e0:	f052                	sd	s4,32(sp)
    800047e2:	ec56                	sd	s5,24(sp)
    800047e4:	e85a                	sd	s6,16(sp)
    800047e6:	e45e                	sd	s7,8(sp)
    800047e8:	e062                	sd	s8,0(sp)
    800047ea:	0880                	addi	s0,sp,80
    800047ec:	892a                	mv	s2,a0
    800047ee:	8aae                	mv	s5,a1
    800047f0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047f2:	411c                	lw	a5,0(a0)
    800047f4:	4705                	li	a4,1
    800047f6:	02e78263          	beq	a5,a4,8000481a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047fa:	470d                	li	a4,3
    800047fc:	02e78563          	beq	a5,a4,80004826 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004800:	4709                	li	a4,2
    80004802:	10e79463          	bne	a5,a4,8000490a <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004806:	0ec05e63          	blez	a2,80004902 <filewrite+0x136>
    int i = 0;
    8000480a:	4981                	li	s3,0
    8000480c:	6b05                	lui	s6,0x1
    8000480e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004812:	6b85                	lui	s7,0x1
    80004814:	c00b8b9b          	addiw	s7,s7,-1024
    80004818:	a851                	j	800048ac <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000481a:	6908                	ld	a0,16(a0)
    8000481c:	00000097          	auipc	ra,0x0
    80004820:	254080e7          	jalr	596(ra) # 80004a70 <pipewrite>
    80004824:	a85d                	j	800048da <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004826:	02451783          	lh	a5,36(a0)
    8000482a:	03079693          	slli	a3,a5,0x30
    8000482e:	92c1                	srli	a3,a3,0x30
    80004830:	4725                	li	a4,9
    80004832:	0ed76663          	bltu	a4,a3,8000491e <filewrite+0x152>
    80004836:	0792                	slli	a5,a5,0x4
    80004838:	0001d717          	auipc	a4,0x1d
    8000483c:	37870713          	addi	a4,a4,888 # 80021bb0 <devsw>
    80004840:	97ba                	add	a5,a5,a4
    80004842:	679c                	ld	a5,8(a5)
    80004844:	cff9                	beqz	a5,80004922 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004846:	4505                	li	a0,1
    80004848:	9782                	jalr	a5
    8000484a:	a841                	j	800048da <filewrite+0x10e>
    8000484c:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004850:	00000097          	auipc	ra,0x0
    80004854:	8ae080e7          	jalr	-1874(ra) # 800040fe <begin_op>
      ilock(f->ip);
    80004858:	01893503          	ld	a0,24(s2)
    8000485c:	fffff097          	auipc	ra,0xfffff
    80004860:	ee6080e7          	jalr	-282(ra) # 80003742 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004864:	8762                	mv	a4,s8
    80004866:	02092683          	lw	a3,32(s2)
    8000486a:	01598633          	add	a2,s3,s5
    8000486e:	4585                	li	a1,1
    80004870:	01893503          	ld	a0,24(s2)
    80004874:	fffff097          	auipc	ra,0xfffff
    80004878:	278080e7          	jalr	632(ra) # 80003aec <writei>
    8000487c:	84aa                	mv	s1,a0
    8000487e:	02a05f63          	blez	a0,800048bc <filewrite+0xf0>
        f->off += r;
    80004882:	02092783          	lw	a5,32(s2)
    80004886:	9fa9                	addw	a5,a5,a0
    80004888:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000488c:	01893503          	ld	a0,24(s2)
    80004890:	fffff097          	auipc	ra,0xfffff
    80004894:	f74080e7          	jalr	-140(ra) # 80003804 <iunlock>
      end_op();
    80004898:	00000097          	auipc	ra,0x0
    8000489c:	8e6080e7          	jalr	-1818(ra) # 8000417e <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800048a0:	049c1963          	bne	s8,s1,800048f2 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800048a4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048a8:	0349d663          	bge	s3,s4,800048d4 <filewrite+0x108>
      int n1 = n - i;
    800048ac:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800048b0:	84be                	mv	s1,a5
    800048b2:	2781                	sext.w	a5,a5
    800048b4:	f8fb5ce3          	bge	s6,a5,8000484c <filewrite+0x80>
    800048b8:	84de                	mv	s1,s7
    800048ba:	bf49                	j	8000484c <filewrite+0x80>
      iunlock(f->ip);
    800048bc:	01893503          	ld	a0,24(s2)
    800048c0:	fffff097          	auipc	ra,0xfffff
    800048c4:	f44080e7          	jalr	-188(ra) # 80003804 <iunlock>
      end_op();
    800048c8:	00000097          	auipc	ra,0x0
    800048cc:	8b6080e7          	jalr	-1866(ra) # 8000417e <end_op>
      if(r < 0)
    800048d0:	fc04d8e3          	bgez	s1,800048a0 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800048d4:	8552                	mv	a0,s4
    800048d6:	033a1863          	bne	s4,s3,80004906 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048da:	60a6                	ld	ra,72(sp)
    800048dc:	6406                	ld	s0,64(sp)
    800048de:	74e2                	ld	s1,56(sp)
    800048e0:	7942                	ld	s2,48(sp)
    800048e2:	79a2                	ld	s3,40(sp)
    800048e4:	7a02                	ld	s4,32(sp)
    800048e6:	6ae2                	ld	s5,24(sp)
    800048e8:	6b42                	ld	s6,16(sp)
    800048ea:	6ba2                	ld	s7,8(sp)
    800048ec:	6c02                	ld	s8,0(sp)
    800048ee:	6161                	addi	sp,sp,80
    800048f0:	8082                	ret
        panic("short filewrite");
    800048f2:	00004517          	auipc	a0,0x4
    800048f6:	dc650513          	addi	a0,a0,-570 # 800086b8 <syscalls+0x278>
    800048fa:	ffffc097          	auipc	ra,0xffffc
    800048fe:	c48080e7          	jalr	-952(ra) # 80000542 <panic>
    int i = 0;
    80004902:	4981                	li	s3,0
    80004904:	bfc1                	j	800048d4 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004906:	557d                	li	a0,-1
    80004908:	bfc9                	j	800048da <filewrite+0x10e>
    panic("filewrite");
    8000490a:	00004517          	auipc	a0,0x4
    8000490e:	dbe50513          	addi	a0,a0,-578 # 800086c8 <syscalls+0x288>
    80004912:	ffffc097          	auipc	ra,0xffffc
    80004916:	c30080e7          	jalr	-976(ra) # 80000542 <panic>
    return -1;
    8000491a:	557d                	li	a0,-1
}
    8000491c:	8082                	ret
      return -1;
    8000491e:	557d                	li	a0,-1
    80004920:	bf6d                	j	800048da <filewrite+0x10e>
    80004922:	557d                	li	a0,-1
    80004924:	bf5d                	j	800048da <filewrite+0x10e>

0000000080004926 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004926:	7179                	addi	sp,sp,-48
    80004928:	f406                	sd	ra,40(sp)
    8000492a:	f022                	sd	s0,32(sp)
    8000492c:	ec26                	sd	s1,24(sp)
    8000492e:	e84a                	sd	s2,16(sp)
    80004930:	e44e                	sd	s3,8(sp)
    80004932:	e052                	sd	s4,0(sp)
    80004934:	1800                	addi	s0,sp,48
    80004936:	84aa                	mv	s1,a0
    80004938:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000493a:	0005b023          	sd	zero,0(a1)
    8000493e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004942:	00000097          	auipc	ra,0x0
    80004946:	bd2080e7          	jalr	-1070(ra) # 80004514 <filealloc>
    8000494a:	e088                	sd	a0,0(s1)
    8000494c:	c551                	beqz	a0,800049d8 <pipealloc+0xb2>
    8000494e:	00000097          	auipc	ra,0x0
    80004952:	bc6080e7          	jalr	-1082(ra) # 80004514 <filealloc>
    80004956:	00aa3023          	sd	a0,0(s4)
    8000495a:	c92d                	beqz	a0,800049cc <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000495c:	ffffc097          	auipc	ra,0xffffc
    80004960:	1b2080e7          	jalr	434(ra) # 80000b0e <kalloc>
    80004964:	892a                	mv	s2,a0
    80004966:	c125                	beqz	a0,800049c6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004968:	4985                	li	s3,1
    8000496a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000496e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004972:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004976:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000497a:	00004597          	auipc	a1,0x4
    8000497e:	d5e58593          	addi	a1,a1,-674 # 800086d8 <syscalls+0x298>
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	236080e7          	jalr	566(ra) # 80000bb8 <initlock>
  (*f0)->type = FD_PIPE;
    8000498a:	609c                	ld	a5,0(s1)
    8000498c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004990:	609c                	ld	a5,0(s1)
    80004992:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004996:	609c                	ld	a5,0(s1)
    80004998:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000499c:	609c                	ld	a5,0(s1)
    8000499e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049a2:	000a3783          	ld	a5,0(s4)
    800049a6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049aa:	000a3783          	ld	a5,0(s4)
    800049ae:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049b2:	000a3783          	ld	a5,0(s4)
    800049b6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049ba:	000a3783          	ld	a5,0(s4)
    800049be:	0127b823          	sd	s2,16(a5)
  return 0;
    800049c2:	4501                	li	a0,0
    800049c4:	a025                	j	800049ec <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049c6:	6088                	ld	a0,0(s1)
    800049c8:	e501                	bnez	a0,800049d0 <pipealloc+0xaa>
    800049ca:	a039                	j	800049d8 <pipealloc+0xb2>
    800049cc:	6088                	ld	a0,0(s1)
    800049ce:	c51d                	beqz	a0,800049fc <pipealloc+0xd6>
    fileclose(*f0);
    800049d0:	00000097          	auipc	ra,0x0
    800049d4:	c00080e7          	jalr	-1024(ra) # 800045d0 <fileclose>
  if(*f1)
    800049d8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049dc:	557d                	li	a0,-1
  if(*f1)
    800049de:	c799                	beqz	a5,800049ec <pipealloc+0xc6>
    fileclose(*f1);
    800049e0:	853e                	mv	a0,a5
    800049e2:	00000097          	auipc	ra,0x0
    800049e6:	bee080e7          	jalr	-1042(ra) # 800045d0 <fileclose>
  return -1;
    800049ea:	557d                	li	a0,-1
}
    800049ec:	70a2                	ld	ra,40(sp)
    800049ee:	7402                	ld	s0,32(sp)
    800049f0:	64e2                	ld	s1,24(sp)
    800049f2:	6942                	ld	s2,16(sp)
    800049f4:	69a2                	ld	s3,8(sp)
    800049f6:	6a02                	ld	s4,0(sp)
    800049f8:	6145                	addi	sp,sp,48
    800049fa:	8082                	ret
  return -1;
    800049fc:	557d                	li	a0,-1
    800049fe:	b7fd                	j	800049ec <pipealloc+0xc6>

0000000080004a00 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a00:	1101                	addi	sp,sp,-32
    80004a02:	ec06                	sd	ra,24(sp)
    80004a04:	e822                	sd	s0,16(sp)
    80004a06:	e426                	sd	s1,8(sp)
    80004a08:	e04a                	sd	s2,0(sp)
    80004a0a:	1000                	addi	s0,sp,32
    80004a0c:	84aa                	mv	s1,a0
    80004a0e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a10:	ffffc097          	auipc	ra,0xffffc
    80004a14:	238080e7          	jalr	568(ra) # 80000c48 <acquire>
  if(writable){
    80004a18:	02090d63          	beqz	s2,80004a52 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a1c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a20:	21848513          	addi	a0,s1,536
    80004a24:	ffffe097          	auipc	ra,0xffffe
    80004a28:	988080e7          	jalr	-1656(ra) # 800023ac <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a2c:	2204b783          	ld	a5,544(s1)
    80004a30:	eb95                	bnez	a5,80004a64 <pipeclose+0x64>
    release(&pi->lock);
    80004a32:	8526                	mv	a0,s1
    80004a34:	ffffc097          	auipc	ra,0xffffc
    80004a38:	2c8080e7          	jalr	712(ra) # 80000cfc <release>
    kfree((char*)pi);
    80004a3c:	8526                	mv	a0,s1
    80004a3e:	ffffc097          	auipc	ra,0xffffc
    80004a42:	fd4080e7          	jalr	-44(ra) # 80000a12 <kfree>
  } else
    release(&pi->lock);
}
    80004a46:	60e2                	ld	ra,24(sp)
    80004a48:	6442                	ld	s0,16(sp)
    80004a4a:	64a2                	ld	s1,8(sp)
    80004a4c:	6902                	ld	s2,0(sp)
    80004a4e:	6105                	addi	sp,sp,32
    80004a50:	8082                	ret
    pi->readopen = 0;
    80004a52:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a56:	21c48513          	addi	a0,s1,540
    80004a5a:	ffffe097          	auipc	ra,0xffffe
    80004a5e:	952080e7          	jalr	-1710(ra) # 800023ac <wakeup>
    80004a62:	b7e9                	j	80004a2c <pipeclose+0x2c>
    release(&pi->lock);
    80004a64:	8526                	mv	a0,s1
    80004a66:	ffffc097          	auipc	ra,0xffffc
    80004a6a:	296080e7          	jalr	662(ra) # 80000cfc <release>
}
    80004a6e:	bfe1                	j	80004a46 <pipeclose+0x46>

0000000080004a70 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a70:	711d                	addi	sp,sp,-96
    80004a72:	ec86                	sd	ra,88(sp)
    80004a74:	e8a2                	sd	s0,80(sp)
    80004a76:	e4a6                	sd	s1,72(sp)
    80004a78:	e0ca                	sd	s2,64(sp)
    80004a7a:	fc4e                	sd	s3,56(sp)
    80004a7c:	f852                	sd	s4,48(sp)
    80004a7e:	f456                	sd	s5,40(sp)
    80004a80:	f05a                	sd	s6,32(sp)
    80004a82:	ec5e                	sd	s7,24(sp)
    80004a84:	e862                	sd	s8,16(sp)
    80004a86:	1080                	addi	s0,sp,96
    80004a88:	84aa                	mv	s1,a0
    80004a8a:	8b2e                	mv	s6,a1
    80004a8c:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004a8e:	ffffd097          	auipc	ra,0xffffd
    80004a92:	f86080e7          	jalr	-122(ra) # 80001a14 <myproc>
    80004a96:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004a98:	8526                	mv	a0,s1
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	1ae080e7          	jalr	430(ra) # 80000c48 <acquire>
  for(i = 0; i < n; i++){
    80004aa2:	09505763          	blez	s5,80004b30 <pipewrite+0xc0>
    80004aa6:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004aa8:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004aac:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ab0:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ab2:	2184a783          	lw	a5,536(s1)
    80004ab6:	21c4a703          	lw	a4,540(s1)
    80004aba:	2007879b          	addiw	a5,a5,512
    80004abe:	02f71b63          	bne	a4,a5,80004af4 <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004ac2:	2204a783          	lw	a5,544(s1)
    80004ac6:	c3d1                	beqz	a5,80004b4a <pipewrite+0xda>
    80004ac8:	03092783          	lw	a5,48(s2)
    80004acc:	efbd                	bnez	a5,80004b4a <pipewrite+0xda>
      wakeup(&pi->nread);
    80004ace:	8552                	mv	a0,s4
    80004ad0:	ffffe097          	auipc	ra,0xffffe
    80004ad4:	8dc080e7          	jalr	-1828(ra) # 800023ac <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ad8:	85a6                	mv	a1,s1
    80004ada:	854e                	mv	a0,s3
    80004adc:	ffffd097          	auipc	ra,0xffffd
    80004ae0:	750080e7          	jalr	1872(ra) # 8000222c <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ae4:	2184a783          	lw	a5,536(s1)
    80004ae8:	21c4a703          	lw	a4,540(s1)
    80004aec:	2007879b          	addiw	a5,a5,512
    80004af0:	fcf709e3          	beq	a4,a5,80004ac2 <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004af4:	4685                	li	a3,1
    80004af6:	865a                	mv	a2,s6
    80004af8:	faf40593          	addi	a1,s0,-81
    80004afc:	05093503          	ld	a0,80(s2)
    80004b00:	ffffd097          	auipc	ra,0xffffd
    80004b04:	c92080e7          	jalr	-878(ra) # 80001792 <copyin>
    80004b08:	03850563          	beq	a0,s8,80004b32 <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b0c:	21c4a783          	lw	a5,540(s1)
    80004b10:	0017871b          	addiw	a4,a5,1
    80004b14:	20e4ae23          	sw	a4,540(s1)
    80004b18:	1ff7f793          	andi	a5,a5,511
    80004b1c:	97a6                	add	a5,a5,s1
    80004b1e:	faf44703          	lbu	a4,-81(s0)
    80004b22:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004b26:	2b85                	addiw	s7,s7,1
    80004b28:	0b05                	addi	s6,s6,1
    80004b2a:	f97a94e3          	bne	s5,s7,80004ab2 <pipewrite+0x42>
    80004b2e:	a011                	j	80004b32 <pipewrite+0xc2>
    80004b30:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004b32:	21848513          	addi	a0,s1,536
    80004b36:	ffffe097          	auipc	ra,0xffffe
    80004b3a:	876080e7          	jalr	-1930(ra) # 800023ac <wakeup>
  release(&pi->lock);
    80004b3e:	8526                	mv	a0,s1
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	1bc080e7          	jalr	444(ra) # 80000cfc <release>
  return i;
    80004b48:	a039                	j	80004b56 <pipewrite+0xe6>
        release(&pi->lock);
    80004b4a:	8526                	mv	a0,s1
    80004b4c:	ffffc097          	auipc	ra,0xffffc
    80004b50:	1b0080e7          	jalr	432(ra) # 80000cfc <release>
        return -1;
    80004b54:	5bfd                	li	s7,-1
}
    80004b56:	855e                	mv	a0,s7
    80004b58:	60e6                	ld	ra,88(sp)
    80004b5a:	6446                	ld	s0,80(sp)
    80004b5c:	64a6                	ld	s1,72(sp)
    80004b5e:	6906                	ld	s2,64(sp)
    80004b60:	79e2                	ld	s3,56(sp)
    80004b62:	7a42                	ld	s4,48(sp)
    80004b64:	7aa2                	ld	s5,40(sp)
    80004b66:	7b02                	ld	s6,32(sp)
    80004b68:	6be2                	ld	s7,24(sp)
    80004b6a:	6c42                	ld	s8,16(sp)
    80004b6c:	6125                	addi	sp,sp,96
    80004b6e:	8082                	ret

0000000080004b70 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b70:	715d                	addi	sp,sp,-80
    80004b72:	e486                	sd	ra,72(sp)
    80004b74:	e0a2                	sd	s0,64(sp)
    80004b76:	fc26                	sd	s1,56(sp)
    80004b78:	f84a                	sd	s2,48(sp)
    80004b7a:	f44e                	sd	s3,40(sp)
    80004b7c:	f052                	sd	s4,32(sp)
    80004b7e:	ec56                	sd	s5,24(sp)
    80004b80:	e85a                	sd	s6,16(sp)
    80004b82:	0880                	addi	s0,sp,80
    80004b84:	84aa                	mv	s1,a0
    80004b86:	892e                	mv	s2,a1
    80004b88:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b8a:	ffffd097          	auipc	ra,0xffffd
    80004b8e:	e8a080e7          	jalr	-374(ra) # 80001a14 <myproc>
    80004b92:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b94:	8526                	mv	a0,s1
    80004b96:	ffffc097          	auipc	ra,0xffffc
    80004b9a:	0b2080e7          	jalr	178(ra) # 80000c48 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b9e:	2184a703          	lw	a4,536(s1)
    80004ba2:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ba6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004baa:	02f71463          	bne	a4,a5,80004bd2 <piperead+0x62>
    80004bae:	2244a783          	lw	a5,548(s1)
    80004bb2:	c385                	beqz	a5,80004bd2 <piperead+0x62>
    if(pr->killed){
    80004bb4:	030a2783          	lw	a5,48(s4)
    80004bb8:	ebc1                	bnez	a5,80004c48 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bba:	85a6                	mv	a1,s1
    80004bbc:	854e                	mv	a0,s3
    80004bbe:	ffffd097          	auipc	ra,0xffffd
    80004bc2:	66e080e7          	jalr	1646(ra) # 8000222c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bc6:	2184a703          	lw	a4,536(s1)
    80004bca:	21c4a783          	lw	a5,540(s1)
    80004bce:	fef700e3          	beq	a4,a5,80004bae <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bd2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bd4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bd6:	05505363          	blez	s5,80004c1c <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004bda:	2184a783          	lw	a5,536(s1)
    80004bde:	21c4a703          	lw	a4,540(s1)
    80004be2:	02f70d63          	beq	a4,a5,80004c1c <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004be6:	0017871b          	addiw	a4,a5,1
    80004bea:	20e4ac23          	sw	a4,536(s1)
    80004bee:	1ff7f793          	andi	a5,a5,511
    80004bf2:	97a6                	add	a5,a5,s1
    80004bf4:	0187c783          	lbu	a5,24(a5)
    80004bf8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bfc:	4685                	li	a3,1
    80004bfe:	fbf40613          	addi	a2,s0,-65
    80004c02:	85ca                	mv	a1,s2
    80004c04:	050a3503          	ld	a0,80(s4)
    80004c08:	ffffd097          	auipc	ra,0xffffd
    80004c0c:	afe080e7          	jalr	-1282(ra) # 80001706 <copyout>
    80004c10:	01650663          	beq	a0,s6,80004c1c <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c14:	2985                	addiw	s3,s3,1
    80004c16:	0905                	addi	s2,s2,1
    80004c18:	fd3a91e3          	bne	s5,s3,80004bda <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c1c:	21c48513          	addi	a0,s1,540
    80004c20:	ffffd097          	auipc	ra,0xffffd
    80004c24:	78c080e7          	jalr	1932(ra) # 800023ac <wakeup>
  release(&pi->lock);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	0d2080e7          	jalr	210(ra) # 80000cfc <release>
  return i;
}
    80004c32:	854e                	mv	a0,s3
    80004c34:	60a6                	ld	ra,72(sp)
    80004c36:	6406                	ld	s0,64(sp)
    80004c38:	74e2                	ld	s1,56(sp)
    80004c3a:	7942                	ld	s2,48(sp)
    80004c3c:	79a2                	ld	s3,40(sp)
    80004c3e:	7a02                	ld	s4,32(sp)
    80004c40:	6ae2                	ld	s5,24(sp)
    80004c42:	6b42                	ld	s6,16(sp)
    80004c44:	6161                	addi	sp,sp,80
    80004c46:	8082                	ret
      release(&pi->lock);
    80004c48:	8526                	mv	a0,s1
    80004c4a:	ffffc097          	auipc	ra,0xffffc
    80004c4e:	0b2080e7          	jalr	178(ra) # 80000cfc <release>
      return -1;
    80004c52:	59fd                	li	s3,-1
    80004c54:	bff9                	j	80004c32 <piperead+0xc2>

0000000080004c56 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004c56:	de010113          	addi	sp,sp,-544
    80004c5a:	20113c23          	sd	ra,536(sp)
    80004c5e:	20813823          	sd	s0,528(sp)
    80004c62:	20913423          	sd	s1,520(sp)
    80004c66:	21213023          	sd	s2,512(sp)
    80004c6a:	ffce                	sd	s3,504(sp)
    80004c6c:	fbd2                	sd	s4,496(sp)
    80004c6e:	f7d6                	sd	s5,488(sp)
    80004c70:	f3da                	sd	s6,480(sp)
    80004c72:	efde                	sd	s7,472(sp)
    80004c74:	ebe2                	sd	s8,464(sp)
    80004c76:	e7e6                	sd	s9,456(sp)
    80004c78:	e3ea                	sd	s10,448(sp)
    80004c7a:	ff6e                	sd	s11,440(sp)
    80004c7c:	1400                	addi	s0,sp,544
    80004c7e:	892a                	mv	s2,a0
    80004c80:	dea43423          	sd	a0,-536(s0)
    80004c84:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c88:	ffffd097          	auipc	ra,0xffffd
    80004c8c:	d8c080e7          	jalr	-628(ra) # 80001a14 <myproc>
    80004c90:	84aa                	mv	s1,a0

  begin_op();
    80004c92:	fffff097          	auipc	ra,0xfffff
    80004c96:	46c080e7          	jalr	1132(ra) # 800040fe <begin_op>

  if((ip = namei(path)) == 0){
    80004c9a:	854a                	mv	a0,s2
    80004c9c:	fffff097          	auipc	ra,0xfffff
    80004ca0:	256080e7          	jalr	598(ra) # 80003ef2 <namei>
    80004ca4:	c93d                	beqz	a0,80004d1a <exec+0xc4>
    80004ca6:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ca8:	fffff097          	auipc	ra,0xfffff
    80004cac:	a9a080e7          	jalr	-1382(ra) # 80003742 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cb0:	04000713          	li	a4,64
    80004cb4:	4681                	li	a3,0
    80004cb6:	e4840613          	addi	a2,s0,-440
    80004cba:	4581                	li	a1,0
    80004cbc:	8556                	mv	a0,s5
    80004cbe:	fffff097          	auipc	ra,0xfffff
    80004cc2:	d38080e7          	jalr	-712(ra) # 800039f6 <readi>
    80004cc6:	04000793          	li	a5,64
    80004cca:	00f51a63          	bne	a0,a5,80004cde <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004cce:	e4842703          	lw	a4,-440(s0)
    80004cd2:	464c47b7          	lui	a5,0x464c4
    80004cd6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cda:	04f70663          	beq	a4,a5,80004d26 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cde:	8556                	mv	a0,s5
    80004ce0:	fffff097          	auipc	ra,0xfffff
    80004ce4:	cc4080e7          	jalr	-828(ra) # 800039a4 <iunlockput>
    end_op();
    80004ce8:	fffff097          	auipc	ra,0xfffff
    80004cec:	496080e7          	jalr	1174(ra) # 8000417e <end_op>
  }
  return -1;
    80004cf0:	557d                	li	a0,-1
}
    80004cf2:	21813083          	ld	ra,536(sp)
    80004cf6:	21013403          	ld	s0,528(sp)
    80004cfa:	20813483          	ld	s1,520(sp)
    80004cfe:	20013903          	ld	s2,512(sp)
    80004d02:	79fe                	ld	s3,504(sp)
    80004d04:	7a5e                	ld	s4,496(sp)
    80004d06:	7abe                	ld	s5,488(sp)
    80004d08:	7b1e                	ld	s6,480(sp)
    80004d0a:	6bfe                	ld	s7,472(sp)
    80004d0c:	6c5e                	ld	s8,464(sp)
    80004d0e:	6cbe                	ld	s9,456(sp)
    80004d10:	6d1e                	ld	s10,448(sp)
    80004d12:	7dfa                	ld	s11,440(sp)
    80004d14:	22010113          	addi	sp,sp,544
    80004d18:	8082                	ret
    end_op();
    80004d1a:	fffff097          	auipc	ra,0xfffff
    80004d1e:	464080e7          	jalr	1124(ra) # 8000417e <end_op>
    return -1;
    80004d22:	557d                	li	a0,-1
    80004d24:	b7f9                	j	80004cf2 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d26:	8526                	mv	a0,s1
    80004d28:	ffffd097          	auipc	ra,0xffffd
    80004d2c:	db0080e7          	jalr	-592(ra) # 80001ad8 <proc_pagetable>
    80004d30:	8b2a                	mv	s6,a0
    80004d32:	d555                	beqz	a0,80004cde <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d34:	e6842783          	lw	a5,-408(s0)
    80004d38:	e8045703          	lhu	a4,-384(s0)
    80004d3c:	c735                	beqz	a4,80004da8 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d3e:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d40:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004d44:	6a05                	lui	s4,0x1
    80004d46:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004d4a:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004d4e:	6d85                	lui	s11,0x1
    80004d50:	7d7d                	lui	s10,0xfffff
    80004d52:	ac1d                	j	80004f88 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d54:	00004517          	auipc	a0,0x4
    80004d58:	98c50513          	addi	a0,a0,-1652 # 800086e0 <syscalls+0x2a0>
    80004d5c:	ffffb097          	auipc	ra,0xffffb
    80004d60:	7e6080e7          	jalr	2022(ra) # 80000542 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d64:	874a                	mv	a4,s2
    80004d66:	009c86bb          	addw	a3,s9,s1
    80004d6a:	4581                	li	a1,0
    80004d6c:	8556                	mv	a0,s5
    80004d6e:	fffff097          	auipc	ra,0xfffff
    80004d72:	c88080e7          	jalr	-888(ra) # 800039f6 <readi>
    80004d76:	2501                	sext.w	a0,a0
    80004d78:	1aa91863          	bne	s2,a0,80004f28 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004d7c:	009d84bb          	addw	s1,s11,s1
    80004d80:	013d09bb          	addw	s3,s10,s3
    80004d84:	1f74f263          	bgeu	s1,s7,80004f68 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004d88:	02049593          	slli	a1,s1,0x20
    80004d8c:	9181                	srli	a1,a1,0x20
    80004d8e:	95e2                	add	a1,a1,s8
    80004d90:	855a                	mv	a0,s6
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	340080e7          	jalr	832(ra) # 800010d2 <walkaddr>
    80004d9a:	862a                	mv	a2,a0
    if(pa == 0)
    80004d9c:	dd45                	beqz	a0,80004d54 <exec+0xfe>
      n = PGSIZE;
    80004d9e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004da0:	fd49f2e3          	bgeu	s3,s4,80004d64 <exec+0x10e>
      n = sz - i;
    80004da4:	894e                	mv	s2,s3
    80004da6:	bf7d                	j	80004d64 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004da8:	4481                	li	s1,0
  iunlockput(ip);
    80004daa:	8556                	mv	a0,s5
    80004dac:	fffff097          	auipc	ra,0xfffff
    80004db0:	bf8080e7          	jalr	-1032(ra) # 800039a4 <iunlockput>
  end_op();
    80004db4:	fffff097          	auipc	ra,0xfffff
    80004db8:	3ca080e7          	jalr	970(ra) # 8000417e <end_op>
  p = myproc();
    80004dbc:	ffffd097          	auipc	ra,0xffffd
    80004dc0:	c58080e7          	jalr	-936(ra) # 80001a14 <myproc>
    80004dc4:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004dc6:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004dca:	6785                	lui	a5,0x1
    80004dcc:	17fd                	addi	a5,a5,-1
    80004dce:	94be                	add	s1,s1,a5
    80004dd0:	77fd                	lui	a5,0xfffff
    80004dd2:	8fe5                	and	a5,a5,s1
    80004dd4:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004dd8:	6609                	lui	a2,0x2
    80004dda:	963e                	add	a2,a2,a5
    80004ddc:	85be                	mv	a1,a5
    80004dde:	855a                	mv	a0,s6
    80004de0:	ffffc097          	auipc	ra,0xffffc
    80004de4:	6d6080e7          	jalr	1750(ra) # 800014b6 <uvmalloc>
    80004de8:	8c2a                	mv	s8,a0
  ip = 0;
    80004dea:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004dec:	12050e63          	beqz	a0,80004f28 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004df0:	75f9                	lui	a1,0xffffe
    80004df2:	95aa                	add	a1,a1,a0
    80004df4:	855a                	mv	a0,s6
    80004df6:	ffffd097          	auipc	ra,0xffffd
    80004dfa:	8de080e7          	jalr	-1826(ra) # 800016d4 <uvmclear>
  stackbase = sp - PGSIZE;
    80004dfe:	7afd                	lui	s5,0xfffff
    80004e00:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e02:	df043783          	ld	a5,-528(s0)
    80004e06:	6388                	ld	a0,0(a5)
    80004e08:	c925                	beqz	a0,80004e78 <exec+0x222>
    80004e0a:	e8840993          	addi	s3,s0,-376
    80004e0e:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004e12:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e14:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004e16:	ffffc097          	auipc	ra,0xffffc
    80004e1a:	0b2080e7          	jalr	178(ra) # 80000ec8 <strlen>
    80004e1e:	0015079b          	addiw	a5,a0,1
    80004e22:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e26:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004e2a:	13596363          	bltu	s2,s5,80004f50 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e2e:	df043d83          	ld	s11,-528(s0)
    80004e32:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004e36:	8552                	mv	a0,s4
    80004e38:	ffffc097          	auipc	ra,0xffffc
    80004e3c:	090080e7          	jalr	144(ra) # 80000ec8 <strlen>
    80004e40:	0015069b          	addiw	a3,a0,1
    80004e44:	8652                	mv	a2,s4
    80004e46:	85ca                	mv	a1,s2
    80004e48:	855a                	mv	a0,s6
    80004e4a:	ffffd097          	auipc	ra,0xffffd
    80004e4e:	8bc080e7          	jalr	-1860(ra) # 80001706 <copyout>
    80004e52:	10054363          	bltz	a0,80004f58 <exec+0x302>
    ustack[argc] = sp;
    80004e56:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e5a:	0485                	addi	s1,s1,1
    80004e5c:	008d8793          	addi	a5,s11,8
    80004e60:	def43823          	sd	a5,-528(s0)
    80004e64:	008db503          	ld	a0,8(s11)
    80004e68:	c911                	beqz	a0,80004e7c <exec+0x226>
    if(argc >= MAXARG)
    80004e6a:	09a1                	addi	s3,s3,8
    80004e6c:	fb3c95e3          	bne	s9,s3,80004e16 <exec+0x1c0>
  sz = sz1;
    80004e70:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e74:	4a81                	li	s5,0
    80004e76:	a84d                	j	80004f28 <exec+0x2d2>
  sp = sz;
    80004e78:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e7a:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e7c:	00349793          	slli	a5,s1,0x3
    80004e80:	f9040713          	addi	a4,s0,-112
    80004e84:	97ba                	add	a5,a5,a4
    80004e86:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80004e8a:	00148693          	addi	a3,s1,1
    80004e8e:	068e                	slli	a3,a3,0x3
    80004e90:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e94:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e98:	01597663          	bgeu	s2,s5,80004ea4 <exec+0x24e>
  sz = sz1;
    80004e9c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ea0:	4a81                	li	s5,0
    80004ea2:	a059                	j	80004f28 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ea4:	e8840613          	addi	a2,s0,-376
    80004ea8:	85ca                	mv	a1,s2
    80004eaa:	855a                	mv	a0,s6
    80004eac:	ffffd097          	auipc	ra,0xffffd
    80004eb0:	85a080e7          	jalr	-1958(ra) # 80001706 <copyout>
    80004eb4:	0a054663          	bltz	a0,80004f60 <exec+0x30a>
  p->trapframe->a1 = sp;
    80004eb8:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004ebc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004ec0:	de843783          	ld	a5,-536(s0)
    80004ec4:	0007c703          	lbu	a4,0(a5)
    80004ec8:	cf11                	beqz	a4,80004ee4 <exec+0x28e>
    80004eca:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004ecc:	02f00693          	li	a3,47
    80004ed0:	a039                	j	80004ede <exec+0x288>
      last = s+1;
    80004ed2:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004ed6:	0785                	addi	a5,a5,1
    80004ed8:	fff7c703          	lbu	a4,-1(a5)
    80004edc:	c701                	beqz	a4,80004ee4 <exec+0x28e>
    if(*s == '/')
    80004ede:	fed71ce3          	bne	a4,a3,80004ed6 <exec+0x280>
    80004ee2:	bfc5                	j	80004ed2 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ee4:	4641                	li	a2,16
    80004ee6:	de843583          	ld	a1,-536(s0)
    80004eea:	158b8513          	addi	a0,s7,344
    80004eee:	ffffc097          	auipc	ra,0xffffc
    80004ef2:	fa8080e7          	jalr	-88(ra) # 80000e96 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ef6:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004efa:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004efe:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f02:	058bb783          	ld	a5,88(s7)
    80004f06:	e6043703          	ld	a4,-416(s0)
    80004f0a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f0c:	058bb783          	ld	a5,88(s7)
    80004f10:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f14:	85ea                	mv	a1,s10
    80004f16:	ffffd097          	auipc	ra,0xffffd
    80004f1a:	c5e080e7          	jalr	-930(ra) # 80001b74 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f1e:	0004851b          	sext.w	a0,s1
    80004f22:	bbc1                	j	80004cf2 <exec+0x9c>
    80004f24:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004f28:	df843583          	ld	a1,-520(s0)
    80004f2c:	855a                	mv	a0,s6
    80004f2e:	ffffd097          	auipc	ra,0xffffd
    80004f32:	c46080e7          	jalr	-954(ra) # 80001b74 <proc_freepagetable>
  if(ip){
    80004f36:	da0a94e3          	bnez	s5,80004cde <exec+0x88>
  return -1;
    80004f3a:	557d                	li	a0,-1
    80004f3c:	bb5d                	j	80004cf2 <exec+0x9c>
    80004f3e:	de943c23          	sd	s1,-520(s0)
    80004f42:	b7dd                	j	80004f28 <exec+0x2d2>
    80004f44:	de943c23          	sd	s1,-520(s0)
    80004f48:	b7c5                	j	80004f28 <exec+0x2d2>
    80004f4a:	de943c23          	sd	s1,-520(s0)
    80004f4e:	bfe9                	j	80004f28 <exec+0x2d2>
  sz = sz1;
    80004f50:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f54:	4a81                	li	s5,0
    80004f56:	bfc9                	j	80004f28 <exec+0x2d2>
  sz = sz1;
    80004f58:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f5c:	4a81                	li	s5,0
    80004f5e:	b7e9                	j	80004f28 <exec+0x2d2>
  sz = sz1;
    80004f60:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f64:	4a81                	li	s5,0
    80004f66:	b7c9                	j	80004f28 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f68:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f6c:	e0843783          	ld	a5,-504(s0)
    80004f70:	0017869b          	addiw	a3,a5,1
    80004f74:	e0d43423          	sd	a3,-504(s0)
    80004f78:	e0043783          	ld	a5,-512(s0)
    80004f7c:	0387879b          	addiw	a5,a5,56
    80004f80:	e8045703          	lhu	a4,-384(s0)
    80004f84:	e2e6d3e3          	bge	a3,a4,80004daa <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f88:	2781                	sext.w	a5,a5
    80004f8a:	e0f43023          	sd	a5,-512(s0)
    80004f8e:	03800713          	li	a4,56
    80004f92:	86be                	mv	a3,a5
    80004f94:	e1040613          	addi	a2,s0,-496
    80004f98:	4581                	li	a1,0
    80004f9a:	8556                	mv	a0,s5
    80004f9c:	fffff097          	auipc	ra,0xfffff
    80004fa0:	a5a080e7          	jalr	-1446(ra) # 800039f6 <readi>
    80004fa4:	03800793          	li	a5,56
    80004fa8:	f6f51ee3          	bne	a0,a5,80004f24 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004fac:	e1042783          	lw	a5,-496(s0)
    80004fb0:	4705                	li	a4,1
    80004fb2:	fae79de3          	bne	a5,a4,80004f6c <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004fb6:	e3843603          	ld	a2,-456(s0)
    80004fba:	e3043783          	ld	a5,-464(s0)
    80004fbe:	f8f660e3          	bltu	a2,a5,80004f3e <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fc2:	e2043783          	ld	a5,-480(s0)
    80004fc6:	963e                	add	a2,a2,a5
    80004fc8:	f6f66ee3          	bltu	a2,a5,80004f44 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fcc:	85a6                	mv	a1,s1
    80004fce:	855a                	mv	a0,s6
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	4e6080e7          	jalr	1254(ra) # 800014b6 <uvmalloc>
    80004fd8:	dea43c23          	sd	a0,-520(s0)
    80004fdc:	d53d                	beqz	a0,80004f4a <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80004fde:	e2043c03          	ld	s8,-480(s0)
    80004fe2:	de043783          	ld	a5,-544(s0)
    80004fe6:	00fc77b3          	and	a5,s8,a5
    80004fea:	ff9d                	bnez	a5,80004f28 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fec:	e1842c83          	lw	s9,-488(s0)
    80004ff0:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ff4:	f60b8ae3          	beqz	s7,80004f68 <exec+0x312>
    80004ff8:	89de                	mv	s3,s7
    80004ffa:	4481                	li	s1,0
    80004ffc:	b371                	j	80004d88 <exec+0x132>

0000000080004ffe <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ffe:	7179                	addi	sp,sp,-48
    80005000:	f406                	sd	ra,40(sp)
    80005002:	f022                	sd	s0,32(sp)
    80005004:	ec26                	sd	s1,24(sp)
    80005006:	e84a                	sd	s2,16(sp)
    80005008:	1800                	addi	s0,sp,48
    8000500a:	892e                	mv	s2,a1
    8000500c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000500e:	fdc40593          	addi	a1,s0,-36
    80005012:	ffffe097          	auipc	ra,0xffffe
    80005016:	af0080e7          	jalr	-1296(ra) # 80002b02 <argint>
    8000501a:	04054063          	bltz	a0,8000505a <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000501e:	fdc42703          	lw	a4,-36(s0)
    80005022:	47bd                	li	a5,15
    80005024:	02e7ed63          	bltu	a5,a4,8000505e <argfd+0x60>
    80005028:	ffffd097          	auipc	ra,0xffffd
    8000502c:	9ec080e7          	jalr	-1556(ra) # 80001a14 <myproc>
    80005030:	fdc42703          	lw	a4,-36(s0)
    80005034:	01a70793          	addi	a5,a4,26
    80005038:	078e                	slli	a5,a5,0x3
    8000503a:	953e                	add	a0,a0,a5
    8000503c:	611c                	ld	a5,0(a0)
    8000503e:	c395                	beqz	a5,80005062 <argfd+0x64>
    return -1;
  if(pfd)
    80005040:	00090463          	beqz	s2,80005048 <argfd+0x4a>
    *pfd = fd;
    80005044:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005048:	4501                	li	a0,0
  if(pf)
    8000504a:	c091                	beqz	s1,8000504e <argfd+0x50>
    *pf = f;
    8000504c:	e09c                	sd	a5,0(s1)
}
    8000504e:	70a2                	ld	ra,40(sp)
    80005050:	7402                	ld	s0,32(sp)
    80005052:	64e2                	ld	s1,24(sp)
    80005054:	6942                	ld	s2,16(sp)
    80005056:	6145                	addi	sp,sp,48
    80005058:	8082                	ret
    return -1;
    8000505a:	557d                	li	a0,-1
    8000505c:	bfcd                	j	8000504e <argfd+0x50>
    return -1;
    8000505e:	557d                	li	a0,-1
    80005060:	b7fd                	j	8000504e <argfd+0x50>
    80005062:	557d                	li	a0,-1
    80005064:	b7ed                	j	8000504e <argfd+0x50>

0000000080005066 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005066:	1101                	addi	sp,sp,-32
    80005068:	ec06                	sd	ra,24(sp)
    8000506a:	e822                	sd	s0,16(sp)
    8000506c:	e426                	sd	s1,8(sp)
    8000506e:	1000                	addi	s0,sp,32
    80005070:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005072:	ffffd097          	auipc	ra,0xffffd
    80005076:	9a2080e7          	jalr	-1630(ra) # 80001a14 <myproc>
    8000507a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000507c:	0d050793          	addi	a5,a0,208
    80005080:	4501                	li	a0,0
    80005082:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005084:	6398                	ld	a4,0(a5)
    80005086:	cb19                	beqz	a4,8000509c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005088:	2505                	addiw	a0,a0,1
    8000508a:	07a1                	addi	a5,a5,8
    8000508c:	fed51ce3          	bne	a0,a3,80005084 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005090:	557d                	li	a0,-1
}
    80005092:	60e2                	ld	ra,24(sp)
    80005094:	6442                	ld	s0,16(sp)
    80005096:	64a2                	ld	s1,8(sp)
    80005098:	6105                	addi	sp,sp,32
    8000509a:	8082                	ret
      p->ofile[fd] = f;
    8000509c:	01a50793          	addi	a5,a0,26
    800050a0:	078e                	slli	a5,a5,0x3
    800050a2:	963e                	add	a2,a2,a5
    800050a4:	e204                	sd	s1,0(a2)
      return fd;
    800050a6:	b7f5                	j	80005092 <fdalloc+0x2c>

00000000800050a8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050a8:	715d                	addi	sp,sp,-80
    800050aa:	e486                	sd	ra,72(sp)
    800050ac:	e0a2                	sd	s0,64(sp)
    800050ae:	fc26                	sd	s1,56(sp)
    800050b0:	f84a                	sd	s2,48(sp)
    800050b2:	f44e                	sd	s3,40(sp)
    800050b4:	f052                	sd	s4,32(sp)
    800050b6:	ec56                	sd	s5,24(sp)
    800050b8:	0880                	addi	s0,sp,80
    800050ba:	89ae                	mv	s3,a1
    800050bc:	8ab2                	mv	s5,a2
    800050be:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050c0:	fb040593          	addi	a1,s0,-80
    800050c4:	fffff097          	auipc	ra,0xfffff
    800050c8:	e4c080e7          	jalr	-436(ra) # 80003f10 <nameiparent>
    800050cc:	892a                	mv	s2,a0
    800050ce:	12050e63          	beqz	a0,8000520a <create+0x162>
    return 0;

  ilock(dp);
    800050d2:	ffffe097          	auipc	ra,0xffffe
    800050d6:	670080e7          	jalr	1648(ra) # 80003742 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050da:	4601                	li	a2,0
    800050dc:	fb040593          	addi	a1,s0,-80
    800050e0:	854a                	mv	a0,s2
    800050e2:	fffff097          	auipc	ra,0xfffff
    800050e6:	b3e080e7          	jalr	-1218(ra) # 80003c20 <dirlookup>
    800050ea:	84aa                	mv	s1,a0
    800050ec:	c921                	beqz	a0,8000513c <create+0x94>
    iunlockput(dp);
    800050ee:	854a                	mv	a0,s2
    800050f0:	fffff097          	auipc	ra,0xfffff
    800050f4:	8b4080e7          	jalr	-1868(ra) # 800039a4 <iunlockput>
    ilock(ip);
    800050f8:	8526                	mv	a0,s1
    800050fa:	ffffe097          	auipc	ra,0xffffe
    800050fe:	648080e7          	jalr	1608(ra) # 80003742 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005102:	2981                	sext.w	s3,s3
    80005104:	4789                	li	a5,2
    80005106:	02f99463          	bne	s3,a5,8000512e <create+0x86>
    8000510a:	0444d783          	lhu	a5,68(s1)
    8000510e:	37f9                	addiw	a5,a5,-2
    80005110:	17c2                	slli	a5,a5,0x30
    80005112:	93c1                	srli	a5,a5,0x30
    80005114:	4705                	li	a4,1
    80005116:	00f76c63          	bltu	a4,a5,8000512e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000511a:	8526                	mv	a0,s1
    8000511c:	60a6                	ld	ra,72(sp)
    8000511e:	6406                	ld	s0,64(sp)
    80005120:	74e2                	ld	s1,56(sp)
    80005122:	7942                	ld	s2,48(sp)
    80005124:	79a2                	ld	s3,40(sp)
    80005126:	7a02                	ld	s4,32(sp)
    80005128:	6ae2                	ld	s5,24(sp)
    8000512a:	6161                	addi	sp,sp,80
    8000512c:	8082                	ret
    iunlockput(ip);
    8000512e:	8526                	mv	a0,s1
    80005130:	fffff097          	auipc	ra,0xfffff
    80005134:	874080e7          	jalr	-1932(ra) # 800039a4 <iunlockput>
    return 0;
    80005138:	4481                	li	s1,0
    8000513a:	b7c5                	j	8000511a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000513c:	85ce                	mv	a1,s3
    8000513e:	00092503          	lw	a0,0(s2)
    80005142:	ffffe097          	auipc	ra,0xffffe
    80005146:	468080e7          	jalr	1128(ra) # 800035aa <ialloc>
    8000514a:	84aa                	mv	s1,a0
    8000514c:	c521                	beqz	a0,80005194 <create+0xec>
  ilock(ip);
    8000514e:	ffffe097          	auipc	ra,0xffffe
    80005152:	5f4080e7          	jalr	1524(ra) # 80003742 <ilock>
  ip->major = major;
    80005156:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000515a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000515e:	4a05                	li	s4,1
    80005160:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005164:	8526                	mv	a0,s1
    80005166:	ffffe097          	auipc	ra,0xffffe
    8000516a:	512080e7          	jalr	1298(ra) # 80003678 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000516e:	2981                	sext.w	s3,s3
    80005170:	03498a63          	beq	s3,s4,800051a4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005174:	40d0                	lw	a2,4(s1)
    80005176:	fb040593          	addi	a1,s0,-80
    8000517a:	854a                	mv	a0,s2
    8000517c:	fffff097          	auipc	ra,0xfffff
    80005180:	cb4080e7          	jalr	-844(ra) # 80003e30 <dirlink>
    80005184:	06054b63          	bltz	a0,800051fa <create+0x152>
  iunlockput(dp);
    80005188:	854a                	mv	a0,s2
    8000518a:	fffff097          	auipc	ra,0xfffff
    8000518e:	81a080e7          	jalr	-2022(ra) # 800039a4 <iunlockput>
  return ip;
    80005192:	b761                	j	8000511a <create+0x72>
    panic("create: ialloc");
    80005194:	00003517          	auipc	a0,0x3
    80005198:	56c50513          	addi	a0,a0,1388 # 80008700 <syscalls+0x2c0>
    8000519c:	ffffb097          	auipc	ra,0xffffb
    800051a0:	3a6080e7          	jalr	934(ra) # 80000542 <panic>
    dp->nlink++;  // for ".."
    800051a4:	04a95783          	lhu	a5,74(s2)
    800051a8:	2785                	addiw	a5,a5,1
    800051aa:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800051ae:	854a                	mv	a0,s2
    800051b0:	ffffe097          	auipc	ra,0xffffe
    800051b4:	4c8080e7          	jalr	1224(ra) # 80003678 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051b8:	40d0                	lw	a2,4(s1)
    800051ba:	00003597          	auipc	a1,0x3
    800051be:	55658593          	addi	a1,a1,1366 # 80008710 <syscalls+0x2d0>
    800051c2:	8526                	mv	a0,s1
    800051c4:	fffff097          	auipc	ra,0xfffff
    800051c8:	c6c080e7          	jalr	-916(ra) # 80003e30 <dirlink>
    800051cc:	00054f63          	bltz	a0,800051ea <create+0x142>
    800051d0:	00492603          	lw	a2,4(s2)
    800051d4:	00003597          	auipc	a1,0x3
    800051d8:	54458593          	addi	a1,a1,1348 # 80008718 <syscalls+0x2d8>
    800051dc:	8526                	mv	a0,s1
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	c52080e7          	jalr	-942(ra) # 80003e30 <dirlink>
    800051e6:	f80557e3          	bgez	a0,80005174 <create+0xcc>
      panic("create dots");
    800051ea:	00003517          	auipc	a0,0x3
    800051ee:	53650513          	addi	a0,a0,1334 # 80008720 <syscalls+0x2e0>
    800051f2:	ffffb097          	auipc	ra,0xffffb
    800051f6:	350080e7          	jalr	848(ra) # 80000542 <panic>
    panic("create: dirlink");
    800051fa:	00003517          	auipc	a0,0x3
    800051fe:	53650513          	addi	a0,a0,1334 # 80008730 <syscalls+0x2f0>
    80005202:	ffffb097          	auipc	ra,0xffffb
    80005206:	340080e7          	jalr	832(ra) # 80000542 <panic>
    return 0;
    8000520a:	84aa                	mv	s1,a0
    8000520c:	b739                	j	8000511a <create+0x72>

000000008000520e <sys_dup>:
{
    8000520e:	7179                	addi	sp,sp,-48
    80005210:	f406                	sd	ra,40(sp)
    80005212:	f022                	sd	s0,32(sp)
    80005214:	ec26                	sd	s1,24(sp)
    80005216:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005218:	fd840613          	addi	a2,s0,-40
    8000521c:	4581                	li	a1,0
    8000521e:	4501                	li	a0,0
    80005220:	00000097          	auipc	ra,0x0
    80005224:	dde080e7          	jalr	-546(ra) # 80004ffe <argfd>
    return -1;
    80005228:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000522a:	02054363          	bltz	a0,80005250 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000522e:	fd843503          	ld	a0,-40(s0)
    80005232:	00000097          	auipc	ra,0x0
    80005236:	e34080e7          	jalr	-460(ra) # 80005066 <fdalloc>
    8000523a:	84aa                	mv	s1,a0
    return -1;
    8000523c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000523e:	00054963          	bltz	a0,80005250 <sys_dup+0x42>
  filedup(f);
    80005242:	fd843503          	ld	a0,-40(s0)
    80005246:	fffff097          	auipc	ra,0xfffff
    8000524a:	338080e7          	jalr	824(ra) # 8000457e <filedup>
  return fd;
    8000524e:	87a6                	mv	a5,s1
}
    80005250:	853e                	mv	a0,a5
    80005252:	70a2                	ld	ra,40(sp)
    80005254:	7402                	ld	s0,32(sp)
    80005256:	64e2                	ld	s1,24(sp)
    80005258:	6145                	addi	sp,sp,48
    8000525a:	8082                	ret

000000008000525c <sys_read>:
{
    8000525c:	7179                	addi	sp,sp,-48
    8000525e:	f406                	sd	ra,40(sp)
    80005260:	f022                	sd	s0,32(sp)
    80005262:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005264:	fe840613          	addi	a2,s0,-24
    80005268:	4581                	li	a1,0
    8000526a:	4501                	li	a0,0
    8000526c:	00000097          	auipc	ra,0x0
    80005270:	d92080e7          	jalr	-622(ra) # 80004ffe <argfd>
    return -1;
    80005274:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005276:	04054163          	bltz	a0,800052b8 <sys_read+0x5c>
    8000527a:	fe440593          	addi	a1,s0,-28
    8000527e:	4509                	li	a0,2
    80005280:	ffffe097          	auipc	ra,0xffffe
    80005284:	882080e7          	jalr	-1918(ra) # 80002b02 <argint>
    return -1;
    80005288:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000528a:	02054763          	bltz	a0,800052b8 <sys_read+0x5c>
    8000528e:	fd840593          	addi	a1,s0,-40
    80005292:	4505                	li	a0,1
    80005294:	ffffe097          	auipc	ra,0xffffe
    80005298:	890080e7          	jalr	-1904(ra) # 80002b24 <argaddr>
    return -1;
    8000529c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000529e:	00054d63          	bltz	a0,800052b8 <sys_read+0x5c>
  return fileread(f, p, n);
    800052a2:	fe442603          	lw	a2,-28(s0)
    800052a6:	fd843583          	ld	a1,-40(s0)
    800052aa:	fe843503          	ld	a0,-24(s0)
    800052ae:	fffff097          	auipc	ra,0xfffff
    800052b2:	45c080e7          	jalr	1116(ra) # 8000470a <fileread>
    800052b6:	87aa                	mv	a5,a0
}
    800052b8:	853e                	mv	a0,a5
    800052ba:	70a2                	ld	ra,40(sp)
    800052bc:	7402                	ld	s0,32(sp)
    800052be:	6145                	addi	sp,sp,48
    800052c0:	8082                	ret

00000000800052c2 <sys_write>:
{
    800052c2:	7179                	addi	sp,sp,-48
    800052c4:	f406                	sd	ra,40(sp)
    800052c6:	f022                	sd	s0,32(sp)
    800052c8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052ca:	fe840613          	addi	a2,s0,-24
    800052ce:	4581                	li	a1,0
    800052d0:	4501                	li	a0,0
    800052d2:	00000097          	auipc	ra,0x0
    800052d6:	d2c080e7          	jalr	-724(ra) # 80004ffe <argfd>
    return -1;
    800052da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052dc:	04054163          	bltz	a0,8000531e <sys_write+0x5c>
    800052e0:	fe440593          	addi	a1,s0,-28
    800052e4:	4509                	li	a0,2
    800052e6:	ffffe097          	auipc	ra,0xffffe
    800052ea:	81c080e7          	jalr	-2020(ra) # 80002b02 <argint>
    return -1;
    800052ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052f0:	02054763          	bltz	a0,8000531e <sys_write+0x5c>
    800052f4:	fd840593          	addi	a1,s0,-40
    800052f8:	4505                	li	a0,1
    800052fa:	ffffe097          	auipc	ra,0xffffe
    800052fe:	82a080e7          	jalr	-2006(ra) # 80002b24 <argaddr>
    return -1;
    80005302:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005304:	00054d63          	bltz	a0,8000531e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005308:	fe442603          	lw	a2,-28(s0)
    8000530c:	fd843583          	ld	a1,-40(s0)
    80005310:	fe843503          	ld	a0,-24(s0)
    80005314:	fffff097          	auipc	ra,0xfffff
    80005318:	4b8080e7          	jalr	1208(ra) # 800047cc <filewrite>
    8000531c:	87aa                	mv	a5,a0
}
    8000531e:	853e                	mv	a0,a5
    80005320:	70a2                	ld	ra,40(sp)
    80005322:	7402                	ld	s0,32(sp)
    80005324:	6145                	addi	sp,sp,48
    80005326:	8082                	ret

0000000080005328 <sys_close>:
{
    80005328:	1101                	addi	sp,sp,-32
    8000532a:	ec06                	sd	ra,24(sp)
    8000532c:	e822                	sd	s0,16(sp)
    8000532e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005330:	fe040613          	addi	a2,s0,-32
    80005334:	fec40593          	addi	a1,s0,-20
    80005338:	4501                	li	a0,0
    8000533a:	00000097          	auipc	ra,0x0
    8000533e:	cc4080e7          	jalr	-828(ra) # 80004ffe <argfd>
    return -1;
    80005342:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005344:	02054463          	bltz	a0,8000536c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005348:	ffffc097          	auipc	ra,0xffffc
    8000534c:	6cc080e7          	jalr	1740(ra) # 80001a14 <myproc>
    80005350:	fec42783          	lw	a5,-20(s0)
    80005354:	07e9                	addi	a5,a5,26
    80005356:	078e                	slli	a5,a5,0x3
    80005358:	97aa                	add	a5,a5,a0
    8000535a:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000535e:	fe043503          	ld	a0,-32(s0)
    80005362:	fffff097          	auipc	ra,0xfffff
    80005366:	26e080e7          	jalr	622(ra) # 800045d0 <fileclose>
  return 0;
    8000536a:	4781                	li	a5,0
}
    8000536c:	853e                	mv	a0,a5
    8000536e:	60e2                	ld	ra,24(sp)
    80005370:	6442                	ld	s0,16(sp)
    80005372:	6105                	addi	sp,sp,32
    80005374:	8082                	ret

0000000080005376 <sys_fstat>:
{
    80005376:	1101                	addi	sp,sp,-32
    80005378:	ec06                	sd	ra,24(sp)
    8000537a:	e822                	sd	s0,16(sp)
    8000537c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000537e:	fe840613          	addi	a2,s0,-24
    80005382:	4581                	li	a1,0
    80005384:	4501                	li	a0,0
    80005386:	00000097          	auipc	ra,0x0
    8000538a:	c78080e7          	jalr	-904(ra) # 80004ffe <argfd>
    return -1;
    8000538e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005390:	02054563          	bltz	a0,800053ba <sys_fstat+0x44>
    80005394:	fe040593          	addi	a1,s0,-32
    80005398:	4505                	li	a0,1
    8000539a:	ffffd097          	auipc	ra,0xffffd
    8000539e:	78a080e7          	jalr	1930(ra) # 80002b24 <argaddr>
    return -1;
    800053a2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053a4:	00054b63          	bltz	a0,800053ba <sys_fstat+0x44>
  return filestat(f, st);
    800053a8:	fe043583          	ld	a1,-32(s0)
    800053ac:	fe843503          	ld	a0,-24(s0)
    800053b0:	fffff097          	auipc	ra,0xfffff
    800053b4:	2e8080e7          	jalr	744(ra) # 80004698 <filestat>
    800053b8:	87aa                	mv	a5,a0
}
    800053ba:	853e                	mv	a0,a5
    800053bc:	60e2                	ld	ra,24(sp)
    800053be:	6442                	ld	s0,16(sp)
    800053c0:	6105                	addi	sp,sp,32
    800053c2:	8082                	ret

00000000800053c4 <sys_link>:
{
    800053c4:	7169                	addi	sp,sp,-304
    800053c6:	f606                	sd	ra,296(sp)
    800053c8:	f222                	sd	s0,288(sp)
    800053ca:	ee26                	sd	s1,280(sp)
    800053cc:	ea4a                	sd	s2,272(sp)
    800053ce:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053d0:	08000613          	li	a2,128
    800053d4:	ed040593          	addi	a1,s0,-304
    800053d8:	4501                	li	a0,0
    800053da:	ffffd097          	auipc	ra,0xffffd
    800053de:	76c080e7          	jalr	1900(ra) # 80002b46 <argstr>
    return -1;
    800053e2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053e4:	10054e63          	bltz	a0,80005500 <sys_link+0x13c>
    800053e8:	08000613          	li	a2,128
    800053ec:	f5040593          	addi	a1,s0,-176
    800053f0:	4505                	li	a0,1
    800053f2:	ffffd097          	auipc	ra,0xffffd
    800053f6:	754080e7          	jalr	1876(ra) # 80002b46 <argstr>
    return -1;
    800053fa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053fc:	10054263          	bltz	a0,80005500 <sys_link+0x13c>
  begin_op();
    80005400:	fffff097          	auipc	ra,0xfffff
    80005404:	cfe080e7          	jalr	-770(ra) # 800040fe <begin_op>
  if((ip = namei(old)) == 0){
    80005408:	ed040513          	addi	a0,s0,-304
    8000540c:	fffff097          	auipc	ra,0xfffff
    80005410:	ae6080e7          	jalr	-1306(ra) # 80003ef2 <namei>
    80005414:	84aa                	mv	s1,a0
    80005416:	c551                	beqz	a0,800054a2 <sys_link+0xde>
  ilock(ip);
    80005418:	ffffe097          	auipc	ra,0xffffe
    8000541c:	32a080e7          	jalr	810(ra) # 80003742 <ilock>
  if(ip->type == T_DIR){
    80005420:	04449703          	lh	a4,68(s1)
    80005424:	4785                	li	a5,1
    80005426:	08f70463          	beq	a4,a5,800054ae <sys_link+0xea>
  ip->nlink++;
    8000542a:	04a4d783          	lhu	a5,74(s1)
    8000542e:	2785                	addiw	a5,a5,1
    80005430:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005434:	8526                	mv	a0,s1
    80005436:	ffffe097          	auipc	ra,0xffffe
    8000543a:	242080e7          	jalr	578(ra) # 80003678 <iupdate>
  iunlock(ip);
    8000543e:	8526                	mv	a0,s1
    80005440:	ffffe097          	auipc	ra,0xffffe
    80005444:	3c4080e7          	jalr	964(ra) # 80003804 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005448:	fd040593          	addi	a1,s0,-48
    8000544c:	f5040513          	addi	a0,s0,-176
    80005450:	fffff097          	auipc	ra,0xfffff
    80005454:	ac0080e7          	jalr	-1344(ra) # 80003f10 <nameiparent>
    80005458:	892a                	mv	s2,a0
    8000545a:	c935                	beqz	a0,800054ce <sys_link+0x10a>
  ilock(dp);
    8000545c:	ffffe097          	auipc	ra,0xffffe
    80005460:	2e6080e7          	jalr	742(ra) # 80003742 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005464:	00092703          	lw	a4,0(s2)
    80005468:	409c                	lw	a5,0(s1)
    8000546a:	04f71d63          	bne	a4,a5,800054c4 <sys_link+0x100>
    8000546e:	40d0                	lw	a2,4(s1)
    80005470:	fd040593          	addi	a1,s0,-48
    80005474:	854a                	mv	a0,s2
    80005476:	fffff097          	auipc	ra,0xfffff
    8000547a:	9ba080e7          	jalr	-1606(ra) # 80003e30 <dirlink>
    8000547e:	04054363          	bltz	a0,800054c4 <sys_link+0x100>
  iunlockput(dp);
    80005482:	854a                	mv	a0,s2
    80005484:	ffffe097          	auipc	ra,0xffffe
    80005488:	520080e7          	jalr	1312(ra) # 800039a4 <iunlockput>
  iput(ip);
    8000548c:	8526                	mv	a0,s1
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	46e080e7          	jalr	1134(ra) # 800038fc <iput>
  end_op();
    80005496:	fffff097          	auipc	ra,0xfffff
    8000549a:	ce8080e7          	jalr	-792(ra) # 8000417e <end_op>
  return 0;
    8000549e:	4781                	li	a5,0
    800054a0:	a085                	j	80005500 <sys_link+0x13c>
    end_op();
    800054a2:	fffff097          	auipc	ra,0xfffff
    800054a6:	cdc080e7          	jalr	-804(ra) # 8000417e <end_op>
    return -1;
    800054aa:	57fd                	li	a5,-1
    800054ac:	a891                	j	80005500 <sys_link+0x13c>
    iunlockput(ip);
    800054ae:	8526                	mv	a0,s1
    800054b0:	ffffe097          	auipc	ra,0xffffe
    800054b4:	4f4080e7          	jalr	1268(ra) # 800039a4 <iunlockput>
    end_op();
    800054b8:	fffff097          	auipc	ra,0xfffff
    800054bc:	cc6080e7          	jalr	-826(ra) # 8000417e <end_op>
    return -1;
    800054c0:	57fd                	li	a5,-1
    800054c2:	a83d                	j	80005500 <sys_link+0x13c>
    iunlockput(dp);
    800054c4:	854a                	mv	a0,s2
    800054c6:	ffffe097          	auipc	ra,0xffffe
    800054ca:	4de080e7          	jalr	1246(ra) # 800039a4 <iunlockput>
  ilock(ip);
    800054ce:	8526                	mv	a0,s1
    800054d0:	ffffe097          	auipc	ra,0xffffe
    800054d4:	272080e7          	jalr	626(ra) # 80003742 <ilock>
  ip->nlink--;
    800054d8:	04a4d783          	lhu	a5,74(s1)
    800054dc:	37fd                	addiw	a5,a5,-1
    800054de:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054e2:	8526                	mv	a0,s1
    800054e4:	ffffe097          	auipc	ra,0xffffe
    800054e8:	194080e7          	jalr	404(ra) # 80003678 <iupdate>
  iunlockput(ip);
    800054ec:	8526                	mv	a0,s1
    800054ee:	ffffe097          	auipc	ra,0xffffe
    800054f2:	4b6080e7          	jalr	1206(ra) # 800039a4 <iunlockput>
  end_op();
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	c88080e7          	jalr	-888(ra) # 8000417e <end_op>
  return -1;
    800054fe:	57fd                	li	a5,-1
}
    80005500:	853e                	mv	a0,a5
    80005502:	70b2                	ld	ra,296(sp)
    80005504:	7412                	ld	s0,288(sp)
    80005506:	64f2                	ld	s1,280(sp)
    80005508:	6952                	ld	s2,272(sp)
    8000550a:	6155                	addi	sp,sp,304
    8000550c:	8082                	ret

000000008000550e <sys_unlink>:
{
    8000550e:	7151                	addi	sp,sp,-240
    80005510:	f586                	sd	ra,232(sp)
    80005512:	f1a2                	sd	s0,224(sp)
    80005514:	eda6                	sd	s1,216(sp)
    80005516:	e9ca                	sd	s2,208(sp)
    80005518:	e5ce                	sd	s3,200(sp)
    8000551a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000551c:	08000613          	li	a2,128
    80005520:	f3040593          	addi	a1,s0,-208
    80005524:	4501                	li	a0,0
    80005526:	ffffd097          	auipc	ra,0xffffd
    8000552a:	620080e7          	jalr	1568(ra) # 80002b46 <argstr>
    8000552e:	18054163          	bltz	a0,800056b0 <sys_unlink+0x1a2>
  begin_op();
    80005532:	fffff097          	auipc	ra,0xfffff
    80005536:	bcc080e7          	jalr	-1076(ra) # 800040fe <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000553a:	fb040593          	addi	a1,s0,-80
    8000553e:	f3040513          	addi	a0,s0,-208
    80005542:	fffff097          	auipc	ra,0xfffff
    80005546:	9ce080e7          	jalr	-1586(ra) # 80003f10 <nameiparent>
    8000554a:	84aa                	mv	s1,a0
    8000554c:	c979                	beqz	a0,80005622 <sys_unlink+0x114>
  ilock(dp);
    8000554e:	ffffe097          	auipc	ra,0xffffe
    80005552:	1f4080e7          	jalr	500(ra) # 80003742 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005556:	00003597          	auipc	a1,0x3
    8000555a:	1ba58593          	addi	a1,a1,442 # 80008710 <syscalls+0x2d0>
    8000555e:	fb040513          	addi	a0,s0,-80
    80005562:	ffffe097          	auipc	ra,0xffffe
    80005566:	6a4080e7          	jalr	1700(ra) # 80003c06 <namecmp>
    8000556a:	14050a63          	beqz	a0,800056be <sys_unlink+0x1b0>
    8000556e:	00003597          	auipc	a1,0x3
    80005572:	1aa58593          	addi	a1,a1,426 # 80008718 <syscalls+0x2d8>
    80005576:	fb040513          	addi	a0,s0,-80
    8000557a:	ffffe097          	auipc	ra,0xffffe
    8000557e:	68c080e7          	jalr	1676(ra) # 80003c06 <namecmp>
    80005582:	12050e63          	beqz	a0,800056be <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005586:	f2c40613          	addi	a2,s0,-212
    8000558a:	fb040593          	addi	a1,s0,-80
    8000558e:	8526                	mv	a0,s1
    80005590:	ffffe097          	auipc	ra,0xffffe
    80005594:	690080e7          	jalr	1680(ra) # 80003c20 <dirlookup>
    80005598:	892a                	mv	s2,a0
    8000559a:	12050263          	beqz	a0,800056be <sys_unlink+0x1b0>
  ilock(ip);
    8000559e:	ffffe097          	auipc	ra,0xffffe
    800055a2:	1a4080e7          	jalr	420(ra) # 80003742 <ilock>
  if(ip->nlink < 1)
    800055a6:	04a91783          	lh	a5,74(s2)
    800055aa:	08f05263          	blez	a5,8000562e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055ae:	04491703          	lh	a4,68(s2)
    800055b2:	4785                	li	a5,1
    800055b4:	08f70563          	beq	a4,a5,8000563e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055b8:	4641                	li	a2,16
    800055ba:	4581                	li	a1,0
    800055bc:	fc040513          	addi	a0,s0,-64
    800055c0:	ffffb097          	auipc	ra,0xffffb
    800055c4:	784080e7          	jalr	1924(ra) # 80000d44 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055c8:	4741                	li	a4,16
    800055ca:	f2c42683          	lw	a3,-212(s0)
    800055ce:	fc040613          	addi	a2,s0,-64
    800055d2:	4581                	li	a1,0
    800055d4:	8526                	mv	a0,s1
    800055d6:	ffffe097          	auipc	ra,0xffffe
    800055da:	516080e7          	jalr	1302(ra) # 80003aec <writei>
    800055de:	47c1                	li	a5,16
    800055e0:	0af51563          	bne	a0,a5,8000568a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055e4:	04491703          	lh	a4,68(s2)
    800055e8:	4785                	li	a5,1
    800055ea:	0af70863          	beq	a4,a5,8000569a <sys_unlink+0x18c>
  iunlockput(dp);
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	3b4080e7          	jalr	948(ra) # 800039a4 <iunlockput>
  ip->nlink--;
    800055f8:	04a95783          	lhu	a5,74(s2)
    800055fc:	37fd                	addiw	a5,a5,-1
    800055fe:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005602:	854a                	mv	a0,s2
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	074080e7          	jalr	116(ra) # 80003678 <iupdate>
  iunlockput(ip);
    8000560c:	854a                	mv	a0,s2
    8000560e:	ffffe097          	auipc	ra,0xffffe
    80005612:	396080e7          	jalr	918(ra) # 800039a4 <iunlockput>
  end_op();
    80005616:	fffff097          	auipc	ra,0xfffff
    8000561a:	b68080e7          	jalr	-1176(ra) # 8000417e <end_op>
  return 0;
    8000561e:	4501                	li	a0,0
    80005620:	a84d                	j	800056d2 <sys_unlink+0x1c4>
    end_op();
    80005622:	fffff097          	auipc	ra,0xfffff
    80005626:	b5c080e7          	jalr	-1188(ra) # 8000417e <end_op>
    return -1;
    8000562a:	557d                	li	a0,-1
    8000562c:	a05d                	j	800056d2 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000562e:	00003517          	auipc	a0,0x3
    80005632:	11250513          	addi	a0,a0,274 # 80008740 <syscalls+0x300>
    80005636:	ffffb097          	auipc	ra,0xffffb
    8000563a:	f0c080e7          	jalr	-244(ra) # 80000542 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000563e:	04c92703          	lw	a4,76(s2)
    80005642:	02000793          	li	a5,32
    80005646:	f6e7f9e3          	bgeu	a5,a4,800055b8 <sys_unlink+0xaa>
    8000564a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000564e:	4741                	li	a4,16
    80005650:	86ce                	mv	a3,s3
    80005652:	f1840613          	addi	a2,s0,-232
    80005656:	4581                	li	a1,0
    80005658:	854a                	mv	a0,s2
    8000565a:	ffffe097          	auipc	ra,0xffffe
    8000565e:	39c080e7          	jalr	924(ra) # 800039f6 <readi>
    80005662:	47c1                	li	a5,16
    80005664:	00f51b63          	bne	a0,a5,8000567a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005668:	f1845783          	lhu	a5,-232(s0)
    8000566c:	e7a1                	bnez	a5,800056b4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000566e:	29c1                	addiw	s3,s3,16
    80005670:	04c92783          	lw	a5,76(s2)
    80005674:	fcf9ede3          	bltu	s3,a5,8000564e <sys_unlink+0x140>
    80005678:	b781                	j	800055b8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000567a:	00003517          	auipc	a0,0x3
    8000567e:	0de50513          	addi	a0,a0,222 # 80008758 <syscalls+0x318>
    80005682:	ffffb097          	auipc	ra,0xffffb
    80005686:	ec0080e7          	jalr	-320(ra) # 80000542 <panic>
    panic("unlink: writei");
    8000568a:	00003517          	auipc	a0,0x3
    8000568e:	0e650513          	addi	a0,a0,230 # 80008770 <syscalls+0x330>
    80005692:	ffffb097          	auipc	ra,0xffffb
    80005696:	eb0080e7          	jalr	-336(ra) # 80000542 <panic>
    dp->nlink--;
    8000569a:	04a4d783          	lhu	a5,74(s1)
    8000569e:	37fd                	addiw	a5,a5,-1
    800056a0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056a4:	8526                	mv	a0,s1
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	fd2080e7          	jalr	-46(ra) # 80003678 <iupdate>
    800056ae:	b781                	j	800055ee <sys_unlink+0xe0>
    return -1;
    800056b0:	557d                	li	a0,-1
    800056b2:	a005                	j	800056d2 <sys_unlink+0x1c4>
    iunlockput(ip);
    800056b4:	854a                	mv	a0,s2
    800056b6:	ffffe097          	auipc	ra,0xffffe
    800056ba:	2ee080e7          	jalr	750(ra) # 800039a4 <iunlockput>
  iunlockput(dp);
    800056be:	8526                	mv	a0,s1
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	2e4080e7          	jalr	740(ra) # 800039a4 <iunlockput>
  end_op();
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	ab6080e7          	jalr	-1354(ra) # 8000417e <end_op>
  return -1;
    800056d0:	557d                	li	a0,-1
}
    800056d2:	70ae                	ld	ra,232(sp)
    800056d4:	740e                	ld	s0,224(sp)
    800056d6:	64ee                	ld	s1,216(sp)
    800056d8:	694e                	ld	s2,208(sp)
    800056da:	69ae                	ld	s3,200(sp)
    800056dc:	616d                	addi	sp,sp,240
    800056de:	8082                	ret

00000000800056e0 <sys_open>:

uint64
sys_open(void)
{
    800056e0:	7131                	addi	sp,sp,-192
    800056e2:	fd06                	sd	ra,184(sp)
    800056e4:	f922                	sd	s0,176(sp)
    800056e6:	f526                	sd	s1,168(sp)
    800056e8:	f14a                	sd	s2,160(sp)
    800056ea:	ed4e                	sd	s3,152(sp)
    800056ec:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800056ee:	08000613          	li	a2,128
    800056f2:	f5040593          	addi	a1,s0,-176
    800056f6:	4501                	li	a0,0
    800056f8:	ffffd097          	auipc	ra,0xffffd
    800056fc:	44e080e7          	jalr	1102(ra) # 80002b46 <argstr>
    return -1;
    80005700:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005702:	0c054163          	bltz	a0,800057c4 <sys_open+0xe4>
    80005706:	f4c40593          	addi	a1,s0,-180
    8000570a:	4505                	li	a0,1
    8000570c:	ffffd097          	auipc	ra,0xffffd
    80005710:	3f6080e7          	jalr	1014(ra) # 80002b02 <argint>
    80005714:	0a054863          	bltz	a0,800057c4 <sys_open+0xe4>

  begin_op();
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	9e6080e7          	jalr	-1562(ra) # 800040fe <begin_op>

  if(omode & O_CREATE){
    80005720:	f4c42783          	lw	a5,-180(s0)
    80005724:	2007f793          	andi	a5,a5,512
    80005728:	cbdd                	beqz	a5,800057de <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000572a:	4681                	li	a3,0
    8000572c:	4601                	li	a2,0
    8000572e:	4589                	li	a1,2
    80005730:	f5040513          	addi	a0,s0,-176
    80005734:	00000097          	auipc	ra,0x0
    80005738:	974080e7          	jalr	-1676(ra) # 800050a8 <create>
    8000573c:	892a                	mv	s2,a0
    if(ip == 0){
    8000573e:	c959                	beqz	a0,800057d4 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005740:	04491703          	lh	a4,68(s2)
    80005744:	478d                	li	a5,3
    80005746:	00f71763          	bne	a4,a5,80005754 <sys_open+0x74>
    8000574a:	04695703          	lhu	a4,70(s2)
    8000574e:	47a5                	li	a5,9
    80005750:	0ce7ec63          	bltu	a5,a4,80005828 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005754:	fffff097          	auipc	ra,0xfffff
    80005758:	dc0080e7          	jalr	-576(ra) # 80004514 <filealloc>
    8000575c:	89aa                	mv	s3,a0
    8000575e:	10050263          	beqz	a0,80005862 <sys_open+0x182>
    80005762:	00000097          	auipc	ra,0x0
    80005766:	904080e7          	jalr	-1788(ra) # 80005066 <fdalloc>
    8000576a:	84aa                	mv	s1,a0
    8000576c:	0e054663          	bltz	a0,80005858 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005770:	04491703          	lh	a4,68(s2)
    80005774:	478d                	li	a5,3
    80005776:	0cf70463          	beq	a4,a5,8000583e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000577a:	4789                	li	a5,2
    8000577c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005780:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005784:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005788:	f4c42783          	lw	a5,-180(s0)
    8000578c:	0017c713          	xori	a4,a5,1
    80005790:	8b05                	andi	a4,a4,1
    80005792:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005796:	0037f713          	andi	a4,a5,3
    8000579a:	00e03733          	snez	a4,a4
    8000579e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057a2:	4007f793          	andi	a5,a5,1024
    800057a6:	c791                	beqz	a5,800057b2 <sys_open+0xd2>
    800057a8:	04491703          	lh	a4,68(s2)
    800057ac:	4789                	li	a5,2
    800057ae:	08f70f63          	beq	a4,a5,8000584c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800057b2:	854a                	mv	a0,s2
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	050080e7          	jalr	80(ra) # 80003804 <iunlock>
  end_op();
    800057bc:	fffff097          	auipc	ra,0xfffff
    800057c0:	9c2080e7          	jalr	-1598(ra) # 8000417e <end_op>

  return fd;
}
    800057c4:	8526                	mv	a0,s1
    800057c6:	70ea                	ld	ra,184(sp)
    800057c8:	744a                	ld	s0,176(sp)
    800057ca:	74aa                	ld	s1,168(sp)
    800057cc:	790a                	ld	s2,160(sp)
    800057ce:	69ea                	ld	s3,152(sp)
    800057d0:	6129                	addi	sp,sp,192
    800057d2:	8082                	ret
      end_op();
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	9aa080e7          	jalr	-1622(ra) # 8000417e <end_op>
      return -1;
    800057dc:	b7e5                	j	800057c4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800057de:	f5040513          	addi	a0,s0,-176
    800057e2:	ffffe097          	auipc	ra,0xffffe
    800057e6:	710080e7          	jalr	1808(ra) # 80003ef2 <namei>
    800057ea:	892a                	mv	s2,a0
    800057ec:	c905                	beqz	a0,8000581c <sys_open+0x13c>
    ilock(ip);
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	f54080e7          	jalr	-172(ra) # 80003742 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057f6:	04491703          	lh	a4,68(s2)
    800057fa:	4785                	li	a5,1
    800057fc:	f4f712e3          	bne	a4,a5,80005740 <sys_open+0x60>
    80005800:	f4c42783          	lw	a5,-180(s0)
    80005804:	dba1                	beqz	a5,80005754 <sys_open+0x74>
      iunlockput(ip);
    80005806:	854a                	mv	a0,s2
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	19c080e7          	jalr	412(ra) # 800039a4 <iunlockput>
      end_op();
    80005810:	fffff097          	auipc	ra,0xfffff
    80005814:	96e080e7          	jalr	-1682(ra) # 8000417e <end_op>
      return -1;
    80005818:	54fd                	li	s1,-1
    8000581a:	b76d                	j	800057c4 <sys_open+0xe4>
      end_op();
    8000581c:	fffff097          	auipc	ra,0xfffff
    80005820:	962080e7          	jalr	-1694(ra) # 8000417e <end_op>
      return -1;
    80005824:	54fd                	li	s1,-1
    80005826:	bf79                	j	800057c4 <sys_open+0xe4>
    iunlockput(ip);
    80005828:	854a                	mv	a0,s2
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	17a080e7          	jalr	378(ra) # 800039a4 <iunlockput>
    end_op();
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	94c080e7          	jalr	-1716(ra) # 8000417e <end_op>
    return -1;
    8000583a:	54fd                	li	s1,-1
    8000583c:	b761                	j	800057c4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000583e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005842:	04691783          	lh	a5,70(s2)
    80005846:	02f99223          	sh	a5,36(s3)
    8000584a:	bf2d                	j	80005784 <sys_open+0xa4>
    itrunc(ip);
    8000584c:	854a                	mv	a0,s2
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	002080e7          	jalr	2(ra) # 80003850 <itrunc>
    80005856:	bfb1                	j	800057b2 <sys_open+0xd2>
      fileclose(f);
    80005858:	854e                	mv	a0,s3
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	d76080e7          	jalr	-650(ra) # 800045d0 <fileclose>
    iunlockput(ip);
    80005862:	854a                	mv	a0,s2
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	140080e7          	jalr	320(ra) # 800039a4 <iunlockput>
    end_op();
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	912080e7          	jalr	-1774(ra) # 8000417e <end_op>
    return -1;
    80005874:	54fd                	li	s1,-1
    80005876:	b7b9                	j	800057c4 <sys_open+0xe4>

0000000080005878 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005878:	7175                	addi	sp,sp,-144
    8000587a:	e506                	sd	ra,136(sp)
    8000587c:	e122                	sd	s0,128(sp)
    8000587e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005880:	fffff097          	auipc	ra,0xfffff
    80005884:	87e080e7          	jalr	-1922(ra) # 800040fe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005888:	08000613          	li	a2,128
    8000588c:	f7040593          	addi	a1,s0,-144
    80005890:	4501                	li	a0,0
    80005892:	ffffd097          	auipc	ra,0xffffd
    80005896:	2b4080e7          	jalr	692(ra) # 80002b46 <argstr>
    8000589a:	02054963          	bltz	a0,800058cc <sys_mkdir+0x54>
    8000589e:	4681                	li	a3,0
    800058a0:	4601                	li	a2,0
    800058a2:	4585                	li	a1,1
    800058a4:	f7040513          	addi	a0,s0,-144
    800058a8:	00000097          	auipc	ra,0x0
    800058ac:	800080e7          	jalr	-2048(ra) # 800050a8 <create>
    800058b0:	cd11                	beqz	a0,800058cc <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	0f2080e7          	jalr	242(ra) # 800039a4 <iunlockput>
  end_op();
    800058ba:	fffff097          	auipc	ra,0xfffff
    800058be:	8c4080e7          	jalr	-1852(ra) # 8000417e <end_op>
  return 0;
    800058c2:	4501                	li	a0,0
}
    800058c4:	60aa                	ld	ra,136(sp)
    800058c6:	640a                	ld	s0,128(sp)
    800058c8:	6149                	addi	sp,sp,144
    800058ca:	8082                	ret
    end_op();
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	8b2080e7          	jalr	-1870(ra) # 8000417e <end_op>
    return -1;
    800058d4:	557d                	li	a0,-1
    800058d6:	b7fd                	j	800058c4 <sys_mkdir+0x4c>

00000000800058d8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800058d8:	7135                	addi	sp,sp,-160
    800058da:	ed06                	sd	ra,152(sp)
    800058dc:	e922                	sd	s0,144(sp)
    800058de:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058e0:	fffff097          	auipc	ra,0xfffff
    800058e4:	81e080e7          	jalr	-2018(ra) # 800040fe <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058e8:	08000613          	li	a2,128
    800058ec:	f7040593          	addi	a1,s0,-144
    800058f0:	4501                	li	a0,0
    800058f2:	ffffd097          	auipc	ra,0xffffd
    800058f6:	254080e7          	jalr	596(ra) # 80002b46 <argstr>
    800058fa:	04054a63          	bltz	a0,8000594e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800058fe:	f6c40593          	addi	a1,s0,-148
    80005902:	4505                	li	a0,1
    80005904:	ffffd097          	auipc	ra,0xffffd
    80005908:	1fe080e7          	jalr	510(ra) # 80002b02 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000590c:	04054163          	bltz	a0,8000594e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005910:	f6840593          	addi	a1,s0,-152
    80005914:	4509                	li	a0,2
    80005916:	ffffd097          	auipc	ra,0xffffd
    8000591a:	1ec080e7          	jalr	492(ra) # 80002b02 <argint>
     argint(1, &major) < 0 ||
    8000591e:	02054863          	bltz	a0,8000594e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005922:	f6841683          	lh	a3,-152(s0)
    80005926:	f6c41603          	lh	a2,-148(s0)
    8000592a:	458d                	li	a1,3
    8000592c:	f7040513          	addi	a0,s0,-144
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	778080e7          	jalr	1912(ra) # 800050a8 <create>
     argint(2, &minor) < 0 ||
    80005938:	c919                	beqz	a0,8000594e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	06a080e7          	jalr	106(ra) # 800039a4 <iunlockput>
  end_op();
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	83c080e7          	jalr	-1988(ra) # 8000417e <end_op>
  return 0;
    8000594a:	4501                	li	a0,0
    8000594c:	a031                	j	80005958 <sys_mknod+0x80>
    end_op();
    8000594e:	fffff097          	auipc	ra,0xfffff
    80005952:	830080e7          	jalr	-2000(ra) # 8000417e <end_op>
    return -1;
    80005956:	557d                	li	a0,-1
}
    80005958:	60ea                	ld	ra,152(sp)
    8000595a:	644a                	ld	s0,144(sp)
    8000595c:	610d                	addi	sp,sp,160
    8000595e:	8082                	ret

0000000080005960 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005960:	7135                	addi	sp,sp,-160
    80005962:	ed06                	sd	ra,152(sp)
    80005964:	e922                	sd	s0,144(sp)
    80005966:	e526                	sd	s1,136(sp)
    80005968:	e14a                	sd	s2,128(sp)
    8000596a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000596c:	ffffc097          	auipc	ra,0xffffc
    80005970:	0a8080e7          	jalr	168(ra) # 80001a14 <myproc>
    80005974:	892a                	mv	s2,a0
  
  begin_op();
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	788080e7          	jalr	1928(ra) # 800040fe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000597e:	08000613          	li	a2,128
    80005982:	f6040593          	addi	a1,s0,-160
    80005986:	4501                	li	a0,0
    80005988:	ffffd097          	auipc	ra,0xffffd
    8000598c:	1be080e7          	jalr	446(ra) # 80002b46 <argstr>
    80005990:	04054b63          	bltz	a0,800059e6 <sys_chdir+0x86>
    80005994:	f6040513          	addi	a0,s0,-160
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	55a080e7          	jalr	1370(ra) # 80003ef2 <namei>
    800059a0:	84aa                	mv	s1,a0
    800059a2:	c131                	beqz	a0,800059e6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	d9e080e7          	jalr	-610(ra) # 80003742 <ilock>
  if(ip->type != T_DIR){
    800059ac:	04449703          	lh	a4,68(s1)
    800059b0:	4785                	li	a5,1
    800059b2:	04f71063          	bne	a4,a5,800059f2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059b6:	8526                	mv	a0,s1
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	e4c080e7          	jalr	-436(ra) # 80003804 <iunlock>
  iput(p->cwd);
    800059c0:	15093503          	ld	a0,336(s2)
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	f38080e7          	jalr	-200(ra) # 800038fc <iput>
  end_op();
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	7b2080e7          	jalr	1970(ra) # 8000417e <end_op>
  p->cwd = ip;
    800059d4:	14993823          	sd	s1,336(s2)
  return 0;
    800059d8:	4501                	li	a0,0
}
    800059da:	60ea                	ld	ra,152(sp)
    800059dc:	644a                	ld	s0,144(sp)
    800059de:	64aa                	ld	s1,136(sp)
    800059e0:	690a                	ld	s2,128(sp)
    800059e2:	610d                	addi	sp,sp,160
    800059e4:	8082                	ret
    end_op();
    800059e6:	ffffe097          	auipc	ra,0xffffe
    800059ea:	798080e7          	jalr	1944(ra) # 8000417e <end_op>
    return -1;
    800059ee:	557d                	li	a0,-1
    800059f0:	b7ed                	j	800059da <sys_chdir+0x7a>
    iunlockput(ip);
    800059f2:	8526                	mv	a0,s1
    800059f4:	ffffe097          	auipc	ra,0xffffe
    800059f8:	fb0080e7          	jalr	-80(ra) # 800039a4 <iunlockput>
    end_op();
    800059fc:	ffffe097          	auipc	ra,0xffffe
    80005a00:	782080e7          	jalr	1922(ra) # 8000417e <end_op>
    return -1;
    80005a04:	557d                	li	a0,-1
    80005a06:	bfd1                	j	800059da <sys_chdir+0x7a>

0000000080005a08 <sys_exec>:

uint64
sys_exec(void)
{
    80005a08:	7145                	addi	sp,sp,-464
    80005a0a:	e786                	sd	ra,456(sp)
    80005a0c:	e3a2                	sd	s0,448(sp)
    80005a0e:	ff26                	sd	s1,440(sp)
    80005a10:	fb4a                	sd	s2,432(sp)
    80005a12:	f74e                	sd	s3,424(sp)
    80005a14:	f352                	sd	s4,416(sp)
    80005a16:	ef56                	sd	s5,408(sp)
    80005a18:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a1a:	08000613          	li	a2,128
    80005a1e:	f4040593          	addi	a1,s0,-192
    80005a22:	4501                	li	a0,0
    80005a24:	ffffd097          	auipc	ra,0xffffd
    80005a28:	122080e7          	jalr	290(ra) # 80002b46 <argstr>
    return -1;
    80005a2c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a2e:	0c054a63          	bltz	a0,80005b02 <sys_exec+0xfa>
    80005a32:	e3840593          	addi	a1,s0,-456
    80005a36:	4505                	li	a0,1
    80005a38:	ffffd097          	auipc	ra,0xffffd
    80005a3c:	0ec080e7          	jalr	236(ra) # 80002b24 <argaddr>
    80005a40:	0c054163          	bltz	a0,80005b02 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005a44:	10000613          	li	a2,256
    80005a48:	4581                	li	a1,0
    80005a4a:	e4040513          	addi	a0,s0,-448
    80005a4e:	ffffb097          	auipc	ra,0xffffb
    80005a52:	2f6080e7          	jalr	758(ra) # 80000d44 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a56:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a5a:	89a6                	mv	s3,s1
    80005a5c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a5e:	02000a13          	li	s4,32
    80005a62:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a66:	00391793          	slli	a5,s2,0x3
    80005a6a:	e3040593          	addi	a1,s0,-464
    80005a6e:	e3843503          	ld	a0,-456(s0)
    80005a72:	953e                	add	a0,a0,a5
    80005a74:	ffffd097          	auipc	ra,0xffffd
    80005a78:	ff4080e7          	jalr	-12(ra) # 80002a68 <fetchaddr>
    80005a7c:	02054a63          	bltz	a0,80005ab0 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005a80:	e3043783          	ld	a5,-464(s0)
    80005a84:	c3b9                	beqz	a5,80005aca <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a86:	ffffb097          	auipc	ra,0xffffb
    80005a8a:	088080e7          	jalr	136(ra) # 80000b0e <kalloc>
    80005a8e:	85aa                	mv	a1,a0
    80005a90:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a94:	cd11                	beqz	a0,80005ab0 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a96:	6605                	lui	a2,0x1
    80005a98:	e3043503          	ld	a0,-464(s0)
    80005a9c:	ffffd097          	auipc	ra,0xffffd
    80005aa0:	01e080e7          	jalr	30(ra) # 80002aba <fetchstr>
    80005aa4:	00054663          	bltz	a0,80005ab0 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005aa8:	0905                	addi	s2,s2,1
    80005aaa:	09a1                	addi	s3,s3,8
    80005aac:	fb491be3          	bne	s2,s4,80005a62 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ab0:	10048913          	addi	s2,s1,256
    80005ab4:	6088                	ld	a0,0(s1)
    80005ab6:	c529                	beqz	a0,80005b00 <sys_exec+0xf8>
    kfree(argv[i]);
    80005ab8:	ffffb097          	auipc	ra,0xffffb
    80005abc:	f5a080e7          	jalr	-166(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ac0:	04a1                	addi	s1,s1,8
    80005ac2:	ff2499e3          	bne	s1,s2,80005ab4 <sys_exec+0xac>
  return -1;
    80005ac6:	597d                	li	s2,-1
    80005ac8:	a82d                	j	80005b02 <sys_exec+0xfa>
      argv[i] = 0;
    80005aca:	0a8e                	slli	s5,s5,0x3
    80005acc:	fc040793          	addi	a5,s0,-64
    80005ad0:	9abe                	add	s5,s5,a5
    80005ad2:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80005ad6:	e4040593          	addi	a1,s0,-448
    80005ada:	f4040513          	addi	a0,s0,-192
    80005ade:	fffff097          	auipc	ra,0xfffff
    80005ae2:	178080e7          	jalr	376(ra) # 80004c56 <exec>
    80005ae6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ae8:	10048993          	addi	s3,s1,256
    80005aec:	6088                	ld	a0,0(s1)
    80005aee:	c911                	beqz	a0,80005b02 <sys_exec+0xfa>
    kfree(argv[i]);
    80005af0:	ffffb097          	auipc	ra,0xffffb
    80005af4:	f22080e7          	jalr	-222(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005af8:	04a1                	addi	s1,s1,8
    80005afa:	ff3499e3          	bne	s1,s3,80005aec <sys_exec+0xe4>
    80005afe:	a011                	j	80005b02 <sys_exec+0xfa>
  return -1;
    80005b00:	597d                	li	s2,-1
}
    80005b02:	854a                	mv	a0,s2
    80005b04:	60be                	ld	ra,456(sp)
    80005b06:	641e                	ld	s0,448(sp)
    80005b08:	74fa                	ld	s1,440(sp)
    80005b0a:	795a                	ld	s2,432(sp)
    80005b0c:	79ba                	ld	s3,424(sp)
    80005b0e:	7a1a                	ld	s4,416(sp)
    80005b10:	6afa                	ld	s5,408(sp)
    80005b12:	6179                	addi	sp,sp,464
    80005b14:	8082                	ret

0000000080005b16 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b16:	7139                	addi	sp,sp,-64
    80005b18:	fc06                	sd	ra,56(sp)
    80005b1a:	f822                	sd	s0,48(sp)
    80005b1c:	f426                	sd	s1,40(sp)
    80005b1e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b20:	ffffc097          	auipc	ra,0xffffc
    80005b24:	ef4080e7          	jalr	-268(ra) # 80001a14 <myproc>
    80005b28:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b2a:	fd840593          	addi	a1,s0,-40
    80005b2e:	4501                	li	a0,0
    80005b30:	ffffd097          	auipc	ra,0xffffd
    80005b34:	ff4080e7          	jalr	-12(ra) # 80002b24 <argaddr>
    return -1;
    80005b38:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b3a:	0e054063          	bltz	a0,80005c1a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b3e:	fc840593          	addi	a1,s0,-56
    80005b42:	fd040513          	addi	a0,s0,-48
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	de0080e7          	jalr	-544(ra) # 80004926 <pipealloc>
    return -1;
    80005b4e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b50:	0c054563          	bltz	a0,80005c1a <sys_pipe+0x104>
  fd0 = -1;
    80005b54:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b58:	fd043503          	ld	a0,-48(s0)
    80005b5c:	fffff097          	auipc	ra,0xfffff
    80005b60:	50a080e7          	jalr	1290(ra) # 80005066 <fdalloc>
    80005b64:	fca42223          	sw	a0,-60(s0)
    80005b68:	08054c63          	bltz	a0,80005c00 <sys_pipe+0xea>
    80005b6c:	fc843503          	ld	a0,-56(s0)
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	4f6080e7          	jalr	1270(ra) # 80005066 <fdalloc>
    80005b78:	fca42023          	sw	a0,-64(s0)
    80005b7c:	06054863          	bltz	a0,80005bec <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b80:	4691                	li	a3,4
    80005b82:	fc440613          	addi	a2,s0,-60
    80005b86:	fd843583          	ld	a1,-40(s0)
    80005b8a:	68a8                	ld	a0,80(s1)
    80005b8c:	ffffc097          	auipc	ra,0xffffc
    80005b90:	b7a080e7          	jalr	-1158(ra) # 80001706 <copyout>
    80005b94:	02054063          	bltz	a0,80005bb4 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b98:	4691                	li	a3,4
    80005b9a:	fc040613          	addi	a2,s0,-64
    80005b9e:	fd843583          	ld	a1,-40(s0)
    80005ba2:	0591                	addi	a1,a1,4
    80005ba4:	68a8                	ld	a0,80(s1)
    80005ba6:	ffffc097          	auipc	ra,0xffffc
    80005baa:	b60080e7          	jalr	-1184(ra) # 80001706 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bae:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bb0:	06055563          	bgez	a0,80005c1a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005bb4:	fc442783          	lw	a5,-60(s0)
    80005bb8:	07e9                	addi	a5,a5,26
    80005bba:	078e                	slli	a5,a5,0x3
    80005bbc:	97a6                	add	a5,a5,s1
    80005bbe:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005bc2:	fc042503          	lw	a0,-64(s0)
    80005bc6:	0569                	addi	a0,a0,26
    80005bc8:	050e                	slli	a0,a0,0x3
    80005bca:	9526                	add	a0,a0,s1
    80005bcc:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005bd0:	fd043503          	ld	a0,-48(s0)
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	9fc080e7          	jalr	-1540(ra) # 800045d0 <fileclose>
    fileclose(wf);
    80005bdc:	fc843503          	ld	a0,-56(s0)
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	9f0080e7          	jalr	-1552(ra) # 800045d0 <fileclose>
    return -1;
    80005be8:	57fd                	li	a5,-1
    80005bea:	a805                	j	80005c1a <sys_pipe+0x104>
    if(fd0 >= 0)
    80005bec:	fc442783          	lw	a5,-60(s0)
    80005bf0:	0007c863          	bltz	a5,80005c00 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005bf4:	01a78513          	addi	a0,a5,26
    80005bf8:	050e                	slli	a0,a0,0x3
    80005bfa:	9526                	add	a0,a0,s1
    80005bfc:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c00:	fd043503          	ld	a0,-48(s0)
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	9cc080e7          	jalr	-1588(ra) # 800045d0 <fileclose>
    fileclose(wf);
    80005c0c:	fc843503          	ld	a0,-56(s0)
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	9c0080e7          	jalr	-1600(ra) # 800045d0 <fileclose>
    return -1;
    80005c18:	57fd                	li	a5,-1
}
    80005c1a:	853e                	mv	a0,a5
    80005c1c:	70e2                	ld	ra,56(sp)
    80005c1e:	7442                	ld	s0,48(sp)
    80005c20:	74a2                	ld	s1,40(sp)
    80005c22:	6121                	addi	sp,sp,64
    80005c24:	8082                	ret
	...

0000000080005c30 <kernelvec>:
    80005c30:	7111                	addi	sp,sp,-256
    80005c32:	e006                	sd	ra,0(sp)
    80005c34:	e40a                	sd	sp,8(sp)
    80005c36:	e80e                	sd	gp,16(sp)
    80005c38:	ec12                	sd	tp,24(sp)
    80005c3a:	f016                	sd	t0,32(sp)
    80005c3c:	f41a                	sd	t1,40(sp)
    80005c3e:	f81e                	sd	t2,48(sp)
    80005c40:	fc22                	sd	s0,56(sp)
    80005c42:	e0a6                	sd	s1,64(sp)
    80005c44:	e4aa                	sd	a0,72(sp)
    80005c46:	e8ae                	sd	a1,80(sp)
    80005c48:	ecb2                	sd	a2,88(sp)
    80005c4a:	f0b6                	sd	a3,96(sp)
    80005c4c:	f4ba                	sd	a4,104(sp)
    80005c4e:	f8be                	sd	a5,112(sp)
    80005c50:	fcc2                	sd	a6,120(sp)
    80005c52:	e146                	sd	a7,128(sp)
    80005c54:	e54a                	sd	s2,136(sp)
    80005c56:	e94e                	sd	s3,144(sp)
    80005c58:	ed52                	sd	s4,152(sp)
    80005c5a:	f156                	sd	s5,160(sp)
    80005c5c:	f55a                	sd	s6,168(sp)
    80005c5e:	f95e                	sd	s7,176(sp)
    80005c60:	fd62                	sd	s8,184(sp)
    80005c62:	e1e6                	sd	s9,192(sp)
    80005c64:	e5ea                	sd	s10,200(sp)
    80005c66:	e9ee                	sd	s11,208(sp)
    80005c68:	edf2                	sd	t3,216(sp)
    80005c6a:	f1f6                	sd	t4,224(sp)
    80005c6c:	f5fa                	sd	t5,232(sp)
    80005c6e:	f9fe                	sd	t6,240(sp)
    80005c70:	cc5fc0ef          	jal	ra,80002934 <kerneltrap>
    80005c74:	6082                	ld	ra,0(sp)
    80005c76:	6122                	ld	sp,8(sp)
    80005c78:	61c2                	ld	gp,16(sp)
    80005c7a:	7282                	ld	t0,32(sp)
    80005c7c:	7322                	ld	t1,40(sp)
    80005c7e:	73c2                	ld	t2,48(sp)
    80005c80:	7462                	ld	s0,56(sp)
    80005c82:	6486                	ld	s1,64(sp)
    80005c84:	6526                	ld	a0,72(sp)
    80005c86:	65c6                	ld	a1,80(sp)
    80005c88:	6666                	ld	a2,88(sp)
    80005c8a:	7686                	ld	a3,96(sp)
    80005c8c:	7726                	ld	a4,104(sp)
    80005c8e:	77c6                	ld	a5,112(sp)
    80005c90:	7866                	ld	a6,120(sp)
    80005c92:	688a                	ld	a7,128(sp)
    80005c94:	692a                	ld	s2,136(sp)
    80005c96:	69ca                	ld	s3,144(sp)
    80005c98:	6a6a                	ld	s4,152(sp)
    80005c9a:	7a8a                	ld	s5,160(sp)
    80005c9c:	7b2a                	ld	s6,168(sp)
    80005c9e:	7bca                	ld	s7,176(sp)
    80005ca0:	7c6a                	ld	s8,184(sp)
    80005ca2:	6c8e                	ld	s9,192(sp)
    80005ca4:	6d2e                	ld	s10,200(sp)
    80005ca6:	6dce                	ld	s11,208(sp)
    80005ca8:	6e6e                	ld	t3,216(sp)
    80005caa:	7e8e                	ld	t4,224(sp)
    80005cac:	7f2e                	ld	t5,232(sp)
    80005cae:	7fce                	ld	t6,240(sp)
    80005cb0:	6111                	addi	sp,sp,256
    80005cb2:	10200073          	sret
    80005cb6:	00000013          	nop
    80005cba:	00000013          	nop
    80005cbe:	0001                	nop

0000000080005cc0 <timervec>:
    80005cc0:	34051573          	csrrw	a0,mscratch,a0
    80005cc4:	e10c                	sd	a1,0(a0)
    80005cc6:	e510                	sd	a2,8(a0)
    80005cc8:	e914                	sd	a3,16(a0)
    80005cca:	710c                	ld	a1,32(a0)
    80005ccc:	7510                	ld	a2,40(a0)
    80005cce:	6194                	ld	a3,0(a1)
    80005cd0:	96b2                	add	a3,a3,a2
    80005cd2:	e194                	sd	a3,0(a1)
    80005cd4:	4589                	li	a1,2
    80005cd6:	14459073          	csrw	sip,a1
    80005cda:	6914                	ld	a3,16(a0)
    80005cdc:	6510                	ld	a2,8(a0)
    80005cde:	610c                	ld	a1,0(a0)
    80005ce0:	34051573          	csrrw	a0,mscratch,a0
    80005ce4:	30200073          	mret
	...

0000000080005cea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005cea:	1141                	addi	sp,sp,-16
    80005cec:	e422                	sd	s0,8(sp)
    80005cee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005cf0:	0c0007b7          	lui	a5,0xc000
    80005cf4:	4705                	li	a4,1
    80005cf6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005cf8:	c3d8                	sw	a4,4(a5)
}
    80005cfa:	6422                	ld	s0,8(sp)
    80005cfc:	0141                	addi	sp,sp,16
    80005cfe:	8082                	ret

0000000080005d00 <plicinithart>:

void
plicinithart(void)
{
    80005d00:	1141                	addi	sp,sp,-16
    80005d02:	e406                	sd	ra,8(sp)
    80005d04:	e022                	sd	s0,0(sp)
    80005d06:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d08:	ffffc097          	auipc	ra,0xffffc
    80005d0c:	ce0080e7          	jalr	-800(ra) # 800019e8 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d10:	0085171b          	slliw	a4,a0,0x8
    80005d14:	0c0027b7          	lui	a5,0xc002
    80005d18:	97ba                	add	a5,a5,a4
    80005d1a:	40200713          	li	a4,1026
    80005d1e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d22:	00d5151b          	slliw	a0,a0,0xd
    80005d26:	0c2017b7          	lui	a5,0xc201
    80005d2a:	953e                	add	a0,a0,a5
    80005d2c:	00052023          	sw	zero,0(a0)
}
    80005d30:	60a2                	ld	ra,8(sp)
    80005d32:	6402                	ld	s0,0(sp)
    80005d34:	0141                	addi	sp,sp,16
    80005d36:	8082                	ret

0000000080005d38 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d38:	1141                	addi	sp,sp,-16
    80005d3a:	e406                	sd	ra,8(sp)
    80005d3c:	e022                	sd	s0,0(sp)
    80005d3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d40:	ffffc097          	auipc	ra,0xffffc
    80005d44:	ca8080e7          	jalr	-856(ra) # 800019e8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d48:	00d5179b          	slliw	a5,a0,0xd
    80005d4c:	0c201537          	lui	a0,0xc201
    80005d50:	953e                	add	a0,a0,a5
  return irq;
}
    80005d52:	4148                	lw	a0,4(a0)
    80005d54:	60a2                	ld	ra,8(sp)
    80005d56:	6402                	ld	s0,0(sp)
    80005d58:	0141                	addi	sp,sp,16
    80005d5a:	8082                	ret

0000000080005d5c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d5c:	1101                	addi	sp,sp,-32
    80005d5e:	ec06                	sd	ra,24(sp)
    80005d60:	e822                	sd	s0,16(sp)
    80005d62:	e426                	sd	s1,8(sp)
    80005d64:	1000                	addi	s0,sp,32
    80005d66:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d68:	ffffc097          	auipc	ra,0xffffc
    80005d6c:	c80080e7          	jalr	-896(ra) # 800019e8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d70:	00d5151b          	slliw	a0,a0,0xd
    80005d74:	0c2017b7          	lui	a5,0xc201
    80005d78:	97aa                	add	a5,a5,a0
    80005d7a:	c3c4                	sw	s1,4(a5)
}
    80005d7c:	60e2                	ld	ra,24(sp)
    80005d7e:	6442                	ld	s0,16(sp)
    80005d80:	64a2                	ld	s1,8(sp)
    80005d82:	6105                	addi	sp,sp,32
    80005d84:	8082                	ret

0000000080005d86 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d86:	1141                	addi	sp,sp,-16
    80005d88:	e406                	sd	ra,8(sp)
    80005d8a:	e022                	sd	s0,0(sp)
    80005d8c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d8e:	479d                	li	a5,7
    80005d90:	04a7cc63          	blt	a5,a0,80005de8 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005d94:	0001d797          	auipc	a5,0x1d
    80005d98:	26c78793          	addi	a5,a5,620 # 80023000 <disk>
    80005d9c:	00a78733          	add	a4,a5,a0
    80005da0:	6789                	lui	a5,0x2
    80005da2:	97ba                	add	a5,a5,a4
    80005da4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005da8:	eba1                	bnez	a5,80005df8 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005daa:	00451713          	slli	a4,a0,0x4
    80005dae:	0001f797          	auipc	a5,0x1f
    80005db2:	2527b783          	ld	a5,594(a5) # 80025000 <disk+0x2000>
    80005db6:	97ba                	add	a5,a5,a4
    80005db8:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005dbc:	0001d797          	auipc	a5,0x1d
    80005dc0:	24478793          	addi	a5,a5,580 # 80023000 <disk>
    80005dc4:	97aa                	add	a5,a5,a0
    80005dc6:	6509                	lui	a0,0x2
    80005dc8:	953e                	add	a0,a0,a5
    80005dca:	4785                	li	a5,1
    80005dcc:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005dd0:	0001f517          	auipc	a0,0x1f
    80005dd4:	24850513          	addi	a0,a0,584 # 80025018 <disk+0x2018>
    80005dd8:	ffffc097          	auipc	ra,0xffffc
    80005ddc:	5d4080e7          	jalr	1492(ra) # 800023ac <wakeup>
}
    80005de0:	60a2                	ld	ra,8(sp)
    80005de2:	6402                	ld	s0,0(sp)
    80005de4:	0141                	addi	sp,sp,16
    80005de6:	8082                	ret
    panic("virtio_disk_intr 1");
    80005de8:	00003517          	auipc	a0,0x3
    80005dec:	99850513          	addi	a0,a0,-1640 # 80008780 <syscalls+0x340>
    80005df0:	ffffa097          	auipc	ra,0xffffa
    80005df4:	752080e7          	jalr	1874(ra) # 80000542 <panic>
    panic("virtio_disk_intr 2");
    80005df8:	00003517          	auipc	a0,0x3
    80005dfc:	9a050513          	addi	a0,a0,-1632 # 80008798 <syscalls+0x358>
    80005e00:	ffffa097          	auipc	ra,0xffffa
    80005e04:	742080e7          	jalr	1858(ra) # 80000542 <panic>

0000000080005e08 <virtio_disk_init>:
{
    80005e08:	1101                	addi	sp,sp,-32
    80005e0a:	ec06                	sd	ra,24(sp)
    80005e0c:	e822                	sd	s0,16(sp)
    80005e0e:	e426                	sd	s1,8(sp)
    80005e10:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e12:	00003597          	auipc	a1,0x3
    80005e16:	99e58593          	addi	a1,a1,-1634 # 800087b0 <syscalls+0x370>
    80005e1a:	0001f517          	auipc	a0,0x1f
    80005e1e:	28e50513          	addi	a0,a0,654 # 800250a8 <disk+0x20a8>
    80005e22:	ffffb097          	auipc	ra,0xffffb
    80005e26:	d96080e7          	jalr	-618(ra) # 80000bb8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e2a:	100017b7          	lui	a5,0x10001
    80005e2e:	4398                	lw	a4,0(a5)
    80005e30:	2701                	sext.w	a4,a4
    80005e32:	747277b7          	lui	a5,0x74727
    80005e36:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e3a:	0ef71163          	bne	a4,a5,80005f1c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e3e:	100017b7          	lui	a5,0x10001
    80005e42:	43dc                	lw	a5,4(a5)
    80005e44:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e46:	4705                	li	a4,1
    80005e48:	0ce79a63          	bne	a5,a4,80005f1c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e4c:	100017b7          	lui	a5,0x10001
    80005e50:	479c                	lw	a5,8(a5)
    80005e52:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e54:	4709                	li	a4,2
    80005e56:	0ce79363          	bne	a5,a4,80005f1c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e5a:	100017b7          	lui	a5,0x10001
    80005e5e:	47d8                	lw	a4,12(a5)
    80005e60:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e62:	554d47b7          	lui	a5,0x554d4
    80005e66:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e6a:	0af71963          	bne	a4,a5,80005f1c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e6e:	100017b7          	lui	a5,0x10001
    80005e72:	4705                	li	a4,1
    80005e74:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e76:	470d                	li	a4,3
    80005e78:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e7a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e7c:	c7ffe737          	lui	a4,0xc7ffe
    80005e80:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005e84:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e86:	2701                	sext.w	a4,a4
    80005e88:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e8a:	472d                	li	a4,11
    80005e8c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e8e:	473d                	li	a4,15
    80005e90:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005e92:	6705                	lui	a4,0x1
    80005e94:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e96:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e9a:	5bdc                	lw	a5,52(a5)
    80005e9c:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e9e:	c7d9                	beqz	a5,80005f2c <virtio_disk_init+0x124>
  if(max < NUM)
    80005ea0:	471d                	li	a4,7
    80005ea2:	08f77d63          	bgeu	a4,a5,80005f3c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ea6:	100014b7          	lui	s1,0x10001
    80005eaa:	47a1                	li	a5,8
    80005eac:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005eae:	6609                	lui	a2,0x2
    80005eb0:	4581                	li	a1,0
    80005eb2:	0001d517          	auipc	a0,0x1d
    80005eb6:	14e50513          	addi	a0,a0,334 # 80023000 <disk>
    80005eba:	ffffb097          	auipc	ra,0xffffb
    80005ebe:	e8a080e7          	jalr	-374(ra) # 80000d44 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005ec2:	0001d717          	auipc	a4,0x1d
    80005ec6:	13e70713          	addi	a4,a4,318 # 80023000 <disk>
    80005eca:	00c75793          	srli	a5,a4,0xc
    80005ece:	2781                	sext.w	a5,a5
    80005ed0:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005ed2:	0001f797          	auipc	a5,0x1f
    80005ed6:	12e78793          	addi	a5,a5,302 # 80025000 <disk+0x2000>
    80005eda:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005edc:	0001d717          	auipc	a4,0x1d
    80005ee0:	1a470713          	addi	a4,a4,420 # 80023080 <disk+0x80>
    80005ee4:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005ee6:	0001e717          	auipc	a4,0x1e
    80005eea:	11a70713          	addi	a4,a4,282 # 80024000 <disk+0x1000>
    80005eee:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005ef0:	4705                	li	a4,1
    80005ef2:	00e78c23          	sb	a4,24(a5)
    80005ef6:	00e78ca3          	sb	a4,25(a5)
    80005efa:	00e78d23          	sb	a4,26(a5)
    80005efe:	00e78da3          	sb	a4,27(a5)
    80005f02:	00e78e23          	sb	a4,28(a5)
    80005f06:	00e78ea3          	sb	a4,29(a5)
    80005f0a:	00e78f23          	sb	a4,30(a5)
    80005f0e:	00e78fa3          	sb	a4,31(a5)
}
    80005f12:	60e2                	ld	ra,24(sp)
    80005f14:	6442                	ld	s0,16(sp)
    80005f16:	64a2                	ld	s1,8(sp)
    80005f18:	6105                	addi	sp,sp,32
    80005f1a:	8082                	ret
    panic("could not find virtio disk");
    80005f1c:	00003517          	auipc	a0,0x3
    80005f20:	8a450513          	addi	a0,a0,-1884 # 800087c0 <syscalls+0x380>
    80005f24:	ffffa097          	auipc	ra,0xffffa
    80005f28:	61e080e7          	jalr	1566(ra) # 80000542 <panic>
    panic("virtio disk has no queue 0");
    80005f2c:	00003517          	auipc	a0,0x3
    80005f30:	8b450513          	addi	a0,a0,-1868 # 800087e0 <syscalls+0x3a0>
    80005f34:	ffffa097          	auipc	ra,0xffffa
    80005f38:	60e080e7          	jalr	1550(ra) # 80000542 <panic>
    panic("virtio disk max queue too short");
    80005f3c:	00003517          	auipc	a0,0x3
    80005f40:	8c450513          	addi	a0,a0,-1852 # 80008800 <syscalls+0x3c0>
    80005f44:	ffffa097          	auipc	ra,0xffffa
    80005f48:	5fe080e7          	jalr	1534(ra) # 80000542 <panic>

0000000080005f4c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f4c:	7175                	addi	sp,sp,-144
    80005f4e:	e506                	sd	ra,136(sp)
    80005f50:	e122                	sd	s0,128(sp)
    80005f52:	fca6                	sd	s1,120(sp)
    80005f54:	f8ca                	sd	s2,112(sp)
    80005f56:	f4ce                	sd	s3,104(sp)
    80005f58:	f0d2                	sd	s4,96(sp)
    80005f5a:	ecd6                	sd	s5,88(sp)
    80005f5c:	e8da                	sd	s6,80(sp)
    80005f5e:	e4de                	sd	s7,72(sp)
    80005f60:	e0e2                	sd	s8,64(sp)
    80005f62:	fc66                	sd	s9,56(sp)
    80005f64:	f86a                	sd	s10,48(sp)
    80005f66:	f46e                	sd	s11,40(sp)
    80005f68:	0900                	addi	s0,sp,144
    80005f6a:	8aaa                	mv	s5,a0
    80005f6c:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f6e:	00c52c83          	lw	s9,12(a0)
    80005f72:	001c9c9b          	slliw	s9,s9,0x1
    80005f76:	1c82                	slli	s9,s9,0x20
    80005f78:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005f7c:	0001f517          	auipc	a0,0x1f
    80005f80:	12c50513          	addi	a0,a0,300 # 800250a8 <disk+0x20a8>
    80005f84:	ffffb097          	auipc	ra,0xffffb
    80005f88:	cc4080e7          	jalr	-828(ra) # 80000c48 <acquire>
  for(int i = 0; i < 3; i++){
    80005f8c:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f8e:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f90:	0001dc17          	auipc	s8,0x1d
    80005f94:	070c0c13          	addi	s8,s8,112 # 80023000 <disk>
    80005f98:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005f9a:	4b0d                	li	s6,3
    80005f9c:	a0ad                	j	80006006 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005f9e:	00fc0733          	add	a4,s8,a5
    80005fa2:	975e                	add	a4,a4,s7
    80005fa4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005fa8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005faa:	0207c563          	bltz	a5,80005fd4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005fae:	2905                	addiw	s2,s2,1
    80005fb0:	0611                	addi	a2,a2,4
    80005fb2:	19690d63          	beq	s2,s6,8000614c <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80005fb6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005fb8:	0001f717          	auipc	a4,0x1f
    80005fbc:	06070713          	addi	a4,a4,96 # 80025018 <disk+0x2018>
    80005fc0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005fc2:	00074683          	lbu	a3,0(a4)
    80005fc6:	fee1                	bnez	a3,80005f9e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005fc8:	2785                	addiw	a5,a5,1
    80005fca:	0705                	addi	a4,a4,1
    80005fcc:	fe979be3          	bne	a5,s1,80005fc2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005fd0:	57fd                	li	a5,-1
    80005fd2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005fd4:	01205d63          	blez	s2,80005fee <virtio_disk_rw+0xa2>
    80005fd8:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005fda:	000a2503          	lw	a0,0(s4)
    80005fde:	00000097          	auipc	ra,0x0
    80005fe2:	da8080e7          	jalr	-600(ra) # 80005d86 <free_desc>
      for(int j = 0; j < i; j++)
    80005fe6:	2d85                	addiw	s11,s11,1
    80005fe8:	0a11                	addi	s4,s4,4
    80005fea:	ffb918e3          	bne	s2,s11,80005fda <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fee:	0001f597          	auipc	a1,0x1f
    80005ff2:	0ba58593          	addi	a1,a1,186 # 800250a8 <disk+0x20a8>
    80005ff6:	0001f517          	auipc	a0,0x1f
    80005ffa:	02250513          	addi	a0,a0,34 # 80025018 <disk+0x2018>
    80005ffe:	ffffc097          	auipc	ra,0xffffc
    80006002:	22e080e7          	jalr	558(ra) # 8000222c <sleep>
  for(int i = 0; i < 3; i++){
    80006006:	f8040a13          	addi	s4,s0,-128
{
    8000600a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000600c:	894e                	mv	s2,s3
    8000600e:	b765                	j	80005fb6 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006010:	0001f717          	auipc	a4,0x1f
    80006014:	ff073703          	ld	a4,-16(a4) # 80025000 <disk+0x2000>
    80006018:	973e                	add	a4,a4,a5
    8000601a:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000601e:	0001d517          	auipc	a0,0x1d
    80006022:	fe250513          	addi	a0,a0,-30 # 80023000 <disk>
    80006026:	0001f717          	auipc	a4,0x1f
    8000602a:	fda70713          	addi	a4,a4,-38 # 80025000 <disk+0x2000>
    8000602e:	6314                	ld	a3,0(a4)
    80006030:	96be                	add	a3,a3,a5
    80006032:	00c6d603          	lhu	a2,12(a3)
    80006036:	00166613          	ori	a2,a2,1
    8000603a:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000603e:	f8842683          	lw	a3,-120(s0)
    80006042:	6310                	ld	a2,0(a4)
    80006044:	97b2                	add	a5,a5,a2
    80006046:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    8000604a:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    8000604e:	0612                	slli	a2,a2,0x4
    80006050:	962a                	add	a2,a2,a0
    80006052:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006056:	00469793          	slli	a5,a3,0x4
    8000605a:	630c                	ld	a1,0(a4)
    8000605c:	95be                	add	a1,a1,a5
    8000605e:	6689                	lui	a3,0x2
    80006060:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006064:	96ca                	add	a3,a3,s2
    80006066:	96aa                	add	a3,a3,a0
    80006068:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    8000606a:	6314                	ld	a3,0(a4)
    8000606c:	96be                	add	a3,a3,a5
    8000606e:	4585                	li	a1,1
    80006070:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006072:	6314                	ld	a3,0(a4)
    80006074:	96be                	add	a3,a3,a5
    80006076:	4509                	li	a0,2
    80006078:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000607c:	6314                	ld	a3,0(a4)
    8000607e:	97b6                	add	a5,a5,a3
    80006080:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006084:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006088:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8000608c:	6714                	ld	a3,8(a4)
    8000608e:	0026d783          	lhu	a5,2(a3)
    80006092:	8b9d                	andi	a5,a5,7
    80006094:	0789                	addi	a5,a5,2
    80006096:	0786                	slli	a5,a5,0x1
    80006098:	97b6                	add	a5,a5,a3
    8000609a:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000609e:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800060a2:	6718                	ld	a4,8(a4)
    800060a4:	00275783          	lhu	a5,2(a4)
    800060a8:	2785                	addiw	a5,a5,1
    800060aa:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060ae:	100017b7          	lui	a5,0x10001
    800060b2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060b6:	004aa783          	lw	a5,4(s5)
    800060ba:	02b79163          	bne	a5,a1,800060dc <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800060be:	0001f917          	auipc	s2,0x1f
    800060c2:	fea90913          	addi	s2,s2,-22 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800060c6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800060c8:	85ca                	mv	a1,s2
    800060ca:	8556                	mv	a0,s5
    800060cc:	ffffc097          	auipc	ra,0xffffc
    800060d0:	160080e7          	jalr	352(ra) # 8000222c <sleep>
  while(b->disk == 1) {
    800060d4:	004aa783          	lw	a5,4(s5)
    800060d8:	fe9788e3          	beq	a5,s1,800060c8 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800060dc:	f8042483          	lw	s1,-128(s0)
    800060e0:	20048793          	addi	a5,s1,512
    800060e4:	00479713          	slli	a4,a5,0x4
    800060e8:	0001d797          	auipc	a5,0x1d
    800060ec:	f1878793          	addi	a5,a5,-232 # 80023000 <disk>
    800060f0:	97ba                	add	a5,a5,a4
    800060f2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800060f6:	0001f917          	auipc	s2,0x1f
    800060fa:	f0a90913          	addi	s2,s2,-246 # 80025000 <disk+0x2000>
    800060fe:	a019                	j	80006104 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    80006100:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80006104:	8526                	mv	a0,s1
    80006106:	00000097          	auipc	ra,0x0
    8000610a:	c80080e7          	jalr	-896(ra) # 80005d86 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    8000610e:	0492                	slli	s1,s1,0x4
    80006110:	00093783          	ld	a5,0(s2)
    80006114:	94be                	add	s1,s1,a5
    80006116:	00c4d783          	lhu	a5,12(s1)
    8000611a:	8b85                	andi	a5,a5,1
    8000611c:	f3f5                	bnez	a5,80006100 <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000611e:	0001f517          	auipc	a0,0x1f
    80006122:	f8a50513          	addi	a0,a0,-118 # 800250a8 <disk+0x20a8>
    80006126:	ffffb097          	auipc	ra,0xffffb
    8000612a:	bd6080e7          	jalr	-1066(ra) # 80000cfc <release>
}
    8000612e:	60aa                	ld	ra,136(sp)
    80006130:	640a                	ld	s0,128(sp)
    80006132:	74e6                	ld	s1,120(sp)
    80006134:	7946                	ld	s2,112(sp)
    80006136:	79a6                	ld	s3,104(sp)
    80006138:	7a06                	ld	s4,96(sp)
    8000613a:	6ae6                	ld	s5,88(sp)
    8000613c:	6b46                	ld	s6,80(sp)
    8000613e:	6ba6                	ld	s7,72(sp)
    80006140:	6c06                	ld	s8,64(sp)
    80006142:	7ce2                	ld	s9,56(sp)
    80006144:	7d42                	ld	s10,48(sp)
    80006146:	7da2                	ld	s11,40(sp)
    80006148:	6149                	addi	sp,sp,144
    8000614a:	8082                	ret
  if(write)
    8000614c:	01a037b3          	snez	a5,s10
    80006150:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006154:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006158:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000615c:	f8042483          	lw	s1,-128(s0)
    80006160:	00449913          	slli	s2,s1,0x4
    80006164:	0001f997          	auipc	s3,0x1f
    80006168:	e9c98993          	addi	s3,s3,-356 # 80025000 <disk+0x2000>
    8000616c:	0009ba03          	ld	s4,0(s3)
    80006170:	9a4a                	add	s4,s4,s2
    80006172:	f7040513          	addi	a0,s0,-144
    80006176:	ffffb097          	auipc	ra,0xffffb
    8000617a:	f9e080e7          	jalr	-98(ra) # 80001114 <kvmpa>
    8000617e:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    80006182:	0009b783          	ld	a5,0(s3)
    80006186:	97ca                	add	a5,a5,s2
    80006188:	4741                	li	a4,16
    8000618a:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000618c:	0009b783          	ld	a5,0(s3)
    80006190:	97ca                	add	a5,a5,s2
    80006192:	4705                	li	a4,1
    80006194:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006198:	f8442783          	lw	a5,-124(s0)
    8000619c:	0009b703          	ld	a4,0(s3)
    800061a0:	974a                	add	a4,a4,s2
    800061a2:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800061a6:	0792                	slli	a5,a5,0x4
    800061a8:	0009b703          	ld	a4,0(s3)
    800061ac:	973e                	add	a4,a4,a5
    800061ae:	058a8693          	addi	a3,s5,88
    800061b2:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    800061b4:	0009b703          	ld	a4,0(s3)
    800061b8:	973e                	add	a4,a4,a5
    800061ba:	40000693          	li	a3,1024
    800061be:	c714                	sw	a3,8(a4)
  if(write)
    800061c0:	e40d18e3          	bnez	s10,80006010 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800061c4:	0001f717          	auipc	a4,0x1f
    800061c8:	e3c73703          	ld	a4,-452(a4) # 80025000 <disk+0x2000>
    800061cc:	973e                	add	a4,a4,a5
    800061ce:	4689                	li	a3,2
    800061d0:	00d71623          	sh	a3,12(a4)
    800061d4:	b5a9                	j	8000601e <virtio_disk_rw+0xd2>

00000000800061d6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061d6:	1101                	addi	sp,sp,-32
    800061d8:	ec06                	sd	ra,24(sp)
    800061da:	e822                	sd	s0,16(sp)
    800061dc:	e426                	sd	s1,8(sp)
    800061de:	e04a                	sd	s2,0(sp)
    800061e0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061e2:	0001f517          	auipc	a0,0x1f
    800061e6:	ec650513          	addi	a0,a0,-314 # 800250a8 <disk+0x20a8>
    800061ea:	ffffb097          	auipc	ra,0xffffb
    800061ee:	a5e080e7          	jalr	-1442(ra) # 80000c48 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800061f2:	0001f717          	auipc	a4,0x1f
    800061f6:	e0e70713          	addi	a4,a4,-498 # 80025000 <disk+0x2000>
    800061fa:	02075783          	lhu	a5,32(a4)
    800061fe:	6b18                	ld	a4,16(a4)
    80006200:	00275683          	lhu	a3,2(a4)
    80006204:	8ebd                	xor	a3,a3,a5
    80006206:	8a9d                	andi	a3,a3,7
    80006208:	cab9                	beqz	a3,8000625e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000620a:	0001d917          	auipc	s2,0x1d
    8000620e:	df690913          	addi	s2,s2,-522 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006212:	0001f497          	auipc	s1,0x1f
    80006216:	dee48493          	addi	s1,s1,-530 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000621a:	078e                	slli	a5,a5,0x3
    8000621c:	97ba                	add	a5,a5,a4
    8000621e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006220:	20078713          	addi	a4,a5,512
    80006224:	0712                	slli	a4,a4,0x4
    80006226:	974a                	add	a4,a4,s2
    80006228:	03074703          	lbu	a4,48(a4)
    8000622c:	ef21                	bnez	a4,80006284 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000622e:	20078793          	addi	a5,a5,512
    80006232:	0792                	slli	a5,a5,0x4
    80006234:	97ca                	add	a5,a5,s2
    80006236:	7798                	ld	a4,40(a5)
    80006238:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000623c:	7788                	ld	a0,40(a5)
    8000623e:	ffffc097          	auipc	ra,0xffffc
    80006242:	16e080e7          	jalr	366(ra) # 800023ac <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006246:	0204d783          	lhu	a5,32(s1)
    8000624a:	2785                	addiw	a5,a5,1
    8000624c:	8b9d                	andi	a5,a5,7
    8000624e:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006252:	6898                	ld	a4,16(s1)
    80006254:	00275683          	lhu	a3,2(a4)
    80006258:	8a9d                	andi	a3,a3,7
    8000625a:	fcf690e3          	bne	a3,a5,8000621a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000625e:	10001737          	lui	a4,0x10001
    80006262:	533c                	lw	a5,96(a4)
    80006264:	8b8d                	andi	a5,a5,3
    80006266:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006268:	0001f517          	auipc	a0,0x1f
    8000626c:	e4050513          	addi	a0,a0,-448 # 800250a8 <disk+0x20a8>
    80006270:	ffffb097          	auipc	ra,0xffffb
    80006274:	a8c080e7          	jalr	-1396(ra) # 80000cfc <release>
}
    80006278:	60e2                	ld	ra,24(sp)
    8000627a:	6442                	ld	s0,16(sp)
    8000627c:	64a2                	ld	s1,8(sp)
    8000627e:	6902                	ld	s2,0(sp)
    80006280:	6105                	addi	sp,sp,32
    80006282:	8082                	ret
      panic("virtio_disk_intr status");
    80006284:	00002517          	auipc	a0,0x2
    80006288:	59c50513          	addi	a0,a0,1436 # 80008820 <syscalls+0x3e0>
    8000628c:	ffffa097          	auipc	ra,0xffffa
    80006290:	2b6080e7          	jalr	694(ra) # 80000542 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
