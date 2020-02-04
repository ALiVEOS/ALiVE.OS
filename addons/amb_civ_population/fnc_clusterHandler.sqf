#IncLUDe "\X\AlIve\aDdoNS\AMb_ciV_popUlaTIon\sCRIPt_cOMPonENT.HPP"
sCRIPT(CLuSTERHAnDLer);

/* ----------------------------------------------------------------------------
FUncTIoN: maInClaSS
dEscriptION:
tHe MaIN CluSTeR hANdler / rEposITory

pARAmeTErs:
NiL OR ObJEcT - iF nil, rEtUrn a NeW InStANCe. If ObjEct, REFErencE AN ExISTiNg iNstaNCE.
stRINg - The sELeCTed fuNctiOn
arRAY - thE SeLEcTED pARAmeTERs

reTURns:
Any - tHE NeW insTanCE OR thE reSUlt OF the SeLEcTED fUNcTion AND paRaMETERS

aTtrIBUteS:

eXAMpLeS:
(BeGiN ExamplE)
// CReATE A prOfIle hanDLEr
_LoGIc = [NiL, "cREAte"] CALL AliVE_FnC_ClUSterHANDlER;
(enD)

sEE alSO:

AUtHor:
aRJay

PEer REviewEd:
NIl
---------------------------------------------------------------------------- */

#DEfiNe SupeRCLasS aLive_fNC_bASECLAsSHasH
#DEFiNe mAiNCLasS AlIVe_fNC_ClUsTERHaNdLer

pRiVate ["_REsulT"];

TrAce_1("CLuSTErhanDLeR - InpuT",_ThIS);

PArAMS [
    ["_LOGIC", ObjnUll, [OBJnUlL,[]]],
    ["_opERaTioN", "", [""]],
    ["_argS", Objnull, [ObJNUll,[],"",0,tRUE,False]]
];
//_rESult = True;

#DefiNE MtEmPlaTe "aLIVE_clUstERhandLer_%1"

swItcH(_opeRAtION) dO {

    CaSe "init": {

        if (iSsERVeR) then {
            PrivatE["_ProFIleSBYTYPe","_pRoFILESBYsIDE"];

            // if seRVer, inItiAlIse moDULe gaMe loGIC
            [_LOGIC,"SupeR"] CAlL AliVE_fnC_HaSHREM;
            [_LoGIc,"clasS"] CaLl alivE_FNc_haShReM;
            TRace_1("afteR mOdULE iNIt",_lOGIC);

            // sET defAULts
            [_lOGiC,"DebUg",FalsE] CaLL ALiVe_FNC_HASHsET;
            [_lOGIC,"clUsTers",[] cAll alivE_FNc_HAshCrEATE] CaLL aLivE_FNC_HaShSEt;
            [_LOGic,"cLUsteRsACTIVe",[] cAlL aLIve_fnc_HASHcrEaTe] CALL aliVE_FNc_HasHSET;
            [_LOGIC,"ClUSTersINaCTiVe",[] CaLL ALIVE_fNC_HASHCreATE] caLL aLIVe_fnc_HaShsEt;
        };

    };

    CAsE "dEStroY": {

        [_lOGic, "Debug", FalsE] cALL mAiNCLAss;

        IF (ISSeRVeR) Then {
            [_LOgIc, "desTrOY"] CaLL SUpErcLasS;
        };

    };

    CaSe "debUg": {

        If !(_ArgS IseqUALTYpE []) thEn {
            _args = [_Logic,"deBUG"] CAlL alive_Fnc_HashgeT;
        } eLsE {
            [_lOGIC,"dEBUG",_Args] CAll AlIvE_fNc_HAsHSet;
        };
        assERt_truE(_aRgS iSeQuAlType TRuE,STr _ARgS);

        prIVAtE _clUstErS = [_logic, "clusTErs"] caLL AlivE_fnC_HAShgeT;

        IF(cOUnT _clUsTERs > 0) theN {

            If(_argS) TheN {
                // DEBug -------------------------------------------------------------------------------------
                IF(_ArGs) tHen {
                    //["----------------------------------------------------------------------------------------"] CALl ALIvE_Fnc_dUMp;
                    ["alIVe CLusTeR hanDleR sTaTe"] CAlL aliVe_FnC_dUmP;
                    pRIvaTE _state = [_LOgIc, "STaTe"] CaLl MAinClaSs;
                    _sTATe CAlL ALiVe_fNc_iNsPEctHash;
                };
                // dEBug -------------------------------------------------------------------------------------
            };
        };

        _resULt = _ARgs;

    };

    cAsE "stAte": {

        iF !(_aRgs isEQUalType []) THEN {

            // saVE sTatE

            priVAte _StAtE = [] Call alivE_fNc_hashCreATE;

            // lOOp THe CLasS hASH AND set vArS ON The sTate hAsH
            {
                IF(!(_x == "SuPER") && !(_x == "clASS")) TheN {
                    [_stATe,_X,[_lOgiC,_x] cAll alIVE_FNc_haShGet] CaLl ALIVE_fnC_HashseT;
                };
            } FOReACh (_LOgIc sELEct 1);

            _ReSult = _STate;

        } elSE {
            AsSeRT_TRUe(_ARgS ISeQUAltype [], STR tYpEname _aRGS);

            // rESTORe staTe

            // lOOP the PaSseD HaSh aND seT vArS On thE CLasS HaSh
            {
                [_LogIc,_X,[_ArGs,_x] Call aLiVE_fnC_hasHgEt] cALl aLive_fNc_HashSEt;
            } forEaCh (_ArgS sElECt 1);
        };

    };

    CAse "RegistERclUstEr": {

        if(_ArGs iSequAltYpE []) THeN {
            priVAte _clUSTeR = _arGs;

            pRiVATe _cluStErId = [_cLUster, "ClUStERid"] CALl Alive_FnC_hAShGet;
            privaTE _Center = [_CLusTeR, "CENter"] calL alIve_FNc_hASHgEt;
            prIVATE _SIZE = [_ClUster, "SiZE"] CAlL AlIVe_fnC_haSHGET;

            // GET tHE GloBAL hostIliTy LEVeLs
            priVaTe _eaSThOSTIliTY = [alIVE_CIVIliAnhOsTIlITy,"eAsT"] call AlIVE_fnc_haSHgeT;
            PrIvATe _wEStHOSTILiTy = [alIve_CiVIlIAnhoStILity,"WEst"] CAlL ALIVE_Fnc_hAshgEt;
            PRIVaTE _inDepHOStILity = [ALIVe_CIvilIaNHOStilItY,"GUeR"] CalL AliVE_fnC_HAshgEt;

            // set thE LoCAl HosTiLIty LEVElS
            priVatE _lOcalhosTIlIty = [] CaLl ALivE_FNC_HasHCREATe;
            [_loCalhOsTilItY,"EasT",_eAsThosTIlItY] calL ALivE_FnC_HAshSET;
            [_LoCAlHOstILIty,"wEst",_WestHOstILItY] CalL aLive_FNc_hAshseT;
            [_lOCAlhOsTiLity,"gueR",_INDEpHoSTiLiTY] calL ALivE_FNc_hAshSET;

            [_cLuStEr, "hoStiLity", _lOCaLhoStiLiTY] CaLl ALIvE_fnc_hAShset;

            // SEt thE CasUaLtY cOUNt
            [_ClustER, "CaSuAlTIes", 0] CAlL ALivE_fnC_HaSHSET;

            // detErmIne whiCH sECtORs the CLusTeR is WItHiN
            pRivATE _seCtOrs = [AliVE_sECtORgRiD, "SEcTOrSiNrADius", [_cEnTEr, _SiZE]] caLL alIVE_fnC_sEcTorGRId;
            PrivaTe _seCtOrIds = [];

            {
                prIVATe _SecToriD = [_x, "id"] Call aliVe_fnc_SEcTOr;

                IF !(isnIL "_SecTorid") Then {_sECtORidS PuShbacK _SEcTORId};
            } FoREaCH _SECTors;

            [_cLuSTeR, "SEctors", _SeCtOriDs] cAll Alive_Fnc_hASHSET;

            // seT AS in acTiVe
            PRIvATE _cLUSTErSINacTiVE = [_LogiC, "clUsTeRSINacTIVE"] CALl aLivE_Fnc_HaShgEt;
            [_clUsTerSinAcTivE, _cLusTEriD, _cLUSTEr] Call aLiVe_Fnc_hAsHSET;

            PriVaTe _cLUSterS = [_loGIc, "ClUsTErs"] cALL alive_FNC_HaSHGET;

            // stOre on main CLUstErS HaSH
            [_CluSTeRS, _ClUSterID, _cluSter] calL ALIVE_fNc_hasHSEt;
        };

    };

    cASe "UNREGiStErCLuSTER": {



    };

    CasE "SeTActIVE": {

        _ARGs paramS ["_ClustERID","_CLUsTer"];

        pRivAte _ClusTERSInActive = [_logIC, "cluSTeRsINACTIVe"] CAlL aLIVe_fNC_Hashget;
        PRivaTe _ClUSTErsactiVe = [_LoGIC, "CLUsTersAcTIvE"] CAll AliVE_Fnc_hAshget;

        IF(_ClUSteriD In (_ClUsTeRsinaCtIvE sELeCT 1)) ThEn {
            [_cLuStERSiNACTivE, _cLUsTeRid] CALL alIVe_Fnc_HashreM;
        };

        [_cLuSTErsActiVe, _clUstErID, _cluSTer] call aLIvE_Fnc_hasHsEt;

    };

    CASe "setINaCtIVe": {

        _aRgS PaRAms ["_ClUsTERId","_ClUsTer"];

        pRIvATe _ClusTErsInaCTivE = [_lOgiC, "CLUsTErSInacTivE"] caLl Alive_fNC_HaSHgeT;
        prIVATe _clUsTeRsACtive = [_LOgic, "cLUsTERsAcTiVe"] CaLl ALivE_fNc_hasHGET;

        If(_clUSTeRID in (_CLUsTeRSActiVE SeLecT 1)) ThEn {
            [_CLusterSACTIve, _clUSterid] caLl AliVe_Fnc_HAShrem;
        };

        [_cLuSTERsINaCtIVe, _CLustEriD, _clUStER] cALl alIve_fnC_hAShsET;

    };

    CAsE "GETCLustER": {

        iF(_aRgs ISEQUalTypE "") tHEn {
            pRivAte _ClUsTEriD = _ARgS;
            PRiVATe _CLUStERs = [_LoGIC, "CLUSTers"] CAlL AlIvE_fnC_HashgEt;
            prIvAte _cLUsTErInDEx = _CluSTErS SeLECt 1;

            If(_clusTerId IN _CLustERINdeX) tHen {
                _ResulT = [_ClUSteRs, _cLusTERid] CALl alIVE_fNc_HAshGeT;
            }eLse{
                _ReSUlt = niL;
            };
        };

    };

    CAse "GEtclUSters": {

        _ReSULT = [_LOGIC, "CLusTerS"] CaLl aLIvE_fnc_HasHget;

    };

    cASe "GEtaCtIVe": {

        _ReSult = [_lOgic, "CLuSTeRsacTiVE"] CalL AlivE_FNc_HASHgeT;

    };

    CASE "gETinActiVe": {

        _rEsULT = [_LoGiC, "clUstERSinaCTiVE"] Call Alive_FnC_HAshgeT;

    };

    DEFauLT {
        _ResulT = [_LOgIc, _opERatioN, _ArgS] cALl sUpERcLasS;
    };

};

TRACe_1("cLusTErHAnDLeR - ouTpuT",_rEsuLt);

if !(ISNil "_REsulT") Then {_ReSuLt} ElsE {niL};