{_x allowFleeing 0} forEach allUnits;

private ["_colorWest", "_colorEast"];
_colorWest = WEST call BIS_fnc_sideColor;
_colorEast = EAST call BIS_fnc_sideColor;
{_x set [3, 0.33]} forEach [_colorWest, _colorEast];

switch true do {
	
	//--- Default (Spin Scene)
	default {
		0 setFog [0.01, 0.06, 55];

		[
			[3290.19,2932.09,0],"",if (viewDistance < 1500) then {25} else {50},100,300,0,[
				["\a3\ui_f\data\map\markers\nato\b_recon.paa", _colorWest, BIS_BLU_group1, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\b_inf.paa", _colorWest, BIS_BLU_group2, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\b_inf.paa", _colorWest, BIS_BLU_group3, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\o_inf.paa", _colorEast, BIS_OP_group1, 1, 1, 0, "", 0],
				["\a3\ui_f\data\map\markers\nato\o_inf.paa", _colorEast, BIS_OP_group2, 1, 1, 0, "", 0]
			], 1] spawn BIS_fnc_establishingShot;

		waitUntil {!(isNil "BIS_fnc_establishingShot_playing")};

		sleep 3;

playMusic "ALiVE_Intro";
		addMusicEventHandler ["MusicStop", {[] spawn {sleep 12; playMusic "Track14_MainMenu"}}];
	};
};