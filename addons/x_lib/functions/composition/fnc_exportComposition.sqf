#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(exportComposition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_exportComposition

Description:
Reads CfgGroups data and exports ALiVE formatted code

Parameters:

Returns:

Examples:
(begin example)
//
_result = [] call ALIVE_fnc_exportComposition;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_configPath"];

_configPath = configFile >> "CfgGroups" >> "Empty" >> "ALIVE";


["EXPORT CfgGroups"] call ALIVE_fnc_dump;
["------------------------------------------------------"] call ALIVE_fnc_dump;
[""] call ALIVE_fnc_dump;


for "_i" from 0 to ((count _configPath) - 1) do
{

    private ["_item","_configName","_name"];

    _item = _configPath select _i;

    if (isClass _item) then {

        _configName = configName _item;
        _name = getText(_item >> "name");

        ["class %1",_configName] call ALIVE_fnc_dump;
        ["{"] call ALIVE_fnc_dump;
        ['name = "$STR_ALIVE_COMPOSITION_%1";',_configName] call ALIVE_fnc_dump;

        for "_i" from 0 to ((count _item) - 1) do
        {

            private ["_comp"];

            _comp = _item select _i;

            if (isClass _comp) then {

                _configName = configName _comp;
                _name = getText(_comp >> "name");

                ["class %1",_configName] call ALIVE_fnc_dump;
                ["{"] call ALIVE_fnc_dump;
                ['name = "$STR_ALIVE_COMPOSITION_%1";',_configName] call ALIVE_fnc_dump;

                for "_i" from 0 to ((count _comp) - 1) do
                {
                    private ["_object","_side","_vehicle","_rank","_position","_direction","_positionString"];

                    _object = _comp select _i;

                    if (isClass _object) then {

                        _configName = configName _object;
                        _side =  getNumber(_object >> "side");
                        _vehicle = getText(_object >> "vehicle");
                        _rank = getText(_object >> "rank");
                        _position = getArray(_object >> "position");
                        _direction = getNumber(_object >> "dir");

                        _positionString = "";
                        for "_i" from 0 to ((count _position) - 1) do
                        {
                            if(_i == (count _position) - 1) then {
                                _positionString = format["%1%2",_positionString, _position select _i];
                            }else{
                                _positionString = format["%1%2,",_positionString, _position select _i];
                            };
                        };

                        ['class %1 {side=%2;vehicle="%3";rank="%4";position[]={%5};dir=%6;};',_configName,_side,_vehicle,_rank,_positionString,_direction] call ALIVE_fnc_dump;

                        //class Object1 {side=8;vehicle="Land_Sleeping_bag_F";rank="";position[]={2.3103,0.960938,-0.00143862};dir=0;};

                    };
                };

                ["};"] call ALIVE_fnc_dump;

            };
        };

        ["};"] call ALIVE_fnc_dump;
        [""] call ALIVE_fnc_dump;

    };
};


["------------------------------------------------------"] call ALIVE_fnc_dump;
["EXPORT Stringtable"] call ALIVE_fnc_dump;
["------------------------------------------------------"] call ALIVE_fnc_dump;
[""] call ALIVE_fnc_dump;

/*
    <Key ID="STR_ALIVE_CMP">
        <English>Custom Military Objective</English>
    </Key>
*/

for "_i" from 0 to ((count _configPath) - 1) do
{

    private ["_item","_configName","_name"];

    _item = _configPath select _i;

    if (isClass _item) then {

        _configName = configName _item;
        _name = getText(_item >> "name");

        ['<Key ID="STR_ALIVE_COMPOSITION_%1">',_configName] call ALIVE_fnc_dump;
        ['<English>%1</English>',_name] call ALIVE_fnc_dump;
        ['</Key>'] call ALIVE_fnc_dump;

        for "_i" from 0 to ((count _item) - 1) do
        {

            private ["_comp"];

            _comp = _item select _i;

            if (isClass _comp) then {

                _configName = configName _comp;
                _name = getText(_comp >> "name");

                ['<Key ID="STR_ALIVE_COMPOSITION_%1">',_configName] call ALIVE_fnc_dump;
                ['<English>%1</English>',_name] call ALIVE_fnc_dump;
                ['</Key>'] call ALIVE_fnc_dump;


            };
        };
    };
};


["------------------------------------------------------"] call ALIVE_fnc_dump;
["EXPORT CfgVehicles Dropdowns"] call ALIVE_fnc_dump;
["------------------------------------------------------"] call ALIVE_fnc_dump;
[""] call ALIVE_fnc_dump;

/*
    class AAF_Communication_Camp_1
    {
            name = "$STR_ALIVE_CMP_COMPOSITION_AAF_CC1";
            value = "AAF_Communication_Camp_1";
    };
*/

for "_i" from 0 to ((count _configPath) - 1) do
{

    private ["_item","_configName","_name"];

    _item = _configPath select _i;

    if (isClass _item) then {

        for "_i" from 0 to ((count _item) - 1) do
        {

            private ["_comp"];

            _comp = _item select _i;

            if (isClass _comp) then {

                _configName = configName _comp;
                _name = getText(_comp >> "name");

                ["class %1",_configName] call ALIVE_fnc_dump;
                ["{"] call ALIVE_fnc_dump;
                ['name = "$STR_ALIVE_COMPOSITION_%1";',_configName] call ALIVE_fnc_dump;
                ['value = "%1";',_configName] call ALIVE_fnc_dump;
                ["};"] call ALIVE_fnc_dump;


            };
        };
    };
};