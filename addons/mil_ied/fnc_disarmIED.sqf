// Disarm IED - ran on client only
#include "\x\alive\addons\mil_IED\script_component.hpp"
SCRIPT(disarmIED);

// Client-side disarm handler. Introduces a skill-scaled disarm time during
// which the IED remains vulnerable to the server-side trip accumulator (another
// engineer stepping in, or the disarmer themselves standing/sprinting mid-job).
// The "new device" wire-guess chance also scales with skill.
//
// Tunables (ADDON getVariable):
//   IED_Engineer_Disarm_BaseTime      - base disarm seconds at skill 1.0 (default 60)
//   IED_Engineer_Disarm_NewDeviceBase - baseline wire-guess threshold (default 0.75)
//                                       Effective trigger rate: ~10% at skill 1.0,
//                                       ~25% at skill 0, clamped into [0.70, 0.90].

private ["_debug","_IED","_caller","_id","_IEDCharge"];

if (isDedicated) exitWith {["disarmIED running on server!"] call ALiVE_fnc_dump;};

// ADDON expands to the global ALiVE_mil_ied (the mil_ied module logic,
// broadcast publicVariable-style from the server). If the broadcast
// hasn't arrived on this client yet, the global is nil and any
// `ADDON getVariable [...]` below would throw a Generic-error popup.
// Reported 2026-05-24 (Ares #890) with the popup pointing at line 91.
// objNull's getVariable returns the supplied default cleanly, so the
// function degrades to the legacy defaults instead of crashing.
private _addonLogic = if (isNil QUOTE(ADDON)) then { objNull } else { ADDON };

_debug = _addonLogic getVariable ["debug", false];

_IED    = _this select 0;
_caller = _this select 1;
_id     = _this select 2;

_IEDCharge = _IED getVariable ["charge", nil];

// Bail immediately if this container has already been disarmed - stale addActions
// on other clients can still fire after the charge has been recovered.
if (_IED getVariable ["ALiVE_IED_Disarmed", false]) exitWith {
    hint "IED already disarmed.";
};

// Everything below needs scheduled context (sleep / waitUntil). addAction
// callbacks are unscheduled, so spawn a fresh thread.
[_IED, _caller, _id, _IEDCharge, _addonLogic] spawn {
    params ["_IED", "_caller", "_id", "_IEDCharge", "_addonLogic"];

    // Nested fn: complete a successful disarm. Keeps the container intact,
    // strips the charge from it, and hands the demo charge to the disarmer's
    // inventory (or drops it nearby in a GroundWeaponHolder). Called from
    // both the wire-guess-success and the auto-success paths.
    private _fnDisarmSuccess = {
        params ["_IED", "_caller", "_id", "_IEDCharge", "_successHint"];

        // Stop the armIED proximity loop - loop checks this variable.
        _IED setVariable ["ALiVE_IED_Disarmed", true, true];

        // Strip the local disarm action (best-effort - addAction IDs are per-client;
        // addActionIED's condition also hides stale entries on other clients).
        [_IED, _id] remoteExec ["ALiVE_fnc_removeActionIED", 0, true];

        // Clean up the stub proximity triggers the armIED spawn created.
        private _trgr = (position _IED) nearObjects ["EmptyDetector", 3];
        {
            deleteVehicle _x;
        } foreach _trgr;

        // Remove from module tracking + drop sector hostility.
        [[position _IED, [str(side group player)], -20] ,"ALiVE_fnc_updateSectorHostility", false, false, true] call BIS_fnc_MP;
        [[ADDON, "removeIED", _IED] ,"ALiVE_fnc_IED", false, false, true] call BIS_fnc_MP;

        // Detach and delete the charge visual. The user's rule: keep the
        // container (trash pile / tyre / junk) visible, only remove the bomb.
        if (!isNil "_IEDCharge" && {!isNull _IEDCharge}) then {
            _IEDCharge removeEventHandler ["handleDamage", _IED getVariable "ehID"];
            detach _IEDCharge;
            deleteVehicle _IEDCharge;
            _IED setVariable ["charge", objNull, true];

            // Award the recovered charge to the disarmer. Inventory first, then
            // a GroundWeaponHolder ~3m away if the disarmer is full.
            private _chargeMag = "DemoCharge_Remote_Mag";
            if (_caller canAdd _chargeMag) then {
                _caller addMagazine _chargeMag;
                hint format ["%1 Charge recovered - added to inventory.", _successHint];
            } else {
                private _holderPos = _caller getPos [3, random 360];
                private _holder = createVehicle ["GroundWeaponHolder", _holderPos, [], 2, "NONE"];
                _holder addMagazineCargoGlobal [_chargeMag, 1];
                hint format ["%1 Inventory full - charge placed on the ground nearby.", _successHint];
            };
        } else {
            // Dud or 3rd-party IED: no separate charge to recover. Leave the
            // container alive but announce the disarm.
            hint _successHint;
        };
    };

    private _skill             = _caller skillFinal "commanding";

    // This function runs client-side. Eden Combo attributes are stored on
    // the module logic as STRINGS, and the server's init-time numeric
    // coercion (fnc_IED.sqf case handlers) isn't broadcast to clients --
    // so these reads can come back as "1" / "60" / "0.75". Comparing or
    // doing arithmetic on a string throws a Generic error (#890, Ares
    // 2026-05-27 client RPT, line 100). Coerce each defensively.
    private _challengeRaw = _addonLogic getVariable ["IED_Engineer_Challenge", 1];
    if (_challengeRaw isEqualType "") then { _challengeRaw = parseNumber _challengeRaw };
    private _challengeEnabled = (_challengeRaw == 1);

    // Skill-scaled disarm time. Skill 1.0 -> baseTime, skill 0 -> 1.5x baseTime,
    // floored at 50% of baseTime. If the Engineer Challenge master toggle is
    // off, fall back to legacy instant disarm.
    private _baseTime   = _addonLogic getVariable ["IED_Engineer_Disarm_BaseTime", 60];
    if (_baseTime isEqualType "") then { _baseTime = parseNumber _baseTime };
    private _disarmTime = if (_challengeEnabled) then {
        ((_baseTime * (1.5 - 0.5 * _skill)) max (_baseTime * 0.5))
    } else {
        0
    };

    if (_disarmTime > 0) then {
        hint format ["Disarming IED… (~%1s)", round _disarmTime];

        // Interruptible wait. If the server-side accumulator detonates the IED
        // during disarm, our reference goes null and we bail.
        private _elapsed = 0;
        while {_elapsed < _disarmTime} do {
            sleep 1;
            if (isNull _IED || !alive _IED) exitWith {};
            _elapsed = _elapsed + 1;
        };
    } else {
        hint "Disarming IED…";
    };

    if (isNull _IED || !alive _IED) exitWith {
        hint "";
    };

    // New-device chance. Skill-scaled when Challenge is enabled, flat 10% legacy otherwise.
    private _newDeviceThreshold = if (_challengeEnabled) then {
        private _base = _addonLogic getVariable ["IED_Engineer_Disarm_NewDeviceBase", 0.75];
        if (_base isEqualType "") then { _base = parseNumber _base };
        ((_base + 0.15 * _skill) min 0.90) max 0.70
    } else {
        0.90
    };

    if ((random 1) > _newDeviceThreshold) then {

        // "New device" - guess red or blue wire. 50/50 coin flip.
        private _wire = if ((random 1) > 0.5) then { "blue" } else { "red" };
        tup_ied_wire = "";

        private _tup_iedPrompt = createDialog "tup_ied_DisarmPrompt";
        noesckey = (findDisplay 1600) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 1) then { true }"];

        waitUntil {sleep 0.3; tup_ied_wire != ""};

        private _selectedWire = tup_ied_wire;
        private _success      = (_selectedWire == _wire);

        // Re-check IED validity - could have been detonated while dialog was open.
        if (isNull _IED || !alive _IED) exitWith { hint ""; };

        if (_success) then {
            [_IED, _caller, _id, _IEDCharge, "You guessed correct! IED disarmed."] call _fnDisarmSuccess;
        } else {
            // Wrong wire - detonate. Use an ammo class that explodes at rest
            // (#890): the M_Mo_*_AT* mortar rounds spawn non-null but inert.
            // Confirmed-detonating classes per the 2026-05-30 in-game test.
            private _shell = [["R_60mm_HE","Bomb_03_F","Bomb_04_F"],[8,1,1]] call BIS_fnc_selectRandomWeighted;
            _shell createVehicle getposATL _IED;

            private _trgr = (position _IED) nearObjects ["EmptyDetector", 3];
            {
                deleteVehicle _x;
            } foreach _trgr;

            [[position _IED, [str(side group player)], +10] ,"ALiVE_fnc_updateSectorHostility", false, false, true] call BIS_fnc_MP;
            [[ADDON, "removeIED", _IED] ,"ALiVE_fnc_IED", false, false, true] call BIS_fnc_MP;

            deleteVehicle _IEDCharge;
            deleteVehicle _IED;
        };

    } else {

        // Standard disarm - automatic success.
        [_IED, _caller, _id, _IEDCharge, "IED disarmed."] call _fnDisarmSuccess;
    };
};
