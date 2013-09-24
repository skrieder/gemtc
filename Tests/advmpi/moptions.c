/* -*- Mode: C; c-basic-offset:4 ; -*- */
/* SLIDE: 2D Life Code Walkthrough */
/*
 *  (C) 2013 by University of Chicago.
 *      See COPYRIGHT in top-level directory.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <mpi.h>

#include "mlife2d.h"
#include "mlife-io.h"

/* MLIFEParseArgs
 *
 * Note: Command line arguments are not guaranteed in the MPI
 *       environment to be passed to all processes.  To be
 *       portable, we must process on rank 0 and distribute
 *       results.
 */
int MLIFE_ParseArgs(int argc, char **argv, MLIFEOptions *options)
{
    int          ret, rank, blklens[2];
    MPI_Aint     displs[2];
    MPI_Datatype types[2], argsType;
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    blklens[0] = 8; blklens[1] = sizeof(options->prefix);
    displs[0]  = 0; displs[1] = &options->prefix[0] - (char *)&options->gNI;
    types[0]   = MPI_INT; types[1] = MPI_CHAR;
    MPI_Type_create_struct( 2, blklens, displs, types, &argsType );
    MPI_Type_commit( &argsType );

    if (rank == 0) {
	/* Initialize defaults */
	options->gNI     = 20;
	options->gNJ     = 20;
	options->pNI     = 0;
	options->pNJ     = 0;
	options->nIter   = 1;
	options->verbose = 0;
	options->doIO    = 0;
	options->restartIter = -1;
	strncpy( options->prefix, "mlife", sizeof(options->prefix) - 1);

        while ((ret = getopt(argc, argv, "a:b:x:y:i:p:r:cv")) >= 0)
        {
            switch(ret) {
                case 'a':
                    options->pNJ = atoi(optarg);
                    break;
                case 'b':
                    options->pNI = atoi(optarg);
                    break;
	        case 'c':
		    options->doIO = 1;
		    break;
                case 'x':
                    options->gNJ = atoi(optarg);
                    break;
                case 'y':
                    options->gNI = atoi(optarg);
                    break;
                case 'i':
                    options->nIter = atoi(optarg);
                    break;
                case 'r':
                    options->restartIter = atoi(optarg);
		    break;
                case 'p':
                    strncpy(options->prefix, optarg, sizeof(options->prefix)-1);
                    break;
	        case 'v':
		    options->verbose = 1;
		    break;
                default:
		    fprintf( stderr, "\
\t-a <pj> - Number of processes in x (j) direction\n\
\t-b <pi> - Number of processes in y (i) direction\n\
\t-c      - Enable I/O (checkpoint)\n\
\t-x <nj> - Size of mesh in x (j) direction\n\
\t-y <ni> - Size of mesh in y (i) direction\n\
\t-i <n>  - Number of iterations\n\
\t-r <i>  - Iteration where restart begins (and read restart file)\n\
\t-p <pre>- Filename prefix for I/O\n\
\t-v      - Turn on verbose output" );
		    MLIFE_Abort( "" );
                    break;
            }
        }
    }

    MPI_Bcast(options, 1, argsType, 0, MPI_COMM_WORLD );
    MPI_Type_free( &argsType );
    return 0;
}

void MLIFE_Abort( const char str[] )
{
    fprintf( stderr, "MLIFE Aborting: %s\n", str );
    MPI_Abort( MPI_COMM_WORLD, 1 );
}
