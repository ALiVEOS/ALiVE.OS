// ETHICS MINEFIELDS v1.9
// File: your_mission\ETHICSMinefields\fn_ETH_globalFunctions.sqf
// by thy (@aldolammel)


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------


THY_fnc_ETH_marker_name_splitter = {
	// This function splits the area-marker's name to check if the name has the basic structure for further validations.
	// Returns _kzNameStructure: array

	params ["_markerName", "_prefix", "_spacer"];
	private ["_txtWarningHeader", "_txtWarning_1", "_kzNameStructureRaw", "_kzNameStructure", "_spacerAmount"];

	// Debug txts:
	//_txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_1 = format ["If the intension is to make it a kill zone, its structure name must be '%1%2TagDoctrine%2TagFaction%2anynumber' or '%1%2TagDoctrine%2anynumber'.", _prefix, _spacer];
	// Initial values:
	_kzNameStructure = [];
	// check if the marker name has more than one _spacer character in its string composition:
	_kzNameStructureRaw = _markerName splitString "";
	_spacerAmount = count (_kzNameStructureRaw select {_x find _spacer isEqualTo 0});  // counting how many times the same character appers in a string.
	// if the _spacer is been used correctly:
	if ( (_spacerAmount >= 2) AND (_spacerAmount <= 4) ) then {
		// spliting the marker name to check its structure:
		_kzNameStructureRaw = _markerName splitString _spacer;
	// Otherwise, if the _spacer is NOT been used correctly:
	} else {
		// Warning message:
		systemChat format ["%1 Marker '%2' > You're not using or using too much the character '%3'. %4", _txtWarningHeader, _markerName, _spacer, _txtWarning_1];
	};
	// Updating to return, converting all strings to uppercase:
	{ _kzNameStructure append [toUpper _x] } forEach _kzNameStructureRaw;
	// Return:
	_kzNameStructure;
};


THY_fnc_ETH_marker_checker = {
	// This function checks if the marker is inside map borders.
	// Return _isValidMarker: bool.

	params ["_marker"];
	private ["_txtWarningHeader", "_isValidMarker", "_markerPos", "_markerPosA", "_markerPosB"];

	// Debug txts:
	_txtWarningHeader = "ETHICS WARNING >";
	// Initial values:
	_isValidMarker = false;
	// Checking the marker position:
	_markerPos = getMarkerPos _marker;
	_markerPosA = _markerPos select 0;
	_markerPosB = _markerPos select 1;
	// If marker is inside the map:
	if ( (_markerPosA >= 0) AND (_markerPosB >= 0) AND (_markerPosA <= worldSize) AND (_markerPosB <= worldSize) ) then {
		// Update to return:
		_isValidMarker = true;
	// Otherwise, if not on map area:
	} else {
		// Warning message:
		systemChat format ["%1 Marker '%2' > This is in an invalid position and will be ignored until its position is within the map borders.", _txtWarningHeader, _marker];
	};
	// Return:
	_isValidMarker;
};


THY_fnc_ETH_marker_scanner = {
	// This function searches and appends in a list all area-markers confirmed as a real kill zone. The searching take place once right at the mission begins.
	// Return: _confirmedKzMarkers: array [[area markers of factions], [area markers of unknown owner], [area markers of UXO]]

	params ["_prefix", "_spacer"];
	private ["_realPrefix", "_acceptableShapes", "_txtDebugHeader", "_txtWarningHeader", "_txtWarning_0", "_txtWarning_1", "_confirmedKzMarkers", "_confirmedKzUnknownMarkers", "_confirmedKzFactionMarkers", "_isValidMarker", "_possibleKzMarkers", "_kzNameStructure", "_kzDoctrine", "_kzFaction", "_isKzPresent", "_isNumber"];

	// Declarations:
	_realPrefix = _prefix + _spacer;
	_acceptableShapes = ["RECTANGLE", "ELLIPSE"];
	// Debug txts:
	_txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_0 = "This mission still has no possible kill zone(s) to be loaded.";
	_txtWarning_1 = format ["If the intension is to make it a kill zone, its structure name must be '%1%2TagDoctrine%2TagFaction%2anynumber' or '%1%2TagDoctrine%2anynumber'.", _prefix, _spacer];
	// Initial values:
	_confirmedKzMarkers = [];
	_confirmedKzUnknownMarkers = [];
	_confirmedKzFactionMarkers = [];
	_isValidMarker = false;

	// Step 1/2 > Creating a list with only area markers with right prefix:
	// Selecting the relevant markers in a slightly different way. Now searching for all marker shapes:
	_possibleKzMarkers = allMapMarkers select { _x find _realPrefix == 0 };
	// Validating each marker position and shape:
	{  // forEach _possibleKzMarkers:
		_isValidMarker = [_x] call THY_fnc_ETH_marker_checker;
		// If something wrong, remove the marker from the list and from the map:
		if ( !_isValidMarker OR !((markerShape _x) in _acceptableShapes) ) then {
			if ( !((markerShape _x) in _acceptableShapes) ) then { systemChat format ["%1 Marker '%2' > This kill zone has NO a rectangle or ellipse shape to be considered to be populated with explosive devices.", _txtWarningHeader, _x] };
			deleteMarker _x;
			_possibleKzMarkers deleteAt (_possibleKzMarkers find _x);
		};
	} forEach _possibleKzMarkers;
	// Error handling:
	if ( (count _possibleKzMarkers) == 0 ) exitWith { systemChat format ["%1 %2 %3", _txtWarningHeader, _txtWarning_0, _txtWarning_1] };

	// Step 2/2 > Ignoring from the first list those area-markers that don't fit the name's structure rules, and creating new lists:
	{  // forEach _possibleKzMarkers:
		// check if the marker name has more than one _spacer character in its string composition:
		_kzNameStructure = [_x, _prefix, _spacer] call THY_fnc_ETH_marker_name_splitter;
		// Case by case, check the valid marker name's amounts of strings:
		switch ( count _kzNameStructure ) do {
			// Case example: killzone_ap_1
			case 3: {
				// Check if the doctrine tag is correctly applied:
				_kzDoctrine = [_kzNameStructure, _x, true] call THY_fnc_ETH_marker_name_section_doctrine;
				// Check if the last section of the area marker name is numeric:
				_isNumber = [_kzNameStructure, _x, _prefix, _spacer] call THY_fnc_ETH_marker_name_section_number;
				// If all validations alright:
				if ( (_kzDoctrine != "") AND _isNumber ) then {
					// If is a non-faction kill zone marker:
					_confirmedKzUnknownMarkers append [_x];
				};
			};
			// Case example: killzone_ap_ind_1   or   killzone_ap_75%_1
			case 4: {
				// Check if the presence tag is correctly applied:
				_isKzPresent = [_kzNameStructure, _x, _spacer] call THY_fnc_ETH_marker_name_section_presence;  // if presence not valid, returns presence 100, otherwise the real probability.
				// if the area-marker did'nt spawn, abort and delete the marker from _possibleKzMarkers:
				if ( !_isKzPresent ) exitWith { 
					if ( ETH_debug ) then { systemChat format ["%1 Marker '%2' > The configured probability deleted the marker.", _txtDebugHeader, _x] };
				};
				// Check if the doctrine tag is correctly applied:
				_kzDoctrine = [_kzNameStructure, _x, true] call THY_fnc_ETH_marker_name_section_doctrine;  // if doctrine not valid, returns "", otherwise it returns the doctrine.
				// Check if the faction tag is correctly applied:
				_kzFaction = [_kzNameStructure, _x, true] call THY_fnc_ETH_marker_name_section_faction;  // if faction not valid, returns "", otherwise it returns the faction.
				// Check if the last section of the area-marker name is numeric:
				_isNumber = [_kzNameStructure, _x, _prefix, _spacer] call THY_fnc_ETH_marker_name_section_number;
				// If all validations alright:
				if ( (_kzDoctrine != "") AND (_kzDoctrine != "UXO") AND (_kzFaction != "") AND _isNumber ) then {
					// add this kill zone in the right array:
					_confirmedKzFactionMarkers append [_x];
				// Otherwise:
				} else {
					// If the doctrine is ON in management file and the kill zone doctrine is alright, add the kill zone in unknown list:
					if ( ETH_doctrinesLandMinefield AND (_kzDoctrine != "") ) then { _confirmedKzUnknownMarkers append [_x] };
					if ( ETH_doctrinesNavalMinefield AND (_kzDoctrine != "") ) then { _confirmedKzUnknownMarkers append [_x] };
					if ( ETH_doctrinesTraps AND (_kzDoctrine != "") ) then { _confirmedKzUnknownMarkers append [_x] };
					if ( ETH_doctrinesOXU AND (_kzDoctrine != "") ) then { _confirmedKzUnknownMarkers append [_x] };
				};
			};
			// Case example: killzone_ap_ind_75%_1
			case 5: {
				// Check if the presence tag is correctly applied:
				_isKzPresent = [_kzNameStructure, _x, _spacer] call THY_fnc_ETH_marker_name_section_presence;  // if presence not valid, returns presence 100, otherwise the real probability.
				// if the area-marker did'nt spawn, abort and delete the marker from _possibleKzMarkers:
				if ( !_isKzPresent ) exitWith { 
					if ( ETH_debug ) then { systemChat format ["%1 Marker '%2' > The configured probability deleted the marker.", _txtDebugHeader, _x] };
				};
				// Check if the doctrine tag is correctly applied:
				_kzDoctrine = [_kzNameStructure, _x, true] call THY_fnc_ETH_marker_name_section_doctrine;  // if doctrine not valid, returns "", otherwise it returns the doctrine.
				// Check if the faction tag is correctly applied:
				_kzFaction = [_kzNameStructure, _x, true] call THY_fnc_ETH_marker_name_section_faction;  // if faction not valid, returns "", otherwise it returns the faction.
				// Check if the last section of the area-marker name is numeric:
				_isNumber = [_kzNameStructure, _x, _prefix, _spacer] call THY_fnc_ETH_marker_name_section_number;
				// If all validations alright:
				if ( (_kzDoctrine != "") AND (_kzDoctrine != "UXO") AND (_kzFaction != "") AND _isNumber ) then {
					// add this kill zone in the right array:
					_confirmedKzFactionMarkers append [_x];
				// Otherwise:
				} else {
					// If the doctrine is ON in management file and the kill zone doctrine is alright, add the kill zone in unknown list:
					if ( ETH_doctrinesLandMinefield AND (_kzDoctrine != "") ) then { _confirmedKzUnknownMarkers append [_x] };
					if ( ETH_doctrinesNavalMinefield AND (_kzDoctrine != "") ) then { _confirmedKzUnknownMarkers append [_x] };
					if ( ETH_doctrinesTraps AND (_kzDoctrine != "") ) then { _confirmedKzUnknownMarkers append [_x] };
					if ( ETH_doctrinesOXU AND (_kzDoctrine != "") ) then { _confirmedKzUnknownMarkers append [_x] };
				};
			};
		};
	} forEach _possibleKzMarkers;
	// Updating the general list to return:
	_confirmedKzMarkers = [_confirmedKzFactionMarkers, _confirmedKzUnknownMarkers];
	// Debug messages:
	if ( ETH_debug ) then {
		// If at least one faction area-marker was confirmed, show the message:
		if ( (count _confirmedKzFactionMarkers) > 0 ) then { 
			systemChat format ["%1 Faction kill zone(s) ready to get explosives: %2", _txtDebugHeader, _confirmedKzFactionMarkers];
		};
		// If at least one unknown area-marker was confirmed, show the message:
		if ( (count _confirmedKzUnknownMarkers) > 0 ) then {
			systemChat format ["%1 Unknown kill zone(s) ready to get explosives: %2", _txtDebugHeader, _confirmedKzUnknownMarkers];
		};
	};
	// Returning:
	_confirmedKzMarkers;
};


THY_fnc_ETH_available_doctrines = {
	// This function just checks and returns which doctrines are available for the mission.
	// Returns _allDoctrinesAvailable: array ["each string is a tag of available doctrine"]

	params ["_isOnDoctLandMinefields", "_isOnDoctNavalMinefields", "_isOnDoctUXO", "_isOnDoctTraps"];
	private ["_doctLandMinefields", "_doctNavalMinefields", "_doctUXO", "_doctTraps", "_allDoctAvailable"];

	// Initial values:
	_doctLandMinefields = [];
	_doctNavalMinefields = [];
	_doctUXO = [];
	_doctTraps = [];
	// Checking the available doctrines:
	if ( _isOnDoctLandMinefields ) then { _doctLandMinefields = ["AP", "AM", "LAM", "HY", "LHY"] };
	if ( _isOnDoctNavalMinefields ) then { _doctNavalMinefields = ["NAM"] };
	if ( _isOnDoctUXO ) then { _doctUXO = ["UXO"] };
	if ( _isOnDoctTraps ) then { _doctTraps = ["BT"] };
	// Merging all available doctrines to return:
	_allDoctrinesAvailable = _doctLandMinefields + _doctNavalMinefields + _doctUXO + _doctTraps;
	// Error handling:
	// It's in fn_ETH_management.sqf to stop the script as soon as possible if no doctrines are activated;
	// Return:
	_allDoctrinesAvailable;
};



THY_fnc_ETH_marker_name_section_doctrine = {
	// This function checks the second section (mandatory) of the area marker's name, validating if the section is a valid ammunition doctrine and if its doctrine is ON in management file.
	// Returns _kzDoctrine: when valid, doctrine tag as string. When invalid, an empty string ("").

	params ["_kzNameStructure", "_kz", "_isServerRequest"];
	private ["_txtWarningHeader", "_allDoctrinesAvailable", "_kzDoctrine"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	// Checking the available doctrines:
	_allDoctrinesAvailable = [ETH_doctrinesLandMinefield, ETH_doctrinesNavalMinefield, ETH_doctrinesOXU, ETH_doctrinesTraps] call THY_fnc_ETH_available_doctrines;
	_kzDoctrine = _kzNameStructure select 1;  // if mission editor doesn't typed uppercase, this fixes it.
	if ( !(_kzDoctrine in _allDoctrinesAvailable) ) then {
		// When feedback off, the message doesnt duplicate for mission editor (because the function also is called by LocalPlayer and not only in server side):
		if ( _isServerRequest ) then {
			systemChat format ["%1 Marker '%2' > The doctrine tag looks wrong. There's no any '%3' doctrine available. Fix the marker variable name or check the available doctrines on fn_ETH_management.sqf.", _txtWarningHeader, _kz, _kzDoctrine];
		};
		_kzDoctrine = "";
	}; 
	// Return:
	_kzDoctrine;
};


THY_fnc_ETH_presence_percentage_checker = {
	// This function takes the presence tag and convert it to an integer percentage for further validations.
	// Returns _realPercentage: integer.

	params ["_kz", "_kzPresence", "_spacer"];
	private ["_txtWarningHeader", "_txtWarning_6", "_txtWarning_7", "_sectionChecker", "_stringNumbersMerged", "_itShouldBeNumeric", "_realPercentage"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_6 = format ["Marker '%1' > Percentage tag looks wrong ('%3%2%3').", _kz, _kzPresence, _spacer];
	_txtWarning_7 = "To handle the error, the script will ignore this Presence Tag.";
	// Initial values:
	_stringNumbersMerged = "";
	_realPercentage = 100;
	// Declarations:
	_sectionChecker = _kzPresence splitString "";
	// Is there the percentage character:
	if ( "%" in _sectionChecker ) then {
		// So delete it from the list to isolated that supposed to be just numbers:
		_sectionChecker deleteAt (_sectionChecker find "%");
		// If has no numbers in presence section, warning the editor:
		if ( (count _sectionChecker) == 0 ) then {
			systemChat format ["%1 %2", _txtWarningHeader, _txtWarning_6];
		// Otherwise, check the numbers:
		} else {
			// if more than one string, merge them, otherwise, keep going:
			if ( (count _sectionChecker) > 1 ) then { _stringNumbersMerged = _sectionChecker joinString "" } else { _stringNumbersMerged = _sectionChecker select 0 };	
			// Converting from string to integer:
			_itShouldBeNumeric = parseNumber _stringNumbersMerged;  // result will be a number extracted from string OR ZERO if inside the string has no numbers.
			// if the conversion works:
			if ( _itShouldBeNumeric != 0 ) then {
				// if the number is between 0 and 100, keep going:
				if ( _itShouldBeNumeric >= 1 AND _itShouldBeNumeric <= 100 ) then {
					// Convert a possible float number to integer:
					_realPercentage = round _itShouldBeNumeric;
				// Otherwise warning alert:
				} else { systemChat format ["%1 %2 You must use a number between 1 and 100. %3", _txtWarningHeader, _txtWarning_6, _txtWarning_7] };
			// if the conversion fails, warning alert:
			} else { systemChat format ["%1 %2 %3", _txtWarningHeader, _txtWarning_6, _txtWarning_7] };
		};
	};
	// Return:
	_realPercentage;
};


THY_fnc_ETH_marker_name_section_presence = {
	// This function checks the optional section of the area marker's name, calculation the kill zone's probability to be available in-game.
	// Returns _isKzPresent: bool.

	params ["_kzNameStructure", "_kz", "_spacer"];
	private ["_txtWarningHeader", "_isKzPresent", "_kzPresence", "_sectionsAvailable", "_realPercentage"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	// Initial values:
	_isKzPresent = true;
	_kzPresence = "";
	// Declarations:
	_sectionsAvailable = count (_kzNameStructure);

	switch ( _sectionsAvailable ) do {
		// Example: killzone_AP_75%_1
		case 4: {
			_kzPresence = _kzNameStructure select 2;
			_realPercentage = [_kz, _kzPresence, _spacer] call THY_fnc_ETH_presence_percentage_checker;
		};
		// Example: killzone_AP_blu_75%_1
		case 5: {
			_kzPresence = _kzNameStructure select 3;
			_realPercentage = [_kz, _kzPresence, _spacer] call THY_fnc_ETH_presence_percentage_checker;
		};
	};
	// Calculationg the probability of the kill zone to be present in-game:
	if ( _realPercentage < (random 100) ) then {
		// delete the marker (only for security):
		deleteMarker _kz;
		// Update to return:
		_isKzPresent = false;
	};
	// Return:
	_isKzPresent;
};


THY_fnc_ETH_marker_name_section_faction = {
	// This function checks the optional section of the area marker's name, validating if the section is a valid faction.
	// Returns _kzFaction: when valid, faction tag as string. When invalid, an empty string ("").

	params ["_kzNameStructure", "_kz", "_isServerRequest"];
	private ["_txtWarningHeader", "_kzDoctrine", "_kzFaction", "_thirdSectionChecker"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	// Declarations:
	_kzDoctrine = _kzNameStructure select 1;
	_kzFaction = _kzNameStructure select 2;
	// Handling errors > if Presence section, abort the function:
	_thirdSectionChecker = _kzFaction splitString "";
	if ( "%" in _thirdSectionChecker ) exitWith {
		// Updationg before to return:
		_kzFaction = "";
		// Return:
		_kzFaction;
	};
	// Handling errors > if UXO doctrine, abort the function:
	if ( _kzDoctrine == "UXO" ) exitWith {
		// When feedback off, the message doesnt duplicate for mission editor (because the function also is called by LocalPlayer and not only in server side):
		if ( _isServerRequest ) then {
			systemChat format ["%1 Marker '%2' > %3 doctrine has its zones always unknown, so you CANNOT use a faction tag ('%4'). For logic reasons, the script is ignoring the faction tag.", _txtWarningHeader, _kz, _kzDoctrine, _kzFaction];
		};
		// Updationg before to return:
		_kzFaction = "";
		// Return:
		_kzFaction;
	};
	// Faction validation:
	if ( !(_kzFaction in ["BLU", "OPF", "IND"]) ) then {
		// When feedback off, the message doesnt duplicate for mission editor (because the function also is called by LocalPlayer and not only in server side):
		if ( _isServerRequest ) then {
			systemChat format ["%1 Marker '%2' > The faction tag looks wrong. There's no '%3' option. For this kill zone owner, it was changed to unknown.", _txtWarningHeader, _kz, _kzFaction];
		};
		// Updationg before to return:
		_kzFaction = "";
	};
	// Return:
	_kzFaction;
};


THY_fnc_ETH_marker_name_section_number = {
	// This function checks the last section (mandatory) of the area marker's name, validating if the section is numeric;
	// Returns _isNumber: bool.

	params ["_kzNameStructure", "_kz", "_prefix", "_spacer"];
	private ["_txtWarningHeader", "_txtWarning_1", "_isNumber", "_index", "_itShouldBeNumeric"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_1 = format ["If the intension is to make it a kill zone, its structure name must be '%1%2TagDoctrine%2TagFaction%2anynumber' or '%1%2TagDoctrine%2anynumber'.", _prefix, _spacer];
	// Initial values:
	_isNumber = false;
	_index = nil;
	// Number validation:
	if ( (count _kzNameStructure) == 3 ) then { _index = 2 };  // it's needed because marker names can have 3, 4 or 5 sections, depends if the Faction tag is been used and Presence tag.
	if ( (count _kzNameStructure) == 4 ) then { _index = 3 };
	if ( (count _kzNameStructure) == 5 ) then { _index = 4 };
	_itShouldBeNumeric = parseNumber (_kzNameStructure select _index);  // result will be a number extracted from string OR ZERO if inside the string has no numbers.
	if ( _itShouldBeNumeric != 0 ) then { _isNumber = true } else { systemChat format ["%1 Marker '%2' > It has no a valid name. %3", _txtWarningHeader, _kz, _txtWarning_1] };
	// Return:
	_isNumber;
};


THY_fnc_ETH_shape_symmetry = {
	// This function checks the area shape symmetry of the kill zone built by the Mission Editor through Eden. It's important to make the work of THY_fnc_ETH_device_planter easier.
	// Returns nothing.

	params ["_kz", "_prefix", "_spacer"];
	private ["_txtWarningHeader", "_kzNameStructure", "_kzDoctrine", "_radiusMin", "_radiusMax", "_kzWidth", "_kzHeight"];

	// Debug txts:
	_txtWarningHeader = "ETHICS WARNING >";
	// check if the marker name structure:
	_kzNameStructure = [_kz, _prefix, _spacer] call THY_fnc_ETH_marker_name_splitter;
	// Declarations:
	_kzDoctrine = _kzNameStructure select 1;
	_radiusMin = 25;
	_radiusMax = 2500;
	if ( _kzDoctrine == "BT" ) then { _radiusMax = 500 };  // CAUTION: BT doctrine uses nearestObject searching in this area, so that demands too much of server CPU.
	// Kill zone dimensions:
	_kzWidth = markerSize _kz select 0;
	_kzHeight = markerSize _kz select 1;
	// If the kill zone marker shape is not symmetric, do it:
	if ( _kzWidth != _kzHeight ) then {
		// Make the kill zone symmetric:
		_kz setMarkerSize [_kzWidth, _kzWidth];
		// Alert the mission editor:
		systemChat format ["%1 Marker '%2' > It was resized to has its shape symmetric (mandatory).", _txtWarningHeader, _kz];
	};
	// If the kill zone's radius is smaller than the minimal OR bigger than the maximum, do it:
	if ( (_kzWidth < _radiusMin) OR (_kzWidth > _radiusMax) ) then {
		// If smaller, do it:
		if (_kzWidth < _radiusMin) then { 
			// set the radius the minal value:
			_kz setMarkerSize [_radiusMin, _radiusMin];
			// Alarm message:
			systemChat format ["%1 Marker '%2' > For %3 doctrine, it was needed to increase the area-marker's size to the minimum radius (%4).", _txtWarningHeader, _kz, _kzDoctrine, _radiusMin];
		// Otherwise, if equal or bigger:
		} else {
			// the maximum value:
			_kz setMarkerSize [_radiusMax, _radiusMax];
			// Alarm message:
			systemChat format ["%1 Marker '%2' > For %3 doctrine, it was needed to decrease the area-marker's size to the maximum radius (%4).", _txtWarningHeader, _kz, _kzDoctrine, _radiusMax];
		};
	};
	// Return:
	true;
};


THY_fnc_ETH_devices_intensity = {
	// This function controls the number of explosive devices for each kill zone and UXO, based on its area's size and general intensity level chosen, setting different amount limits to be planted through each area-marker.
	// Returns _limitersByDeviceDoctrine: array [AP amount limiter, AM amount limiter, UXO amout limiter, TP amout limiter]

	params ["_intensity", "_kzSize"];
	private ["_txtWarningHeader", "_limitersByDeviceDoctrine", "_limiterDevices", "_kzRadius", "_kzArea"];

	// Debug txts:
	//private _txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	// Handling errors:
	_intensity = toUpper _intensity;
	if ( !(_intensity in ["EXTREME", "HIGH", "MID", "LOW", "LOWEST"]) ) then {
		systemChat format ["%1 fn_ETH_management.sqf > check the INTENSITY configuration. There's no any '%2' option. To avoid this error, the intensity was changed to 'MID'.", _txtWarningHeader, _intensity];
		_intensity = "MID";
	};
	// Initial values:
	_limitersByDeviceDoctrine = [];
	_limiterDevices = 0;
	// Basic area calcs:
	_kzRadius = _kzSize select 0;  // 40.1234
	_kzArea = pi * (_kzRadius ^ 2);  // 5600.30
	// Case by case, do it:
	switch ( _intensity ) do {
		case "EXTREME": {
			_limiterDevices = round ((sqrt _kzArea) * 2);
			_limitersByDeviceDoctrine = [ _limiterDevices, round (_limiterDevices / 1.5), round (_limiterDevices / 40), round (_limiterDevices / 65) ];  // [AP, AM, UXO, TP]
		};
		case "HIGH": {
			_limiterDevices = round (sqrt _kzArea);
			_limitersByDeviceDoctrine = [ _limiterDevices, round (_limiterDevices / 1.5), round (_limiterDevices / 40), round (_limiterDevices / 60)] ;  // [AP, AM, UXO, TP]
		};
		case "MID": {
			_limiterDevices = round ((sqrt _kzArea) / 2);
			_limitersByDeviceDoctrine = [ _limiterDevices, round (_limiterDevices / 1.5), round (_limiterDevices / 40), round (_limiterDevices / 55) ];  // [AP, AM, UXO, TP]
		};
		case "LOW": {
			_limiterDevices = round ((sqrt _kzArea) / 6);
			_limitersByDeviceDoctrine = [ _limiterDevices, round (_limiterDevices / 1.5), round (_limiterDevices / 40), round (_limiterDevices / 50) ];  // [AP, AM, UXO, TP]
		};
		case "LOWEST": {
			_limiterDevices = round ((sqrt _kzArea) / 10);
			_limitersByDeviceDoctrine = [ _limiterDevices, round (_limiterDevices / 1.5), round (_limiterDevices / 40), round (_limiterDevices / 45) ];  // [AP, AM, UXO, TP]
		};
	};
	// return:
	_limitersByDeviceDoctrine;
};


THY_fnc_ETH_no_mine_topography = {
	// This function defines all topography features where a mine SHOULD avoid to be planted for another function. More about topography features on: https://community.bistudio.com/wiki/Location
	// Returns _noMineZonesTopography: array

	params ["_kzDoctrine", "_subdoctrine", "_devicePos"];
	private ["_noMineZones"];

	// Initial values:
	_noMineZonesTopography = [];
	// Basic validation:
	if ( (!ETH_globalRulesTopography) OR (_kzDoctrine == "UXO") OR (_kzDoctrine == "BT") OR (_kzDoctrine == "LAM") OR (_subdoctrine == "LAM") ) exitWith { _noMineZonesTopography /*Returning*/ };
	// Topography features:
	_noMineZonesTopography = [
		nearestLocation [_devicePos, "RockArea"],    // index 0
		nearestLocation [_devicePos, "Hill"],        // index 1
		nearestLocation [_devicePos, "Mount"]        // index 2
	];
	// Return:
	_noMineZonesTopography;
};


THY_fnc_ETH_no_mine_ethics = {
	// This function defines all civilian locations where a mine SHOULD avoid to be planted for another function. More about locations on: https://community.bistudio.com/wiki/Location
	// Returns _noMineZonesEthics: array

	params ["_kzDoctrine", "_subdoctrine", "_devicePos"];
	private ["_noMineZones"];

	// Initial values:
	_noMineZonesEthics = [];
	// Basic validation:
	if ( (!ETH_globalRulesEthics) OR (_kzDoctrine == "UXO") ) exitWith { _noMineZonesEthics /*Returning*/ };
	// Civilian zones:
	_noMineZonesEthics = [
		nearestLocation [_devicePos, "NameVillage"],      // index 0
		nearestLocation [_devicePos, "nameCity"],         // index 1
		nearestLocation [_devicePos, "NameCityCapital"],  // index 2
		nearestLocation [_devicePos, "NameLocal"]         // index 3
	];
	// Return:
	_noMineZonesEthics;
};


THY_fnc_ETH_inspection = {
	// This function ensures that each explosive device placed respects the previously configured doctrine, deleting the mines that doesn't follow doctrine rules, nor global rules when available.
	// Returns _wasDeviceDeleted: bool

	params ["_device", "_devicePos", "_hybridSubdoctrine", "_kzDoctrine", "_isNaval"];
	private ["_wasDeviceDeleted", "_noMineZonesTopography", "_noMineZonesEthics"];

	// Initial values:
	_wasDeviceDeleted = false;
	_noMineZonesTopography = [];
	_noMineZonesEthics = [];
	// If UXO, just get out:
	if ( _kzDoctrine == "UXO" ) exitWith { _wasDeviceDeleted /*returning*/ };  // 'cause all UXO devices will be dropped, with no rules, even in water.
	// Global Rules checker:
	_noMineZonesTopography = [_kzDoctrine, _hybridSubdoctrine, _devicePos] call THY_fnc_ETH_no_mine_topography;
	_noMineZonesEthics = [_kzDoctrine, _hybridSubdoctrine, _devicePos] call THY_fnc_ETH_no_mine_ethics;
	// If some LAND doctrine:
	if ( !_isNaval ) then {
		// General land device rules > Never be planted in the water:
		if ( ((getPosASLW _device) select 2) < 0.2 ) then {  // 'select 2' = Z axis.
			// Delete the device if some rule is broken, and report it:
			deleteVehicle _device; _wasDeviceDeleted = true;
		};
		// General land device rules > if device not deleted and topography rules true, and topography returned with at least one element in its array:
		if ( !_wasDeviceDeleted AND ETH_globalRulesTopography AND ((count _noMineZonesTopography) > 0) ) then {
			if ( ((_devicePos distance (_noMineZonesTopography select 0)) < 80) /*OR ((_devicePos distance (_noMineZonesTopography select 1)) < 100)*/ OR ((_devicePos distance (_noMineZonesTopography select 2)) < 80) ) then {
				// Delete the device if some rule is broken, and report it:
				deleteVehicle _device; _wasDeviceDeleted = true;
			};
		}; 
		// General land device rules > if device not deleted and Ethics rules true, and ethics returned with at least one element in its array:
		if ( !_wasDeviceDeleted AND ETH_globalRulesEthics AND ((count _noMineZonesEthics) > 0)) then {
			if ( ((_devicePos distance (_noMineZonesEthics select 0)) < 200) OR ((_devicePos distance (_noMineZonesEthics select 1)) < 200) OR ((_devicePos distance (_noMineZonesEthics select 2)) < 200) OR ((_devicePos distance (_noMineZonesEthics select 3)) < 100) ) then {
				// Delete the device if some rule is broken, and report it:
				deleteVehicle _device; _wasDeviceDeleted = true;
			};
		};
		// If not deleted yet:
		if ( !_wasDeviceDeleted ) then {
			// AP land device rules only > if device not deleted and AP is on road:
			if ( (_kzDoctrine == "AP") OR (_hybridSubdoctrine == "AP") ) then {
				// if AP over the roads, delete the device, and report it:
				if ( isOnRoad _devicePos ) then { deleteVehicle _device; _wasDeviceDeleted = true };
			};
			// LAM land device rules only > if device not deleted and LAM is NOT on road:
			if ( (_kzDoctrine == "LAM") OR (_hybridSubdoctrine == "LAM") ) then {
				// if LAM out of the roads, delete the device, and report it:
				if ( !(isOnRoad _devicePos) ) then { deleteVehicle _device; _wasDeviceDeleted = true };
			};
			// BT land device rules only > if device not deleted and BT is on road:
			if ( (_kzDoctrine == "BT") AND (isOnRoad _devicePos) ) then {
				// Delete the device if some rule is broken, and report it:
				deleteVehicle _device; _wasDeviceDeleted = true;
			};
		};
	// If some NAVAL doctrine:
	} else {
		// General naval device rules > Never be planted on terrain:
		if ( !(surfaceIsWater _devicePos) ) then {
			// Delete the device if some rule is broken, and report it:
			deleteVehicle _device; _wasDeviceDeleted = true;
		};
	};
	// return:
	_wasDeviceDeleted;
};


THY_fnc_ETH_cosmetic_grass_remover = {
	// This function just removes the grass around a specific object when the object is not under the water.
	// Returns nothing.

	params ["_objPos"];
	private ["_grassRemover"];

	// Initial values:
	_grassRemover = objNull;
	// if the GrassRemover position is in the water, the creation of this grass-remover is canceled:
	if ( ((ATLToASL _objPos) select 2) < 0.2 ) exitWith {};  // 'select 2' = Z axis.
	// if NOT under the water, do it:
	_grassRemover = "Tarp_01_Large_Black_F" createVehicle _objPos;
	// After remove the grass, hide the object:
	if ( isMultiplayer ) then { _grassRemover hideObjectGlobal true } else { _grassRemover hideObject true };
	// Return:
	true;
};

THY_fnc_ETH_cosmetic_UXO_impact_fail = {
	// This function decorates unexploded bombs' impacts.
	// Return nothing.

	params ["_devicePos"];

	// if the impact position is in the water, the current creation is canceled:
	if ( ((ATLToASL _devicePos) select 2) < 0.2 ) exitWith {};  // 'select 2' = Z axis.
	// Crater decoration:
	"Land_ShellCrater_01_F" createVehicle _devicePos;
	"Land_ShellCrater_02_debris_F" createVehicle _devicePos;
	// return:
	true;
};


THY_fnc_ETH_cosmetic_UXO_impact_area = {
	// This function just creates a fake bomb impact area in a limited area pre-configured. Smoke templates: https://community.bistudio.com/wiki/Particles_Tutorial#Full_examples
	// Returns nothing.

	params ["_kzPos", "_kzRadius"];
	private ["_smokePos", "_smokePosASL", "_smoke", "_grassRemover", "_terrainObjects"];

	// Generate a random position inside a circle:
	_smokePos = _kzPos getPos [_kzRadius * sqrt random 1, random 360];
	_smokePosASL = ATLToASL _smokePos;
	// if the smoke position is in the water, the current impact area creation is canceled:
	if ( (_smokePosASL select 2) < 0.2 ) exitWith {};  // 'select 2' = Z axis.
	// This remove the grass around:
	[_smokePos] call THY_fnc_ETH_cosmetic_grass_remover;
	// Crater decoration:
	//"Land_Decal_ScorchMark_01_small_F" createVehicle _smokePos;
	"Land_ShellCrater_01_F" createVehicle _smokePos;
	"Land_ShellCrater_02_debris_F" createVehicle _smokePos;
	// Remove all selected terrain objects from around the impact area:
	_terrainObjects = nearestTerrainObjects [_smokePosASL, ["FENCE", "TREE", "SMALL TREE", "BUSH", "WALL"], 2, false];  // [position ASL, [types], radius, sort, 2Dmode]
	{  // forEach _terrainObjects:
		if ( isMultiplayer ) then { _x hideObjectGlobal true } else { _x hideObject true };
	} forEach _terrainObjects;
	// Creating the smoke source:
	_smoke = "#particlesource" createVehicle _smokePos;
	_smoke setParticleParams [
		["\A3\Data_F\ParticleEffects\Universal\Universal", 16, 9, 16, 0], "", "Billboard",
		1, 8, [0, 0, 0], [0, 0, 1.5], 0, 10, 7.9, 0.066, [1, 3, 6],
		[[0.5, 0.5, 0.5, 0], [0.5, 0.5, 0.5, 0.15], [0.5, 0.5, 0.5, 0.15], [0.5, 0.5, 0.5, 0.1], [0.75, 0.75, 0.75, 0.075], [1, 1, 1, 0]],
		[0.25], 1, 0, "", "", _smoke];
	_smoke setParticleRandom [0, [0.25, 0.25, 0], [0.2, 0.2, 0], 0, 0.25, [0, 0, 0, 0.1], 0, 0];
	_smoke setDropInterval 0.05;
	// Return:
	true;
};


THY_fnc_ETH_execution_service = {
	// This function is responsable to plant the each explosive device and, if necessary, to set its direction.
	// Returns _wasDeviceDeleted: bool.

	params ["_kz", "_kzFaction", "_ammoClassname", "_kzPos", "_kzRadius", "_kzDoctrine", "_hybridSubdoctrine", "_whereToPlant", "_isNaval"];
	private ["_txtDebugHeader", "_txtWarningHeader", "_device", "_place", "_placePos", "_placeIndex", "_devicePos", "_wasDeviceDeleted"];
	
	// CPU breath:
	sleep 0.05;  // CAUTION: without the breath, ETHICS might affect the server performance as hell.
	// Debug txts:
	_txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	// Handling errors:
	if ( (_kzDoctrine == "HY") AND (_hybridSubdoctrine == "") ) then { systemChat format ["%1 %2 > In this doctrine is mandatory to set '_hybridSubdoctrine' at 'THY_fnc_ETH_device_planter' when is called the 'THY_fnc_ETH_execution_service' function.) ", _txtWarningHeader, _kzDoctrine] };
	// Initial values:
	_device = objNull;
	_place = [];
	_placeIndex = nil;
	_placePos = [];
	_devicePos = [];

	// STEP 1 > WHEN SPECIFIC PLACE is needed:
	if ( _kzDoctrine == "BT" ) then {
		// if there's at least one place into the _whereToPlant, do it:
		if ( (count _whereToPlant) > 0 ) then {
			// select a place option from the list:
			_place = selectRandom _whereToPlant;
			// Take its position:
			_placePos = getPosATL _place;
			// and delete it from the list to avoid to plant another device in same spot:
			_placeIndex = _whereToPlant find _place; 
			_whereToPlant deleteAt _placeIndex;
		// WIP / Otherwise debug message:
		} else { if ( ETH_debug ) then { systemChat format ["%1 Marker '%2' > The script didn't find more good place for the remaining explosives.", _txtDebugHeader, _kz] } };
	};

	// STEP 2 > CREATING THE EXPLOSIVE and SETTING ITS DIRECTION:
	// Land doctrine:
	if ( !_isNaval ) then {
		// CREATING:
		if ( _kzDoctrine !="BT" ) then {
			_device = createMine [_ammoClassname, _kzPos, [], _kzRadius];
		} else {
			// Booby-trap device is created, forcing its Z axis position to avoid devices floating:
			_device = createMine [_ammoClassname, [(_placePos select 0), (_placePos select 1), 0.1], [], 1];  // best result here with Z=0.1
		};
		// GETTING POSITION releated by terrain level, including sea floor: https://community.bistudio.com/wiki/File:position.jpg
		_devicePos = getPosATL _device;
		if ( _kzDoctrine == "UXO" ) then {
			// Adds a cosmetic crater around the device:
			[_devicePos] call THY_fnc_ETH_cosmetic_UXO_impact_fail;
			// Force the Z axis to be ZERO 'cause Arma creates the device at the first surface found (sea surface) so this will put the device to the sea floor:
			_device setPosATL [(_devicePos select 0), (_devicePos select 1), 0];  // [x, y, z] / best result here with Z=0
		};
		// SETTING DIRECTION:
		if ( _kzDoctrine == "UXO" OR _kzDoctrine == "BT" ) then {
			// Randomizing the device direction:
			_device setDir (selectRandom [0, 45, 90, 135, 180, 225, 270, 315]);  // compass degrees.
		};		
	// Naval Doctrine:
	} else {
		// Explosive device is created:
		_device = createMine [_ammoClassname, _kzPos, [], _kzRadius];
		// Device position releated by sea level (surface): https://community.bistudio.com/wiki/File:position.jpg
		_devicePos = getPosASL _device;
	};
	
	// STEP 3 > AFTER CREATION RULES CHECKER:
	_wasDeviceDeleted = [_device, _devicePos, _hybridSubdoctrine, _kzDoctrine, _isNaval] call THY_fnc_ETH_inspection;

	// STEP LAST > Performance and Visibility:
	// If the mine is okay, do it:
	if ( !_wasDeviceDeleted ) then {
		// WIP / if dynamic simulation is ON in the mission, it will save performance:
		if ( ETH_A3_dynamicSim ) then { 
			_device enableDynamicSimulation true;  // https://community.bistudio.com/wiki/enableDynamicSimulation
			if ( isDedicated ) then {
				_device enableSimulationGlobal true;  // https://community.bistudio.com/wiki/enableSimulationGlobal
			} else {
				_device enableSimulation true;  // https://community.bistudio.com/wiki/enableSimulation
			};
		};
		// If is NOT the Mission Editor debugging:
		if ( !ETH_debug ) then {
			// And it's NOT a UXO device, the device will be revealed only for its faction:
			if ( _kzDoctrine !="UXO" ) then {
				switch ( _kzFaction ) do {
					case "BLU": { blufor revealMine _device };
					case "OPF": { opfor revealMine _device };
					case "IND": { independent revealMine _device };
				};
			};
		// If is the mission editor debugging, all devices will be revealed, including UXO:
		} else { (side player) revealMine _device };
		// WIP:
		//if ( ETH_devicesEditableByZeus ) then { {_x addCuratorEditableObjects [[_device], true]} forEach allCurators };
	};
	// Return:
	_wasDeviceDeleted;
};


THY_fnc_ETH_device_planter = {
	// This function organizes how each doctrine plants its mines.
	// Returns _deviceAmountsByDoctrine: array [AP [planted, deleted], AM [planted, deleted], UXO [planted, deleted]]

	params ["_kzNameStructure", "_ammoLandAP", "_ammoLandAM", "_ammoNavalAM", "_ammoPackUXO", "_ammoTrapBT", "_kz", "_kzSize", "_limiterDeviceAmounts", "_deviceAmountsByDoctrine"];
	private ["_txtDebugHeader", "_kzDoctrine", "_kzFaction", "_kzPos", "_kzRadius", "_limiterAmountAP", "_limiterAmountAM", "_limiterAmountUXO", "_limiterAmountTP", "_limiterMultiplier", "_limiterDevicesDeletedAP", "_limiterDevicesDeletedAM", "_limiterDevicesDeletedUXO", "_limiterDevicesDeletedTP", "_allDevicesPlantedAP", "_allDevicesDeletedAP", "_allDevicesPlantedAM", "_allDevicesDeletedAM", "_allDevicesPlantedUXO", "_allDevicesDeletedUXO", "_allDevicesPlantedTP", "_allDevicesDeletedTP","_devicesPlantedAP", "_devicesDeletedAP", "_devicesPlantedAM", "_devicesDeletedAM", "_devicesPlantedUXO", "_devicesDeletedUXO", "_devicesPlantedTP", "_devicesDeletedTP", "_wasDeviceDeleted", "_ammoUXO", "_hideaways"];

	// Debug txts:
	_txtDebugHeader = "ETHICS DEBUG >";
	//private _txtWarningHeader = "ETHICS WARNING >";
	// Config from Kill zone Name Structure:
	_kzDoctrine = _kzNameStructure select 1;
	_kzFaction = "";
	if ( (count _kzNameStructure) == 4 ) then { _kzFaction = _kzNameStructure select 2 };
	// Kill zone attributes: 
	_kzPos = markerPos _kz;            // [5800.70,3000.60,0]
	_kzRadius = _kzSize select 0;      // 40.1234
	// Limiters for this _kz, previously based on its size:
	_limiterAmountAP = _limiterDeviceAmounts select 0;
	_limiterAmountAM = _limiterDeviceAmounts select 1;
	_limiterAmountUXO = _limiterDeviceAmounts select 2;
	_limiterAmountTP = _limiterDeviceAmounts select 3;
	_limiterMultiplier = 0.6;  // 60% is the minimal amount to be planted.
	_limiterDevicesDeletedAP = _limiterAmountAP * _limiterMultiplier;
	_limiterDevicesDeletedAM = _limiterAmountAM * _limiterMultiplier;
	_limiterDevicesDeletedUXO = _limiterAmountUXO * _limiterMultiplier;  // P.S: Actually, UXO can't be deleted as its Doctrine rule in not follow other rules.
	_limiterDevicesDeletedTP = _limiterAmountTP * _limiterMultiplier;
	// Devices' numbers of the sum of the other kill zones priviously loaded by this function:
	_allDevicesPlantedAP = (_deviceAmountsByDoctrine select 0) select 0;
	_allDevicesDeletedAP = (_deviceAmountsByDoctrine select 0) select 1;
	_allDevicesPlantedAM = (_deviceAmountsByDoctrine select 1) select 0;
	_allDevicesDeletedAM = (_deviceAmountsByDoctrine select 1) select 1;
	_allDevicesPlantedUXO = (_deviceAmountsByDoctrine select 2) select 0;
	_allDevicesDeletedUXO = (_deviceAmountsByDoctrine select 2) select 1;
	_allDevicesPlantedTP = (_deviceAmountsByDoctrine select 3) select 0;
	_allDevicesDeletedTP = (_deviceAmountsByDoctrine select 3) select 1;
	// Devices' numbers only for this _kz:
	_devicesPlantedAP = _limiterAmountAP;
	_devicesDeletedAP = 0;
	_devicesPlantedAM = _limiterAmountAM;
	_devicesDeletedAM = 0;
	_devicesPlantedUXO = _limiterAmountUXO;
	_devicesDeletedUXO = 0;  // Actually, UXO can't be deleted as its Doctrine rule in not follow other rules.
	_devicesPlantedTP = _limiterAmountTP;
	_devicesDeletedTP = 0;
	// Debug message:
	if ( ETH_debug ) then { sleep 1; systemChat format ["%1 Marker '%2' > Planting the explosives...", _txtDebugHeader, _kz] };
	// Device planter rules by doctrine:
	switch ( _kzDoctrine ) do {
		// LAND ANTI-PERSONNEL, planting all of them at once:
		case "AP": {
			// Looping > Device amount planting in a row:
			for "_i" from 1 to _limiterAmountAP do {
				// Execute the device planting:
				_wasDeviceDeleted = [_kz, _kzFaction, _ammoLandAP, _kzPos, _kzRadius, _kzDoctrine, "", [], false] call THY_fnc_ETH_execution_service;
				// If something went wrong, deleted amount of explosive devices:
				if ( _wasDeviceDeleted ) then { _devicesDeletedAP = _devicesDeletedAP + 1 };
			};
			// Debug Kill zone feedbacks:
			[_kzDoctrine, _kz, _devicesPlantedAP, _devicesDeletedAP, _limiterDevicesDeletedAP, ETH_debug, "", ""] call THY_fnc_ETH_done_feedbacks;
			// Update with total numbers to return:
			_deviceAmountsByDoctrine = [[(_allDevicesPlantedAP + _devicesPlantedAP), (_allDevicesDeletedAP + _devicesDeletedAP)], [_allDevicesPlantedAM, _allDevicesDeletedAM], [_allDevicesPlantedUXO, _allDevicesDeletedUXO], [_allDevicesPlantedTP, _allDevicesDeletedTP]];
		};
		// LAND ANTI-MATERIEL, planting all of them at once:
		case "AM": {
			// Looping > Device amount planting in a row:
			for "_i" from 1 to _limiterAmountAM do {
				// Execute the device planting:
				_wasDeviceDeleted = [_kz, _kzFaction, _ammoLandAM, _kzPos, _kzRadius, _kzDoctrine, "", [], false] call THY_fnc_ETH_execution_service;
				// If something went wrong, deleted amount of explosive devices:
				if ( _wasDeviceDeleted ) then { _devicesDeletedAM = _devicesDeletedAM + 1 };
			};
			// Debug Kill zone feedbacks:
			[_kzDoctrine, _kz, _devicesPlantedAM, _devicesDeletedAM, _limiterDevicesDeletedAM, ETH_debug, "", ""] call THY_fnc_ETH_done_feedbacks;
			// Update with total numbers to return:
			_deviceAmountsByDoctrine = [[_allDevicesPlantedAP, _allDevicesDeletedAP], [(_allDevicesPlantedAM + _devicesPlantedAM), (_allDevicesDeletedAM + _devicesDeletedAM)], [_allDevicesPlantedUXO, _allDevicesDeletedUXO], [_allDevicesPlantedTP, _allDevicesDeletedTP]]; 
		};
		// LAND LIMITED ANTI-MATERIEL, planting all of them at once:
		case "LAM": {
			// Looping > Device amount planting in a row:
			for "_i" from 1 to _limiterAmountAM do {
				// Execute the device planting:
				_wasDeviceDeleted = [_kz, _kzFaction, _ammoLandAM, _kzPos, _kzRadius, _kzDoctrine, "", [], false] call THY_fnc_ETH_execution_service;
				// If something went wrong, deleted amount of explosive devices:
				if ( _wasDeviceDeleted ) then { _devicesDeletedAM = _devicesDeletedAM + 1 };
			};
			// Debug Kill zone feedbacks:
			[_kzDoctrine, _kz, _devicesPlantedAM, _devicesDeletedAM, _limiterDevicesDeletedAM, ETH_debug, "", ""] call THY_fnc_ETH_done_feedbacks;
			// Update with total numbers to return:
			_deviceAmountsByDoctrine = [[_allDevicesPlantedAP, _allDevicesDeletedAP], [(_allDevicesPlantedAM + _devicesPlantedAM), (_allDevicesDeletedAM + _devicesDeletedAM)], [_allDevicesPlantedUXO, _allDevicesDeletedUXO], [_allDevicesPlantedTP, _allDevicesDeletedTP]]; 
		};
		// LAND HYBRID, planting all combined mines at once:
		case "HY": {
			// Reducing each device subdoctrine for the combination amount doesn't except the regular limits:
			_limiterAmountAP = round (_limiterAmountAP / 1.5);  // Makes AP (66%) proporsion bigger than AM (33%).
			_limiterAmountAM = round (_limiterAmountAM / 3);
			// Subdoctrines need recalculate the mine types' limeters:
			_limiterDevicesDeletedAP = _limiterAmountAP * _limiterMultiplier;
			_limiterDevicesDeletedAM = _limiterAmountAM * _limiterMultiplier;
			// Needed to include Hybrid solution correctly in final devices balance:
			_devicesPlantedAP = _limiterAmountAP;
			_devicesPlantedAM = _limiterAmountAM;
			// Looping > AP amount planting in a row:
			for "_i" from 1 to _limiterAmountAP do {
				// Execute the device planting:
				_wasDeviceDeleted = [_kz, _kzFaction, _ammoLandAP, _kzPos, _kzRadius, _kzDoctrine, "AP", [], false] call THY_fnc_ETH_execution_service;
				// If something went wrong, deleted amount of explosive devices:
				if ( _wasDeviceDeleted ) then { _devicesDeletedAP = _devicesDeletedAP + 1 };
			};
			// Looping > AM amount planting in a row:
			for "_i" from 1 to _limiterAmountAM do {
				// Execute the device planting:
				_wasDeviceDeleted = [_kz, _kzFaction, _ammoLandAM, _kzPos, _kzRadius, _kzDoctrine, "AM", [], false] call THY_fnc_ETH_execution_service;
				// If something went wrong, deleted amount of explosive devices:
				if ( _wasDeviceDeleted ) then { _devicesDeletedAM = _devicesDeletedAM + 1 };
			};
			// Debug Kill zone feedbacks:
			[_kzDoctrine, _kz, _devicesPlantedAP, _devicesDeletedAP, _limiterDevicesDeletedAP, ETH_debug, "Hybrid", "AP"] call THY_fnc_ETH_done_feedbacks;
			[_kzDoctrine, _kz, _devicesPlantedAM, _devicesDeletedAM, _limiterDevicesDeletedAM, ETH_debug, "Hybrid", "AM"] call THY_fnc_ETH_done_feedbacks;
			// Update with total numbers to return:
			_deviceAmountsByDoctrine = [[(_allDevicesPlantedAP + _devicesPlantedAP), (_allDevicesDeletedAP + _devicesDeletedAP)], [(_allDevicesPlantedAM + _devicesPlantedAM), (_allDevicesDeletedAM + _devicesDeletedAM)], [_allDevicesPlantedUXO, _allDevicesDeletedUXO], [_allDevicesPlantedTP, _allDevicesDeletedTP]];
		};
		// LAND HYBRID, planting all combined mines at once:
		case "LHY": {
			// Reducing each device subdoctrine for the combination amount doesn't except the regular limits:
			_limiterAmountAP = round (_limiterAmountAP / 1.5);
			//_limiterAmountAM = round (_limiterAmountAM / 2);  // Commented because is needed increasing a bit the LAM limiter. If LOWEST intensity, it will be rare enough.
			// Subdoctrines need recalculate the mine types' limeters:
			_limiterDevicesDeletedAP = _limiterAmountAP * _limiterMultiplier;
			_limiterDevicesDeletedAM = _limiterAmountAM * _limiterMultiplier;
			// Needed to include Hybrid solution correctly in final devices balance:
			_devicesPlantedAP = _limiterAmountAP;
			_devicesPlantedAM = _limiterAmountAM;
			// Looping > AP amount planting in a row:
			for "_i" from 1 to _limiterAmountAP do {
				// Execute the device planting:
				_wasDeviceDeleted = [_kz, _kzFaction, _ammoLandAP, _kzPos, _kzRadius, _kzDoctrine, "AP", [], false] call THY_fnc_ETH_execution_service;
				// If something went wrong, deleted amount of explosive devices:
				if ( _wasDeviceDeleted ) then { _devicesDeletedAP = _devicesDeletedAP + 1 };
			};
			// Looping > LAM amount planting in a row:
			for "_i" from 1 to _limiterAmountAM do {
				// Execute the device planting:
				_wasDeviceDeleted = [_kz, _kzFaction, _ammoLandAM, _kzPos, _kzRadius, _kzDoctrine, "LAM", [], false] call THY_fnc_ETH_execution_service;
				// If something went wrong, deleted amount of explosive devices:
				if ( _wasDeviceDeleted ) then { _devicesDeletedAM = _devicesDeletedAM + 1 };
			};
			// Debug Kill zone feedbacks:
			[_kzDoctrine, _kz, _devicesPlantedAP, _devicesDeletedAP, _limiterDevicesDeletedAP, ETH_debug, "Limited Hybrid", "AP"] call THY_fnc_ETH_done_feedbacks;
			[_kzDoctrine, _kz, _devicesPlantedAM, _devicesDeletedAM, _limiterDevicesDeletedAM, ETH_debug, "Limited Hybrid", "LAM"] call THY_fnc_ETH_done_feedbacks;
			// Update with total numbers to return:
			_deviceAmountsByDoctrine = [[(_allDevicesPlantedAP + _devicesPlantedAP), (_allDevicesDeletedAP + _devicesDeletedAP)], [(_allDevicesPlantedAM + _devicesPlantedAM), (_allDevicesDeletedAM + _devicesDeletedAM)], [_allDevicesPlantedUXO, _allDevicesDeletedUXO], [_allDevicesPlantedTP, _allDevicesDeletedTP]];
		};
		// NAVAL ANTI-MATERIEL, planting all of them at once:
		case "NAM": {
			// Looping > Device amount planting in a row:
			for "_i" from 1 to _limiterAmountAM do {
				// Execute the device planting:
				_wasDeviceDeleted = [_kz, _kzFaction, _ammoNavalAM, _kzPos, _kzRadius, _kzDoctrine, "", [], true] call THY_fnc_ETH_execution_service;
				// If something went wrong, deleted amount of explosive devices:
				if ( _wasDeviceDeleted ) then { _devicesDeletedAM = _devicesDeletedAM + 1 };
			};
			// Debug Kill zone feedbacks:
			[_kzDoctrine, _kz, _devicesPlantedAM, _devicesDeletedAM, _limiterDevicesDeletedAM, ETH_debug, "", ""] call THY_fnc_ETH_done_feedbacks;
			// Update with total numbers to return:
			_deviceAmountsByDoctrine = [[_allDevicesPlantedAP, _allDevicesDeletedAP], [(_allDevicesPlantedAM + _devicesPlantedAM), (_allDevicesDeletedAM + _devicesDeletedAM)], [_allDevicesPlantedUXO, _allDevicesDeletedUXO], [_allDevicesPlantedTP, _allDevicesDeletedTP]]; 
		};
		// UNEXPLODED ORDNANCE, dropping all of them at once:
		case "UXO": {
			// Creating cosmetic smokes:
			if ( ETH_cosmeticSmokesUXO ) then {
				for "_i" from 1 to (round (_limiterAmountUXO / (selectRandom [1, 2, 3]))) do {
					[_kzPos, _kzRadius] call THY_fnc_ETH_cosmetic_UXO_impact_area;
				};
			};
			// Looping > Device amount planting in a row:
			for "_i" from 1 to _limiterAmountUXO do {
				_ammoUXO = selectRandom _ammoPackUXO;
				// Execute the device planting:
				_wasDeviceDeleted = [_kz, _kzFaction, _ammoUXO, _kzPos, _kzRadius, _kzDoctrine, "", [], false] call THY_fnc_ETH_execution_service;
				// If something went wrong, deleted amount of explosive devices:
				// UXO cant be deleted because it is dropped everywhere, water included.
			};
			// Debug UXO zone feedbacks:
			[_kzDoctrine, _kz, _devicesPlantedUXO, _devicesDeletedUXO, _limiterDevicesDeletedUXO, ETH_debug, "", ""] call THY_fnc_ETH_done_feedbacks;
			// Update with total numbers to return:
			_deviceAmountsByDoctrine = [[_allDevicesPlantedAP, _allDevicesDeletedAP], [_allDevicesPlantedAM, _allDevicesDeletedAM], [(_allDevicesPlantedUXO + _devicesPlantedUXO), (_allDevicesDeletedUXO + _devicesDeletedUXO)], [_allDevicesPlantedTP, _allDevicesDeletedTP]];  // P.S: This calcs is here just to preserve the standards, because UXO has no deletation counter in pratices.
		};
		// BOOBY-TRAP, planting all of them at once:
		case "BT": {
			// Finding potential hiding places:
			_hideaways = nearestTerrainObjects [_kzPos, ["TREE", "FOREST"/* , "TRACK", "HOUSE" */], _kzRadius];  // don't include "Small tree", "Bush" or another common object if you don't wanna stress too much the server CPU;
			// if the hideaways' amount is smaller than pre-calculated TP amount limit, it create a new limit base on available hideaways:
			if ( (count _hideaways) < _limiterAmountTP ) then { 
				_limiterAmountTP = count _hideaways;
				_devicesPlantedTP = _limiterAmountTP;
			};
			// Looping > Device amount planting in a row:
			for "_i" from 1 to _limiterAmountTP do {
				// Execute the device planting:
				_wasDeviceDeleted = [_kz, _kzFaction, _ammoTrapBT, _kzPos, _kzRadius, _kzDoctrine, "", _hideaways, false] call THY_fnc_ETH_execution_service;
				// If something went wrong, deleted amount of explosive devices:
				if ( _wasDeviceDeleted ) then { _devicesDeletedTP = _devicesDeletedTP + 1 };
			};
			// Debug Kill zone feedbacks:
			[_kzDoctrine, _kz, _devicesPlantedTP, _devicesDeletedTP, _limiterDevicesDeletedTP, ETH_debug, "", ""] call THY_fnc_ETH_done_feedbacks;
			// Update with total numbers to return:
			_deviceAmountsByDoctrine = [[_allDevicesPlantedAP, _allDevicesDeletedAP], [_allDevicesPlantedAM, _allDevicesDeletedAM], [_allDevicesPlantedUXO, _allDevicesDeletedUXO], [(_allDevicesPlantedTP + _devicesPlantedTP), (_allDevicesDeletedTP + _devicesDeletedTP)]];
		};
	};
	// Return:
	_deviceAmountsByDoctrine;
};


THY_fnc_ETH_done_feedbacks = {
	// This function just gives some feedback about kill zones numbers, sometimes for debugging purposes, sometimes for warning the mission editor. 
	// Returns nothing.

	params ["_kzDoctrine", "_kz", "_devicesPlanted", "_devicesDeleted", "_limiterMinesDeleted", "_debug", "_hybridTitle", "_subdoctrine"];
	private ["_txtDebugHeader", "_txtWarningHeader", "_txtWarning_2", "_txtWarning_4", "_txtWarning_5"];

	// Debug txts:
	_txtDebugHeader = "ETHICS DEBUG >";
	_txtWarningHeader = "ETHICS WARNING >";
	_txtWarning_2 = "Try to change the kill zone position. Not recommended, you might also turn off the ETHICS and TOPOGRAPHY rules.";
	_txtWarning_4 = format ["Too much devices deleted (%1 of %2) for simulation reasons or editor's choices. %3", _devicesDeleted, _devicesPlanted, _txtWarning_2];
	_txtWarning_5 = format ["No mines were planted. Try to restart the mission to make sure it was just a coincidence. If the behavior comes again, try to change the kill zone position or increase the mines' intensity (current='%1').", ETH_globalDevicesIntensity];
	// If doctrine has NO subdoctrine:
	if ( _hybridTitle == "" ) then {
		// Debug Kill zone feedbacks > Everything looks fine:
		if ( _debug AND (_devicesDeleted < _limiterMinesDeleted) ) then { 
			// If no mines deleted:
			if ( _devicesDeleted == 0 ) then {
				systemChat format ["%1 Marker '%2' > %3 > Got all %4 devices planted successfully.", _txtDebugHeader, _kz, _kzDoctrine, _devicesPlanted];
			// Otherwise, just a few mines deleted:
			} else {
				systemChat format ["%1 Marker '%2' > %3 > From %4 devices planted, %5 were deleted (balance: %6).", _txtDebugHeader, _kz, _kzDoctrine, _devicesPlanted, _devicesDeleted, (_devicesPlanted - _devicesDeleted)];
			};
		// If not fine, probably some mission editor's action is required:
		} else {
			// If lots of mines deleted:
			if ( _devicesDeleted > _limiterMinesDeleted ) then {
				// If it's NOT LAM:
				if ( _kzDoctrine != "LAM" ) then {
					// Warning message:
					systemChat format ["%1 Marker '%2' > %3 > %4", _txtWarningHeader, _kz, _kzDoctrine, _txtWarning_4];
				// if it's LAM:
				} else {
					// just show the regular debug message for LAM if, at least, one LAM was planted:
					if ( ETH_debug AND ((_devicesPlanted - _devicesDeleted) != 0) ) then { 
						systemChat format ["%1 Marker '%2' > %3 > From %4 devices planted, %5 were deleted (balance: %6).", _txtDebugHeader, _kz, _kzDoctrine, _devicesPlanted, _devicesDeleted, (_devicesPlanted - _devicesDeleted)];
					// Otherwise, you finally got a rare scenario to check:
					} else {
						systemChat format ["%1 Marker '%2' > %3 > %4", _txtWarningHeader, _kz, _kzDoctrine, _txtWarning_5];
					};
				};
			};
		};
	// Otherwise, if the doctrine has subdoctrine:
	} else {
		// If everything looks fine:
		if ( _devicesDeleted < _limiterMinesDeleted ) then { 
			// If no mines deleted:
			if ( _devicesDeleted == 0 ) then {
				if ( ETH_debug ) then { systemChat format ["%1 Marker '%2' > %3 > %4 > Got all %5 devices planted successfully.", _txtDebugHeader, _kz, _hybridTitle, _subdoctrine, _devicesPlanted] };
			// Otherwise, just a few mines deleted:
			} else {
				if ( ETH_debug ) then { systemChat format ["%1 Marker '%2' > %3 > %4 > From %5 devices planted, %6 were deleted (balance: %7).", _txtDebugHeader, _kz, _hybridTitle, _subdoctrine, _devicesPlanted, _devicesDeleted, (_devicesPlanted - _devicesDeleted)] };
			};
		// Otherwise, if the amount of devices-deleted is bigger than the limiter of devices-deleted:
		} else {
			// If it's NOT LAM:
			if ( _subdoctrine != "LAM" ) then {
				// Warming message:
				systemChat format ["%1 Marker '%2' > %3 > %4 > %5", _txtWarningHeader, _kz, _hybridTitle, _subdoctrine, _txtWarning_4];
			// Otherwise, if it's LAN:
			} else {
				// just show the regular debug message for HY LAM if, at least, one LAM was planted:
				if (  (_devicesPlanted - _devicesDeleted) != 0 ) then {
					if ( ETH_debug ) then { systemChat format ["%1 Marker '%2' > %3 > %4 > From %5 devices planted, %6 were deleted (balance: %7).", _txtDebugHeader, _kz, _hybridTitle, _subdoctrine, _devicesPlanted, _devicesDeleted, (_devicesPlanted - _devicesDeleted)] };
				// Otherwise, you finally got a rare scenario to check:
				} else {
					systemChat format ["%1 Marker '%2' > %3 > %4 > %5", _txtWarningHeader, _kz, _hybridTitle, _subdoctrine, _txtWarning_5];
				};
			};
		};
	};
	// Returning:
	true;
};


THY_fnc_ETH_debug = {
	// This function shows a monitor with ETHICS script information right after ALL script proccesses has been finnished, so to see the Debug monitor can take a while. Only the hosted-server-player and dedicated-server-admin are able to see the feature.
	// Returns nothing.

	if ( !ETH_debug ) exitWith {};

	params ["_kzAmountFaction", "_kzAmountUnknown", "_balanceDevicesAP", "_balanceDevicesAM", "_balanceDevicesUXO", "_balanceDevicesTP", "_balanceDevicesNoEthTotal"];

	hintSilent format [
		"\n" +
		"--- ETHICS DEBUG MONITOR ---\n" + 
		"\n" +
		"Kill zones on map = %1\n" +
		"Kill zones from factions = %2\n" +
		"Kill zones from unknown = %3\n" +
		"Devices' intensity = %4\n" +
		"Initial ETH AP planted = %5\n" +
		"Initial ETH AM planted = %6\n" +
		"Initial ETH UXO planted = %7\n" +
		"Initial ETH Traps planted = %8\n" +
		"Initial No-ETH planted = %9\n" +
		"Current all devices = %10\n" +
		"\n",
		(_kzAmountFaction + _kzAmountUnknown),
		_kzAmountFaction,
		_kzAmountUnknown,
		ETH_globalDevicesIntensity,
		_balanceDevicesAP,
		_balanceDevicesAM,
		_balanceDevicesUXO,
		_balanceDevicesTP,
		_balanceDevicesNoEthTotal,
		(count allMines)
	];
	// Returning:
	true;
};
