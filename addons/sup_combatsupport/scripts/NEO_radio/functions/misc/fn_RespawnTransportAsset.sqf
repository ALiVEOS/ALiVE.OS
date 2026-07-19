
#define DEFAULT_TRANSPORT_TASKS ["Pickup", "Land", "Land (Eng off)", "Move", "Circle", "Insertion", "Slingload", "Unhook"]

private ["_veh", "_grp", "_callsign", "_pos", "_dir","_height","_type", "_respawn","_code","_tasks","_faction","_side","_sides","_slingloading"];

_veh = _this select 0;
_grp = _this select 1;
_callsign = _this select 2;
_pos = _this select 3;
_dir = _this select 4;
_height = _this select 5;
_type = _this select 6;
_respawn = _this select 7;
_code = _this select 8;
_slingloading = _this select 9;

// Snapshot Military Logistics Simulation settings off the old vehicle before it's replaced
// so the new Transport asset stays registered with the resupply watchdog.
private _oldLogisticsEnabled = _veh getVariable ["ALIVE_logistics_enabled", false];
private _oldLogisticsSource = _veh getVariable ["ALIVE_logistics_source", 0];

//define defaults

_faction = gettext(configfile >> "CfgVehicles" >> _type >> "faction");
_sides = [WEST,EAST,RESISTANCE,CIVILIAN];

//get side
switch ((getNumber(configfile >> "CfgVehicles" >> _type >> "side"))) do {
    case 0 : {_side = EAST};
    case 1 : {_side = WEST};
    case 2 : {_side = RESISTANCE};
    default {_side = EAST};
};

//Exit if limit is reached
if (TRANS_RESPAWN_LIMIT == 0) exitwith {
    _replen = format ["All units! We are out of transport assets"];
    [[player,_replen,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
};

//Start respawning if not exited
sleep _respawn;
TRANS_RESPAWN_LIMIT = TRANS_RESPAWN_LIMIT - 1;

//Remove from all side-lists
{
    private ["_sideArray","_sideIn"];
    _sideIn = _x;
    _sideArray = NEO_radioLogic getVariable [format["NEO_radioTrasportArray_%1", _sideIn],[]];
    {
        if (isnull (_x select 0) || {((_x select 0) == _veh)}) then {
            _sideArray set [_foreachIndex, -1];
            _sideArray = _sideArray - [-1];
        };
    } foreach _sideArray;
    NEO_radioLogic setVariable [format["NEO_radioTrasportArray_%1", _sideIn], _sideArray, true];
} foreach _sides;

sleep (floor (random [3,6,9]));

// Don't yank a disabled transport out from under the player who called it. If a player is
// aboard or standing next to the downed asset (e.g. it hard-landed at their position and cut
// its engine), leave the airframe + crew where they are - it's already de-listed above, so it's
// no longer a callable asset, and garbage collection cleans it up later. The replacement still
// comes in from base. Anything downed away from players is recycled immediately as before.
private _keepAsset = (!isNull _veh) && {
    ({ isPlayer _x } count crew _veh > 0)
    || ({ isPlayer _x && { alive _x } && { _x distance _veh < 120 } } count allPlayers > 0)
};

// #530: the door gunners live in their own group (NEO_radioGunnerGroup), so they are NOT in
// units _grp - grab it while _veh still exists so we can recycle them alongside the rest
private _gunGrp = if (!isNull _veh) then { _veh getVariable ["NEO_radioGunnerGroup", grpNull] } else { grpNull };

//Delete objects and groups
if (!isNull _veh && {!_keepAsset}) then {
    deletevehicle _veh;
};

if (!isNull _grp && {!_keepAsset}) then {
    {deletevehicle _x} foreach units _grp;
    _grp call ALiVE_fnc_DeleteGroupRemote;
};

if (!isNull _gunGrp && {!_keepAsset}) then {
    {deletevehicle _x} foreach units _gunGrp;
    deleteGroup _gunGrp;
};

if (!_keepAsset) then { waitUntil {isNull _veh} };

private ["_veh","_grp"];

_veh = nearestObjects [_pos, [_type], 5];

if (count _veh == 0) then {
    _grp = createGroup _side;
    _veh = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
    _veh setDir _dir;
    _veh setPosATL _pos;

    If (_height > 0) then {
        _veh setposasl [getposASL _veh select 0, getposASL _veh select 1, _height];
        _veh setVelocity [0, 0, -1];
    } else {
        _veh setPosATL _pos
    };

    createVehicleCrew _veh;
    _crew = crew _veh;
    _crew joinSilent _grp;
    _grp addVehicle _veh;

    _veh lockDriver true;
    _veh setVariable ["ALIVE_CombatSupport", true];
    (driver _veh) setvariable ["VCOM_NOAI", true];
} else {
    _veh = _veh select 0;
    waitUntil {(_veh getVariable ["ALIVE_CombatSupport", false])};
    _grp = (group (driver _veh));
};

// Restore Military Logistics Simulation settings on the respawned Transport asset.
_veh setVariable ["ALIVE_logistics_enabled", _oldLogisticsEnabled, true];
_veh setVariable ["ALIVE_logistics_source", _oldLogisticsSource, true];

_ffvTurrets = [_type,true,true,false,true] call ALIVE_fnc_configGetVehicleTurretPositions;
_gunnerTurrets = [_type,false,true,true,true] call ALIVE_fnc_configGetVehicleTurretPositions;
_ffvTurrets = _ffvTurrets - _gunnerTurrets;

if(count _ffvTurrets > 0) then
{
    for "_i" from 0 to (count _ffvTurrets)-1 do {
        _turretPath = _ffvTurrets call BIS_fnc_arrayPop;
        [_veh turretUnit _turretPath] join grpNull;
        deleteVehicle (_veh turretUnit _turretPath);
    };
};

_hdl = [[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;
waituntil {scriptdone _hdl};

sleep 1;

_codeArray = [_code, ";"] Call CBA_fnc_split;
{
  If(_x != "") then {
      [_veh, _x] spawn {
         private ["_veh", "_spawn"];
         _veh = _this select 0;
         _spawn = compile(_this select 1);
         [_veh] spawn _spawn;
      };
  };
} forEach _codeArray;

if (!_slingloading) then {
    _tasks = DEFAULT_TRANSPORT_TASKS - ["Slingload","Unhook"];
} else {
    _tasks = DEFAULT_TRANSPORT_TASKS;
};

//Set variables and run FSM and optionally passed code
_veh setVariable ["NEO_transportAvailableTasks", _tasks, true];

private _audio = NEO_radioLogic getvariable ["combatsupport_audio",true];

//Start FSM
private _transportfsm = "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\transport.fsm";
private _fsmHandle = [_veh, _grp, _callsign, _pos, _dir,_height,_type, _respawn,_code,_audio,_slingloading] execFSM _transportfsm;

//Register to all friendly side-lists
{
    if (_side getfriend _x >= 0.6) then {
        private ["_array"];

        _array = NEO_radioLogic getVariable format["NEO_radioTrasportArray_%1", _x];
        _array pushback ([_veh, _grp, _callsign, _fsmHandle]);

        NEO_radioLogic setVariable [format["NEO_radioTrasportArray_%1", _x], _array,true];
    };
} foreach _sides;

_replen = format["All units this is %1! We are back on station and are ready for tasking", _callsign] ;
[[player,_replen,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
