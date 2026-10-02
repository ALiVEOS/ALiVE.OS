// Returns [minRange, maxRange] in metres: the band an artillery battery fires in. The tablet
// map draws it as the red and green rings round the battery, the fire-mission check refuses a
// target inside the minimum, and a move into range aims inside the band.
//   [_guns, _magazine, _class] call NEO_fnc_artyUnitFiringDistance - measured with the engine's
//       own range check (inRangeOfArtillery), the one a fire mission passes or fails, on the
//       first of the battery's guns (one gun or a list) with a live gunner that gets an answer,
//       firing that round. The minimum carries the 50 m the fire check has always added; the
//       maximum is the reach over level ground. Kept per gun type and round on each machine,
//       and under _class too, so a battery whose guns are packed or unmanned still finds it.
//   _class call NEO_fnc_artyUnitFiringDistance - the gun's weapon config only, as before, and
//       what the measured call falls back to when nothing can be measured or found.
// The engine's artillery flies drag-free: a gun that reaches R over level ground reaches a
// target h metres higher out to R * sqrt(1 - 2h/R). The weapon config can be far from what
// the round does: the Mk6 mortar's weapon says 1 to 500 m, while its HE shell lands from
// about 35 m out to about 4080 m.
// Author: Jman

private ["_class", "_weapons", "_min", "_max"];
_min = 0;
_max = 0;

_class = _this;

if (_this isEqualType []) then
{
    _this params [["_guns", [], [objNull, []]], ["_mag", "", [""]], ["_type", "", [""]]];
    if (_guns isEqualType objNull) then { _guns = [_guns] };
    _guns = _guns select { !isNull _x };
    if (_type == "") then { _type = typeOf (_guns param [0, objNull]) };
    _class = _type;
    if (_mag == "") exitWith {};

    if (isNil "ALiVE_CS_artyRanges") then { ALiVE_CS_artyRanges = createHashMap };
    private _keys = [_type + "|" + _mag];
    { _keys pushBackUnique ((typeOf _x) + "|" + _mag) } forEach _guns;
    {
        private _known = ALiVE_CS_artyRanges getOrDefault [_x, []];
        if (_known isNotEqualTo []) exitWith { _min = _known select 0; _max = _known select 1 };
    } forEach _keys;
    if (_max > 0) exitWith {};

    {
        private _gun = _x;
        // out along the way the gun faces, a quarter further each step, to the first point in range
        // and on to the first point past it; then close in on both edges by halving
        private _dir = getDir _gun;
        private _in = { (_gun getPos [_this, _dir]) inRangeOfArtillery [[_gun], _mag] };
        private _short = 0;
        private _first = -1;
        private _last = -1;
        private _past = -1;
        private _d = 25;
        while { _d < 100000 && {_past < 0} } do
        {
            if (_d call _in) then
            {
                if (_first < 0) then { _first = _d };
                _last = _d;
            }
            else
            {
                if (_first < 0) then { _short = _d } else { _past = _d };
            };
            _d = _d * 1.25;
        };
        // nothing in range (a round this gun doesn't carry): the next gun is tried, and nothing is kept
        if (_first >= 0) exitWith
        {
            for "_i" from 1 to 12 do
            {
                private _m = (_short + _first) / 2;
                if (_m call _in) then { _first = _m } else { _short = _m };
            };
            if (_past > 0) then
            {
                for "_i" from 1 to 12 do
                {
                    private _m = (_last + _past) / 2;
                    if (_m call _in) then { _last = _m } else { _past = _m };
                };
            };
            // the edge found lies on the ground there, h metres above or below the gun: back to level ground
            private _h = (getTerrainHeightASL (_gun getPos [_last, _dir])) - ((getPosASL _gun) select 2);
            _min = round _first + 50;
            _max = round (_h + sqrt (_h ^ 2 + _last ^ 2));
            ALiVE_CS_artyRanges set [_type + "|" + _mag, [_min, _max]];
            ALiVE_CS_artyRanges set [(typeOf _gun) + "|" + _mag, [_min, _max]];
        };
    } forEach (_guns select { alive _x && {alive gunner _x} });
};
if (_max > 0) exitWith { [_min, _max] };

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
