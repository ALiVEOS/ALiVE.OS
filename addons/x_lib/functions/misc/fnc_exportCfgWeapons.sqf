/* ----------------------------------------------------------------------------
Function:

Description:
	Export list of weapons for Community Wiki
	http://community.bistudio.com/wiki/Category:Arma_3:_Assets

Parameters:
	0: STRING - mode
		"screenshots" - create items one by one and take their screenshot. Works only on "Render" terrain.
		"screenshotsTest" - create items one by one without taking screen (to verify everything is ok)
	1: STRING - CfgPatches Prefix i.e. CUP
	2: ARRAY of STRINGs - list of CfgPatches classes. Only weapons belonging to these addons will be used
	3: ARRAY of STRINGS - list of types of weapons to include
	4: BOOL - true if mod does not have CfgPatches entry or is incomplete entry

Returns:
	BOOL

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Karel Moricky update by Tup for ALiVE War Room purposes
---------------------------------------------------------------------------- */

params [
    ["_mode", "Weapon",[""]],
    ["_patchprefix", "",[""]],
    ["_patches", [],[[]]],
    ["_types", [],[[]]],
    ["_noCfgPatches", false,[false]]
];

player enablesimulation false;
player hideobject true;

_mode = tolower _mode;
_screenshots = _mode in ["screenshots","screenshotstest"];
if (_screenshots && !(worldname in ["Render","RenderGreen","RenderBlue"])) exitwith {"Use 'Render White' for capturing screenshots." call bis_fnc_errorMsg;};
_capture = _mode == "screenshots";
if (_screenshots) then {_mode = "Weapon";};

_mode = tolower _mode;
_patchWeapons = [];
_allPatches = true;
if (_patchprefix != "") then {
	private "_num";
	_num = count _patchprefix;
	_allPatches = false;
	_patches = "true" configClasses (configfile >> "cfgpatches");
	{
		if (tolower((configName _x) select [0, _num]) == tolower(_patchprefix)) then {
			_patchWeapons = _patchWeapons + getarray (configfile >> "cfgpatches" >> configName _x >> "weapons");
		};
	} foreach _patches;
} else {
	if (count _patches > 0) then {
		_allPatches = false;
		{
			_patchWeapons = _patchWeapons + getarray (configfile >> "cfgpatches" >> _x >> "weapons");
		} foreach _patches;
	};
};

_types = +_types;
{
	_types set [_foreachindex,tolower _x];
} foreach _types;
_allTypes = count _types == 0;

_br = tostring [13,10];
_product = productversion select 0;
_productShort = productversion select 1;
_text = "";
_cam = objnull;
_holder = objnull;

_alt = 100;
_pos = [3540,100,_alt];
_player = player;
_weaponObjects = [];

_cfgWeapons = (configfile >> "cfgweapons") call bis_fnc_returnchildren;
_cfgWeaponsCount = count _cfgWeapons;

// Handle mods that don't include weapons in CfgPatches...
if (_patchprefix != "" && (_noCfgPatches || count _patchWeapons == 0)) then {
	_patchWeapons = [];
	{
		if ([tolower(configName _x), tolower(_patchprefix)] call CBA_fnc_find != -1) then {
			_patchWeapons set [count _patchWeapons, configName _x];
		};
	} foreach _cfgWeapons;
};

if (_screenshots) then {
	_cam = "camera" camcreate _pos;
	_cam cameraeffect ["internal","back"];
	_cam campreparefocus [-1,-1];
	_cam camcommitprepared 0;
	showcinemaborder false;
	setaperture 47;
	setdate [2035,5,28,9,0];
	0 setfog 0.2;
};
if (_mode == "json") then {
	diag_log "{ 'weapons' : [";
};
{

	_cfg = _x;
	_class = configname _cfg;
	_scope = getnumber (_cfg >> "scope");
	_model = gettext (_cfg >> "model");
	_disName = getText (_cfg >> "displayName");
	_weaponAddons = [];
	_itemTypeArray = _class call bis_fnc_itemType;
	_itemCategory = _itemTypeArray select 0;
	_itemType = _itemTypeArray select 1;
	_isAllVehicles = _class iskindof "allvehicles";

	if (

		(_allPatches || {_class == _x} count _patchWeapons > 0)
		&&
		(_allTypes || (tolower _itemType) in _types)
		&&
		_scope > 0
		//&&
		//(_model != "")
	) then {
		if (_mode == "json") exitWith {
			_newType = _itemType;
			switch (_itemType) do {
			    case "AssaultRifle": {
			    	_newType = "Assault Rifles";
			    };
			    case "SniperRifle": {
			    	_newType = "Sniper Rifles";
			    };
			    case "MachineGun": {
			    	_newType = "Machine Guns";
			    };
			    case "Handgun": {
			    	_newType = "Handguns";
			    };
			    case "AccessoryPointer": {
			    	_newType = "Items";
			    };
			    case "MissileLauncher";
			    case "RocketLauncher": {
			    	_newType = "Launchers";
			    };
			    case "AccessoryMuzzle";
			    case "AccessorySights": {
			    	_newType = "Optics / Suppressors";
			    };
			    case "Vest": {
			    	_newType = "Vests";
			    };
			    case "Uniform": {
			    	_newType = "Uniforms";
			    };
			    default {
			     	_newType = _itemType;
			    };
			};
			diag_log format["{'type':'%1',", _newType];
			diag_log format["'class':'%1',", _class];
			diag_log format["'name':'%1'},", _disName];
		};
		[_itemType,_class] call bis_fnc_log;
		if (_screenshots) then {
			_holder = switch _itemType do {
				case "NVGoggles";
				case "Headgears": {
					_holder = createvehicle ["groundweaponholder",_pos,[],0,"none"];
					_holder setpos _pos;
					_holder addweaponcargo [_class,1];
					_holder setvectordirandup [[0,0,1],[0,-1,0]];

					_campos = [_pos,1.75,60] call bis_fnc_relpos;
					_campos set [2,_alt + 1.3];
					_cam campreparepos _campos;
					_cam campreparefov 0.4;
					_cam campreparetarget [(_pos select 0),(_pos select 1) + 0.5,_alt + 1.3];
					_cam camcommitprepared 0;
					_holder
				};
				case "Vestx": {
					_holder = createvehicle ["groundweaponholder",_pos,[],0,"none"];
					_holder setpos _pos;
					_holder addweaponcargo [_class,1];
					_holder setvectordirandup [[0.00173726,0.000167279,0.999998],[-0.995395,-0.0958456,0.00177588]];//[[0,0,1],[-1,0,0]];

					_campos = [_pos,2,90] call bis_fnc_relpos;
					_campos set [2,_alt + 1];
					_cam campreparepos _campos;
					_cam campreparefov 0.7;
					_cam campreparetarget [(_pos select 0),(_pos select 1)-0.3,_alt + 0.6];
					_cam camcommitprepared 0;
					_holder
				};
				case "Headgear";
				case "Vest";
				case "Uniform": {
					_holder = createagent [typeof player,_pos,[],0,"none"];
					removeallweapons _holder;
					removeallitems _holder;
					removeuniform _holder;
					removevest _holder;
					removeheadgear _holder;
					removegoggles _holder;
					_items = assigneditems _holder;
					{_holder unassignitem _x} foreach _items;
					_holder switchcamera "internal";
					_holder setpos _pos;
					_holder setdir 90;
					_holder setface "kerry";
					_holder switchmove "amovpercmstpsnonwnondnon";
					_offset = switch _itemType do {
						case "Headgear": {
							_holder addheadgear _class;
							_cam campreparefov 0.125;
							setShadowDistance 0;
							 0.8125
						};
						case "Vest": {
							_holder addvest _class;
							_cam campreparefov 0.3;
							 0.3
						};
						case "Uniform": {
							_holder adduniform _class;
							_cam campreparefov 0.6;
							 0
						};
					};
					_holder enablesimulation false;

					_campos = [_pos,2.5,90] call bis_fnc_relpos;
					_campos set [2,_alt + 1];
					_cam campreparepos _campos;
					_cam campreparetarget [(_pos select 0),(_pos select 1),_alt + 0.85 + _offset];
					_cam camcommitprepared 0;
					_holder
				};
				case "AccessoryMuzzle";
				case "AccessoryPointer";
				case "AccessorySights": {
						_holder = createvehicle ["groundweaponholder",_pos,[],0,"none"];
						_holder setpos _pos;
						_holder addweaponcargo [_class,1];
						_holder setvectordirandup [[0,0,1],[1,0,0]];

						_fov = if (_itemType == "AccessoryMuzzle") then {0.3} else {0.2};
						_campos = [_pos,0.5,90] call bis_fnc_relpos;
						_campos set [2,_alt + 0.5];
						_cam campreparepos _campos;
						_cam campreparefov _fov;
						_cam campreparetarget [(_pos select 0),(_pos select 1),_alt + 0.57];
						_cam camcommitprepared 0;
						_holder
				};
				case "UnknownWeapon": {
					// Get grenades
					if (_class == "Throw") then {
						private "_muzzles";
						_muzzles = getarray (configfile >> "cfgWeapons" >> _class >> "muzzles");
						{
							private ["_grenades","_muzzle"];
							_muzzle = _x;
							_muzzle call bis_fnc_log;
							_grenades = getarray (configfile >> "cfgWeapons" >> _class >> _x >> "magazines");
							_grenades call bis_fnc_log;
							{
								_x call bis_fnc_log;
								private ["_holder","_campos"];
								_holder = createvehicle ["groundweaponholder",_pos,[],0,"none"];
								_holder setpos [(_pos select 0),(_pos select 1)+0.55,_alt+0.15];
								_holder addmagazinecargo [_x,1];
								_holder setvectordirandup [[0.707107,0,0.707107],[0.408248,0.816497,-0.408248]];

								_campos = [_pos,0.5*2,90] call bis_fnc_relpos;
								_campos set [2,_alt + 0.5];
								_cam campreparepos _campos;
								_cam campreparefov 0.2;
								_cam campreparetarget [(_pos select 0),(_pos select 1),_alt + 1];
								_cam camcommitprepared 0;
								if (_capture) then {
									sleep 1;

										"scr_cap" callExtension format["exportCfg\%1_CfgWeapons_%2.png",_productShort,_muzzle];

									sleep 0.01;
								} else {
									_x call bis_fnc_log;
									sleep 0.1;
								};
								selectplayer _player;
								_holder setpos [10,10,10];
								deletevehicle _holder;
								setShadowDistance -1;
							} foreach _grenades;
						} foreach _muzzles;
					};
				};

				default {
					if (_itemCategory == "Item") then {
						_holder = createvehicle ["groundweaponholder",_pos,[],0,"none"];
						_holder setpos [(_pos select 0),(_pos select 1)+0.55,_alt+0.15];
						_holder addweaponcargo [_class,1];
						_holder setvectordirandup [[0.707107,0,0.707107],[0.408248,0.816497,-0.408248]];

						_campos = [_pos,0.5*2,90] call bis_fnc_relpos;
						_campos set [2,_alt + 0.5];
						_cam campreparepos _campos;
						_cam campreparefov 0.4;
						_cam campreparetarget [(_pos select 0),(_pos select 1),_alt + 1];
						_cam camcommitprepared 0;
						_holder
					} else {

						_holder = createvehicle ["groundweaponholder",_pos,[],0,"none"];
						_holder setpos _pos;
						_holder addweaponcargo [_class,1];
						_holder setvectordirandup [[0,0,1],[1,0,0]];

						_fov = if (_itemType == "Handgun") then {0.3} else {0.7};
						_campos = [_pos,0.5,90] call bis_fnc_relpos;
						_campos set [2,_alt + 0.5];
						_cam campreparepos _campos;
						_cam campreparefov _fov;
						_cam campreparetarget [(_pos select 0),(_pos select 1),_alt + 0.57];
						_cam camcommitprepared 0;
						_holder
					};
				};
			};
			if (_capture && _itemType != "UnknownWeapon") then {
				sleep 1;

					"scr_cap" callExtension format["exportCfg\%1_CfgWeapons_%2.png",_productShort,_class];

				sleep 0.01;
			} else {
				sleep 0.1;
			};

			selectplayer _player;
			if (_itemType != "UnknownWeapon") then {
				_holder setpos [10,10,10];
				deletevehicle _holder;
			};
			setShadowDistance -1;
		};
	} else {
		// [_itemType,_class] call bis_fnc_log;
	};

	// progressloadingscreen (_foreachindex / _cfgWeaponsCount);
} foreach _cfgWeapons;
if (_mode == "json") then {
	diag_log "]}";
};
if (_screenshots) then {
	_cam cameraeffect ["terminate","back"];
	camdestroy _cam;
	setaperture -1;
};

player enablesimulation true;
player hideobject false;

true