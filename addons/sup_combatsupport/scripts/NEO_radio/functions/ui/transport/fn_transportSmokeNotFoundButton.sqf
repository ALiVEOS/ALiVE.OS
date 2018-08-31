private ["_display", "_transportUnitLb"];
_display = findDisplay 655555;
_transportUnitLb = _display displayCtrl 655568;

private ["_transportArray", "_chopper"];
_transportArray = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", playerSide];

if (!isNil {NEO_radioLogic getVariable "NEO_radioTalkWithPilot"}) then {
    _chopper = NEO_radioLogic getVariable "NEO_radioTalkWithPilot";
}

else {
    _chopper = _transportArray select (lbCurSel _transportUnitLb) select 0;
};

//Confirmed
_chopper setVariable ["NEO_radioSmokeConfirmed", false, true];

[
    player,
    "Negative, throwing another smoke. Over.",
    "group"
] call NEO_fnc_messageBroadcast;

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
