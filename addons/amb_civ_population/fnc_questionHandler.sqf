/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_questionHandler

Description:
Main handler for questions

Parameters:
String - Question

Returns:
none

Examples:
(begin example)
["Home"] call ALiVE_fnc_questionHandler; //-- Ask where they live
["Insurgents"] call ALiVE_fnc_questionHandler; //-- Ask if they've seen any insurgents
["StrangeBehavior"] call ALiVE_fnc_questionHandler; //-- Ask if they've seen any strange behavior
(end)

Notes:
Civilians will stay stay hostile after becoming hostile (persistent through menu closing)
Civilians may become annoyed when you keep asking questions, which will raise their hostility
Some responses are shared by the hostile and non-hostile sections, this is done to keep a gray line between hostile and non-hostile

See Also:
- nil

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_civData","_civInfo","_hostile","_hostility","_asked","_civ","_answerGiven"];
params [
	["_logic", objNull],
	["_question", ""]
];

//-- Define control ID's
#define MAINCLASS ALiVE_fnc_civInteract
#define CIVINTERACT_RESPONSELIST (findDisplay 923 displayCtrl 9239)

//-- Get civ hostility
_hostile =  false;
_civData = [_logic, "CivData"] call ALiVE_fnc_hashGet;
_civInfo = [_civData, "CivInfo"] call ALiVE_fnc_hashGet;
_civ = [_logic, "Civ"] call ALiVE_fnc_hashGet;
_civName = name _civ;

//-- Set questions asked
_asked = ([_civData, "Asked"] call ALiVE_fnc_hashGet) + 1;
[_civData, "Asked", _asked] call ALiVE_fnc_hashSet;

if (!isNil {[_civData, "Hostile"] call ALiVE_fnC_hashGet}) then {
	_hostile = true;
} else {
	_hostility = _civInfo select 1;
	if (random 100 < _hostility) then {
		_hostile = true;
		[_civData, "Hostile", true] call ALiVE_fnc_hashSet;
	};
};

//-- Hash new data to logic
[_logic, "CivData", _civData] call ALiVE_fnc_hashSet;

//-- Get previous responses
_answersGiven = [_civData, "AnswersGiven"] call ALiVE_fnc_hashGet;

//-- Clear previous responses
CIVINTERACT_RESPONSELIST ctrlSetText "";

//-- Check if question has already been answered
if ((_question in _answersGiven) and (floor random 100 < 75)) exitWith {
	_response1 = "I'm not telling you again.";
	_response2 = "Haven't we already discussed this?";
	_response3 = "I have already answered that.";
	_response4 = "Why are you asking me again.";
	_response5 = "You already asked me that.";
	_response6 = "You are beginning to annoy me with that question.";
	_response7 = "I cannot talk about this anymore.";
	_response8 = "You have gotten your answers already.";
	_response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8] call BIS_fnc_selectRandom;
	CIVINTERACT_RESPONSELIST ctrlSetText _response;

	//-- Check if civilian is irritated
	[_logic,"isIrritated", [_hostile,_asked,_civ]] call MAINCLASS;
};

switch (_question) do {

	//-- Where is your home located
	case "Home": {
		_homePos = _civInfo select 0;

		if (!(_hostile) and (floor random 100 > 15)) then {
			_response1 = format ["I live over there, I'll show you (%1's house has been marked on the map).", _civName];
			_response2 = format ["I live nearby (%1's house has been marked on the map).", _civName];
			_response3 = format ["I will point it out for you (%1's house has been marked on the map).", _civName];
			_response4 = format ["I live right over there (%1's house has been marked on the map).", _civName];
			_response5 = format ["Just over there. (The house is marked on the map).", _civName];
			_response = [_response1,_response2,_response3,_response4,_response5] call BIS_fnc_selectRandom;
			CIVINTERACT_RESPONSELIST ctrlSetText _response;

			//-- Create marker on home
			_answersGiven pushBack "Home";_answerGiven = true;
			_markerName = format ["%1's home", _civName];
			_marker = [str _homePos, _homePos, "ICON", [.35, .35], "ColorCIV", _markerName, "mil_circle", "Solid", 0, .5] call ALIVE_fnc_createMarkerGlobal;
			_marker spawn {sleep 30;deleteMarker _this};
		} else {
			_response1 = "I am sorry, but I don't feel comfortable giving that information out.";
			_response2 = "I do not want to share that with you.";
			_response3 = "I do not owe you anything.";
			_response4 = "Please leave me alone.";
			_response5 = "Please leave.";
			_response6 = "Get out of here!";
			_response = [_response1,_response2,_response3,_response4,_response5,_response6] call BIS_fnc_selectRandom;
			CIVINTERACT_RESPONSELIST ctrlSetText _response;
		};
	};

	//-- What town do you live in
	case "Town": {
		_homePos = _civInfo select 0;
		_town = [_homePos] call ALIVE_fnc_taskGetNearestLocationName;

		if !(_hostile) then {
			if (floor random 100 > 15) then {
				_response1 = format ["I live by %1.", _town];
				_response2 = format ["I live in %1.", _town];
				_response3 = format ["I live in the village of %1.", _town];
				_response4 = format ["My home town is %1.", _town];
				_response5 = "You should not be here.";
				_response6 = "They would not like me talking to you.";
				_response = [_response1, _response2, _response3, _response4, _response5, _response6] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
				_answersGiven pushBack "Town";_answerGiven = true;
			} else {
				_response1 = "I am sorry, but I do not feel comfortable giving that information out.";
				_response2 = "Sorry, I do not want to answer that.";
				_response3 = "I should not share that with you.";
				_response4 = "I just want to be left alone.";
				_response5 = "Please leave my community alone.";
				_response = [_response1,_response2,_response3,_response4,_response5] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
			};
		} else {
			_response1 = "I am sorry, but I do not feel comfortable giving that information out.";
			_response2 = "I should not share that with you.";
			_response3 = "I do not owe you anything.";
			_response4 = "You should not be here.";
			_response5 = "Please leave me alone.";
			_response6 = "I will not tell you where I live!";
			_response7 = "You will not terrorize my town!";
			_response = [_response1, _response2, _response3, _response4, _response5, _response6, _response7] call BIS_fnc_selectRandom;
			CIVINTERACT_RESPONSELIST ctrlSetText _response;
		};
	};

	//-- Have you seen any IED's nearby
	case "IEDs": {

		_IEDs = [];
		{
			if (_x distance2D (getPos _civ) < 1000) then {_IEDs pushBack _x};
		} forEach allMines;

		if (count _IEDs == 0) then {
			if !(_hostile) then {
				if (floor random 100 > 25) then {
					_response1 = "There are no IEDs nearby.";
					_response2 = "Sorry, I haven't seen any.";
					_response3 = "Not that I know of, sorry.";
					_response4 = "No IEDs have been set near here.";
					_response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "IEDs";_answerGiven = true;
				} else {
					_response1 = "Sorry, I do not know.";
					_response2 = "I cannot give that type of information out.";
					_response3 = "I would be killed if I told you.";
					_response4 = "Please leave, they can't see me talking to you.";
					_response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
				};
			} else {
				_response1 = "Like I would tell you.";
				_response2 = "Just leave me alone already.";
				_response3 = "You will have to find that out for yourself.";
				_response4 = "Watch your step.";
				_response5 = "Maybe I should have planted a few.";
				_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
			};

		} else {
			_iedLocation = getPos (_IEDs call BIS_fnc_selectRandom);

			if !(_hostile) then {
				if (floor random 100 > 25) then {
					_response1 = "Yes I saw one earlier (Location marked on map).";
					_response2 = "Let me show you one (Location marked on map).";
					_response3 = "I think I know a spot (Location marked on map).";
					_response4 = "I saw an insurgent plant one (Location marked on map).";
					_response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "IEDs";_answerGiven = true;

					//-- Create marker on IED
					_iedPos = getPos (_IEDs call BIS_fnc_selectRandom);
					_iedPos = [_iedPos, (25 + ceil random 15)] call CBA_fnc_randPos;
					_marker = [str _iedPos, _iedPos, "ELLIPSE", [40, 40], "ColorRed", "IED", "n_installation", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
					_text = [str (str _iedPos),_iedPos,"ICON", [0.1,0.1],"ColorRed","IED", "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;
					[_marker,_text] spawn {sleep 30;deleteMarker (_this select 0);deleteMarker (_this select 1)};
				} else {
					_response1 = "Sorry, I do not know.";
					_response2 = "I cannot give that type of information out.";
					_response3 = "I would be killed if I told you.";
					_response4 = "Please leave, they can't see me talking to you.";
					_response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
				};
			} else {
				_response1 = "Like I would tell you.";
				_response2 = "Just leave me alone already.";
				_response3 = "You will have to find that our for yourself.";
				_response4 = "Watch your step.";
				_response5 = "Maybe I should have planted a few.";
				_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
			};

		};
	};

	//-- Have you seen any insurgent activity lately
	case "Insurgents": {

		_insurgentFaction = [_logic, "InsurgentFaction"] call ALiVE_fnc_hashGet;
		_pos = getPos _civ;
		_town = [_pos] call ALIVE_fnc_taskGetNearestLocationName;

		//-- Get nearby insurgents
		_insurgents = [];
		{
			_leader = leader _x;

			if ((faction _leader == _insurgentFaction) and {_leader distance2D _pos < 1100}) then {
				_insurgents pushBack _leader;
			};
		} forEach allGroups;

		if (count _insurgents == 0) then {
			//-- Insurgents are not nearby
			if !(_hostile) then {
				if (floor random 100 > 40) then {
					_response1 = "Sorry I have not seen any.";
					_response2 = "No, there are none nearby.";
					_response3 = "Not recently, sorry.";
					_response4 = "Thankfully no.";
					_response5 = "I haven't seen any.";
					_response = [_response1, _response2, _response3, _response4,_response5] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "Insurgents";_answerGiven = true;
				} else {
					_response1 = "Please, just leave me alone.";
					_response2 = "I don't want to talk about this.";
					_response3 = "I don't want to talk to you.";
					_response4 = "I can't tell you.";
					_response5 = "They wouldn't like me talking to you.";
					_response = [_response1, _response2, _response3, _response4,_response5] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
				};
			} else {
				_response1 = "As if I would tell you.";
				_response2 = "Get away from me.";
				_response3 = "Please, just leave me alone.";
				_response4 = "I don't want to talk about this.";
				_response5 = "I don't want to talk to you.";
				_response = [_response1, _response2, _response3, _response4,_response5] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
			};
		} else {
			//-- Insurgents are nearby
			if !(_hostile) then {
				//-- Random chance to reveal insurgents
				if (floor random 100 > 50) then {
					//-- Reveal location
					_response1 = format ["Some insurgents are near %1.", _town];
					_response2 = "Don't snitch on me (Insurgents marked on map).";
					_response3 = "Yes, let me show you where I saw them (Insurgents marked on map).";
					_response4 = "Yes, but you must keep this secret (Insurgents marked on map).";
					_response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "Insurgents";_answerGiven = true;

					//-- Create marker on insurgent group
					_insurgentLeaders = [_insurgents,[getPos player],{_Input0 distance2D getPos _x},"ASCEND"] call BIS_fnc_sortBy;
					_insurgentPos = getPos (_insurgentLeaders select 0);
					_insurgentPos = [_insurgentPos, (75 + ceil random 25)] call CBA_fnc_randPos;
					_marker = [str _insurgentPos, _insurgentPos, "ELLIPSE", [100, 100], "ColorEAST", "Insurgents", "n_installation", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
					_text = [str (str _insurgentPos),_insurgentPos,"ICON", [0.1,0.1],"ColorRed","Insurgents", "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;
					[_marker,_text] spawn {sleep 30;deleteMarker (_this select 0);deleteMarker (_this select 1)};
				} else {
					//-- Don't reveal location
					_response1 = "They wouldn't want me talking to you.";
					_response2 = "You can't ask questions like that.";
					_response3 = "Are you crazy?";
					_response4 = "Please, just leave me alone.";
					_response5 = "I don't want to talk about this.";
					_response6 = "I don't want to talk to you.";
					_response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
				};
			} else {
				_response1 = "As if I would tell you.";
				_response2 = "Get away from me.";
				_response3 = "Please, just leave me alone.";
				_response4 = "I don't want to talk about this.";
				_response5 = "I don't want to talk to you.";
				_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
			};
		};

	};

	//-- Do you know the location of any insurgent hideouts
	case "Hideouts": {
		_installations = [_civData, "Installations"] call ALiVE_fnc_hashGet;
		_actions = [_civData, "Actions"] call ALiVE_fnc_hashGet;
		_installations params ["_factory","_HQ","_depot","_roadblocks"];
		_actions params ["_ambush","_sabotage","_ied","_suicide"];

		if ((_factory isEqualTo []) and (_HQ isEqualTo []) and (_depot isEqualTo []) and (_roadblocks isEqualTo [])) then {

			if !(_hostile) then {
				if (floor random 100 > 30) then {
					_response1 = "Insurgents have not established any installations here.";
					_response2 = "Luckily, no.";
					_response3 = "No, I have not.";
					_response4 = "There are no insurgent bases here.";
					_response5 = "There are no insurgent hideouts here.";
					_response6 = "Insurgents have not taken over this area yet.";
					_response7 = "There are no hideouts here.";
					_response8 = "There are no installations here.";
					_response9 = "We are still free from their reign.";
					_response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8,_response9] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "Hideouts";_answerGiven = true;
				} else {
					_response1 = "Are you crazy.";
					_response2 = "I cannot talk about this.";
					_response3 = "Do you want to get me killed?";
					_response4 = "I will not put myself in danger.";
					_response5 = "I will not put myself at risk.";
					_response = [_response1,_response2,_response3,_response4,_response5] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
				};
			} else {
				_response1 = "I don't have time for this.";
				_response2 = "I cannot talk about this right now.";
				_response3 = "Are you crazy.";
				_response4 = "Why would you ask me such question.";
				_response5 = "That is a crazy question to ask.";
				_response6 = "Do you want to get me killed?";
				_response7 = "I will not put myself in danger.";
				_response8 = "Why would you ask that?";
				_response9 = "I cannot help you with that.";
				_response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8,_response9] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
			};
		} else {

			private ["_installation","_type","_typeName","_installationData"];
			for "_i" from 0 to 3 do {
				_installationArray = _installations call BIS_fnc_selectRandom;

				if (!(_installationArray isEqualTo []) and (isNil "_installation")) then {
					_index = _installations find _installationArray;
					switch (str _index) do {
						case "0": {_typeName = "IED Factory";_type = "IED factory"};
						case "1": {_typeName = "Recruitment HQ";_type = "recruitment HQ"};
						case "2": {_typeName = "Munitions Depot";_type = "munitions depot"};
						case "3": {_typeName = "Roadblocks";_type = "roadblocks"};
					};
					_installation = _installationArray;
				};
			};

			if ((isNil "_type") or (isNil "_installation")) exitWith {

				_response1 = "I can't talk about that.";
				_response2 = "They would kill me.";
				_response3 = "Are you crazy.";
				_response4 = "Do you want to get me killed.";
				_response5 = "I cannot put my family at risk by answering that.";
				_response = [_response1,_response2,_response3,_response4,_response5] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
				_answersGiven pushBack "Hideouts";_answerGiven = true;
			};

			if !(_hostile) then {
				if (floor random 100 > 60) then {
					if (floor random 100 > 60) then {
						_response1 = format ["I noticed a %1 nearby (%2 marked on map).", _type,_typeName];
						_response2 = format ["Someone told me there was a %1 close by (%2 marked on map).", _type,_typeName];
						_response3 = format ["I observed insurgents setting up a %1 (%2 marked on map).", _type,_typeName];
						_response4 = format ["I know the location of a %1 (%2 marked on map).", _type,_typeName];
						_response5 = format ["Insurgents established a %1 (%2 marked on map).", _type,_typeName];
						_response6 = format ["I can show you the location of a %1 (%2 marked on map).", _type,_typeName];
						_response7 = format ["You must keep this a secret (%2 marked on map).", _type,_typeName];
						_response8 = format ["You must promise to protect me (%2 marked on map).", _type,_typeName];
						_response9 = format ["Please remove the %1 from the area and restore peace (%2 marked on map).", _type,_typeName];
						_response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8,_response9] call BIS_fnc_selectRandom;
						CIVINTERACT_RESPONSELIST ctrlSetText _response;
						_answersGiven pushBack "Hideouts";_answerGiven = true;

						if (floor random 100 > 30) then {
							//-- Create marker on general installation location
							_installationPos = getPos _installation;
							_installationPos = [_installationPos, (75 + ceil random 25)] call CBA_fnc_randPos;
							_marker = [str _installationPos, _installationPos, "ELLIPSE", [100,100], "ColorEAST", _typeName, "n_installation", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
							_text = [str (str _installationPos),_installationPos,"ICON", [0.1,0.1],"ColorRed",_typeName, "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;
							[_marker,_text] spawn {sleep 30;deleteMarker (_this select 0);deleteMarker (_this select 1)};
						} else {
							//-- Create marker on installation location
							_installationPos = getPos _installation;
							_marker = [str _installationPos, _installationPos, "ICON", [1,1], "ColorRed", _type, "n_installation", "Solid", 0, .5] call ALIVE_fnc_createMarkerGlobal;
							_marker spawn {sleep 30;deleteMarker _this};
						};
					} else {
						_response1 = format ["I noticed a %1 nearby.", _type];
						_response2 = format ["Someone told me there was a %1 close by.", _type];
						_response3 = format ["I observed insurgents setting up a %1.", _type];
						_response4 = format ["Insurgents have prepared a %1 nearby.", _type];
						_response5 = format ["Insurgents established a %1 close by here.", _type];
						_response6 = format ["Others have mentioned a %1 close by.", _type];
						_response7 = format ["Insurgents have setup a %1 nearby.", _type];
						_response8 = format ["Restore peace to this area, there is a %1 around here.", _type];
						_response9 = format ["I do not know where it is, but insurgents are operating a %1 somewhere around here.", _type];
						_response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8,_response9] call BIS_fnc_selectRandom;
						CIVINTERACT_RESPONSELIST ctrlSetText _response;
						_answersGiven pushBack "Hideouts";_answerGiven = true;
					};
				} else {
					_response1 = "I can't talk about that.";
					_response2 = "They would kill me.";
					_response3 = "Are you crazy.";
					_response4 = "Do you want to get me killed.";
					_response5 = "I cannot put my family at risk by answering that.";
					_response = [_response1,_response2,_response3,_response4,_response5] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "Hideouts";_answerGiven = true;
				};
			} else {
				if (floor random 100 > _hostility) then {
					_response1 = format ["I noticed a %1 nearby.", _type];
					_response2 = format ["Someone told me there was a %1 close by.", _type];
					_response3 = format ["I observed insurgents setting up a %1.", _type];
					_response4 = format ["Insurgents have prepared a %1 nearby.", _type];
					_response5 = format ["Insurgents established a %1 close by here.", _type];
					_response6 = format ["Others have mentioned a %1 close by.", _type];
					_response7 = format ["Insurgents have setup a %1 nearby.", _type];
					_response8 = format ["Restore peace to this area, there is a %1 around here.", _type];
					_response9 = format ["I do not know where it is, but insurgents are operating a %1 somewhere around here.", _type];
					_response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8,_response9] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "Hideouts";_answerGiven = true;
				} else {
					_response1 = "I can't talk about that.";
					_response2 = "They would kill me.";
					_response3 = "Are you crazy.";
					_response4 = "Do you want to get me killed.";
					_response5 = "I cannot put my family at risk by answering that.";
					_response6 = "Get out of here!";
					_response7 = "Get away from me";
					_response8 = "You disgust me!";
					_response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "Hideouts";_answerGiven = true;
				};
			};
		};
	};

	//-- Have you noticed any strange behavior lately
	case "StrangeBehavior": {
		_hostileCivInfo = [_civData, "HostileCivInfo"] call ALiVE_fnc_hashGet;	//-- [_civ,_homePos,_activeCommands]
		//-- Check if data exists
		if (count _hostileCivInfo == 0) then {
			if !(_hostile) then {
				if (floor random 100 > 70) then {
					_response1 = "I have not seen anything.";
					_response2 = "Sorry, I haven't.";
					_response3 = "No, I have not.";
					_response4 = "There has been no suspicious behavior lately.";
					_response5 = "Everything is peaceful here.";
					_response6 = "We are a peaceful community.";
					_response = [_response1, _response2, _response3, _response4, _response5, _response6] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "StrangeBehavior";_answerGiven = true;
				} else {
					_response1 = "I will not put myself at risk.";
					_response2 = "They would kill me if I told you.";
					_response3 = "I cannot talk about that.";
					_response4 = "There has been no suspicious behavior lately.";
					_response5 = "They wouldn't want me talking to you.";
					_response6 = "I shouldn't be talking about this.";
					_response = [_response1, _response2, _response3, _response4, _response5,_response6] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
				};
			} else {
				_response1 = "I cannot talk about that";
				_response2 = "They wouldn't want me talking to you";
				_response3 = "I cannot help you";
				_response4 = "No, I have not";
				_response5 = "I have not seen anything lately";
				_response6 = "There is no danger here";
				_response7 = "I don't have time for this";
				_response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
				_answersGiven pushBack "StrangeBehavior";_answerGiven = true;
			};
		} else {
			_hostileCivInfo params ["_hostileCiv","_homePos","_activeCommands"];
			_activeCommand = _activeCommands call BIS_fnc_selectRandom;
			_activeCommand = _activeCommand select 0;
			_activePlan = [_logic,"getActivePlan",_activeCommand] call MAINCLASS;

			if (isNil "_activePlan") exitWith {CIVINTERACT_RESPONSELIST ctrlSetText "I can't talk about this right now."};

			if (!(_hostile) and (floor random 100 > 70)) then {
				_response1 = format ["I heard %1 was %2.", name _hostileCiv, _activePlan];
				_response2 = format ["Someone told me that %1 was %2.", name _hostileCiv, _activePlan];
				_response3 = format ["I saw that %1 was %2.", name _hostileCiv, _activePlan];
				_response4 = format ["I think %1 was %2.", name _hostileCiv, _activePlan];
				_response5 = format ["I was informed that %1 was %2.", name _hostileCiv, _activePlan];
				_response6 = format ["I was told %1 was %2.", name _hostileCiv, _activePlan];
				_response = [_response1, _response2, _response3, _response4, _response5, _response6] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
				_answersGiven pushBack "StrangeBehavior";_answerGiven = true;

				if (floor random 100 <= 35) then {
					switch (str floor random 2) do {
						case "0": {
							_response1 = " I overheard where he was (Position marked on map).";
							_response2 = " Someone told me where he was (Position marked on map).";
							_response3 = " I saw him earlier (Position marked on map).";
							_response4 = " I I think I know where you can find him (Position marked on map).";
							_response = [_response1, _response2, _response3,_response4] call BIS_fnc_selectRandom;
							CIVINTERACT_RESPONSELIST ctrlSetText ((ctrlText CIVINTERACT_RESPONSELIST) + _response);

							//-- Create marker on hostile civ location
							_civPos = [getPos _hostileCiv, (10 + ceil random 8)] call CBA_fnc_randPos;
							_markerName = format ["%1's location", name _hostileCiv];
							_marker = [str _civPos, _civPos, "ELLIPSE", [40, 40], "ColorRed", _markerName, "n_installation", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
							_text = [str (str _civPos),_civPos,"ICON", [0.1,0.1],"ColorRed",_markerName, "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;
							[_marker,_text] spawn {sleep 30;deleteMarker (_this select 0);deleteMarker (_this select 1)};
						};
						case "1": {
							_response1 = " I'll show you where he lives (Home marked on map).";
							_response2 = " I know where he lives (Home marked on map).";
							_response3 = " Someone told me where he lives (Home marked on map).";
							_response4 = " I will show you where you can find him (Home marked on map).";
							_response = [_response1, _response2, _response3,_response4] call BIS_fnc_selectRandom;
							CIVINTERACT_RESPONSELIST ctrlSetText ((ctrlText CIVINTERACT_RESPONSELIST) + _response);

							//-- Create marker on hostile civ location
							_markerName = format ["%1's home", name _hostileCiv];
							_marker = [str _homePos, _homePos, "ICON", [.35, .35], "ColorRed", _markerName, "mil_circle", "Solid", 0, .5] call ALIVE_fnc_createMarkerGlobal;
							_marker spawn {sleep 30;deleteMarker _this};
						};
					};
				};
			} else {
				if (floor random 100 > _hostility) then {
					_response1 = format ["I heard %1 was %2.", name _hostileCiv, _activePlan];
					_response2 = format ["Someone told me that %1 was %2.", name _hostileCiv, _activePlan];
					_response3 = format ["I saw that %1 was %2.", name _hostileCiv, _activePlan];
					_response4 = format ["I think %1 was %2.", name _hostileCiv, _activePlan];
					_response5 = format ["I was informed that %1 was %2.", name _hostileCiv, _activePlan];
					_response6 = format ["I was told %1 was %2.", name _hostileCiv, _activePlan];
					_response = [_response1, _response2, _response3, _response4, _response5, _response6] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "StrangeBehavior";_answerGiven = true;
				} else {
					_response1 = "I cannot talk about that";
					_response2 = "They wouldn't want me talking to you";
					_response3 = "I cannot help you";
					_response4 = "No, I have not";
					_response5 = "I have not seen anything lately";
					_response6 = "There is no danger here";
					_response7 = "I don't have time for this";
					_response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7] call BIS_fnc_selectRandom;
					CIVINTERACT_RESPONSELIST ctrlSetText _response;
					_answersGiven pushBack "StrangeBehavior";_answerGiven = true;
				};
			};
		};
	};

	//-- What is your opinion of our forces
	case "Opinion": {
		private ["_response"];
		_personalHostility = _civInfo select 1;
		_townHostility = _civInfo select 2;

		if (((_townHostility / 2.5) > 45) and (floor random 100 > 25) and (_personalHostility < 50)) exitWith {
			_response1 = "They wouldn't like me talking to you.";
			_response2 = "I can't talk about this.";
			_response3 = "Please.. just leave me alone.";
			_response4 = "I can't help you.";
			_response5 = "Please leave before they see you.";
			_response6 = "You must leave immediately.";
			_response7 = "They must not see me talking to you.";
			_response = [_response1, _response2, _response3, _response4, _response5, _response6,_response7] call BIS_fnc_selectRandom;
			CIVINTERACT_RESPONSELIST ctrlSetText _response;

			//-- Check if civilian is irritated
			[_logic,"isIrritated", [_hostile,_asked,_civ]] call MAINCLASS;
		};

		if !(_hostile) then {
			if (floor random 100 < 70) then {

				//-- Give answer
				if (_personalHostility <= 25) then {
					_response1 = "I support you.";
					_response2 = "You will have no problems with me.";
					_response3 = "I support your cause.";
					_response4 = "You do not have to worry about me.";
					_response5 = "I fully support your forces.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_personalHostility > 25) and (_personalHostility <= 50)) then {
					_response1 = "I mostly support you.";
					_response2 = "I support you. Do not mess it up.";
					_response3 = "I have mixed feelings about your forces.";
					_response4 = "You have keep my trust.";
					_response5 = "I have supported you for awhile.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_personalHostility > 50) and (_personalHostility <= 75)) then {
					_response1 = "Your forces have made bad decisions lately.";
					_response2 = "I am beginning to dislike you.";
					_response3 = "You must regain my trust.";
					_response4 = "You better not stay long.";
					_response5 = "I do not support you.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_personalHostility > 75) and (_personalHostility <= 100)) then {
					_response1 = "I strongly oppose of your presence here.";
					_response2 = "You better leave.";
					_response3 = "I do not support you.";
					_response4 = "I hate your forces.";
					_response5 = "You need to leave immediately.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if (_personalHostility > 100) then {
					_response1 = "I am extremely opposed to you.";
					_response2 = "You do not here.";
					_response3 = "You need to leave now.";
					_response4 = "Get out of here!";
					_response5 = "Who would support people like you?";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((isNil "_response") or (isNil "_personalHostility")) then {_response = "I don't want to talk right now"};
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
				_answersGiven pushBack "Opinion";_answerGiven = true;
			} else {
				//-- Decline to answer
				_response1 = "I don't want to talk right now.";
				_response2 = "I don't think I should be talking to you.";
				_response3 = "I shouldn't be talking to you.";
				_response4 = "You should move on.";
				_response5 = "I can't answer that.";
				_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
			};
		} else {
			if (floor random 100 > _personalHostility) then {
				//-- Give answer
				if (_personalHostility <= 25) then {
					_response1 = "I support you.";
					_response2 = "You will have no problems with me.";
					_response3 = "I support your cause.";
					_response4 = "You do not have to worry about me.";
					_response5 = "I fully support your forces.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_personalHostility > 25) and (_personalHostility <= 50)) then {
					_response1 = "I mostly support you.";
					_response2 = "I support you. Do not mess it up.";
					_response3 = "I have mixed feelings about your forces.";
					_response4 = "You have keep my trust.";
					_response5 = "I have supported you for awhile.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_personalHostility > 50) and (_personalHostility <= 75)) then {
					_response1 = "Your forces have made bad decisions lately.";
					_response2 = "I am beginning to dislike you.";
					_response3 = "You must regain my trust.";
					_response4 = "You better not stay long.";
					_response5 = "I do not support you.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_personalHostility > 75) and (_personalHostility <= 100)) then {
					_response1 = "I strongly oppose of your presence here.";
					_response2 = "You better leave.";
					_response3 = "I do not support you.";
					_response4 = "I hate your forces.";
					_response5 = "You need to leave immediately.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if (_personalHostility > 100) then {
					_response1 = "I am extremely opposed to you.";
					_response2 = "You do not here.";
					_response3 = "You need to leave now.";
					_response4 = "Get out of here!";
					_response5 = "Who would support people like you?";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((isNil "_response") or (isNil "_personalHostility")) then {_response = "I don't want to talk right now"};
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
				_answersGiven pushBack "Opinion";_answerGiven = true;
			} else {
				//-- Decline to answer
				_response1 = "I don't want to talk right now.";
				_response2 = "I don't think I should be talking to you.";
				_response3 = "I shouldn't be talking to you.";
				_response4 = "You should move on.";
				_response5 = "I can't answer that.";
				_response6 = "Get out of here!";
				_response = [_response1, _response2, _response3, _response4, _response5,_response6] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
			};
		};
	};

	//-- What is the general opinion of our forces in your town
	case "TownOpinion": {
		private ["_response"];
		_personalHostility = _civInfo select 1;
		_townHostility = _civInfo select 2;

		if (((_townHostility / 2.5) > 45) and (floor random 100 > 25) and (_personalHostility < 50)) exitWith {
			_response1 = "They wouldn't like me talking to you.";
			_response2 = "I can't talk about this.";
			_response3 = "You must leave this place immediately.";
			_response4 = "You are in severe danger here.";
			_response5 = "Please leave before they see you.";
			_response6 = "You must leave immediately.";
			_response7 = "They must not see me talking to you.";
			_response = [_response1, _response2, _response3, _response4, _response5, _response6,_response7] call BIS_fnc_selectRandom;
			CIVINTERACT_RESPONSELIST ctrlSetText _response;

			//-- Check if civilian is irritated
			[_logic,"isIrritated", [_hostile,_asked,_civ]] call MAINCLASS;
		};

		//-- This really needs to be a switch, couldn't get it to work properly the first time
		if !(_hostile) then {
			if (floor random 100 < 70) then {

				//-- Give answer
				if (_townHostility <= 25) then {
					_response1 = "You are well respected around here.";
					_response2 = "I don't think you need to worry about our hostility here.";
					_response3 = "We support you.";
					_response4 = "We will help you if we can.";
					_response5 = "You are supported here.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_townHostility > 25) and (_townHostility <= 50)) then {
					_response1 = "Tensions have been rising lately.";
					_response2 = "The people around here are undecided.";
					_response3 = "There are mixed feelings about you.";
					_response4 = "You might want to try and lower hostility around here.";
					_response5 = "Most of us support you.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_townHostility > 50) and (_townHostility <= 75)) then {
					_response1 = "Tensions have risen greatly.";
					_response2 = "The people around here do not like you.";
					_response3 = "You are not liked around here.";
					_response4 = "You shouldn't stay long.";
					_response5 = "Most people do not support you.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_townHostility > 75) and (_townHostility <= 100)) then {
					_response1 = "Tensions are very high.";
					_response2 = "Be very careful of people around here.";
					_response3 = "You are strongly opposed here.";
					_response4 = "You shouldn't stay long.";
					_response5 = "Very few of us support you.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if (_townHostility > 100) then {
					_response1 = "Tensions are extremely high.";
					_response2 = "You might get followed if you stick around.";
					_response3 = "You are hated around here.";
					_response4 = "You should leave now.";
					_response5 = "Barely anybody here supports you.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((isNil "_response") or (isNil "_townHostility")) then {_response = "I don't want to talk right now"};
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
				_answersGiven pushBack "TownOpinion";_answerGiven = true;
			} else {
				//-- Decline to answer
				_response1 = "I don't want to talk right now.";
				_response2 = "I don't think I should be talking to you.";
				_response3 = "I shouldn't be talking to you.";
				_response4 = "You should move on.";
				_response5 = "I can't answer that.";
				_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
			};
		} else {
			if (floor random 100 > _personalHostility) then {
				//-- Give answer
				if (_townHostility <= 25) then {
					_response1 = "You are well respected around here.";
					_response2 = "I don't think you need to worry about our hostility here.";
					_response3 = "We support you.";
					_response4 = "We will help you if we can.";
					_response5 = "You are supported here.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_townHostility > 25) and (_townHostility <= 50)) then {
					_response1 = "Tensions have been rising lately.";
					_response2 = "The people around here are undecided.";
					_response3 = "There are mixed feelings about you.";
					_response4 = "You might want to try and lower hostility around here.";
					_response5 = "Most of us support you.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_townHostility > 50) and (_townHostility <= 75)) then {
					_response1 = "Tensions have risen greatly.";
					_response2 = "The people around here do not like you.";
					_response3 = "You are not liked around here.";
					_response4 = "You shouldn't stay long.";
					_response5 = "Most people do not support you.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((_townHostility > 75) and (_townHostility <= 100)) then {
					_response1 = "Tensions are very high.";
					_response2 = "Be very careful of people around here.";
					_response3 = "You are strongly opposed here.";
					_response4 = "You shouldn't stay long.";
					_response5 = "Very few of us support you.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if (_townHostility > 100) then {
					_response1 = "Tensions are extremely high.";
					_response2 = "You might get followed if you stick around.";
					_response3 = "You are hated around here.";
					_response4 = "You should leave now.";
					_response5 = "Barely anybody here supports you.";
					_response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
				};

				if ((isNil "_response") or (isNil "_townHostility")) then {_response = "I don't want to talk right now"};
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
				_answersGiven pushBack "TownOpinion";_answerGiven = true;
			} else {
				//-- Decline to answer
				_response1 = "I don't want to talk right now.";
				_response2 = "I don't think I should be talking to you.";
				_response3 = "I shouldn't be talking to you.";
				_response4 = "You should move on.";
				_response5 = "I can't answer that.";
				_response6 = "Get out of here!";
				_response = [_response1, _response2, _response3, _response4, _response5,_response6] call BIS_fnc_selectRandom;
				CIVINTERACT_RESPONSELIST ctrlSetText _response;
			};
		};
	};

};

//-- Check if civilian is irritated
[_logic,"isIrritated", [_hostile,_asked,_civ]] call MAINCLASS;

if (_answerGiven) then {
	[_civData, "AnswersGiven", _answersGiven] call ALiVE_fnc_hashSet;
	_civ setVariable ["AnswersGiven",_answersGiven];
	_civ setVariable ["AnswersGiven",_answersGiven, false]; //-- Broadcasting could bring server perf loss with high use (set false to true at risk)
};


/*
Threat outline

ADD THREATS THAT CAN LOWER OR RAISE HOSTILITY DEPENDING ON THE CIVILIANS CURRENT
HOSTILITY AND THE AMOUNT OF QUESTIONS ASKED ALREADY
THREATS TOWARDS LOW HOSTILITY CIVS COULD HAVE A HIGHER CHANCE OF RAISING HOSTILITY
WHILE THREATS TOWARDS HIGH HOSTILITY CIVS COULD HAVE A HIGHER CHANCE (MAKE IT BALANCED)

if (floor random 100 > _hostility) then {
	_hostility = ceil (_hostility / 3);
	_civInfo = [_civInfo select 0, _hostility, _civInfo select 2];
	[_logic, "CivInfo", _civInfo] call ALiVE_fnc_hashSet;
} else {
	if (floor random 100 > 20) then {
		_hostility = ceil (_hostility / 3);
		_civInfo = [_civInfo select 0, _hostility, _civInfo select 2];
		[_logic, "CivInfo", _civInfo] call ALiVE_fnc_hashSet;
	};
};
*/