#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/HQSitRepG.sqf

_SCRname = "SitRepG";
_HQ = _this select 0;

_HQ setVariable ["leaderHQ",(leader _HQ)];
_csN = +GVAR(callSignsN);

	{
	_nouns = [_x] call EFUNC(common,randomOrdB);
	_csN set [_foreachIndex,_nouns]
	}
forEach _csN;

_HQ setVariable [QGVAR(callSignsN),_csN];
_HQ setVariable [QGVAR(cyclecount),0];
_cycleC = 0;

if (isNil (QGVAR(mAttG))) then {GVAR(mAttG) = false};
_HQ setVariable [QGVAR(mAtt),GVAR(mAttG)];
if ((isNil (QGVAR(personalityG))) or not (_HQ getVariable [QGVAR(mAtt),false])) then {GVAR(personalityG) = "OTHER"};
_HQ setVariable [QGVAR(personality),GVAR(personalityG)];

if (isNil (QGVAR(recklessnessG))) then {GVAR(recklessnessG) = 0.5};
_HQ setVariable [QGVAR(recklessness),GVAR(recklessnessG)];
if (isNil (QGVAR(consistencyG))) then {GVAR(consistencyG) = 0.5};
_HQ setVariable [QGVAR(consistency),GVAR(consistencyG)];
if (isNil (QGVAR(activityG))) then {GVAR(activityG) = 0.5};
_HQ setVariable [QGVAR(activity),GVAR(activityG)];
if (isNil (QGVAR(reflexG))) then {GVAR(reflexG) = 0.5};
_HQ setVariable [QGVAR(reflex),GVAR(reflexG)];
if (isNil (QGVAR(circumspectionG))) then {GVAR(circumspectionG) = 0.5};
_HQ setVariable [QGVAR(circumspection),GVAR(circumspectionG)];
if (isNil (QGVAR(finenessG))) then {GVAR(finenessG) = 0.5};
_HQ setVariable [QGVAR(fineness),GVAR(finenessG)];

[_HQ] call FUNC(personality);

[[_HQ],EFUNC(hac,lhq)] call EFUNC(common,spawn);

if (isNil (QGVAR(boxedG))) then {GVAR(boxedG) = []};
_HQ setVariable [QGVAR(boxed),GVAR(boxedG)];

if (isNil (QEGVAR(missionmodules,ammoBoxesG))) then
	{
	EGVAR(missionmodules,ammoBoxesG) = [];

	if not (isNil QEGVAR(missionmodules,ammoDepotG)) then
		{
		_rds = (triggerArea EGVAR(missionmodules,ammoDepotG)) select 0;
		EGVAR(missionmodules,ammoBoxesG) = (getPosATL EGVAR(missionmodules,ammoDepotG)) nearObjects ["ReammoBox_F",_rds]
		}
	};

_HQ setVariable [QGVAR(ammoBoxes),EGVAR(missionmodules,ammoBoxesG)];

_HQ setVariable [QGVAR(reconDone),false];
_HQ setVariable [QGVAR(defDone),false];
_HQ setVariable [QGVAR(reconStage),1];
_HQ setVariable [QGVAR(reconStage2),1];
_HQ setVariable [QGVAR(airInDef),[]];

_KnEnPos = [];

if (isNil (QEGVAR(missionmodules,excludedG))) then {EGVAR(missionmodules,excludedG) = []};
_HQ setVariable [QEGVAR(common,excluded),EGVAR(missionmodules,excludedG)];
if (isNil (QGVAR(fastG))) then {GVAR(fastG) = false};
_HQ setVariable [QGVAR(fast),GVAR(fastG)];
if (isNil (QGVAR(exInfoG))) then {GVAR(exInfoG) = false};
_HQ setVariable [QGVAR(exInfo),GVAR(exInfoG)];
if (isNil (QGVAR(objHoldTimeG))) then {GVAR(objHoldTimeG) = 600};
_HQ setVariable [QGVAR(objHoldTime),GVAR(objHoldTimeG)];
if (isNil QGVAR(nObjG)) then {GVAR(nObjG) = 1};
_HQ setVariable [QGVAR(nObj),GVAR(nObjG)];

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

if (isNil (QGVAR(supportWPG))) then {GVAR(supportWPG) = false};
	
_HQ setVariable [QGVAR(supportWP),GVAR(supportWPG)];

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
	
	if not (_HQ getVariable [QGVAR(fast),false]) then 
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
		if not (_lastHQ == (_HQ getVariable ["leaderHQ",objNull])) then {sleep (60 + (random 60))};
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
	
	if (isNil QEGVAR(missionmodules,garrisonG)) then {EGVAR(missionmodules,garrisonG) = []};
	_HQ setVariable [QGVAR(garrison),EGVAR(missionmodules,garrisonG)];
	
	if (isNil (QGVAR(noAirCargoG))) then {GVAR(noAirCargoG) = false};
	_HQ setVariable [QGVAR(noAirCargo),GVAR(noAirCargoG)];
	if (isNil (QGVAR(noLandCargoG))) then {GVAR(noLandCargoG) = false};
	_HQ setVariable [QGVAR(noLandCargo),GVAR(noLandCargoG)];
	if (isNil (QGVAR(lastFriendsG))) then {GVAR(lastFriendsG) = []};
	_HQ setVariable [QGVAR(lastFriends),GVAR(lastFriendsG)];
	if (isNil (QGVAR(cargoFindG))) then {GVAR(cargoFindG) = 1};
	_HQ setVariable [QGVAR(cargoFind),GVAR(cargoFindG)];
	if (isNil (QGVAR(subordinatedG))) then {GVAR(subordinatedG) = []};
	_HQ setVariable [QGVAR(subordinated),GVAR(subordinatedG)];
	if (isNil (QEGVAR(missionmodules,includedG))) then {EGVAR(missionmodules,includedG) = []};
	_HQ setVariable [QGVAR(included),EGVAR(missionmodules,includedG)];
	if (isNil (QEGVAR(missionmodules,excludedG))) then {EGVAR(missionmodules,excludedG) = []};
	_HQ setVariable [QEGVAR(common,excluded),EGVAR(missionmodules,excludedG)];
	if (isNil (QGVAR(subAllG))) then {GVAR(subAllG) = true};
	_HQ setVariable [QGVAR(subAll),GVAR(subAllG)];
	if (isNil (QGVAR(subSynchroG))) then {GVAR(subSynchroG) = false};
	_HQ setVariable [QGVAR(subSynchro),GVAR(subSynchroG)];
	if (isNil (QGVAR(subNamedG))) then {GVAR(subNamedG) = false};
	_HQ setVariable [QGVAR(subNamed),GVAR(subNamedG)];
	if (isNil (QGVAR(subZeroG))) then {GVAR(subZeroG) = false};
	_HQ setVariable [QGVAR(subZero),GVAR(subZeroG)];
	if (isNil (QGVAR(reSynchroG))) then {GVAR(reSynchroG) = true};
	_HQ setVariable [QGVAR(reSynchro),GVAR(reSynchroG)];
	if (isNil (QGVAR(nameLimitG))) then {GVAR(nameLimitG) = 100};
	_HQ setVariable [QGVAR(nameLimit),GVAR(nameLimitG)];
	if (isNil (QGVAR(surrG))) then {GVAR(surrG) = false};
	_HQ setVariable [QGVAR(surr),GVAR(surrG)];
	if (isNil (QEGVAR(missionmodules,noReconG))) then {EGVAR(missionmodules,noReconG) = []};
	_HQ setVariable [QGVAR(noRecon),EGVAR(missionmodules,noReconG)];
	if (isNil (QEGVAR(missionmodules,noAttackG))) then {EGVAR(missionmodules,noAttackG) = []};
	_HQ setVariable [QGVAR(noAttack),EGVAR(missionmodules,noAttackG)];
	if (isNil (QEGVAR(missionmodules,cargoOnlyG))) then {EGVAR(missionmodules,cargoOnlyG) = []};
	_HQ setVariable [QGVAR(cargoOnly),EGVAR(missionmodules,cargoOnlyG)];
	if (isNil (QEGVAR(missionmodules,noCargoG))) then {EGVAR(missionmodules,noCargoG) = []};
	_HQ setVariable [QGVAR(noCargo),EGVAR(missionmodules,noCargoG)];
	if (isNil (QEGVAR(missionmodules,noFlankG))) then {EGVAR(missionmodules,noFlankG) = []};
	_HQ setVariable [QGVAR(noFlank),EGVAR(missionmodules,noFlankG)];
	if (isNil (QEGVAR(missionmodules,noDefG))) then {EGVAR(missionmodules,noDefG) = []};
	_HQ setVariable [QGVAR(noDef),EGVAR(missionmodules,noDefG)];
	if (isNil (QEGVAR(missionmodules,firstToFightG))) then {EGVAR(missionmodules,firstToFightG) = []};
	_HQ setVariable [QGVAR(firstToFight),EGVAR(missionmodules,firstToFightG)];
	if (isNil (QGVAR(voiceCommG))) then {GVAR(voiceCommG) = true};
	_HQ setVariable [QGVAR(voiceComm),GVAR(voiceCommG)];
	if (isNil (QEGVAR(missionmodules,frontG))) then {EGVAR(missionmodules,frontG) = false};
	_HQ setVariable [QGVAR(frontA),EGVAR(missionmodules,frontG)];
	if (isNil (QGVAR(lRelocatingG))) then {GVAR(lRelocatingG) = false};
	_HQ setVariable [QGVAR(lRelocating),GVAR(lRelocatingG)];
	if (isNil (QGVAR(fleeG))) then {GVAR(fleeG) = true};
	_HQ setVariable [QGVAR(flee),GVAR(fleeG)];
	if (isNil (QGVAR(garrRG))) then {GVAR(garrRG) = 500};
	_HQ setVariable [QGVAR(garrR),GVAR(garrRG)];
	if (isNil (QGVAR(rushG))) then {GVAR(rushG) = false};
	_HQ setVariable [QGVAR(rush),GVAR(rushG)];
	if (isNil (QGVAR(garrVehAbG))) then {GVAR(garrVehAbG) = false};
	_HQ setVariable [QGVAR(garrVehAb),GVAR(garrVehAbG)];
	if (isNil (QGVAR(defendObjectivesG))) then {GVAR(defendObjectivesG) = 4};
	_HQ setVariable [QGVAR(defendObjectives),GVAR(defendObjectivesG)];
	if (isNil (QGVAR(defSpotG))) then {GVAR(defSpotG) = []};
	_HQ setVariable [QGVAR(defSpot),GVAR(defSpotG)];
	if (isNil (QGVAR(recDefSpotG))) then {GVAR(recDefSpotG) = []};
	_HQ setVariable [QGVAR(recDefSpot),GVAR(recDefSpotG)];
	if (isNil QGVAR(flareG)) then {GVAR(flareG) = true};
	_HQ setVariable [QGVAR(flare),GVAR(flareG)];
	if (isNil QGVAR(smokeG)) then {GVAR(smokeG) = true};
	_HQ setVariable [QGVAR(smoke),GVAR(smokeG)];
	if (isNil QGVAR(noRecG)) then {GVAR(noRecG) = 1};
	_HQ setVariable [QGVAR(noRec),GVAR(noRecG)];
	if (isNil QGVAR(rapidCaptG)) then {GVAR(rapidCaptG) = 10};
	_HQ setVariable [QGVAR(rapidCapt),GVAR(rapidCaptG)];
	if (isNil QGVAR(muuG)) then {GVAR(muuG) = 1};
	_HQ setVariable [QGVAR(muu),GVAR(muuG)];
	if (isNil QGVAR(artyShellsG)) then {GVAR(artyShellsG) = 1};
	_HQ setVariable [QGVAR(artyShells),GVAR(artyShellsG)];
	if (isNil QGVAR(withdrawG)) then {GVAR(withdrawG) = 1};
	_HQ setVariable [QGVAR(withdraw),GVAR(withdrawG)];
	if (isNil QGVAR(berserkG)) then {GVAR(berserkG) = false};
	_HQ setVariable [QGVAR(berserk),GVAR(berserkG)];
	if (isNil QEGVAR(missionmodules,iDChanceG)) then {EGVAR(missionmodules,iDChanceG) = 100};
	_HQ setVariable [QGVAR(iDChance),EGVAR(missionmodules,iDChanceG)];
	if (isNil QEGVAR(missionmodules,rDChanceG)) then {EGVAR(missionmodules,rDChanceG) = 100};
	_HQ setVariable [QGVAR(rDChance),EGVAR(missionmodules,rDChanceG)];
	if (isNil QEGVAR(missionmodules,sDChanceG)) then {EGVAR(missionmodules,sDChanceG) = 100};
	_HQ setVariable [QGVAR(sDChance),EGVAR(missionmodules,sDChanceG)];
	if (isNil QEGVAR(missionmodules,ammoDropG)) then {EGVAR(missionmodules,ammoDropG) = []};
	_HQ setVariable [QGVAR(ammoDrop),EGVAR(missionmodules,ammoDropG)];
	if (isNil QGVAR(sFTargetsG)) then {GVAR(sFTargetsG) = []};
	_HQ setVariable [QGVAR(sFTargets),GVAR(sFTargetsG)];
	if (isNil QGVAR(lZG)) then {GVAR(lZG) = false};
	_HQ setVariable [QGVAR(lZ),GVAR(lZG)];
	if (isNil QEGVAR(missionmodules,sFBodyGuardG)) then {EGVAR(missionmodules,sFBodyGuardG) = []};
	_HQ setVariable [QGVAR(sFBodyGuard),EGVAR(missionmodules,sFBodyGuardG)];
	if (isNil QGVAR(dynFormG)) then {GVAR(dynFormG) = false};
	_HQ setVariable [QGVAR(dynForm),GVAR(dynFormG)];
	if (isNil QGVAR(unlimitedCaptG)) then {GVAR(unlimitedCaptG) = false};
	_HQ setVariable [QGVAR(unlimitedCapt),GVAR(unlimitedCaptG)];
	if (isNil QGVAR(captLimitG)) then {GVAR(captLimitG) = 10};
	_HQ setVariable [QGVAR(captLimit),GVAR(captLimitG)];
	if (isNil QGVAR(getHQInsideG)) then {GVAR(getHQInsideG) = false};
	_HQ setVariable [QGVAR(getHQInside),GVAR(getHQInsideG)];
	if (isNil QGVAR(wAG)) then {GVAR(wAG) = true};
	_HQ setVariable [QGVAR(wA),GVAR(wAG)];

	if (isNil QGVAR(infoMarkersG)) then {GVAR(infoMarkersG) = false};
	_HQ setVariable [QGVAR(infoMarkers),GVAR(infoMarkersG)];
	
	if (isNil QGVAR(artyMarksG)) then {GVAR(artyMarksG) = false};
	_HQ setVariable [QGVAR(artyMarks),GVAR(artyMarksG)];
	
	if (isNil (QGVAR(resetNowG))) then {GVAR(resetNowG) = false};
	_HQ setVariable [QGVAR(resetNow),GVAR(resetNowG)];
	if (isNil (QGVAR(resetOnDemandG))) then {GVAR(resetOnDemandG) = false};
	_HQ setVariable [QGVAR(resetOnDemand),GVAR(resetOnDemandG)];
	if (isNil (QGVAR(resetTimeG))) then {GVAR(resetTimeG) = 600};
	_HQ setVariable [QGVAR(resetTime),GVAR(resetTimeG)];
	if (isNil (QGVAR(combiningG))) then {GVAR(combiningG) = false};
	_HQ setVariable [QGVAR(combining),GVAR(combiningG)];
	if (isNil (QGVAR(objRadius1G))) then {GVAR(objRadius1G) = 300};
	_HQ setVariable [QGVAR(objRadius1),GVAR(objRadius1G)];
	if (isNil (QGVAR(objRadius2G))) then {GVAR(objRadius2G) = 500};
	_HQ setVariable [QGVAR(objRadius2),GVAR(objRadius2G)];
	if (isNil (QGVAR(knowTLG))) then {GVAR(knowTLG) = true};
	_HQ setVariable [QGVAR(knowTL),GVAR(knowTLG)];
	
	if (isNil (QGVAR(sMedG))) then {GVAR(sMedG) = true};
	_HQ setVariable [QGVAR(sMed),GVAR(sMedG)];
	if (isNil (QEGVAR(missionmodules,exMedicG))) then {EGVAR(missionmodules,exMedicG) = []};
	_HQ setVariable [QGVAR(exMedic),EGVAR(missionmodules,exMedicG)];
	if (isNil (QGVAR(medPointsG))) then {GVAR(medPointsG) = []};
	_HQ setVariable [QGVAR(medPoints),GVAR(medPointsG)];
	if (isNil (QGVAR(supportedGG))) then {GVAR(supportedGG) = []};
	_HQ setVariable [QGVAR(supportedG),GVAR(supportedGG)];
		
	if (isNil (QEGVAR(missionmodules,rCASG))) then {EGVAR(missionmodules,rCASG) = []};
	_HQ setVariable [QGVAR(rCAS),EGVAR(missionmodules,rCASG)];
	if (isNil (QEGVAR(missionmodules,rCAPG))) then {EGVAR(missionmodules,rCAPG) = []};
	_HQ setVariable [QGVAR(rCAP),EGVAR(missionmodules,rCAPG)];
	
	if (isNil (QGVAR(sFuelG))) then {GVAR(sFuelG) = true};
	_HQ setVariable [QGVAR(sFuel),GVAR(sFuelG)];
	if (isNil (QEGVAR(missionmodules,exRefuelG))) then {EGVAR(missionmodules,exRefuelG) = []};
	_HQ setVariable [QGVAR(exRefuel),EGVAR(missionmodules,exRefuelG)];
	if (isNil (QGVAR(fuelPointsG))) then {GVAR(fuelPointsG) = []};
	_HQ setVariable [QGVAR(fuelPoints),GVAR(fuelPointsG)];
	if (isNil (QGVAR(fSupportedGG))) then {GVAR(fSupportedGG) = []};
	_HQ setVariable [QGVAR(fSupportedG),GVAR(fSupportedGG)];
	
	if (isNil (QGVAR(sAmmoG))) then {GVAR(sAmmoG) = true};
	_HQ setVariable [QGVAR(sAmmo),GVAR(sAmmoG)];
	if (isNil (QEGVAR(missionmodules,exReammoG))) then {EGVAR(missionmodules,exReammoG) = []};
	_HQ setVariable [QGVAR(exReammo),EGVAR(missionmodules,exReammoG)];
	if (isNil (QGVAR(ammoPointsG))) then {GVAR(ammoPointsG) = []};
	_HQ setVariable [QGVAR(ammoPoints),GVAR(ammoPointsG)];
	if (isNil (QGVAR(aSupportedGG))) then {GVAR(aSupportedGG) = []};
	_HQ setVariable [QGVAR(aSupportedG),GVAR(aSupportedGG)];
	
	if (isNil (QGVAR(sRepG))) then {GVAR(sRepG) = true};
	_HQ setVariable [QGVAR(sRep),GVAR(sRepG)];
	if (isNil (QEGVAR(missionmodules,exRepairG))) then {EGVAR(missionmodules,exRepairG) = []};
	_HQ setVariable [QGVAR(exRepair),EGVAR(missionmodules,exRepairG)];
	if (isNil (QGVAR(repPointsG))) then {GVAR(repPointsG) = []};
	_HQ setVariable [QGVAR(repPoints),GVAR(repPointsG)];
	if (isNil (QGVAR(rSupportedGG))) then {GVAR(rSupportedGG) = []};
	_HQ setVariable [QGVAR(rSupportedG),GVAR(rSupportedGG)];
	
	if (isNil QGVAR(airDistG)) then {GVAR(airDistG) = 4000};
	_HQ setVariable [QGVAR(airDist),GVAR(airDistG)];
	
	if (isNil (QGVAR(commDelayG))) then {GVAR(commDelayG) = 1};
	_HQ setVariable [QGVAR(commDelay),GVAR(commDelayG)];


	// Per-letter override (string "DEFEND") wins; fall back to shared CBA boolean.
	private _orderSrc = if (isNil (QGVAR(orderG))) then {GVAR(order)} else {GVAR(orderG)};
	private _orderDefault = ["ATTACK", "DEFEND"] select ((_orderSrc isEqualType "") || {_orderSrc});
	_HQ setVariable [QGVAR(order), _orderDefault];

	if (isNil (QGVAR(attackAlwaysG))) then {GVAR(attackAlwaysG) = false};
	_HQ setVariable [QGVAR(attackAlways),GVAR(attackAlwaysG)];

	if (isNil (QGVAR(cRDefResG))) then {GVAR(cRDefResG) = 0};
	_HQ setVariable [QGVAR(cRDefRes),GVAR(cRDefResG)];

	if (isNil (QGVAR(reconReserveG))) then {GVAR(reconReserveG) = (0.3 * (0.5 + (_HQ getVariable [QGVAR(circumspection),0.5])))};
	_HQ setVariable [QGVAR(reconReserve),GVAR(reconReserveG)];
	if (isNil (QGVAR(exhaustedG))) then {GVAR(exhaustedG) = []};
	_HQ setVariable [QGVAR(exhausted),GVAR(exhaustedG)];
	if (isNil (QGVAR(attackReserveG))) then {GVAR(attackReserveG) = (0.5 * (0.5 + ((_HQ getVariable [QGVAR(circumspection),0.5])/1.5)))};
	_HQ setVariable [QGVAR(attackReserve),GVAR(attackReserveG)];
	if (isNil (QGVAR(idleOrdG))) then {GVAR(idleOrdG) = true};
	_HQ setVariable [QGVAR(idleOrd),GVAR(idleOrdG)];

	if (isNil (QGVAR(idleDefG))) then {GVAR(idleDefG) = true};
	_HQ setVariable [QGVAR(idleDef),GVAR(idleDefG)];

	if (isNil QEGVAR(missionmodules,idleDecoyG)) then {EGVAR(missionmodules,idleDecoyG) = objNull};
	_HQ setVariable [QGVAR(idleDecoy),EGVAR(missionmodules,idleDecoyG)];
	if (isNil QEGVAR(missionmodules,supportDecoyG)) then {EGVAR(missionmodules,supportDecoyG) = objNull};
	_HQ setVariable [QGVAR(supportDecoy),EGVAR(missionmodules,supportDecoyG)]; 
	if (isNil QEGVAR(missionmodules,restDecoyG)) then {EGVAR(missionmodules,restDecoyG) = objNull};
	_HQ setVariable [QGVAR(restDecoy),EGVAR(missionmodules,restDecoyG)]; 
	if (isNil QGVAR(sec1G)) then {GVAR(sec1G) = objNull};
	_HQ setVariable [QGVAR(sec1),GVAR(sec1G)]; 
	if (isNil QGVAR(sec2G)) then {GVAR(sec2G) = objNull};
	_HQ setVariable [QGVAR(sec2),GVAR(sec2G)]; 

	if (isNil QGVAR(supportRTBG)) then {GVAR(supportRTBG) = false};
	_HQ setVariable [QGVAR(supportRTB),GVAR(supportRTBG)];
	
	if (isNil QEGVAR(common,debugG)) then {EGVAR(common,debugG) = false};
	_HQ setVariable [QEGVAR(common,debug),EGVAR(common,debugG)]; 
	if (isNil QGVAR(debugIIG)) then {GVAR(debugIIG) = false};
	_HQ setVariable [QGVAR(debugII),GVAR(debugIIG)]; 
	
	if (isNil QEGVAR(missionmodules,alwaysKnownUG)) then {EGVAR(missionmodules,alwaysKnownUG) = []};
	_HQ setVariable [QGVAR(alwaysKnownU),EGVAR(missionmodules,alwaysKnownUG)];
	if (isNil QEGVAR(missionmodules,alwaysUnKnownUG)) then {EGVAR(missionmodules,alwaysUnKnownUG) = []};
	_HQ setVariable [QGVAR(alwaysUnKnownU),EGVAR(missionmodules,alwaysUnKnownUG)];

	if (isNil QEGVAR(missionmodules,aOnlyG)) then {EGVAR(missionmodules,aOnlyG) = []};
	_HQ setVariable [QGVAR(aOnly),EGVAR(missionmodules,aOnlyG)];
	if (isNil QEGVAR(missionmodules,rOnlyG)) then {EGVAR(missionmodules,rOnlyG) = []};
	_HQ setVariable [QGVAR(rOnly),EGVAR(missionmodules,rOnlyG)]; 
	
	if (isNil QGVAR(airEvacG)) then {GVAR(airEvacG) = false};
	_HQ setVariable [QGVAR(airEvac),GVAR(airEvacG)]; 
	
	if (isNil QGVAR(aAOG)) then {GVAR(aAOG) = false};
	_HQ setVariable [QGVAR(aAO),GVAR(aAOG)]; 
	if (isNil QGVAR(forceAAOG)) then {GVAR(forceAAOG) = false};
	_HQ setVariable [QGVAR(forceAAO),GVAR(forceAAOG)];
	

	if (isNil QGVAR(bBAOObjG)) then {GVAR(bBAOObjG) = 1};
	_HQ setVariable [QGVAR(bBAOObj),GVAR(bBAOObjG)]; 
	
	if (isNil (QGVAR(moraleConstG))) then {GVAR(moraleConstG) = 1};
	_HQ setVariable [QGVAR(moraleConst),GVAR(moraleConstG)];
	
	if (isNil (QGVAR(offTendG))) then {GVAR(offTendG) = 1};
	_HQ setVariable [QGVAR(offTend),GVAR(offTendG)];
	
	if (isNil QGVAR(eBDoctrineG)) then {GVAR(eBDoctrineG) = false};
	_HQ setVariable [QGVAR(eBDoctrine),GVAR(eBDoctrineG)]; 
	if (isNil QGVAR(forceEBDoctrineG)) then {GVAR(forceEBDoctrineG) = false};
	_HQ setVariable [QGVAR(forceEBDoctrine),GVAR(forceEBDoctrineG)]; 
	
	if (isNil QGVAR(defRangeG)) then {GVAR(defRangeG) = 1};
	_HQ setVariable [QGVAR(defRange),GVAR(defRangeG)];
	if (isNil QGVAR(garrRangeG)) then {GVAR(garrRangeG) = 1};
	_HQ setVariable [QGVAR(garrRange),GVAR(garrRangeG)];
	
	if (isNil QGVAR(noCaptG)) then {GVAR(noCaptG) = []};
	_HQ setVariable [QGVAR(noCapt),GVAR(noCapt)];
	
	if (isNil QGVAR(attInfDistanceG)) then {GVAR(attInfDistanceG) = 1};
	_HQ setVariable [QGVAR(attInfDistance),GVAR(attInfDistanceG)];
	if (isNil QGVAR(attArmDistanceG)) then {GVAR(attArmDistanceG) = 1};
	_HQ setVariable [QGVAR(attArmDistance),GVAR(attArmDistanceG)];
	if (isNil QGVAR(attSnpDistanceG)) then {GVAR(attSnpDistanceG) = 1};
	_HQ setVariable [QGVAR(attSnpDistance),GVAR(attSnpDistanceG)];
	if (isNil QGVAR(captureDistanceG)) then {GVAR(captureDistanceG) = 1};
	_HQ setVariable [QGVAR(captureDistance),GVAR(captureDistanceG)];	
	if (isNil QGVAR(flankDistanceG)) then {GVAR(flankDistanceG) = 1};
	_HQ setVariable [QGVAR(flankDistance),GVAR(flankDistanceG)];
	if (isNil QGVAR(attSFDistanceG)) then {GVAR(attSFDistanceG) = 1};
	_HQ setVariable [QGVAR(attSFDistance),GVAR(attSFDistanceG)];
	if (isNil QGVAR(reconDistanceG)) then {GVAR(reconDistanceG) = 1};
	_HQ setVariable [QGVAR(reconDistance),GVAR(reconDistanceG)];
	if (isNil QGVAR(uAVAltG)) then {GVAR(uAVAltG) = 150};
	_HQ setVariable [QEGVAR(common,uAVAlt),GVAR(uAVAltG)];
	
	if (isNil QGVAR(obj1G)) then {GVAR(obj1G) = createTrigger ["EmptyDetector", leaderHQG]};
	if (isNil QGVAR(obj2G)) then {GVAR(obj2G) = createTrigger ["EmptyDetector", leaderHQG]};
	if (isNil QGVAR(obj3G)) then {GVAR(obj3G) = createTrigger ["EmptyDetector", leaderHQG]};
	if (isNil QGVAR(obj4G)) then {GVAR(obj4G) = createTrigger ["EmptyDetector", leaderHQG]};
	
	_HQ setVariable [QGVAR(obj1),GVAR(obj1G)];
	_HQ setVariable [QGVAR(obj2),GVAR(obj2G)];
	_HQ setVariable [QGVAR(obj3),GVAR(obj3G)];
	_HQ setVariable [QGVAR(obj4),GVAR(obj4G)];
	
	_objectives = [GVAR(obj1G),GVAR(obj2G),GVAR(obj3G),GVAR(obj4G)];
	_NAVObjectives = [];

	if (isNil (QGVAR(simpleModeG))) then {GVAR(simpleModeG) = true};
	_HQ setVariable [QGVAR(simpleMode),GVAR(simpleModeG)];

	if (isNil (QGVAR(secTasksG))) then {GVAR(secTasksG) = false};
	_HQ setVariable [QGVAR(secTasks),GVAR(secTasksG)];
	
	if (isNil (QEGVAR(missionmodules,simpleObjsG))) then {EGVAR(missionmodules,simpleObjsG) = []};
	_HQ setVariable [QGVAR(simpleObjs),EGVAR(missionmodules,simpleObjsG)];

	if (isNil (QEGVAR(missionmodules,navalObjsG))) then {EGVAR(missionmodules,navalObjsG) = []};
	_HQ setVariable [QGVAR(navalObjs),EGVAR(missionmodules,navalObjsG)];

	if (isNil (QGVAR(maxSimpleObjsG))) then {GVAR(maxSimpleObjsG) = 5};
	_HQ setVariable [QGVAR(maxSimpleObjs),GVAR(maxSimpleObjsG)];

	if (_HQ getVariable [QGVAR(simpleMode),false]) then {

		_objectives = EGVAR(missionmodules,simpleObjsG);
		_NAVObjectives = EGVAR(missionmodules,navalObjsG);
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
			
	if not (isNil QGVAR(defFrontLG)) then {_HQ setVariable [QGVAR(defFrontL),GVAR(defFrontLG)]};
	if not (isNil QGVAR(defFront1G)) then {_HQ setVariable [QGVAR(defFront1),GVAR(defFront1G)]};
	if not (isNil QGVAR(defFront2G)) then {_HQ setVariable [QGVAR(defFront2),GVAR(defFront2G)]};
	if not (isNil QGVAR(defFront3G)) then {_HQ setVariable [QGVAR(defFront3),GVAR(defFront3G)]};
	if not (isNil QGVAR(defFront4G)) then {_HQ setVariable [QGVAR(defFront4),GVAR(defFront4G)]};
	
	_civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];
	if not (isNil (QGVAR(civFG))) then {_civF = GVAR(civFG)};
	_HQ setVariable [QGVAR(civF),_civF];
	
	if (isNil (QGVAR(defG))) then {GVAR(defG) = []};
	_HQ setVariable [QGVAR(def),GVAR(defG)];
	
	_nObj = _HQ getVariable [QGVAR(nObj),1];

	switch (_nObj) do
		{
		case (1) : {_HQ setVariable [QGVAR(obj),GVAR(obj1G)]};
		case (2) : {_HQ setVariable [QGVAR(obj),GVAR(obj2G)]};
		case (3) : {_HQ setVariable [QGVAR(obj),GVAR(obj3G)]};
		default {_HQ setVariable [QGVAR(obj),GVAR(obj4G)]};
		};
		
	[_HQ, _cycleC, _lastReset, [], _civF] call EFUNC(hac,statusQuo);
	};
