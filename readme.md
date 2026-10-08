<p align="center">
    <img src="https://github.com/ALiVEOS/ALiVE.OS/blob/master/images/alive_logo_large.png" width="600">
</p>

<p align="center">
    <a href="https://github.com/ALiVEOS/ALiVE.OS/releases/latest">
        <img src="https://img.shields.io/github/release/ALiVEOS/ALiVE.OS.svg?maxAge=2592000" alt="ALiVE Version">
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
        <img src="https://img.shields.io/github/license/ALiVEOS/ALiVE.OS.svg" alt="ALiVE License">
    </a>
</p>

<p align="center">
    <a href="https://github.com/ALiVEOS/ALiVE.OS/issues">
        <img src="https://img.shields.io/github/issues/ALiVEOS/ALiVE.OS.svg?maxAge=2592000" alt="ALiVE Issues">
    </a>
    <a href="https://github.com/ALiVEOS/ALiVE.OS/labels/Ready">
        <img src="https://img.shields.io/badge/Label-Ready-blue.svg" alt="Ready">
    </a>
    <a href="https://github.com/ALiVEOS/ALiVE.OS/labels/WIP">
        <img src="https://img.shields.io/badge/Label-WIP-blue.svg" alt="WIP">
    </a>
    <a href="https://github.com/ALiVEOS/ALiVE.OS/labels/Needs%20Testing">
        <img src="https://img.shields.io/badge/Label-Testing-blue.svg" alt="Testing">
    </a>
</p>

<p align="center">
    <sup><strong>Requires the latest version of <a href="https://github.com/CBATeam/CBA_A3/releases">CBA A3</a>.</strong></sup>
</p>


Developed by the team that brought you Multi Session Operations (MSO), the **Advanced Light Infantry Virtual Environment (ALiVE)** is an easy to use modular mission framework that provides everything players and mission makers need to quickly set up and run realistic military operations in almost any scenario, including command, combat support, service support, logistics and more.

### Main Features

ALiVE features the revolutionary **Virtual Profile System** that supports thousands of units operating simultaneously across the map with minimal impact on performance.  Unlike older caching systems, Virtual AI groups will continue to move, operate and fight and will seamlessly spawn into the visual game world when players are in range.

ALiVE identifies key military, industrial and civilian installations automatically for any map. It uses an advanced, multi-layered AI **Operational Command** structure which assesses the strategic, operational and tactical situation across the battlespace, analyses the relative strengths of enemy and friendly forces and issues missions accordingly. The result is a fluid, dynamic and credibly realistic battlefield as forces modelled on real world Combined Arms doctrines fight for key objectives.

The second generation **Persistent Campaign** system automatically retains mission critical data on an external database without any user installations required - no need for complicated MySQL databases, it is all handled completely automatically (this requires a dedicated server)!

ALiVE also provides a variety of popular **Player Support** utilities such as View Distance, Respawn Manager and an integrated Support Radio Suite for AI controlled Combat Support, Combat Service Support and C2ISTAR.

The intuitive, easy to use modular framework means mission making with ALiVE is quick and easy, even if you have never opened the editor before.  Simply place modules down and play.  ALiVE can be used completely stand alone or as part of more complex missions and scripts.

A recent addition is a fully in game GUI for building unit, group and faction configs without having to learn the intricacies of config editing.

### Installation
- Download and run as any normal mod for ArmA3 using -mod=@CBA_A3;@ALiVE
- For Dedicated Servers use -mod=@CBA_A3;@ALiVEServer;@ALiVE
- ALiVE requires CBA_A3

#### Content for other mods and CDLC
ALiVE ships support for some mods and Creator DLC in its `addons` folder. Each part loads only when the mod it needs is loaded too, and is skipped quietly otherwise, so there is nothing to copy in or out:

| Addon | Loads when this is loaded | Adds |
|---|---|---|
| `composition_vn` | S.O.G. Prairie Fire | Jungle military compositions for camps, field HQs and outposts |
| `composition_spe` | Spearhead 1944 | Bocage military and guerrilla compositions |
| `composition_cup` | CUP Terrains Core | Desert, Woodland and Pacific compositions built from CUP objects |
| `compatibility_gm` | Global Mobilization | ALiVE factions and groups for Global Mobilization units |

Without the mod, the server log shows a line like `Skipped loading of addon 'ALiVE_composition_vn' as required addon 'loadorder_f_vietnam' is not present`. That is expected and not an error.

These four used to live in the `optional` folder and had to be copied into `addons` by hand. In `@ALiVE` the update replaces those copies, since the files have the same names. If you copied any of them into `@ALiVEServer` or another mod folder, delete them there, or the old ungated copy loads alongside the new one.

#### Optional addons
The `optional` folder now holds only server-side choices that change behaviour, so they stay opt-in. Copy one into `@ALiVE\addons` (or `@ALiVEServer\addons`) on the dedicated server to use it:

- `sys_data_auto` adds the Data module on a dedicated server for missions that don't place one
- `sys_data_auto_perfmon` does the same with player statistics off and performance monitoring on

### Help
There are several entries in the Field Manual which will guide you through interacting with key in game ALiVE features.

- By default, ALiVE uses the **App Key** to open the ALiVE interaction menu.  The app key is found next to your right control key. If you do not have an app key or wish to use a different binding, you can remap it in the mods keybinding menu once in game. 
- Some features will require that you carry a **Laser Designator** (or any custom item defined in the editor modules).
- For Advanced Markers, access the map and press **CTRL ALT LMB** to place or edit a marker. Press **CTRL ALT RMB** to delete a marker.

For full instructions refer to the wiki at https://alivewiki.com/

Join us on Discord: https://discord.gg/KkacXFx

### Contributing

ALiVE is going through a module by module overhaul. If you are reporting a bug, requesting a feature or thinking about a pull request, please read [CONTRIBUTING.md](CONTRIBUTING.md) first. A bug report with an RPT log attached is the fastest route to a fix.

### How It Works
ALiVE is complex but not complicated. Each module is standalone but they can be synchronised to each other to create different scenarios. The modules work independently but will use data derived from another module if it is synchronised. This layered approach provides a high degree of flexibility and allows you to build custom scenarios quickly.

Everything starts with the Placement modules. These modules fulfill two important functions: they identify a list of military and civilian objectives or areas of importance across the map and secondly, they place the AI groups. There are several module parameters for customising the type of objectives and also the shape and size of the AI forces. Refer to the Military and Civilian Placement Module pages for further details on these.

The objectives come from a terrain index: a survey of the map's buildings, roads and open ground that ships with ALiVE for more than 170 terrains. On a terrain without one, placement and the AI Commanders have little to work from, and the startup screen says so. The Map Indexer module can make an index for any terrain, and indexes made by the community are added to ALiVE.

If an AI Commander is placed, it will take command of all available AI forces of its faction. However, it needs to know where its objectives are and this is simply done by synchronising it to one or more Placements Modules.  So for example you could place an OPFOR Military Placement module to occupy an area of the map then sync a BLUFOR AI Commander to it so it knows to attack those objectives.

Using different combinations of modules it is possible to quickly create a huge range of scenarios, from massive tank battles to intense urban counter insurgency. The best way is to experiment!
