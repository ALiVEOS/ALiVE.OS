// ----------------------------------------------------------------------------
// CfgALiVELists
//
// Built-in named lists of what players may have, read by ALIVE_fnc_lists. A
// mission's description.ext can add its own lists, or a class of the same
// name to replace one of these. Keys:
//   only[], never[], also[] - class, group (BUS_InfSquad) or faction>group
//                             names; Class=price sets a FOB price
//   kinds[]        - FORTIFICATION, SUPPLY, STATIC, VEHICLE or
//                    VEHICLE:CAR,TRUCK,ARMOUR,ARTILLERY,AIR,BOAT, TROOPS,
//                    GEAR; none means every kind. Any kind cut leaves out
//                    artillery static weapons.
//   staticTier     - 2 machine guns and grenade launchers, 3 all
//   fieldWorksOnly - fortifications no taller than 3 m (Player FOBs only)
//   fold           - 1 shows one of each vehicle, static weapon and crate
//                    model, the plainest of its camo and loadout variants;
//                    soldiers and named classes are never folded
//   inherit        - another list to start from
//   class <Class> { cost = N; } - a FOB price
//
// The first five carry the Player FOBs Build List Preset names, so a preset
// and its list give the same build list. GEAR is kept in those so the FOB
// Arsenal's gear stays as it is with a preset today.
// ----------------------------------------------------------------------------

class CfgALiVELists {
    class ALL {
    };
    class OUTPOST {
        kinds[] = {"FORTIFICATION", "SUPPLY", "GEAR"};
        fieldWorksOnly = 1;
    };
    class FORTIFIED {
        kinds[] = {"FORTIFICATION", "SUPPLY", "STATIC", "VEHICLE:CAR,TRUCK,BOAT", "TROOPS", "GEAR"};
        staticTier = 3;
    };
    class INFANTRY {
        kinds[] = {"FORTIFICATION", "SUPPLY", "STATIC", "VEHICLE:CAR,TRUCK", "TROOPS", "GEAR"};
        staticTier = 2;
        fieldWorksOnly = 1;
    };
    class LOGISTICS {
        kinds[] = {"FORTIFICATION", "SUPPLY", "VEHICLE:TRUCK,BOAT", "GEAR"};
    };
    class SUPPLIES {
        kinds[] = {"SUPPLY"};
    };
    class LIGHT {
        kinds[] = {"SUPPLY", "STATIC", "VEHICLE:CAR,TRUCK,BOAT", "TROOPS"};
        staticTier = 2;
    };
    class STATICS_SUPPLIES {
        kinds[] = {"SUPPLY", "STATIC"};
    };
    class TROOPS {
        kinds[] = {"TROOPS"};
    };
    // the resupply tablet's list when its List is not set
    class STANDARD {
        kinds[] = {"FORTIFICATION", "SUPPLY", "STATIC", "VEHICLE:CAR,TRUCK,BOAT", "TROOPS"};
        staticTier = 2;
        fold = 1;
    };
};
