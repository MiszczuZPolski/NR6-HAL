#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/HQSitRepE.sqf

_SCRname = "SitRepE";
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

if (isNil (QGVAR(mAttE))) then {GVAR(mAttE) = false};
_HQ setVariable [QGVAR(mAtt),GVAR(mAttE)];
if ((isNil (QGVAR(personalityE))) or not (_HQ getVariable [QGVAR(mAtt),false])) then {GVAR(personalityE) = "OTHER"};
_HQ setVariable [QGVAR(personality),GVAR(personalityE)];

if (isNil (QGVAR(recklessnessE))) then {GVAR(recklessnessE) = 0.5};
_HQ setVariable [QGVAR(recklessness),GVAR(recklessnessE)];
if (isNil (QGVAR(consistencyE))) then {GVAR(consistencyE) = 0.5};
_HQ setVariable [QGVAR(consistency),GVAR(consistencyE)];
if (isNil (QGVAR(activityE))) then {GVAR(activityE) = 0.5};
_HQ setVariable [QGVAR(activity),GVAR(activityE)];
if (isNil (QGVAR(reflexE))) then {GVAR(reflexE) = 0.5};
_HQ setVariable [QGVAR(reflex),GVAR(reflexE)];
if (isNil (QGVAR(circumspectionE))) then {GVAR(circumspectionE) = 0.5};
_HQ setVariable [QGVAR(circumspection),GVAR(circumspectionE)];
if (isNil (QGVAR(finenessE))) then {GVAR(finenessE) = 0.5};
_HQ setVariable [QGVAR(fineness),GVAR(finenessE)];

[_HQ] call FUNC(personality);

[[_HQ],HAL_LHQ] call EFUNC(common,spawn);

if (isNil (QGVAR(boxedE))) then {GVAR(boxedE) = []};
_HQ setVariable [QGVAR(boxed),GVAR(boxedE)];

if (isNil (QGVAR(ammoBoxesE))) then 
	{
	GVAR(ammoBoxesE) = [];

	if not (isNil QGVAR(ammoDepotE)) then 
		{
		_rds = (triggerArea GVAR(ammoDepotE)) select 0;
		GVAR(ammoBoxesE) = (getPosATL GVAR(ammoDepotE)) nearObjects ["ReammoBox_F",_rds]
		}
	};
	
_HQ setVariable [QGVAR(ammoBoxes),GVAR(ammoBoxesE)];

_HQ setVariable [QGVAR(reconDone),false];
_HQ setVariable [QGVAR(defDone),false];
_HQ setVariable [QGVAR(reconStage),1];
_HQ setVariable [QGVAR(reconStage2),1];
_HQ setVariable [QGVAR(airInDef),[]];

_KnEnPos = [];

if (isNil (QGVAR(excludedE))) then {GVAR(excludedE) = []};
_HQ setVariable [QEGVAR(common,excluded),GVAR(excludedE)];
if (isNil (QGVAR(fastE))) then {GVAR(fastE) = false};
_HQ setVariable [QGVAR(fast),GVAR(fastE)];
if (isNil (QGVAR(exInfoE))) then {GVAR(exInfoE) = false};
_HQ setVariable [QGVAR(exInfo),GVAR(exInfoE)];
if (isNil (QGVAR(objHoldTimeE))) then {GVAR(objHoldTimeE) = 600};
_HQ setVariable [QGVAR(objHoldTime),GVAR(objHoldTimeE)];
if (isNil QGVAR(nObjE)) then {GVAR(nObjE) = 1};
_HQ setVariable [QGVAR(nObj),GVAR(nObjE)];

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

if (isNil (QGVAR(supportWPE))) then {GVAR(supportWPE) = false};
	
_HQ setVariable [QGVAR(supportWP),GVAR(supportWPE)];

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
	
	if (isNil QGVAR(garrisonE)) then {GVAR(garrisonE) = []};
	_HQ setVariable [QGVAR(garrison),GVAR(garrisonE)];
	
	if (isNil (QGVAR(noAirCargoE))) then {GVAR(noAirCargoE) = false};
	_HQ setVariable [QGVAR(noAirCargo),GVAR(noAirCargoE)];
	if (isNil (QGVAR(noLandCargoE))) then {GVAR(noLandCargoE) = false};
	_HQ setVariable [QGVAR(noLandCargo),GVAR(noLandCargoE)];
	if (isNil (QGVAR(lastFriendsE))) then {GVAR(lastFriendsE) = []};
	_HQ setVariable [QGVAR(lastFriends),GVAR(lastFriendsE)];
	if (isNil (QGVAR(cargoFindE))) then {GVAR(cargoFindE) = 1};
	_HQ setVariable [QGVAR(cargoFind),GVAR(cargoFindE)];
	if (isNil (QGVAR(subordinatedE))) then {GVAR(subordinatedE) = []};
	_HQ setVariable [QGVAR(subordinated),GVAR(subordinatedE)];
	if (isNil (QGVAR(includedE))) then {GVAR(includedE) = []};
	_HQ setVariable [QGVAR(included),GVAR(includedE)];
	if (isNil (QGVAR(excludedE))) then {GVAR(excludedE) = []};
	_HQ setVariable [QEGVAR(common,excluded),GVAR(excludedE)];
	if (isNil (QGVAR(subAllE))) then {GVAR(subAllE) = true};
	_HQ setVariable [QGVAR(subAll),GVAR(subAllE)];
	if (isNil (QGVAR(subSynchroE))) then {GVAR(subSynchroE) = false};
	_HQ setVariable [QGVAR(subSynchro),GVAR(subSynchroE)];
	if (isNil (QGVAR(subNamedE))) then {GVAR(subNamedE) = false};
	_HQ setVariable [QGVAR(subNamed),GVAR(subNamedE)];
	if (isNil (QGVAR(subZeroE))) then {GVAR(subZeroE) = false};
	_HQ setVariable [QGVAR(subZero),GVAR(subZeroE)];
	if (isNil (QGVAR(reSynchroE))) then {GVAR(reSynchroE) = true};
	_HQ setVariable [QGVAR(reSynchro),GVAR(reSynchroE)];
	if (isNil (QGVAR(nameLimitE))) then {GVAR(nameLimitE) = 100};
	_HQ setVariable [QGVAR(nameLimit),GVAR(nameLimitE)];
	if (isNil (QGVAR(surrE))) then {GVAR(surrE) = false};
	_HQ setVariable [QGVAR(surr),GVAR(surrE)];
	if (isNil (QGVAR(noReconE))) then {GVAR(noReconE) = []};
	_HQ setVariable [QGVAR(noRecon),GVAR(noReconE)];
	if (isNil (QGVAR(noAttackE))) then {GVAR(noAttackE) = []};
	_HQ setVariable [QGVAR(noAttack),GVAR(noAttackE)];
	if (isNil (QGVAR(cargoOnlyE))) then {GVAR(cargoOnlyE) = []};
	_HQ setVariable [QGVAR(cargoOnly),GVAR(cargoOnlyE)];
	if (isNil (QGVAR(noCargoE))) then {GVAR(noCargoE) = []};
	_HQ setVariable [QGVAR(noCargo),GVAR(noCargoE)];
	if (isNil (QGVAR(noFlankE))) then {GVAR(noFlankE) = []};
	_HQ setVariable [QGVAR(noFlank),GVAR(noFlankE)];
	if (isNil (QGVAR(noDefE))) then {GVAR(noDefE) = []};
	_HQ setVariable [QGVAR(noDef),GVAR(noDefE)];
	if (isNil (QGVAR(firstToFightE))) then {GVAR(firstToFightE) = []};
	_HQ setVariable [QGVAR(firstToFight),GVAR(firstToFightE)];
	if (isNil (QGVAR(voiceCommE))) then {GVAR(voiceCommE) = true};
	_HQ setVariable [QGVAR(voiceComm),GVAR(voiceCommE)];
	if (isNil (QGVAR(frontAE))) then {GVAR(frontE) = false};
	_HQ setVariable [QGVAR(frontA),GVAR(frontE)];
	if (isNil (QGVAR(lRelocatingE))) then {GVAR(lRelocatingE) = false};
	_HQ setVariable [QGVAR(lRelocating),GVAR(lRelocatingE)];
	if (isNil (QGVAR(fleeE))) then {GVAR(fleeE) = true};
	_HQ setVariable [QGVAR(flee),GVAR(fleeE)];
	if (isNil (QGVAR(garrRE))) then {GVAR(garrRE) = 500};
	_HQ setVariable [QGVAR(garrR),GVAR(garrRE)];
	if (isNil (QGVAR(rushE))) then {GVAR(rushE) = false};
	_HQ setVariable [QGVAR(rush),GVAR(rushE)];
	if (isNil (QGVAR(garrVehAbE))) then {GVAR(garrVehAbE) = false};
	_HQ setVariable [QGVAR(garrVehAb),GVAR(garrVehAbE)];
	if (isNil (QGVAR(defendObjectivesE))) then {GVAR(defendObjectivesE) = 4};
	_HQ setVariable [QGVAR(defendObjectives),GVAR(defendObjectivesE)];
	if (isNil (QGVAR(defSpotE))) then {GVAR(defSpotE) = []};
	_HQ setVariable [QGVAR(defSpot),GVAR(defSpotE)];
	if (isNil (QGVAR(recDefSpotE))) then {GVAR(recDefSpotE) = []};
	_HQ setVariable [QGVAR(recDefSpot),GVAR(recDefSpotE)];
	if (isNil QGVAR(flareE)) then {GVAR(flareE) = true};
	_HQ setVariable [QGVAR(flare),GVAR(flareE)];
	if (isNil QGVAR(smokeE)) then {GVAR(smokeE) = true};
	_HQ setVariable [QGVAR(smoke),GVAR(smokeE)];
	if (isNil QGVAR(noRecE)) then {GVAR(noRecE) = 1};
	_HQ setVariable [QGVAR(noRec),GVAR(noRecE)];
	if (isNil QGVAR(rapidCaptE)) then {GVAR(rapidCaptE) = 10};
	_HQ setVariable [QGVAR(rapidCapt),GVAR(rapidCaptE)];
	if (isNil QGVAR(muuE)) then {GVAR(muuE) = 1};
	_HQ setVariable [QGVAR(muu),GVAR(muuE)];
	if (isNil QGVAR(artyShellsE)) then {GVAR(artyShellsE) = 1};
	_HQ setVariable [QGVAR(artyShells),GVAR(artyShellsE)];
	if (isNil QGVAR(withdrawE)) then {GVAR(withdrawE) = 1};
	_HQ setVariable [QGVAR(withdraw),GVAR(withdrawE)];
	if (isNil QGVAR(berserkE)) then {GVAR(berserkE) = false};
	_HQ setVariable [QGVAR(berserk),GVAR(berserkE)];
	if (isNil QGVAR(iDChanceE)) then {GVAR(iDChanceE) = 100};
	_HQ setVariable [QGVAR(iDChance),GVAR(iDChanceE)];
	if (isNil QGVAR(rDChanceE)) then {GVAR(rDChanceE) = 100};
	_HQ setVariable [QGVAR(rDChance),GVAR(rDChanceE)];
	if (isNil QGVAR(sDChanceE)) then {GVAR(sDChanceE) = 100};
	_HQ setVariable [QGVAR(sDChance),GVAR(sDChanceE)];
	if (isNil QGVAR(ammoDropE)) then {GVAR(ammoDropE) = []};
	_HQ setVariable [QGVAR(ammoDrop),GVAR(ammoDropE)];
	if (isNil QGVAR(sFTargetsE)) then {GVAR(sFTargetsE) = []};
	_HQ setVariable [QGVAR(sFTargets),GVAR(sFTargetsE)];
	if (isNil QGVAR(lZE)) then {GVAR(lZE) = false};
	_HQ setVariable [QGVAR(lZ),GVAR(lZE)];
	if (isNil QGVAR(sFBodyGuardE)) then {GVAR(sFBodyGuardE) = []};
	_HQ setVariable [QGVAR(sFBodyGuard),GVAR(sFBodyGuardE)];
	if (isNil QGVAR(dynFormE)) then {GVAR(dynFormE) = false};
	_HQ setVariable [QGVAR(dynForm),GVAR(dynFormE)];
	if (isNil QGVAR(unlimitedCaptE)) then {GVAR(unlimitedCaptE) = false};
	_HQ setVariable [QGVAR(unlimitedCapt),GVAR(unlimitedCaptE)];
	if (isNil QGVAR(captLimitE)) then {GVAR(captLimitE) = 10};
	_HQ setVariable [QGVAR(captLimit),GVAR(captLimitE)];
	if (isNil QGVAR(getHQInsideE)) then {GVAR(getHQInsideE) = false};
	_HQ setVariable [QGVAR(getHQInside),GVAR(getHQInsideE)];
	if (isNil QGVAR(wAE)) then {GVAR(wAE) = true};
	_HQ setVariable [QGVAR(wA),GVAR(wAE)];

	if (isNil QGVAR(infoMarkersE)) then {GVAR(infoMarkersE) = false};
	_HQ setVariable [QGVAR(infoMarkers),GVAR(infoMarkersE)];
	
	if (isNil QGVAR(artyMarksE)) then {GVAR(artyMarksE) = false};
	_HQ setVariable [QGVAR(artyMarks),GVAR(artyMarksE)];
	
	if (isNil (QGVAR(resetNowE))) then {GVAR(resetNowE) = false};
	_HQ setVariable [QGVAR(resetNow),GVAR(resetNowE)];
	if (isNil (QGVAR(resetOnDemandE))) then {GVAR(resetOnDemandE) = false};
	_HQ setVariable [QGVAR(resetOnDemand),GVAR(resetOnDemandE)];
	if (isNil (QGVAR(resetTimeE))) then {GVAR(resetTimeE) = 600};
	_HQ setVariable [QGVAR(resetTime),GVAR(resetTimeE)];
	if (isNil (QGVAR(combiningE))) then {GVAR(combiningE) = false};
	_HQ setVariable [QGVAR(combining),GVAR(combiningE)];
	if (isNil (QGVAR(objRadius1E))) then {GVAR(objRadius1E) = 300};
	_HQ setVariable [QGVAR(objRadius1),GVAR(objRadius1E)];
	if (isNil (QGVAR(objRadius2E))) then {GVAR(objRadius2E) = 500};
	_HQ setVariable [QGVAR(objRadius2),GVAR(objRadius2E)];
	if (isNil (QGVAR(knowTLE))) then {GVAR(knowTLE) = true};
	_HQ setVariable [QGVAR(knowTL),GVAR(knowTLE)];
	
	if (isNil (QGVAR(sMedE))) then {GVAR(sMedE) = true};
	_HQ setVariable [QGVAR(sMed),GVAR(sMedE)];
	if (isNil (QGVAR(exMedicE))) then {GVAR(exMedicE) = []};
	_HQ setVariable [QGVAR(exMedic),GVAR(exMedicE)];
	if (isNil (QGVAR(medPointsE))) then {GVAR(medPointsE) = []};
	_HQ setVariable [QGVAR(medPoints),GVAR(medPointsE)];
	if (isNil (QGVAR(supportedGE))) then {GVAR(supportedGE) = []};
	_HQ setVariable [QGVAR(supportedG),GVAR(supportedGE)];
		
	if (isNil (QGVAR(rCASE))) then {GVAR(rCASE) = []};
	_HQ setVariable [QGVAR(rCAS),GVAR(rCASE)];
	if (isNil (QGVAR(rCAPE))) then {GVAR(rCAPE) = []};
	_HQ setVariable [QGVAR(rCAP),GVAR(rCAPE)];
	
	if (isNil (QGVAR(sFuelE))) then {GVAR(sFuelE) = true};
	_HQ setVariable [QGVAR(sFuel),GVAR(sFuelE)];
	if (isNil (QGVAR(exRefuelE))) then {GVAR(exRefuelE) = []};
	_HQ setVariable [QGVAR(exRefuel),GVAR(exRefuelE)];
	if (isNil (QGVAR(fuelPointsE))) then {GVAR(fuelPointsE) = []};
	_HQ setVariable [QGVAR(fuelPoints),GVAR(fuelPointsE)];
	if (isNil (QGVAR(fSupportedGE))) then {GVAR(fSupportedGE) = []};
	_HQ setVariable [QGVAR(fSupportedG),GVAR(fSupportedGE)];
	
	if (isNil (QGVAR(sAmmoE))) then {GVAR(sAmmoE) = true};
	_HQ setVariable [QGVAR(sAmmo),GVAR(sAmmoE)];
	if (isNil (QGVAR(exReammoE))) then {GVAR(exReammoE) = []};
	_HQ setVariable [QGVAR(exReammo),GVAR(exReammoE)];
	if (isNil (QGVAR(ammoPointsE))) then {GVAR(ammoPointsE) = []};
	_HQ setVariable [QGVAR(ammoPoints),GVAR(ammoPointsE)];
	if (isNil (QGVAR(aSupportedGE))) then {GVAR(aSupportedGE) = []};
	_HQ setVariable [QGVAR(aSupportedG),GVAR(aSupportedGE)];
	
	if (isNil (QGVAR(sRepE))) then {GVAR(sRepE) = true};
	_HQ setVariable [QGVAR(sRep),GVAR(sRepE)];
	if (isNil (QGVAR(exRepairE))) then {GVAR(exRepairE) = []};
	_HQ setVariable [QGVAR(exRepair),GVAR(exRepairE)];
	if (isNil (QGVAR(repPointsE))) then {GVAR(repPointsE) = []};
	_HQ setVariable [QGVAR(repPoints),GVAR(repPointsE)];
	if (isNil (QGVAR(rSupportedGE))) then {GVAR(rSupportedGE) = []};
	_HQ setVariable [QGVAR(rSupportedG),GVAR(rSupportedGE)];
	
	if (isNil QGVAR(airDistE)) then {GVAR(airDistE) = 4000};
	_HQ setVariable [QGVAR(airDist),GVAR(airDistE)];
	
	if (isNil (QGVAR(commDelayE))) then {GVAR(commDelayE) = 1};
	_HQ setVariable [QGVAR(commDelay),GVAR(commDelayE)];


	if ((isNil (QGVAR(orderE))) and (isNil {_HQ getVariable QGVAR(order)})) then {_HQ setVariable [QGVAR(order),"ATTACK"]};
	if ( not (isNil (QGVAR(orderE)))) then {
		if (GVAR(orderE) == "DEFEND") then {
			_HQ setVariable [QGVAR(order),"DEFEND"]
		} else {
			_HQ setVariable [QGVAR(order),"ATTACK"]
		};
	};

	if (isNil (QGVAR(attackAlwaysE))) then {GVAR(attackAlwaysE) = false};
	_HQ setVariable [QGVAR(attackAlways),GVAR(attackAlwaysE)];

	if (isNil (QGVAR(cRDefResE))) then {GVAR(cRDefResE) = 0};
	_HQ setVariable [QGVAR(cRDefRes),GVAR(cRDefResE)];

	if (isNil (QGVAR(reconReserveE))) then {GVAR(reconReserveE) = (0.3 * (0.5 + (_HQ getVariable [QGVAR(circumspection),0.5])))};
	_HQ setVariable [QGVAR(reconReserve),GVAR(reconReserveE)];
	if (isNil (QGVAR(exhaustedE))) then {GVAR(exhaustedE) = []};
	_HQ setVariable [QGVAR(exhausted),GVAR(exhaustedE)];
	if (isNil (QGVAR(attackReserveE))) then {GVAR(attackReserveE) = (0.5 * (0.5 + ((_HQ getVariable [QGVAR(circumspection),0.5])/1.5)))};
	_HQ setVariable [QGVAR(attackReserve),GVAR(attackReserveE)];
	if (isNil (QGVAR(idleOrdE))) then {GVAR(idleOrdE) = true};
	_HQ setVariable [QGVAR(idleOrd),GVAR(idleOrdE)];

	if (isNil (QGVAR(idleDefE))) then {GVAR(idleDefE) = true};
	_HQ setVariable [QGVAR(idleDef),GVAR(idleDefE)];

	if (isNil QGVAR(idleDecoyE)) then {GVAR(idleDecoyE) = objNull};
	_HQ setVariable [QGVAR(idleDecoy),GVAR(idleDecoyE)]; 
	if (isNil QGVAR(supportDecoyE)) then {GVAR(supportDecoyE) = objNull};
	_HQ setVariable [QGVAR(supportDecoy),GVAR(supportDecoyE)]; 
	if (isNil QGVAR(restDecoyE)) then {GVAR(restDecoyE) = objNull};
	_HQ setVariable [QGVAR(restDecoy),GVAR(restDecoyE)]; 
	if (isNil QGVAR(sec1E)) then {GVAR(sec1E) = objNull};
	_HQ setVariable [QGVAR(sec1),GVAR(sec1E)]; 
	if (isNil QGVAR(sec2E)) then {GVAR(sec2E) = objNull};
	_HQ setVariable [QGVAR(sec2),GVAR(sec2E)];

	if (isNil QGVAR(supportRTBE)) then {GVAR(supportRTBE) = false};
	_HQ setVariable [QGVAR(supportRTB),GVAR(supportRTBE)];
	
	if (isNil QEGVAR(common,debugE)) then {EGVAR(common,debugE) = false};
	_HQ setVariable [QEGVAR(common,debug),EGVAR(common,debugE)]; 
	if (isNil QGVAR(debugIIE)) then {GVAR(debugIIE) = false};
	_HQ setVariable [QGVAR(debugII),GVAR(debugIIE)]; 
	
	if (isNil QGVAR(alwaysKnownUE)) then {GVAR(alwaysKnownUE) = []};
	_HQ setVariable [QGVAR(alwaysKnownU),GVAR(alwaysKnownUE)]; 
	if (isNil QGVAR(alwaysUnKnownUE)) then {GVAR(alwaysUnKnownUE) = []};
	_HQ setVariable [QGVAR(alwaysUnKnownU),GVAR(alwaysUnKnownUE)];
	
 	if (isNil QGVAR(aOnlyE)) then {GVAR(aOnlyE) = []};
	_HQ setVariable [QGVAR(aOnly),GVAR(aOnlyE)]; 
	if (isNil QGVAR(rOnlyE)) then {GVAR(rOnlyE) = []};
	_HQ setVariable [QGVAR(rOnly),GVAR(rOnlyE)]; 
	
	if (isNil QGVAR(airEvacE)) then {GVAR(airEvacE) = false};
	_HQ setVariable [QGVAR(airEvac),GVAR(airEvacE)]; 
	
	if (isNil QGVAR(aAOE)) then {GVAR(aAOE) = false};
	_HQ setVariable [QGVAR(aAO),GVAR(aAOE)]; 
	if (isNil QGVAR(forceAAOE)) then {GVAR(forceAAOE) = false};
	_HQ setVariable [QGVAR(forceAAO),GVAR(forceAAOE)];
	

	if (isNil QGVAR(bBAOObjE)) then {GVAR(bBAOObjE) = 1};
	_HQ setVariable [QGVAR(bBAOObj),GVAR(bBAOObjE)]; 
	
	if (isNil (QGVAR(moraleConstE))) then {GVAR(moraleConstE) = 1};
	_HQ setVariable [QGVAR(moraleConst),GVAR(moraleConstE)];
	
	if (isNil (QGVAR(offTendE))) then {GVAR(offTendE) = 1};
	_HQ setVariable [QGVAR(offTend),GVAR(offTendE)];
	
	if (isNil QGVAR(eBDoctrineE)) then {GVAR(eBDoctrineE) = false};
	_HQ setVariable [QGVAR(eBDoctrine),GVAR(eBDoctrineE)]; 
	if (isNil QGVAR(forceEBDoctrineE)) then {GVAR(forceEBDoctrineE) = false};
	_HQ setVariable [QGVAR(forceEBDoctrine),GVAR(forceEBDoctrineE)]; 

	if (isNil QGVAR(defRangeE)) then {GVAR(defRangeE) = 1};
	_HQ setVariable [QGVAR(defRange),GVAR(defRangeE)];
	if (isNil QGVAR(garrRangeE)) then {GVAR(garrRangeE) = 1};
	_HQ setVariable [QGVAR(garrRange),GVAR(garrRangeE)];
	
	if (isNil QGVAR(noCaptE)) then {GVAR(noCaptE) = []};
	_HQ setVariable [QGVAR(noCapt),GVAR(noCapt)];
	
	if (isNil QGVAR(attInfDistanceE)) then {GVAR(attInfDistanceE) = 1};
	_HQ setVariable [QGVAR(attInfDistance),GVAR(attInfDistanceE)];
	if (isNil QGVAR(attArmDistanceE)) then {GVAR(attArmDistanceE) = 1};
	_HQ setVariable [QGVAR(attArmDistance),GVAR(attArmDistanceE)];
	if (isNil QGVAR(attSnpDistanceE)) then {GVAR(attSnpDistanceE) = 1};
	_HQ setVariable [QGVAR(attSnpDistance),GVAR(attSnpDistanceE)];
	if (isNil QGVAR(captureDistanceE)) then {GVAR(captureDistanceE) = 1};
	_HQ setVariable [QGVAR(captureDistance),GVAR(captureDistanceE)];	
	if (isNil QGVAR(flankDistanceE)) then {GVAR(flankDistanceE) = 1};
	_HQ setVariable [QGVAR(flankDistance),GVAR(flankDistanceE)];
	if (isNil QGVAR(attSFDistanceE)) then {GVAR(attSFDistanceE) = 1};
	_HQ setVariable [QGVAR(attSFDistance),GVAR(attSFDistanceE)];
	if (isNil QGVAR(reconDistanceE)) then {GVAR(reconDistanceE) = 1};
	_HQ setVariable [QGVAR(reconDistance),GVAR(reconDistanceE)];
	if (isNil QGVAR(uAVAltE)) then {GVAR(uAVAltE) = 150};
	_HQ setVariable [QEGVAR(common,uAVAlt),GVAR(uAVAltE)];
	
	if (isNil QGVAR(obj1E)) then {GVAR(obj1E) = createTrigger ["EmptyDetector", leaderHQE]};
	if (isNil QGVAR(obj2E)) then {GVAR(obj2E) = createTrigger ["EmptyDetector", leaderHQE]};
	if (isNil QGVAR(obj3E)) then {GVAR(obj3E) = createTrigger ["EmptyDetector", leaderHQE]};
	if (isNil QGVAR(obj4E)) then {GVAR(obj4E) = createTrigger ["EmptyDetector", leaderHQE]};
	
	_HQ setVariable [QGVAR(obj1),GVAR(obj1E)];
	_HQ setVariable [QGVAR(obj2),GVAR(obj2E)];
	_HQ setVariable [QGVAR(obj3),GVAR(obj3E)];
	_HQ setVariable [QGVAR(obj4),GVAR(obj4E)];
	
	_objectives = [GVAR(obj1E),GVAR(obj2E),GVAR(obj3E),GVAR(obj4E)];
	_NAVObjectives = [];

	if (isNil (QGVAR(simpleModeE))) then {GVAR(simpleModeE) = true};
	_HQ setVariable [QGVAR(simpleMode),GVAR(simpleModeE)];

	if (isNil (QGVAR(secTasksE))) then {GVAR(secTasksE) = false};
	_HQ setVariable [QGVAR(secTasks),GVAR(secTasksE)];
	
	if (isNil (QGVAR(simpleObjsE))) then {GVAR(simpleObjsE) = []};
	_HQ setVariable [QGVAR(simpleObjs),GVAR(simpleObjsE)];

	if (isNil (QGVAR(navalObjsE))) then {GVAR(navalObjsE) = []};
	_HQ setVariable [QGVAR(navalObjs),GVAR(navalObjsE)];

	if (isNil (QGVAR(maxSimpleObjsE))) then {GVAR(maxSimpleObjsE) = 5};
	_HQ setVariable [QGVAR(maxSimpleObjs),GVAR(maxSimpleObjsE)];

	if (_HQ getVariable [QGVAR(simpleMode),false]) then {

		_objectives = GVAR(simpleObjsE);
		_NAVObjectives = GVAR(navalObjsE);
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
				
	if not (isNil QGVAR(defFrontLE)) then {_HQ setVariable [QGVAR(defFrontL),GVAR(defFrontLE)]};
	if not (isNil QGVAR(defFront1E)) then {_HQ setVariable [QGVAR(defFront1),GVAR(defFront1E)]};
	if not (isNil QGVAR(defFront2E)) then {_HQ setVariable [QGVAR(defFront2),GVAR(defFront2E)]};
	if not (isNil QGVAR(defFront3E)) then {_HQ setVariable [QGVAR(defFront3),GVAR(defFront3E)]};
	if not (isNil QGVAR(defFront4E)) then {_HQ setVariable [QGVAR(defFront4),GVAR(defFront4E)]};
	
	_civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];
	if not (isNil (QGVAR(civFE))) then {_civF = GVAR(civFE)};
	_HQ setVariable [QGVAR(civF),_civF];
	
	if (isNil (QGVAR(defE))) then {GVAR(defE) = []};
	_HQ setVariable [QGVAR(def),GVAR(defE)];
	
	_nObj = _HQ getVariable [QGVAR(nObj),1];

	switch (_nObj) do
		{
		case (1) : {_HQ setVariable [QGVAR(obj),GVAR(obj1E)]};
		case (2) : {_HQ setVariable [QGVAR(obj),GVAR(obj2E)]};
		case (3) : {_HQ setVariable [QGVAR(obj),GVAR(obj3E)]};
		default {_HQ setVariable [QGVAR(obj),GVAR(obj4E)]};
		};
		
	call GVAR(statusQuo);
	};
