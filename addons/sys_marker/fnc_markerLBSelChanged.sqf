#include <\x\alive\addons\sys_marker\script_component.hpp>

SCRIPT(markerLBSelChanged);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_markerOnLoad
Description:
Handles the onload event for a dialog

Parameters:
_this select 0: DISPLAY - Reference to calling display

Returns:
Nil

See Also:
- <ALIVE_fnc_marker>

Author:
Tupolov

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_params","_display","_color","_colorForce","_cursel","_class","_brush","_type","_Preview","_idc","_id","_ctrl","_colorComboBox","_substring","_ValueIcon"];

_params = _this select 0;
_display = ctrlparent (_params select 0);
_idc = _this select 1;
_ctrl = _display displayctrl _idc;

_cursel = lbcursel _ctrl;

if (_cursel == -1) then {_cursel = 0};
_class = _ctrl lbdata _cursel;
_Preview = _display displayctrl 801200;


switch _idc do {
	case 80104: { //Icon ComboBox
		_type = gettext (configfile >> "cfgmarkers" >> _class >> "icon");
		_Preview ctrlsettext _type;

		//If flag is selected, set the color to default and disable color ComboBox (we don't want to colorize flags).
		_colorComboBox = _display displayctrl 80105;
		_substring = [_class, 0, 4] call BIS_fnc_trimString;

		if (_substring == "flag_") then
		{
			_colorComboBox lbSetCurSel 0;	//Assume default is at 0
			_colorComboBox ctrlEnable false;
		}
		else
		{
			_colorComboBox ctrlEnable true;
		};

	};
	case 80110: {
		_brush = if (_class == "solid") then {
			"#(argb,8,8,3)color(1,1,1,0.5)"
		} else {
			gettext (configfile >> "cfgmarkerbrushes" >> _class >> "texture");
		};
		_Preview ctrlsettext _brush;
	};
	case 80105: {
		_color = if (_class == "default") then {
			_colorForce = if (count _this > 2) then {_this select 2} else {false};
			if (_colorForce) then {
				[]
			} else {
				_ValueIcon = _display displayctrl 80104;
				// Cater for uncolored civilian icons
				private "_cock";
				_cock = [_ValueIcon lbdata (lbcursel _ValueIcon),0,1] call BIS_fnc_trimString;
				if (_cock == "c_") then {
					[0,0,0,1];
				} else {
						(configfile >> "cfgmarkers" >> (_ValueIcon lbdata (lbcursel _ValueIcon)) >> "color") call BIS_fnc_colorConfigToRGBA;
				};
			};
		} else {
				(configfile >> "cfgmarkercolors" >> _class >> "color") call bis_fnc_colorConfigToRGBA;
		};
		if (count _color == 0) then {_color = [0,0,0,1];};
		_Preview ctrlsettextcolor _color;
	};
	case 801013: {
		// If this changes update the group type dropdown
		private ["_i","_groupValue","_config","_temp","_side","_faction"];
		_groupValue = _display displayctrl 801014;
		lbClear _groupValue;
		_temp = [_class, "/"] call CBA_fnc_split;
		_side = _temp select 2;
		_faction = _temp select 3;
		_config = (configFile >> "CfgGroups" >> _side >> _faction);
		for "_i" from 0 to count _config -1 do {
			private ["_type","_f"];
			_type = _config select _i;
			if (isClass _type) then {
				_index = _groupValue lbAdd getText(_type >> "name");
				_groupValue lbSetData [_index, str(_type)];
				for "_f" from 0 to count _type -1 do {
					private ["_unit","_index","_t","_u"];
					_unit = _type select _f;
					if (isClass _unit) then {
						_t = gettext ( _type >> "name");
						_u = gettext ( _unit >> "name");
						_index = _groupValue lbAdd format["%1 - %2", _t, _u];
						_groupValue lbSetData [_index, str(_unit)];
					};
				};
			};
		};
		_groupValue lbSetSelected [0, true];
	};
	case 80120: {
		// If Icon class group changes repopulate the icon types
		//--- Icon Types
		_ValueIcon = _display displayctrl 80104;
		lbClear _ValueIcon;
		{
			private ["_index", "_icon","_markerClass"];
			_markerClass = getText (configFile >> "cfgmarkers" >> _x >> "markerClass");
			if (_markerClass == "") then {_markerClass = "Default";};
			if ( _markerClass == _class) then {
				_icon = gettext (configfile >> "cfgmarkers" >> _x >> "name");
				_index = _ValueIcon lbAdd _icon;
				_ValueIcon lbSetData [_index, _x];
			};
		} foreach (uiNamespace getVariable QGVAR(CfgMarkers));

		for "_i" from 0 to (lbsize _ValueIcon - 1) do {
			private ["_icon","_type"];
			_icon = _ValueIcon lbdata _i;
			_type = gettext (configfile >> "cfgmarkers" >> _icon >> "icon");
			_ValueIcon lbsetpicture [_i,_type];
			lbsetcolor [80104,_i,(configfile >> "cfgmarkers" >> _icon >> "color") call bis_fnc_colorConfigToRGBA];
		};
		lbSetCurSel [ICON_LIST, 0];
	};
};

