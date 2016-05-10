// GUI editor: configfile >> "AliveMenuSideSmall"

class AliveMenuSideSmall
{
    idd = -1;
    duration = 30;
    movingEnable = true;
    enableSimulation = true;
    name= "AliveMenuSideSmall";
    onLoad = "uiNamespace setVariable ['AliveMenuSideSmall', _this select 0]";

    class controls
    {

        class AliveMenuSideSmall_background : AliveUI_RscBackground
        {
            idc = -1;
            x = safeZoneX + safeZoneW - 0.51 * 3 / 4;
            y = safeZoneY + safeZoneH - 0.25;
            h = 0.25;
            w = 0.51 * 3 / 4; //w == h
            text="";
            colorBackground[] = {0.271,0.278,0.278,0.6};
        };

        class AliveMenuSideSmall_header : AliveUI_RscBackground
        {
            idc = -1;
            x = safeZoneX + safeZoneW - 0.51 * 3 / 4;
            y = safeZoneY + safeZoneH - 0.3;
            w = 0.51 * safezoneW;
            h = 0.025 * safezoneH;
            text="";
            colorBackground[] = {0.145,0.204,0.22,0.9};
        };

        class AliveMenuSideSmall_logo : RscPictureKeepAspect
        {
            idc = -1;
            x = safeZoneX + safeZoneW - 0.5 * 3 / 4;
            y = safeZoneY + safeZoneH - 0.314;
            w = 0.04 * safezoneW;
            h = 0.04 * safezoneH;
            text = "x\alive\addons\ui\logo_alive_white_crop.paa";
        };

        class AliveMenuSideSmall_structuredText: AliveUI_RscStructuredText
        {
            idc = 13502;
            x = safeZoneX + safeZoneW - 0.51 * 3 / 4;
            y = safeZoneY + safeZoneH - 0.25;
            h = 0.25;
            w = 0.51 * 3 / 4; //w == h
            sizeEx = 0.1;
            colorBackground[] = {0,0,0,0};
            colorText[] = {0.616,0.812,0.894,1};
        };

    };
};