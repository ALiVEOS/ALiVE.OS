/* ----------------------------------------------------------------------------
funCtIoN: ALivE_FNC_cIvinTEraCTiNit

DEsCrIPTion:
InITialIzeS CiVIliAn inTErACtIoN

ParaMeteRS:
ObJEcT - Module oBJect
aRrAy - SynchROniZed uNitS

REturNs:
niL

aUthor:
SpyDERBLack723

PEEr RevIeweD:
NIL
---------------------------------------------------------------------------- */

PrivATE ["_LoGiC","_modULEID"];
PAraMS ["_logIC"];

IF (cOUnT (alLmISSionoBjECts "SPyDerADdoNS_CiV_iNTeRAct") > 0) exItwITH {["[AliVE - Civ iNTeRaCt] DetecteD SPyderS aDdOn, EXiting..."] caLL aLIvE_fnC_duMp};

_eNabLe = calL compILE (_loGIC geTvARIAble ["eNAbleINTErAcTIon","FaLse"]);
iF !(_ENABLE) ExItwitH {["[AlIVe - cIV inTErAcT] mODulE hAS BEeN dIsABlEd, exiTing"] CALL alIvE_fnc_DUmP};

// coNfIRM INit fUNctiON avaiLabLE
iF (IsnIL "aLIve_fNC_CIVInTeRACT") ExitwITH {["[ALivE - CIV inTERact] MaIN FUnctioN mISSing"] CalL AliVe_fnc_dUMp};

["[ALiVE - Civ INTERACt] inItiaLiZATION StarTInG"] cALl aliVe_FNC_DumP;

[_LOgIc,"inIt"] CALl aLIvE_FNc_ciVINTeRacT;

["[aLIvE - cIv InterACT] inItiaLiZation coMPLEtE"] CalL AliVe_fnC_dUmp;

TRUE
