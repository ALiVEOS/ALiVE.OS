#include "\x\alive\addons\mil_IED\script_component.hpp"
SCRIPT(bomberOnFrame);

params ["_victim","_bomber","_pos"];

// Blow up bomber
if ((_bomber distance _victim < 8) && (alive _bomber)) then {
    [_bomber, "Alive_Beep", 50] call CBA_fnc_globalSay3d;
    _bomber addRating -2001;
    _bomber playMoveNow "AmovPercMstpSsurWnonDnon";

    [
        {
            private _bomber = _this;

            if ((random 100) > 10) then { // check if bomb goes off
                _bomber disableAI "ANIM";
                _bomber disableAI "MOVE";

                private _shell = [["M_Mo_120mm_AT","M_Mo_120mm_AT_LG","M_Mo_82mm_AT_LG","R_60mm_HE","Bomb_04_F","Bomb_03_F"],[8,4,2,1,1,1]] call BIS_fnc_selectRandomWeighted;
                _shell createVehicle [(getpos _bomber) select 0, (getpos _bomber) select 1,0];

                [{deletevehicle _this}, _bomber, 0.3] call CBA_fnc_waitAndExecute;
            } else { // Bomb malfunction
                [_bomber, _pos] call ALiVE_fnc_doMoveRemote;
            };
            if (ADDON getVariable ["debug", false]) then {
                diag_log format ["BANG! Suicide Bomber %1", _bomber];
                deletemarker _marker;
            };
        },
        _bomber,
        5
    ] call CBA_fnc_waitAndExecute;
} else {
    [
        {
            private _bomber = _this;

            if (ADDON getVariable ["debug", false]) then {
                diag_log format ["Ending Suicide Bomber %1 as out of time or dead.", _bomber];
                private _marker = _bomber getVariable ["marker", ""];
                deletemarker _marker;
            };
            if ((random 100) > 50) then { // Dead man switch
                private _shell = [["M_Mo_120mm_AT","M_Mo_120mm_AT_LG","M_Mo_82mm_AT_LG","R_60mm_HE","Bomb_04_F","Bomb_03_F"],[8,4,2,1,1,1]] call BIS_fnc_selectRandomWeighted;
                _shell createVehicle [(getpos _bomber) select 0, (getpos _bomber) select 1,0];

                [{deletevehicle _this}, _bomber, 0.3] call CBA_fnc_waitAndExecute;
            };
        },
        _bomber,
        1
    ] call CBA_fnc_waitAndExecute;
};