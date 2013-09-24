/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*
 *  (C) 2004 by University of Chicago.
 *      See COPYRIGHT in top-level directory.
 */

#include <mpi.h>

#include "mlife2d.h"

int MLIFE_ExchangeInitPt2pt9( MLIFEPatchDesc *patch, 
			     int **m1, int **m2, void *privateData )
{
    *(void **)privateData = 0;
  return 0;
}

int MLIFE_ExchangeEndPt2pt9( void *privateData )
{
    return 0;
}

int MLIFE_ExchangePt2pt9( MLIFEPatchDesc *patch, int **matrix, 
			  MLIFETiming *timedata, void *privateData )
{
    MPI_Request reqs[16];
    MPI_Comm    comm = patch->comm;
    static MPI_Datatype type = MPI_DATATYPE_NULL;
    int LRows = patch->lni;
    int LCols = patch->lnj;

    /* Send and receive boundary information */

    if (type == MPI_DATATYPE_NULL) {
        MPI_Type_vector(LRows, 1, LCols+2, MPI_INT, &type);
        MPI_Type_commit(&type);
    }

    MPI_Isend(&matrix[1][1], 1, type,
	      patch->left, 0, comm, reqs);
    MPI_Irecv(&matrix[1][0], 1, type,
	      patch->left, 0, comm, reqs+1);
    MPI_Isend(&matrix[1][LCols], 1, type,
	      patch->right, 0, comm, reqs+2);
    MPI_Irecv(&matrix[1][LCols+1], 1, type,
	      patch->right, 0, comm, reqs+3);

    /* move the top, bottom edges */
    MPI_Isend(&matrix[1][1], LCols, MPI_INT,
	      patch->up, 0, comm, reqs+4);
    MPI_Irecv(&matrix[0][1], LCols, MPI_INT,
	      patch->up, 0, comm, reqs+5);
    MPI_Isend(&matrix[LRows][1], LCols, MPI_INT,
	      patch->down, 0, comm, reqs+6);
    MPI_Irecv(&matrix[LRows+1][1], LCols, MPI_INT,
	      patch->down, 0, comm, reqs+7);

    /* Move the diagonals */
    MPI_Isend( &matrix[1][1], 1, MPI_INT, patch->ul, 0, comm, reqs+8 );
    MPI_Isend( &matrix[LRows][1], 1, MPI_INT, patch->ll, 0, comm, reqs+9 );
    MPI_Isend( &matrix[1][LCols], 1, MPI_INT, patch->ur, 0, comm, reqs+10 );
    MPI_Isend( &matrix[LRows][LCols], 1, MPI_INT, patch->lr, 0, comm, reqs+11 );
    MPI_Irecv( &matrix[0][0], 1, MPI_INT, patch->ul, 0, comm, reqs+12 );
    MPI_Irecv( &matrix[0][LCols+1], 1, MPI_INT, patch->ur, 0, comm, reqs+13 );
    MPI_Irecv( &matrix[LRows+1][0], 1, MPI_INT, patch->ll, 0, comm, reqs+14 );
    MPI_Irecv( &matrix[LRows+1][LCols+1], 1, MPI_INT, patch->lr, 0, comm, 
	       reqs+15 );

    /* Note that this may seem */
    MPI_Waitall(16, reqs, MPI_STATUSES_IGNORE);

    return MPI_SUCCESS;
}
