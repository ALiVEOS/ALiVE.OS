/*
	Include this file in description.ext of your mission

	Optionally, you can set default value:
		#define DAYTIMEHOUR_DEFAULT	19

	Example:
	class Params
	{
		#include "\a3\Functions_F\Params\paramDaytimeHour.inc"
	};
*/

#ifndef DAYTIMEHOUR_DEFAULT
	#define DAYTIMEHOUR_DEFAULT	5
#endif

class Daytime
{
	title = $STR_a3_cfgvehicles_moduledate_f_arguments_hour_0;
	values[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23};
	texts[] = {"00:00","01:00","02:00","03:00","04:00","05:00","06:00","07:00","08:00","09:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00"};
	default = DAYTIMEHOUR_DEFAULT;
	function = "BIS_fnc_paramDaytime";
};