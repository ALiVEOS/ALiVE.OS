#include "\x\alive\addons\mil_c2istar\script_component.hpp"
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

private ["_taskPosition","_taskSide","_taskID","_taskPlayers","_taskType","_type","_customText","_colour","_typePrefix","_icon","_markerDefinition","_player"];

_taskPosition = _this select 0;
_taskSide = _this select 1;
_taskPlayers = _this select 2;
_taskID = _this select 3;
_taskType = _this select 4;
_type = if(count _this > 5) then {_this select 5} else {""};
// Optional 7th arg: overrides the auto-generated marker text (the
// "Target X" / "HVT" / etc. label derived from _taskType + _type
// below). Used by single-marker task callers to surface the task
// title (e.g. "Repair Sewer Service") instead of the generic
// "Target critical service" derived label. Multi-marker callers
// (Assassination Insertion / Extraction / HVT etc.) leave this
// blank and keep their per-marker semantic labels.
_customText = if(count _this > 6 && {typeName (_this select 6) == "STRING"}) then {_this select 6} else {""};

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
        _markerDefinition = [_taskPosition,_taskID,_colour,"HVT","o_inf",[1,1],1,"ICON"];
    };
    case "hostage":{
        _markerDefinition = [_taskPosition,_taskID,_colour,"Hostage","b_inf",[1,1],1,"ICON"];
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
    case "civilian":{

        _markerDefinition = [_taskPosition,_taskID,_colour,_type,"c_unknown",[1,1],1,"ICON"];
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
        _markerDefinition = [_taskPosition,_taskID,_colour,".","mil_warning",[1,1],1,"ICON"];
    };
};

// If the caller supplied a custom text override, replace the marker
// text (4th element of _markerDefinition) with it. Keeps the icon /
// colour / shape from the switch's per-type selection. Defensive
// type guard: if a caller accidentally passes nil (e.g. a stale
// _taskTitle reference), treat as no-override rather than throwing.
if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
    ["DIAG-STRIP taskCreateMarkersForPlayers: taskID=%1 type=%2 customText=%3 (typeName=%4)", _taskID, _taskType, _customText, typeName _customText] call ALiVE_fnc_dump;
};
if (typeName _customText == "STRING" && {_customText != ""} && {count _markerDefinition >= 4}) then {
    _markerDefinition set [3, _customText];
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