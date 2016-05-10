private ["_veh","_grp","_callsign","_pos", "_dir", "_type", "_airport", "_code","_height","_side","_respawn","_sides"];

_veh = _this select 0;
_grp = _this select 1;
_callsign = _this select 2;
_pos = _this select 3;
_dir = _this select 4;
_height = _this select 5;
_type = _this select 6;
_airport = _this select 7;
_respawn = _this select 8;

//define defaults
_code = _this select 9;
_tasks = ["Pickup", "Land", "land (Eng off)", "Move", "Circle","Insertion"];
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
if (CAS_RESPAWN_LIMIT == 0) exitwith {
    _replen = format ["All units! We are out of CAS assets"];
	[[player,_replen,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
};

//Start respawning if not exited
sleep _respawn;
CAS_RESPAWN_LIMIT = CAS_RESPAWN_LIMIT - 1;

//Remove from all side-lists
{
		private ["_sideArray","_sideIn"];
        _sideIn = _x;
		_sideArray = NEO_radioLogic getVariable [format["NEO_radioCasArray_%1", _sideIn],[]];
        {
            if (isnull (_x select 0) || {((_x select 0) == _veh)}) then {
                _sideArray set [_foreachIndex, -1];
				_sideArray = _sideArray - [-1];
            };
        } foreach _sideArray;
        NEO_radioLogic setVariable [format["NEO_radioCasArray_%1", _sideIn], _sideArray, true];
} foreach _sides;

//Delete objects and groups
deletevehicle _veh;
{deletevehicle _x} foreach units _grp;
_grp call ALiVE_fnc_DeleteGroupRemote;

sleep 5;

private ["_veh","_grp"];

_grp = createGroup _side;
_veh = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
_veh setDir _dir;
_veh setPosATL _pos;

if (_height > 0) then {
	_veh setposASL [getposASL _veh select 0, getposASL _veh select 1, _height];
} else {
	_veh setPosATL _pos;
};

_veh setVelocity [0,0,-1];
_veh setVariable ["ALIVE_CombatSupport", true];

if (getNumber(configFile >> "CfgVehicles" >> _type >> "isUav")==1) then {
	createVehicleCrew _veh;
} else {
	[_veh, _grp] call BIS_fnc_spawnCrew;
};



_veh lockDriver true;

_ffvTurrets = [_type,true,true,false,true] call ALIVE_fnc_configGetVehicleTurretPositions;
                                _gunnerTurrets = [_type,false,true,true,true] call ALIVE_fnc_configGetVehicleTurretPositions;
                                _ffvTurrets = _ffvTurrets - _gunnerTurrets;

                           if(count _ffvTurrets > 0) then
                            {
                                for "_i" from 0 to (count _ffvTurrets)-1 do
                                    {
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

//FSM
_casfsm = "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\cas.fsm";
[_veh, _grp, _callsign, _pos, _airport, _dir, _height, _type, _respawn, _code] execFSM _casfsm;


//Register to all friendly side-lists
{
	if (_side getfriend _x >= 0.6) then {
		private ["_array"];

		_array = NEO_radioLogic getVariable format["NEO_radioCasArray_%1", _x];
        _array set [count _array,[_veh, _grp, _callsign]];

        NEO_radioLogic setVariable [format["NEO_radioCasArray_%1", _x], _array,true];
	};
} foreach _sides;

_replen = format ["All Units this is %1, We are back on Station and are ready for tasking", _callsign] ;
[[player,_replen,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;