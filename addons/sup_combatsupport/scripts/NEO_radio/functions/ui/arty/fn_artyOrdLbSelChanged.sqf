private
[
	"_artyArray", "_display", "_artyOrdnanceTypeLb", "_artyRateOfFireText", "_artyRateOfFireLb", "_artyRoundCountText",
	"_artyRoundCountLb", "_artyDispersionText", "_artyDispersionSlider", "_artyUnitLb", "_artyRateDelayText", "_artyRateDelaySlider",
	"_battery", "_ord", "_count", "_countArray"
];
_artyArray = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", playerSide];
_display = findDisplay 655555;
_artyOrdnanceTypeLb = _this select 0;
_artyRateOfFireText = _display displayCtrl 655602;
_artyRateOfFireLb = _display displayCtrl 655603;
_artyRoundCountText = _display displayCtrl 655604;
_artyRoundCountLb = _display displayCtrl 655605;
_artyDispersionText = _display displayCtrl 655608;
_artyDispersionSlider = _display displayCtrl 655609;
_artyUnitLb = _display displayCtrl 655594;
_artyRateDelayText = _display displayCtrl 655611;
_artyRateDelaySlider = _display displayCtrl 655612;
_battery = _artyArray select (lbCurSel _artyUnitLb) select 0;
_ord = _artyOrdnanceTypeLb lbText (lbCurSel _artyOrdnanceTypeLb);
_count = 0;
_countArray = [];

{
	if ((_x select 0) == _ord) then
	{
		_count = _x select 1;
	};
} forEach (_battery getVariable "NEO_radioArtyBatteryRounds");
if (_count >= 1) then { _countArray set [count _countArray, "1 ROUND"] };
if (_count >= 3) then { _countArray set [count _countArray, "3 ROUNDS"] };
if (_count >= 6) then { _countArray set [count _countArray, "6 ROUNDS"] };
if (_count >= 12) then { _countArray set [count _countArray, "12 ROUNDS"] };
if (_count >= 24) then { _countArray set [count _countArray, "24 ROUNDS"] };

if (count _countArray > 0) then
{
	//Texts
	_artyRateOfFireText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>RATE OF FIRE</t>";
	_artyRoundCountText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>ROUND COUNT</t>";
	_artyDispersionText ctrlSetStructuredText parseText "<t color='#627057' size='0.8' font='PuristaMedium'>DISPERSION - 0/500m</t>";

	//Rate Of Fire Type LB
	_artyRateOfFireLb ctrlEnable true;
	lbClear _artyRateOfFireLb;
	{
		_artyRateOfFireLb lbAdd _x;
	} forEach ["FULL", "SEMI-FULL"];

	//Rate Of Fire Type LB
	_artyRoundCountLb ctrlEnable true;
	lbClear _artyRoundCountLb;
	{
		_artyRoundCountLb lbAdd _x;
	} forEach _countArray;

	//Slider
	_artyDispersionSlider ctrlSetPosition [0.270903 * safezoneW + safezoneX, 0.710018 * safezoneH + safezoneY, (0.105833 * safezoneW), (0.0280024 * safezoneH)];
	_artyDispersionSlider sliderSetRange [0, 500];
	_artyDispersionSlider sliderSetspeed [1, 50];
	_artyDispersionSlider sliderSetPosition 0;
	_artyDispersionSlider ctrlCommit 0;

	//Event Handlers
	_artyRateOfFireLb ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_artyConfirmButtonEnable; _this call NEO_fnc_artyRateOfFireLbOnSelChanged;"];
	_artyRoundCountLb ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_artyConfirmButtonEnable"];
	_artyDispersionSlider ctrlSetEventHandler ["SliderPosChanged", "_this call NEO_fnc_artyDispersionOnSliderPosChanged"];
	_artyRateDelaySlider ctrlSetEventHandler ["SliderPosChanged", "_this call NEO_fnc_artyRateDelayOnSliderPosChanged"];
};
