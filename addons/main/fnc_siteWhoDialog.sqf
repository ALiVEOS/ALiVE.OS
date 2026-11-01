/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_siteWhoDialog

Description:
The Permissions window every player site shares (main\data\ui\siteWho.hpp): one or two sets of Who
Can rules side by side, each a column of tick buttons with its names list. The site that opens it
says what the columns are, and what Apply does with them (sends them to its own server, which
checks the sender again). Runs on the player's machine.

Parameters:
    ["open", [header, note, columns, onApply, onReset]] - closes whatever dialog is open and opens this one.
        header  - STRING, the title bar
        note    - STRING, structured text under it
        columns - ARRAY of one or two [title, namesLabel, namesTooltip, tokens, rules, names], where
                  tokens is [[token, label, tooltip], ...] (at most 5), rules the ticked tokens as
                  stored ("SIDE,LIST") and names the names list
        onApply - CODE, called with [[rules, names], ...] in column order when Apply is pressed
        onReset - CODE (optional), called when Use module settings is pressed; without it the
                  button isn't shown
    ["fill"]             - draws the window from its draft; nothing when it isn't open
    ["toggle", [column, index]] - ticks or unticks one rule
    ["apply"]            - hands the draft and the names lists to onApply
    ["reset"]            - calls onReset
    ["closed"]           - the window closed: the draft goes

Examples:
(begin example)
["open", ["Who can dismantle", "", [["", "Names", "", [["SIDE", "Own side", ""]], "SIDE", ""]], { hint str _this }]] call ALiVE_fnc_siteWhoDialog;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], ["_args", []]];
private _result = true;
#define SITEWHO_IDD 9295

switch (_operation) do {

    case "open": {
        _args params [["_header", "", [""]], ["_note", "", [""]], ["_columns", [], [[]]], ["_onApply", {}, [{}]], ["_onReset", {}, [{}]]];
        if (!hasInterface || {_columns isEqualTo []}) exitWith { _result = false };
        _columns = _columns select [0, 2];
        closeDialog 0;
        [_header, _note, _columns, _onApply, _onReset] spawn {
            params ["_header", "_note", "_columns", "_onApply", "_onReset"];
            uiSleep 0.1;
            if (!createDialog "ALiVE_SiteWhoWindow") exitWith {};
            uiNamespace setVariable ["ALiVE_siteWho_spec", [_header, _note, _columns, _onApply, _onReset]];
            // the ticked rules, a list per column, as stored (an older word stays as it was saved)
            uiNamespace setVariable ["ALiVE_siteWho_draft", _columns apply { (toUpper (_x param [4, ""])) splitString "[]""', " }];
            private _d = findDisplay SITEWHO_IDD;
            private _canReset = !(_onReset isEqualTo {});
            (_d displayCtrl 92971) ctrlShow _canReset;
            {
                (_d displayCtrl (92967 + _forEachIndex)) ctrlSetText (_x param [5, ""]);
            } forEach _columns;
            // one column: laid out as the narrower FOB window was
            if (count _columns == 1) then {
                private _sx = { _this * safezoneW + safezoneX };
                private _move = { params ["_idc", "_x", "_w"]; private _c = _d displayCtrl _idc; private _p = ctrlPosition _c; _c ctrlSetPosition [_x call _sx, _p select 1, _w * safezoneW, _p select 3]; _c ctrlCommit 0 };
                { [_x, 0.4, 0.2] call _move } forEach [92950, 92951];
                { [_x, 0.41, 0.18] call _move } forEach [92952, 92953, 92955, 92956, 92957, 92958, 92959, 92965, 92967];
                [92969, 0.455, 0.065] call _move;
                [92970, 0.525, 0.065] call _move;
                { (_d displayCtrl _x) ctrlShow false } forEach [92954, 92960, 92961, 92962, 92963, 92964, 92966, 92968];
                // too narrow for three buttons in a row: Use module settings gets its own, under the names
                if (_canReset) then {
                    [92971, 0.41, 0.18] call _move;
                    private _down = { params ["_idc", "_dy"]; private _c = _d displayCtrl _idc; private _p = ctrlPosition _c; _p set [1, (_p select 1) + _dy * safezoneH]; _c ctrlSetPosition _p; _c ctrlCommit 0 };
                    { [_x, 0.04] call _down } forEach [92969, 92970];
                    private _bg = _d displayCtrl 92950;
                    private _p = ctrlPosition _bg;
                    _p set [3, (_p select 3) + 0.04 * safezoneH];
                    _bg ctrlSetPosition _p;
                    _bg ctrlCommit 0;
                };
            };
            ["fill"] call ALiVE_fnc_siteWhoDialog;
        };
    };

    case "fill": {
        private _d = findDisplay SITEWHO_IDD;
        private _spec = uiNamespace getVariable ["ALiVE_siteWho_spec", []];
        private _draft = uiNamespace getVariable ["ALiVE_siteWho_draft", []];
        if (isNull _d || {_spec isEqualTo []}) exitWith { _result = false };
        _spec params ["_header", "_note", "_columns"];
        (_d displayCtrl 92951) ctrlSetText _header;
        (_d displayCtrl 92952) ctrlSetStructuredText parseText _note;
        {
            _x params [["_title", ""], ["_namesLabel", ""], ["_namesTip", ""], ["_tokens", []]];
            private _col = _forEachIndex;
            private _ticked = _draft param [_col, []];
            (_d displayCtrl (92953 + _col)) ctrlSetText _title;
            (_d displayCtrl (92965 + _col)) ctrlSetText _namesLabel;
            (_d displayCtrl (92967 + _col)) ctrlSetTooltip _namesTip;
            for "_i" from 0 to 4 do {
                private _b = _d displayCtrl (92955 + 5 * _col + _i);
                private _t = _tokens param [_i, []];
                if (_t isEqualTo []) then { _b ctrlShow false } else {
                    _t params ["_token", "_label", ["_tip", ""]];
                    _b ctrlShow true;
                    _b ctrlSetText format ["%1  %2", ["[  ]", "[+]"] select (_token in _ticked), _label];
                    _b ctrlSetTooltip _tip;
                };
            };
        } forEach _columns;
    };

    case "toggle": {
        _args params [["_col", 0, [0]], ["_index", 0, [0]]];
        private _spec = uiNamespace getVariable ["ALiVE_siteWho_spec", []];
        private _draft = uiNamespace getVariable ["ALiVE_siteWho_draft", []];
        if (_spec isEqualTo [] || {_col >= count _draft}) exitWith { _result = false };
        private _token = ((((_spec select 2) select _col) param [3, []]) param [_index, []]) param [0, ""];
        if (_token == "") exitWith { _result = false };
        private _ticked = _draft select _col;
        if (_token in _ticked) then { _ticked deleteAt (_ticked find _token) } else { _ticked pushBack _token };
        ["fill"] call ALiVE_fnc_siteWhoDialog;
    };

    case "apply": {
        private _d = findDisplay SITEWHO_IDD;
        private _spec = uiNamespace getVariable ["ALiVE_siteWho_spec", []];
        private _draft = uiNamespace getVariable ["ALiVE_siteWho_draft", []];
        if (isNull _d || {_spec isEqualTo []}) exitWith { _result = false };
        private _out = [];
        { _out pushBack [_x joinString ",", ctrlText (_d displayCtrl (92967 + _forEachIndex))] } forEach _draft;
        _out call (_spec select 3);
    };

    case "reset": {
        private _spec = uiNamespace getVariable ["ALiVE_siteWho_spec", []];
        if (_spec isEqualTo []) exitWith { _result = false };
        [] call (_spec param [4, {}]);
    };

    case "closed": {
        uiNamespace setVariable ["ALiVE_siteWho_spec", nil];
        uiNamespace setVariable ["ALiVE_siteWho_draft", nil];
    };
};

_result
