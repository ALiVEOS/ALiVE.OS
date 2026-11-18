// ----------------------------------------------------------------------------
// CfgALiVEFactions
//
// A faction mod tells ALiVE about itself here, with no script and no entry in
// ALiVE's own CustomFactions.hpp: its supply crates, transports and support
// vehicles, and, only when its CfgGroups categories do not fit ALiVE's, where
// ALiVE finds its groups. The ORBAT Creator writes one into every faction it
// exports. A mod writes the class at the root of its config.cpp; it needs no
// requiredAddons entry for ALiVE, and with ALiVE not loaded nothing reads it.
// A mission can declare the same in its description.ext.
//
// Read once as ALiVE's static data loads (ALiVE_fnc_configFactionsRegister),
// after CustomFactions.hpp and before faction inference. What ALiVE already
// lists for a faction always wins. Every property is optional:
//
// class CfgALiVEFactions {
//     class MyFaction {                        // the CfgFactionClasses class
//         version = 1;
//         groupSide = "Indep";                 // CfgGroups side class (East, West, Indep)
//         groupFaction = "MyFaction";          // CfgGroups faction class; another faction's borrows its groups
//         class GroupTypes {                   // ALiVE category = CfgGroups category to use for it
//             Motorized_MTP = "Motorized";
//         };
//         class Groups {                       // ALiVE category = group classes
//             SpecOps[] = {"MyFaction_Recon"};
//         };
//         supplies[]     = {"MyFaction_Crate_Ammo"};   // ALIVE_factionDefaultSupplies
//         supports[]     = {"MyFaction_Truck_Ammo"};   // ALIVE_factionDefaultSupports
//         transport[]    = {"MyFaction_Truck"};        // ALIVE_factionDefaultTransport
//         airTransport[] = {"MyFaction_Heli"};         // ALIVE_factionDefaultAirTransport
//         containers[]   = {};                         // ALIVE_factionDefaultContainers
//         aa[]           = {};                         // ALIVE_factionDefaultAA
//         rarity = 1;                          // draw groups weighted by their rarityGroup
//     };
// };
//
// Class names that are not loaded are left out, and an empty list is not
// written, so ALiVE's list for the faction's side still applies. A block only
// registers a faction mapping when it borrows another faction's groups or
// names GroupTypes or Groups; one naming the faction itself leaves ALiVE to
// read the faction's own CfgGroups as it always has.
// ----------------------------------------------------------------------------

class CfgALiVEFactions {};
