#include <\x\alive\addons\ui\script_component.hpp>
SCRIPT(displayMenu);

/* ----------------------------------------------------------------------------
Function: displayMenu
Description:
Display various UI menus

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:

Examples:
(begin example)

// open full menu
[["openFull"],"ALIVE_fnc_displayMenu",player,false,false] spawn BIS_fnc_MP;

// open map full menu
[["openMapFull"],"ALIVE_fnc_displayMenu",player,false,false] spawn BIS_fnc_MP;

// open side menu
[["openSide"],"ALIVE_fnc_displayMenu",player,false,false] spawn BIS_fnc_MP;

// open side menu
[["openSideTop"],"ALIVE_fnc_displayMenu",player,false,false] spawn BIS_fnc_MP;

// open modal menu
[["openModal"],"ALIVE_fnc_displayMenu",player,false,false] spawn BIS_fnc_MP;

// open wide menu
[["openWide"],"ALIVE_fnc_displayMenu",player,false,false] spawn BIS_fnc_MP;

// close menu for player
[["close"],"ALIVE_fnc_displayMenu",player,false,false] spawn BIS_fnc_MP;

// set full menu text
[["setFullText","cheese"],"ALIVE_fnc_displayMenu",player,false,false] spawn BIS_fnc_MP;



// set side menu text
[["setSideText","cheese"],"ALIVE_fnc_displayMenu",player,false,false] spawn BIS_fnc_MP;

_image = "<img src='logo_alive_white_crop.paa'/>";
_title = "<t size='2'>Heading</t>";
_separator = "<br/>";
_text1 = "<t shadow='1'>Text with shadow</t>
         <t shadow='1' shadowColor='#ff0000'>Text with red Shadow</t>
         <t shadow='2'>Text with outline</t>";
_text2 = "<t font='EtelkaMonospacePro'>EtelkaMonospacePro</t><br/><t font='EtelkaMonospacePro'>EtelkaMonospacePro</t><br/><t font='EtelkaMonospaceProBold'>EtelkaMonospaceProBold</t><br/><t font='EtelkaNarrowMediumPro'>EtelkaNarrowMediumPro</t><br/><t font='GillSans'>GillSans</t><br/><t font='LucidaConsoleB'>LucidaConsoleB</t><br/><t font='PuristaLight'>PuristaLight</t><br/><t font='PuristaMedium'>PuristaMedium</t><br/><t font='PuristaSemibold'>PuristaSemibold</t><br/><t font='PuristaBold'>PuristaBold</t><br/>";
_text = format["%1%2%3%4%5%6%7",_image,_separator,_title,_separator,_text1,_separator,_text2];

[["setFullText",_text],"ALIVE_fnc_displayMenu",player,false,false] spawn BIS_fnc_MP;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

// Display components

#define FullMenu_CTRL_MainDisplay 13901
#define FullMenu_CTRL_Background 13902
#define FullMenu_CTRL_Header 13903
#define FullMenu_CTRL_Logo 13904
#define FullMenu_CTRL_Text 13905
#define FullMenu_CTRL_Hide 13906
#define FullMenu_CTRL_Back 13907

#define FullMenuMap_CTRL_MainDisplay 13801
#define FullMenuMap_CTRL_Text 13802
#define FullMenuMap_CTRL_Back 13803
#define FullMenuMap_CTRL_Map 13804

#define FullMenuImage_CTRL_MainDisplay 13601
#define FullMenuImage_CTRL_Text 13602
#define FullMenuImage_CTRL_Back 13603
#define FullMenuImage_CTRL_Image 13604

#define ModalMenu_CTRL_MainDisplay 13101
#define ModalMenu_CTRL_Text 13102
#define ModalMenu_CTRL_Back 13103

#define WideMenu_CTRL_MainDisplay 13301
#define WideMenu_CTRL_Text 13302
#define WideMenu_CTRL_Back 13303

#define SideMenu_CTRL_Text 13202

#define SideMenuTop_CTRL_Text 13402

#define SideMenuTopSmall_CTRL_Text 13702

#define SideMenuSmall_CTRL_Text 13502

#define SideSubtitleSmall_CTRL_Text 14202

#define SplashMenu_CTRL_Text 14102

#define SideMenuFull_CTRL_Text 14302

#define Menu_getControl(disp,ctrl) ((findDisplay ##disp) displayCtrl ##ctrl)

#define KEYSCODE_ESC_KEY 1


private["_action","_args"];

_action = _this select 0;
_args = _this select 1;

switch(_action) do {

    case "openFull":{

        [_args] spawn {

            private["_args","_closeButton","_display"];

            _args = _this select 0;

            disableSerialization;

            createDialog "AliveMenuFull";

            waitUntil {sleep 0.01; (!(isNull (findDisplay FullMenu_CTRL_MainDisplay)))};
            _display = findDisplay FullMenu_CTRL_MainDisplay;
            _display displayAddEventHandler ["KeyDown","['keyHandler',_this] call ALIVE_fnc_displayMenu"];

            if(count _args > 0 ) then {
                ALiVE_displayMenuCallback = _args;
            }else{
                ALiVE_displayMenuCallback = nil;
            };

            _closeButton = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Back);
            _closeButton ctrlShow true;
            _closeButton ctrlSetEventHandler ["MouseButtonClick", "['handleClose'] call ALIVE_fnc_displayMenu"];

            _hideButton = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Hide);
            _hideButton ctrlShow true;
            _hideButton ctrlSetEventHandler ["MouseButtonClick", "['handleHide'] call ALIVE_fnc_displayMenu"];
        };
    };

    case "setFullText":{

        [_args] spawn {

            private["_text"];

            _args = _this select 0;

            disableSerialization;

            waitUntil {sleep 0.01; (!(isNull (findDisplay FullMenu_CTRL_MainDisplay)))};

            _text = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Text);
            _text ctrlShow true;

            _text ctrlSetStructuredText (parseText _args);

        };

    };

    case "handleHide":{

        private["_hideButton","_background","_header","_logo","_text"];

        _hideButton = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Hide);
        _hideButton ctrlShow true;
        _hideButton ctrlSetText "Show";
        _hideButton ctrlSetEventHandler ["MouseButtonClick", "['handleShow'] call ALIVE_fnc_displayMenu"];

        _background = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Background);
        _background ctrlShow false;

        _header = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Header);
        _header ctrlShow false;

        _logo = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Logo);
        _logo ctrlShow false;

        _text = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Text);
        _text ctrlShow false;

    };

    case "handleShow":{

        private["_hideButton","_background","_header","_logo","_text"];

        _hideButton = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Hide);
        _hideButton ctrlShow true;
        _hideButton ctrlSetText "Hide";
        _hideButton ctrlSetEventHandler ["MouseButtonClick", "['handleHide'] call ALIVE_fnc_displayMenu"];

        _background = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Background);
        _background ctrlShow true;

        _header = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Header);
        _header ctrlShow true;

        _logo = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Logo);
        _logo ctrlShow true;

        _text = Menu_getControl(FullMenu_CTRL_MainDisplay,FullMenu_CTRL_Text);
        _text ctrlShow true;

    };

    case "openMapFull":{

        [_args] spawn {

            private["_args","_display","_closeButton"];

            _args = _this select 0;

            disableSerialization;

            createDialog "AliveMenuMapFull";

            waitUntil {sleep 0.01; (!(isNull (findDisplay FullMenuMap_CTRL_MainDisplay)))};
            _display = findDisplay FullMenuMap_CTRL_MainDisplay;
            _display displayAddEventHandler ["KeyDown","['keyHandler',_this] call ALIVE_fnc_displayMenu"];

            if(count _args > 0 ) then {
                ALiVE_displayMenuCallback = _args;
            }else{
                ALiVE_displayMenuCallback = nil;
            };

            _closeButton = Menu_getControl(FullMenuMap_CTRL_MainDisplay,FullMenuMap_CTRL_Back);
            _closeButton ctrlShow true;
            _closeButton ctrlSetEventHandler ["MouseButtonClick", "['handleClose'] call ALIVE_fnc_displayMenu"];

        };
    };

    case "setFullMapText":{

        [_args] spawn {

            private["_text"];

            _args = _this select 0;

            disableSerialization;

            waitUntil {sleep 0.01; (!(isNull (findDisplay FullMenuMap_CTRL_MainDisplay)))};

            _text = Menu_getControl(FullMenuMap_CTRL_MainDisplay,FullMenuMap_CTRL_Text);
            _text ctrlShow true;

            _text ctrlSetStructuredText (parseText _args);

        };

    };

    case "setFullMapAnimation":{

        [_args] spawn {

            _args = _this select 0;

            disableSerialization;

            waitUntil {sleep 0.01; (!(isNull (findDisplay FullMenuMap_CTRL_MainDisplay)))};

            _map = Menu_getControl(FullMenuMap_CTRL_MainDisplay,FullMenuMap_CTRL_Map);

            ctrlMapAnimClear _map;
            _map ctrlMapAnimAdd _args;//[0.5, ctrlMapScale _map, _position];
            ctrlMapAnimCommit _map;

        };

    };

    case "openImageFull":{

        [_args] spawn {

            private["_args","_display","_closeButton"];

            _args = _this select 0;

            disableSerialization;

            createDialog "AliveMenuImageFull";

            waitUntil {sleep 0.01; (!(isNull (findDisplay FullMenuImage_CTRL_MainDisplay)))};
            _display = findDisplay FullMenuImage_CTRL_MainDisplay;
            _display displayAddEventHandler ["KeyDown","['keyHandler',_this] call ALIVE_fnc_displayMenu"];

            if(count _args > 0 ) then {
                ALiVE_displayMenuCallback = _args;
            }else{
                ALiVE_displayMenuCallback = nil;
            };

            _closeButton = Menu_getControl(FullMenuImage_CTRL_MainDisplay,FullMenuImage_CTRL_Back);
            _closeButton ctrlShow true;
            _closeButton ctrlSetEventHandler ["MouseButtonClick", "['handleClose'] call ALIVE_fnc_displayMenu"];

        };
    };

    case "setFullImageText":{

        [_args] spawn {

            private["_text"];

            _args = _this select 0;

            disableSerialization;

            waitUntil {sleep 0.01; (!(isNull (findDisplay FullMenuImage_CTRL_MainDisplay)))};

            _text = Menu_getControl(FullMenuImage_CTRL_MainDisplay,FullMenuImage_CTRL_Text);
            _text ctrlShow true;

            _text ctrlSetStructuredText (parseText _args);

        };

    };

    case "setFullImage":{

        [_args] spawn {

            _args = _this select 0;

            disableSerialization;

            waitUntil {sleep 0.01; (!(isNull (findDisplay FullMenuImage_CTRL_MainDisplay)))};

            _image = Menu_getControl(FullMenuImage_CTRL_MainDisplay,FullMenuImage_CTRL_Image);

            _image ctrlSetText _args;

        };

    };

    case "openModal":{
        
        [_args] spawn {

            private["_args","_display","_closeButton"];

            _args = _this select 0;

            disableSerialization;

            createDialog "AliveMenuModal";

            waitUntil {sleep 0.01; (!(isNull (findDisplay ModalMenu_CTRL_MainDisplay)))};
            _display = findDisplay ModalMenu_CTRL_MainDisplay;
            _display displayAddEventHandler ["KeyDown","['keyHandler',_this] call ALIVE_fnc_displayMenu"];

            if(count _args > 0 ) then {
                ALiVE_displayMenuCallback = _args;
            }else{
                ALiVE_displayMenuCallback = nil;
            };

            _closeButton = Menu_getControl(ModalMenu_CTRL_MainDisplay,ModalMenu_CTRL_Back);
            _closeButton ctrlShow true;
            _closeButton ctrlSetEventHandler ["MouseButtonClick", "['handleClose'] call ALIVE_fnc_displayMenu"];

        };
    };

    case "setModalText":{

        [_args] spawn {

            private["_text"];

            _args = _this select 0;

            disableSerialization;

            waitUntil {sleep 0.01; (!(isNull (findDisplay ModalMenu_CTRL_MainDisplay)))};

            _text = Menu_getControl(ModalMenu_CTRL_MainDisplay,ModalMenu_CTRL_Text);
            _text ctrlShow true;

            _text ctrlSetStructuredText (parseText _args);

        };
    };

    case "openWide":{

        [_args] spawn {

            private["_args","_display","_closeButton"];

            _args = _this select 0;

            disableSerialization;

            createDialog "AliveMenuWide";

            waitUntil {sleep 0.01; (!(isNull (findDisplay WideMenu_CTRL_MainDisplay)))};
            _display = findDisplay WideMenu_CTRL_MainDisplay;
            _display displayAddEventHandler ["KeyDown","['keyHandler',_this] call ALIVE_fnc_displayMenu"];

            if(count _args > 0 ) then {
                ALiVE_displayMenuCallback = _args;
            }else{
                ALiVE_displayMenuCallback = nil;
            };

            _closeButton = Menu_getControl(WideMenu_CTRL_MainDisplay,WideMenu_CTRL_Back);
            _closeButton ctrlShow true;
            _closeButton ctrlSetEventHandler ["MouseButtonClick", "['handleClose'] call ALIVE_fnc_displayMenu"];

        };
    };

    case "setWideText":{

        [_args] spawn {

            private["_text"];

            _args = _this select 0;

            disableSerialization;

            waitUntil {sleep 0.01; (!(isNull (findDisplay WideMenu_CTRL_MainDisplay)))};

            _text = Menu_getControl(WideMenu_CTRL_MainDisplay,WideMenu_CTRL_Text);
            _text ctrlShow true;

            _text ctrlSetStructuredText (parseText _args);

        };
    };

    case "keyHandler":{

        private["_keypressed","_return"];

        _keypressed = _args select 1;
        _return = false;

        // disable esc while in dialog
        switch (_keypressed) do
        {
            case KEYSCODE_ESC_KEY:
            {
                _return = true;
                ['handleClose'] call ALIVE_fnc_displayMenu;
            };
        };
        _return;

    };

    case "handleClose":{

        private["_callbackLogic","_callbackClass","_callbackMethod","_callbackArgs"];

        closeDialog 0;

        if!(isNil "ALiVE_displayMenuCallback") then {
            _callbackLogic = ALiVE_displayMenuCallback select 0;
            _callbackClass = _callbackLogic getVariable "class";
            _callbackMethod = ALiVE_displayMenuCallback select 1;
            _callbackArgs = ALiVE_displayMenuCallback select 2;

            [_callbackLogic,_callbackMethod,["close",_callbackArgs]] call _callbackClass;
        };

    };

    case "openSide":{
        if!(isNil "_args") then {
            1001 cutRsc ["AliveMenuSide","PLAIN",_args];
        }else{
            1001 cutRsc ["AliveMenuSide","PLAIN"];
        }
    };

    case "setSideText":{

        disableSerialization;

        private["_text","_sideDisplay"];

        _sideDisplay = uiNameSpace getVariable "AliveMenuSide";

        _text = _sideDisplay displayCtrl SideMenu_CTRL_Text;
        _text ctrlShow true;

        _text ctrlSetStructuredText (parseText _args);
    };

    case "openSideSmall":{
        if!(isNil "_args") then {
            1002 cutRsc ["AliveMenuSideSmall","PLAIN",_args];
        }else{
            1002 cutRsc ["AliveMenuSideSmall","PLAIN"];
        }
    };

    case "setSideSmallText":{

        disableSerialization;

        private["_text","_sideDisplay"];

        _sideDisplay = uiNameSpace getVariable "AliveMenuSideSmall";

        _text = _sideDisplay displayCtrl SideMenuSmall_CTRL_Text;
        _text ctrlShow true;

        _text ctrlSetStructuredText (parseText _args);
    };

    case "openSideSubtitle":{
        if!(isNil "_args") then {
            1003 cutRsc ["AliveSubtitleSideSmall","PLAIN",_args];
        }else{
            1003 cutRsc ["AliveSubtitleSideSmall","PLAIN"];
        }
    };

    case "closeSideSubtitle":{
        1003 cutText ["", "PLAIN"];
    };

    case "setSideSubtitleSmallText":{

        disableSerialization;

        private["_text","_sideDisplay"];

        _sideDisplay = uiNameSpace getVariable "AliveSubtitleSideSmall";

        _text = _sideDisplay displayCtrl SideSubtitleSmall_CTRL_Text;
        _text ctrlShow true;

        _text ctrlSetStructuredText (parseText _args);
    };

    case "openSideTop":{
        if!(isNil "_args") then {
            1004 cutRsc ["AliveMenuSideTop","PLAIN",_args];
        }else{
            1004 cutRsc ["AliveMenuSideTop","PLAIN"];
        }
    };

    case "setSideTopText":{

        disableSerialization;

        private["_text","_sideDisplay"];

        _sideDisplay = uiNameSpace getVariable "AliveMenuSide";

        _text = _sideDisplay displayCtrl SideMenuTop_CTRL_Text;
        _text ctrlShow true;

        _text ctrlSetStructuredText (parseText _args);
    };

    case "openSideTopSmall":{
        if!(isNil "_args") then {
            1007 cutRsc ["AliveMenuSideTopSmall","PLAIN",_args];
        }else{
            1007 cutRsc ["AliveMenuSideTopSmall","PLAIN"];
        }
    };

    case "setSideTopSmallText":{

        disableSerialization;

        private["_text","_sideDisplay"];

        _sideDisplay = uiNameSpace getVariable "AliveMenuSideTopSmall";

        _text = _sideDisplay displayCtrl SideMenuTopSmall_CTRL_Text;
        _text ctrlShow true;

        _text ctrlSetStructuredText (parseText _args);
    };

    case "closeSideTopSmall":{
        1007 cutText ["", "PLAIN"];
    };

    case "openSplash":{
        if!(isNil "_args") then {
            1005 cutRsc ["AliveSplash","PLAIN",_args];
        }else{
            1005 cutRsc ["AliveSplash","PLAIN"];
        }
    };

    case "closeSplash":{
        1005 cutText ["", "PLAIN"];
    };

    case "setSplashText":{

        disableSerialization;

        private["_text","_splashDisplay"];

        _splashDisplay = uiNameSpace getVariable "AliveSplash";

        _text = _splashDisplay displayCtrl SplashMenu_CTRL_Text;
        _text ctrlShow true;

        _text ctrlSetStructuredText (parseText _args);
    };

    case "openSideFull":{
        if!(isNil "_args") then {
            1006 cutRsc ["AliveMenuSideFull","PLAIN",_args];
        }else{
            1006 cutRsc ["AliveMenuSideFull","PLAIN"];
        }
    };

    case "closeSideFull":{
        1006 cutText ["", "PLAIN"];
    };

    case "setSideFullText":{

        disableSerialization;

        private["_text","_sideFullDisplay"];

        _sideFullDisplay = uiNameSpace getVariable "AliveMenuSideFull";

        _text = _sideFullDisplay displayCtrl SideMenuFull_CTRL_Text;
        _text ctrlShow true;

        _text ctrlSetStructuredText (parseText _args);
    };

};
