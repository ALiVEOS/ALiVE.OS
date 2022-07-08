/* 
* Filename:
* init.sqf
* Description:
* Executed when mission is started (before briefing screen)
* 
* Creation date: 05/04/2021
* 
* */
// ====================================================================================


/* 
* Filename:
* init.sqf
*
* Description:
* Executed when mission is started (before briefing screen)
* 
* Created by Jman
* Creation date: 05/04/2021
* 
// ====================================================================================
*/

//Starting Init
["| Erawan Secret War - Executing init.sqf..."] call ALiVE_fnc_dump;

[] call vn_ms_fnc_enableSOGTraits;


if (isServer) then {

};

if (hasInterface) then {

    ["| Erawan Secret War - Running ClientInit..."] call ALiVE_fnc_dump;

    [] spawn {
     //   enableRadio false;
       
        
        _start = time;
        waituntil {(player getvariable ["alive_sys_player_playerloaded",false]) || ((time - _start) > 10)};

				sleep 3;
				playMusic "vn_deadly_jungle";
			  10 fadesound 0.9;
        sleep 60;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>ERAWAN SECRET WAR</t><br/>";
        _text = format["%1<t>Weapons, ammo and supplies are available in the crates, load up and head out.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>ERAWAN SECRET WAR</t><br/>";
        _text = format["%1<t>Grab an RTO pack with a PRC-77 in order to call in air support, artillery or resupplies.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;


        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>ERAWAN SECRET WAR</t><br/>";
        _text = format["%1<t>You can use ALiVE Logistics to move supplies by vehicle to other locations. The Duty Officers will stay at the FOBs</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
    };
};





