#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/HQSitRepB.sqf

_SCRname = "SitRepB";
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

if (isNil (QGVAR(mAttB))) then {GVAR(mAttB) = false};
_HQ setVariable [QGVAR(mAtt),GVAR(mAttB)];
if ((isNil (QGVAR(personalityB))) or not (_HQ getVariable [QGVAR(mAtt),false])) then {GVAR(personalityB) = "OTHER"};
_HQ setVariable [QGVAR(personality),GVAR(personalityB)];
	
if (isNil (QGVAR(recklessnessB))) then {GVAR(recklessnessB) = 0.5};
_HQ setVariable [QGVAR(recklessness),GVAR(recklessnessB)];
if (isNil (QGVAR(consistencyB))) then {GVAR(consistencyB) = 0.5};
_HQ setVariable [QGVAR(consistency),GVAR(consistencyB)];
if (isNil (QGVAR(activityB))) then {GVAR(activityB) = 0.5};
_HQ setVariable [QGVAR(activity),GVAR(activityB)];
if (isNil (QGVAR(reflexB))) then {GVAR(reflexB) = 0.5};
_HQ setVariable [QGVAR(reflex),GVAR(reflexB)];
if (isNil (QGVAR(circumspectionB))) then {GVAR(circumspectionB) = 0.5};
_HQ setVariable [QGVAR(circumspection),GVAR(circumspectionB)];
if (isNil (QGVAR(finenessB))) then {GVAR(finenessB) = 0.5};
_HQ setVariable [QGVAR(fineness),GVAR(finenessB)];

[_HQ] call FUNC(personality);

[[_HQ],EFUNC(hac,lhq)] call EFUNC(common,spawn);

if (isNil (QGVAR(boxedB))) then {GVAR(boxedB) = []};
_HQ setVariable [QGVAR(boxed),GVAR(boxedB)];

if (isNil (QEGVAR(missionmodules,ammoBoxesB))) then
	{
	EGVAR(missionmodules,ammoBoxesB) = [];

	if not (isNil QEGVAR(missionmodules,ammoDepotB)) then
		{
		_rds = (triggerArea EGVAR(missionmodules,ammoDepotB)) select 0;
		EGVAR(missionmodules,ammoBoxesB) = (getPosATL EGVAR(missionmodules,ammoDepotB)) nearObjects ["ReammoBox_F",_rds]
		}
	};

_HQ setVariable [QGVAR(ammoBoxes),EGVAR(missionmodules,ammoBoxesB)];

_HQ setVariable [QGVAR(reconDone),false];
_HQ setVariable [QGVAR(defDone),false];
_HQ setVariable [QGVAR(reconStage),1];
_HQ setVariable [QGVAR(reconStage2),1];
_HQ setVariable [QGVAR(airInDef),[]];

_KnEnPos = [];

if (isNil (QEGVAR(missionmodules,excludedB))) then {EGVAR(missionmodules,excludedB) = []};
_HQ setVariable [QEGVAR(common,excluded),EGVAR(missionmodules,excludedB)];
if (isNil (QGVAR(fastB))) then {GVAR(fastB) = false};
_HQ setVariable [QGVAR(fast),GVAR(fastB)];
if (isNil (QGVAR(exInfoB))) then {GVAR(exInfoB) = false};
_HQ setVariable [QGVAR(exInfo),GVAR(exInfoB)];
if (isNil (QGVAR(objHoldTimeB))) then {GVAR(objHoldTimeB) = 600};
_HQ setVariable [QGVAR(objHoldTime),GVAR(objHoldTimeB)];
if (isNil QGVAR(nObjB)) then {GVAR(nObjB) = 1};
_HQ setVariable [QGVAR(nObj),GVAR(nObjB)];

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

if (isNil (QGVAR(supportWPB))) then {GVAR(supportWPB) = false};
	
_HQ setVariable [QGVAR(supportWP),GVAR(supportWPB)];

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
	
	if (isNil QEGVAR(missionmodules,garrisonB)) then {EGVAR(missionmodules,garrisonB) = []};
	_HQ setVariable [QGVAR(garrison),EGVAR(missionmodules,garrisonB)];
	
	if (isNil (QGVAR(noAirCargoB))) then {GVAR(noAirCargoB) = false};
	_HQ setVariable [QGVAR(noAirCargo),GVAR(noAirCargoB)];
	if (isNil (QGVAR(noLandCargoB))) then {GVAR(noLandCargoB) = false};
	_HQ setVariable [QGVAR(noLandCargo),GVAR(noLandCargoB)];
	if (isNil (QGVAR(lastFriendsB))) then {GVAR(lastFriendsB) = []};
	_HQ setVariable [QGVAR(lastFriends),GVAR(lastFriendsB)];
	if (isNil (QGVAR(cargoFindB))) then {GVAR(cargoFindB) = 1};
	_HQ setVariable [QGVAR(cargoFind),GVAR(cargoFindB)];
	if (isNil (QGVAR(subordinatedB))) then {GVAR(subordinatedB) = []};
	_HQ setVariable [QGVAR(subordinated),GVAR(subordinatedB)];
	if (isNil (QEGVAR(missionmodules,includedB))) then {EGVAR(missionmodules,includedB) = []};
	_HQ setVariable [QGVAR(included),EGVAR(missionmodules,includedB)];
	if (isNil (QEGVAR(missionmodules,excludedB))) then {EGVAR(missionmodules,excludedB) = []};
	_HQ setVariable [QEGVAR(common,excluded),EGVAR(missionmodules,excludedB)];
	if (isNil (QGVAR(subAllB))) then {GVAR(subAllB) = true};
	_HQ setVariable [QGVAR(subAll),GVAR(subAllB)];
	if (isNil (QGVAR(subSynchroB))) then {GVAR(subSynchroB) = false};
	_HQ setVariable [QGVAR(subSynchro),GVAR(subSynchroB)];
	if (isNil (QGVAR(subNamedB))) then {GVAR(subNamedB) = false};
	_HQ setVariable [QGVAR(subNamed),GVAR(subNamedB)];
	if (isNil (QGVAR(subZeroB))) then {GVAR(subZeroB) = false};
	_HQ setVariable [QGVAR(subZero),GVAR(subZeroB)];
	if (isNil (QGVAR(reSynchroB))) then {GVAR(reSynchroB) = true};
	_HQ setVariable [QGVAR(reSynchro),GVAR(reSynchroB)];
	if (isNil (QGVAR(nameLimitB))) then {GVAR(nameLimitB) = 100};
	_HQ setVariable [QGVAR(nameLimit),GVAR(nameLimitB)];
	if (isNil (QGVAR(surrB))) then {GVAR(surrB) = false};
	_HQ setVariable [QGVAR(surr),GVAR(surrB)];
	if (isNil (QEGVAR(missionmodules,noReconB))) then {EGVAR(missionmodules,noReconB) = []};
	_HQ setVariable [QGVAR(noRecon),EGVAR(missionmodules,noReconB)];
	if (isNil (QEGVAR(missionmodules,noAttackB))) then {EGVAR(missionmodules,noAttackB) = []};
	_HQ setVariable [QGVAR(noAttack),EGVAR(missionmodules,noAttackB)];
	if (isNil (QEGVAR(missionmodules,cargoOnlyB))) then {EGVAR(missionmodules,cargoOnlyB) = []};
	_HQ setVariable [QGVAR(cargoOnly),EGVAR(missionmodules,cargoOnlyB)];
	if (isNil (QEGVAR(missionmodules,noCargoB))) then {EGVAR(missionmodules,noCargoB) = []};
	_HQ setVariable [QGVAR(noCargo),EGVAR(missionmodules,noCargoB)];
	if (isNil (QEGVAR(missionmodules,noFlankB))) then {EGVAR(missionmodules,noFlankB) = []};
	_HQ setVariable [QGVAR(noFlank),EGVAR(missionmodules,noFlankB)];
	if (isNil (QEGVAR(missionmodules,noDefB))) then {EGVAR(missionmodules,noDefB) = []};
	_HQ setVariable [QGVAR(noDef),EGVAR(missionmodules,noDefB)];
	if (isNil (QEGVAR(missionmodules,firstToFightB))) then {EGVAR(missionmodules,firstToFightB) = []};
	_HQ setVariable [QGVAR(firstToFight),EGVAR(missionmodules,firstToFightB)];
	if (isNil (QGVAR(voiceCommB))) then {GVAR(voiceCommB) = true};
	_HQ setVariable [QGVAR(voiceComm),GVAR(voiceCommB)];
	if (isNil (QEGVAR(missionmodules,frontB))) then {EGVAR(missionmodules,frontB) = false};
	_HQ setVariable [QGVAR(frontA),EGVAR(missionmodules,frontB)];
	if (isNil (QGVAR(lRelocatingB))) then {GVAR(lRelocatingB) = false};
	_HQ setVariable [QGVAR(lRelocating),GVAR(lRelocatingB)];
	if (isNil (QGVAR(fleeB))) then {GVAR(fleeB) = true};
	_HQ setVariable [QGVAR(flee),GVAR(fleeB)];
	if (isNil (QGVAR(garrRB))) then {GVAR(garrRB) = 500};
	_HQ setVariable [QGVAR(garrR),GVAR(garrRB)];
	if (isNil (QGVAR(rushB))) then {GVAR(rushB) = false};
	_HQ setVariable [QGVAR(rush),GVAR(rushB)];
	if (isNil (QGVAR(garrVehAbB))) then {GVAR(garrVehAbB) = false};
	_HQ setVariable [QGVAR(garrVehAb),GVAR(garrVehAbB)];
	if (isNil (QGVAR(defendObjectivesB))) then {GVAR(defendObjectivesB) = 4};
	_HQ setVariable [QGVAR(defendObjectives),GVAR(defendObjectivesB)];
	if (isNil (QGVAR(defSpotB))) then {GVAR(defSpotB) = []};
	_HQ setVariable [QGVAR(defSpot),GVAR(defSpotB)];
	if (isNil (QGVAR(recDefSpotB))) then {GVAR(recDefSpotB) = []};
	_HQ setVariable [QGVAR(recDefSpot),GVAR(recDefSpotB)];
	if (isNil QGVAR(flareB)) then {GVAR(flareB) = true};
	_HQ setVariable [QGVAR(flare),GVAR(flareB)];
	if (isNil QGVAR(smokeB)) then {GVAR(smokeB) = true};
	_HQ setVariable [QGVAR(smoke),GVAR(smokeB)];
	if (isNil QGVAR(noRecB)) then {GVAR(noRecB) = 1};
	_HQ setVariable [QGVAR(noRec),GVAR(noRecB)];
	if (isNil QGVAR(rapidCaptB)) then {GVAR(rapidCaptB) = 10};
	_HQ setVariable [QGVAR(rapidCapt),GVAR(rapidCaptB)];
	if (isNil QGVAR(muuB)) then {GVAR(muuB) = 1};
	_HQ setVariable [QGVAR(muu),GVAR(muuB)];
	if (isNil QGVAR(artyShellsB)) then {GVAR(artyShellsB) = 1};
	_HQ setVariable [QGVAR(artyShells),GVAR(artyShellsB)];
	if (isNil QGVAR(withdrawB)) then {GVAR(withdrawB) = 1};
	_HQ setVariable [QGVAR(withdraw),GVAR(withdrawB)];
	if (isNil QGVAR(berserkB)) then {GVAR(berserkB) = false};
	_HQ setVariable [QGVAR(berserk),GVAR(berserkB)];
	if (isNil QEGVAR(missionmodules,iDChanceB)) then {EGVAR(missionmodules,iDChanceB) = 100};
	_HQ setVariable [QGVAR(iDChance),EGVAR(missionmodules,iDChanceB)];
	if (isNil QEGVAR(missionmodules,rDChanceB)) then {EGVAR(missionmodules,rDChanceB) = 100};
	_HQ setVariable [QGVAR(rDChance),EGVAR(missionmodules,rDChanceB)];
	if (isNil QEGVAR(missionmodules,sDChanceB)) then {EGVAR(missionmodules,sDChanceB) = 100};
	_HQ setVariable [QGVAR(sDChance),EGVAR(missionmodules,sDChanceB)];
	if (isNil QEGVAR(missionmodules,ammoDropB)) then {EGVAR(missionmodules,ammoDropB) = []};
	_HQ setVariable [QGVAR(ammoDrop),EGVAR(missionmodules,ammoDropB)];
	if (isNil QGVAR(sFTargetsB)) then {GVAR(sFTargetsB) = []};
	_HQ setVariable [QGVAR(sFTargets),GVAR(sFTargetsB)];
	if (isNil QGVAR(lZB)) then {GVAR(lZB) = false};
	_HQ setVariable [QGVAR(lZ),GVAR(lZB)];
	if (isNil QEGVAR(missionmodules,sFBodyGuardB)) then {EGVAR(missionmodules,sFBodyGuardB) = []};
	_HQ setVariable [QGVAR(sFBodyGuard),EGVAR(missionmodules,sFBodyGuardB)];
	if (isNil QGVAR(dynFormB)) then {GVAR(dynFormB) = false};
	_HQ setVariable [QGVAR(dynForm),GVAR(dynFormB)];
	if (isNil QGVAR(unlimitedCaptB)) then {GVAR(unlimitedCaptB) = false};
	_HQ setVariable [QGVAR(unlimitedCapt),GVAR(unlimitedCaptB)];
	if (isNil QGVAR(captLimitB)) then {GVAR(captLimitB) = 10};
	_HQ setVariable [QGVAR(captLimit),GVAR(captLimitB)];
	if (isNil QGVAR(getHQInsideB)) then {GVAR(getHQInsideB) = false};
	_HQ setVariable [QGVAR(getHQInside),GVAR(getHQInsideB)];
	if (isNil QGVAR(wAB)) then {GVAR(wAB) = true};
	_HQ setVariable [QGVAR(wA),GVAR(wAB)];

	if (isNil QGVAR(infoMarkersB)) then {GVAR(infoMarkersB) = false};
	_HQ setVariable [QGVAR(infoMarkers),GVAR(infoMarkersB)];

	if (isNil QGVAR(artyMarksB)) then {GVAR(artyMarksB) = false};
	_HQ setVariable [QGVAR(artyMarks),GVAR(artyMarksB)];

	if (isNil (QGVAR(resetNowB))) then {GVAR(resetNowB) = false};
	_HQ setVariable [QGVAR(resetNow),GVAR(resetNowB)];
	if (isNil (QGVAR(resetOnDemandB))) then {GVAR(resetOnDemandB) = false};
	_HQ setVariable [QGVAR(resetOnDemand),GVAR(resetOnDemandB)];
	if (isNil (QGVAR(resetTimeB))) then {GVAR(resetTimeB) = 600};
	_HQ setVariable [QGVAR(resetTime),GVAR(resetTimeB)];
	if (isNil (QGVAR(combiningB))) then {GVAR(combiningB) = false};
	_HQ setVariable [QGVAR(combining),GVAR(combiningB)];
	if (isNil (QGVAR(objRadius1B))) then {GVAR(objRadius1B) = 300};
	_HQ setVariable [QGVAR(objRadius1),GVAR(objRadius1B)];
	if (isNil (QGVAR(objRadius2B))) then {GVAR(objRadius2B) = 500};
	_HQ setVariable [QGVAR(objRadius2),GVAR(objRadius2B)];
	if (isNil (QGVAR(knowTLB))) then {GVAR(knowTLB) = true};
	_HQ setVariable [QGVAR(knowTL),GVAR(knowTLB)];
	
	if (isNil (QGVAR(sMedB))) then {GVAR(sMedB) = true};
	_HQ setVariable [QGVAR(sMed),GVAR(sMedB)];
	if (isNil (QEGVAR(missionmodules,exMedicB))) then {EGVAR(missionmodules,exMedicB) = []};
	_HQ setVariable [QGVAR(exMedic),EGVAR(missionmodules,exMedicB)];
	if (isNil (QGVAR(medPointsB))) then {GVAR(medPointsB) = []};
	_HQ setVariable [QGVAR(medPoints),GVAR(medPointsB)];
	if (isNil (QGVAR(supportedGB))) then {GVAR(supportedGB) = []};
	_HQ setVariable [QGVAR(supportedG),GVAR(supportedGB)];

	if (isNil (QEGVAR(missionmodules,rCASB))) then {EGVAR(missionmodules,rCASB) = []};
	_HQ setVariable [QGVAR(rCAS),EGVAR(missionmodules,rCASB)];
	if (isNil (QEGVAR(missionmodules,rCAPB))) then {EGVAR(missionmodules,rCAPB) = []};
	_HQ setVariable [QGVAR(rCAP),EGVAR(missionmodules,rCAPB)];
	
	if (isNil (QGVAR(sFuelB))) then {GVAR(sFuelB) = true};
	_HQ setVariable [QGVAR(sFuel),GVAR(sFuelB)];
	if (isNil (QEGVAR(missionmodules,exRefuelB))) then {EGVAR(missionmodules,exRefuelB) = []};
	_HQ setVariable [QGVAR(exRefuel),EGVAR(missionmodules,exRefuelB)];
	if (isNil (QGVAR(fuelPointsB))) then {GVAR(fuelPointsB) = []};
	_HQ setVariable [QGVAR(fuelPoints),GVAR(fuelPointsB)];
	if (isNil (QGVAR(fSupportedGB))) then {GVAR(fSupportedGB) = []};
	_HQ setVariable [QGVAR(fSupportedG),GVAR(fSupportedGB)];
	
	if (isNil (QGVAR(sAmmoB))) then {GVAR(sAmmoB) = true};
	_HQ setVariable [QGVAR(sAmmo),GVAR(sAmmoB)];
	if (isNil (QEGVAR(missionmodules,exReammoB))) then {EGVAR(missionmodules,exReammoB) = []};
	_HQ setVariable [QGVAR(exReammo),EGVAR(missionmodules,exReammoB)];
	if (isNil (QGVAR(ammoPointsB))) then {GVAR(ammoPointsB) = []};
	_HQ setVariable [QGVAR(ammoPoints),GVAR(ammoPointsB)];
	if (isNil (QGVAR(aSupportedGB))) then {GVAR(aSupportedGB) = []};
	_HQ setVariable [QGVAR(aSupportedG),GVAR(aSupportedGB)];
	
	if (isNil (QGVAR(sRepB))) then {GVAR(sRepB) = true};
	_HQ setVariable [QGVAR(sRep),GVAR(sRepB)];
	if (isNil (QEGVAR(missionmodules,exRepairB))) then {EGVAR(missionmodules,exRepairB) = []};
	_HQ setVariable [QGVAR(exRepair),EGVAR(missionmodules,exRepairB)];
	if (isNil (QGVAR(repPointsB))) then {GVAR(repPointsB) = []};
	_HQ setVariable [QGVAR(repPoints),GVAR(repPointsB)];
	if (isNil (QGVAR(rSupportedGB))) then {GVAR(rSupportedGB) = []};
	_HQ setVariable [QGVAR(rSupportedG),GVAR(rSupportedGB)];
	
	if (isNil QGVAR(airDistB)) then {GVAR(airDistB) = 4000};
	_HQ setVariable [QGVAR(airDist),GVAR(airDistB)];
	
	if (isNil (QGVAR(commDelayB))) then {GVAR(commDelayB) = 1};
	_HQ setVariable [QGVAR(commDelay),GVAR(commDelayB)];


	// Per-letter override (string "DEFEND") wins; fall back to shared CBA boolean.
	private _orderSrc = if (isNil (QGVAR(orderB))) then {GVAR(order)} else {GVAR(orderB)};
	private _orderDefault = ["ATTACK", "DEFEND"] select ((_orderSrc isEqualType "") || {_orderSrc});
	_HQ setVariable [QGVAR(order), _orderDefault];

	if (isNil (QGVAR(attackAlwaysB))) then {GVAR(attackAlwaysB) = false};
	_HQ setVariable [QGVAR(attackAlways),GVAR(attackAlwaysB)];

	if (isNil (QGVAR(cRDefResB))) then {GVAR(cRDefResB) = 0};
	_HQ setVariable [QGVAR(cRDefRes),GVAR(cRDefResB)];


	if (isNil (QGVAR(reconReserveB))) then {GVAR(reconReserveB) = (0.3 * (0.5 + (_HQ getVariable [QGVAR(circumspection),0.5])))};
	_HQ setVariable [QGVAR(reconReserve),GVAR(reconReserveB)];
	if (isNil (QGVAR(exhaustedB))) then {GVAR(exhaustedB) = []};
	_HQ setVariable [QGVAR(exhausted),GVAR(exhaustedB)];
	if (isNil (QGVAR(attackReserveB))) then {GVAR(attackReserveB) = (0.5 * (0.5 + ((_HQ getVariable [QGVAR(circumspection),0.5])/1.5)))};
	_HQ setVariable [QGVAR(attackReserve),GVAR(attackReserveB)];
	if (isNil (QGVAR(idleOrdB))) then {GVAR(idleOrdB) = true};
	_HQ setVariable [QGVAR(idleOrd),GVAR(idleOrdB)];

	if (isNil (QGVAR(idleDefB))) then {GVAR(idleDefB) = true};
	_HQ setVariable [QGVAR(idleDef),GVAR(idleDefB)];

	if (isNil QEGVAR(missionmodules,idleDecoyB)) then {EGVAR(missionmodules,idleDecoyB) = objNull};
	_HQ setVariable [QGVAR(idleDecoy),EGVAR(missionmodules,idleDecoyB)];
	if (isNil QEGVAR(missionmodules,supportDecoyB)) then {EGVAR(missionmodules,supportDecoyB) = objNull};
	_HQ setVariable [QGVAR(supportDecoy),EGVAR(missionmodules,supportDecoyB)]; 
	if (isNil QEGVAR(missionmodules,restDecoyB)) then {EGVAR(missionmodules,restDecoyB) = objNull};
	_HQ setVariable [QGVAR(restDecoy),EGVAR(missionmodules,restDecoyB)]; 
	if (isNil QGVAR(sec1B)) then {GVAR(sec1B) = objNull};
	_HQ setVariable [QGVAR(sec1),GVAR(sec1B)]; 
	if (isNil QGVAR(sec2B)) then {GVAR(sec2B) = objNull};
	_HQ setVariable [QGVAR(sec2),GVAR(sec2B)];

	if (isNil QGVAR(supportRTBB)) then {GVAR(supportRTBB) = false};
	_HQ setVariable [QGVAR(supportRTB),GVAR(supportRTBB)];
	
	if (isNil QEGVAR(common,debugB)) then {EGVAR(common,debugB) = false};
	_HQ setVariable [QEGVAR(common,debug),EGVAR(common,debugB)]; 
	if (isNil QGVAR(debugIIB)) then {GVAR(debugIIB) = false};
	_HQ setVariable [QGVAR(debugII),GVAR(debugIIB)]; 
	
	if (isNil QEGVAR(missionmodules,alwaysKnownUB)) then {EGVAR(missionmodules,alwaysKnownUB) = []};
	_HQ setVariable [QGVAR(alwaysKnownU),EGVAR(missionmodules,alwaysKnownUB)];
	if (isNil QEGVAR(missionmodules,alwaysUnKnownUB)) then {EGVAR(missionmodules,alwaysUnKnownUB) = []};
	_HQ setVariable [QGVAR(alwaysUnKnownU),EGVAR(missionmodules,alwaysUnKnownUB)];

	if (isNil QEGVAR(missionmodules,aOnlyB)) then {EGVAR(missionmodules,aOnlyB) = []};
	_HQ setVariable [QGVAR(aOnly),EGVAR(missionmodules,aOnlyB)];
	if (isNil QEGVAR(missionmodules,rOnlyB)) then {EGVAR(missionmodules,rOnlyB) = []};
	_HQ setVariable [QGVAR(rOnly),EGVAR(missionmodules,rOnlyB)]; 
	
	if (isNil QGVAR(airEvacB)) then {GVAR(airEvacB) = false};
	_HQ setVariable [QGVAR(airEvac),GVAR(airEvacB)];
	
	if (isNil QGVAR(aAOB)) then {GVAR(aAOB) = false};
	_HQ setVariable [QGVAR(aAO),GVAR(aAOB)]; 
	if (isNil QGVAR(forceAAOB)) then {GVAR(forceAAOB) = false};
	_HQ setVariable [QGVAR(forceAAO),GVAR(forceAAOB)];
	
	if (isNil QGVAR(bBAOObjB)) then {GVAR(bBAOObjB) = 1};
	_HQ setVariable [QGVAR(bBAOObj),GVAR(bBAOObjB)]; 
	
	if (isNil (QGVAR(moraleConstB))) then {GVAR(moraleConstB) = 1};
	_HQ setVariable [QGVAR(moraleConst),GVAR(moraleConstB)];
	
	if (isNil (QGVAR(offTendB))) then {GVAR(offTendB) = 1};
	_HQ setVariable [QGVAR(offTend),GVAR(offTendB)];
	
	if (isNil QGVAR(eBDoctrineB)) then {GVAR(eBDoctrineB) = false};
	_HQ setVariable [QGVAR(eBDoctrine),GVAR(eBDoctrineB)]; 
	if (isNil QGVAR(forceEBDoctrineB)) then {GVAR(forceEBDoctrineB) = false};
	_HQ setVariable [QGVAR(forceEBDoctrine),GVAR(forceEBDoctrineB)]; 
	
	if (isNil QGVAR(defRangeB)) then {GVAR(defRangeB) = 1};
	_HQ setVariable [QGVAR(defRange),GVAR(defRangeB)];
	if (isNil QGVAR(garrRangeB)) then {GVAR(garrRangeB) = 1};
	_HQ setVariable [QGVAR(garrRange),GVAR(garrRangeB)];
		
	if (isNil QGVAR(noCaptB)) then {GVAR(noCaptB) = []};
	_HQ setVariable [QGVAR(noCapt),GVAR(noCapt)];
	
	if (isNil QGVAR(attInfDistanceB)) then {GVAR(attInfDistanceB) = 1};
	_HQ setVariable [QGVAR(attInfDistance),GVAR(attInfDistanceB)];
	if (isNil QGVAR(attArmDistanceB)) then {GVAR(attArmDistanceB) = 1};
	_HQ setVariable [QGVAR(attArmDistance),GVAR(attArmDistanceB)];
	if (isNil QGVAR(attSnpDistanceB)) then {GVAR(attSnpDistanceB) = 1};
	_HQ setVariable [QGVAR(attSnpDistance),GVAR(attSnpDistanceB)];
	if (isNil QGVAR(captureDistanceB)) then {GVAR(captureDistanceB) = 1};
	_HQ setVariable [QGVAR(captureDistance),GVAR(captureDistanceB)];	
	if (isNil QGVAR(flankDistanceB)) then {GVAR(flankDistanceB) = 1};
	_HQ setVariable [QGVAR(flankDistance),GVAR(flankDistanceB)];
	if (isNil QGVAR(attSFDistanceB)) then {GVAR(attSFDistanceB) = 1};
	_HQ setVariable [QGVAR(attSFDistance),GVAR(attSFDistanceB)];
	if (isNil QGVAR(reconDistanceB)) then {GVAR(reconDistanceB) = 1};
	_HQ setVariable [QGVAR(reconDistance),GVAR(reconDistanceB)];
	if (isNil QGVAR(uAVAltB)) then {GVAR(uAVAltB) = 150};
	_HQ setVariable [QEGVAR(common,uAVAlt),GVAR(uAVAltB)];

	if (isNil QGVAR(obj1B)) then {GVAR(obj1B) = createTrigger ["EmptyDetector", leaderHQB]};
	if (isNil QGVAR(obj2B)) then {GVAR(obj2B) = createTrigger ["EmptyDetector", leaderHQB]};
	if (isNil QGVAR(obj3B)) then {GVAR(obj3B) = createTrigger ["EmptyDetector", leaderHQB]};
	if (isNil QGVAR(obj4B)) then {GVAR(obj4B) = createTrigger ["EmptyDetector", leaderHQB]};
	
	_HQ setVariable [QGVAR(obj1),GVAR(obj1B)];
	_HQ setVariable [QGVAR(obj2),GVAR(obj2B)];
	_HQ setVariable [QGVAR(obj3),GVAR(obj3B)];
	_HQ setVariable [QGVAR(obj4),GVAR(obj4B)];
		
	_objectives = [GVAR(obj1B),GVAR(obj2B),GVAR(obj3B),GVAR(obj4B)];
	_NAVObjectives = [];

	if (isNil (QGVAR(simpleModeB))) then {GVAR(simpleModeB) = true};
	_HQ setVariable [QGVAR(simpleMode),GVAR(simpleModeB)];

	if (isNil (QEGVAR(missionmodules,navalObjsB))) then {EGVAR(missionmodules,navalObjsB) = []};
	_HQ setVariable [QGVAR(navalObjs),EGVAR(missionmodules,navalObjsB)];

	if (isNil (QGVAR(secTasksB))) then {GVAR(secTasksB) = false};
	_HQ setVariable [QGVAR(secTasks),GVAR(secTasksB)];

	if (isNil (QEGVAR(missionmodules,simpleObjsB))) then {EGVAR(missionmodules,simpleObjsB) = []};
	_HQ setVariable [QGVAR(simpleObjs),EGVAR(missionmodules,simpleObjsB)];

	if (isNil (QGVAR(maxSimpleObjsB))) then {GVAR(maxSimpleObjsB) = 5};
	_HQ setVariable [QGVAR(maxSimpleObjs),GVAR(maxSimpleObjsB)];

	if (_HQ getVariable [QGVAR(simpleMode),false]) then {

		_objectives = EGVAR(missionmodules,simpleObjsB);
		_NAVObjectives = EGVAR(missionmodules,navalObjsB);
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
			
	if not (isNil QGVAR(defFrontLB)) then {_HQ setVariable [QGVAR(defFrontL),GVAR(defFrontLB)]};
	if not (isNil QGVAR(defFront1B)) then {_HQ setVariable [QGVAR(defFront1),GVAR(defFront1B)]};
	if not (isNil QGVAR(defFront2B)) then {_HQ setVariable [QGVAR(defFront2),GVAR(defFront2B)]};
	if not (isNil QGVAR(defFront3B)) then {_HQ setVariable [QGVAR(defFront3),GVAR(defFront3B)]};
	if not (isNil QGVAR(defFront4B)) then {_HQ setVariable [QGVAR(defFront4),GVAR(defFront4B)]};
	
	_civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];
	if not (isNil (QGVAR(civFB))) then {_civF = GVAR(civFB)};
	_HQ setVariable [QGVAR(civF),_civF];
	
	if (isNil (QGVAR(defB))) then {GVAR(defB) = []};
	_HQ setVariable [QGVAR(def),GVAR(defB)];
	
	_nObj = _HQ getVariable [QGVAR(nObj),1];

	switch (_nObj) do
		{
		case (1) : {_HQ setVariable [QGVAR(obj),GVAR(obj1B)]};
		case (2) : {_HQ setVariable [QGVAR(obj),GVAR(obj2B)]};
		case (3) : {_HQ setVariable [QGVAR(obj),GVAR(obj3B)]};
		default {_HQ setVariable [QGVAR(obj),GVAR(obj4B)]};
		};
	
	[_HQ, _cycleC, _lastReset, [], _civF] call EFUNC(hac,statusQuo);
	};
