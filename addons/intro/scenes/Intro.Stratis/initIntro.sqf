{_x allowFleeing 0} forEach allUnits;

private ["_colorWest", "_colorEast"];
_colorWest = WEST call BIS_fnc_sideColor;
_colorEast = EAST call BIS_fnc_sideColor;
{_x set [3, 0.33]} forEach [_colorWest, _colorEast];

switch true do {

	//--- Thunderstorm
	case !(isnil {uinamespace getvariable "RscDisplayCurator_opened"}): {
		setdate [2035,7,16,18,45 + random 15];
		1 call bis_fnc_setovercast;
		0 setrain 1;
		0 setlightnings 0;
		0 setfog [0.05,0.07,50];
		"Mediterranean" call BIS_fnc_setPPeffectTemplate;

		_pos = [5004.963,5909.859,0.000];

		//--- Move groups to the new position
		{
			_grpPos = if (side _x == east) then {
				[_pos,20,180 * _foreachindex] call bis_fnc_relpos
			} else {
				[_pos,150,-90 * _foreachindex] call bis_fnc_relpos
			};
			{
				_x setpos [_grpPos select 0,(_grpPos select 1) + _foreachindex,0];
			} foreach units _x;

			while {count waypoints _x > 0} do {deletewaypoint [_x,0]};
			_x addwaypoint [_pos,20];
		} foreach allgroups;


		[
			_pos,						// Target position
			"",						// SITREP text
			200,						// Altitude
			300,						// Radius
			75,						// Viewing angle
			1,						// Movement direction
			[
				["\a3\ui_f\data\map\markers\nato\b_recon.paa", _colorWest, BIS_BLU_group1, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\b_inf.paa", _colorWest, BIS_BLU_group2, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\b_inf.paa", _colorWest, BIS_BLU_group3, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\o_inf.paa", _colorEast, BIS_OP_group1, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\o_inf.paa", _colorEast, BIS_OP_group2, 1, 1, 0, "", 0]
			],
			1						// World scene mode
		] spawn BIS_fnc_establishingShot;

		waitUntil {!(isNil "BIS_fnc_establishingShot_playing")};

		sleep 3;

		0 fademusic 0.7;
playMusic "ALiVE_Intro";
		addMusicEventHandler ["MusicStop", {[] spawn {sleep 12; playMusic "Track14_MainMenu"}}];

		while {true} do {
			sleep (15 + random 15);
			createagent ["ModuleLightning_F",_pos,[],100,"none"];
		};
	};

	//--- Default (Research domes)
	default {
		0 setFog [0.01, 0.06, 55];

		[
			[6482.517,5266.367,0],				// Target position
			"",						// SITREP text
			if (viewDistance < 1500) then {400} else {600},	// Altitude
			200,						// 200m radius
			300,						// 300 degree viewing angle
			1,						// Clockwise movement
			[
				["\a3\ui_f\data\map\markers\nato\b_recon.paa", _colorWest, BIS_BLU_group1, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\b_inf.paa", _colorWest, BIS_BLU_group2, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\b_inf.paa", _colorWest, BIS_BLU_group3, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\o_inf.paa", _colorEast, BIS_OP_group1, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\o_inf.paa", _colorEast, BIS_OP_group2, 1, 1, 0, "", 0]
			],
			1						// World scene mode
		] spawn BIS_fnc_establishingShot;

		waitUntil {!(isNil "BIS_fnc_establishingShot_playing")};

		sleep 3;

playMusic "ALiVE_Intro";
		addMusicEventHandler ["MusicStop", {[] spawn {sleep 12; playMusic "Track14_MainMenu"}}];
	};
};