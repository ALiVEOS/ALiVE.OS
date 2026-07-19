private
[
    "_display", "_casUnitLb", "_casTaskLb", "_casFlyHeightSlider", "_casRadiusSlider", "_casArray", "_veh",
    "_grp", "_callsign", "_callSignPlayer", "_task", "_marker", "_isPlane", "_pos", "_radius", "_flyInHeight",
    "_Coord","_weapon","_loiterDuration"
];
// #940 follow-up: in "first player only" mode, only the current operator may dispatch.
if !(call ALIVE_fnc_combatSupportIsOperator) exitWith { hint localize "STR_ALIVE_CS_NOTOPERATOR"; };
_display = findDisplay 655555;
_casUnitLb = _display displayCtrl 655582;
_casTaskLb = _display displayCtrl 655587;
_casFlyHeightSlider = _display displayCtrl 655590;
_casRadiusSlider = _display displayCtrl 655592;
_casAttackRunLB = _display displayCtrl 655613;
_casROELb = _display displayCtrl 655615;
_audio = NEO_radioLogic getVariable format ["combatsupport_audio", true];
_casArray = NEO_radioLogic getVariable [format ["NEO_radioCasArray_%1", playerSide], []];
_veh = _casArray select (lbCurSel _casUnitLb) select 0;
_grp = _casArray select (lbCurSel _casUnitLb) select 1;
_callsign = _casArray select (lbCurSel _casUnitLb) select 2;
_callSignPlayer = (format ["%1", group player]) call NEO_fnc_callsignFix;
// read the internal task token via lbData, not lbText - the CAS task list can show a friendlier
// label (e.g. "SEARCH AND DESTROY") while the token that flows to cas.fsm's _task compares stays "SAD"
_task = _casTaskLb lbData (lbCurSel _casTaskLb);
// the single ATTACK task (merged ATTACK RUN + ATTACK GROUND) dispatches as "ATTACK GROUND" - the
// area-attack path handles auto-detection, empty vehicles AND a player's manual laser designation
if (_task == "ATTACK") then { _task = "ATTACK GROUND"; };
_marker = NEO_radioLogic getVariable "NEO_supportMarker";
_isPlane = !(_veh isKindOf "Helicopter");
_pos = getMarkerPos _marker;
_pos set [2, 0];
_radius = sliderPosition _casRadiusSlider;
_flyInHeight = switch (sliderPosition _casFlyHeightSlider) do
{
    case 1 : { if (_isPlane) then { 150 } else { 50 } };
    case 2 : { if (_isPlane) then { 250 } else { 100 } };
    case 3 : { if (_isPlane) then { 500 } else { 150 } };
};
_coord = _pos call BIS_fnc_posToGrid;
// #735 follow-up: resolve chosen weapon by its row DATA (classname), not by re-indexing the
// now-filtered weapons list (row index no longer maps to weapons _veh).
_weapon = _casAttackRunLB lbData (lbCurSel _casAttackRunLB);
_ROE = _casROELb lbData (lbCurSel _casROELb);
// guard: never hand setCombatMode an empty enum (cas.fsm does "_grp setCombatMode _ROE").
// lbData is "" when the list has no selection - default to the list's own default (RED).
if (_ROE == "") then { _ROE = "RED"; };
// #323: for LOITER the weapon list is reused as a duration picker - its lbData is seconds
// (Indefinite = -1), not a weapon classname. Move it to the duration slot and blank the
// weapon field. Every other task keeps -1 so the array shape (index 7) stays uniform.
_loiterDuration = -1;
if (_task == "LOITER") then {
    if (_weapon != "") then { _loiterDuration = parseNumber _weapon; };
    _weapon = "";
};

//New Task
_veh setVariable ["NEO_radioCasNewTask", [_task, _pos, _radius, _flyInHeight, _weapon, _ROE, player, _loiterDuration], true];


if (_audio) then {
    player kbAddtopic["ALIVE_SUPP_protocol", "a3\modules_f\supports\kb\protocol.bikb"];
    leader _grp kbAddtopic["ALIVE_SUPP_protocol", "a3\modules_f\supports\kb\protocol.bikb"];

    if (_isPlane && (_task == "SAD" || _task == "ATTACK RUN" || _task == "ATTACK GROUND")) then {
        player kbTell [leader _grp, "ALIVE_SUPP_protocol", "CAS_Bombing_Request", "GROUP"];
    } else {
        player kbTell [leader _grp, "ALIVE_SUPP_protocol", "CAS_Heli_Request", "GROUP"];
    };
} else {
    [[player,format["%1, %2 needs immediate CAS at %3%4. Over.", _callsign, _callSignPlayer, _coord select 0, _coord select 1],"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
};

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
