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
                private _rows = GVAR(LAST) apply {format ["<t align='left'>%1</t><t align='right'>%2</t>", _x select 0, _x select 1]};
                parseText format ["<t size='1.1'>%1</t><br/>%2", localize "STR_ALIVE_PERF_SERVER", _rows joinString "<br/>"]
            };
        };
        hintSilent _text;
        sleep 5;
    };
};
