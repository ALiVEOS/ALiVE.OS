#include <\x\alive\addons\mil_opcom\script_component.hpp>
SCRIPT(OPCOMdropIntel);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMdropIntel

Description:
Adds civilian actions

Parameters:
Array - [_unit,_chance 0-1]
Returns:
object or any

Examples:
(begin example)
//
_result = [_unit,0.1] call ALIVE_fnc_OPCOMdropIntel;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_data","_chance","_globalChance"];

params [
    ["_data", [objNull,objNull], [[]]],
    ["_chance", 0, [-1]]
];

// Set Data
_unit = _data select 0;
_side = (faction _unit) call ALiVE_fnc_FactionSide;
_globalChance = call compile (format["ALiVE_MIL_OPCOM_INTELCHANCE_%1",_side]);

//Override from OPCOM module else use provided value (default off)
_chance = if (!isnil "_globalChance") then {_globalChance} else {_chance};

//["ALiVE OPCOM DropIntel TRACE side: %1 chance: %2 _globalChance active: %3",_side,_chance,!isnil "_globalChance"] call ALiVE_fnc_DumpR;

if (random 1 > _chance || {isNull _unit}) exitwith {};

_type = selectRandom ["Land_File1_F","Land_FilePhotos_F","Land_File2_F","Land_File_research_F"];
_position = getposATL _unit;

_object = _type createVehicle _position;
_object setposATL ([_position,1] call CBA_fnc_Randpos);

//["ALiVE OPCOM DropIntel TRACE object %1 created at %2 (%3)",typeOf _object, getposATL _object, _object] call ALiVE_fnc_DumpR;

if (!isNull _object) then {
    
    //Add Action globally
	_args = [
		"Read Intel", //Action Text
		{_object = _this select 0; _caller = _this select 1; _params = _this select 3; openmap true; [_params select 0, 1500, _params select 1] call ALiVE_fnc_OPCOMToggleInstallations}, //Action Code
		[_position,_side], //Params
		1, //Prio
		false, //showWindow
		true, //hideOnUse
		"", //showrtcut
		"alive _target" //condition
	];
    [[_object, _args],"addAction",true,true] call BIS_fnc_MP;
    
    //["ALiVE OPCOM DropIntel TRACE action placed on object %1! All good!",_object] call ALiVE_fnc_DumpR;
    //_marker = [format["OPCOM_INTEL_%1", getposATL _object], getposATL _object,"ICON", [0.2,0.2],"ColorRed","INTEL", "n_installation", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;

	//Do cleanup!
	[_unit,_object,_marker] spawn {
	    
	    _unit = _this select 0;
	    _object = _this select 1;
        _marker = _this select 2;
	    
	    waituntil {sleep 10; isNil "_unit" || {isNull _unit}};
	    
        //["ALiVE OPCOM DropIntel TRACE deleting object %1! DropIntel finishing!",_object] call ALiVE_fnc_DumpR;
        
        deleteMarker _marker;
	    deleteVehicle _object;
	};
	
	_object
};