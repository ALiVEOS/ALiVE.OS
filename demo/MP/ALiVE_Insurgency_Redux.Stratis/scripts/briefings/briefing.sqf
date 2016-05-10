/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: briefing.sqf

Author:

	Hazey

Last modified:

	1/17/2015

Description:

	Mission Briefing.
______________________________________________________*/

player createDiarySubject ["insPage","ALiVE Insurgency"];

player createDiaryRecord ["insPage", ["About",
"<br/>DESCRIPTION<br/>
===========<br/><br/>
Insurgency | ALiVE is a throwback to the old Arma 2 Insurgency by Fireball+Pogoman<br/><br/>
Players must search houses or kill enemy units to find randomly generated INTEL items which mark enemy cache locations.<br/><br/>
Destroy X amount of cache locations and win!<br/><br/>

<t size=2 align=left>How to play?</t><br/>
Search and clear the indicated red grids. (When Enabled VIA CQB module)<br/><br/>
When a grid is cleared it will turn green.<br/><br/>
Be sure to search the houses for randomly generated INTEL items.<br/><br/>
Picking up INTEL items will create a marker in the general area of a cache location.<br/><br/>
Find and destroy the cache.<br/><br/>

<t size=2 align=left>Who with?</t><br/>
Join our teamspeak 3 channel (ts3.whiskeycompany.net) to meet up with others on the map, or use the ingame VOIP.<br/><br/>

CREDITS
========<br/><br/>

Hazey<br/>
ALiVE Dev team<br/>
Highhead, Tupolov, ARjay<br/>
PogoMan - Old Insurgency idea<br/>
Fireball - Old Insurgency idea<br/>
"]];

player createDiaryRecord ["insPage", ["Advanced Roles",
"<br/><t size=2 align=left>Medic - Deploy Mash</t><br/>
===========<br/><br/>
- Allows you to deploy a new respawn point for your side.<br/><br/>
- Only one respawn point per medic can be deployed at a time.<br/><br/>
- Must be within 5 meteres to un-deploy.<br/><br/>
- When the medic dies, so does the respawn point! - Protect the medic! -<br/><br/>

<br/><t size=2 align=left>Engineer/MG - Deploy Sandbag</t><br/>
===========<br/><br/>
- Allows you to spawn a small sandbag for protection 2 meters in front of you.<br/><br/>
- Only one sandbag per engineer/mg can be deployed at a time.<br/><br/>
- Must be within 5 meteres to un-deploy.<br/><br/>
<br/><br/><br/>

These are still WIP.
"]];


