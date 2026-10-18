private ["_display", "_map", "_transportUnitLb", "_transportTaskLb", "_transportConfirmButton", "_slider"];
// #940 follow-up: in "first player only" mode, only the current operator may dispatch.
if !(call ALIVE_fnc_combatSupportIsOperator) exitWith { [localize "STR_ALIVE_COMBATSUPPORT", localize "STR_ALIVE_CS_NOTOPERATOR"] call ALIVE_fnc_sendHint; };
_display = findDisplay 655555;
_map = _display displayCtrl 655560;
_transportUnitLb = _display displayCtrl 655568;
_transportTaskLb = _display displayCtrl 655569;
_transportConfirmButton = _display displayCtrl 655574;
_slider = _display displayCtrl 655578;
_audio = NEO_radioLogic getVariable format ["combatsupport_audio", true];

private ["_transportArray", "_chopper", "_grp", "_callsign", "_callSignPlayer", "_task", "_marker", "_pos","_amnt"];
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
_task = _transportTaskLb lbData (lbCurSel _transportTaskLb);
_marker = NEO_radioLogic getVariable "NEO_supportMarker";
_pos = getMarkerPos _marker;
_pos set [2, 0];
// Round so the aircraft flies the whole number the player read off the slider
_amnt = round (sliderPosition _slider);_location = _pos call BIS_fnc_posToGrid;


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
if (toUpper _task == "PARADROP") then
{
    _arguments = [_task, _pos,_amnt, player];
};

//Player dialog
private ["_posTask", "_text"];
_posTask = _pos call BIS_fnc_posToGrid;
_text = switch (toUpper _task) do
{
    case "PICKUP" : { ["STR_ALIVE_CS_MSG_TR_PICKUP", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "LAND" : { ["STR_ALIVE_CS_MSG_TR_LAND", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "LAND (ENG OFF)" : { ["STR_ALIVE_CS_MSG_TR_LAND", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "MOVE" : { ["STR_ALIVE_CS_MSG_TR_MOVE", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "CIRCLE" : { ["STR_ALIVE_CS_MSG_TR_CIRCLE", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "RTB" : { ["STR_ALIVE_CS_MSG_TR_RTB", _callsign, _callSignPlayer] };
    case "INSERTION" : { ["STR_ALIVE_CS_MSG_TR_INSERTION", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "SLINGLOAD" : { ["STR_ALIVE_CS_MSG_TR_SLINGLOAD", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "UNHOOK" : { ["STR_ALIVE_CS_MSG_TR_UNHOOK", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "MEDEVAC" : { ["STR_ALIVE_CS_MSG_TR_MEDEVAC", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
    case "PARADROP" : { ["STR_ALIVE_CS_MSG_TR_PARADROP", _callsign, _callSignPlayer, _posTask select 0, _posTask select 1] };
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
// its destination stays on this player's map while it flies the order
if (toUpper _task != "RTB") then { [_chopper, _arguments, "NEO_radioTrasportUnitStatus", [[_pos, _callsign]]] call NEO_fnc_supportOrderMarkers };

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
