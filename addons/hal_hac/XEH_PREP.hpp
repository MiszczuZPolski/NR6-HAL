// Functions registered here in Phase 3 when extraction begins.
PREP(desperation);
PREP(dispatcher);
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
