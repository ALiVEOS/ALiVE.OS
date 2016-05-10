private ["_display", "_transportUnitLb", "_transportFlyHeightSlider"];
_display = findDisplay 655555;
_transportUnitLb = _display displayCtrl 655568;
_transportFlyHeightSlider = _display displayCtrl 655580;

private ["_transportArray", "_chopper", "_grp", "_callsign", "_callSignPlayer", "_task"];
_transportArray = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", playerSide];
_chopper = _transportArray select (lbCurSel _transportUnitLb) select 0; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithPilot" }) then { _chopper = vehicle player };
_grp = _transportArray select (lbCurSel _transportUnitLb) select 1; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithPilot" }) then { _grp = group (driver _chopper) };
_callsign = _transportArray select (lbCurSel _transportUnitLb) select 2; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithPilot" }) then { _callsign = (format ["%1", _grp]) call NEO_fnc_callsignFix };
_callSignPlayer = (format ["%1", group player]) call NEO_fnc_callsignFix;
_task = "RTB";

//New Task Assigned - RTB
_chopper setVariable ["NEO_radioTransportNewTask", [_task, []], true];
[player, format ["%1 this is %2, return to base. Over.", _callSign, _callSignPlayer], "side"] call NEO_fnc_messageBroadcast;

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
