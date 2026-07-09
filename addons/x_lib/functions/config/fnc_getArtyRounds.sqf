private ["_class","_mags"];

_class = _this;

if(_class isEqualTo "BUS_MotInf_MortTeam") then {
_class    = "B_MBT_01_arty_F"
};

// #887 - collect magazines from EVERY turret (mod artillery often mounts the
// gun outside MainTurret), with a vehicle-level fallback for statics
_mags = [];
{
    _mags append (getArray (_x >> "magazines"));
} forEach ("isClass _x" configClasses (configfile >> "CfgVehicles" >> _class >> "Turrets"));

if (_mags isEqualTo []) then {
    _mags = getArray (configfile >> "CfgVehicles" >> _class >> "magazines");
};

private _allTypes = ["HE","SMOKE","WP","SADARM","CLUSTER","LASER","MINE","AT MINE","ROCKETS","ILLUM"];
private _roundsAvail = [];

{
    private _mag = _x;
    {
        if ([_x, _mag] call ALIVE_fnc_isMagazineOfOrdnanceType) then {
            _roundsAvail pushBackUnique _x;
        };
    } forEach _allTypes;
} forEach _mags;

_roundsAvail;
