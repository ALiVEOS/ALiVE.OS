/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_SpawnIntel.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Creates random intel for you to find inside houses.

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

private ["_intelItems","_selectedItem","_item","_cacheBuildings","_cities","_cityName","_cityPos","_cityRadA","_cityRadB","_cityType","_cityAngle","_targetBuilding","_intelPosition","_m"];

sleep 60;

spawnedIntelItems = [];
publicVariable "spawnedIntelItems";

_intelItems = INS_INTELSPAWNED;
_cities = call INS_fnc_urbanAreas;

{
	_cityName = _x select 0;
	_cityPos = _x select 1;
	_cityRadA = _x select 2;
	_cityRadB = _x select 3;
	_cityType = _x select 4;
	_cityAngle = _x select 5;

	if(_cityRadB > _cityRadA) then {
		_cityRadA = _cityRadB;
	};

	_cacheBuildings = [_cityPos,_cityRadA] call INS_fnc_findBuildings;

	for "_i" from 1 to (paramsArray select 8) step 1 do {
		if(count _cacheBuildings > 0) then {
			_selectedItem = _intelItems call BIS_fnc_selectRandom;
			// Pull the array and select a random building from it.
			_targetBuilding = _cacheBuildings call BIS_fnc_selectRandom;
			// Take the random building from the above result and pass it through gRBP function to get a single cache position
			_intelPosition = [_targetBuilding] call INS_fnc_RandomBuildingPosition;
			_item = createVehicle [_selectedItem, _intelPosition, [], 0, "None"];
			[[_item,"<t color='#FF0000'>Gather Intel</t>"],"INS_fnc_addactionMP", true, true] spawn BIS_fnc_MP;
			// Move the Cache to the above select position
			_item setPos _intelPosition;

			spawnedIntelItems set [count spawnedIntelItems, _item];
			publicVariable "spawnedIntelItems";

			if (ins_debug) then {
				//debug to see where box spawned is if not multiplayer
				_m = createMarker [format ["box%1",random 1000],getposATL _item];
				_m setMarkerShape "ICON";
				_m setMarkerType "mil_dot";
				_m setMarkerColor "ColorGreen";
			};
		};

		Sleep 0.1;
	};
} forEach _cities;