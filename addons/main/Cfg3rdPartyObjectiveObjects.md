# Cfg3rdPartyObjectiveObjects

Reference for the `Cfg3rdPartyObjectiveObjects` config class consumed by
ALiVE's Objective Objects picker (issue
[#875](https://github.com/ALiVEOS/ALiVE.OS/issues/875)).

## Convention

Standard Arma config: any addon's `config.cpp` can declare subclasses
under `Cfg3rdPartyObjectiveObjects` and they merge into the same root
class as the entries defined in `addons/main`. ALiVE walks the merged
tree at runtime and surfaces every block whose `cfgPatchesName`
resolves against `CfgPatches`.

```cpp
class Cfg3rdPartyObjectiveObjects {
    class MyMod {
        cfgPatchesName = "MyMod_main";
        displayName    = "My Mod";
        radar[]        = {"MyMod_radar_1", "MyMod_radar_2"};
        antenna[]      = {"MyMod_antenna_1"};
        jammer[]       = {};
        comms[]        = {};
        dataTerminal[] = {};
        staticData[]   = {};
    };
};
```

## Schema

| Field            | Type   | Required | Notes |
|------------------|--------|----------|-------|
| `cfgPatchesName` | string | yes      | `CfgPatches` class for the gating `isClass` check. Block is skipped if the patch isn't loaded. |
| `displayName`    | string | yes      | Human-readable label, used as the "source" filter option. |
| `radar[]`        | array  | optional | Air-search / height-finder / SAM-component / radome / dish classes. |
| `antenna[]`      | array  | optional | Transmitter towers / poles / omnidirectional / satellite antennas / mast antennas. |
| `dataTerminal[]` | array  | optional | Interactive data / rugged terminals. |
| `jammer[]`       | array  | optional | EMP / electronic-warfare / jammer-themed props. |
| `comms[]`        | array  | optional | Comms gear (transmitter boxes, satellite phones, comms-variant vehicles, radio props). |
| `staticData[]`   | array  | optional | Visual signal panels, marker panels, casualty indicators. |

Classnames are matched case-insensitively against `CfgVehicles`. Classes
not in `CfgVehicles` are silently skipped.

## Side detection

The picker's side filter reads side via:

1. `getNumber (configFile >> "CfgVehicles" >> _class >> "side")` first
2. Suffix-heuristic fallback (`_BLUFOR` / `_OPFOR` / `_INDFOR` / `_IND` /
   `_CIV`) when the numeric side is unset (-1) or out-of-range

Classes without a numeric `side` and without a side suffix surface as
"Empty" in the side filter. Setting `side` in `CfgVehicles` is the
permanent fix and applies to all of ALiVE.

## Verification

The picker's load handler logs per-source class counts to RPT:

```
ALIVE FilteredMultiSelect LOAD: ... sources=[Arma 3 (Vanilla + DLC)=49, RHS AFRF=12, MyMod=4] ...
```

If the block doesn't appear:

- `cfgPatchesName` typo or wrong patch class
- Class names not present in `CfgVehicles`
- Subclass name collides with one ALiVE already defines (`A3_vanilla`,
  `CrowsEW`, `pook_SAM_Base`, `pook_camonets`, `RHS_AFRF`, `RHS_USAF`,
  `RHS_GREF`, `EAA`, `Drongos`)

## Reference

The shipping registry at
[`Cfg3rdPartyObjectiveObjects.hpp`](Cfg3rdPartyObjectiveObjects.hpp) is
the canonical reference. Any of its mod blocks (RHS, POOK, Crows, EAA,
Drongos) can be copied as a template.
