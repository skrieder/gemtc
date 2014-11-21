#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <CL/opencl.h>
//#include "vectadd.cl"
//this funtion will load the main kernel
const char *KernelSource = "\n" \

"__kernel void vecAdd(                                                  \n"\
"   __global int *a,                                              \n" \
"   __global int* b,                                             \n" \
" __global int* c,						\n"\
"   const unsigned int n)                                           \n" \
"{                                                                      \n" \
"   int id = get_global_id(0);                                           \n" \
"   if(id < n)                                                       \n" \
"       c[id] = a[id] + b[id];                                \n" \
"}                                                                      \n" \

"\n";
/*char* load_program_source(const char *filename) {
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
 */

int main( int argc, char* argv[] )
{
//unsigned int n;
    // Length of vectors
  int m = atoi(argv[4]);
//struct timespec start, finish;
unsigned int n=(256*m);
    // Host input vectors
    int *h_a;
    int *h_b;
    // Host output vector
    int *h_c;
	double elapsed;
    // Device input buffers
    cl_mem d_a;
    cl_mem d_b;
    // Device output buffer
    cl_mem d_c;
	cl_kernel kernel; 
    cl_platform_id* cpPlatform;        // OpenCL platform
    cl_device_id device_id;           // device ID
    cl_context context;               // context
    //cl_command_queue* queue;           // command queue
    //cl_command_queue queue;           // command queue
    cl_program program;               // program
cl_platform_id* platforms;		// platform id,
// differnt for all the device we have in the system
cl_uint platformCount; //keeps the divice count

    // Size, in bytes, of each vector
    size_t bytes = n*sizeof(int);
 
    // Allocate memory for each vector on host
    h_a = (int*)malloc(bytes);
    h_b = (int*)malloc(bytes);
    h_c = (int*)malloc(bytes);
    // Initialize vectors on host
    int i;
    for( i = 0; i < n; i++ )
    {
        h_a[i] = i;
        h_b[i] = i;
//	printf("%d ",h_a[i]);
    }
 
    size_t globalSize, localSize; //similar to cuda
    cl_int err;//for errors
    int workgrp;
    int wrkitm;
    int num_ker;
    num_ker=atoi(argv[2]);
    wrkitm=atoi(argv[3]);// i have tried automating lots of data,
//u can check my bash script
    // Number of work items in each local work group
    localSize = wrkitm ;
//n=atoi(argv[1]);
    // Number of total work items - localSize must be devisor
    globalSize = n;
//mallocing for array of queues (break through)
cl_command_queue * queue = (cl_command_queue *)malloc(num_ker * sizeof(cl_command_queue));
//defining platform
 clGetPlatformIDs(0, NULL, &platformCount);
    cpPlatform = (cl_platform_id*) malloc(sizeof(cl_platform_id) * platformCount);
clGetPlatformIDs(platformCount, cpPlatform, NULL);//what ever is returned from last step will be used here

int choice = atoi(argv[1]);
if(choice ==1)
{
// we can have CL_DEVICE_GPU or ACCELERATOR or ALL as an option here
//depending what device are we working on
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

	for(i=0;i<num_ker;++i)
	{
    queue[i] = clCreateCommandQueue(context, device_id, 0, &err);
	}
    // Create the compute program from the source buffer
    program = clCreateProgramWithSource(context, 1,
                            (const char **) & KernelSource, NULL, &err);
    // Build the program executable
    clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
    // Create the compute kernel in the program we wish to run
    kernel = clCreateKernel(program, "vecAdd", &err);
 
    // Create the input and output arrays in device memory for our calculation
    d_a = clCreateBuffer(context, CL_MEM_READ_ONLY, bytes, NULL, NULL);
    d_b = clCreateBuffer(context, CL_MEM_READ_ONLY, bytes, NULL, NULL);
    d_c = clCreateBuffer(context, CL_MEM_WRITE_ONLY, bytes, NULL, NULL);
    //clock_gettime(CLOCK_MONOTONIC, &start);

	// Write our data set into the input array in device memory
	for(i=0;i<num_ker;++i)
{
    err = clEnqueueWriteBuffer(queue[i], d_a, CL_TRUE, 0,bytes, h_a, 0, NULL, NULL);
    err = clEnqueueWriteBuffer(queue[i], d_b, CL_TRUE, 0,bytes, h_b, 0, NULL, NULL);
}
//clFinish(queue);
	// i know.. way to many APIs to be called in OpenCL
    // Set the arguments to our compute kernel
    err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &d_a);
    err = clSetKernelArg(kernel, 1, sizeof(cl_mem), &d_b);
    err = clSetKernelArg(kernel, 2, sizeof(cl_mem), &d_c);
    err = clSetKernelArg(kernel, 3, sizeof(unsigned int), &n);
  // Get the maximum work group size for executing the kernel on the device
//localSize=256;
//  err = clGetKernelWorkGroupInfo(kernel, device_id, CL_KERNEL_WORK_GROUP_SIZE, sizeof(localSize), &localSize, NULL);
    if (err != CL_SUCCESS)
    {
        printf("Error: Failed to retrieve kernel work group info! %d\n", err);
        exit(1);
    }
// timer for my evalutation
//clock_t start=clock();

// clock_gettime(CLOCK_MONOTONIC, &start);
// kernel part
    // Execute the kernel over the entire range of the data set 
    
//printf("err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &globalSize, &localSize,0, NULL, NULL\n");

struct timeval tim;
  double t1,t2;

    gettimeofday(&tim, NULL);
    t1=tim.tv_sec+(tim.tv_usec/1000000.0);

for(i=0;i<num_ker;i++)
{
err = clEnqueueNDRangeKernel(queue[i], kernel, 1, NULL, &globalSize, &localSize,
                                                              0, NULL, NULL);


}
gettimeofday(&tim, NULL);
    t2=tim.tv_sec+(tim.tv_usec/1000000.0);
printf("GPU time %.4lf\t",(t2-t1));

// Wait for the command queue to get serviced before reading back results

    //clock_gettime(CLOCK_MONOTONIC, &finish);
    //elapsed = (finish.tv_sec - start.tv_sec);
    //elapsed += (finish.tv_nsec - start.tv_nsec)/ 1000000.0;
 //clock_t finish =clock();

    // Read the results from the device

for(i=0;i<num_ker;++i)
{
clEnqueueReadBuffer(queue[i], d_c, CL_TRUE, 0,
                                bytes, h_c, 0, NULL, NULL );    
}  
//clock_gettime(CLOCK_MONOTONIC, &finish);
  //elapsed = (finish.tv_nsec - start.tv_nsec);
  //  elapsed += (finish.tv_nsec - start.tv_nsec)/ 1000000.0;
for(i=0;i<num_ker;++i)
{
clFinish(queue[i]);
}
    //Sum up vector c and print result divided by n, this should equal 1 within error
//int threads=globalSize/localSize;    
//double sum = 0;
  //  for(i=0; i<n; i++)
//       printf("%d ", h_c[i]);
//elapsed=(start-finish)/CLOCKS_PER_SEC;
//printf("%d",globalSize);
//printf("/%d ",localSize);
//printf("threads = %d \n",threads);
//    printf("Time taken by GPU in MicroSec = %.6le\n ",elapsed);
 
    // release OpenCL resources
    clReleaseMemObject(d_a);
    clReleaseMemObject(d_b);
    clReleaseMemObject(d_c);
    clReleaseProgram(program);
    clReleaseKernel(kernel);
for(i=0;i<num_ker;++i)
    clReleaseCommandQueue(queue[i]);
    clReleaseContext(context);
 
    //release host memory
    free(h_a);
    free(h_b);
    free(h_c);
 
    return 0;
}
