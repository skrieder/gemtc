#ifndef _GEMTC_KERNELS_MIC_
#define  _GEMTC_KERNELS_MIC_


#pragma offload_attribute(push, target (mic))

void* kernel_add_sleep(void *length);

typedef struct {
	int length;
	// perhaps a payload resides here...
} sleep_task;

#pragma offload_attribute(pop)

#endif