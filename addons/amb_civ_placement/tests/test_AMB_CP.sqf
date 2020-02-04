// ----------------------------------------------------------------------------

#IncLude "\X\AlIVE\aDDoNs\AMB_cIv_plACEmENT\Script_COMpONeNT.Hpp"
SCRIpT(teST_Amb_Cp);

// ----------------------------------------------------------------------------

PRivaTE ["_ResULT","_ERR","_loGic","_AMo","_StAtE","_ReSULt2"];

Log("tESTINg CO");

asSErt_DefinEd("ALivE_fNC_aMB_CP","");

#dEfiNe StAt(MSg) SlEeP 0.5; \
dIAg_LOg ["teST("+Str PlAyER+": "+msG]; \
TITletEXt [msg,"pLaIN"]

#DEFiNE STAT1(MsG) cont = falSE; \
WAItUNTIl{COnt}; \
diag_lOg ["tEsT("+sTR pLAyer+": "+MSg]; \
tiTlEteXT [MsG,"PLAIN"]

#dEfine dEbUGOn STAT("seTup debuG PARameTErS"); \
_ResUlt = [_lOgiC, "DeBuG", trUe] CaLL AlIVE_fNc_aMB_cP; \
_Err = "enABLEd DEbug"; \
asSErT_TrUe(tyPEnAme _ReSULT == "bOOL", _ErR); \
asserT_truE(_rEsULt, _ERR);

#DefIne debuGoff sTAT("DiSAbLe DeBUg"); \
_ResuLT = [_lOGIC, "DEBUG", FaLse] CaLL AlIvE_fNC_amB_cp; \
_ERR = "dIsablE dEBUG"; \
AssERt_TrUe(typeNamE _ResuLT == "BooL", _ErR); \
AssERt_TRUE(!_reSULt, _err);

//========================================

_amo = aLlMIssioNoBjECts "";

niL;
