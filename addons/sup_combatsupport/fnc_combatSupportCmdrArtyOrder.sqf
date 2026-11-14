#include "\x\alive\addons\sup_combatsupport\script_component.hpp"
SCRIPT(combatSupportCmdrArtyOrder);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_combatSupportCmdrArtyOrder

Description:
Commander's guns ordered from outside the game, for example from the War Room's live map.
Server side, and only for code already running on the server: a call that arrives by remoteExec
(from any machine) is refused, so a client can't use it to fire the guns. The same battery pick,
reach, ordnance and danger close refusal as the tablet (ALIVE_fnc_combatSupportCmdrArtyFire);
one order every 5 s per side. The Player Combat Support module's Commander artillery on call
setting is the tablet's and doesn't apply here; an asymmetric commander still answers with mortars
only. The side's players hear the HQ's call over the radio, as for the commander's own missions.

Parameters:
String or Side - whose guns: "WEST", "EAST", "GUER" / "INDEPENDENT", or a side
Array - grid position [x, y] or [x, y, z]
String - ordnance: HE, SMOKE or ILLUM
Number - rounds, 1 to 24 (clamped)
String - who gave the order, for the log (optional)

Returns:
Array - [true, "fired", battery entity id, metres] or [false, reason], the reason one of
"badargs", "refused" (remoteExec'd), "busy" (within 5 s of the side's last order), "noguns",
"nobattery" (the side has no batteries left at all), "friendlies"

Examples:
(begin example)
private _r = ["WEST", [3200, 5800], "HE", 6, "War Room: Jman"] call ALIVE_fnc_combatSupportCmdrArtyOrder;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith { [false, "refused"] };
if (isRemoteExecuted) exitWith {
    ["ALiVE CS - commander's guns order: refused a call sent by remoteExec from machine %1", remoteExecutedOwner] call ALiVE_fnc_dump;
    [false, "refused"]
};
private _say = { ["ALiVE CS - commander's guns order: %1", _this] call ALiVE_fnc_dump };
if !(_this isEqualType [] && {count _this in [4, 5]}) exitWith { "refused an order that is not [side, position, ordnance, rounds]" call _say; [false, "badargs"] };
_this params [["_side", "", ["", west]], ["_pos", [], [[]]], ["_ord", "", [""]], ["_count", 1, [0]], ["_by", "", [""]]];

if (_side isEqualType "") then {
    _side = switch (toUpper _side) do {
        case "WEST": {west};
        case "EAST": {east};
        case "GUER";
        case "INDEPENDENT";
        case "RESISTANCE": {resistance};
        default {sideUnknown};
    };
};
if !(_side in [west, east, resistance]) exitWith { "refused an order without a usable side" call _say; [false, "badargs"] };
if !(count _pos in [2, 3] && {(_pos findIf { !(_x isEqualType 0) || {!finite _x} }) < 0}) exitWith { "refused an order without a usable grid" call _say; [false, "badargs"] };
_ord = toUpper _ord;
if !(_ord in ["HE", "SMOKE", "ILLUM"]) exitWith { format ["refused an order for %1 rounds", _ord] call _say; [false, "badargs"] };
_count = ((round _count) max 1) min 24;
_pos = [_pos select 0, _pos select 1, 0];
private _grid = mapGridPosition _pos;
if (_by == "") then { _by = "an order from outside the game" };

// one order every 5 s per side
if (isNil "ALiVE_CS_cmdrArtyOrderLast") then { ALiVE_CS_cmdrArtyOrderLast = createHashMap };
private _key = str _side;
if (time - (ALiVE_CS_cmdrArtyOrderLast getOrDefault [_key, -100]) < 5) exitWith { format ["refused %1: the side's last order was under 5 s ago", _by] call _say; [false, "busy"] };
ALiVE_CS_cmdrArtyOrderLast set [_key, time];

private _cmdrArtyFireAllowed = true;
private _r = [_side, _pos, _ord, _count, false, objNull] call ALIVE_fnc_combatSupportCmdrArtyFire;
_r params ["_fired", "_what", "_dist"];
if (!_fired) exitWith {
    format ["%1 asked %2 for %3 %4 at %5: %6", _by, _side, _count, _ord, _grid, switch (_what) do { case "friendlies": {"friendlies near the grid"}; case "nobattery": {"the side has no batteries left"}; default {"no ready battery reaches it"} }] call _say;
    [false, _what]
};
format ["%1 asked %2 for %3 %4 at %5: battery %6 (%7 m) fires", _by, _side, _count, _ord, _grid, _what, _dist] call _say;
[true, "fired", _what, _dist]
