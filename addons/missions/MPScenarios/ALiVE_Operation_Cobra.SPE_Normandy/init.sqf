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

// Initialize SPE Function to draw frontline on map
[
  call compile preprocessFileLineNumbers "scripts\frontline_data.sqf"
] call SPE_MISSIONUTILITYFUNCTIONS_fnc_generateFrontline;

//Starting Init
["| Operation Cobra - Executing init.sqf..."] call ALiVE_fnc_dump;

// ====================================================================================	
// Disable AI simuation in single player & editor preview
if (!isMultiplayer) then {
	skipTime 9;
	{if (_x != player) then {_x enableSimulation false}} forEach switchableUnits;
};
// ====================================================================================	
//Set default view distance for players

if (viewDistance > 650) then {
	setViewDistance 650;
};
if ((getObjectViewDistance # 0) > 650) then {
	setObjectViewDistance 650;
};

setTerrainGrid 3.125;

waitUntil { !(isNull player) };
//Restrict Arsenal to US equipement only
if (side player == RESISTANCE) then {
	BIS_fnc_arsenal_factions = [faction player,"SPE_US_ARMY"]; 
};

//Initialize various scripts
[] execVM "bon_recruit_units\init.sqf";
[] execVM "Scripts\Earplugs.sqf";
[] execVM "Scripts\SquadResetInit.sqf";

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

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>OPERATION COBRA</t><br/>";
        _text = format["%1<t>You can use ALiVE Logistics to move supplies by vehicle to other locations.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
    };
};

