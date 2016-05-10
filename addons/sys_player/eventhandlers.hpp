class Extended_PreInit_EventHandlers
{
    class alive_sys_player
    {
        init = "alive_sys_player_fnc_initVehicle = compile preprocessFileLineNumbers '\x\alive\addons\sys_player\fnc_vehicleInit.sqf'";
    };
};

class Extended_InitPost_Eventhandlers
{
    class LANDVEHICLE
    {
        class alive_sys_player
        {
            init = "_this call alive_sys_player_fnc_initVehicle";
        };
    };
    class AIR
    {
        class alive_sys_player
        {
            init = "_this call alive_sys_player_fnc_initVehicle";
        };
    };
    class SHIP
    {
        class alive_sys_player
        {
            init = "_this call alive_sys_player_fnc_initVehicle";
        };
    };
};