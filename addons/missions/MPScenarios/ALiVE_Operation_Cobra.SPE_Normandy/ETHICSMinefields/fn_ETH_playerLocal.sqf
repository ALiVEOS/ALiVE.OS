// ETHICS MINEFIELDS v1.8
// File: your_mission\ETHICSMinefields\fn_ETH_playerLocal.sqf
// by thy (@aldolammel)


// ETHICS CORE / TRY TO CHANGE NOTHING BELOW!!! --------------------------------------------------------------------


if (!hasInterface) exitWith {};  // all players clients and player host can read this file.

// Check if the main script file is okay to keep going:
if ( ETH_doctrinesLandMinefield OR ETH_doctrinesNavalMinefield OR ETH_doctrinesOXU OR ETH_doctrinesTraps ) then {
	// Local object declarations:
	private ["_eachConfirmedList", "_kzNameStructure", "_kzDoctrine", "_kzFaction", "_brush", "_colorUnknown", "_colorKnown", "_color"];
	{  // forEach ETH_confirmedKzMarkers:
		_eachConfirmedList = _x;
		{  // forEach _eachConfirmedList:
			// Basic validations:
			_kzNameStructure = [_x, ETH_prefix, ETH_spacer] call THY_fnc_ETH_marker_name_splitter;
			_kzDoctrine = [_kzNameStructure, _x, false] call THY_fnc_ETH_marker_name_section_doctrine;
			_kzFaction = [_kzNameStructure, _x, false] call THY_fnc_ETH_marker_name_section_faction;
			// Initial values:
			_x setMarkerAlphaLocal 0;
			_brush = ETH_killzoneStyleBrush;
			_colorUnknown = "ColorUNKNOWN";
			_colorKnown = ETH_killzoneStyleColor;
			if ( _colorUnknown == ETH_killzoneStyleColor ) then { _colorUnknown = "ColorRed" };  // error handling: invert if editor's choice is the original script unknown color.
			_color = _colorUnknown;
			// If visible:
			if ( ETH_killzoneVisibleOnMap ) then {
				switch ( _kzFaction ) do {
					case "BLU": { if ( (side player) == blufor ) then { _color = _colorKnown; _x setMarkerAlphaLocal ETH_killzoneStyleAlpha } };
					case "OPF": { if ( (side player) == opfor ) then { _color = _colorKnown; _x setMarkerAlphaLocal ETH_killzoneStyleAlpha } };
					case "IND": { if ( (side player) == independent ) then { _color = _colorKnown; _x setMarkerAlphaLocal ETH_killzoneStyleAlpha } };
				};
				// Finally, execute the style configuration:
				if ( ETH_doctrinesLandMinefield AND (_kzDoctrine == "LAM") ) then { _brush = "Border" };  // style for doctrines where only roads are mined.
				if ( ETH_doctrinesTraps AND (_kzDoctrine == "BT") ) then { _brush = "Border" };  // style for doctrines where only roads are mined.
				if ( ETH_doctrinesOXU AND (_kzDoctrine == "UXO") ) then { _brush = "Cross" };
				_x setMarkerColorLocal _color;  // https://community.bistudio.com/wiki/Arma_3:_CfgMarkerColors
				_x setMarkerBrushLocal _brush;  // https://community.bistudio.com/wiki/setMarkerBrush
			};
			// If is the mission editor debugging, just show too:
			if ( ETH_debug ) then { _x setMarkerAlphaLocal 1 };
		} forEach _eachConfirmedList;
	} forEach ETH_confirmedKzMarkers;
};
// Return:
true;
