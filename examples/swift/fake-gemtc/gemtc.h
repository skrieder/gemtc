struct ResultPair{int ID; void *params;};

void PrintArray(void *ptr, int num_elements);

extern void gemtcSetup(int, int);
extern void gemtcCleanup();
extern void gemtcBlockingRun(int Type, int Threads, int ID, void *d_params);
extern void gemtcPush(int taskType, int threads, int ID, void *d_parameters);
void gemtcPoll(int *ID, void **params);
extern void gemtcMemcpyHostToDevice(void *device, void *host, int size);
extern void gemtcMemcpyDeviceToHost(void *host, void *device, int size);
extern void *gemtcGPUMalloc(int size);
extern void gemtcGPUFree(void *p);
int IntFromStr(char *str);
int *GEMTC_CPUMallocInt(int size);
void SetVoidPointerWithOffset(void *ptr, void * value, int writeSize, int offset);
void GetHardCodedResult(void *ptr, void * value, int writeSize, int offset);
void GEMTC_FillPositionArray(void *position, int num_elements);
void dumpParams(void* params);
void **GEMTC_CPUMallocVPP(int size);
void *GEMTC_CPUMallocVP(int size);
void *GEMTC_CPUMalloc(int size);
void *VPFromVPP(void **ptr);
void GEMTC_CPUFreeVP(void *p);
void GEMTC_CPU_SetInt(void *ptr, int value);
void GEMTC_CPU_SetLongInt(void *ptr, long int value);
void GEMTC_CPU_SetDouble(void *ptr, double value);
void GEMTC_ZeroDoubleArray(void *ptr, int num_elements);
double* GEMTC_GetDoubleArray(int num_elements);
double* GEMTC_GetPositionArray(int num_elements);
int GEMTC_CPU_GetInt(void *ptr);
long int GEMTC_CPU_GetLongInt(void *ptr);
double GEMTC_CPU_GetDouble(void *ptr);
int IntFromVP(void *params);
int GEMTC_CPU_GetResult(void *ptr);

void PrintIntFromPointer(int *ID);
void PrintIntFromVPP(void **params);
void PrintIntFromVP(void *params);

struct GEMTC_S
{
    int i;
    void* d;
  };


int GEMTC_SizeOfInt();
int GEMTC_SizeOfLongInt();
int GEMTC_SizeOfDouble();
void *GEMTC_GetVoidPointer();
int *GEMTC_GetIntPointer();
void *GEMTC_GetVoidPointerWithSize(int size);
void GEMTC_f(int j, struct GEMTC_S* s);

/**
  Initializes the SuperKernel and necessary shared memory on GPU.
Parameter is the size of the queues in device memory. Changing this value has no noticeable effect on performance if this is >5000.
*/
void GEMTC_Setup(int queueSize);

/**
	Kills the SuperKernel. Cleans up device memory.
*/
void GEMTC_Cleanup();

/**
 	Blocking call that will wait for the microkernel to finish before returning.
	Very bad efficiency in multithreaded.
	Recommend using GEMTC_Push/GEMTC_Poll
*/
//slightly different
void GEMTC_BlockingRun(int Type, int Threads, int ID, void *d_params);

/**
   Enqueues a task into GPU memory queue.
*/
void GEMTC_Push(int Type, int Threads, int ID, void *d_params);

// Take an ID and params as reference
void GEMTC_Poll(int *ID, void **params);
/**
   Pass an ID and params as ref and update this way now.
*/

/**
   Allocates size bytes of device memory. Uses GEMTC_ Sub-Allocator
*/
void *GEMTC_GPUMalloc(int size);

/**
   CPU Memory set
   ptr should point to a good integer
 */
void GEMTC_CPU_SetInt(void *ptr, int value);

/**
   Free memory allocated by GEMTC_GPUMalloc through the Sub-Allocator
*/
void GEMTC_GPUFree(void *p);

/**
   Copies Memory from Host to Device
   Very similar to corresponding CUDA function
*/
void GEMTC_MemcpyHostToDevice(void *device, void *host, int size);

/**
   Copies Memory from Device to Host
   Very similar to corresponding CUDA function
*/
void GEMTC_MemcpyDeviceToHost(void *host, void *device, int size);
