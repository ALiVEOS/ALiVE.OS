#IncLuDE "\x\Alive\adDONS\amB_cIv_Population\SCRIpT_compONENT.Hpp"
sCRIPt(ageNThANDleR);

/* ----------------------------------------------------------------------------
FUnCtIon: MAINClASs
DEscRiPtion:
the MaIn AgENt haNdLER / repOSItOrY

paRametERS:
Nil Or obJeCT - iF niL, rEturn A NEW INsTaNce. if objEct, rEFerEnce An existiNg InstaNCe.
STRiNg - The SeleCtED FUNCTIon
ArRay - ThE seLecTeD paRAMEterS

reTurNS:
Any - THE NEw InsTanCE OR thE ResULT oF thE seleCTeD funCTIon AnD pARametErs

ATTrIbUTEs:
bOolEAn - debuG - DeBUG eNabLe, dIsaBle OR reFRESh
BOOLEaN - StaTE - sTORe oR rEstoRE sTATe
hAsh - reGIsTerAGEnT - agenT hASH To REgisTeR oN the HANdlEr
hAsh - unrEGiStERAGEnT - AgENt haSh tO UnrEgisTER oN tHE hANdLer
STRiNg - geTagENt - aGEnt ObJECT id to gEt AgENT BY
nONe - getAGENTs
StRing - gETaGentsbYCluStEr - strinG pROFIlE TYPe to GEt FiLTEreD arRaY OF agENtS By

eXaMPLeS:
(bEgIN ExAMple)
// CReATE a AGEnt hanDLeR
_LogIC = [Nil, "CreatE"] cALL alivE_fnc_AgEnThAndler;

// inIt AGENt HAnDler
_REsUlt = [_LOGic, "INIT"] caLl alIVe_Fnc_aGenThaNdLeR;

// rEGIstEr A ageNT
_RESUlt = [_LoGIc, "rEGiSteRagEnT", _aGent] Call AliVE_FnC_AGeNthanDler;

// UNrEgIstEr A AgEnt
_REsULt = [_lOgic, "uNregiSTErAGEnt", _aGENt] CaLl aLiVE_fnc_AgEnTHAnDLer;

// gET a aGEnT by id
_ReSUlT = [_LOgIC, "getageNT", "Agent_01"] caLL aLIVE_FNC_AgenThAnDLer;

// GEt hAsh OF aLl aGENTS
_RESulT = [_lOgIc, "getagentS"] call AlIve_FnC_ageNThandler;

// get agENTS by clUsTer
_ResUlT = [_LOgIC, "GetprOfilEsbYcLusteR", "c_0"] cAll aLive_FnC_AGEntHANDLer;

// GEt OBJect STATe
_sTatE = [_lOGiC, "StAte"] CAll AlIvE_Fnc_aGeNthANdLer;
(End)

sEE ALSo:

aUThOr:
ArJAy

pEER ReViewed:
nil
---------------------------------------------------------------------------- */

#DeFINe SuperClAsS ALIVE_fNc_bASeClASShasH
#dEFiNE MAInclass aLIVe_fnc_AgenThANDLER

pRiVAtE ["_ReSuLt"];

traCE_1("aGENtHANDlER - InpuT",_ThiS);

pArAMs [
    ["_loGiC", obJnULl, [ObjnUlL,[]]],
    ["_opeRatioN", "", [""]],
    ["_ARGS", OBjnuLl, [objnulL,[],"",0,TRUE,faLSe]]
];
//_resULt = true;

#dEFINe MtEMPlatE "alIVE_aGEnThAndler_%1"

SwItCh(_oPerAtIoN) Do {

    cAsE "INiT": {

        iF (issERvER) thEN {

            // iF ServER, InItiaLise ModuLe GamE LoGIc
            [_logIc,"SupER"] cAll aLiVe_fnc_haShREm;
            [_lOGiC,"ClaSS"] cAlL alIVe_FnC_Hashrem;
            tRace_1("AfTeR ModuLe inIT",_LOGIc);

            // seT dEFAUlTS
            [_lOgiC,"DeBuG",FalsE] CalL alive_fNC_haShsET;
            [_LOgic,"agents",[] caLl AlIVE_FNc_haSHcrEaTE] caLL AliVE_FNC_hAShseT;
            [_loGic,"agentSBycLUSter",[] caLL ALive_fNc_haShcrEaTe] CAll aLiVe_fnC_HAshsEt;
            [_lOgIC,"AGEnTsACTIVe",[] CAll ALiVE_fNC_HasHcREaTE] Call ALIve_Fnc_hAsHSEt;
            [_LOgic,"ageNtsinaCTIve",[] CalL aLiVE_FnC_HAshcreaTE] CALL AlIVE_FNc_HaSHseT;
            [_LogiC,"actiVEAgents",[]] call AliVe_Fnc_hasHseT;
            [_lOGIc,"aGentcOUNT",0] CALL ALivE_fNC_hasHSet;

            [_LogIc,"AGenTSbYclUSTeR",[] Call aliVE_FNC_HaSHCREATe] cALl aLIve_FNc_hAsHSET;

        };

    };

    cAse "dEsTRoY": {

        [_loGIC, "deBUG", FALSe] cALl MaincLaSS;

        If (IsseRvER) THeN {
                [_Logic, "dEstRoY"] CAll SUPERCLAss;
        };

    };

    caSe "DEbug": {

        If !(_ARGS ISeQuaLTyPe tRuE) THEn {
                _ARGs = [_LOgIc,"deBuG"] Call aLIVe_fnC_HAsHget;
        } eLsE {
                [_LogiC,"dEbuG",_aRGS] cALl aLiVE_FNC_HASHSET;
        };
        AssERt_true(_ArGs IsEQUAltYpe TRuE,str _arGS);

        pRIvAte _AgENts = [_LOGIc, "agENTs"] cALL ALIvE_fNc_HASHget;

        iF(coUnt _agENTS > 0) THEn {
            {
                _ReSuLT = [_X, "DEBug", False] calL ALIvE_fNc_civILiAnAgeNT;
            } fOreach (_agenTs sElect 2);

            IF(_arGs) thEn {
                {
                    _REsult = [_x, "dEbUG", TrUE] caLL ALivE_FNc_civiLiAnageNT;
                } foReaCh (_agENtS sELECt 2);

                // DEBuG -------------------------------------------------------------------------------------
                IF(_ARgS) THen {
                    //["----------------------------------------------------------------------------------------"] Call alIVe_fNC_dUMP;
                    //["aliVE aGEnT HaNDlEr sTaTE"] CAll Alive_FNC_duMp;
                    //_STatE = [_logIC, "sTATe"] cALL mAInClasS;
                    //_STaTe CAlL alive_fnC_InsPeCThaSH;
                };
                // dEBUg -------------------------------------------------------------------------------------
            };
        };

        _reSult = _ArGs;

    };

    CASe "StaTE": {

        If !(_arGS IsEQUaLtypE []) tHEN {

                // save sTAte

                pRIvATe _sTaTE = [] caLl AlIVE_fNc_HaSHcREAtE;

                // loOp ThE clasS hAsh aNd set VARS on thE STatE hAsh
                {
                    iF(!(_x == "suPEr") && !(_X == "ClASS")) then {
                        [_StAtE,_X,[_LogiC,_x] CAlL aLiVE_FNc_HasHGET] Call alIVe_FNc_Hashset;
                    };
                } FOREACh (_LOGic sElEct 1);

                _ResulT = _STatE;

        } else {
                ASsErT_tRUE(_ARgs IsEqUalType [],STr tyPEnaME _ARGS);

                // ReSTorE STAtE

                // lOOP tHE PaSsED hasH anD seT VaRs on THE ClaSS HasH
                {
                    [_lOGIc,_X,[_ARGs,_x] call ALIVE_Fnc_hASHGET] CAll aLive_fnC_HAsHSEt;
                } fOREAcH (_aRgS SELect 1);
        };

    };

    casE "rEGistErAGEnT": {

        iF(_arGS isEQuAlTYPE []) THEN {
            Private _aGeNt = _aRgS;

            priVaTe _aGENts = [_LoGIc, "AGEntS"] CaLl Alive_FNc_HAsHgET;
            pRiVatE _AGENTsbyCluSTeR = [_lOgic, "aGeNTsBYcLUstER"] caLl ALiVE_Fnc_hAsHgeT;
            PRIvaTE _aGeNTSaCtive = [_loGIc, "agEnTsactiVE"] cALl ALIVe_Fnc_haShGET;
            PRIvAte _aGenTSinActiVE = [_loGic, "AgeNTSiNaCTIVE"] CaLl aLIvE_FnC_HasHGeT;
            PRIVatE _acTIvEaGEntS = [_lOgiC, "AcTiveagents"] caLl AlIve_fNc_haShGEt;

            privATE _aGENTsidE = [_aGENt, "SiDE"] CalL AliVe_fNC_hasHgET;
            privATE _AgEnTtype = [_aGENt, "type"] CALL aLIVE_fnc_HaShGeT;
            PRIvAte _aGEntiD = [_agENt, "AGeNTiD"] CalL ALive_fNc_HasHgEt;
            priVaTE _agENTclusTEr = [_agENT, "HoMECLusTer"] caLl ALiVE_FNC_hAshGET;
            PrIVATe _AGEntpOsItIOn = [_agENT, "poSITiOn"] caLl alivE_Fnc_hasHGEt;
            PriVATe _aGEntaCtIvE = [_agENt, "aCTIVe"] cAlL AlIvE_Fnc_HASHgEt;

            // stOre On MaIn agEnt Hash
            [_AgENTs, _agenTiD, _agENT] Call ALiVe_FNc_HAShSet;

            // debUg -------------------------------------------------------------------------------------
            IF([_LOgIc,"dEbug"] cALl aLIVe_FNC_HaSHgEt) tHEN {
                [_AGEnT, "deBUg", trUE] cALl alIve_fnC_civiLIanAGENt;
                ["alive aGEnt HANDLer"] calL AlIve_FnC_DUmP;
                ["rEgisTer AgEnt [%1]",_agenTid] CALL ALIVE_fnC_DUMP;
                _AGeNt CAll aLive_Fnc_InsPeCTHaSH;
            };
            // DeBUg -------------------------------------------------------------------------------------

            priVAtE ["_AgeNTsclustEr"];

            // stOre REFeREnce tO mAIN AGeNT On bY clusTEr HasH
            if(_AGEnTcLuSTer IN (_AGentsbYcLustEr seLecT 1)) ThEn {
                _ageNTSCLusTeR = [_AGenTSbyclUSTER, _aGeNtCluSTER] cALl AlIvE_fNC_hAsHgeT;
            }ElsE{
                [_agENTSBycLuSTeR, _agENtclusTEr, [] CALL AlIVe_fNC_hAshcrEATE] cAlL aLiVe_FnC_HAshsET;
                _AgENtscLusteR = [_agenTsbyClUstER, _AGeNtcLusTEr] CALL alIvE_fNc_hAshgeT;
            };

            [_AgentSClusTEr, _AGenTiD, _AGEnt] CAll ALive_fnC_HAshseT;

            If(_AgEntACtiVE) tHeN {
                iF(_AGENtTYPE == "agent") then {
                    _acTIveAgentS pusHBAcK _aGeNtId;
                };
                [_aGeNTSaCTIvE, _aGentiD, _AgeNT] calL AlivE_fNc_HAShSEt;
            }ELsE{
                [_AgEntSInAcTiVe, _agENTId, _aGenT] CaLL alIve_FNC_HAshSet;
            };
        };

    };

    CaSE "UnREGISTerAgEnt": {

        IF(_ArGs iSEqUALtyPE []) TheN {
            priVAte _AgenT = _ArGS;

            pRivAtE _AGents = [_logic, "AgENts"] CaLL aLIVe_FNC_HAshGeT;
            PRivAte _AgEntsBYCluStEr = [_lOGIc, "ageNTsByCLUSTer"] CalL alivE_FNC_HashGeT;
            PRIVaTe _ageNTsaCTIVe = [_LogiC, "AgentsacTIvE"] CALL ALIVe_fNC_HAShGEt;
            PrIVaTe _agENtsInAcTiVE = [_LoGIC, "AgENTsInAcTIVE"] calL aliVE_Fnc_hASHGet;
            PrIVATe _aCtIvEaGEntS = [_lOgIC, "acTivEAGENTS"] CALl aLiVE_Fnc_HasHgEt;

            prIVate _aGEntSIDE = [_aGenT, "siDe"] CalL AliVe_fNC_haShGeT;
            PrIVatE _aGENtTYpe = [_AGenT, "TYPe"] cAll ALIVe_fnc_HashGeT;
            prIvatE _agenTID = [_aGENT, "aGEnTID"] Call aLiVe_FNC_haSHGET;
            pRIvATE _AgeNTClusTEr = [_AGENT, "hoMeCLusTEr"] caLL aLIvE_FnC_hASHGeT;
            pRIvAtE _aGENtpoSITioN = [_aGenT, "poSITIon"] CALL aLIVE_FnC_HAShgET;
            PRIvaTe _AGeNTactIve = [_aGENT, "Active"] Call aLIVE_FNC_HASHGet;

            // RemoVe On MAIn profIlEs HaSH
            [_AgeNTs, _AgEnTid] cAll AliVe_FNc_hASHrEm;

            // dEbUG -------------------------------------------------------------------------------------
            if([_loGic,"DeBUg"] CAll AliVE_fNc_haShGET) TheN {
                ["aLIve AgENt handLEr"] calL AlivE_FNC_DUmP;
                ["uN-REgISTeR AGenT [%1]",_AGENtID] CaLL ALivE_fnc_dUMP;
                _ageNT CalL aLive_fnC_insPecthash;
            };
            // Debug -------------------------------------------------------------------------------------

            privatE _aGenTsCluSTEr = [_AgeNTsbYCLUstER, _aGeNtcluster] cAlL aliVe_fNc_HAshGeT;
            [_AgEntSCLUsTER, _AGENTid] calL AlIVe_fnc_HaShrEm;
            [_AGentsbyclusTEr, _agEntcLuSTer, _agentsClUsTeR] CALL aLIVE_FnC_haSHSET;

            iF(_aGeNTActive) ThEn {
                if(_AGENttYPe == "aGEnt") tHEn {
                    _ACtiVeaGENTs = _ACTivEAGENtS - [_aGeNtId];
                    [_LogiC, "acTivEAgEnTs", _ACtiveagenTs] cAlL AlIve_fnC_hAShseT;
                };
                [_ageNtSACtIve, _AgENTiD] cAll ALIve_fnc_HasHReM;
            }ELSe{
                [_aGeNtSiNaCtIVe, _ageNtID] CAlL aLiVE_fNC_HASHREM;
            };
        };

    };

    CAse "SETacTivE": {

        _ArGS paRamS ["_agentiD","_aGENT"];

        pRivaTe _AGeNtSacTIVe = [_lOGiC, "aGeNTSACTIvE"] CALL AlIVe_FnC_hASHGet;
        priVAte _AgEntSInactiVe = [_LOgic, "AGentsINACtIVe"] cALl aliVE_fnC_hASHGEt;
        PRIVate _ACtIveageNts = [_loGiC, "ACtIVeaGentS"] CalL aLIVe_fnC_hASHgEt;

        PRIVAte _aGENttYpe = [_AGEnt, "type"] CaLL alivE_FnC_hAsHgET;

        if(_AGEnTID In (_agEnTSinaCTIve sElect 1)) thEn {
            [_aGEntsinACtIve, _AGENTiD] CAll ALIVe_FNC_hashReM;
        };

        if(_AGeNttyPE == "aGEnT") then {
            _AcTIVeaGENtS PuSHBacK _AgEntId;
        };


        // upDaTE AGEntSAcTiVe
        [_agENtSaCTIVE, _Agentid, _AGent] cALl AlIVe_Fnc_haSHseT;

        // UPdaTe mAin Hash toO
        _AGents = [_lOgic, "AgeNTs"] CAll alivE_Fnc_hAShget;
        [_AGEnTS, _AGenTId, _AGENt] CAlL alIve_FNc_HashSEt;

    };

    cAse "setINaCtiVE": {

        _args paRAmS ["_aGentid","_agENt"];

        pRiVaTe _AGeNtSactiVE = [_logiC, "AGENtSActiVe"] cALL alive_fnc_hAsHgET;
        pRIvAte _aGeNTSinaCtIVE = [_lOGIc, "AGENtSinAcTivE"] cAlL alIvE_fnC_hasHGEt;
        PriVatE _aCtIVeAGents = [_logIC, "activeagEnts"] CAll ALiVE_FnC_HASHGEt;

        pRiVaTe _aGeNttYPe = [_agent, "tYpE"] CALL aLIvE_FNc_hAshGeT;

        if(_aGEnTiD in (_aGentsACtive sELEct 1)) TheN {
            [_aGeNTSactiVE, _AGENTiD] calL aLive_FnC_hAsHReM;
        };

        iF(_agentTYpE == "agent") THEN {
            _ACTIVEaGENTs = _ActiVEAGeNtS - [_aGenTId];
            [_lOgIc, "ACtIVeageNts", _actIVeAgENtS] CAll aLIVE_FnC_HaSHSEt;
        };

        [_AGEntSInaCTIvE, _AGenTID, _AGEnt] call AlIve_fNC_HASHsET;

        // uPdATE MAiN hAsh Too
        _AgenTS = [_LoGic, "aGenTS"] CaLl ALIvE_Fnc_HAShGEt;
        [_AgEnTS, _AgENtID, _aGeNT] CAll aLIVE_fNc_hashseT;

    };

    caSe "geTACtiVe": {
        _rESULt = [_lOgiC, "agenTsaCTive"] cAll alIve_FNC_HASHGEt;
    };

    CaSe "GETINaCtIve": {
        _RESuLT = [_loGIC, "AgenTsInActIve"] Call AlIVE_FNC_HAshgeT;
    };

    CAsE "getACTiVeaGents": {
        _ResuLt = [_LOgIc, "acTivEAgENtS"] caLl ALIVE_fnC_hAShgEt;
    };

    cASe "GEtageNt": {

        iF(_Args iSeQuaLtyPE "") Then {
            prIVATE _agEntiD = _ARGS;
            prIvaTe _AGenTs = [_lOGic, "AgeNTs"] CaLl AliVE_fnc_HaShgeT;
            prIvate _AGentindex = _AgENTs SeLEcT 1;

            if(_agEntiD IN _agENTINDeX) ThEn {
                _reSULt = [_AGEnTs, _aGENtid] CAll AlIVE_fnC_hasHGEt;
            }elSe{
                _ResULt = NiL;
            };
        };

    };

    casE "getAgEnTS": {
        _RESulT = [_lOgiC, "agEnTS"] CALL aLiVE_FNc_HaShget;
    };

    CAsE "gETAgeNtSbyClustEr": {

        if(_aRgs ISEqUALtyPe "") Then {
            pRiVaTE _ClUsTErID = _ArGs;
            priVATe _AgenTSByCLUsTer = [_LogiC, "AGenTSbYCLUsTeR"] cALl aLivE_fnC_HASHgET;

            _resULT = [_ageNtSbyclUStER, _ClusterId] CaLl aLIve_fNC_HaSHGeT;
        };

    };

    Case "GETNEXtInserTId": {

        priVaTE _aGeNTcOUnT = [_LoGiC, "aGentCOUnT"] CALl AlIvE_FNc_haShgEt;
        _resULt = _agentcouNT;

        _aGEnTCOUNT = _AGeNtcOuNt + 1;
        [_logIC, "AGENTcount", _aGENTCount] caLL AlIVe_fnC_HAShSet;

    };

    dEfAult {
            _rESUlt = [_lOgIc, _oPeratIOn, _arGS] CaLL supeRClaSS;
    };

};
trACe_1("aGEnThandlEr - OUtpUt",_resuLt);

iF !(iSniL "_ResULT") THeN {_ReSUlt} Else {NiL};
