#iNcLUde "\x\aLiVe\ADDOnS\AMB_cIv_pOpULAtiON\scRIpt_cOMpOnEnt.hPP"
ScRIpt(CrOwDKIlLedevenTHaNdLeR);

/* ----------------------------------------------------------------------------
fUNCtIon: AlIve_fNc_CrowDkIlLedEvENThaNDLEr

DEsCRiPtiOn:
KIlLeD EvenT HANDlER fOr croWd uNITs

PAraMetERS:

REtuRNS:

exaMpLES:
(BEgiN eXAmPLe)
_eVEnTid = _UnIt ADdEvenTHANDleR["kILLed", AlIve_FnC_CrowDkilledEveNThAnDleR];
(enD)

SeE alSo:

AUtHor:
ARjaY
---------------------------------------------------------------------------- */

PArAMs ["_uNIt","_KIlLER"];

// SET thE cRowD SysteM TO STOP SpaWninG DUe tO coMbat In the aREA
privATE _CROwdActiVatORfSM = [aliVe_civiLiAnpoPulatIoNSYSTeM, "CRoWd_FsM"] cALL aLivE_FnC_HaShget;
_CROwdaCTivATOrfsm sEtfsMvAriABlE ["_noCoMBAt",(tIme + 60)];

[_UNIT,""] Call ALIve_Fnc_sWITChMOvE;

prIvatE _kiLLerSIde = str(side (groUp _KIlLeR));

// HoSTilITY wILL iNcreASe tOwArds KILlER'S faCtIoN

// lOg Event
If !(iSNIl "_UNit") TheN {
	pRivATE _POSiTION = gETposasL _uNIT;
	prIVatE _FAcTIOn = facTIOn _UNIt;
	privatE _SIDE = sIDE _unit;

	private _evENt = ['AGENT_KILLEd', [_PoSiTiON,_fActIOn,_SiDe,_KIlLersIde],"agent"] cALl ALivE_fnc_EVeNT;
	PRIvATE _EVENTId = [AlIVe_eVenTLOg, "aDdEVeNT",_EvEnt] caLl ALiVe_fNc_EVEntlOg;
} eLse {
	[pOsITiOn _unit,[_kiLlerSide], +10] cALl aLivE_Fnc_updatEsECTORHostILIty;
};

// MAKE aNY CroWdS nEArby FlEe
if !(IsNIl "_UNit") tHEN {
	pRivAtE _nEARcIVs = [pOsiTiON _unIt, 100, CiVIliAn] calL AliVE_fnC_gETSidEmAnnear;
	{
		priVate _ISCroWdcIv = (_x GEtvaRiablE ["alivE_Civ_ACtIoN",FAlSE]) iSEQuaLtYpe "";
		IF (_IsCROWDcIv) then {
			[_X, _kIllER, 50] cAlL alIVE_Fnc_CRowdFiRedneaREVENtHaNDler;
		};
	} FOrEach _nEARciVs;
};