class CfgFunctions
{
#include "ETHICSMinefields\THY_ETH_functions.hpp"
    class SPEALIVE_Missions
    {
        tag = "spe_alivems";

        class coalive_fnc
        {
            file = "fnc";

            class coalive_briefing
            {
                postInit = 1;
            };
            class coalive_typeWrite
            {
                postInit = 1;
            };
        };
				class params
				{
						file = "fnc";
						
						class params_stamina
						{
							recompile = 0;
						};
						class params_aimCoef
						{
							recompile = 0;
						};
						
						
				};
    };
};
