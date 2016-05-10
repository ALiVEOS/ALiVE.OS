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

	if !(isServer) exitwith {};

	private["_cycleDelay","_decimalplaces","_rainProbability","_fogProbability",
	"_lightningProbability","_minimumOvercast","_maximumOvercast","_currentdate",
	"_currenthour","_initialOvercast","_minimumFog","_maximumFog","_initialFog",
	"_initialFogDecay","_initialFogAltitude","_windDir","_isFoggy","_cycleVariance",
	"_currentmonth","_options","_realWeatherHash"];


if (isServer) then {};



         if (WEATHER_DEBUG) then {
         	 ["Module ALiVE_sys_weather SERVER STARTING"] call ALIVE_fnc_dump;
         	 ["Module ALiVE_sys_weather INITIAL_WEATHER: %1, WEATHER_CYCLE_DELAY: %2, WEATHER_CYCLE_VARIANCE: %3",INITIAL_WEATHER,WEATHER_CYCLE_DELAY,WEATHER_CYCLE_VARIANCE] call ALIVE_fnc_dump;
         };


             _currentdate = date;
						 _currenthour = _currentdate select 3;
             _currentmonth = _currentdate select 1;
						 _rainProbability = 0;
				     _fogProbability = 0;
						 _lightningProbability = 0;
						 
             // Random climate selector
             _options = [0,1,2,3];
					  if (INITIAL_WEATHER == 4)  then { INITIAL_WEATHER = _options call BIS_fnc_selectRandom; };


		         switch (INITIAL_WEATHER) do
							{

								case 0: {	//  Arid - A region that receives very little precipitation all year.
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
										  private ["_location","_weatherNote"];
										  _realWeatherHash = [WEATHER_CYCLE_REAL_LOCATION] call ALIVE_fnc_getWeather;
	
										  if (typename _realWeatherHash == "ARRAY") then {
	
	
											  // Apply real weather
	
											  	// For now just output to log :)
	
												_weatherNote = {
													diag_log format["%1 : %2", _key, _value];
												};
	
												diag_log format["--------------------------------- WEATHER IN %1 AT %2 ---------------------------------", WEATHER_CYCLE_REAL_LOCATION, date];
												[_realWeatherHash, _weatherNote] call CBA_fnc_hashEachPair;
											} else {
												diag_log format["--------------------------------- ERROR GETTING REAL WEATHER : %1", _realWeatherHash];
											};
	
	
												_minimumOvercast = 0; _maximumOvercast = 1;
	
								};
							
								case 6: {	};
							

							};
							
							
							_minimumFog = 0;
							_maximumFog = 0.5;

							 switch (WEATHER_OVERRIDE) do
							{
								case 0: {};  
								
								case 1: {  // clear
								  		_fogProbability = 0; 	_minimumOvercast = 0; _maximumOvercast = 0.40; 
								};  
								case 2: {  // overcast
								  	  _fogProbability = 0; 	_minimumOvercast = 0.60; _maximumOvercast = 0.85;
								};  
								case 3: {  // stormy
								  	   _fogProbability = 0; 	_minimumOvercast = 0.85; _maximumOvercast = 1; 
								};     
								case 4: {  // foggy
								  	   _fogProbability = 100; 	_minimumOvercast = 0.20; _maximumOvercast = 0.55;
								  	   _minimumFog = 0.28;
											 _maximumFog = 0.5;
								};     
							};
							
								_initialFog = (_minimumFog + random (_maximumFog - _minimumFog));
								_initialFogDecay = _initialFog/10+random _initialFog/100;
								_initialFogAltitude = random 150;
								
								_cycleVariance = WEATHER_CYCLE_VARIANCE;
								_cycleDelay = WEATHER_CYCLE_DELAY;
								_decimalplaces = 2;
								_initialOvercast = (_minimumOvercast + random (_maximumOvercast - _minimumOvercast));


								_windDir = random 360;
								_isFoggy = false;

								0 setOvercast round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces);
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

								if (WEATHER_DEBUG) then { ["Module ALiVE_sys_weather WEATHER CHANGED! OVERCAST: %1, NEXTWEATHERCHANGE: %2", overcast, nextWeatherChange] call ALIVE_fnc_dump;};


								// Now lets apply the first weather settings to the server and run the cycle delay in a new thread and launch the weathercycle function when delay complete.
								[round(_initialOvercast * (10 ^ _decimalplaces)) / (10 ^ _decimalplaces), _rainProbability, _lightningProbability, _cycleDelay, _maximumOvercast, _fogProbability, _minimumOvercast, _windDir, _minimumFog, _maximumFog, _isFoggy, _initialFog, _initialFogDecay, _initialFogAltitude, _decimalplaces, _cycleVariance] spawn ALIVE_fnc_weatherServer;







