#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(civInteract);

/* ----------------------------------------------------------------------------
Function: MAINCLASS

Description:
Main handler for civilian interraction

Parameters:
String - Operation
Array - Arguments

Returns:
Any - Result of the operation

Examples:
(begin example)
[_logic,_operation, _arguments] call MAINCLASS;
_civData = [_logic,"getData", [player,_civ]] call MAINCLASS; //-- Get data of civilian
(end)

See Also:
- nil

Author: SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params [
	["_logic", objNull],
	["_operation", ""],
	["_arguments", []]
];

private ["_result"];

//-- Define function shortcuts
#define MAINCLASS ALiVE_fnc_civInteract
#define QUESTIONHANDLER ALiVE_fnc_questionHandler

//-- Define control ID's
#define CIVINTERACT_DISPLAY 		(findDisplay 923)
#define CIVINTERACT_CIVNAME 		(CIVINTERACT_DISPLAY displayCtrl 9236)
#define CIVINTERACT_DETAIN 		(CIVINTERACT_DISPLAY displayCtrl 92311)
#define CIVINTERACT_QUESTIONLIST 		(CIVINTERACT_DISPLAY displayCtrl 9234)
#define CIVINTERACT_RESPONSELIST 		(CIVINTERACT_DISPLAY displayCtrl 9239)
#define CIVINTERACT_PIC					(CIVINTERACT_DISPLAY displayCtrl 1200)
#define CIVINTERACT_INVENTORYCONTROLS 	[9240,9241,9243,9244]
#define CIVINTERACT_SEARCHBUTTON 	(CIVINTERACT_DISPLAY displayCtrl 9242)
#define CIVINTERACT_GEARLIST 		(CIVINTERACT_DISPLAY displayCtrl 9244)
#define CIVINTERACT_GEARLISTCONTROL 	(CIVINTERACT_DISPLAY displayCtrl 9244)
#define CIVINTERACT_CONFISCATEBUTTON 	(CIVINTERACT_DISPLAY displayCtrl 9245)
#define CIVINTERACT_OPENGEARCONTAINER	(CIVINTERACT_DISPLAY displayCtrl 9246)

switch (_operation) do {

	case "create": {
		_result = [] call ALiVE_fnc_hashCreate;
	};

	//-- Create logic on all localities
	case "init": {

		if (isNil QMOD(civInteractHandler)) then {
			//-- Get settings
			_debug = _logic getVariable "debug";
			_factionEnemy = _logic getVariable "insurgentFaction";
			private _authorized = (_logic getVariable "limitInteraction") call ALiVE_fnc_stringListToArray;

			//-- Create interact handler object
			MOD(civInteractHandler) = [nil,"create"] call MAINCLASS;
			[MOD(civInteractHandler), "Debug", _debug] call ALiVE_fnc_hashSet;
			[MOD(civInteractHandler), "InsurgentFaction", _factionEnemy] call ALiVE_fnc_hashSet;
			[MOD(civInteractHandler), "authorized", _authorized] call ALiVE_fnc_hashSet;
		};
	};

	//-- On load
	case "openMenu": {
		_civ = _arguments;

 		private _authorized = [MOD(civInteractHandler), "authorized", []] call ALiVE_fnc_hashGet;

		//-- Exit if civ is armed
		if ((primaryWeapon _civ != "") or {handgunWeapon _civ != ""}) exitWith {};

		// Exit if not authorized
		if (count _authorized > 0 && !((getPlayerUID player in _authorized) || (typeOf player in _authorized) || (name player in _authorized) || (faction player in _authorized) || (rank player in _authorized))) exitWith {["The civilian can't understand what you are saying."] call ALiVE_fnc_dumpR;};

		//-- Close dialog if it happened to open twice
		if (!isNull findDisplay 923) exitWith {};

		//-- Stop civilian
		[[[_civ],{(_this select 0) disableAI "MOVE"}],"BIS_fnc_spawn",_civ,false,true] call BIS_fnc_MP;
		//_civ disableAI "MOVE"; //-- Needs further testing but wasn't reliable in MP (Arguments must be local -- unit is local to server (or hc))

		//-- Remove data from handler -- Just in case something doesn't delete upon closing
		[_logic, "CivData", nil] call ALiVE_fnc_hashSet;
		[_logic, "Civ", nil] call ALiVE_fnc_hashSet;
		[_logic, "Items", nil] call ALiVE_fnc_hashSet;

		//-- Hash civilian to logic (must be done early so commandHandler has an object to use)
		[_logic, "Civ", _civ] call ALiVE_fnc_hashSet;	//-- Unit object

		//-- Open dialog
		CreateDialog "ALiVE_CivilianInteraction";

		if (_civ getVariable "detained") then {
			CIVINTERACT_DETAIN ctrlSetText "Release";
		};

		[nil,"toggleSearchMenu"] call MAINCLASS;
		CIVINTERACT_CONFISCATEBUTTON ctrlShow false;
		CIVINTERACT_OPENGEARCONTAINER ctrlShow false;

		//-- Display loading
		CIVINTERACT_QUESTIONLIST lbAdd "Loading . . .";
		CIVINTERACT_PIC ctrlsetText "a3\ui_f\data\GUI\Rsc\RscDisplayMain\profile_player_ca.paa";
		//-- Retrieve data
		[nil,"getData", [player,_civ]] remoteExecCall [QUOTE(MAINCLASS),2];
	};

	//-- Load data
	case "loadData": {
		//-- Exit if the menu has been closed
		if (isNull findDisplay 923) exitWith {};

		_arguments params ["_objectiveInstallations","_objectiveActions","_civInfo","_hostileCivInfo"];

		_logic = MOD(civInteractHandler);

		//-- Create hash
		_civData = [] call ALIVE_fnc_hashCreate;
		_civ = [_logic,"Civ"] call ALiVE_fnc_hashGet;
		_answersGiven = _civ getVariable ["AnswersGiven", []];

		//-- Hash data to logic
		[_civData, "Installations", _objectiveInstallations] call ALiVE_fnc_hashSet;		//-- [_factory,_HQ,_depot,_roadblocks]
		[_civData, "Actions", _objectiveActions] call ALiVE_fnc_hashSet;			//-- [_ambush,_sabotage,_ied,_suicide]
		[_civData, "CivInfo", _civInfo] call ALiVE_fnc_hashSet;				//-- [_homePos, _individualHostility, _townHostility]
		[_civData, "HostileCivInfo", _hostileCivInfo] call ALiVE_fnc_hashSet;			//-- [_civ,_homePos,_activeCommands]
		[_civData, "AnswersGiven", _answersGiven] call ALiVE_fnc_hashSet;			//-- Default []
		[_civData, "Asked", 0] call ALiVE_fnc_hashSet;					//-- Default - 0
		[_logic, "CivData", _civData] call ALiVE_fnc_hashSet;

		//-- Display persistent civ name
		_name = _civInfo select 3;
		_role = [nil,"getRole", _civ] call MAINCLASS;
		if (_role == "None") then {
			CIVINTERACT_CIVNAME ctrlSetText (format ["%1 (%2)", _name, [configFile >> "CfgVehicles" >> typeOf vehicle _civ] call BIS_fnc_displayName]);
		} else {
			CIVINTERACT_CIVNAME ctrlSetText (format ["%1 (%2)", _name, _role]);
		};

		[_logic,"enableMain"] call MAINCLASS;
	};

	case "enableMain": {
		//-- Remove EH's
		(COMMANDBOARD_DISPLAY displayCtrl COMMANDBOARD_MAINMENU) ctrlRemoveAllEventHandlers "LBSelChanged";

		//-- Clear list
		lbClear CIVINTERACT_QUESTIONLIST;

		//-- Build question list
		CIVINTERACT_QUESTIONLIST lbAdd "Where do you live?";
		CIVINTERACT_QUESTIONLIST lbSetData [0, "Home"];

		CIVINTERACT_QUESTIONLIST lbAdd "What town you do live in";
		CIVINTERACT_QUESTIONLIST lbSetData [1, "Town"];

		CIVINTERACT_QUESTIONLIST lbAdd "Have you seen any IED's lately?";
		CIVINTERACT_QUESTIONLIST lbSetData [2, "IEDs"];

		CIVINTERACT_QUESTIONLIST lbAdd "Have you seen any insurgent activity lately?";
		CIVINTERACT_QUESTIONLIST lbSetData [3, "Insurgents"];

		CIVINTERACT_QUESTIONLIST lbAdd "Do you know the location of any insurgent hideouts?";
		CIVINTERACT_QUESTIONLIST lbSetData [4, "Hideouts"];

		CIVINTERACT_QUESTIONLIST lbAdd "Have you seen any strange behavior lately?";
		CIVINTERACT_QUESTIONLIST lbSetData [5, "StrangeBehavior"];

		CIVINTERACT_QUESTIONLIST lbAdd "Do you support us?";
		CIVINTERACT_QUESTIONLIST lbSetData [6, "Opinion"];

		CIVINTERACT_QUESTIONLIST lbAdd "What is the opinion of our forces in this area?";
		CIVINTERACT_QUESTIONLIST lbSetData [7, "TownOpinion"];

		CIVINTERACT_QUESTIONLIST ctrlAddEventHandler ["LBSelChanged","
			params ['_control','_index'];
			_question = _control lbData _index;
			[ALiVE_civInteractHandler,_question] call ALiVE_fnc_questionHandler;
		"];
	};

	//-- Unload
	case "closeMenu": {
		//-- Close menu
		closeDialog 0;

		//-- Un-stop civilian
		_civ = [_logic, "Civ"] call ALiVE_fnc_hashGet;
		[[[_civ],{(_this select 0) enableAI "MOVE"}],"BIS_fnc_spawn",_civ,false,true] call BIS_fnc_MP;
		//_civ enableAI "MOVE"; //-- Needs further testing but wasn't reliable in MP (Arguments must be local -- unit is local to server (or hc))

		//-- Remove data from handler
		[_logic, "CivData", nil] call ALiVE_fnc_hashSet;
		[_logic, "Civ", nil] call ALiVE_fnc_hashSet;
		//[_logic, "Items", nil] call ALiVE_fnc_hashSet; 	//-- REMOVE AFTER FIX
	};

	case "getObjectiveInstallations": {
		_arguments params ["_opcom","_objective"];

		_factory = [_opcom,"convertObject",[_objective,"factory",objNull] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
		_HQ = [_opcom,"convertObject",[_objective,"HQ",objNull] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
		_depot = [_opcom,"convertObject",[_objective,"depot",objNull] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
		_roadblocks = [_opcom,"convertObject",[_objective,"roadblocks",objNull] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

		_result = [_factory,_HQ,_depot,_roadblocks];

	};

	case "getObjectiveActions": {
		_arguments params ["_opcom","_objective"];

		_ambush = [_opcom,"convertObject",[_objective,"ambush",objNull] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
		_sabotage = [_opcom,"convertObject",[_objective,"sabotage",objNull] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
		_ied = [_opcom,"convertObject",[_objective,"ied",objNull] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
		_suicide = [_opcom,"convertObject",[_objective,"suicide",objNull] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

		_result = [_ambush,_sabotage,_ied,_suicide];
	};

	case "getData": {
		private ["_opcom","_nearestObjective","_civInfo","_clusterID","_agentProfile","_hostileCivInfo","_name","_objectiveInstallations","_objectiveActions"];
		_arguments params ["_player","_civ"];

		_civPos = getPos _civ;
		_insurgentFaction = [MOD(civInteractHandler), "InsurgentFaction"] call ALiVE_fnc_hashGet;
		_objectives = [];

		//-- Get nearest objective properties
		for "_i" from 0 to (count OPCOM_instances - 1) step 1 do {
			_opcom = OPCOM_instances select _i;

			if (_insurgentFaction in ([_opcom, "factions"] call ALiVE_fnc_hashGet)) exitWith {
				_objectives = ([_opcom, "objectives",[]] call ALiVE_fnc_hashGet);
				_objectives = [_objectives,[_civPos],{_Input0 distance2D ([_x, "center"] call CBA_fnc_HashGet)},"ASCEND"] call BIS_fnc_sortBy;
				_nearestObjective = [_opcom, _objectives select 0];
			};
		};


		if (count _objectives > 0) then {
			_objectiveInstallations = [MOD(civInteractHandler), "getObjectiveInstallations", _nearestObjective] call MAINCLASS;
			_objectiveActions = [MOD(civInteractHandler), "getObjectiveActions", _nearestObjective] call MAINCLASS;
		} else {
			_objectiveInstallations = [[],[],[],[]];
			_objectiveActions = [[],[],[],[]];
		};

		//-- Get civilian info
		_civID = _civ getVariable ["agentID", ""];

		if (_civID != "") then {
			_civProfile = [ALIVE_agentHandler, "getAgent", _civID] call ALIVE_fnc_agentHandler;
			_clusterID = (_civProfile select 2) select 9;
			_cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;
			_homePos = (_civProfile select 2) select 10;
			_individualHostility = (_civProfile select 2) select 12;
			_townHostility = [_cluster, "posture"] call ALIVE_fnc_hashGet;	//_townHostility = (_cluster select 2) select 9; (Different)

			if (!isNil {[_civProfile,"ALiVE_PersistentName"] call ALiVE_fnc_hashGet}) then {
				_name = [_civProfile,"ALiVE_PersistentName"] call ALiVE_fnc_hashGet;
			} else {
				[_civProfile,"ALiVE_PersistentName", name _civ] call ALiVE_fnc_hashSet;
				_name = name _civ;
			};

			_civInfo = [_homePos, _individualHostility, _townHostility, _name];

		} else {
			_clusterID = _civ getVariable ["ALiVE_clusterID",""];
			if (_clusterID == "") then {
				private _nearestAgent = [position _civ] call ALiVE_fnc_getNearestActiveAgent;
            	if (count _nearestAgent > 0) then {
                 	_clusterID = [_nearestAgent, "homeCluster"] call ALiVE_fnc_hashGet;
				} else {
					_clusterID = ([ALIVE_clusterHandler, "clusters"] call ALiVE_fnc_hashGet) select 1 select 0;
				};
			};
			_cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;
			_homePos = _civ getVariable ["ALiVE_homePos",position _civ];
			_individualHostility = _civ getVariable ["ALiVE_CivPop_Hostility",30];
			_townHostility = [_cluster, "posture"] call ALIVE_fnc_hashGet;
			_name = name _civ;
			_civInfo = [_homePos, _individualHostility, _townHostility,_name];
		};

		//-- Get nearby hostile civilian
		_hostileCivInfo = [];
		_insurgentCommands = ["alive_fnc_cc_suicide","alive_fnc_cc_suicidetarget","alive_fnc_cc_rogue","alive_fnc_cc_roguetarget","alive_fnc_cc_sabotage","alive_fnc_cc_getweapons"];
		_agentsByCluster = [ALIVE_agentHandler, "agentsByCluster"] call ALIVE_fnc_hashGet;
		_nearCivs = [_agentsByCluster, _clusterID] call ALIVE_fnc_hashGet;

		for "_i" from 0 to ((count (_nearCivs select 1)) - 1) do {
			_agentID = (_nearCivs select 1) select _i;
			_agentProfile = [_nearCivs, _agentID] call ALiVE_fnc_hashGet;

			if ([_agentProfile,"active"] call ALIVE_fnc_hashGet) then {
				if ([_agentProfile, "type"] call ALiVE_fnc_hashGet == "agent") then {
					_activeCommands = [_agentProfile,"activeCommands",[]] call ALIVE_fnc_hashGet;

					if ({toLower (_x select 0) in _insurgentCommands} count _activeCommands > 0) then {
						_unit = [_agentProfile,"unit"] call ALIVE_fnc_hashGet;

						if (name _civ != name _unit) then {
							_homePos = (_agentProfile select 2) select 10;
							_hostileCivInfo pushBack [_unit,_homePos,_activeCommands];
						};
					};
				};
			};
		};

		if (count _hostileCivInfo > 0) then {_hostileCivInfo = _hostileCivInfo call BIS_fnc_selectRandom};	//-- Ensure random hostile civ is picked if there are multiple

		_civData = [_objectiveInstallations, _objectiveActions, _civInfo,_hostileCivInfo];

		// _civData call ALiVE_fnc_inspectArray;

		//-- Send data to client
		[nil,"loadData", _civData] remoteExecCall [QUOTE(MAINCLASS),_player];
	};

	case "getRole": {
		private ["_role"];
		_civ = _arguments;
		_role = "none";
		{if (_civ getvariable [_x,false]) exitwith {_role = _x}} foreach ["townelder","major","priest","muezzin","politician"];

		_result = ([_role] call CBA_fnc_capitalize);
	};

	case "isIrritated": {
		_arguments params ["_hostile","_asked","_civ"];

		//-- Raise hostility if civilian is irritated
		if !(_hostile) then {
			if (floor random 100 < (3 * _asked)) then {
				[MOD(civInteractHandler),"UpdateHostility", [_civ, 10]] call MAINCLASS;
				if (floor random 70 < (_asked * 5)) then {
					_response1 = format [" *%1 grows visibly annoyed*", name _civ];
					_response2 = format [" *%1 appears uninterested in the conversation*", name _civ];
					_response3 = " Please leave me alone now.";
					_response4 = " I do not want to talk to you anymore.";
					_response5 = " Can I go now?";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText ((ctrlText CIVINTERACT_RESPONSELIST) + _response);
				};
			};
		} else {
			if (floor random 100 < (8 * _asked)) then {
				[MOD(civInteractHandler),"UpdateHostility", [_civ, 10]] call MAINCLASS;
				if (floor random 70 < (_asked * 5)) then {
					_response1 = format [" *%1 looks anxious*", name _civ];
					_response2 = format [" *%1 looks distracted*", name _civ];
					_response3 = " Are you done yet?";
					_response4 = " You ask too many questions.";
					_response5 = " You need to leave now.";
					_response = [_response1, _response2, _response3,_response4, _response5] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText ((ctrlText CIVINTERACT_RESPONSELIST) + _response);
				};
			};
		};
	};

	case "UpdateHostility": {
		//-- Change local civilian hostility
		private ["_townHostilityValue"];
		_arguments params ["_civ","_value"];
		if (count _arguments > 2) then {_townHostilityValue = _arguments select 2};

		if (isNil "_townHostilityValue") then {
			if (isNil {[MOD(civInteractHandler), "CivData"] call ALiVE_fnc_hashGet}) exitWith {};

			_civData = [MOD(civInteractHandler), "CivData"] call ALiVE_fnc_hashGet;
			_civInfo = [_civData, "CivInfo"] call ALiVE_fnc_hashGet;
			_civInfo params ["_homePos","_individualHostility","_townHostility","_name"];

			_individualHostility = _individualHostility + _value;
			_townHostilityValue = floor random 4;
			_townHostility = _townHostility + _townHostilityValue;
			[_civData, "CivInfo", [_homePos, _individualHostility, _townHostility, _name]] call ALiVE_fnc_hashSet;

			[MOD(civInteractHandler), "CivData", _civData] call ALiVE_fnc_hashSet;
		};

		//-- Change civilian posture globally
		if (isNil "_townHostilityValue") exitWith {[_logic, "UpdateHostility", [_civ,_value,_townHostilityValue]] remoteExecCall [QUOTE(MAINCLASS),2]};

		_civID = _civ getVariable ["agentID", ""];
		if (_civID != "") then {
			_civProfile = [ALIVE_agentHandler, "getAgent", _civID] call ALIVE_fnc_agentHandler;
			_clusterID = _civProfile select 2 select 9;

			//-- Set town hostility
			_cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;
			_clusterHostility = [_cluster, "posture"] call ALIVE_fnc_hashGet;
			[_cluster, "posture", (_clusterHostility + _townHostilityValue)] call ALIVE_fnc_hashSet;

			//-- Set individual hostility
			_hostility = (_civProfile select 2) select 12;
			_hostility = _hostility + _value;
			[_civProfile, "posture", _hostility] call ALiVE_fnc_hashSet;
		};
	};

	case "getActivePlan": {
		_activeCommand = _arguments;

		switch (toLower _activeCommand) do {
			case "alive_fnc_cc_suicide": {
				_activePlan1 = "carrying out a suicide bombing";
				_activePlan2 = "strapping himself with explosives";
				_activePlan3 = "planning a bombing";
				_activePlan4 = "getting ready to bomb your forces";
				_activePlan5 = "about to bomb your forces";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
			case "alive_fnc_cc_suicidetarget": {
				_activePlan1 = "planning on carrying out a suicide bombing";
				_activePlan2 = "strapping himself with explosives";
				_activePlan3 = "planning a bombing";
				_activePlan4 = "getting ready to bomb your forces";
				_activePlan5 = "about to bomb your forces";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
			case "alive_fnc_cc_rogue": {
				_activePlan1 = "storing a weapon in his house";
				_activePlan2 = "stockpiling weapons";
				_activePlan3 = "planning on shooting a patrol";
				_activePlan4 = "looking for patrols to shoot at";
				_activePlan5 = "paid to shoot at your forces";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
			case "alive_fnc_cc_roguetarget": {
				_activePlan1 = "storing a weapon in his house";
				_activePlan2 = "stockpiling weapons";
				_activePlan3 = "planning on shooting a patrol";
				_activePlan4 = "looking for somebody to shoot at";
				_activePlan5 = "paid to shoot at your forces";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
			case "alive_fnc_cc_sabotage": {
				_activePlan1 = "planning on sabotaging a building";
				_activePlan2 = "blowing up a building";
				_activePlan3 = "planting explosives nearby";
				_activePlan4 = "getting ready to plant explosives";
				_activePlan5 = "paid to shoot at your forces";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
			case "alive_fnc_cc_getweapons": {
				_activePlan1 = "retrieving weapons from a nearby weapons depot";
				_activePlan2 = "planning on joining the insurgents";
				_activePlan3 = "getting ready to go to a nearby insurgent recruitment center";
				_activePlan4 = "getting ready to retrieve weapons from a cache";
				_activePlan5 = "paid to attack your forces";
				_activePlan6 = "forced to join the insurgents";
				_activePlan7 = "preparing to attack your forces";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
		};
	};

	case "toggleSearchMenu": {
		private ["_enable"];
		if (ctrlVisible 9240) then {_enable = false} else {_enable = true};

		CIVINTERACT_SEARCHBUTTON ctrlShow !_enable;

		{
			ctrlShow [_x, _enable];
		} forEach CIVINTERACT_INVENTORYCONTROLS;

		if (_enable) then {
			[MOD(civInteractHandler),"displayGearContainers"] call MAINCLASS;
		} else {
			CIVINTERACT_CONFISCATEBUTTON ctrlShow  false;
			CIVINTERACT_OPENGEARCONTAINER ctrlShow false;
		};
	};

	case "displayGearContainers": {
		private ["_configPath","_index"];
		_civ = [MOD(civInteractHandler), "Civ"] call ALiVE_fnc_hashGet;
		lbClear CIVINTERACT_GEARLIST;
		_index = 0;


		CIVINTERACT_OPENGEARCONTAINER ctrlSetText "View Contents";
		CIVINTERACT_OPENGEARCONTAINER buttonSetAction "[nil,'openGearContainer'] call ALiVE_fnc_civInteract";

		{
			if (_x != "") then {
				//-- Get config path
				_configPath = nil;
				_configPath = configfile >> "CfgWeapons" >> _x;
				if !(isClass _configPath) then {_configPath = configfile >> "CfgMagazines" >> _x};
				if !(isClass _configPath) then {_configPath = configfile >> "CfgVehicles" >> _x};
				if !(isClass _configPath) then {_configPath = configfile >> "CfgGlasses" >> _x};

				//-- Get item info
				if (isClass _configPath) then {
					_itemName = getText (_configPath >> "displayName");
					_itemPic = getText (_configPath >> "picture");

					CIVINTERACT_GEARLIST lbAdd _itemName;
					CIVINTERACT_GEARLIST lbSetPicture [_index, _itemPic];
					CIVINTERACT_GEARLIST lbSetData [_index, (configName _configPath)];
					_index = _index + 1;
				};
			};
		} forEach ([headgear _civ,goggles _civ,uniform _civ,vest _civ,backpack _civ] + (assignedItems _civ));

		[MOD(civInteractHandler),"CurrentGearMode", "Containers"] call ALiVE_fnc_hashSet;

		CIVINTERACT_GEARLIST ctrlAddEventHandler ["LBSelChanged",{[nil,"onGearClick", _this] call MAINCLASS}];
	};

	case "openGearContainer": {
		_civ = [MOD(civInteractHandler), "Civ"] call ALiVE_fnc_hashGet;
		_data = CIVINTERACT_GEARLIST lbData (lbCurSel CIVINTERACT_GEARLIST);

		if (_data == backpack _civ) exitWith {
			[nil,"displayContainerItems", backpackItems _civ] call MAINCLASS;
			[MOD(civInteractHandler),"CurrentGearMode", "Backpack"] call ALiVE_fnc_hashSet;

		};

		if (_data == vest _civ) exitWith {
			[nil,"displayContainerItems", vestItems _civ] call MAINCLASS;
			[MOD(civInteractHandler),"CurrentGearMode", "Vest"] call ALiVE_fnc_hashSet;
		};

		if (_data == uniform _civ) exitWith {
			[nil,"displayContainerItems", uniformItems _civ] call MAINCLASS;
			[MOD(civInteractHandler),"CurrentGearMode", "Uniform"] call ALiVE_fnc_hashSet;
		};

		CIVINTERACT_OPENGEARCONTAINER ctrlShow false;
	};

	case "displayContainerItems": {
		private ["_configPath","_index"];
		_items = _arguments;
		lbClear CIVINTERACT_GEARLIST;
		_index = 0;

		{
			//-- Get config path
			_configPath = nil;
			_configPath = configfile >> "CfgWeapons" >> _x;
			if !(isClass _configPath) then {_configPath = configfile >> "CfgMagazines" >> _x};
			if !(isClass _configPath) then {_configPath = configfile >> "CfgVehicles" >> _x};
			if !(isClass _configPath) then {_configPath = configfile >> "CfgGlasses" >> _x};

			//-- Get item info
			if (isClass _configPath) then {
				_itemName = getText (_configPath >> "displayName");
				_itemPic = getText (_configPath >> "picture");

				CIVINTERACT_GEARLIST lbAdd _itemName;
				CIVINTERACT_GEARLIST lbSetPicture [_index, _itemPic];
				CIVINTERACT_GEARLIST lbSetData [_index, (configName _configPath)];
				_index = _index + 1;
			};
		} forEach _arguments;

		CIVINTERACT_CONFISCATEBUTTON ctrlShow false;

		CIVINTERACT_OPENGEARCONTAINER ctrlSetText "Close Contents";
		CIVINTERACT_OPENGEARCONTAINER buttonSetAction "[nil,'displayGearContainers'] call ALiVE_fnc_civInteract";
	};

	case "onGearClick": {
		_index = lbCurSel CIVINTERACT_GEARLIST;
		_data = CIVINTERACT_GEARLIST lbData _index;
		_civ = [MOD(civInteractHandler),"Civ"] call ALiVE_fnc_hashGet;

		if (_index == -1) then {
			CIVINTERACT_CONFISCATEBUTTON ctrlShow false;
			CIVINTERACT_OPENGEARCONTAINER ctrlShow false;
		} else {
			CIVINTERACT_CONFISCATEBUTTON ctrlShow true;

			_civ = [MOD(civInteractHandler),"Civ"] call ALiVE_fnc_hashGet;

			if (_data in [backpack _civ,vest _civ,uniform _civ]) then {
				CIVINTERACT_OPENGEARCONTAINER ctrlShow true;
			} else {
				CIVINTERACT_OPENGEARCONTAINER ctrlShow false;
			};
		};
	};

	case "addToInventory": {
		_arguments params ["_receiver","_item"];
		_result = false;

		if (_receiver canAddItemToBackpack _item) then {
			player addItemToBackpack _item;
			_result = true;
		} else {
			if (_receiver canAddItemToVest _item) then {
				player addItemToVest _item;
				_result = true;
			} else {
				if (_receiver canAddItemToUniform _item) then {
					player addItemToUniform _item;
					_result = true;
				};
			};
		};
	};

	case "refreshContainer": {
		_container = [_logic,"CurrentGearMode"] call ALiVE_fnc_hashGet;
		_civ = [_logic,"Civ"] call ALiVE_fnc_hashGet;

		switch (_container) do {
			case "Backpack": {
				[nil,"displayContainerItems", backpackItems _civ] call MAINCLASS;
			};
			case "Vest": {
				[nil,"displayContainerItems", vestItems _civ] call MAINCLASS;
			};
			case "Uniform": {
				[nil,"displayContainerItems", uniformItems _civ] call MAINCLASS;
			};
			Default {
				[nil,"displayGearContainers"] call MAINCLASS;
			};
		};
	};

	case "confiscate": {
		private ["_exit"];
		_index = lbCurSel CIVINTERACT_GEARLIST;
		_item = CIVINTERACT_GEARLIST lbData _index;
		_civ = [MOD(civInteractHandler), "Civ"] call ALiVE_fnc_hashGet;
		_exit = false;

		switch true do {
			case (_item == backpack _civ): {
				_items = backpackItems _civ;
				_newBackpack = (backpack _civ) createVehicle (getPos _civ);
				removeBackpackGlobal _civ;
				{_newBackpack addItemCargoGlobal [_x,1]} forEach _items;

				_exit = true;
			};
			case (_item == vest _civ): {
				if !([nil,"addToInventory", [player,_item]] call MAINCLASS) then {
					_item createVehicle (getPos _civ);
				};

				removeVest _civ;
				_exit = true;
			};
			case (_item == uniform _civ): {
				if !([nil,"addToInventory", [player,_item]] call MAINCLASS) then {
					_item createVehicle (getPos _civ);
				};

				removeUniform _civ;
				_exit = true;
			};
			case (_item == headgear _civ): {
				if !([nil,"addToInventory", [player,_item]] call MAINCLASS) then {
					_item createVehicle (getPos _civ);
				};

				removeHeadgear _civ;
				_exit = true;
			};
			case (_item == goggles _civ): {
				if !([nil,"addToInventory", [player,_item]] call MAINCLASS) then {
					_item createVehicle (getPos _civ);
				};
				removeGoggles _civ;
				_exit = true;
			};
		};

		if (_exit) exitWith {[MOD(civInteractHandler),"refreshContainer"] call MAINCLASS};

		if (player canAddItemToBackpack _item) exitWith {
			player addItemToBackpack _item;
			_civ removeWeaponGlobal _item;_civ removeMagazineGlobal _item;_civ removeItem _item;
			[_logic,"displayGear"] call MAINCLASS;
			ctrlShow [CIVINTERACT_CONFISCATEBUTTON, false];

			[MOD(civInteractHandler),"refreshContainer"] call MAINCLASS;
		};

		if (player canAddItemToVest _item) exitWith {
			player addItemToVest _item;
			_civ removeWeaponGlobal _item;_civ removeMagazineGlobal _item;_civ removeItem _item;
			[_logic,"displayGear"] call MAINCLASS;
			ctrlShow [CIVINTERACT_CONFISCATEBUTTON, false];

			[MOD(civInteractHandler),"refreshContainer"] call MAINCLASS;
		};

		if (player canAddItemToUniform _item) exitWith {
			player addItemToUniform _item;
			_civ removeWeaponGlobal _item;_civ removeMagazineGlobal _item;_civ removeItem _item;
			[_logic,"displayGear"] call MAINCLASS;
			ctrlShow [CIVINTERACT_CONFISCATEBUTTON, false];

			[MOD(civInteractHandler),"refreshContainer"] call MAINCLASS;
		};

		hint "There is no room for this item in your inventory";
	};

	case "Detain": {
		//-- Function is exactly the same as ALiVE arrest/release --> Author: Highhead
		_civ = [_logic, "Civ"] call ALiVE_fnc_hashGet;

		closeDialog 0;

		if (!isNil "_civ") then {
			if !(_civ getVariable ["detained", false]) then {
				//-- Join caller group
				[_civ] joinSilent (group player);
				_civ setVariable ["detained", true, true];
			} else {
				//-- Join civilian group
				[_civ] joinSilent (createGroup civilian);
				_civ setVariable ["detained", false, true];
			};
		};
	};

	case "getDown": {
		_civ = [_logic, "Civ"] call ALiVE_fnc_hashGet;

		closeDialog 0;

		if (!isNil "_civ") then {
			[_civ] spawn {
				params ["_civ"];
				sleep 1;
				_civ disableAI "MOVE";
				_civ setUnitPos "DOWN";
				sleep (10 + (ceil random 20));
				_civ enableAI "MOVE";
				_civ setUnitPos "AUTO";
			};
		};
	};

	case "goAway": {
		_civ = [_logic, "Civ"] call ALiVE_fnc_hashGet;

		closeDialog 0;

		if (!isNil "_civ") then {
			[_civ] spawn {
				params ["_civ"];
				sleep 1;
				_civ setUnitPos "AUTO";
				_fleePos = [position _civ, 30, 50, 1, 0, 1, 0] call BIS_fnc_findSafePos;
				_civ doMove _fleePos;
			};
		};
	};

};



//-- Return result if any exists
if (!isNil "_result") then {_result} else {nil};