#include <\x\alive\addons\sys_playertags\script_component.hpp>
private ['_lineCount', '_tmpText', '_type', '_vehicle', '_playerVehicle'];

_obj = _this select 0;
_objDist = _this select 1;
_scrPos = _this select 2;
_objDistMod = _this select 3;
_absolutePos = _this select 4;
_lineCount = 0;
_tmpText = "";
_type = vehicle _obj;
_ownGroup = group player;

func_getRank = {
	private["_rank","_rankid"];
	_rankid = _this;
	_rank = "";
	switch (_rankid) do {
		case 0 : {_rank = "Private";};
		case 1 : {_rank = "Corporal";};
		case 2 : {_rank = "Sergeant";};
		case 3 : {_rank = "Lieutenant";};
		case 4 : {_rank = "Captain";};
		case 5 : {_rank = "Major";};
		case 6 : {_rank = "Colonel";};
		default  {};
	};
	_rank
};

	_tagsInVehicle = true;
	if (_obj == vehicle player && !playertags_invehicle) then { _tagsInVehicle = false; };
		
		if (_type isKindOf "Car" ||
				_type isKindOf "StaticWeapon" ||
				_type isKindOf "Plane" ||
				_type isKindOf "Helicopter" ||
				_type isKindOf "Tank") then {
					if (_tagsInVehicle) then {
								["ALIVE Player Tags - _tagsInVehicle: %1", _tagsInVehicle] call ALIVE_fnc_dump;
							_vehicle = _obj;
							_objTypeStr = format["%1", (typeOf _vehicle)];
							_name = getText(configFile >> "cfgVehicles" >> _objTypeStr >> "displayName");
							_tmpText = _tmpText + format["%1:<br/>", _name];
							_lineCount = 1;
							{
								if (!(isNull _x) && alive _x) then {
									if (gunner _vehicle == _x) then {
										_tmpText = _tmpText + "G: ";
									};
									if (driver _vehicle == _x) then {
										_tmpText = _tmpText + "D: ";
									};
									if (commander _vehicle == _x) then {
										_tmpText = _tmpText + "C: ";
									};
									_nameColor = playertags_namecolour;
									_groupColor = playertags_groupcolour;
						
									if (_x == leader group _x) then {
										_nameColor = playertags_thisgroupleadernamecolour;
									};
									if (group _x == _ownGroup) then {
										_groupColor = playertags_thisgroupcolour;
									};
									_rank = '';
									if (playertags_rank) then {
										_rank = (rankId _x) call func_getRank;
									};
									_thisgroup = '';
									if (playertags_group) then {
										_thisgroup = group _x;
									};
									_tmpText = _tmpText + format["<t color='%1'>%5 %2</t><br/>", _nameColor, name _x, _groupColor, _thisgroup, _rank];
									_lineCount = _lineCount + 1;
								}
							} foreach (crew _vehicle);
					}
		}
		else {
			_man = _obj;
			_group = group _man;
			_nameColor = playertags_namecolour;
			_groupColor = playertags_groupcolour;
		
		
			if (alive _man) then
			{
				if (_man == leader _group) then {
					_nameColor = playertags_thisgroupleadernamecolour;
				};
				if (_group == _ownGroup) then {
					_groupColor = playertags_thisgroupcolour;
				};
				_rank = '';
				if (playertags_rank) then {
				_rank = (rankId _man) call func_getRank;
				};
				_thisgroup = '';
				if (playertags_group) then {
						_thisgroup = group _man;
				};
				_tmpText = _tmpText + format["<t color='%1'>%5 %2</t> <br/><t color='%3'>%4</t>", _nameColor, name _man, _groupColor, _thisgroup, _rank];
				_lineCount = 1;
			};
		};
	
foundUnitsText set [foundUnitsCount, [_tmpText, _scrPos, _lineCount, _objDistMod, _absolutePos]];
foundUnitsCount = foundUnitsCount + 1;


