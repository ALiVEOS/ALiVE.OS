//#define DEBUG_MODE_FULL
#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\include.hpp"
SCRIPT(orbatCreatorGUI);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_orbatCreatorGUI
Description:
Main handler for the orbat creator interface

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:


Examples:


See Also:
- <ALiVE_fnc_orbatCreatorInit>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_orbatCreatorGUI


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

        [_logic,"super", QUOTE(SUPERCLASS] call ALiVE_fnc_hashSet;
        [_logic,"class", QUOTE(MAINCLASS] call ALiVE_fnc_hashSet;

		[_logic,"background", true] call ALiVE_fnc_hashSet;
		[_logic,"selectedFaction", ""] call ALiVE_fnc_hashSet;

	};

    case "background": {

        if (_args isEqualType true) then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "selectedFaction": {

        if (_args isEqualType "") then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "enableUnitEditorBackground": {

        private _enable = _args;

        private _state = [_logic,"state"] call MAINCLASS;

        if (_enable) then {
            private _pos = getPos _logic;

            0 fadeSound 0;

            // init background
            private _background = createVehicle ["HeliHEmpty",[0,0,0],[],0,"none"];
            if ([_logic,"background"] call MAINCLASS) then {
                _background = createVehicle ["Sphere_3DEN",[0,0,0],[],0,"none"];
                _pos set [2,500];
            };
            _background setPos _pos;
            _background setDir 0;

            [_state,"unitEditor_interfaceBackground", _background] call ALiVE_fnc_hashSet;

            // init camera

            private _tempUnit = createVehicle [typeOf player,position player,[],0,"none"];
            _tempUnit setPos _pos;
            _tempUnit setDir 0;
            _tempUnit switchAction "playerstand";
            _tempUnit enableSimulation false;

            [_state,"unitEditor_activeUnitPosition", getPos _tempUnit] call ALiVE_fnc_hashSet;

            private _target = _tempUnit modelToWorld [0,4,1.6];
            [_logic,"deleteUnit", _tempUnit] call MAINCLASS;

            private _cam = "camera" camCreate _pos;
            _cam camSetFov 0.35;
            _cam setDir (_cam getRelDir _tempUnit);
            _cam camSetTarget _target;
            _cam camSetRelPos [-0.05,1,0.15];
            _cam cameraEffect ["Internal", "Back"];
            _cam camcommit 0;

            showcinemaborder false;

            [_state,"unitEditor_interfaceCamera", _cam] call ALiVE_fnc_hashSet;
        } else {
            private _interfaceCamera = [_state,"unitEditor_interfaceCamera"] call ALiVE_fnc_hashGet;
            private _interfaceBackground = [_state,"unitEditor_interfaceBackground"] call ALiVE_fnc_hashGet;
            private _activeUnit = [_state,"unitEditor_activeUnitObject"] call ALiVE_fnc_hashGet;

            _interfaceCamera cameraEffect ["terminate","back"];
            camDestroy _interfaceCamera;

            [_logic,"deleteUnit", _activeUnit] call MAINCLASS;
            deleteVehicle _interfaceBackground;

            [player,"FIRST_PERSON"] call ALIVE_fnc_switchCamera;
        };

    };

	case "onMenuStripButtonClicked": {

		_args params ["_control","_menuPath"];

        private _op = menuData [OC_COMMON_MENUSTRIP,_menuPath];

        switch (_op) do {

            case "orbatCreatorClose": {

                //[_logic,"closeOrbatCreator"] call MAINCLASS;

            };

            case "factionEditorOpen": {

                //[_logic,"openInterface", "Faction_Editor"] spawn MAINCLASS;

            };

            case "unitEditorOpen": {

                //[_logic,"openInterface", "Unit_Editor"] spawn MAINCLASS;

            };

            case "groupEditorOpen": {

                //[_logic,"openInterface", "Group_Editor"] spawn MAINCLASS;

            };

            case "exportFaction": {

                //[_logic,"exportConfig", "Faction"] call MAINCLASS;

            };

            case "exportCrates": {

                //[_logic,"exportConfig", "Crates"] call MAINCLASS;

            };

            case "exportImages": {

                //[_logic,"exportConfig", "Images"] call MAINCLASS;

            };

            case "exportUnitsSelected": {

                //[_logic,"exportConfig", "UnitsSelected"] call MAINCLASS;

            };

            case "exportUnitsAll": {

                //[_logic,"exportConfig", "UnitsAll"] call MAINCLASS;

            };

            case "exportUnitsClasses": {

                //[_logic,"exportConfig", "UnitsClasses"] call MAINCLASS;

            };

            case "exportGroupsSelected": {

                //[_logic,"exportConfig", "GroupsSelected"] call MAINCLASS;

            };

            case "exportGroupsAll": {

                //[_logic,"exportConfig", "GroupsAll"] call MAINCLASS;

            };

            case "exportGroupsAllStaticData": {

                //[_logic,"exportConfig", "GroupsAllStaticData"] call MAINCLASS;

            };

            case "exportFull": {

                //[_logic,"exportConfig", "Full"] call MAINCLASS;

            };

            case "exportCfgPatches": {

                //[_logic,"exportConfig", "CfgPatches"] call MAINCLASS;

            };

            case "exportFullWrite": {

                //[_logic,"exportConfig", "FullWrite"] call MAINCLASS;

            };

            case "exportFullWriteImages": {

                //[_logic,"exportConfig", "FullWriteImages"] call MAINCLASS;

            };

		};

	};

	case "closeUI": {

		closeDialog 0;

	};

	case "loadSidesToList": {

        private _list = _args;

        lbClear _list;

        for "_i" from 0 to 3 do {
            private _sideNum = _i;
            private _sideText = [_sideNum] call ALiVE_fnc_sideNumberToText;
            private _sideText = [_sideText] call ALiVE_fnc_sideTextToLong;

            private _index = _list lbAdd _sideText;
            _list lbSetData [_index,str _sideNum];
        };

	};

	case "loadFlagsToList": {

		private _list = _args;

		lbClear _list;

		private _allFlags = [MOD(orbatCreator),"getAllFlags"] call ALiVE_fnc_orbatCreator;

		{
			_x params ["_name","_path"];

			private _index = _list lbAdd _name;
			_list lbSetData [_index,_path];
			_list lbSetPicture [_index,_path];
		} foreach _allFlags;

	};

};

TRACE_1("Orbat Creator GUI - output", _result);

if (!isnil "_result") then {_result} else {nil};