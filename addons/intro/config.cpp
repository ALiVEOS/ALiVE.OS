#include <script_component.hpp>

class CfgPatches
{
	class ADDON
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = {"ALIVE_main"};
		versionDesc = "ALiVE";
		VERSION_CONFIG;
		author[] = {"Music by Johari"};
		authorUrl = "http://dev-heaven.net/projects/alive";
	};
};
class CfgMissions
{
	class Cutscenes
	{
		class ALiVE_Intro_Stratis
		{
			directory = "x\alive\addons\intro\scenes\Intro.Stratis";
		};
		class ALiVE_Intro_Stratis_1
		{
			directory = "x\alive\addons\intro\scenes\Intro_1.Stratis";
		};
		class ALiVE_Intro_Altis
		{
			directory = "x\alive\addons\intro\scenes\Intro.Altis";
		};
		class ALiVE_Intro_Altis_1
		{
			directory = "x\alive\addons\intro\scenes\Intro_1.Altis";
		};	
	};
};

class CAWorld;

class CfgWorlds
{
	class Stratis: CAWorld
	{ 
			cutscenes[] = {"ALiVE_Intro_Stratis","ALiVE_Intro_Stratis_1"};
	};
	class Altis: CAWorld
	{ 
			cutscenes[] = {"ALiVE_Intro_Altis","ALiVE_Intro_Altis_1"};
	};	
};

class CfgMusic
{
	class ALiVE_Intro
	{
		name = "ALiVE - This is War - Johari";
		sound[] = {"\x\alive\addons\intro\Music\ArmA.ogg",1.0,1.0};
		duration = 172;
		theme = "safe";
		musicClass = "Lead";
	};
	class ALiVE_Bonus
	{
		name = "ALiVE - Everest - Johari";
		sound[] = {"\x\alive\addons\intro\Music\EverestInstrumental.ogg",1.0,1.0};
		duration = 255;
		theme = "safe";
		musicClass = "Lead";
	};	
};


class RscStandardDisplay;
class RscPicture;
class RscDisplayMain: RscStandardDisplay
{
	class controls
	{
		class JohariLogo: RscPicture
		{			
			idc = 1299;
			text = "\x\alive\addons\intro\data\johari_small.paa";	
			tooltip = "$STR_ALIVE_UI_TOOLTIP_JOHARI_ABOUT";
			x = "safezoneX + safezoneW - 2 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			y = "21 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 			(safezoneY + safezoneH - 			(			((safezoneW / safezoneH) min 1.2) / 1.2))";
			w = "1.28 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			h = "1.28 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";			
		};		
	};
};
