
user/_sleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
	if(argc <=1)
   8:	4785                	li	a5,1
   a:	02a7d063          	bge	a5,a0,2a <main+0x2a>
	{
		fprintf(2, "Usage: sleep <time>\n");
		exit(1);
	}

	int time = atoi(argv[1]);
   e:	6588                	ld	a0,8(a1)
  10:	00000097          	auipc	ra,0x0
  14:	1a8080e7          	jalr	424(ra) # 1b8 <atoi>
	sleep(time);
  18:	00000097          	auipc	ra,0x0
  1c:	32c080e7          	jalr	812(ra) # 344 <sleep>

	exit(0);
  20:	4501                	li	a0,0
  22:	00000097          	auipc	ra,0x0
  26:	292080e7          	jalr	658(ra) # 2b4 <exit>
		fprintf(2, "Usage: sleep <time>\n");
  2a:	00000597          	auipc	a1,0x0
  2e:	7a658593          	addi	a1,a1,1958 # 7d0 <malloc+0xe6>
  32:	4509                	li	a0,2
  34:	00000097          	auipc	ra,0x0
  38:	5ca080e7          	jalr	1482(ra) # 5fe <fprintf>
		exit(1);
  3c:	4505                	li	a0,1
  3e:	00000097          	auipc	ra,0x0
  42:	276080e7          	jalr	630(ra) # 2b4 <exit>

0000000000000046 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4c:	87aa                	mv	a5,a0
  4e:	0585                	addi	a1,a1,1
  50:	0785                	addi	a5,a5,1
  52:	fff5c703          	lbu	a4,-1(a1)
  56:	fee78fa3          	sb	a4,-1(a5)
  5a:	fb75                	bnez	a4,4e <strcpy+0x8>
    ;
  return os;
}
  5c:	6422                	ld	s0,8(sp)
  5e:	0141                	addi	sp,sp,16
  60:	8082                	ret

0000000000000062 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  62:	1141                	addi	sp,sp,-16
  64:	e422                	sd	s0,8(sp)
  66:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  68:	00054783          	lbu	a5,0(a0)
  6c:	cb91                	beqz	a5,80 <strcmp+0x1e>
  6e:	0005c703          	lbu	a4,0(a1)
  72:	00f71763          	bne	a4,a5,80 <strcmp+0x1e>
    p++, q++;
  76:	0505                	addi	a0,a0,1
  78:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	fbe5                	bnez	a5,6e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  80:	0005c503          	lbu	a0,0(a1)
}
  84:	40a7853b          	subw	a0,a5,a0
  88:	6422                	ld	s0,8(sp)
  8a:	0141                	addi	sp,sp,16
  8c:	8082                	ret

000000000000008e <strlen>:

uint
strlen(const char *s)
{
  8e:	1141                	addi	sp,sp,-16
  90:	e422                	sd	s0,8(sp)
  92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  94:	00054783          	lbu	a5,0(a0)
  98:	cf91                	beqz	a5,b4 <strlen+0x26>
  9a:	0505                	addi	a0,a0,1
  9c:	87aa                	mv	a5,a0
  9e:	4685                	li	a3,1
  a0:	9e89                	subw	a3,a3,a0
  a2:	00f6853b          	addw	a0,a3,a5
  a6:	0785                	addi	a5,a5,1
  a8:	fff7c703          	lbu	a4,-1(a5)
  ac:	fb7d                	bnez	a4,a2 <strlen+0x14>
    ;
  return n;
}
  ae:	6422                	ld	s0,8(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret
  for(n = 0; s[n]; n++)
  b4:	4501                	li	a0,0
  b6:	bfe5                	j	ae <strlen+0x20>

00000000000000b8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e422                	sd	s0,8(sp)
  bc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  be:	ca19                	beqz	a2,d4 <memset+0x1c>
  c0:	87aa                	mv	a5,a0
  c2:	1602                	slli	a2,a2,0x20
  c4:	9201                	srli	a2,a2,0x20
  c6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ce:	0785                	addi	a5,a5,1
  d0:	fee79de3          	bne	a5,a4,ca <memset+0x12>
  }
  return dst;
}
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	addi	sp,sp,16
  d8:	8082                	ret

00000000000000da <strchr>:

char*
strchr(const char *s, char c)
{
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e0:	00054783          	lbu	a5,0(a0)
  e4:	cb99                	beqz	a5,fa <strchr+0x20>
    if(*s == c)
  e6:	00f58763          	beq	a1,a5,f4 <strchr+0x1a>
  for(; *s; s++)
  ea:	0505                	addi	a0,a0,1
  ec:	00054783          	lbu	a5,0(a0)
  f0:	fbfd                	bnez	a5,e6 <strchr+0xc>
      return (char*)s;
  return 0;
  f2:	4501                	li	a0,0
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret
  return 0;
  fa:	4501                	li	a0,0
  fc:	bfe5                	j	f4 <strchr+0x1a>

00000000000000fe <gets>:

char*
gets(char *buf, int max)
{
  fe:	711d                	addi	sp,sp,-96
 100:	ec86                	sd	ra,88(sp)
 102:	e8a2                	sd	s0,80(sp)
 104:	e4a6                	sd	s1,72(sp)
 106:	e0ca                	sd	s2,64(sp)
 108:	fc4e                	sd	s3,56(sp)
 10a:	f852                	sd	s4,48(sp)
 10c:	f456                	sd	s5,40(sp)
 10e:	f05a                	sd	s6,32(sp)
 110:	ec5e                	sd	s7,24(sp)
 112:	1080                	addi	s0,sp,96
 114:	8baa                	mv	s7,a0
 116:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 118:	892a                	mv	s2,a0
 11a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11c:	4aa9                	li	s5,10
 11e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 120:	89a6                	mv	s3,s1
 122:	2485                	addiw	s1,s1,1
 124:	0344d863          	bge	s1,s4,154 <gets+0x56>
    cc = read(0, &c, 1);
 128:	4605                	li	a2,1
 12a:	faf40593          	addi	a1,s0,-81
 12e:	4501                	li	a0,0
 130:	00000097          	auipc	ra,0x0
 134:	19c080e7          	jalr	412(ra) # 2cc <read>
    if(cc < 1)
 138:	00a05e63          	blez	a0,154 <gets+0x56>
    buf[i++] = c;
 13c:	faf44783          	lbu	a5,-81(s0)
 140:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 144:	01578763          	beq	a5,s5,152 <gets+0x54>
 148:	0905                	addi	s2,s2,1
 14a:	fd679be3          	bne	a5,s6,120 <gets+0x22>
  for(i=0; i+1 < max; ){
 14e:	89a6                	mv	s3,s1
 150:	a011                	j	154 <gets+0x56>
 152:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 154:	99de                	add	s3,s3,s7
 156:	00098023          	sb	zero,0(s3)
  return buf;
}
 15a:	855e                	mv	a0,s7
 15c:	60e6                	ld	ra,88(sp)
 15e:	6446                	ld	s0,80(sp)
 160:	64a6                	ld	s1,72(sp)
 162:	6906                	ld	s2,64(sp)
 164:	79e2                	ld	s3,56(sp)
 166:	7a42                	ld	s4,48(sp)
 168:	7aa2                	ld	s5,40(sp)
 16a:	7b02                	ld	s6,32(sp)
 16c:	6be2                	ld	s7,24(sp)
 16e:	6125                	addi	sp,sp,96
 170:	8082                	ret

0000000000000172 <stat>:

int
stat(const char *n, struct stat *st)
{
 172:	1101                	addi	sp,sp,-32
 174:	ec06                	sd	ra,24(sp)
 176:	e822                	sd	s0,16(sp)
 178:	e426                	sd	s1,8(sp)
 17a:	e04a                	sd	s2,0(sp)
 17c:	1000                	addi	s0,sp,32
 17e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 180:	4581                	li	a1,0
 182:	00000097          	auipc	ra,0x0
 186:	172080e7          	jalr	370(ra) # 2f4 <open>
  if(fd < 0)
 18a:	02054563          	bltz	a0,1b4 <stat+0x42>
 18e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 190:	85ca                	mv	a1,s2
 192:	00000097          	auipc	ra,0x0
 196:	17a080e7          	jalr	378(ra) # 30c <fstat>
 19a:	892a                	mv	s2,a0
  close(fd);
 19c:	8526                	mv	a0,s1
 19e:	00000097          	auipc	ra,0x0
 1a2:	13e080e7          	jalr	318(ra) # 2dc <close>
  return r;
}
 1a6:	854a                	mv	a0,s2
 1a8:	60e2                	ld	ra,24(sp)
 1aa:	6442                	ld	s0,16(sp)
 1ac:	64a2                	ld	s1,8(sp)
 1ae:	6902                	ld	s2,0(sp)
 1b0:	6105                	addi	sp,sp,32
 1b2:	8082                	ret
    return -1;
 1b4:	597d                	li	s2,-1
 1b6:	bfc5                	j	1a6 <stat+0x34>

00000000000001b8 <atoi>:

int
atoi(const char *s)
{
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e422                	sd	s0,8(sp)
 1bc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1be:	00054603          	lbu	a2,0(a0)
 1c2:	fd06079b          	addiw	a5,a2,-48
 1c6:	0ff7f793          	andi	a5,a5,255
 1ca:	4725                	li	a4,9
 1cc:	02f76963          	bltu	a4,a5,1fe <atoi+0x46>
 1d0:	86aa                	mv	a3,a0
  n = 0;
 1d2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1d4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1d6:	0685                	addi	a3,a3,1
 1d8:	0025179b          	slliw	a5,a0,0x2
 1dc:	9fa9                	addw	a5,a5,a0
 1de:	0017979b          	slliw	a5,a5,0x1
 1e2:	9fb1                	addw	a5,a5,a2
 1e4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e8:	0006c603          	lbu	a2,0(a3)
 1ec:	fd06071b          	addiw	a4,a2,-48
 1f0:	0ff77713          	andi	a4,a4,255
 1f4:	fee5f1e3          	bgeu	a1,a4,1d6 <atoi+0x1e>
  return n;
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret
  n = 0;
 1fe:	4501                	li	a0,0
 200:	bfe5                	j	1f8 <atoi+0x40>

0000000000000202 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 208:	02b57463          	bgeu	a0,a1,230 <memmove+0x2e>
    while(n-- > 0)
 20c:	00c05f63          	blez	a2,22a <memmove+0x28>
 210:	1602                	slli	a2,a2,0x20
 212:	9201                	srli	a2,a2,0x20
 214:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 218:	872a                	mv	a4,a0
      *dst++ = *src++;
 21a:	0585                	addi	a1,a1,1
 21c:	0705                	addi	a4,a4,1
 21e:	fff5c683          	lbu	a3,-1(a1)
 222:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 226:	fee79ae3          	bne	a5,a4,21a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
    dst += n;
 230:	00c50733          	add	a4,a0,a2
    src += n;
 234:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 236:	fec05ae3          	blez	a2,22a <memmove+0x28>
 23a:	fff6079b          	addiw	a5,a2,-1
 23e:	1782                	slli	a5,a5,0x20
 240:	9381                	srli	a5,a5,0x20
 242:	fff7c793          	not	a5,a5
 246:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 248:	15fd                	addi	a1,a1,-1
 24a:	177d                	addi	a4,a4,-1
 24c:	0005c683          	lbu	a3,0(a1)
 250:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 254:	fee79ae3          	bne	a5,a4,248 <memmove+0x46>
 258:	bfc9                	j	22a <memmove+0x28>

000000000000025a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 260:	ca05                	beqz	a2,290 <memcmp+0x36>
 262:	fff6069b          	addiw	a3,a2,-1
 266:	1682                	slli	a3,a3,0x20
 268:	9281                	srli	a3,a3,0x20
 26a:	0685                	addi	a3,a3,1
 26c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 26e:	00054783          	lbu	a5,0(a0)
 272:	0005c703          	lbu	a4,0(a1)
 276:	00e79863          	bne	a5,a4,286 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 27a:	0505                	addi	a0,a0,1
    p2++;
 27c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 27e:	fed518e3          	bne	a0,a3,26e <memcmp+0x14>
  }
  return 0;
 282:	4501                	li	a0,0
 284:	a019                	j	28a <memcmp+0x30>
      return *p1 - *p2;
 286:	40e7853b          	subw	a0,a5,a4
}
 28a:	6422                	ld	s0,8(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
  return 0;
 290:	4501                	li	a0,0
 292:	bfe5                	j	28a <memcmp+0x30>

0000000000000294 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 294:	1141                	addi	sp,sp,-16
 296:	e406                	sd	ra,8(sp)
 298:	e022                	sd	s0,0(sp)
 29a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 29c:	00000097          	auipc	ra,0x0
 2a0:	f66080e7          	jalr	-154(ra) # 202 <memmove>
}
 2a4:	60a2                	ld	ra,8(sp)
 2a6:	6402                	ld	s0,0(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret

00000000000002ac <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ac:	4885                	li	a7,1
 ecall
 2ae:	00000073          	ecall
 ret
 2b2:	8082                	ret

00000000000002b4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b4:	4889                	li	a7,2
 ecall
 2b6:	00000073          	ecall
 ret
 2ba:	8082                	ret

00000000000002bc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2bc:	488d                	li	a7,3
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c4:	4891                	li	a7,4
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <read>:
.global read
read:
 li a7, SYS_read
 2cc:	4895                	li	a7,5
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <write>:
.global write
write:
 li a7, SYS_write
 2d4:	48c1                	li	a7,16
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <close>:
.global close
close:
 li a7, SYS_close
 2dc:	48d5                	li	a7,21
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e4:	4899                	li	a7,6
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ec:	489d                	li	a7,7
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <open>:
.global open
open:
 li a7, SYS_open
 2f4:	48bd                	li	a7,15
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2fc:	48c5                	li	a7,17
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 304:	48c9                	li	a7,18
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 30c:	48a1                	li	a7,8
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <link>:
.global link
link:
 li a7, SYS_link
 314:	48cd                	li	a7,19
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 31c:	48d1                	li	a7,20
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 324:	48a5                	li	a7,9
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <dup>:
.global dup
dup:
 li a7, SYS_dup
 32c:	48a9                	li	a7,10
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 334:	48ad                	li	a7,11
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 33c:	48b1                	li	a7,12
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 344:	48b5                	li	a7,13
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 34c:	48b9                	li	a7,14
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 354:	1101                	addi	sp,sp,-32
 356:	ec06                	sd	ra,24(sp)
 358:	e822                	sd	s0,16(sp)
 35a:	1000                	addi	s0,sp,32
 35c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 360:	4605                	li	a2,1
 362:	fef40593          	addi	a1,s0,-17
 366:	00000097          	auipc	ra,0x0
 36a:	f6e080e7          	jalr	-146(ra) # 2d4 <write>
}
 36e:	60e2                	ld	ra,24(sp)
 370:	6442                	ld	s0,16(sp)
 372:	6105                	addi	sp,sp,32
 374:	8082                	ret

0000000000000376 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 376:	7139                	addi	sp,sp,-64
 378:	fc06                	sd	ra,56(sp)
 37a:	f822                	sd	s0,48(sp)
 37c:	f426                	sd	s1,40(sp)
 37e:	f04a                	sd	s2,32(sp)
 380:	ec4e                	sd	s3,24(sp)
 382:	0080                	addi	s0,sp,64
 384:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 386:	c299                	beqz	a3,38c <printint+0x16>
 388:	0805c863          	bltz	a1,418 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 38c:	2581                	sext.w	a1,a1
  neg = 0;
 38e:	4881                	li	a7,0
 390:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 394:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 396:	2601                	sext.w	a2,a2
 398:	00000517          	auipc	a0,0x0
 39c:	45850513          	addi	a0,a0,1112 # 7f0 <digits>
 3a0:	883a                	mv	a6,a4
 3a2:	2705                	addiw	a4,a4,1
 3a4:	02c5f7bb          	remuw	a5,a1,a2
 3a8:	1782                	slli	a5,a5,0x20
 3aa:	9381                	srli	a5,a5,0x20
 3ac:	97aa                	add	a5,a5,a0
 3ae:	0007c783          	lbu	a5,0(a5)
 3b2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3b6:	0005879b          	sext.w	a5,a1
 3ba:	02c5d5bb          	divuw	a1,a1,a2
 3be:	0685                	addi	a3,a3,1
 3c0:	fec7f0e3          	bgeu	a5,a2,3a0 <printint+0x2a>
  if(neg)
 3c4:	00088b63          	beqz	a7,3da <printint+0x64>
    buf[i++] = '-';
 3c8:	fd040793          	addi	a5,s0,-48
 3cc:	973e                	add	a4,a4,a5
 3ce:	02d00793          	li	a5,45
 3d2:	fef70823          	sb	a5,-16(a4)
 3d6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3da:	02e05863          	blez	a4,40a <printint+0x94>
 3de:	fc040793          	addi	a5,s0,-64
 3e2:	00e78933          	add	s2,a5,a4
 3e6:	fff78993          	addi	s3,a5,-1
 3ea:	99ba                	add	s3,s3,a4
 3ec:	377d                	addiw	a4,a4,-1
 3ee:	1702                	slli	a4,a4,0x20
 3f0:	9301                	srli	a4,a4,0x20
 3f2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3f6:	fff94583          	lbu	a1,-1(s2)
 3fa:	8526                	mv	a0,s1
 3fc:	00000097          	auipc	ra,0x0
 400:	f58080e7          	jalr	-168(ra) # 354 <putc>
  while(--i >= 0)
 404:	197d                	addi	s2,s2,-1
 406:	ff3918e3          	bne	s2,s3,3f6 <printint+0x80>
}
 40a:	70e2                	ld	ra,56(sp)
 40c:	7442                	ld	s0,48(sp)
 40e:	74a2                	ld	s1,40(sp)
 410:	7902                	ld	s2,32(sp)
 412:	69e2                	ld	s3,24(sp)
 414:	6121                	addi	sp,sp,64
 416:	8082                	ret
    x = -xx;
 418:	40b005bb          	negw	a1,a1
    neg = 1;
 41c:	4885                	li	a7,1
    x = -xx;
 41e:	bf8d                	j	390 <printint+0x1a>

0000000000000420 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 420:	7119                	addi	sp,sp,-128
 422:	fc86                	sd	ra,120(sp)
 424:	f8a2                	sd	s0,112(sp)
 426:	f4a6                	sd	s1,104(sp)
 428:	f0ca                	sd	s2,96(sp)
 42a:	ecce                	sd	s3,88(sp)
 42c:	e8d2                	sd	s4,80(sp)
 42e:	e4d6                	sd	s5,72(sp)
 430:	e0da                	sd	s6,64(sp)
 432:	fc5e                	sd	s7,56(sp)
 434:	f862                	sd	s8,48(sp)
 436:	f466                	sd	s9,40(sp)
 438:	f06a                	sd	s10,32(sp)
 43a:	ec6e                	sd	s11,24(sp)
 43c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 43e:	0005c903          	lbu	s2,0(a1)
 442:	18090f63          	beqz	s2,5e0 <vprintf+0x1c0>
 446:	8aaa                	mv	s5,a0
 448:	8b32                	mv	s6,a2
 44a:	00158493          	addi	s1,a1,1
  state = 0;
 44e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 450:	02500a13          	li	s4,37
      if(c == 'd'){
 454:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 458:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 45c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 460:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 464:	00000b97          	auipc	s7,0x0
 468:	38cb8b93          	addi	s7,s7,908 # 7f0 <digits>
 46c:	a839                	j	48a <vprintf+0x6a>
        putc(fd, c);
 46e:	85ca                	mv	a1,s2
 470:	8556                	mv	a0,s5
 472:	00000097          	auipc	ra,0x0
 476:	ee2080e7          	jalr	-286(ra) # 354 <putc>
 47a:	a019                	j	480 <vprintf+0x60>
    } else if(state == '%'){
 47c:	01498f63          	beq	s3,s4,49a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 480:	0485                	addi	s1,s1,1
 482:	fff4c903          	lbu	s2,-1(s1)
 486:	14090d63          	beqz	s2,5e0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 48a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 48e:	fe0997e3          	bnez	s3,47c <vprintf+0x5c>
      if(c == '%'){
 492:	fd479ee3          	bne	a5,s4,46e <vprintf+0x4e>
        state = '%';
 496:	89be                	mv	s3,a5
 498:	b7e5                	j	480 <vprintf+0x60>
      if(c == 'd'){
 49a:	05878063          	beq	a5,s8,4da <vprintf+0xba>
      } else if(c == 'l') {
 49e:	05978c63          	beq	a5,s9,4f6 <vprintf+0xd6>
      } else if(c == 'x') {
 4a2:	07a78863          	beq	a5,s10,512 <vprintf+0xf2>
      } else if(c == 'p') {
 4a6:	09b78463          	beq	a5,s11,52e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4aa:	07300713          	li	a4,115
 4ae:	0ce78663          	beq	a5,a4,57a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4b2:	06300713          	li	a4,99
 4b6:	0ee78e63          	beq	a5,a4,5b2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4ba:	11478863          	beq	a5,s4,5ca <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4be:	85d2                	mv	a1,s4
 4c0:	8556                	mv	a0,s5
 4c2:	00000097          	auipc	ra,0x0
 4c6:	e92080e7          	jalr	-366(ra) # 354 <putc>
        putc(fd, c);
 4ca:	85ca                	mv	a1,s2
 4cc:	8556                	mv	a0,s5
 4ce:	00000097          	auipc	ra,0x0
 4d2:	e86080e7          	jalr	-378(ra) # 354 <putc>
      }
      state = 0;
 4d6:	4981                	li	s3,0
 4d8:	b765                	j	480 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4da:	008b0913          	addi	s2,s6,8
 4de:	4685                	li	a3,1
 4e0:	4629                	li	a2,10
 4e2:	000b2583          	lw	a1,0(s6)
 4e6:	8556                	mv	a0,s5
 4e8:	00000097          	auipc	ra,0x0
 4ec:	e8e080e7          	jalr	-370(ra) # 376 <printint>
 4f0:	8b4a                	mv	s6,s2
      state = 0;
 4f2:	4981                	li	s3,0
 4f4:	b771                	j	480 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4f6:	008b0913          	addi	s2,s6,8
 4fa:	4681                	li	a3,0
 4fc:	4629                	li	a2,10
 4fe:	000b2583          	lw	a1,0(s6)
 502:	8556                	mv	a0,s5
 504:	00000097          	auipc	ra,0x0
 508:	e72080e7          	jalr	-398(ra) # 376 <printint>
 50c:	8b4a                	mv	s6,s2
      state = 0;
 50e:	4981                	li	s3,0
 510:	bf85                	j	480 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 512:	008b0913          	addi	s2,s6,8
 516:	4681                	li	a3,0
 518:	4641                	li	a2,16
 51a:	000b2583          	lw	a1,0(s6)
 51e:	8556                	mv	a0,s5
 520:	00000097          	auipc	ra,0x0
 524:	e56080e7          	jalr	-426(ra) # 376 <printint>
 528:	8b4a                	mv	s6,s2
      state = 0;
 52a:	4981                	li	s3,0
 52c:	bf91                	j	480 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 52e:	008b0793          	addi	a5,s6,8
 532:	f8f43423          	sd	a5,-120(s0)
 536:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 53a:	03000593          	li	a1,48
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	e14080e7          	jalr	-492(ra) # 354 <putc>
  putc(fd, 'x');
 548:	85ea                	mv	a1,s10
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e08080e7          	jalr	-504(ra) # 354 <putc>
 554:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 556:	03c9d793          	srli	a5,s3,0x3c
 55a:	97de                	add	a5,a5,s7
 55c:	0007c583          	lbu	a1,0(a5)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	df2080e7          	jalr	-526(ra) # 354 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 56a:	0992                	slli	s3,s3,0x4
 56c:	397d                	addiw	s2,s2,-1
 56e:	fe0914e3          	bnez	s2,556 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 572:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 576:	4981                	li	s3,0
 578:	b721                	j	480 <vprintf+0x60>
        s = va_arg(ap, char*);
 57a:	008b0993          	addi	s3,s6,8
 57e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 582:	02090163          	beqz	s2,5a4 <vprintf+0x184>
        while(*s != 0){
 586:	00094583          	lbu	a1,0(s2)
 58a:	c9a1                	beqz	a1,5da <vprintf+0x1ba>
          putc(fd, *s);
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	dc6080e7          	jalr	-570(ra) # 354 <putc>
          s++;
 596:	0905                	addi	s2,s2,1
        while(*s != 0){
 598:	00094583          	lbu	a1,0(s2)
 59c:	f9e5                	bnez	a1,58c <vprintf+0x16c>
        s = va_arg(ap, char*);
 59e:	8b4e                	mv	s6,s3
      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	bdf9                	j	480 <vprintf+0x60>
          s = "(null)";
 5a4:	00000917          	auipc	s2,0x0
 5a8:	24490913          	addi	s2,s2,580 # 7e8 <malloc+0xfe>
        while(*s != 0){
 5ac:	02800593          	li	a1,40
 5b0:	bff1                	j	58c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5b2:	008b0913          	addi	s2,s6,8
 5b6:	000b4583          	lbu	a1,0(s6)
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	d98080e7          	jalr	-616(ra) # 354 <putc>
 5c4:	8b4a                	mv	s6,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bd65                	j	480 <vprintf+0x60>
        putc(fd, c);
 5ca:	85d2                	mv	a1,s4
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	d86080e7          	jalr	-634(ra) # 354 <putc>
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	b565                	j	480 <vprintf+0x60>
        s = va_arg(ap, char*);
 5da:	8b4e                	mv	s6,s3
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b54d                	j	480 <vprintf+0x60>
    }
  }
}
 5e0:	70e6                	ld	ra,120(sp)
 5e2:	7446                	ld	s0,112(sp)
 5e4:	74a6                	ld	s1,104(sp)
 5e6:	7906                	ld	s2,96(sp)
 5e8:	69e6                	ld	s3,88(sp)
 5ea:	6a46                	ld	s4,80(sp)
 5ec:	6aa6                	ld	s5,72(sp)
 5ee:	6b06                	ld	s6,64(sp)
 5f0:	7be2                	ld	s7,56(sp)
 5f2:	7c42                	ld	s8,48(sp)
 5f4:	7ca2                	ld	s9,40(sp)
 5f6:	7d02                	ld	s10,32(sp)
 5f8:	6de2                	ld	s11,24(sp)
 5fa:	6109                	addi	sp,sp,128
 5fc:	8082                	ret

00000000000005fe <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5fe:	715d                	addi	sp,sp,-80
 600:	ec06                	sd	ra,24(sp)
 602:	e822                	sd	s0,16(sp)
 604:	1000                	addi	s0,sp,32
 606:	e010                	sd	a2,0(s0)
 608:	e414                	sd	a3,8(s0)
 60a:	e818                	sd	a4,16(s0)
 60c:	ec1c                	sd	a5,24(s0)
 60e:	03043023          	sd	a6,32(s0)
 612:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 616:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 61a:	8622                	mv	a2,s0
 61c:	00000097          	auipc	ra,0x0
 620:	e04080e7          	jalr	-508(ra) # 420 <vprintf>
}
 624:	60e2                	ld	ra,24(sp)
 626:	6442                	ld	s0,16(sp)
 628:	6161                	addi	sp,sp,80
 62a:	8082                	ret

000000000000062c <printf>:

void
printf(const char *fmt, ...)
{
 62c:	711d                	addi	sp,sp,-96
 62e:	ec06                	sd	ra,24(sp)
 630:	e822                	sd	s0,16(sp)
 632:	1000                	addi	s0,sp,32
 634:	e40c                	sd	a1,8(s0)
 636:	e810                	sd	a2,16(s0)
 638:	ec14                	sd	a3,24(s0)
 63a:	f018                	sd	a4,32(s0)
 63c:	f41c                	sd	a5,40(s0)
 63e:	03043823          	sd	a6,48(s0)
 642:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 646:	00840613          	addi	a2,s0,8
 64a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 64e:	85aa                	mv	a1,a0
 650:	4505                	li	a0,1
 652:	00000097          	auipc	ra,0x0
 656:	dce080e7          	jalr	-562(ra) # 420 <vprintf>
}
 65a:	60e2                	ld	ra,24(sp)
 65c:	6442                	ld	s0,16(sp)
 65e:	6125                	addi	sp,sp,96
 660:	8082                	ret

0000000000000662 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 662:	1141                	addi	sp,sp,-16
 664:	e422                	sd	s0,8(sp)
 666:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 668:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 66c:	00000797          	auipc	a5,0x0
 670:	19c7b783          	ld	a5,412(a5) # 808 <freep>
 674:	a805                	j	6a4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 676:	4618                	lw	a4,8(a2)
 678:	9db9                	addw	a1,a1,a4
 67a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 67e:	6398                	ld	a4,0(a5)
 680:	6318                	ld	a4,0(a4)
 682:	fee53823          	sd	a4,-16(a0)
 686:	a091                	j	6ca <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 688:	ff852703          	lw	a4,-8(a0)
 68c:	9e39                	addw	a2,a2,a4
 68e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 690:	ff053703          	ld	a4,-16(a0)
 694:	e398                	sd	a4,0(a5)
 696:	a099                	j	6dc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 698:	6398                	ld	a4,0(a5)
 69a:	00e7e463          	bltu	a5,a4,6a2 <free+0x40>
 69e:	00e6ea63          	bltu	a3,a4,6b2 <free+0x50>
{
 6a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a4:	fed7fae3          	bgeu	a5,a3,698 <free+0x36>
 6a8:	6398                	ld	a4,0(a5)
 6aa:	00e6e463          	bltu	a3,a4,6b2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ae:	fee7eae3          	bltu	a5,a4,6a2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6b2:	ff852583          	lw	a1,-8(a0)
 6b6:	6390                	ld	a2,0(a5)
 6b8:	02059713          	slli	a4,a1,0x20
 6bc:	9301                	srli	a4,a4,0x20
 6be:	0712                	slli	a4,a4,0x4
 6c0:	9736                	add	a4,a4,a3
 6c2:	fae60ae3          	beq	a2,a4,676 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6ca:	4790                	lw	a2,8(a5)
 6cc:	02061713          	slli	a4,a2,0x20
 6d0:	9301                	srli	a4,a4,0x20
 6d2:	0712                	slli	a4,a4,0x4
 6d4:	973e                	add	a4,a4,a5
 6d6:	fae689e3          	beq	a3,a4,688 <free+0x26>
  } else
    p->s.ptr = bp;
 6da:	e394                	sd	a3,0(a5)
  freep = p;
 6dc:	00000717          	auipc	a4,0x0
 6e0:	12f73623          	sd	a5,300(a4) # 808 <freep>
}
 6e4:	6422                	ld	s0,8(sp)
 6e6:	0141                	addi	sp,sp,16
 6e8:	8082                	ret

00000000000006ea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6ea:	7139                	addi	sp,sp,-64
 6ec:	fc06                	sd	ra,56(sp)
 6ee:	f822                	sd	s0,48(sp)
 6f0:	f426                	sd	s1,40(sp)
 6f2:	f04a                	sd	s2,32(sp)
 6f4:	ec4e                	sd	s3,24(sp)
 6f6:	e852                	sd	s4,16(sp)
 6f8:	e456                	sd	s5,8(sp)
 6fa:	e05a                	sd	s6,0(sp)
 6fc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6fe:	02051493          	slli	s1,a0,0x20
 702:	9081                	srli	s1,s1,0x20
 704:	04bd                	addi	s1,s1,15
 706:	8091                	srli	s1,s1,0x4
 708:	0014899b          	addiw	s3,s1,1
 70c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 70e:	00000517          	auipc	a0,0x0
 712:	0fa53503          	ld	a0,250(a0) # 808 <freep>
 716:	c515                	beqz	a0,742 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 718:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 71a:	4798                	lw	a4,8(a5)
 71c:	02977f63          	bgeu	a4,s1,75a <malloc+0x70>
 720:	8a4e                	mv	s4,s3
 722:	0009871b          	sext.w	a4,s3
 726:	6685                	lui	a3,0x1
 728:	00d77363          	bgeu	a4,a3,72e <malloc+0x44>
 72c:	6a05                	lui	s4,0x1
 72e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 732:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 736:	00000917          	auipc	s2,0x0
 73a:	0d290913          	addi	s2,s2,210 # 808 <freep>
  if(p == (char*)-1)
 73e:	5afd                	li	s5,-1
 740:	a88d                	j	7b2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 742:	00000797          	auipc	a5,0x0
 746:	0ce78793          	addi	a5,a5,206 # 810 <base>
 74a:	00000717          	auipc	a4,0x0
 74e:	0af73f23          	sd	a5,190(a4) # 808 <freep>
 752:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 754:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 758:	b7e1                	j	720 <malloc+0x36>
      if(p->s.size == nunits)
 75a:	02e48b63          	beq	s1,a4,790 <malloc+0xa6>
        p->s.size -= nunits;
 75e:	4137073b          	subw	a4,a4,s3
 762:	c798                	sw	a4,8(a5)
        p += p->s.size;
 764:	1702                	slli	a4,a4,0x20
 766:	9301                	srli	a4,a4,0x20
 768:	0712                	slli	a4,a4,0x4
 76a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 76c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 770:	00000717          	auipc	a4,0x0
 774:	08a73c23          	sd	a0,152(a4) # 808 <freep>
      return (void*)(p + 1);
 778:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 77c:	70e2                	ld	ra,56(sp)
 77e:	7442                	ld	s0,48(sp)
 780:	74a2                	ld	s1,40(sp)
 782:	7902                	ld	s2,32(sp)
 784:	69e2                	ld	s3,24(sp)
 786:	6a42                	ld	s4,16(sp)
 788:	6aa2                	ld	s5,8(sp)
 78a:	6b02                	ld	s6,0(sp)
 78c:	6121                	addi	sp,sp,64
 78e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 790:	6398                	ld	a4,0(a5)
 792:	e118                	sd	a4,0(a0)
 794:	bff1                	j	770 <malloc+0x86>
  hp->s.size = nu;
 796:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 79a:	0541                	addi	a0,a0,16
 79c:	00000097          	auipc	ra,0x0
 7a0:	ec6080e7          	jalr	-314(ra) # 662 <free>
  return freep;
 7a4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7a8:	d971                	beqz	a0,77c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7aa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ac:	4798                	lw	a4,8(a5)
 7ae:	fa9776e3          	bgeu	a4,s1,75a <malloc+0x70>
    if(p == freep)
 7b2:	00093703          	ld	a4,0(s2)
 7b6:	853e                	mv	a0,a5
 7b8:	fef719e3          	bne	a4,a5,7aa <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7bc:	8552                	mv	a0,s4
 7be:	00000097          	auipc	ra,0x0
 7c2:	b7e080e7          	jalr	-1154(ra) # 33c <sbrk>
  if(p == (char*)-1)
 7c6:	fd5518e3          	bne	a0,s5,796 <malloc+0xac>
        return 0;
 7ca:	4501                	li	a0,0
 7cc:	bf45                	j	77c <malloc+0x92>
