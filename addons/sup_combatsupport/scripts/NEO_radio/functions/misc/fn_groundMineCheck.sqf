/*
    NEO_fnc_groundMineCheck
    #690: the road check of a Combat Support ground vehicle. While it drives on an order, the
    crew watches the road 20 to 70 m ahead for an IED (the IED module's) or a mine (the game's
    own, placed by anyone but its own side). On a find the vehicle stops, the crew works on it
    for 8 s, and a roll against the module's Disarm Chance decides: success removes it, failure
    goes off at the vehicle (the crew got it wrong while working on it, as a player does). Then
    the vehicle drives on with the order under way.

    Engine mines that belong to an IED module device (an ACE or RHS skin made with createMine)
    carry the IED's "town" and go the IED way only. A found device is claimed before the roll,
    so the IED module's own trip checks wait instead of firing on the stopped vehicle.

    Params: 0: _veh <OBJECT>. Server-side.
    Author: Jman
*/
params ["_veh"];
if (!isServer || {isNull _veh}) exitWith {};

private _fnc_say = {
    params ["_key", ["_args", []]];
    [[_veh, [_key, _veh getVariable ["NEO_groundCallsign", ""]] + _args, "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
};
// a placed mine belongs to whoever placed it; null parents (editor, Zeus, a save) count as unknown
private _fnc_ownSide = {
    params ["_mine"];
    private _who = (getShotParents _mine) param [1, objNull];
    if (isNull _who) then { _who = (getShotParents _mine) param [0, objNull] };
    !isNull _who && {(side group _who) isEqualTo (side group driver _veh)}
};

// ends with the vehicle, or when it is written off (a hull kept for players aboard)
while { alive _veh && {(_veh getVariable ["NEO_radioGroundRun", 0]) != -1} } do {
    sleep 0.5;
    if (speed _veh > 2
        && {(_veh getVariable ["NEO_radioGroundUnitStatus", ""]) in ["MISSION", "PATROL", "RTB"]}
        && {!(_veh getVariable ["NEO_groundDisarming", false])}) then {

        private _p = _veh getPos [45, getDir _veh];
        private _found = objNull;
        private _isIED = false;
        // the IED module's devices (any object it gave a "town")
        {
            if (alive _x && {!isNil {_x getVariable "town"}}
                && {!(_x getVariable ["ALiVE_IED_Disarmed", false])}
                && {!(_x getVariable ["ALiVE_IED_Detonating", false])}
                && {!(_x getVariable ["NEO_groundChecked", false])}) exitWith { _found = _x; _isIED = true };
        } forEach (_p nearObjects 25);
        // the game's mines
        if (isNull _found) then {
            {
                if ((_x distance2D _p) < 25 && {mineActive _x}
                    && {isNil {_x getVariable "town"}}
                    && {isNil {(attachedTo _x) getVariable "town"}}
                    && {!(_x getVariable ["NEO_groundChecked", false])}
                    && {!([_x] call _fnc_ownSide)}) exitWith { _found = _x };
            } forEach allMines;
        };

        if (!isNull _found) then {
            _found setVariable ["NEO_groundChecked", true, true];
            if (_isIED) then { _found setVariable ["ALiVE_IED_Claimed", true, true] };
            _veh setVariable ["NEO_groundDisarming", true, true];
            _veh setVariable ["NEO_groundDefendPaused", true, true];
            [_veh] call NEO_fnc_groundStop;
            private _at = getPosATL _found;
            ["STR_ALIVE_CS_MSG_GR_DEVICE_FOUND", [mapGridPosition _at]] call _fnc_say;
            sleep 8;
            if (!alive _veh) exitWith { if (_isIED) then { _found setVariable ["ALiVE_IED_Claimed", false, true] } };

            private _chance = _veh getVariable ["NEO_groundDisarmChance", 70];
            private _ok = (random 100) < _chance;
            if (_isIED) then {
                private _addon = missionNamespace getVariable ["ALiVE_mil_ied", objNull];
                { deleteVehicle (_found getVariable [_x, objNull]) } forEach ["Trigger", "Detect_Trigger", "Det_Trigger"];
                if (_ok) then {
                    _found setVariable ["ALiVE_IED_Disarmed", true, true];
                    [_at, [str (side group driver _veh)], -20] call ALiVE_fnc_updateSectorHostility;
                } else {
                    _found setVariable ["ALiVE_IED_Detonating", true, true];
                };
                if (!isNull _addon) then { [_addon, "removeIED", _found] call ALiVE_fnc_IED };
                private _charge = _found getVariable ["charge", objNull];
                { if (_x isKindOf "ALIVE_DemoCharge_Remote_Ammo" || {_x == _charge}) then { detach _x; deleteVehicle _x } } forEach (attachedObjects _found);
                if (!isNull _charge) then { deleteVehicle _charge };
                deleteVehicle _found;
            };
            // a failed attempt goes off at the vehicle's front, where the crew was working on it:
            // a mine as itself, so an AT mine hits as hard as it would have; an IED as the IED
            // module's own blast (its charge is already gone, so its damage handler can't add another)
            private _blast = _veh getPos [((boundingBoxReal _veh) select 1 select 1) + 2, getDir _veh];
            _blast = [_blast select 0, _blast select 1, 0];
            if (_isIED) then {
                if (!_ok) then { ([["R_60mm_HE", "Bomb_03_F", "Bomb_04_F"], [8, 1, 1]] call BIS_fnc_selectRandomWeighted) createVehicle _blast };
            } else {
                if (_ok) then { deleteVehicle _found } else {
                    _found setPosATL _blast;
                    [_found] remoteExecCall ["triggerAmmo", owner _found];
                };
            };
            ["ALiVE Combat Support - ground transport %1 %2 a %3 at %4 (chance %5)", _veh getVariable ["NEO_groundCallsign", ""], ["set off", "disarmed"] select _ok, ["mine", "IED"] select _isIED, mapGridPosition _at, _chance] call ALiVE_fnc_dump;
            [["STR_ALIVE_CS_MSG_GR_DETONATED", "STR_ALIVE_CS_MSG_GR_DISARMED"] select _ok] call _fnc_say;

            sleep 2;
            if (alive _veh) then {
                _veh setVariable ["NEO_groundDefendPaused", false, true];
                _veh setVariable ["NEO_groundDisarming", false, true];
            };
        };
    };
};
