#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(civInteract);

/* ----------------------------------------------------------------------------
Function: MAINCLASS

Description:
Main handler for civilian interaction

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
Jman

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
#define CIVINTERACT_GATHERINTEL		(CIVINTERACT_DISPLAY displayCtrl 92316)
#define CIVINTERACT_HOSTILITYLABEL	(CIVINTERACT_DISPLAY displayCtrl 9247)
#define CIVINTERACT_NEGOTIATE		(CIVINTERACT_DISPLAY displayCtrl 92327)
#define CIVINTERACT_RATION			(CIVINTERACT_DISPLAY displayCtrl 92314)
#define CIVINTERACT_WATER			(CIVINTERACT_DISPLAY displayCtrl 92315)
#define CIVINTERACT_CALMDOWN		(CIVINTERACT_DISPLAY displayCtrl 92324)
#define CIVINTERACT_FOLLOW			(CIVINTERACT_DISPLAY displayCtrl 92320)
#define CIVINTERACT_STAY			(CIVINTERACT_DISPLAY displayCtrl 92321)
#define CIVINTERACT_HANDSUP			(CIVINTERACT_DISPLAY displayCtrl 92323)
#define CIVINTERACT_KNEEL			(CIVINTERACT_DISPLAY displayCtrl 92325)
#define CIVINTERACT_GETIN			(CIVINTERACT_DISPLAY displayCtrl 92326)
#define CIVINTERACT_STOP			(CIVINTERACT_DISPLAY displayCtrl 92310)
#define CIVINTERACT_GETDOWN			(CIVINTERACT_DISPLAY displayCtrl 92312)

switch (_operation) do {

	case "create": {
		_result = [] call ALiVE_fnc_hashCreate;
	};

	//-- Create logic on all localities
	case "init": {

		if (isNil QMOD(civInteractHandler)) then {
			//-- Get settings
			private ["_debug", "_factionEnemy", "_humanitarianDecrease", "_maxAllowAid", "_authorized"];

			waitUntil {_result = _logic getVariable "waterItems"; !isNil "_result"};

			private _waterItems = _logic getVariable ["waterItems", []];
			private _humratItems = _logic getVariable ["rationItems", []];

			_debug = _logic getVariable "debug";

			// Merge insurgentFaction multi-select array + insurgentFactionManual
			// comma-separated string into a deduped array. Backward-compat
			// with legacy SQMs that stored insurgentFaction as a single string.
			private _factionEnemyRaw    = _logic getVariable ["insurgentFaction", []];
			private _factionEnemyManual = _logic getVariable ["insurgentFactionManual", ""];
			private _factionsArr = if (typeName _factionEnemyRaw == "ARRAY") then {
				+_factionEnemyRaw
			} else {
				if (_factionEnemyRaw == "") then { [] } else {
					[[_factionEnemyRaw, " ", ""] call CBA_fnc_replace, ","] call CBA_fnc_split
				}
			};
			private _manualArr = if (_factionEnemyManual == "") then { [] } else {
				[[_factionEnemyManual, " ", ""] call CBA_fnc_replace, ","] call CBA_fnc_split
			};
			_factionEnemy = [];
			{
				if (typeName _x == "STRING" && {_x != ""} && {_x != "NONE"} && {!(_x in _factionEnemy)}) then {
					_factionEnemy pushBack _x;
				};
			} forEach (_factionsArr + _manualArr);

			_humanitarianDecrease = parseNumber (_logic getVariable["humanitarianHostilityChance", "20"]);
			_maxAllowAid = parseNumber (_logic getVariable["maxAllowAid", "3"]);
			_authorized = (_logic getVariable "limitInteraction") call ALiVE_fnc_stringListToArray;

			//-- Create interact handler object
			MOD(civInteractHandler) = [nil,"create"] call MAINCLASS;
			[MOD(civInteractHandler), "Debug", _debug] call ALiVE_fnc_hashSet;
			[MOD(civInteractHandler), "InsurgentFaction", _factionEnemy] call ALiVE_fnc_hashSet;
			[MOD(civInteractHandler), "authorized", _authorized] call ALiVE_fnc_hashSet;

			// -- Store init data
			_humanitarianData = [] call ALiVE_fnc_hashCreate;
			[_humanitarianData, "waterItems", _waterItems] call ALiVE_fnc_hashSet;
			[_humanitarianData, "humratItems", _humratItems] call ALiVE_fnc_hashSet;
			[_humanitarianData, "hostilityDecrease", _humanitarianDecrease] call ALiVE_fnc_hashSet;
			[_humanitarianData, "maxAllowAid", _maxAllowAid] call ALiVE_fnc_hashSet;
			[MOD(civInteractHandler), "humanitarianData", _humanitarianData] call ALiVE_fnc_hashSet;
		};
	};

	//-- On load
	case "openMenu": {
		// Guard against callers that pass a non-object arg shape (corrupt
		// MenuDef action dispatch, unexpected remote-exec param). Without
		// this, a stray caller could land here with _arguments = [] and
		// _civ would be an array that crashes later commands with type
		// errors, or worse, leak a scope-unbound _civ across sibling code.
		if (!(_arguments isEqualType objNull)) exitWith {};
		// `private` anchors _civ to this case block's scope. Previously
		// _civ = _arguments assigned unprivated, which lets SQF resolve
		// the name against any enclosing scope chain - fragile in nested
		// dialog-onUnload / BIS_fnc_MP contexts where the outer scope can
		// go stale between use sites within the same case body.
		private _civ = _arguments;

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

		// Gather Intel is one-shot per civilian. Hide the button if this
		// civ has already been queried, matching the ACE branch's
		// {isNil {_target getVariable "intelGathered"}} visibility
		// condition.
		CIVINTERACT_GATHERINTEL ctrlShow (isNil {_civ getVariable "intelGathered"});

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

		_arguments params ["_objectiveInstallations","_objectiveActions","_civInfo","_hostileCivInfo",["_intelQuality", [0,1,0,"Stabilize",10,0], [[]]]];

		_logic = MOD(civInteractHandler);

		//-- Create hash
		_civData = [] call ALIVE_fnc_hashCreate;
		private _civ = [_logic,"Civ"] call ALiVE_fnc_hashGet;
		_answersGiven = _civ getVariable ["AnswersGiven", []];

		//-- Hash data to logic
		[_civData, "Installations", _objectiveInstallations] call ALiVE_fnc_hashSet;		//-- [_factory,_HQ,_depot,_roadblocks]
		[_civData, "Actions", _objectiveActions] call ALiVE_fnc_hashSet;			//-- [_ambush,_sabotage,_ied,_suicide]
		[_civData, "CivInfo", _civInfo] call ALiVE_fnc_hashSet;				//-- [_homePos, _individualHostility, _townHostility]
		[_civData, "HostileCivInfo", _hostileCivInfo] call ALiVE_fnc_hashSet;			//-- [_civ,_homePos,_activeCommands]
		[_civData, "IntelQuality", _intelQuality] call ALiVE_fnc_hashSet;				//-- [chanceBonus, radiusMultiplier, markerDurationBonus, phase, exactMarkerChance, deceptionChance]
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

		// Effective hostility for this civ at dialog open. The full
		// indicator render and tier-driven button gating live in case
		// "refreshHostilityIndicator" so they can also be re-driven from
		// fnc_questionHandler after each question (the irritation post-
		// processing may have just bumped the civ's posture and the
		// player should see the dialog react in real time). The
		// Response-area "Civilian refuses to cooperate" hint stays
		// here - it's a one-shot at dialog open and refreshing it
		// mid-dialog would clobber the question response text the
		// player just received.
		private _civPosture = (_civInfo select 1) max 0 min 100;
		private _playerSide = str (side (group player));
		private _sideBaseline = if (!isNil "ALIVE_civilianHostility") then {
			[ALIVE_civilianHostility, _playerSide, 0] call ALiVE_fnc_hashGet
		} else { 0 };
		private _h = (_civPosture max _sideBaseline) max 0 min 100;

		if (_h >= 60) then {
			CIVINTERACT_RESPONSELIST ctrlSetStructuredText parseText (
				format ["<t color='#e64d4d' align='center'>%1</t>",
					localize "STR_ALIVE_CIV_INTERACT_REFUSES_COOPERATION"]
			);
		};

		[_logic, "refreshHostilityIndicator"] call MAINCLASS;

		[_logic,"enableMain"] call MAINCLASS;
	};

	//-- Re-renders the hostility indicator label + tier-driven button
	//   enable states from the current _civInfo cached on _logic. Called
	//   from case "loadData" on dialog open and from fnc_questionHandler
	//   after each question (UpdateHostility may have just bumped the
	//   posture via the irritation post-processing). Idempotent - safe
	//   to call repeatedly. Does NOT touch the Response area; the
	//   refuses-cooperation hint there is one-shot in loadData so a
	//   mid-dialog tier crossing doesn't overwrite the question response
	//   text the player just received.
	case "refreshHostilityIndicator": {
		private _civData = [_logic, "CivData"] call ALiVE_fnc_hashGet;
		if (isNil "_civData") exitWith {};
		private _civInfo = [_civData, "CivInfo"] call ALiVE_fnc_hashGet;
		if (isNil "_civInfo") exitWith {};
		private _civ = [_logic, "Civ"] call ALiVE_fnc_hashGet;
		if (isNil "_civ" || {isNull _civ}) exitWith {};

		// Effective hostility (same source-of-truth as loadData).
		private _civPosture = (_civInfo select 1) max 0 min 100;
		private _playerSide = str (side (group player));
		private _sideBaseline = if (!isNil "ALIVE_civilianHostility") then {
			[ALIVE_civilianHostility, _playerSide, 0] call ALiVE_fnc_hashGet
		} else { 0 };
		private _h = (_civPosture max _sideBaseline) max 0 min 100;

		// Indicator label render (DESCRIPTIVE / NUMERIC mode). Reuses
		// the per-civ deterministic perceived-offset, lazy-initialised
		// here on first call and broadcast so subsequent re-opens and
		// other clients see the same offset.
		private _hostilityMode = missionNamespace getVariable ["ALiVE_amb_civ_population_HostilityIndicator", "OFF"];
		if (_hostilityMode == "OFF") then {
			CIVINTERACT_HOSTILITYLABEL ctrlShow false;
		} else {
			if (isNil {_civ getVariable "ALiVE_CivPop_PerceivedOffset"}) then {
				_civ setVariable ["ALiVE_CivPop_PerceivedOffset", floor (random 11) - 5, true];
			};

			private _offset = _civ getVariable ["ALiVE_CivPop_PerceivedOffset", 0];
			private _perceived = (_h + _offset) max 0 min 100;

			private _label = "";
			private _color = [];
			switch (true) do {
				case (_perceived < 20): { _label = localize "STR_ALIVE_CIV_POP_HOSTILITY_BUCKET_FRIENDLY";  _color = [0.4,  0.8,  0.4,  1]; };
				case (_perceived < 40): { _label = localize "STR_ALIVE_CIV_POP_HOSTILITY_BUCKET_NEUTRAL";   _color = [0.7,  0.8,  0.4,  1]; };
				case (_perceived < 60): { _label = localize "STR_ALIVE_CIV_POP_HOSTILITY_BUCKET_WARY";      _color = [0.9,  0.8,  0.3,  1]; };
				case (_perceived < 80): { _label = localize "STR_ALIVE_CIV_POP_HOSTILITY_BUCKET_DEFIANT";   _color = [0.95, 0.55, 0.2,  1]; };
				default                 { _label = localize "STR_ALIVE_CIV_POP_HOSTILITY_BUCKET_HOSTILE";   _color = [0.9,  0.3,  0.3,  1]; };
			};

			private _text = if (_hostilityMode == "NUMERIC") then {
				format ["%1 (~%2", _label, _perceived] + "%)"
			} else {
				_label
			};

			CIVINTERACT_HOSTILITYLABEL ctrlSetText _text;
			CIVINTERACT_HOSTILITYLABEL ctrlSetTextColor _color;
			CIVINTERACT_HOSTILITYLABEL ctrlShow true;
		};

		// Tier-driven action restriction.
		//   Defiant (60-79): active set is Go Away, Go Home, Close,
		//                    Calm Down, Detain.
		//   Hostile (80+):   active set is Go Away, Go Home, Close,
		//                    Search, Detain (Calm Down locks out).
		//   Below Defiant:   full button set active.
		// Go Away, Go Home, and Close are NOT in the restrictable list -
		// they are always-available exits. Tooltip on disabled controls
		// reads "Civilian refuses cooperation". Idempotent re-runs let
		// the player watch buttons grey/ungrey as the civ's posture
		// crosses tier boundaries during the session.
		private _restrictable = [
			CIVINTERACT_NEGOTIATE, CIVINTERACT_GATHERINTEL,
			CIVINTERACT_RATION, CIVINTERACT_WATER, CIVINTERACT_QUESTIONLIST,
			CIVINTERACT_SEARCHBUTTON, CIVINTERACT_DETAIN, CIVINTERACT_CALMDOWN,
			CIVINTERACT_FOLLOW, CIVINTERACT_STAY,
			CIVINTERACT_HANDSUP, CIVINTERACT_KNEEL, CIVINTERACT_GETIN,
			CIVINTERACT_STOP, CIVINTERACT_GETDOWN
		];
		private _activeAtTier = switch (true) do {
			case (_h >= 80): { [CIVINTERACT_SEARCHBUTTON, CIVINTERACT_DETAIN] };
			case (_h >= 60): { [CIVINTERACT_CALMDOWN, CIVINTERACT_DETAIN] };
			default          { _restrictable };
		};
		private _refuses = (_h >= 60);
		private _refusesTooltip = localize "STR_ALIVE_CIV_INTERACT_REFUSES_TOOLTIP";

		{
			if (_x in _activeAtTier) then {
				_x ctrlEnable true;
				_x ctrlSetTooltip "";
			} else {
				if (_refuses) then {
					_x ctrlEnable false;
					_x ctrlSetTooltip _refusesTooltip;
				} else {
					_x ctrlEnable true;
					_x ctrlSetTooltip "";
				};
			};
		} forEach _restrictable;

		// GETIN/GETOUT toggle button - text + enable context-aware:
		//   civ in vehicle               -> "Get Out", enabled
		//   civ on foot, vehicle nearby  -> "Get In",  enabled
		//   civ on foot, no vehicle      -> "Get In",  greyed (no-vehicle tooltip)
		// Tier-restriction (above) still wins: at h>=60 the button is
		// already greyed with the refuses tooltip; this block only fires
		// the no-vehicle override when the tier check left it enabled.
		private _civInVehicle = (vehicle _civ != _civ);
		if (_civInVehicle) then {
			CIVINTERACT_GETIN ctrlSetText "Get Out";
		} else {
			CIVINTERACT_GETIN ctrlSetText "Get In";
			if (ctrlEnabled CIVINTERACT_GETIN) then {
				// Match the react GETIN target search - any alive movable
				// LandVehicle in range; the literal nearest one is what
				// react picks on click.
				private _candidates = nearestObjects [_civ, ["LandVehicle"], 50] select {
					alive _x && {canMove _x}
				};
				if (count _candidates == 0) then {
					CIVINTERACT_GETIN ctrlEnable false;
					CIVINTERACT_GETIN ctrlSetTooltip "No vehicle within range";
				};
			};
		};
	};

	case "enableMain": {
		//-- Remove EH's
		(COMMANDBOARD_DISPLAY displayCtrl COMMANDBOARD_MAINMENU) ctrlRemoveAllEventHandlers "LBSelChanged";

		//-- Clear list
		lbClear CIVINTERACT_QUESTIONLIST;

		//-- Build question list
		CIVINTERACT_QUESTIONLIST lbAdd  (localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_HOME");
		CIVINTERACT_QUESTIONLIST lbSetData [0, "Home"];

		CIVINTERACT_QUESTIONLIST lbAdd (localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_TOWN");
		CIVINTERACT_QUESTIONLIST lbSetData [1, "Town"];

		CIVINTERACT_QUESTIONLIST lbAdd (localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IEDS");
		CIVINTERACT_QUESTIONLIST lbSetData [2, "IEDs"];

		CIVINTERACT_QUESTIONLIST lbAdd (localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_INSURGENTS");
		CIVINTERACT_QUESTIONLIST lbSetData [3, "Insurgents"];

		CIVINTERACT_QUESTIONLIST lbAdd (localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_HIDEOUTS");
		CIVINTERACT_QUESTIONLIST lbSetData [4, "Hideouts"];

		CIVINTERACT_QUESTIONLIST lbAdd (localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_STRANGEBEHAVIOR");
		CIVINTERACT_QUESTIONLIST lbSetData [5, "StrangeBehavior"];

		CIVINTERACT_QUESTIONLIST lbAdd (localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_OPINION");
		CIVINTERACT_QUESTIONLIST lbSetData [6, "Opinion"];

		CIVINTERACT_QUESTIONLIST lbAdd (localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_TOWNOPINION");
		CIVINTERACT_QUESTIONLIST lbSetData [7, "TownOpinion"];

		CIVINTERACT_QUESTIONLIST lbAdd (localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_NEEDS");
		CIVINTERACT_QUESTIONLIST lbSetData [8, "Needs"];

		CIVINTERACT_QUESTIONLIST lbAdd (localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_PRESSURE");
		CIVINTERACT_QUESTIONLIST lbSetData [9, "Pressure"];

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
		private _civ = [_logic, "Civ"] call ALiVE_fnc_hashGet;
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
		//  Multi-faction: accept this OPCOM if ANY of its factions overlaps
		//  the insurgent-faction list from this module.
		for "_i" from 0 to (count OPCOM_instances - 1) step 1 do {
			_opcom = OPCOM_instances select _i;

			private _opcomFactions = [_opcom, "factions"] call ALiVE_fnc_hashGet;
			if ((_insurgentFaction arrayIntersect _opcomFactions) isNotEqualTo []) exitWith {
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

		private _askingSide = str (side (group _player));
		if !(_askingSide in ["EAST","WEST","GUER"]) then {_askingSide = "WEST"};

		private _supportPhase = "Stabilize";
		private _supportValue = 0;
		private _intelQuality = [0,1,0,_supportPhase,10,0];

		if !(isNil "_cluster") then {
			private _hostilityHash = [_cluster, "hostility", []] call ALIVE_fnc_hashGet;
			private _hostility = [_hostilityHash, _askingSide, 100] call ALIVE_fnc_hashGet;

			if (_hostility <= 0) then {
				_supportPhase = "Consolidate";
			} else {
				if (_hostility <= 25) then {
					_supportPhase = "Build";
				} else {
					if (_hostility <= 65) then {
						_supportPhase = "Engage";
					};
				};
			};

			if !(isNil "ALIVE_fnc_taskGetCivilianSupportState") then {
				private _supportState = [_cluster, _askingSide] call ALIVE_fnc_taskGetCivilianSupportState;
				if !(_supportState isEqualTo []) then {
					_supportValue = [_supportState, "support", 0] call ALIVE_fnc_hashGet;
					_supportPhase = [_supportState, "phase", _supportPhase] call ALIVE_fnc_hashGet;
				};
			};

			_supportValue = (_supportValue max 0) min 100;

			private _phaseBonus = switch (_supportPhase) do {
				case "Consolidate": {20};
				case "Build": {12};
				case "Engage": {6};
				default {0};
			};
			private _supportBonus = round (_supportValue * 0.1);
			private _chanceBonus = (_phaseBonus + _supportBonus) min 35;

			private _precisionMultiplier = switch (_supportPhase) do {
				case "Consolidate": {0.45};
				case "Build": {0.65};
				case "Engage": {0.8};
				default {1};
			};
			_precisionMultiplier = (_precisionMultiplier - (_supportValue * 0.002)) max 0.35;

			private _durationBonus = switch (_supportPhase) do {
				case "Consolidate": {30};
				case "Build": {20};
				case "Engage": {10};
				default {0};
			};
			private _exactMarkerChance = switch (_supportPhase) do {
				case "Consolidate": {55};
				case "Build": {35};
				case "Engage": {20};
				default {8};
			};
			_exactMarkerChance = (_exactMarkerChance + round (_supportValue * 0.2)) min 85;

			private _deceptionChance = switch (_supportPhase) do {
				case "Consolidate": {0};
				case "Build": {5};
				case "Engage": {12};
				default {20};
			};
			_deceptionChance = (_deceptionChance + round ((100 - _supportValue) * 0.1)) min 35;

			_intelQuality = [_chanceBonus, _precisionMultiplier, _durationBonus, _supportPhase, _exactMarkerChance, _deceptionChance];
		};

		_civData = [_objectiveInstallations, _objectiveActions, _civInfo,_hostileCivInfo,_intelQuality];

		// _civData call ALiVE_fnc_inspectArray;

		//-- Send data to client
		[nil,"loadData", _civData] remoteExecCall [QUOTE(MAINCLASS),_player];
	};

	case "getRole": {
		private ["_role"];
		private _civ = _arguments;
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
					_response1 = format [localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IRRITATED_HOSTILE_1", name _civ];
					_response2 = format [localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IRRITATED_HOSTILE_2", name _civ];
					_response3 = localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IRRITATED_HOSTILE_3";
					_response4 = localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IRRITATED_HOSTILE_4";
					_response5 = localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IRRITATED_HOSTILE_5";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText ((ctrlText CIVINTERACT_RESPONSELIST) + _response);
				};
			};
		} else {
			if (floor random 100 < (8 * _asked)) then {
				[MOD(civInteractHandler),"UpdateHostility", [_civ, 10]] call MAINCLASS;
				if (floor random 70 < (_asked * 5)) then {
					_response1 = format [localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IRRITATED_NOTHOSTILE_1", name _civ];
					_response2 = format [localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IRRITATED_NOTHOSTILE_2", name _civ];
					_response3 = localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IRRITATED_NOTHOSTILE_3";
					_response4 = localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IRRITATED_NOTHOSTILE_4";
					_response5 = localize "STR_ALIVE_CIV_INTERACT_QUESTIONS_IRRITATED_NOTHOSTILE_5";
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
			// -- Check if the caller is trying to increase or decrease hostility
			_townHostilityValue = if (_value < 0) then {floor random -4} else {floor random 4};
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
				_activePlan1 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SUICIDE_1";
				_activePlan2 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SUICIDE_2";
				_activePlan3 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SUICIDE_3";
				_activePlan4 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SUICIDE_4";
				_activePlan5 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SUICIDE_5";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
			case "alive_fnc_cc_suicidetarget": {
				_activePlan1 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SUICIDETARGET_1";
				_activePlan2 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SUICIDETARGET_2";
				_activePlan3 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SUICIDETARGET_3";
				_activePlan4 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SUICIDETARGET_4";
				_activePlan5 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SUICIDETARGET_5";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
			case "alive_fnc_cc_rogue": {
				_activePlan1 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_ROGUE_1";
				_activePlan2 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_ROGUE_2";
				_activePlan3 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_ROGUE_3";
				_activePlan4 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_ROGUE_4";
				_activePlan5 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_ROGUE_5";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
			case "alive_fnc_cc_roguetarget": {
				_activePlan1 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_ROGUETARGET_1";
				_activePlan2 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_ROGUETARGET_2";
				_activePlan3 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_ROGUETARGET_3";
				_activePlan4 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_ROGUETARGET_4";
				_activePlan5 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_ROGUETARGET_5";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
			case "alive_fnc_cc_sabotage": {
				_activePlan1 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SABOTAGE_1";
				_activePlan2 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SABOTAGE_2";
				_activePlan3 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SABOTAGE_3";
				_activePlan4 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SABOTAGE_4";
				_activePlan5 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_SABOTAGE_5";
				_result = [_activePlan1,_activePlan2,_activePlan3,_activePlan4,_activePlan5] call BIS_fnc_selectRandom;
			};
			case "alive_fnc_cc_getweapons": {
				_activePlan1 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_GETWEAPONS_1";
				_activePlan2 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_GETWEAPONS_2";
				_activePlan3 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_GETWEAPONS_3";
				_activePlan4 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_GETWEAPONS_4";
				_activePlan5 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_GETWEAPONS_5";
				_activePlan6 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_GETWEAPONS_6";
				_activePlan7 = localize "STR_ALIVE_CIV_INTERACT_ACTIVEPLAN_GETWEAPONS_7";
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
		private _civ = [MOD(civInteractHandler), "Civ"] call ALiVE_fnc_hashGet;
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
		private _civ = [MOD(civInteractHandler), "Civ"] call ALiVE_fnc_hashGet;
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
		private _civ = [MOD(civInteractHandler),"Civ"] call ALiVE_fnc_hashGet;

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
		private _civ = [_logic,"Civ"] call ALiVE_fnc_hashGet;

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
		private _civ = [MOD(civInteractHandler), "Civ"] call ALiVE_fnc_hashGet;
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

	//-- Unified verb surface (Phase 5b of amb_civ_placement arc).
	//   Existing dialog callers pass no _arguments and read the civ from
	//   the handler hash (behaviour preserved). Non-dialog callers (ACE
	//   interact menu, future vanilla single-action entry) pass the civ
	//   directly as _arguments; the OR-fallback below resolves either.
	case "Detain": {
		//-- Function is exactly the same as ALiVE arrest/release --> Author: Highhead
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};
		if (isNil "_civ") exitWith { closeDialog 0; };

		// Handcuffs requirement: when ACE is loaded, the player must
		// carry an ACE_CableTie (zip-tie) to INITIATE detention. The
		// item is not consumed - cuffs are reusable. Releasing a
		// previously-detained civ is exempt from the check so a player
		// who lost / dropped their cuffs can still free a civ they
		// detained earlier. Without ACE the legacy unconditional
		// behaviour stands so non-ACE missions are unaffected.
		private _alreadyDetained = _civ getVariable ["detained", false];
		private _aceLoaded = isClass (configFile >> "CfgPatches" >> "ace_main");
		if (_aceLoaded && {!_alreadyDetained} && {!("ACE_CableTie" in (items player))}) exitWith {
			hintSilent localize "STR_ALIVE_CIV_INTERACT_DETAIN_NEED_CUFFS";
			// Dialog stays open so the player can pick another action.
		};

		closeDialog 0;

		if (!_alreadyDetained) then {
			//-- Join caller group
			[_civ] joinSilent (group player);
			_civ setVariable ["detained", true, true];
		} else {
			//-- Join civilian group
			[_civ] joinSilent (createGroup civilian);
			_civ setVariable ["detained", false, true];
		};
	};

	case "Stop": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};

		closeDialog 0;

		if (!isNil "_civ") then {
			[_civ] spawn {
				params ["_civ"];
				sleep 1;
				_civ disableAI "MOVE";
				sleep (60 + (ceil random 20));
				_civ enableAI "MOVE";
				_civ setUnitPos "AUTO";
			};
		};
	};

	case "getDown": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};

		closeDialog 0;

		if (!isNil "_civ") then {
			[_civ] spawn {
				params ["_civ"];
				sleep 1;
				_civ disableAI "MOVE";
				_civ setUnitPos "DOWN";
				sleep (60 + (ceil random 20));
				_civ enableAI "MOVE";
				_civ setUnitPos "AUTO";
			};
		};
	};

	case "goAway": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};

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

	//-- New shared verbs (Phase 5b). Thin bridges so the vanilla dialog
	//   (5c), the sys_acemenu civilian branch (5d) and the classic
	//   scroll-wheel path (legacy) all call identical code. Each case
	//   accepts the civilian object directly as _arguments.

	//-- Negotiate: consolidates the five role-gated "Talk to <Role>"
	//   entries in fnc_addCivilianActions into a single context-aware
	//   verb. Role detection reuses the existing getRole case; the
	//   underlying flow still lives in ALIVE_fnc_selectRoleAction
	//   (10% hostility-reduce success, sector-wide shift, role-
	//   dependent magnitude). Only enabled when the civilian has one
	//   of the five role flags set; caller gates visibility.
	case "Negotiate": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};
		if (!isNil "_civ") then {
			// Dialog stays open through both success and failure paths
			// so the player can try other actions if the negotiation
			// failed (10% success rate per ALIVE_fnc_selectRoleAction).
			// The narrative result text appears on the side-panel UI
			// (ALiVE_fnc_displayMenu "openSideSmall") which coexists
			// with the civInteract dialog.
			[_civ, player] call ALIVE_fnc_selectRoleAction;
		};
	};

	//-- GatherIntel: hostility-aware intel reveal shared by the dialog
	//   button and the ACE branch. Four possible outcomes per attempt,
	//   all indistinguishable to the player at the moment of click
	//   except via the hint text:
	//
	//     1. REFUSAL  - very hostile civs refuse outright. No markers.
	//        Chance scales from 0 below hostility 50 to 60% at h=100,
	//        capped at 75%.
	//     2. NOTHING  - civ has nothing useful to share. Base chance
	//        gate (civIntelGatherChance, percent, default 30). No
	//        markers, no map open.
	//     3. DECEPTIVE - civ lies. Decoy installation markers placed
	//        at random positions 800-2800 m from the civ, styled
	//        identically to real markers. Deception chance scales
	//        from 0 at hostility 25 to ~45% at h=100, capped at 50%.
	//        Map opens, same success hint as truthful path - the
	//        ruse is only obvious on arrival at the marked location.
	//     4. TRUTHFUL - real reveal via OPCOMToggleInstallations
	//        within 2000 m of the civ.
	//
	//   The civilian's intel opportunity is consumed on ANY attempt
	//   via the intelGathered flag, so spammed attempts are prevented.
	//   The CLASSIC scroll-wheel path in fnc_addCivilianActions keeps
	//   its legacy behaviour (~10% availability + guaranteed truthful
	//   outcome) and does not route through this case.
	//
	//   Hint (not dumpR) - dumpR routes through sidechat which is
	//   hidden for most players. hint renders top-right over the
	//   map, visible as the markers appear.
	case "GatherIntel": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};
		if (!isNil "_civ") then {
			private _chance = missionNamespace getVariable ["ALiVE_amb_civ_population_IntelGatherChance", 30];
			private _h = _civ getVariable ["ALiVE_CivPop_Hostility", 30];
			_civ setVariable ["intelGathered", true];

			// Hide the button on the still-open dialog so the player sees
			// the attempt was consumed (matches the openMenu visibility
			// gate that hides on subsequent re-opens via the intelGathered
			// flag).
			CIVINTERACT_GATHERINTEL ctrlShow false;

			// Tier 1: refusal (hostility-driven)
			// Dialog stays open so the player can try other actions.
			private _refusalChance = ((((_h - 50) * 1.2) max 0) min 75);
			if (random 100 < _refusalChance) exitWith {
				hint (localize "STR_ALIVE_CIV_INTERACT_INTEL_REFUSED");
			};

			// Tier 2: base chance gate (civ has any info at all)
			// Dialog stays open so the player can try other actions.
			if (random 100 >= _chance) exitWith {
				hint (localize "STR_ALIVE_CIV_INTERACT_INTEL_NOTHING");
			};

			// Tier 3 vs Tier 4: deception vs truth (hostility-driven)
			// Success path - close the dialog so the map can take focus
			// and the markers are visible.
			private _deceptionChance = ((((_h - 25) * 0.6) max 0) min 50);
			private _deceptive = random 100 < _deceptionChance;

			closeDialog 0;
			openMap true;
			if (_deceptive) then {
				[getPosATL _civ] call ALiVE_fnc_gatherIntelDeceptive;
			} else {
				[getPosATL _civ, 2000] call ALiVE_fnc_OPCOMToggleInstallations;
			};
			hint (localize "STR_ALIVE_CIV_INTERACT_INTEL_REVEALED");
		};
	};

	//-- AdvCiv quick-command bridges. Each one is a passthrough to
	//   ALIVE_fnc_advciv_react with the appropriate verb string. The
	//   advciv layer already enforces active-advciv / blacklist /
	//   alive checks, so these stay thin. GetInVehicle takes a second
	//   argument (the vehicle to enter); advciv_react picks the
	//   nearest qualifying one when nil. closeDialog 0 fires before
	//   the action is dispatched so the civ is captured into _civ
	//   first (onUnload clears the handler hash); a no-op when called
	//   from a non-dialog path (ACE menu).
	case "Follow": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};
		closeDialog 0;
		if (!isNil "_civ") then { [_civ, "FOLLOW"] call ALIVE_fnc_advciv_react; };
	};

	case "StayHere": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};
		closeDialog 0;
		if (!isNil "_civ") then { [_civ, "STAY"] call ALIVE_fnc_advciv_react; };
	};

	case "GoHome": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};
		closeDialog 0;
		if (!isNil "_civ") then { [_civ, "GOHOME"] call ALIVE_fnc_advciv_react; };
	};

	case "HandsUp": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};
		closeDialog 0;
		if (!isNil "_civ") then { [_civ, "HANDSUP"] call ALIVE_fnc_advciv_react; };
	};

	case "CalmDown": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};
		closeDialog 0;
		if (!isNil "_civ") then { [_civ, "CALM"] call ALIVE_fnc_advciv_react; };
	};

	case "Kneel": {
		private _civ = if (_arguments isEqualType objNull) then {_arguments} else {[_logic, "Civ"] call ALiVE_fnc_hashGet};
		closeDialog 0;
		if (!isNil "_civ") then { [_civ, "KNEEL"] call ALIVE_fnc_advciv_react; };
	};

	case "GetInVehicle": {
		//-- Toggle dispatch:
		//     civ in a vehicle  -> GETOUT (player-coerced dismount + HANDSUP)
		//     civ on foot       -> GETIN  (advciv_react picks nearest empty
		//                                   vehicle within 50 m; or uses the
		//                                   _vehicle param if explicitly
		//                                   passed by a caller).
		//   The dialog button text + enable state is driven by
		//   case "refreshHostilityIndicator" so the player sees the right
		//   verb before clicking.
		private _civ = objNull;
		private _vehicle = objNull;
		if (_arguments isEqualType [] && {count _arguments > 0}) then {
			_civ = _arguments select 0;
			if (count _arguments > 1) then { _vehicle = _arguments select 1; };
		} else {
			if (_arguments isEqualType objNull) then { _civ = _arguments };
		};
		if (isNull _civ) then { _civ = [_logic, "Civ"] call ALiVE_fnc_hashGet };
		closeDialog 0;
		if (!isNil "_civ" && {!isNull _civ}) then {
			if (vehicle _civ != _civ) then {
				[_civ, "GETOUT"] call ALIVE_fnc_advciv_react;
			} else {
				if (isNull _vehicle) then {
					[_civ, "GETIN"] call ALIVE_fnc_advciv_react;
				} else {
					[_civ, "GETIN", _vehicle] call ALIVE_fnc_advciv_react;
				};
			};
		};
	};

	case "giveItem": {
		_arguments params ["_itemType"];
		private ["_civ", "_humanitarian", "_item", "_decreaseChance", "_maxAllowAid", "_consumed"];

		_civ = [_logic, "Civ"] call ALiVE_fnc_hashGet;
		_humanitarian = [_logic, "humanitarianData"] call ALiVE_fnc_hashGet;
		_items = [_humanitarian, _itemType] call ALiVE_fnc_hashGet;
		_decreaseChance = [_humanitarian, "hostilityDecrease"] call ALiVE_fnc_hashGet;
		_maxAllowAid = [_humanitarian, "maxAllowAid"] call ALiVE_fnc_hashGet;

		// Check amount of aid already received
		_consumed = _civ getVariable[QGVAR(consumedItems), 0];
		if (_consumed >= _maxAllowAid) exitWith {
			["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
			["setSideSmallText",localize "STR_ALIVE_CIV_POP_TOOMUCHAID"] spawn ALIVE_fnc_displayMenu;
		};

		// Ensure item is in the inventory & remove it
		private _validItems = ((vestItems player) + (uniformItems player) + (backpackItems player)) arrayIntersect _items;
		if (_validItems isequalto []) exitWith {
			["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
			["setSideSmallText",localize "STR_ALIVE_CIV_POP_NOAID"] spawn ALIVE_fnc_displayMenu;
		};

		private _item = _validItems select 0;

		if (_item in vestItems player) then
		{
			player removeItemFromVest _item;
		} else {
			if (_item in uniformItems player) then {
				player removeItemFromUniform _item;
			} else {
				if (_item in backpackItems player) then {
					player removeItemFromBackpack _item;
				};
			};
		};


		_civ setVariable[QGVAR(consumedItems), (_consumed + 1)];
		[_civ] spawn {
			params ["_civ"];
			player playAction "putdown"; sleep 0.2; _civ playAction "putdown";
		};

		if (_decreaseChance > random 100) then {
			// Use local `call MAINCLASS` (matching the question handler's
			// UpdateHostility call site) so the client-side CivData cache on
			// _logic is updated synchronously - that's the same source the
			// refreshHostilityIndicator hook below reads from. The previous
			// `remoteExecCall [..., 2]` only updated server-side agent /
			// cluster state and left the open dialog's cached posture stale,
			// so the player wouldn't see the indicator label or tier-driven
			// button states react to a successful give until the next
			// question or dialog re-open.
			[_logic, "UpdateHostility", [_civ, -7]] call MAINCLASS;
			[_logic, "refreshHostilityIndicator"] call MAINCLASS;
		};
	};
};



//-- Return result if any exists
if (!isNil "_result") then {_result} else {nil};
