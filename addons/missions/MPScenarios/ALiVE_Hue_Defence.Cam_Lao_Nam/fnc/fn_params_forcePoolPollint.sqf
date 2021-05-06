/*
    Author: Jman
    Date: 20/04/2021

    Description:
        Fetches and handles the ALiVE forcepool polling interval parameter.

    Parameter(s):
        _paramValue - Value of the parameter [NUMBER, defaults to 0]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 900, [0]]
];

  alive_forcepool_cycleTime = _paramValue;

true
