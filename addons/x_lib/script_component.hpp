
#define COMPONENT x_lib
#include <\x\alive\addons\main\script_mod.hpp>

#define LOG_LEVELS ["info", "notice", "warning", "error", "critical"]

#ifdef DEBUG_ENABLED_X_LIB
	#define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_X_LIB
	#define DEBUG_SETTINGS DEBUG_ENABLED_X_LIB
#endif

#include <\x\cba\addons\main\script_macros.hpp>
#include <script_macros.hpp>
