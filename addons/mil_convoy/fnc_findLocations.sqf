#include <\x\alive\addons\mil_convoy\script_component.hpp>

fnc_findLocations = {
_types = _this;
_locations = nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"),_types,30000];
 
_collection = [];
{
   _pos = position _x;
   _size = size _x;
                                           
   if (_size select 0 > _size select 1) then {_size = _size select 0} else {_size = _size select 1};
      _collection set [count _collection,[_pos,_size]];
} foreach _locations;
_collection;
};
_locs = ["NameCityCapital","NameCity","NameVillage","NameLocal","Hill"] call fnc_findLocations;