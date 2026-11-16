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
        ["meta", "M:meta", [], ""]
    ]],
    ["options", [
        ["noRandom", "B", true, ""],
        ["force", "B", false, ""],
        ["copyParent", "B", false, ""]
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
        ["identity", "M:identity", [], ""]
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
        ["textures", "LS", [], "path", 16]
    ]],
    ["turret", [
        ["path", "A", [], "turretPath"],
        ["cfg", "S", "", "cfgPath"],
        ["name", "S", "", "text60"],
        ["gunnerUnit", "S", "", "id?"],
        ["gunnerClass", "S", "", "gear"]
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
        ["members", "L:member", [], "", FS_MAX_MEMBERS]
    ]],
    ["member", [
        ["ref", "S", "", "ref"],
        ["rank", "S", "PRIVATE", "rank"],
        ["pos", "A", [], "pos"]
    ]]
];

missionNamespace setVariable ["ALiVE_FS_schemaCache", _schema];
_schema
