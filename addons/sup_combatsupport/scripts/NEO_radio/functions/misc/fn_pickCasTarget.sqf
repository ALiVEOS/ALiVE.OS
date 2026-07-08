private["_veh","_pos","_radius","_targets","_target","_enemySides","_classList","_parents"];
_veh = _this select 0;
_pos = _this select 1;
_radius = _this select 2;
_weapon = _this select 3;

_enemySides = _veh call BIS_fnc_enemySides;
_target = objNull;

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

scopeName "main";

_targets = _pos nearEntities [_classList, _radius];
[_targets,true] call CBA_fnc_shuffle;

{
    if ((side _x) == (side _veh) && {_x isKindOf "LaserTargetBase"}) exitWith {_target = _x};

    if (alive _x && {(side _x) in _enemySides}) then {
        if(isNull _target && {random 1 > .5}) then {
            (group (driver _veh)) reveal _x;
            _target = _x;

            breakTo "main";
        } else {
            _target = _x;

            breakTo "main";
        };
    };
} forEach _targets;

// Check to see if weapon is unguided bomb, if so then add a lasertarget to help AI Pilots fire at something...
// Only auto-lase when a real target was found, and use a laser class the shooter's side can actually see
if (!isNull _target && {!(_target isKindOf "LaserTargetBase")} && {getNumber(configFile >> "CfgWeapons" >> _weapon >> "canLock") == 0 && getText(configFile >> "CfgWeapons" >> _weapon >> "cursorAim") == "bomb"} ) then {
    private _lazor = "LaserTargetE";
    if (side _veh getFriend WEST > 0.6) then {_lazor = "LaserTargetW"};
    private _laser = _lazor createVehicle [getpos _target select 0,getpos _target select 1,0];
    _laser setVariable ["NEO_radioAutoLase", true];
    _laser attachto [_target,[0,0,4]];
    _target = _laser;
};

_target;
