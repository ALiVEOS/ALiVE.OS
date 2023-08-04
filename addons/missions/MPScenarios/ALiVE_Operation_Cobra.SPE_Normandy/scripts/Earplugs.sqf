/////////////////////////////////////////////////////////////////////////////////
//
// EarPlugs - part of PixeL_GaMMa library.
// Simulate having earplugs in, allowing you to hear radio over other noises
// Copyright (c) Colin J.D. Stewart. All rights reserved
// APL-ND License - https://www.bistudio.com/community/licenses/arma-public-license-nd
//
/////////////////////////////////////////////////////////////////////////////////

if (hasInterface) then {
	PX_fnc_earPlugsInsert = {
		PX_earPlugActive = true;
		1 fadeSound 0.2;	
		player removeAction PX_earPlugAction;
		hint "Ear plugs have been inserted!";
		PX_earPlugAction = player addAction [("<t color='#FF0000'>Remove Ear Plugs</t>"), {call PX_fnc_earPlugsRemove}, [], 1, false, true];
	};

	PX_fnc_earPlugsRemove = {
		PX_earPlugActive = false;
		1 fadeSound 1;
		player removeAction PX_earPlugAction;
		hint "Ear plugs have been removed!";
		PX_earPlugAction = player addAction [("<t color='#00FF00'>Insert Ear Plugs</t>"), {call PX_fnc_earPlugsInsert}, [], 1, false, true];	
	};

	PX_earPlugActive = false;
	player addEventHandler ["Respawn", {
		if (PX_earPlugActive) then {
			PX_earPlugAction = player addAction [("<t color='#FF0000'>Remove Ear Plugs</t>"), {call PX_fnc_earPlugsRemove}, [], 1, false, true];
		} else {
			PX_earPlugAction = player addAction [("<t color='#00FF00'>Insert Ear Plugs</t>"), {call PX_fnc_earPlugsInsert}, [], 1, false, true];
		};	
	}];
	player addEventHandler ["Killed", { player removeAction PX_earPlugAction; }];
};