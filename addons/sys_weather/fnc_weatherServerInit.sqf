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

GVAR(REAL_WEATHER) = false;

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

        // Check to see if you want the weather right now
        if (WEATHER_OVERRIDE == 5) then {
            // Server will return UTC
            private _tmpDate =  ([true] call ALIVE_fnc_getServerTime) splitString "/ :";
            private _curDate = [_tmpDate select 2, _tmpDate select 1, _tmpDate select 0, _tmpDate select 3, _tmpDate select 4];

            GVAR(REAL_WEATHER) = [WEATHER_CYCLE_REAL_LOCATION, _curDate] call ALIVE_fnc_getRealWeather;
        } else {
            // Get weather for game time
            GVAR(REAL_WEATHER) = [WEATHER_CYCLE_REAL_LOCATION] call ALIVE_fnc_getRealWeather;
        };

        if (typeName GVAR(REAL_WEATHER) == "BOOL") exitWith {
            diag_log format["--------------------------------- ERROR GETTING REAL WEATHER : %1", WEATHER_CYCLE_REAL_LOCATION];
        };

        _rainProbability = (parseNumber ([GVAR(REAL_WEATHER),"rain", 0] call ALiVE_fnc_hashGet)) * 100;
        _fogProbability = (parseNumber ([GVAR(REAL_WEATHER),"fog", 0] call ALiVE_fnc_hashGet)) * 100;
        _lightningProbability = (parseNumber ([GVAR(REAL_WEATHER),"thunder", 0] call ALiVE_fnc_hashGet)) * 100;

        private _conditions = [GVAR(REAL_WEATHER),"conds", "Clear"] call ALiVE_fnc_hashGet;

        // ["CONDITIONS: %1",_conditions] call ALIVE_fnc_dump;

        if (_conditions == "") then {_conditions = "Clear"};

        if (_conditions find "Drizzle" != -1 || _conditions find "Rain" != -1 || _conditions find "Snow" != -1 || _conditions find "Thunderstorms" != -1 || _conditions find "Showers" != -1 || _conditions find "Hail" != -1 || _conditions find "Ice" != -1) then {
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
            case "Light Haze";
            case "Light Fog Patches": {
                _minimumFog = 0.1; _maximumFog = 0.2;
            };
            case "Haze";
            case "Light Freezing Fog";
            case "Light Fog": {
                _minimumFog = 0.2; _maximumFog = 0.3;
            };
            case "Heavy Haze";
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

        // Check conditions for rain

        private _minimumRain = 0;
        private _maximumRain = 0.1;

        switch (_conditions) do {
            case "Light Drizzle": {
                _minimumRain = 0.1; _maximumRain = 0.2;
            };
            case "Light Rain Mist";
            case "Drizzle": {
                _minimumRain = 0.2; _maximumRain = 0.3;
            };
            case "Rain Mist";
            case "Heavy Drizzle";
            case "Light Freezing Rain";
            case "Light Rain": {
                _minimumRain = 0.3; _maximumRain = 0.4;
            };
            case "Heavy Rain Mist";
            case "Light Rain Showers";
            case "Freezing Rain";
            case "Rain": {
                _minimumRain = 0.4; _maximumRain = 0.5;
            };
            case "Light Thunderstorms and Rain";
            case "Rain": {
                _minimumRain = 0.5; _maximumRain = 0.6;
            };
            case "Thunderstorms and Rain";
            case "Rain Showers": {
                _minimumRain = 0.7; _maximumRain = 0.8;
            };
            case "Heavy Thunderstorms and Rain";
            case "Heavy Rain Showers";
            case "Heavy Freezing Rain";
            case "Heavy Rain": {
                _minimumRain = 0.9; _maximumRain = 1;
            };
            default {
                _minimumRain = 0; _maximumRain = 0.1;
            };
        };
        0 setRain (_minimumRain + random (_maximumRain - _minimumRain));

        // Check conditions for lightning
        private _lightnings = parseNumber ([GVAR(REAL_WEATHER),"thunder", 0] call ALiVE_fnc_hashGet);
        if (_conditions find "Thunderstorm" != -1) then {
            _lightnings = 0.5;
        };
        if (_conditions find "Light Thunderstorm" != -1) then {
            _lightnings = 0.2;
        };
        if (_conditions find "Heavy Thunderstorm" != -1) then {
            _lightnings = 1;
        };
        0 setLightnings _lightnings;

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

private _windSpeed = random 5;
private _windDir = random 360;
private _isFoggy = false;

if (INITIAL_WEATHER == 5 && typeName GVAR(REAL_WEATHER) != "BOOL") then { // REAL WEATHER

    // Calculate Fog
    _isFoggy = parseNumber ([GVAR(REAL_WEATHER),"fog", 0] call ALiVE_fnc_hashGet);
    if (_isFoggy > 0.5) then {true}else{false};

    // TODO - Haze, Mist etc
    if (random 100 <= _fogProbability) then {
        _isFoggy = true;
        0 setFog [_initialFog, _initialFogDecay, _initialFogAltitude];
    };

    // Set clouds, rain and lightning
    0 setOvercast round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);

    // Calculate Wind
    _windDir = parseNumber ([GVAR(REAL_WEATHER),"wdird", random 360] call ALiVE_fnc_hashGet);
    _windSpeed = parseNumber ([GVAR(REAL_WEATHER),"wspdm", 1 + (random 5)] call ALiVE_fnc_hashGet);
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

if (WEATHER_DEBUG) then {
    ["INIT WEATHER SETTINGS: Overcast: %1, MinO: %2, MaxO: %3, RainProb: %4, Rain: %5, LightProb: %6, Lightning: %7, WindDir: %8, Wind: %9, WindSpeed: %10, FogP: %11, minFog: %12, maxFog: %13, Fog: %14, Fog Settings [%15, %16, %17], Decimal: %18, CycleVar: %19, Delay: %20",round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces), _minimumOvercast, _maximumOvercast, _rainProbability, rain, _lightningProbability, lightnings, _windDir, wind, _windSpeed, _fogProbability, _minimumFog, _maximumFog, _isFoggy, _initialFog, _initialFogDecay, _initialFogAltitude, _decimalplaces, _cycleVariance, _cycleDelay] call ALIVE_fnc_dump;
};


if (INITIAL_WEATHER != 5) then {
    if (WEATHER_DEBUG) then { ["Module ALiVE_sys_weather WEATHER CHANGED! OVERCAST: %1, NEXTWEATHERCHANGE: %2", overcast, nextWeatherChange] call ALIVE_fnc_dump;};
    // Now lets apply the first weather settings to the server and run the cycle delay in a new thread and launch the weathercycle function when delay complete.
    [round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces), _rainProbability, _lightningProbability, _cycleDelay, _maximumOvercast, _fogProbability, _minimumOvercast, _windDir, _minimumFog, _maximumFog, _isFoggy, _initialFog, _initialFogDecay, _initialFogAltitude, _decimalplaces, _cycleVariance] spawn ALIVE_fnc_weatherServer;

} else {

    // Real weather should just start moving weather towards the state in the next hour

};






