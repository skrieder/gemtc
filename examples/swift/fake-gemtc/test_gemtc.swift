/*
	Test program for evaluating the new gemtc worker. -Scott
*/

import io;
import gemtc;

main
{
     int r = gemtc_sleep(1);
     int s = gemtc_sleep(2);
     
     printf("The result received to swift for r was: %d\n", r);
     printf("The result received to swift for s was: %d\n", s);
}
