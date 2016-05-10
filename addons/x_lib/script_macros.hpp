
// #include "\x\alive\addons\x_lib\script_component.hpp"

/*
	Section: Logging Macros
*/

#define LOG_FORMAT(varLevel,varComponent,varText,varParams) \
	[varLevel, varComponent, varText, varParams, __FILE__, __LINE__] call core_fnc_log

#define LOG(varLevel,varComponent,varText) \
	LOG_FORMAT(varLevel,varComponent,varText,[])

#define LOG_INFO(varComponent,varText) \
	LOG("Info",varComponent,varText)

#define LOG_NOTICE(varComponent,varText) \
	LOG("Notice",varComponent,varText)

#define LOG_WARNING(varComponent,varText) \
	LOG("Warning",varComponent,varText)

#define LOG_ERROR(varComponent,varText) \
	LOG("Error",varComponent,varText)

#define LOG_CRITICAL(varComponent,varText) \
	LOG("Critical",varComponent,varText)
