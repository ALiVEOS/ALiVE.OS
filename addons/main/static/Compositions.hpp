
/*
 * Compositions
 */

ALIVE_compositions = [] call ALIVE_fnc_hashCreate;

[ALIVE_compositions, "HQ", [
	"smallHQOutpost1",
	"largeMedicalHQ1"
]] call ALIVE_fnc_hashSet;

[ALIVE_compositions, "camps", [
	"smallConvoyCamp1",
	"smallMilitaryCamp1",
	"smallMortarCamp1",
	"mediumAACamp1",
	"mediumMilitaryCamp1",
	"mediumMGCamp1",
	"mediumMGCamp2",
	"mediumMGCamp3"
]] call ALIVE_fnc_hashSet;

[ALIVE_compositions, "communications", [
	"communicationCamp1"
]] call ALIVE_fnc_hashSet;

[ALIVE_compositions, "fuel", [
	"smallFuelStation1",
	"mediumFuelSilo1"
]] call ALIVE_fnc_hashSet;

[ALIVE_compositions, "constructionSupplies", [
	"bagFenceKit1",
	"hbarrierKit1",
	"hbarrierKit2",
	"hbarrierWallKit1",
	"hbarrierWallKit2"
]] call ALIVE_fnc_hashSet;

[ALIVE_compositions, "crashsites", [
	"smallOspreyCrashsite1",
	"smallAH99Crashsite1",
	"mediumc192Crash1"
]] call ALIVE_fnc_hashSet;

[ALIVE_compositions, "objectives", [
	"largeMilitaryOutpost1",
	"mediumMilitaryOutpost1",
	"hugeSupplyOutpost1",
	"hugeMilitaryOutpost1"
]] call ALIVE_fnc_hashSet;

[ALIVE_compositions, "other", [
	"smallATNest1",
	"smallMGNest1",
	"smallCheckpoint1",
	"smallRoadblock1",
	"mediumCheckpoint1",
	"largeGarbageCamp1"
]] call ALIVE_fnc_hashSet;

[ALIVE_compositions, "roadblocks", [
	"smallCheckpoint1",
	"smallCheckpoint2",
	"smallCheckpoint3",
	"mediumCheckpoint2",
	"smallroadblock1",
	"smallroadblock2"
]] call ALIVE_fnc_hashSet;