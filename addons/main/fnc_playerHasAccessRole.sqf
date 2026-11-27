/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_playerHasAccessRole

Description:
Shared rank, slot and condition gate for the player modules (C2ISTAR, Player Logistics, Combat Support,
Recruitment), asked beside the access-item gate (ALIVE_fnc_playerHasAccessItems). Items can be picked
off a dead player; rank, slot and a mission's own condition can't.

Each module keeps three settings on its logic, broadcast by the server at start:
    ALiVE_accessRank       "ANY" (default), "LEADER" (group leaders only), or the lowest rank allowed:
                           "CORPORAL", "SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"
    ALiVE_accessSlots      comma separated; each entry matches the unit's variable name (exact), its
                           role description (contains) or its group's callsign (exact), without case
    ALiVE_accessCondition  SQF run on the player's machine with _caller as the player; must return true

With neither rank nor slots set, everyone passes them; with either or both set, meeting one is enough.
A condition, when set, must also return true. One that errors or returns anything but true or false
refuses, and is said once in the RPT. A logged-in admin (or a listen server's host) always passes, so a
mission maker can't lock themselves out; in single player the settings apply, so they can be tried.

Parameters:
0: OBJECT - the module logic holding the settings (objNull: everyone passes)
1: OBJECT - the unit to ask about (default player)
2: BOOL   - tell the player why, at most once every 10 s per module (default false)
3: STRING - the module's name for the hint (default "")

Returns:
BOOL - true when the unit may use the module

Examples:
(begin example)
if !([NEO_radioLogic, player, true, localize "STR_ALIVE_COMBATSUPPORT"] call ALIVE_fnc_playerHasAccessRole) exitWith {};
(end)

Author: Jman
---------------------------------------------------------------------------- */

params [["_holder", objNull, [objNull]], ["_unit", objNull, [objNull]], ["_tell", false, [false]], ["_label", "", [""]]];
if (isNull _unit) then { _unit = player };
if (isNull _holder || {isNull _unit}) exitWith { true };

private _rank = _holder getVariable ["ALiVE_accessRank", "ANY"];
if !(_rank isEqualType "") then { _rank = "ANY" };
_rank = toUpper trim _rank;
private _slots = _holder getVariable ["ALiVE_accessSlots", ""];
if !(_slots isEqualType "") then { _slots = "" };
private _cond = _holder getVariable ["ALiVE_accessCondition", ""];
if !(_cond isEqualType "") then { _cond = "" };
_cond = trim _cond;

private _slotList = ((_slots splitString ",") apply { toLower trim _x }) select { _x != "" };
if (_rank in ["", "ANY"] && {_slotList isEqualTo []} && {_cond == ""}) exitWith { true };

// an admin, or a listen server's host, always gets in
if (_unit isEqualTo player && {isMultiplayer} && {serverCommandAvailable "#kick"}) exitWith { true };

private _ranks = ["PRIVATE", "CORPORAL", "SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"];
private _rankSet = !(_rank in ["", "ANY"]);
private _rankOk = _rankSet && {
    if (_rank == "LEADER") then { leader group _unit isEqualTo _unit } else {
        private _need = _ranks find _rank;
        _need >= 0 && {rankId _unit >= _need}
    }
};
private _slotOk = _slotList isNotEqualTo [] && {
    private _var = toLower vehicleVarName _unit;
    private _role = toLower roleDescription _unit;
    private _call = toLower groupId group _unit;
    (_slotList findIf { _x == _var || {_x == _call} || {_role != "" && {_x in _role}} }) >= 0
};
private _ok = (!_rankSet && {_slotList isEqualTo []}) || {_rankOk} || {_slotOk};

if (_ok && {_cond != ""}) then {
    // compiled once per text; one that errors is remembered as broken and never run again, so a menu
    // asking every frame can't fill the RPT
    private _cache = missionNamespace getVariable ["ALiVE_accessCondCache", createHashMap];
    private _code = _cache getOrDefault [_cond, nil];
    if (isNil "_code") then {
        _code = compile _cond;
        if (isNil "_code") then { _code = {} };
        _cache set [_cond, _code];
        missionNamespace setVariable ["ALiVE_accessCondCache", _cache];
    };
    if (_code isEqualType "") exitWith { _ok = false };
    private _caller = _unit;
    private _r = call _code;
    if (isNil "_r" || {!(_r isEqualType true)}) then {
        _cache set [_cond, "broken"];
        ["ALiVE access: the Access Condition of %1 did not return true or false, so nobody passes it: %2", [_label, typeOf _holder] select (_label == ""), _cond] call ALiVE_fnc_dump;
        _ok = false;
    } else {
        _ok = _r;
    };
};

if (!_ok && {_tell} && {hasInterface} && {_unit isEqualTo player}) then {
    private _told = missionNamespace getVariable ["ALiVE_accessToldAt", createHashMap];
    private _key = [_label, str _holder] select (_label == "");
    if (diag_tickTime - (_told getOrDefault [_key, -1e9]) >= 60) then {
        _told set [_key, diag_tickTime];
        missionNamespace setVariable ["ALiVE_accessToldAt", _told];
        private _who = [];
        if (_rankSet) then {
            _who pushBack (if (_rank == "LEADER") then { localize "STR_ALIVE_ACCESS_WHO_LEADER" } else {
                format [localize "STR_ALIVE_ACCESS_WHO_RANK", (_rank select [0, 1]) + toLower (_rank select [1])] });
        };
        if (_slotList isNotEqualTo []) then { _who pushBack format [localize "STR_ALIVE_ACCESS_WHO_SLOTS", _slots] };
        private _text = if (_who isEqualTo []) then { localize "STR_ALIVE_ACCESS_DENIED_MISSION" } else {
            format [localize "STR_ALIVE_ACCESS_DENIED", _who joinString (localize "STR_ALIVE_ACCESS_OR")] };
        [[localize "STR_ALIVE_ACCESS_TITLE", _label] select (_label != ""), _text] call ALIVE_fnc_sendHint;
    };
};

_ok
