// File: skipTime.sqf
// Count the number of playable units (excluding AI and headless clients)
_playableUnits = (playableUnits - allUnits select {(_x isKindOf "HeadlessClient_F")});

// Check if all playable units are within 100m of the lantern
_nearbyUnits = _playableUnits select {(_x distance _object <= 100)};

if (count _nearbyUnits == count _playableUnits) then {
    skipTime 4;
hint "Time skipped 4 hours.";	
        } else {
           hint "Everyone must be at base to skip time.";
};
