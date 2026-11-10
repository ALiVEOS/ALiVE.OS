
// Include the relevant static data

#include "CQB.hpp"

#include "Placement.hpp"

#include "Logistics.hpp"

#include "PlayerResupply.hpp"

#include "Tasks.hpp"

#include "CivPop.hpp"

#include "GarrisonPositions.hpp"

#include "Compositions.hpp"

#include "CustomFactions.hpp"

// Phase 3c.1: redirect-only inference for unmapped factions.
// CustomFactions.hpp populates ALiVE_factionCustomMappings with curated
// entries (RHS USAF/USMC/AFRF/GREF/SAF and the BLU_G_F example). The
// inference call below fills the gaps - any loaded faction NOT in the
// curated set AND lacking proper CfgGroups gets an inferred redirect to
// a vanilla A3 faction on its dominant side, making it spawnable. Phase
// 3c.2 will add unit substitution so the mod's actual units appear
// instead of vanilla A3 fallbacks.
// Timed apart, so a slow start can be put down to the data or to the faction inference
private _staticInferStart = diag_tickTime;
["staticData: data loaded, faction inference starting"] call ALiVE_fnc_dump;
call ALiVE_fnc_inferFactionMappingsAll;
["staticData: faction inference took %1 s", (diag_tickTime - _staticInferStart) toFixed 1] call ALiVE_fnc_dump;

#include "Maps.hpp"

ALiVE_STATIC_DATA_LOADED = true;
