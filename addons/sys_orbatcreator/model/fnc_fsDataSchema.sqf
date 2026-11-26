#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataSchema);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataSchema

Description:
The schema table of the studio faction model. Every reader and writer of the
plain form walks this table, never the shape of the data, so a loadout slot that
looks like a pair is never read as one.

Built once per mission into missionNamespace ALiVE_FS_schemaCache. Callers must
not change the table or its default values; copy a default array with + before
using it.

Each spec is a list of rows, in plain-form order:
    [key, type, default, rule, limit, orderKey, idLetter]
    type     - "S" string, "N" number, "B" bool, "LS" list of strings,
               "A" raw array with its own checker, "M:x" map of spec x,
               "D:x" dictionary id to map of spec x, "L:x" list of maps of spec x
    rule     - a rule name of ALiVE_fnc_fsDataCheckValue, or [min, max] for numbers
               (a rule ending in ? also accepts "")
    limit    - most entries of an LS, D: or L: value (0 = no limit)
    orderKey - D: only, the in-memory key holding the id order
    idLetter - D: only, the letter every id of that dictionary starts with

Parameters:
    None

Returns:
    HASHMAP - spec name to rows

Examples:
    (begin example)
    private _rows = (call ALiVE_fnc_fsDataSchema) get "unit";
    (end)

See Also:
    ALiVE_fnc_fsDataFromPlain, ALiVE_fnc_fsDataToPlain, ALiVE_fnc_fsDataCheckValue

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

private _cached = missionNamespace getVariable "ALiVE_FS_schemaCache";
if (!isNil "_cached") exitWith { _cached };

private _emptyLoadout = [[], [], [], [], [], [], "", "", [], ["", "", "", "", "", ""]];

private _schema = createHashMapFromArray [
    ["faction", [
        ["schema", "N", FS_SCHEMA, [0, 999999]],
        ["id", "S", "", "id?"],
        ["name", "S", "", "text60"],
        ["tag", "S", "", "tag?"],
        ["class", "S", "", "class?"],
        ["side", "N", 1, [0, 3]],
        ["flag", "S", "", "path"],
        ["icon", "S", "", "path"],
        ["priority", "N", 1, [0, 100]],
        ["author", "S", "", "text60"],
        ["modName", "S", "", "modName?"],
        ["options", "M:options", [], ""],
        ["categories", "D:category", [], "", FS_MAX_CATEGORIES, "categoryOrder", "c"],
        ["units", "D:unit", [], "", FS_MAX_UNITS, "unitOrder", "u"],
        ["vehicles", "D:vehicle", [], "", FS_MAX_VEHICLES, "vehicleOrder", "v"],
        ["groups", "D:group", [], "", FS_MAX_GROUPS, "groupOrder", "g"],
        ["pools", "D:pool", [], "", FS_MAX_POOLS, "poolOrder", "p"],
        // how the faction is declared to ALiVE (CfgALiVEFactions, supply crates)
        ["alive", "M:alive", [], ""],
        ["meta", "M:meta", [], ""]
    ]],
    ["options", [
        ["noRandom", "B", true, ""],
        ["force", "B", false, ""],
        ["copyParent", "B", false, ""]
    ]],
    // auto: the lists still worked out by the studio; a hand edit takes a name out.
    // List refs are a vehicle id ("v3") or an outside class ("#Class").
    ["alive", [
        ["hook", "B", true, ""],
        ["rarity", "B", true, ""],
        ["auto", "LS", FS_ALIVE_LISTS, "gear", 8],
        ["crates", "L:crate", [], "", FS_MAX_CRATES],
        ["suppliesExtra", "LS", [], "gear", 32],
        ["transport", "LS", [], "ref", 32],
        ["airTransport", "LS", [], "ref", 16],
        ["supports", "LS", [], "ref", 32],
        ["aa", "LS", [], "ref", 8],
        ["containers", "LS", [], "gear", 16],
        ["redirects", "L:redirect", [], "", 11]
    ]],
    // a supply crate: key ammo, weapons, launchers, support, uniforms or a made-up one
    ["crate", [
        ["key", "S", "", "gear"],
        ["name", "S", "", "text60"],
        ["class", "S", "", "class?"],
        ["classAuto", "B", true, ""],
        ["base", "S", "", "class"],
        ["cargo", "L:cargo", [], "", FS_MAX_CRATE_ROWS]
    ]],
    // an empty ALiVE category drawn from another category of the faction
    ["redirect", [
        ["from", "S", "", "aliveCat"],
        ["to", "S", "", "class"]
    ]],
    ["meta", [
        ["counter", "N", 0, [0, 999999]],
        ["created", "A", [], "date"],
        ["modified", "A", [], "date"],
        ["aliveVersion", "S", "", "text60"],
        ["source", "S", "", "text60"],
        ["legacyPatches", "LS", [], "class", 8]
    ]],
    ["category", [
        ["id", "S", "", "id"],
        ["name", "S", "", "text60"]
    ]],
    ["unit", [
        ["id", "S", "", "id"],
        ["name", "S", "", "text60"],
        ["class", "S", "", "class"],
        ["classAuto", "B", true, ""],
        ["base", "S", "", "class"],
        ["src", "S", "", "gear"],
        ["category", "S", "", "id?"],
        ["loadout", "A", _emptyLoadout, "loadout"],
        ["identity", "M:identity", [], ""],
        // the shared gear pools he wears, one per slot (ALiVE_fnc_fsDataPool)
        ["pools", "LS", [], "id", 8],
        // his part in AUTO GROUPS: "" = worked out (ALiVE_fnc_fsAutoRole)
        ["role", "S", "", "role?"],
        ["specOps", "B", false, ""],
        // engineer and canDeactivateMines written into his class: -1 = as his base class, 0 or 1 = set on the Units tab
        ["engineer", "N", -1, [-1, 1]],
        ["eod", "N", -1, [-1, 1]],
        // attendant and uavHacker, the same way
        ["medic", "N", -1, [-1, 1]],
        ["uavHacker", "N", -1, [-1, 1]],
        // ACE medical (1 medic, 2 doctor) and engineer (2 advanced) training: ALiVE_FS_aceMedic and ALiVE_FS_aceEngineer
        // in his class, set on him by the faction runtime when ACE reads them; -1 = as his base class
        ["aceMedic", "N", -1, [-1, 2]],
        ["aceEngineer", "N", -1, [-1, 2]],
        // the faction author's Init Code, run for this class only (ALiVE_fnc_fsGenConfig); never taken from pasted text
        ["initCode", "S", "", "code"],
        // written in its own optional part, which loads only when the mods it needs are loaded
        ["optional", "B", false, ""]
    ]],
    ["identity", [
        ["types", "LS", [], "gear", 32],
        ["face", "S", "", "gear"],
        ["speaker", "S", "", "gear"],
        ["insignia", "S", "", "gear"],
        ["pitch", "N", 0, [0, 10]],
        ["fixed", "B", false, ""]
    ]],
    ["vehicle", [
        ["id", "S", "", "id"],
        ["name", "S", "", "text60"],
        ["class", "S", "", "class"],
        ["classAuto", "B", true, ""],
        ["base", "S", "", "class"],
        ["src", "S", "", "gear"],
        ["category", "S", "", "id?"],
        ["crewUnit", "S", "", "id?"],
        ["crewClass", "S", "", "gear"],
        ["turrets", "L:turret", [], "", 16],
        ["texture", "S", "", "gear"],
        ["textures", "LS", [], "path", 16],
        // markings taken off: hiddenSelections names of the base (a roundel, an emblem, a number)
        ["markingsOff", "LS", [], "gear", 32],
        ["components", "L:component", [], "", 32],
        // 0 as the base vehicle, 1 empty, 2 the cargo list
        ["pylons", "LS", [], "gear", 64],
        ["cargoMode", "N", 0, [0, 2]],
        ["cargo", "L:cargo", [], "", 64],
        ["initCode", "S", "", "code"],
        ["optional", "B", false, ""]
    ]],
    // kind: 0 weapon, 1 magazine, 2 item, 3 backpack (the four Transport classes)
    ["cargo", [
        ["class", "S", "", "gear"],
        ["kind", "N", 2, [0, 3]],
        ["count", "N", 1, [1, 999]]
    ]],
    ["component", [
        ["source", "S", "", "class"],
        ["value", "N", 0, [0, 1]]
    ]],
    ["turret", [
        ["path", "A", [], "turretPath"],
        ["cfg", "S", "", "cfgPath"],
        ["name", "S", "", "text60"],
        ["gunnerUnit", "S", "", "id?"],
        ["gunnerClass", "S", "", "gear"]
    ]],
    // a shared gear pool: slot 0 primary, 1 handgun, 2 launcher, 3 uniform, 4 vest, 5 backpack, 6 headgear, 7 facewear
    ["pool", [
        ["id", "S", "", "id"],
        ["name", "S", "", "text60"],
        ["slot", "N", 0, [0, 7]],
        ["entries", "L:poolEntry", [], "", 32]
    ]],
    // an item and its weight; a weapon carries its whole loadout entry (attachments, loaded magazines)
    ["poolEntry", [
        ["class", "S", "", "gear"],
        ["weight", "N", 1, [1, 100]],
        ["weapon", "A", [], "poolWeapon"]
    ]],
    ["group", [
        ["id", "S", "", "id"],
        ["name", "S", "", "text60"],
        ["class", "S", "", "class"],
        ["classAuto", "B", true, ""],
        ["src", "S", "", "cfgPath"],
        ["category", "S", "Infantry", "class"],
        ["icon", "S", "", "path"],
        ["rarity", "N", 0.5, [0, 1]],
        ["members", "L:member", [], "", FS_MAX_MEMBERS],
        // the AUTO GROUPS recipe that made it ("inf_squad", "mot_v3"); "" = made by hand
        ["auto", "S", "", "gear"]
    ]],
    ["member", [
        ["ref", "S", "", "ref"],
        ["rank", "S", "PRIVATE", "rank"],
        ["pos", "A", [], "pos"]
    ]]
];

missionNamespace setVariable ["ALiVE_FS_schemaCache", _schema];
_schema
