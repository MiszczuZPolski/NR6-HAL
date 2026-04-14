# HAL Modules — Core

*2 modules in this category. Place them in Eden editor under **Systems → Modules → HAL - Modules**.*

---

### HAL Core

> Activates HAL. Can be synchronized to a trigger for late activation.

**Runtime class:** `hal_missionmodules_Core_Module`
**Init function:** `core_fnc_init`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Startup Delay** — `NUMBER` · default `15`
  - Time in seconds that HAL will wait before initializing.

---

### HAL General Settings

> General settings shared by all commanders.

**Runtime class:** `hal_missionmodules_GenSettings_Module`
**Init function:** `generalSettings`
**Sync:** place and sync to `LocationArea_F`

**Arguments:**

- **Enable Cargo Recon** — `BOOL` · default `True`
  - Recon orders will use provided lifts.
- **Synchronized/Planned Attacks** — `BOOL` · default `False`
  - Attacks will be timed and synchronized among squads attacking the same target.
- **Commander Chat Orders** — `BOOL` · default `True`
  - Commander orders visivle in side chat.
- **Radio Comms Presence** — `NUMBER` · default `100`
  - Chance for a communication between AI and commander to be visible and audible.
- **Radio Comms Profile** — `?`
  - Changes the lines used in radio communications to better fit certain contexts for modded content.
- **Add Group ID for BFT** — `BOOL` · default `true`
  - Friendly forces will have their Squad ID show up on info markers.
- **Squad Leader Actions** — `BOOL` · default `True`
  - Player squad leaders will have HAL actions enabled.
- **Actions Menu** — `BOOL` · default `True`
  - Player squad leaders will have HAL actions enabled as a menu.
- **Tasking Actions (Deprecated)** — `BOOL` · default `False`
  - Player squad leaders will have tasking related actions. Deprecated by menu.
- **Support Actions (Deprecated)** — `BOOL` · default `False`
  - Player squad leaders will have support related actions. Deprecated by menu.
- **Only Use ACE Actions** — `BOOL` · default `False`
  - Player squad leaders will only use ACE self-interactions for their HAL actions.
- **Disable Withdraw For Players Squad Leader** — `BOOL` · default `True`
  - Players will not receive forced retreat orders (Recommended).
- **Disable Cargo Players Squad Leaders** — `BOOL` · default `True`
  - Players will not be provided with forced lifts (Recommended).
- **Infantry Disembark Upon Enemy Contact** — `NUMBER` · default `200`
  - Infantry will dismount their transport upon making contact with enemy within this radius from them. Note that certain orders will always have their infantry disembark when meeting nearby enemy to counterattack and re-evaluate.
- **Distance To Use Transport** — `NUMBER` · default `1500`
  - Distance beyond which infantry will make use of dispatched transports to get a lift. Too low values will result in problematic behaviour.
- **Enable LZ System** — `BOOL` · default `True`
  - System that will place invisible helipads when helicopter transport is issued to improve the selection of landing sites by AI pilots.
- **NR6 Sites Garrisons** — `BOOL` · default `True`
  - Uses the NR6 Sites CBA based defensive script for garrison orders instead of stock HAL.
- **Squad Info Share Range** — `NUMBER` · default `500`
  - How far do squads communicate enemy positions to other nearby squads. Set to 0 to disable.
- **Sling Load Ammo Drop** — `BOOL` · default `False`
  - (Feature inconsistent at this time)
- **RHQ Auto Mode** — `BOOL` · default `True`
  - Classifies units to be used by HAL automatically
- **Pathfinding Increments** — `NUMBER` · default `0`
  - Set to 0 to disable. Adds several waypoints to squads instead of a single straight line waypoint to account for terrain. May cause more issues with mobility. (Recommended disabled)
- **Supports Magic Heal (ACE only)** — `BOOL` · default `False`
  - Enables magic healing around ambulances upon support request as a workaround for ACE medical.
- **Supports Magic Repair** — `BOOL` · default `False`
  - Enables magic repairs around repair vehicles upon support request as a workaround for ACE repair limitations.
- **Supports Magic Rearm** — `BOOL` · default `False`
  - Enables magic vehicle rearming around ammo vehicles upon support request as a workaround for ACE rearming limitations.
- **Supports Magic Refuel** — `BOOL` · default `False`
  - Enables magic refueling around refuel vehicles upon support request as a workaround for ACE refuel limitations.

---
