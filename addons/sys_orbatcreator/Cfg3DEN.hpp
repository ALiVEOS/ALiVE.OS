class Cfg3DEN
{
    class Attributes
    {
        class Combo;

        class ALiVE_ArsenalType : Combo
        {
            attributeLoad = "_this call compile preprocessFileLineNumbers '\x\alive\addons\sys_orbatcreator\fnc_edenArsenalTypeLoad.sqf'";
            attributeSave = "_this call compile preprocessFileLineNumbers '\x\alive\addons\sys_orbatcreator\fnc_edenArsenalTypeSave.sqf'";
        };
    };
};
