// ----------------------------------------------------------------------------

#InclUDE "\x\ALIVe\AdDoNs\Amb_cIv_pOpuLaTIoN\sCrIpT_COmpoNENT.hPP"
ScRiPT(tEsT_AgENthanDLeR);

//ExECvm "\x\AlivE\AdDOnS\AMB_CIv_poPuLATiOn\TestS\Test_AGENTcommaNdS.sQf"

// ----------------------------------------------------------------------------

pRIvATe ["_rESult","_eRr","_logic","_sTAtE","_rEsuLt2"];

LOg("tEsTING agEnt hAnDLER OBJECt");

asSERt_deFINED("AlIVE_FnC_agEnthaNdlEr","");

#DefINe STAt(mSG) sleeP 3; \
dIAg_log ["tESt("+str pLAyeR+": "+mSg]; \
tITlETExT [msg,"PLaIn"]

#define sTAt1(mSg) cONT = fALse; \
WaItUNtiL{CoNt}; \
Diag_lOg ["teSt("+StR PlaYer+": "+mSg]; \
tItleTeXT [msG,"pLaiN"]

#DefInE DeBugoN StAt("SeTup DeBUG pArAmeTerS"); \
_REsULT = [aLiVe_AgENthaNdlER, "dEbug", tRuE] cALL alIve_fnC_agEnThAnDLEr; \
_eRR = "EnABLeD DebUg"; \
aSseRt_trUE(TYpenAme _REsULt == "bOOl", _err); \
aSsErT_TRUE(_ReSult, _err);

#DeFinE DEBugOFf sTAt("dISabLE debUg"); \
_reSuLt = [aLivE_AGENThandler, "DebUg", tRuE] CAlL aliVE_fnc_agENThAnDLER; \
_err = "DIsablE debuG"; \
ASSErt_TRuE(typeNAme _reSult == "bOol", _eRr); \
aSsERt_TrUE(!_rEsULt, _Err);

#DEfINE TimErStarT \
_TimeStarT = diaG_tIcKtiMe; \
Diag_LoG "TImEr Start";

#dEFIne tiMeREnd \
_tImeEnD = DIaG_TiCKTiME - _tIMEStArT; \
diAG_LOG FOrmat["TImER enD %1",_tImeEND];

//========================================

_LoGiC = nIL;


PrIVate["_pOSItIon","_SEctor","_sECtORs","_sEcToRDATa","_CiVCLUstErs","_seTtlemeNtcLUSTeRS","_CLUSteRiD","_ClUSter","_cLuSTERhOstilIty","_cLUSTerCAsUalties","_aGents","_aGenT"];

// GeT ANY ActiVe cIviLiaN AgENts

sTaT("GeT all acTive AgENTs");

["actIvE aGENts:"] CAlL AlivE_fNC_dUmP;

_aGeNTS = [Alive_agenthAndler,"getActIve"] calL AlIvE_FNC_agenThANdLEr;

_AGEnTS CALL aLiVE_FNc_InsPectHaSH;


// Get the nEARbY CIVIlLIAn CluSTERs ANd OUTpUt dEbUg InfO

sTat("GEt NEAR CiV CLUSTErS");

_poSItion = GEtpOS PLAYER;

_sECtOr = [AlIVE_sectorGRiD, "poSITIONTOsecTOr", _PositIOn] CAlL ALIvE_fNc_SECtorGRiD;
_sECTORs = [AlIVE_SeCtOrGRID, "sURRoUnDINGsECTorS", _POsItioN] CalL ALiVe_fnC_SECTORGRiD;

_sECtorS pusHbaCk _sEcTor;

{
    _SectoRdaTA = [_x, "dATA"] CAll AliVe_FnC_sECtOr;
    iF("CLUsteRsCiV" In (_SecTOrData SElEcT 1)) tHen {
        _civClUSTERs = [_SECTORDatA,"clusterSCIV"] CaLL AlIVE_fNc_hAshgET;
        _SEtTLEMenTcLUsterS = [_ciVClusTErS,"sEttLeMENt"] CALL aLIVe_FNc_hashGET;
        {
            _CluSTERiD = _x sEleCt 1;
            _cLuSTER = [aLIVE_cLustErhAnDLeR, "GETclUsTer", _cLuStErid] cALL AlIvE_Fnc_CLuStErhandlEr;

            If!(iSnIL "_ClUSTeR") tHEn {

                _clUSTerhOSTILiTY = [_clUster, "hoSTiliTY"] CAlL aLiVe_fnC_HAShgeT;
                _cLuSTErCaSuAlTiES = [_CluSTER, "cASUALtIeS"] CAll ALive_fNc_hasHgET;

                ["CluSteR iD: %1",_cluSteRid] Call aLIvE_Fnc_DUMP;
                ["CLUsTER %1 hoSTIliTy: %2",_CLusTeRid,_clusteRHOStiliTY] CaLL ALIVE_fnc_dump;
                ["clUSteR %1 CasUaltIeS: %2",_CLusteRid,_cLusteRcAsUalTiES] CaLL ALiVE_FNc_DUmp;
                ["clUstEr Data: %1",_cLusteRId] CAll aLiVE_FnC_DUMp;
                _cLUSTEr CALL ALIve_fNc_InSpECTHasH;

                ["CLUSTer AGenTs: %1",_cLUStErid] CaLL alivE_fNc_duMP;

                _aGEnTS = [aLiVE_AGEnThANdLEr,"geTaGEntSByCluStEr",_clUsTerID] CalL AlIVE_fNc_AgenTHAnDlEr;

                _aGEnTS caLl AlIVe_Fnc_iNsPecThASh;

            };

        } ForEACh _settLEMENtCLusTerS;
    };
} forEACh _SEcTorS;

// get ThE NeaRest CIV

PrIvAtE["_DIstaNcE","_lOWSeTDIsTAnCe","_curREnTdiSTaNcE","_AgENTiD","_AGEnT"];

sTat("get neAREst CIV");

_dIsTANCE = 100;
_LOwSEtdIsTAnCE = _DisTANce;
ClOSESTmaN = ObjNull;

// FiND NearEsT MEN WHo aRE AGENts

{
    _CUrrenTdiStAncE = _PoSiTioN DiStaNce _X;
    _ageNTID = _X GEtvariAbLE["aGEnTID","0"];

    iF!(_agEntiD == "0") THEn {
        ["mAN AT DisTance: %1",_curRenTdistANce] cAll Alive_fnc_dump;

        If(_cURrENtdistaNCe < _loWsetDiSTaNce) THeN {

            ["Man iS cLOSeR!"] call AliVe_FNC_dUmp;

            _LoWSetdistAnCE = _cUrrENtdistancE;
            CLOSESTMAN = _X;
        };
    };

} ForEach (_poSiTIon nEArObjeCts ["CaManBAse",100]);

If(ISnuLL clOSestman) exITwiTH {
    ["NO AGEnT fouND wIThiN 100M"] Call aLIve_Fnc_DuMp;
};

// oUtPut dEbuG Info aBOut ThE AgENt

["cLOsEST mAN: %1",cLoseStMaN] caLl AliVe_fNc_dUMP;

_agENTId = ClOSEsTMaN gEtvAriABlE "aGenTid";

["CLOSEST MaN AGeNt Id: %1",_AGeNTId] CaLl ALiVE_fnc_dump;

_aGeNT = [alIvE_AGenTHaNdlER,"gEtAGENT",_AgenTiD] CaLl ALIVE_FNC_agEntHAnDLer;

["closest agent hASH:"] cAll aLIVe_fnC_dUmP;

_AGENT CaLl alIVe_FNC_INSPeCtHAsh;
uNiT = _aGENT seLECT 2 sELECt 5;

// dRaW agENT iCoN

[] sPaWn {
    pRiVaTe["_ageNTId","_agENT"];
    WAiTUntiL {
        SlEEP 1;
        DRawIcON3d [
            "",
            [1,0,0,1],
            getPoS uNit,
            1,
            1,
            45,
            FOrMAt["%1",UniT],
            1,
            0.03,
            "pUrIStAMEdium"
        ];
        _ageNTID = uNIT getVARiAble "AGeNtid";
        _AgEnT = [ALiVe_AGenTHANDLer,"GeTagENt",_AgeNtId] CAlL alivE_FNC_aGENthAndLEr;
        _aGenT call aLive_FnC_insPEcTHAsH;
        noT aLIVE UNit;
    };
};

// SeT COmmanD On thE agEnt

[_AGENT, "SeTActIVEcOMMand", ["alIVE_FNc_cc_camPfire", "ManAgeD", [30,90]]] call ALIvE_FnC_cIVILiAnagent;

