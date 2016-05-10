/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_exportCfgVehicleWeapons

Description:
	Export list of objects for Community Wiki
	http://community.bistudio.com/wiki/Category:Arma_3:_Assets

Parameters:
	0: STRING - mode
		"screenshots" - create objects one by one and take their screenshot. Works only on "Render" terrain.
		"screenshotsTest" - create objects one by one without taking screen (to verify everything is ok)

	1: ARRAY of SIDEs 0 list of sides. Only objects of these sides will be used
	2: ARRAY of STRINGs - list of CfgPatches classes. Only objects belonging to these addons will be used
	3: BOOL - true to use only AI units (soldiers, vehicles), false to use empty ones

Returns:
	BOOL

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Karel Moricky and edited by TUP for War Room
---------------------------------------------------------------------------- */

params [
    ["_mode", "config",[""]],
    ["_sides", [0,1,2,3],[[]]],
    ["_patchprefix", "",[""]],
    ["_patches", [],[[]]],
    ["_allVehicles", true,[true]]
];

if (_patchprefix != "") then {
	private ["_num","_listpatches"];
	_num = count _patchprefix;
	_patches = "tolower(((configName _x) select [0, _num])) == tolower(_patchprefix)" configClasses (configfile >> "cfgpatches");
	{
		_patches set [_foreachindex,tolower (configName _x)];
	} foreach _patches;
} else {
	if (count _patches > 0) then {
		_patches = +_patches;
		{
			_patches set [_foreachindex,tolower _x];
		} foreach _patches;
	};
};

_allPatches = count _patches == 0;



_sides = +_sides;
{
	if (typename _x == typename sideunknown) then {_sides set [_foreachindex,_x call bis_fnc_sideid];};
} foreach _sides;
if (count _sides == 0) then {_sides = [0,1,2,3,4];};

player enablesimulation false;
player hideobject true;


_funcGetTurretsWeapons = {
     private ["_result", "_getAnyMagazines", "_findRecurse", "_class"];
     _result = [];
     _getAnyMagazines = {
         private ["_weapon", "_mags"];
         _weapon = configFile >> "CfgWeapons" >> _this;
         _mags = [];
         {
             _mags = _mags + getArray (
                 (if (_x == "this") then { _weapon } else { _weapon >> _x }) >> "magazines"
             )
         } foreach getArray (_weapon >> "muzzles");
         _mags
     };
     _findRecurse = {
         private ["_root", "_class", "_path", "_currentPath"];
         _root = (_this select 0);
         _path = +(_this select 1);
         for "_i" from 0 to count _root -1 do {
             _class = _root select _i;
             if (isClass _class) then {
                 _currentPath = _path + [_i];
                 {
                     _result set [count _result, [_x, _x call _getAnyMagazines, _currentPath, str _class]];
                 } foreach getArray (_class >> "weapons");
                 _class = _class >> "turrets";
                 if (isClass _class) then {
                     [_class, _currentPath] call _findRecurse;
                 };
             };
         };
     };
     _class = (
         configFile >> "CfgVehicles" >> (
             switch (typeName _this) do {
                 case "STRING" : {_this};
                 case "OBJECT" : {typeOf _this};
                 default {nil}
             }
         ) >> "turrets"
     );
     [_class, []] call _findRecurse;
     _result;
 };

switch tolower _mode do {
	case "screenshots";
	case "screenshotstest": {

		if !(worldname in ["Render","RenderGreen","RenderBlue"]) exitwith {"Use 'Render White' for capturing screenshots." call bis_fnc_errorMsg;};

		_alt = 100;
		_pos = [3540,100,_alt];
		_object = objnull;
		_cfgAll = configfile >> "cfgvehicles" >> "all";
		_restrictedModels = ["","\A3\Weapons_f\dummyweapon.p3d","\A3\Weapons_f\laserTgt.p3d"];
		_blacklist = [
			"WeaponHolder",
			"LaserTarget",
			"Bag_Base",
			"Man",
			"Animal",
			"House"
		];
		_capture = _mode == "screenshots";
		_product = productversion select 1;

		_cfgVehicles = (configfile >> "cfgvehicles") call bis_fnc_returnchildren;

		_cam = "camera" camcreate _pos;
		_cam cameraeffect ["internal","back"];
		_cam campreparefocus [-1,-1];
		_cam camcommitprepared 0;
		showcinemaborder false;
		setaperture 25;
		setdate [2035,5,28,10,0];
		0 setfog 0.2;

		_n = 0;
		{
			_class = configname _x;
			_scope = getnumber (_x >> "scope");
			_side = getnumber (_x >> "side");
			_unitAddons = unitaddons _class;
			_isAllVehicles = _class iskindof "allvehicles";

			if (
				((_allVehicles && _isAllVehicles) || (!_allVehicles && !_isAllVehicles))
				&&
				_side in _sides
				&&
				(_allPatches || {(tolower _x) in _patches} count _unitAddons > 0 || (_patchprefix != "" && [tolower(_class), tolower(_patchprefix)] call CBA_fnc_find != -1))
				&&
				_scope > 1
			) then {
				_model = gettext (_x >> "model");
				if (!(_model in _restrictedModels) && inheritsfrom _x != _cfgAll && {_class iskindof _x} count _blacklist == 0) then {
					_object = createvehicle [_class,_pos,[],0,"none"];
					if (_class iskindof "allvehicles") then {_object setdir 90;} else {_object setdir 270;};
					//_object setdir 90;
					_object setpos _pos;
					_object switchmove "amovpercmstpsnonwnondnon";
					_object enablesimulation false;

					_size = (sizeof _class) max 0.1;
					_targetZ = 0;
					if (_class iskindof "allvehicles") then {
						_size = _size * 0.5;
					};
					if (_class iskindof "staticweapon") then {
						_targetZ = -_size * 0.25;
					};
					_campos = _pos getPos [_size * 1.5,135];
					_campos set [2,_alt + _size * 0.5];

					_cam campreparepos _campos;
					_cam campreparetarget (_object modeltoworld [0,0,_targetZ]);
					_cam camcommitprepared 0;

					private "_vehicleWeapons";
					_vehicleWeapons = _class call _funcGetTurretsWeapons;
					[_class,_vehicleWeapons] call bis_fnc_log;
					if (_capture) then {
						sleep 1;
						{
							"scr_cap" callExtension format["exportCfg\%1_CfgWeapons_%2.png",_product,_x select 0];
						} foreach _vehicleWeapons;
						sleep 0.01;
					} else {
						sleep 0.1;
					};
					_n = _n + 1;
					_object setpos [10,10,10];
					deletevehicle _object;

					[_class,_size] call bis_fnc_log;
				};
			};
		} foreach _cfgVehicles;
		_n call bis_fnc_log;

		_cam cameraeffect ["terminate","back"];
		camdestroy _cam;
		setaperture -1;
	};
};

player enablesimulation true;
player hideobject false;

true