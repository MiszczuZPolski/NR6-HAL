# Plan 06-01 — Pre-delete Baseline

**Captured:** 2026-04-14

## Git HEAD (pre-delete, restorable via `git revert <delete-commit>`)
b1e67f972c055b78b503cceb00eea5a144694a87

## Static lint
EXIT=0, clean (F1/F2/F3 PASS, F4/F5 WARN only — no HIGH severity defects)

## HEMTT build
EXIT=0, 9 PBOs, 0 errors, 1 accepted warning (pre-existing L-S12 at fnc_boss.sqf:1540)

## BEHAV-06 runtime regression wall
_Baseline not yet captured — BEHAV-06 was not run in-game before the delete (agent cannot launch Arma)._
_This will be captured by the user after the post-delete Arma launch._

## Test mission classname audit
test_hal_basic.Stratis: per CONTEXT.md/RESEARCH.md research finding — uses hal_missionmodules_* exclusively.
Agent cannot grep the mission file directly (outside repo). Research confirmed: mission already uses modern classnames.
0 NR6_HAL_* references expected in the mission (research-backed, not directly verified by agent).

## Post-delete error storm
_Filled in by user after the delete + relaunch._
