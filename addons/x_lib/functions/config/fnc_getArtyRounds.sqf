private ["_class","_weapon","_weaponClass","_mags""_result"];

_class = _this;

if(_class isEqualTo "BUS_MotInf_MortTeam") then {
_class    = "B_MBT_01_arty_F"
};

_mags = [configfile >> "CfgVehicles" >> _class >> "Turrets" >> "MainTurret" >> "magazines"] call ALiVE_fnc_getConfigValue;

private _roundsAvail =[];

     {

        private _he = ["Mo_shells", _x] call BIS_fnc_inString;
        if (!_he) then {
            _he = ["he", _x] call BIS_fnc_inString;
        };

        private _smoke = ["Mo_smoke", _x] call BIS_fnc_inString;
            if (!_smoke) then {
            _smoke = ["smoke", _x] call BIS_fnc_inString;
        };

        private _guided = ["Mo_guided", _x] call BIS_fnc_inString;

        private _cluster = ["Mo_Cluster", _x] call BIS_fnc_inString;

        private _lg = ["Mo_LG", _x] call BIS_fnc_inString;
        if (!_lg) then {
            _lg = ["laser", _x] call BIS_fnc_inString;
        };

        private _mine = ["Mo_mine", _x] call BIS_fnc_inString;

        private _atmine = ["Mo_AT_mine", _x] call BIS_fnc_inString;

        private _rockets = ["rockets", _x] call BIS_fnc_inString;

        private _illum = ["illum", _x] call BIS_fnc_inString;
        if (!_illum) then {
            _illum = ["flare", _x] call BIS_fnc_inString;
        };

             if (_he) then {
                 _roundsAvail =  _roundsAvail + ["HE"];
             };
             if (_smoke) then {
                 _roundsAvail =  _roundsAvail + ["SMOKE"];
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
