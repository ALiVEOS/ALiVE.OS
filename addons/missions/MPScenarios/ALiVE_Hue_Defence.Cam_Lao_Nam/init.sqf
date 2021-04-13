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
["| The Battle of Hue - Executing init.sqf..."] call ALiVE_fnc_dump;

[] call vn_ms_fnc_enableSOGTraits;

if (isServer) then {

};

if (hasInterface) then {

    ["| The Battle of Hue - Running ClientInit..."] call ALiVE_fnc_dump;

    [] spawn {
        enableRadio false;
        titleText ["The ALiVE Team presents...", "BLACK IN",9999];
        0 fadesound 0;

        playMusic "vn_enemy_territory";

        private ["_cam","_camx","_camy","_camz","_object"];
        _start = time;

        waituntil {(player getvariable ["alive_sys_player_playerloaded",false]) || ((time - _start) > 10)};
        sleep 3;

        _object = player;
        _camx = getposATL player select 0;
        _camy = getposATL player select 1;
        _camz = getposATL player select 2;

        _cam = "camera" CamCreate [_camx -500 ,_camy + 500,_camz+450];

        _cam CamSetTarget player;
        _cam CameraEffect ["Internal","Back"];
        _cam CamCommit 0;

        _cam camsetpos [_camx -15 ,_camy + 15,_camz+3];

        titleText ["A L i V E   |   T H E  B A T T L E  O F  H U E", "BLACK IN",10];

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
	            ["The Battle of Hue"],
	            [format ["Wednesday 31st January 1968. %1%2%3%4h", ["0", ""] select (_hour >= 10), _hour, ["0", ""] select (_minute >= 10), _minute]],
	            ["1st Marine Regiment, Task Force X-Ray, Phu Bai Combat Base, South Vietnam", "<t align = 'left' shadow = '1' size = '0.7'>%1</t><br/><br/>"],
	            ["Target AO: ", "<t align = 'left' shadow = '1' size = '0.7' font='tt2020style_e_vn_bold'>%1</t>"],
	            ["The Imperial City and Citadel of Hue", nil, 3.5]
		        ],
		        [safeZoneX + safeZoneW - _w, _w],
		        [safeZoneY + safeZoneH - _h - 0.05, _h]
		    ] spawn vn_ms_fnc_sfx_typeText;
		};

        sleep 25;

        _cam CameraEffect ["Terminate","Back"];
        CamDestroy _cam;

        sleep 20;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>THE BATTLE OF HUE</t><br/>";
        _text = format["%1<t>Welcome to FOB Phu Bai. Weapons, ammo and supplies are available under the camo netting, load up and head out.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>THE BATTLE OF HUE</t><br/>";
        _text = format["%1<t>Grab an RTO pack with a PRC-77 in order to call in air support, artillery or resupplies.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>THE BATTLE OF HUE</t><br/>";
        _text = format["%1<t>Head north in convoy or by foot. Consolidate and defend Hue</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>THE BATTLE OF HUE</t><br/>";
        _text = format["%1<t>You can use ALiVE Logistics to move supplies by vehicle to other locations. The Duty Officer though will stay at FOB Phu Bai.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
    };
};


