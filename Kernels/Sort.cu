//This micro-kernel currently does not use shared memory
//It could be improved by adding this caching.

//This micro-kernel currently uses a selection sort.
//This is done for simplicity of testing and should be replaced
//  before using it for serious testing with a better sort.

__device__ void Sort( void* param)
{
    float* paramIn = (float*)param;
    int N = (int)(*paramIn);
    float* a  = paramIn+1;  //input data, will currently be trashed
    float* b  = a + N*sizeof(float); //location for result array

    int warp_size = 32;
    int tid = threadIdx.x%warp_size;

    float *sub = a + tid*N/warp_size;  //Sub list that each warp will sort
    
    //Selection Sort, eventually do Merge or something faster
    int i, j;
    for(i=0; i<N/warp_size-1; i++){
      //Find min is remaining list
      int min = i;
      for(j=i+1; j<N/warp_size; j++){
        if(sub[j]<sub[min])min = j;
      }
      //Swap ith place with min
      float temp = sub[i];
      sub[i]=sub[min];
      sub[min]=temp;
    }

    //Merge loops
    int subs;  //number of sub lists I currently have
    for(subs=warp_size; subs!=1; subs=subs/2){
      if(tid<subs/2){
        //Merge our two lists
        int sub_size = N/subs;
        float *sub1 = a + 2*tid*sub_size;
        float *sub2 = sub1 + sub_size;
        
        float *ret = b + 2*tid*sub_size;
        
        //Merge our two lists into their location in ret
        int p1 = 0;  //place in first list
        int p2 = 0;  //place in second list
        int cur= 0;
        while(p1<sub_size && p2<sub_size){
          if(sub1[p1]<sub[p2]){
            ret[cur++] = sub1[p1++];
          }else{
            ret[cur++] = sub2[p2++];
          }
        }
        //Copy any elements left in our lists after the first list runs out
        while(p1<sub_size) ret[cur++]=sub1[p1++];
        while(p2<sub_size) ret[cur++]=sub2[p2++];

        int k;
        for(k=0;k<2*sub_size;k++)sub1[k]=ret[k];
      }
      /*      //Copy the now sorted sub arrays back into sub to be merged again
      int k;
      for(k=tid; k<N; k+=warp_size) a[k]=b[k];
      */
    }
}
