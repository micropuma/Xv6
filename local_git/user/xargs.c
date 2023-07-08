#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"

#define BUFSIZE 30
//#define DEBUG 0

int main(int argc, char *argv[])
{
	sleep(10);

	//1. first need to figure out where is the standard input.
	char buf[BUFSIZE];
	read(0, buf, BUFSIZE);

        //2. next need to get the xargs argv list!
	char *xargv[MAXARG];
	int xargc = 0;
	for(int i = 1; i < argc; i++)
	{
		xargv[xargc++] = argv[i];
	}

	//3. Finally, need to combine those two arguments into the right order!
	char *p = buf;
	printf("%s", buf);
	for(int i = 0; i < BUFSIZE; i++)
	{
		// \n means individual line, like -n 1 command!
		if(buf[i] == '\n')
		{
			int pid = fork();
			if(pid > 0)
			{
				// parent process change the p pointer and wait!
				p = &buf[i+1];
		 		wait(0);		
			}
			else if(pid == 0)
			{
				// child process executes the command!
				buf[i] = 0;
				// construct the parameter list!
                                xargv[xargc++] = p;
				xargv[xargc] = 0;
				xargc++;
				exec(xargv[0], xargv);
				exit(0);
			}
		}
	}

	wait(0);
	exit(0);
}
	

