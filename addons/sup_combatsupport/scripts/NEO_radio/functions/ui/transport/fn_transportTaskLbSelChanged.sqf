private ["_display", "_text", "_lb", "_index", "_slider", "_sliderText", "_show"];
_display = findDisplay 655555;
_text = _display displayCtrl 655573;
_lb = _this select 0;
_index = _this select 1;
_slider = _display displayCtrl 655578;
_sliderText = _display displayCtrl 655579;
_objectLb = _display displayCtrl 655580;
_show = switch (toUpper (_lb lbText _index)) do
{
    case "PICKUP" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to location and wait for a smoke visual and confirmation (EVAC)</t>" };
    case "LAND" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to coordinates and land the chopper at his discression (DROP)</t>" };
    case "LAND (ENG OFF)" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to coordinates and land the chopper at his discression and will shutdown engine (DROP)</t>" };
    case "MOVE" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to designated position and wait for further orders</t>" };
    case "CIRCLE" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to designated coordinates and circle the area clockwise till further notice</t>" };
    case "INSERTION" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to designated coordinates and will hover for rope insertion</t>" };
    case "SLINGLOAD" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to designated coordinates and slingload nearest available object</t>" };
    case "UNHOOK" : { "<t color='#FFFF73' size='0.7' font='PuristaMedium'>Unit will move to designated coordinates and unhook current slingload</t>" };
};

//Help Text
_text ctrlSetStructuredText parseText _show;

//Confirm Button
[] call NEO_fnc_transportConfirmButtonEnable;

//Slider
_task = switch (_lb lbText _index) do
{
    CASE "CIRCLE" :
    {
        _objectLb ctrlSetPosition [safeZoneX + (safeZoneW / 2.275), safeZoneY + (safeZoneH / 1.45), (safeZoneW / 1000), (safeZoneH / 1000)];
        _objectLb ctrlCommit 0;
        _slider ctrlSetPosition [0.281002 * safezoneW + safezoneX, 0.5504 * safezoneH + safezoneY, (0.0927966 * safezoneW), (0.0196 * safezoneH)];
        _slider ctrlCommit 0;
        _sliderText ctrlSetText "Radius: 200/300";
        _sliderText ctrlSetPosition [0.225 * safezoneW + safezoneX, 0.52 * safezoneH + safezoneY, (0.19 * safezoneW), (0.028 * safezoneH)];
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

            _sliderText ctrlSetText format [""Radius: %1/300"", _pos];
        "]
    };
    CASE "INSERTION" :
    {
        _objectLb ctrlSetPosition [safeZoneX + (safeZoneW / 2.275), safeZoneY + (safeZoneH / 1.45), (safeZoneW / 1000), (safeZoneH / 1000)];
        _objectLb ctrlCommit 0;
        _slider ctrlSetPosition [0.281002 * safezoneW + safezoneX, 0.5504 * safezoneH + safezoneY, (0.0927966 * safezoneW), (0.0196 * safezoneH)];
        _slider ctrlCommit 0;
        _sliderText ctrlSetText "Height: 20/50";
        _sliderText ctrlSetPosition [0.225 * safezoneW + safezoneX, 0.52 * safezoneH + safezoneY, (0.19 * safezoneW), (0.028 * safezoneH)];
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

            _sliderText ctrlSetText format [""Height: %1/50"", _pos];
        "]
    };

    CASE "SLINGLOAD" :
    {
        private ["_pos"];
        _slider ctrlSetPosition [safeZoneX + (safeZoneW / 2.275), safeZoneY + (safeZoneH / 1.45), (safeZoneW / 1000), (safeZoneH / 1000)];
        _slider ctrlCommit 0;
        _objectLb ctrlSetPosition [0.280111 * safezoneW + safezoneX, 0.5504 * safezoneH + safezoneY, (0.22 * safezoneW), (0.028 * safezoneH)];
        _objectLb ctrlCommit 0;
        _sliderText ctrlSetText "Select cargo to lift:";
        _sliderText ctrlSetPosition [0.225 * safezoneW + safezoneX, 0.52 * safezoneH + safezoneY, (0.19 * safezoneW), (0.028 * safezoneH)];
        _sliderText ctrlCommit 0;

        _pos = getMarkerPos (uinamespace getVariable ["NEO_transportMarkerCreated","unknown"]);

        if (isNil "_pos" || {str(_pos) == "[0,0,0]"}) then {_pos = getpos player;};

        _objectLb ctrlEnable true;
        lbClear _objectLb;

        _nearestObjects = nearestObjects [_pos, [], 100];
        {
            if ( count (getArray (configFile >> "CfgVehicles" >> typeOf _x >> "slingLoadCargoMemoryPoints")) > 0 ) then
            {
                private ["_idx"];
                diag_log _x;
                _idx = _objectLb lbAdd (getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName"));
                // _objectLb lbSetPicture [_idx, (getText (configFile >> "CfgVehicles" >> typeOf _x >> "picture"))];
                _objectLb lbSetData [_idx, str(getpos _x)];
            };
        } forEach _nearestObjects;

        _objectLb lbSetCurSel 0;

        _objectLb ctrlSetEventHandler ["LBSelChanged",
        "
            private [""_lb"", ""_pos"", ""_sliderText""];
            _lb = _this select 0;
            _pos = call compile (_lb lbData (_this select 1));
            _marker = NEO_radioLogic getVariable ""NEO_supportMarker"";
            _marker setMarkerPosLocal _pos;
            uinamespace setVariable [""NEO_transportMarkerCreated"", _marker];
        "];
    };
    CASE DEFAULT
    {
        _objectLb ctrlSetPosition [safeZoneX + (safeZoneW / 2.275), safeZoneY + (safeZoneH / 1.45), (safeZoneW / 1000), (safeZoneH / 1000)];
        _objectLb ctrlCommit 0;
        _slider ctrlSetPosition [safeZoneX + (safeZoneW / 2.275), safeZoneY + (safeZoneH / 1.45), (safeZoneW / 1000), (safeZoneH / 1000)];
        _slider ctrlCommit 0;
        _sliderText ctrlSetText "";
        _sliderText ctrlSetPosition [safeZoneX + (safeZoneW / 2.255), safeZoneY + (safeZoneH / 1.48), (safeZoneW / 1000), (safeZoneH / 1000)];
        _sliderText ctrlCommit 0;
    };
};
