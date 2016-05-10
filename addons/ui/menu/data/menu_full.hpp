// GUI editor: configfile >> "AliveMenuFull"

class AliveMenuFull
{
    idd = 13901;
    movingEnable = true;
    enableSimulation = true;

    class controls
    {

        class AliveMenuFull_background : AliveUI_RscBackground
        {
            idc = 13902;
            x = safezoneX;
            y = safezoneY + (0.028 * safezoneH);
            w = 0.3 * safezoneW;
            h = 0.908 * safezoneH;
            text="";
            colorBackground[] = {0.271,0.278,0.278,0.6};
        };

        class AliveMenuFull_header : AliveUI_RscBackground
        {
            idc = 13903;
            x = safezoneX;
            y = safezoneY;
            w = 0.3 * safezoneW;
            h = 0.025 * safezoneH;
            text="";
            colorBackground[] = {0.145,0.204,0.22,0.9};
        };

        class AliveMenuFull_logo : RscPictureKeepAspect
        {
            idc = 13904;
            x = safezoneX + (0.004 * safezoneW);
            y = safezoneY - (safezoneH * 0.007);
            w = 0.04 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = {1,1,1,1};
            text = "x\alive\addons\ui\logo_alive_white_crop.paa";
        };

        class AliveMenuFull_structuredText: AliveUI_RscStructuredText
        {
            idc = 13905;
            x = safezoneX + (0.016 * safezoneW);
            y = safezoneY + (0.028 * safezoneH);
            w = 0.25 * safezoneW;
            h = 0.908 * safezoneH;
            sizeEx = 0.1;
            colorBackground[] = {0,0,0,0};
            colorText[] = {0.616,0.812,0.894,1};
        };

        class AliveMenuFull_subMenuHideButton : AliveUI_RscButton
        {
            idc = 13906;
            text = "Hide";
            x = safezoneX;
            y = safezoneY + (safezoneH - (0.06 * safezoneH));
            w = 0.3 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.145,0.204,0.22,0.9};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.145,0.204,0.22,0.9};
            colorFocused[] = {0.145,0.204,0.22,0.9};
        };

        class AliveMenuFull_subMenuAbortButton : AliveUI_RscButton
        {
            idc = 13907;
            text = "Close";
            x = safezoneX;
            y = safezoneY + (safezoneH - (0.028 * safezoneH));
            w = 0.3 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.376,0.196,0.204,1};
            colorFocused[] = {0.376,0.196,0.204,1};
        };

    };
};