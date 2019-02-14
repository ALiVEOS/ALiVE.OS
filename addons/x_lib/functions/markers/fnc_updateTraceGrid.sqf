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

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_grid","_fill"];

_grid = _this select 0;
_fill = if (count _this > 1) then {_this select 1} else {"Solid"};

{
    private _pos = getposATL _x;
    private _side = side _x;

    private _cleared = [GVAR(TRACEGRID_STORE),str(_side),[]] call ALiVE_fnc_HashGet;

    If ((_pos select 2) < 2 && {_x == vehicle _x})  then {
        private _gridPos = _pos call ALiVE_fnc_GridPos;
        private _markerID = format["ALiVE_TraceGrid_%1%2",_gridpos select 0,_gridPos select 1];
        private _nearEnemy = [_gridPos,str(_side), 75] call ALiVE_fnc_isEnemyNear;

        [{
            if (_markerID == _x) exitwith {
                if (_nearEnemy) then {
                    if (_markerID in _cleared) then {
                        // if grid was cleared before then mark the grid red again on all clients of the specific side including JIP clients that join in later
                        [[_markerID,_gridPos,"RECTANGLE",[50,50],"COLORRED","","EMPTY", _fill,0,0.5],"ALIVE_fnc_createMarker",_side,true,false] spawn BIS_fnc_MP;

                        // remove from cleared sectors
                        [GVAR(TRACEGRID_STORE),str(_side),([GVAR(TRACEGRID_STORE),str(_side),[]] call ALiVE_fnc_HashGet) - [_markerID]] call ALiVE_fnc_HashSet;
                    };
                } else {
                     if !(_markerID in _cleared) then {
                        // if grid is not yet cleared then mark the cleared grid green on all clients of the specific side including JIP clients that join in later
                        [[_markerID,_gridPos,"RECTANGLE",[50,50],"COLORGREEN","","EMPTY", _fill,0,0.5],"ALIVE_fnc_createMarker",_side,true,false] spawn BIS_fnc_MP;

                        // collect to cleared sectors
                        [GVAR(TRACEGRID_STORE),str(_side),([GVAR(TRACEGRID_STORE),str(_side),[]] call ALiVE_fnc_HashGet) + [_markerID]] call ALiVE_fnc_HashSet;
                    };
                };
            };
        },_grid,10] call ALiVE_fnc_arrayFrameSplitter;
    };
} foreach allPlayers;

_grid;
