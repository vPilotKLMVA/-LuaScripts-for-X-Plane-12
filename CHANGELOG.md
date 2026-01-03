# Changelog

All notable changes to vATC Flightbar Enhanced will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned for v2.2.0
- Settings window with configuration options
- SimBrief XML parsing and flight plan integration
- Basic VATSIM data fetching
- METAR QNH extraction

### Planned for v2.3.0
- Full VATSIM integration (controllers, FIR detection)
- Dynamic font scaling based on screen resolution
- Custom color schemes
- Keyboard shortcuts

### Planned for v2.4.0
- Step climb FL calculation
- Data change alarms
- ETD/ETA actual tracking (brake release/set)
- Next ATC prediction

## [2.1.0] - 2026-01-03

### Added
- **Enhanced flight data display** with three-section layout (DEP/CRZ/ARR)
- **Comprehensive dataref integration**:
  - Weather data (QNH, temperature, wind direction/speed)
  - Navigation data (GPS distance, ETA)
  - Transponder mode detection
- **Flight phase detection system**:
  - PARKED: On ground, speed < 5 kts
  - TAXI: On ground, speed ≥ 5 kts
  - CLIMB: Airborne, altitude < 20,000 ft
  - CRZ: Altitude ≥ 20,000 ft
  - APPR: Descent phase, distance < 30 NM, altitude < 5,000 ft
- **Color-coded status indicators**:
  - Red: Offline (no VATSIM connection)
  - Orange: Prefiled (flight plan filed but not connected)
  - Green: Online (active on VATSIM)
- **Dynamic window positioning** adapts to screen resolution
- **Menu integration** with toggle options:
  - Toggle Bar: Show/hide flight information bar
  - Toggle Header: Show/hide field labels
- **Comprehensive display fields**:
  - DEP section: Origin, Callsign, ATC type, Frequency, Gate, SID, Runway, Squawk, QNH, METAR QNH, Transponder mode, ETD, Distance
  - CRZ section: FIR callsign, FIR frequency, Next FIR
  - ARR section: Destination, ETA, QNH, METAR QNH, Temperature, Wind, STAR, Approach, Runway

### Changed
- **Migrated from Lua to native C plugin**:
  - Better performance and integration
  - No FlyWithLua dependency
  - Native X-Plane SDK usage
- **Improved rendering system**:
  - Uses X-Plane Display API
  - OpenGL-based drawing
  - Borderless overlay window
- **Updated architecture**:
  - Modular code structure
  - Separate data structures for flight data
  - Clean separation of concerns

### Technical
- Built with Visual Studio Build Tools 2019+
- Uses X-Plane SDK 4.0.0
- CMake-based build system
- Native Windows 64-bit plugin (`.xpl`)

## [1.4.2] - 2025-12-XX (Legacy Lua Version)

### Note
This was the last Lua-based version. All future development is in the native C plugin.

### Features (Lua Version)
- ImGui-based borderless HUD bar
- Pin/Unpin functionality
- Dynamic font scaling (0.8x - 1.5x)
- METAR QNH display for departure and arrival
- Step climb FL (nFIR sFL) support
- Alarm system for data changes
- Real-time refresh from VATSIM and SimBrief
- HTTPS fetch (LuaSec) with curl fallback
- Pure ImGui rendering

### Deprecated
- ⚠️ Lua version no longer maintained
- ⚠️ Use native C plugin (v2.x) instead
- ⚠️ FlyWithLua no longer required

## Legacy Versions

### [1.0.0] - Initial Lua Release
- Basic VATSIM data display
- SimBrief integration
- Flight progress tracking
- METAR parsing

---

## Version Numbering

- **MAJOR**: Incompatible API/functionality changes
- **MINOR**: Backwards-compatible new features
- **PATCH**: Backwards-compatible bug fixes

## Links

- [GitHub Repository](https://github.com/vPilotKLMVA/vATC-Flightbar)
- [Releases](https://github.com/vPilotKLMVA/vATC-Flightbar/releases)
- [Issues](https://github.com/vPilotKLMVA/vATC-Flightbar/issues)
- [Development Repo](https://github.com/vPilotKLMVA/Developement) (Private)

---

**Legend**:
- `Added` - New features
- `Changed` - Changes in existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Security fixes
