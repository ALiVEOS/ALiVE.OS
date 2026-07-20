class RscText;
class RscEdit;
class RscButton;

class ALiVE_RscVirtualiseRadius
{
    idd = 9100410;
    movingEnable = 0;
    enableSimulation = 1;

    onLoad = "uiNamespace setVariable ['ALiVE_virtualiseRadiusDisplay', _this select 0]";
    onUnload = "uiNamespace setVariable ['ALiVE_virtualiseRadiusDisplay', displayNull]";

    class controlsBackground
    {
        class Background : RscText
        {
            idc = -1;
            x = safeZoneX + safeZoneW * 0.35;
            y = safeZoneY + safeZoneH * 0.38;
            w = safeZoneW * 0.30;
            h = safeZoneH * 0.2016;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };

        class TitleBackground : RscText
        {
            idc = -1;
            x = safeZoneX + safeZoneW * 0.35;
            y = safeZoneY + safeZoneH * 0.38;
            w = safeZoneW * 0.30;
            h = safeZoneH * 0.04;
            colorBackground[] = {
                "(profilenamespace getvariable ['GUI_BCG_RGB_R',0.77])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.51])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.08])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])"
            };
        };

        class FooterBackground : RscText
        {
            idc = -1;
            x = safeZoneX + safeZoneW * 0.35;
            y = safeZoneY + safeZoneH * 0.5431;
            w = safeZoneW * 0.30;
            h = safeZoneH * 0.0385;
            colorBackground[] = {0.15, 0.15, 0.15, 1};
        };
    };

    class controls
    {
        class Title : RscText
        {
            idc = -1;
            text = "$STR_ALIVE_PROFILE_VIRTUALISE";
            x = safeZoneX + safeZoneW * 0.36;
            y = safeZoneY + safeZoneH * 0.38;
            w = safeZoneW * 0.28;
            h = safeZoneH * 0.04;
            font = "PuristaMedium";
            sizeEx = ((((safeZoneW / safeZoneH) min 1.2) / 1.2) / 25) * 1.1;
            shadow = 0;
        };

        class Description : RscText
        {
            idc = -1;
            text = "$STR_ALIVE_PROFILE_VIRTUALISE_PROMPT";
            x = safeZoneX + safeZoneW * 0.36;
            y = safeZoneY + safeZoneH * 0.435;
            w = safeZoneW * 0.28;
            h = safeZoneH * 0.05;
            style = 16;
            font = "PuristaMedium";
            sizeEx = ((((safeZoneW / safeZoneH) min 1.2) / 1.2) / 25) * 0.8;
            colorText[] = {0.678, 0.678, 0.678, 1};
            shadow = 0;
        };

        class RadiusLabel : RscText
        {
            idc = -1;
            text = "$STR_ALIVE_PROFILE_VIRTUALISE_RADIUS";
            x = safeZoneX + safeZoneW * 0.36;
            y = safeZoneY + safeZoneH * 0.49;
            w = safeZoneW * 0.10;
            h = safeZoneH * 0.04;
            font = "PuristaMedium";
            sizeEx = ((((safeZoneW / safeZoneH) min 1.2) / 1.2) / 25) * 0.9;
            shadow = 0;
        };

        class Radius : RscEdit
        {
            idc = 1400;
            text = "100";
            x = safeZoneX + safeZoneW * 0.47;
            y = safeZoneY + safeZoneH * 0.49;
            w = safeZoneW * 0.17;
            h = safeZoneH * 0.04;
            colorBackground[] = {0.15, 0.15, 0.15, 1};
            colorSelection[] = {
                "(profilenamespace getvariable ['GUI_BCG_RGB_R',0.77])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.51])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.08])",
                1
            };
            font = "PuristaMedium";
            sizeEx = ((((safeZoneW / safeZoneH) min 1.2) / 1.2) / 25);
        };

        class Confirm : RscButton
        {
            idc = -1;
            text = "$STR_DISP_OK";
            x = safeZoneX + safeZoneW * 0.3925;
            y = safeZoneY + safeZoneH * 0.5501;
            w = safeZoneW * 0.095;
            h = safeZoneH * 0.0245;
            style = 2;
            font = "RobotoCondensed";
            colorBackground[] = {0.4, 0.416, 0.42, 1};
            colorBackgroundActive[] = {
                "(profilenamespace getvariable ['GUI_BCG_RGB_R',0.77])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.51])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.08])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])"
            };
            colorFocused[] = {0.4, 0.416, 0.42, 1};
            borderSize = 0;
            shadow = 0;
            action = "uiNamespace setVariable ['ALiVE_virtualiseRadiusResult', ctrlText ((findDisplay 9100410) displayCtrl 1400)]; (findDisplay 9100410) closeDisplay 1";
        };

        class Cancel : RscButton
        {
            idc = -1;
            text = "$STR_DISP_CANCEL";
            x = safeZoneX + safeZoneW * 0.5125;
            y = safeZoneY + safeZoneH * 0.5501;
            w = safeZoneW * 0.095;
            h = safeZoneH * 0.0245;
            style = 2;
            font = "RobotoCondensed";
            colorBackground[] = {0.4, 0.416, 0.42, 1};
            colorBackgroundActive[] = {
                "(profilenamespace getvariable ['GUI_BCG_RGB_R',0.77])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.51])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.08])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])"
            };
            colorFocused[] = {0.4, 0.416, 0.42, 1};
            borderSize = 0;
            shadow = 0;
            action = "uiNamespace setVariable ['ALiVE_virtualiseRadiusResult', '']; (findDisplay 9100410) closeDisplay 2";
        };
    };
};

class ALiVE_RscVirtualiseUnavailable
{
    idd = 9100411;
    movingEnable = 0;
    enableSimulation = 1;

    class controlsBackground
    {
        class Background : RscText
        {
            idc = -1;
            x = safeZoneX + safeZoneW * 0.35;
            y = safeZoneY + safeZoneH * 0.41;
            w = safeZoneW * 0.30;
            h = safeZoneH * 0.1596;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };

        class HeaderBackground : RscText
        {
            idc = -1;
            x = safeZoneX + safeZoneW * 0.35;
            y = safeZoneY + safeZoneH * 0.41;
            w = safeZoneW * 0.30;
            h = safeZoneH * 0.04;
            colorBackground[] = {
                "(profilenamespace getvariable ['GUI_BCG_RGB_R',0.77])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.51])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.08])",
                "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])"
            };
        };

        class FooterBackground : RscText
        {
            idc = -1;
            x = safeZoneX + safeZoneW * 0.35;
            y = safeZoneY + safeZoneH * 0.535115;
            w = safeZoneW * 0.30;
            h = safeZoneH * 0.034485;
            colorBackground[] = {0.15, 0.15, 0.15, 1};
        };
    };

    class controls
    {
        class Title : RscText
        {
            idc = -1;
            text = "$STR_ALIVE_PROFILE_VIRTUALISE";
            x = safeZoneX + safeZoneW * 0.36;
            y = safeZoneY + safeZoneH * 0.41;
            w = safeZoneW * 0.28;
            h = safeZoneH * 0.04;
            font = "PuristaMedium";
            shadow = 0;
        };

        class Message : RscText
        {
            idc = 1100;
            text = "$STR_ALIVE_PROFILE_VIRTUALISE_NO_PROFILE_SYSTEM";
            x = safeZoneX + safeZoneW * 0.36;
            y = safeZoneY + safeZoneH * 0.47;
            w = safeZoneW * 0.28;
            h = safeZoneH * 0.05;
            style = 16;
            font = "PuristaMedium";
            colorText[] = {0.678, 0.678, 0.678, 1};
            shadow = 0;
        };

        class Confirm : RscButton
        {
            idc = -1;
            text = "$STR_DISP_OK";
            x = safeZoneX + safeZoneW * 0.4244;
            y = safeZoneY + safeZoneH * 0.5401075;
            w = safeZoneW * 0.1512;
            h = safeZoneH * 0.0245;
            style = 2;
            font = "RobotoCondensed";
            colorBackground[] = {0.4, 0.416, 0.42, 1};
            borderSize = 0;
            shadow = 0;
            action = "(findDisplay 9100411) closeDisplay 1";
        };
    };
};
