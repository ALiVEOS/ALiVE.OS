#ifndef execNow
#define execNow call compile preprocessfilelinenumbers
#endif

//Starting Init
["ALiVE | Getting Started - Executing init.sqf..."] call ALiVE_fnc_Dump;

/////////////////////
// Init server
/////////////////////

if (isServer) then {

};


/////////////////////
// Init clients
/////////////////////

if (hasInterface) then {

    ["ALiVE | Quick Start APEX - Running ClientInit..."] call ALiVE_fnc_Dump;

    player createDiaryRecord ["Diary", ["Mission",
"<font size='18'>COMMANDER'S INTENT</font><br />Draxl Company, NRF16 are established at <marker name='respawn_west'>FOB JOHNSTON</marker>. Commander’s Intent is for the Company Force Recon Team, call sign RAIDER ONE, to destroy weapons and materiel throughout the Area of Operations in order to disrupt enemy operations.<br />
<br />
<font size='18'>TASK ORG</font><br />
Force Recon Team (RAIDER-ONE) has Hunter MRAP, AH-6 Light Utility Helicopter, UAVs and assault boats available to deploy as the local commander sees fit.<br />
    <br />
EAGLE-ONE (AH-99) and EAGLE-TWO (V-44) attack aircraft are on call for Close Air Support.<br />
    <br />
RODEO-TWO (UH-80) and RODEO-THREE (CH-67) medium-heavy utility helicopters are on call for transport and logistics tasks.<br />
<br />
<font size='18'>COORD</font><br />
NRF SIGINT will provide periodic updates on suspected enemy activity via map overlay.<br />
    <br />
Local Comd has full tactical autonomy to conduct operations as he sees fit but may request specific taskings from CROSSROAD via the Command Tablet uplink.<br />
    <br />
Logistics Demands may be submitted to CROSSROAD for resupply of equipment and Combat Supplies.<br />
    <br />
Battle Casualty Replacements (including respawn) will arrive at the FOB.<br />
    <br />
Recon team is encouraged to submit SITREPs, SPOTREPs and Patrol Reports via the Command Tablet in order to facilitate Command and Control.<br />
    <br />
<font size='18'>ADMINISTRATION</font><br />
Zeus access is available for Local Comd.<br />
Administration Actions are available for Local Comd."
    ]];

        player createDiaryRecord ["Diary", ["Situation",
"<font size='18'>HQ NATO RESPONSE FORCE 16</font><br />
<br />
FOB JOHNSTON, BALA AIRFIELD, SW TANOA, GR 021035<br />
<br />
Weather: Clear. Visibility 2km+. First Light 0630<br />
<br />
<font size='18'>ENEMY FORCES</font><br />
Intel indicates that a CSAT Combined Arms Armoured Battalion has occupied strategic locations around the main island of Tanoa. The main body of forces are established in defensive positions in the vicinity of vital logistics hubs, including Aeroport de Tanoa in the south and La Rochelle Aerodrome and Blue Pearl Industrial Port in the North East. In the south island St George airstrip and the bridge crossing at Harcourt are also occupied. SIGINT indicates that enemy HQ is likely to be in the vicinity of Georgetown and subsequently heavily defended.<br />
    <br />
CSAT are supported by the local Syndikat faction, believed to be in approx Company strength but spread thinly across the island. Their modus operandi is to occupy civilian establishments from where they establish points of control and act as a force multiplier for CSAT.<br />
    <br />
CIVPOP is present in small numbers and are mostly those that are too afraid to leave their homes and belongings. They do not pose a threat and are largely ambivalent to local and NATO forces. It goes without saying, avoid civilian casualties.    <br />    <br />
<font size='18'>FRIENDLY FORCES</font><br />
NATO Response Force 16 consists of a NATO Combined Arms Armoured Company (Draxl Company - HQ callsign CROSSROAD), including special forces reconnaissance elements (RAIDER), close air (EAGLE) and rotary wing support units (RODEO).<br />
<br />
NATO forces are located at the <marker name='respawn_west'>Bala Airstrip</marker>, which has been secured as a ""beachhead"" onto the Horizon Islands. The company size force will secure and consolidate their position around Bala Airstrip, while special forces elements and support units look to opportunistically disrupt OPFOR operations on the main island.
"]];

    player createDiaryRecord ["Diary", ["Overview",
        "NATO forces must intervene in the widening insurgency situation on the Horizon Islands. NATO has established a <marker name='respawn_west'>FOB</marker> in the SW of Tanoa. Lead your CTRG team in distrupting Syndikat and CSAT as they try to secure the main island."
    ]];

    //Intro
    [] spawn {
        enableRadio false;
        titleText ["The ALiVE Team presents...", "BLACK IN",9999];
        0 fadesound 0;

        playMusic "AmbientTrack01_F_EXP";

        private ["_cam","_camx","_camy","_camz","_object"];
        _start = time;

        waituntil {(player getvariable ["alive_sys_player_playerloaded",false]) || ((time - _start) > 20)};
        sleep 10;

        _object = player;
        _camx = getposATL player select 0;
        _camy = getposATL player select 1;
        _camz = getposATL player select 2;

        _cam = "camera" CamCreate [_camx -500 ,_camy + 500,_camz+450];

        _cam CamSetTarget player;
        _cam CameraEffect ["Internal","Back"];
        _cam CamCommit 0;

        _cam camsetpos [_camx -15 ,_camy + 15,_camz+3];

        titleText ["A L i V E   |   G E T T I N G  S T A R T E D", "BLACK IN",10];
        10 fadesound 0.9;
        _cam CamCommit 20;
        sleep 5;
        sleep 15;

        _cam CameraEffect ["Terminate","Back"];
        CamDestroy _cam;

        sleep 1;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>GETTING STARTED</t><br/>";
        _text = format["%1<t>A simple mission that follows the quick start guide for ALiVE usage.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;



        _title = "<t size='1.5' color='#68a7b7' shadow='1'>GETTING STARTED</t><br/>";
        _text = format["%1<t>Combat support CAS and Transport is available, grab an ALiVE tablet item from a support supply box to access combat support and C2ISTAR assets.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>GETTING STARTED</t><br/>";
        _text = format["%1<t>Tanoa has been overwhelmed by CSAT forces following an insurgency by Syndikat. Take back control of the Horizon Islands!</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
        enableRadio true;
    };
};
