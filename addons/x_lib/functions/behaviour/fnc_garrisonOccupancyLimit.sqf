#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(garrisonOccupancyLimit);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_garrisonOccupancyLimit

Description:
The most men a garrison may seat in any one building, for the whole mission.

Every placement module carries a Garrison Building Occupancy Limit setting. It is read
off the module logics the same way the blacklist is, so no caller has to know the value
and no signature anywhere changes.

Where more than one module sets a limit the smallest wins. The setting exists to stop
men packing into one building, and a mission that asked for two somewhere clearly does
not want twelve elsewhere.

The answer cannot change after mission start, so it is worked out once and kept.

The field is plain text, so a value that is not a whole number is skipped and reported
rather than guessed at. parseNumber reads "2 men" as 2 and "x" as 0, and both would be
worse than saying nothing happened: one silently invents a limit the author did not
write, the other silently removes the limit they did.

Parameters:
    None.

Returns:
    NUMBER - the limit, or 0 when no module set a usable one, which is the ordinary
    case and leaves every garrison seating exactly as it did before the setting existed.

Examples:
(begin example)
private _cap = call ALIVE_fnc_garrisonOccupancyLimit;
if (_cap > 0) then {
    _buildingPositions = _buildingPositions select [0, _cap];
};
(end)

See Also:
- <ALIVE_fnc_garrisonBuildingBlacklist>
- <ALIVE_fnc_groupGarrison>

Author:
Jman
---------------------------------------------------------------------------- */

if !(isNil "ALiVE_garrisonOccupancyLimitCache") exitWith { ALiVE_garrisonOccupancyLimitCache };

private _limits = [];
private _rejected = [];

// Eden writes each module's setting onto the module logic at mission load, so the
// modules are read directly rather than made to announce themselves.
{
    // Captured because the digit test below rebinds _x.
    private _module = _x;
    private _raw = _module getVariable ["garrisonOccupancyLimit", ""];

    if (_raw isEqualType "" && {_raw != ""}) then {
        // A pasted value can carry tabs or line breaks even from a single-line field.
        private _text = (_raw splitString toString [9,13,10]) joinString " ";
        while {count _text > 0 && {(_text select [0, 1]) == " "}} do { _text = _text select [1] };
        while {count _text > 0 && {(_text select [count _text - 1, 1]) == " "}} do { _text = _text select [0, count _text - 1] };

        if (_text != "") then {
            // Digits only, the same test the preferred-positions setting uses. This is
            // what rejects "-1", "1.5" and "2 men" rather than reading a number out of
            // them.
            private _isNumber = true;
            { if (_x < 48 || {_x > 57}) then { _isNumber = false }; } forEach toArray _text;

            if (_isNumber) then {
                private _n = parseNumber _text;
                // Zero is accepted as no limit rather than reported. It is the obvious
                // way to write "off" and it already means that everywhere else here.
                if (_n > 0) then { _limits pushBack [_n, typeOf _module] };
            } else {
                _rejected pushBack [_text, typeOf _module];
            };
        };
    };
} forEach (entities "Module_F");

private _limit = 0;
if !(_limits isEqualTo []) then {
    _limit = selectMin (_limits apply { _x select 0 });
};

// Reported once. A setting that did nothing reads to the author as a broken feature,
// and two modules disagreeing is worth saying out loud rather than leaving them to
// wonder which one took effect.
if !(_rejected isEqualTo []) then {
    ["ALiVE garrisonOccupancyLimit - %1 setting(s) not understood and skipped, no limit taken from them: %2", count _rejected, _rejected] call ALiVE_fnc_dump;
};

private _distinct = [];
{ _distinct pushBackUnique (_x select 0); } forEach _limits;
if (count _distinct > 1) then {
    ["ALiVE garrisonOccupancyLimit - %1 modules set different limits (%2); the smallest, %3, applies to every garrison", count _limits, _distinct, _limit] call ALiVE_fnc_dump;
};

if (_limit > 0) then {
    ["ALiVE garrisonOccupancyLimit - limit %1 per building applies to every garrison", _limit] call ALiVE_fnc_dump;
};

ALiVE_garrisonOccupancyLimitCache = _limit;
_limit
