/*
 * Mil logistics convoy transport vehicles fallback for sides
 */

ALIVE_sideDefaultTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultTransport, "EAST", ["O_Truck_02_transport_F","O_Truck_02_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultTransport, "WEST", ["B_Truck_01_transport_F","B_Truck_01_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultTransport, "GUER", ["I_Truck_02_covered_F","I_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultTransport, "CIV", ["C_Van_01_transport_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics convoy transport vehicles per faction
 */

ALIVE_factionDefaultTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultTransport, "OPF_F", ["O_Truck_02_transport_F","O_Truck_02_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "OPF_G_F", ["O_G_Van_01_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "IND_F", ["I_Truck_02_covered_F","I_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "BLU_F", ["B_Truck_01_transport_F","B_Truck_01_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "BLU_G_F", ["B_G_Van_01_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "CIV_F", ["C_Van_01_transport_F"]] call ALIVE_fnc_hashSet;

// APEX
[ALIVE_factionDefaultTransport, "OPF_T_F", ["O_T_Truck_03_transport_ghex_F","O_T_Truck_03_covered_ghex_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "IND_C_F", ["C_Truck_02_covered_F","C_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "BLU_T_F", ["B_T_Truck_01_transport_F","B_T_Truck_01_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "BLU_CTRG_F", ["B_T_Truck_01_transport_F","B_T_Truck_01_covered_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "Gendarmerie", ["C_Truck_02_covered_F","C_Truck_02_transport_F"]] call ALIVE_fnc_hashSet;


/*
 * Mil logistics air transport vehicles fallback for sides
 */

ALIVE_sideDefaultAirTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultAirTransport, "EAST", ["O_Heli_Transport_04_F","O_Heli_Transport_04_box_F","O_Heli_Attack_02_F","O_Heli_Light_02_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultAirTransport, "WEST", ["B_Heli_Transport_03_F","B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultAirTransport, "GUER", ["I_Heli_Transport_02_F","I_Heli_light_03_unarmed_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultAirTransport, "CIV", ["C_Heli_light_01_ion_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics air transport vehicles per faction
 */

ALIVE_factionDefaultAirTransport = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultAirTransport, "OPF_F", ["O_Heli_Transport_04_F","O_Heli_Transport_04_box_F","O_Heli_Attack_02_F","O_Heli_Light_02_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "OPF_G_F", ["I_Heli_light_03_unarmed_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "IND_F", ["I_Heli_Transport_02_F","I_Heli_light_03_unarmed_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "BLU_F", ["B_Heli_Transport_03_F","B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "BLU_G_F", ["I_Heli_light_03_unarmed_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "CIV_F", ["C_Heli_light_01_ion_F"]] call ALIVE_fnc_hashSet;

// APEX
[ALIVE_factionDefaultAirTransport, "OPF_T_F", ["O_Heli_Transport_04_F","O_Heli_Transport_04_box_F","O_Heli_Attack_02_F","O_Heli_Light_02_F","O_T_VTOL_02_infantry_F","O_T_VTOL_02_vehicle_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "IND_C_F", ["I_C_Heli_Light_01_civil_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "BLU_T_F", ["B_Heli_Transport_03_F","B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F","B_T_VTOL_01_armed_F","B_T_VTOL_01_infantry_F","B_T_VTOL_01_vehicle_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "BLU_CTRG_F", ["B_Heli_Transport_03_F","B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F","B_T_VTOL_01_armed_F","B_T_VTOL_01_infantry_F","B_T_VTOL_01_vehicle_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "Gendarmerie", ["C_Heli_Light_01_civil_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers fallback for sides
 */

ALIVE_sideDefaultContainers = [] call ALIVE_fnc_hashCreate;
[ALIVE_sideDefaultContainers, "EAST", ["ALIVE_O_supplyCrate_F","O_CargoNet_01_ammo_F","CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultContainers, "WEST", ["ALIVE_B_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultContainers, "GUER", ["ALIVE_I_supplyCrate_F","I_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_sideDefaultContainers, "CIV", ["CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;

/*
 * Mil logistics airdrop containers per faction
 */
ALIVE_factionDefaultContainers = [] call ALIVE_fnc_hashCreate;
[ALIVE_factionDefaultContainers, "OPF_F", ["ALIVE_O_supplyCrate_F","O_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "OPF_G_F", ["ALIVE_O_supplyCrate_F","O_CargoNet_01_ammo_F","CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "IND_F", ["ALIVE_I_supplyCrate_F","I_CargoNet_01_ammo_F","CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "BLU_F", ["ALIVE_B_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "BLU_G_F", ["ALIVE_B_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "CIV_F", ["CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;

// APEX
[ALIVE_factionDefaultContainers, "OPF_T_F", ["ALIVE_O_supplyCrate_F","O_CargoNet_01_ammo_F","CargoNet_01_box_F","Land_Pod_Heli_Transport_04_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "IND_C_F", ["ALIVE_I_supplyCrate_F","I_CargoNet_01_ammo_F","CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "BLU_T_F", ["ALIVE_B_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "BLU_CTRG_F", ["ALIVE_B_supplyCrate_F","B_CargoNet_01_ammo_F","CargoNet_01_box_F","B_Slingload_01_Cargo_F","C_T_supplyCrate_F"]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultContainers, "Gendarmerie", ["CargoNet_01_box_F"]] call ALIVE_fnc_hashSet;

#include "logistics\3CB.hpp"
#include "logistics\RHS_AFRF.hpp"
#include "logistics\RHS_GREF.hpp"
#include "logistics\RHS_SAF.hpp"
#include "logistics\RHS_USAF.hpp"
#include "logistics\IFA3.hpp"
