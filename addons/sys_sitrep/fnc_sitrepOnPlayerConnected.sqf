#include <\x\alive\addons\sys_sitrep\script_component.hpp>
SCRIPT(sitrepOnPlayerConnected);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sitrepOnPlayerConnected
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
private ["_id","_name","_uid"];

_id = _this select 0;
_name = _this select 1;
_uid = _this select 2;


[_uid] spawn {

    private ["_uid","_unit","_player","_playerGUID","_owner"];

    _uid = _this select 0;

    _unit = objNull;

    _unit = [_uid] call ALIVE_fnc_getPlayerByUIDOnConnect;

    if !(isNull _unit) then {

        _owner = owner _unit;

        waituntil {MOD(sys_sitrep) getvariable ["init",false]};

        waitUntil{sleep 1; !(isNil QGVAR(store))};

        // Send latest version of GVAR(STORE)
        _owner publicVariableClient QGVAR(store);
    };

};