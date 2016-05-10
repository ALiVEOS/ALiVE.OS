#include <\x\alive\addons\mil_ied\script_component.hpp>
SCRIPT(placeIED);

// Find suitable spot for IED
// Pass location and booleans to look for roads, objects, entrances
// Returns an array of position s
private ["_addroads","_addobjects","_addentrances","_goodspots","_location","_size"];

_location = _this select 0;
_addroads = _this select 1;
_addobjects = _this select 2;
_addentrances = _this select 3;
_size = _this select 4;

_goodspots = [];

// Look for objects
If (_addobjects) then {
	private ["_spottype"];
	// broken fences, low walls,  garbage, garbage containers, gates, rubble
	_spottype = ["Land_JunkPile_F","Land_GarbageContainer_closed_F","Land_GarbageBags_F","Land_Tyres_F","Land_GarbagePallet_F","Land_Pallets_F","Land_Ancient_Wall_8m_F","Land_City_8mD_F","Land_City2_8mD_F","Land_Wreck_HMMWV_F","Land_Wreck_Hunter_F","Land_Mil_WallBig_Gate_F","Land_Stone_Gate_F","Land_Mil_WiredFenceD_F","Land_Net_Fence_Gate_F","Land_Stone_8mD_F","Land_Wired_Fence_8mD_F","Land_Wall_IndCnc_4_D_F","Land_Wall_IndCnc_End_2_F","Land_Net_FenceD_8m_F","Land_New_WiredFence_10m_Dam_F"];
	{
		_goodspots set [count _goodspots, getposATL  _x];
	} foreach nearestobjects [_location,_spottype,_size];
};

// Look for building entrances
If (_addentrances) then {
	// Get first building postion (entrance) for each building within range
	{
		_goodspots set [count _goodspots, getposATL  _x];
	} foreach (nearestobjects [_location ,["House"],_size]);
};

// Look for roads
If (_addroads) then {
	// Get raods within range
	{
		_goodspots set [count _goodspots, getposATL  _x];
	} foreach (_location nearRoads _size);
};

_goodspots
