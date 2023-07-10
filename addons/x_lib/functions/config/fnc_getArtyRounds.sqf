private ["_class","_weapon","_weaponClass","_mags""_result"];

_class = _this;

if(_class isEqualTo "BUS_MotInf_MortTeam") then {
_class    = "B_MBT_01_arty_F"
};

_mags = [configfile >> "CfgVehicles" >> _class >> "Turrets" >> "MainTurret" >> "magazines"] call ALiVE_fnc_getConfigValue;

private _roundsAvail = [];

 {
     private _he      = ["HE",      _x] call ALIVE_fnc_isMagazineOfOrdnanceType;
     private _smoke   = ["SMOKE",   _x] call ALIVE_fnc_isMagazineOfOrdnanceType;
     private _wp      = ["WP",      _x] call ALIVE_fnc_isMagazineOfOrdnanceType;
     private _guided  = ["SADARM",  _x] call ALIVE_fnc_isMagazineOfOrdnanceType;
     private _cluster = ["CLUSTER", _x] call ALIVE_fnc_isMagazineOfOrdnanceType;
     private _lg      = ["LASER",   _x] call ALIVE_fnc_isMagazineOfOrdnanceType;
     private _mine    = ["MINE",    _x] call ALIVE_fnc_isMagazineOfOrdnanceType;
     private _atmine  = ["AT MINE", _x] call ALIVE_fnc_isMagazineOfOrdnanceType;
     private _rockets = ["ROCKETS", _x] call ALIVE_fnc_isMagazineOfOrdnanceType;
     private _illum   = ["ILLUM",   _x] call ALIVE_fnc_isMagazineOfOrdnanceType;

     if (_he) then {
         _roundsAvail =  _roundsAvail + ["HE"];
     };
     if (_smoke) then {
         _roundsAvail =  _roundsAvail + ["SMOKE"];
     };
     if (_wp) then {
         _roundsAvail =  _roundsAvail + ["WP"];
     };
     if (_guided) then {
         _roundsAvail =  _roundsAvail + ["SADARM"];
     };
     if (_cluster) then {
         _roundsAvail =  _roundsAvail + ["CLUSTER"];
     };
     if (_lg) then {
         _roundsAvail =  _roundsAvail + ["LASER"];
     };
     if (_mine) then {
         _roundsAvail =  _roundsAvail + ["MINE"];
     };
     if (_atmine) then {
         _roundsAvail =  _roundsAvail + ["AT MINE"];
     };
     if (_rockets) then {
          _roundsAvail =  _roundsAvail + ["ROCKETS"];
     };
     if (_illum) then {
         _roundsAvail =  _roundsAvail + ["ILLUM"];
     };
} forEach _mags;



_roundsAvail;
