#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(updateTraceGrid);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_updateTraceGrid
Description:
Updates hostility state of given grid-sectors

Parameters:
array - grid (created with ALIVE_fnc_createTraceGrid)

Returns:
array - grid

Examples:
(begin example)
    _grid call ALIVE_fnc_updateTraceGrid;
(end)

See Also:
- <ALIVE_fnc_createTraceGrid>

Author:
Highhead
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_grid","_fill"];

_grid = _this select 0;
_fill = if (count _this > 1) then {_this select 1} else {"Solid"};

// Squares cleared before a reload, painted green for their side once the grid has drawn them (F405).
if (!isNil QGVAR(TRACEGRID_REPAINT)) then {
    private _left = 0;
    {
        private _sideStr = _x;
        private _side = switch (_sideStr) do { case "WEST": {west}; case "EAST": {east}; case "GUER": {resistance}; case "CIV": {civilian}; default {sideUnknown} };
        private _still = [];
        {
            if (_x in _grid && {_side != sideUnknown}) then {
                [_x, getMarkerPos _x, "RECTANGLE", [50,50], "COLORGREEN", "", "EMPTY", _fill, 0, 0.5] remoteExecCall ["ALIVE_fnc_createMarker", _side, format ["%1_%2", _x, _side]];
            } else {
                if (_side != sideUnknown) then { _still pushBack _x };
            };
        } forEach ([GVAR(TRACEGRID_REPAINT), _sideStr, []] call ALiVE_fnc_HashGet);
        [GVAR(TRACEGRID_REPAINT), _sideStr, _still] call ALiVE_fnc_HashSet;
        _left = _left + count _still;
    } forEach (GVAR(TRACEGRID_REPAINT) select 1);
    if (_left == 0) then { GVAR(TRACEGRID_REPAINT) = nil };
};

{
    private _pos = getposATL _x;
    private _side = side group _x;

    private _cleared = [GVAR(TRACEGRID_STORE),str(_side),[]] call ALiVE_fnc_HashGet;

    If ((_pos select 2) < 2 && {_x == vehicle _x})  then {
        private _gridPos = _pos call ALiVE_fnc_GridPos;
        private _markerID = format["ALiVE_TraceGrid_%1_%2",_gridpos select 0,_gridPos select 1];

        // only the squares T.R.A.C.E. drew, the ones with buildings, change colour
        if (_markerID in _grid) then {
            private _nearEnemy = [_gridPos,str(_side), 75] call ALiVE_fnc_isEnemyNear;
            // Each change goes to that side's clients, late joiners included, under the square's
            // own id, so a new colour replaces the last one in the late-joiner queue rather than
            // queueing behind every change since the start.
            private _jipID = format ["%1_%2", _markerID, _side];
            if (_nearEnemy) then {
                if (_markerID in _cleared) then {
                    // cleared before: red again
                    [_markerID,_gridPos,"RECTANGLE",[50,50],"COLORRED","","EMPTY", _fill,0,0.5] remoteExecCall ["ALIVE_fnc_createMarker", _side, _jipID];
                    [GVAR(TRACEGRID_STORE),str(_side),_cleared - [_markerID]] call ALiVE_fnc_HashSet;
                };
            } else {
                if !(_markerID in _cleared) then {
                    // not cleared yet: green
                    [_markerID,_gridPos,"RECTANGLE",[50,50],"COLORGREEN","","EMPTY", _fill,0,0.5] remoteExecCall ["ALIVE_fnc_createMarker", _side, _jipID];
                    [GVAR(TRACEGRID_STORE),str(_side),_cleared + [_markerID]] call ALiVE_fnc_HashSet;
                };
            };
        };
    };
} foreach allPlayers;

_grid;
