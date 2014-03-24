#ifndef HISTOGRAM_COMMON_H
#define HISTOGRAM_COMMON_H

////////////////////////////////////////////////////////////////////////////////
// Common definitions
////////////////////////////////////////////////////////////////////////////////
#define HISTOGRAM256_BIN_COUNT 256
#define UINT_BITS 32
typedef unsigned int uint;
typedef unsigned char uchar;

////////////////////////////////////////////////////////////////////////////////
// GPU-specific common definitions
////////////////////////////////////////////////////////////////////////////////
#define LOG2_WARP_SIZE 5U
#define WARP_SIZE (1U << LOG2_WARP_SIZE)

//May change on future hardware, so better parametrize the code
#define SHARED_MEMORY_BANKS 16

//Warps ==subhistograms per threadblock
#define WARP_COUNT 1 

//Threadblock size
#define HISTOGRAM256_THREADBLOCK_SIZE (WARP_COUNT * WARP_SIZE)

#define PARTIAL_HISTOGRAM256_COUNT 240
//Shared memory per threadblock
#define HISTOGRAM256_THREADBLOCK_MEMORY (WARP_COUNT * HISTOGRAM256_BIN_COUNT)

#define UMUL(a, b) ( (a) * (b) )
#define UMAD(a, b, c) ( UMUL((a), (b)) + (c) )

// GPU histogram
extern "C" void initHistogram256(void);
extern "C" void closeHistogram256(void);

extern "C" void histogram256(
    uint *d_Histogram,
    void *d_Data,
    uint byteCount
);

#endif
