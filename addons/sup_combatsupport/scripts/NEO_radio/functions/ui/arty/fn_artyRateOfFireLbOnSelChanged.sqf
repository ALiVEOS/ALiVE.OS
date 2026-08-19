private
[
    "_display", "_artyRateOfFireLb", "_rate", "_artyRoundCountLb", "_artyRateDelayText", "_artyRateDelaySlider"
];
([] call ALiVE_fnc_tabletBox) params ["_uiX","_uiY","_uiW","_uiH"];
_display = findDisplay 655555;
_artyRateOfFireLb = _this select 0;
_rate = _artyRateOfFireLb lbText (lbCurSel _artyRateOfFireLb);
_artyRoundCountLb = _display displayCtrl 655605;
_artyRateDelayText = _display displayCtrl 655611;
_artyRateDelaySlider = _display displayCtrl 655612;

if (_rate == "STAGGERED") then
{
    _artyRateDelayText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>DELAY - 5/30s</t>";

    _artyRateDelaySlider ctrlSetPosition [0.404129 * _uiW + _uiX, 0.710018 * _uiH + _uiY, (0.105833 * _uiW), (0.0280024 * _uiH)];
    _artyRateDelaySlider sliderSetRange [5, 30];
    _artyRateDelaySlider sliderSetspeed [1, 10];
    _artyRateDelaySlider sliderSetPosition 5;
    _artyRateDelaySlider ctrlCommit 0;
}
else
{
    _artyRateDelayText ctrlSetText "";
    _artyRateDelaySlider ctrlSetPosition [_uiX + (_uiW / 2), _uiY + (_uiH / 2), (_uiW / 1000), (_uiH / 1000)];
    _artyRateDelaySlider ctrlCommit 0;
};
