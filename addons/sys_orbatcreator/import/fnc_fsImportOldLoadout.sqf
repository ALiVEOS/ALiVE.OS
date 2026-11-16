#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsImportOldLoadout);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsImportOldLoadout

Description:
The loadout of a class exported by the classic ORBAT Creator
(ALiVE_orbatCreator_owned 1), in order:
    1. getArray ALiVE_orbatCreator_loadout, used when it passes
       ALiVE_fnc_fsDataLoadoutCheck;
    2. else getUnitLoadout of the class, with a note: the loadout was read from
       the weapon lists of the class, so its attachments need checking.
The init handler text is not read. Exports made before 11 Nov 2017 keep the loadout
only there and import through step 2.

Parameters:
    _class - STRING - the class
    _notes - ARRAY - notes are appended here

Returns:
    ARRAY - the loadout

Examples:
    (begin example)
    private _loadout = ["OLD_Rifleman", _notes] call ALiVE_fnc_fsImportOldLoadout;
    (end)

See Also:
    ALiVE_fnc_fsImportMan

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_class", "", [""]], ["_notes", [], [[]]]];

private _stored = getArray (configFile >> "CfgVehicles" >> _class >> "ALiVE_orbatCreator_loadout");
if (([_stored] call ALiVE_fnc_fsDataLoadoutCheck) select 0) exitWith { _stored };

_notes pushBack format ["%1: loadout read from the weapon lists of the class; check its attachments in the Arsenal.", _class];
getUnitLoadout _class
