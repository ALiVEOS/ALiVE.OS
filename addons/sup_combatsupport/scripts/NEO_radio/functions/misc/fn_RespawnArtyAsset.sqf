private ["_veh", "_grp", "_callsign", "_pos", "_dir","_height","_type", "_respawn","_code","_tasks","_faction","_side","_sides"];

private ["_pos", "_class", "_callsign", "_unitCount", "_rounds", "_code", "_roundsUnit", "_roundsAvailable", "_canMove", "_units", "_grp", "_vehDir","_artyBatteries"];
_units = _this select 0;
_grp = _this select 1;
_callsign = _this select 2;
_pos = _this select 3;
_availableRounds = _this select 4;
_canMove = _this select 5;
_type = _this select 6;
_battery = _this select 7;
_respawn = _this select 8;

_unitCount = count _units; if (_unitCount > 4) then { _unitCount = 4 }; if (_unitCount < 1) then { _unitCount = 1 };
_canMove = if (_type in ["B_MBT_01_arty_F", "O_MBT_02_arty_F", "B_MBT_01_mlrs_F","O_Mortar_01_F", "B_Mortar_01_F","I_Mortar_01_F","BUS_Support_Mort","BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","OI_support_Mort","HAF_MotInf_MortTeam","HAF_Support_Mort"]) then { true } else { false };
_rounds = _availableRounds;
_roundsUnit = _type call NEO_fnc_artyUnitAvailableRounds;
_roundsAvailable = [];


//define defaults
_code = _this select 9;
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
if (ARTY_RESPAWN_LIMIT == 0) exitwith {
    _replen = format ["All units! We are out of arty assets"];
	[[player,_replen,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
};

//Start respawning if not exited
sleep _respawn;
ARTY_RESPAWN_LIMIT = ARTY_RESPAWN_LIMIT - 1;

//Remove from all side-lists
_toDelete = [];
{
		private ["_sideArray","_sideIn"];
        _sideIn = _x;
		_sideArray = NEO_radioLogic getVariable [format["NEO_radioArtyArray_%1", _sideIn],[]];
        {
            if (count _units > 0) then {
                _toDelete set [count _toDelete,_x];

                _sideArray set [_foreachIndex, -1];
				_sideArray = _sideArray - [-1];
            };
        } foreach _sideArray;
        NEO_radioLogic setVariable [format["NEO_radioArtyArray_%1", _sideIn], _sideArray, true];
} foreach _sides;

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

if (_side == WEST && _type == "BUS_MotInf_MortTeam") then {
    // Spawn a mortar team :)
    private ["_veh","_vehPos"];
    _vehPos = [_pos, 30, _vehDir] call BIS_fnc_relPos; _vehPos set [2, 0];
    _grp = [_vehPos, side _grp, (configFile >> "cfgGroups" >> "WEST" >> "BLU_F" >> "Motorized" >> "BUS_MotInf_MortTeam"),[],[],[],[],[],_vehDir] call BIS_fnc_spawnGroup;
    {
        _units set [count _units, _x];
        _x setVariable ["ALIVE_CombatSupport", true];
    } foreach units _grp;
} else {
    private ["_vehPos","_i"];
    for "_i" from 1 to _unitCount do
    {
        private ["_veh"];
        _vehPos = [_pos, 15, _vehDir] call BIS_fnc_relPos; _vehPos set [2, 0];
		_veh = createVehicle [_type, _vehPos, [], 0, "CAN_COLLIDE"];
		_veh setDir _vehDir;
		_veh setPosATL _vehPos;
		[_veh, _grp] call BIS_fnc_spawnCrew;
		_veh lock true;
		_vehDir = _vehDir + 90;
        
		_units set [count _units, _veh];
        _artyBatteries pushback _veh;

        // set ownership flag for other modules
        _veh setVariable ["ALIVE_CombatSupport", true];
    };
};

{_x setVariable ["NEO_radioArtyModule", [leader _grp, _callsign], true]} forEach _units;

[[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;

//Validate rounds
{
	if ((_x select 0) in _roundsUnit) then
	{
		_roundsAvailable set [count _roundsAvailable, _x];
	};
} forEach _rounds;

leader _grp setVariable ["NEO_radioArtyBatteryRounds", _roundsAvailable, true];

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

//FSM
[_units, _grp, _callsign, _pos, _roundsAvailable, _canMove, _type, leader _grp, _code] execFSM "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\alivearty.fsm";

_a = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", _side];
_a set [count _a, [leader _grp, _grp, _callsign, _units, _roundsAvailable]];

NEO_radioLogic setVariable [format ["NEO_radioArtyArray_%1", _side], _a, true];

_replen = format["All units this is %1! We are back on station and are ready for tasking", _callsign] ;
[[player,_replen,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
