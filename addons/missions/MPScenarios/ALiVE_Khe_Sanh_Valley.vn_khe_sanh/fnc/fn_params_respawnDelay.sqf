/*
    Author: Wyqer, veteran29
    Date: 2019-08-28

    Description:
        Fetches VN Respawn delay parameter.

    Parameter(s):
        _paramValue - Respawn delay time [NUMBER, defaults to 60]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 60, [0]]
];

missionNamespace setVariable ["BIS_selectRespawnTemplate_delay", _paramValue];

true
