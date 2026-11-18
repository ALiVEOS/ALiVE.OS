#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenAlive);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenAlive

Description:
The faction's CfgALiVEFactions block: how ALiVE finds its groups, and its
supplies, supports, transport, air transport, containers and AA, so a mission
needs no script and ALiVE no CustomFactions entry. ALiVE reads it when it loads
its faction data; without ALiVE (or on an ALiVE build that predates it) the
class is unknown and nothing reads it, so the mod still does not require ALiVE.

groupSide and groupFaction always name the faction itself, which tells ALiVE
to use the faction's own groups as they are. GroupTypes is written only for a
redirect (an empty ALiVE category drawn from another of the faction's
categories); that is the one case where ALiVE registers a mapping for it.
A list is written only when it has something in it, so ALiVE keeps using its
side's list otherwise. Empty when the plan has no ALiVE block.

Parameters:
    _plan    - HASHMAP - from ALiVE_fnc_fsGenPlan
    _faction - HASHMAP - the snapshot

Returns:
    ARRAY - lines

Examples:
    (begin example)
    _lines append ([_plan, _faction] call ALiVE_fnc_fsGenAlive);
    (end)

See Also:
    ALiVE_fnc_fsGenPlan, ALiVE_fnc_fsAlivePicks

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_plan", createHashMap, [createHashMap]], ["_faction", createHashMap, [createHashMap]]];

if !(_plan getOrDefault ["hook", false]) exitWith { [] };

private _q = { [_this] call ALiVE_fnc_fsGenQuote };
private _a = { [_this] call ALiVE_fnc_fsGenArray };
private _class = _faction getOrDefault ["class", _plan get "tag"];
private _side = _faction getOrDefault ["side", 1];
private _lists = _plan getOrDefault ["alive", createHashMap];
private _types = _plan getOrDefault ["aliveTypes", []];
private _i = "        ";

private _lines = [
    "class CfgALiVEFactions {",
    format ["    class %1 {", _class],
    format ["%1version = %2;", _i, FS_ALIVE_HOOK_VER toFixed 0]
];
if (_side != 3) then {
    _lines pushBack (_i + "groupSide = " + ((["East", "West", "Indep"] select _side) call _q) + ";");
    _lines pushBack (_i + "groupFaction = " + (_class call _q) + ";");
    if (count _types > 0) then {
        _lines pushBack (_i + "class GroupTypes {");
        { _lines pushBack format ["%1    %2 = %3;", _i, _x select 0, (_x select 1) call _q] } forEach _types;
        _lines pushBack (_i + "};");
    };
};
{
    private _list = _lists getOrDefault [_x, []];
    if (count _list > 0) then { _lines pushBack format ["%1%2[] = %3;", _i, _x, _list call _a] };
} forEach ["supplies", "supports", "transport", "airTransport", "containers", "aa"];
if ((_faction getOrDefault ["alive", createHashMap]) getOrDefault ["rarity", true]) then { _lines pushBack (_i + "rarity = 1;") };
_lines append ["    };", "};"];
_lines
