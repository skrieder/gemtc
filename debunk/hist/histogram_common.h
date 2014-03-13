#ifndef HISTOGRAM_COMMON_H
#define HISTOGRAM_COMMON_H

////////////////////////////////////////////////////////////////////////////////
// Common definitions
////////////////////////////////////////////////////////////////////////////////
#define HISTOGRAM64_BIN_COUNT 64
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

//Threadblock size: must be a multiple of (4 * SHARED_MEMORY_BANKS)
//because of the bit permutation of threadIdx.x
#define HISTOGRAM64_THREADBLOCK_SIZE (4 * SHARED_MEMORY_BANKS)

//Warps ==subhistograms per threadblock
#define WARP_COUNT 6

#define UMUL(a, b) ( (a) * (b) )
#define UMAD(a, b, c) ( UMUL((a), (b)) + (c) )

////////////////////////////////////////////////////////////////////////////////
// Reference CPU histogram
////////////////////////////////////////////////////////////////////////////////
extern "C" void histogram64CPU(
    uint *h_Histogram,
    void *h_Data,
    uint byteCount
);


////////////////////////////////////////////////////////////////////////////////
// GPU histogram
////////////////////////////////////////////////////////////////////////////////
extern "C" void initHistogram64(void);
extern "C" void closeHistogram64(void);
extern "C" void histogram64(
    uint *d_Histogram,
    void *d_Data,
    uint byteCount
);


#endif

