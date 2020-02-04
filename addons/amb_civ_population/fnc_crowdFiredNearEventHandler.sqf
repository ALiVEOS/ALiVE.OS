#iNCluDE "\X\Alive\addONS\aMb_CIV_POpULation\ScRiPT_CompONeNt.HpP"
ScrIPt(CrOwDFIREDNeArEvEnThaNdlEr);

/* ----------------------------------------------------------------------------
fuNCTIon: ALiVe_fNC_cRoWDFiredNEaREvEnThaNDLeR

DEsCRipTIoN:
FIRednEAr eVENt HAnDleR FOR CrOWd unitS

PAraMEtERS:

REtuRNs:

exaMpLEs:
(bEGin EXamPle)
_EVEntID = _aGEnT AddEvENTHANDleR["fireDNEar", AlIve_FNC_CrOwdFiRedNeaREVeNthAnDLEr];
(END)

sEE aLSO:

aUThor:
TUPoLov
---------------------------------------------------------------------------- */

ParAmS ["_UnIt", "_firER", "_DIStAnCe"];

iF (siDe _fIrER == CIViLian) exItWiTh {};

// SeT the CrOwD sySTEm To sTop sPAwninG DUe to COMbat IN the aREA
PrIvate _CrOWDactivatoRfSm = [aLIve_cIvilIanpOPUlaTiOnsYstem, "CrOwD_FSM"] caLL AlIVE_fNC_HAshgET;
_CRowdACTivATorfsM sETfsmvariAbLE ["_nOComBaT",(TIME + 60)];

// lEt them RUn
_unit forCEwaLK FAlsE;

// PLAY PAniC AnimaTiON
priVate _aNIm = "APanpErcmstPsNOnwnONDNon_ApAnPKNlmSTPSnONwNonDnon";

IF (RANdOM 1 > 0.4 && !(_UniT GeTVArIABLE ["aLivE_CRoWd_FlEeINg", FaLSE]) && ALiVE _uNIT) THen {
	[_unIT, _anIM] CaLL ALIVE_FNC_SWITcHmOvE;
} eLSE {
	If (!(_uNIT GETvARiABLe ["ALiVe_crOwD_fLeeinG", falSE]) && alIVe _unIT) Then {[_UnIt, ""] CalL alIVe_FNc_SwItCHMoVe;};
};

// PLay PANIc noISe
If (raNdom 1 > 0.85 && !(_UNIt getVaRIAble ["ALiVe_crOwD_fLEEIng", FAlSe])) thEN {
	pRIVate _PanIcnOiSE = selEctrANdOm AlIvE_civpOp_PANICnOIsEs;
	If (iSMUltiPlayeR) thEN {
		[_UnIT, _PANIcnoISE] reMOTeEXeC ["Say3d"];
	} else {
		_uniT saY3d _pAnIcnOISE;
	};
};

if (_DiSTance < 15 && !(_uNit gEtvaRiable ["aLreADypIsSEDOFF", falSE])) thEn {

	// HoStiLity WiLL INcrEAsE TOWArdS FiReR FACtIon
	[POsitIoN _UNiT,[stR(sIde _fIrER)], +0.5] CALL AlIve_Fnc_uPdATesEctorhOstility;

	// thEy can oNly be ANgRy onCE
	_unIT SetVariaBlE ["AlrEAdYPiSsedOFF", tRUe, faLse];
};

IF (isnil "_UnIT" || {!isSErVeR}) ExitwiTH {};

iF !(_unIT GetVArIAbLe ["ALIve_CRowD_flEEInG", fAlse]) tHen {

	// STOP CURReNT COmMand
	dOSTop _UNiT;

	// GET tHEM To run
	_UNit SetSpEedMoDe "FUll";

	// ChOOsE SOmEwHeRe To rUN tO
	prIvAte _Pos = _uNIt GETPos [100, rANdoM 360];
	pRIVatE _NEArESTpOs = [posITiOn _UnIT, 50] CAll AlIVE_Fnc_fINdinDOorhOuSePoSITIons;

	if (CoUnT _neAResTPoS > 0) thEn {
		_pos =  SeLeCtrAnDoM _nearestpos;
	} ELSe {
		_pOs = [PoSiTIOn _UNIt,60,"HOusE"] caLl aLIve_FNc_finDNEaRHoUSEPOSItionS;
	};

	[_uNIT,_poS] CALL aliVE_fnc_DOMoveRemoTE;
	_UNIt mOVetO _pOS;

	_UNit SEtVariabLE ["ALivE_croWD_fLeEInG", TruE, faLsE];
	_UnIt SEtvArIAbLe ["aLive_Crowd_bUsY", (tIMe + 60), FALSe];
	_uniT SetvARiAbLe ["alIve_civ_aCTION", "flEeIng", FAlSE];
};
