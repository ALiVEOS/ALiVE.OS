#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(advciv_civAimRelease);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_civAimRelease
Description:
    Server-side release of an aim-pressure-triggered HandsUp civilian.
    Clears the ORDERED state, the HANDSUP order, the surrender
    animation, and the aim-pressure tracking flags, returning the
    civilian to the CALM state so the AdvCiv brain loop resumes
    normal behaviour.

    The companion watcher (started by civAimReact for Neutral / Wary
    bucket triggers) calls this once the triggering player has been
    further than aim-range + hysteresis (3 m) for 2 s. The
    `ALiVE_advciv_traumatised` flag set on Wary triggers persists -
    that's a campaign-level marker, not a session marker.

Parameters:
    _this select 0: OBJECT - civilian to release
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_civAimReact
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_civ", objNull, [objNull]]];

if (!isServer) exitWith {};
if (isNull _civ || {!alive _civ}) exitWith {};
if (!(_civ getVariable ["ALiVE_advciv_aimTriggeredHandsUp", false])) exitWith {};

_civ setVariable ["ALiVE_advciv_state", "CALM", true];
_civ setVariable ["ALiVE_advciv_order", "NONE", true];
_civ setVariable ["ALiVE_advciv_aimTriggeredHandsUp", nil, true];
_civ setVariable ["ALiVE_advciv_aimTriggeredBy", nil, true];
_civ setVariable ["ALiVE_advciv_aimFarSince", nil, true];

[_civ, "MOVE"] remoteExec ["enableAI", _civ];
_civ setUnitPos "AUTO";
[_civ, ""] remoteExec ["switchMove", 0];
