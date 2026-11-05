#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(readTargetPapers);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_readTargetPapers

Description:
Says who a man is from the Wallet (ID) he carries (ALiVE_fnc_giveTargetPapers), without
the player having to take it: the Check ID action on a body or a prisoner, and Search in
the C2ISTAR soldier menu (A. Ares on Discord, 5 Nov). The same notification as taking it.

With a second argument it only answers whether he can be checked now: he carries a wallet
with an identity on it, and he is dead or held (captive, surrendered, or ACE handcuffed or
surrendering), and the player is within 3 m.

Run where the player is.

Parameters:
Object - The man
Bool - (optional) true to only ask whether he can be checked, default false

Returns:
Bool - whether he carries papers that say who he is (or, asking, whether he can be checked)

Examples:
(begin example)
[cursorObject] call ALiVE_fnc_readTargetPapers;
[cursorObject, true] call ALiVE_fnc_readTargetPapers;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_man", objNull, [objNull]], ["_ask", false, [false]]];

if (isNull _man || {!(_man isKindOf "CAManBase")} || {_man == player}) exitWith { false };
private _identity = _man getVariable "ALiVE_targetIdentity";
if (isNil "_identity" || {!("Wallet_ID" in magazines _man)}) exitWith { false };

if (_ask) exitWith {
    (player distance _man) < 3 && {vehicle _man == _man} && {
        !alive _man || {captive _man} || {_man getVariable ["ALiVE_surrendered", false]}
            || {_man getVariable ["ace_captives_isHandcuffed", false]} || {_man getVariable ["ace_captives_isSurrendering", false]}
    }
};

_identity params ["_name", "_role", ["_arg", ""]];
[localize "STR_ALIVE_TARGETID_TITLE", format [localize "STR_ALIVE_TARGETID_TEXT", _name, format [localize _role, _arg]]] call ALIVE_fnc_sendHint;
true
