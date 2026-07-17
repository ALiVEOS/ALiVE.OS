#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOMAsymmetricState);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OPCOMAsymmetricState
Description:
Returns installation and profiled force counts for asymmetric OPCOM instances.
Needs to run serverside.

Parameters:
Any - Optional selector. Supports:
    - nil / objNull for all asymmetric OPCOM instances
    - Side or side text (for example east or "EAST")
    - Faction string (for example "OPF_G_F")
    - OPCOM ID string
    - OPCOM module object
    - OPCOM handler hash

Returns:
Hash - State hash with:
    HQ
    recruitmentHQ
    depot
    factory
    ambush
    sabotage
    ied
    suicide
    roadblocks
    allInstallations
    profiles
    profileGroups
    entityProfiles
    vehicleProfiles
    allProfiles
    factions
    handlers
Nil - On non-server machines

Examples:
(begin example)
_state = [east] call ALIVE_fnc_OPCOMAsymmetricState;
_condition = ([_state,"recruitmentHQ",0] call ALIVE_fnc_hashGet == 0) &&
    {([_state,"profileGroups",0] call ALIVE_fnc_hashGet < 15)};
(end)

See Also:

Author:
ALiVE Team
---------------------------------------------------------------------------- */

private [
    "_target",
    "_state",
    "_handlers",
    "_factions",
    "_targetIsAll",
    "_targetSide",
    "_targetString",
    "_targetFaction",
    "_targetOpcomID",
    "_baseInstallations",
    "_entityProfiles",
    "_vehicleProfiles",
    "_allProfiles"
];

_target = objNull;
if (count _this > 0 && {!isNil {_this select 0}}) then {
    _target = _this select 0;
};

if !(isServer) exitWith {
    ["ALiVE_fnc_OPCOMAsymmetricState needs to run serverside"] call ALIVE_fnc_dump;
    nil
};

_state = [] call ALIVE_fnc_hashCreate;
{
    [_state,_x,0] call ALIVE_fnc_hashSet;
} forEach [
    "HQ",
    "recruitmentHQ",
    "depot",
    "factory",
    "ambush",
    "sabotage",
    "ied",
    "suicide",
    "roadblocks",
    "allInstallations",
    "profiles",
    "profileGroups",
    "entityProfiles",
    "vehicleProfiles",
    "allProfiles"
];
[_state,"factions",[]] call ALIVE_fnc_hashSet;
[_state,"handlers",[]] call ALIVE_fnc_hashSet;

if (isNil "OPCOM_instances" || {count OPCOM_instances == 0}) exitWith {_state};

private _getSideText = {
    params ["_value"];

    private _result = "";

    if (_value isEqualType east) then {
        if (_value == east) then {_result = "EAST"};
        if (_value == west) then {_result = "WEST"};
        if (_value == resistance) then {_result = "GUER"};
        if (_value == civilian) then {_result = "CIV"};
    };

    if (_value isEqualType "") then {
        _result = toUpper _value;
        if (_result == "RESISTANCE") then {_result = "GUER"};
        if !(_result in ["EAST","WEST","GUER","CIV"]) then {
            _result = "";
        };
    };

    _result
};

_handlers = [];
_factions = [];

_targetIsAll = (_target isEqualType objNull) && {isNull _target};
_targetSide = [_target] call _getSideText;
_targetString = if (_target isEqualType "") then {_target} else {""};
_targetFaction = "";
_targetOpcomID = "";

if (_targetString != "" && {_targetSide == ""}) then {
    _targetFaction = _targetString;
    _targetOpcomID = _targetString;
};

{
    private _handler = _x;
    private _controlType = [_handler,"controltype",""] call ALIVE_fnc_hashGet;
    private _match = false;

    if (_controlType == "asymmetric") then {
        _match = _targetIsAll;

        if (!_match && {[_target] call ALIVE_fnc_isHash}) then {
            _match = _target isEqualTo _handler;
        };

        if (!_match && {_target isEqualType objNull && {!isNull _target}}) then {
            private _moduleHandler = _target getVariable ["handler",[]];
            if ([_moduleHandler] call ALIVE_fnc_isHash) then {
                _match = _moduleHandler isEqualTo _handler;
            };
        };

        if (!_match && {_targetSide != ""}) then {
            _match = ([_handler,"side",""] call ALIVE_fnc_hashGet) == _targetSide;
        };

        if (!_match && {_targetOpcomID != ""}) then {
            _match = ([_handler,"opcomID",""] call ALIVE_fnc_hashGet) == _targetOpcomID;
        };

        if (!_match && {_targetFaction != ""}) then {
            _match = _targetFaction in ([_handler,"factions",[]] call ALIVE_fnc_hashGet);
        };

        if (_match) then {
            _handlers pushBackUnique _handler;
        };
    };
} forEach OPCOM_instances;

{
    {
        _factions pushBackUnique _x;
    } forEach ([_x,"factions",[]] call ALIVE_fnc_hashGet);
} forEach _handlers;

if (count _factions == 0 && {_targetFaction != ""}) then {
    _factions pushBackUnique _targetFaction;
};

[_state,"factions",_factions] call ALIVE_fnc_hashSet;
[_state,"handlers",_handlers] call ALIVE_fnc_hashSet;

_baseInstallations = [
    ["HQ","HQ"],
    ["depot","depot"],
    ["factory","factory"],
    ["ambush","ambush"],
    ["sabotage","sabotage"],
    ["ied","ied"],
    ["suicide","suicide"],
    ["roadblocks","roadblocks"]
];

// Count active insurgency installations from the objective hashes owned by each matched asymmetric OPCOM.
{
    private _handler = _x;
    // #727 - a removed objective keeps its still-alive installation objects, so
    // filter deleted objectives out or the counts stay inflated (mirrors the
    // OPCOM/TACOM removed-objective guards on the non-asymmetric paths).
    private _objectives = ([_handler,"objectives",[]] call ALIVE_fnc_hashGet) select {
        !([_x,"deleted",false] call ALiVE_fnc_HashGet)
    };

    {
        private _objective = _x;

        {
            private _stateKey = _x select 0;
            private _objectiveKey = _x select 1;
            private _installation = [_handler,"convertObject",[_objective,_objectiveKey,[]] call ALIVE_fnc_hashGet] call ALIVE_fnc_OPCOM;

            if (alive _installation) then {
                [_state,_stateKey,([_state,_stateKey,0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
                [_state,"allInstallations",([_state,"allInstallations",0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
            };
        } forEach _baseInstallations;
    } forEach _objectives;
} forEach _handlers;

[_state,"recruitmentHQ",[_state,"HQ",0] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;

_entityProfiles = [];
_vehicleProfiles = [];
_allProfiles = [];

if !(isNil "ALIVE_profileHandler") then {
    {
        private _faction = _x;
        private _factionEntityProfiles = [ALIVE_profileHandler, "getProfilesByFactionByType", [_faction,"entity"]] call ALIVE_fnc_profileHandler;
        private _factionVehicleProfiles = [ALIVE_profileHandler, "getProfilesByFactionByType", [_faction,"vehicle"]] call ALIVE_fnc_profileHandler;
        private _factionProfiles = [ALIVE_profileHandler, "getProfilesByFaction", _faction] call ALIVE_fnc_profileHandler;

        if (isNil "_factionEntityProfiles") then {_factionEntityProfiles = []};
        if (isNil "_factionVehicleProfiles") then {_factionVehicleProfiles = []};
        if (isNil "_factionProfiles") then {_factionProfiles = []};

        {_entityProfiles pushBackUnique _x} forEach _factionEntityProfiles;
        {_vehicleProfiles pushBackUnique _x} forEach _factionVehicleProfiles;
        {_allProfiles pushBackUnique _x} forEach _factionProfiles;
    } forEach _factions;
};

[_state,"profiles",count _entityProfiles] call ALIVE_fnc_hashSet;
[_state,"profileGroups",count _entityProfiles] call ALIVE_fnc_hashSet;
[_state,"entityProfiles",count _entityProfiles] call ALIVE_fnc_hashSet;
[_state,"vehicleProfiles",count _vehicleProfiles] call ALIVE_fnc_hashSet;
[_state,"allProfiles",count _allProfiles] call ALIVE_fnc_hashSet;

_state
