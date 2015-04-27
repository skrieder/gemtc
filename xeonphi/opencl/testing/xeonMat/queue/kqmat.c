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
void randomInit(int* data, int size)
{
   for  (i = 0; i < size; i++)
   data[i] = rand() / (int)RAND_MAX;
}
 
/////////////////////////////////////////////////////////
// Program main
/////////////////////////////////////////////////////////
 
int main(int argc, char* argv[])
{
int num_ker=0,num_queue;
num_ker=atoi(argv[2]);
num_queue=atoi(argv[3]);

	//variables
/*#define WA 1024
#define HA 1024
#define WB 1024
#define HB WA
#define WC WB
#define HC HA
*/
struct timeval tim,ftim;
  double t1,t2,tim1,tim2;

//    gettimeofday(&tim, NULL);
  //  t1=tim.tv_sec+(tim.tv_usec/1000000.0);
    gettimeofday(&ftim, NULL);
    tim1=ftim.tv_sec+(ftim.tv_usec/1000000.0);

int m,WA,HA,WB,HB,WC,HC;
m = atoi(argv[5]);
WA=(256*m);
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
   unsigned int mem_size_A = sizeof(int) * size_A;
   int* h_A = (int*) malloc(mem_size_A);
 
   unsigned int size_B = WB * HB;
   unsigned int mem_size_B = sizeof(int) * size_B;
   int* h_B = (int*) malloc(mem_size_B);
 
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
   unsigned int  mem_size_C = sizeof(int) * size_C;
   int* h_C = (int*) malloc(mem_size_C);
 
   // 5. Initialize OpenCL
   // OpenCL specific variables
   cl_context clGPUContext;
//   cl_command_queue* clCommandQue;
   //cl_program clProgram;
   //cl_kernel clKernel;
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
    //cl_device_id device_id;// = (cl_device_id)malloc(sizeof(cl_device_id)); 
    // Bind to platform
// errcode = clGetPlatformIDs(1, &cpPlatform, NULL);
clGetPlatformIDs(0, NULL, &platformCount);
    cpPlatform = (cl_platform_id*) malloc(sizeof(cl_platform_id) * platformCount);
clGetPlatformIDs(platformCount, cpPlatform, NULL);//what ever is returned from last step will be used here

cl_device_id device_id;
int choice =atoi(argv[1]);
if(choice ==1)
{
 // Length of vectors
    // n = 64;

    // Connect to a compute device 
// we can have CL_DEVICE_GPU or ACCELERATOR or ALL as an option here
//depending what device are we working on
// we can these multiple times depending on requirements
    errcode = clGetDeviceIDs(cpPlatform[0],CL_DEVICE_TYPE_ACCELERATOR , 1, &device_id, NULL);
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
//malloc for command queue, kernel and program
cl_kernel *clKernel=(cl_kernel *)malloc(num_ker * sizeof(cl_kernel));
cl_program *clProgram=(cl_program *)malloc(num_ker * sizeof(cl_kernel));

cl_command_queue * clCommandQue = (cl_command_queue *)malloc(num_ker * sizeof(cl_command_queue));
   //Create a command-queue
for(i=0;i<num_queue;i++)
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
 for(i=0;i<num_ker;i++)
{
   clProgram[i] = clCreateProgramWithSource(clGPUContext, 
                1, (const char **) & KernelSource, 
                NULL, &errcode);
   //shrCheckError(errcode, CL_SUCCESS);
 
   errcode = clBuildProgram(clProgram[i], 0, 
              NULL, NULL, NULL, NULL);
   //shrCheckError(errcode, CL_SUCCESS);
 
   clKernel[i] = clCreateKernel(clProgram[i], 
               "matrixMul", &errcode);
} 
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

for(i=0;i<num_queue;i++){
    errcode = clEnqueueWriteBuffer(clCommandQue[i], d_A, CL_TRUE, 0,mem_size_A, h_A, 0, NULL, NULL);
errcode = clEnqueueWriteBuffer(clCommandQue[i], d_B, CL_TRUE, 0,mem_size_B, h_B, 0, NULL, NULL);
}
    
   // 7. Launch OpenCL kernel
   size_t localWorkSize[2], globalWorkSize[2];
 
   int wA = WA;
   int wC = WC;
for(i=0;i<num_ker;i++)
{
   errcode = clSetKernelArg(clKernel[i], 0, 
              sizeof(cl_mem), (void *)&d_C);
   errcode = clSetKernelArg(clKernel[i], 1, 
              sizeof(cl_mem), (void *)&d_A);
   errcode = clSetKernelArg(clKernel[i], 2, 
              sizeof(cl_mem), (void *)&d_B);
   errcode = clSetKernelArg(clKernel[i], 3, 
              sizeof(int), (void *)&wA);
   errcode = clSetKernelArg(clKernel[i], 4, 
              sizeof(int), (void *)&wC);
}
//   shrCheckError(errcode, CL_SUCCESS);
//struct timespec start, finish;
 
 int value;
value =atoi(argv[4]);
   localWorkSize[0] = value ;
   localWorkSize[1] = value ;
   globalWorkSize[0] = HA;
   globalWorkSize[1] = HA;
//clFinish(clCommandQue);

//timer starting
// clock_gettime(CLOCK_MONOTONIC, &start);
//struct timeval tim;
  //double t1,t2;

//    gettimeofday(&tim, NULL);
  //  t1=tim.tv_sec+(tim.tv_usec/1000000.0);
    gettimeofday(&tim, NULL);
    t1=tim.tv_sec+(tim.tv_usec/1000000.0);
//multikernels inside queues
int j=0;
for(j=0;j<num_queue;j++)
{
for(i=0;i<num_ker;i++){
   errcode = clEnqueueNDRangeKernel(clCommandQue[j], 
              clKernel[i], 2, NULL, globalWorkSize, 
              localWorkSize, 0, NULL, NULL);
}
}
for(i=0;i<num_queue;i++)
{
 clFinish(clCommandQue[i]);
}

gettimeofday(&tim, NULL);
    t2=tim.tv_sec+(tim.tv_usec/1000000.0);
printf("%.6lf\t",(t2-t1));
 
 // shrCheckError(errcode, CL_SUCCESS);
/*  clock_gettime(CLOCK_MONOTONIC, &finish);
        elapsed = (finish.tv_sec - start.tv_sec);
        elapsed += (finish.tv_nsec - start.tv_nsec)/ 1000000000.0;

printf("Work Item/threads = %d \n",value);
printf("time taken by GPU = %le\n ",elapsed);
*/
   // 8. Retrieve result from device

for(i=0;i<num_queue;i++)
{
   errcode = clEnqueueReadBuffer(clCommandQue[i], 
              d_C, CL_TRUE, 0, mem_size_C, 
              h_C, 0, NULL, NULL);
   //shrCheckError(errcode, CL_SUCCESS);
}
for(i=0;i<num_queue;i++)
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
for(i=0;i<num_ker;i++)
{
   clReleaseKernel(clKernel[i]);
   clReleaseProgram(clProgram[i]);
}
for(i=0;i<num_queue;i++){
   clReleaseCommandQueue(clCommandQue[i]);
}	
gettimeofday(&ftim, NULL);
    tim2=ftim.tv_sec+(ftim.tv_usec/1000000.0);
printf("%.6lf\t",(tim2-tim1));
printf("\n");
exit(0);
}

