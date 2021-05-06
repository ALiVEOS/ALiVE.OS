/*
    Author: Jman
    Date: 14/04/2021

    Description:
        Fetches and handles RotorLib flight model parameter.

    Parameter(s):
        _paramValue - Value of the parameter [NUMBER, defaults to 0]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 2, [0]]
];

  forceRotorLibSimulation = _paramValue;

true
