/* 
* Filename:
* macros.sqf 
*
* Description:
* Define keywords and assign definitions
* 
* NOTE: In ArmA 3 preprocessor commands are case-sensitive!
*
* Created by [KH]Jman
* Creation date: 07/01/2017
* Email: jman@kellys-heroes.eu
* Web: http://www.kellys-heroes.eu
* 
* */
// ====================================================================================
#define VAR_DEFAULT(var,val) if (isNil #var) then {var=(val);}


#ifndef PP
	#define PP preprocessFileLineNumbers
#endif

#ifndef execNow
	#define execNow call compile preprocessFileLineNumbers 
#endif

#ifndef CPP
	#define CPP compile preprocessFileLineNumbers
#endif

#ifndef CCP
	#define CCP call compile preprocessFile
#endif
