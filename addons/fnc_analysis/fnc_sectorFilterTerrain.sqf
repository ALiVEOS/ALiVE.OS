#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(sectorFilterTerrain);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorFilterTerrain

Description:
Returns an array of sectors with a terrain type filtered out

Parameters:
Array - Array of sectors

Returns:
Array of terrain filtered sectors

Examples:
(begin example)
    _landSectors = [_sectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;
(end)

See Also:


Author:
ARJay
shukari
---------------------------------------------------------------------------- */

if (!params [
        ["_sectors", [], [[]]],
        ["_terrainType", "", [""]]
    ]) exitWith {["ANALYSIS - ALIVE_fnc_sectorFilterTerrain - Wrong input - CALLER: %1 - INPUT: %2", _fnc_scriptNameParent, _this] call ALiVE_fnc_Dump};

_sectors select {
    private _sectorData = [_x, "data"] call ALIVE_fnc_sector;
    
    !isNil "_sectorData" && {([_sectorData, "terrain", ""] call ALIVE_fnc_hashGet) != _terrainType}
};
