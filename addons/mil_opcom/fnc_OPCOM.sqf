//#define DEBUG_MODE_FULL
#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOM);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOM
Description:
Virtual AI Controller (WIP)

Base class for OPCOM objects to inherit from

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
init
createhashobject
createobjectivesbydistance
objectives
analyzeclusteroccupation
setorders
synchronizeorders
NearestAvailableSection
setstatebyclusteroccupation
selectordersbystate

Examples:
(begin example)
// create OPCOM objectives of SEP (ingame object for now) objectives and distance
_objectives = [_logic, "createobjectivesbydistance",SEP] call ALIVE_fnc_OPCOM;
(end)

See Also:

Author:
Highhead
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_OPCOM

TRACE_1("OPCOM - input",_this);

params [
    ["_logic", objNull, [objNull,[],""]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
private _result = nil;

/*
_blackOps = ["id"];

if !(_operation in _blackOps) then {
    _check = "nothing"; if !(isnil "_args") then {_check = _args};

    ["op: %1 | args: %2",_operation,_check] call ALiVE_fnc_DumpR;
};
*/

#define MTEMPLATE "ALiVE_OPCOM_%1"
#define GET_OBJECTIVE_DEBUG_MARKER(ID) (format [MTEMPLATE, ID])

switch (_operation) do {
    case "create": {
        private ["_logic"];

        _logic = (createGroup sideLogic) createUnit [QUOTE(ADDON), [0,0], [], 0, "NONE"];

        TRACE_1("Creating class on all localities",true);

        // initialise module game logic on all localities
        _logic setVariable ["super", SUPERCLASS];
        _logic setVariable ["class", MAINCLASS];

        _result = _logic;
    };

    case "init": {
        if (isServer) then {
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_OPCOM"];

            if (isnil QUOTE(ADDON)) then {
                ADDON = _logic;

                PublicVariable QUOTE(ADDON);
            };
            TRACE_1("After module init",_logic);

            TRACE_1("Starting process",_logic);

            _logic setVariable ["startupComplete", false];
            [_logic,"start"] call MAINCLASS;
            _logic setVariable ["startupComplete", true, true];
        };
    };

    case "start": {
        if (!isServer) exitwith {};

        // parse module parameters

        private _customNameParam = _logic getvariable ["customName",""];
        private _type = _logic getvariable ["controltype","invasion"];
        private _occupation = (parseNumber format ["%1", _logic getvariable ["asym_occupation",-100]])/100;
        private _intelChance = (parseNumber format ["%1", _logic getvariable ["intelchance",-100]])/100;
        // Phase 4: faction sources, all unioned below.
        //   factions       : multi-select listbox (primary UX,
        //                    ORIGINAL property so old `factions`
        //                    Edit data loads via multi-select
        //                    Load handler's CSV/array parser)
        //   factionsManual : Edit field (manual override for
        //                    unloaded mod factions)
        //   faction1-4     : hidden legacy slots, applied via
        //                    ALiVE_HiddenAttribute expression
        //                    so old missions that picked
        //                    factions through the pre-Phase-4
        //                    single-faction dropdowns still
        //                    work
        private _factions = [_logic getvariable ["factions",[]]] call ALiVE_fnc_parseArrayFromString;
        private _factionsManual = [_logic getvariable ["factionsManual",[]]] call ALiVE_fnc_parseArrayFromString;
        private _faction1 = _logic getvariable ["faction1",""];
        private _faction2 = _logic getvariable ["faction2",""];
        private _faction3 = _logic getvariable ["faction3",""];
        private _faction4 = _logic getvariable ["faction4",""];
        private _simultanObjectives = parseNumber format ["%1", _logic getvariable ["simultanObjectives",10]];
        private _minAgents = parseNumber format ["%1", _logic getvariable ["minAgents",2]];
        private _asymForceLimit = floor (parseNumber format ["%1", _logic getvariable ["asymForceLimit",-1]]);
        private _recruitCycleMin = (parseNumber format ["%1", _logic getvariable ["recruitCycleMin",30]]) max 0;
        private _recruitCycleMax = (parseNumber format ["%1", _logic getvariable ["recruitCycleMax",60]]) max _recruitCycleMin;

        private _recruitAttemptLimit = floor (parseNumber format ["%1", _logic getvariable ["recruitAttemptLimit",0]]);
        _recruitAttemptLimit = _recruitAttemptLimit max -1;

        private _recruitSuccessChance = ((parseNumber format ["%1", _logic getvariable ["recruitSuccessChance",50]]) max 0) min 100;
        private _hostilityPresenceMultiplier = (parseNumber format ["%1", _logic getvariable ["hostilityPresenceMultiplier",1]]) max 0;
        private _hostilityInstallationMultiplier = (parseNumber format ["%1", _logic getvariable ["hostilityInstallationMultiplier",1]]) max 0;
        private _hostilityInstallationInterval = ((parseNumber format ["%1", _logic getvariable ["hostilityInstallationInterval",10]]) max 0) * 60;
        private _taskProfileCountOverridesRaw = _logic getvariable ["taskProfileCountOverrides",""];
        private _taskProfileTypeOverridesRaw = _logic getvariable ["taskProfileTypeOverrides",""];
        private _civicRecruitmentMultiplier = (parseNumber format ["%1", _logic getvariable ["civicRecruitmentMultiplier",1]]) max 0;
        private _civicInstallationMultiplier = (parseNumber format ["%1", _logic getvariable ["civicInstallationMultiplier",1]]) max 0;
        private _civicRetaliationChanceRaw = (parseNumber format ["%1", _logic getvariable ["civicRetaliationChance",0]]) max 0;
        private _civicRetaliationChance = if (_civicRetaliationChanceRaw >= 1) then {
            (_civicRetaliationChanceRaw min 100) / 100
        } else {
            _civicRetaliationChanceRaw min 1
        };
        private _civicRetaliationIntensity = (parseNumber format ["%1", _logic getvariable ["civicRetaliationIntensity",1]]) max 0;
        private _debug = ((_logic getvariable ["debug","false"]) == "true");
        private _persistent = ((_logic getvariable ["persistent","false"]) == "true");
        private _reinforcements = call compile (_logic getvariable ["reinforcements","0.9"]);
        private _roadblocks = (parseNumber format ["%1", _logic getvariable ["roadblocks",1]]) > 0;
        // #697 Phase 2.1: AI-driven friendly destroy of enemy asymmetric
        // installations. Read the mode string here; the behavioural
        // implementation lands in follow-up commits (proximity first,
        // then objective-capture). Valid values: "off", "proximity",
        // "capture", "both". Default "proximity" preserves the nicer
        // UX the issue asked for without forcing "both" on mission-
        // makers upgrading.
        private _friendlyDisableMode = _logic getvariable ["asym_friendlyDisableInstallations","proximity"];

        // Issue #355 - asymmetric progressive recruitment. Controls
        // whether insurgent recruitment unlocks heavier vehicle
        // tiers as aggregate hostility rises. "off" preserves the
        // legacy infantry-only recruitment behaviour. Runtime
        // logic lives in fnc_INS_helpers.sqf's recruitment loop
        // + sampleOpcomHostility / classifyGroupTier /
        // buildTieredGroupRoster helpers.
        private _asymEscalationIntensity = _logic getvariable ["asym_escalationIntensity","off"];

        // #861: configurable per-OPCOM list of CfgVehicles parent
        // class names whose group entries are excluded from the
        // asymmetric tiered roster. Default matches the previous
        // hard-coded behaviour (no tanks / planes / helis / ships)
        // so existing missions keep working without a touch;
        // mission-makers running state-backed insurgent factions
        // can edit the comma-separated list to widen recruitment.
        private _asymExcludeRaw = _logic getVariable ["asym_excludeKinds", "Tank,Plane,Helicopter,Ship"];
        private _asymExcludeKinds = [];
        {
            private _t = _x;
            while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
            while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do { _t = _t select [0, count _t - 1] };
            if (_t != "") then { _asymExcludeKinds pushBackUnique _t };
        } forEach ([_asymExcludeRaw, ","] call CBA_fnc_split);

        private _position = getposATL _logic;

        //Priority rule: if the Phase-4 sources (`factions`
        //multi-select and/or `factionsManual` free-text
        //override) have any non-empty entries, they are the
        //sole source of truth - the hidden legacy faction1-4
        //slots are IGNORED. Only when BOTH Phase-4 sources
        //are empty do we fall back to legacy slots (so
        //pre-Phase-4 missions that haven't been re-opened /
        //re-saved in the new Eden still run with their old
        //single-select picks).
        //
        //Previously this union'd all four sources, which let
        //pre-Phase-4 legacy defaults (typically "BLU_F" in
        //faction1) pollute the runtime faction list any time
        //a migrated mission's mission-maker picked a
        //different faction in the new multi-select. Priority
        //model means the mission-maker's explicit multi-
        //select choice is authoritative and the hidden
        //legacy data is inert until needed.
        //
        //All entries still deduped and filtered for empty /
        //"NONE" sentinel regardless of source.
        private _primary = _factions + _factionsManual;
        private _primaryNonEmpty = ({typeName _x == "STRING" && {_x != ""} && {_x != "NONE"}} count _primary) > 0;
        private _allFactionSources = if (_primaryNonEmpty) then {
            _primary
        } else {
            [_faction1, _faction2, _faction3, _faction4]
        };
        _factions = [];
        {
            if (typeName _x == "STRING" && {_x != ""} && {_x != "NONE"} && {!(_x in _factions)}) then {
                _factions pushBack _x;
            };
        } forEach _allFactionSources;

        //Pre-Phase-4 the implicit default came from faction1's
        //"BLU_F" defaultValue (the four single-faction slots
        //guaranteed _factions had at least one entry). Phase 4
        //preserves the same fallback so a misconfigured module
        //doesn't crash on the _factions select 0 below - just
        //logs a warning so the mission-maker can see they need
        //to populate Factions.
        if (_factions isequalto []) then {
            [
                "ALiVE OPCOM init WARNING: AI Commander '%1' has no factions configured (Factions multi-select empty AND Factions manual override empty). Defaulting to ['BLU_F']. Pick at least one faction in the Factions multi-select to silence this.",
                _customName
            ] call ALiVE_fnc_Dump;
            _factions pushBack "BLU_F";
        };

        private _taskProfileCountOverrides = [_logic, "parseTaskProfileCountOverrides", _taskProfileCountOverridesRaw] call MAINCLASS;
        private _taskProfileTypeOverrides = [_logic, "parseTaskProfileTypeOverrides", _taskProfileTypeOverridesRaw] call MAINCLASS;

        // determine side

        private _side = [(_factions select 0) call ALiVE_fnc_factionSide] call ALiVE_fnc_sideToSideText;
        if (_side == "NULL") then {
            ["ALiVE OPCOM init ERROR: AI Commander has invalid side. Factions = %1", _factions] call ALiVE_fnc_Dump;
            _side = "EAST";
        };

        ([_side] call ALiVE_fnc_getSideAllegiances) params ["_sidesEnemy","_sidesFriendly"];
        // the helper only reports how the OTHER sides align, so our own side is
        // absent from both lists. The occupation analysis bins nearby profiles by
        // side membership, so ours has to be listed friendly - without it an
        // objective our own troops hold matches neither list, reads as unheld and
        // gets ordered attacked.
        _sidesFriendly pushBackUnique _side;

        // set custom name

        private _customName = if (isNil "_customNameParam" || _customNameParam == "") then {
            //set default Name as "[SIDE] Commander" if none provided for backwords compatibility
            format ["%1 Commander", [_side] call Alive_fnc_sideTextToLong]
        } else {
            _customNameParam
        };

        //Finally set common data

        private _opcomID = str (floor (_position select 0)) + str (floor (_position select 1));

        private _handler = [[
            ["class", QUOTE(MAINCLASS)],
            ["side", _side],
            ["factions", _factions],
            ["sidesenemy", _sidesEnemy],
            ["sidesfriendly", _sidesFriendly],
            ["position", _position],
            ["simultanobjectives", _simultanObjectives],
            ["minAgents", _minAgents],
            ["asymForceLimit", _asymForceLimit],
            ["recruitCycleMin", _recruitCycleMin],
            ["recruitCycleMax", _recruitCycleMax],
            ["recruitAttemptLimit", _recruitAttemptLimit],
            ["recruitSuccessChance", _recruitSuccessChance],
            ["hostilityPresenceMultiplier", _hostilityPresenceMultiplier],
            ["hostilityInstallationMultiplier", _hostilityInstallationMultiplier],
            ["hostilityInstallationInterval", _hostilityInstallationInterval],
            ["taskProfileCountOverrides", _taskProfileCountOverrides],
            ["taskProfileTypeOverrides", _taskProfileTypeOverrides],
            ["civicRecruitmentMultiplier", _civicRecruitmentMultiplier],
            ["civicInstallationMultiplier", _civicInstallationMultiplier],
            ["civicRetaliationChance", _civicRetaliationChance],
            ["civicRetaliationIntensity", _civicRetaliationIntensity],
            ["opcomID", _opcomID],
            ["debug", _debug],
            ["persistent", _persistent],
            ["module", _logic],
            ["reinforcements", _reinforcements],
            ["asym_occupation", _occupation],
            ["controltype", _type],
            ["intelchance", _intelChance],
            ["roadblocks", _roadblocks],
            ["friendlyDisableMode", _friendlyDisableMode],
            ["asymEscalationIntensity", _asymEscalationIntensity],
            ["asymExcludeKinds", _asymExcludeKinds],
            ["name", _customName],
            ["objectives", []],
            ["pendingorders", []]
        ]] call ALIVE_fnc_hashCreate;

        _logic setVariable ["handler", _handler];

        //Add to OPCOM_instances global array for easier access

        if (isnil "OPCOM_instances") then {
            OPCOM_instances = [];
        };
        OPCOM_instances pushback _handler;

        missionnamespace setvariable [
            format ["OPCOM_%1", (count OPCOM_instances) - 1], // -1 to maintain zero index
            _handler
        ];

        // Issue #697 Phases 2.2 + 2.3: periodic scan lets
        // friendly AI automatically disable this OPCOM's
        // asymmetric installations (IED factory / Recruitment HQ
        // / Weapons depot) via two independent triggers -
        // proximity presence (friendly units within ~150 m of
        // the installation) and objective capture (a friendly
        // OPCOM has a "defending" objective overlapping the
        // insurgent objective). Gated on asymmetric controltype
        // AND friendlyDisableMode != "off" - the validator
        // function itself decides which trigger branch to run
        // per the mode value. Loop self-terminates when the
        // OPCOM's module logic is deleted - the dispose path
        // calls deleteVehicle _module, so `isNull _module`
        // becomes true on the next wake and the loop breaks.
        if (_type == "asymmetric" && {_friendlyDisableMode != "off"}) then {
            [_handler] spawn {
                params ["_handler"];
                private _SCAN_INTERVAL = 30; // seconds between scans
                while {true} do {
                    sleep _SCAN_INTERVAL;
                    private _module = [_handler, "module", objNull] call ALiVE_fnc_HashGet;
                    if (isNull _module) exitWith {};
                    [_handler] call ALIVE_fnc_OPCOMfriendlyDisableInstallations;
                };
            };
        };

        if (["ALiVE_mil_c2istar"] call ALIVE_fnc_isModuleAvailable) then {
            // G2 intel pipeline setup for each synced C2ISTAR.
            // Wrapped in a spawn because the waituntil on the
            // C2ISTAR's startupComplete flag otherwise blocks
            // this OPCOM's init: C2ISTAR's own init can take
            // ~14 s (player-side resolution + static data
            // loading), and holding OPCOM init open that long
            // locks the module init phase. Latent bug -
            // previously masked because the C2ISTAR USAGE text
            // told mission-makers never to sync it, so the
            // foreach saw an empty list. Now that the USAGE
            // text recommends syncing (per the issue that
            // surfaced this), the wait is actually reached.
            // Asynchronous G2 creation is safe: OPCOM's init
            // doesn't consume the G2 reference; it's only used
            // later by the "listen" / spotrep paths which no-op
            // while G2 is nil (_G2 getVariable checks handle
            // absence gracefully).
            [_logic, _handler, _side] spawn {
                params ["_logic", "_handler", "_side"];
                {
                    if (typeof _x == "ALiVE_mil_c2istar") then {
                        waituntil {_x getVariable ["startupComplete",false]};
                        
                        // Read opcomIntelSides from the SPECIFIC C2ISTAR
                        // that's synced to this OPCOM (the foreach
                        // iteration variable), not the global ALIVE_MIL_C2ISTAR
                        // singleton - the global tracks only the
                        // last-initialised module and would skip per-
                        // sync configuration in a multi-C2ISTAR mission.
                        private _displayIntel = [_x,"displayIntel"] call ALiVE_fnc_C2ISTAR;
                        private _opcomIntelSides = [_x,"opcomIntelSides"] call ALiVE_fnc_C2ISTAR;
                        if (_displayIntel && {_side in _opcomIntelSides}) then {
                            private _G2 = [nil,"create", [_handler]] call ALiVE_fnc_G2;
                            [_G2,"start"] call ALiVE_fnc_G2;
                            [_handler,"G2", _G2] call ALiVE_fnc_hashSet;
                        };
                    };
                } foreach (synchronizedObjects _logic);
            };
        };

        //Spread Intel Information for this OPCOMs side
        missionnamespace setvariable [
            format ["ALiVE_MIL_OPCOM_INTELCHANCE_%1", [_side] call ALiVE_fnc_SideTextToObject],
            _intelChance,
            true
        ];

        // find synced CQB modules, wait for their init to finish, store them
        private _startTime = diag_ticktime;
        private _syncedCQBModules = (synchronizedObjects _logic) select {typeof _x == "ALiVE_mil_cqb"};
        {
            waituntil { _x getVariable ["startupComplete", false] };
        } foreach _syncedCQBModules;

        [_handler,"CQB", _syncedCQBModules] call ALiVE_fnc_HashSet;
        ["ALiVE_fnc_OPCOM - %1: %2 seconds spent waiting for CQB module init", _customName, diag_ticktime - _startTime] call ALiVE_fnc_Dump;

        //Set dynamic data depending on type, like section sizes
        switch (_type) do {
            case ("invasion") : {
                [_handler, "sectionsamount_attack", 4] call ALiVE_fnc_HashSet;
                [_handler, "sectionsamount_reserve", 1] call ALiVE_fnc_HashSet;
                [_handler, "sectionsamount_defend", 2] call ALiVE_fnc_HashSet;
            };
            case ("occupation") : {
                [_handler, "sectionsamount_attack", 4] call ALiVE_fnc_HashSet;
                [_handler, "sectionsamount_reserve", 1] call ALiVE_fnc_HashSet;
                [_handler, "sectionsamount_defend", 5] call ALiVE_fnc_HashSet;
            };
            case ("asymmetric") : {
                [_handler, "sectionsamount_attack", 1] call ALiVE_fnc_HashSet;
                [_handler, "sectionsamount_reserve", 1] call ALiVE_fnc_HashSet;
                [_handler, "sectionsamount_defend", 1] call ALiVE_fnc_HashSet;

                //initialise INS helpers
                call ALiVE_fnc_INS_helpers;

                // Issue #355: build a tiered group roster
                // per faction now that the INS helpers are
                // loaded. Each call to
                // ALiVE_fnc_INS_buildTieredGroupRoster
                // walks the faction's CfgGroups, classifies
                // each group via INS_classifyGroupTier
                // (excludes tanks/jets/helis/ships), and
                // buckets the rest into infantry/light/medium.
                // Cached on the handler so the recruitment
                // loop picks from the pre-built roster each
                // cycle instead of re-walking CfgGroups.
                private _tieredGroupRoster = [] call ALiVE_fnc_hashCreate;
                private _excludeKinds = [_handler, "asymExcludeKinds", ["Tank", "Plane", "Helicopter", "Ship"]] call ALiVE_fnc_HashGet;
                {
                    private _factionRoster = [_x, _excludeKinds] call ALiVE_fnc_INS_buildTieredGroupRoster;
                    [_tieredGroupRoster, _x, _factionRoster] call ALiVE_fnc_hashSet;
                } foreach _factions;
                [_handler,"tieredGroupRoster", _tieredGroupRoster] call ALiVE_fnc_HashSet;
                [_handler,"escalationLevel", "infantry"] call ALiVE_fnc_HashSet;

                private _syncedCQBModules = [_handler,"CQB", []] call ALiVE_fnc_HashGet;
                [_syncedCQBModules] call ALiVE_fnc_resetCQB;
            };
        };

        ([_handler, ["sectionsamount_attack","sectionsamount_defend","sectionsamount_reserve"]] call ALiVE_fnc_hashGetMany) params [
            "_sectionAmountAttack",
            "_sectionAmountDefend",
            "_sectionAmountReserve"
        ];

        private _attackSectionCount = [_handler,"getTaskProfileCount", ["attack", _sectionAmountAttack]] call MAINCLASS;
        private _defendSectionCount = [_handler,"getTaskProfileCount", ["defend", _sectionAmountDefend]] call MAINCLASS;
        private _reserveSectionCount = [_handler,"getTaskProfileCount", ["reserve", _sectionAmountReserve]] call MAINCLASS;

        [_handler,"sectionsamount_attack", _attackSectionCount] call ALiVE_fnc_HashSet;
        [_handler,"sectionsamount_defend", _defendSectionCount] call ALiVE_fnc_HashSet;
        [_handler,"sectionsamount_reserve", _reserveSectionCount] call ALiVE_fnc_HashSet;

        /*
        CONTROLLER  - coordination
        */

        if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
            ["No Virtual AI system module was found! Please use this module in your mission!"] call ALIVE_fnc_dumpR;
        };

        //Wait for virtual profiles ready, output debug for tracing mission makers errors (like forgetting Virtual AI System module)
        while {
            (isnil "ALiVE_ProfileHandler") || { !([ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet) }
        } do {
            ["OPCOM Waiting for Virtual AI System..."] call ALiVE_fnc_dump;
             sleep 1;
        };

        //Wait for sector grid to be ready
        //waituntil {["OPCOM Waiting for Sector Grid System..."] call ALiVE_fnc_dump; count (([([ALIVE_sectorGrid, "positionToSector", [1,1,0]] call ALIVE_fnc_sectorGrid),"data"] call ALIVE_fnc_hashGet) select 1) > 0};

        private _objectives = [];

        //Load Data from DB
        if (_persistent && { !isNil "ALIVE_sys_data" } && {!ALIVE_sys_data_DISABLED}) then {
            _objectives = [_handler,"loadObjectivesDB"] call MAINCLASS;

            ["OPCOM loaded %1 objectives from DB!", count _objectives] call ALiVE_fnc_dump;
        
            // Load starting forces
            private _missionName = [missionName, "%20", "-"] call CBA_fnc_replace;
            private _key = format ["%1_%2-OPCOM_%3-starting-forces", ALIVE_sys_data_GROUP_ID, _missionName, [_handler,"opcomID"] call CBA_fnc_hashGet];
            private _result = [GVAR(DATAHANDLER),"read", ["mil_opcom", [], _key]] call ALIVE_fnc_Data;

            if (_result isEqualType []) then {
                private _startingForces = [_result,"data"] call CBA_fnc_hashGet;
                [_handler,"startForceStrength", _startingForces] call CBA_fnc_hashSet;
            };

            [_handler,"objectives", _objectives] call ALiVE_fnc_hashSet;
        };

        //If no data was loaded from DB then get objectives data from other modules or synced Location modules!
        if (_objectives isequalto []) then {
            {
                private _moduleObjectives = [_handler,"getModuleObjectives", _x] call MAINCLASS;
                if (!isnil "_moduleObjectives") then {
                    _objectives append _moduleObjectives;
                };
            } foreach (synchronizedObjects _logic);

            private _objectiveSortStrategy = switch (_type) do {
                case ("occupation") :   { "strategic" };
                case ("invasion")   :   { "distance" };
                case ("asymmetric") :   { "asymmetric" };
            };

            _objectives = [_handler,"createObjectives", [_objectives,_objectiveSortStrategy]] call MAINCLASS;

            ["OPCOM created %1 new objectives!", count _objectives] call ALiVE_fnc_dump;
        };

        ///////////
        //Validate
        ///////////

        private _isValid = [_handler,"validateStartupState"] call MAINCLASS;
        if (!_isValid) exitwith {};

        ///////////
        //Startup
        ///////////


        // Perform initial cluster occupation and troops analysis as MP modules are finished
        private _clusterOccupationAnalysis = [_handler,"analyzeclusteroccupation", [_sidesFriendly, _sidesEnemy]] call MAINCLASS;
        private _forcesInit = [_handler,"scantroops"] call MAINCLASS;

        ["OPCOM %1 Initial analysis done...", _side] call ALiVE_fnc_dump;
        ["OPCOM and TACOM %1 starting...",_side] call ALiVE_fnc_Dump;

        switch _type do {
            case "occupation": {
                private _opcomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                private _tacomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";

                [_handler,"OPCOM_FSM", _opcomFSM] call ALiVE_fnc_HashSet;
                [_handler,"TACOM_FSM", _tacomFSM] call ALiVE_fnc_HashSet;
            };
            case "invasion": {
                private _opcomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                private _tacomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";

                [_handler,"OPCOM_FSM", _opcomFSM] call ALiVE_fnc_HashSet;
                [_handler,"TACOM_FSM", _tacomFSM] call ALiVE_fnc_HashSet;
            };
            case "asymmetric": {
                private _fsm = [_handler] execFSM "\x\alive\addons\mil_opcom\insurgency.fsm";

                [_handler,"OPCOM_FSM", _fsm] call ALiVE_fnc_HashSet;
            };
        };

        // Set startup complete and end loading screen if init has passed or an error occurred

        [_handler,"listen"] call MAINCLASS;

        [_handler,"startupComplete", true] call ALiVE_fnc_HashSet;
    };

    case "listen": {
        private _G2 = [_logic,"G2"] call ALiVE_fnc_hashGet;
        if (isnil "_G2") exitwith {};
    
        private _listenerID = [ALiVE_eventLog, "addListener", [_logic, [
            "PROFILE_ATTACK_START",
            "PROFILE_ATTACK_END"
        ]]] call ALiVE_fnc_eventLog;
        [_logic,"listenerID", _listenerID] call ALiVE_fnc_hashSet;
    };

    case "handleEvent": {
        private _event = _args;

        private _eventData = [_event,"data"] call ALiVE_fnc_hashGet;
        private _eventOpcomID = _eventData select 0;

        private _opcomSide = [_logic, "side"] call ALiVE_fnc_HashGet;
        private _type = [_event,"type"] call ALiVE_fnc_hashGet;

        switch (_type) do {
            case "PROFILE_ATTACK_START": {
                _eventData params ["_attackID","_attackerID","_targets","_attackPosition","_attackerSide","_maxRange","_cyclesLeft"];

                if (_opcomSide == _attackerSide) then {
                    [_logic,"createSpotrepForProfiles", _targets] call MAINCLASS;
                };
            };

            case "PROFILE_ATTACK_END": {
                _eventData params ["_attackID","_attackerID","_targetsLeft","_targetsKilled","_attackPosition","_attackerSide","_timeStarted","_maxRange","_cyclesLeft"];

                if (_opcomSide == _attackerSide) then {
                    private _G2 = [_logic,"G2"] call ALiVE_fnc_hashGet;
                    if (!isnil "_G2") then {
                        [_G2,"removeProfileSpotreps", _targetsKilled] call ALiVE_fnc_G2;
                    };
                };
            };
        };
    };

    case "createSpotrepForProfiles": {
        private _profiles = _args;

        private _G2 = [_logic,"G2"] call ALiVE_fnc_hashGet;
        if (isnil "_G2") exitwith {};

        {
            private _spotrepData = [_G2,"buildSpotrepForProfile", [_x,0]] call ALiVE_fnc_G2;
            //If the profile was dead when trying to process ALive_fnc_G2, spotrepdata would return null, skip this profile
            if (isnil "_spotrepData") then { continue };
            [_G2,"createSpotrep", _spotrepData] call ALiVE_fnc_G2;
        } foreach _profiles;
    };

    case "getModuleObjectives": {
        private _module = _args;
        private _moduleType = typeof _module;

        private _controlType = [_logic,"controltype"] call ALiVE_fnc_HashGet;

        // mil_placement_spe deliberately NOT in the list - the module is
        // designed to place profile groups / vehicles at a fixed position
        // (with module direction driving placement orientation). Syncing
        // it to an OPCOM causes OPCOM to sweep its units into the
        // objective pool and redeploy them, which defeats the module's
        // purpose. Profile sources for OPCOM's faction still count through
        // the spe module's own spawns, just not as OPCOM-managed objectives.
        if (_moduleType in [
            "ALiVE_mil_placement",
            "ALiVE_civ_placement",
            "ALiVE_civ_placement_custom",
            "ALiVE_mil_placement_custom"
        ]) exitwith {
            // wait for module to finish init
            waituntil { _module getVariable ["startupComplete", false] };

            private _moduleObjectives = [_module,"objectives",objNull, []] call ALIVE_fnc_OOsimpleOperation;

            // Stamp objectiveType per source-module class so downstream
            // marker / C2ISTAR / tour consumers can differentiate which
            // placement module each objective came from. Previously all
            // classes defaulted to "MIL" (via the HashGet default at
            // the assignment sites), giving mission-makers no way to tell
            // OPCOM-held objectives apart on the map. Issue #809.
            private _modLabel = switch _moduleType do {
                case "ALiVE_mil_placement":        {"MIL"};
                case "ALiVE_mil_placement_custom": {"CUS"};
                case "ALiVE_civ_placement":        {"CIV"};
                case "ALiVE_civ_placement_custom": {"CCU"};
                default {"MIL"};
            };
            {
                [_x,"objectiveType", _modLabel] call ALiVE_fnc_HashSet;
            } forEach _moduleObjectives;

            if (_controlType == "asymmetric" && {_moduleType in ["ALiVE_civ_placement","ALiVE_civ_placement_custom"]}) then {
                private _asymmetricInstallationCountOverrides = [_handler,"parseAsymmetricInstallationCountOverrides", _module getVariable ["asymmetricInstallationCountOverrides", ""] ] call MAINCLASS;

                if (count (_asymmetricInstallationCountOverrides select 1) > 0) then {
                    private _overrideSource = format ["%1_%2", typeOf _module, str _module];

                    {
                        [_x, "asymmetricInstallationCountOverrides", _asymmetricInstallationCountOverrides] call ALiVE_fnc_HashSet;
                        [_x, "asymmetricInstallationOverrideSource", _overrideSource] call ALiVE_fnc_HashSet;
                    } foreach _moduleObjectives;
                };
            };

            _result = _moduleObjectives;
        };

        //Is it a synced editor location-gamelogic?
        if (_module iskindof "LocationBase_F") then {
            //These two values can be overwritten with f.e. *this setvariable ["size",700]* in init-field of editorobject...
            private _size = _module getvariable ["size", 150];
            private _priority = _module getvariable ["priority", 200];
            
            private _objectiveType = getText(configfile >> "CfgVehicles" >> (typeOf _module) >> "displayName");

            private _objective = [[
                ["center", getposATL _module],
                ["size", _size],
                ["objectiveType", _objectiveType],
                ["priority", _priority],
                ["clusterID", ""]
            ]] call ALiVE_fnc_hashCreate;

            _result = [_objective];
        };
    };

    // Find any active objectives where the assigned profiles have no waypoints
    // and reset their state so it can be reconsidered for new orders
    case "cleanupduplicatesections": {
        private _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
        private _pending_orders = [_logic,"pendingorders",[]] call ALiVE_fnc_HashGet;
        private _size_reserve = [_logic,"sectionsamount_reserve",1] call ALiVE_fnc_HashGet;
        private _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;

        private _idlestates = ["unassigned","idle"];

        {
            private _objective = _x;
            private _section = [_objective,"section",[]] call ALiVE_fnc_HashGet;

            private _sectionWaypoints = 0;
            {
                private _profile = [ALiVE_ProfileHandler,"getProfile", _x] call ALiVE_fnc_ProfileHandler;

                if !(isnil "_profile") then {
                    private _profileWaypoints = _profile select 2 select 16;
                    _sectionWaypoints = _sectionWaypoints + (count _profileWaypoints);
                } else {
                    [_logic,"resetProfileOrders", _x] call ALiVE_fnc_OPCOM;
                };
            } foreach _section;

            private _state = [_objective,"opcom_state",[]] call ALiVE_fnc_HashGet;
            if (!(_state in _idlestates) && {count _section > 0} && {_sectionWaypoints == 0}) then {
                {[_logic,"resetProfileOrders", _x] call ALiVE_fnc_OPCOM} foreach _section;
                [_logic,"resetObjective", ([_objective,"objectiveID"] call ALiVE_fnc_HashGet)] call ALiVE_fnc_OPCOM;
            };
        } foreach _objectives;
    };

    case "NearestAvailableSection": {

        //private _id = time; [true, "ALiVE OPCOM composing section!", format["OPCOM_nearestSection_%1",_id]] call ALIVE_fnc_timer;

        private ["_radius","_troopsunsorted","_types","_pos","_size","_troops","_busy","_section","_reserved","_profileIDs","_profile"];

        _pos = _args select 0;
        _size = _args select 1;
        if (count _args > 2) then {_types = _args select 2} else {_types = ["infantry"]};

        // Get troops from current OPCOM analysis
        _troops = []; {_troops = _troops + ([_logic,_x,[]] call ALiVE_fnc_HashGet)} foreach _types;

        //subtract busy and reserved profiles
        _busy = []; {_busy pushback (_x select 1)} foreach ([_logic,"pendingorders",[]] call ALiVE_fnc_HashGet);
        {_busy = _busy + ([_x,"section",[]] call ALiVE_fnc_HashGet)} foreach ([_logic,"objectives",[]] call ALiVE_fnc_HashGet);
        _reserved = [_logic,"ProfileIDsReserve",[]] call ALiVE_fnc_HashGet;
        _busy = _busy - _reserved;

        // If great amount of troops is requested reroute profiles if needed
        _troops = if (_size >= 5) then {_troops - _reserved} else {_troops - (_busy + _reserved)};

        // Filter troops
        _radius = 2000;
        while
        {
            private _nearProfiles = [_pos, _radius, [([_logic,"side","EAST"] call ALiVE_fnc_HashGet),"entity"]] call ALIVE_fnc_getNearProfiles;

            _troopsUnsorted = [];

            {
                private _profile = _x;

                if (!isnil "_profile") then {

                    private _profileID = [_profile,"profileID",""] call ALiVE_fnc_HashGet;
                    private _commander = (count ([_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashGet) > 0);
                    private _busy = ([_profile,"busy",false] call ALiVE_fnc_HashGet);
                    private _pathfindingEnabled = [Alive_profileSystem,"pathfinding"] call ALiVE_fnc_hashGet;
                    private _isSeaTravel = if (_pathfindingEnabled) then { //Use new pathfinding function instead of straight line check
                        {[Alive_pathfinder,"layer1SeaTravelCheck",[[_profile,"position",[0,0,0]] call ALiVE_fnc_HashGet,_pos]] call Alive_fnc_pathfinder;}
                    } else {
                        {[[_profile,"position",[0,0,0]] call ALiVE_fnc_HashGet,_pos] call ALiVE_fnc_crossesSea}
                    };
                    
                    // Static AA gate: profiles registered as "static" in
                    // ALIVE_aaProfileBehaviour (populated by mil_placement
                    // / mil_placement_custom AA spawn) skip section
                    // composition - keeps emplaced AA at its spawn point
                    // instead of being repositioned on attack / defend
                    // orders. Roaming AA passes through as a normal
                    // force unit.
                    private _aaBehVal = if (!isNil "ALIVE_aaProfileBehaviour") then {
                        [ALIVE_aaProfileBehaviour, _profileID] call ALIVE_fnc_hashGet
                    } else { nil };
                    private _isStaticAA = !isNil "_aaBehVal" && {typeName _aaBehVal == "STRING"} && {_aaBehVal == "static"};
                    private _valid = !_busy && {_profileID in _troops} && {!_commander || {if (_profileID in ([_logic,"sea",[]] call ALiVE_fnc_HashGet)) then {call _isSeaTravel} else {!(call _isSeaTravel)}}} && {!_isStaticAA} && {!(!isNil "ALIVE_profileStationary" && {[ALIVE_profileStationary, _profileID, false] call ALIVE_fnc_hashGet})};

                    if (_valid) then {_troopsUnsorted pushBack _profile};
                };
            } foreach _nearProfiles;

            ((count _troopsUnsorted <= _size) && {_radius < 15000});
        } do {
            _radius = _radius + 2000;
        };

        //Sort by distance
        _troops = [_troopsUnsorted,[_pos],
                    {([_x,"position",_Input0] call ALiVE_fnc_HashGet) distance _Input0}
                        ,"ASCEND",
                    {!isnil "_x" && {count _x > 2}}
                    ] call ALiVE_fnc_SortBy;

        //Collect to section
        _section = [];
        {
            if (count _section == _size) exitwith {};

            if (!isnil "_x") then {_section pushback ([_x,"profileID",""] call ALiVE_fnc_HashGet)};
        } foreach _troops;

        _result = _section;

        //[false, "ALiVE OPCOM composing section!", format["OPCOM_nearestSection_%1",_id]] call ALIVE_fnc_timer;
    };

    ///////////////////////////////////////////////////
    // Scan position for nearby profiles belonging to
    // the passed sides.
    // Returns array of all found profiles
    ///////////////////////////////////////////////////

    case "findProfilesNearPosition": {
        _args params ["_pos","_sides","_requireVisibility"];
        _pos = [_pos select 0, _pos select 1, 0];

        if (_requireVisibility) then {
            _pos = ATLtoASL _pos;
            _pos set [2,(_pos select 2) + 2];
        };

        private _nearEnemies = [];

        private _nearProfiles = [_pos, 800, [_sides,"entity"]] call ALIVE_fnc_getNearProfiles;
        {
            if (_requireVisibility) then {
                private _profileID = _x select 2 select 4;
                private _profilePosition = _x select 2 select 2;

                private _profilePosASL = ATLtoASL [_profilePosition select 0, _profilePosition select 1, 0];
                _profilePosASL set [2,(_profilePosASL select 2) + 2];

                if (_profilePosition distance _pos < 500 && { !(terrainIntersectASL [_profilePosASL, _pos]) }) then {
                    _nearEnemies pushbackunique [_x select 2 select 4, _x select 2 select 2]; // [id,pos]
                };
            } else {
                _nearEnemies pushbackunique [_x select 2 select 4, _x select 2 select 2]; // [id,pos]
            };
        } foreach _nearProfiles;

        _result = _nearEnemies;
    };

    case "attackentity": {
        ASSERT_TRUE(typeName _args == "ARRAY",str _args);

        private ["_target","_reserved","_sides","_size","_type","_proIDs","_knownE","_attackedE","_pos","_profiles","_profileIDs","_profile","_section","_profileID","_i","_waypoints","_posAttacker","_dist","_rtb","_fireSupport","_vehicleProfile","_vehicleType","_ATOtype"];

        _target = _args select 0;
        _size = _args select 1;
        _type = _args select 2;

        _section = [];
        _profileIDs = [];
        _profiles = [];
        _dist = 1000;
        
        _profile = [ALiVE_ProfileHandler,"getProfile",_target] call ALiVE_fnc_ProfileHandler;
        //Attempt to solve the error resulting from the race condition between the profile death and this call
        if (isnil "_profile") exitwith {_result = _section}; //Exit early
        
        _side = [_logic,"side"] call ALiVE_fnc_HashGet;
        _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;
        _sides = [_logic,"sidesenemy",["EAST"]] call ALiVE_fnc_HashGet;
        _knownE = [_logic,"knownentities",[]] call ALiVE_fnc_HashGet;
        _attackedE = [_logic,"attackedentities",[]] call ALiVE_fnc_HashGet;
        _reserved = [_logic,"ProfileIDsReserve",[]] call ALiVE_fnc_HashGet;
        _pos = [_profile,"position"] call ALiVE_fnc_HashGet;

        _vehicles = ([_profile,"vehicleAssignments",[[],[]]] call ALIVE_fnc_hashGet) select 1;
        if (count _vehicles > 0) then {
            _vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_vehicles select 0] call ALiVE_fnc_ProfileHandler;
        };


        {
            _proIDs = [ALIVE_profileHandler, "getProfilesBySide",_x] call ALIVE_fnc_profileHandler;
            _profileIDs = _profileIDs + _proIDs;
        } foreach _sides;

        {
            if ((isnil "_x") || {_x select 0 == _target} || {!((_x select 0) in _profileIDs)}) then {
                _knownE set [_foreachIndex,"x"];
            };
        } foreach _knownE;
        _knownE = _knownE - ["x"];
        [_logic,"knownentities",_knownE] call ALiVE_fnc_HashSet;

        {
            if ((isnil "_x") || {time - (_x select 3) > 90} || {!((_x select 0) in _profileIDs)}) then {
                _attackedE set [_foreachIndex,"x"];
            };
        } foreach _attackedE;
        _attackedE = _attackedE - ["x"];
        [_logic,"attackedentities",_attackedE] call ALiVE_fnc_HashSet;

        // request-rate lever: when the mil_artillery "Call-for-fire rate" setting
        // is above Normal it broadcasts [contactsPerScan, cooldownSeconds]. Here
        // we fan a fresh ARTY_REQUEST across several known enemy contacts per scan
        // (not just the lead target below), each on its own short artillery
        // cooldown, independent of the 90s maneuver cooldown above. [0,0] (Normal,
        // or no artillery module) skips this block entirely - maneuver behaviour
        // is unchanged, so this is additive and default-off.
        private _artyRate = missionNamespace getVariable [format ["ALIVE_MilArtillery_requestRate_%1", toUpper str _side], [0,0]];
        if ((_artyRate select 0) > 0 && {["ALiVE_mil_artillery"] call ALiVE_fnc_IsModuleAvailable}) then {
            private _artyMax = _artyRate select 0;
            private _artyCd = _artyRate select 1;
            private _artyReq = [_logic,"artyRequestedEntities",[]] call ALiVE_fnc_HashGet;
            {
                if ((isnil "_x") || {time - (_x select 1) > _artyCd} || {!((_x select 0) in _profileIDs)}) then {
                    _artyReq set [_foreachIndex,"x"];
                };
            } forEach _artyReq;
            _artyReq = _artyReq - ["x"];
            private _artyAsym = ([_logic,"controltype",""] call ALiVE_fnc_HashGet) == "asymmetric";
            private _artySideObj = [_side] call ALiVE_fnc_sideTextToObject;
            private _artyFaction = _factions select 0;
            private _artyFired = 0;
            {
                if (_artyFired >= _artyMax) exitWith {};
                if (!isnil "_x" && {_x isEqualType []} && {count _x > 0}) then {
                    private _cID = _x select 0;
                    if (({!(isnil "_x") && {_x isEqualType []} && {(_x select 0) == _cID}} count _artyReq) < 1) then {
                        private _cProfile = [ALiVE_ProfileHandler,"getProfile",_cID] call ALiVE_fnc_ProfileHandler;
                        if (!isnil "_cProfile") then {
                            private _cPos = [_cProfile,"position"] call ALiVE_fnc_HashGet;
                            // _cID is still a member of _knownE (unlike the #887
                            // block, where _target was pruned at the top), so its
                            // own entry supplies the "self" count - no 1+ seed, or
                            // the weight would run one high and relax selectivity.
                            private _cContacts = ({
                                !isnil "_x" && {_x isEqualType []} && {count _x > 0} && {
                                    private _kP = [ALiVE_ProfileHandler,"getProfile",_x select 0] call ALiVE_fnc_ProfileHandler;
                                    !isnil "_kP" && {([_kP,"position"] call ALiVE_fnc_HashGet) distance2D _cPos < 200}
                                }
                            } count _knownE);
                            private _aE = ['ARTY_REQUEST', [_cID, _cPos, _cContacts, _artySideObj, _artyFaction, _artyAsym],"OPCOM"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_aE] call ALIVE_fnc_eventLog;
                            _artyReq pushBack [_cID, time];
                            _artyFired = _artyFired + 1;
                        };
                    };
                };
            } forEach _knownE;
            [_logic,"artyRequestedEntities",_artyReq] call ALiVE_fnc_HashSet;
        };

        if ({!(isnil "_x") && {_x select 0 == _target}} count _attackedE < 1) then {

            private _infantry = [_logic,"infantry",[]] call ALiVE_fnc_HashGet;
            private _motorized = [_logic,"motorized",[]] call ALiVE_fnc_HashGet;
            private _mechanized = [_logic,"mechanized",[]] call ALiVE_fnc_HashGet;
            private _armored = [_logic,"armored",[]] call ALiVE_fnc_HashGet;
            private _artillery = [_logic,"artillery",[]] call ALiVE_fnc_HashGet;
            private _AAA = [_logic,"AAA",[]] call ALiVE_fnc_HashGet;
            private _air = [_logic,"air",[]] call ALiVE_fnc_HashGet;

            switch (_type) do {
                case ("infantry") : {
                    _profiles = _infantry;
                    _dist = 1000;
                };
                case ("motorized") : {
                    _profiles = _motorized;
                    _dist = 3000;
                };
                case ("mechanized") : {
                    _profiles = _mechanized;
                };
                case ("armored") : {
                    _profiles = _armored;
                    _dist = 3000;
                };
                case ("artillery") : {
                    _profiles = _artillery;
                    _dist = 5000;
                    _fireSupport = true;
                };
                case ("AAA") : {
                    _profiles = _AAA;
                    _dist = 5000;
                };
                case ("air") : {
                    _profiles = _air;
                    _dist = 30000;
                    _rtb = true;
                };
                default {
                    _profiles = _infantry;
                };
            };


            if (!isnil "_rtb" && {["ALiVE_mil_ATO"] call ALiVE_fnc_IsModuleAvailable}) exitwith {

                _ATOtype = "CAS";

                // ["Calling ATO event"] call ALiVE_fnc_DumpR;

                _args = [
                    "RED",	// ROE
                    200,
                    "FULL",
                    0.1,
                    0.1,
                    2000,	// RADIUS
                    10,
                    [_target]  // TARGETS either profile or unit
                ];
                _event = ['ATO_REQUEST', [_ATOtype, [_side] call ALiVE_fnc_sideTextToObject, _factions select 0, _pos, _args],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                _attackedE pushback [_target,_pos,_section,time];
                [_logic,"attackedentities",_attackedE] call ALiVE_fnc_HashSet;
            };

            // #887 - with the AI artillery module present, every contact
            // response also asks for a fire mission on the target: fires
            // precede maneuver. The QRF type switch above never selects
            // "artillery" (types come from the target vehicle class), so
            // gating the request on it meant no commander ever fired a
            // round. The artillery module's own gates (contact count,
            // range, cooldown, ammunition, concurrency) decide whether a
            // battery actually answers, so asking costs nothing when the
            // guns are busy, dry or out of range
            if (["ALiVE_mil_artillery"] call ALiVE_fnc_IsModuleAvailable) then {

                private _targetProfile = [ALiVE_ProfileHandler,"getProfile",_target] call ALiVE_fnc_ProfileHandler;
                if (!isnil "_targetProfile") then {
                    private _targetPos = [_targetProfile,"position"] call ALiVE_fnc_HashGet;

                    // contact weight: the target itself counts (it was pruned
                    // from the known-entities list above, so start at 1) plus
                    // known enemies near it - the artillery module applies
                    // its minimum-contact rule to this count
                    private _contacts = 1;
                    {
                        if (!isnil "_x" && {_x isEqualType []} && {count _x > 0}) then {
                            private _kProfile = [ALiVE_ProfileHandler,"getProfile",_x select 0] call ALiVE_fnc_ProfileHandler;
                            if (!isnil "_kProfile") then {
                                if (([_kProfile,"position"] call ALiVE_fnc_HashGet) distance2D _targetPos < 200) then {
                                    _contacts = _contacts + 1;
                                };
                            };
                        };
                    } foreach _knownE;

                    private _asym = ([_logic,"controltype",""] call ALiVE_fnc_HashGet) == "asymmetric";

                    private _aEvent = ['ARTY_REQUEST', [_target, _targetPos, _contacts, [_side] call ALiVE_fnc_sideTextToObject, _factions select 0, _asym],"OPCOM"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_aEvent] call ALIVE_fnc_eventLog;
                };
            };

            // artillery sections themselves hold position and answer with
            // fire missions instead of driving at the enemy like line units
            if (!isnil "_fireSupport") exitwith {
                _attackedE pushback [_target,_pos,_section,time];
                [_logic,"attackedentities",_attackedE] call ALiVE_fnc_HashSet;
            };

            if (count _profiles == 0) then {
                {
                    if (count _x > 0) exitwith {
                        _profiles = _x;
                        _rtb = nil;
                    };
                } foreach [_armored,_mechanized,_motorized,_infantry];
            };

            if (count _profiles > 0) then {

                _profilesUnsorted = _profiles;
                _profiles = [_profilesUnsorted,[_pos],{if !(isnil "_x") then {_p = nil; _p = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler; if !(isnil "_p") then {([_p,"position",_Input0] call ALiVE_fnc_HashGet) distance _Input0} else {[0,0,0] distance _Input0}} else {[0,0,0] distance _Input0}},"ASCEND"] call ALiVE_fnc_SortBy;

                _i = 0;
                while {count _section < _size} do {
                    private ["_profileWaypoint","_profileID"];

                    if (_i >= count _profiles) exitwith {};

                        _profileID = (_profiles select _i);
                    _profile = ([ALiVE_ProfileHandler,"getProfile",_profileID] call ALiVE_fnc_profileHandler);

                    if !(isnil "_profile") then {
                            _posAttacker = [_profile, "position"] call ALiVE_fnc_HashGet;

                        // Static AA gate (see "nearestSection" case for
                        // rationale). Static AA never gets pulled into a
                        // QRF response - stays at its emplaced spawn.
                        private _aaBehVal = if (!isNil "ALIVE_aaProfileBehaviour") then {
                            [ALIVE_aaProfileBehaviour, _profileID] call ALIVE_fnc_hashGet
                        } else { nil };
                        private _isStaticAA = !isNil "_aaBehVal" && {typeName _aaBehVal == "STRING"} && {_aaBehVal == "static"};

                        if (!(isnil "_profile") && {_pos distance _posAttacker < _dist} && {!(_profileID in _reserved)} && {!_isStaticAA} && {!(!isNil "ALIVE_profileStationary" && {[ALIVE_profileStationary, _profileID, false] call ALIVE_fnc_hashGet})}) then {

                            _waypoints = [_profile,"waypoints"] call ALIVE_fnc_hashGet;

                            if (({!(isnil "_x") && {_profileID in (_x select 2)}} count _attackedE) < 1 && {count _waypoints <= 2}) then {
                                if (!isnil "_rtb") then {
                                    _profileWaypoint = [_posAttacker, 50] call ALIVE_fnc_createProfileWaypoint;
                                    [_profileWaypoint,"statements",["true",
                                        format["
                                            if !(isServer) exitwith {};

                                            _profile = [ALiVE_ProfileHandler,'getProfile',%1] call ALiVE_fnc_profileHandler;
                                            _active = [_profile,'active',false] call ALiVE_fnc_HashGet;

                                            if (_active) then {
                                                _group = _profile select 2 select 13;
                                                _group setSpeedmode 'LIMITED';
                                                {(vehicle _x) land 'LAND'} foreach (units _group);
                                            } else {
                                                _vehicleProfiles = [_profile,'vehiclesInCommandOf',[]] call ALIVE_fnc_hashGet;

                                                {
                                                    _vehicleProfile = [ALiVE_ProfileHandler,'getProfile',_x] call ALiVE_fnc_ProfileHandler;
                                                    [_vehicleProfile,'engineOn',false] call ALIVE_fnc_HashSet;
                                                } foreach _vehicleProfiles;
                                            };
                                        ",str(_profileID)]
                                    ]] call ALIVE_fnc_hashSet;

                                    [_profile,"insertWaypoint",_profileWaypoint] call ALIVE_fnc_profileEntity;
                                };

                                _profileWaypoint = [_pos, 50, "MOVE", "FULL", 50, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                [_profile,"insertWaypoint",_profileWaypoint] call ALIVE_fnc_profileEntity;

                                _section pushback _profileID;
                            } else {
                                //player sidechat format["Entity %1 is already on attack mission...!",_profileID];
                            };
                        };
                    };

                    _i = _i + 1;
                };

                if (count _section > 0) then {
                    _attackedE pushback [_target,_pos,_section,time];
                    [_logic,"attackedentities",_attackedE] call ALiVE_fnc_HashSet;
                    //player sidechat format["Group %1 is attacked by %2",_target, _section];
                };
            } else {
                ["OPCOM has no troops to respond on TACOM request for QRF on %1 of type %2",_target,_type] call ALiVE_fnc_DumpR;
            };
        } else {
            //player sidechat format["Target %1 already beeing attacked, dead or not existing for any reason...!",_target];
        };

        _result = _section;
    };

    ///////////////////////////////////////////////////
    // Creates a new waypoint for the profile to move to the passed position
    // Sets var on TACOM to signal completion once WP is reached
    ///////////////////////////////////////////////////

    case "setorders": {
        _args params ["_pos","_profileID","_objectiveID","_orders"];

        private _TACOM_FSM = [_logic,"TACOM_FSM"] call ALiVE_fnc_HashGet;
        private _objectives = [_logic,"objectives"] call ALiVE_fnc_HashGet;

        {
            private _id = [_x,"objectiveID"] call ALiVE_fnc_HashGet;
            private _section = [_x,"section",[]] call ALiVE_fnc_HashGet;

            if ((_profileID in _section) && {!(_objectiveID == _id)}) then {
                [_logic,"resetProfileOrders",_profileID] call ALiVE_fnc_OPCOM;
            };
        } foreach _objectives;

        private _pendingOrders = [_logic,"pendingorders",[]] call ALiVE_fnc_HashGet;

        // remove any existing pending orders for this profile

        [_pendingOrders, { (_x select 1) == _profileID }] call ALiVE_fnc_deleteIf;

        // add new waypoint to profile

        private _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;

        [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
        [_profile,"clearActiveCommands"] call ALIVE_fnc_profileEntity;

        private _profileWaypoint = [_pos, 15] call ALIVE_fnc_createProfileWaypoint;

        private _var = ["_TACOM_DATA", ["completed", [_ProfileID,_objectiveID,_orders]]];
        private _statements = format ["[{%1 setFSMVariable %2}, [], 1 + (random 9)] call CBA_fnc_waitAndExecute", _TACOM_FSM, _var];
        [_profileWaypoint,"statements", ["true",_statements]] call ALIVE_fnc_hashSet;
        [_profileWaypoint,"behaviour", "AWARE"] call ALIVE_fnc_hashSet;
        [_profileWaypoint,"speed", "NORMAL"] call ALIVE_fnc_hashSet;

        [_profile,"addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

        _pendingOrders pushback [_pos,_ProfileID,_objectiveID,time];

        _result = _profileWaypoint;
    };

    ///////////////////////////////////////////////////
    // Called when a profile has compeleted waypoint
    // that was created for a TACOM order
    // Returns whether or not any remaining waypoints
    // for that order remain
    ///////////////////////////////////////////////////

    case "synchronizeorders": {
        private _ProfileIDInput = _args;
        private _pendingOrders = [_logic,"pendingorders", []] call ALiVE_fnc_HashGet;
        private _synchronized = false;

        // private _profilePendingOrderIndex = _pendingOrders findIf { (_x select 1) == _ProfileIDInput };
        // if (_profilePendingOrderIndex == -1) exitwith {};

        // private _profilePendingOrder = _pendingOrders deleteat _profilePendingOrderIndex;
        // private _objective = _profilePendingOrder select 2;
        // private _remainingOrders = [];

        // {
        //     _x params ["_pos","_profileID","_objectiveID","_time"];

        //     if (_objectiveID == _objective) then {
        //         private _dead = isnil { [ALiVE_profileHandler,"getProfile", _profileID] call ALiVE_fnc_profileHandler };
        //         private _timeout = (time - _time) > 3600;
        //     };
        // } foreach _pendingOrders;

        private _ordersToRemove = [];
        private _objectiveIDsToCheck = [];
        {
            _x params ["_pos","_profileID","_objectiveID","_time"];

            private _dead = isnil { [ALiVE_profileHandler,"getProfile", _profileID] call ALiVE_fnc_profileHandler };
            private _timeout = (time - _time) > 3600;

            if (_dead || { _timeout } || { _ProfileID == _ProfileIDInput }) then {
                _ordersToRemove pushback _foreachindex;
                _objectiveIDsToCheck pushback _objectiveID;
            };
        } foreach _pendingOrders;

        [_pendingOrders, _ordersToRemove] call ALiVE_fnc_deleteAtMany;

        //We have to check for any additional orders for the given
        // objectives *after deleting from the array*,
        // otherwise findIf just finds the exact same order
        // that we were already looking at above (in "_x")
        // and _synchronized is never set to true.

        //Get rid of any duplicate objective IDs in the array
        _objectiveIDsToCheck = _objectiveIDsToCheck arrayIntersect _objectiveIDsToCheck;
        {
            private _objectiveId = _x;
            private _objectiveFound = _pendingOrders findIf { _objectiveID == (_x select 2) };
            if (_objectiveFound == -1) then {
                _synchronized = true; 
            };
        } forEach _objectiveIDsToCheck;
        
        _result = _synchronized;
    };

    /*
        Clears existing orders for a given profile
    */
    case "resetorders";
    case "resetProfileOrders": {
        private _profileID = _args;

        // reset reserve queue if there is an entry for the entitiy
        private _profileIDsReserve = [_logic,"ProfileIDsReserve", []] call ALiVE_fnc_HashGet;
        _profileIDsReserve deleteat (_profileIDsReserve find _profileID);

        // reset pending orders if there is an entry for the entitiy
        private _pendingOrders = [_logic,"pendingorders", []] call ALiVE_fnc_HashGet;
        _pendingOrders deleteat (_pendingOrders findif { (_x select 1) == _profileID });

        // if entity is assigned to objective, remove it
        // if objective then has no profiles assigned, reset objective

        // reset section entry on objectives if the entity is still assigned to an objective
        private _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
        {
            private _section = [_x,"section", []] call ALiVE_fnc_HashGet;

            private _sectionProfileIndex = _section find _profileID;
            if (_sectionProfileIndex != -1) exitwith {
                _section deleteat _sectionProfileIndex;
                [_x,"sectionAssist", []] call ALiVE_fnc_HashSet;

                if (_section isequalto []) then {
                    [_logic,"resetObjective", ([_x,"objectiveID"] call ALiVE_fnc_HashGet)] call MAINCLASS;
                };
            };
        } foreach _objectives;

        // if the profile is inactive with no activeCommands, start ambient movement
        private _profile = [ALIVE_profileHandler,"getProfile", _profileID] call ALIVE_fnc_profileHandler;
        if !(isnil "_profile") then {
            private _active = [_profile,"active", false] call ALIVE_fnc_HashGet;
            private _activeCommands = [_profile,"activeCommands", []] call ALIVE_fnc_HashGet;

            if (!_active && { _activeCommands isequalto [] }) then {
                [_profile,"clearActiveCommands"] call ALIVE_fnc_profileEntity;
                [_profile,"setActiveCommand", ["ALIVE_fnc_ambientMovement","spawn",[200,"SAFE",[0,0,0]]]] call ALIVE_fnc_profileEntity;
            };
        };

        _result = true;
    };

    case "getOPCOMbyid";
    case "getOPCOMByID": {
        ASSERT_TRUE(_args isequaltype "", str _args);

        private _opcomIndex = OPCOM_instances findIf { ([_x,"opcomID",""] call ALiVE_fnc_HashGet) == _args };
        if (_opcomIndex != -1) then {
            _result = OPCOM_instances select _opcomIndex;
        };

    };

    case "getobjectivebyid";
    case "getObjectiveByID": {
        private _id = _args;

        if (!isnil "_logic" && {_logic isequaltype []} && {_logic isnotequalto []}) then {
            // find objective from passed opcom
            private _objectives = [_logic,"objectives"] call ALIVE_fnc_HashGet;
            private _objectiveIndex = _objectives findIf { ([_x,"objectiveID"] call ALiVE_fnc_hashGet) == _id };
            if (_objectiveIndex != -1) exitwith {
                _result = _objectives select _objectiveIndex;
            };
        } else {
            // find objective from any opcom
            {
                private _objectives = [_x,"objectives"] call ALIVE_fnc_HashGet;
                private _objectiveIndex = _objectives findIf { ([_x,"objectiveID"] call ALiVE_fnc_hashGet) == _id };
                if (_objectiveIndex != -1) exitwith {
                    _result = _objectives select _objectiveIndex;
                };
            } foreach OPCOM_INSTANCES;
        };
    };

    case "sortObjectives": {
        if(isnil "_args") then {
            _args = [_logic,"objectives"] call ALIVE_fnc_hashGet;
        } else {
            private ["_side","_color"];

            private _debug = [_logic,"debug",false] call ALiVE_fnc_HashGet;

            private _type = _args;
            private _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
            private _asym_occupation = [_logic,"asym_occupation",-1] call ALiVE_fnc_HashGet;
            private _roadblocks = [_logic,"roadblocks",true] call ALiVE_fnc_HashGet;

            // A single objective with a missing or malformed center position throws a
            // Generic error inside the sort callbacks below (they read the raw hash
            // values array: _x select 2 select 1), which aborts OPCOM init entirely and
            // hangs the mission on the loading screen. An objective with no position
            // cannot be sorted or tasked, so drop it here and name it in the RPT.
            _objectives = _objectives select {
                private _center = if (_x isEqualType [] && {count _x > 2 && {(_x select 2) isEqualType [] && {count (_x select 2) > 1}}}) then {(_x select 2) select 1};
                private _valid = !isNil "_center" && {_center isEqualType [] && {count _center >= 2 && {(_center select 0) isEqualType 0 && {(_center select 1) isEqualType 0}}}};

                if (!_valid) then {
                    ["OPCOM dropped objective with invalid center position! objectiveID: %1, objectiveType: %2, center: %3",
                        [_x,"objectiveID","unknown"] call ALiVE_fnc_HashGet,
                        [_x,"objectiveType","unknown"] call ALiVE_fnc_HashGet,
                        if (isNil "_center") then {"nil"} else {str _center}
                    ] call ALiVE_fnc_dump;
                };

                _valid
            };

            switch (_type) do {
                //by distance
                case ("distance") : {
                    _objectives = [_objectives,[_logic],{
                        _final = ([_Input0, "position"] call ALIVE_fnc_HashGet) distance (_x select 2 select 1);

                        //["OPCOM Priority calculated %1",_final] call ALiVE_fnc_dumpR;

                        _final = _final*(1-(random 0.33));

                        //["OPCOM Priority randomized with a variety of one third in relation to distance %1 ",_final] call ALiVE_fnc_dumpR;

                        _final
                    },"ASCEND"] call ALiVE_fnc_SortBy;
                };

                //by size and height
                case ("strategic") : {
                    _objectives = [_objectives,[_logic],{
                        _height = (ATLtoASL [(_x select 2 select 1) select 0,(_x select 2 select 1) select 1,0]) select 2;
                        _value1 = (_x select 2 select 2);
                        _value2 = (_x select 2 select 4);
                        _value3 = (_height/2);
                        _value4 = ((([_Input0, "position"] call ALIVE_fnc_HashGet) distance (_x select 2 select 1))/10);

                        _final = (_value1 + _value2 + _value3) - _value4;

                        //["OPCOM Priority calculated %1",_final] call ALiVE_fnc_dumpR;

                        _final = _final*(1-(random 0.33));

                        //["OPCOM Priority randomized with a variety of one third in relation to size, height, distance, cluster priority %1",_final] call ALiVE_fnc_dumpR;

                        _final
                    },"DESCEND"] call ALiVE_fnc_SortBy;
                };

                case ("asymmetric") : {
                    _objectivesCiv = +_objectives;
                    _objectivesMil = +_objectives;

                    _objectivesFilteredCiv = [_objectivesCiv,[_logic],{(([_Input0, "position"] call ALIVE_fnc_HashGet) distance (_x select 2 select 1))*(1-(random 0.20))},"ASCEND",{(_x select 2 select 3) == "CIV"}] call ALiVE_fnc_SortBy;
                    _objectivesFilteredMil = [_objectivesMil,[_logic],{(([_Input0, "position"] call ALIVE_fnc_HashGet) distance (_x select 2 select 1))*(1-(random 0.20))},"ASCEND",{(_x select 2 select 3) == "MIL"}] call ALiVE_fnc_SortBy;

                    _objectives = _objectivesFilteredCiv + _objectivesFilteredMil;

                    //["OPCOM Asymmetric Priority randomized with a variety of one fifth in relation to distance"] call ALiVE_fnc_dumpR;

                    _factions = [_logic,"factions",["OPF_F"]] call ALiVE_fnc_HashGet;
                    _sidesEnemy = [_logic,"sidesenemy",["WEST"]] call ALiVE_fnc_HashGet;
                    _sidesFriendly = [_logic,"sidesfriendly",["EAST"]] call ALiVE_fnc_HashGet;
                    _CQB = [_logic,"CQB",[]] call ALiVE_fnc_HashGet;

                    //Convert CQB modules
                    _CQB = +_CQB; {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                    private _overrideObjectiveIDs = [_logic,"seedAsymmetricInstallations",_objectives] call ALiVE_fnc_OPCOM;

                    {
                        private _objective = _x;
                        private _objectiveID = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;
                        private _created = false;

                        if (!(_objectiveID in _overrideObjectiveIDs) && {random 1 < _asym_occupation}) then {
                            private _center = [_objective,"center"] call ALiVE_fnc_HashGet;
                            private _size = [_objective,"size",-1] call ALiVE_fnc_HashGet;
                            private _dominantFaction = [_center, _size] call ALiVE_fnc_getDominantFaction;

                            if (isnil "_dominantFaction" || {!(([[_dominantFaction call ALiVE_fnc_factionSide] call ALiVE_fnc_SideObjectToNumber] call ALiVE_fnc_SideNumberToText) in _sidesEnemy)}) then {
                                private _buildingTypes = [];
                                private _roadTypes = [];
                                private _availableBuildings = [_center,_size] call ALiVE_fnc_INS_filterObjectiveBuildings;
                                private _availableRoads = _center nearRoads _size;

                                if (count _availableBuildings > 0) then {
                                    _buildingTypes = ["HQ","depot","factory"];
                                };

                                if (count _availableRoads > 0) then {
                                    _roadTypes = ["ied"];
                                    if (_roadblocks) then {_roadTypes pushBack "roadblocks"};
                                };

                                private _preferredType = "";
                                private _fallbackTypes = [];

                                if (count _buildingTypes > 0) then {
                                    _preferredType = selectRandom _buildingTypes;
                                    _fallbackTypes = (_buildingTypes - [_preferredType]);
                                };

                                if (count _roadTypes > 0 && {(random 1) < 0.45 || count _buildingTypes == 0}) then {
                                    _preferredType = selectRandom _roadTypes;
                                    _fallbackTypes = (_roadTypes - [_preferredType]) + _buildingTypes;
                                };

                                if (_preferredType != "") then {
                                    _created = [_logic,"createAsymmetricInstallation",[_preferredType,_center,_preferredType in ["HQ","depot","factory"],_objective]] call ALiVE_fnc_OPCOM;

                                    if (!_created) then {
                                        {
                                            if (!_created) then {
                                                _created = [_logic,"createAsymmetricInstallation",[_x,_center,_x in ["HQ","depot","factory"],_objective]] call ALiVE_fnc_OPCOM;
                                            };
                                        } foreach _fallbackTypes;
                                    };
                                };
                            };
                        };
                    } foreach _objectives;
                };

                case ("size") : {};

                default {};
            };
            _objectives = _objectives select {
                !([_x,"deleted",false] call ALiVE_fnc_HashGet)
            };
            [_logic,"objectives",_objectives] call ALiVE_fnc_HashSet;

            if (_debug) then {
                [_logic,"createObjectiveDebugMarkers", _objectives] call MAINCLASS;
            };

            _args = _objectives;
        };

        _result = _args;
    };

    case "resetObjective": {
        if (!isnil "_args") then {
            private _objectiveID = _args;

            private _objective = [_logic,"getObjectiveByID", _objectiveID] call MAINCLASS;
            if (isnil "_objective") exitwith {
                _result = [_logic,"objectives", []] call ALIVE_fnc_hashGet;
            };

            private _previousTacomState = [_objective,"tacom_state", "none"] call ALiVE_fnc_hashGet;
            private _objectiveType = [_objective,"objectiveType", "MIL"] call ALiVE_fnc_hashGet;

            [_objective, [
                ["tacom_state", "none"],
                ["opcom_state", "unassigned"],
                ["danger", -1],
                ["section", []],
                ["sectionAssist", []],
                ["opcom_orders", "none"],
                ["objectiveType", _objectiveType]
            ]] call ALiVE_fnc_hashSetMany;

            ([_logic, ["opcomID","side","factions"]] call ALiVE_fnc_hashGetMany) params ["_opcomID","_side","_factions"];

            private _event = ['TACOM_ORDER_COMPLETE', [_opcomID,_objective,_previousTacomState,_side,_factions, false, []], "TACOM"] call ALIVE_fnc_event; //TODO: this should be elsewhere
            [ALIVE_eventLog,"addEvent", _event] call ALIVE_fnc_eventLog;

            private _debug = [_logic,"debug", false] call ALiVE_fnc_HashGet;
            if (_debug) then {
                private _marker = GET_OBJECTIVE_DEBUG_MARKER(_objectiveID);
                _marker setMarkerColorLocal "ColorWhite";
            };
        };

        _result = [_logic,"objectives", []] call ALIVE_fnc_hashGet;
    };

    case "initObjective": {
        if(isnil "_args") then {
                _args = [_logic,"objectives",[]] call ALIVE_fnc_hashGet;
        } else {
            ASSERT_TRUE(typeName _args == "STRING",str _args);
            private ["_objective"];

            //{
                _id = _args;

                _factions = [_logic,"factions",["OPF_F"]] call ALiVE_fnc_HashGet;
                _sidesEnemy = [_logic,"sidesenemy",["WEST"]] call ALiVE_fnc_HashGet;
                _sidesFriendly = [_logic,"sidesfriendly",["EAST"]] call ALiVE_fnc_HashGet;
                _CQB = [_logic,"CQB",[]] call ALiVE_fnc_HashGet;
                _debug = [_logic,"debug",false] call ALiVE_fnc_HashGet;

                _objective = [_logic,"getObjectiveByID",_id] call ALiVE_fnc_OPCOM;
                _center = [_objective,"center"] call AliVE_fnc_HashGet;
                _size = [_objective,"size"] call AliVE_fnc_HashGet;

                //Convert CQB modules
                _CQB = +_CQB; {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Get sector data
                _sector = [ALIVE_sectorGrid, "positionToSector", _center] call ALIVE_fnc_sectorGrid;
                _sectorData = [_sector,"data",["",[],[],nil]] call ALIVE_fnc_hashGet;
                _entitiesBySide = [_sectorData, "entitiesBySide",["",[],[],nil]] call ALIVE_fnc_hashGet;
                _agents = [];

                // Get amb civilian clusterdata
                if ("clustersCiv" in (_sectorData select 1)) then {

                    if (isnil "ALIVE_agentHandler") exitwith {};

                    _civClusters = [_sectorData,"clustersCiv"] call ALIVE_fnc_hashGet;
                    _settlementClusters = [_civClusters,"settlement",[]] call ALIVE_fnc_hashGet;
                    _agentClusterData = [ALIVE_agentHandler,"agentsByCluster",["",[],[],nil]] call ALiVE_fnc_hashGet;

                    if (count _settlementClusters <= 0) exitwith {};

                    _settlementClusters = [_settlementClusters,[_center],{_Input0 distance (_x select 0)},"ASCEND"] call ALiVE_fnc_SortBy;
                    _agents =  ([_agentClusterData,_settlementClusters select 0 select 1,["",[],[],nil]] call ALiVE_fnc_HashGet) select 1;

                    [_objective,"agents",_agents] call ALiVE_fnc_HashSet;
                };

                _factory = [_logic,"convertObject",[_objective,"factory",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _HQ = [_logic,"convertObject",[_objective,"HQ",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _ambush = [_logic,"convertObject",[_objective,"ambush",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _depot = [_logic,"convertObject",[_objective,"depot",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _sabotage = [_logic,"convertObject",[_objective,"sabotage",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _ied = [_logic,"convertObject",[_objective,"ied",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _suicide = [_logic,"convertObject",[_objective,"suicide",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                _roadblocks = [_logic,"convertObject",[_objective,"roadblocks",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

                if (alive _factory) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"factory",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_factory};
                if (alive _HQ) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"HQ",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_recruit};
                if (alive _depot) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"depot",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_depot};
                if (alive _roadblocks) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"roadblocks",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_roadblocks};
                if (alive _ied) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"ied",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents] spawn ALiVE_fnc_INS_ied};
                if (alive _ambush) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"ambush",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents] spawn ALiVE_fnc_INS_ambush};

                if (alive _sabotage) then {
                    private ["_buildings","_target"];

                    //Selecting tallest enterable building as target...
                    if (isnil "_buildings" || {count _buildings > 0}) then {
                        if (isnil "_buildings") then {_buildings = [_center, _size] call ALiVE_fnc_getEnterableHouses};

                        _buildings = [_buildings,[],{

                            _maxHeight = -999;
                            if (alive _x && {!((typeOf _x) isKindOf "House_Small_F")}) then {

                            if !((getText(configfile >> "CfgVehicles" >> (typeOf _x) >> "destrType")) == "DestructNo") then {
                                    _bbr = boundingBoxReal _x;
                                    _p1 = _bbr select 0; _p2 = _bbr select 1;
                                    _maxHeight = abs((_p2 select 2)-(_p1 select 2));
                                };
                            };
                            _maxHeight

                        },"DESCEND"] call ALiVE_fnc_SortBy;

                        if (count _buildings > 0) then {_target = _buildings select 0; _target = [[],"convertObject",_target] call ALiVE_fnc_OPCOM} else {_target = [[],"convertObject",objNull] call ALiVE_fnc_OPCOM};
                    };

                    [time,_center,_id,_size,selectRandom _factions,[_objective,"sabotage",[]] call ALiVE_fnc_HashGet,_target,_sidesEnemy,_agents] spawn ALiVE_fnc_INS_sabotage;
                };

                if (alive _suicide) then {
                    private ["_civFactions"];

                    _civFactions = [];

                    // Get civilian factions of existing groups
                    {if ((side leader _x) == CIVILIAN) then {_civFactions = (_civFactions - [faction leader _x]) + [faction leader _x]}} foreach allgroups;

                    // Get civilian factions from Amb Civs
                    If (!isnil "ALiVE_Agenthandler") then {
                        _AllAgents = [ALiVE_Agenthandler,"agents",["",[],[],nil]] call ALiVE_fnc_HashGet;
                        if (count (_AllAgents select 2) > 0) exitwith {_civFactions = _civFactions + [[(_AllAgents select 2 select 0),"faction","CIV_F"] call ALiVE_fnc_HashGet]};
                    };

                    [time,_center,_id,_size,selectRandom _factions,[_objective,"suicide",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,_civFactions] spawn ALiVE_fnc_INS_suicide;
                };

                if (alive _roadblocks) then {
                    if (!isnil "ALiVE_CIV_PLACEMENT_ROADBLOCKS") then {
                        {
                            // Reset "disable"-action on exisiting roadblocks at the objective once at mission start
                            if (_center distance _x < (_size + 50) && {count (nearestObjects [_x, ["ALIVE_DemoCharge_Remote_Ammo"],2]) < 2}) then {
                                [_x] call ALiVE_fnc_INS_addRoadblockHoldActionWhenReady;
                            };
                        } foreach ALiVE_CIV_PLACEMENT_ROADBLOCKS;
                    };
                };

                //Set default data
                //[_objective,"opcom_orders","none"] call AliVE_fnc_HashSet;
                //[_objective,"tacom_state","none"] call AliVE_fnc_HashSet;
                //[_objective,"opcom_state","unassigned"] call AliVE_fnc_HashSet;
                //[_objective,"section",[]] call AliVE_fnc_HashSet;
                [_objective,"objectiveType",[_objective,"objectiveType","MIL"] call AliVE_fnc_HashGet] call AliVE_fnc_HashSet;

                // debug ---------------------------------------
                if (_debug) then {_args setMarkerColorLocal "ColorWhite"};
                // debug ---------------------------------------

            //} call CBA_fnc_DirectCall;

            _args = [_logic,"objectives",[]] call ALIVE_fnc_hashGet;
        };
        _result = _args;
    };

    case "removeObjective": {
        if !(isServer) exitwith {[_logic,_operation,_args] remoteExec ["ALiVE_fnc_OPCOM",2]};

        if (isnil "_args") then {
            _result = [_logic,"objectives",[]] call ALIVE_fnc_hashGet;
        } else {
            ASSERT_TRUE(_args isequaltype "", str _args);

            private _objectiveID = _args;

            private _objectives = [_logic,"objectives", []] call ALiVE_fnc_HashGet;
            private _objectiveIndex = _objectives findIf { ([_x,"objectiveID",""] call ALiVE_fnc_HashGet) == _objectiveID };

            if (_objectiveIndex != -1) then {
                private _objective = _objectives select _objectiveIndex;
                private _section = [_objective,"section",[]] call ALiVE_fnc_HashGet;

                [_objective,"deleted", true] call ALiVE_fnc_hashSet;

                { [_logic,"resetProfileOrders", _x] call ALiVE_fnc_OPCOM } foreach _section;
                [_logic,"resetObjective", _objectiveID] call ALiVE_fnc_OPCOM;

                _objectives deleteAt _objectiveIndex;
            };

            // clean up markers

            deleteMarker GET_OBJECTIVE_DEBUG_MARKER(_objectiveID);

            private _controlType = ([_logic, "controltype", ""] call ALiVE_fnc_HashGet); 
            if (_controlType == "asymmetric") then {
                {
                    deleteMarker _x;
                } forEach [
                    format ["%1_Hostility", _objectiveID],
                    format ["%1_actions", _objectiveID],
                    format ["hq_%1", _objectiveID],
                    format ["depot_%1", _objectiveID],
                    format ["factory_%1", _objectiveID],
                    format ["ambush_%1", _objectiveID],
                    format ["sabotage_%1", _objectiveID],
                    format ["ied_%1", _objectiveID],
                    format ["suicide_%1", _objectiveID],
                    format ["roadblocks_%1", _objectiveID]
                ];
            };

            _result = _objectives;
        };
    };

    case "findReinforcementBase": {
            _AO = [];
            _FOB = [];
            {
                private ["_state","_orders"];

                _orders = [_x,"opcom_orders",""] call ALiVE_fnc_HashGet;
                _state = [_x,"opcom_state",""] call ALiVE_fnc_HashGet;

                if (_orders in ["attack","defend"]) then {_AO pushback _x} else {
                    if (_state in ["reserve","reserving","idle"]) then {
                        _FOB pushback _x;
                    };
                };
            } foreach ([_logic,"objectives",[]] call ALiVE_fnc_HashGet);

            if (count _FOB > 0 && {count _AO > 0}) then {
                _FOB = [_FOB,[[_AO select 0,"center",[0,0,0]] call ALiVE_fnc_HashGet],{_input0 distance ([_x,"center",[0,0,0]] call ALiVE_fnc_HashGet)},"ASCEND"] call ALiVE_fnc_SortBy;

                _result = _FOB select 0;
            } else {
                if (count _FOB > 0) then {
                    _result = _FOB select 0;
                };
            };
    };

    case "addTask": {
        _operation = _args select 0;
        _pos = _args select 1;
        _section = _args select 2;
        _TACOM_FSM = [_logic,"TACOM_FSM"] call ALiVE_fnc_HashGet;

        _objective = [_logic,"addObjective",[_pos,100,"internal"]] call ALiVE_fnc_OPCOM;
        [_objective,"section",_section] call AliVE_fnc_HashSet;

        _TACOM_FSM setFSMVariable ["_busy",false];
        _TACOM_FSM setFSMVariable ["_TACOM_DATA",["true",nil]];

        switch (_operation) do {
            case ("recon") : {
                _recon = [_objective,_section];
                _TACOM_FSM setFSMVariable ["_recon",_recon];
            };
            case ("capture") : {
                _capture = [_objective,_section];
                _TACOM_FSM setFSMVariable ["_capture",_capture];
            };
            case ("defend") : {
                _defend = [_objective,_section];
                _TACOM_FSM setFSMVariable ["_defend",_defend];
            };
            case ("reserve") : {
                _reserve = [_objective,_section];
                _TACOM_FSM setFSMVariable ["_reserve",_reserve];
            };
        };
    };

    case "pause": {
        if(isNil "_args") then {
            // if no new value was provided return current setting
            _args = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
        } else {
                // if a new value was provided set groups list
                ASSERT_TRUE(typeName _args == "BOOL",str typeName _args);

                waituntil {[_logic,"startupComplete",false] call ALiVE_fnc_HashGet && {([_logic,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet) > -1} && {!isNil {([_logic,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet) getFSMVariable "_pause"}}};

                private ["_state"];

                _state = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
                if (_state && _args) exitwith {};

                //Set value
                _args = [_logic,"pause",_args,false] call ALIVE_fnc_OOsimpleOperation;

                _OPCOM_FSM = [_logic,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet;
                _TACOM_FSM = [_logic,"TACOM_FSM",-1] call ALiVE_fnc_HashGet;

                _TACOM_FSM setFSMvariable ["_pause",_args];
                _OPCOM_FSM setFSMvariable ["_pause",_args];

                ["Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_dump;
        };
        _result = _args;
    };

    case "stop": {
        private ["_opcomID","_opcomFSM","_tacomFSM"];

        _opcomID = [_logic,"opcomID",""] call ALiVE_fnc_HashGet;
        _opcomFSM = [_logic, "OPCOM_FSM",-1] call ALiVE_fnc_HashGet;
        _tacomFSM = [_logic, "TACOM_FSM",-1] call ALiVE_fnc_HashGet;

        if (_tacomFSM != -1) then {
            _tacomFSM setFSMvariable ["_exitFSM",true];
            _tacomFSM setFSMvariable ["_busy",false];
            waituntil {sleep 1; isnil {[_this select 0, "TACOM_FSM"] call ALiVE_fnc_HashGet}};
        };
        if (_opcomFSM != -1) then {
            _opcomFSM setFSMvariable ["_exitFSM",true];
            _opcomFSM setFSMvariable ["_busy",false];
            waituntil {sleep 1; isnil {[_this select 0, "OPCOM_FSM"] call ALiVE_fnc_HashGet}};
        };

        ["OPCOM stopped..."] call ALiVE_fnc_dump;

        _result = true;
    };

    case "createhashobject": {
        if (isServer) then {
            _result = [] call ALIVE_fnc_hashCreate;
            [_result,"super"] call ALIVE_fnc_hashRem;
            [_result,"class"] call ALIVE_fnc_hashRem;
        };
    };

    case "parseTaskProfileCountOverrides": {
        private _overrides = [] call ALIVE_fnc_hashCreate;

        if (isNil "_args") exitWith {
            _result = _overrides;
        };

        private _entries = _args;
        if (_entries isEqualType "") then {
            if (_entries == "") exitWith {
                _result = _overrides;
            };

            private _parseFailed = isNil {
                _entries = call compile _entries;
                false
            };

            if (_parseFailed) exitWith {
                _result = _overrides;
            };
        };

        if !(_entries isEqualType []) exitWith {
            _result = _overrides;
        };

        {
            if (_x isEqualType [] && {count _x >= 2}) then {
                private _taskRaw = _x select 0;
                private _count = _x select 1;

                if (_taskRaw isEqualType "" && {_taskRaw != ""} && {_count isEqualType 0} && {_count >= 0}) then {
                    private _task = toLower _taskRaw;
                    [_overrides,_task,floor _count] call ALiVE_fnc_hashSet;
                };
            };
        } forEach _entries;

        _result = _overrides;
    };

    case "parseTaskProfileTypeOverrides": {
        private _overrides = [] call ALIVE_fnc_hashCreate;

        if (isNil "_args") exitWith {
            _result = _overrides;
        };

        private _entries = _args;
        if (_entries isEqualType "") then {
            if (_entries == "") exitWith {
                _result = _overrides;
            };

            private _parseFailed = isNil {
                _entries = call compile _entries;
                false
            };

            if (_parseFailed) exitWith {
                _result = _overrides;
            };
        };

        if !(_entries isEqualType []) exitWith {
            _result = _overrides;
        };

        {
            if (_x isEqualType [] && {count _x >= 2}) then {
                private _taskRaw = _x select 0;
                private _rawTypes = _x select 1;
                private _types = [];

                if (_taskRaw isEqualType "" && {_taskRaw != ""} && {_rawTypes isEqualType []}) then {
                    private _task = toLower _taskRaw;
                    {
                        if (_x isEqualType "") then {
                            private _type = switch (toLower _x) do {
                                case "infantry": {"infantry"};
                                case "motorized": {"motorized"};
                                case "mechanized": {"mechanized"};
                                case "armored": {"armored"};
                                case "artillery": {"artillery"};
                                case "aaa": {"AAA"};
                                case "air": {"air"};
                                case "sea": {"sea"};
                                default {""};
                            };

                            if (_type != "") then {
                                _types pushBackUnique _type;
                            };
                        };
                    } forEach _rawTypes;

                    if (count _rawTypes == 0 || {count _types > 0}) then {
                        [_overrides,_task,_types] call ALiVE_fnc_hashSet;
                    };
                };
            };
        } forEach _entries;

        _result = _overrides;
    };

    case "normalizeAsymmetricInstallationType": {
        if (isNil "_args" || {!(_args isEqualType "")}) exitWith {
            _result = "";
        };

        _result = switch (toLower _args) do {
            case "hq";
            case "recruit";
            case "recruitmenthq";
            case "recruitment_hq": {"HQ"};
            case "depot": {"depot"};
            case "factory";
            case "iedfactory";
            case "ied_factory": {"factory"};
            case "ied": {"ied"};
            case "roadblock";
            case "roadblocks": {"roadblocks"};
            default {""};
        };
    };

    case "parseAsymmetricInstallationCountOverrides": {
        private _overrides = [] call ALIVE_fnc_hashCreate;

        if (isNil "_args") exitWith {
            _result = _overrides;
        };

        private _entries = _args;
        if (_entries isEqualType "") then {
            if (_entries == "") exitWith {
                _result = _overrides;
            };

            private _parseFailed = isNil {
                _entries = call compile _entries;
                false
            };

            if (_parseFailed) exitWith {
                _result = _overrides;
            };
        };

        if !(_entries isEqualType []) exitWith {
            _result = _overrides;
        };

        {
            if (_x isEqualType [] && {count _x >= 2}) then {
                private _rawType = _x select 0;
                private _count = _x select 1;

                if (_rawType isEqualType "" && {_rawType != ""} && {_count isEqualType 0} && {_count >= 0}) then {
                    private _type = [_logic, "normalizeAsymmetricInstallationType", _rawType] call ALiVE_fnc_OPCOM;

                    if (_type != "") then {
                        [_overrides, _type, floor _count] call ALiVE_fnc_hashSet;
                    };
                };
            };
        } forEach _entries;

        _result = _overrides;
    };

    case "createAsymmetricInstallation": {
        if !(isServer) exitWith {
            _result = false;
        };

        _args params [
            ["_type", "", [""]],
            ["_target", [0,0,0], [[], objNull]],
            ["_useClosestBuilding", false, [true]],
            ["_objectiveRef", objNull, [objNull, [], "", []]]
        ];

        private _installationType = [_logic, "normalizeAsymmetricInstallationType", _type] call ALiVE_fnc_OPCOM;
        if (_installationType == "") exitWith {
            _result = false;
        };

        if (([_logic, "controltype", ""] call ALiVE_fnc_HashGet) != "asymmetric") exitWith {
            _result = false;
        };

        private _anchorPos = [];
        if (_target isEqualType objNull) then {
            if (!isNull _target) then {
                _anchorPos = getPosATL _target;
            };
        } else {
            if (_target isEqualType [] && {count _target >= 2}) then {
                _anchorPos = +_target;
            };
        };

        if (_anchorPos isEqualTo []) exitWith {
            _result = false;
        };

        private _objectiveSearchPos = +_anchorPos;
        private _objective = [];

        if !isNil "_objectiveRef" then {
            if ([_objectiveRef] call ALIVE_fnc_isHash) then {
                _objective = _objectiveRef;
            } else {
                if (_objectiveRef isEqualType "" && {_objectiveRef != ""}) then {
                    _objective = [_logic, "getObjectiveByID", _objectiveRef] call ALiVE_fnc_OPCOM;
                } else {
                    if (_objectiveRef isEqualType [] && {count _objectiveRef >= 2}) then {
                        _objectiveSearchPos = +_objectiveRef;
                    };
                };
            };
        };

        if !([_objective] call ALIVE_fnc_isHash) then {
            private _nearestDistance = -1;

            {
                private _candidateCenter = [_x, "center", []] call ALiVE_fnc_HashGet;

                if !(_candidateCenter isEqualTo []) then {
                    private _distance = _objectiveSearchPos distance2D _candidateCenter;
                    if (_nearestDistance < 0 || {_distance < _nearestDistance}) then {
                        _nearestDistance = _distance;
                        _objective = _x;
                    };
                };
            } foreach ([_logic, "objectives", []] call ALiVE_fnc_HashGet);
        };

        if !([_objective] call ALIVE_fnc_isHash) exitWith {
            _result = false;
        };

        private _objectiveID = [_objective, "objectiveID", ""] call ALiVE_fnc_HashGet;
        private _center = [_objective, "center", []] call ALiVE_fnc_HashGet;
        private _size = [_objective, "size", 0] call ALiVE_fnc_HashGet;
        if (_objectiveID == "" || {_center isEqualTo []}) exitWith {
            _result = false;
        };

        private _existing = [_logic, "convertObject", [_objective, _installationType, []] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
        if (alive _existing) exitWith {
            _result = false;
        };

        private _factions = [_logic, "factions", ["OPF_F"]] call ALiVE_fnc_HashGet;
        if (count _factions == 0) then {
            _factions = ["OPF_F"];
        };

        private _sidesEnemy = [_logic, "sidesenemy", ["WEST"]] call ALiVE_fnc_HashGet;
        private _CQB = [_logic, "CQB", []] call ALiVE_fnc_HashGet;
        _CQB = +_CQB;
        {
            _CQB set [_foreachIndex, [[],"convertObject", _x] call ALiVE_fnc_OPCOM];
        } foreach _CQB;

        private _agents = [_objective, "agents", []] call ALiVE_fnc_HashGet;
        if (_agents isEqualTo [] && {!isNil "ALIVE_sectorGrid"} && {!isNil "ALIVE_agentHandler"}) then {
            private _sector = [ALIVE_sectorGrid, "positionToSector", _center] call ALIVE_fnc_sectorGrid;
            private _sectorData = [_sector, "data", ["", [], [], nil]] call ALIVE_fnc_hashGet;

            if ("clustersCiv" in (_sectorData select 1)) then {
                private _civClusters = [_sectorData, "clustersCiv"] call ALIVE_fnc_hashGet;
                private _settlementClusters = [_civClusters, "settlement", []] call ALIVE_fnc_hashGet;
                private _agentClusterData = [ALIVE_agentHandler, "agentsByCluster", ["", [], [], nil]] call ALiVE_fnc_hashGet;

                if (count _settlementClusters > 0) then {
                    _settlementClusters = [_settlementClusters, [_center], {_Input0 distance (_x select 0)}, "ASCEND"] call ALiVE_fnc_SortBy;
                    _agents = ([_agentClusterData, _settlementClusters select 0 select 1, ["", [], [], nil]] call ALiVE_fnc_HashGet) select 1;
                    [_objective, "agents", _agents] call ALiVE_fnc_HashSet;
                };
            };
        };

        private _spawnPos = +_anchorPos;
        private _selectedTarget = objNull;
        private _created = false;

        if (_installationType in ["HQ", "factory", "depot"]) then {
            private _buildings = [_center, _size] call ALiVE_fnc_INS_filterObjectiveBuildings;
            private _locallyUsedBuildings = [];
            private _externallyUsedBuildings = [];

            {
                private _occupied = [_logic, "convertObject", [_objective, _x, []] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                if (alive _occupied) then {
                    _locallyUsedBuildings pushBackUnique _occupied;
                };
            } foreach ["factory", "HQ", "depot"];

            {
                private _candidateObjective = _x;
                if (([_candidateObjective, "objectiveID", ""] call ALiVE_fnc_HashGet) != _objectiveID) then {
                    {
                        private _occupied = [_logic, "convertObject", [_candidateObjective, _x, []] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                        if (alive _occupied) then {
                            _externallyUsedBuildings pushBackUnique _occupied;
                        };
                    } foreach ["factory", "HQ", "depot"];
                };
            } foreach ([_logic, "objectives", []] call ALiVE_fnc_HashGet);

            private _candidateBuildings = [];
            {
                if !(_x in _externallyUsedBuildings) then {
                    _candidateBuildings pushBack _x;
                };
            } foreach _buildings;

            private _preferredBuildings = _candidateBuildings select {
                !(_x in _locallyUsedBuildings)
            };
            private _selectionBuildings = if (count _preferredBuildings > 0) then {
                _preferredBuildings
            } else {
                _candidateBuildings
            };

            if (_target isEqualType objNull && {!isNull _target} && {alive _target} && {_target in _candidateBuildings}) then {
                _selectedTarget = _target;
            };

            if (isNull _selectedTarget) then {
                private _sortedBuildings = [_selectionBuildings, [_anchorPos], {_Input0 distance2D _x}, "ASCEND"] call ALiVE_fnc_SortBy;
                if (count _sortedBuildings > 0) then {
                    if (_useClosestBuilding || {(_anchorPos distance2D (_sortedBuildings select 0)) <= 15}) then {
                        _selectedTarget = _sortedBuildings select 0;
                    };
                };
            };

            if (alive _selectedTarget) then {
                _spawnPos = getPosATL _selectedTarget;
                [_objective, _installationType, [[],"convertObject", _selectedTarget] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                _created = true;
            };
        } else {
            if (_installationType == "ied") then {
                if !(isnil "ALiVE_MIL_IED") then {
                    private _placeholders = ((nearestobjects [_spawnPos, ["Static"], 150]) + (_spawnPos nearRoads 150));
                    if (count _placeholders > 0) then {
                        _selectedTarget = _placeholders select 0;
                    } else {
                        _selectedTarget = _spawnPos nearestObject "building";
                    };
                    [_objective, "ied", [[],"convertObject", _selectedTarget] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                    _created = true;
                };
            } else {
                if (_installationType == "roadblocks") then {
                    private _roadblockCap = ceil (_size / 200);
                    private _existingRoadblockCount = if (isnil "ALiVE_CIV_PLACEMENT_ROADBLOCKS") then {
                        0
                    } else {
                        {_spawnPos distance _x < _size} count ALiVE_CIV_PLACEMENT_ROADBLOCKS
                    };

                    if (_existingRoadblockCount < _roadblockCap) then {
                        private _roadblockFaction = [_spawnPos, _size] call ALiVE_fnc_getDominantFaction;

                        if !(isNil "_roadblockFaction") then {
                            private _candidateRoads = _spawnPos nearRoads (_size + 20);
                            _candidateRoads = _candidateRoads select {
                                _x distance _spawnPos >= (_size - 10) || {isOnRoad _x} || {(str _x) find "invisible" == -1}
                            };

                            private _existingRoadblocks = if (isnil "ALiVE_CIV_PLACEMENT_ROADBLOCKS") then {[]} else {ALiVE_CIV_PLACEMENT_ROADBLOCKS};
                            private _viableRoadIndex = _candidateRoads findIf {
                                private _road = _x;

                                ({_road distance _x < 100} count _existingRoadblocks) == 0
                                && {isOnRoad _road}
                                && {count (roadsConnectedTo _road) > 0}
                                && {((nearestBuilding position _road) distance2D position _road) >= 20}
                                && {!(position _road isFlatEmpty [-1, -1, 0.3, 10, -1] isEqualTo [])}
                            };

                            if (_viableRoadIndex >= 0) then {
                                [_objective, "roadblocks", [[],"convertObject", _spawnPos nearestObject "building"] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                                _created = true;
                            };
                        };
                    };
                };
            };
        };

        if !_created exitWith {
            _result = false;
        };

        private _faction = selectRandom _factions;
        switch (_installationType) do {
            case "factory": {
                [time, _center, _objectiveID, _size, _faction, _selectedTarget, _sidesEnemy, _agents, +_CQB] spawn ALiVE_fnc_INS_factory;
            };
            case "depot": {
                [time, _center, _objectiveID, _size, _faction, _selectedTarget, _sidesEnemy, _agents, +_CQB] spawn ALiVE_fnc_INS_depot;
            };
            case "HQ": {
                [time, _center, _objectiveID, _size, _faction, _selectedTarget, _sidesEnemy, _agents, +_CQB] spawn ALiVE_fnc_INS_recruit;
            };
            case "ied": {
                [time, _spawnPos, _objectiveID, _size, _faction, _selectedTarget, _sidesEnemy, _agents] spawn ALiVE_fnc_INS_ied;
            };
            case "roadblocks": {
                [time, _spawnPos, _objectiveID, _size, _faction, objNull, _sidesEnemy, _agents, +_CQB] spawn ALiVE_fnc_INS_roadblocks;
            };
        };

        _result = true;
    };

    case "seedAsymmetricInstallations": {
        if (isNil "_args") then {
            _args = [_logic, "objectives", []] call ALiVE_fnc_HashGet;
        };

        private _objectives = _args;
        private _debug = [_logic, "debug", false] call ALiVE_fnc_HashGet;
        private _handledObjectiveIDs = [];
        private _processedSources = [];

        {
            private _objective = _x;
            private _sourceKey = [_objective, "asymmetricInstallationOverrideSource", ""] call ALiVE_fnc_HashGet;
            private _overrides = [_objective, "asymmetricInstallationCountOverrides", []] call ALiVE_fnc_HashGet;

            if (_sourceKey != "" && {[_overrides] call ALIVE_fnc_isHash} && {count (_overrides select 1) > 0} && {!(_sourceKey in _processedSources)}) then {
                _processedSources pushBack _sourceKey;

                private _groupObjectives = [];
                {
                    if (([_x, "asymmetricInstallationOverrideSource", ""] call ALiVE_fnc_HashGet) == _sourceKey) then {
                        _groupObjectives pushBack _x;
                        private _groupObjectiveID = [_x, "objectiveID", ""] call ALiVE_fnc_HashGet;
                        if (_groupObjectiveID != "") then {
                            _handledObjectiveIDs pushBackUnique _groupObjectiveID;
                        };
                    };
                } foreach _objectives;

                {
                    private _installationType = _x;
                    private _requestedCount = [_overrides, _installationType, 0] call ALiVE_fnc_HashGet;
                    private _createdCount = 0;
                    private _usedObjectiveIDs = [];

                    if (_requestedCount > 0) then {
                        {
                            private _objectiveCandidate = _x;
                            private _candidateObjectiveID = [_objectiveCandidate, "objectiveID", ""] call ALiVE_fnc_HashGet;

                            if (_createdCount < _requestedCount && {!(_candidateObjectiveID in _usedObjectiveIDs)}) then {
                                private _createdInstallation = [_logic, "createAsymmetricInstallation", [_installationType, [_objectiveCandidate, "center", []] call ALiVE_fnc_HashGet, _installationType in ["HQ", "depot", "factory"], _objectiveCandidate]] call ALiVE_fnc_OPCOM;

                                if (_createdInstallation) then {
                                    _createdCount = _createdCount + 1;
                                    _usedObjectiveIDs pushBack _candidateObjectiveID;
                                };
                            };
                        } foreach _groupObjectives;
                    };

                    if (_debug && {_requestedCount > _createdCount}) then {
                        ["OPCOM asymmetric installation overrides requested %1 %2 installations but only placed %3.", _requestedCount, _installationType, _createdCount] call ALiVE_fnc_dump;
                    };
                } foreach ["HQ", "factory", "depot", "ied", "roadblocks"];
            };
        } foreach _objectives;

        _result = _handledObjectiveIDs;
    };

    case "getTaskProfileCount": {
        _args params [
            ["_task","",[""]],
            ["_default",0,[0]],
            ["_fallbackTask","",[""]]
        ];

        _result = _default;

        private _overrides = [_logic,"taskProfileCountOverrides",[]] call ALiVE_fnc_hashGet;
        if !([_overrides] call ALIVE_fnc_isHash) exitWith {};

        private _taskOverride = [_overrides, toLower _task] call ALiVE_fnc_hashGet;
        if (!isnil "_taskOverride" && {_taskOverride isEqualType 0}) exitwith {
            _result = _taskOverride;
        };

        private _fallbackTaskOverride = [_overrides, toLower _fallbackTask] call ALiVE_fnc_hashGet;
        if (!isnil "_fallbackTaskOverride" && {_fallbackTaskOverride isEqualType 0}) exitwith {
            _result = _fallbackTaskOverride;
        };
    };

    case "getTaskProfileTypes": {
        _args params [
            ["_task","",[""]],
            ["_default",[],[[]]],
            ["_fallbackTask","",[""]]
        ];

        _result = +_default;

        private _overrides = [_logic,"taskProfileTypeOverrides",[]] call ALiVE_fnc_hashGet;
        if !([_overrides] call ALIVE_fnc_isHash) exitWith {};

        private _found = false;
        {
            if (!_found) then {
                private _taskKey = toLower _x;

                if (_taskKey != "") then {
                    private _override = [_overrides,_taskKey,"__ALIVE_MISSING__"] call ALiVE_fnc_hashGet;

                    if (_override isEqualType []) then {
                        _result = +_override;
                        _found = true;
                    };
                };
            };
        } forEach [_task,_fallbackTask];
    };

    case "convertObject": {
        private ["_object"];

        if !(isNil "_args") then {
            if (typeName _args == "ARRAY") then {

                _object = objNull;

                if (count _args == 2) then {
                    _object = (_args select 0) nearestObject (_args select 1);

                    if (isnil "_object" || {!alive _object}) then {
                        _objects = (_args select 0) nearEntities [_args select 1,1];

                        if (count _objects > 0) then {_object = _objects select 0};
                    };
                };
            } else {
                if(typeName _args == "OBJECT") then {
                    if (alive _args) then {_object = [[getposATL _args select 0,getposATL _args select 1],typeOf _args]} else {_object = []};
                };
            };
            _result = _object;
        };
    };

    case "saveData": {
        private ["_objectives","_exportObjectives","_objective","_objectiveID","_exportObjective","_objectivesGlobal","_save","_messages","_message","_saveResult"];

        if (isServer && {!isNil "ALIVE_sys_data"} && {!ALIVE_sys_data_DISABLED}) then {

            private ["_exportProfiles","_async","_missionName"];

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["OPCOM - SAVE DATA TRIGGERED"] call ALiVE_fnc_dump;
            };

            _result = [false,[]];
            _blacklist = ["code","actions"];

            //Save only every 60 seconds, bad hack because of this http://dev.withsix.com/issues/74321
            //For normal each instance would save their own objectives but the hack collects all objectives of all OPCOMs on one save, FIFO principle
            if (isnil QGVAR(OBJECTIVES_DB_SAVE) || {!(isnil QGVAR(OBJECTIVES_DB_SAVE)) && {time - (GVAR(OBJECTIVES_DB_SAVE) select 1) > 300}}) then {

                _objectivesGlobal = [];
                {
                    if ([_x,"persistent",false] call ALIVE_fnc_HashGet) then {
                        _objectivesGlobal = _objectivesGlobal + ([_x, "objectives",[]] call ALiVE_fnc_HashGet);
                    };
                } foreach OPCOM_INSTANCES;

                GVAR(OBJECTIVES_DB_SAVE) = [_objectivesGlobal,time];
                {
                    if(ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["OPCOM - SAVE DATA Objective prepared for DB: %1",_x] call ALiVE_fnc_dump;
                    };
                } foreach (GVAR(OBJECTIVES_DB_SAVE) select 0);
                _save = true;
            };
            if (isnil "_save") exitwith {["OPCOM - SAVE DATA Please wait at least 5 minutes before saving again!"] call ALiVE_fnc_dump;};
            if (count (GVAR(OBJECTIVES_DB_SAVE) select 0) == 0) exitwith {["SAVE OPCOM DATA Dataset is empty, not saving...!"] call ALiVE_fnc_dump;};

            //If I didnt send you to hell - go and save, the feck!
            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["OPCOM - SAVE DATA - SYS DATA EXISTS"] call ALiVE_fnc_dump;
            };

            if (isNil QGVAR(DATAHANDLER)) then {

                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["OPCOM - CREATE DATA HANDLER!"] call ALiVE_fnc_dump;
                };

                GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
                [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
                };

            _exportObjectives = [] call ALIVE_fnc_hashCreate;

            {
                _objective = _x;
                _objectiveID = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;

                _exportObjective = [_objective, [], []] call ALIVE_fnc_hashCopy;

                if([_exportObjective, "_rev"] call ALIVE_fnc_hashGet == "") then {
                    [_exportObjective, "_rev"] call ALIVE_fnc_hashRem;
                };

                {[_exportObjective, _x] call ALIVE_fnc_hashRem} foreach _blacklist;

                [_exportObjectives, _objectiveID, _exportObjective] call ALIVE_fnc_hashSet;

                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["OPCOM - EXPORT READY OBJECTIVE:"] call ALiVE_fnc_dump;
                    _exportObjective call ALIVE_fnc_inspectHash;
                };


            } forEach (GVAR(OBJECTIVES_DB_SAVE) select 0);


            _message = format["ALiVE OPCOM - Preparing to save %1 objectives..",count(_exportObjectives select 1)];
            _messages = _result select 1;
            _messages pushback _message;


            _async = false; // Wait for response from server
            _missionName = [missionName, "%20","-"] call CBA_fnc_replace;
            _missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName]; // must include group_id to ensure mission reference is unique across groups

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["OPCOM - SAVE DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALiVE_fnc_dump;
            };

            _saveResult = [GVAR(DATAHANDLER), "bulkSave", ["mil_opcom", _exportObjectives, _missionName, _async]] call ALIVE_fnc_Data;
            _result set [0,_saveResult];

            _message = format["ALiVE OPCOM - Save Result: %1",_saveResult];
            _messages = _result select 1;
            _messages pushback _message;

            // Save starting forces (every session to allow users to modify the array and persist it)
            if (!isnil {[_logic,"startForceStrength"] call ALiVE_fnc_HashGet}) then {
                private _key = format ["%1-OPCOM_%2-starting-forces", _missionName, [_logic, "opcomID"] call CBA_fnc_hashGet];
                private _prev = [GVAR(DATAHANDLER), "read", ["mil_opcom", [], _key]] call ALIVE_fnc_Data;

                private _startForceStrength = [_logic,"startForceStrength"] call ALiVE_fnc_HashGet;
                private _data = [[["data", _startForceStrength]]] call CBA_fnc_hashCreate;

                if (_prev isEqualType []) then {
                    private _rev = [_prev, "_rev"] call CBA_fnc_hashGet;

                    if (!isNil {_rev}) then {
                        [_data, "_rev", _rev] call CBA_fnc_hashSet;
                    };
                };

                [GVAR(DATAHANDLER), "write", ["mil_opcom", _data, false, _key]] call ALIVE_fnc_Data;
            };

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["OPCOM - SAVE DATA RESULT (maybe truncated in RPT, dont worry): %1",_saveResult] call ALiVE_fnc_dump;
                ["OPCOM - SAVE DATA SAVING COMPLETE!"] call ALiVE_fnc_dump;
            };
        };
    };

    case "loadData": {
        private ["_stopped","_result"];

        if !(isServer && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {["LOAD OPCOM DATA FROM DB NOT POSSIBLE! NO SYS DATA MODULE AVAILABLE OR NOT DEDICATED!"] call ALiVE_fnc_dumpR};

        //Stop OPCOM
        _stopped = [_logic,"stop"] call ALiVE_fnc_OPCOM;

        //Load from DB
        _objectives = [_logic,"loadObjectivesDB"] call ALiVE_fnc_OPCOM;

        //Reset objectives
        [_logic,"objectives",_objectives] call ALiVE_fnc_HashSet;

        //Restart OPCOM
        switch ([_logic,"controltype","invasion"] call ALiVE_fnc_HashGet) do {
            case ("occupation") : {
                _OPCOM = [_logic] call {
                    _handler = _this select 0;

                    _OPCOM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                    _TACOM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";

                    [_handler, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                    [_handler, "TACOM_FSM",_TACOM] call ALiVE_fnc_HashSet;
                };
            };
            case ("invasion") : {
                _OPCOM = [_logic] call {
                    _handler = _this select 0;

                    _OPCOM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                    _TACOM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";

                    [_handler, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                    [_handler, "TACOM_FSM",_TACOM] call ALiVE_fnc_HashSet;
                };
            };
            case ("asymmetric") : {
                _OPCOM = [_logic] execFSM "\x\alive\addons\mil_opcom\insurgency.fsm";

                [_logic, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                [_logic, "TACOM_FSM",-1] call ALiVE_fnc_HashSet;
            };
        };

        if(ALiVE_SYS_DATA_DEBUG_ON) then {
            ["OPCOM - LOAD DATA Imported %1 objectives from DB!",count ([_logic,"objectives",[]] call ALiVE_fnc_HashGet)] call ALiVE_fnc_dump;
        };

        _result = _objectives;
    };

    case "loadObjectivesDB": {
        private _opcomID = [_logic,"opcomID",""] call ALiVE_fnc_HashGet;
        private _objectives = [];

        _result = [];

        if (!isServer) exitwith {};

        if (!isNil "ALIVE_sys_data" && {!ALIVE_sys_data_DISABLED}) then {
            private ["_importProfiles","_result","_i"];

            //defaults
            private _async = false;
            private _missionName = [missionName, "%20","-"] call CBA_fnc_replace;
            _missionName = format ["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName];

            if (ALiVE_SYS_DATA_DEBUG_ON) then {
                ["OPCOM - LOAD DATA  - MISSION: %1",_missionName] call ALiVE_fnc_dump;
            };

            //Load only every 5 minutes
            if (isnil QGVAR(OBJECTIVES_DB_LOAD) || {!(isnil QGVAR(OBJECTIVES_DB_LOAD)) && {time - (GVAR(OBJECTIVES_DB_LOAD) select 1) > 300}}) then {

                if (ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["OPCOM - LOAD DATA  FROM DB, PLEASE WAIT..."] call ALiVE_fnc_dump;
                };

                if (isNil QGVAR(DATAHANDLER)) then {

                    if (ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["OPCOM - CREATE DATA HANDLER!"] call ALiVE_fnc_dump;
                    };

                    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
                    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
                };

                [true] call ALIVE_fnc_timer;
                GVAR(OBJECTIVES_DB_LOAD) = [[GVAR(DATAHANDLER), "bulkLoad", ["mil_opcom", _missionName, _async]] call ALIVE_fnc_Data,time];
                [] call ALIVE_fnc_timer;

                //Exit if no loaded data
                if (((typeName (GVAR(OBJECTIVES_DB_LOAD) select 0)) == "BOOL") && {!(GVAR(OBJECTIVES_DB_LOAD) select 0)}) exitwith {};

                if (ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["OPCOM - LOAD DATA %1 OBJECTIVES LOADED FROM DB!",count ((GVAR(OBJECTIVES_DB_LOAD) select 0) select 2)] call ALiVE_fnc_dump;
                };
            } else {

                if (ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["OPCOM - LOAD DATA FROM CACHE!"] call ALiVE_fnc_dump;
                };
            };

            _result = GVAR(OBJECTIVES_DB_LOAD) select 0;

            if (!(isnil "_result") && {typename _result == "ARRAY"} && {count _result > 0} && {count (_result select 2) > 0}) then {

                _objectives = [];
                {
                    _id = [_x,"opcomID",""] call ALiVE_fnc_HashGet;

                    if (_id == _opcomID) then {

                        //["LOAD OPCOM DATA RESETTING RESULT %1/%2!",_foreachIndex,(count _objectives)] call ALiVE_fnc_dump;

                        _rev = [_x,"_rev",""] call ALiVE_fnc_HashGet;

                        [_x, "_id"] call ALIVE_fnc_hashRem;
                        [_x, "_rev"] call ALIVE_fnc_hashRem;

                        [_x,"_rev",_rev] call ALiVE_fnc_HashSet;

                        _objectives pushback _x;
                    };
                } foreach (_result select 2);

                private _keys = [
                    "objectiveID","center","size","objectiveType","priority","opcom_state","clusterID","opcomID",
                    "opcom_orders","danger","sectionAssist","section","tacom_state",
                    "factory","HQ","ambush","depot","sabotage","ied","suicide","roadblocks",
                    "actionsFulfilled",
                    "_rev"
                ];

                // Rebuild objectives in correct index-order
                {
                    //["LOAD OPCOM DATA CLEANING HASH %1/%2!",_foreachIndex,(count _objectives)] call ALiVE_fnc_dump;

                    private _entry = _x;

                    private _target = [nil,"createhashobject"] call ALIVE_fnc_OPCOM;

                    {
                        _data = [_entry,_x] call ALiVE_fnc_HashGet;

                        if !(isnil "_data") then {
                            [_target,_x,_data] call ALiVE_fnc_HashSet;
                        } else {
                            [_target,_x] call ALiVE_fnc_HashRem;
                        };
                    } foreach _keys;

                    _objectives set [_foreachIndex, _target];
                } foreach _objectives;

                [_logic,"objectives", _objectives] call ALiVE_fnc_HashSet;
                [_logic,"clusteroccupation", []] call ALiVE_fnc_HashSet;

                private _i = 10;

                _objectives = [_logic,"objectives", []] call ALiVE_fnc_HashGet;
                {
                    private _entry = _x;

                    if (_i == 10) then {
                        _i = 0;

                        if(ALiVE_SYS_DATA_DEBUG_ON) then {
                            ["OPCOM - LOAD DATA REBUILDING OBJECTIVE %1/%2!", _foreachIndex, (count _objectives)] call ALiVE_fnc_dump;
                        };
                    };

                    _i = _i + 1;

                    private _oID = [_entry,"objectiveID", ""] call ALiVE_fnc_HashGet;
                    private _section = [_entry,"section", []] call ALiVE_fnc_HashGet;

                    if !(isnil "_section") then {
                        { [_logic,"resetProfileOrders", _x] call ALiVE_fnc_OPCOM } foreach _section;
                    };

                    if !(isnil "_oID") then {
                        switch ([_logic,"controltype","invasion"] call ALiVE_fnc_HashGet) do {
                            case ("asymmetric") : {
                                [_logic,"initObjective", _oID] call ALiVE_fnc_OPCOM;
                            };
                            default {
                                [_logic,"resetObjective", _oID] call ALiVE_fnc_OPCOM;
                            };
                        };
                    };
                } foreach _objectives;

                [_logic,"objectives", _objectives] call ALiVE_fnc_HashSet;
                _objectives = [_logic,"objectives", []] call ALiVE_fnc_HashGet;

                if (ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["OPCOM - LOAD DATA IMPORTED %1 OBJECTIVES FROM DB!", count _objectives] call ALiVE_fnc_dump;
                };
            } else {
                if (ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["OPCOM - LOAD DATA LOADING FROM DB FAILED!"] call ALiVE_fnc_dump;
                };
            };
        } else {
            if (ALiVE_SYS_DATA_DEBUG_ON) then {
                ["OPCOM - LOAD DATA FROM DB NOT POSSIBLE! NO SYS DATA MODULE AVAILABLE!"] call ALiVE_fnc_dumpR;
            };
        };

        _result = _objectives;
    };

    case "objectives": {
        if (isnil "_args") then {
            _result = [_logic,"objectives", []] call ALIVE_fnc_hashGet;
        } else {
            if (_args isequaltype []) then {
                [_logic,"objectives", _args] call ALIVE_fnc_hashSet;
                _result = _args;
            };
        };
    };

    case "findOPCOMByAllegiance": {
        if (_args isequaltype "") then {
            private _identifier = tolower _args;

            private _opcomIndex = OPCOM_instances findif {
                private _factions = ([_x,"factions", []] call ALiVE_fnc_HashGet) apply { tolower _x };
                private _side = tolower ([_x,"side", ""] call ALiVE_fnc_HashGet);

                (_identifier == _side) || { _identifier in _factions }
            };

            if (_opcomIndex != -1) then {
                _result = OPCOM_instances select _opcomIndex;
            };
        };
    };

    case "addObjective": {
        // allow users to pass side or faction classname for _logic
        _logic = if (_logic isequaltype "") then {
            private _identifier = _logic;
            _logic = [nil,"findOPCOMByAllegiance", _identifier] call ALiVE_fnc_OPCOM;

            if (isnil  "_logic") then {
                ["OPCOM operation 'addObjective' didn't find an OPCOM for faction or side %1!", _identifier] call ALiVE_fnc_dump;
            };
        } else {
            _logic
        };

        if (isnil "_logic" || isnil "_args") exitwith {};

        ASSERT_TRUE(_args isequaltype [], str _args);
        ASSERT_TRUE(count _args > 2 ,str _args);

        private _debug = [_logic,"debug", false] call ALIVE_fnc_HashGet;
        private _side = [_logic,"side", "EAST"] call ALIVE_fnc_HashGet;

        _args params [
            ["_id", "", [""]],
            ["_pos", [0,0,0], [[]]],
            ["_size", 50, [-1]],
            ["_type", "unknown", [""]],
            ["_priority", 100, [-1]],
            ["_opcomState", "unassigned", [""]],
            ["_clusterID", "none", [""]],
            ["_opcomID", [_logic,"opcomID", ""] call ALiVE_fnc_HashGet, [""]]
        ];

        private _objective = [[
            ["objectiveID", _id],
            ["center", _pos],
            ["size", _size],
            ["objectiveType", _type],
            ["priority", _priority],
            ["opcom_state", _opcomState],
            ["clusterID", _clusterID],
            ["opcomID", _opcomID],
            ["deleted", false],
            ["_rev", ""]
        ]] call ALIVE_fnc_hashCreate;

        if (_debug) then {
            [_logic,"createObjectiveDebugMarkers", [_objective]] call MAINCLASS;
        };

        private _objectives = [_logic,"objectives"] call ALiVE_fnc_HashGet;
        _objectives pushback _objective;

        _result = _objective;
    };

    /*

    */

    case "createObjectives";
    case "createobjectives": {
        if (isnil "_args") exitwith {
            _result = [_logic,"objectives"] call ALIVE_fnc_hashGet;
        };

        _args params ["_objectives","_sortingStrategy"];

        ([_logic, ["position","side","factions","debug","opcomID"]] call ALiVE_fnc_hashGetMany) params [
            "_startpos",
            "_side",
            "_factions",
            ["_debug", false],
            ["_opcomID", ""]
        ];

        private _unsortedObjectives = _objectives apply {
            private _target = _x;

            ([_target, ["center","size","objectiveType","priority","clusterID","asymmetricInstallationCountOverrides","asymmetricInstallationOverrideSource"]] call ALiVE_fnc_hashGetMany) params [
                "_pos",
                "_size",
                "_type",
                "_priority",
                "_clusterID",
                ["_asymmetricInstallationCountOverrides", []],
                ["_asymmetricInstallationOverrideSource", ""]
            ];

            [_pos,_size,_type,_priority,_clusterID,_opcomID,_asymmetricInstallationCountOverrides,_asymmetricInstallationOverrideSource]
        };

        // create objectives
        
        {
            private _id = format ["OPCOM_%1_objective_%2_%3", _opcomID, _foreachIndex, diag_ticktime];

            _x params [
                "_pos",
                "_size",
                "_type",
                "_priority",
                "_clusterID",
                "_opcomID",
                "_asymmetricInstallationCountOverrides",
                "_asymmetricInstallationOverrideSource"
            ];

            private _opcomState = "unassigned";

            private _createdObjective = [_logic,"addObjective", [_id,_pos,_size,_type,_priority,_opcomState,_clusterID,_opcomID]] call ALiVE_fnc_OPCOM;

            private _isSeededAsymmetricObjective = _asymmetricInstallationCountOverrides isnotequalto [];
            if (_isSeededAsymmetricObjective) then {
                [_createdObjective,"asymmetricInstallationCountOverrides", _asymmetricInstallationCountOverrides] call ALiVE_fnc_HashSet;
                [_createdObjective,"asymmetricInstallationOverrideSource", _asymmetricInstallationOverrideSource] call ALiVE_fnc_HashSet;
            };
        } foreach _unsortedObjectives;

        [_logic,"sortObjectives", _sortingStrategy] call ALiVE_fnc_OPCOM;

        _result = [_logic,"objectives", []] call ALiVE_fnc_HashGet;
    };

    case "createObjectiveDebugMarkers": {
        private _objectives = if (_args isequaltype []) then { _args } else { [_logic,"objectives"] call ALiVE_fnc_HashGet };
        private _fullObjectiveIDList = ([_logic,"objectives"] call ALiVE_fnc_HashGet) apply { [_x,"objectiveID"] call ALiVE_fnc_HashGet };

        private _sideSettings = createHashMapFromArray [
            ["EAST", ["COLORRED", 0]],
            ["WEST", ["COLORBLUE", 1]],
            ["GUER", ["COLORGREEN", 2]]
        ];

        {
            private _id = [_x,"objectiveID",""] call ALiVE_fnc_HashGet;
            private _pos = [_x,"center",[0,0,0]] call ALiVE_fnc_HashGet;
            private _type = [_x,"objectiveType",""] call ALiVE_fnc_HashGet;
            private _side = [_logic,"side","EAST"] call ALiVE_fnc_HashGet;

            (_sideSettings getordefault [_side, ["COLORWHITE", 3]]) params [
                "_color",
                "_yOffsetMultipler"
            ];
            
            _pos set [1, (_pos select 1) + (3 * _yOffsetMultipler)];
            
            private _priorityIndex = _fullObjectiveIDList find _id;

            private _debugMarkerID = GET_OBJECTIVE_DEBUG_MARKER(_id);
            deleteMarker _debugMarkerID;

            [
                _debugMarkerID,
                ["opcom", _pos] call ALiVE_fnc_debugMarkerOffset,
                "ICON",
                [0.5,0.5],
                _color,
                format["%1 #%2 (%3)", _side, _priorityIndex, _type],
                "mil_dot",
                "FDiagonal",
                0,
                0.5
            ] call ALIVE_fnc_createMarkerGlobal;
        } foreach _objectives;
    };

    case "nearestObjectives": {
        ASSERT_TRUE(typeName _args == "ARRAY" && {count _args >= 1},str _args);

        private ["_state","_pos","_objectives","_tmp"];

        _pos = _args select 0;
        _state = _args select 1; if (isnil "_state") then {_state = "attacking"};

        _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;

        if (count _objectives == 0) exitwith {_result = []};

        _tmp = []; {if (([_x,"opcom_state",""] call ALiVE_fnc_HashGet) == _state) then {_tmp pushback _x}} foreach _objectives;
        _tmp = [_tmp,[_pos],{_Input0 distance ([_x,"center",[0,0,0]] call ALiVE_fnc_HashGet)},"ASCEND"] call ALiVE_fnc_SortBy;

        _result = +_tmp;
    };

    case "nearestEntity": {
        ASSERT_TRUE(typeName _args == "ARRAY" && {count _args >= 1},str _args);

        private ["_objectives","_state"];

        _unit = _args select 0;
        _state = _args select 1; if (isnil "_state") then {_state = "attacking"};

        _pos = getposATL _unit;
        _faction = faction _unit;

        _objectives = [_logic,"nearestObjectives",[_pos,_state]] call ALiVE_fnc_OPCOM;

        if (count _objectives == 0) exitwith {};

        {
            private ["_profile"];

            _profile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

            if !(isnil "_profile") exitwith {_result = _x}
        } foreach ([_objectives select 0,"section",[]] call ALiVE_fnc_HashGet);
    };

    case "joinObjectiveClient": {
        ASSERT_TRUE(typeName _args == "ARRAY",str _args);

        private ["_positions","_pos"];

        // Execute Function on Clients only
        if !(hasInterface) exitwith {[_logic,_operation,_args] remoteExec ["ALiVE_fnc_OPCOM",owner _unit]};

        _args params [
            ["_unit", player, [objNull]],
            ["_objectives", [], [[]]],
            ["_color", "COLORYELLOW", [""]]
        ];

        // Only run function if objectives are provided
        if (count _objectives == 0) exitwith {hint "OPCOM currently has no assault objectives in his list!"};

        // Mark objectives, this handy function should be moved to x lib
        _fnc_createMarkerArray = {
            private ["_markers"];

            params [
                ["_positions", [], [[]]],
                ["_color", "COLORYELLOW", [""]],
                ["_shape", "RECTANGLE", [""]],
                ["_size", [500, 500], [[]]],
                ["_type", "EMPTY", [""]],
                ["_text", "", [""]],
                ["_brush", "SOLID", [""]],
                ["_alpha", 0.5, [-1]]
            ];

            _markers = [];
            {
                _m = createMarkerLocal [str(_x), _x];
                _m setMarkerShapeLocal _shape;
                _m setMarkerSizeLocal _size;
                _m setMarkerTypeLocal _type;
                _m setMarkerColorLocal _color;
                _m setMarkerTextLocal _text;
                _m setMarkerBrushLocal _brush;
                _m setMarkerAlphaLocal _alpha;

                _markers pushback _m;
            } foreach _positions;

            _markers;
        };
        _positions = []; {_positions pushback ([_x,"center"] call ALiVE_fnc_Hashget)} foreach _objectives;
        [_positions,_color,"RECTANGLE",[500,500],"EMPTY","","FDiagonal",0.5] call _fnc_createMarkerArray;

        // Select position on map
        openmap true; hint "Click on map to select objective!";
        ALiVE_MIL_OPCOM_CLICKPOS = nil; onMapSingleclick "ALiVE_MIL_OPCOM_CLICKPOS = _pos; onMapSingleclick ''";
        waituntil {!isnil "ALiVE_MIL_OPCOM_CLICKPOS"}; _pos = ALiVE_MIL_OPCOM_CLICKPOS;
        ALiVE_MIL_OPCOM_CLICKPOS = nil; hint "Objective selected! Please wait while OPCOM is preparing the operation...";

        // Get nearest objective from that position
        _objectives = [_objectives,[_pos],{_Input0 distance ([_x,"center"] call ALiVE_fnc_HashGet)},"ASCEND"] call ALiVE_fnc_SortBy;

        [_logic,"joinObjectiveServer",[_unit,_objectives select 0]] call ALiVE_fnc_OPCOM;

        openmap false;

        // Remove markers
        {deleteMarkerLocal str(_x)} foreach _positions;
    };

    case "joinObjectiveServer": {
        ASSERT_TRUE(typeName _args == "ARRAY",str _args);

        private ["_section","_entityID","_profile","_error","_players"];

        // Execute on Server only
        if !(isServer) exitwith {[_logic,_operation,_args] remoteExec ["ALiVE_fnc_OPCOM",2]};

        _args params [
            ["_unit", objNull, [objNull]],
            ["_objective", [], [[]]]
        ];

        _section = ([_objective,"section",[]] call ALiVE_fnc_HashGet) - [_unit getvariable ["profileID",""]]; if (count _section <= 0) then {_error = "OPCOM responds that the select section is destroyed!"};
        _profile = [ALiVE_ProfileHandler,"getProfile",_section select 0] call ALiVE_fnc_ProfileHandler; if (isnil "_profile") then {_error = "OPCOM reports that the assigned group is already dead!"};
        _profileUnit = [ALiVE_ProfileHandler,"getProfile",_unit getvariable ["profileID",""]] call ALiVE_fnc_ProfileHandler; if (isnil "_profileUnit") then {_error = "OPCOM reports that players group cannot be assigned!"};

        if !(isnil "_error") exitwith {hint _error; ["%1",_error] call ALiVE_fnc_Dump};

        _players = []; {if (isPlayer _x) then {_players pushback _x}} foreach (units group _unit);

        {{titleText ['Preparing Insertion...', 'BLACK OUT',2]} remoteExec ["BIS_fnc_Spawn",owner _x]; sleep 0.2} foreach _players;

        sleep 5;

        _unit setposATL ([_profile,"position"] call ALiVE_fnc_HashGet);

        waituntil {sleep 1; [_profile,"active"] call ALiVE_fnc_HashGet};

        _units = [_profile,"units"] call ALIVE_fnc_hashGet;
        _group = group (_units select 0);

        (units (group _unit)) join _group;

        sleep 5;

        if ((vehicle leader _group) == (leader _group)) then {
            {_x setposATL (formationPosition _x)} foreach (units (group _unit));

            //_x addBackpack "B_Parachute" is local - applause
            //_pos set [2,1000];
            //{_x addBackpack "B_Parachute"; _x setPosATL _pos} foreach _groupUnits;
        } else {
            {_x setposATL ([getposATL leader _group,50] call CBA_fnc_RandPos); _x moveInCargo (vehicle leader _group)} foreach (units (group _unit));
        };

        [_profileUnit, "clearWaypoints"] call ALIVE_fnc_profileEntity;
        {[_profileUnit, "addWaypoint", _x] call ALIVE_fnc_profileEntity} foreach ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet);

        {{titleText ['Inserting...', 'BLACK IN',2]} remoteExec ["BIS_fnc_Spawn",owner _x]; sleep 0.2} foreach _players;
    };


    ///////////////////////////////////////////////////
    // Scan all objectives for nearby profiles
    // Sort into owned / contested / enemy owned objectives
    // Sets opcom_state for each objective based on occupation
    ///////////////////////////////////////////////////

    case "analyzeclusteroccupation": {
        _args params ["_sidesFriendly","_sidesEnemy"];

        private _objectives = [_logic,"objectives", []] call ALiVE_fnc_HashGet;

        private _friendlyObjectives = [];
        private _enemyObjectives = [];
        private _contestedObjectives = [];
        {
            private _objective = _x;

            private _id = [_objective,"objectiveID"] call ALiVE_fnc_HashGet;
            private _pos = [_objective,"center"] call ALiVE_fnc_HashGet;

            private _section = [_objective,"section", []] call ALiVE_fnc_HashGet;
            if (_section isequalto []) then {
                [_objective,"opcom_state", "unassigned"] call ALiVE_fnc_HashSet;
                [_objective,"opcom_orders", "none"] call ALiVE_fnc_HashSet;
                [_objective,"danger", -1] call ALiVE_fnc_HashSet;
            };

            // find nearby friendly/enemy entities

            private _nearEntities = [_pos, 500, ["all","entity"]] call ALIVE_fnc_getNearProfiles;

            private _nearFriendlies = [];
            private _nearEnemies = [];
            {
                private _side = _x select 2 select 3;
                if (_side in _sidesFriendly) then {
                    _nearFriendlies pushback _x;
                } else {
                    if (_side in _sidesEnemy) then {
                        _nearEnemies pushback _x;
                    };
                };
            } foreach _nearEntities;

            // determine objective state from near entities

            if (_nearFriendlies isnotequalto []) then {
                if (_nearEnemies isequalto []) then {
                    _friendlyObjectives pushback [_id, _nearFriendlies, _nearEnemies];
                } else {
                    _contestedObjectives pushback [_id, _nearFriendlies, _nearEnemies];
                };
            } else {
                if (_nearEnemies isnotequalto []) then {
                    _enemyObjectives pushback [_id, _nearFriendlies, _nearEnemies];
                };
            };
        } foreach _objectives;

        private _clusterOccupation = [_friendlyObjectives, _enemyObjectives, _contestedObjectives, time];
        [_logic,"clusteroccupation", _clusterOccupation] call AliVE_fnc_HashSet;

        private _controltype = [_logic,"controltype", "invasion"] call ALiVE_fnc_HashGet;
        private _prios = switch (_controltype) do {
            case ("invasion") : {
                [
                    [_friendlyObjectives,"reserve"],
                    [_enemyObjectives,"attack"],
                    [_contestedObjectives,"defend"]
                ]
            };

            case ("occupation") : {
                [
                    [_friendlyObjectives,"reserve"],
                    [_enemyObjectives,"attack"],
                    [_contestedObjectives,"defend"]
                ]
            };
            case ("asymmetric") : {
                [
                    [_friendlyObjectives,"reserve"],
                    [_enemyObjectives,"attack"],
                    [_contestedObjectives,"defend"]
                ]
            };
        };

        {
            _x params ["_objectives","_operation"];
            [_logic,"setstatebyclusteroccupation", [_objectives,_operation]] call ALiVE_fnc_OPCOM;
        } foreach _prios;

        _result = _clusterOccupation;
    };

    ///////////////////////////////////////////////////
    // Scan position for nearby, visible enemy profiles.
    // Returns array of all found enemies
    ///////////////////////////////////////////////////

    case "scanForNearEnemies": {
        _args params ["_position",["_requireVisibility", true]];

        private _sidesEnemy = [_logic,"sidesenemy", ["EAST"]] call ALiVE_fnc_HashGet;

        _result = [_logic,"findProfilesNearPosition", [_position,_sidesEnemy,_requireVisibility]] call MAINCLASS;
    };

    ///////////////////////////////////////////////////
    // Scan all controlled profiles for nearby enemy profiles.
    // Wipes existing knownentities data.
    // Returns array of all found enemies
    ///////////////////////////////////////////////////

    case "scanFriendliesForNearEnemies": {

        private _factions = [_logic,"factions",[]] call ALiVE_fnc_HashGet;

        // private _duration = time; ["TACOM Trigger enemyscan for %1 at %2",_factions,_duration] call ALiVE_fnc_DumpR;

        private _controlledProfileIDs = [];
        {
            _controlledProfileIDs append ([ALiVE_ProfileHandler,"getProfilesByFaction",_x] call ALiVE_fnc_ProfileHandler);
        } foreach _factions;

        private _knownEntities = [];
        {
            private _profile = [ALiVE_ProfileHandler,"getProfile", _x] call ALiVE_fnc_ProfileHandler;

            if (!isnil "_profile") then {
                private _pos = [_profile,"position"] call ALiVE_fnc_HashGet;
                private _nearEnemies = [_logic,"scanForNearEnemies", [_pos,true]] call MAINCLASS;

                {
                    _knownEntities pushbackunique _x;
                } foreach _nearEnemies;
            };
        } foreach _controlledProfileIDs;

        _knownEntitiesIds = _knownEntities apply { _x select 0};

        [_logic,"createSpotrepForProfiles", _knownEntitiesIds] call MAINCLASS;

        [_logic,"knownentities", _knownEntities] call ALiVE_fnc_HashSet;

        // ["TACOM enemyscan for %1 finished in %2 seconds",_factions, time - _duration] call ALiVE_fnc_DumpR;

        _result = _knownEntities;

    };

    case "scantroops" : {

        private ["_inf","_mot","_mech","_arm","_air","_sea","_profileIDs","_artilleryClasses","_AAA","_AAAClasses"];

        _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;
        _duration = time;

        _profileIDs = [];
        {
            _profileIDs = _profileIDs + ([ALIVE_profileHandler, "getProfilesByFaction",_x] call ALIVE_fnc_profileHandler);
        } foreach _factions;

        _inf = [];
        _mot = [];
        _AAA = [];
        _arm = [];
        _air = [];
        _sea = [];
        _mech = [];
        _arty = [];

        if (isnil "_profileIDs" || {count _profileIDs == 0}) exitwith {_result = [_inf,_mot,_mech,_arm,_air,_sea,_arty,_AAA]};

        {
            private ["_profile","_assignments","_type","_objectType","_vehicleClass","_busy"];

            _profile = [ALIVE_profileHandler, "getProfile",_x] call ALIVE_fnc_profileHandler;

            if !(isnil "_profile") then {

                _type = [_profile,"type",""] call ALIVE_fnc_hashGet;
                _objectType = [_profile,"objectType",""] call ALIVE_fnc_hashGet;
                _vehicleClass = [_profile,"vehicleClass",""] call ALIVE_fnc_hashGet;

                switch (tolower _type) do {
                    case ("vehicle") : {
                        _assignments = [_profile,"entitiesInCommandOf",[]] call ALIVE_fnc_hashGet;

                        if ((count (_assignments)) > 0) then {

                            // Dont collect vehicles with player profiles assigned
                            if ({(_x getvariable ["profileID",""]) in _assignments} count allPlayers > 0) exitwith {};

                            // artillery and AA hold and fire regardless of
                            // chassis - wheeled launchers and SPGs (BM-21,
                            // DANA, CAESAR) carry objectType car/truck and
                            // must not be waypointed at the enemy as QRF
                            if ([_vehicleClass] call ALiVE_fnc_isArtillery || {[_vehicleClass] call ALiVE_fnc_isAA}) exitwith {
                                if ([_vehicleClass] call ALiVE_fnc_isArtillery) then {{if !(_x in _arty) then {_arty pushback _x}} foreach _assignments};
                                if ([_vehicleClass] call ALiVE_fnc_isAA) then {{if !(_x in _AAA) then {_AAA pushback _x}} foreach _assignments};
                            };

                            switch (tolower _objectType) do {
                                case "car": {
                                    {if !(_x in _mot) then {_mot pushback _x}} foreach _assignments;
                                };
                                case "tank": {
                                    {if !(_x in _arm) then {_arm pushback _x}} foreach _assignments;
                                };
                                case "armored": {
                                    {if !(_x in _mech) then {_mech pushback _x}} foreach _assignments;
                                };
                                case "truck": {
                                    {if !(_x in _mot) then {_mot pushback _x}} foreach _assignments;
                                };
                                case "ship": {
                                    {if !(_x in _sea) then {_sea pushback _x}} foreach _assignments;
                                };

                                /* // Since ATO is in place do not control air assets and pilots
                                case "helicopter": {
                                        {if !(_x in _air) then {_air pushback _x}} foreach _assignments;
                                };
                                case "plane": {
                                        {if !(_x in _air) then {_air pushback _x}} foreach _assignments;
                                };
                                */
                            };
                        };
                    };

                    case ("entity") : {
                        _assignments = ([_profile,"vehicleAssignments",["",[],[],nil]] call ALIVE_fnc_hashGet) select 1;
                        _unitClasses = [_profile,"unitClasses",[]] call ALIVE_fnc_hashGet;

                        if (
                            count _assignments == 0 && // entity is not assigned to a vehicle
                            {!([_profile,"isPlayer",false] call ALIVE_fnc_hashGet)} && // not a player
                            {{[toLower _x, "pilot"] call CBA_fnc_find != -1} count _unitClasses == 0} && // no pilots in entity
                            {!(!isNil "ALIVE_profileStationary" && {[ALIVE_profileStationary, _x, false] call ALIVE_fnc_hashGet})} // not a held roadblock / stationary garrison
                            ) then {
                            _inf pushback _x;
                        };
                    };
                };
            };
        } foreach _profileIDs;

        [_logic,"infantry",_inf] call ALiVE_fnc_HashSet;
        [_logic,"motorized",_mot] call ALiVE_fnc_HashSet;
        [_logic,"mechanized",_mech] call ALiVE_fnc_HashSet;
        [_logic,"armored",_arm] call ALiVE_fnc_HashSet;
        [_logic,"artillery",_arty] call ALiVE_fnc_HashSet;
        [_logic,"AAA",_AAA] call ALiVE_fnc_HashSet;
        [_logic,"air",_air] call ALiVE_fnc_HashSet;
        [_logic,"sea",_sea] call ALiVE_fnc_HashSet;

        _count = [
            count _inf,
            count _mot,
            count _mech,
            count _arm,
            count _air,
            count _sea,
            count _arty,
            count _AAA
        ];

        if (isnil {[_logic,"startForceStrength"] call ALiVE_fnc_HashGet}) then {
            [_logic,"startForceStrength",+_count] call ALiVE_fnc_HashSet
        };
        _currentForceStrength = [_logic,"currentForceStrength",_count] call ALiVE_fnc_HashSet;

        _duration = time - _duration;
        //["Scantroops time taken: %1 sec.",_duration] call ALiVE_fnc_DumpH;
        _result = [_inf,_mot,_mech,_arm,_air,_sea,_arty,_AAA];
    };

    ///////////////////////////////////////////////////
    // Sets the opcom_state of each passed objective to the passed state
    // Prevents new state from being set if it violates the normal flow of states
    ///////////////////////////////////////////////////

    case "setstatebyclusteroccupation": {
        _args params ["_objectives","_operation"];

        private _idleStates = switch (_operation) do {
            case "unassigned":  { ["internal","unassigned"] };
            case "attack" :     { ["internal","attack","attacking","defend","defending"] };
            case "defend" :     { ["internal","defend","defending","attack","attacking"] };
            case "reserve":     { ["internal","attack","attacking","defend","defending","reserve","reserving","idle"] };
            default             { ["internal","reserve","reserving","idle"] };
        };

        {
            private _objectiveID = _x select 0;

            private _target = [_logic,"getObjectiveByID", _objectiveID] call ALiVE_fnc_OPCOM;
            if (!isnil "_target" && {!([_target,"deleted", false] call ALiVE_fnc_hashGet)}) then {
                private _opcomState = [_target,"opcom_state"] call ALiVE_fnc_HashGet;
                if !(_opcomState in _idleStates) then {
                    [_target,"opcom_state", _operation] call ALiVE_fnc_HashSet;
                };
            };
        } foreach _objectives;
    };

    ///////////////////////////////////////////////////
    // Finds the highest priority objective with the passed state
    // and determines its next orders
    ///////////////////////////////////////////////////

    case "selectordersbystate": {
        private _state = _args;

        private _module = [_logic,"module"] call ALiVE_fnc_HashGet;
        private _objectives = [_logic, "objectives", []] call AliVE_fnc_HashGet;
        private _OPCOM_FSM = [_logic,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet;
        private _OPCOM_SKIP_OBJECTIVES = _OPCOM_FSM getFSMvariable ["_OPCOM_SKIP_OBJECTIVES", []];

        private _allSyncedTriggersActivated = {((typeof _x) == "EmptyDetector") && {!(triggerActivated _x)}} count (synchronizedObjects _module) == 0;

        private _targetObjectiveIndex = _objectives findIf {
            private _objectiveID = [_x, "objectiveID"] call AliVE_fnc_HashGet;
            private _objectiveState = [_x, "opcom_state"] call AliVE_fnc_HashGet;

            !(_objectiveID in _OPCOM_SKIP_OBJECTIVES) &&
            _objectiveState == _state &&
            { _allSyncedTriggersActivated || { !(_objectiveState in ["attack","unassigned"]) } }
        };

        if (_targetObjectiveIndex != -1) then {
            private _targetObjective = _objectives select _targetObjectiveIndex;

            private _nextOrders = switch (_state) do {
                case "attack": { "attack" };
                case "unassigned": { "attack" };
                case "defend": { "defend" };
                case "reserve": { "reserve" };
            };

            [_targetObjective,"opcom_orders", _nextOrders] call AliVE_fnc_HashSet;
            _result = ["execute", _targetObjective];
        };
    };

    case "sectionsamount_attack": {
        if !(_args isequaltype 0) then {
            _result = [_logic, "sectionsamount_attack"] call ALiVE_fnc_HashGet;
        } else {
            [_logic,"sectionsamount_attack", _args] call ALiVE_fnc_HashSet;

            private _tacom = [_logic,"TACOM_FSM"] call ALiVE_fnc_HashGet;
            _tacom setFSMVariable ["_sectionsamount_attack", _args];
        };
    };

    case "sectionsamount_reserve": {
        if !(_args isequaltype 0) then {
            _result = [_logic,"sectionsamount_reserve"] call ALiVE_fnc_HashGet;
        } else {
            [_logic,"sectionsamount_reserve", _args] call ALiVE_fnc_HashSet;

            private _tacom = [_logic,"TACOM_FSM"] call ALiVE_fnc_HashGet;
            _tacom setFSMVariable ["_sectionsamount_reserve", _args];
        };
    };

    case "sectionsamount_defend": {
        if !(_args isequaltype 0) then {
            _result = [_logic,"sectionsamount_defend"] call ALiVE_fnc_HashGet;
        } else {
            [_logic,"sectionsamount_defend", _args] call ALiVE_fnc_HashSet;

            private _tacom = [_logic, "TACOM_FSM"] call ALiVE_fnc_HashGet;
            _tacom setFSMVariable ["_sectionsamount_defend", _args];
        };
    };


    case "destroy": {
        if (_logic isequaltype objnull) then {
            _logic = _logic getVariable "handler";
        };

        private _OPCOM_FSM = [_logic,"OPCOM_FSM", -1] call ALiVE_fnc_HashGet;
        private _TACOM_FSM = [_logic,"TACOM_FSM", -1] call ALiVE_fnc_HashGet;
        private _module = [_logic,"module", objNull] call ALiVE_fnc_HashGet;

        _TACOM_FSM setFSMvariable ["_exitFSM", true];
        _OPCOM_FSM setFSMvariable ["_exitFSM", true];

        OPCOM_instances = OPCOM_instances - [_logic];

        _module setVariable ["super", nil];
        _module setVariable ["class", nil];

        private _group = group _module;

        deleteVehicle _module;
        deletegroup _group;

        _logic = nil;
    };

    case "debug": {
        if !(_args isequaltype true) then {
            _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
            [_logic,"debug", _args] call ALIVE_fnc_hashSet;
        };

        _result = _args;
    };

    case "OPCOM_monitor": {
        ASSERT_TRUE(_args isequaltype true, str _args);

        private _enableMonitor = _args;

        private _hdl = [_logic,"monitor", false] call AliVE_fnc_HashGet;
        private _debug = [_logic,"debug", false] call ALiVE_fnc_HashGet;

        if (!(_enableMonitor) && {!(_hdl isequaltype true)}) then {
            terminate _hdl;
            [_logic,"monitor", nil] call AliVE_fnc_HashSet;

            if (_debug) then {
                ["OPCOM and TACOM monitoring ended..."] call ALIVE_fnc_dumpR;
            };
        } else {
            _hdl = _logic spawn {
                private _debug = [_this,"debug", false] call ALiVE_fnc_HashGet;
                if (_debug) then {
                    ["OPCOM and TACOM monitoring started..."] call ALIVE_fnc_dumpR;
                };

                private _FSM_OPCOM = [_this,"OPCOM_FSM"] call AliVE_fnc_HashGet;
                private _FSM_TACOM = [_this,"TACOM_FSM"] call AliVE_fnc_HashGet;

                private _OPCOM_OBJECTIVES = [_this,"objectives",[]] call AliVE_fnc_HashGet;

                if (isnil QGVAR(MONITOR_FULL)) then {GVAR(MONITOR_FULL) = false};

                while {true} do {
                    private _state = _FSM_OPCOM getfsmvariable "_OPCOM_status";
                    private _OPCOM_busy = _FSM_OPCOM getfsmvariable "_busy";
                    private _side = _FSM_OPCOM getfsmvariable "_side";
                    private _cycleTime = _FSM_OPCOM getfsmvariable "_cycleTime";
                    private _timestamp = floor(time - (_FSM_OPCOM getfsmvariable "_timestamp"));
                    private _OPC_DATA = _FSM_OPCOM getfsmvariable ["_OPCOM_DATA","nil"];
                    private _OPC_QUEUE = _FSM_OPCOM getfsmvariable ["_OPCOM_QUEUE",[]];
                    private _state_TACOM = _FSM_TACOM getfsmvariable "_TACOM_status";
                    private _TACOM_busy = _FSM_TACOM getfsmvariable "_busy";

                    //Exit if FSM has ended
                    if (isnil "_cycleTime") exitwith {["Exiting OPCOM Monitor"] call ALiVE_fnc_Dump};

                    private _maxLimit = _cycleTime + ((count allunits) * 2);

                    if (GVAR(MONITOR_FULL)) then {

                        private _currentForceStrength = [_this,"currentForceStrength", []] call ALiVE_fnc_HashGet;

                        private _states = [] call ALiVE_fnc_HashCreate;

                        {
                            private _objective = _x;
                            private _state = [_objective,"opcom_state", "none"] call ALiVE_fnc_Hashget;

                            [_states,_state, ([_states, _state, 0] call ALiVE_fnc_HashGet) + 1] call ALiVE_fnc_HashSet;
                        } foreach _OPCOM_OBJECTIVES;

                        hintsilent (parsetext format[
                            "OPC state: %1 (%2s %3)<br/>TAC state: %4 (%5)<br/>OPC data: %6<br/>OPC processes queued: %7<br/><br/>OPC states: %8<br/>OPC statecount: %9<br/>OPC forces: %10",
                            _state,_timestamp,_OPCOM_busy,_state_TACOM,_TACOM_busy,_OPC_DATA,count _OPC_QUEUE,_states select 1,_states select 2,_currentForceStrength,_maxLimit
                        ]);
                    };

                    if (_timestamp > _maxLimit) then {
                        if (_debug) then {
                            private _message = parsetext (format[
                                "<t align=left>OPCOM side: %1<br/><br/>WARNING! Max. duration exceeded!<br/>state OPCOM: %2<br/>state TACOM: %4<br/>duration: %3</t>",
                                _side,
                                _state,
                                _timestamp,
                                _state_TACOM
                            ]);
                            [_message] call ALIVE_fnc_dump;
                            hintsilent _message;

                            if (_timestamp > 900) then {
                                _FSM_OPCOM setfsmvariable ["_OPCOM_DATA",nil];
                                _FSM_OPCOM setfsmvariable ["_busy",false];
                            };
                        };
                    };

                    sleep 1;
                };
            };

            [_logic,"monitor", _hdl] call AliVE_fnc_HashSet;
        };

        _result = _hdl;
    };

    case "changeControlType": {
        // Execute on Server only — OPCOM state (FSM handles, objectives,
        // controltype) lives in a server-local hash, so a client-side call
        // would tear down nothing and misreport "startup not complete".
        if !(isServer) exitwith {[_logic,_operation,_args] remoteExec ["ALiVE_fnc_OPCOM",2]};

        _args params ["_newControlType"];

        _result = false;

        if !(_newControlType in ["invasion","occupation","asymmetric"]) exitwith {
            ["ALiVE_fnc_OPCOM | Operation '%1' | Invalid value for _newControlType %2, must be one of %3", _operation, _newControlType, ["invasion","occupation","asymmetric"]] call ALiVE_fnc_Dump;
        };

        if !([_logic,"startupComplete", false] call ALiVE_fnc_hashGet) exitwith {
            ["ALiVE_fnc_OPCOM | Operation '%1' | Cannot change control type, OPCOM has not finished startup", _operation] call ALiVE_fnc_Dump;
        };

        private _existingControlType = [_logic,"controltype"] call ALiVE_fnc_hashGet;
        if (_newControlType == _existingControlType) exitwith {};

        private _conventionalTypes = ["invasion","occupation"];

        private _opcomFSM = [_logic,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet;
        private _tacomFSM = [_logic,"TACOM_FSM",-1] call ALiVE_fnc_HashGet;

        // Terminate active controllers before replacing their objective set.
        // Asymmetric OPCOMs do not have a TACOM FSM, hence the -1 sentinel.
        if (_tacomFSM != -1) then {
            _tacomFSM setFSMvariable ["_exitFSM", true];
            _tacomFSM setFSMvariable ["_busy", false];
            waitUntil {
                sleep 1;
                isNil {[_logic, "TACOM_FSM"] call ALiVE_fnc_HashGet}
            };
        };
        if (_opcomFSM != -1) then {
            _opcomFSM setFSMvariable ["_exitFSM", true];
            _opcomFSM setFSMvariable ["_busy", false];
            waitUntil {
                sleep 1;
                isNil {[_logic, "OPCOM_FSM"] call ALiVE_fnc_HashGet}
            };
        };

        // remove objectives

        private _objectives = +([_logic,"objectives"] call ALiVE_fnc_HashGet);
        {
            [_logic,"removeObjective", [_x,"objectiveID"] call ALiVE_fnc_hashGet] call MAINCLASS;
        } foreach _objectives;

        private _sortType = switch (_newControlType) do {
            case "occupation": {"strategic"};
            case "invasion": {"distance"};
            default {"asymmetric"};
        };
        _objectives = [_logic,"objectives",
            [_logic,"createObjectives", [_objectives,_sortType]] call MAINCLASS
        ] call MAINCLASS;
        [_logic,"pendingorders", []] call ALiVE_fnc_hashSet;

        [_logic,"controltype", _newControlType] call ALiVE_fnc_hashSet;

        // reboot FSMs

        if (_newControlType in _conventionalTypes) then {
            private _newOPCOMFSM = [_logic] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
            private _newTACOMFSM = [_logic] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";
            [_logic,"OPCOM_FSM", _newOPCOMFSM] call ALiVE_fnc_HashSet;
            [_logic,"TACOM_FSM", _newTACOMFSM] call ALiVE_fnc_HashSet;
        } else {
            // load ins helpers if not already loaded
            if (isnil "ALiVE_fnc_INS_getOpcomByObjective") then {
                call ALiVE_fnc_INS_helpers;
            };

            private _newOPCOMFSM = [_logic] execFSM "\x\alive\addons\mil_opcom\insurgency.fsm";
            [_logic,"OPCOM_FSM", _newOPCOMFSM] call ALiVE_fnc_HashSet;
            [_logic,"TACOM_FSM", -1] call ALiVE_fnc_HashSet;
        };

        _result = true;
    };

    case "state": {
        if (_args isequaltype []) then {
            // Restore state

            private _newState = _args;
            if !([_newState] call ALiVE_fnc_isHash) exitwith {
                ["ALiVE_fnc_OPCOM operation %1 - Passed state is not a hash", _operation] call ALiVE_fnc_Dump;
            };

            private _newStateKeys = _newState select 1;
            private _newStateValues = _newState select 2;

            {
                private _newValue = _newStateValues select _foreachindex;

                [_logic, _x, _newValue] call ALiVE_fnc_hashSet;
            } foreach _newStateKeys;
        } else {
            // extract state

            private _keys = (_logic select 1) - ["super","class"];
            private _values = _logic select 2;
            
            private _keyValuePairs = _keys apply {
                [_x, _values select _foreachindex]
            };

            private _state = [_keyValuePairs] call ALIVE_fnc_hashCreate;

            _result = _state;
        };
    };

    case "validateStartupState": {
        _args params ["_opcomModule"];

        _result = false;

        private _debug = [_logic,"debug"] call ALiVE_fnc_HashGet;
        private _customName = [_logic,"name"] call ALiVE_fnc_HashGet;
        private _side = [_logic,"side"] call ALiVE_fnc_HashGet;
        private _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;
        private _objectives = [_logic,"objectives"] call ALiVE_fnc_HashGet;

        private _objectiveCount = count _objectives;

        // exit if there are no objectives
        if (_objectiveCount == 0) exitwith {
            [
                "There are 0 objectives for OPCOM instance with factions %1! Please assign Military or Civilian Placement Objectives!",
                _factions
            ] call ALIVE_fnc_dumpR;
        };

        // warning for excessive objective count
        if (_objectiveCount > 80) then {
            [
                "There are %1 objectives for OPCOM instance with factions %2! This may result in decreased performance, suggested objective count is below 80!",
                _objectiveCount,
                _factions
            ] call ALIVE_fnc_dump;
        };

        //Check if there are any profiles available.
        //
        //Enumerate factions offered by synced placement modules
        //so an OPCOM Factions vs placement-module faction mismatch
        //surfaces clearly in the RPT. Fires unconditionally (not
        //debug-gated) because this is the commonest OPCOM-init
        //misconfiguration: mission-maker picks faction X in OPCOM
        //but the synced Mil Placement was left on its OPF_F
        //default, so there are zero profiles for X and OPCOM
        //silently refuses to run.
        private _parsePlacementFactions = {
            params ["_value"];
            private _parsed = [];
            if (_value isEqualType []) exitWith {
                {
                    if (_x isEqualType "" && {_x != ""} && {_x != "NONE"} && {!(_x in _parsed)}) then {
                        _parsed pushBack _x;
                    };
                } forEach _value;
                _parsed
            };
            if !(_value isEqualType "") exitWith { [] };
            if (_value == "") exitWith { [] };
            private _s = _value;
            _s = [_s, " ", ""] call CBA_fnc_replace;
            _s = [_s, "[", ""] call CBA_fnc_replace;
            _s = [_s, "]", ""] call CBA_fnc_replace;
            _s = [_s, """", ""] call CBA_fnc_replace;
            {
                if (_x != "" && {_x != "NONE"} && {!(_x in _parsed)}) then {
                    _parsed pushBack _x;
                };
            } forEach ([_s, ","] call CBA_fnc_split);
            _parsed
        };

        private _availableFactions = [];
        private _customPlacementClasses = ["ALiVE_civ_placement_custom","ALiVE_mil_placement_custom"];
        {
            // mil_placement_spe omitted - see rationale at the placement-class
            // iteration above.
            private _placementType = typeOf _x;
            if (_placementType in ["ALiVE_mil_placement","ALiVE_civ_placement","ALiVE_civ_placement_custom","ALiVE_mil_placement_custom"]) then {
                private _placementFactions = [_x getVariable ["factions", ""]] call _parsePlacementFactions;
                private _legacyPlacementFactions = [];
                if (count _placementFactions == 0) then {
                    _legacyPlacementFactions = [_x getVariable ["faction", ""]] call _parsePlacementFactions;
                    private _legacyIsDefault = (count _legacyPlacementFactions == 1) && {(_legacyPlacementFactions select 0) == "BLU_F"};
                    private _legacyBlocksInheritance = (_placementType in _customPlacementClasses) && {_legacyIsDefault};
                    if (!_legacyBlocksInheritance) then {
                        _placementFactions = +_legacyPlacementFactions;
                    };
                };
                if ((count _placementFactions == 0) && {_placementType in _customPlacementClasses}) then {
                    _placementFactions = +_factions;
                };
                if ((count _placementFactions == 0) && {count _legacyPlacementFactions > 0}) then {
                    _placementFactions = +_legacyPlacementFactions;
                };
                {
                    if (!(_x in _availableFactions)) then {
                        _availableFactions pushBack _x;
                    };
                } forEach _placementFactions;
            };
        } forEach (synchronizedObjects _opcomModule);

        private _unmatchedFactions = _factions select {!(_x in _availableFactions)};
        if (count _unmatchedFactions > 0) then {
            [
                "ALiVE OPCOM init MISMATCH: AI Commander '%1' has Factions [%2] but synced placement modules only provide factions [%3]. Unmatched: [%4]. Fix: change the OPCOM Factions multi-select to match a placement module, sync a placement with the missing faction, or leave a custom objective's Force Factions empty so it inherits this Commander.",
                _customName,
                _factions joinString ", ",
                _availableFactions joinString ", ",
                _unmatchedFactions joinString ", "
            ] call ALiVE_fnc_Dump;
        };

        // Verify that OPCOM has at least one group
        // Warn for factions with no groups

        private _playerProfiles = ([ALiVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler) select 1;

        private _opcomProfileCount = 0;
        private _factionsWithNoGroups = [];
        {
            private _factionProfiles = [ALIVE_profileHandler,"getProfilesByFaction", _x] call ALIVE_fnc_profileHandler;
            _factionProfiles = _factionProfiles - _playerProfiles;

            _opcomProfileCount = _opcomProfileCount + (count _factionProfiles);

            if (_factionProfiles isequalto []) then {
                _factionsWithNoGroups pushback _x;
            };
        } foreach _factions;

        if (_factionsWithNoGroups isnotequalto []) then {
            [
                "There are no groups for OPCOM faction(s) %1! %2",
                _factionsWithNoGroups,
                "Please ensure you have configured a Mil Placement or Mil Placement (Civ Obj) module for this faction (or faction units are synced to Virtual AI module). If so, please check groups are correctly configured for this faction."
            ] call ALIVE_fnc_dumpR;
        };

        if (_opcomProfileCount == 0) exitwith {
            ["Aborting OPCOM Init... There are no groups for OPCOM with factions %1", _factions] call ALIVE_fnc_dumpR;
        };

        // validate no other opcom is configured with any of our factions
        
        private _otherOPCOMS = OPCOM_instances - [_logic];

        private _factionsWithOtherOPCOMS = [];
        private _offendingOPCOMFactions = [];
        {
            _otherOPCOM = _x;

            // wait until init has passed on that instance
            waituntil { !(isnil {[_otherOPCOM, "factions"] call ALiVE_fnc_HashGet}) };

            private _otherOPCOMFactions = [_otherOPCOM,"factions"] call ALiVE_fnc_HashGet;

            private _factionsInCommon = _factions arrayintersect _otherOPCOMFactions;

            if (_factionsInCommon isnotequalto []) then {
                _offendingOPCOMFactions = _otherOPCOMFactions;

                { _factionsWithOtherOPCOMS pushbackunique _x } foreach _factionsInCommon;
            };
        } foreach _otherOPCOMS;

        if (_factionsWithOtherOPCOMS isnotequalto []) exitwith {
            [
                "Aborting OPCOM Init... Factions %1 are already used by another OPCOM that has factions %2! Please change the faction!",
                _factionsWithOtherOPCOMS,
                _offendingOPCOMFactions
            ] call ALIVE_fnc_dumpR;
        };

        // Still there? Awesome, verify that all factions are on the same side

        private _factionSides = _factions apply {
            [_x call ALiVE_fnc_factionSide] call ALiVE_fnc_sideToSideText
        };

        private _testSide = _factionSides select 0;
        private _differingSideIndex = _factionSides findIf { _x != _testSide };
        if (_differingSideIndex != -1) exitwith {
            ["There are factions from different sides within this OPCOM %1! Please only select one side per OPCOM!", _factions] call ALIVE_fnc_dumpR;
        };

        if (_debug) then {
            ["OPCOM %1 starts with %2 profiles and %3 objectives!", _side, _opcomProfileCount, _objectiveCount] call ALIVE_fnc_dumpR;
        };

        _result = true;
    };

    // keep operation for backwards compat
    case "convert": { _result = [_args] call ALiVE_fnc_parseArrayFromString };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("OPCOM - output", _result);

if !(isnil "_result") then {_result} else {nil};
