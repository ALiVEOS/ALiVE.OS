#include "\x\alive\addons\sys_weather\script_component.hpp"
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
private _date = date;

if (count _this > 1) then {
    _date = _this select 1;
};

// Convert dates to SCALARS
{
    If (typeName _x == "STRING") then {
        _date set [_foreachIndex, parseNumber _x];
    };
} foreach _date;

private _result = false;

// Check Location
// Create function call
private _cmd = format ["GetWeatherLocation [""%1""]", _location];

// diag_log format ["cmd: %1",_cmd];

// Send command to plugin
private _newLoc = [_cmd] call ALIVE_fnc_sendToPlugin;

// diag_log format ["WEATHER LOCATION JSON: %1",_newloc];

if ([tolower(_newloc), "error"] call CBA_fnc_find == -1) then {

    // Process Weather Location data
    _newloc = [nil,"decode",_newLoc] call ALiVE_fnc_json;
    _newLoc = [_newLoc select 3,"get",["l"]] call ALiVE_fnc_json;

    diag_log format ["WEATHER LOCATION: %1 = %2",_location, _newloc];

    private _year = _date select 0;
    private _mon = _date select 1;
    private _day = _date select 2;
    private _hour = _date select 3;

    // Work out which year should be used

    // Get the local time to the server (not UTC)
    private _curDate =  ([true] call ALIVE_fnc_getServerTime) splitString "/ :";
    private _curYear = parseNumber (_curDate select 2);
    private _curMon = parseNumber (_curDate select 1);
    private _curDay = parseNumber (_curDate select 0);
    private _curHour = parseNumber (_curDate select 3);

    if (_year > _curYear || _year < 2007) then {
        _date set [0,_curYear - 1];
    };

    if (_year == _curYear && _mon > _curMon) then {
        _date set [1,_curMon - 1];
    };

    if (_year == _curYear && _mon == _curMon && _day > _curDay) then {
        _date set [2,_curDay - 1];
    };

    if (_year == _curYear && _mon == _curMon && _day == _curDay && _hour >= _curHour) then {
        _date set [3,_curHour - 1];
    };


    // convert date back to string to handle values less than 10
    {
        if (_x < 10) then {
            _date set [_foreachIndex, "0" + str(_x)];
        } else {
            _date set [_foreachIndex, str(_x)];
        };

    } foreach _date;

    // Create function call
    _cmd = format ["GetWeather ['%1','%2','%3','%4','%5']", _date select 0, _date select 1, _date select 2, _date select 3, _newloc];

    diag_log format ["weather cmd: %1",_cmd];

    // Send command to plugin (Dedicated Server only atm)
    //if (isDedicated) then {
        private _response = [_cmd] call ALIVE_fnc_sendToPlugin;
    //} else {
    //    _response = "ALiVEClient" callExtension _cmd;
    // };

    //diag_log format ["WEATHER JSON: %1",_response];

    // Check response for error or no data
    // TO DO

    // Parse correct response
    private _realWeather = [nil,"decode",_response] call ALiVE_fnc_json;

    if (typename _realWeather == "ARRAY") then {

        private _weatherHash = [] call ALiVE_fnc_hashCreate;

        /*
            tempm   Temp in C
            tempi   Temp in F
            dewptm  Dewpoint in C
            dewpti  Duepoint in F
            hum Humidity %
            wspdm   WindSpeed kph
            wspdi   Windspeed in mph
            wgustm  Wind gust in kph
            wgusti  Wind gust in mph
            wdird   Wind direction in degrees
            wdire   Wind direction description (ie, SW, NNE)
            vism    Visibility in Km
            visi    Visability in Miles
            pressurem   Pressure in mBar
            pressurei   Pressure in inHg
            windchillm  Wind chill in C
            windchilli  Wind chill in F
            heatindexm  Heat index C
            heatindexi  Heat Index F
            precipm Precipitation in mm
            precipi Precipitation in inches
            pop Probability of Precipitation
            conds   See possible condition phrases below
        */

        private _count = (count _realWeather)-2;

        for [{ private _i = 4},{_i <= _count},{_i = _i + 2}] do {
            [_weatherHash,_realWeather select _i, _realWeather select (_i+1)] call ALiVE_fnc_hashSet;
        };

        diag_log format["--------------------------------- WEATHER IN %1 AT %2 ---------------------------------", WEATHER_CYCLE_REAL_LOCATION, _date];

        if (WEATHER_DEBUG) then {
            _weatherHash call ALiVE_fnc_inspectHash;
        };

        _result = _weatherHash;

    } else {
        diag_log format["--------------------------------- ERROR GETTING REAL WEATHER : %1", _realWeather];
    };
} else {
    diag_log format["--------------------------------- ERROR GETTING REAL WEATHER : %1", _newLoc];
};

_result

/*
Current Condition Phrases

Some conditions can be Light, Heavy or normal, which has no classifier. For example, Light Drizzle, Heavy Drizzle, and Drizzle are all possible conditions.

    [Light/Heavy] Drizzle
    [Light/Heavy] Rain
    [Light/Heavy] Snow
    [Light/Heavy] Snow Grains
    [Light/Heavy] Ice Crystals
    [Light/Heavy] Ice Pellets
    [Light/Heavy] Hail
    [Light/Heavy] Mist
    [Light/Heavy] Fog
    [Light/Heavy] Fog Patches
    [Light/Heavy] Smoke
    [Light/Heavy] Volcanic Ash
    [Light/Heavy] Widespread Dust
    [Light/Heavy] Sand
    [Light/Heavy] Haze
    [Light/Heavy] Spray
    [Light/Heavy] Dust Whirls
    [Light/Heavy] Sandstorm
    [Light/Heavy] Low Drifting Snow
    [Light/Heavy] Low Drifting Widespread Dust
    [Light/Heavy] Low Drifting Sand
    [Light/Heavy] Blowing Snow
    [Light/Heavy] Blowing Widespread Dust
    [Light/Heavy] Blowing Sand
    [Light/Heavy] Rain Mist
    [Light/Heavy] Rain Showers
    [Light/Heavy] Snow Showers
    [Light/Heavy] Snow Blowing Snow Mist
    [Light/Heavy] Ice Pellet Showers
    [Light/Heavy] Hail Showers
    [Light/Heavy] Small Hail Showers
    [Light/Heavy] Thunderstorm
    [Light/Heavy] Thunderstorms and Rain
    [Light/Heavy] Thunderstorms and Snow
    [Light/Heavy] Thunderstorms and Ice Pellets
    [Light/Heavy] Thunderstorms with Hail
    [Light/Heavy] Thunderstorms with Small Hail
    [Light/Heavy] Freezing Drizzle
    [Light/Heavy] Freezing Rain
    [Light/Heavy] Freezing Fog
    Patches of Fog
    Shallow Fog
    Partial Fog
    Overcast
    Clear
    Partly Cloudy
    Mostly Cloudy
    Scattered Clouds
    Small Hail
    Squalls
    Funnel Cloud
    Unknown Precipitation
    Unknown
*/