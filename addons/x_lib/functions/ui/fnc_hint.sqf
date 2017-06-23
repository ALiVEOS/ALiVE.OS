#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_hint

Description:
    Hints a message to the player without overwriting other hints.

Parameters:
    0 - Hint text [string]
    1 - Text format parameters [array] (optional)
    2 - Hint silent [bool] (optional)
    3 - Hint display duration seconds [number] (optional)

Returns:
    Nothing [nil]

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    Naught
---------------------------------------------------------------------------- */

if (hasInterface) then { // Don't do anything on non-GUI machines
    if (isNil "ALiVE_hintQueue") then {ALiVE_hintQueue = []};

    ALiVE_hintQueue pushBack _this;

    if ((count ALiVE_hintQueue) == 1) then { // Run queue
        0 spawn {
            while {(count ALiVE_hintQueue) > 0} do {
                private ["_text"];
                (ALiVE_hintQueue select 0) params ["_arg0", ["_arg1", [], [[]]], ["_arg2", false, [true]], ["_arg3", -1, [0]]];
                _text = format([_arg0] + _arg1);
                if (_arg3 == -1) then { _arg3 = 1.5 + ([_text] call ALiVE_fnc_timeToRead); };

                if (_arg2) then { // Silent
                    hintSilent parseText(_text);
                } else { // Normal
                    hint parseText(_text);
                };

                uiSleep(_arg3);

                ALiVE_hintQueue deleteAt 0;
            };
        };
    };
};
