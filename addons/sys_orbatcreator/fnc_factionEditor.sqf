//#define DEBUG_MODE_FULL
#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(factionEditor);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_factionEditor
Description:
Main handler for the orbat creator faction editor

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:

Examples:

See Also:
ALiVE_fnc_factionEditorGUI

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_factionEditor


private "_result";
params [
    ["_logic", objNull, [objNull, []]],
    ["_operation", "", [""]],
    ["_args", objNull]
];

switch (_operation) do {

    default {
        _result = _this call SUPERCLASS;
    };

    case "init": {

        [_logic,"super", QUOTE(SUPERCLASS)] call ALiVE_fnc_hashSet;
        [_logic,"class", QUOTE(MAINCLASS)] call ALiVE_fnc_hashSet;

		private _factionEditorGUI = [nil,"create"] call ALiVE_fnc_factionEditorGUI;
		[_factionEditorGUI,"init"] call ALiVE_fnc_factionEditorGUI;

		[_logic,"view", _factionEditorGUI] call ALiVE_fnc_hashSet;
		[_logic,"prefix", ""] call ALiVE_fnc_hashSet;

	};

	case "view": {

        if (_args isEqualType []) then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

	};

	case "prefix": {

        if (_args isEqualType "") then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

	};

	case "openUI": {

		private _view = [_logic,"view"] call ALiVE_fnc_hashGet;
		[_view,"openUI"] call ALiVE_fnc_factionEditorGUI;

	};

	case "closeUI": {

		private _view = [_logic,"view"] call ALiVE_fnc_hashGet;
		[_view,"closeUI"] call ALiVE_fnc_factionEditorGUI;

	};

	case "generateFactionClassname": {

		_args params ["_side","_country","_force","_camo"];

		private _prefix = [_logic,"prefix"] call MAINCLASS;

		_country = _country + _force;

        private _sideText = [_side] call ALiVE_fnc_sideNumberToText;
        private _sideTextLong = [_sideText] call ALiVE_fnc_sideTextToLong;
		_sideTextLong = [_sideTextLong] call CBA_fnc_leftTrim;
        private _sidePrefix = _sideTextLong select [0,1];

        private _countryPrefix = [_country," ",""] call CBA_fnc_replace;
        _countryPrefix = [_countryPrefix,"_",""] call CBA_fnc_replace;

        private _classname = format ["%1_%2", _sidePrefix, _countryPrefix];

        if (_prefix != "") then {
            _classname = format ["%1_%2", _prefix, _classname];
        };

        if (_camo != "") then {
            _classname = format ["%1_%2", _classname, _camo];
        };

        _result = _classname

	};

};

TRACE_1("Faction Editor - output", _result);

if (!isnil "_result") then {_result} else {nil};