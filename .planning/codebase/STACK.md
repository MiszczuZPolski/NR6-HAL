# Technology Stack

**Analysis Date:** 2026-04-09

## Languages

**Primary:**
- SQF (SQF Script Format) - Arma 3 scripting language used for all game logic and AI behavior
- SQC - Binarized SQF format for optimized performance (mentioned in README as future implementation)

**Secondary:**
- C++ - Configuration and class definitions in `.cpp` files (Arma 3 config syntax)

## Runtime

**Environment:**
- Arma 3 Engine (required version 2.14+) - Military combat simulation platform

**Game Engine:**
- Bohemia Interactive Arma 3 - DirectX/custom rendering engine

## Frameworks

**Core:**
- Community Base Addons (CBA) - Version 3.16.0 (required dependency)
  - Provides common functions and utilities for addon development
  - Required by: `cba_main` addon as specified in all config.cpp files
  - Functions used: `CBA_fnc_randPos`, `CBA_fnc_findMax`, `CBA_fnc_waitUntilAndExecute`, `CBA_fnc_compileFunction`

**Game Integration:**
- Arma 3 Modules Framework (`A3_Modules_F`) - Required for mission module integration
  - Located at: `addons/missionmodules/config.cpp`
  - Provides base classes for custom mission modules

**Build System:**
- HEMTT (Build Tool) - Arma 3 PBO compilation and project management
  - Configuration: `.hemtt/project.toml`, `.hemtt/launch.toml`
  - Handles addon compilation, binarization, and packaging

## Key Dependencies

**Critical:**
- CBA (Community Base Addons) Version 3.16.0 - Core library functions, macro compilation, event handler system
  - Location: Referenced in all addon `config.cpp` files under `requiredAddons[]`
  - Purpose: Function compilation, random position generation, array utilities, wait/execute patterns
  - Config file: `/N/arma3/NR6-HAL/.hemtt/launch.toml` (workshop ID 450814997)

**Optional (Alternate Implementations):**
- ACE3 - Medical engine macros available in `include/z/ace/` but not actively required
  - Status: Reference macros only, not a hard dependency

## Configuration

**Environment:**
- HEMTT project configuration-based
- No external environment variables (.env) required
- Configuration defined in: `.hemtt/project.toml`

**Build:**
- HEMTT processes config files:
  - `.hemtt/project.toml` - Project metadata (name, prefix, author, version)
  - `.hemtt/launch.toml` - Dependency specifications (Steam workshop IDs)
  - Macro preprocessing via `#include` system in SQF/HPP files

**Preprocessor Macros:**
- Script macros defined in: `addons/main/script_macros.hpp`
- Version macros in: `addons/main/script_version.hpp` (MAJOR=1, MINOR=0, PATCH=0, BUILD=0)
- Component-level settings in: `addons/*/script_component.hpp` files
- Debug flags support optional compilation: `DEBUG_MODE_FULL`, `DISABLE_COMPILE_CACHE`, `ENABLE_PERFORMANCE_COUNTERS`

## Platform Requirements

**Development:**
- Arma 3 (base game installation required)
- HEMTT build tool
- Text editor with SQF/C++ syntax support
- Optional: PBO Manager (pboman3) for manual PBO creation/decompilation
- Arma 3 Tools (binarization of SQF to SQFC format)
- Git for version control

**Production/Deployment:**
- Target: Arma 3 Steam Workshop or local mod directory
- Installation: PBO addons in `addons/` directory as compiled `.pbo` files
- Runtime dependency: CBA_A3 mod (Steam workshop ID 450814997) must be loaded before HAL

## Module Structure

**Main Addons (in `addons/`):**
- `addons/main/` - Core module with version, macros, and shared utilities
- `addons/core/` - Core initialization and CBA integration
- `addons/common/` - Common functions library (50+ mission/AI functions)
- `addons/missionmodules/` - Arma 3 mission module definitions and UI

**Standalone Modules (in `nr6_*/`):**
- `nr6_hal/` - Main HAL AI and task management engine (Boss, HAC_fnc, TaskInit, Squad Tasking)
- `nr6_reinforcements/` - Air and logistic reinforcement system
- `nr6_airreinforcements/` - Air reinforcement dispatcher (variants A/B/C)
- `nr6_alice2/` - Enhanced asset intelligence system
- `nr6_sites/` - Defensive site management and garrison tactics
- `nr6_sitemarkers/` - Site marker visualization
- `nr6_tools/` - Development and compilation utilities

## Asset Formats

**Media:**
- PAA (Arma 3 texture format) - Icon and logo files
- Sound files - Audio for radio chatter and notifications (in `nr6_hal/Sound/`)

**Code Artifacts:**
- SQF files (.sqf) - Human-readable scripts
- HPP files (.hpp) - Header includes and macro definitions
- CPP files (.cpp) - Configuration class definitions
- SQFC files (.sqfc) - Binarized compiled SQF (post-build)
- PBO files (.pbo) - Packed addon containers (compiled output)

## Compilation & Optimization

**Default State:**
- Scripts compiled from SQF source files at runtime via `compile preprocessFileLineNumbers`
- Function caching enabled via `CBA_fnc_compileFunction` unless `DISABLE_COMPILE_CACHE` is set

**Optimization Path:**
- Optional binarization to SQFC (compiled binary format) for improved load time and performance
- Requires: Arma 3 Script Compiler (part of Arma 3 Tools)
- Build process controlled by HEMTT: compiles SQF → SQFC automatically when configured

---

*Stack analysis: 2026-04-09*
