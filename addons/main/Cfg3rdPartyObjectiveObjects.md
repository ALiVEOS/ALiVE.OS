# Mod Author Guide: Registering Objects with ALiVE Objective Objects

This guide is for **3rd-party mod authors** who want their radar / antenna /
jammer / comms / data-terminal / signal-panel classes to appear in ALiVE's
Objective Objects picker (issue
[#875](https://github.com/ALiVEOS/ALiVE.OS/issues/875)) without needing a
PR to ALiVE itself.

ALiVE walks the merged config tree at runtime. **Arma's config system
merges any class definitions sharing a class name across all loaded
addons.** That means you can extend ALiVE's registry from your own
addon's `config.cpp` — no ALiVE changes required.

## Schema

In your addon's `config.cpp`:

```cpp
class Cfg3rdPartyObjectiveObjects {
    class MyMod {
        cfgPatchesName = "MyMod_main";          // required
        displayName    = "My Mod";              // required, picker label
        radar[]        = {"MyMod_radar_1", "MyMod_radar_2"};
        antenna[]      = {"MyMod_antenna_1"};
        jammer[]       = {};                    // empty / omit if N/A
        comms[]        = {};
        dataTerminal[] = {};
        staticData[]   = {};
    };
};
```

### Fields

| Field            | Type   | Required | Notes |
|------------------|--------|----------|-------|
| `cfgPatchesName` | string | yes      | A class in `CfgPatches` that ALiVE checks via `isClass`. Used to gate the entire block — if the patch isn't loaded, the block is skipped. Lets unloaded mods drop out cleanly. |
| `displayName`    | string | yes      | Human-readable label shown as the "source" filter option in the picker. |
| `radar[]`        | array  | optional | Air-search / height-finder / SAM-component / radome / dish classes. |
| `antenna[]`      | array  | optional | Transmitter towers / poles / omnidirectional / satellite antennas / mast antennas. |
| `dataTerminal[]` | array  | optional | Interactive data / rugged terminals. |
| `jammer[]`       | array  | optional | EMP / electronic-warfare / jammer-themed props. |
| `comms[]`        | array  | optional | Generic comms gear (transmitter boxes, satellite phones, comms-variant vehicles, radio props). |
| `staticData[]`   | array  | optional | Visual signal panels, marker panels, casualty indicators. |

All classnames are matched case-insensitively against `CfgVehicles` at
runtime. Classes not present in `CfgVehicles` are silently skipped.

## Side detection

The picker's side filter reads side via:

1. `getNumber (configFile >> "CfgVehicles" >> _class >> "side")` first
2. Suffix-heuristic fallback (`_BLUFOR` / `_OPFOR` / `_INDFOR` / `_IND` /
   `_CIV`) when the numeric side is unset (-1) or out-of-range

If your mod's classes don't have a numeric `side` set in CfgVehicles and
don't follow a side suffix, all of them will surface as "Empty" in the
side filter. Setting `side` in your CfgVehicles entries fixes this for
all of ALiVE, not just this picker.

## Verification

1. Drop your addon into your @mod load order
2. Open Eden, place an ALiVE placement module (`mil_placement_custom`,
   `mil_placement`, `civ_placement_custom`, `civ_placement`, or `mil_ato`)
3. Open the **Objective Objects** attribute
4. Cycle the **Source** filter — your `displayName` should appear
5. Select your source — your classes should appear in the listbox

If your block doesn't show up, check:

- The `cfgPatchesName` you wrote actually exists in `CfgPatches`
  (typo? Wrong patch class?)
- All your class names exist in `CfgVehicles`
- Your subclass under `Cfg3rdPartyObjectiveObjects` is uniquely named
  (don't reuse `MyMod` if ALiVE already has a `MyMod` block)

## Reference

The shipping registry at
[`Cfg3rdPartyObjectiveObjects.hpp`](Cfg3rdPartyObjectiveObjects.hpp) is the
canonical reference — copy any of its mod blocks (RHS, POOK, Crows, EAA,
Drongos) as a template.

## What if my classes don't fit a category?

The picker's category filter is just for UX-grouping. If your asset is a
"radar antenna combo" prop, pick the closest category — radar /
antenna / comms — and place it under that. The category influences only
the listbox grouping; spawn behaviour is identical across categories.

## Performance

The walker fires once per Eden picker open. Schema parsing is
proportional to total class count across all sources — adding a few
hundred classes is no concern. The current shipping registry has ~250
classes across 9 sources with no measurable Eden overhead.
