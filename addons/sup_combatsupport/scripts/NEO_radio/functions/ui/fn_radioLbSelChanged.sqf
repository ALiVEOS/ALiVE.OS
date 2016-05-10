private ["_display", "_map", "_lb", "_index", "_supportMarker", "_artyMarkers"];
_display = findDisplay 655555;
_map = _display displayCtrl 655560;
_lb = _this select 0;
_index = _this select 1;
_supportMarker = NEO_radioLogic getVariable "NEO_supportMarker";
_artyMarkers = NEO_radioLogic getVariable "NEO_supportArtyMarkers";

//Transport Controls
private
[
	"_transportUnitLb", "_transportTaskLb", "_transportUnitText", "_transportTaskText", "_transportHelpUnitText", "_transportHelpTaskText",
	"_transportConfirmButton", "_transportBaseButton", "_transportSmokeFoundButton", "_transportSmokeNotFoundButton", "_transportSlider",
	"_transportSliderText", "_transportHeightCombo", "_transportSpeedCombo", "_transportRoeCombo", "_transportComboText"
];
_transportUnitLb = _display displayCtrl 655568;
_transportTaskLb = _display displayCtrl 655569;
_transportUnitText = _display displayCtrl 655570;
_transportTaskText = _display displayCtrl 655571;
_transportHelpUnitText = _display displayCtrl 655572;
_transportHelpTaskText = _display displayCtrl 655573;
_transportConfirmButton = _display displayCtrl 655574;
_transportBaseButton = _display displayCtrl 655575;
_transportSmokeFoundButton = _display displayCtrl 655576;
_transportSmokeNotFoundButton = _display displayCtrl 655577;
_transportSlider = _display displayCtrl 655578;
_transportSliderText = _display displayCtrl 655579;
_transportHeightCombo = _display displayCtrl 655630;
_transportSpeedCombo = _display displayCtrl 655631;
_transportRoeCombo = _display displayCtrl 655632;
_transportComboText = _display displayCtrl 655633;

//CAS Controls
private
[
	"_casUnitLb", "_casUnitText", "_casHelpUnitText", "_casConfirmButton", "_casBaseButton", "_casTaskLb", "_casTaskText", "_casTaskHelpText",
	"_casFlyHeightSlider", "_casFlyHeighSliderText", "_casRadiusSlider", "_casRadiusSliderText", "_casAttackRunText", "_casAttackRunLB"
];
_casUnitLb = _display displayCtrl 655582;
_casUnitText = _display displayCtrl 655583;
_casHelpUnitText = _display displayCtrl 655584;
_casConfirmButton = _display displayCtrl 655585;
_casBaseButton = _display displayCtrl 655586;
_casTaskLb = _display displayCtrl 655587;
_casTaskText = _display displayCtrl 655588;
_casTaskHelpText = _display displayCtrl 655589;
_casFlyHeightSlider = _display displayCtrl 655590;
_casFlyHeighSliderText = _display displayCtrl 655591;
_casRadiusSlider = _display displayCtrl 655592;
_casRadiusSliderText = _display displayCtrl 655593;
_casAttackRunText = _display displayCtrl 655614;
_casAttackRunLB = _display displayCtrl 655613;
_casROELb = _display displayCtrl 655615;
_casROEText = _display displayCtrl 655616;

//ARTY Controls
private
[
	"_artyUnitLb", "_artyUnitText", "_artyHelpUnitText", "_artyConfirmButton", "_artyBaseButton", "_artyOrdnanceTypeText", "_artyOrdnanceTypeLb",
	"_artyRateOfFireText", "_artyRateOfFireLb", "_artyRoundCountText", "_artyRoundCountLb", "_artyMoveButton", "_artyDontMoveButton", "_artyDispersionText",
	"_artyDispersionSlider", "_artyRateDelayText", "_artyRateDelaySlider"
];
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

//Re-initialize Controls
{ (_x select 0) ctrlSetEventHandler [(_x select 1), ""] } forEach [[_map, "MouseButtonDown"]];
{ _x ctrlSetPosition [1, 1, (safeZoneW / 1000), (safeZoneH / 1000)]; _x ctrlCommit 0; } forEach [_transportConfirmButton, _transportBaseButton, _transportSmokeFoundButton, _transportSmokeNotFoundButton, _transportSlider, _transportSliderText, _casConfirmButton, _casBaseButton, _casFlyHeightSlider, _casRadiusSlider, _artyConfirmButton, _artyMoveButton, _artyDontMoveButton, _artyDispersionSlider, _artyBaseButton, _artyRateDelaySlider, _transportHeightCombo, _transportSpeedCombo, _transportRoeCombo];
{ _x ctrlSetText "" } forEach [_transportUnitText, _transportTaskText, _transportHelpUnitText, _transportHelpTaskText, _transportSliderText, _casUnitText, _casHelpUnitText, _casTaskText, _casROEText,_casTaskHelpText, _casFlyHeighSliderText, _casRadiusSliderText, _casAttackRunText, _artyUnitText, _artyHelpUnitText, _artyOrdnanceTypeText, _artyRateOfFireText, _artyRoundCountText, _artyDispersionText, _artyRateDelayText, _transportComboText];
{ _x ctrlEnable false; } forEach [_transportUnitLb, _transportTaskLb, _casUnitLb, _casTaskLb, _casROELb, _casAttackRunLB, _artyUnitLb, _artyOrdnanceTypeLb, _artyRateOfFireLb, _artyRoundCountLb, _transportHeightCombo, _transportSpeedCombo, _transportRoeCombo];
{ lbClear _x } forEach [_transportUnitLb, _transportTaskLb, _casUnitLb, _casTaskLb, _casROELb, _casAttackRunLB, _artyUnitLb, _artyOrdnanceTypeLb, _artyRateOfFireLb, _artyRoundCountLb, _transportHeightCombo, _transportSpeedCombo, _transportRoeCombo];

//Markers
{ uinamespace setVariable [_x, nil] } forEach ["NEO_transportMarkerCreated", "NEO_casMarkerCreated", "NEO_artyMarkerCreated"];
{ _x setMarkerAlphaLocal 0 } forEach (_artyMarkers + [_supportMarker]);

switch (toUpper (_lb lbText _index)) do
{
	case "TRANSPORT" :
	{
		private ["_transportArray"];
		_transportArray = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", playerSide];

		if (count _transportArray > 0) then
		{
			_transportUnitText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>UNIT</t>";
			_transportHelpUnitText ctrlSetStructuredText parseText "<t color='#FFFF00' size='0.7' font='PuristaMedium'>Select a unit</t>";
			//done
			_transportConfirmButton ctrlEnable false; _transportConfirmButton ctrlSetPosition [0.519796* safezoneW + safezoneX, 0.6848 * safezoneH + safezoneY, (0.216525 * safezoneW), (0.028 * safezoneH)]; _transportConfirmButton ctrlCommit 0;
			_transportBaseButton ctrlEnable false; _transportBaseButton ctrlSetPosition [0.519796 * safezoneW + safezoneX, 0.6512 * safezoneH + safezoneY, (0.216525 * safezoneW), (0.028 * safezoneH)]; _transportBaseButton ctrlCommit 0;

			if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithPilot" }) then
			{
				_transportUnitLb ctrlEnable true;
				lbClear _transportUnitLb;
				{
					if (vehicle player == (_x select 0)) then
					{
						_transportUnitLb lbAdd (_x select 2);
						_transportUnitLb lbSetPicture [0, (getText (configFile >> "CfgVehicles" >> typeOf (_x select 0) >> "picture"))];
					};
				} forEach _transportArray;
			}
			else
			{
				_transportUnitLb ctrlEnable true;
				lbClear _transportUnitLb;
				{
					_transportUnitLb lbAdd (_x select 2);
					_transportUnitLb lbSetPicture [_forEachIndex, (getText (configFile >> "CfgVehicles" >> typeOf (_x select 0) >> "picture"))];
				} forEach _transportArray;
			};

			_transportUnitLb ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_transportUnitLbSelChanged"];
			_transportConfirmButton ctrlSetEventHandler ["ButtonClick", "_this call NEO_fnc_transportConfirmButton"];
			_transportBaseButton ctrlSetEventHandler ["ButtonClick", "_this call NEO_fnc_transportBaseButton"];
			_transportSmokeFoundButton ctrlSetEventHandler ["ButtonClick", "_this call NEO_fnc_transportSmokeFoundButton"];
			_transportSmokeNotFoundButton ctrlSetEventHandler ["ButtonClick", "_this call NEO_fnc_transportSmokeNotFoundButton"];

			if (count _transportArray < 2) then { lbSetCurSel [655568, 0] };
		};
	};

	case "CAS" :
	{
		private ["_casArray"];
		_casArray = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", playerSide];

		if (count _casArray > 0) then
		{
			_casUnitText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>UNIT</t>";
			_casHelpUnitText ctrlSetStructuredText parseText "<t color='#FFFF00' size='0.7' font='PuristaMedium'>Select a unit</t>";
			//done
			_casConfirmButton ctrlEnable false; _casConfirmButton ctrlSetPosition [0.519796 * safezoneW + safezoneX, 0.6848 * safezoneH + safezoneY, (0.216525 * safezoneW), (0.028 * safezoneH)]; _casConfirmButton ctrlCommit 0;
			_casBaseButton ctrlEnable false; _casBaseButton ctrlSetPosition [0.519796 * safezoneW + safezoneX, 0.6512 * safezoneH + safezoneY, (0.216525 * safezoneW), (0.028 * safezoneH)]; _casBaseButton ctrlCommit 0;

			_casUnitLb ctrlEnable true;
			lbClear _casUnitLb;
			{
				_casUnitLb lbAdd (_x select 2);
				_casUnitLb lbSetPicture [_forEachIndex, (getText (configFile >> "CfgVehicles" >> typeOf (_x select 0) >> "picture"))];
			} forEach _casArray;

			_casUnitLb ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_casUnitLbSelChanged"];
			_casTaskLb ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_casTaskLbSelChanged"];

			_casConfirmButton ctrlSetEventHandler ["ButtonClick", "_this call NEO_fnc_casConfirmButton"];
			_casBaseButton ctrlSetEventHandler ["ButtonClick", "_this call NEO_fnc_casBaseButton"];

			if (count _casArray < 2) then { lbSetCurSel [655582, 0] };
		};
	};


	case "ARTY" :
	{
		private ["_artyArray"];
		_artyArray = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", playerSide];

		if (count _artyArray > 0) then
		{
			_artyUnitText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>BATTERY</t>";
			_artyHelpUnitText ctrlSetStructuredText parseText "<t color='#FFFF00' size='0.7' font='PuristaMedium'>Select a unit</t>";
			//done
			_artyConfirmButton ctrlEnable false; _artyConfirmButton ctrlSetPosition [0.519796 * safezoneW + safezoneX, 0.6848 * safezoneH + safezoneY, (0.216525 * safezoneW), (0.028 * safezoneH)]; _artyConfirmButton ctrlCommit 0;
			_artyBaseButton ctrlEnable false; _artyBaseButton ctrlSetPosition [0.519796 * safezoneW + safezoneX, 0.6512 * safezoneH + safezoneY, (0.216525 * safezoneW), (0.028 * safezoneH)]; _artyBaseButton ctrlCommit 0;

			if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then
			{
				_artyUnitLb ctrlEnable true;
				lbClear _artyUnitLb;
				{
					if (((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 0 == _x select 0) then
					{
						_artyUnitLb lbAdd (_x select 2);
						_artyUnitLb lbSetPicture [0, (getText (configFile >> "CfgVehicles" >> typeOf ((_x select 3) select 0) >> "picture"))];
					};
				} forEach _artyArray;
			}
			else
			{
				_artyUnitLb ctrlEnable true;
				lbClear _artyUnitLb;
				{
					_artyUnitLb lbAdd (_x select 2);
					_artyUnitLb lbSetPicture [_forEachIndex, (getText (configFile >> "CfgVehicles" >> typeOf ((_x select 3) select 0) >> "picture"))];
				} forEach _artyArray;
			};

			_artyUnitLb ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_artyUnitLbSelChanged"];
			_artyConfirmButton ctrlSetEventHandler ["ButtonClick", "_this call NEO_fnc_artyConfirmButton"];
			_artyBaseButton ctrlSetEventHandler ["ButtonClick", "_this call NEO_fnc_artyBaseButton"];

			if (count _artyArray < 2) then { lbSetCurSel [655594, 0] };
		};
	};
};