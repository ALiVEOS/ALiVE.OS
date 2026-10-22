#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobCap);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_fobCap

Description:
How many FOBs a side may have. FOB Limit picks one of two rules: Fixed, the same number for
every side (Fixed Limit, 1 to 12), or Dynamic, Starting FOBs plus one more for every
Objectives Per FOB the side holds, up to Most FOBs. A Fixed Limit that isn't a number falls
back to Dynamic, with a warning, rather than allowing none.

What a side holds: with an AI Commander, its objectives in a defend or reserve state (an
insurgent commander says defending and reserving). Without one, as for players on their own,
the other commanders' objectives where that side has units and no hostile side has, within
300 m. FOBs never count towards it, or a FOB would earn its own side more FOBs.

Parameters:
String - The operation
Array - Its arguments

Returns:
resolve - [] -> ["DYNAMIC"] or ["FIXED", n]
heldCount - [side string] -> number of objectives held
capForSide - [side string] -> how many FOBs that side may have
countForSide - [side string] -> how many it has
canDeploy - [side string] -> true when it may deploy another

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};

params [["_operation", "", [""]], ["_args", [], [[]]]];

private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
private _set = { [_logic, "attribute", [_this]] call ALiVE_fnc_FOB };
private _result = nil;

switch (_operation) do {

    case "resolve": {
        if (("fob_cap_type" call _set) == "FIXED") then {
            private _raw = _logic getVariable ["fob_cap", "3"];
            private _n = if (_raw isEqualType "") then { parseNumber _raw } else { _raw };
            if (!(_n isEqualType 0) || {_n == 0}) then {
                ["ALiVE Player FOBs - Fixed Limit %1 isn't a number of FOBs; using the dynamic limit instead", _raw] call ALiVE_fnc_dumpR;
                _result = ["DYNAMIC"];
            } else {
                _result = ["FIXED", (round _n max 1) min 12];
            };
        } else {
            _result = ["DYNAMIC"];
        };
    };

    case "heldCount": {
        _args params [["_side", "WEST", [""]]];
        private _isFob = { !isNil {[_this, "fobID"] call ALiVE_fnc_hashGet} };
        private _opcoms = missionNamespace getVariable ["OPCOM_instances", []];
        private _own = _opcoms select { ([_x, "side", ""] call ALiVE_fnc_hashGet) == _side };
        private _held = 0;
        if (_own isNotEqualTo []) then {
            {
                {
                    if (!(_x call _isFob) && {([_x, "opcom_state", ""] call ALiVE_fnc_hashGet) in ["defend","defending","reserve","reserving"]}) then {
                        _held = _held + 1;
                    };
                } forEach +([_x, "objectives", []] call ALiVE_fnc_hashGet);
            } forEach _own;
        } else {
            // No commander of its own: an objective counts when this side has units there
            // (virtual groups, or soldiers and players on the ground) and no hostile side has,
            // within 300 m, the same reach and hostility test ALiVE_fnc_isHeldObjective uses.
            ([_side] call ALiVE_fnc_getSideAllegiances) params [["_enemySides", [], [[]]]];
            private _enemyObjs = _enemySides apply { [_x] call ALiVE_fnc_sideTextToObject };
            private _sideObj = [_side] call ALiVE_fnc_sideTextToObject;
            {
                if (([_x, "side", ""] call ALiVE_fnc_hashGet) != _side) then {
                    {
                        private _pos = [_x, "center", [0,0,0]] call ALiVE_fnc_hashGet;
                        if !(_x call _isFob) then {
                            private _men = (_pos nearEntities [["Man","Car","Tank"], 300]) select { alive _x };
                            private _ours = (_men findIf { side _x isEqualTo _sideObj } > -1)
                                || {([_pos, 300, [_side, "entity"], true] call ALiVE_fnc_getNearProfiles) isNotEqualTo []};
                            private _theirs = (_men findIf { (side _x in _enemyObjs) || {side _x isEqualTo sideEnemy} } > -1)
                                || {([_pos, 300, [_enemySides, "entity"], true] call ALiVE_fnc_getNearProfiles) isNotEqualTo []};
                            if (_ours && {!_theirs}) then { _held = _held + 1 };
                        };
                    } forEach +([_x, "objectives", []] call ALiVE_fnc_hashGet);
                };
            } forEach _opcoms;
        };
        _result = _held;
    };

    case "capForSide": {
        _args params [["_side", "WEST", [""]]];
        private _rule = ["resolve"] call ALiVE_fnc_fobCap;
        if ((_rule select 0) == "FIXED") then {
            _result = _rule select 1;
        } else {
            private _held = ["heldCount", [_side]] call ALiVE_fnc_fobCap;
            _result = ("fob_cap_max" call _set) min (("fob_cap_base" call _set) + floor (_held / ("fob_cap_per" call _set)));
        };
    };

    case "countForSide": {
        _args params [["_side", "WEST", [""]]];
        _result = count ([_logic, "registryIDs", [_side]] call ALiVE_fnc_FOB);
    };

    // A FOB type's own limit (FOB Types' cap, 0 for none), on top of the side's
    case "countForType": {
        _args params [["_side", "WEST", [""]], ["_type", "", [""]]];
        _result = {
            ([[ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet, "type", ""] call ALIVE_fnc_hashGet) == _type
        } count ([_logic, "registryIDs", [_side]] call ALiVE_fnc_FOB);
    };

    case "canDeployType": {
        _args params [["_side", "WEST", [""]], ["_type", "", [""]]];
        private _cap = ([_logic, "typeSpec", [_type]] call ALiVE_fnc_FOB) param [11, 0];
        _result = _type == "" || {_cap <= 0} || {(["countForType", [_side, _type]] call ALiVE_fnc_fobCap) < _cap};
    };

    case "canDeploy": {
        _args params [["_side", "WEST", [""]]];
        _result = (["countForSide", [_side]] call ALiVE_fnc_fobCap) < (["capForSide", [_side]] call ALiVE_fnc_fobCap);
    };
};

if (isNil "_result") then { nil } else { _result }
