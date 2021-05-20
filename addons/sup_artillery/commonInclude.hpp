//GUI and script related macros
#include "\a3\3DEN\UI\macros.inc"

//DIK Key Codes
#include "\a3\ui_f\hpp\definedikcodes.inc"

//Common GRIDs
#include "\a3\ui_f\hpp\definecommongrids.inc"

//Eden Editor IDDs and IDCs as well as controls types and styles and macros
#include "\a3\3den\ui\resincl.inc"

#define SHOW_IN_ROOT value = 0
#define EDIT_W 10
#define EDIT_W_WIDE 11
#define CENTERED_X(w) (CENTER_X - (w / 2 * GRID_W))
#define DIALOG_TOP (safezoneY + 17 * GRID_H)
#define CTRL_DEFAULT_H (SIZE_M * GRID_H)

//Statusbar
#define SPACE_X (2 * pixelW)
#define ORIGIN_X_STATUSBAR (safezoneW - 60 * GRID_W)

//Macros for scripting
#define CTRL(IDC) (_display displayCtrl IDC)

//Eden Editor
#define IDD_3DEN 313