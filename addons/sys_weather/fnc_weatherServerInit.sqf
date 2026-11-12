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
#include "\x\alive\addons\sys_weather\script_component.hpp"
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

// the starting weather: the same rain roll as every later change (fnc_weatherCycleServer.sqf)
private _initialRain = -1;
if (random 100 < _rainProbability && {_maximumOvercast >= 0.55}) then {
    _initialOvercast = _initialOvercast max 0.55;
    _initialRain = ((_initialOvercast - 0.5) * 2) max 0.2 min 1;
} else {
    if (_minimumOvercast < 0.6) then {
        _initialOvercast = _initialOvercast min (0.5 max _minimumOvercast);
        _initialRain = 0;
    };
};
0 setOvercast round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
if (_initialRain >= 0) then { 0 setRain _initialRain };
if (random 100 <= _fogProbability) then {
    _isFoggy = true;
    0 setFog [_initialFog, _initialFogDecay, _initialFogAltitude];
};
0 setWindForce round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
0 setWindDir _windDir;
0 setGusts round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
0 setWaves round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);

sleep 0.01;
forceWeatherChange;

if (WEATHER_DEBUG) then {
    ["INIT WEATHER SETTINGS: Overcast: %1, MinO: %2, MaxO: %3, RainProb: %4, Rain: %5, LightProb: %6, Lightning: %7, WindDir: %8, Wind: %9, WindSpeed: %10, FogP: %11, minFog: %12, maxFog: %13, Fog: %14, Fog Settings [%15, %16, %17], Decimal: %18, CycleVar: %19, Delay: %20",round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces), _minimumOvercast, _maximumOvercast, _rainProbability, rain, _lightningProbability, lightnings, _windDir, wind, _windSpeed, _fogProbability, _minimumFog, _maximumFog, _isFoggy, _initialFog, _initialFogDecay, _initialFogAltitude, _decimalplaces, _cycleVariance, _cycleDelay] call ALIVE_fnc_dump;
};


if (WEATHER_DEBUG) then { ["Module ALiVE_sys_weather WEATHER CHANGED! OVERCAST: %1, NEXTWEATHERCHANGE: %2", overcast, nextWeatherChange] call ALIVE_fnc_dump;};
// Now lets apply the first weather settings to the server and run the cycle delay in a new thread and launch the weathercycle function when delay complete.
[round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces), _rainProbability, _lightningProbability, _cycleDelay, _maximumOvercast, _fogProbability, _minimumOvercast, _windDir, _minimumFog, _maximumFog, _isFoggy, _initialFog, _initialFogDecay, _initialFogAltitude, _decimalplaces, _cycleVariance] spawn ALIVE_fnc_weatherServer;
