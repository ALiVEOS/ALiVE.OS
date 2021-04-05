/*
    Author: Wyqer, veteran29
    Date: 2019-07-21

    Description:
        Writing mission information on mission startup.

    Parameter(s):
        NONE

    Returns:
        Effects were started [BOOL]
*/

[] spawn {
    sleep 2;
    // Corner coordinates
    private _w = 0.80;
    private _h = 0.45;
    date params ["", "", "", "_hour", "_minute"];

    [
        [
            ["Operation: ", "<t align = 'left' shadow = '1' size = '0.7' font='tt2020style_e_vn_bold'>%1</t>"],
            ["The Defence of Hue"],
            [format ["Wednesday 31st January 1968. %1%2%3%4h", ["0", ""] select (_hour >= 10), _hour, ["0", ""] select (_minute >= 10), _minute]],
            ["1st Marine Regiment, Task Force X-Ray, Phu Bai Combat Base, South Vietnam", "<t align = 'left' shadow = '1' size = '0.7'>%1</t><br/><br/>"],
            ["Target AO: ", "<t align = 'left' shadow = '1' size = '0.7' font='tt2020style_e_vn_bold'>%1</t>"],
            ["Hue and the Imperial City", nil, 3.5]
        ],
        [safeZoneX + safeZoneW - _w, _w],
        [safeZoneY + safeZoneH - _h - 0.05, _h]
    ] spawn vn_ms_fnc_sfx_typeText;
};

true
