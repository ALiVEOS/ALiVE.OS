#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobPlacement);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobPlacement

Description:
Placing a catalog item at a FOB, on the player's machine. A copy of the item that only this
player sees stands in front of them and follows as they move and turn; it is tinted green
where it can go (inside the FOB's build range, on land) and red where it can't, and an object
that can't be tinted gets a green or red outline instead. From the scroll menu:
- Place puts it there: the server is asked to build it and charges the FOB's supply.
- Rotate turns it 45 degrees.
- Cancel stops.
Placing also stops if the player dies, gets into a vehicle or walks out of the build range.

Parameters:
String - "start" with [catalog row, FOB row from ALiVE_FOB_registryMirror], or "place",
"rotate", "cancel"

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};

params [["_operation", "", [""]], ["_args", []]];

// Where the item goes and whether it may: in front of the player, at the reach the item needs,
// turned by the player's heading plus their rotation. Worked out here for the preview and again
// for Place, so Place never sends a position the preview hadn't caught up with.
ALiVE_FOB_placeSpot = {
    ALiVE_FOB_placeState params ["", "_fob", "_reach", "_turn"];
    _fob params ["", "", "", "_centre", "", "", "", "", "_range"];
    private _pos = player getPos [_reach, getDir player];
    _pos set [2, 0];
    [_pos, (getDir player + _turn) % 360, (_pos distance2D _centre <= _range) && {!surfaceIsWater _pos}]
};

private _fnc_stop = {
    if (!isNil "ALiVE_FOB_placeDraw") then { removeMissionEventHandler ["Draw3D", ALiVE_FOB_placeDraw]; ALiVE_FOB_placeDraw = nil };
    { player removeAction _x } forEach (missionNamespace getVariable ["ALiVE_FOB_placeActions", []]);
    ALiVE_FOB_placeActions = [];
    private _g = missionNamespace getVariable ["ALiVE_FOB_ghost", objNull];
    if (!isNull _g) then { deleteVehicle _g };
    ALiVE_FOB_ghost = objNull;
    ALiVE_FOB_placing = false;
};

switch (_operation) do {

    case "start": {
        call _fnc_stop;
        _args params ["_row", "_fob"];
        _row params ["_class", "_name", "", "_cost"];
        private _g = _class createVehicleLocal [0, 0, 0];
        if (isNull _g) exitWith {};
        _g enableSimulation false;
        _g allowDamage false;
        _g disableCollisionWith player;
        private _bb = boundingBoxReal _g;
        private _d = (_bb select 1) vectorDiff (_bb select 0);
        private _reach = ((((abs (_d select 0)) max (abs (_d select 1))) / 2) + 2) max 4;
        // tinted when the object has texture slots to tint
        private _slots = count (getArray (configFile >> "CfgVehicles" >> _class >> "hiddenSelections"));

        ALiVE_FOB_ghost = _g;
        ALiVE_FOB_placing = true;
        ALiVE_FOB_placeState = [_row, _fob, _reach, 0, _slots, _bb, false];

        ALiVE_FOB_placeDraw = addMissionEventHandler ["Draw3D", {
            private _g = ALiVE_FOB_ghost;
            ALiVE_FOB_placeState params ["_row", "_fob", "_reach", "_turn", "_slots", "_bb", "_wasOk"];
            if (isNull _g || {!alive player} || {vehicle player != player}) exitWith { ["cancel"] call ALiVE_fnc_fobPlacement };
            _fob params ["", "", "", "_centre", "", "", "", "", "_range"];
            if (player distance2D _centre > _range + 10) exitWith {
                ["cancel"] call ALiVE_fnc_fobPlacement;
                [localize "STR_ALIVE_FOB", localize "STR_ALIVE_FOB_PLACE_LEFT"] call ALIVE_fnc_sendHint;
            };
            (call ALiVE_FOB_placeSpot) params ["_pos", "_dir", "_ok"];
            _g setPosATL _pos;
            private _up = surfaceNormal _pos;
            private _tip = -((sin _dir) * (_up select 0) + (cos _dir) * (_up select 1)) / ((_up select 2) max 0.1);
            _g setVectorDirAndUp [vectorNormalized [sin _dir, cos _dir, _tip], _up];
            if (_slots > 0) then {
                if (_ok isNotEqualTo _wasOk || {!(_g getVariable ["ALiVE_FOB_tinted", false])}) then {
                    private _tex = ["#(rgb,8,8,3)color(1,0,0,0.6)", "#(rgb,8,8,3)color(0,1,0,0.6)"] select _ok;
                    for "_i" from 0 to (_slots - 1) do { _g setObjectTexture [_i, _tex] };
                    _g setVariable ["ALiVE_FOB_tinted", true];
                };
            } else {
                // an outline of the object's box, at its feet and its top
                private _c = [[1,0,0,1], [0,1,0,1]] select _ok;
                (_bb select 0) params ["_x0", "_y0", "_z0"];
                (_bb select 1) params ["_x1", "_y1", "_z1"];
                {
                    private _z = _x;
                    private _pts = [[_x0,_y0,_z], [_x1,_y0,_z], [_x1,_y1,_z], [_x0,_y1,_z]] apply { _g modelToWorldVisual _x };
                    { drawLine3D [_pts select _forEachIndex, _pts select ((_forEachIndex + 1) % 4), _c] } forEach _pts;
                } forEach [_z0, _z1];
            };
            ALiVE_FOB_placeState set [6, _ok];
        }];

        ALiVE_FOB_placeActions = [
            player addAction [format [localize "STR_ALIVE_FOB_ACTION_PLACE", [_name, _class] select (_name == ""), _cost], { ["place"] call ALiVE_fnc_fobPlacement }, nil, 10, true, true, "", "ALiVE_FOB_placing"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_ROTATE", { ["rotate"] call ALiVE_fnc_fobPlacement }, nil, 9.9, false, false, "", "ALiVE_FOB_placing"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_CANCEL", { ["cancel"] call ALiVE_fnc_fobPlacement }, nil, 9.8, false, true, "", "ALiVE_FOB_placing"]
        ];
        [localize "STR_ALIVE_FOB", localize "STR_ALIVE_FOB_PLACE_HELP", true] call ALIVE_fnc_sendHint;
    };

    case "rotate": {
        if (isNil "ALiVE_FOB_placeState") exitWith {};
        ALiVE_FOB_placeState set [3, ((ALiVE_FOB_placeState select 3) + 45) % 360];
    };

    case "place": {
        private _g = missionNamespace getVariable ["ALiVE_FOB_ghost", objNull];
        if (isNull _g) exitWith {};
        ALiVE_FOB_placeState params ["_row", "_fob"];
        (call ALiVE_FOB_placeSpot) params ["_pos", "_dir", "_ok"];
        if !(_ok) exitWith { [localize "STR_ALIVE_FOB", localize "STR_ALIVE_FOB_PLACE_BAD", true] call ALIVE_fnc_sendHint };
        call _fnc_stop;
        ["build", [_row select 0, _pos, _dir, _fob select 0]] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
    };

    case "cancel": {
        call _fnc_stop;
    };
};
