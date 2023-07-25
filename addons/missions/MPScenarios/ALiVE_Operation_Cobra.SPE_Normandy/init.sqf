/* 
* Filename:
* init.sqf
*
* Description:
* Executed when mission is started (before briefing screen)
* 
* Created by Jman
* Creation date: 24/07/2023
* 
// ====================================================================================
*/

//Starting Init
["| Operation Cobra - Executing init.sqf..."] call ALiVE_fnc_dump;



// ====================================================================================	
// Disable AI simuation in single player & editor preview
if (!isMultiplayer) then {
	skipTime 9;
	{if (_x != player) then {_x enableSimulation false}} forEach switchableUnits;
};
// ====================================================================================	


if (viewDistance > 1000) then {
	setViewDistance 1000;
};
if ((getObjectViewDistance # 0) > 1000) then {
	setObjectViewDistance 1000;
};




waitUntil { !(isNull player) };

if (side player == RESISTANCE) then {
	BIS_fnc_arsenal_factions = [faction player,"SPE_US_ARMY"]; 
};
	
	
// if (side player == WEST) then {};

// if (isServer) then {};


if (hasInterface) then {

    ["| Operation Cobra - Running ClientInit..."] call ALiVE_fnc_dump;

    [] spawn {

       
        
        _start = time;
        waituntil {(player getvariable ["alive_sys_player_playerloaded",false]) || ((time - _start) > 10)};

				sleep 3;
				playMusic "SPE_HoW_Misc_Daniel_Patras_Theme";
			  10 fadesound 0.9;
        sleep 60;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>OPERATION COBRA</t><br/>";
        _text = format["%1<t>Weapons, ammo and supplies are available in the crates, load up and head out.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
        
         sleep 15;
        
        
        _title = "<t size='1.5' color='#68a7b7' shadow='1'>OPERATION COBRA</t><br/>";
        _text = format["%1<t>Use the mobile respawn Halftrack which can be deployed on the frontline.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
        
        
         sleep 15;
        
        
        _title = "<t size='1.5' color='#68a7b7' shadow='1'>OPERATION COBRA</t><br/>";
        _text = format["%1<t>Deploy to the mobile respawn Halftrack using the flagpole at base.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>OPERATION COBRA</t><br/>";
        _text = format["%1<t>Grab a Radiopack in order to call in air support, artillery or resupplies.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;


        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'OPERATION COBRA</t><br/>";
        _text = format["%1<t>You can use ALiVE Logistics to move supplies by vehicle to other locations.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
    };
};







