/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_exportCfgVehicles

Description:
	Export list of objects for Community Wiki
	http://community.bistudio.com/wiki/Category:Arma_3:_Assets

Parameters:
	0: STRING - mode
		"screenshots" - create objects one by one and take their screenshot. Works only on "Render" terrain.
		"screenshotsTest" - create objects one by one without taking screen (to verify everything is ok)

	1: ARRAY of SIDEs 0 list of sides. Only objects of these sides will be used
	2: ARRAY of STRINGs - list of CfgPatches classes. Only objects belonging to these addons will be used
	3: ARRAY of STRINGS - list of types to include
	4: BOOL - true to use only AI units (soldiers, vehicles), false to use empty ones

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
    ["_types", [],[[]]],
    ["_allVehicles", true,[true]]
];


if (_patchprefix != "") then {
	private ["_num","_listpatches"];
	_num = count _patchprefix;
	_patches = "((configName _x) select [0, _num]) == _patchprefix" configClasses (configfile >> "cfgpatches");
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

_types = +_types;
{
	_types set [_foreachindex,tolower _x];
} foreach _types;
_allTypes = count _types == 0;

player enablesimulation false;
player hideobject true;

switch tolower _mode do {
	case "json";
	case "config";
	case "screenshots";
	case "screenshotstest": {

		// if !(worldname in ["Render","RenderGreen","RenderBlue"]) exitwith {"Use 'Render White' for capturing screenshots." call bis_fnc_errorMsg;};

		_alt = 100;
		_pos = [3540,100,_alt];
		_object = objnull;
		_cfgAll = configfile >> "cfgvehicles" >> "all";
		_restrictedModels = ["","\A3\Weapons_f\dummyweapon.p3d","\A3\Weapons_f\laserTgt.p3d"];
		_blacklist = [
			"WeaponHolder",
			"LaserTarget"
//			"Bag_Base",
//			"Strategic"
		];
		_capture = _mode == "screenshots";
		_product = productversion select 1;

		_cfgVehicles = (configfile >> "cfgvehicles") call bis_fnc_returnchildren;

		_cam = "camera" camcreate _pos;
		_cam cameraeffect ["internal","back"];
		_cam campreparefocus [-1,-1];
		_cam camcommitprepared 0;
		showcinemaborder false;
		setaperture 47;
		setdate [2035,5,28,9,0];
		0 setfog 0.2;
		if (_mode == "json") then {
			diag_log "{ 'vehicles' : [";
		};
		_ni = 0;
		{
			_class = configname _x;
			_scope = getnumber (_x >> "scope");
			_side = getnumber (_x >> "side");
			_faction = getText (_x >> "faction");
			_disName = getText (_x >> "displayName");
			_unitAddons = unitaddons _class;
			_isAllVehicles = _class iskindof "allvehicles";

			if (
				((_allVehicles && _isAllVehicles) || (!_allVehicles && !_isAllVehicles))
				&&
				_side in _sides
				&&
				(_allPatches || {(tolower _x) in _patches} count _unitAddons > 0 || (_patchprefix != "" && [_class, _patchprefix] call CBA_fnc_find != -1))
				&&
				( _scope > 1 || (_scope == 1 && _class iskindof "Bag_Base") )
				&&
				(_allTypes || {_class iskindof _x} count _types > 0)
			) then {
				_model = gettext (_x >> "model");
				if (!(_model in _restrictedModels) && inheritsfrom _x != _cfgAll && {_class iskindof _x} count _blacklist == 0) then {

					if (_mode == "json") exitWith {
						_newType = str(_unitAddons);
						switch true do {
						    case ([str(_unitAddons), "AirVehicles"] call CBA_fnc_find != -1): {
						    	_newType = "Aircraft";
						    };
						    case ([str(_unitAddons), "Wheeled"] call CBA_fnc_find != -1): {
						    	_newType = "Wheeled";
						    };
						    case ([str(_unitAddons), "Tracked"] call CBA_fnc_find != -1): {
						    	_newType = "Tracked";
						    };
						    case ([str(_unitAddons), "WaterVehicles"] call CBA_fnc_find != -1): {
						    	_newType = "Boats";
						    };
						    case ([str(_unitAddons), "Creatures"] call CBA_fnc_find != -1): {
						    	_newType = "Units";
						    };
						    case ([str(_unitAddons), "Backpacks"] call CBA_fnc_find != -1): {
						    	_newType = "Backpacks";
						    };
						    case ([str(_unitAddons), "AmmoBoxes"] call CBA_fnc_find != -1): {
						    	_newType = "Supplies";
						    };
						    default {
						     	_newType = str(_unitAddons);
						    };
						};
						diag_log format["{'type':'%1',", _newType];
						diag_log format["'side':'%1',", [_side] call ALiVE_fnc_sideNumberToText];
						diag_log format["'faction':'%1',", [(configFile >> "CfgFactionClasses" >> _faction >> "displayName")] call ALiVE_fnc_getConfigValue];
						diag_log format["'class':'%1',", _class];
						diag_log format["'name':'%1'},", _disName];
					};
					[_unitAddons, _side, _class] call bis_fnc_log;
					_ni = _ni + 1;
					if (_mode == "config") exitWith {};

					_object = createvehicle [_class,[0,0,0],[],0,"none"];

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
					if (_class iskindof "man" && !(_class iskindof "animal")) then {

						private "_moves";
						_size = _size * 0.5;
						_targetZ = _size * 0.5;
						_moves = ["amovpercmstpsnonwnondnon","AidlPercMstpSrasWrflDnon_Salute","AidlPercMstpSrasWrflDnon_AI","Acts_A_M01_briefing","AmovPercMstpSlowWrflDnon","AmovPercMstpSlowWrflDnon_Salute","AmovPercMstpSnonWnonDnon_Ease","AmovPercMstpSnonWnonDnon_Salute","AmovPknlMstpSlowWrflDnon","AmovPknlMstpSnonWnonDnon","AadjPknlMstpSrasWrflDleft","Acts_A_M03_briefing"];
						if (primaryWeapon _object != "") then {
							_object switchmove (_moves select (ceil(random (count _moves))-1));
						} else {
							_object switchmove "amovpercmstpsnonwnondnon";
						};

					};
					if (_class iskindof "staticweapon") then {

						_targetZ = -_size * 0.25;
					};
					if (_class iskindof "house") then {

						_size = _size * 0.75;
					};
					if (_class iskindof "Bag_Base") then {
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
						_holder setdir 235;
						_holder setface "kerry";
						_holder switchmove "amovpercmstpsnonwnondnon";
						_holder addBackpack _class;
						_cam campreparefov 0.3;

						_holder enablesimulation false;
						bagholder = _holder;

					};


					if (_class iskindof "Bag_Base") then {
						_campos = [_pos,2.5,90] call bis_fnc_relpos;
						_campos set [2,_alt + 2];
						_cam campreparepos _campos;
						_cam campreparetarget [(_pos select 0),(_pos select 1),_alt + 1.3];
						_cam camcommitprepared 0;
					} else {
						_campos = [_pos,_size * 1.5,135] call bis_fnc_relpos;
						_campos set [2,_alt + _size * 0.5];
						_cam campreparepos _campos;
						_cam campreparetarget (_object modeltoworld [0,0,_targetZ]);
						_cam camcommitprepared 0;
					};

					if (_capture) then {
						sleep 3;

						"scr_cap" callExtension format["exportCfg\%1_CfgVehicles_%2.png",_product,_class];

						sleep 0.01;
					} else {
						sleep 0.1;
					};
					_object setpos [10,10,10];
					deletevehicle _object;
					if (_class iskindof "Bag_Base") then {
						deleteVehicle bagholder;
					};
				};
			};
		} foreach _cfgVehicles;
		if (_mode == "json") then {
			diag_log "]}";
		};
		_ni call bis_fnc_log;
		_cam cameraeffect ["terminate","back"];
		camdestroy _cam;
		setaperture -1;
	};
};

player enablesimulation true;
player hideobject false;

true