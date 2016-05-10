#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(C2OnPlayerConnected);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_C2OnPlayerConnected
Description:

On connection of player

Parameters:

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

if (isServer) then {

    private ["_id","_name","_uid"];

    _id = _this select 0;
    _name = _this select 1;
    _uid = _this select 2;

    if (_name == "__SERVER__" || _uid == "") exitWith {};

    [_uid] spawn {

        private ["_uid","_unit"];

        _uid = _this select 0;

        _unit = [_uid] call ALIVE_fnc_getPlayerByUIDOnConnect;

        if !(isNull _unit) then {

            private ["_groupID","_playerID","_event"];

            _groupID = str (group _unit);
            _playerID = getPlayerUID _unit;

            _event = ['TASKS_SYNC', [_playerID,_groupID], "PLAYER"] call ALIVE_fnc_event;

            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

        };
    };
};