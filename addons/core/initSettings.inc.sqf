// initSettings.inc.sqf
// CBA_fnc_addSetting registration for all HAL configurable options.
// Included from XEH_preInit.sqf. LLSTRING() macros in this file resolve
// against addons/core/stringtable.xml (STR_hal_core_*).
//
// Scope: 1 = server (publicVariable'd), 0 = client-only.
// Defaults preserved verbatim from addons/missionmodules/CfgVehicles.hpp
// so CBA settings produce identical behaviour to the legacy editor-module
// defaults. Per D-02, editor module arguments still override per-HQ.

// ============================================================
// HAL General Settings
// ============================================================
[
    QEGVAR(core,reconCargo), "CHECKBOX",
    [LLSTRING(reconCargo), LLSTRING(reconCargo_desc)],
    LLSTRING(category_general),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,synchroAttack), "CHECKBOX",
    [LLSTRING(synchroAttack), LLSTRING(synchroAttack_desc)],
    LLSTRING(category_general),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,hQChat), "CHECKBOX",
    [LLSTRING(hQChat), LLSTRING(hQChat_desc)],
    LLSTRING(category_general),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,aIChatDensity), "SLIDER",
    [LLSTRING(aIChatDensity), LLSTRING(aIChatDensity_desc)],
    LLSTRING(category_general),
    [0, 100, 100, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,aIChat_Type), "LIST",
    [LLSTRING(aIChat_Type), LLSTRING(aIChat_Type_desc)],
    LLSTRING(category_general),
    [["NONE","SILENT_M","40K_IMPERIUM"], ["Default (Original HAC recordings)","Only Radio Static","Imperium Of Man (40K)"], 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,infoMarkersID), "CHECKBOX",
    [LLSTRING(infoMarkersID), LLSTRING(infoMarkersID_desc)],
    LLSTRING(category_general),
    true, 0
] call CBA_fnc_addSetting;

[
    QEGVAR(core,actions), "CHECKBOX",
    [LLSTRING(actions), LLSTRING(actions_desc)],
    LLSTRING(category_general),
    true, 0
] call CBA_fnc_addSetting;

[
    QEGVAR(core,actionsMenu), "CHECKBOX",
    [LLSTRING(actionsMenu), LLSTRING(actionsMenu_desc)],
    LLSTRING(category_general),
    true, 0
] call CBA_fnc_addSetting;

[
    QEGVAR(core,taskActions), "CHECKBOX",
    [LLSTRING(taskActions), LLSTRING(taskActions_desc)],
    LLSTRING(category_general),
    false, 0
] call CBA_fnc_addSetting;

[
    QEGVAR(core,supportActions), "CHECKBOX",
    [LLSTRING(supportActions), LLSTRING(supportActions_desc)],
    LLSTRING(category_general),
    false, 0
] call CBA_fnc_addSetting;

[
    QEGVAR(core,actionsAceOnly), "CHECKBOX",
    [LLSTRING(actionsAceOnly), LLSTRING(actionsAceOnly_desc)],
    LLSTRING(category_general),
    false, 0
] call CBA_fnc_addSetting;

[
    QEGVAR(core,noRestPlayers), "CHECKBOX",
    [LLSTRING(noRestPlayers), LLSTRING(noRestPlayers_desc)],
    LLSTRING(category_general),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,noCargoPlayers), "CHECKBOX",
    [LLSTRING(noCargoPlayers), LLSTRING(noCargoPlayers_desc)],
    LLSTRING(category_general),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,disembarkRange), "SLIDER",
    [LLSTRING(disembarkRange), LLSTRING(disembarkRange_desc)],
    LLSTRING(category_general),
    [0, 2000, 200, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,cargoObjRange), "SLIDER",
    [LLSTRING(cargoObjRange), LLSTRING(cargoObjRange_desc)],
    LLSTRING(category_general),
    [0, 10000, 1500, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,lZ), "CHECKBOX",
    [LLSTRING(lZ), LLSTRING(lZ_desc)],
    LLSTRING(category_general),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,garrisonV2), "CHECKBOX",
    [LLSTRING(garrisonV2), LLSTRING(garrisonV2_desc)],
    LLSTRING(category_general),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,nEAware), "SLIDER",
    [LLSTRING(nEAware), LLSTRING(nEAware_desc)],
    LLSTRING(category_general),
    [0, 5000, 500, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,slingDrop), "CHECKBOX",
    [LLSTRING(slingDrop), LLSTRING(slingDrop_desc)],
    LLSTRING(category_general),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,rHQAutoFill), "CHECKBOX",
    [LLSTRING(rHQAutoFill), LLSTRING(rHQAutoFill_desc)],
    LLSTRING(category_general),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,pathFinding), "SLIDER",
    [LLSTRING(pathFinding), LLSTRING(pathFinding_desc)],
    LLSTRING(category_general),
    [0, 10, 0, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,magicHeal), "CHECKBOX",
    [LLSTRING(magicHeal), LLSTRING(magicHeal_desc)],
    LLSTRING(category_general),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,magicRepair), "CHECKBOX",
    [LLSTRING(magicRepair), LLSTRING(magicRepair_desc)],
    LLSTRING(category_general),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,magicRearm), "CHECKBOX",
    [LLSTRING(magicRearm), LLSTRING(magicRearm_desc)],
    LLSTRING(category_general),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,magicRefuel), "CHECKBOX",
    [LLSTRING(magicRefuel), LLSTRING(magicRefuel_desc)],
    LLSTRING(category_general),
    false, 1
] call CBA_fnc_addSetting;

// ============================================================
// HAL Commander Settings
// ============================================================
[
    QEGVAR(core,fast), "CHECKBOX",
    [LLSTRING(fast), LLSTRING(fast_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,commDelay), "SLIDER",
    [LLSTRING(commDelay), LLSTRING(commDelay_desc)],
    LLSTRING(category_commander),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(common,chatDebug), "CHECKBOX",
    [LLSTRING(chatDebug), LLSTRING(chatDebug_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,exInfo), "CHECKBOX",
    [LLSTRING(exInfo), LLSTRING(exInfo_desc)],
    LLSTRING(category_commander),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,resetTime), "SLIDER",
    [LLSTRING(resetTime), LLSTRING(resetTime_desc)],
    LLSTRING(category_commander),
    [0, 600, 150, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,resetOnDemand), "CHECKBOX",
    [LLSTRING(resetOnDemand), LLSTRING(resetOnDemand_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,subAll), "CHECKBOX",
    [LLSTRING(subAll), LLSTRING(subAll_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,subSynchro), "CHECKBOX",
    [LLSTRING(subSynchro), LLSTRING(subSynchro_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,knowTL), "CHECKBOX",
    [LLSTRING(knowTL), LLSTRING(knowTL_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,getHQInside), "CHECKBOX",
    [LLSTRING(getHQInside), LLSTRING(getHQInside_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(hac,camV), "CHECKBOX",
    [LLSTRING(camV), LLSTRING(camV_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,infoMarkers), "CHECKBOX",
    [LLSTRING(infoMarkers), LLSTRING(infoMarkers_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,artyMarks), "CHECKBOX",
    [LLSTRING(artyMarks), LLSTRING(artyMarks_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,secTasks), "CHECKBOX",
    [LLSTRING(secTasks), LLSTRING(secTasks_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(common,debug), "CHECKBOX",
    [LLSTRING(debug), LLSTRING(debug_desc)],
    LLSTRING(category_commander),
    false, 1
] call CBA_fnc_addSetting;

// ============================================================
// HAL Behaviour Settings
// ============================================================
[
    QEGVAR(core,smoke), "CHECKBOX",
    [LLSTRING(smoke), LLSTRING(smoke_desc)],
    LLSTRING(category_behaviour),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,flare), "CHECKBOX",
    [LLSTRING(flare), LLSTRING(flare_desc)],
    LLSTRING(category_behaviour),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,garrVehAb), "CHECKBOX",
    [LLSTRING(garrVehAb), LLSTRING(garrVehAb_desc)],
    LLSTRING(category_behaviour),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,idleOrd), "CHECKBOX",
    [LLSTRING(idleOrd), LLSTRING(idleOrd_desc)],
    LLSTRING(category_behaviour),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,idleDef), "CHECKBOX",
    [LLSTRING(idleDef), LLSTRING(idleDef_desc)],
    LLSTRING(category_behaviour),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,flee), "CHECKBOX",
    [LLSTRING(flee), LLSTRING(flee_desc)],
    LLSTRING(category_behaviour),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,surr), "CHECKBOX",
    [LLSTRING(surr), LLSTRING(surr_desc)],
    LLSTRING(category_behaviour),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,muu), "SLIDER",
    [LLSTRING(muu), LLSTRING(muu_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,rush), "CHECKBOX",
    [LLSTRING(rush), LLSTRING(rush_desc)],
    LLSTRING(category_behaviour),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,withdraw), "SLIDER",
    [LLSTRING(withdraw), LLSTRING(withdraw_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,airDist), "SLIDER",
    [LLSTRING(airDist), LLSTRING(airDist_desc)],
    LLSTRING(category_behaviour),
    [0, 20000, 4000, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,dynForm), "CHECKBOX",
    [LLSTRING(dynForm), LLSTRING(dynForm_desc)],
    LLSTRING(category_behaviour),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,defRange), "SLIDER",
    [LLSTRING(defRange), LLSTRING(defRange_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,garrRange), "SLIDER",
    [LLSTRING(garrRange), LLSTRING(garrRange_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,attInfDistance), "SLIDER",
    [LLSTRING(attInfDistance), LLSTRING(attInfDistance_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,attArmDistance), "SLIDER",
    [LLSTRING(attArmDistance), LLSTRING(attArmDistance_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,attSnpDistance), "SLIDER",
    [LLSTRING(attSnpDistance), LLSTRING(attSnpDistance_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,flankDistance), "SLIDER",
    [LLSTRING(flankDistance), LLSTRING(flankDistance_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,attSFDistance), "SLIDER",
    [LLSTRING(attSFDistance), LLSTRING(attSFDistance_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,reconDistance), "SLIDER",
    [LLSTRING(reconDistance), LLSTRING(reconDistance_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,captureDistance), "SLIDER",
    [LLSTRING(captureDistance), LLSTRING(captureDistance_desc)],
    LLSTRING(category_behaviour),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(common,uAVAlt), "SLIDER",
    [LLSTRING(uAVAlt), LLSTRING(uAVAlt_desc)],
    LLSTRING(category_behaviour),
    [0, 2000, 150, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,combining), "CHECKBOX",
    [LLSTRING(combining), LLSTRING(combining_desc)],
    LLSTRING(category_behaviour),
    false, 1
] call CBA_fnc_addSetting;

// ============================================================
// HAL Personality Settings
// ============================================================
[
    QEGVAR(core,mAtt), "CHECKBOX",
    [LLSTRING(mAtt), LLSTRING(mAtt_desc)],
    LLSTRING(category_personality),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,personality), "LIST",
    [LLSTRING(personality), LLSTRING(personality_desc)],
    LLSTRING(category_personality),
    [
        ["GENIUS","IDIOT","CHAOTIC","COMPETENT","EAGER","DILATORY","SCHEMER","BRUTE","OTHER"],
        ["Ideal","Worst","Chaotic","Competent","Eager","Hesitant","Schemer","Aggressive","Randomized"],
        3
    ], 1
] call CBA_fnc_addSetting;

// ============================================================
// HAL Support Settings
// ============================================================
[
    QEGVAR(core,cargoFind), "SLIDER",
    [LLSTRING(cargoFind), LLSTRING(cargoFind_desc)],
    LLSTRING(category_support),
    [0, 5000, 1, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,noAirCargo), "CHECKBOX",
    [LLSTRING(noAirCargo), LLSTRING(noAirCargo_desc)],
    LLSTRING(category_support),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,noLandCargo), "CHECKBOX",
    [LLSTRING(noLandCargo), LLSTRING(noLandCargo_desc)],
    LLSTRING(category_support),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,sMed), "CHECKBOX",
    [LLSTRING(sMed), LLSTRING(sMed_desc)],
    LLSTRING(category_support),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,sFuel), "CHECKBOX",
    [LLSTRING(sFuel), LLSTRING(sFuel_desc)],
    LLSTRING(category_support),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,sAmmo), "CHECKBOX",
    [LLSTRING(sAmmo), LLSTRING(sAmmo_desc)],
    LLSTRING(category_support),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,sRep), "CHECKBOX",
    [LLSTRING(sRep), LLSTRING(sRep_desc)],
    LLSTRING(category_support),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,supportWP), "CHECKBOX",
    [LLSTRING(supportWP), LLSTRING(supportWP_desc)],
    LLSTRING(category_support),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,artyShells), "SLIDER",
    [LLSTRING(artyShells), LLSTRING(artyShells_desc)],
    LLSTRING(category_support),
    [0, 10, 1, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,airEvac), "CHECKBOX",
    [LLSTRING(airEvac), LLSTRING(airEvac_desc)],
    LLSTRING(category_support),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,supportRTB), "CHECKBOX",
    [LLSTRING(supportRTB), LLSTRING(supportRTB_desc)],
    LLSTRING(category_support),
    true, 1
] call CBA_fnc_addSetting;

// ============================================================
// HAL Objectives Settings
// ============================================================
[
    QEGVAR(core,order), "CHECKBOX",
    [LLSTRING(order), LLSTRING(order_desc)],
    LLSTRING(category_objectives),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,berserk), "CHECKBOX",
    [LLSTRING(berserk), LLSTRING(berserk_desc)],
    LLSTRING(category_objectives),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,simpleMode), "CHECKBOX",
    [LLSTRING(simpleMode), LLSTRING(simpleMode_desc)],
    LLSTRING(category_objectives),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,unlimitedCapt), "CHECKBOX",
    [LLSTRING(unlimitedCapt), LLSTRING(unlimitedCapt_desc)],
    LLSTRING(category_objectives),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,captLimit), "SLIDER",
    [LLSTRING(captLimit), LLSTRING(captLimit_desc)],
    LLSTRING(category_objectives),
    [0, 100, 10, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,garrR), "SLIDER",
    [LLSTRING(garrR), LLSTRING(garrR_desc)],
    LLSTRING(category_objectives),
    [0, 5000, 500, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,objHoldTime), "SLIDER",
    [LLSTRING(objHoldTime), LLSTRING(objHoldTime_desc)],
    LLSTRING(category_objectives),
    [0, 3600, 60, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,objRadius1), "SLIDER",
    [LLSTRING(objRadius1), LLSTRING(objRadius1_desc)],
    LLSTRING(category_objectives),
    [0, 5000, 300, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,objRadius2), "SLIDER",
    [LLSTRING(objRadius2), LLSTRING(objRadius2_desc)],
    LLSTRING(category_objectives),
    [0, 5000, 500, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,lRelocating), "CHECKBOX",
    [LLSTRING(lRelocating), LLSTRING(lRelocating_desc)],
    LLSTRING(category_objectives),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,noRec), "SLIDER",
    [LLSTRING(noRec), LLSTRING(noRec_desc)],
    LLSTRING(category_objectives),
    [0, 1000, 10, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,rapidCapt), "SLIDER",
    [LLSTRING(rapidCapt), LLSTRING(rapidCapt_desc)],
    LLSTRING(category_objectives),
    [0, 1000, 10, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,defendObjectives), "SLIDER",
    [LLSTRING(defendObjectives), LLSTRING(defendObjectives_desc)],
    LLSTRING(category_objectives),
    [0, 50, 4, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,reconReserve), "SLIDER",
    [LLSTRING(reconReserve), LLSTRING(reconReserve_desc)],
    LLSTRING(category_objectives),
    [0, 1, 0, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,attackReserve), "SLIDER",
    [LLSTRING(attackReserve), LLSTRING(attackReserve_desc)],
    LLSTRING(category_objectives),
    [0, 1, 0, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,cRDefRes), "SLIDER",
    [LLSTRING(cRDefRes), LLSTRING(cRDefRes_desc)],
    LLSTRING(category_objectives),
    [0, 1, 0.4, 2], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,aAO), "CHECKBOX",
    [LLSTRING(aAO), LLSTRING(aAO_desc)],
    LLSTRING(category_objectives),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,forceAAO), "CHECKBOX",
    [LLSTRING(forceAAO), LLSTRING(forceAAO_desc)],
    LLSTRING(category_objectives),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,bBAOObj), "SLIDER",
    [LLSTRING(bBAOObj), LLSTRING(bBAOObj_desc)],
    LLSTRING(category_objectives),
    [0, 50, 4, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(core,maxSimpleObjs), "SLIDER",
    [LLSTRING(maxSimpleObjs), LLSTRING(maxSimpleObjs_desc)],
    LLSTRING(category_objectives),
    [0, 50, 5, 0], 1
] call CBA_fnc_addSetting;

[
    QEGVAR(hac,objectiveRespawn), "CHECKBOX",
    [LLSTRING(objectiveRespawn), LLSTRING(objectiveRespawn_desc)],
    LLSTRING(category_objectives),
    false, 1
] call CBA_fnc_addSetting;

// ============================================================
// HAL High Commander Settings
// ============================================================
[
    QEGVAR(missionmodules,customObjOnly), "CHECKBOX",
    [LLSTRING(customObjOnly), LLSTRING(customObjOnly_desc)],
    LLSTRING(category_highcommander),
    true, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(missionmodules,bbLRelocating), "CHECKBOX",
    [LLSTRING(bbLRelocating), LLSTRING(bbLRelocating_desc)],
    LLSTRING(category_highcommander),
    false, 1
] call CBA_fnc_addSetting;

[
    QEGVAR(missionmodules,mainInterval), "SLIDER",
    [LLSTRING(mainInterval), LLSTRING(mainInterval_desc)],
    LLSTRING(category_highcommander),
    [1, 60, 5, 0], 1
] call CBA_fnc_addSetting;
