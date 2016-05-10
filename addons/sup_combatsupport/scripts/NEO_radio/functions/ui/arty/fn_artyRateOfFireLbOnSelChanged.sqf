private
[
	"_display", "_artyRateOfFireLb", "_rate", "_artyRoundCountLb", "_artyRateDelayText", "_artyRateDelaySlider"
];
_display = findDisplay 655555;
_artyRateOfFireLb = _this select 0;
_rate = _artyRateOfFireLb lbText (lbCurSel _artyRateOfFireLb);
_artyRoundCountLb = _display displayCtrl 655605;
_artyRateDelayText = _display displayCtrl 655611;
_artyRateDelaySlider = _display displayCtrl 655612;

if (_rate == "SEMI-FULL") then
{
	_artyRateDelayText ctrlSetStructuredText parseText "<t color='#627057' size='0.8' font='PuristaMedium'>DELAY - 5/30s</t>";

	_artyRateDelaySlider ctrlSetPosition [0.404129 * safezoneW + safezoneX, 0.710018 * safezoneH + safezoneY, (0.105833 * safezoneW), (0.0280024 * safezoneH)];
	_artyRateDelaySlider sliderSetRange [5, 30];
	_artyRateDelaySlider sliderSetspeed [1, 10];
	_artyRateDelaySlider sliderSetPosition 5;
	_artyRateDelaySlider ctrlCommit 0;
}
else
{
	_artyRateDelayText ctrlSetText "";
	_artyRateDelaySlider ctrlSetPosition [safeZoneX + (safeZoneW / 2), safeZoneY + (safeZoneH / 2), (safeZoneW / 1000), (safeZoneH / 1000)];
	_artyRateDelaySlider ctrlCommit 0;
};
