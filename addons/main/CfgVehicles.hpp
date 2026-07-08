#define MODULE_NAME ALiVE_require
#define MVAR(var) DOUBLES(MODULE_NAME,var)

// Add a game logic which does nothing except requires the addon in the mission.

// Forward declarations for engine-level UI control classes used as
// inheritance targets by the ALiVE_FactionChoiceMulti / ALiVE_HiddenAttribute
// custom attribute bases below. MUST live at top-level scope - declaring
// them inside `class Cfg3DEN > class Attributes` creates shadow classes at
// Cfg3DEN/Attributes/ctrl* that rapify then resolves above BI's global
// ctrl* classes, breaking BI attribute classes (Type, EditCode, ...) whose
// Controls/Title sub-controls inherit from ctrlStatic. Symptom was:
//   "No entry bin\config.bin/Cfg3DEN/Attributes/Type/Controls/Title.type"
//   (and matching .idc / .y / .colorText / .font / .sizeEx / .text)
// cascading across every BI attribute that chains through ctrlStatic.
class ctrlControlsGroupNoScrollbars;
class ctrlListBox;
class ctrlStatic;
class ctrlEdit;
class ctrlCombo;
class ctrlButton;

class CfgFactionClasses {
    class Alive {
        displayName = "$STR_ALIVE_MODULE";
        priority = 0;
        side = 7;
    };
};

class Cfg3DEN
{
    class Attributes // Attribute UI controls are placed in this pre-defined class
    {
        // Base class templates
        class Default; // Empty template with pre-defined width and single line height
        class TitleWide: Default
        {
            class Controls
            {
                class Title;
            };
        }; // Template with full-width single line title and space for content below it

        // SubTitle header used by all ALiVE modules for section grouping
        class ALiVE_ModuleSubTitle: TitleWide
        {
            class Controls: Controls
            {
                class Title: Title
                {
                    style = 2;
                    colorText[] = {1,1,1,0.4};
                };
            };
        };

        class EditMulti3; // Forward declaration of native A3 multiline edit control
        class EditMulti5; // Forward declaration of native A3 5-line multiline edit control

        // Multiline SQF code input — used for onEachSpawn hook fields across all placement modules.
        // Inherits the native EditMulti5 control (5 visible rows) rather than EditMulti3.
        // The 3-line variant was causing mission-makers to perceive the field as broken:
        // typing past line 3 scrolls cursor + content off-screen invisibly (no visible
        // scrollbar on BI Edit controls), and the lack of visual feedback reads as "input
        // is being lost". 5 visible rows makes it obvious input is being accepted; for the
        // rare script that exceeds 5 lines, the edit still accepts input via keyboard
        // navigation within its own buffer.
        class ALiVE_EditMultilineSQF: EditMulti5
        {
        };

        class Combo; // Forward declaration of BI Combo attribute control

        // ctrlControlsGroupNoScrollbars / ctrlListBox / ctrlStatic forward
        // declarations live at top-of-file (outside class Cfg3DEN), not
        // here - see the rationale there. Attempting to forward-decl them
        // inside class Attributes shadows BI's global ctrl* classes and
        // breaks BI attributes (Type, EditCode, ...) that chain through
        // them. See fix in 2026-04-20 commit referencing this note.

        // ALiVE_FactionChoice family:
        //   Dynamic faction-selection Combo shared across placement-style
        //   modules. Populated at Eden-panel-open time from loaded
        //   CfgFactionClasses entries grouped by side (OPFOR / BLUFOR /
        //   INDFOR / CIVILIAN) with the displayName + classname suffix
        //   shown to the user.
        //
        //   Three variants differ only in which sides their dropdown
        //   includes - the same Load / Save handlers serve all three,
        //   parameterized via an array passed alongside _this:
        //
        //     ALiVE_FactionChoice            sides 0/1/2/3 (all)
        //     ALiVE_FactionChoice_Military   sides 0/1/2 (no civilians)
        //     ALiVE_FactionChoice_Civilian   side 3 only
        //
        //   Modules pick the variant that matches their semantics:
        //     mil_*    -> Military    (mission-makers shouldn't pick a
        //                              civilian faction for an enemy
        //                              placement objective)
        //     civ_*    -> Civilian    (mission-makers shouldn't pick an
        //                              OPFOR faction for civilian
        //                              ambient population)
        //     generic  -> base ALiVE_FactionChoice (rare; only when
        //                              all-sides is genuinely intended)
        //
        //   Stored attribute value is the canonical faction classname
        //   STRING. Legacy SQMs whose stored string doesn't match any
        //   currently-loaded faction get an "(unrecognised) <value>"
        //   entry at the TOP of the dropdown so the value isn't lost.
        //   Case-insensitive matching on restore (closes #651).
        //
        //   attributeLoad / attributeSave live in separate .sqf files;
        //   see the rationale in mil_ied Cfg3DEN.hpp (preprocessor fights
        //   with multi-line strings on Windows CRLF).
        class ALiVE_FactionChoice: Combo {
            attributeLoad = "[_this, [0,1,2,3]] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceLoad.sqf'";
            attributeSave = "_this call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceSave.sqf'";
        };
        class ALiVE_FactionChoice_Military: Combo {
            attributeLoad = "[_this, [0,1,2]] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceLoad.sqf'";
            attributeSave = "_this call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceSave.sqf'";
        };
        class ALiVE_FactionChoice_Civilian: Combo {
            attributeLoad = "[_this, [3]] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceLoad.sqf'";
            attributeSave = "_this call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceSave.sqf'";
        };

        // Single-select vehicle dropdowns for the Combat Support sub-modules
        // (SUP CAS / Artillery / Transport). Dynamically filled from
        // fnc_listFactionRoleVehicles (role-suitable vehicles across all
        // loaded factions, rows "[side] class | Name [Faction] Mod");
        // stores ONE bare classname STRING via BI's default Combo save -
        // the same wire format as the free-text Edit these replace. A
        // stored classname the enumeration doesn't know (unloaded mod)
        // surfaces as a selected "(unrecognised)" row so open+OK never
        // rewrites the mission. Same pattern as ALiVE_FactionChoice.
        class ALiVE_VehicleCombo_CAS: Combo {
            attributeLoad = "[_this, 'cas_type', 'cas'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenVehicleChoiceLoad.sqf'";
        };
        class ALiVE_VehicleCombo_Artillery: Combo {
            attributeLoad = "[_this, 'artillery_type', 'arty'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenVehicleChoiceLoad.sqf'";
        };
        class ALiVE_VehicleCombo_Transport: Combo {
            attributeLoad = "[_this, 'transport_type', 'transport'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenVehicleChoiceLoad.sqf'";
        };

        // Variant control classes for civilian-side single-select
        // faction attributes that store the selection under a non-
        // default setVariable key (i.e. NOT "faction"). The variant
        // class is the canonical hook because per-attribute
        // attributeLoad / attributeSave overrides on the
        // `class X { control = "Y"; }` shape are silently ignored
        // by Eden - only attributes inheriting from a base class
        // that itself defines attributeLoad / attributeSave have
        // those overrides honoured.
        //
        // Each variant passes its target setVariable key as the
        // third argument to the load handler and the second
        // argument to the save handler, ensuring the persisted
        // logic-variable name matches what the consuming module's
        // expression writes (and what its case-accessor reads).
        class ALiVE_FactionChoice_Civilian_AmbientVehicleFaction: ALiVE_FactionChoice_Civilian {
            attributeLoad = "[_this, [3], 'ambientVehicleFaction'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceLoad.sqf'";
            attributeSave = "[_this, 'ambientVehicleFaction'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceSave.sqf'";
        };
        class ALiVE_FactionChoice_Civilian_AmbientCrowdFaction: ALiVE_FactionChoice_Civilian {
            attributeLoad = "[_this, [3], 'ambientCrowdFaction'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceLoad.sqf'";
            attributeSave = "[_this, 'ambientCrowdFaction'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceSave.sqf'";
        };

        // ALiVE_FactionChoiceMulti family:
        //   Multi-select counterpart to ALiVE_FactionChoice. Same dynamic
        //   population (CfgFactionClasses + missionConfig, side filtered,
        //   civilian blacklist, Cfg3rdPartyFactions registry overrides,
        //   Phase 3c.1 inferability prediction) but with a multi-select
        //   ListBox at IDC 100 instead of a single-select Combo.
        //
        //   Built by inheriting BI's Combo attribute base (which is a
        //   controlsGroup with title + value child controls) and overriding
        //   the inner Value control's type (CT_LISTBOX=5 vs CT_COMBO=4)
        //   and style flag (LB_MULTI = 0x20 added to ST_FRAME = 16).
        //   This piggybacks on Combo's value-binding plumbing (attributeLoad/
        //   Save addressing IDC 100 via controlsGroupCtrl) without having
        //   to redefine the entire Cfg3DEN attribute framework from scratch.
        //
        //   Stored value is an SQF array literal STRING like
        //   `["BLU_F","OPF_F","IND_F"]`. Load handler also accepts CSV form
        //   `BLU_F,OPF_F` for backward compatibility with the old Edit-field
        //   pattern. Save always emits canonical array-literal form.
        //
        //   The third element of the load handler's invocation is the logic-
        //   variable name (default "factions"), allowing the same handler
        //   to serve modules whose attribute is named differently (e.g.
        //   "CQB_FACTIONS" for mil_cqb).
        //
        //   Three side-filter variants matching the single-select trio:
        //     ALiVE_FactionChoiceMulti           sides 0/1/2/3 (all)
        //     ALiVE_FactionChoiceMulti_Military  sides 0/1/2   (no civilians)
        //     ALiVE_FactionChoiceMulti_Civilian  side 3        (civilians only)
        //
        //   Modules pick the variant matching their semantics. mil_opcom
        //   uses _Military (an OPCOM faction list shouldn't include civilians).

        // Multi-select faction listbox - tall Cfg3DEN attribute that
        // renders as a multi-row listbox with Ctrl+click toggle and
        // shift+click range-select semantics (LB_MULTI style).
        //
        // Pattern: inherit ctrlControlsGroupNoScrollbars (NOT BI's
        // Combo). Attribute panel slot height is taken from the
        // outer h here; explicit child positions inside `controls`
        // (note lowercase, NOT Controls) lay out the listbox. ACE3
        // Arsenal's Cfg3DEN attribute uses this same pattern - the
        // only known way to ship a tall multi-row Cfg3DEN attribute,
        // since Combo / Edit / Title bases enforce a single-row slot
        // and silently ignore any h override.
        //
        // The three variants below differ only in attributeLoad's
        // side-allowlist parameter; they inherit everything else
        // from _Base.
        class ALiVE_FactionChoiceMulti_Base: ctrlControlsGroupNoScrollbars {
            // Forward decl of ctrlControlsGroupNoScrollbars doesn't
            // pull through the body's default properties (type, style,
            // colorBackground, etc), so they need to be set explicitly
            // here. type = 15 = CT_CONTROLS_GROUP_NO_SCROLLBARS is the
            // critical one - without it, Eden treats this as a bare
            // CT_STATIC and never descends into `class controls`,
            // causing the inner listbox to not exist (Load handler
            // reports "listbox control (IDC 100) not found").
            //
            // Layout: Eden does NOT auto-render the per-attribute
            // displayName as a row label for custom controlsGroup
            // attributes (only for simple Combo / Edit / Checkbox
            // bases), so we render the field label ourselves via a
            // Title sub-control positioned in the row's left column.
            // The listbox sits in the right (value) column to align
            // with where standard Eden value controls would.
            type  = 15;
            style = 0;
            idc   = -1;
            x = 0;
            y = 0;
            // Outer width spans the full standard Eden attribute row
            // so children can align with where other attributes' labels
            // and value controls sit.
            // Layout (grid units, halved):
            //   y=0   h=5   Title (left col, x=0..48, right-aligned)
            //   y=5   h=50  Listbox (full width, x=4..130; pushed below
            //                Title row so title text isn't overwritten
            //                by the listbox's first row)
            // Total = 55 grid units.
            w = "130 * (pixelW * pixelGrid * 0.5)";
            h = "55 * (pixelH * pixelGrid * 0.5)";
            colorBackground[] = {0, 0, 0, 0};
            colorText[]       = {1, 1, 1, 1};
            text   = "";
            font   = "RobotoCondensed";
            sizeEx = "pixelH * pixelGrid * 2.2";

            // controlsGroup engine expects VScrollbar / HScrollbar
            // sub-classes even on the "NoScrollbars" variant - empty
            // blocks silence the RPT warnings.
            class VScrollbar {};
            class HScrollbar {};

            class controls {
                // Title sub-control sits LEFT-aligned at the listbox's
                // left edge (x=4, matching the listbox's 4-grid left
                // inset) at y=0..5, ABOVE the listbox row that starts
                // at y=5. Text is set per-attribute by the LOAD handler
                // via ctrlSetText on idc 101, matching the pattern used
                // by ALiVE_TaskTypeChoice_Base / ALiVE_SideChoiceMulti /
                // ALiVE_C2ISTARAccessItemsChoice. Pre-fix the listbox
                // sat at y=0 covering this row, so the title text bled
                // through the translucent listbox background and
                // appeared as a misplaced overlay on the listbox's
                // first row. Left-aligned (style=0) since the listbox
                // is full-width — the label sits flush above the
                // listbox content rather than in a separate left
                // label column.
                class Title: ctrlStatic {
                    idc      = 101;
                    type     = 0;
                    style    = 0;
                    x        = "4 * (pixelW * pixelGrid * 0.5)";
                    y        = 0;
                    w        = "126 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0};
                    colorText[]       = {1, 1, 1, 0.9};
                    text     = "";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.2";
                    tooltip  = "Multi-select: left-click selects one row; Ctrl+left-click toggles individual rows; Shift+left-click selects a range.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                class List: ctrlListBox {
                    idc = 100;
                    type = 5;            // CT_LISTBOX
                    style = 16 + 0x20;   // ST_FRAME + LB_MULTI
                    // Listbox claims full controlsGroup width (x=0, w=130)
                    // so long class+display+mod-tag rows aren't clipped at
                    // the right edge. Sibling chrome (Title label / Faction
                    // header strip / Override edit) keeps original 48-grid
                    // left-margin layout - same asymmetric pattern as the
                    // FilteredMultiSelect_Base substrate. 4-grid left inset
                    // so the listbox doesn't bleed flush to the dialog's
                    // left edge. y=5 so the listbox sits BELOW the Title
                    // row at y=0..5, avoiding the title-overwrite that
                    // occurs when both share y=0.
                    x = "4 * (pixelW * pixelGrid * 0.5)";
                    y = "5 * (pixelH * pixelGrid * 0.5)";
                    w = "126 * (pixelW * pixelGrid * 0.5)";
                    h = "50 * (pixelH * pixelGrid * 0.5)";

                    // color[] is the listbox frame / line rendering
                    // colour (paired with ST_FRAME style bit). Matches
                    // the selection BG so any frame-like stroke blends
                    // on the currently-selected row.
                    color[]                  = {1, 0.62, 0, 1};
                    // Cursor / focus-ring properties drawn around the
                    // row the user most recently clicked. These
                    // PERSIST after the row is deselected (Ctrl+click
                    // toggle), so matching the selection BG would
                    // leave an orange outline ghosting around the
                    // now-deselected row. Match the unselected BG
                    // instead so the ring is invisible on deselected
                    // rows and appears as a subtle dark border around
                    // the selection when a row is actively selected.
                    colorActive[]            = {0, 0, 0, 0.5};
                    colorFocused[]           = {0, 0, 0, 0.5};
                    colorHover[]             = {0, 0, 0, 0.5};
                    colorText[]              = {1, 1, 1, 1};
                    colorBackground[]        = {0, 0, 0, 0.5};
                    // Selection highlight: hardcoded Eden-title orange-
                    // yellow BG with black text so the selected row is
                    // high-contrast and readable. Matches the module
                    // dialog's own title-bar chrome. The profilenamespace
                    // GUI_BCG_RGB_* macros would track the user's GUI
                    // Background colour (Options > Game > Layout) which
                    // is often a different shade from the Eden title
                    // chrome and produces a mismatched darker highlight
                    // on customised profiles.
                    colorSelect[]            = {0, 0, 0, 1};
                    colorSelect2[]           = {0, 0, 0, 1};
                    colorSelectBackground[]  = {1, 0.62, 0, 1};
                    colorSelectBackground2[] = {1, 0.62, 0, 1};
                    colorDisabled[]          = {1, 1, 1, 0.25};
                    // Disable the text drop-shadow. Fine when selected
                    // text was white, but with black-on-orange selection
                    // the semi-transparent black shadow smears into the
                    // letters and hurts legibility.
                    shadow                   = 0;
                    colorShadow[]            = {0, 0, 0, 0};

                    // Solid black tooltip background + matching black
                    // border for legibility (Eden's default attribute
                    // tooltip is too transparent; yellow border was
                    // visually distracting).
                    tooltip  = "Multi-select: Ctrl+click toggles individual rows. Shift+click selects a range. Plain click replaces the selection with just that one row.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};

                    // Listbox text and row height matched up to other
                    // Eden dialog controls without being so small the
                    // selected items appear shrunk.
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.0";
                    rowHeight = "pixelH * pixelGrid * 2.4";
                    period   = 1.2;

                    // ListBox engine expects these even when unused -
                    // empty defaults silence RPT warnings.
                    soundSelect[] = {"", 0, 0};
                    maxHistoryDelay = 1.0;

                    class ListScrollBar {
                        color[]         = {1, 1, 1, 0.6};
                        colorActive[]   = {1, 1, 1, 1};
                        colorDisabled[] = {1, 1, 1, 0.3};
                        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                        arrowFull  = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                        border     = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
                        thumb      = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                    };
                };
            };
        };

        class ALiVE_FactionChoiceMulti: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, [0,1,2,3], 'factions', [], _value, 'Factions:'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'factions'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiSave.sqf'";
        };

        class ALiVE_FactionChoiceMulti_Military: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, [0,1,2], 'factions', [], _value, 'Factions:'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'factions'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiSave.sqf'";
        };

        class ALiVE_FactionChoiceMulti_Civilian: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, [3], 'factions', [], _value, 'Factions:'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'factions'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiSave.sqf'";
        };

        // Variant of _Military that pre-ticks BLU_F when the listbox
        // resolves empty. Used by mil_opcom's `factions` attribute,
        // which has a runtime fallback to BLU_F (warns + defaults in
        // fnc_OPCOM.sqf when the configured factions list is empty);
        // showing BLU_F pre-ticked in the listbox aligns the visual
        // state with what the runtime will use.
        //
        // Encoded as a control-class variant rather than a per-attribute
        // attributeLoad override because Eden's attribute system reads
        // attributeLoad from the control class for controls-group-based
        // custom controls; per-attribute overrides on the Cfg3DEN /
        // CfgVehicles attribute class do not propagate. (Confirmed via
        // ENTRY-state diagnostic logging during #860 testing - the
        // override path produced _this count=3 / initialDefault=[],
        // matching the inherited control-class shape rather than the
        // 4-element override.)
        //
        // Other ALiVE_FactionChoiceMulti consumers (mil_cqb /
        // sup_player_resupply / sys_aiskill / amb_civ_population) keep
        // the unmodified _Military / _Civilian / base variant - their
        // empty default is semantic opt-in, not a broken-state
        // placeholder.
        class ALiVE_FactionChoiceMulti_Military_Default_BLU_F: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, [0,1,2], 'factions', ['BLU_F'], _value, '$STR_ALIVE_OPCOM_FACTIONS', '$STR_ALIVE_OPCOM_FACTIONS_COMMENT'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'factions'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiSave.sqf'";
        };

        // Per-consumer variant for mil_cqb's CQB_FACTIONS picker.
        // Title text + tooltip pulled from the mil_cqb stringtable so
        // the visible label / hover text match the attribute's
        // displayName / tooltip config.
        class ALiVE_FactionChoiceMulti_Military_CQB: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, [0,1,2], 'factions', [], _value, '$STR_ALIVE_CQB_FACTIONS', '$STR_ALIVE_CQB_FACTIONS_COMMENT'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'factions'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiSave.sqf'";
        };

        // Per-consumer variant for amb_civ_population's insurgent
        // faction picker. Title text + tooltip pulled from the
        // amb_civ_population stringtable. The displayName key
        // resolves to "Insurgent Faction(s):" - the parenthetical
        // plural clarifies that multi-select is supported.
        class ALiVE_FactionChoiceMulti_Military_InsurgentFactions: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, [0,1,2], 'factions', [], _value, '$STR_ALIVE_CIV_POP_INSURGENT_FACTION', '$STR_ALIVE_CIV_POP_INSURGENT_FACTION_COMMENT'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'factions'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiSave.sqf'";
        };

        // Shared by custom military/civilian objective modules. Empty
        // selection is meaningful: the module inherits factions from synced
        // OPCOMs at runtime.
        class ALiVE_FactionChoiceMulti_Military_CustomObjectives: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, [0,1,2], 'factions', [], _value, 'Force Factions:', 'Optional. Pick one or more factions for this custom objective to spawn. Leave empty to inherit factions from a synced AI Commander. If no Commander factions are available, the legacy Force Faction fallback is used.'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'factions'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiSave.sqf'";
        };

        // Per-consumer variant for sup_player_resupply's faction
        // whitelist picker. Title text + tooltip pulled from the
        // sup_player_resupply stringtable.
        class ALiVE_FactionChoiceMulti_Military_FactionWhitelist: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, [0,1,2], 'factions', [], _value, '$STR_ALIVE_PR_FACTION_WHITELIST', '$STR_ALIVE_PR_FACTION_WHITELIST_COMMENT'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'factions'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionChoiceMultiSave.sqf'";
        };

        // ALiVE_SideChoiceMulti:
        //   Multi-select listbox for sides (EAST / WEST / GUER). Used by
        //   mil_c2istar's opcomIntelSides attribute, which selects which
        //   synced OPCOMs feed their G2 spotrep pipeline into C2ISTAR.
        //   Sides are a fixed three-entry enum so the LOAD handler
        //   hardcodes the rows - no CfgFactionClasses walk required.
        //   Civilian (CIV) is omitted because civilians can't run an
        //   OPCOM commander.
        //
        //   Storage shape: CSV string "EAST,WEST" so the existing
        //   runtime path in fnc_C2ISTAR.sqf (which pipes the value
        //   through ALiVE_fnc_stringListToArray then uppercases) keeps
        //   working unchanged. LOAD also accepts SQF array literal,
        //   single-token, and empty-string forms so missions saved
        //   with the legacy Edit-field format restore cleanly.
        //
        //   Substrate inherited from ALiVE_FactionChoiceMulti_Base -
        //   same controlsGroup chrome, listbox styling, scrollbars.
        //   Geometry overrides: outer h compacted to 25 grid units
        //   (three short rows don't need the parent's 55), inner
        //   listbox pushed to y=5 so it sits BELOW the Title row
        //   rather than overlapping it. Without these overrides the
        //   Title text ("Commander Intel Sides:") sits in the same
        //   y-band as the listbox's first row and visually clashes -
        //   tolerable on faction lists where long classnames hide
        //   the title, ugly with only three short rows.
        //
        //   The LOAD handler calls ctrlSetText on the Title sub-control
        //   (idc 101) so the visible label can be customised per
        //   consuming attribute rather than locked to the parent
        //   substrate's "Override Factions:".
        // ALiVE_C2ISTARAccessItemsChoice:
        //   Multi-select listbox of equipment categories that grant
        //   C2ISTAR access. Used by mil_c2istar's c2_item attribute
        //   (formerly a single-classname Edit). Each row = one
        //   category from CfgALiVEC2ISTARAccessItems; categories
        //   whose cfgPatchesName isn't loaded drop off the listbox.
        //
        //   Storage shape: CSV of category keys, e.g. "LaserDesignators,
        //   Radios,Tablets". Runtime gate in fnc_C2MenuDef.sqf walks
        //   each category's classnames[] and checks against the
        //   player's assignedItems + items + backpack. Back-compat
        //   accepted: legacy stored classname like "LaserDesignator"
        //   is matched against each category's classnames[] and the
        //   containing category is ticked.
        //
        //   Substrate inherits ALiVE_FactionChoiceMulti_Base with
        //   geometry overrides (compact 5-row right-column listbox),
        //   same approach as ALiVE_SideChoiceMulti.
        class ALiVE_C2ISTARAccessItemsChoice: ALiVE_FactionChoiceMulti_Base {
            h = "32 * (pixelH * pixelGrid * 0.5)";
            class controls: controls {
                // Compact variant restores Title to the LEFT column
                // (x=0..48, right-aligned) — its listbox sits in the
                // RIGHT column (x=48..130) for a side-by-side layout.
                // The faction-consumer Base substrate uses a full-width
                // left-aligned Title above a full-width listbox, which
                // would clash with this variant's side-by-side intent.
                class Title: Title {
                    x     = 0;
                    w     = "48 * (pixelW * pixelGrid * 0.5)";
                    style = 1;
                };
                class List: List {
                    x = "48 * (pixelW * pixelGrid * 0.5)";
                    y = "5 * (pixelH * pixelGrid * 0.5)";
                    w = "82 * (pixelW * pixelGrid * 0.5)";
                    h = "26 * (pixelH * pixelGrid * 0.5)";
                };
            };
            attributeLoad = "[_this, 'c2_item', '$STR_ALIVE_C2ISTAR_ALLOW', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenC2ISTARAccessItemsLoad.sqf'";
            attributeSave = "[_this, 'c2_item'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenC2ISTARAccessItemsSave.sqf'";
        };

        // Combat Support / Player Combat Logistics variants of the access-items
        // multi-select. Same shared registry (CfgALiVEC2ISTARAccessItems), same
        // Load/Save handlers, same geometry - only the stored variable name and
        // title differ. Cloned control classes are required because the Load/Save
        // handler strings must live on the CONTROL class: attributeLoad overrides
        // on the consuming attribute class do not propagate for controlsGroup
        // based controls.
        class ALiVE_CSAccessItemsChoice: ALiVE_C2ISTARAccessItemsChoice {
            attributeLoad = "[_this, 'combatsupport_item', '$STR_ALIVE_CS_ALLOW', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenC2ISTARAccessItemsLoad.sqf'";
            attributeSave = "[_this, 'combatsupport_item'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenC2ISTARAccessItemsSave.sqf'";
        };
        class ALiVE_PRAccessItemsChoice: ALiVE_C2ISTARAccessItemsChoice {
            attributeLoad = "[_this, 'pr_item', '$STR_ALIVE_PR_ALLOW', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenC2ISTARAccessItemsLoad.sqf'";
            attributeSave = "[_this, 'pr_item'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenC2ISTARAccessItemsSave.sqf'";
        };


        class ALiVE_SideChoiceMulti: ALiVE_FactionChoiceMulti_Base {
            // Compact 4-row listbox sitting in the normal right column
            // (x=48..130) so the Title sub-control has the left column
            // (x=0..48) to itself without overlap. Outer height covers
            // Title row (0..5) + Listbox (5..27) + 1 grid unit of bottom
            // padding.
            h = "28 * (pixelH * pixelGrid * 0.5)";
            class controls: controls {
                // Compact variant restores Title to the LEFT column
                // (x=0..48, right-aligned) — its listbox sits in the
                // RIGHT column (x=48..130) for a side-by-side layout.
                // The faction-consumer Base substrate uses a full-width
                // left-aligned Title above a full-width listbox, which
                // would clash with this variant's side-by-side intent.
                //
                // Explicit no-op inheritance also keeps the sibling
                // Title sub-control when overriding List below -
                // without it, overriding one nested class via
                // `class List: List {}` can silently drop the others.
                class Title: Title {
                    x     = 0;
                    w     = "48 * (pixelW * pixelGrid * 0.5)";
                    style = 1;
                };
                class List: List {
                    // Style redeclared explicitly so the LB_MULTI bit
                    // (0x20) survives nested-class inheritance. Without
                    // it the listbox can silently degrade to single-
                    // select and persistence reads only the focused row.
                    style = 16 + 0x20;
                    x = "48 * (pixelW * pixelGrid * 0.5)";
                    y = "5 * (pixelH * pixelGrid * 0.5)";
                    w = "82 * (pixelW * pixelGrid * 0.5)";
                    h = "22 * (pixelH * pixelGrid * 0.5)";
                };
            };
            attributeLoad = "[_this, 'opcomIntelSides', '$STR_ALIVE_C2ISTAR_OPCOM_INTEL_SIDES', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenSideChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'opcomIntelSides'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenSideChoiceMultiSave.sqf'";
        };

        // ALiVE_ItemChoiceMulti family:
        //   Multi-select listbox of humanitarian items (water or ration)
        //   populated from the CfgALiVEHumanitarianItems registry. Each
        //   entry in the registry is gated on a cfgPatchesName, so items
        //   from unloaded mods are excluded from the dropdown — mission-
        //   makers only see the classes their current mod set actually
        //   provides.
        //
        //   Two variants differ only in the category filter passed to the
        //   load handler:
        //     ALiVE_ItemChoiceMulti_Water   filters to the "water" subclass
        //     ALiVE_ItemChoiceMulti_Ration  filters to the "ration" subclass
        //
        //   Stored attribute value is an SQF array literal of classname
        //   strings, same serialisation contract as ALiVE_FactionChoiceMulti.
        //   The variable name on the logic is configurable via the third
        //   element of _this (defaults to "items").
        //
        //   Substrate is inherited from ALiVE_FactionChoiceMulti_Base —
        //   same ctrlControlsGroupNoScrollbars type=15 listbox. Only the
        //   attributeLoad / attributeSave point at the item-specific
        //   handlers; everything else (layout, colours, scrollbar, etc.)
        //   comes through unchanged.
        class ALiVE_ItemChoiceMulti_Water: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, 'water', 'customWaterItems'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenItemChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'customWaterItems'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenItemChoiceMultiSave.sqf'";
        };

        class ALiVE_ItemChoiceMulti_Ration: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, 'ration', 'customHumRatItems'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenItemChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'customHumRatItems'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenItemChoiceMultiSave.sqf'";
        };

        // ALiVE_AnimalChoiceMulti family:
        //   Multi-select listbox of ambient animal classnames populated
        //   from the CfgALiVEAmbientAnimals registry. Each registry
        //   entry is gated on a cfgPatchesName, so animals from
        //   unloaded mods are excluded - mission-makers only see the
        //   classes their current mod set actually provides.
        //
        //   Two species categories: poultry (urban backyard birds -
        //   spawn near civilian buildings inside towns) and herd
        //   (sheep / goats - spawn in open fields outside the town
        //   footprint). Used by amb_civ_placement's ambient-animals
        //   feature.
        //
        //   Each variant pre-ticks a vanilla A3 default pool when no
        //   stored value is found (4th arg to attributeLoad), so
        //   fresh module placement shows the standard farm-animal
        //   classes already selected. The 5th arg plumbs Cfg3DEN's
        //   engine-auto-populated `_value` through so saved
        //   selections persist across Eden re-open regardless of
        //   logic-var name (matches the FactionChoiceMulti fix in
        //   commit 4d9d7e14).
        //
        //   Substrate inherited from ALiVE_FactionChoiceMulti_Base -
        //   same listbox geometry, font, scrollbars.
        class ALiVE_AnimalChoiceMulti_Poultry: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, 'poultry', 'customPoultryClasses', ['Hen_random_F', 'Cock_random_F'], _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenAnimalChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'customPoultryClasses'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenItemChoiceMultiSave.sqf'";
        };

        class ALiVE_AnimalChoiceMulti_Herd: ALiVE_FactionChoiceMulti_Base {
            attributeLoad = "[_this, 'herd', 'customHerdClasses', ['Goat_random_F', 'Sheep_random_F'], _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenAnimalChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'customHerdClasses'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenItemChoiceMultiSave.sqf'";
        };

        // ALiVE_FilteredMultiSelect_Base:
        //   Consolidated multi-select listbox + single-axis filter row +
        //   Override Edit. Used by amb_civ_placement (Animal Classes -
        //   poultry/herd categories) and amb_civ_population (Humanitarian
        //   Items - water/ration categories) to replace the previous
        //   per-category two-listbox-plus-Manual layout.
        //
        //   Layout (53 grid units total):
        //     y=0   h=5   Title                (left col)
        //     y=0   h=4   FilterLabel + Next   (right col, top of value column)
        //     y=5   h=42  Listbox              (right col, multi-select)
        //     y=48  h=5   Override Label/Edit  (free-text mod classes)
        //
        //   Filter cycle button (idc 1210) cycles through ["All", cat1,
        //   cat2, ...] and HIDES rows outside the active category. The
        //   cumulative selection set survives cycling - LOAD/SAVE store
        //   ticks on the controlsGroup namespace under
        //   alive_selectedClasses, same race-avoidance pattern as the
        //   composition picker (gate flag during programmatic re-tick).
        //
        //   Storage shape: a single STRING attribute on the logic in
        //   structured form `cat1:Class1,Class2;cat2:Class3` so one
        //   consolidated SQM slot replaces N per-category slots. Runtime
        //   reads the consolidated key first; legacy per-category attrs
        //   stay defined as hidden back-compat aliases so missions saved
        //   pre-consolidation still resolve via their existing logic
        //   vars when the consolidated key is empty.
        class ALiVE_FilteredMultiSelect_Base: ctrlControlsGroupNoScrollbars {
            type  = 15;
            style = 0;
            idc   = -1;
            x = 0;
            y = 0;
            w = "130 * (pixelW * pixelGrid * 0.5)";
            // Total height grew 53 -> 58 (+5 grid units) when the side
            // filter strip was added on a second row (y=5..9). Listbox
            // pushed from y=5 to y=10, override row from y=48 to y=53.
            h = "58 * (pixelH * pixelGrid * 0.5)";
            colorBackground[] = {0, 0, 0, 0};
            colorText[]       = {1, 1, 1, 1};
            text   = "";
            font   = "RobotoCondensed";
            sizeEx = "pixelH * pixelGrid * 2.2";

            class VScrollbar {};
            class HScrollbar {};

            class controls {
                // Geometry asymmetry by design: the inner listbox (idc 100)
                // claims full controlsGroup width (x=0, w=130) so long
                // class+display+mod-tag rows aren't clipped at the right
                // edge. The header strip (FilterLabel + FilterNext) and
                // the Override edit field stay in their original 48-grid
                // left-margin layout because their content (filter cycle
                // status, free-text override entry) is short enough to
                // not need the extra width and the inner Title /
                // OverrideLabel column labels add useful UX context for
                // those rows.
                class Title: ctrlStatic {
                    idc      = 101;
                    type     = 0;
                    style    = 1;
                    x        = 0;
                    y        = 0;
                    w        = "48 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0};
                    colorText[]       = {1, 1, 1, 0.9};
                    text     = "Items:";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.2";
                    tooltip  = "Tick items from the listbox. Filter narrows by category. Multi-select: Ctrl+click toggles individual rows, Shift+click selects a range, plain click replaces the selection with just that one row. Override field accepts free-text class names for mod entries the listbox doesn't surface.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                class FilterLabel: ctrlStatic {
                    idc      = 1200;
                    type     = 0;
                    style    = 0;
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = 0;
                    w        = "65 * (pixelW * pixelGrid * 0.5)";
                    h        = "4 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 0.62, 0, 1};
                    text     = "Type: All";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    tooltip  = "Filter the listbox by category. Click Next > to cycle through available categories.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                class FilterNext: ctrlButton {
                    idc      = 1210;
                    type     = 1;
                    style    = 2;
                    x        = "115 * (pixelW * pixelGrid * 0.5)";
                    y        = 0;
                    w        = "15 * (pixelW * pixelGrid * 0.5)";
                    h        = "4 * (pixelH * pixelGrid * 0.5)";
                    text     = "Next >";
                    default  = 0;
                    colorBackground[]        = {1, 0.62, 0, 0.6};
                    colorBackgroundDisabled[]= {0.4, 0.4, 0.4, 0.5};
                    colorBackgroundActive[]  = {1, 0.62, 0, 1};
                    colorFocused[]           = {1, 0.62, 0, 1};
                    colorBackgroundFocused[] = {1, 0.62, 0, 1};
                    colorText[]              = {1, 1, 1, 1};
                    colorDisabled[]          = {1, 1, 1, 0.25};
                    colorBorder[]            = {0, 0, 0, 1};
                    borderSize               = 0;
                    offsetX = 0; offsetY = 0; offsetPressedX = 0; offsetPressedY = 0;
                    colorShadow[] = {0, 0, 0, 0};
                    soundEnter[]  = {"", 0, 0};
                    soundPush[]   = {"", 0, 0};
                    soundClick[]  = {"", 0, 0};
                    soundEscape[] = {"", 0, 0};
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.6";
                };

                // SECOND ROW - side filter strip. Identical layout to the
                // category strip on row 0, just shifted down 5 grid units.
                // IDCs 1201 / 1211 (mirror 1200 / 1210). LOAD handler
                // builds a per-class side via hybrid detection (CfgVehicles
                // `side` config first, class-name suffix heuristic when
                // side is -1 / Empty), then intersects category + side
                // filters when populating the listbox.
                //
                // Side filter is always-on in the substrate. Consumers
                // whose data has no meaningful side variation (animals,
                // humanitarian items) just see "Side: All" with the cycle
                // doing nothing useful; harmless cosmetic noise. Consumers
                // with side-themed data (objective objects from POOK SAM
                // BLUFOR/IND/OPFOR variants etc.) get a real second filter
                // axis.
                class SideFilterLabel: ctrlStatic {
                    idc      = 1201;
                    type     = 0;
                    style    = 0;
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = "5 * (pixelH * pixelGrid * 0.5)";
                    w        = "65 * (pixelW * pixelGrid * 0.5)";
                    h        = "4 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 0.62, 0, 1};
                    text     = "Side: All";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    tooltip  = "Filter the listbox by side. Click Next > to cycle: All / BLUFOR / OPFOR / Independent / Civilian / Empty (no side declared). Side is read from CfgVehicles >> side first; classes flagged Empty are re-checked against class-name suffixes (_BLUFOR / _IND / _INDFOR / _OPFOR) so theme-by-suffix mod content (POOK SAM family etc.) is filterable.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                class SideFilterNext: ctrlButton {
                    idc      = 1211;
                    type     = 1;
                    style    = 2;
                    x        = "115 * (pixelW * pixelGrid * 0.5)";
                    y        = "5 * (pixelH * pixelGrid * 0.5)";
                    w        = "15 * (pixelW * pixelGrid * 0.5)";
                    h        = "4 * (pixelH * pixelGrid * 0.5)";
                    text     = "Next >";
                    default  = 0;
                    colorBackground[]        = {1, 0.62, 0, 0.6};
                    colorBackgroundDisabled[]= {0.4, 0.4, 0.4, 0.5};
                    colorBackgroundActive[]  = {1, 0.62, 0, 1};
                    colorFocused[]           = {1, 0.62, 0, 1};
                    colorBackgroundFocused[] = {1, 0.62, 0, 1};
                    colorText[]              = {1, 1, 1, 1};
                    colorDisabled[]          = {1, 1, 1, 0.25};
                    colorBorder[]            = {0, 0, 0, 1};
                    borderSize               = 0;
                    offsetX = 0; offsetY = 0; offsetPressedX = 0; offsetPressedY = 0;
                    colorShadow[] = {0, 0, 0, 0};
                    soundEnter[]  = {"", 0, 0};
                    soundPush[]   = {"", 0, 0};
                    soundClick[]  = {"", 0, 0};
                    soundEscape[] = {"", 0, 0};
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.6";
                };

                class List: ctrlListBox {
                    idc = 100;
                    type = 5;            // CT_LISTBOX
                    style = 16 + 0x20;   // ST_FRAME + LB_MULTI
                    x = "4 * (pixelW * pixelGrid * 0.5)";
                    y = "10 * (pixelH * pixelGrid * 0.5)";
                    w = "126 * (pixelW * pixelGrid * 0.5)";
                    h = "42 * (pixelH * pixelGrid * 0.5)";

                    color[]                  = {1, 0.62, 0, 1};
                    colorActive[]            = {0, 0, 0, 0.5};
                    colorFocused[]           = {0, 0, 0, 0.5};
                    colorHover[]             = {0, 0, 0, 0.5};
                    colorText[]              = {1, 1, 1, 1};
                    colorBackground[]        = {0, 0, 0, 0.5};
                    colorSelect[]            = {0, 0, 0, 1};
                    colorSelect2[]           = {0, 0, 0, 1};
                    colorSelectBackground[]  = {1, 0.62, 0, 1};
                    colorSelectBackground2[] = {1, 0.62, 0, 1};
                    colorDisabled[]          = {1, 1, 1, 0.25};
                    shadow                   = 0;
                    colorShadow[]            = {0, 0, 0, 0};

                    tooltip  = "Multi-select: Ctrl+click toggles individual rows. Shift+click selects a range. Plain click replaces the selection with just that one row. Filtered rows from other categories are hidden but their ticks are preserved across cycles.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};

                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.0";
                    rowHeight = "pixelH * pixelGrid * 2.4";
                    period   = 1.2;

                    soundSelect[] = {"", 0, 0};
                    maxHistoryDelay = 1.0;

                    class ListScrollBar {
                        color[]         = {1, 1, 1, 0.6};
                        colorActive[]   = {1, 1, 1, 1};
                        colorDisabled[] = {1, 1, 1, 0.3};
                        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                        arrowFull  = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                        border     = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
                        thumb      = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                    };
                };

                class OverrideLabel: ctrlStatic {
                    idc      = 103;
                    type     = 0;
                    style    = 1;
                    x        = 0;
                    y        = "53 * (pixelH * pixelGrid * 0.5)";
                    w        = "48 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0};
                    colorText[]       = {1, 1, 1, 0.7};
                    text     = "Override entries:";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.2";
                    tooltip  = "Free-text comma-separated class names for mod entries the listbox doesn't surface. Combined with the listbox ticks above at save time.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                class Override: ctrlEdit {
                    idc      = 102;
                    type     = 2;
                    style    = 0;
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = "53 * (pixelH * pixelGrid * 0.5)";
                    w        = "82 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    text     = "";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 1, 1, 1};
                    colorSelection[]  = {1, 0.62, 0, 0.6};
                    colorDisabled[]   = {1, 1, 1, 0.25};
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    autocomplete = "";
                    canModify = 1;
                };
            };
        };

        // Animal subclass: poultry + herd categories. Wires the LOAD
        // handler with the legacy per-category varNames + their Manual
        // back-compat partners so existing missions migrate cleanly into
        // the consolidated picker.
        class ALiVE_AnimalChoiceMulti_Filtered: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, 'CfgALiVEAmbientAnimals', 'poultry,herd', 'customPoultryClasses,customHerdClasses', ['Hen_random_F','Cock_random_F','Goat_random_F','Sheep_random_F'], _value, '$STR_ALIVE_AMBCP_ANIMAL_CLASSES', 'customPoultryClassesManual,customHerdClassesManual', 'customAnimalClasses'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFilteredMultiSelectLoad.sqf'";
            attributeSave = "[_this, 'CfgALiVEAmbientAnimals', 'poultry,herd', 'customPoultryClasses,customHerdClasses', 'customPoultryClassesManual,customHerdClassesManual'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFilteredMultiSelectSave.sqf'";
        };

        // AA Unit subclass: faction-aware multi-select of AA-shape
        // CfgVehicles classes. Filter cycles All / Vehicle / Static
        // (data-driven from listFactionAAUnits role tags). Override
        // Edit accepts free-text mod classes the predicate doesn't
        // surface. Used by mil_placement / mil_placement_custom for
        // per-cluster AA force composition.
        class ALiVE_AAUnitChoiceMulti: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, 'aaClasses', 'faction', '$STR_ALIVE_MP_AA_CLASSES', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenAAUnitChoiceLoad.sqf'";
            attributeSave = "[_this, 'aaClasses'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenAAUnitChoiceSave.sqf'";
        };

        // Item subclass: water + ration categories. Same shape as the
        // animal variant but reads CfgALiVEHumanitarianItems.
        class ALiVE_ItemChoiceMulti_Filtered: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, 'CfgALiVEHumanitarianItems', 'water,ration', 'customWaterItems,customHumRatItems', [], _value, '$STR_ALIVE_CIV_POP_HUMANITARIAN_ITEMS', 'customWaterItemsManual,customHumRatItemsManual', 'customHumanitarianItems'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFilteredMultiSelectLoad.sqf'";
            attributeSave = "[_this, 'CfgALiVEHumanitarianItems', 'water,ration', 'customWaterItems,customHumRatItems', 'customWaterItemsManual,customHumRatItemsManual'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFilteredMultiSelectSave.sqf'";
        };

        // Objective-objects subclass: comms / radar / antenna props +
        // visual signal panels for objective scenery placement (#875).
        // Reads Cfg3rdPartyObjectiveObjects with the new flat-array
        // schema (objectClasses[] + staticDataObjects[]) - 246 classes
        // across 9 mod blocks (vanilla + Contact + Jets DLCs + RHS x4 +
        // Crows EW + POOK SAM/Camonets + EAA + Drongos AO).
        //
        // Filter cycle: All / objectClasses (comms+radar) /
        // staticDataObjects (signal panels). Same hide-rows semantic
        // as Animals / HumanitarianItems variants.
        //
        // No legacy varNames or Manual back-compat fields - this is
        // a fresh attribute (#875), not a consolidation of pre-existing
        // pickers. Per-category fallback varNames provided as
        // forward-compat scaffolding only.
        class ALiVE_ObjectiveObjectChoice: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, 'Cfg3rdPartyObjectiveObjects', 'radar,antenna,dataTerminal,jammer,comms,staticData', 'objectiveRadarClasses,objectiveAntennaClasses,objectiveDataTerminalClasses,objectiveJammerClasses,objectiveCommsClasses,objectiveStaticDataClasses', [], _value, '$STR_ALIVE_OBJECTIVE_OBJECTS', '', 'objectiveObjects', '$STR_ALIVE_OBJECTIVE_OVERRIDE'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFilteredMultiSelectLoad.sqf'";
            attributeSave = "[_this, 'Cfg3rdPartyObjectiveObjects', 'radar,antenna,dataTerminal,jammer,comms,staticData', 'objectiveRadarClasses,objectiveAntennaClasses,objectiveDataTerminalClasses,objectiveJammerClasses,objectiveCommsClasses,objectiveStaticDataClasses', ''] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFilteredMultiSelectSave.sqf'";
        };

        // ALiVE_FactionTierChoice:
        //   Swap-selection variant of the filtered multi-select substrate.
        //   Listbox shows ALL military-side factions at all times; the
        //   filter cycle button SWAPS which tier's tick state is currently
        //   displayed (NOT hides rows). Each faction can be ticked under
        //   any tier independently. Used by sys_aiskill to consolidate the
        //   four skill-tier listboxes (Recruit / Regular / Veteran / Expert)
        //   plus the Custom Skill listbox into one picker.
        //
        //   Storage shape: structured string
        //     "recruit:OPF_F;regular:BLU_F,IND_F;veteran:;expert:;custom:CUP_F"
        //   on a single consolidated attr (skillTierFactions).
        //
        //   Inherits the same controlsGroup substrate as the hide-rows
        //   variant (ALiVE_FilteredMultiSelect_Base) - identical UI shape.
        //   Only the LOAD/SAVE handlers differ to encode the swap
        //   semantic.
        class ALiVE_FactionTierChoice: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, [0,1,2], 'skillTierFactions', 'skillFactionsRecruit,skillFactionsRegular,skillFactionsVeteran,skillFactionsExpert,customSkillFactions', 'skillFactionsRecruitManual,skillFactionsRegularManual,skillFactionsVeteranManual,skillFactionsExpertManual,customSkillFactionsManual', 'Recruit,Regular,Veteran,Expert,Custom', _value, '$STR_ALIVE_AISKILL_TIER_FACTIONS'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionTierChoiceLoad.sqf'";
            attributeSave = "[_this, 'skillTierFactions', 'skillFactionsRecruit,skillFactionsRegular,skillFactionsVeteran,skillFactionsExpert,customSkillFactions', 'skillFactionsRecruitManual,skillFactionsRegularManual,skillFactionsVeteranManual,skillFactionsExpertManual,customSkillFactionsManual', 'Recruit,Regular,Veteran,Expert,Custom'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionTierChoiceSave.sqf'";
        };

        // ALiVE_FactionSlotChoice:
        //   Consolidated single-select picker for the six mil_c2istar
        //   autoGenerate*Faction attributes (BLU friendly + enemy, OPF
        //   friendly + enemy, IND friendly + enemy). One listbox of all
        //   military factions; the FilterNext button (top filter row,
        //   idc 1210) cycles through six SLOTS (BLU Friendly, BLU Enemy,
        //   OPF Friendly, OPF Enemy, IND Friendly, IND Enemy). Each slot
        //   stores ONE faction classname. The SideFilterNext button
        //   (idc 1211) toggles between Auto (per-slot natural side) and
        //   All (every military faction visible).
        //
        //   Single-select semantics: listbox style overrides
        //   ALiVE_FilteredMultiSelect_Base's LB_MULTI bit (0x20) to
        //   ST_FRAME only (16) so the user can only highlight ONE row
        //   per slot. LBSelChanged in the LOAD handler stores the
        //   selected row's lbData (faction classname) under the current
        //   slot key in `alive_slotSelections` on the display namespace.
        //
        //   Storage shape: consolidated string "BLU_F|OPF_F|OPF_F|BLU_F|
        //   IND_F|OPF_F" (six pipe-separated tokens, slot order matches
        //   the cycle order). SAVE also writes each token to its legacy
        //   per-slot attribute (autoGenerateBluforFaction etc.) so the
        //   runtime path in fnc_C2ISTAR.sqf (which reads each by name)
        //   continues to work unchanged.
        class ALiVE_FactionSlotChoice: ALiVE_FilteredMultiSelect_Base {
            class controls: controls {
                class Title: Title {};
                class FilterLabel: FilterLabel {};
                class FilterNext: FilterNext {};
                class SideFilterLabel: SideFilterLabel {};
                class SideFilterNext: SideFilterNext {};
                class List: List {
                    // Override the inherited LB_MULTI style to single-
                    // select. ST_FRAME only (16); without LB_MULTI the
                    // listbox enforces one row per slot at the UI layer,
                    // matching the semantics that each slot stores one
                    // faction.
                    style = 16;
                    // Constrain to the right column (x=48..130) so the
                    // listbox aligns with where standard Eden value
                    // controls sit. Left column (x=0..48) stays clear
                    // for the Title sub-control above. Width 82 covers
                    // CfgFactionClasses display names comfortably.
                    x = "48 * (pixelW * pixelGrid * 0.5)";
                    w = "82 * (pixelW * pixelGrid * 0.5)";
                };
                class OverrideLabel: OverrideLabel {};
                class Override: Override {};
            };
            attributeLoad = "[_this, 'autoGenerateFactions', 'autoGenerateBluforFaction,autoGenerateBluforEnemyFaction,autoGenerateOpforFaction,autoGenerateOpforEnemyFaction,autoGenerateIndforFaction,autoGenerateIndforEnemyFaction', 'BLU Friendly,BLU Enemy,OPF Friendly,OPF Enemy,IND Friendly,IND Enemy', '1|0,2|0|1,2|2|0,1', 'BLU_F,OPF_F,OPF_F,BLU_F,IND_F,OPF_F', _value, 'Auto Task Factions:'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionSlotChoiceLoad.sqf'";
            attributeSave = "[_this, 'autoGenerateFactions', 'autoGenerateBluforFaction,autoGenerateBluforEnemyFaction,autoGenerateOpforFaction,autoGenerateOpforEnemyFaction,autoGenerateIndforFaction,autoGenerateIndforEnemyFaction'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionSlotChoiceSave.sqf'";
        };


        // ALiVE_FactionStaticDataChoice family:
        //   Lets a mission-maker override the per-faction static-data
        //   registries (mil_logistics ground / air transport / airdrop
        //   containers; mil_placement support / supply classes) from
        //   inside Eden, instead of hand-editing init.sqf to call
        //   ALIVE_fnc_hashSet on the global registry hashes.
        //
        //   Layout: controlsGroup containing a multi-select listbox of
        //   classes drawn from the module's currently-selected factions
        //   (filtered by kind - "land" / "air" / "container" / "support"
        //   / "supply"), plus a free-text override Edit at the bottom for
        //   classes the listbox doesn't surface (mod-specific classes,
        //   community classes that don't live in CfgGroups, etc.).
        //
        //   Storage: a single string on the logic, format
        //     FACTION1=class1,class2;FACTION2=class3
        //   On Eden re-open, classes that match a listbox row are ticked,
        //   the rest pre-fill the override field. On module init the
        //   resolver merges both halves and applies via hashSet to the
        //   global registry (same plumbing as the existing init.sqf
        //   override pattern, just driven by Eden state).
        //
        //   Substrate is a fresh ctrlControlsGroupNoScrollbars (NOT
        //   inherited from ALiVE_FactionChoiceMulti_Base) because this
        //   control needs a taller layout to fit the override Edit row
        //   below the listbox.
        class ALiVE_FactionStaticDataChoice_Base: ctrlControlsGroupNoScrollbars {
            type  = 15;
            style = 0;
            idc   = -1;
            x = 0;
            y = 0;
            w = "130 * (pixelW * pixelGrid * 0.5)";
            // Layout (grid units, halved per existing module-dialog
            // convention):
            //   y=0  h=5  Title (left col)  + Faction Combo (right col)
            //   y=6  h=50 Listbox (right col, full width)
            //   y=57 h=5  Override Label (left col) + Override Edit (right col)
            //
            // Total = 62 grid units. The reactive faction-picker combo
            // (idc 200) sits at the top right and drives listbox /
            // override population for the currently-selected faction.
            // attributeLoad attaches an LBSelChanged handler to the
            // combo that flushes the current view's ticks + override
            // text into a per-faction hash on the display, then
            // repopulates listbox + override Edit for the newly-picked
            // faction. attributeSave does the final flush before
            // serialising.
            h = "62 * (pixelH * pixelGrid * 0.5)";
            colorBackground[] = {0, 0, 0, 0};
            colorText[]       = {1, 1, 1, 1};
            text   = "";
            font   = "RobotoCondensed";
            sizeEx = "pixelH * pixelGrid * 2.2";

            class VScrollbar {};
            class HScrollbar {};

            class controls {
                // Row 1 left: title (per-attribute label set at runtime
                // by attributeLoad from the localised string in the
                // variant control's plumbed args).
                class Title: ctrlStatic {
                    idc      = 101;
                    type     = 0;
                    style    = 1;
                    x        = 0;
                    y        = 0;
                    w        = "48 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0};
                    colorText[]       = {1, 1, 1, 0.9};
                    text     = "Override:";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.2";
                    tooltip  = "Use the Next button to pick a faction, then tick classes from the listbox to build the override set for that faction.\n\nMulti-select: Ctrl+click toggles individual rows in/out of the selection. Shift+click selects a range. Plain click replaces the selection with just that one row.\n\nThe Override field accepts free-text class names for mod classes the listbox doesn't surface (combined with listbox ticks). The 'Custom Class Mode' setting at the top of the section controls whether the combined set REPLACES the faction's registry entry or APPENDS to it.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                // Row 1 right: faction-picker. Two-control approach
                // after ctrlListBox (multiple geometry tries) + ctrlCombo
                // both refused to render inside the 3DEN attribute
                // controlsGroup. Layout: a static text label showing the
                // currently-active faction (idc 200) on the left of the
                // value column, and a "Next" button (idc 202) on the
                // right. Click the button to cycle to the next faction
                // (wrapping); right-click to cycle to the previous. The
                // attached ButtonClick handler in the load handler does
                // the per-faction view flush + reload.
                class FactionLabel: ctrlStatic {
                    idc      = 200;
                    type     = 0;
                    style    = 0;        // ST_LEFT
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = 0;
                    w        = "65 * (pixelW * pixelGrid * 0.5)";
                    h        = "6 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 0.62, 0, 1};
                    text     = "";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.0";
                    tooltip  = "Currently-active faction. The listbox + override field below show overrides for THIS faction. Use the Next button to cycle through other factions when the module manages more than one.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                class FactionNextButton: ctrlButton {
                    idc      = 202;
                    type     = 1;        // CT_BUTTON
                    style    = 2;        // ST_CENTER
                    x        = "115 * (pixelW * pixelGrid * 0.5)";
                    y        = 0;
                    w        = "15 * (pixelW * pixelGrid * 0.5)";
                    h        = "6 * (pixelH * pixelGrid * 0.5)";
                    text     = "Next >";
                    default  = 0;

                    colorBackground[]        = {1, 0.62, 0, 0.6};
                    colorBackgroundDisabled[]= {0.4, 0.4, 0.4, 0.5};
                    colorBackgroundActive[]  = {1, 0.62, 0, 1};
                    colorFocused[]           = {1, 0.62, 0, 1};
                    colorBackgroundFocused[] = {1, 0.62, 0, 1};
                    // White text on orange BG.
                    colorText[]              = {1, 1, 1, 1};
                    colorDisabled[]          = {1, 1, 1, 0.25};
                    colorBorder[]            = {0, 0, 0, 1};
                    borderSize               = 0;
                    offsetX                  = 0;
                    offsetY                  = 0;
                    offsetPressedX           = 0;
                    offsetPressedY           = 0;
                    colorShadow[]            = {0, 0, 0, 0};
                    soundEnter[]             = {"", 0, 0};
                    soundPush[]              = {"", 0, 0};
                    soundClick[]             = {"", 0, 0};
                    soundEscape[]            = {"", 0, 0};

                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    tooltip  = "Cycle to the next faction.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                // Row 2 right: multi-select listbox showing the
                // currently-picked faction's classes (filtered by the
                // attribute's kind). Repopulated by the LBSelChanged
                // handler attached to FactionPicker.
                class List: ctrlListBox {
                    idc = 100;
                    type = 5;
                    style = 16 + 0x20;
                    // Listbox starts after the faction-picker row above
                    // (picker static + button at y=0 h=6, gap, list at
                    // y=7). Listbox at x=4 w=126 (4-grid left inset so it
                    // doesn't bleed flush to the dialog's left edge);
                    // faction picker strip + Override edit field keep
                    // original 48-grid left-margin layout.
                    x = "4 * (pixelW * pixelGrid * 0.5)";
                    y = "7 * (pixelH * pixelGrid * 0.5)";
                    w = "126 * (pixelW * pixelGrid * 0.5)";
                    h = "48 * (pixelH * pixelGrid * 0.5)";

                    color[]                  = {1, 0.62, 0, 1};
                    colorActive[]            = {0, 0, 0, 0.5};
                    colorFocused[]           = {0, 0, 0, 0.5};
                    colorHover[]             = {0, 0, 0, 0.5};
                    colorText[]              = {1, 1, 1, 1};
                    colorBackground[]        = {0, 0, 0, 0.5};
                    colorSelect[]            = {0, 0, 0, 1};
                    colorSelect2[]           = {0, 0, 0, 1};
                    colorSelectBackground[]  = {1, 0.62, 0, 1};
                    colorSelectBackground2[] = {1, 0.62, 0, 1};
                    colorDisabled[]          = {1, 1, 1, 0.25};
                    shadow                   = 0;
                    colorShadow[]            = {0, 0, 0, 0};

                    tooltip  = "Multi-select: Ctrl+click toggles individual rows. Shift+click selects a range. Plain click replaces the selection with just that one row.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};

                    font     = "RobotoCondensed";
                    // Match OPCOM's faction-multi listbox at sizeEx 2.0
                    // for consistency across faction-related controls.
                    sizeEx   = "pixelH * pixelGrid * 2.0";
                    rowHeight = "pixelH * pixelGrid * 2.4";
                    period   = 1.2;

                    soundSelect[] = {"", 0, 0};
                    maxHistoryDelay = 1.0;

                    class ListScrollBar {
                        color[]         = {1, 1, 1, 0.6};
                        colorActive[]   = {1, 1, 1, 1};
                        colorDisabled[] = {1, 1, 1, 0.3};
                        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                        arrowFull  = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                        border     = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
                        thumb      = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                    };
                };

                // Row 3 left: override-field label.
                class OverrideLabel: ctrlStatic {
                    idc      = 103;
                    type     = 0;
                    style    = 1;
                    x        = 0;
                    y        = "57 * (pixelH * pixelGrid * 0.5)";
                    w        = "48 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0};
                    colorText[]       = {1, 1, 1, 0.7};
                    text     = "Override classes:";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.2";
                    tooltip  = "Free-text comma-separated class names for THIS faction (the one currently picked above). For mod classes the listbox doesn't surface. Combined with the listbox ticks - both contribute to this faction's override set. The 'Custom Class Mode' at the top decides whether that set REPLACES the registry's existing entry for the faction or APPENDS to it. Switching the faction picker swaps the field to the new faction's saved overrides.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                // Row 3 right: per-faction override Edit. Shows the
                // currently-picked faction's overrides; LBSelChanged on
                // the combo flushes its text to the per-faction hash
                // on swap.
                class Override: ctrlEdit {
                    idc      = 102;
                    type     = 2;
                    style    = 0;
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = "57 * (pixelH * pixelGrid * 0.5)";
                    w        = "82 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    text     = "";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 1, 1, 1};
                    colorSelection[]  = {1, 0.62, 0, 0.6};
                    colorDisabled[]   = {1, 1, 1, 0.25};
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    autocomplete = "";
                    canModify = 1;
                };
            };
        };

        // Per-kind variants. Each plumbs a kind-filter token through to the
        // listbox feeder + a different logic-variable name + a localised
        // title string. The handler resolves the filter token to a CfgGroups
        // category list (and isKindOf gate) for the listbox population.
        class ALiVE_FactionStaticDataChoice_LandTransport: ALiVE_FactionStaticDataChoice_Base {
            attributeLoad = "[_this, 'land', 'customLandTransport', '$STR_ALIVE_ML_CUSTOM_LAND_TRANSPORT', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionStaticDataLoad.sqf'";
            attributeSave = "[_this, 'customLandTransport'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionStaticDataSave.sqf'";
        };

        class ALiVE_FactionStaticDataChoice_AirTransport: ALiVE_FactionStaticDataChoice_Base {
            attributeLoad = "[_this, 'air', 'customAirTransport', '$STR_ALIVE_ML_CUSTOM_AIR_TRANSPORT', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionStaticDataLoad.sqf'";
            attributeSave = "[_this, 'customAirTransport'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionStaticDataSave.sqf'";
        };

        class ALiVE_FactionStaticDataChoice_Containers: ALiVE_FactionStaticDataChoice_Base {
            attributeLoad = "[_this, 'container', 'customContainers', '$STR_ALIVE_ML_CUSTOM_CONTAINERS', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionStaticDataLoad.sqf'";
            attributeSave = "[_this, 'customContainers'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionStaticDataSave.sqf'";
        };

        class ALiVE_FactionStaticDataChoice_Supports: ALiVE_FactionStaticDataChoice_Base {
            attributeLoad = "[_this, 'support', 'customSupports', '$STR_ALIVE_MP_CUSTOM_SUPPORTS', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionStaticDataLoad.sqf'";
            attributeSave = "[_this, 'customSupports'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionStaticDataSave.sqf'";
        };

        class ALiVE_FactionStaticDataChoice_Supplies: ALiVE_FactionStaticDataChoice_Base {
            attributeLoad = "[_this, 'supply', 'customSupplies', '$STR_ALIVE_MP_CUSTOM_SUPPLIES', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionStaticDataLoad.sqf'";
            attributeSave = "[_this, 'customSupplies'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenFactionStaticDataSave.sqf'";
        };

        // ALiVE_TaskTypeChoice family:
        //   Flat-list multi-select for global registries that aren't
        //   faction-keyed. mil_c2istar's ALIVE_autoGeneratedTasks is the
        //   archetype - one global array of task-type names that the
        //   commander draws from when auto-generating tasks. Mission-
        //   makers override it without hand-editing init.sqf.
        //
        //   Layout differs from the FactionStaticDataChoice family - no
        //   faction picker (single bucket), so the listbox spans the full
        //   value column from y=0 with the override Edit row below.
        class ALiVE_TaskTypeChoice_Base: ctrlControlsGroupNoScrollbars {
            type  = 15;
            style = 0;
            idc   = -1;
            x = 0;
            y = 0;
            w = "130 * (pixelW * pixelGrid * 0.5)";
            // Layout (grid units, halved):
            //   y=0   h=5   Title (left col only)
            //   y=5   h=50  Listbox (full width, pushed below Title row
            //                so the title text doesn't get overwritten
            //                by the listbox's first row)
            //   y=57  h=5   Override Label (left) + Override Edit (right)
            // Total = 62 grid units.
            h = "62 * (pixelH * pixelGrid * 0.5)";
            colorBackground[] = {0, 0, 0, 0};
            colorText[]       = {1, 1, 1, 1};
            text   = "";
            font   = "RobotoCondensed";
            sizeEx = "pixelH * pixelGrid * 2.2";

            class VScrollbar {};
            class HScrollbar {};

            class controls {
                class Title: ctrlStatic {
                    idc      = 101;
                    type     = 0;
                    style    = 1;
                    x        = 0;
                    y        = 0;
                    w        = "48 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0};
                    colorText[]       = {1, 1, 1, 0.9};
                    text     = "Override:";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.2";
                    tooltip  = "Tick task types from the listbox to build the override set. The Override field accepts free-text task type names for mod tasks the listbox doesn't surface (combined with listbox ticks). The 'Custom Class Mode' setting controls whether the combined set REPLACES the registry or APPENDS to it.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                class List: ctrlListBox {
                    idc = 100;
                    type = 5;
                    style = 16 + 0x20;   // ST_FRAME + LB_MULTI
                    // Listbox at x=4 w=126 (4-grid left inset so it
                    // doesn't bleed flush to the dialog's left edge);
                    // sibling chrome keeps original 48-grid left margin.
                    // y=5 so the listbox sits BELOW the Title row at
                    // y=0..5, avoiding the visual title-overwrite that
                    // occurs when both share y=0.
                    x = "4 * (pixelW * pixelGrid * 0.5)";
                    y = "5 * (pixelH * pixelGrid * 0.5)";
                    w = "126 * (pixelW * pixelGrid * 0.5)";
                    h = "50 * (pixelH * pixelGrid * 0.5)";

                    color[]                  = {1, 0.62, 0, 1};
                    colorActive[]            = {0, 0, 0, 0.5};
                    colorFocused[]           = {0, 0, 0, 0.5};
                    colorHover[]             = {0, 0, 0, 0.5};
                    colorText[]              = {1, 1, 1, 1};
                    colorBackground[]        = {0, 0, 0, 0.5};
                    colorSelect[]            = {0, 0, 0, 1};
                    colorSelect2[]           = {0, 0, 0, 1};
                    colorSelectBackground[]  = {1, 0.62, 0, 1};
                    colorSelectBackground2[] = {1, 0.62, 0, 1};
                    colorDisabled[]          = {1, 1, 1, 0.25};
                    shadow                   = 0;
                    colorShadow[]            = {0, 0, 0, 0};

                    tooltip  = "Multi-select: left-click selects one row; Ctrl+left-click toggles individual rows; Shift+left-click selects a range.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};

                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.0";
                    rowHeight = "pixelH * pixelGrid * 2.4";
                    period   = 1.2;

                    soundSelect[] = {"", 0, 0};
                    maxHistoryDelay = 1.0;

                    class ListScrollBar {
                        color[]         = {1, 1, 1, 0.6};
                        colorActive[]   = {1, 1, 1, 1};
                        colorDisabled[] = {1, 1, 1, 0.3};
                        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                        arrowFull  = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                        border     = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
                        thumb      = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                    };
                };

                class OverrideLabel: ctrlStatic {
                    idc      = 103;
                    type     = 0;
                    style    = 1;
                    x        = 0;
                    y        = "57 * (pixelH * pixelGrid * 0.5)";
                    w        = "48 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0};
                    colorText[]       = {1, 1, 1, 0.7};
                    text     = "Override tasks:";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.2";
                    tooltip  = "Free-text comma-separated task type names. For mod tasks the listbox doesn't surface (e.g. tasks added by community mod packs). Combined with the listbox ticks above.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                class Override: ctrlEdit {
                    idc      = 102;
                    type     = 2;
                    style    = 0;
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = "57 * (pixelH * pixelGrid * 0.5)";
                    w        = "82 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    text     = "";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 1, 1, 1};
                    colorSelection[]  = {1, 0.62, 0, 0.6};
                    colorDisabled[]   = {1, 1, 1, 0.25};
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    autocomplete = "";
                    canModify = 1;
                };
            };
        };

        // Per-registry variant. The 'autoGenerated' kind plumbs through
        // to the AUTO_GENERATED registry name and the C2ISTAR title.
        class ALiVE_TaskTypeChoice_AutoGenerated: ALiVE_TaskTypeChoice_Base {
            attributeLoad = "[_this, 'autoGenerated', 'customAutoGeneratedTasks', '$STR_ALIVE_C2_CUSTOM_AUTOGEN_TASKS', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenTaskTypeChoiceLoad.sqf'";
            attributeSave = "[_this, 'customAutoGeneratedTasks'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenTaskTypeChoiceSave.sqf'";
        };

        // Civic variant. The 'civic' kind populates the listbox from the
        // closed Hearts-and-Minds task list (no global registry walk)
        // because civic-enabled tasks are a fixed 10-entry subset of
        // ALIVE_autoGeneratedTasks. Used by mil_c2istar's
        // civicEnabledTaskFamilies attribute.
        class ALiVE_TaskTypeChoice_Civic: ALiVE_TaskTypeChoice_Base {
            attributeLoad = "[_this, 'civic', 'civicEnabledTaskFamilies', '$STR_ALIVE_C2ISTAR_CIVIC_FAMILIES', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenTaskTypeChoiceLoad.sqf'";
            attributeSave = "[_this, 'civicEnabledTaskFamilies'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenTaskTypeChoiceSave.sqf'";
        };

        // ALiVE_CompositionChoice family:
        //   Faction-aware multi-select picker for mil_placement_custom's
        //   `composition` attribute (and any future module that wants to
        //   pick from a faction's composition pool). Listbox content is
        //   the set of compositions valid for the module's currently-
        //   selected faction (Military for WEST/EAST factions, Guerrilla
        //   for RESISTANCE), populated via ALiVE_fnc_listFactionCompositions.
        //
        //   Storage: a single comma-separated string on the logic, e.g.
        //     "SimpleOutpost07,CargoTower_IND_F,Land_FieldHQ"
        //   Empty string = no compositions selected (caller decides
        //   whether that means "skip spawn" or "pick by category default").
        //   Legacy single-class strings round-trip cleanly: a saved
        //   "SimpleOutpost07" parses into a 1-element list and either
        //   ticks the matching listbox row or fills the override field.
        //
        //   Layout matches the ALiVE_TaskTypeChoice family - flat list,
        //   no faction picker (the module's `faction` attribute is the
        //   single source of truth, read once at attributeLoad time).
        //   The override Edit accepts free-text class names for mod
        //   compositions the listbox doesn't surface.
        class ALiVE_CompositionChoice_Base: ctrlControlsGroupNoScrollbars {
            type  = 15;
            style = 0;
            idc   = -1;
            x = 0;
            y = 0;
            w = "130 * (pixelW * pixelGrid * 0.5)";
            // Layout (grid units, halved):
            //   y=0   h=5   Title (left col only)
            //   y=0   h=4   Side filter label    (idc 1200) + Next button (idc 1210)
            //   y=5   h=4   Size filter label    (idc 1201) + Next button (idc 1211)
            //   y=10  h=4   Category filter label (idc 1202) + Next button (idc 1212)
            //   y=15  h=4   Source filter label  (idc 1203) + Next button (idc 1213)
            //   y=20  h=42  Listbox (right col)
            //   y=63  h=5   Override Label (left) + Override Edit (right)
            // Total = 68 grid units. Filter rows use the FactionStaticDataChoice
            // button-cycle pattern (ctrlCombo refuses to render inside 3DEN
            // attribute controlsGroups, per the comment on FactionLabel /
            // FactionNextButton above). Integer y multipliers (no 4.5 / 9.5
            // half-units) - the engine seems to mishandle non-integer grid
            // values for static-text controls (label rendering blanks out).
            h = "68 * (pixelH * pixelGrid * 0.5)";
            colorBackground[] = {0, 0, 0, 0};
            colorText[]       = {1, 1, 1, 1};
            text   = "";
            font   = "RobotoCondensed";
            sizeEx = "pixelH * pixelGrid * 2.2";

            class VScrollbar {};
            class HScrollbar {};

            class controls {
                class Title: ctrlStatic {
                    idc      = 101;
                    type     = 0;
                    style    = 1;
                    x        = 0;
                    y        = 0;
                    w        = "48 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0};
                    colorText[]       = {1, 1, 1, 0.9};
                    text     = "Compositions:";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.2";
                    tooltip  = "Tick compositions from the listbox to build the spawn set for this module's faction. At runtime one composition is picked at random from the selection. Use the Side / Size / Category filters above the list to narrow the view. The Override field accepts free-text class names for mod compositions the listbox doesn't surface (combined with listbox ticks).\n\nMulti-select: Ctrl+click toggles individual rows. Shift+click selects a range. Plain click replaces the selection with just that one row.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                class SideFilterLabel: ctrlStatic {
                    idc      = 1200;
                    type     = 0;
                    style    = 0;
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = 0;
                    w        = "65 * (pixelW * pixelGrid * 0.5)";
                    h        = "4 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 0.62, 0, 1};
                    text     = "Side: All";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    tooltip  = "Filter the listbox by side. Click Next > to cycle: All / WEST / EAST / Independent / Civilian / Universal (compositions without a side suffix in their class name).";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                    class VScrollbar {};
                    class HScrollbar {};
                };
                class SideFilterNext: ctrlButton {
                    idc      = 1210;
                    type     = 1;
                    style    = 2;
                    x        = "115 * (pixelW * pixelGrid * 0.5)";
                    y        = 0;
                    w        = "15 * (pixelW * pixelGrid * 0.5)";
                    h        = "4 * (pixelH * pixelGrid * 0.5)";
                    text     = "Next >";
                    default  = 0;
                    colorBackground[]        = {1, 0.62, 0, 0.6};
                    colorBackgroundDisabled[]= {0.4, 0.4, 0.4, 0.5};
                    colorBackgroundActive[]  = {1, 0.62, 0, 1};
                    colorFocused[]           = {1, 0.62, 0, 1};
                    colorBackgroundFocused[] = {1, 0.62, 0, 1};
                    colorText[]              = {1, 1, 1, 1};
                    colorDisabled[]          = {1, 1, 1, 0.25};
                    colorBorder[]            = {0, 0, 0, 1};
                    borderSize               = 0;
                    offsetX = 0; offsetY = 0; offsetPressedX = 0; offsetPressedY = 0;
                    colorShadow[] = {0, 0, 0, 0};
                    soundEnter[]  = {"", 0, 0};
                    soundPush[]   = {"", 0, 0};
                    soundClick[]  = {"", 0, 0};
                    soundEscape[] = {"", 0, 0};
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.6";
                };

                class SizeFilterLabel: ctrlStatic {
                    idc      = 1201;
                    type     = 0;
                    style    = 0;
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = "5 * (pixelH * pixelGrid * 0.5)";
                    w        = "65 * (pixelW * pixelGrid * 0.5)";
                    h        = "4 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 0.62, 0, 1};
                    text     = "Size: All";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    tooltip  = "Filter the listbox by size. Click Next > to cycle: All / Large / Medium / Small / Unspecified (compositions whose category class doesn't carry a size suffix).";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                    class VScrollbar {};
                    class HScrollbar {};
                };
                class SizeFilterNext: SideFilterNext {
                    idc      = 1211;
                    y        = "5 * (pixelH * pixelGrid * 0.5)";
                };

                class CategoryFilterLabel: ctrlStatic {
                    idc      = 1202;
                    type     = 0;
                    style    = 0;
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = "10 * (pixelH * pixelGrid * 0.5)";
                    w        = "65 * (pixelW * pixelGrid * 0.5)";
                    h        = "4 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 0.62, 0, 1};
                    text     = "Category: All";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    tooltip  = "Filter the listbox by category. Click Next > to cycle through Camps / Outposts / FieldHQ / HQ / Fort / Heliports / Marine / Communications / Power / Supports / etc. The available categories are populated from the faction's actual composition pool.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                    class VScrollbar {};
                    class HScrollbar {};
                };
                class CategoryFilterNext: SideFilterNext {
                    idc      = 1212;
                    y        = "10 * (pixelH * pixelGrid * 0.5)";
                };

                class SourceFilterLabel: ctrlStatic {
                    idc      = 1203;
                    type     = 0;
                    style    = 0;
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = "15 * (pixelH * pixelGrid * 0.5)";
                    w        = "65 * (pixelW * pixelGrid * 0.5)";
                    h        = "4 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 0.62, 0, 1};
                    text     = "Source: All";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    tooltip  = "Filter the listbox by source mod. Click Next > to cycle: All / Vanilla (Arma 3 stock) / individual mod identifiers (Zeus Enhanced, ALiVE, etc.) for each mod that contributed at least one composition for this faction.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                    class VScrollbar {};
                    class HScrollbar {};
                };
                class SourceFilterNext: SideFilterNext {
                    idc      = 1213;
                    y        = "15 * (pixelH * pixelGrid * 0.5)";
                };

                class List: ctrlListBox {
                    idc = 100;
                    type = 5;
                    style = 16 + 0x20;   // ST_FRAME + LB_MULTI
                    // Listbox at x=4 w=126 (4-grid left inset so it
                    // doesn't bleed flush to the dialog's left edge);
                    // sibling chrome / filter strips keep original
                    // 48-grid left margin.
                    x = "4 * (pixelW * pixelGrid * 0.5)";
                    y = "20 * (pixelH * pixelGrid * 0.5)";
                    w = "126 * (pixelW * pixelGrid * 0.5)";
                    h = "42 * (pixelH * pixelGrid * 0.5)";

                    color[]                  = {1, 0.62, 0, 1};
                    colorActive[]            = {0, 0, 0, 0.5};
                    colorFocused[]           = {0, 0, 0, 0.5};
                    colorHover[]             = {0, 0, 0, 0.5};
                    colorText[]              = {1, 1, 1, 1};
                    colorBackground[]        = {0, 0, 0, 0.5};
                    colorSelect[]            = {0, 0, 0, 1};
                    colorSelect2[]           = {0, 0, 0, 1};
                    colorSelectBackground[]  = {1, 0.62, 0, 1};
                    colorSelectBackground2[] = {1, 0.62, 0, 1};
                    colorDisabled[]          = {1, 1, 1, 0.25};
                    shadow                   = 0;
                    colorShadow[]            = {0, 0, 0, 0};

                    tooltip  = "Multi-select: left-click selects one row; Ctrl+left-click toggles individual rows; Shift+left-click selects a range. At spawn time one composition is picked at random from the ticked set.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};

                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.0";
                    rowHeight = "pixelH * pixelGrid * 2.4";
                    period   = 1.2;

                    soundSelect[] = {"", 0, 0};
                    maxHistoryDelay = 1.0;

                    class ListScrollBar {
                        color[]         = {1, 1, 1, 0.6};
                        colorActive[]   = {1, 1, 1, 1};
                        colorDisabled[] = {1, 1, 1, 0.3};
                        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                        arrowFull  = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                        border     = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
                        thumb      = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                    };
                };

                class OverrideLabel: ctrlStatic {
                    idc      = 103;
                    type     = 0;
                    style    = 1;
                    x        = 0;
                    y        = "63 * (pixelH * pixelGrid * 0.5)";
                    w        = "48 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    colorBackground[] = {0, 0, 0, 0};
                    colorText[]       = {1, 1, 1, 0.7};
                    text     = "Override compositions:";
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 2.2";
                    tooltip  = "Free-text comma-separated composition class names. For mod compositions the listbox doesn't surface (e.g. compositions added by community packs). Combined with the listbox ticks above.";
                    tooltipColorShade[] = {0, 0, 0, 1};
                    tooltipColorText[]  = {1, 1, 1, 1};
                    tooltipColorBox[]   = {0, 0, 0, 1};
                };

                class Override: ctrlEdit {
                    idc      = 102;
                    type     = 2;
                    style    = 0;
                    x        = "48 * (pixelW * pixelGrid * 0.5)";
                    y        = "63 * (pixelH * pixelGrid * 0.5)";
                    w        = "82 * (pixelW * pixelGrid * 0.5)";
                    h        = "5 * (pixelH * pixelGrid * 0.5)";
                    text     = "";
                    colorBackground[] = {0, 0, 0, 0.5};
                    colorText[]       = {1, 1, 1, 1};
                    colorSelection[]  = {1, 0.62, 0, 0.6};
                    colorDisabled[]   = {1, 1, 1, 0.25};
                    font     = "RobotoCondensed";
                    sizeEx   = "pixelH * pixelGrid * 1.8";
                    autocomplete = "";
                    canModify = 1;
                };
            };
        };

        // Per-module variant. mil_placement_custom plumbs through to its
        // existing `ALiVE_mil_placement_custom_composition` property
        // (preserved for backward compat with existing missions) and the
        // module's faction attribute as the listbox content driver.
        class ALiVE_CompositionChoice_MPCustom: ALiVE_CompositionChoice_Base {
            attributeLoad = "[_this, 'composition', 'faction', '$STR_ALIVE_CMP_COMPOSITION', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenCompositionChoiceLoad.sqf'";
            attributeSave = "[_this, 'composition'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenCompositionChoiceSave.sqf'";
        };

        // Roadblock-composition picker variant. Used by civ_placement +
        // civ_placement_custom for the `roadblockCompositions` attribute
        // (the multi-select pool fnc_createRoadblock samples per spawn).
        // Same controlsGroup as the base; LOAD passes "CheckpointsBarricades"
        // as the initial Category filter so first-time Eden opens show the
        // roadblock-relevant subset without making the user cycle. Saved
        // filter state still wins on subsequent opens, so a user who
        // explicitly cycles to All / a different category gets that view
        // restored on reload.
        class ALiVE_CompositionChoice_CivRoadblock: ALiVE_CompositionChoice_Base {
            // Category lock uses substring patterns (case-insensitive) so 3rd-
            // party mod compositions whose category isn't the BIS literal
            // "CheckpointsBarricades" still surface. Display label is the
            // single friendly name shown in the locked Category row.
            attributeLoad = "[_this, 'roadblockCompositions', 'faction', '$STR_ALIVE_CP_ROADBLOCK_COMPOSITIONS', _value, 'checkpoint,barricade,roadblock', 'Roadblocks'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenCompositionChoiceLoad.sqf'";
            attributeSave = "[_this, 'roadblockCompositions'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenCompositionChoiceSave.sqf'";
        };

        // Hidden attribute - renders zero UI (h = 0, empty controls).
        // Used by legacy attributes that need to round-trip SQM data
        // through their `expression` without surfacing in the panel.
        // Same ctrlControlsGroupNoScrollbars substrate + same explicit
        // engine-property defaults as ALiVE_FactionChoiceMulti_Base
        // above (forward decl doesn't pull them through).
        class ALiVE_HiddenAttribute: ctrlControlsGroupNoScrollbars {
            type  = 15;
            style = 0;
            idc   = -1;
            x = 0;
            y = 0;
            w = 0;
            h = 0;
            colorBackground[] = {0, 0, 0, 0};
            colorText[]       = {1, 1, 1, 1};
            text   = "";
            font   = "RobotoCondensed";
            sizeEx = "pixelH * pixelGrid * 1.6";
            // Eden expects attributeLoad / attributeSave on every
            // attribute control; hidden attributes do nothing for
            // either (the SQM-saved value is applied via the per-
            // attribute `expression` at module init, no UI to
            // populate or read back). Empty handlers silence the
            // RPT warnings.
            attributeLoad = "";
            attributeSave = "";
            class VScrollbar {};
            class HScrollbar {};
            class controls {};
        };
    };
    // Configuration of all objects
    class Object
    {
        // Categories collapsible in "Edit Attributes" window
        class AttributeCategories
        {
              // Category class, can be anything
              class State
              {
                    class Attributes
                    {
                          // Attribute class, can be anything
                          class ALiVE_OverrideLoadout
                          {
                                //--- Mandatory properties
                                displayName = "Override ALiVE ORBAT Loadout"; // Name assigned to UI control class Title
                                tooltip = " ALiVE ORBAT Creator units have scripted loadouts. Enable this to override this loadout."; // Tooltip assigned to UI control class Title
                                property = "ALiVE_OverrideLoadout"; // Unique config property name saved in SQM
                                control = "Checkbox"; // UI control base class displayed in Edit Attributes window, points to Cfg3DEN >> Attributes

                                // Expression called when applying the attribute in Eden and at the scenario start
                                // The expression is called twice - first for data validation, and second for actual saving
                                // Entity is passed as _this, value is passed as _value
                                // %s is replaced by attribute config name. It can be used only once in the expression
                                // In MP scenario, the expression is called only on server.
                                expression = "_this setVariable ['%s',_value];";

                                // Expression called when custom property is undefined yet (i.e., when setting the attribute for the first time)
                                // Entity is passed as _this
                                // Returned value is the default value
                                // Used when no value is returned, or when it's of other type than NUMBER, STRING or ARRAY
                                // Custom attributes of logic entities (e.g., modules) are saved always, even when they have default value
                                defaultValue = "false";

                                //--- Optional properties
                                condition = "objectControllable";
                                typeName = "BOOL"; // Defines data type of saved value, can be STRING, NUMBER or BOOL. Used only when control is "Combo", "Edit" or their variants
                          };
                    };
              };
        };
    };
};

class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class ArgumentsBaseUnits
        {
            class Units;
        };
        class AttributesBase
        {
            class Default;
            class Edit; // Default edit box (i.e., text input field)
            class Combo; // Default combo box (i.e., drop-down menu)
            class Checkbox; // Default checkbox (returned value is Bool)
            class CheckboxNumber; // Default checkbox (returned value is Number)
            class ModuleDescription; // Module description
        };
        class ModuleDescription
        {
            class AnyBrain;
        };
    };

    class ModuleAliveBase: Module_F {
        scope = 1;
        displayName = "EditorAliveBase";
        category = "Alive";
        class AttributesBase : AttributesBase
        {
            class ALiVE_ModuleSubTitle : Default
            {
                control = "ALiVE_ModuleSubTitle";
                defaultValue = "''";
            };
            class ALiVE_HiddenAttribute : Default
            {
                control = "ALiVE_HiddenAttribute";
                defaultValue = "''";
            };
            class ALiVE_EditMulti3 : Default
            {
                control = "EditMulti3";
                defaultValue = "''";
            };
            class ALiVE_EditMulti5 : Default
            {
                control = "EditMulti5";
                defaultValue = "''";
            };
            class ALiVE_EditMultilineSQF : Default
            {
                control = "ALiVE_EditMultilineSQF";
                defaultValue = "''";
            };
        };
    };

    class ALiVE_require: ModuleAliveBase
    {
        scope = 2;
        displayName = "$STR_ALIVE_REQUIRES_ALIVE";
        icon = "x\alive\addons\main\icon_requires_alive.paa";
        picture = "x\alive\addons\main\icon_requires_alive.paa";
        functionPriority = 40;
        isGlobal = 2;
        function = "ALiVE_fnc_aliveInit";
        author = MODULE_AUTHOR;

        class Attributes: AttributesBase
        {
            class debug: Combo
            {
                    property =  MVAR(debug);
                    displayName = "$STR_ALIVE_DEBUG";
                    tooltip = "$STR_ALIVE_DEBUG_COMMENT";
                    defaultValue = """false""";
                    class Values
                    {
                            class Yes
                            {
                                    name = "Yes";
                                    value = "true";
                            };
                            class No
                            {
                                    name = "No";
                                    value = "false";
                            };
                    };
            };
            class ALiVE_Versioning: Combo
            {
                    property =  MVAR(ALiVE_Versioning);
                    displayName = "$STR_ALIVE_REQUIRES_ALIVE_VERSIONING";
                    tooltip = "$STR_ALIVE_REQUIRES_ALIVE_VERSIONING_COMMENT";
                    defaultValue = """warning""";
                    class Values
                    {
                            class warning
                            {
                                    name = "Warn players";
                                    value = "warning";
                            };
                            class kick
                            {
                                    name = "Kick players";
                                    value = "kick";
                            };
                    };
            };

            class ALiVE_AI_DISTRIBUTION: Combo
            {
                    property =  MVAR(ALiVE_AI_DISTRIBUTION);
                    displayName = "$STR_ALIVE_REQUIRES_ALIVE_AI_DISTRIBUTION";
                    tooltip = "$STR_ALIVE_REQUIRES_ALIVE_AI_DISTRIBUTION_COMMENT";
                    defaultValue = """false""";
                    class Values
                    {
                            class off
                            {
                                    name = "Server";
                                    value = "false";
                            };
                            class on
                            {
                                    name = "Headless clients";
                                    value = "true";
                            };
                    };
            };

            class ALiVE_DISABLESAVE: Combo
            {
                    property =  MVAR(ALiVE_DISABLESAVE);
                    displayName = "$STR_ALIVE_DISABLESAVE";
                    tooltip = "$STR_ALIVE_DISABLESAVE_COMMENT";
                    defaultValue = """true""";
                    class Values
                    {
                            class warning
                            {
                                    name = "Yes";
                                    value = "true";
                            };
                            class kick
                            {
                                    name = "No";
                                    value = "false";
                            };
                    };
            };
            class ALiVE_DISABLEMARKERS: Combo
            {
                    property =  MVAR(ALiVE_DISABLEMARKERS);
                    displayName = "$STR_ALIVE_DISABLEMARKERS";
                    tooltip = "$STR_ALIVE_DISABLEMARKERS_COMMENT";
                    typeName = "BOOL";
                    defaultValue = "false";
                    class Values
                    {
                            class Yes
                            {
                                    name = "Yes";
                                    value = 1;
                            };
                            class No
                            {
                                    name = "No";
                                    value = 0;
                            };
                    };
            };
            class ALiVE_DISABLEADMINACTIONS: Combo
            {
                    property =  MVAR(ALiVE_DISABLEADMINACTIONS);

                    displayName = "$STR_ALIVE_DISABLEADMINACTIONS";
                    tooltip = "$STR_ALIVE_DISABLEADMINACTIONS_COMMENT";
                    typeName = "BOOL";
                    defaultValue = "false";
                    class Values
                    {
                            class Yes
                            {
                                    name = "Yes";
                                    value = 1;
                            };
                            class No
                            {
                                    name = "No";
                                    value = 0;
                            };
                    };
            };
            class ALiVE_PAUSEMODULES: Combo
            {
                    property =  MVAR(ALiVE_PAUSEMODULES);
                    displayName = "$STR_ALiVE_PAUSEMODULES";
                    tooltip = "$STR_ALiVE_PAUSEMODULES_COMMENT";
                    typeName = "BOOL";
                    defaultValue = "false";
                    class Values
                    {
                            class Yes
                            {
                                    name = "Yes";
                                    value = 1;
                            };
                            class No
                            {
                                    name = "No";
                                    value = 0;
                            };
                    };
            };
            class ALiVE_GC_INTERVAL: Edit
            {
                    property =  MVAR(ALiVE_GC_INTERVAL);
                    displayName = "$STR_ALIVE_GC_INTERVAL";
                    tooltip = "$STR_ALIVE_GC_INTERVAL_COMMENT";
                    defaultValue = """300""";
            };
            class ALiVE_GC_THRESHHOLD: Edit
            {
                    property =  MVAR(ALiVE_GC_THRESHHOLD);
                    displayName = "$STR_ALIVE_GC_THRESHHOLD";
                    tooltip = "$STR_ALIVE_GC_THRESHHOLD_COMMENT";
                    defaultValue = """100""";
            };
            class ALiVE_GC_INDIVIDUALTYPES: Edit
            {
                    property =  MVAR(ALiVE_GC_INDIVIDUALTYPES);
                    displayName = "$STR_ALIVE_GC_INDIVIDUALTYPES";
                    tooltip = "$STR_ALIVE_GC_INDIVIDUALTYPES_COMMENT";
                    defaultValue = """""";
            };
            class ALiVE_TABLET_MODEL: Combo
            {
                property =  MVAR(ALiVE_TABLET_MODEL);
                displayName = "$STR_ALiVE_TABLET_MODEL";
                tooltip = "$STR_ALiVE_TABLET_MODEL_COMMENT";
                typeName = "STRING";
                defaultValue = """Tablet01""";
                class Values
                {
                    class Tablet01
                    {
                        name = "Tablet 1";
                        value = "Tablet01";
                    };
                    class MapBag01
                    {
                        name = "Mapbag 1";
                        value = "Mapbag01";
                    };
                };
            };
            class ModuleDescription: ModuleDescription{};
        };
        class ModuleDescription: ModuleDescription
        {
            //description = "$STR_ALIVE_REQUIRES_COMMENT"; // Short description, will be formatted as structured text
            description[] = {
                "$STR_ALIVE_REQUIRES_ALIVE",
                "",
                "$STR_ALIVE_REQUIRES_USAGE"
            };
            sync[] = {}; // Array of synced entities (can contain base classes)
        };
    };
};
