#include <\x\alive\addons\mil_convoy\script_component.hpp>

fnc_findLocations = {
private _types = _this;
private _locations = nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"),_types,30000];

private _collection = [];
{
   private _pos = position _x;
   private _size = size _x;

   if (_size select 0 > _size select 1) then {_size = _size select 0} else {_size = _size select 1};
      _collection pushback [_pos,_size];
} foreach _locations;
_collection;
};
private _locs = ["NameCityCapital","NameCity","NameVillage","NameLocal","Hill"] call fnc_findLocations;