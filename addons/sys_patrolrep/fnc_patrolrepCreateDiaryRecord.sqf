#include <\x\alive\addons\sys_patrolrep\script_component.hpp>
SCRIPT(patrolrepCreateDiaryRecord);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_patrolrepCreateDiaryRecord
Description:
Creates a diary record

Parameters:
array - diary values

Returns:
bool

Examples:
(begin example)
                    [
0                        _patrolrepName,
1                        [_patrolrepHash, QGVAR(callsign)] call ALIVE_fnc_hashGet,
2                        [_patrolrepHash, QGVAR(DTG)] call ALIVE_fnc_hashGet,
3                        [_patrolrepHash, QGVAR(sdateTime)] call ALIVE_fnc_hashGet,
4                        [_patrolrepHash, QGVAR(edateTime)] call ALIVE_fnc_hashGet,
5                        [_patrolrepHash, QGVAR(sloc)] call ALIVE_fnc_hashGet,
6                        [_patrolrepHash, QGVAR(eloc)] call ALIVE_fnc_hashGet,
7                        [_patrolrepHash, QGVAR(patcomp)] call ALIVE_fnc_hashGet,
8                        [_patrolrepHash, QGVAR(task)] call ALIVE_fnc_hashGet,
9                        [_patrolrepHash, QGVAR(enbda)] call ALIVE_fnc_hashGet,
10                        [_patrolrepHash, QGVAR(results)] call ALIVE_fnc_hashGet,
11                       [_patrolrepHash, QGVAR(cs)] call ALIVE_fnc_hashGet,
12                        [_patrolrepHash, QGVAR(ammo)] call ALIVE_fnc_hashGet,
13                        [_patrolrepHash, QGVAR(cas)] call ALIVE_fnc_hashGet,
14                        [_patrolrepHash, QGVAR(veh)] call ALIVE_fnc_hashGet,
15                        [_patrolrepHash, QGVAR(spotreps)] call ALIVE_fnc_hashGet,
16                        [_patrolrepHash, QGVAR(sitreps)] call ALIVE_fnc_hashGet,
17                        [_patrolrepHash, QGVAR(group)] call ALIVE_fnc_hashGet,
18                        [_patrolrepHash, QGVAR(spos)] call ALIVE_fnc_hashGet,
19                        [_patrolrepHash, QGVAR(epos)] call ALIVE_fnc_hashGet
                    ] call ALIVE_fnc_patrolrepCreateDiaryRecord;
(end)

See Also:
- <ALIVE_fnc_patrolrep>

Author:
Tupolov
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

_params = _this;

LOG(str _params);

_markerName = _params select 0;

_markers = createMarkerLocal [format["%1START",_markerName], _params select 18];

_markers setMarkerPosLocal (_params select 18);
_markers setMarkerAlphaLocal 1;

_markers setMarkerTextLocal format["%1 START",_markerName];
_markers setMarkerTypeLocal "mil_marker";

_markere = createMarkerLocal [format["%1END",_markerName], _params select 19];

_markere setMarkerPosLocal (_params select 19);
_markere setMarkerAlphaLocal 1;

_markere setMarkerTextLocal format["%1 END",_markerName];
_markere setMarkerTypeLocal "mil_marker";

if !(player diarySubjectExists "PATROLREP") then {
    player createDiarySubject ["PATROLREP","PATROLREP"];
};

_spotreps = "";
{
    _spotreps = _spotreps + _x + " ";
} foreach (_params select 15);

_sitreps = "";
{
    _sitreps = _sitreps + _x + " ";
} foreach (_params select 16);

player createDiaryRecord ["PATROLREP", [
    format ["DTG:%1 - %2", ( _params select 2), ( _params select 0)],
    format [
        "Callsign: %1 - Unit: %19<br/>" +
        "Start Timing: %3<br/>" +
        "End Timing: %4<br/>" +
        "Start Location: <marker name='%17'>%5</marker><br/>" +
        "End Location: <marker name='%18'>%6</marker><br/>" +
        "Task: %8<br/><br/>" +
        "Patrol Composition:<br/> %7<br/><br/>" +
        "Enemy/Battle Damage Assessment:<br/> %9<br/><br/>" +
        "Results of Encounters:<br/> %10<br/><br/>" +
        "Patrol Ammo: %12<br/>" +
        "Patrol Casualties: %13<br/>" +
        "Patrol Support: %11<br/>" +
        "Patrol Vehicles: %14<br/><br/>" +
        "SPOTREPs: %15<br/>" +
        "SITREPs: %16<br/>",
         _params select 1,
         _params select 2,
         _params select 3,
         _params select 4,
         _params select 5,
         _params select 6,
         _params select 7,
         _params select 8,
         _params select 9,
         _params select 10,
         _params select 11,
         _params select 12,
         _params select 13,
         _params select 14,
         _spotreps,
         _sitreps,
         _markers,
         _markere,
         _params select 17
    ]
]];




