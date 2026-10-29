    private ["_unit", "_text", "_radio","_side"];
    _unit = _this select 0;
    _text = _this select 1;
    _radio = _this select 2;
    // An optional 4th argument names the side the message is for. The server's own respawn
    // notices pass it: they ran with "player" as the speaker, which is nobody on a dedicated
    // server, and nobody's side is UNKNOWN, friendly to no side (measured), so a side's "back
    // on station" and "out of assets" notices reached no one there.
    // A message can come as [stringtable key, arguments...] instead of text, so each player reads
    // it in their own language: it's put together here, on the machine that shows it. (Jman)
    // A detail written as $STR_... (a speed, a mission type) is read in the player's language too,
    // and a detail that is itself [key, arguments...] is put together the same way (a SITREP's ETA).
    private _fnc_words = {
        if (_this isEqualType "") exitWith { if ((_this select [0, 5]) == "$STR_") then { localize (_this select [1]) } else { _this } };
        if (_this isEqualType [] && {_this isNotEqualTo []} && {(_this select 0) isEqualType ""}) exitWith {
            private _args = (_this select [1]) apply { _x call _fnc_words };
            if (_args isNotEqualTo []) then { format ([localize (_this select 0)] + _args) } else { localize (_this select 0) }
        };
        _this
    };
    if (_text isEqualType []) then { _text = _text call _fnc_words };
    _side = if (count _this > 3 && {(_this select 3) isEqualType west}) then {_this select 3} else {side group _unit};

    //enableRadio true;
    //enableSentences true;
    //sleep 1;

    _friendlySides = [];
    {if (_x getfriend (_side) >= 0.6) then {_friendlySides pushback _x}} foreach [WEST,EAST,RESISTANCE,CIVILIAN];

    switch (_radio) do
    {
        case "global" : { _unit globalChat _text; if (!isNull _unit) then { ["", _text] call ALIVE_fnc_radioLog } };
        case "side" : {
            // A player on a friendly side gets it the way they chose for task updates (Addon Options, ALiVE,
            // Game, Task and radio updates): a subtitle or a hint from HQ, or side chat as it always was. (Jman)
            private _style = missionNamespace getVariable ["ALiVE_prefTaskMessages", "chat"];
            if (hasInterface && {!isNull player} && {_style != "chat"} && {!isNil "ALIVE_fnc_taskSubtitle"} && {(side group player) in _friendlySides}) then {
                // one at a time: a SITREP or a CAS run sends several lines seconds apart, and each subtitle or
                // hint would replace the one before it was read
                // (the queue and its reader's flag change only inside isNil, which nothing interrupts)
                isNil {
                    if (isNil "ALiVE_NEO_radioQueue") then { ALiVE_NEO_radioQueue = []; ALiVE_NEO_radioBusy = false };
                    ALiVE_NEO_radioQueue pushBack _text;
                    if !(ALiVE_NEO_radioBusy) then {
                        ALiVE_NEO_radioBusy = true;
                        [] spawn {
                            while { true } do {
                                private _line = nil;
                                isNil { if (ALiVE_NEO_radioQueue isEqualTo []) then { ALiVE_NEO_radioBusy = false } else { _line = ALiVE_NEO_radioQueue deleteAt 0 } };
                                if (isNil "_line") exitWith {};
                                ["HQ", _line] call ALIVE_fnc_taskSubtitle;
                                sleep (((count _line) / 20) max 4 min 10);
                            };
                        };
                    };
                };
            } else {
                {[_x,"HQ"] sideChat _text} foreach _friendlySides;
                if (hasInterface && {!isNull player} && {(side group player) in _friendlySides}) then { ["HQ", _text] call ALIVE_fnc_radioLog };
            };
        };
        case "group" : { _unit groupChat _text; if (hasInterface && {group player == group _unit}) then { ["", _text] call ALIVE_fnc_radioLog } };
        case "vehicle" : { _unit vehicleChat _text; if (hasInterface && {vehicle player == vehicle _unit}) then { ["", _text] call ALIVE_fnc_radioLog } };
        case "sideRadio" : { _unit sideRadio _text; if (hasInterface && {side group player == side group _unit}) then { ["", _text] call ALIVE_fnc_radioLog } };
    };

    //sleep 1;
    //enableSentences false;
    //enableRadio false;


true;
