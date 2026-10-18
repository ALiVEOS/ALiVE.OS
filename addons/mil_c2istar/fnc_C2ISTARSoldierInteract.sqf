#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(C2ISTARSoldierInteract);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_C2ISTARSoldierInteract

Description:
The soldier interaction window: talk to a surrendered enemy soldier or to a friendly
AI soldier, with or without ACE, the way Civilian Interaction talks to civilians.

A prisoner can be questioned (once), restrained, told to follow you or stay, searched
and released. A friendly soldier can be asked about the friendly units around him, what
enemy his group has seen, and where his group is headed. With ACE a prisoner is
restrained with ACE's own handcuffs and led away with ACE's escort, so Follow me and
Stay here are left to ACE.

Orders that move a soldier or read what his group knows run on the server, where the
soldier is; they travel by broadcast, as the rest of C2ISTAR's prisoner messages do,
so a mission's remote-execution whitelist can't stop them.

Parameters:
String - operation
    "init"    (every machine, once) the broadcast handlers
    "canTalk" [target, caller] whether "Talk to soldier" is offered
    "open"    [target] open the window on him
    "button"  operation of a button
    "closed"  the window was closed
    "server"  [operation, target, caller] an order run on the server
    "answer"  [operation, target, caller] "Seen anything?" / "Where to?" where the group lives
    "reply"   [text, markers, seconds] the server's answer, shown on the asker's machine
Any - arguments

Returns:
Bool for "canTalk", nothing otherwise

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], ["_args", []]];

#define SI_DISPLAY (findDisplay 9260)
#define SI_PRISONER_BUTTONS [92610, 92611, 92612, 92613, 92614, 92615]
#define SI_FRIENDLY_BUTTONS [92620, 92621, 92622]

private _hasAce = isClass (configFile >> "CfgPatches" >> "ace_captives");

// A line of text, or [key, arguments] read in this machine's language; an argument written
// "$STR_..." is read in it too. Answers worked out on another machine travel as keys.
private _fnc_tr = {
    if (_this isEqualType "") exitWith { _this };
    private _a = (_this select [1]) apply { if (_x isEqualType "" && {(_x find "$STR_") == 0}) then { localize (_x select [1]) } else { _x } };
    format ([localize (_this select 0)] + _a)
};

// The window's answer box, or a hint when the window is shut
private _fnc_say = {
    params ["_text"];
    _text = _text call _fnc_tr;
    if (isNull SI_DISPLAY) exitWith { [localize "STR_ALIVE_C2ISTAR", _text] call ALIVE_fnc_sendHint };
    // plain text: a name or callsign with < or & in it would break parsed markup
    (SI_DISPLAY displayCtrl 92602) ctrlSetStructuredText text _text;
};

switch (_operation) do {

    case "init": {
        if (isServer) then {
            "ALiVE_c2istar_soldierOrder" addPublicVariableEventHandler { ["server", _this select 1] call ALiVE_fnc_C2ISTARSoldierInteract };
        };
        if (hasInterface) then {
            "ALiVE_c2istar_soldierReply" addPublicVariableEventHandler { ["reply", _this select 1] call ALiVE_fnc_C2ISTARSoldierInteract };
        };
        if (isServer) then {
            // an answer worked out where the group lives (a headless client), passed on to the asker
            "ALiVE_c2istar_soldierRelay" addPublicVariableEventHandler {
                (_this select 1) params ["_caller", "_answer"];
                ALiVE_c2istar_soldierReply = _answer;
                if (local _caller) then { ["reply", _answer] call ALiVE_fnc_C2ISTARSoldierInteract } else { (owner _caller) publicVariableClient "ALiVE_c2istar_soldierReply" };
            };
        };
    };

    case "canTalk": {
        _args params [["_target", objNull], ["_caller", objNull]];
        if (isNull _target || {!alive _target} || {isPlayer _target} || {!(_target isKindOf "CAManBase")}
            || {vehicle _target != _target} || {(_caller distance _target) > 4.5}) exitWith { false };
        if (lifeState _target == "INCAPACITATED") exitWith { false };
        if (_target getVariable ["ALiVE_surrendered", false]) exitWith { !isNil "ALiVE_c2istar_fnc_askQuestion" };
        (side group _target) isEqualTo (side group _caller) && {!(group _target isEqualTo group _caller)}
    };

    case "open": {
        _args params [["_target", objNull]];
        if !(["canTalk", [_target, player]] call ALiVE_fnc_C2ISTARSoldierInteract) exitWith {};
        if (!isNull SI_DISPLAY) exitWith {};
        createDialog "ALiVE_SoldierInteraction";
        uiNamespace setVariable ["ALiVE_soldierInteractTarget", _target];
        private _prisoner = _target getVariable ["ALiVE_surrendered", false];
        (SI_DISPLAY displayCtrl 92601) ctrlSetText (if (_prisoner) then { format [localize "STR_ALIVE_C2ISTAR_SI_PRISONER_NAME", name _target] } else { name _target });
        { (SI_DISPLAY displayCtrl _x) ctrlShow _prisoner } forEach SI_PRISONER_BUTTONS;
        { (SI_DISPLAY displayCtrl _x) ctrlShow !_prisoner } forEach SI_FRIENDLY_BUTTONS;
        if (_prisoner) then {
            // once, or once more at a prison after being questioned in the field
            (SI_DISPLAY displayCtrl 92610) ctrlEnable ([_target, [getPosATL _target] call ALiVE_c2istar_fnc_atPrison] call ALiVE_c2istar_fnc_canBeQuestioned);
            // ACE leads its prisoners with its own escort
            if (_hasAce) then { { (SI_DISPLAY displayCtrl _x) ctrlShow false } forEach [92612, 92613] };
            [["STR_ALIVE_C2ISTAR_SI_PRISONER_OPEN"]] call _fnc_say;
        } else {
            // the friendly-units report is the module's Ask About Friendlies setting
            (SI_DISPLAY displayCtrl 92620) ctrlEnable !isNil "ALiVE_c2istar_fnc_askFriendly";
            [format ["%1 %2, %3.", [rank _target, "displayName"] call BIS_fnc_rankParams, name _target, groupId group _target]] call _fnc_say;
        };
    };

    case "closed": {
        uiNamespace setVariable ["ALiVE_soldierInteractTarget", objNull];
    };

    case "button": {
        private _op = _args;
        private _target = uiNamespace getVariable ["ALiVE_soldierInteractTarget", objNull];
        if (isNull _target || {!alive _target}) exitWith { closeDialog 0 };
        private _fnc_order = {
            ALiVE_c2istar_soldierOrder = [_this, _target, player];
            if (isServer) then { ["server", ALiVE_c2istar_soldierOrder] call ALiVE_fnc_C2ISTARSoldierInteract } else { publicVariableServer "ALiVE_c2istar_soldierOrder" };
        };
        switch (_op) do {
            case "question": {
                (SI_DISPLAY displayCtrl 92610) ctrlEnable false;
                [["STR_ALIVE_C2ISTAR_SI_QUESTION"]] call _fnc_say;
                [_target, player] call ALiVE_c2istar_fnc_askQuestion;
            };
            case "restrain": {
                if (_hasAce) then {
                    ["ace_captives_setHandcuffed", [_target, true], _target] call CBA_fnc_targetEvent;
                    [["STR_ALIVE_C2ISTAR_SI_RESTRAIN_ACE"]] call _fnc_say;
                } else {
                    "restrain" call _fnc_order;
                    [["STR_ALIVE_C2ISTAR_SI_RESTRAIN"]] call _fnc_say;
                };
            };
            case "follow": { "follow" call _fnc_order; [["STR_ALIVE_C2ISTAR_SI_FOLLOW"]] call _fnc_say };
            case "stay": { "stay" call _fnc_order; [["STR_ALIVE_C2ISTAR_SI_STAY"]] call _fnc_say };
            case "search": {
                private _kit = (uniformItems _target) + (vestItems _target) + (backpackItems _target) + (assignedItems _target);
                private _names = [];
                {
                    private _n = getText (configFile >> "CfgWeapons" >> _x >> "displayName");
                    if (_n == "") then { _n = getText (configFile >> "CfgMagazines" >> _x >> "displayName") };
                    if (_n == "") then { _n = getText (configFile >> "CfgGlasses" >> _x >> "displayName") };
                    if (_n == "") then { _n = getText (configFile >> "CfgVehicles" >> _x >> "displayName") };
                    if (_n == "") then { _n = _x };
                    _names pushBack _n;
                } forEach _kit;
                if (_names isEqualTo []) then { [["STR_ALIVE_C2ISTAR_SI_SEARCH_NONE"]] call _fnc_say } else {
                    private _counted = [];
                    { private _n = _x; if (_counted findIf { (_x select 0) == _n } < 0) then { _counted pushBack [_n, { _x == _n } count _names] } } forEach _names;
                    [["STR_ALIVE_C2ISTAR_SI_SEARCH_CARRIES", (_counted apply { if ((_x select 1) > 1) then { format ["%1 x%2", _x select 0, _x select 1] } else { _x select 0 } }) joinString ", "]] call _fnc_say;
                };
            };
            case "release": { "release" call _fnc_order; closeDialog 0; [localize "STR_ALIVE_C2ISTAR", format [localize "STR_ALIVE_C2ISTAR_SI_RELEASE", name _target]] call ALIVE_fnc_sendHint };
            case "friendlies": {
                // once a minute per soldier, as the old action was
                if (_target getVariable ["ALiVE_c2istar_askedRecently", false]) exitWith { [["STR_ALIVE_C2ISTAR_SI_FRIENDLIES_AGAIN"]] call _fnc_say };
                private _count = [_target, player] call ALiVE_c2istar_fnc_askFriendly;
                [[
                    ["STR_ALIVE_C2ISTAR_SI_FRIENDLIES_0"],
                    ["STR_ALIVE_C2ISTAR_SI_FRIENDLIES_1"],
                    ["STR_ALIVE_C2ISTAR_SI_FRIENDLIES_N", _count]
                ] select (_count min 2)] call _fnc_say;
            };
            case "seen": { "seen" call _fnc_order; [["STR_ALIVE_C2ISTAR_SI_SEEN_WAIT"]] call _fnc_say };
            case "headed": { "headed" call _fnc_order; [["STR_ALIVE_C2ISTAR_SI_HEADED_WAIT"]] call _fnc_say };
        };
    };

    case "server": {
        if (!isServer) exitWith {};
        _args params [["_op", ""], ["_target", objNull], ["_caller", objNull]];
        if (isNull _target || {!alive _target} || {isNull _caller} || {(_caller distance _target) > 10}) exitWith {};
        private _prisoner = _target getVariable ["ALiVE_surrendered", false];
        // Orders to the man himself, on the machine that owns him. A group change hands him to
        // the new group's owner a moment later, and orders sent before that are lost with the
        // move (AI switches don't travel), so they wait for it to settle first.
        private _fnc_onUnit = {
            params ["_code"];
            [_target, _code] spawn {
                params ["_t", "_c"];
                private _t0 = time;
                waitUntil { sleep 0.2; (owner _t) == (groupOwner group _t) || {time > _t0 + 5} };
                if (local _t) then { _t call _c } else { [_t, _c] remoteExecCall ["call", _t] };
            };
        };
        // Out of a player's group into a fresh one of his own side, calm and kept off the profiles
        private _fnc_ownGroup = {
            if ((group _target) getVariable ["ALIVE_profileIgnore", false] && {!isPlayer leader group _target}) exitWith {};
            private _g = createGroup [_target getVariable ["ALiVE_prisonerSide", side group _target], true];
            _g setVariable ["ALIVE_profileIgnore", true, true];
            [_target] joinSilent _g;
            _g allowFleeing 0;
            _g setBehaviour "CARELESS";
        };
        switch (_op) do {
            case "restrain": {
                if (!_prisoner) exitWith {};
                _target setVariable ["ALiVE_restrained", true, true];
                [] call _fnc_ownGroup;
                [{ doStop _this; _this disableAI "PATH"; _this disableAI "MOVE"; [_this, "Acts_ExecutionVictim_Loop"] remoteExecCall ["switchMove", 0] }] call _fnc_onUnit;
            };
            case "follow": {
                if (!_prisoner) exitWith {};
                // Into the player's group, as Civilian Interaction's Detain does. Left in a group of
                // his own he ran off: a surrender leaves the group fleeing, which neither
                // allowFleeing nor courage ended (measured: 190 m away in a minute, from 2 m).
                [_target, ""] remoteExecCall ["switchMove", 0];
                (group _caller) setVariable ["ALIVE_profileIgnore", true, true];
                [_target] joinSilent (group _caller);
                [{ _this enableAI "PATH"; _this enableAI "MOVE"; _this setUnitPos "UP"; _this doFollow (leader group _this) }] call _fnc_onUnit;
            };
            case "stay": {
                if (!_prisoner) exitWith {};
                [] call _fnc_ownGroup;
                [{
                    doStop _this; _this disableAI "PATH"; _this disableAI "MOVE";
                    if (_this getVariable ["ALiVE_restrained", false]) then { [_this, "Acts_ExecutionVictim_Loop"] remoteExecCall ["switchMove", 0] } else { _this action ["Surrender", _this] };
                }] call _fnc_onUnit;
            };
            case "release": {
                if (!_prisoner) exitWith {};
                _target setVariable ["ALiVE_restrained", false, true];
                [] call _fnc_ownGroup;
                [_target, ""] remoteExecCall ["switchMove", 0];
                // Off he goes, still unarmed and still captive; the prisoner cleanup removes him
                // once nobody is about. ACE's release takes his captive status with it (it was
                // ACE's surrender that gave it), so it's put back once ACE has let him go, or the
                // players' own AI shoot him as he walks away.
                [_target] spawn {
                    params ["_t"];
                    if (isClass (configFile >> "CfgPatches" >> "ace_captives")) then {
                        ["ace_captives_setHandcuffed", [_t, false], _t] call CBA_fnc_targetEvent;
                        ["ace_captives_setSurrendered", [_t, false], _t] call CBA_fnc_targetEvent;
                        private _t0 = time;
                        waitUntil { sleep 0.2; !(_t getVariable ["ace_captives_isSurrendering", false]) && {!(_t getVariable ["ace_captives_isHandcuffed", false])} || {time > _t0 + 5} };
                        [_t, "setCaptive", "ALiVE_prisoner", true] call ace_common_fnc_statusEffect_set;
                    };
                    private _t1 = time;
                    waitUntil { sleep 0.2; (owner _t) == (groupOwner group _t) || {time > _t1 + 5} };
                    private _go = { _this enableAI "PATH"; _this enableAI "MOVE"; _this setUnitPos "UP"; _this doMove (_this getPos [300, random 360]) };
                    if (local _t) then { _t call _go } else { [_t, _go] remoteExecCall ["call", _t] };
                };
            };
            case "seen";
            case "headed": {
                if (_prisoner) exitWith {};
                // worked out where the group lives: its knowledge and its plan are only there
                if (local leader group _target) then { ["answer", [_op, _target, _caller]] call ALiVE_fnc_C2ISTARSoldierInteract } else {
                    ["answer", [_op, _target, _caller]] remoteExecCall ["ALiVE_fnc_C2ISTARSoldierInteract", leader group _target];
                };
            };
        };
    };

    case "answer": {
        // "Seen anything?" and "Where to?", answered on the machine that owns the group
        _args params [["_op", ""], ["_target", objNull], ["_caller", objNull]];
        if (isNull _target || {isNull _caller}) exitWith {};
        private _fnc_reply = {
            if (isServer) then {
                ALiVE_c2istar_soldierReply = _this;
                if (local _caller) then { ["reply", _this] call ALiVE_fnc_C2ISTARSoldierInteract } else { (owner _caller) publicVariableClient "ALiVE_c2istar_soldierReply" };
            } else {
                ALiVE_c2istar_soldierRelay = [_caller, _this];
                publicVariableServer "ALiVE_c2istar_soldierRelay";
            };
        };
        switch (_op) do {
            case "seen": {
                private _side = side group _target;
                private _known = ((leader group _target) targets [true, 1500]) select { alive _x && {(_side getFriend side group _x) < 0.6} };
                private _groups = [];
                { _groups pushBackUnique group _x } forEach _known;
                private _marks = _groups apply { [getPosATL leader _x, "hd_dot", ["STR_ALIVE_C2ISTAR_SI_MARK_ENEMY", ["$STR_ALIVE_C2ISTAR_SI_INFANTRY", "$STR_ALIVE_C2ISTAR_SI_VEHICLE"] select (vehicle leader _x != leader _x)]] };
                [[
                    ["STR_ALIVE_C2ISTAR_SI_SEEN_NONE", name _target],
                    [["STR_ALIVE_C2ISTAR_SI_SEEN_ONE", "STR_ALIVE_C2ISTAR_SI_SEEN_N"] select (count _groups > 1), name _target, count _groups]
                ] select (_groups isNotEqualTo []), _marks, 120] call _fnc_reply;
            };
            case "headed": {
                private _g = group _target;
                private _wp = [_g, currentWaypoint _g];
                private _pos = if ((currentWaypoint _g) < count (waypoints _g)) then { waypointPosition _wp } else { expectedDestination (leader _g) select 0 };
                if (isNil "_pos" || {_pos isEqualTo [0,0,0]} || {(_pos distance2D _target) < 50}) exitWith {
                    [["STR_ALIVE_C2ISTAR_SI_HEADED_HOLD", name _target], [], 0] call _fnc_reply;
                };
                [["STR_ALIVE_C2ISTAR_SI_HEADED_TO", name _target, mapGridPosition _pos, round ((_pos distance2D _target) / 10) * 10,
                    ["$STR_ALIVE_C2ISTAR_SI_DIR_N", "$STR_ALIVE_C2ISTAR_SI_DIR_NE", "$STR_ALIVE_C2ISTAR_SI_DIR_E", "$STR_ALIVE_C2ISTAR_SI_DIR_SE", "$STR_ALIVE_C2ISTAR_SI_DIR_S", "$STR_ALIVE_C2ISTAR_SI_DIR_SW", "$STR_ALIVE_C2ISTAR_SI_DIR_W", "$STR_ALIVE_C2ISTAR_SI_DIR_NW"] select (round ((_target getDir _pos) / 45) mod 8)],
                    [[_pos, "hd_objective", ["STR_ALIVE_C2ISTAR_SI_MARK_HEADED", groupId _g]]], 120] call _fnc_reply;
            };
        };
    };

    case "reply": {
        if (!hasInterface) exitWith {};
        _args params [["_text", ""], ["_marks", []], ["_seconds", 0]];
        [_text] call _fnc_say;
        private _made = [];
        {
            _x params ["_pos", "_type", "_label"];
            ALiVE_c2istar_siMarkerCount = (missionNamespace getVariable ["ALiVE_c2istar_siMarkerCount", 0]) + 1;
            private _m = createMarkerLocal [format ["ALiVE_c2istar_si_%1", ALiVE_c2istar_siMarkerCount], _pos];
            _m setMarkerTypeLocal _type;
            _m setMarkerColorLocal (["ColorRed", "ColorBlue"] select (_type == "hd_objective"));
            _m setMarkerTextLocal (_label call _fnc_tr);
            _made pushBack _m;
        } forEach _marks;
        if (_made isNotEqualTo []) then { [_made, _seconds] spawn { sleep (_this select 1); { deleteMarkerLocal _x } forEach (_this select 0) } };
    };
};
