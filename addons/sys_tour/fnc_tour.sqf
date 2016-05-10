//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_tour\script_component.hpp>
SCRIPT(tour);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_tour
Description:
Tour

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance
Boolean - debug - Debug enabled
Array - state - Save and restore module state

Examples:
[_logic, "debug", true] call ALiVE_fnc_tour;

See Also:
- <ALIVE_fnc_tourInit>

Author:
ARJay

Peer Reviewed:
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_tour
#define MTEMPLATE "ALiVE_TOUR_%1"

private ["_logic","_operation","_args","_result","_debug"];

TRACE_1("TOUR - input",_this);

_logic = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
_result = true;

switch(_operation) do {
	default {
		_result = [_logic, _operation, _args] call SUPERCLASS;
	};
	case "destroy": {
		[_logic, "debug", false] call MAINCLASS;
		if (isServer) then {
			// if server
			_logic setVariable ["super", nil];
			_logic setVariable ["class", nil];
			
			[_logic, "destroy"] call SUPERCLASS;
		};
	};
	case "debug": {
		if (typeName _args == "BOOL") then {
			_logic setVariable ["debug", _args];
		} else {
			_args = _logic getVariable ["debug", false];
		};
		if (typeName _args == "STRING") then {
			if(_args == "true") then {_args = true;} else {_args = false;};
			_logic setVariable ["debug", _args];
		};
		ASSERT_TRUE(typeName _args == "BOOL",str _args);
		
		_result = _args;
	};
	case "init": {

		if (isServer) then {
			_logic setVariable ["super", SUPERCLASS];
			_logic setVariable ["class", MAINCLASS];
			_logic setVariable ["moduleType", "ALIVE_TOUR"];
			_logic setVariable ["startupComplete", false];
			_logic setVariable ["selectionState", "start"];
			_logic setVariable ["drawEventID", -1];

			ALiVE_tourStarted = false;

			ALIVE_tourInstance = _logic;

			[_logic, "setSelectionOptions"] call MAINCLASS;

			TRACE_1("After module init",_logic);

			[_logic, "start"] call MAINCLASS;
		};
	};
	case "setSelectionOptions": {

        private["_selectionOptions"];

        _selectionOptions = [] call ALIVE_fnc_hashCreate;

        // start selections

        private["_overview","_actionSelection","_technologySelection","_modulesSelection"];

        _overview = [] call ALIVE_fnc_hashCreate;

        [_overview,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_info.paa"] call ALIVE_fnc_hashSet;
        [_overview,"inactiveLabel","Overview"] call ALIVE_fnc_hashSet;
        [_overview,"activeLabel","About ALiVE"] call ALIVE_fnc_hashSet;
        [_overview,"iconState",["Overview",0,0]] call ALIVE_fnc_hashSet;

        _technologySelection = [] call ALIVE_fnc_hashCreate;

        [_technologySelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_tech.paa"] call ALIVE_fnc_hashSet;
        [_technologySelection,"inactiveLabel","Technology"] call ALIVE_fnc_hashSet;
        [_technologySelection,"activeLabel","Explore the Core ALiVE Technology"] call ALIVE_fnc_hashSet;
        [_technologySelection,"iconState",["Technology",0,0]] call ALIVE_fnc_hashSet;

        _modulesSelection = [] call ALIVE_fnc_hashCreate;

        [_modulesSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_task.paa"] call ALIVE_fnc_hashSet;
        [_modulesSelection,"inactiveLabel","Modules"] call ALIVE_fnc_hashSet;
        [_modulesSelection,"activeLabel","Learn about the ALiVE modules"] call ALIVE_fnc_hashSet;
        [_modulesSelection,"iconState",["Modules",0,0]] call ALIVE_fnc_hashSet;

        _usageSelection = [] call ALIVE_fnc_hashCreate;

        [_usageSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_info.paa"] call ALIVE_fnc_hashSet;
        [_usageSelection,"inactiveLabel","Player Tutorial"] call ALIVE_fnc_hashSet;
        [_usageSelection,"activeLabel","Learn about using ALiVE systems in game"] call ALIVE_fnc_hashSet;
        [_usageSelection,"iconState",["Usage",0,0]] call ALIVE_fnc_hashSet;

        _actionSelection = [] call ALIVE_fnc_hashCreate;

        [_actionSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_weapon.paa"] call ALIVE_fnc_hashSet;
        [_actionSelection,"inactiveLabel","Action"] call ALIVE_fnc_hashSet;
        [_actionSelection,"activeLabel","Get into the action"] call ALIVE_fnc_hashSet;
        [_actionSelection,"iconState",["Action",0,0]] call ALIVE_fnc_hashSet;

        [_selectionOptions,"start",[_overview,_technologySelection,_modulesSelection,_usageSelection,_actionSelection]] call ALIVE_fnc_hashSet;

        // overview selections

        private["_whatSelection","_whySelection","_whoSelection","_backSelection"];

        _whatSelection = [] call ALIVE_fnc_hashCreate;

        [_whatSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_what.paa"] call ALIVE_fnc_hashSet;
        [_whatSelection,"inactiveLabel","What"] call ALIVE_fnc_hashSet;
        [_whatSelection,"activeLabel","What is ALiVE"] call ALIVE_fnc_hashSet;
        [_whatSelection,"iconState",["What",0,0]] call ALIVE_fnc_hashSet;

        _whySelection = [] call ALIVE_fnc_hashCreate;

        [_whySelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_what.paa"] call ALIVE_fnc_hashSet;
        [_whySelection,"inactiveLabel","Why"] call ALIVE_fnc_hashSet;
        [_whySelection,"activeLabel","Why ALiVE"] call ALIVE_fnc_hashSet;
        [_whySelection,"iconState",["Why",0,0]] call ALIVE_fnc_hashSet;

        _whoSelection = [] call ALIVE_fnc_hashCreate;

        [_whoSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_what.paa"] call ALIVE_fnc_hashSet;
        [_whoSelection,"inactiveLabel","Who"] call ALIVE_fnc_hashSet;
        [_whoSelection,"activeLabel","Who is ALiVE"] call ALIVE_fnc_hashSet;
        [_whoSelection,"iconState",["Who",0,0]] call ALIVE_fnc_hashSet;

        _moreSelection = [] call ALIVE_fnc_hashCreate;

        [_moreSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_what.paa"] call ALIVE_fnc_hashSet;
        [_moreSelection,"inactiveLabel","More"] call ALIVE_fnc_hashSet;
        [_moreSelection,"activeLabel","More Information"] call ALIVE_fnc_hashSet;
        [_moreSelection,"iconState",["More",0,0]] call ALIVE_fnc_hashSet;

        _backSelection = [] call ALIVE_fnc_hashCreate;

        [_backSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_back.paa"] call ALIVE_fnc_hashSet;
        [_backSelection,"inactiveLabel","Go Back"] call ALIVE_fnc_hashSet;
        [_backSelection,"activeLabel","Go back to the previous menu"] call ALIVE_fnc_hashSet;
        [_backSelection,"iconState",["Back",0,0]] call ALIVE_fnc_hashSet;

        [_selectionOptions,"Overview",[_whatSelection,_whySelection,_whoSelection,_moreSelection,_backSelection]] call ALIVE_fnc_hashSet;

        // action selections

        private["_joinRandomSelection","_freeRoam","_backSelection"];

        _joinRandomSelection = [] call ALIVE_fnc_hashCreate;

        [_joinRandomSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_what.paa"] call ALIVE_fnc_hashSet;
        [_joinRandomSelection,"inactiveLabel","Join Group"] call ALIVE_fnc_hashSet;
        [_joinRandomSelection,"activeLabel","Join a group"] call ALIVE_fnc_hashSet;
        [_joinRandomSelection,"iconState",["Join",0,0]] call ALIVE_fnc_hashSet;

        _freeRoam = [] call ALIVE_fnc_hashCreate;

        [_freeRoam,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_what.paa"] call ALIVE_fnc_hashSet;
        [_freeRoam,"inactiveLabel","Free Roam"] call ALIVE_fnc_hashSet;
        [_freeRoam,"activeLabel","Free roam the mission"] call ALIVE_fnc_hashSet;
        [_freeRoam,"iconState",["Roam",0,0]] call ALIVE_fnc_hashSet;

        _backSelection = [] call ALIVE_fnc_hashCreate;

        [_backSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_back.paa"] call ALIVE_fnc_hashSet;
        [_backSelection,"inactiveLabel","Go Back"] call ALIVE_fnc_hashSet;
        [_backSelection,"activeLabel","Go back to the previous menu"] call ALIVE_fnc_hashSet;
        [_backSelection,"iconState",["Back",0,0]] call ALIVE_fnc_hashSet;

        [_selectionOptions,"Action",[_joinRandomSelection,_freeRoam,_backSelection]] call ALIVE_fnc_hashSet;

        // technology selections

        private["_mapAnalysisSelection","_objectivesSelection","_battlefieldSelection","_profileSelection","_opcomSelection","_dataSelection","_warroomSelection","_backSelection"];

        _mapAnalysisSelection = [] call ALIVE_fnc_hashCreate;

        [_mapAnalysisSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_sector.paa"] call ALIVE_fnc_hashSet;
        [_mapAnalysisSelection,"inactiveLabel","Map Analysis"] call ALIVE_fnc_hashSet;
        [_mapAnalysisSelection,"activeLabel","View map analysis"] call ALIVE_fnc_hashSet;
        [_mapAnalysisSelection,"iconState",["Analysis",0,0]] call ALIVE_fnc_hashSet;

        _objectivesSelection = [] call ALIVE_fnc_hashCreate;

        [_objectivesSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_mil_placement.paa"] call ALIVE_fnc_hashSet;
        [_objectivesSelection,"inactiveLabel","Objective Analysis"] call ALIVE_fnc_hashSet;
        [_objectivesSelection,"activeLabel","View objective analysis"] call ALIVE_fnc_hashSet;
        [_objectivesSelection,"iconState",["Objective",0,0]] call ALIVE_fnc_hashSet;

        _battlefieldSelection = [] call ALIVE_fnc_hashCreate;

        [_battlefieldSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_cas.paa"] call ALIVE_fnc_hashSet;
        [_battlefieldSelection,"inactiveLabel","Battlefield Analysis"] call ALIVE_fnc_hashSet;
        [_battlefieldSelection,"activeLabel","View battlefield analysis"] call ALIVE_fnc_hashSet;
        [_battlefieldSelection,"iconState",["Battlefield",0,0]] call ALIVE_fnc_hashSet;

        _profileSelection = [] call ALIVE_fnc_hashCreate;

        [_profileSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_profiles.paa"] call ALIVE_fnc_hashSet;
        [_profileSelection,"inactiveLabel","Virtual AI System"] call ALIVE_fnc_hashSet;
        [_profileSelection,"activeLabel","The virtual AI system"] call ALIVE_fnc_hashSet;
        [_profileSelection,"iconState",["Profiles",0,0]] call ALIVE_fnc_hashSet;

        _opcomSelection = [] call ALIVE_fnc_hashCreate;

        [_opcomSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_opcom.paa"] call ALIVE_fnc_hashSet;
        [_opcomSelection,"inactiveLabel","AI Commander"] call ALIVE_fnc_hashSet;
        [_opcomSelection,"activeLabel","The military AI commanders"] call ALIVE_fnc_hashSet;
        [_opcomSelection,"iconState",["Opcom",0,0]] call ALIVE_fnc_hashSet;

        _dataSelection = [] call ALIVE_fnc_hashCreate;

        [_dataSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_data.paa"] call ALIVE_fnc_hashSet;
        [_dataSelection,"inactiveLabel","Database"] call ALIVE_fnc_hashSet;
        [_dataSelection,"activeLabel","The central persistence database"] call ALIVE_fnc_hashSet;
        [_dataSelection,"iconState",["Data",0,0]] call ALIVE_fnc_hashSet;

        _warroomSelection = [] call ALIVE_fnc_hashCreate;

        [_warroomSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_task.paa"] call ALIVE_fnc_hashSet;
        [_warroomSelection,"inactiveLabel","WarRoom Web Integration"] call ALIVE_fnc_hashSet;
        [_warroomSelection,"activeLabel","The WarRoom web system"] call ALIVE_fnc_hashSet;
        [_warroomSelection,"iconState",["Warroom",0,0]] call ALIVE_fnc_hashSet;

        _backSelection = [] call ALIVE_fnc_hashCreate;

        [_backSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_back.paa"] call ALIVE_fnc_hashSet;
        [_backSelection,"inactiveLabel","Go Back"] call ALIVE_fnc_hashSet;
        [_backSelection,"activeLabel","Go back to the previous menu"] call ALIVE_fnc_hashSet;
        [_backSelection,"iconState",["Back",0,0]] call ALIVE_fnc_hashSet;

        [_selectionOptions,"Technology",[_mapAnalysisSelection,_objectivesSelection,_battlefieldSelection,_profileSelection,_opcomSelection,_dataSelection,_warroomSelection,_backSelection]] call ALIVE_fnc_hashSet;

        // module selections

        private["_opcomSelection","_placementSelection","_logisticsSelection","_cqbSelection","_civilianSelection","_supportSelection","_resupplySelection","_c2Selection"];

        _opcomSelection = [] call ALIVE_fnc_hashCreate;

        [_opcomSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_opcom.paa"] call ALIVE_fnc_hashSet;
        [_opcomSelection,"inactiveLabel","AI Commander"] call ALIVE_fnc_hashSet;
        [_opcomSelection,"activeLabel","The military AI commander (OPCOM) module"] call ALIVE_fnc_hashSet;
        [_opcomSelection,"iconState",["ModuleOPCOM",0,0]] call ALIVE_fnc_hashSet;

        _placementSelection = [] call ALIVE_fnc_hashCreate;

        [_placementSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_mil_placement.paa"] call ALIVE_fnc_hashSet;
        [_placementSelection,"inactiveLabel","Military Placement"] call ALIVE_fnc_hashSet;
        [_placementSelection,"activeLabel","The military force placement modules"] call ALIVE_fnc_hashSet;
        [_placementSelection,"iconState",["ModulePlacement",0,0]] call ALIVE_fnc_hashSet;

        _logisticsSelection = [] call ALIVE_fnc_hashCreate;

        [_logisticsSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_logistics.paa"] call ALIVE_fnc_hashSet;
        [_logisticsSelection,"inactiveLabel","Military Logistics"] call ALIVE_fnc_hashSet;
        [_logisticsSelection,"activeLabel","The military AI logistics module"] call ALIVE_fnc_hashSet;
        [_logisticsSelection,"iconState",["ModuleLogistics",0,0]] call ALIVE_fnc_hashSet;

        _cqbSelection = [] call ALIVE_fnc_hashCreate;

        [_cqbSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_cqb.paa"] call ALIVE_fnc_hashSet;
        [_cqbSelection,"inactiveLabel","Close Quarters Battle"] call ALIVE_fnc_hashSet;
        [_cqbSelection,"activeLabel","The close quarters battle module"] call ALIVE_fnc_hashSet;
        [_cqbSelection,"iconState",["ModuleCQB",0,0]] call ALIVE_fnc_hashSet;

        _civilianSelection = [] call ALIVE_fnc_hashCreate;

        [_civilianSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_civ.paa"] call ALIVE_fnc_hashSet;
        [_civilianSelection,"inactiveLabel","Civilian Population"] call ALIVE_fnc_hashSet;
        [_civilianSelection,"activeLabel","The civilian population module"] call ALIVE_fnc_hashSet;
        [_civilianSelection,"iconState",["ModuleCivilian",0,0]] call ALIVE_fnc_hashSet;

        _supportSelection = [] call ALIVE_fnc_hashCreate;

        [_supportSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_cs.paa"] call ALIVE_fnc_hashSet;
        [_supportSelection,"inactiveLabel","Player Combat Support"] call ALIVE_fnc_hashSet;
        [_supportSelection,"activeLabel","The player combat support module"] call ALIVE_fnc_hashSet;
        [_supportSelection,"iconState",["ModuleCombatSupport",0,0]] call ALIVE_fnc_hashSet;

        _resupplySelection = [] call ALIVE_fnc_hashCreate;

        [_resupplySelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_logistics.paa"] call ALIVE_fnc_hashSet;
        [_resupplySelection,"inactiveLabel","Player Combat Logistics"] call ALIVE_fnc_hashSet;
        [_resupplySelection,"activeLabel","The player combat logistics module"] call ALIVE_fnc_hashSet;
        [_resupplySelection,"iconState",["ModuleResupply",0,0]] call ALIVE_fnc_hashSet;

        _c2Selection = [] call ALIVE_fnc_hashCreate;

        [_c2Selection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_intel.paa"] call ALIVE_fnc_hashSet;
        [_c2Selection,"inactiveLabel","Player Command and Control"] call ALIVE_fnc_hashSet;
        [_c2Selection,"activeLabel","The command and control (C2ISTAR) module"] call ALIVE_fnc_hashSet;
        [_c2Selection,"iconState",["ModuleC2",0,0]] call ALIVE_fnc_hashSet;

        _backSelection = [] call ALIVE_fnc_hashCreate;

        [_backSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_back.paa"] call ALIVE_fnc_hashSet;
        [_backSelection,"inactiveLabel","Go Back"] call ALIVE_fnc_hashSet;
        [_backSelection,"activeLabel","Go back to the previous menu"] call ALIVE_fnc_hashSet;
        [_backSelection,"iconState",["Back",0,0]] call ALIVE_fnc_hashSet;

        [_selectionOptions,"Modules",[_opcomSelection,_placementSelection,_logisticsSelection,_cqbSelection,_civilianSelection,_supportSelection,_resupplySelection,_c2Selection,_backSelection]] call ALIVE_fnc_hashSet;

        // usage selections

        private["_aliveMenuSelection","_adminActionsSelection","_playerOptionsSelection","_playerLogisticsSelection","_playerCombatLogisticsSelection","_playerC2","_playerCombatSupport","_playerMarkers","_backSelection"];

        _aliveMenuSelection = [] call ALIVE_fnc_hashCreate;

        [_aliveMenuSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_info.paa"] call ALIVE_fnc_hashSet;
        [_aliveMenuSelection,"inactiveLabel","ALiVE Menu System"] call ALIVE_fnc_hashSet;
        [_aliveMenuSelection,"activeLabel","Using the ALiVE menu system"] call ALIVE_fnc_hashSet;
        [_aliveMenuSelection,"iconState",["UsageMenu",0,0]] call ALIVE_fnc_hashSet;

        _adminActionsSelection = [] call ALIVE_fnc_hashCreate;

        [_adminActionsSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_info.paa"] call ALIVE_fnc_hashSet;
        [_adminActionsSelection,"inactiveLabel","Admin Actions"] call ALIVE_fnc_hashSet;
        [_adminActionsSelection,"activeLabel","Actions for server administrators"] call ALIVE_fnc_hashSet;
        [_adminActionsSelection,"iconState",["UsageAdmin",0,0]] call ALIVE_fnc_hashSet;

        _playerOptionsSelection = [] call ALIVE_fnc_hashCreate;

        [_playerOptionsSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_info.paa"] call ALIVE_fnc_hashSet;
        [_playerOptionsSelection,"inactiveLabel","Player Options"] call ALIVE_fnc_hashSet;
        [_playerOptionsSelection,"activeLabel","Options available to players"] call ALIVE_fnc_hashSet;
        [_playerOptionsSelection,"iconState",["UsagePlayer",0,0]] call ALIVE_fnc_hashSet;

        _playerLogisticsSelection = [] call ALIVE_fnc_hashCreate;

        [_playerLogisticsSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_info.paa"] call ALIVE_fnc_hashSet;
        [_playerLogisticsSelection,"inactiveLabel","Logistics"] call ALIVE_fnc_hashSet;
        [_playerLogisticsSelection,"activeLabel","Lift and shift logistics"] call ALIVE_fnc_hashSet;
        [_playerLogisticsSelection,"iconState",["UsagePlayerLogistics",0,0]] call ALIVE_fnc_hashSet;

        _playerCombatLogisticsSelection = [] call ALIVE_fnc_hashCreate;

        [_playerCombatLogisticsSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_info.paa"] call ALIVE_fnc_hashSet;
        [_playerCombatLogisticsSelection,"inactiveLabel","Combat Logistics"] call ALIVE_fnc_hashSet;
        [_playerCombatLogisticsSelection,"activeLabel","Resuply combat logistics"] call ALIVE_fnc_hashSet;
        [_playerCombatLogisticsSelection,"iconState",["UsagePlayerCombatLogistics",0,0]] call ALIVE_fnc_hashSet;

        _playerC2 = [] call ALIVE_fnc_hashCreate;

        [_playerC2,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_info.paa"] call ALIVE_fnc_hashSet;
        [_playerC2,"inactiveLabel","Command and Control"] call ALIVE_fnc_hashSet;
        [_playerC2,"activeLabel","Command and control"] call ALIVE_fnc_hashSet;
        [_playerC2,"iconState",["UsagePlayerC2",0,0]] call ALIVE_fnc_hashSet;

        _playerCombatSupport = [] call ALIVE_fnc_hashCreate;

        [_playerCombatSupport,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_info.paa"] call ALIVE_fnc_hashSet;
        [_playerCombatSupport,"inactiveLabel","Combat Support"] call ALIVE_fnc_hashSet;
        [_playerCombatSupport,"activeLabel","Combat Support"] call ALIVE_fnc_hashSet;
        [_playerCombatSupport,"iconState",["UsagePlayerCombatSupport",0,0]] call ALIVE_fnc_hashSet;

        _playerMarkers = [] call ALIVE_fnc_hashCreate;

        [_playerMarkers,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_info.paa"] call ALIVE_fnc_hashSet;
        [_playerMarkers,"inactiveLabel","Advanced Markers"] call ALIVE_fnc_hashSet;
        [_playerMarkers,"activeLabel","Advanced markers"] call ALIVE_fnc_hashSet;
        [_playerMarkers,"iconState",["UsageAdvancedMarkers",0,0]] call ALIVE_fnc_hashSet;

        _backSelection = [] call ALIVE_fnc_hashCreate;

        [_backSelection,"icon","x\alive\addons\sys_tour\data\alive_icons_tour_back.paa"] call ALIVE_fnc_hashSet;
        [_backSelection,"inactiveLabel","Go Back"] call ALIVE_fnc_hashSet;
        [_backSelection,"activeLabel","Go back to the previous menu"] call ALIVE_fnc_hashSet;
        [_backSelection,"iconState",["Back",0,0]] call ALIVE_fnc_hashSet;

        [_selectionOptions,"Usage",[_aliveMenuSelection,_adminActionsSelection,_playerOptionsSelection,_playerLogisticsSelection,_playerCombatLogisticsSelection,_playerC2,_playerCombatSupport,_playerMarkers,_backSelection]] call ALIVE_fnc_hashSet;

        // store all the selection options

        _logic setVariable ["selectionOptions", _selectionOptions];

	};

	case "resetSelectionState": {

	    private["_selectionOptions","_iconState"];

	    _selectionOptions = _logic getVariable "selectionOptions";

	    {
            {
                _iconState = _x select 2 select 3;
                _iconState set [1,0];
                _iconState set [2,0];
            } forEach _x;
	    } forEach (_selectionOptions select 2);

	};

	case "start": {

        if(isServer) then {

            // start listening for events
            [_logic,"listen"] call MAINCLASS;

            player setCaptive true;
            player enableFatigue false;
            player addEventHandler ["HandleDamage", {(_this select 2) / 100}];

            ALiVE_tourStarted = true;

            // display loading
            [_logic,"displayStartLoadingScreen"] call MAINCLASS;

            // setup placement
            [_logic,"setRandomPlacement"] call MAINCLASS;

            // create initial interactive icons
            [_logic,"displaySelectionState"] call MAINCLASS;

            // set module as startup complete
            _logic setVariable ["startupComplete", true];

        };

    };

    case "displayStartLoadingScreen": {

        private["_line1","_line2","_line3","_line4","_text"];

        call BIS_fnc_VRFadeIn;

        _line1 = "<t size='1.5' color='#68a7b7' align='center'>Welcome to the ALiVE Tour</t><br/><br/>";
        _line2 = "<t size='1' align='center'>Discover the technology, modules, and usage of ALiVE.</t><br/>";
        _line3 = "<t size='1' align='center'>Information topics will be created around your player.</t><br/>";
        _line4 = "<t size='1' align='center'>Walk towards a topic you wish to learn more about.</t><br/><br/>";

        _text = format["%1%2%3%4",_line1,_line2,_line3,_line4];

        ["openSplash",0.3] call ALIVE_fnc_displayMenu;
        ["setSplashText",_text] call ALIVE_fnc_displayMenu;

    };

    case "setRandomPlacement": {

        private["_sides","_side","_locationTypes","_locationType","_initialPosition","_position","_emptyPosition"];

        waitUntil {!(isNil "ALIVE_REQUIRE_INITIALISED")};
        waitUntil {ALIVE_REQUIRE_INITIALISED};

        _sides = ["EAST","WEST"];
        _side = _sides call BIS_fnc_selectRandom;
        _locationTypes = ["Short","Medium","Long"];
        _locationType = _locationTypes call BIS_fnc_selectRandom;

        _initialPosition = position _logic;

        _position = [_initialPosition,_locationType,_side] call ALIVE_fnc_taskGetSideCluster;

        if(count _position == 0) then {
            _position = [_initialPosition,_locationType,_side] call ALIVE_fnc_taskGetSideSectorCompositionPosition;
        };

        if(count _position > 0) then {
            _position = [_position,"overwatch"] call ALIVE_fnc_taskGetSectorPosition;
        }else{
            _position = _initialPosition;
        };

        _emptyPosition = _position findEmptyPosition [10,1000];

        if(count _emptyPosition > 0) then {
            if!(surfaceIsWater _emptyPosition) then {
                player setPos _emptyPosition;
            };
        }else{
            if!(surfaceIsWater _position) then {
                player setPos _position;
            };
        };

    };

    case "displaySelectionState": {

        // set some defaults

        ALIVE_tourActiveColour = [1,1,1,1];
        ALIVE_tourInActiveColour = [1,1,1,1];


        // get the current selections

        private["_currentSelectionState","_selectionOptions","_countSelections"];

        _currentSelectionState = _logic getVariable "selectionState";
        _selectionOptions = _logic getVariable "selectionOptions";

        ALIVE_tourCurrentSelectionValues = [_selectionOptions,_currentSelectionState] call ALIVE_fnc_hashGet;

        _countSelections = count ALIVE_tourCurrentSelectionValues;


        // define the positions for the selection icons

        private["_offset","_rad","_degStep","_position","_eventID"];

        _offset = 15;
        _rad = (_offset * _countSelections) / (2 * pi);
        _degStep = 360 / _countSelections;

        ALIVE_tourIconPositions = [];

        {
            _position = [getPos player, _rad, _degStep * _forEachIndex] call BIS_fnc_relPos;
            _position set [2, (100) + (_forEachIndex * 10)];

            ALIVE_tourIconPositions set [count ALIVE_tourIconPositions, _position];

        } foreach ALIVE_tourCurrentSelectionValues;


        // run the draw icon 3D routine for the selections

        _eventID = addMissionEventHandler ["Draw3D", {
            {
                private ["_selectionOption","_icon","_inactiveLabel","_activeLabel","_iconState","_iconActive","_iconDistance",
                "_iconID","_iconActiveTime","_position","_distance","_size","_active","_label","_colour","_soundSource"];

                _selectionOption = _x;

                _icon = _selectionOption select 2 select 0;
                _inactiveLabel = _selectionOption select 2 select 1;
                _activeLabel = _selectionOption select 2 select 2;
                _iconState = _selectionOption select 2 select 3;

                _iconID = _iconState select 0;
                _iconDistance = _iconState select 1;
                _iconActiveTime = _iconState select 2;

                _position = ALIVE_tourIconPositions select _forEachIndex;

                _distance = (getPos player) distance _position;

                _colour = ALIVE_tourInActiveColour;
                _size = 2.5;
                _label = _inactiveLabel;

                if(_distance > 6) then {
                    _size = 2.5;
                    _colour = ALIVE_tourInActiveColour;
                    _label = _inactiveLabel;
                    _iconActiveTime = 0;

                    if(_distance > 40) then {
                        _size = 0.5;
                        _label = "";
                    };

                    if(_position select 2 > 2) then {
                        _position set [2, (_position select 2) - 1];
                        ALIVE_tourIconPositions set [_forEachIndex,_position];
                    };

                    if(_position select 2 == 3) then {
                        _soundSource = "RoadCone_L_F" createVehicle _position;
                        hideObjectGlobal _soundSource;
                        _soundSource say3d "FD_Finish_F";
                    };
                }else{
                    _size = 2.5 + (24 - (_distance * 4));

                    if(_distance < 6) then {
                        _label = _activeLabel;
                        _colour = ALIVE_tourActiveColour;

                        if(_iconDistance >= _distance) then {
                            _iconActiveTime = _iconActiveTime + 1;
                        }else{
                            if(_iconActiveTime > 0) then {
                                _iconActiveTime = _iconActiveTime - 1;
                            };
                        };

                        if(_iconActiveTime > 100) then {

                            _soundSource = "RoadCone_L_F" createVehicle _position;
                            hideObjectGlobal _soundSource;
                            _soundSource say3d "FD_CP_Not_Clear_F";

                            [ALIVE_tourInstance,"handleIconActivated",_iconID] call ALIVE_fnc_tour;
                        };

                    }else{
                        if(_distance > 6) then {
                            _label = _inactiveLabel;
                            _colour = ALIVE_tourInActiveColour;
                        };
                    };
                };

                _iconState set [1,_distance];
                _iconState set [2,_iconActiveTime];

                drawIcon3D [_icon,_colour,_position,_size,_size,0,_label,1,0.06];

            } foreach ALIVE_tourCurrentSelectionValues;
        }];

        _logic setVariable ["drawEventID", _eventID];

    };

    case "handleIconActivated": {

        private["_eventID","_currentSelectionState"];

        [_logic,"resetSelectionState"] call MAINCLASS;

        _eventID = _logic getVariable "drawEventID";

        removeMissionEventHandler ["Draw3D",_eventID];

        _currentSelectionState = _logic getVariable "selectionState";

        if(_currentSelectionState == "start") then {

            _logic setVariable ["selectionState",_args];

            [_logic,"displaySelectionState"] call MAINCLASS;

        }else{

            [_logic,format["activateSelection%1",_args]] call MAINCLASS;

        };
    };

    case "activateSelectionBack": {
        _logic setVariable ["selectionState","start"];
        [_logic,"displaySelectionState"] call MAINCLASS;
    };

    case "handleMenuCallback": {

        private["_action","_id"];

        _action = _args select 0;
        _id = _args select 1;

        switch(_action) do {
            case "close": {

                [_logic,"resetSelectionState"] call MAINCLASS;

                [_logic,format["deactivateSelection%1",_id]] call MAINCLASS;
            };
        };

    };

    case "activateSelectionWhat": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>What is ALiVE?</t><br/><br/>";
            _line2 = "<t size='1'>ALIVE is a missions makers framework. Developed by Arma community veterans, the easy to use modular system provides everything that players and mission makers need to set up and run realistic military operations in almost any scenario up to Company level, including command, combat support, service support and logistics.</t><br/><br/>";
            _line3 = "<t size='1'>The editor placed modules are designed to be intuitive but highly flexible so you can create a huge range of different scenarios by simply placing a few modules and markers. The AI Commanders have an overall mission and a prioritised list of objectives that they will work through autonomously. Players can choose to tag along with the AI and join the fight, take your own squad of AI or other players and tackle your own objectives or just sit back and watch it all unfold.</t><br/><br/>";
            _line4 = "<t size='1'>Mission makers may wish to use ALiVE modules as a backdrop for dynamic missions and campaigns, enhancing scenarios created with traditional editing techniques. ALiVE can significantly reduce the effort required to make a complex mission by adding ambience, support and persistence at the drop of a module.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openImageFull",[_logic,"handleMenuCallback","What"]] call ALIVE_fnc_displayMenu;
            ["setFullImageText",_baseCopy] call ALIVE_fnc_displayMenu;
            ["setFullImage","x\alive\addons\ui\logo_alive_square.paa"] call ALIVE_fnc_displayMenu;

        };

    };

    case "deactivateSelectionWhat": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Overview"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionWhy": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Why ALiVE?</t><br/><br/>";
            _line2 = "<t size='1'>ALiVE was designed to enhance the ARMA 3 experience for groups and players who want to create a credibly realistc mission or campaign.</t><br/><br/>";
            _line3 = "<t size='1'>Coming from development of the MSO mod in ARMA 2, the lessons learned there have influenced the development of ALiVE:</t><br/><br/>";
            _line4 = "<t size='1'>Moving from an entirely script based platform to taking advantage of the ARMA module framework to enable much easier usage by mission editors</t><br/><br/>";
            _line5 = "<t size='1'>Opting for a centralised database as opposed to supporting individual group database installations.</t><br/><br/>";
            _line6 = "<t size='1'>Going from largely random in game events to a much more environment and event driven AI and generation systems.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5,_line6];

            ["openImageFull",[_logic,"handleMenuCallback","Why"]] call ALIVE_fnc_displayMenu;
            ["setFullImageText",_baseCopy] call ALIVE_fnc_displayMenu;
            ["setFullImage","x\alive\addons\ui\logo_alive_square.paa"] call ALIVE_fnc_displayMenu;

        };

    };

    case "deactivateSelectionWhy": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Overview"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionWho": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_line8","_line9","_line10","_line11","_line12","_line13","_line14","_line15","_line16","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Who are the dev's?</t><br/><br/>";
            _line2 = "<t size='1'>ALiVE has been in constant development since the release of ARMA 3 early access.</t><br/><br/>";
            _line3 = "<t size='1'>Developed by a global team from 5 countries, ALiVE continues to be a compelling hobby project for the largely IT professional developers.</t><br/><br/>";
            _line4 = "<t size='1'>ARJay</t><br/>";
            _line5 = "<t size='1'>Cameroon</t><br/>";
            _line6 = "<t size='1'>Friznit</t><br/>";
            _line7 = "<t size='1'>Gunny</t><br/>";
            _line8 = "<t size='1'>Haze</t><br/>";
            _line9 = "<t size='1'>Highhead</t><br/>";
            _line10 = "<t size='1'>Jman</t><br/>";
            _line11 = "<t size='1'>Naught</t><br/>";
            _line12 = "<t size='1'>Raptor</t><br/>";
            _line13 = "<t size='1'>Rye</t><br/>";
            _line14 = "<t size='1'>Tupolov</t><br/>";
            _line15 = "<t size='1'>WobblyHeadedBob</t><br/>";
            _line16 = "<t size='1'>Wolffy.au</t><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7%8%9%10%11%12%13%14%15%16",_line1,_line2,_line3,_line4,_line5,_line6,_line7,_line8,_line9,_line10,_line11,_line12,_line13,_line14,_line15,_line16];

            ["openImageFull",[_logic,"handleMenuCallback","Who"]] call ALIVE_fnc_displayMenu;
            ["setFullImageText",_baseCopy] call ALIVE_fnc_displayMenu;
            ["setFullImage","x\alive\addons\sys_tour\data\devteam.paa"] call ALIVE_fnc_displayMenu;

        };

    };

    case "deactivateSelectionWho": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Overview"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionMore": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_line8","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>More Information</t><br/><br/>";
            _line2 = "<t size='1'>The ALiVE community and resources are available for players seeking support, tutorials, and missions.</t><br/><br/>";
            _line3 = "<t size='1'><a href='http://alivemod.com'>The ALiVE website</a></t><br/><br/>";
            _line4 = "<t size='1'><a href='http://alivemod.com/wiki'>The ALiVE wiki</a></t><br/><br/>";
            _line5 = "<t size='1'><a href='http://alivemod.com/forum'>The ALiVE forum</a></t><br/><br/>";
            _line6 = "<t size='1'><a href='https://www.youtube.com/user/ALIVEARMA3'>The ALiVE Youtube channel</a></t><br/><br/>";
            _line7 = "<t size='1'><a href='https://www.facebook.com/alivemod'>The ALiVE Facebook page</a></t><br/><br/>";
            _line8 = "<t size='1'><a href='http://forums.bistudio.com/showthread.php?169350-ALiVE-Advanced-Light-Infantry-Virtual-Environment'>The ALiVE BI forum thread</a></t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7%8",_line1,_line2,_line3,_line4,_line5,_line6,_line7,_line8];

            ["openImageFull",[_logic,"handleMenuCallback","More"]] call ALIVE_fnc_displayMenu;
            ["setFullImageText",_baseCopy] call ALIVE_fnc_displayMenu;
            ["setFullImage","x\alive\addons\ui\logo_alive_square.paa"] call ALIVE_fnc_displayMenu;

        };

    };

    case "deactivateSelectionMore": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Overview"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionAnalysis": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7' >Map Analysis</t><br/><br/>";
            _line2 = "<t size='1'>ALiVE needs to make many decisions about the environment in which it operates. To make informed decisions, as detailed a view of the world as possible is required.</t><br/><br/>";
            _line3 = "<t size='1'>To facilitate this ALiVE uses a series of analysis and calculation functions to store, evaluate and retrieve information about the current map.</t><br/><br/>";
            _line4 = "<t size='1'>These demonstrations display some of the analytic powers of ALiVE plotted on the world map.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4",_line1,_line2,_line3,_line4];

            ["openMapFull",[_logic,"handleMenuCallback","Analysis"]] call ALIVE_fnc_displayMenu;
            ["setFullMapText",_baseCopy] call ALIVE_fnc_displayMenu;

            private["_mapSize","_mapCenter"];

            _mapSize = [] call ALIVE_fnc_getMapBounds;
            _mapCenter = [(_mapSize/2),(_mapSize/2)];
            ["setFullMapAnimation",[0.5,0.7,_mapCenter]] call ALIVE_fnc_displayMenu;


            private["_allSectors","_landSectors","_playerSector","_surroundingSectors","_highSectors","_playerSectorData","_playerSectorCenterPosition"];

            _allSectors = [ALIVE_sectorGrid, "sectors"] call ALIVE_fnc_sectorGrid;
            _landSectors = [_allSectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;
            _playerSector = [ALIVE_sectorGrid, "positionToSector", getPos player] call ALIVE_fnc_sectorGrid;
            _playerSectorData = [_playerSector, "data"] call ALIVE_fnc_hashGet;
            _playerSectorCenterPosition = [_playerSector, "center"] call ALIVE_fnc_sector;
            _surroundingSectors = [ALIVE_sectorGrid, "surroundingSectors", getPos player] call ALIVE_fnc_sectorGrid;

            private ["_createMarker"];

            _createMarker = {
                private ["_markerID","_position","_dimensions","_alpha","_color","_shape","_m"];

                _markerID = _this select 0;
                _position = _this select 1;
                _dimensions = _this select 2;
                _color = _this select 3;

                _m = createMarkerLocal [_markerID, _position];
                _m setMarkerShapeLocal "ICON";
                _m setMarkerSizeLocal _dimensions;
                _m setMarkerTypeLocal "mil_dot";
                _m setMarkerColorLocal _color;
                _m setMarkerTextLocal _markerID;
                _m
            };


            [ALIVE_sectorPlotter, "plot", [_allSectors, "elevation"]] call ALIVE_fnc_plotSectors;

            private["_line","_currentCopy"];

            _line = "<t size='1'>Current analysis: sector elevation</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;



            private["_highSectors","_sortedHighSectors"];

            _highSectors = [_landSectors, 100, 200] call ALIVE_fnc_sectorFilterElevation;
            _sortedHighSectors = [_highSectors, getPos player] call ALIVE_fnc_sectorSortDistance;

            [ALIVE_sectorPlotter, "plot", [_sortedHighSectors, "elevation"]] call ALIVE_fnc_plotSectors;

            _line = "<t size='1'>Current analysis: highest elevation sectors</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;



            [ALIVE_sectorPlotter, "plot", [_allSectors, "terrain"]] call ALIVE_fnc_plotSectors;

            _line = "<t size='1'>Current analysis: sector terrain types (land,shore,sea)</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 20;



            ["setFullMapAnimation",[0.5,0.2,_playerSectorCenterPosition]] call ALIVE_fnc_displayMenu;


            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;
            [ALIVE_sectorPlotter, "plot", [[_playerSector], "terrainSamples"]] call ALIVE_fnc_plotSectors;

            _line = "<t size='1'>Current analysis: in sector terrain type sampling</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;


            private["_sortedElevationData","_lowestElevationInSector","_highestElevationInSector","_m","_m1","_m2","_m3"];

            _sortedElevationData = [_playerSectorData, "elevationLand", []] call ALIVE_fnc_sectorDataSort;

            if(count _sortedElevationData > 0) then {
                _lowestElevationInSector = _sortedElevationData select 0;
                _m1 = ["Lowest Elevation",(_lowestElevationInSector select 0),[1,1],"ColorGreen"] call _createMarker;

                _highestElevationInSector = _sortedElevationData select count(_sortedElevationData)-1;
                _m2 = ["Highest Elevation",(_highestElevationInSector select 0),[1,1],"ColorRed"] call _createMarker;

                _line = "<t size='1'>Current analysis: lowest and highest points in sector</t><br/><br/>";
                _currentCopy = format["%1%2",_baseCopy,_line];
                ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

                sleep 10;
                deleteMarkerLocal _m1;
                deleteMarkerLocal _m2;
            };

            private["_sortedShorePositions","_nearestShorePosition"];

            _sortedShorePositions = [_playerSectorData, "terrain", [getPos player,"shore"]] call ALIVE_fnc_sectorDataSort;

            if(count _sortedShorePositions > 0) then {
            	_nearestShorePosition = _sortedShorePositions select 0;
            	_m2 = ["Nearest Shore",_nearestShorePosition,[1,1],"ColorKhaki"] call _createMarker;

            	_line = "<t size='1'>Current analysis: nearest shore position</t><br/><br/>";
                _currentCopy = format["%1%2",_baseCopy,_line];
                ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            	sleep 10;
            	deleteMarkerLocal _m2;
            };

            private["_sortedSeaPositions","_nearestSeaPosition"];

            _sortedSeaPositions = [_playerSectorData, "terrain", [getPos player,"sea"]] call ALIVE_fnc_sectorDataSort;

            if(count _sortedSeaPositions > 0) then {
            	_nearestSeaPosition = _sortedSeaPositions select 0;
            	_m3 = ["Nearest Sea",_nearestSeaPosition,[1,1],"ColorBlue"] call _createMarker;

            	_line = "<t size='1'>Current analysis: nearest sea position</t><br/><br/>";
                _currentCopy = format["%1%2",_baseCopy,_line];
                ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            	sleep 10;
            	deleteMarkerLocal _m3;
            };


            [ALIVE_sectorPlotter, "plot", [[_playerSector], "bestPlaces"]] call ALIVE_fnc_plotSectors;

            _line = "<t size='1'>Current analysis: environment types</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;

            private["_sortedForestPositions","_nearestForestPosition"];

            _sortedForestPositions = [_playerSectorData, "bestPlaces", [getPos player,"forest"]] call ALIVE_fnc_sectorDataSort;

            if(count _sortedForestPositions > 0) then {
                _nearestForestPosition = _sortedForestPositions select 0;
                _m1 = ["Nearest Vegetation",_nearestForestPosition,[1,1],"ColorGreen"] call _createMarker;

                _line = "<t size='1'>Current analysis: nearest vegetation</t><br/><br/>";
                _currentCopy = format["%1%2",_baseCopy,_line];
                ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

                sleep 10;
                deleteMarkerLocal _m1;
            };

            private["_sortedHillPositions","_nearestHillPosition"];

            _sortedHillPositions = [_playerSectorData, "bestPlaces", [getPos player,"exposedHills"]] call ALIVE_fnc_sectorDataSort;

            if(count _sortedHillPositions > 0) then {
            	_nearestHillPosition = _sortedHillPositions select 0;
            	_m3 = ["Nearest Exposed Hill",_nearestHillPosition,[1,1],"ColorOrange"] call _createMarker;

            	_line = "<t size='1'>Current analysis: nearest exposed hill</t><br/><br/>";
                _currentCopy = format["%1%2",_baseCopy,_line];
                ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            	sleep 10;
            	deleteMarkerLocal _m3;
            };


            [ALIVE_sectorPlotter, "plot", [[_playerSector], "flatEmpty"]] call ALIVE_fnc_plotSectors;

            _line = "<t size='1'>Current analysis: empty spaces</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;

            private["_sortedFlatEmptyPositions","_nearestFlatEmptyPosition"];

            _sortedFlatEmptyPositions = [_playerSectorData, "flatEmpty", [getPos player]] call ALIVE_fnc_sectorDataSort;

            if(count _sortedFlatEmptyPositions > 0) then {
            	_nearestFlatEmptyPosition = _sortedFlatEmptyPositions select 0;
            	_m = ["Nearest Empty Space",_nearestFlatEmptyPosition,[1,1],"ColorRed"] call _createMarker;

            	_line = "<t size='1'>Current analysis: nearest empty space</t><br/><br/>";
                _currentCopy = format["%1%2",_baseCopy,_line];
                ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            	sleep 10;
                deleteMarkerLocal _m;
            };


            [ALIVE_sectorPlotter, "plot", [[_playerSector], "roads"]] call ALIVE_fnc_plotSectors;

            _line = "<t size='1'>Current analysis: roads</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;

            private["_sortedRoadPositions","_nearestRoadPosition"];

            _sortedRoadPositions = [_playerSectorData, "roads", [getPos player, "road"]] call ALIVE_fnc_sectorDataSort;

            if(count _sortedRoadPositions > 0) then {
            	_nearestRoadPosition = _sortedRoadPositions select 0;
            	_m = ["Nearest Road",(_nearestRoadPosition select 0),[1,1],"ColorGreen"] call _createMarker;

            	_line = "<t size='1'>Current analysis: nearest road</t><br/><br/>";
                _currentCopy = format["%1%2",_baseCopy,_line];
                ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            	sleep 10;
            	deleteMarkerLocal _m;
            };

            private["_sortedCrossroadPositions","_nearestCrossroadPosition"];

            _sortedCrossroadPositions = [_playerSectorData, "roads", [getPos player, "crossroad"]] call ALIVE_fnc_sectorDataSort;

            if(count _sortedCrossroadPositions > 0) then {
            	_nearestCrossroadPosition = _sortedCrossroadPositions select 0;
            	_m = ["Nearest Crossroad",(_nearestCrossroadPosition select 0),[1,1],"ColorOrange"] call _createMarker;

            	_line = "<t size='1'>Current analysis: nearest crossroad</t><br/><br/>";
                _currentCopy = format["%1%2",_baseCopy,_line];
                ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            	sleep 10;
            	deleteMarkerLocal _m;
            };

            private["_sortedTerminusPositions","_nearestTerminusPosition"];

            _sortedTerminusPositions = [_playerSectorData, "roads", [getPos player, "terminus"]] call ALIVE_fnc_sectorDataSort;

            if(count _sortedTerminusPositions > 0) then {
            	_nearestTerminusPosition = _sortedTerminusPositions select 0;
            	_m = ["Nearest Terminus",(_nearestTerminusPosition select 0),[1,1],"ColorRed"] call _createMarker;

            	_line = "<t size='1'>Current analysis: nearest road terminus</t><br/><br/>";
                _currentCopy = format["%1%2",_baseCopy,_line];
                ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            	sleep 10;
            	deleteMarkerLocal _m;
            };

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;


            _line = "<t size='1'>Demonstration complete</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

        };

    };

    case "deactivateSelectionAnalysis": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;

        _logic setVariable ["selectionState","Technology"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionProfiles": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7' >Virtual AI System</t><br/><br/>";
            _line2 = "<t size='1'>To enable truly whole map operations, the ALiVE development team has created a group and vehicle profiling system that stores the complete state of in game AI objects.</t><br/><br/>";
            _line3 = "<t size='1'>These objects can then be spawned or despawned depending on distance to players. This system goes beyond traditional unit caching systems, to store a representative data structure describing units.</t><br/><br/>";
            _line4 = "<t size='1'>Caching for performance is one obvious benefit of the profile system but it also enables continued simulation of the virtualised profiles.</t><br/><br/>";
            _line5 = "<t size='1'>The map is now displaying the profile system at work. Full opacity markers denote spawned or visual groups and vehicles. Transparent markers represent virtualised, simulated units.</t><br/><br/>";
            _line6 = "<t size='1'>Virtual waypoints are display using x markers. The profile system seamlessly translates virtual waypoints to in game waypoints when profiles are spawned and despawned.</t><br/><br/>";
            _line7 = "<t size='1'>Another benefit to the profile system is that it provides a convenient format for saving the state of the game using the ALiVE persistent central database.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5,_line6,_line7];

            ["openMapFull",[_logic,"handleMenuCallback","Profiles"]] call ALIVE_fnc_displayMenu;
            ["setFullMapText",_baseCopy] call ALIVE_fnc_displayMenu;

            private["_mapSize","_mapCenter"];

            _mapSize = [] call ALIVE_fnc_getMapBounds;
            _mapCenter = [(_mapSize/2),(_mapSize/2)];
            ["setFullMapAnimation",[0.5,0.7,_mapCenter]] call ALIVE_fnc_displayMenu;

            [ALIVE_profileHandler, "debug", true] call ALIVE_fnc_profileHandler;

        };

    };

    case "deactivateSelectionProfiles": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        [ALIVE_profileHandler, "debug", false] call ALIVE_fnc_profileHandler;

        _logic setVariable ["selectionState","Technology"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionOpcom": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7' >OPCOM</t><br/><br/>";
            _line2 = "<t size='1'>The AI Operation Commanders (OPCOM) are intelligent battlefield commanders that control an entire factions strategy, tactics and logistics.</t><br/><br/>";
            _line3 = "<t size='1'>OPCOM prioritises a list of objectives and then plans and executes missions with available units. Op Commanders will react to the changing environment and attack, defend, withdraw or resupply depending on the current tactical situation. OPCOM continues to work with profiled groups, controlling a virtual battlefield out of visual range of players.</t><br/><br/>";
            _line4 = "<t size='1'>OPCOM consists of two core elements: Operational Command (OPCOM) and Tactical Command (TACOM). OPCOM takes the objectives of any synced Military or Civilian Placement modules and prioritises them depending on the user defined variables. It also regularly analyses the map, relative troop strengths and available assets required to capture and hold objectives in its area of operations. OPCOM gives missions to TACOM, which in turn executes the tactical level orders to units and reports back its state once that mission is complete.</t><br/><br/>";
            _line5 = "<t size='1'>OPCOM is a Virtual AI Commander, as it controls only profiled groups. TACOM is a low level tactical commander that deals with Visual AI groups when players are nearby. This means it is possible to transfer the status of groups and objectives seamlessly between the Visual (spawned) Layer and the Virtual (unspawned or cached) Layer. This allows huge ongoing virtual battles, from offensive operations with blazing battlefronts to insurgency deployments with a high degree of realism and minimal impact on performance.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5];

            ["openMapFull",[_logic,"handleMenuCallback","Opcom"]] call ALIVE_fnc_displayMenu;
            ["setFullMapText",_baseCopy] call ALIVE_fnc_displayMenu;

            private["_mapSize","_mapCenter"];

            _mapSize = [] call ALIVE_fnc_getMapBounds;
            _mapCenter = [(_mapSize/2),(_mapSize/2)];
            ["setFullMapAnimation",[0.5,0.7,_mapCenter]] call ALIVE_fnc_displayMenu;

            private["_moduleType","_handler","_objectives","_side","_sideDisplay","_line","_currentCopy","_profiles","_markers","_profileID","_profile"];

            {
                _moduleType = _x getVariable "moduleType";
                if!(isNil "_moduleType") then {

                    if(_moduleType == "ALIVE_OPCOM") then {

                        _handler = _x getVariable "handler";
                        _objectives = [_handler,"objectives"] call ALIVE_fnc_hashGet;
                        _side = [_handler,"side"] call ALIVE_fnc_hashGet;
                        _sideDisplay = [_side] call ALIVE_fnc_sideTextToLong;

                        if!(isNil "_profiles") then {
                            {
                                _profileID = _x;
                                _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
                                if !(isnil "_profile") then {
                                    [_profile, "deleteMarker"] call ALIVE_fnc_profileEntity;
                                };
                            } forEach _profiles;

                            {
                                deleteMarker _x;
                            } forEach _markers;
                        };

                        sleep 1;

                        _line = format["<t size='1'>Currently viewing OPCOM strategic view for %1</t><br/><br/>",_sideDisplay];
                        _currentCopy = format["%1%2",_baseCopy,_line];
                        ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

                        private ["_center","_size","_priority","_type","_state","_section","_objectiveID","_alpha","_marker","_color","_dir","_position","_icon","_text","_m"];

                        _color = "ColorYellow";

                        // set the side color
                        switch(_side) do {
                            case "EAST":{
                                _color = "ColorRed";
                            };
                            case "WEST":{
                                _color = "ColorBlue";
                            };
                            case "CIV":{
                                _color = "ColorYellow";
                            };
                            case "GUER":{
                                _color = "ColorGreen";
                            };
                            default {
                                _color = "ColorYellow";
                            };
                        };

                        _profiles = [];
                        _markers = [];

                        {
                            _center = [_x,"center"] call ALIVE_fnc_hashGet;
                            _size = [_x,"size"] call ALIVE_fnc_hashGet;
                            _priority = [_x,"priority"] call ALIVE_fnc_hashGet;
                            _type = [_x,"type"] call ALIVE_fnc_hashGet;
                            _state = [_x,"tacom_state"] call ALIVE_fnc_hashGet;
                            _section = [_x,"section"] call ALIVE_fnc_hashGet;
                            _objectiveID = [_x,"objectiveID"] call ALIVE_fnc_hashGet;

                            _alpha = 1;

                            if!(isNil "_section") then {

                                // create the profile marker
                                {
                                    _profileID = _x;
                                    _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
                                    if !(isnil "_profile") then {
                                        _position = _profile select 2 select 2;

                                        if!(surfaceIsWater _position) then {
                                            _m = [_profile, "createMarker", [_alpha]] call ALIVE_fnc_profileEntity;
                                            _markers = _markers + _m;
                                            _profiles set [count _profiles, _profileID];
                                        };

                                        _dir = [_position, _center] call BIS_fnc_dirTo;
                                    };
                                } forEach _section;
                            };


                            // create the objective area marker
                            _m = createMarker [format[MTEMPLATE, _objectiveID], _center];
                            _m setMarkerShape "Ellipse";
                            _m setMarkerBrush "FDiagonal";
                            _m setMarkerSize [_size, _size];
                            _m setMarkerColor _color;
                            _m setMarkerAlpha _alpha;

                            _markers = _markers + [_m];

                            _icon = "EMPTY";
                            _text = "";

                            if!(isNil "_state") then {
                                switch(_state) do {
                                    case "reserve":{
                                        _icon = "mil_marker";
                                        _text = " occupied";
                                    };
                                    case "defend":{
                                        _icon = "mil_marker";
                                        _text = " occupied";
                                    };
                                    case "recon":{

                                        // create direction marker
                                        _m = createMarker [format[MTEMPLATE, format["%1_dir", _objectiveID]], [_position, 100, _dir] call BIS_fnc_relPos];
                                        _m setMarkerShape "ICON";
                                        _m setMarkerSize [0.5,0.5];
                                        _m setMarkerType "mil_arrow";
                                        _m setMarkerColor _color;
                                        _m setMarkerAlpha _alpha;
                                        _m setMarkerDir _dir;

                                        _markers = _markers + [_m];

                                        _icon = "EMPTY";
                                        _text = " sighting";
                                    };
                                    case "capture":{

                                        // create direction marker
                                        _m = createMarker [format[MTEMPLATE, format["%1_dir", _objectiveID]], [_position, 100, _dir] call BIS_fnc_relPos];
                                        _m setMarkerShape "ICON";
                                        _m setMarkerSize [0.5,0.5];
                                        _m setMarkerType "mil_arrow2";
                                        _m setMarkerColor _color;
                                        _m setMarkerAlpha _alpha;
                                        _m setMarkerDir _dir;

                                        _markers = _markers + [_m];

                                        _icon = "mil_warning";
                                        _text = " captured";
                                    };
                                };
                            };

                            // create type marker
                            _m = createMarker [format[MTEMPLATE, format["%1_type", _objectiveID]], _center];
                            _m setMarkerShape "ICON";
                            _m setMarkerSize [0.5, 0.5];
                            _m setMarkerType _icon;
                            _m setMarkerColor _color;
                            _m setMarkerAlpha _alpha;
                            _m setMarkerText _text;

                            _markers = _markers + [_m];

                        } forEach _objectives;

                        _logic setVariable ["opcomMarkers",_markers];
                        _logic setVariable ["opcomProfiles",_profiles];

                        sleep 20;
                    };
                }
            } forEach (entities "Module_F");


        };

    };

    case "deactivateSelectionOpcom": {

        private["_markers","_profiles","_profileID","_profile"];

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _markers = _logic getVariable "opcomMarkers";
        _profiles = _logic getVariable "opcomProfiles";

        {
            _profileID = _x;
            _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
            if !(isnil "_profile") then {
                [_profile, "deleteMarker"] call ALIVE_fnc_profileEntity;
            };
        } forEach _profiles;

        {
            deleteMarker _x;
        } forEach _markers;

        _logic setVariable ["selectionState","Technology"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionObjective": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7' >Objective Analysis</t><br/><br/>";
            _line2 = "<t size='1'>To enable the AI Operational Commanders (OPCOM) to devise a battle plan they need to know what objectives exist on a given map, what priority the objectives are, and the type and composition of the objectives.</t><br/><br/>";
            _line3 = "<t size='1'>ALiVE uses an in depth indexing of ARMA maps to evaluate clusters of building objects to determine the size, priority and composition of map objectives.</t><br/><br/>";
            _line4 = "<t size='1'>In this demonstration is the display of various objective types in the current mission and map.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openMapFull",[_logic,"handleMenuCallback","Objective"]] call ALIVE_fnc_displayMenu;
            ["setFullMapText",_baseCopy] call ALIVE_fnc_displayMenu;

            private["_mapSize","_mapCenter"];

            _mapSize = [] call ALIVE_fnc_getMapBounds;
            _mapCenter = [(_mapSize/2),(_mapSize/2)];
            ["setFullMapAnimation",[0.5,0.7,_mapCenter]] call ALIVE_fnc_displayMenu;

            private["_allSectors","_landSectors","_playerSector","_surroundingSectors","_highSectors","_playerSectorData","_playerSectorCenterPosition","_line","_currentCopy"];

            _allSectors = [ALIVE_sectorGrid, "sectors"] call ALIVE_fnc_sectorGrid;
            _landSectors = [_allSectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;
            _playerSector = [ALIVE_sectorGrid, "positionToSector", getPos player] call ALIVE_fnc_sectorGrid;
            _playerSectorData = [_playerSector, "data"] call ALIVE_fnc_hashGet;
            _playerSectorCenterPosition = [_playerSector, "center"] call ALIVE_fnc_sector;
            _surroundingSectors = [ALIVE_sectorGrid, "surroundingSectors", getPos player] call ALIVE_fnc_sectorGrid;


            [ALIVE_sectorPlotter, "plot", [_landSectors, "clustersMil"]] call ALIVE_fnc_plotSectors;

            _line1 = "<t size='1'>Displaying military objectives</t><br/><br/>";
            _line2 = "<t size='1'>Green: military infrastructure</t><br/>";
            _line3 = "<t size='1'>Blue: military air infrastructure</t><br/>";
            _line4 = "<t size='1'>Orange: military helicopter infrastructure</t><br/>";
            _currentCopy = format["%1%2%3%4%5",_baseCopy,_line1,_line2,_line3,_line4];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;


            [ALIVE_sectorPlotter, "plot", [_landSectors, "clustersCiv"]] call ALIVE_fnc_plotSectors;

            _line1 = "<t size='1'>Displaying civilian objectives</t><br/><br/>";
            _line2 = "<t size='1'>Black / Green: civilian settlements</t><br/>";
            _line3 = "<t size='1'>Yellow: civilian power infrastructure</t><br/>";
            _line4 = "<t size='1'>White: civilian communications infrastructure</t><br/>";
            _line5 = "<t size='1'>Blue: civilian marine infrastructure</t><br/>";
            _line6 = "<t size='1'>Orange: civilian fuel infrastructure</t><br/>";
            _currentCopy = format["%1%2%3%4%5%6%7",_baseCopy,_line1,_line2,_line3,_line4,_line5,_line6];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;

            _line = "<t size='1'>Demonstration complete</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;


        };

    };

    case "deactivateSelectionObjective": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;

        _logic setVariable ["selectionState","Technology"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionBattlefield": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7' >Battlefield Analysis</t><br/><br/>";
            _line2 = "<t size='1'>Current events on the battlefield are key information for OPCOM and other ALiVE systems, allowing real time adjustments to strategy and planning.</t><br/><br/>";
            _line3 = "<t size='1'>An event system connects the ALiVE modules to ensure that when something of interest occurs on the battlefield all interested systems can receive the information.</t><br/><br/>";
            _line4 = "<t size='1'>In this demonstration is displayed various on demand battlefield analysis routines.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openMapFull",[_logic,"handleMenuCallback","Battlefield"]] call ALIVE_fnc_displayMenu;
            ["setFullMapText",_baseCopy] call ALIVE_fnc_displayMenu;

            private["_mapSize","_mapCenter"];

            _mapSize = [] call ALIVE_fnc_getMapBounds;
            _mapCenter = [(_mapSize/2),(_mapSize/2)];
            ["setFullMapAnimation",[0.5,0.7,_mapCenter]] call ALIVE_fnc_displayMenu;

            private["_allSectors","_landSectors","_playerSector","_surroundingSectors","_highSectors","_playerSectorData","_playerSectorCenterPosition","_line","_currentCopy"];

            _allSectors = [ALIVE_sectorGrid, "sectors"] call ALIVE_fnc_sectorGrid;
            _landSectors = [_allSectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;
            _playerSector = [ALIVE_sectorGrid, "positionToSector", getPos player] call ALIVE_fnc_sectorGrid;
            _playerSectorData = [_playerSector, "data"] call ALIVE_fnc_hashGet;
            _playerSectorCenterPosition = [_playerSector, "center"] call ALIVE_fnc_sector;
            _surroundingSectors = [ALIVE_sectorGrid, "surroundingSectors", getPos player] call ALIVE_fnc_sectorGrid;


            [ALIVE_sectorPlotter, "plot", [_landSectors, "activeClusters"]] call ALIVE_fnc_plotSectors;

            _line = "<t size='1'>Displaying active objectives and their occupation state</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;


            [ALIVE_sectorPlotter, "plot", [_landSectors, "casualties"]] call ALIVE_fnc_plotSectors;

            _line = "<t size='1'>Displaying sector casualty levels</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;


            _line = "<t size='1'>Demonstration complete</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullMapText",_currentCopy] call ALIVE_fnc_displayMenu;


        };

    };

    case "deactivateSelectionBattlefield": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        [ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;

        _logic setVariable ["selectionState","Technology"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionData": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Central Persistence Database</t><br/><br/>";
            _line2 = "<t size='1'>In order to store in game statistics, live operation feeds, player gear, and all other persistence layer operations, the ALiVE team has developed technology to store data in a central database.</t><br/><br/>";
            _line3 = "<t size='1'>Built using modern data transfer and storage technologies (JSON,NoSQL) the ALiVE data tech provides seamless transfer from in game to storage and storage back to game.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openFull",[_logic,"handleMenuCallback","Data"]] call ALIVE_fnc_displayMenu;
            ["setFullText",_baseCopy] call ALIVE_fnc_displayMenu;

        };

    };

    case "deactivateSelectionData": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Technology"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionWarroom": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7' >WarRoom</t><br/><br/>";
            _line2 = "<t size='1'>ALiVE introduces revolutionary web services integration by streaming ARMA 3 in game data to our ALiVE War Room web platform. War Room allows players and groups to review current and past operations as well keep track of individual and group performance statistics.</t><br/><br/>";
            _line3 = "<t size='1'>War Room offers groups membership to a virtual task force operating across the various AO's offered by the ARMA 3 engine. War Room exposes task force wins, losses and leaderboards for performance. The platform provides live streaming capabilities for BLUFOR tracking, group management tools, after action reporting, and ALiVE module controls from the web.</t><br/><br/>";
            _line4 = "<t size='1'>Beside events, statistics and streaming, War Room provides the platform for persisting Multiplayer Campaigns. This allows groups to run 'multi-session operations' by storing game state to a cloud based database. Group admins can update campaign data via the War Room, such as adding map markers, objectives, editing loadouts or adding vehicles and units to the campaign - all via the web platform.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openImageFull",[_logic,"handleMenuCallback","Warroom"]] call ALIVE_fnc_displayMenu;
            ["setFullImageText",_baseCopy] call ALIVE_fnc_displayMenu;
            ["setFullImage","x\alive\addons\sys_tour\data\warroom1.paa"] call ALIVE_fnc_displayMenu;

            sleep 1;

            private["_line","_currentCopy"];

            _line = "<t size='1'>Image: WarRoom global operations map</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullImageText",_currentCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line = "<t size='1'>Image: Player stats overview</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullImageText",_currentCopy] call ALIVE_fnc_displayMenu;
            ["setFullImage","x\alive\addons\sys_tour\data\warroom2.paa"] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line = "<t size='1'>Image: Player experience</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullImageText",_currentCopy] call ALIVE_fnc_displayMenu;
            ["setFullImage","x\alive\addons\sys_tour\data\warroom3.paa"] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line = "<t size='1'>Image: Operation AAR</t><br/><br/>";
            _currentCopy = format["%1%2",_baseCopy,_line];
            ["setFullImageText",_currentCopy] call ALIVE_fnc_displayMenu;
            ["setFullImage","x\alive\addons\sys_tour\data\warroom4.paa"] call ALIVE_fnc_displayMenu;

        };

    };

    case "deactivateSelectionWarroom": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Technology"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionModuleOPCOM": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>AI Operation Commanders (OPCOM)</t><br/><br/>";
            _line2 = "<t size='1'>The OPCOM module prioritises a list of objectives and then plans and executes missions with available units. Op Commanders will react to the changing environment and attack, defend, withdraw or resupply depending on the current tactical situation. OPCOM continues to work with virtualised groups, controlling a virtual battlefield out of visual range of players.</t><br/><br/>";
            _line3 = "<t size='1'>OPCOM consists of two core elements: Operational Command (OPCOM) and Tactical Command (TACOM). OPCOM takes the objectives of any synced Military or Civilian Placement modules and prioritises them depending on the user defined variables. It also regularly analyses the map, relative troop strengths and available assets required to capture and hold objectives in its area of operations. OPCOM gives missions to TACOM, which in turn executes the tactical level orders to units and reports back its state once that mission is complete.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openFull",[_logic,"handleMenuCallback","ModuleOPCOM"]] call ALIVE_fnc_displayMenu;
            ["setFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            call BIS_fnc_VRFadeIn;

            _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

            ["openSplash",0.25] call ALIVE_fnc_displayMenu;
            ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

            hideObjectGlobal player;

            private["_opcomModules","_moduleType","_handler","_objectives","_side","_sideDisplay","_shuffledModules","_profiles","_sortedProfiles"];

            _opcomModules = [];

            {
                _moduleType = _x getVariable "moduleType";
                if!(isNil "_moduleType") then {

                    if(_moduleType == "ALIVE_OPCOM") then {
                        _opcomModules set [count _opcomModules,_x];
                    };
                };
            } forEach (entities "Module_F");

            _shuffledModules = [_opcomModules] call CBA_fnc_shuffle;

            _profiles = [];

            {

                _handler = _x getVariable "handler";
                _objectives = [_handler,"objectives"] call ALIVE_fnc_hashGet;

                {
                    private["_objective","_center","_section","_orders","_opcom_state","_tacom_state"];

                    _objective = _x;
                    _center = [_objective,"center"] call ALIVE_fnc_hashGet;
                    _section = [_objective,"section"] call ALIVE_fnc_hashGet;
                    _orders = [_objective,"opcom_orders"] call ALIVE_fnc_hashGet;
                    _opcom_state = [_objective,"opcom_state"] call ALIVE_fnc_hashGet;
                    _tacom_state = [_objective,"tacom_state"] call ALIVE_fnc_hashGet;

                    if!(isNil "_section") then {
                        {
                            private["_profileID","_profile","_position"];

                            _profileID = _x;
                            _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;

                            if !(isnil "_profile") then {

                                _position = _profile select 2 select 2;

                                if(_opcom_state == "idle") then {
                                    _profiles set [count _profiles,[_objective,_profileID,15000]];
                                }else{
                                    _profiles set [count _profiles,[_objective,_profileID,_center distance _position]];
                                };

                            };

                        } forEach _section;
                    };

                } forEach _objectives;

            } forEach _shuffledModules;


            _sortedProfiles = [_profiles,[],{_x select 2},"ASCEND"] call ALiVE_fnc_SortBy;


            {
                private["_center","_size","_priority","_type","_orders","_section","_objectiveID","_action","_objective","_nearestTownToObjective","_profileID"];

                _objective = _x select 0;
                _profileID = _x select 1;
                _center = [_objective,"center"] call ALIVE_fnc_hashGet;
                _size = [_objective,"size"] call ALIVE_fnc_hashGet;
                _priority = [_objective,"priority"] call ALIVE_fnc_hashGet;
                _type = [_objective,"type"] call ALIVE_fnc_hashGet;
                _orders = [_objective,"opcom_orders"] call ALIVE_fnc_hashGet;
                _section = [_objective,"section"] call ALIVE_fnc_hashGet;
                _objectiveID = [_objective,"objectiveID"] call ALIVE_fnc_hashGet;

                _action = "";
                _objective = "";
                _nearestTownToObjective = [_center] call ALIVE_fnc_taskGetNearestLocationName;

                if(_type == "MIL") then {
                    _objective = "Military objective";
                }else{
                    _objective = "Civilian objective";
                };

                if!(isNil "_orders") then {
                    switch(_orders) do {
                        case "attack":{
                            _action = format["<t>Ordered by OPCOM to attack %1 near %2</t>",_objective,_nearestTownToObjective];
                        };
                        case "defend":{
                            _action = format["<t>Ordered by OPCOM to defend %1 near %2</t>",_objective,_nearestTownToObjective];
                        };
                        case "recon":{
                            _action = format["<t>Ordered by OPCOM to recon %1 near %2</t>",_objective,_nearestTownToObjective];
                        };
                    };
                };


                private["_profile","_position","_faction","_line1","_group","_unit","_nearestTown","_factionName","_title","_text","_target","_duration"];

                _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;

                if !(isnil "_profile") then {


                    _faction = _profile select 2 select 29;

                    _position = _profile select 2 select 2;

                    _position = [_position, 50, random 360] call BIS_fnc_relPos;

                    if(surfaceIsWater _position) then {
                        _position = [_position] call ALIVE_fnc_getClosestLand;
                    };

                    player setPos _position;

                    waitUntil{_profile select 2 select 1};

                    _group = _profile select 2 select 13;
                    _unit = (units _group) call BIS_fnc_selectRandom;

                    _duration = 30;

                    if!(isNil "_unit") then {

                        _target = "RoadCone_L_F" createVehicle _center;
                        hideObjectGlobal _target;

                        [_logic, "createDynamicCamera", [_duration,player,_unit,_target]] call MAINCLASS;

                        ["closeSplash"] call ALIVE_fnc_displayMenu;

                        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;
                        _factionName = getText(configfile >> "CfgFactionClasses" >> _faction >> "displayName");

                        _title = "<t size='1.5' color='#68a7b7' shadow='1'>OPCOM Troops</t><br/>";
                        _text = format["%1<t>%2 group %3 near %4</t> %5",_title,_factionName,_group,_nearestTown,_action];

                        ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
                        ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;

                        sleep (_duration-2);

                        _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

                        call BIS_fnc_VRFadeIn;

                        ["openSplash",0.25] call ALIVE_fnc_displayMenu;
                        ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

                        deleteVehicle _target;

                        ["closeSideTopSmall"] call ALIVE_fnc_displayMenu;

                        [_logic, "deleteDynamicCamera"] call MAINCLASS;

                    };

                };

            } forEach _sortedProfiles;

        };


    };

    case "deactivateSelectionModuleOPCOM": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        if!(isNil "ALIVE_cameraType") then {
            if(ALIVE_cameraType == "CAMERA") then {
                if!(isNil "ALIVE_tourCamera") then {
                    [ALIVE_tourCamera,true] call ALIVE_fnc_stopCinematic;
                    [ALIVE_tourCamera] call ALIVE_fnc_removeCamera;
                };
            }else{

                [true] call ALIVE_fnc_revertCamera;
            };
        };

        player hideObjectGlobal false;

        ["closeSideTopSmall"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Modules"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionModulePlacement": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_moduleType","_placementModules"];

            _placementModules = [];

            {
                _moduleType = _x getVariable "moduleType";
                if!(isNil "_moduleType") then {
                    if(_moduleType == "ALIVE_MP" || _moduleType == "ALIVE_CMP") then {
                        _placementModules set [count _placementModules, _x];
                    };
                };
            } forEach (entities "Module_F");


            private["_module","_moduleType","_objectives","_faction","_objective","_position","_size","_playerPosition","_emptyPosition",
            "_camera","_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy","_nearestTown","_factionName",
            "_target","_title","_text","_duration"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Military Placement</t><br/><br/>";
            _line2 = "<t size='1'>The military placement modules place starting forces in areas defined by the mission maker.</t><br/><br/>";
            _line3 = "<t size='1'>Based on the given areas defined by the mission maker ALiVE will create forces in and around key military, civilian, or custom objectives.</t><br/><br/>";
            _line4 = "<t size='1'>Besides spawning forces defined by the mission maker, these modules can spawn land and air vehicles, ammo crates, and other ambient details. If static weapons are near, the modules will man them with units, and also garrison units in defensible positions.</t><br/><br/>";
            _line5 = "<t size='1'>The custom military placement module can also spawn ALiVE predefined compositions to give maps a fresh layout, or to populate baren map regions.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5];

            ["openFull",[_logic,"handleMenuCallback","ModulePlacement"]] call ALIVE_fnc_displayMenu;
            ["setFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

            //call BIS_fnc_VRFadeIn;

            ["openSplash",2] call ALIVE_fnc_displayMenu;
            ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

            player hideObjectGlobal true;

            {
                _module = _x;
                _moduleType = _module getVariable "moduleType";

                if(_moduleType == "ALIVE_MP") then {

                    _objectives = _module getVariable "objectives";
                    _faction = _module getVariable "faction";

                    {

                        _objective = _x;

                        _position = [_objective,"center"] call ALIVE_fnc_hashGet;
                        _size = [_objective,"size"] call ALIVE_fnc_hashGet;

                        _playerPosition = [_position, 50, random 360] call BIS_fnc_relPos;

                        if(surfaceIsWater _playerPosition) then {
                            _playerPosition = [_playerPosition] call ALIVE_fnc_getClosestLand;
                        };

                        player setPos _playerPosition;

                        sleep 4;

                        _target = "RoadCone_L_F" createVehicle _position;
                        _target hideObjectGlobal true;

                        _duration = 20;

                        ALIVE_cameraType = "CAMERA";

                        _randomPosition = [_position, 500, random(360)] call BIS_fnc_relPos;
                        _target2 = "RoadCone_L_F" createVehicle _randomPosition;
                        _target2 hideObjectGlobal true;

                        ALIVE_tourCamera = [_target2,false,"SATELITE"] call ALIVE_fnc_addCamera;
                        [ALIVE_tourCamera,true] call ALIVE_fnc_startCinematic;
                        //[ALIVE_tourCamera,_target2,_target,_duration] spawn ALIVE_fnc_panShot;
                        [ALIVE_tourCamera,_target,_duration] spawn ALIVE_fnc_flyInShot;


                        ["closeSplash"] call ALIVE_fnc_displayMenu;


                        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;
                        _factionName = getText(configfile >> "CfgFactionClasses" >> _faction >> "displayName");

                        _title = "<t size='1.5' color='#68a7b7' shadow='1'>Military Objective</t><br/>";
                        _text = format["%1<t>Objective near %2 initially held by: %3</t>",_title,_nearestTown,_factionName];

                        ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
                        ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;

                        sleep (_duration-4);

                        _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

                        call BIS_fnc_VRFadeIn;

                        ["openSplash",0.25] call ALIVE_fnc_displayMenu;
                        ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

                        deleteVehicle _target;
                        ["closeSideTopSmall"] call ALIVE_fnc_displayMenu;
                        [_logic, "deleteDynamicCamera"] call MAINCLASS;


                    } forEach _objectives;

                }else{

                    _objectives = _module getVariable "objectives";
                    _faction = _module getVariable "faction";

                    _objective = _objectives call BIS_fnc_selectRandom;

                    _position = [_objective,"center"] call ALIVE_fnc_hashGet;
                    _size = [_objective,"size"] call ALIVE_fnc_hashGet;

                    _playerPosition = [_position, 50, random 360] call BIS_fnc_relPos;

                    if(surfaceIsWater _playerPosition) then {
                        _playerPosition = [_playerPosition] call ALIVE_fnc_getClosestLand;
                    };

                    player setPos _playerPosition;

                    sleep 4;

                    _target = "RoadCone_L_F" createVehicle _position;
                    _target hideObjectGlobal true;

                    _duration = 20;

                    ALIVE_cameraType = "CAMERA";

                    _randomPosition = [_position, 500, random(360)] call BIS_fnc_relPos;
                    _target2 = "RoadCone_L_F" createVehicle _randomPosition;
                    _target2 hideObjectGlobal true;

                    ALIVE_tourCamera = [_target2,false,"BIRDS_EYE"] call ALIVE_fnc_addCamera;
                    [ALIVE_tourCamera,true] call ALIVE_fnc_startCinematic;
                    //[ALIVE_tourCamera,_target2,_target,_duration] spawn ALIVE_fnc_panShot;
                    [ALIVE_tourCamera,_target,_duration] spawn ALIVE_fnc_flyInShot;

                    ["closeSplash"] call ALIVE_fnc_displayMenu;

                    _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;
                    _factionName = getText(configfile >> "CfgFactionClasses" >> _faction >> "displayName");

                    _title = "<t size='1.5' color='#68a7b7' shadow='1'>Military Objective</t><br/>";
                    _text = format["%1<t>Objective near %2 initially held by: %3</t>",_title,_nearestTown,_factionName];

                    ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
                    ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;

                    sleep (_duration-4);

                    _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

                    call BIS_fnc_VRFadeIn;

                    ["openSplash",0.25] call ALIVE_fnc_displayMenu;
                    ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

                    deleteVehicle _target;
                    ["closeSideTopSmall"] call ALIVE_fnc_displayMenu;
                    [_logic, "deleteDynamicCamera"] call MAINCLASS;

                };

            } forEach _placementModules;

            ["closeSplash"] call ALIVE_fnc_displayMenu;

        };

    };

    case "deactivateSelectionModulePlacement": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        if!(isNil "ALIVE_cameraType") then {
            if(ALIVE_cameraType == "CAMERA") then {
                if!(isNil "ALIVE_tourCamera") then {
                    [ALIVE_tourCamera,true] call ALIVE_fnc_stopCinematic;
                    [ALIVE_tourCamera] call ALIVE_fnc_removeCamera;
                };
            }else{

                [true] call ALIVE_fnc_revertCamera;
            };
        };

        player hideObjectGlobal false;

        ["closeSideSubtitle"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Modules"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionModuleLogistics": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Military Logistics</t><br/><br/>";
            _line2 = "<t size='1'>The Battlefield Logistics System is responsible for maintaining operational effectiveness of all units in the Theatre of Operations, delivering resupplies and Battle Casualty Replacements to the front line.</t><br/><br/>";
            _line3 = "<t size='1'>BCRs require a suitable objective held by friendly forces where they will muster before moving to join front line units. OPCOM requests BCRs when Combat Effectiveness falls below acceptable levels.</t><br/><br/>";
            _line4 = "<t size='1'>The Logistics Commander (LOGCOM) assesses the tactical situation and determines the best location to bring in BCRs and then dispatches a convoy with the required troops and vehicles. Replacements may come in by Air or Land depending on the location and availability of landing sites and the type of replacements requested. Large airfields have a higher capacity to deliver logistics than small patrol bases.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openFull",[_logic,"handleMenuCallback","ModuleLogistics"]] call ALIVE_fnc_displayMenu;
            ["setFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            /*
            _line1 = "<t size='1.5' color='#68a7b7' align='center'>Finding logistics insertion...</t><br/><br/>";

            //call BIS_fnc_VRFadeIn;

            ["openSplash",2] call ALIVE_fnc_displayMenu;
            ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

            private["_position","_faction","_side","_forceMakeup","_event","_eventID","_logisticsModules","_logisticsModule","_moduleType",
            "_logisticsEvent","_eventState","_transportProfiles","_transportProfile","_position","_group","_leader","_vehicle","_factions",
            "_eventQueue","_forcePool"];

            _logisticsModules = [];

            {
                _moduleType = _x getVariable "moduleType";
                if!(isNil "_moduleType") then {

                    ["TYPE: %1",_moduleType] call ALIVE_fnc_dump;
                    if(_moduleType == "ALIVE_ML") then {
                        _logisticsModules set [count _logisticsModules, _x];
                    };
                };
            } forEach (entities "Module_F");

            _logisticsModule = _logisticsModules call BIS_fnc_selectRandom;

            if!(isNil "_logisticsModule") then {

                _side = _logisticsModule getVariable "side";
                _factions = _logisticsModule getVariable "factions";
                _faction = _factions select 0 select 1 select 0;
                _eventQueue = _logisticsModule getVariable "eventQueue";
                _forcePool = _logisticsModule getVariable "forcePool";

                _position = [getPos player, 20, 180] call BIS_fnc_relPos;

                _forceMakeup = [
                    3, // infantry
                    0, // motorised
                    0, // mechanised
                    0, // armour
                    0, // plane
                    0  // heli
                ];

                _event = ['LOGCOM_REQUEST', [_position,_faction,_side,_forceMakeup,"HELI_INSERT"],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                sleep 5;

                _logisticsEvent = [_eventQueue, _eventID] call ALIVE_fnc_hashGet;

                if!(isNil "_logisticsEvent") then {

                    waitUntil{
                        sleep 1;
                        _eventState = [_logisticsEvent,"state"] call ALIVE_fnc_hashGet;
                        (_eventState == "heliTransport" || _eventState == "eventComplete")
                    };

                    if(_eventState == "heliTransport") then {

                        _transportProfiles = [_logisticsEvent,"transportProfiles"] call ALIVE_fnc_hashGet;
                        _transportProfile = _transportProfiles call BIS_fnc_selectRandom;

                        _transportProfile = [ALIVE_profileHandler, "getProfile", _transportProfile] call ALIVE_fnc_profileHandler;
                        if!(isNil "_transportProfile") then {
                            _position = _transportProfile select 2 select 2;

                            player setPos _position;

                            waitUntil {(_transportProfile select 2 select 1)};

                            _group = _transportProfile select 2 select 13;
                            _leader = leader _group;
                            _vehicle = vehicle _leader;

                            ["closeSplash"] call ALIVE_fnc_displayMenu;

                            ALIVE_tourCamera = [player,false,"UAV"] call ALIVE_fnc_addCamera;
                            [ALIVE_tourCamera,true] call ALIVE_fnc_startCinematic;
                            [ALIVE_tourCamera,_vehicle,100] call ALIVE_fnc_chaseShot;
                        };
                    };
                };
            };
            
            ["closeSplash"] call ALIVE_fnc_displayMenu;
            */

        };

    };

    case "deactivateSelectionModuleLogistics": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        if!(isNil "ALIVE_tourCamera") then {

            [ALIVE_tourCamera,true] call ALIVE_fnc_stopCinematic;
            [ALIVE_tourCamera] call ALIVE_fnc_removeCamera;
        };

        ["closeSideSubtitle"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Modules"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionModuleCQB": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>CQB</t><br/><br/>";
            _line2 = "<t size='1'>The close quarters battle module automatically populates civilian and military buildings with dismounted infantry units when a player moves within range. The groups occupy buildings, patrol the streets and react to enemy presence.</t><br/><br/>";
            _line3 = "<t size='1'>CQB detects the dominant AI faction in the area (ignoring players) and spawns the appropriate units accordingly.</t><br/><br/>";
            _line4 = "<t size='1'>CQB units are not under control of OPCOM, they exist to provide exciting urban combat, building clearance, and general feeling of unease in built up areas controlled by enemy forces.</t><br/><br/>";
            _line5 = "<t size='1'></t><br/><br/>";
            _line6 = "<t size='1'></t><br/><br/>";
            _line7 = "<t size='1'></t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openFull",[_logic,"handleMenuCallback","ModuleCQB"]] call ALIVE_fnc_displayMenu;
            ["setFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            call BIS_fnc_VRFadeIn;

            _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

            ["openSplash",0.2] call ALIVE_fnc_displayMenu;
            ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

            private["_position","_faction","_side","_CQBModules","_CQBModule","_factions","_houses","_position","_group","_leader","_nearestTown","_factionName","_title","_text"];

            _CQBModules = [];

            {
                _CQBModules set [count _CQBModules, _x];
            } foreach (MOD(CQB) getVariable ["instances",[]]);

            _CQBModule = _CQBModules call BIS_fnc_selectRandom;

            if!(isNil "_CQBModule") then {

                _factions = _CQBModule getVariable "factions";
                _houses = _CQBModule getVariable "houses";

                {

                    if ([_x] call ALiVE_fnc_isHouseEnterable) then {

                        _position = position _x;

                        player setPos _position;
                        hideObjectGlobal player;

                        sleep 3;

                        waitUntil {
                            _group = _x getVariable "group";
                            !(isNil "_group")
                        };

                        _group = _x getVariable "group";

                        waitUntil {
                            _group = _x getVariable "group";
                            (typeName _group == "GROUP")
                        };

                        _leader = leader _group;

                        _faction = faction _leader;

                        [_leader,"FIRST_PERSON"] call ALIVE_fnc_switchCamera;

                        ["closeSplash"] call ALIVE_fnc_displayMenu;

                        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;
                        _factionName = getText(configfile >> "CfgFactionClasses" >> _faction >> "displayName");

                        _title = "<t size='1.5' color='#68a7b7' shadow='1'>CQB Units</t><br/>";
                        _text = format["%1<t>%2 units near %3</t><br/>",_title,_factionName,_nearestTown];

                        ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
                        ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;

                        sleep 30;

                        call BIS_fnc_VRFadeIn;

                        _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

                        ["openSplash",0.2] call ALIVE_fnc_displayMenu;
                        ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

                        [true] call ALIVE_fnc_revertCamera;

                        ["closeSideTopSmall"] call ALIVE_fnc_displayMenu;

                    };

                } forEach _houses;

            };

            ["closeSplash"] call ALIVE_fnc_displayMenu;

        };

    };

    case "deactivateSelectionModuleCQB": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        player hideObjectGlobal false;

        [true] call ALIVE_fnc_revertCamera;

        ["closeSideSubtitle"] call ALIVE_fnc_displayMenu;
        ["closeSideTopSmall"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Modules"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionModuleCivilian": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Civilian Population</t><br/><br/>";
            _line2 = "<t size='1'>The ambient civilian population modules allow mission designers to give some life to the empty settlements in the ARMA world.</t><br/><br/>";
            _line3 = "<t size='1'>The modules spawn civilian units and ambient vehicles when players are near towns and settlements large and small.</t><br/><br/>";
            _line4 = "<t size='1'>More than just a randomised movement simulator, the civilian agents all have tasks they are currently performing, which will change according to time of day, hostility levels and according to the whims of the civilian in question.</t><br/><br/>";
            _line5 = "<t size='1'>Killing civilians will adjust the settlements hostility to the player (or AI) faction. To much collateral damage and civilians may take up arms against their enemies.</t><br/><br/>";
            _line6 = "<t size='1'></t><br/><br/>";
            _line7 = "<t size='1'></t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5,_line6,_line7];

            ["openFull",[_logic,"handleMenuCallback","ModuleCivilian"]] call ALIVE_fnc_displayMenu;
            ["setFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            call BIS_fnc_VRFadeIn;

            _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

            ["openSplash",0.3] call ALIVE_fnc_displayMenu;
            ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

            private["_civilianAgents","_activeCommands","_profile","_type","_line1","_position","_unit",
            "_faction","_id","_duration","_nearestTown","_factionName","_title","_text","_command",
            "_commandName","_action","_target"];

            if!(isNil "ALIVE_agentHandler") then {
                _civilianAgents = [ALIVE_agentHandler,"getAgents"] call ALIVE_fnc_agentHandler;
                _activeCommands = [ALIVE_civCommandRouter,"commandState"] call ALIVE_fnc_hashGet;

                {
                    _profile = _x;

                    _type = _profile select 2 select 4;

                    if(_type == "agent") then {

                        _position = _profile select 2 select 2;

                        if(surfaceIsWater _position) then {
                            _position = [_position] call ALIVE_fnc_getClosestLand;
                        };

                        player setPos _position;
                        hideObjectGlobal player;

                        waitUntil{_profile select 2 select 1};

                        _unit = _profile select 2 select 5;
                        _faction = _profile select 2 select 7;
                        _id = _profile select 2 select 3;

                        _duration = 20;

                        _target = "RoadCone_L_F" createVehicle _position;
                        hideObjectGlobal _target;

                        if!(isNil "_unit") then {

                            _command = [_activeCommands,_id] call ALIVE_fnc_hashGet;
                            _command = _command select 1;

                            _commandName = _command select 0;

                            _action = "";
                            switch(_commandName) do {
                                case "ALIVE_fnc_cc_idle":{
                                    _action = "resting";
                                };
                                case "ALIVE_fnc_cc_campfire":{
                                    _action = "preparing campfire";
                                };
                                case "ALIVE_fnc_cc_driveTo":{
                                    _action = "driving";
                                };
                                case "ALIVE_fnc_cc_housework":{
                                    _action = "housework";
                                };
                                case "ALIVE_fnc_cc_joinGathering":{
                                    _action = "joining gathering";
                                };
                                case "ALIVE_fnc_cc_joinMeeting":{
                                    _action = "joining meeting";
                                };
                                case "ALIVE_fnc_cc_journey":{
                                    _action = "starting a journey";
                                };
                                case "ALIVE_fnc_cc_observe":{
                                    _action = "observing";
                                };
                                case "ALIVE_fnc_cc_randomMovement":{
                                    _action = "walking";
                                };
                                case "ALIVE_fnc_cc_rogue":{
                                    _action = "going rogue";
                                };
                                case "ALIVE_fnc_cc_sleep":{
                                    _action = "sleeping";
                                };
                                case "ALIVE_fnc_cc_startGathering":{
                                    _action = "starting a gathering";
                                };
                                case "ALIVE_fnc_cc_startMeeting":{
                                    _action = "starting a meeting";
                                };
                                case "ALIVE_fnc_cc_suicide":{
                                    _action = "planning a suicide bombing";
                                };
                            };

                            [_logic, "createDynamicCamera", [_duration,player,_unit,_target]] call MAINCLASS;

                            _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;
                            _factionName = getText(configfile >> "CfgFactionClasses" >> _faction >> "displayName");

                            _title = "<t size='1.5' color='#68a7b7' shadow='1'>Civilian</t><br/>";
                            _text = format["%1<t>%2 is %3 near %4</t><br/>",_title,name _unit,_action,_nearestTown];

                            ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
                            ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;

                            ["closeSplash"] call ALIVE_fnc_displayMenu;

                            sleep _duration;

                            call BIS_fnc_VRFadeIn;

                            _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

                            ["openSplash",0.3] call ALIVE_fnc_displayMenu;
                            ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

                            deleteVehicle _target;

                            ["closeSideTopSmall"] call ALIVE_fnc_displayMenu;
                            [_logic, "deleteDynamicCamera"] call MAINCLASS;
                        };
                    };

                } forEach (_civilianAgents select 2);

                ["closeSplash"] call ALIVE_fnc_displayMenu;

            };

        };

    };

    case "deactivateSelectionModuleCivilian": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        if!(isNil "ALIVE_cameraType") then {
            if(ALIVE_cameraType == "CAMERA") then {
                if!(isNil "ALIVE_tourCamera") then {
                    [ALIVE_tourCamera,true] call ALIVE_fnc_stopCinematic;
                    [ALIVE_tourCamera] call ALIVE_fnc_removeCamera;
                };
            }else{

                [true] call ALIVE_fnc_revertCamera;
            };
        };

        ["closeSideSubtitle"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Modules"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionModuleCombatSupport": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>The combat support modules allow mission makers to add a variety of AI piloted support vehicles available to players in their missions via an immersive and intuitive interface in game.</t><br/><br/>";
            _line3 = "<t size='1'>Combat support types include:</t><br/><br/>";
            _line4 = "<t size='1'>CAS - Close Air Support attack helicopters or fast air</t><br/><br/>";
            _line5 = "<t size='1'>Transport - On demand helicopter transport and logistics</t><br/><br/>";
            _line6 = "<t size='1'>Artillery - Offensive support from artillery units and mortar emplacements</t><br/><br/>";
            _line7 = "<t size='1'>In mission these various support types are requested via the Combat Support tablet.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5,_line6,_line7];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            ["radio"] call ALIVE_fnc_radioAction;

            sleep 1;

            waitUntil { sleep 1; _display = findDisplay 655555;(isNull _display)};

            ["closeSideFull"] call ALIVE_fnc_displayMenu;

            [_logic,"deactivateSelectionModuleCombatSupport"] call MAINCLASS;

        };

    };

    case "deactivateSelectionModuleCombatSupport": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Modules"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionModuleResupply": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Resupply</t><br/><br/>";
            _line2 = "<t size='1'>The player resupply module allows players to make resupply requests from LOGCOM in the same way that OPCOM will request reinforcements (and from the same reinforcement pool)</t><br/><br/>";
            _line3 = "<t size='1'>Providing an interface for players to request new vehicles, weapons, defence stores and AI teams from the logistics Force Pool, the resupply module provides realistic convoy and air insertion of supplies and forces as directed by players.</t><br/><br/>";
            _line4 = "<t size='1'></t><br/><br/>";
            _line5 = "<t size='1'></t><br/><br/>";
            _line6 = "<t size='1'></t><br/><br/>";
            _line7 = "<t size='1'></t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5,_line6,_line7];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            ["OPEN",[]] call ALIVE_fnc_PRTabletOnAction;

            sleep 1;

            waitUntil { sleep 1; _display = findDisplay 60001;(isNull _display)};

            ["closeSideFull"] call ALIVE_fnc_displayMenu;

            [_logic,"deactivateSelectionModuleResupply"] call MAINCLASS;

        };

    };

    case "deactivateSelectionModuleResupply": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Modules"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionModuleC2": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_line8","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>C2ISTAR</t><br/><br/>";
            _line2 = "<t size='1'>The C2ISTAR module provides a set of tools for the player to use for Command and Control as well as various Intelligence, Surveillance, Target Acquisition and Reconnaissance functions.</t><br/><br/>";
            _line3 = "<t size='1'>Functions include:</t><br/><br/>";
            _line4 = "<t size='1'>Player created and managed tasks.</t><br/><br/>";
            _line5 = "<t size='1'>OPCOM generated tasks.</t><br/><br/>";
            _line6 = "<t size='1'>SITREP reporting</t><br/><br/>";
            _line7 = "<t size='1'>PATROLREP reporting</t><br/><br/>";
            _line8 = "<t size='1'>Tasks, and reports can be persisted by the ALiVE persistence system so they are recreated on server restart and join in progress players.</t><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5,_line6,_line7,_line8];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            ["OPEN",[]] call ALIVE_fnc_C2TabletOnAction;

            sleep 1;

            waitUntil { sleep 1; _display = findDisplay 70001;(isNull _display)};

            ["closeSideFull"] call ALIVE_fnc_displayMenu;

            [_logic,"deactivateSelectionModuleC2"] call MAINCLASS;

        };

    };

    case "deactivateSelectionModuleC2": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Modules"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionJoin": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_opcomModules","_moduleType","_handler","_objectives","_side","_sideDisplay","_shuffledModules","_line1"];

            _line1 = "<t size='1.5' color='#68a7b7' align='center'>Moving position...</t><br/><br/>";

            ["openSplash",0.25] call ALIVE_fnc_displayMenu;
            ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

            _opcomModules = [];

            {
                _moduleType = _x getVariable "moduleType";
                if!(isNil "_moduleType") then {

                    if(_moduleType == "ALIVE_OPCOM") then {
                        _opcomModules set [count _opcomModules,_x];
                    };
                };
            } forEach (entities "Module_F");

            _shuffledModules = [_opcomModules] call CBA_fnc_shuffle;

            scopeName "main";

            {

                _handler = _x getVariable "handler";
                _objectives = [_handler,"objectives"] call ALIVE_fnc_hashGet;
                _side = [_handler,"side"] call ALIVE_fnc_hashGet;
                _sideDisplay = [_side] call ALIVE_fnc_sideTextToLong;

                {
                    private["_center","_size","_priority","_type","_orders","_section","_objectiveID","_action","_objective","_nearestTownToObjective"];

                    _center = [_x,"center"] call ALIVE_fnc_hashGet;
                    _size = [_x,"size"] call ALIVE_fnc_hashGet;
                    _priority = [_x,"priority"] call ALIVE_fnc_hashGet;
                    _type = [_x,"type"] call ALIVE_fnc_hashGet;
                    _orders = [_x,"opcom_orders"] call ALIVE_fnc_hashGet;
                    _section = [_x,"section"] call ALIVE_fnc_hashGet;
                    _objectiveID = [_x,"objectiveID"] call ALIVE_fnc_hashGet;

                    _action = "";
                    _objective = "";

                    if(_orders == "attack") then {
                        if!(isNil "_section") then {

                            private["_profileID","_profile","_position","_faction","_line1","_group","_unit","_nearestTown","_factionName","_title","_text","_target","_duration"];

                            _profileID = _section call BIS_fnc_selectRandom;
                            _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;

                            if !(isnil "_profile") then {

                                _faction = _profile select 2 select 29;
                                _position = _profile select 2 select 2;
                                _vehiclesInCommandOf = _profile select 2 select 8;

                                _profile call ALIVE_fnc_inspectHash;

                                if(count _vehiclesInCommandOf == 0) then {

                                    _position = [_position, 50, random 360] call BIS_fnc_relPos;

                                    if(surfaceIsWater _position) then {
                                        _position = [_position] call ALIVE_fnc_getClosestLand;
                                    };

                                    _profile call ALIVE_fnc_inspectHash;

                                    player setPos _position;

                                    waitUntil{_profile select 2 select 1};

                                    sleep 2;

                                    _group = _profile select 2 select 13;
                                    _unit = (units _group) call BIS_fnc_selectRandom;

                                    _duration = 1000;

                                    if!(isNil "_unit") then {

                                        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;
                                        _factionName = getText(configfile >> "CfgFactionClasses" >> _faction >> "displayName");

                                        _title = "<t size='1.5' color='#68a7b7' shadow='1'>Joining Group</t><br/>";
                                        _text = format["%1<t>%2 group %3 near %4</t> %5",_title,_factionName,_group,_nearestTown,_action];

                                        ["openSideTopSmall"] call ALIVE_fnc_displayMenu;
                                        ["setSideTopSmallText",_text] call ALIVE_fnc_displayMenu;

                                        player remoteControl _unit;
                                        _unit enableFatigue false;

                                        [_unit,"FIRST_PERSON"] call ALIVE_fnc_switchCamera;

                                        player hideObjectGlobal true;

                                        ["closeSplash"] call ALIVE_fnc_displayMenu;

                                        waitUntil{
                                            sleep 1;
                                            if((player distance _unit) > 100) then {
                                                //_newPosition = [getPos _unit, 10, random 360] call BIS_fnc_relPos;
                                                player setPos (position _unit);
                                            };
                                            !(alive _unit)
                                        };

                                        _line1 = "<t size='1.5' color='#68a7b7' align='center'>You have been killed...</t><br/><br/>";

                                        ["openSplash",0.25] call ALIVE_fnc_displayMenu;
                                        ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

                                        objNull remoteControl _unit;

                                        [true] call ALIVE_fnc_revertCamera;

                                        sleep 2;

                                        breakTo "main";

                                    };

                                };

                            };

                        };
                    };

                } forEach _objectives;

            } forEach _shuffledModules;

            [_logic,"deactivateSelectionJoin"] call MAINCLASS;
        };

    };

    case "deactivateSelectionJoin": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        player hideObjectGlobal false;

        ["closeSplash"] call ALIVE_fnc_displayMenu;
        ["closeSideTopSmall"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Action"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionRoam": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_opcomModules","_moduleType","_handler","_objectives","_side","_sideDisplay","_shuffledModules","_line1"];

            _line1 = "<t size='1.5' color='#68a7b7' align='center'>Returning to base...</t><br/><br/>";

            ["openSplash",0.25] call ALIVE_fnc_displayMenu;
            ["setSplashText",_line1] call ALIVE_fnc_displayMenu;

            _initialPosition = position _logic;

            player setPos _initialPosition;

            sleep 2;

            [_logic,"deactivateSelectionRoam"] call MAINCLASS;

        };

    };

    case "deactivateSelectionRoam": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        player hideObjectGlobal false;

        ["closeSplash"] call ALIVE_fnc_displayMenu;
        ["closeSideTopSmall"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Action"];

    };

    case "activateSelectionUsageMenu": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>ALiVE Menu</t><br/><br/>";
            _line2 = "<t size='1'>All actions available in game to players are accessible via the ALiVE menu. To open the menu use your <a href='http://en.wikipedia.org/wiki/Menu_key' color='#68a7b7'>keyboards menu key (if existing)</a></t><br/><br/>";
            _line3 = "<t size='1'>If you wish to remap the ALiVE menu key to an alternate binding in Custom Controls - Use Action 20 in the control options menu of the game. Do not use a modifier (CTRL, ALT or SHIFT). You will need to restart ArmA for this to take effect.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openFull",[_logic,"handleMenuCallback","UsageMenu"]] call ALIVE_fnc_displayMenu;
            ["setFullText",_baseCopy] call ALIVE_fnc_displayMenu;

        };

    };

    case "deactivateSelectionUsageMenu": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Usage"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionUsageAdmin": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy","_currentCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Admin Actions</t><br/><br/>";
            _line2 = "<t size='1'>A range of actions for interacting and debugging ALiVE modules are available via the ALiVE menu submenu admin actions.</t><br/><br/>";
            _line3 = "<t size='1'>This menu is available in single player missions, and in multiplayer missions when logged in as the server admin.</t><br/><br/>";
            _line3 = "<t size='1'>Open the ALiVE menu (see ALiVE menu option in this tutorial for details) and select admin actions.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Admin Actions</t><br/><br/>";
            _line2 = "<t size='1'>Admin action option: Enable Ghosting</t><br/><br/>";
            _line3 = "<t size='1'>Ghosting will hide the player object from all forces, allowing admins to test and observe other players or enemy forces safely.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Admin Actions</t><br/><br/>";
            _line2 = "<t size='1'>Admin action option: Enable Teleporting</t><br/><br/>";
            _line3 = "<t size='1'>Teleporting will allow the admin to click the map to move around, useful for testing missions or checking on players.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Admin Actions</t><br/><br/>";
            _line2 = "<t size='1'>Admin action option: Teleport Units</t><br/><br/>";
            _line3 = "<t size='1'>Teleport units allows the server admin to select players to teleport.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Admin Actions</t><br/><br/>";
            _line2 = "<t size='1'>Admin action option: Activate Marking Units</t><br/><br/>";
            _line3 = "<t size='1'>Marking units will display all units on the map for a limited time.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Admin Actions</t><br/><br/>";
            _line2 = "<t size='1'>Admin action option: Activate CQB Debug</t><br/><br/>";
            _line3 = "<t size='1'>CQB debug will display all CQB selected buildings on the map. Buildings designated with a X merker denotes spawned CQB units, and buildings designated with a circle denotes non spawned CQB positions.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Admin Actions</t><br/><br/>";
            _line2 = "<t size='1'>Admin action option: Activate Profiles Debug</t><br/><br/>";
            _line3 = "<t size='1'>Profiles debug will display all virtual group profiles on the map, full opactiy markers denote spawned groups, and transparent markers denote virtualised groups. Waypoints for virtualised groups are designated with an X marker.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Admin Actions</t><br/><br/>";
            _line2 = "<t size='1'>Admin action option: Activate Civilian Debug</t><br/><br/>";
            _line3 = "<t size='1'>Civilian debug will display all civilian agent positions on the map.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Admin Actions</t><br/><br/>";
            _line2 = "<t size='1'>Admin action option: Profile non profiled units</t><br/><br/>";
            _line3 = "<t size='1'>Profiling non profiled units will create virtual profiles for any units on the map that have not already been virtualised, this can be useful for units spawned by other systems eg Zeus.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Admin Actions</t><br/><br/>";
            _line2 = "<t size='1'>Admin action option: Debug Console</t><br/><br/>";
            _line3 = "<t size='1'>Debug console allows debug console access for server admins on servers where debug console is disabled.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            [_logic,"deactivateSelectionUsageAdmin"] call MAINCLASS;


        };

    };

    case "deactivateSelectionUsageAdmin": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        ["closeSideFull"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Usage"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionUsagePlayer": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy","_currentCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Options</t><br/><br/>";
            _line2 = "<t size='1'>Various options for players are made available when the Player Options module is placed in a mission.</t><br/><br/>";
            _line3 = "<t size='1'>Open the ALiVE menu (see ALiVE menu option in this tutorial for details).</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>View Settings</t><br/><br/>";
            _line2 = "<t size='1'>The view settings player option will open a small tablet to adjust the view distance and detail in multiplayer missions where view distance is defined by the server.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Tags</t><br/><br/>";
            _line2 = "<t size='1'>The player tags entry in the ALiVE menu allows players to turn on or off the player tag system (if enabled on the Player Options module).</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Persistence</t><br/><br/>";
            _line2 = "<t size='1'>The Player Persistence option is available on dedicated servers that are connected to the ALiVE WarRoom for campaign persistence.</t><br/><br/>";
            _line3 = "<t size='1'>This menu contains options for the player to control saving of their character.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            [_logic,"deactivateSelectionUsagePlayer"] call MAINCLASS;

        };

    };

    case "deactivateSelectionUsagePlayer": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        ["closeSideFull"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Usage"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionUsagePlayerLogistics": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic","_initialPosition"];

            _logic = _this select 0;

            ["openSplash",0.25] call ALIVE_fnc_displayMenu;
            ["setSplashText","<t size='1.5' color='#68a7b7' align='center'>Returning to base...</t><br/><br/>"] call ALIVE_fnc_displayMenu;

            _initialPosition = position _logic;

            player setPos _initialPosition;

            sleep 5;

            ["closeSplash"] call ALIVE_fnc_displayMenu;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy","_currentCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Logistics (lift and shift)</t><br/><br/>";
            _line2 = "<t size='1'>Player logistics allows players to lift, shift, and store objects, it also allows for vehicle towing and vehicle storage.</t><br/><br/>";
            _line3 = "<t size='1'>Open the ALiVE menu (see ALiVE menu option in this tutorial for details).</t><br/><br/>";
            _line4 = "<t size='1'>Select Player Logistics and Activate Actions, this will enable player logistics actions on objects and vehicles. It is advised to deactivate this when not needed to reduce script processing.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 10;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Logistics (lift and shift)</t><br/><br/>";
            _line2 = "<t size='1'>Nearby are some ammo crates, approach the crates and use the action menu to select Carry object to lift the ammo box.</t><br/><br/>";
            _line3 = "<t size='1'>You can move ammo crates near the nearby transport truck, drop the ammo crates near the truck.</t><br/><br/>";
            _line4 = "<t size='1'>Use your action menu on the truck and select Stow in cargo to load all nearby objects into the vehicles cargo.</t><br/><br/>";
            _line5 = "<t size='1'>Select Load out cargo to unload objects from the truck.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [_logic,"deactivateSelectionUsagePlayerLogistics"] call MAINCLASS;

        };

    };

    case "deactivateSelectionUsagePlayerLogistics": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        ["closeSideFull"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Usage"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionUsagePlayerCombatLogistics": {

        ALIVE_tourActiveScript = [_logic] spawn {

            player setCaptive false;

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy","_currentCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Logistics</t><br/><br/>";
            _line2 = "<t size='1'>If the mission maker has placed the Player Combat Logisitcs module, the Player Combat Logistics tablet interface will be accessible via the ALiVE menu.</t><br/><br/>";
            _line3 = "<t size='1'>Open the ALiVE menu (see ALiVE menu option in this tutorial for details).</t><br/><br/>";
            _line4 = "<t size='1'>Select the Player Combat Logistics option to open the tablet (note you must have the object required to access the tablet in your inventory - by default the ALiVE tablet, or the laser designator).</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 30;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Logistics</t><br/><br/>";
            _line2 = "<t size='1'>Select the delivery method for your logistics request.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Logistics</t><br/><br/>";
            _line2 = "<t size='1'>Select any supplies or reinforcements you require. Note that your payload must be within the constraints listed under the map.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Logistics</t><br/><br/>";
            _line2 = "<t size='1'>You can adjust the payload by selecting payload items from the payload list.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Logistics</t><br/><br/>";
            _line2 = "<t size='1'>Select the location for the logistics delivery on the map.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Logistics</t><br/><br/>";
            _line2 = "<t size='1'>Request the logistics delivery.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Logistics</t><br/><br/>";
            _line2 = "<t size='1'>Your delivery will be made in due time, you can follow it's progress on the tablet, or monitor radio messages from command.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [_logic,"deactivateSelectionUsagePlayerCombatLogistics"] call MAINCLASS;

        };

    };

    case "deactivateSelectionUsagePlayerCombatLogistics": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        ["closeSideFull"] call ALIVE_fnc_displayMenu;

        player setCaptive true;

        _logic setVariable ["selectionState","Usage"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionUsagePlayerC2": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            player setCaptive false;

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy","_currentCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>If the mission maker has placed the C2ISTAR module, the Command and control submenu will be available via the ALiVE menu.</t><br/><br/>";
            _line3 = "<t size='1'>Open the ALiVE menu (see ALiVE menu option in this tutorial for details).</t><br/><br/>";
            _line4 = "<t size='1'>Select the Player C2ISTAR option.</t><br/><br/>";
            _line5 = "<t size='1'>Select the Manage Tasks sub option.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 30;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Select create task to create a player defined task.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Enter task details, set the task state, application, current and parent.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Select a location on the map for the task destination.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Select assign players to select the players to assign the task to, once done assigning players, select Back to return to the Create Task screen. Create the task.</t><br/><br/>";
            _line3 = "<t size='1'>Select Create Task to create the task.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>The created task will be issued to the selected players, and will now appear in the Current Tasks list, you can select the task in the list and Edit it to alter task details, or delete it.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Select Generate a task to create a dynamic task.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Select the type of task to create.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Select the task distance from your player, if you choose from map, select a location on the map to use as a reference point.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Select the enemy faction for the generated task.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Select the application and current state of the generated task.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Select assign players to select the players to assign the task to, once done assigning players, select Back to return to the Generate Task screen.</t><br/><br/>";
            _line3 = "<t size='1'>Select Generate Task to create the task.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>The generated tasks will be issued to the selected players, and will now appear in the Current Tasks list, you can select the task in the list and Edit it to alter task details, or delete it.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Close the player tasks tablet.</t><br/><br/>";
            _line3 = "<t size='1'>Open the ALiVE menu.</t><br/><br/>";
            _line4 = "<t size='1'>Select the Player C2ISTAR option.</t><br/><br/>";
            _line5 = "<t size='1'>Select the Send SITREP sub option.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>The SITREP functionality allows players in multiplayer missions to send situation reports to other players.</t><br/><br/>";
            _line3 = "<t size='1'>Enter some report details and select Send SITREP once done.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>The submitted SITREP will be available via the map and diary for all players who match the eyes only setting on the report.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>Open the ALiVE menu.</t><br/><br/>";
            _line3 = "<t size='1'>Select the Player C2ISTAR option.</t><br/><br/>";
            _line4 = "<t size='1'>Select the Send PATROLREP sub option.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>The PATROL functionality allows players in multiplayer missions to send patrol reports to other players.</t><br/><br/>";
            _line3 = "<t size='1'>Enter some report details and select the start and end points for the patrol on the map.</t><br/><br/>";
            _line4 = "<t size='1'Select Send PATROLREP once done.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Command and Control (C2ISTAR)</t><br/><br/>";
            _line2 = "<t size='1'>The submitted PATROLREP will be available via the map and diary for all players who match the eyes only setting on the report.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [_logic,"deactivateSelectionUsagePlayerC2"] call MAINCLASS;

        };

    };

    case "deactivateSelectionUsagePlayerC2": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        ["closeSideFull"] call ALIVE_fnc_displayMenu;

        player setCaptive true;

        _logic setVariable ["selectionState","Usage"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionUsagePlayerCombatSupport": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic","_initialPosition"];

            _logic = _this select 0;

            ["openSplash",0.25] call ALIVE_fnc_displayMenu;
            ["setSplashText","<t size='1.5' color='#68a7b7' align='center'>Returning to base...</t><br/><br/>"] call ALIVE_fnc_displayMenu;

            _initialPosition = position _logic;

            player setPos _initialPosition;

            sleep 5;

            ["closeSplash"] call ALIVE_fnc_displayMenu;

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy","_currentCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>If the mission maker has placed Combat support modules, the Combat Support submenu will be available via the ALiVE menu.</t><br/><br/>";
            _line3 = "<t size='1'>Open the ALiVE menu (see ALiVE menu option in this tutorial for details).</t><br/><br/>";
            _line4 = "<t size='1'>Select the Player Combat Support option.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 30;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Select the TRANSPORT option.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Select the transport unit to request support from, and select PICKUP.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>You can also select the height, speed and rules of engagement for the transport vehicle.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Select the location on the map for the destination of the transport vehicle.</t><br/><br/>";
            _line3 = "<t size='1'>Once pickup point selected, press the Confirm button.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>You can request a SITREP of the transport vehicle to determine it's current position, health, ammo levels and availability.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>The transport vehicle will now move to the requested position.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Once the transport vehicle has arrived at the pickup point you will be request to pop a smoke grenade to designate where the transport should land. Once the smoke has been sighted by the transport vehicle, open the Combat Support tablet again to confirm the smoke as the LZ.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Once the vehicle has landed you can board and then use the Combat Support tablet to issue futhers orders to the transport.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;



            ["openSplash",0.25] call ALIVE_fnc_displayMenu;
            ["setSplashText","<t size='1.5' color='#68a7b7' align='center'>Moving Position...</t><br/><br/>"] call ALIVE_fnc_displayMenu;

            _position = [_initialPosition, "Map", "EAST", "MIL"] call ALIVE_fnc_taskGetSideCluster;

            _position = [_position,"overwatch"] call ALIVE_fnc_taskGetSectorPosition;

            player setPos _position;

            sleep 5;

            ["closeSplash"] call ALIVE_fnc_displayMenu;



            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Open the Combat Support tablet, and select the CAS option.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Select the CAS unit to request support from, and select SAD (Search and Destroy).</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Define the radius, altitude and rules of engagement for the search and destroy mission</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Select the location on the map for the search and destroy mission.</t><br/><br/>";
            _line3 = "<t size='1'>Once location selected, press the Confirm button.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>The CAS vehicle will now move to the search and destroy mission and attack targets unitl ordered to return to base.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;


            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Open the Combat Support tablet, and select the ARTY option.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Select the artillery battery to request support from, and select the ordnance to use.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Define the rate of fire, number of rounds, and the dispersion of the fire mission.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>Select the location on the map for the fire mission.</t><br/><br/>";
            _line3 = "<t size='1'>Once location selected, press the Confirm button.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Player Combat Support</t><br/><br/>";
            _line2 = "<t size='1'>The artillery battery will now commence firing on the selected location.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [_logic,"deactivateSelectionUsagePlayerCombatSupport"] call MAINCLASS;

        };

    };

    case "deactivateSelectionUsagePlayerCombatSupport": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        ["closeSideFull"] call ALIVE_fnc_displayMenu;

        _logic setVariable ["selectionState","Usage"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "activateSelectionUsageAdvancedMarkers": {

        ALIVE_tourActiveScript = [_logic] spawn {

            private["_logic"];

            _logic = _this select 0;

            private["_line1","_line2","_line3","_line4","_line5","_line6","_line7","_baseCopy","_currentCopy"];

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Advanced Markers</t><br/><br/>";
            _line2 = "<t size='1'>Advanced markers allow players to create, add SPOTREP, draw and persist markers.</t><br/><br/>";
            _line3 = "<t size='1'>Open the map.</t><br/><br/>";
            _line4 = "<t size='1'>Hold the control key and left click to create an advanced marker.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 30;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Advanced Markers</t><br/><br/>";
            _line2 = "<t size='1'>Select the marker options as desired.</t><br/><br/>";
            _line3 = "<t size='1'>You can opt to add a SPOTREP to the marker, which will add the report to the map and diary.</t><br/><br/>";
            _line4 = "<t size='1'>Click Ok once done.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Advanced Markers</t><br/><br/>";
            _line2 = "<t size='1'>You can edit a created marker by holding the control key and left clicking on the marker.</t><br/><br/>";
            _line3 = "<t size='1'>You can delete a created marker by holding the control key and right clicking on the marker.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            _line1 = "<br/><t size='1.5' color='#68a7b7'>Advanced Markers</t><br/><br/>";
            _line2 = "<t size='1'>You can also draw lines, rectangles, arrows, ellipses. By default drawing on the map is broadcast to all players on your side.</t><br/><br/>";
            _line3 = "<t size='1'>Press the [ button to cycle through drawing modes. Press the END button to exit drawing mode.</t><br/><br/>";
            _line4 = "<t size='1'>Press the up arrow to increase the width of a line or angle of a box/ellipse, press the down arrow to decrease the width of the line or angle of box/ellipse.</t><br/><br/>";
            _line5 = "<t size='1'>Press the left arrow to change color. Press the right arrow to change fill (if appropriate).</t><br/><br/>";
            _line6 = "<t size='1'>Press CTRL and the left mouse button to start drawing, press CTRL and the left mouse button again to stop drawing.</t><br/><br/>";

            _baseCopy = format["%1%2%3%4%5%6%7",_line1,_line2,_line3,_line4,_line5,_line6];

            ["openSideFull"] call ALIVE_fnc_displayMenu;
            ["setSideFullText",_baseCopy] call ALIVE_fnc_displayMenu;

            sleep 20;

            [_logic,"deactivateSelectionUsageAdvancedMarkers"] call MAINCLASS;

        };

    };

    case "deactivateSelectionUsageAdvancedMarkers": {

        if!(isNil "ALIVE_tourActiveScript") then {
            if!(scriptDone ALIVE_tourActiveScript) then {
                terminate ALIVE_tourActiveScript;
            };
        };

        _logic setVariable ["selectionState","Usage"];

        [_logic,"displaySelectionState"] call MAINCLASS;

    };

    case "createDynamicCamera": {

        private ["_source","_target1","_target2","_duration","_sourceIsPlayer","_targetIsPlayer","_targetIsMan","_targetInVehicle","_cameraAngles",
        "_initialAngle","_diceRoll","_cameraShots","_shot","_target2","_randomPosition"];

        _duration = _args select 0;
        _source = _args select 1;
        _target1 = _args select 2;
        _target2 = if(count _this > 3) then {_this select 3} else {nil};

        _sourceIsPlayer = false;
        if(isPlayer _source) then {
            _sourceIsPlayer = true;
        };

        _targetIsMan = false;
        _targetInVehicle = false;
        if(_target1 isKindOf "Man" && alive _target1) then {
            _targetIsMan = true;
            if(vehicle _target1 != _target1) then {
                _targetInVehicle = true;
                _target1 = vehicle _target1;
            };
        };

        //_cameraAngles = ["DEFAULT","LOW","EYE","HIGH","BIRDS_EYE","UAV","SATELITE"];
        _cameraAngles = ["EYE","HIGH","BIRDS_EYE","UAV"];
        _initialAngle = _cameraAngles call BIS_fnc_selectRandom;

        /*
        ["CINEMATIC DURATION: %1",_duration] call ALIVE_fnc_dump;
        ["SOURCE IS PLAYER: %1",_sourceIsPlayer] call ALIVE_fnc_dump;
        ["TARGET IS MAN: %1",_targetIsMan] call ALIVE_fnc_dump;
        ["TARGET IS IN VEHICLE: %1",_targetInVehicle] call ALIVE_fnc_dump;
        */

        ALIVE_cameraType = "CAMERA";

        if(_targetIsMan && !(_targetInVehicle)) then {
            _diceRoll = random 1;
            if(_diceRoll > 0.4) then {
                ALIVE_cameraType = "SWITCH";
            };
        };

        //["CAMERA TYPE IS: %1",ALIVE_cameraType] call ALIVE_fnc_dump;

        _cameraShots = ["FLY_IN","PAN","ZOOM"];

        if(_targetIsMan || _targetInVehicle) then {
            _cameraShots = _cameraShots + ["CHASE","CHASE_SIDE","CHASE_ANGLE"];
        };

        _shot = _cameraShots call BIS_fnc_selectRandom;

        /*
        ["CAMERA SHOT IS: %1",_shot] call ALIVE_fnc_dump;
        ["CAMERA ANGLE IS: %1",_initialAngle] call ALIVE_fnc_dump;
        */

        if(ALIVE_cameraType == "CAMERA") then {

            if!(_shot == "PAN") then {
                ALIVE_tourCamera = [_source,false,_initialAngle] call ALIVE_fnc_addCamera;
                [ALIVE_tourCamera,true] call ALIVE_fnc_startCinematic;
            };

            switch(_shot) do {
                case "FLY_IN":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_flyInShot;
                };
                case "ZOOM":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_zoomShot;
                };
                case "PAN":{

                    if(isNil "_target2") then {
                        _randomPosition = [position _source, (random(50)), random(360)] call BIS_fnc_relPos;
                        _target2 = "RoadCone_L_F" createVehicle _randomPosition;
                        _target2 hideObjectGlobal true;
                    };

                    ALIVE_tourCamera = [_source,false,_initialAngle] call ALIVE_fnc_addCamera;
                    [ALIVE_tourCamera,true] call ALIVE_fnc_startCinematic;
                    [ALIVE_tourCamera,_target2,_target1,_duration] spawn ALIVE_fnc_panShot;
                };
                case "STATIC":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_staticShot;
                };
                case "CHASE":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_chaseShot;
                };
                case "CHASE_SIDE":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_chaseSideShot;
                };
                case "CHASE_WHEEL":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_chaseWheelShot;
                };
                case "CHASE_ANGLE":{
                    [ALIVE_tourCamera,_target1,_duration] spawn ALIVE_fnc_chaseAngleShot;
                };
            };

        }else{

            [_target1,"FIRST_PERSON"] call ALIVE_fnc_switchCamera;

        };

    };

    case "deleteDynamicCamera": {

        if(ALIVE_cameraType == "CAMERA") then {

            [ALIVE_tourCamera,true] call ALIVE_fnc_stopCinematic;
            [ALIVE_tourCamera] call ALIVE_fnc_removeCamera;

        }else{

            [true] call ALIVE_fnc_revertCamera;

        };

        player hideObjectGlobal false;

    };

    case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, [
            "LOGISTICS_INSERTION",
            "LOGISTICS_COMPLETE",
            "PROFILE_KILLED",
            "OPCOM_RECON",
            "OPCOM_CAPTURE",
            "OPCOM_DEFEND",
            "OPCOM_RESERVE"
        ]]] call ALIVE_fnc_eventLog;
        _logic setVariable ["listenerID", _listenerID];
    };
    case "handleEvent": {
        private["_event","_id","_type","_eventData"];

        if(typeName _args == "ARRAY") then {

            _event = _args;

            _id = [_event, "id"] call ALIVE_fnc_hashGet;
            _type = [_event, "type"] call ALIVE_fnc_hashGet;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            [_logic, _type, [_id,_eventData]] call MAINCLASS;

        };
    };
    case "LOGISTICS_INSERTION": {
        private["_eventID","_eventData","_position","_side","_faction","_nearestTown","_title","_text"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _position = _eventData select 0;
        _side = _eventData select 2;
        _faction = _eventData select 1;
        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;

        switch(_side) do {
            case "EAST":{
                _side = "OPFOR";
            };
            case "WEST":{
                _side = "BLUFOR";
            };
            case "GUER":{
                _side = "INDEP";
            };
        };

        _title = "<t size='1.5' color='#68a7b7'  shadow='1'>REINFORCEMENTS</t><br/>";
        _text = format["%1<t>%2 battlefield reinforcement requested by OPCOM. Insertion point near %3</t>",_title,_side,_nearestTown];

        ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

    };
    case "LOGISTICS_COMPLETE": {
        private["_eventID","_eventData","_position","_side","_faction","_nearestTown","_title","_text"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _position = _eventData select 0;
        _side = _eventData select 2;
        _faction = _eventData select 1;

        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;

        switch(_side) do {
            case "EAST":{
                _side = "OPFOR";
            };
            case "WEST":{
                _side = "BLUFOR";
            };
            case "GUER":{
                _side = "INDEP";
            };
        };

        _title = "<t size='1.5' color='#68a7b7'  shadow='1'>REINFORCEMENTS</t><br/>";
        _text = format["%1<t>%2 battlefield reinforcement delivered to staging area near %3</t>",_title,_side,_nearestTown];

        ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;


    };
    case "PROFILE_KILLED": {
        private["_eventID","_eventData","_position","_side","_faction","_nearestTown","_title","_text"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _position = _eventData select 0;
        _side = _eventData select 2;
        _faction = _eventData select 1;

        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;

        switch(_side) do {
            case "EAST":{
                _side = "OPFOR";
            };
            case "WEST":{
                _side = "BLUFOR";
            };
            case "GUER":{
                _side = "INDEP";
            };
        };

        _title = "<t size='1.5' color='#68a7b7'  shadow='1'>CASUALTY REPORT</t><br/>";
        _text = format["%1<t>%2 units KIA near %3</t>",_title,_side,_nearestTown];

        ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

    };
    case "OPCOM_RECON": {
        private["_eventID","_eventData","_side","_position","_size","_type","_priority","_clusterID","_nearestTown","_title","_text"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _side = _eventData select 0;
        _position = _eventData select 1 select 2 select 1;
        _size = _eventData select 1 select 2 select 2;
        _type = _eventData select 1 select 2 select 3;
        _priority = _eventData select 1 select 2 select 4;
        _clusterID = _eventData select 1 select 2 select 6;

        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;

        switch(_type) do {
            case "MIL":{
                _type = "military";
            };
            case "CIV":{
                _type = "civilian";
            };
        };

        switch(_side) do {
            case "EAST":{
                _side = "OPFOR";
            };
            case "WEST":{
                _side = "BLUFOR";
            };
            case "GUER":{
                _side = "INDEP";
            };
        };

        _title = "<t size='1.5' color='#68a7b7'  shadow='1'>OPCOM EVENT</t><br/>";
        _text = format["%1<t>%2 OPCOM has requested recon of a %3 objective near %4</t>",_title,_side,_type,_nearestTown];

        ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

    };
    case "OPCOM_CAPTURE": {
        private["_eventID","_eventData","_side","_position","_size","_type","_priority","_clusterID","_nearestTown","_title","_text"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _side = _eventData select 0;
        _position = _eventData select 1 select 2 select 1;
        _size = _eventData select 1 select 2 select 2;
        _type = _eventData select 1 select 2 select 3;
        _priority = _eventData select 1 select 2 select 4;
        _clusterID = _eventData select 1 select 2 select 6;

        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;

        switch(_type) do {
            case "MIL":{
                _type = "military";
            };
            case "CIV":{
                _type = "civilian";
            };
        };

        switch(_side) do {
            case "EAST":{
                _side = "OPFOR";
            };
            case "WEST":{
                _side = "BLUFOR";
            };
            case "GUER":{
                _side = "INDEP";
            };
        };

        _title = "<t size='1.5' color='#68a7b7'  shadow='1'>OPCOM EVENT</t><br/>";
        _text = format["%1<t>%2 OPCOM is capturing a %3 objective near %4</t>",_title,_side,_type,_nearestTown];

        ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

    };
    case "OPCOM_DEFEND": {
        private["_eventID","_eventData","_side","_position","_size","_type","_priority","_clusterID","_nearestTown","_title","_text"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _side = _eventData select 0;
        _position = _eventData select 1 select 2 select 1;
        _size = _eventData select 1 select 2 select 2;
        _type = _eventData select 1 select 2 select 3;
        _priority = _eventData select 1 select 2 select 4;
        _clusterID = _eventData select 1 select 2 select 6;

        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;

        switch(_type) do {
            case "MIL":{
                _type = "military";
            };
            case "CIV":{
                _type = "civilian";
            };
        };

        switch(_side) do {
            case "EAST":{
                _side = "OPFOR";
            };
            case "WEST":{
                _side = "BLUFOR";
            };
            case "GUER":{
                _side = "INDEP";
            };
        };

        _title = "<t size='1.5' color='#68a7b7'  shadow='1'>OPCOM EVENT</t><br/>";
        _text = format["%1<t>%2 OPCOM is defending a %3 objective near %4</t>",_title,_side,_type,_nearestTown];

        ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

    };
    case "OPCOM_RESERVE": {
        private["_eventID","_eventData","_side","_position","_size","_type","_priority","_clusterID","_nearestTown","_title","_text"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _side = _eventData select 0;
        _position = _eventData select 1 select 2 select 1;
        _size = _eventData select 1 select 2 select 2;
        _type = _eventData select 1 select 2 select 3;
        _priority = _eventData select 1 select 2 select 4;
        _clusterID = _eventData select 1 select 2 select 6;

        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;

        switch(_type) do {
            case "MIL":{
                _type = "military";
            };
            case "CIV":{
                _type = "civilian";
            };
        };

        switch(_side) do {
            case "EAST":{
                _side = "OPFOR";
            };
            case "WEST":{
                _side = "BLUFOR";
            };
            case "GUER":{
                _side = "INDEP";
            };
        };

        _title = "<t size='1.5' color='#68a7b7'  shadow='1'>OPCOM EVENT</t><br/>";
        _text = format["%1<t>%2 OPCOM has reserved a %3 objective near %4</t>",_title,_side,_type,_nearestTown];

        ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

    };
    case "OPCOM_TERRORIZE": {
        private["_eventID","_eventData","_side","_position","_size","_type","_priority","_clusterID","_nearestTown","_title","_text"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _side = _eventData select 0;
        _position = _eventData select 1 select 2 select 1;
        _size = _eventData select 1 select 2 select 2;
        _type = _eventData select 1 select 2 select 3;
        _priority = _eventData select 1 select 2 select 4;
        _clusterID = _eventData select 1 select 2 select 6;

        _nearestTown = [_position] call ALIVE_fnc_taskGetNearestLocationName;

        switch(_type) do {
            case "MIL":{
                _type = "military";
            };
            case "CIV":{
                _type = "civilian";
            };
        };

        switch(_side) do {
            case "EAST":{
                _side = "OPFOR";
            };
            case "WEST":{
                _side = "BLUFOR";
            };
            case "GUER":{
                _side = "INDEP";
            };
        };

        _title = "<t size='1.5' color='#68a7b7'  shadow='1'>OPCOM EVENT</t><br/>";
        _text = format["%1<t>%2 OPCOM has terrorized a %3 objective near %4</t>",_title,_side,_type,_nearestTown];

        ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

    };
};

TRACE_1("TOUR - output",_result);
_result;
