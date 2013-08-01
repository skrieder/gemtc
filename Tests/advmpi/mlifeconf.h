/* mlifeconf.h.  Generated from mlifeconf.h.in by configure.  */
/* mlifeconf.h.in.  Generated from configure.ac by autoheader.  */

/* Define to 1 if you have the `drand48' function. */
#define HAVE_DRAND48 1

/* Define to 1 if you have the `nanosleep' function. */
#define HAVE_NANOSLEEP 1

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "wgropp@illinois.edu"

/* Define to the full name of this package. */
#define PACKAGE_NAME "MLIFE"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "MLIFE 1.0"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "mlife"

/* Define to the home page for this package. */
#define PACKAGE_URL "http://www.cs.illinois.edu/~wgropp/advmpi"

/* Define to the version of this package. */
#define PACKAGE_VERSION "1.0"

/* Define to `__inline__' or `__inline' if that's what the C compiler
   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
/* #undef inline */
#endif

/* Define to the equivalent of the C99 'restrict' keyword, or to
   nothing if this is not supported.  Do not define if restrict is
   supported directly.  */
#define restrict __restrict
/* Work around a bug in Sun C++: it does not support _Restrict or
   __restrict__, even though the corresponding Sun C compiler ends up with
   "#define restrict _Restrict" or "#define restrict __restrict__" in the
   previous line.  Perhaps some future version of Sun C++ will work with
   restrict; if so, hopefully it defines __RESTRICT like Sun C does.  */
#if defined __SUNPRO_CC && !defined __RESTRICT
# define _Restrict
# define __restrict__
#endif

/* Define to empty if the keyword `volatile' does not work. Warning: valid
   code using `volatile' can become incorrect without. Disable with care. */
/* #undef volatile */
