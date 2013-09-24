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

static int MLIFE_nextstate(int **matrix, int y, int x);

int MLIFE_TimeIterations( MLIFEPatchDesc *patch, int nIter, 
			  int doCheckpoint,
			  int **m1, int **m2, 
	  int (*exchangeInit)( MLIFEPatchDesc *, int**, int **, void *), 
	  int (*exchange)( MLIFEPatchDesc *, int **, MLIFETiming *, void *), 
			  int (*exchangeEnd)( void * ),
			  MLIFETiming *timedata )
{
    double t1, t2, t3;
    int    i, j, k, **temp;
    int    LCols = patch->lnj;
    int    LRows = patch->lni;
    void   *privateData;

    /* Initialize the timedata */
    timedata->packtime = timedata->unpacktime = 0.0;
    timedata->exchtime = timedata->itertime = 0.0;

    /* Initialize mesh */
    MLIFE_InitLocalMesh( patch, m1, m2 );
    if (doCheckpoint)
	MLIFEIO_Checkpoint( patch, m1, 0, MPI_INFO_NULL );

    /* Initialize exchange */
    (*exchangeInit)( patch, m1, m2, &privateData );

    /* Time the iterations */
    t1 = 0;

    MPI_Barrier( MPI_COMM_WORLD );
    t2 = MPI_Wtime();
    for (k=0; k<nIter; k++) {
	t3 = MPI_Wtime();
	(*exchange)( patch, m1, timedata, privateData );
	t1 += MPI_Wtime() - t3;

        /* calculate new state for all non-boundary elements */
        for (i = 1; i <= LRows; i++) {
            for (j = 1; j <= LCols; j++) {
                m2[i][j] = MLIFE_nextstate(m1, i, j);
            }
        }

        /* swap the matrices */
	temp = m1;
	m1   = m2;
        m2   = temp;

	if (doCheckpoint)
	    MLIFEIO_Checkpoint( patch, m1, k+1, MPI_INFO_NULL );
    }
    t2 = MPI_Wtime() - t2;

    (*exchangeEnd)( privateData );

    /* Get the maximum time over all involved processes */
    timedata->packtime   = timedata->packtime / nIter;
    timedata->unpacktime = timedata->unpacktime / nIter;
    timedata->exchtime   = t1 / nIter;
    timedata->itertime   = t2 / nIter;
    MPI_Allreduce( MPI_IN_PLACE, timedata, 4, MPI_DOUBLE, MPI_MAX, 
		   patch->comm );

    return 0;
}


static int MLIFE_nextstate(int **matrix,
                           int row,
                           int col)
{
    int sum;

    /* add values of all eight neighbors */
    sum = matrix[row-1][col-1] + matrix[row-1][col] +
          matrix[row-1][col+1] + matrix[row][col-1] +
          matrix[row][col+1] + matrix[row+1][col-1] +
          matrix[row+1][col] + matrix[row+1][col+1];

    if (sum < 2 || sum > 3) return DIES;
    else if (sum == 3)      return BORN;
    else                    return matrix[row][col];
}



