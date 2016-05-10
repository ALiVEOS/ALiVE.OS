private["_veh","_keepWeapon","_wepCount","_ammoCount","_count"];
_veh = _this select 0;
_keepWeapon = _this select 1;
_ammoCount = [];
{
    private "_count";
    if (_x == _weapon) then {
        _count = -1;
    } else {
        _count = _veh ammo _x;
        _veh setAmmo [_x, 0];
    };
    _ammoCount set [count _ammoCount, _count];
} foreach weapons _veh;

_ammoCount;