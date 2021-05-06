/*
    Author: Wyqer, veteran29
    Date: 2020-12-05

    Description:
        Fetches VN whitelisted arsenal enabled/disabled parameter.

    Parameter(s):
        _paramValue - Value of the parameter [NUMBER, defaults to 0]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 0, [0]]
];

// Store arsenal setting in global variable
vn_ms_arsenalEnabled = _paramValue;

true
