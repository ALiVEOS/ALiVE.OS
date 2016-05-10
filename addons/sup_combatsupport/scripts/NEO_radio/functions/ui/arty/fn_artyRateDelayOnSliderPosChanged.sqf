private ["_display", "_slider", "_pos", "_casFlyHeightSliderText"];
_display = findDisplay 655555;
_slider = _this select 0;
_pos = round (_this select 1);
_artyRateDelayText = _display displayCtrl 655611;

_slider sliderSetPosition _pos;
_artyRateDelayText ctrlSetStructuredText parseText format ["<t color='#627057' size='0.8' font='PuristaMedium'>DELAY - %1/30s</t>", _pos];
