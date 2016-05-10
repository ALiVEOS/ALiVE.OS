#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getFactionsDataSource);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getFactionsDataSource

Description:
Get current players info formatted for a UI datasource

Parameters:


Returns:
Array - Multi dimensional array of values and options

Examples:
(begin example)
_datasource = [] call ALiVE_fnc_getFactionsDataSource
(end)

Author:
ARJay
 
Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_side","_data","_options","_values","_factionConfig","_class","_classSide","_classSideText","_factionClass","_factionName"];

_data = [];
_options = [];
_values = [];

_factionConfig = (configfile >> "CfgFactionClasses");

for "_i" from 0 to count _factionConfig -1 do {
	_class = _factionConfig select _i;

	if (isClass _class) then {

        _classSide = getNumber(_class >> "side");

	    if(_classSide >= 0 && _classSide < 3) then {
	        _classSideText = [_classSide] call ALIVE_fnc_sideNumberToText;
            _classSideText = [_classSideText] call ALIVE_fnc_sideTextToLong;
	        _factionClass = configName _class;
            _factionName = getText(_class >> "displayName");
            _options pushback (format["%1 - %2",_factionName,_classSideText]);
            _values pushback _factionClass;
	    };

	};
};

_data set [0,_options];
_data set [1,_values];

_data
