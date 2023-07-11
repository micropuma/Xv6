
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <match>:

void match(const char* path, const char* name){
    //printf("%s %s", path, name);
    int pp = 0;
    int pa = 0;
    while(path[pp] != 0){
   0:	00054783          	lbu	a5,0(a0)
   4:	cbb1                	beqz	a5,58 <match+0x58>
        pa = 0;
        int np = pp;
        while(name[pa] != 0){
   6:	0005c883          	lbu	a7,0(a1)
   a:	882a                	mv	a6,a0
   c:	a031                	j	18 <match+0x18>
                np++;
            }
            else
                break;
        }
        if(name[pa] == 0){
   e:	c785                	beqz	a5,36 <match+0x36>
    while(path[pp] != 0){
  10:	0805                	addi	a6,a6,1
  12:	00084783          	lbu	a5,0(a6)
  16:	c3a9                	beqz	a5,58 <match+0x58>
        while(name[pa] != 0){
  18:	00088f63          	beqz	a7,36 <match+0x36>
  1c:	00158693          	addi	a3,a1,1
  20:	8742                	mv	a4,a6
  22:	87c6                	mv	a5,a7
            if (name[pa] == path[np]){
  24:	00074603          	lbu	a2,0(a4)
  28:	fef613e3          	bne	a2,a5,e <match+0xe>
        while(name[pa] != 0){
  2c:	0006c783          	lbu	a5,0(a3)
  30:	0705                	addi	a4,a4,1
  32:	0685                	addi	a3,a3,1
  34:	fbe5                	bnez	a5,24 <match+0x24>
void match(const char* path, const char* name){
  36:	1141                	addi	sp,sp,-16
  38:	e406                	sd	ra,8(sp)
  3a:	e022                	sd	s0,0(sp)
  3c:	0800                	addi	s0,sp,16
            printf("%s\n", path);
  3e:	85aa                	mv	a1,a0
  40:	00001517          	auipc	a0,0x1
  44:	9c850513          	addi	a0,a0,-1592 # a08 <malloc+0xfa>
  48:	00001097          	auipc	ra,0x1
  4c:	808080e7          	jalr	-2040(ra) # 850 <printf>
            return;
        }
        pp++;
    }
}
  50:	60a2                	ld	ra,8(sp)
  52:	6402                	ld	s0,0(sp)
  54:	0141                	addi	sp,sp,16
  56:	8082                	ret
  58:	8082                	ret

000000000000005a <find>:

void find(char *path, char *name){
  5a:	d8010113          	addi	sp,sp,-640
  5e:	26113c23          	sd	ra,632(sp)
  62:	26813823          	sd	s0,624(sp)
  66:	26913423          	sd	s1,616(sp)
  6a:	27213023          	sd	s2,608(sp)
  6e:	25313c23          	sd	s3,600(sp)
  72:	25413823          	sd	s4,592(sp)
  76:	25513423          	sd	s5,584(sp)
  7a:	25613023          	sd	s6,576(sp)
  7e:	23713c23          	sd	s7,568(sp)
  82:	0500                	addi	s0,sp,640
  84:	892a                	mv	s2,a0
  86:	89ae                	mv	s3,a1
    char buf[512], *p;
    int fd;
    struct dirent de;
    struct stat st;

    if((fd = open(path, 0)) < 0){
  88:	4581                	li	a1,0
  8a:	00000097          	auipc	ra,0x0
  8e:	47e080e7          	jalr	1150(ra) # 508 <open>
  92:	06054563          	bltz	a0,fc <find+0xa2>
  96:	84aa                	mv	s1,a0
        fprintf(2, "ls: cannot open %s\n", path);
        return;
    }
    
    if(fstat(fd, &st) < 0){
  98:	d8840593          	addi	a1,s0,-632
  9c:	00000097          	auipc	ra,0x0
  a0:	484080e7          	jalr	1156(ra) # 520 <fstat>
  a4:	06054763          	bltz	a0,112 <find+0xb8>
        fprintf(2, "ls: cannot stat %s\n", path);
        close(fd);
        return;
    }
    switch(st.type){
  a8:	d9041783          	lh	a5,-624(s0)
  ac:	0007869b          	sext.w	a3,a5
  b0:	4705                	li	a4,1
  b2:	08e68063          	beq	a3,a4,132 <find+0xd8>
  b6:	4709                	li	a4,2
  b8:	00e69863          	bne	a3,a4,c8 <find+0x6e>
        case T_FILE:
            // printf("%s %d %d %l\n", path, st.type, st.ino, st.size);
            match(path, name);
  bc:	85ce                	mv	a1,s3
  be:	854a                	mv	a0,s2
  c0:	00000097          	auipc	ra,0x0
  c4:	f40080e7          	jalr	-192(ra) # 0 <match>
                }
                find(buf, name);
            }
            break;
    }
    close(fd);
  c8:	8526                	mv	a0,s1
  ca:	00000097          	auipc	ra,0x0
  ce:	426080e7          	jalr	1062(ra) # 4f0 <close>
}
  d2:	27813083          	ld	ra,632(sp)
  d6:	27013403          	ld	s0,624(sp)
  da:	26813483          	ld	s1,616(sp)
  de:	26013903          	ld	s2,608(sp)
  e2:	25813983          	ld	s3,600(sp)
  e6:	25013a03          	ld	s4,592(sp)
  ea:	24813a83          	ld	s5,584(sp)
  ee:	24013b03          	ld	s6,576(sp)
  f2:	23813b83          	ld	s7,568(sp)
  f6:	28010113          	addi	sp,sp,640
  fa:	8082                	ret
        fprintf(2, "ls: cannot open %s\n", path);
  fc:	864a                	mv	a2,s2
  fe:	00001597          	auipc	a1,0x1
 102:	8fa58593          	addi	a1,a1,-1798 # 9f8 <malloc+0xea>
 106:	4509                	li	a0,2
 108:	00000097          	auipc	ra,0x0
 10c:	71a080e7          	jalr	1818(ra) # 822 <fprintf>
        return;
 110:	b7c9                	j	d2 <find+0x78>
        fprintf(2, "ls: cannot stat %s\n", path);
 112:	864a                	mv	a2,s2
 114:	00001597          	auipc	a1,0x1
 118:	8fc58593          	addi	a1,a1,-1796 # a10 <malloc+0x102>
 11c:	4509                	li	a0,2
 11e:	00000097          	auipc	ra,0x0
 122:	704080e7          	jalr	1796(ra) # 822 <fprintf>
        close(fd);
 126:	8526                	mv	a0,s1
 128:	00000097          	auipc	ra,0x0
 12c:	3c8080e7          	jalr	968(ra) # 4f0 <close>
        return;
 130:	b74d                	j	d2 <find+0x78>
            if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 132:	854a                	mv	a0,s2
 134:	00000097          	auipc	ra,0x0
 138:	16e080e7          	jalr	366(ra) # 2a2 <strlen>
 13c:	2541                	addiw	a0,a0,16
 13e:	20000793          	li	a5,512
 142:	00a7fb63          	bgeu	a5,a0,158 <find+0xfe>
                printf("ls: path too long\n");
 146:	00001517          	auipc	a0,0x1
 14a:	8e250513          	addi	a0,a0,-1822 # a28 <malloc+0x11a>
 14e:	00000097          	auipc	ra,0x0
 152:	702080e7          	jalr	1794(ra) # 850 <printf>
                break;
 156:	bf8d                	j	c8 <find+0x6e>
            strcpy(buf, path);
 158:	85ca                	mv	a1,s2
 15a:	db040513          	addi	a0,s0,-592
 15e:	00000097          	auipc	ra,0x0
 162:	0fc080e7          	jalr	252(ra) # 25a <strcpy>
            p = buf+strlen(buf);
 166:	db040513          	addi	a0,s0,-592
 16a:	00000097          	auipc	ra,0x0
 16e:	138080e7          	jalr	312(ra) # 2a2 <strlen>
 172:	02051913          	slli	s2,a0,0x20
 176:	02095913          	srli	s2,s2,0x20
 17a:	db040793          	addi	a5,s0,-592
 17e:	993e                	add	s2,s2,a5
            *p++ = '/';
 180:	00190b13          	addi	s6,s2,1
 184:	02f00793          	li	a5,47
 188:	00f90023          	sb	a5,0(s2)
                if(de.name[0] == '.' && de.name[1] == 0) continue;
 18c:	02e00a93          	li	s5,46
                if(de.name[0] == '.' && de.name[1] == '.' && de.name[2] == 0) continue;
 190:	6a0d                	lui	s4,0x3
 192:	e2ea0a13          	addi	s4,s4,-466 # 2e2e <__global_pointer$+0x1bb5>
                    printf("ls: cannot stat %s\n", buf);
 196:	00001b97          	auipc	s7,0x1
 19a:	87ab8b93          	addi	s7,s7,-1926 # a10 <malloc+0x102>
            while(read(fd, &de, sizeof(de)) == sizeof(de)){
 19e:	a825                	j	1d6 <find+0x17c>
                memmove(p, de.name, DIRSIZ);
 1a0:	4639                	li	a2,14
 1a2:	da240593          	addi	a1,s0,-606
 1a6:	855a                	mv	a0,s6
 1a8:	00000097          	auipc	ra,0x0
 1ac:	26e080e7          	jalr	622(ra) # 416 <memmove>
                p[DIRSIZ] = 0;
 1b0:	000907a3          	sb	zero,15(s2)
                if(stat(buf, &st) < 0){
 1b4:	d8840593          	addi	a1,s0,-632
 1b8:	db040513          	addi	a0,s0,-592
 1bc:	00000097          	auipc	ra,0x0
 1c0:	1ca080e7          	jalr	458(ra) # 386 <stat>
 1c4:	04054363          	bltz	a0,20a <find+0x1b0>
                find(buf, name);
 1c8:	85ce                	mv	a1,s3
 1ca:	db040513          	addi	a0,s0,-592
 1ce:	00000097          	auipc	ra,0x0
 1d2:	e8c080e7          	jalr	-372(ra) # 5a <find>
            while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1d6:	4641                	li	a2,16
 1d8:	da040593          	addi	a1,s0,-608
 1dc:	8526                	mv	a0,s1
 1de:	00000097          	auipc	ra,0x0
 1e2:	302080e7          	jalr	770(ra) # 4e0 <read>
 1e6:	47c1                	li	a5,16
 1e8:	eef510e3          	bne	a0,a5,c8 <find+0x6e>
                if(de.inum == 0)
 1ec:	da045783          	lhu	a5,-608(s0)
 1f0:	d3fd                	beqz	a5,1d6 <find+0x17c>
                if(de.name[0] == '.' && de.name[1] == 0) continue;
 1f2:	da245783          	lhu	a5,-606(s0)
 1f6:	0007871b          	sext.w	a4,a5
 1fa:	fd570ee3          	beq	a4,s5,1d6 <find+0x17c>
                if(de.name[0] == '.' && de.name[1] == '.' && de.name[2] == 0) continue;
 1fe:	fb4711e3          	bne	a4,s4,1a0 <find+0x146>
 202:	da444783          	lbu	a5,-604(s0)
 206:	ffc9                	bnez	a5,1a0 <find+0x146>
 208:	b7f9                	j	1d6 <find+0x17c>
                    printf("ls: cannot stat %s\n", buf);
 20a:	db040593          	addi	a1,s0,-592
 20e:	855e                	mv	a0,s7
 210:	00000097          	auipc	ra,0x0
 214:	640080e7          	jalr	1600(ra) # 850 <printf>
                    continue;
 218:	bf7d                	j	1d6 <find+0x17c>

000000000000021a <main>:

int
main(int argc, char *argv[]){
 21a:	1141                	addi	sp,sp,-16
 21c:	e406                	sd	ra,8(sp)
 21e:	e022                	sd	s0,0(sp)
 220:	0800                	addi	s0,sp,16
    if (argc < 3){
 222:	4709                	li	a4,2
 224:	00a74f63          	blt	a4,a0,242 <main+0x28>
        printf("Usage: find [path] [filename]\n");
 228:	00001517          	auipc	a0,0x1
 22c:	81850513          	addi	a0,a0,-2024 # a40 <malloc+0x132>
 230:	00000097          	auipc	ra,0x0
 234:	620080e7          	jalr	1568(ra) # 850 <printf>
        exit(-1);
 238:	557d                	li	a0,-1
 23a:	00000097          	auipc	ra,0x0
 23e:	28e080e7          	jalr	654(ra) # 4c8 <exit>
 242:	87ae                	mv	a5,a1
    }
    find(argv[1], argv[2]);
 244:	698c                	ld	a1,16(a1)
 246:	6788                	ld	a0,8(a5)
 248:	00000097          	auipc	ra,0x0
 24c:	e12080e7          	jalr	-494(ra) # 5a <find>
    exit(0);
 250:	4501                	li	a0,0
 252:	00000097          	auipc	ra,0x0
 256:	276080e7          	jalr	630(ra) # 4c8 <exit>

000000000000025a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 260:	87aa                	mv	a5,a0
 262:	0585                	addi	a1,a1,1
 264:	0785                	addi	a5,a5,1
 266:	fff5c703          	lbu	a4,-1(a1)
 26a:	fee78fa3          	sb	a4,-1(a5)
 26e:	fb75                	bnez	a4,262 <strcpy+0x8>
    ;
  return os;
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret

0000000000000276 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 27c:	00054783          	lbu	a5,0(a0)
 280:	cb91                	beqz	a5,294 <strcmp+0x1e>
 282:	0005c703          	lbu	a4,0(a1)
 286:	00f71763          	bne	a4,a5,294 <strcmp+0x1e>
    p++, q++;
 28a:	0505                	addi	a0,a0,1
 28c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 28e:	00054783          	lbu	a5,0(a0)
 292:	fbe5                	bnez	a5,282 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 294:	0005c503          	lbu	a0,0(a1)
}
 298:	40a7853b          	subw	a0,a5,a0
 29c:	6422                	ld	s0,8(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret

00000000000002a2 <strlen>:

uint
strlen(const char *s)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2a8:	00054783          	lbu	a5,0(a0)
 2ac:	cf91                	beqz	a5,2c8 <strlen+0x26>
 2ae:	0505                	addi	a0,a0,1
 2b0:	87aa                	mv	a5,a0
 2b2:	4685                	li	a3,1
 2b4:	9e89                	subw	a3,a3,a0
 2b6:	00f6853b          	addw	a0,a3,a5
 2ba:	0785                	addi	a5,a5,1
 2bc:	fff7c703          	lbu	a4,-1(a5)
 2c0:	fb7d                	bnez	a4,2b6 <strlen+0x14>
    ;
  return n;
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
  for(n = 0; s[n]; n++)
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <strlen+0x20>

00000000000002cc <memset>:

void*
memset(void *dst, int c, uint n)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2d2:	ca19                	beqz	a2,2e8 <memset+0x1c>
 2d4:	87aa                	mv	a5,a0
 2d6:	1602                	slli	a2,a2,0x20
 2d8:	9201                	srli	a2,a2,0x20
 2da:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2de:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2e2:	0785                	addi	a5,a5,1
 2e4:	fee79de3          	bne	a5,a4,2de <memset+0x12>
  }
  return dst;
}
 2e8:	6422                	ld	s0,8(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret

00000000000002ee <strchr>:

char*
strchr(const char *s, char c)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2f4:	00054783          	lbu	a5,0(a0)
 2f8:	cb99                	beqz	a5,30e <strchr+0x20>
    if(*s == c)
 2fa:	00f58763          	beq	a1,a5,308 <strchr+0x1a>
  for(; *s; s++)
 2fe:	0505                	addi	a0,a0,1
 300:	00054783          	lbu	a5,0(a0)
 304:	fbfd                	bnez	a5,2fa <strchr+0xc>
      return (char*)s;
  return 0;
 306:	4501                	li	a0,0
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret
  return 0;
 30e:	4501                	li	a0,0
 310:	bfe5                	j	308 <strchr+0x1a>

0000000000000312 <gets>:

char*
gets(char *buf, int max)
{
 312:	711d                	addi	sp,sp,-96
 314:	ec86                	sd	ra,88(sp)
 316:	e8a2                	sd	s0,80(sp)
 318:	e4a6                	sd	s1,72(sp)
 31a:	e0ca                	sd	s2,64(sp)
 31c:	fc4e                	sd	s3,56(sp)
 31e:	f852                	sd	s4,48(sp)
 320:	f456                	sd	s5,40(sp)
 322:	f05a                	sd	s6,32(sp)
 324:	ec5e                	sd	s7,24(sp)
 326:	1080                	addi	s0,sp,96
 328:	8baa                	mv	s7,a0
 32a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 32c:	892a                	mv	s2,a0
 32e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 330:	4aa9                	li	s5,10
 332:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 334:	89a6                	mv	s3,s1
 336:	2485                	addiw	s1,s1,1
 338:	0344d863          	bge	s1,s4,368 <gets+0x56>
    cc = read(0, &c, 1);
 33c:	4605                	li	a2,1
 33e:	faf40593          	addi	a1,s0,-81
 342:	4501                	li	a0,0
 344:	00000097          	auipc	ra,0x0
 348:	19c080e7          	jalr	412(ra) # 4e0 <read>
    if(cc < 1)
 34c:	00a05e63          	blez	a0,368 <gets+0x56>
    buf[i++] = c;
 350:	faf44783          	lbu	a5,-81(s0)
 354:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 358:	01578763          	beq	a5,s5,366 <gets+0x54>
 35c:	0905                	addi	s2,s2,1
 35e:	fd679be3          	bne	a5,s6,334 <gets+0x22>
  for(i=0; i+1 < max; ){
 362:	89a6                	mv	s3,s1
 364:	a011                	j	368 <gets+0x56>
 366:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 368:	99de                	add	s3,s3,s7
 36a:	00098023          	sb	zero,0(s3)
  return buf;
}
 36e:	855e                	mv	a0,s7
 370:	60e6                	ld	ra,88(sp)
 372:	6446                	ld	s0,80(sp)
 374:	64a6                	ld	s1,72(sp)
 376:	6906                	ld	s2,64(sp)
 378:	79e2                	ld	s3,56(sp)
 37a:	7a42                	ld	s4,48(sp)
 37c:	7aa2                	ld	s5,40(sp)
 37e:	7b02                	ld	s6,32(sp)
 380:	6be2                	ld	s7,24(sp)
 382:	6125                	addi	sp,sp,96
 384:	8082                	ret

0000000000000386 <stat>:

int
stat(const char *n, struct stat *st)
{
 386:	1101                	addi	sp,sp,-32
 388:	ec06                	sd	ra,24(sp)
 38a:	e822                	sd	s0,16(sp)
 38c:	e426                	sd	s1,8(sp)
 38e:	e04a                	sd	s2,0(sp)
 390:	1000                	addi	s0,sp,32
 392:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 394:	4581                	li	a1,0
 396:	00000097          	auipc	ra,0x0
 39a:	172080e7          	jalr	370(ra) # 508 <open>
  if(fd < 0)
 39e:	02054563          	bltz	a0,3c8 <stat+0x42>
 3a2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a4:	85ca                	mv	a1,s2
 3a6:	00000097          	auipc	ra,0x0
 3aa:	17a080e7          	jalr	378(ra) # 520 <fstat>
 3ae:	892a                	mv	s2,a0
  close(fd);
 3b0:	8526                	mv	a0,s1
 3b2:	00000097          	auipc	ra,0x0
 3b6:	13e080e7          	jalr	318(ra) # 4f0 <close>
  return r;
}
 3ba:	854a                	mv	a0,s2
 3bc:	60e2                	ld	ra,24(sp)
 3be:	6442                	ld	s0,16(sp)
 3c0:	64a2                	ld	s1,8(sp)
 3c2:	6902                	ld	s2,0(sp)
 3c4:	6105                	addi	sp,sp,32
 3c6:	8082                	ret
    return -1;
 3c8:	597d                	li	s2,-1
 3ca:	bfc5                	j	3ba <stat+0x34>

00000000000003cc <atoi>:

int
atoi(const char *s)
{
 3cc:	1141                	addi	sp,sp,-16
 3ce:	e422                	sd	s0,8(sp)
 3d0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3d2:	00054603          	lbu	a2,0(a0)
 3d6:	fd06079b          	addiw	a5,a2,-48
 3da:	0ff7f793          	andi	a5,a5,255
 3de:	4725                	li	a4,9
 3e0:	02f76963          	bltu	a4,a5,412 <atoi+0x46>
 3e4:	86aa                	mv	a3,a0
  n = 0;
 3e6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3e8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3ea:	0685                	addi	a3,a3,1
 3ec:	0025179b          	slliw	a5,a0,0x2
 3f0:	9fa9                	addw	a5,a5,a0
 3f2:	0017979b          	slliw	a5,a5,0x1
 3f6:	9fb1                	addw	a5,a5,a2
 3f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3fc:	0006c603          	lbu	a2,0(a3)
 400:	fd06071b          	addiw	a4,a2,-48
 404:	0ff77713          	andi	a4,a4,255
 408:	fee5f1e3          	bgeu	a1,a4,3ea <atoi+0x1e>
  return n;
}
 40c:	6422                	ld	s0,8(sp)
 40e:	0141                	addi	sp,sp,16
 410:	8082                	ret
  n = 0;
 412:	4501                	li	a0,0
 414:	bfe5                	j	40c <atoi+0x40>

0000000000000416 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 416:	1141                	addi	sp,sp,-16
 418:	e422                	sd	s0,8(sp)
 41a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 41c:	02b57463          	bgeu	a0,a1,444 <memmove+0x2e>
    while(n-- > 0)
 420:	00c05f63          	blez	a2,43e <memmove+0x28>
 424:	1602                	slli	a2,a2,0x20
 426:	9201                	srli	a2,a2,0x20
 428:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 42c:	872a                	mv	a4,a0
      *dst++ = *src++;
 42e:	0585                	addi	a1,a1,1
 430:	0705                	addi	a4,a4,1
 432:	fff5c683          	lbu	a3,-1(a1)
 436:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 43a:	fee79ae3          	bne	a5,a4,42e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 43e:	6422                	ld	s0,8(sp)
 440:	0141                	addi	sp,sp,16
 442:	8082                	ret
    dst += n;
 444:	00c50733          	add	a4,a0,a2
    src += n;
 448:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 44a:	fec05ae3          	blez	a2,43e <memmove+0x28>
 44e:	fff6079b          	addiw	a5,a2,-1
 452:	1782                	slli	a5,a5,0x20
 454:	9381                	srli	a5,a5,0x20
 456:	fff7c793          	not	a5,a5
 45a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 45c:	15fd                	addi	a1,a1,-1
 45e:	177d                	addi	a4,a4,-1
 460:	0005c683          	lbu	a3,0(a1)
 464:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 468:	fee79ae3          	bne	a5,a4,45c <memmove+0x46>
 46c:	bfc9                	j	43e <memmove+0x28>

000000000000046e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 46e:	1141                	addi	sp,sp,-16
 470:	e422                	sd	s0,8(sp)
 472:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 474:	ca05                	beqz	a2,4a4 <memcmp+0x36>
 476:	fff6069b          	addiw	a3,a2,-1
 47a:	1682                	slli	a3,a3,0x20
 47c:	9281                	srli	a3,a3,0x20
 47e:	0685                	addi	a3,a3,1
 480:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 482:	00054783          	lbu	a5,0(a0)
 486:	0005c703          	lbu	a4,0(a1)
 48a:	00e79863          	bne	a5,a4,49a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 48e:	0505                	addi	a0,a0,1
    p2++;
 490:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 492:	fed518e3          	bne	a0,a3,482 <memcmp+0x14>
  }
  return 0;
 496:	4501                	li	a0,0
 498:	a019                	j	49e <memcmp+0x30>
      return *p1 - *p2;
 49a:	40e7853b          	subw	a0,a5,a4
}
 49e:	6422                	ld	s0,8(sp)
 4a0:	0141                	addi	sp,sp,16
 4a2:	8082                	ret
  return 0;
 4a4:	4501                	li	a0,0
 4a6:	bfe5                	j	49e <memcmp+0x30>

00000000000004a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a8:	1141                	addi	sp,sp,-16
 4aa:	e406                	sd	ra,8(sp)
 4ac:	e022                	sd	s0,0(sp)
 4ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4b0:	00000097          	auipc	ra,0x0
 4b4:	f66080e7          	jalr	-154(ra) # 416 <memmove>
}
 4b8:	60a2                	ld	ra,8(sp)
 4ba:	6402                	ld	s0,0(sp)
 4bc:	0141                	addi	sp,sp,16
 4be:	8082                	ret

00000000000004c0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4c0:	4885                	li	a7,1
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4c8:	4889                	li	a7,2
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4d0:	488d                	li	a7,3
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4d8:	4891                	li	a7,4
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <read>:
.global read
read:
 li a7, SYS_read
 4e0:	4895                	li	a7,5
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <write>:
.global write
write:
 li a7, SYS_write
 4e8:	48c1                	li	a7,16
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <close>:
.global close
close:
 li a7, SYS_close
 4f0:	48d5                	li	a7,21
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4f8:	4899                	li	a7,6
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <exec>:
.global exec
exec:
 li a7, SYS_exec
 500:	489d                	li	a7,7
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <open>:
.global open
open:
 li a7, SYS_open
 508:	48bd                	li	a7,15
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 510:	48c5                	li	a7,17
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 518:	48c9                	li	a7,18
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 520:	48a1                	li	a7,8
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <link>:
.global link
link:
 li a7, SYS_link
 528:	48cd                	li	a7,19
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 530:	48d1                	li	a7,20
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 538:	48a5                	li	a7,9
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <dup>:
.global dup
dup:
 li a7, SYS_dup
 540:	48a9                	li	a7,10
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 548:	48ad                	li	a7,11
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 550:	48b1                	li	a7,12
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 558:	48b5                	li	a7,13
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 560:	48b9                	li	a7,14
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <trace>:
.global trace
trace:
 li a7, SYS_trace
 568:	48d9                	li	a7,22
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 570:	48dd                	li	a7,23
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 578:	1101                	addi	sp,sp,-32
 57a:	ec06                	sd	ra,24(sp)
 57c:	e822                	sd	s0,16(sp)
 57e:	1000                	addi	s0,sp,32
 580:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 584:	4605                	li	a2,1
 586:	fef40593          	addi	a1,s0,-17
 58a:	00000097          	auipc	ra,0x0
 58e:	f5e080e7          	jalr	-162(ra) # 4e8 <write>
}
 592:	60e2                	ld	ra,24(sp)
 594:	6442                	ld	s0,16(sp)
 596:	6105                	addi	sp,sp,32
 598:	8082                	ret

000000000000059a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 59a:	7139                	addi	sp,sp,-64
 59c:	fc06                	sd	ra,56(sp)
 59e:	f822                	sd	s0,48(sp)
 5a0:	f426                	sd	s1,40(sp)
 5a2:	f04a                	sd	s2,32(sp)
 5a4:	ec4e                	sd	s3,24(sp)
 5a6:	0080                	addi	s0,sp,64
 5a8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5aa:	c299                	beqz	a3,5b0 <printint+0x16>
 5ac:	0805c863          	bltz	a1,63c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5b0:	2581                	sext.w	a1,a1
  neg = 0;
 5b2:	4881                	li	a7,0
 5b4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5b8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5ba:	2601                	sext.w	a2,a2
 5bc:	00000517          	auipc	a0,0x0
 5c0:	4ac50513          	addi	a0,a0,1196 # a68 <digits>
 5c4:	883a                	mv	a6,a4
 5c6:	2705                	addiw	a4,a4,1
 5c8:	02c5f7bb          	remuw	a5,a1,a2
 5cc:	1782                	slli	a5,a5,0x20
 5ce:	9381                	srli	a5,a5,0x20
 5d0:	97aa                	add	a5,a5,a0
 5d2:	0007c783          	lbu	a5,0(a5)
 5d6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5da:	0005879b          	sext.w	a5,a1
 5de:	02c5d5bb          	divuw	a1,a1,a2
 5e2:	0685                	addi	a3,a3,1
 5e4:	fec7f0e3          	bgeu	a5,a2,5c4 <printint+0x2a>
  if(neg)
 5e8:	00088b63          	beqz	a7,5fe <printint+0x64>
    buf[i++] = '-';
 5ec:	fd040793          	addi	a5,s0,-48
 5f0:	973e                	add	a4,a4,a5
 5f2:	02d00793          	li	a5,45
 5f6:	fef70823          	sb	a5,-16(a4)
 5fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5fe:	02e05863          	blez	a4,62e <printint+0x94>
 602:	fc040793          	addi	a5,s0,-64
 606:	00e78933          	add	s2,a5,a4
 60a:	fff78993          	addi	s3,a5,-1
 60e:	99ba                	add	s3,s3,a4
 610:	377d                	addiw	a4,a4,-1
 612:	1702                	slli	a4,a4,0x20
 614:	9301                	srli	a4,a4,0x20
 616:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 61a:	fff94583          	lbu	a1,-1(s2)
 61e:	8526                	mv	a0,s1
 620:	00000097          	auipc	ra,0x0
 624:	f58080e7          	jalr	-168(ra) # 578 <putc>
  while(--i >= 0)
 628:	197d                	addi	s2,s2,-1
 62a:	ff3918e3          	bne	s2,s3,61a <printint+0x80>
}
 62e:	70e2                	ld	ra,56(sp)
 630:	7442                	ld	s0,48(sp)
 632:	74a2                	ld	s1,40(sp)
 634:	7902                	ld	s2,32(sp)
 636:	69e2                	ld	s3,24(sp)
 638:	6121                	addi	sp,sp,64
 63a:	8082                	ret
    x = -xx;
 63c:	40b005bb          	negw	a1,a1
    neg = 1;
 640:	4885                	li	a7,1
    x = -xx;
 642:	bf8d                	j	5b4 <printint+0x1a>

0000000000000644 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 644:	7119                	addi	sp,sp,-128
 646:	fc86                	sd	ra,120(sp)
 648:	f8a2                	sd	s0,112(sp)
 64a:	f4a6                	sd	s1,104(sp)
 64c:	f0ca                	sd	s2,96(sp)
 64e:	ecce                	sd	s3,88(sp)
 650:	e8d2                	sd	s4,80(sp)
 652:	e4d6                	sd	s5,72(sp)
 654:	e0da                	sd	s6,64(sp)
 656:	fc5e                	sd	s7,56(sp)
 658:	f862                	sd	s8,48(sp)
 65a:	f466                	sd	s9,40(sp)
 65c:	f06a                	sd	s10,32(sp)
 65e:	ec6e                	sd	s11,24(sp)
 660:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 662:	0005c903          	lbu	s2,0(a1)
 666:	18090f63          	beqz	s2,804 <vprintf+0x1c0>
 66a:	8aaa                	mv	s5,a0
 66c:	8b32                	mv	s6,a2
 66e:	00158493          	addi	s1,a1,1
  state = 0;
 672:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 674:	02500a13          	li	s4,37
      if(c == 'd'){
 678:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 67c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 680:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 684:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 688:	00000b97          	auipc	s7,0x0
 68c:	3e0b8b93          	addi	s7,s7,992 # a68 <digits>
 690:	a839                	j	6ae <vprintf+0x6a>
        putc(fd, c);
 692:	85ca                	mv	a1,s2
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	ee2080e7          	jalr	-286(ra) # 578 <putc>
 69e:	a019                	j	6a4 <vprintf+0x60>
    } else if(state == '%'){
 6a0:	01498f63          	beq	s3,s4,6be <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6a4:	0485                	addi	s1,s1,1
 6a6:	fff4c903          	lbu	s2,-1(s1)
 6aa:	14090d63          	beqz	s2,804 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 6ae:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6b2:	fe0997e3          	bnez	s3,6a0 <vprintf+0x5c>
      if(c == '%'){
 6b6:	fd479ee3          	bne	a5,s4,692 <vprintf+0x4e>
        state = '%';
 6ba:	89be                	mv	s3,a5
 6bc:	b7e5                	j	6a4 <vprintf+0x60>
      if(c == 'd'){
 6be:	05878063          	beq	a5,s8,6fe <vprintf+0xba>
      } else if(c == 'l') {
 6c2:	05978c63          	beq	a5,s9,71a <vprintf+0xd6>
      } else if(c == 'x') {
 6c6:	07a78863          	beq	a5,s10,736 <vprintf+0xf2>
      } else if(c == 'p') {
 6ca:	09b78463          	beq	a5,s11,752 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6ce:	07300713          	li	a4,115
 6d2:	0ce78663          	beq	a5,a4,79e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6d6:	06300713          	li	a4,99
 6da:	0ee78e63          	beq	a5,a4,7d6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6de:	11478863          	beq	a5,s4,7ee <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6e2:	85d2                	mv	a1,s4
 6e4:	8556                	mv	a0,s5
 6e6:	00000097          	auipc	ra,0x0
 6ea:	e92080e7          	jalr	-366(ra) # 578 <putc>
        putc(fd, c);
 6ee:	85ca                	mv	a1,s2
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e86080e7          	jalr	-378(ra) # 578 <putc>
      }
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b765                	j	6a4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6fe:	008b0913          	addi	s2,s6,8
 702:	4685                	li	a3,1
 704:	4629                	li	a2,10
 706:	000b2583          	lw	a1,0(s6)
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	e8e080e7          	jalr	-370(ra) # 59a <printint>
 714:	8b4a                	mv	s6,s2
      state = 0;
 716:	4981                	li	s3,0
 718:	b771                	j	6a4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 71a:	008b0913          	addi	s2,s6,8
 71e:	4681                	li	a3,0
 720:	4629                	li	a2,10
 722:	000b2583          	lw	a1,0(s6)
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	e72080e7          	jalr	-398(ra) # 59a <printint>
 730:	8b4a                	mv	s6,s2
      state = 0;
 732:	4981                	li	s3,0
 734:	bf85                	j	6a4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 736:	008b0913          	addi	s2,s6,8
 73a:	4681                	li	a3,0
 73c:	4641                	li	a2,16
 73e:	000b2583          	lw	a1,0(s6)
 742:	8556                	mv	a0,s5
 744:	00000097          	auipc	ra,0x0
 748:	e56080e7          	jalr	-426(ra) # 59a <printint>
 74c:	8b4a                	mv	s6,s2
      state = 0;
 74e:	4981                	li	s3,0
 750:	bf91                	j	6a4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 752:	008b0793          	addi	a5,s6,8
 756:	f8f43423          	sd	a5,-120(s0)
 75a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 75e:	03000593          	li	a1,48
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	e14080e7          	jalr	-492(ra) # 578 <putc>
  putc(fd, 'x');
 76c:	85ea                	mv	a1,s10
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	e08080e7          	jalr	-504(ra) # 578 <putc>
 778:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 77a:	03c9d793          	srli	a5,s3,0x3c
 77e:	97de                	add	a5,a5,s7
 780:	0007c583          	lbu	a1,0(a5)
 784:	8556                	mv	a0,s5
 786:	00000097          	auipc	ra,0x0
 78a:	df2080e7          	jalr	-526(ra) # 578 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 78e:	0992                	slli	s3,s3,0x4
 790:	397d                	addiw	s2,s2,-1
 792:	fe0914e3          	bnez	s2,77a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 796:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 79a:	4981                	li	s3,0
 79c:	b721                	j	6a4 <vprintf+0x60>
        s = va_arg(ap, char*);
 79e:	008b0993          	addi	s3,s6,8
 7a2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7a6:	02090163          	beqz	s2,7c8 <vprintf+0x184>
        while(*s != 0){
 7aa:	00094583          	lbu	a1,0(s2)
 7ae:	c9a1                	beqz	a1,7fe <vprintf+0x1ba>
          putc(fd, *s);
 7b0:	8556                	mv	a0,s5
 7b2:	00000097          	auipc	ra,0x0
 7b6:	dc6080e7          	jalr	-570(ra) # 578 <putc>
          s++;
 7ba:	0905                	addi	s2,s2,1
        while(*s != 0){
 7bc:	00094583          	lbu	a1,0(s2)
 7c0:	f9e5                	bnez	a1,7b0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7c2:	8b4e                	mv	s6,s3
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	bdf9                	j	6a4 <vprintf+0x60>
          s = "(null)";
 7c8:	00000917          	auipc	s2,0x0
 7cc:	29890913          	addi	s2,s2,664 # a60 <malloc+0x152>
        while(*s != 0){
 7d0:	02800593          	li	a1,40
 7d4:	bff1                	j	7b0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7d6:	008b0913          	addi	s2,s6,8
 7da:	000b4583          	lbu	a1,0(s6)
 7de:	8556                	mv	a0,s5
 7e0:	00000097          	auipc	ra,0x0
 7e4:	d98080e7          	jalr	-616(ra) # 578 <putc>
 7e8:	8b4a                	mv	s6,s2
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bd65                	j	6a4 <vprintf+0x60>
        putc(fd, c);
 7ee:	85d2                	mv	a1,s4
 7f0:	8556                	mv	a0,s5
 7f2:	00000097          	auipc	ra,0x0
 7f6:	d86080e7          	jalr	-634(ra) # 578 <putc>
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	b565                	j	6a4 <vprintf+0x60>
        s = va_arg(ap, char*);
 7fe:	8b4e                	mv	s6,s3
      state = 0;
 800:	4981                	li	s3,0
 802:	b54d                	j	6a4 <vprintf+0x60>
    }
  }
}
 804:	70e6                	ld	ra,120(sp)
 806:	7446                	ld	s0,112(sp)
 808:	74a6                	ld	s1,104(sp)
 80a:	7906                	ld	s2,96(sp)
 80c:	69e6                	ld	s3,88(sp)
 80e:	6a46                	ld	s4,80(sp)
 810:	6aa6                	ld	s5,72(sp)
 812:	6b06                	ld	s6,64(sp)
 814:	7be2                	ld	s7,56(sp)
 816:	7c42                	ld	s8,48(sp)
 818:	7ca2                	ld	s9,40(sp)
 81a:	7d02                	ld	s10,32(sp)
 81c:	6de2                	ld	s11,24(sp)
 81e:	6109                	addi	sp,sp,128
 820:	8082                	ret

0000000000000822 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 822:	715d                	addi	sp,sp,-80
 824:	ec06                	sd	ra,24(sp)
 826:	e822                	sd	s0,16(sp)
 828:	1000                	addi	s0,sp,32
 82a:	e010                	sd	a2,0(s0)
 82c:	e414                	sd	a3,8(s0)
 82e:	e818                	sd	a4,16(s0)
 830:	ec1c                	sd	a5,24(s0)
 832:	03043023          	sd	a6,32(s0)
 836:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 83a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 83e:	8622                	mv	a2,s0
 840:	00000097          	auipc	ra,0x0
 844:	e04080e7          	jalr	-508(ra) # 644 <vprintf>
}
 848:	60e2                	ld	ra,24(sp)
 84a:	6442                	ld	s0,16(sp)
 84c:	6161                	addi	sp,sp,80
 84e:	8082                	ret

0000000000000850 <printf>:

void
printf(const char *fmt, ...)
{
 850:	711d                	addi	sp,sp,-96
 852:	ec06                	sd	ra,24(sp)
 854:	e822                	sd	s0,16(sp)
 856:	1000                	addi	s0,sp,32
 858:	e40c                	sd	a1,8(s0)
 85a:	e810                	sd	a2,16(s0)
 85c:	ec14                	sd	a3,24(s0)
 85e:	f018                	sd	a4,32(s0)
 860:	f41c                	sd	a5,40(s0)
 862:	03043823          	sd	a6,48(s0)
 866:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 86a:	00840613          	addi	a2,s0,8
 86e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 872:	85aa                	mv	a1,a0
 874:	4505                	li	a0,1
 876:	00000097          	auipc	ra,0x0
 87a:	dce080e7          	jalr	-562(ra) # 644 <vprintf>
}
 87e:	60e2                	ld	ra,24(sp)
 880:	6442                	ld	s0,16(sp)
 882:	6125                	addi	sp,sp,96
 884:	8082                	ret

0000000000000886 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 886:	1141                	addi	sp,sp,-16
 888:	e422                	sd	s0,8(sp)
 88a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 890:	00000797          	auipc	a5,0x0
 894:	1f07b783          	ld	a5,496(a5) # a80 <freep>
 898:	a805                	j	8c8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 89a:	4618                	lw	a4,8(a2)
 89c:	9db9                	addw	a1,a1,a4
 89e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a2:	6398                	ld	a4,0(a5)
 8a4:	6318                	ld	a4,0(a4)
 8a6:	fee53823          	sd	a4,-16(a0)
 8aa:	a091                	j	8ee <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ac:	ff852703          	lw	a4,-8(a0)
 8b0:	9e39                	addw	a2,a2,a4
 8b2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8b4:	ff053703          	ld	a4,-16(a0)
 8b8:	e398                	sd	a4,0(a5)
 8ba:	a099                	j	900 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8bc:	6398                	ld	a4,0(a5)
 8be:	00e7e463          	bltu	a5,a4,8c6 <free+0x40>
 8c2:	00e6ea63          	bltu	a3,a4,8d6 <free+0x50>
{
 8c6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c8:	fed7fae3          	bgeu	a5,a3,8bc <free+0x36>
 8cc:	6398                	ld	a4,0(a5)
 8ce:	00e6e463          	bltu	a3,a4,8d6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d2:	fee7eae3          	bltu	a5,a4,8c6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8d6:	ff852583          	lw	a1,-8(a0)
 8da:	6390                	ld	a2,0(a5)
 8dc:	02059713          	slli	a4,a1,0x20
 8e0:	9301                	srli	a4,a4,0x20
 8e2:	0712                	slli	a4,a4,0x4
 8e4:	9736                	add	a4,a4,a3
 8e6:	fae60ae3          	beq	a2,a4,89a <free+0x14>
    bp->s.ptr = p->s.ptr;
 8ea:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ee:	4790                	lw	a2,8(a5)
 8f0:	02061713          	slli	a4,a2,0x20
 8f4:	9301                	srli	a4,a4,0x20
 8f6:	0712                	slli	a4,a4,0x4
 8f8:	973e                	add	a4,a4,a5
 8fa:	fae689e3          	beq	a3,a4,8ac <free+0x26>
  } else
    p->s.ptr = bp;
 8fe:	e394                	sd	a3,0(a5)
  freep = p;
 900:	00000717          	auipc	a4,0x0
 904:	18f73023          	sd	a5,384(a4) # a80 <freep>
}
 908:	6422                	ld	s0,8(sp)
 90a:	0141                	addi	sp,sp,16
 90c:	8082                	ret

000000000000090e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 90e:	7139                	addi	sp,sp,-64
 910:	fc06                	sd	ra,56(sp)
 912:	f822                	sd	s0,48(sp)
 914:	f426                	sd	s1,40(sp)
 916:	f04a                	sd	s2,32(sp)
 918:	ec4e                	sd	s3,24(sp)
 91a:	e852                	sd	s4,16(sp)
 91c:	e456                	sd	s5,8(sp)
 91e:	e05a                	sd	s6,0(sp)
 920:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 922:	02051493          	slli	s1,a0,0x20
 926:	9081                	srli	s1,s1,0x20
 928:	04bd                	addi	s1,s1,15
 92a:	8091                	srli	s1,s1,0x4
 92c:	0014899b          	addiw	s3,s1,1
 930:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 932:	00000517          	auipc	a0,0x0
 936:	14e53503          	ld	a0,334(a0) # a80 <freep>
 93a:	c515                	beqz	a0,966 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 93e:	4798                	lw	a4,8(a5)
 940:	02977f63          	bgeu	a4,s1,97e <malloc+0x70>
 944:	8a4e                	mv	s4,s3
 946:	0009871b          	sext.w	a4,s3
 94a:	6685                	lui	a3,0x1
 94c:	00d77363          	bgeu	a4,a3,952 <malloc+0x44>
 950:	6a05                	lui	s4,0x1
 952:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 956:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 95a:	00000917          	auipc	s2,0x0
 95e:	12690913          	addi	s2,s2,294 # a80 <freep>
  if(p == (char*)-1)
 962:	5afd                	li	s5,-1
 964:	a88d                	j	9d6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 966:	00000797          	auipc	a5,0x0
 96a:	12278793          	addi	a5,a5,290 # a88 <base>
 96e:	00000717          	auipc	a4,0x0
 972:	10f73923          	sd	a5,274(a4) # a80 <freep>
 976:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 978:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 97c:	b7e1                	j	944 <malloc+0x36>
      if(p->s.size == nunits)
 97e:	02e48b63          	beq	s1,a4,9b4 <malloc+0xa6>
        p->s.size -= nunits;
 982:	4137073b          	subw	a4,a4,s3
 986:	c798                	sw	a4,8(a5)
        p += p->s.size;
 988:	1702                	slli	a4,a4,0x20
 98a:	9301                	srli	a4,a4,0x20
 98c:	0712                	slli	a4,a4,0x4
 98e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 990:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 994:	00000717          	auipc	a4,0x0
 998:	0ea73623          	sd	a0,236(a4) # a80 <freep>
      return (void*)(p + 1);
 99c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9a0:	70e2                	ld	ra,56(sp)
 9a2:	7442                	ld	s0,48(sp)
 9a4:	74a2                	ld	s1,40(sp)
 9a6:	7902                	ld	s2,32(sp)
 9a8:	69e2                	ld	s3,24(sp)
 9aa:	6a42                	ld	s4,16(sp)
 9ac:	6aa2                	ld	s5,8(sp)
 9ae:	6b02                	ld	s6,0(sp)
 9b0:	6121                	addi	sp,sp,64
 9b2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9b4:	6398                	ld	a4,0(a5)
 9b6:	e118                	sd	a4,0(a0)
 9b8:	bff1                	j	994 <malloc+0x86>
  hp->s.size = nu;
 9ba:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9be:	0541                	addi	a0,a0,16
 9c0:	00000097          	auipc	ra,0x0
 9c4:	ec6080e7          	jalr	-314(ra) # 886 <free>
  return freep;
 9c8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9cc:	d971                	beqz	a0,9a0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ce:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9d0:	4798                	lw	a4,8(a5)
 9d2:	fa9776e3          	bgeu	a4,s1,97e <malloc+0x70>
    if(p == freep)
 9d6:	00093703          	ld	a4,0(s2)
 9da:	853e                	mv	a0,a5
 9dc:	fef719e3          	bne	a4,a5,9ce <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9e0:	8552                	mv	a0,s4
 9e2:	00000097          	auipc	ra,0x0
 9e6:	b6e080e7          	jalr	-1170(ra) # 550 <sbrk>
  if(p == (char*)-1)
 9ea:	fd5518e3          	bne	a0,s5,9ba <malloc+0xac>
        return 0;
 9ee:	4501                	li	a0,0
 9f0:	bf45                	j	9a0 <malloc+0x92>
