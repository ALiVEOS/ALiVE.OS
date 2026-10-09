#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(createTraceGrid);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createTraceGrid
Description:
Marks all grid-sectors with buildings within the given radius of a position. Use on server with ALiVE_fnc_updateTraceGrid.

Parameters:
array - position
number - radius

Returns:
array - grid

Examples:
(begin example)
            [
                getpos player,
                500
            ] call ALIVE_fnc_createTraceGrid;
(end)

See Also:
- <ALIVE_fnc_updateTraceGrid>

Author:
Highhead
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_pos","_radius","_grid","_fill"];

_pos = _this select 0;
_radius = _this select 1;
_fill = if (count _this > 2) then {_this select 2} else {"Solid"};

// Each side's cleared squares. Saved with the mission (ALiVE Data's mission store), so after a reload the
// squares a side had cleared come back green rather than every square starting red again (F405).
if (isnil QGVAR(TRACEGRID_STORE)) then {GVAR(TRACEGRID_STORE) = [] call ALiVE_fnc_HashCreate};
if (isNil QGVAR(TRACEGRID_RESTORED) && {!isNil "ALiVE_fnc_getData"} && {!isNil "ALiVE_sys_data_mission_data"}) then {
    GVAR(TRACEGRID_RESTORED) = true;
    private _saved = ["ALiVE_traceCleared"] call ALiVE_fnc_getData;
    if (!isNil "_saved" && {_saved isEqualType []} && {[_saved] call ALiVE_fnc_isHash}) then {
        GVAR(TRACEGRID_STORE) = +_saved;
        // painted green by ALiVE_fnc_updateTraceGrid once each square has been drawn, as they're drawn a few a frame
        GVAR(TRACEGRID_REPAINT) = +_saved;
    };
};

_grid = [];
// "Drawn already?" is asked once per building, so it's asked of a hash map: asked of the growing
// list, the build slowed with the square of the number of buildings.
private _drawn = createHashMap;

[{
    private ["_gridPos","_markerID"];

    _gridPos = (getposATL _x) call ALiVE_fnc_GridPos;
    // X and Y are kept apart: joined, 150,5050 and 15050,50 made one name on a map over 10 km.
    _markerID = format["ALiVE_TraceGrid_%1_%2",_gridpos select 0,_gridPos select 1];

    if !(_markerID in _drawn) then {
        _drawn set [_markerID, true];
        [_markerID,_gridPos,"RECTANGLE", [50,50], "COLORRED", "", "EMPTY", _fill, 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
        _grid pushBack _markerID;
    };
},([_pos,_radius] call ALiVE_fnc_getEnterableHouses),5] call ALiVE_fnc_ArrayFrameSplitter;

_grid