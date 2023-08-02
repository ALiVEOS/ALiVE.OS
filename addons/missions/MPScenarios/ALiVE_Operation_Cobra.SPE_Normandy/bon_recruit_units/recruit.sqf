// by Bon_Inf*

if(not local player) exitWith{};
if((count (units group player) + count bon_recruit_queue) >= bon_max_units_allowed) exitWith {hint "You've reached the max. allowed group size."};


#include "dialog\definitions.sqf"
disableSerialization;


_update_queue = {
	_display = findDisplay BON_RECRUITING_DIALOG;
	_queuelist = _display displayCtrl BON_RECRUITING_QUEUE;
	_queuelist ctrlSetText format["Units queued: %1",count bon_recruit_queue];
};


_display = findDisplay BON_RECRUITING_DIALOG;
_listbox = _display displayCtrl BON_RECRUITING_UNITLIST;
_sel = lbCurSel _listbox; if(_sel < 0) exitWith{};

_unittype = bon_recruit_recruitableunits select _sel;
_typename = lbtext [BON_RECRUITING_UNITLIST,_sel];

_queuepos = 0;
_queuecount = count bon_recruit_queue;
if(_queuecount > 0) then {
	_queuepos = (bon_recruit_queue select (_queuecount - 1)) + 1;
	hint parseText format["<t size='1.0' font='PuristaMedium' color='#ef2525'>%1</t> added to queue.",_typename];
};
bon_recruit_queue = bon_recruit_queue + [_queuepos];

[] call _update_queue;


WaitUntil{_queuepos == bon_recruit_queue select 0};
sleep (1.5 * (_queuepos min 1));
hint parseText format["Processing your <t size='1.0' font='PuristaMedium' color='#ffd800'>%1</t>.",_typename];

sleep 8.5;




/********************* UNIT CREATION ********************/
_unit = group player createUnit [_unittype, [(getPos bon_recruit_barracks select 0) + 10 - random 10,(getPos bon_recruit_barracks select 1) + 10 - random 20,0], [], 0, "FORM"];
_unit setRank "PRIVATE";
[_unit] execVM (BON_RECRUIT_PATH+"init_newunit.sqf");
/*******************************************************/




hint parseText format["Your <t size='1.0' font='PuristaMedium' color='#008aff'>%1</t> %2 has arrived.",_typename,name _unit];
bon_recruit_queue = bon_recruit_queue - [_queuepos];

[] call _update_queue;