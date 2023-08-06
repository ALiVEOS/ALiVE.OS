/*
    Author: Wyqer, veteran29
    Date: 2019-12-06

    Description:
        Fetches and handles VN aimCoef parameter.

    Parameter(s):
        _paramValue - Value of the parameter [NUMBER, defaults to 1]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 0, [1]]
];

if (hasInterface && {_paramValue == 1}) then {
    // Reduce aim precision coefficient, if selected in parameter
    player setCustomAimCoef 0.1;

    // Add respawn event handler to reapply reduction
    player addEventHandler ["Respawn", {player setCustomAimCoef 0.1;}];
};

true
