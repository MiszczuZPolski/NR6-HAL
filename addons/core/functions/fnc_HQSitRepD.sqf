#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/HQSitRepD.sqf

_SCRname = "SitRepD";
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

if (isNil (QGVAR(mAttD))) then {GVAR(mAttD) = false};
_HQ setVariable [QGVAR(mAtt),GVAR(mAttD)];
if ((isNil (QGVAR(personalityD))) or not (_HQ getVariable [QGVAR(mAtt),false])) then {GVAR(personalityD) = "OTHER"};
_HQ setVariable [QGVAR(personality),GVAR(personalityD)];

if (isNil (QGVAR(recklessnessD))) then {GVAR(recklessnessD) = 0.5};
_HQ setVariable [QGVAR(recklessness),GVAR(recklessnessD)];
if (isNil (QGVAR(consistencyD))) then {GVAR(consistencyD) = 0.5};
_HQ setVariable [QGVAR(consistency),GVAR(consistencyD)];
if (isNil (QGVAR(activityD))) then {GVAR(activityD) = 0.5};
_HQ setVariable [QGVAR(activity),GVAR(activityD)];
if (isNil (QGVAR(reflexD))) then {GVAR(reflexD) = 0.5};
_HQ setVariable [QGVAR(reflex),GVAR(reflexD)];
if (isNil (QGVAR(circumspectionD))) then {GVAR(circumspectionD) = 0.5};
_HQ setVariable [QGVAR(circumspection),GVAR(circumspectionD)];
if (isNil (QGVAR(finenessD))) then {GVAR(finenessD) = 0.5};
_HQ setVariable [QGVAR(fineness),GVAR(finenessD)];

[_HQ] call FUNC(personality);

[[_HQ],HAL_LHQ] call EFUNC(common,spawn);

if (isNil (QGVAR(boxedD))) then {GVAR(boxedD) = []};
_HQ setVariable [QGVAR(boxed),GVAR(boxedD)];

if (isNil (QGVAR(ammoBoxesD))) then 
	{
	GVAR(ammoBoxesD) = [];

	if not (isNil QGVAR(ammoDepotD)) then 
		{
		_rds = (triggerArea GVAR(ammoDepotD)) select 0;
		GVAR(ammoBoxesD) = (getPosATL GVAR(ammoDepotD)) nearObjects ["ReammoBox_F",_rds]
		}
	};
	
_HQ setVariable [QGVAR(ammoBoxes),GVAR(ammoBoxesD)];

_HQ setVariable [QGVAR(reconDone),false];
_HQ setVariable [QGVAR(defDone),false];
_HQ setVariable [QGVAR(reconStage),1];
_HQ setVariable [QGVAR(reconStage2),1];
_HQ setVariable [QGVAR(airInDef),[]];

_KnEnPos = [];

if (isNil (QGVAR(excludedD))) then {GVAR(excludedD) = []};
_HQ setVariable [QEGVAR(common,excluded),GVAR(excludedD)];
if (isNil (QGVAR(fastD))) then {GVAR(fastD) = false};
_HQ setVariable [QGVAR(fast),GVAR(fastD)];
if (isNil (QGVAR(exInfoD))) then {GVAR(exInfoD) = false};
_HQ setVariable [QGVAR(exInfo),GVAR(exInfoD)];
if (isNil (QGVAR(objHoldTimeD))) then {GVAR(objHoldTimeD) = 600};
_HQ setVariable [QGVAR(objHoldTime),GVAR(objHoldTimeD)];
if (isNil QGVAR(nObjD)) then {GVAR(nObjD) = 1};
_HQ setVariable [QGVAR(nObj),GVAR(nObjD)];

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

if (isNil (QGVAR(supportWPD))) then {GVAR(supportWPD) = false};
	
_HQ setVariable [QGVAR(supportWP),GVAR(supportWPD)];

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
	
	if (isNil QGVAR(garrisonD)) then {GVAR(garrisonD) = []};
	_HQ setVariable [QGVAR(garrison),GVAR(garrisonD)];
	
	if (isNil (QGVAR(noAirCargoD))) then {GVAR(noAirCargoD) = false};
	_HQ setVariable [QGVAR(noAirCargo),GVAR(noAirCargoD)];
	if (isNil (QGVAR(noLandCargoD))) then {GVAR(noLandCargoD) = false};
	_HQ setVariable [QGVAR(noLandCargo),GVAR(noLandCargoD)];
	if (isNil (QGVAR(lastFriendsD))) then {GVAR(lastFriendsD) = []};
	_HQ setVariable [QGVAR(lastFriends),GVAR(lastFriendsD)];
	if (isNil (QGVAR(cargoFindD))) then {GVAR(cargoFindD) = 1};
	_HQ setVariable [QGVAR(cargoFind),GVAR(cargoFindD)];
	if (isNil (QGVAR(subordinatedD))) then {GVAR(subordinatedD) = []};
	_HQ setVariable [QGVAR(subordinated),GVAR(subordinatedD)];
	if (isNil (QGVAR(includedD))) then {GVAR(includedD) = []};
	_HQ setVariable [QGVAR(included),GVAR(includedD)];
	if (isNil (QGVAR(excludedD))) then {GVAR(excludedD) = []};
	_HQ setVariable [QEGVAR(common,excluded),GVAR(excludedD)];
	if (isNil (QGVAR(subAllD))) then {GVAR(subAllD) = true};
	_HQ setVariable [QGVAR(subAll),GVAR(subAllD)];
	if (isNil (QGVAR(subSynchroD))) then {GVAR(subSynchroD) = false};
	_HQ setVariable [QGVAR(subSynchro),GVAR(subSynchroD)];
	if (isNil (QGVAR(subNamedD))) then {GVAR(subNamedD) = false};
	_HQ setVariable [QGVAR(subNamed),GVAR(subNamedD)];
	if (isNil (QGVAR(subZeroD))) then {GVAR(subZeroD) = false};
	_HQ setVariable [QGVAR(subZero),GVAR(subZeroD)];
	if (isNil (QGVAR(reSynchroD))) then {GVAR(reSynchroD) = true};
	_HQ setVariable [QGVAR(reSynchro),GVAR(reSynchroD)];
	if (isNil (QGVAR(nameLimitD))) then {GVAR(nameLimitD) = 100};
	_HQ setVariable [QGVAR(nameLimit),GVAR(nameLimitD)];
	if (isNil (QGVAR(surrD))) then {GVAR(surrD) = false};
	_HQ setVariable [QGVAR(surr),GVAR(surrD)];
	if (isNil (QGVAR(noReconD))) then {GVAR(noReconD) = []};
	_HQ setVariable [QGVAR(noRecon),GVAR(noReconD)];
	if (isNil (QGVAR(noAttackD))) then {GVAR(noAttackD) = []};
	_HQ setVariable [QGVAR(noAttack),GVAR(noAttackD)];
	if (isNil (QGVAR(cargoOnlyD))) then {GVAR(cargoOnlyD) = []};
	_HQ setVariable [QGVAR(cargoOnly),GVAR(cargoOnlyD)];
	if (isNil (QGVAR(noCargoD))) then {GVAR(noCargoD) = []};
	_HQ setVariable [QGVAR(noCargo),GVAR(noCargoD)];
	if (isNil (QGVAR(noFlankD))) then {GVAR(noFlankD) = []};
	_HQ setVariable [QGVAR(noFlank),GVAR(noFlankD)];
	if (isNil (QGVAR(noDefD))) then {GVAR(noDefD) = []};
	_HQ setVariable [QGVAR(noDef),GVAR(noDefD)];
	if (isNil (QGVAR(firstToFightD))) then {GVAR(firstToFightD) = []};
	_HQ setVariable [QGVAR(firstToFight),GVAR(firstToFightD)];
	if (isNil (QGVAR(voiceCommD))) then {GVAR(voiceCommD) = true};
	_HQ setVariable [QGVAR(voiceComm),GVAR(voiceCommD)];
	if (isNil (QGVAR(frontAD))) then {GVAR(frontD) = false};
	_HQ setVariable [QGVAR(frontA),GVAR(frontD)];
	if (isNil (QGVAR(lRelocatingD))) then {GVAR(lRelocatingD) = false};
	_HQ setVariable [QGVAR(lRelocating),GVAR(lRelocatingD)];
	if (isNil (QGVAR(fleeD))) then {GVAR(fleeD) = true};
	_HQ setVariable [QGVAR(flee),GVAR(fleeD)];
	if (isNil (QGVAR(garrRD))) then {GVAR(garrRD) = 500};
	_HQ setVariable [QGVAR(garrR),GVAR(garrRD)];
	if (isNil (QGVAR(rushD))) then {GVAR(rushD) = false};
	_HQ setVariable [QGVAR(rush),GVAR(rushD)];
	if (isNil (QGVAR(garrVehAbD))) then {GVAR(garrVehAbD) = false};
	_HQ setVariable [QGVAR(garrVehAb),GVAR(garrVehAbD)];
	if (isNil (QGVAR(defendObjectivesD))) then {GVAR(defendObjectivesD) = 4};
	_HQ setVariable [QGVAR(defendObjectives),GVAR(defendObjectivesD)];
	if (isNil (QGVAR(defSpotD))) then {GVAR(defSpotD) = []};
	_HQ setVariable [QGVAR(defSpot),GVAR(defSpotD)];
	if (isNil (QGVAR(recDefSpotD))) then {GVAR(recDefSpotD) = []};
	_HQ setVariable [QGVAR(recDefSpot),GVAR(recDefSpotD)];
	if (isNil QGVAR(flareD)) then {GVAR(flareD) = true};
	_HQ setVariable [QGVAR(flare),GVAR(flareD)];
	if (isNil QGVAR(smokeD)) then {GVAR(smokeD) = true};
	_HQ setVariable [QGVAR(smoke),GVAR(smokeD)];
	if (isNil QGVAR(noRecD)) then {GVAR(noRecD) = 1};
	_HQ setVariable [QGVAR(noRec),GVAR(noRecD)];
	if (isNil QGVAR(rapidCaptD)) then {GVAR(rapidCaptD) = 10};
	_HQ setVariable [QGVAR(rapidCapt),GVAR(rapidCaptD)];
	if (isNil QGVAR(muuD)) then {GVAR(muuD) = 1};
	_HQ setVariable [QGVAR(muu),GVAR(muuD)];
	if (isNil QGVAR(artyShellsD)) then {GVAR(artyShellsD) = 1};
	_HQ setVariable [QGVAR(artyShells),GVAR(artyShellsD)];
	if (isNil QGVAR(withdrawD)) then {GVAR(withdrawD) = 1};
	_HQ setVariable [QGVAR(withdraw),GVAR(withdrawD)];
	if (isNil QGVAR(berserkD)) then {GVAR(berserkD) = false};
	_HQ setVariable [QGVAR(berserk),GVAR(berserkD)];
	if (isNil QGVAR(iDChanceD)) then {GVAR(iDChanceD) = 100};
	_HQ setVariable [QGVAR(iDChance),GVAR(iDChanceD)];
	if (isNil QGVAR(rDChanceD)) then {GVAR(rDChanceD) = 100};
	_HQ setVariable [QGVAR(rDChance),GVAR(rDChanceD)];
	if (isNil QGVAR(sDChanceD)) then {GVAR(sDChanceD) = 100};
	_HQ setVariable [QGVAR(sDChance),GVAR(sDChanceD)];
	if (isNil QGVAR(ammoDropD)) then {GVAR(ammoDropD) = []};
	_HQ setVariable [QGVAR(ammoDrop),GVAR(ammoDropD)];
	if (isNil QGVAR(sFTargetsD)) then {GVAR(sFTargetsD) = []};
	_HQ setVariable [QGVAR(sFTargets),GVAR(sFTargetsD)];
	if (isNil QGVAR(lZD)) then {GVAR(lZD) = false};
	_HQ setVariable [QGVAR(lZ),GVAR(lZD)];
	if (isNil QGVAR(sFBodyGuardD)) then {GVAR(sFBodyGuardD) = []};
	_HQ setVariable [QGVAR(sFBodyGuard),GVAR(sFBodyGuardD)];
	if (isNil QGVAR(dynFormD)) then {GVAR(dynFormD) = false};
	_HQ setVariable [QGVAR(dynForm),GVAR(dynFormD)];
	if (isNil QGVAR(unlimitedCaptD)) then {GVAR(unlimitedCaptD) = false};
	_HQ setVariable [QGVAR(unlimitedCapt),GVAR(unlimitedCaptD)];
	if (isNil QGVAR(captLimitD)) then {GVAR(captLimitD) = 10};
	_HQ setVariable [QGVAR(captLimit),GVAR(captLimitD)];
	if (isNil QGVAR(getHQInsideD)) then {GVAR(getHQInsideD) = false};
	_HQ setVariable [QGVAR(getHQInside),GVAR(getHQInsideD)];
	if (isNil QGVAR(wAD)) then {GVAR(wAD) = true};
	_HQ setVariable [QGVAR(wA),GVAR(wAD)];

	if (isNil QGVAR(infoMarkersD)) then {GVAR(infoMarkersD) = false};
	_HQ setVariable [QGVAR(infoMarkers),GVAR(infoMarkersD)];

	if (isNil QGVAR(artyMarksD)) then {GVAR(artyMarksD) = false};
	_HQ setVariable [QGVAR(artyMarks),GVAR(artyMarksD)];
		
	if (isNil (QGVAR(resetNowD))) then {GVAR(resetNowD) = false};
	_HQ setVariable [QGVAR(resetNow),GVAR(resetNowD)];
	if (isNil (QGVAR(resetOnDemandD))) then {GVAR(resetOnDemandD) = false};
	_HQ setVariable [QGVAR(resetOnDemand),GVAR(resetOnDemandD)];
	if (isNil (QGVAR(resetTimeD))) then {GVAR(resetTimeD) = 600};
	_HQ setVariable [QGVAR(resetTime),GVAR(resetTimeD)];
	if (isNil (QGVAR(combiningD))) then {GVAR(combiningD) = false};
	_HQ setVariable [QGVAR(combining),GVAR(combiningD)];
	if (isNil (QGVAR(objRadius1D))) then {GVAR(objRadius1D) = 300};
	_HQ setVariable [QGVAR(objRadius1),GVAR(objRadius1D)];
	if (isNil (QGVAR(objRadius2D))) then {GVAR(objRadius2D) = 500};
	_HQ setVariable [QGVAR(objRadius2),GVAR(objRadius2D)];
	if (isNil (QGVAR(knowTLD))) then {GVAR(knowTLD) = true};
	_HQ setVariable [QGVAR(knowTL),GVAR(knowTLD)];
	
	if (isNil (QGVAR(sMedD))) then {GVAR(sMedD) = true};
	_HQ setVariable [QGVAR(sMed),GVAR(sMedD)];
	if (isNil (QGVAR(exMedicD))) then {GVAR(exMedicD) = []};
	_HQ setVariable [QGVAR(exMedic),GVAR(exMedicD)];
	if (isNil (QGVAR(medPointsD))) then {GVAR(medPointsD) = []};
	_HQ setVariable [QGVAR(medPoints),GVAR(medPointsD)];
	if (isNil (QGVAR(supportedGD))) then {GVAR(supportedGD) = []};
	_HQ setVariable [QGVAR(supportedG),GVAR(supportedGD)];
		
	if (isNil (QGVAR(rCASD))) then {GVAR(rCASD) = []};
	_HQ setVariable [QGVAR(rCAS),GVAR(rCASD)];
	if (isNil (QGVAR(rCAPD))) then {GVAR(rCAPD) = []};
	_HQ setVariable [QGVAR(rCAP),GVAR(rCAPD)];
	
	if (isNil (QGVAR(sFuelD))) then {GVAR(sFuelD) = true};
	_HQ setVariable [QGVAR(sFuel),GVAR(sFuelD)];
	if (isNil (QGVAR(exRefuelD))) then {GVAR(exRefuelD) = []};
	_HQ setVariable [QGVAR(exRefuel),GVAR(exRefuelD)];
	if (isNil (QGVAR(fuelPointsD))) then {GVAR(fuelPointsD) = []};
	_HQ setVariable [QGVAR(fuelPoints),GVAR(fuelPointsD)];
	if (isNil (QGVAR(fSupportedGD))) then {GVAR(fSupportedGD) = []};
	_HQ setVariable [QGVAR(fSupportedG),GVAR(fSupportedGD)];
	
	if (isNil (QGVAR(sAmmoD))) then {GVAR(sAmmoD) = true};
	_HQ setVariable [QGVAR(sAmmo),GVAR(sAmmoD)];
	if (isNil (QGVAR(exReammoD))) then {GVAR(exReammoD) = []};
	_HQ setVariable [QGVAR(exReammo),GVAR(exReammoD)];
	if (isNil (QGVAR(ammoPointsD))) then {GVAR(ammoPointsD) = []};
	_HQ setVariable [QGVAR(ammoPoints),GVAR(ammoPointsD)];
	if (isNil (QGVAR(aSupportedGD))) then {GVAR(aSupportedGD) = []};
	_HQ setVariable [QGVAR(aSupportedG),GVAR(aSupportedGD)];
	
	if (isNil (QGVAR(sRepD))) then {GVAR(sRepD) = true};
	_HQ setVariable [QGVAR(sRep),GVAR(sRepD)];
	if (isNil (QGVAR(exRepairD))) then {GVAR(exRepairD) = []};
	_HQ setVariable [QGVAR(exRepair),GVAR(exRepairD)];
	if (isNil (QGVAR(repPointsD))) then {GVAR(repPointsD) = []};
	_HQ setVariable [QGVAR(repPoints),GVAR(repPointsD)];
	if (isNil (QGVAR(rSupportedGD))) then {GVAR(rSupportedGD) = []};
	_HQ setVariable [QGVAR(rSupportedG),GVAR(rSupportedGD)];
	
	if (isNil QGVAR(airDistD)) then {GVAR(airDistD) = 4000};
	_HQ setVariable [QGVAR(airDist),GVAR(airDistD)];
	
	if (isNil (QGVAR(commDelayD))) then {GVAR(commDelayD) = 1};
	_HQ setVariable [QGVAR(commDelay),GVAR(commDelayD)];


	if ((isNil (QGVAR(orderD))) and (isNil {_HQ getVariable QGVAR(order)})) then {_HQ setVariable [QGVAR(order),"ATTACK"]};
	if ( not (isNil (QGVAR(orderD)))) then {
		if (GVAR(orderD) == "DEFEND") then {
			_HQ setVariable [QGVAR(order),"DEFEND"]
		} else {
			_HQ setVariable [QGVAR(order),"ATTACK"]
		};
	};

	if (isNil (QGVAR(attackAlwaysD))) then {GVAR(attackAlwaysD) = false};
	_HQ setVariable [QGVAR(attackAlways),GVAR(attackAlwaysD)];

	if (isNil (QGVAR(cRDefResD))) then {GVAR(cRDefResD) = 0};
	_HQ setVariable [QGVAR(cRDefRes),GVAR(cRDefResD)];

	if (isNil (QGVAR(reconReserveD))) then {GVAR(reconReserveD) = (0.3 * (0.5 + (_HQ getVariable [QGVAR(circumspection),0.5])))};
	_HQ setVariable [QGVAR(reconReserve),GVAR(reconReserveD)];
	if (isNil (QGVAR(exhaustedD))) then {GVAR(exhaustedD) = []};
	_HQ setVariable [QGVAR(exhausted),GVAR(exhaustedD)];
	if (isNil (QGVAR(attackReserveD))) then {GVAR(attackReserveD) = (0.5 * (0.5 + ((_HQ getVariable [QGVAR(circumspection),0.5])/1.5)))};
	_HQ setVariable [QGVAR(attackReserve),GVAR(attackReserveD)];
	if (isNil (QGVAR(idleOrdD))) then {GVAR(idleOrdD) = true};
	_HQ setVariable [QGVAR(idleOrd),GVAR(idleOrdD)];

	if (isNil (QGVAR(idleDefD))) then {GVAR(idleDefD) = true};
	_HQ setVariable [QGVAR(idleDef),GVAR(idleDefD)];

	if (isNil QGVAR(idleDecoyD)) then {GVAR(idleDecoyD) = objNull};
	_HQ setVariable [QGVAR(idleDecoy),GVAR(idleDecoyD)]; 
	if (isNil QGVAR(supportDecoyD)) then {GVAR(supportDecoyD) = objNull};
	_HQ setVariable [QGVAR(supportDecoy),GVAR(supportDecoyD)]; 
	if (isNil QGVAR(restDecoyD)) then {GVAR(restDecoyD) = objNull};
	_HQ setVariable [QGVAR(restDecoy),GVAR(restDecoyD)]; 
	if (isNil QGVAR(sec1D)) then {GVAR(sec1D) = objNull};
	_HQ setVariable [QGVAR(sec1),GVAR(sec1D)]; 
	if (isNil QGVAR(sec2D)) then {GVAR(sec2D) = objNull};
	_HQ setVariable [QGVAR(sec2),GVAR(sec2D)];

	if (isNil QGVAR(supportRTBD)) then {GVAR(supportRTBD) = false};
	_HQ setVariable [QGVAR(supportRTB),GVAR(supportRTBD)];
	
	if (isNil QEGVAR(common,debugD)) then {EGVAR(common,debugD) = false};
	_HQ setVariable [QEGVAR(common,debug),EGVAR(common,debugD)]; 
	if (isNil QGVAR(debugIID)) then {GVAR(debugIID) = false};
	_HQ setVariable [QGVAR(debugII),GVAR(debugIID)];
	
	if (isNil QGVAR(alwaysKnownUD)) then {GVAR(alwaysKnownUD) = []};
	_HQ setVariable [QGVAR(alwaysKnownU),GVAR(alwaysKnownUD)]; 
	if (isNil QGVAR(alwaysUnKnownUD)) then {GVAR(alwaysUnKnownUD) = []};
	_HQ setVariable [QGVAR(alwaysUnKnownU),GVAR(alwaysUnKnownUD)]; 
	
	if (isNil QGVAR(aOnlyD)) then {GVAR(aOnlyD) = []};
	_HQ setVariable [QGVAR(aOnly),GVAR(aOnlyD)]; 
	if (isNil QGVAR(rOnlyD)) then {GVAR(rOnlyD) = []};
	_HQ setVariable [QGVAR(rOnly),GVAR(rOnlyD)];
	
	if (isNil QGVAR(airEvacD)) then {GVAR(airEvacD) = false};
	_HQ setVariable [QGVAR(airEvac),GVAR(airEvacD)];  
	
	if (isNil QGVAR(aAOD)) then {GVAR(aAOD) = false};
	_HQ setVariable [QGVAR(aAO),GVAR(aAOD)]; 
	if (isNil QGVAR(forceAAOD)) then {GVAR(forceAAOD) = false};
	_HQ setVariable [QGVAR(forceAAO),GVAR(forceAAOD)];


	if (isNil QGVAR(bBAOObjD)) then {GVAR(bBAOObjD) = 1};
	_HQ setVariable [QGVAR(bBAOObj),GVAR(bBAOObjD)]; 
	
	if (isNil (QGVAR(moraleConstD))) then {GVAR(moraleConstD) = 1};
	_HQ setVariable [QGVAR(moraleConst),GVAR(moraleConstD)];
	
	if (isNil (QGVAR(offTendD))) then {GVAR(offTendD) = 1};
	_HQ setVariable [QGVAR(offTend),GVAR(offTendD)];
	
	if (isNil QGVAR(eBDoctrineD)) then {GVAR(eBDoctrineD) = false};
	_HQ setVariable [QGVAR(eBDoctrine),GVAR(eBDoctrineD)]; 
	if (isNil QGVAR(forceEBDoctrineD)) then {GVAR(forceEBDoctrineD) = false};
	_HQ setVariable [QGVAR(forceEBDoctrine),GVAR(forceEBDoctrineD)]; 
	
	if (isNil QGVAR(defRangeD)) then {GVAR(defRangeD) = 1};
	_HQ setVariable [QGVAR(defRange),GVAR(defRangeD)];
	if (isNil QGVAR(garrRangeD)) then {GVAR(garrRangeD) = 1};
	_HQ setVariable [QGVAR(garrRange),GVAR(garrRangeD)];
	
	if (isNil QGVAR(noCaptD)) then {GVAR(noCaptD) = []};
	_HQ setVariable [QGVAR(noCapt),GVAR(noCapt)];
	
	if (isNil QGVAR(attInfDistanceD)) then {GVAR(attInfDistanceD) = 1};
	_HQ setVariable [QGVAR(attInfDistance),GVAR(attInfDistanceD)];
	if (isNil QGVAR(attArmDistanceD)) then {GVAR(attArmDistanceD) = 1};
	_HQ setVariable [QGVAR(attArmDistance),GVAR(attArmDistanceD)];
	if (isNil QGVAR(attSnpDistanceD)) then {GVAR(attSnpDistanceD) = 1};
	_HQ setVariable [QGVAR(attSnpDistance),GVAR(attSnpDistanceD)];
	if (isNil QGVAR(captureDistanceD)) then {GVAR(captureDistanceD) = 1};
	_HQ setVariable [QGVAR(captureDistance),GVAR(captureDistanceD)];	
	if (isNil QGVAR(flankDistanceD)) then {GVAR(flankDistanceD) = 1};
	_HQ setVariable [QGVAR(flankDistance),GVAR(flankDistanceD)];
	if (isNil QGVAR(attSFDistanceD)) then {GVAR(attSFDistanceD) = 1};
	_HQ setVariable [QGVAR(attSFDistance),GVAR(attSFDistanceD)];
	if (isNil QGVAR(reconDistanceD)) then {GVAR(reconDistanceD) = 1};
	_HQ setVariable [QGVAR(reconDistance),GVAR(reconDistanceD)];
	if (isNil QGVAR(uAVAltD)) then {GVAR(uAVAltD) = 150};
	_HQ setVariable [QEGVAR(common,uAVAlt),GVAR(uAVAltD)];

	if (isNil QGVAR(obj1D)) then {GVAR(obj1D) = createTrigger ["EmptyDetector", leaderHQD]};
	if (isNil QGVAR(obj2D)) then {GVAR(obj2D) = createTrigger ["EmptyDetector", leaderHQD]};
	if (isNil QGVAR(obj3D)) then {GVAR(obj3D) = createTrigger ["EmptyDetector", leaderHQD]};
	if (isNil QGVAR(obj4D)) then {GVAR(obj4D) = createTrigger ["EmptyDetector", leaderHQD]};
	
 	_HQ setVariable [QGVAR(obj1),GVAR(obj1D)];
	_HQ setVariable [QGVAR(obj2),GVAR(obj2D)];
	_HQ setVariable [QGVAR(obj3),GVAR(obj3D)];
	_HQ setVariable [QGVAR(obj4),GVAR(obj4D)];
	
	_objectives = [GVAR(obj1D),GVAR(obj2D),GVAR(obj3D),GVAR(obj4D)];
	_NAVObjectives = [];

	if (isNil (QGVAR(simpleModeD))) then {GVAR(simpleModeD) = true};
	_HQ setVariable [QGVAR(simpleMode),GVAR(simpleModeD)];

	if (isNil (QGVAR(secTasksD))) then {GVAR(secTasksD) = false};
	_HQ setVariable [QGVAR(secTasks),GVAR(secTasksD)];
	
	if (isNil (QGVAR(simpleObjsD))) then {GVAR(simpleObjsD) = []};
	_HQ setVariable [QGVAR(simpleObjs),GVAR(simpleObjsD)];

	if (isNil (QGVAR(navalObjsD))) then {GVAR(navalObjsD) = []};
	_HQ setVariable [QGVAR(navalObjs),GVAR(navalObjsD)];

	if (isNil (QGVAR(maxSimpleObjsD))) then {GVAR(maxSimpleObjsD) = 5};
	_HQ setVariable [QGVAR(maxSimpleObjs),GVAR(maxSimpleObjsD)];

	if (_HQ getVariable [QGVAR(simpleMode),false]) then {

		_objectives = GVAR(simpleObjsD);
		_NAVObjectives = GVAR(navalObjsD);
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
				
	if not (isNil QGVAR(defFrontLD)) then {_HQ setVariable [QGVAR(defFrontL),GVAR(defFrontLD)]};
	if not (isNil QGVAR(defFront1D)) then {_HQ setVariable [QGVAR(defFront1),GVAR(defFront1D)]};
	if not (isNil QGVAR(defFront2D)) then {_HQ setVariable [QGVAR(defFront2),GVAR(defFront2D)]};
	if not (isNil QGVAR(defFront3D)) then {_HQ setVariable [QGVAR(defFront3),GVAR(defFront3D)]};
	if not (isNil QGVAR(defFront4D)) then {_HQ setVariable [QGVAR(defFront4),GVAR(defFront4D)]};
	
	_civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];
	if not (isNil (QGVAR(civFD))) then {_civF = GVAR(civFD)};
	_HQ setVariable [QGVAR(civF),_civF];
	
	if (isNil (QGVAR(defD))) then {GVAR(defD) = []};
	_HQ setVariable [QGVAR(def),GVAR(defD)];
	
	_nObj = _HQ getVariable [QGVAR(nObj),1];

	switch (_nObj) do
		{
		case (1) : {_HQ setVariable [QGVAR(obj),GVAR(obj1D)]};
		case (2) : {_HQ setVariable [QGVAR(obj),GVAR(obj2D)]};
		case (3) : {_HQ setVariable [QGVAR(obj),GVAR(obj3D)]};
		default {_HQ setVariable [QGVAR(obj),GVAR(obj4D)]};
		};
		
	call GVAR(statusQuo);
	};
