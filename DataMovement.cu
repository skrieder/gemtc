

int first = 1;
void synchronizeAndPrint(cudaStream_t stream, char *s){
  cudaError_t e = cudaStreamSynchronize(stream);
  if(e!=cudaSuccess){
    //if(first){printf("CUDA Error:   %s   at %s\n", cudaGetErrorString( e ), s);first=0;}
    first=0;
    printf("CUDA Error:   %s   at %s\n", cudaGetErrorString( e ), s);
  }
}


void cudaSafeMemcpy(void *destination, void *source, int size, enum cudaMemcpyKind direction, cudaStream_t stream, char *errorStatement)
{
  //Get Lock
  pthread_mutex_lock(&memcpyLock);

  //Memcpy
  cudaMemcpyAsync(destination, source, size, direction, stream);

  //Synchronize and Print Errors
  synchronizeAndPrint(stream, errorStatement);

  //Release Lock
  pthread_mutex_unlock(&memcpyLock);
}



