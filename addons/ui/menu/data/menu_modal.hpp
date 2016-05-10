// GUI editor: configfile >> "AliveMenuModal"

class AliveMenuModal
{
    idd = 13101;
    movingEnable = true;
    enableSimulation = true;

    class controls
    {

        class AliveMenuModal_background : AliveUI_RscBackground
        {
            idc = -1;
            x = 0.3 * safezoneW + safezoneX;
            y = (0.3 + 0.028) * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.4 * safezoneH;
            text="";
            colorBackground[] = {0.271,0.278,0.278,0.6};
        };

        class AliveMenuModal_header : AliveUI_RscBackground
        {
            idc = -1;
            x = 0.3 * safezoneW + safezoneX;
            y = 0.3 * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.025 * safezoneH;
            text="";
            colorBackground[] = {0.145,0.204,0.22,0.9};
        };

        class AliveMenuModal_logo : RscPictureKeepAspect
        {
            idc = -1;
            x = 0.304 * safezoneW + safezoneX;
            y = 0.294 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = {1,1,1,1};
            text = "x\alive\addons\ui\logo_alive_white_crop.paa";
        };

        class AliveMenuModal_structuredText: AliveUI_RscStructuredText
        {
            idc = 13102;
            x = 0.3 * safezoneW + safezoneX;
            y = (0.3 + 0.028) * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.4 * safezoneH;
            sizeEx = 0.1;
            colorBackground[] = {0,0,0,0};
            colorText[] = {0.616,0.812,0.894,1};
        };

        class AliveMenuFull_subMenuAbortButton : AliveUI_RscButton
        {
            idc = 13103;
            text = "Close";
            x = 0.3 * safezoneW + safezoneX;
            y = (0.7 + 0.031) * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
        };

    };
};