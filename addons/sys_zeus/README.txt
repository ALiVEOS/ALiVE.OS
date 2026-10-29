ALiVE Zeus modules (sys_zeus)

Optional modules a Zeus can place to drive ALiVE during a mission. Nothing here is needed to
run ALiVE, and Zeus Enhanced is never required:

- With Zeus Enhanced loaded, a module asks for its options in a dialog.
- Plain Zeus gets the same modules with their defaults.

Every request is checked on the server: it must come from a player with Zeus, and the module
says so when the ALiVE module it needs is missing from the mission.

A mission with its own restrictive CfgRemoteExec must allow ALiVE_fnc_zeusRequest (server)
and ALiVE_fnc_zeusFeedback (clients).
