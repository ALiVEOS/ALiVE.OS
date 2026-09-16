// Apply the destination airfield modifier to an already calculated base cost.
// Call only when airside weighting is active for the procedure.
params ["_sector", "_size", "_moveCost"];
private _isAirside = if (count _sector > 5) then {
    _sector select 5
} else {
    private _value = [_sector select 2, _size / 2] call ALiVE_fnc_isAirside;
    _sector set [5, _value];
    _value
};
if (_isAirside) then {_moveCost * ALiVE_pathfinding_airsideWeight} else {_moveCost}
