#include<stdlib.h>
#include<cuda_runtime.h>

typedef struct memoryPointer MemoryPointer;

struct memoryPointer{
  MemoryPointer *ptr;
  unsigned size;
  unsigned *data;
};

static MemoryPointer base;
static MemoryPointer *freep = NULL;

int CHUNK_SIZE=2048;
int headerSize=16;
int MIN_BULK_AMOUNT = 1000000; //2^20 ~1million

void gemtcAddList(MemoryPointer *bp){
  MemoryPointer *p;
  // printf("start\n");
  //freep start of list of free memory
    for(p = freep; (bp->data < p->data || bp->data > (p->ptr)->data); p = p->ptr){
  //  for(p = freep; !(bp->data > p->data && bp->data < (p->ptr)->data); p = p->ptr){
      //printf("in for p:%p  bp:%p\n", p->data, bp->data);
    if(p->data >= (p->ptr)->data && (bp->data > p->data || bp->data < (p->ptr)->data)){
      // printf("break\n");
      break;
    }
  }
  if(bp->data==p->data)return; //memory is freed twice
                               // This is a bad patch for the problem

    // printf("step 1\n");
  if( (((char *)bp->data) + bp->size) == (char *)p->ptr->data){
    // printf("step 1 else\n");
    bp->size += (p->ptr)->size;
    bp->ptr = (p->ptr)->ptr;
    cudaSafeMemcpy(bp->data, &bp->size, sizeof(unsigned), cudaMemcpyHostToDevice,
                   stream_dataIn, "Merging freed memory in old block");
    // printf("step 2\n");
    if(p->ptr != &base)free(p->ptr);
  }else
    bp->ptr = p->ptr;

  if( (((char *)p->data) + p->size) == (char *)bp->data){
    p->size += bp->size;
    p->ptr = bp->ptr;
    cudaSafeMemcpy(p->data, &p->size, sizeof(unsigned), cudaMemcpyHostToDevice,
	       stream_dataIn, "Merging old memory into new block");
    // printf("step 3\n");
    free(bp);
  }else
    p->ptr = bp;
  
  freep = p;
}

void gemtcFree(void *loc){
  loc = ((void *)(((char *)loc)-headerSize));
  MemoryPointer *v = (MemoryPointer *) malloc(sizeof(MemoryPointer));
  cudaSafeMemcpy(&v->size, loc, sizeof(unsigned), cudaMemcpyDeviceToHost,
                 stream_dataOut, "Reading size of freed memory");
  v->data = (unsigned *) loc;
  // printf("start add list\n");
  gemtcAddList(v);
  // printf("end add list\n");
}


static MemoryPointer *morecore(unsigned nu){
  void *cp;
  MemoryPointer *up = (MemoryPointer *)malloc(sizeof(MemoryPointer));
  if (nu < MIN_BULK_AMOUNT) nu = MIN_BULK_AMOUNT;
  cudaMalloc(&cp, nu);

  up->data = (unsigned *)cp;

  up->size = nu;
  cudaSafeMemcpy(cp,&nu,sizeof(unsigned),cudaMemcpyHostToDevice,
		 stream_dataIn, "Writing size of new block from cudaMalloc");

  gemtcAddList(up);
  return freep;
}


void *gemtcMalloc(unsigned nbytes){
  MemoryPointer *p, *prevp;
  if ((prevp = freep)==NULL){
    base.ptr = freep = prevp = &base;
    base.size = 0;
  }
  nbytes+=headerSize;
  if(nbytes%CHUNK_SIZE!=0)nbytes+=(CHUNK_SIZE-nbytes%CHUNK_SIZE);
  char *loc;
  for(p = prevp->ptr; ;prevp = p, p = p->ptr){
    if(p->size >= nbytes){
      if(p->size == nbytes){
        prevp->ptr = p->ptr;
        loc = (char *) p->data;
        free(p);
      }else{
        p->size -= nbytes;
        loc =((char *) p->data)+p->size;
      }
      freep = prevp;
      cudaSafeMemcpy(loc,&nbytes,sizeof(unsigned),cudaMemcpyHostToDevice,
                     stream_dataIn, "Writing size on newly allocated memory");
      return (void *)(loc+headerSize);
    }
    if (p == freep)
      if((p = morecore(nbytes))==NULL)
        return NULL;
  }
}

