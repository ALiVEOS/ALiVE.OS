// ETHICS MINEFIELDS v1.8
// File: your_mission\ETHICSMinefields\fn_ETH_management.sqf
// by thy (@aldolammel)

// Runs only in server:
if (!isServer) exitWith {};


// PARAMETERS OF EDITOR'S OPTIONS:
ETH_debug = false;                  // true = shows crucial info only to hosted-server-player / false = turn it off. Detault: false
ETH_killzoneVisibleOnMap = true;   // true = The faction kill zone is visible on map only by its faction player / false = invisible for everyone. Defalt: true
	ETH_killzoneStyleColor = "ColorRed";   // color of minefields on map in-game. Default: "ColorRed"
	ETH_killzoneStyleBrush = "FDiagonal";  // texture of minefields on map in-game. Default: "FDiagonal"
	ETH_killzoneStyleAlpha = 1;        // 0.5 = Minefields barely invisible on the map / 1 = quite visible. Default: 1
ETH_doctrinesLandMinefield = true;     // true = landmines will spawn if an area-marker requests them / false = turn it off. Default: true
	ETH_ammoLandAP = "SPE_SMI_35_Pressure_MINE";      // Default: "APERSMine". For more device options, check the Ethics Documentation.
	ETH_ammoLandAM = "SPE_TMI_42_MINE";         // Default: "ATMine". For more device options, check the Ethics Documentation.
ETH_doctrinesNavalMinefield = false;    // true = naval mines will spawn if an area-marker requests them / false = turn it off. Default: false
	ETH_ammoNavalAM = "UnderwaterMineAB";  // Default: "UnderwaterMineAB". For more options, check the Ethics Documentation.
ETH_doctrinesOXU = false;                   // true = Unexploded bombs will spawn if an area-marker requests them / false = turn it off. Default: false
	ETH_ammoPackUXO = ["BombCluster_01_UXO2_F", "BombCluster_02_UXO4_F", "BombCluster_03_UXO1_F"];  // For more device options, check the Ethics Documentation.
	ETH_cosmeticSmokesUXO = true;      // true = adds few impact smoke sources into the UXO zones / false = turn it off. Default: true
ETH_doctrinesTraps = false;             // true = Traps will spawn if an area-marker requests them / false = turn it off. Default: false
	ETH_ammoTrapBT = "APERSTripMine";  // Default: "APERSTripMine". For more device options, check the Ethics Documentation.
ETH_globalDevicesIntensity = "MID";    // Proportional number of explosives through the area-markers. Options: "EXTREME", "HIGH", "MID", "LOW", "LOWEST". Default: "MID"
ETH_globalRulesEthics = false;          // true = script follows military conventions for choosing where to plant mines / false = mine has no ethics. Default: true
ETH_globalRulesTopography = false;      // true = script follows topography for choosing better where to plant mines / false = mines every terrains. Default: true
ETH_A3_dynamicSim = true;              // true = devices that are too far away from players will be frozen to save server performance / false = turn it off. Default: true
ETH_minesEditableByZeus = false;      // WIP / true = ETHICS explosive devices can be manipulated when Zeus is available / false = no editable. Detault: true


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------
publicVariable "ETH_debug"; publicVariable "ETH_killzoneVisibleOnMap"; publicVariable "ETH_killzoneStyleColor"; publicVariable "ETH_killzoneStyleBrush"; publicVariable "ETH_killzoneStyleAlpha"; publicVariable "ETH_doctrinesLandMinefield"; publicVariable "ETH_ammoLandAP"; publicVariable "ETH_ammoLandAM"; publicVariable "ETH_doctrinesNavalMinefield"; publicVariable "ETH_ammoNavalAM"; publicVariable "ETH_doctrinesOXU"; publicVariable "ETH_ammoPackUXO"; publicVariable "ETH_cosmeticSmokesUXO"; publicVariable "ETH_doctrinesTraps"; publicVariable "ETH_ammoTrapBT"; publicVariable "ETH_globalDevicesIntensity"; publicVariable "ETH_globalRulesEthics"; publicVariable "ETH_globalRulesTopography"; publicVariable "ETH_A3_dynamicSim"; /* publicVariable
"ETH_minesEditableByZeus"; */

[] spawn {
	
	private ["_txtDebugHeader", "_txtWarningHeader", "_txtWarning_3", "_deviceAmountsByDoctrine", "_kzAmountFaction", "_kzAmountUnknown", "_eachConfirmedList", "_kzSize", "_limiterDevicesKz", "_allDevicesPlantedAP", "_allDevicesDeletedAP", "_allDevicesPlantedAM", "_allDevicesDeletedAM", "_allDevicesPlantedUXO", "_allDevicesDeletedUXO", "_allDevicesPlantedTP", "_allDevicesDeletedTP","_totalDevicesDeleted", "_totalDevicesPlanted", "_balanceDevicesAP", "_balanceDevicesAM", "_balanceDevicesUXO", "_balanceDevicesTP", "_balanceDevicesTotal", "_balanceDevicesNoEthTotal"];
	
	// Debug txts:
	_txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_3 = "ammunition is empty at fn_ETH_management.sqf file. To fix the error, the script set automatically an ammunition to be used.";
	// Handling errors:
	if ( ETH_killzoneVisibleOnMap AND (ETH_killzoneStyleAlpha < 0.1) ) then { systemChat format ["%1 the mission has 'ETH_killzoneVisibleOnMap' configured as TRUE, but the 'ETH_killzoneStyleAlpha' was configured as invisible. Because of that, the script changed the 'ETH_killzoneStyleAlpha' value to 1 (quite visible).", _txtWarningHeader]; ETH_killzoneStyleAlpha = 1 };
	if ( ETH_doctrinesLandMinefield AND (ETH_ammoLandAP == "") ) then { ETH_ammoLandAP = "APERSMine"; systemChat format ["%1 The AP %2", _txtWarningHeader, _txtWarning_3]};
	if ( ETH_doctrinesLandMinefield AND (ETH_ammoLandAM == "") ) then { ETH_ammoLandAM = "ATMine"; systemChat format ["%1 The AM %2", _txtWarningHeader, _txtWarning_3]};
	if ( ETH_doctrinesNavalMinefield AND (ETH_ammoNavalAM == "") ) then { ETH_ammoNavalAM = "UnderwaterMineAB"; systemChat format ["%1 The NAM %2", _txtWarningHeader, _txtWarning_3]};
	if ( ETH_doctrinesOXU AND ((count ETH_ammoPackUXO) == 0) ) then { ETH_ammoPackUXO = ["BombCluster_01_UXO2_F", "BombCluster_02_UXO4_F", "BombCluster_03_UXO1_F"]; systemChat format ["%1 The UXO %2", _txtWarningHeader, _txtWarning_3]};
	if ( ETH_doctrinesTraps AND (ETH_ammoTrapBT == "") ) then { ETH_ammoTrapBT = "APERSTripMine"; systemChat format ["%1 The BT %2", _txtWarningHeader, _txtWarning_3]};
	if ( !ETH_doctrinesLandMinefield AND !ETH_doctrinesNavalMinefield AND !ETH_doctrinesOXU AND !ETH_doctrinesTraps ) then { 
		systemChat format ["%1 There's no any doctrine available at fn_ETH_management.sqf file. Turn some doctrine 'TRUE' to use Ethics Minefields script.", _txtWarningHeader];
	// If the basic is fine, the script starts:
	} else {
		// Kill zone name's structure:
		ETH_prefix = "killzone";  // CAUTION: NEVER include/insert the ETH_spacer character as part of the ETH_prefix too.
		ETH_spacer = "_";  // CAUTION: try do not change it, and never use "%"!
		publicVariable "ETH_prefix";
		publicVariable "ETH_spacer";
		// Initial values:            AP      AM      UXO     TP
		_deviceAmountsByDoctrine = [[0, 0], [0, 0], [0, 0], [0, 0]];  // [planted, deleted]
		ETH_confirmedKzMarkers = [];
		_limiterDevicesKz = [];
		_kzNameStructure = [];
		_kzAmountFaction = 0;
		_kzAmountUnknown = 0;
		// Search for all kill zone area-markers set by mission editor on Eden:
		ETH_confirmedKzMarkers = [ETH_prefix, ETH_spacer] call THY_fnc_ETH_marker_scanner;
		publicVariable "ETH_confirmedKzMarkers";  // after collecting the confirmed kill zones, finally declaring the public variable.
		

		// IT HAPPENS BEFORE THE BRIEFING SCREEN:
		// Converting specific area markers to kill zone:
		{  // forEach ETH_confirmedKzMarkers (part 1/2):
			_eachConfirmedList = _x;
			{  // forEach _eachConfirmedList:
				// Marker shape symmetry's consolidation:
				[_x, ETH_prefix, ETH_spacer] call THY_fnc_ETH_shape_symmetry;
			} forEach _eachConfirmedList;
		} forEach ETH_confirmedKzMarkers;

		// CAUTION: Never remove this sleep break!
		sleep 1;

		// IT HAPPENS AFTER THE MISSON STARTS:
		// Planting devices through the available kill zone:
		{  // forEach ETH_confirmedKzMarkers (part 2/2):
			_eachConfirmedList = _x;
			{  // forEach _eachConfirmedList:
				// Check kill zones' size after symmetry acted:
				_kzSize = markerSize _x;
				// Defining the explosive device' amount needed for each kill zone's size:
				_limiterDevicesKz = [ETH_globalDevicesIntensity, _kzSize] call THY_fnc_ETH_devices_intensity;  // returns the device amounts' limiters specific for kill zone.
				// Looking for factions tag on kill zone names:
				_kzNameStructure = [_x, ETH_prefix, ETH_spacer] call THY_fnc_ETH_marker_name_splitter;
				// Mine planter (slow process)
				_deviceAmountsByDoctrine = [_kzNameStructure, ETH_ammoLandAP, ETH_ammoLandAM, ETH_ammoNavalAM, ETH_ammoPackUXO, ETH_ammoTrapBT, _x, _kzSize, _limiterDevicesKz, _deviceAmountsByDoctrine] call THY_fnc_ETH_device_planter;  // returns the mines' numbers updated.
			} forEach _eachConfirmedList;
		} forEach ETH_confirmedKzMarkers;
		
		// Debug purposes:
		if ( ETH_debug ) then {
			sleep 1;  // It fixes a bug in the final calc when too much devices;
			systemChat format ["%1 > All confirmed kill zones are ready!", _txtDebugHeader];
			_kzAmountFaction = count (ETH_confirmedKzMarkers select 0);
			_kzAmountUnknown = count (ETH_confirmedKzMarkers select 1);
		};
		// Final balance:
		_allDevicesPlantedAP = (_deviceAmountsByDoctrine select 0) select 0;
		_allDevicesDeletedAP = (_deviceAmountsByDoctrine select 0) select 1;
		_allDevicesPlantedAM = (_deviceAmountsByDoctrine select 1) select 0;
		_allDevicesDeletedAM = (_deviceAmountsByDoctrine select 1) select 1;
		_allDevicesPlantedUXO = (_deviceAmountsByDoctrine select 2) select 0;
		_allDevicesDeletedUXO = (_deviceAmountsByDoctrine select 2) select 1;
		_allDevicesPlantedTP = (_deviceAmountsByDoctrine select 3) select 0;
		_allDevicesDeletedTP = (_deviceAmountsByDoctrine select 3) select 1;
		_balanceDevicesAP = abs (_allDevicesPlantedAP - _allDevicesDeletedAP);
		_balanceDevicesAM = abs (_allDevicesPlantedAM - _allDevicesDeletedAM);
		_balanceDevicesUXO = abs (_allDevicesPlantedUXO - _allDevicesDeletedUXO);
		_balanceDevicesTP = abs (_allDevicesPlantedTP - _allDevicesDeletedTP);
		_totalDevicesPlanted = _allDevicesPlantedAP + _allDevicesPlantedAM + _allDevicesPlantedUXO + _allDevicesPlantedTP;
		_totalDevicesDeleted = _allDevicesDeletedAP + _allDevicesDeletedAM + _allDevicesDeletedUXO + _allDevicesDeletedTP;
		_balanceDevicesTotal = abs (_totalDevicesPlanted - _totalDevicesDeleted);
		_balanceDevicesNoEthTotal = abs ((count allMines) - _balanceDevicesTotal);
		// Debug looping:
		while { ETH_debug } do {
			// CPU breath:
			sleep 5;
			// Debug monitor:
			[_kzAmountFaction, _kzAmountUnknown, _balanceDevicesAP, _balanceDevicesAM, _balanceDevicesUXO, _balanceDevicesTP, _balanceDevicesNoEthTotal] call THY_fnc_ETH_debug;
		};  // while ends.
	};
};  // spawn ends.
