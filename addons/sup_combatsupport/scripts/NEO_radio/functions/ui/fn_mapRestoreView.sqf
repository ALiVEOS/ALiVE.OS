// #698: the feedback view-restore was promoted to x_lib as ALIVE_fnc_mapRestoreView so every ALiVE
// tablet can share it. NEO_fnc_mapRestoreView stays as a thin forward so the shipped Combat Support
// call sites do not need touching.
// Author: Jman
_this call ALIVE_fnc_mapRestoreView
