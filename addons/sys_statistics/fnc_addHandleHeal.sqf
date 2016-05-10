/*
 * Filename:
 * fnc_addHandleHeal.sqf
 *
 * Description:
 * Adds a HandleHeal EH for the object to the machine locally
 *
 * Created by Tupolov
 * Creation date: 05/05/2014
 *
 * */

// ====================================================================================
// MAIN

#include "script_component.hpp"

private "_player";

_player = _this select 0;

TRACE_1("ADDING HANDLE HEAL:", _this);

_player addEventHandler ["handleHeal", {_this call GVAR(fnc_handleHealEH);}];
