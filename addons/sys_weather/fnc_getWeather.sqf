#include <\x\alive\addons\sys_weather\script_component.hpp>
SCRIPT(getWeather);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getWeather
Description:
Gets real weather for a time and location, returns a CBA_HASH of weather observations for the day

Parameters:
_this select 0: STRING - Location either as COUNTRY/CITY or LON,LAT

Returns:
CBA_HASH - Weather conditions

Examples:
(begin example)
// get london weather
_weather = ["England/London"] call ALIVE_fnc_getWeather;
(end)

See Also:
- <ALIVE_fnc_weather>

Author:
Tuplov
Peer Reviewed:

---------------------------------------------------------------------------- */

private _location = _this select 0;

private _result = false;

// Check Location
// Create function call
private _cmd = format ["GetWeatherLocation [""%1""]", _location];

// diag_log format ["cmd: %1",_cmd];

// Send command to plugin
private _newLoc = [_cmd] call ALIVE_fnc_sendToPlugin;

diag_log format ["WEATHER LOCATION JSON: %1",_newloc];

if ([_newloc, "Error"] call CBA_fnc_find == -1) then {

    // Process Weather Location data
    _newloc = [nil,"decode",_newLoc] call ALiVE_fnc_json;
    _newLoc = [_newLoc select 3,"get",["l"]] call ALiVE_fnc_json;

    //diag_log format ["WEATHER LOCATION JSON: %1",_newloc];

    private _date = date;
    private _year = "2015";
    private _i = 0;

    {
        if (_x < 10) then {
            _date set [_i, "0" + str(_x)];
        } else {
            _date set [_i, _x];
        };
        _i = _i + 1;
    } foreach _date;

    // Create function call
    _cmd = format ["GetWeather ['%1','%2','%3','%4','%5']", _year, _date select 1, _date select 2, _date select 3, _newloc];

    //diag_log format ["weather cmd: %1",_cmd];

    // Send command to plugin (Dedicated Server only atm)
    //if (isDedicated) then {
        private _response = [_cmd] call ALIVE_fnc_sendToPlugin;
    //} else {
    //    _response = "ALiVEClient" callExtension _cmd;
    // };

    //diag_log format ["WEATHER JSON: %1",_response];

    // Check response for error
    // TO DO

    // Parse correct response
    _result = [nil,"decode",_response] call ALiVE_fnc_json;

} else {
    _result = _newloc;
};

_result;