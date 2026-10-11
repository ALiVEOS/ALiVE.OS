#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(claimGround);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_claimGround

Description:
Claim the ground a placed vehicle stands on while the placement modules are still
placing. A placed vehicle is a virtual profile until a player comes near, so there is
nothing there yet for the next placement's object checks to find, and two placements
picked for one spot met as they spawned: a parked tank thrown on its back beside an
AA launcher. ALiVE_fnc_findVehicleSpawnPosition and ALiVE_fnc_findCompositionSpawnPosition
keep clear of the claims.

Claims are only for that startup phase. The first one starts a watch that clears them
all once every placement module has finished (or after ten minutes); from then on the
vehicles are placed and anything that spawns is found by the ordinary object checks.
Runs on the server; a call once the phase is over does nothing.

Parameters:
Array - position
String - vehicle class, for its size

Returns:
Nothing

Examples:
(begin example)
[_position, _vehicleClass] call ALiVE_fnc_claimGround;
(end)

See Also:
ALiVE_fnc_findVehicleSpawnPosition, ALiVE_fnc_findCompositionSpawnPosition

Author:
Jman
---------------------------------------------------------------------------- */

params [["_position", [], [[]]], ["_class", "", [""]]];

if (!isServer || {!isNil "ALiVE_groundClaimsDone"} || {count _position < 2} || {_class == ""}) exitWith {};

if (isNil "ALiVE_groundClaims") then {
    ALiVE_groundClaims = [];
    [] spawn {
        private _t0 = diag_tickTime;
        sleep 5;
        waitUntil {
            sleep 2;
            private _placers = (entities "Module_F") select { private _t = toLower (typeOf _x); (_t find "alive_") == 0 && {(_t find "placement") >= 0} };
            ((_placers findIf { !(_x getVariable ["startupComplete", false]) }) < 0) || {diag_tickTime - _t0 > 600}
        };
        ALiVE_groundClaimsDone = true;
        ALiVE_groundClaims = nil;
    };
};

private _box = [_class] call ALiVE_fnc_getVehicleBoundingBox;
ALiVE_groundClaims pushBack [_position, ((_box select 0) max (_box select 1)) / 2];
