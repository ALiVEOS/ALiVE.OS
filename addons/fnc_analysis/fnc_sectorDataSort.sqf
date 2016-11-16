#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorDataSort);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorDataSort

Description:
Sorts the various sector data keys

Parameters:
Hash - Sector data hash
String - Data key to sort
Array - sort args

Returns:
Sorted data

Examples:
(begin example)
// sort elevation data
_sortedElevationData = [_sectorData, "elevation", []] call ALIVE_fnc_sectorDataSort;

// sort best places forest positions
_sortedForestPositions = [_sectorData, "bestPlaces", [getPos player,"forest"]] call ALIVE_fnc_sectorDataSort;

// sort flat empty positions
_sortedFlatEmptyPositions = [_sectorData, "flatEmpty", [getPos player]] call ALIVE_fnc_sectorDataSort;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params ["_sectorData","_key","_args"];

private _err = format["sector data sort requires an hash - %1",_sectorData];
ASSERT_TRUE(_sectorData isEqualType [], _err);
_err = format["sector data sort a string key - %1",_key];
ASSERT_TRUE(_key isEqualType "", _err);
_err = format["sector data sort a args array - %1",_args];
ASSERT_TRUE(_args isEqualType [], _err);


switch (_key) do {

    case "flatEmpty": {

        private _position = _args select 0;
        private _order = if(count _args > 1) then {_args select 1} else {"ASCEND"};

        private _data = [_sectorData, _key] call ALIVE_fnc_hashGet;
        private _sortedData = [_data,[],{_position distance _x},_order] call ALiVE_fnc_SortBy;

        _sortedData

    };

    case "elevationLand": {

        private _order = if(count _args > 0) then {_args select 0} else {"ASCEND"};

        private _data = [_sectorData, "elevationSamplesLand"] call ALIVE_fnc_hashGet;
        private _sortedData = [_data,[],{_x select 1},_order] call ALiVE_fnc_SortBy;

        _sortedData

    };

    case "elevationSea": {

        private _order = if(count _args > 0) then {_args select 0} else {"ASCEND"};

        private _data = [_sectorData, "elevationSamplesSea"] call ALIVE_fnc_hashGet;
        private _sortedData = [_data,[],{_x select 1},_order] call ALiVE_fnc_SortBy;

        _sortedData

    };

    case "terrain": {

        _args params [
            "_position",
            "_terrainKey",
            ["_order", "ASCEND"]
        ];

        private _data = [_sectorData, "terrainSamples"] call ALIVE_fnc_hashGet;
        private _terrainData = [_data, _terrainKey] call ALIVE_fnc_hashGet;
        private _sortedData = [_terrainData,[],{_position distance _x},_order] call ALiVE_fnc_SortBy;

        _sortedData

    };

    case "roads": {

        _args params [
            "_position",
            "_roadKey",
            ["_order", "ASCEND"]
        ];

        private _data = [_sectorData, _key] call ALIVE_fnc_hashGet;
        private _roadData = [_data, _roadKey] call ALIVE_fnc_hashGet;
        private _sortedData = [_roadData,[],{_position distance (_x select 0)},_order] call ALiVE_fnc_SortBy;

        _sortedData

    };

    case "bestPlaces": {

        _args params [
            "_position",
            "_placeKey",
            ["_order", "ASCEND"]
        ];

        private _data = [_sectorData, _key] call ALIVE_fnc_hashGet;
        private _placeData = [_data, _placeKey] call ALIVE_fnc_hashGet;
        private _sortedData = [_placeData,[],{_position distance _x},_order] call ALiVE_fnc_SortBy;

        _sortedData

    };

    case "entitiesBySide": {

        _args params [
            "_position",
            "_sideKey",
            ["_order", "ASCEND"]
        ];

        private _data = [_sectorData, _key] call ALIVE_fnc_hashGet;
        private _sideData = [_data, _sideKey] call ALIVE_fnc_hashGet;
        private _sortedData = [_sideData,[],{_position distance (_x select 1)},_order] call ALiVE_fnc_SortBy;

        _sortedData

    };

    case "vehiclesBySide": {

        _args params [
            "_position",
            "_sideKey",
            ["_order", "ASCEND"]
        ];

        private _data = [_sectorData, _key] call ALIVE_fnc_hashGet;
        private _sideData = [_data, _sideKey] call ALIVE_fnc_hashGet;
        private _sortedData = [_sideData,[],{_position distance (_x select 1)},_order] call ALiVE_fnc_SortBy;

        _sortedData

    };

};