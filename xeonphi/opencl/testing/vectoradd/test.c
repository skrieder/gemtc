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
//this will load the main kernel
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
    unsigned int n = 10;
struct timespec start, finish;

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
 
    cl_platform_id cpPlatform;        // OpenCL platform
    cl_device_id device_id;           // device ID
    cl_context context;               // context
    cl_command_queue queue;           // command queue
    cl_program program;               // program
    cl_kernel kernel;                 // kernel
 
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
    }
 
    size_t globalSize, localSize;
    cl_int err;
 int workgrp;
int wrkitm;
//wrkitm=atoi(argv[1]);
    // Number of work items in each local work group
//    localSize = wrkitm ;
//workgrp=atoi(argv[2]);
    // Number of total work items - localSize must be devisor
    globalSize = n;//ceil(n/(float)localSize)*localSize;
//cl_uint platformCount;
//cl_platform_id* platforms;
 //clGetPlatformIDs(0, NULL, &platformCount);
//	    platforms = (cl_platform_id*) malloc(sizeof(cl_platform_id) * platformCount);
//	    clGetPlatformIDs(platformCount, platforms, NULL);
//printf("%d",platformCount);
    // Bind to platform
    err = clGetPlatformIDs(1, &cpPlatform, NULL);
    // Get ID for the device
    err = clGetDeviceIDs(NULL, CL_DEVICE_TYPE_CPU, 1, &device_id, NULL);
    if (err != CL_SUCCESS)

    {

        printf("Error: Failed to create a device group!\n");
}
    // Create a context 
    context = clCreateContext(0, 1, &device_id, NULL, NULL, &err);
if (!context)
    
        printf("Error: Failed to create a compute context!\n");
    
// Create a command queue
    queue = clCreateCommandQueue(context, device_id, 0, &err);
//loading external cl file
 const char *file="vectadd.cl";
const char *kernelSource =  load_program_source(file);
    // Create the compute program from the source buffer
    program = clCreateProgramWithSource(context, 1,
                            (const char **) & kernelSource, NULL, &err);
    // Build the program executable
    clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
 
    // Create the compute kernel in the program we wish to run
    kernel = clCreateKernel(program, "vecAdd", &err);
 
    // Create the input and output arrays in device memory for our calculation
    d_a = clCreateBuffer(context, CL_MEM_READ_ONLY, bytes, NULL, NULL);
    d_b = clCreateBuffer(context, CL_MEM_READ_ONLY, bytes, NULL, NULL);
    d_c = clCreateBuffer(context, CL_MEM_WRITE_ONLY, bytes, NULL, NULL);
    // Write our data set into the input array in device memory
    err = clEnqueueWriteBuffer(queue, d_a, CL_TRUE, 0,bytes, h_a, 0, NULL, NULL);
    err = clEnqueueWriteBuffer(queue, d_b, CL_TRUE, 0,bytes, h_b, 0, NULL, NULL);
clFinish(queue);
    // Set the arguments to our compute kernel
    err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &d_a);
    err = clSetKernelArg(kernel, 1, sizeof(cl_mem), &d_b);
    err = clSetKernelArg(kernel, 2, sizeof(cl_mem), &d_c);
    err = clSetKernelArg(kernel, 3, sizeof(unsigned int), &n);
 clock_gettime(CLOCK_MONOTONIC, &start);
    // Execute the kernel over the entire range of the data set 
    err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &globalSize, &localSize,
                                                              0, NULL, NULL);

 clock_gettime(CLOCK_MONOTONIC, &finish);
        elapsed = (finish.tv_sec - start.tv_sec);
        elapsed += (finish.tv_nsec - start.tv_nsec)/ 1000000000.0;
 
    // Wait for the command queue to get serviced before reading back results
    clFinish(queue);
    // Read the results from the device
    clEnqueueReadBuffer(queue, d_c, CL_TRUE, 0,
                                bytes, h_c, 0, NULL, NULL );
 clFinish(queue);

    //Sum up vector c and print result divided by n, this should equal 1 within error
    double sum = 0;
    for(i=0; i<n; i++)
        sum += h_c[i];
printf("Work Item/threads = %d \n",wrkitm);
printf("time taken by GPU = %le\n ",elapsed);
 
    // release OpenCL resources
    clReleaseMemObject(d_a);
    clReleaseMemObject(d_b);
    clReleaseMemObject(d_c);
    clReleaseProgram(program);
    clReleaseKernel(kernel);
    clReleaseCommandQueue(queue);
    clReleaseContext(context);
 
    //release host memory
    free(h_a);
    free(h_b);
    free(h_c);
 
    return 0;
}
