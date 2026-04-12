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
// StatusQuo trunk (must be last — depends on all sub-functions above)
PREP(statusQuo);
