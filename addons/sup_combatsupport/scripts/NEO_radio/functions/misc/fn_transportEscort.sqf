/*
    NEO_fnc_transportEscort (Eric on Discord, 22 Oct): a support vehicle escorts a transport the player ordered, set to
    fire at will. Runs on the server, sent there by the transport panel's confirm with the Escort box's choice.

    [transport, escort netId ("" for none), "AIR" | "GROUND", the player who asked]

    An air escort (an attack helicopter from the CAS list, or an armed transport helicopter) flies 150 m behind the
    transport, and circles 250 m out while the transport is slow or on the ground, never landing. A ground escort
    (an armed ground transport) drives 40 m behind it. Its own group throughout: in the transport's group its gunners
    would only fire as the pilot's, and the transport's own orders would move it too.

    It lets go, and the escort goes home, when the transport heads home, stands down, is lost or is given a new escort
    (or none); when the escort itself is lost or given an order of its own.

    Author: Jman
*/
if (!isServer) exitWith {};
if (!canSuspend) exitWith { _this spawn NEO_fnc_transportEscort };
params [["_transport", objNull], ["_escortId", ""], ["_kind", "AIR"], ["_player", objNull]];
if (isNull _transport) exitWith {};
private _escort = if (_escortId isEqualTo "") then { objNull } else { _escortId call BIS_fnc_objectFromNetId };
private _air = _kind == "AIR";

// the transport's escort is this one from now; a loop running for another one sees that and lets go
if (isNull _escort || {!alive _escort}) exitWith { _transport setVariable ["NEO_radioEscort", objNull, true] };
if ((_transport getVariable ["NEO_radioEscort", objNull]) isEqualTo _escort && {(_escort getVariable ["NEO_radioEscorting", objNull]) isEqualTo _transport}) exitWith {};

// which of the side's lists it is on says which order and status it answers to
private _side = side group driver _transport;
private _onList = {
    params ["_name"];
    ((NEO_radioLogic getVariable [format [_name, _side], []]) findIf { (_x select 0) isEqualTo _escort }) > -1
};
private _type = switch (true) do {
    case (["NEO_radioCasArray_%1"] call _onList): { "CAS" };
    case (["NEO_radioTrasportArray_%1"] call _onList): { "TRANSPORT" };
    case (["NEO_radioGroundArray_%1"] call _onList): { "GROUND" };
    default { "" };
};
if (_type == "") exitWith { _transport setVariable ["NEO_radioEscort", objNull, true] };
private _statusVar = ["NEO_radioCasUnitStatus", "NEO_radioTrasportUnitStatus", "NEO_radioGroundUnitStatus"] select (["CAS", "TRANSPORT", "GROUND"] find _type);
private _orderVar = ["NEO_radioCasNewTask", "NEO_radioTransportNewTask", "NEO_radioGroundNewTask"] select (["CAS", "TRANSPORT", "GROUND"] find _type);
private _trStatusVar = ["NEO_radioGroundUnitStatus", "NEO_radioTrasportUnitStatus"] select _air;
// standing by, and not escorting another transport already
if ((_escort getVariable [_statusVar, "NONE"]) != "NONE" || {!isNull (_escort getVariable ["NEO_radioEscorting", objNull])}) exitWith {
    _transport setVariable ["NEO_radioEscort", objNull, true];
    if (!isNull _player) then { [localize "STR_ALIVE_CS_MSG_ESCORT_BUSY"] remoteExec ["hint", _player] };
};

_transport setVariable ["NEO_radioEscort", _escort, true];
_escort setVariable ["NEO_radioEscorting", _transport, true];
_escort setVariable [_statusVar, "MISSION", true];
private _mark = ["ESCORT", _transport];
_escort setVariable ["NEO_radioCurrentTask", _mark, true];
private _grp = group driver _escort;
private _was = [behaviour leader _grp, combatMode _grp];
private _defendWas = _escort getVariable "NEO_radioGunnerDefendOn";
// fire at will and stay on the route, as measured for the transports' door gunners (fn_transportGunnerDefend): the crew
// one calm group at YELLOW, targeting on, the pilot kept from escalating to combat (which makes a helicopter hover or
// break off), no leader sending them after what they see, and the gunners shown what to shoot at (below)
[_grp, "CARELESS"] remoteExec ["setBehaviour", leader _grp];
[_grp, "YELLOW"] remoteExec ["setCombatMode", leader _grp];
[_grp, false] remoteExec ["enableAttack", leader _grp];
{ [_x, "TARGET"] remoteExec ["enableAI", _x]; [_x, "AUTOTARGET"] remoteExec ["enableAI", _x] } forEach units _grp;
[driver _escort, "AUTOCOMBAT"] remoteExec ["disableAI", driver _escort];
// an armed transport already has the door gunners' loop: switch it to fire. Anything else gets it from the loop below
private _ownLoop = _escort getVariable ["NEO_radioGunnerDefendArmed", false];
if (_ownLoop) then { _escort setVariable ["NEO_radioGunnerDefendOn", true, true] };
private _gside = side _grp;
["CS - %1 escorts %2", _escort, _transport] call ALiVE_fnc_dump;
// said once it is really on its way
if (!isNull _player) then {
    private _cs = { (format ["%1", group driver _this]) call NEO_fnc_callsignFix };
    [[_player, ["STR_ALIVE_CS_MSG_ESCORT", _escort call _cs, _transport call _cs], "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
};

private _busy = false;     // the transport has taken its order: standing down after that is the end of it
private _circle = 0;
private _height = -1;
private _stopped = false;
while {true} do {
    sleep 2;
    if (!alive _transport || {!alive _escort} || {!alive driver _escort} || {!canMove _escort}) exitWith {};
    if !((_transport getVariable ["NEO_radioEscort", objNull]) isEqualTo _escort) exitWith {};
    if !((_escort getVariable ["NEO_radioCurrentTask", []]) isEqualTo _mark) exitWith {};
    if (!isNil {_escort getVariable _orderVar}) exitWith {};
    private _st = _transport getVariable [_trStatusVar, "NONE"];
    if (_st != "NONE") then { _busy = true };
    // an air transport stands down only once home; a ground one stands down at the end of every leg, so for it only
    // heading home ends the escort
    if (_st in ["RTB", "KILLED"] || {_air && {_busy && {_st == "NONE"}}}) exitWith {};
    // the gunners onto the nearest enemy in sight of the escort or round the transport
    if (!_ownLoop) then {
        private _gunners = ((allTurrets _escort) select { (_escort weaponsTurret _x) isNotEqualTo [] }) apply { _escort turretUnit _x } select { alive _x && {!isPlayer _x} };
        if (_gunners isNotEqualTo []) then {
            private _t = objNull;
            private _td = 1e9;
            {
                if (alive _x && {side _x != civilian} && {(_gside getFriend (side _x)) < 0.6} && {(_x distance _escort) < _td}
                    && {lineIntersectsSurfaces [eyePos _escort, aimPos _x, _escort, _x] isEqualTo []}) then { _td = _x distance _escort; _t = _x };
            } forEach ((_escort nearEntities [["Man", "Car", "Tank", "Air", "Ship"], 800]) + (_transport nearEntities [["Man", "Car", "Tank"], 400]));
            if (!isNull _t) then { _grp reveal [_t, 4]; { _x doTarget _t; _x doFire _t } forEach _gunners };
        };
    };
    private _tp = getPosATL _transport;
    if (_air) then {
        private _slow = speed _transport < 15 || {isTouchingGround _transport};
        private _goal = if (_slow) then { _circle = _circle + 30; _tp getPos [250, _circle] } else { _tp getPos [150, getDir _transport + 180] };
        private _h = [((_tp select 2) max 60) + 50, 120] select _slow;
        if (abs (_h - _height) > 30) then { _height = _h; [_escort, _h min 1000] remoteExec ["flyInHeight", _escort] };
        if (_slow || {(_escort distance2D _goal) > 80}) then { [_escort, _goal] call ALiVE_fnc_doMoveRemote };
    } else {
        if ((_escort distance2D _transport) > 60) then {
            _stopped = false;
            [_escort, _tp getPos [40, getDir _transport + 180]] call ALiVE_fnc_doMoveRemote;
        } else {
            if (!_stopped && {speed _transport < 3}) then { _stopped = true; [_escort, getPosATL _escort] call ALiVE_fnc_doMoveRemote };
        };
    };
};

// let go: back as it was, and home unless it has an order of its own
_escort setVariable ["NEO_radioEscorting", nil, true];
if ((_transport getVariable ["NEO_radioEscort", objNull]) isEqualTo _escort) then { _transport setVariable ["NEO_radioEscort", objNull, true] };
if (_ownLoop) then { _escort setVariable ["NEO_radioGunnerDefendOn", if (isNil "_defendWas") then { true } else { _defendWas }, true] };
if (!isNull _grp) then {
    [_grp, _was select 0] remoteExec ["setBehaviour", leader _grp];
    [_grp, _was select 1] remoteExec ["setCombatMode", leader _grp];
};
["CS - %1 stops escorting %2", _escort, _transport] call ALiVE_fnc_dump;
if (alive _escort && {(_escort getVariable ["NEO_radioCurrentTask", []]) isEqualTo _mark} && {isNil {_escort getVariable _orderVar}}) then {
    private _base = _escort getVariable ["ALIVE_CombatSupport_Base", []];
    private _rtb = switch (_type) do {
        case "CAS": { ["RTB", _base, 0, 0, "", "", _player] };
        default { ["RTB", _base, 0, _player] };
    };
    _escort setVariable [_orderVar, _rtb, true];
};
