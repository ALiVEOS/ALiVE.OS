private ["_display", "_map", "_transportUnitLb", "_transportTaskLb", "_transportConfirmButton", "_slider", "_transportFlyHeightSlider"];
_display = findDisplay 655555;
_map = _display displayCtrl 655560;
_transportUnitLb = _display displayCtrl 655568;
_transportTaskLb = _display displayCtrl 655569;
_transportConfirmButton = _display displayCtrl 655574;
_slider = _display displayCtrl 655578;
_transportFlyHeightSlider = _display displayCtrl 655580;
_audio = NEO_radioLogic getVariable format ["combatsupport_audio", true];

private ["_transportArray", "_chopper", "_grp", "_callsign", "_callSignPlayer", "_task", "_marker", "_pos","_amnt"];
_transportArray = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", playerSide];

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
_task = _transportTaskLb lbText (lbCurSel _transportTaskLb);
_marker = NEO_radioLogic getVariable "NEO_supportMarker";
_pos = getMarkerPos _marker;
_pos set [2, 0];
_amnt = sliderPosition _slider;_location = _pos call BIS_fnc_posToGrid;


//New Task Assigned
private ["_arguments"];
_arguments = [_task, _pos, 0, player];

if (toUpper _task == "CIRCLE") then
{
    _arguments = [_task, _pos,_amnt, player];
};
if (toUpper _task == "INSERTION") then
{
    _arguments = [_task, _pos,_amnt, player];
};

//Player dialog
private ["_posTask", "_text"];
_posTask = _pos call BIS_fnc_posToGrid;
_text = switch (toUpper _task) do
{
    case "PICKUP" : { format ["%1, %2 requesting pickup at %3 %4 . Over.", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "LAND" : { format ["%1, land at %3 %4. Over.", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "LAND (ENG OFF)" : { format ["%1, land at %3 %4. Over.", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "MOVE" : { format ["%1, move to %3 %4 and wait for orders. Over.", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "CIRCLE" : { format ["%1, move to %3 %4 and provide overwatch. Over.", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "RTB" : { format ["%1, return to base. Over.", _callsign, _callSignPlayer] };
    case "INSERTION" : { format ["%1, move to %3 %4 for insertion. Over.", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "SLINGLOAD" : { format ["%1, move to %3 %4 for slingloading. Over.", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "UNHOOK" : { format ["%1, move to %3 %4 to deliver sling load. Over.", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
};

if (_audio) then {
    player kbAddtopic["ALIVE_SUPP_protocol", "a3\modules_f\supports\kb\protocol.bikb"];
    leader _grp kbAddtopic["ALIVE_SUPP_protocol", "a3\modules_f\supports\kb\protocol.bikb"];
    if (toUpper _task != "UNHOOK") then {
        player kbTell [leader _grp, "ALIVE_SUPP_protocol", "Transport_Request", "GROUP"];
    } else {
        player kbTell [leader _grp, "ALIVE_SUPP_protocol", "Drop_Request", "GROUP"];
    };
};

if (_task == "SLINGLOAD" && !isNull getSlingLoad _chopper || _task == "UNHOOK" && isNull getSlingLoad _chopper) then {
    // probably not supported
} else {
    // Let side know over the raadio
    [[player,_text,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
};

//New Task
_chopper setVariable ["NEO_radioTransportNewTask", _arguments, true];

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
