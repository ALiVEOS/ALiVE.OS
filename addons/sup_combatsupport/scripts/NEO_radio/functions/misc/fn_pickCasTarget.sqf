private["_veh","_pos","_radius","_targets","_target","_enemySides","_classList","_parents"];
_veh = _this select 0;
_pos = _this select 1;
_radius = _this select 2;
_weapon = _this select 3;

_parents = [ (configFile >> "CfgWeapons" >> _weapon),true] call BIS_fnc_returnParents;
if("MissileLauncher" in _parents) then {
    _classList = ["LaserTargetBase", "Tank", "Wheeled_apc"];
} else {
    if("RocketPods" in _parents) then {
        _classList = ["LaserTargetBase", "Man","Air","Car","Motorcycle","Tank", "Wheeled_apc"];
    } else {
        _classList = ["LaserTargetBase", "Man","Air","Car","Motorcycle", "Wheeled_apc"];
    };
};

_targets = (_pos nearEntities [_classList, _radius]);
_target = objNull;

_enemySides = _veh call BIS_fnc_enemySides;
{
    if( (side _x) == (side _veh) && _x isKindOf "LaserTargetBase") exitWith { _target = _x; };

    if (alive _x && (side _x) in _enemySides ) then {
        if(isNull _target && random 1 > .5) then {
            (group (driver _veh)) reveal _x;
            _target = _x;
        } else {
            _target = _x;
        };
    };
} forEach _targets;

// Check to see if weapon is unguided bomb, if so then add a lasertarget to help AI Pilots fire at something...
if (!(_target isKindOf "LaserTargetBase") && getNumber(configFile >> "CfgWeapon" >> _weapon >> "canLock") == 0 && getText(configFile >> "CfgWeapon" >> _weapon >> "cursorAim") == "bomb" ) then {
    private _laser = "LaserTargetBase" createVehicle [getpos _target select 0,getpos _target select 1,0];
    _laser attachto [_target,[0,0,4]];
    _target = _laser;
};

_target;
