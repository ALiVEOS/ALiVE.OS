
class CfgPatches {
	class ADDON {
		units[] = {};
		weapons[] = {};
		
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = {};
		VERSION_CONFIG;
		
		authorUrl = "http://dev-heaven.net/projects/alive";
		author[] = {
			"Naught",
			"ARJay",
			"Friznit",
			"Gunny",
			"HighHead",
			"Jman",
			"Raptor",
			"Rye",
			"Tupolov",
			"WobbleyHeadedBob",
			"Wolffy_au"
		};
		
		class logging {
			sp_log_level[]	= {"info", "notice", "warning", "error", "critical"};
			mp_log_level[]	= {"notice", "warning", "error", "critical"};
			log_to_diary = 0;
		};
	};
};
