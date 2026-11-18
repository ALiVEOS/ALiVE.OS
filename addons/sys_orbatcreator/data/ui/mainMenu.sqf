/* ----------------------------------------------------------------------------
Script: data\ui\mainMenu.sqf

Description:
The ALiVE item on the main menu's top bar and its dropdown (CfgMainMenu.hpp). The
title's onLoad compiles this file into uiNamespace, because the main menu runs
before any mission.

The game's own menu script only opens the five menus it knows by IDC, so this one
opens and closes itself the same way: it unfolds under the title in the game's time,
and folds away when the pointer leaves the title and the list. Entering the title
already closes the game's menus, as any other control on the display does.

    - "load": places the title, on the bar after OPTIONS when there is room for it,
      otherwise above the game's info rows, left of the news panel and the logos over it;
    - "open": unfolds the list, downward from the bar or upward near the screen's foot;
    - "mouse": the display's mouse events, folds the list once the pointer is outside.

Parameters:
    _op   - STRING - the event
    _args - ARRAY - the event arguments

Returns:
    Nothing

Author:
    Jman
---------------------------------------------------------------------------- */

#define FS_MENU_IDC_GROUP 14098
#define FS_MENU_ROWS 5
// the game's own MENU_TIME (rscdisplaymain.sqf)
#define FS_MENU_TIME 0.2

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _uW = pixelW * pixelGrid * 2;
private _uH = pixelH * pixelGrid * 2;

switch (_op) do {
    case "load": {
        _args params ["_title"];
        // the bar's width in grid units shrinks as the UI size grows; the profile icon starts 4 units from the right
        private _left = 0.5 + 25 * _uW;
        private _room = (safezoneX + safezoneW - 4 * _uW) - _left;
        if (_room >= 5 * _uW) then {
            _title ctrlSetPosition [_left, safezoneY + 2 * _uH, (10 * _uW) min _room, 2 * _uH];
        } else {
            // The right-hand column (the game's news panel, ACE's in its place, the logos above them) is 10 units wide and
            // rises on a development branch, so the title stays left of it. The left-hand rows top out 7 units and
            // 16 pixels up, and it sits one row above those.
            _title ctrlSetPosition [safezoneX + safezoneW - 18 * _uW - 8 * pixelH, safezoneY + safezoneH - 9 * _uH - 20 * pixelH, 8 * _uW, 2 * _uH];
        };
        _title ctrlCommit 0;
    };

    case "open": {
        _args params ["_title"];
        private _display = ctrlParent _title;
        private _group = _display displayCtrl FS_MENU_IDC_GROUP;
        if (isNull _group || {_group getVariable ["alive_fs_open", false]}) exitWith {};

        (ctrlPosition _title) params ["_tx", "_ty", "_tw", "_th"];
        private _w = 10 * _uW;
        private _h = FS_MENU_ROWS * 1.5 * _uH;
        // kept on screen as the game keeps its own menus
        private _gx = _tx min (safezoneX + safezoneW - _w - _th * 3 / 4);
        // away from the bar the title is above the info rows, which the list must not cover
        private _up = _ty > (safezoneY + safezoneH / 2);
        private _gy = if (_up) then { _ty - _h } else { _ty + _th };
        private _shut = [_gx, if (_up) then { _ty } else { _ty + _th }, _w, 0];

        // part way through folding it turns straight back
        if (ctrlCommitted _group) then {
            _group ctrlSetPosition _shut;
            _group ctrlCommit 0;
        };
        _group ctrlSetPosition [_gx, _gy, _w, _h];
        _group ctrlCommit FS_MENU_TIME;

        _group setVariable ["alive_fs_open", true];
        _group setVariable ["alive_fs_shut", _shut];
        _group setVariable ["alive_fs_title", _title];
        _group setVariable ["alive_fs_areas", [[_tx, _ty, _tx + _tw, _ty + _th], [_gx, _gy, _gx + _w, _gy + _h]]];

        if !(_display getVariable ["alive_fs_mouse", false]) then {
            _display setVariable ["alive_fs_mouse", true];
            _display displayAddEventHandler ["MouseMoving", { ["mouse", [_this select 0, true]] call (uiNamespace getVariable "ALiVE_FS_mainMenu") }];
            _display displayAddEventHandler ["MouseHolding", { ["mouse", [_this select 0, false]] call (uiNamespace getVariable "ALiVE_FS_mainMenu") }];
        };
    };

    case "mouse": {
        _args params ["_display", "_moved"];
        private _group = _display displayCtrl FS_MENU_IDC_GROUP;
        if (isNull _group || {!(_group getVariable ["alive_fs_open", false])}) exitWith {};

        getMousePosition params ["_mx", "_my"];
        private _over = ((_group getVariable ["alive_fs_areas", []]) findIf {
            _x params ["_l", "_t", "_r", "_b"];
            _mx >= _l && {_mx <= _r} && {_my >= _t} && {_my <= _b}
        }) >= 0;
        if (_over) exitWith {};

        // opened from the keyboard: a still pointer leaves it open while the focus stays on the menu
        private _focus = focusedCtrl _display;
        private _held = !_moved && {(_focus isEqualTo (_group getVariable ["alive_fs_title", controlNull])) || {(ctrlParentControlsGroup _focus) isEqualTo _group}};
        if (_held) exitWith {};

        _group setVariable ["alive_fs_open", false];
        _group ctrlSetPosition (_group getVariable "alive_fs_shut");
        _group ctrlCommit FS_MENU_TIME;
    };
};
