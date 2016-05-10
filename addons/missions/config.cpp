
class CfgPatches
{
	class ALiVE_Missions
	{
		units[] = {""};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"Alive_main"};
	};
};

class CfgMissions
{
	class Showcases
	{
        class Showcase_Tour
        {
            briefingName = "ALiVE | Tour";
            directory = "x\alive\addons\missions\showcases\tour.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
			overviewText = "ALiVE Tour will take you through the different modules, technology and gameplay offered by ALiVE.";
			author = "ALiVE Mod Team";   
        };
		class Showcase_Getting_Started
		{
			briefingName = "ALiVE | Quick Start";
			directory = "x\alive\addons\missions\showcases\basic.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
			overviewText = "This is the basic quick start mission featured in the ALiVE documentation and Wiki (alivemod.com)";
			author = "ALiVE Mod Team";            		
		};
		class Showcase_Divide_And_Rule
		{
			briefingName = "ALiVE | Divide and Rule";
			directory = "x\alive\addons\missions\showcases\alive_divide_and_rule.altis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
			overviewText = "INTEL has been received about a nuclear device being built by a scientist named Ahelef Mahmoud in an hideout in Zaros! Locate Mahmoud, disable the bomb, and return home safely!";
			author = "ALiVE Mod Team";               		
		};		
        class Showcase_HurtLocker
        {
            briefingName = "ALiVE | Hurt Locker";
            directory = "x\alive\addons\missions\showcases\hurtlocker.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
			overviewText = "Stratis is reeling from a brutal insurgency campaign. IED's litter the landscape, its your job to identify and disarm IEDs to ensure the safety of the civilian population. Beware of the local militia!";
			author = "ALiVE Mod Team";   
        };	        		
	};
	class MPMissions
	{
		class MP_COOP_Divide_And_Rule
		{
			briefingName = "ALiVE | Divide and Rule (COOP 7)";
			directory = "x\alive\addons\missions\showcases\alive_divide_and_rule.altis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
			overviewText = "INTEL has been received about a nuclear device being built by a scientist named Ahelef Mahmoud in an hideout in Zaros! Locate Mahmoud, disable the bomb, and return home safely!";
			author = "ALiVE Mod Team";               		
		};				
		class MP_COOP_Getting_Started
		{
			briefingName = "ALiVE | Quick Start (COOP 9)";
			directory = "x\alive\addons\missions\showcases\basic.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
			overviewText = "This is the basic quick start mission featured in the ALiVE documentation and Wiki (alivemod.com)";
			author = "ALiVE Mod Team";            		
		};		
		class MP_COOP_Air_Assault
		{
			briefingName = "ALiVE | Air Assault (COOP 8)";
			directory = "x\alive\addons\missions\mpscenarios\ALiVE_Air_Assault.Altis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "Steal the prototype MI-48 from the airbase at Salakano and bring it to your Command base in the north! Try to survive!";
			author = "ALiVE Mod Team";   
		};
        class MP_COOP_HurtLocker
        {
            briefingName = "ALiVE | Hurt Locker (COOP 10)";
            directory = "x\alive\addons\missions\showcases\hurtlocker.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
			overviewText = "Stratis is reeling from a brutal insurgency campaign. IED's litter the landscape, its your job to identify and disarm IEDs to ensure the safety of the civilian population. Beware of the local militia!";
			author = "ALiVE Mod Team";   
        };			
		class MP_COOP_Sabotage
		{
			briefingName = "ALiVE | Sabotage (COOP 12)";
			directory = "x\alive\addons\missions\mpscenarios\ALiVE_Sabotage.Altis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "Lead an insurgency on Altis, use sabotage and subterfuge to capture weapons and establish safe houses across the island.";
			author = "ALiVE Mod Team";   
		};			
	};
};

