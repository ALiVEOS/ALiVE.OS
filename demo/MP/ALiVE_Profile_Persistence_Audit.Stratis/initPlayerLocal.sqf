waitUntil {!isNull player};
player setVariable ["ALIVE_profileIgnore", true, true];
player allowDamage false;
{
    _x params ["_label", "_operation"];
    player addAction [
        _label,
        {
            params ["_target", "_caller", "_actionID", "_operation"];
            [_operation, _caller] remoteExec ["PA_fnc_request", 2];
        },
        _operation, 1.5, false, true, "", "true"
    ];
} forEach [
    ["PA: 1 - Run Local save/load reproductions", "roundtrip"],
    ["PA: 2 - Reproduce an empty campaign save", "empty"],
    ["PA: 3 - Run isolated Cloud backend reproductions", "cloud"],
    ["PA: 4 - Save fresh fixtures for a mission restart", "save"],
    ["PA: 5 - Verify the last saved baseline", "verify"],
    ["PA: 6 - Spawn restored hook and attrition fixtures", "show"],
    ["PA: Clear this test mission's saved state", "clear"]
];
player createDiaryRecord ["Diary", ["Persistence tests",
    "Run Local tests first, then Cloud tests. Results appear in chat and the server RPT as [PA] PASS/FAIL/BLOCKED.<br/><br/>For a cold load, select Save fresh fixtures, leave using ordinary Abort (do not run ALiVE Save and Exit), and start this same mission again. Verification runs automatically after ALiVE loads.<br/><br/>Simulation stays paused so it cannot repair or change the fixtures before inspection. The Cloud transport is in memory and never contacts War Room."
]];
