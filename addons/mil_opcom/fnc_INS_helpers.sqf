//#define DEBUG_MODE_FULL
#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(INS_helpers);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_INS_helpers
Description:
Helper Function to keep transferred and stored code small

Base class for OPCOM objects to inherit from

Parameters:
Several
_timeTaken = _this select 0; //number
_pos = _this select 1; //array
_id = _this select 2; //string
_size = _this select 3; //number
_faction = _this select 4; //string
_factory = _this select 5; //array of [_pos,_class]
_target = _this select 6; //array of [_pos,_class]
_sides = _this select 7; //array of side as strings
_agents = _this select 8; //array of strings

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
none

Examples:
(begin example)
// no example
(end)

See Also:

Author:
Highhead
Javen
Jman

---------------------------------------------------------------------------- */

// Whether an Asymmetric commander may set up this kind of installation or carry out this action
// (Installation Types, #1081): factory, depot, recruit (the recruitment HQ), ied, suicide,
// sabotage, ambush or roadblocks. Anything else, and a commander without the setting, is allowed.
ALiVE_fnc_INS_typeAllowed = {
                params [["_opcom", []], ["_kind", ""]];
                private _gated = ["factory","depot","recruit","ied","suicide","sabotage","ambush","roadblocks"];
                if !((toLower _kind) in _gated) exitWith {true};
                private _types = if (_opcom isEqualType [] && {_opcom isNotEqualTo []}) then {[_opcom, "insTypes", _gated] call ALiVE_fnc_HashGet} else {_gated};
                (toLower _kind) in _types
};

// War on Drugs (#1080): whether this commander's IED factories are drug labs
ALiVE_fnc_INS_drugLabsOn = {
                params [["_opcom", []]];
                if (isNil "_opcom" || {!(_opcom isEqualType [])} || {_opcom isEqualTo []}) exitWith {false};
                [_opcom, "drugLabs", false] call ALiVE_fnc_HashGet
};
// what a player calls the "factory" installation: an IED factory, or a drug lab
ALiVE_fnc_INS_factoryName = {
                params [["_opcom", []]];
                ["IED factory", "drug lab"] select ([_opcom] call ALiVE_fnc_INS_drugLabsOn)
};
// the commander's drug labs still standing: built, not destroyed, not disabled
ALiVE_fnc_INS_countStandingLabs = {
                params [["_opcom", []]];
                if !([_opcom] call ALiVE_fnc_INS_drugLabsOn) exitWith {0};
                private _n = 0;
                {
                    if !([_x, "deleted", false] call ALiVE_fnc_HashGet) then {
                        private _b = [_opcom, "convertObject", [_x, "factory", []] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
                        if (!isNil "_b" && {_b isEqualType objNull} && {alive _b} && {!(_b getVariable ["ALiVE_MIL_OPCOM_FACTORY_DISABLED", false])}) then { _n = _n + 1 };
                    };
                } forEach ([_opcom, "objectives", []] call ALiVE_fnc_HashGet);
                _n
};

ALiVE_fnc_INS_getOpcomByObjective = {
                params [["_objective",[]]];

                if (_objective isEqualTo []) exitwith {nil};

                private _opcomID = [_objective,"opcomID",""] call ALiVE_fnc_HashGet;
                if (_opcomID == "") exitwith {nil};

                private _opcom = nil;

                {
                    if (([_x,"opcomID",""] call ALiVE_fnc_HashGet) == _opcomID) exitwith {
                        _opcom = _x;
                    };
                } foreach (missionNameSpace getVariable ["OPCOM_instances",[]]);

                _opcom
};

ALiVE_fnc_INS_getHostilitySetting = {
                params [["_objective",[]],["_key",""],["_default",0]];

                private _opcom = [_objective] call ALiVE_fnc_INS_getOpcomByObjective;
                if (isnil "_opcom") exitwith {_default};

                [_opcom,_key,_default] call ALiVE_fnc_HashGet
};

// Shared classname tier ladder. Takes a flat list of vehicle
// classnames and reports the tier of the heaviest one. Both callers
// supply that list from what they have in hand: the recruitment
// classifier below reads the classnames out of CfgGroups, the
// hostility path (issue #991) reads them off live profiles. One
// definition of what counts as light or medium, used by both.
//
// Classnames that aren't vehicles don't elevate the tier: men and
// static weapons fall out of whichever tier the rest of the list
// already has, so a plain rifle team classifies as "infantry". "Man"
// is the same separator ALiVE uses in
// ALiVE_fnc_createProfilesFromGroupConfig, so man and vehicle classes
// are split the same way on both paths. See
// ALiVE_fnc_INS_classifyGroupTier for what each tier covers.
//
// The exclusion list is tested BEFORE men are skipped, so an
// asym_excludeKinds entry naming a Man-derived kind still excludes -
// the attribute is mission-facing and gets to mean what it says.
ALiVE_fnc_INS_classifyClassesTier = {
                params [
                    ["_classes", [], [[]]],
                    ["_excludedKinds", ["Tank", "Plane", "Helicopter", "Ship"], [[]]]
                ];

                private _hasExcluded = false;
                private _hasMedium = false;
                private _hasLight = false;

                {
                    private _class = _x;
                    if (_class isEqualType "" && {_class != ""}) then {
                        // Mission-maker-configurable exclusion list.
                        // Default keeps the legacy hard-coded list
                        // (Tank / Plane / Helicopter / Ship) - missions
                        // that don't touch the asym_excludeKinds attr
                        // get identical behaviour to before #861.
                        // Edit the attribute on mil_opcom to widen
                        // (e.g. allow tanks for state-backed
                        // insurgencies) or narrow the list.
                        private _isExcluded = (_excludedKinds findIf {
                            _class isKindOf _x
                        }) >= 0;
                        if (_isExcluded) then {
                            _hasExcluded = true;
                        } else {
                            // Men don't elevate tier - a rifleman's
                            // classname is a Man class, not a vehicle.
                            // StaticWeapon units (MGs, mortars, AT
                            // launchers) accompany infantry and don't
                            // elevate tier either.
                            if (!(_class isKindOf "Man") && {!(_class isKindOf "StaticWeapon")}) then {
                                // Wheeled APCs, MRAPs, LSVs and trucks all inherit Car, so Car alone
                                // put every one of them in the light tier and left medium empty. They
                                // are medium, as is any Car with the armour of one (a modded APC). A3's
                                // trucks come down from Truck_F, not the older Truck.
                                private _isMediumWheeled = (_class isKindOf "Truck") ||
                                    {_class isKindOf "Truck_F"} ||
                                    {_class isKindOf "Wheeled_APC_F"} ||
                                    {_class isKindOf "MRAP_01_base_F"} ||
                                    {_class isKindOf "MRAP_02_base_F"} ||
                                    {_class isKindOf "MRAP_03_base_F"} ||
                                    {_class isKindOf "LSV_01_base_F"} ||
                                    {_class isKindOf "LSV_02_base_F"} ||
                                    {getNumber (configFile >> "CfgVehicles" >> _class >> "armor") >= 200};
                                if (_class isKindOf "Car" && {!_isMediumWheeled}) then {
                                    _hasLight = true;
                                } else {
                                    // Any other non-infantry, non-
                                    // excluded vehicle - treated as
                                    // medium (wheeled APC, armed
                                    // truck, non-Car transport, and
                                    // any heavy types the mission-
                                    // maker has un-excluded).
                                    _hasMedium = true;
                                };
                            };
                        };
                    };
                } forEach _classes;

                if (_hasExcluded) exitWith {"excluded"};
                if (_hasMedium) exitWith {"medium"};
                if (_hasLight) exitWith {"light"};
                "infantry"
};

// Classify a CfgGroups group entry into a "tier" for the asymmetric-OPCOM
// progressive recruitment feature (issue #355). Asymmetric forces
// historically never get tanks, jets, helis, or boats - regardless of
// what the faction's CfgGroups category structure happens to include.
// This classifier is faction-agnostic: it walks the group's units,
// inspects each unit's vehicle classname via isKindOf, and picks a tier
// from the heaviest eligible unit.
//
// Tiers:
//   "excluded" - any unit isKindOf Tank / Plane / Helicopter / Ship.
//                Tank_F in A3 is the shared base for tanks AND tracked
//                IFVs (BMP/BTR-style), so this also excludes tracked
//                armour - which is consistent with "asymmetric forces
//                get technicals and light wheeled, nothing tracked".
//   "medium"   - any wheeled/vehicle unit that's not isKindOf Car and
//                not excluded above (wheeled APCs, armed wheeled
//                transport).
//   "light"    - at least one isKindOf Car unit, no medium/excluded
//                found (technicals, pickups, light transport).
//   "infantry" - no vehicle units (beyond StaticWeapon, which counts
//                as infantry equipment and does NOT elevate tier).
//
// Note: a CfgGroups unit entry's "vehicle" is the unit's own classname,
// which for a rifleman is a Man class - it is not a "has a vehicle"
// flag. The shared ladder skips Man classes for tier purposes (after
// testing them against the exclusion list), so infantry groups land in
// "infantry" as the tiers above describe.
//
// Returns: string tier, or "excluded" if any unit in the group would
// cross the asymmetric-force capability cap.
ALiVE_fnc_INS_classifyGroupTier = {
                params [
                    ["_groupConfig", configNull, [configNull]],
                    ["_excludedKinds", ["Tank", "Plane", "Helicopter", "Ship"], [[]]]
                ];

                if (isNull _groupConfig) exitWith {"excluded"};

                // Pull the group's unit classnames out of config and hand
                // them to the shared ladder, which sorts men from vehicles.
                private _classes = [];

                for "_i" from 0 to (count _groupConfig - 1) do {
                    private _unitConfig = _groupConfig select _i;
                    if (isClass _unitConfig) then {
                        private _vehicle = getText (_unitConfig >> "vehicle");
                        if (_vehicle != "") then {
                            _classes pushBack _vehicle;
                        };
                    };
                };

                [_classes, _excludedKinds] call ALiVE_fnc_INS_classifyClassesTier
};

// Build a tiered group roster for a faction, usable by the asymmetric
// progressive recruitment feature. Walks the faction's CfgGroups
// categories, classifies each group via INS_classifyGroupTier, buckets
// by tier. "excluded" groups are dropped entirely from the roster.
//
// Return format (positional index so callers can use select):
//   [[infantry classnames], [light classnames], [medium classnames]]
//
// Called once per faction at asymmetric-OPCOM init; result cached on
// the handler hashmap under "tieredGroupRoster".
ALiVE_fnc_INS_buildTieredGroupRoster = {
                params [
                    ["_faction", "", [""]],
                    ["_excludedKinds", ["Tank", "Plane", "Helicopter", "Ship"], [[]]]
                ];

                private _roster = [[], [], []];
                if (_faction == "") exitWith {_roster};

                private _groupsConfig = _faction call ALiVE_fnc_configGetFactionGroups;
                if (isNull _groupsConfig) exitWith {_roster};

                // As the infantry-only picker does: blacklisted groups (the mission's own list
                // included) and groups with no units are left out, and the infantry tier comes
                // from the faction's Infantry category only, so a tank crew or divers aren't
                // recruited as infantry. A mapped faction (RHS and others) names its own category.
                private _blacklist = missionNamespace getVariable ["ALiVE_PLACEMENT_GROUPBLACKLIST", []];
                private _infantryCategory = "Infantry";
                if (!isNil "ALIVE_factionCustomMappings" && {_faction in (ALIVE_factionCustomMappings select 1)}) then {
                    private _mappedTypes = [[ALIVE_factionCustomMappings, _faction] call ALIVE_fnc_hashGet, "GroupFactionTypes"] call ALIVE_fnc_hashGet;
                    if (!isNil "_mappedTypes") then {
                        private _mapped = [_mappedTypes, "Infantry"] call ALIVE_fnc_hashGet;
                        if (!isNil "_mapped" && {_mapped isEqualType ""}) then { _infantryCategory = _mapped };
                    };
                };

                for "_i" from 0 to (count _groupsConfig - 1) do {
                    private _categoryConfig = _groupsConfig select _i;
                    if (isClass _categoryConfig) then {
                        private _isInfantryCategory = (configName _categoryConfig) == _infantryCategory;
                        for "_j" from 0 to (count _categoryConfig - 1) do {
                            private _groupConfig = _categoryConfig select _j;
                            if (isClass _groupConfig && {!((configName _groupConfig) in _blacklist)} && {count ("isClass _x" configClasses _groupConfig) > 0}) then {
                                private _tier = [_groupConfig, _excludedKinds] call ALiVE_fnc_INS_classifyGroupTier;
                                switch (_tier) do {
                                    case "infantry": { if (_isInfantryCategory) then { (_roster select 0) pushBack (configName _groupConfig); }; };
                                    case "light":    { (_roster select 1) pushBack (configName _groupConfig); };
                                    case "medium":   { (_roster select 2) pushBack (configName _groupConfig); };
                                };
                            };
                        };
                    };
                };

                _roster
};

// Sample aggregate hostility for an asymmetric OPCOM. Walks each of
// the OPCOM's objectives, pulls the settlement cluster(s) in that
// sector, and accumulates the insurgent-side hostility value across
// them.
//
// Hostility is driven by existing ALiVE mechanisms: installation
// destruction (buildingKilledEH -> +50 to insurgent side) and
// sustained player presence in insurgent-held areas
// (updateHostilityByPresence). So a higher aggregate reflects how
// much pressure the insurgent OPCOM has been under mission-wide.
//
// Used by the progressive-recruitment feature to derive tier unlock
// status. Monotonic ratcheting is handled at the call site - this
// helper just reports the current scalar.
//
// Returns: scalar (how far insurgent-side hostility has risen since
// the start, summed across this OPCOM's settlement clusters). 0 if
// sector grid / cluster handler aren't initialised (returns 0 =
// "nothing to escalate on").
ALiVE_fnc_INS_sampleOpcomHostility = {
                params [["_handler", [], [[]]]];

                private _totalHostility = 0;

                if (isNil QMOD(SECTORGRID) || {isNil QMOD(CLUSTERHANDLER)}) exitWith {_totalHostility};

                private _side = [_handler, "side", ""] call ALiVE_fnc_HashGet;
                if (_side == "") exitWith {_totalHostility};

                private _objectives = [_handler, "objectives", []] call ALiVE_fnc_HashGet;
                private _seenClusterIDs = [];

                // Every settlement starts at the hostility set in Civilian Population, so only the
                // rise since then counts. Summing the start itself gave a map with many settlements
                // a head start that could unlock a tier before anything had happened.
                private _baseline = if (isNil "ALIVE_civilianHostility") then {0} else {[ALIVE_civilianHostility, _side, 0] call ALiVE_fnc_hashGet};

                {
                    private _objective = _x;
                    private _center = [_objective, "center", [0,0,0]] call ALiVE_fnc_HashGet;

                    private _sector = [ALIVE_sectorGrid, "positionToSector", _center] call ALIVE_fnc_sectorGrid;
                    private _sectorData = [_sector, "data", ["", [], [], nil]] call ALiVE_fnc_hashGet;

                    if ("clustersCiv" in (_sectorData select 1)) then {
                        private _civClusters = [_sectorData, "clustersCiv"] call ALiVE_fnc_hashGet;
                        private _settlementClusters = [_civClusters, "settlement"] call ALiVE_fnc_hashGet;

                        {
                            private _clusterID = _x select 1;
                            // Objectives can share a sector; dedup so we
                            // don't double-count a cluster's hostility.
                            if !(_clusterID in _seenClusterIDs) then {
                                _seenClusterIDs pushBack _clusterID;
                                private _cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;
                                if !(isNil "_cluster") then {
                                    private _clusterHostility = [_cluster, "hostility"] call ALiVE_fnc_hashGet;
                                    private _sideHostility = [_clusterHostility, _side, 0] call ALiVE_fnc_hashGet;
                                    _totalHostility = _totalHostility + _sideHostility - _baseline;
                                };
                            };
                        } forEach _settlementClusters;
                    };
                } forEach _objectives;

                _totalHostility
};

ALiVE_fnc_INS_getNearestObjectiveByPosition = {
                params [
                    ["_pos",[],[[]]],
                    ["_radius",2500,[0]],
                    ["_friendlySide","",["", east]],
                    ["_requiredControlType","",[""]]
                ];

                if (_pos isEqualTo []) exitwith {[]};

                private _friendlySideText = "";
                if (_friendlySide isEqualType east) then {
                    _friendlySideText = [[_friendlySide] call ALiVE_fnc_sideObjectToNumber] call ALiVE_fnc_sideNumberToText;
                } else {
                    if (_friendlySide isEqualType "") then {
                        _friendlySideText = toUpper _friendlySide;
                        if (_friendlySideText == "RESISTANCE") then {_friendlySideText = "GUER"};
                    };
                };

                private _requiredControlTypeText = toLower _requiredControlType;
                private _nearestObjective = [];
                private _closestDistance = _radius max 0;

                {
                    private _opcom = _x;
                    private _controlType = toLower ([_opcom, "controltype", ""] call ALiVE_fnc_HashGet);
                    private _sidesEnemy = [[_opcom, "sidesenemy", []] call ALiVE_fnc_HashGet] call ALiVE_fnc_INS_normalizeHostilitySides;

                    if (
                        (_requiredControlTypeText == "" || {_controlType == _requiredControlTypeText})
                        && {(_friendlySideText == "") || {_friendlySideText in _sidesEnemy}}
                    ) then {
                        {
                            private _center = [_x,"center",[]] call ALiVE_fnc_HashGet;
                            if !(_center isEqualTo []) then {
                                private _distance = _pos distance2D _center;
                                if (_distance <= _closestDistance) then {
                                    _closestDistance = _distance;
                                    _nearestObjective = _x;
                                };
                            };
                        } foreach ([_opcom, "objectives", []] call ALIVE_fnc_HashGet);
                    };
                } foreach (missionNameSpace getVariable ["OPCOM_instances",[]]);

                _nearestObjective
};

// Collect the classnames carried by a list of profiles. Accepts either
// profile hashes or profileIDs (the objective "section" stores IDs).
// Vehicle profiles contribute their vehicleClass; entity profiles
// contribute their unitClasses plus the vehicleClass of every vehicle
// profile they are linked to, so a boat crew yields the boat plus its
// crew classnames.
//
// Only runs on hostility events, so the per-profile handler lookups are
// a handful of resolutions per event, not a loop cost.
//
// Returns: array of classnames, [] if nothing resolves.
ALiVE_fnc_INS_getProfileUnitClasses = {
                params [["_profiles",[],[[]]]];

                private _classes = [];
                private _canResolve = !isNil "ALIVE_profileHandler";

                {
                    private _profile = _x;

                    if (_profile isEqualType "") then {
                        if (_canResolve) then {
                            _profile = [ALIVE_profileHandler,"getProfile",_profile] call ALIVE_fnc_profileHandler;
                        } else {
                            _profile = nil;
                        };
                    };

                    if (!isNil "_profile" && {_profile isEqualType []}) then {
                        private _vehicleClass = [_profile,"vehicleClass",""] call ALiVE_fnc_HashGet;
                        if (_vehicleClass isEqualType "" && {_vehicleClass != ""}) then {
                            _classes pushBackUnique _vehicleClass;
                        };
                        {_classes pushBackUnique _x} foreach ([_profile,"unitClasses",[]] call ALiVE_fnc_HashGet);

                        // An entity profile's unitClasses are man classes only -
                        // the boat or truck the group arrived in is a separate
                        // vehicle profile, referenced by ID. Without this hop
                        // every entity profile would classify as "infantry" and
                        // the multiplier would be stuck at 1 (#991's boat case).
                        // vehiclesInCommandOf / vehiclesInCargoOf are arrays of
                        // vehicle profileIDs (ALiVE_fnc_profileEntity :177/:476),
                        // covering both crewing a vehicle and riding in one.
                        if (_canResolve && {([_profile,"type",""] call ALiVE_fnc_HashGet) isEqualTo "entity"}) then {
                            private _vehicleIDs = ([_profile,"vehiclesInCommandOf",[]] call ALiVE_fnc_HashGet) + ([_profile,"vehiclesInCargoOf",[]] call ALiVE_fnc_HashGet);
                            {
                                if (_x isEqualType "" && {_x != ""}) then {
                                    private _vehicleProfile = [ALIVE_profileHandler,"getProfile",_x] call ALIVE_fnc_profileHandler;
                                    if (!isNil "_vehicleProfile" && {_vehicleProfile isEqualType []}) then {
                                        private _linkedClass = [_vehicleProfile,"vehicleClass",""] call ALiVE_fnc_HashGet;
                                        if (_linkedClass isEqualType "" && {_linkedClass != ""}) then {
                                            _classes pushBackUnique _linkedClass;
                                        };
                                    };
                                };
                            } foreach _vehicleIDs;
                        };
                    };
                } foreach _profiles;

                _classes
};

// Hostility weight for the units that carried an action out (issue
// #991). Runs the same tier ladder the recruitment classifier uses, so
// "light" and "medium" mean the same thing here as they do there.
//
// The ladder is deliberately shallow - the shift is already multiplied
// by duration (up to 4x) and by the commander's
// hostilityPresenceMultiplier, so this term only tilts the result:
//   infantry / nothing resolved - 1    (baseline, shift unchanged)
//   light (technicals, pickups) - 1.25
//   medium (wheeled APCs, trucks) - 1.5
//   excluded (boats, armour, air) - 2
//
// "excluded" is the recruitment classifier's word for what an
// asymmetric commander will never field itself. It still won't recruit
// those, but a mission-placed boat or truck delivering supplies is
// exactly the case #991 was raised for, so here it carries the heaviest
// weight rather than being ignored.
//
// The default exclusion list is used regardless of the OPCOM's
// asym_excludeKinds attribute: that attribute governs what the
// commander may recruit, not how much a delivery is worth.
ALiVE_fnc_INS_getHostilityUnitMultiplier = {
                params [["_classes",[],[[]]]];

                if (_classes isEqualTo []) exitwith {1};

                switch ([_classes] call ALiVE_fnc_INS_classifyClassesTier) do {
                    case "light":    {1.25};
                    case "medium":   {1.5};
                    case "excluded": {2};
                    default          {1};
                };
};

ALiVE_fnc_INS_updateHostilityByPresence = {
                params ["_timeTaken","_pos","_insurgentSides",["_baseShift",20],["_allSides",["EAST","WEST","GUER"]],["_objective",[]],["_actingProfiles",[],[[]]]];

                _allSides = [_allSides] call ALiVE_fnc_INS_normalizeHostilitySides;
                _insurgentSides = [_insurgentSides] call ALiVE_fnc_INS_normalizeHostilitySides;

                if (count _insurgentSides == 0) exitwith {};

                private _elapsed = (time - _timeTaken) max 0;
                private _durationMultiplier = ((floor (_elapsed / 120)) max 1) min 4;
                private _presenceMultiplier = ([_objective,"hostilityPresenceMultiplier",1] call ALiVE_fnc_INS_getHostilitySetting) max 0;

                // Issue #991 - weight the shift by what carried the action out.
                // Callers holding the acting profiles pass them; the rest fall
                // back to the section the commander assigned to the objective.
                // Nothing to resolve, or a plain rifle team, leaves the shift
                // exactly as it was before this term existed.
                private _actingClasses = [_actingProfiles] call ALiVE_fnc_INS_getProfileUnitClasses;
                if (_actingClasses isEqualTo [] && {!(_objective isEqualTo [])}) then {
                    // "section" is a flat array of profileIDs (see
                    // ALiVE_fnc_OPCOM :3174) - exactly the resolver's input.
                    _actingClasses = [[_objective,"section",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_INS_getProfileUnitClasses;
                };
                private _unitMultiplier = [_actingClasses] call ALiVE_fnc_INS_getHostilityUnitMultiplier;

                private _shift = (_baseShift * _presenceMultiplier) * _durationMultiplier * _unitMultiplier;

                // Sustained insurgent activity slowly normalizes support for the insurgency
                // and makes the remaining combatant sides less welcome in the same area.
                [_pos,_insurgentSides,-_shift] call ALiVE_fnc_updateSectorHostility;
                [_pos,_allSides - _insurgentSides,_shift] call ALiVE_fnc_updateSectorHostility;
};

ALiVE_fnc_INS_normalizeHostilitySides = {
                params [["_sides",[]],["_validSides",["EAST","WEST","GUER"]]];

                if !(_sides isEqualType []) then {
                    _sides = [_sides];
                };

                private _normalized = [];

                {
                    private _sideText = "";

                    if (_x isEqualType east) then {
                        _sideText = ([[_x] call ALiVE_fnc_sideObjectToNumber] call ALiVE_fnc_sideNumberToText);
                    } else {
                        if (_x isEqualType "") then {
                            _sideText = toUpper _x;
                            if (_sideText == "RESISTANCE") then {_sideText = "GUER"};
                        };
                    };

                    if (_sideText in _validSides) then {
                        _normalized pushBackUnique _sideText;
                    };
                } forEach _sides;

                _normalized
};

ALiVE_fnc_INS_getHostilityPhase = {
                params [["_hostility",0,[0]]];

                private _phase = "Stabilize";

                if (_hostility <= 0) then {
                    _phase = "Consolidate";
                } else {
                    if (_hostility <= 25) then {
                        _phase = "Build";
                    } else {
                        if (_hostility <= 65) then {
                            _phase = "Engage";
                        };
                    };
                };

                _phase
};

ALiVE_fnc_INS_getHeartsAndMindsPressure = {
                params [
                    ["_pos", [], [[]]],
                    ["_insurgentSide", "", ["", east]],
                    ["_radius", 1200, [0]]
                ];

                if (
                    _pos isEqualTo [] ||
                    {isNil "ALIVE_clusterHandler"} ||
                    {isNil "ALIVE_clustersCivSettlement"}
                ) exitwith {[0, "Stabilize", ""]};

                private _insurgentSideText = "";
                if (_insurgentSide isEqualType east) then {
                    _insurgentSideText = [[_insurgentSide] call ALiVE_fnc_sideObjectToNumber] call ALiVE_fnc_sideNumberToText;
                } else {
                    if (_insurgentSide isEqualType "") then {
                        _insurgentSideText = toUpper _insurgentSide;
                        if (_insurgentSideText == "RESISTANCE") then {_insurgentSideText = "GUER"};
                    };
                };

                if !(_insurgentSideText in ["EAST","WEST","GUER"]) then {
                    _insurgentSideText = "EAST";
                };

                private _cluster = nil;
                private _closestDistance = _radius max 0;

                {
                    private _candidateCluster = [ALIVE_clusterHandler, "getCluster", _x] call ALIVE_fnc_clusterHandler;

                    if !(isNil "_candidateCluster") then {
                        private _center = [_candidateCluster, "center", []] call ALIVE_fnc_hashGet;

                        if !(_center isEqualTo []) then {
                            private _distance = _pos distance2D _center;

                            if (_distance <= _closestDistance) then {
                                _closestDistance = _distance;
                                _cluster = _candidateCluster;
                            };
                        };
                    };
                } foreach (ALIVE_clustersCivSettlement select 1);

                if (isNil "_cluster") exitwith {[0, "Stabilize", ""]};

                private _heartsAndMinds = if ("heartsAndMinds" in (_cluster select 1)) then {
                    [_cluster, "heartsAndMinds", []] call ALIVE_fnc_hashGet
                } else {
                    []
                };

                private _bestPressure = 0;
                private _bestPhase = "Stabilize";

                {
                    if (_x != _insurgentSideText) then {
                        // Only hearts-and-minds progress puts pressure on the insurgents: the
                        // civic model's phase and pressure when it is on, a record's support
                        // (moved by task outcomes) when it is off, and nothing from a side with
                        // no record here. The phase used to come from the settlement's
                        // hostility, where the default Low (0) reads as Consolidate, so a side
                        // not even in the mission cut recruitment to about a quarter of the
                        // chance set, whatever hostility the mission gave the side that was.
                        private _phase = "Stabilize";
                        private _support = 0;
                        private _supportState = [];

                        if !(_heartsAndMinds isEqualTo []) then {
                            if (_x in (_heartsAndMinds select 1)) then {
                                _supportState = [_heartsAndMinds, _x, []] call ALIVE_fnc_hashGet;
                                if !(_supportState isEqualTo []) then {
                                    if (missionNamespace getVariable ["ALIVE_civicStateEnabled", false]) then {
                                        _phase = [_supportState, "phase", _phase] call ALIVE_fnc_hashGet;
                                        private _insurgentPressure = [_supportState, "insurgentPressure", 100] call ALIVE_fnc_hashGet;
                                        _support = 100 - ((_insurgentPressure max 0) min 100);
                                    } else {
                                        // With the civic model off, the record's phase is worked
                                        // out from that same hostility (the task refresh does
                                        // it), so it would bring the fault back as soon as C2ISTAR
                                        // or a civilian conversation made a record.
                                        _support = [_supportState, "support", 0] call ALIVE_fnc_hashGet;
                                    };
                                };
                            };
                        };

                        _support = (_support max 0) min 100;

                        private _phaseWeight = switch (_phase) do {
                            case "Consolidate": {40};
                            case "Build": {28};
                            case "Engage": {14};
                            default {0};
                        };

                        private _pressure = ((_support * 0.6) + _phaseWeight) min 100;

                        if (_pressure > _bestPressure) then {
                            _bestPressure = _pressure;
                            _bestPhase = _phase;
                        };
                    };
                } foreach ["EAST","WEST","GUER"];

                [round _bestPressure, _bestPhase, [_cluster, "clusterID", ""] call ALIVE_fnc_hashGet]
};
ALiVE_fnc_INS_updateHostilityByInstallations = {
                params [
                    "_objective",
                    "_pos",
                    "_insurgentSides",
                    ["_installations",[]],
                    ["_currentHostility",0],
                    ["_interval",600],
                    ["_allSides",["EAST","WEST","GUER"]]
                ];

                _allSides = [_allSides] call ALiVE_fnc_INS_normalizeHostilitySides;
                _insurgentSides = [_insurgentSides] call ALiVE_fnc_INS_normalizeHostilitySides;

                if (count _insurgentSides == 0) exitwith {0};

                private _installationMultiplier = ([_objective,"hostilityInstallationMultiplier",1] call ALiVE_fnc_INS_getHostilitySetting) max 0;
                private _effectiveInterval = ([_objective,"hostilityInstallationInterval",_interval] call ALiVE_fnc_INS_getHostilitySetting) max 0;

                private _covertWeight = 0;
                private _overtWeight = 0;

                {
                    _x params [["_type",""],["_installation",objNull]];

                    if (alive _installation) then {
                        switch (toLower _type) do {
                            case "factory": {_covertWeight = _covertWeight + 2;};
                            case "ied";
                            case "sabotage": {_covertWeight = _covertWeight + 1;};
                            case "hq": {_overtWeight = _overtWeight + 2;};
                            case "depot";
                            case "roadblocks": {_overtWeight = _overtWeight + 1;};
                        };
                    };
                } forEach _installations;

                if ((_covertWeight + _overtWeight) <= 0) exitwith {
                    [_objective,"presenceHostilityTick"] call ALiVE_fnc_HashRem;
                    0
                };

                private _lastUpdate = [_objective,"presenceHostilityTick",-1] call ALiVE_fnc_HashGet;
                if (_lastUpdate < 0) exitwith {
                    [_objective,"presenceHostilityTick",time] call ALiVE_fnc_HashSet;
                    0
                };

                if (time - _lastUpdate < _effectiveInterval) exitwith {0};

                [_objective,"presenceHostilityTick",time] call ALiVE_fnc_HashSet;

                                private _supportWeight = if (_currentHostility > 0) then {
                    // Hostile populations only soften through lower-signature insurgent activity.
                    (_covertWeight * 2) min 4
                } else {
                    (_covertWeight + _overtWeight) min 4
                };

                private _civicInstallationMultiplier = ([_objective,"civicInstallationMultiplier",1] call ALiVE_fnc_INS_getHostilitySetting) max 0;
                if (_civicInstallationMultiplier > 0) then {
                    private _pressureSide = if (count _insurgentSides > 0) then {_insurgentSides select 0} else {"EAST"};
                    private _hmPressureData = [_pos,_pressureSide,1200] call ALiVE_fnc_INS_getHeartsAndMindsPressure;
                    _hmPressureData params [["_hmPressure",0]];
                    private _civicDampening = ((_hmPressure / 100) * (0.8 * _civicInstallationMultiplier)) min 0.95;
                    _supportWeight = round (_supportWeight * ((1 - _civicDampening) max 0));
                };

                if (_supportWeight <= 0) exitwith {0};

                private _insurgentShift = -(_supportWeight * _installationMultiplier);
                private _otherShift = ((ceil (_supportWeight / 2)) min 2) * _installationMultiplier;

                [_pos,_insurgentSides,_insurgentShift] call ALiVE_fnc_updateSectorHostility;
                [_pos,_allSides - _insurgentSides,_otherShift] call ALiVE_fnc_updateSectorHostility;

                _insurgentShift
};

ALiVE_fnc_INS_assault = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_objective","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _sides = _this select 5;
                _agents = _this select 6;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};
                if (isNil "_objective" || {[_objective,"deleted",false] call ALiVE_fnc_HashGet}) exitWith {};

                // Add TACOM suicide command on one ambient civilian agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_suicideTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_CAPTURE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

// Takes an IED trigger's IEDs off the map for good. The IED module keeps them in its store under
// the key the trigger's order names and puts them back each time the trigger fires, and only the
// trigger's deactivation (players leaving) takes them off again, which deleting the trigger skips.
ALiVE_fnc_INS_clearIEDs = {
                params ["_key", "_pos"];

                if (isNil "ALiVE_mil_ied_STORE") exitwith {};
                private _allIEDs = [ALiVE_mil_ied_STORE, "IEDs"] call ALiVE_fnc_HashGet;
                if (isNil "_allIEDs") exitwith {};
                if (isNil {[_allIEDs, _key] call ALiVE_fnc_HashGet}) exitwith {};

                [_pos, _key] call ALIVE_fnc_removeIED;
                [_allIEDs, _key] call ALiVE_fnc_HashRem;
};

ALiVE_fnc_INS_ambush = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_road","_roadObject","_objective","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _road = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _roadObject = [[],"convertObject",_road] call ALiVE_fnc_OPCOM;

                // Establish ambush position
                if (alive _roadObject) then {[_objective,"ambush",_road] call ALiVE_fnc_HashSet};

                // Add TACOM suicide command on one ambient civilian agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                // Place ambient IED trigger. Its IEDs are kept under a key of their own: the town's IED
                // trigger uses the town's, and 2 triggers on one key put back and take away each
                // other's IEDs.
                private _ambushKey = format ["%1-ambush", _id];
                private _trg = objNull;
                if (!isnil "ALiVE_mil_IED") then {
                    _trg = createTrigger ["EmptyDetector",getposATL _roadObject];
                    _trg setTriggerArea [_size + 250, _size + 250,0,false];
                    _trg setTriggerActivation ["ANY","PRESENT",true];
                    _trg setTriggerStatements [
                        "this && {(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0",
                            format["null = [getpos thisTrigger,%1,'%2',%3] call ALIVE_fnc_createIED",100,_ambushKey,ceil(random 2)],
                            format["null = [getpos thisTrigger,'%1'] call ALIVE_fnc_removeIED",_ambushKey]
                    ];
                };

                _event = ['OPCOM_RECON',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;

                // Wait 15 minutes for any enemy vehicles to pass before reassigning
                _timeTaken = time; waituntil {time - _timeTaken > 900};

                // Remove ambush marker
                if (alive _roadObject) then {deletemarker format["Ambush_%1",getposATL _roadObject]; [_objective,"ambush"] call ALiVE_fnc_HashRem};

                // And its IED trigger with any IEDs it has out, so the road isn't mined for good once
                // the ambush is over. The trigger goes first, so nobody sets it off in between, and
                // the IEDs are cleared even if the trigger has already gone: Military IED deletes
                // the triggers within 3 m of an IED it takes away.
                if (!isNull _trg) then { deleteVehicle _trg };
                [_ambushKey, getposATL _roadObject] call ALiVE_fnc_INS_clearIEDs;
};

// Harassing Fire (Eric on Discord, 22 Oct): the cell has reached its firing point, 400 to 700 m from enemy troops near
// the objective. With a player near enough for it to be on the map it sets up a mortar, fires a few rounds at them,
// packs up and drives back towards the objective; otherwise the attack is only counted. The gun never outlives the
// action: every way out goes through one release
ALiVE_fnc_INS_harass = {
                params ["_timeTaken", "_pos", "_id", "_size", "_faction", "_target", "_targetID", "_center"];
                private _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;
                private _side = _faction call ALiVE_fnc_factionSide;
                private _sideText = [[_side] call ALiVE_fnc_sideObjectToNumber] call ALiVE_fnc_sideNumberToText;
                private _say = { ["ALiVE [INS_harass] objective %1: %2", _id, _this] call ALiVE_fnc_dump };
                // where the enemy is now, not where they were when the attack was picked; gone, nothing to fire at
                if (_targetID != "") then {
                    private _tp = [ALIVE_profileHandler, "getProfile", _targetID] call ALIVE_fnc_profileHandler;
                    if (isNil "_tp") then { _target = [] } else { _target = [_tp, "position", _target] call ALiVE_fnc_HashGet };
                };
                if (isNil "_objective") exitWith { "objective gone" call _say };
                if (_target isEqualTo []) exitWith { "the enemy it was after is gone" call _say };
                private _section = [_objective,"section",[]] call ALiVE_fnc_HashGet;
                if (_section isEqualTo []) exitWith { "no cell" call _say };
                private _profile = [ALIVE_profileHandler, "getProfile", _section select 0] call ALIVE_fnc_profileHandler;
                if (isNil "_profile") exitWith { "cell gone" call _say };

                // not on the map: nobody is near enough to see it, so the attack is only counted
                if !([_profile,"active",false] call ALiVE_fnc_HashGet) exitWith {
                    format ["no player near, attack on %1 counted, nothing fired", mapGridPosition _target] call _say;
                    [_timeTaken,_target,[_side],20,["EAST","WEST","GUER"],_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
                    sleep 120;
                };

                // the mortar: the faction's own, else the side's standard one
                private _class = ((_faction call ALIVE_fnc_configGetFactionArtilleryVehicles) select { _x isKindOf "StaticMortar" }) param [0, ""];
                if (_class == "") then { _class = switch (_sideText) do { case "WEST": {"B_Mortar_01_F"}; case "GUER": {"I_Mortar_01_F"}; default {"O_Mortar_01_F"} } };
                private _group = [_profile,"group",grpNull] call ALiVE_fnc_HashGet;
                private _units = (units _group) select { alive _x };
                if (isNull _group || {_units isEqualTo []}) exitWith { "cell has no one left" call _say };

                // the gunner: not the leader where there is anyone else, so the cell's moves don't pull him off the tube
                private _gunner = if (count _units > 1) then { _units select 1 } else { _units select 0 };
                [_profile, "clearActiveCommands"] call ALIVE_fnc_profileEntity;
                [_profile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                private _spot = getPosATL _gunner getPos [5, random 360];
                private _gun = createVehicle [_class, _spot, [], 0, "NONE"];
                _gun setDir (_spot getDir _target);
                _gun setVariable ["ALiVE_INS_harassGun", _id, true];
                [_gunner, "PATH"] remoteExec ["disableAI", _gunner];
                [_gunner, _gun] remoteExec ["moveInGunner", _gunner];

                private _release = {
                    if (!isNull _gunner && {alive _gunner}) then {
                        [_gunner, "PATH"] remoteExec ["enableAI", _gunner];
                        if (vehicle _gunner == _gun) then { _gunner remoteExec ["moveOut", _gunner] };
                    };
                    if (!isNull _gun) then {
                        private _eh = _gun getVariable ["ALiVE_INS_harassEH", -1];
                        if (_eh >= 0) then { [_gun, ["Fired", _eh]] remoteExec ["removeEventHandler", _gun] };
                        // deleting a crewed gun deletes its crew: the gunner is out first (or dead, or 10 s gone by)
                        private _w = time;
                        waitUntil { sleep 0.5; isNull _gunner || {!alive _gunner} || {vehicle _gunner != _gun} || {time - _w > 10} };
                        deleteVehicle _gun;
                    };
                };
                private _gone = { isNull _gun || {!alive _gun} || {!alive _gunner} || {isNull _group} };

                private _t0 = time;
                waitUntil { sleep 1; (gunner _gun == _gunner) || {call _gone} || {time - _t0 > 30} };
                if (call _gone || {gunner _gun != _gunner}) exitWith { "the gunner never got to the mortar" call _say; call _release };

                // a round it carries, and the target within its reach
                private _mag = (getArtilleryAmmo [_gun]) param [0, ""];
                if (_mag == "" || {!(_target inRangeOfArtillery [[_gun], _mag])}) exitWith {
                    format ["target %1 out of the mortar's reach from %2", mapGridPosition _target, mapGridPosition _gun] call _say; call _release
                };

                // counted where the gun is local (a headless client may own it), read here from the public count
                _gun setVariable ["ALiVE_INS_harassFired", 0, true];
                [[_gun], {
                    params ["_g"];
                    private _eh = _g addEventHandler ["Fired", { (_this select 0) setVariable ["ALiVE_INS_harassFired", ((_this select 0) getVariable ["ALiVE_INS_harassFired", 0]) + 1, true] }];
                    _g setVariable ["ALiVE_INS_harassEH", _eh, true];
                }] remoteExec ["call", _gun];

                private _rounds = 3 + floor random 3;
                format ["team %1 sets up at %2, %3 rounds at %4", _section select 0, mapGridPosition _gun, _rounds, mapGridPosition _target] call _say;
                [_gun, [_target, _mag, _rounds]] remoteExec ["doArtilleryFire", _gun];
                _t0 = time;
                waitUntil { sleep 2; ((_gun getVariable ["ALiVE_INS_harassFired", 0]) >= _rounds) || {call _gone} || {time - _t0 > 120} };
                format ["%1 rounds fired at %2", _gun getVariable ["ALiVE_INS_harassFired", 0], mapGridPosition _target] call _say;
                [_timeTaken,_target,[_side],20,["EAST","WEST","GUER"],_objective] call ALiVE_fnc_INS_updateHostilityByPresence;

                // scoot: pack up, and the commander's own moves take the cell back towards the objective, as it would any
                // section whose point has moved
                sleep 20;
                call _release;
                private _exfil = +_center;
                private _actions = [_objective,"actions",[]] call ALiVE_fnc_HashGet;
                if (_actions isNotEqualTo []) then { _actions set [1, _exfil] };
                "packed up" call _say;
                _t0 = time;
                waitUntil {
                    sleep 5;
                    private _p = [ALIVE_profileHandler, "getProfile", _section select 0] call ALIVE_fnc_profileHandler;
                    isNil "_p" || {([_p,"position",_exfil] call ALiVE_fnc_HashGet) distance2D _exfil < 100} || {time - _t0 > 300}
                };
};

ALiVE_fnc_INS_retreat = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_objective","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _sides = _this select 5;
                _agents = _this select 6;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_allSides - _sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                //remove installations if existing
                // Hash keys match case-sensitively and the recruitment HQ is stored as "HQ"
                // (INS_recruit), so "hq" never found it: a retreat left the HQ standing and
                // recruiting. "roadblocks" stays out on purpose: it holds the nearest building
                // as a marker for where the roadblocks went, and the roadblocks themselves are
                // run by the roadblock system, which has its own capture and disable.
                {
                    _object = [[],"convertObject",[_objective,_x,[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

                    if (alive _object) then {
                        // Only the factory, HQ and depot are the insurgents' own buildings, so only they
                        // come down. The ied and suicide keys hold the nearest house, wall or road as a
                        // stand-in for their trigger (the trigger itself only when nothing stood within
                        // 150 m), ambush a road piece and sabotage the building the insurgents were sent
                        // to wreck: damaging those flattened whatever stood there. A stored trigger is
                        // deleted, as before; anything else is left alone.
                        if (_x in ["factory","HQ","depot"]) then {
                            _object setdamage 1;
                        } else {
                            if (_object isKindOf "EmptyDetector") then {deletevehicle _object};
                        };
                        // The markers are named in lower case (hq_<id>, as insurgency.fsm makes it).
                        deleteMarker format["%1_%2",toLower _x,_id];
                    };

                    [_objective,_x] call ALiVE_fnc_HashRem;
                } foreach ["factory","HQ","ambush","depot","sabotage","ied","suicide"];

                // The IED and suicide bomber triggers themselves sit on the objective's centre (INS_ied
                // and INS_suicide are handed the same centre as this retreat), and the objective only
                // keeps a stand-in for them, so they were never removed: the town went on planting IEDs
                // and sending bombers after the insurgents had gone, and a later IED action added another.
                // Only this town's: Military IED's own triggers can share the centre. The IED one names
                // the town in its order, the bomber one carries its id.
                {
                    private _act = (triggerStatements _x) param [1, ""];
                    if (((_act find "ALIVE_fnc_createIED") > -1 && {(_act find _id) > -1}) || {(_x getVariable ["ALiVE_INS_objectiveID", ""]) == _id}) then {
                        deleteVehicle _x;
                    };
                } forEach (_pos nearObjects ["EmptyDetector", 1]);
                // Deleting the IED trigger skips its deactivation, so take the town's IEDs off here,
                // and an ambush's too: with the objective's ambush gone, nothing would clear them.
                [_id, _pos] call ALiVE_fnc_INS_clearIEDs;
                [format ["%1-ambush", _id], _pos] call ALiVE_fnc_INS_clearIEDs;
                // And the IED module's record of the trigger, which a persistent reload would build it back from.
                if (!isNil "ALiVE_mil_ied_STORE") then {
                    private _storedTriggers = [ALiVE_mil_ied_STORE, "triggers"] call ALiVE_fnc_HashGet;
                    if (!isNil "_storedTriggers") then {
                        [_storedTriggers, format ["%1-IED", _id]] call ALiVE_fnc_HashRem;
                    };
                };

                // Reset all actions done on that objective so they can be performed again
                [_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashSet;

                // Reduce hostility level after retreat
                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;

                _event = ['OPCOM_DEFEND',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
};

ALiVE_fnc_INS_factory = {
                private ["_timeTaken","_pos","_center","_id","_size","_faction","_sides","_agents","_building","_objective","_CQB","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Startup can hand us either a persisted [pos, class] ref or the live building object.
                if !(_factory isEqualType objNull) then {
                    _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;
                };

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Timeout
                waituntil {time - _timeTaken > 120};
                if (isNil "_objective" || {[_objective,"deleted",false] call ALiVE_fnc_HashGet}) exitWith {};

                // Store center position
                _center = _pos;

                // Establish factory
                if (alive _factory) then {
                    // Get indoor Housepos
                    _pos = getposATL _factory;
                    _positions = [_pos,15] call ALIVE_fnc_findIndoorHousePositions;
                    _pos = if (count _positions > 0) then {(selectRandom _positions)} else {_pos};

                    // Create factory
                    [_factory,_id,_faction] call ALiVE_fnc_INS_spawnIEDfactory;

                    // Create virtual guards
                    {[_x,"addHouse",_factory] call ALiVE_fnc_CQB} foreach _CQB;

                    // Set factory
                    [_objective,"factory",[[],"convertObject",_factory] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_getWeapons", "managed", [_pos]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                // Reset to center position
                _pos = _center;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_ied = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_section","_objective", "_num"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};
                if (isNil "_objective" || {[_objective,"deleted",false] call ALiVE_fnc_HashGet}) exitWith {};

                // If IED module is used add IEDs and VBIEDs according to IED module settings
                if (!isnil "ALiVE_MIL_IED") then {
                    // One IED trigger per town. On a persistent load Military IED has already rebuilt
                    // the one it has on record by the time this runs again, and 2 triggers on one
                    // town put its IEDs out twice. The standing one gives the same orders, so keep it.
                    private _trg = objNull;
                    private _standing = (_pos nearObjects ["EmptyDetector", 1]) select {
                        private _act = (triggerStatements _x) param [1, ""];
                        (_act find "ALIVE_fnc_createIED") > -1 && {(_act find _id) > -1}
                    };
                    if (_standing isEqualTo []) then {
                        _trg = createTrigger ["EmptyDetector",_pos];
                        _trg setTriggerArea [_size + 250, _size + 250,0,false];
                        _trg setTriggerActivation ["ANY","PRESENT",true];
                        _num = ceil(_size/100);
                        _trg setTriggerStatements [
                            "this && {(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0",
                                format["null = [getpos thisTrigger,%1,'%2',%3] call ALIVE_fnc_createIED",_size,text _id,_num],
                                format["null = [getpos thisTrigger,'%1'] call ALIVE_fnc_removeIED",text _id]
                        ];

                        [MOD(MIL_IED), "storeTrigger", [_size,format["%1",_id],_pos,true,"IED",_num]] call ALiVE_fnc_IED;
                    } else {
                        _trg = _standing select 0;
                    };

                    [_pos,_size,1] call ALiVE_fnc_placeVBIED;

                    _placeholders = ((nearestobjects [_pos,["Static"],150]) + (_pos nearRoads 150));
                    if (!isnil "_placeholders" && {count _placeholders > 0}) then {_trg = _placeholders select 0};

                    [_objective,"ied",[[],"convertObject",_trg] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM rogue command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_suicide = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_objective","_civFactions"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _civFactions = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};
                if (isNil "_objective" || {[_objective,"deleted",false] call ALiVE_fnc_HashGet}) exitWith {};

                // Place ambient suiciders trigger
                if (!isnil "ALiVE_mil_IED") then {
                    _trg = createTrigger ["EmptyDetector",_pos];
                    _trg setTriggerArea [_size + 250, _size + 250,0,false];
                    _trg setTriggerActivation ["ANY","PRESENT",false];
                    _trg setTriggerStatements [
                        "this && ({(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)",
                        format ["null = [[getpos thisTrigger,%1,'%2'],thisList] call ALIVE_fnc_createBomber", _size, (selectRandom _civFactions)],
                         ""
                    ];
                    // Named for the town, so a retreat can tell it from Military IED's own bomber
                    // trigger, which can sit on the same centre.
                    _trg setVariable ["ALiVE_INS_objectiveID", _id];

                    _placeholders = ((nearestobjects [_pos,["Static"],150]) + (_pos nearRoads 150));
                    if (!isnil "_placeholders" && {count _placeholders > 0}) then {_trg = _placeholders select 0};

                    [_objective,"suicide",[[],"convertObject",_trg] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM suicide command on one ambient civilian agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_suicideTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_sabotage = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_target","_profileID","_objective"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _target = _this select 6;
                _sides = _this select 7;
                _agents = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;
                _target = [[],"convertObject",_target] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};
                if (isNil "_objective" || {[_objective,"deleted",false] call ALiVE_fnc_HashGet}) exitWith {};

                // Assign sabotage target
                if (alive _target) then {[_objective,"sabotage",[[],"convertObject",_target] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet};

                // Add TACOM Sabotage command on all selected agents
                {
                    private ["_agent"];
                     _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_sabotage", "managed", [getposATL _target]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;

                // Wait 15 minutes for Sabotage to happen
                _timeTaken = time; waituntil {time - _timeTaken > 900};
};

ALiVE_fnc_INS_getRoadblockPosition = {
                params [["_roadblockSource", objNull, [objNull, []]]];

                if (_roadblockSource isEqualType objNull) then {
                    getPosATL _roadblockSource
                } else {
                    _roadblockSource
                };
};

ALiVE_fnc_INS_getRoadblockCompositionHandlers = {
                params [["_roadblockSource", objNull, [objNull, []]]];

                private _roadblockPos = [_roadblockSource] call ALiVE_fnc_INS_getRoadblockPosition;
                (nearestObjects [_roadblockPos, ["ALIVE_DemoCharge_Remote_Ammo"], 5]) select {
                    !((_x getVariable ["ALiVE_X_LIB_COMPOSITION_OBJECTS", []]) isEqualTo [])
                }
};

ALiVE_fnc_INS_getRoadblockActionObject = {
                params [["_roadblockSource", objNull, [objNull, []]]];

                private _roadblockPos = [_roadblockSource] call ALiVE_fnc_INS_getRoadblockPosition;

                private _actionObject = objNull;
                private _compositionHandlers = [_roadblockSource] call ALiVE_fnc_INS_getRoadblockCompositionHandlers;
                private _compositionObjects = [];
                {
                    _compositionObjects append (_x getVariable ["ALiVE_X_LIB_COMPOSITION_OBJECTS", []]);
                } forEach _compositionHandlers;

                _compositionObjects = _compositionObjects select {!isNull _x};

                private _barGates = _compositionObjects select {
                    _x isKindOf "Land_BarGate_F"
                };

                if !(_barGates isEqualTo []) then {
                    _barGates = [_barGates, [_roadblockPos], {_input0 distance2D _x}, "ASCEND"] call BIS_fnc_sortBy;
                } else {
                    // Only scan loose gates for legacy roadblocks without composition data.
                    if (_compositionHandlers isEqualTo []) then {
                        _barGates = nearestObjects [_roadblockPos, ["Land_BarGate_F"], 20];
                    };
                };

                if !(_barGates isEqualTo []) then {
                    _actionObject = _barGates select 0;
                } else {
                    private _helpers = (nearestObjects [_roadblockPos, ["RoadCone_L_F", "Box_FIA_Wps_F"], 12]) select {
                        _x getVariable [QGVAR(ROADBLOCK_HELPER), false]
                    };
                    private _coneHelpers = _helpers select {typeOf _x == "RoadCone_L_F"};

                    if !(_coneHelpers isEqualTo []) then {
                        _actionObject = _coneHelpers deleteAt 0;
                    };

                    {
                        deleteVehicle _x;
                    } forEach (_helpers - [_actionObject]);

                    if (isNull _actionObject) then {
                        private _nearRoads = _roadblockPos nearRoads 10;
                        private _anchorPos = +_roadblockPos;
                        private _direction = 0;

                        if !(_nearRoads isEqualTo []) then {
                            private _road = _nearRoads select 0;
                            private _connectedRoads = roadsConnectedTo _road;

                            if !(_connectedRoads isEqualTo []) then {
                                _direction = _road getDir (_connectedRoads select 0);
                            };

                            _anchorPos = getPosATL _road;
                        };

                        _actionObject = createVehicle ["RoadCone_L_F", _anchorPos, [], 0, "CAN_COLLIDE"];
                        _actionObject allowDamage false;
                        _actionObject enableSimulationGlobal false;
                        _actionObject setDir _direction;
                        _actionObject setPosATL (_anchorPos getPos [6, _direction + 90]);
                        _actionObject setVectorUp (surfaceNormal (getPosWorld _actionObject));
                        _actionObject setVariable [QGVAR(ROADBLOCK_HELPER), true, true];
                    };
                };

                _actionObject
};

ALiVE_fnc_INS_addRoadblockHoldAction = {
                params [["_roadblockSource", objNull, [objNull, []]]];

                private _actionObject = [_roadblockSource] call ALiVE_fnc_INS_getRoadblockActionObject;
                if (isNull _actionObject) exitwith {};

                if (_actionObject getVariable [QGVAR(ROADBLOCK_DISABLED), false]) exitwith {};
                if (_actionObject getVariable [QGVAR(ROADBLOCK_ACTION_ADDED), false]) exitwith {};
                _actionObject setVariable [QGVAR(ROADBLOCK_ACTION_ADDED), true, true];

                private _chargePos = [_roadblockSource] call ALiVE_fnc_INS_getRoadblockPosition;

                private _charge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo", _chargePos, [], 0, "CAN_COLLIDE"];
                _charge hideObjectGlobal true;
                _charge allowDamage false;

                [
                    _actionObject,
                    "disable the roadblock!",
                    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                    "_this distance2D _target < 8 && {!(_target getVariable ['ALiVE_MIL_OPCOM_ROADBLOCK_DISABLED', false])}",
                    "_caller distance2D _target < 8 && {!(_target getVariable ['ALiVE_MIL_OPCOM_ROADBLOCK_DISABLED', false])}",
                    {},
                    {},
                    {
                        params ["_target", "_caller", "_ID", "_arguments"];

                        private _charge = _arguments select 0;

                        _target setVariable [QGVAR(ROADBLOCK_DISABLED), true, true];
                        [_target, _ID] remoteExec ["BIS_fnc_holdActionRemove", 0, _target];

                        [getPosATL _charge, 30] remoteExec ["ALiVE_fnc_RemoveComposition", 2];

                        ["Nice Job", format ["%1 disabled the roadblock at grid %2!", name _caller, mapGridPosition _target]] remoteExec ["BIS_fnc_showSubtitle", side (group _caller)];

                        if (_target getVariable [QGVAR(ROADBLOCK_HELPER), false]) then {
                            deleteVehicle _target;
                        };

                        deleteVehicle _charge;
                    },
                    {},
                    [_charge],
                    15
                // A dedicated server has no player to hold this, and running the game's hold-action code
                // there throws on some buildings (fn_holdAction_showIcon), so only players' machines get it.
                ] remoteExec ["BIS_fnc_holdActionAdd", [0, -2] select isDedicated, _actionObject];
};

ALiVE_fnc_INS_addRoadblockHoldActionWhenReady = {
                params [["_roadblockSource", objNull, [objNull, []]]];

                [_roadblockSource] spawn {
                    params [["_roadblockSource", objNull, [objNull, []]]];

                    private _timeout = time + 10;
                    waitUntil {
                        sleep 0.25;
                        !(([_roadblockSource] call ALiVE_fnc_INS_getRoadblockCompositionHandlers) isEqualTo []) ||
                        {time > _timeout}
                    };

                    [_roadblockSource] call ALiVE_fnc_INS_addRoadblockHoldAction;
                };
};

ALiVE_fnc_INS_roadblocks = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_CQB","_objective"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _handle = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};
                if (isNil "_objective" || {[_objective,"deleted",false] call ALiVE_fnc_HashGet}) exitWith {};

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Spawn CQB
                [_pos,_size,_CQB] call ALiVE_fnc_addCQBpositions;

                // Spawn roadblock only until a max amount of roadblocks per objective is reached (size 600 will allow for 3 roadblocks)
                if (isnil "ALiVE_CIV_PLACEMENT_ROADBLOCKS" || {{_pos distance _x < _size} count ALiVE_CIV_PLACEMENT_ROADBLOCKS < ceil(_size/200)}) then {
                    private _roads = [_pos, _size, ceil(_size/200), false] call ALiVE_fnc_createRoadblock;

                    // Create disable action on newly created roadblocks
                    {
                        [_x] call ALiVE_fnc_INS_addRoadblockHoldActionWhenReady;
                    } foreach _roads;
                };

                // Identify location
                [_objective,"roadblocks",[[],"convertObject",_pos nearestObject "building"] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;

                _event = ['OPCOM_RESERVE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_depot = {
                private ["_timeTaken","_center","_id","_size","_faction","_sides","_agents","_depot","_CQB","_objective"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _depot = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Store center position
                _center = _pos;

                // Startup can hand us either a persisted [pos, class] ref or the live building object.
                if !(_depot isEqualType objNull) then {
                    _depot = [[],"convertObject",_depot] call ALiVE_fnc_OPCOM;
                };

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Timeout
                waituntil {time - _timeTaken > 120};
                if (isNil "_objective" || {[_objective,"deleted",false] call ALiVE_fnc_HashGet}) exitWith {};

                // Establish Depot
                if (alive _depot) then {
                    [_depot,_id,_faction] call ALiVE_fnc_INS_spawnDepot;

                    // Create virtual guards
                    {[_x,"addHouse",_depot] call ALiVE_fnc_CQB} foreach _CQB;

                    // Set depot
                    [_objective,"depot",[[],"convertObject",_depot] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM get weapons command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;
                    if (!isnil "_agent" && {_foreachIndex < 3}) then {[_agent, "setActiveCommand", ["ALIVE_fnc_cc_getWeapons", "managed", [_pos]]] call ALIVE_fnc_civilianAgent};
                } foreach _agents;

                // Restore center position
                _pos = _center;

                // Spawn CQB
                [_pos,_size,_CQB] call ALiVE_fnc_addCQBpositions;

                _event = ['OPCOM_RESERVE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_recruit = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_HQ","_CQB","_objective","_center","_opcom","_forceLimit","_recruitCycleMin","_recruitCycleMax","_recruitAttemptLimit","_recruitSuccessChance","_opcomFactions","_civicRecruitmentMultiplier"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _HQ = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;
                _opcom = [_objective] call ALiVE_fnc_INS_getOpcomByObjective;
                _forceLimit = -1;
                _recruitCycleMin = 1800;
                _recruitCycleMax = 3600;
                _recruitAttemptLimit = 0;
                _recruitSuccessChance = 0.5;
                _opcomFactions = [_faction];
                _civicRecruitmentMultiplier = 1;

                if !(isnil "_opcom") then {
                    _forceLimit = floor ([_opcom,"asymForceLimit",-1] call ALiVE_fnc_HashGet);
                    _recruitCycleMin = (([_opcom,"recruitCycleMin",30] call ALiVE_fnc_HashGet) max 0) * 60;
                    _recruitCycleMax = (([_opcom,"recruitCycleMax",60] call ALiVE_fnc_HashGet) max 0) * 60;
                    _recruitAttemptLimit = floor ([_opcom,"recruitAttemptLimit",0] call ALiVE_fnc_HashGet);
                    _recruitAttemptLimit = _recruitAttemptLimit max -1;
                    _recruitSuccessChance = ((([_opcom,"recruitSuccessChance",50] call ALiVE_fnc_HashGet) max 0) min 100) / 100;
                    _opcomFactions = [_opcom,"factions",[_faction]] call ALiVE_fnc_HashGet;
                    _civicRecruitmentMultiplier = ([_opcom,"civicRecruitmentMultiplier",1] call ALiVE_fnc_HashGet) max 0;
                };

                if (_recruitCycleMax < _recruitCycleMin) then {_recruitCycleMax = _recruitCycleMin};

                // Store center position
                _center = _pos;

                // Startup can hand us either a persisted [pos, class] ref or the live building object.
                if !(_HQ isEqualType objNull) then {
                    _HQ = [[],"convertObject",_HQ] call ALiVE_fnc_OPCOM;
                };

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Establish HQ
                if (alive _HQ) then {
                    // Create HQ
                    [_HQ,_id,_faction] call ALiVE_fnc_INS_spawnHQ;

                    // Get indoor Housepos
                    _pos = getposATL _HQ;
                    _positions = [_pos,15] call ALIVE_fnc_findIndoorHousePositions;
                    _pos = if (count _positions > 0) then {(selectRandom _positions)} else {_pos};

                    // Create virtual guards
                    {[_x,"addHouse",_HQ] call ALiVE_fnc_CQB} foreach _CQB;

                    // Set HQ
                    [_objective,"HQ",[[],"convertObject",_HQ] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;

                    // Recruiters: one stands in the HQ while players are near, and his death stops the town recruiting.
                    if (!isNil "_opcom" && {[_opcom, "recruiters", false] call ALiVE_fnc_HashGet}) then {
                        [_HQ, _faction, _pos, _recruitCycleMax max 600, _opcom] spawn ALiVE_fnc_INS_recruiterPresence;
                    };

                    // A recruiter worth killing (#426): with the commander's Recruiter HVT Task
                    // Chance, every hostile side with players is given an Assassination task at the
                    // new Recruitment HQ, through the same direct channel the convoy tasks use. Once per town.
                    private _hvtChance = if (isNil "_opcom") then {0} else {[_opcom,"recruiterTaskChance",0] call ALiVE_fnc_HashGet};
                    if (_hvtChance > 0 && {!([_objective,"recruiterTaskRaised",false] call ALiVE_fnc_HashGet)} && {random 100 < _hvtChance} && {!isNil "ALIVE_eventLog"}) then {
                        [_objective,"recruiterTaskRaised",true] call ALiVE_fnc_HashSet;
                        private _insSide = if (_side isEqualType "") then {[_side] call ALiVE_fnc_sideTextToObject} else {_side};
                        // One recruiter task open per side at a time. The commander sets up most of its
                        // Recruitment HQs in the first minutes, and each one raised a task at once, so a side
                        // started with ten HVT tasks. Now an HQ waits until its side has none open, then raises
                        // its own, for as long as the HQ stands, so the HQs come up one after another. A task
                        // counts as open while its HVT step (_c1) is neither done nor failed, or for two minutes
                        // after it is raised, before the task handler has it.
                        [_HQ, _id, _faction, _insSide] spawn {
                            params ["_HQ", "_id", "_faction", "_insSide"];
                            private _waiting = (["EAST","WEST","GUER"] - [str _insSide]) select {
                                (([_x] call ALiVE_fnc_sideTextToObject) getFriend _insSide) < 0.6
                            };
                            while {alive _HQ && {_waiting isNotEqualTo []}} do {
                                {
                                    private _hSideText = _x;
                                    private _hp = [_hSideText] call ALiVE_fnc_getPlayersDataSource;
                                    private _pObj = if (count (_hp select 1) > 0) then {[(_hp select 1) select 0] call ALIVE_fnc_getPlayerByUID} else {objNull};
                                    private _recruiterTaskId = format ["%1_recruiter_%2_%3", _id, _hSideText, round time];
                                    // checked and claimed in one unscheduled step, so two HQs waking together can't both
                                    // see the side free; a task nobody goes after stops counting as open after an hour
                                    private _claimed = !isNull _pObj && {isNil {
                                        private _openKey = format ["ALiVE_INS_recruiterTask_%1", _hSideText];
                                        (missionNamespace getVariable [_openKey, ["", -1e6]]) params ["_openId", "_openAt"];
                                        private _open = (time - _openAt) < 120 || {(time - _openAt) < 3600 && {!isNil "ALIVE_taskHandler"} && {
                                            private _hvtStep = [ALIVE_taskHandler, "getTask", _openId + "_c1"] call ALIVE_fnc_taskHandler;
                                            !isNil "_hvtStep" && {!((_hvtStep select 8) in ["Succeeded", "Failed", "Canceled"])}
                                        }};
                                        if (_open) then { false } else { missionNamespace setVariable [_openKey, [_recruiterTaskId, time]]; nil }
                                    }};
                                    if (_claimed) then {
                                        private _taskData = [_recruiterTaskId, "OPCOM", _hSideText, faction _pObj,
                                            "Assassination", "NULL", getPosATL _HQ, [_hp select 1, _hp select 0], _faction, "Y", "Side"];
                                        private _tEvent = ["TASK_GENERATE", _taskData, "OPCOM"] call ALIVE_fnc_event;
                                        [ALIVE_eventLog, "addEvent", _tEvent] call ALIVE_fnc_eventLog;
                                        ["ALiVE OPCOM: recruiter task raised for %1 at the Recruitment HQ near %2", _hSideText, mapGridPosition _HQ] call ALiVE_fnc_dump;
                                        private _tasks = _HQ getVariable ["ALiVE_INS_recruiterTasks", []];
                                        _tasks pushBack [_recruiterTaskId, time];
                                        _HQ setVariable ["ALiVE_INS_recruiterTasks", _tasks];
                                        _waiting = _waiting - [_hSideText];
                                    };
                                } forEach +_waiting;
                                if (_waiting isNotEqualTo []) then { sleep 30 };
                            };
                        };
                    };
                };

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;
                    if (!isnil "_agent" && {_foreachIndex < 3}) then {[_agent, "setActiveCommand", ["ALIVE_fnc_cc_getWeapons", "managed", [_pos]]] call ALIVE_fnc_civilianAgent};
                } foreach _agents;

                // Restore center position
                _pos = _center;

                // Add CQB
                [_pos,_size,_CQB] call ALiVE_fnc_addCQBpositions;

                // Run recruitment attempts while the HQ survives.
                [_timeTaken,_pos,_size,_id,_faction,_HQ,_sides,_agents,_forceLimit,_recruitCycleMin,_recruitCycleMax,_recruitAttemptLimit,_recruitSuccessChance,_opcomFactions,_civicRecruitmentMultiplier,_side,_objective] spawn {
                    private ["_timeTaken","_pos","_size","_id","_faction","_targetBuilding","_sides","_agents","_forceLimit","_recruitCycleMin","_recruitCycleMax","_recruitAttemptLimit","_recruitSuccessChance","_opcomFactions","_civicRecruitmentMultiplier","_currentForce","_attemptsRemaining","_side","_objective"];

                    _timeTaken = _this select 0;
                    _pos = _this select 1;
                    _size = _this select 2;
                    _id = _this select 3;
                    _faction = _this select 4;
                    _HQ = _this select 5;
                    _sides = _this select 6;
                    _agents = _this select 7;
                    _forceLimit = _this select 8;
                    _recruitCycleMin = _this select 9;
                    _recruitCycleMax = _this select 10;
                    _recruitAttemptLimit = _this select 11;
                    _recruitSuccessChance = _this select 12;
                    _opcomFactions = _this select 13;
                    _civicRecruitmentMultiplier = _this select 14;
                    _side = _this select 15;
                    _objective = _this select 16;
                    _allSides = ["EAST","WEST","GUER"];

                    // Escalation intensity, its tier roster and the escalation level live on the
                    // commander. A spawned script cannot see the caller's _opcom, so without this
                    // it was always nil here and every recruit came from the infantry-only path.
                    private _opcom = if (isNil "_objective") then {nil} else {[_objective] call ALiVE_fnc_INS_getOpcomByObjective};

                    _attemptsRemaining = if (_recruitAttemptLimit == 0) then {count _agents} else {_recruitAttemptLimit};

                    // The newest loop owns the building. A new HQ set up in the building of a disabled one
                    // clears the disabled flag, which would wake this loop as well, and 2 loops recruited
                    // from the one building.
                    ALiVE_INS_recruitLoopCount = (missionNamespace getVariable ["ALiVE_INS_recruitLoopCount", 0]) + 1;
                    private _loopToken = ALiVE_INS_recruitLoopCount;
                    _HQ setVariable ["ALiVE_MIL_OPCOM_HQ_RECRUITLOOP", _loopToken];

                    // A disabled HQ stands, so alive alone kept it recruiting after a player or friendly
                    // AI had disabled it. The flag is cleared if a new HQ is set up in the building.
                    while {alive _HQ && {!(_HQ getVariable ["ALiVE_MIL_OPCOM_HQ_DISABLED", false])} && {(_HQ getVariable ["ALiVE_MIL_OPCOM_HQ_RECRUITLOOP", _loopToken]) == _loopToken} && {_attemptsRemaining != 0} && {!isNil "_objective"} && {!([_objective,"deleted",false] call ALiVE_fnc_HashGet)}} do {

                        private _hmPressureData = [_pos,_side,(_size + 600) max 900] call ALiVE_fnc_INS_getHeartsAndMindsPressure;
                        _hmPressureData params [["_hmPressure",0],["_hmPhase","Stabilize"]];

                        private _effectivePressure = ((_hmPressure * _civicRecruitmentMultiplier) max 0) min 100;
                        // War on Drugs (#1080): every standing drug lab speeds recruitment, up to twice as fast with 4
                        private _labs = if (isNil "_opcom") then {0} else {[_opcom] call ALiVE_fnc_INS_countStandingLabs};
                        private _delayMultiplier = (1 + (0.01 * _effectivePressure)) / (1 + 0.25 * (_labs min 4));
                        // Recruiter Boost (#1088): while the town's recruiter is alive (Recruiters on, not killed and not
                        // waiting to come back) this HQ recruits faster, and below with a better chance
                        private _boost = 1;
                        if (!isNil "_opcom" && {[_opcom, "recruiters", false] call ALiVE_fnc_HashGet}
                            && {time >= (_HQ getVariable ["ALiVE_INS_recruiterBackAt", 0])}) then {
                            _boost = [_opcom, "recruiterBoost", 1] call ALiVE_fnc_HashGet;
                        };
                        _delayMultiplier = _delayMultiplier / _boost;
                        private _adjustedCycleMin = _recruitCycleMin * _delayMultiplier;
                        private _adjustedCycleMax = _recruitCycleMax * _delayMultiplier;

                        // Delay between recruitment attempts.
                        sleep (_adjustedCycleMin + random ((_adjustedCycleMax - _adjustedCycleMin) max 0));

                        // Only recruit while the HQ still exists.
                        if (!alive _HQ || {_HQ getVariable ["ALiVE_MIL_OPCOM_HQ_DISABLED", false]} || {(_HQ getVariable ["ALiVE_MIL_OPCOM_HQ_RECRUITLOOP", _loopToken]) != _loopToken}) exitwith {};

                        // Its recruiter was killed since the last attempt (Recruiters): this attempt doesn't happen, nor
                        // as many after it as the commander's Recruitments Skipped says.
                        private _skip = _HQ getVariable ["ALiVE_INS_recruitSkipNext", 0];
                        if (_skip isEqualType true) then { _skip = [0, 1] select _skip };
                        if (_skip > 0) then {
                            _HQ setVariable ["ALiVE_INS_recruitSkipNext", _skip - 1];
                            continue
                        };

                        // Positive values are finite attempt counts, negative values are unlimited.
                        if (_attemptsRemaining > 0) then {
                            _attemptsRemaining = _attemptsRemaining - 1;
                        };

                        _currentForce = -1;
                        if (_forceLimit > -1 && {!isnil "ALIVE_profileHandler"}) then {
                            _currentForce = 0;
                            {
                                _currentForce = _currentForce + count ([ALIVE_profileHandler, "getProfilesByFaction",_x] call ALIVE_fnc_profileHandler);
                            } foreach _opcomFactions;
                        };

                        if !(_forceLimit > -1 && {_currentForce >= _forceLimit}) then {
                            private _phaseChanceMultiplier = switch (_hmPhase) do {
                                case "Consolidate": {0.35};
                                case "Build": {0.5};
                                case "Engage": {0.75};
                                default {1};
                            };
                            private _pressureChanceMultiplier = (1 - (0.007 * _effectivePressure)) max 0.2;
                            private _effectiveRecruitChance = (_recruitSuccessChance * _phaseChanceMultiplier * _pressureChanceMultiplier * _boost) min 1;

                            // Use the configured chance for a successful recruitment spawn.
                            if (random 1 < _effectiveRecruitChance) then {
	                            // Issue #355 - progressive recruitment: pick group
	                            // from tiered roster based on escalation intensity
	                            // and current aggregate hostility. Falls back to
	                            // legacy Infantry-only behaviour when
	                            // asymEscalationIntensity == "off" or the roster
	                            // is unavailable for this faction.
	                            private _escalationIntensity = if (!isNil "_opcom") then {[_opcom, "asymEscalationIntensity", "off"] call ALiVE_fnc_HashGet} else {"off"};
	                            private _group = "FALSE";

	                            if (_escalationIntensity == "off" || {isNil "_opcom"}) then {
	                                // Legacy path: infantry only, from config (or
	                                // custom mapping, both handled by configGetRandomGroup).
	                                _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
	                            } else {
	                                // Thresholds scale per intensity. Tier 1 (light)
	                                // unlocks at lower hostility, tier 2 (medium) at
	                                // higher. These are indicative - tune per
	                                // playtesting.
	                                private _thresholds = switch (_escalationIntensity) do {
	                                    case "low":    {[200, 500]};
	                                    case "medium": {[100, 300]};
	                                    case "high":   {[50, 150]};
	                                    default        {[9999, 9999]};
	                                };
	                                private _hostility = [_opcom] call ALiVE_fnc_INS_sampleOpcomHostility;
	                                private _computedTier = "infantry";
	                                if (_hostility >= (_thresholds select 0)) then {_computedTier = "light"};
	                                if (_hostility >= (_thresholds select 1)) then {_computedTier = "medium"};

	                                // Monotonic ratchet: insurgents don't lose
	                                // acquired capabilities. Store max tier seen
	                                // to date on the handler.
	                                private _tierOrder = ["infantry", "light", "medium"];
	                                private _recordedTier = [_opcom, "escalationLevel", "infantry"] call ALiVE_fnc_HashGet;
	                                private _unlockedTier = if ((_tierOrder find _computedTier) > (_tierOrder find _recordedTier)) then {
	                                    [_opcom, "escalationLevel", _computedTier] call ALiVE_fnc_HashSet;
	                                    _computedTier
	                                } else {
	                                    _recordedTier
	                                };

	                                // Build recruitment pool from all unlocked
	                                // tiers. Higher tiers augment rather than
	                                // replace - mission stays varied.
	                                private _rosterByFaction = [_opcom, "tieredGroupRoster", []] call ALiVE_fnc_HashGet;
	                                private _factionRoster = [_rosterByFaction, _faction, [[],[],[]]] call ALiVE_fnc_hashGet;
	                                private _pool = switch (_unlockedTier) do {
	                                    case "medium": { (_factionRoster select 0) + (_factionRoster select 1) + (_factionRoster select 2) };
	                                    case "light":  { (_factionRoster select 0) + (_factionRoster select 1) };
	                                    default        { _factionRoster select 0 };
	                                };

	                                if (count _pool > 0) then {
	                                    _group = selectRandom _pool;
	                                } else {
	                                    // Roster empty (faction has no CfgGroups
	                                    // entries we could classify, or custom-
	                                    // mapping path). Fall back to legacy
	                                    // configGetRandomGroup so 3rd-party
	                                    // factionCustomMappings users still get
	                                    // recruitment.
	                                    _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
	                                };
	                            };

	                            _recruits = [_group, [_pos,10,_size,1,0,0,0,[],[_pos]] call BIS_fnc_findSafePos, random(360), true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;
	                            {[_x, "setActiveCommand", ["ALIVE_fnc_ambientMovement","spawn",[_size + 200,"SAFE",[0,0,0]]]] call ALIVE_fnc_profileEntity} foreach _recruits;

	                            // The group just recruited is what carried this
	                            // one out, so weight the shift by it (#991).
	                            // If createProfilesFromGroupConfig returned []
	                            // the resolver finds no classes and the call
	                            // falls back to the objective's own section.
	                            [_timeTaken,_pos,[_side],10,_allSides,_objective,_recruits] call ALiVE_fnc_INS_updateHostilityByPresence;

                            };
                        };
                    };
                    _HQ setVariable ["ALiVE_INS_recruitLoopEnded", _loopToken];
                };

                _event = ['OPCOM_RESERVE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
};

ALiVE_fnc_INS_idle = {
    private ["_time"];

    _time = time;

    waituntil {time - _time > _this};
};

ALiVE_fnc_INS_protectInstallationActionObject = {
    params [["_object", objNull, [objNull]]];

    if (isNull _object) exitwith {};

    _object allowDamage false;
    _object enableSimulationGlobal false;
    _object setVariable [QGVAR(INSTALLATION_ACTION_OBJECT), true, true];
};

ALiVE_fnc_INS_registerInstallationOnBuilding = {
    params [
        ["_building", objNull, [objNull]],
        ["_installationVar", "", [""]],
        "_id",
        ["_disabledVar", "", [""]]
    ];

    if (isNull _building) exitwith {};
    if (_installationVar == "") exitwith {};

    private _installationIDs = _building getVariable [_installationVar, []];
    if !(_installationIDs isEqualType []) then {
        _installationIDs = [_installationIDs];
    };
    if !(_id in _installationIDs) then {
        _installationIDs pushBack _id;
    };
    _building setVariable [_installationVar, _installationIDs, true];

    if (_disabledVar != "") then {
        _building setVariable [_disabledVar, false, true];
    };

    if !(_building getVariable [QGVAR(INSTALLATION_KILLED_EH_ADDED), false]) then {
        _building addEventHandler ["Killed", ALIVE_fnc_INS_buildingKilledEH];
        _building setVariable [QGVAR(INSTALLATION_KILLED_EH_ADDED), true, true];
    };

    // Civilian dialog write-side for the "Has anyone been pressuring
    // you?" question (introduced by commit a229a841 in
    // amb_civ_population, currently the sole reader at
    // fnc_questionHandler.sqf case "Pressure"). When an asymmetric
    // installation registers on a building, sweep civilians within
    // 50 m and flag them as having had insurgent contact - the
    // installation's spawn implies insurgents physically present in
    // the area at registration time. Idempotent (skips already-
    // flagged civs); multi-installation buildings re-trigger the
    // sweep but the flag-check short-circuits.
    private _civFlagged = 0;
    private _nearMen = _building nearObjects ["CAManBase", 50];
    {
        if (
            side _x == civilian
            && {!(_x getVariable ["ALiVE_CivPop_InsurgentContact", false])}
        ) then {
            _x setVariable ["ALiVE_CivPop_InsurgentContact", true, true];
            _civFlagged = _civFlagged + 1;
        };
    } forEach _nearMen;

    // DIAG-STRIP - does this sweep ever reach a soul? nearObjects only returns
    // SPAWNED units, and an installation registers long after its objective
    // spawns, with no player about to have spawned anyone - so the civilians
    // nearby may all still be virtual and invisible to it. A run that only ever
    // reports zero means the flag has no source, and the civilian question that
    // reads it can never answer anything but "no, no one".
    // The building itself rather than just its class. Two installations landing on the same
    // building is the leading explanation for #1003, where an IED factory registers here but
    // then has no composition and no way to disable it: the furniture pass exits silently when
    // a building already carries some, and the hold action is refused when one of the same kind
    // is already on it. A class name cannot tell two huts apart, so the log could not show a
    // collision. The object reference carries a unique id and can.
    // Opt-in (set ALiVE_DIAG_INS = true): written for every installation, it filled a tester's RPT with
    // 229 lines in one evening with Debug off (A. Ares on Discord, 15 Oct).
    if (!isNil "ALiVE_DIAG_INS" && {ALiVE_DIAG_INS}) then {
        diag_log format ["[ALiVE DIAG-STRIP INS-CONTACT] %1 spawned man/men within 50m of %2, %3 civilian(s) flagged, installations on it: %4",
            count _nearMen, _building, _civFlagged, _building getVariable [_installationVar, []]];
    };
};

ALiVE_fnc_INS_getBuildingInstallations = {
    params [["_building", objNull, [objNull]]];

    if (isNull _building) exitwith {[]};

    private _installations = [];

    {
        _x params ["_objectiveKey", "_installationVar", "_disabledVar", "_actionKey"];

        private _ids = _building getVariable [_installationVar, nil];
        if !(isNil "_ids") then {
            if !(_ids isEqualType []) then {
                _ids = [_ids];
            };

            {
                _installations pushBack [_objectiveKey, _installationVar, _disabledVar, _actionKey, _x];
            } forEach _ids;
        };
    } forEach [
        ["factory", QGVAR(factory), "ALiVE_MIL_OPCOM_FACTORY_DISABLED", "factory"],
        ["HQ", QGVAR(HQ), "ALiVE_MIL_OPCOM_HQ_DISABLED", "recruit"],
        ["depot", QGVAR(depot), "ALiVE_MIL_OPCOM_DEPOT_DISABLED", "depot"]
    ];

    _installations
};

// The Installation Props themes: [tables, things on tables, depot floor, HQ floor] (ALiVE_fnc_INS_propSet).
// Classes that aren't loaded are dropped when used.
if (isNil "ALiVE_INS_propThemes") then {
    ALiVE_INS_propThemes = createHashMapFromArray [
        ["CLASSIC", [["Land_RattanTable_01_F"], ["Land_Canteen_F","Land_TinContainer_F"], ["VirtualReammoBox_small_F"], ["VirtualReammoBox_small_F"]]],
        ["MODERN", [
            ["Land_CampingTable_F","Land_CampingTable_small_F","Land_WoodenTable_large_F","Land_WoodenTable_small_F","Land_TableDesk_F","Land_TableSmall_01_F","Land_Workbench_01_F"],
            ["Land_Laptop_F","Land_PortableLongRangeRadio_F","Land_FMradio_F","Land_SatellitePhone_F","Land_Map_unfolded_F","Land_File1_F","Land_Notepad_F","Land_Wrench_F","Land_Pliers_F","Land_Battery_F","Land_DuctTape_F","Land_ButaneCanister_F","Land_Can_V1_F","Land_BottlePlastic_V1_F"],
            ["Box_East_Ammo_F","Box_East_AmmoOrd_F","Box_East_Wps_F","Box_East_Grenades_F","Box_Syndicate_Ammo_F","Box_Syndicate_Wps_F","Land_Ammobox_rounds_F","Land_CratesWooden_F","Land_WoodenBox_F","Land_Sacks_goods_F","Land_CanisterFuel_F"],
            ["Land_MapBoard_F","Land_ChairPlastic_F","Land_ChairWood_F","Land_CampingChair_V2_F","Land_Sleeping_bag_brown_F","Land_Ammobox_rounds_F","Box_East_Wps_F"]
        ]],
        ["VIETNAM", [
            ["Land_vn_table","Land_vn_us_common_table_01","Land_vn_kitchen_table_a","Land_vn_table_drawer","Land_vn_woodentable_small_f","Land_vn_woodentable_large_f","Land_vn_tablesmall_01_f"],
            ["vn_b_prop_typewriter_01","vn_b_prop_telephone_01","Land_vn_radio","vn_b_prop_fmradio_01","vn_o_prop_radio_m252b_01","Land_vn_map_unfolded_f","vn_o_item_map_case_01","Land_vn_us_common_lantern_01","Land_vn_candle_01","Land_vn_waterbottle_01_full_f","Land_vn_teapot_ep1"],
            ["Land_vn_us_ammobox_small_01","Land_vn_us_ammobox_small_03","Land_vn_pavn_weapons_cache","vn_prop_60mm_crate_01","vn_prop_81mm_crate_02","Land_vn_metalcrate","Land_vn_crateswooden_f","Land_vn_woodencrate_01_f","vn_prop_food_sack_01_gh","Land_vn_sack_f"],
            ["Land_vn_b_prop_mapstand_01","Land_vn_mapboard_f","vn_flag_vc","vn_banner_vc","vn_o_item_bedroll_01","vn_b_prop_cot_01","Land_vn_chair","vn_bar_01_campchair_01"]
        ]],
        ["WW2", [
            ["SPE_Desk_01","SPE_SideTable_01","SPE_CoffeeTable","SPE_DiningTable_01","SPE_ChateauTable_01"],
            ["SPE_Radio_Ger","Land_SPE_Onion_Lamp","Land_SPE_Ger_Lamp","Land_SPE_Cider_Bottle_01","Land_SPE_Milk_Bottle","Land_SPE_Pots_01","Land_SPE_Ammocan_German","SPE_US_TNT_half_pound","Land_Map_F","Land_File1_F"],
            ["Land_SPE_Ammobox_German_01","Land_SPE_Ammobox_German_02","Land_SPE_Ammobox_German_03","Land_SPE_Ammocrate_US_01","SPE_BasicAmmunitionBox_GER","SPE_Weaponcrate_K98_GER","Land_SPE_Jerrycan","Land_SPE_Sack_Wheat_Pile"],
            ["SPE_Banner_01_FFF_F","SPE_FlagCarrier_FFF","Land_SPE_Cabinet","SPE_LeatherChair","SPE_DiningChair","SPE_ChateauChair"]
        ]],
        ["COLDWAR", [
            ["gm_euro_furniture_table_06_random","gm_euro_furniture_desk_01_random","Land_TableDesk_F","Land_WoodenTable_small_F"],
            ["gm_r123m_table","gm_anprc371_table","Land_Laptop_F","Land_Map_unfolded_F","Land_File1_F","Land_Notepad_F","Land_FMradio_F"],
            ["gm_AmmoBox_wood_01_empty","gm_AmmoBox_wood_03_empty","gm_ammobox_aluminium_01_empty","gm_ammobox_pile_small_01_empty","gm_fortification_crate_01","gm_crates_pile_01","gm_jerrycan","gm_barrel_rusty"],
            ["gm_banner_GC","gm_flag_GC","Land_ChairWood_F","Land_Sleeping_bag_brown_F","Land_MapBoard_F"]
        ]]
    ];
};

// The props an installation is dressed with: [tables, things on tables, floor props]. A mission's
// own list for this kind of installation (Factory, Depot or HQ Props on the AI Commander) is used for
// all three; otherwise the commander's Installation Props theme. Auto picks the theme from the
// commander's faction (SOG, Spearhead 1944, Global Mobilization) and keeps ALiVE's own props for any
// other. Classes that aren't loaded are dropped, and an empty list falls back to ALiVE's own.
ALiVE_fnc_INS_propSet = {
    params [["_type", ""], ["_faction", ""]];
    private _classic = [["Land_RattanTable_01_F"], ["Land_Canteen_F","Land_TinContainer_F"], ["VirtualReammoBox_small_F"]];
    private _module = objNull;
    if (!isNil "OPCOM_instances") then {
        private _i = OPCOM_instances findIf { _faction in ([_x, "factions", []] call ALiVE_fnc_HashGet) };
        if (_i >= 0) then { _module = [OPCOM_instances select _i, "module", objNull] call ALiVE_fnc_HashGet };
    };
    private _loaded = { _this select { isClass (configFile >> "CfgVehicles" >> _x) } };
    private _own = (((_module getVariable [["insPropsFactory", "insPropsDepot", "insPropsHQ"] param [["factory", "depot", "HQ"] find _type, "insPropsFactory"], ""]) splitString ", ") call _loaded);
    if (_own isNotEqualTo [] && {_type in ["factory", "depot", "HQ"]}) exitWith { [_own, _own, _own] };
    private _theme = toUpper (_module getVariable ["insPropTheme", "AUTO"]);
    if (_theme == "AUTO") then {
        private _f = toLower _faction;
        _theme = switch (true) do {
            case (_f select [0, 3] == "vn_"): { "VIETNAM" };
            case (_f select [0, 4] == "spe_"): { "WW2" };
            case (_f select [0, 3] == "gm_"): { "COLDWAR" };
            default { "CLASSIC" };
        };
    };
    private _all = (missionNamespace getVariable ["ALiVE_INS_propThemes", createHashMap]) getOrDefault [_theme, []];
    // the HQ's floor is its own (maps, chairs, bedrolls); the factory and depot share the crates
    private _set = if (_all isEqualTo []) then { +_classic } else { [_all select 0, _all select 1, _all select ([2, 3] select (_type == "HQ"))] };
    _set = _set apply { _x call _loaded };
    { if (_x isEqualTo []) then { _set set [_forEachIndex, _classic select _forEachIndex] } } forEach _set;
    _set
};

// The interior sets an installation can be dressed with (ALiVE_Interiors >> Factory, Depot or HQ, the
// mission's own first, also read under its CfgGroups >> Empty): the commander's own pick for this kind of
// installation when it set one (Factory, Depot or HQ Interiors), otherwise those of the Installation
// Props era. Auto takes the era from the commander's faction (SOG Vietnam, Spearhead WW2, Global
// Mobilization Cold War, any other Modern). A set needing a class that isn't loaded is left out.
// Returns config entries, or [] for ALiVE's own tables and props (the Classic theme, or none fit).
ALiVE_fnc_INS_interiorSets = {
    params [["_type", ""], ["_faction", ""]];
    private _kind = ["Factory", "Depot", "HQ", "Lab"] param [["factory", "depot", "HQ", "lab"] find _type, ""];
    if (_kind == "") exitWith { [] };
    private _module = objNull;
    if (!isNil "OPCOM_instances") then {
        private _i = OPCOM_instances findIf { _faction in ([_x, "factions", []] call ALiVE_fnc_HashGet) };
        if (_i >= 0) then { _module = [OPCOM_instances select _i, "module", objNull] call ALiVE_fnc_HashGet };
    };
    private _all = [];
    {
        private _root = _x >> _kind;
        if (isClass _root) then {
            {
                // all its classes loaded, and not one the mission already gave under the same name
                private _n = configName _x;
                private _ok = (("true" configClasses _x) findIf { !isClass (configFile >> "CfgVehicles" >> getText (_x >> "vehicle")) }) < 0;
                if (_ok && {(_all findIf { configName _x == _n }) < 0}) then { _all pushBack _x };
            } forEach ("isClass _x" configClasses _root);
        };
    } forEach [missionConfigFile >> "ALiVE_Interiors", missionConfigFile >> "CfgGroups" >> "Empty" >> "ALiVE_Interiors", configFile >> "ALiVE_Interiors"];
    // the commander's own pick for the kind (Factory, Depot, HQ or Lab Interiors)
    private _ownKey = ["insPropsFactory", "insPropsDepot", "insPropsHQ", "insPropsLab"] param [["Factory", "Depot", "HQ", "Lab"] find _kind, ""];
    private _own = (if (_ownKey == "") then { "" } else { _module getVariable [_ownKey, ""] }) splitString ", " apply { toLower _x };
    private _picked = _all select { (toLower configName _x) in _own };
    if (_picked isNotEqualTo []) exitWith { _picked };
    private _theme = toUpper (_module getVariable ["insPropTheme", "AUTO"]);
    if (_theme == "CLASSIC") exitWith { [] };
    if (_theme == "AUTO") then {
        private _f = toLower _faction;
        _theme = switch (true) do {
            case (_f select [0, 3] == "vn_"): { "VIETNAM" };
            case (_f select [0, 4] == "spe_"): { "WW2" };
            case (_f select [0, 3] == "gm_"): { "COLDWAR" };
            default { "MODERN" };
        };
    };
    // a set marked era "ANY" (the drug lab sets) fits every era
    private _era = _all select { (toUpper getText (_x >> "era")) in [_theme, "ANY"] };
    // an era whose CDLC isn't loaded falls back to the modern sets
    if (_era isEqualTo []) then { _era = _all select { toUpper getText (_x >> "era") == "MODERN" } };
    _era
};

// The floor under an indoor spot (ATL), as an ASL position. A building position often sits a little
// above the floor, by a different amount on every map, so what's under it is measured rather than
// taken as given; the spot itself when nothing is found close below it.
ALiVE_fnc_INS_floorAt = {
    params ["_posATL"];
    private _at = AGLToASL _posATL;
    private _down = lineIntersectsSurfaces [_at vectorAdd [0, 0, 0.6], _at vectorAdd [0, 0, -1.2], objNull, objNull, true, 1, "GEOM", "VIEW"];
    if (_down isEqualTo []) exitWith { _at };
    [_at select 0, _at select 1, ((_down select 0) select 0) select 2]
};

// Whether one piece of furniture fits on a floor: its footprint (its collision box, measured once per
// class, with 10 cm to spare) centred at _centre (ASL) turned to _dir is checked at every corner for
// floor under it at the floor's height and a roof over it, nothing between _from (ASL, the spot it's
// reached from) and the corner, and no wall along any of its edges or across its diagonals, at knee and chest height.
ALiVE_fnc_INS_pieceFits = {
    params ["_cls", "_centre", "_dir", "_from"];
    if (isNil "ALiVE_INS_footprints") then { ALiVE_INS_footprints = createHashMap };
    private _turn = { params ["_v", "_d"]; [(_v select 0) * cos _d + (_v select 1) * sin _d, -(_v select 0) * sin _d + (_v select 1) * cos _d, 0] };
    private _clear = { params ["_a", "_b"]; (lineIntersectsSurfaces [_a, _b, objNull, objNull, true, 1, "GEOM", "VIEW"]) isEqualTo [] };
    private _half = ALiVE_INS_footprints getOrDefaultCall [_cls, {
        private _o = createSimpleObject [_cls, [0, 0, 0], true];
        private _h = [0.3, 0.3];
        if (!isNull _o) then {
            private _bb = boundingBoxReal [_o, "Geometry"];
            if (((_bb select 2) max 0) < 0.01) then { _bb = boundingBoxReal _o };
            _h = [((((_bb select 1) select 0) - ((_bb select 0) select 0)) / 2) max 0.1, ((((_bb select 1) select 1) - ((_bb select 0) select 1)) / 2) max 0.1];
            deleteVehicle _o;
        };
        _h
    }, true];
    _half params ["_hx", "_hy"];
    _hx = _hx + 0.1; _hy = _hy + 0.1;
    private _corners = [[-_hx, -_hy], [_hx, -_hy], [_hx, _hy], [-_hx, _hy]] apply { _centre vectorAdd ([[_x select 0, _x select 1, 0], _dir] call _turn) };
    private _ok = true; private _why = "";
    {
        private _c = _x;
        private _down = lineIntersectsSurfaces [_c vectorAdd [0, 0, 0.5], _c vectorAdd [0, 0, -0.6], objNull, objNull, true, 1, "GEOM", "VIEW"];
        if (_down isEqualTo [] || {abs ((((_down select 0) select 0) select 2) - (_centre select 2)) > 0.08}) exitWith { _ok = false; _why = "floor" };
        if ([_c vectorAdd [0, 0, 0.6], _c vectorAdd [0, 0, 12]] call _clear) exitWith { _ok = false; _why = "roof" };
        private _next = _corners select ((_forEachIndex + 1) mod 4);
        {
            private _h = [0, 0, _x];
            if !([_from vectorAdd _h, _c vectorAdd _h] call _clear) exitWith { _ok = false; _why = "reach" };
            if !([_c vectorAdd _h, _next vectorAdd _h] call _clear) exitWith { _ok = false; _why = "edge" };
        } forEach [0.4, 1.2];
        if (!_ok) exitWith {};
    } forEach _corners;
    // and across it, corner to corner, for a post or a beam standing inside the footprint
    if (_ok) then {
        {
            private _h = [0, 0, _x];
            if (!([(_corners select 0) vectorAdd _h, (_corners select 2) vectorAdd _h] call _clear) || {!([(_corners select 1) vectorAdd _h, (_corners select 3) vectorAdd _h] call _clear)}) exitWith { _ok = false; _why = "inside" };
        } forEach [0.4, 1.2];
    };
    if (!_ok && {!isNil "ALiVE_INS_fitWhy"}) then { ALiVE_INS_fitWhy pushBack _why };
    _ok
};

// Which of an interior set's furniture fits at an indoor spot (ATL) turned to a heading (each piece
// checked with ALiVE_fnc_INS_pieceFits, reached from the spot). Returns the config entries that fit,
// or [] when the set's main piece doesn't or fewer than half of its pieces do.
ALiVE_fnc_INS_interiorFits = {
    params ["_cfg", "_posATL", "_dir"];
    private _floor = [_posATL] call ALiVE_fnc_INS_floorAt;
    private _pieces = ("isClass _x" configClasses _cfg) select { ((getArray (_x >> "position")) param [2, 0]) < 0.3 };
    private _fit = [];
    {
        private _p = getArray (_x >> "position");
        if ([getText (_x >> "vehicle"),
            _floor vectorAdd [(_p select 0) * cos _dir + (_p select 1) * sin _dir, -(_p select 0) * sin _dir + (_p select 1) * cos _dir, 0],
            _dir + getNumber (_x >> "dir"), _floor] call ALiVE_fnc_INS_pieceFits) then { _fit pushBack _x } else {
            if (_forEachIndex == 0) exitWith { _fit = [] };
        };
        if (_forEachIndex == 0 && {_fit isEqualTo []}) exitWith {};
    } forEach _pieces;
    if (count _fit * 2 < count _pieces) then { _fit = [] };
    _fit
};

// Puts an interior set down at an indoor spot, turned to a heading: furniture stood on the floor,
// small things set on the furniture under them. Returns [furniture, everything].
ALiVE_fnc_INS_spawnInterior = {
    params ["_cfg", "_posATL", "_dir", ["_only", []]];
    private _floor = [_posATL] call ALiVE_fnc_INS_floorAt;
    private _furniture = []; private _all = [];
    {
        private _cls = getText (_x >> "vehicle");
        private _p = getArray (_x >> "position");
        private _on = (_p param [2, 0]) >= 0.3;
        // a piece of furniture that didn't fit is left out
        if (!_on && {_only isNotEqualTo []} && {!(_x in _only)}) then { continue };
        private _r = [(_p select 0) * cos _dir + (_p select 1) * sin _dir, -(_p select 0) * sin _dir + (_p select 1) * cos _dir, 0];
        private _at = _floor vectorAdd _r;
        // furniture and crates are real objects (the installation's actions sit on them); what stands
        // on them is a plain prop
        private _o = if (!_on || {(_cls select [0, 7]) == "Weapon_"}) then {
            createVehicle [_cls, ASLToATL _at, [], 0, "CAN_COLLIDE"]
        } else { createSimpleObject [_cls, _at] };
        if (!isNull _o) then {
            _o setDir (_dir + getNumber (_x >> "dir"));
            private _z = _floor select 2;
            if (_on) then {
                private _hits = lineIntersectsSurfaces [_at vectorAdd [0, 0, 2.5], _at, _o, objNull, true, 5, "VIEW", "GEOM"];
                private _hit = _hits select { (_x select 2) in _furniture };
                if (_hit isNotEqualTo []) then { _z = ((_hit select 0) select 0) select 2 };
                // its furniture was left out: so is it
                if (_hit isEqualTo []) then { deleteVehicle _o };
            };
            if (isNull _o) then { continue };
            // its lowest point on that surface
            _o setPosASL [_at select 0, _at select 1, _z];
            private _low = (_o modelToWorldWorld [0, 0, ((boundingBoxReal _o) select 0) select 2]) select 2;
            _o setPosASL [_at select 0, _at select 1, _z + (_z - _low)];
            if (!_on) then { _furniture pushBack _o; [_o] call ALiVE_fnc_INS_protectInstallationActionObject };
            _all pushBack _o;
        };
    } forEach ("isClass _x" configClasses _cfg);
    [_furniture, _all]
};

// Dresses a building with interior sets: one, or two in a building with room, at indoor spots
// where they fit, lined up with the building. Returns [furniture, everything], or [[], []] when no
// set fits anywhere (ALiVE_fnc_spawnFurniture then uses its own tables and props).
ALiVE_fnc_INS_dressWithInteriors = {
    params ["_building", "_sets", "_positions"];
    private _furniture = []; private _all = []; private _used = [];
    private _want = [1, 2] select (count _positions >= 6);
    private _tries = _positions call BIS_fnc_arrayShuffle;
    {
        private _pos = _x;
        if (count _used >= _want) exitWith {};
        if ((_used findIf { (_x distance2D _pos) < 3.5 }) < 0) then {
            // every set, each of the four turns lined up with the building, and the spot itself or
            // half a metre off it, until one fits
            private _fit = [];
            {
                private _set = _x;
                {
                    private _dir = (getDir _building) + _x;
                    {
                        private _at = _pos vectorAdd [(_x select 0) * cos _dir + (_x select 1) * sin _dir, -(_x select 0) * sin _dir + (_x select 1) * cos _dir, 0];
                        private _pieces = [_set, _at, _dir] call ALiVE_fnc_INS_interiorFits;
                        if (_pieces isNotEqualTo []) exitWith { _fit = [_set, _at, _dir, _pieces] };
                    } forEach [[0, 0], [0.5, 0], [-0.5, 0], [0, 0.5], [0, -0.5]];
                    if (_fit isNotEqualTo []) exitWith {};
                } forEach ([0, 90, 180, 270] call BIS_fnc_arrayShuffle);
                if (_fit isNotEqualTo []) exitWith {};
            } forEach (_sets call BIS_fnc_arrayShuffle);
            if (_fit isNotEqualTo []) then {
                _fit params ["_set", "_at", "_dir", "_pieces"];
                ([_set, _at, _dir, _pieces] call ALiVE_fnc_INS_spawnInterior) params ["_f", "_a"];
                _furniture append _f; _all append _a; _used pushBack _pos;
                // a second set is a different one where there's a choice
                if (count _sets > 1) then { _sets = _sets - [_set] };
            };
        };
    } forEach _tries;
    [_furniture, _all]
};

ALiVE_fnc_spawnFurniture = {

    private ["_pos","_furniture","_bomb","_box","_created"];

    _building = _this select 0;
    _ieds = _this select 1;
    _add = _this select 2;
    _ammo = _this select 3;
    private _type = _this param [4, ""];
    private _faction = _this param [5, ""];

    if (!(alive _building) || {count (_building getvariable [QGVAR(furnitured),[]]) > 0}) exitwith {[]};

    // tables, what sits on them, and what stands on the floor: the commander's Installation Props
    // theme, or the mission's own list for this kind of installation (ALiVE_fnc_INS_propSet)
    ([_type, _faction] call ALiVE_fnc_INS_propSet) params ["_furnitures", "_objects", "_boxes"];
    _bombs = ["ALIVE_IEDUrbanSmall_Remote_Ammo","ALIVE_IEDLandSmall_Remote_Ammo","ALIVE_IEDLandBig_Remote_Ammo"];
    _created = [];

    _pos = getposATL _building;
    // Indoor spots in this building only, the same roof check ALIVE_fnc_findIndoorHousePositions makes: that
    // function takes every house within its radius, so where huts stand close together (SOG) a second set of
    // furniture went into the neighbour and it carried the installation's action too (A. Ares on Discord, 15 Oct).
    _positions = ([_building] call ALIVE_fnc_getBuildingPositions) select {
        private _a = ATLtoASL _x;
        lineIntersects [_a vectorAdd [0, 0, 0.5], _a vectorAdd [0, 0, 2.5]]
    };
    // the building's own positions when the indoor search finds none (many mod and Livonia houses):
    // everything placed there is checked for floor, roof and walls before it goes in
    if (count _positions == 0) then { _positions = (_building buildingPos -1) select { (_x select 2) < 30 } };

    if (count _positions == 0) exitwith {
        ["ALiVE MIL OPCOM Insurgency has not found indoor Houspositions to place IED Factory/HQ/depot objects for building %1 at %2",_building, getposATL _building] call ALiVE_fnc_Dump;
        [];
    };

    // the interior sets for this kind of installation and era, where they fit (ALiVE_Interiors)
    private _sets = [_type, _faction] call ALiVE_fnc_INS_interiorSets;
    if (_sets isNotEqualTo []) then {
        ([_building, _sets, _positions] call ALiVE_fnc_INS_dressWithInteriors) params ["_setFurniture", "_setAll"];
        if (_setFurniture isNotEqualTo []) then {
            _created append _setAll;
            // the factory's IED sits on its first table or bench; the HQ and depot sets get none, as their
            // first piece can be a sleeping bag or a crate (kawi0756 on Discord, 14 Oct)
            if (_ieds && {_type == "factory"}) then {
                private _table = _setFurniture select 0;
                _bomb = createVehicle [(selectRandom _bombs), getposATL _table, [], 0, "CAN_COLLIDE"];
                _charge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo", getposATL _bomb, [], 0, "CAN_COLLIDE"];
                _bomb attachTo [_table, [0, 0, _table call ALiVE_fnc_getRelativeTop]];
                _charge attachTo [_bomb, [0, 0, 0]];
                _ehID = _charge addeventhandler ["HandleDamage", {
                    if (isPlayer (_this select 3)) then {
                        _bomb = attachedTo (_this select 0);
                        _ehID = _bomb getVariable "ehID";
                        "M_Mo_120mm_AT" createVehicle [(getpos (_this select 0)) select 0, (getpos (_this select 0)) select 1, 0];
                        _bomb removeEventhandler ["HandleDamage", _ehID];
                        deletevehicle (_this select 0);
                        deleteVehicle _bomb;
                    };
                }];
                _bomb setVariable ["ehID", _ehID, true];
                _bomb setvariable ["charge", _charge, true];
                _created pushback _bomb;
                _created pushback _charge;
            };
        };
    };
    if (_created isNotEqualTo []) exitWith {
        _building setvariable [QGVAR(furnitured), _created];
        _created
    };

    {
        private ["_pos"];

        _pos = _x;

        if ({(_pos select 2) - (_x select 2) < 0.5} count _positions > 1) then {
            private _fits = { params ["_cls", "_p"]; private _f = [_p] call ALiVE_fnc_INS_floorAt; [_cls, _f, getDir _building, _f] call ALiVE_fnc_INS_pieceFits };
            private _fCls = selectRandom _furnitures;
            if (random 1 < 0.3 && {[_fCls, _pos] call _fits}) then {
                _furniture = createVehicle [_fCls, _pos, [], 0, "CAN_COLLIDE"];
                _furniture setposATL _pos;
                _furniture setdir getdir _building;

                // Keep action anchors stable. Bombs are not affected and still exploding.
                // Once the building is destroyed or site is disabled, the furniture gets deleted.
                [_furniture] call ALiVE_fnc_INS_protectInstallationActionObject;

                _created pushback _furniture;

                if (_ieds) then {
                    _bomb = createVehicle [(selectRandom _bombs), getposATL _furniture, [], 0, "CAN_COLLIDE"];
                    _charge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo",getposATL _bomb, [], 0, "CAN_COLLIDE"];

                    _bomb attachTo [_furniture, [0,0,_furniture call ALiVE_fnc_getRelativeTop]];
                    _charge attachTo [_bomb, [0,0,0]];

                    // Add damage handler
                    _ehID = _charge addeventhandler ["HandleDamage",{
                        private ["_trgr","_IED"];

                        if (isPlayer (_this select 3)) then {
                            _bomb = attachedTo (_this select 0);
                            _ehID = _bomb getVariable "ehID";

                            "M_Mo_120mm_AT" createVehicle [(getpos (_this select 0)) select 0, (getpos (_this select 0)) select 1,0];

                            _bomb removeEventhandler ["HandleDamage",_ehID];

                            deletevehicle (_this select 0);
                            deleteVehicle _bomb;
                        };
                    }];

                    _bomb setVariable ["ehID",_ehID, true];
                    _bomb setvariable ["charge", _charge, true];

                    _created pushback _bomb;
                    _created pushback _charge;
                };
            } else {
                if (_add && {random 1 < 0.5} && {[_fCls, _pos] call _fits}) then {
                    _furniture = createVehicle [_fCls, _pos, [], 0, "CAN_COLLIDE"];
                    _furniture setdir getdir _building;
                    [_furniture] call ALiVE_fnc_INS_protectInstallationActionObject;

                    _object = createVehicle [(selectRandom _objects), _pos, [], 0, "CAN_COLLIDE"];
                    _object attachTo [_furniture, [0,0,(_furniture call ALiVE_fnc_getRelativeTop) + 0.15]];
 
                    _created pushback _furniture;
                    _created pushback _object;
                } else {
                    private _bCls = selectRandom _boxes;
                    if (_ammo && {random 1 < 0.5} && {[_bCls, _pos] call _fits}) then {
                        _box = createVehicle [_bCls, _pos, [], 0, "CAN_COLLIDE"];
                        _box setdir (_building getDir _box);
                        [_box] call ALiVE_fnc_INS_protectInstallationActionObject;

                        _created pushback _box;
                    };
                };
            };
        };
    } foreach _positions;

    if ({_x getVariable [QGVAR(INSTALLATION_ACTION_OBJECT), false]} count _created == 0 && {count _positions > 0}) then {
        // somewhere it fits: a table, or failing that a small crate. Where neither fits anywhere,
        // nothing goes in and the installation's actions sit on the building itself
        private _anchorCls = selectRandom _furnitures;
        private _anchorPos = (_positions select { [_anchorCls, [_x] call ALiVE_fnc_INS_floorAt, getDir _building, [_x] call ALiVE_fnc_INS_floorAt] call ALiVE_fnc_INS_pieceFits }) param [0, []];
        if (_anchorPos isEqualTo []) then {
            _anchorCls = "VirtualReammoBox_small_F";
            _anchorPos = (_positions select { [_anchorCls, [_x] call ALiVE_fnc_INS_floorAt, getDir _building, [_x] call ALiVE_fnc_INS_floorAt] call ALiVE_fnc_INS_pieceFits }) param [0, []];
        };
        if (_anchorPos isNotEqualTo []) then {
            _furniture = createVehicle [_anchorCls, _anchorPos, [], 0, "CAN_COLLIDE"];
            _furniture setposATL _anchorPos;
            _furniture setdir getdir _building;
            [_furniture] call ALiVE_fnc_INS_protectInstallationActionObject;
            _created pushback _furniture;
        };
    };

    _building setvariable [QGVAR(furnitured),_created];

    _created
};

ALiVE_fnc_INS_getInstallationActionObjects = {
    params [
        ["_building", objNull, [objNull]],
        ["_objects", [], [[]]]
    ];

    private _sourceObjects = if (_objects isEqualTo []) then {
        _building getvariable [QGVAR(furnitured),[]]
    } else {
        _objects
    };

    private _actionObjects = _sourceObjects select {
        alive _x && {_x getVariable [QGVAR(INSTALLATION_ACTION_OBJECT), false]}
    };

    if (_actionObjects isEqualTo [] && {alive _building}) then {
        _actionObjects = [_building];
    };

    _actionObjects
};

ALiVE_fnc_INS_addInstallationHoldActions = {
    params [
        ["_building", objNull, [objNull]],
        ["_title", "", [""]],
        ["_disabledVar", "", [""]],
        ["_subtitleTitle", "", [""]],
        ["_subtitleText", "", [""]],
        ["_duration", 10, [0]]
    ];

    if !(alive _building) exitwith {};
    if (_disabledVar == "") exitwith {};

    private _interactionDistanceSqr = 100;

    {
        private _actionObject = _x;
        private _actionKeys = _actionObject getVariable [QGVAR(INSTALLATION_ACTIONS_ADDED), []];

        if !(_disabledVar in _actionKeys) then {
            _actionKeys pushback _disabledVar;

            _actionObject setVariable ["ALiVE_MIL_OPCOM_INSTALLATION_BUILDING", _building, true];
            _actionObject setVariable [QGVAR(INSTALLATION_ACTIONS_ADDED), _actionKeys, true];

            [
                _actionObject,
                _title,
                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                // Wrap in call { } to give `private` a valid statement context.
                // Arma evaluates addAction condition/conditionShow strings as an
                // expression (roughly `_eval = <string>`), which turns a leading
                // `private` statement into a parse error ("Missing ;" at the `=`
                // after _building). `call { ... }` creates a local scope that can
                // contain the `private _building = ...` declaration, and returns
                // the last expression's boolean value as the condition result.
                format ["call { private _building = _target getVariable ['ALiVE_MIL_OPCOM_INSTALLATION_BUILDING', _target]; (_this distanceSqr _target) <= %2 && {alive _building} && {!(_building getVariable ['%1', false])} }", _disabledVar, _interactionDistanceSqr],
                format ["call { private _building = _target getVariable ['ALiVE_MIL_OPCOM_INSTALLATION_BUILDING', _target]; (_caller distanceSqr _target) <= %2 && {alive _building} && {!(_building getVariable ['%1', false])} }", _disabledVar, _interactionDistanceSqr],
                {},
                {},
                {
                    params ["_target", "_caller", "_ID", "_arguments"];
                    _arguments params ["_building", "_disabledVar", "_subtitleTitle", "_subtitleText"];

                    if (isNull _building) exitWith {};

                    [_target, _ID] remoteExec ["BIS_fnc_holdActionRemove", 0, _target];
                    [_building, _caller, _subtitleTitle, _subtitleText] remoteExec ["ALiVE_fnc_INS_disableBuildingInstallations", 2];
                },
                {},
                [_building, _disabledVar, _subtitleTitle, _subtitleText],
                _duration
            // A dedicated server has no player to hold this, and running the game's hold-action code
            // there throws on some buildings (fn_holdAction_showIcon), so only players' machines get it.
            ] remoteExec ["BIS_fnc_holdActionAdd", [0, -2] select isDedicated, _actionObject];
        };
    } foreach ([_building] call ALiVE_fnc_INS_getInstallationActionObjects);
};

ALiVE_fnc_INS_spawnIEDfactory = {
    private ["_building","_id"];

    _building = _this select 0;
    _id = _this select 1;
    private _faction = _this param [2, ""];

    if !(alive _building) exitwith {};

    [_building, QGVAR(factory), _id, "ALiVE_MIL_OPCOM_FACTORY_DISABLED"] call ALiVE_fnc_INS_registerInstallationOnBuilding;
    private _duration = 10 + ((count (_building getvariable [QGVAR(furnitured),[]]))*4);

    // War on Drugs (#1080): a drug lab gets lab furniture and no booby-trapped charge
    private _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;
    private _opcom = if (isNil "_objective") then {[]} else {[_objective] call ALiVE_fnc_INS_getOpcomByObjective};
    private _lab = [_opcom] call ALiVE_fnc_INS_drugLabsOn;
    private _name = [_opcom] call ALiVE_fnc_INS_factoryName;

    [_building,!_lab,false,false,["factory","lab"] select _lab,_faction] call ALiVE_fnc_spawnFurniture;

    [
        _building,
        format ["disable the %1!", _name],
        "ALiVE_MIL_OPCOM_FACTORY_DISABLED",
        "Nice Job",
        "%1 disabled the " + _name + " at grid %2!",
        _duration
    ] call ALiVE_fnc_INS_addInstallationHoldActions;
};

// A recruiter stands in a Recruitment HQ while a player is within 800 m (the commander's Recruiters
// setting), and goes when none is within 1200 m. Killed, he costs the town its next recruitment attempt,
// and a new one turns up after _pause seconds. While a recruiter HVT task from this HQ is open its target
// is the recruiter, and that task succeeding counts as his death. Runs as long as the town's recruiting
// does. With the commander's Recruiter Class he's made from that; Recruiter Guards stand with him; and if the
// HQ is disabled while he's there and players are near, he runs for it (#1088).
// [HQ building, faction, position, pause, commander's handler]
ALiVE_fnc_INS_recruiterPresence = {
    params ["_HQ", "_faction", "_pos", "_pause", ["_opcom", []]];
    if !([_opcom] call ALIVE_fnc_isHash) then { _opcom = [] call ALiVE_fnc_hashCreate };
    private _setClass = (([_opcom, "recruiterClass", ""] call ALiVE_fnc_HashGet) splitString ", ") select { isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "CAManBase"} };
    private _classes = if (_setClass isNotEqualTo []) then { _setClass } else {
        [[_faction], 1, missionNamespace getVariable ["ALiVE_MIL_CQB_UNITBLACKLIST", []]] call ALiVE_fnc_taskGetHVTUnits
    };
    if (_classes isEqualTo []) exitWith {};
    private _class = selectRandom _classes;
    // the town he recruits for, as players are told it: the nearest named place, else the grid
    private _town = if (isNil "ALIVE_fnc_taskGetNearestLocationName") then { "" } else { [getPos _HQ] call ALIVE_fnc_taskGetNearestLocationName };
    if (_town == "") then { _town = mapGridPosition _HQ };
    _HQ setVariable ["ALiVE_INS_recruiterTown", _town];
    private _guardCount = [_opcom, "recruiterGuards", 2] call ALiVE_fnc_HashGet;
    private _skips = [_opcom, "recruiterSkips", 1] call ALiVE_fnc_HashGet;
    private _walks = [_opcom, "recruiterWalks", false] call ALiVE_fnc_HashGet;
    private _guardClasses = if (_guardCount > 0) then {
        [[_faction], _guardCount, missionNamespace getVariable ["ALiVE_MIL_CQB_UNITBLACKLIST", []], true] call ALiVE_fnc_chooseRandomUnits
    } else { [] };
    private _guards = [];
    private _fnc_clear = {
        { if (!isNull _x) then { private _g = group _x; deleteVehicle _x; if (!isNull _g && {units _g isEqualTo []}) then { deleteGroup _g } } } forEach (_guards + [_unit]);
        _guards = [];
        _unit = objNull;
    };
    private _sideObj = _faction call ALiVE_fnc_factionSide;
    if (_sideObj isEqualType "") then { _sideObj = [_sideObj] call ALiVE_fnc_sideTextToObject };
    // the recruiting loop this recruiter belongs to: it starts just after this, and a newer one taking
    // the building, or this one finishing, ends the recruiter too
    private _t = time;
    waitUntil { sleep 1; !isNil {_HQ getVariable "ALiVE_MIL_OPCOM_HQ_RECRUITLOOP"} || {time - _t > 60} };
    private _token = _HQ getVariable ["ALiVE_MIL_OPCOM_HQ_RECRUITLOOP", -1];
    private _unit = objNull;
    private _players = { (allPlayers - entities "HeadlessClient_F") findIf { _x distance _HQ < _this } > -1 };
    while {
        alive _HQ && {!(_HQ getVariable ["ALiVE_MIL_OPCOM_HQ_DISABLED", false])}
        && {(_HQ getVariable ["ALiVE_MIL_OPCOM_HQ_RECRUITLOOP", -1]) == _token}
        && {(_HQ getVariable ["ALiVE_INS_recruitLoopEnded", -2]) != _token}
    } do {
        // recruiter HVT tasks from this HQ, one per hostile side: while one is open its target is the recruiter
        private _taskOpen = false;
        private _tasks = (_HQ getVariable ["ALiVE_INS_recruiterTasks", []]) select {
            _x params ["_id", "_raisedAt"];
            private _hvtStep = if (isNil "ALIVE_taskHandler") then {nil} else {[ALIVE_taskHandler, "getTask", _id + "_c1"] call ALIVE_fnc_taskHandler};
            private _doneKey = format ["ALiVE_taskSucceeded_%1", _id + "_c1"];
            if (missionNamespace getVariable [_doneKey, false]) then {
                // the HVT killed: the task is taken down as it succeeds, so this is how it is seen
                missionNamespace setVariable [_doneKey, nil];
                _hvtStep = nil;
                if (time - (_HQ getVariable ["ALiVE_INS_recruiterTakenAt", -1e9]) > 1800) then {
                    _HQ setVariable ["ALiVE_INS_recruitSkipNext", _skips];
                    _HQ setVariable ["ALiVE_INS_recruiterBackAt", time + _pause];
                    ["ALiVE OPCOM: the recruiter at the Recruitment HQ near %1 was killed in a task; that town skips %2 recruitment(s)", mapGridPosition _HQ, _skips] call ALiVE_fnc_dump;
                };
                _raisedAt = -1e6;
            };
            if (isNil "_hvtStep") then {
                // not handed over yet, or gone: kept for three minutes, as a new task takes a while to register
                (time - _raisedAt) < 180
            } else {
                private _state = _hvtStep select 8;
                if (_state == "Succeeded" && {time - (_HQ getVariable ["ALiVE_INS_recruiterTakenAt", -1e9]) > 1800}) then {
                    _HQ setVariable ["ALiVE_INS_recruitSkipNext", _skips];
                    _HQ setVariable ["ALiVE_INS_recruiterBackAt", time + _pause];
                    ["ALiVE OPCOM: the recruiter at the Recruitment HQ near %1 was killed in a task; that town skips %2 recruitment(s)", mapGridPosition _HQ, _skips] call ALiVE_fnc_dump;
                };
                private _open = !(_state in ["Succeeded", "Failed", "Canceled"]);
                if (_open) then { _taskOpen = true };
                _open
            };
        };
        _HQ setVariable ["ALiVE_INS_recruiterTasks", _tasks];
        // read by his kill handler: while a task is out on him, the task's own success tells the players
        _HQ setVariable ["ALiVE_INS_recruiterTaskOpen", _taskOpen];
        if (!isNull _unit && {!alive _unit}) then { _unit = objNull };
        // guards left after their recruiter died stay and fight, and go once no player is near
        _guards = _guards select { alive _x };
        if (isNull _unit && {_guards isNotEqualTo []} && {!(1200 call _players)}) then { call _fnc_clear };
        if (isNull _unit) then {
            if (!_taskOpen && {time >= (_HQ getVariable ["ALiVE_INS_recruiterBackAt", 0])} && {800 call _players}) then {
                private _grp = createGroup [_sideObj, true];
                _unit = _grp createUnit [_class, _pos, [], 0, "CAN_COLLIDE"];
                _unit setPosATL _pos;
                _unit disableAI "PATH";
                _unit setUnitPos "UP";
                _unit setVariable ["ALIVE_profileIgnore", true, true];
                // kept on the server: a headless client given the group would run none of what's done to him here
                _unit setVariable ["ALiVE_ignore_HC", true, true];
                _grp setVariable ["ALIVE_profileIgnore", true];
                _unit setVariable ["ALiVE_INS_recruiterOf", [_HQ, _pause, _skips]];
                // papers that say who he is, found on his body or by searching him as a prisoner
                if (!isNil "ALiVE_fnc_giveTargetPapers") then { [_unit, "STR_ALIVE_TARGETID_RECRUITER", _town] call ALiVE_fnc_giveTargetPapers };
                // counted the moment he dies, wherever he is local, so a body cleaned up before the next
                // look still counts; the side of the player who killed him is told
                _unit addMPEventHandler ["MPKilled", {
                    if (!isServer) exitWith {};
                    params ["_dead", "_killer", ["_instigator", objNull]];
                    (_dead getVariable ["ALiVE_INS_recruiterOf", [objNull, 0, 1]]) params ["_hq", "_pause", ["_skips", 1]];
                    if (isNull _hq) exitWith {};
                    _hq setVariable ["ALiVE_INS_recruitSkipNext", _skips];
                    _hq setVariable ["ALiVE_INS_recruiterBackAt", time + _pause];
                    ["ALiVE OPCOM: the recruiter at the Recruitment HQ near %1 was killed; that town skips %2 recruitment(s)", mapGridPosition _hq, _skips] call ALiVE_fnc_dump;
                    if (isNull _instigator) then { _instigator = _killer };
                    // told only to a side that's his enemy: a player on his own side who shoots him gets no success
                    if (isPlayer _instigator && {((side group _dead) getFriend (side group _instigator)) < 0.6} && {!(_hq getVariable ["ALiVE_INS_recruiterTaskOpen", false])}) then {
                        ["notify", ["STR_ALIVE_OPCOM_RECRUITER_KILLED", _hq getVariable ["ALiVE_INS_recruiterTown", mapGridPosition _hq], "STR_ALIVE_OPCOM_RECRUITER_KILLED_SHORT"]] remoteExec ["ALiVE_fnc_OPCOMHVT", side group _instigator];
                    };
                }];
                // his guards, at the building's own positions where it has them, in his group so they stay by him
                private _spots = (_HQ buildingPos -1) call BIS_fnc_arrayShuffle;
                {
                    private _at = _spots param [_forEachIndex, _pos getPos [3 + random 6, random 360]];
                    private _g = _grp createUnit [_x, _at, [], 0, "CAN_COLLIDE"];
                    _g setPosATL _at;
                    _g disableAI "PATH";
                    _g setVariable ["ALIVE_profileIgnore", true, true];
                    _g setVariable ["ALiVE_ignore_HC", true, true];
                    _guards pushBack _g;
                } forEach ([[], _guardClasses] select (_guards isEqualTo []));
                // Recruiter Walks The Town: he and his guards walk a round of the town's buildings within 150 m of
                // the HQ, back to it, and round again
                if (_walks) then {
                    { _x enableAI "PATH" } forEach (units _grp);
                    _grp setBehaviour "SAFE";
                    _grp setSpeedMode "LIMITED";
                    private _stops = ((nearestObjects [_pos, ["House", "Building"], 150]) select { (_x buildingPos 0) isNotEqualTo [0,0,0] }) call BIS_fnc_arrayShuffle;
                    { private _w = _grp addWaypoint [_x buildingPos 0, 0]; _w setWaypointType "MOVE"; _w setWaypointTimeout [20, 40, 60] } forEach (_stops select [0, 4]);
                    private _home = _grp addWaypoint [_pos, 0];
                    _home setWaypointType "CYCLE";
                };
                ["ALiVE OPCOM: a recruiter (%1) is in the Recruitment HQ near %2, with %3 guard(s)%4", _class, mapGridPosition _HQ, count _guards, ["", ", walking the town"] select _walks] call ALiVE_fnc_dump;
            };
        } else {
            // Cornered, with his guards down (or none given him) and a hostile player within 25 m, he gives himself
            // up (Ando on Discord, 17 Oct): a prisoner like any other, to detain and question through C2ISTAR.
            // Taken, he costs the town its recruiting as his death would; his kill handler and any recruiter task
            // still open are told, so it isn't counted again.
            if (
                !isNil "ALiVE_c2istar_fnc_surrender"
                && {(_guards select { alive _x }) isEqualTo []}
                && {(allPlayers findIf { alive _x && {(_x distance _unit) < 25} && {(_sideObj getFriend side group _x) < 0.6} }) > -1}
            ) then {
                _unit setVariable ["ALiVE_INS_recruiterOf", [objNull, 0, 1]];
                _HQ setVariable ["ALiVE_INS_recruiterTakenAt", time];
                _unit setVariable ["ALiVE_INS_recruiterCaptured", true, true];
                // questioned, he gives up his own Recruitment HQ wherever it is (A. Ares on Discord, 19 Oct)
                _unit setVariable ["ALiVE_INS_recruiterHQ", _HQ, true];
                [_unit] call ALiVE_c2istar_fnc_surrender;
                _HQ setVariable ["ALiVE_INS_recruitSkipNext", _skips];
                _HQ setVariable ["ALiVE_INS_recruiterBackAt", time + _pause];
                ["ALiVE OPCOM: the recruiter at the Recruitment HQ near %1 gave himself up; that town skips %2 recruitment(s)", mapGridPosition _HQ, _skips] call ALiVE_fnc_dump;
                // the side of the player who cornered him is told
                private _taker = allPlayers select { alive _x && {(_x distance _unit) < 25} && {(_sideObj getFriend side group _x) < 0.6} };
                if (_taker isNotEqualTo []) then {
                    ["notify", ["STR_ALIVE_OPCOM_RECRUITER_TAKEN", _town,"STR_ALIVE_OPCOM_RECRUITER_TAKEN_SHORT"]] remoteExec ["ALiVE_fnc_OPCOMHVT", side group (_taker select 0)];
                };
                // the players' now: nothing here deletes him
                _unit = objNull;
            } else {
                // he goes when no one is near; when a task opens he waits until no player can see him go
                if ((_taskOpen && {!(300 call _players)}) || {!(1200 call _players)}) then {
                    call _fnc_clear;
                };
            };
        };
        sleep 10;
    };
    // the HQ disabled or the town's recruiting over: with players near he runs for it, then is gone once out of
    // their sight (or after 5 minutes); otherwise he and his guards just go
    if (!isNull _unit && {alive _unit} && {400 call _players}) then {
        private _runner = _unit;
        private _runGroup = createGroup [side group _runner, true];
        _runGroup setVariable ["ALIVE_profileIgnore", true];
        [_runner] joinSilent _runGroup;
        _runner enableAI "PATH";
        _runner setBehaviour "AWARE";
        _runner setSpeedMode "FULL";
        // away from the nearest player
        private _near = (allPlayers - entities "HeadlessClient_F") apply { [_x distance _runner, _x] };
        _near sort true;
        private _from = (_near param [0, [0, objNull]]) select 1;
        private _away = (getPos _runner) getPos [800, if (isNull _from) then { random 360 } else { _from getDir _runner }];
        _runner doMove _away;
        ["ALiVE OPCOM: the recruiter at the Recruitment HQ near %1 runs for it", mapGridPosition _HQ] call ALiVE_fnc_dump;
        _unit = objNull;
        // his guards hold the building and fight, and go once no player is near
        private _left = _guards select { alive _x };
        { _x enableAI "PATH" } forEach _left;
        _guards = [];
        [_runner, _left] spawn {
            params ["_runner", "_left"];
            private _t = time;
            private _noneNear = { params ["_who", "_d"]; ((allPlayers - entities "HeadlessClient_F") findIf { _x distance _who < _d }) < 0 };
            waitUntil { sleep 5; !alive _runner || {time - _t > 300} || {[_runner, 1000] call _noneNear} };
            if (alive _runner) then { private _g = group _runner; deleteVehicle _runner; deleteGroup _g };
            waitUntil { sleep 10; _left = _left select { alive _x }; _left isEqualTo [] || {(_left findIf { !([_x, 1200] call _noneNear) }) < 0} };
            { private _g = group _x; deleteVehicle _x; if (units _g isEqualTo []) then { deleteGroup _g } } forEach _left;
        };
    } else {
        call _fnc_clear;
    };
};

ALiVE_fnc_INS_spawnHQ = {
    private ["_building","_id"];

    _building = _this select 0;
    _id = _this select 1;
    private _faction = _this param [2, ""];

    if !(alive _building) exitwith {};

    [_building, QGVAR(HQ), _id, "ALiVE_MIL_OPCOM_HQ_DISABLED"] call ALiVE_fnc_INS_registerInstallationOnBuilding;
    private _duration = 10 + ((count (_building getvariable [QGVAR(furnitured),[]]))*4);

    [_building,true,true,true,"HQ",_faction] call ALiVE_fnc_spawnFurniture;

    [
        _building,
        "disable the Recruitment HQ!",
        "ALiVE_MIL_OPCOM_HQ_DISABLED",
        "Congratulations",
        "%1 disabled the Recruitment HQ at grid %2!",
        _duration
    ] call ALiVE_fnc_INS_addInstallationHoldActions;
};

ALiVE_fnc_INS_spawnDepot = {
    private ["_building","_id"];

    _building = _this select 0;
    _id = _this select 1;
    private _faction = _this param [2, ""];

    if !(alive _building) exitwith {};

    [_building, QGVAR(depot), _id, "ALiVE_MIL_OPCOM_DEPOT_DISABLED"] call ALiVE_fnc_INS_registerInstallationOnBuilding;
    private _duration = 10 + ((count (_building getvariable [QGVAR(furnitured),[]]))*4);

    [_building,true,false,true,"depot",_faction] call ALiVE_fnc_spawnFurniture;

    [
        _building,
        "disable the weapons depot!",
        "ALiVE_MIL_OPCOM_DEPOT_DISABLED",
        "Good work",
        "%1 disabled the weapons depot at grid %2!",
        _duration
    ] call ALiVE_fnc_INS_addInstallationHoldActions;
};

ALiVE_fnc_getRelativeTop = {

    _object = _this;

    _bbr = boundingBoxReal _object;
    _p1 = _bbr select 0; _p2 = _bbr select 1;
    _height = abs((_p2 select 2)-(_p1 select 2));
    _height/2;
};

ALIVE_fnc_INS_buildingKilledEH = {

    private ["_building","_killer","_opcom","_pos"];

    _building = _this select 0;
    _killer = _this select 1;
    _pos = getposATL _building;

    private _furniture = _building getvariable [QGVAR(furnitured),[]];
    private _installations = [_building] call ALiVE_fnc_INS_getBuildingInstallations;

    if (_installations isEqualTo []) exitwith {};

    // fire event
    // TODO: cba events should be fired from core event loop, not here

    private _hostilityUpdates = [];
    private _events = [];

    {
        _x params ["_objectiveKey", "_installationVar", "_disabledVar", "_actionKey", "_id"];

        private _installationType = toLower _objectiveKey;
        ["ASYMM_INSTALLATION_DESTROYED", [_installationType,_building,_killer]] call CBA_fnc_globalEvent;

        private _event = ['ASYMM_INSTALLATION_DESTROYED', [_installationType,_building,_killer],"OPCOM"] call ALIVE_fnc_event;
        _events pushBack _event;

        private _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;
        if ([_objective] call ALIVE_fnc_isHash) then {
            private _objectiveOpcomID = [_objective,"opcomID",""] call ALiVE_fnc_HashGet;
            private _objectivePos = [_objective,"center",_pos] call ALiVE_fnc_HashGet;

            if (
                _objectiveOpcomID != ""
                && {(_hostilityUpdates findIf {(_x select 0) == _objectiveOpcomID && {(_x select 1) isEqualTo _objectivePos}}) == -1}
            ) then {
                _hostilityUpdates pushBack [_objectiveOpcomID, _objectivePos];
            };

            [_objective,_objectiveKey] call ALiVE_fnc_HashRem;
            [_objective,"actionsFulfilled",([_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashGet) - [_actionKey]] call ALiVE_fnc_HashSet;
        };

        _building setVariable [_installationVar, nil, true];
        _building setVariable [_disabledVar, true, true];
    } forEach _installations;

    [ALiVE_eventLog, "addEvents", _events] call ALiVE_fnc_eventLog;

    {
        _x setVariable [QGVAR(INSTALLATION_ACTIONS_ADDED), [], true];
        _x setVariable ["ALiVE_MIL_OPCOM_INSTALLATION_BUILDING", nil, true];
    } forEach (([_building, _furniture] call ALiVE_fnc_INS_getInstallationActionObjects) + [_building]);

    {deleteVehicle _x} foreach _furniture;
    _building setvariable [QGVAR(furnitured),[], true];

    {
        _x params ["_opcomID", "_objectivePos"];

        private _objectiveOpcom = [];
        {
            if (([_x,"opcomID"," "] call ALiVE_fnc_HashGet) == _opcomID) exitwith {
                _objectiveOpcom = _x
            }
        } foreach OPCOM_instances;

        if ([_objectiveOpcom] call ALIVE_fnc_isHash) then {
            private _opcomSide = [_objectiveOpcom,"side",""] call ALiVE_fnc_HashGet;
            private _allSides = ["EAST","WEST","GUER"];

            [_objectivePos,[_opcomSide], 50] call ALiVE_fnc_updateSectorHostility;
            [_objectivePos,_allSides - [_opcomSide], -50] call ALiVE_fnc_updateSectorHostility;
        };
    } forEach _hostilityUpdates;
};

ALiVE_fnc_INS_compileList = {
            private ["_list"];

            _list = str(_this);
            _list = [_list, "[", ""] call CBA_fnc_replace;
            _list = [_list, "]", ""] call CBA_fnc_replace;
            _list = [_list, "'", ""] call CBA_fnc_replace;
            _list = [_list, """", ""] call CBA_fnc_replace;
            _list = [_list, ",", ", "] call CBA_fnc_replace;
            _list;
};

// Whether one building can carry an asymmetric installation: free, destructible, with indoor positions,
// big enough and not a tower or other blacklisted kind. Split out of the filter below so a caller after
// one building can stop at the first that passes (A. Ares on Discord, 16 Oct: on Normandy's 400-800 m
// objectives checking every building took 0.5 to 4 s an objective, and an Asymmetric commander with
// 176 objectives took 5 to 8 minutes to start).
ALiVE_fnc_INS_buildingSuitable = {
    params ["_h"];
    private _ok = true;
    scopeName "suitable";
        private _type = typeOf _h;
        private _blacklist = ["tower","cage","platform","trench","bridge"];

        //["Building selected: %1 | %2",typeOf _h, _h] call ALiVE_fnc_DumpR;

        // Already carrying an installation, so leave it alone.
        //
        // Two installations on one building look fine while they are being placed and then fail
        // silently. The second one finds the building already furnished, so the furniture pass
        // returns empty without a word, and the hold action is refused because one of the same
        // kind is already attached. The result is an IED factory that is registered, marked on
        // the map, and has nothing in it and no way to disable it (#1003).
        //
        // Checked first because it is the cheapest test here, and because a building that is
        // already taken should not cost an indoor-position sweep to reject.
        if !(([_h] call ALiVE_fnc_INS_getBuildingInstallations) isEqualTo []) then {
            false breakOut "suitable"
        };

        // A building players cannot bring down is no place for an installation: the way to end
        // one is to destroy its building. Some classes are made indestructible in their config
        // (destrType DestructNo), so charges do nothing and the installation and its marker stay
        // for good. Measured on Malden: 114 of 2,534 enterable buildings, and 5 demolition charges
        // left one at damage 0 while the destructible ones beside it went down.
        if ((getText (configOf _h >> "destrType")) == "DestructNo" || {!isDamageAllowed _h}) then {
            false breakOut "suitable"
        };

        private _buildingPositions = [getposATL _h,5] call ALIVE_fnc_findIndoorHousePositions;
        
        if (count _buildingPositions == 0) then {
            //["Deleted buildingtype %1! No indoor houseposition!",typeof _h] call ALiVE_fnc_DumpR;
            _ok = false;
        } else {          
            private _dimensions = _h call BIS_fnc_boundingBoxDimensions;

            // too small
            if (((_dimensions select 0) + (_dimensions select 1)) < 10) then {
                //["Deleted buildingtype %1! Building is too small!",typeof _h] call ALiVE_fnc_DumpR;

                _ok = false;
            } else {
                if (
                    //Building is double as high as broad and is very likely a tower, or contains a blacklisted class
                    (((_dimensions select 2)/2) > (_dimensions select 0) && {((_dimensions select 2)/2) > (_dimensions select 1)})
                    ||
                    {{[_type , _x] call CBA_fnc_find != -1} count _blacklist > 0}
                ) then {
                    //["Deleted buildingtype %1! Building is a tower or blacklisted!",typeof _h] call ALiVE_fnc_DumpR;
                    _ok = false;
                };
            };
        };
    _ok
};

// The buildings in an objective that can carry an installation. With nothing more it checks them all.
// Optional: _want stops once that many are found; _from checks them nearest that point first, so with
// _want 1 the answer is the nearest suitable one; _skip leaves those buildings out unchecked.
ALiVE_fnc_INS_filterObjectiveBuildings = {

    params ["_center","_size",["_want", -1],["_from", []],["_skip", []]];

    // Every House and Building in reach, nearest first (nearestObjects sorts them), tested one at a time and
    // only until enough are found: on Normandy an 800 m objective holds thousands of walls, fences and sheds, and
    // testing them all for being enterable cost 0.3 to 1.4 s a call before any of them was looked at. Searching
    // from _from takes in what is within the objective around that point instead.
    private _origin = if (_from isNotEqualTo []) then {_from} else {_center};
    private _reach = if (_from isNotEqualTo []) then {_size + (_from distance2D _center)} else {_size};
    private _near = nearestObjects [_origin, ["House","Building","land_vn_cave_base"], _reach];
    if (_from isNotEqualTo []) then { _near = _near select { (_x distance2D _center) <= _size } };
    if (_skip isNotEqualTo []) then { _near = _near - _skip };

    private _found = [];
    {
        if ([_x] call ALIVE_fnc_isHouseEnterable && {[_x] call ALiVE_fnc_INS_buildingSuitable}) then {
            _found pushBack _x;
            if (_want > 0 && {count _found >= _want}) then { break };
        };
    } forEach _near;

    _found
};

// Civilians who have had insurgents among them: every spawned civilian within 30 m of one of this insurgent
// commander's groups is marked ALiVE_CivPop_InsurgentContact, which makes "Has anyone been pressuring you?" a yes.
// The installation and bomber marks cover where insurgents set up; this covers where their patrols walk. Only
// spawned groups and spawned civilians, so it costs nothing where no player is. [commander's handler]; returns how
// many it marked.
ALiVE_fnc_INS_contactSweep = {
    params ["_handler"];
    private _side = [[_handler, "side", ""] call ALiVE_fnc_HashGet] call ALIVE_fnc_sideTextToObject;
    private _marked = 0;
    {
        private _leader = leader _x;
        if (side _x == _side && {alive _leader} && {!isPlayer _leader} && {vehicle _leader == _leader || {(speed vehicle _leader) < 20}}) then {
            {
                if (side group _x == civilian && {!isPlayer _x} && {alive _x} && {!(_x getVariable ["ALiVE_CivPop_InsurgentContact", false])}) then {
                    _x setVariable ["ALiVE_CivPop_InsurgentContact", true, true];
                    _marked = _marked + 1;
                };
            } forEach (_leader nearEntities ["CAManBase", 30]);
        };
    } forEach allGroups;
    _marked
};
