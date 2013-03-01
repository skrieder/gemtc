

void matrixMultiply(void *params){
  int side = *((int *)params);
  float *A = (float *)(((char *)params) + sizeof(int));
  float *B = (float *)(((char *)params) + sizeof(int) +side*sizeof(float));
  float *C = (float *)(((char *)params) + sizeof(int) +2*side*sizeof(float));

  int i, j , k;
  for(i=0; i<side; i++){
    for(j=0; j<side; j++){
      float temp=0;
      for(k=0; k<side; k++)temp+= A[i+side*k]*B[k+side*j];
      C[i+side*j]=temp;
    }
  }
}
