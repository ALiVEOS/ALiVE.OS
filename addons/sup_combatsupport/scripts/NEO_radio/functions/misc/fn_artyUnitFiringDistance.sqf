// Returns [minRange, maxRange] in metres for an artillery battery's own gun, used to
// draw the red/green firing-range envelope around the battery on the tablet map.
// Previously hardcoded to the 82mm mortar regardless of the actual piece; now reads
// the real turret weapon and only falls back to the mortar when the gun exposes no range.
// Author: Jman

private ["_class", "_weapons", "_min", "_max"];
_min = 0;
_max = 0;

_class = _this;

// artillery pieces carry minRange/maxRange on the turret weapon; pick the longest-ranged
// weapon on the main turret (skips coax MGs etc. which have no/low maxRange)
_weapons = getArray (configFile >> "CfgVehicles" >> _class >> "Turrets" >> "MainTurret" >> "weapons");
{
    private _w = configFile >> "CfgWeapons" >> _x;
    private _wMax = getNumber (_w >> "maxRange");
    if (_wMax > _max) then
    {
        _max = _wMax;
        _min = getNumber (_w >> "minRange");
    };
} forEach _weapons;

// fall back to the 82mm mortar as a proxy if the gun exposes no range (some mods keep
// range on the magazine, not the weapon) so the envelope still shows something sensible
if (_max <= 0) then
{
    _min = getNumber (configFile >> "CfgWeapons" >> "mortar_82mm" >> "minRange");
    _max = getNumber (configFile >> "CfgWeapons" >> "mortar_82mm" >> "maxRange");
};

[_min, _max]
