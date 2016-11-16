#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisFlatEmpty);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisFlatEmpty

Description:
Perform analysis on an array of sectors using the find empty command

Parameters:
Array - array of sectors
Scalar - the max positions to find within the sector
String - vehicle class to use to find empty position for

Returns:
...

Examples:
(begin example)
// add flat empty data to passed sector objects
_result = [_sectors] call ALIVE_fnc_sectorAnalysisFlatEmpty;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params [
    "_sectors"
    ["_vehicleClass", "false"]
];

private _err = format["sector analysis flat empty requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualType [], _err);

{
    private _sector = _x;
    private _centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
    private _dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;

    private _radius = _dimensions select 0;

    private _emptyPositions = [];

    private ["_position"];

    if !(_vehicleClass == "false") then {
        _position = _centerPosition findEmptyPosition[1, _radius, _vehicleClass];
    }else{
        _position = _centerPosition findEmptyPosition[1, _radius];
    };

    if(count _position > 0) then {
        // minDistance, precicePos, maxGradient, gradientRadius, onWater, onShore
        _position = _position isFlatEmpty[1,1,0.5,2,0,false];
        _emptyPositions = [_position];
    };

    // store the result of the analysis on the sector instance
    [_sector, "data", ["flatEmpty",_emptyPositions]] call ALIVE_fnc_sector;
} forEach _sectors;