ALiVE

Developed by the team that brought you Multi Session Operations (MSO), the Advanced Light Infantry Virtual Environment (ALiVE) is an easy to use modular mission framework that provides everything players and mission makers need to quickly set up and run realistic military operations in almost any scenario, including command, combat support, service support, logistics and more.

Main Features

ALiVE features the revolutionary *Virtual Profile System* that supports thousands of units operating simultaneously across the map with minimal impact on performance.  Unlike older caching systems, Virtual AI groups will continue to move, operate and fight and will seamlessly spawn into the visual game world when players are in range.

ALiVE identifies key military, industrial and civilian installations automatically for any map. It uses an advanced, multi-layered AI *Operational Command* structure which assesses the strategic, operational and tactical situation across the battlespace, analyses the relative strengths of enemy and friendly forces and issues missions accordingly. The result is a fluid, dynamic and credibly realistic battlefield as forces modelled on real world Combined Arms doctrines fight for key objectives.

The second generation *Persistent Campaign* system automatically retains mission critical data on an external database without any user installations required - no need for complicated MySQL databases, it is all handled completely automatically!

ALiVE have created and fully integrated the *aliveMod.com War-Room*, which tracks operations in near-realtime and provides powerful analytical tools to review every kill and every shot fired.

ALiVE also provides a variety of popular *Player Support* utilities such as View Distance, Respawn and Revive Manager, Long Range Communications Rebroadcast for ACRE and an integrated Support Radio Suite for AI controlled Combat and Combat Service Support.

The intuitive, easy to use *modular framework* means mission making with ALiVE is quick and easy, even if you have never opened the editor before.  Simply place modules down and play.  ALiVE can be used completely stand alone or as part of more complex missions and scripts.

Further information, including details of the technical innovations behind ALiVE and the full development history can be found on the wiki

Core Team

Friznit - Product/Project Owner
Tupolov - Developer, Data Lead
Highhead - Developer, QA Lead
ARJay - Developer, Web Lead
Gunny - Developer
Jman - Developer, Build Lead
SpyderBlack - Developer
Ligthert - Contributor / Tester
SavageCDN - Testing
Hazey - Developer / Tester
Raptor - Developer / Tester

Alumni

Secure - Developer (ALiVEPlugIn)
WobblyHeadedBob - Developer
Naught - Developer
Cameroon - Developer
Wolffy.au - Co-founder, Developer
Rye - Social Media

Music

Johari

﻿----------------------------------------------------
ALiVE Instructions
----------------------------------------------------

-------------
Overview
-------------
ALiVE is the next generation dynamic persistent mission mod for Arma 3. Developed by a group of veteran Arma community members (responsible for the MSO mission framework) and a number of current and former serving military personnel, the easy to use modular mission framework provides everything that players and mission makers need to set up and run realistic military operations in almost any scenario, including command, combat support, service support and logistics.


Mission makers can quickly and easily create epic, large scale, whole map missions in both single and multiplayer environments.  ALiVE enables mission makers to bypass the difficulties of complex scripting and challenging performance issues.  It is compatible with custom factions, terrains, units and add-ons, even zombies!


ALiVE features autonomous AI Commanders that plan and direct missions for all AI forces across the Area of Operations, identifying strategic objectives and reacting to changes in the tactical situation.  Both AI and player forces are supported by a fully integrated logistics system that realistically models the tactical challenges of sustaining supply lines and battlefield resupply.


The revolutionary Virtual Profile System can support thousands of units operating simultaneously across the map with minimal impact on performance. All of this is tracked and persisted via a cloud based database. The result is a realistic and constantly changing battlefield which truly brings Arma 3 ALiVE. 


* Find out more at http://alivemod.com


--------------
Installation
---------------
ALiVE requires CBA. Please download and install CBA from here:
http://www.armaholic.com/page.php?id=18768&highlight=CBA

ALiVE and the ALiVEServer addons are installed the same way as any normal mod.  Extract into the ArmA 3 Directory, by default this is located in:
32-Bit - C:\Program Files\Steam\Steamapps\Common\ArmA 3\
64-Bit - C:\Program Files (x86)\Steam\Steamapps\Common\ArmA 3\

After extraction it should look like this:
Steam\Steamapps\Common\ArmA 3\@ALiVE\addons\
Steam\Steamapps\Common\ArmA 3\@ALiVEServer\

You'll also need to add a Launch Parameter to Steam (or any Arma 3 Launcher).  Right-click on ArmA 3 and click Properties and then Set Launch Options. 

In the window that opens enter: -mod=@CBA_A3;@ALiVE
If using a Dedicated Server use the following:  -mod=@CBA_A3;@ALiVEServer;@ALiVE

-----------------------------
Showcase Missions
-----------------------------
We have a set of SP and MP missions to showcase the power of ALiVE. 

In addition, similar to Arma 3 Bootcamp DLC, there is a “Tour” mission available from the Showcase mission list that provides a detailed overview of ALiVE features.

Available Missions are:

* SP - ALiVE Tour - A guide to ALiVE
* SP - ALiVE Quick Start - The example mission from our Wiki/Readme
* SP - ALiVE Divide and Rule - Find the nuclear device before it gets into the wrong hands
* SP - ALiVE Hurt Locker - Secure IED littered Stratis and eliminate the local militia


Simply access these missions via the Arma 3 Main Menu > Play > Showcases.

* MP - COOP 09 - Quick Start (Stratis) - The example mission from our Wiki/Readme, a simple whole map mission.
* MP - COOP 07 - Air Assault (Altis) - Steal an experimental helicopter while fighting across Altis
* MP - COOP 12 - Sabotage (Altis) - An example of what can be done with ALiVE, an insurgency game mode with sabotage and subterfuge.
* MP - COOP 10 - Hurt Locker (Stratis) - Secure IED littered Stratis and eliminate the local militia

Access these MP missions from your dedicated server mission selection screen.

We do not currently support “Hosted” MP play, ALiVE MP requires a Dedicated Server. You can however run a Dedicated Server and join it from the Arma 3 Client on the same PC.

-------------------
In-Game Help
-------------------
There are several entries in the Field Manual which will guide you through interacting with key in game ALiVE features.

By default, ALiVE uses the App Key to open the ALiVE interaction menu.  The app key is found next to your right control key. If you do not have an app key or wish to use a different binding, you can map User Key 20 in the game options menu. Note custom key bindings do not support modifiers (CTRL, ALT or SHIFT). You will need to restart Arma for this to take effect. 

Some features will require that you carry a Laser Designator (or custom item defined in the editor modules).

For Advanced Markers, access the map and press CTRL LMB to place or edit a marker. Press CTRL RMB to delete a marker.

For Quick Markers, access the map and press [ to choose your marker mode, CTRL LMB once to start drawing, CTRL LMB once to finish.

See the Field Manual for more information.


-------------------------------------------------------------
Getting Started - Making a mission with ALiVE
-------------------------------------------------------------
Follow these steps to create a simple mission with ALiVE. In this scenario the OPFOR will be occupying the whole island while BLUFOR will start at a small base and move out to seize objectives.

NOTE: If you want to add any friendly AI units or player vehicles you need to make sure they don't get 'Virtualized' by ALiVE. You can do this by syncing them to the Virtual AI System Module and selecting 'Virtualize All Editor Units Except Synced Units' in the module settings.

We suggest starting out on Stratis! 


Core Modules
-------------------
To begin with, place the Core modules. These should not be synced to anything.
1. Place an ALiVE Required module - this is required to run ALiVE, turn off debug
2. Place a Database Module and configure parameters as desired (requires a dedicated server to work)
3. Place a Player Options Module and configure parameters as desired (select save to database if you have placed the Database module)
4. Near LZ Connor (south east Stratis) Place a Virtual AI System Module (select persistent if using the database) and Virtualize All Editor Units Except Synced Units. Position doesn’t matter but its easier to sync friendly units when the module is closer to your base.


BLUFOR
-------------
Next, we'll set up a base for BLUFOR. The BLUFOR AI need a base to start from so make sure there is some type of military building within the marker area, such as a barracks or compound. Go to LZ Connor on Stratis.
1. Place at least one playable unit on the map
2. Place an area marker zone and name it BLUFOR_1, make sure it covers LZ Connor and the surrounding area.
3. Place a Military Placement (Mil Obj) module in your BLUFOR base, choose the desired options (e.g. light infantry, platoon strength - suggest 30 to start) and faction and add the marker zone name to the TAOR box (type in BLUFOR_1)
4. Place an AI Military Commander module for BLUFOR and select Invasion mode in the options
5. Sync(F5) the BLUFOR Mil Placement module to your BLUFOR AI Military Commander module
6. Ensure you have enabled persistence on each module if using the database
7. Add some Empty Vehicles in your base and sync them to the Virtual AI System, so that they are not virtualized
8. Add some additional playable units as needed and some supplies.
9. Optionally, give your side some tasks and task management. Place a Player Command/Control (C2ISTAR) module and add a Laser Designator to your player - “ this additem ‘LaserDesignator’ ” - in the init box of the player.
10. Optionally, add some combat support. Place a Player Combat Support Module, a Player Combat Support (Transport) module (in the base) and a Player Combat Support (CAS) module (in the base). Sync the Transport and CAS modules to the Player Combat Support Module.


OPFOR
-----------
Now add some OPFOR occupying the rest of the map
1. Place a second Mil Placement (Mil Obj) module, select desired options (e.g. Light Inf, Battalion Strength) and an OPFOR faction. Type the name of the BLUFOR base marker into the Blacklist box (BLUFOR_1)
2. Place a Mil Placement (Civ Obj) module and select desired options. Once again, type the name of the BLUFOR base marker into the Blacklist box (BLUFOR_1)
3. Place an AI Military Commander module, set it to OPFOR and select Occupy mode
4. Sync the OPFOR Mil Placement modules to your OPFOR AI Military Commander module
5. Place a CQB module, set the OPFOR faction and sync it to the Mil Placement (Civ Obj) module


Start the Invasion
------------------------
1. Finally, sync the BLUFOR AI Military Commander module to the OPFOR Mil Placement (Mil Obj) and Mil Placement (Civ Obj) modules
2. Save and play!


------------
Tutorials
------------
A complete set of tutorials for each key module to ALiVE is available at:
http://alivemod.com/#Editors


------------------------
ALiVE War Room
------------------------
We highly recommend that you (as a player or a group admin) register with our ALiVE War Room! Go here:


http://alivemod.com/user/register


When registering on War Room you have the chance to create a group or join a current group if they are accepting applications.  If you register a group, you will able to register one or more servers to enable database persistence, player stats and AAR.


NOTE: If you are a MANW Jury member, once registered, please apply via War Room to join the MANW group. For the purposes of the MANW competition we have registered a MANW group on the ALiVE War Room. You will still need to do the dedicated setup below. If you run a dedicated server and your mission is setup to use data/stats etc it will automatically post data to the War Room.


In order to capture data properly with ALiVE and ensure mission persistence, players should always use the PLAYER EXIT button when on a dedicated server. Administrators should use the SERVER SAVE AND EXIT button when wanting to close down an MP session on a dedicated server. Both these buttons are available by pressing ESC to get to the main menu while in game.


Setting Up A Dedicated Server
-----------------------------------------
Unless you are a MANW Jury member, you will need to register your server on ALiVE War Room. The War Room (Group/Server settings) has further details on setting up your dedicated server along with a configuration file for you to download.


NOTE: MANW jury members may register their own server if they wish. Please replace the alive.cfg file provided if you do (with the alive.cfg file provided during server registration). If you are a MANW Jury member who already has a dedicated server setup for ALiVE, do not use the provided alive.cfg file and you do not need to follow the instructions below.


Follow the usual BIS guidance on setting up a dedicated server. In addition to get ALiVE working with your server you will need to:


NOTE: Please ensure persistent = 1 is set in your server.cfg.


NOTE: These steps must be performed on your dedicated server NOT your client machine


Step 1     Microsoft .NET Framework 4 Client Profile must be installed on your dedicated server.     Get it from http://www.microsoft.com/download/en/details.aspx?id=24872


Step 2     Microsoft Visual C++ 2010 redistributable must also be installed on your dedicated server.     Get it from http://www.microsoft.com/en-us/download/details.aspx?id=8328


Step 3     Download the @ALiVEServer addon (MANW jury members already have the @ALiVEServer addon included) and extract the folder into the Dedicated Server Arma 3 root folder. Add @ALiVEServer to your mod line on your dedicated server. 


NOTE: Prior to extracting the addon from the 7zip archive, make sure that the archive isn't blocked. Right-Click > Properties > Unblock.


Step 4     Download and save the alive.cfg file to C:\Users\USERNAME\AppData\Local\ALiVE OR your Arma 3 root directory. If using AppData, you may need to create the directory yourself, if it's not there. Do not use your root arma 3 directory AND the AppData\Local\ALiVE directory.


NOTE: MANW Jury members already have their alive.cfg file included in the ALiVE download (it should be in your Arma 3 root directory when you extract the download).


Step 5     Important: Your ALiVE mission needs the ALiVE Database module (available in the Arma 3 Editor) placed for this feature to work!


Step 6     Run your ALiVE MP mission on your dedicated server and connect with your client   
  
Step 7     Go to alivemod.com War Room, under Live Data Feed on the home page and you should see a message stating your mission was launched.


Troubleshooting Your Dedicated Server
----------------------------------------------------
Step 1     Download and install BareTail (log monitor)  
   
Step 2     Launch Arma3server.exe with the @ALiVE and @ALiveServer in the mod line on your dedicated server. Ensure the ALiVEServer addon has been downloaded into the Arma root folder.


Step 3     Launch your arma3.exe as normal (with @ALiVE but no need for @ALiVEServer on your client)     


Step 4     Run any MP mission (with the Database Module placed) on your dedicated server and connect with your client, go into the game     


Step 5     (on your dedicated server)  In baretail open users/username/appdata/local/Arma 3/AliveServer.log


Step 6     (on your dedicated server) In baretail open the alive.log file in your Arma 3 root directory (it may be in the users/username/appdata/local/ALiVE folder if you set that up).
 
Step 7      (on your dedicated server) In baretail open Arma3Server RPT usually users/username/appdata/local/Arma3/    
 
Step 8     Check for the arma3server.rpt for CONNECTED TO DATABASE OK     


Step 9     Go to alivemod.com War Room, under Live Data Feed you should see a message stating your mission was launched. If not, check Your Group page.


-------
Help
-------
Our devs check our forum daily, so any issues please contact us via the forum:
http://alivemod.com/forum/


--------------
Gameplay
--------------
ALiVE is a dynamic campaign mission framework. The editor placed modules are designed to be intuitive but highly flexible, empowering mission makers to create a huge range of different scenarios by simply placing a few modules and markers. The AI Commanders have an overall mission and a prioritised list of objectives that they work through autonomously. Players can choose to tag along with the AI and join the fight, tackle their own objectives or just sit back and watch it all unfold.


Mission makers may wish to experiment by synchronizing different modules to each other, or using standalone ALiVE modules as a backdrop for dynamic missions and campaigns, enhancing scenarios created with traditional editing techniques. ALiVE significantly reduces the effort required to make a complex mission by adding ambience, support and persistence at the drop of a module.


-------------------
How It Works
-------------------
ALiVE is complex but not complicated. Each module is standalone but they can be synchronised to each other to create different scenarios. The modules work independently but will use data derived from another module if it is synchronised. This layered approach provides a high degree of flexibility and allows you to build custom scenarios quickly.


Everything starts with the Placement modules. These modules fulfill two important functions: they identify a list of military and civilian objectives or areas of importance across the map and secondly, they place the AI groups. There are several module parameters for customising the type of objectives and also the shape and size of the AI forces. Refer to the Military and Civilian Placement Module pages for further details on these.


If an Operational Commander (OPCOM) is placed, it will take command of all available AI forces of its faction. However, OPCOM needs to know where its objectives are and this is simply done by Synchronising it to one or more Placements Modules.
Note that OPCOM does not exclusively take command of the units defined in the Placement modules, it is only using them to get a list of objectives. OPCOM will take command of all units of its faction across the map.


So for example you could place an OPFOR Military Placement module to occupy an area of the map, but synch a BLUFOR OPCOM to it so it knows to attack those objectives.
Another example: place a Civilian Placement module with no Unit Placement so it is only providing a list of objectives. Then place a BLUFOR Military Placement Module in a small zone nearby with and set it to a Platoon of Light Infantry. Synch a BLUFOR OPCOM in Invasion mode to both Placement modules and watch as the Infantry are ordered to attack the civilian objectives.


Using different combinations of modules it is possible to quickly create a huge range of scenarios, from massive tank battles to intense urban counter insurgency. The best way is to experiment!


see our Wiki for more information http://alivemod.com/wiki

----------
License
-----------
See Lincese.txt for full details.
