/* ----------------------------------------------------------------------------
Script: init.sqf (ALiVE_FactionStudio.VR)

Description:
Init of the studio scene mission. The player is a hidden, frozen civilian on
the VR map; the studio stands its stage in front of him and runs in scene mode,
where Esc is swallowed and the Exit button ends the mission.

Parameters:
    None

Returns:
    Nothing

Examples:
    (begin example)
    playMission ["", "\x\alive\addons\sys_orbatcreator\scene\ALiVE_FactionStudio.VR"];
    (end)

See Also:
    ALiVE_fnc_fsStudioStart, ALiVE_fnc_fsStudioClose

Author:
    Jman
---------------------------------------------------------------------------- */

enableSaving [false, false];
player allowDamage false;
player enableSimulation false;
hideObject player;
enableRadio false;
0 fadeSound 0;
["scene", objNull] spawn ALiVE_fnc_fsStudioStart;
