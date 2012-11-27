#include <assert.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <tcl.h>

#include <stdio.h>

// header file include
extern void setupGemtc(int);
extern void cleanupGemtc(void);
extern void *run(int, int, void*, int);


/**
   Set leaf package name here:
*/
#define LEAF_PKG_NAME sleep

/**
   Set leaf package version here:
*/
#define LEAF_PKG_VERSION 0.0.1

/**
   Shorten command creation lines.   
   The namespace is prepended
 */
#define COMMAND(tcl_function, pkg, c_function)

static int
C_Sleep_Cmd(ClientData cdata, Tcl_Interp *interp,
             int objc, Tcl_Obj *const objv[])
{

  double x;
  int error = Tcl_GetDoubleFromObj(interp, objv[1], &x);

  printf("Error message: %i\n", error);
    printf("Sleeptime is equal to: %lf\n", x);
   int xx = (int) x;
   sleep(xx);
    printf("Sleep has completed.");
  
    // return some results
    Tcl_Obj* result = Tcl_NewDoubleObj(0);
  Tcl_SetObjResult(interp, result);
  return TCL_OK;
}
/*
C_Sleep_Cmd_2(ClientData cdata, Tcl_Interp *interp,
             int objc, Tcl_Obj *const objv[])
{
  // return some results
  Tcl_Obj* result = Tcl_NewDoubleObj(0);
  Tcl_SetObjResult(interp, result);
  return TCL_OK;
}
*/
int DLLEXPORT
Tclsleep_Init(Tcl_Interp *interp)
{
  if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL)
    return TCL_ERROR;

  if (Tcl_PkgProvide(interp, "sleep1", "0.0.1") == TCL_ERROR)
    return TCL_ERROR;

  Tcl_CreateObjCommand(interp,
                       "sleep1::c::c_sleep", C_Sleep_Cmd,
                       NULL, NULL);

  Tcl_Namespace* ns =
    Tcl_FindNamespace(interp, "sleep1", NULL, 0);

  Tcl_Export(interp, ns, "*", 0);
  return TCL_OK;

}
