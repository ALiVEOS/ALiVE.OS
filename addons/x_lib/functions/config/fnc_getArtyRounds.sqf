private ["_class","_mags"];

_class = _this;

if(_class isEqualTo "BUS_MotInf_MortTeam") then {
_class    = "B_MBT_01_arty_F"
};

// #887 - recursive turret walk + magazineWell resolution: mod artillery
// mounts guns on nested turrets and lists ordnance through wells
_mags = _class call ALIVE_fnc_getArtyMagazines;

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
