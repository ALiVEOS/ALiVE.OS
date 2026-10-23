#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskGetInsurgencyLocation);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetInsurgencyLocation

Description:
Get insurgency location

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

private ["_taskLocation","_taskLocationType","_side","_opcomModules","_moduleType","_objectiveData","_opcom","_controlType","_opcomSide","_center",
"_size","_tacom_state","_opcom_state","_section","_sections","_profileID","_profile","_position","_hq","_depot","_factory","_objectives"];

_taskLocation = _this select 0;
_taskLocationType = _this select 1;
_side = _this select 2;
// Tasks Only Against Known Enemy (C2ISTAR module): the side the installation must be known to
private _knownTo = _this param [3, ""];

_opcomModules = [];

{
    _moduleType = _x getVariable "moduleType";
    if!(isNil "_moduleType") then {

        if(_moduleType == "ALIVE_OPCOM") then {
            _opcomModules pushback _x;
        };
    };
} forEach (entities "Module_F");

_objectives = [];

{
    _opcom = _x getVariable "handler";
    _controlType = _x getVariable "controltype";
    _opcomSide = [_opcom,"side"] call ALIVE_fnc_hashGet;

    if(_side == _opcomSide && _controlType == "asymmetric") then {

        {
            _center = [_x,"center",[]] call ALIVE_fnc_hashGet;
            _size = [_x,"size",150] call ALIVE_fnc_hashGet;
            _opcom_state = [_x,"opcom_state","unassigned"] call ALIVE_fnc_hashGet;
            _hq = [_x,"HQ",[]] call ALIVE_fnc_hashGet;
            _depot = [_x,"depot",[]] call ALIVE_fnc_hashGet;
            _factory = [_x,"factory",[]] call ALIVE_fnc_hashGet;
            _section = [_x,"section",[]] call ALIVE_fnc_hashGet;

            //_x call ALIVE_fnc_inspectHash;

            if((count _hq > 0) || (count _depot > 0) || count _factory > 0) then {
                _objectives pushBack [_size,_center,_section,_hq,_depot,_factory];
            };

        } forEach ([_opcom,"objectives",[]] call ALiVE_fnc_HashGet);

    };

} foreach _opcomModules;

private ["_sortedObjectives","_targetObjective"];

_targetObjective = [];

if(count _objectives > 0) then {

    // _objectives call ALIVE_fnc_inspectArray;

    _sortedObjectives = [_objectives,[],{_taskLocation distance (_x select 1)},"ASCEND"] call ALiVE_fnc_SortBy;

    private _minDistance = missionNamespace getVariable ["ALIVE_taskMinDistance", 0];
    if (_taskLocationType in ["Short", "Medium", "Long"] && {_minDistance > 0}) then {
        private _filteredObjectives = [];
        {
            private _centerPos = _x select 1;
            if !(_centerPos isEqualTo []) then {
                if (_taskLocation distance2D _centerPos >= _minDistance) then {
                    _filteredObjectives pushBack _x;
                };
            };
        } forEach _sortedObjectives;

        if (count _filteredObjectives > 0) then {
            _sortedObjectives = _filteredObjectives;
        };
    };

    // Maximum Task Distance (TheLogatron on Discord, 23 Oct): only those within it of the player; none within
    // it (blacklisted spots aside), the whole list stays and the nearest beyond is used, as Minimum Task Distance falls back
    private _maxDistance = missionNamespace getVariable ["ALIVE_taskMaxDistance", 0];
    if (_taskLocationType in ["Short", "Medium", "Long"] && {_maxDistance > 0} && {count _sortedObjectives > 0}) then {
        private _bl = missionNamespace getVariable ["ALIVE_taskBlacklistMarkers", []];
        private _within = _sortedObjectives select { private _p = _x select 1; _p isNotEqualTo [] && {(_taskLocation distance2D _p) <= _maxDistance} && {(_bl findIf { _p inArea _x }) < 0} };
        _sortedObjectives = if (_within isEqualTo []) then {
            ["C2ISTAR - nothing within Maximum Task Distance %1 of %2, so the nearest beyond it is used", _maxDistance, mapGridPosition _taskLocation] call ALiVE_fnc_dump; _sortedObjectives
        } else { _within };
    };

    // Areas the mission keeps generated tasks out of (Task Blacklist on the C2ISTAR module, #729).
    private _taskBlacklist = missionNamespace getVariable ["ALIVE_taskBlacklistMarkers", []];
    if (_taskBlacklist isNotEqualTo []) then {
        _sortedObjectives = _sortedObjectives select { private _c = _x select 1; (_taskBlacklist findIf {_c inArea _x}) < 0 };
    };

    // only installations _knownTo knows of; none known, the list stays and the task's own check turns it down
    if (_knownTo != "" && {_taskLocationType != "Map"} && {_sortedObjectives isNotEqualTo []}) then {
        private _mask = ["places", _knownTo, _sortedObjectives apply { _x select 1 }] call ALIVE_fnc_taskKnownEnemy;
        private _knownObjs = [];
        { if (_mask select _forEachIndex) then { _knownObjs pushBack _x } } forEach _sortedObjectives;
        if (_knownObjs isNotEqualTo []) then { _sortedObjectives = _knownObjs };
    };

    private _countObjectives = count _sortedObjectives;
    if (_countObjectives == 0) exitWith {};

    if(_taskLocationType == "Map" || _taskLocationType == "Short") then {
        if(count _sortedObjectives > 1 && _taskLocationType == "Short") then {
            _targetObjective = _sortedObjectives select 1;
        }else{
            _targetObjective = _sortedObjectives select 0;
        };

    };

    if(_taskLocationType == "Medium") then {
        _targetObjective = _sortedObjectives select (floor(_countObjectives/2));
    };

    if(_taskLocationType == "Long") then {
        _targetObjective = _sortedObjectives select (_countObjectives-1);
    };

};

_targetObjective;
