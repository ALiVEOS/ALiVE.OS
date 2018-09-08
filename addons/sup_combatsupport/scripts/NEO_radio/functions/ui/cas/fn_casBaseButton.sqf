private ["_display", "_casUnitLb", "_casArray", "_veh", "_callsign", "_callSignPlayer", "_pos"];
_display = findDisplay 655555;
_casUnitLb = _display displayCtrl 655582;
_casArray = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", playerSide];
_veh = _casArray select (lbCurSel _casUnitLb) select 0;
_callsign = _casArray select (lbCurSel _casUnitLb) select 2;
_callSignPlayer = (format ["%1", group player]) call NEO_fnc_callsignFix;
_pos = _veh getVariable ["ALIVE_CombatSupport_Base", []];

//Task
_veh setVariable ["NEO_radioCasNewTask", ["RTB", _pos, 0, 0, "", "", player], true];
[player, format ["%1. Return to base. Over.", _callsign, _callSignPlayer], "side"] call NEO_fnc_messageBroadcast;

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
