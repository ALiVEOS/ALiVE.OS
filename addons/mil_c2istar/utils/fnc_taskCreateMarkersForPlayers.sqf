#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskCreateMarkersForPlayers);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCreateMarkersForPlayers

Description:
Mark a position for players

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskPosition","_taskSide","_taskID","_taskPlayers","_taskType","_type","_colour","_typePrefix","_icon","_markerDefinition","_player"];

_taskPosition = _this select 0;
_taskSide = _this select 1;
_taskPlayers = _this select 2;
_taskID = _this select 3;
_taskType = _this select 4;
_type = if(count _this > 5) then {_this select 5} else {""};

if (typeName _taskSide == "STRING") then {
    _taskSide = [_taskSide] call ALiVE_fnc_sideTextToObject;
};

switch(_taskSide) do {
    case EAST:{
        _colour = "ColorRed";
        _typePrefix = "o";
    };
    case WEST:{
        _colour = "ColorBlue";
        _typePrefix = "b";
    };
    case CIVILIAN:{
        _colour = "ColorYellow";
        _typePrefix = "c";
    };
    case RESISTANCE:{
        _colour = "ColorGreen";
        _typePrefix = "n";
    };
};

_markerDefinition = [];

switch(_taskType) do {
    case "Insertion":{
        _markerDefinition = [_taskPosition,_taskID,_colour,"Start","mil_start",[1,1],1,"ICON"];
    };
    case "Extraction":{
        _markerDefinition = [_taskPosition,_taskID,_colour,"Extraction","mil_end",[1,1],1,"ICON"];
    };
    case "HVT":{
        _markerDefinition = [_taskPosition,_taskID,_colour,"HVT","mil_objective",[1,1],1,"ICON"];
    };
    case "hostage":{
        _markerDefinition = [_taskPosition,_taskID,_colour,"Hostage","mil_objective",[1,1],1,"ICON"];
    };
    case "csar":{
        _markerDefinition = [_taskPosition,_taskID,_colour,"Beacon","mil_warning",[1,1],1,"ICON"];
    };
    case "vehicle":{

        switch(_type) do {
            case "Car":{
                _icon = format["%1_recon",_typePrefix];
            };
            case "Tank":{
                _icon = format["%1_armor",_typePrefix];
            };
            case "Armored":{
                _icon = format["%1_armor",_typePrefix];
            };
            case "Truck":{
                _icon = format["%1_recon",_typePrefix];
            };
            case "Ship":{
                _icon = format["%1_unknown",_typePrefix];
            };
            case "Helicopter":{
                _icon = format["%1_air",_typePrefix];
            };
            case "Plane":{
                _icon = format["%1_plane",_typePrefix];
            };
            case "StaticWeapon":{
                _icon = format["%1_mortar",_typePrefix];
            };
            default {
                _icon = "hd_dot";
            };
        };

        _markerDefinition = [_taskPosition,_taskID,_colour,"Target Vehicle",_icon,[1,1],1,"ICON"];
    };
    case "entity":{

        _icon = format["%1_inf",_typePrefix];

        _markerDefinition = [_taskPosition,_taskID,_colour,"Target Infantry",_icon,[1,1],1,"ICON"];
    };
    case "building":{

        _icon = format["%1_inf",_typePrefix];
        _type = format["Target %1",_type];

        _markerDefinition = [_taskPosition,_taskID,_colour,_type,_icon,[1,1],1,"ICON"];
    };
    default {
        _markerDefinition = [_taskPosition,_taskID,_colour,"","mil_warning",[1,1],1,"ICON"];
    };
};

{
    _player = [_x] call ALIVE_fnc_getPlayerByUID;

    if !(isNull _player) then {
        if(isDedicated) then {
            [_markerDefinition,"ALIVE_fnc_taskCreateMarker",_player,false,false] spawn BIS_fnc_MP;
        }else{
            _markerDefinition call ALIVE_fnc_taskCreateMarker;
        };
    };

} forEach _taskPlayers;