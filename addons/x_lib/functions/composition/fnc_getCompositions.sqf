#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getCompositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getCompositions

Description:
Returns an array of composition configs

Parameters:
String - Type - Civilian, Military, Guerrilla
Array - Category name(s) - leave [] for any

    Civilian Categories - airports, checkpointsbarricades, construction, constructionSupplies, communications, fuel, general, heliports, industrial, marine, mining_oil, power, rail, settlements
    Guerrilla Categories - camps, checkpointsbarricades, constructionsupplies, commnunications, fieldhq, fort, fuel, hq, marine, medical, outposts, power, supports
    Military Categories - airports, camps, checkpointsbarricades, constructionsupplies, communications, crashsites, fieldhq, fort, fuel, heliports, hq, marine, medical, outposts, power, supports, supplies

Array - Size - ["Large","Medium","Small"] - leave [] for any size
Array - Faction(s) (Optional) - leave [] for any faction

Returns:
Array - Of composition configs, empty array if nothing found

Examples:
(begin example)
//
_result = [_compType, _cat, _size, _factions] call ALiVE_fnc_getCompositions;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

// ["COMPOSITION INPUT : %1",_this] call ALiVE_fnc_dump;

if (count _this < 3) exitWith {};

private _comp = _this select 0;
private _compType = _comp;
private _cat = if (typeName (_this select 1) == "ARRAY") then {_this select 1} else {[_this select 1]};
private _size = if (typeName (_this select 2) == "ARRAY") then {_this select 2} else {[_this select 2]};
private _env = "Urban";
private _faction = [];
private _enemyFactions = [];
private _searchString = [];
private _result = [];
private _recursive = false;

if (count _this > 3) then {
    if (typeName (_this select 3) == "ARRAY") then {_faction = _this select 3} else {_faction = [_this select 3]};
};

if (count _this > 4) then {
    _recursive = _this select 4;
};

if (count _this > 5) then {
    _searchString = _this select 5;
};

if (!isNil "ALiVE_mapCompositionType") then {
    _env = ALiVE_mapCompositionType;
};

if (_env != "Urban") then {
    _compType = format["%1_%2",_comp,_env]; // Civilian_Pacific etc
};

private _configPaths = [
    missionConfigFile >> "CfgGroups" >> "Empty" >> _compType,
    configFile >> "CfgGroups" >> "Empty" >> _compType
];

// Default to regular if additional PBOs are not loaded
if (!isClass (_configPaths select 0) && !isClass(_configPaths select 1)) then {
    ["WARNING: You don't appear to have the %1 compositions loaded, make sure you have added the composition PBOs to your @ALiVE or @ALiVEServer addon folders! Falling back to %2!", _compType,_comp] call ALiVE_fnc_dump;

    _configPaths = [
        missionConfigFile >> "CfgGroups" >> "Empty" >> _comp,
        configFile >> "CfgGroups" >> "Empty" >> _comp
    ];
};

// Get enemy factions
if (count _faction != 0) then {
    {
        private _friendlySide = _x call ALiVE_fnc_factionSide;
        private _enemySide = [];
        switch (_friendlySide) do {
            case EAST : {
                _enemySide = [WEST];
                if ([RESISTANCE, EAST] call BIS_fnc_sideIsEnemy) then {
                    _enemySide pushback RESISTANCE;
                };
            };
            case WEST: {
                _enemySide = [EAST];
                if ([RESISTANCE, WEST] call BIS_fnc_sideIsEnemy) then {
                    _enemySide pushback RESISTANCE;
                };
            };
            case RESISTANCE: {
                if ([WEST, RESISTANCE] call BIS_fnc_sideIsEnemy) then {
                    _enemySide pushback WEST;
                };
                if ([EAST, RESISTANCE] call BIS_fnc_sideIsEnemy) then {
                    _enemySide pushback EAST;
                };
            };
            default {
                _enemySide = [EAST];
            };
        };
        {
            private _enemy = _x;
            _enemy = [_enemy] call ALIVE_fnc_sideObjectToNumber;
            _enemy = [_enemy] call ALIVE_fnc_sideNumberToText;
            {
                if !(_x in _enemyFactions) then {
                    _enemyFactions pushback _x;
                };
            } foreach (_enemy call ALiVE_fnc_getSideFactions);
            // diag_log format["FRIEND %1",_friendlySide];
            // diag_log format["ENEMY %1",_enemy];
        } foreach _enemySide;
    } foreach _faction;

};

{
    private _configPath = _x; // Military_Pacific

    for "_i" from 0 to ((count _configPath) - 1) do
    {

        private _item = _configPath select _i; // airports

        if (isClass _item && (count _cat == 0 || ({tolower(configName _item) find tolower(_x) != -1} count _cat > 0))) then {

            if (count _size == 0  || ({tolower(configName _item) find tolower(_x) != -1} count _size > 0)) then { // airportslarge

                for "_i" from 0 to ((count _item) - 1) do
                {
                    private _comp = _item select _i;
                    // diag_log str(_comp);
                    if (isClass _comp) then {
                        // diag_log _enemyFactions;
                        if ({(configName _comp) find _x != -1} count _enemyFactions == 0 ||  count _faction == 0  ) then {
                            if ({(configName _comp) find _x != -1} count _searchString > 0 ||  count _searchString == 0  ) then {
                                _result pushback _comp;
                            };
                        };
                    };
                };
            };
        };
    };
} foreach _configPaths;


if (count _result == 0 && !_recursive) then {
    private _temp = "Urban";
    if (!isNil "ALiVE_mapCompositionType") then {
        // If we can't find any compositions for the current environment i.e. desert/woodland then check urban for any size composition
        _temp = ALiVE_mapCompositionType;
        ALiVE_mapCompositionType = nil;
    };
    // Another attempt at getting a composition (might not fit environment)
    _result = [_comp,_cat,[],_faction, true] call ALiVE_fnc_getCompositions;

    if (_temp != "Urban") then {
        // Set the env back to what it was for other composition searches
        ALiVE_mapCompositionType = _temp;
    };
};

// ["Found %1 compositions for %2", count _result, _this] call ALiVE_fnc_dump;

_result
