// OpenCL Kernel
__kernel void
sleep(__global int *a, __global unsigned int n)
{
	int b=1,c=1,d=1,id,i=1;
   	id = get_global_id(0);

	while(i<n){
	b=a[id+i]*b;
	b=b+1;
	b=c+b/(c*d);
	d=c*b/(c+d);
	 b=b+1;
        b=c+b/(c*d);
        d=c*b/(c+d);
	 b=b+1;
        b=c+b/(c*d);
        d=c*b/(c+d);
	i++;	 
}
}
