private ["_display", "_artyUnitLb", "_artyArray", "_battery", "_callsign", "_callSignPlayer"];
_display = findDisplay 655555;
_artyUnitLb = _display displayCtrl 655594;
_artyArray = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", playerSide];
_battery = _artyArray select (lbCurSel _artyUnitLb) select 0; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _battery = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 0 };
_callsign = _artyArray select (lbCurSel _artyUnitLb) select 2; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _callsign = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 1 };
_callSignPlayer = (format ["%1", group player]) call NEO_fnc_callsignFix;

_battery setVariable ["NEO_radioArtyGoToBase", true, true];
[player, format ["%1, this is %2. Abort fire mission and return to base. Over.", _callsign, _callSignPlayer], "side"] call NEO_fnc_messageBroadcast;

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
