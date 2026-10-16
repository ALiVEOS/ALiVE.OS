private
[
    "_display", "_artyArray", "_artyConfirmButton", "_artyUnitLb", "_artyOrdnanceTypeLb", "_artyRateOfFireLb",
    "_artyRoundCountLb", "_battery", "_status"
];
_display = findDisplay 655555;

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

_artyConfirmButton = _display displayCtrl 655597;
_artyUnitLb = _display displayCtrl 655594;
_artyOrdnanceTypeLb = _display displayCtrl 655601;
_artyRateOfFireLb = _display displayCtrl 655603;
_artyRoundCountLb = _display displayCtrl 655605;

// the AI Commander's guns (F509): Confirm needs a grid that a ready commander battery can reach with
// the chosen round, and waits 15 s after a request for the commander's answer
if (["selected"] call NEO_fnc_artyCmdrBoard) exitWith {
    private _fresh = !isNil { uinamespace getVariable "NEO_artyMarkerCreated" };
    private _ls = NEO_radioLogic getVariable ["NEO_supportMarkerArtyLastShot", ""];
    private _hasMarker = _fresh || {_ls != "" && {markerAlpha _ls > 0}};
    private _rowsOk = lbCurSel _artyOrdnanceTypeLb != -1 && {lbCurSel _artyRateOfFireLb != -1} && {lbCurSel _artyRoundCountLb != -1};
    private _recent = time - (missionNamespace getVariable ["NEO_artyCmdrSentAt", -100]) < 15;
    private _ok = false;
    private _pos = [0, 0, 0];
    if (_hasMarker) then {
        _pos = if (_fresh) then { getMarkerPos (NEO_radioLogic getVariable "NEO_supportMarker") } else { getMarkerPos _ls };
        private _ord = _artyOrdnanceTypeLb lbData (lbCurSel _artyOrdnanceTypeLb);
        _ok = _rowsOk && {!_recent} && {["inRange", [_pos, _ord]] call NEO_fnc_artyCmdrBoard};
    };
    _artyConfirmButton ctrlEnable _ok;
    if (_hasMarker) then {
        private _help = _display displayCtrl 655596;
        if (_ok) then {
            _help ctrlSetStructuredText parseText format ["<t color='#627057' size='0.7' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_CMDR_HELP"];
        } else {
            private _key = if (_recent) then { "STR_ALIVE_CS_UI_CMDR_SENT" } else {
                ["STR_ALIVE_CS_UI_CMDR_OUT_OF_RANGE", "STR_ALIVE_CS_UI_CMDR_BUSY"] select (["inReach", [_pos]] call NEO_fnc_artyCmdrBoard)
            };
            _help ctrlSetStructuredText parseText format ["<t color='#FFFF73' size='0.7' font='PuristaMedium'>%1</t>", localize _key];
        };
    };
};

_battery = _artyArray select (lbCurSel _artyUnitLb) select 0; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _battery = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 0 };
_status = _battery getVariable "NEO_radioArtyUnitStatus";

if
(
    (
        !isNil { uinamespace getVariable "NEO_artyMarkerCreated" }
        ||
        {
            private _ls = NEO_radioLogic getVariable ["NEO_supportMarkerArtyLastShot", ""];
            _ls != "" && {markerAlpha _ls > 0}
        }
    )
    &&
    _status != "KILLED"
    &&
    _status != "MISSION"
    &&
    _status != "RTB"
    &&
    lbCurSel _artyUnitLb != -1
    &&
    lbCurSel _artyOrdnanceTypeLb != -1
    &&
    lbCurSel _artyRateOfFireLb != -1
    &&
    lbCurSel _artyRoundCountLb != -1
)
then
{
    _artyConfirmButton ctrlEnable true;
}
else
{
    _artyConfirmButton ctrlEnable false;
};
