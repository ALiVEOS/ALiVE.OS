/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_findHouseProgressive
Description:
    Progressive-radius wrapper around ALIVE_fnc_advciv_findHouse. Searches at
    1x, 2x, then 3x the configured ALiVE_advciv_fleeRadius, returning the
    first radius at which a usable building is found. Used by the PANIC-state
    cover-seeking logic in fnc_advciv_brainTick to avoid stranding civs in
    open terrain (bridges, runways, fields) when the nearest viable building
    happens to be beyond the default fleeRadius.

    The 3x cap (default 360 m) is intentionally bounded - civilians shouldn't
    sprint half a kilometre to find a house, but they should reach the next
    block over from a wide-open patch like a bridge centre.

    Logs each radius attempt behind the ALiVE_advciv_debug gate so test runs
    can see exactly which radius succeeded (or that all three failed).

Parameters:
    _this select 0: OBJECT - The civilian unit seeking shelter
Returns:
    ARRAY - [building OBJECT, positions ARRAY] in the same shape as
            ALIVE_fnc_advciv_findHouse. building == objNull and positions == []
            if no usable building was found at any of the progressive radii.
See Also:
    ALIVE_fnc_advciv_findHouse, ALIVE_fnc_advciv_brainTick
Author:
    Jman
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {[objNull, []]};

private _baseRadius = ALiVE_advciv_fleeRadius;
private _multipliers = [1, 2, 3];
private _result = [objNull, []];

{
    private _multiplier = _x;
    private _radius = _baseRadius * _multiplier;
    private _h = [_unit, _radius] call ALiVE_fnc_advciv_findHouse;
    private _bld = _h select 0;
    private _positions = _h select 1;
    if (!isNull _bld && {count _positions > 0}) exitWith {
        _result = _h;
        if (ALiVE_advciv_debug) then {
            diag_log format ["[ALiVE Hide DEBUG] findHouseProgressive civ=%1 FOUND building at radius=%2m (multiplier=%3x) dist=%4", name _unit, _radius, _multiplier, _unit distance _bld];
        };
    };
    if (ALiVE_advciv_debug) then {
        diag_log format ["[ALiVE Hide DEBUG] findHouseProgressive civ=%1 radius=%2m (multiplier=%3x) - no usable building, expanding", name _unit, _radius, _multiplier];
    };
} forEach _multipliers;

if (ALiVE_advciv_debug && {isNull (_result select 0)}) then {
    diag_log format ["[ALiVE Hide DEBUG] findHouseProgressive civ=%1 EXHAUSTED all radii up to %2m - no cover available", name _unit, _baseRadius * 3];
};

_result
