#ifndef __GEMTC_MEMORY__
#define __GEMTC_MEMORY__

typedef unsigned long mic_mem_ref_t;

typedef struct {
	unsigned int size;
	mic_mem_ref_t mic_payload;
} DataHeader_t;

typedef struct {
	int p;
} payload_t;


void *payload_from_header(void* header);

void *header_from_payload(void* payload);


#endif
