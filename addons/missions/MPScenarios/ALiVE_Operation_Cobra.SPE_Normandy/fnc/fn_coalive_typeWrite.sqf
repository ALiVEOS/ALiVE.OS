/*
    Description:
        Writing mission information on mission startup.

    Parameter(s):
        NONE

    Returns:
        Effects were started [BOOL]
*/

[] spawn {
    sleep 2;
[ 
 [ 
  ["Operation Cobra", "<t align = 'left' shadow = '1' size = '1' font='Nimbus_Mono'>%1</t><br/>"], 
  ["U.S. VII Corps, Saint-Lo, Normandy, France", "<t align = 'left' shadow = '1' size = '0.7' font='Nimbus_Mono'>%1</t><br/>"], 
  ["Mission: Advance across the Vire river and engage the enemy forces", "<t align = 'left' shadow = '1' size = '0.5' font='Nimbus_Mono'>%1</t><br/>", 15] 
 ] 
] spawn SPE_fnc_typeText_WW2;
};

true
