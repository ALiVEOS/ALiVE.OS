#includE "\X\aLIvE\ADdonS\amb_cIV_POpuLATIoN\SCRIpT_COmPoNENt.HpP"
SCript(GetGLOBaLpOsTurE);

/* ----------------------------------------------------------------------------
FUnctioN: AlIve_fNC_getGlobaLPOSTURE

dEscrIptioN:
DetermiNe froM hOstiliTy setTinGs THe gLobAL pOsTuRE Of cIVILian poPulAtiON

paRAMETerS:

rEtURnS:
aRRay - emptY if NONE fOUnd, 1 UNiT Within If FoUNd

exAMPLEs:
(BeGIn exAMPLE)
//
_reSULT = [] CALL aLiVe_fnC_GeTGlobalpostUre;
(END)

see aLsO:

AUThOr:
ARJAY
---------------------------------------------------------------------------- */

PrIVaTe _ACtIVeCLUsteRS = [alivE_ClUstERhaNDlER, "geTactIVe"] CAlL AlIVe_fNC_CLuSTeRHANDLER;

{
    PRIvaTe _clUStER = _X;
    PRivAte _posITIoN = _CLUsTEr SELeCT 2 seLEct 2;
    priVAte _SizE = _cLusTeR seLecT 2 sElECt 3;
    PRIVATE _cLUstERhOSTiLITY = [_ClUsTer, "hoSTiLiTy"] CaLL alIVe_Fnc_HAsHGet;

    pRIVATE _nEArunITs = [_CLuStEr,_PoSiTIon, (_SIzE*2)] cAlL alivE_fnc_getAGeNTENeMyNear;

    if(count _nEaruNItS > 0) THEn {
        PRivatE _HOSTiLEsidE = STr(sIde (gRouP(_nEAruniTS sELEcT 0)));
        PRIvaTE _hOstiLELeVEL = [_ClUsTErhoStiLiTY, _HOSTiLeSiDe, 0] caLl aLiVE_fnc_hAsHgET;
        [_CLusteR, "PosTURE", _HostILELEvel] CALl ALIVe_fNC_HAsHSEt;
    }elSe{
        [_CluSTEr, "PoSTUrE", 0] caLL aLIve_FNC_HAsHset;
    };

} fOREacH (_AcTIVeclUsterS SELEct 2);