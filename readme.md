<p align="center">
    <img src="https://github.com/ALiVEOS/ALiVE.OS/blob/master/images/alive_logo_large.png" width="600">
</p>

<p align="center">
    <a href="https://github.com/ALiVEOS/ALiVE.OS/releases/latest">
        <img src="https://img.shields.io/github/release/ALiVEOS/ALiVE.OS.svg?maxAge=2592000" alt="ALiVE Version">
    </a>
    
    <a href="https://github.com/ALiVEOS/ALiVE.OS/issues">
        <img src="https://img.shields.io/github/issues/ALiVEOS/ALiVE.OS.svg?maxAge=2592000" alt="ALiVE Issues">
    </a>
    
    <a href="https://forums.bistudio.com/topic/187954-alive-advanced-light-infantry-virtual-environment-10-ga/">
        <img src="https://img.shields.io/badge/BI-Forums-lightgrey.svg" alt="BI Forums">
    </a>
    
    <a href="http://alivemod.com/forum">
        <img src="https://img.shields.io/badge/ALiVE-Forums-lightgrey.svg" alt="ALiVE Forums">
    </a>
    
    <a href="http://alivemod.com/wiki">
        <img src="https://img.shields.io/badge/ALiVE-Wiki-lightgrey.svg" alt="ALiVE Wiki">
    </a>

    <a href="https://github.com/ALiVEOS/ALiVE.OS/blob/master/LICENSE.txt">
        <img src="https://img.shields.io/github/license/ALiVEOS/ALiVE.OS.svg?maxAge=2592000" alt="ALiVE License">
    </a>
</p>

<p align="center">
    <sup><strong>Requires the latest version of <a href="https://github.com/CBATeam/CBA_A3/releases">CBA A3</a>.</strong></sup>
</p>


Developed by the team that brought you Multi Session Operations (MSO), the **Advanced Light Infantry Virtual Environment (ALiVE)** is an easy to use modular mission framework that provides everything players and mission makers need to quickly set up and run realistic military operations in almost any scenario, including command, combat support, service support, logistics and more.

###Main Features

ALiVE features the revolutionary *Virtual Profile System* that supports thousands of units operating simultaneously across the map with minimal impact on performance.  Unlike older caching systems, Virtual AI groups will continue to move, operate and fight and will seamlessly spawn into the visual game world when players are in range.

ALiVE identifies key military, industrial and civilian installations automatically for any map. It uses an advanced, multi-layered AI *Operational Command* structure which assesses the strategic, operational and tactical situation across the battlespace, analyses the relative strengths of enemy and friendly forces and issues missions accordingly. The result is a fluid, dynamic and credibly realistic battlefield as forces modelled on real world Combined Arms doctrines fight for key objectives.

The second generation *Persistent Campaign* system automatically retains mission critical data on an external database without any user installations required - no need for complicated MySQL databases, it is all handled completely automatically (this requires a dedicated server)!

ALiVE also provides a variety of popular *Player Support* utilities such as View Distance, Respawn Manager and an integrated Support Radio Suite for AI controlled Combat Support, Combat Service Support and C2ISTAR.

The intuitive, easy to use *modular framework* means mission making with ALiVE is quick and easy, even if you have never opened the editor before.  Simply place modules down and play.  ALiVE can be used completely stand alone or as part of more complex missions and scripts.

###Installation
-Download and run as any normal mod for ArmA3 using -mod=@CBA_A3;@ALiVE
-For Dedicated Servers use -mod=@CBA_A3;@ALiVEServer;@ALiVE
-ALiVE requires CBA_A3

###Help
There are several entries in the Field Manual which will guide you through interacting with key in game ALiVE features.

-By default, ALiVE uses the **App Key** to open the ALiVE interaction menu.  The app key is found next to your right control key. If you do not have an app key or wish to use a different binding, you can remap it in the mods keybinding menu once in game. 
-Some features will require that you carry a **Laser Designator** (or any custom item defined in the editor modules).
-For Advanced Markers, access the map and press **CTRL ALT LMB** to place or edit a marker. Press **CTRL ALT RMB** to delete a marker.

For full instructions refer to the wiki at http://alivemod.com/wiki/

Our devs check our forum daily, so any issues please contact us via the forum at http://alivemod.com/forum/

###ALiVE War Room
We highly recommend that you (as a player or a group admin) register with our ALiVE War Room at http://alivemod.com/user/register

On the War Room you can create a new group or join a current group if they accept applications.  If you create a group, you can register one or more servers to enable database persistence, player stats and AAR.

In order to capture data properly with ALiVE and ensure mission persistence, players should always use the **PLAYER EXIT** button when on a dedicated server. Administrators should use the **SERVER SAVE AND EXIT** button when closing down an MP session on a dedicated server. Both these buttons are available by pressing ESC to get to the main menu while in game.

###How It Works
ALiVE is complex but not complicated. Each module is standalone but they can be synchronised to each other to create different scenarios. The modules work independently but will use data derived from another module if it is synchronised. This layered approach provides a high degree of flexibility and allows you to build custom scenarios quickly.

Everything starts with the Placement modules. These modules fulfill two important functions: they identify a list of military and civilian objectives or areas of importance across the map and secondly, they place the AI groups. There are several module parameters for customising the type of objectives and also the shape and size of the AI forces. Refer to the Military and Civilian Placement Module pages for further details on these.

If an Operational Commander (OPCOM) is placed, it will take command of all available AI forces of its faction. However, OPCOM needs to know where its objectives are and this is simply done by Synchronising it to one or more Placements Modules.
Note that OPCOM does not exclusively take command of the units defined in the Placement modules, it is only using them to get a list of objectives. OPCOM will take command of all units of its faction across the map.

So for example you could place an OPFOR Military Placement module to occupy an area of the map, but synch a BLUFOR OPCOM to it so it knows to attack those objectives.
Another example: place a Civilian Placement module with no Unit Placement so it is only providing a list of objectives. Then place a BLUFOR Military Placement Module in a small zone nearby with and set it to a Platoon of Light Infantry. Synch a BLUFOR OPCOM in Invasion mode to both Placement modules and watch as the Infantry are ordered to attack the civilian objectives.

Using different combinations of modules it is possible to quickly create a huge range of scenarios, from massive tank battles to intense urban counter insurgency. The best way is to experiment!
