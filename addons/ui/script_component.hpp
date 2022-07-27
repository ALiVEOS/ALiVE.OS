#define COMPONENT ui
#include "\x\alive\addons\main\script_mod.hpp"

//#define DEBUG_ENABLED_UI

#ifdef DEBUG_ENABLED_UI
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_UI
    #define DEBUG_SETTINGS DEBUG_SETTINGS_UI
#endif

#include "\x\cba\addons\main\script_macros.hpp"

#define _SMW 0.15*safeZoneW // common sub-menu width

#define _LBH 0.033*safeZoneH // list button height


// additional "_SUB" macros to handle sub folders
#define PATHTO_SUB(var1,var2,var3,var4) MAINPREFIX\##var1\SUBPREFIX\##var2\##var3\##var4.sqf
#define COMPILE_FILE_SUB(var1,var2,var3,var4) COMPILE_FILE2(PATHTO_SUB(var1,var2,var3,var4))
#define PREP_SYS_SUB(var1,var2,var3,var4) ##var1##_##var2##_fnc_##var4 = COMPILE_FILE_SUB(var1,var2,var3,DOUBLES(fnc,var4))
#define PREP_SUB(var1,var2) PREP_SYS_SUB(PREFIX,COMPONENT_F,var1,var2)

// array select with bounds check (for optional parameters)
#define IfCountDefault(var1,array2,index3,default4) ##var1 = if (count ##array2 > ##index3) then { ##array2 select ##index3 } else { ##default4 };

