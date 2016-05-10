private ["_display", "_map"];
_display = findDisplay 655555;
_map = _display displayCtrl 655560;

private
[
	"_casArray", "_casUnitLb", "_casUnitText", "_casHelpUnitText", "_casConfirmButton", "_casBaseButton", "_casTaskLb", "_casTaskText",
	"_casTaskHelpText", "_casFlyHeightSlider", "_casFlyHeighSliderText", "_casRadiusSlider", "_casRadiusSliderText", "_supportMarker",
	"_veh", "_status"
];
_casArray = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", playerSide];
_casUnitLb = _display displayCtrl 655582;
_casUnitText = _display displayCtrl 655583;
_casHelpUnitText = _display displayCtrl 655584;
_casConfirmButton = _display displayCtrl 655585;
_casBaseButton = _display displayCtrl 655586;
_casTaskLb = _display displayCtrl 655587;
_sitRepButton = _display displayCtrl 655625;
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
_supportMarker = NEO_radioLogic getVariable "NEO_supportMarker";
_veh = _casArray select (lbCurSel _casUnitLb) select 0;
_status = _veh getVariable "NEO_radioCasUnitStatus";

//Status Text
_casHelpUnitText ctrlSetStructuredText parseText (switch (_status) do
{
	case "NONE" : { "<t color='#627057' size='0.7' font='PuristaMedium'>Unit is available and waiting for task</t>" };
	case "KILLED" : { "<t color='#603234' size='0.7' font='PuristaMedium'>Unit is combat ineffective</t>" };
	case "MISSION" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit is on a mission, you may abort or change the current task</t>" };
	case "RTB" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit is RTB</t>" };
});

//Marker
uinamespace setVariable ["NEO_casMarkerCreated", nil];
_supportMarker setMarkerAlphaLocal 0;

//Base Button
if (_status == "RTB" || _status == "NONE" || _status == "KILLED" || getPosATL _veh select 2 < 10) then
{
	_casBaseButton ctrlEnable false;
}
else
{
	_casBaseButton ctrlEnable true;
};

//Re-initialize Controls
{ _x ctrlSetPosition [1, 1, (safeZoneW / 1000), (safeZoneH / 1000)]; _x ctrlCommit 0; } forEach [_casFlyHeightSlider, _casRadiusSlider];
{ _x ctrlSetText "" } forEach [_casTaskText, _casTaskHelpText, _casROEText, _casFlyHeighSliderText, _casRadiusSliderText, _casAttackRunText];
{ lbClear _x } forEach [_casTaskLb,_casAttackRunLB, _casROELb];

if (_status != "KILLED") then
{
	//Targets Text
	_casTaskText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>TASK</t>";
	_casTaskHelpText ctrlSetStructuredText parseText "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Select a task</t>";

	//Tasks LB
	_casTaskLb ctrlEnable true;
	_sitRepButton ctrlEnable true;
	lbClear _casTaskLb;
	{
		_casTaskLb lbAdd _x;
	} forEach ["SAD","LOITER","ATTACK RUN"];

	//GPS
	uinamespace setVariable ["NEO_casMarkerCreated", nil];
	_supportMarker setMarkerAlphaLocal 0;

	//Sliders
	_casFlyHeighSliderText ctrlSetText "Altitude: Med";
	_casFlyHeighSliderText ctrlSetPosition [0.397304 * safezoneW + safezoneX, 0.514 * safezoneH + safezoneY, (0.105169 * safezoneW), (0.028 * safezoneH)];
	_casFlyHeighSliderText ctrlCommit 0;
	_casFlyHeightSlider ctrlSetPosition [0.402708 * safezoneW + safezoneX, 0.5508 * safezoneH + safezoneY, (0.0927966 * safezoneW), (0.0196 * safezoneH)];
	_casFlyHeightSlider ctrlCommit 0;

	_casFlyHeightSlider sliderSetRange [1, 3];
	_casFlyHeightSlider sliderSetspeed [1, 1];
	_casFlyHeightSlider sliderSetPosition 2;
	_casFlyHeightSlider ctrlSetEventHandler ["SliderPosChanged",
	"
		private [""_slider"", ""_pos"", ""_casFlyHeightSliderText"", ""_text""];
		_slider = _this select 0;
		_pos = round (_this select 1);
		_casFlyHeightSliderText = (findDisplay 655555) displayCtrl 655591;
		_text = switch (_pos) do
		{
			case 1 : { ""Altitude: Low"" };
			case 2 : { ""Altitude: Med"" };
			case 3 : { ""Altitude: High"" };
		};

		_slider sliderSetPosition _pos;
		_casFlyHeightSliderText ctrlSetText _text;
	"];

	//GPS
	_map ctrlSetEventHandler ["MouseButtonDown", "_this call NEO_fnc_radioMapEvent"];
};

//Confirm Button
[] call NEO_fnc_casConfirmButtonEnable;
