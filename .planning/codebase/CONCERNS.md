# Codebase Concerns

**Analysis Date:** 2026-04-09

## Tech Debt

**Extensive Commented-Out Code:**
- Issue: Large sections of code remain commented out, particularly legacy function implementations
- Files: `nr6_hal/HAC_fnc.sqf` (lines 1-100+), `nr6_alice2/data/scripts/fn_civilianSet.sqf` (lines 64-96)
- Impact: Makes maintenance harder, obscures functionality, increases file size, creates confusion about what is actually active
- Fix approach: Either remove deprecated code or create a separate legacy/archive branch; if needed for reference, create a DEPRECATED.md file listing old patterns

**Mixed Variable Declaration Styles:**
- Issue: Code uses both old `private ["_var1","_var2"]` syntax and new `params` syntax inconsistently
- Files: Multiple files including `nr6_hal/Boss.sqf` (lines 3-21), `addons/common/functions/fnc_cff_ffe.sqf` (lines 3-11)
- Impact: Inconsistent code style reduces readability and makes updates harder; new developers unfamiliar with both patterns
- Fix approach: Standardize on `params` and `private` keywords throughout; create automated refactoring for large files

## Known Bugs

**TODO Comments with Legacy Arma 2 Code:**
- Symptoms: Outdated code references that suggest incomplete migration from Arma 2 to Arma 3
- Files: `nr6_alice2/data/scripts/fn_civilianSet.sqf` (line 36: "TODO GITA - NO NEED ARMA 3")
- Trigger: When spawning civilian units in Arma 3 environments
- Workaround: Current code has fallback logic using Arma 3 location functions
- Fix approach: Remove legacy Arma 2 location logic and clean up the civilian spawning function

## Fragile Areas

**Monolithic Functions with High Complexity:**
- Files: 
  - `nr6_hal/HAC_fnc.sqf` (5645 lines)
  - `nr6_hal/HAC_fnc2.sqf` (3389 lines)
  - `nr6_hal/RHQLibrary.sqf` (2491 lines)
  - `nr6_hal/Boss_fnc.sqf` (2202 lines)
  - `nr6_hal/Boss.sqf` (2021 lines)
- Why fragile: Extremely large single-file implementations make debugging difficult, increase merge conflict risk, reduce code reusability, and make unit testing nearly impossible
- Safe modification: Extract functions into smaller, focused files; use strict variable scoping; add parameter validation at function entry points
- Test coverage: No evidence of automated testing; manual testing only
- Impact: Small changes in these files risk cascading failures in Boss AI system

**Extensive Global Variable Usage:**
- Files: `nr6_hal/VarInit.sqf` (100+ global variable initializations), `nr6_hal/Boss.sqf`, all HAL modules
- Why fragile: Global namespace pollution makes it hard to track state, creates hidden dependencies, causes mysterious bugs when variables are unintentionally modified
- Current pattern: Variables like `RydBBa_HQs`, `RydHQ_AllArty`, `RydBB_Active` are global and modified throughout codebase
- Safe modification: Encapsulate globals in namespace objects (e.g., `RYD_GLOBALS` with sub-objects); use setter/getter functions; document all global writes
- Test coverage: No way to isolate state between test runs

**Deep Nesting in Control Flow:**
- Files: `nr6_hal/Boss.sqf` (nested waitUntil and forEach loops with complex conditions), `addons/common/functions/fnc_cff_ffe.sqf` (deeply nested if-then-else chains)
- Why fragile: Multiple levels of indentation (4-6 levels in some cases) make logic hard to follow, increase likelihood of operator errors (! vs !!, == vs !=)
- Current issue: Hard to trace which exit conditions apply to which scope
- Safe modification: Extract nested logic into separate functions; use early exits (exitWith) more aggressively; simplify conditions

**Hardcoded String Concatenation for Keys:**
- Files: `nr6_hal/TaskInitNR6.sqf` (line 5-7: variable keys like `'Resting' + (str (group ...))`)
- Why fragile: String concatenation for variable keys is error-prone; typos in key names create silent bugs (new variables instead of accessing existing ones)
- Current issue: Group identifiers converted to strings may not be unique or consistent across reload/restart
- Safe modification: Use dedicated key generation functions; store variable names as constants; add assertion checks on variable get/set

## Performance Bottlenecks

**Repeated Group Conversions and Format Calls:**
- Problem: Code repeatedly calls `str (group _unit)` to create variable keys instead of caching group identifiers
- Files: `nr6_hal/TaskInitNR6.sqf` (lines 5-7, 17), repeated in other action functions
- Cause: Group object converted to string multiple times per execution path
- Improvement path: Cache the string representation once, pass it as parameter, or use getVariable with object direct reference instead of string key

**Inefficient Entity Queries:**
- Problem: `nearEntities` called with large distance (100000m) on every civilian spawn
- Files: `nr6_alice2/data/scripts/fn_civilianSet.sqf` (line 36)
- Cause: Old Arma 2 pattern maintained; radius search is expensive for populated areas
- Improvement path: Use pre-computed location objects; cache results; reduce search radius

**Multiple nearestObjects Calls:**
- Problem: Sequential nearestObjects queries instead of single optimized search
- Files: `nr6_alice2/data/scripts/fn_civilianSet.sqf` (lines 43-51: first searches for `bis_alice_emptydoor`, falls back to `house`)
- Cause: Type filtering done in script instead of query
- Improvement path: Query all building types once; filter in code or improve config to reduce query count

**Frequent Array Concatenation:**
- Problem: Using `+` operator for array concatenation in loops, creates new array each iteration
- Files: `nr6_hal/VarInit.sqf` (line 21: `RydHQ_AllArty = RydHQ_Howitzer + RydHQ_Mortar + ...`)
- Cause: Functional style without considering memory allocation cost
- Improvement path: Pre-allocate arrays; use pushBack in loops instead of concatenation

**Frequent isNil String Checks:**
- Problem: Checking if variable is nil using string representation `isNil "varName"` instead of faster null checks
- Files: `nr6_hal/VarInit.sqf` (50+ lines checking `isNil ("RYD_...")`)
- Cause: Defensive coding pattern but expensive on every mission load
- Improvement path: Use namespace objects with proper initialization; check at startup only, cache results

## Scaling Limits

**Max Function File Size:**
- Current capacity: SQF files are plain text; parsers may struggle above 5000+ lines
- Limit: `nr6_hal/HAC_fnc.sqf` at 5645 lines approaches practical limits for single-file interpretation
- Scaling path: Split large files into modules; use compile-time includes; implement proper module system

**Global Namespace Pollution:**
- Current capacity: Hundreds of global variables with RYD* and RHQ* prefixes across codebase
- Limit: As codebase grows, collision risk increases; debugging gets exponentially harder
- Scaling path: Implement namespace object pattern; use class definitions for data structures; isolate module state

**Hardcoded Configuration Values:**
- Problem: Artillery types, vehicle classes, weapon configurations hardcoded in multiple files
- Files: `nr6_hal/VarInit.sqf` (lines 9-21 vehicle class arrays), `addons/common/functions/fnc_cff.sqf` (hardcoded ammo types)
- Limit: Adding new vehicles/ammo requires modifying multiple files
- Scaling path: Centralize configuration in config.cpp or dedicated config files; load at startup; use reference counting

## Missing Critical Features

**No Input Validation Framework:**
- Problem: Functions accept parameters without type checking or bounds validation
- Files: Most .sqf files in HAL system
- Blocks: Can't safely extend functionality; parameter changes cascade; hard to debug misuse
- Fix approach: Create validation library with type checking; add contractual assertions; document parameter requirements

**No Logging/Debugging System:**
- Problem: Code uses diag_log and RydBBa_SAL globalChat ad-hoc for debugging
- Files: Scattered throughout (e.g., `nr6_alice2/data/scripts/fn_civilianSet.sqf` line 39, `nr6_hal/Boss.sqf` line 38)
- Blocks: Can't easily debug production issues; no audit trail
- Fix approach: Implement centralized logging module with log levels; add timestamps; route to configured output

**No Error Recovery Mechanism:**
- Problem: Functions fail silently or return false without explanation
- Files: Most mission module functions
- Blocks: When something goes wrong, no way to know why or recover gracefully
- Fix approach: Implement try-catch equivalent pattern; return error codes/messages; add fallback behaviors

**No State Management Pattern:**
- Problem: Complex state tracked through global variables and object setVariable calls inconsistently
- Files: Boss system, HAL modules
- Blocks: Can't replay/debug state transitions; can't unit test
- Fix approach: Create state machine library; use dedicated state objects; add state validation

## Test Coverage Gaps

**No Automated Testing:**
- What's not tested: All core AI behavior in Boss.sqf, HAC_fnc.sqf, all military decision functions
- Files: `nr6_hal/Boss.sqf`, `nr6_hal/HAC_fnc.sqf`, `nr6_hal/Boss_fnc.sqf`, `nr6_hal/RHQLibrary.sqf`
- Risk: Changes to tactical AI system can break silently; regressions go undetected
- Priority: HIGH - Boss system is most complex, highest impact

**No Unit Tests for Utility Functions:**
- What's not tested: Mathematical functions (angleTowards, positionAround, distanceCalc), array operations
- Files: `addons/common/functions/fnc_*.sqf` (69 functions total)
- Risk: Subtle bugs in position calculations could cause cascading AI failures
- Priority: HIGH - these functions are dependency for everything else

**No Integration Tests for Mission Modules:**
- What's not tested: Civilian spawning system, reinforcement mechanics, site capture
- Files: `nr6_alice2/`, `nr6_reinforcements/`, `nr6_sites/`
- Risk: Edge cases in module interactions cause unpredictable mission behavior
- Priority: MEDIUM - affects user experience but less critical than core AI

**Missing Regression Tests for Fixes:**
- What's not tested: Any bugs that were fixed previously
- Files: All modules
- Risk: Same bugs resurface in future changes
- Priority: MEDIUM - preventative measure for code stability

## Security Considerations

**No Input Sanitization:**
- Risk: String-based variable keys could be exploited if user input reaches them
- Files: `nr6_hal/TaskInitNR6.sqf`, any code using user-provided strings
- Current mitigation: Game is single-player/closed mod, limited exposure
- Recommendations: Even in closed environments, validate and sanitize all variable names; use whitelists for dynamic property access

**Global State Accessible from All Contexts:**
- Risk: Debug mode variables (`RydBB_Debug`, `RydHQ_ChatDebug`) could expose internal state
- Files: `nr6_hal/VarInit.sqf`, all modules that check these flags
- Current mitigation: Debug variables documented, expected to be disabled in production
- Recommendations: Implement privilege check for debug features; don't expose debug data in multiplayer contexts; audit who can modify global state

**No Replay/Audit Trail:**
- Risk: Difficult to forensically analyze AI decisions or user actions
- Files: All HAL modules
- Current mitigation: diag_log provides some trace
- Recommendations: Implement decision logging with full context; record all major state transitions

---

*Concerns audit: 2026-04-09*
