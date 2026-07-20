// #698: the map-swap engine was promoted to x_lib as ALIVE_fnc_mapControlSwap so every ALiVE tablet
// can share it (and it gained shown/enabled-state preservation there). NEO_fnc_mapControlSwap stays
// as a thin forward so the shipped Combat Support call sites do not need touching.
// Author: Jman
_this call ALIVE_fnc_mapControlSwap
