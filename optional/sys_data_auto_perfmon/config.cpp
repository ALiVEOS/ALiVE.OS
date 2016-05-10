#include <script_component.hpp>

#include <CfgPatches.hpp>

class Extended_PreInit_EventHandlers
{
 class alive_sys_data_auto_perfmon
 {
  init = "call ('\x\alive\optional\sys_data_auto_perfmon\XEH_preInit.sqf' call SLX_XEH_COMPILE)";
 };
};
