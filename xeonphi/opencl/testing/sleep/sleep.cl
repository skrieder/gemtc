// OpenCL Kernel
__kernel void
sleep(__global unsigned int a, __global unsigned int b)
{
	b=0;
   int tx = get_global_id(0); 
	while(tx<a)
	b=b+1; 

}
