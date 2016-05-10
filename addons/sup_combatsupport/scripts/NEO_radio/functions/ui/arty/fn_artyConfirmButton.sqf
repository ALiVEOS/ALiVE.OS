private
[
	"_display", "_artyArray", "_artyConfirmButton", "_artyUnitLb", "_artyOrdnanceTypeLb", "_artyRateOfFireLb",
	"_artyRoundCountLb", "_artyDispersionSlider", "_artyRateDelaySlider", "_battery", "_status", "_supportMarker",
	"_pos", "_type", "_ord", "_rate", "_count", "_dispersion", "_coord"
];
_display = findDisplay 655555;
_artyArray = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", playerSide];
_artyConfirmButton = _display displayCtrl 655597;
_artyUnitLb = _display displayCtrl 655594;
_artyOrdnanceTypeLb = _display displayCtrl 655601;
_artyRateOfFireLb = _display displayCtrl 655603;
_artyRoundCountLb = _display displayCtrl 655605;
_artyDispersionSlider = _display displayCtrl 655609;
_artyRateDelaySlider = _display displayCtrl 655612;
_battery = _artyArray select (lbCurSel _artyUnitLb) select 0; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _battery = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 0 };
_unit = _artyArray select (lbCurSel _artyUnitLb) select 1;

_status = _battery getVariable "NEO_radioArtyUnitStatus";
_supportMarker = NEO_radioLogic getVariable "NEO_supportMarker";
_pos = getMarkerPos _supportMarker; _pos set [2, 0];
_type = "IMMEDIATE";
_ordnanceType = _artyOrdnanceTypeLb lbText (lbCurSel _artyOrdnanceTypeLb);

//_ord = [_battery, _ordnanceType] CALL ALIVE_fnc_GetMagazineType;
_ord = [_battery, _ordnanceType] CALL ALIVE_fnc_getArtyMagazineType;

_rate = switch (_artyRateOfFireLb lbText (lbCurSel _artyRateOfFireLb)) do
{
	case "FULL" : { 0 };
	case "SEMI-FULL" : { round (sliderPosition _artyRateDelaySlider) };
	case DEFAULT { 0 };
};
_count = switch (_artyRoundCountLb lbText (lbCurSel _artyRoundCountLb)) do
{
	case "1 ROUND" : { 1 };
	case "3 ROUNDS" : { 3 };
	case "6 ROUNDS" : { 6 };
	case "12 ROUNDS" : { 12 };
	case "24 ROUNDS" : { 24 };
	case DEFAULT { 1 };
};
_dispersion = sliderPosition _artyDispersionSlider;
_coord = _pos call BIS_fnc_posToGrid;
_callsign = _artyArray select (lbCurSel _artyUnitLb) select 2; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _callsign = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 1 };
_callsignPlayer = (format ["%1", group player]) call NEO_fnc_callsignFix;

//Dislog from player
[[player,format["%1, this is %2. We need an %5 %7 round %6 strike at grid %3%4 with %8m dispersion and %9s delay. Over.", _callsign, _callSignPlayer, _coord select 0, _coord select 1, _type, _ordnanceType, _count, _dispersion, _rate],"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;


//NEW TASK
_battery setVariable ["NEO_radioArtyNewTask", [_type, _ordnanceType, _rate, _count, _dispersion, _pos, _unit, _ord, _callsignPlayer], true];

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
