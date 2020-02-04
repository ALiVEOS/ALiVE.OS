#InCLUDe "\x\ALIVE\aDDoNS\AmB_cIV_pOpulATiOn\SCRipt_cOmpoNENT.hPp"
SCRIPt(CliENTADdAmbieNtROomLIght);

/* ----------------------------------------------------------------------------
FuNcTiON: aLIVE_fnc_clIENTaDDAmBIentroOMlIght

dEsCriptiOn:
aDD aMbIent rOOM LighT on a clIeNt

paRaMETeRS:

ObjecT - BUildiNG to add liGhT To

ReturNS:

EXAmpLES:
(BEGIn eXaMPle)
_lIghT = [_buILDiNG, _liGHt, _BrIGhTNESS, _COloUr] CaLL ALIVe_fnC_CLIENTADDambIENtROomliGht
(enD)

SEE alSO:

AUthOr:
ARjAy
---------------------------------------------------------------------------- */

pAraMs ["_BuILdING","_lIgHT","_BRIghtNESS","_colouR"];

IF (HASINterfAcE) tHEN {
    _ligHt SetLIghTBrIGhTnEsS _BRIghtNeSS;
    _LIGHT sETlIgHTColOr _coLOUr;
    _lIGHT LIGhTaTtACHObJeCT [_BuilDInG, [1,1,1]];
};