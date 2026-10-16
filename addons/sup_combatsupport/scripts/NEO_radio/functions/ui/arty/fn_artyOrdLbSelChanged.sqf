private
[
    "_artyArray", "_display", "_artyOrdnanceTypeLb", "_artyRateOfFireText", "_artyRateOfFireLb", "_artyRoundCountText",
    "_artyRoundCountLb", "_artyDispersionText", "_artyDispersionSlider", "_artyUnitLb", "_artyRateDelayText", "_artyRateDelaySlider",
    "_battery", "_ord", "_count", "_countArray"
];
([] call ALiVE_fnc_tabletBox) params ["_uiX","_uiY","_uiW","_uiH"];

  	    _has_SPE_leFH18 = false;
  	    {
  	    	if(_x select 1 == "SPE_leFH18") then {
  	    		_has_SPE_leFH18 = true;
  	    	}
  	    } forEach SUP_ARTYARRAYS;
  
        _artyArray = []; 
        _artyArray append (NEO_radioLogic getVariable [format ["NEO_radioArtyArray_%1", playerSide], []]);
 
	      if (_has_SPE_leFH18) then { 
	      	if (playerSide != WEST) then {
	        _artyArray append (NEO_radioLogic getVariable [format ["NEO_radioArtyArray_%1", WEST], []]);
	        };
	      };

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
// the AI Commander's guns (F509): no battery object, rounds capped by the commander's own volley
private _cmdr = ["selected"] call NEO_fnc_artyCmdrBoard;
_ord = _artyOrdnanceTypeLb lbData (lbCurSel _artyOrdnanceTypeLb);
_count = 0;
_countArray = [];
{ _x ctrlSetBackgroundColor [0, 0, 0, 0] } forEach [_artyRateOfFireLb, _artyRoundCountLb];

if (_cmdr) then {
    _count = ["roundsCap"] call NEO_fnc_artyCmdrBoard;
} else {
    _battery = _artyArray select (lbCurSel _artyUnitLb) select 0;
    {
        if ((_x select 0) == _ord) then
        {
            _count = _x select 1;
        };
    } forEach (_battery getVariable "NEO_radioArtyBatteryRounds");
};
// the label is translated; the count itself goes in lbData, which is what the confirm button reads
{ if (_count >= _x) then { _countArray pushback _x } } forEach [1, 3, 6, 12, 24];

if (count _countArray > 0) then
{
    { _x ctrlSetBackgroundColor [0.047, 0.047, 0.047, 0.72] } forEach [_artyRateOfFireLb, _artyRoundCountLb];
    //Texts
    _artyRateOfFireText ctrlSetStructuredText parseText format ["<t color='#B4B4B4' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_RATE_OF_FIRE"];
    _artyRoundCountText ctrlSetStructuredText parseText format ["<t color='#B4B4B4' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_ROUND_COUNT"];
    _artyDispersionText ctrlSetStructuredText parseText format ["<t color='#B4B4B4' size='0.8' font='PuristaMedium'>%1</t>", [format [localize "STR_ALIVE_CS_UI_DISPERSION", 0], localize "STR_ALIVE_CS_UI_CMDR_DISPERSION"] select _cmdr];

    //Rate Of Fire Type LB
    _artyRateOfFireLb ctrlEnable true;
    lbClear _artyRateOfFireLb;
    {
        private _row = _artyRateOfFireLb lbAdd localize ("STR_ALIVE_CS_UI_RATE_" + _x);
        _artyRateOfFireLb lbSetData [_row, _x];
    } forEach (["RAPID", "STAGGERED"] select [0, [2, 1] select _cmdr]);

    //Rate Of Fire Type LB
    _artyRoundCountLb ctrlEnable true;
    lbClear _artyRoundCountLb;
    {
        private _row = _artyRoundCountLb lbAdd format [localize (["STR_ALIVE_CS_UI_ROUNDS_N", "STR_ALIVE_CS_UI_ROUNDS_1"] select (_x == 1)), _x];
        _artyRoundCountLb lbSetData [_row, str _x];
    } forEach _countArray;

    //Slider (the commander sets its own dispersion, so its slider stays hidden)
    if (!_cmdr) then {
    _artyDispersionSlider ctrlSetPosition [0.270903 * _uiW + _uiX, 0.710018 * _uiH + _uiY, (0.105833 * _uiW), (0.0280024 * _uiH)];
    _artyDispersionSlider sliderSetRange [0, 500];
    _artyDispersionSlider sliderSetspeed [1, 50];
    _artyDispersionSlider sliderSetPosition 0;
    _artyDispersionSlider ctrlCommit 0;
    };

    //Event Handlers
    _artyRateOfFireLb ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_artyConfirmButtonEnable; _this call NEO_fnc_artyRateOfFireLbOnSelChanged;"];
    _artyRoundCountLb ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_artyConfirmButtonEnable"];
    _artyDispersionSlider ctrlSetEventHandler ["SliderPosChanged", "_this call NEO_fnc_artyDispersionOnSliderPosChanged"];
    _artyRateDelaySlider ctrlSetEventHandler ["SliderPosChanged", "_this call NEO_fnc_artyRateDelayOnSliderPosChanged"];

    // default RATE OF FIRE = RAPID and ROUND COUNT = 1 ROUND so the panel is
    // ready to fire once a battery and target are picked
    _artyRateOfFireLb lbSetCurSel 0;
    if (lbSize _artyRoundCountLb > 0) then { _artyRoundCountLb lbSetCurSel 0; };
};
