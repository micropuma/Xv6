
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#define BUFSIZE 30
//#define DEBUG 0

int main(int argc, char *argv[])
{
   0:	7149                	addi	sp,sp,-368
   2:	f686                	sd	ra,360(sp)
   4:	f2a2                	sd	s0,352(sp)
   6:	eea6                	sd	s1,344(sp)
   8:	eaca                	sd	s2,336(sp)
   a:	e6ce                	sd	s3,328(sp)
   c:	e2d2                	sd	s4,320(sp)
   e:	fe56                	sd	s5,312(sp)
  10:	fa5a                	sd	s6,304(sp)
  12:	f65e                	sd	s7,296(sp)
  14:	1a80                	addi	s0,sp,368
  16:	892a                	mv	s2,a0
  18:	84ae                	mv	s1,a1
	sleep(10);
  1a:	4529                	li	a0,10
  1c:	00000097          	auipc	ra,0x0
  20:	3ec080e7          	jalr	1004(ra) # 408 <sleep>

	//1. first need to figure out where is the standard input.
	char buf[BUFSIZE];
	read(0, buf, BUFSIZE);
  24:	4679                	li	a2,30
  26:	f9040593          	addi	a1,s0,-112
  2a:	4501                	li	a0,0
  2c:	00000097          	auipc	ra,0x0
  30:	364080e7          	jalr	868(ra) # 390 <read>

        //2. next need to get the xargs argv list!
	char *xargv[MAXARG];
	int xargc = 0;
	for(int i = 1; i < argc; i++)
  34:	4785                	li	a5,1
  36:	0527da63          	bge	a5,s2,8a <main+0x8a>
  3a:	00848713          	addi	a4,s1,8
  3e:	e9040793          	addi	a5,s0,-368
  42:	0009059b          	sext.w	a1,s2
  46:	ffe9069b          	addiw	a3,s2,-2
  4a:	1682                	slli	a3,a3,0x20
  4c:	9281                	srli	a3,a3,0x20
  4e:	068e                	slli	a3,a3,0x3
  50:	e9840613          	addi	a2,s0,-360
  54:	96b2                	add	a3,a3,a2
	{
		xargv[xargc++] = argv[i];
  56:	6310                	ld	a2,0(a4)
  58:	e390                	sd	a2,0(a5)
	for(int i = 1; i < argc; i++)
  5a:	0721                	addi	a4,a4,8
  5c:	07a1                	addi	a5,a5,8
  5e:	fed79ce3          	bne	a5,a3,56 <main+0x56>
		xargv[xargc++] = argv[i];
  62:	fff58b9b          	addiw	s7,a1,-1
	}

	//3. Finally, need to combine those two arguments into the right order!
	char *p = buf;
	printf("%s", buf);
  66:	f9040593          	addi	a1,s0,-112
  6a:	00001517          	auipc	a0,0x1
  6e:	83e50513          	addi	a0,a0,-1986 # 8a8 <malloc+0xea>
  72:	00000097          	auipc	ra,0x0
  76:	68e080e7          	jalr	1678(ra) # 700 <printf>
	for(int i = 0; i < BUFSIZE; i++)
  7a:	f9140493          	addi	s1,s0,-111
  7e:	4901                	li	s2,0
	char *p = buf;
  80:	f9040b13          	addi	s6,s0,-112
	{
		// \n means individual line, like -n 1 command!
		if(buf[i] == '\n')
  84:	4a29                	li	s4,10
	for(int i = 0; i < BUFSIZE; i++)
  86:	4af9                	li	s5,30
  88:	a829                	j	a2 <main+0xa2>
	int xargc = 0;
  8a:	4b81                	li	s7,0
  8c:	bfe9                	j	66 <main+0x66>
			int pid = fork();
			if(pid > 0)
			{
				// parent process change the p pointer and wait!
				p = &buf[i+1];
		 		wait(0);		
  8e:	4501                	li	a0,0
  90:	00000097          	auipc	ra,0x0
  94:	2f0080e7          	jalr	752(ra) # 380 <wait>
				p = &buf[i+1];
  98:	8b26                	mv	s6,s1
	for(int i = 0; i < BUFSIZE; i++)
  9a:	2905                	addiw	s2,s2,1
  9c:	0485                	addi	s1,s1,1
  9e:	05590c63          	beq	s2,s5,f6 <main+0xf6>
		if(buf[i] == '\n')
  a2:	fff4c783          	lbu	a5,-1(s1)
  a6:	ff479ae3          	bne	a5,s4,9a <main+0x9a>
			int pid = fork();
  aa:	00000097          	auipc	ra,0x0
  ae:	2c6080e7          	jalr	710(ra) # 370 <fork>
			if(pid > 0)
  b2:	fca04ee3          	bgtz	a0,8e <main+0x8e>
			}
			else if(pid == 0)
  b6:	f175                	bnez	a0,9a <main+0x9a>
			{
				// child process executes the command!
				buf[i] = 0;
  b8:	fb040793          	addi	a5,s0,-80
  bc:	993e                	add	s2,s2,a5
  be:	fe090023          	sb	zero,-32(s2)
				// construct the parameter list!
                                xargv[xargc++] = p;
  c2:	003b9793          	slli	a5,s7,0x3
  c6:	fb040713          	addi	a4,s0,-80
  ca:	97ba                	add	a5,a5,a4
  cc:	ef67b023          	sd	s6,-288(a5)
				xargv[xargc] = 0;
  d0:	001b879b          	addiw	a5,s7,1
  d4:	078e                	slli	a5,a5,0x3
  d6:	97ba                	add	a5,a5,a4
  d8:	ee07b023          	sd	zero,-288(a5)
				xargc++;
				exec(xargv[0], xargv);
  dc:	e9040593          	addi	a1,s0,-368
  e0:	e9043503          	ld	a0,-368(s0)
  e4:	00000097          	auipc	ra,0x0
  e8:	2cc080e7          	jalr	716(ra) # 3b0 <exec>
				exit(0);
  ec:	4501                	li	a0,0
  ee:	00000097          	auipc	ra,0x0
  f2:	28a080e7          	jalr	650(ra) # 378 <exit>
			}
		}
	}

	wait(0);
  f6:	4501                	li	a0,0
  f8:	00000097          	auipc	ra,0x0
  fc:	288080e7          	jalr	648(ra) # 380 <wait>
	exit(0);
 100:	4501                	li	a0,0
 102:	00000097          	auipc	ra,0x0
 106:	276080e7          	jalr	630(ra) # 378 <exit>

000000000000010a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 110:	87aa                	mv	a5,a0
 112:	0585                	addi	a1,a1,1
 114:	0785                	addi	a5,a5,1
 116:	fff5c703          	lbu	a4,-1(a1)
 11a:	fee78fa3          	sb	a4,-1(a5)
 11e:	fb75                	bnez	a4,112 <strcpy+0x8>
    ;
  return os;
}
 120:	6422                	ld	s0,8(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12c:	00054783          	lbu	a5,0(a0)
 130:	cb91                	beqz	a5,144 <strcmp+0x1e>
 132:	0005c703          	lbu	a4,0(a1)
 136:	00f71763          	bne	a4,a5,144 <strcmp+0x1e>
    p++, q++;
 13a:	0505                	addi	a0,a0,1
 13c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 13e:	00054783          	lbu	a5,0(a0)
 142:	fbe5                	bnez	a5,132 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 144:	0005c503          	lbu	a0,0(a1)
}
 148:	40a7853b          	subw	a0,a5,a0
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret

0000000000000152 <strlen>:

uint
strlen(const char *s)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cf91                	beqz	a5,178 <strlen+0x26>
 15e:	0505                	addi	a0,a0,1
 160:	87aa                	mv	a5,a0
 162:	4685                	li	a3,1
 164:	9e89                	subw	a3,a3,a0
 166:	00f6853b          	addw	a0,a3,a5
 16a:	0785                	addi	a5,a5,1
 16c:	fff7c703          	lbu	a4,-1(a5)
 170:	fb7d                	bnez	a4,166 <strlen+0x14>
    ;
  return n;
}
 172:	6422                	ld	s0,8(sp)
 174:	0141                	addi	sp,sp,16
 176:	8082                	ret
  for(n = 0; s[n]; n++)
 178:	4501                	li	a0,0
 17a:	bfe5                	j	172 <strlen+0x20>

000000000000017c <memset>:

void*
memset(void *dst, int c, uint n)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 182:	ca19                	beqz	a2,198 <memset+0x1c>
 184:	87aa                	mv	a5,a0
 186:	1602                	slli	a2,a2,0x20
 188:	9201                	srli	a2,a2,0x20
 18a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 18e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 192:	0785                	addi	a5,a5,1
 194:	fee79de3          	bne	a5,a4,18e <memset+0x12>
  }
  return dst;
}
 198:	6422                	ld	s0,8(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret

000000000000019e <strchr>:

char*
strchr(const char *s, char c)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	cb99                	beqz	a5,1be <strchr+0x20>
    if(*s == c)
 1aa:	00f58763          	beq	a1,a5,1b8 <strchr+0x1a>
  for(; *s; s++)
 1ae:	0505                	addi	a0,a0,1
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	fbfd                	bnez	a5,1aa <strchr+0xc>
      return (char*)s;
  return 0;
 1b6:	4501                	li	a0,0
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  return 0;
 1be:	4501                	li	a0,0
 1c0:	bfe5                	j	1b8 <strchr+0x1a>

00000000000001c2 <gets>:

char*
gets(char *buf, int max)
{
 1c2:	711d                	addi	sp,sp,-96
 1c4:	ec86                	sd	ra,88(sp)
 1c6:	e8a2                	sd	s0,80(sp)
 1c8:	e4a6                	sd	s1,72(sp)
 1ca:	e0ca                	sd	s2,64(sp)
 1cc:	fc4e                	sd	s3,56(sp)
 1ce:	f852                	sd	s4,48(sp)
 1d0:	f456                	sd	s5,40(sp)
 1d2:	f05a                	sd	s6,32(sp)
 1d4:	ec5e                	sd	s7,24(sp)
 1d6:	1080                	addi	s0,sp,96
 1d8:	8baa                	mv	s7,a0
 1da:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1dc:	892a                	mv	s2,a0
 1de:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e0:	4aa9                	li	s5,10
 1e2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1e4:	89a6                	mv	s3,s1
 1e6:	2485                	addiw	s1,s1,1
 1e8:	0344d863          	bge	s1,s4,218 <gets+0x56>
    cc = read(0, &c, 1);
 1ec:	4605                	li	a2,1
 1ee:	faf40593          	addi	a1,s0,-81
 1f2:	4501                	li	a0,0
 1f4:	00000097          	auipc	ra,0x0
 1f8:	19c080e7          	jalr	412(ra) # 390 <read>
    if(cc < 1)
 1fc:	00a05e63          	blez	a0,218 <gets+0x56>
    buf[i++] = c;
 200:	faf44783          	lbu	a5,-81(s0)
 204:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 208:	01578763          	beq	a5,s5,216 <gets+0x54>
 20c:	0905                	addi	s2,s2,1
 20e:	fd679be3          	bne	a5,s6,1e4 <gets+0x22>
  for(i=0; i+1 < max; ){
 212:	89a6                	mv	s3,s1
 214:	a011                	j	218 <gets+0x56>
 216:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 218:	99de                	add	s3,s3,s7
 21a:	00098023          	sb	zero,0(s3)
  return buf;
}
 21e:	855e                	mv	a0,s7
 220:	60e6                	ld	ra,88(sp)
 222:	6446                	ld	s0,80(sp)
 224:	64a6                	ld	s1,72(sp)
 226:	6906                	ld	s2,64(sp)
 228:	79e2                	ld	s3,56(sp)
 22a:	7a42                	ld	s4,48(sp)
 22c:	7aa2                	ld	s5,40(sp)
 22e:	7b02                	ld	s6,32(sp)
 230:	6be2                	ld	s7,24(sp)
 232:	6125                	addi	sp,sp,96
 234:	8082                	ret

0000000000000236 <stat>:

int
stat(const char *n, struct stat *st)
{
 236:	1101                	addi	sp,sp,-32
 238:	ec06                	sd	ra,24(sp)
 23a:	e822                	sd	s0,16(sp)
 23c:	e426                	sd	s1,8(sp)
 23e:	e04a                	sd	s2,0(sp)
 240:	1000                	addi	s0,sp,32
 242:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 244:	4581                	li	a1,0
 246:	00000097          	auipc	ra,0x0
 24a:	172080e7          	jalr	370(ra) # 3b8 <open>
  if(fd < 0)
 24e:	02054563          	bltz	a0,278 <stat+0x42>
 252:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 254:	85ca                	mv	a1,s2
 256:	00000097          	auipc	ra,0x0
 25a:	17a080e7          	jalr	378(ra) # 3d0 <fstat>
 25e:	892a                	mv	s2,a0
  close(fd);
 260:	8526                	mv	a0,s1
 262:	00000097          	auipc	ra,0x0
 266:	13e080e7          	jalr	318(ra) # 3a0 <close>
  return r;
}
 26a:	854a                	mv	a0,s2
 26c:	60e2                	ld	ra,24(sp)
 26e:	6442                	ld	s0,16(sp)
 270:	64a2                	ld	s1,8(sp)
 272:	6902                	ld	s2,0(sp)
 274:	6105                	addi	sp,sp,32
 276:	8082                	ret
    return -1;
 278:	597d                	li	s2,-1
 27a:	bfc5                	j	26a <stat+0x34>

000000000000027c <atoi>:

int
atoi(const char *s)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 282:	00054603          	lbu	a2,0(a0)
 286:	fd06079b          	addiw	a5,a2,-48
 28a:	0ff7f793          	andi	a5,a5,255
 28e:	4725                	li	a4,9
 290:	02f76963          	bltu	a4,a5,2c2 <atoi+0x46>
 294:	86aa                	mv	a3,a0
  n = 0;
 296:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 298:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 29a:	0685                	addi	a3,a3,1
 29c:	0025179b          	slliw	a5,a0,0x2
 2a0:	9fa9                	addw	a5,a5,a0
 2a2:	0017979b          	slliw	a5,a5,0x1
 2a6:	9fb1                	addw	a5,a5,a2
 2a8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ac:	0006c603          	lbu	a2,0(a3)
 2b0:	fd06071b          	addiw	a4,a2,-48
 2b4:	0ff77713          	andi	a4,a4,255
 2b8:	fee5f1e3          	bgeu	a1,a4,29a <atoi+0x1e>
  return n;
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
  n = 0;
 2c2:	4501                	li	a0,0
 2c4:	bfe5                	j	2bc <atoi+0x40>

00000000000002c6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2cc:	02b57463          	bgeu	a0,a1,2f4 <memmove+0x2e>
    while(n-- > 0)
 2d0:	00c05f63          	blez	a2,2ee <memmove+0x28>
 2d4:	1602                	slli	a2,a2,0x20
 2d6:	9201                	srli	a2,a2,0x20
 2d8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2dc:	872a                	mv	a4,a0
      *dst++ = *src++;
 2de:	0585                	addi	a1,a1,1
 2e0:	0705                	addi	a4,a4,1
 2e2:	fff5c683          	lbu	a3,-1(a1)
 2e6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ea:	fee79ae3          	bne	a5,a4,2de <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ee:	6422                	ld	s0,8(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret
    dst += n;
 2f4:	00c50733          	add	a4,a0,a2
    src += n;
 2f8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2fa:	fec05ae3          	blez	a2,2ee <memmove+0x28>
 2fe:	fff6079b          	addiw	a5,a2,-1
 302:	1782                	slli	a5,a5,0x20
 304:	9381                	srli	a5,a5,0x20
 306:	fff7c793          	not	a5,a5
 30a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 30c:	15fd                	addi	a1,a1,-1
 30e:	177d                	addi	a4,a4,-1
 310:	0005c683          	lbu	a3,0(a1)
 314:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 318:	fee79ae3          	bne	a5,a4,30c <memmove+0x46>
 31c:	bfc9                	j	2ee <memmove+0x28>

000000000000031e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 31e:	1141                	addi	sp,sp,-16
 320:	e422                	sd	s0,8(sp)
 322:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 324:	ca05                	beqz	a2,354 <memcmp+0x36>
 326:	fff6069b          	addiw	a3,a2,-1
 32a:	1682                	slli	a3,a3,0x20
 32c:	9281                	srli	a3,a3,0x20
 32e:	0685                	addi	a3,a3,1
 330:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 332:	00054783          	lbu	a5,0(a0)
 336:	0005c703          	lbu	a4,0(a1)
 33a:	00e79863          	bne	a5,a4,34a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 33e:	0505                	addi	a0,a0,1
    p2++;
 340:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 342:	fed518e3          	bne	a0,a3,332 <memcmp+0x14>
  }
  return 0;
 346:	4501                	li	a0,0
 348:	a019                	j	34e <memcmp+0x30>
      return *p1 - *p2;
 34a:	40e7853b          	subw	a0,a5,a4
}
 34e:	6422                	ld	s0,8(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret
  return 0;
 354:	4501                	li	a0,0
 356:	bfe5                	j	34e <memcmp+0x30>

0000000000000358 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 358:	1141                	addi	sp,sp,-16
 35a:	e406                	sd	ra,8(sp)
 35c:	e022                	sd	s0,0(sp)
 35e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 360:	00000097          	auipc	ra,0x0
 364:	f66080e7          	jalr	-154(ra) # 2c6 <memmove>
}
 368:	60a2                	ld	ra,8(sp)
 36a:	6402                	ld	s0,0(sp)
 36c:	0141                	addi	sp,sp,16
 36e:	8082                	ret

0000000000000370 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 370:	4885                	li	a7,1
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <exit>:
.global exit
exit:
 li a7, SYS_exit
 378:	4889                	li	a7,2
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <wait>:
.global wait
wait:
 li a7, SYS_wait
 380:	488d                	li	a7,3
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 388:	4891                	li	a7,4
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <read>:
.global read
read:
 li a7, SYS_read
 390:	4895                	li	a7,5
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <write>:
.global write
write:
 li a7, SYS_write
 398:	48c1                	li	a7,16
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <close>:
.global close
close:
 li a7, SYS_close
 3a0:	48d5                	li	a7,21
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3a8:	4899                	li	a7,6
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b0:	489d                	li	a7,7
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <open>:
.global open
open:
 li a7, SYS_open
 3b8:	48bd                	li	a7,15
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c0:	48c5                	li	a7,17
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3c8:	48c9                	li	a7,18
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d0:	48a1                	li	a7,8
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <link>:
.global link
link:
 li a7, SYS_link
 3d8:	48cd                	li	a7,19
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e0:	48d1                	li	a7,20
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3e8:	48a5                	li	a7,9
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f0:	48a9                	li	a7,10
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3f8:	48ad                	li	a7,11
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 400:	48b1                	li	a7,12
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 408:	48b5                	li	a7,13
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 410:	48b9                	li	a7,14
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <trace>:
.global trace
trace:
 li a7, SYS_trace
 418:	48d9                	li	a7,22
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 420:	48dd                	li	a7,23
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 428:	1101                	addi	sp,sp,-32
 42a:	ec06                	sd	ra,24(sp)
 42c:	e822                	sd	s0,16(sp)
 42e:	1000                	addi	s0,sp,32
 430:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 434:	4605                	li	a2,1
 436:	fef40593          	addi	a1,s0,-17
 43a:	00000097          	auipc	ra,0x0
 43e:	f5e080e7          	jalr	-162(ra) # 398 <write>
}
 442:	60e2                	ld	ra,24(sp)
 444:	6442                	ld	s0,16(sp)
 446:	6105                	addi	sp,sp,32
 448:	8082                	ret

000000000000044a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 44a:	7139                	addi	sp,sp,-64
 44c:	fc06                	sd	ra,56(sp)
 44e:	f822                	sd	s0,48(sp)
 450:	f426                	sd	s1,40(sp)
 452:	f04a                	sd	s2,32(sp)
 454:	ec4e                	sd	s3,24(sp)
 456:	0080                	addi	s0,sp,64
 458:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 45a:	c299                	beqz	a3,460 <printint+0x16>
 45c:	0805c863          	bltz	a1,4ec <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 460:	2581                	sext.w	a1,a1
  neg = 0;
 462:	4881                	li	a7,0
 464:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 468:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 46a:	2601                	sext.w	a2,a2
 46c:	00000517          	auipc	a0,0x0
 470:	44c50513          	addi	a0,a0,1100 # 8b8 <digits>
 474:	883a                	mv	a6,a4
 476:	2705                	addiw	a4,a4,1
 478:	02c5f7bb          	remuw	a5,a1,a2
 47c:	1782                	slli	a5,a5,0x20
 47e:	9381                	srli	a5,a5,0x20
 480:	97aa                	add	a5,a5,a0
 482:	0007c783          	lbu	a5,0(a5)
 486:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 48a:	0005879b          	sext.w	a5,a1
 48e:	02c5d5bb          	divuw	a1,a1,a2
 492:	0685                	addi	a3,a3,1
 494:	fec7f0e3          	bgeu	a5,a2,474 <printint+0x2a>
  if(neg)
 498:	00088b63          	beqz	a7,4ae <printint+0x64>
    buf[i++] = '-';
 49c:	fd040793          	addi	a5,s0,-48
 4a0:	973e                	add	a4,a4,a5
 4a2:	02d00793          	li	a5,45
 4a6:	fef70823          	sb	a5,-16(a4)
 4aa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ae:	02e05863          	blez	a4,4de <printint+0x94>
 4b2:	fc040793          	addi	a5,s0,-64
 4b6:	00e78933          	add	s2,a5,a4
 4ba:	fff78993          	addi	s3,a5,-1
 4be:	99ba                	add	s3,s3,a4
 4c0:	377d                	addiw	a4,a4,-1
 4c2:	1702                	slli	a4,a4,0x20
 4c4:	9301                	srli	a4,a4,0x20
 4c6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ca:	fff94583          	lbu	a1,-1(s2)
 4ce:	8526                	mv	a0,s1
 4d0:	00000097          	auipc	ra,0x0
 4d4:	f58080e7          	jalr	-168(ra) # 428 <putc>
  while(--i >= 0)
 4d8:	197d                	addi	s2,s2,-1
 4da:	ff3918e3          	bne	s2,s3,4ca <printint+0x80>
}
 4de:	70e2                	ld	ra,56(sp)
 4e0:	7442                	ld	s0,48(sp)
 4e2:	74a2                	ld	s1,40(sp)
 4e4:	7902                	ld	s2,32(sp)
 4e6:	69e2                	ld	s3,24(sp)
 4e8:	6121                	addi	sp,sp,64
 4ea:	8082                	ret
    x = -xx;
 4ec:	40b005bb          	negw	a1,a1
    neg = 1;
 4f0:	4885                	li	a7,1
    x = -xx;
 4f2:	bf8d                	j	464 <printint+0x1a>

00000000000004f4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f4:	7119                	addi	sp,sp,-128
 4f6:	fc86                	sd	ra,120(sp)
 4f8:	f8a2                	sd	s0,112(sp)
 4fa:	f4a6                	sd	s1,104(sp)
 4fc:	f0ca                	sd	s2,96(sp)
 4fe:	ecce                	sd	s3,88(sp)
 500:	e8d2                	sd	s4,80(sp)
 502:	e4d6                	sd	s5,72(sp)
 504:	e0da                	sd	s6,64(sp)
 506:	fc5e                	sd	s7,56(sp)
 508:	f862                	sd	s8,48(sp)
 50a:	f466                	sd	s9,40(sp)
 50c:	f06a                	sd	s10,32(sp)
 50e:	ec6e                	sd	s11,24(sp)
 510:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 512:	0005c903          	lbu	s2,0(a1)
 516:	18090f63          	beqz	s2,6b4 <vprintf+0x1c0>
 51a:	8aaa                	mv	s5,a0
 51c:	8b32                	mv	s6,a2
 51e:	00158493          	addi	s1,a1,1
  state = 0;
 522:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 524:	02500a13          	li	s4,37
      if(c == 'd'){
 528:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 52c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 530:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 534:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 538:	00000b97          	auipc	s7,0x0
 53c:	380b8b93          	addi	s7,s7,896 # 8b8 <digits>
 540:	a839                	j	55e <vprintf+0x6a>
        putc(fd, c);
 542:	85ca                	mv	a1,s2
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	ee2080e7          	jalr	-286(ra) # 428 <putc>
 54e:	a019                	j	554 <vprintf+0x60>
    } else if(state == '%'){
 550:	01498f63          	beq	s3,s4,56e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 554:	0485                	addi	s1,s1,1
 556:	fff4c903          	lbu	s2,-1(s1)
 55a:	14090d63          	beqz	s2,6b4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 55e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 562:	fe0997e3          	bnez	s3,550 <vprintf+0x5c>
      if(c == '%'){
 566:	fd479ee3          	bne	a5,s4,542 <vprintf+0x4e>
        state = '%';
 56a:	89be                	mv	s3,a5
 56c:	b7e5                	j	554 <vprintf+0x60>
      if(c == 'd'){
 56e:	05878063          	beq	a5,s8,5ae <vprintf+0xba>
      } else if(c == 'l') {
 572:	05978c63          	beq	a5,s9,5ca <vprintf+0xd6>
      } else if(c == 'x') {
 576:	07a78863          	beq	a5,s10,5e6 <vprintf+0xf2>
      } else if(c == 'p') {
 57a:	09b78463          	beq	a5,s11,602 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 57e:	07300713          	li	a4,115
 582:	0ce78663          	beq	a5,a4,64e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 586:	06300713          	li	a4,99
 58a:	0ee78e63          	beq	a5,a4,686 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 58e:	11478863          	beq	a5,s4,69e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 592:	85d2                	mv	a1,s4
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	e92080e7          	jalr	-366(ra) # 428 <putc>
        putc(fd, c);
 59e:	85ca                	mv	a1,s2
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e86080e7          	jalr	-378(ra) # 428 <putc>
      }
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	b765                	j	554 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5ae:	008b0913          	addi	s2,s6,8
 5b2:	4685                	li	a3,1
 5b4:	4629                	li	a2,10
 5b6:	000b2583          	lw	a1,0(s6)
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	e8e080e7          	jalr	-370(ra) # 44a <printint>
 5c4:	8b4a                	mv	s6,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	b771                	j	554 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ca:	008b0913          	addi	s2,s6,8
 5ce:	4681                	li	a3,0
 5d0:	4629                	li	a2,10
 5d2:	000b2583          	lw	a1,0(s6)
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e72080e7          	jalr	-398(ra) # 44a <printint>
 5e0:	8b4a                	mv	s6,s2
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	bf85                	j	554 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5e6:	008b0913          	addi	s2,s6,8
 5ea:	4681                	li	a3,0
 5ec:	4641                	li	a2,16
 5ee:	000b2583          	lw	a1,0(s6)
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e56080e7          	jalr	-426(ra) # 44a <printint>
 5fc:	8b4a                	mv	s6,s2
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bf91                	j	554 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 602:	008b0793          	addi	a5,s6,8
 606:	f8f43423          	sd	a5,-120(s0)
 60a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 60e:	03000593          	li	a1,48
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	e14080e7          	jalr	-492(ra) # 428 <putc>
  putc(fd, 'x');
 61c:	85ea                	mv	a1,s10
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	e08080e7          	jalr	-504(ra) # 428 <putc>
 628:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 62a:	03c9d793          	srli	a5,s3,0x3c
 62e:	97de                	add	a5,a5,s7
 630:	0007c583          	lbu	a1,0(a5)
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	df2080e7          	jalr	-526(ra) # 428 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 63e:	0992                	slli	s3,s3,0x4
 640:	397d                	addiw	s2,s2,-1
 642:	fe0914e3          	bnez	s2,62a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 646:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 64a:	4981                	li	s3,0
 64c:	b721                	j	554 <vprintf+0x60>
        s = va_arg(ap, char*);
 64e:	008b0993          	addi	s3,s6,8
 652:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 656:	02090163          	beqz	s2,678 <vprintf+0x184>
        while(*s != 0){
 65a:	00094583          	lbu	a1,0(s2)
 65e:	c9a1                	beqz	a1,6ae <vprintf+0x1ba>
          putc(fd, *s);
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	dc6080e7          	jalr	-570(ra) # 428 <putc>
          s++;
 66a:	0905                	addi	s2,s2,1
        while(*s != 0){
 66c:	00094583          	lbu	a1,0(s2)
 670:	f9e5                	bnez	a1,660 <vprintf+0x16c>
        s = va_arg(ap, char*);
 672:	8b4e                	mv	s6,s3
      state = 0;
 674:	4981                	li	s3,0
 676:	bdf9                	j	554 <vprintf+0x60>
          s = "(null)";
 678:	00000917          	auipc	s2,0x0
 67c:	23890913          	addi	s2,s2,568 # 8b0 <malloc+0xf2>
        while(*s != 0){
 680:	02800593          	li	a1,40
 684:	bff1                	j	660 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 686:	008b0913          	addi	s2,s6,8
 68a:	000b4583          	lbu	a1,0(s6)
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	d98080e7          	jalr	-616(ra) # 428 <putc>
 698:	8b4a                	mv	s6,s2
      state = 0;
 69a:	4981                	li	s3,0
 69c:	bd65                	j	554 <vprintf+0x60>
        putc(fd, c);
 69e:	85d2                	mv	a1,s4
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	d86080e7          	jalr	-634(ra) # 428 <putc>
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b565                	j	554 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ae:	8b4e                	mv	s6,s3
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b54d                	j	554 <vprintf+0x60>
    }
  }
}
 6b4:	70e6                	ld	ra,120(sp)
 6b6:	7446                	ld	s0,112(sp)
 6b8:	74a6                	ld	s1,104(sp)
 6ba:	7906                	ld	s2,96(sp)
 6bc:	69e6                	ld	s3,88(sp)
 6be:	6a46                	ld	s4,80(sp)
 6c0:	6aa6                	ld	s5,72(sp)
 6c2:	6b06                	ld	s6,64(sp)
 6c4:	7be2                	ld	s7,56(sp)
 6c6:	7c42                	ld	s8,48(sp)
 6c8:	7ca2                	ld	s9,40(sp)
 6ca:	7d02                	ld	s10,32(sp)
 6cc:	6de2                	ld	s11,24(sp)
 6ce:	6109                	addi	sp,sp,128
 6d0:	8082                	ret

00000000000006d2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d2:	715d                	addi	sp,sp,-80
 6d4:	ec06                	sd	ra,24(sp)
 6d6:	e822                	sd	s0,16(sp)
 6d8:	1000                	addi	s0,sp,32
 6da:	e010                	sd	a2,0(s0)
 6dc:	e414                	sd	a3,8(s0)
 6de:	e818                	sd	a4,16(s0)
 6e0:	ec1c                	sd	a5,24(s0)
 6e2:	03043023          	sd	a6,32(s0)
 6e6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ee:	8622                	mv	a2,s0
 6f0:	00000097          	auipc	ra,0x0
 6f4:	e04080e7          	jalr	-508(ra) # 4f4 <vprintf>
}
 6f8:	60e2                	ld	ra,24(sp)
 6fa:	6442                	ld	s0,16(sp)
 6fc:	6161                	addi	sp,sp,80
 6fe:	8082                	ret

0000000000000700 <printf>:

void
printf(const char *fmt, ...)
{
 700:	711d                	addi	sp,sp,-96
 702:	ec06                	sd	ra,24(sp)
 704:	e822                	sd	s0,16(sp)
 706:	1000                	addi	s0,sp,32
 708:	e40c                	sd	a1,8(s0)
 70a:	e810                	sd	a2,16(s0)
 70c:	ec14                	sd	a3,24(s0)
 70e:	f018                	sd	a4,32(s0)
 710:	f41c                	sd	a5,40(s0)
 712:	03043823          	sd	a6,48(s0)
 716:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 71a:	00840613          	addi	a2,s0,8
 71e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 722:	85aa                	mv	a1,a0
 724:	4505                	li	a0,1
 726:	00000097          	auipc	ra,0x0
 72a:	dce080e7          	jalr	-562(ra) # 4f4 <vprintf>
}
 72e:	60e2                	ld	ra,24(sp)
 730:	6442                	ld	s0,16(sp)
 732:	6125                	addi	sp,sp,96
 734:	8082                	ret

0000000000000736 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 736:	1141                	addi	sp,sp,-16
 738:	e422                	sd	s0,8(sp)
 73a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 73c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 740:	00000797          	auipc	a5,0x0
 744:	1907b783          	ld	a5,400(a5) # 8d0 <freep>
 748:	a805                	j	778 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 74a:	4618                	lw	a4,8(a2)
 74c:	9db9                	addw	a1,a1,a4
 74e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 752:	6398                	ld	a4,0(a5)
 754:	6318                	ld	a4,0(a4)
 756:	fee53823          	sd	a4,-16(a0)
 75a:	a091                	j	79e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 75c:	ff852703          	lw	a4,-8(a0)
 760:	9e39                	addw	a2,a2,a4
 762:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 764:	ff053703          	ld	a4,-16(a0)
 768:	e398                	sd	a4,0(a5)
 76a:	a099                	j	7b0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 76c:	6398                	ld	a4,0(a5)
 76e:	00e7e463          	bltu	a5,a4,776 <free+0x40>
 772:	00e6ea63          	bltu	a3,a4,786 <free+0x50>
{
 776:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 778:	fed7fae3          	bgeu	a5,a3,76c <free+0x36>
 77c:	6398                	ld	a4,0(a5)
 77e:	00e6e463          	bltu	a3,a4,786 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 782:	fee7eae3          	bltu	a5,a4,776 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 786:	ff852583          	lw	a1,-8(a0)
 78a:	6390                	ld	a2,0(a5)
 78c:	02059713          	slli	a4,a1,0x20
 790:	9301                	srli	a4,a4,0x20
 792:	0712                	slli	a4,a4,0x4
 794:	9736                	add	a4,a4,a3
 796:	fae60ae3          	beq	a2,a4,74a <free+0x14>
    bp->s.ptr = p->s.ptr;
 79a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 79e:	4790                	lw	a2,8(a5)
 7a0:	02061713          	slli	a4,a2,0x20
 7a4:	9301                	srli	a4,a4,0x20
 7a6:	0712                	slli	a4,a4,0x4
 7a8:	973e                	add	a4,a4,a5
 7aa:	fae689e3          	beq	a3,a4,75c <free+0x26>
  } else
    p->s.ptr = bp;
 7ae:	e394                	sd	a3,0(a5)
  freep = p;
 7b0:	00000717          	auipc	a4,0x0
 7b4:	12f73023          	sd	a5,288(a4) # 8d0 <freep>
}
 7b8:	6422                	ld	s0,8(sp)
 7ba:	0141                	addi	sp,sp,16
 7bc:	8082                	ret

00000000000007be <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7be:	7139                	addi	sp,sp,-64
 7c0:	fc06                	sd	ra,56(sp)
 7c2:	f822                	sd	s0,48(sp)
 7c4:	f426                	sd	s1,40(sp)
 7c6:	f04a                	sd	s2,32(sp)
 7c8:	ec4e                	sd	s3,24(sp)
 7ca:	e852                	sd	s4,16(sp)
 7cc:	e456                	sd	s5,8(sp)
 7ce:	e05a                	sd	s6,0(sp)
 7d0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d2:	02051493          	slli	s1,a0,0x20
 7d6:	9081                	srli	s1,s1,0x20
 7d8:	04bd                	addi	s1,s1,15
 7da:	8091                	srli	s1,s1,0x4
 7dc:	0014899b          	addiw	s3,s1,1
 7e0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7e2:	00000517          	auipc	a0,0x0
 7e6:	0ee53503          	ld	a0,238(a0) # 8d0 <freep>
 7ea:	c515                	beqz	a0,816 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ee:	4798                	lw	a4,8(a5)
 7f0:	02977f63          	bgeu	a4,s1,82e <malloc+0x70>
 7f4:	8a4e                	mv	s4,s3
 7f6:	0009871b          	sext.w	a4,s3
 7fa:	6685                	lui	a3,0x1
 7fc:	00d77363          	bgeu	a4,a3,802 <malloc+0x44>
 800:	6a05                	lui	s4,0x1
 802:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 806:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 80a:	00000917          	auipc	s2,0x0
 80e:	0c690913          	addi	s2,s2,198 # 8d0 <freep>
  if(p == (char*)-1)
 812:	5afd                	li	s5,-1
 814:	a88d                	j	886 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 816:	00000797          	auipc	a5,0x0
 81a:	0c278793          	addi	a5,a5,194 # 8d8 <base>
 81e:	00000717          	auipc	a4,0x0
 822:	0af73923          	sd	a5,178(a4) # 8d0 <freep>
 826:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 828:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 82c:	b7e1                	j	7f4 <malloc+0x36>
      if(p->s.size == nunits)
 82e:	02e48b63          	beq	s1,a4,864 <malloc+0xa6>
        p->s.size -= nunits;
 832:	4137073b          	subw	a4,a4,s3
 836:	c798                	sw	a4,8(a5)
        p += p->s.size;
 838:	1702                	slli	a4,a4,0x20
 83a:	9301                	srli	a4,a4,0x20
 83c:	0712                	slli	a4,a4,0x4
 83e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 840:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 844:	00000717          	auipc	a4,0x0
 848:	08a73623          	sd	a0,140(a4) # 8d0 <freep>
      return (void*)(p + 1);
 84c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 850:	70e2                	ld	ra,56(sp)
 852:	7442                	ld	s0,48(sp)
 854:	74a2                	ld	s1,40(sp)
 856:	7902                	ld	s2,32(sp)
 858:	69e2                	ld	s3,24(sp)
 85a:	6a42                	ld	s4,16(sp)
 85c:	6aa2                	ld	s5,8(sp)
 85e:	6b02                	ld	s6,0(sp)
 860:	6121                	addi	sp,sp,64
 862:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 864:	6398                	ld	a4,0(a5)
 866:	e118                	sd	a4,0(a0)
 868:	bff1                	j	844 <malloc+0x86>
  hp->s.size = nu;
 86a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 86e:	0541                	addi	a0,a0,16
 870:	00000097          	auipc	ra,0x0
 874:	ec6080e7          	jalr	-314(ra) # 736 <free>
  return freep;
 878:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 87c:	d971                	beqz	a0,850 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 880:	4798                	lw	a4,8(a5)
 882:	fa9776e3          	bgeu	a4,s1,82e <malloc+0x70>
    if(p == freep)
 886:	00093703          	ld	a4,0(s2)
 88a:	853e                	mv	a0,a5
 88c:	fef719e3          	bne	a4,a5,87e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 890:	8552                	mv	a0,s4
 892:	00000097          	auipc	ra,0x0
 896:	b6e080e7          	jalr	-1170(ra) # 400 <sbrk>
  if(p == (char*)-1)
 89a:	fd5518e3          	bne	a0,s5,86a <malloc+0xac>
        return 0;
 89e:	4501                	li	a0,0
 8a0:	bf45                	j	850 <malloc+0x92>
