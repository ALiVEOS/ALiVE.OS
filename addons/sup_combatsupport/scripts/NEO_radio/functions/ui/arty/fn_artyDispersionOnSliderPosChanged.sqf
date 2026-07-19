private ["_display", "_slider", "_pos", "_casFlyHeightSliderText"];
_display = findDisplay 655555;
_slider = _this select 0;
_pos = round (_this select 1);
_artyDispersionText = _display displayCtrl 655608;

_slider sliderSetPosition _pos;
_artyDispersionText ctrlSetStructuredText parseText format ["<t color='#B4B4B4' size='0.8' font='PuristaMedium'>DISPERSION - %1/500m</t>", _pos];

// live-update the dispersion / beaten-zone ring while dragging, if a strike is placed
if (!isNil { uinamespace getVariable "NEO_artyMarkerCreated" }) then {
    [getMarkerPos (NEO_radioLogic getVariable "NEO_supportMarker"), _pos, "ColorOrange"] call NEO_fnc_supportDrawRing;
};
