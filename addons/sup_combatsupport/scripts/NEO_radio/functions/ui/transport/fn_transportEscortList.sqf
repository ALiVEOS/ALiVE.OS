/*
    NEO_fnc_transportEscortList (Eric on Discord, 22 Oct): fills the transport panel's Escort box with the support
    vehicles free to escort this transport. Air transport: the side's attack helicopters on the CAS list and its armed
    air transports; ground transport: its armed ground transports. Only ones standing by, not this transport and not
    already escorting. The first row is no escort; each row's data is the vehicle's id
    from BIS_fnc_netId, which works in singleplayer too (netId alone is multiplayer only).

    [combo, "AIR" | "GROUND", transport]

    Author: Jman
*/
params [["_combo", controlNull], ["_kind", "AIR"], ["_transport", objNull]];
if (isNull _combo) exitWith {};
lbClear _combo;
private _row = _combo lbAdd localize "STR_ALIVE_CS_UI_ESCORT_NONE";
_combo lbSetData [_row, ""];
private _free = {
    params ["_veh", "_statusVar"];
    alive _veh && {_veh != _transport} && {alive driver _veh} && {canMove _veh}
    && {(_veh getVariable [_statusVar, "NONE"]) == "NONE"}
    && {isNull (_veh getVariable ["NEO_radioEscorting", objNull])}
};
private _rows = [];
if (_kind == "AIR") then {
    {
        _x params ["_veh", "", "_callsign"];
        if (_veh isKindOf "Helicopter" && {!unitIsUAV _veh} && {[_veh, "NEO_radioCasUnitStatus"] call _free}) then { _rows pushBack [_callsign, _veh] };
    } forEach (NEO_radioLogic getVariable [format ["NEO_radioCasArray_%1", playerSide], []]);
    {
        _x params ["_veh", "", "_callsign"];
        if (_veh isKindOf "Helicopter" && {_veh getVariable ["NEO_radioGunnerDefendArmed", false]} && {[_veh, "NEO_radioTrasportUnitStatus"] call _free}) then { _rows pushBack [_callsign, _veh] };
    } forEach (NEO_radioLogic getVariable [format ["NEO_radioTrasportArray_%1", playerSide], []]);
} else {
    {
        _x params ["_veh", "", "_callsign"];
        if (_veh getVariable ["NEO_radioGunnerDefendArmed", false] && {[_veh, "NEO_radioGroundUnitStatus"] call _free}) then { _rows pushBack [_callsign, _veh] };
    } forEach (NEO_radioLogic getVariable [format ["NEO_radioGroundArray_%1", playerSide], []]);
};
private _current = _transport getVariable ["NEO_radioEscort", objNull];
private _aheadNow = _transport getVariable ["NEO_radioEscortAhead", false];
private _sel = 0;
// an air escort is offered twice (arismagicgr, #1135): behind the transport, or ahead of it to the landing spot. The
// ahead row's data ends in "|AHEAD"
private _addRows = {
    params ["_callsign", "_veh"];
    private _r = _combo lbAdd format [localize "STR_ALIVE_CS_UI_ESCORT", _callsign];
    _combo lbSetData [_r, _veh call BIS_fnc_netId];
    if (_veh isEqualTo _current && {!_aheadNow}) then { _sel = _r };
    if (_kind == "AIR") then {
        _r = _combo lbAdd format [localize "STR_ALIVE_CS_UI_ESCORT_AHEAD", _callsign];
        _combo lbSetData [_r, (_veh call BIS_fnc_netId) + "|AHEAD"];
        if (_veh isEqualTo _current && {_aheadNow}) then { _sel = _r };
    };
};
{ _x call _addRows } forEach _rows;
// the transport's current escort is busy escorting it, so it is not in the list above: show it as chosen
if (!isNull _current && {_sel == 0} && {alive _current}) then {
    [(format ["%1", group driver _current]) call NEO_fnc_callsignFix, _current] call _addRows;
};
_combo lbSetCurSel _sel;
_combo ctrlEnable true;
_combo ctrlShow true;
