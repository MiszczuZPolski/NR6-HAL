# HAL Modules — Big Boss (High Command)

*4 modules in this category. Place them in Eden editor under **Systems → Modules → HAL - Modules**.*

---

### High Commander

> Creates a new high commander.

**Runtime class:** `hal_missionmodules_BBLeader_Module`
**Init function:** `bbLeader`
**Sync:** place and sync to `LocationArea_F`

*No arguments — this module acts by placement alone.*

---

### High Commander Objective

> Adds an objective for the synchronized high commander module.

**Runtime class:** `hal_missionmodules_BBLeader_Objective_Module`
**Init function:** `bbObjective`
**Sync:** place and sync to `LocationArea_F`

*No arguments — this module acts by placement alone.*

---

### High Commander Settings

> Sets settings for the synchronized high commander module.

**Runtime class:** `hal_missionmodules_BBSettings_Module`
**Init function:** `bbSettings`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **No Auto Objectives** — `BOOL` · default `True`
  - HC will only consider user placed objectives instead of scanning the map for strategic locations.
- **Commanders Relocate** — `BOOL` · default `False`
  - HC controlled conmmanders will relocate to objectives recently captured. This is used for HC mode as the legacy relocation works differently.
- **HC Cycle (Minutes)** — `NUMBER` · default `5`
  - Delay between HC computation cycles.

---

### High Commander Zone

> If custom objectives are not enforced, High-Command mode will only scan the map within this zone for additional objectives.

**Runtime class:** `hal_missionmodules_BBZone_Module`
**Init function:** `bbZone`
**Sync:** place and sync to `LocationArea_F`

*No arguments — this module acts by placement alone.*

---
