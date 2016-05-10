#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getObjectsByType);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getObjectsByType

Description:
Returns objects by their P3D name for the entire map

Parameters:
Array - Partial P3D type names to search for across the entire map

Returns:
Array - List of all objects across the map matching the types specified

Examples:
(begin example)
// get array of id's and positions from object data
_obj_array = [
	"vez.p3d",
	"barrack",
	"mil_",
	"lhd_",
	"ss_hangar",
	"runway",
	"heli_h_army",
	"dragonteeth"
] call ALIVE_fnc_getObjectsByType;
(end)

See Also:
- <ALIVE_fnc_getNearestObjectInArray>

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_types","_err","_worldName","_file","_raw_objects","_object_hash","_expanded","_data_array","_obj_array"];
_types = _this;
_err = "types provided not valid";
ASSERT_DEFINED("_types",_err);
ASSERT_TRUE(typeName _types == "ARRAY", _err);

if(isNil "wrp_objects") then {
	// read raw object data
	_worldName = toLower(worldName);
	_file = format["x\alive\addons\fnc_strategic\indexes\objects.%1.sqf", _worldName];
	call compile preprocessFileLineNumbers _file;
	format["Reading raw object data from file - %1 objects", count wrp_objects] call ALIVE_fnc_logger;

	/*
	Removed due to index parser
	{
		if([_x select 0, "\plants"] call CBA_fnc_find != -1) then {
			wrp_objects set [_forEachIndex, -1];
		} else {
			if([_x select 0, "\rocks"] call CBA_fnc_find != -1) then {
				wrp_objects set [_forEachIndex, -1];
			} else {
				if([_x select 0, "\pond"] call CBA_fnc_find != -1) then {
					wrp_objects set [_forEachIndex, -1];
				};
			};
		};
	} forEach wrp_objects;

	wrp_objects = wrp_objects - [-1];
	format["Removed plants, rocks and pond objects - %1 objects", count wrp_objects] call ALIVE_fnc_logger;
	*/
};
_raw_objects = wrp_objects;
_err = "raw object information not read correctly from file";
ASSERT_DEFINED("_raw_objects",_err);
ASSERT_TRUE(typeName _raw_objects == "ARRAY", _err);

_object_hash = [_raw_objects] call ALIVE_fnc_hashCreate;
ASSERT_DEFINED("_object_hash",_err);
ASSERT_TRUE(typeName _object_hash == "ARRAY", "_object_hash invalid");

_expanded = [];
{
	private["_p3dname"];
	_p3dname = _x;
	{
	    //["--- OBJ: %1 SEARCH: %2",_x,_p3dname] call ALIVE_fnc_dump;
		if([_p3dname, _x] call CBA_fnc_find != -1) then {
		    //["FOUND OBJECT: %1 WITH: %2",_x,_p3dname] call ALIVE_fnc_dump;
			_expanded pushback _p3dname;
		};
	} forEach _types;
} forEach (_object_hash select 1);


_data_array = [];
{
	private["_name","_data"];
	_name = _x;
	_data = [_object_hash, _name] call ALIVE_fnc_hashGet;
	if(!isNil "_data") then {
		_data_array = _data_array + _data;
	};
} forEach _expanded;
ASSERT_DEFINED("_data_array",_err);
ASSERT_TRUE(typeName _data_array == "ARRAY", "_data_array invalid");

// create an array of objects from positions
_obj_array = [];
{
	private["_id","_pos"];
	_id = _x select 0;
	_pos = _x select 1;
	//["SET OBJECT: %1",_id] call ALIVE_fnc_dump;
	_obj_array pushback (_pos nearestObject _id);
} forEach _data_array;
ASSERT_DEFINED("_obj_array",_err);
ASSERT_TRUE(typeName _obj_array == "ARRAY", "_obj_array invalid");

_obj_array;
