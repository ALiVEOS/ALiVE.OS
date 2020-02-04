/* ----------------------------------------------------------------------------
fUNCtiOn: alIve_Fnc_quEstIoNHAnDLEr

deScriPTIon:
mAIN haNdler FoR queSTIOnS

parameteRS:
stRInG - questIoN

RetUrnS:
NONE

eXAmpLES:
(begin EXaMplE)
["hOme"] cALl Alive_fNC_qUEStioNHAnDlER; //-- aSk wHEre ThEy LIVe
["insurGents"] CAlL ALIVe_Fnc_QuEstIOnHaNdlEr; //-- ASK IF TheY'vE seen Any InsurgEnTS
["STRAngeBehavIOr"] calL aLiVe_fnC_QUeSTioNHandLer; //-- ask IF tHEY'vE Seen ANy stranGe beHaviOR
(EnD)

notEs:
CiVIliAns WIlL Stay StAY HOSTILE AftER bECoMInG hOSTIlE (pERSiStENT THROUGh menu cLOsinG)
civiLIanS mAy bEComE ANNOyed WHEN yOU Keep ASKINg quEstiOns, wHich wILl raisE ThEir HoSTilItY
SoMe REsPonseS ARe shArEd bY the hOSTIle ANd non-hosTilE sectIONs, This iS dONE to Keep a GRAy lIne BEtWeEn hostile And non-hosTile

SEE ALsO:
- NIL

auTHOr:
sPYDERBlACK723

peEr reViEWeD:
nil
---------------------------------------------------------------------------- */

PriVate ["_civDaTa","_cIvInFO","_hostIle","_HOSTIlIty","_AskEd","_civ","_AnswERGIvEN"];
PARAMs [
	["_logiC", objNuLL],
	["_qUesTIOn", ""]
];

//-- DEFINe ContRol iD'S
#defINe mainclASs aLIve_fnC_cIvInterACt
#DefINE ciVinTeraCt_REspONSelist (FINddISPlay 923 dIsplAYCtRL 9239)

//-- GEt Civ HosTiliTY
_hOStilE =  falSE;
_CivDAtA = [_LOgIC, "cIvDATA"] caLL aLIVE_fnC_hASHGEt;
_civINfo = [_CIvdATA, "CiviNfO"] CAlL alivE_fnC_HasHGET;
_CiV = [_lOgIc, "civ"] CaLL aliVe_FNC_haSHgeT;
_CIVname = NamE _ciV;

//-- set qUEstIoNs aSkEd
_aSKED = ([_cIvdaTA, "aSKED"] cALL alivE_fnc_HasHgEt) + 1;
[_civdaTA, "AsKeD", _AsKed] cAll AliVe_Fnc_hashset;

IF (!isnIL {[_CiVDatA, "HOSTiLE"] call ALive_FNC_hasHGEt}) THEn {
	_HOStIlE = TrUE;
} ELse {
	_HoStilitY = _ciViNFo sElecT 1;
	if (raNdoM 100 < _HOSTilIty) THEn {
		_HosTILE = trUe;
		[_CIVdata, "HOsTIlE", TRuE] calL ALiVE_fNC_hAshSet;
	};
};

//-- hash nEW Data TO lOGIC
[_logIC, "ciVdAtA", _CIVDATA] CaLL AlIve_FnC_HaSHseT;

//-- gEt pReVIous reSpOnses
_AnsWERSgiveN = [_civDatA, "ANswerSgIVEN"] cALL aLIve_FNc_hasHgEt;

//-- clEAr pReviOUS RespoNSes
CIViNtERACt_ReSPONsELIST CTRLseTtEXt "";

//-- cHECk if qUEStiON hAs alReAdY bEEN aNsWerEd
iF ((_qUestiON IN _aNSWErsgIveN) aNd (FlOor RAnDOM 100 < 75)) EXITwiTh {
	_reSpoNsE1 = "I'm nOt tElLING You aGAIn.";
	_RESponSe2 = "hAVeN't we alReadY dISCUSSEd thiS?";
	_reSPONse3 = "i hAve aLREady ANswEReD thAT.";
	_respONse4 = "wHy are YOU aSKiNg me again.";
	_RESpONSE5 = "YOu ALREAdy ASKeD Me ThAT.";
	_rEspOnsE6 = "You Are BEgINNinG tO ANnOY mE WIth tHAT qUeSTION.";
	_resPONse7 = "I CAnNOt TalK ABoUT THIS AnyMORe.";
	_rESponsE8 = "yOU HAVE GOTTeN YoUR aNsWERs aLreAdY.";
	_rESpOnsE = [_resPONse1,_rESPONSe2,_resPOnSe3,_reSpoNse4,_reSpoNSe5,_ReSpONsE6,_rESPonsE7,_ResPonsE8] cAll bis_FnC_seLecTRANDOm;
	civINTERact_RespONseliSt CtRLSetTexT _rESpOnSE;

	//-- cHeCK if ciVilIan IS IRRITAtEd
	[_LOGIc,"isIrritAteD", [_HosTIlE,_asKed,_CIv]] cALL MaIncLass;
};

switch (_QUestioN) dO {

	//-- WheRE iS YOUr hOmE LOcAteD
	CASE "hOMe": {
		_HOMepoS = _CIVInFO SELect 0;

		IF (!(_HostIle) AnD (flooR rAndoM 100 > 15)) Then {
			_RESpOnsE1 = FoRmaT ["i LIVE over theRe, i'lL ShOW YoU (%1's hOUSe HaS BEEN maRKeD On THe MAp).", _CIvNAme];
			_resPOnsE2 = fOrmat ["i livE neaRBy (%1'S HoUSe HaS bEEn MARkED on the map).", _CiVNAMe];
			_ReSpONsE3 = FOrMaT ["i WiLL pOINT iT OUt FOr yOU (%1's HousE hAs BEen MaRKEd On THE MAp).", _cIvnAme];
			_reSPONSE4 = foRMAt ["i LIvE rigHT over THerE (%1's hoUSe haS bEen mArked On THE mAP).", _civNAme];
			_rEspOnse5 = FoRmAT ["jUSt oVeR THere. (tHE HOuse is MaRked ON thE MAp).", _ciVNAme];
			_RESponsE = [_reSpONSE1,_rEsPOnsE2,_rEsPOnSE3,_REsPonSe4,_RESPoNse5] cAlL bis_fnc_SELecTRAnDOm;
			ciVinteRaCT_RESpONSeLiSt ctrlsEtteXT _reSPOnSE;

			//-- CrEATe MarKER On HOme
			_AnSwersGIVEN PuShbAck "homE";_AnSWeRgivEn = TrUE;
			_MArKErName = formAT ["%1'S hOme", _ciVNAMe];
			_MArkEr = [STr _hoMepoS, _HOmEPOs, "iCoN", [.35, .35], "coLOrCiv", _MarKERnAME, "miL_cIRclE", "SOLID", 0, .5] cAll ALiVe_FNc_CReaTeMarkErgLOBAl;
			_MarKer sPaWN {sLeep 30;delEtEMarkER _THIs};
		} ELsE {
			_rESpONsE1 = "I am SorRy, But I dOn't FeEl cOmFOrtaBlE giVInG tHAT InFOrmaTIon OUT.";
			_RESPONsE2 = "I DO Not wanT to sHARe ThAT WITH you.";
			_respONse3 = "i Do Not oWE you aNYTHINg.";
			_ReSpoNse4 = "plEasE LEAvE ME AlONE.";
			_rESPOnse5 = "plEASe LEave.";
			_rESpONse6 = "GEt OuT oF HeRE!";
			_RespoNse = [_rESPOnsE1,_ReSPoNse2,_reSPONse3,_rESpOnSe4,_response5,_respOnsE6] CAlL biS_fNc_sELectRAndOm;
			cIviNtERAct_RespOnseLISt CTRlSETTeXT _reSPOnsE;
		};
	};

	//-- wHaT towN Do YoU LivE In
	caSE "tOWN": {
		_HOmePOS = _cIvINfO SeleCT 0;
		_TOWN = [_homePOs] cALl AliVE_FnC_taskgeTNEaREstlocaTIOnNamE;

		iF !(_hostIle) Then {
			if (flOOR ranDOm 100 > 15) tHeN {
				_RESPoNse1 = FOrMaT ["i liVE by %1.", _ToWN];
				_REsPONSE2 = ForMaT ["I LIve In %1.", _toWn];
				_rESPOnSe3 = FoRmaT ["I liVE In THe villAGe OF %1.", _TOwn];
				_rESPONsE4 = ForMAt ["MY HOme ToWN is %1.", _tOWn];
				_RespONSe5 = "You sHOuld nOT BE here.";
				_ResponsE6 = "theY wOuld nOT LIKe mE tALkInG TO you.";
				_rEsponSe = [_rESpoNsE1, _reSPonse2, _RespONSE3, _rEsPoNse4, _rESponSE5, _ResPOnsE6] Call BIS_FNC_SeLecTRaNdoM;
				CIviNTeracT_resPoNSelIst CtrLSettExT _resPoNsE;
				_ANSweRSGIVen pUSHBack "tOWn";_AnsWERGIVen = TRUe;
			} ELSE {
				_ResPOnSE1 = "I Am sORry, But I Do NOT feEl comForTABLe giVInG tHAT inFORMAtIon OUT.";
				_rESPonse2 = "SorRy, I do Not wANT TO AnSWeR ThaT.";
				_RESPonsE3 = "i SHoULD NOT sHARe tHaT with You.";
				_ResPOnSE4 = "i JUSt WaNT To bE LEFT aLONe.";
				_resPonse5 = "pleASe leAVe my CoMmUNiTY ALone.";
				_ReSPONSE = [_REsponSe1,_ResPONse2,_rEspOnse3,_rESPONsE4,_RESpoNsE5] CaLL biS_FnC_SelectrANDOm;
				CIVinTerAct_reSPOnSeList ctrLsETtExT _rESPoNSe;
			};
		} ElSe {
			_RESpONsE1 = "I aM SoRRy, but I dO not fEel cOMfoRtabLe giVinG THAt InforMaTion OuT.";
			_rESPoNSe2 = "i SHOuLd NOt ShaRE ThAT WiTh yoU.";
			_ReSPonSE3 = "I Do nOt Owe You ANyTHING.";
			_REspOnSE4 = "YOU shoULd NOt bE heRE.";
			_ResPoNSE5 = "PlEaSE LEAVe mE ALonE.";
			_RespONSE6 = "i WiLL nOt tEll yoU wHErE i livE!";
			_REsPoNse7 = "YoU WILl not terrOrIzE MY TOWn!";
			_resPONse = [_ReSpONSe1, _rEspOnsE2, _rEsPonsE3, _reSPONse4, _Response5, _ReSpONsE6, _respONSE7] call bis_Fnc_sElECtRANDOM;
			CIvInteracT_REspOnselIst CtrLsEtTEXt _respONsE;
		};
	};

	//-- HAVE YOU SeEN ANy ieD's NEArBy
	CASE "iedS": {

		_IeDS = [];
		{
			IF (_x DiSTaNCe2D (geTPOs _cIV) < 1000) THeN {_iEds pUSHbaCK _X};
		} fOrEach allmINES;

		iF (COUnt _iEdS == 0) TheN {
			IF !(_HoSTilE) ThEN {
				iF (fLooR RAndOm 100 > 25) THEn {
					_resPONSe1 = "ThERE aRe nO IEds neaRBY.";
					_reSPONSE2 = "SoRry, i HaVeN'T seeN aNy.";
					_ReSPOnse3 = "noT ThAT i know oF, SoRrY.";
					_REspONsE4 = "No IEds HaVe been seT NEAR heRe.";
					_REsPonsE = [_REsponSe1, _rEsPOnsE2, _reSPoNSe3, _RESPONSE4] CaLl BIS_fNC_SeLectraNDom;
					CIvInTERaCt_RESPOnSELiSt cTRlsETtExt _REsPonSE;
					_AnsweRSgiVeN pUSHbAcK "iEDs";_anSWErgIVen = trUE;
				} else {
					_reSpOnSe1 = "SOrRY, I DO nOt kNOW.";
					_ReSPoNSe2 = "i CanNOt GivE ThAT tYpE OF infORMAtIon OUt.";
					_ResPoNSE3 = "i wOUlD bE KilLED iF i ToLd yoU.";
					_RESpoNsE4 = "PlEaSe leAVe, they CaN'T SEe me TaLKInG to YOu.";
					_RESPonSE = [_ResPoNsE1, _REspONsE2, _rEsPoNsE3, _respOnse4] cAlL Bis_fnc_SeLeCtRanDom;
					CIvIntERAcT_RespONSelist CTRlsETTexT _rEsPonse;
				};
			} elSE {
				_rESPonse1 = "LIKe i WOUld teLl YOu.";
				_REsPoNSe2 = "JUSt LeAvE ME alOnE ALReadY.";
				_REsPOnsE3 = "YOU wILl HaVe TO fInD thaT oUT for YOuRSElf.";
				_resPOnsE4 = "waTcH YOUr StEp.";
				_RESPoNSE5 = "MaybE I ShOULD HAvE pLaNTEd a FEw.";
				_rESpOnSe = [_resPonse1, _rEsPonSE2, _ReSPonSe3, _resPonSe4, _RespONSE5] CALl bIs_FNC_SelEctrAnDOm;
				ciVinteRACT_reSpOnselisT cTRLsEttEXt _rESpOnSe;
			};

		} eLSe {
			_IEDLOcAtION = GEtpoS (_ieDs CaLl bIS_Fnc_SelectrAndOm);

			IF !(_HOsTIlE) thEN {
				If (FLoor RANdom 100 > 25) tHEN {
					_rESPoNse1 = "yEs I SAw ONe earLIeR (LoCatION MaRked oN map).";
					_rEsPOnSE2 = "Let mE SHOw you oNE (LOcATion mARKED on MAp).";
					_rEsPonsE3 = "I THInK i knOW A Spot (LOCATion MArkeD on map).";
					_ReSPoNsE4 = "i sAW AN insUrgENT plaNt ONE (LocaTION marKed on MAP).";
					_ReSpONsE = [_RESpoNsE1, _rEspONse2, _ResPoNSe3, _reSpoNsE4] CAlL biS_FNc_SElECtrAndOM;
					CIViNteRAct_rEspoNSelIST ctRlSeTtEXT _REspoNSE;
					_aNsWERSGIVEn PUShbAck "IeDS";_aNsWeRgIVEN = tRuE;

					//-- cREATE MArKER on ieD
					_IEDpOs = GETPoS (_ieDs cAll BiS_FNc_SELECTrANdOM);
					_IEdPOS = [_ieDpos, (25 + cEIl ranDoM 15)] cALl cBa_fNc_RanDPOs;
					_MaRker = [str _IedpOS, _IedpOS, "ELLIPSE", [40, 40], "CoLoRrED", "ied", "n_INsTallatIoN", "FDiagoNAL", 0, 0.5] CALL ALive_fNc_CreatemArKErgLoBAl;
					_tExT = [StR (STr _IEDPoS),_iedPoS,"iCon", [0.1,0.1],"CoLorREd","iED", "MIl_Dot", "fDIAgOnaL",0,0.5] cALl AlIVE_fNC_CreAtEmaRkErgloBal;
					[_MARKeR,_text] sPAWn {SlEEp 30;delETemARKer (_ThIs SeLeCt 0);DElEteMArKer (_ThiS SELEcT 1)};
				} Else {
					_reSPOnSE1 = "SorRY, i Do nOT kNow.";
					_reSpOnSE2 = "i CaNNOt GIVE THaT TYPe of iNFORMaTiON OUt.";
					_rEsponSe3 = "I WOuLD be kILLed If I tOld YoU.";
					_reSpONSe4 = "PLEasE lEAVE, ThEY cAN'T seE ME tAlkiNG To YOu.";
					_rESpOnse = [_reSpONsE1, _ReSPONSE2, _RESPonSe3, _reSpoNsE4] cALl BIS_fnC_SELeCtrandOm;
					ciVIntErAct_respoNSelIsT CTRLseTtext _ReSpONSe;
				};
			} elSE {
				_ResPONsE1 = "LIKE I woUld tELl You.";
				_ResPonse2 = "JuSt leAvE mE Alone AlREADy.";
				_rESPoNSE3 = "yoU wiLl haVE tO Find thAT oUr fOr yourSELF.";
				_ResPONsE4 = "waTCh YoUr stEP.";
				_RESPoNSE5 = "mAYbe I shoULD HAVE pLAnted a Few.";
				_RespONSE = [_rEsponSE1, _RespoNse2, _ResPoNse3, _rEsPOnse4, _REsPONSe5] CalL Bis_Fnc_SeleCTrAndOM;
				cIvIntERAcT_RESpOnselIST cTrlseTteXT _rESpONse;
			};

		};
	};

	//-- hAvE YoU SEeN any InsUrgeNT AcTivIty LateLY
	cASE "insurGenTS": {

		_INSuRGEnTFActIoN = [_LOgIc, "inSURGENTfacTIoN"] cALL ALiVe_fnC_HasHgEt;
		_pOs = getpOS _ciV;
		_toWN = [_poS] call AlIVe_FNc_TAsKgETNEaResTlOCAtIOnNamE;

		//-- gET neaRby InSURGeNTs
		_iNSuRgENts = [];
		{
			_leaDeR = LeadEr _x;

			If ((FACtiOn _LEadeR == _INsURgENtFacTiON) aNd {_lEAder DIstaNce2d _pOS < 1100}) theN {
				_INsurGENts pUsHbAck _lEAdEr;
			};
		} ForEACh allgRoUps;

		If (cOuNT _InsURgents == 0) thEn {
			//-- inSurgeNts ArE NOT nEaRBy
			IF !(_hOstILe) thEN {
				iF (FlOOR rAnDOM 100 > 40) ThEn {
					_reSPoNse1 = "sorry i HAvE nOt sEEn aNy.";
					_respONSe2 = "no, THerE ARe NONE NearBy.";
					_respoNSE3 = "NOt reCENTly, sOrRy.";
					_RESPOnSE4 = "THAnKFUllY nO.";
					_ReSPoNSE5 = "i Haven'T seen aNY.";
					_respoNSE = [_RESPonsE1, _rESpoNSe2, _REsPonSE3, _RespoNSE4,_rEspOnSe5] caLl BIs_fNc_SElecTraNdom;
					CIvInTErAcT_REspONsEList ctRlSettExt _ReSPONSE;
					_AnSwErsgiVeN PuShbaCK "InsURGENTs";_AnSWergiven = TrUE;
				} ElsE {
					_REsPONse1 = "PLeasE, jUST LEAVe ME ALone.";
					_respoNse2 = "i Don't waNT tO TAlk abOuT this.";
					_RESPONsE3 = "I dOn'T waNt TO talk tO you.";
					_rEsPONsE4 = "I cAN't teLl yoU.";
					_REspONSe5 = "theY WoULdN'T liKE me TalkING TO YOU.";
					_RESpOnSe = [_ResPonse1, _reSPonsE2, _reSPoNSe3, _reSponse4,_rEspoNse5] caLl BIS_fNc_SELECTRANDOm;
					ciViNtEraCt_respoNsElIst CTrLsETteXt _respOnSE;
				};
			} ELse {
				_rESponse1 = "As If i wOulD Tell You.";
				_reSPOnSE2 = "GeT AwAy From me.";
				_RESpoNse3 = "PLeasE, JUST LeaVe Me AlOne.";
				_rESPoNsE4 = "I Don'T wANt To tALk aBoUT ThIS.";
				_rESpOnSe5 = "i dOn'T waNT TO TaLk To yOu.";
				_ReSPoNse = [_rESPOnSE1, _REsPoNsE2, _REsponSe3, _REsponse4,_ReSpoNSe5] CALL biS_fNC_seLECTRAndOM;
				CiViNtErAcT_rESponSELIst cTRlseTtExt _rESPoNsE;
			};
		} Else {
			//-- iNsurGeNts aRE nEARbY
			IF !(_hOStiLE) THEN {
				//-- RanDOM chAncE to revEAl iNSUrgents
				if (floOR rANdom 100 > 50) thEn {
					//-- rEVEAL lOCatIoN
					_ResPOnse1 = ForMat ["sOmE inSuRGentS are NeAr %1.", _TOwn];
					_respoNsE2 = "dOn'T SnitCH ON Me (INSurgeNts MaRkEd ON mAp).";
					_responSE3 = "yES, Let mE Show You wherE i saw THEM (iNsurGEnTS MArKED on MAP).";
					_reSPoNse4 = "YEs, BUt YoU MUST keEp tHiS sEcREt (InsuRGentS mARkEd oN map).";
					_ResPonSe = [_RESPoNSE1, _REsPOnse2, _ResPonSE3, _RespOnSe4] calL bIs_fNC_SELEctrandoM;
					civINtERAct_ResponSELisT CTrLsETtExt _rEsponSe;
					_AnSweRsGIVen PUSHBAck "InsurgenTS";_AnSWERGIVEN = TRUe;

					//-- cReaTE mArkER on inSurGenT gROup
					_INSURgentlEadeRs = [_INsuRgeNtS,[gETpos plaYEr],{_inpUt0 DistANce2d getpOS _x},"aScEnD"] CAll BIS_Fnc_SorTby;
					_insUrGeNTpOS = getpoS (_insURGEntLEadeRS SeleCT 0);
					_INsUrGENtPOS = [_inSUrGeNTpOS, (75 + CEil RAnDOm 25)] cALL cBA_fNc_rANDPOS;
					_maRKeR = [STR _InSurgENTpoS, _inSUrGenTpoS, "eLliPsE", [100, 100], "cOLOrEASt", "INsURgENts", "n_InSTAllaTiOn", "fdiAGOnaL", 0, 0.5] CaLl AlIVE_fNc_CrEatemaRkergLoBal;
					_tExT = [StR (STR _inSURgEntpoS),_iNSUrgEntpoS,"icOn", [0.1,0.1],"cOlOrRed","insurgEnTS", "MIL_DOt", "FDIAGOnaL",0,0.5] caLL AlivE_FNC_CReAtEMARKeRGLObAl;
					[_marKeR,_Text] sPAwn {slEEp 30;DeLETeMARKEr (_ThiS SeLeCT 0);DeLeTEmaRKEr (_ThIs SElEct 1)};
				} ELsE {
					//-- DON'T rEvEal locATioN
					_ReSpONsE1 = "THEY WOuldn'T WAnT Me talKinG To YOu.";
					_RESPoNSe2 = "yOu cAN't ASK QuEsTIONS LIke thaT.";
					_ResPonSE3 = "ArE You craZY?";
					_respOnSe4 = "pleAsE, just leAVe Me ALOnE.";
					_ResPOnSE5 = "i dOn'T WAnT to TALk aBOUt THis.";
					_REsPoNSE6 = "I doN'T WaNt to TaLK tO YoU.";
					_ReSpONSE = [_rESpONSE1, _reSPONSE2, _RESPoNsE3, _rEsPoNsE4] CaLL bis_FNc_SElecTRandoM;
					CiViNTeract_reSponSEList ctrLSetteXt _responsE;
				};
			} ElSE {
				_rEspONse1 = "AS if I woUlD TElL you.";
				_responSE2 = "GeT AWaY FRom ME.";
				_resPOnsE3 = "pleAsE, jUSt LEAve me aLonE.";
				_RESpOnsE4 = "I doN't waNt To TAlK abouT This.";
				_ReSpoNSe5 = "I dON't WANT tO TAlk to YoU.";
				_reSpOnsE = [_ReSPonSE1, _ReSponSe2, _rEsponse3, _RESPonSe4, _ResPonSe5] caLL BiS_FnC_seLECTRANdOm;
				CivinteracT_RESpOnseLiSt CtRLSeTtEXT _ReSPONSe;
			};
		};

	};

	//-- DO yOU Know thE locaTiOn of Any INSuRGeNt HiDEoUts
	CAse "HIdeOutS": {
		_instALLatiONS = [_CivDatA, "insTALlaTIoNs"] caLl aLiVE_Fnc_haSHgEt;
		_AcTIOns = [_CIVData, "acTiOnS"] CAll aLiVe_FNc_HAsHgET;
		_inStaLlaTIons pARamS ["_FACtOry","_Hq","_dePOT","_rOadBLoCKS"];
		_ActiOnS parAMs ["_AmbuSh","_SAbotAge","_IED","_SuicIdE"];

		If ((_FActoRy ISeqUaLTO []) aND (_hq IseQUALTo []) And (_DePot ISEQUAlto []) And (_rOAdBLOCkS isEquAlTo [])) theN {

			iF !(_HoStIle) ThEn {
				iF (floOR RanDom 100 > 30) tHEn {
					_resPONsE1 = "InSUrGeNts havE NoT esTablIShed AnY inStaLlatIONS heRE.";
					_rEsPOnsE2 = "luckILY, nO.";
					_reSpoNSE3 = "NO, I have nOt.";
					_resPOnSe4 = "ThERE ARe nO inSuRGENT bASES hERe.";
					_RESpOnSe5 = "theRE are no inSurgENt HiDEOuTs HeRE.";
					_resPonSe6 = "iNSURgENtS HAVe NOt TaKeN over THiS AREa YeT.";
					_rESpOnse7 = "tHerE ARe No hidEoUTs hErE.";
					_ReSPONSe8 = "tHeRe aRE No INstaLLatIOns here.";
					_ReSPonsE9 = "We are STILl fREe frOm THEiR REiGN.";
					_rESpOnse = [_respONse1,_rESPoNSE2,_rESpONsE3,_ReSpoNSe4,_RESPoNSe5,_rESpOnsE6,_ReSPONSe7,_REsPoNSe8,_RespOnsE9] cAlL bis_Fnc_seLECTRANDoM;
					CiVinTeRAcT_rESPONseLIsT ctRLsETTEXt _rEspONSe;
					_aNSWeRSgIveN puShBACK "hiDEouTS";_ANSWergIVEN = True;
				} eLsE {
					_ReSpoNsE1 = "arE yoU crAZy.";
					_rEsPOnSe2 = "i CANnot tAlK AbOUt ThiS.";
					_responSE3 = "Do yOu WaNt tO gET mE kiLLeD?";
					_respONSE4 = "I WilL not PUT MySELF in dangeR.";
					_ReSpONse5 = "I WILl NOT pUt MYSELf At Risk.";
					_reSPoNSE = [_ResPONsE1,_ReSpOnsE2,_reSPonSE3,_responSe4,_rEspONSE5] cALl BiS_fNc_sELECTRanDOM;
					civINTEracT_responSElIsT CTrlSEtTExT _REspoNSE;
				};
			} Else {
				_respOnsE1 = "I DON't hAvE TIMe fOR thIS.";
				_ResPOnSE2 = "i canNot TaLK ABoUT thiS RIGHT NoW.";
				_reSPoNSe3 = "ARe YoU CRaZY.";
				_respOnSe4 = "WHY woulD yOu asK Me SUcH qUesTION.";
				_REsPonSE5 = "THaT iS A CrAZy queSTioN to ask.";
				_REsPoNSE6 = "do yoU Want to gEt Me kIlled?";
				_ReSponse7 = "I WILl Not pUT myselF In DANGeR.";
				_rEsponsE8 = "WhY wOuld You aSK thAt?";
				_ReSPonse9 = "I CanNOT HelP you WiTh thAt.";
				_RESpOnse = [_reSPonsE1,_REsponSE2,_respONSe3,_rEspoNSE4,_respoNsE5,_reSPONSe6,_reSpoNse7,_ResPoNsE8,_RESponsE9] Call bIS_FNC_SelECTRAnDoM;
				CIViNteRacT_RESPOnSEList cTrLSEttext _ReSponSE;
			};
		} ELse {

			prIVAte ["_INSTaLLatiON","_TYpE","_tyPEnAme","_instALLaTiOndAta"];
			For "_I" FRoM 0 To 3 Do {
				_INSTAllatiOnaRRAY = _iNstAllATionS Call bis_FNC_SelectraNDOm;

				if (!(_inSTaLlATIOnArrAY iseQuaLto []) aND (isniL "_iNSTaLlatIoN")) then {
					_indEX = _inSTaLlaTIOnS FinD _INStaLlaTiONaRray;
					SWITch (StR _iNdEx) dO {
						case "0": {_tyPenamE = "ieD FaCtory";_TYpe = "ieD FacTOry"};
						CaSE "1": {_tYpenaMe = "rEcRuItmENT HQ";_tyPE = "ReCRUItMeNT HQ"};
						cASe "2": {_tYpenAme = "MunItioNs dePoT";_typE = "MUnItioNs depOt"};
						cASE "3": {_tYpENAMe = "ROAdBloCkS";_TYPE = "RoaDbLOCKS"};
					};
					_inStaLLatiOn = _iNSTALLaTIonaRRAY;
				};
			};

			IF ((IsNiL "_Type") or (iSnil "_inSTAllAtiOn")) exITwITh {

				_rEspONSe1 = "I CAN'T TALk aBOuT thAt.";
				_ResPoNse2 = "They wOULd KiLL Me.";
				_rEsPoNsE3 = "ARe you cRAZy.";
				_ReSPonsE4 = "Do yOU WAnT To GET Me KILled.";
				_rEsponse5 = "i CanNoT PUt my fAmIly At risK By anSwERING THAT.";
				_rESPONSE = [_reSPOnSe1,_ReSPONse2,_reSPOnSE3,_REsponSE4,_RespOnSe5] CALl bis_FNC_selectrAndoM;
				CiVINtEracT_rEsPONSeLIsT CTRlsETtext _ReSPoNse;
				_answeRsGIvEN PUsHBack "HideOUTs";_AnsWerGIven = tRUE;
			};

			If !(_HosTILe) tHEN {
				if (FLooR RandoM 100 > 60) ThEN {
					IF (FLoOR rAnDOm 100 > 60) tHeN {
						_reSPOnse1 = FoRMat ["i noticeD a %1 NeArBY (%2 MARKEd oN Map).", _TyPE,_typenAME];
						_ReSPonSe2 = forMat ["sOMeoNe TOld Me ThEre waS A %1 cLose BY (%2 mARked On map).", _tYPE,_TyPENaMe];
						_RespOnsE3 = FORmat ["I oBSErVED InSURGeNTS SETTinG UP a %1 (%2 MarkED On mAp).", _tYPe,_TyPEname];
						_respoNSe4 = foRmAt ["i knOw ThE loCAtion of A %1 (%2 MARkED oN mAp).", _tYpE,_TyPeNAmE];
						_respONse5 = FoRMat ["insuRGEnTs estABLIsHED a %1 (%2 maRkeD on maP).", _Type,_TYpeNAmE];
						_respONSE6 = foRMat ["I can shOw YOU THe LOCAtiON of a %1 (%2 marked on MAP).", _TYpE,_tYPeNaMe];
						_rEspONSe7 = fORmAt ["you MUsT KEep thIs A SecreT (%2 MArkEd On MAp).", _TYpE,_tyPeNAmE];
						_rEsponSE8 = forMAt ["You MUst pROMISe TO proTeCT me (%2 marKeD on MaP).", _tYPE,_tyPenAmE];
						_rESPoNse9 = fOrMat ["plEasE REMove tHE %1 fROM the aReA And rEsToRE PeaCE (%2 mArKEd on MAp).", _tYpe,_TypENaME];
						_RESpONSE = [_ResPoNse1,_reSponsE2,_rESPOnSE3,_resPonse4,_ReSPonse5,_REspOnsE6,_rEsponSe7,_rESPonse8,_respOnSE9] cALl biS_fNC_seLecTraNdOm;
						CIVIntEract_rEsPOnseliST ctRlSetText _rESpONsE;
						_anSWeRSgIven pUshback "hIdeOUts";_aNsWeRGivEN = tRUE;

						iF (floOr random 100 > 30) ThEN {
							//-- cREaTE mArKeR On geneRAl insTalLatION lOcATIOn
							_INsTaLlaTIONpos = gEtPOs _instALlATION;
							_INstalLaTIoNPoS = [_iNstAlLaTIONPOs, (75 + ceil RanDoM 25)] cALL Cba_fNC_rAnDpOS;
							_maRKEr = [Str _iNStaLLATIonpOs, _iNSTALLATIoNPOs, "eLlIPSE", [100,100], "COlOREASt", _tYPENaME, "N_INSTallation", "FDiagoNAL", 0, 0.5] CalL ALIVE_fNc_crEaTemARKerGlobAl;
							_TexT = [STR (str _inStaLlaTiONPos),_iNSTALLatiOnPos,"iCoN", [0.1,0.1],"CoLoRreD",_TyPENamE, "MIL_DOt", "fdIAGONaL",0,0.5] CALl alIVe_fnc_CREAteMARkeRgLObaL;
							[_mArKEr,_TExt] SPawN {sLeeP 30;DElEtEmArkEr (_THis Select 0);deLETemArker (_THIs sELECT 1)};
						} Else {
							//-- creAtE MarKer On inStaLLATIOn LoCatiON
							_inSTALLAtIoNPOs = getpos _inSTallaTION;
							_mArKER = [STr _insTalLAtIonpOS, _INStallATiONpOs, "Icon", [1,1], "coLoRRED", _TYpe, "N_instAlLATiON", "SoLID", 0, .5] caLl ALiVE_FNC_CreATeMaRKeRGlOBAl;
							_mARKer SPAWN {SlEeP 30;dElEtemaRkEr _ThIs};
						};
					} ELsE {
						_RESpoNSe1 = FoRmaT ["i NOTIcEd a %1 nearbY.", _TYpE];
						_ReSpONse2 = FORMAt ["sOMEoNE ToLD mE TheRe wAS a %1 CLOsE bY.", _tYPE];
						_reSPoNse3 = FOrmAT ["i oBserVED inSurGents SETTiNG UP A %1.", _TYpe];
						_rESponsE4 = ForMaT ["iNsUrgents HaVe pREPARED A %1 nEARBy.", _type];
						_REspoNse5 = FoRmAT ["InsURGENTS eStablISheD A %1 clOsE by heRe.", _TYPE];
						_RESPOnse6 = foRmAT ["OtHers haVE mEnTIOned a %1 cloSE by.", _TyPe];
						_reSPoNSE7 = FORmAt ["iNsURGeNtS hAve SEtUP A %1 neArby.", _TYPe];
						_rESpONSe8 = FoRMat ["restORE pEacE To tHiS ARea, tHEre IS a %1 AroUNd Here.", _TypE];
						_rEsponse9 = foRMAT ["I do not kNow whERe it is, BUT iNSUrGeNTs aRe OpERatinG a %1 somEWhERe aRouND HERe.", _TypE];
						_rEsPoNse = [_reSponSe1,_REsPOnsE2,_resPoNsE3,_reSpONsE4,_RESPonsE5,_rESPOnSe6,_reSpoNse7,_rEsPonse8,_rEspOnsE9] CALL bis_FnC_sElectRaNDOm;
						cIvinteRaCT_ReSponSEList CtRlSETTExT _rESPOnSE;
						_AnSweRSgiVen pUShbaCk "hIdEoUTs";_AnswERGIVEN = TruE;
					};
				} ELse {
					_resPOnsE1 = "I can'T taLK ABoUt THAT.";
					_reSpoNse2 = "thEY woULD kILL ME.";
					_REspONse3 = "aRE You CraZY.";
					_ReSPonSE4 = "dO YOU Want TO get me KIllEd.";
					_reSpONSe5 = "i CannOt PUt my FaMIlY AT RIsk bY aNsWeRinG That.";
					_RESPonSe = [_REsPoNse1,_rESponSE2,_reSPONSe3,_rEsPoNSe4,_rEsPonSE5] cAll bIS_fnc_SeLeCtRAnDom;
					cIVINtERACt_ReSponsElIST CTrlSetText _RESponse;
					_ANsWERsgiVEn PuSHback "HidEOuTs";_AnswERgiVEN = tRUE;
				};
			} ElSE {
				If (FLOor rANdom 100 > _hoStILiTy) ThEN {
					_RespoNSE1 = FoRmaT ["I nOtiCed A %1 NEARBY.", _TYpe];
					_reSponsE2 = FoRMaT ["SOMEoNE toLd Me tHerE WAS a %1 cLoSE bY.", _tYpe];
					_rESPonSE3 = FORmAT ["i ObSerVEd INSuRGEntS setting Up a %1.", _tyPe];
					_REsponsE4 = forMAT ["INsUrgENTS HAve PREparEd a %1 nEaRBY.", _TYPe];
					_ResPONSe5 = fORMAt ["INSurGents estabLiShed A %1 cLosE by HeRe.", _TYPe];
					_rEspoNSE6 = FOrmaT ["othErs HaVe MENTioneD A %1 Close BY.", _tYPe];
					_respoNsE7 = forMat ["inSurgEnts HavE sETuP A %1 NEARBy.", _tYpe];
					_rEsPONSE8 = fORMAT ["ReStOrE PEaCE to ThIs arEA, ThEre Is a %1 aROUNd HeRe.", _tyPE];
					_respoNse9 = FOrMat ["I dO nOT kNOW WhERe IT is, buT InSuRGenTS aRe opeRAtinG a %1 soMEWhEre AROUNd hErE.", _TYpe];
					_reSpoNSE = [_ReSPOnse1,_REsPONSE2,_RESPoNse3,_ResPonsE4,_REsPONsE5,_RESPOnse6,_rEsPoNSe7,_reSPOnsE8,_REspOnsE9] cAll BiS_FnC_sELECTRandoM;
					ciVInTerAcT_REsPOnSeliSt CtrLSeTTEXt _ResPOnsE;
					_anSwErsgIVEn puShBacK "hidEouTs";_aNswERGiVen = TruE;
				} elsE {
					_responSE1 = "I CaN't TALk aboUT That.";
					_reSPonSE2 = "theY WouLD KilL mE.";
					_RESPOnSe3 = "ARe YOU crAzY.";
					_rESpOnsE4 = "Do you wAnT tO GET Me kiLLeD.";
					_reSPoNSe5 = "i CAnnoT pUt MY FamIly aT risK By aNsweRing ThaT.";
					_reSPoNse6 = "gEt OUT of HeRe!";
					_rEsPonse7 = "gET AWAY frOm me";
					_RespONSE8 = "you dISGuSt me!";
					_REspOnSe = [_REsponsE1,_RESpoNse2,_reSponSe3,_RespONSE4,_RESpONsE5,_rEsPONSe6,_rESponsE7,_reSpONSe8] caLL BiS_fnC_SelECtraNdOm;
					cIVinTeraCT_RESpoNselisT CTrLsEtTExt _RESpONse;
					_AnswErsgiVEn PuShBACk "hIDeOuTs";_answerGiVeN = True;
				};
			};
		};
	};

	//-- haVE YOU NotiCEd aNY sTRange beHavioR lATeLY
	CaSe "strANgeBEhAvIOR": {
		_HOstiLeCiViNfO = [_cIVdAtA, "HoStileCiVINfO"] CaLl Alive_fNc_hAShGeT;	//-- [_Civ,_HomePos,_ACTIVecOmMaNDS]
		//-- cHEcK If DaTA EXIStS
		if (CoUNT _hOStILEcivinFO == 0) then {
			iF !(_hoStIlE) ThEN {
				iF (flOoR RAndom 100 > 70) THen {
					_rESpONse1 = "i haVE nOT SEeN anythiNG.";
					_ReSpONSE2 = "soRrY, i HAvEn't.";
					_RESPoNSE3 = "No, i Have NOt.";
					_rEspONse4 = "TherE hAS beEn nO sUSPiCIoUs beHAVioR lAteLy.";
					_RESPonse5 = "EVERyThiNG is pEAcEFuL HeRE.";
					_rEsPonsE6 = "WE ARe a peACeful coMmUnity.";
					_ReSPONSe = [_rEspoNse1, _RESpoNsE2, _ReSPonSE3, _rESPoNSe4, _REsPONse5, _REsPonsE6] CALl BIS_fNc_sELectRandOm;
					CIVInTErAct_rEsPonSELIsT CtrLsETTEXt _reSpOnsE;
					_AnsWERsGiVEn pUShBACK "sTrangeBehavioR";_AnsWErGIveN = TRue;
				} ELsE {
					_reSPonSe1 = "i WIlL not Put mySelf at RIsK.";
					_responsE2 = "thEy WOulD KILl me iF i TOld YOu.";
					_respoNse3 = "i caNnot taLk AboUT THat.";
					_REspONSE4 = "tHErE Has BEeN nO SUSpiCiouS bEHaVior lAteLy.";
					_rEspOnsE5 = "tHeY wOUldN't wANt ME TaLKiNg TO You.";
					_ReSpONSe6 = "i ShouLdn'T be TaLkIng AbOut ThIs.";
					_ReSpOnSE = [_RespONse1, _ReSpOnSe2, _respoNse3, _ReSPONse4, _ResPONSE5,_rESpOnSE6] CALL Bis_fNc_SElECTraNDOm;
					cIvIntERAct_reSPOnsELIst ctRlSetTeXt _ReSPonsE;
				};
			} Else {
				_REsPonSe1 = "i Cannot talk abOUT thaT";
				_rESPOnse2 = "THey woULDn't WanT mE TALKInG to You";
				_ReSpONSe3 = "i cANnOT Help yoU";
				_rEspOnse4 = "nO, I HaVe Not";
				_ReSPOnSE5 = "I HAVE NoT seeN AnYTHing LAtElY";
				_response6 = "THeRe IS nO daNGEr HErE";
				_reSpoNSe7 = "i DoN't hAve Time For this";
				_REspOnSE = [_RESponSE1,_rEsPoNse2,_ResPonsE3,_rESpONSE4,_rEspOnSe5,_reSpoNsE6,_RESPOnSe7] caLL bis_FNC_selECTranDOM;
				CiviNTeracT_RESpoNSelIsT CTRlseTTeXT _respOnSe;
				_AnSwErsgiveN PuSHbACk "strangeBEHaVioR";_AnsweRGiven = TRUE;
			};
		} ELSE {
			_hoStiLEcIVinfO pAramS ["_hosTiLeCiV","_HomEPOS","_AcTIVEcoMmanDs"];
			_ACtIvECoMmAnd = _aCtiVecOmMandS CAll bis_FNc_sEleCtRANDom;
			_actIVECOMmAnd = _actIVecomManD sElECT 0;
			_acTiVepLaN = [_lOGic,"getACTiveplAN",_acTiVeCOMMAnd] CalL maiNclASS;

			IF (IsniL "_acTIVeplan") EXitwith {civinteRacT_respONseliST CtRlSetTEXt "i cAn'T TAlk about tHIS RIGht nOW."};

			IF (!(_hOStiLe) anD (FLOoR RanDom 100 > 70)) THEN {
				_REsPonsE1 = fOrmaT ["i heARd %1 WaS %2.", nAME _HosTiLeCiv, _ACtivEPLan];
				_rEspONSe2 = fORMaT ["soMEoNe TOld ME THAT %1 WaS %2.", name _HoStIleCiv, _aCTIVEPLan];
				_Response3 = fORmAT ["I SAw thAt %1 wAs %2.", Name _HOstilEcIV, _acTiVepLAn];
				_RESPOnSE4 = FOrmAt ["I ThINK %1 WAs %2.", nAME _HostileciV, _ActIvEPlan];
				_RESPonse5 = forMAt ["I waS iNFORMEd ThAT %1 Was %2.", nAmE _hOStIlEciV, _AcTiVEPLan];
				_ResPOnsE6 = fORmaT ["I was ToLD %1 wAS %2.", namE _hoSTILeciv, _ACTivePLan];
				_RESPOnsE = [_reSpOnse1, _REsPONsE2, _rEspoNse3, _reSPOnSE4, _respONse5, _ResPonSe6] call BIS_FNC_sElECTRANDOm;
				cIvINTeraCt_ReSPoNseliST ctrLSeTTeXt _RESpoNsE;
				_ansWeRSgIven PushBAcK "straNgEbeHaViOr";_aNsWErGIvEN = tRuE;

				iF (flooR RaNdoM 100 <= 35) tHeN {
					sWItCH (StR FLoor raNdom 2) Do {
						cAse "0": {
							_REsPONSE1 = " I OVERHEARD WHERE He WAs (posItIoN maRkED On MaP).";
							_reSPONse2 = " sOmeONe TOLD me WHERE hE waS (posiTiOn MArKed ON map).";
							_ReSPoNse3 = " I saW him EaRLier (pOSITIOn MarKed On MaP).";
							_rEspoNSe4 = " i i tHINK i knoW WHEre you CaN FiNd him (PositION mArked ON Map).";
							_reSpOnsE = [_resPOnSe1, _responSe2, _RESPonSe3,_RespONSe4] cALl bIs_fNC_seLeCTrANDOm;
							civinTERACT_resPoNSELisT cTrlsetTExT ((ctRlTExt cIViNteRAct_respoNSelisT) + _rEspoNSe);

							//-- creAtE mARker oN hOstILE cIV lOcaTiOn
							_civPos = [gEtpos _hoStIlecIV, (10 + cEIL RanDOM 8)] CaLl CBA_FNC_raNDPos;
							_MArkerNAmE = FormAt ["%1'S LOcATion", NAmE _HoSTIlECiv];
							_markEr = [StR _CivPOS, _CiVPoS, "ellIPSe", [40, 40], "CoLOrReD", _maRkernAME, "n_inStaLlatiON", "FDiAGOnAl", 0, 0.5] CAlL aLIVE_fnc_CReATemArkERGLobAL;
							_TEXT = [str (stR _CIvPOS),_ciVpOS,"icOn", [0.1,0.1],"COlorRed",_MArKernAme, "mIl_dOT", "FdiaGonAl",0,0.5] caLl aLiVe_Fnc_CrEAtEmArkErgLobAl;
							[_maRKER,_Text] spawn {sLEeP 30;DELETEMaRkeR (_tHIS SelecT 0);dELeteMARkER (_tHIS SeleCT 1)};
						};
						Case "1": {
							_RESPOnSe1 = " i'Ll SHoW yOu WhERe he lIVeS (HOMe MArKED on MAP).";
							_ResPOnSe2 = " I KnOW WheRe hE LIVeS (HOMe MaRkeD ON mAP).";
							_reSPOnse3 = " soMeoNE TOLD ME wHere he LIVEs (HOmE MArkeD oN mAP).";
							_rESpoNse4 = " I Will shoW yOu wHERE You cAN fIND HIm (hoME MaRked On MAp).";
							_rESpoNSE = [_REspoNSe1, _RESPoNse2, _response3,_REsPoNSe4] CALL biS_FNC_sELECTraNDoM;
							CIVinteRaCT_reSPONsELisT CtrLSETTExt ((CtrltexT ciVINtERACt_RespONseLiSt) + _REsPonse);

							//-- cReAtE mARKEr oN HostiLE CiV LoCatIon
							_mARKERNAME = FOrMat ["%1's homE", Name _HostileCIV];
							_mARkEr = [sTr _hOMepoS, _homePos, "ICOn", [.35, .35], "COLOrRED", _maRKErNAme, "mIl_CiRCle", "SoLid", 0, .5] caLl AlIve_fnc_CReATemaRKeRgLOBaL;
							_mArkeR SPaWN {SlEEp 30;DeletEmaRkER _THIs};
						};
					};
				};
			} ElSE {
				iF (floOr RaNDom 100 > _hOStILIty) ThEN {
					_resPonSE1 = FoRmat ["I HEARD %1 wAS %2.", NAmE _hostileCIv, _ACtivePLaN];
					_reSpOnse2 = forMAt ["SOMEONE TOlD Me that %1 wAS %2.", naME _hOStiLecIv, _ACtIVePlAn];
					_REsponse3 = foRMat ["I saW THaT %1 Was %2.", name _hOstiLeciV, _aCTIVePLAn];
					_ResPONSe4 = forMAt ["I THiNK %1 wAS %2.", NAmE _HostileCiv, _aCtivepLaN];
					_RESpOnse5 = FOrmat ["I WAS INFORmEd tHAT %1 was %2.", nAmE _HOsTiLeCIV, _AcTiVEplAN];
					_resPOnSe6 = fORMAT ["i waS TOLd %1 WAS %2.", nAmE _hOsTilEcIv, _ACtIvEplAn];
					_rESPonSE = [_respOnsE1, _RESPoNSE2, _REsPOnse3, _resPonSE4, _RESPOnsE5, _ReSPOnSE6] caLl Bis_fNc_sELeCtRANDoM;
					CIVInteRaCt_REsPONsELisT CTrLsetteXt _rESpoNSe;
					_aNswErSgIVEn PUSHbACK "strangeBeHavIOr";_anSweRGiVen = trUE;
				} Else {
					_RespONsE1 = "i CaNNOT TaLK abOUT ThAT";
					_RespONsE2 = "theY wOULDN't wAnt me TalKINg TO yOU";
					_REsPONsE3 = "i caNNOT heLp yOU";
					_rESpONSE4 = "NO, i hAve NoT";
					_REsPOnSE5 = "I haVE nOT SEEn AnYtHiNG LatELY";
					_reSpONsE6 = "THeRe IS NO dANGER HerE";
					_rESpOnSe7 = "i doN't havE TIme FOr This";
					_ReSpoNse = [_rESPonsE1,_REspOnse2,_rESpOnse3,_RESpOnSe4,_rESponsE5,_ReSpONse6,_rESpoNse7] caLl BiS_fNc_sElECtRANdom;
					CiviNterAcT_RESpONsEliSt CtrLSETTExt _ResPOnsE;
					_aNsWerSGIvEN pusHbaCK "strAnGebEhAvioR";_aNsweRGIVEN = tRuE;
				};
			};
		};
	};

	//-- whAt IS yoUR oPiniOn Of OUR foRcES
	CASE "OpiNioN": {
		PRiVAte ["_Response"];
		_PersonALhOsTIliTy = _civinfo sELecT 1;
		_TowNhOStILitY = _CIVINfO sElEct 2;

		iF (((_tOwNhOsTiLItY / 2.5) > 45) aND (fLOoR randOM 100 > 25) AnD (_peRSOnalHoSTiLiTY < 50)) ExitwITH {
			_rEspOnse1 = "ThEY woulDn't LIKe mE TALKing To YOu.";
			_reSPoNse2 = "I CAN't talk abouT tHiS.";
			_resPONSe3 = "PlEAse.. JUST lEAve ME aLoNE.";
			_ResPOnse4 = "I CaN'T HElP you.";
			_ReSPOnse5 = "pLease lEAVe BEForE They SeE YOU.";
			_ResponSe6 = "YOU MUSt leAvE immeDIAtelY.";
			_rEsponse7 = "THEy MUsT not sEe Me TalkInG TO yoU.";
			_resPOnSE = [_RESpOnse1, _rESPOnse2, _reSPonse3, _ReSPONSE4, _RESPonsE5, _ReSPonSE6,_ReSpOnse7] CaLL bIs_Fnc_selECTRaNdOM;
			civINTErACT_reSPOnseLIst CTrlseTteXT _reSpOnSE;

			//-- cheCk iF cIVILiAN iS IRRITAtED
			[_loGic,"isIRRitAted", [_hoStIle,_askEd,_CIV]] caLL MaINclass;
		};

		IF !(_HOSTILE) tHeN {
			IF (fLoor ranDom 100 < 70) ThEn {

				//-- giVe ANsWER
				IF (_PERSONalHostILiTy <= 25) then {
					_reSpONSE1 = "I SupPOrt YOU.";
					_resPONSE2 = "yOU wIlL hAve NO proBlEms wIth me.";
					_REsPonSE3 = "i SuppOrt YOUR cAuSE.";
					_ReSpONse4 = "yOu Do NOT havE TO wORRY AbOUT me.";
					_REsponsE5 = "I fULLY SuPPOrT Your FOrceS.";
					_ReSpoNsE = [_rESpOnSe1, _REspoNse2, _RespOnSE3, _REsPONSe4, _ReSPoNse5] cAlL BiS_fnC_sELECTRAndOm;
				};

				if ((_PErSOnaLhOSTiLitY > 25) aNd (_peRSoNAlhOstiliTY <= 50)) thEn {
					_ReSpoNsE1 = "i MOStLY sUppOrt yOu.";
					_reSpONSE2 = "i SUPporT you. dO noT MesS It up.";
					_ReSPONsE3 = "I HAvE MiXEd FEELInGS AbOuT YoUR foRCeS.";
					_reSpoNSe4 = "yoU have kEEP my tRUsT.";
					_rESPonse5 = "I HAVe sUpPOrTed YoU For AwhIlE.";
					_ResPONSe = [_RespONSE1, _RESpONsE2, _RESpoNse3, _rEspoNsE4, _RESpOnsE5] call bIs_fnc_SeLeCtraNDom;
				};

				IF ((_PeRSoNaLhostiLITy > 50) anD (_peRsONalhosTIlIty <= 75)) Then {
					_REspONsE1 = "youR FORceS haVe mAdE baD dECISioNs lAtElY.";
					_ReSPoNSE2 = "I Am BEgINNING to DislIKe You.";
					_reSponsE3 = "You muST rEgaiN mY TrUST.";
					_rEsponSe4 = "yOU bEtter Not StaY loNG.";
					_ReSPONsE5 = "I dO not SUPPorT yOu.";
					_respOnSE = [_RESpOnSe1, _rEsPoNse2, _REsponse3, _Response4, _rEsPONSe5] call BIs_fnc_sElECTRandom;
				};

				If ((_peRsONalHOSTILity > 75) And (_PerSONalhostiliTY <= 100)) THEN {
					_resPoNSE1 = "i sTRONgLY OPpOSe Of YOUR prESenCe hEre.";
					_RespONSe2 = "You better leAve.";
					_reSPonsE3 = "I Do noT suPpoRT yOu.";
					_ReSPONse4 = "i hATe youR forCES.";
					_ReSPoNSe5 = "You neED tO LEaVE iMMeDIATELY.";
					_resPoNSE = [_resPONSe1, _resPOnSE2, _ResPONsE3, _ReSponSe4, _rESPoNSe5] cALl bIS_fnc_selECTRanDOm;
				};

				IF (_PeRsONALHoStILIty > 100) thEn {
					_rESPOnSE1 = "i aM EXTReMELY oPpOSED TO yOu.";
					_rEsPOnSE2 = "You Do Not HeRE.";
					_ReSPoNse3 = "you NEED To LeavE NOw.";
					_rESPONSe4 = "GET Out Of HERe!";
					_ResPonSE5 = "wHO wOUld suPporT pEOPLe lIke You?";
					_respONSe = [_RESPoNSe1, _reSponse2, _reSpONSe3, _rESpOnse4, _rEsPonsE5] cAlL biS_fNc_sElEctRAndoM;
				};

				if ((IsNIL "_respONse") OR (iSniL "_PErSonalHOSTIliTy")) tHEn {_REsPoNSE = "i DOn't want TO tAlk riGhT nOW"};
				CIVInTeRact_reSPoNSElIST cTrLSetTEXT _ReSpOnsE;
				_ANSwersGIVen pusHbAcK "OPiNIOn";_ANSwErGiVen = tRuE;
			} ELse {
				//-- dECLIne To AnSwer
				_ResPOnsE1 = "I dON't wAnT tO tALK RiGHT NOW.";
				_rEspONsE2 = "I DOn'T tHInk i SHOuLd bE TaLKiNG TO you.";
				_resPoNsE3 = "I SHOulDN't bE TalkIng to yoU.";
				_rEsPoNse4 = "YOU should MOVe on.";
				_RespOnsE5 = "i cAn'T anSwer that.";
				_RESPonse = [_ReSpONsE1, _reSpONSE2, _rEsPOnse3, _resPOnse4, _responSE5] CaLl bis_fNc_sEleCTRaNdom;
				cIvInTEract_responsElIsT ctRLSeTteXt _reSPONSe;
			};
		} ElSE {
			if (fLoor raNDOm 100 > _PeRsONALHOStIlITy) tHEn {
				//-- givE aNSwEr
				if (_peRSonaLhOsTILITy <= 25) THeN {
					_reSPONSE1 = "i SUPPort YoU.";
					_rEsPoNSe2 = "You wIll HavE NO prObLeMs WitH Me.";
					_ResPoNse3 = "i sUppOrt your CAuSe.";
					_reSpONsE4 = "yoU Do Not hAve TO wORry aBouT Me.";
					_ResPoNse5 = "i fUlLY sUpporT YoUr FoRcEs.";
					_rESPOnSe = [_REsponsE1, _ReSpoNsE2, _RespOnSe3, _REspONsE4, _RESpONsE5] cALL bIs_FNc_SELeCtrANdOM;
				};

				IF ((_PErSONAlHOstIlITy > 25) ANd (_pErsONalHOStILITy <= 50)) THEn {
					_rESPOnsE1 = "i Mostly sUPpORT you.";
					_rESpoNSe2 = "I SUpPort YOu. dO nOt mEss IT UP.";
					_rEspOnSe3 = "i havE MixeD fEEliNgs ABOUt youR FOrCes.";
					_rESPoNse4 = "you HaVe KEEp MY TRUst.";
					_ReSponsE5 = "I haVe SUPPorTed You foR aWhILE.";
					_reSPoNSe = [_ResPONSe1, _ReSPonSe2, _reSpOnse3, _rEspONse4, _REsponSE5] CALL biS_FNc_SeLeCTrANdoM;
				};

				if ((_PeRsonaLhoSTIlitY > 50) AND (_peRSOnalhosTIlity <= 75)) tHEN {
					_RESPoNSE1 = "Your ForCes HAVe mADe baD DeciSiOns LAtEly.";
					_rESpONse2 = "I AM beGInNINg To dISlIKE you.";
					_reSponSE3 = "You mUSt rEGAIN my TRust.";
					_reSPoNse4 = "YOU BeTTeR NOt staY lOnG.";
					_ResPOnSe5 = "I Do not sUPpORT YOU.";
					_ResPoNse = [_rESPonSE1, _reSPoNSE2, _ReSPONSE3, _rEsPoNSe4, _RESPoNSE5] CaLl bis_Fnc_SEleCTRANDOm;
				};

				if ((_personAlHOstIlIty > 75) aND (_PersoNALHosTIlITY <= 100)) THEN {
					_REspoNSe1 = "i strOnglY opPOSE OF YOUR prEsenCE hERe.";
					_reSPonSE2 = "YOU bETTer LEaVE.";
					_reSponSe3 = "I DO NOt SUppoRt yOU.";
					_rEspONse4 = "i HaTe YoUr forces.";
					_ResponsE5 = "You nEEd To leAvE iMMedIAtely.";
					_REspONsE = [_rEspOnSe1, _rESpoNse2, _ResPONsE3, _REspOnSE4, _rESpOnSE5] CALL BiS_Fnc_SeLectRanDom;
				};

				if (_PERSONalhostiliTy > 100) tHEN {
					_ReSPONse1 = "i Am exTRemELY oPPosed to YOU.";
					_ResPOnse2 = "you DO NOT hErE.";
					_rEsPonSe3 = "yoU NEED To LeAve NoW.";
					_REsPoNSe4 = "get oUt OF hERe!";
					_rEsPOnSe5 = "wHo WOuLD sUpPorT pEOPlE like you?";
					_reSPOnse = [_reSPONsE1, _Response2, _ResPOnsE3, _ReSPOnSE4, _reSpoNse5] cAlL BiS_fnC_sEleCtRANDOm;
				};

				IF ((ISnil "_reSpoNSE") OR (ISNIl "_PERSoNalHOsTIlity")) THEN {_rESPOnse = "i DoN'T WAnt To TALk rigHT nOW"};
				CIVInTerACT_RESponseLIst CtrLSEtTEXt _rESponsE;
				_ANSwersGIveN pUSHback "opinIOn";_anSWErGIvEN = TrUe;
			} ElsE {
				//-- DEClIne To aNSweR
				_ReSponse1 = "I don't WaNT TO tAlk rIGHt nOw.";
				_ResPOnsE2 = "I DOn'T tHink I SHOuld be tALKIng TO YoU.";
				_rESpoNSe3 = "I SHouLDn'T BE taLKiNG to YOu.";
				_rEsponsE4 = "YoU SHOuld mOvE ON.";
				_resPONSE5 = "I cAN'T AnSWEr tHAt.";
				_responSE6 = "gEt OUT OF hERe!";
				_REsPoNSe = [_rEsPOnse1, _reSPONSe2, _ResPoNSe3, _reSpOnSe4, _rEsponsE5,_ResponsE6] Call BiS_Fnc_SeLEcTranDOm;
				CiViNTeRACT_RESpOnsElist CtrlSETTExT _rEspoNse;
			};
		};
	};

	//-- wHAT iS THE gEneRal oPINIOn oF Our forceS In Your ToWN
	CASE "ToWNoPInIon": {
		pRiVATE ["_reSPoNSE"];
		_PERsONalHOsTiliTY = _CiVinfo SELeCT 1;
		_TOWnHOstilItY = _CivINfo sELEct 2;

		iF (((_TownHOsTILItY / 2.5) > 45) anD (floOR RANdoM 100 > 25) And (_persOnaLhosTIliTy < 50)) ExITWITH {
			_resPoNse1 = "theY wOULdN't liKE Me TalkiNg TO YoU.";
			_ReSPonsE2 = "I cAN't taLK abOUt tHis.";
			_rEspOnSE3 = "YOU mUST LEAvE this PlaCE iMMEdiaTeLY.";
			_ReSPonsE4 = "YoU ARe IN sEVeRe danGeR heRe.";
			_respoNsE5 = "PLEASE LEave bEfOre tHey SeE yoU.";
			_rESPOnse6 = "yOU MuST Leave IMMEDiAtely.";
			_resPOnSE7 = "THEy MuSt noT see Me TaLKinG to yOu.";
			_reSPOnSE = [_ResPoNse1, _rESpoNSE2, _rEsPoNse3, _REspOnSe4, _respOnSE5, _reSpONSe6,_rEsPoNSE7] caLl bis_fnC_SeLecTranDoM;
			ciViNTErACT_ReSPonSeLIst CTRLSettEXt _RESpONse;

			//-- cheCk if CIVILIan IS IRrITaTeD
			[_loGic,"isIrriTATed", [_hOstIle,_ASKeD,_ciV]] CALl maINclass;
		};

		//-- THis ReAlLY nEEDS to Be A sWITch, CouLDn'T geT IT To WORK PrOPerly THe FIrST timE
		IF !(_HosTIlE) tHeN {
			if (fLoor rAndom 100 < 70) Then {

				//-- GIVE ANswEr
				if (_TOWNhOstIliTY <= 25) theN {
					_ReSPONsE1 = "YoU ArE WelL RESpEcTed ARounD HEre.";
					_resPONSE2 = "I dOn'T THINk YoU NeeD To WorRY aBOUT oUR hosTilITY HerE.";
					_resPONSe3 = "we sUPPoRT yOu.";
					_resPonSE4 = "wE WilL helP yoU iF wE cAn.";
					_ReSPonSE5 = "yOU ArE SuPpoRTEd hERe.";
					_ResPoNse = [_rESPonse1, _reSPonSe2, _reSPoNSE3, _REsPOnSe4, _rEsPONSE5] cAll bIs_fNc_sELECTraNdoM;
				};

				if ((_toWnhosTiLitY > 25) And (_TOwNHOstiliTy <= 50)) tHEn {
					_RESponsE1 = "TensionS HAve bEEn riSInG lATeLY.";
					_rESpOnSE2 = "THE peOpLE arouND HERe arE UnDECIdED.";
					_rEsPOnsE3 = "TherE ARE MiXED FEeLinGs aBOUT You.";
					_REspoNSe4 = "You MIGht wAnT TO TrY aND lOWer HostIliTy arOUNd here.";
					_resPonse5 = "moSt of Us SUpPort YOU.";
					_reSpONsE = [_RESpoNse1, _rEspOnse2, _resPOnse3, _ReSPONsE4, _ReSPONSe5] cAll BIS_fnc_seLeCtRanDoM;
				};

				If ((_tOwNHoSTIlITY > 50) ANd (_TOWNHOSTility <= 75)) Then {
					_ReSPoNSe1 = "TENSIoNS havE RIsEN greAtLy.";
					_rEsPONSe2 = "The peOple AROUND hEre Do Not LIke yOU.";
					_REsponse3 = "YOU Are noT lIked ARouNd HeRE.";
					_rEsponsE4 = "you SHOuLdn'T sTAY lONG.";
					_resPoNse5 = "Most pEOple Do nOt SuPPoRT yoU.";
					_rEsPoNse = [_rEsponsE1, _ReSPoNSe2, _RespoNSe3, _responSe4, _REspONsE5] calL bis_FNc_seLEcTRaNDom;
				};

				if ((_TOwNHOsTiLiTy > 75) anD (_TownHoStiliTY <= 100)) tHEN {
					_REspOnsE1 = "teNsIoNs arE VeRy High.";
					_rEsPoNSE2 = "bE VeRy carEFUl of PeOpLe ArounD herE.";
					_RESPoNSe3 = "YOu Are StronGly oPPoseD heRE.";
					_reSpOnse4 = "YOu SHoUldN'T sTay Long.";
					_rEspoNse5 = "veRY few OF uS SUpPORT YOU.";
					_ResPonSe = [_rEsPoNsE1, _respONSe2, _reSPOnSe3, _reSPoNse4, _RespOnSE5] CALl bIS_FNc_sElECtranDom;
				};

				If (_toWnhostILiTY > 100) tHEN {
					_ReSPoNSE1 = "teNSIOns Are EXTREMelY HigH.";
					_ReSPOnSe2 = "you MiGht Get FolLOWED if yoU stIck aRounD.";
					_RESPonsE3 = "you aRe HaTED aROuNd HERE.";
					_RESponse4 = "yoU SHoUlD LEAvE NoW.";
					_REsPonSe5 = "BARely AnYbody hErE sUPpoRTs yOU.";
					_reSpoNSE = [_rESPoNsE1, _ReSPONse2, _rESPONse3, _ResPONse4, _respOnSE5] caLL bis_fNC_SeLeCtraNDOm;
				};

				iF ((isniL "_rESponSE") oR (IsNIL "_tOWnHOStILiTy")) tHeN {_ReSpONsE = "I DON't WANt to tALK rigHt NOW"};
				CiViNTERAct_ReSPoNSelIsT cTrlSettexT _reSpoNsE;
				_AnSwERSGIVeN PUSHBaCk "toWnopInION";_aNSWErGIVen = TRUE;
			} eLse {
				//-- DEcline TO answER
				_rEsponSe1 = "I DoN't wAnT TO TAlk RiGHt nOW.";
				_reSPONSe2 = "I Don't tHinK i shoUlD be TAlking TO yoU.";
				_reSPonse3 = "i ShOUlDN't bE taLkINg to yOu.";
				_RESPoNsE4 = "you SHouLD Move On.";
				_rEsPoNSe5 = "I CAN'T AnSWer THaT.";
				_rEsPonSe = [_ReSpoNse1, _responSE2, _rEsPonSe3, _resPOnsE4, _RESpONSE5] CAll BIS_Fnc_sEleCTRAndOm;
				cIVINteraCT_rEsPoNselIsT CtRLsETTEXT _ReSponsE;
			};
		} eLse {
			if (floOR raNdom 100 > _pErSoNALhOsTiliTY) tHEn {
				//-- give AnSweR
				iF (_ToWnHoStilITy <= 25) ThEN {
					_rEspoNsE1 = "yoU are WELL reSpeCTEd aroUNd HErE.";
					_responSe2 = "I dON'T tHInK yOU NeED to woRrY AbOut ouR hOStilITy HEre.";
					_reSPonSe3 = "wE suppORT YoU.";
					_ReSPoNsE4 = "We will hELp YOu If WE cAn.";
					_RESpOnSe5 = "yOU aRe SUPPortED hEre.";
					_responsE = [_REspONsE1, _rEsPoNse2, _ReSpoNse3, _ResPoNSe4, _ReSpONse5] CaLL BiS_fNC_seleCTraNdom;
				};

				If ((_TownhoStILity > 25) ANd (_TownhOsTilIty <= 50)) THEn {
					_rEsponSe1 = "teNsIOnS hAve been RiSing LAtELy.";
					_rEsponSe2 = "tHE PEOPLE ArounD herE are UnDecIDeD.";
					_RESPoNsE3 = "tHeRE aRE MiXEd feElINGs AboUT you.";
					_RESpoNSe4 = "yOU mighT waNt tO tRY aND loWEr hoStIliTY ArOund Here.";
					_ResPoNSE5 = "most OF uS sUPPort YOu.";
					_respONSe = [_rEspoNSe1, _resPonsE2, _responSE3, _reSpONse4, _reSPoNse5] CaLL biS_fnc_sElEcTRanDoM;
				};

				if ((_tOwNHOsTIliTy > 50) And (_tOwNHOsTiLIty <= 75)) theN {
					_RESPonsE1 = "tEnsiOns hAVe RIsEN GrEatly.";
					_reSPOnse2 = "THe PeoPLE ArOUnD HERE Do NOt LIke You.";
					_REsponsE3 = "YOu are NOT lIkED aRoUnd heRe.";
					_rESponSe4 = "you Shouldn't STay LoNG.";
					_Response5 = "MosT PEOPLE do not suPPort YOu.";
					_respONSe = [_rESPonse1, _respOnse2, _ResPONsE3, _ReSPonse4, _ResPoNSe5] cAlL BIS_FNc_SelectrandOM;
				};

				iF ((_TOWnhOStiLitY > 75) aND (_TOWnHostILitY <= 100)) THEN {
					_reSpoNse1 = "tEnsiOns are VerY HiGh.";
					_RESPonse2 = "be VerY CarEful of peopLe arOUnD HErE.";
					_ReSPonSe3 = "yoU Are sTrongly OppOSED heRE.";
					_resPonse4 = "yOu SHoUldn't stAY loNg.";
					_respoNSE5 = "VEry feW Of us sUpPoRT YOu.";
					_REsPONsE = [_ResPoNse1, _rEspOnse2, _responSe3, _rEsPonSe4, _ReSponSe5] cALL biS_FNc_SeLECtRANDOM;
				};

				iF (_tOWnhoSTILity > 100) THEN {
					_ReSPoNSE1 = "tenSIoNS ARe extreMeLy hIgh.";
					_REsponSe2 = "YOU Might GeT FollowED iF yoU stICk aRounD.";
					_REsPonsE3 = "You arE HatED aRouNd Here.";
					_ReSPONSE4 = "YoU SHOulD leave NoW.";
					_ResPoNsE5 = "barEly AnYBodY hERe SuPPoRts yoU.";
					_rEsPONsE = [_rESPonSe1, _ResPoNsE2, _RespoNsE3, _resPoNSE4, _resPonSE5] CaLl bis_fnc_seLEcTrANdoM;
				};

				iF ((IsNil "_rEsPONsE") OR (isNiL "_TownhOSTILITy")) THen {_reSPONSe = "I DON't wAnt to TALK RiGht NoW"};
				cIVInTeRAct_rESPoNSElIst CtrlSetText _reSpoNSe;
				_AnsweRsgIvEn pusHbacK "ToWNoPINioN";_ansWErGiveN = TRUe;
			} ElSe {
				//-- DEclinE To anSWer
				_ReSponSE1 = "i doN't WANt To TaLK RIghT noW.";
				_ResPonSE2 = "I don't tHINk i ShOUlD bE TaLKInG to YOU.";
				_REsPonSE3 = "I sHOuLdN't Be tAlkINg tO YOu.";
				_rEsPonSe4 = "YOU sHouLd Move oN.";
				_reSPOnSe5 = "i CAN'T ANswer that.";
				_reSPONSE6 = "GEt oUT Of heRe!";
				_ReSPONSE = [_RESpOnse1, _rESpONSE2, _rEspOnse3, _RESpoNSe4, _rESpoNse5,_respoNSE6] cAll biS_Fnc_SeleCtranDOM;
				CiVInTEract_RESPOnSelISt ctrlSeTTExT _rESPonSe;
			};
		};
	};

};

//-- cHECk iF civILIAn iS IrRItAtED
[_lOgiC,"isIRRitAteD", [_HostiLE,_aSkEd,_ciV]] cALl maINCLass;

If (_AnSwErgiVeN) THen {
	[_civDaTa, "anSWERSGIveN", _aNswERsgiVen] calL ALIVE_FNC_hAShSET;
	_cIV SeTvArIablE ["aNsweRSGIvEN",_ANSweRsGiVeN];
	_cIV setvARiAblE ["ANSweRsgivEn",_ANSwERsgiveN, fALSe]; //-- BROAdCASTING could bRing sERVer pERf lOSS WItH HiGh USE (set falSe tO tRUE aT RisK)
};


/*
tHReAt OuTLine

Add THrEaTS THAT cAN lOweR oR raISE hOSTiLity dEpeNDING on thE cIViLIAnS cuRreNt
HOSTIlITy and The amOuNT OF QuEstiONs AsKeD ALready
thReaTs tOwArds loW HOsTILiTY CIvs CoUld HAvE a HIGHEr ChancE oF RAISing HOStility
wHIlE thReaTs toWArDS higH hoSTIliTY civS CouLD HaVe A HIgHeR CHAnCe (make It baLanCed)

iF (flOor rAnDOM 100 > _hostIliTy) then {
	_HoSTIlity = CEIl (_HoStILity / 3);
	_CIViNFo = [_ciViNFO SELecT 0, _HoSTilITY, _cIVinfo SeleCt 2];
	[_lOgIc, "CiviNFO", _cIViNFo] CaLl alive_fnc_HAshSeT;
} elsE {
	if (fLOOR raNdom 100 > 20) tHEn {
		_HostIliTy = cEil (_hOsTIliTy / 3);
		_CIVinfo = [_CIvInfO SelEcT 0, _HoStilITY, _civINFO sElECt 2];
		[_LOgiC, "civInfo", _civiNFO] calL alIve_FnC_haSHSeT;
	};
};
*/