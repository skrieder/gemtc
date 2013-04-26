#ifndef _GEMTC_MIC_API_H_ADAPTR
#define _GEMTC_MIC_API_H_ADAPTR 1


void gemtcSetup(int Queuesize, int workers) {
	MIC_gemtcSetup(Queuesize, workers);
}
void gemtcCleanup() {
	 MIC_gemtcCleanup();
}
void gemtcPush(int Type, int Threads, int ID, void *params) {
	MIC_gemtcPush(Type, Threads, ID, params);
}

void gemtcPoll(int *ID, void **params) {
	MIC_gemtcPoll(ID, params);
}

void *gemtcGPUMalloc(unsigned nbytes) {
	return MIC_gemtcMalloc(nbytes);
}

void gemtcFree(void *loc) {
	MIC_gemtcFree(loc);
}


void gemtcMemcpyDeviceToHost(void *host, void *device, int size) {
	MIC_gemtcMemcpyDeviceToHost(host, device, size);
}
void gemtcMemcpyHostToDevice(void *device, void *host, int size) {
	MIC_gemtcMemcpyHostToDevice(device, host, size);
}
#endif
