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
		
	private["_cycleDelay","_waiting","_minimumFog","_decimalplaces","_isFoggy","_maximumFog","_initialFogDecay","_initialFogAltitude","_currentdate","_currenthour","_nextWeatherChangeSeconds","_nextWeatherChangeMinutes","_isRaining","_isLightning","_rainProbability","_fogProbability","_lightningProbability","_minimumOvercast","_maximumOvercast","_windDir","_cycleVariance", "_firstCycleDelay"];

					_initialOvercast = _this select 0;
					_rainProbability = _this select 1;
					_lightningProbability = _this select 2;
					_cycleDelay = _this select 3;
					_maximumOvercast = _this select 4;
					_fogProbability = _this select 5;
					_minimumOvercast = _this select 6;
					_windDir = _this select 7;
					_minimumFog = _this select 8;
					_maximumFog = _this select 9;
					_isFoggy = _this select 10;
					_initialFog = _this select 11;
					_initialFogDecay = _this select 12;
					_initialFogAltitude = _this select 13;
					_decimalplaces = _this select 14;
					_cycleVariance = _this select 15;
		
					_isRaining = false;
					_isLightning = false;
					_waiting = false;
					_firstCycle = true;

					_firstCycleDelay = 10;

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