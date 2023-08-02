Bon's Infantry Recruitment Redux -- by Moser

About:

V. 1

The original script by Bon_Inf* was a priceless asset to COOP type missions such as Takistan Force,
and is still regarded as one of the best AI recruitment scripts ever released. This port to Arma 3
uses the original scripts written Bon_Inf*, albeit with small modifications and enhancements. The
main change is a switch from static unit lists to dynamic unit lists. The script will detect your unit's
vehicleClass and build the list with units from your vehicleClass. No longer will you 
have to manually build your own unit list; however, that legacy option is still available
for mission designers who want to customize the list of recruitable units.

For example, Massi's desert Rangers will only be able to recruit other desert Rangers. Other subfactions 
in the same faction class, such as SEAL or DELTA, will not be recruitable if the player is a Ranger. 
This is solely a design choice, and in my opinion, an improvement in realism from similar recruitment scripts, 
such as Rommel's excellent MSO recruitment script, which included the entire faction in the recruitment lists. 
In the future, I will include an option to allow for the entire faction to be available in the recruitment lists.

----------------------------------------------------------------------------------------------

Features: 

- Recruitment lists are dynamically built by the subfaction of the player by default
- Static, customizable lists of units are now optional
- Multiplayer cleanup of player's AI on disconnect
- "Dismiss" action for each AI infantry unit

----------------------------------------------------------------------------------------------

Installation:

The installation procedure remains identical to the original version.

Place the folder "bon_recruit_units" in your root mission folder.

For the "init.sqf", place the following line to initialize the server and client scripts:

[] execVM "bon_recruit_units\init.sqf";

For the "description.ext", place the following lines for the recruitment GUI.

#include "bon_recruit_units\dialog\common.hpp"
#include "bon_recruit_units\dialog\recruitment.hpp"

In an object's initialization field (such as a flag), add:

this addAction["<t color='#ff9900'>Recruit Infantry</t>", "bon_recruit_units\open_dialog.sqf"];

------------------------------------------------------------------------------------------------

Customizing unit lists:

To switch from dynamic recruitment lists to static recruitment lists, change 

"bon_dynamic_list = true" to "bon_dynamic_list = false" in "bon_recruit_units\init.sqf"

To customize the static recruitment list, modify "bon_recruit_units\recruitable_units_static.sqf".

--------------------------------------------------------------------------------------------------

Credits:

- Bon_Inf* for his excellent recruitment A2 AI recruitment script
- Sa-Matra for allowing me to use and modify his GUI dialogs code
- Zonekiller for his extremely useful array builder script
- The guys at Task Force Rattler for helping me test the script out
--------------------------------------------------------------------------------------------------
