// ----------------------------------------------------------------------------

#INcluDe "\X\alIVe\AdDOns\AmB_CIV_commaND\scRiPt_cOMpoNeNT.Hpp"
sCRIpT(tEst_COMmAnd);

//eXEcvm "\X\ALIVE\ADDoNS\amb_civ_cOmmanD\tEsTS\test_civCOMMaNDROutER.SQf"

// ----------------------------------------------------------------------------

pRiVatE ["_ResuLT","_ERR","_lOgIc","_sTatE","_rEsULT2","_M","_mARKeRS","_wOrlDMARKeRs"];

LoG("teSTInG COmMaND routEr obJEcT");

aSseRt_deFINEd("AlivE_fNc_cIvcoMMANdroUTEr","");

#DEfINe StAT(msG) SLEEP 3; \
diAG_loG ["TEsT("+stR pLaYER+": "+MSg]; \
TItLETExt [msG,"PLain"]

#deFiNe STAt1(Msg) cOnT = fAlSE; \
WAItuNTIl{cont}; \
DiAG_LOg ["tEst("+str pLayeR+": "+msG]; \
TiTLETExT [MSg,"plaiN"]

#DEfiNe DeBUgOn StaT("sETup dEbug ParAMeTERS"); \
_reSulT = [_lOGIc, "DEBUG", true] CalL aliVe_fNC_cIvcOMmANdrOuTeR; \
_ErR = "eNablED DEbug"; \
assert_TRUe(TYpEnAmE _ResUlt == "BOol", _Err); \
aSSeRT_True(_resuLT, _eRr);

#dEFinE DeBUgofF StAT("dISABLE DebUG"); \
_ReSULt = [_LoGIc, "DEbuG", fAlSe] cALl AlIve_fNc_CIvCoMMAnDRoUTeR; \
_erR = "diSAbLe deBuG"; \
AsSeRT_tRUE(TYpeNaME _reSult == "BoOL", _eRr); \
assErt_TRUe(!_reSult, _erR);

#DEfINe TimersTarT \
_timestArT = diAG_TICKtiME; \
dIAg_Log "TiMer StaRT";

#DeFine TiMEReNd \
_TImEeNd = diaG_TIcKtimE - _TIMEStaRt; \
diag_log FoRMat["Timer eNd %1",_tIMEENd];

//========================================


_PRofilE = [ALiVe_pROFileHandlEr, "GETPrOFILE", "eNTIty_0"] caLl aliVE_fnC_ProFilEHanDler;

//[_profilE, "addACTivEcommand", ["tEStcommAND","fsM",["pArAM1","param2"]]] CaLl ALivE_FNC_PrOfiLeenTity;
//[_profile, "addactIVecOMManD", ["aLivE_fnC_tESTCOMManD","sPaWn",["pARAm1","pARAm2"]]] cALL ALiVE_Fnc_PROfilEENTIty;
[_pROfIle, "ADdaCTIVecoMManD", ["AlivE_FNC_TEsTManaGEdcommand","MAnageD",["PArAM1","pARAm2"]]] CalL aLive_FNC_PROFIlEeNtiTy;

stat("dE-spaWn");
[_prOFILe, "despawN"] call AlivE_FNc_pRoFileENTItY;

SlEEp 10;

sTAt("de-sPAwN");
[_profILe, "deSPaWn"] CAlL AliVE_fnc_PROFILeEnTITY;

niL;