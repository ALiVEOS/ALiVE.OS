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
setSectionOrders
confirmOrder
releaseOrder
setObjectiveSection
rebuildObjectiveIndexes
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

PROFILE_SCOPE(OPERATION, _operation)

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
        // War on Drugs (#1080): this commander's IED factories are drug labs
        private _drugLabs = (toLower format ["%1", _logic getvariable ["drugLabs", "false"]]) in ["true", "1"];
        private _type = _logic getvariable ["controltype","invasion"];
        private _occupation = (parseNumber format ["%1", _logic getvariable ["asym_occupation",-100]])/100;
        private _intelChance = (parseNumber format ["%1", _logic getvariable ["intelchance",-100]])/100;
        // High value target (#625): how long, in seconds, new attacks pause once he's killed; 0 is off,
        // -1 stops them for the rest of the mission, -2 takes the module's Pause After Kill (minutes)
        private _hvt = parseNumber format ["%1", _logic getvariable ["hvt", 0]];
        if (_hvt == -2) then { _hvt = (((parseNumber format ["%1", _logic getVariable ["hvtPauseMins", 15]]) max 0) * 60) max 1 };
        // Occupation pause (The Horny Latino on Discord, 19 Oct): minutes an Occupation commander holds new attacks after
        // each capture while players clear up and meet the locals; 0 (the default) is off
        private _occPauseMins = (parseNumber format ["%1", _logic getVariable ["occPauseMins", 0]]) max 0;
        // Preparation tasks (The Horny Latino on Discord, 19 Oct): an Invasion commander's attacks wait for a player
        // wiretap task at the objective, or for Preparation Timeout minutes; off by default
        private _prepTasks = (toLower format ["%1", _logic getVariable ["prepTasks", "false"]]) in ["true", "1"];
        private _prepTimeout = ((parseNumber format ["%1", _logic getVariable ["prepTimeoutMins", 15]]) max 1) * 60;
        // Choice After Recon (Will501 on Discord, 22 Oct): after a recon, players take the targets or hand them over
        private _prepChoice = (toLower format ["%1", _logic getVariable ["prepChoice", "false"]]) in ["true", "1"];
        // Preparation Tasks How Often (Eric and Will501 on Discord, 23 Oct): the share of attacks that get them
        private _prepOften = switch (toLower format ["%1", _logic getVariable ["prepOften", "all"]]) do { case "many": { 2/3 }; case "few": { 1/3 }; default { 1 } };
        // how many tasks an operation hands out (The Horny Latino on Discord, 20 Oct): Invasion preparation tasks per
        // objective, and Occupation clean-up tasks per capture. 0 and 0 (the default) keep one wiretap for Invasion and
        // every clean-up kind for Occupation
        private _opTasksMin = (parseNumber format ["%1", _logic getVariable ["opTasksMin", 0]]) max 0;
        private _opTasksMax = (parseNumber format ["%1", _logic getVariable ["opTasksMax", 0]]) max 0;
        // Tasks Only Against Known Enemy (A. Ares on Discord, 21 Oct): those tasks aim only at what this commander has
        // found, so they don't give hidden positions away; off by default
        private _opTasksKnownOnly = (toLower format ["%1", _logic getVariable ["opTasksKnownOnly", "false"]]) in ["true", "1"];
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
        // Harassing Fire (Eric on Discord, 22 Oct): an Asymmetric commander's mortar attacks, and the shortest wait between them
        private _harassFire = (toLower format ["%1", _logic getVariable ["asymHarassFire", "false"]]) in ["true", "1"];
        private _harassCycle = (parseNumber format ["%1", _logic getVariable ["asymHarassCycle", 20]]) max 1;
        private _recruitCycleMax = (parseNumber format ["%1", _logic getvariable ["recruitCycleMax",60]]) max _recruitCycleMin;

        private _recruitAttemptLimit = floor (parseNumber format ["%1", _logic getvariable ["recruitAttemptLimit",0]]);
        _recruitAttemptLimit = _recruitAttemptLimit max -1;

        private _recruitSuccessChance = ((parseNumber format ["%1", _logic getvariable ["recruitSuccessChance",50]]) max 0) min 100;
        // Chance a new Recruitment HQ raises a task to kill its recruiter (#426).
        private _recruiterTaskChance = ((parseNumber format ["%1", _logic getvariable ["recruiterTaskChance",0]]) max 0) min 100;
        // Recruiters: a recruiter in each Recruitment HQ, and killing him stops that town recruiting for a while.
        private _recruiters = (toLower format ["%1", _logic getvariable ["recruiters", "false"]]) in ["true", "1"];
        // ... his class (empty: an officer, as the HVT), his guards and how many recruitments a kill costs (#1088)
        private _recruiterClass = format ["%1", _logic getvariable ["recruiterClass", ""]];
        private _recruiterGuards = ((parseNumber format ["%1", _logic getvariable ["recruiterGuards", 2]]) max 0) min 8;
        private _recruiterSkips = ((parseNumber format ["%1", _logic getvariable ["recruiterSkips", 1]]) max 1) min 10;
        private _recruiterWalks = (toLower format ["%1", _logic getvariable ["recruiterWalks", "false"]]) in ["true", "1"];
        private _recruiterBoost = ((parseNumber format ["%1", _logic getvariable ["recruiterBoost", 1]]) max 1) min 2;
        // Frontline Minefields (#979): none, few or many.
        private _frontlineMinefields = toLower format ["%1", _logic getvariable ["frontlineMinefields","none"]];
        // Prepared Defences (#233): none, few or many.
        private _preparedDefences = toLower format ["%1", _logic getvariable ["preparedDefences","none"]];
        // Security Patrols (#1087): the share of reserve groups that patrol between rear objectives.
        private _securityPatrols = switch (toLower format ["%1", _logic getvariable ["securityPatrols","none"]]) do {
            case "few": { 0.25 }; case "some": { 0.5 }; case "many": { 0.75 }; default { 0 };
        };
        // Security Patrols mode (#1092): Objectives walks the rear objectives, Coverage walks the coldest ground; and the reach of a patrol from home in either
        private _securityPatrolMode = if ((toLower format ["%1", _logic getvariable ["securityPatrolMode","objectives"]]) == "coverage") then { "coverage" } else { "objectives" };
        private _securityPatrolReach = ((parseNumber format ["%1", _logic getvariable ["securityPatrolReach", 3000]]) max 500) min 10000;
        // read first on the profile simulator's busiest path, so a mission without Coverage pays nothing for it
        if (_securityPatrolMode == "coverage" && {_securityPatrols > 0}) then { ALiVE_coverageActive = true };
        // Attacks Arrive Together (#207): on each leg of an attack the faster groups wait before setting off.
        private _arriveTogether = (toLower format ["%1", _logic getvariable ["arriveTogether","false"]]) == "true";
        // Preparation Fire (#207): the commander's guns fire on an objective's defenders before it is assaulted.
        private _prepFire = (toLower format ["%1", _logic getvariable ["prepFire","false"]]) == "true";
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
        // The editor stores this as text, but a module made by script can hold a number, and
        // call compile on a number throws.
        private _reinforcements = _logic getvariable ["reinforcements","0.9"];
        if !(_reinforcements isEqualType 0) then {_reinforcements = call compile _reinforcements};
        // a percentage typed beside the dropdown wins when filled in (19 Oct 2026); 1 or less is read as a fraction
        private _reinforcementsTyped = format ["%1", _logic getVariable ["reinforcementsTyped", ""]];
        if (_reinforcementsTyped != "") then { _reinforcements = parseNumber _reinforcementsTyped; if (_reinforcements > 1) then { _reinforcements = _reinforcements / 100 } };
        private _roadblocks = (parseNumber format ["%1", _logic getvariable ["roadblocks",1]]) > 0;
        // Installation Types (#1081): what an Asymmetric commander may set up, as lower-case keys
        private _insTypes = (toLower format ["%1", _logic getvariable ["asymInstallations", "factory,depot,recruit,ied,suicide,sabotage,ambush,roadblocks"]]) splitString ", ";
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
        private _usedDefaultFaction = _factions isEqualTo [];
        if (_usedDefaultFaction) then {
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

        // the civilians' answers and C2ISTAR's tasks name drug labs once any commander has them
        if (_drugLabs) then { missionNamespace setVariable ["ALiVE_INS_drugLabsAny", true, true] };

        // A name the mission maker gave this commander is what its side's HQ radio messages open with
        // (ALIVE_fnc_radioBroadcast), on every machine. The first named commander of a side keeps it.
        if (!isNil "_customNameParam" && {_customNameParam isEqualType ""} && {_customNameParam != ""}) then {
            private _callsigns = missionNamespace getVariable ["ALiVE_commanderCallsigns", createHashMap];
            if !(_side in _callsigns) then {
                _callsigns set [_side, _customNameParam];
                missionNamespace setVariable ["ALiVE_commanderCallsigns", _callsigns, true];
            };
        };

        if (_usedDefaultFaction) then {
            [
                "ALiVE OPCOM init WARNING: AI Commander '%1' has no factions configured (Factions multi-select empty AND Additional Factions empty). Defaulting to ['BLU_F']. Pick at least one faction in the Factions multi-select to silence this.",
                _customName
            ] call ALiVE_fnc_Dump;
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
            ["harassFire", _harassFire],
            ["harassCycle", _harassCycle],
            // the first not before one interval has gone by
            ["harassNextAt", time + 60 * _harassCycle],
            ["recruitCycleMax", _recruitCycleMax],
            ["recruitAttemptLimit", _recruitAttemptLimit],
            ["recruitSuccessChance", _recruitSuccessChance],
            ["recruiterTaskChance", _recruiterTaskChance],
            ["recruiters", _recruiters],
            ["recruiterClass", _recruiterClass],
            ["recruiterGuards", _recruiterGuards],
            ["recruiterSkips", _recruiterSkips],
            ["recruiterWalks", _recruiterWalks],
            ["recruiterBoost", _recruiterBoost],
            ["frontlineMinefields", _frontlineMinefields],
            ["preparedDefences", _preparedDefences],
            ["securityPatrols", _securityPatrols],
            ["securityPatrolMode", _securityPatrolMode],
            ["securityPatrolReach", _securityPatrolReach],
            ["arriveTogether", _arriveTogether],
            ["prepFire", _prepFire],
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
            ["hvt", _hvt],
            ["occPauseMins", _occPauseMins],
            // Invasion and Occupation both (A. Ares on Discord, 22 Oct); the type is checked when an attack is picked,
            // so a commander switched from one to the other part way through keeps it
            ["prepTasks", _prepTasks],
            ["prepChoice", _prepChoice],
            ["prepOften", _prepOften],
            ["prepTimeout", _prepTimeout],
            ["opTasksMin", _opTasksMin],
            ["opTasksMax", _opTasksMax],
            ["opTasksKnownOnly", _opTasksKnownOnly],
            ["roadblocks", _roadblocks],
            ["insTypes", _insTypes],
            ["drugLabs", _drugLabs],
            ["friendlyDisableMode", _friendlyDisableMode],
            ["asymEscalationIntensity", _asymEscalationIntensity],
            ["asymExcludeKinds", _asymExcludeKinds],
            ["name", _customName],
            ["objectives", []],
            ["objectivesByID", createHashMap],
            ["profileObjectiveAssignment", createHashMap],
            ["pendingorders", []]
        ]] call ALIVE_fnc_hashCreate;

        _logic setVariable ["handler", _handler];

        //Add to OPCOM_instances global array for easier access

        if (isnil "OPCOM_instances") then {
            OPCOM_instances = [];
        };
        OPCOM_instances pushback _handler;
        // what each commander fights, published for players' tablets: on a dedicated server OPCOM_instances is the
        // server's alone, so C2ISTAR's enemy faction filter found nothing there and listed every faction (NeisAEL on
        // Discord, 23 Oct)
        ALiVE_OPCOM_factionsPublic = (OPCOM_instances select { _x isEqualType [] }) apply { [[_x, "sidesenemy", []] call ALiVE_fnc_HashGet, [_x, "factions", []] call ALiVE_fnc_HashGet] };
        publicVariable "ALiVE_OPCOM_factionsPublic";

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

        // An insurgent commander marks the civilians its groups have been among, every minute
        if (_type == "asymmetric") then {
            [_handler] spawn {
                params ["_handler"];
                while {true} do {
                    sleep 60;
                    private _module = [_handler, "module", objNull] call ALiVE_fnc_HashGet;
                    if (isNull _module) exitWith {};
                    if (!isNil "ALiVE_fnc_INS_contactSweep") then { [_handler] call ALiVE_fnc_INS_contactSweep };
                };
            };
        };

        // Security Patrols (#1087): every 2 minutes, once the commander has had 10 to settle its reserves
        if (_securityPatrols > 0) then {
            [_handler] spawn {
                params ["_handler"];
                sleep 600;
                while {true} do {
                    private _module = [_handler, "module", objNull] call ALiVE_fnc_HashGet;
                    if (isNull _module) exitWith {};
                    if !([_handler, "pause", false] call ALiVE_fnc_HashGet) then {
                        [_handler] call ALIVE_fnc_OPCOMsecurityPatrols;
                    };
                    sleep 120;
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
        private _syncedCQBModules = (synchronizedObjects _logic) select {typeof _x == "ALiVE_mil_cqb"};
        {
            waituntil { _x getVariable ["startupComplete", false] };
        } foreach _syncedCQBModules;

        [_handler,"CQB", _syncedCQBModules] call ALiVE_fnc_HashSet;

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

        // The starting forces are saved under a name built from this commander's
        // position, which only it knows. Passing it makes it known to Clear Current
        // Mission's Data, and moves a save from before saves were kept per map to
        // this map's name before the load below reads it.
        [format ["-OPCOM_%1-starting-forces", [_handler,"opcomID"] call CBA_fnc_hashGet]] call ALiVE_fnc_storeMigrate;
        // the high value target and the operation in hand are saved the same way, so Clear Current Mission's Data
        // has to know their names too, or a cleared mission loads a dead target and a leftover pause. Both came after
        // saves were kept per map, so there is nothing old to move: listing the names is enough, without two more
        // passes over the store.
        if (isNil "ALiVE_storeSuffixes") then { ALiVE_storeSuffixes = [] };
        ALiVE_storeSuffixes pushBackUnique format ["-OPCOM_%1-hvt", [_handler,"opcomID"] call CBA_fnc_hashGet];
        ALiVE_storeSuffixes pushBackUnique format ["-OPCOM_%1-opstate", [_handler,"opcomID"] call CBA_fnc_hashGet];

        //Load Data from DB
        if (_persistent && { !isNil "ALIVE_sys_data" } && {!ALIVE_sys_data_DISABLED}) then {
            _objectives = [_handler,"loadObjectivesDB"] call MAINCLASS;

            ["OPCOM loaded %1 objectives from DB!", count _objectives] call ALiVE_fnc_dump;
        
            // Load starting forces
            private _key = format ["%1-OPCOM_%2-starting-forces", ([""] call ALiVE_fnc_storeKeys) select 0, [_handler,"opcomID"] call CBA_fnc_hashGet];
            private _result = [GVAR(DATAHANDLER),"read", ["mil_opcom", [], _key]] call ALIVE_fnc_Data;

            if (_result isEqualType []) then {
                private _startingForces = [_result,"data"] call CBA_fnc_hashGet;
                [_handler,"startForceStrength", _startingForces] call CBA_fnc_hashSet;
            };

            // The high value target, so a saved mission doesn't place a second one
            _key = format ["%1-OPCOM_%2-hvt", ([""] call ALiVE_fnc_storeKeys) select 0, [_handler,"opcomID"] call CBA_fnc_hashGet];
            _result = [GVAR(DATAHANDLER),"read", ["mil_opcom", [], _key]] call ALIVE_fnc_Data;
            if (_result isEqualType [] && {!isNil {[_result,"data"] call CBA_fnc_hashGet}}) then {
                [_handler,"hvtRecord", [_result,"data"] call CBA_fnc_hashGet] call CBA_fnc_hashSet;
            };

            // the operation in hand at the save (The Horny Latino on Discord, 21 Oct: a pause's clean-up tasks were
            // gone after a load, and the commander moved straight on): its pause and preparations carry on
            _key = format ["%1-OPCOM_%2-opstate", ([""] call ALiVE_fnc_storeKeys) select 0, [_handler,"opcomID"] call CBA_fnc_hashGet];
            _result = [GVAR(DATAHANDLER),"read", ["mil_opcom", [], _key]] call ALIVE_fnc_Data;
            if (_result isEqualType [] && {!isNil {[_result,"data"] call CBA_fnc_hashGet}}) then {
                [_handler, "opResume", [_result,"data"] call CBA_fnc_hashGet] call MAINCLASS;
            };

            [_handler,"objectives", _objectives] call ALiVE_fnc_hashSet;
            [_handler,"rebuildObjectiveIndexes"] call MAINCLASS;
        };

        //If no data was loaded from DB then get objectives data from other modules or synced Location modules!
        if (_objectives isequalto []) then {
            private _placementObjectives = [];
            {
                private _moduleObjectives = [_handler,"getModuleObjectives", _x] call MAINCLASS;
                if (!isnil "_moduleObjectives") then {
                    _placementObjectives append _moduleObjectives;
                };
            } foreach (synchronizedObjects _logic);

            private _objectiveSortStrategy = switch (_type) do {
                case ("occupation") :   { "strategic" };
                case ("invasion")   :   { "distance" };
                case ("asymmetric") :   { "asymmetric" };
            };

            _objectives = [_handler,"createObjectives", [_placementObjectives,_objectiveSortStrategy]] call MAINCLASS;

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
        private _clusterOccupationAnalysis = if (isnil QMOD(REQUIRE_INITIALISED)) then {
            [{
                params ["_handler","_sidesFriendly","_sidesEnemy"];
                [_handler,"analyzeclusteroccupation", [_sidesFriendly, _sidesEnemy]] call MAINCLASS;
            }, [_handler,_sidesFriendly,_sidesEnemy]] call CBA_fnc_directCall;
        } else {
            [_handler,"analyzeclusteroccupation", [_sidesFriendly, _sidesEnemy]] call MAINCLASS;
        };

        private _forcesInit = if (isnil QMOD(REQUIRE_INITIALISED)) then {
            [{
                [_this select 0, "scantroops"] call ALiVE_fnc_OPCOM
            }, [_handler]] call CBA_fnc_directCall;
        } else {
            [_handler, "scantroops"] call ALiVE_fnc_OPCOM;
        };

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

        // Frontline minefields (#979). An invasion or occupation commander with Frontline
        // Minefields set lays a small field in front of each held objective that faces the enemy:
        // anti-tank mines on the roads into it, anti-personnel mines elsewhere, in a band beyond
        // its edge facing the nearest enemy-held objective (or the nearest enemy group). Its own
        // side and friendly sides are told where the mines are. Few allows 2 fields, Many 6; one
        // field per objective, at most one every 5 min; never within 300 m of a player. Fields stay until cleared.
        // The mines still in the ground are kept on their objective, so a saved mission lays them again on load.
        if (_type in ["occupation","invasion"]) then {
            [_handler] spawn {
                params ["_handler"];
                sleep 180;
                private _side = [[_handler,"side","EAST"] call ALiVE_fnc_HashGet] call ALiVE_fnc_sideTextToObject;
                private _tooFew = createHashMap;
                while { !isNil "_handler" && {!([_handler,"stopped",false] call ALiVE_fnc_HashGet)} } do {
                    // Fields saved with the mission come back first, checked every pass so a load that
                    // finishes late is still picked up. A field cleared before the save comes back empty,
                    // still counting against the limit, as it did before the save.
                    private _fields = [_handler,"minefields",[]] call ALiVE_fnc_HashGet;
                    private _restored = 0;
                    {
                        private _oid = [_x,"objectiveID",""] call ALiVE_fnc_HashGet;
                        private _saved = [_x,"minefield",[]] call ALiVE_fnc_HashGet;
                        if (_saved isEqualType [] && {[_x,"minefieldLaid",false] call ALiVE_fnc_HashGet} && {(_fields findIf { (_x select 0) == _oid }) < 0}) then {
                            private _mines = []; private _classes = [];
                            {
                                _x params [["_cls", "APERSMine", [""]], ["_pos", [], [[]]]];
                                if (_pos isNotEqualTo []) then {
                                    private _m = createMine [_cls, _pos, [], 0];
                                    { if ((_side getFriend _x) >= 0.6) then { _x revealMine _m } } forEach [west, east, resistance];
                                    _mines pushBack _m; _classes pushBack _cls;
                                };
                            } forEach _saved;
                            _fields pushBack [_oid, [_x,"center",[0,0,0]] call ALiVE_fnc_HashGet, _mines, _classes];
                            _restored = _restored + 1;
                        };
                    } forEach ([_handler,"objectives",[]] call ALiVE_fnc_HashGet);
                    [_handler,"minefields",_fields] call ALiVE_fnc_HashSet;
                    if (_restored > 0) then { ["OPCOM %1: %2 saved minefield(s) laid again", _side, _restored] call ALiVE_fnc_dump };
                    private _setting = toLower ([_handler,"frontlineMinefields","none"] call ALiVE_fnc_HashGet);
                    private _max = switch (_setting) do { case "few": {2}; case "many": {6}; default {0} };
                    private _fields = [_handler,"minefields",[]] call ALiVE_fnc_HashGet;
                    // What each field still has in the ground goes on its objective, which is what a save keeps.
                    {
                        _x params ["_oid", "_c", "_mines", ["_classes", []]];
                        private _o = [_handler,"getobjectivebyid",_oid] call ALiVE_fnc_OPCOM;
                        if (!isNil "_o" && {_o isEqualType []}) then {
                            private _left = [];
                            { if (!isNull _x && {alive _x}) then { _left pushBack [_classes param [_forEachIndex, "APERSMine"], getPosATL _x] } } forEach _mines;
                            [_o,"minefield",_left] call ALiVE_fnc_HashSet;
                        };
                    } forEach _fields;
                    if (_max > 0 && {count _fields < _max}) then {
                        private _side = [[_handler,"side","EAST"] call ALiVE_fnc_HashGet] call ALiVE_fnc_sideTextToObject;
                        private _held = ([_handler,"objectives",[]] call ALiVE_fnc_HashGet) select {
                            private _oid = [_x,"objectiveID",""] call ALiVE_fnc_HashGet;
                            ([_x,"opcom_state",""] call ALiVE_fnc_HashGet) in ["defend","defending","reserve","reserving","idle"]
                            && {(_fields findIf { (_x select 0) == _oid }) < 0}
                            && {time - (_tooFew getOrDefault [_oid, -1e6]) > 1800}
                        };
                        // Where the enemy is: the centres of objectives hostile commanders hold.
                        private _enemyPos = [];
                        {
                            private _o = _x;
                            private _oSide = [[_o,"side","EAST"] call ALiVE_fnc_HashGet] call ALiVE_fnc_sideTextToObject;
                            if ((_side getFriend _oSide) < 0.6) then {
                                {
                                    if (([_x,"opcom_state",""] call ALiVE_fnc_HashGet) in ["defend","defending","reserve","reserving","idle"]) then {
                                        _enemyPos pushBack ([_x,"center",[0,0,0]] call ALiVE_fnc_HashGet);
                                    };
                                } forEach ([_o,"objectives",[]] call ALiVE_fnc_HashGet);
                            };
                        } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
                        // The objective of ours nearest the enemy, within 3 km of it, goes first.
                        private _best = []; private _bestD = 3000;
                        {
                            private _c = [_x,"center",[0,0,0]] call ALiVE_fnc_HashGet;
                            private _toward = [];
                            private _d = 1e9;
                            { if ((_x distance2D _c) < _d) then { _d = _x distance2D _c; _toward = _x } } forEach _enemyPos;
                            if (_toward isEqualTo []) then {
                                private _foes = ((missionNamespace getVariable ["OPCOM_instances", []]) apply { [_x,"side",""] call ALiVE_fnc_HashGet }) select { (_side getFriend ([_x] call ALiVE_fnc_sideTextToObject)) < 0.6 };
                                {
                                    private _near = [_c, 3000, [_x, "entity"]] call ALIVE_fnc_getNearProfiles;
                                    { private _p = [_x,"position",[0,0,0]] call ALiVE_fnc_HashGet; if ((_p distance2D _c) < _d) then { _d = _p distance2D _c; _toward = _p } } forEach _near;
                                } forEach _foes;
                            };
                            if (_toward isNotEqualTo [] && {_d < _bestD} && {([_c, 300] call ALiVE_fnc_anyPlayersInRange) == 0}) then { _bestD = _d; _best = [_x, _c, _toward] };
                        } forEach _held;
                        if (_best isNotEqualTo []) then {
                            _best params ["_objective", "_c", "_toward"];
                            private _size = ([_objective,"size",150] call ALiVE_fnc_HashGet) max 100;
                            private _dir = _c getDir _toward;
                            private _mines = []; private _classes = [];
                            private _tries = 0;
                            while { count _mines < 12 && {_tries < 60} } do {
                                _tries = _tries + 1;
                                private _p = (_c getPos [_size + 40 + random 120, _dir]) getPos [(random 160) - 80, _dir + 90];
                                if (!surfaceIsWater _p && {((nearestBuilding _p) distance2D _p) > 8} && {([_p, 300] call ALiVE_fnc_anyPlayersInRange) == 0} && {isNil "ALiVE_fnc_isAirside" || {!([_p, 5] call ALiVE_fnc_isAirside)}}) then {
                                    private _onRoad = (_p nearRoads 6) isNotEqualTo [];
                                    private _cls = ["APERSMine", "ATMine"] select _onRoad;
                                    private _m = createMine [_cls, _p, [], 0];
                                    {
                                        if ((_side getFriend _x) >= 0.6) then { _x revealMine _m };
                                    } forEach [west, east, resistance];
                                    _mines pushBack _m; _classes pushBack _cls;
                                };
                            };
                            // Too few spots to make a field (buildings, water, an airfield): take them up and try
                            // this objective again on a later pass rather than leave a mine or two on their own.
                            if (count _mines < 6) exitWith {
                                { deleteVehicle _x } forEach _mines;
                                _tooFew set [[_objective,"objectiveID",""] call ALiVE_fnc_HashGet, time];
                            };
                            _fields pushBack [[_objective,"objectiveID",""] call ALiVE_fnc_HashGet, _c, _mines, _classes];
                            private _saveList = []; { _saveList pushBack [_classes select _forEachIndex, getPosATL _x] } forEach _mines; [_objective,"minefield",_saveList] call ALiVE_fnc_HashSet; [_objective,"minefieldLaid",true] call ALiVE_fnc_HashSet;
                            [_handler,"minefields",_fields] call ALiVE_fnc_HashSet;
                            ["OPCOM %1: minefield of %2 mines laid in front of %3, facing %4", _side, count _mines, mapGridPosition _c, round _dir] call ALiVE_fnc_dump;
                        };
                    };
                    sleep 300;
                };
            };
        };

        // Prepared Defences (#233). An invasion or occupation commander with Prepared Defences set
        // digs in: an objective held for 10 minutes gets a small fort (one of the faction's Fort
        // compositions) at its edge facing the enemy. Few allows 3, Many 8; at most one every 5 min,
        // never within 300 m of a player, and not where fortifications already stand (which also
        // covers a fort restored from a save).
        if (_type in ["occupation","invasion"]) then {
            [_handler] spawn {
                params ["_handler"];
                private _heldSince = createHashMap;
                private _skip = createHashMap;
                sleep 180;
                while { !isNil "_handler" && {!([_handler,"stopped",false] call ALiVE_fnc_HashGet)} } do {
                    private _max = switch (toLower ([_handler,"preparedDefences","none"] call ALiVE_fnc_HashGet)) do { case "few": {3}; case "many": {8}; default {0} };
                    private _built = [_handler,"defences",[]] call ALiVE_fnc_HashGet;
                    // How long each objective has been held, kept every pass so a lost and retaken
                    // objective starts again, however many forts are already up.
                    {
                        private _oid = [_x,"objectiveID",""] call ALiVE_fnc_HashGet;
                        if (([_x,"opcom_state",""] call ALiVE_fnc_HashGet) in ["defend","defending","reserve","reserving","idle"]) then {
                            if !(_oid in _heldSince) then { _heldSince set [_oid, time] };
                        } else {
                            _heldSince deleteAt _oid;
                        };
                    } forEach ([_handler,"objectives",[]] call ALiVE_fnc_HashGet);
                    if (_max > 0 && {count _built < _max}) then {
                        private _sideText = [_handler,"side","EAST"] call ALiVE_fnc_HashGet;
                        private _side = [_sideText] call ALiVE_fnc_sideTextToObject;
                        private _candidates = [];
                        {
                            private _oid = [_x,"objectiveID",""] call ALiVE_fnc_HashGet;
                            if (_oid in _heldSince && {time - (_heldSince get _oid) >= (missionNamespace getVariable ["ALiVE_OPCOM_defenceHold", 600])} && {!(_oid in _built)} && {!(_oid in _skip)}) then { _candidates pushBack _x };
                        } forEach ([_handler,"objectives",[]] call ALiVE_fnc_HashGet);
                        private _foes = ((missionNamespace getVariable ["OPCOM_instances", []]) apply { [_x,"side",""] call ALiVE_fnc_HashGet }) select { _x != "" && {(_side getFriend ([_x] call ALiVE_fnc_sideTextToObject)) < 0.6} };
                        {
                            private _objective = _x;
                            private _oid = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;
                            private _c = [_objective,"center",[0,0,0]] call ALiVE_fnc_HashGet;
                            private _size = ([_objective,"size",150] call ALiVE_fnc_HashGet) max 50;
                            if (([_c, 300 + _size] call ALiVE_fnc_anyPlayersInRange) > 0) then { continue };
                            // already fortified (by placement, or a fort restored from a save): count it as done
                            if (count (nearestObjects [_c, ["Land_BagBunker_Small_F","Land_BagFence_Round_F","Land_HBarrier_3_F","Land_HBarrier_5_F"], _size + 60]) > 4) then { _skip set [_oid, true]; continue };
                            // Face the nearest enemy group within 3 km, else a random edge.
                            private _toward = []; private _d = 3000;
                            {
                                { private _p = [_x,"position",[0,0,0]] call ALiVE_fnc_HashGet; if ((_p distance2D _c) < _d) then { _d = _p distance2D _c; _toward = _p } } forEach ([_c, 3000, [_x, "entity"]] call ALIVE_fnc_getNearProfiles);
                            } forEach _foes;
                            private _dir = if (_toward isEqualTo []) then { random 360 } else { _c getDir _toward };
                            private _faction = ([_handler,"factions",[]] call ALiVE_fnc_HashGet) param [0, ""];
                            private _comps = ["Military", ["Fort"], ["Small"], _faction] call ALiVE_fnc_getCompositions;
                            if (_comps isEqualTo []) then { _skip set [_oid, true]; continue };
                            // the faction's own forts first: the pool holds every faction's. A faction
                            // with none of its own (RHS and most mods) takes its side's vanilla ones
                            // or the unmarked ones, never another side's
                            private _own = _comps select { (configName _x) find _faction >= 0 };
                            if (_own isEqualTo []) then {
                                private _tag = switch (_sideText) do { case "WEST": {"_BLU_"}; case "EAST": {"_OPF_"}; case "GUER": {"_IND_"}; default {"_CIV_"} };
                                _own = _comps select { (configName _x) find _tag >= 0 };
                                if (_own isEqualTo []) then { _own = _comps select { private _n = configName _x; ["_BLU_","_OPF_","_IND_"] findIf { _n find _x >= 0 } < 0 } };
                            };
                            if (_own isNotEqualTo []) then { _comps = _own };
                            private _comp = selectRandom _comps;
                            private _r = ([_comp] call ALiVE_fnc_getCompositionRadius) max 8;
                            // Through the composition site check, which keeps a fort off slopes, roads,
                            // buildings and water; the engine's own search took ground up to a 0.25 gradient
                            // and left forts leaning on hillsides.
                            private _site = [_c getPos [(_size * 0.6) max 30, _dir], 80, _r, "military", _dir] call ALiVE_fnc_findCompositionSpawnPosition;
                            if (_site isEqualTo []) then { continue };
                            private _pos = _site select 0;
                            // no clear ground near this one: it is tried again on a later pass
                            if ((_pos distance2D _c) > (_size + 200) || {(_pos nearRoads (_r + 4)) isNotEqualTo []} || {([_pos, 300] call ALiVE_fnc_anyPlayersInRange) > 0} || {!isNil "ALiVE_fnc_isAirside" && {[_pos, _r] call ALiVE_fnc_isAirside}}) then { continue };
                            [_comp, _pos, _dir, _faction] call ALiVE_fnc_spawnComposition;
                            // players can take it apart once they've cleared the area (ALIVE_fnc_addDismantleAction)
                            [_pos, _r + 5, "fortifications"] call ALIVE_fnc_addDismantleAction;
                            _built pushBack _oid;
                            ["OPCOM %1: prepared defences (%2) built at %3, facing %4", _side, configName _comp, mapGridPosition _pos, round _dir] call ALiVE_fnc_dump;
                            break;
                        } forEach _candidates;
                        [_handler,"defences",_built] call ALiVE_fnc_HashSet;
                    };
                    // Second stage, Many only: an objective that has kept its fort for another 30 minutes
                    // gets a medium fort on one flank, up to 4 per commander, under the same rules.
                    if (_max == 8) then {
                        private _medium = [_handler,"defencesMedium",[]] call ALiVE_fnc_HashGet;
                        private _sideText = [_handler,"side","EAST"] call ALiVE_fnc_HashGet;
                        if (count _medium < 4) then {
                            {
                                private _objective = _x;
                                private _oid = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;
                                if (_oid in _built && {!(_oid in _medium)} && {!((_oid + "_medium") in _skip)} && {_oid in _heldSince}
                                    && {time - (_heldSince get _oid) >= 4 * (missionNamespace getVariable ["ALiVE_OPCOM_defenceHold", 600])}
                                    && {([_objective,"opcom_state",""] call ALiVE_fnc_HashGet) in ["defend","defending","reserve","reserving","idle"]}) then {
                                    private _c = [_objective,"center",[0,0,0]] call ALiVE_fnc_HashGet;
                                    private _size = ([_objective,"size",150] call ALiVE_fnc_HashGet) max 50;
                                    if (([_c, 300 + _size] call ALiVE_fnc_anyPlayersInRange) > 0) then { continue };
                                    private _faction = ([_handler,"factions",[]] call ALiVE_fnc_HashGet) param [0, ""];
                                    private _comps = ["Military", ["Fort"], ["Medium"], _faction] call ALiVE_fnc_getCompositions;
                                    private _own = _comps select { (configName _x) find _faction >= 0 };
                                    if (_own isEqualTo []) then {
                                        private _tag = switch (_sideText) do { case "WEST": {"_BLU_"}; case "EAST": {"_OPF_"}; case "GUER": {"_IND_"}; default {"_CIV_"} };
                                        _own = _comps select { (configName _x) find _tag >= 0 };
                                        if (_own isEqualTo []) then { _own = _comps select { private _n = configName _x; ["_BLU_","_OPF_","_IND_"] findIf { _n find _x >= 0 } < 0 } };
                                    };
                                    if (_own isNotEqualTo []) then { _comps = _own };
                                    if (_comps isEqualTo []) then { _skip set [_oid + "_medium", true]; continue };
                                    // The medium forts are wide (median radius about 30 m) and ground that clear is
                                    // rarely found by a town, so the narrower ones are used and 18 m of clear ground
                                    // around the centre is enough, searched out to 150 m.
                                    private _narrow = _comps select { ([_x] call ALiVE_fnc_getCompositionRadius) <= 28 };
                                    if (_narrow isNotEqualTo []) then { _comps = _narrow };
                                    private _comp = selectRandom _comps;
                                    private _rFull = ([_comp] call ALiVE_fnc_getCompositionRadius) max 10;
                                    private _r = _rFull min 18;
                                    private _dir = random 360;
                                    private _site = [_c getPos [(_size * 0.6) max 30, _dir], 150, _rFull, "military", _dir] call ALiVE_fnc_findCompositionSpawnPosition;
                                    if (_site isEqualTo []) then { continue };
                                    private _pos = _site select 0;
                                    if ((_pos distance2D _c) > (_size + 200) || {(_pos nearRoads (_rFull + 4)) isNotEqualTo []} || {([_pos, 300] call ALiVE_fnc_anyPlayersInRange) > 0} || {!isNil "ALiVE_fnc_isAirside" && {[_pos, _rFull] call ALiVE_fnc_isAirside}}) then { continue };
                                    [_comp, _pos, _c getDir _pos, _faction] call ALiVE_fnc_spawnComposition;
                                    // players can take it apart once they've cleared the area (ALIVE_fnc_addDismantleAction)
                                    [_pos, _rFull + 5, "fortifications"] call ALIVE_fnc_addDismantleAction;
                                    _medium pushBack _oid;
                                    ["OPCOM %1: prepared defences extended (%2) at %3", _sideText, configName _comp, mapGridPosition _pos] call ALiVE_fnc_dump;
                                    break;
                                };
                            } forEach ([_handler,"objectives",[]] call ALiVE_fnc_HashGet);
                            [_handler,"defencesMedium",_medium] call ALiVE_fnc_HashSet;
                        };
                    };
                    sleep 300;
                };
            };
        };

        // Set startup complete and end loading screen if init has passed or an error occurred

        [_handler,"listen"] call MAINCLASS;

        [_factions] call ALiVE_fnc_initFindVehicleTypeCache;

        [_handler,"startupComplete", true] call ALiVE_fnc_HashSet;

        ["place", [_handler]] spawn ALiVE_fnc_OPCOMHVT;

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
            // Set to Placement Only (#1026): its units are placed, its objectives are no commander's.
            if (_module getVariable ["ALiVE_placementOnly", false]) exitWith {
                ["OPCOM - %1 is set to Placement Only, so its objectives are left out", _module] call ALiVE_fnc_dump;
                _result = [];
            };

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
        private _profilesByID = [ALiVE_profileHandler,"profilesById"] call ALiVE_fnc_hashGet;
        private _size_reserve = [_logic,"sectionsamount_reserve",1] call ALiVE_fnc_HashGet;
        private _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;

        private _idlestates = ["unassigned","idle"];
        private _emptyManual = [];

        {
            private _objective = _x;
            private _section = [_objective,"section",[]] call ALiVE_fnc_HashGet;

            private _sectionWaypoints = 0;
            {
                private _profile = _profilesByID get _x;

                if !(isnil "_profile") then {
                    private _profileWaypoints = _profile select 2 select 16;
                    _sectionWaypoints = _sectionWaypoints + (count _profileWaypoints);
                } else {
                    [_logic,"resetProfileOrders", _x] call ALiVE_fnc_OPCOM;
                };
            } foreach _section;

            private _state = [_objective,"opcom_state",[]] call ALiVE_fnc_HashGet;
            if (!(_state in _idlestates) && {count _section > 0} && {_sectionWaypoints == 0}) then {
                {[_logic,"resetProfileOrders", _x] call ALiVE_fnc_OPCOM} forEach (+_section);
                [_logic,"resetObjective", ([_objective,"objectiveID"] call ALiVE_fnc_HashGet)] call ALiVE_fnc_OPCOM;
            };
            // a one-off order (addTask: a player's recon, say) whose group has died has nothing left to do; not one
            // still waiting for its group
            if (
                [_objective,"manualTask",false] call ALiVE_fnc_HashGet
                && {([_objective,"section",[]] call ALiVE_fnc_HashGet) isEqualTo []}
                && {time - ([_objective,"manualSince",time] call ALiVE_fnc_HashGet) > 300}
            ) then {
                _emptyManual pushBack ([_objective,"objectiveID",""] call ALiVE_fnc_HashGet);
            };
        } foreach _objectives;
        { [_logic,"removeObjective",_x] call ALiVE_fnc_OPCOM } forEach _emptyManual;

        private _pendingOrders = [_logic,"pendingorders",[]] call ALiVE_fnc_HashGet;
        private _ordersToRemove = [];

        {
            _x params ["","_profileID","","_orderTime"];

            private _dead = isNil { _profilesByID get _profileID };
            private _timeout = (time - _orderTime) > 3600;

            if (_dead || {_timeout}) then {
                _ordersToRemove pushBack _forEachIndex;
            };
        } forEach _pendingOrders;

        [_pendingOrders,_ordersToRemove] call ALiVE_fnc_deleteAtMany;
    };

    case "NearestAvailableSection": {

        private ["_radius","_troopsunsorted","_types","_pos","_size","_troops","_busy","_section","_reserved","_profileIDs","_profile","_profileObjectiveAssignment"];

        _args params [
            "_pos",
            "_size",
            ["_types", ["infantry"]]
        ];

        // Get troops from current OPCOM analysis
        _troops = []; {_troops = _troops + ([_logic,_x,[]] call ALiVE_fnc_HashGet)} foreach _types;

        //subtract busy and reserved profiles
        _busy = +([_logic,"pendingorders",[]] call ALiVE_fnc_HashGet);

        _profileObjectiveAssignment = [_logic,"profileObjectiveAssignment"] call ALiVE_fnc_HashGet;
        _busy append (keys _profileObjectiveAssignment);

        _reserved = [_logic,"ProfileIDsReserve", []] call ALiVE_fnc_HashGet;
        _busy = _busy - _reserved;

        // If great amount of troops is requested reroute profiles if needed
        _troops = if (_size >= 5) then { _troops - _reserved } else { _troops - (_busy + _reserved) };

        // Read shared search settings once per section request.
        private _searchSide = [_logic,"side","EAST"] call ALiVE_fnc_HashGet;
        private _pathfindingEnabled = [Alive_profileSystem,"pathfinding"] call ALiVE_fnc_hashGet;
        private _seaProfileIDs = [_logic,"sea",[]] call ALiVE_fnc_HashGet;

        // Filter troops
        _radius = 2000;
        while
        {
            private _nearProfiles = [_pos, _radius, [_searchSide,"entity"]] call ALIVE_fnc_getNearProfiles;

            _troopsUnsorted = [];

            {
                private _profile = _x;

                if (!isnil "_profile") then {

                    private _profileID = [_profile,"profileID",""] call ALiVE_fnc_HashGet;
                    private _commander = (count ([_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashGet) > 0);
                    private _busy = ([_profile,"busy",false] call ALiVE_fnc_HashGet);
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
                    private _valid = !_busy && {_profileID in _troops} && {!_commander || {if (_profileID in _seaProfileIDs) then {call _isSeaTravel} else {!(call _isSeaTravel)}}} && {!_isStaticAA} && {!(!isNil "ALIVE_profileStationary" && {[ALIVE_profileStationary, _profileID, false] call ALIVE_fnc_hashGet})};

                    if (_valid) then {_troopsUnsorted pushBack _profile};
                };
            } foreach _nearProfiles;

            // Expand only while the current radius cannot fill the section.
            ((count _troopsUnsorted < _size) && {_radius < 15000});
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

    case "attackentity";
    case "attackEntity": {
        ASSERT_TRUE(_args isequaltype [],str _args);

        private ["_target","_reserved","_sides","_size","_type","_proIDs","_knownE","_attackedE","_pos","_profiles","_profileIDs","_profile","_section","_profileID","_i","_waypoints","_posAttacker","_dist","_rtb","_fireSupport","_vehicleProfile","_vehicleType","_ATOtype"];

        _target = _args select 0;
        _size = _args select 1;
        _type = _args select 2;

        _section = [];
        _profileIDs = [];
        _profiles = [];
        _dist = 1000;

        private _profilesById = [ALiVE_ProfileHandler,"profilesById"] call ALiVE_fnc_hashGet;
        
        _profile = _profilesById get _target;
        if (isnil "_profile") exitwith {_result = []}; //Exit early
        
        _side = [_logic,"side"] call ALiVE_fnc_HashGet;
        _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;
        _sides = [_logic,"sidesenemy",["EAST"]] call ALiVE_fnc_HashGet;
        _knownE = [_logic,"knownentities",[]] call ALiVE_fnc_HashGet;
        _attackedE = [_logic,"attackedentities",[]] call ALiVE_fnc_HashGet;
        _reserved = [_logic,"ProfileIDsReserve",[]] call ALiVE_fnc_HashGet;
        _pos = [_profile,"position"] call ALiVE_fnc_HashGet;

        _vehicles = ([_profile,"vehicleAssignments",[[],[]]] call ALIVE_fnc_hashGet) select 1;
        if (count _vehicles > 0) then {
            _vehicleProfile = _profilesById get (_vehicles select 0);
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
        // _side is already the side TEXT here ("EAST"), so str would wrap it in
        // quote characters and build a key the artillery module never publishes
        private _artyRate = missionNamespace getVariable [format ["ALIVE_MilArtillery_requestRate_%1", toUpper _side], [0,0]];
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
            private _artyEvents = [];
            {
                if (_artyFired >= _artyMax) exitWith {};
                if (!isnil "_x" && {_x isEqualType []} && {count _x > 0}) then {
                    private _cID = _x select 0;
                    if (({!(isnil "_x") && {_x isEqualType []} && {(_x select 0) == _cID}} count _artyReq) < 1) then {
                        private _cProfile = _profilesById get _cID;
                        if (!isnil "_cProfile") then {
                            private _cPos = [_cProfile,"position"] call ALiVE_fnc_HashGet;
                            // _cID is still a member of _knownE (unlike the #887
                            // block, where _target was pruned at the top), so its
                            // own entry supplies the "self" count - no 1+ seed, or
                            // the weight would run one high and relax selectivity.
                            private _cContacts = ({
                                !isnil "_x" && {_x isEqualType []} && {count _x > 0} && {
                                    private _kP = _profilesById get (_x select 0);
                                    !isnil "_kP" && {([_kP,"position"] call ALiVE_fnc_HashGet) distance2D _cPos < 200}
                                }
                            } count _knownE);
                            private _aE = ['ARTY_REQUEST', [_cID, _cPos, _cContacts, _artySideObj, _artyFaction, _artyAsym],"OPCOM"] call ALIVE_fnc_event;
                            _artyEvents pushBack _aE;
                            _artyReq pushBack [_cID, time];
                            _artyFired = _artyFired + 1;
                        };
                    };
                };
            } forEach _knownE;

            if (_artyEvents isNotEqualTo []) then {
                [ALIVE_eventLog,"addEvents", _artyEvents] call ALIVE_fnc_eventLog;
            };

            [_logic,"artyRequestedEntities", _artyReq] call ALiVE_fnc_HashSet;
        };

        if ({!(isnil "_x") && {_x select 0 == _target}} count _attackedE < 1) then {
            ([_logic, ["infantry","motorized","mechanized","armored","artillery","AAA","air"]] call ALiVE_fnc_hashGetMany) params [
                "_infantry","_motorized","_mechanized","_armored","_artillery","_AAA","_air"
            ];

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
                _eventID = [ALIVE_eventLog,"addEvent", _event] call ALIVE_fnc_eventLog;

                _attackedE pushback [_target,_pos,_section,time];
                [_logic,"attackedentities", _attackedE] call ALiVE_fnc_HashSet;
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
                private _targetProfile = _profilesById get _target;
                if (!isnil "_targetProfile") then {
                    private _targetPos = [_targetProfile,"position"] call ALiVE_fnc_HashGet;

                    // contact weight: the target itself counts (it was pruned
                    // from the known-entities list above, so start at 1) plus
                    // known enemies near it - the artillery module applies
                    // its minimum-contact rule to this count
                    private _contacts = 1;
                    {
                        if (!isnil "_x" && {_x isEqualType []} && {count _x > 0}) then {
                            private _kProfile = _profilesById get (_x select 0);
                            if (!isnil "_kProfile") then {
                                if (([_kProfile,"position"] call ALiVE_fnc_HashGet) distance2D _targetPos < 200) then {
                                    _contacts = _contacts + 1;
                                };
                            };
                        };
                    } foreach _knownE;

                    private _asym = ([_logic,"controltype",""] call ALiVE_fnc_HashGet) == "asymmetric";

                    private _aEvent = ['ARTY_REQUEST', [_target, _targetPos, _contacts, [_side] call ALiVE_fnc_sideTextToObject, _factions select 0, _asym],"OPCOM"] call ALIVE_fnc_event;
                    [ALIVE_eventLog,"addEvent", _aEvent] call ALIVE_fnc_eventLog;
                };
            };

            // artillery sections themselves hold position and answer with
            // fire missions instead of driving at the enemy like line units
            if (!isnil "_fireSupport") exitwith {
                _attackedE pushback [_target,_pos,_section,time];
                [_logic,"attackedentities", _attackedE] call ALiVE_fnc_HashSet;
            };

            if (count _profiles == 0) then {
                {
                    if (_x isnotequalto []) exitwith {
                        _profiles = _x;
                        _rtb = nil;
                    };
                } foreach [_armored,_mechanized,_motorized,_infantry];
            };

            if (count _profiles > 0) then {

                // A QRF only needs _size sections (normally one or two). Query
                // the profile spatial grid instead of sorting every section in
                // the force, then keep a distance-ordered bounded candidate set.
                private _eligibleProfileIDs = createHashMap;
                {_eligibleProfileIDs set [_x, true]} forEach _profiles;
                private _nearProfiles = [_pos, _dist, [_side,"entity"]] call ALiVE_fnc_getNearProfiles;
                private _candidates = [];
                {
                    private _candidateProfile = _x;
                    private _profileID = [_candidateProfile,"profileID",""] call ALiVE_fnc_HashGet;

                    if (!isnil "_candidateProfile" && {_eligibleProfileIDs getOrDefault [_profileID, false]}) then {
                        private _candidatePos = [_candidateProfile, "position"] call ALiVE_fnc_HashGet;
                        private _aaBehVal = if (!isNil "ALIVE_aaProfileBehaviour") then {
                            [ALIVE_aaProfileBehaviour, _profileID] call ALIVE_fnc_hashGet
                        } else { nil };
                        private _isStaticAA = !isNil "_aaBehVal" && {typeName _aaBehVal == "STRING"} && {_aaBehVal == "static"};

                        private _candidateDistance = _pos distance _candidatePos;
                        if (_candidateDistance < _dist && {!(_profileID in _reserved)} && {!_isStaticAA} && {!(!isNil "ALIVE_profileStationary" && {[ALIVE_profileStationary, _profileID, false] call ALIVE_fnc_hashGet})}) then {
                            private _candidateWaypoints = [_candidateProfile,"waypoints"] call ALIVE_fnc_hashGet;

                            if (({!(isnil "_x") && {_profileID in (_x select 2)}} count _attackedE) < 1 && {count _candidateWaypoints <= 2}) then {
                                private _candidate = [_candidateDistance, _profileID, _candidateProfile, _candidatePos];
                                private _insertAt = _candidates findIf {(_candidate select 0) < (_x select 0)};
                                if (_insertAt < 0) then {
                                    _candidates pushBack _candidate;
                                } else {
                                    _candidates insert [_insertAt, [_candidate]];
                                };
                                if (count _candidates > _size) then {
                                    _candidates deleteAt _size;
                                };
                            };
                        };
                    };
                } forEach _nearProfiles;

                {
                    _x params ["_candidateDistance", "_profileID", "_profile", "_posAttacker"];
                    private _profileWaypoint = [];

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
                    _section pushBack _profileID;
                } forEach _candidates;

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

    case "setorders";
    case "setOrders": {
        _args params ["_pos","_profileID","_objectiveID","_orders"];

        private _profileWaypoints = [_logic,"setSectionOrders",
            [
                [],
                _objectiveID,
                _orders,
                [[_pos,_profileID]]
            ]] call MAINCLASS;
        _result = _profileWaypoints param [0,[]];
    };

    case "setSectionOrders": {
        _args params ["_targetObjective","_objectiveID","_orders","_orderBatch",["_orderID",-1]];

        if (_orderBatch isEqualTo []) exitWith {
            _result = [];
        };

        private _TACOM_FSM = [_logic,"TACOM_FSM"] call ALiVE_fnc_HashGet;

        // defensive guard, not required under correct operation
        // if a profile was given multiple orders, select the last order
        private _ordersByProfileID = createHashMap;
        {
            _ordersByProfileID set [_x select 1, _x];
        } forEach _orderBatch;
        _orderBatch = values _ordersByProfileID;
        // TACOM supplies the objective after PREPARE_ORDERS has already updated
        // its section through setObjectiveSection. Legacy setorders callers do
        // not supply it, so retain defensive assignment reconciliation for them.
        if (_targetObjective isEqualTo []) then {
            private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_HashGet;
            _targetObjective = _objectivesByID get _objectiveID;

            if !(isNil "_targetObjective") then {
                private _section = [_targetObjective,"section",[]] call ALiVE_fnc_HashGet;
                [_logic,"setObjectiveSection", [_targetObjective,_section]] call MAINCLASS;
            };
        };

        private _pendingOrders = [_logic,"pendingorders",[]] call ALiVE_fnc_HashGet;
        {
            if !(isNil {_ordersByProfileID get (_x select 1)}) then {
                _pendingOrders deleteAt _forEachIndex;
            };
        } forEachReversed _pendingOrders;

        private _profilesByID = [ALiVE_profileHandler,"profilesById"] call ALiVE_fnc_hashGet;
        private _profileWaypoints = [];

        // Attacks Arrive Together (#207). The groups of an attack set off at once at their own speed, so the
        // armour reached the objective minutes before the infantry. Each ground group's time to its point is
        // estimated from the straight distance and its normal speed (a vehicle's by 1.3, for the roads it keeps
        // to), and a group that would arrive 20 s or more before the slowest waits where it is for the difference
        // (at most 15 minutes) before setting off. Only the two legs of an attack: the move to the points round
        // the objective, and the capture from there. Aircraft are left as they were: held, a spawned helicopter
        // would take off and hover where it stood.
        private _delays = createHashMap;
        if ([_logic,"arriveTogether",false] call ALiVE_fnc_HashGet && {_orders in ["recon","capture"]} && {count _orderBatch > 1}) then {
            private _air = [_logic,"air",[]] call ALiVE_fnc_HashGet;
            private _foot = [_logic,"infantry",[]] call ALiVE_fnc_HashGet;
            private _etas = [];
            {
                _x params ["_pos","_profileID"];
                private _profile = _profilesByID get _profileID;
                if (!isNil "_profile" && {!(_profileID in _air)}) then {
                    private _speed = (([_profile,"speedPerSecond",[1,1,1]] call ALiVE_fnc_HashGet) param [1, 1]) max 0.5;
                    private _eta = (([_profile,"position",_pos] call ALiVE_fnc_HashGet) distance2D _pos) / _speed;
                    if !(_profileID in _foot) then { _eta = _eta * 1.3 };
                    _etas pushBack [_profileID, _eta];
                };
            } forEach _orderBatch;
            if (_etas isNotEqualTo []) then {
                private _slowest = selectMax (_etas apply { _x select 1 });
                {
                    _x params ["_profileID","_eta"];
                    private _wait = (_slowest - _eta) min 900;
                    if (_wait >= 20) then { _delays set [_profileID, _wait] };
                } forEach _etas;
            };
        };
        // Preparation Fire (#207). The assault on an objective where recon found the enemy is preceded by a call
        // for fire on its defenders: the group nearest its centre, weighted by the others within 200 m of it, as
        // the commander's contact reports ask. The artillery module decides whether a battery answers (range,
        // rounds, cooldown, its friendly check). Its check is made once, before a ranging round and the volley, so
        // the assault holds where it stands for 150 s first, by the same wait as Attacks Arrive Together, rather
        // than closing on the target under its own guns. Not asked with a friendly group already within 250 m of
        // the target (the section on the objective as the order is issued again), nor more than once per
        // objective in 15 minutes.
        private _prepHold = 0;
        if ([_logic,"prepFire",false] call ALiVE_fnc_HashGet && {_orders == "capture"} && {!isNil "_targetObjective"} && {_targetObjective isNotEqualTo []}
            && {([_targetObjective,"danger",-1] call ALiVE_fnc_HashGet) > 0}
            && {time - ([_targetObjective,"prepFireAt",-1e9] call ALiVE_fnc_HashGet) > 900}
            && {(_orderBatch findIf { !isNil {_profilesByID get (_x select 1)} }) > -1}
            && {["ALiVE_mil_artillery"] call ALiVE_fnc_IsModuleAvailable}) then {
            private _center = [_targetObjective,"center",[0,0,0]] call ALiVE_fnc_HashGet;
            private _sidesEnemy = [_logic,"sidesenemy",[]] call ALiVE_fnc_HashGet;
            private _defenders = ([_logic,"findProfilesNearPosition",[_center,_sidesEnemy,false]] call MAINCLASS) select { ((_x select 1) distance2D _center) < 250 };
            if (_defenders isEqualTo []) exitWith {};
            _defenders = [_defenders, [], { (_x select 1) distance2D _center }, "ASCEND"] call BIS_fnc_sortBy;
            (_defenders select 0) params ["_targetID","_targetPos"];
            private _side = [_logic,"side","EAST"] call ALiVE_fnc_HashGet;
            private _ownSides = ([_logic,"sidesfriendly",[]] call ALiVE_fnc_HashGet) + [_side];
            if (([_targetPos, 250, [_ownSides,"entity"]] call ALIVE_fnc_getNearProfiles) isNotEqualTo []) exitWith {};
            private _contacts = { ((_x select 1) distance2D _targetPos) < 200 } count _defenders;
            private _factions = [_logic,"factions",[]] call ALiVE_fnc_HashGet;
            private _asym = ([_logic,"controltype",""] call ALiVE_fnc_HashGet) == "asymmetric";
            [_targetObjective,"prepFireAt",time] call ALiVE_fnc_HashSet;
            private _event = ['ARTY_REQUEST', [_targetID, _targetPos, _contacts, [_side] call ALiVE_fnc_sideTextToObject, _factions param [0, ""], _asym],"OPCOM"] call ALIVE_fnc_event;
            [ALIVE_eventLog,"addEvent", _event] call ALIVE_fnc_eventLog;
            _prepHold = 150;
            ["OPCOM %1 - preparation fire asked on objective %2: %3 contact(s) at the nearest defenders (%6), %4 m from its centre; the assault holds %5 s", _side, _objectiveID,
                _contacts, round (_targetPos distance2D _center), _prepHold, _targetID] call ALiVE_fnc_dump;
        };
        // aircraft don't hold (a spawned helicopter would take off and hover)
        private _airIDs = [_logic,"air",[]] call ALiVE_fnc_HashGet;
        private _issuedAt = time;

        {
            _x params ["_pos","_profileID"];
            private _profile = _profilesByID get _profileID;

            if !(isNil "_profile") then {
                [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
                [_profile,"clearActiveCommands"] call ALIVE_fnc_profileEntity;

                private _profileWaypoint = [_pos,15] call ALIVE_fnc_createProfileWaypoint;
                private _message = ["completed",[_profileID,_objectiveID,_orders]];
                private _statements = format ["[{private _queue = %1 getFSMVariable [""_TACOM_QUEUE"",[]]; _queue pushBack %2; %1 setFSMVariable [""_TACOM_QUEUE"",_queue];}, [], 1 + (random 9)] call CBA_fnc_waitAndExecute",_TACOM_FSM,_message];
                [_profileWaypoint, [
                    ["statements",["true",_statements]],
                    ["behaviour","AWARE"],
                    ["speed","NORMAL"]
                ]] call ALiVE_fnc_hashSetMany;

                private _wait = (_delays getOrDefault [_profileID, 0]) + ([_prepHold, 0] select (_profileID in _airIDs));
                if (_wait > 0) then {
                    // a waypoint where the group stands that completes only once the wait is over, then the order
                    // itself. It keeps the group on a waypoint meanwhile (the sweep of finished orders would
                    // otherwise hand it back) and needs nothing to release it, so an order reset or replaced
                    // meanwhile can't leave the group stuck. Time starts again after a saved game is loaded, so
                    // an earlier time than the order's means a reload, and the group goes at once.
                    private _here = +([_profile,"position",_pos] call ALiVE_fnc_HashGet);
                    private _waitPoint = [_here,0,"MOVE","NORMAL",0,[],"NO CHANGE","NO CHANGE","AWARE"] call ALIVE_fnc_createProfileWaypoint;
                    [_waitPoint,"statements",[format ["time > %1 || {time < %2}", _issuedAt + _wait, _issuedAt], ""]] call ALiVE_fnc_hashSet;
                    [_profile,"addWaypoint",_waitPoint] call ALIVE_fnc_profileEntity;
                };
                [_profile,"addWaypoint",_profileWaypoint] call ALIVE_fnc_profileEntity;
                _pendingOrders pushBack [_pos,_profileID,_objectiveID,_issuedAt,_orderID];
                _profileWaypoints pushBack _profileWaypoint;
            };
        } forEach _orderBatch;


        _result = _profileWaypoints;
    };

    case "confirmOrder": {
        // An accepted order's groups are OPCOM's to track from here. Taking the order ID
        // off their pending entries means a duplicate or stale confirmation that turns up
        // later can never release groups that are legitimately on an accepted order.
        private _orderID = _args;
        _result = 0;

        if !(_orderID isEqualType 0 && {_orderID > 0}) exitWith {};

        {
            if ((_x param [4,-1]) isEqualTo _orderID) then {
                _x set [4,-1];
                _result = _result + 1;
            };
        } forEach ([_logic,"pendingorders",[]] call ALiVE_fnc_HashGet);
    };

    case "releaseOrder": {
        // TACOM hands out the waypoints and marks the groups busy before it confirms, so
        // an order OPCOM then rejects (expired, late or stale) left its groups walking to
        // a dead objective and kept out of new sections until the one hour sweep in
        // cleanupduplicatesections. Release exactly the groups this order stamped.
        // Manual and legacy orders stamp -1 and are never released here.
        private _orderID = _args;
        _result = [];

        if !(_orderID isEqualType 0 && {_orderID > 0}) exitWith {};

        // collect first: resetProfileOrders deletes from pendingorders as it goes
        private _profileIDs = [];
        {
            if ((_x param [4,-1]) isEqualTo _orderID) then {_profileIDs pushBack (_x select 1)};
        } forEach ([_logic,"pendingorders",[]] call ALiVE_fnc_HashGet);

        if (_profileIDs isEqualTo []) exitWith {};

        private _profilesByID = [ALiVE_profileHandler,"profilesById"] call ALiVE_fnc_hashGet;
        {
            private _profile = _profilesByID get _x;
            if !(isNil "_profile") then {
                // the waypoint carries a "completed" statement for this order, so leaving it
                // would have the group report a completion for an order that no longer
                // exists when it arrives
                [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
                [_profile,"clearActiveCommands"] call ALIVE_fnc_profileEntity;
            };
            [_logic,"resetProfileOrders",_x] call MAINCLASS;
        } forEach _profileIDs;

        if ([_logic,"debug",false] call ALiVE_fnc_HashGet) then {
            ["OPCOM %1 released %2 group(s) from dead order %3: %4",
                [_logic,"side","EAST"] call ALiVE_fnc_HashGet, count _profileIDs, _orderID, _profileIDs] call ALiVE_fnc_dump;
        };

        _result = _profileIDs;
    };

    case "setObjectiveSection": {
        _args params ["_objective","_newSection"];

        if (isNil "_objective" || {!(_objective isEqualType [])}) exitWith {
            _result = [[],[],[]];
        };

        private _objectiveID = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;
        private _oldSection = +([_objective,"section",[]] call ALiVE_fnc_HashGet);
        _newSection = _newSection arrayIntersect _newSection; // deduplicate section

        private _addedProfileIDs = _newSection - _oldSection;
        private _removedProfileIDs = (_oldSection - _newSection) arrayIntersect (_oldSection - _newSection);

        private _reassignedProfileIDs = [];
        private _emptiedObjectiveIDs = [];
        private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_HashGet;
        private _profileObjectiveAssignment = [_logic,"profileObjectiveAssignment"] call ALiVE_fnc_HashGet;

        _objectivesByID set [_objectiveID,_objective];

        {
            private _assignedObjectiveID = _profileObjectiveAssignment get _x;
            if (_assignedObjectiveID isEqualTo _objectiveID) then {
                _profileObjectiveAssignment deleteAt _x;
            };
        } forEach _removedProfileIDs;

        {
            private _profileID = _x;
            private _assignedObjectiveID = _profileObjectiveAssignment get _profileID;

            if !(isNil "_assignedObjectiveID") then {
                if (_assignedObjectiveID isNotEqualTo _objectiveID) then {
                    private _assignedObjective = _objectivesByID get _assignedObjectiveID;

                    if !(isNil "_assignedObjective") then {
                        if !(_assignedObjective isEqualRef _objective) then {
                            private _assignedSection = [_assignedObjective,"section",[]] call ALiVE_fnc_HashGet;
                            private _remainingSection = _assignedSection - [_profileID];

                            if (_remainingSection isNotEqualTo _assignedSection) then {
                                [_assignedObjective,"section",_remainingSection] call ALiVE_fnc_HashSet;
                                [_assignedObjective,"sectionAssist",[]] call ALiVE_fnc_HashSet;

                                if (_remainingSection isEqualTo []) then {
                                    _emptiedObjectiveIDs pushBackUnique _assignedObjectiveID;
                                };
                            };
                        };
                    };

                    _reassignedProfileIDs pushBackUnique _profileID;
                };
            };

            _profileObjectiveAssignment set [_profileID,_objectiveID];
        } forEach _newSection;

        [_objective,"section",_newSection] call ALiVE_fnc_HashSet;
        if (_removedProfileIDs isNotEqualTo [] || {_newSection isEqualTo []}) then {
            [_objective,"sectionAssist",[]] call ALiVE_fnc_HashSet;
        };

        if (_reassignedProfileIDs isNotEqualTo []) then {
            private _profileIDsReserve = [_logic,"ProfileIDsReserve",[]] call ALiVE_fnc_HashGet;
            {
                private _reserveIndex = _profileIDsReserve find _x;
                if (_reserveIndex != -1) then {
                    _profileIDsReserve deleteAt _reserveIndex;
                };
            } forEach _reassignedProfileIDs;
        };

        {
            [_logic,"resetObjective",_x] call MAINCLASS;
        } forEach _emptiedObjectiveIDs;

        _result = [_addedProfileIDs,_removedProfileIDs,_reassignedProfileIDs];
    };

    ///////////////////////////////////////////////////
    // Called when a profile has compeleted waypoint
    // that was created for a TACOM order
    // Returns whether or not any remaining waypoints
    // for that order remain
    ///////////////////////////////////////////////////

    case "synchronizeorders";
    case "synchronizeOrders": {
        private _profileIDInput = _args;
        private _pendingOrders = [_logic,"pendingorders", []] call ALiVE_fnc_HashGet;
        private _profilePendingOrderIndex = _pendingOrders findIf { (_x select 1) == _profileIDInput };

        if (_profilePendingOrderIndex == -1) exitWith {
            _result = false;
        };

        private _profilePendingOrder = _pendingOrders deleteAt _profilePendingOrderIndex;
        private _objectiveIDToCheck = _profilePendingOrder select 2;

        private _profilesByID = [ALiVE_profileHandler,"profilesById"] call ALiVE_fnc_hashGet;
        private _hasRemainingOrders = false;

        {
            _x params ["","_profileID","_objectiveID","_orderTime"];

            if (_objectiveID == _objectiveIDToCheck) then {
                private _dead = isNil { _profilesByID get _profileID };
                private _timeout = (time - _orderTime) > 3600;

                if (_dead || {_timeout}) then {
                    _pendingOrders deleteAt _forEachIndex;
                } else {
                    _hasRemainingOrders = true;
                };
            };
        } forEachReversed _pendingOrders;

        _result = !_hasRemainingOrders;
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
        private _pendingOrderIndex = _pendingOrders findIf { (_x select 1) == _profileID };
        if (_pendingOrderIndex != -1) then {
            _pendingOrders deleteAt _pendingOrderIndex;
        };

        // if entity is assigned to objective, remove it
        // if objective then has no profiles assigned, reset objective

        // Remove the profile directly from its assigned objective. The fallback
        // scan repairs legacy or externally-mutated section data without keeping
        // the linear search on the normal order-reset path.
        private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_HashGet;
        private _profileObjectiveAssignment = [_logic,"profileObjectiveAssignment"] call ALiVE_fnc_HashGet;
        private _assignedObjectiveID = _profileObjectiveAssignment get _profileID;
        private _assignmentRemoved = false;

        if !(isNil "_assignedObjectiveID") then {
            private _assignedObjective = _objectivesByID get _assignedObjectiveID;

            if !(isNil "_assignedObjective") then {
                private _section = [_assignedObjective,"section",[]] call ALiVE_fnc_HashGet;
                private _sectionProfileIndex = _section find _profileID;

                if (_sectionProfileIndex != -1) then {
                    private _remainingSection = _section - [_profileID];
                    [_logic,"setObjectiveSection",[_assignedObjective,_remainingSection]] call MAINCLASS;
                    _assignmentRemoved = true;

                    if (_remainingSection isEqualTo []) then {
                        [_logic,"resetObjective",_assignedObjectiveID] call MAINCLASS;
                    };
                };
            };
        };

        _profileObjectiveAssignment deleteAt _profileID;

        if (!_assignmentRemoved) then {
            {
                private _objective = _x;
                private _section = [_objective,"section",[]] call ALiVE_fnc_HashGet;
                private _sectionProfileIndex = _section find _profileID;

                if (_sectionProfileIndex != -1) exitWith {
                    private _objectiveID = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;
                    private _remainingSection = _section - [_profileID];
                    [_logic,"setObjectiveSection",[_objective,_remainingSection]] call MAINCLASS;

                    if (_remainingSection isEqualTo []) then {
                        [_logic,"resetObjective",_objectiveID] call MAINCLASS;
                    };
                };
            } forEach ([_logic,"objectives",[]] call ALiVE_fnc_HashGet);
        };

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
            private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_HashGet;
            _result = _objectivesByID get _id;
        } else {
            {
                private _objectivesByID = [_x,"objectivesByID"] call ALiVE_fnc_HashGet;
                private _objective = _objectivesByID get _id;
                if !(isNil "_objective") exitWith {
                    _result = _objective;
                };
            } foreach OPCOM_INSTANCES;
        };
    };

    case "rebuildObjectiveIndexes": {
        private _objectivesByID = createHashMap;
        private _profileObjectiveAssignment = createHashMap;
        private _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
        private _objectivesEmptiedByRepair = [];

        {
            private _objective = _x;
            private _objectiveID = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;
            _objectivesByID set [_objectiveID,_objective];
        } forEach _objectives;

        {
            private _objective = _x;
            private _objectiveID = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;
            private _section = [_objective,"section",[]] call ALiVE_fnc_HashGet;
            private _normalizedSection = [];

            {
                private _assignedObjectiveID = _profileObjectiveAssignment get _x;

                if (isNil "_assignedObjectiveID") then {
                    _profileObjectiveAssignment set [_x,_objectiveID];
                    _normalizedSection pushBack _x;
                } else {
                    if (_assignedObjectiveID isEqualTo _objectiveID) then {
                        _normalizedSection pushBackUnique _x;
                    };
                };
            } forEach _section;

            if (_normalizedSection isNotEqualTo _section) then {
                [_objective,"section",_normalizedSection] call ALiVE_fnc_HashSet;
                [_objective,"sectionAssist",[]] call ALiVE_fnc_HashSet;

                if (_section isNotEqualTo [] && {_normalizedSection isEqualTo []}) then {
                    _objectivesEmptiedByRepair pushBackUnique _objectiveID;
                };
            };
        } forEach _objectives;

        [_logic,"objectivesByID", _objectivesByID] call ALiVE_fnc_HashSet;
        [_logic,"profileObjectiveAssignment", _profileObjectiveAssignment] call ALiVE_fnc_HashSet;

        {
            [_logic,"resetObjective", _x] call MAINCLASS;
        } forEach _objectivesEmptiedByRepair;

        _result = [_objectivesByID,_profileObjectiveAssignment];
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

                    // Custom objectives are stamped "CUS" (Cust. Obj.) and "CCU" (Cust. Civ. Obj.)
                    // above, so they count with military and civilian objectives here. Filtering on
                    // "CIV" and "MIL" alone dropped every custom objective from an insurgency.
                    _objectivesFilteredCiv = [_objectivesCiv,[_logic],{(([_Input0, "position"] call ALIVE_fnc_HashGet) distance (_x select 2 select 1))*(1-(random 0.20))},"ASCEND",{([_x,"objectiveType","MIL"] call ALiVE_fnc_HashGet) in ["CIV","CCU"]}] call ALiVE_fnc_SortBy;
                    _objectivesFilteredMil = [_objectivesMil,[_logic],{(([_Input0, "position"] call ALIVE_fnc_HashGet) distance (_x select 2 select 1))*(1-(random 0.20))},"ASCEND",{([_x,"objectiveType","MIL"] call ALiVE_fnc_HashGet) in ["MIL","CUS"]}] call ALiVE_fnc_SortBy;

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
                                // whether any building here can take one: the first suitable building is enough
                                private _availableBuildings = [_center,_size,1] call ALiVE_fnc_INS_filterObjectiveBuildings;
                                private _availableRoads = _center nearRoads _size;

                                if (count _availableBuildings > 0) then {
                                    _buildingTypes = ["HQ","depot","factory"] select { [_logic, ["recruit", _x] select (_x != "HQ")] call ALiVE_fnc_INS_typeAllowed };
                                };

                                if (count _availableRoads > 0) then {
                                    _roadTypes = ["ied"] select { [_logic, _x] call ALiVE_fnc_INS_typeAllowed };
                                    if (_roadblocks && {[_logic, "roadblocks"] call ALiVE_fnc_INS_typeAllowed}) then {_roadTypes pushBack "roadblocks"};
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
            [_logic,"rebuildObjectiveIndexes"] call MAINCLASS;

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
            [_logic,"setObjectiveSection",[_objective,[]]] call MAINCLASS;

            [_objective, [
                ["tacom_state", "none"],
                ["opcom_state", "unassigned"],
                ["danger", -1],
                ["opcom_orders", "none"],
                ["objectiveType", _objectiveType]
            ]] call ALiVE_fnc_hashSetMany;

            ([_logic, ["opcomID","side","factions"]] call ALiVE_fnc_hashGetMany) params ["_opcomID","_side","_factions"];

            private _event = ['TACOM_ORDER_COMPLETE', [_opcomID,_objective,_previousTacomState,_side,_factions, false, []], "TACOM"] call ALIVE_fnc_event; //TODO: this should be elsewhere
            [ALIVE_eventLog,"addEvent", _event] call ALIVE_fnc_eventLog;

            private _debug = [_logic,"debug", false] call ALiVE_fnc_HashGet;
            if (_debug) then {
                private _marker = GET_OBJECTIVE_DEBUG_MARKER(_objectiveID);
                _marker setMarkerColor "ColorWhite";
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
                if (_debug) then {
                    GET_OBJECTIVE_DEBUG_MARKER(_args) setMarkerColor "ColorWhite";
                };
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
            private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_HashGet;
            private _objective = _objectivesByID get _objectiveID;
            private _objectiveIndex = if (isNil "_objective") then {
                -1
            } else {
                _objectives findIf { _x isEqualRef _objective }
            };

            if (_objectiveIndex != -1) then {
                private _section = [_objective,"section",[]] call ALiVE_fnc_HashGet;
                private _manualTask = [_objective,"manualTask",false] call ALiVE_fnc_HashGet;

                [_objective,"deleted", true] call ALiVE_fnc_hashSet;

                if (_manualTask) then {
                    // Remove transient objectives from the indexes first so
                    // profile cleanup cannot reset them and emit a second,
                    // contradictory completion event.
                    _objectives deleteAt _objectiveIndex;
                    _objectivesByID deleteAt _objectiveID;
                    { [_logic,"resetProfileOrders", _x] call ALiVE_fnc_OPCOM } forEach (+_section);
                } else {
                    { [_logic,"resetProfileOrders", _x] call ALiVE_fnc_OPCOM } forEach (+_section);
                    [_logic,"resetObjective", _objectiveID] call ALiVE_fnc_OPCOM;

                    _objectives deleteAt _objectiveIndex;
                    _objectivesByID deleteAt _objectiveID;
                };
            };

            // clean up markers

            deleteMarker GET_OBJECTIVE_DEBUG_MARKER(_objectiveID);

            private _controlType = ([_logic, "controltype", ""] call ALiVE_fnc_HashGet); 
            if (_controlType == "asymmetric") then {
                {
                    deleteMarker _x;
                } forEach [
                    _objectiveID,
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

    case "reorderObjective": {
        if !(isServer) exitwith {[_logic,_operation,_args] remoteExec ["ALiVE_fnc_OPCOM",2]};

        _args params [
            ["_objectiveID", "", [""]],
            ["_newIndex", 0, [0]]
        ];

        private _objectives = [_logic,"objectives", []] call ALiVE_fnc_HashGet;
        private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_HashGet;
        private _objective = _objectivesByID get _objectiveID;
        private _objectiveIndex = if (isNil "_objective") then {
            -1
        } else {
            _objectives findIf { _x isEqualRef _objective }
        };

        if (_objectiveIndex != -1) then {
            _newIndex = 0 max _newIndex min (count _objectives - 1);

            // in-place move on the live array reference. Array position is the
            // commander's de-facto priority queue (selectordersbystate picks the
            // first match per state), and every async consumer resolves
            // objectives by ID or hash reference, so reordering is safe mid-run.
            //
            // INVOKE UNSCHEDULED ONLY: the deleteAt+insert is two statements, so a
            // scheduler yield between them would let an observer (an OPCOM analyze
            // pass) transiently see the array with this objective absent, skipping
            // it for one cycle. The current callers are all unscheduled; a future
            // scheduled caller must wrap this op or make the move atomic.
            private _movedObjective = _objectives deleteAt _objectiveIndex;
            _objectives insert [_newIndex, [_movedObjective]];
        };

        _result = _objectives;
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

    // A player's search-and-destroy or ambush order (NeisAEL on Discord, 17 Oct): the given groups are taken off the
    // commander's hands under a one-off objective, as addTask does, but given their orders here rather than through
    // TACOM, and handed back after _seconds (or when the objective has gone, the group dead).
    //   "sad":    to the place, then search and destroy within 150 m, weapons free, then stay there
    //   "ambush": to the place, then hide and hold fire (a hold that never completes on its own) until an enemy comes
    //             within 80 m or the group is already fighting, then fight
    // Both end in a hold that never completes, so the commander's sweep of finished orders doesn't hand the group back
    // early and turn the place into an ordinary objective. On hand-back the orders are cleared and the group set back
    // to its usual combat mode, so it doesn't sit there holding fire.
    case "addTimedTask": {
        _args params [["_type", "", [""]], ["_pos", [], [[]]], ["_section", [], [[]]], ["_seconds", 600, [0]]];
        if !(_type in ["sad", "ambush"]) exitWith {};
        if ((count _pos) < 2 || {_section isEqualTo []}) exitWith {};
        _section = (_section select {_x isEqualType ""}) arrayIntersect _section;

        private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_HashGet;
        private _manualTaskSequence = [_logic,"manualTaskSequence",0] call ALiVE_fnc_HashGet;
        private _manualObjectiveID = "";
        while {
            _manualTaskSequence = _manualTaskSequence + 1;
            _manualObjectiveID = format ["%1_manual_%2",[_logic,"opcomID","OPCOM"] call ALiVE_fnc_HashGet,_manualTaskSequence];
            !(isNil {_objectivesByID get _manualObjectiveID})
        } do {};
        [_logic,"manualTaskSequence",_manualTaskSequence] call ALiVE_fnc_HashSet;

        _objective = [_logic,"addObjective",[_manualObjectiveID,_pos,100,"internal",100,"internal"]] call ALiVE_fnc_OPCOM;
        [_objective,"manualTask",true] call ALiVE_fnc_HashSet;
        [_objective,"manualSince",time] call ALiVE_fnc_HashSet;
        // the commander now counts these groups as busy and leaves them alone
        [_logic,"setObjectiveSection",[_objective,_section]] call ALiVE_fnc_OPCOM;

        {
            private _profile = [ALIVE_profileHandler,"getProfile",_x] call ALIVE_fnc_profileHandler;
            if (!isNil "_profile") then {
                [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
                [_profile,"clearActiveCommands"] call ALIVE_fnc_profileEntity;
                private _approach = _pos getPos [random 30, random 360];
                [_profile,"addWaypoint",[_approach,15,"MOVE","NORMAL",30,[],"NO CHANGE","NO CHANGE","AWARE"] call ALIVE_fnc_createProfileWaypoint] call ALIVE_fnc_profileEntity;
                if (_type == "sad") then {
                    [_profile,"addWaypoint",[_pos,150,"SAD","NORMAL",50,[],"LINE","RED","COMBAT"] call ALIVE_fnc_createProfileWaypoint] call ALIVE_fnc_profileEntity;
                    private _stay = [_pos,50,"HOLD","NORMAL",10,[],"NO CHANGE","RED","COMBAT"] call ALIVE_fnc_createProfileWaypoint;
                    [_stay,"statements",["false",""]] call ALiVE_fnc_hashSet;
                    [_profile,"addWaypoint",_stay] call ALIVE_fnc_profileEntity;
                } else {
                    private _hold = [_approach,0,"HOLD","LIMITED",10,[],"NO CHANGE","GREEN","STEALTH"] call ALIVE_fnc_createProfileWaypoint;
                    // never completes by itself, spawned or virtual: the group stays put until handed back
                    [_hold,"statements",["false",""]] call ALiVE_fnc_hashSet;
                    [_profile,"addWaypoint",_hold] call ALIVE_fnc_profileEntity;
                };
            };
        } forEach _section;

        // handed back on the clock; an ambush is sprung by enemies coming close
        [_logic, _manualObjectiveID, _section, _type, _seconds] spawn {
            params ["_logic", "_id", "_section", "_type", "_seconds"];
            private _until = time + _seconds;
            while { time < _until && {!isNil {([_logic,"objectivesByID"] call ALiVE_fnc_HashGet) get _id}} } do {
                sleep 5;
                // checked every time: a group that despawns and spawns again comes back holding fire
                if (_type == "ambush") then {
                    {
                        private _profile = [ALIVE_profileHandler,"getProfile",_x] call ALIVE_fnc_profileHandler;
                        if (!isNil "_profile" && {_profile select 2 select 1}) then {
                            private _g = _profile select 2 select 13;
                            if (_g isEqualType grpNull && {!isNull _g} && {combatMode _g != "RED"}) then {
                                private _leader = leader _g;
                                // a parked vehicle has no side of its own: only men, or vehicles with a live crew
                                private _near = (_leader nearEntities [["CAManBase","LandVehicle"], 80]) findIf {
                                    alive _x && {_x isKindOf "CAManBase" || {(crew _x) findIf {alive _x} > -1}} && {(side _g getFriend side _x) < 0.6}
                                } > -1;
                                if (_near || {behaviour _leader == "COMBAT"}) then {
                                    // where the group lives, which can be a headless client
                                    [_g, "RED"] remoteExec ["setCombatMode", groupOwner _g];
                                    [_g, "COMBAT"] remoteExec ["setBehaviour", groupOwner _g];
                                };
                            };
                        };
                    } forEach _section;
                };
            };
            if (!isNil {([_logic,"objectivesByID"] call ALiVE_fnc_HashGet) get _id}) then {
                // as releaseOrder does: the never-ending hold would otherwise keep the group there for good
                {
                    private _profile = [ALIVE_profileHandler,"getProfile",_x] call ALIVE_fnc_profileHandler;
                    if (!isNil "_profile") then {
                        [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
                        [_profile,"clearActiveCommands"] call ALIVE_fnc_profileEntity;
                        private _g = _profile select 2 select 13;
                        if (_profile select 2 select 1 && {_g isEqualType grpNull} && {!isNull _g}) then {
                            [_g, "YELLOW"] remoteExec ["setCombatMode", groupOwner _g];
                            [_g, "AWARE"] remoteExec ["setBehaviour", groupOwner _g];
                            [_g, "NORMAL"] remoteExec ["setSpeedMode", groupOwner _g];
                        };
                    };
                } forEach _section;
                [_logic,"removeObjective",_id] call ALiVE_fnc_OPCOM;
            };
        };

        _result = _objective;
    };

    case "addTask": {
        _args params [
            ["_operation", "", [""]],
            ["_pos", [], [[]]],
            ["_section", [], [[]]]
        ];

        if !(_operation in ["recon","capture","defend","reserve"]) exitWith {
            ["OPCOM addTask ignored unsupported operation %1",_operation] call ALiVE_fnc_Dump;
        };
        if ((count _pos) < 2) exitWith {
            ["OPCOM addTask ignored invalid position %1",_pos] call ALiVE_fnc_Dump;
        };

        // Manual orders own exactly the supplied profile IDs. Invalid entries are
        // discarded and duplicate IDs are collapsed before the request is queued.
        _section = (_section select {_x isEqualType ""}) arrayIntersect _section;

        _TACOM_FSM = [_logic,"TACOM_FSM"] call ALiVE_fnc_HashGet;
        if (isNil "_TACOM_FSM" || {_TACOM_FSM <= 0} || {completedFSM _TACOM_FSM}) exitWith {
            ["OPCOM addTask ignored because TACOM is unavailable"] call ALiVE_fnc_Dump;
        };

        private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_HashGet;
        private _manualTaskSequence = [_logic,"manualTaskSequence",0] call ALiVE_fnc_HashGet;
        private _manualObjectiveID = "";
        while {
            _manualTaskSequence = _manualTaskSequence + 1;
            _manualObjectiveID = format ["%1_manual_%2",[_logic,"opcomID","OPCOM"] call ALiVE_fnc_HashGet,_manualTaskSequence];
            !(isNil {_objectivesByID get _manualObjectiveID})
        } do {};
        [_logic,"manualTaskSequence",_manualTaskSequence] call ALiVE_fnc_HashSet;

        _objective = [_logic,"addObjective",[_manualObjectiveID,_pos,100,"internal",100,"internal"]] call ALiVE_fnc_OPCOM;
        [_objective,"manualTask",true] call ALiVE_fnc_HashSet;
        // when it was given: empty until TACOM hands it its group, so cleanupduplicatesections waits before
        // taking one with no group left away
        [_objective,"manualSince",time] call ALiVE_fnc_HashSet;

        // The request is self-contained. TACOM assigns the supplied section only
        // when this FIFO entry reaches the head of its queue.
        private _tacomQueue = _TACOM_FSM getFSMVariable ["_TACOM_QUEUE",[]];
        _tacomQueue pushBack ["manual_order",[_operation,_objective,+_section]];
        _TACOM_FSM setFSMVariable ["_TACOM_QUEUE",_tacomQueue];

        _result = _objective;
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

        // Installation Types (#1081): every installation the commander creates comes through here
        if !([_logic, ["recruit", toLower _installationType] select (_installationType != "HQ")] call ALiVE_fnc_INS_typeAllowed) exitWith {
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

            // The nearest suitable building to the anchor that no objective uses; failing that, the nearest
            // one only this objective uses. Found nearest first, stopping at the first that passes, rather than
            // checking every building in the objective and sorting them (the same choice, far fewer checks).
            if (_target isEqualType objNull && {!isNull _target} && {alive _target} && {!(_target in _externallyUsedBuildings)} && {[_target] call ALiVE_fnc_INS_buildingSuitable}) then {
                _selectedTarget = _target;
            };

            if (isNull _selectedTarget) then {
                private _nearest = [_center, _size, 1, _anchorPos, _externallyUsedBuildings + _locallyUsedBuildings] call ALiVE_fnc_INS_filterObjectiveBuildings;
                if (_nearest isEqualTo []) then {
                    _nearest = [_center, _size, 1, _anchorPos, _externallyUsedBuildings] call ALiVE_fnc_INS_filterObjectiveBuildings;
                };
                if (_nearest isNotEqualTo []) then {
                    if (_useClosestBuilding || {(_anchorPos distance2D (_nearest select 0)) <= 15}) then {
                        _selectedTarget = _nearest select 0;
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
                            // All three have to hold, as in createRoadblock: with OR almost every road passed.
                            _candidateRoads = _candidateRoads select {
                                _x distance _spawnPos >= (_size - 10) && {isOnRoad _x} && {(str _x) find "invisible" == -1}
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
                        // player-designated objectives are session-only by design; a player FOB's
                        // objective is saved with the FOB and re-added by Player FOBs on load, so
                        // saving it here too would give the commander two of it after a restart
                        _objectivesGlobal = _objectivesGlobal + (([_x, "objectives",[]] call ALiVE_fnc_HashGet) select {!([_x,"playerCreated",false] call ALiVE_fnc_HashGet) && {!([_x,"manualTask",false] call ALiVE_fnc_HashGet)} && {([_x,"fobID",""] call ALiVE_fnc_HashGet) == ""}});
                    };
                } foreach OPCOM_INSTANCES;

                GVAR(OBJECTIVES_DB_SAVE) = [_objectivesGlobal,time];
                if (ALiVE_SYS_DATA_DEBUG_ON) then {
                    {
                        ["OPCOM - SAVE DATA Objective prepared for DB: %1",_x] call ALiVE_fnc_dump;
                    } foreach (GVAR(OBJECTIVES_DB_SAVE) select 0);
                };
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
            _missionName = ([""] call ALiVE_fnc_storeKeys) select 0; // group, mission and map

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

            // The high value target: who he is, whether he's still alive, and what's left of the
            // attack pause if he isn't
            private _hvtRecord = +([_logic,"hvtRecord",[]] call ALiVE_fnc_HashGet);
            if (_hvtRecord isNotEqualTo []) then {
                _hvtRecord set [3, ((([_logic,"module"] call ALiVE_fnc_HashGet) getVariable ["ALiVE_HVT_holdUntil", -1]) - time) max 0];
                private _key = format ["%1-OPCOM_%2-hvt", _missionName, [_logic, "opcomID"] call CBA_fnc_hashGet];
                private _prev = [GVAR(DATAHANDLER), "read", ["mil_opcom", [], _key]] call ALIVE_fnc_Data;
                private _data = [[["data", _hvtRecord]]] call CBA_fnc_hashCreate;
                if (_prev isEqualType []) then {
                    private _rev = [_prev, "_rev"] call CBA_fnc_hashGet;
                    if (!isNil {_rev}) then { [_data, "_rev", _rev] call CBA_fnc_hashSet };
                };
                [GVAR(DATAHANDLER), "write", ["mil_opcom", _data, false, _key]] call ALIVE_fnc_Data;
            };

            // the operation in hand: what's left of a pause after a capture and where, and the objectives whose
            // preparations are already done (written every save, so a finished pause isn't brought back)
            private _opKey = format ["%1-OPCOM_%2-opstate", _missionName, [_logic, "opcomID"] call CBA_fnc_hashGet];
            private _opPrev = [GVAR(DATAHANDLER), "read", ["mil_opcom", [], _opKey]] call ALIVE_fnc_Data;
            private _opData = [[["data", [_logic, "opState"] call MAINCLASS]]] call CBA_fnc_hashCreate;
            if (_opPrev isEqualType []) then {
                private _rev = [_opPrev, "_rev"] call CBA_fnc_hashGet;
                if (!isNil {_rev}) then { [_opData, "_rev", _rev] call CBA_fnc_hashSet };
            };
            [GVAR(DATAHANDLER), "write", ["mil_opcom", _opData, false, _opKey]] call ALIVE_fnc_Data;

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
        [_logic,"rebuildObjectiveIndexes"] call MAINCLASS;

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
            private _missionName = ([""] call ALiVE_fnc_storeKeys) select 0; // group, mission and map

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

                GVAR(OBJECTIVES_DB_LOAD) = [[GVAR(DATAHANDLER), "bulkLoad", ["mil_opcom", _missionName, _async]] call ALIVE_fnc_Data,time];

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
                    // Frontline Minefields (#979): the mines left in each field, so they are laid again
                    "minefield","minefieldLaid",
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
                [_logic,"rebuildObjectiveIndexes"] call MAINCLASS;
                [_logic,"clusteroccupation", []] call ALiVE_fnc_HashSet;
                [_logic,"clusteroccupationPrevious", []] call ALiVE_fnc_HashSet;

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
                        { [_logic,"resetProfileOrders", _x] call ALiVE_fnc_OPCOM } forEach (+_section);
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
                [_logic,"rebuildObjectiveIndexes"] call MAINCLASS;
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
                [_logic,"rebuildObjectiveIndexes"] call MAINCLASS;
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
        //
        // A statement, not an expression. This used to be _logic = if (...) then {...},
        // and a then-block's value is its last statement: here the "not found" check,
        // an if whose condition is false whenever a commander IS found, so it gave nil.
        // Every side or faction string therefore replaced the commander it had just
        // found with nil and left at the nil check below, adding nothing and saying
        // nothing. A side string still reaches only the first commander of that side.
        if (_logic isequaltype "") then {
            private _identifier = _logic;
            _logic = [nil,"findOPCOMByAllegiance", _identifier] call ALiVE_fnc_OPCOM;

            if (isnil  "_logic") then {
                ["OPCOM operation 'addObjective' didn't find an OPCOM for faction or side %1!", _identifier] call ALiVE_fnc_dump;
            };
        };

        // params turns a missing or nil _args into objNull, so isNil never caught it and
        // a call with no objective details added an empty one at the map's corner. The
        // test now asks for what the asserts below require.
        if (isnil "_logic" || {!(_args isequaltype [])} || {count _args < 3}) exitwith {};

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
            ["_opcomID", [_logic,"opcomID", ""] call ALiVE_fnc_HashGet, [""]],
            ["_playerCreated", false, [false]],
            ["_insertAtFront", false, [false]]
        ];

        // The same objective added again (same id, same place) hands back the one already there.
        // A script-added objective is saved with the commander's own, so a mission that adds it
        // at every start gave a persistent commander two under one id from its second session
        // on, and removeObjective only ever took out the indexed one. An id that is already in
        // use somewhere else is still added, as before, but now says so.
        private _existing = ([_logic,"objectivesByID"] call ALiVE_fnc_HashGet) get _id;
        if (!isNil "_existing" && {!([_existing,"deleted",false] call ALiVE_fnc_HashGet)}) then {
            private _there = [_existing,"center",[0,0,0]] call ALiVE_fnc_HashGet;
            if ((_there distance2D _pos) < 1) then {
                _result = _existing;
            } else {
                ["OPCOM operation 'addObjective': objective id %1 is already in use at %2, adding a second at %3 under the same id", _id, _there, _pos] call ALiVE_fnc_dump;
            };
        };
        if (!isNil "_result") exitwith {
            if (_debug) then {
                ["OPCOM operation 'addObjective': objective %1 is already there, keeping it", _id] call ALiVE_fnc_dump;
            };
        };

        // playerCreated must stay AFTER _rev. The FSMs read the objective value
        // array POSITIONALLY: objectiveID(0), center(1), size(2), objectiveType(3),
        // priority(4) and opcom_state(5) are all read by index in opcom.fsm/tacom.fsm.
        // NEVER reorder keys 0-9; only ever append new keys after _rev.
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
            ["_rev", ""],
            ["playerCreated", _playerCreated]
        ]] call ALIVE_fnc_hashCreate;

        if (_debug) then {
            [_logic,"createObjectiveDebugMarkers", [_objective]] call MAINCLASS;
        };

        private _objectives = [_logic,"objectives"] call ALiVE_fnc_HashGet;

        // hashGet returns the live array reference, so mutating in place is
        // visible to the FSMs without a HashSet. Front insertion puts the
        // objective first in its opcom_state bucket (selectordersbystate takes
        // the first array-order match), making it the commander's top priority.
        if (_insertAtFront) then {
            _objectives insert [0, [_objective]];
        } else {
            _objectives pushback _objective;
        };

        private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_HashGet;
        _objectivesByID set [_id,_objective];

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
        ASSERT_TRUE(_args isequaltype [] && {count _args >= 1},str _args);

        private ["_objectives","_state"];

        _args params ["_unit", ["_state","attacking"]];

        private _pos = getposATL _unit;
        private _faction = faction _unit;

        private _objectives = [_logic,"nearestObjectives", [_pos,_state]] call ALiVE_fnc_OPCOM;
        if (_objectives isequalto []) exitwith {};

        private _profilesById = [ALiVE_profileHandler,"profilesById"] call ALiVE_fnc_hashGet;
        {
            if !(isnil {_profilesById get _x}) exitwith {_result = _x}
        } foreach ([_objectives select 0,"section"] call ALiVE_fnc_HashGet);
    };

    case "joinObjectiveClient": {
        ASSERT_TRUE(typeName _args == "ARRAY",str _args);

        private ["_positions","_pos"];

        _args params [
            ["_unit", player, [objNull]],
            ["_objectives", [], [[]]],
            ["_color", "COLORYELLOW", [""]]
        ];

        // The pick is made on the machine of the unit asking. Asking where the unit is local,
        // not whether this machine has a screen, sends a client's request on from a
        // player-hosted server instead of opening the map for the host. The unit is read
        // first: the old check used _unit before these params, which only worked while the
        // caller's own _unit showed through, so a unit local to a dedicated server (an AI
        // soldier) sent the call back to the server, where _unit was undefined, without end.
        // Only the server forwards, since only there does owner name a machine.
        if (isNull _unit) exitwith {};
        if !(local _unit) exitwith {
            if (isServer) then {[_logic,_operation,_args] remoteExec ["ALiVE_fnc_OPCOM",owner _unit]};
        };
        if !(hasInterface) exitwith {};

        // Only run function if objectives are provided
        if (count _objectives == 0) exitwith {[localize "STR_ALIVE_OPCOM", "OPCOM currently has no assault objectives in his list!"] call ALIVE_fnc_sendHint};

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
        openmap true; [localize "STR_ALIVE_OPCOM", "Click on map to select objective!"] call ALIVE_fnc_sendHint;
        ALiVE_MIL_OPCOM_CLICKPOS = nil; onMapSingleclick "ALiVE_MIL_OPCOM_CLICKPOS = _pos; onMapSingleclick ''";
        waituntil {!isnil "ALiVE_MIL_OPCOM_CLICKPOS"}; _pos = ALiVE_MIL_OPCOM_CLICKPOS;
        ALiVE_MIL_OPCOM_CLICKPOS = nil; [localize "STR_ALIVE_OPCOM", "Objective selected! Please wait while OPCOM is preparing the operation..."] call ALIVE_fnc_sendHint;

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

        _section = ([_objective,"section",[]] call ALiVE_fnc_HashGet) - [_unit getvariable ["profileID",""]];
        if (count _section <= 0) then {_error = "OPCOM responds that the select section is destroyed!"};

        private _profilesById = [ALiVE_profileHandler,"profilesById"] call ALiVE_fnc_hashGet;

        _profile = _profilesById get (_section select 0);
        if (isnil "_profile") then {_error = "OPCOM reports that the assigned group is already dead!"};
        
        _profileUnit = _profilesById get (_unit getvariable ["profileID",""]);
        if (isnil "_profileUnit") then {_error = "OPCOM reports that players group cannot be assigned!"};

        if !(isnil "_error") exitwith {[localize "STR_ALIVE_OPCOM", _error] call ALIVE_fnc_sendHint; ["%1",_error] call ALiVE_fnc_Dump};

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

        private _occupationGrid = [ALiVE_profileSystem,"spacialGridProfiles"] call ALiVE_fnc_hashGet;

        private _friendlyObjectives = [];
        private _enemyObjectives = [];
        private _contestedObjectives = [];
        {
            private _objective = _x;

            private _id = [_objective,"objectiveID"] call ALiVE_fnc_HashGet;
            private _pos = [_objective,"center"] call ALiVE_fnc_HashGet;

            private _section = [_objective,"section", []] call ALiVE_fnc_HashGet;
            if (_section isequalto []) then {
                [_objective, [
                    ["opcom_state", "unassigned"],
                    ["opcom_orders", "none"],
                    ["danger", -1]
                ]] call ALiVE_fnc_hashSetMany;
            };

            private _candidates = _occupationGrid call ["findInRange", [_pos, 500, false, true, false]];
            private _nearFriendlies = [];
            private _nearEnemies = [];
            {
                private _values = _x select 2;
                if ((_values select 5) == "entity") then {
                    private _side = _values select 3;
                    private _friendly = _side in _sidesFriendly;
                    if ((_friendly || {_side in _sidesEnemy}) && {((_values select 2) distance _pos) <= 500}) then {
                        if (_friendly) then {
                            _nearFriendlies pushBack _x;
                        } else {
                            _nearEnemies pushBack _x;
                        };
                    };
                };
            } forEach _candidates;

            // A player's objective set to be taken or held (sup_command): taken once only the side's own are
            // there, so it settles like any held objective; until then, while nobody's on it, take is an attack.
            // Hold is an attack too while only the enemy is there (through the same caps and holds as any attack)
            // and a defence otherwise.
            private _intent = [_objective,"playerIntent",""] call ALiVE_fnc_HashGet;
            if (_intent != "") then {
                private _ownOnly = _nearFriendlies isnotequalto [] && {_nearEnemies isequalto []};
                private _enemyOnly = _nearFriendlies isequalto [] && {_nearEnemies isnotequalto []};
                if (_intent == "take" && {_ownOnly}) then {
                    [_objective,"playerIntent",""] call ALiVE_fnc_HashSet;
                } else {
                    if (_section isequalto []) then {
                        [_objective,"opcom_state", ["defend", "attack"] select (_intent == "take" || {_enemyOnly})] call ALiVE_fnc_HashSet;
                    };
                };
            };

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
        // the look before this one is kept as well: a place whose defenders were wiped out just before this look is
        // already the enemy's in it, and Military Logistics asks whether this side held a place another side has taken
        [_logic,"clusteroccupationPrevious", [_logic,"clusteroccupation", []] call ALiVE_fnc_HashGet] call ALiVE_fnc_HashSet;
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

        // Internal TACOM workers defer publication until their generation is accepted.
        private _publishResult = if (_args isEqualType []) then {_args param [0,true]} else {true};

        private _factions = [_logic,"factions",[]] call ALiVE_fnc_HashGet;

        private _controlledProfileIDs = [];
        {
            _controlledProfileIDs append ([ALiVE_ProfileHandler,"getProfilesByFaction",_x] call ALiVE_fnc_ProfileHandler);
        } foreach _factions;

        private _profilesById = [ALiVE_ProfileHandler,"profilesById"] call ALiVE_fnc_hashGet;

        private _knownEntities = [];
        {
            private _profile = _profilesById get _x;

            if (!isnil "_profile") then {
                private _pos = [_profile,"position"] call ALiVE_fnc_HashGet;
                private _nearEnemies = [_logic,"scanForNearEnemies", [_pos,true]] call MAINCLASS;

                {
                    _knownEntities pushbackunique _x;
                } foreach _nearEnemies;
            };
        } foreach _controlledProfileIDs;

        if (_publishResult) then {
            // remembered for Tasks Only Against Known Enemy: [id, last seen position, when], so what was spotted
            // stays known for a while after it goes out of sight, whether or not C2ISTAR shows intel. The C2ISTAR
            // module's own Tasks Only Against Known Enemy reads it too (ALIVE_fnc_taskKnownEnemy)
            if ([_logic, "opTasksKnownOnly", false] call ALiVE_fnc_HashGet || {missionNamespace getVariable ["ALiVE_c2istar_tasksKnownOnly", false]}) then {
                private _seen = [_logic, "knownSeen"] call ALiVE_fnc_HashGet;
                if (isNil "_seen") then { _seen = createHashMap; [_logic, "knownSeen", _seen] call ALiVE_fnc_HashSet };
                { _seen set [_x select 0, [_x select 1, time]] } forEach _knownEntities;
            };
            private _knownEntitiesIds = _knownEntities apply {_x select 0};
            [_logic,"createSpotrepForProfiles",_knownEntitiesIds] call MAINCLASS;
            [_logic,"knownentities",_knownEntities] call ALiVE_fnc_HashSet;
        };

        _result = _knownEntities;

    };

    case "scantroops";
    case "scanTroops" : {
        private ["_inf","_mot","_mech","_arm","_air","_sea","_profileIDs","_artilleryClasses","_AAA","_AAAClasses"];

        private _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;

        private _profileIDs = [];
        {
            _profileIDs append +([ALIVE_profileHandler,"getProfilesByFaction", _x] call ALIVE_fnc_profileHandler);
        } foreach _factions;

        private _inf = [];
        private _mot = [];
        private _AAA = [];
        private _arm = [];
        private _air = [];
        private _sea = [];
        private _mech = [];
        private _arty = [];

        if (isnil "_profileIDs" || {count _profileIDs == 0}) exitwith {
            [_logic, [
                ["infantry", _inf],
                ["motorized", _mot],
                ["mechanized", _mech],
                ["armored", _arm],
                ["artillery", _arty],
                ["AAA", _AAA],
                ["air", _air],
                ["sea", _sea],
                ["currentForceStrength", [0,0,0,0,0,0,0,0]]
            ]] call ALiVE_fnc_HashSetMany;

            _result = [_inf,_mot,_mech,_arm,_air,_sea,_arty,_AAA];
        };

        private _profilesById = [ALiVE_profileHandler,"profilesById"] call ALiVE_fnc_hashGet;

        private _playerProfileIDs = allPlayers apply { _x getVariable ["profileID", ""] };
        private _vehicleRoleCache = createHashMap;
        private _pilotClassCache = createHashMap;
        private _hasPilotClass = {
            params ["_classes"];
            private _hasPilot = (_classes findIf {
                private _cachedPilot = _pilotClassCache get _x;
                if (isNil "_cachedPilot") then {
                    _cachedPilot = [toLower _x, "pilot"] call CBA_fnc_find != -1;
                    _pilotClassCache set [_x, _cachedPilot];
                };
                _cachedPilot
            }) >= 0;
            _hasPilot
        };

        {
            private ["_profile","_assignments","_type","_objectType","_vehicleClass","_busy"];

            _profile = _profilesById get _x;

            if !(isnil "_profile") then {

                _type = [_profile,"type",""] call ALIVE_fnc_hashGet;
                _objectType = [_profile,"objectType",""] call ALIVE_fnc_hashGet;
                _vehicleClass = [_profile,"vehicleClass",""] call ALIVE_fnc_hashGet;

                switch (tolower _type) do {
                    case ("vehicle") : {
                        _assignments = [_profile,"entitiesInCommandOf",[]] call ALIVE_fnc_hashGet;

                        // A crew removed without freeing its vehicle left its ID here, and the ID was saved
                        // and loaded with the vehicle every session, so TACOM logged one more "NULL profile
                        // passed to FSM" each time (#1073). Drop such IDs from the vehicle itself, which also
                        // heals a campaign saved before this.
                        if ((_assignments findIf {isNil {_profilesById get _x}}) != -1) then {
                            private _vehicleAssignments = _profile select 2 select 7;
                            private _inCargoOf = [_profile,"entitiesInCargoOf",[]] call ALIVE_fnc_hashGet;
                            {
                                if (isNil {_profilesById get _x}) then {
                                    _assignments deleteAt (_assignments find _x);
                                    _inCargoOf deleteAt (_inCargoOf find _x);
                                    [_vehicleAssignments,_x,nil] call ALIVE_fnc_hashSet;
                                };
                            } forEach +_assignments;
                        };

                        if ((count (_assignments)) > 0) then {

                            // Dont collect vehicles with player profiles assigned
                            if ((_playerProfileIDs findIf {_x in _assignments}) >= 0) exitwith {};

                            // artillery and AA hold and fire regardless of
                            // chassis - wheeled launchers and SPGs (BM-21,
                            // DANA, CAESAR) carry objectType car/truck and
                            // must not be waypointed at the enemy as QRF
                            private _vehicleRoles = _vehicleRoleCache get _vehicleClass;
                            if (isNil "_vehicleRoles") then {
                                _vehicleRoles = [
                                    [_vehicleClass] call ALiVE_fnc_isArtillery,
                                    [_vehicleClass] call ALiVE_fnc_isAA
                                ];
                                _vehicleRoleCache set [_vehicleClass, _vehicleRoles];
                            };
                            if ((_vehicleRoles select 0) || {_vehicleRoles select 1}) exitwith {
                                if (_vehicleRoles select 0) then {{if !(_x in _arty) then {_arty pushback _x}} foreach _assignments};
                                if (_vehicleRoles select 1) then {{if !(_x in _AAA) then {_AAA pushback _x}} foreach _assignments};
                            };

                            switch (tolower _objectType) do {
                                case "car": {
                                    { _mot pushbackunique _x } foreach _assignments;
                                };
                                case "tank": {
                                    { _arm pushbackunique _x } foreach _assignments;
                                };
                                case "armored": {
                                    { _mech pushbackunique _x } foreach _assignments;
                                };
                                case "truck": {
                                    { _mot pushbackunique _x } foreach _assignments;
                                };
                                case "ship": {
                                    { _sea pushbackunique _x } foreach _assignments;
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
                            {!([_unitClasses] call _hasPilotClass)} && // no pilots in entity
                            {!(!isNil "ALIVE_profileStationary" && {[ALIVE_profileStationary, _x, false] call ALIVE_fnc_hashGet})} // not a held roadblock / stationary garrison
                            ) then {
                            _inf pushback _x;
                        };
                    };
                };
            };
        } foreach _profileIDs;

        [_logic, [
            ["infantry", _inf],
            ["motorized", _mot],
            ["mechanized", _mech],
            ["armored", _arm],
            ["artillery", _arty],
            ["AAA", _AAA],
            ["air", _air],
            ["sea", _sea]
        ]] call ALiVE_fnc_HashSetMany;

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
            [_logic,"startForceStrength", +_count] call ALiVE_fnc_HashSet
        };
        _currentForceStrength = [_logic,"currentForceStrength",_count] call ALiVE_fnc_HashSet;

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
    // Preparation tasks (The Horny Latino on Discord, 19 Oct): before an Invasion or Occupation commander (Occupation
    // from 22 Oct, A. Ares on Discord) attacks a new objective,
    // players on its side are given preparation tasks there, and the attack waits for them or the module's Preparation
    // Timeout, whichever comes first. One preparation at a time per commander. True when the attack may go ahead;
    // anything that stops a task being given (no players, no C2ISTAR, nobody there) means no wait at all.
    // 20 Oct: Fewest and Most Tasks per Operation set how many; besides the wiretap a task can be to destroy the AA and
    // mortar emplacements there, the enemy vehicles there, or an insurgent installation nearby, each only where there is
    // something to destroy; and the side is told on the radio when the preparations are asked for and when the assault
    // goes ahead.
    ///////////////////////////////////////////////////
    case "prepReady": {
        private _objective = _args;
        _result = true;
        if !([_logic, "prepTasks", false] call ALiVE_fnc_HashGet) exitWith {};
        // a conventional commander only: an insurgent one has no attacks to prepare
        if !(([_logic, "controltype", ""] call ALiVE_fnc_HashGet) in ["invasion", "occupation"]) exitWith {};
        private _module = [_logic, "module"] call ALiVE_fnc_HashGet;
        // no attack while a pause after a capture or a high value target hold is on, so nothing is prepared then
        // either: the preparation and its timeout would run out inside the hold
        if (time < (_module getVariable ["ALiVE_HVT_holdUntil", -1]) || {!([_logic, "occPauseOpen"] call ALiVE_fnc_OPCOM)}) exitWith { _result = false };
        private _objectiveID = [_objective, "objectiveID", ""] call ALiVE_fnc_HashGet;
        private _state = _module getVariable ["ALiVE_prep_state", ""];
        private _prepFor = _module getVariable ["ALiVE_prep_objectiveID", ""];
        // finished for this objective, either way: it goes ahead (kept per objective, as one is asked about both
        // before its recon and before its attack, with others' in between)
        private _cleared = _module getVariable ["ALiVE_prep_cleared", []];
        // Choice After Recon (Will501 on Discord, 22 Oct): once the recon has reported, players say whether they take
        // the targets themselves (the second round of tasks, as before) or hand them to the commander, which sends its
        // own units against what they found while they stay in overwatch. Their answer is only recorded (prepAnswer);
        // it is acted on here, in the commander's own pass. No answer by the Preparation Timeout counts as handing over
        private _prepEnd = {
            params ["_why", "_say"];
            private _pf = _module getVariable ["ALiVE_prep_objectiveID", ""];
            private _cl = _module getVariable ["ALiVE_prep_cleared", []];
            _cl pushBackUnique _pf;
            _module setVariable ["ALiVE_prep_cleared", _cl];
            _module setVariable ["ALiVE_prep_state", "done"];
            _module setVariable ["ALiVE_prep_choice", ""];
            [_logic, "prepFlag"] call ALiVE_fnc_OPCOM;
            ["OPCOM %1: the attack on %2 goes ahead (%3)", [_logic, "side", ""] call ALiVE_fnc_HashGet, _pf, _why] call ALiVE_fnc_dump;
            if (([_logic, "prepCancelTasks"] call ALiVE_fnc_OPCOM) > 0 && {_say != ""}) then { _say = _say + " Remaining preparation tasks are cancelled." };
            if (_say != "") then { [_logic, "opRadio", _say] call ALiVE_fnc_OPCOM };
        };
        // the recon's targets still worth sending anyone at (A. Ares on Discord, 22 Oct): a group with someone alive in
        // it, a vehicle or emplacement with a crew; a group wiped out is gone from the profiles altogether
        private _prepAlive = {
            (_module getVariable ["ALiVE_prep_choiceTargets", []]) select {
                private _p = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                if (isNil "_p") then { false } else {
                    if (([_p, "type", ""] call ALiVE_fnc_HashGet) == "vehicle") then {
                        ([_p, "entitiesInCommandOf", []] call ALiVE_fnc_HashGet) isNotEqualTo []
                    } else {
                        !([_p, "active", false] call ALiVE_fnc_HashGet) || {({alive _x} count units ([_p, "group", grpNull] call ALiVE_fnc_HashGet)) > 0}
                    }
                }
            }
        };
        // one step of a choice in hand; true while it still holds the attack
        private _prepChoiceStep = {
            private _c = _module getVariable ["ALiVE_prep_choice", ""];
            private _place = _module getVariable ["ALiVE_prep_place", "the objective"];
            private _late = _c == "pending" && {time > (_module getVariable ["ALiVE_prep_deadline", -1])};
            private _hold = false;
            if (_c == "pending" && {!_late}) then { _hold = true };
            if (_c == "hand" || {_late}) then {
                private _alive = call _prepAlive;
                if (_alive isEqualTo []) then {
                    ["handed over, nothing left", format ["Nothing left of the targets at %1. The assault goes ahead.", _place]] call _prepEnd;
                } else {
                    // up to 4 targets, each from the first pool with a free section in reach (motorized and armour
                    // reach 3 km, infantry and mechanized 1 km)
                    // one order per target (each raises a fire request where there is artillery), from the first pool
                    // with one of its sections in that pool's reach
                    private _sent = [];
                    private _pools = [_logic, ["infantry", "motorized", "mechanized", "armored"]] call ALiVE_fnc_hashGetMany;
                    private _mySide = [_logic, "side", "WEST"] call ALiVE_fnc_HashGet;
                    {
                        private _t = _x;
                        private _tp = [ALIVE_profileHandler, "getProfile", _t] call ALIVE_fnc_profileHandler;
                        if (count _sent < 4 && {!isNil "_tp"}) then {
                            private _tpos = [_tp, "position", [0,0,0]] call ALiVE_fnc_HashGet;
                            private _near = ([_tpos, 3000, [_mySide, "entity"]] call ALIVE_fnc_getNearProfiles) apply {
                                [[_x, "profileID", ""] call ALiVE_fnc_HashGet, ([_x, "position", [0,0,0]] call ALiVE_fnc_HashGet) distance _tpos]
                            };
                            private _type = "";
                            {
                                private _pool = _x;
                                private _reach = [1000, 3000, 1000, 3000] select _forEachIndex;
                                if (_type == "" && {!isNil "_pool"} && {_pool isEqualType []} && {(_near findIf { (_x select 1) < _reach && {(_x select 0) in _pool} }) >= 0}) then {
                                    _type = ["infantry", "motorized", "mechanized", "armored"] select _forEachIndex;
                                };
                            } forEach _pools;
                            if (_type != "") then {
                                private _g = [_logic, "attackEntity", [_t, 1, _type]] call ALiVE_fnc_OPCOM;
                                if (!isNil "_g" && {_g isEqualType []}) then { _sent append _g };
                            };
                        };
                    } forEach _alive;
                    if (_sent isEqualTo []) then {
                        ["handed over, no units free", format ["No units free to take the targets at %1. The assault goes ahead.", _place]] call _prepEnd;
                    } else {
                        // the main assault waits a while, so it doesn't take the same sections off their targets
                        _module setVariable ["ALiVE_prep_choice", "handed"];
                        _module setVariable ["ALiVE_prep_handedUntil", time + 300];
                        [_logic, "prepFlag"] call ALiVE_fnc_OPCOM;
                        ["OPCOM %1: %2 handed over (%3): %4 of %5 targets alive, sections %6 sent", [_logic, "side", ""] call ALiVE_fnc_HashGet,
                            _module getVariable ["ALiVE_prep_objectiveID", ""], ["by the players", "no answer"] select _late, count _alive,
                            count (_module getVariable ["ALiVE_prep_choiceTargets", []]), _sent] call ALiVE_fnc_dump;
                        private _who = [format ["%1 sections are", count _sent], "1 section is"] select (count _sent == 1);
                        [_logic, "opRadio", [
                            format ["Understood. %1 moving on the targets at %2. Stay in overwatch.", _who, _place],
                            format ["No answer from the recon at %1. The commander takes the targets itself: %2 moving in.", _place, toLower _who]
                        ] select _late] call ALiVE_fnc_OPCOM;
                        _hold = true;
                    };
                };
            };
            if (_c == "handed") then {
                private _alive = call _prepAlive;
                if (_alive isNotEqualTo [] && {time < (_module getVariable ["ALiVE_prep_handedUntil", -1])}) then { _hold = true } else {
                    ["handed over", [format ["The assault at %1 is going ahead.", _place],
                        format ["The targets at %1 are down. The assault is going ahead.", _place]] select (_alive isEqualTo [])] call _prepEnd;
                };
            };
            _hold
        };
        if (_objectiveID in _cleared || {_prepFor == _objectiveID && {_state in ["done", "expired"]}}) exitWith {};
        // one in hand for another objective holds this one back, so players get one at a time
        if (_state == "requested" && {_prepFor != _objectiveID}) exitWith {
            // a recon's choice in hand is settled first, through to its hand-over
            if ((_module getVariable ["ALiVE_prep_choice", ""]) in ["pending", "hand", "handed"]) exitWith { call _prepChoiceStep; _result = false };
            // unless that one has run out of time
            if (time <= (_module getVariable ["ALiVE_prep_deadline", -1])) then { _result = false } else {
                _module setVariable ["ALiVE_prep_state", "expired"];
                _cleared pushBackUnique _prepFor;
                _module setVariable ["ALiVE_prep_cleared", _cleared];
                ["OPCOM %1: the preparation for %2 ran out of time", [_logic, "side", ""] call ALiVE_fnc_HashGet, _prepFor] call ALiVE_fnc_dump;
                private _gone = ([_logic, "prepCancelTasks"] call ALiVE_fnc_OPCOM) > 0;
                [_logic, "opRadio", format ["Out of time at %1. The assault goes ahead without the preparations.%2", _module getVariable ["ALiVE_prep_place", "the objective"], ["", " Remaining preparation tasks are cancelled."] select _gone]] call ALiVE_fnc_OPCOM;
                _result = false;
            };
        };
        // Recon first (Javen on Discord, 22 Oct): with Tasks Only Against Known Enemy and nothing known, the players were
        // sent to reconnoitre. Once they have reported, a second round of tasks goes after what they found, inside the
        // same Preparation Timeout
        private _reconID = _module getVariable ["ALiVE_prep_reconID", ""];
        private _round2 = false;
        // (told by the recon's report, which names its task: the task's rows are deleted the moment it finishes)
        if (_state == "requested" && {_prepFor == _objectiveID} && {_reconID != ""} && {!(_module getVariable ["ALiVE_prep_round2Done", false])}
            && {time <= (_module getVariable ["ALiVE_prep_deadline", -1])}) then {
            _round2 = ((missionNamespace getVariable ["ALiVE_reconReports", []]) findIf { (_x param [5, ""]) == _reconID }) >= 0;
        };
        // Choice After Recon: the recon has reported, so the players are asked before any second round
        private _choiceRow = [];
        if (_round2) then {
            private _reports = missionNamespace getVariable ["ALiVE_reconReports", []];
            _choiceRow = _reports select (_reports findIf { (_x param [5, ""]) == _reconID });
        };
        // asked only when the recon found something to take or hand over
        if (_round2 && {[_logic, "prepChoice", false] call ALiVE_fnc_HashGet} && {(_module getVariable ["ALiVE_prep_choice", ""]) == ""}
            && {(_choiceRow param [3, []]) isNotEqualTo []}) then {
            private _row = _choiceRow;
            // the targets the players were told about, kept here (a report row is dropped after an hour)
            _module setVariable ["ALiVE_prep_choiceTargets", +(_row param [3, []])];
            _module setVariable ["ALiVE_prep_choice", "pending"];
            private _sideText = [_logic, "side", "WEST"] call ALiVE_fnc_HashGet;
            [_logic, "prepFlag"] call ALiVE_fnc_OPCOM;
            private _n = count (_row param [3, []]);
            ["OPCOM %1: the recon at %2 reported %3 targets, asking the players (choice pending)", _sideText, _objectiveID, _n] call ALiVE_fnc_dump;
            [_logic, "opRadio", format ["Recon at %1 is complete, %2 spotted. Take the targets yourselves, or hand them to the commander? Answer from the OPCOM Orders menu.",
                _module getVariable ["ALiVE_prep_place", "the objective"], [format ["%1 targets", _n], "1 target"] select (_n == 1)]] call ALiVE_fnc_OPCOM;
        };
        if (_state == "requested" && {_prepFor == _objectiveID} && {(_module getVariable ["ALiVE_prep_choice", ""]) in ["pending", "hand", "handed"]}) exitWith {
            _result = !(call _prepChoiceStep);
        };
        if (_state == "requested" && {!_round2}) exitWith {
            // every task asked for: one still open holds the attack; one C2ISTAR never made is given 2 minutes
            private _ids = _module getVariable ["ALiVE_prep_taskIDs", [_module getVariable ["ALiVE_prep_taskID", ""]]];
            private _all = ([ALiVE_TaskHandler, "tasks", ["", [], [], nil]] call ALiVE_fnc_HashGet) select 2;
            private _young = time - (_module getVariable ["ALiVE_prep_requestedAt", -1]) <= 120;
            private _open = 0; private _made = 0; private _won = 0;
            // a task's own (root) row says how it stands: its stages' rows are marked Succeeded as each ends, so the
            // first stage done used to count as the task done. A finished task's rows are deleted, so its outcome comes
            // from what C2ISTAR kept when it finished (F529)
            private _finished = missionNamespace getVariable ["ALiVE_c2istar_finishedTasks", createHashMap];
            {
                private _id = _x;
                private _root = _all select { (_x select 0) == _id };
                private _states = if (_root isNotEqualTo []) then { [(_root select 0) select 8] } else {
                    if (_id in _finished) then { [_finished get _id] } else { (_all select { ((_x select 0) find _id) == 0 }) apply { _x select 8 } }
                };
                // the recon is still watching while any of its OP stages is open (OP 1 is _c2, OP 2 _c3)
                if (_id == _reconID) then {
                    private _obs = (_all select { (_x select 0) in [_id + "_c2", _id + "_c3"] }) apply { _x select 8 };
                    if ((_obs findIf { !(_x in ["Succeeded", "Failed", "Canceled"]) }) >= 0) then { _states = ["Assigned"] };
                };
                if (_states isEqualTo []) then { if (_young) then { _open = _open + 1 } } else {
                    _made = _made + 1;
                    if ("Succeeded" in _states) then { _won = _won + 1 } else {
                        if ((_states findIf { !(_x in ["Failed", "Canceled"]) }) >= 0) then { _open = _open + 1 };
                    };
                };
            } forEach _ids;
            private _why = "";
            if (_open == 0) then { _why = ["no task made", ["failed", "done"] select (_won > 0)] select (_made > 0) };
            if (_why == "" && {time > (_module getVariable ["ALiVE_prep_deadline", -1])}) then { _why = "time up" };
            // two minutes before the deadline, tasks still open: HQ says so once, as what is unfinished then is
            // cancelled when the assault goes in (prepCancelTasks)
            private _deadline = _module getVariable ["ALiVE_prep_deadline", -1];
            if (_why == "" && {_open > 0} && {time > _deadline - 120} && {(_module getVariable ["ALiVE_prep_warned", -1]) != _deadline}) then {
                _module setVariable ["ALiVE_prep_warned", _deadline];
                [_logic, "opRadio", format ["Two minutes to the assault at %1. Finish what you can, Over.", _module getVariable ["ALiVE_prep_place", "the objective"]]] call ALiVE_fnc_OPCOM;
            };
            if (_why == "") exitWith { _result = false };
            _module setVariable ["ALiVE_prep_state", ["expired", "done"] select (_why == "done")];
            _cleared pushBackUnique _objectiveID;
            _module setVariable ["ALiVE_prep_cleared", _cleared];
            ["OPCOM %1: the attack on %2 goes ahead (preparation %3, %4 of %5 tasks done)", [_logic, "side", ""] call ALiVE_fnc_HashGet, _objectiveID, _why, _won, count _ids] call ALiVE_fnc_dump;
            private _place = _module getVariable ["ALiVE_prep_place", "the objective"];
            private _say = switch (_why) do {
                case "done": { format ["Preparations at %1 are complete. All units, the assault is going ahead.", _place] };
                case "time up": { format ["Out of time at %1. The assault goes ahead without the preparations.%2", _place, ["", " Remaining preparation tasks are cancelled."] select (([_logic, "prepCancelTasks"] call ALiVE_fnc_OPCOM) > 0)] };
                case "failed": { format ["The preparations at %1 have failed. The assault goes ahead regardless.", _place] };
                default { "" };
            };
            if (_say != "") then { [_logic, "opRadio", _say] call ALiVE_fnc_OPCOM };
        };
        // a new objective: ask for the tasks
        private _side = [_logic, "side", "WEST"] call ALiVE_fnc_HashGet;
        // Preparation Tasks How Often: only some attacks get them; one that doesn't goes ahead as usual
        if (random 1 >= ([_logic, "prepOften", 1] call ALiVE_fnc_HashGet)) exitWith {
            _cleared pushBackUnique _objectiveID;
            _module setVariable ["ALiVE_prep_cleared", _cleared];
            ["OPCOM %1: no preparation tasks for %2 this time (Preparation Tasks How Often), the attack goes ahead", _side, _objectiveID] call ALiVE_fnc_dump;
        };
        private _players = [_logic, "prepTestPlayers", []] call ALiVE_fnc_HashGet;      // a test sets this; empty in play
        if (_players isEqualTo []) then {
            private _p = [_side] call ALiVE_fnc_getPlayersDataSource;
            _players = [_p select 1, _p select 0];
            // a group that opted out of automatic orders (OPCOM Orders menu) gets no preparation tasks either
            // (Will501 on Discord, 23 Oct)
            private _keep = [];
            {
                private _uid = _x;
                private _i = allPlayers findIf { getPlayerUID _x == _uid };
                if (_i < 0 || {!((group (allPlayers select _i)) getVariable ["ALiVE_mil_c2istar_playerOrdersOptOut", false])}) then { _keep pushBack _forEachIndex };
            } forEach (_players select 0);
            _players = [_keep apply { (_players select 0) select _x }, _keep apply { (_players select 1) select _x }];
        };
        private _center = [_objective, "center", [0,0,0]] call ALiVE_fnc_HashGet;
        private _sidesEnemy = [_logic, "sidesenemy", []] call ALiVE_fnc_HashGet;
        // the faction holding the objective, from the enemy groups within 500 m
        private _enemyFaction = "";
        {
            private _near = [_center, 500, [_x, "entity"]] call ALIVE_fnc_getNearProfiles;
            if (_enemyFaction == "" && {_near isNotEqualTo []}) then { _enemyFaction = [_near select 0, "faction", ""] call ALiVE_fnc_HashGet };
        } forEach _sidesEnemy;
        if (isNil "ALIVE_MIL_C2ISTAR" || {isNil "ALiVE_TaskHandler"} || {isNil "ALIVE_eventLog"} || {(_players select 0) isEqualTo []}
            || {!(missionNamespace getVariable ["ALiVE_c2istar_autoPlayerTasks", true])} || {_enemyFaction == ""}) exitWith {
            // nobody to give it to: the attack goes ahead, and the objective is asked about again once players are on;
            // nobody holding it: no task to set, ever. In the middle of a preparation (a recon's second round) it keeps
            // waiting for the tasks already out, and the round is tried again on a later check
            if (_round2) exitWith { _result = false };
            if (_enemyFaction == "") then {
                _cleared pushBackUnique _objectiveID;
                _module setVariable ["ALiVE_prep_cleared", _cleared];
                ["OPCOM %1: no preparation task for %2 (no enemy groups there), the attack goes ahead", _side, _objectiveID] call ALiVE_fnc_dump;
            };
        };
        // what there is to do there, the wiretap always: a comms building at the objective if there is one (matched by
        // model, as C2ISTAR's own index does); with none, the task puts up its own comms site
        private _radius = ([_objective, "size", 150] call ALiVE_fnc_HashGet) max 300;
        private _comms = (missionNamespace getVariable ["ALIVE_civilianCommsBuildingTypes", []]) apply { toLower _x };
        private _building = objNull;
        if (_comms isNotEqualTo []) then {
            {
                private _m = toLower ((getModelInfo _x) select 1);
                if (alive _x && {(_comms findIf { (_m find _x) > -1 }) > -1}) exitWith { _building = _x };
            } forEach (nearestObjects [_center, ["House", "Building"], ([_objective, "size", 150] call ALiVE_fnc_HashGet) max 150]);
        };
        private _kinds = [["Wiretap", [_building]]];
        // the enemy's vehicles there: AA and mortar emplacements (static AA, mortars, and AA vehicles) apart from the rest;
        // up to 3 of each, aircraft and boats left out
        private _empl = [];
        private _vehs = [];
        // Tasks Only Against Known Enemy: only the vehicles whose crews this commander has spotted
        private _knownOnly = [_logic, "opTasksKnownOnly", false] call ALiVE_fnc_HashGet;
        private _known = if (_knownOnly) then { [_logic, "knownEnemy"] call ALiVE_fnc_OPCOM } else { [[], []] };
        {
            {
                private _cls = [_x, "vehicleClass", ""] call ALiVE_fnc_HashGet;
                private _id = [_x, "profileID", ""] call ALiVE_fnc_HashGet;
                if (_cls != "" && {_id != ""} && {!(_cls isKindOf "Air")} && {!(_cls isKindOf "Ship")}
                    && {!_knownOnly || {[_logic, "knownVehicle", [_x, _known]] call ALiVE_fnc_OPCOM}}) then {
                    if (_cls isKindOf "StaticMortar" || {_cls isKindOf "StaticAAWeapon"}
                        || {getText (configFile >> "CfgVehicles" >> _cls >> "editorSubcategory") == "EdSubcat_AAs"}) then {
                        if (count _empl < 3) then { _empl pushBack _id };
                    } else {
                        if (count _vehs < 3 && {!(_cls isKindOf "StaticWeapon")}) then { _vehs pushBack _id };
                    };
                };
            } forEach ([_center, _radius, [_x, "vehicle"]] call ALIVE_fnc_getNearProfiles);
        } forEach _sidesEnemy;
        if (_empl isNotEqualTo []) then { _kinds pushBack ["DestroyVehicles", _empl, "AA and mortar emplacements"] };
        if (_vehs isNotEqualTo []) then { _kinds pushBack ["DestroyVehicles", _vehs, "enemy vehicles"] };
        // an insurgent installation within 2 km (recruitment HQ, arms cache or IED factory)
        if (!isNil "ALIVE_fnc_taskGetInsurgencyLocation") then {
            private _found = false;
            // with Tasks Only Against Known Enemy, only the side holding the objective: the task looks for that side's
            // nearest installation, so that's the one that has to be known
            private _insSides = _sidesEnemy;
            if (_knownOnly) then { _insSides = [[[(_enemyFaction call ALiVE_fnc_factionSide)] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText] };
            {
                private _ins = [_center, "Map", _x] call ALIVE_fnc_taskGetInsurgencyLocation;
                if (!_found && {_ins isEqualType []} && {count _ins > 1} && {(_ins select 1) isEqualType []} && {count (_ins select 1) >= 2}
                    && {((_ins select 1) distance2D _center) < 2000}
                    && {!_knownOnly || {[_logic, "knownPlace", [_ins select 1, _known]] call ALiVE_fnc_OPCOM}}) then { _found = true };
            } forEach _insSides;
            if (_found) then { _kinds pushBack ["InsurgencyDestroyAssets", [], "insurgent installation"] };
        };
        // the second round, after a recon: only what it has made known, every kind of it
        if (_round2) exitWith {
            _module setVariable ["ALiVE_prep_round2Done", true];
            private _more = _kinds select { !((_x select 0) in ["Wiretap", "ReconObjective"]) };
            private _place2 = _module getVariable ["ALiVE_prep_place", "the objective"];
            if (_more isEqualTo []) exitWith {
                ["OPCOM %1: the recon at %2 found nothing to add to the preparations", _side, _objectiveID] call ALiVE_fnc_dump;
                [_logic, "opRadio", format ["Recon at %1 is complete. Nothing there for further preparations.", _place2]] call ALiVE_fnc_OPCOM;
                _result = false;
            };
            private _faction2 = ([_logic, "factions", [""]] call ALiVE_fnc_HashGet) param [0, ""];
            private _ids2 = _module getVariable ["ALiVE_prep_taskIDs", []];
            {
                _x params ["_type", "_extra"];
                private _taskID = format ["PREP_%1_%2_r%3", _objectiveID, floor time, _forEachIndex];
                private _taskData = [_taskID, "OPCOM", _side, _faction2, _type, "Map", +_center, _players, _enemyFaction, "Y", "Side"];
                if (_extra isNotEqualTo []) then { _taskData pushBack _extra };
                [ALIVE_eventLog, "addEvent", ["TASK_GENERATE", _taskData, "OPCOM"] call ALIVE_fnc_event] call ALIVE_fnc_eventLog;
                _ids2 pushBack _taskID;
            } forEach _more;
            _module setVariable ["ALiVE_prep_taskIDs", _ids2];
            _module setVariable ["ALiVE_prep_requestedAt", time];
            ["OPCOM %1: the recon at %2 found %3; tasks added", _side, _objectiveID, _more apply { _x param [2, _x select 0] }] call ALiVE_fnc_dump;
            [_logic, "opRadio", format ["Recon at %1 is complete. %2 issued against what it found.", _place2,
                [format ["%1 more tasks", count _more], "1 more task"] select (count _more == 1)]] call ALiVE_fnc_OPCOM;
            _result = false;
        };
        // how many: 0 and 0 keep the wiretap alone; otherwise between the fewest and the most, no more than there are kinds
        private _lo = [_logic, "opTasksMin", 0] call ALiVE_fnc_HashGet;
        private _hi = [_logic, "opTasksMax", 0] call ALiVE_fnc_HashGet;
        private _chosen = [_kinds select 0];
        if (_lo > 0 || {_hi > 0}) then {
            if (_hi < _lo) then { _hi = _lo };
            private _n = ((_lo + floor random (_hi - _lo + 1)) max 1) min (count _kinds);
            _chosen = (_kinds call BIS_fnc_arrayShuffle) select [0, _n];
        };
        // Recon first (Javen on Discord, 22 Oct): with Tasks Only Against Known Enemy and nothing known there, the players
        // are sent to reconnoitre it as well, whatever Fewest and Most say, and what they report brings a second round
        _module setVariable ["ALiVE_prep_reconID", ""];
        _module setVariable ["ALiVE_prep_round2Done", false];
        _module setVariable ["ALiVE_prep_choice", ""];
        _module setVariable ["ALiVE_prep_choiceTargets", []];
        private _reconKind = [];
        if (_knownOnly && {count _kinds == 1} && {!isNil "ALIVE_fnc_taskReconObjective"}) then {
            _reconKind = ["ReconObjective", [], "reconnaissance"];
            _chosen = [_reconKind] + _chosen;
        };
        private _faction = ([_logic, "factions", [""]] call ALiVE_fnc_HashGet) param [0, ""];
        private _ids = [];
        {
            _x params ["_type", "_extra"];
            private _taskID = format ["PREP_%1_%2_%3", _objectiveID, floor time, _forEachIndex];
            private _taskData = [_taskID, "OPCOM", _side, _faction, _type, "Map", +_center, _players, _enemyFaction, "Y", "Side"];
            if (_extra isNotEqualTo []) then { _taskData pushBack _extra };
            [ALIVE_eventLog, "addEvent", ["TASK_GENERATE", _taskData, "OPCOM"] call ALIVE_fnc_event] call ALIVE_fnc_eventLog;
            _ids pushBack _taskID;
            if (_x isEqualTo _reconKind) then { _module setVariable ["ALiVE_prep_reconID", _taskID] };
        } forEach _chosen;
        private _place = [_center] call ALIVE_fnc_taskGetNearestLocationName;
        if (isNil "_place" || {!(_place isEqualType "")} || {_place == ""}) then { _place = "grid " + mapGridPosition _center };
        _module setVariable ["ALiVE_prep_objectiveID", _objectiveID];
        _module setVariable ["ALiVE_prep_taskIDs", _ids];
        _module setVariable ["ALiVE_prep_taskID", _ids select 0];
        _module setVariable ["ALiVE_prep_place", _place];
        _module setVariable ["ALiVE_prep_requestedAt", time];
        _module setVariable ["ALiVE_prep_deadline", time + ([_logic, "prepTimeout", 900] call ALiVE_fnc_HashGet)];
        _module setVariable ["ALiVE_prep_state", "requested"];
        ["OPCOM %1: the attack on %2 waits for %3 at %4", _side, _objectiveID, _chosen apply { _x param [2, _x select 0] }, mapGridPosition _center] call ALiVE_fnc_dump;
        [_logic, "opRadio", format ["The operation at %1 is not ready until the preparations are complete. %2 issued.", _place,
            [format ["%1 tasks", count _ids], "1 task"] select (count _ids == 1)]] call ALiVE_fnc_OPCOM;
        _result = false;
    };

    // Choice After Recon: whether any commander on this side is waiting for the players' answer, published for the
    // OPCOM Orders menu (one flag per side, so it stays up while any of them is still waiting)
    case "prepFlag": {
        private _sideText = [_logic, "side", "WEST"] call ALiVE_fnc_HashGet;
        private _any = (missionNamespace getVariable ["OPCOM_instances", []]) findIf {
            private _m = [_x, "module"] call ALiVE_fnc_HashGet;
            ([_x, "side", ""] call ALiVE_fnc_HashGet) == _sideText && {!isNil "_m"} && {(_m getVariable ["ALiVE_prep_choice", ""]) == "pending"}
        };
        missionNamespace setVariable [format ["ALiVE_prep_choicePending_%1", _sideText], _any >= 0, true];
        _result = _any >= 0;
    };

    // The attack goes ahead before every preparation task is done (A. Ares on Discord, 23 Oct: a Wiretap stayed open
    // after the assault went in): each still open is taken off the task handler as a player's cancelled order is
    // (locks released, rows and markers gone), and its players get one "Task cancelled" popup for it, not one per
    // stage. HQ warns two minutes before (prepReady). Returns how many were cancelled
    case "prepCancelTasks": {
        private _module = [_logic, "module"] call ALiVE_fnc_HashGet;
        _result = 0;
        if (isNil "_module" || {isNil "ALiVE_TaskHandler"}) exitWith {};
        private _ids = _module getVariable ["ALiVE_prep_taskIDs", []];
        private _all = ([ALiVE_TaskHandler, "tasks", ["", [], [], nil]] call ALiVE_fnc_HashGet) select 2;
        private _managed = [ALiVE_TaskHandler, "managedTaskParams", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_HashGet;
        {
            private _id = _x;
            private _root = _all select { (_x select 0) == _id };
            if (_root isNotEqualTo [] && {!(((_root select 0) select 8) in ["Succeeded", "Failed", "Canceled"])}) then {
                private _row = +(_root select 0);
                // a Wiretap's "Setup Wiretap" action stays on its building otherwise, and finishing it would announce
                // a wiretap with no task behind it: marked done, which hides the action everywhere
                if ("Wiretap" in (_row param [12, ""]) && {_id in (_managed select 1)}) then {
                    private _tp = [_managed, _id] call ALiVE_fnc_hashGet;
                    { if (_x isEqualType objNull && {!isNull _x}) then { _x setVariable ["ALiVE_Task_Wiretapped", true, true] } } forEach ([_tp, "targets", []] call ALiVE_fnc_hashGet);
                };
                {
                    private _p = [_x] call ALIVE_fnc_getPlayerByUID;
                    if (!isNull _p) then { ["TaskCanceled", ["", _row select 5]] remoteExecCall ["BIS_fnc_showNotification", _p] };
                } forEach ((_row select 7) param [0, []]);
                private _event = ["TASK_DELETE", [_id, _row select 1, _row select 2], "OPCOM"] call ALiVE_fnc_event;
                [ALIVE_eventLog, "addEvent", _event] call ALiVE_fnc_eventLog;
                _result = _result + 1;
            };
        } forEach _ids;
        _module setVariable ["ALiVE_prep_taskIDs", []];
        if (_result > 0) then {
            ["OPCOM %1: preparation for %2 over, %3 tasks cancelled", [_logic, "side", ""] call ALiVE_fnc_HashGet, _module getVariable ["ALiVE_prep_objectiveID", ""], _result] call ALiVE_fnc_dump;
        };
    };

    // Choice After Recon: a player's answer, "take" or "hand", only recorded while one is asked for; prepReady acts on
    // it in the commander's own pass. True when it was taken
    case "prepAnswer": {
        private _module = [_logic, "module"] call ALiVE_fnc_HashGet;
        _result = false;
        if (!isNil "_module" && {_args in ["take", "hand"]} && {(_module getVariable ["ALiVE_prep_choice", ""]) == "pending"}) then {
            _module setVariable ["ALiVE_prep_choice", _args];
            [_logic, "prepFlag"] call ALiVE_fnc_OPCOM;
            ["OPCOM %1: the players answered %2 for %3", [_logic, "side", ""] call ALiVE_fnc_HashGet, _args, _module getVariable ["ALiVE_prep_objectiveID", ""]] call ALiVE_fnc_dump;
            _result = true;
        };
    };

    // What this commander knows of the enemy (A. Ares on Discord, 21 Oct), for Tasks Only Against Known Enemy:
    // [entity profile IDs, their last known positions], from what its units have seen in the last 30 minutes, its spot
    // reports (when C2ISTAR shows intel) and the groups its units can see now
    case "knownEnemy": {
        private _ids = [];
        private _pos = [];
        private _seen = [_logic, "knownSeen"] call ALiVE_fnc_HashGet;
        if (!isNil "_seen") then {
            {
                if (time - (_y select 1) > 1800) then { _seen deleteAt _x } else { _ids pushBack _x; _pos pushBack (_y select 0) };
            } forEach +_seen;
        };
        private _G2 = [_logic, "G2"] call ALiVE_fnc_HashGet;
        if (!isNil "_G2") then {
            private _reports = _G2 getVariable ["spotrepsByProfileID", createHashMap];
            {
                if !(_x in _ids) then {
                    _ids pushBack _x;
                    _pos pushBack (_y getOrDefault ["position", [0,0,0]]);
                };
            } forEach _reports;
        };
        {
            if (_x isEqualType [] && {count _x > 1} && {!((_x select 0) in _ids)}) then {
                _ids pushBack (_x select 0);
                _pos pushBack (_x select 1);
            };
        } forEach ([_logic, "knownentities", []] call ALiVE_fnc_HashGet);
        // and what players reported from a reconnaissance task (ALIVE_fnc_taskReconObjective): [side, position, time,
        // group ids, group positions], for this side, in the last 30 minutes
        private _mySide = [_logic, "side", "WEST"] call ALiVE_fnc_HashGet;
        {
            _x params ["_rSide", "", "_rTime", ["_rIds", []], ["_rPos", []]];
            if (_rSide == _mySide && {time - _rTime <= 1800}) then {
                { if !(_x in _ids) then { _ids pushBack _x; _pos pushBack (_rPos param [_forEachIndex, [0,0,0]]) } } forEach _rIds;
            };
        } forEach (missionNamespace getVariable ["ALiVE_reconReports", []]);
        _result = [_ids, _pos];
    };

    // What players tell this commander (A. Ares on Discord, 23 Oct): [entity profile IDs, their positions, the places
    // reported] from a spot report, a prisoner's or a civilian's answer, remembered as if its own units had seen them
    // (ALIVE_fnc_taskKnownEnemy "report"). Each place is kept too, under a key no profile has, so a hideout or a parked
    // vehicle reported with no group beside it still counts as known (knownPlace, knownVehicle). Known for the next 30
    // minutes, like the rest of "knownEnemy"; older entries are dropped here as well
    case "reportSeen": {
        _args params [["_ids", [], [[]]], ["_poss", [], [[]]], ["_places", [], [[]]]];
        private _seen = [_logic, "knownSeen"] call ALiVE_fnc_HashGet;
        if (isNil "_seen") then { _seen = createHashMap; [_logic, "knownSeen", _seen] call ALiVE_fnc_HashSet };
        { if (time - (_y select 1) > 1800) then { _seen deleteAt _x } } forEach +_seen;
        { if (_x isEqualType "") then { _seen set [_x, [_poss param [_forEachIndex, [0,0,0]], time]] } } forEach _ids;
        { if (_x isEqualType [] && {count _x > 1}) then { _seen set [format ["report_%1_%2", round (_x select 0), round (_x select 1)], [_x, time]] } } forEach _places;
        _result = count _ids;
    };

    // [vehicle profile, knownEnemy's answer]: true when a group crewing it has been seen, or it stands within 100 m of
    // where a seen group was (they saw the gun, not just the gunners: an empty or uncrewed one too)
    case "knownVehicle": {
        _args params ["_vehicle", "_known"];
        private _crew = [_vehicle, "entitiesInCommandOf", []] call ALiVE_fnc_HashGet;
        _result = (_crew findIf { _x in (_known select 0) }) > -1;
        if (!_result) then {
            private _vp = [_vehicle, "position", []] call ALiVE_fnc_HashGet;
            if (_vp isEqualType [] && {count _vp > 1}) then {
                _result = ((_known select 1) findIf { _x isEqualType [] && {count _x > 1} && {(_x distance2D _vp) < 100} }) > -1;
            };
        };
    };

    // [position, knownEnemy's answer]: true when the commander can know what is at a place: a spotted enemy group was
    // last seen within 300 m of it, or one of its own groups is within 500 m (as close as its units see, scanning)
    case "knownPlace": {
        _args params ["_place", "_known"];
        _result = ((_known select 1) findIf { _x isEqualType [] && {count _x > 1} && {(_x distance2D _place) < 300} }) > -1;
        if (!_result) then {
            _result = ([_place, 500, [[_logic, "side", "WEST"] call ALiVE_fnc_HashGet, "entity"]] call ALIVE_fnc_getNearProfiles) isNotEqualTo [];
        };
    };

    // a radio call to the commander's side from its HQ (The Horny Latino on Discord, 20 Oct); the last one sent is kept
    // on the module for tests
    case "opRadio": {
        private _text = _args;
        if (!(_text isEqualType "") || {_text == ""}) exitWith {};
        private _side = [_logic, "side", "WEST"] call ALiVE_fnc_HashGet;
        ([_logic, "module"] call ALiVE_fnc_HashGet) setVariable ["ALiVE_op_lastRadio", _text];
        if (isNil "ALIVE_fnc_radioBroadcastToSide") exitWith {};
        [_side, [objNull, _text, "side", [_side] call ALiVE_fnc_sideTextToObject, false, false, false, true, "HQ"]] call ALIVE_fnc_radioBroadcastToSide;
    };

    ///////////////////////////////////////////////////
    // Occupation pause (The Horny Latino on Discord, 19 Oct): after a capture the commander holds new attacks for the
    // module's Pause After Capture and gives players clean-up or hearts-and-minds tasks round the place it took. It moves
    // on when those tasks are all closed or the timer runs out, whichever comes first; with no tasks the timer governs.
    // Defence, reserve and reinforcement go on as usual.
    ///////////////////////////////////////////////////
    case "occPauseStart": {
        // [objective, seconds left] when a saved pause is resumed after a load; the objective alone otherwise
        private _objective = _args;
        private _left = -1;
        if (_args isEqualType [] && {count _args == 2} && {(_args select 1) isEqualType 0}) then { _objective = _args select 0; _left = _args select 1 };
        private _mins = [_logic,"occPauseMins",0] call ALiVE_fnc_HashGet;
        if (!(_mins isEqualType 0) || {_mins <= 0} || {([_logic,"controltype",""] call ALiVE_fnc_HashGet) != "occupation"}) exitWith {};
        private _module = [_logic,"module"] call ALiVE_fnc_HashGet;
        private _sideText = [_logic,"side","WEST"] call ALiVE_fnc_HashGet;
        // a second capture while paused extends the hold rather than starting it again
        _module setVariable ["ALiVE_Occ_holdUntil", (time + ([_mins * 60, _left] select (_left > 0))) max (_module getVariable ["ALiVE_Occ_holdUntil", -1])];
        _module setVariable ["ALiVE_Occ_raisedAt", time];
        _module setVariable ["ALiVE_Occ_objectiveID", [_objective,"objectiveID",""] call ALiVE_fnc_HashGet];
        private _center = [_objective,"center",[0,0,0]] call ALiVE_fnc_HashGet;
        private _objID = [_objective,"objectiveID","obj"] call ALiVE_fnc_HashGet;
        private _civ = ([_objective,"objectiveType","MIL"] call ALiVE_fnc_HashGet) in ["CIV","CCU"];
        private _types = [["RemoveIED","DestroyVehicles"],["AidDelivery","MeetLocalLeader"]] select _civ;
        if (_civ) then {
            // only the civic families the mission left switched on
            // (unset when C2ISTAR hasn't said: no filter; set and empty means the mission switched them all off)
            if (!isNil "ALIVE_civicEnabledTaskFamilies") then {
                private _families = ALIVE_civicEnabledTaskFamilies apply { toUpper _x };
                _types = _types select { (toUpper _x) in _families };
            };
        };
        // Tasks Only Against Known Enemy (A. Ares on Discord, 21 Oct): the vehicles to destroy are the spotted ones round
        // the objective, up to 3, and with none that task isn't given (left to itself it picks the nearest enemy vehicle,
        // seen or not). Removing IEDs is left out: its IED is the nearest one the IED module placed, which nobody has seen.
        // Before the Fewest and Most pick, so it chooses among what can be given
        private _knownVehs = [];
        if ([_logic, "opTasksKnownOnly", false] call ALiVE_fnc_HashGet) then {
            private _known = [_logic, "knownEnemy"] call ALiVE_fnc_OPCOM;
            private _radius = ([_objective, "size", 150] call ALiVE_fnc_HashGet) max 300;
            {
                {
                    private _id = [_x, "profileID", ""] call ALiVE_fnc_HashGet;
                    private _cls = [_x, "vehicleClass", ""] call ALiVE_fnc_HashGet;
                    if (count _knownVehs < 3 && {_id != ""} && {!(_cls isKindOf "Air")} && {!(_cls isKindOf "Ship")}
                        && {[_logic, "knownVehicle", [_x, _known]] call ALiVE_fnc_OPCOM}) then { _knownVehs pushBack _id };
                } forEach ([_center, _radius, [_x, "vehicle"]] call ALIVE_fnc_getNearProfiles);
            } forEach ([_logic, "sidesenemy", []] call ALiVE_fnc_HashGet);
            _types = _types - ["RemoveIED"];
            if (_knownVehs isEqualTo []) then { _types = _types - ["DestroyVehicles"] };
        };
        // Fewest and Most Tasks per Operation pick how many of them (0 and 0: all of them)
        private _lo = [_logic, "opTasksMin", 0] call ALiVE_fnc_HashGet;
        private _hi = [_logic, "opTasksMax", 0] call ALiVE_fnc_HashGet;
        if ((_lo > 0 || {_hi > 0}) && {_types isNotEqualTo []}) then {
            if (_hi < _lo) then { _hi = _lo };
            _types = (_types call BIS_fnc_arrayShuffle) select [0, ((_lo + floor random (_hi - _lo + 1)) max 1) min (count _types)];
        };
        // a test's stand-in players ([ids, names], as for the preparation tasks); in play, the side's own
        private _tp = [_logic, "prepTestPlayers", []] call ALiVE_fnc_HashGet;
        private _players = if (_tp isEqualTo []) then { [_sideText] call ALiVE_fnc_getPlayersDataSource } else { [_tp select 1, _tp select 0] };
        // this capture's own tasks only: one left open from a pause the timer ended doesn't hold this one
        _module setVariable ["ALiVE_Occ_pauseTasks", []];
        if (!(missionNamespace getVariable ["ALiVE_c2istar_autoPlayerTasks", true]) || {isNil "ALIVE_eventLog"}
            || {isNil "ALIVE_taskHandler"} || {(_players select 1) isEqualTo []} || {_types isEqualTo []}) then {
            ["OPCOM %1: holding new attacks for %2 min after taking %3 (no tasks to give, so the timer decides)", _sideText, _mins, _objID] call ALiVE_fnc_dump;
        } else {
            // the clean-up tasks look for the first hostile commander's lead faction
            private _mySide = [_sideText] call ALiVE_fnc_sideTextToObject;
            private _enemyFaction = "";
            {
                private _theirSide = [[_x,"side","CIV"] call ALiVE_fnc_HashGet] call ALiVE_fnc_sideTextToObject;
                if (_enemyFaction == "" && {(_mySide getFriend _theirSide) < 0.6}) then {
                    _enemyFaction = ([_x,"factions",[]] call ALiVE_fnc_HashGet) param [0, ""];
                };
            } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
            private _ids = [];
            private _faction = ([_logic,"factions",[]] call ALiVE_fnc_HashGet) param [0, ""];
            {
                private _id = format ["occpause_%1_%2_%3", [_logic,"opcomID",""] call ALiVE_fnc_HashGet, round time, _forEachIndex];
                private _taskData = [_id, "OPCOM", _sideText, _faction, _x, "Map", +_center,
                    [_players select 1, _players select 0], _enemyFaction, "Y", "Side"];
                if (_x == "DestroyVehicles" && {_knownVehs isNotEqualTo []}) then { _taskData pushBack _knownVehs };
                [ALIVE_eventLog, "addEvent", ["TASK_GENERATE", _taskData, "OPCOM"] call ALIVE_fnc_event] call ALIVE_fnc_eventLog;
                _ids pushBack _id;
            } forEach _types;
            _module setVariable ["ALiVE_Occ_pauseTasks", _ids];
            ["OPCOM %1: holding new attacks for up to %2 min after taking %3; tasks %4 at %5", _sideText, _mins, _objID, _types, mapGridPosition _center] call ALiVE_fnc_dump;
            // and tell the side what comes next
            private _place = [_center] call ALIVE_fnc_taskGetNearestLocationName;
            if (isNil "_place" || {!(_place isEqualType "")} || {_place == ""}) then { _place = "grid " + mapGridPosition _center };
            _module setVariable ["ALiVE_Occ_place", _place];
            [_logic, "opRadio", [format ["%1 is secured. All units, clear the area before the operation moves on.", _place],
                format ["%1 is secured. All units prepare for aid relief to the affected area.", _place]] select _civ] call ALiVE_fnc_OPCOM;
        };
        // one watcher wakes the commander as soon as the hold ends, rather than at its next 5 minute cycle
        if !(_module getVariable ["ALiVE_Occ_watcher", false]) then {
            _module setVariable ["ALiVE_Occ_watcher", true];
            [_logic, _module] spawn {
                params ["_h", "_module"];
                waitUntil { sleep 10; [_h,"occPauseOpen"] call ALiVE_fnc_OPCOM };
                _module setVariable ["ALiVE_Occ_watcher", false];
                private _fsm = [_h,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet;
                if (_fsm isEqualType 0 && {_fsm > -1}) then {
                    private _q = _fsm getFSMVariable ["_OPCOM_QUEUE", []];
                    _q pushBack ["analyze", nil];
                    _fsm setFSMVariable ["_OPCOM_QUEUE", _q];
                };
                ["OPCOM %1: the pause after a capture is over (%2), moving on", [_h,"side",""] call ALiVE_fnc_HashGet,
                    _module getVariable ["ALiVE_Occ_endWhy", "the time is up"]] call ALiVE_fnc_dump;
                // the side hears it only when it was told the pause began (tasks were given)
                private _place = _module getVariable ["ALiVE_Occ_place", ""];
                if (_place != "") then {
                    _module setVariable ["ALiVE_Occ_place", ""];
                    [_h, "opRadio", format ["Operations at %1 are complete. The operation moves on.", _place]] call ALiVE_fnc_OPCOM;
                };
            };
        };
    };

    // the operation in hand, for a persistent save: [seconds left on a pause after a capture, its objective, the
    // objectives whose preparations are done]
    case "opState": {
        private _module = [_logic,"module"] call ALiVE_fnc_HashGet;
        private _left = (((_module getVariable ["ALiVE_Occ_holdUntil", -1]) - time) max 0);
        _result = [round _left, [_module getVariable ["ALiVE_Occ_objectiveID", ""], ""] select (_left <= 0), +(_module getVariable ["ALiVE_prep_cleared", []])];
    };

    // after a load: the preparations already done stay done, and a pause that was running holds attacks again at once
    // and, once a player of the side is in (or the time runs out first), gives its tasks again for the time it had left
    case "opResume": {
        private _st = _args;
        if !(_st isEqualType []) exitWith {};
        _st params [["_left", 0], ["_objID", ""], ["_cleared", []]];
        private _module = [_logic,"module"] call ALiVE_fnc_HashGet;
        if (_cleared isEqualType [] && {_cleared isNotEqualTo []}) then { _module setVariable ["ALiVE_prep_cleared", +_cleared] };
        if (!(_left isEqualType 0) || {_left <= 0} || {_objID == ""}) exitWith {};
        private _deadline = time + _left;
        _module setVariable ["ALiVE_Occ_holdUntil", _deadline];
        _module setVariable ["ALiVE_Occ_objectiveID", _objID];
        ["OPCOM %1: a pause after taking %2 carries on after the load, %3 s left", [_logic,"side",""] call ALiVE_fnc_HashGet, _objID, round _left] call ALiVE_fnc_dump;
        [_logic, _deadline, _objID] spawn {
            params ["_h", "_deadline", "_objID"];
            private _side = [_h,"side","WEST"] call ALiVE_fnc_HashGet;
            waitUntil {
                sleep 5;
                time > _deadline || {!isNil "ALIVE_taskHandler" && {(([_h, "prepTestPlayers", []] call ALiVE_fnc_HashGet) isNotEqualTo []
                    || {((([_side] call ALiVE_fnc_getPlayersDataSource) select 1) isNotEqualTo [])})}}
            };
            if (time >= _deadline) exitWith {};
            private _i = ([_h,"objectives",[]] call ALiVE_fnc_HashGet) findIf { ([_x,"objectiveID",""] call ALiVE_fnc_HashGet) == _objID };
            if (_i < 0) exitWith {};
            [_h, "occPauseStart", [([_h,"objectives",[]] call ALiVE_fnc_HashGet) select _i, _deadline - time]] call ALiVE_fnc_OPCOM;
        };
    };

    // true while no pause is running: the time is up, or every task it gave players is closed
    case "occPauseOpen": {
        private _module = [_logic,"module"] call ALiVE_fnc_HashGet;
        _result = true;
        if (time < (_module getVariable ["ALiVE_Occ_holdUntil", -1])) then {
            private _ids = _module getVariable ["ALiVE_Occ_pauseTasks", []];
            if (_ids isNotEqualTo [] && {!([_logic,"occPauseTasksOpen"] call ALiVE_fnc_OPCOM)}) then {
                _module setVariable ["ALiVE_Occ_holdUntil", -1];
                _module setVariable ["ALiVE_Occ_pauseTasks", []];
                _module setVariable ["ALiVE_Occ_endWhy", "its tasks are done"];
            } else {
                _result = false;
                _module setVariable ["ALiVE_Occ_endWhy", "the time is up"];
            };
        };
    };

    // true while one of the pause's tasks is still open; one that never appeared (nothing to find there) is given
    // 2 minutes, then counts as closed
    case "occPauseTasksOpen": {
        private _module = [_logic,"module"] call ALiVE_fnc_HashGet;
        private _ids = _module getVariable ["ALiVE_Occ_pauseTasks", []];
        _result = false;
        if (_ids isEqualTo [] || {isNil "ALIVE_taskHandler"}) exitWith {};
        private _records = (([ALIVE_taskHandler,"tasks",["",[],[],nil]] call ALiVE_fnc_HashGet) select 2) select {
            private _rid = _x select 0;
            (_ids findIf { (_rid find _x) == 0 }) >= 0
        };
        if (_records isEqualTo []) exitWith {
            _result = time < ((_module getVariable ["ALiVE_Occ_raisedAt", -1]) + 120);
        };
        _result = (_records findIf { !((_x select 8) in ["Succeeded","Failed","Canceled"]) }) >= 0;
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

        // Synced triggers all fired, and no pause after the high value target was killed (#625)
        private _allSyncedTriggersActivated = {((typeof _x) == "EmptyDetector") && {!(triggerActivated _x)}} count (synchronizedObjects _module) == 0
            && {time >= (_module getVariable ["ALiVE_HVT_holdUntil", -1])}
            && {[_logic,"occPauseOpen"] call ALiVE_fnc_OPCOM};

        private _targetObjectiveIndex = _objectives findIf {
            private _objectiveID = [_x, "objectiveID"] call AliVE_fnc_HashGet;
            private _objectiveState = [_x, "opcom_state"] call AliVE_fnc_HashGet;

            !(_objectiveID in _OPCOM_SKIP_OBJECTIVES) &&
            _objectiveState == _state &&
            { !(_objectiveState in ["attack","unassigned"]) || { _allSyncedTriggersActivated && {[_logic, "prepReady", _x] call ALiVE_fnc_OPCOM} } }
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
        // what each commander fights, published for players' tablets: on a dedicated server OPCOM_instances is the
        // server's alone, so C2ISTAR's enemy faction filter found nothing there and listed every faction (NeisAEL on
        // Discord, 23 Oct)
        ALiVE_OPCOM_factionsPublic = (OPCOM_instances select { _x isEqualType [] }) apply { [[_x, "sidesenemy", []] call ALiVE_fnc_HashGet, [_x, "factions", []] call ALiVE_fnc_HashGet] };
        publicVariable "ALiVE_OPCOM_factionsPublic";

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
                    private _OPC_DATA = _FSM_OPCOM getfsmvariable ["_OPCOM_DATA",[]];
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
                                _FSM_OPCOM setfsmvariable ["_OPCOM_DATA",[]];
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

        // a preparation in hand (and a question to the players) doesn't carry over to the new type; what is cleared stays
        private _prepModule = [_logic, "module"] call ALiVE_fnc_HashGet;
        if (!isNil "_prepModule") then {
            _prepModule setVariable ["ALiVE_prep_state", ""];
            _prepModule setVariable ["ALiVE_prep_choice", ""];
            _prepModule setVariable ["ALiVE_prep_choiceTargets", []];
            [_logic, "prepFlag"] call ALiVE_fnc_OPCOM;
        };

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

        private _skipKeys = ["objectivesByID","profileObjectiveAssignment"];

        if (_args isequaltype []) then {
            // Restore state
            private _newState = _args;
            if !([_newState] call ALiVE_fnc_isHash) exitwith {
                ["ALiVE_fnc_OPCOM operation %1 - Passed state is not a hash", _operation] call ALiVE_fnc_Dump;
            };

            private _newStateKeys = _newState select 1;
            private _newStateValues = _newState select 2;

            {
                if !(_x in _skipKeys) then {
                    private _newValue = _newStateValues select _foreachindex;

                    [_logic, _x, _newValue] call ALiVE_fnc_hashSet;
                };
            } foreach _newStateKeys;

            [_logic,"rebuildObjectiveIndexes"] call MAINCLASS;
        } else {
            // extract state
            private _allKeys = _logic select 1;
            private _keys = _allKeys - (["super","class"] + _skipKeys);
            private _values = _logic select 2;
            
            private _keyValuePairs = _keys apply {
                [_x, _values select (_allKeys find _x)]
            };

            private _state = [_keyValuePairs] call ALIVE_fnc_hashCreate;

            _result = _state;
        };
    };

    case "validateStartupState": {
        // Taken off the commander itself, the way everything else below is. This used to be read
        // from the arguments of the call, and the one place that makes the call passes none, so
        // it was always nothing at all. Asking nothing what it is synchronised to answers with an
        // empty list and no complaint, so the check compared the commander's factions against
        // nothing and reported every one of them as unmatched, on every mission, whatever the
        // synced placement modules actually offered.
        private _opcomModule = [_logic, "module", objNull] call ALiVE_fnc_HashGet;

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
                "Aborting OPCOM Init... There are 0 objectives for OPCOM instance with factions %1! Please assign Military or Civilian Placement Objectives!",
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
        // The factions the placement modules synced to this commander place, named in the no-groups warning below
        // when a missing faction isn't among them. That's the commonest OPCOM-init misconfiguration: faction X picked
        // here, the synced Mil Placement left on its default, so there are no groups for X and the commander won't
        // run. A synced placement of another side is fine on its own: a commander controls every profile of its
        // factions wherever they were placed, and a synced placement gives it objectives, not forces (objectives
        // shared between sides are made this way). The Eden check in main/fnc_edenValidateOpcomFactions.sqf works
        // the same way.
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
                // A Custom Faction Compiler synced to the placement module decides the faction it
                // places, ahead of its Force Factions, so it decides what it supplies here too.
                private _compiledFaction = [_x] call ALiVE_fnc_factionCompilerResolveForModule;
                private _placementFactions = if (_compiledFaction != "") then {[_compiledFaction]} else {[_x getVariable ["factions", ""]] call _parsePlacementFactions};
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
            private _syncedHint = "";
            if (_availableFactions isNotEqualTo [] && {(_factionsWithNoGroups findIf {!(_x in _availableFactions)}) >= 0}) then {
                _syncedHint = format [" The placement modules synced to AI Commander '%1' place [%2]: set one to the missing faction, or leave a synced custom objective's Force Factions empty so it takes this Commander's.",
                    _customName, _availableFactions joinString ", "];
            };
            [
                "There are no groups for OPCOM faction(s) %1! %2%3",
                _factionsWithNoGroups,
                "Please ensure you have configured a Mil Placement or Mil Placement (Civ Obj) module for this faction (or faction units are synced to Virtual AI module). If so, please check groups are correctly configured for this faction.",
                _syncedHint
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
            ["Aborting OPCOM Init... There are factions from different sides within this OPCOM %1! Please only select one side per OPCOM!", _factions] call ALIVE_fnc_dumpR;
        };

        if (_debug) then {
            ["OPCOM %1 starts with %2 profiles and %3 objectives!", _side, _opcomProfileCount, _objectiveCount] call ALIVE_fnc_dumpR;
        };

        _result = true;
    };

    // keep operation for backwards compat
    case "convert": {
        _result = [_args] call ALiVE_fnc_parseArrayFromString;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

PROFILE_SCOPE_END(OPERATION)
TRACE_1("OPCOM - output", _result);

if !(isnil "_result") then {_result} else {nil};
