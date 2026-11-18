#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioPools);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioPools

Description:
The gear pools popup (ALiVE_FS_Pools, 14910), opened for the selected unit, and
the Units tab's Roll and Reset.

    - "open" / "fill": the faction's pools (green: the unit wears it), the picked
      pool's slot, items and users;
    - "select" / "entry": a pool, or one of its items (its weight to the box);
    - "new": a pool named from the name box, for the slot in the slot combo;
    - "rename" / "delete";
    - "use": the unit wears the picked pool, or stops; one pool per slot, so it
      takes the place of his other pool for that slot;
    - "slot": the pool's slot (its items are emptied, they were for the old slot);
    - "weight" (1 to 100) / "remove": the picked item;
    - "add": the unit combo's item in the pool's slot (a weapon with its
      attachments and magazine); an item already there gets 1 more weight;
    - "roll": the preview body takes a random pick from each pool the unit wears
      (ALiVE_fnc_fsPoolRoll), as he would in a mission;
    - "unroll": the preview back in his stored loadout;
    - "close".
Every change is saved at once.

Parameters:
    _op   - STRING - as above
    _args - ARRAY - the event arguments

Returns:
    Nothing

Examples:
    (begin example)
    ["open"] call ALiVE_fnc_fsStudioPools;
    (end)

See Also:
    ALiVE_fnc_fsDataPool, ALiVE_fnc_fsPoolRoll, ALiVE_fnc_fsStudioTabUnits

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _popup = findDisplay FS_IDD_POOLS;
private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
private _units = _faction getOrDefault ["units", createHashMap];
private _pools = _faction getOrDefault ["pools", createHashMap];
private _uid = _session getOrDefault ["selUnit", ""];
private _unit = _units getOrDefault [_uid, createHashMap];
private _pid = _session getOrDefault ["selPool", ""];
private _pool = _pools getOrDefault [_pid, createHashMap];
private _slotKeys = ["STR_ALIVE_FS_PL_S0", "STR_ALIVE_FS_PL_S1", "STR_ALIVE_FS_PL_S2", "STR_ALIVE_FS_PL_S3", "STR_ALIVE_FS_PL_S4", "STR_ALIVE_FS_PL_S5", "STR_ALIVE_FS_PL_S6", "STR_ALIVE_FS_PL_S7"];

// an item's name: the weapon, container or headgear display name
private _nameOf = {
    params ["_class"];
    private _n = "";
    { if (_n isEqualTo "") then { _n = getText (configFile >> _x >> _class >> "displayName") } } forEach ["CfgWeapons", "CfgVehicles", "CfgGlasses"];
    if (_n isEqualTo "") then { _class } else { _n }
};
// [slot, items, weights] for each pool the unit wears that has items
private _specOf = {
    params ["_entry"];
    ((_entry getOrDefault ["pools", []]) select { count ((_pools getOrDefault [_x, createHashMap]) getOrDefault ["entries", []]) > 0 }) apply {
        private _p = _pools get _x;
        private _weaponSlot = (_p get "slot") in [0, 1, 2];
        [_p get "slot", (_p get "entries") apply { [_x get "class", _x get "weapon"] select _weaponSlot }, (_p get "entries") apply { _x get "weight" }]
    }
};
private _changed = {
    params ["_why", ["_status", []]];
    if !(_why isEqualTo "") exitWith { [1, _why] call ALiVE_fnc_fsStudioStatus };
    ["gear pools", false] call ALiVE_fnc_fsDataTouch;
    ["fill"] call ALiVE_fnc_fsStudioPools;
    ["refresh", []] call ALiVE_fnc_fsStudioTabUnits;
    if !(_status isEqualTo []) then { _status call ALiVE_fnc_fsStudioStatus };
};
// the picked pool's items as [item, weight, weapon] triples, for the model's "entries"
private _triples = { (_pool getOrDefault ["entries", []]) apply { [_x get "class", _x get "weight", +(_x get "weapon")] } };

switch (_op) do {
    case "open": {
        private _studio = _session getOrDefault ["display", displayNull];
        if (isNull _studio || {!(_uid in _units)}) exitWith {};
        if (!isNull _popup) then { _popup closeDisplay 2 };
        _popup = _studio createDisplay "ALiVE_FS_Pools";
        if (isNull _popup) exitWith {};
        (_popup displayCtrl FS_IDC_PL_TITLE) ctrlSetText format [localize "STR_ALIVE_FS_PL_TITLE", _unit getOrDefault ["name", _uid]];
        private _slot = _popup displayCtrl FS_IDC_PL_SLOT;
        { _slot lbAdd localize _x } forEach _slotKeys;
        private _who = _popup displayCtrl FS_IDC_PL_UNIT;
        {
            if (_x in _units) then {
                private _i = _who lbAdd ((_units get _x) getOrDefault ["name", _x]);
                _who lbSetData [_i, _x];
                if (_x == _uid) then { _who lbSetCurSel _i };
            };
        } forEach (_faction getOrDefault ["unitOrder", []]);
        // start on a pool he wears, else the first
        if !(_pid in _pools) then {
            _session set ["selPool", ((_unit getOrDefault ["pools", []]) select { _x in _pools }) param [0, (_faction getOrDefault ["poolOrder", []]) param [0, ""]]];
        };
        ["fill"] call ALiVE_fnc_fsStudioPools;
    };
    case "fill": {
        if (isNull _popup) exitWith {};
        _session set ["poolFilling", true];
        private _worn = _unit getOrDefault ["pools", []];
        private _l = _popup displayCtrl FS_IDC_PL_LIST;
        lbClear _l;
        private _order = (_faction getOrDefault ["poolOrder", []]) select { _x in _pools };
        {
            private _p = _pools get _x;
            private _i = _l lbAdd (_p getOrDefault ["name", _x]);
            _l lbSetData [_i, _x];
            _l lbSetTextRight [_i, format ["%1  %2", localize (_slotKeys select (_p getOrDefault ["slot", 0])), count (["users", [_x]] call ALiVE_fnc_fsDataPool)]];
            if (_x in _worn) then { _l lbSetColor [_i, [0.45, 0.85, 0.45, 1]] };
            if (_x == _pid) then { _l lbSetCurSel _i };
        } forEach _order;
        private _has = _pid in _pools;
        (_popup displayCtrl FS_IDC_PL_NAME) ctrlSetText (_pool getOrDefault ["name", ""]);
        if (_has) then { (_popup displayCtrl FS_IDC_PL_SLOT) lbSetCurSel (_pool getOrDefault ["slot", 0]) } else {
            if (lbCurSel (_popup displayCtrl FS_IDC_PL_SLOT) < 0) then { (_popup displayCtrl FS_IDC_PL_SLOT) lbSetCurSel 0 };
        };
        // the items, each with its weight and its chance
        private _e = _popup displayCtrl FS_IDC_PL_ENTRIES;
        private _was = lbCurSel _e;
        lbClear _e;
        private _entries = _pool getOrDefault ["entries", []];
        private _total = 0;
        { _total = _total + (_x get "weight") } forEach _entries;
        {
            private _class = _x get "class";
            private _i = _e lbAdd ([_class] call _nameOf);
            private _w = _x get "weapon";
            _e lbSetTooltip [_i, if (_w isEqualTo []) then { _class } else { ((_w select [0, 4]) + ((_w select [4, 2]) apply { _x param [0, ""] }) + [_w param [6, ""]]) select { _x isEqualType "" && {!(_x isEqualTo "")} } joinString ", " }];
            _e lbSetTextRight [_i, format ["%1  %2%3", _x get "weight", round (100 * (_x get "weight") / (_total max 1)), "%"]];
        } forEach _entries;
        if (lbSize _e > 0) then { _e lbSetCurSel ((_was max 0) min ((lbSize _e) - 1)) };
        (_popup displayCtrl FS_IDC_PL_WEIGHT) ctrlSetText str ((_entries param [lbCurSel _e, createHashMap]) getOrDefault ["weight", 1]);
        private _users = ["users", [_pid]] call ALiVE_fnc_fsDataPool;
        (_popup displayCtrl FS_IDC_PL_USERS) ctrlSetText (if (_has) then {
            if (_users isEqualTo []) then { localize "STR_ALIVE_FS_PL_USERS_NONE" } else { format [localize "STR_ALIVE_FS_PL_USERS", count _users, (_users apply { (_units get _x) getOrDefault ["name", _x] }) joinString ", "] }
        } else { localize "STR_ALIVE_FS_PL_EMPTY" });
        private _use = _popup displayCtrl FS_IDC_PL_USE;
        _use ctrlSetText localize (["STR_ALIVE_FS_PL_USE", "STR_ALIVE_FS_PL_UNUSE"] select (_pid in _worn));
        { (_popup displayCtrl _x) ctrlEnable _has } forEach [FS_IDC_PL_RENAME, FS_IDC_PL_DELETE, FS_IDC_PL_USE, FS_IDC_PL_ADDUNIT, FS_IDC_PL_SETWEIGHT, FS_IDC_PL_REMOVE];
        (_popup displayCtrl FS_IDC_PL_ROLL) ctrlEnable !(([_unit] call _specOf) isEqualTo []);
        _session set ["poolFilling", false];
    };
    case "select": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["poolFilling", false]}) exitWith {};
        _session set ["selPool", _ctrl lbData _index];
        ["fill"] call ALiVE_fnc_fsStudioPools;
    };
    case "entry": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["poolFilling", false]}) exitWith {};
        (_popup displayCtrl FS_IDC_PL_WEIGHT) ctrlSetText str (((_pool getOrDefault ["entries", []]) param [_index, createHashMap]) getOrDefault ["weight", 1]);
    };
    case "new": {
        private _name = ctrlText (_popup displayCtrl FS_IDC_PL_NAME);
        // the box still shows the picked pool's name: a new pool needs a name of its own
        if (_name isEqualTo "" || {_name isEqualTo (_pool getOrDefault ["name", ""])}) then { _name = format [localize "STR_ALIVE_FS_PL_DEFAULT", (count _pools) + 1] };
        private _id = ["add", [_name, (lbCurSel (_popup displayCtrl FS_IDC_PL_SLOT)) max 0]] call ALiVE_fnc_fsDataPool;
        if (_id isEqualTo "") exitWith { [1, "S_POOL_FULL"] call ALiVE_fnc_fsStudioStatus };
        _session set ["selPool", _id];
        [""] call _changed;
    };
    case "rename": { [["rename", [_pid, ctrlText (_popup displayCtrl FS_IDC_PL_NAME)]] call ALiVE_fnc_fsDataPool] call _changed };
    case "delete": {
        if !(_pid in _pools) exitWith {};
        private _n = ["delete", [_pid]] call ALiVE_fnc_fsDataPool;
        _session set ["selPool", (_faction getOrDefault ["poolOrder", []]) param [0, ""]];
        ["", [0, "S_POOL_DELETED", [_n]]] call _changed;
    };
    case "use": {
        if !(_pid in _pools) exitWith {};
        [["use", [_uid, _pid, !(_pid in (_unit getOrDefault ["pools", []]))]] call ALiVE_fnc_fsDataPool] call _changed;
    };
    case "slot": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["poolFilling", false]} || {!(_pid in _pools)} || {(_pool get "slot") == _index}) exitWith {};
        private _had = count (_pool get "entries");
        [["slot", [_pid, _index]] call ALiVE_fnc_fsDataPool, [[], [0, "S_POOL_SLOT"]] select (_had > 0)] call _changed;
    };
    case "weight": {
        private _i = lbCurSel (_popup displayCtrl FS_IDC_PL_ENTRIES);
        private _list = call _triples;
        if (_i < 0 || {_i >= count _list}) exitWith {};
        private _n = parseNumber ctrlText (_popup displayCtrl FS_IDC_PL_WEIGHT);
        if (!(finite _n) || {_n < 1} || {_n > 100}) exitWith { [1, "S_POOL_WEIGHT"] call ALiVE_fnc_fsStudioStatus };
        (_list select _i) set [1, round _n];
        [["entries", [_pid, _list]] call ALiVE_fnc_fsDataPool] call _changed;
    };
    case "remove": {
        private _i = lbCurSel (_popup displayCtrl FS_IDC_PL_ENTRIES);
        private _list = call _triples;
        if (_i < 0 || {_i >= count _list}) exitWith {};
        _list deleteAt _i;
        [["entries", [_pid, _list]] call ALiVE_fnc_fsDataPool] call _changed;
    };
    case "add": {
        if !(_pid in _pools) exitWith {};
        private _who = _popup displayCtrl FS_IDC_PL_UNIT;
        private _from = if (lbCurSel _who < 0) then { "" } else { _who lbData (lbCurSel _who) };
        if !(_from in _units) exitWith {};
        private _slot = _pool get "slot";
        private _have = ((_units get _from) getOrDefault ["loadout", []]) param [[0, 2, 1, 3, 4, 5, 6, 7] select _slot, []];
        // the item in that slot: a weapon entry, a container's class, or a class
        private _item = "";
        private _weapon = [];
        switch (true) do {
            case (_slot in [0, 1, 2]): { if (_have isEqualType [] && {count _have == 7}) then { _item = _have select 0; _weapon = +_have } };
            case (_slot in [3, 4, 5]): { if (_have isEqualType [] && {count _have > 0}) then { _item = _have select 0 } };
            default { if (_have isEqualType "") then { _item = _have } };
        };
        if (_item isEqualTo "") exitWith { [1, "S_POOL_NOITEM", [localize (_slotKeys select _slot)]] call ALiVE_fnc_fsStudioStatus };
        private _list = call _triples;
        private _at = _list findIf { (toLower (_x select 0)) == toLower _item && {(_x select 2) isEqualTo _weapon} };
        if (_at >= 0) then { (_list select _at) set [1, (((_list select _at) select 1) + 1) min 100] } else { _list pushBack [_item, 1, _weapon] };
        [["entries", [_pid, _list]] call ALiVE_fnc_fsDataPool] call _changed;
    };
    case "roll": {
        private _body = _session getOrDefault ["body", objNull];
        private _spec = [_unit] call _specOf;
        if (isNull _body || {!((_session getOrDefault ["bodyRef", ""]) isEqualTo _uid)} || {!(_body isKindOf "CAManBase")}) exitWith {};
        if (_spec isEqualTo []) exitWith { [1, "S_POOL_ROLL_NONE"] call ALiVE_fnc_fsStudioStatus };
        _body setUnitLoadout ([_unit getOrDefault ["loadout", []], _spec] call ALiVE_fnc_fsPoolRoll);
        [0, "S_POOL_ROLLED"] call ALiVE_fnc_fsStudioStatus;
    };
    case "unroll": {
        if (_uid in _units) then { ["unit", _uid] call ALiVE_fnc_fsStudioPreview };
    };
    case "close": {
        if (!isNull _popup) then { _popup closeDisplay 2 };
    };
    default {};
};
