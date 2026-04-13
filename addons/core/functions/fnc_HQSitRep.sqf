#include "..\script_component.hpp"
params ["_HQ"];

_HQ setVariable ["leaderHQ",(leader _HQ)];
_csN = +GVAR(callSignsN);

{
	_nouns = [_x] call EFUNC(common,randomOrdB);
	_csN set [_foreachIndex,_nouns]
} forEach _csN;

_HQ setVariable [QGVAR(callSignsN), _csN];
_HQ setVariable [QGVAR(cyclecount), 0];
_cycleC = 0;

if (isNil (QGVAR(mAtt))) then {GVAR(mAtt) = false};
_HQ setVariable [QGVAR(mAtt),GVAR(mAtt)];
if ((isNil (QGVAR(personality))) or !(_HQ getVariable [QGVAR(mAtt),false])) then {GVAR(personality) = "OTHER"};
_HQ setVariable [QGVAR(personality),GVAR(personality)];

if (isNil (QGVAR(recklessness))) then {GVAR(recklessness) = 0.5};
_HQ setVariable [QGVAR(recklessness),GVAR(recklessness)];
if (isNil (QGVAR(consistency))) then {GVAR(consistency) = 0.5};
_HQ setVariable [QGVAR(consistency),GVAR(consistency)];
if (isNil (QGVAR(activity))) then {GVAR(activity) = 0.5};
_HQ setVariable [QGVAR(activity),GVAR(activity)];
if (isNil (QGVAR(reflex))) then {GVAR(reflex) = 0.5};
_HQ setVariable [QGVAR(reflex),GVAR(reflex)];
if (isNil (QGVAR(circumspection))) then {GVAR(circumspection) = 0.5};
_HQ setVariable [QGVAR(circumspection),GVAR(circumspection)];
if (isNil (QGVAR(fineness))) then {GVAR(fineness) = 0.5};
_HQ setVariable [QGVAR(fineness),GVAR(fineness)];

[_HQ] call FUNC(personality);

[[_HQ],EFUNC(hac,lhq)] call EFUNC(common,spawn);

if (isNil (QGVAR(boxed))) then {GVAR(boxed) = []};
_HQ setVariable [QGVAR(boxed),GVAR(boxed)];

if (isNil (QGVAR(ammoBoxes))) then
	{
	GVAR(ammoBoxes) = [];

	if !(isNil QGVAR(ammoDepot)) then
		{
		_radius = (triggerArea GVAR(ammoDepot)) select 0;
		GVAR(ammoBoxes) = (getPosATL GVAR(ammoDepot)) nearObjects ["ReammoBox_F",_radius]
		}
	};

_HQ setVariable [QGVAR(ammoBoxes),GVAR(ammoBoxes)];

_HQ setVariable [QGVAR(reconDone),false];
_HQ setVariable [QGVAR(defDone),false];
_HQ setVariable [QGVAR(reconStage),1];
_HQ setVariable [QGVAR(reconStage2),1];
_HQ setVariable [QGVAR(airInDef),[]];

_KnEnPos = [];

if (isNil (QEGVAR(common,excluded))) then {EGVAR(common,excluded) = []};
_HQ setVariable [QEGVAR(common,excluded),EGVAR(common,excluded)];
if (isNil (QGVAR(fast))) then {GVAR(fast) = false};
_HQ setVariable [QGVAR(fast),GVAR(fast)];
if (isNil (QGVAR(exInfo))) then {GVAR(exInfo) = false};
_HQ setVariable [QGVAR(exInfo),GVAR(exInfo)];
if (isNil (QGVAR(objHoldTime))) then {GVAR(objHoldTime) = 600};
_HQ setVariable [QGVAR(objHoldTime),GVAR(objHoldTime)];
if (isNil QGVAR(nObj)) then {GVAR(nObj) = 1};
_HQ setVariable [QGVAR(nObj),GVAR(nObj)];

_HQ setVariable [QGVAR(init),true];

_HQ setVariable [QGVAR(inertia),0];
_HQ setVariable [QGVAR(morale),0];
_HQ setVariable [QGVAR(cInitial),0];
_HQ setVariable [QGVAR(cLast),0];
_HQ setVariable [QGVAR(cCurrent),0];
_HQ setVariable [QGVAR(cIMoraleC),0];
_HQ setVariable [QGVAR(cLMoraleC),0];
_HQ setVariable [QGVAR(surrender),false];

_HQ setVariable [QGVAR(firstEMark),true];
_HQ setVariable [QGVAR(lastE),0];
_HQ setVariable [QGVAR(flankingInit),false];
_HQ setVariable [QGVAR(flankingDone),false];
_HQ setVariable [QGVAR(progress),0];

_HQ setVariable [QGVAR(aAthreat),[]];
_HQ setVariable [QGVAR(aTthreat),[]];
_HQ setVariable [QGVAR(airthreat),[]];
_HQ setVariable [QGVAR(exhausted),[]];

if (isNil (QGVAR(supportWP))) then {GVAR(supportWP) = false};

_HQ setVariable [QGVAR(supportWP),GVAR(supportWP)];

_lastHQ = _HQ getVariable ["leaderHQ",objNull];
_OLmpl = 0;
_cycleCap = 0;
_firstMC = 0;
_wp = [];
_lastReset = 0;
_HQlPos = [-10,-10,0];
_cInitial = 0;

while {true} do
	{

	if (GVAR(rHQAutoFill)) then
	{
	[] call EFUNC(data,presentRHQ)
	};

	_specFor_class = EGVAR(data,specFor) + EGVAR(data,wS_specFor_class) - RHQs_SpecFor;

	_recon_class = EGVAR(data,recon) + EGVAR(data,wS_recon_class) - RHQs_Recon;

	_FO_class = EGVAR(data,fO) + EGVAR(data,wS_FO_class) - RHQs_FO;

	_snipers_class = EGVAR(data,snipers) + EGVAR(data,wS_snipers_class) - RHQs_Snipers;

	_ATinf_class = EGVAR(data,aTInf) + EGVAR(data,wS_ATinf_class) - RHQs_ATInf;

	_AAinf_class = EGVAR(data,aAInf) + EGVAR(data,wS_AAinf_class) - RHQs_AAInf;

	_Inf_class = EGVAR(data,inf) + EGVAR(data,wS_Inf_class) - RHQs_Inf;

	_Art_class = EGVAR(data,art) + EGVAR(data,wS_Art_class) - RHQs_Art;

	_HArmor_class = EGVAR(data,hArmor) + EGVAR(data,wS_HArmor_class) - RHQs_HArmor;

	_MArmor_class = EGVAR(data,mArmor) + EGVAR(data,wS_MArmor_class) - RHQs_MArmor;

	_LArmor_class = EGVAR(data,lArmor) + EGVAR(data,wS_LArmor_class) - RHQs_LArmor;

	_LArmorAT_class = EGVAR(data,lArmorAT) + EGVAR(data,wS_LArmorAT_class) - RHQs_LArmorAT;

	_Cars_class = EGVAR(data,cars) + EGVAR(data,wS_Cars_class) - RHQs_Cars;

	_Air_class = EGVAR(data,air) + EGVAR(data,wS_Air_class) - RHQs_Air;

	_BAir_class = EGVAR(data,bAir) + EGVAR(data,wS_BAir_class) - RHQs_BAir;

	_RAir_class = EGVAR(data,rAir) + EGVAR(data,wS_RAir_class) - RHQs_RAir;

	_NCAir_class = EGVAR(data,nCAir) + EGVAR(data,wS_NCAir_class) - RHQs_NCAir;

	_Naval_class = EGVAR(data,naval) + EGVAR(data,wS_Naval_class) - RHQs_Naval;

	_Static_class = EGVAR(data,static) + EGVAR(data,wS_Static_class) - RHQs_Static;

	_StaticAA_class = EGVAR(data,staticAA) + EGVAR(data,wS_StaticAA_class) - RHQs_StaticAA;

	_StaticAT_class = EGVAR(data,staticAT) + EGVAR(data,wS_StaticAT_class) - RHQs_StaticAT;

	_Support_class = EGVAR(data,support) + EGVAR(data,wS_Support_class) - RHQs_Support;

	_Cargo_class = EGVAR(data,cargo) + EGVAR(data,wS_Cargo_class) - RHQs_Cargo;

	_NCCargo_class = EGVAR(data,nCCargo) + EGVAR(data,wS_NCCargo_class) - RHQs_NCCargo;

	_Crew_class = EGVAR(data,crew) + EGVAR(data,wS_Crew_class) - RHQs_Crew;

	_Other_class = EGVAR(data,other) + EGVAR(data,wS_Other_class);

	_NCrewInf_class = _Inf_class - _Crew_class;
	_Cargo_class = _Cargo_class - (_Support_class - ["MH60S"]);

	_HQ setVariable [QGVAR(nCVeh),_NCCargo_class + (_Support_class - ["MH60S"])];

	if (isNull _HQ) exitWith {GVAR(allHQ) = GVAR(allHQ) - [_HQ]};
	if (({alive _x} count (units _HQ)) == 0) exitWith {GVAR(allHQ) = GVAR(allHQ) - [_HQ]};
	if (_HQ getVariable [QGVAR(surrender),false]) exitWith {GVAR(allHQ) = GVAR(allHQ) - [_HQ]};

	if !(_HQ getVariable [QGVAR(fast),false]) then
		{
		waitUntil
			{
			sleep 0.1;
			((({(_x getVariable [QGVAR(pending),false])} count GVAR(allHQ)) == 0) or (_HQ getVariable [QEGVAR(common,kIA),false]))
			}
		};

	if (_HQ getVariable [QEGVAR(common,kIA),false]) exitWith {GVAR(allHQ) = GVAR(allHQ) - [_HQ]};

	_HQ setVariable [QGVAR(pending),true];

	if (_cycleC > 1) then
		{
		if (_lastHQ != (_HQ getVariable ["leaderHQ",objNull])) then {sleep (60 + (random 60))};
		};

	if (_HQ getVariable [QEGVAR(common,kIA),false]) exitWith {GVAR(allHQ) = GVAR(allHQ) - [_HQ]};

	_lastHQ = (leader _HQ);

	_HQ setVariable [QGVAR(cyclecount),_cycleC + 1];
	_cycleC = _HQ getVariable [QGVAR(cyclecount),1];

	_SpecFor = [];
	_recon = [];
	_FO = [];
	_snipers = [];
	_ATinf = [];
	_AAinf = [];
	_Inf = [];
	_Art = [];
	_HArmor = [];
	_MArmor = [];
	_LArmor = [];
	_LArmorAT = [];
	_Cars = [];
	_Air = [];
	_BAir = [];
	_RAir = [];
	_NCAir = [];
	_Naval = [];
	_Static = [];
	_StaticAA = [];
	_StaticAT = [];
	_Support = [];
	_Cargo = [];
	_NCCargo = [];
	_Other = [];
	_Crew = [];
	_NCrewInf = [];

	_SpecForG = [];
	_reconG = [];
	_FOG = [];
	_snipersG = [];
	_ATinfG = [];
	_AAinfG = [];
	_InfG = [];
	_ArtG = [];
	_HArmorG = [];
	_MArmorG = [];
	_LArmorG = [];
	_LArmorATG = [];
	_CarsG = [];
	_AirG = [];
	_BAirG = [];
	_RAirG = [];
	_NCAirG = [];
	_NavalG = [];
	_StaticG = [];
	_StaticAAG = [];
	_StaticATG = [];
	_SupportG = [];
	_CargoG = [];
	_NCCargoG = [];
	_OtherG = [];
	_CrewG = [];
	_NCrewInfG = [];

	_EnSpecFor = [];
	_Enrecon = [];
	_EnFO = [];
	_Ensnipers = [];
	_EnATinf = [];
	_EnAAinf = [];
	_EnInf = [];
	_EnArt = [];
	_EnHArmor = [];
	_EnMArmor = [];
	_EnLArmor = [];
	_EnLArmorAT = [];
	_EnCars = [];
	_EnAir = [];
	_EnBAir = [];
	_EnRAir = [];
	_EnNCAir = [];
	_EnNaval = [];
	_EnStatic = [];
	_EnStaticAA = [];
	_EnStaticAT = [];
	_EnSupport = [];
	_EnCargo = [];
	_EnNCCargo = [];
	_EnOther = [];
	_EnCrew = [];
	_EnNCrewInf = [];

	_EnSpecForG = [];
	_EnreconG = [];
	_EnFOG = [];
	_EnsnipersG = [];
	_EnATinfG = [];
	_EnAAinfG = [];
	_EnInfG = [];
	_EnArtG = [];
	_EnHArmorG = [];
	_EnMArmorG = [];
	_EnLArmorG = [];
	_EnLArmorATG = [];
	_EnCarsG = [];
	_EnAirG = [];
	_EnBAirG = [];
	_EnRAirG = [];
	_EnNCAirG = [];
	_EnNavalG = [];
	_EnStaticG = [];
	_EnStaticAAG = [];
	_EnStaticATG = [];
	_EnSupportG = [];
	_EnCargoG = [];
	_EnNCCargoG = [];
	_EnOtherG = [];
	_EnCrewG = [];
	_EnNCrewInfG = [];

	_HQ setVariable [QGVAR(lastE),count (_HQ getVariable [QGVAR(knEnemies),[]])];
	_HQ setVariable [QGVAR(lastFriends),_HQ getVariable [QGVAR(friends),[]]];

	if (isNil QGVAR(garrison)) then {GVAR(garrison) = []};
	_HQ setVariable [QGVAR(garrison),GVAR(garrison)];

	if (isNil (QGVAR(noAirCargo))) then {GVAR(noAirCargo) = false};
	_HQ setVariable [QGVAR(noAirCargo),GVAR(noAirCargo)];
	if (isNil (QGVAR(noLandCargo))) then {GVAR(noLandCargo) = false};
	_HQ setVariable [QGVAR(noLandCargo),GVAR(noLandCargo)];
	if (isNil (QGVAR(lastFriends))) then {GVAR(lastFriends) = []};
	_HQ setVariable [QGVAR(lastFriends),GVAR(lastFriends)];
	if (isNil (QGVAR(cargoFind))) then {GVAR(cargoFind) = 1};
	_HQ setVariable [QGVAR(cargoFind),GVAR(cargoFind)];
	if (isNil (QGVAR(subordinated))) then {GVAR(subordinated) = []};
	_HQ setVariable [QGVAR(subordinated),GVAR(subordinated)];
	if (isNil (QGVAR(included))) then {GVAR(included) = []};
	_HQ setVariable [QGVAR(included),GVAR(included)];
	if (isNil (QEGVAR(common,excluded))) then {EGVAR(common,excluded) = []};
	_HQ setVariable [QEGVAR(common,excluded),EGVAR(common,excluded)];
	if (isNil (QGVAR(subAll))) then {GVAR(subAll) = true};
	_HQ setVariable [QGVAR(subAll),GVAR(subAll)];
	if (isNil (QGVAR(subSynchro))) then {GVAR(subSynchro) = false};
	_HQ setVariable [QGVAR(subSynchro),GVAR(subSynchro)];
	if (isNil (QGVAR(subNamed))) then {GVAR(subNamed) = false};
	_HQ setVariable [QGVAR(subNamed),GVAR(subNamed)];
	if (isNil (QGVAR(subZero))) then {GVAR(subZero) = false};
	_HQ setVariable [QGVAR(subZero),GVAR(subZero)];
	if (isNil (QGVAR(reSynchro))) then {GVAR(reSynchro) = true};
	_HQ setVariable [QGVAR(reSynchro),GVAR(reSynchro)];
	if (isNil (QGVAR(nameLimit))) then {GVAR(nameLimit) = 100};
	_HQ setVariable [QGVAR(nameLimit),GVAR(nameLimit)];
	if (isNil (QGVAR(surr))) then {GVAR(surr) = false};
	_HQ setVariable [QGVAR(surr),GVAR(surr)];
	if (isNil (QGVAR(noRecon))) then {GVAR(noRecon) = []};
	_HQ setVariable [QGVAR(noRecon),GVAR(noRecon)];
	if (isNil (QGVAR(noAttack))) then {GVAR(noAttack) = []};
	_HQ setVariable [QGVAR(noAttack),GVAR(noAttack)];
	if (isNil (QGVAR(cargoOnly))) then {GVAR(cargoOnly) = []};
	_HQ setVariable [QGVAR(cargoOnly),GVAR(cargoOnly)];
	if (isNil (QGVAR(noCargo))) then {GVAR(noCargo) = []};
	_HQ setVariable [QGVAR(noCargo),GVAR(noCargo)];
	if (isNil (QGVAR(noFlank))) then {GVAR(noFlank) = []};
	_HQ setVariable [QGVAR(noFlank),GVAR(noFlank)];
	if (isNil (QGVAR(noDef))) then {GVAR(noDef) = []};
	_HQ setVariable [QGVAR(noDef),GVAR(noDef)];
	if (isNil (QGVAR(firstToFight))) then {GVAR(firstToFight) = []};
	_HQ setVariable [QGVAR(firstToFight),GVAR(firstToFight)];
	if (isNil (QGVAR(voiceComm))) then {GVAR(voiceComm) = true};
	_HQ setVariable [QGVAR(voiceComm),GVAR(voiceComm)];
	if (isNil (QGVAR(frontA))) then {EGVAR(common,front) = false};
	_HQ setVariable [QGVAR(frontA),EGVAR(common,front)];
	if (isNil (QGVAR(lRelocating))) then {GVAR(lRelocating) = false};
	_HQ setVariable [QGVAR(lRelocating),GVAR(lRelocating)];
	if (isNil (QGVAR(flee))) then {GVAR(flee) = true};
	_HQ setVariable [QGVAR(flee),GVAR(flee)];
	if (isNil (QGVAR(garrR))) then {GVAR(garrR) = 500};
	_HQ setVariable [QGVAR(garrR),GVAR(garrR)];
	if (isNil (QGVAR(rush))) then {GVAR(rush) = false};
	_HQ setVariable [QGVAR(rush),GVAR(rush)];
	if (isNil (QGVAR(garrVehAb))) then {GVAR(garrVehAb) = false};
	_HQ setVariable [QGVAR(garrVehAb),GVAR(garrVehAb)];
	if (isNil (QGVAR(defendObjectives))) then {GVAR(defendObjectives) = 4};
	_HQ setVariable [QGVAR(defendObjectives),GVAR(defendObjectives)];
	if (isNil (QGVAR(defSpot))) then {GVAR(defSpot) = []};
	_HQ setVariable [QGVAR(defSpot),GVAR(defSpot)];
	if (isNil (QGVAR(recDefSpot))) then {GVAR(recDefSpot) = []};
	_HQ setVariable [QGVAR(recDefSpot),GVAR(recDefSpot)];
	if (isNil QGVAR(flare)) then {GVAR(flare) = true};
	_HQ setVariable [QGVAR(flare),GVAR(flare)];
	if (isNil QGVAR(smoke)) then {GVAR(smoke) = true};
	_HQ setVariable [QGVAR(smoke),GVAR(smoke)];
	if (isNil QGVAR(noRec)) then {GVAR(noRec) = 1};
	_HQ setVariable [QGVAR(noRec),GVAR(noRec)];
	if (isNil QGVAR(rapidCapt)) then {GVAR(rapidCapt) = 10};
	_HQ setVariable [QGVAR(rapidCapt),GVAR(rapidCapt)];
	if (isNil QGVAR(muu)) then {GVAR(muu) = 1};
	_HQ setVariable [QGVAR(muu),GVAR(muu)];
	if (isNil QGVAR(artyShells)) then {GVAR(artyShells) = 1};
	_HQ setVariable [QGVAR(artyShells),GVAR(artyShells)];
	if (isNil QGVAR(withdraw)) then {GVAR(withdraw) = 1};
	_HQ setVariable [QGVAR(withdraw),GVAR(withdraw)];
	if (isNil QGVAR(berserk)) then {GVAR(berserk) = false};
	_HQ setVariable [QGVAR(berserk),GVAR(berserk)];
	if (isNil QGVAR(iDChance)) then {GVAR(iDChance) = 100};
	_HQ setVariable [QGVAR(iDChance),GVAR(iDChance)];
	if (isNil QGVAR(rDChance)) then {GVAR(rDChance) = 100};
	_HQ setVariable [QGVAR(rDChance),GVAR(rDChance)];
	if (isNil QGVAR(sDChance)) then {GVAR(sDChance) = 100};
	_HQ setVariable [QGVAR(sDChance),GVAR(sDChance)];
	if (isNil QGVAR(ammoDrop)) then {GVAR(ammoDrop) = []};
	_HQ setVariable [QGVAR(ammoDrop),GVAR(ammoDrop)];
	if (isNil QGVAR(sFTargets)) then {GVAR(sFTargets) = []};
	_HQ setVariable [QGVAR(sFTargets),GVAR(sFTargets)];
	if (isNil QGVAR(lZ)) then {GVAR(lZ) = false};
	_HQ setVariable [QGVAR(lZ),GVAR(lZ)];
	if (isNil QGVAR(sFBodyGuard)) then {GVAR(sFBodyGuard) = []};
	_HQ setVariable [QGVAR(sFBodyGuard),GVAR(sFBodyGuard)];
	if (isNil QGVAR(dynForm)) then {GVAR(dynForm) = false};
	_HQ setVariable [QGVAR(dynForm),GVAR(dynForm)];
	if (isNil QGVAR(unlimitedCapt)) then {GVAR(unlimitedCapt) = false};
	_HQ setVariable [QGVAR(unlimitedCapt),GVAR(unlimitedCapt)];
	if (isNil QGVAR(captLimit)) then {GVAR(captLimit) = 10};
	_HQ setVariable [QGVAR(captLimit),GVAR(captLimit)];
	if (isNil QGVAR(getHQInside)) then {GVAR(getHQInside) = false};
	_HQ setVariable [QGVAR(getHQInside),GVAR(getHQInside)];
	if (isNil QGVAR(wA)) then {GVAR(wA) = true};
	_HQ setVariable [QGVAR(wA),GVAR(wA)];

	if (isNil QGVAR(infoMarkers)) then {GVAR(infoMarkers) = false};
	_HQ setVariable [QGVAR(infoMarkers),GVAR(infoMarkers)];

	if (isNil QGVAR(artyMarks)) then {GVAR(artyMarks) = false};
	_HQ setVariable [QGVAR(artyMarks),GVAR(artyMarks)];

	if (isNil (QGVAR(resetNow))) then {GVAR(resetNow) = false};
	_HQ setVariable [QGVAR(resetNow),GVAR(resetNow)];
	if (isNil (QGVAR(resetOnDemand))) then {GVAR(resetOnDemand) = false};
	_HQ setVariable [QGVAR(resetOnDemand),GVAR(resetOnDemand)];
	if (isNil (QGVAR(resetTime))) then {GVAR(resetTime) = 600};
	_HQ setVariable [QGVAR(resetTime),GVAR(resetTime)];
	if (isNil (QGVAR(combining))) then {GVAR(combining) = false};
	_HQ setVariable [QGVAR(combining),GVAR(combining)];
	if (isNil (QGVAR(objRadius1))) then {GVAR(objRadius1) = 300};
	_HQ setVariable [QGVAR(objRadius1),GVAR(objRadius1)];
	if (isNil (QGVAR(objRadius2))) then {GVAR(objRadius2) = 500};
	_HQ setVariable [QGVAR(objRadius2),GVAR(objRadius2)];
	if (isNil (QGVAR(knowTL))) then {GVAR(knowTL) = true};
	_HQ setVariable [QGVAR(knowTL),GVAR(knowTL)];

	if (isNil (QGVAR(sMed))) then {GVAR(sMed) = true};
	_HQ setVariable [QGVAR(sMed),GVAR(sMed)];
	if (isNil (QGVAR(exMedic))) then {GVAR(exMedic) = []};
	_HQ setVariable [QGVAR(exMedic),GVAR(exMedic)];
	if (isNil (QGVAR(medPoints))) then {GVAR(medPoints) = []};
	_HQ setVariable [QGVAR(medPoints),GVAR(medPoints)];
	if (isNil (QGVAR(supportedG))) then {GVAR(supportedG) = []};
	_HQ setVariable [QGVAR(supportedG),GVAR(supportedG)];

	if (isNil (QGVAR(rCAS))) then {GVAR(rCAS) = []};
	_HQ setVariable [QGVAR(rCAS),GVAR(rCAS)];
	if (isNil (QGVAR(rCAP))) then {GVAR(rCAP) = []};
	_HQ setVariable [QGVAR(rCAP),GVAR(rCAP)];

	if (isNil (QGVAR(sFuel))) then {GVAR(sFuel) = true};
	_HQ setVariable [QGVAR(sFuel),GVAR(sFuel)];
	if (isNil (QGVAR(exRefuel))) then {GVAR(exRefuel) = []};
	_HQ setVariable [QGVAR(exRefuel),GVAR(exRefuel)];
	if (isNil (QGVAR(fuelPoints))) then {GVAR(fuelPoints) = []};
	_HQ setVariable [QGVAR(fuelPoints),GVAR(fuelPoints)];
	if (isNil (QGVAR(fSupportedG))) then {GVAR(fSupportedG) = []};
	_HQ setVariable [QGVAR(fSupportedG),GVAR(fSupportedG)];

	if (isNil (QGVAR(sAmmo))) then {GVAR(sAmmo) = true};
	_HQ setVariable [QGVAR(sAmmo),GVAR(sAmmo)];
	if (isNil (QGVAR(exReammo))) then {GVAR(exReammo) = []};
	_HQ setVariable [QGVAR(exReammo),GVAR(exReammo)];
	if (isNil (QGVAR(ammoPoints))) then {GVAR(ammoPoints) = []};
	_HQ setVariable [QGVAR(ammoPoints),GVAR(ammoPoints)];
	if (isNil (QGVAR(aSupportedG))) then {GVAR(aSupportedG) = []};
	_HQ setVariable [QGVAR(aSupportedG),GVAR(aSupportedG)];

	if (isNil (QGVAR(sRep))) then {GVAR(sRep) = true};
	_HQ setVariable [QGVAR(sRep),GVAR(sRep)];
	if (isNil (QGVAR(exRepair))) then {GVAR(exRepair) = []};
	_HQ setVariable [QGVAR(exRepair),GVAR(exRepair)];
	if (isNil (QGVAR(repPoints))) then {GVAR(repPoints) = []};
	_HQ setVariable [QGVAR(repPoints),GVAR(repPoints)];
	if (isNil (QGVAR(rSupportedG))) then {GVAR(rSupportedG) = []};
	_HQ setVariable [QGVAR(rSupportedG),GVAR(rSupportedG)];

	if (isNil QGVAR(airDist)) then {GVAR(airDist) = 4000};
	_HQ setVariable [QGVAR(airDist),GVAR(airDist)];

	if (isNil (QGVAR(commDelay))) then {GVAR(commDelay) = 1};
	_HQ setVariable [QGVAR(commDelay),GVAR(commDelay)];


	if ((isNil (QGVAR(order))) and (isNil {_HQ getVariable QGVAR(order)})) then {_HQ setVariable [QGVAR(order),"ATTACK"]};
	if ( !(isNil (QGVAR(order)))) then {
		if (GVAR(order) == "DEFEND") then {
			_HQ setVariable [QGVAR(order),"DEFEND"]
		} else {
			_HQ setVariable [QGVAR(order),"ATTACK"]
		};
	};

	if (isNil (QGVAR(attackAlways))) then {GVAR(attackAlways) = false};
	_HQ setVariable [QGVAR(attackAlways),GVAR(attackAlways)];

	if (isNil (QGVAR(cRDefRes))) then {GVAR(cRDefRes) = 0};
	_HQ setVariable [QGVAR(cRDefRes),GVAR(cRDefRes)];

	if (isNil (QGVAR(reconReserve))) then {GVAR(reconReserve) = (0.3 * (0.5 + (_HQ getVariable [QGVAR(circumspection),0.5])))};
	_HQ setVariable [QGVAR(reconReserve),GVAR(reconReserve)];
	if (isNil (QGVAR(exhausted))) then {GVAR(exhausted) = []};
	_HQ setVariable [QGVAR(exhausted),GVAR(exhausted)];
	if (isNil (QGVAR(attackReserve))) then {GVAR(attackReserve) = (0.5 * (0.5 + ((_HQ getVariable [QGVAR(circumspection),0.5])/1.5)))};
	_HQ setVariable [QGVAR(attackReserve),GVAR(attackReserve)];
	if (isNil (QGVAR(idleOrd))) then {GVAR(idleOrd) = true};
	_HQ setVariable [QGVAR(idleOrd),GVAR(idleOrd)];

	if (isNil (QGVAR(idleDef))) then {GVAR(idleDef) = true};
	_HQ setVariable [QGVAR(idleDef),GVAR(idleDef)];

	if (isNil QGVAR(idleDecoy)) then {GVAR(idleDecoy) = objNull};
	_HQ setVariable [QGVAR(idleDecoy),GVAR(idleDecoy)];
	if (isNil QGVAR(supportDecoy)) then {GVAR(supportDecoy) = objNull};
	_HQ setVariable [QGVAR(supportDecoy),GVAR(supportDecoy)];
	if (isNil QGVAR(restDecoy)) then {GVAR(restDecoy) = objNull};
	_HQ setVariable [QGVAR(restDecoy),GVAR(restDecoy)];
	if (isNil QGVAR(sec1)) then {GVAR(sec1) = objNull};
	_HQ setVariable [QGVAR(sec1),GVAR(sec1)];
	if (isNil QGVAR(sec2)) then {GVAR(sec2) = objNull};
	_HQ setVariable [QGVAR(sec2),GVAR(sec2)];

	if (isNil QGVAR(supportRTB)) then {GVAR(supportRTB) = false};
	_HQ setVariable [QGVAR(supportRTB),GVAR(supportRTB)];

	if (isNil QEGVAR(common,debug)) then {EGVAR(common,debug) = false};
	_HQ setVariable [QEGVAR(common,debug),EGVAR(common,debug)];
	if (isNil QGVAR(debugII)) then {GVAR(debugII) = false};
	_HQ setVariable [QGVAR(debugII),GVAR(debugII)];

	if (isNil QGVAR(alwaysKnownU)) then {GVAR(alwaysKnownU) = []};
	_HQ setVariable [QGVAR(alwaysKnownU),GVAR(alwaysKnownU)];
	if (isNil QGVAR(alwaysUnKnownU)) then {GVAR(alwaysUnKnownU) = []};
	_HQ setVariable [QGVAR(alwaysUnKnownU),GVAR(alwaysUnKnownU)];

	if (isNil QGVAR(aOnly)) then {GVAR(aOnly) = []};
	_HQ setVariable [QGVAR(aOnly),GVAR(aOnly)];
	if (isNil QGVAR(rOnly)) then {GVAR(rOnly) = []};
	_HQ setVariable [QGVAR(rOnly),GVAR(rOnly)];

	if (isNil QGVAR(airEvac)) then {GVAR(airEvac) = false};
	_HQ setVariable [QGVAR(airEvac),GVAR(airEvac)];

	if (isNil QGVAR(aAO)) then {GVAR(aAO) = false};
	_HQ setVariable [QGVAR(aAO),GVAR(aAO)];
	if (isNil QGVAR(forceAAO)) then {GVAR(forceAAO) = false};
	_HQ setVariable [QGVAR(forceAAO),GVAR(forceAAO)];


	if (isNil QGVAR(bBAOObj)) then {GVAR(bBAOObj) = 1};
	_HQ setVariable [QGVAR(bBAOObj),GVAR(bBAOObj)];

	if (isNil (QGVAR(moraleConst))) then {GVAR(moraleConst) = 1};
	_HQ setVariable [QGVAR(moraleConst),GVAR(moraleConst)];

	if (isNil (QGVAR(offTend))) then {GVAR(offTend) = 1};
	_HQ setVariable [QGVAR(offTend),GVAR(offTend)];

	if (isNil QGVAR(eBDoctrine)) then {GVAR(eBDoctrine) = false};
	_HQ setVariable [QGVAR(eBDoctrine),GVAR(eBDoctrine)];
	if (isNil QGVAR(forceEBDoctrine)) then {GVAR(forceEBDoctrine) = false};
	_HQ setVariable [QGVAR(forceEBDoctrine),GVAR(forceEBDoctrine)];

	if (isNil QGVAR(defRange)) then {GVAR(defRange) = 1};
	_HQ setVariable [QGVAR(defRange),GVAR(defRange)];
	if (isNil QGVAR(garrRange)) then {GVAR(garrRange) = 1};
	_HQ setVariable [QGVAR(garrRange),GVAR(garrRange)];

	if (isNil QGVAR(noCapt)) then {GVAR(noCapt) = []};
	_HQ setVariable [QGVAR(noCapt),GVAR(noCapt)];

	if (isNil QGVAR(attInfDistance)) then {GVAR(attInfDistance) = 1};
	_HQ setVariable [QGVAR(attInfDistance),GVAR(attInfDistance)];
	if (isNil QGVAR(attArmDistance)) then {GVAR(attArmDistance) = 1};
	_HQ setVariable [QGVAR(attArmDistance),GVAR(attArmDistance)];
	if (isNil QGVAR(attSnpDistance)) then {GVAR(attSnpDistance) = 1};
	_HQ setVariable [QGVAR(attSnpDistance),GVAR(attSnpDistance)];
	if (isNil QGVAR(captureDistance)) then {GVAR(captureDistance) = 1};
	_HQ setVariable [QGVAR(captureDistance),GVAR(captureDistance)];
	if (isNil QGVAR(flankDistance)) then {GVAR(flankDistance) = 1};
	_HQ setVariable [QGVAR(flankDistance),GVAR(flankDistance)];
	if (isNil QGVAR(attSFDistance)) then {GVAR(attSFDistance) = 1};
	_HQ setVariable [QGVAR(attSFDistance),GVAR(attSFDistance)];
	if (isNil QGVAR(reconDistance)) then {GVAR(reconDistance) = 1};
	_HQ setVariable [QGVAR(reconDistance),GVAR(reconDistance)];
	if (isNil QEGVAR(common,uAVAlt)) then {EGVAR(common,uAVAlt) = 150};
	_HQ setVariable [QEGVAR(common,uAVAlt),EGVAR(common,uAVAlt)];

	if (isNil QGVAR(obj1)) then {GVAR(obj1) = createTrigger ["EmptyDetector", leaderHQ]};
	if (isNil QGVAR(obj2)) then {GVAR(obj2) = createTrigger ["EmptyDetector", leaderHQ]};
	if (isNil QGVAR(obj3)) then {GVAR(obj3) = createTrigger ["EmptyDetector", leaderHQ]};
	if (isNil QGVAR(obj4)) then {GVAR(obj4) = createTrigger ["EmptyDetector", leaderHQ]};

	_HQ setVariable [QGVAR(obj1),GVAR(obj1)];
	_HQ setVariable [QGVAR(obj2),GVAR(obj2)];
	_HQ setVariable [QGVAR(obj3),GVAR(obj3)];
	_HQ setVariable [QGVAR(obj4),GVAR(obj4)];

	_objectives = [GVAR(obj1),GVAR(obj2),GVAR(obj3),GVAR(obj4)];
	_NAVObjectives = [];

	if (isNil (QGVAR(simpleMode))) then {GVAR(simpleMode) = true};
	_HQ setVariable [QGVAR(simpleMode),GVAR(simpleMode)];

	if (isNil (QGVAR(secTasks))) then {GVAR(secTasks) = false};
	_HQ setVariable [QGVAR(secTasks),GVAR(secTasks)];

	if (isNil (QGVAR(simpleObjs))) then {GVAR(simpleObjs) = []};
	_HQ setVariable [QGVAR(simpleObjs),GVAR(simpleObjs)];

	if (isNil (QGVAR(navalObjs))) then {GVAR(navalObjs) = []};
	_HQ setVariable [QGVAR(navalObjs),GVAR(navalObjs)];

	if (isNil (QGVAR(maxSimpleObjs))) then {GVAR(maxSimpleObjs) = 5};
	_HQ setVariable [QGVAR(maxSimpleObjs),GVAR(maxSimpleObjs)];

	if (_HQ getVariable [QGVAR(simpleMode),false]) then {

		_objectives = GVAR(simpleObjs);
		_NAVObjectives = GVAR(navalObjs);
		_HQ setVariable [QGVAR(aAO),true];
		_HQ setVariable [QGVAR(forceAAO),true];

	};

	_HQ setVariable [QGVAR(objectives),_objectives];
	_HQ setVariable [QGVAR(navalObjectives),_NAVObjectives];

	_listed = _HQ getVariable "BBProgress";

	if (isNil "_listed") then
		{
		_midX = 0;
		_midY = 0;

		_notTaken = _objectives - (_HQ getVariable [QEGVAR(common,taken),[]]);

		_nTc = count _notTaken;

		if (_nTc < 1) then
			{
			_notTaken = _objectives;
			_nTc = 4
			};

			{
			_pos = getPosATL _x;
			_midX = _midX + (_pos select 0);
			_midY = _midY + (_pos select 1);
			}
		forEach _notTaken;

		_HQ setVariable [QGVAR(eyeOfBattle),[_midX/_nTc,_midY/_nTc,0]];
		};

	if !(isNil QGVAR(defFrontL)) then {_HQ setVariable [QGVAR(defFrontL),GVAR(defFrontL)]};
	if !(isNil QGVAR(defFront1)) then {_HQ setVariable [QGVAR(defFront1),GVAR(defFront1)]};
	if !(isNil QGVAR(defFront2)) then {_HQ setVariable [QGVAR(defFront2),GVAR(defFront2)]};
	if !(isNil QGVAR(defFront3)) then {_HQ setVariable [QGVAR(defFront3),GVAR(defFront3)]};
	if !(isNil QGVAR(defFront4)) then {_HQ setVariable [QGVAR(defFront4),GVAR(defFront4)]};

	_civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];
	if !(isNil (QGVAR(civF))) then {_civF = GVAR(civF)};
	_HQ setVariable [QGVAR(civF),_civF];

	if (isNil (QGVAR(def))) then {GVAR(def) = []};
	_HQ setVariable [QGVAR(def),GVAR(def)];

	_nObj = _HQ getVariable [QGVAR(nObj),1];

	switch (_nObj) do
		{
		case (1) : {_HQ setVariable [QGVAR(obj),GVAR(obj1)]};
		case (2) : {_HQ setVariable [QGVAR(obj),GVAR(obj2)]};
		case (3) : {_HQ setVariable [QGVAR(obj),GVAR(obj3)]};
		default {_HQ setVariable [QGVAR(obj),GVAR(obj4)]};
		};

	[_HQ, _cycleC, _lastReset, [], _civF] call EFUNC(hac,statusQuo);
	};
