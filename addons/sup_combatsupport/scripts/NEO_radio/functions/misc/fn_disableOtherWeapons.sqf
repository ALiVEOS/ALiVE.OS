// DEPRECATED for the CAS ATTACK path: the cas.fsm Attack link now calls
// NEO_fnc_casPrepareWeapons instead, which keeps every usable ground-attack
// weapon loaded so the delivery can switch on depletion rather than force one
// weapon and RTB when it empties. Kept for any other caller of the same
// zero-all-but-one contract; NEO_fnc_reenableWeapons still restores it.
// Author: Jman
private["_veh","_keepWeapon","_wepCount","_ammoCount","_count"];
_veh = _this select 0;
_keepWeapon = _this select 1;
_ammoCount = [];
{
    private "_count";
    if (_x == _keepWeapon) then {
        _count = -1;
    } else {
        _count = _veh ammo _x;
        _veh setAmmo [_x, 0];
    };
    _ammoCount pushback _count;
} foreach weapons _veh;

_ammoCount;
