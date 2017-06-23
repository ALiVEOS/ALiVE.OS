#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_log

Description:
    Logs a value to the diagnostics logs.

Parameters:
    0 - Log level [string]
    1 - Component [string]
    2 - Message [string]
    3 - Message parameters [array] (optional)
    4 - File path [string] (optional)
    5 - Line number [number] (optional)

Returns:
    Nothing

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    Naught
---------------------------------------------------------------------------- */

params [["_level", "", [""]], ["_component", "", [""]], ["_message", "", [""]],
        ["_params", [], [[]]], ["_path", "File Not Found", [""]], ["_lineNumber", 0, [0]]];

if ([ALiVE_log_level,([toLower(_this select 0)] call ALiVE_fnc_convertLogLevel)] call ALiVE_fnc_selBinStr) then {
    private ["_output"];
    _output = format[
        "%1: %2 [ T: %3 | TT: %4 | F: '%5:%6' | M: '%7' | W: '%8' ] %9",
        _level, _component, time, diag_tickTime, _path, str(_lineNumber),
        missionName, worldName, format([_message] + _params)
    ];

    diag_log text _output;

    if (ALiVE_logToDiary) then {
        if (isNil "ALiVE_diaryLogQueue") then {ALiVE_diaryLogQueue = []};
        ALiVE_diaryLogQueue pushBack _output;
    };
};
