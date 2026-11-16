#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataToText);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataToText

Description:
Turns a studio faction into its share text, one line:
    ALIVEFS|<schema>|<length>|<payload>
<payload> is str of the plain form and <length> is its character count, so a
paste that was cut short is caught before anything is parsed. Both numbers are
written with toFixed 0 (str writes large numbers as 1.2e+06).

Parameters:
    _faction - HASHMAP or ARRAY - the faction, or its plain form

Returns:
    STRING - the share text

Examples:
    (begin example)
    copyToClipboard ([missionNamespace getVariable "ALiVE_FS_faction"] call ALiVE_fnc_fsDataToText);
    (end)

See Also:
    ALiVE_fnc_fsDataParse, ALiVE_fnc_fsDataToPlain

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap, []]]];

private _plain = if (_faction isEqualType []) then { _faction } else { [_faction] call ALiVE_fnc_fsDataToPlain };
private _payload = str _plain;

// Joined with + rather than format, so a long payload is never cut.
"ALIVEFS|" + (FS_SCHEMA toFixed 0) + "|" + ((count _payload) toFixed 0) + "|" + _payload
