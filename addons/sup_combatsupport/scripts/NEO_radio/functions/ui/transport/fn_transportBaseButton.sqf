private ["_display", "_transportUnitLb"];
_display = findDisplay 655555;
_transportUnitLb = _display displayCtrl 655568;

private ["_transportArray", "_chopper", "_grp", "_callsign", "_callSignPlayer", "_pos"];
_transportArray = NEO_radioLogic getVariable [format ["NEO_radioTrasportArray_%1", playerSide], []];

if (!isNil {NEO_radioLogic getVariable "NEO_radioTalkWithPilot"}) then {
    _chopper = NEO_radioLogic getVariable "NEO_radioTalkWithPilot";
    _grp = group (driver _chopper);
    _callsign = (format ["%1", _grp]) call NEO_fnc_callsignFix;
}
else {
    _chopper = _transportArray select (lbCurSel _transportUnitLb) select 0;
    _grp = _transportArray select (lbCurSel _transportUnitLb) select 1;
    _callsign = _transportArray select (lbCurSel _transportUnitLb) select 2;
};

_callSignPlayer = (format ["%1", group player]) call NEO_fnc_callsignFix;
_pos = _chopper getVariable ["ALIVE_CombatSupport_Base", []];

//New Task Assigned - RTB
// the Route box counts for the way home too (A. Ares on Discord, 4 Nov)
private _routeCb = _display displayCtrl 655639;
private _avoid = lbCurSel _routeCb > -1 && {(_routeCb lbData (lbCurSel _routeCb)) == "1"};
_chopper setVariable ["NEO_transportRoute", _avoid, true];
_chopper setVariable ["NEO_radioTransportNewTask", ["RTB", _pos, 0, player, _avoid], true];
[player, ["STR_ALIVE_CS_MSG_51", _callSign, _callSignPlayer], "side"] call NEO_fnc_messageBroadcast;

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
