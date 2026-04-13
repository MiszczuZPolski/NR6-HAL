// Functions registered here in Phase 3 when extraction begins.
PREP(desperation);
PREP(dispatcher);
// HQ command scripts (Phase 5-02 Task 3)
PREP(flanking);
PREP(hqOrders);
PREP(hqOrdersDef);
PREP(hqOrdersEast);
PREP(hqReset);
PREP(lhq);
PREP(lPos);
PREP(reloc);
PREP(rev);
PREP(sfIdleOrd);
PREP(spotScan);
// StatusQuo sub-functions (leaf-first order)
PREP(statusQuo_init);
PREP(statusQuo_scanFriends);
PREP(statusQuo_classifyFriends);
PREP(statusQuo_classifyEnemies);
PREP(statusQuo_artyPublish);
PREP(statusQuo_morale);
PREP(statusQuo_doctrine);
PREP(statusQuo_objective);
PREP(statusQuo_attackDispatch);
PREP(statusQuo_hqReloc);
PREP(LF_Loop);
// Tactical behavior scripts (Plan 05-03 Wave 3)
PREP(goAttAir);
PREP(goAttAirCAP);
PREP(goAttArmor);
PREP(goAttInf);
PREP(goAttNaval);
PREP(goAttSniper);
PREP(goCapture);
PREP(goCaptureNaval);
PREP(goFlank);
PREP(goSFAttack);
PREP(goDef);
PREP(goDefAir);
PREP(goDefNav);
PREP(goDefRecon);
PREP(goDefRes);
PREP(goIdle);
PREP(goRecon);
PREP(goRest);
PREP(sCargo);
PREP(garrison);
// Supply/support scripts (Plan 05-04 Wave 4)
PREP(goAmmoSupp);
PREP(goFuelSupp);
PREP(goMedSupp);
PREP(goRepSupp);
PREP(suppAmmo);
PREP(suppFuel);
PREP(suppMed);
PREP(suppRep);
// StatusQuo trunk (must be last — depends on all sub-functions above)
PREP(statusQuo);
