AC_PREREQ(2.63)
AC_INIT([MLIFE],
        1.0,
        [wgropp@illinois.edu],
        [mlife],
        [http://www.cs.illinois.edu/~wgropp/advmpi])

AC_CONFIG_HEADER(mlifeconf.h)

AC_ARG_WITH(mpi,[--with-mpi=dir - location of MPI compilation and run scripts],,with_mpi=/usr/local/bin)
AC_ARG_WITH(pnetcdf,[--with-pnetcdf=dir - location of pNetCDF libraries],,with_pnetcdf=no)
AC_ARG_WITH(fpmpi2,[--with-fpmpi2=dir - location of FPMPI2 libraries],,with_fpmpi2=no)
#
# Try to find the compiler
if test -d "$with_mpi" -a -x "$with_mpi/mpicc" ; then
    MPI_DIR=$with_mpi
fi

# Find the compilers, if they aren't set with the environment variables
if test -z "$MPICC" ; then
    AC_MSG_CHECKING([for how to compile MPI program in C])
    if test -x $MPI_DIR/mpicc ; then 
        MPICC=$MPI_DIR/mpicc
    elif test -x $MPI_DIR/bin/mpicc ; then
        MPICC=$MPI_DIR/bin/mpicc
    elif test -x $MPI_DIR/mpcc ; then
        MPICC=$MPIDIR/mpcc
    elif test -x $MPI_DIR/bin/mpcc ; then
        MPICC=$MPIDIR/bin/mpcc
    else 
        saveIFS=$IFS
        IFS=":"
	for dir in $PATH ; do
	    if test -x $dir/mpicc ; then
                MPICC=$dir/mpicc
		break
            elif test -x $dir/mpcc ; then
                MPICC=$dir/mpcc
		break
            fi
	done
	IFS=$saveIFS
    fi
    if test -n "$MPICC" ; then
        AC_MSG_RESULT($MPICC)
    else
        AC_MSG_RESULT([cannot determine!])
    fi
fi

dnl if test -z "$MPIF77" ; then
dnl     AC_MSG_CHECKING([for how to compile MPI program in Fortran])
dnl     if test -x $MPI_DIR/mpif77 ; then 
dnl         MPIF77=$MPI_DIR/mpif77
dnl     elif test -x $MPI_DIR/bin/mpicc ; then
dnl         MPIF77=$MPI_DIR/bin/mpif77
dnl     elif test -x $MPI_DIR/mpxlf ; then
dnl         MPIF77=$MPIDIR/mpxlf
dnl     elif test -x $MPI_DIR/bin/mpxlf ; then
dnl         MPIF77=$MPIDIR/bin/mpxlf
dnl     else
dnl         saveIFS=$IFS
dnl         IFS=":"
dnl 	for dir in $PATH ; do
dnl 	    if test -x $dir/mpif77 ; then
dnl                 MPIF77=$dir/mpif77
dnl 		break
dnl             elif test -x $dir/mpxlf ; then
dnl                 MPIF77=$dir/mpxlf
dnl 		break
dnl             fi
dnl 	done
dnl 	IFS=$saveIFS
dnl     fi
dnl     if test -n "$MPIF77" ; then 
dnl         AC_MSG_RESULT($MPIF77)
dnl     else
dnl         AC_MSG_RESULT([cannot determine!])
dnl     fi
dnl fi

dnl if test -z "$MPIEXEC" ; then
dnl     AC_MSG_CHECKING([for how to run MPI programs])
dnl     if test -x $MPI_DIR/mpiexec ; then 
dnl         MPIEXEC=$MPI_DIR/mpiexec
dnl 	MPIEXEC_NP=-n
dnl     elif test -x $MPI_DIR/bin/mpiexec ; then
dnl         MPIEXEC=$MPI_DIR/bin/mpiexec
dnl 	MPIEXEC_NP=-n
dnl     elif test -x $MPI_DIR/mpirun ; then
dnl         MPIEXEC=$MPI_DIR/mpirun 
dnl 	MPIEXEC_NP=-np
dnl     elif test -x $MPI_DIR/bin/mpirun ; then
dnl         MPIEXEC=$MPI_DIR/bin/mpirun
dnl 	MPIEXEC_NP=-np
dnl     else
dnl         saveIFS=$IFS
dnl         IFS=":"
dnl 	for dir in $PATH ; do
dnl 	    if test -x $dir/mpiexec ; then
dnl                 MPIEXEC=$dir/mpiexec
dnl 		MPIEXEC_NP=-n
dnl 		break
dnl             elif test -x $dir/mpirun ; then
dnl                 MPIEXEC=$dir/mpirun
dnl 		MPIEXEC_NP=-np
dnl 		break
dnl             elif test -x $dir/llrun ; then
dnl                 MPIEXEC=$dir/llrun
dnl 		MPIEXEC_NP=-p
dnl                 break
dnl             fi
dnl 	done
dnl 	IFS=$saveIFS
dnl     fi
dnl     if test -n "$MPIEXEC" ; then 
dnl         AC_MSG_RESULT($MPIEXEC $MPIEXEC_NP)
dnl     else
dnl         AC_MSG_RESULT([cannot determine!])
dnl     fi
dnl fi
AC_SUBST(MPICC)
dnl AC_SUBST(MPIF77)
dnl AC_SUBST(MPIEXEC)
dnl AC_SUBST(MPIEXEC_NP)

# Now, make sure that we have something that we can use
if test -n "$MPICC" ; then
    # Note that this may make CC a cross compiler
    CC=$MPICC
else
    AC_MSG_ERROR([You must specify the directory containing the MPI compilation scripts using the --with-mpi=dir option])
fi

AC_PROG_CC
AC_C_VOLATILE
AC_C_RESTRICT
AC_C_INLINE
#
# Find the MPI location
# Try to find drand48
# Try to find nanosleep
AC_CHECK_FUNCS(drand48 nanosleep)
# If we didn't find them, try with a few options
if test "$ac_cv_func_drand48" != yes ; then
    saveCFLAGS=$CFLAGS
    CFLAGS="$CFLAGS -D_XOPEN_SOURCE"
    AC_MSG_CHECKING([for drand48 defined when _XOPEN_SOURCE is defined])
    AC_TRY_LINK([#include <>],[double a=drand48();],pac_cv_func_drand48_with_xopen=yes,pac_cv_func_drand48_with_xopen=no)
    AC_MSG_RESULT($pac_cv_drand48_with_xopen)
    if test "$pac_cv_drand48_with_xopen" != yes ; then
        CFLAGS=$saveCFLAGS
        AC_MSG_WARN([Some examples require the random number generator drand48])
    fi
fi

if test "$with_pnetcdf" != no -a -d "$with_pnetcdf" ; then
    PNETCDF_DIR=$with_pnetcdf
fi

if test "$with_fpmpi2" != no -a -d "$with_fpmpi2" ; then
    FPMPI2_DIR=$with_fpmpi2
fi

AC_SUBST(MPI_DIR)
AC_SUBST(PNETCDF_DIR)
AC_SUBST(FPMPI2_DIR)
AC_OUTPUT(Makefile)
