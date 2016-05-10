#include "macro.sqf"

if (isNil { NEO_radioLogic getVariable "NEO_supportMarker" }) then
{
	private ["_marker"];
	_marker = createMarkerLocal ["NEO_supportMarker", [100, 1000, 0]];
	_marker setMarkerAlphaLocal 0;
	NEO_radioLogic setVariable ["NEO_supportMarker", _marker];
	
	private ["_markerArtyMin", "_markerArtyMax"];
	_markerArtyMin = createMarkerLocal ["NEO_supportMarkerArtyMin", [100, 1000, 0]];
	_markerArtyMin setMarkerAlphaLocal 0;
	_markerArtyMax = createMarkerLocal ["NEO_supportMarkerArtyMax", [100, 1000, 0]];
	_markerArtyMax setMarkerAlphaLocal 0;
	NEO_radioLogic setVariable ["NEO_supportArtyMarkers", [_markerArtyMin, _markerArtyMax]];
};

//Display
private ["_display", "_map", "_abort", "_suppListBox", "_unit", "_action","_available", "_transportArray", "_casArray", "_artyArray"];

disableSerialization;

_suppListBox = SR_getControl(SR_Main_Display,SR_Support_List);
_translist = SR_getControl(SR_Main_Display,SR_Transport_List);
_artylist = SR_getControl(SR_Main_Display,SR_Arty_List);
_map = SR_getControl(SR_Main_Display,SR_Map);
_abort = SR_getControl(SR_Main_Display,SR_ABORT_BTN);
_unit = player;
_action = uinamespace getVariable "NEO_radioCurrentAction";

private ["_available", "_transportArray", "_casArray", "_artyArray","_side"];

/*
if (isnil "playerSide") then {
	switch (getNumber(configFile >> "Cfgvehicles" >> (typeof _unit) >> "side")) do {
	    case 0 : {_side = EAST};
	    case 1 : {_side = WEST};
	    case 2 : {_side = RESISTANCE};
	    case 3 : {_side = CIVILIAN};
	    default {_side = EAST};
	};
	playerSide = _side;
};
*/
_available = [];
_transportArray = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", playerSide];
_casArray = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", playerSide];
_artyArray = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", playerSide];

//Available Supports
if (count _transportArray > 0) then { _available set [count _available, ["TRANSPORT", "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa"]] };
if (count _casArray > 0) then { _available set [count _available, ["CAS", "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\cas_ca.paa"]] };
if (count _artyArray > 0 && (_action == "radio" || _action == "talkarty")) then { _available set [count _available, ["ARTY", "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\artillery_ca.paa"]] };
//Support ListBox
lbClear _suppListBox;
{
	_suppListBox lbAdd format["%1", (_x select 0)];
	_suppListBox lbSetPicture [_forEachIndex, (_x select 1)];
} forEach _available;

//Display Event Handlers
_suppListBox ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_radioLbSelChanged"];
_abort ctrlSetEventHandler ["ButtonClick", "closeDialog 0;"];

switch (_action) do
{
	case "talk" :
	{
		NEO_radioLogic setVariable ["NEO_radioTalkWithPilot", vehicle _unit];
		
		[] spawn
		{
			lbSetCurSel [655565, 0];
			waituntil { lbSize 655568 > 0 };
			lbSetCurSel [655568, 0];
		};
	};

	case "talkarty" :
	{
		NEO_radioLogic setVariable ["NEO_radioTalkWithArty", vehicle cursorTarget];
		
		[] spawn
		{
			lbSetCurSel [655565, 2];
			waituntil { lbSize 655594 > 0 };
			lbSetCurSel [655594, 0];;
		};
	};

	case "radio" :
	{
		if (count _available > 0 && count _available < 2) then 
		{
			[] spawn { lbSetCurSel [655565, 0] };
		}
		else
		{
			private ["_count", "_sup", "_index", "_obj"];
			_count = 0;
			_sup = 0;
			_index = [0, 0];
			_obj = objNull;
			
			{
				_obj = _x select 0;
				
				if ((_obj getVariable "NEO_radioTrasportUnitStatus") == "SMOKECONF") then
				{
					_index = [0, _forEachIndex];
					_sup = _translist;
					_count = _count + 1;
				};
			} forEach _transportArray;
			
			{
				_obj = _x select 0;
				
				if ((_obj getVariable "NEO_radioArtyUnitStatus") == "RESPONSE") then
				{
					_index = [2, _forEachIndex];
					_sup = _artylist;
					_count = _count + 1;
				};
			} forEach _artyArray;
			
			if (_count > 0) then
			{
				[_index, _sup] spawn
				{
					lbSetCurSel [655565, (_this select 0) select 0];
					waituntil { lbSize (_this select 1) > 0 };
					lbSetCurSel [(_this select 1), (_this select 0) select 1];
				};
			};
		};
	};
};

/*//Satellite
if (vehicle _unit == _unit && _action == "radio") then
{
	private ["_sat"];
	_sat = createVehicle ["SatPhone", getPosATL _unit, [], 0, "CAN_COLLIDE"];
	NEO_radioLogic setVariable ["NEO_radioSatalliteObject", _sat];
	_sat attachTo [_unit, [-0.15,0.3,-0.3], "neck"];
	_unit playMove "amovpknlmstpsraswrfldnon_gear";
};*/

//Hide GPS
showGPS false;
