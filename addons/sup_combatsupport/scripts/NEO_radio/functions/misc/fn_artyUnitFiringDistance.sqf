private ["_min", "_max", "_result"];
_min = 0;
_max = 0;
_result = 0;

_class = _this;

if(_class isEqualTo "BUS_MotInf_MortTeam") then {
_class	= "B_MBT_01_arty_F"
};

_weapon = [configfile >> "CfgVehicles" >> _class >> "Turrets" >> "MainTurret" >> "weapons"] call ALiVE_fnc_getConfigValue;

_min = [configfile >> "CfgWeapons" >> "mortar_82mm" >> "minRange"] call ALiVE_fnc_getConfigValue;
_max = [configfile >> "CfgWeapons" >> "mortar_82mm" >> "maxRange"] call ALiVE_fnc_getConfigValue;


_result = [_min, _max];

_result;
