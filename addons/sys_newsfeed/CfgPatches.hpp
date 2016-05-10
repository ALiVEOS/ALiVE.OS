// Simply a package which requires other addons.
class CfgPatches {
	class ADDON {
		units[] = {};
		weapons[] = {};
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = {"ALIVE_main"};
		versionDesc = "ALiVE";
		//versionAct = "['SYS_NEWSFEED',_this] execVM '\x\alive\addons\main\about.sqf';";
		VERSION_CONFIG;
		author[] = {"Gunny"};
		authorUrl = "http://dev-heaven.net/projects/alive";
	};
};
#include <\x\alive\addons\sys_newsfeed\newsfeed\newsfeed.hpp>