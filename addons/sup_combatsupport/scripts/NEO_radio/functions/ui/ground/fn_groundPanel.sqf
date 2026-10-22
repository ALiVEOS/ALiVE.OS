/*
    NEO_fnc_groundPanel
    #690: the tablet panel for Combat Support ground transport. It uses the air transport
    panel's controls (unit and task lists, Confirm, Return to base, speed and rules of
    engagement), with its own lists and orders; the transport's two smoke buttons become
    "Set point A" and "Set point B" for a road patrol.

    Operations:
      "unit"    [lb, index]   a vehicle picked: status, tasks, combos
      "task"    [lb, index]   a task picked: help text, point buttons for a patrol
      "point"   "A" | "B"     which patrol point the next map click sets
      "target"  [pos]         a map click or grid entry (from NEO_fnc_supportSetTargetPos)
      "enable"                Confirm on or off
      "confirm"               send the order
      "base"                  send it home
      "combo"   [cb, index]   speed or rules of engagement changed
    Author: Jman
*/
params [["_op", ""], ["_args", []]];
([] call ALiVE_fnc_tabletBox) params ["_uiX", "_uiY", "_uiW", "_uiH"];
private _d = findDisplay 655555;
if (isNull _d) exitWith {};
private _unitLb = _d displayCtrl 655568;
private _taskLb = _d displayCtrl 655569;
private _confirm = _d displayCtrl 655574;
private _baseBtn = _d displayCtrl 655575;
private _ptA = _d displayCtrl 655576;
private _ptB = _d displayCtrl 655577;
private _helpUnit = _d displayCtrl 655572;
private _taskText = _d displayCtrl 655571;
private _helpTask = _d displayCtrl 655573;
private _heightCb = _d displayCtrl 655630;
private _speedCb = _d displayCtrl 655631;
private _roeCb = _d displayCtrl 655632;
private _escortCb = _d displayCtrl 655638;
private _comboText = _d displayCtrl 655633;
private _list = NEO_radioLogic getVariable [format ["NEO_radioGroundArray_%1", playerSide], []];
private _entry = _list param [lbCurSel _unitLb, []];
private _veh = _entry param [0, objNull];
private _status = _veh getVariable ["NEO_radioGroundUnitStatus", "KILLED"];
private _t = { params ["_colour", "_key", ["_size", "0.7"]]; parseText format ["<t color='%1' size='%3' font='PuristaMedium'>%2</t>", _colour, localize _key, _size] };
private _hide = { { _x ctrlEnable false; _x ctrlSetPosition [1, 1, _uiW / 1000, _uiH / 1000]; _x ctrlCommit 0 } forEach _this };
private _markerB = NEO_radioLogic getVariable ["NEO_supportGroundMarkerB", ""];

switch (_op) do {
    case "unit": {
        if (isNull _veh) exitWith {};
        uiNamespace setVariable ["NEO_radioCbVehicle", _veh];
        _helpUnit ctrlSetStructuredText (switch (_status) do {
            case "NONE": { ["#627057", "STR_ALIVE_CS_UI_UNIT_AVAILABLE"] call _t };
            case "KILLED": { ["#603234", "STR_ALIVE_CS_UI_UNIT_INEFFECTIVE"] call _t };
            case "RTB": { ["#FFFF73", "STR_ALIVE_CS_UI_UNIT_RTB"] call _t };
            case "CARGO": { ["#FFFF73", "STR_ALIVE_CS_UI_GR_WAIT_CARGO"] call _t };
            case "PATROL": { ["#FFFF73", "STR_ALIVE_CS_UI_GR_ON_PATROL"] call _t };
            case "IMMOBILE": { ["#603234", "STR_ALIVE_CS_UI_GR_IMMOBILE"] call _t };
            default { ["#FFFF73", "STR_ALIVE_CS_UI_UNIT_ON_MISSION"] call _t };
        });
        _baseBtn ctrlEnable !(_status in ["RTB", "NONE", "KILLED", "IMMOBILE"]);
        [_ptA, _ptB, _heightCb, _escortCb] call _hide;
        lbClear _taskLb;
        { lbClear _x } forEach [_speedCb, _roeCb, _escortCb];
        _taskText ctrlSetText ""; _helpTask ctrlSetText ""; _comboText ctrlSetText "";
        if (_status == "KILLED") exitWith { ["enable"] call NEO_fnc_groundPanel };
        _taskText ctrlSetStructuredText (["#B4B4B4", "STR_ALIVE_CS_UI_TASK", "0.8"] call _t);
        _helpTask ctrlSetStructuredText (["#FFFF73", "STR_ALIVE_CS_UI_SELECT_TASK"] call _t);
        _taskLb ctrlEnable true;
        (_d displayCtrl 655625) ctrlEnable true;
        {
            private _row = _taskLb lbAdd localize ("STR_ALIVE_CS_UI_GRTASK_" + _x);
            _taskLb lbSetData [_row, _x];
        } forEach (_veh getVariable ["NEO_groundAvailableTasks", ["PICKUP", "MOVE", "PATROL"]]);
        _taskLb ctrlSetEventHandler ["LBSelChanged", "['task', _this] call NEO_fnc_groundPanel"];
        uiNamespace setVariable ["NEO_transportMarkerCreated", nil];
        uiNamespace setVariable ["NEO_groundPointSel", "A"];
        uiNamespace setVariable ["NEO_groundPointB", nil];
        uiNamespace setVariable ["NEO_groundPointA", nil];
        (NEO_radioLogic getVariable "NEO_supportMarker") setMarkerAlphaLocal 0;
        if (_markerB != "") then { _markerB setMarkerAlphaLocal 0 };
        (_d displayCtrl 655560) ctrlSetEventHandler ["MouseButtonDown", "_this call NEO_fnc_radioMapEvent"];
        uiNamespace setVariable ["NEO_radioMapClickArmed", true];
        // speed and rules of engagement, in the same places as the air transport's
        (_veh getVariable ["NEO_radioGroundUnitProperties", [1, 1, 1]]) params ["", "_speed", "_roe"];
        _speedCb ctrlEnable true; _speedCb ctrlSetPosition [0.278525 * _uiW + _uiX, 0.64 * _uiH + _uiY, 0.0927966 * _uiW, 0.028 * _uiH]; _speedCb ctrlCommit 0;
        _roeCb ctrlEnable (_veh getVariable ["NEO_radioGunnerDefendArmed", false]); _roeCb ctrlSetPosition [0.401017 * _uiW + _uiX, 0.64 * _uiH + _uiY, 0.0927966 * _uiW, 0.028 * _uiH]; _roeCb ctrlCommit 0;
        _comboText ctrlSetText localize "STR_ALIVE_CS_UI_BEHAVIOUR"; _comboText ctrlSetPosition [0.278525 * _uiW + _uiX, 0.598 * _uiH + _uiY, 0.215 * _uiW, 0.028 * _uiH]; _comboText ctrlCommit 0;
        { _speedCb lbAdd localize _x } forEach ["STR_ALIVE_CS_UI_SPEED_SLOW", "STR_ALIVE_CS_UI_SPEED_NORMAL", "STR_ALIVE_CS_UI_SPEED_FAST"];
        // own handler first: setting the selection fires it, and on the same values it does nothing
        { _x ctrlSetEventHandler ["LBSelChanged", "['combo', _this] call NEO_fnc_groundPanel"] } forEach [_speedCb, _roeCb];
        _speedCb lbSetCurSel _speed;
        { _roeCb lbAdd localize _x } forEach ["STR_ALIVE_CS_UI_TR_ROE_HOLD", "STR_ALIVE_CS_UI_TR_ROE_FREE"];
        _roeCb lbSetCurSel _roe;
        // an escort for it, from the side's armed ground transports standing by (Eric on Discord, 22 Oct)
        _escortCb ctrlSetPosition [0.278525 * _uiW + _uiX, 0.696 * _uiH + _uiY, 0.215 * _uiW, 0.028 * _uiH]; _escortCb ctrlCommit 0;
        [_escortCb, "GROUND", _veh] call NEO_fnc_transportEscortList;
        ["enable"] call NEO_fnc_groundPanel;
    };

    case "task": {
        private _task = _taskLb lbData (lbCurSel _taskLb);
        _helpTask ctrlSetStructuredText (["#FFFF73", "STR_ALIVE_CS_UI_GR_DESC_" + _task] call _t);
        if (_task == "PATROL") then {
            _ptA ctrlSetText localize "STR_ALIVE_CS_UI_GR_POINT_A";
            _ptB ctrlSetText localize "STR_ALIVE_CS_UI_GR_POINT_B";
            _ptA ctrlEnable true; _ptA ctrlSetPosition [0.519796 * _uiW + _uiX, 0.6176 * _uiH + _uiY, 0.106 * _uiW, 0.028 * _uiH]; _ptA ctrlCommit 0;
            _ptB ctrlEnable true; _ptB ctrlSetPosition [0.630321 * _uiW + _uiX, 0.6176 * _uiH + _uiY, 0.106 * _uiW, 0.028 * _uiH]; _ptB ctrlCommit 0;
            _ptA ctrlSetEventHandler ["ButtonClick", "['point', 'A'] call NEO_fnc_groundPanel"];
            _ptB ctrlSetEventHandler ["ButtonClick", "['point', 'B'] call NEO_fnc_groundPanel"];
        } else {
            [_ptA, _ptB] call _hide;
            uiNamespace setVariable ["NEO_groundPointSel", "A"];
            uiNamespace setVariable ["NEO_groundPointB", nil];
            if (_markerB != "") then { _markerB setMarkerAlphaLocal 0 };
        };
        ["enable"] call NEO_fnc_groundPanel;
    };

    case "point": {
        uiNamespace setVariable ["NEO_groundPointSel", _args];
        _helpTask ctrlSetStructuredText (["#FFFF73", "STR_ALIVE_CS_UI_GR_CLICK_" + _args] call _t);
    };

    case "target": {
        _args params ["_pos"];
        if ((uiNamespace getVariable ["NEO_groundPointSel", "A"]) == "B" && {(_taskLb lbData (lbCurSel _taskLb)) == "PATROL"}) then {
            if (_markerB == "") then {
                _markerB = createMarkerLocal ["NEO_supportGroundMarkerB", _pos];
                _markerB setMarkerTypeLocal "hd_Pickup_noShadow";
                NEO_radioLogic setVariable ["NEO_supportGroundMarkerB", _markerB];
            };
            _markerB setMarkerPosLocal _pos;
            _markerB setMarkerTextLocal localize "STR_ALIVE_CS_UI_GR_MARKER_B";
            _markerB setMarkerAlphaLocal 1;
            uiNamespace setVariable ["NEO_groundPointB", _pos];
            uiNamespace setVariable ["NEO_groundPointSel", "A"];
            // the shared target code has already moved marker A here too: put it back
            private _a = uiNamespace getVariable ["NEO_groundPointA", []];
            private _m = NEO_radioLogic getVariable "NEO_supportMarker";
            if (_a isEqualTo []) then { _m setMarkerAlphaLocal 0 } else { _m setMarkerPosLocal _a; _m setMarkerAlphaLocal 1 };
        } else {
            private _m = NEO_radioLogic getVariable "NEO_supportMarker";
            _m setMarkerPosLocal _pos;
            _m setMarkerAlphaLocal 1;
            _m setMarkerTextLocal localize (["STR_ALIVE_CS_UI_MARKER_GROUND", "STR_ALIVE_CS_UI_GR_MARKER_A"] select ((_taskLb lbData (lbCurSel _taskLb)) == "PATROL"));
            _m setMarkerTypeLocal "hd_Pickup_noShadow";
            uiNamespace setVariable ["NEO_transportMarkerCreated", _m];
            uiNamespace setVariable ["NEO_groundPointA", _pos];
        };
        ["enable"] call NEO_fnc_groundPanel;
    };

    case "enable": {
        private _task = _taskLb lbData (lbCurSel _taskLb);
        _confirm ctrlEnable (
            !isNull _veh && {!(_status in ["KILLED", "IMMOBILE"])}
            && {!(_veh getVariable ["ALIVE_resupply_inProgress", false])}
            && {_task != ""}
            && {!isNil { uiNamespace getVariable "NEO_transportMarkerCreated" }}
            && {_task != "PATROL" || {!isNil { uiNamespace getVariable "NEO_groundPointB" }}}
        );
    };

    case "confirm": {
        if !(call ALIVE_fnc_combatSupportIsOperator) exitWith { [localize "STR_ALIVE_COMBATSUPPORT", localize "STR_ALIVE_CS_NOTOPERATOR"] call ALIVE_fnc_sendHint };
        if (isNull _veh) exitWith {};
        private _task = _taskLb lbData (lbCurSel _taskLb);
        private _pos = +(uiNamespace getVariable ["NEO_groundPointA", getMarkerPos (NEO_radioLogic getVariable "NEO_supportMarker")]);
        _pos set [2, 0];
        private _posB = uiNamespace getVariable ["NEO_groundPointB", []];
        private _me = (format ["%1", group player]) call NEO_fnc_callsignFix;
        private _args = ["STR_ALIVE_CS_MSG_GR_ORDER_" + _task, _entry select 2, _me, mapGridPosition _pos];
        if (_task == "PATROL") then { _args pushBack (mapGridPosition _posB) };
        [[player, _args, "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
        private _order = [_task, _pos, 0, player, _posB];
        _veh setVariable ["NEO_radioGroundNewTask", _order, true];
        // its escort, from the Escort box (a new order with none lets the old one go)
        private _escortId = if (lbCurSel _escortCb > -1) then { _escortCb lbData (lbCurSel _escortCb) } else { "" };
        [[_veh, _escortId, "GROUND", player], "NEO_fnc_transportEscort", false, false] spawn BIS_fnc_MP;
        // the destination, or both ends of the patrol, stay on this player's map while the order runs
        [_veh, _order, "NEO_radioGroundUnitStatus", if (_task == "PATROL") then {
            [[_pos, format ["%1 %2", _entry select 2, localize "STR_ALIVE_CS_UI_GR_MARKER_A"]], [_posB, format ["%1 %2", _entry select 2, localize "STR_ALIVE_CS_UI_GR_MARKER_B"]]]
        } else { [[_pos, _entry select 2]] }] call NEO_fnc_supportOrderMarkers;
        [lbCurSel 655565] call NEO_fnc_radioRefreshUi;
    };

    case "base": {
        if !(call ALIVE_fnc_combatSupportIsOperator) exitWith { [localize "STR_ALIVE_COMBATSUPPORT", localize "STR_ALIVE_CS_NOTOPERATOR"] call ALIVE_fnc_sendHint };
        if (isNull _veh) exitWith {};
        private _me = (format ["%1", group player]) call NEO_fnc_callsignFix;
        _veh setVariable ["NEO_radioGroundNewTask", ["RTB", _veh getVariable ["ALIVE_CombatSupport_Base", []], 0, player], true];
        [player, ["STR_ALIVE_CS_MSG_51", _entry select 2, _me], "side"] call NEO_fnc_messageBroadcast;
        [lbCurSel 655565] call NEO_fnc_radioRefreshUi;
    };

    case "combo": {
        _args params ["_cb", "_index"];
        // only while the ground panel is the one showing
        if ((lbData [655565, lbCurSel 655565]) != "GROUND") exitWith {};
        if (isNull _veh || {_status == "KILLED"}) exitWith {};
        (_veh getVariable ["NEO_radioGroundUnitProperties", [1, 1, 1]]) params ["_h", "_speed", "_roe"];
        private _callsign = _entry select 2;
        if (_cb == _speedCb && {_speed != _index}) then {
            _veh setVariable ["NEO_radioGroundUnitProperties", [_h, _index, _roe], true];
            private _s = ["LIMITED", "NORMAL", "FULL"] select _index;
            [[_veh, _s], "fnc_setSpeed", false, false] spawn BIS_fnc_MP;
            if (_status != "NONE") then { [player, ["STR_ALIVE_CS_MSG_GR_SPEED", _callsign, "$STR_ALIVE_CS_WORD_SPEED_" + _s], "side"] call NEO_fnc_messageBroadcast };
        };
        if (_cb == _roeCb && {_roe != _index}) then {
            _veh setVariable ["NEO_radioGroundUnitProperties", [_h, _speed, _index], true];
            [[_veh, _index > 0], "fnc_setROE", false, false] spawn BIS_fnc_MP;
            if (_status != "NONE") then { [player, [["STR_ALIVE_CS_MSG_55", "STR_ALIVE_CS_MSG_54"] select (_index > 0), _callsign], "side"] call NEO_fnc_messageBroadcast };
        };
    };
};
