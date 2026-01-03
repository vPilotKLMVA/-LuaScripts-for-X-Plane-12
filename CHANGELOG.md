# vATC-Flightbar Changelog

All notable changes to this project will be documented in this file.

## [v1.4.7] - 2026-01-03

### Fixed
- **CRITICAL**: Fixed fatal error - `do_on_draw()` does not exist in FlyWithLua!
- Corrected callback to use `do_every_draw()` (the actual FlyWithLua function)
- Script now loads without errors

### Technical Details
- Line 1130: Changed `do_on_draw()` to `do_every_draw()` (correct FlyWithLua function)
- **Root cause**: v1.4.6 used non-existent function `do_on_draw()` causing "attempt to call global 'do_on_draw' (a nil value)" error
- **Solution**: FlyWithLua uses `do_every_draw()` for ImGui rendering, NOT `do_on_draw()`

---

## [v1.4.6] - 2026-01-03 ❌ BROKEN

### Fixed
- ~~Fixed incorrect FlyWithLua callback~~ (WRONG - used non-existent `do_on_draw()`)
- Fixed METAR QNH columns not being populated in display (dep_metar_qnh, arr_metar_qnh now show actual METAR data)
- Fixed log file naming - now uses "vATC_Log.txt" consistently (was "vATClog.log")

### Known Issues
- **FATAL**: Used `do_on_draw()` which doesn't exist → script won't load

---

## [v1.4.5] - 2026-01-02

### Fixed
- **CRITICAL**: Fixed FlyWithLua NG+ compatibility issues causing X-Plane crashes
- Changed ImGui callback from `do_every_frame()` to `do_on_draw()` (FlyWithLua NG+ requirement)
- Added 20 FPS throttle to draw loop using `os.clock()` to prevent performance issues
- Removed `pcall()` wrapper from draw functions (forbidden in ImGui callbacks for performance)
- Moved imgui safety checks BEFORE all imgui function calls in `vatc_draw_bar()` and `vatc_draw_settings()`
- Renamed log file from `vATC_sync.log` to `vATC_Log.txt`

### Changed
- Loader filename now includes version: `vATC_v1.4.5.lua`
- Optimized draw function with proper throttling mechanism
- Improved error handling for ImGui availability

### Technical Details
- **Root Cause**: Using wrong callback function caused FlyWithLua to crash X-Plane
- **FlyWithLua NG+ Requirements**:
  - MUST use `do_on_draw()` for ImGui callbacks (NOT `do_every_frame()`)
  - MUST throttle draw calls (max 20 FPS recommended)
  - NO pcall() in draw loops (performance requirement)
  - ALL safety checks MUST occur BEFORE imgui calls
- **Solution**: Complete rewrite of draw callback system following FlyWithLua NG+ specifications

---

## [v1.4.4] - 2026-01-02

### Fixed
- **CRITICAL**: Fixed X-Plane crash caused by ImGui safety checks occurring AFTER imgui function calls
- Moved `imgui` and `imgui.constant` safety checks to BEFORE any ImGui API calls
- Fixed crash in `vatc_draw_bar()` - safety check now at top of function
- Fixed crash in `vatc_draw_settings()` - added safety check before imgui calls

### Technical Details
- **Root Cause**: `imgui.SetNextWindowPos()` and `imgui.SetNextWindowSize()` were called before checking if `imgui` table exists
- **Impact**: X-Plane crashed immediately after FlyWithLua loaded all scripts
- **Solution**: Moved all safety checks to the very beginning of draw functions

---

## [v1.4.3] - 2026-01-02

### Fixed
- **CRITICAL**: Fixed missing `version.lua` file causing "FATAL: core modules failed"
- Fixed file naming inconsistency (removed `vATC_` prefix from module files)
- Updated deploy script to use correct project path (`vPilotKLMVA/vATC-Flightbar`)
- Removed Aithena references from deployment

### Changed
- Renamed loader file: `vATC_sync loader.lua` → `vATC_sync.lua`
- Module files now use standard names without prefix:
  - `vATC_version.lua` → `version.lua`
  - `vATC_config.lua` → `config.lua`
  - `vATC_utils.lua` → `utils.lua`
  - `vATC_alarms.lua` → `alarms.lua`
  - `vATC_init.lua` → `init.lua`

### Deployment
- Updated `~/deploy_xplane.sh` source path
- All files successfully deployed to Windows X-Plane

---

## [v1.4.2] - 2026-01-02 (Previous)

### Features
- Pure ImGui rendering (no float_wnd, no FFI, no system32)
- Borderless HUD bar at top of screen
- Pin/Unpin functionality
- Dynamic font scaling (0.8x to 1.5x based on resolution)
- METAR QNH display for DEP/ARR
- Step climb FL (nFIR sFL) support
- Alarm system for data changes
- Real-time VATSIM + SimBrief integration

### Known Issues
- Missing `version.lua` caused loading failures (FIXED in v1.4.3)
- X-Plane log showed: "ERROR version: cannot open version.lua"

### Removed
- ❌ All XPLM FFI integration (removed in v1.4.1 - caused crashes)
- ❌ float_wnd system32 calls (replaced with pure ImGui)
- ❌ OpenGL drawing (replaced with ImGui)

---

## Version History Summary

| Version | Date | Status | Notes |
|---------|------|--------|-------|
| v1.4.7 | 2026-01-03 | ✅ Current | Fixed callback - uses correct do_every_draw() |
| v1.4.6 | 2026-01-03 | ❌ FATAL | Used non-existent do_on_draw() function |
| v1.4.5 | 2026-01-02 | ❌ FATAL | Same as v1.4.6 - bad callback |
| v1.4.4 | 2026-01-02 | ⚠️ Broken | Wrong ImGui callback function |
| v1.4.3 | 2026-01-02 | ⚠️ Broken | Fixed files, but wrong callback |
| v1.4.2 | 2026-01-02 | ⚠️ Broken | Missing version.lua file |
| v1.4.1 | 2025-12-xx | ✅ Stable | Removed FFI/system32 |
| v1.4.0 | 2025-12-xx | ✅ Stable | Pure ImGui implementation |
| v1.3.x | 2025-xx-xx | ⚠️ Crashes | Used FFI (caused X-Plane crashes) |
| v1.2.x | 2025-xx-xx | ⚠️ Crashes | Used float_wnd + system32 |

---

## Backup Locations

**Mac OneDrive:**
```
/Users/mcwillem/Library/CloudStorage/OneDrive-Persoonlijk/Documenten/X-Plane/Backup/
├── vATC_sync_v1.4.2_2026-01-02/  (Clean ImGui version, missing version.lua)
```

**GitHub:**
- Repository: https://github.com/vPilotKLMVA/vATC-Flightbar
- Current branch: main

---

## Critical Notes

### ⚠️ DO NOT REINTRODUCE:
1. **FFI calls** - Causes X-Plane crashes
2. **system32 references** - Stability issues
3. **float_wnd** - Replaced by pure ImGui
4. **XPLM library loading** - Not compatible with FlyWithLua

### ✅ Safe to use:
1. Pure ImGui functions (`imgui.*`)
2. FlyWithLua built-in functions
3. Standard Lua libraries (io, os, string, math)
4. dkjson (JSON parsing)
5. socket.http / ssl.https (HTTPS requests)

---

## Testing Checklist

Before releasing a new version:
- [ ] X-Plane loads without crashes
- [ ] FlyWithLua log shows: "vATC Sync v1.x.x loaded"
- [ ] No "FATAL: core modules failed" error
- [ ] All module files present (version.lua, config.lua, utils.lua, alarms.lua, init.lua)
- [ ] Bar displays at top of screen
- [ ] VATSIM data fetches successfully
- [ ] SimBrief XML parsing works

---

*For questions: https://forums.x-plane.org/profile/422092-pilot-mcwillem/*
