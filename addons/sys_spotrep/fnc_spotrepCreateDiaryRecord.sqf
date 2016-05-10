#include <\x\alive\addons\sys_spotrep\script_component.hpp>
SCRIPT(spotrepCreateDiaryRecord);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_spotrepCreateDiaryRecord
Description:
Creates a diary record

Parameters:
array - diary values

Returns:
bool

Examples:
(begin example)
                        _spotrepName,
                        [_spotrepHash, QGVAR(callsign)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(DTG)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(dateTime)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(loc)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(faction)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(size)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(type)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(activity)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(factivity)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(remarks),"NONE"] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(markername),"NONE"] call ALIVE_fnc_hashGet
                    ] call ALIVE_fnc_spotrepCreateDiaryRecord;
(end)

See Also:
- <ALIVE_fnc_spotrep>

Author:
Tupolov
Peer Reviewed:
nil
---------------------------------------------------------------------------- */
LOG(str _this);
_params = _this;

if !(player diarySubjectExists "SPOTREP") then {
    player createDiarySubject ["SPOTREP","SPOTREP"];
};

player createDiaryRecord ["SPOTREP", [
    format ["DTG:%1 - %2", ( _params select 2), ( _params select 0)],
    format [
        "Callsign: %1<br/>" +
        "Timing: %2<br/>" +
        "Location: <marker name='%10'>%3</marker><br/>" +
        "<br/>" +
        "Enemy: %4<br/>" +
        "Enemy Size: %5<br/>" +
        "Enemy Type: %6<br/>" +
        "Enemy Actions: %7<br/><br/>" +
        "Friendly Actions: %8<br/><br/>" +
        "Remarks:<br/>" +
        "%9<br/>",
         _params select 1,
         _params select 3,
         _params select 4,
         _params select 5,
         _params select 6,
         _params select 7,
         _params select 8,
         _params select 9,
         _params select 10,
         _params select 11
    ]
]];

