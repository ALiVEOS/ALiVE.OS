#include "\x\alive\addons\sys_perf\script_component.hpp"
SCRIPT(perfShow);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_perfShow
Description:
Turns the admin's Show Perf readout on or off (#1031). While it is on, a hint shows
the server's latest performance sample and refreshes every 5 seconds.

Parameters:
None

Returns:
Nil

See Also:
- <ALIVE_fnc_perfServer>

Author:
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};

GVAR(SHOW) = !(missionNamespace getVariable [QGVAR(SHOW), false]);

if (!GVAR(SHOW)) exitWith { hintSilent "" };

[] spawn {
    while {missionNamespace getVariable [QGVAR(SHOW), false]} do {
        private _text = if !(missionNamespace getVariable [QGVAR(RUNNING), false]) then {
            parseText format ["<t size='1.1'>%1</t><br/>%2", localize "STR_ALIVE_PERF_SERVER", localize "STR_ALIVE_PERF_OFF"]
        } else {
            if (isNil QGVAR(LAST)) then {
                parseText format ["<t size='1.1'>%1</t><br/>%2", localize "STR_ALIVE_PERF_SERVER", localize "STR_ALIVE_PERF_WAITING"]
            } else {
                // plain labels on screen; the RPT keeps the short field names, which are easier to search
                private _rows = GVAR(LAST) apply {
                    _x params ["_key", "_value"];
                    if (_key == "time") then { _value = [_value / 3600, "HH:MM:SS"] call BIS_fnc_timeToString };
                    private _label = localize format ["STR_ALIVE_PERF_L_%1", toUpper _key];
                    if (_label == "") then { _label = _key };
                    format ["<t align='left'>%1</t><t align='right'>%2</t>", _label, _value]
                };
                parseText format ["<t size='1.1'>%1</t><br/>%2", localize "STR_ALIVE_PERF_SERVER", _rows joinString "<br/>"]
            };
        };
        hintSilent _text;
        sleep 5;
    };
};
