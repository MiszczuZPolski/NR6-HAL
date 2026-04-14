#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/HQSitRepF.sqf

_SCRname = "SitRepF";
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

if (isNil (QGVAR(mAttF))) then {GVAR(mAttF) = false};
_HQ setVariable [QGVAR(mAtt),GVAR(mAttF)];
if ((isNil (QGVAR(personalityF))) or not (_HQ getVariable [QGVAR(mAtt),false])) then {GVAR(personalityF) = "OTHER"};
_HQ setVariable [QGVAR(personality),GVAR(personalityF)];

if (isNil (QGVAR(recklessnessF))) then {GVAR(recklessnessF) = 0.5};
_HQ setVariable [QGVAR(recklessness),GVAR(recklessnessF)];
if (isNil (QGVAR(consistencyF))) then {GVAR(consistencyF) = 0.5};
_HQ setVariable [QGVAR(consistency),GVAR(consistencyF)];
if (isNil (QGVAR(activityF))) then {GVAR(activityF) = 0.5};
_HQ setVariable [QGVAR(activity),GVAR(activityF)];
if (isNil (QGVAR(reflexF))) then {GVAR(reflexF) = 0.5};
_HQ setVariable [QGVAR(reflex),GVAR(reflexF)];
if (isNil (QGVAR(circumspectionF))) then {GVAR(circumspectionF) = 0.5};
_HQ setVariable [QGVAR(circumspection),GVAR(circumspectionF)];
if (isNil (QGVAR(finenessF))) then {GVAR(finenessF) = 0.5};
_HQ setVariable [QGVAR(fineness),GVAR(finenessF)];

[_HQ] call FUNC(personality);

[[_HQ],EFUNC(hac,lhq)] call EFUNC(common,spawn);

if (isNil (QGVAR(boxedF))) then {GVAR(boxedF) = []};
_HQ setVariable [QGVAR(boxed),GVAR(boxedF)];

if (isNil (QEGVAR(missionmodules,ammoBoxesF))) then
	{
	EGVAR(missionmodules,ammoBoxesF) = [];

	if not (isNil QEGVAR(missionmodules,ammoDepotF)) then
		{
		_rds = (triggerArea EGVAR(missionmodules,ammoDepotF)) select 0;
		EGVAR(missionmodules,ammoBoxesF) = (getPosATL EGVAR(missionmodules,ammoDepotF)) nearObjects ["ReammoBox_F",_rds]
		}
	};

_HQ setVariable [QGVAR(ammoBoxes),EGVAR(missionmodules,ammoBoxesF)];

_HQ setVariable [QGVAR(reconDone),false];
_HQ setVariable [QGVAR(defDone),false];
_HQ setVariable [QGVAR(reconStage),1];
_HQ setVariable [QGVAR(reconStage2),1];
_HQ setVariable [QGVAR(airInDef),[]];

_KnEnPos = [];

if (isNil (QEGVAR(missionmodules,excludedF))) then {EGVAR(missionmodules,excludedF) = []};
_HQ setVariable [QEGVAR(common,excluded),EGVAR(missionmodules,excludedF)];
if (isNil (QGVAR(fastF))) then {GVAR(fastF) = false};
_HQ setVariable [QGVAR(fast),GVAR(fastF)];
if (isNil (QGVAR(exInfoF))) then {GVAR(exInfoF) = false};
_HQ setVariable [QGVAR(exInfo),GVAR(exInfoF)];
if (isNil (QGVAR(objHoldTimeF))) then {GVAR(objHoldTimeF) = 600};
_HQ setVariable [QGVAR(objHoldTime),GVAR(objHoldTimeF)];
if (isNil QGVAR(nObjF)) then {GVAR(nObjF) = 1};
_HQ setVariable [QGVAR(nObj),GVAR(nObjF)];

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

if (isNil (QGVAR(supportWPF))) then {GVAR(supportWPF) = false};
	
_HQ setVariable [QGVAR(supportWP),GVAR(supportWPF)];

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
	
	if (isNil QEGVAR(missionmodules,garrisonF)) then {EGVAR(missionmodules,garrisonF) = []};
	_HQ setVariable [QGVAR(garrison),EGVAR(missionmodules,garrisonF)];
	
	if (isNil (QGVAR(noAirCargoF))) then {GVAR(noAirCargoF) = false};
	_HQ setVariable [QGVAR(noAirCargo),GVAR(noAirCargoF)];
	if (isNil (QGVAR(noLandCargoF))) then {GVAR(noLandCargoF) = false};
	_HQ setVariable [QGVAR(noLandCargo),GVAR(noLandCargoF)];
	if (isNil (QGVAR(lastFriendsF))) then {GVAR(lastFriendsF) = []};
	_HQ setVariable [QGVAR(lastFriends),GVAR(lastFriendsF)];
	if (isNil (QGVAR(cargoFindF))) then {GVAR(cargoFindF) = 1};
	_HQ setVariable [QGVAR(cargoFind),GVAR(cargoFindF)];
	if (isNil (QGVAR(subordinatedF))) then {GVAR(subordinatedF) = []};
	_HQ setVariable [QGVAR(subordinated),GVAR(subordinatedF)];
	if (isNil (QEGVAR(missionmodules,includedF))) then {EGVAR(missionmodules,includedF) = []};
	_HQ setVariable [QGVAR(included),EGVAR(missionmodules,includedF)];
	if (isNil (QEGVAR(missionmodules,excludedF))) then {EGVAR(missionmodules,excludedF) = []};
	_HQ setVariable [QEGVAR(common,excluded),EGVAR(missionmodules,excludedF)];
	if (isNil (QGVAR(subAllF))) then {GVAR(subAllF) = true};
	_HQ setVariable [QGVAR(subAll),GVAR(subAllF)];
	if (isNil (QGVAR(subSynchroF))) then {GVAR(subSynchroF) = false};
	_HQ setVariable [QGVAR(subSynchro),GVAR(subSynchroF)];
	if (isNil (QGVAR(subNamedF))) then {GVAR(subNamedF) = false};
	_HQ setVariable [QGVAR(subNamed),GVAR(subNamedF)];
	if (isNil (QGVAR(subZeroF))) then {GVAR(subZeroF) = false};
	_HQ setVariable [QGVAR(subZero),GVAR(subZeroF)];
	if (isNil (QGVAR(reSynchroF))) then {GVAR(reSynchroF) = true};
	_HQ setVariable [QGVAR(reSynchro),GVAR(reSynchroF)];
	if (isNil (QGVAR(nameLimitF))) then {GVAR(nameLimitF) = 100};
	_HQ setVariable [QGVAR(nameLimit),GVAR(nameLimitF)];
	if (isNil (QGVAR(surrF))) then {GVAR(surrF) = false};
	_HQ setVariable [QGVAR(surr),GVAR(surrF)];
	if (isNil (QEGVAR(missionmodules,noReconF))) then {EGVAR(missionmodules,noReconF) = []};
	_HQ setVariable [QGVAR(noRecon),EGVAR(missionmodules,noReconF)];
	if (isNil (QEGVAR(missionmodules,noAttackF))) then {EGVAR(missionmodules,noAttackF) = []};
	_HQ setVariable [QGVAR(noAttack),EGVAR(missionmodules,noAttackF)];
	if (isNil (QEGVAR(missionmodules,cargoOnlyF))) then {EGVAR(missionmodules,cargoOnlyF) = []};
	_HQ setVariable [QGVAR(cargoOnly),EGVAR(missionmodules,cargoOnlyF)];
	if (isNil (QEGVAR(missionmodules,noCargoF))) then {EGVAR(missionmodules,noCargoF) = []};
	_HQ setVariable [QGVAR(noCargo),EGVAR(missionmodules,noCargoF)];
	if (isNil (QEGVAR(missionmodules,noFlankF))) then {EGVAR(missionmodules,noFlankF) = []};
	_HQ setVariable [QGVAR(noFlank),EGVAR(missionmodules,noFlankF)];
	if (isNil (QEGVAR(missionmodules,noDefF))) then {EGVAR(missionmodules,noDefF) = []};
	_HQ setVariable [QGVAR(noDef),EGVAR(missionmodules,noDefF)];
	if (isNil (QEGVAR(missionmodules,firstToFightF))) then {EGVAR(missionmodules,firstToFightF) = []};
	_HQ setVariable [QGVAR(firstToFight),EGVAR(missionmodules,firstToFightF)];
	if (isNil (QGVAR(voiceCommF))) then {GVAR(voiceCommF) = true};
	_HQ setVariable [QGVAR(voiceComm),GVAR(voiceCommF)];
	if (isNil (QEGVAR(missionmodules,frontF))) then {EGVAR(missionmodules,frontF) = false};
	_HQ setVariable [QGVAR(frontA),EGVAR(missionmodules,frontF)];
	if (isNil (QGVAR(lRelocatingF))) then {GVAR(lRelocatingF) = false};
	_HQ setVariable [QGVAR(lRelocating),GVAR(lRelocatingF)];
	if (isNil (QGVAR(fleeF))) then {GVAR(fleeF) = true};
	_HQ setVariable [QGVAR(flee),GVAR(fleeF)];
	if (isNil (QGVAR(garrRF))) then {GVAR(garrRF) = 500};
	_HQ setVariable [QGVAR(garrR),GVAR(garrRF)];
	if (isNil (QGVAR(rushF))) then {GVAR(rushF) = false};
	_HQ setVariable [QGVAR(rush),GVAR(rushF)];
	if (isNil (QGVAR(garrVehAbF))) then {GVAR(garrVehAbF) = false};
	_HQ setVariable [QGVAR(garrVehAb),GVAR(garrVehAbF)];
	if (isNil (QGVAR(defendObjectivesF))) then {GVAR(defendObjectivesF) = 4};
	_HQ setVariable [QGVAR(defendObjectives),GVAR(defendObjectivesF)];
	if (isNil (QGVAR(defSpotF))) then {GVAR(defSpotF) = []};
	_HQ setVariable [QGVAR(defSpot),GVAR(defSpotF)];
	if (isNil (QGVAR(recDefSpotF))) then {GVAR(recDefSpotF) = []};
	_HQ setVariable [QGVAR(recDefSpot),GVAR(recDefSpotF)];
	if (isNil QGVAR(flareF)) then {GVAR(flareF) = true};
	_HQ setVariable [QGVAR(flare),GVAR(flareF)];
	if (isNil QGVAR(smokeF)) then {GVAR(smokeF) = true};
	_HQ setVariable [QGVAR(smoke),GVAR(smokeF)];
	if (isNil QGVAR(noRecF)) then {GVAR(noRecF) = 1};
	_HQ setVariable [QGVAR(noRec),GVAR(noRecF)];
	if (isNil QGVAR(rapidCaptF)) then {GVAR(rapidCaptF) = 10};
	_HQ setVariable [QGVAR(rapidCapt),GVAR(rapidCaptF)];
	if (isNil QGVAR(muuF)) then {GVAR(muuF) = 1};
	_HQ setVariable [QGVAR(muu),GVAR(muuF)];
	if (isNil QGVAR(artyShellsF)) then {GVAR(artyShellsF) = 1};
	_HQ setVariable [QGVAR(artyShells),GVAR(artyShellsF)];
	if (isNil QGVAR(withdrawF)) then {GVAR(withdrawF) = 1};
	_HQ setVariable [QGVAR(withdraw),GVAR(withdrawF)];
	if (isNil QGVAR(berserkF)) then {GVAR(berserkF) = false};
	_HQ setVariable [QGVAR(berserk),GVAR(berserkF)];
	if (isNil QEGVAR(missionmodules,iDChanceF)) then {EGVAR(missionmodules,iDChanceF) = 100};
	_HQ setVariable [QGVAR(iDChance),EGVAR(missionmodules,iDChanceF)];
	if (isNil QEGVAR(missionmodules,rDChanceF)) then {EGVAR(missionmodules,rDChanceF) = 100};
	_HQ setVariable [QGVAR(rDChance),EGVAR(missionmodules,rDChanceF)];
	if (isNil QEGVAR(missionmodules,sDChanceF)) then {EGVAR(missionmodules,sDChanceF) = 100};
	_HQ setVariable [QGVAR(sDChance),EGVAR(missionmodules,sDChanceF)];
	if (isNil QEGVAR(missionmodules,ammoDropF)) then {EGVAR(missionmodules,ammoDropF) = []};
	_HQ setVariable [QGVAR(ammoDrop),EGVAR(missionmodules,ammoDropF)];
	if (isNil QGVAR(sFTargetsF)) then {GVAR(sFTargetsF) = []};
	_HQ setVariable [QGVAR(sFTargets),GVAR(sFTargetsF)];
	if (isNil QGVAR(lZF)) then {GVAR(lZF) = false};
	_HQ setVariable [QGVAR(lZ),GVAR(lZF)];
	if (isNil QEGVAR(missionmodules,sFBodyGuardF)) then {EGVAR(missionmodules,sFBodyGuardF) = []};
	_HQ setVariable [QGVAR(sFBodyGuard),EGVAR(missionmodules,sFBodyGuardF)];
	if (isNil QGVAR(dynFormF)) then {GVAR(dynFormF) = false};
	_HQ setVariable [QGVAR(dynForm),GVAR(dynFormF)];
	if (isNil QGVAR(unlimitedCaptF)) then {GVAR(unlimitedCaptF) = false};
	_HQ setVariable [QGVAR(unlimitedCapt),GVAR(unlimitedCaptF)];
	if (isNil QGVAR(captLimitF)) then {GVAR(captLimitF) = 10};
	_HQ setVariable [QGVAR(captLimit),GVAR(captLimitF)];
	if (isNil QGVAR(getHQInsideF)) then {GVAR(getHQInsideF) = false};
	_HQ setVariable [QGVAR(getHQInside),GVAR(getHQInsideF)];
	if (isNil QGVAR(wAF)) then {GVAR(wAF) = true};
	_HQ setVariable [QGVAR(wA),GVAR(wAF)];

	if (isNil QGVAR(infoMarkersF)) then {GVAR(infoMarkersF) = false};
	_HQ setVariable [QGVAR(infoMarkers),GVAR(infoMarkersF)];

	if (isNil QGVAR(artyMarksF)) then {GVAR(artyMarksF) = false};
	_HQ setVariable [QGVAR(artyMarks),GVAR(artyMarksF)];
		
	if (isNil (QGVAR(resetNowF))) then {GVAR(resetNowF) = false};
	_HQ setVariable [QGVAR(resetNow),GVAR(resetNowF)];
	if (isNil (QGVAR(resetOnDemandF))) then {GVAR(resetOnDemandF) = false};
	_HQ setVariable [QGVAR(resetOnDemand),GVAR(resetOnDemandF)];
	if (isNil (QGVAR(resetTimeF))) then {GVAR(resetTimeF) = 600};
	_HQ setVariable [QGVAR(resetTime),GVAR(resetTimeF)];
	if (isNil (QGVAR(combiningF))) then {GVAR(combiningF) = false};
	_HQ setVariable [QGVAR(combining),GVAR(combiningF)];
	if (isNil (QGVAR(objRadius1F))) then {GVAR(objRadius1F) = 300};
	_HQ setVariable [QGVAR(objRadius1),GVAR(objRadius1F)];
	if (isNil (QGVAR(objRadius2F))) then {GVAR(objRadius2F) = 500};
	_HQ setVariable [QGVAR(objRadius2),GVAR(objRadius2F)];
	if (isNil (QGVAR(knowTLF))) then {GVAR(knowTLF) = true};
	_HQ setVariable [QGVAR(knowTL),GVAR(knowTLF)];
	
	if (isNil (QGVAR(sMedF))) then {GVAR(sMedF) = true};
	_HQ setVariable [QGVAR(sMed),GVAR(sMedF)];
	if (isNil (QEGVAR(missionmodules,exMedicF))) then {EGVAR(missionmodules,exMedicF) = []};
	_HQ setVariable [QGVAR(exMedic),EGVAR(missionmodules,exMedicF)];
	if (isNil (QGVAR(medPointsF))) then {GVAR(medPointsF) = []};
	_HQ setVariable [QGVAR(medPoints),GVAR(medPointsF)];
	if (isNil (QGVAR(supportedGF))) then {GVAR(supportedGF) = []};
	_HQ setVariable [QGVAR(supportedG),GVAR(supportedGF)];
		
	if (isNil (QEGVAR(missionmodules,rCASF))) then {EGVAR(missionmodules,rCASF) = []};
	_HQ setVariable [QGVAR(rCAS),EGVAR(missionmodules,rCASF)];
	if (isNil (QEGVAR(missionmodules,rCAPF))) then {EGVAR(missionmodules,rCAPF) = []};
	_HQ setVariable [QGVAR(rCAP),EGVAR(missionmodules,rCAPF)];
	
	if (isNil (QGVAR(sFuelF))) then {GVAR(sFuelF) = true};
	_HQ setVariable [QGVAR(sFuel),GVAR(sFuelF)];
	if (isNil (QEGVAR(missionmodules,exRefuelF))) then {EGVAR(missionmodules,exRefuelF) = []};
	_HQ setVariable [QGVAR(exRefuel),EGVAR(missionmodules,exRefuelF)];
	if (isNil (QGVAR(fuelPointsF))) then {GVAR(fuelPointsF) = []};
	_HQ setVariable [QGVAR(fuelPoints),GVAR(fuelPointsF)];
	if (isNil (QGVAR(fSupportedGF))) then {GVAR(fSupportedGF) = []};
	_HQ setVariable [QGVAR(fSupportedG),GVAR(fSupportedGF)];
	
	if (isNil (QGVAR(sAmmoF))) then {GVAR(sAmmoF) = true};
	_HQ setVariable [QGVAR(sAmmo),GVAR(sAmmoF)];
	if (isNil (QEGVAR(missionmodules,exReammoF))) then {EGVAR(missionmodules,exReammoF) = []};
	_HQ setVariable [QGVAR(exReammo),EGVAR(missionmodules,exReammoF)];
	if (isNil (QGVAR(ammoPointsF))) then {GVAR(ammoPointsF) = []};
	_HQ setVariable [QGVAR(ammoPoints),GVAR(ammoPointsF)];
	if (isNil (QGVAR(aSupportedGF))) then {GVAR(aSupportedGF) = []};
	_HQ setVariable [QGVAR(aSupportedG),GVAR(aSupportedGF)];
	
	if (isNil (QGVAR(sRepF))) then {GVAR(sRepF) = true};
	_HQ setVariable [QGVAR(sRep),GVAR(sRepF)];
	if (isNil (QEGVAR(missionmodules,exRepairF))) then {EGVAR(missionmodules,exRepairF) = []};
	_HQ setVariable [QGVAR(exRepair),EGVAR(missionmodules,exRepairF)];
	if (isNil (QGVAR(repPointsF))) then {GVAR(repPointsF) = []};
	_HQ setVariable [QGVAR(repPoints),GVAR(repPointsF)];
	if (isNil (QGVAR(rSupportedGF))) then {GVAR(rSupportedGF) = []};
	_HQ setVariable [QGVAR(rSupportedG),GVAR(rSupportedGF)];
	
	if (isNil QGVAR(airDistF)) then {GVAR(airDistF) = 4000};
	_HQ setVariable [QGVAR(airDist),GVAR(airDistF)];
	
	if (isNil (QGVAR(commDelayF))) then {GVAR(commDelayF) = 1};
	_HQ setVariable [QGVAR(commDelay),GVAR(commDelayF)];


	// Per-letter override (string "DEFEND") wins; fall back to shared CBA boolean.
	private _orderSrc = if (isNil (QGVAR(orderF))) then {GVAR(order)} else {GVAR(orderF)};
	private _orderDefault = ["ATTACK", "DEFEND"] select ((_orderSrc isEqualType "") || {_orderSrc});
	_HQ setVariable [QGVAR(order), _orderDefault];

	if (isNil (QGVAR(attackAlwaysF))) then {GVAR(attackAlwaysF) = false};
	_HQ setVariable [QGVAR(attackAlways),GVAR(attackAlwaysF)];

	if (isNil (QGVAR(cRDefResF))) then {GVAR(cRDefResF) = 0};
	_HQ setVariable [QGVAR(cRDefRes),GVAR(cRDefResF)];

	if (isNil (QGVAR(reconReserveF))) then {GVAR(reconReserveF) = (0.3 * (0.5 + (_HQ getVariable [QGVAR(circumspection),0.5])))};
	_HQ setVariable [QGVAR(reconReserve),GVAR(reconReserveF)];
	if (isNil (QGVAR(exhaustedF))) then {GVAR(exhaustedF) = []};
	_HQ setVariable [QGVAR(exhausted),GVAR(exhaustedF)];
	if (isNil (QGVAR(attackReserveF))) then {GVAR(attackReserveF) = (0.5 * (0.5 + ((_HQ getVariable [QGVAR(circumspection),0.5])/1.5)))};
	_HQ setVariable [QGVAR(attackReserve),GVAR(attackReserveF)];
	if (isNil (QGVAR(idleOrdF))) then {GVAR(idleOrdF) = true};
	_HQ setVariable [QGVAR(idleOrd),GVAR(idleOrdF)];

	if (isNil (QGVAR(idleDefF))) then {GVAR(idleDefF) = true};
	_HQ setVariable [QGVAR(idleDef),GVAR(idleDefF)];

	if (isNil QEGVAR(missionmodules,idleDecoyF)) then {EGVAR(missionmodules,idleDecoyF) = objNull};
	_HQ setVariable [QGVAR(idleDecoy),EGVAR(missionmodules,idleDecoyF)];
	if (isNil QEGVAR(missionmodules,supportDecoyF)) then {EGVAR(missionmodules,supportDecoyF) = objNull};
	_HQ setVariable [QGVAR(supportDecoy),EGVAR(missionmodules,supportDecoyF)]; 
	if (isNil QEGVAR(missionmodules,restDecoyF)) then {EGVAR(missionmodules,restDecoyF) = objNull};
	_HQ setVariable [QGVAR(restDecoy),EGVAR(missionmodules,restDecoyF)]; 
	if (isNil QGVAR(sec1F)) then {GVAR(sec1F) = objNull};
	_HQ setVariable [QGVAR(sec1),GVAR(sec1F)]; 
	if (isNil QGVAR(sec2F)) then {GVAR(sec2F) = objNull};
	_HQ setVariable [QGVAR(sec2),GVAR(sec2F)];

	if (isNil QGVAR(supportRTBF)) then {GVAR(supportRTBF) = false};
	_HQ setVariable [QGVAR(supportRTB),GVAR(supportRTBF)];
	
 	if (isNil QEGVAR(common,debugF)) then {EGVAR(common,debugF) = false};
	_HQ setVariable [QEGVAR(common,debug),EGVAR(common,debugF)]; 
	if (isNil QGVAR(debugIIF)) then {GVAR(debugIIF) = false};
	_HQ setVariable [QGVAR(debugII),GVAR(debugIIF)];
	
	if (isNil QEGVAR(missionmodules,alwaysKnownUF)) then {EGVAR(missionmodules,alwaysKnownUF) = []};
	_HQ setVariable [QGVAR(alwaysKnownU),EGVAR(missionmodules,alwaysKnownUF)];
	if (isNil QEGVAR(missionmodules,alwaysUnKnownUF)) then {EGVAR(missionmodules,alwaysUnKnownUF) = []};
	_HQ setVariable [QGVAR(alwaysUnKnownU),EGVAR(missionmodules,alwaysUnKnownUF)];

	if (isNil QEGVAR(missionmodules,aOnlyF)) then {EGVAR(missionmodules,aOnlyF) = []};
	_HQ setVariable [QGVAR(aOnly),EGVAR(missionmodules,aOnlyF)];
	if (isNil QEGVAR(missionmodules,rOnlyF)) then {EGVAR(missionmodules,rOnlyF) = []};
	_HQ setVariable [QGVAR(rOnly),EGVAR(missionmodules,rOnlyF)]; 
	
	if (isNil QGVAR(airEvacF)) then {GVAR(airEvacF) = false};
	_HQ setVariable [QGVAR(airEvac),GVAR(airEvacF)]; 
	
	if (isNil QGVAR(aAOF)) then {GVAR(aAOF) = false};
	_HQ setVariable [QGVAR(aAO),GVAR(aAOF)]; 
	if (isNil QGVAR(forceAAOF)) then {GVAR(forceAAOF) = false};
	_HQ setVariable [QGVAR(forceAAO),GVAR(forceAAOF)];
	

	if (isNil QGVAR(bBAOObjF)) then {GVAR(bBAOObjF) = 1};
	_HQ setVariable [QGVAR(bBAOObj),GVAR(bBAOObjF)]; 
	
	if (isNil (QGVAR(moraleConstF))) then {GVAR(moraleConstF) = 1};
	_HQ setVariable [QGVAR(moraleConst),GVAR(moraleConstF)];
	
	if (isNil (QGVAR(offTendF))) then {GVAR(offTendF) = 1};
	_HQ setVariable [QGVAR(offTend),GVAR(offTendF)];
	
	if (isNil QGVAR(eBDoctrineF)) then {GVAR(eBDoctrineF) = false};
	_HQ setVariable [QGVAR(eBDoctrine),GVAR(eBDoctrineF)]; 
	if (isNil QGVAR(forceEBDoctrineF)) then {GVAR(forceEBDoctrineF) = false};
	_HQ setVariable [QGVAR(forceEBDoctrine),GVAR(forceEBDoctrineF)]; 
	
	if (isNil QGVAR(defRangeF)) then {GVAR(defRangeF) = 1};
	_HQ setVariable [QGVAR(defRange),GVAR(defRangeF)];
	if (isNil QGVAR(garrRangeF)) then {GVAR(garrRangeF) = 1};
	_HQ setVariable [QGVAR(garrRange),GVAR(garrRangeF)];
	
	if (isNil QGVAR(noCaptF)) then {GVAR(noCaptF) = []};
	_HQ setVariable [QGVAR(noCapt),GVAR(noCapt)];
	
	if (isNil QGVAR(attInfDistanceF)) then {GVAR(attInfDistanceF) = 1};
	_HQ setVariable [QGVAR(attInfDistance),GVAR(attInfDistanceF)];
	if (isNil QGVAR(attArmDistanceF)) then {GVAR(attArmDistanceF) = 1};
	_HQ setVariable [QGVAR(attArmDistance),GVAR(attArmDistanceF)];
	if (isNil QGVAR(attSnpDistanceF)) then {GVAR(attSnpDistanceF) = 1};
	_HQ setVariable [QGVAR(attSnpDistance),GVAR(attSnpDistanceF)];
	if (isNil QGVAR(captureDistanceF)) then {GVAR(captureDistanceF) = 1};
	_HQ setVariable [QGVAR(captureDistance),GVAR(captureDistanceF)];	
	if (isNil QGVAR(flankDistanceF)) then {GVAR(flankDistanceF) = 1};
	_HQ setVariable [QGVAR(flankDistance),GVAR(flankDistanceF)];
	if (isNil QGVAR(attSFDistanceF)) then {GVAR(attSFDistanceF) = 1};
	_HQ setVariable [QGVAR(attSFDistance),GVAR(attSFDistanceF)];
	if (isNil QGVAR(reconDistanceF)) then {GVAR(reconDistanceF) = 1};
	_HQ setVariable [QGVAR(reconDistance),GVAR(reconDistanceF)];
	if (isNil QGVAR(uAVAltF)) then {GVAR(uAVAltF) = 150};
	_HQ setVariable [QEGVAR(common,uAVAlt),GVAR(uAVAltF)];
		
	if (isNil QGVAR(obj1F)) then {GVAR(obj1F) = createTrigger ["EmptyDetector", leaderHQF]};
	if (isNil QGVAR(obj2F)) then {GVAR(obj2F) = createTrigger ["EmptyDetector", leaderHQF]};
	if (isNil QGVAR(obj3F)) then {GVAR(obj3F) = createTrigger ["EmptyDetector", leaderHQF]};
	if (isNil QGVAR(obj4F)) then {GVAR(obj4F) = createTrigger ["EmptyDetector", leaderHQF]};
		
	_HQ setVariable [QGVAR(obj1),GVAR(obj1F)];
	_HQ setVariable [QGVAR(obj2),GVAR(obj2F)];
	_HQ setVariable [QGVAR(obj3),GVAR(obj3F)];
	_HQ setVariable [QGVAR(obj4),GVAR(obj4F)];
	
	_objectives = [GVAR(obj1F),GVAR(obj2F),GVAR(obj3F),GVAR(obj4F)];
	_NAVObjectives = [];

	if (isNil (QGVAR(simpleModeF))) then {GVAR(simpleModeF) = true};
	_HQ setVariable [QGVAR(simpleMode),GVAR(simpleModeF)];

	if (isNil (QGVAR(secTasksF))) then {GVAR(secTasksF) = false};
	_HQ setVariable [QGVAR(secTasks),GVAR(secTasksF)];
	
	if (isNil (QEGVAR(missionmodules,simpleObjsF))) then {EGVAR(missionmodules,simpleObjsF) = []};
	_HQ setVariable [QGVAR(simpleObjs),EGVAR(missionmodules,simpleObjsF)];

	if (isNil (QEGVAR(missionmodules,navalObjsF))) then {EGVAR(missionmodules,navalObjsF) = []};
	_HQ setVariable [QGVAR(navalObjs),EGVAR(missionmodules,navalObjsF)];

	if (isNil (QGVAR(maxSimpleObjsF))) then {GVAR(maxSimpleObjsF) = 5};
	_HQ setVariable [QGVAR(maxSimpleObjs),GVAR(maxSimpleObjsF)];

	if (_HQ getVariable [QGVAR(simpleMode),false]) then {

		_objectives = EGVAR(missionmodules,simpleObjsF);
		_NAVObjectives = EGVAR(missionmodules,navalObjsF);
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
				
	if not (isNil QGVAR(defFrontLF)) then {_HQ setVariable [QGVAR(defFrontL),GVAR(defFrontLF)]};
	if not (isNil QGVAR(defFront1F)) then {_HQ setVariable [QGVAR(defFront1),GVAR(defFront1F)]};
	if not (isNil QGVAR(defFront2F)) then {_HQ setVariable [QGVAR(defFront2),GVAR(defFront2F)]};
	if not (isNil QGVAR(defFront3F)) then {_HQ setVariable [QGVAR(defFront3),GVAR(defFront3F)]};
	if not (isNil QGVAR(defFront4F)) then {_HQ setVariable [QGVAR(defFront4),GVAR(defFront4F)]};
	
	_civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];
	if not (isNil (QGVAR(civFF))) then {_civF = GVAR(civFF)};
	_HQ setVariable [QGVAR(civF),_civF];
	
	if (isNil (QGVAR(defF))) then {GVAR(defF) = []};
	_HQ setVariable [QGVAR(def),GVAR(defF)];
	
	_nObj = _HQ getVariable [QGVAR(nObj),1];

	switch (_nObj) do
		{
		case (1) : {_HQ setVariable [QGVAR(obj),GVAR(obj1F)]};
		case (2) : {_HQ setVariable [QGVAR(obj),GVAR(obj2F)]};
		case (3) : {_HQ setVariable [QGVAR(obj),GVAR(obj3F)]};
		default {_HQ setVariable [QGVAR(obj),GVAR(obj4F)]};
		};
		
	[_HQ, _cycleC, _lastReset, [], _civF] call EFUNC(hac,statusQuo);
	};
