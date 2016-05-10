
private ["_delay","_locality"];

	_delay = _this select 0;

		if (isServer) then {_locality = "SERVER"};
		if (hasInterface) then {_locality = "CLIENT"};

		while { (nextWeatherChange >= 0) } do {
			sleep _delay;		
			diag_log format["Module ALiVE_sys_weather [%2] OVERCAST: %3, NEXTWEATHERCHANGE IN: %4 SECONDS (%5 MINUTES)", missionName, _locality, overcast, nextWeatherChange, round((nextWeatherChange/60) * (10 ^ 2)) / (10 ^ 2)]; 				
		};
		
		
		