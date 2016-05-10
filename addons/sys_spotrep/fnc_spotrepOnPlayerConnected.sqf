#include <\x\alive\addons\sys_spotrep\script_component.hpp>
SCRIPT(spotrepOnPlayerConnected);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_spotrepOnPlayerConnected
Description:

On connection of player

Parameters:

Returns:

See Also:

Author:
Tupolov

Peer Reviewed:
nil
---------------------------------------------------------------------------- */
private ["_id","_name","_uid","_owner","_jip"];
_id = _this select 0;
_name = _this select 1;
_uid = _this select 2;
_owner = _this select 3;
_jip = _this select 4;

[_uid, _owner] spawn {

    private ["_uid","_unit","_player","_playerGUID","_owner"];

    _uid = _this select 0;
    _owner = _this select 1;

    _unit = objNull;

    _unit = [_uid] call ALIVE_fnc_getPlayerByUIDOnConnect;

    if !(isNull _unit) then {

        waituntil {MOD(sys_spotrep) getvariable ["init",false]};

        waitUntil{sleep 1; !(isNil QGVAR(store))};

        // Send latest version of GVAR(STORE)
        _owner publicVariableClient QGVAR(store);
    };

};