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
#define LEAF_PKG_NAME setup

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
C_Setup_Cmd(ClientData cdata, Tcl_Interp *interp,
             int objc, Tcl_Obj *const objv[])
{

  double x;
  int error = Tcl_GetDoubleFromObj(interp, objv[1], &x);

  // call the gemtc setup

    printf("Calling gpu setup now...\n");
    setupGemtc(2560);
    printf("Out of gpu setup.\n");
      
  printf("Error message: %i\n", error);
    // return some results
    Tcl_Obj* result = Tcl_NewDoubleObj(0);
  Tcl_SetObjResult(interp, result);
  return TCL_OK;
}
int DLLEXPORT
Tclsetup_Init(Tcl_Interp *interp)
{
  if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL)
    return TCL_ERROR;

  if (Tcl_PkgProvide(interp, "setup", "0.0.1") == TCL_ERROR)
    return TCL_ERROR;

  Tcl_CreateObjCommand(interp,
                       "setup::c::c_setup", C_Setup_Cmd,
                       NULL, NULL);

  Tcl_Namespace* ns =
    Tcl_FindNamespace(interp, "setup", NULL, 0);

  Tcl_Export(interp, ns, "*", 0);
  return TCL_OK;

}
