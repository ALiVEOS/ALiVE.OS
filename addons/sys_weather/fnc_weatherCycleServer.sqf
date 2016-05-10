
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_weatherCycleServer
Description:
Server side weather cycle

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

private ["_nextWeatherChangeSeconds","_nextWeatherChangeMinutes","_newFog","_newFogDecay","_newFogAltitude","_currentOvercast","_maximumOvercast","_minimumOvercast","_isHighend","_isLowend","_rainProbability","_fogProbability","_lightningProbability","_minimumOvercast","_windDir","_decimalplaces","_minimumFog","_isFoggy","_initialFog", "_initialFogDecay", "_initialFogAltitude","_currenthour","_newOvercast","_waiting","_cycleDelay","_cycle","_isRaining","_isLightning","_cycleVariance","_period","_firstCycle","_newWindDir"];
			 
			 _maximumOvercast = _this select 0;
			 _rainProbability = _this select 1;
			 _fogProbability = _this select 2;
			 _lightningProbability = _this select 3;
			 _minimumOvercast = _this select 4;
			 _windDir = _this select 5;
			 _minimumFog = _this select 6;
			 _maximumFog = _this select 7;
			 _isFoggy = _this select 8;
			 _initialFog = _this select 9; 
			 _initialFogDecay = _this select 10;
			 _initialFogAltitude = _this select 11;
			 _cycleDelay = _this select 12;
			 _decimalplaces = _this select 13;
			 _currentOvercast = round(overcast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
			 _cycleVariance = _this select 14;
			 _firstCycle = _this select 15;
			 _isHighend = false;
			 _isLowend = false;
			 _waiting = true;
			 _cycle  = true;
			 _isRaining = false;
			 _isLightning = false;
			 _newOvercast = 2;
				
						
				if (round((_currentOvercast) * (10 ^ 1)) / (10 ^ 1) >= _maximumOvercast - 0.1) then { _isHighend = true; };
				if (round((_currentOvercast) * (10 ^ 1)) / (10 ^ 1) <= _minimumOvercast + 0.1) then { _isLowend = true; };
				
			 	_currentdate = date;
			 	_currenthour = _currentdate select 3;
			 	
			 	

  if (WEATHER_DEBUG) then { 
         	 ["Module ALiVE_sys_weather CURRENT WEATHER DATA:  _MAXIMUMOVERCAST: %1 _MINIMUMOVERCAST: %2 _RAINPROBABILITY: %3 _FOGPROBABILITY: %4 _LIGHTNINGPROBABILITY: %5 _WINDDIR: %6 _CURRENTOVERCAST: %7 _CURRENTHOUR: %8 _ISHIGHEND: %9 _ISLOWEND: %10 _MINIMUMFOG: %11 _MAXIMUMFOG: %12 _ISFOGGY: %13 _INITIALFOG: %14 _INITIALFOGDECAY: %15 _INITIALFOGALTITUDE: %16, _FIRSTCYCLE: %18",_maximumOvercast, _minimumOvercast, _rainProbability, _fogProbability, _lightningProbability, _windDir, round(overcast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces), _currenthour, _isHighend, _isLowend, _minimumFog, _maximumFog, _isFoggy, _initialFog, _initialFogDecay, _initialFogAltitude, missionName, _firstCycle] call ALIVE_fnc_dump;
    }; 	 
			

				 _newFog = _minimumFog + (_maximumFog - _minimumFog) * random 0.05;
				 _newFogDecay = _newFog/10+random _newFog/100;
				 _newFogAltitude = random 150;
		
		
						while {_newOvercast > _maximumOvercast || _newOvercast < _minimumOvercast} do
						{
								if (_isHighend) then {
									_newOvercast = (overcast - (random _cycleVariance));  
								};
								if (_isLowend) then {
									_newOvercast = (overcast + (random _cycleVariance));  
								};
								if (!_isHighend && !_isLowend) then {	
									_seed = random 100;
									if (_seed >= 50) then { 
										_newOvercast = (overcast + random _cycleVariance); }
										 else {
										 _newOvercast = (overcast - random _cycleVariance);
									};
								};
						};
						
						
		
	
 					_period = WEATHER_CYCLE_DELAY;
				
					_period setOvercast round(_newOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
					
					if (random 100 <= _fogProbability) then { 
						_isFoggy = true;
						_period setFog [_newFog, _newFogDecay, _newFogAltitude];
					} else {
						_isFoggy = false;
						_period setFog [0,0,0];
					};
			
					_period setWindForce round(_newOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces); 
					_windDir = _windDir + random 45;
					_newWindDir = _windDir;
					_period setWindDir _windDir;
					_period setGusts round(_newOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
					_period setWaves round(_newOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);		

			
	
  if (WEATHER_DEBUG) then { 
         	 ["Module ALiVE_sys_weather NEW WEATHER DATA: _NEWOVERCAST SETTING: %2, OVERCAST: %3, _PERIOD: %4, _ISFOGGY: %5, _NEWFOG: %6, _NEWFOGDECAY: %7, _NEWFOGALTITUDE: %8, _WINDDIR: %9, _NEWWINDDIR: %10",missionName, round(_newOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces), round(overcast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces),_period, _isFoggy, _newFog, _newFogDecay, _newFogAltitude, _windDir, _newWindDir] call ALIVE_fnc_dump;
    }; 	 
			

	
	
				
						while { ( round(overcast * (10 ^ _decimalplaces)) != round((_newOvercast) * (10 ^ _decimalplaces))  && _cycle) } do {
							

			if (_waiting && WEATHER_DEBUG) then {
								hintSilent format["****************************\n Current overcast setting: \n%1\n Overcast target value:\n%2\n****************************", round(overcast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces), round(_newOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces)];
							};	
							
							
								if (round(overcast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces) == round(_newOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces) && _waiting) then {  // if _newOvercast value reached
									_waiting = false; 
									
									
						
	  if (WEATHER_DEBUG) then { 
	  	
	  		hintSilent format["****************************\n Weather cycle complete\n \n Current overcast setting: \n%1\n Overcast target value:\n%2\n Next cycle starts in:\n %3 seconds\n (%4 minutes)\n****************************", _currentOvercast,round(_newOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces),round(_cycleDelay),round(_cycleDelay)/60];
	  		
	  		
         	 ["Module ALiVE_sys_weather WEATHER CYCLE COMPLETE. LETS WAIT %1 SECONDS (%2 MINUTES) THEN SPAWN THE WEATHERCYCLE. OVERCAST: %3",round(_cycleDelay),round(_cycleDelay)/60,round(overcast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces)] call ALIVE_fnc_dump;
    }; 	 
    					
     
								   for "_i" from 0 to _cycleDelay step 1 do { sleep 1; };
								   
												[
												_maximumOvercast,  
												_rainProbability,  
												_fogProbability,  
												_lightningProbability, 
												_minimumOvercast,  
												_windDir, 
												_minimumFog,  
												_maximumFog, 
												_isFoggy, 
												_initialFog, 
												_initialFogDecay, 
												_initialFogAltitude,  
												_cycleDelay, 
												_decimalplaces,
												_cycleVariance,
												false
												] spawn ALIVE_fnc_weatherCycleServer;
								 _cycle = false; 
								};
							sleep 1;
						};
					
					
