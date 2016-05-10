private ["_lb", "_index", "_display", "_map"];
_lb = _this select 0;
_index = _this select 1;
_display = findDisplay 655555;
_map = _display displayCtrl 655560;

private
[
	"_casArray", "_casUnitLb", "_casUnitText", "_casHelpUnitText", "_casConfirmButton", "_casBaseButton", "_casTaskLb", "_casTaskText",
	"_casTaskHelpText", "_show", "_veh", "_casRadiusSlider", "_casRadiusSliderText", "_casAttackRunText", "_casAttackRunLB"
];
_casArray = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", playerSide];
_casUnitLb = _display displayCtrl 655582;
_casUnitText = _display displayCtrl 655583;
_casHelpUnitText = _display displayCtrl 655584;
_casConfirmButton = _display displayCtrl 655585;
_casBaseButton = _display displayCtrl 655586;
_casTaskLb = _display displayCtrl 655587;
_casTaskText = _display displayCtrl 655588;
_casTaskHelpText = _display displayCtrl 655589;
_casAttackRunText = _display displayCtrl 655614;
_casAttackRunLB = _display displayCtrl 655613;
_casROELb = _display displayCtrl 655615;
_casROEText = _display displayCtrl 655616;

_show = switch (toUpper (_lb lbText _index)) do
{
	case "SAD" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to location, provide Close Air Support and engage all painted targets</t>" };
	case "LOITER" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to location and loiter without engaging any targets</t>" };
	case "ATTACK RUN" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to location and engage any known targets with the specified weapon</t>" };
};
_veh = _casArray select (lbCurSel _casUnitLb) select 0;
_casRadiusSlider = _display displayCtrl 655592;
_casRadiusSliderText = _display displayCtrl 655593;
_casAttackRunText ctrlSetText "";
_casAttackRunLB ctrlEnable false;

//Radius Slider
if (toUpper (_lb lbText _index) == "SAD" || toUpper (_lb lbText _index) == "LOITER" || toUpper (_lb lbText _index) == "ATTACK RUN") then
{

	_casRadiusSliderText ctrlSetText "CAS Radius: 500m";
	_casRadiusSliderText ctrlSetPosition [0.280111 * safezoneW + safezoneX, 0.514 * safezoneH + safezoneY, (0.0927966 * safezoneW), (0.028 * safezoneH)];
	_casRadiusSliderText ctrlCommit 0;
	_casRadiusSlider ctrlSetPosition [0.281002 * safezoneW + safezoneX, 0.5504 * safezoneH + safezoneY, (0.0927966 * safezoneW), (0.0196 * safezoneH)];
	_casRadiusSlider ctrlCommit 0;

	_casFlyHeighSliderText ctrlCommit 0;
	_casRadiusSlider sliderSetRange [250, 1000];
	_casRadiusSlider sliderSetspeed [50, 100];
	_casRadiusSlider sliderSetPosition 500;
	_casRadiusSlider ctrlSetEventHandler ["SliderPosChanged",
	"
		private [""_slider"", ""_pos"", ""_casRadiusSliderText"", ""_text""];
		_slider = _this select 0;
		_pos = round (_this select 1);
		_casRadiusSliderText = (findDisplay 655555) displayCtrl 655593;
		_text = format [""CAS Radius: %1m"", _pos];

		_slider sliderSetPosition _pos;
		_casRadiusSliderText ctrlSetText _text;
	"];

	_casROEText ctrlSetText "Rules of Engagment";
	_casROEText ctrlSetPosition [0.402708 * safezoneW + safezoneX, 0.59 * safezoneH + safezoneY, (0.0927966 * safezoneW), (0.028 * safezoneH)];
	_casROEText ctrlCommit 0;

	_casROELb ctrlEnable true;
	lbClear _casROELb;
	{
		_casROELb lbAdd (_x select 0);
		_casROELb lbSetData [_foreachIndex, (_x select 1)];
	} forEach [["Hold Fire","BLUE"], ["Hold Fire - Defend","GREEN"], ["Hold fire, engage at will","WHITE"],["Fire at will","YELLOW"],["Fire at will, engage at will","RED"]];
	_casROELb lbSetCurSel 4;


	if (toUpper (_lb lbText _index) == "ATTACK RUN") then {
		_casAttackRunText ctrlSetText "Choose Weapon";
		_casAttackRunText ctrlSetPosition [0.280111 * safezoneW + safezoneX, 0.59 * safezoneH + safezoneY, (0.0927966 * safezoneW), (0.028 * safezoneH)];
		_casAttackRunText ctrlCommit 0;

		_casAttackRunLB ctrlEnable true;
		lbClear _casAttackRunLB;
		{
			private "_weapon";
			_weapon = [(configFile>>"CfgWeapons">>_x)] call bis_fnc_displayName;
			_casAttackRunLB lbAdd _weapon;
		} forEach weapons _veh;

	} else {
		lbClear _casAttackRunLB;
		{
			private "_weapon";
			_weapon = [(configFile>>"CfgWeapons">>_x)] call bis_fnc_displayName;
			_casAttackRunLB lbAdd _weapon;
		} forEach weapons _veh;
		_casAttackRunLB lbSetCurSel 0;
	};
}
else
{
	_casRadiusSliderText ctrlSetText "";
	_casRadiusSliderText ctrlSetPosition [safeZoneX + (safeZoneW / 2.255), safeZoneY + (safeZoneH / 1.48), (safeZoneW / 1000), (safeZoneH / 1000)];
	_casRadiusSliderText ctrlCommit 0;
	_casRadiusSlider ctrlSetPosition [safeZoneX + (safeZoneW / 2.275), safeZoneY + (safeZoneH / 1.45), (safeZoneW / 1000), (safeZoneH / 1000)];
	_casRadiusSlider ctrlCommit 0;

	_casAttackRunText ctrlSetText "";
	_casAttackRunText ctrlCommit 0;

	_casAttackRunLB ctrlEnable false;
	_casROEText ctrlSetText "";
	_casROELb ctrlEnable false;
};

//Help Text
_casTaskHelpText ctrlSetStructuredText parseText _show;

//Confirm Button
[] call NEO_fnc_casConfirmButtonEnable;
