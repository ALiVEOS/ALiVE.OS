#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobPlacement);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobPlacement

Description:
Placing a catalog item at a FOB, on the player's machine. A copy of the item that only this
player sees stands in front of them and follows as they move and turn; it is tinted green
where it can go (inside the FOB's build range, on land) and red where it can't, and an object
that can't be tinted gets a green or red outline instead. The copy collides with nothing. From the
scroll menu:
- Place puts it there: the server is asked to build it and charges the FOB's supply.
- Rotate turns it 45 degrees.
- Cancel stops.
Placing also stops if the player dies, gets into a vehicle or walks out of the build range.

Parameters:
String - "start" with [catalog row, FOB row from ALiVE_FOB_registryMirror] (for a new FOB's
headquarters [[class, name, "DEPLOY", 0], a FOB-like row centred on the kit, kit]), or "place",
"rotate", "cancel"; "surface" with [spot, height ASL, object to ignore] for the first surface
straight down from that height

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], ["_args", []]];
if (!hasInterface && {_operation != "surface"}) exitWith {};

// Where the item goes and whether it may: in front of the player, at the reach the item needs,
// turned by the player's heading plus their rotation. Worked out here for the preview and again
// for Place, so Place never sends a position the preview hadn't caught up with. A fortification
// or supply object sits on the first surface straight below the spot, looking down from just
// above the player's head: a roof the player stands on, a floor, or the ground. Static weapons
// and vehicles stay on the ground. Returns [position ATL, heading, can go, surface up, why not]:
// why not is [string key, its arguments] for the first rule that fails, [] when it can go.
ALiVE_FOB_placeSpot = {
    ALiVE_FOB_placeState params ["_row", "_fob", "_reach", "_turn"];
    _fob params ["", "", "", "_centre", "", "", "", "", "_range"];
    private _pos = player getPos [_reach, getDir player];
    _pos set [2, 0];
    private _up = surfaceNormal _pos;
    if ((_row select 2) in ["FORTIFICATION", "SUPPLY"]) then {
        (["surface", [_pos, ((eyePos player) select 2) + 1.5, ALiVE_FOB_ghost]] call ALiVE_fnc_fobPlacement) params ["_atl", "_n"];
        _pos = _atl; _up = _n;
    };
    private _deploying = (_row select 2) == "DEPLOY";
    private _why = call {
        if (_pos distance2D _centre > _range) exitWith {
            if (_deploying) then { ["STR_ALIVE_FOB_WHY_KIT", [round _range]] } else { ["STR_ALIVE_FOB_WHY_RANGE", [round _range]] }
        };
        if (surfaceIsWater _pos) exitWith { ["STR_ALIVE_FOB_WHY_WATER", []] };
        if (!_deploying) exitWith { [] };
        // a headquarters: the server's own tests too
        if ((_up select 2) < 0.966) exitWith { ["STR_ALIVE_FOB_WHY_SLOPE", [round acos ((_up select 2) min 1)]] };
        private _min = (missionNamespace getVariable ["ALiVE_sup_fob", objNull]) getVariable ["fob_min_distance", 500];
        if (_min isEqualType "") then { _min = parseNumber _min };
        private _rows = missionNamespace getVariable ["ALiVE_FOB_registryMirror", []];
        private _i = _rows findIf { ((_x select 3) distance2D _pos) < _min };
        if (_i >= 0) exitWith { ["STR_ALIVE_FOB_WHY_NEAR", [(_rows select _i) select 2, round (((_rows select _i) select 3) distance2D _pos), round _min]] };
        // the side's FOB limit, as the server last sent it: [side, FOBs, limit]
        private _side = str (side group player);
        private _room = (missionNamespace getVariable ["ALiVE_FOB_sideRoom", []]) select { (_x select 0) == _side };
        if (_room isNotEqualTo [] && {((_room select 0) select 1) >= ((_room select 0) select 2)}) exitWith { ["STR_ALIVE_FOB_WHY_CAP", [(_room select 0) select 2]] };
        []
    };
    [_pos, (getDir player + _turn) % 360, _why isEqualTo [], _up, _why]
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
        _args params ["_row", "_fob", ["_kit", objNull]];
        _row params ["_class", "_name", "_kind", "_cost"];
        private _g = _class createVehicleLocal [0, 0, 0];
        if (isNull _g) exitWith {};
        _g enableSimulation false;
        _g allowDamage false;
        // collides with nothing, so moving it through soldiers, crates or vehicles hurts none of them
        _g setPhysicsCollisionFlag false;
        _g disableCollisionWith player;
        private _bb = boundingBoxReal _g;
        private _d = (_bb select 1) vectorDiff (_bb select 0);
        private _reach = ((((abs (_d select 0)) max (abs (_d select 1))) / 2) + 2) max 4;
        // tinted when the object has texture slots to tint
        private _slots = count (getArray (configFile >> "CfgVehicles" >> _class >> "hiddenSelections"));

        ALiVE_FOB_ghost = _g;
        ALiVE_FOB_placing = true;
        ALiVE_FOB_lastWhy = "";
        ALiVE_FOB_placeState = [_row, _fob, _reach, 0, _slots, _bb, false, _kit];

        ALiVE_FOB_placeDraw = addMissionEventHandler ["Draw3D", {
            private _g = ALiVE_FOB_ghost;
            ALiVE_FOB_placeState params ["_row", "_fob", "_reach", "_turn", "_slots", "_bb", "_wasOk", "_kit"];
            if (isNull _g || {!alive player} || {vehicle player != player}) exitWith { ["cancel"] call ALiVE_fnc_fobPlacement };
            private _deploying = (_row select 2) == "DEPLOY";
            // the kit gone (deployed by someone else, or moved off) ends a deploy
            if (_deploying && {isNull _kit || {isNil {_kit getVariable "ALiVE_FOB_kit"}}}) exitWith { ["cancel"] call ALiVE_fnc_fobPlacement };
            _fob params ["", "", "", "_centre", "", "", "", "", "_range"];
            if (player distance2D _centre > _range + 10) exitWith {
                ["cancel"] call ALiVE_fnc_fobPlacement;
                [localize "STR_ALIVE_FOB", localize (["STR_ALIVE_FOB_PLACE_LEFT", "STR_ALIVE_FOB_PLACE_LEFT_KIT"] select _deploying)] call ALIVE_fnc_sendHint;
            };
            (call ALiVE_FOB_placeSpot) params ["_pos", "_dir", "_ok", "_up", "_why"];
            if (_why isNotEqualTo [] && {(_why select 0) != (missionNamespace getVariable ["ALiVE_FOB_lastWhy", ""])}) then {
                [localize "STR_ALIVE_FOB", format ([localize (_why select 0)] + (_why select 1))] call ALIVE_fnc_sendHint;
            };
            ALiVE_FOB_lastWhy = _why param [0, ""];
            private _tip = -((sin _dir) * (_up select 0) + (cos _dir) * (_up select 1)) / ((_up select 2) max 0.1);
            _g setVectorDirAndUp [vectorNormalized [sin _dir, cos _dir, _tip], _up];
            _g setPosATL _pos;
            if (_slots > 0) then {
                if (_ok isNotEqualTo _wasOk || {!(_g getVariable ["ALiVE_FOB_tinted", false])}) then {
                    private _tex = ["#(rgb,8,8,3)color(1,0,0,0.6)", "#(rgb,8,8,3)color(0,1,0,0.6)"] select _ok;
                    for "_i" from 0 to (_slots - 1) do { _g setObjectTexture [_i, _tex] };
                    _g setVariable ["ALiVE_FOB_tinted", true];
                };
            } else {
                // an outline of the object's box: a ring at its top, a ring at its feet lifted just
                // clear of the ground (a model's lowest point is often below it), and the corners joined
                private _c = [[1,0,0,1], [0,1,0,1]] select _ok;
                (_bb select 0) params ["_x0", "_y0", "_z0"];
                (_bb select 1) params ["_x1", "_y1", "_z1"];
                private _corners = [[_x0,_y0], [_x1,_y0], [_x1,_y1], [_x0,_y1]];
                private _top = _corners apply { _g modelToWorldVisual [_x select 0, _x select 1, _z1] };
                private _base = _corners apply {
                    private _p = _g modelToWorldVisual [_x select 0, _x select 1, _z0];
                    [_p select 0, _p select 1, (_p select 2) max ((_pos select 2) + 0.05)]
                };
                {
                    private _ring = _x;
                    { drawLine3D [_ring select _forEachIndex, _ring select ((_forEachIndex + 1) % 4), _c] } forEach _ring;
                } forEach [_top, _base];
                { drawLine3D [_x, _top select _forEachIndex, _c] } forEach _base;
            };
            ALiVE_FOB_placeState set [6, _ok];
        }];

        ALiVE_FOB_placeActions = [
            player addAction [[format [localize "STR_ALIVE_FOB_ACTION_PLACE", [_name, _class] select (_name == ""), _cost], localize "STR_ALIVE_FOB_ACTION_DEPLOY_HERE"] select (_kind == "DEPLOY"), { ["place"] call ALiVE_fnc_fobPlacement }, nil, 10, true, true, "", "ALiVE_FOB_placing"],
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
        ALiVE_FOB_placeState params ["_row", "_fob", "", "", "", "", "", "_kit"];
        (call ALiVE_FOB_placeSpot) params ["_pos", "_dir", "_ok", "", "_why"];
        private _deploying = (_row select 2) == "DEPLOY";
        if !(_ok) exitWith { [localize "STR_ALIVE_FOB", format ([localize (_why select 0)] + (_why select 1)), true] call ALIVE_fnc_sendHint };
        call _fnc_stop;
        if (_deploying) exitWith { ["deploy", [_kit, _pos, _dir]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] };
        // the height as ASL: the server looks for a surface there itself rather than taking it on trust
        ["build", [_row select 0, ATLToASL _pos, _dir, _fob select 0]] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
    };

    case "cancel": {
        call _fnc_stop;
    };

    // The first surface straight down from a height (ASL) at a spot: [position ATL, its up]. Used
    // here and by the server's build, which runs it again from the height the player sent.
    case "surface": {
        _args params ["_spot", "_fromASL", ["_ignore", objNull]];
        private _ground = getTerrainHeightASL _spot;
        private _hits = lineIntersectsSurfaces [[_spot select 0, _spot select 1, _fromASL max (_ground + 0.1)], [_spot select 0, _spot select 1, _ground - 0.1], _ignore, objNull, true, 5, "GEOM", "NONE"];
        // never on top of a soldier standing there
        private _i = _hits findIf { isNull (_x select 2) || {!((_x select 2) isKindOf "CAManBase")} };
        private _hit = if (_i < 0) then { [] } else { _hits select _i };
        if (_hit isEqualTo [] || {isNull (_hit select 2)}) exitWith { [[_spot select 0, _spot select 1, 0], surfaceNormal _spot] };
        [ASLToATL (_hit select 0), _hit select 1]
    };
};
