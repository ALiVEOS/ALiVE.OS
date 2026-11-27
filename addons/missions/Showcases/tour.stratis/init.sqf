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
    player createDiaryRecord ["Diary", ["New in ALiVE 3",
        "Round your start point:<br/>- A FOB Kit: use Deploy FOB on it. The cargo house beside it is a Field HQ for another kit.<br/>- A camping table: recruit soldiers into your group there.<br/>- A mortar: get in it and ask for orders on the ALiVE menu (C2ISTAR) to be given a fire mission.<br/>- A Ground Transport truck on the Combat Support tablet.<br/><br/>Player Tutorial, What's New, walks through each one, and the Field Manual has a page for each."
    ]];

};