private ["_smoke", "_color"];
_smoke = _this;
_color = switch (typeOf _smoke) do
{
    case "SmokeShell" : { "white" };
    case "SmokeShellRed": { "red" };
    case "SmokeShellGreen": { "green" };
    case "SmokeShellYellow": { "yellow" };
    case "SmokeShellPurple": { "purple" };
    case "SmokeShellBlue": { "blue" };
    case "SmokeShellOrange": { "orange" };
    case "3Rnd_Smoke_Grenade_shell": { "white" };
    case "3Rnd_SmokeRed_Grenade_shell": { "red" };
    case "3Rnd_SmokeGreen_Grenade_shell": { "green" };
    case "3Rnd_SmokeBlue_Grenade_shell": { "blue" };
    case "3Rnd_SmokeOrange_Grenade_shell": { "orange" };
    case "3Rnd_SmokePurple_Grenade_shell": { "purple" };
    case "3Rnd_SmokeYellow_Grenade_shell": { "yellow" };
    case "1Rnd_SmokeBlue_Grenade_shell": { "blue" };
    case "1Rnd_SmokeGreen_Grenade_shell": { "green" };
    case "1Rnd_SmokeOrange_Grenade_shell": { "orange" };
    case "1Rnd_SmokeRed_Grenade_shell": { "red" };
    case "1Rnd_Smoke_Grenade_shell": { "white" };
    case "1Rnd_SmokeYellow_Grenade_shell": { "yellow" };
    // any other smoke (SOG, Spearhead, Global Mobilization, other mods): the colour its class name
    // gives, or failing that the nearest colour to the smoke it makes
    default {
        private _name = toLower typeOf _smoke;
        private _byName = [["red", "red"], ["green", "green"], ["grn", "green"], ["yellow", "yellow"], ["yel", "yellow"],
            ["purple", "purple"], ["violet", "purple"], ["blue", "blue"], ["blu", "blue"], ["orange", "orange"], ["org", "orange"],
            ["black", "black"], ["blk", "black"]] select { (_name find (_x select 0)) >= 0 };
        if (_byName isNotEqualTo []) then { (_byName select 0) select 1 } else {
            private _rgb = (getArray (configFile >> "CfgAmmo" >> typeOf _smoke >> "smokeColor")) select [0, 3];
            if (count _rgb < 3) then { "white" } else {
                private _named = [["white", [1, 1, 1]], ["red", [0.84, 0.14, 0.14]], ["green", [0.21, 0.63, 0.49]],
                    ["yellow", [0.99, 0.86, 0.07]], ["purple", [0.43, 0.14, 0.41]], ["blue", [0.12, 0.19, 1]],
                    ["orange", [0.67, 0.23, 0.1]], ["black", [0.05, 0.05, 0.05]]];
                private _best = ""; private _d = 1e9;
                { private _e = _rgb distance (_x select 1); if (_e < _d) then { _d = _e; _best = _x select 0 } } forEach _named;
                _best
            };
        };
    };
};

_color;
