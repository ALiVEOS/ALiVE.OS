// Simply a package which requires other addons.
class CfgPatches {
	class ADDON {
		units[] = { };
		weapons[] = { };
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = { "ALIVE_main", "cba_ui" };
		versionDesc = "ALiVE";
		//versionAct = "['SYS_VIEWDISTANCE',_this] execVM '\x\alive\addons\main\about.sqf';";
		VERSION_CONFIG;
		author[] = { "Gunny", "Wolffy_au" };
		authorUrl = "http://dev-heaven.net/projects/alive";
	};
};
#include <\x\alive\addons\sys_viewdistance\vdist.hpp>
