#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(checkConfigCompatibility);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_checkConfigCompatibility

Description:
Checks a faction for compatibility

Parameters:
Config - config file

Returns:

Examples:
(begin example)
// inspect config class
["BLU_F"] call ALIVE_fnc_checkConfigCompatibility;

// inspect all factions
_factions = configfile >> "CfgFactionClasses";
for "_i" from 0 to count _factions -1 do {

    _faction = _factions select _i;
    if(isClass _faction) then {
        _configName = configName _faction;
        _side = getNumber(_faction >> "side");
        if(_side < 3) then {
            [configName (_factions select _i)] call ALIVE_fnc_checkConfigCompatibility;
        };
    };
}
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_dump","_sideToText","_cfgValue","_faction"];

_dump = {
    private ["_variable","_variableType","_output"];

    _variable = _this select 0;
    _variableType = typename _variable;
    _output = "";

    if(count _this > 1) then {
    	_variable = format _this;
    };

    if(isNil {_variableType}) then {
    	_output = ["IS NIL"];
    } else {
    	if(_variableType == "STRING") then {
    		_output = _variable;
    	} else {
    		_output = str _variable;
    	};
    };

    diag_log text _output;
};

_sideToText = {
    switch (_this select 0) do
    {
    	case 0: {"East"};
    	case 1: {"West"};
    	case 2: {"Indep"};
    	case 3: {"CIV"};
    	default {""};
    };
};

_cfgValue = {
    private ["_cfg"];
    _cfg = _this select 0;

    switch (true) do {
    	case (isText(_cfg)): {getText(_cfg)};
    	case (isNumber(_cfg)): {getNumber(_cfg)};
    	case (isArray(_cfg)): {getArray(_cfg)};
    	case (isClass(_cfg)): {_cfg};
    	default {nil};
    };
};

_cfgFindFaction = {
    private ["_cfg","_faction","_detailed","_item","_text","_result","_findRecurse","_className"];

    _cfg = _this select 0;
    _faction = _this select 1;

    _result = [];

    _findRecurse = {
    	private ["_root","_class","_path","_currentPath","_currentFaction"];

    	_root = (_this select 0);
    	_path = +(_this select 1);

        _currentFaction = [_root >> "faction"] call _cfgValue;

    	if!(isNil "_currentFaction") then {
    	    if(_currentFaction == _faction) then {
    	        _result pushback _root;
    	    };
    	};

    	for "_i" from 0 to count _root -1 do {

    		_class = _root select _i;

    		if (isClass _class) then {
    			_currentPath = _path + [_i];

    			_className = configName _class;

    			_class = _root >> _className;

    			[_class, _currentPath] call _findRecurse;
    		};
    	};
    };

    [_cfg, []] call _findRecurse;

    _result
};



_faction = _this select 0;

[""] call _dump;
[""] call _dump;
_text = " ----------------------------------------------------------------------------------------------------------- ";
[_text] call _dump;
[""] call _dump;
[""] call _dump;
_text = " ----------- Faction Compatibility ----------- ";
[_text] call _dump;
["Checking compatibility for faction: %1",_faction] call _dump;



// first check the faction

private ["_factionOK","_text","_config","_displayName","_side","_sideToText"];

_factionOK = false;

[""] call _dump;
_text = " ----------- CfgFactionClass ----------- ";
[_text] call _dump;
[""] call _dump;
_text = "Checking faction is found in CfgFactionClasses";
[_text] call _dump;


_config = configfile >> "CfgFactionClasses" >> _faction;

if(count _config > 0) then {
    _displayName = [_config >> "displayName"] call _cfgValue;
    _side = [_config >> "side"] call _cfgValue;
    _sideToText = [_side] call _sideToText;
    ["faction found in CfgFactionClasses. Display: %2 Side: %3",_faction,_displayName,_sideToText] call _dump;

    _factionOK = true;
}else{
    ["faction %1 not found in CfgFactionClasses..",_faction] call _dump;
};



// check groups matching the faction

private ["_factionToGroupMappingOK","_factionGroups"];

_factionToGroupMappingOK = false;

[""] call _dump;
_text = " ----------- CfgGroups ----------- ";
[_text] call _dump;
[""] call _dump;
_text = "Checking faction has a direct relationship to CfgGroups entry";
[_text] call _dump;


_config = configfile >> "CfgGroups" >> _sideToText >> _faction;

if(count _config > 0) then {
    ["faction found in CfgGroups >> %2 >> %1",_faction,_sideToText] call _dump;

    _factionToGroupMappingOK = true;

    _factionGroups = [_config,_faction] call _cfgFindFaction;
}else{
    ["-- warning: faction not found in CfgGroups >> %2 >> %1",_faction,_sideToText] call _dump;
};


// if the direct mapping check failed try reverse lookup groups > faction

private ["_groupToFactionMappingOK"];

_groupToFactionMappingOK = false;

if!(_factionToGroupMappingOK) then {
    [""] call _dump;
    _text = "Checking if any CfgGroups entries have relationship to the faction";
    [_text] call _dump;

    _config = configfile >> "CfgGroups" >> _sideToText;
    _factionGroups = [_config,_faction] call _cfgFindFaction;

    if(count _factionGroups > 0) then {
        ["-- warning: %1 groups have been found in CfgGroups >> %2",count _factionGroups,_sideToText] call _dump;
        ["-- warning: Suggest naming the CfgGroup parent class matching faction name eg: CfgGroups >> %1 >> %2",_sideToText,_faction] call _dump;

        _groupToFactionMappingOK = true;
    }else{
        ["-- warning: no groups found in CfgGroups with faction: %1",_faction] call _dump;
    };

};


// check for standardised naming convention for CfgGroup categories

private ["_groupCategoriesOK","_entry","_splitEntry","_cfgGroupFactionName","_standardCategories","_class","_configName"];

_groupCategoriesOK = true;

if(_groupToFactionMappingOK || _factionToGroupMappingOK && (count _factionGroups > 0)) then {

    [""] call _dump;
    _text = "Checking standardised naming convention for CfgGroup categories";
    [_text] call _dump;

    _entry = _factionGroups select 0;

    _splitEntry = [str _entry,"/"] call CBA_fnc_split;

    _cfgGroupFactionName = _splitEntry select 3;

    _config = configfile >> "CfgGroups" >> _sideToText >> _cfgGroupFactionName;

    _standardCategories = ["Infantry","SpecOps","Support","Motorized","Mechanized","Armored","Air"];

    for "_i" from 0 to count _config -1 do {
    	_class = _config select _i;

    	if (isClass _class) then {
    	    _configName = configName _class;
    	    if!(_configName in _standardCategories) then {

                ["-- warning: CfgGroups category: %1 is not a standard group category!",_configName,_standardCategories] call _dump;
                ["-- warning: Suggest using standard naming convention for CfgGroup categories eg one of: %1",_standardCategories] call _dump;

                _groupCategoriesOK = false;
    	    }else{
                ["CfgGroups category: %1 is a standard group category",_configName] call _dump;
    	    };

    	};

    };

};

// found some groups for the faction - investigate them

private ["_standardVehicleTypes","_groupSide","_groupFaction","_groupConfigName","_unitConfigName","_unitSide","_unitVehicle",
"_unitRank","_vehicleConfigName","_vehicleType","_vehicleCrew","_crewConfig","_crewConfigName","_crewFaction","_crewSide"];

if(_groupToFactionMappingOK || _factionToGroupMappingOK && (count _factionGroups > 0)) then {

    [""] call _dump;
    _text = "Checking individual CfgGroups entries for the faction";
    [_text] call _dump;

    _standardVehicleTypes = ["Ship","Submarine","Armored","Car","Static","Air","Autonomous","Support"];

    {
        [""] call _dump;
        ["Checking Group: %1",_x] call _dump;

        _groupSide = [_x >> "side"] call _cfgValue;
        _groupFaction = [_x >> "faction"] call _cfgValue;
        _groupConfigName = configName _x;

        if(isNil "_groupSide") then {
            ["-- warning: Group: %1 has no side number set, suggest adding it!",_groupConfigName] call _dump;
        };

        if(isNil "_groupFaction") then {
            ["-- warning: Group: %1 has no faction set, suggest adding it!",_groupConfigName] call _dump;
        };

        for "_i" from 0 to count _x -1 do {

            _class = _x select _i;

            if (isClass _class) then {

                _unitConfigName = configName _class;
                _unitSide = [_class >> "side"] call _cfgValue;
                _unitVehicle = [_class >> "vehicle"] call _cfgValue;
                _unitRank = [_class >> "rank"] call _cfgValue;

                if(isNil "_unitSide") then {
                    ["-- warning: Group %1 Unit %2 has no side number set, suggest adding it!",_groupConfigName,_unitConfigName] call _dump;
                };

                if(isNil "_unitRank") then {
                    ["-- warning: Group %1 Unit %2 has no rank set, suggest adding it!",_groupConfigName,_unitConfigName] call _dump;
                };

                if!(isNil "_unitVehicle") then {

                    _vehicleConfig = configfile >> "CfgVehicles" >> _unitVehicle;

                    if(count _vehicleConfig > 0) then {

                        _vehicleConfigName = configName _vehicleConfig;

                        if(_vehicleConfigName isKindOf "Man") then {

                        }else{

                            _vehicleType = [_vehicleConfig >> "vehicleClass"] call _cfgValue;
                            _vehicleCrew = [_vehicleConfig >> "crew"] call _cfgValue;

                            if!(_vehicleType in _standardVehicleTypes) then {

                                ["-- warning: CfgVehicle %1 vehicleClass: %2 is not a standard vehicleClass!",_vehicleConfigName,_vehicleType] call _dump;
                                ["-- warning: Suggest using standard naming convention for CfgVehicle vehicleClass eg one of: %1",_standardVehicleTypes] call _dump;

                            };

                            if!(isNil "_vehicleCrew") then {
                                _crewConfig = configfile >> "CfgVehicles" >> _vehicleCrew;


                                if(count _crewConfig > 0) then {
                                    /*
                                    _crewConfigName = configName _crewConfig;
                                    _crewFaction = [_crewConfig >> "faction"] call _cfgValue;
                                    _crewSide = [_crewConfig >> "side"] call _cfgValue;

                                    if!(_crewFaction == _faction) then {
                                        ["-- warning: CfgVehicle %1 has crew defined %2 not from it's own faction %3!",_vehicleConfigName,_crewConfigName,_crewFaction] call _dump;
                                    };
                                    */
                                }else{
                                    ["-- warning: Group %1 Vehicle %2 crew %3 has no CfgVehicles entry!!!",_groupConfigName,_vehicleConfigName,_vehicleCrew] call _dump;
                                }
                            };
                        };

                    }else{
                        ["-- warning: Group %1 Vehicle %2 has no matching class in CfgVehicles!!!",_groupConfigName,_unitVehicle] call _dump;
                    };

                    // we have a vehicle try to get it from CfgVehicles!

                }else{
                    ["-- warning: Group %1 Unit %2 has no vehicle set, suggest adding it!",_groupConfigName,_unitConfigName] call _dump;
                };

            };
        };


    } forEach _factionGroups;

};

// vehicles now..

private ["_factionVehicles","_factionMen","_class","_configName","_currentFaction","_vehicleType","_factionVehicleTypes"];

_factionVehicles = [] call ALIVE_fnc_hashCreate;
_factionMen = [];

_config = configfile >> "CfgVehicles";

for "_i" from 0 to count _config -1 do {
    _class = _config select _i;
    if (isClass _class) then {
        _configName = configName _class;
        _currentFaction = [_class >> "faction"] call _cfgValue;
        if!(isNil "_currentFaction") then {
            if(_currentFaction == _faction) then {
                if(_configName isKindOf "Man") then {
                    if([_class >> "scope"] call _cfgValue == 2) then {
                        _factionMen pushback _class;
                    };
                }else{
                    if([_class >> "scope"] call _cfgValue == 2) then {
                        _vehicleType = [_class >> "vehicleClass"] call _cfgValue;

                        if!(_vehicleType in (_factionVehicles select 1)) then {
                            [_factionVehicles,_vehicleType,[]] call ALIVE_fnc_hashSet;
                        };

                        _factionVehicleTypes = [_factionVehicles,_vehicleType] call ALIVE_fnc_hashGet;
                        _factionVehicleTypes pushback _class;

                        [_factionVehicles,_vehicleType,_factionVehicleTypes] call ALIVE_fnc_hashSet;
                    };
                };
            };
        };
    };
};


[""] call _dump;
_text = " ----------- CfgVehicles Vehicles ----------- ";
[_text] call _dump;
[""] call _dump;

private ["_spawnPosition","_vehicleType"];

_spawnPosition = (getPosATL player) getPos [10, 0];


[_factionVehicles,_side,_faction,_spawnPosition] spawn {

    private ["_factionVehicles","_vehicleClasses","_side","_faction","_spawnPosition","_vehicleClass","_configName","_vehicleCrew","_profiles"];

    _factionVehicles = _this select 0;
    _side = _this select 1;
    _faction = _this select 2;
    _spawnPosition = _this select 3;

    _side = [_side] call ALIVE_fnc_sideNumberToText;

    {

        _vehicleType = _x;

        _vehicleClasses = [_factionVehicles,_vehicleType] call ALIVE_fnc_hashGet;

        ["-- Type: %1",_vehicleType] call ALIVE_fnc_dump;

        {

            _vehicleClass = _x;

            _configName = configName _vehicleClass;

            [_configName] call ALIVE_fnc_dump;

            _vehicleCrew = [_vehicleClass >> "crew"] call ALIVE_fnc_getConfigValue;

            if!(isNil "_vehicleCrew") then {

                sleep 1;

                _profiles = [_configName,_side,_faction,"CAPTAIN",_spawnPosition,0,false] call ALIVE_fnc_createProfilesCrewedVehicle;

                sleep 10;

                {
                    _profileType = _x select 2 select 5;

                    if(_profileType == "entity") then {
                        [_x, "destroy"] call ALIVE_fnc_profileEntity;
                    }else{
                        [_x, "destroy"] call ALIVE_fnc_profileVehicle;
                    };

                } forEach _profiles;

                sleep 5;

            };

        } forEach _vehicleClasses;

    } forEach (_factionVehicles select 1);

};


[""] call _dump;
_text = " ----------- CfgVehicles Men ----------- ";
[_text] call _dump;
[""] call _dump;


{

    _vehicleClass = _x;

    _configName = configName _vehicleClass;

    [_configName] call _dump;

    _vehicleType = [_vehicleClass >> "vehicleClass"] call _cfgValue;

    //["-- Type: %1",_vehicleType] call _dump;


} forEach _factionMen;