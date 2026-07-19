#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isMagazineOfOrdnanceType

Description:
Check if magazine is of ordnance type. Matches by classname pattern first;
when the name matches no pattern, classifies by the round's CfgAmmo ancestry
(mod magazines carry real-world designations like rhs_mag_155mm_m795_28 that
match none of the patterns, which left mod guns with no usable ordnance).

Parameters:
String - Ordnance type
String - Magazine classname

Returns:
Boolean

Examples:
(begin example)
private _result = ["HE", _magazineClassName] call ALIVE_fnc_isMagazineOfOrdnanceType;
(end)

See Also:

Author:
marceldev89
Jman
---------------------------------------------------------------------------- */

// bare "he"/"HE" matched any classname containing that letter pair (chem,
// shells, launcher...) - underscore-boundary tokens only. Real HE shells the
// tokens miss are still caught by the CfgAmmo ancestry fallback below.
#define HE_SUBSTRINGS      ["Mo_shells", "_he", "he_", "_HE", "HE_"];
#define SMOKE_SUBSTRINGS   ["Mo_smoke", "smoke", "Smoke","smokeshell","SmokeShell","NB","nb"];
#define PHOS_SUBSTRINGS    ["wp", "WP"];
#define GUIDED_SUBSTRINGS  ["Mo_guided"];
#define CLUSTER_SUBSTRINGS ["Mo_Cluster"];
#define LASER_SUBSTRINGS   ["Mo_LG", "laser"];
#define MINE_SUBSTRINGS    ["Mo_Mine"];
#define AT_MINE_SUBSTRINGS ["Mo_AT_mine"];
#define ROCKET_SUBSTRINGS  ["rockets"];
#define ILLUM_SUBSTRINGS   ["illum", "ilum", "flare", "lume"];
// gas rounds (SOG chem, KAT Type0/TypeCS) must never classify at all - firing
// gas on a smoke or HE call is the one misfire worse than a wrong colour. Today
// they are shotDeploy rounds and fall through every branch structurally; the name
// guard is the second lock in case a mod ships one shaped as a real shell or
// dispenser. Type tokens are underscore-anchored to the KAT naming so they cannot
// collide with unrelated classnames. "gas" is not a requestable type - negative guard only.
#define GAS_SUBSTRINGS     ["chem", "Chem", "CHEM", "_TypeCS", "_Type0"];
// VN 105mm naming: wp classifies by the "wp" pattern above; ab / frag / chem
// carry no pattern and classify by the CfgAmmo fallback (ab -> CLUSTER + HE,
// frag -> HE, chem -> intentionally nothing - it is a gas round).

private _ordnanceType      = param [0];
private _magazineClassName = param [1];

private _substrings = switch (_ordnanceType) do {
    case "HE":      { HE_SUBSTRINGS };
    case "SMOKE":   { SMOKE_SUBSTRINGS };
    case "WP":      { PHOS_SUBSTRINGS };
    case "SADARM":  { GUIDED_SUBSTRINGS };
    case "CLUSTER": { CLUSTER_SUBSTRINGS };
    case "LASER":   { LASER_SUBSTRINGS };
    case "MINE":    { MINE_SUBSTRINGS };
    case "AT MINE": { AT_MINE_SUBSTRINGS };
    case "ROCKETS": { ROCKET_SUBSTRINGS };
    case "ILLUM":   { ILLUM_SUBSTRINGS };
    default         { [] };
};

private _found = false;

{
    if (_x in _magazineClassName) exitWith {
        _found = true;
    };
} foreach _substrings;

if (_found) exitWith { true };

// #887 - config-ancestry fallback. Each branch carries a guard so vanilla
// magazines (whose names the patterns already classify) keep their exact
// previous answers - e.g. a WP round is smoke-parented in config but must
// not start answering true for SMOKE.
private _ammo = getText (configfile >> "CfgMagazines" >> _magazineClassName >> "ammo");
if (_ammo == "") exitWith { false };

private _ammoCfg = configfile >> "CfgAmmo" >> _ammo;
private _cfgAmmoRoot = configfile >> "CfgAmmo";

private _fnc_isDispenser = {
    (toLower getText (_ammoCfg >> "simulation")) == "shotsubmunitions"
};
private _fnc_submunitions = {
    private _subs = [];
    private _subEntry = _ammoCfg >> "submunitionAmmo";
    if (isText _subEntry) then { _subs pushBack (getText _subEntry) };
    if (isArray _subEntry) then {
        { if (_x isEqualType "") then { _subs pushBack _x }; } forEach (getArray _subEntry);
    };
    _subs
};
// takes the pattern array as _this (the pattern defines carry a trailing
// semicolon, so they can only expand inside a block body)
private _fnc_nameMatchesAny = {
    (_this findIf { _x in _magazineClassName }) > -1
};

// plain-shell test shared by HE and the CLUSTER carrier arm - shell
// simulation is the mod-proof fallback when the ammo has its own class tree
private _fnc_isShell = {
    (_ammo isKindOf ["ShellBase", _cfgAmmoRoot]) || {(toLower getText (_ammoCfg >> "simulation")) == "shotshell"}
};

// concealment-smoke submunition: harmless (no hit, no splash) and either
// SmokeShell-parented or smoke-named. GM's smoke canister
// (gm_shotdeploy_smokeshell_wht) has no parent class at all, so parentage alone
// misses it - the name is the only signal it carries. The name arm requires the
// class to actually exist: getNumber on a missing config path returns 0, so a
// dangling submunition reference from an unloaded compat pbo would otherwise read
// as harmless smoke off nothing.
private _fnc_hasHarmlessSmokeSub = {
    ((call _fnc_submunitions) findIf {
        ((_x isKindOf ["SmokeShell", _cfgAmmoRoot]) || {isClass (_cfgAmmoRoot >> _x) && {"smoke" in toLower _x}})
            && {getNumber (_cfgAmmoRoot >> _x >> "hit") == 0}
            && {getNumber (_cfgAmmoRoot >> _x >> "indirectHit") == 0}
    }) > -1
};
// illumination submunition: FlareCore-parented or flare/illum-named (same name
// fallback the smoke helper has, for candles with no parent class). No
// harmlessness gate - flares carry burn damage by design (RHS: hit=5).
private _fnc_hasFlareSub = {
    ((call _fnc_submunitions) findIf {
        (_x isKindOf ["FlareCore", _cfgAmmoRoot])
            || {isClass (_cfgAmmoRoot >> _x) && {
                private _subName = toLower _x;
                ("flare" in _subName) || {"illum" in _subName} || {"ilum" in _subName}
            }}
    }) > -1
};

switch (_ordnanceType) do {
    case "ILLUM": {
        // the flare is a submunition on most mod illum rounds (RHS 152mm/155mm
        // eject a FlareCore candle from a plain carrier), so testing the carrier
        // alone left those guns unable to fire illumination at all
        (
            (_ammo isKindOf ["FlareCore", _cfgAmmoRoot])
            || {((call _fnc_isDispenser) || {call _fnc_isShell}) && {call _fnc_hasFlareSub}}
        ) && {!((call { GAS_SUBSTRINGS }) call _fnc_nameMatchesAny)}
    };
    case "SMOKE": {
        // WP rounds are smoke-parented in config - keep them out of SMOKE
        (
            (_ammo isKindOf ["SmokeShell", _cfgAmmoRoot])
            // a round that deploys HARMLESS smoke submunitions is a smoke round.
            // Two shapes. A dispenser splits in the air and never detonates on the
            // ground - its hit values are the ejection charge (RHS 152mm smoke
            // carries indirectHit=2 there), so the submunition is the truth and
            // the carrier numbers say nothing. A real shell (Spearhead's M84 is
            // ShellBase-parented) does land, so it must do no damage at all: a
            // shell that explodes is HE, whose branch owns indirectHit>0, and
            // requiring ==0 here keeps the two disjoint. The submunition itself
            // must be harmless either way - a gas/chem cloud or a WP wedge is
            // SmokeShell-derived too, but it poisons or burns, so a submunition
            // that deals damage is not concealment.
            || {(call _fnc_isDispenser) && {call _fnc_hasHarmlessSmokeSub}}
            || {
                (call _fnc_isShell)
                    && {getNumber (_ammoCfg >> "indirectHit") == 0}
                    && {call _fnc_hasHarmlessSmokeSub}
            }
        ) && {!((call { PHOS_SUBSTRINGS }) call _fnc_nameMatchesAny)}
          && {!((call { GAS_SUBSTRINGS }) call _fnc_nameMatchesAny)}
    };
    case "LASER": {
        getNumber (_ammoCfg >> "laserLock") > 0
    };
    case "SADARM": {
        (call _fnc_isDispenser) && {
            ((call _fnc_submunitions) findIf {
                getNumber (_cfgAmmoRoot >> _x >> "laserLock") > 0 || {getNumber (_cfgAmmoRoot >> _x >> "irLock") > 0}
            }) > -1
        }
    };
    case "MINE": {
        // AT mine rounds stay AT MINE only (name layer), never plain MINE
        (call _fnc_isDispenser) && {!((call { AT_MINE_SUBSTRINGS }) call _fnc_nameMatchesAny)} && {
            ((call _fnc_submunitions) findIf {
                _x isKindOf ["MineBase", _cfgAmmoRoot] || {_x isKindOf ["TimeBombCore", _cfgAmmoRoot]}
            }) > -1
        }
    };
    case "CLUSTER": {
        // a dispenser round, or a real shell that deploys submunitions on the
        // way down (SOG 105mm airburst simulates as shotShell). Array-form
        // submunitionAmmo is the discriminator on the shell arm: bare-string
        // form is a single follow-through penetrator (tandem HEAT), never a
        // cluster - the isArray gate is what rejects those and is NOT redundant
        // with the count check below (which rejects empty arrays, e.g. the SOG
        // frag round). laserLock sits on the CARRIER of a laser-guided round
        // (the vanilla 155mm LG drops an unguided dart), so the guided test must
        // read the carrier on BOTH arms, not just the shell arm - this hoist is
        // the operative laser exclusion; the name tokens below are case-sensitive
        // best-effort backup only and do NOT cover uppercase mod names like
        // rhs_mag_LASER_2a33. Smoke / flare / mine submunitions and smoke / WP /
        // laser / illum / mine-named rounds are held out so picking CLUSTER can
        // never fire the wrong round - each of those is its own type and a
        // cluster call wants immediate area effect.
        (getNumber (_ammoCfg >> "laserLock") == 0) && {
            (call _fnc_isDispenser) || {
                (call _fnc_isShell)
                    && {!(_ammo isKindOf ["SmokeShell", _cfgAmmoRoot])}
                    && {!(_ammo isKindOf ["FlareCore", _cfgAmmoRoot])}
                    && {isArray (_ammoCfg >> "submunitionAmmo")}
            }
        } && {
            private _subs = call _fnc_submunitions;
            // GM's mine dart has no parent class, so the name is read too
            private _isMine = (_subs findIf {
                _x isKindOf ["MineBase", _cfgAmmoRoot]
                    || {_x isKindOf ["TimeBombCore", _cfgAmmoRoot]}
                    || {"mine" in toLower _x}
            }) > -1;
            private _isGuided = (_subs findIf { getNumber (_cfgAmmoRoot >> _x >> "laserLock") > 0 || {getNumber (_cfgAmmoRoot >> _x >> "irLock") > 0} }) > -1;
            private _isSmokeOrFlare = ((_subs findIf {
                _x isKindOf ["SmokeShell", _cfgAmmoRoot] || {_x isKindOf ["FlareCore", _cfgAmmoRoot]}
            }) > -1) || {call _fnc_hasHarmlessSmokeSub} || {call _fnc_hasFlareSub};
            (count _subs > 0) && {!_isMine} && {!_isGuided} && {!_isSmokeOrFlare}
                && {!((call { PHOS_SUBSTRINGS }) call _fnc_nameMatchesAny)}
                && {!((call { SMOKE_SUBSTRINGS }) call _fnc_nameMatchesAny)}
                && {!((call { LASER_SUBSTRINGS }) call _fnc_nameMatchesAny)}
                && {!((call { ILLUM_SUBSTRINGS }) call _fnc_nameMatchesAny)}
                && {!((call { AT_MINE_SUBSTRINGS }) call _fnc_nameMatchesAny)}
                && {!((call { MINE_SUBSTRINGS }) call _fnc_nameMatchesAny)}
                && {!((call { GAS_SUBSTRINGS }) call _fnc_nameMatchesAny)}
        }
    };
    case "ROCKETS": {
        // parentage first, then simulation type - mod rocket ammo (e.g. RHS
        // Grad) often has its own class tree but always simulates as a rocket
        (_ammo isKindOf ["RocketBase", _cfgAmmoRoot])
            || {(toLower getText (_ammoCfg >> "simulation")) in ["shotrocket","shotmissile"]}
    };
    case "HE": {
        // plain shell only - anything smoke / flare / guided / dispenser /
        // rocket parented belongs to its own type. Shell simulation is the
        // mod-proof fallback when the ammo has its own class tree.
        (call _fnc_isShell)
            && {!(_ammo isKindOf ["SmokeShell", _cfgAmmoRoot])}
            && {!(_ammo isKindOf ["FlareCore", _cfgAmmoRoot])}
            && {getNumber (_ammoCfg >> "laserLock") == 0}
            && {!(call _fnc_isDispenser)}
            // an HE round explodes. Spearhead parents its smoke shell on
            // ShellBase and gives it no splash at all, so parentage alone reads
            // it as HE and an HE fire mission puts smoke on the target. Every
            // real HE shell carries indirect damage - vanilla's 155 has 125,
            // Spearhead's own HE has 250, its smoke has none - so ask whether
            // the thing actually goes off rather than what it inherits from.
            // Vanilla never reaches here: its names match at the pattern test
            // above and exit before any of this runs.
            && {getNumber (_ammoCfg >> "indirectHit") > 0}
            // a WP or smoke round modelled as a damaging ShellBase passes
            // everything above - CUP/RHS WP carry indirectHit=50, 3CB's smoke
            // shells 3 - and an HE fire mission would put burning phosphorus or
            // a smoke screen on the target. Parentage cannot tell them apart
            // (they are NOT SmokeShell-parented, which is the whole problem), but
            // every one carries its nature in the magazine name, so the same
            // patterns that classify them INTO their own type also hold them OUT of HE.
            && {!((call { SMOKE_SUBSTRINGS }) call _fnc_nameMatchesAny)}
            && {!((call { PHOS_SUBSTRINGS }) call _fnc_nameMatchesAny)}
            && {!((call { ILLUM_SUBSTRINGS }) call _fnc_nameMatchesAny)}
            && {!((call { GAS_SUBSTRINGS }) call _fnc_nameMatchesAny)}
            // and for the shape the name misses: a shell whose payload is a
            // harmless smoke canister or a flare is concealment/illumination,
            // not high explosive
            && {!(call _fnc_hasHarmlessSmokeSub)}
            && {!(call _fnc_hasFlareSub)}
    };
    default { false };
};
