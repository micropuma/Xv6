#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main()
{
	int ptov[2];
	int vtop[2];

	pipe(ptov);
	pipe(vtop);

	int pid = fork();

	if(pid == 0)
	{
		// child process
		char buf[10];
		close(ptov[1]);
		close(vtop[0]);

                if(read(ptov[0], buf, 10) > 0)
			printf("%d: received ping\n", getpid());
		write(vtop[1], "pong", 5);
		
		close(ptov[0]);
		close(vtop[1]);
		exit(0);
	}
	else if(pid > 0)
	{
                // parent process
		char buf[10];
		close(ptov[0]);
		close(vtop[1]);
		write(ptov[1], "ping", 5);

		wait(0);
		if(read(vtop[0], buf, 10) > 0)
			printf("%d: received pong\n", getpid());

                close(ptov[1]);
		close(vtop[0]);
		exit(0);
	}

	exit(0);
}
