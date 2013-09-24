/* -*- Mode: C; c-basic-offset:4 ; -*- */
/* SLIDE: 2D Life Code Walkthrough */
/*
 *  (C) 2013 by University of Chicago.
 *      See COPYRIGHT in top-level directory.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mpi.h>

#include "mlife2d.h"

/* 

 */
int MLIFE_PatchCreateProcessMesh( MLIFEOptions *options, MLIFEPatchDesc *patch )
{
    int dims[2];
    int up, down, left, right, ul, ur,ll, lr;
    int prow, pcol;
    int nprocs, rank;

    dims[0] = options->pNI;
    dims[1] = options->pNJ;

    patch->comm = MPI_COMM_WORLD;

    MPI_Comm_size( MPI_COMM_WORLD, &nprocs );
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    
    MPI_Dims_create(nprocs, 2, dims);

    patch->pNI = dims[0];
    patch->pNJ = dims[1];

    patch->gNI = options->gNI;
    patch->gNJ = options->gNJ;

    /* compute the cartesian coords of this process; number across
     * rows changing column by 1 changes rank by 1)
     */
    prow = rank / dims[1];
    pcol = rank % dims[1];
    patch->patchI = prow;
    patch->patchJ = pcol;
    
    /* Compute the neighbors */
    left = right = up = down = MPI_PROC_NULL;
    ul = ur = ll = lr = MPI_PROC_NULL;
    if (prow > 0) {
        up   = rank - dims[1];
	if (pcol > 0) ul = up - 1;
	if (pcol < dims[1] - 1) ur = up + 1;
    }
    if (pcol > 0) {
        left = rank - 1;
    }
    if (prow < dims[0]-1) {
        down = rank + dims[1];
	if (pcol > 0) ll = down - 1;
	if (pcol < dims[1] - 1) lr = down + 1;
    }
    if (pcol < dims[1]-1) {
        right = rank + 1;
    }
    patch->left  = left;
    patch->right = right;
    patch->up    = up;
    patch->down  = down;
    patch->ul    = ul;
    patch->ur    = ur;
    patch->ll    = ll;
    patch->lr    = lr;

    return 0;
}

int MLIFE_PatchCreateProcessMeshWithCart( MLIFEOptions *options, 
					  MLIFEPatchDesc *patch )
{
    int dims[2], periods[2], coords[2];
    int up, down, left, right, ul, ur,ll, lr;
    int prow, pcol;
    int nprocs, rank;

    dims[0] = options->pNI;
    dims[1] = options->pNJ;

    MPI_Comm_size( MPI_COMM_WORLD, &nprocs );
    
    MPI_Dims_create(nprocs, 2, dims);

    patch->pNI = dims[0];
    patch->pNJ = dims[1];

    patch->gNI = options->gNI;
    patch->gNJ = options->gNJ;

    /* Create a Cartesian communicator using the recommended (by dims_create)
       sizes */
    periods[0] = periods[1] = 0;
    MPI_Cart_create( MPI_COMM_WORLD, 2, dims, periods, 1, &patch->comm );

    /* The ordering of processes, relative to the rank in the new 
       communicator, is defined by the MPI standard.  However, there are
       useful convenience functions */

    MPI_Comm_rank( patch->comm, &rank ); 
    MPI_Cart_coords( patch->comm, rank, 2, coords );
    /* compute the cartesian coords of this process; number across
     * rows changing column by 1 changes rank by 1)
     */
    patch->patchI = coords[0];  /* prow */
    patch->patchJ = coords[1];  /* pcol */

    /* Get the neighbors.  Shift can be used for the coordinate directions */
    MPI_Cart_shift( patch->comm, 0, 1, &up, &down );
    MPI_Cart_shift( patch->comm, 1, 1, &left, &right );

    /* For the diagonal processes, we can either:
     1. Use the defined layout to compute them
     2. Communicate with the neighbors in the coordinate directions, who 
        know those ranks (e.g., as the up neighbor for the ranks of the up
        neighbors left and right neighbors).
    */
    ul = ur = ll = lr = MPI_PROC_NULL;
    if (up != MPI_PROC_NULL) {
	if (left != MPI_PROC_NULL) ul = up - 1;
	if (right != MPI_PROC_NULL) ur = up + 1;
    }
    if (down != MPI_PROC_NULL) {
	if (left != MPI_PROC_NULL) ll = down - 1;
	if (right != MPI_PROC_NULL) lr = down + 1;
    }

    patch->left  = left;
    patch->right = right;
    patch->up    = up;
    patch->down  = down;
    patch->ul    = ul;
    patch->ur    = ur;
    patch->ll    = ll;
    patch->lr    = lr;

    return 0;
}

int MLIFE_PatchCreateDataMeshDesc( MLIFEOptions *options, 
				   MLIFEPatchDesc *patch )
{    
    int firstcol, firstrow, lastcol, lastrow;

    /* compute the decomposition of the global mesh.
     * these are for the "active" part of the mesh, and range from
     * 1 to GRows by 1 to GCols
     */
    firstcol = 1 + patch->patchJ * (patch->gNJ / patch->pNJ);
    firstrow = 1 + patch->patchI * (patch->gNI / patch->pNI);
    if (patch->patchJ == patch->pNJ - 1) {
        lastcol = patch->gNJ;
    }
    else {
        lastcol  = 1 + (patch->patchJ + 1) * (patch->gNJ / patch->pNJ) - 1;
    }
    if (patch->patchI == patch->pNI - 1) {
        lastrow = patch->gNI;
    }
    else {
        lastrow = 1 + (patch->patchI + 1) * (patch->gNI / patch->pNI) - 1;
    }

    patch->gI  = firstrow;
    patch->gJ  = firstcol;
    patch->lni = lastrow - firstrow + 1;
    patch->lnj = lastcol - firstcol + 1;
    
    return 0;
}

/* Allocate a C-style 2-D array (array of pointers);  allocate 
   local mesh with ghost cells and as a contiguous block so that 
   strided access may be used for the left/right edges 

   For simplicity, all patches have halo cells on all sides, even 
   if the process shares a physical boundary.
*/
int MLIFE_AllocateLocalMesh( MLIFEPatchDesc *patch, int ***m1, int ***m2 )
{
    int **mat, i, j;

    mat    = (int **)malloc( (patch->lni + 2) * sizeof(int*) );
    if (!mat) MLIFE_Abort( "Unable to allocate mat" );
    mat[0] = (int *)malloc( (patch->lni+2)*(patch->lnj+2)*sizeof(int) );
    if (!mat[0]) MLIFE_Abort( "Unable to allocate mat[0]" );
    for (i=1; i<patch->lni+2; i++) {
	mat[i] = mat[i-1] + patch->lnj+2;
    }
    *m1 = mat;

    mat    = (int **)malloc( (patch->lni + 2) * sizeof(int*) );
    if (!mat) MLIFE_Abort( "Unable to allocate mat" );
    mat[0] = (int *)malloc( (patch->lni+2)*(patch->lnj+2)*sizeof(int) );
    if (!mat[0]) MLIFE_Abort( "Unable to allocate mat[0]" );
    for (i=1; i<patch->lni+2; i++) {
	mat[i] = mat[i-1] + patch->lnj+2;
    }
    *m2 = mat;

    return 0;
}

int MLIFE_FreeLocalMesh( MLIFEPatchDesc *patch, int **m1, int **m2 )
{
    free( m1[0] );
    free( m1 );
    free( m2[0] );
    free( m2 );
    return 0;
}

int MLIFE_InitLocalMesh( MLIFEPatchDesc *patch, int **m1, int **m2 )
{
    int i, j;
    int lni = patch->lni, lnj = patch->lnj;

    /* initialize the boundaries of the life matrix */
    for (j = 0; j < lnj+2; j++) {
        m1[0][j] = m1[lni+1][j] = m2[0][j] = m2[lni+1][j] = DIES;
    }
    for (i = 0; i < lni+2; i++) {
        m1[i][0] = m1[i][lnj+1] = m2[i][0] = m2[i][lnj+1] = DIES;
    }

    /* Initialize the life matrix */
    for (i = 1; i <= lni; i++)  {
	/* Seed is determined by the row */
        srand48((long)(1000^(i + patch->gI-1)));
	//printf( "Row %d:", i + patch->gI-1 );
        /* advance to the random number generator to the
	 * first *owned* cell in this row
	 */
        for (j=1; j < patch->gJ; j++) {    
            (void)drand48();
        }

        for (j=1; j <= lnj; j++) {
            if (drand48() > 0.5) { m1[i][j] = BORN; /*printf("%d ",j);*/}
            else                 m1[i][j] = DIES;
	}
	//printf( "\n" );
    }

    return 0;
}
