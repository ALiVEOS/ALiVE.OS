#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(getPositionDistancePlayers);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getPositionDistancePlayers

Description:
Get closest position with no players present

Parameters:
Array - Position center point for search
Scalar - Max Radius of search
Scalar - Count positions to find
Boolean - Only land positions

Returns:
Array - position

Examples:
(begin example)
// get closest position with no players present
_position = [getPos player] call ALIVE_fnc_getPositionDistancePlayers;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_distance","_countToFind","_onlyLand","_result","_err","_sectors","_sector",
"_center","_playersInRange","_countFound","_found"];

_position = _this select 0;
_distance = _this select 1;
_countToFind = if(count _this > 2) then {_this select 2} else {1};
_onlyLand = if(count _this > 3) then {_this select 3} else {false};

_err = format["get closest no players requires a position array - %1",_position];
ASSERT_TRUE(typeName _position == "ARRAY",_err);

_sectors = [ALIVE_sectorGrid, "sectors"] call ALIVE_fnc_sectorGrid;

if(_onlyLand) then {
    _sectors = [_sectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;
};

_sectors = [_sectors,_position] call ALIVE_fnc_sectorSortDistance;

scopeName "main";
_countFound = 0;
_found = [];

{
    _sector = _x;
    _center = [_sector, "center"] call ALIVE_fnc_sector;
    _playersInRange = [_center, _distance] call ALiVE_fnc_anyPlayersInRange;

    if(_playersInRange == 0) then {

        _position = _center;

        // Check if position is water (in case of shore sector)
        if (_onlyLand && surfaceIsWater _position) then {

            // Go find nearest land
            _pos = [_position, _distance/2] call ALiVE_fnc_getClosestLand;

            if (_pos distance _position > 5) then {
                _found set [count _found, _pos];

                _countFound = _countFound + 1;
            };

        } else {

            _found set [count _found, _position];

            _countFound = _countFound + 1;
        };

        if(_countFound == _countToFind) then {

            breakTo "main";
        }
    };
} forEach _sectors;

if(_countToFind == 1) then {
    _result = _found select 0;
}else{
    _result = _found;
};

_result