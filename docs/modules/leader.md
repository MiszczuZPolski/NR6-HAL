# HAL Modules — Leader (Commander)

*16 modules in this category. Place them in Eden editor under **Systems → Modules → HAL - Modules**.*

---

### Ammo Drop Ammo Depot

> Adds a zone in which all ammo boxes will be used for ammo drops for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_AmmoDepot_Module`
**Init function:** `ammoDepot`
**Sync:** place and sync to `LocationArea_F`

*No arguments — this module acts by placement alone.*

---

### Commander Behaviour Settings

> Sets behaviour settings for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_BehSettings_Module`
**Init function:** `leaderBehaviourSettings`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Smoke For Retreat** — `BOOL` · default `True`
  - Squads will use smoke grenades or request smoke shells to cover their retreat.
- **Flares On Enemies** — `BOOL` · default `True`
  - Squads will use flares or request flare shells to mark or exposed enemies (At night).
- **Garr Disembark (only Stock)** — `BOOL` · default `True`
  - Makes garrisoned squads disembark their vehicle when using the stock garrison mode (not compatible with NR6 Sites mode).
- **Idle Orders** — `BOOL` · default `True`
  - Squads will wander and patrol around their position when waiting for orders
- **Patrol Orders** — `BOOL` · default `True`
  - When used with Idle Orders, squads will patrol between captured objectives instead of idling when waiting for orders
- **Fleeing Behaviour** — `BOOL` · default `True`
  - Enables fleeing for overwhelmed squads
- **Surrender Behaviour** — `BOOL` · default `True`
  - Enables surrendering for overwhelmed squads
- **Morale Coefficient** — `NUMBER` · default `1`
  - Coefficient of how much morale is affected by events on the battlefield. The higher this is, the more likely troops will stop fighting.
- **Rush Mode** — `BOOL` · default `False`
  - Squads will always run to their objectives (even in patrols).
- **Withdrawal Coefficient** — `NUMBER` · default `1`
  - Coefficient of how likely troops will be withdrawn. The higher this is, the more likely troops will run.
- **Max Air Asset Dist** — `NUMBER` · default `4000`
  - Idle air assets beyond this distance from their starting position will return to that position. Useful for planes running away from the map when not issued any waypoints.
- **Dynamic Formations** — `BOOL` · default `True`
  - Squads will change their formation according to the situation (Updated every minute).
- **Defend Position Radius Mult** — `NUMBER` · default `1`
  - Multiplier for how far from the defense point defense orders will be assigned. Useful for keeping a tight defensive formation or opening it up.
- **Garrison Radius Mult** — `NUMBER` · default `1`
  - Multiplier for how far garrisonned squads will look around for buildings and static weapons from their garrison point.
- **Inf Attack Radius Mult** — `NUMBER` · default `1`
  - Multiplier for how far from the target's position the initial waypoint will be placed during infantry attack orders.
- **Armor Attack Radius Mult** — `NUMBER` · default `1`
  - Multiplier for how far from the target's position the initial waypoint will be placed during armor attack orders.
- **Sniper Attack Radius Mult** — `NUMBER` · default `1`
  - Multiplier for how far from the target's position the initial waypoint will be placed during sniper attack orders.
- **Flanking Radius Mult** — `NUMBER` · default `1`
  - Multiplier for how far from the target's position the initial waypoint will be placed during flanking attack orders.
- **Specops Attack Radius Mult** — `NUMBER` · default `1`
  - Multiplier for how far from the target's position the initial waypoint will be placed during specops attack orders.
- **Recon Radius Mult** — `NUMBER` · default `1`
  - Multiplier for how far from the recon position the initial waypoint will be placed during recon orders.
- **Capture Radius Mult** — `NUMBER` · default `1`
  - Multiplier for how far from the objective's position the initial waypoint will be placed during capture orders.
- **UAV Deploy Altitude** — `NUMBER` · default `150`
  - Altitude at which carried UAVs will fly during recon orders. Set to 0 to disable.
- **Exhausted Squads Combine** — `BOOL` · default `False`
  - Enables withdrawing or disabled squads to join forces with other squads to continue fighting. WIP setting.

---

### Exclude Squads

> Synchronized squad members will have their squad added to the list of non-controlled squads for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_Exclude_Module`
**Init function:** `exclude`
**Sync:** place and sync to `LocationArea_F`

*No arguments — this module acts by placement alone.*

---

### Commander Front

> Sets a limited area of operations (front) for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_Front_Module`
**Init function:** `front`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Enable Front** — `BOOL` · default `True`
  - Enables the usage of a limited area of operations for a commander. This module will serve as the front area.

---

### Idle Rally Point

> Sets an idle rally point for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_IdleDecoy_Module`
**Init function:** `idleDecoy`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Chance Of Rally (%)** — `NUMBER` · default `True`
  - Chance that an idle squad will use this position as a rally point.

---

### Include Squads

> Synchronized squad members will have their squad added to the list of controlled squads for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_Include_Module`
**Init function:** `include`
**Sync:** place and sync to `LocationArea_F`

*No arguments — this module acts by placement alone.*

---

### HAL Commander

> Adds an AI commander. Synchronize to a unit to set it to be the AI commander or do not for a virtual HQ.

**Runtime class:** `hal_missionmodules_Leader_Module`
**Init function:** `addLeader`
**Sync:** place and sync to `LocationArea_F`

*No arguments — this module acts by placement alone.*

---

### Naval Objective (Simple Mode)

> Adds a naval simple-mode objective for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_NavalObjective_Module`
**Init function:** `navalObjective`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Set Taken By Commander** — `STRING`
  - Selects which AI leader will consider this objective as taken.

---

### Commander Objectives Settings

> Sets objective settings for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_ObjSettings_Module`
**Init function:** `leaderObjectivesSettings`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Forced Defense Mode** — `BOOL` · default `False`
  - Commander will never go into offensive mode.
- **Forced Attack Mode** — `BOOL` · default `False`
  - Commander will never go into defensive mode.
- **Simple Mode** — `BOOL` · default `True`
  - Default mode. Activates simple mode and disables the old HAL 4 objectives system.
- **Never Capture** — `BOOL` · default `False`
  - Commander will keep sending troops to an objective and it will never be considered captured.
- **Capture Strength** — `NUMBER` · default `10`
  - Number of units that must be at the objective to capture it.
- **Garrison Attack Range** — `NUMBER` · default `500`
  - How far can attack orders be isued for a garrisoned squad.
- **Time To Capture Objective** — `NUMBER` · default `60`
  - Capture orders will stay active for squads this long after they have reached the objective.
- **Friendly Capture Radius** — `NUMBER` · default `300`
  - Friendly forces must be within this radius from an objective to capture it.
- **Enemy Capture Radius** — `NUMBER` · default `500`
  - Enemy forces must be within this radius from an objective for the commander to consider it lost.
- **Relocating Commander** — `BOOL` · default `False`
  - Commander will move to the latest captured objective each time. Only works in legacy mode.
- **Chance Skip Recon** — `NUMBER` · default `10`
  - Chance to skip recon stage for capturing objectives on each cycle. Percentage affected by leader personality. Set well above 100 to guarantee skipping (like 1000)
- **Chance Fast Capture** — `NUMBER` · default `10`
  - Chance for the commander to focus on capturing objectives instead of engaging hostiles on each cycle. Percentage affected by leader personality. Set well above 100.
- **Def Ownership Size** — `NUMBER` · default `4`
  - Sets how many squads must be around an objective for the commander to consider it a defensive point. Only works in legacy mode.
- **Recon Reserve Ratio** — `NUMBER`
  - Coefficient of how many squads will be reserved for recon. Choose a number from 0 to 1.
- **Att Reserve Ratio** — `NUMBER`
  - Coefficient of how many squads will be reserved for advanced attack orders like flanking orders. Choose a number from 0 to 1.
- **Def Reserve Ratio** — `NUMBER` · default `0.4`
  - Coefficient of how many squads will be reserved for advanced defend orders like patrol orders. Choose a number from 0 to 1.
- **All At Once** — `BOOL` · default `False`
  - Will allow commander to capture objectives all at once and out of order.  Only works in legacy mode.
- **Force AAO** — `BOOL` · default `False`
  - Will force the commander to capture objectives all at once.  Only works in legacy mode.
- **Objectives At Once (HC mode)** — `NUMBER` · default `4`
  - Set the max number of objectives to capture at once.  Only works in high-command + legacy mode.
- **Objectives At Once (Simple mode)** — `NUMBER` · default `5`
  - Set the max number of objectives to capture at once in simple mode.
- **Create Objective Player Respawn Points** — `BOOL` · default `False`
  - Creates a player respawn position for every taken objective.

---

### Objective (Legacy Mode)

> Adds a legacy-mode objective for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_Objective_Module`
**Init function:** `objective`
**Sync:** place and sync to `LocationArea_F`

*No arguments — this module acts by placement alone.*

---

### Commander Personality Settings

> Sets personality settings for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_PersSettings_Module`
**Init function:** `leaderPersonalitySettings`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Manual Personality** — `BOOL` · default `True`
- **Select Personality** — `STRING`
  - Squads will use flares or request flare shells to mark or expose enemies (At night).

---

### Commander Settings

> Sets settings for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_Settings_Module`
**Init function:** `leaderSettings`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Fast Orders** — `BOOL` · default `False`
  - Makes commander issue orders before the end of its waiting period between order cycles. Can cause clashing orders and heavy CPU load.
- **Communication Delay** — `NUMBER` · default `1`
  - Coefficient of speed for orders dispatching. (ex: 2 for double delay) Avoid values under 1.
- **Map Radio Messages** — `BOOL` · default `False`
  - Show radio messages on map as markers.
- **Ext Enemy Reports** — `BOOL` · default `True`
  - Makes commander receive information about enemies from non-controlled groups.
- **Cycle Duration** — `NUMBER` · default `150`
  - Waiting time between each cycle of orders.
- **Cycles On Demand** — `BOOL` · default `False`
  - Only advance to next order cycle when ((group LeaderHQ) setVariable ['RydHQ_ResetNow',true]) has been set to true for the concerned commander.
- **Control All Side Groups** — `BOOL` · default `False`
  - Add all from the same side as the commander under his control.
- **Control Sync Groups** — `BOOL` · default `False`
  - Units synchronized to the commander unit will be added to his control (Non Virtual CO).
- **Commander KnownE Share** — `BOOL` · default `False`
  - All known enemy targets will be shared to controlled players
- **Commander Shelter Seek** — `BOOL` · default `False`
  - Commanders will seek for shelter everytime they relocate (For Relocating Mode).
- **Remote Cam** — `BOOL` · default `False`
  - Setting broken with caching. Supposed to add a camera to see what other squad leaders can see
- **BFT Markers** — `BOOL` · default `False`
  - Enables BFT markers with known enemy positions refreshed each cycle.
- **Artillery Markers** — `BOOL` · default `False`
  - Enables artillery markers for fire missions.
- **Objective Status Tasks** — `BOOL` · default `False`
  - Enables tasks added to all groups that inform players about the ownership/status of objectives. NOTE: May cause an error. It is a bug on BI's side linked to a task function for groups and can be ignored.
- **Debug** — `BOOL` · default `False`
  - Enables debug mode for the commander.

---

### Objective (Simple Mode)

> Adds a simple-mode objective for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_SimpleObjective_Module`
**Init function:** `simpleObjective`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Set Taken By Commander** — `STRING`
  - Selects which AI leader will consider this objective as taken.

---

### Commander Support Settings

> Sets support settings for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_SupSettings_Module`
**Init function:** `leaderSupportSettings`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Cargo Find Range** — `NUMBER` · default `1`
  - Range around an infantry squad within which the squad will look for a transport vehicle. If no vehicle is found, commander will try to provide a lift for the squad. To only use commander dispatched lifts, set to a very small value. Set to 0 to disable.
- **Disable Air Cargo** — `BOOL` · default `False`
  - Disable aerial transportation.
- **Disable Land Cargo** — `BOOL` · default `False`
  - Disable ground transportation.
- **Medical Support** — `BOOL` · default `True`
  - Controlled groups will receive medical support (See magic workaround in HAL general settings for usage with ACE).
- **Fuel Support** — `BOOL` · default `True`
  - Controlled groups will receive refueling support (See magic workaround in HAL general settings for usage with ACE).
- **Ammo Support** — `BOOL` · default `True`
  - Controlled groups will receive rearming support (See magic workaround in HAL general settings for usage with ACE).
- **Repair Support** — `BOOL` · default `True`
  - Controlled groups will receive repairing support (See magic workaround in HAL general settings for usage with ACE).
- **Support Waypoints** — `BOOL` · default `False`
  - Support orders will use support waypoints.
- **Arty Ord Coef** — `NUMBER` · default `1`
  - Coefficient of how many shells should be dropped every round.
- **Air Evac** — `BOOL` · default `True`
  - Enables retreat orders to use air evac.
- **Support RTB** — `BOOL` · default `True`
  - Makes support vehicles/groups return to their strating point uppon completion of their mission

---

### Supports Rally Point

> Sets a support rally point for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_SuppDecoy_Module`
**Init function:** `SuppDecoy`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Chance Of Rally (%)** — `NUMBER` · default `True`
  - Chance that a support squad will use this position as a rally point (%).

---

### Withdrawal Rally Point

> Sets a withdrawal rally point for the synchronized commander module.

**Runtime class:** `hal_missionmodules_Leader_WithdrawDecoy_Module`
**Init function:** `restDecoy`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Chance Of Rally (%)** — `NUMBER` · default `True`
  - Chance that a retreating squad will use this position as a rally point.

---
