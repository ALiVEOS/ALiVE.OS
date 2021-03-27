//#define DEBUG_MODE_FULL
#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(PR);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PR
Description:
Player Resupply

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
[_logic, "debug", true] call ALiVE_fnc_PR;

See Also:
- <ALIVE_fnc_PRnit>

Author:
ARJay

Peer Reviewed:
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_PR
#define MTEMPLATE "ALiVE_PR_%1"
#define DEFAULT_PR_ITEM "LaserDesignator"
#define DEFAULT_RESTRICTION_TYPE "SIDE"
#define DEFAULT_RESTRICTION_BLACKLIST []
#define DEFAULT_RESTRICTION_WHITELIST []
#define DEFAULT_SELECTED_INDEX 0
#define DEFAULT_SELECTED_VALUE ""
#define DEFAULT_SELECTED_OPTIONS []
#define DEFAULT_SELECTED_VALUES []
#define DEFAULT_SELECTED_DEPTH 0
#define DEFAULT_SORTED_VEHICLES []
#define DEFAULT_SORTED_GROUPS []
#define DEFAULT_STATE "INIT"
#define DEFAULT_SIDE "WEST"
#define DEFAULT_FACTION "BLU_F"
#define DEFAULT_FACTIONS []
#define DEFAULT_MARKER []
#define DEFAULT_DESTINATION_MARKER []
#define DEFAULT_DESTINATION []
#define DEFAULT_SCALAR 0
#define DEFAULT_COUNT_AIR []
#define DEFAULT_COUNT_INSERT []
#define DEFAULT_COUNT_CONVOY []
#define DEFAULT_PAYLOAD_READY false
#define DEFAULT_REQUEST_STATUS []

// Display components
#define PRTablet_CTRL_MainDisplay 60001
#define PRTablet_CTRL_Map 60002
#define PRTablet_CTRL_ButtonRequest 60003
#define PRTablet_CTRL_DeliveryList 60005
#define PRTablet_CTRL_SupplyList 60006
#define PRTablet_CTRL_ReinforceList 60007
#define PRTablet_CTRL_PayloadList 60008
#define PRTablet_CTRL_PayloadInfo 60009
#define PRTablet_CTRL_PayloadDelete 60010
#define PRTablet_CTRL_PayloadOptions 60011
#define PRTablet_CTRL_PayloadWeight 60012
#define PRTablet_CTRL_PayloadSize 60023
#define PRTablet_CTRL_PayloadGroups 60013
#define PRTablet_CTRL_PayloadVehicles 60014
#define PRTablet_CTRL_PayloadIndividuals 60015
#define PRTablet_CTRL_PayloadStatus 60016
#define PRTablet_CTRL_DeliveryTypeTitle 60017
#define PRTablet_CTRL_SupplyListTitle 60018
#define PRTablet_CTRL_ReinforceListTitle 60019
#define PRTablet_CTRL_PayloadListTitle 60020
#define PRTablet_CTRL_StatusTitle 60021
#define PRTablet_CTRL_StatusText 60022
#define PRTablet_CTRL_StatusList 60024
#define PRTablet_CTRL_ButtonStatus 60025
#define PRTablet_CTRL_ButtonL1 60026
#define PRTablet_CTRL_ButtonR1 60027
#define PRTablet_CTRL_StatusMap 60028
#define PRTablet_CTRL_ForcePool 60099

// Control Macros
#define PR_getControl(disp,ctrl) ((findDisplay ##disp) displayCtrl ##ctrl)
#define PR_getSelData(ctrl) (lbData[##ctrl,(lbCurSel ##ctrl)])


private ["_logic","_operation","_args","_result"];

TRACE_1("PR - input",_this);

_logic = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
_result = true;

switch(_operation) do {
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
    case "destroy": {
        if (isServer) then {
            // if server
            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];

            [_logic, "destroy"] call SUPERCLASS;
        };
    };

    case "pr_item": {
        _result = [_logic,_operation,_args,DEFAULT_PR_ITEM] call ALIVE_fnc_OOsimpleOperation;
    };
    case "pr_restrictionType": {
        _result = [_logic,_operation,_args,DEFAULT_RESTRICTION_TYPE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "pr_restrictionDeliveryAirDrop": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["pr_restrictionDeliveryAirDrop", _args];
        } else {
            _args = _logic getVariable ["pr_restrictionDeliveryAirDrop", true];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["pr_restrictionDeliveryAirDrop", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "pr_restrictionDeliveryInsert": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["pr_restrictionDeliveryInsert", _args];
        } else {
            _args = _logic getVariable ["pr_restrictionDeliveryInsert", true];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["pr_restrictionDeliveryInsert", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "pr_restrictionDeliveryConvoy": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["pr_restrictionDeliveryConvoy", _args];
        } else {
            _args = _logic getVariable ["pr_restrictionDeliveryConvoy", true];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["pr_restrictionDeliveryConvoy", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "pr_audio": {
        _result = [_logic,_operation,_args,true] call ALIVE_fnc_OOsimpleOperation;
    };
    case "countsAir": {
        _result = [_logic,_operation,_args,DEFAULT_COUNT_AIR] call ALIVE_fnc_OOsimpleOperation;
    };
    case "countsInsert": {
        _result = [_logic,_operation,_args,DEFAULT_COUNT_INSERT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "countsConvoy": {
        _result = [_logic,_operation,_args,DEFAULT_COUNT_CONVOY] call ALIVE_fnc_OOsimpleOperation;
    };
    case "currentWeight": {
        _result = [_logic,_operation,_args,DEFAULT_SCALAR] call ALIVE_fnc_OOsimpleOperation;
    };
    case "currentGroups": {
        _result = [_logic,_operation,_args,DEFAULT_SCALAR] call ALIVE_fnc_OOsimpleOperation;
    };
    case "currentVehicles": {
        _result = [_logic,_operation,_args,DEFAULT_SCALAR] call ALIVE_fnc_OOsimpleOperation;
    };
    case "currentIndividuals": {
        _result = [_logic,_operation,_args,DEFAULT_SCALAR] call ALIVE_fnc_OOsimpleOperation;
    };

    case "state": {
        _result = [_logic,_operation,_args,DEFAULT_STATE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "side": {
        _result = [_logic,_operation,_args,DEFAULT_SIDE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "faction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;
    };

    case "deliveryListOptions": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_OPTIONS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "deliveryListValues": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUES] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedDeliveryListIndex": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_INDEX] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedDeliveryListValue": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUE] call ALIVE_fnc_OOsimpleOperation;
    };

    case "selectedSupplyListOptions": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_OPTIONS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedSupplyListValues": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUES] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedSupplyListDepth": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_DEPTH] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedSupplyListIndex": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_INDEX] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedSupplyListValue": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedSupplyListParents": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUES] call ALIVE_fnc_OOsimpleOperation;
    };

    case "selectedReinforceListOptions": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_OPTIONS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedReinforceListValues": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUES] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedReinforceListDepth": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_DEPTH] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedReinforceListIndex": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_INDEX] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedReinforceListValue": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "selectedReinforceListParents": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUES] call ALIVE_fnc_OOsimpleOperation;
    };

    case "payloadListOptions": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_OPTIONS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "payloadListValues": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUES] call ALIVE_fnc_OOsimpleOperation;
    };
    case "payloadListIndex": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_INDEX] call ALIVE_fnc_OOsimpleOperation;
    };
    case "payloadListValue": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUE] call ALIVE_fnc_OOsimpleOperation;
    };

    case "payloadComboOptions": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_OPTIONS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "payloadComboValues": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUES] call ALIVE_fnc_OOsimpleOperation;
    };
    case "payloadComboIndex": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_INDEX] call ALIVE_fnc_OOsimpleOperation;
    };
    case "payloadComboValue": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUE] call ALIVE_fnc_OOsimpleOperation;
    };

    case "sortedVehicles": {
        _result = [_logic,_operation,_args,DEFAULT_SORTED_VEHICLES] call ALIVE_fnc_OOsimpleOperation;
    };
    case "sortedGroups": {
        _result = [_logic,_operation,_args,DEFAULT_SORTED_GROUPS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "marker": {
        _result = [_logic,_operation,_args,DEFAULT_MARKER] call ALIVE_fnc_OOsimpleOperation;
    };
    case "destinationMarker": {
        _result = [_logic,_operation,_args,DEFAULT_DESTINATION_MARKER] call ALIVE_fnc_OOsimpleOperation;
    };
    case "destination": {
        _result = [_logic,_operation,_args,DEFAULT_DESTINATION] call ALIVE_fnc_OOsimpleOperation;
    };
    case "payloadReady": {
        _result = [_logic,_operation,_args,DEFAULT_PAYLOAD_READY] call ALIVE_fnc_OOsimpleOperation;
    };
    case "requestStatus": {
        _result = [_logic,_operation,_args,DEFAULT_REQUEST_STATUS] call ALIVE_fnc_OOsimpleOperation;
    };

    case "statusListOptions": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_OPTIONS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "statusListValues": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUES] call ALIVE_fnc_OOsimpleOperation;
    };
    case "statusListIndex": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_INDEX] call ALIVE_fnc_OOsimpleOperation;
    };
    case "statusListValue": {
        _result = [_logic,_operation,_args,DEFAULT_SELECTED_VALUE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "statusMarker": {
        _result = [_logic,_operation,_args,DEFAULT_MARKER] call ALIVE_fnc_OOsimpleOperation;
    };

    case "factions": {
        if !(isnil "_args") then {
            if(typeName _args == "STRING") then {
                if !(_args == "") then {
                    _args = [_args, " ", ""] call CBA_fnc_replace;
                    _args = [_args, "[", ""] call CBA_fnc_replace;
                    _args = [_args, "]", ""] call CBA_fnc_replace;
                    _args = [_args, "'", ""] call CBA_fnc_replace;
                    _args = [_args, """", ""] call CBA_fnc_replace;
                    _args = [_args, ","] call CBA_fnc_split;

                    if(count _args > 0) then {
                        _logic setVariable [_operation, _args];
                    };
                } else {
                    _logic setVariable [_operation, []];
                };
            } else {
                if(typeName _args == "ARRAY") then {
                    _logic setVariable [_operation, _args];
                };
            };
        };

        _args = _logic getVariable [_operation, DEFAULT_FACTIONS];

        _result = _args;
    };

    case "blacklist": {
        if !(isnil "_args") then {
            if(typeName _args == "STRING") then {
                if !(_args == "") then {
                    _args = [_args, " ", ""] call CBA_fnc_replace;
                    _args = [_args, "[", ""] call CBA_fnc_replace;
                    _args = [_args, "]", ""] call CBA_fnc_replace;
                    _args = [_args, "'", ""] call CBA_fnc_replace;
                    _args = [_args, """", ""] call CBA_fnc_replace;
                    _args = [_args, ","] call CBA_fnc_split;

                    if(count _args > 0) then {
                        _logic setVariable [_operation, _args];
                    };
                } else {
                    _logic setVariable [_operation, []];
                };
            } else {
                if(typeName _args == "ARRAY") then {
                    _logic setVariable [_operation, _args];
                };
            };
        };

        _args = _logic getVariable [_operation, DEFAULT_RESTRICTION_BLACKLIST];

        _result = _args;
    };

    case "whitelist": {
        if !(isnil "_args") then {
            if(typeName _args == "STRING") then {
                if !(_args == "") then {
                    _args = [_args, " ", ""] call CBA_fnc_replace;
                    _args = [_args, "[", ""] call CBA_fnc_replace;
                    _args = [_args, "]", ""] call CBA_fnc_replace;
                    _args = [_args, "'", ""] call CBA_fnc_replace;
                    _args = [_args, """", ""] call CBA_fnc_replace;
                    _args = [_args, ","] call CBA_fnc_split;

                    if(count _args > 0) then {
                        _logic setVariable [_operation, _args];
                    };
                } else {
                    _logic setVariable [_operation, []];
                };
            } else {
                if(typeName _args == "ARRAY") then {
                    _logic setVariable [_operation, _args];
                };
            };
        };

        _args = _logic getVariable [_operation, DEFAULT_RESTRICTION_WHITELIST];

        _result = _args;
    };

    case "init": {

        //Only one init per instance is allowed
        if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SUP RESUPPLY - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

        //Start init
        _logic setVariable ["initGlobal", false];

        _logic setVariable ["super", SUPERCLASS];
        _logic setVariable ["class", MAINCLASS];
        _logic setVariable ["moduleType", "ALIVE_PR"];
        _logic setVariable ["startupComplete", false];

        ALIVE_SUP_PLAYER_RESUPPLY = _logic;

        // load static data
        call ALiVE_fnc_staticDataHandler;

        // Set faction whitelist
        ALIVE_PR_FACTIONLIST = [_logic, "factions", _logic getVariable ["pr_factionWhitelist", DEFAULT_FACTIONS]] call MAINCLASS;

        // Set final blacklist
        ALiVE_PR_BLACKLIST = ([_logic, "blacklist", _logic getVariable ["pr_restrictionBlacklist", DEFAULT_RESTRICTION_BLACKLIST]] call MAINCLASS) + ALiVE_PR_BLACKLIST + ALiVE_PLACEMENT_VEHICLEBLACKLIST;

        // Set final whitelist
        ALiVE_PR_WHITELIST = ([_logic, "whitelist", _logic getVariable ["pr_restrictionWhitelist", DEFAULT_RESTRICTION_WHITELIST]] call MAINCLASS) + ALiVE_PR_WHITELIST;

        // Get on with it
        [_logic, "start"] call MAINCLASS;

        // The machine has an interface? Must be a MP client, SP client or a client that acts as host!
        if (hasInterface) then {

            _logic setVariable ["startupComplete", true];

            // set the player side

            private ["_playerSide","_sideNumber","_sideText","_playerFaction"];

            waitUntil {
                sleep 0.1;
                ((str side player) != "UNKNOWN")
            };

            _playerSide = side player;
            _sideNumber = [_playerSide] call ALIVE_fnc_sideObjectToNumber;
            _sideText = [_sideNumber] call ALIVE_fnc_sideNumberToText;

            if(_sideText == "CIV") then {
                _playerFaction = faction player;
                _playerSide = _playerFaction call ALiVE_fnc_factionSide;
                _sideNumber = [_playerSide] call ALIVE_fnc_sideObjectToNumber;
                _sideText = [_sideNumber] call ALIVE_fnc_sideNumberToText;
            };

            [_logic,"side",_sideText] call MAINCLASS;

            // set the player faction

            private ["_playerFaction"];

            _playerFaction = faction player;

            if (count ALIVE_PR_FACTIONLIST == 0) then {
                ALIVE_PR_FACTIONLIST pushback _playerFaction;
            };

            [_logic,"faction",_playerFaction] call MAINCLASS;

            // get the restriction type

            private ["_restrictionType","_restrictionTypeAirDrop","_restrictionTypeHeliInsert","_restrictionTypeConvoy"];

            _restrictionTypeAirDrop = _logic getVariable ["pr_restrictionDeliveryAirDrop",true];
            _restrictionTypeHeliInsert = _logic getVariable ["pr_restrictionDeliveryInsert",true];
            _restrictionTypeConvoy = _logic getVariable ["pr_restrictionDeliveryConvoy",true];

            if (typeName _restrictionTypeAirDrop == "STRING") then {
                    if(_restrictionTypeAirDrop == "true") then {_restrictionTypeAirDrop = true;} else {_restrictionTypeAirDrop = false;};
                    _logic setVariable ["pr_restrictionDeliveryAirDrop", _restrictionTypeAirDrop];
            };

            if (typeName _restrictionTypeHeliInsert == "STRING") then {
                    if(_restrictionTypeHeliInsert == "true") then {_restrictionTypeHeliInsert = true;} else {_restrictionTypeHeliInsert = false;};
                    _logic setVariable ["pr_restrictionDeliveryInsert", _restrictionTypeHeliInsert];
            };

            if (typeName _restrictionTypeConvoy == "STRING") then {
                    if(_restrictionTypeConvoy == "true") then {_restrictionTypeConvoy = true;} else {_restrictionTypeConvoy = false;};
                    _logic setVariable ["pr_restrictionDeliveryConvoy", _restrictionTypeConvoy];
            };

            _restrictionType = _logic getVariable ["pr_restrictionType","SIDE"];

            // set the counts

            private ["_countAir","_countInsert","_countConvoy","_heliLiftCapacity","_heliLiftClasses"];

            // Works out maximum helicopter load (anywhere from 2000 to 12000 kg)
            _heliLiftCapacity = 2000;
            _heliLiftClasses = [ALIVE_factionDefaultAirTransport,_playerFaction, [ALIVE_sideDefaultAirTransport,_sideText] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashGet;

            if (count _heliLiftClasses > 0) then {
                {
                    private ["_capacity","_slingloadmax","_maxLoad"];
                    _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;
                    if (!isNil "_slingloadmax") then {
                        _maxLoad = [(configFile >> "CfgVehicles" >> _x >> "maximumLoad")] call ALiVE_fnc_getConfigValue;
                        if (_slingloadmax > _maxLoad) then {_capacity = _slingloadmax;} else {_capacity = _maxLoad;};
                        if (_capacity > _heliLiftCapacity) then {_heliLiftCapacity = _capacity;};
                    };
                } foreach _heliLiftClasses;
            };

             // Weight, Groups, Vehicles, Individuals, Size
            _countInsert =  [_heliLiftCapacity,2,2,8,80];
            _countAir =     [18000,5,5,8,100]; // Parachute can drop ~18,000kg
            _countConvoy =  [10000,5,5,8,200]; // HEMTT can carry 10 tons = ~10,000kg

            [_logic,"countsAir",_countAir] call MAINCLASS;
            [_logic,"countsInsert",_countInsert] call MAINCLASS;
            [_logic,"countsConvoy",_countConvoy] call MAINCLASS;


            // set the delivery type list options

            private ["_deliveryListOptions","_deliveryListValues"];

            _deliveryListOptions = [];
            _deliveryListValues = [];

            if(_restrictionTypeAirDrop) then {
                _deliveryListOptions pushback ("Airlift: Air drop by transport plane");
                _deliveryListValues pushback "PR_AIRDROP";
            };

            if(_restrictionTypeHeliInsert) then {
                _deliveryListOptions pushback ("Airlift: Air insertion via helicopter or VTOL");
                _deliveryListValues pushback "PR_HELI_INSERT";
            };

            if(_restrictionTypeConvoy) then {
                _deliveryListOptions pushback ("Convoy: Resupply via road transport vehicles");
                _deliveryListValues pushback "PR_STANDARD";
            };

            if(count _deliveryListOptions == 0) then {
                ["There are no delivery methods allowed, enable one or more delivery methods on the Player Combat Logistics module!"] call ALIVE_fnc_dumpR;
                _deliveryListOptions pushback ("Convoy: Resupply via road transport vehicles");
                _deliveryListValues pushback "PR_STANDARD";
            };

            [_logic,"deliveryListOptions",_deliveryListOptions] call MAINCLASS;

            // set the delivery list values
            [_logic,"deliveryListValues",_deliveryListValues] call MAINCLASS;


            // set the supply list options

            private ["_supplyListOptions","_supplyListValues","_selectedSupplyListOptions","_selectedSupplyListValues"];

            _supplyListOptions = ["Vehicles","Defence Stores","Combat Supplies"];
            _supplyListValues = ["Vehicles","Defence","Combat"];

            _selectedSupplyListOptions = [_logic,"selectedSupplyListOptions"] call MAINCLASS;
            _selectedSupplyListOptions pushback _supplyListOptions;
            [_logic,"selectedSupplyListOptions",_selectedSupplyListOptions] call MAINCLASS;

            // set the supply list values
            _selectedSupplyListValues = [_logic,"selectedSupplyListValues"] call MAINCLASS;
            _selectedSupplyListValues pushback _supplyListOptions;
            [_logic,"selectedSupplyListValues",_selectedSupplyListValues] call MAINCLASS;


            // set the reinforcement list options

            private ["_reinforceListOptions","_selectedReinforceListOptions","_selectedReinforceListValues"];

            _reinforceListOptions = ["Individuals","Groups"];

            _selectedReinforceListOptions = [_logic,"selectedReinforceListOptions"] call MAINCLASS;
            _selectedReinforceListOptions pushback _reinforceListOptions;
            [_logic,"selectedReinforceListOptions",_selectedReinforceListOptions] call MAINCLASS;

            // set the reinforcement list values
            _selectedReinforceListValues = [_logic,"selectedReinforceListValues"] call MAINCLASS;
            _selectedReinforceListValues pushback _reinforceListOptions;
            [_logic,"selectedReinforceListValues",_selectedReinforceListValues] call MAINCLASS;



            // set the payload combo options

            private ["_payloadComboOptions","_payloadComboValues"];

            _payloadComboOptions = ["Join Player Group","Static Defence","Reinforce"];
            _payloadComboValues = ["Join","Static","Reinforce"];

            [_logic,"payloadComboOptions",_payloadComboOptions] call MAINCLASS;

            // set the payload combo values
            [_logic,"payloadComboValues",_payloadComboValues] call MAINCLASS;


            private ["_file"];

            // load static data
            call ALiVE_fnc_staticDataHandler;

            private _sortedVehicles = [] call ALiVE_fnc_hashCreate;
            private _sortedGroups = [] call ALiVE_fnc_hashCreate;

            // Check to see if there's a faction whitelist
            private _pr_faction_whitelist = [_logic, "factions", _logic getVariable ["pr_factionWhitelist", DEFAULT_FACTIONS]] call MAINCLASS;
            private _civ = count _pr_faction_whitelist == 0;

            // get sorted config data
            if(_restrictionType == "SIDE") then {
                _sortedVehicles = [_sideText,ALiVE_PR_BLACKLIST,ALiVE_PR_WHITELIST] call ALIVE_fnc_sortCFGVehiclesByClass;
            }else{
                {
                    private _tempVehicles = [_x,ALiVE_PR_BLACKLIST,ALiVE_PR_WHITELIST, _civ] call ALIVE_fnc_sortCFGVehiclesByFactionClass;
                    private _mergeHash = {
                        private _listOfVeh = [_sortedVehicles, _key, []] call ALiVE_fnc_hashGet;
                        {
                            private _item = _x;
                            _listOfVeh pushbackUnique _item;
                        } foreach _Value;
                        [_sortedVehicles,_key,_listOfVeh] call ALIVE_fnc_hashSet;
                    };
                    [_tempVehicles, _mergeHash] call CBA_fnc_hashEachPair;
                } foreach ALIVE_PR_FACTIONLIST;
            };

            [_logic,"sortedVehicles",_sortedVehicles] call MAINCLASS;


            // get sorted group data
            if(_restrictionType == "SIDE") then {
                _sortedGroups = [_sideText] call ALIVE_fnc_sortCFGGroupsBySide;
            }else{
                {
                    private _tempGroups = [_sideText, _x] call ALIVE_fnc_sortCFGGroupsByFaction;
                    private _factionGroups = [_tempGroups, _x] call ALiVE_fnc_hashGet;
                    [_sortedGroups, _x, _factionGroups] call ALiVE_fnc_hashSet;
                } foreach ALIVE_PR_FACTIONLIST;
            };

            [_logic,"sortedGroups",_sortedGroups] call MAINCLASS;

            _audio = [_logic,"pr_audio"] call MAINCLASS;

            // Create HQ Audio source
            if (_audio) then {
                private _hqClass = "HQ";
                private _identity = "EPC_B_BHQ";
                switch (_playerSide) do {
                    case EAST: {
                        _hqClass = "OPF";
                        _identity = "Male01PER";
                    };
                    case RESISTANCE: {
                        _hqClass = "IND";
                        _identity = "Male01GRE";
                    };
                    default {
                        _identity = "EPC_B_BHQ";
                        _hqClass = "HQ";
                    };
                };
                private _HQ = getText(configFile >> "CfgHQIdentities" >> _hqClass >> "name");
                ALIVE_PR_HQ = (createGroup _playerSide) createUnit ["Logic", [10,10,1000], [], 0, "NONE"];
                ALIVE_PR_HQ setGroupId [_HQ];
                ALIVE_PR_HQ setIdentity _identity;
                ALIVE_PR_HQ kbAddtopic["ALIVE_PR_protocol", "a3\modules_f\supports\kb\protocol.bikb"];

            };

            // Initialise interaction key if undefined
            if (isNil "SELF_INTERACTION_KEY") then {SELF_INTERACTION_KEY = [221,[false,false,false]];};

            TRACE_2("Menu pre-req",SELF_INTERACTION_KEY,ALIVE_fnc_logisticsMenuDef);

            // Initialise main menu
            [
                    "player",
                    [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                    -9500,
                    [
                            "call ALIVE_fnc_PRMenuDef",
                            ["main", "alive_flexiMenu_rscPopup"]
                    ]
            ] call CBA_fnc_flexiMenu_Add;

        };
    };
    case "start": {

        // set module as startup complete
        _logic setVariable ["startupComplete", true];

        if(isServer) then {

            waituntil {!(isnil "ALIVE_profileSystemInit")};

            // start listening for logcom events
            [_logic,"listen"] call MAINCLASS;

        };

    };
    case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["LOGCOM_RESPONSE","LOGCOM_STATUS_RESPONSE"]]] call ALIVE_fnc_eventLog;
        _logic setVariable ["listenerID", _listenerID];
    };
    case "handleEvent": {

        private["_event","_eventData"];

        if(typeName _args == "ARRAY") then {

            _event = _args;

            // a response event from LOGCOM has been received.
            // if the we are a dedicated server,
            // dispatch the event to the player who requested it
            if((isServer && isMultiplayer) || isDedicated) then {

                private ["_eventData","_playerID","_player"];

                _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

                _playerID = _eventData select 1;

                _player = objNull;
                {
                    if (getPlayerUID _x == _playerID) exitWith {
                        _player = _x;
                    };
                } forEach playableUnits;

                if !(isNull _player) then {
                    [_event,"ALIVE_fnc_PRTabletEventToClient",_player,false,false] spawn BIS_fnc_MP;
                };

            }else{

                // the player is the server

                [_logic, "handleLOGCOMResponse", _event] call MAINCLASS;

            };

        };
    };
    case "handleLOGCOMResponse": {

        // event handler for LOGOM_RESPONSE
        // events

        private["_event","_eventData","_message","_requestID","_side","_sideObject","_selectedDeliveryValue",
        "_radioMessage","_radioBroadcast","_markers","_audio"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
            _message = [_event, "message"] call ALIVE_fnc_hashGet;

            _requestID = _eventData select 0;

            _side = [_logic,"side"] call MAINCLASS;
            _sideObject = [_side] call ALIVE_fnc_sideTextToObject;
            _selectedDeliveryValue = [_logic,"selectedDeliveryListValue"] call MAINCLASS;

            _audio = [_logic,"pr_audio"] call MAINCLASS;

            private _HQ = switch (_sideObject) do {
                case WEST: {
                    "BLU"
                };
                case EAST: {
                    "OPF"
                };
                case RESISTANCE: {
                    "IND"
                };
                default {
                    "HQ"
                };
            };

            _radioMessage = "";

            if (_audio) then {
                player kbAddtopic["ALIVE_PR_protocol", "a3\modules_f\supports\kb\protocol.bikb"];
            };

            switch(_message) do {
                case "ACKNOWLEDGED":{

                    // LOGCOM has received and accepted the request
                    if (_audio) then {

                        ALIVE_PR_HQ kbTell [player, "ALIVE_PR_protocol", "Drop_Acknowledged", "GROUP"];

                    } else {

                        _radioMessage = "Request acknowledged, stand by";

                        _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                        [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;
                    };


                };
                case "REQUEST_INSERTION":{

                    // LOGCOM has selected insertion point for request

                    switch(_selectedDeliveryValue) do {
                        case "PR_AIRDROP": {
                            _radioMessage = "Cargo lift in flight to requested destination";
                        };
                        case "PR_HELI_INSERT": {
                            _radioMessage = "Rotary wing units have been loaded with requested payload";
                        };
                        case "PR_STANDARD": {
                            _radioMessage = "Convoy units have been loaded with requested payload";
                        };
                    };

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;


                };
                case "REQUEST_ENROUTE":{

                    // LOGCOM request has arrived at destination point

                    switch(_selectedDeliveryValue) do {
                        case "PR_HELI_INSERT": {
                            _radioMessage = "Rotary wing units are on way to destination";
                        };
                        case "PR_STANDARD": {
                            _radioMessage = "Convoy units are on way to destination";
                        };
                    };

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;


                };
                case "REQUEST_ARRIVED":{

                    // LOGCOM request has arrived at destination point

                    switch(_selectedDeliveryValue) do {
                        case "PR_HELI_INSERT": {
                            _radioMessage = "Rotary wing units have arrived at the destination. Commencing unloading";
                        };
                        case "PR_STANDARD": {
                            _radioMessage = "Convoy units have arrived at the destination. Commencing unloading";
                        };
                    };

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;


                };
                case "REQUEST_DELIVERED":{

                    // LOGCOM has delivered the request

                    private ["_position","_isWaiting","_marker","_markers","_markerLabel"];

                    _position = _eventData select 2;
                    _isWaiting = _eventData select 3;
                    _markerLabel = "";

                    if (_audio) then {

                        ALIVE_PR_HQ kbTell [player, "ALIVE_PR_protocol", "Drop_Accomplished", "GROUP"];

                    };

                    switch(_selectedDeliveryValue) do {
                        case "PR_AIRDROP": {
                            _radioMessage = "Airdrop request completed";
                            _markerLabel = "Airdrop destination";
                        };
                        case "PR_HELI_INSERT": {
                            _radioMessage = "Rotary wing insertion request completed";
                            _markerLabel = "Heli Insert destination";
                        };
                        case "PR_STANDARD": {
                            _radioMessage = "Convoy request completed";
                            _markerLabel = "Convoy destination";
                        };
                    };

                    if(_isWaiting) then {
                        _radioMessage = format["%1, Payload transport vehicle is RTB.",_radioMessage];
                    };

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;


                    // clear request markers

                    _markers = [_logic,"marker"] call MAINCLASS;

                    if(count _markers > 0) then {
                        deleteMarkerLocal (_markers select 0);
                    };

                    [_logic,"marker",[]] call MAINCLASS;

                    // display destination markers

                    if(count _position > 0) then {

                        _markers = [];

                        _marker = createMarkerLocal ["PR_DESTINATION_M1", _position];
                        _marker setMarkerShapeLocal "Icon";
                        _marker setMarkerSizeLocal [0.75, 0.75];
                        _marker setMarkerTypeLocal "mil_dot";
                        _marker setMarkerColorLocal "ColorYellow";
                        _marker setMarkerTextLocal _markerLabel;
                        _markers pushback _marker;

                        _marker = createMarkerLocal ["PR_DESTINATION_M2", _position];
                        _marker setMarkerShape "Ellipse";
                        _marker setMarkerSize [150, 150];
                        _marker setMarkerColor "ColorYellow";
                        _marker setMarkerAlpha 0.5;
                        _markers pushback _marker;

                        [_logic,"destinationMarker",_markers] call MAINCLASS;

                    };

                    // set the tablet state to reset

                    [_logic,"state","RESET"] call MAINCLASS;

                    // delete destination markers after 3 minutes

                    [_logic,_position] spawn {

                        params ["_logic","_position"];

                        //Needs investigation: REQUEST_DELIVERED is called twice for some reason. Thats why those markers are not being deleted.
                        //Workaround: reduced from 180 to 30.
                        sleep 30;

                        private _markers = [_logic,"destinationMarker"] call MAINCLASS;

                        {
                                deleteMarker _x;
                        } foreach _markers;
                    };

                };
                case "REQUEST_LOST":{

                    // LOGCOM has lost the request enroute

                    switch(_selectedDeliveryValue) do {
                        case "PR_HELI_INSERT": {

                            if (_audio) then {

                                ALIVE_PR_HQ kbTell [player, "ALIVE_PR_protocol", "Drop_Destroyed", "GROUP"];

                            };

                            _radioMessage = "Rotary wing units have been destroyed enroute to destination";
                        };
                        case "PR_STANDARD": {
                            _radioMessage = "Convoy units have been destroyed enroute to destination";
                        };
                    };

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

                    // clear request markers

                    _markers = [_logic,"marker"] call MAINCLASS;

                    if(count _markers > 0) then {
                        deleteMarkerLocal (_markers select 0);
                    };

                    [_logic,"marker",[]] call MAINCLASS;

                    // set the tablet state to reset

                    [_logic,"state","RESET"] call MAINCLASS;


                };
                case "DENIED_FORCEPOOL":{

                    // LOGCOM has denied the request due to insufficient forces

                    _radioMessage = "Your request for support has been denied. Insufficient resources available";

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

                    // clear request markers

                    _markers = [_logic,"marker"] call MAINCLASS;

                    if(count _markers > 0) then {
                        deleteMarkerLocal (_markers select 0);
                    };

                    [_logic,"marker",[]] call MAINCLASS;

                    // set the tablet state to reset

                    [_logic,"state","RESET"] call MAINCLASS;

                };
                case "DENIED_NOT_AVAILABLE":{

                    // LOGCOM has no insertion point to deliver from

                    _radioMessage = "Your request for support has been denied. No insertion point is available";

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

                    // clear request markers

                    _markers = [_logic,"marker"] call MAINCLASS;

                    if(count _markers > 0) then {
                        deleteMarkerLocal (_markers select 0);
                    };

                    [_logic,"marker",[]] call MAINCLASS;

                    // set the tablet state to reset

                    [_logic,"state","RESET"] call MAINCLASS;

                };
                case "DENIED_FORCE_CREATION":{

                    // LOGCOM has denied the request because the force pool did not result in any profiles created

                    _radioMessage = "Your request for support has been denied. The forces requested are not available";

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

                    // clear request markers

                    _markers = [_logic,"marker"] call MAINCLASS;

                    if(count _markers > 0) then {
                        deleteMarkerLocal (_markers select 0);
                    };

                    [_logic,"marker",[]] call MAINCLASS;

                    // set the tablet state to reset

                    [_logic,"state","RESET"] call MAINCLASS;

                };
                case "DENIED_WAITING_INIT":{

                    // LOGCOM has denied the request because the force pool did not result in any profiles created

                    _radioMessage = "Your request for support has been denied. LOGCOM is still setting up.";

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

                    // clear request markers

                    _markers = [_logic,"marker"] call MAINCLASS;

                    if(count _markers > 0) then {
                        deleteMarkerLocal (_markers select 0);
                    };

                    [_logic,"marker",[]] call MAINCLASS;

                    // set the tablet state to reset

                    [_logic,"state","RESET"] call MAINCLASS;

                };
                case "DENIED_FACTION_HANDLER_NOT_FOUND":{

                    // LOGCOM has denied the request because no mil logistics modules for this faction have been found

                    _radioMessage = "Your request for support has been denied. No military logistics supply chain found for your players faction.";

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

                    // clear request markers

                    _markers = [_logic,"marker"] call MAINCLASS;

                    if(count _markers > 0) then {
                        deleteMarkerLocal (_markers select 0);
                    };

                    [_logic,"marker",[]] call MAINCLASS;

                    // set the tablet state to reset

                    [_logic,"state","RESET"] call MAINCLASS;

                };
                case "STATUS":{

                    // LOGCOM has responded with the current request status

                    disableSerialization;

                    [_logic,"statusListOptions",[]] call MAINCLASS;
                    [_logic,"statusListValues",[]] call MAINCLASS;
                    [_logic,"statusListIndex",DEFAULT_SELECTED_INDEX] call MAINCLASS;
                    [_logic,"statusListValue",DEFAULT_SELECTED_VALUE] call MAINCLASS;

                    private ["_payloadStatusList","_payloadRequests","_options","_values","_payloadRequest","_payloadState",
                    "_stateLabel","_rowData","_payloadID","_payloadPositions","_payloadDistance","_payloadType","_typeLabel"];

                    _payloadStatusList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusList);
                    _payloadStatusList ctrlShow true;

                    lbClear _payloadStatusList;

                    _payloadRequests = _eventData select 2;
                    _options = [];
                    _values = [];

                    {

                        _payloadRequest = _x;
                        _payloadType = _payloadRequest select 0;
                        _payloadID = _payloadRequest select 1;
                        _payloadState = _payloadRequest select 2;
                        _payloadPositions = _payloadRequest select 3;

                        _typeLabel = '';

                        switch(_payloadType) do {
                            case 'PR_STANDARD':{
                                _typeLabel = 'Convoy Request';
                            };
                            case 'PR_HELI_INSERT':{
                                _typeLabel = 'Heli Insert Request';
                            };
                            case 'PR_AIRDROP':{
                                _typeLabel = 'Airdrop Request';
                            };
                        };

                        _payloadID = format["ID: %1",_payloadID];

                        _payloadDistance = 'Unknown';

                        if(count _payloadPositions > 0) then {
                            _payloadDistance = player distance (_payloadPositions select 0);
                            _payloadDistance = format["%1m",_payloadDistance];
                        };

                        _stateLabel = '';

                        switch(_payloadState) do {
                            case 'playerRequested':{
                                _stateLabel = 'Requested';
                            };
                            case 'transportLoad':{
                                _stateLabel = 'Loading';
                            };
                            case 'transportLoadWait':{
                                _stateLabel = 'Loading';
                            };
                            case 'transportStart':{
                                _stateLabel = 'Loading';
                            };
                            case 'transportTravel':{
                                _stateLabel = 'Enroute';
                            };
                            case 'transportComplete':{
                                _stateLabel = 'Enroute';
                            };
                            case 'transportUnloadWait':{
                                _stateLabel = 'Unloading';
                            };
                            case 'transportReturn':{
                                _stateLabel = 'RTB';
                            };
                            case 'transportReturnWait':{
                                _stateLabel = 'RTB';
                            };
                            case 'airdropWait':{
                                _stateLabel = 'Loading';
                            };
                            case 'heliTransportStart':{
                                _stateLabel = 'Loading';
                            };
                            case 'heliTransport':{
                                _stateLabel = 'Enroute';
                            };
                            case 'heliTransportUnloadWait':{
                                _stateLabel = 'Unloading';
                            };
                            case 'heliTransportComplete':{
                                _stateLabel = 'Complete';
                            };
                            case 'heliTransportReturn':{
                                _stateLabel = 'RTB';
                            };
                            case 'heliTransportReturnWait':{
                                _stateLabel = 'RTB';
                            };
                            case 'eventComplete':{
                                _stateLabel = 'Complete';
                            };
                        };

                        _rowData = [];

                        _options pushBack _payloadRequest;

                        _values pushBack _payloadID;

                        _rowData pushBack format['%1 %2 %3 %4', _payloadID, _typeLabel, _stateLabel, _payloadDistance];

                        _payloadStatusList lnbAddRow _rowData;

                    } foreach _payloadRequests;

                    [_logic,"statusListOptions",_options] call MAINCLASS;
                    [_logic,"statusListValues",_values] call MAINCLASS;

                    _payloadStatusList ctrlSetEventHandler ["LBSelChanged", "['STATUS_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                };
                case "CANCEL_FAILED":{

                    // LOGCOM has denied the request because no mil logistics modules for this faction have been found

                    _radioMessage = "Your request to cancel has been denied. Requested units cannot RTB at this time.";

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

                    // clear request markers

                    _markers = [_logic,"marker"] call MAINCLASS;

                    if(count _markers > 0) then {
                        deleteMarkerLocal (_markers select 0);
                    };

                    [_logic,"marker",[]] call MAINCLASS;

                    // set the tablet state to reset

                    [_logic,"state","RESET"] call MAINCLASS;

                };
                case "CANCEL_OK":{

                    // LOGCOM has denied the request because no mil logistics modules for this faction have been found

                    _radioMessage = "Your request for support has been cancelled.";

                    _radioBroadcast = [player,_radioMessage,"side",_sideObject,false,true,false,true,_HQ];

                    [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

                    // clear request markers

                    _markers = [_logic,"marker"] call MAINCLASS;

                    if(count _markers > 0) then {
                        deleteMarkerLocal (_markers select 0);
                    };

                    [_logic,"marker",[]] call MAINCLASS;

                    // set the tablet state to reset

                    [_logic,"state","RESET"] call MAINCLASS;

                };
            };

        };

    };
    case "tabletOnLoad": {

        // on load of the tablet
        // restore state

        if (hasInterface) then {

            [_logic] spawn {

                private ["_logic","_state"];

                _logic = _this select 0;

                sleep 0.5;

                disableSerialization;

                _state = [_logic,"state"] call MAINCLASS;

                switch(_state) do {

                    case "INIT":{

                        // the interface is opened
                        // for the first time

                        [_logic,"showInit"] call MAINCLASS;

                    };

                    case "REQUEST":{

                        // a request is in progress
                        // but not yet sent
                        // restore the values of the request

                        [_logic,"showRequest"] call MAINCLASS;

                    };

                    case "REQUEST_SENT":{

                        // request has been sent
                        // display the status interface

                        [_logic,"resetRequest"] call MAINCLASS;

                    };
                    case "RESET":{

                        // the tablet has just made a request
                        // and the request has been completed
                        // reset the request interface objects

                        [_logic,"resetRequest"] call MAINCLASS;

                    };
                };

                // Hide GPS
                showGPS false;

            };

        };

    };
    case "tabletOnUnLoad": {

        // The machine has an interface? Must be a MP client, SP client or a client that acts as host!
        if (hasInterface) then {

            // clear markers

            private _markers = [_logic,"marker"] call MAINCLASS;
            {deleteMarker _x} foreach _markers;

            _markers = [_logic,"statusMarker"] call MAINCLASS;
            {deleteMarker _x} foreach _markers;

            _markers = [_logic,"destinationMarker"] call MAINCLASS;
            {deleteMarker _x} foreach _markers;

            // Show GPS
            showGPS true;

        };

    };
    case "tabletOnAction": {

        // The machine has an interface? Must be a MP client, SP client or a client that acts as host!
        if (hasInterface) then {

            if (isnil "_args") exitwith {};

            private ["_action"];

            _action = _args select 0;
            _args = _args select 1;

            switch(_action) do {

                case "OPEN": {

                    switch (MOD(TABLET_MODEL)) do {
                        case "Tablet01": {
                            createDialog "PRTablet";
                        };

                        case "Mapbag01": {
                            createDialog "PRTablet";

                            private _ctrlBackground = ((findDisplay 60001) displayCtrl 60000);
                            _ctrlBackground ctrlsettext "x\alive\addons\main\data\ui\ALiVE_mapbag.paa";
                            _ctrlBackground ctrlSetPosition [
                                0.15 * safezoneW + safezoneX,
                                -0.242 * safezoneH + safezoneY,
                                0.72 * safezoneW,
                                1.372 * safezoneH
                            ];
                            _ctrlBackground ctrlCommit 0;
                        };

                        default {
                            createDialog "PRTablet";
                        };
                    };

                    // Display Current Force Pool

                    private _forcePoolStatus = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ForcePool);
                    _forcePoolStatus ctrlsettext "WAITING...";

                    [nil,"getForcePool", [player, faction player]] remoteExecCall [QUOTE(MAINCLASS),2];

                };

                case "DELIVERY_LIST_SELECT": {

                    // user selects on of the delivery type options
                    // the selection will determine what options
                    // are available

                    private ["_deliveryList","_selectedIndex","_deliveryListOptions","_deliveryListValues","_selectedOption","_selectedValue"];

                    _deliveryList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _deliveryListOptions = [_logic,"deliveryListOptions"] call MAINCLASS;
                    _deliveryListValues = [_logic,"deliveryListValues"] call MAINCLASS;
                    _selectedOption = _deliveryListOptions select _selectedIndex;
                    _selectedValue = _deliveryListValues select _selectedIndex;

                    // set the state as request in progress
                    // store the selected values for later

                    [_logic,"state","REQUEST"] call MAINCLASS;
                    [_logic,"selectedDeliveryListIndex",_selectedIndex] call MAINCLASS;
                    [_logic,"selectedDeliveryListValue",_selectedValue] call MAINCLASS;

                    // set the counts

                    private ["_sizeText","_weightText","_groupText","_vehiclesText","_individualsText","_counts","_countWeight","_countSize","_countGroups","_countVehicles","_countIndividuals"];

                    _weightText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadWeight);
                    _sizeText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadSize);
                    _groupText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadGroups);
                    _vehiclesText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadVehicles);
                    _individualsText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadIndividuals);

                    switch(_selectedValue) do {
                        case "PR_AIRDROP": {
                            _counts = [_logic,"countsAir"] call MAINCLASS;
                        };
                        case "PR_HELI_INSERT": {
                            _counts = [_logic,"countsInsert"] call MAINCLASS;
                        };
                        case "PR_STANDARD": {
                            _counts = [_logic,"countsConvoy"] call MAINCLASS;
                        };
                    };

                    _countWeight = _counts select 0;
                    _countGroups = _counts select 1;
                    _countVehicles = _counts select 2;
                    _countIndividuals = _counts select 3;
                    _countSize = _counts select 4;

                    _sizeText ctrlSetText format["%1 of %2 size",0,_countSize];
                    _weightText ctrlSetText format["%1 of %2 weight",0,_countWeight];
                    _groupText ctrlSetText format["%1 of %2 groups",0,_countGroups];
                    _vehiclesText ctrlSetText format["%1 of %2 vehicles",0,_countVehicles];
                    _individualsText ctrlSetText format["%1 of %2 individuals",0,_countIndividuals];

                    // reset the supply list

                    private ["_supplyList","_selectedSupplyListOptions","_selectedSupplyListValues","_selectedSupplyListDepth"];

                    _supplyList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_SupplyList);

                    _selectedSupplyListOptions = [_logic,"selectedSupplyListOptions"] call MAINCLASS;
                    _selectedSupplyListValues = [_logic,"selectedSupplyListValues"] call MAINCLASS;
                    _selectedSupplyListDepth = [_logic,"selectedSupplyListDepth"] call MAINCLASS;

                    lbClear _supplyList;

                    {
                        _supplyList lbAdd format["%1", _x];
                    } forEach (_selectedSupplyListOptions select 0);

                    _supplyList ctrlSetEventHandler ["LBSelChanged", "['SUPPLY_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                    [_logic,"selectedSupplyListDepth",0] call MAINCLASS;

                    // reset the reinforce list

                    private ["_reinforceList","_selectedReinforceListOptions","_selectedReinforceListValues","_selectedReinforceListDepth"];

                    _reinforceList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ReinforceList);

                    _selectedReinforceListOptions = [_logic,"selectedReinforceListOptions"] call MAINCLASS;
                    _selectedReinforceListValues = [_logic,"selectedReinforceListValues"] call MAINCLASS;
                    _selectedReinforceListDepth = [_logic,"selectedReinforceListDepth"] call MAINCLASS;

                    lbClear _reinforceList;

                    {
                        _reinforceList lbAdd format["%1", _x];
                    } forEach (_selectedReinforceListOptions select 0);

                    _reinforceList ctrlSetEventHandler ["LBSelChanged", "['REINFORCE_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                    [_logic,"selectedReinforceListDepth",0] call MAINCLASS;

                    // reset the payload list

                    private ["_payloadListOptions","_payloadListValues","_payloadList"];

                    _payloadList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadList);
                    _payloadListOptions = [_logic,"payloadListOptions"] call MAINCLASS;
                    _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;

                    _payloadListOptions = [];
                    _payloadListValues = [];

                    [_logic,"payloadListOptions",_payloadListOptions] call MAINCLASS;
                    [_logic,"payloadListValues",_payloadListValues] call MAINCLASS;

                    lbClear _payloadList;

                    _payloadList ctrlSetEventHandler ["LBSelChanged", "['PAYLOAD_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                    // reset the map

                    private ["_map","_markers"];

                    _map = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_Map);

                    _map ctrlSetEventHandler ["MouseButtonDown", "['MAP_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                    _markers = [_logic,"marker"] call MAINCLASS;

                    if(count _markers > 0) then {
                        deleteMarkerLocal (_markers select 0);
                    };

                    // enable send button

                    private ["_payloadRequestButton"];

                    _payloadRequestButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonRequest);
                    _payloadRequestButton ctrlShow true;
                    _payloadRequestButton ctrlSetEventHandler ["MouseButtonClick", "['PAYLOAD_REQUEST_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                };

                case "SUPPLY_LIST_SELECT": {

                    // supply list select
                    // the user selects an option from the list

                    private ["_supplyList","_selectedIndex","_selectedDeliveryValue","_selectedSupplyListOptions","_selectedSupplyListValues","_selectedSupplyListDepth",
                    "_selectedSupplyListParents","_selectedListOptions","_selectedListValues","_selectedOption","_selectedValue","_sortedVehicles",
                    "_updateList","_options","_values","_vehicleClasses","_displayName","_faction","_side"];

                    _supplyList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _selectedDeliveryValue = [_logic,"selectedDeliveryListValue"] call MAINCLASS;
                    _selectedSupplyListOptions = [_logic,"selectedSupplyListOptions"] call MAINCLASS;
                    _selectedSupplyListValues = [_logic,"selectedSupplyListValues"] call MAINCLASS;
                    _selectedSupplyListDepth = [_logic,"selectedSupplyListDepth"] call MAINCLASS;
                    _selectedSupplyListParents = [_logic,"selectedSupplyListParents"] call MAINCLASS;
                    _selectedListOptions = _selectedSupplyListOptions select _selectedSupplyListDepth;
                    _selectedListValues = _selectedSupplyListValues select _selectedSupplyListDepth;
                    _selectedOption = _selectedListOptions select _selectedIndex;
                    _selectedValue = _selectedListValues select _selectedIndex;
                    _sortedVehicles = [_logic,"sortedVehicles"] call MAINCLASS;
                    _faction = [_logic,"faction"] call MAINCLASS;
                    _side = [_logic,"side"] call MAINCLASS;

                    _updateList = false;

                    _selectedSupplyListParents set [_selectedSupplyListDepth,_selectedValue];
                    [_logic,"selectedSupplyListParents",_selectedSupplyListParents] call MAINCLASS;

                    if(_selectedValue == "<< Back") then {

                        // go back a level

                        _selectedSupplyListDepth = _selectedSupplyListDepth - 1;

                        [_logic,"selectedSupplyListDepth",_selectedSupplyListDepth] call MAINCLASS;

                        _options = _selectedSupplyListOptions select _selectedSupplyListDepth;
                        _values = _selectedSupplyListValues select _selectedSupplyListDepth;

                        lbClear _supplyList;

                        {
                            _supplyList lbAdd format["%1", _x];
                        } forEach _options;

                    }else{

                        switch(_selectedSupplyListDepth) do {
                            case 0: {

                                // selected something from the top level
                                // get vehicle categories for the selected
                                // top level option

                                _updateList = true;

                                switch(_selectedValue) do {
                                    case "Vehicles": {

                                        private ["_staticOptions"];

                                        // attempt to get options by faction
                                        _staticOptions = [ALIVE_factionDefaultResupplyVehicleOptions,_faction,[]] call ALIVE_fnc_hashGet;

                                        // if no options found for the faction use side options
                                        if(count _staticOptions == 0) then {
                                            _staticOptions = [ALIVE_sideDefaultResupplyVehicleOptions,_side] call ALIVE_fnc_hashGet;
                                        };

                                        _staticOptions = [_staticOptions,_selectedDeliveryValue] call ALIVE_fnc_hashGet;

                                        _options = _staticOptions select 0;
                                        _values = _staticOptions select 1;

                                        /*
                                        switch(_selectedDeliveryValue) do {
                                            case "PR_AIRDROP": {
                                                _options = ["<< Back","Car","Ship"];
                                                _values = ["<< Back","Car","Ship"];
                                            };
                                            case "PR_HELI_INSERT": {
                                                _options = ["<< Back","Air"];
                                                _values = ["<< Back","Air"];
                                            };
                                            case "PR_STANDARD": {
                                                _options = ["<< Back","Car","Armored","Support"];
                                                _values = ["<< Back","Car","Armored","Support"];
                                            };
                                        };
                                        */

                                        _selectedSupplyListOptions set [1,_options];
                                        _selectedSupplyListValues set [1,_values];
                                    };
                                    case "Defence Stores": {

                                        private ["_staticOptions"];

                                        // attempt to get options by faction
                                        _staticOptions = [ALIVE_factionDefaultResupplyDefenceStoreOptions,_faction,[]] call ALIVE_fnc_hashGet;

                                        // if no options found for the faction use side options
                                        if(count _staticOptions == 0) then {
                                            _staticOptions = [ALIVE_sideDefaultResupplyDefenceStoreOptions,_side] call ALIVE_fnc_hashGet;
                                        };

                                        _staticOptions = [_staticOptions,_selectedDeliveryValue] call ALIVE_fnc_hashGet;

                                        _options = _staticOptions select 0;
                                        _values = _staticOptions select 1;

                                        /*
                                        _options = ["<< Back","Static","Fortifications","Tents","Military"];
                                        _values = ["<< Back","Static","Fortifications","Tents","Structures_Military"];
                                        */

                                        _selectedSupplyListOptions set [1,_options];
                                        _selectedSupplyListValues set [1,_values];
                                    };
                                    case "Combat Supplies": {

                                        private ["_staticOptions"];

                                        // attempt to get options by faction
                                        _staticOptions = [ALIVE_factionDefaultResupplyCombatSuppliesOptions,_faction,[]] call ALIVE_fnc_hashGet;

                                        // if no options found for the faction use side options
                                        if(count _staticOptions == 0) then {
                                            _staticOptions = [ALIVE_sideDefaultResupplyCombatSuppliesOptions,_side] call ALIVE_fnc_hashGet;
                                        };

                                        _staticOptions = [_staticOptions,_selectedDeliveryValue] call ALIVE_fnc_hashGet;

                                        _options = _staticOptions select 0;
                                        _values = _staticOptions select 1;

                                        /*
                                        _options = ["<< Back","Ammo"];
                                        _values = ["<< Back","Ammo"];
                                        */

                                        _selectedSupplyListOptions set [1,_options];
                                        _selectedSupplyListValues set [1,_values];
                                    };
                                };

                            };
                            case 1: {

                                // selected something from the second level
                                // get vehicle classes for the selected category

                                _updateList = true;

                                _options = ["<< Back"];
                                _values = ["<< Back"];

                                _vehicleClasses = [_sortedVehicles,_selectedValue] call ALIVE_fnc_hashGet;

                                private ["_deliveryType","_maxWeight","_counts"];

                                _deliveryType = [_logic,"selectedDeliveryListValue"] call MAINCLASS;

                                switch(_deliveryType) do {
                                    case "PR_AIRDROP": {
                                        _counts = [_logic,"countsAir"] call MAINCLASS;
                                    };
                                    case "PR_HELI_INSERT": {
                                        _counts = [_logic,"countsInsert"] call MAINCLASS;
                                    };
                                    case "PR_STANDARD": {
                                        _counts = [_logic,"countsConvoy"] call MAINCLASS;
                                    };
                                };

                                _maxWeight = _counts select 0;

                                {
                                    private ["_slingable"];

                                    _displayName = getText(configFile >> "CfgVehicles" >> _x >> "displayname");

                                    // Make sure item is not too heavy to transport based on delivery type
                                    if (_deliveryType == "PR_HELI_INSERT" || _deliveryType == "PR_AIRDROP") then {

                                        _slingable = count ([(configFile >> "CfgVehicles" >> _x >> "slingLoadCargoMemoryPoints")] call ALiVE_fnc_getConfigValue) > 0;

                                        If (!_slingable && _deliveryType == "PR_HELI_INSERT" && (_selectedValue == "Car" || _selectedValue == "Ship")) then {
                                            // Don't display
                                        } else {
                                            if ([_x] call ALIVE_fnc_getObjectWeight < _maxWeight) then {
                                                _options pushback _displayName;
                                                _values pushback _x;
                                            };
                                        };

                                    } else {

                                        if (_deliveryType == "PR_STANDARD") then {
                                            _options pushback _displayName;
                                            _values pushback _x;
                                        };
                                    };

                                } forEach _vehicleClasses;

                                _selectedSupplyListOptions set [2,_options];
                                _selectedSupplyListValues set [2,_values];

                            };
                            case 2: {

                                private ["_payloadListOptions","_payloadListValues","_payloadList","_selectedParents"];

                                // selected something from the third level
                                // a vehicle has been selected..

                                _payloadListOptions = [_logic,"payloadListOptions"] call MAINCLASS;
                                _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;

                                _selectedParents = [];
                                {
                                    _selectedParents pushback _x;
                                } forEach _selectedSupplyListParents;

                                _payloadListOptions pushback _selectedOption;
                                _payloadListValues pushback [_selectedValue,_selectedParents];

                                [_logic,"payloadListOptions",_payloadListOptions] call MAINCLASS;
                                [_logic,"payloadListValues",_payloadListValues] call MAINCLASS;

                                _payloadList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadList);

                                private _index = _payloadList lbAdd format["%1", _selectedOption];
                                _payLoadList lbSetTooltip [_index, _selectedValue];

                                [_logic,"payloadUpdated"] call MAINCLASS;

                            };
                        };

                        if(_updateList) then {

                            // update the list options based
                            // on the last selection

                            _selectedSupplyListDepth = _selectedSupplyListDepth + 1;

                            [_logic,"selectedSupplyListDepth",_selectedSupplyListDepth] call MAINCLASS;
                            [_logic,"selectedSupplyListOptions",_selectedSupplyListOptions] call MAINCLASS;
                            [_logic,"selectedSupplyListValues",_selectedSupplyListValues] call MAINCLASS;

                            _options = _selectedSupplyListOptions select _selectedSupplyListDepth;
                            _values = _selectedSupplyListValues select _selectedSupplyListDepth;

                            lbClear _supplyList;

                            {
                                private _index = _supplyList lbAdd format["%1", _x];

                                if (_selectedSupplyListDepth == 2 && _index > 0) then {
                                    private _vehicleClasses = [_sortedVehicles, _selectedValue] call ALIVE_fnc_hashGet;
                                    _supplyList lbSetTooltip [_index, format ["%1", _vehicleClasses select (_index - 1)]];
                                };
                            } forEach _options;

                        };

                    };

                };

                case "REINFORCE_LIST_SELECT": {

                    // reinforce list select
                    // the user selects an option from the list

                    private ["_reinforceList","_selectedIndex","_selectedDeliveryValue","_selectedReinforceListOptions","_selectedReinforceListValues","_selectedReinforceListDepth",
                    "_selectedReinforceListParents","_selectedListOptions","_selectedListValues","_selectedOption","_selectedValue","_sortedVehicles","_sortedGroups",
                    "_updateList","_options","_values","_vehicleClasses","_displayName","_factions","_categories","_groups","_blacklistOptions","_faction","_side"];

                    _reinforceList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _selectedDeliveryValue = [_logic,"selectedDeliveryListValue"] call MAINCLASS;
                    _selectedReinforceListOptions = [_logic,"selectedReinforceListOptions"] call MAINCLASS;
                    _selectedReinforceListValues = [_logic,"selectedReinforceListValues"] call MAINCLASS;
                    _selectedReinforceListDepth = [_logic,"selectedReinforceListDepth"] call MAINCLASS;
                    _selectedReinforceListParents = [_logic,"selectedReinforceListParents"] call MAINCLASS;
                    _selectedListOptions = _selectedReinforceListOptions select _selectedReinforceListDepth;
                    _selectedListValues = _selectedReinforceListValues select _selectedReinforceListDepth;
                    _selectedOption = _selectedListOptions select _selectedIndex;
                    _selectedValue = _selectedListValues select _selectedIndex;
                    _sortedVehicles = [_logic,"sortedVehicles"] call MAINCLASS;
                    _sortedGroups = [_logic,"sortedGroups"] call MAINCLASS;
                    _faction = [_logic,"faction"] call MAINCLASS;
                    _side = [_logic,"side"] call MAINCLASS;

                    _updateList = false;

                    _selectedReinforceListParents set [_selectedReinforceListDepth,_selectedValue];
                    [_logic,"selectedReinforceListParents",_selectedReinforceListParents] call MAINCLASS;

                    if(_selectedValue == "<< Back") then {

                        // go back a level

                        _selectedReinforceListDepth = _selectedReinforceListDepth - 1;

                        [_logic,"selectedReinforceListDepth",_selectedReinforceListDepth] call MAINCLASS;

                        _options = _selectedReinforceListOptions select _selectedReinforceListDepth;
                        _values = _selectedReinforceListValues select _selectedReinforceListDepth;

                        lbClear _reinforceList;

                        {
                            _reinforceList lbAdd format["%1", _x];
                        } forEach _options;

                    }else{

                        switch(_selectedReinforceListDepth) do {
                            case 0: {

                                // selected something from the top level
                                // get vehicle categories for the selected
                                // top level option

                                _updateList = true;

                                switch(_selectedValue) do {
                                    case "Individuals": {

                                        private ["_staticOptions"];

                                        // attempt to get options by faction
                                        _staticOptions = [ALIVE_factionDefaultResupplyIndividualOptions,_faction,[]] call ALIVE_fnc_hashGet;

                                        // if no options found for the faction use side options
                                        if(count _staticOptions == 0) then {
                                            _staticOptions = [ALIVE_sideDefaultResupplyIndividualOptions,_side] call ALIVE_fnc_hashGet;
                                        };

                                        _staticOptions = [_staticOptions,_selectedDeliveryValue] call ALIVE_fnc_hashGet;

                                        _options = _staticOptions select 0;
                                        _values = _staticOptions select 1;

                                        /*
                                        switch(_selectedDeliveryValue) do {
                                            case "PR_AIRDROP": {
                                                _options = ["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"];
                                                _values = ["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"];
                                            };
                                            case "PR_HELI_INSERT": {
                                                _options = ["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"];
                                                _values = ["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"];
                                            };
                                            case "PR_STANDARD": {
                                                _options = ["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"];
                                                _values = ["<< Back","Men","MenDiver","MenRecon","MenSniper","MenSupport"];
                                            };
                                        };
                                        */

                                        _selectedReinforceListOptions set [1,_options];
                                        _selectedReinforceListValues set [1,_values];
                                    };
                                    case "Groups": {

                                        _options = ["<< Back"];
                                        _factions = _sortedGroups select 1;
                                        _options = _options + _factions;

                                        _selectedReinforceListOptions set [1,_options];
                                        _selectedReinforceListValues set [1,_options];

                                    };
                                };

                            };
                            case 1: {

                                _updateList = true;

                                if(_selectedReinforceListParents select 0 == "Groups") then {

                                    // selected a group faction
                                    // display categories

                                    _options = ["<< Back"];
                                    _categories = [_sortedGroups,_selectedValue] call ALIVE_fnc_hashGet;
                                    _categories = _categories select 1;
                                    _options = _options + _categories;

                                    private ["_staticOptions"];

                                    // STATIC OPTIONS ARE BLACKLIST OPTIONS

                                    // attempt to get options by faction
                                    _staticOptions = [ALIVE_factionDefaultResupplyGroupOptions,_faction,[]] call ALIVE_fnc_hashGet;

                                    // if no options found for the faction use side options
                                    if(count _staticOptions == 0) then {
                                        _staticOptions = [ALIVE_sideDefaultResupplyGroupOptions,_side] call ALIVE_fnc_hashGet;
                                    };

                                    _blacklistOptions = [_staticOptions,_selectedDeliveryValue] call ALIVE_fnc_hashGet;

                                    /*
                                    switch(_selectedDeliveryValue) do {
                                        case "PR_AIRDROP": {
                                            _blacklistOptions = ["Armored","Support"];
                                        };
                                        case "PR_HELI_INSERT": {
                                            _blacklistOptions = ["Armored","Mechanized","Motorized","Motorized_MTP","SpecOps","Support"];
                                        };
                                        case "PR_STANDARD": {
                                            _blacklistOptions = ["Support"];
                                        };
                                    };
                                    */

                                    _options = _options - _blacklistOptions;

                                    _selectedReinforceListOptions set [2,_options];
                                    _selectedReinforceListValues set [2,_options];

                                }else{

                                    // selected something from the second level
                                    // get vehicle classes for the selected category

                                    _options = ["<< Back"];
                                    _values = ["<< Back"];

                                    _vehicleClasses = [_sortedVehicles,_selectedValue] call ALIVE_fnc_hashGet;
                                    _vehicleClasses = _vehicleClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                                    {
                                        _displayName = getText(configFile >> "CfgVehicles" >> _x >> "displayname");

                                        _options pushback _displayName;
                                        _values pushback _x;

                                    } forEach _vehicleClasses;

                                    _selectedReinforceListOptions set [2,_options];
                                    _selectedReinforceListValues set [2,_values];

                                };

                            };
                            case 2: {

                                if(_selectedReinforceListParents select 0 == "Groups") then {

                                    // selected a group category
                                    // display groups

                                    _updateList = true;

                                    _categories = [_sortedGroups,_selectedReinforceListParents select 1] call ALIVE_fnc_hashGet;
                                    _groups = [_categories,_selectedReinforceListParents select 2] call ALIVE_fnc_hashGet;

                                    _options = _groups select 2;
                                    _options = ["<< Back"] + _options;
                                    _values = _groups select 1;
                                    _values = ["<< Back"] + _values;

                                    _selectedReinforceListOptions set [3,_options];
                                    _selectedReinforceListValues set [3,_values];

                                }else{

                                    private ["_payloadListOptions","_payloadListValues","_payloadList","_selectedParents"];

                                    // selected something from the third level
                                    // a vehicle has been selected..

                                    _payloadListOptions = [_logic,"payloadListOptions"] call MAINCLASS;
                                    _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;

                                    _selectedParents = [];
                                    {
                                        _selectedParents pushback _x;
                                    } forEach _selectedReinforceListParents;

                                    _payloadListOptions pushback _selectedOption;
                                    _payloadListValues pushback [_selectedValue,_selectedParents,"Reinforce"];

                                    [_logic,"payloadListOptions",_payloadListOptions] call MAINCLASS;
                                    [_logic,"payloadListValues",_payloadListValues] call MAINCLASS;

                                    _payloadList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadList);

                                    private _index = _payloadList lbAdd format["%1", _selectedOption];
                                    _payLoadList lbSetTooltip [_index, _selectedValue];

                                    [_logic,"payloadUpdated"] call MAINCLASS;

                                };

                            };
                            case 3: {

                                private ["_payloadListOptions","_payloadListValues","_payloadList","_selectedParents"];

                                // selected something from the third level
                                // a vehicle has been selected..

                                _payloadListOptions = [_logic,"payloadListOptions"] call MAINCLASS;
                                _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;

                                _selectedParents = [];
                                {
                                    _selectedParents pushback _x;
                                } forEach _selectedReinforceListParents;

                                _payloadListOptions pushback _selectedOption;
                                _payloadListValues pushback [_selectedValue,_selectedParents,"Reinforce"];

                                [_logic,"payloadListOptions",_payloadListOptions] call MAINCLASS;
                                [_logic,"payloadListValues",_payloadListValues] call MAINCLASS;

                                _payloadList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadList);

                                private _index = _payloadList lbAdd format["%1", _selectedOption];
                                _payLoadList lbSetTooltip [_index, _selectedValue];

                                [_logic,"payloadUpdated"] call MAINCLASS;

                            };
                        };

                        if(_updateList) then {

                            // update the list options based
                            // on the last selection

                            _selectedReinforceListDepth = _selectedReinforceListDepth + 1;

                            [_logic,"selectedReinforceListDepth",_selectedReinforceListDepth] call MAINCLASS;
                            [_logic,"selectedReinforceListOptions",_selectedReinforceListOptions] call MAINCLASS;
                            [_logic,"selectedReinforceListValues",_selectedReinforceListValues] call MAINCLASS;

                            _options = _selectedReinforceListOptions select _selectedReinforceListDepth;
                            _values = _selectedReinforceListValues select _selectedReinforceListDepth;

                            lbClear _reinforceList;

                            {
                                private _index = _reinforceList lbAdd format["%1", _x];

                                if (_index > 0) then {
                                    private _tooltip = "";

                                    // Groups
                                    if (_selectedReinforceListDepth == 3) then {
                                        private _groupCategories = [_sortedGroups, _selectedReinforceListParents select 1] call ALIVE_fnc_hashGet;
                                        private _groupClasses = [_groupCategories, _selectedReinforceListParents select 2] call ALIVE_fnc_hashGet;
                                        _tooltip = (_groupClasses select 1) select (_index - 1);
                                    } else {
                                        // Individuals
                                        if (_selectedReinforceListDepth == 2 && _selectedReinforceListParents select 0 == "Individuals") then {
                                            private _vehicleClasses = [_sortedVehicles, _selectedValue] call ALIVE_fnc_hashGet;
                                            _tooltip = _vehicleClasses select (_index - 1);
                                        };
                                    };

                                    _reinforceList lbSetTooltip [_index, _tooltip];
                                };
                            } forEach _options;

                        };

                    };

                };

                case "PAYLOAD_LIST_SELECT": {

                    // user selects one of the payload items

                    private ["_payloadList","_selectedIndex","_payloadListOptions","_payloadListValues","_selectedOption","_selectedValue"];

                    _payloadList = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _payloadListOptions = [_logic,"payloadListOptions"] call MAINCLASS;
                    _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;

                    _selectedOption = _payloadListOptions select _selectedIndex;
                    _selectedValue = _payloadListValues select _selectedIndex;

                    [_logic,"payloadListIndex",_selectedIndex] call MAINCLASS;
                    [_logic,"payloadListValue",_selectedValue] call MAINCLASS;

                    // enable delete button

                    private ["_payloadDeleteButton"];

                    _payloadDeleteButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadDelete);
                    _payloadDeleteButton ctrlShow true;
                    _payloadDeleteButton ctrlSetEventHandler ["MouseButtonClick", "['PAYLOAD_DELETE_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                    // populate info text

                    private ["_payloadInfoText","_payloadInfo","_payloadOption","_payloadType","_payloadOptionsCombo","_payloadComboValues"];

                    _payloadOptionsCombo = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadOptions);
                    _payloadOptionsCombo ctrlShow false;

                    _payloadComboValues = [_logic,"payloadComboValues"] call MAINCLASS;

                    _payloadInfoText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadInfo);
                    _payloadInfo = _selectedValue select 1;
                    _payloadOption = _selectedValue select 2;
                    _payloadType = _payloadInfo select 0;

                    // [">>>>>>>>>> %1 %2 %3", _payloadInfo, _payloadOption, _payloadType] call ALiVE_fnc_dump;

                    private ["_displayName","_vehsize","_weight","_class"];

                    if (_payloadType != "Groups") then {

                        _class = _selectedValue select 0;
                        _displayName = [(configFile >> "CfgVehicles" >> _class >> "displayName")] call ALiVE_fnc_getConfigValue;
                        _vehsize = [(configFile >> "CfgVehicles" >> _class >> "mapSize")] call ALiVE_fnc_getConfigValue;
                        _weight = [_class] call ALIVE_fnc_getObjectWeight;
                        _faction = [(configFile >> "CfgVehicles" >> _class >> "faction")] call ALiVE_fnc_getConfigValue;
                        _faction = [((_faction call ALiVE_fnc_configGetFactionClass) >> "displayname")] call ALiVE_fnc_getConfigValue;
                        _side = [[[(configFile >> "CfgVehicles" >> _class >> "side")] call ALiVE_fnc_getConfigValue] call ALIVE_fnc_sideNumberToText] call ALIVE_fnc_sideTextToLong;
                    };

                    disableSerialization;

                    switch(_payloadType) do {
                        case "Vehicles":{
                            _payloadInfoText ctrlSetText format["Empty vehicle: %1, Size: %2m, Weight: %3kg", _displayName, _vehsize, _weight];
                        };
                        case "Defence Stores":{
                            _payloadInfoText ctrlSetText format["Defence Stores: %1, Size: %2m, Weight: %3kg", _displayName, _vehsize, _weight];
                        };
                        case "Combat Supplies":{
                            _payloadInfoText ctrlSetText format["Combat Supplies: %1, Size: %2m, Weight: %3kg", _displayName, _vehsize, _weight];
                        };
                        case "Individuals":{
                            _payloadInfoText ctrlSetText format["Individual Reinforcements: %1, Faction: %2, Side: %3", _displayName, _faction, _side];

                            // enable the options combo

                            _payloadOptionsCombo ctrlShow true;

                            _payloadOptionsCombo lbSetCurSel (_payloadComboValues find _payloadOption);

                        };
                        case "Groups":{
                            _payloadInfoText ctrlSetText format["Group Reinforcements:"];

                            // enable the options combo

                            _payloadOptionsCombo ctrlShow true;

                            _payloadOptionsCombo lbSetCurSel (_payloadComboValues find _payloadOption);


                        };
                    };

                };

                case "PAYLOAD_DELETE_CLICK": {

                    // delete selected option
                    // from the payload list

                    private ["_payloadDeleteButton","_payloadList","_selectedIndex","_payloadListOptions","_payloadListValues","_delete"];

                    _payloadDeleteButton = _args select 0 select 0;
                    _payloadList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadList);
                    _selectedIndex = lbCurSel _payloadList;
                    _payloadListOptions = [_logic,"payloadListOptions"] call MAINCLASS;
                    _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;

                    _payloadListOptions set [_selectedIndex,"del"];
                    _payloadListValues set [_selectedIndex,"del"];

                    _delete = ["del"];

                    _payloadListOptions = _payloadListOptions - _delete;
                    _payloadListValues = _payloadListValues - _delete;

                    [_logic,"payloadListOptions",_payloadListOptions] call MAINCLASS;
                    [_logic,"payloadListValues",_payloadListValues] call MAINCLASS;

                    _payloadList lbDelete _selectedIndex;

                    _payloadDeleteButton ctrlShow false;

                    [_logic,"payloadUpdated"] call MAINCLASS;

                };

                case "PAYLOAD_COMBO_SELECT": {

                    // a group or individuals options
                    // have been set update the values
                    // of the item

                    private ["_payloadOptionsCombo","_selectedIndex","_payloadComboOptions","_payloadComboValues","_selectedOption","_selectedValue"];

                    _payloadOptionsCombo = _args select 0 select 0;
                    _selectedIndex = _args select 0 select 1;
                    _payloadComboOptions = [_logic,"payloadComboOptions"] call MAINCLASS;
                    _payloadComboValues = [_logic,"payloadComboValues"] call MAINCLASS;

                    _selectedOption = _payloadComboOptions select _selectedIndex;
                    _selectedValue = _payloadComboValues select _selectedIndex;

                    private ["_payloadList","_selectedPayloadIndex","_payloadListOptions","_payloadListValues","_selectedPayloadItem","_selectedPayloadValue"];

                    _payloadList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadList);
                    _selectedPayloadIndex = lbCurSel _payloadList;
                    _payloadListOptions = [_logic,"payloadListOptions"] call MAINCLASS;
                    _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;

                    _selectedPayloadItem = _payloadListOptions select _selectedPayloadIndex;
                    _selectedPayloadValue = _payloadListValues select _selectedPayloadIndex;

                    _selectedPayloadValue set [2,_selectedValue];


                };

                case "MAP_CLICK": {

                    // on map click, clear existing
                    // markers, create a marker with
                    // details of the delivery type

                    private ["_button","_posX","_posY","_map","_position","_markers","_marker","_markerLabel","_selectedDeliveryValue"];

                    _button = _args select 0 select 1;
                    _posX = _args select 0 select 2;
                    _posY = _args select 0 select 3;

                    if(_button == 0) then {

                        _markers = [_logic,"marker"] call MAINCLASS;
                        _selectedDeliveryValue = [_logic,"selectedDeliveryListValue"] call MAINCLASS;

                        if(count _markers > 0) then {
                            deleteMarkerLocal (_markers select 0);
                        };

                        _map = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_Map);

                        _position = _map ctrlMapScreenToWorld [_posX, _posY];

                        ctrlMapAnimClear _map;
                        _map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _position];
                        ctrlMapAnimCommit _map;

                        switch(_selectedDeliveryValue) do {
                            case "PR_AIRDROP": {
                                _markerLabel = "Air Drop";
                            };
                            case "PR_HELI_INSERT": {
                                _markerLabel = "Heli Insert";
                            };
                            case "PR_STANDARD": {
                                _markerLabel = "Convoy";
                            };
                        };

                        _marker = createMarkerLocal [format["%1%2",MTEMPLATE,"marker"],_position];
                        _marker setMarkerAlphaLocal 1;
                        _marker setMarkerTextLocal _markerLabel;
                        _marker setMarkerTypeLocal "hd_End";

                        [_logic,"marker",[_marker]] call MAINCLASS;
                        [_logic,"destination",_position] call MAINCLASS;

                    };

                };

                case "MAP_CLICK_NULL": {

                    // map click on status
                    // do nothing

                };

                case "PAYLOAD_REQUEST_CLICK": {

                    // payload requested
                    // if the payload and map marker
                    // are correct send the event
                    // if not output warning message

                    private ["_markers","_payloadReady","_status"];

                    _markers = [_logic,"marker"] call MAINCLASS;
                    _payloadReady = [_logic,"payloadReady"] call MAINCLASS;
                    _audio = [_logic,"pr_audio"] call MAINCLASS;

                    _status = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadStatus);

                    if(count _markers > 0) then {

                        if(_payloadReady) then {

                            _status ctrlSetText "Sending payload request";
                            _status ctrlSetTextColor [0.384,0.439,0.341,1];

                            // prepare the payload

                            private ["_side","_faction","_destination","_deliveryType","_selectedDeliveryValue","_payloadListValues","_emptyVehicles",
                            "_payload","_staticIndividuals","_joinIndividuals","_reinforceIndividuals","_staticGroups","_joinGroups",
                            "_reinforceGroups","_payloadClass","_payloadInfo","_payloadType","_payloadOrders","_requestID","_forceMakeup",
                            "_event","_eventID","_playerID"];

                            _side = [_logic,"side"] call MAINCLASS;
                            _faction = [_logic,"faction"] call MAINCLASS;
                            _destination = [_logic,"destination"] call MAINCLASS;
                            _deliveryType = [_logic,"selectedDeliveryListValue"] call MAINCLASS;
                            _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;

                            _emptyVehicles = [];
                            _payload = [];
                            _staticIndividuals = [];
                            _joinIndividuals = [];
                            _reinforceIndividuals = [];
                            _staticGroups = [];
                            _joinGroups = [];
                            _reinforceGroups = [];

                            {
                                _payloadClass = _x select 0;
                                _payloadInfo = _x select 1;
                                _payloadType = _payloadInfo select 0;

                                private ["_faction","_vehicleType","_customMappings","_groups","_groupNames"];

                                _faction = _payloadInfo select 1;

                                // hacks for RHS support..
                                // ------------------------------------------------------------------------

                                if!([_faction, "rhs_"] call CBA_fnc_find == -1) then {

                                    if(_payloadType == "Vehicles") then {

                                        _vehicleType = _payloadInfo select 1;
                                        switch(_vehicleType) do {
                                            case "rhs_vehclass_car":{
                                                _payloadInfo set [1,"Car"];
                                            };
                                            case "rhs_vehclass_truck":{
                                                _payloadInfo set [1,"Car"];
                                            };
                                            case "rhs_vehclass_ifv":{
                                                _payloadInfo set [1,"Armored"];
                                            };
                                            case "rhs_vehclass_apc":{
                                                _payloadInfo set [1,"Armored"];
                                            };
                                            case "rhs_vehclass_tank":{
                                                _payloadInfo set [1,"Armored"];
                                            };
                                            case "rhs_vehclass_helicopter":{
                                                _payloadInfo set [1,"Air"];
                                            };
                                        };

                                    };

                                    if(_payloadType == "Groups") then {

                                        _customMappings = [ALIVE_factionCustomMappings, _faction] call ALIVE_fnc_hashGet;
                                        _groups = [_customMappings, "Groups"] call ALIVE_fnc_hashGet;

                                        _groups call ALIVE_fnc_inspectHash;

                                        {
                                            _groupNames = [_groups, _x] call ALIVE_fnc_hashGet;

                                            _groupNames call ALIVE_fnc_inspectArray;

                                            if(_payloadClass in _groupNames) then {
                                                _payloadInfo set [2,_x];
                                            };
                                        } forEach (_groups select 1);

                                    };

                                };

                                // end hacks for RHS support..
                                // ------------------------------------------------------------------------

                                switch(_payloadType) do {
                                    case "Vehicles":{
                                        _emptyVehicles pushback [_payloadClass,_payloadInfo];
                                    };
                                    case "Defence Stores":{
                                        _payload pushback _payloadClass;
                                    };
                                    case "Combat Supplies":{
                                        _payload pushback _payloadClass;
                                    };
                                    case "Individuals":{
                                        _payloadOrders = _x select 2;
                                        switch(_payloadOrders) do {
                                            case "Join":{
                                                _joinIndividuals pushback [_payloadClass,_payloadInfo];
                                            };
                                            case "Static":{
                                                _staticIndividuals pushback [_payloadClass,_payloadInfo];
                                            };
                                            case "Reinforce":{
                                                _reinforceIndividuals pushback [_payloadClass,_payloadInfo];
                                            };
                                        };
                                    };
                                    case "Groups":{
                                        _payloadOrders = _x select 2;
                                        switch(_payloadOrders) do {
                                            case "Join":{
                                                _joinGroups pushback [_payloadClass,_payloadInfo];
                                            };
                                            case "Static":{
                                                _staticGroups pushback [_payloadClass,_payloadInfo];
                                            };
                                            case "Reinforce":{
                                                _reinforceGroups pushback [_payloadClass,_payloadInfo];
                                            };
                                        };
                                    };
                                };

                            } forEach _payloadListValues;

                            _requestID = floor(time);

                            _forceMakeup = [_requestID,_payload,_emptyVehicles,_staticIndividuals,_joinIndividuals,_reinforceIndividuals,_staticGroups,_joinGroups,_reinforceGroups];

                            // send the event

                            _playerID = getPlayerUID player;

                            _event = ['LOGCOM_REQUEST', [_destination,_faction,_side,_forceMakeup,_deliveryType,_playerID],"PR"] call ALIVE_fnc_event;

                            if(isServer) then {
                                [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                            }else{
                                [[_event],"ALIVE_fnc_addEventToServer",false,false] spawn BIS_fnc_MP;
                            };

                            // display radio message

                            private ["_side","_sideObject","_callSignPlayer","_radioMessage","_radioBroadcast"];


                            if (_audio) then {

                                player kbTell [ALIVE_PR_HQ, "ALIVE_PR_protocol", "Drop_Request", "GROUP"];

                            } else {

                                _side = [_logic,"side"] call MAINCLASS;
                                _sideObject = [_side] call ALIVE_fnc_sideTextToObject;

                                private _HQ = switch (_sideObject) do {
                                    case WEST: {
                                        "BLU"
                                    };
                                    case EAST: {
                                        "OPF"
                                    };
                                    case RESISTANCE: {
                                        "IND"
                                    };
                                    default {
                                        "HQ"
                                    };
                                };

                                _callSignPlayer = format ["%1", group player];

                                _radioMessage = "Requesting logistics support at the supplied location";

                                _radioBroadcast = [player,_radioMessage,"side",_sideObject,true,false,true,false,_HQ];

                                [_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;
                            };

                            // Reset after a succesful request
                            [_logic,"resetRequest"] call MAINCLASS;
                        }else{
                            _status ctrlSetText "Payload refused adjust payload settings";
                            _status ctrlSetTextColor [0.729,0.216,0.235,1];
                        };

                    }else{
                        _status ctrlSetText "Select destination point on map";
                        _status ctrlSetTextColor [0.729,0.216,0.235,1];
                    };

                };

                case "SHOW_STATUS_CLICK": {

                    private ["_side","_faction","_destination","_deliveryType","_selectedDeliveryValue","_payloadListValues","_emptyVehicles",
                    "_payload","_staticIndividuals","_joinIndividuals","_reinforceIndividuals","_staticGroups","_joinGroups",
                    "_reinforceGroups","_payloadClass","_payloadInfo","_payloadType","_payloadOrders","_requestID","_forceMakeup",
                    "_event","_eventID","_playerID"];

                    _side = [_logic,"side"] call MAINCLASS;
                    _faction = [_logic,"faction"] call MAINCLASS;
                    _requestID = floor(time);
                    _playerID = getPlayerUID player;

                    _event = ['LOGCOM_STATUS_REQUEST', [_faction,_side,_requestID,_playerID],"PR"] call ALIVE_fnc_event;

                    if(isServer) then {
                        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                    }else{
                        [[_event],"ALIVE_fnc_addEventToServer",false,false] spawn BIS_fnc_MP;
                    };

                    // set the interface state

                    [_logic,"showStatus"] call MAINCLASS;

                };

                case "SHOW_REQUEST_CLICK": {

                    // set the interface state

                    [_logic,"showRequest"] call MAINCLASS;

                };

                case "STATUS_LIST_SELECT": {

                    // user selects one of the payload items

                    private ["_statusList","_statusIndex","_statusListOptions","_statusListValues","_selectedOption","_selectedValue"];

                    _statusList = _args select 0 select 0;
                    _statusIndex = _args select 0 select 1;
                    _statusListOptions = [_logic,"statusListOptions"] call MAINCLASS;
                    _statusListValues = [_logic,"statusListValues"] call MAINCLASS;

                    _selectedOption = _statusListOptions select _statusIndex;
                    _selectedValue = _statusListValues select _statusIndex;

                    [_logic,"statusListIndex",_selectedIndex] call MAINCLASS;
                    [_logic,"statusListValue",_selectedValue] call MAINCLASS;

                    // enable delete button

                    private ["_payloadType","_payloadStatusButtonL1","_payloadStatusButtonR1"];

                    _payloadType = _selectedOption select 0;

                    _payloadStatusButtonL1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonL1);
                    _payloadStatusButtonL1 ctrlSetText "Cancel Request";
                    _payloadStatusButtonL1 ctrlShow true;
                    _payloadStatusButtonL1 ctrlSetEventHandler ["MouseButtonClick", "['STATUS_CANCEL_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                    if(_payloadType == 'PR_STANDARD' || _payloadType == 'PR_HELI_INSERT') then {

                        _payloadStatusButtonR1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonR1);
                        _payloadStatusButtonR1 ctrlSetText "Show Details";
                        _payloadStatusButtonR1 ctrlShow true;
                        _payloadStatusButtonR1 ctrlSetEventHandler ["MouseButtonClick", "['STATUS_DETAILS_SHOW',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                    };

                };

                case "STATUS_CANCEL_CLICK": {

                    private ["_statusListOptions","_statusListIndex","_statusListValue","_selectedOption"];

                    _statusListOptions = [_logic,"statusListOptions"] call MAINCLASS;

                    _statusListIndex = [_logic,"statusListIndex"] call MAINCLASS;
                    _statusListValue = [_logic,"statusListValue"] call MAINCLASS;

                    _selectedOption = _statusListOptions select _statusListIndex;

                    private ["_selectedRequestID","_side","_faction","_requestID","_playerID","_event"];

                    _selectedRequestID = _selectedOption select 1;

                    _side = [_logic,"side"] call MAINCLASS;
                    _faction = [_logic,"faction"] call MAINCLASS;
                    _requestID = floor(time);
                    _playerID = getPlayerUID player;

                    _event = ['LOGCOM_CANCEL_REQUEST', [_faction,_side,_requestID,_playerID,_selectedRequestID],"PR"] call ALIVE_fnc_event;

                    if(isServer) then {
                        [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                    }else{
                        [[_event],"ALIVE_fnc_addEventToServer",false,false] spawn BIS_fnc_MP;
                    };

                };

                case "STATUS_DETAILS_SHOW": {

                    private ["_statusListOptions","_statusListIndex","_statusListValue","_selectedOption"];

                    _statusListOptions = [_logic,"statusListOptions"] call MAINCLASS;

                    _statusListIndex = [_logic,"statusListIndex"] call MAINCLASS;
                    _statusListValue = [_logic,"statusListValue"] call MAINCLASS;

                    _selectedOption = _statusListOptions select _statusListIndex;

                    private ["_positions","_payloadStatusButtonL1","_payloadStatusButtonR1","_payloadStatusMap","_markers","_marker"];

                    _positions = _selectedOption select 3;

                    _payloadStatusButtonL1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonL1);
                    _payloadStatusButtonL1 ctrlShow false;

                    _payloadStatusButtonR1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonR1);
                    _payloadStatusButtonR1 ctrlSetText "Hide Details";
                    _payloadStatusButtonR1 ctrlShow true;
                    _payloadStatusButtonR1 ctrlSetEventHandler ["MouseButtonClick", "['STATUS_DETAILS_HIDE',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                    _payloadStatusMap = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusMap);
                    _payloadStatusMap ctrlShow true;

                    if(count _positions > 0) then {

                        _position = _positions select 0;

                        ctrlMapAnimClear _payloadStatusMap;
                        _payloadStatusMap ctrlMapAnimAdd [0.5, ctrlMapScale _payloadStatusMap, _position];
                        ctrlMapAnimCommit _payloadStatusMap;

                        _markers = [];

                        _marker = createMarkerLocal ["PR_STATUS_M1", _position];
                        _marker setMarkerShapeLocal "Icon";
                        _marker setMarkerSizeLocal [0.75, 0.75];
                        _marker setMarkerTypeLocal "mil_dot";
                        _marker setMarkerColorLocal "ColorYellow";
                        _marker setMarkerTextLocal "Request Location";
                        _markers pushback _marker;

                        _marker = createMarkerLocal ["PR_STATUS_M2", _position];
                        _marker setMarkerShape "Ellipse";
                        _marker setMarkerSize [150, 150];
                        _marker setMarkerColor "ColorYellow";
                        _marker setMarkerAlpha 0.5;
                        _markers pushback _marker;

                        [_logic,"statusMarker",_markers] call MAINCLASS;

                    };

                };

                case "STATUS_DETAILS_HIDE": {

                    private ["_statusMarker","_payloadStatusButtonL1","_payloadStatusButtonR1","_payloadStatusMap"];

                    _statusMarker = [_logic,"statusMarker"] call MAINCLASS;

                    if(count _statusMarker > 0) then {
                        {
                            deleteMarkerLocal _x;
                        } foreach _statusMarker;
                    };

                    [_logic,"statusMarker",[]] call MAINCLASS;

                    _payloadStatusButtonL1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonL1);
                    _payloadStatusButtonL1 ctrlShow true;

                    _payloadStatusButtonR1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonR1);
                    _payloadStatusButtonR1 ctrlSetText "Show Details";
                    _payloadStatusButtonR1 ctrlShow true;
                    _payloadStatusButtonR1 ctrlSetEventHandler ["MouseButtonClick", "['STATUS_DETAILS_SHOW',[_this]] call ALIVE_fnc_PRTabletOnAction"];

                    _payloadStatusMap = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusMap);
                    _payloadStatusMap ctrlShow false;

                };

            };

        };

    };

    case "payloadUpdated": {

        // payload updated
        // calculate weights and
        // counts

        if (hasInterface) then {

            private ["_payloadListOptions","_payloadListValues","_selectedDeliveryValue","_currentWeight","_currentSize",
            "_currentGroups","_currentVehicles","_currentIndividuals","_payloadInfo","_payloadType","_payloadClass","_itemWeight","_itemSize"];

            _payloadListOptions = [_logic,"payloadListOptions"] call MAINCLASS;
            _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;
            _selectedDeliveryValue = [_logic,"selectedDeliveryListValue"] call MAINCLASS;

            _currentWeight = 0;
            _currentSize = 0;
            _currentGroups = 0;
            _currentVehicles = 0;
            _currentIndividuals = 0;

            {
                _payloadClass = _x select 0;
                _payloadInfo = _x select 1;
                _payloadType = _payloadInfo select 0;

                switch(_payloadType) do {
                    case "Vehicles":{
                        _currentVehicles = _currentVehicles + 1;
                    };
                    case "Defence Stores":{
                        // get object weight
                        _itemWeight = [_payloadClass] call ALIVE_fnc_getObjectWeight;
                        _currentWeight = _currentWeight + _itemWeight;

                        // get object size
                        _itemSize = [_payloadClass] call ALIVE_fnc_getObjectSize;
                        _currentSize = _currentSize + _itemSize;
                    };
                    case "Combat Supplies":{
                        // get object weight
                        _itemWeight = [_payloadClass] call ALIVE_fnc_getObjectWeight;
                        _currentWeight = _currentWeight + _itemWeight;

                        // get object size
                        _itemSize = [_payloadClass] call ALIVE_fnc_getObjectSize;
                        _currentSize = _currentSize + _itemSize;
                    };
                    case "Individuals":{
                        _currentIndividuals = _currentIndividuals + 1;
                    };
                    case "Groups":{
                        _currentGroups = _currentGroups + 1;
                    };
                };

            } forEach _payloadListValues;

            // set the counts

            private ["_weightText","_sizeText","_groupText","_vehiclesText","_individualsText","_counts","_countWeight","_countGroups",
            "_countVehicles","_countIndividuals","_countSize","_payloadReady"];

            _weightText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadWeight);
            _sizeText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadSize);
            _groupText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadGroups);
            _vehiclesText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadVehicles);
            _individualsText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadIndividuals);

            switch(_selectedDeliveryValue) do {
                case "PR_AIRDROP": {
                    _counts = [_logic,"countsAir"] call MAINCLASS;
                };
                case "PR_HELI_INSERT": {
                    _counts = [_logic,"countsInsert"] call MAINCLASS;
                };
                case "PR_STANDARD": {
                    _counts = [_logic,"countsConvoy"] call MAINCLASS;
                };
            };

            _countWeight = _counts select 0;
            _countGroups = _counts select 1;
            _countVehicles = _counts select 2;
            _countIndividuals = _counts select 3;
            _countSize = _counts select 4;

            _weightText ctrlSetText format["%1 of %2 weight",_currentWeight,_countWeight];
            _sizeText ctrlSetText format["%1 of %2 size",_currentSize,_countSize];
            _groupText ctrlSetText format["%1 of %2 groups",_currentGroups,_countGroups];
            _vehiclesText ctrlSetText format["%1 of %2 vehicles",_currentVehicles,_countVehicles];
            _individualsText ctrlSetText format["%1 of %2 individuals",_currentIndividuals,_countIndividuals];

            _payloadReady = true;

            if(_currentWeight > _countWeight) then {
                _payloadReady = false;
                _weightText ctrlSetTextColor [0.729,0.216,0.235,1];
            }else{
                _weightText ctrlSetTextColor [0.384,0.439,0.341,1];
            };

            if(_currentSize > _countSize) then {
                _payloadReady = false;
                _sizeText ctrlSetTextColor [0.729,0.216,0.235,1];
            }else{
                _sizeText ctrlSetTextColor [0.384,0.439,0.341,1];
            };

            if(_currentGroups > _countGroups) then {
                _payloadReady = false;
                _groupText ctrlSetTextColor [0.729,0.216,0.235,1];
            }else{
                _groupText ctrlSetTextColor [0.384,0.439,0.341,1];
            };

            if(_currentVehicles > _countVehicles) then {
                _payloadReady = false;
                _vehiclesText ctrlSetTextColor [0.729,0.216,0.235,1];
            }else{
                _vehiclesText ctrlSetTextColor [0.384,0.439,0.341,1];
            };

            if(_currentIndividuals > _countIndividuals) then {
                _payloadReady = false;
                _individualsText ctrlSetTextColor [0.729,0.216,0.235,1];
            }else{
                _individualsText ctrlSetTextColor [0.384,0.439,0.341,1];
            };

            [_logic,"payloadReady",_payloadReady] call MAINCLASS;

        };

    };

    case "showInit": {

        // reset status markers

        private ["_statusMarker"];

        _statusMarker = [_logic,"statusMarker"] call MAINCLASS;

        if(count _statusMarker > 0) then {
            {
                deleteMarkerLocal _x;
            } foreach _statusMarker;
        };

        [_logic,"statusMarker",[]] call MAINCLASS;

        // Display Current Force Pool

        private ["_forcePool","_forcePoolStatus"];
        _forcePoolStatus = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ForcePool);
        if (!isNil "ALIVE_globalForcePool") then {
            _forcePool = [ALIVE_globalForcePool,faction player,0] call ALIVE_fnc_hashGet;
        } else {
            _forcePool = "WAITING...";
        };

        _forcePoolStatus ctrlSetText format["Current Force Pool: %1",_forcePool];
        _forcePoolStatus ctrlShow true;
        // setup the delivery type list
        private ["_deliveryList","_deliveryListOptions","_deliveryListValues","_selectedDeliveryListIndex"];

        _deliveryList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_DeliveryList);
        _deliveryListOptions = [_logic,"deliveryListOptions"] call MAINCLASS;
        _deliveryListValues = [_logic,"deliveryListValues"] call MAINCLASS;

        lbClear _deliveryList;

        {
            _deliveryList lbAdd format["%1", _x];
        } forEach _deliveryListOptions;

        _deliveryList ctrlSetEventHandler ["LBSelChanged", "['DELIVERY_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        // disable delete button

        private ["_payloadDeleteButton"];

        _payloadDeleteButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadDelete);
        _payloadDeleteButton ctrlShow false;

        // setup and disable payload selection combo

        private ["_payloadOptionsCombo","_payloadComboOptions","_payloadComboValues","_selectedPayloadComboIndex"];

        _payloadOptionsCombo = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadOptions);
        _payloadOptionsCombo ctrlShow false;

        _payloadComboOptions = [_logic,"payloadComboOptions"] call MAINCLASS;
        _payloadComboValues = [_logic,"payloadComboValues"] call MAINCLASS;
        _selectedPayloadComboIndex = [_logic,"payloadComboIndex"] call MAINCLASS;

        lbClear _payloadOptionsCombo;

        {
            _payloadOptionsCombo lbAdd format["%1", _x];
        } forEach _payloadComboOptions;

        _payloadOptionsCombo ctrlSetEventHandler ["LBSelChanged", "['PAYLOAD_COMBO_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        // disable request button

        private ["_payloadRequestButton"];

        _payloadRequestButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonRequest);
        _payloadRequestButton ctrlShow false;

        // disable the request status fields

        private ["_payloadStatusTitle","_payloadStatusText","_payloadStatusList","_payloadStatusButton","_payloadStatusButtonL1","_payloadStatusButtonR1","_payloadStatusMap"];

        _payloadStatusButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonStatus);
        _payloadStatusButton ctrlShow true;
        _payloadStatusButton ctrlSetText "Show Status";
        _payloadStatusButton ctrlSetEventHandler ["MouseButtonClick", "['SHOW_STATUS_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _payloadStatusTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusTitle);
        _payloadStatusTitle ctrlShow false;

        _payloadStatusText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusText);
        _payloadStatusText ctrlShow false;

        _payloadStatusList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusList);
        _payloadStatusList ctrlShow false;

        _payloadStatusButtonL1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonL1);
        _payloadStatusButtonL1 ctrlShow false;

        _payloadStatusButtonR1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonR1);
        _payloadStatusButtonR1 ctrlShow false;

        _payloadStatusMap = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusMap);
        _payloadStatusMap ctrlShow false;


         [nil,"getForcePool", [player, faction player]] remoteExecCall [QUOTE(MAINCLASS),2];
    };

    case "getForcePool": {

        _args params ["_player","_faction"];
        //Wait until MIL_LOG has init and Force Pool Set
        waituntil {!(isnil "ALIVE_globalForcePool")};
        private _forcePool = [MOD(globalForcePool),_faction, 0] call ALiVE_fnc_hashGet;

        [nil,"displayForcePool", [_faction,_forcePool]] remoteExecCall [QUOTE(MAINCLASS),_player];

    };

    case "displayForcePool": {

        _args params ["_faction","_forcepool"];

        private _forcePoolStatus = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ForcePool);
        _forcePoolStatus ctrlSetText format ["Current Force Pool: %1", _forcePool];
        _forcePoolStatus ctrlShow true;

    };

    case "showRequest": {

        // a request is in progress
        // but not yet sent
        // restore the values of the request

        private ["_map"];

        // setup the map

        _map = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_Map);

        _map ctrlSetEventHandler ["MouseButtonDown", "['MAP_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _map ctrlShow true;

        // reset status markers

        private ["_statusMarker"];

        _statusMarker = [_logic,"statusMarker"] call MAINCLASS;

        if(count _statusMarker > 0) then {
            {
                deleteMarkerLocal _x;
            } foreach _statusMarker;
        };

        [_logic,"statusMarker",[]] call MAINCLASS;

        // restore other ui elements

        private ["_deliveryTitle","_supplyTitle","_reinforceTitle","_payloadTitle","_payloadInfo","_payloadStatus","_payloadWeight","_payloadSize","_payloadGroups","_payloadVehicles","_payloadIndividuals"];

        _deliveryTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_DeliveryTypeTitle);
        _deliveryTitle ctrlShow true;

        _supplyTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_SupplyListTitle);
        _supplyTitle ctrlShow true;

        _reinforceTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ReinforceListTitle);
        _reinforceTitle ctrlShow true;

        _payloadTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadListTitle);
        _payloadTitle ctrlShow true;

        _payloadInfo = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadInfo);
        _payloadInfo ctrlShow true;

        _payloadStatus = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadStatus);
        _payloadStatus ctrlShow true;

        _payloadWeight = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadWeight);
        _payloadWeight ctrlShow true;

        _payloadSize = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadSize);
        _payloadSize ctrlShow true;

        _payloadGroups = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadGroups);
        _payloadGroups ctrlShow true;

        _payloadVehicles = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadVehicles);
        _payloadVehicles ctrlShow true;

        _payloadIndividuals = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadIndividuals);
        _payloadIndividuals ctrlShow true;

        // restore the delivery type list

        private ["_deliveryList","_deliveryListOptions","_deliveryListValues","_selectedDeliveryListIndex"];

        _deliveryList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_DeliveryList);
        _deliveryListOptions = [_logic,"deliveryListOptions"] call MAINCLASS;
        _deliveryListValues = [_logic,"deliveryListValues"] call MAINCLASS;
        _selectedDeliveryListIndex = [_logic,"selectedDeliveryListIndex"] call MAINCLASS;

        lbClear _deliveryList;

        {
            _deliveryList lbAdd format["%1", _x];
        } forEach _deliveryListOptions;

        _deliveryList lbSetCurSel _selectedDeliveryListIndex;

        _deliveryList ctrlSetEventHandler ["LBSelChanged", "['DELIVERY_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _deliveryList ctrlShow true;

        // restore the payload list

        private ["_payloadListOptions","_payloadListValues","_payloadList"];

        _payloadList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadList);
        _payloadListOptions = [_logic,"payloadListOptions"] call MAINCLASS;
        _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;

        lbClear _payloadList;

        {
            _payloadList lbAdd format["%1", _x];
        } forEach _payloadListOptions;

        _payloadList ctrlSetEventHandler ["LBSelChanged", "['PAYLOAD_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _payloadList ctrlShow true;

        // setup the supply list

        private ["_supplyList","_selectedSupplyListOptions","_selectedSupplyListValues","_selectedSupplyListDepth"];

        _supplyList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_SupplyList);

        _selectedSupplyListOptions = [_logic,"selectedSupplyListOptions"] call MAINCLASS;
        _selectedSupplyListValues = [_logic,"selectedSupplyListValues"] call MAINCLASS;
        [_logic,"selectedSupplyListDepth",0] call MAINCLASS;

        lbClear _supplyList;

        {
            _supplyList lbAdd format["%1", _x];
        } forEach (_selectedSupplyListOptions select 0);

        _supplyList ctrlSetEventHandler ["LBSelChanged", "['SUPPLY_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _supplyList ctrlShow true;

        // setup the reinforce list

        private ["_reinforceList","_selectedReinforceListOptions","_selectedReinforceListValues","_selectedReinforceListDepth"];

        _reinforceList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ReinforceList);

        _selectedReinforceListOptions = [_logic,"selectedReinforceListOptions"] call MAINCLASS;
        _selectedReinforceListValues = [_logic,"selectedReinforceListValues"] call MAINCLASS;
        [_logic,"selectedReinforceListDepth",0] call MAINCLASS;

        lbClear _reinforceList;

        {
            _reinforceList lbAdd format["%1", _x];
        } forEach (_selectedReinforceListOptions select 0);

        _reinforceList ctrlSetEventHandler ["LBSelChanged", "['REINFORCE_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _reinforceList ctrlShow true;

        // disable delete button

        private ["_payloadDeleteButton"];

        _payloadDeleteButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadDelete);

        _payloadDeleteButton ctrlShow false;

        // setup and disable payload selection combo

        private ["_payloadOptionsCombo","_payloadComboOptions","_payloadComboValues","_selectedPayloadComboIndex"];

        _payloadOptionsCombo = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadOptions);

        _payloadOptionsCombo ctrlShow false;

        _payloadComboOptions = [_logic,"payloadComboOptions"] call MAINCLASS;
        _payloadComboValues = [_logic,"payloadComboValues"] call MAINCLASS;
        _selectedPayloadComboIndex = [_logic,"payloadComboIndex"] call MAINCLASS;

        lbClear _payloadOptionsCombo;

        {
            _payloadOptionsCombo lbAdd format["%1", _x];
        } forEach _payloadComboOptions;

        _payloadOptionsCombo ctrlSetEventHandler ["LBSelChanged", "['PAYLOAD_COMBO_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        // enable request button

        private ["_payloadRequestButton"];

        _payloadRequestButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonRequest);
        _payloadRequestButton ctrlShow true;
        _payloadRequestButton ctrlSetText "Send Request";
        _payloadRequestButton ctrlSetEventHandler ["MouseButtonClick", "['PAYLOAD_REQUEST_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        // disable the request status fields

        private ["_payloadStatusTitle","_payloadStatusText","_payloadStatusList","_payloadStatusButton","_payloadStatusButtonL1","_payloadStatusButtonR1","_payloadStatusMap"];

        _payloadStatusButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonStatus);
        _payloadStatusButton ctrlShow true;
        _payloadStatusButton ctrlSetText "Show Status";
        _payloadStatusButton ctrlSetEventHandler ["MouseButtonClick", "['SHOW_STATUS_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _payloadStatusTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusTitle);
        _payloadStatusTitle ctrlShow false;

        _payloadStatusText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusText);
        _payloadStatusText ctrlShow false;

        _payloadStatusList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusList);
        _payloadStatusList ctrlShow false;

        _payloadStatusButtonL1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonL1);
        _payloadStatusButtonL1 ctrlShow false;

        _payloadStatusButtonR1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonR1);
        _payloadStatusButtonR1 ctrlShow false;

        _payloadStatusMap = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusMap);
        _payloadStatusMap ctrlShow false;

        // set paylist

        [_logic,"payloadUpdated"] call MAINCLASS;

    };

    case "resetRequest": {

        // the tablet has just made a request
        // and the request has been completed
        // reset the request interface objects

        // reset map marker

        private ["_markers","_destinationMarkers"];

        _markers = [_logic,"marker"] call MAINCLASS;

        if(count _markers > 0) then {
            deleteMarkerLocal (_markers select 0);
        };

        [_logic,"marker",[]] call MAINCLASS;
        [_logic,"destination",[]] call MAINCLASS;

        _destinationMarkers = [_logic,"destinationMarker"] call MAINCLASS;

        if(count _destinationMarkers > 0) then {
            {
                deleteMarker _x;
            } forEach _destinationMarkers;

        };

        [_logic,"destinationMarker",[]] call MAINCLASS;

        // reset status markers

        private ["_statusMarker"];

        _statusMarker = [_logic,"statusMarker"] call MAINCLASS;

        if(count _statusMarker > 0) then {
            {
                deleteMarkerLocal _x;
            } foreach _statusMarker;
        };

        [_logic,"statusMarker",[]] call MAINCLASS;

        // restore other ui elements

        private ["_map","_deliveryTitle","_supplyTitle","_reinforceTitle","_payloadTitle","_payloadInfo","_payloadStatus","_payloadWeight","_payloadSize","_payloadGroups","_payloadVehicles","_payloadIndividuals"];

        _map = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_Map);
        _map ctrlShow true;

        _deliveryTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_DeliveryTypeTitle);
        _deliveryTitle ctrlShow true;

        _supplyTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_SupplyListTitle);
        _supplyTitle ctrlShow true;

        _reinforceTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ReinforceListTitle);
        _reinforceTitle ctrlShow true;

        _payloadTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadListTitle);
        _payloadTitle ctrlShow true;

        _payloadInfo = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadInfo);
        _payloadInfo ctrlShow true;

        _payloadStatus = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadStatus);
        _payloadStatus ctrlShow true;

        _payloadWeight = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadWeight);
        _payloadWeight ctrlShow true;

        _payloadSize = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadSize);
        _payloadSize ctrlShow true;

        _payloadGroups = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadGroups);
        _payloadGroups ctrlShow true;

        _payloadVehicles = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadVehicles);
        _payloadVehicles ctrlShow true;

        _payloadIndividuals = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadIndividuals);
        _payloadIndividuals ctrlShow true;

        // restore the delivery type list

        private ["_deliveryList","_deliveryListOptions","_deliveryListValues","_selectedDeliveryListIndex"];

        _deliveryList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_DeliveryList);
        _deliveryListOptions = [_logic,"deliveryListOptions"] call MAINCLASS;
        _deliveryListValues = [_logic,"deliveryListValues"] call MAINCLASS;
        _selectedDeliveryListIndex = [_logic,"selectedDeliveryListIndex"] call MAINCLASS;

        lbClear _deliveryList;

        {
            _deliveryList lbAdd format["%1", _x];
        } forEach _deliveryListOptions;

        _deliveryList lbSetCurSel _selectedDeliveryListIndex;

        _deliveryList ctrlSetEventHandler ["LBSelChanged", "['DELIVERY_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _deliveryList ctrlShow true;

        // reset the payload list

        private ["_payloadListOptions","_payloadListValues","_payloadList"];

        [_logic,"payloadListOptions",[]] call MAINCLASS;
        [_logic,"payloadListValues",[]] call MAINCLASS;

        _payloadList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadList);
        _payloadListOptions = [_logic,"payloadListOptions"] call MAINCLASS;
        _payloadListValues = [_logic,"payloadListValues"] call MAINCLASS;

        lbClear _payloadList;

        {
            _payloadList lbAdd format["%1", _x];
        } forEach _payloadListOptions;

        _payloadList ctrlSetEventHandler ["LBSelChanged", "['PAYLOAD_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _payloadList ctrlShow true;

        // setup the supply list

        private ["_supplyList","_selectedSupplyListOptions","_selectedSupplyListValues","_selectedSupplyListDepth"];

        _supplyList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_SupplyList);

        _selectedSupplyListOptions = [_logic,"selectedSupplyListOptions"] call MAINCLASS;
        _selectedSupplyListValues = [_logic,"selectedSupplyListValues"] call MAINCLASS;
        [_logic,"selectedSupplyListDepth",0] call MAINCLASS;

        lbClear _supplyList;

        {
            _supplyList lbAdd format["%1", _x];
        } forEach (_selectedSupplyListOptions select 0);

        _supplyList ctrlSetEventHandler ["LBSelChanged", "['SUPPLY_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _supplyList ctrlShow true;

        // setup the reinforce list

        private ["_reinforceList","_selectedReinforceListOptions","_selectedReinforceListValues","_selectedReinforceListDepth"];

        _reinforceList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ReinforceList);

        _selectedReinforceListOptions = [_logic,"selectedReinforceListOptions"] call MAINCLASS;
        _selectedReinforceListValues = [_logic,"selectedReinforceListValues"] call MAINCLASS;
        [_logic,"selectedReinforceListDepth",0] call MAINCLASS;

        lbClear _reinforceList;

        {
            _reinforceList lbAdd format["%1", _x];
        } forEach (_selectedReinforceListOptions select 0);

        _reinforceList ctrlSetEventHandler ["LBSelChanged", "['REINFORCE_LIST_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _reinforceList ctrlShow true;

        // disable delete button

        private ["_payloadDeleteButton"];

        _payloadDeleteButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadDelete);

        _payloadDeleteButton ctrlShow false;

        // setup and disable payload selection combo

        private ["_payloadOptionsCombo","_payloadComboOptions","_payloadComboValues","_selectedPayloadComboIndex"];

        _payloadOptionsCombo = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadOptions);

        _payloadOptionsCombo ctrlShow false;

        _payloadComboOptions = [_logic,"payloadComboOptions"] call MAINCLASS;
        _payloadComboValues = [_logic,"payloadComboValues"] call MAINCLASS;
        _selectedPayloadComboIndex = [_logic,"payloadComboIndex"] call MAINCLASS;

        lbClear _payloadOptionsCombo;

        {
            _payloadOptionsCombo lbAdd format["%1", _x];
        } forEach _payloadComboOptions;

        _payloadOptionsCombo ctrlSetEventHandler ["LBSelChanged", "['PAYLOAD_COMBO_SELECT',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        // enable request button

        private ["_payloadRequestButton"];

        _payloadRequestButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonRequest);
        _payloadRequestButton ctrlShow true;
        _payloadRequestButton ctrlSetText "Send Request";
        _payloadRequestButton ctrlSetEventHandler ["MouseButtonClick", "['PAYLOAD_REQUEST_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        // disable the request status fields

        private ["_payloadStatusTitle","_payloadStatusText","_payloadStatusList","_payloadStatusButton","_payloadStatusButtonL1","_payloadStatusButtonR1","_payloadStatusMap"];

        [_logic,"requestStatus",[]] call MAINCLASS;

        _payloadStatusButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonStatus);
        _payloadStatusButton ctrlShow true;
        _payloadStatusButton ctrlSetText "Show Status";
        _payloadStatusButton ctrlSetEventHandler ["MouseButtonClick", "['SHOW_STATUS_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

        _payloadStatusTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusTitle);
        _payloadStatusTitle ctrlShow false;

        _payloadStatusText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusText);
        _payloadStatusText ctrlShow false;

        _payloadStatusList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusList);
        _payloadStatusList ctrlShow false;

        _payloadStatusButtonL1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonL1);
        _payloadStatusButtonL1 ctrlShow false;

        _payloadStatusButtonR1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonR1);
        _payloadStatusButtonR1 ctrlShow false;

        _payloadStatusMap = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusMap);
        _payloadStatusMap ctrlShow false;

    };

    case "showStatus": {

        // payload requested
        // disable request inerface
        // display the status interface

        if (hasInterface) then {

            private ["_map","_deliveryTitle","_deliveryList","_supplyTitle","_supplyList","_reinforceTitle","_reinforceList",
            "_payloadTitle","_payloadList","_payloadInfo","_payloadStatus","_payloadWeight","_payloadSize","_payloadGroups","_payloadVehicles",
            "_payloadIndividuals","_payloadDeleteButton","_payloadOptionsCombo","_payloadRequestButton"];

            _map = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_Map);
            _map ctrlSetEventHandler ["MouseButtonDown", "['MAP_CLICK_NULL',[_this]] call ALIVE_fnc_PRTabletOnAction"];

            _deliveryTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_DeliveryTypeTitle);
            _deliveryTitle ctrlShow false;

            _deliveryList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_DeliveryList);
            _deliveryList ctrlShow false;

            _supplyTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_SupplyListTitle);
            _supplyTitle ctrlShow false;

            _supplyList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_SupplyList);
            _supplyList ctrlShow false;

            _reinforceTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ReinforceListTitle);
            _reinforceTitle ctrlShow false;

            _reinforceList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ReinforceList);
            _reinforceList ctrlShow false;

            _payloadTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadListTitle);
            _payloadTitle ctrlShow false;

            _payloadList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadList);
            _payloadList ctrlShow false;

            _payloadInfo = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadInfo);
            _payloadInfo ctrlShow false;

            _payloadStatus = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadStatus);
            _payloadStatus ctrlShow false;

            _payloadWeight = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadWeight);
            _payloadWeight ctrlShow false;

            _payloadSize = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadSize);
            _payloadSize ctrlShow false;

            _payloadGroups = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadGroups);
            _payloadGroups ctrlShow false;

            _payloadVehicles = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadVehicles);
            _payloadVehicles ctrlShow false;

            _payloadIndividuals = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadIndividuals);
            _payloadIndividuals ctrlShow false;

            _payloadDeleteButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadDelete);
            _payloadDeleteButton ctrlShow false;

            _payloadOptionsCombo = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_PayloadOptions);
            _payloadOptionsCombo ctrlShow false;

            _map = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_Map);
            _map ctrlShow false;

            // display request status text

            private ["_payloadRequestButton","_payloadStatusButton","_payloadStatusList","_payloadStatusTitle","_payloadStatusButtonL1","_payloadStatusButtonR1","_payloadStatusMap"];

            _payloadRequestButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonRequest);
            _payloadRequestButton ctrlShow false;

            _payloadStatusButton = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonStatus);
            _payloadStatusButton ctrlShow true;
            _payloadStatusButton ctrlSetText "Back to Requests";
            _payloadStatusButton ctrlSetEventHandler ["MouseButtonClick", "['SHOW_REQUEST_CLICK',[_this]] call ALIVE_fnc_PRTabletOnAction"];

            _payloadStatusList = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusList);
            _payloadStatusList ctrlShow true;

            _payloadStatusTitle = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusTitle);
            _payloadStatusTitle ctrlShow true;
            _payloadStatusTitle ctrlSetText "Request Status";

            _payloadStatusButtonL1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonL1);
            _payloadStatusButtonL1 ctrlShow false;

            _payloadStatusButtonR1 = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_ButtonR1);
            _payloadStatusButtonR1 ctrlShow false;

            _payloadStatusMap = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusMap);
            _payloadStatusMap ctrlShow false;

            /*
            _payloadStatusText = PR_getControl(PRTablet_CTRL_MainDisplay,PRTablet_CTRL_StatusText);
            _payloadStatusText ctrlShow true;
            */

            [_logic,"state","REQUEST_SENT"] call MAINCLASS;
        };

    };

};

TRACE_1("PR - output",_result);
_result;
