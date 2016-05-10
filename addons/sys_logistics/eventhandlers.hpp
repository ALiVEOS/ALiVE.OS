class Extended_PostInit_EventHandlers {
	class ADDON {
		init = QUOTE(call COMPILE_FILE(XEH_postInit));
	};
};

class Extended_Init_EventHandlers
{
	class LANDVEHICLE
	{
		class ADDON 
		{
			ServerInit = "[nil,'setEH',_this] spawn ALiVE_fnc_Logistics";
		};
	};
	class AIR
	{
		class ADDON 
		{
			ServerInit = "[nil,'setEH',_this] spawn ALiVE_fnc_Logistics";
		};
	};
	class SHIP
	{
		class ADDON 
		{
			ServerInit = "[nil,'setEH',_this] spawn ALiVE_fnc_Logistics";
		};
	};
};