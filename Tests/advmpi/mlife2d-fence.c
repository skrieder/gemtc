/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*
 *  (C) 2004 by University of Chicago.
 *      See COPYRIGHT in top-level directory.
 */

#include <mpi.h>

#include "mlife2d.h"

static int above_LRows, left_LCols,  right_LCols;

static MPI_Win matrix_win, temp_win;

typedef struct mem_win {
    void *mem;
    MPI_Win win;
    int above_LRows, left_LCols,  right_LCols;
  
} mem_win;

static mem_win mem_win_map[2];

int MLIFE_ExchangeInitFence( MLIFEPatchDesc *patch, 
			     int **m1, int **m2, void *privateData )
{
    int      err=MPI_SUCCESS;
    int      tmp_next, tmp_prev, tmp_left, tmp_right;
    int      tmp_LRows, tmp_LCols; 
    int      tmp_GFirstRow, tmp_GFirstCol; 
    int      nprocs;

    int LRows = patch->lni;
    int LCols = patch->lnj;

    /* create windows */
    /* Note that the meshes are passes as the pointers to the rows,
      but the rows are contiguous in memory */
    MPI_Win_create(m1[0], (LRows+2)*(LCols+2)*sizeof(int), 
                   sizeof(int), MPI_INFO_NULL, patch->comm, &matrix_win);

    MPI_Win_create(m2[0], (LRows+2)*(LCols+2)*sizeof(int), 
                   sizeof(int), MPI_INFO_NULL, patch->comm, &temp_win);

    /* store the mapping from memory address to associated 
       window */ 

    mem_win_map[0].mem = m1[0];
    mem_win_map[0].win = matrix_win;
    mem_win_map[1].mem = m2[0];
    mem_win_map[1].win = temp_win;

    /* for one-sided communication, we need to know the number of
       local rows in rank above and the number of local 
       columns in rank left and right in order to do 
       the puts into the right locations in memory. */
    
    MPI_Comm_size(patch->comm, &nprocs);

    if (patch->up == MPI_PROC_NULL)
        above_LRows = 0;
    else {
	MPI_Recv( &above_LRows, 1, MPI_INT, patch->up, 0, patch->comm, 
		  MPI_STATUS_IGNORE );
    }
    if (patch->down != MPI_PROC_NULL) {
	MPI_Send( &patch->lni, 1, MPI_INT, patch->down, 0, patch->comm );
    }

    if (patch->left == MPI_PROC_NULL)
        left_LCols = 0;
    else {
	MPI_Recv( &left_LCols, 1, MPI_INT, patch->left, 0, patch->comm,
		  MPI_STATUS_IGNORE );
	MPI_Send( &patch->lnj, 1, MPI_INT, patch->left, 0, patch->comm );
    }

    if (patch->right == MPI_PROC_NULL)
        right_LCols = 0;
    else {
	/* This send matches the recv from the left, above */
	MPI_Send( &patch->lnj, 1, MPI_INT, patch->right, 0, patch->comm );
	/* This recv matche the send from the left, above */
	MPI_Recv( &right_LCols, 1, MPI_INT, patch->right, 0, patch->comm,
		  MPI_STATUS_IGNORE );
    }

    return err;
}

int MLIFE_ExchangeEndFence(void *privateData)
{
    MPI_Win_free(&matrix_win);
    MPI_Win_free(&temp_win);
    return 0;
}
       /* SLIDE: 2D Life Code Walkthrough */
int MLIFE_ExchangeFence( MLIFEPatchDesc *patch, int **matrix,
			 MLIFETiming *timedata, void *privateData )
{
    int err=MPI_SUCCESS;
    MPI_Aint disp;
    int LRows = patch->lni;
    int LCols = patch->lnj;
    static MPI_Datatype mytype = MPI_DATATYPE_NULL;
    static MPI_Datatype left_type = MPI_DATATYPE_NULL;
    static MPI_Datatype right_type = MPI_DATATYPE_NULL;

    MPI_Win win;

    /* Find the right window object */
    if (mem_win_map[0].mem == &matrix[0][0])
        win = mem_win_map[0].win;
    else
        win = mem_win_map[1].win;

    /* create datatype if not already created */
    if (mytype == MPI_DATATYPE_NULL) {
	MPI_Type_vector(LRows, 1, LCols+2, MPI_INT, &mytype);
        MPI_Type_commit(&mytype);
    }
    if (left_type == MPI_DATATYPE_NULL) {
	MPI_Type_vector(LRows, 1, left_LCols+2, MPI_INT, &left_type);
        MPI_Type_commit(&left_type);
    }
    if (right_type == MPI_DATATYPE_NULL) {
	MPI_Type_vector(LRows, 1, right_LCols+2, MPI_INT,
                        &right_type);
        MPI_Type_commit(&right_type);
    }


    MPI_Win_fence(MPI_MODE_NOPRECEDE, win);

    /* first put the left, right edges */

    disp = (left_LCols + 2) + (left_LCols + 1);
    MPI_Put(&matrix[1][1], 1, mytype, patch->left, disp, 1, 
	    left_type, win);

    disp = right_LCols + 2;
    MPI_Put(&matrix[1][LCols], 1, mytype, patch->right, disp, 1, 
            right_type, win); 

    /* Complete the right/left transfers for the diagonal trick */
    MPI_Win_fence( 0, win );

    /* now put the top, bottom edges (including the diagonal 
       points) */
    MPI_Put(&matrix[1][0], LCols + 2, MPI_INT, patch->up,
            (above_LRows+1)*(LCols+2), LCols+2, MPI_INT, win);

    MPI_Put(&matrix[LRows][0], LCols + 2, MPI_INT, patch->down, 0, 
            LCols+2, MPI_INT, win);

    MPI_Win_fence(MPI_MODE_NOSTORE | MPI_MODE_NOPUT | 
                  MPI_MODE_NOSUCCEED, win);
    return err;
}
