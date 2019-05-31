//#define DEBUG_MODE_FULL
#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(orbatCreatorFaction);
/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_orbatCreatorFaction
Description:
Main handler for factions for the orbat creator

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance

Examples:
_faction = [nil,"create"] call ALiVE_fnc_orbatCreatorFaction;

See Also:
- <ALiVE_fnc_orbatCreator>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClass
#define MAINCLASS   ALiVE_fnc_orbatCreatorFaction

private "_result";
params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch (_operation) do {

    default {
        _result = _this call SUPERCLASS;
    };

    case "create": {

		_args params [
			"_configName",
			"_displayName",
			"_flag",
			"_icon",
			"_priority",
			"_sideNum",
			["_camo", ""],
			["_groupCategoriesRootName", ""],
			["_groupsByCategory", []],
			["_assetCategories", []],
			["_assets", []]
		];

		_logic = [nil,"create"] call SUPERCLASS;

		_logic setvariable ["super", QUOTE(SUPERCLASS)];
		_logic setvariable ["class", QUOTE(MAINCLASS)];

        private _tmpHash = [] call ALiVE_fnc_hashCreate;

        // CfgFactionClass

		_logic setvariable ["configName", _configName];
		_logic setvariable ["displayName", _displayName];
		_logic setvariable ["shortName", _displayName];
		_logic setvariable ["flag", _flag];
		_logic setvariable ["icon", _icon];
		_logic setvariable ["priority", _priority];
		_logic setvariable ["side", _sideNum];
		_logic setvariable ["groupCategoriesRootName", _groupCategoriesRootName];
		_logic setvariable ["camo", _camo];

        // CfgGroups

        private _groupCategory = +_tmpHash;
        [_groupCategory,"name",""] call ALiVE_fnc_hashSet;
        [_groupCategory,"configName", ""] call ALiVE_fnc_hashSet;
        [_groupCategory,"groups", +_tmpHash] call ALiVE_fnc_hashSet;

		private _createGroupCategory = {
			params ["_name","_configName"];

			private _category = +_groupCategory;
			[_category,"name", _name] call ALiVE_fnc_hashSet;
			[_category,"configName", _configName] call ALiVE_fnc_hashSet;
		};

		if (_groupsByCategory isequalto []) then {
			private _groupCategoryInfantry = ["Infantry","Infantry"] call _createGroupCategory;
			private _groupCategorySpecOps = ["Special Forces","SpecOps"] call _createGroupCategory;
			private _groupCategoryMotorized = ["Motorized Infantry","Motorized"] call _createGroupCategory;
			private _groupCategoryMotorizedMTP = ["Motorized Infantry (MTP)","Motorized_MTP"] call _createGroupCategory;
			private _groupCategorySupport = ["Support Infantry","Support"] call _createGroupCategory;
			private _groupCategoryMechanized = ["Mechanized Infantry","Mechanized"] call _createGroupCategory;
			private _groupCategoryArmored = ["Armor","Armored"] call _createGroupCategory;
			private _groupCategoryArtillery = ["Artillery","Artillery"] call _createGroupCategory;
			private _groupCategoryNaval = ["Naval","Naval"] call _createGroupCategory;
			private _groupCategoryAir = ["Air","Air"] call _createGroupCategory;

			_groupsByCategory = +_tmpHash;
			[_groupsByCategory,"Infantry", _groupCategoryInfantry] call ALiVE_fnc_hashSet;
			[_groupsByCategory,"SpecOps", +_groupCategorySpecOps] call ALiVE_fnc_hashSet;
			[_groupsByCategory,"Motorized", _groupCategoryMotorized] call ALiVE_fnc_hashSet;
			[_groupsByCategory,"Motorized_MTP", +_groupCategoryMotorizedMTP] call ALiVE_fnc_hashSet;
			[_groupsByCategory,"Mechanized", _groupCategoryMechanized] call ALiVE_fnc_hashSet;
			[_groupsByCategory,"Support", _groupCategorySupport] call ALiVE_fnc_hashSet;
			[_groupsByCategory,"Armored", _groupCategoryArmored] call ALiVE_fnc_hashSet;
			[_groupsByCategory,"Artillery", _groupCategoryArtillery] call ALiVE_fnc_hashSet;
			[_groupsByCategory,"Naval", _groupCategoryNaval] call ALiVE_fnc_hashSet;
			[_groupsByCategory,"Air", _groupCategoryAir] call ALiVE_fnc_hashSet;

			_logic setvariable ["groupCategories", _groupsByCategory];
			[_logic,"initGroupCategories"] call MAINCLASS;
		};

		_logic setvariable ["groupCategories", _groupsByCategory];

        // units / vehicles

		_logic setvariable ["assetCategories", _assetCategories];
		_logic setvariable ["assets", _assets];

		_logic setvariable ["assetsImportedConfig", false];

		_result = _logic;

    };

    case "configName": {

        if (_args isequaltype "") then {
			_logic setvariable [_operation,_args];
            _result = _args;
        } else {
			_result = _logic getvariable _operation;
        };

    };

    case "displayName": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "shortName": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "flag": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "icon": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "priority": {

        if (_args isequaltype 0) then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "side": {

        if (_args isequaltype 0) then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "camo": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "groupCategoriesRootName": {

        if (_args isequaltype "") then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "groupCategories": {

        if (_args isequaltype []) then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "assets": {

        if (_args isequaltype []) then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

    case "assetCategories": {

        if (_args isequaltype []) then {
            _logic setvariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getvariable _operation;
        };

    };

	case "initGroupCategories": {

		private _factionClassname = [_logic,"configName"] call MAINCLASS;
        private _factionGroupCategories = [_logic,"groupCategories"] call MAINCLASS;

        private _factionConfigGroupCategories = _factionClassname call ALiVE_fnc_configGetFactionGroups;
        private _factionConfigGroupCategoryName = configname _factionConfigGroupCategories;

        for "_i" from 0 to (count _factionConfigGroupCategories - 1) do {
            private _groupCategory = _factionConfigGroupCategories select _i;

            if (isclass _groupCategory) then {
                private _groupCategoryDisplayName = gettext (_groupCategory >> "name");
                private _groupCategoryConfigName = configname _groupCategory;

                if (_groupCategoryConfigName == "Motorized_MTP") then {
                    _groupCategoryDisplayName = "Motorized Infantry (MTP)";
                };

                private _categoryGroups = [] call ALiVE_fnc_hashCreate;

                for "_i" from 0 to (count _groupCategory - 1) do {
                    private _groupEntry = _groupCategory select _i;

                    if (isclass _groupEntry) then {
                        private _groupConfigName = configName _groupEntry;
                        private _groupName = getText (_groupEntry >> "name");
                        private _groupSide = getNumber (_groupEntry >> "side");
                        private _groupFaction = getText (_groupEntry >> "faction");
                        private _groupIcon = getText (_groupEntry >> "icon");
                        private _rarityGroup = getNumber (_groupEntry >> "rarityGroup");

                        if (_rarityGroup == 0) then {
                            _rarityGroup = 0.5;
                        };

                        private _units = [];

                        for "_i" from 0 to (count _groupEntry - 1) do {
                            private _unitEntry = _groupEntry select _i;

                            if (isclass _unitEntry) then {
                                private _unitSide = getNumber (_unitEntry >> "side");
                                private _unitVehicle = getText (_unitEntry >> "vehicle");
                                private _unitRank = getText (_unitEntry >> "rank");
                                private _unitPosition = getArray (_unitEntry >> "position");

                                private _unit = [[
									["side", _unitSide],
									["vehicle", _unitVehicle],
									["rank", _unitRank],
									["position", _unitPosition]
								]] call ALiVE_fnc_hashCreate;

                                _units pushback _unit;
                            };

                        };

                        private _group = [[
							["configName", _groupConfigName],
							["name", _groupName],
							["side", _groupSide],
							["faction", _groupFaction],
							["icon", _groupIcon],
							["rarityGroup", _rarityGroup],
							["units", _units]
						]] call ALiVE_fnc_hashCreate;

                        [_categoryGroups,_groupConfigName,_group] call ALiVE_fnc_hashSet;
                    };
                };

                _newGroupCategory = [[
					["name", _groupCategoryDisplayName],
					["configName", _groupCategoryConfigName],
					["groups", _categoryGroups]
				]] call ALiVE_fnc_hashCreate;

                [_factionGroupCategories,_groupCategoryConfigName,_newGroupCategory] call ALiVE_fnc_hashSet;
            };
        };

		[_logic,"groupCategoriesRootName", _factionConfigGroupCategoryName] call MAINCLASS;
		[_logic,"groupCategories", _factionGroupCategories] call MAINCLASS;

	};

};

if (!isnil "_result") then {_result} else {nil};