/*
	Author: Karel Moricky, edited by Tup

	Description:
	Export object composition for use in CfgGroups. The result will be copied to clipboard. Create your composition in the editor. Place a man from the faction you wish to associate the composition with (civilian if none) in the center of the objects. Press play and run the command from the debug console. Once run, paste the clipboard text into a config file.

	Parameter(s):
		0: STRING - Type - airports, camps, checkpointsbarricades, constructionsupplies, communications, crashsites, fieldhq, fort, fuel, heliports, hq, marine, medical, outposts, power, supports, supplies
		1: STRING - Size - Small (15m radius), Medium (30m radius), Large (60m radius)
		2: STRING - Class - Some unique identifier
		3: STRING - Name - What will appear in the UI (Faction will be added automatically)

	Returns:
	Copies CfgGroups entry to clipboard

	Example:
	["Camps", "Small", "Camp", "My Camp"] call ALiVE_fnc_exportCfgComposition
*/

private ["_center","_objects","_dir","_logic","_text","_br","_type","_size","_class","_name","_radius"];
_type = _this param [0,"Camp"];
_size = _this param [1,"Small"];
_class = _this param [2,"SmallCamp"];
_name = _this param [3,"Small Camp"];

diag_log "Running ALiVE Composition export";

switch (_size) do {
    case "Small": {
    	_radius = 15;
    };
    case "Medium": {
    	_radius = 30;
    };
    case "Large": {
    	_radius = 60;
    };
    default {
     	_radius = 30;
    };
};

private _faction = if(str(side player) == "CIV") then {""} else { faction player };

_objects = player nearObjects _radius;

_objects = _objects - [player];

diag_log format["Found %1 objects for export.", str(count _objects)];

if (count _objects == 0) exitWith {
	diag_log "No objects found";
};

_center = (_objects select 0) call bis_fnc_position;

_dir = direction (_objects select 0);

_logic = createagent ["Logic",_center,[],0,"none"];
_logic setpos _center;
_logic setdir _dir;

_text = "";

_br = tostring [10];

if (_faction != "") then {
	_text = _text + format["        class %1%2_%3_%4 %5        {%5", _type, _size, _class, _faction, _br];
	_text = _text + format["            name = ""%1%2"";%3", _name, format[" [%1]",faction player], _br];

	private _icon = getText(configFile >> "CfgFactionClasses" >> faction player >> "flag");
	_text = _text + format["            icon = '%1';%2", _icon, _br];
} else {
	_text = _text + format["        class %1%2_%3 %4        {%4", _type, _size, _class, _br];
	_text = _text + format["            name = ""%1"";%2", _name, _br];
};

_text = _text + format["            size = 8;%1", _br];
{
	private ["_objPos","_objSide","_objRank"];
	_objPos = _logic worldtomodel position _x;
	_objSide = 8;
	_objRank = "";
	if !(isnull group _x) then {
		_objSide = (_x call bis_fnc_objectside) call bis_fnc_sideID;
		_objRank = rank _x;
	};

	_objText = format [
		"            class Object%1	{side = %2; vehicle = ""%3""; rank = ""%4""; position[] = {%5,%6,%7}; dir = %8;};",
		_foreachindex,
		_objSide,
		typeof _x,
		_objRank,
		(_objPos select 0),
		(_objPos select 1),
		getposatl _x select 2,
		(direction _x - _dir) % 360
	];
	_text = _text + _objText + _br;
} foreach _objects;

_text = _text + "        };";

deletevehicle _logic;
copytoclipboard _text;
diag_log _text;