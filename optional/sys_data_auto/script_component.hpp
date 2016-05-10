#define COMPONENT sys_data_auto
#include <\x\alive\addons\main\script_mod.hpp>

#define DATA_INBOUND_LIMIT 9500

#ifdef DEBUG_ENABLED_SYS_DATA_AUTO
	#define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_SYS_DATA_AUTO
	#define DEBUG_SETTINGS DEBUG_SETTINGS_SYS_DATA_AUTO
#endif

#include <\x\cba\addons\main\script_macros.hpp>