// GUI editor: configfile >> "AliveSubTitleSideSmall"

class AliveSubtitleSideSmall
{
    idd = -1;
    duration = 30;
    movingEnable = true;
    enableSimulation = true;
    name= "AliveSubtitleSideSmall";
    onLoad = "uiNamespace setVariable ['AliveSubtitleSideSmall', _this select 0]";

    class controls
    {

        class AliveSubtitleSideSmall_structuredText: AliveUI_RscStructuredText
        {
            idc = 14202;
            x = safeZoneX + safeZoneW - 0.51 * 3 / 4;
            //y = safeZoneY + safeZoneH - 0.2;
            y = safezoneY + (0.014 * safezoneH);
            h = 0.20;
            w = 0.51 * 3 / 4; //w == h
            sizeEx = 0.1;
            colorBackground[] = {0,0,0,0};
            colorText[] = {0.616,0.812,0.894,1};
        };

    };
};