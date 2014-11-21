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
// Allocates a matrix with random float entries.
void randomInit(float* data, int size)
{
   for  (i = 0; i < size; i++)
   data[i] = rand() / (float)RAND_MAX;
}

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


int main( int argc, char* argv[] )
{
    // Length of vectors
  int m = atoi(argv[4]);
	unsigned int n=(256*m);
//matrix variable
 // OpenCL device memory for matrices
   cl_mem d_A;
   cl_mem d_B;
   cl_mem d_C;
//	cl_kernel *kernel; 
    cl_platform_id* cpPlatform;        // OpenCL platform
    cl_device_id device_id;           // device ID
    cl_context context;               // context
    //cl_command_queue* queue;           // command queue
    cl_command_queue queue;           // command queue
	cl_program program;               // program
cl_platform_id* platforms;		// platform id,
// differnt for all the device we have in the system
cl_uint platformCount; //keeps the divice count

 
    size_t globalSize, localSize; //similar to cuda
    cl_int err;//for errors
    int workgrp;
    int wrkitm;
    int num_ker;
    num_ker=atoi(argv[2]);
    wrkitm=atoi(argv[3]);// i have tried automating lots of data,
    // Number of work items in each local work group
    localSize = wrkitm ;
    // Number of total work items - localSize must be devisor
    globalSize = n;
//#############Matrix Multiplication Variables ###############
int WA,HA,WB,HB,WC,HC;
WA = n;
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
// 4. allocate host memory for the result C
   unsigned int size_C = WC * HC;
   unsigned int  mem_size_C = sizeof(float) * size_C;
   float* h_C = (float*) malloc(mem_size_C);
 // 2. initialize host memory
   randomInit(h_A, size_A);
   randomInit(h_B, size_B);
//######################## matrix done #######################
//mallocing for array of queues (break through)
//cl_command_queue * queue = (cl_command_queue *)malloc(num_ker * sizeof(cl_command_queue));
cl_kernel *kernel=(cl_kernel *)malloc(num_ker * sizeof(cl_kernel));
//cl_program *program=(cl_program *)malloc(num_ker * sizeof(cl_kernel));
//defining platform
 clGetPlatformIDs(0, NULL, &platformCount);
    cpPlatform = (cl_platform_id*) malloc(sizeof(cl_platform_id) * platformCount);
clGetPlatformIDs(platformCount, cpPlatform, NULL);//what ever is returned from last step will be used here

int choice = atoi(argv[1]);
if(choice ==1)
{
// we can have CL_DEVICE_GPU or ACCELERATOR or ALL as an option here
// we can these multiple times depending on requirements
    err = clGetDeviceIDs(cpPlatform[0],CL_DEVICE_TYPE_CPU , 1, &device_id, NULL);
    if (err != CL_SUCCESS)
    
        printf("Error: Failed to create a device group!\n");
}

else
{
    // Get ID for the device
    err = clGetDeviceIDs(cpPlatform[1], CL_DEVICE_TYPE_GPU, 1, &device_id, NULL);

    if (err != CL_SUCCESS)

    {

        printf("Error: Failed to create a device group!\n");
}
}
    context = clCreateContext(0, 1, &device_id, NULL, NULL, &err);
//malloc file and kernel variable
char *file;
char *KernelSource;

    queue = clCreateCommandQueue(context, device_id, 0, &err);
        file="matxm.cl";
        KernelSource =  load_program_source(file);
	// Create the compute program from the source buffer
    program = clCreateProgramWithSource(context, 1,
                            (const char **) & KernelSource, NULL, &err);
    // Build the program executable
    clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
for (i=0;i<num_ker;i++)
{    
// Create the compute kernel in the program we wish to run
    kernel[i] = clCreateKernel(program, file, &err);
 }
//matrix start 
d_C = clCreateBuffer(context, CL_MEM_READ_WRITE,
          mem_size_A, NULL, &err);
   d_A = clCreateBuffer(context,
          CL_MEM_READ_WRITE,
          mem_size_A, h_A, &err);
   d_B = clCreateBuffer(context,
          CL_MEM_READ_WRITE,
          mem_size_B, h_B, &err);
//matrix finish
 err = clEnqueueWriteBuffer(queue, d_A, CL_TRUE, 0,mem_size_A, h_A, 0, NULL, NULL);
err = clEnqueueWriteBuffer(queue, d_B, CL_TRUE, 0,mem_size_B, h_B, 0, NULL, NULL);
 //size_t localWorkSize[2], globalWorkSize[2];
for(i=0;i<num_ker;i++)
{
   int wA = WA;
   int wC = WC;
   err = clSetKernelArg(kernel[i], 0,
              sizeof(cl_mem), (void *)&d_C);
   err = clSetKernelArg(kernel[i], 1,
              sizeof(cl_mem), (void *)&d_A);
   err = clSetKernelArg(kernel[i], 2,
              sizeof(cl_mem), (void *)&d_B);
   err = clSetKernelArg(kernel[i], 3,
              sizeof(int), (void *)&wA);
   err = clSetKernelArg(kernel[i], 4,
              sizeof(int), (void *)&wC);

}

  /*  // Set the arguments to our compute kernel
    err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &d_a);
    err = clSetKernelArg(kernel, 1, sizeof(cl_mem), &d_b);
    err = clSetKernelArg(kernel, 2, sizeof(cl_mem), &d_c);
    err = clSetKernelArg(kernel, 3, sizeof(unsigned int), &n);
  // Get the maximum work group size for executing the kernel on the device
    if (err != CL_SUCCESS)
    {
        printf("Error: Failed to retrieve kernel work group info! %d\n", err);
        exit(1);
    }
    */
//struct timeval tim;
  //double t1,t2;

    //gettimeofday(&tim, NULL);
    //t1=tim.tv_sec+(tim.tv_usec/1000000.0);

//need to work on work size#############################
for(i=0;i<num_ker;i++)
{
err = clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &globalSize, &localSize,
                                                              0, NULL, NULL);




err = clEnqueueReadBuffer(queue,
              d_C, CL_TRUE, 0, mem_size_C,
              h_C, 0, NULL, NULL);
   }
clFinish(queue);
    // release OpenCL resources
    free(h_A);
   free(h_B);
   free(h_C);

   clReleaseMemObject(d_A);
   clReleaseMemObject(d_C);
   clReleaseMemObject(d_B);
   clReleaseProgram(program);
   // clReleaseKernel(kernel);
for(i=0;i<num_ker;++i)
{
    clReleaseKernel(kernel[i]);
}
    clReleaseContext(context);
 
    clReleaseCommandQueue(queue);
 
    return 0;
}
