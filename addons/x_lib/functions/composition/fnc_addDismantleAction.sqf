#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(addDismantleAction);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addDismantleAction

Description:
Lets players take apart a roadblock or a fortification once its area is clear (A. Ares on Discord,
14 Oct 2026). A traffic cone is set beside it, with a 15 second hold action that shows only when no
enemy of the player is within 60 m of the cone. Finishing it removes the composition (and its saved
copy) through ALIVE_fnc_removeComposition. Used for Military Placement roadblocks and the AI
Commander's prepared defences; insurgent roadblocks keep their own action. Server only.

Parameters:
    _this select 0: ARRAY  - the composition's position
    _this select 1: NUMBER - the radius it covers
    _this select 2: STRING - what it is, for the message ("roadblock", "fortifications")

Examples:
    (begin example)
    [_pos, 30, "roadblock"] call ALIVE_fnc_addDismantleAction;
    (end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_pos", [0,0,0], [[]]], ["_radius", 30, [0]], ["_what", "roadblock", [""]]];
if (!isServer) exitWith {};

[_pos, _radius, _what] spawn {
    params ["_pos", "_radius", "_what"];
    // the composition is spawned in its own thread; let it land first
    sleep 5;

    // a cone a few metres out, on clear ground where there is some
    private _conePos = _pos getPos [(_radius * 0.6) max 6, random 360];
    private _clear = _conePos findEmptyPosition [0, 12, "RoadCone_L_F"];
    if (_clear isNotEqualTo []) then { _conePos = _clear };
    private _cone = createVehicle ["RoadCone_L_F", _conePos, [], 0, "CAN_COLLIDE"];
    _cone allowDamage false;
    _cone enableSimulationGlobal false;
    _cone setVectorUp (surfaceNormal (getPosWorld _cone));
    _cone setVariable ["ALiVE_dismantle", [_pos, _radius, _what], true];

    private _clearArea = "({alive _x && {(side group _x) getFriend (side group _this) < 0.6}} count (_target nearEntities [['CAManBase','LandVehicle','StaticWeapon'], 60])) == 0";
    [
        _cone,
        format ["Dismantle the %1", _what],
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "_this distance2D _target < 8 && {" + _clearArea + "}",
        "_caller distance2D _target < 8",
        {},
        {},
        {
            params ["_target", "_caller", "_ID"];
            (_target getVariable ["ALiVE_dismantle", []]) params [["_pos", getPosATL _target], ["_radius", 30], ["_what", "roadblock"]];
            [_target, _ID] remoteExec ["BIS_fnc_holdActionRemove", 0, _target];
            [_pos, _radius] remoteExec ["ALiVE_fnc_removeComposition", 2];
            ["ALiVE", format ["%1 dismantled the %2 at grid %3.", name _caller, _what, mapGridPosition _pos]] remoteExec ["ALIVE_fnc_sendHint", side (group _caller)];
            [_target] remoteExec ["deleteVehicle", 2];
        },
        {},
        [],
        15
    // as for the insurgent roadblocks: a dedicated server has no player to hold it
    ] remoteExec ["BIS_fnc_holdActionAdd", [0, -2] select isDedicated, _cone];
};
