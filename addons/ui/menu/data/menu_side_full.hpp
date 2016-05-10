// GUI editor: configfile >> "AliveMenuSideFull"

class AliveMenuSideFull
{
    idd = -1;
    duration = 30;
    movingEnable = true;
    enableSimulation = true;
    name= "AliveMenuSideFull";
    onLoad = "uiNamespace setVariable ['AliveMenuSideFull', _this select 0]";

    class controls
    {

        class AliveMenuSideFull_background : AliveUI_RscBackground
        {
            idc = -1;
            x = safezoneX;
            y = safezoneY + (0.028 * safezoneH);
            w = 0.2 * safezoneW;
            h = 1 * safezoneH;
            text="";
            colorBackground[] = {0.271,0.278,0.278,0.6};
        };

        class AliveMenuSideFull_header : AliveUI_RscBackground
        {
            idc = -1;
            x = safezoneX;
            y = safezoneY;
            w = 0.2 * safezoneW;
            h = 0.025 * safezoneH;
            text="";
            colorBackground[] = {0.145,0.204,0.22,0.9};
        };

        class AliveMenuSideFull_logo : RscPictureKeepAspect
        {
            idc = -1;
            x = safezoneX + (0.004 * safezoneW);
            y = safezoneY - (safezoneH * 0.007);
            w = 0.04 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = {1,1,1,1};
            text = "x\alive\addons\ui\logo_alive_white_crop.paa";
        };

        class AliveMenuSideFull_structuredText: AliveUI_RscStructuredText
        {
            idc = 14302;
            x = safezoneX + (0.016 * safezoneW);
            y = safezoneY + (0.028 * safezoneH);
            w = 0.15 * safezoneW;
            h = 0.908 * safezoneH;
            sizeEx = 0.1;
            colorBackground[] = {0,0,0,0};
            colorText[] = {0.616,0.812,0.894,1};
        };

    };
};