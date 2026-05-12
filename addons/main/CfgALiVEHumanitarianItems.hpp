// ----------------------------------------------------------------------------
// CfgALiVEHumanitarianItems
//
// Registry consumed by the shared ALiVE_ItemChoiceMulti_Water /
// ALiVE_ItemChoiceMulti_Ration controls (see
// fnc_edenItemChoiceMultiLoad.sqf). Enumerates known "water" and
// "ration" classnames per source mod, gated by `cfgPatchesName` so
// items from unloaded mods don't clutter the Eden dropdown.
//
// Unlike Cfg3rdPartyFactions (which is a refinement layer over
// CfgFactionClasses auto-detection), THIS registry IS the source of
// truth for the humanitarian-item multi-selects. There's no
// authoritative config subclass in the engine equivalent to
// CfgFactionClasses for arbitrary items, so we maintain the list
// here.
//
// This class is intentionally open -- any addon (a 3rd-party compat
// PBO, a mission-maker's own mod) can extend the registry by
// declaring additional subclasses in its own config.cpp. No ALiVE
// core changes required to add new mod-specific item sources.
//
// Runtime behaviour: the classnames listed here also populate the
// built-in ALiVE_CivPop_Interaction_WaterItems /
// ALiVE_CivPop_Interaction_RationItems arrays in static/CivPop.hpp
// for the civ humanitarian-aid interaction code path. The two lists
// are intentionally kept in sync; keep both current when adding or
// removing entries.
//
// Schema per subclass:
//   cfgPatchesName (string)  REQUIRED - CfgPatches class to detect.
//                                       Entry skipped if not loaded.
//                                       Use "A3_Characters_F" for
//                                       vanilla A3 (always present)
//                                       or "ALiVE_main" for ALiVE
//                                       core items.
//   displayName    (string)  REQUIRED - mod label shown in the
//                                       dropdown entry suffix
//                                       (e.g. "ACE_Canteen (ACE3)").
//   class water {                       OPTIONAL - water items
//       class <ClassName> {
//           displayName (string) REQUIRED - human-readable label.
//       };
//   };
//   class ration {                      OPTIONAL - ration items
//       class <ClassName> { displayName = "..."; };
//   };
//
// All classnames matched case-insensitively against CfgWeapons /
// CfgMagazines (or CfgVehicles for item-props) at runtime; casing
// in the registry doesn't matter.
// ----------------------------------------------------------------------------

class CfgALiVEHumanitarianItems {

    // Vanilla A3 -- always loaded. Soda cans (drinks) + Tactical Bacon.
    class ALiVE_Vanilla_A3 {
        cfgPatchesName = "A3_Characters_F";
        displayName    = "Arma 3";
        class water {
            class Item_Can_V1_F { displayName = "Spirit (can)"; };
            class Item_Can_V2_F { displayName = "Franta (can)"; };
            class Item_Can_V3_F { displayName = "RedGull (can)"; };
        };
        class ration {
            class Item_TacticalBacon_F { displayName = "Tactical Bacon"; };
        };
    };

    // ALiVE core items -- always loaded alongside the mod itself.
    class ALiVE_Core {
        cfgPatchesName = "ALiVE_main";
        displayName    = "ALiVE";
        class water {
            class ALiVE_Waterbottle { displayName = "Water Bottle"; };
        };
        class ration {
            class ALiVE_Humrat { displayName = "Rice Pack"; };
        };
    };

    // ACE3 field-rations PBO. Modern classnames; the legacy
    // ACE_Humanitarian_Ration (underscored) from the retired ACEX
    // PBO is kept in the static CivPop.hpp lookup list for
    // backward-compat but deliberately omitted here -- ACEX hasn't
    // shipped for ~4 years and the current classname is
    // ACE_HumanitarianRation (no underscore).
    class ACE3_FieldRations {
        cfgPatchesName = "ace_field_rations";
        displayName    = "ACE3";
        class water {
            class ACE_Canteen     { displayName = "Canteen"; };
            class ACE_WaterBottle { displayName = "Water Bottle"; };
            class ACE_Spirit      { displayName = "Spirit (soda)"; };
            class ACE_Franta      { displayName = "Franta (soda)"; };
            class ACE_RedGull     { displayName = "RedGull (energy drink)"; };
        };
        class ration {
            class ACE_MRE_BeefStew           { displayName = "MRE - Beef Stew"; };
            class ACE_MRE_ChickenTikkaMasala { displayName = "MRE - Chicken Tikka Masala"; };
            class ACE_MRE_ChickenWithRice    { displayName = "MRE - Chicken with Rice"; };
            class ACE_MRE_CreamOfChickenSoup { displayName = "MRE - Cream of Chicken Soup"; };
            class ACE_MRE_LambCurry          { displayName = "MRE - Lamb Curry"; };
            class ACE_MRE_MeatballsWithPasta { displayName = "MRE - Meatballs with Pasta"; };
            class ACE_MRE_SteakVegetables    { displayName = "MRE - Steak & Vegetables"; };
            class ACE_HumanitarianRation     { displayName = "Humanitarian Ration"; };
            class ACE_Banana                 { displayName = "Banana"; };
            class ACE_SunflowerSeeds         { displayName = "Sunflower Seeds"; };
            class ACE_BeefJerky              { displayName = "Beef Jerky"; };
        };
    };

    // MGM Foods mod. cfgPatchesName is a best-guess -- if MGM items
    // don't appear when the mod is loaded, the patch name needs
    // correcting here.
    class MGM_Foods {
        cfgPatchesName = "mgm_foods";
        displayName    = "MGM Foods";
        class water {
            class mgm_item_redgull { displayName = "RedGull"; };
        };
        class ration {
            class mgm_item_mre { displayName = "MRE"; };
        };
    };

    // Kurt's Survival System (KSS). cfgPatchesName best-guess as
    // above; adjust if items don't appear with KSS loaded.
    class KSS {
        cfgPatchesName = "kss_main";
        displayName    = "Kurt's Survival System";
        class water {
            class KSS_water_plastic_bottle { displayName = "Plastic Water Bottle"; };
        };
        class ration {
            class KSS_canned_beef { displayName = "Canned Beef"; };
            class KSS_canned_fish { displayName = "Canned Fish"; };
        };
    };

    // S.O.G. Prairie Fire (Vietnam CDLC). Crate-prop drinks + field
    // rations + fresh food props.
    class VN_SOG_PrairieFire {
        cfgPatchesName = "vn_characters_c";
        displayName    = "S.O.G. Prairie Fire";
        class water {
            class vn_prop_drink_01 { displayName = "Drink (crate prop 1)"; };
            class vn_prop_drink_02 { displayName = "Drink (crate prop 2)"; };
            class vn_prop_drink_05 { displayName = "Drink (crate prop 5)"; };
        };
        class ration {
            class vn_b_item_rations_01  { displayName = "Field Ration"; };
            class vn_prop_food_fresh_01 { displayName = "Fresh Food (prop 1)"; };
            class vn_prop_food_fresh_02 { displayName = "Fresh Food (prop 2)"; };
            class vn_prop_food_meal_01  { displayName = "Meal (prop 1)"; };
            class vn_prop_food_sack_01  { displayName = "Food Sack (prop 1)"; };
            class vn_prop_food_sack_02  { displayName = "Food Sack (prop 2)"; };
        };
    };

};
