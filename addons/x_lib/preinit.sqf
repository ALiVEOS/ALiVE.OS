#include "script_component.hpp"

/* Load Definitions */
//#define BENCHMARK
#define C_DIARY_SUBJECT "alive_docs"
#define C_DIARY_SUBJECT_NAME "ALiVE"
#define C_DIARY_BUFFER_FLUSH_INTERVAL 1 // second(s)
#define C_GET_LOG_OPT(cfg) (configFile >> "CfgPatches" >> QUOTE(ADDON) >> "logging" >> cfg)

/*
	Section: General Function Initialization
*/

[] call ALiVE_fnc_isHC;
[] call ALiVE_fnc_BUS;

/* Load Logging Configuration */
{ // forEach
	[_x, true] call ALiVE_fnc_setLogLevel;
} forEach ([(if (!isMultiplayer) then {C_GET_LOG_OPT("sp_log_level")} else {C_GET_LOG_OPT("mp_log_level")}), []] call ALiVE_fnc_getConfigValue);

ALiVE_logToDiary = [[C_GET_LOG_OPT("log_to_diary"), 0] call ALiVE_fnc_getConfigValue] call ALiVE_fnc_toBool;

/* Load Client ID Response System */
if (isServer) then
{
	ALiVE_clientId = -1;
	"ALiVE_clientIdRequest" addPublicVariableEventHandler
	{
		private ["_clientId"];
		_clientId = owner(_this select 1);
		
		ALiVE_clientId = _clientId;
		_clientId publicVariableClient "ALiVE_clientId";
		
		ALiVE_clientId = -1;
	};
};

/* Load Player-Side Systems */
if (!isDedicated) then
{
	0 spawn
	{
		/* Wait For Initialization */
		waitUntil {!isNull player};
		
		/* Request Client ID */
		if (isServer) then
		{
			ALiVE_clientId = owner(player);
		}
		else
		{
			ALiVE_clientIdRequest = player;
			publicVariableServer "ALiVE_clientIdRequest";
			
			waitUntil {!isNil "ALiVE_clientId"};
		};
		
		/* Load Log-To-Diary System */
		if (ALiVE_logToDiary) then
		{
			if (!(player diarySubjectExists C_DIARY_SUBJECT)) then
			{
				player createDiarySubject [C_DIARY_SUBJECT, C_DIARY_SUBJECT_NAME];
			};
			
			0 spawn
			{
				while {true} do
				{
					if (ALiVE_logToDiary && {(count ALiVE_diaryLogQueue) > 0}) then
					{
						{ // forEach
							player createDiaryRecord [C_DIARY_SUBJECT, ["Diagnostics Log", _x]];
						} forEach ALiVE_diaryLogQueue;
						
						ALiVE_diaryLogQueue = []; // Okay while atomic SQF variables are guaranteed
					};
					
					uiSleep C_DIARY_BUFFER_FLUSH_INTERVAL;
				};
			};
		};
	};
};

/*
	Section: Logging Library Initialization
*/

ALiVE_log_level = "";

/*
	Section: Actor Library Initialization
*/

if (isServer) then
{
	ALiVE_actors_mainGroup = createGroup sideLogic;
	publicVariable "ALiVE_actors_mainGroup";
};

"ALiVE_actors_newMessage" addPublicVariableEventHandler
{
	private ["_val", "_actor"];
	_val = _this select 1;
	_actor = _val select 0;
	
	if (local _actor) then
	{
		+(_val) spawn (_actor getVariable "ALiVE_actors_messageHandler");
	};
};
