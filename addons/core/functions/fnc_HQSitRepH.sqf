#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/HQSitRepH.sqf

_SCRname = "SitRepH";
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

if (isNil (QGVAR(mAttH))) then {GVAR(mAttH) = false};
_HQ setVariable [QGVAR(mAtt),GVAR(mAttH)];
if ((isNil (QGVAR(personalityH))) or not (_HQ getVariable [QGVAR(mAtt),false])) then {GVAR(personalityH) = "OTHER"};
_HQ setVariable [QGVAR(personality),GVAR(personalityH)];

if (isNil (QGVAR(recklessnessH))) then {GVAR(recklessnessH) = 0.5};
_HQ setVariable [QGVAR(recklessness),GVAR(recklessnessH)];
if (isNil (QGVAR(consistencyH))) then {GVAR(consistencyH) = 0.5};
_HQ setVariable [QGVAR(consistency),GVAR(consistencyH)];
if (isNil (QGVAR(activityH))) then {GVAR(activityH) = 0.5};
_HQ setVariable [QGVAR(activity),GVAR(activityH)];
if (isNil (QGVAR(reflexH))) then {GVAR(reflexH) = 0.5};
_HQ setVariable [QGVAR(reflex),GVAR(reflexH)];
if (isNil (QGVAR(circumspectionH))) then {GVAR(circumspectionH) = 0.5};
_HQ setVariable [QGVAR(circumspection),GVAR(circumspectionH)];
if (isNil (QGVAR(finenessH))) then {GVAR(finenessH) = 0.5};
_HQ setVariable [QGVAR(fineness),GVAR(finenessH)];

[_HQ] call FUNC(personality);

[[_HQ],EFUNC(hac,lhq)] call EFUNC(common,spawn);

if (isNil (QGVAR(boxedH))) then {GVAR(boxedH) = []};
_HQ setVariable [QGVAR(boxed),GVAR(boxedH)];

if (isNil (QEGVAR(missionmodules,ammoBoxesH))) then
	{
	EGVAR(missionmodules,ammoBoxesH) = [];

	if not (isNil QEGVAR(missionmodules,ammoDepotH)) then
		{
		_rds = (triggerArea EGVAR(missionmodules,ammoDepotH)) select 0;
		EGVAR(missionmodules,ammoBoxesH) = (getPosATL EGVAR(missionmodules,ammoDepotH)) nearObjects ["ReammoBox_F",_rds]
		}
	};

_HQ setVariable [QGVAR(ammoBoxes),EGVAR(missionmodules,ammoBoxesH)];

_HQ setVariable [QGVAR(reconDone),false];
_HQ setVariable [QGVAR(defDone),false];
_HQ setVariable [QGVAR(reconStage),1];
_HQ setVariable [QGVAR(reconStage2),1];
_HQ setVariable [QGVAR(airInDef),[]];

_KnEnPos = [];

if (isNil (QEGVAR(missionmodules,excludedH))) then {EGVAR(missionmodules,excludedH) = []};
_HQ setVariable [QEGVAR(common,excluded),EGVAR(missionmodules,excludedH)];
if (isNil (QGVAR(fastH))) then {GVAR(fastH) = false};
_HQ setVariable [QGVAR(fast),GVAR(fastH)];
if (isNil (QGVAR(exInfoH))) then {GVAR(exInfoH) = false};
_HQ setVariable [QGVAR(exInfo),GVAR(exInfoH)];
if (isNil (QGVAR(objHoldTimeH))) then {GVAR(objHoldTimeH) = 600};
_HQ setVariable [QGVAR(objHoldTime),GVAR(objHoldTimeH)];
if (isNil QGVAR(nObjH)) then {GVAR(nObjH) = 1};
_HQ setVariable [QGVAR(nObj),GVAR(nObjH)];

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

if (isNil (QGVAR(supportWPH))) then {GVAR(supportWPH) = false};
	
_HQ setVariable [QGVAR(supportWP),GVAR(supportWPH)];

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
	
	if (isNil QEGVAR(missionmodules,garrisonH)) then {EGVAR(missionmodules,garrisonH) = []};
	_HQ setVariable [QGVAR(garrison),EGVAR(missionmodules,garrisonH)];
	
	if (isNil (QGVAR(noAirCargoH))) then {GVAR(noAirCargoH) = false};
	_HQ setVariable [QGVAR(noAirCargo),GVAR(noAirCargoH)];
	if (isNil (QGVAR(noLandCargoH))) then {GVAR(noLandCargoH) = false};
	_HQ setVariable [QGVAR(noLandCargo),GVAR(noLandCargoH)];
	if (isNil (QGVAR(lastFriendsH))) then {GVAR(lastFriendsH) = []};
	_HQ setVariable [QGVAR(lastFriends),GVAR(lastFriendsH)];
	if (isNil (QGVAR(cargoFindH))) then {GVAR(cargoFindH) = 1};
	_HQ setVariable [QGVAR(cargoFind),GVAR(cargoFindH)];
	if (isNil (QGVAR(subordinatedH))) then {GVAR(subordinatedH) = []};
	_HQ setVariable [QGVAR(subordinated),GVAR(subordinatedH)];
	if (isNil (QEGVAR(missionmodules,includedH))) then {EGVAR(missionmodules,includedH) = []};
	_HQ setVariable [QGVAR(included),EGVAR(missionmodules,includedH)];
	if (isNil (QEGVAR(missionmodules,excludedH))) then {EGVAR(missionmodules,excludedH) = []};
	_HQ setVariable [QEGVAR(common,excluded),EGVAR(missionmodules,excludedH)];
	if (isNil (QGVAR(subAllH))) then {GVAR(subAllH) = true};
	_HQ setVariable [QGVAR(subAll),GVAR(subAllH)];
	if (isNil (QGVAR(subSynchroH))) then {GVAR(subSynchroH) = false};
	_HQ setVariable [QGVAR(subSynchro),GVAR(subSynchroH)];
	if (isNil (QGVAR(subNamedH))) then {GVAR(subNamedH) = false};
	_HQ setVariable [QGVAR(subNamed),GVAR(subNamedH)];
	if (isNil (QGVAR(subZeroH))) then {GVAR(subZeroH) = false};
	_HQ setVariable [QGVAR(subZero),GVAR(subZeroH)];
	if (isNil (QGVAR(reSynchroH))) then {GVAR(reSynchroH) = true};
	_HQ setVariable [QGVAR(reSynchro),GVAR(reSynchroH)];
	if (isNil (QGVAR(nameLimitH))) then {GVAR(nameLimitH) = 100};
	_HQ setVariable [QGVAR(nameLimit),GVAR(nameLimitH)];
	if (isNil (QGVAR(surrH))) then {GVAR(surrH) = false};
	_HQ setVariable [QGVAR(surr),GVAR(surrH)];
	if (isNil (QEGVAR(missionmodules,noReconH))) then {EGVAR(missionmodules,noReconH) = []};
	_HQ setVariable [QGVAR(noRecon),EGVAR(missionmodules,noReconH)];
	if (isNil (QEGVAR(missionmodules,noAttackH))) then {EGVAR(missionmodules,noAttackH) = []};
	_HQ setVariable [QGVAR(noAttack),EGVAR(missionmodules,noAttackH)];
	if (isNil (QEGVAR(missionmodules,cargoOnlyH))) then {EGVAR(missionmodules,cargoOnlyH) = []};
	_HQ setVariable [QGVAR(cargoOnly),EGVAR(missionmodules,cargoOnlyH)];
	if (isNil (QEGVAR(missionmodules,noCargoH))) then {EGVAR(missionmodules,noCargoH) = []};
	_HQ setVariable [QGVAR(noCargo),EGVAR(missionmodules,noCargoH)];
	if (isNil (QEGVAR(missionmodules,noFlankH))) then {EGVAR(missionmodules,noFlankH) = []};
	_HQ setVariable [QGVAR(noFlank),EGVAR(missionmodules,noFlankH)];
	if (isNil (QEGVAR(missionmodules,noDefH))) then {EGVAR(missionmodules,noDefH) = []};
	_HQ setVariable [QGVAR(noDef),EGVAR(missionmodules,noDefH)];
	if (isNil (QEGVAR(missionmodules,firstToFightH))) then {EGVAR(missionmodules,firstToFightH) = []};
	_HQ setVariable [QGVAR(firstToFight),EGVAR(missionmodules,firstToFightH)];
	if (isNil (QGVAR(voiceCommH))) then {GVAR(voiceCommH) = true};
	_HQ setVariable [QGVAR(voiceComm),GVAR(voiceCommH)];
	if (isNil (QEGVAR(missionmodules,frontH))) then {EGVAR(missionmodules,frontH) = false};
	_HQ setVariable [QGVAR(frontA),EGVAR(missionmodules,frontH)];
	if (isNil (QGVAR(lRelocatingH))) then {GVAR(lRelocatingH) = false};
	_HQ setVariable [QGVAR(lRelocating),GVAR(lRelocatingH)];
	if (isNil (QGVAR(fleeH))) then {GVAR(fleeH) = true};
	_HQ setVariable [QGVAR(flee),GVAR(fleeH)];
	if (isNil (QGVAR(garrRH))) then {GVAR(garrRH) = 500};
	_HQ setVariable [QGVAR(garrR),GVAR(garrRH)];
	if (isNil (QGVAR(rushH))) then {GVAR(rushH) = false};
	_HQ setVariable [QGVAR(rush),GVAR(rushH)];
	if (isNil (QGVAR(garrVehAbH))) then {GVAR(garrVehAbH) = false};
	_HQ setVariable [QGVAR(garrVehAb),GVAR(garrVehAbH)];
	if (isNil (QGVAR(defendObjectivesH))) then {GVAR(defendObjectivesH) = 4};
	_HQ setVariable [QGVAR(defendObjectives),GVAR(defendObjectivesH)];
	if (isNil (QGVAR(defSpotH))) then {GVAR(defSpotH) = []};
	_HQ setVariable [QGVAR(defSpot),GVAR(defSpotH)];
	if (isNil (QGVAR(recDefSpotH))) then {GVAR(recDefSpotH) = []};
	_HQ setVariable [QGVAR(recDefSpot),GVAR(recDefSpotH)];
	if (isNil QGVAR(flareH)) then {GVAR(flareH) = true};
	_HQ setVariable [QGVAR(flare),GVAR(flareH)];
	if (isNil QGVAR(smokeH)) then {GVAR(smokeH) = true};
	_HQ setVariable [QGVAR(smoke),GVAR(smokeH)];
	if (isNil QGVAR(noRecH)) then {GVAR(noRecH) = 1};
	_HQ setVariable [QGVAR(noRec),GVAR(noRecH)];
	if (isNil QGVAR(rapidCaptH)) then {GVAR(rapidCaptH) = 10};
	_HQ setVariable [QGVAR(rapidCapt),GVAR(rapidCaptH)];
	if (isNil QGVAR(muuH)) then {GVAR(muuH) = 1};
	_HQ setVariable [QGVAR(muu),GVAR(muuH)];
	if (isNil QGVAR(artyShellsH)) then {GVAR(artyShellsH) = 1};
	_HQ setVariable [QGVAR(artyShells),GVAR(artyShellsH)];
	if (isNil QGVAR(withdrawH)) then {GVAR(withdrawH) = 1};
	_HQ setVariable [QGVAR(withdraw),GVAR(withdrawH)];
	if (isNil QGVAR(berserkH)) then {GVAR(berserkH) = false};
	_HQ setVariable [QGVAR(berserk),GVAR(berserkH)];
	if (isNil QEGVAR(missionmodules,iDChanceH)) then {EGVAR(missionmodules,iDChanceH) = 100};
	_HQ setVariable [QGVAR(iDChance),EGVAR(missionmodules,iDChanceH)];
	if (isNil QEGVAR(missionmodules,rDChanceH)) then {EGVAR(missionmodules,rDChanceH) = 100};
	_HQ setVariable [QGVAR(rDChance),EGVAR(missionmodules,rDChanceH)];
	if (isNil QEGVAR(missionmodules,sDChanceH)) then {EGVAR(missionmodules,sDChanceH) = 100};
	_HQ setVariable [QGVAR(sDChance),EGVAR(missionmodules,sDChanceH)];
	if (isNil QEGVAR(missionmodules,ammoDropH)) then {EGVAR(missionmodules,ammoDropH) = []};
	_HQ setVariable [QGVAR(ammoDrop),EGVAR(missionmodules,ammoDropH)];
	if (isNil QGVAR(sFTargetsH)) then {GVAR(sFTargetsH) = []};
	_HQ setVariable [QGVAR(sFTargets),GVAR(sFTargetsH)];
	if (isNil QGVAR(lZH)) then {GVAR(lZH) = false};
	_HQ setVariable [QGVAR(lZ),GVAR(lZH)];
	if (isNil QEGVAR(missionmodules,sFBodyGuardH)) then {EGVAR(missionmodules,sFBodyGuardH) = []};
	_HQ setVariable [QGVAR(sFBodyGuard),EGVAR(missionmodules,sFBodyGuardH)];
	if (isNil QGVAR(dynFormH)) then {GVAR(dynFormH) = false};
	_HQ setVariable [QGVAR(dynForm),GVAR(dynFormH)];
	if (isNil QGVAR(unlimitedCaptH)) then {GVAR(unlimitedCaptH) = false};
	_HQ setVariable [QGVAR(unlimitedCapt),GVAR(unlimitedCaptH)];
	if (isNil QGVAR(captLimitH)) then {GVAR(captLimitH) = 10};
	_HQ setVariable [QGVAR(captLimit),GVAR(captLimitH)];
	if (isNil QGVAR(getHQInsideH)) then {GVAR(getHQInsideH) = false};
	_HQ setVariable [QGVAR(getHQInside),GVAR(getHQInsideH)];
	if (isNil QGVAR(wAH)) then {GVAR(wAH) = true};
	_HQ setVariable [QGVAR(wA),GVAR(wAH)];
	
	if (isNil QGVAR(infoMarkersH)) then {GVAR(infoMarkersH) = false};
	_HQ setVariable [QGVAR(infoMarkers),GVAR(infoMarkersH)];

	if (isNil QGVAR(artyMarksH)) then {GVAR(artyMarksH) = false};
	_HQ setVariable [QGVAR(artyMarks),GVAR(artyMarksH)];
	
	if (isNil (QGVAR(resetNowH))) then {GVAR(resetNowH) = false};
	_HQ setVariable [QGVAR(resetNow),GVAR(resetNowH)];
	if (isNil (QGVAR(resetOnDemandH))) then {GVAR(resetOnDemandH) = false};
	_HQ setVariable [QGVAR(resetOnDemand),GVAR(resetOnDemandH)];
	if (isNil (QGVAR(resetTimeH))) then {GVAR(resetTimeH) = 600};
	_HQ setVariable [QGVAR(resetTime),GVAR(resetTimeH)];
	if (isNil (QGVAR(combiningH))) then {GVAR(combiningH) = false};
	_HQ setVariable [QGVAR(combining),GVAR(combiningH)];
	if (isNil (QGVAR(objRadius1H))) then {GVAR(objRadius1H) = 300};
	_HQ setVariable [QGVAR(objRadius1),GVAR(objRadius1H)];
	if (isNil (QGVAR(objRadius2H))) then {GVAR(objRadius2H) = 500};
	_HQ setVariable [QGVAR(objRadius2),GVAR(objRadius2H)];
	if (isNil (QGVAR(knowTLH))) then {GVAR(knowTLH) = true};
	_HQ setVariable [QGVAR(knowTL),GVAR(knowTLH)];
	
	if (isNil (QGVAR(sMedH))) then {GVAR(sMedH) = true};
	_HQ setVariable [QGVAR(sMed),GVAR(sMedH)];
	if (isNil (QEGVAR(missionmodules,exMedicH))) then {EGVAR(missionmodules,exMedicH) = []};
	_HQ setVariable [QGVAR(exMedic),EGVAR(missionmodules,exMedicH)];
	if (isNil (QGVAR(medPointsH))) then {GVAR(medPointsH) = []};
	_HQ setVariable [QGVAR(medPoints),GVAR(medPointsH)];
	if (isNil (QGVAR(supportedGH))) then {GVAR(supportedGH) = []};
	_HQ setVariable [QGVAR(supportedG),GVAR(supportedGH)];
		
	if (isNil (QEGVAR(missionmodules,rCASH))) then {EGVAR(missionmodules,rCASH) = []};
	_HQ setVariable [QGVAR(rCAS),EGVAR(missionmodules,rCASH)];
	if (isNil (QEGVAR(missionmodules,rCAPH))) then {EGVAR(missionmodules,rCAPH) = []};
	_HQ setVariable [QGVAR(rCAP),EGVAR(missionmodules,rCAPH)];
	
	if (isNil (QGVAR(sFuelH))) then {GVAR(sFuelH) = true};
	_HQ setVariable [QGVAR(sFuel),GVAR(sFuelH)];
	if (isNil (QEGVAR(missionmodules,exRefuelH))) then {EGVAR(missionmodules,exRefuelH) = []};
	_HQ setVariable [QGVAR(exRefuel),EGVAR(missionmodules,exRefuelH)];
	if (isNil (QGVAR(fuelPointsH))) then {GVAR(fuelPointsH) = []};
	_HQ setVariable [QGVAR(fuelPoints),GVAR(fuelPointsH)];
	if (isNil (QGVAR(fSupportedGH))) then {GVAR(fSupportedGH) = []};
	_HQ setVariable [QGVAR(fSupportedG),GVAR(fSupportedGH)];
	
	if (isNil (QGVAR(sAmmoH))) then {GVAR(sAmmoH) = true};
	_HQ setVariable [QGVAR(sAmmo),GVAR(sAmmoH)];
	if (isNil (QEGVAR(missionmodules,exReammoH))) then {EGVAR(missionmodules,exReammoH) = []};
	_HQ setVariable [QGVAR(exReammo),EGVAR(missionmodules,exReammoH)];
	if (isNil (QGVAR(ammoPointsH))) then {GVAR(ammoPointsH) = []};
	_HQ setVariable [QGVAR(ammoPoints),GVAR(ammoPointsH)];
	if (isNil (QGVAR(aSupportedGH))) then {GVAR(aSupportedGH) = []};
	_HQ setVariable [QGVAR(aSupportedG),GVAR(aSupportedGH)];
	
	if (isNil (QGVAR(sRepH))) then {GVAR(sRepH) = true};
	_HQ setVariable [QGVAR(sRep),GVAR(sRepH)];
	if (isNil (QEGVAR(missionmodules,exRepairH))) then {EGVAR(missionmodules,exRepairH) = []};
	_HQ setVariable [QGVAR(exRepair),EGVAR(missionmodules,exRepairH)];
	if (isNil (QGVAR(repPointsH))) then {GVAR(repPointsH) = []};
	_HQ setVariable [QGVAR(repPoints),GVAR(repPointsH)];
	if (isNil (QGVAR(rSupportedGH))) then {GVAR(rSupportedGH) = []};
	_HQ setVariable [QGVAR(rSupportedG),GVAR(rSupportedGH)];
	
	if (isNil QGVAR(airDistH)) then {GVAR(airDistH) = 4000};
	_HQ setVariable [QGVAR(airDist),GVAR(airDistH)];
	
	if (isNil (QGVAR(commDelayH))) then {GVAR(commDelayH) = 1};
	_HQ setVariable [QGVAR(commDelay),GVAR(commDelayH)];


	// Per-letter override (string "DEFEND") wins; fall back to shared CBA boolean.
	private _orderSrc = if (isNil (QGVAR(orderH))) then {GVAR(order)} else {GVAR(orderH)};
	private _orderDefault = ["ATTACK", "DEFEND"] select ((_orderSrc isEqualType "") || {_orderSrc});
	_HQ setVariable [QGVAR(order), _orderDefault];

	if (isNil (QGVAR(attackAlwaysH))) then {GVAR(attackAlwaysH) = false};
	_HQ setVariable [QGVAR(attackAlways),GVAR(attackAlwaysH)];

	if (isNil (QGVAR(cRDefResH))) then {GVAR(cRDefResH) = 0};
	_HQ setVariable [QGVAR(cRDefRes),GVAR(cRDefResH)];

	if (isNil (QGVAR(reconReserveH))) then {GVAR(reconReserveH) = (0.3 * (0.5 + (_HQ getVariable [QGVAR(circumspection),0.5])))};
	_HQ setVariable [QGVAR(reconReserve),GVAR(reconReserveH)];
	if (isNil (QGVAR(exhaustedH))) then {GVAR(exhaustedH) = []};
	_HQ setVariable [QGVAR(exhausted),GVAR(exhaustedH)];
	if (isNil (QGVAR(attackReserveH))) then {GVAR(attackReserveH) = (0.5 * (0.5 + ((_HQ getVariable [QGVAR(circumspection),0.5])/1.5)))};
	_HQ setVariable [QGVAR(attackReserve),GVAR(attackReserveH)];
	if (isNil (QGVAR(idleOrdH))) then {GVAR(idleOrdH) = true};
	_HQ setVariable [QGVAR(idleOrd),GVAR(idleOrdH)];

	if (isNil (QGVAR(idleDefH))) then {GVAR(idleDefH) = true};
	_HQ setVariable [QGVAR(idleDef),GVAR(idleDefH)];

	if (isNil QEGVAR(missionmodules,idleDecoyH)) then {EGVAR(missionmodules,idleDecoyH) = objNull};
	_HQ setVariable [QGVAR(idleDecoy),EGVAR(missionmodules,idleDecoyH)];
	if (isNil QEGVAR(missionmodules,supportDecoyH)) then {EGVAR(missionmodules,supportDecoyH) = objNull};
	_HQ setVariable [QGVAR(supportDecoy),EGVAR(missionmodules,supportDecoyH)]; 
	if (isNil QEGVAR(missionmodules,restDecoyH)) then {EGVAR(missionmodules,restDecoyH) = objNull};
	_HQ setVariable [QGVAR(restDecoy),EGVAR(missionmodules,restDecoyH)]; 
	if (isNil QGVAR(sec1H)) then {GVAR(sec1H) = objNull};
	_HQ setVariable [QGVAR(sec1),GVAR(sec1H)]; 
	if (isNil QGVAR(sec2H)) then {GVAR(sec2H) = objNull};
	_HQ setVariable [QGVAR(sec2),GVAR(sec2H)]; 

	if (isNil QGVAR(supportRTBH)) then {GVAR(supportRTBH) = false};
	_HQ setVariable [QGVAR(supportRTB),GVAR(supportRTBH)];
	
	if (isNil QEGVAR(common,debugH)) then {EGVAR(common,debugH) = false};
	_HQ setVariable [QEGVAR(common,debug),EGVAR(common,debugH)]; 
	if (isNil QGVAR(debugIIH)) then {GVAR(debugIIH) = false};
	_HQ setVariable [QGVAR(debugII),GVAR(debugIIH)]; 
	
	if (isNil QEGVAR(missionmodules,alwaysKnownUH)) then {EGVAR(missionmodules,alwaysKnownUH) = []};
	_HQ setVariable [QGVAR(alwaysKnownU),EGVAR(missionmodules,alwaysKnownUH)];
	if (isNil QEGVAR(missionmodules,alwaysUnKnownUH)) then {EGVAR(missionmodules,alwaysUnKnownUH) = []};
	_HQ setVariable [QGVAR(alwaysUnKnownU),EGVAR(missionmodules,alwaysUnKnownUH)];
	
	if (isNil QEGVAR(missionmodules,aOnlyH)) then {EGVAR(missionmodules,aOnlyH) = []};
	_HQ setVariable [QGVAR(aOnly),EGVAR(missionmodules,aOnlyH)];
	if (isNil QEGVAR(missionmodules,rOnlyH)) then {EGVAR(missionmodules,rOnlyH) = []};
	_HQ setVariable [QGVAR(rOnly),EGVAR(missionmodules,rOnlyH)];
	
	if (isNil QGVAR(airEvacH)) then {GVAR(airEvacH) = false};
	_HQ setVariable [QGVAR(airEvac),GVAR(airEvacH)]; 
	
	if (isNil QGVAR(aAOH)) then {GVAR(aAOH) = false};
	_HQ setVariable [QGVAR(aAO),GVAR(aAOH)]; 
	if (isNil QGVAR(forceAAOH)) then {GVAR(forceAAOH) = false};
	_HQ setVariable [QGVAR(forceAAO),GVAR(forceAAOH)];

	if (isNil QGVAR(bBAOObjH)) then {GVAR(bBAOObjH) = 1};
	_HQ setVariable [QGVAR(bBAOObj),GVAR(bBAOObjH)]; 
	
	if (isNil (QGVAR(moraleConstH))) then {GVAR(moraleConstH) = 1};
	_HQ setVariable [QGVAR(moraleConst),GVAR(moraleConstH)];
	
	if (isNil (QGVAR(offTendH))) then {GVAR(offTendH) = 1};
	_HQ setVariable [QGVAR(offTend),GVAR(offTendH)];
	
	if (isNil QGVAR(eBDoctrineH)) then {GVAR(eBDoctrineH) = false};
	_HQ setVariable [QGVAR(eBDoctrine),GVAR(eBDoctrineH)]; 
	if (isNil QGVAR(forceEBDoctrineH)) then {GVAR(forceEBDoctrineH) = false};
	_HQ setVariable [QGVAR(forceEBDoctrine),GVAR(forceEBDoctrineH)];  
	
	if (isNil QGVAR(defRangeH)) then {GVAR(defRangeH) = 1};
	_HQ setVariable [QGVAR(defRange),GVAR(defRangeH)];
	if (isNil QGVAR(garrRangeH)) then {GVAR(garrRangeH) = 1};
	_HQ setVariable [QGVAR(garrRange),GVAR(garrRangeH)];
	
	if (isNil QGVAR(noCaptH)) then {GVAR(noCaptH) = []};
	_HQ setVariable [QGVAR(noCapt),GVAR(noCapt)];
	
	if (isNil QGVAR(attInfDistanceH)) then {GVAR(attInfDistanceH) = 1};
	_HQ setVariable [QGVAR(attInfDistance),GVAR(attInfDistanceH)];
	if (isNil QGVAR(attArmDistanceH)) then {GVAR(attArmDistanceH) = 1};
	_HQ setVariable [QGVAR(attArmDistance),GVAR(attArmDistanceH)];
	if (isNil QGVAR(attSnpDistanceH)) then {GVAR(attSnpDistanceH) = 1};
	_HQ setVariable [QGVAR(attSnpDistance),GVAR(attSnpDistanceH)];
	if (isNil QGVAR(captureDistanceH)) then {GVAR(captureDistanceH) = 1};
	_HQ setVariable [QGVAR(captureDistance),GVAR(captureDistanceH)];
	if (isNil QGVAR(flankDistanceH)) then {GVAR(flankDistanceH) = 1};
	_HQ setVariable [QGVAR(flankDistance),GVAR(flankDistanceH)];
	if (isNil QGVAR(attSFDistanceH)) then {GVAR(attSFDistanceH) = 1};
	_HQ setVariable [QGVAR(attSFDistance),GVAR(attSFDistanceH)];
	if (isNil QGVAR(reconDistanceH)) then {GVAR(reconDistanceH) = 1};
	_HQ setVariable [QGVAR(reconDistance),GVAR(reconDistanceH)];
	if (isNil QGVAR(uAVAltH)) then {GVAR(uAVAltH) = 150};
	_HQ setVariable [QEGVAR(common,uAVAlt),GVAR(uAVAltH)];
	
	if (isNil QGVAR(obj1H)) then {GVAR(obj1H) = createTrigger ["EmptyDetector", leaderHQH]};
	if (isNil QGVAR(obj2H)) then {GVAR(obj2H) = createTrigger ["EmptyDetector", leaderHQH]};
	if (isNil QGVAR(obj3H)) then {GVAR(obj3H) = createTrigger ["EmptyDetector", leaderHQH]};
	if (isNil QGVAR(obj4H)) then {GVAR(obj4H) = createTrigger ["EmptyDetector", leaderHQH]};
	
	_HQ setVariable [QGVAR(obj1),GVAR(obj1H)];
	_HQ setVariable [QGVAR(obj2),GVAR(obj2H)];
	_HQ setVariable [QGVAR(obj3),GVAR(obj3H)];
	_HQ setVariable [QGVAR(obj4),GVAR(obj4H)];
	
	_objectives = [GVAR(obj1H),GVAR(obj2H),GVAR(obj3H),GVAR(obj4H)];
	_NAVObjectives = [];

	if (isNil (QGVAR(simpleModeH))) then {GVAR(simpleModeH) = true};
	_HQ setVariable [QGVAR(simpleMode),GVAR(simpleModeH)];

	if (isNil (QGVAR(secTasksH))) then {GVAR(secTasksH) = false};
	_HQ setVariable [QGVAR(secTasks),GVAR(secTasksH)];
	
	if (isNil (QEGVAR(missionmodules,simpleObjsH))) then {EGVAR(missionmodules,simpleObjsH) = []};
	_HQ setVariable [QGVAR(simpleObjs),EGVAR(missionmodules,simpleObjsH)];

	if (isNil (QEGVAR(missionmodules,navalObjsH))) then {EGVAR(missionmodules,navalObjsH) = []};
	_HQ setVariable [QGVAR(navalObjs),EGVAR(missionmodules,navalObjsH)];

	if (isNil (QGVAR(maxSimpleObjsH))) then {GVAR(maxSimpleObjsH) = 5};
	_HQ setVariable [QGVAR(maxSimpleObjs),GVAR(maxSimpleObjsH)];

	if (_HQ getVariable [QGVAR(simpleMode),false]) then {

		_objectives = EGVAR(missionmodules,simpleObjsH);
		_NAVObjectives = EGVAR(missionmodules,navalObjsH);
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
			
	if not (isNil QGVAR(defFrontLH)) then {_HQ setVariable [QGVAR(defFrontL),GVAR(defFrontLH)]};
	if not (isNil QGVAR(defFront1H)) then {_HQ setVariable [QGVAR(defFront1),GVAR(defFront1H)]};
	if not (isNil QGVAR(defFront2H)) then {_HQ setVariable [QGVAR(defFront2),GVAR(defFront2H)]};
	if not (isNil QGVAR(defFront3H)) then {_HQ setVariable [QGVAR(defFront3),GVAR(defFront3H)]};
	if not (isNil QGVAR(defFront4H)) then {_HQ setVariable [QGVAR(defFront4),GVAR(defFront4H)]};
	
	_civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];
	if not (isNil (QGVAR(civFH))) then {_civF = GVAR(civFH)};
	_HQ setVariable [QGVAR(civF),_civF];
	
	if (isNil (QGVAR(defH))) then {GVAR(defH) = []};
	_HQ setVariable [QGVAR(def),GVAR(defH)];
	
	_nObj = _HQ getVariable [QGVAR(nObj),1];

	switch (_nObj) do
		{
		case (1) : {_HQ setVariable [QGVAR(obj),GVAR(obj1H)]};
		case (2) : {_HQ setVariable [QGVAR(obj),GVAR(obj2H)]};
		case (3) : {_HQ setVariable [QGVAR(obj),GVAR(obj3H)]};
		default {_HQ setVariable [QGVAR(obj),GVAR(obj4H)]};
		};
		
	[_HQ, _cycleC, _lastReset, [], _civF] call EFUNC(hac,statusQuo);
	};
