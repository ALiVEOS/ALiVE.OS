#include <\x\alive\addons\sys_adminActions\script_component.hpp>
SCRIPT(adminActionsTeleportUnits);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_adminActionsTeleportUnits
Description:

Teleports the nearest unit of given pos (maplick) to desired location (mapclick again)

Parameters:
none

Returns:
OBJECT - selected unit

See Also:
- <ALIVE_fnc_adminActions>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_unit","_input","_pos"];

_input = [[_this], 0, ["CAManBase"], [[]]] call BIS_fnc_param;
_unit = objNull;

[] call ALIVE_fnc_markUnits;

scopeName "#Main";

if (!visibleMap) then {openmap true};

while {visibleMap} do {

	GVAR(SELECTED_POSITION) = nil;
	GVAR(SELECTED_UNITS) = nil;

	["Click on map to select the unit!"] call ALiVE_fnc_DumpH;
	
	_input onmapsingleClick {GVAR(SELECTED_UNITS) = nearestObjects [_pos, _this, 50]};
	waituntil {!visibleMap || {!isnil QGVAR(SELECTED_UNITS)}};
    
    if !(visibleMap) exitwith {breakTo "#Main"};
	
	if !(count GVAR(SELECTED_UNITS) == 0) then {
        
		_unit = GVAR(SELECTED_UNITS) select 0;
		
		["Unit %1 selected! Click on map to teleport the unit!",_unit] call ALiVE_fnc_DumpH;
		onmapsingleClick {GVAR(SELECTED_POSITION) = _pos; onMapSingleClick ""};
		
		waituntil {!visibleMap || {!isnil QGVAR(SELECTED_POSITION)}};
        
        if !(visibleMap) exitwith {breakTo "#Main"};
        
		_pos = GVAR(SELECTED_POSITION);
		
		(vehicle _unit) setposATL _pos;
		["Unit %1 was teleported successfully to %2!",_unit,_pos] call ALiVE_fnc_DumpH;
    
    } else {
        hint format["No unit in that area!"]; onMapSingleClick "";
    };
	
	sleep 1;
};

GVAR(SELECTED_POSITION) = nil;
GVAR(SELECTED_UNITS) = nil;

hint format["Teleporting units finished!"];

_unit;