//OpenCL kernel. Each work item takes care of one element of c

__kernel void vecAdd(  __global int *a,                       
                       __global int *b,                       
                       __global int *c,                       
                       const unsigned int n)                   
{                                                               
    //Get our global thread ID                                  
    int id = get_global_id(0);                                  
    //Make sure we do not go out of bounds                     
    if (id < n)                                                 
        c[id] = a[id] + b[id];                                  
}                                                             
