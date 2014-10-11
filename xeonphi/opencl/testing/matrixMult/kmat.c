// Multiply two matrices A * B = C
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <CL/opencl.h> 
 
 int i=0;
/* char *KernelSource = "\n"\

"__kernel void matrixMul(__global float* C,		\n"\
"          __global float* A,				\n"\
"         __global float* B,				\n"\
"        int wA, int wB)				\n"\
"{							\n"\
"   int tx = get_global_id(0); 				\n"\
"   int ty = get_global_id(1);				\n"\

"	 float value = 0;				\n"\
"   for (int k = 0; k < wA; ++k)			\n"\
"   {							\n"\
"      float elementA = A[ty * wA + k];			\n"\
"      float elementB = B[k * wB + tx];			\n"\
"      value += elementA * elementB;			\n"\
"   }							\n"\

"   C[ty * wA + tx] = value;				\n"\
"}							\n"\

"\n";
*/
char* load_program_source(const char *filename) {
  struct stat statbuf;
  FILE *fh;
  char *source;

  fh = fopen(filename, "r");
  if (fh == 0)
    return 0;

  stat(filename, &statbuf);
  source = (char *) malloc(statbuf.st_size + 1);
  fread(source, statbuf.st_size, 1, fh);
  source[statbuf.st_size] = '\0';

  return source;
}

// Allocates a matrix with random float entries.
void randomInit(float* data, int size)
{
   for  (i = 0; i < size; i++)
   data[i] = rand() / (float)RAND_MAX;
}
 
/////////////////////////////////////////////////////////
// Program main
/////////////////////////////////////////////////////////
 
int main(int argc, char* argv[])
{
int num_ker;
num_ker=atoi(argv[2]);
	//variables
/*#define WA 1024
#define HA 1024
#define WB 1024
#define HB WA
#define WC WB
#define HC HA
*/
int WA,HA,WB,HB,WC,HC;
WA = atoi(argv[4]);
HA = WA;
WB = WA;
HB = WB;
WC = WA;
HC = WA;
   // set seed for rand()
   srand(2006);
 
   // 1. allocate host memory for matrices A and B
	//automate the size of the matrix
   unsigned int size_A = WA * HA;
   unsigned int mem_size_A = sizeof(float) * size_A;
   float* h_A = (float*) malloc(mem_size_A);
 
   unsigned int size_B = WB * HB;
   unsigned int mem_size_B = sizeof(float) * size_B;
   float* h_B = (float*) malloc(mem_size_B);
 
   // 2. initialize host memory
   randomInit(h_A, size_A);
   randomInit(h_B, size_B);
 
/*   // 3. print out A and B
   printf("\n\nMatrix A\n");
   for(i = 0; i < size_A; i++)
   {
      printf("%f ", h_A[i]);
      if(((i + 1) % WA) == 0)
      printf("\n");
   }
 
   printf("\n\nMatrix B\n");
   for(i = 0; i < size_B; i++)
   {
      printf("%f ", h_B[i]);
      if(((i + 1) % WB) == 0)
      printf("\n");
   }
 */
   
// 4. allocate host memory for the result C
   unsigned int size_C = WC * HC;
   unsigned int  mem_size_C = sizeof(float) * size_C;
   float* h_C = (float*) malloc(mem_size_C);
 
   // 5. Initialize OpenCL
   // OpenCL specific variables
   cl_context clGPUContext;
//   cl_command_queue* clCommandQue;
   cl_program clProgram;
   cl_kernel clKernel;
 cl_platform_id* cpPlatform;        // OpenCL platform
cl_uint platformCount; //keeps the divice count
  
   size_t dataBytes;
   size_t kernelLength;
   cl_int errcode;
 
   // OpenCL device memory for matrices
   cl_mem d_A;
   cl_mem d_B;
   cl_mem d_C;
 
   /*****************************************/
   /* Initialize OpenCL */
   /*****************************************/
//cl_platform_id* cpPlatform;        // OpenCL platform
    cl_device_id device_id;  
    // Bind to platform
// errcode = clGetPlatformIDs(1, &cpPlatform, NULL);
clGetPlatformIDs(0, NULL, &platformCount);
    cpPlatform = (cl_platform_id*) malloc(sizeof(cl_platform_id) * platformCount);
clGetPlatformIDs(platformCount, cpPlatform, NULL);//what ever is returned from last step will be used here

int choice =atoi(argv[1]);
if(choice ==1)
{
 // Length of vectors
    // n = 64;

    // Connect to a compute device 
// we can have CL_DEVICE_GPU or ACCELERATOR or ALL as an option here
//depending what device are we working on
// we can these multiple times depending on requirements
    errcode = clGetDeviceIDs(cpPlatform[0],CL_DEVICE_TYPE_CPU , 1, &device_id, NULL);
    if (errcode != CL_SUCCESS)

        printf("Error: Failed to create a device group!\n");
}
else
{
 //   errcode = clGetPlatformIDs(1, &cpPlatform, NULL);
    // Get ID for the device
    errcode = clGetDeviceIDs(cpPlatform[1], CL_DEVICE_TYPE_GPU, 1, &device_id, NULL);
    if (errcode != CL_SUCCESS)

    {

        printf("Error: Failed to create a device group!\n");
}
}
//printf("here");
    // Create a context 
   clGPUContext = clCreateContext(0, 1, &device_id, NULL, NULL, &errcode);
    // Create a command queue
//printf("here");
   /*clGPUContext = clCreateContextFromType(NULL, 
                   CL_DEVICE_TYPE_GPU, 
                   NULL, NULL, &errcode);
   //shrCheckError(errcode, CL_SUCCESS);
 
   // get the list of GPU devices associated 
   // with context
   errcode = clGetContextInfo(clGPUContext, 
              CL_CONTEXT_DEVICES, 0, NULL, 
              &dataBytes);
   cl_device_id *clDevices = (cl_device_id *)
              malloc(dataBytes);
   errcode = clGetContextInfo(clGPUContext, 
              CL_CONTEXT_DEVICES, dataBytes, 
              clDevices, NULL);
   //shrCheckError(errcode, CL_SUCCESS);
 */
//malloc for command queue
cl_command_queue * clCommandQue = (cl_command_queue *)malloc(num_ker * sizeof(cl_command_queue));
   //Create a command-queue
for(i=0;i<num_ker;i++)
{
   clCommandQue[i] = clCreateCommandQueue(clGPUContext, 
                  device_id, 0, &errcode);
 }  //shrCheckError(errcode, CL_SUCCESS);
  
  /* // Setup device memory
   d_C = clCreateBuffer(clGPUContext, 
          CL_MEM_READ_WRITE, 
          mem_size_A, NULL, &errcode);
   d_A = clCreateBuffer(clGPUContext, 
printf("\nhere"); 
          CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, 
          mem_size_A, h_A, &errcode);
   d_B = clCreateBuffer(clGPUContext, 
          CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, 
          mem_size_B, h_B, &errcode);
 */
 	char *file="matxm.cl";
	char *KernelSource =  load_program_source(file);
 
   clProgram = clCreateProgramWithSource(clGPUContext, 
                1, (const char **) & KernelSource, 
                &kernelLength, &errcode);
   //shrCheckError(errcode, CL_SUCCESS);
 
   errcode = clBuildProgram(clProgram, 0, 
              NULL, NULL, NULL, NULL);
   //shrCheckError(errcode, CL_SUCCESS);
 
   clKernel = clCreateKernel(clProgram, 
               "matrixMul", &errcode);
   //shrCheckError(errcode, CL_SUCCESS);
  // Setup device memory
   d_C = clCreateBuffer(clGPUContext, CL_MEM_READ_WRITE,
          mem_size_A, NULL, &errcode);
   d_A = clCreateBuffer(clGPUContext,
          CL_MEM_READ_WRITE,
          mem_size_A, h_A, &errcode);
   d_B = clCreateBuffer(clGPUContext,
          CL_MEM_READ_WRITE,
          mem_size_B, h_B, &errcode);

     // Write our data set into the input array in device memory

for(i=0;i<num_ker;i++){
    errcode = clEnqueueWriteBuffer(clCommandQue[i], d_A, CL_TRUE, 0,mem_size_A, h_A, 0, NULL, NULL);
errcode = clEnqueueWriteBuffer(clCommandQue[i], d_B, CL_TRUE, 0,mem_size_B, h_B, 0, NULL, NULL);
}
    
   // 7. Launch OpenCL kernel
   size_t localWorkSize[2], globalWorkSize[2];
 
   int wA = WA;
   int wC = WC;
   errcode = clSetKernelArg(clKernel, 0, 
              sizeof(cl_mem), (void *)&d_C);
   errcode = clSetKernelArg(clKernel, 1, 
              sizeof(cl_mem), (void *)&d_A);
   errcode = clSetKernelArg(clKernel, 2, 
              sizeof(cl_mem), (void *)&d_B);
   errcode = clSetKernelArg(clKernel, 3, 
              sizeof(int), (void *)&wA);
   errcode = clSetKernelArg(clKernel, 4, 
              sizeof(int), (void *)&wC);
//   shrCheckError(errcode, CL_SUCCESS);
//struct timespec start, finish;
 
 int value;
value =atoi(argv[3]);
   localWorkSize[0] = value ;
   localWorkSize[1] = value ;
   globalWorkSize[0] = HA;
   globalWorkSize[1] = HA;
//clFinish(clCommandQue);

//timer starting
// clock_gettime(CLOCK_MONOTONIC, &start);

for(i=0;i<num_ker;i++){
   errcode = clEnqueueNDRangeKernel(clCommandQue[i], 
              clKernel, 2, NULL, globalWorkSize, 
              localWorkSize, 0, NULL, NULL);
}
  // shrCheckError(errcode, CL_SUCCESS);
/*  clock_gettime(CLOCK_MONOTONIC, &finish);
        elapsed = (finish.tv_sec - start.tv_sec);
        elapsed += (finish.tv_nsec - start.tv_nsec)/ 1000000000.0;

printf("Work Item/threads = %d \n",value);
printf("time taken by GPU = %le\n ",elapsed);
*/
   // 8. Retrieve result from device

for(i=0;i<num_ker;i++)
{
   errcode = clEnqueueReadBuffer(clCommandQue[i], 
              d_C, CL_TRUE, 0, mem_size_C, 
              h_C, 0, NULL, NULL);
   //shrCheckError(errcode, CL_SUCCESS);
}
for(i=0;i<num_ker;i++)
{
 clFinish(clCommandQue[i]);
}
 // shrCheckError(errcode, CL_SUCCESS);
  //clock_gettime(CLOCK_MONOTONIC, &finish);
    //    elapsed = (finish.tv_sec - start.tv_sec);
      //  elapsed += (finish.tv_nsec - start.tv_nsec)/ 1000000000.0;

//printf("Work Item/threads = %d \n",value);
//printf("time taken by GPU = %le\n ",elapsed);

   // 9. print out the results
   /*printf("\n\nMatrix C (Results)\n");
   for(i = 0; i < size_C; i++)
   {
      printf("%f ", h_C[i]);
      if(((i + 1) % WC) == 0)
      printf("\n");
   }
   printf("\n");*/
 
   // 10. clean up memory
   free(h_A);
   free(h_B);
   free(h_C);
 
   clReleaseMemObject(d_A);
   clReleaseMemObject(d_C);
   clReleaseMemObject(d_B);
 
//   free(device_id);
 free(KernelSource);
   clReleaseContext(clGPUContext);
   clReleaseKernel(clKernel);
   clReleaseProgram(clProgram);
for(i=0;i<num_ker;i++)
   clReleaseCommandQueue(clCommandQue[i]);

}

