#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/HQSitRepC.sqf

_SCRname = "SitRepC";
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

if (isNil (QGVAR(mAttC))) then {GVAR(mAttC) = false};
_HQ setVariable [QGVAR(mAtt),GVAR(mAttC)];
if ((isNil (QGVAR(personalityC))) or not (_HQ getVariable [QGVAR(mAtt),false])) then {GVAR(personalityC) = "OTHER"};
_HQ setVariable [QGVAR(personality),GVAR(personalityC)];

if (isNil (QGVAR(recklessnessC))) then {GVAR(recklessnessC) = 0.5};
_HQ setVariable [QGVAR(recklessness),GVAR(recklessnessC)];
if (isNil (QGVAR(consistencyC))) then {GVAR(consistencyC) = 0.5};
_HQ setVariable [QGVAR(consistency),GVAR(consistencyC)];
if (isNil (QGVAR(activityC))) then {GVAR(activityC) = 0.5};
_HQ setVariable [QGVAR(activity),GVAR(activityC)];
if (isNil (QGVAR(reflexC))) then {GVAR(reflexC) = 0.5};
_HQ setVariable [QGVAR(reflex),GVAR(reflexC)];
if (isNil (QGVAR(circumspectionC))) then {GVAR(circumspectionC) = 0.5};
_HQ setVariable [QGVAR(circumspection),GVAR(circumspectionC)];
if (isNil (QGVAR(finenessC))) then {GVAR(finenessC) = 0.5};
_HQ setVariable [QGVAR(fineness),GVAR(finenessC)];

[_HQ] call FUNC(personality);

[[_HQ],EFUNC(hac,lhq)] call EFUNC(common,spawn);

if (isNil (QGVAR(boxedC))) then {GVAR(boxedC) = []};
_HQ setVariable [QGVAR(boxed),GVAR(boxedC)];

if (isNil (QEGVAR(missionmodules,ammoBoxesC))) then
	{
	EGVAR(missionmodules,ammoBoxesC) = [];

	if not (isNil QEGVAR(missionmodules,ammoDepotC)) then
		{
		_rds = (triggerArea EGVAR(missionmodules,ammoDepotC)) select 0;
		EGVAR(missionmodules,ammoBoxesC) = (getPosATL EGVAR(missionmodules,ammoDepotC)) nearObjects ["ReammoBox_F",_rds]
		}
	};

_HQ setVariable [QGVAR(ammoBoxes),EGVAR(missionmodules,ammoBoxesC)];

_HQ setVariable [QGVAR(reconDone),false];
_HQ setVariable [QGVAR(defDone),false];
_HQ setVariable [QGVAR(reconStage),1];
_HQ setVariable [QGVAR(reconStage2),1];
_HQ setVariable [QGVAR(airInDef),[]];

_KnEnPos = [];

if (isNil (QEGVAR(missionmodules,excludedC))) then {EGVAR(missionmodules,excludedC) = []};
_HQ setVariable [QEGVAR(common,excluded),EGVAR(missionmodules,excludedC)];
if (isNil (QGVAR(fastC))) then {GVAR(fastC) = false};
_HQ setVariable [QGVAR(fast),GVAR(fastC)];
if (isNil (QGVAR(exInfoC))) then {GVAR(exInfoC) = false};
_HQ setVariable [QGVAR(exInfo),GVAR(exInfoC)];
if (isNil (QGVAR(objHoldTimeC))) then {GVAR(objHoldTimeC) = 600};
_HQ setVariable [QGVAR(objHoldTime),GVAR(objHoldTimeC)];
if (isNil QGVAR(nObjC)) then {GVAR(nObjC) = 1};
_HQ setVariable [QGVAR(nObj),GVAR(nObjC)];

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

if (isNil (QGVAR(supportWPC))) then {GVAR(supportWPC) = false};
	
_HQ setVariable [QGVAR(supportWP),GVAR(supportWPC)];

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
	
	if (isNil QEGVAR(missionmodules,garrisonC)) then {EGVAR(missionmodules,garrisonC) = []};
	_HQ setVariable [QGVAR(garrison),EGVAR(missionmodules,garrisonC)];
	
	if (isNil (QGVAR(noAirCargoC))) then {GVAR(noAirCargoC) = false};
	_HQ setVariable [QGVAR(noAirCargo),GVAR(noAirCargoC)];
	if (isNil (QGVAR(noLandCargoC))) then {GVAR(noLandCargoC) = false};
	_HQ setVariable [QGVAR(noLandCargo),GVAR(noLandCargoC)];
	if (isNil (QGVAR(lastFriendsC))) then {GVAR(lastFriendsC) = []};
	_HQ setVariable [QGVAR(lastFriends),GVAR(lastFriendsC)];
	if (isNil (QGVAR(cargoFindC))) then {GVAR(cargoFindC) = 1};
	_HQ setVariable [QGVAR(cargoFind),GVAR(cargoFindC)];
	if (isNil (QGVAR(subordinatedC))) then {GVAR(subordinatedC) = []};
	_HQ setVariable [QGVAR(subordinated),GVAR(subordinatedC)];
	if (isNil (QEGVAR(missionmodules,includedC))) then {EGVAR(missionmodules,includedC) = []};
	_HQ setVariable [QGVAR(included),EGVAR(missionmodules,includedC)];
	if (isNil (QEGVAR(missionmodules,excludedC))) then {EGVAR(missionmodules,excludedC) = []};
	_HQ setVariable [QEGVAR(common,excluded),EGVAR(missionmodules,excludedC)];
	if (isNil (QGVAR(subAllC))) then {GVAR(subAllC) = true};
	_HQ setVariable [QGVAR(subAll),GVAR(subAllC)];
	if (isNil (QGVAR(subSynchroC))) then {GVAR(subSynchroC) = false};
	_HQ setVariable [QGVAR(subSynchro),GVAR(subSynchroC)];
	if (isNil (QGVAR(subNamedC))) then {GVAR(subNamedC) = false};
	_HQ setVariable [QGVAR(subNamed),GVAR(subNamedC)];
	if (isNil (QGVAR(subZeroC))) then {GVAR(subZeroC) = false};
	_HQ setVariable [QGVAR(subZero),GVAR(subZeroC)];
	if (isNil (QGVAR(reSynchroC))) then {GVAR(reSynchroC) = true};
	_HQ setVariable [QGVAR(reSynchro),GVAR(reSynchroC)];
	if (isNil (QGVAR(nameLimitC))) then {GVAR(nameLimitC) = 100};
	_HQ setVariable [QGVAR(nameLimit),GVAR(nameLimitC)];
	if (isNil (QGVAR(surrC))) then {GVAR(surrC) = false};
	_HQ setVariable [QGVAR(surr),GVAR(surrC)];
	if (isNil (QEGVAR(missionmodules,noReconC))) then {EGVAR(missionmodules,noReconC) = []};
	_HQ setVariable [QGVAR(noRecon),EGVAR(missionmodules,noReconC)];
	if (isNil (QEGVAR(missionmodules,noAttackC))) then {EGVAR(missionmodules,noAttackC) = []};
	_HQ setVariable [QGVAR(noAttack),EGVAR(missionmodules,noAttackC)];
	if (isNil (QEGVAR(missionmodules,cargoOnlyC))) then {EGVAR(missionmodules,cargoOnlyC) = []};
	_HQ setVariable [QGVAR(cargoOnly),EGVAR(missionmodules,cargoOnlyC)];
	if (isNil (QEGVAR(missionmodules,noCargoC))) then {EGVAR(missionmodules,noCargoC) = []};
	_HQ setVariable [QGVAR(noCargo),EGVAR(missionmodules,noCargoC)];
	if (isNil (QEGVAR(missionmodules,noFlankC))) then {EGVAR(missionmodules,noFlankC) = []};
	_HQ setVariable [QGVAR(noFlank),EGVAR(missionmodules,noFlankC)];
	if (isNil (QEGVAR(missionmodules,noDefC))) then {EGVAR(missionmodules,noDefC) = []};
	_HQ setVariable [QGVAR(noDef),EGVAR(missionmodules,noDefC)];
	if (isNil (QEGVAR(missionmodules,firstToFightC))) then {EGVAR(missionmodules,firstToFightC) = []};
	_HQ setVariable [QGVAR(firstToFight),EGVAR(missionmodules,firstToFightC)];
	if (isNil (QGVAR(voiceCommC))) then {GVAR(voiceCommC) = true};
	_HQ setVariable [QGVAR(voiceComm),GVAR(voiceCommC)];
	if (isNil (QEGVAR(missionmodules,frontC))) then {EGVAR(missionmodules,frontC) = false};
	_HQ setVariable [QGVAR(frontA),EGVAR(missionmodules,frontC)];
	if (isNil (QGVAR(lRelocatingC))) then {GVAR(lRelocatingC) = false};
	_HQ setVariable [QGVAR(lRelocating),GVAR(lRelocatingC)];
	if (isNil (QGVAR(fleeC))) then {GVAR(fleeC) = true};
	_HQ setVariable [QGVAR(flee),GVAR(fleeC)];
	if (isNil (QGVAR(garrRC))) then {GVAR(garrRC) = 500};
	_HQ setVariable [QGVAR(garrR),GVAR(garrRC)];
	if (isNil (QGVAR(rushC))) then {GVAR(rushC) = false};
	_HQ setVariable [QGVAR(rush),GVAR(rushC)];
	if (isNil (QGVAR(garrVehAbC))) then {GVAR(garrVehAbC) = false};
	_HQ setVariable [QGVAR(garrVehAb),GVAR(garrVehAbC)];
	if (isNil (QGVAR(defendObjectivesC))) then {GVAR(defendObjectivesC) = 4};
	_HQ setVariable [QGVAR(defendObjectives),GVAR(defendObjectivesC)];
	if (isNil (QGVAR(defSpotC))) then {GVAR(defSpotC) = []};
	_HQ setVariable [QGVAR(defSpot),GVAR(defSpotC)];
	if (isNil (QGVAR(recDefSpotC))) then {GVAR(recDefSpotC) = []};
	_HQ setVariable [QGVAR(recDefSpot),GVAR(recDefSpotC)];
	if (isNil QGVAR(flareC)) then {GVAR(flareC) = true};
	_HQ setVariable [QGVAR(flare),GVAR(flareC)];
	if (isNil QGVAR(smokeC)) then {GVAR(smokeC) = true};
	_HQ setVariable [QGVAR(smoke),GVAR(smokeC)];
	if (isNil QGVAR(noRecC)) then {GVAR(noRecC) = 1};
	_HQ setVariable [QGVAR(noRec),GVAR(noRecC)];
	if (isNil QGVAR(rapidCaptC)) then {GVAR(rapidCaptC) = 10};
	_HQ setVariable [QGVAR(rapidCapt),GVAR(rapidCaptC)];
	if (isNil QGVAR(muuC)) then {GVAR(muuC) = 1};
	_HQ setVariable [QGVAR(muu),GVAR(muuC)];
	if (isNil QGVAR(artyShellsC)) then {GVAR(artyShellsC) = 1};
	_HQ setVariable [QGVAR(artyShells),GVAR(artyShellsC)];
	if (isNil QGVAR(withdrawC)) then {GVAR(withdrawC) = 1};
	_HQ setVariable [QGVAR(withdraw),GVAR(withdrawC)];
	if (isNil QGVAR(berserkC)) then {GVAR(berserkC) = false};
	_HQ setVariable [QGVAR(berserk),GVAR(berserkC)];
	if (isNil QEGVAR(missionmodules,iDChanceC)) then {EGVAR(missionmodules,iDChanceC) = 100};
	_HQ setVariable [QGVAR(iDChance),EGVAR(missionmodules,iDChanceC)];
	if (isNil QEGVAR(missionmodules,rDChanceC)) then {EGVAR(missionmodules,rDChanceC) = 100};
	_HQ setVariable [QGVAR(rDChance),EGVAR(missionmodules,rDChanceC)];
	if (isNil QEGVAR(missionmodules,sDChanceC)) then {EGVAR(missionmodules,sDChanceC) = 100};
	_HQ setVariable [QGVAR(sDChance),EGVAR(missionmodules,sDChanceC)];
	if (isNil QEGVAR(missionmodules,ammoDropC)) then {EGVAR(missionmodules,ammoDropC) = []};
	_HQ setVariable [QGVAR(ammoDrop),EGVAR(missionmodules,ammoDropC)];
	if (isNil QGVAR(sFTargetsC)) then {GVAR(sFTargetsC) = []};
	_HQ setVariable [QGVAR(sFTargets),GVAR(sFTargetsC)];
	if (isNil QGVAR(lZC)) then {GVAR(lZC) = false};
	_HQ setVariable [QGVAR(lZ),GVAR(lZC)];
	if (isNil QEGVAR(missionmodules,sFBodyGuardC)) then {EGVAR(missionmodules,sFBodyGuardC) = []};
	_HQ setVariable [QGVAR(sFBodyGuard),EGVAR(missionmodules,sFBodyGuardC)];
	if (isNil QGVAR(dynFormC)) then {GVAR(dynFormC) = false};
	_HQ setVariable [QGVAR(dynForm),GVAR(dynFormC)];
	if (isNil QGVAR(unlimitedCaptC)) then {GVAR(unlimitedCaptC) = false};
	_HQ setVariable [QGVAR(unlimitedCapt),GVAR(unlimitedCaptC)];
	if (isNil QGVAR(captLimitC)) then {GVAR(captLimitC) = 10};
	_HQ setVariable [QGVAR(captLimit),GVAR(captLimitC)];
	if (isNil QGVAR(getHQInsideC)) then {GVAR(getHQInsideC) = false};
	_HQ setVariable [QGVAR(getHQInside),GVAR(getHQInsideC)];
	if (isNil QGVAR(wAC)) then {GVAR(wAC) = true};
	_HQ setVariable [QGVAR(wA),GVAR(wAC)];

	if (isNil QGVAR(infoMarkersC)) then {GVAR(infoMarkersC) = false};
	_HQ setVariable [QGVAR(infoMarkers),GVAR(infoMarkersC)];

	if (isNil QGVAR(artyMarksC)) then {GVAR(artyMarksC) = false};
	_HQ setVariable [QGVAR(artyMarks),GVAR(artyMarksC)];
		
	if (isNil (QGVAR(resetNowC))) then {GVAR(resetNowC) = false};
	_HQ setVariable [QGVAR(resetNow),GVAR(resetNowC)];
	if (isNil (QGVAR(resetOnDemandC))) then {GVAR(resetOnDemandC) = false};
	_HQ setVariable [QGVAR(resetOnDemand),GVAR(resetOnDemandC)];
	if (isNil (QGVAR(resetTimeC))) then {GVAR(resetTimeC) = 600};
	_HQ setVariable [QGVAR(resetTime),GVAR(resetTimeC)];
	if (isNil (QGVAR(combiningC))) then {GVAR(combiningC) = false};
	_HQ setVariable [QGVAR(combining),GVAR(combiningC)];
	if (isNil (QGVAR(objRadius1C))) then {GVAR(objRadius1C) = 300};
	_HQ setVariable [QGVAR(objRadius1),GVAR(objRadius1C)];
	if (isNil (QGVAR(objRadius2C))) then {GVAR(objRadius2C) = 500};
	_HQ setVariable [QGVAR(objRadius2),GVAR(objRadius2C)];
	if (isNil (QGVAR(knowTLC))) then {GVAR(knowTLC) = true};
	_HQ setVariable [QGVAR(knowTL),GVAR(knowTLC)];
	
	if (isNil (QGVAR(sMedC))) then {GVAR(sMedC) = true};
	_HQ setVariable [QGVAR(sMed),GVAR(sMedC)];
	if (isNil (QEGVAR(missionmodules,exMedicC))) then {EGVAR(missionmodules,exMedicC) = []};
	_HQ setVariable [QGVAR(exMedic),EGVAR(missionmodules,exMedicC)];
	if (isNil (QGVAR(medPointsC))) then {GVAR(medPointsC) = []};
	_HQ setVariable [QGVAR(medPoints),GVAR(medPointsC)];
	if (isNil (QGVAR(supportedGC))) then {GVAR(supportedGC) = []};
	_HQ setVariable [QGVAR(supportedG),GVAR(supportedGC)];
	
	if (isNil (QEGVAR(missionmodules,rCASC))) then {EGVAR(missionmodules,rCASC) = []};
	_HQ setVariable [QGVAR(rCAS),EGVAR(missionmodules,rCASC)];
	if (isNil (QEGVAR(missionmodules,rCAPC))) then {EGVAR(missionmodules,rCAPC) = []};
	_HQ setVariable [QGVAR(rCAP),EGVAR(missionmodules,rCAPC)];

	if (isNil (QGVAR(sFuelC))) then {GVAR(sFuelC) = true};
	_HQ setVariable [QGVAR(sFuel),GVAR(sFuelC)];
	if (isNil (QEGVAR(missionmodules,exRefuelC))) then {EGVAR(missionmodules,exRefuelC) = []};
	_HQ setVariable [QGVAR(exRefuel),EGVAR(missionmodules,exRefuelC)];
	if (isNil (QGVAR(fuelPointsC))) then {GVAR(fuelPointsC) = []};
	_HQ setVariable [QGVAR(fuelPoints),GVAR(fuelPointsC)];
	if (isNil (QGVAR(fSupportedGC))) then {GVAR(fSupportedGC) = []};
	_HQ setVariable [QGVAR(fSupportedG),GVAR(fSupportedGC)];
	
	if (isNil (QGVAR(sAmmoC))) then {GVAR(sAmmoC) = true};
	_HQ setVariable [QGVAR(sAmmo),GVAR(sAmmoC)];
	if (isNil (QEGVAR(missionmodules,exReammoC))) then {EGVAR(missionmodules,exReammoC) = []};
	_HQ setVariable [QGVAR(exReammo),EGVAR(missionmodules,exReammoC)];
	if (isNil (QGVAR(ammoPointsC))) then {GVAR(ammoPointsC) = []};
	_HQ setVariable [QGVAR(ammoPoints),GVAR(ammoPointsC)];
	if (isNil (QGVAR(aSupportedGC))) then {GVAR(aSupportedGC) = []};
	_HQ setVariable [QGVAR(aSupportedG),GVAR(aSupportedGC)];
	
	if (isNil (QGVAR(sRepC))) then {GVAR(sRepC) = true};
	_HQ setVariable [QGVAR(sRep),GVAR(sRepC)];
	if (isNil (QEGVAR(missionmodules,exRepairC))) then {EGVAR(missionmodules,exRepairC) = []};
	_HQ setVariable [QGVAR(exRepair),EGVAR(missionmodules,exRepairC)];
	if (isNil (QGVAR(repPointsC))) then {GVAR(repPointsC) = []};
	_HQ setVariable [QGVAR(repPoints),GVAR(repPointsC)];
	if (isNil (QGVAR(rSupportedGC))) then {GVAR(rSupportedGC) = []};
	_HQ setVariable [QGVAR(rSupportedG),GVAR(rSupportedGC)];
	
	if (isNil QGVAR(airDistC)) then {GVAR(airDistC) = 4000};
	_HQ setVariable [QGVAR(airDist),GVAR(airDistC)];
	
	if (isNil (QGVAR(commDelayC))) then {GVAR(commDelayC) = 1};
	_HQ setVariable [QGVAR(commDelay),GVAR(commDelayC)];


	// Per-letter override (string "DEFEND") wins; fall back to shared CBA boolean.
	private _orderSrc = if (isNil (QGVAR(orderC))) then {GVAR(order)} else {GVAR(orderC)};
	private _orderDefault = ["ATTACK", "DEFEND"] select ((_orderSrc isEqualType "") || {_orderSrc});
	_HQ setVariable [QGVAR(order), _orderDefault];

	if (isNil (QGVAR(attackAlwaysC))) then {GVAR(attackAlwaysC) = false};
	_HQ setVariable [QGVAR(attackAlways),GVAR(attackAlwaysC)];

	if (isNil (QGVAR(cRDefResC))) then {GVAR(cRDefResC) = 0};
	_HQ setVariable [QGVAR(cRDefRes),GVAR(cRDefResC)];

	if (isNil (QGVAR(reconReserveC))) then {GVAR(reconReserveC) = (0.3 * (0.5 + (_HQ getVariable [QGVAR(circumspection),0.5])))};
	_HQ setVariable [QGVAR(reconReserve),GVAR(reconReserveC)];
	if (isNil (QGVAR(exhaustedC))) then {GVAR(exhaustedC) = []};
	_HQ setVariable [QGVAR(exhausted),GVAR(exhaustedC)];
	if (isNil (QGVAR(attackReserveC))) then {GVAR(attackReserveC) = (0.5 * (0.5 + ((_HQ getVariable [QGVAR(circumspection),0.5])/1.5)))};
	_HQ setVariable [QGVAR(attackReserve),GVAR(attackReserveC)];
	if (isNil (QGVAR(idleOrdC))) then {GVAR(idleOrdC) = true};
	_HQ setVariable [QGVAR(idleOrd),GVAR(idleOrdC)];
	
	if (isNil (QGVAR(idleDefC))) then {GVAR(idleDefC) = true};
	_HQ setVariable [QGVAR(idleDef),GVAR(idleDefC)];

	if (isNil QEGVAR(missionmodules,idleDecoyC)) then {EGVAR(missionmodules,idleDecoyC) = objNull};
	_HQ setVariable [QGVAR(idleDecoy),EGVAR(missionmodules,idleDecoyC)];
	if (isNil QEGVAR(missionmodules,supportDecoyC)) then {EGVAR(missionmodules,supportDecoyC) = objNull};
	_HQ setVariable [QGVAR(supportDecoy),EGVAR(missionmodules,supportDecoyC)]; 
	if (isNil QEGVAR(missionmodules,restDecoyC)) then {EGVAR(missionmodules,restDecoyC) = objNull};
	_HQ setVariable [QGVAR(restDecoy),EGVAR(missionmodules,restDecoyC)]; 
	if (isNil QGVAR(sec1C)) then {GVAR(sec1C) = objNull};
	_HQ setVariable [QGVAR(sec1),GVAR(sec1C)]; 
	if (isNil QGVAR(sec2C)) then {GVAR(sec2C) = objNull};
	_HQ setVariable [QGVAR(sec2),GVAR(sec2C)];

	if (isNil QGVAR(supportRTBC)) then {GVAR(supportRTBC) = false};
	_HQ setVariable [QGVAR(supportRTB),GVAR(supportRTBC)];
	
	if (isNil QEGVAR(common,debugC)) then {EGVAR(common,debugC) = false};
	_HQ setVariable [QEGVAR(common,debug),EGVAR(common,debugC)]; 
	if (isNil QGVAR(debugIIC)) then {GVAR(debugIIC) = false};
	_HQ setVariable [QGVAR(debugII),GVAR(debugIIC)]; 
	
	if (isNil QEGVAR(missionmodules,alwaysKnownUC)) then {EGVAR(missionmodules,alwaysKnownUC) = []};
	_HQ setVariable [QGVAR(alwaysKnownU),EGVAR(missionmodules,alwaysKnownUC)];
	if (isNil QEGVAR(missionmodules,alwaysUnKnownUC)) then {EGVAR(missionmodules,alwaysUnKnownUC) = []};
	_HQ setVariable [QGVAR(alwaysUnKnownU),EGVAR(missionmodules,alwaysUnKnownUC)];

	if (isNil QEGVAR(missionmodules,aOnlyC)) then {EGVAR(missionmodules,aOnlyC) = []};
	_HQ setVariable [QGVAR(aOnly),EGVAR(missionmodules,aOnlyC)];
	if (isNil QEGVAR(missionmodules,rOnlyC)) then {EGVAR(missionmodules,rOnlyC) = []};
	_HQ setVariable [QGVAR(rOnly),EGVAR(missionmodules,rOnlyC)]; 
	
	if (isNil QGVAR(airEvacC)) then {GVAR(airEvacC) = false};
	_HQ setVariable [QGVAR(airEvac),GVAR(airEvacC)];
	
	if (isNil QGVAR(aAOC)) then {GVAR(aAOC) = false};
	_HQ setVariable [QGVAR(aAO),GVAR(aAOC)]; 
	if (isNil QGVAR(forceAAOC)) then {GVAR(forceAAOC) = false};
	_HQ setVariable [QGVAR(forceAAO),GVAR(forceAAOC)]; 
	
	if (isNil QGVAR(bBAOObjC)) then {GVAR(bBAOObjC) = 1};
	_HQ setVariable [QGVAR(bBAOObj),GVAR(bBAOObjC)]; 

	if (isNil (QGVAR(moraleConstC))) then {GVAR(moraleConstC) = 1};
	_HQ setVariable [QGVAR(moraleConst),GVAR(moraleConstC)];
	
	if (isNil (QGVAR(offTendC))) then {GVAR(offTendC) = 1};
	_HQ setVariable [QGVAR(offTend),GVAR(offTendC)];
	
	if (isNil QGVAR(eBDoctrineC)) then {GVAR(eBDoctrineC) = false};
	_HQ setVariable [QGVAR(eBDoctrine),GVAR(eBDoctrineC)]; 
	if (isNil QGVAR(forceEBDoctrineC)) then {GVAR(forceEBDoctrineC) = false};
	_HQ setVariable [QGVAR(forceEBDoctrine),GVAR(forceEBDoctrineC)]; 
	
	if (isNil QGVAR(defRangeC)) then {GVAR(defRangeC) = 1};
	_HQ setVariable [QGVAR(defRange),GVAR(defRangeC)];
	if (isNil QGVAR(garrRangeC)) then {GVAR(garrRangeC) = 1};
	_HQ setVariable [QGVAR(garrRange),GVAR(garrRangeC)];

	if (isNil QGVAR(noCaptC)) then {GVAR(noCaptC) = []};
	_HQ setVariable [QGVAR(noCapt),GVAR(noCapt)];
	
	if (isNil QGVAR(attInfDistanceC)) then {GVAR(attInfDistanceC) = 1};
	_HQ setVariable [QGVAR(attInfDistance),GVAR(attInfDistanceC)];
	if (isNil QGVAR(attArmDistanceC)) then {GVAR(attArmDistanceC) = 1};
	_HQ setVariable [QGVAR(attArmDistance),GVAR(attArmDistanceC)];
	if (isNil QGVAR(attSnpDistanceC)) then {GVAR(attSnpDistanceC) = 1};
	_HQ setVariable [QGVAR(attSnpDistance),GVAR(attSnpDistanceC)];
	if (isNil QGVAR(captureDistanceC)) then {GVAR(captureDistanceC) = 1};
	_HQ setVariable [QGVAR(captureDistance),GVAR(captureDistanceC)];	
	if (isNil QGVAR(flankDistanceC)) then {GVAR(flankDistanceC) = 1};
	_HQ setVariable [QGVAR(flankDistance),GVAR(flankDistanceC)];
	if (isNil QGVAR(attSFDistanceC)) then {GVAR(attSFDistanceC) = 1};
	_HQ setVariable [QGVAR(attSFDistance),GVAR(attSFDistanceC)];
	if (isNil QGVAR(reconDistanceC)) then {GVAR(reconDistanceC) = 1};
	_HQ setVariable [QGVAR(reconDistance),GVAR(reconDistanceC)];
	if (isNil QGVAR(uAVAltC)) then {GVAR(uAVAltC) = 150};
	_HQ setVariable [QEGVAR(common,uAVAlt),GVAR(uAVAltC)];

	if (isNil QGVAR(obj1C)) then {GVAR(obj1C) = createTrigger ["EmptyDetector", leaderHQC]};
	if (isNil QGVAR(obj2C)) then {GVAR(obj2C) = createTrigger ["EmptyDetector", leaderHQC]};
	if (isNil QGVAR(obj3C)) then {GVAR(obj3C) = createTrigger ["EmptyDetector", leaderHQC]};
	if (isNil QGVAR(obj4C)) then {GVAR(obj4C) = createTrigger ["EmptyDetector", leaderHQC]};
	
	_HQ setVariable [QGVAR(obj1),GVAR(obj1C)];
	_HQ setVariable [QGVAR(obj2),GVAR(obj2C)];
	_HQ setVariable [QGVAR(obj3),GVAR(obj3C)];
	_HQ setVariable [QGVAR(obj4),GVAR(obj4C)];
	
	_objectives = [GVAR(obj1C),GVAR(obj2C),GVAR(obj3C),GVAR(obj4C)];
	_NAVObjectives = [];

	if (isNil (QGVAR(simpleModeC))) then {GVAR(simpleModeC) = true};
	_HQ setVariable [QGVAR(simpleMode),GVAR(simpleModeC)];

	if (isNil (QGVAR(secTasksC))) then {GVAR(secTasksC) = false};
	_HQ setVariable [QGVAR(secTasks),GVAR(secTasksC)];

	if (isNil (QEGVAR(missionmodules,simpleObjsC))) then {EGVAR(missionmodules,simpleObjsC) = []};
	_HQ setVariable [QGVAR(simpleObjs),EGVAR(missionmodules,simpleObjsC)];

	if (isNil (QEGVAR(missionmodules,navalObjsC))) then {EGVAR(missionmodules,navalObjsC) = []};
	_HQ setVariable [QGVAR(navalObjs),EGVAR(missionmodules,navalObjsC)];

	if (isNil (QGVAR(maxSimpleObjsC))) then {GVAR(maxSimpleObjsC) = 5};
	_HQ setVariable [QGVAR(maxSimpleObjs),GVAR(maxSimpleObjsC)];

	if (_HQ getVariable [QGVAR(simpleMode),false]) then {

		_objectives = EGVAR(missionmodules,simpleObjsC);
		_NAVObjectives = EGVAR(missionmodules,navalObjsC);
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
		
	if not (isNil QGVAR(defFrontLC)) then {_HQ setVariable [QGVAR(defFrontL),GVAR(defFrontLC)]};
	if not (isNil QGVAR(defFront1C)) then {_HQ setVariable [QGVAR(defFront1),GVAR(defFront1C)]};
	if not (isNil QGVAR(defFront2C)) then {_HQ setVariable [QGVAR(defFront2),GVAR(defFront2C)]};
	if not (isNil QGVAR(defFront3C)) then {_HQ setVariable [QGVAR(defFront3),GVAR(defFront3C)]};
	if not (isNil QGVAR(defFront4C)) then {_HQ setVariable [QGVAR(defFront4),GVAR(defFront4C)]};
	
	_civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];
	if not (isNil (QGVAR(civFC))) then {_civF = GVAR(civFC)};
	_HQ setVariable [QGVAR(civF),_civF];
	
	if (isNil (QGVAR(defC))) then {GVAR(defC) = []};
	_HQ setVariable [QGVAR(def),GVAR(defC)];
	
	_nObj = _HQ getVariable [QGVAR(nObj),1];

	switch (_nObj) do
		{
		case (1) : {_HQ setVariable [QGVAR(obj),GVAR(obj1C)]};
		case (2) : {_HQ setVariable [QGVAR(obj),GVAR(obj2C)]};
		case (3) : {_HQ setVariable [QGVAR(obj),GVAR(obj3C)]};
		default {_HQ setVariable [QGVAR(obj),GVAR(obj4C)]};
		};
		
	[_HQ, _cycleC, _lastReset, [], _civF] call EFUNC(hac,statusQuo);
	};
