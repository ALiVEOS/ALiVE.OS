// Simply a package which requires other addons.
class CfgPatches {
	class ADDON {
		units[] = { };
		weapons[] = { };
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = {"ALIVE_main"};
		versionDesc = "ALiVE";
		//versionAct = "['SYS_CREWINFO',_this] execVM '\x\alive\addons\main\about.sqf';";
		VERSION_CONFIG;
		author[] = {"Jman"};
		authorUrl = "http://dev-heaven.net/projects/alive";
	};
};
	#include <\x\alive\addons\sys_crewinfo\crewinfo.hpp>
class RscTitles {
	#include <\x\alive\addons\sys_crewinfo\namesright.hpp>
	#include <\x\alive\addons\sys_crewinfo\namesleft.hpp>
};
