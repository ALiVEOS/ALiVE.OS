class Extended_Init_EventHandlers
{
    class MAN
    {
        class ADDON
        {
            init = QUOTE(_this spawn ALiVE_fnc_addCivilianActions);
            clientInit = QUOTE(_this call ALiVE_fnc_addCivilianInteraction);
        };
    };
    // Any box can be handed to a town once it holds enough food and water.
    class ReammoBox_F
    {
        class ADDON
        {
            clientInit = "['addActions', [_this select 0]] call ALiVE_fnc_aidCrate";
        };
    };
};