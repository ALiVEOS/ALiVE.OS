/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_weatherServerInit
Description:
Server side weather init

Parameters:
_this select 0: OBJECT - Reference to module


Returns:
Nil

See Also:
- <ALIVE_fnc_weather>

Author:
Jman
Peer Reviewed:
nil
---------------------------------------------------------------------------- */
#include <\x\alive\addons\sys_weather\script_component.hpp>
SCRIPT(weatherServerInit);

if !(isServer) exitwith {};

if (WEATHER_DEBUG) then {
    ["Module ALiVE_sys_weather SERVER STARTING"] call ALIVE_fnc_dump;
    ["Module ALiVE_sys_weather INITIAL_WEATHER: %1, WEATHER_CYCLE_DELAY: %2, WEATHER_CYCLE_VARIANCE: %3",INITIAL_WEATHER,WEATHER_CYCLE_DELAY,WEATHER_CYCLE_VARIANCE] call ALIVE_fnc_dump;
};

private _currentdate = date;
private _currenthour = _currentdate select 3;
private _currentmonth = _currentdate select 1;
private _rainProbability = 0;
private _fogProbability = 0;
private _lightningProbability = 0;
private _minimumOvercast = 0;
private _maximumOvercast = 0.5;
private _minimumFog = 0;
private _maximumFog = 0.5;

// Implement snow probability, storm probability, sand storm?

// Random climate selector
private _options = [0,1,2,3];

if (INITIAL_WEATHER == 4)  then { INITIAL_WEATHER = (selectRandom _options); };

switch (INITIAL_WEATHER) do
{

    case 0: {    //  Arid - A region that receives very little precipitation all year.
        _rainProbability = 0;
        _fogProbability = 0;
        _lightningProbability = 0;
        _minimumOvercast = 0;
        _maximumOvercast = 0.30;
    };

    case 1: {  // Continental - Climate is marked by variable weather patterns and a large seasonal temperature variance.
        _rainProbability = 50;
        _lightningProbability = 50;

        // Winter (December, January and February)
        _minimumOvercast = 0.45;
        _maximumOvercast = 1;
        _fogProbability = 15;

        if (_currentmonth >=3 && _currentmonth <=5) then {  // Spring (March, April and May)
            _minimumOvercast = 0.2;
            _maximumOvercast = 0.55;
            _fogProbability = 10;
        };
        if (_currentmonth >=6 && _currentmonth <=8) then {  // Summer (June, July and August)
            _minimumOvercast = 0;
            _maximumOvercast = 0.50;
            _fogProbability = 5;
        };
        if (_currentmonth >=9 && _currentmonth <=11) then {  // Autumn (September, October and November)
            _minimumOvercast = 0.45;
            _maximumOvercast = 0.65;
            _fogProbability = 10;
        };
    };

    case 2: {  // Tropical - Climate zone where monsoon (June to September) rainfall is associated with large storms.
        _rainProbability = 85;
        _lightningProbability = 95;

         // post-monsoon period (October to December).
         _minimumOvercast = 0.45;
         _maximumOvercast = 0.75;
         _fogProbability = 10;

        if (_currentmonth >=6 && _currentmonth <=9) then {  // monsoon (June to September)
            _minimumOvercast = 0.90;
            _maximumOvercast = 1;
        };
        if (_currentmonth >=1 && _currentmonth <=2) then {  // winter (January and February)
            _minimumOvercast = 0.45;
            _maximumOvercast = 1;
        };
        if (_currentmonth >=3 && _currentmonth <=5) then {  // summer (March to May)
            _minimumOvercast = 0;
            _maximumOvercast = 0.50;
        };
    };

    case 3: {   // Mediterranean - The climate is characterized by hot, dry summers and cool, wet winters.
        _rainProbability = 25;
        _lightningProbability = 35;

         // The rainy, and slightly cooler, winter period occurs in October, November, December, January, February and March.
         _minimumOvercast = 0.55;
         _maximumOvercast = 0.85;
         _fogProbability = 10;

        if (_currentmonth >=4 && _currentmonth <=9) then {  // Summer ( April through May, June, July, August and September)
            _minimumOvercast = 0;
            _maximumOvercast = 0.50;
        };
    };

    case 5: { // Real Weather - Real weather for a time and location you specify.

        // Get the current weather
        GVAR(REAL_WEATHER) = [WEATHER_CYCLE_REAL_LOCATION] call ALIVE_fnc_getRealWeather;

        _rainProbability = (parseNumber ([GVAR(REAL_WEATHER),"rain", 0] call ALiVE_fnc_hashGet)) * 100;
        _fogProbability = (parseNumber ([GVAR(REAL_WEATHER),"fog", 0] call ALiVE_fnc_hashGet)) * 100;
        _lightningProbability = (parseNumber ([GVAR(REAL_WEATHER),"thunder", 0] call ALiVE_fnc_hashGet)) * 100;

        private _conditions = [GVAR(REAL_WEATHER),"conds", "Clear"] call ALiVE_fnc_hashGet;

        if ("Drizzle" find _conditions != -1) then {
            _conditions = "Mostly Cloudy";
        };
        if ("Rain" find _conditions != -1 || "Snow" find _conditions != -1 || "Thunderstorms" find _conditions != -1 || "Showers" find _conditions != -1 || "Hail" find _conditions != -1 || "Ice" find _conditions != -1) then {
            _conditions = "Overcast";
        };

        // Check for Tornado
        private _tornado = parseNumber ([GVAR(REAL_WEATHER),"tornado", 0] call ALiVE_fnc_hashGet);

        // Check for Volcanic Ash, Dust, Sand, Haze, Drifting/Blowing Widespread Dust/Sand/Snow, Sandstorm, Smoke, Hail, Ice, Dust Whirls, Mist, shallow fog for effects


        // Check conditions for clouds
        switch (_conditions) do {
            case "Clear": {
                _minimumOvercast = 0; _maximumOvercast = 0.1;
            };
            case "Scattered Clouds": {
                _minimumOvercast = 0.1; _maximumOvercast = 0.3;
            };
            case "Partly Cloudy": {
                _minimumOvercast = 0.3; _maximumOvercast = 0.5;
            };
            case "Mostly Cloudy": {
                _minimumOvercast = 0.5; _maximumOvercast = 0.7;
            };
            case "Overcast": {
                _minimumOvercast = 0.7; _maximumOvercast = 1;
            };
            default {
                _minimumOvercast = 0.1; _maximumOvercast = 0.3;
            };
        };

        // Check conditions for fog
        switch (_conditions) do {
            case "Light Fog Patches": {
                _minimumFog = 0.1; _maximumFog = 0.2;
            };
            case "Light Freezing Fog";
            case "Light Fog": {
                _minimumFog = 0.2; _maximumFog = 0.3;
            };
            case "Patches of Fog": {
                _minimumFog = 0.2; _maximumFog = 0.3;
            };
            case "Partial Fog": {
                _minimumFog = 0.4; _maximumFog = 0.5;
            };
            case "Fog": {
                _minimumFog = 0.5; _maximumFog = 0.7;
            };
            case "Heavy Fog Patches": {
                _minimumFog = 0.8; _maximumFog = 0.9;
            };
            case "Heavy Freezing Fog";
            case "Heavy Fog": {
                _minimumFog = 0.9; _maximumFog = 1;
            };
            default {
                _minimumFog = 0; _maximumFog = 0.1;
            };
        };

    };
};

switch (WEATHER_OVERRIDE) do
{
        case 0: {};

        case 1: {  // clear
            _fogProbability = 0; _minimumOvercast = 0; _maximumOvercast = 0.40;
        };
        case 2: {  // overcast
            _fogProbability = 0; _minimumOvercast = 0.60; _maximumOvercast = 0.85;
        };
        case 3: {  // stormy
            _fogProbability = 0; _minimumOvercast = 0.85; _maximumOvercast = 1;
        };
        case 4: {  // foggy
            _fogProbability = 100; _minimumOvercast = 0.20; _maximumOvercast = 0.55;
            _minimumFog = 0.28;
            _maximumFog = 0.5;
        };
};

private _initialFog = (_minimumFog + random (_maximumFog - _minimumFog));
private _initialFogDecay = _initialFog/10+random _initialFog/100;
private _initialFogAltitude = random 150;

private _cycleVariance = WEATHER_CYCLE_VARIANCE;
private _cycleDelay = WEATHER_CYCLE_DELAY;
private _decimalplaces = 2;
private _initialOvercast = (_minimumOvercast + random (_maximumOvercast - _minimumOvercast));

private _windDir = random 360;
private _isFoggy = false;

if (INITIAL_WEATHER == 5) then { // REAL WEATHER

    // Calculate Fog
    _isFoggy = parseNumber ([GVAR(REAL_WEATHER),"fog", 0] call ALiVE_fnc_hashGet);
    if (_isFoggy > 0.5) then {true}else{false};

    if (random 100 <= _fogProbability) then {
        _isFoggy = true;
        0 setFog [_initialFog, _initialFogDecay, _initialFogAltitude];
    };

    // Set clouds, rain and lightning
    0 setOvercast round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
    0 setRain parseNumber ([GVAR(REAL_WEATHER),"rain", 0] call ALiVE_fnc_hashGet);
    0 setLightnings parseNumber ([GVAR(REAL_WEATHER),"thunder", 0] call ALiVE_fnc_hashGet);

    // Calculate Wind
    _windDir = parseNumber ([GVAR(REAL_WEATHER),"wdird", random 360] call ALiVE_fnc_hashGet);
    private _windSpeed = parseNumber ([GVAR(REAL_WEATHER),"wspdm", 1 + (random 5)] call ALiVE_fnc_hashGet);
    setWind [-_windSpeed * sin(_windDir), -_windSpeed * cos(_windDir), true];

    // Calculate gusts and waves
    // Using ACE calc for waves
    private _newWaves = ((vectorMagnitude [-_windSpeed * sin(_windDir), -_windSpeed * cos(_windDir),0]) / 16.0) min 1.0;
    if (abs(_newWaves - waves) > 0.1) then {
        1 setWaves _newWaves;
    };

    // Does gusts do anything?
    //0 setGusts = [GVAR(REAL_WEATHER),"wgustm", round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces)] call ALiVE_fnc_hashGet;


} else {
    0 setOvercast round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
    if (random 100 <= _fogProbability) then {
        _isFoggy = true;
        0 setFog [_initialFog, _initialFogDecay, _initialFogAltitude];
    };
    0 setWindForce round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
    0 setWindDir _windDir;
    0 setGusts round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
    0 setWaves round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
};

sleep 0.01;
forceWeatherChange;

if (WEATHER_DEBUG) then { ["Module ALiVE_sys_weather WEATHER CHANGED! OVERCAST: %1, NEXTWEATHERCHANGE: %2", overcast, nextWeatherChange] call ALIVE_fnc_dump;};

// Now lets apply the first weather settings to the server and run the cycle delay in a new thread and launch the weathercycle function when delay complete.
[round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces), _rainProbability, _lightningProbability, _cycleDelay, _maximumOvercast, _fogProbability, _minimumOvercast, _windDir, _minimumFog, _maximumFog, _isFoggy, _initialFog, _initialFogDecay, _initialFogAltitude, _decimalplaces, _cycleVariance] spawn ALIVE_fnc_weatherServer;







