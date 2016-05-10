// GUI editor: configfile >> "AliveMenuSide"

class AliveMenuSideTop
{
    idd = -1;
    duration = 30;
    movingEnable = true;
    enableSimulation = true;
    name= "AliveMenuSide";
    onLoad = "uiNamespace setVariable ['AliveMenuSide', _this select 0]";

    class controls
    {

        class AliveMenuSideTop_background : AliveUI_RscBackground
        {
            idc = -1;
            x = safeZoneX + safeZoneW - 0.51 * 3 / 4;
            y = (0.15 + 0.028) * safezoneH + safezoneY;
            h = 0.5;
            w = 0.51 * 3 / 4; //w == h
            text="";
            colorBackground[] = {0.271,0.278,0.278,0.6};
        };

        class AliveMenuSideTop_header : AliveUI_RscBackground
        {
            idc = -1;
            x = safeZoneX + safeZoneW - 0.51 * 3 / 4;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.51 * safezoneW;
            h = 0.025 * safezoneH;
            text="";
            colorBackground[] = {0.145,0.204,0.22,0.9};
        };

        class AliveMenuSideTop_logo : RscPictureKeepAspect
        {
            idc = -1;
            x = safeZoneX + safeZoneW - 0.5 * 3 / 4;
            y = 0.143 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.04 * safezoneH;
            text = "x\alive\addons\ui\logo_alive_white_crop.paa";
        };

        class AliveMenuSideTop_structuredText: AliveUI_RscStructuredText
        {
            idc = 13402;
            x = safeZoneX + safeZoneW - 0.5 * 3 / 4;
            y = (0.15 + 0.028) * safezoneH + safezoneY;
            h = 0.5;
            w = 0.5 * 3 / 4; //w == h
            sizeEx = 0.1;
            colorBackground[] = {0,0,0,0};
            colorText[] = {0.616,0.812,0.894,1};
        };

    };
};