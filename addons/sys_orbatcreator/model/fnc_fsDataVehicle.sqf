#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataVehicle);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataVehicle

Description:
Edits the vehicles of a studio faction: the same operations as
ALiVE_fnc_fsDataUnit ("add", "set", "duplicate", "delete", "move"), run on the
vehicles dictionary. "set" of crewUnit checks the unit id exists; a deleted
vehicle is also taken out of every group it was a member of.

Parameters:
    _op      - STRING - the operation
    _args    - ARRAY - its arguments
    _faction - HASHMAP - optional, default missionNamespace ALiVE_FS_faction

Returns:
    per operation, as ALiVE_fnc_fsDataUnit

Examples:
    (begin example)
    private _id = ["add", [_entry]] call ALiVE_fnc_fsDataVehicle;
    ["set", [_id, "crewUnit", "u3"]] call ALiVE_fnc_fsDataVehicle;
    (end)

See Also:
    ALiVE_fnc_fsDataUnit, ALiVE_fnc_fsDataRefs

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_op", "", [""]], ["_args", [], [[]]], ["_faction", objNull]];

[_op, _args, _faction, "vehicle"] call ALiVE_fnc_fsDataUnit
