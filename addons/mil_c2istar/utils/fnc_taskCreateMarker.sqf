#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskCreateMarker);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCreateMarker

Description:
Create a local marker

Parameters:

Returns:

Examples:
(begin example)
// default marker
[_position,_taskID,"ColorRed"] call ALIVE_fnc_taskCreateMaker;

// red objective marker no label
[_position,_taskID,"ColorRed","","mil_objective",[1,1],1,"ICON"] call ALIVE_fnc_taskCreateMaker;

// red circle
[_position,_taskID,"ColorRed","","",[100,100],1,"ELLIPSE","FDiagonal"] call ALIVE_fnc_taskCreateMaker;
(end)

A3 Brushes

BDiagonal,Border,Cross,DiagGrid,FDiagonal,Grid,Horizontal,Solid,SolidBorder,SolidFull,Vertical

A3 Shapes

ICON,RECTANGLE,ELLIPSE

A3 Markers

mil_objective,mil_marker,mil_marker_noShadow,mil_flag,mil_flag_noShadow,,mil_arrow,mil_arrow_noShadow
mil_arrow2,mil_arrow2_noShadow,mil_ambush,mil_ambush_noShadow,mil_destroy,mil_destroy_noShadow
mil_start,mil_start_noShadow,mil_end,mil_end_noShadow,mil_pickup,mil_pickup_noShadow
mil_join,mil_join_noShadow,mil_warning,mil_warning_noShadow,mil_unknown,mil_unknown_noShadow
mil_circle,mil_circle_noShadow,mil_dot,mil_dot_noShadow,mil_box,mil_box_noShadow
mil_triangle,mil_triangle_noShadow,

hd_objective,hd_flag,hd_flag_noShadow,hd_arrow,hd_arrow_noShadow,hd_ambush,hd_ambush_noShadow
hd_destroy,hd_destroy_noShadow,hd_start,hd_start_noShadow,hd_end,hd_end_noShadow,hd_pickup,hd_pickup_noShadow
hd_join,hd_join_noShadow,hd_warning,hd_warning_noShadow,hd_unknown,hd_unknown_noShadow,hd_dot,hd_dot_noShadow

b_unknown,o_unknown,n_unknown,
b_inf,o_inf,n_inf,
b_motor_inf,o_motor_inf,n_motor_inf,
b_mech_inf,o_mech_inf,n_mech_inf
b_armor,o_armor,n_armor,
b_recon,o_recon,n_recon,
b_air,o_air,n_air,
b_plane,o_plane,n_plane,
b_uav,o_uav,n_uav,
b_naval,o_naval,n_naval,
b_med,o_med,n_med
b_art,o_art,n_art
b_mortar,o_mortar,n_mortar
b_hq,o_hq,n_hq
b_support,o_support,n_support
b_maint,o_maint,n_maint,
b_service,o_service,n_service
b_installation,o_installation,n_installation,u_installation
c_unknown,c_car,c_ship,c_air,c_plane

group_0,group_1,group_2,group_3,group_4,group_5,group_6,group_7,group_8,group_9,group_10,group_11
respawn_unknown,respawn_inf,respawn_motor,respawn_armor,respawn_air,respawn_plane,respawn_naval,respawn_para

loc_Tree,loc_SmallTree,loc_Bush,loc_Church,loc_Chapel,loc_Cross,loc_Rock,loc_Bunker,loc_Fountain,loc_ViewTower,loc_Lighthouse
loc_Quay,loc_Fuelstation,loc_Hospital,loc_BusStop,loc_Transmitter,loc_Stack,loc_Ruin,loc_Tourism,loc_WaterTower,loc_Power
loc_PowerSolar,loc_PowerWave,loc_PowerWind,loc_Fortress

flag_NATO,flag_CSAT,flag_AAF,flag_Altis,flag_AltisColonial,flag_FIA,flag_EU,flag_UN,flag_Belgium,flag_Canada,flag_Catalonia
flag_Croatia,flag_CzechRepublic,flag_Denmark,flag_France,flag_Georgia,flag_Germany,flag_Greece,flag_Hungary,flag_Iceland
flag_Italy,flag_Luxembourg,flag_Netherlands,flag_Norway,flag_Poland,flag_Portugal,flag_Slovakia,flag_Slovenia,flag_Spain
flag_UK,flag_USA,

waypoint,KIA,Minefield,MinefieldAP


See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_taskID","_markerColour","_markerText","_markerType","_markerDimensions",
"_markerAlpha","_markerShape","_markerBrush","_taskMarkers","_m"];

_position = _this select 0;
_taskID = _this select 1;
_markerColour = _this select 2;
_markerText = if(count _this > 3) then {_this select 3} else {""};
_markerType = if(count _this > 4) then {_this select 4} else {"waypoint"};
_markerDimensions = if(count _this > 5) then {_this select 5} else {[0.8, 0.8]};
_markerAlpha = if(count _this > 6) then {_this select 6} else {1};
_markerShape = if(count _this > 7) then {_this select 7} else {"ICON"};
_markerBrush = if(count _this > 8) then {_this select 8} else {"SOLID"};

// if the clients task markers hash
// does not exist create it
if(isNil "ALIVE_taskMarkers") then {
    ALIVE_taskMarkers = [] call ALIVE_fnc_hashCreate;
    [ALIVE_taskMarkers,_taskID,[]] call ALIVE_fnc_hashSet;
};

if(_taskID in (ALIVE_taskMarkers select 1)) then {

    _taskMarkers = [ALIVE_taskMarkers,_taskID] call ALIVE_fnc_hashGet;

    {
        deleteMarkerLocal _x;
    } forEach _taskMarkers;

    [ALIVE_taskMarkers,_taskID,[]] call ALIVE_fnc_hashSet;

}else{

    [ALIVE_taskMarkers,_taskID,[]] call ALIVE_fnc_hashSet;

};

_taskMarkers = [ALIVE_taskMarkers,_taskID] call ALIVE_fnc_hashGet;

// create the marker
_m = createMarkerLocal [format["%1_m1",_taskID], _position];
_m setMarkerSizeLocal _markerDimensions;
_m setMarkerColorLocal _markerColour;
_m setMarkerAlphaLocal _markerAlpha;
_m setMarkerShapeLocal _markerShape;

if(_markerShape == "ICON") then {
    _m setMarkerTypeLocal _markerType;
};

if(_markerText != "") then {
    _m setMarkerTextLocal _markerText;
};

_taskMarkers set [count _taskMarkers, _m];

// update the clients task markers
[ALIVE_taskMarkers,_taskID,_taskMarkers] call ALIVE_fnc_hashSet;