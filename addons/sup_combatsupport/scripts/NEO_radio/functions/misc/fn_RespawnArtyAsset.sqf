private [
    "_grp", "_callsign", "_pos", "_type", "_respawn","_code", "_side",
    "_leader", "_unitCount", "_rounds", "_roundsUnit", "_roundsAvailable",
    "_canMove", "_units", "_grp", "_vehDir", "_artyBatteries"
];

_units = _this select 0;
_grp = _this select 1;
_callsign = _this select 2;
_pos = _this select 3;
_availableRounds = _this select 4;
_canMove = _this select 5;
_type = _this select 6;
_battery = _this select 7;
_respawn = _this select 8;
_code = _this select 9;
_leader = _battery;
_side = _this select 10;

_unitCount = count _units; if (_unitCount > 4) then { _unitCount = 4 }; if (_unitCount < 1) then { _unitCount = 1 };
// _canMove comes from the battery being replaced, which weighed both whether its class can
// move and the module's Allow Repositioning. Working it out again here from a list of
// vanilla classes dropped that setting and pinned every modded battery in place.
_rounds = _availableRounds;
_roundsAvailable = [];

//Exit if limit is reached
if (ARTY_RESPAWN_LIMIT == 0) exitwith {
    _replen = format ["All units! We are out of arty assets"];
    [[player,_replen,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
};

//Start respawning if not exited
sleep _respawn;
// Checked again after the wait, and taken in the same unscheduled step: 2 batteries lost close
// together both passed the check above, both took 1 off, and the limit went below 0, where it
// never stopped anything again.
private _outOfAssets = false;
isNil { if (ARTY_RESPAWN_LIMIT == 0) then { _outOfAssets = true } else { ARTY_RESPAWN_LIMIT = ARTY_RESPAWN_LIMIT - 1 } };
if (_outOfAssets) exitwith {
    _replen = format ["All units! We are out of arty assets"];
    [[player,_replen,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
};


//This unit cannot be used anymore, remove from side-list
_sideArray = NEO_radioLogic getVariable [format["NEO_radioArtyArray_%1", _side], []];

{
    if (_leader isEqualTo (_x select 0)) exitWith {
        _sideArray set [_forEachIndex, [-1]];
    };

} forEach _sideArray;

_sideArray = _sideArray - [[-1]];
NEO_radioLogic setVariable [format["NEO_radioArtyArray_%1", _side], _sideArray, true];

//Delete objects and groups
{deleteVehicle _x} foreach _units;
{deletevehicle _x} foreach units _grp;
_grp call ALiVE_fnc_DeleteGroupRemote;

sleep 5;

//Create new units and vehicles
_units = [];
_vehDir = 0;

_grp = createGroup _side;
_artyBatteries = [];

// A mortar team is named after its CfgGroups entry, not a vehicle, and the first spawn
// (fnc_combatSupport.sqf) puts down the side's static mortar in its place. Only NATO's
// motorised team had a case here, and it built a different team from the first spawn's;
// the other five names went to createVehicle, which made nothing, so the empty battery
// counted as lost at once and respawned again until the limit every battery shares ran out.
private _spawnClass = _type;
if (_type in ["BUS_Support_Mort","BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","OI_support_Mort","HAF_MotInf_MortTeam","HAF_Support_Mort"]) then {
    _unitCount = 1;
    _spawnClass = switch (_type select [0,1]) do {
        case "O" : {"O_Mortar_01_F"};
        case "H" : {"I_Mortar_01_F"};
        default {"B_Mortar_01_F"};
    };
};

private ["_vehPos","_i"];
for "_i" from 1 to _unitCount do
{
    private ["_veh"];
    _vehPos = (_pos getPos [15, _vehDir]); _vehPos set [2, 0];
    _veh = createVehicle [_spawnClass, _vehPos, [], 0, "CAN_COLLIDE"];
    _veh setDir _vehDir;
    _veh setPosATL _vehPos;
    createVehicleCrew _veh;
    _crew = crew _veh;
    _crew joinSilent _grp;
    _grp addVehicle _veh;
    _veh lock true;
    _vehDir = _vehDir + 90;

    _units pushback _veh;
    _artyBatteries pushback _veh;

    // Exclude CS from VCOM
    // CS only runs serverside so no PV is needed
    (driver _veh) setvariable ["VCOM_NOAI", true];

    // set ownership flag for other modules
    _veh setVariable ["ALIVE_CombatSupport", true];

    // Kept out of the profile system, as the first spawn keeps it.
    _veh setVariable ["ALIVE_profileIgnore", true];
    _grp setVariable ["ALIVE_profileIgnore", true];

    // A leader and an assistant to pack and carry the mortar, as the first spawn gives it.
    // Not the motorised teams' cars: the first spawn's are still parked where it left them.
    if (_spawnClass in ["O_Mortar_01_F","B_Mortar_01_F","I_Mortar_01_F"]) then {
        private _prefix = _spawnClass select [0,1];
        private _newgrp = [_vehPos, _side, [format ["%1_soldier_TL_F", _prefix], format ["%1_soldier_F", _prefix]],[],[],[],[],[],_vehDir] call BIS_fnc_spawnGroup;
        (units _newgrp) joinSilent _grp;
        deleteGroup _newgrp;

        private _sptarr = _grp getVariable ["supportWeaponArray",[]];
        _sptarr pushback _veh;
        _grp setvariable ["supportWeaponArray", _sptarr];
    };
};
// A fire mission splits its rounds over this many guns and a mortar team's unpack waits for
// this many tubes, so the default of 3 left a 1-tube team firing a third of every mission.
_grp setVariable ["supportWeaponCount", count _units];

{_x setVariable ["NEO_radioArtyModule", [leader _grp, _callsign], true]} forEach _units;

[[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;

//Validate rounds against what the new battery can fire: its live gun where there is one, as
//the first spawn does. NEO_fnc_artyUnitAvailableRounds only knows the vanilla classes, so a
//modded battery came back from a respawn with nothing on its tablet.
_roundsUnit = (if (count _artyBatteries > 0) then {_artyBatteries select 0} else {_type}) call ALiVE_fnc_GetArtyRounds;
{
    if ((_x select 0) in _roundsUnit) then
    {
        _roundsAvailable pushback _x;
    };
} forEach _rounds;

leader _grp setVariable ["NEO_radioArtyBatteryRounds", _roundsAvailable, true];

// Carry the Military Logistics Simulation settings from the old leader onto the new battery so
// the resupply watchdog keeps monitoring the asset after respawn. Variables are still readable
// on the dead leader via getVariable.
private _oldLogisticsEnabled = _battery getVariable ["ALIVE_logistics_enabled", false];
private _oldLogisticsSource = _battery getVariable ["ALIVE_logistics_source", 0];
private _oldDefaultRounds = _battery getVariable ["ALIVE_resupply_defaultRounds", _roundsAvailable];
{
    _x setVariable ["ALIVE_logistics_enabled", _oldLogisticsEnabled, true];
    _x setVariable ["ALIVE_logistics_source", _oldLogisticsSource, true];
    _x setVariable ["ALIVE_resupply_defaultRounds", _oldDefaultRounds, true];
} forEach _units;
private _newLeader = leader _grp;
_newLeader setVariable ["ALIVE_logistics_enabled", _oldLogisticsEnabled, true];
_newLeader setVariable ["ALIVE_logistics_source", _oldLogisticsSource, true];
_newLeader setVariable ["ALIVE_resupply_defaultRounds", _oldDefaultRounds, true];
if (count _units > 0) then {
    _newLeader setVariable ["ALIVE_resupply_primaryVehicle", _units select 0, true];
};

_codeArray = [_code, ";"] Call CBA_fnc_split;
{
    _vehicle = _x;
    {
        If(_x != "") then {
            [_vehicle, _x] spawn {
                private ["_vehicle", "_spawn"];
                _vehicle = _this select 0;
                _spawn = compile(_this select 1);
                [_vehicle] spawn _spawn;
            };
        };
    } forEach _codeArray;
} forEach _artyBatteries;

private _audio = NEO_radioLogic getvariable ["combatsupport_audio",true];

// Keep the battery on its emplacement unless repositioning was allowed - see the
// matching note at the initial-creation site in fnc_combatSupport.sqf. The FSM
// puts the guns into COMBAT so they engage freely, and Arma treats COMBAT as
// licence to manoeuvre, which drives a self-propelled piece off its position.
// A respawned battery needs the same treatment as the original.
if (!_canMove) then {
    {
        _x disableAI "PATH";
    } forEach (units _grp);
};

//FSM
private _artyfsm = "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\alivearty.fsm";
private _fsmHandle = [_units, _grp, _callsign, _pos, _roundsAvailable, _canMove, _type, leader _grp, _code, _audio, _side] execFSM _artyfsm;

private _artyAsset = NEO_radioLogic getVariable [format ["NEO_radioArtyArray_%1", _side], []];
_artyAsset pushback ([leader _grp, _grp, _callsign, _units, _roundsAvailable, _fsmHandle]);

NEO_radioLogic setVariable [format ["NEO_radioArtyArray_%1", _side], _artyAsset, true];

_replen = format["All units this is %1! We are back on station and are ready for tasking", _callsign] ;
[[player,_replen,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
