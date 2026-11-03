#include "\x\alive\addons\sys_data\script_component.hpp"
SCRIPT(writeData_WarRoom);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_writeData_WarRoom
Description:
Sends one record to the War Room on alivemod.com through the alive_wr extension
(@alive_wr, server side). The extension signs it with the server's key, keeps it
on disk until alivemod.com accepts it, and never makes the game wait, so this
returns at once whether or not the War Room can be reached.

Called by ALIVE_fnc_Data for the "write" operation with source "WarRoom"; ALiVE
Statistics uses it when the Data module found the War Room link
(ALiVE_sys_data_warRoom).

Parameters:
Array - the data handler logic (unused)
Array - [module, data, async]:
    module: String - the record's path at the War Room, for example "events"
    data: Array of [key, value] pairs, or a CBA hash
    async: Bool - ignored, sending is always in the background

Returns:
String - the record's id, or "ERROR" if the extension refused it

Examples:
(begin example)
[ALiVE_sys_data_datahandler, "write", ["events", [["Event","Kill"],["Killer","Bob"]], true], "WarRoom"] call ALIVE_fnc_Data;
(end)

See Also:
- <ALIVE_fnc_Data>
- <ALiVE_fnc_encodeJSON>

Author:
Jman

Peer Reviewed:
---------------------------------------------------------------------------- */
params ["_logic", "_args"];
_args params ["_module", "_data"];

// The same pairs a CBA hash holds.
private _pairs = if (_data isEqualType [] && {count _data == 4} && {(_data select 0) isEqualTo "#CBA_HASH#"}) then {
    private _out = [];
    { _out pushBack [_x, (_data select 2) select _forEachIndex] } forEach (_data select 1);
    _out
} else {
    _data
};

private _json = "{";
{
    _x params ["_key", "_value"];
    if (_forEachIndex > 0) then { _json = _json + "," };
    _json = _json + ((if (_key isEqualType "") then {_key} else {str _key}) call ALiVE_fnc_encodeJSON) + ":" + (_value call ALiVE_fnc_encodeJSON);
} forEach _pairs;
_json = _json + "}";

private _reply = "alive_wr" callExtension ["send", [_module, _json]];
_reply params [["_id", ""], ["_code", -1]];

if (_code != 0) exitWith {
    ["ALiVE War Room: could not send a %1 record: %2", _module, _id] call ALiVE_fnc_dump;
    "ERROR"
};
_id
