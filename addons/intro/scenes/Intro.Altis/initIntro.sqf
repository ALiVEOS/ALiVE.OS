switch true do {

	//--- Thunderstorm
	case !(isnil {uinamespace getvariable "RscDisplayCurator_opened"}): {
		setdate [2035,7,16,18,45 + random 15];
		1 call bis_fnc_setovercast;
		0 setrain 1;
		0 setlightnings 0;
		0 setfog [0.05,0.07,70];
		"Mediterranean" call BIS_fnc_setPPeffectTemplate;

		_pos = [23562.354,21109.277,0.000];
		[
			_pos,						// Target position
			"",						// SITREP text
			70,						// Altitude
			150,						// Radius
			135,						// Viewing angle
			0,						// Movement direction
			[],
			1						// World scene mode
		] spawn BIS_fnc_establishingShot;

		waitUntil {!(isNil "BIS_fnc_establishingShot_playing")};

		sleep 3;

		0 fademusic 0.7;
playMusic "ALiVE_Intro";
		addMusicEventHandler ["MusicStop", {[] spawn {sleep 12; playMusic "Track14_MainMenu"}}];

		while {true} do {
			createagent ["ModuleLightning_F",_pos,[],100,"none"];
			sleep (15 + random 15);
		};
	};

	//--- Default (Research domes)
	default {
		[
			[16082.296,17004.082,0.000],			// Target position
			"",						// SITREP text
			300,						// Altitude
			150,						// 150m radius
			100,						// 100 degree viewing angle
			0,						// Counter-clockwise movement
			[],
			1						// World scene mode
		] spawn BIS_fnc_establishingShot;

		waitUntil {!(isNil "BIS_fnc_establishingShot_playing")};

		sleep 3;

playMusic "ALiVE_Bonus";
		addMusicEventHandler ["MusicStop", {[] spawn {sleep 12; playMusic "Track14_MainMenu"}}];
	};
};