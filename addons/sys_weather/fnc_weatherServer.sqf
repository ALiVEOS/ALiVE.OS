/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_weatherServer
Description:
Server side weather

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

if !(isServer) exitwith {};

private _initialOvercast = _this select 0;
private _rainProbability = _this select 1;
private _lightningProbability = _this select 2;
private _cycleDelay = _this select 3;
private _maximumOvercast = _this select 4;
private _fogProbability = _this select 5;
private _minimumOvercast = _this select 6;
private _windDir = _this select 7;
private _minimumFog = _this select 8;
private _maximumFog = _this select 9;
private _isFoggy = _this select 10;
private _initialFog = _this select 11;
private _initialFogDecay = _this select 12;
private _initialFogAltitude = _this select 13;
private _decimalplaces = _this select 14;
private _cycleVariance = _this select 15;

private _isRaining = false;
private _isLightning = false;
private _waiting = false;
private _firstCycle = true;

private _firstCycleDelay = 10;

while { (_firstCycle) } do {

      if (round(overcast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces) == round((_initialOvercast) * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces) && !_waiting) then {  // if _initialOvercast value reached
        _waiting = true;

        if (WEATHER_DEBUG) then {

            hintSilent format["****************************\n Initial Weather setting complete\n \n Current overcast setting: \n%1\n Overcast target value:\n%2\n Next cycle starts in:\n %3 seconds\n (%4 minutes)\n****************************", round(overcast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces),round((_initialOvercast) * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces),round(_firstCycleDelay),round(_firstCycleDelay)/60];

            ["Module ALiVE_sys_weather WEATHER CYCLE COMPLETE. LETS WAIT %1 SECONDS (%2 MINUTES) THEN SPAWN THE WEATHERCYCLE. OVERCAST: %3",round(_firstCycleDelay),round(_firstCycleDelay)/60,round(overcast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces)] call ALIVE_fnc_dump;
        };

        for "_i" from 0 to _firstCycleDelay step 1 do {  sleep 1; };

        [_maximumOvercast, _rainProbability, _fogProbability, _lightningProbability, _minimumOvercast, _windDir, _minimumFog, _maximumFog, _isFoggy, _initialFog, _initialFogDecay, _initialFogAltitude, _cycleDelay, _decimalplaces, _cycleVariance,true] spawn ALIVE_fnc_weatherCycleServer;
        _firstCycle = false;
    };
    sleep 1;
};