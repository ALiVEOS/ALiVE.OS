private ["_display", "_text", "_lb", "_index", "_slider", "_sliderText", "_show", "_chopper"];
([] call ALiVE_fnc_tabletBox) params ["_uiX","_uiY","_uiW","_uiH"];
_display = findDisplay 655555;
_text = _display displayCtrl 655573;
_lb = _this select 0;
_index = _this select 1;
_slider = _display displayCtrl 655578;
_sliderText = _display displayCtrl 655579;
_objectLb = _display displayCtrl 655580;

_transportArray = NEO_radioLogic getVariable [format ["NEO_radioTrasportArray_%1", playerSide], []];
_transportUnitLb = _display displayCtrl 655568;

if (!isNil {NEO_radioLogic getVariable "NEO_radioTalkWithPilot"}) then {
    _chopper = NEO_radioLogic getVariable "NEO_radioTalkWithPilot";
}
else {
    _chopper = _transportArray select (lbCurSel _transportUnitLb) select 0;
};

_show = switch (toUpper (_lb lbData _index)) do
{
    case "PICKUP" : { format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_TR_PICKUP"] };
    case "LAND" : { format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_TR_LAND"] };
    case "LAND (ENG OFF)" : { format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_TR_LAND_ENG_OFF"] };
    case "MOVE" : { format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_TR_MOVE"] };
    case "CIRCLE" : { format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_TR_CIRCLE"] };
    case "INSERTION" : { format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_TR_INSERTION"] };
    case "SLINGLOAD" : { format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_TR_SLINGLOAD"] };
    case "UNHOOK" : { format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_TR_UNHOOK"] };
    case "MEDEVAC" : { format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_TR_MEDEVAC"] };
    case "PARADROP" : { format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_TR_PARADROP"] };
};

//Help Text
_text ctrlSetStructuredText parseText _show;

//Confirm Button
[] call NEO_fnc_transportConfirmButtonEnable;

//Slider
_task = switch (_lb lbData _index) do
{
    CASE "CIRCLE" :
    {
        _objectLb ctrlSetPosition [_uiX + (_uiW / 2.275), _uiY + (_uiH / 1.45), (_uiW / 1000), (_uiH / 1000)];
        _objectLb ctrlCommit 0;
        _objectLb ctrlEnable false;
        _slider ctrlSetPosition [0.281002 * _uiW + _uiX, 0.5504 * _uiH + _uiY, (0.0927966 * _uiW), (0.0196 * _uiH)];
        _slider ctrlCommit 0;
        _sliderText ctrlSetText format [localize "STR_ALIVE_CS_UI_TR_RADIUS", 200];
        _sliderText ctrlSetPosition [0.280111 * _uiW + _uiX, 0.52 * _uiH + _uiY, (0.19 * _uiW), (0.028 * _uiH)]; // over its slider; 0.225 fell off the left of the tablet screen
        _sliderText ctrlCommit 0;

        _slider sliderSetRange [100, 300];
        _slider sliderSetspeed [50, 100];
        _slider sliderSetPosition 200;
        _slider ctrlSetEventHandler ["SliderPosChanged",
        "
            private [""_slider"", ""_pos"", ""_sliderText""];
            _slider = _this select 0;
            _pos = round (_this select 1);
            _sliderText = (findDisplay 655555) displayCtrl 655579;

            _sliderText ctrlSetText format [localize ""STR_ALIVE_CS_UI_TR_RADIUS"", _pos];
        "]
    };
    CASE "INSERTION" :
    {
        _objectLb ctrlSetPosition [_uiX + (_uiW / 2.275), _uiY + (_uiH / 1.45), (_uiW / 1000), (_uiH / 1000)];
        _objectLb ctrlCommit 0;
        _objectLb ctrlEnable false;
        _slider ctrlSetPosition [0.281002 * _uiW + _uiX, 0.5504 * _uiH + _uiY, (0.0927966 * _uiW), (0.0196 * _uiH)];
        _slider ctrlCommit 0;
        _sliderText ctrlSetText format [localize "STR_ALIVE_CS_UI_TR_HEIGHT", 25];
        _sliderText ctrlSetPosition [0.280111 * _uiW + _uiX, 0.52 * _uiH + _uiY, (0.19 * _uiW), (0.028 * _uiH)]; // over its slider; 0.225 fell off the left of the tablet screen
        _sliderText ctrlCommit 0;

        _slider sliderSetRange [2, 50];
        _slider sliderSetspeed [1, 10];
        _slider sliderSetPosition 25;
        _slider ctrlSetEventHandler ["SliderPosChanged",
        "
            private [""_slider"", ""_pos"", ""_sliderText""];
            _slider = _this select 0;
            _pos = round (_this select 1);
            _sliderText = (findDisplay 655555) displayCtrl 655579;

            _sliderText ctrlSetText format [localize ""STR_ALIVE_CS_UI_TR_HEIGHT"", _pos];
        "]
    };

    // the height the passengers jump from, above the ground
    CASE "PARADROP" :
    {
        _objectLb ctrlSetPosition [_uiX + (_uiW / 2.275), _uiY + (_uiH / 1.45), (_uiW / 1000), (_uiH / 1000)];
        _objectLb ctrlCommit 0;
        _objectLb ctrlEnable false;
        _slider ctrlSetPosition [0.281002 * _uiW + _uiX, 0.5504 * _uiH + _uiY, (0.0927966 * _uiW), (0.0196 * _uiH)];
        _slider ctrlCommit 0;
        _sliderText ctrlSetText format [localize "STR_ALIVE_CS_UI_TR_DROPHEIGHT", 250];
        _sliderText ctrlSetPosition [0.280111 * _uiW + _uiX, 0.52 * _uiH + _uiY, (0.19 * _uiW), (0.028 * _uiH)]; // over its slider; 0.225 fell off the left of the tablet screen
        _sliderText ctrlCommit 0;

        _slider sliderSetRange [150, 500];
        _slider sliderSetspeed [25, 50];
        _slider sliderSetPosition 250;
        _slider ctrlSetEventHandler ["SliderPosChanged",
        "
            private [""_slider"", ""_pos"", ""_sliderText""];
            _slider = _this select 0;
            _pos = round (_this select 1);
            _sliderText = (findDisplay 655555) displayCtrl 655579;

            _sliderText ctrlSetText format [localize ""STR_ALIVE_CS_UI_TR_DROPHEIGHT"", _pos];
        "]
    };

    CASE "SLINGLOAD" :
    {
        private ["_pos"];
        _slider ctrlSetPosition [_uiX + (_uiW / 2.275), _uiY + (_uiH / 1.45), (_uiW / 1000), (_uiH / 1000)];
        _slider ctrlCommit 0;
        _objectLb ctrlSetPosition [0.280111 * _uiW + _uiX, 0.5504 * _uiH + _uiY, (0.22 * _uiW), (0.028 * _uiH)];
        _objectLb ctrlCommit 0;
        _sliderText ctrlSetText localize "STR_ALIVE_CS_UI_TR_SELECT_CARGO";
        _sliderText ctrlSetPosition [0.280111 * _uiW + _uiX, 0.52 * _uiH + _uiY, (0.19 * _uiW), (0.028 * _uiH)]; // indent to line up with the cargo box below (was 0.225, flush with the section labels)
        _sliderText ctrlCommit 0;

        _pos = getMarkerPos (uinamespace getVariable ["NEO_transportMarkerCreated","unknown"]);

        if (_pos isEqualTo [0,0,0]) then {_pos = getpos player;};

        _objectLb ctrlEnable true;
        lbClear _objectLb;

        _nearestObjects = nearestObjects [_pos, [], 100];
        {
            if ( count (getArray (configFile >> "CfgVehicles" >> typeOf _x >> "slingLoadCargoMemoryPoints")) > 0  && ([_x] call ALiVE_fnc_getObjectWeight < [(configFile >> "CfgVehicles" >> typeOf _chopper >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue)) then {
                private ["_idx"];
                // diag_log _x;
                _idx = _objectLb lbAdd (getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName"));
                // _objectLb lbSetPicture [_idx, (getText (configFile >> "CfgVehicles" >> typeOf _x >> "picture"))];
                _objectLb lbSetData [_idx, str(getpos _x)];
            };
        } forEach _nearestObjects;

        // no liftable cargo nearby - tell the player rather than leave a blank list + silent confirm
        if (lbSize _objectLb == 0) then {
            _sliderText ctrlSetText localize "STR_ALIVE_CS_UI_TR_NO_CARGO";
        } else {
            // only auto-select when there IS cargo; lbSetCurSel 0 on an empty list fires LBSelChanged
            // with empty lbData, and parseSimpleArray "" throws a format error
            _objectLb lbSetCurSel 0;
        };

        _objectLb ctrlSetEventHandler ["LBSelChanged",
        "
            private [""_lb"", ""_pos"", ""_sliderText""];
            _lb = _this select 0;
            _pos = parseSimpleArray (_lb lbData (_this select 1));
            _marker = NEO_radioLogic getVariable ""NEO_supportMarker"";
            _marker setMarkerPosLocal _pos;
            uinamespace setVariable [""NEO_transportMarkerCreated"", _marker];
        "];
    };
    CASE DEFAULT
    {
        _objectLb ctrlSetPosition [_uiX + (_uiW / 2.275), _uiY + (_uiH / 1.45), (_uiW / 1000), (_uiH / 1000)];
        _objectLb ctrlCommit 0;
        _objectLb ctrlEnable false;
        _slider ctrlSetPosition [_uiX + (_uiW / 2.275), _uiY + (_uiH / 1.45), (_uiW / 1000), (_uiH / 1000)];
        _slider ctrlCommit 0;
        _sliderText ctrlSetText "";
        _sliderText ctrlSetPosition [_uiX + (_uiW / 2.255), _uiY + (_uiH / 1.48), (_uiW / 1000), (_uiH / 1000)];
        _sliderText ctrlCommit 0;
    };
};
