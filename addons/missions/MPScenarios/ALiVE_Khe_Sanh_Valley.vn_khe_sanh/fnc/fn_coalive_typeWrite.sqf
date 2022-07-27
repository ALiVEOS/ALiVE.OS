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
    private _w = 0.95;
    private _h = 0.55;
    date params ["", "", "", "_hour", "_minute"];

    [
        [
            ["Khe Sanh Valley", "<t align = 'left' shadow = '1' size = '0.7' font='tt2020style_e_vn_bold'>%1</t>"],
            [" "],
            [format ["Sunday 21st April 1968. %1%2%3%4h", ["0", ""] select (_hour >= 10), _hour, ["0", ""] select (_minute >= 10), _minute]],
            ["2nd Brigade, 1st Cavalry Division, Khe Sanh", "<t align = 'left' shadow = '1' size = '0.7'>%1</t><br/><br/>"],
            ["Mission: ", "<t align = 'left' shadow = '1' size = '0.7' font='tt2020style_e_vn_bold'>%1</t>"],
            ["Defend Khe Sanh, conduct counter insurgency operations from FSB Old French Fort", nil, 3.5]
        ],
        [safeZoneX + safeZoneW - _w, _w],
        [safeZoneY + safeZoneH - _h - 0.05, _h]
    ] spawn vn_ms_fnc_sfx_typeText;
};

true
