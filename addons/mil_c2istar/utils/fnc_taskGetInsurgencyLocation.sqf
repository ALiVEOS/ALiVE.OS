#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
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
---------------------------------------------------------------------------- */

private ["_taskLocation","_taskLocationType","_side","_opcomModules","_moduleType","_objectiveData","_opcom","_controlType","_opcomSide","_center",
"_size","_tacom_state","_opcom_state","_section","_sections","_profileID","_profile","_position","_hq","_depot","_factory","_objectives"];

_taskLocation = _this select 0;
_taskLocationType = _this select 1;
_side = _this select 2;

_opcomModules = [];

{
    _moduleType = _x getVariable "moduleType";
    if!(isNil "_moduleType") then {

        if(_moduleType == "ALIVE_OPCOM") then {
            _opcomModules set [count _opcomModules,_x];
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

    _objectives call ALIVE_fnc_inspectArray;

    _sortedObjectives = [_objectives,[],{_taskLocation distance (_x select 1)},"ASCEND"] call ALiVE_fnc_SortBy;

    _sortedObjectives call ALIVE_fnc_inspectArray;

    _countObjectives = count _sortedObjectives;

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