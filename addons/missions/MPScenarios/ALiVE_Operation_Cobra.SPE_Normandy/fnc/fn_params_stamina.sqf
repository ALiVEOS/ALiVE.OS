/*
    Author: Wyqer, veteran29
    Date: 2019-09-16

    Description:
        Fetches and handles VN stamina parameter.

    Parameter(s):
        _paramValue - Value of the parameter [NUMBER, defaults to 1]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 1, [1]]
];

if (hasInterface && {_paramValue == 1}) then {
    // Disable stamina, if selected in parameter
    player setFatigue 0;
    player enableStamina false;
    

    // Add respawn event handler to reapply disabled stamina
    player addEventHandler ["Respawn", {player setFatigue 0; player enableStamina false;}];
};

true
