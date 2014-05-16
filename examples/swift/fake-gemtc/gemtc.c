extern void gemtcSetup(int, int);

/* C */
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "gemtc.h"

//#include <log.h>

void GEMTC_f(int j, struct GEMTC_S* s)
{
  s->i = 90;
}

void PrintArray(void *ptr, int num_elements){
  double *A = (double *)ptr;

  int i;
  for(i=0; i<num_elements; i++){
    printf("A[%d] = %f\n", i, A[i]);
  }
}

void SetVoidPointerWithOffset(void *ptr, void * value, int writeSize, int offset){
  memcpy( (((char*)ptr)+offset), value, writeSize);
}

void GetHardCodedResult(void *ptr, void * value, int writeSize, int offset){
  memcpy( (ptr), ((char *)value + offset), writeSize);
}


/* Helpers*/
void dumpParams(void* params){
  /*This will dump everything in the data table, but
    you have to actually pass the table here. */

  long int np = *((long int*) params);
  long int nd = *(((long int*) params)+1);

  int size = np * nd;

  double *mass = (((double*) params) +2);
  double *pos = mass + 1;
  double *vel = pos + size;
  double *acc = vel + size;
  double *f = acc + size;
  double *pe = f + size;
  double *ke = pe + size; 

  printf("NP: %ld\n ND: %ld\n", np, nd);

  int i;
  for(i=0; i<size; i++){
    printf("%d: %.2f %.2f %.2f %.2f %.2f %.2f\n", i, pos[i], vel[i], acc[i], f[i], pe[i], ke[i]);
  }
}

int GEMTC_SizeOfInt(){
  return sizeof(int);
}
int GEMTC_SizeOfDouble(){
  return (int)sizeof(double);
}
int GEMTC_SizeOfLongInt(){
  return (int)sizeof(long int);
}

double* GEMTC_GetPositionArray(int num_elements){
	double *position = (double*)malloc(sizeof(double)*num_elements);
  	srand(123456789);
  	int i;
	for(i=0; i<num_elements; i++){
    		position[i] = ((double)rand())/52000;
  	}
	return position;
}

void GEMTC_FillPositionArray(void *position, int num_elements){
  double* A = (double*) position;
  srand(123456789);
  int i;
  for(i=0; i<num_elements; i++){
    A[i] = ((double)rand())/52000;
    //printf("Setting: %f\n",A[i]);
  }
}

double* GEMTC_GetDoubleArray(int num_elements){
	double *array = (double*)malloc(num_elements * sizeof(double));
	int i;
	for(i=0; i<num_elements; i++){
		array[i] = 0.0;
	}
	return array;
}
void GEMTC_ZeroDoubleArray(void *pointer, int num_elements){
  double *A = (double *)pointer;
  //  double *array = (double*)malloc(num_elements * sizeof(double));
  int i;
  for(i=0; i<num_elements; i++){
    A[i] = 0.0;
  }
}


int IntFromStr(char *str){
  int temp;
  temp = atoi(str);
  return temp;
}

void PrintIntFromPointer(int *ID){
  printf("The id is: %d\n", *ID);
}
void PrintIntFromVPP(void **params){
  int temp;
  temp = **(int **)params;
  printf("The int at params is: %d\n", temp);
}
void PrintIntFromVP(void *params){
  int temp;
  temp = *(int *)params;
  printf("The int at params is: %d\n", temp);
}

int IntFromVP(void *params){
  int temp;
  memcpy(&temp, params, sizeof(int));
  //  printf("IntFromVP: %i\n", temp);
  return temp;
}

void *VPFromVPP(void **ptr){
  void *temp;
  temp = *ptr;
  return temp;
}

void *GEMTC_GetVoidPointer(){
  int *result = (int *)malloc(sizeof(int));
  return result;
}
void *GEMTC_GetVoidPointerWithSize(int size){
  void *result = malloc(size);
  return result;
}
int *GEMTC_GetIntPointer(){
  int *result = (int *)malloc(sizeof(int));
  return result;
}

static bool setup = false;
static bool cleanup = false;

/* The Setup function should be called once per node at the start of the program.*/
void GEMTC_Setup(int queueSize)
{
  if (!setup)
  {
    // Call GEMTC_Setup Here
    gemtcSetup(queueSize, 0);
    setup = true;
  }
  //log_printf("GEMTC_Setup");
}

/* The cleanup function should be called once per node at the end of the program.*/
void GEMTC_Cleanup()
{
  if (!cleanup)
  {
    gemtcCleanup();
    cleanup = true;
  }
}

void GEMTC_BlockingRun(int Type, int Threads, int ID, void *d_params)
{
  gemtcBlockingRun(Type, Threads, ID, d_params);
}

void GEMTC_Push(int Type, int Threads, int ID, void *d_params)
{
  gemtcPush(Type, Threads, ID, d_params);
}

void GEMTC_Poll(int *ID, void **params){
  // log_printf("GEMTC_Poll");
  gemtcPoll(ID, params);
}

/* GPU Memory Allocate*/
void *GEMTC_GPUMalloc(int size)
{
  //printf("GEMTC_GPUMalloc Start\n");
  return gemtcGPUMalloc(size);
}


/* GEMTC Memory Free*/
void GEMTC_GPUFree(void *p)
{
  gemtcGPUFree(p);
}

/* CPU Memory Allocate*/
void *GEMTC_CPUMalloc(int size)
{
  void *result = malloc(sizeof(size));
  return result;
}
/* CPU Memory Allocate an Int*/
int *GEMTC_CPUMallocInt(int size)
{
  int *result = malloc(sizeof(size));
  return result;
}
/* CPU Memory Allocate an Int*/
void **GEMTC_CPUMallocVPP(int size)
{
  void **result = malloc(sizeof(size));
  return result;
}
/* CPU Memory Allocate an Int*/
void *GEMTC_CPUMallocVP(int size)
{
  void *result = malloc(sizeof(size));
  return result;
}

void GEMTC_CPU_SetInt(void *ptr, int value)
{
  memcpy(ptr, &value, sizeof(int));
}
void GEMTC_CPU_SetLongInt(void *ptr, long int value)
{
  memcpy(ptr, &value, sizeof(long int));
}
void GEMTC_CPU_SetDouble(void *ptr, double value)
{
  memcpy(ptr, &value, sizeof(double));
}

int GEMTC_CPU_GetInt(void *ptr)
{
  int temp;
  temp = *(int *)ptr;
  return temp;
}
long int GEMTC_CPU_GetLongInt(void *ptr)
{
  long int temp;
  temp = *(long int *)ptr;
  return temp;
}
double GEMTC_CPU_GetDouble(void *ptr)
{
  double temp;
  temp = *(double *)ptr;
  return temp;
}

/* void* deref_ptr(void *ptr){ */
/*   return &ptr; */
/* } */

int GEMTC_CPU_GetResult(void *ptr){
  int result;
  memcpy(&result, ptr, sizeof(int));
  return result;
}

/* CPU Memory Free*/
void GEMTC_CPUFreeVP(void *p){
  free(p);
}

/*GEMTC optimized memory transfer Host to Dev.*/
void GEMTC_MemcpyHostToDevice(void *device, void *host, int size)
{
  gemtcMemcpyHostToDevice(device, host, size);
}

/*GEMTC optimized memory transfer Dev to Host.*/
void GEMTC_MemcpyDeviceToHost(void *host, void *device, int size)
{
  gemtcMemcpyDeviceToHost(host, device, size);
}


