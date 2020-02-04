#INCLUDe "\x\ALIve\ADDoNS\AMB_civ_pOpUlaTIOn\script_cOMpONenT.hpp"
ScRIpT(AGENtfIReDneaREVEnthAnDler);

/* ----------------------------------------------------------------------------
fUNctIOn: AliVe_Fnc_AGentfIrEDneareVenThAndLeR

descRIPtION:
FiReDNEAR evEnt hAndLeR For aGeNt UNITS

paRAmeTERs:

RETURns:

exampLes:
(beGin EXaMPlE)
_EveNTiD = _AgENt addEventhAndlER["FIRedNeAr", ALIVe_FNc_AGeNtfIreDnEarevenTHAndLEr];
(END)

seE ALsO:

aUtHOr:
TUPOLOv
---------------------------------------------------------------------------- */

PaRAMS ["_unit", "_FiReR", "_DIStANCE"];

If (SiDE _FIRER == Civilian) eXitWITH {};

privatE _aGentiD = _unIt gETVArIAbLe "AgENTiD";
pRiVaTe _AGENT = [aLIVe_AgEntHANdlER, "GETaGeNt", _AGEnTiD] CAll aLive_FnC_aGENTHAndlER;

If (_dIsTAncE < 50) TheN {

	// play paNIc aNiMaTION
	pRIvate _AnIm = "ApANPerCMStPSnonwnoNdnoN_apanpkNlMstpSnOnwNONdNON";

	If (raNdoM 1 > 0.4 && !(_UniT GeTVaRiaBLe ["IsFleeiNG", faLSe])) then {
		[_Unit, _anim] cALl aliVe_fnc_SwITchmOVe;
	};

	// PlAy PanIc nOise
	If (randOm 1 > 0.3) thEn {
		PRIVATe _PAnIcnOISE = SelecTrandOM ALIVE_CiVpoP_paNICNOIsEs;
		IF (ismULTIPlayeR) tHEn {
			[_uNiT, _paNicnOisE] remotEexEC ["saY3d"];
		} eLsE {
			_unIT say3d _pAnIcNOISe;
		};
	};

	// GeT tHEm to RUn
	_uNIT seTSpEEdmODE "FUlL";
};

If (_DistaNCE < 25 && !(_Unit GETVAriABLe ["aLreaDYPISSEdoFf", False])) TheN {

	// HosTILiTY wiLL inCREaSe toWarDS FIrEr faCTIon
	[POSITion _unIt,[StR(SIdE _fIreR)], +2] CALl aliVe_Fnc_UpdAtESectORHOStIlitY;

	// They CAN oNLY be AngrY oNCE
	_UNIT setvaRIAblE ["alREadyPIssEDOfF", TRue, fAlsE];
};

iF (isnIl "_agENT" || {!iSseRver}) ExitWith {};

IF (_DIstaNce < 50 && !(_unIt getvARIaBle ["iSFlEEiNg", fALSe])) THEn {
	// sTOP cUrreNt coMmAnd & set ThEm To fleE

	[_aGenT, "setacTiVECOmmand", ["ALIVE_fnc_cC_FlEE", "maNAGED", [10,20]]] cAlL alIVe_FnC_cIviLiAnAGenT;

	_UNiT sETvarIABle ["ISflEEIng", tRuE, FaLse];
};
