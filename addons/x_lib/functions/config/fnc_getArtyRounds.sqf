private ["_class","_mags"];

// takes a classname, or a live gun (or its crew, via vehicle). Only a live gun
// can answer the #950 fallback at the bottom.
private _gun = objNull;
if (_this isEqualType objNull) then {
    _gun = vehicle _this;
    _class = typeOf _gun;
} else {
    _class = _this;
};

if(_class isEqualTo "BUS_MotInf_MortTeam") then {
_class    = "B_MBT_01_arty_F"
};

// #887 - recursive turret walk + magazineWell resolution: mod artillery
// mounts guns on nested turrets and lists ordnance through wells
_mags = _class call ALIVE_fnc_getArtyMagazines;

private _allTypes = ["HE","SMOKE","WP","SADARM","CLUSTER","LASER","MINE","AT MINE","ROCKETS","ILLUM"];

// _this = the magazine list to classify
private _fnc_classify = {
    private _out = [];
    {
        private _mag = _x;
        {
            if ([_x, _mag] call ALIVE_fnc_isMagazineOfOrdnanceType) then {
                _out pushBackUnique _x;
            };
        } forEach _allTypes;
    } forEach _this;
    _out
};

private _roundsAvail = _mags call _fnc_classify;

// #950 - rocket artillery mounts its launcher at spawn: the Spearhead Calliope
// reports only its hull machine guns to a config walk and the RHS BM-21 reports
// nothing at all, so both offer no rounds and their tablet comes up empty. Given
// a live gun, ask the artillery computer what it can actually fire.
if (_roundsAvail isEqualTo [] && {!isNull _gun}) then {
    _roundsAvail = (getArtilleryAmmo [_gun]) call _fnc_classify;
};

_roundsAvail;
