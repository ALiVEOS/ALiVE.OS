#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(gatherIntelDeceptive);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_gatherIntelDeceptive

Description:
Places 2 to 4 decoy installation markers at random positions 800 to 2800 m
from the given origin, styled identically to the real-intel reveal from
ALiVE_fnc_OPCOMToggleInstallations (ColorRed ELLIPSE + mil_dot icon,
alpha 0.5 fading over roughly 40 s). A player cannot distinguish a
deceptive reveal from a truthful one at the time of placement; the
ruse is only obvious on arrival at the marked location, where no
enemy installation actually exists.

Dispatched from the "GatherIntel" case in ALiVE_fnc_civInteract when
the hostility-driven deception roll passes. The truthful path in the
same case calls ALiVE_fnc_OPCOMToggleInstallations directly; the hint
text is identical between the two paths by design.

Parameters:
    _origin : ARRAY - world position (ATL) of the deceiving civilian.
        Decoys are scattered around this point.

Returns:
    Nothing.

Examples:
(begin example)
[getPosATL _civ] call ALiVE_fnc_gatherIntelDeceptive;
(end)

See Also:
    ALiVE_fnc_OPCOMToggleInstallations - the truthful reveal path.
    ALiVE_fnc_civInteract case "GatherIntel" - dispatch caller.

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_origin", [0,0,0], [[]]]];

if (!(_origin isEqualType []) || {count _origin < 2}) exitWith {};

private _count = 2 + floor random 3;
private _createdMarkers = [];

for "_i" from 0 to (_count - 1) do {
    // Decoy radius 800-2800 m, covering roughly the same order of
    // magnitude as the real reveal's 2000 m so decoys feel plausible
    // next to real markers on the map edge. Direction is random via
    // CBA_fnc_randPos.
    private _decoyPos = [_origin, 800 + random 2000] call CBA_fnc_randPos;
    private _baseId = format ["alive_decoy_intel_%1_%2", diag_tickTime, _i];

    private _mEllipse = [_baseId, _decoyPos, "ELLIPSE", [150, 150], "ColorRed", "IED", "n_installation", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
    private _mIcon    = [_baseId + "I", _decoyPos, "ICON", [0.1, 0.1], "ColorRed", "installation", "mil_dot", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;

    _createdMarkers append [_mEllipse, _mIcon];
};

// Fade-and-delete matching the cadence used by
// ALiVE_fnc_OPCOMToggleInstallations so deceptive and truthful reveals
// share timing: alpha decrements by 0.01 every second from the initial
// 0.5, reaching the 0.1 deletion threshold at roughly 40 seconds.
if (count _createdMarkers > 0) then {
    _createdMarkers spawn {
        waitUntil {
            sleep 1;
            {_x setMarkerAlpha ((markerAlpha _x) - 0.01)} forEach _this;
            markerAlpha (_this select 0) < 0.1
        };
        {deleteMarker _x} forEach _this;
    };
};
