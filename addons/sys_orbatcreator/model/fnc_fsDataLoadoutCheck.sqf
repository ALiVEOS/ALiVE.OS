#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataLoadoutCheck);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataLoadoutCheck

Description:
Is this a well-formed getUnitLoadout array. A loadout from a stranger's share text
must have exactly the engine's shape before it is kept, because the export writes
it into a config file and setUnitLoadout reads it on every unit.

    - an array of exactly 10;
    - slots 0, 1, 2, 8 (weapons): [] or [S, S, S, S, M, M, S], M being [] or [S, N];
    - slots 3, 4, 5 (uniform, vest, backpack): [] or [S, items], items a list of
      at most 200 entries, each [S, N], [S, N, N], [weaponArray, N] or [S, BOOL]
      (a uniform, vest or backpack stowed in the container);
    - slots 6, 7 (headgear, facewear): S;
    - slot 9 (linked items): six S;
    - every S passes the gear rule, every N is 0..9999.

Parameters:
    _loadout - ARRAY - the loadout

Returns:
    ARRAY - [ok, why]; why is "" when ok, else a short English reason naming the slot

Examples:
    (begin example)
    ([getUnitLoadout "B_Soldier_F"] call ALiVE_fnc_fsDataLoadoutCheck) params ["_ok", "_why"];
    (end)

See Also:
    ALiVE_fnc_fsDataCheckValue

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params ["_loadout"];

if (isNil "_loadout" || {!(_loadout isEqualType [])}) exitWith { [false, "not a list"] };
if ((count _loadout) != 10) exitWith { [false, format ["%1 slots, not 10", (count _loadout) toFixed 0]] };

// The gear rule of ALiVE_fnc_fsDataCheckValue as one engine regex: a loop over the characters made an
// import of a big faction slow.
private _isS = { _this isEqualType "" && {_this regexMatch "^[A-Za-z0-9_]{0,80}$"} };
private _isN = { _this isEqualType 0 && {finite _this} && {_this >= 0} && {_this <= 9999} };
private _isMag = { (_this isEqualTo []) || {_this isEqualType [] && {(count _this) == 2} && {(_this select 0) call _isS} && {(_this select 1) call _isN}} };
private _isWeapon = {
    (_this isEqualTo []) || {
        _this isEqualType [] && {(count _this) == 7}
        && {(_this select 0) call _isS} && {(_this select 1) call _isS} && {(_this select 2) call _isS} && {(_this select 3) call _isS}
        && {(_this select 4) call _isMag} && {(_this select 5) call _isMag} && {(_this select 6) call _isS}
    }
};
private _isItem = {
    _this isEqualType [] && {
        private _n = count _this;
        (_n == 2 && {(_this select 0) call _isS} && {(_this select 1) isEqualType true})
        || {_n == 2 && {(_this select 1) call _isN} && {((_this select 0) call _isS) || {((_this select 0) isEqualType []) && {!((_this select 0) isEqualTo [])} && {(_this select 0) call _isWeapon}}}}
        || {_n == 3 && {(_this select 0) call _isS} && {(_this select 1) call _isN} && {(_this select 2) call _isN}}
    }
};
private _isContainer = {
    (_this isEqualTo []) || {
        _this isEqualType [] && {(count _this) == 2} && {(_this select 0) call _isS}
        && {(_this select 1) isEqualType []} && {(count (_this select 1)) <= 200}
        && {((_this select 1) findIf { !(_x call _isItem) }) < 0}
    }
};

private _why = "";
{
    if (_why isEqualTo "" && {!((_loadout select _x) call _isWeapon)}) then { _why = format ["weapon slot %1", _x toFixed 0] };
} forEach [0, 1, 2, 8];
{
    if (_why isEqualTo "" && {!((_loadout select _x) call _isContainer)}) then { _why = format ["container slot %1", _x toFixed 0] };
} forEach [3, 4, 5];
{
    if (_why isEqualTo "" && {!((_loadout select _x) call _isS)}) then { _why = format ["slot %1", _x toFixed 0] };
} forEach [6, 7];
if (_why isEqualTo "") then {
    private _linked = _loadout select 9;
    if (!(_linked isEqualType []) || {(count _linked) != 6} || {(_linked findIf { !(_x call _isS) }) >= 0}) then { _why = "slot 9" };
};

[_why isEqualTo "", _why]
