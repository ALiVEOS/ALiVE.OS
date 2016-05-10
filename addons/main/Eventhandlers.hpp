class Extended_PreInit_EventHandlers {
	class ADDON {
		init = QUOTE(call COMPILE_FILE(XEH_preInit));
	};
};

class Extended_PostInit_EventHandlers {
	class ADDON {
		serverInit = QUOTE(call COMPILE_FILE(XEH_postServerInit));
		init = QUOTE(call COMPILE_FILE(XEH_postInit));
	};
};

class Extended_Init_EventHandlers
{
	class AllVehicles
	{
		class ADDON
		{
			init = "_this spawn ALiVE_fnc_ZeusRegister";
		};
	};
};
