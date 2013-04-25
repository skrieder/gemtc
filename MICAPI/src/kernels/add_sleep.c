#include <sys/time.h>
#include <stddef.h>

#define BUSY_LOOP_REPEATS 100000

#pragma offload_attribute(push, target (mic))
long time_diff_usec(struct timeval start, struct timeval end) {
	return (end.tv_sec-start.tv_sec)*1000000 + (end.tv_usec-start.tv_usec);
}

void* kernel_add_sleep(void *length) {
	int sleep_time_usec = *((int*)length);
	int i = 0;

	struct timeval start_time;
	struct timeval cur_time;
	gettimeofday(&start_time, NULL);	
	gettimeofday(&cur_time, NULL);
	int dumb;
	while (time_diff_usec(start_time, cur_time) < sleep_time_usec) {
		for (i = 0; i<BUSY_LOOP_REPEATS; i++) {
			dumb = i * 20;
		}
		gettimeofday(&cur_time, NULL);
	}

	return 0;
}
#pragma offload_attribute(pop)