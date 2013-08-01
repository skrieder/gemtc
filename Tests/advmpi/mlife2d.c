/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*
 *  (C) 2013 by University of Chicago.
 *      See COPYRIGHT in top-level directory.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mpi.h>

#include "mlife2d.h"
#include "mlife-io.h"

static int verbose = 0;

int main(int argc, char *argv[])
{
    int            rank, provided;
    MLIFEPatchDesc patch;
    MLIFEOptions   options;
    MLIFETiming    timedataPt2pt, timedataPt2ptSnd, timedataPt2ptUv,
	timedataFence, timedataPt2pt9;
    int            **m1, **m2;
    int            kk, commtype;
    const char     *commstr = 0;
    int doCheckpoint = 0;
  
    MPI_Init_thread(&argc, &argv,MPI_THREAD_SINGLE,&provided);

    MLIFE_ParseArgs(argc, argv, &options);
    verbose      = options.verbose;
    doCheckpoint = options.doIO;

    MLIFEIO_Init(MPI_COMM_WORLD);

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    for (commtype=0; commtype<2; commtype++) {
	/* Create the communicator, including determining the coordinates
	   of the "patch" that this process owns, and the decompostion 
	   of the domain */
	switch (commtype) {
	case 0:
	    MLIFE_PatchCreateProcessMesh( &options, &patch );
	    commstr = "COMM_WORLD";
	    break;
	case 1:
	    MLIFE_PatchCreateProcessMeshWithCart( &options, &patch );
	    commstr = "CART_CREATE";
	    break;
	default:
	    fprintf( stderr, "Internal error - commtype = %d\n", commtype );
	    MPI_Abort( MPI_COMM_WORLD, 1 );
	}
	MLIFE_PatchCreateDataMeshDesc( &options, &patch );

	if (verbose) {
	    printf( "[%d] Proc with %s is [%d,%d] in [%d,%d], mesh [%d,%d]x[%d,%d] within [%d,%d]\n",
		    rank, commstr,
		    patch.patchI, patch.patchJ, patch.pNI, patch.pNJ,
		    patch.gI, patch.gI+patch.lni-1, 
		    patch.gJ, patch.gJ+patch.lnj-1, 
		    patch.gNI, patch.gNJ );
	    MPI_Barrier( MPI_COMM_WORLD );
	}

	MLIFE_AllocateLocalMesh( &patch, &m1, &m2 );

	/* Run these tests multiple times.  In many cases, the first
	   run will take significantly longer, as library setup actions
	   take place.  To illustrate this, write out the timing data for
	   each run, so that the first and second times can be compared */
	for (kk=0; kk<2; kk++) {
	
	    /* For each communication approach, perform these steps
	       1: Initialize the mesh (initial data)
	       2: Initialize the exchange 
	       3: Time the iterations, including any communication steps.
	    */
	    MLIFE_TimeIterations( &patch, options.nIter, doCheckpoint, m1, m2,
				  MLIFE_ExchangeInitPt2pt,
				  MLIFE_ExchangePt2pt,
				  MLIFE_ExchangeEndPt2pt,
				  &timedataPt2pt );
	    MLIFE_TimeIterations( &patch, options.nIter, doCheckpoint, m1, m2,
				  MLIFE_ExchangeInitPt2ptSnd,
				  MLIFE_ExchangePt2ptSnd,
				  MLIFE_ExchangeEndPt2ptSnd,
				  &timedataPt2ptSnd );
	    MLIFE_TimeIterations( &patch, options.nIter, doCheckpoint, m1, m2,
				  MLIFE_ExchangeInitPt2ptUV,
				  MLIFE_ExchangePt2ptUV,
				  MLIFE_ExchangeEndPt2ptUV,
				  &timedataPt2ptUv );
	    MLIFE_TimeIterations( &patch, options.nIter, doCheckpoint, m1, m2,
				  MLIFE_ExchangeInitFence,
				  MLIFE_ExchangeFence,
				  MLIFE_ExchangeEndFence,
				  &timedataFence );
	    MLIFE_TimeIterations( &patch, options.nIter, doCheckpoint, m1, m2,
				  MLIFE_ExchangeInitPt2pt9,
				  MLIFE_ExchangePt2pt9,
				  MLIFE_ExchangeEndPt2pt9,
				  &timedataPt2pt9 );
	    
	    /* Print the total time taken */
	    if (rank == 0) {
		printf( "Mesh size [%d,%d] on process array [%d,%d] for %s\n",
			patch.gNI, patch.gNJ, patch.pNI, patch.pNJ, commstr );
		printf( "Exchange type\tPer iter\tExchange\tPacktime\tUnpacktime\n" );
		printf( "[%d] Pt2pt: \t%e\t%e\n", rank,
			timedataPt2pt.itertime,
			timedataPt2pt.exchtime );
		printf( "[%d] Pt2ptSnd: \t%e\t%e\n", rank,
			timedataPt2ptSnd.itertime,
			timedataPt2ptSnd.exchtime );
		printf( "[%d] Pt2ptUv: \t%e\t%e\t%e\t%e\n", rank,
			timedataPt2ptUv.itertime,
			timedataPt2ptUv.exchtime,
			timedataPt2ptUv.packtime,
			timedataPt2ptUv.unpacktime);
		printf( "[%d] Fence: \t%e\t%e\n", rank,
			timedataFence.itertime,
			timedataFence.exchtime );
		printf( "[%d] Pt2pt-9: \t%e\t%e\n", rank,
			timedataPt2pt9.itertime,
			timedataPt2pt9.exchtime );
	    }
	}
	MLIFE_FreeLocalMesh( &patch, m1, m2 );
    }

    MLIFEIO_Finalize();
    MPI_Finalize();

    return 0;
}


