private ["_display", "_map"];
_display = findDisplay 655555;
_map = _display displayCtrl 655560;

private
[
	"_artyArray", "_artyUnitLb", "_artyUnitText", "_artyHelpUnitText", "_artyConfirmButton", "_artyBaseButton", "_artyOrdnanceTypeText",
	"_artyOrdnanceTypeLb", "_artyRateOfFireText", "_artyRateOfFireLb", "_artyRoundCountText", "_artyRoundCountLb", "_artyMoveButton",
	"_artyDontMoveButton", "_artyDispersionText", "_artyDispersionSlider", "_artyRateDelayText", "_artyRateDelaySlider",
	"_supportMarker", "_artyMarkers", "_battery", "_status", "_class", "_ord"
];
_artyArray = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", playerSide];
_artyUnitLb = _display displayCtrl 655594;
_artyUnitText = _display displayCtrl 655595;
_artyHelpUnitText = _display displayCtrl 655596;
_artyConfirmButton = _display displayCtrl 655597;
_artyBaseButton = _display displayCtrl 655610;
_artyOrdnanceTypeText = _display displayCtrl 655600;
_artyOrdnanceTypeLb = _display displayCtrl 655601;
_artyRateOfFireText = _display displayCtrl 655602;
_artyRateOfFireLb = _display displayCtrl 655603;
_artyRoundCountText = _display displayCtrl 655604;
_artyRoundCountLb = _display displayCtrl 655605;
_artyMoveButton = _display displayCtrl 655606;
_artyDontMoveButton = _display displayCtrl 655607;
_artyDispersionText = _display displayCtrl 655608;
_artyDispersionSlider = _display displayCtrl 655609;
_artyRateDelayText = _display displayCtrl 655611;
_artyRateDelaySlider = _display displayCtrl 655612;
_supportMarker = NEO_radioLogic getVariable "NEO_supportMarker";
_artyMarkers = NEO_radioLogic getVariable "NEO_supportArtyMarkers";
_battery = _artyArray select (lbCurSel _artyUnitLb) select 0; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _battery = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 0 };
_status = _battery getVariable "NEO_radioArtyUnitStatus";
_class = typeOf (((_artyArray select (lbCurSel _artyUnitLb)) select 3) select 0); if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _class = typeOf (NEO_radioLogic getVariable "NEO_radioTalkWithArty") };
_ord = _battery getVariable "NEO_radioArtyBatteryRounds";

//Help Text
_artyHelpUnitText ctrlSetStructuredText parseText (switch (toUpper _status) do
{
	case "NONE" : { "<t color='#627057' size='0.7' font='PuristaMedium'>Unit is available and waiting for fire mission</t>" };
	case "KILLED" : { "<t color='#603234' size='0.7' font='PuristaMedium'>Unit is combat ineffective</t>" };
	case "MISSION" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit is on a fire mission</t>" };
	case "MOVE" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit is on the move to get in range of target</t>" };
	case "RTB" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit is RTB</t>" };
	case "RESPONSE" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit waiting for response</t>" };
	case "NOAMMO" : { "<t color='#603234' size='0.7' font='PuristaMedium>Unit is out of ammunition</t>" };
});

if (_status == "RESPONSE") then
{
	_artyMoveButton ctrlEnable true; _artyMoveButton ctrlSetPosition [0.519796 * safezoneW + safezoneX, 0.6176 * safezoneH + safezoneY, (0.216525 * safezoneW), (0.028 * safezoneH)]; _artyMoveButton ctrlCommit 0;
	_artyMoveButton ctrlSetEventHandler ["ButtonClick", "_this call NEO_fnc_artyMoveButtons"];
	_artyDontMoveButton ctrlEnable true; _artyDontMoveButton ctrlSetPosition [0.519796 * safezoneW + safezoneX, 0.584 * safezoneH + safezoneY, (0.216525 * safezoneW), (0.028 * safezoneH)]; _artyDontMoveButton ctrlCommit 0;
	_artyDontMoveButton ctrlSetEventHandler ["ButtonClick", "_this call NEO_fnc_artyMoveButtons"];
}
else
{
	_artyMoveButton ctrlEnable false; _artyMoveButton ctrlSetPosition [safeZoneX + (safeZoneW / 1000), safeZoneY + (safeZoneH / 1.425), (safeZoneW / 1000), (safeZoneH / 1000)]; _artyMoveButton ctrlCommit 0;
	_artyDontMoveButton ctrlEnable false; _artyDontMoveButton ctrlSetPosition [safeZoneX + (safeZoneW / 1000), safeZoneY + (safeZoneH / 1.375), (safeZoneW / 1000), (safeZoneH / 1000)];  _artyDontMoveButton ctrlCommit 0;
};

//Markers
uinamespace setVariable ["NEO_artyMarkerCreated", nil];
{ _x setMarkerAlphaLocal 0 } forEach _artyMarkers + [_supportMarker];

//Re-initialize Controls
{ _x ctrlSetPosition [1, 1, (safeZoneW / 1000), (safeZoneH / 1000)]; _x ctrlCommit 0; } forEach [_artyDispersionSlider, _artyRateDelaySlider];
{ _x ctrlSetText "" } forEach [_artyOrdnanceTypeText, _artyRateOfFireText, _artyRoundCountText, _artyDispersionText, _artyRateDelayText];
{ lbClear _x } forEach [_artyOrdnanceTypeLb, _artyRateOfFireLb, _artyRoundCountLb];

if (!(_status in ["KILLED", "MISSION", "RTB", "MOVE", "RESPONSE", "NOAMMO"]) && count _ord > 0) then
{
	//Ordnance
	_artyOrdnanceTypeText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>ORDNANCE</t>";
	_artyOrdnanceTypeLb ctrlEnable true;
	lbClear _artyOrdnanceTypeLb;
	{
		if ((_x select 1) >= 1) then
		{
			_artyOrdnanceTypeLb lbAdd (_x select 0);

		};
	} forEach _ord;

	//Arty Markers
	{
		private ["_radius"];
		_radius = _class call NEO_fnc_artyUnitFiringDistance;

		_x setMarkerPosLocal getPosATL _battery;
		_x setMarkerShapeLocal "ELLIPSE";
		_x setMarkerBrushlocal "SolidBorder";

		if (_forEachIndex == 0) then
		{
			_x setMarkerAlphaLocal 0.8;
			_x setMarkerSizeLocal [_radius select 0, _radius select 0];
			_x setMarkerColorLocal "ColorRed";
		}
		else
		{
			_x setMarkerAlphaLocal 0.3;
			_x setMarkerSizeLocal [_radius select 1, _radius select 1];
			_x setMarkerColorLocal "ColorGreen";
		};
	} forEach _artyMarkers;

	//Map Anim
	ctrlMapAnimClear _map;
	_map ctrlMapAnimAdd [0.5, 1, position _battery];
	ctrlMapAnimCommit _map;

	//EventHandlers
	_artyOrdnanceTypeLb ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_artyConfirmButtonEnable; _this call NEO_fnc_artyOrdLbSelChanged"];
	_map ctrlSetEventHandler ["MouseButtonDown", "_this call NEO_fnc_radioMapEvent"];
};

//Buttons
if (_status == "MOVE") then { _artyBaseButton ctrlEnable true } else { _artyBaseButton ctrlEnable false };
[] call NEO_fnc_artyConfirmButtonEnable;
