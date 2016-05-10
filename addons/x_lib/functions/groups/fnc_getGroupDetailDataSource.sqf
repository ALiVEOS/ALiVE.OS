#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getGroupDetailDataSource);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getGroupDetailDataSource

Description:
Get a individual groups info formatted for a UI datasource

Parameters:


Returns:
Array - Multi dimensional array of values and options

Examples:
(begin example)
_datasource = call ALiVE_fnc_getGroupDetailDataSource
(end)

Author:
ARJay
 
Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_group","_data","_rows","_values","_row","_labels","_rank","_player"];

_group = _this select 0;

_data = [];
_rows = [];
_values = [];

{
    if (!(isnull _x) && (alive _x)) then {

        _row = [];
        _labels = [];
        _rank = '';

        switch(rank _x) do {
            case 'PRIVATE':{
                _rank = 'PVT';
            };
            case 'CORPORAL':{
                _rank = 'CPL';
            };
            case 'SERGEANT':{
                _rank = 'SGT';
            };
            case 'LIEUTENANT':{
                _rank = 'LT';
            };
            case 'CAPTAIN':{
                _rank = 'CAPT';
            };
            case 'MAJOR':{
                _rank = 'MAJ';
            };
            case 'COLONEL':{
                _rank = 'COL';
            };
        };

        _player = '[AI]';
        if(isPlayer _x) then {
            _player = '[Player]';
        };

        _leader = '';
        if(isFormationLeader _x) then {
            _leader = '*Leader*';
        };

        _labels pushback (format['%1 %2 %3 %4 %5',group _x, _rank, name _x, _player, _leader]);
        _labels pushback ('');
        _labels pushback ('');
        _labels pushback ('');
        _labels pushback ('');
        _labels pushback ('');

        _row pushback (_labels);

        _rows pushback (_row);
        _values pushback (_x);


        private ["_unitAmmo","_obj","_objConfig","_objName","_objPicture","_objMagazines","_objAmmo","_ammoType","_ammoRoundCount","_ammoMagazineCount","_ammoMax","_ammoConfig","_ammoName","_ammoPicture","_ammoTypeCount","_ammoName"];

        _unitAmmo = _x call ALIVE_fnc_vehicleGetAmmo;

        //_unitAmmo call ALIVE_fnc_inspectArray;

        // primary

        _row = [];
        _labels = [];

        _obj = primaryWeapon _x;

        if!(_obj == '') then {

            _objConfig = configFile >> "cfgweapons" >> _obj;
            _objName = getText (_objConfig >> "displayName");
            _objPicture = getText (_objConfig >> "picture");
            _objMagazines = _obj call ALIVE_fnc_configGetWeaponMagazines;

            _labels pushback (_objPicture);
            _labels pushback (_objName);

            _row pushback (_labels);

            _rows pushback (_row);
            _values pushback (_obj);

            _objAmmo = [] call ALIVE_fnc_hashCreate;

            {
                _ammoType = _x select 0;
                _ammoCount = _x select 1;
                _ammoMax = _x select 2;

                if((_ammoMax > 1) && (_ammoType in _objMagazines)) then {

                    if!(_ammoType in (_objAmmo select 1)) then {

                        _ammoConfig = configFile >> "cfgmagazines" >> _ammoType;
                        _ammoName = getText (_ammoConfig >> "displayName");
                        _ammoPicture = getText (_ammoConfig >> "picture");

                        [_objAmmo, _ammoType, [0, 0, _ammoName, _ammoPicture]] call ALIVE_fnc_hashSet;
                    };

                    _ammoTypeData = [_objAmmo, _ammoType] call ALIVE_fnc_hashGet;
                    _ammoRoundCount = _ammoTypeData select 0;
                    _ammoMagazineCount = _ammoTypeData select 1;
                    _ammoRoundCount = _ammoRoundCount + _ammoCount;
                    _ammoMagazineCount = _ammoMagazineCount + 1;
                    _ammoTypeData set [0,_ammoRoundCount];
                    _ammoTypeData set [1,_ammoMagazineCount];
                    [_objAmmo, _ammoType, _ammoTypeData] call ALIVE_fnc_hashSet;

                };
            } foreach _unitAmmo;

            //_objAmmo call ALIVE_fnc_inspectHash;

            {
                _row = [];
                _labels = [];

                _ammoTypeData = [_objAmmo, _x] call ALIVE_fnc_hashGet;
                _ammoRoundCount = _ammoTypeData select 0;
                _ammoMagazineCount = _ammoTypeData select 1;
                _ammoName = _ammoTypeData select 2;
                _ammoPicture = _ammoTypeData select 3;

                _labels pushback (_ammoPicture);
                _labels pushback (_ammoName);
                _labels pushback (format['%1 mags', _ammoMagazineCount]);
                _labels pushback (format['%1 rounds', _ammoRoundCount]);

                _row pushback (_labels);

                _rows pushback (_row);
                _values pushback (_ammoName);

            } foreach (_objAmmo select 1);

        };

        // secondary

        _row = [];
        _labels = [];

        _obj = secondaryWeapon _x;

        if!(_obj == '') then {

            _objConfig = configFile >> "cfgweapons" >> _obj;
            _objName = getText (_objConfig >> "displayName");
            _objPicture = getText (_objConfig >> "picture");
            _objMagazines = _obj call ALIVE_fnc_configGetWeaponMagazines;

            _labels pushback (_objPicture);
            _labels pushback (_objName);

            _row pushback (_labels);

            _rows pushback (_row);
            _values pushback (_obj);

            _objAmmo = [] call ALIVE_fnc_hashCreate;

            {
                _ammoType = _x select 0;
                _ammoCount = _x select 1;
                _ammoMax = _x select 2;

                if(_ammoType in _objMagazines) then {

                    if!(_ammoType in (_objAmmo select 1)) then {

                        _ammoConfig = configFile >> "cfgmagazines" >> _ammoType;
                        _ammoName = getText (_ammoConfig >> "displayName");
                        _ammoPicture = getText (_ammoConfig >> "picture");

                        [_objAmmo, _ammoType, [0, 0, _ammoName, _ammoPicture]] call ALIVE_fnc_hashSet;
                    };

                    _ammoTypeData = [_objAmmo, _ammoType] call ALIVE_fnc_hashGet;
                    _ammoRoundCount = _ammoTypeData select 0;
                    _ammoMagazineCount = _ammoTypeData select 1;
                    _ammoRoundCount = _ammoRoundCount + _ammoCount;
                    _ammoMagazineCount = _ammoMagazineCount + 1;
                    _ammoTypeData set [0,_ammoRoundCount];
                    _ammoTypeData set [1,_ammoMagazineCount];
                    [_objAmmo, _ammoType, _ammoTypeData] call ALIVE_fnc_hashSet;

                };
            } foreach _unitAmmo;

            //_objAmmo call ALIVE_fnc_inspectHash;

            {
                _row = [];
                _labels = [];

                _ammoTypeData = [_objAmmo, _x] call ALIVE_fnc_hashGet;
                _ammoRoundCount = _ammoTypeData select 0;
                _ammoMagazineCount = _ammoTypeData select 1;
                _ammoName = _ammoTypeData select 2;
                _ammoPicture = _ammoTypeData select 3;

                _labels pushback (_ammoPicture);
                _labels pushback (_ammoName);
                _labels pushback (format['%1 mags', _ammoMagazineCount]);
                _labels pushback (format['%1 rounds', _ammoRoundCount]);

                _row pushback (_labels);

                _rows pushback (_row);
                _values pushback (_ammoName);

            } foreach (_objAmmo select 1);

        };


        // handgun

        _row = [];
        _labels = [];

        _obj = handgunWeapon _x;

        if!(_obj == '') then {

            _objConfig = configFile >> "cfgweapons" >> _obj;
            _objName = getText (_objConfig >> "displayName");
            _objPicture = getText (_objConfig >> "picture");
            _objMagazines = _obj call ALIVE_fnc_configGetWeaponMagazines;

            _labels pushback (_objPicture);
            _labels pushback (_objName);

            _row pushback (_labels);

            _rows pushback (_row);
            _values pushback (_obj);

            _objAmmo = [] call ALIVE_fnc_hashCreate;

            {
                _ammoType = _x select 0;
                _ammoCount = _x select 1;
                _ammoMax = _x select 2;

                if((_ammoMax > 1) && (_ammoType in _objMagazines)) then {

                    if!(_ammoType in (_objAmmo select 1)) then {

                        _ammoConfig = configFile >> "cfgmagazines" >> _ammoType;
                        _ammoName = getText (_ammoConfig >> "displayName");
                        _ammoPicture = getText (_ammoConfig >> "picture");

                        [_objAmmo, _ammoType, [0, 0, _ammoName, _ammoPicture]] call ALIVE_fnc_hashSet;
                    };

                    _ammoTypeData = [_objAmmo, _ammoType] call ALIVE_fnc_hashGet;
                    _ammoRoundCount = _ammoTypeData select 0;
                    _ammoMagazineCount = _ammoTypeData select 1;
                    _ammoRoundCount = _ammoRoundCount + _ammoCount;
                    _ammoMagazineCount = _ammoMagazineCount + 1;
                    _ammoTypeData set [0,_ammoRoundCount];
                    _ammoTypeData set [1,_ammoMagazineCount];
                    [_objAmmo, _ammoType, _ammoTypeData] call ALIVE_fnc_hashSet;

                };
            } foreach _unitAmmo;

            //_objAmmo call ALIVE_fnc_inspectHash;

            {
                _row = [];
                _labels = [];

                _ammoTypeData = [_objAmmo, _x] call ALIVE_fnc_hashGet;
                _ammoRoundCount = _ammoTypeData select 0;
                _ammoMagazineCount = _ammoTypeData select 1;
                _ammoName = _ammoTypeData select 2;
                _ammoPicture = _ammoTypeData select 3;

                _labels pushback (_ammoPicture);
                _labels pushback (_ammoName);
                _labels pushback (format['%1 mags', _ammoMagazineCount]);
                _labels pushback (format['%1 rounds', _ammoRoundCount]);

                _row pushback (_labels);

                _rows pushback (_row);
                _values pushback (_ammoName);

            } foreach (_objAmmo select 1);

        };



        // divider

        _row = [];
        _labels = [];

        _labels pushback ("");

        _row pushback (_labels);

        _rows pushback (_row);
        _values pushback (_obj);

    };
} foreach (units _group);


_data pushback (_rows);
_data pushback (_values);

_data
