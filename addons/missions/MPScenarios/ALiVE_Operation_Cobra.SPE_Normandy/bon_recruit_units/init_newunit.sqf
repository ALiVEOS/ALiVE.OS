_unit = _this select 0;

/*****************************************************************
	following section to run only on server.
	Note: duplicate respective code in the pve in the init.sqf
******************************************************************/
if(isServer) then{
	[_unit] execFSM (BON_RECRUIT_PATH+"unit_lifecycle.fsm");
} else {
	bon_recruit_newunit = _unit;
	publicVariable "bon_recruit_newunit";
};




/*****************************************************************
	Client Stuff
******************************************************************/
_unit addAction ["<t color='#949494'>Dismiss</t>",BON_RECRUIT_PATH+"dismiss.sqf",[],-10,false,true,""];