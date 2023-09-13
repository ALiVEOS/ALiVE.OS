#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(detectDLC);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_detectDLC

Description:
Detects CDLC present in getLoadedModsInfo array

Parameters: Scalar - DLC appId
Returns: Boolean - true if search term is found, false if not

Example: 
(App ID, 1175380: Arma 3 Creator DLC: Spearhead 1944)
[1175380] call ALIVE_fnc_detectDLC; 

Author:
Jman
---------------------------------------------------------------------------- */

private ["_itemID","_isPresent","_listAddons","_thisRow"];

DEFAULT_PARAM(9999999,_itemID ,[]);

    private _isPresent = 0;
    private _listAddons = getLoadedModsInfo;
    {
      if (count _x > 0) then {
         _thisRow = [_x] call ALiVE_fnc_toString;
         ["ALIVE_fnc_detectDLC - Loaded Addon: %1", _thisRow] call ALIVE_fnc_dump;
         _isPresent = [_itemID, _thisRow] call BIS_fnc_inString;
         if (_isPresent) then { break; };
      };
     } forEach _listAddons; 
     
_isPresent