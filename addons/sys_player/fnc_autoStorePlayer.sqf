#include "\x\alive\addons\sys_player\script_component.hpp"
SCRIPT(autoStorePlayer);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_autoStorePlayer
Description:
Save all player data to a server side store, DB save optional

Parameters:
Array - The selected parameters

Returns:
Nothing

Examples:
(begin example)
        [ALiVE_fnc_autoStorePlayer, 10, [DEFAULT_INTERVAL, 10]] call CBA_fnc_addPerFrameHandler;
(end)

See Also:
- <ALIVE_fnc_player>

Author:
Tupolov
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_check","_autoSaveTime","_params","_delay"];

_params = _this select 0;
_delay = _params select 0;                  // seconds between saves to server memory
private _tick = _params param [1, _delay];  // seconds between calls of this handler

// Timed saves never ran: both checks compared against a last-save time that defaulted to the
// current time and was only ever set by a save. They now count this handler's calls, which CBA
// makes at a steady pace, so a call that runs late never pushes the next save back. CBA makes
// the first call on the frame after the handler is added, before anybody has been restored, so
// that call only starts the count.
private _memPasses = MOD(sys_player) getVariable ["timedSaveMemPasses", -1];
if (_memPasses < 0) exitWith {
    MOD(sys_player) setVariable ["timedSaveMemPasses", 0];
    MOD(sys_player) setVariable ["timedSaveDBPasses", 0];
};
_memPasses = _memPasses + 1;
private _dbPasses = (MOD(sys_player) getVariable ["timedSaveDBPasses", 0]) + 1;

// A database write needs Save to Database on, a working Data module and an Auto Save Interval
// above 0; blank is off. Only the Local store takes writes mid-mission: the Cloud store keeps
// each record's revision from the load and would refuse every write after the first.
_check = MOD(sys_player) getvariable ["storeToDB", false];
_autoSaveTime = MOD(sys_player) getVariable ["autoSaveTime", 0];
private _dbDue = _autoSaveTime > 0 && {_check} && {_dbPasses * _tick >= _autoSaveTime}
    && {!isNil "ALIVE_sys_data" && {!ALIVE_sys_data_DISABLED}}
    && {!isNil "ALiVE_SYS_DATA_SOURCE" && {ALiVE_SYS_DATA_SOURCE == "pns"}};
private _memDue = _dbDue || {_memPasses * _tick >= _delay};

// Say once if timed writes are set up but can't run, rather than leave the mission maker guessing.
if (_autoSaveTime > 0 && {_check} && {!isNil "ALiVE_SYS_DATA_SOURCE" && {ALiVE_SYS_DATA_SOURCE != "pns"}}
    && {!(MOD(sys_player) getVariable ["timedSaveSourceWarned", false])}) then {
    MOD(sys_player) setVariable ["timedSaveSourceWarned", true];
    ["SYS_PLAYER - AUTO SAVE INTERVAL IS SET BUT THE DATA MODULE'S DATABASE SOURCE IS %1: TIMED DATABASE WRITES ONLY RUN ON LOCAL", ALiVE_SYS_DATA_SOURCE] call ALiVE_fnc_dump;
};

MOD(sys_player) setVariable ["timedSaveMemPasses", [_memPasses, 0] select _memDue];
MOD(sys_player) setVariable ["timedSaveDBPasses", [_dbPasses, 0] select _dbDue];
TRACE_4("Checking timed saves", _memPasses, _dbPasses, _memDue, _dbDue);

if (_memDue) then {
    // Only players whose saved state has been restored, or who had none, and who aren't being
    // sent off for joining in the wrong role: saving anyone else would overwrite the record they
    // are about to be given. Each first sends the gear they carry now, since the server's copy
    // only changes when they move items in or out of a container, and the save runs a few
    // seconds later so that gear has arrived.
    // switchableUnits is where the player is in single player, as the module's own lookups know.
    private _candidates = playableUnits + switchableUnits;
    _candidates = _candidates arrayIntersect _candidates;
    private _units = _candidates select {
        private _uid = getPlayerUID _x;
        _uid != ""
            && {MOD(sys_player) getVariable [_uid + "_restored", false]}
            && {!(_x getVariable [QGVAR(kicked), false])}
    };
    {
        [[MOD(sys_player), "pushGear", [_x]], "ALiVE_fnc_player", _x, false] call BIS_fnc_MP;
    } foreach _units;

    [{
        params ["_pairs", "_dbDue"];
        {
            // the same player, still restored, five seconds on
            _x params ["_unit", "_uid"];
            if (!isNull _unit && {getPlayerUID _unit == _uid} && {MOD(sys_player) getVariable [_uid + "_restored", false]}) then {
                [MOD(sys_player), "setPlayer", [_unit]] call ALiVE_fnc_player;
            };
        } foreach _pairs;
        if (_dbDue) then {
            TRACE_1("Saving players to DB", diag_tickTime);
            [MOD(sys_player), "savePlayers", [false]] call ALiVE_fnc_player;
        };
    }, [_units apply {[_x, getPlayerUID _x]}, _dbDue], 5] call CBA_fnc_waitAndExecute;
};
