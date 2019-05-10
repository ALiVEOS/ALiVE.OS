class CfgWeapons
{
	class GrenadeLauncher;
	class Throw: GrenadeLauncher
	{
		muzzles[] += {"ALiVE_Handgrenade_stoneMuzzle","ALiVE_Handgrenade_canMuzzle","ALiVE_Handgrenade_bottleMuzzle"};
		class ThrowMuzzle;
		class ALiVE_Handgrenade_stoneMuzzle: ThrowMuzzle
		{
			displayName = "Stone";
			magazines[] = {"ALiVE_Handgrenade_stone"};
		};
		class ALiVE_Handgrenade_canMuzzle: ThrowMuzzle
		{
			displayName = "Can";
			magazines[] = {"ALiVE_Handgrenade_can"};
		};
		class ALiVE_Handgrenade_bottleMuzzle: ThrowMuzzle
		{
			displayName = "Bottle";
			magazines[] = {"ALiVE_Handgrenade_bottle"};
		};
	};
};