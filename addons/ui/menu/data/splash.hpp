// GUI editor: configfile >> "AliveSplash"

class AliveSplash
{
    idd = -1;
    duration = 30;
    movingEnable = false;
    enableSimulation = false;
    name= "AliveSplash";
    onLoad = "uiNamespace setVariable ['AliveSplash', _this select 0]";

    class controls
    {

        class AliveSplash_background : RscPicture
        {
            idc = -1;
            x = safezoneX;
            y = safezoneY;
            w = safezoneW;
            h = safezoneH;
            colorText[] = {1,1,1,1};
            text = "x\alive\addons\ui\alive_bg.paa";
        };

        class AliveSplash_logo : RscPictureKeepAspect
        {
            idc = -1;
            x = 0.3 * safezoneW + safezoneX;
            y = (0.1 + 0.028) * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.4 * safezoneH;
            colorText[] = {1,1,1,1};
            text = "x\alive\addons\ui\logo_alive_square.paa";
        };

        class AliveSplash_structuredText: AliveUI_RscStructuredText
        {
            idc = 14102;
            x = 0.3 * safezoneW + safezoneX;
            y = 0.45 * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.4 * safezoneH;
            sizeEx = 0.1;
            colorBackground[] = {0,0,0,0};
            colorText[] = {0.616,0.812,0.894,1};
        };

    };
};