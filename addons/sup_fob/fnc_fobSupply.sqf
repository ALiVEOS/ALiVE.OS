#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobSupply);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_fobSupply

Description:
A FOB's supply, whichever Supply Source the module uses. Every cost is a debit and every
refund a credit through here, so the three sources behave the same to everything else.

FOB supply (FOBPOOL) and Supply crates (CRATES) keep a count on each FOB, limited by its
tier's Supply Limit; they differ only in how it's topped up (that comes later). Force pool
(FORCEPOOL) spends the force pool of the FOB's faction, the one Military Logistics keeps and
Recruitment spends; a faction with no pool is free and reports -1, as Recruitment does.

Parameters:
String - The operation
Array - Its arguments

Returns:
balance - [fobID] -> what can be spent now (-1 when it's free)
cap - [fobID] -> the most it can hold (-1 for the force pool)
canAfford - [fobID, amount] -> true or false
debit - [fobID, amount, reason] -> true when taken, false when there isn't enough
credit - [fobID, amount, reason] -> the new balance

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};

params [["_operation", "", [""]], ["_args", [], [[]]]];

private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
private _set = { [_logic, "attribute", [_this]] call ALiVE_fnc_FOB };
private _mode = "fob_supply_source" call _set;
// poolDebit [faction, amount]: straight from a faction's force pool, no FOB involved (a Field
// HQ handing out a kit in force pool mode). A faction with no pool is free.
if (_operation == "poolDebit") exitWith {
    _args params [["_faction", "", [""]], ["_amount", 0, [0]]];
    if (isNil "ALIVE_globalForcePool" || {!(_faction in (ALIVE_globalForcePool select 1))}) exitWith { true };
    private _left = [ALIVE_globalForcePool, _faction, 0] call ALIVE_fnc_hashGet;
    if (_left isEqualType "") then { _left = parseNumber _left };
    if (_amount > _left) exitWith { false };
    [ALIVE_globalForcePool, _faction, _left - (_amount max 0)] call ALIVE_fnc_hashSet;
    true
};

private _entry = [ALiVE_FOB_registry, _args param [0, ""]] call ALIVE_fnc_hashGet;
if (isNil "_entry") exitWith { if (_operation in ["canAfford", "debit"]) then {false} else {0} };

private _poolOf = {
    private _faction = [_entry, "faction", ""] call ALIVE_fnc_hashGet;
    if (isNil "ALIVE_globalForcePool" || {!(_faction in (ALIVE_globalForcePool select 1))}) exitWith { [_faction, -1] };
    private _left = [ALIVE_globalForcePool, _faction, 0] call ALIVE_fnc_hashGet;
    if (_left isEqualType "") then { _left = parseNumber _left };
    [_faction, _left]
};
private _capOf = { ("fob_supply_cap_t" + str ([_entry, "tier", 1] call ALIVE_fnc_hashGet)) call _set };
private _debug = "fob_debug" call _set;
private _result = 0;

switch (_operation) do {

    case "balance": {
        _result = if (_mode == "FORCEPOOL") then { (call _poolOf) select 1 } else { [_entry, "supply", 0] call ALIVE_fnc_hashGet };
    };

    case "cap": {
        _result = if (_mode == "FORCEPOOL") then { -1 } else { call _capOf };
    };

    case "canAfford": {
        _args params ["", ["_amount", 0, [0]]];
        private _balance = ["balance", [_args select 0]] call ALiVE_fnc_fobSupply;
        _result = _balance < 0 || {_amount <= _balance};
    };

    case "debit": {
        _args params ["", ["_amount", 0, [0]], ["_reason", "", [""]]];
        _amount = _amount max 0;
        if (_mode == "FORCEPOOL") then {
            (call _poolOf) params ["_faction", "_left"];
            if (_left < 0) exitWith { _result = true };
            if (_amount > _left) exitWith { _result = false };
            [ALIVE_globalForcePool, _faction, _left - _amount] call ALIVE_fnc_hashSet;
            _result = true;
        } else {
            private _have = [_entry, "supply", 0] call ALIVE_fnc_hashGet;
            if (_amount > _have) exitWith { _result = false };
            [_entry, "supply", _have - _amount] call ALIVE_fnc_hashSet;
            ALiVE_FOB_dirty = true;
            _result = true;
        };
        if (_debug) then { ["ALiVE Player FOBs - %1 debit %2 (%3): %4", _args select 0, _amount, _reason, _result] call ALiVE_fnc_dump };
    };

    case "credit": {
        _args params ["", ["_amount", 0, [0]], ["_reason", "", [""]]];
        _amount = _amount max 0;
        if (_mode == "FORCEPOOL") then {
            (call _poolOf) params ["_faction", "_left"];
            if (_left < 0) exitWith { _result = -1 };
            _result = _left + _amount;
            [ALIVE_globalForcePool, _faction, _result] call ALIVE_fnc_hashSet;
        } else {
            _result = (([_entry, "supply", 0] call ALIVE_fnc_hashGet) + _amount) min (call _capOf);
            [_entry, "supply", _result] call ALIVE_fnc_hashSet;
            ALiVE_FOB_dirty = true;
        };
        if (_debug) then { ["ALiVE Player FOBs - %1 credit %2 (%3): now %4", _args select 0, _amount, _reason, _result] call ALiVE_fnc_dump };
    };
};

_result
