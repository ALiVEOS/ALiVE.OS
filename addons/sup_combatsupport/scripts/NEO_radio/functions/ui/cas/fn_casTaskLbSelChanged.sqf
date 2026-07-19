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
_casArray = NEO_radioLogic getVariable [format ["NEO_radioCasArray_%1", playerSide], []];
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

_show = switch (toUpper (_lb lbData _index)) do
{
    case "SAD" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to location, provide Close Air Support and engage all painted targets</t>" };
    case "LOITER" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to location and loiter without engaging any targets</t>" };
    case "ATTACK" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit engages all hostiles in the target area, including unmanned vehicles. Lase a target to designate it manually - the pilot will prioritise your laser. Automatic uses the best weapon first and switches as ammo runs out; pick a specific weapon below to force it</t>" };
};
_veh = _casArray select (lbCurSel _casUnitLb) select 0;
_casRadiusSlider = _display displayCtrl 655592;
_casRadiusSliderText = _display displayCtrl 655593;
_casAttackRunText ctrlSetText "";
_casAttackRunLB ctrlEnable false;

//Radius Slider
if (toUpper (_lb lbData _index) == "SAD" || toUpper (_lb lbData _index) == "LOITER" || toUpper (_lb lbData _index) == "ATTACK") then
{

    _casRadiusSliderText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>CAS Radius: 500m</t>";
    _casRadiusSliderText ctrlSetPosition [0.280111 * safezoneW + safezoneX, 0.514 * safezoneH + safezoneY, (0.0927966 * safezoneW), (0.028 * safezoneH)];
    _casRadiusSliderText ctrlCommit 0;
    _casRadiusSlider ctrlSetPosition [0.281002 * safezoneW + safezoneX, 0.5504 * safezoneH + safezoneY, (0.0927966 * safezoneW), (0.0196 * safezoneH)];
    _casRadiusSlider ctrlCommit 0;

    _casFlyHeighSliderText ctrlCommit 0;
    _casRadiusSlider sliderSetRange [250, 1000];
    _casRadiusSlider sliderSetspeed [50, 100];
    _casRadiusSlider sliderSetPosition 500;
    // keep the engagement ring in step when the radius resets on a task switch -
    // sliderSetPosition does not fire SliderPosChanged, so redraw the ring explicitly
    if (!isNil { uinamespace getVariable "NEO_casMarkerCreated" }) then {
        [getMarkerPos (NEO_radioLogic getVariable "NEO_supportMarker"), 500, "ColorBlue"] call NEO_fnc_supportDrawRing;
    };
    _casRadiusSlider ctrlSetEventHandler ["SliderPosChanged",
    "
        private [""_slider"", ""_pos"", ""_casRadiusSliderText"", ""_text""];
        _slider = _this select 0;
        _pos = round (_this select 1);
        _casRadiusSliderText = (findDisplay 655555) displayCtrl 655593;
        _text = format [""CAS Radius: %1m"", _pos];

        _slider sliderSetPosition _pos;
        _casRadiusSliderText ctrlSetStructuredText parseText format [""<t color='#B4B4B4' size='0.8' font='PuristaMedium'>%1</t>"", _text];

        if (!isNil { uinamespace getVariable ""NEO_casMarkerCreated"" }) then {
            [getMarkerPos (NEO_radioLogic getVariable ""NEO_supportMarker""), _pos, ""ColorBlue""] call NEO_fnc_supportDrawRing;
        };
    "];

    // ROE only matters for tasks that actually engage - LOITER never fires, so hide it
    if (toUpper (_lb lbData _index) == "LOITER") then {
        _casROEText ctrlSetText "";
        _casROELb ctrlEnable false;
        lbClear _casROELb;
    } else {
        _casROEText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>RULES OF ENGAGEMENT</t>";
        // sits just left of the ROE list so "RULES OF ENGAGEMENT" reads flush with it;
        // wide (transparent bg, so the extra width is invisible) to stay on one line
        _casROEText ctrlSetPosition [0.38 * safezoneW + safezoneX, 0.59 * safezoneH + safezoneY, (0.16 * safezoneW), (0.028 * safezoneH)];
        _casROEText ctrlCommit 0;

        _casROELb ctrlEnable true;
        lbClear _casROELb;
        {
            _casROELb lbAdd (_x select 0);
            _casROELb lbSetData [_foreachIndex, (_x select 1)];
        } forEach [["Hold Fire","BLUE"], ["Hold Fire - Defend","GREEN"], ["Hold Fire - Return Fire","WHITE"],["Fire At Will","YELLOW"],["Fire At Will - Engage At Will","RED"]];
        _casROELb lbSetCurSel 4;
    };


    // one shared filter with the runtime weapon logic - see NEO_fnc_casUsableWeapons
    // (keeps deliverable guns/rockets/bombs/ground missiles; drops the laser
    // designator, countermeasures, air-to-air-only missiles and no-damage dummies)
    private _usableWeapons = [_veh] call NEO_fnc_casUsableWeapons;
    if (toUpper (_lb lbData _index) == "ATTACK") then {
        _casAttackRunText ctrlSetStructuredText parseText "<t color='#B4B4B4' size='0.8' font='PuristaMedium'>CHOOSE WEAPON</t>";
        _casAttackRunText ctrlSetPosition [0.280111 * safezoneW + safezoneX, 0.59 * safezoneH + safezoneY, (0.0927966 * safezoneW), (0.028 * safezoneH)];
        _casAttackRunText ctrlCommit 0;

        _casAttackRunLB ctrlEnable true;
        lbClear _casAttackRunLB;
        // AUTO heads the list and is the default: the pilot picks the best loaded
        // weapon and switches to another as ammo runs out
        private _autoRow = _casAttackRunLB lbAdd "Automatic (pilot's choice)";
        _casAttackRunLB lbSetData [_autoRow, "AUTO"];
        {
            private ["_row", "_fam", "_name"];
            // family tag so the player can tell a gun from a bomb at a glance, e.g. "[GUN] M230"
            _fam = [_x] call NEO_fnc_casWeaponFamily;
            _name = [(configFile >> "CfgWeapons" >> _x)] call bis_fnc_displayName;
            if (_fam != "OTHER") then { _name = format ["[%1] %2", _fam, _name]; };
            _row = _casAttackRunLB lbAdd _name;
            _casAttackRunLB lbSetData [_row, _x];
            _casAttackRunLB lbSetTooltip [_row, _name]; // full label on hover - the narrow row can clip long modded names
        } forEach _usableWeapons;
        if (lbSize _casAttackRunLB > 0) then { _casAttackRunLB lbSetCurSel 0; };

    } else {
        if (toUpper (_lb lbData _index) == "LOITER") then {
            // loiter never delivers ordnance - no weapon picker, no greyed clutter
            lbClear _casAttackRunLB;
            _casAttackRunLB ctrlEnable false;
        } else {
            lbClear _casAttackRunLB;
            {
                private ["_row", "_fam", "_name"];
                _fam = [_x] call NEO_fnc_casWeaponFamily;
                _name = [(configFile >> "CfgWeapons" >> _x)] call bis_fnc_displayName;
                if (_fam != "OTHER") then { _name = format ["[%1] %2", _fam, _name]; };
                _row = _casAttackRunLB lbAdd _name;
                _casAttackRunLB lbSetData [_row, _x];
                _casAttackRunLB lbSetTooltip [_row, _name];
            } forEach _usableWeapons;
            if (lbSize _casAttackRunLB > 0) then { _casAttackRunLB lbSetCurSel 0; };
        };
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
