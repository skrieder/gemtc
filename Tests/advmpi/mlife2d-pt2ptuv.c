/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*
 *  (C) 2004 by University of Chicago.
 *      See COPYRIGHT in top-level directory.
 */

#include <mpi.h>
#include <stdlib.h>
#include <stdio.h>
#include "mlife2d.h"

typedef struct {
    int *lsbuf, *rsbuf, *lrbuf, *rrbuf;  /* send and receive buffers */
    int buflen;
} myvecbuf;


int MLIFE_ExchangeInitPt2ptUV( MLIFEPatchDesc *patch, 
			     int **m1, int **m2, void *privateData )
{
    myvecbuf *myvec;
    myvec         = (myvecbuf *)malloc( sizeof(myvecbuf) );
    myvec->lsbuf  = (int *)malloc( patch->lni  * sizeof(int) );
    myvec->rsbuf  = (int *)malloc( patch->lni  * sizeof(int) );
    myvec->lrbuf  = (int *)malloc( patch->lni  * sizeof(int) );
    myvec->rrbuf  = (int *)malloc( patch->lni  * sizeof(int) );
    myvec->buflen = patch->lni;
    *(void **)privateData = (void *)myvec;
  return 0;
}

int MLIFE_ExchangeEndPt2ptUV( void *privateData )
{
    myvecbuf *myvec = (myvecbuf *)privateData;

    free( myvec->lsbuf );
    free( myvec->rsbuf );
    free( myvec->lrbuf );
    free( myvec->rrbuf );
    free( myvec );
    return 0;
}

int MLIFE_ExchangePt2ptUV( MLIFEPatchDesc *patch, int **matrix, 
			   MLIFETiming *timedata, void *privateData )
{
    MPI_Request reqs[4];
    MPI_Comm    comm = patch->comm;
    int LRows = patch->lni;
    int LCols = patch->lnj;
    myvecbuf *myvec = (myvecbuf *)privateData;
    int *restrict lsbuf = (int *)myvec->lsbuf;
    int *restrict rsbuf = (int *)myvec->rsbuf;
    int *restrict lrbuf = (int *)myvec->lrbuf;
    int *restrict rrbuf = (int *)myvec->rrbuf;
    int buflen = myvec->buflen, i;
    double t1, t2;

    /* Send and receive boundary information */
    /* first, move the left, right edges */
    MPI_Irecv(lrbuf, buflen, MPI_INT, patch->left, 0, comm, reqs+1);
    MPI_Irecv(rrbuf, buflen, MPI_INT, patch->right, 0, comm, reqs+3);
    /* User pack of the buffers to send */
    t1 = MPI_Wtime();
    if (patch->left != MPI_PROC_NULL) {
	for (i=0; i<buflen; i++) {
	    lsbuf[i] = matrix[i+1][1];
	}
    }
    if (patch->right != MPI_PROC_NULL) {
	for (i=0; i<buflen; i++) {
	    rsbuf[i] = matrix[i+1][LCols];
	}
    }
    t1 = MPI_Wtime() - t1;
    MPI_Isend(lsbuf, buflen, MPI_INT, patch->left, 0, comm, reqs);
    MPI_Isend(rsbuf, buflen, MPI_INT, patch->right, 0, comm, reqs+2);
    /* We need to wait on these for the trick that we use to move
       the diagonal terms to work */
    MPI_Waitall( 4, reqs, MPI_STATUSES_IGNORE );
    /* Need to unpack */
    t2 = MPI_Wtime();
    if (patch->left != MPI_PROC_NULL) {
	for (i=0; i<buflen; i++) {
	    matrix[i+1][0]       = lrbuf[i];
	}
    }
    if (patch->right != MPI_PROC_NULL) {
	for (i=0; i<buflen; i++) {
	    matrix[i+1][LCols+1] = rrbuf[i];
	}
    }
    t2 = MPI_Wtime() - t2;

    /* move the top, bottom edges (including diagonals) */
    MPI_Isend(&matrix[1][0], LCols+2, MPI_INT,
	      patch->up, 0, comm, reqs);
    MPI_Irecv(&matrix[0][0], LCols+2, MPI_INT,
	      patch->up, 0, comm, reqs+1);
    MPI_Isend(&matrix[LRows][0], LCols+2, MPI_INT,
	      patch->down, 0, comm, reqs+2);
    MPI_Irecv(&matrix[LRows+1][0], LCols+2, MPI_INT,
	      patch->down, 0, comm, reqs+3);

    MPI_Waitall(4, reqs, MPI_STATUSES_IGNORE);

    timedata->packtime   += t1;
    timedata->unpacktime += t2;

    return MPI_SUCCESS;
}
