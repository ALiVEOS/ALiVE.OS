#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileKillBoxes);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileKillBoxes

Description:
Kill boxes (#541). A map marker whose text starts with KILLBOX keeps the AI around it
spawned for as long as the marker is there, as if a player stood on it, so aircraft
can hit them from far off. A number after the word sets the radius in metres
("KILLBOX 2000", or "KILLBOX 2km"); without one it is the normal spawn distance. A
box only works while some player is within 10 km of it. Deleting the marker ends it,
and the AI there go back into the profile system once no player is near.

Runs on the server, started by the profile system when Kill Box Markers is on. Each
kill box is a game logic in ALiVE_SpawnSources carrying its radius as
ALiVE_spawnSourceRadius, which the activator reads.

Parameters:
None

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};

// Biggest radius a marker may ask for: the box spawns everything inside it.
#define KILLBOX_MAX_RADIUS 5000
// A box works only while some player is this close to it.
#define KILLBOX_PLAYER_RANGE 10000

// The profile system makes the source list as it starts; wait for it.
waitUntil { sleep 1; !isNil "ALiVE_SpawnSources" };

private _boxes = createHashMap; // marker name -> logic
private _group = grpNull;

while {true} do {
    private _wanted = createHashMap;
    {
        private _text = toLower (markerText _x);
        private _rest = switch (true) do {
            case (_text find "killbox" == 0): { _text select [7] };
            case (_text find "kill box" == 0): { _text select [8] };
            default { nil };
        };
        if (!isNil "_rest") then {
            // The first number in the text. "2km", or anything under 100, is kilometres, so a
            // typo can't make a box a few metres across.
            private _found = _rest regexFind ["[0-9]+(\.[0-9]+)?"];
            private _radius = if (_found isEqualTo []) then { 0 } else { parseNumber ((_found select 0 select 0) select 0) };
            if (_radius > 0 && {_radius < 100 || {_rest find "km" >= 0}}) then { _radius = _radius * 1000 };
            if (_radius <= 0) then { _radius = ALIVE_spawnRadius };
            private _pos = markerPos _x;
            // Only while a player is within reach of it, so a box left by someone who has gone
            // doesn't hold the AI there for the rest of the mission.
            if ((allPlayers findIf { (_x distance2D _pos) < KILLBOX_PLAYER_RANGE }) >= 0) then {
                _wanted set [_x, [_pos, _radius min KILLBOX_MAX_RADIUS]];
            };
        };
    } forEach allMapMarkers;

    // Gone or renamed: stop spawning for it.
    {
        if !(_x in _wanted) then {
            ALiVE_SpawnSources = ALiVE_SpawnSources - [_y];
            ["ALiVE kill box at %1 ended (marker %2 gone, or no player within 10 km)", mapGridPosition _y, _x] call ALiVE_fnc_dump;
            deleteVehicle _y;
            _boxes deleteAt _x;
        };
    } forEach +_boxes;

    // New ones, and moved or resized ones.
    {
        _y params ["_pos", "_radius"];
        private _logic = _boxes getOrDefault [_x, objNull];
        if (isNull _logic) then {
            if (isNull _group) then { _group = createGroup [sideLogic, true] };
            _logic = _group createUnit ["Logic", _pos, [], 0, "CAN_COLLIDE"];
            _boxes set [_x, _logic];
            ["ALiVE kill box at %1, radius %2 m (marker %3)", mapGridPosition _pos, _radius, _x] call ALiVE_fnc_dump;
        };
        if ((_logic distance2D _pos) > 1) then { _logic setPos _pos };
        _logic setVariable ["ALiVE_spawnSourceRadius", _radius];
        ALiVE_SpawnSources pushBackUnique _logic;
    } forEach _wanted;

    sleep 5;
};
