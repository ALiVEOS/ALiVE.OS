#ifndef execNow
#define execNow call compile preprocessfilelinenumbers
#endif

//Starting Init
["| Tour - Executing init.sqf..."] call ALiVE_fnc_dump;

/////////////////////
// Init server
/////////////////////

if (isServer) then {

};


/////////////////////
// Init clients
/////////////////////

if (hasInterface) then {

    ["| Tour - Running ClientInit..."] call ALiVE_fnc_dump;

    player createDiaryRecord ["Diary", ["ALIVE Tour",
        "Welcome to the ALiVE Tour. Discover the technology, modules, and usage of ALiVE. Information topics will be created around your player. Walk towards a topic you wish to learn more about."
    ]];

};