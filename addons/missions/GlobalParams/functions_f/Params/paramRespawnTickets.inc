/*
	Author: Karel Moricky

	Set respawn tickets for all sides.

	You can optionally set minimum and maximum number of tickets (default is 100 and 1100):
		#define TICKETS_MIN	500
		#define TICKETS_MAX	1500

	Optionally, you can set default value:
		#define TICKETS_DEFAULT	300

	Include this file to description.ext of your mission

	Example:
	class Params
	{
		#include "\a3\Functions_F\Params\paramRespawnTickets.inc"
	};
*/

#ifndef TICKETS_MIN
	#define TICKETS_MIN	100
#endif
#ifndef TICKETS_MAX
	#define TICKETS_MAX	1100
#endif
#ifndef TICKETS_DEFAULT
	#define TICKETS_DEFAULT	-1
#endif

__EXEC(_ticketsStep = TICKETS_MAX * 0.1 - TICKETS_MIN * 0.1;)
__EXEC(_tickets0 = TICKETS_MIN + 0 * _ticketsStep;)
__EXEC(_tickets1 = TICKETS_MIN + 1 * _ticketsStep;)
__EXEC(_tickets2 = TICKETS_MIN + 2 * _ticketsStep;)
__EXEC(_tickets3 = TICKETS_MIN + 3 * _ticketsStep;)
__EXEC(_tickets4 = TICKETS_MIN + 4 * _ticketsStep;)
__EXEC(_tickets5 = TICKETS_MIN + 5 * _ticketsStep;)
__EXEC(_tickets6 = TICKETS_MIN + 6 * _ticketsStep;)
__EXEC(_tickets7 = TICKETS_MIN + 7 * _ticketsStep;)
__EXEC(_tickets8 = TICKETS_MIN + 8 * _ticketsStep;)
__EXEC(_tickets9 = TICKETS_MIN + 9 * _ticketsStep;)
__EXEC(_tickets10 = TICKETS_MIN + 10 * _ticketsStep;)

class RespawnTickets
{
	title = $STR_A3_paramRespawnTickets_title;
	values[] = {
		-1,
		__EVAL(_tickets0),
		__EVAL(_tickets1),
		__EVAL(_tickets2),
		__EVAL(_tickets3),
		__EVAL(_tickets4),
		__EVAL(_tickets5),
		__EVAL(_tickets6),
		__EVAL(_tickets7),
		__EVAL(_tickets8),
		__EVAL(_tickets9),
		__EVAL(_tickets10)
	};
	texts[] = {
		$STR_DISABLED,
		__EVAL(_tickets0),
		__EVAL(_tickets1),
		__EVAL(_tickets2),
		__EVAL(_tickets3),
		__EVAL(_tickets4),
		__EVAL(_tickets5),
		__EVAL(_tickets6),
		__EVAL(_tickets7),
		__EVAL(_tickets8),
		__EVAL(_tickets9),
		__EVAL(_tickets10)
	};
	default = TICKETS_DEFAULT;
	function = "BIS_fnc_paramRespawnTickets";
};