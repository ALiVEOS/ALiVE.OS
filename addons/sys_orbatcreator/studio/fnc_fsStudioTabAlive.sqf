#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioTabAlive);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioTabAlive

Description:
The studio ALiVE tab: what the export declares to ALiVE, in four sections picked
from the Section combo (the controls of the other three are hidden).
    1. What ALiVE will see: the "Declare this faction to ALiVE" and "Weight
       groups by rarity" ticks, the preview (ALiVE_fnc_fsAlivePreview), Copy
       block and Check against the loaded mod (ALiVE_fnc_fsAliveLive);
    2. Supplies and crates: the crates with their row counts; Edit contents opens
       the cargo popup on the picked crate; Back to automatic;
    3. Logistics picks: transport, air transport, supports, AA and containers;
       Add from the faction's vehicles or a typed class, Remove, Back to automatic;
    4. Category redirects: an empty ALiVE category drawn from another of the
       faction's categories that has groups.
A list the studio works out is shown greyed and marked automatic. Changing an
automatic list (or crate) first keeps what was worked out, then takes it out of
alive.auto, so ALiVE_fnc_fsGenPlan writes it as it now stands.

Events: "refresh", "section", "hook", "rarity", "copy", "live", "crateEdit",
"crateAuto", "listPick", "listAdd", "listRemove", "listAuto", "redirFrom",
"redirTo".

Parameters:
    _op   - STRING - the event
    _args - ARRAY - the event arguments

Returns:
    Nothing

Examples:
    (begin example)
    ["refresh", []] call ALiVE_fnc_fsStudioTabAlive;
    (end)

See Also:
    ALiVE_fnc_fsAlivePreview, ALiVE_fnc_fsAliveCrates, ALiVE_fnc_fsAlivePicks, ALiVE_fnc_fsStudioCargo

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _display = _session getOrDefault ["display", displayNull];
private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
if !("alive" in _faction) then { _faction set ["alive", createHashMap] };
private _alive = _faction get "alive";
private _ctrl = { _display displayCtrl _this };
private _safe = { ((_this regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"] };
private _civ = (_faction getOrDefault ["side", 1]) == 3;
private _vehicles = _faction getOrDefault ["vehicles", createHashMap];

// the four sections' controls; the Section combo and its label are always on show
private _panels = [
    [FS_IDC_A_HOOK, FS_IDC_A_HOOKLABEL, FS_IDC_A_RARITY, FS_IDC_A_RARITYLABEL, FS_IDC_A_COPY, FS_IDC_A_LIVE, FS_IDC_A_PREVIEW],
    [FS_IDC_A_CRATELIST, FS_IDC_A_CRATEEDIT, FS_IDC_A_CRATEAUTO, FS_IDC_A_CRATENOTE],
    [FS_IDC_A_LISTPICKLABEL, FS_IDC_A_LISTPICK, FS_IDC_A_LIST, FS_IDC_A_LISTNOTE, FS_IDC_A_LISTSOURCELABEL, FS_IDC_A_LISTSOURCE, FS_IDC_A_LISTADD, FS_IDC_A_LISTREMOVE, FS_IDC_A_LISTAUTO],
    [FS_IDC_A_REDIRFROM, FS_IDC_A_REDIRTOLABEL, FS_IDC_A_REDIRTO, FS_IDC_A_REDIRNOTE]
];
// the lists on the picks section, with their stringtable names
private _pickLists = [
    ["transport", "STR_ALIVE_FS_A_LIST_TRANSPORT"],
    ["airTransport", "STR_ALIVE_FS_A_LIST_AIR"],
    ["supports", "STR_ALIVE_FS_A_LIST_SUPPORTS"],
    ["aa", "STR_ALIVE_FS_A_LIST_AA"],
    ["containers", "STR_ALIVE_FS_A_LIST_CONTAINERS"]
];
private _section = _session getOrDefault ["aliveSection", 0];
private _listAt = _session getOrDefault ["aliveList", 0];
private _listName = (_pickLists select ((_listAt max 0) min 4)) select 0;

private _auto = { (_this in (_alive getOrDefault ["auto", FS_ALIVE_LISTS])) };
private _changed = {
    params ["_why", ["_status", "S_ALIVE_SET"], ["_statusArgs", []]];
    ["alive " + _why, false] call ALiVE_fnc_fsDataTouch;
    [0, _status, _statusArgs] call ALiVE_fnc_fsStudioStatus;
    ["refresh", []] call ALiVE_fnc_fsStudioTabAlive;
};
// keeps what the studio works out for a list (or the crates) and takes it out of auto, so it can be changed
private _own = {
    params ["_name"];
    if !(_name call _auto) exitWith {};
    if (_name isEqualTo "crates") then {
        _alive set ["crates", (([_faction] call ALiVE_fnc_fsAliveCrates) select 0) apply { +_x }];
    } else {
        _alive set [_name, +(([_faction] call ALiVE_fnc_fsAlivePicks) getOrDefault [_name, []])];
    };
    _alive set ["auto", (_alive getOrDefault ["auto", FS_ALIVE_LISTS]) - [_name]];
};
// a list's entries as shown: what is set, or what is worked out
private _entriesOf = {
    params ["_name"];
    if (_name isEqualTo "containers") exitWith { _alive getOrDefault ["containers", []] };
    if (_name call _auto) exitWith { ([_faction] call ALiVE_fnc_fsAlivePicks) getOrDefault [_name, []] };
    _alive getOrDefault [_name, []]
};
// a ref as a row: a faction vehicle by its name, an outside class by its display name
private _refText = {
    params ["_ref"];
    if ((_ref select [0, 1]) isEqualTo "#") exitWith {
        private _c = _ref select [1];
        private _n = getText (configFile >> "CfgVehicles" >> _c >> "displayName");
        [format ["%1  (%2)", _n, _c], _c] select (_n isEqualTo "")
    };
    if (_ref in _vehicles) exitWith { (_vehicles get _ref) getOrDefault ["name", _ref] };
    private _n = getText (configFile >> "CfgVehicles" >> _ref >> "displayName");
    [format ["%1  (%2)", _n, _ref], _ref] select (_n isEqualTo "")
};

switch (_op) do {
    case "refresh": {
        if (isNull _display) exitWith {};
        _session set ["aliveFilling", true];
        private _sec = FS_IDC_A_SECTION call _ctrl;
        if (lbSize _sec == 0) then {
            { _sec lbAdd localize _x } forEach ["STR_ALIVE_FS_A_SEC_PREVIEW", "STR_ALIVE_FS_A_SEC_CRATES", "STR_ALIVE_FS_A_SEC_PICKS", "STR_ALIVE_FS_A_SEC_REDIRECTS"];
        };
        _sec lbSetCurSel _section;
        { private _on = _forEachIndex == _section; { (_x call _ctrl) ctrlShow _on } forEach _x } forEach _panels;
        private _hook = _alive getOrDefault ["hook", true];

        switch (_section) do {
            case 0: {
                (FS_IDC_A_HOOK call _ctrl) cbSetChecked _hook;
                (FS_IDC_A_RARITY call _ctrl) cbSetChecked (_alive getOrDefault ["rarity", true]);
                (FS_IDC_A_RARITY call _ctrl) ctrlEnable _hook;
                (FS_IDC_A_COPY call _ctrl) ctrlEnable _hook;
                // the faction's own export loaded in this game, and ALiVE's faction data read
                private _cls = _faction getOrDefault ["class", ""];
                private _loaded = !isNil "ALIVE_factionDefaultSupplies" && {!(_cls isEqualTo "")} && {(getText ((_cls call ALiVE_fnc_configGetFactionClass) >> "ALiVE_FS_tag")) isEqualTo (_faction getOrDefault ["tag", ""])};
                (FS_IDC_A_LIVE call _ctrl) ctrlEnable _loaded;
                (FS_IDC_A_LIVE call _ctrl) ctrlSetTooltip localize (["STR_ALIVE_FS_A_LIVE_OFF", "STR_ALIVE_FS_A_LIVE_TIP"] select _loaded);

                private _p = [_faction] call ALiVE_fnc_fsAlivePreview;
                _session set ["alivePreview", _p];
                private _live = _session getOrDefault ["aliveLive", createHashMap];
                if !(_loaded) then { _live = createHashMap };
                private _hasLive = count _live > 0;
                private _lines = [];
                private _head = { _lines pushBack format ["<t color='#93C47D'>%1</t>", (localize _this) call _safe] };
                // a value, and beside it what ALiVE has read when that is checked; amber when they differ
                private _pair = {
                    params ["_label", "_mine", ["_theirs", -1]];
                    private _s = format ["%1: %2", _label call _safe, _mine call _safe];
                    if (_theirs isEqualType "") then {
                        private _col = ["#E5B422", "#B0B0B0"] select (_mine isEqualTo _theirs);
                        _s = _s + format ["   <t color='%1'>%2 %3</t>", _col, (localize "STR_ALIVE_FS_A_LOADED") call _safe, _theirs call _safe];
                    };
                    _lines pushBack _s;
                };
                if !(_p getOrDefault ["hook", false]) then {
                    _lines pushBack format ["<t color='#E5B422'>%1</t>", (localize "STR_ALIVE_FS_A_PREVIEW_OFF") call _safe];
                } else {
                    "STR_ALIVE_FS_A_PV_GROUPS" call _head;
                    private _liveCats = createHashMapFromArray (_live getOrDefault ["cats", []]);
                    {
                        _x params ["_cat", "_state", "_n", ["_to", ""]];
                        private _mine = switch (_state) do {
                            case "ok": { format [localize "STR_ALIVE_FS_A_PV_N", _n] };
                            case "redirect": { format [localize "STR_ALIVE_FS_A_PV_REDIRECT", _to] };
                            case "fillable": { localize "STR_ALIVE_FS_A_PV_FILLABLE" };
                            default { localize "STR_ALIVE_FS_A_PV_NONE" };
                        };
                        private _theirs = -1;
                        if (_hasLive) then { _theirs = format [localize "STR_ALIVE_FS_A_PV_N", _liveCats getOrDefault [_cat, 0]] };
                        if (_hasLive && {_state in ["redirect", "fillable", "none"]} && {(_liveCats getOrDefault [_cat, 0]) == 0}) then { _theirs = _mine };
                        [_cat, _mine, _theirs] call _pair;
                    } forEach (_p getOrDefault ["cats", []]);
                    "STR_ALIVE_FS_A_PV_LISTS" call _head;
                    private _liveLists = createHashMapFromArray (_live getOrDefault ["lists", []]);
                    {
                        _x params ["_name", "_classes", "_isAuto"];
                        private _mine = if (count _classes == 0) then { localize "STR_ALIVE_FS_A_PV_SIDE" } else { _classes joinString ", " };
                        if (_isAuto && {count _classes > 0}) then { _mine = _mine + " " + localize "STR_ALIVE_FS_A_AUTOMATIC" };
                        private _theirs = -1;
                        if (_hasLive) then {
                            private _got = _liveLists getOrDefault [_name, []];
                            _theirs = if (count _got == 0) then { localize "STR_ALIVE_FS_A_PV_SIDE" } else { _got joinString ", " };
                            // the same classes in the same order count as the same, whatever the mark
                            if ((_got apply { toLower _x }) isEqualTo (_classes apply { toLower _x })) then { _theirs = _mine };
                        };
                        [_name, _mine, _theirs] call _pair;
                    } forEach (_p getOrDefault ["lists", []]);
                    "STR_ALIVE_FS_A_PV_MAPPING" call _head;
                    private _n = _p getOrDefault ["redirects", 0];
                    private _mine = if (_n == 0) then { localize "STR_ALIVE_FS_A_PV_MAP_NONE" } else { format [localize "STR_ALIVE_FS_A_PV_MAP_SOME", _n] };
                    private _theirs = -1;
                    if (_hasLive) then {
                        private _kind = _live getOrDefault ["mapping", "none"];
                        _theirs = localize ("STR_ALIVE_FS_A_MAP_" + toUpper _kind);
                        if ((_n == 0 && {_kind in ["none", "declared"]}) || {_n > 0 && {_kind isEqualTo "declared"}}) then { _theirs = _mine };
                    };
                    [localize "STR_ALIVE_FS_A_PV_MAPPING_ROW", _mine, _theirs] call _pair;
                    if ((_p getOrDefault ["groups", 0]) == 0) then {
                        _lines pushBack format ["<t color='#E5B422'>%1</t>", (localize "STR_ALIVE_FS_A_PV_BORROW") call _safe];
                    };
                    "STR_ALIVE_FS_A_PV_BLOCK" call _head;
                    _lines pushBack format ["<t font='EtelkaMonospacePro' size='0.8' color='#D0D0D0'>%1</t>", ((_p getOrDefault ["text", ""]) call _safe) regexReplace ["\r?\n", "<br/>"]];
                };
                private _box = FS_IDC_A_PREVIEW call _ctrl;
                _box ctrlSetStructuredText parseText (_lines joinString "<br/>");
                (ctrlPosition _box) params ["_bx", "_by", "_bw"];
                _box ctrlSetPosition [_bx, _by, _bw, (ctrlTextHeight _box) max ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)];
                _box ctrlCommit 0;
            };
            case 1: {
                private _l = FS_IDC_A_CRATELIST call _ctrl;
                private _was = lbCurSel _l;
                lbClear _l;
                private _crates = ([_faction] call ALiVE_fnc_fsAliveCrates) select 0;
                private _isAuto = "crates" call _auto;
                {
                    private _i = _l lbAdd (_x getOrDefault ["name", _x getOrDefault ["class", ""]]);
                    _l lbSetTooltip [_i, _x getOrDefault ["class", ""]];
                    _l lbSetTextRight [_i, format [localize "STR_ALIVE_FS_A_ROWS", count (_x getOrDefault ["cargo", []])]];
                    if (_isAuto) then { _l lbSetColor [_i, [0.7, 0.7, 0.7, 1]] };
                } forEach _crates;
                if (lbSize _l > 0) then { _l lbSetCurSel ((_was max 0) min ((lbSize _l) - 1)) };
                private _can = _hook && {!_civ};
                (FS_IDC_A_CRATEEDIT call _ctrl) ctrlEnable (_can && {lbSize _l > 0});
                (FS_IDC_A_CRATEAUTO call _ctrl) ctrlEnable (_can && {!_isAuto});
                private _note = switch (true) do {
                    case (!_hook): { "STR_ALIVE_FS_A_PREVIEW_OFF" };
                    case (_civ): { "STR_ALIVE_FS_A_CRATE_CIV" };
                    case (_isAuto): { "STR_ALIVE_FS_A_CRATE_AUTO" };
                    default { "STR_ALIVE_FS_A_CRATE_SET" };
                };
                (FS_IDC_A_CRATENOTE call _ctrl) ctrlSetStructuredText parseText ((localize _note) call _safe);
            };
            case 2: {
                private _pick = FS_IDC_A_LISTPICK call _ctrl;
                if (lbSize _pick == 0) then { { _pick lbAdd localize (_x select 1) } forEach _pickLists };
                _pick lbSetCurSel _listAt;
                private _isAuto = (_listName != "containers") && {_listName call _auto};
                private _l = FS_IDC_A_LIST call _ctrl;
                private _was = lbCurSel _l;
                lbClear _l;
                {
                    private _i = _l lbAdd ([_x] call _refText);
                    _l lbSetData [_i, _x];
                    if (_isAuto) then { _l lbSetColor [_i, [0.7, 0.7, 0.7, 1]] };
                } forEach ([_listName] call _entriesOf);
                if (lbSize _l > 0) then { _l lbSetCurSel ((_was max 0) min ((lbSize _l) - 1)) };
                (FS_IDC_A_LISTNOTE call _ctrl) ctrlSetStructuredText parseText ((localize (switch (true) do {
                    case (!_hook): { "STR_ALIVE_FS_A_PREVIEW_OFF" };
                    case (_listName isEqualTo "containers"): { "STR_ALIVE_FS_A_LIST_CONTAINERS_NOTE" };
                    case (_isAuto): { "STR_ALIVE_FS_A_LIST_AUTO_NOTE" };
                    default { "STR_ALIVE_FS_A_LIST_SET_NOTE" };
                })) call _safe);
                // the faction's vehicles (not for containers), then a typed class
                private _src = FS_IDC_A_LISTSOURCE call _ctrl;
                private _srcWas = lbCurSel _src;
                lbClear _src;
                if !(_listName isEqualTo "containers") then {
                    {
                        if (_x in _vehicles) then {
                            private _i = _src lbAdd ((_vehicles get _x) getOrDefault ["name", _x]);
                            _src lbSetData [_i, _x];
                        };
                    } forEach (_faction getOrDefault ["vehicleOrder", keys _vehicles]);
                };
                private _i = _src lbAdd localize "STR_ALIVE_FS_A_LIST_OTHER";
                _src lbSetData [_i, "#"];
                _src lbSetCurSel ((_srcWas max 0) min ((lbSize _src) - 1));
                (FS_IDC_A_LISTADD call _ctrl) ctrlEnable _hook;
                (FS_IDC_A_LISTREMOVE call _ctrl) ctrlEnable (_hook && {lbSize _l > 0});
                (FS_IDC_A_LISTAUTO call _ctrl) ctrlEnable (_hook && {!_isAuto} && {!(_listName isEqualTo "containers")});
            };
            case 3: {
                private _checks = [_faction] call ALiVE_fnc_fsAliveCheck;
                private _l = FS_IDC_A_REDIRFROM call _ctrl;
                private _at = (_session getOrDefault ["aliveCat", 0]) max 0;
                lbClear _l;
                {
                    _x params ["_cat", "_state", "_n", ["_to", ""]];
                    private _i = _l lbAdd _cat;
                    _l lbSetData [_i, _cat];
                    _l lbSetTextRight [_i, switch (_state) do {
                        case "ok": { format [localize "STR_ALIVE_FS_A_PV_N", _n] };
                        case "redirect": { format [localize "STR_ALIVE_FS_A_PV_REDIRECT", _to] };
                        default { localize "STR_ALIVE_FS_A_PV_NONE" };
                    }];
                    if (_state isEqualTo "ok") then { _l lbSetColor [_i, [0.7, 0.7, 0.7, 1]] };
                } forEach _checks;
                _l lbSetCurSel (_at min ((lbSize _l) - 1));
                private _row = _checks param [lbCurSel _l, ["", "none", 0, ""]];
                _row params ["_cat", "_state", "", ["_to", ""]];
                // None, then the faction's categories that have groups
                private _combo = FS_IDC_A_REDIRTO call _ctrl;
                lbClear _combo;
                private _i = _combo lbAdd localize "STR_ALIVE_FS_A_REDIR_NONE";
                _combo lbSetData [_i, ""];
                private _sel = 0;
                {
                    _x params ["_c", "_s"];
                    if (_s isEqualTo "ok" && {!(_c isEqualTo _cat)}) then {
                        private _j = _combo lbAdd _c;
                        _combo lbSetData [_j, _c];
                        if (_c isEqualTo _to) then { _sel = _j };
                    };
                } forEach _checks;
                _combo lbSetCurSel _sel;
                private _can = _hook && {!_civ} && {!(_state isEqualTo "ok")};
                _combo ctrlEnable _can;
                (FS_IDC_A_REDIRNOTE call _ctrl) ctrlSetStructuredText parseText ((localize (switch (true) do {
                    case (!_hook): { "STR_ALIVE_FS_A_PREVIEW_OFF" };
                    case (_state isEqualTo "ok"): { "STR_ALIVE_FS_A_REDIR_HAS" };
                    default { "STR_ALIVE_FS_A_REDIR_NOTE" };
                })) call _safe);
            };
        };
        _session set ["aliveFilling", false];
    };

    case "section": {
        _args params ["", ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["aliveFilling", false]}) exitWith {};
        _session set ["aliveSection", _index];
        ["refresh", []] call ALiVE_fnc_fsStudioTabAlive;
    };

    case "hook": {
        _args params ["", ["_state", 0]];
        if (_session getOrDefault ["aliveFilling", false]) exitWith {};
        _alive set ["hook", _state isEqualTo 1 || {_state isEqualTo true}];
        ["hook", ["S_ALIVE_OFF", "S_ALIVE_ON"] select (_alive get "hook")] call _changed;
    };
    case "rarity": {
        _args params ["", ["_state", 0]];
        if (_session getOrDefault ["aliveFilling", false]) exitWith {};
        _alive set ["rarity", _state isEqualTo 1 || {_state isEqualTo true}];
        ["rarity"] call _changed;
    };

    case "copy": {
        private _text = (_session getOrDefault ["alivePreview", createHashMap]) getOrDefault ["text", ""];
        if (_text isEqualTo "") exitWith {};
        copyToClipboard _text;
        [0, "S_ALIVE_COPIED", [count _text]] call ALiVE_fnc_fsStudioStatus;
    };
    case "live": {
        private _live = [_faction] call ALiVE_fnc_fsAliveLive;
        _session set ["aliveLive", _live];
        if (count _live == 0) exitWith { [1, "S_ALIVE_LIVE_NONE"] call ALiVE_fnc_fsStudioStatus };
        [0, "S_ALIVE_LIVE"] call ALiVE_fnc_fsStudioStatus;
        ["refresh", []] call ALiVE_fnc_fsStudioTabAlive;
    };

    case "crateEdit": {
        private _i = lbCurSel (FS_IDC_A_CRATELIST call _ctrl);
        if (_i < 0) exitWith {};
        private _wasAuto = "crates" call _auto;
        ["crates"] call _own;
        if (_i >= count (_alive getOrDefault ["crates", []])) exitWith {};
        if (_wasAuto) then { ["alive crates", false] call ALiVE_fnc_fsDataTouch };
        ["open", ["crate", _i]] call ALiVE_fnc_fsStudioCargo;
    };
    case "crateAuto": {
        _alive set ["crates", []];
        _alive set ["auto", (_alive getOrDefault ["auto", FS_ALIVE_LISTS]) + (["crates"] - (_alive getOrDefault ["auto", FS_ALIVE_LISTS]))];
        ["crates", "S_ALIVE_AUTO"] call _changed;
    };

    case "listPick": {
        _args params ["", ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["aliveFilling", false]}) exitWith {};
        _session set ["aliveList", _index];
        ["refresh", []] call ALiVE_fnc_fsStudioTabAlive;
    };
    case "listAdd": {
        private _src = FS_IDC_A_LISTSOURCE call _ctrl;
        if (lbCurSel _src < 0) exitWith {};
        private _what = _src lbData (lbCurSel _src);
        private _name = _listName;
        // the typed class goes through the same add, as an outside class
        private _add = {
            params ["_ref", "_name"];
            private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
            private _alive = _faction get "alive";
            private _isContainers = _name isEqualTo "containers";
            private _rule = ["ref", "gear"] select _isContainers;
            if !(([_ref, _rule] call ALiVE_fnc_fsDataCheckValue) isEqualTo "") exitWith { [1, "S_ALIVE_BAD", [_ref]] call ALiVE_fnc_fsStudioStatus };
            if (!_isContainers && {_name in (_alive getOrDefault ["auto", FS_ALIVE_LISTS])}) then {
                _alive set [_name, +(([_faction] call ALiVE_fnc_fsAlivePicks) getOrDefault [_name, []])];
                _alive set ["auto", (_alive getOrDefault ["auto", FS_ALIVE_LISTS]) - [_name]];
            };
            private _list = _alive getOrDefault [_name, []];
            if ((_list findIf { (toLower _x) isEqualTo (toLower _ref) }) >= 0) exitWith { [1, "S_ALIVE_HAVE", [_ref]] call ALiVE_fnc_fsStudioStatus };
            if (count _list >= ([32, 16] select _isContainers)) exitWith { [1, "S_ALIVE_FULL", []] call ALiVE_fnc_fsStudioStatus };
            _list pushBack _ref;
            _alive set [_name, _list];
            ["alive " + _name, false] call ALiVE_fnc_fsDataTouch;
            [0, "S_ALIVE_SET", []] call ALiVE_fnc_fsStudioStatus;
            ["refresh", []] call ALiVE_fnc_fsStudioTabAlive;
        };
        if (_what isEqualTo "#") exitWith {
            ["open", [localize "STR_ALIVE_FS_A_LIST_ASK", "", {
                params ["_ok", "_text", "_args"];
                _args params ["_add", "_name"];
                _text = (_text splitString " ") joinString "";
                if (!_ok || {_text isEqualTo ""}) exitWith {};
                if !(isClass (configFile >> "CfgVehicles" >> _text)) exitWith { [1, "S_ALIVE_NOCLASS", [_text]] call ALiVE_fnc_fsStudioStatus };
                [[("#" + configName (configFile >> "CfgVehicles" >> _text)), configName (configFile >> "CfgVehicles" >> _text)] select (_name isEqualTo "containers"), _name] call _add;
            }, [_add, _name]]] call ALiVE_fnc_fsStudioPrompt;
        };
        [_what, _name] call _add;
    };
    case "listRemove": {
        private _l = FS_IDC_A_LIST call _ctrl;
        private _i = lbCurSel _l;
        if (_i < 0) exitWith {};
        if !(_listName isEqualTo "containers") then { [_listName] call _own };
        private _list = _alive getOrDefault [_listName, []];
        if (_i >= count _list) exitWith {};
        _list deleteAt _i;
        _alive set [_listName, _list];
        [_listName] call _changed;
    };
    case "listAuto": {
        if (_listName isEqualTo "containers") exitWith {};
        _alive set [_listName, []];
        _alive set ["auto", (_alive getOrDefault ["auto", FS_ALIVE_LISTS]) + ([_listName] - (_alive getOrDefault ["auto", FS_ALIVE_LISTS]))];
        [_listName, "S_ALIVE_AUTO"] call _changed;
    };

    case "redirFrom": {
        _args params ["", ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["aliveFilling", false]}) exitWith {};
        _session set ["aliveCat", _index];
        ["refresh", []] call ALiVE_fnc_fsStudioTabAlive;
    };
    case "redirTo": {
        _args params ["_combo", ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["aliveFilling", false]}) exitWith {};
        private _l = FS_IDC_A_REDIRFROM call _ctrl;
        if (lbCurSel _l < 0) exitWith {};
        private _from = _l lbData (lbCurSel _l);
        private _to = _combo lbData _index;
        private _list = (_alive getOrDefault ["redirects", []]) select { !((_x getOrDefault ["from", ""]) isEqualTo _from) };
        if !(_to isEqualTo "") then { _list pushBack createHashMapFromArray [["from", _from], ["to", _to]] };
        _alive set ["redirects", _list];
        ["redirects"] call _changed;
    };
    default {};
};
