private["_veh","_ammoCount"];
_veh = _this select 0;
_ammoCount = _this select 1;

{
    if( (_ammoCount select _foreachindex) != -1 ) then {
        _veh setAmmo [_x, _ammoCount select _foreachindex];
    };
} foreach weapons _veh;