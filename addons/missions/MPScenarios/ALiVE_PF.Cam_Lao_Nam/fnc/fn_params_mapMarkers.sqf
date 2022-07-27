/*
    Author: Jman
    Date: 11-04-2021

    Description: Fetches and handles map markers parameter.

    Parameter(s):
        _paramValue - Value of the parameter [NUMBER, defaults to 0]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 0, [0]]
];

if (hasInterface && {_paramValue == 1}) then {
[] execVM "scripts\mapMarkers.sqf";
};

true
