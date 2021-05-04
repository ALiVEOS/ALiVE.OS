/*
    Author: Wyqer, veteran29
    Date: 2019-09-27

    Description:
        Fetches VN mission failure on wipe parameter.

    Parameter(s):
        _paramValue - Value of the parameter [NUMBER, defaults to 1]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 1, [0]]
];

// Store hints setting in global variable
vn_failOnWipe = _paramValue;

true
