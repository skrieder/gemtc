/*
	Test program for evaluating the new gemtc worker. -Scott
*/

#include <builtins.swift>
#include <io.swift>
#include <sys.swift>
#include <gemtc.swift>

main
{	
	int sleepTime = toint(argv("sleep_time"));
	int numTasks = toint(argv("num_tasks"));

	printf("Sleeptime: %i", sleepTime);
	printf("Numtasks: %i", numTasks);
	int A[];
	foreach i in [0:numTasks]
	{
		A[i] = gemtc_sleep(sleepTime);
		//printf("The result received to swift for A[i] was: %d\n", A[i]);
     	}
	// printf("The result received to swift for A[0] was: %d\n", A[0]);
	// printf("The result received to swift for A[1] was: %d\n", A[1]);
        // printf("The result received to swift for A[1] was: %d\n", A[1]);
}
