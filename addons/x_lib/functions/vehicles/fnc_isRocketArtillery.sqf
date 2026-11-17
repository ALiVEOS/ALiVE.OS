#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(isRocketArtillery);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isRocketArtillery

Description:
Checks if a vehicle is ROCKET artillery (MLRS-class), as opposed to gun
artillery. Rocket systems have large minimum ranges (4-5km) that make them
useless on small terrains, so placement can defer them. Classified by
ordnance where that is decisive; many launchers carry rounds that do not
classify as ROCKETS, so a name signature over classname + model path is the
fallback.

Parameters:
Object or String - vehicle (or classname)

Returns:
Boolean

Examples:
(begin example)
_isMLRS = ["RHS_BM21_MSV_01"] call ALIVE_fnc_isRocketArtillery;
(end)

See Also:
ALIVE_fnc_isArtillery

Author:
Jman
---------------------------------------------------------------------------- */

private _class = _this select 0;

switch (typeName _class) do {
    case ("OBJECT") : {_class = typeOf _class};
    case ("STRING") : {_class = _class};
};

if !([_class] call ALIVE_fnc_isArtillery) exitWith { false };

private _ordnance = _class call ALiVE_fnc_GetArtyRounds;
// a salvo launcher whose rockets come out of one dispenser shot (Spearhead's Calliope, #1129) answers ROCKETS too,
// but it is a short-range gun with no minimum range, so placement must not hold it back on small maps: its vote
// counts only when some ROCKETS magazine is a rocket of its own
private _salvoOnly = {
    private _rocketMags = (_class call ALIVE_fnc_getArtyMagazines) select { ["ROCKETS", _x] call ALIVE_fnc_isMagazineOfOrdnanceType };
    (count _rocketMags > 0) && {(_rocketMags findIf { !(["ROCKET SALVO", _x] call ALIVE_fnc_isMagazineOfOrdnanceType) }) < 0}
};
if ("ROCKETS" in _ordnance && {!("HE" in _ordnance)} && {!(call _salvoOnly)}) exitWith { true };

// the ordnance vote above only catches launchers whose rounds classify as
// ROCKETS with no HE among them; plenty do not. Recognise those by the common
// launcher families in the classname / model path
private _sig = toLower format ["%1 %2", _class, getText (configFile >> "CfgVehicles" >> _class >> "model")];
// "m142" as well as "himars" - RHS names the launcher rhsusf_M142_*, which
// carries neither the word himars nor, now its pylon pod is read correctly,
// a ROCKETS answer to vote with above
(["bm21", "bm-21", "grad", "mlrs", "m270", "himars", "m142", "smerch", "uragan", "rm70", "rm-70", "katyusha"] findIf { _x in _sig }) > -1
