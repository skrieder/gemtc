/*
	Test program for evaluating the new gemtc worker. -Scott
*/


import io;
import sys;
import gemtc;

main
{
	
	int N = toint(argv("bound"));
	int sleepTime = toint(argv("sleeptime"));

   	// print for debug
	//     	printf("The number of arguments is: %i\n", argc());
     	//printf("The bound is: %i\n", N);
     	//printf("The sleeptime is: %i\n", sleepTime);
      
	int A[];
	foreach i in [0:N-1]
	{
		A[i] = gemtc_sleep(sleepTime);
	//	printf("The result received to swift for A[i] was: %d\n", A[i]);
     	}
//	printf("The result received to swift for A[0] was: %d\n", A[0]);
//	printf("The result received to swift for A[1] was: %d\n", A[1]);
//      printf("The result received to swift for A[1] was: %d\n", A[1]);
}
