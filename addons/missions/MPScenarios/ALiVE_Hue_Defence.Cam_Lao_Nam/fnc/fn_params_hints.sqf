/*
    Author: Wyqer, veteran29
    Date: 2019-07-30

    Description:
        Fetches VN hints parameter.

    Parameter(s):
        _paramValue - Value of the parameter [NUMBER, defaults to 1]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 1, [0]]
];

// Store hints setting in global variable
vn_hints = _paramValue;

true
