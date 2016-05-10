#include <\x\alive\addons\sys_sitrep\script_component.hpp>
SCRIPT(sitrepCreateDiaryRecord);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sitrepCreateDiaryRecord
Description:
Creates a diary record

Parameters:
array - diary values

Returns:
bool

Examples:
(begin example)
                    [
                        _sitrepName,
                        [_sitRepHash, QGVAR(sitrepName)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(callsign)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(DTG)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(dateTime)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(loc)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(ekia)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(evde)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(evda)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, GVAR(civ)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, GVAR(fkia)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, GVAR(fwia)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, GVAR(fvde)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, GVAR(fvda)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, GVAR(ammo)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, GVAR(cas)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, GVAR(remarks)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, GVAR(group)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, GVAR(pos)] call ALIVE_fnc_hashGet
                    ] call ALIVE_fnc_sitrepCreateDiaryRecord;
(end)

See Also:
- <ALIVE_fnc_sitrep>

Author:
Tupolov
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

_params = _this;

LOG(str _params);

_markerName = "MK" + str(random time + 1);

if !(player diarySubjectExists "SITREP") then {
    player createDiarySubject ["SITREP","SITREP"];
};

player createDiaryRecord ["SITREP", [
    format ["DTG:%1 - %2", ( _params select 2), ( _params select 0)],
    format [
        "Callsign: %1<br/>" +
        "Timing: %2<br/>" +
        "Location: <marker name='%15'>%3</marker><br/>" +
        "<br/>" +
        "Enemy KIA: %4<br/>" +
        "Enemy Forces:<br/>%5<br/><br/>" +
        "Civilian Casualties: %6<br/><br/>" +
        "Friendly KIA: %7<br/>" +
        "Friendly WIA: %8<br/>" +
        "Friendly Forces:<br/>%9<br/><br>" +
        "Ammo State: %10<br/>" +
        "Casualty State: %11<br/>" +
        "Vehicle State: %12<br/>" +
        "Combat Support State: %13<br/><br/>" +
        "Remarks:<br/>" +
        "%14<br/>",
         _params select 1,
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
         _params select 15,
         _markerName
    ]
]];


_marker = createMarkerLocal [_markerName, (_params select 17)];

_marker setMarkerPosLocal (_params select 17);
_marker setMarkerAlphaLocal 1;

_marker setMarkerTextLocal format["SITREP %1",_params select 0];
_marker setMarkerTypeLocal "mil_marker";