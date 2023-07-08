#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PIPEREAD 0
#define PIPEWRITE 1

// finish prime sieve, using pipe to fulfill concurrency!

void primes(int fd)
{
	int pipe2[2];
	int isFirst = 1;

	// public is the one to sieve!
	int public = 0;
	int otherNum = 0;
      
	read(fd, &public, sizeof(int));
        printf("prime %d\n", public);

	while(read(fd, &otherNum, sizeof(int)) != 0)
	{
		if(isFirst == 1)
		{
			isFirst = 0;
			pipe(pipe2);
			
			int pid = fork();
			if(pid > 0)
			{
				close(pipe2[PIPEREAD]);
			}
			else if(pid == 0)
			{
				close(pipe2[PIPEWRITE]);
                                primes(pipe2[PIPEREAD]);
				//close(pipe2[PIPEREAD]);
				return;
			}	
		}

		if(otherNum % public != 0)
		{
			//printf("%d\t", otherNum);
			write(pipe2[PIPEWRITE], &otherNum, sizeof(int));
		}
	}

	close(fd);
	close(pipe2[PIPEWRITE]);
	wait(0);
}

int main(void)
{
	int pipe1[2];
	pipe(pipe1);

	int pid = fork();

	if(pid > 0)
	{
		close(pipe1[PIPEREAD]);
		for(int i = 2; i <= 35; i++)
		{
			write(pipe1[PIPEWRITE], &i, sizeof(int));
		}
		close(pipe1[PIPEWRITE]);
		wait(0);
	}
	else if(pid == 0)
	{
		close(pipe1[PIPEWRITE]);
		primes(pipe1[PIPEREAD]);
		//close(pipe1[PIPEREAD]);
	}

	exit(0);
}		
