class CfgFunctions
{
    class VNALIVE_Missions
    {
        tag = "vn_alivems";

        class coalive_fnc
        {
            file = "fnc";

            class coalive_briefing
            {
                postInit = 1;
            };
            class coalive_respawnInit
            {
                postInit = 1;
            };
        };
				class params
				{
						file = "fnc";
						class params_arsenal
						{
							recompile = 0;
						};
						class params_aimCoef
						{
							recompile = 0;
						};
						class params_failOnWipe
						{
							recompile = 0;
						};
						class params_hints
						{
							recompile = 0;
						};
						class params_respawnDelay
						{
							recompile = 0;
						};
						class params_stamina
						{
							recompile = 0;
						};
						class params_teleportAction
						{
							recompile = 0;
						};
						class params_mapMarkers
						{
							recompile = 0;
						};
						class params_rotorLib
						{
							recompile = 0;
						};
				};
        class coalive_fsm
        {
            file = "fsm";
            class coalive_alpha
            {
              ext = ".fsm";
            };
        };	
    };
};
