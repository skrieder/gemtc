#include "gemtc_memory.h"

void *payload_from_header(void* header) {
	return header + sizeof(DataHeader_t);
}
void *header_from_payload(void* payload) {
	return payload - sizeof(DataHeader_t);
}