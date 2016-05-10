#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(checkStaticDataMapping);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_checkStaticDataMapping

Description:
Checks a faction for compatibility

Parameters:
Config - config file

Returns:

Examples:
(begin example)
// inspect config class
["rhs_faction_usarmy_wd"] call ALIVE_fnc_checkStaticDataMapping;

// inspect all factions
_factions = configfile >> "CfgFactionClasses";
for "_i" from 0 to count _factions -1 do {

    _faction = _factions select _i;
    if(isClass _faction) then {
        _configName = configName _faction;
        _side = getNumber(_faction >> "side");
        if(_side < 3) then {
            [configName (_factions select _i)] call ALIVE_fnc_checkStaticDataMapping;
        };
    };
}
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

_faction = _this select 0;


[_faction] spawn {

    _faction = _this select 0;

    player setCaptive true;
    player enableFatigue false;
    player addEventHandler ["HandleDamage", {(_this select 2) / 100}];


    [""] call ALIVE_fnc_dump;
    [""] call ALIVE_fnc_dump;
    _text = " ----------------------------------------------------------------------------------------------------------- ";
    [_text] call ALIVE_fnc_dump;
    [""] call ALIVE_fnc_dump;
    [""] call ALIVE_fnc_dump;
    _text = " ----------- Faction Static Data Mapping ----------- ";
    [_text] call ALIVE_fnc_dump;
    ["Checking static data mapping for faction: %1",_faction] call ALIVE_fnc_dump;




    private ["_config","_factionOK","_displayName","_side","_sideToText","_spawnPosition"];

    _config = configfile >> "CfgFactionClasses" >> _faction;
    _factionOK = false;

    if(count _config > 0) then {
        _displayName = [_config >> "displayName"] call ALiVE_fnc_getConfigValue;
        _side = [_config >> "side"] call ALiVE_fnc_getConfigValue;
        _sideToText = [_side] call ALIVE_fnc_sideNumberToText;
        ["faction found in CfgFactionClasses. Display: %2 Side: %3",_faction,_displayName,_sideToText] call ALIVE_fnc_dump;

        _factionOK = true;
    }else{
        ["faction %1 not found in CfgFactionClasses..",_faction] call ALIVE_fnc_dump;
    };


    if!(_factionOK) exitWith {};




    private ["_factionCustomMappings","_factionCustomDefaultSupports","_factionCustomDefaultTransports","_factionCustomDefaultAirTransports","_spawnPosition","_spawner","_factionVehicles","_vehicleClasses","_side","_faction","_spawnPosition","_vehicleClass","_configName","_vehicleCrew","_profiles"];

    _spawnPosition = (getPosATL player) getPos [10, 0];
    _factionSide = [_side] call ALIVE_fnc_sideNumberToText;

    _factionCustomMappings = [ALIVE_factionCustomMappings, _faction] call ALIVE_fnc_hashGet;

    if!(isNil "_factionCustomMappings") then {

        ["Static Mappings for faction : %1",_faction] call ALIVE_fnc_dump;
        _factionCustomMappings call ALIVE_fnc_inspectHash;

    };



    _factionCustomDefaultSupports = [ALIVE_factionDefaultSupports, _faction] call ALIVE_fnc_hashGet;

    if!(isNil "_factionCustomDefaultSupports") then {

        ["Static Default Supports for faction : %1",_faction] call ALIVE_fnc_dump;
        _factionCustomDefaultSupports call ALIVE_fnc_inspectArray;

        {

            _configName = _x;

            ["-- Name: %1",_configName] call ALIVE_fnc_dump;

            _title = "<t size='1' color='#68a7b7' shadow='1'>Support Vehicle</t><br/>";
            _text = format["%1<t>%2</t><br/>",_title,_configName];

            ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
            ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;


            sleep 1;

            _profiles = [_configName,_factionSide,_faction,"CAPTAIN",_spawnPosition,0,false] call ALIVE_fnc_createProfilesCrewedVehicle;

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

        } forEach _factionCustomDefaultSupports;

    };




    _factionCustomDefaultTransports = [ALIVE_factionDefaultTransport, _faction] call ALIVE_fnc_hashGet;

    if!(isNil "_factionCustomDefaultTransports") then {

        ["Static Default Transports for faction : %1",_faction] call ALIVE_fnc_dump;
        _factionCustomDefaultTransports call ALIVE_fnc_inspectArray;

        {

            _configName = _x;

            ["-- Name: %1",_configName] call ALIVE_fnc_dump;

            _title = "<t size='1' color='#68a7b7' shadow='1'>Transport Vehicle</t><br/>";
            _text = format["%1<t>%2</t><br/>",_title,_configName];

            ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
            ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;


            sleep 1;

            _profiles = [_configName,_factionSide,_faction,"CAPTAIN",_spawnPosition,0,false] call ALIVE_fnc_createProfilesCrewedVehicle;

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

        } forEach _factionCustomDefaultTransports;

    };




    _factionCustomDefaultAirTransports = [ALIVE_factionDefaultAirTransport, _faction] call ALIVE_fnc_hashGet;

    if!(isNil "_factionCustomDefaultAirTransports") then {

        ["Static Default Air Transports for faction : %1",_faction] call ALIVE_fnc_dump;
        _factionCustomDefaultAirTransports call ALIVE_fnc_inspectArray;

        {

            _configName = _x;

            ["-- Name: %1",_configName] call ALIVE_fnc_dump;

            _title = "<t size='1' color='#68a7b7' shadow='1'>Air Transport Vehicle</t><br/>";
            _text = format["%1<t>%2</t><br/>",_title,_configName];

            ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
            ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;


            sleep 1;

            _profiles = [_configName,_factionSide,_faction,"CAPTAIN",_spawnPosition,0,false] call ALIVE_fnc_createProfilesCrewedVehicle;

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

        } forEach _factionCustomDefaultAirTransports;

    };


    sleep 2;


    _title = "<t size='1' color='#68a7b7' shadow='1'>FACTION DONE!</t><br/>";
    _text = format["%1<t>%2</t><br/>",_title,_faction];

    ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
    ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;

};