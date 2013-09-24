/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*
 *
 *  (C) 2004 by University of Chicago.
 *      See COPYRIGHT in top-level directory.
 */

#ifndef MLIFE_H
#define MLIFE_H

#include "mlifeconf.h"

#if 0
extern void   srand48();
extern double drand48();
extern char * malloc();
#endif

extern char *optarg;

typedef struct {
    MPI_Comm comm;         /* Communicator for processor mesh */
    int patchI, patchJ;    /* (I,J) location of patch in processor mesh */
    int pNI, pNJ;          /* Size of processor mesh */
    int left, right, up, down;  /* Neighbors to this patch: left = (I,J-1),
				   up = (I-1,J), etc.  (standard matrix 
				   ordering) */
    int ul, ur, ll, lr;    /* Upper left, upper right, lower left, 
			      lower right (needed for one option of the
			      9 point stencil) */
    int gNI, gNJ;          /* Full size of data mesh */
    int gI, gJ;            /* Global I,J for the upper left corner of the 
			      local patch */
    int lni, lnj;          /* Size of local patch */
} MLIFEPatchDesc;

typedef struct {
    double packtime, unpacktime; /* Time to pack/unpack data if separate */
    double exchtime;             /* Time for exchange */
    double itertime;             /* Time for the iteration loop */
} MLIFETiming;

typedef struct {
    int gNI, gNJ;          /* Size of global mesh */
    int pNI, pNJ;          /* Size of processor mesh */
    int nIter;             /* Number of iterations */
    int restartIter;       /* Used to determine when to create restart files */
    int verbose;           /* Whether verbose output used */
    int doIO;              /* Whether I/O used */
    char prefix[64];       /* Name for output file prefix */
} MLIFEOptions;

int MLIFE_ParseArgs( int argc, char **argv, MLIFEOptions *options );

int MLIFE_PatchCreateProcessMesh( MLIFEOptions *options, 
				  MLIFEPatchDesc *patch );
int MLIFE_PatchCreateProcessMeshWithCart( MLIFEOptions *options, 
					  MLIFEPatchDesc *patch );
int MLIFE_PatchCreateDataMeshDesc( MLIFEOptions *options,
				   MLIFEPatchDesc *patch );
int MLIFE_AllocateLocalMesh( MLIFEPatchDesc *patch, int ***m1, int ***m2 );
int MLIFE_FreeLocalMesh( MLIFEPatchDesc *patch, int **m1, int **m2 );
int MLIFE_InitLocalMesh( MLIFEPatchDesc *patch, int **m1, int **m2 );
int MLIFE_TimeIterations( MLIFEPatchDesc *patch, int nIter, int doCheck,
			  int **m1, int **m2, 
	  int (*exchangeInit)( MLIFEPatchDesc *, int**, int **, void *), 
	  int (*exchange)( MLIFEPatchDesc *, int **, MLIFETiming *, void *), 
			  int (*exchangeEnd)( void * ),
			  MLIFETiming *timedata );
void MLIFE_Abort( const char str[] );


/* pt-2-pt with isend/irecv */
int MLIFE_ExchangeInitPt2pt( MLIFEPatchDesc *patch, 
			     int **m1, int **m2, void *privateData );
int MLIFE_ExchangeEndPt2pt( void *privateData );
int MLIFE_ExchangePt2pt( MLIFEPatchDesc *patch, int **matrix, 
			 MLIFETiming *timedata, void *privateData );
/* pt-2-pt with send/irecv */
int MLIFE_ExchangeInitPt2ptSnd( MLIFEPatchDesc *patch, 
				int **m1, int **m2, void *privateData );
int MLIFE_ExchangeEndPt2ptSnd( void *privateData );
int MLIFE_ExchangePt2ptSnd( MLIFEPatchDesc *patch, int **matrix, 
			    MLIFETiming *timedata, void *privateData );

/* pt-2-pt with user pack/unpack */
int MLIFE_ExchangeInitPt2ptUV( MLIFEPatchDesc *patch, 
			       int **m1, int **m2, void *privateData );
int MLIFE_ExchangeEndPt2ptUV( void *privateData );
int MLIFE_ExchangePt2ptUV( MLIFEPatchDesc *patch, int **matrix, 
			   MLIFETiming *timedata, void *privateData );

/* RMA with Fence */
int MLIFE_ExchangeInitFence( MLIFEPatchDesc *patch, 
			     int **m1, int **m2, void *privateData );
int MLIFE_ExchangeEndFence( void *privateData );
int MLIFE_ExchangeFence( MLIFEPatchDesc *patch, int **matrix, 
			 MLIFETiming *timedata, void *privateData );

/* Pt-2-pt, for 9 point stencil, without the diagonal trick */
int MLIFE_ExchangeInitPt2pt9( MLIFEPatchDesc *patch, 
			      int **m1, int **m2, void *privateData );
int MLIFE_ExchangeEndPt2pt9( void *privateData );
int MLIFE_ExchangePt2pt9( MLIFEPatchDesc *patch, int **matrix, 
			  MLIFETiming *timedata, void *privateData );

#define BORN 1
#define DIES 0

#endif
