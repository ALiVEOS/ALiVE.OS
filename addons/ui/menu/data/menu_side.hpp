// GUI editor: configfile >> "AliveMenuSide"

class AliveMenuSide
{
    idd = -1;
    duration = 30;
    movingEnable = true;
    enableSimulation = true;
    name= "AliveMenuSide";
    onLoad = "uiNamespace setVariable ['AliveMenuSide', _this select 0]";

    class controls
    {

        class AliveMenuSide_background : AliveUI_RscBackground
        {
            idc = -1;
            x = safeZoneX + safeZoneW - 0.51 * 3 / 4;
            y = safeZoneY + safeZoneH - 0.5;
            h = 0.5;
            w = 0.51 * 3 / 4; //w == h
            text="";
            colorBackground[] = {0.271,0.278,0.278,0.6};
        };

        class AliveMenuSide_header : AliveUI_RscBackground
        {
            idc = -1;
            x = safeZoneX + safeZoneW - 0.51 * 3 / 4;
            y = safeZoneY + safeZoneH - 0.55;
            w = 0.51 * safezoneW;
            h = 0.025 * safezoneH;
            text="";
            colorBackground[] = {0.145,0.204,0.22,0.9};
        };

        class AliveMenuSide_logo : RscPictureKeepAspect
        {
            idc = -1;
            x = safeZoneX + safeZoneW - 0.5 * 3 / 4;
            y = safeZoneY + safeZoneH - 0.563;
            w = 0.04 * safezoneW;
            h = 0.04 * safezoneH;
            text = "x\alive\addons\ui\logo_alive_white_crop.paa";
        };

        class AliveMenuSide_structuredText: AliveUI_RscStructuredText
        {
            idc = 13202;
            x = safeZoneX + safeZoneW - 0.5 * 3 / 4;
            y = safeZoneY + safeZoneH - 0.5;
            h = 0.5;
            w = 0.5 * 3 / 4; //w == h
            sizeEx = 0.1;
            colorBackground[] = {0,0,0,0};
            colorText[] = {0.616,0.812,0.894,1};
        };

    };
};