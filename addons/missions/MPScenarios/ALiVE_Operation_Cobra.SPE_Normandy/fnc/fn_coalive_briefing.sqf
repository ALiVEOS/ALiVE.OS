/*
    Original Author: Wyqer, veteran29
    Date: 2019-07-21

    Description:
        Adds the briefing to the map screen.

    Parameter(s):
        NONE

    Returns:
        Function reached the end [BOOL]
*/

if (!hasInterface) exitWith {true};

// Select "Briefing" by default on the map screen
[] spawn {
    disableSerialization;
    private ["_display"];
    waitUntil {
        _display = uiNamespace getVariable ["RscDiary", displayNull];
        !isNull _display
    };

    private _diaryList = (_display displayCtrl 1001);
    _diaryList lnbSetCurSelRow 1; // Briefing

    private _ca_diaryIndex = (_display displayCtrl 1002);
    _ca_diaryIndex lnbSetCurSelRow 0; // Mission
};


player createDiaryRecord [
    "Diary", ["Coordinating Instructions", localize "STR_SPE_BRIEFING_COALIVE_TACTICAL_OPCOBRA"]
];


player createDiaryRecord [
    "Diary", [localize "STR_A3_Diary_Execution_title", localize "STR_SPE_BRIEFING_COALIVE_EXECUTION_OPCOBRA"]
];


player createDiaryRecord [
    "Diary", [localize "STR_A3_Diary_Mission_title", localize "STR_SPE_BRIEFING_COALIVE_MISSION_OPCOBRA"]
];


player createDiaryRecord [
    "Diary", [localize "STR_A3_Diary_Situation_title", localize "STR_SPE_BRIEFING_COALIVE_SITUATION_OPCOBRA"]
];


player createDiarySubject [
    "ALiVE", "ALiVE Instructions"
];

player createDiaryRecord [
    "ALiVE", ["Commander Actions", localize "STR_SPE_BRIEFING_COALIVE_ALIVEACTIONS_OPCOBRA"]
];

player createDiaryRecord [
    "ALiVE", ["Menu / Interactions", localize "STR_SPE_BRIEFING_COALIVE_ALIVEMENUINTER_OPCOBRA"]
];

player createDiaryRecord [
    "ALiVE", ["Overview", localize "STR_SPE_BRIEFING_COALIVE_ALIVEHOWTO_OPCOBRA"]
];

true
