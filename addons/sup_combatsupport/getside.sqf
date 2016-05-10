_unitType = _logic getvariable ["unittype","BLU_F_Blaaa"];
_faction = gettext(configfile >> "CfgVehicles" >> _unitType >> "faction");
_side = getNumber(configfile >> "CfgVehicles" >> _unitType >> "side");