#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(CQBsortStrategicHouses);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_CQBsortStrategicHouses

Description:
Sort buildings into strategic and non-strategic arrays

Parameters:
Array - List of all enterable houses

Returns:
Array - An array containing randomly selected strategic and non strategic
buidlings including the maximum number of building positions for
the building.

Examples:
(begin example)
_spawnhouses = call ALIVE_fnc_getAllEnterableHouses;
_result = [_spawnhouses] call ALIVE_fnc_CQBsortStrategicHouses;
CQBpositionsStrat = _result select 0; // [strathouse1, strathouse2];
CQBpositionsReg = _result select 1; // [nonstrathouse1, nonstrathouse2];
(end)

See Also:
- <ALIVE_fnc_getEnterableHouses>
- <ALIVE_fnc_getAllEnterableHouses>

Authors:
Naught
Highhead
Wolffy.au
Jman
---------------------------------------------------------------------------- */
private ["_spawnhouses","_BuildingTypeStrategic","_density","_CQB_spawn","_blackzone","_whitezone","_nonstrathouses","_strathouses"];

scopename "main";

PARAMS_1(_spawnhouses);
ASSERT_TRUE(typeName _spawnhouses == "ARRAY",str _spawnhouses);
DEFAULT_PARAM(1,_BuildingTypeStrategic,[]);
DEFAULT_PARAM(2,_density,1000);
DEFAULT_PARAM(3,_CQB_spawn,0.01);
DEFAULT_PARAM(4,_blackzone,[]);
DEFAULT_PARAM(5,_whitezone,[]);

_strathouses = [];
_nonstrathouses = [];

{ // forEach
    private ["_obj", "_isStrategic", "_houses"];
    _obj = _x;

    // CBA AI Building Position helper objects are kindOf Building, so the enterable-houses
    // sweep hands them to this sorter as standalone one-slot houses. If the helper sits
    // inside a nearby enterable building, that building's own garrison already mans the
    // spot at spawn time (CBA_fnc_buildingPositions merge in spawnGroup) - drop the helper
    // here so it cannot raise a second group on the same spot. Free-standing helpers and
    // helpers inside buildings without engine positions are kept as houses, so areas that
    // only have CBA positions keep their CQB presence.
    private _absorbedCBApos = (_obj isKindOf "CBA_buildingPos") && {
        private _cbaPos = _obj buildingPos 0;
        ((nearestObjects [_obj, ["House","Building"], 50]) findIf {
            private _building = _x;
            !(_building isKindOf "CBA_buildingPos")
            && {[_building] call ALiVE_fnc_isHouseEnterable}
            && {(([_building] call CBA_fnc_buildingPositions) findIf {_x isEqualTo _cbaPos}) != -1}
        }) != -1
    };
    _isStrategic = (typeOf _obj) in _BuildingTypeStrategic;
    _houses = if (_isStrategic) then {_strathouses} else {_nonstrathouses};

    if (!_absorbedCBApos && {!(([_obj] call ALiVE_fnc_getBuildingPositions) isEqualTo [])} && {!(_obj in _houses)}) then {
        private ["_pos", "_collect"];

        _pos = getPosATL _obj;
        _collect = true;

        // Are there TAOR or Blacklist markers?
        if (count (_whitezone + _blackzone) > 0) then {
            // Filter Whitezone
            {_collect = false; if ([_pos,_x] call ALiVE_fnc_inArea) exitWith {_collect = true}} forEach _whitezone;

            // Filter Blackzone
            {if ([_pos, _x] call ALiVE_fnc_inArea) exitWith {_collect = false}} forEach _blackzone;
        };

        if (_collect) then {

            { // forEach
                private ["_dis"];
                _dis = _pos distance (getposATL _x);
                if ((_dis < _density) && {!_isStrategic || {_dis < 60}}) exitWith {
                    _collect = (random 1) < _CQB_spawn;
                };
            } forEach _houses;

            if (_collect) then {
                _houses pushback _obj;
            };
        };
    };
} forEach _spawnhouses;

[_strathouses,_nonstrathouses];
