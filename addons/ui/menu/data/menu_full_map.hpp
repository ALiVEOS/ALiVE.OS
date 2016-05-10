// GUI editor: configfile >> "AliveMenuMapFull"

class AliveMenuMapFull
{
    idd = 13801;
    movingEnable = true;
    enableSimulation = true;

    class controls
    {

        class AliveMenuFullMap_background : RscPicture
        {
            idc = -1;
            x = safezoneX;
            y = safezoneY;
            w = safezoneW;
            h = safezoneH;
            colorText[] = {1,1,1,1};
            text = "x\alive\addons\ui\alive_bg.paa";
        };

        class AliveMenuFullMap_textBackground : AliveUI_RscBackground
        {
            idc = -1;
            x = safezoneX;
            y = safezoneY + (0.028 * safezoneH);
            w = 0.3 * safezoneW;
            h = 0.941 * safezoneH;
            text="";
            colorBackground[] = {0.271,0.278,0.278,0.4};
        };

        class AliveMenuFullMap_header : AliveUI_RscBackground
        {
            idc = -1;
            x = safezoneX;
            y = safezoneY;
            w = 0.3 * safezoneW;
            h = 0.025 * safezoneH;
            text="";
            colorBackground[] = {0.145,0.204,0.22,0.9};
        };

        class AliveMenuFullMap_logo : RscPictureKeepAspect
        {
            idc = -1;
            x = safezoneX + (0.019 * safezoneW);
            y = safezoneY - (safezoneH * 0.01);
            w = 0.04 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = {1,1,1,1};
            text = "x\alive\addons\ui\logo_alive_white_crop.paa";
        };

        class AliveMenuFullMap_structuredText: AliveUI_RscStructuredText
        {
            idc = 13802;
            x = safezoneX + (0.016 * safezoneW);
            y = safezoneY + (0.028 * safezoneH);
            w = 0.25 * safezoneW;
            h = 0.941 * safezoneH;
            sizeEx = 0.1;
            colorBackground[] = {0,0,0,0};
            colorText[] = {0.616,0.812,0.894,1};
        };

        class AliveMenuFullMap_subMenuAbortButton : AliveUI_RscButton
        {
            idc = 13803;
            text = "Close";
            x = safezoneX;
            y = safezoneY + (safezoneH - (0.028 * safezoneH));
            w = 0.3 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

        class AliveMenuFullMap_taskingMap : AliveUI_RscMap
        {
            idc = 13804;
            x = 0.303 * safezoneW + safezoneX;
            y = safezoneY;
            w = 0.697 * safezoneW;
            h = safezoneH;
        };

    };
};