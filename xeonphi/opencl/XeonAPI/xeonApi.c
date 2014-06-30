#include "xeonApi.h"
#include "super_kernel.h"
#include "QueueJob.h"
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <CL/opencl.h>

void XEON_gemtcInitialize()
{
//initialize all the opencl variables
//bind connect blah blah for opencl
// now it will have gpu, later it wud be accelarator
}

//dummy setup api
void XEON_gemtcSetup(int Queuesize, int workers)
{
// we need to make super kernels before doing anything here.
}
