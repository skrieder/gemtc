#include<stdlib.h>
#include<cuda_runtime.h>

/*
This file contains the SubAllocator for Gemtc

The purpose of the suballocator is to allow efficient mallocs and
frees of global memory from the Host

cudaMalloc gets poor performance, so this will use cudaMalloc to
get a large block of memory and sub-divide it as mallocs are needed


Model:
A circular linked list of free memory blocks is kept in host memory
The elements of this list are kept in order of increasing device addr

When memory is allocated, a header is written infront of it with its
size information. Beyond this, mallocs are not tracked.

When memory is malloced, an existing node will removed or have its
size reduced.

When memory is freed, an existing is extended if its adjacent to the
new memory, or a new node is created and inserted in order.

NOTE: Currently malloc and free must search the linked list, which 
      may be O(n). A future work is to change the data structure to
      get O(log(n)) scaling.
 */



pthread_mutex_t memoryListLock;

typedef struct memoryPointer MemoryPointer;

//The struct for a node of the memory linked list
struct memoryPointer{
  MemoryPointer *ptr;
  unsigned size;
  unsigned *data;
};

static MemoryPointer base;

//A pointer to somewhere in the list
static MemoryPointer *freep = NULL;

//All memory is allocated in mulitples of this amount
int CHUNK_SIZE=1024;
//This is the size of the header infront of each malloc
int headerSize=8;

//Minimum size that will be malloced from CUDA when more
//  memory is needed
int MIN_BULK_AMOUNT = 10000000; //~10million


//Adds a node to the list of memory, or merges it with a node that is
//  its precessor or succesor
void gemtcAddList(MemoryPointer *bp){
  MemoryPointer *p;
  //freep start of list of free memory
  for(p = freep; (bp->data < p->data || bp->data > (p->ptr)->data); p = p->ptr){
     if(p->data >= (p->ptr)->data && (bp->data > p->data || bp->data < (p->ptr)->data)){
       break;
     }
  }
  if( (((char *)bp->data) + bp->size) == (char *)p->ptr->data){
    bp->size += (p->ptr)->size;
    bp->ptr = (p->ptr)->ptr;
    if(p->ptr != &base){
      free(p->ptr);
    }
  }else
    bp->ptr = p->ptr;

  if( (((char *)p->data) + p->size) == (char *)bp->data){
    p->size += bp->size;
    p->ptr = bp->ptr;
    free(bp);
  }else{
    p->ptr = bp;
  }
  freep = p;
}

//This will read the size information of the memory, create a node
// for the memory and hand it off the gemtcAddList(..)
void gemtcFree(void *loc){
  pthread_mutex_lock(&memoryListLock);

  loc = ((void *)(((char *)loc)-headerSize));
  MemoryPointer *v = (MemoryPointer *) malloc(sizeof(MemoryPointer));
  cudaSafeMemcpy(&v->size, loc, sizeof(unsigned), cudaMemcpyDeviceToHost,
                 stream_dataOut, "Reading size of freed memory");
  
  v->data = (unsigned *) loc;

  gemtcAddList(v);

  pthread_mutex_unlock(&memoryListLock);
}

//This is called by malloc when more memory is needed
//It will call cudaMalloc then hand it off to gemtcAddList to
//  Add the new memory to the list
static MemoryPointer *morecore(unsigned nu){
  void *cp;
  MemoryPointer *up = (MemoryPointer *)malloc(sizeof(MemoryPointer));
  if (nu < MIN_BULK_AMOUNT) nu = MIN_BULK_AMOUNT;
  cudaMalloc(&cp, nu);

  up->data = (unsigned *)cp;

  up->size = nu;

  gemtcAddList(up);
  return freep;
}

//Searches the list for a large enough block of consecutive memory
//If none are found, manycore() wil be called to get a large 
//  enough block
void *gemtcMalloc(unsigned nbytes){
  pthread_mutex_lock(&memoryListLock);
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
      pthread_mutex_unlock(&memoryListLock);
 
      return (void *)(loc+headerSize);
    }
    if (p == freep){
      if((p = morecore(nbytes))==NULL){
        pthread_mutex_unlock(&memoryListLock);
	return NULL;
      }
    }
  }
}

