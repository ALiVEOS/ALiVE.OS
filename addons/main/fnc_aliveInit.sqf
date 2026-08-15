#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(aliveInit);


/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_aliveInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_alive>

Author:
Wolffy.au
Tupolov
Jman
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_aliveInit

#define DEFAULT_DEBUG "false"
#define DEFAULT_GC_THRESHOLD "100"
#define DEFAULT_GC_INTERVAL "300"
#define DEFAULT_GC_INDIVIDUALTYPES ""

#define MPINTERRUPT 49
#define ABORTBUTTON 104

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// CREATE MODULE IF IT DOES NOT EXIST
// Check to see if module was placed... (might be auto enabled)
if (isnil "_logic") then {
    if (isServer) then {

        // Ensure only one module is used
        if !(isNil QMOD(require)) then {
            _logic = MOD(require);
            ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_REQUIRESALIVE_ERROR1");
        } else {
            _logic = (createGroup sideLogic) createUnit [QMOD(require), [0,0], [], 0, "NONE"];
            MOD(require) = _logic;
        };

        //Push to clients
        PublicVariable QMOD(require);
    };

    TRACE_1("Waiting for object to be ready",true);

    waituntil {!isnil QMOD(require)};

    TRACE_1("Creating class on all localities",true);

    _logic = MOD(require);

};
// Init ALIVE_Requires

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

//Only one init per instance is allowed
if !(isnil {_logic getVariable "initGlobal"}) exitwith {["Require - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_dump};

//Start init
_logic setVariable ["initGlobal", false];

//["%1 - Initialisation started...",_logic] call ALiVE_fnc_Dump;

//Start ALiVE Requires init
_logic setVariable ["init", false];
_logic setVariable ["super", SUPERCLASS];
_logic setVariable ["class", MAINCLASS];
_logic setVariable ["moduleType", QMOD(require)];
_logic setVariable ["startupComplete", false];

MOD(require) = _logic;

//--------------------------------------------------------------------------------------------------------//
// Init base systems on server and client

TRACE_1("Launching Base ALiVE Systems",true);

// Say something during the wait, which used to pass in complete silence.
//
// Starting a mission holds every machine until the server has finished placing units, and
// on a heavy mission that is minutes of a blank screen that reads as a crash.
//
// The engine loading screen this replaces could never carry text. It is drawn outside the
// display system, so it creates no display and no control that could be written to.
//
// ALiVE puts up its own screen instead. It carries text, it comes down under its own power,
// and Escape still reaches the pause menu over it, so Abort and ALiVE's own exit entries
// stay available throughout.
//
// It cannot cover the engine's own mission loading or the briefing map, and nothing can.
// While that screen is up the script scheduler is all but stopped: a loop set to run twice
// a second was measured firing once and then not again for fourteen seconds, resuming the
// instant the mission clock started. So nothing can be drawn there, nothing can fill the
// bar there, and nothing could take that screen down again if we raised one of our own,
// which is what went wrong when that was tried.
//
// A mission quick enough to finish while its briefing is still being read is therefore over
// before anything is seen. The long startups this exists for run far past that and are
// spent standing in the world, which is where it shows and where the waiting actually
// hurts.
// The modules the wait is actually waiting on, listed once and used twice: to say how far
// along it is, and to name what is holding it up. The same list the server waits on further
// down, so the screen can only ever report on things that are genuinely keeping you here.
ALiVE_initGateModules = [
    QMOD(amb_civ_placement), QMOD(mil_placement), QMOD(civ_placement),
    QMOD(civ_placement_custom), QMOD(mil_placement_custom), QMOD(mil_placement_spe),
    QMOD(mil_cqb), QMOD(mil_OPCOM), QMOD(SYS_playeroptions)
];

if (isServer) then {
    [] spawn {
        // How much of the wait is done, measured as the share of those that have finished.
        // Modules a mission has not placed are not counted, exactly as the wait does not
        // count them.
        private _gate = ALiVE_initGateModules;

        // The same ceiling the screens use, and for the same reason. A module that throws before
        // it reports in never clears the signal this waits on, and without a limit this counts
        // entities and broadcasts to every machine once a second for the rest of the session,
        // long after the last screen has given up and stopped listening. Set well beyond the
        // fifteen minutes a screen waits, so it is still feeding them for as long as anyone is
        // actually watching, and stops once nobody is.
        private _deadline = diag_tickTime + 1800;

        while {isNil QMOD(REQUIRE_INITIALISED) && {diag_tickTime < _deadline}} do {
            private _placed = (entities "Module_F") select {(typeOf _x) in _gate};
            private _done = _placed select {_x getVariable ["startupComplete", false]};

            MOD(INIT_PROGRESS) = if (count _placed == 0) then {1} else {
                (count _done) / (count _placed)
            };
            Publicvariable QMOD(INIT_PROGRESS);

            uiSleep 1;
        };
    };
};

if (hasInterface) then {
    // The moment is taken here rather than inside, because the screen scheduler is starved
    // while the engine is still loading and the spawn below has been measured taking nine
    // seconds to reach its first line. Read in there, the count would quietly start late and
    // under-report the wait by however long the machine was busy.
    diag_tickTime spawn {
        disableSerialization;
        private _started = _this;

        // Someone joining a mission that is already running has nothing to wait for. Without
        // this they get a black screen and a finished frame thrown over a live game.
        if (!isNil QMOD(REQUIRE_INITIALISED)) exitWith {};

        // Drawn as our own controls rather than through cutText. cutText pins its text at a
        // fixed point below the middle of the screen and grows downwards from there, and
        // nothing moves that anchor, so a block this tall always sat low and ran off the
        // bottom of the screen. A control of our own can be measured once the text is in it
        // and then placed so the block is truly centred, whatever it is showing at the time.
        waitUntil {!isNull (findDisplay 46)};
        private _display = findDisplay 46;

        // Deliberately larger than the screen, so no aspect ratio leaves an edge uncovered.
        private _back = _display ctrlCreate ["RscText", -1];
        _back ctrlSetBackgroundColor [0, 0, 0, 1];
        _back ctrlSetPosition [safezoneX - 0.5, safezoneY - 0.5, safezoneW + 1, safezoneH + 1];
        _back ctrlCommit 0;

        private _panel = _display ctrlCreate ["RscStructuredText", -1];
        // Explicitly see-through. The class carries its own background colour, which drew a
        // faintly lighter panel over the black behind the text.
        _panel ctrlSetBackgroundColor [0, 0, 0, 0];

        // Taking the screen down does not depend on the loop below surviving to the end.
        // The backdrop is opaque and covers everything, so a fault anywhere in the drawing
        // loop, or a module that never reports itself finished, would leave someone staring
        // at black with only Abort to get out of it. This waits on nothing but the signal
        // and a deadline, and clears the screen either way.
        //
        // It waits longer than the finished frame is left up, so in the ordinary case the
        // loop has already cleared both and this finds nothing to do.
        [_back, _panel] spawn {
            params ["_back", "_panel"];
            disableSerialization;

            // Half an hour, and deliberately far longer than the loop's own ceiling. This is the
            // last resort for the case where the loop itself is gone, so it must never be the
            // thing that decides when the screen clears in the ordinary run of events.
            private _deadline = diag_tickTime + 1800;
            waitUntil {!isNil QMOD(REQUIRE_INITIALISED) || {diag_tickTime > _deadline}};
            // Longer than the loop leaves either of its closing frames up, so the loop always
            // gets to finish its say and this finds both controls already gone.
            uiSleep 10;

            { if (!isNull _x) then { ctrlDelete _x } } forEach [_panel, _back];
        };

        // Put the text in, ask how tall it came out, then place it so that height is centred
        // on the screen. The height can only be asked for once the text is in and the control
        // already has its width, because the answer depends on where the lines wrap.
        private _show = {
            params ["_ctrl", "_body"];
            _ctrl ctrlSetPosition [safezoneX, safezoneY, safezoneW, safezoneH];
            _ctrl ctrlCommit 0;
            _ctrl ctrlSetStructuredText parseText _body;
            private _height = ctrlTextHeight _ctrl;
            // If the height comes back as nothing, fall back to the full screen rather than
            // placing a block of no height, which would show nothing at all.
            if (_height <= 0) then { _height = safezoneH };
            // Never start above the top of the screen. A block taller than the screen would
            // otherwise be centred by losing its head, and the logo is the first thing to go.
            private _top = (safezoneY + ((safezoneH - _height) / 2)) max safezoneY;
            _ctrl ctrlSetPosition [safezoneX, _top, safezoneW, _height];
            _ctrl ctrlCommit 0;
        };

        // Where you are and who you are with. None of this changes while the wait runs, so
        // it is worked out once here rather than twice a second, and it gives someone
        // something to read that is about their mission rather than about the machine.
        private _terrain = getText (configFile >> "CfgWorlds" >> worldName >> "description");
        if (_terrain == "") then { _terrain = worldName };

        // The plain form. nearestLocations wants a list of types and throws a config error
        // popup for one the terrain does not define, so ask for the closest of anything.
        private _where = "";
        private _loc = nearestLocation [getPosATL player, ""];
        if (!isNull _loc && {text _loc != ""}) then { _where = format ["near %1", text _loc] };

        private _sideName = switch (side group player) do {
            case west:       { "BLUFOR" };
            case east:       { "OPFOR" };
            case resistance: { "Independent" };
            case civilian:   { "Civilian" };
            default          { "" };
        };

        private _force = getText (configFile >> "CfgFactionClasses" >> (faction player) >> "displayName");
        if (_force == "") then { _force = faction player };
        if (_sideName != "") then { _force = format ["%1 (%2)", _force, _sideName] };

        private _orientation = [_terrain, _where, _force] select {_x != ""};
        private _orientationText = _orientation joinString "   |   ";

        // When this machine first saw each progress line, so it can be dropped once it stops
        // being news. Timed here rather than where it is raised, because the server and this
        // machine do not share a clock and the difference would show as lines expiring early
        // or never expiring at all.
        private _activitySeen = [];

        // How long anyone is asked to look at an opaque screen over a world that is usually
        // already playable. Reported from a live session: a placement module threw while starting
        // up, so it never said it had finished, and the screen stayed. The player could fire his
        // gun and went into Zeus to escape it, which is the useful part of the report, because
        // the backstop above would have cleared it eventually and he did not wait. Half an hour
        // is not a rescue if nobody is willing to sit through it.
        //
        // Fifteen minutes against a slowest measured start of eight and a half, so a genuinely
        // slow machine still finishes on its own. Cutting a real start short costs little: this
        // only takes the screen away, nothing here stops the modules, and they carry on setting
        // the mission up behind it.
        private _deadline = diag_tickTime + 900;

        while {isNil QMOD(REQUIRE_INITIALISED) && {diag_tickTime < _deadline}} do {
            private _busy = [];
            if (!isNil "ALiVE_initRunning") then { _busy = +ALiVE_initRunning };

            // Name only what is actually keeping you here. Plenty of other modules are
            // starting up at the same time, but the wait does not depend on them and they
            // carry on quietly after it ends, so naming one would point at something that
            // is not the reason and would disagree with the count beside it.
            //
            // Two of the same kind are tracked separately but named once.
            private _gateNames = [];
            if (!isNil "ALiVE_initGateModules") then { _gateNames = ALiVE_initGateModules };

            private _names = [];
            private _others = [];
            {
                if (_x isEqualType [] && {count _x > 1}) then {
                    if ((_x select 0) in _gateNames) then {
                        _names pushBackUnique (_x select 1);
                    } else {
                        _others pushBackUnique (_x select 1);
                    };
                };
            } forEach _busy;

            // If none of the modules the wait depends on is actually running, name whatever is.
            //
            // One the wait does not count can still hold everyone up, by sitting ahead of one it
            // does. Modules start in priority order, so the air commander at 190 runs before
            // player options at 200, and player options is the last thing the wait waits for.
            // Measured on Cam Lao Nam: the air commander took seventy seconds while the screen
            // sat at 92 per cent naming player options, which had not started and which takes a
            // tenth of a second once it does. The share done was right; the name beside it was
            // not.
            if (_names isEqualTo []) then { _names = _others };

            private _what = "Getting started";
            if (count _names > 0) then {
                // Capped for height. Five names plus everything else runs off the bottom of
                // the screen, and the ones past the first few are not what anyone is reading.
                if (count _names > 3) then {
                    private _rest = count _names - 3;
                    _names resize 3;
                    _names pushBack format ["and %1 more", _rest];
                };
                _what = _names joinString "<br />";
            };

            private _done = 0;
            if (!isNil QMOD(INIT_PROGRESS)) then { _done = MOD(INIT_PROGRESS) };
            // Built here rather than in the line below, because a per cent sign sitting next
            // to a placeholder inside format is asking to be read as one.
            private _percentText = (str (round (_done * 100))) + "%";

            // A bar built from a row of small blocks, filled ones in amber and the rest in
            // slate. Blocks rather than one stretched bar because the width asked for on an
            // image here is ignored: the texture is square and is scaled from its height, so
            // one block came out the same small square whatever width it was given. A row of
            // them is the length the bar actually needs, and it reads as a gauge.
            private _segments = 12;
            private _filled = round (_segments * _done);

            private _bar = "";
            for "_i" from 1 to _segments do {
                private _colour = if (_i <= _filled) then {
                    "color(0.918,0.690,0.290,1)"
                } else {
                    "color(0.157,0.212,0.255,1)"
                };
                _bar = _bar + format ["<img image='#(argb,8,8,3)%1' size='1.1'/>", _colour];
                if (_i < _segments) then {
                    // A see-through block for the gap, so the blocks read separately rather
                    // than running into one solid line.
                    _bar = _bar + "<img image='#(argb,8,8,3)color(0,0,0,0)' size='0.45'/>";
                };
            };

            // Read as minutes once there is a minute to read. A bare count of seconds stops
            // meaning much to anyone once it is into the hundreds.
            private _elapsed = floor (diag_tickTime - _started);
            private _mins = floor (_elapsed / 60);
            private _secs = _elapsed mod 60;

            private _timeText = format ["%1 seconds", _secs];
            if (_mins > 0) then {
                _timeText = format ["%1 minute%2 %3 seconds",
                    _mins, ["", "s"] select (_mins > 1), _secs];
            };

            // How many units have been put into the world so far. A figure that climbs the
            // whole way through says the work is moving even while the share done cannot,
            // which is most of a long startup.
            private _placedText = "";
            if (!isNil "ALiVE_profileHandler") then {
                private _profiles = [ALiVE_profileHandler, "getProfiles"] call ALiVE_fnc_profileHandler;
                if (!isNil "_profiles" && {_profiles isEqualType []} && {count _profiles > 2}) then {
                    // Named for what they are. A profile is a group or a vehicle, and
                    // "units" would mean nothing to whoever is reading this.
                    _placedText = format ["%1 groups and vehicles placed so far", count (_profiles select 2)];
                };
            };

            // Both figures on one line, which costs one line of height rather than two.
            if (_placedText != "") then {
                _timeText = format ["%1   |   %2", _timeText, _placedText];
            };

            // What has been happening, and anything that went wrong with it. All of this is
            // already in the log, but nobody is reading the log while they are sat waiting.
            //
            // Red for something that stopped, amber for something that carried on regardless,
            // grey for ordinary progress. Painting all three red said a mission was broken
            // when it was merely busy.
            //
            // Faults sit above the grey, and are held for the whole of startup rather than
            // rotated. Ordinary progress underneath churns several times a second, and if the
            // two shared a list a fault would be gone before it could be read.
            private _warnText = "";
            private _lines = [];

            if (!isNil "ALiVE_initWarnings") then {
                {
                    // Paired as severity and message. A bare string is read as the milder of
                    // the two, so an older entry can never claim to be worse than it is.
                    private _severity = "warning";
                    private _message = _x;
                    if (_x isEqualType [] && {count _x > 1}) then {
                        _severity = _x select 0;
                        _message = _x select 1;
                    };

                    // Same size as the ordinary lines below. Colour alone carries the
                    // difference, which is enough, and it keeps the block from changing
                    // height as faults come and go.
                    private _colour = if (_severity == "error") then {"#d24b47"} else {"#f2a541"};
                    _lines pushBack format ["<t align='center' size='0.95' color='%1'>%2</t>", _colour, _message];
                } forEach ALiVE_initWarnings;
            };

            // Greyer than the rest, so the running commentary sits clearly beneath the things
            // that actually want reading.
            //
            // Dropped once it has been up for twenty seconds. A module that started that long
            // ago has stopped being news, and holding it there made the screen look stuck when
            // a slow module left nothing else to say for minutes at a time. Faults are not
            // aged out this way: those are kept for the whole of startup on purpose.
            if (!isNil "ALiVE_initActivity") then {
                {
                    private _line = _x;
                    if ((_activitySeen findIf {(_x select 0) == _line}) < 0) then {
                        _activitySeen pushBack [_line, diag_tickTime];
                    };
                } forEach ALiVE_initActivity;

                // The list only ever holds the handful of lines still on screen plus those
                // that have aged out, so it is trimmed rather than allowed to grow all run.
                while {count _activitySeen > 30} do { _activitySeen deleteAt 0 };

                {
                    private _line = _x;
                    private _at = _activitySeen findIf {(_x select 0) == _line};
                    if (_at >= 0 && {(diag_tickTime - ((_activitySeen select _at) select 1)) < 20}) then {
                        _lines pushBack format ["<t align='center' size='0.95' color='#8fa0ab'>%1</t>", _line];
                    };
                } forEach ALiVE_initActivity;
            };

            if (count _lines > 0) then {
                _warnText = "<br /><br />" + (_lines joinString "<br />");
            };

            [_panel, format [
                "<t align='center'><img image='\x\alive\addons\main\logo_alive.paa' size='14'/></t>"
                + "<br /><br /><t align='center' size='1.7' color='#e4ebf0'>Preparing the battlefield</t>"
                + "<br /><t align='center' size='1.05' color='#8fa0ab'>Placing units and setting up the commanders. Large missions take a few minutes.</t>"
                + "<br /><t align='center' size='1' color='#57b98a'>%6</t>"
                + "<br /><br /><t align='center' size='1.15' color='#f2a541'>WAITING ON</t>"
                + "<br /><t align='center' size='1.15' color='#e4ebf0'>%1</t>"
                + "<br /><br /><t align='center'>%2</t>"
                + "<br /><t align='center' size='1.4' color='#f2a541'>%3</t>"
                + "<br /><t align='center' size='1.05' color='#8fa0ab'>%4</t>"
                + "%5",
                _what,
                _bar,
                _percentText,
                _timeText,
                _warnText,
                _orientationText
            ]] call _show;

            uiSleep 0.5;
        };

        // Finish on something. The loop above ends the instant the wait is over, so without
        // this the screen simply vanishes at whatever figure it had reached, which reads as
        // giving up rather than being done. A moment at full is what tells you the work
        // finished rather than stopped.
        private _elapsedEnd = floor (diag_tickTime - _started);
        private _minsEnd = floor (_elapsedEnd / 60);
        private _secsEnd = _elapsedEnd mod 60;

        private _fullBar = "";
        for "_i" from 1 to 12 do {
            _fullBar = _fullBar + "<img image='#(argb,8,8,3)color(0.341,0.725,0.541,1)' size='1.1'/>";
            if (_i < 12) then {
                _fullBar = _fullBar + "<img image='#(argb,8,8,3)color(0,0,0,0)' size='0.45'/>";
            };
        };

        private _tookText = format ["took %1 seconds", _secsEnd];
        if (_minsEnd > 0) then {
            _tookText = format ["took %1 minute%2 %3 seconds",
                _minsEnd, ["", "s"] select (_minsEnd > 1), _secsEnd];
        };

        // Only say it is ready if it actually is. Coming off the ceiling above means something
        // never finished, and telling someone the mission is set up when a module stopped part
        // way through would send them looking for a fault in the wrong place.
        if (isNil QMOD(REQUIRE_INITIALISED)) then {
            // Name it on screen rather than sending someone to a log for it. This machine already
            // holds the answer, and the wait above has been showing it every half second. "Military
            // Placement never finished" is something a player can report; "a module stopped, go and
            // read a log" is how a report never gets made.
            private _stuck = "something that did not give its name";
            if (!isNil "ALiVE_initRunning") then {
                private _stillGoing = [];
                {
                    if (_x isEqualType [] && {count _x > 1}) then {
                        _stillGoing pushBackUnique (_x select 1);
                    };
                } forEach ALiVE_initRunning;
                if !(_stillGoing isEqualTo []) then { _stuck = _stillGoing joinString ", " };
            };

            [_panel, format [
                "<t align='center'><img image='\x\alive\addons\main\logo_alive.paa' size='14'/></t>"
                + "<br /><br /><t align='center' size='1.7' color='#f2a541'>Gave up waiting</t>"
                + "<br /><br /><t align='center' size='1.05' color='#8fa0ab'>This never reported that it had finished</t>"
                + "<br /><t align='center' size='1.15' color='#e4ebf0'>%1</t>"
                + "<br /><br /><t align='center' size='1.05' color='#8fa0ab'>The screen is coming down rather than keeping you here. Parts of the mission may not be set up, and it is worth reporting.</t>"
                + "<br /><br /><t align='center' size='1.05' color='#8fa0ab'>%2</t>",
                _stuck,
                _tookText
            ]] call _show;

            ["ALiVE startup screen gave up after %1 - still waiting on: %2", _tookText, _stuck] call ALiVE_fnc_dump;

            uiSleep 6;
        } else {
            [_panel, format [
                "<t align='center'><img image='\x\alive\addons\main\logo_alive.paa' size='14'/></t>"
                + "<br /><br /><t align='center' size='1.7' color='#57b98a'>Ready</t>"
                + "<br /><t align='center' size='1.05' color='#8fa0ab'>The mission is set up. Good hunting.</t>"
                + "<br /><br /><t align='center'>%1</t>"
                + "<br /><t align='center' size='1.4' color='#57b98a'>%3</t>"
                + "<br /><t align='center' size='1.05' color='#8fa0ab'>%2</t>",
                _fullBar,
                _tookText,
                "100%"
            ]] call _show;

            uiSleep 1.5;
        };

        // Guarded the same way the backstop above guards its own removal. Either of these can
        // already be gone, and asking a null control to delete itself is an error rather than a
        // quiet no-op.
        { if (!isNull _x) then { ctrlDelete _x } } forEach [_panel, _back];
    };
};

ALiVE_lastFrameCheckTime = time;

// NewsFeed
[] spawn ALiVE_fnc_newsFeedInit;

// Admin Actions
if !(_logic getVariable ["ALIVE_DISABLEADMINACTIONS", false]) then {
    [] spawn ALiVE_fnc_adminActionsInit;
};

// Advanced Markers
if !(_logic getVariable ["ALIVE_DISABLEMARKERS", false]) then {
    [] spawn ALIVE_fnc_spotrepInit;
    [] spawn ALiVE_fnc_markerInit;
};

// Player Logistics
[] spawn ALiVE_fnc_logisticsInit;

// Pause Modules
if (_logic getVariable ["ALIVE_PAUSEMODULES", false]) then {
    call ALiVE_fnc_pauseModulesAuto;
};

// Garbage Collector
private "_GC";
_GC = [nil, "create"] call ALiVE_fnc_GC;
_GC setVariable ["debug", _logic getVariable ["debug", DEFAULT_DEBUG]];
_GC setVariable ["ALiVE_GC_INTERVAL", _logic getVariable ["ALiVE_GC_INTERVAL", DEFAULT_GC_INTERVAL]];
_GC setVariable ["ALiVE_GC_THRESHHOLD", _logic getVariable ["ALiVE_GC_THRESHHOLD", DEFAULT_GC_THRESHOLD]];
_GC setVariable ["ALiVE_GC_INDIVIDUALTYPES", _logic getVariable ["ALiVE_GC_INDIVIDUALTYPES", DEFAULT_GC_INDIVIDUALTYPES]];
[_GC, "init"] spawn ALiVE_fnc_GC;

//---------------------------------------------------------------------------------------------------------//

// Only on Server
if (isServer) then {
    //Sets global type of Versioning (Kick or Warn)
    MOD(VERSIONINGTYPE) = _logic getvariable [QMOD(VERSIONING),"warning"];
    Publicvariable QMOD(VERSIONINGTYPE);

    //Enables/Disables SP saving possibility, default value true due to out of mem crashes
    MOD(DISABLESAVE) = _logic getvariable [QMOD(DISABLESAVE),"true"];
    Publicvariable QMOD(DISABLESAVE);

    //Activates dynamic AI distribution to all available headless clients
    MOD(AI_DISTRIBUTION) = ((_logic getvariable [QMOD(AI_DISTRIBUTION),"false"]) == "true");
    MOD(AI_DISTRIBUTION) spawn ALiVE_fnc_AI_Distributor;

    MOD(TABLET_MODEL) = _logic getvariable [QMOD(TABLET_MODEL), "Tablet01"];
    Publicvariable QMOD(TABLET_MODEL);

    // Event Log
    ALIVE_eventLog = [nil, "create"] call ALIVE_fnc_eventLog;
    [ALIVE_eventLog, "init"] call ALIVE_fnc_eventLog;
    [ALIVE_eventLog, "debug", false] call ALIVE_fnc_eventLog;

    //Waiting for the mandatory modules below, mind that not all modules need to be initialised before mission start
    waitUntil {
        [
            QMOD(amb_civ_placement),
            QMOD(mil_placement),
            QMOD(civ_placement),
            QMOD(civ_placement_custom),
            QMOD(mil_placement_custom),
            QMOD(mil_placement_spe),
            QMOD(mil_cqb),
            QMOD(mil_OPCOM),
            QMOD(SYS_playeroptions)
        ] call ALiVE_fnc_isModuleInitialised;
    };
    
    
    //This is the last module init to be run, therefore indicates that init of the defined modules above has passed on server
    MOD(REQUIRE_INITIALISED) = true;
    Publicvariable QMOD(REQUIRE_INITIALISED);

    _logic setVariable ["init", true, true];
};

// Only on clients
if (hasInterface) then {
    waituntil {!isnil QMOD(DISABLESAVE)}; // Wait for global var to be set on Server

    if (MOD(DISABLESAVE) == "true") then {enableSaving [false, false]};

    if (isMultiplayer) then {

        private _id = [1, [false, false, false],{
            // Add hook to abort button

            [] spawn {
                private _wait = time + 10;

                waitUntil {
                    LOG(str ( (findDisplay MPINTERRUPT) displayCtrl ABORTBUTTON ));
                    str ((findDisplay MPINTERRUPT) displayCtrl ABORTBUTTON) != "No control" || time > _wait
                };
                ((findDisplay MPINTERRUPT) displayCtrl ABORTBUTTON) ctrlAddEventHandler ["ButtonClick", {

                    // ALiVE Abort Code
                    private ["_name","_uid","_id","_shotsFired"];
                    _id = player;
                    _name = name player;
                    _uid = getPlayerUID player;

                    ["Exit - Exit Player id: %1 name: %2 uid: %3",_id,_name,_uid] call ALiVE_fnc_dump;

                    //["STATS ENABLED: %1",MOD(sys_statistics_ENABLED)] call ALiVE_fnc_dump;

                    if (!isNil QMOD(sys_statistics) && (MOD(sys_statistics_ENABLED))) then {
                        ["Exit - Player Stats OPD"] call ALiVE_fnc_dump;

                        if (!isNil "ALIVE_sys_statistics_playerShotsFired") then {

                            // diag_log str(ALIVE_sys_statistics_playerShotsFired);

                            // Send the player's shots fired data to the server and add it to the hash
                            // [[_uid, ALIVE_sys_statistics_playerShotsFired],"ALiVE_fnc_updateShotsFired", false, false] call BIS_fnc_MP;
                            [_uid, ALIVE_sys_statistics_playerShotsFired] remoteExec ["ALiVE_fnc_updateShotsFired", 2];
                        };

                        // Stats module onPlayerDisconnected call
                        [[_id, _name, _uid],"ALIVE_fnc_stats_onPlayerDisconnected", false, false] call BIS_fnc_MP;

                    };

                    if (["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) then {

                        ["Exit - Player Profile Handler OPD"] call ALiVE_fnc_dump;
                        // Profiles module onPlayerDisconnected call
                        [[_id, _name, _uid],"ALIVE_fnc_profile_onPlayerDisconnected", false, false] call BIS_fnc_MP;

                    };
                    ["Exit - [ABORT] Ending mission"] call ALiVE_fnc_dump;
                }];
                ["has hooked abort button: %1", player] call ALiVE_fnc_dump;
            };
        }] call CBA_fnc_addKeyHandler;
    };
};

waitUntil {!(isNil QMOD(REQUIRE_INITIALISED))};

// Nothing to close here any more. ALiVE puts up its own startup screen further up and
// takes it down itself on this same signal. Closing the engine screen that is no longer
// raised prints "Loading screen did not start yet" across the bottom of the screen, which
// is worse than the silence it replaced. The saved data loading raises and closes its own
// engine screen inside mil_opcom, so nothing here is covering for it either.

// Indicate Init is finished on server
if (isServer) then {
    _logic setVariable ["startupComplete", true, true];
};

//["%1 - Initialisation Completed...",MOD(require)] call ALiVE_fnc_Dump;
_logic setVariable ["bis_fnc_initModules_activate",true];

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;

["Global INIT COMPLETE"] call ALiVE_fnc_dump;
[false,"ALiVE Global Init Timer Complete","INIT"] call ALIVE_fnc_timer;
[" "] call ALIVE_fnc_dump;