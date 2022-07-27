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
["ALiVE | Erawan Secret War - Executing init.sqf..."] call ALiVE_fnc_dump;

[] call vn_ms_fnc_enableSOGTraits;

if (isServer) then {

};

if (hasInterface) then {

    ["ALiVE | Erawan Secret War - Running ClientInit..."] call ALiVE_fnc_dump;

    [] spawn {
      
        titleText ["The ALiVE Team presents...", "BLACK IN",9999];
        0 fadesound 0;

        private ["_cam","_camx","_camy","_camz","_object"];
        _start = time;

        waituntil {(player getvariable ["alive_sys_player_playerloaded",false]) || ((time - _start) > 10)};
        sleep 3;

   			playMusic "vn_calm_before_the_storm";
   			
        _object = player;
        _camx = getposATL player select 0;
        _camy = getposATL player select 1;
        _camz = getposATL player select 2;

        _cam = "camera" CamCreate [_camx -500 ,_camy + 500,_camz+450];

        _cam CamSetTarget player;
        _cam CameraEffect ["Internal","Back"];
        _cam CamCommit 0;

        _cam camsetpos [_camx -15 ,_camy + 15,_camz+3];

        titleText ["A L i V E   |   E R A W A N", "BLACK IN",10];

        10 fadesound 0.9;
        _cam CamCommit 25;

		[] spawn {
		    sleep 2;
		    // Corner coordinates
    		private _w = 0.95;
    		private _h = 0.55;
		    date params ["", "", "", "_hour", "_minute"];

		    [
		        [
	            ["Erawan Secret War", "<t align = 'left' shadow = '1' size = '1.0' font='tt2020style_e_vn_bold'>%1</t><br/>"],
	            [format ["Sunday 10th July 1960. %1%2%3%4h", ["0", ""] select (_hour >= 10), _hour, ["0", ""] select (_minute >= 10), _minute], "<t align = 'left' shadow = '1' size = '1.0' font='tt2020style_e_vn_bold'>%1</t><br/>"],
	            ["Seal Team Alpha, Camp Striker, Laos", "<t align = 'left' shadow = '1' size = '1.0'>%1</t><br/>"],
                [" "],
	            ["Target AO: ", "<t align = 'left' shadow = '1' size = '1.0' font='tt2020style_e_vn_bold'>%1</t>"],
	            ["Infiltrate POW Camp", "<t align = 'left' shadow = '1' size = '1.0' font='tt2020style_e_vn_bold'>%1</t>", 3.5]
		        ],
		        [safeZoneX + safeZoneW - _w, _w],
		        [safeZoneY + safeZoneH - _h - 0.05, _h]
		    ] spawn vn_ms_fnc_sfx_typeText;
		};

        sleep 25;

        _cam CameraEffect ["Terminate","Back"];
        CamDestroy _cam;

        sleep 20;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>ERAWAN SECRET WAR</t><br/>";
        _text = format["%1<t>Weapons, ammo and supplies are available in the crates, load up and head out.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>ERAWAN SECRET WAR</t><br/>";
        _text = format["%1<t>Grab an RTO pack with a PRC-77 in order to call in artillery support.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

    };
};





