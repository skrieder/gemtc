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
/////////////////////////////////////////////////////////
// Program main
/////////////////////////////////////////////////////////
 
int main(int argc, char* argv[])
{
int num_ker=0;
num_ker=atoi(argv[2]);
struct timeval tim,ftim;
  double t1,t2,tim1,tim2;

//    gettimeofday(&tim, NULL);
  //  t1=tim.tv_sec+(tim.tv_usec/1000000.0);
    gettimeofday(&ftim, NULL);
    tim1=ftim.tv_sec+(ftim.tv_usec/1000000.0);
 
 
   // 5. Initialize OpenCL
   // OpenCL specific variables
   cl_context clGPUContext;
   cl_command_queue clCommandQue;
   cl_program clProgram;
//   cl_kernel clKernel;
cl_kernel *clKernel=(cl_kernel *)malloc(num_ker *sizeof(cl_kernel));
cl_platform_id* cpPlatform;        // OpenCL platform
cl_uint platformCount; //keeps the divice count
  
   cl_int errcode;
 
   // OpenCL device memory for matrices
  // cl_mem d_A;
  // cl_mem d_B;
 
clGetPlatformIDs(0, NULL, &platformCount);
    cpPlatform = (cl_platform_id*) malloc(sizeof(cl_platform_id) * platformCount);
clGetPlatformIDs(platformCount, cpPlatform, NULL);//what ever is returned from last step will be used here

cl_device_id device_id;
 // 7. Launch OpenCL kernel
   size_t localWorkSize, globalWorkSize;

int value;
value =atoi(argv[3]);// should be 1 ?
   localWorkSize = value ;
   globalWorkSize=atoi(argv[4]);
	int n = atoi(argv[4]);
char *file="sleep.cl";
        char *KernelSource =  load_program_source(file);

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

//for(i=0;i<num_ker;i++){
//queue
   clCommandQue = clCreateCommandQueue(clGPUContext, 
                  device_id, 0, &errcode);
//program
   clProgram = clCreateProgramWithSource(clGPUContext, 
                1, (const char **) & KernelSource, 
                NULL, &errcode);

   errcode = clBuildProgram(clProgram, 0, 
              NULL, NULL, NULL, NULL);
   //shrCheckError(errcode, CL_SUCCESS);
for(i=0;i<num_ker;i++)
{
   clKernel[i] = clCreateKernel(clProgram, 
               "sleep", &errcode);
 }
  //shrCheckError(errcode, CL_SUCCESS);
	 int *h_A;// n=atoi(argv[4]);// A for sleep time, B for results may be
  // Setup device memoryi
	cl_mem d_A;
	h_A = (int *)malloc(n*sizeof(int));
/*   d_A = clCreateBuffer(clGPUContext,
          CL_MEM_READ_WRITE,
          sizeof(int), h_A, &errcode);
   d_B = clCreateBuffer(clGPUContext,
          CL_MEM_READ_WRITE,
          sizeof(int), h_B, &errcode);*/
	int i;
	for( i=0; i< n; i++)
	h_A[i]=i*i;
     // Write our data set into the input array in device memory
	
	d_A = clCreateBuffer(clGPUContext, CL_MEM_READ_ONLY, n*sizeof(int), h_A, NULL);
for(i=0;i<num_ker;i++)
{

   errcode = clEnqueueWriteBuffer(clCommandQue, d_A, CL_TRUE, 0,n*sizeof(int), h_A, 0, NULL, NULL);


   errcode = clSetKernelArg(clKernel[i], 0, 
              n*sizeof(int),(void *)&h_A);
   errcode = clSetKernelArg(clKernel[i], 1, 
              sizeof(unsigned int),(void *)&n);

// clock_gettime(CLOCK_MONOTONIC, &start);
}
 gettimeofday(&tim, NULL);
    t1=tim.tv_sec+(tim.tv_usec/1000000.0);

for(i=0;i<num_ker;i++){
   errcode = clEnqueueNDRangeKernel(clCommandQue, 
              clKernel[i], 1, NULL, &globalWorkSize, 
              &localWorkSize, 0, NULL, NULL);
}
  // shrCheckError(errcode, CL_SUCCESS);
 // clock_gettime(CLOCK_MONOTONIC, &finish);
   //     elapsed = (finish.tv_sec - start.tv_sec);
     //   elapsed += (finish.tv_nsec - start.tv_nsec)/ 1000.0;
  
gettimeofday(&tim, NULL);
    t2=tim.tv_sec+(tim.tv_usec/1000000.0);
printf("%.6lf\t",(t2-t1));

//printf("Work Item/threads = %d \n",value);
//printf("time microsecond GPU = %le\n ",elapsed);

 
   // 8. Retrieve result from device

//for(i=0;i<num_ker;i++)
/*{
   errcode = clEnqueueReadBuffer(clCommandQue, 
              d_B, CL_TRUE, 0, sizeof(unsigned int), 
              h_B, 0, NULL, NULL);
   //shrCheckError(errcode, CL_SUCCESS);
//}*/
//for(i=0;i<num_ker;i++)
//{
 clFinish(clCommandQue);


   // 10. clean up memory
//   free(h_A);
  // free(h_B);
  
 
  // clReleaseMemObject(d_A);
  // clReleaseMemObject(d_B);

 
//   free(device_id);
 free(KernelSource);
   clReleaseContext(clGPUContext);
for(i=0;i<num_ker;i++)
   clReleaseKernel(clKernel[i]);
   clReleaseProgram(clProgram);
//for(i=0;i<num_ker;i++)
   clReleaseCommandQueue(clCommandQue);
gettimeofday(&ftim, NULL);
    tim2=ftim.tv_sec+(ftim.tv_usec/1000000.0);
printf("%.6lf\t",(tim2-tim1));
printf("\n");

exit(0);
}

