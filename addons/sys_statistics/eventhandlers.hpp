class Extended_PreInit_EventHandlers
{
 class alive_sys_statistics
 {
  init = "call ('\x\alive\addons\sys_statistics\XEH_preInit.sqf' call SLX_XEH_COMPILE)";
 };
};

class Extended_Killed_Eventhandlers
{
	class LANDVEHICLE
	{
		class alive_sys_statistics 
		{
			killed = "_this call alive_sys_statistics_fnc_unitKilledEH";
		};
	};
	class MAN
	{
		class alive_sys_statistics 
		{
			killed = "_this call alive_sys_statistics_fnc_unitKilledEH";
		};
	};
	class AIR
	{
		class alive_sys_statistics 
		{
			killed = "_this call alive_sys_statistics_fnc_unitKilledEH";
		};
	};
	class SHIP
	{
		class alive_sys_statistics 
		{
			killed = "_this call alive_sys_statistics_fnc_unitKilledEH";
		};
	};
};

class Extended_incomingMissile_Eventhandlers
{
	class LANDVEHICLE
	{
		class alive_sys_statistics 
		{
			incomingMissile = "_this call alive_sys_statistics_fnc_incomingMissileEH";
		};
	};
	class MAN
	{
		class alive_sys_statistics 
		{
			incomingMissile = "_this call alive_sys_statistics_fnc_incomingMissileEH";
		};
	};
	class AIR
	{
		class alive_sys_statistics 
		{
			incomingMissile = "_this call alive_sys_statistics_fnc_incomingMissileEH";
		};
	};
	class SHIP
	{
		class alive_sys_statistics 
		{
			incomingMissile = "_this call alive_sys_statistics_fnc_incomingMissileEH";
		};
	};
};


class Extended_FiredBIS_EventHandlers
{
	class LANDVEHICLE
	{
		class alive_sys_statistics 
		{
			firedBis = "_this call alive_sys_statistics_fnc_firedEH";
		};
	};
	class AIR
	{
		class alive_sys_statistics 
		{
			firedBis = "_this call alive_sys_statistics_fnc_firedEH";
		};
	};
	class SHIP
	{
		class alive_sys_statistics 
		{
			firedBis = "_this call alive_sys_statistics_fnc_firedEH";
		};
	};
};

class Extended_Hit_EventHandlers
{
	class LANDVEHICLE
	{
		class alive_sys_statistics 
		{
			Hit = "_this call alive_sys_statistics_fnc_hitEH";
		};
	};
	class AIR
	{
		class alive_sys_statistics 
		{
			Hit = "_this call alive_sys_statistics_fnc_hitEH";
		};
	};
	class SHIP
	{
		class alive_sys_statistics 
		{
			Hit = "_this call alive_sys_statistics_fnc_hitEH";
		};
	};
};



class Extended_GetOut_EventHandlers
{
	class LANDVEHICLE
	{
		class alive_sys_statistics 
		{
			getOut = "_this call alive_sys_statistics_fnc_getOutEH";
		};
	};
	class AIR
	{
		class alive_sys_statistics 
		{
			getOut = "_this call alive_sys_statistics_fnc_getOutEH";
		};
	};
	class SHIP
	{
		class alive_sys_statistics 
		{
			getOut = "_this call alive_sys_statistics_fnc_getOutEH";
		};
	};
};

class Extended_GetIn_EventHandlers
{
	class LANDVEHICLE
	{
		class alive_sys_statistics 
		{
			getIn = "_this call alive_sys_statistics_fnc_getInEH";
		};
	};
	class AIR
	{
		class alive_sys_statistics 
		{
			getIn = "_this call alive_sys_statistics_fnc_getInEH";
		};
	};
	class SHIP
	{
		class alive_sys_statistics 
		{
			getIn = "_this call alive_sys_statistics_fnc_getInEH";
		};
	};
};

class Extended_landedTouchDown_EventHandlers
{
	class AIR
	{
		class alive_sys_statistics 
		{
			landedTouchDown = "_this call alive_sys_statistics_fnc_landedTouchDownEH";
		};
	};
};