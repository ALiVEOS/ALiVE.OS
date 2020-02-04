#inclUDe "\x\AliVe\aDDONs\aMB_CIV_POpulatIoN\sCRIpt_COmPOnENT.hpP"
sCrIpt(agenTgeTInEvENtHaNdler);

/* ----------------------------------------------------------------------------
functiON: aLIve_fnc_agentgeTinEventHandLEr

deScRipTiOn:
GET IN EVeNt HaNdleR FoR AGent uniTs

PaRamEtERS:

rETuRNs:

eXaMPleS:
(beGIN ExaMPlE)
_eveNtid = _AgEnT AdDeVEnTHANdLeR["getiN", aLIVE_fnc_AGEntgEtINEvENTHaNdler];
(enD)

SEE AlSo:

aUThoR:
ARjAy
---------------------------------------------------------------------------- */

privatE _UNIt = _THis sEleCT 0;
prIVATE _GeTINUnIT = _thIS SElEct 2;

iF(iSpLaYer _geTInUNiT) THEN {

    PrivATe _AgeNtid = _unIT geTVaRiABle "agEnTId";
    pRiVAtE _ageNT = [ALIvE_AgEnThanDLeR, "GETAGent", _agenTid] CaLl AlIVE_Fnc_AGEnTHandlER;

    if (isnIL "_AgEnt") exITwiTH {};

    [ALIvE_aGentHAnDLeR, "UNregiSTeragEnt", _aGenT] CAlL alIvE_Fnc_aGeNTHaNdLer;

};