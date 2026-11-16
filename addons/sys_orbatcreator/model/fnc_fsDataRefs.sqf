#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataRefs);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataRefs

Description:
Where a unit or vehicle id is used in a studio faction: as a group member, as a
vehicle's crew, or as a turret's gunner. "clean" also removes those uses (members
dropped, crew and gunner set back to "", meaning as the base vehicle), which is
what a delete does so no reference to the deleted entry remains.

Parameters:
    _op      - STRING - "count" or "clean"
    _id      - STRING - the unit or vehicle id
    _faction - HASHMAP - optional, default missionNamespace ALiVE_FS_faction

Returns:
    ARRAY - [groups, seats] as found before any clean: the number of groups that
            have it as a member, and the number of crew and gunner seats set to it

Examples:
    (begin example)
    (["count", "u12"] call ALiVE_fnc_fsDataRefs) params ["_groups", "_seats"];
    (end)

See Also:
    ALiVE_fnc_fsDataUnit, ALiVE_fnc_fsDataVehicle

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_op", "count", [""]], ["_id", "", [""]], ["_faction", objNull]];

if !(_faction isEqualType createHashMap) then { _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap] };
if (_id isEqualTo "") exitWith { [0, 0] };

private _clean = _op isEqualTo "clean";
private _groups = 0;
private _seats = 0;

{
    private _grp = _y;
    private _members = _grp getOrDefault ["members", []];
    private _kept = _members select { !((_x getOrDefault ["ref", ""]) isEqualTo _id) };
    if ((count _kept) != (count _members)) then {
        _groups = _groups + 1;
        if (_clean) then { _grp set ["members", _kept] };
    };
} forEach (_faction getOrDefault ["groups", createHashMap]);

{
    private _veh = _y;
    if ((_veh getOrDefault ["crewUnit", ""]) isEqualTo _id) then {
        _seats = _seats + 1;
        if (_clean) then { _veh set ["crewUnit", ""] };
    };
    {
        if ((_x getOrDefault ["gunnerUnit", ""]) isEqualTo _id) then {
            _seats = _seats + 1;
            if (_clean) then { _x set ["gunnerUnit", ""] };
        };
    } forEach (_veh getOrDefault ["turrets", []]);
} forEach (_faction getOrDefault ["vehicles", createHashMap]);

[_groups, _seats]
