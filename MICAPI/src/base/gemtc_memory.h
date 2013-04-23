#ifndef __GEMTC_MEMORY__
#define __GEMTC_MEMORY__

typedef struct {
	unsigned int size;
} DataHeader_t;

typedef struct {
	int p;
} payload_t;

void *payload_from_header(void* header);

void *header_from_payload(void* payload);


#endif