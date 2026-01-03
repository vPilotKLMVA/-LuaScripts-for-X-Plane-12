# vATC Flightbar Enhanced

**Native X-Plane 12 plugin for comprehensive VATSIM flight information display**

![Version](https://img.shields.io/badge/version-2.1.0-blue)
![Platform](https://img.shields.io/badge/platform-Windows%2064--bit-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)
![X-Plane](https://img.shields.io/badge/X--Plane-12-orange)

## Overview

vATC Flightbar Enhanced is a native C plugin for X-Plane 12 that displays real-time flight information in a sleek, borderless bar at the top of your screen. Designed specifically for VATSIM pilots, it integrates with SimBrief flight plans and VATSIM data to provide comprehensive situational awareness during your flights.

### Key Features

✅ **Comprehensive Flight Data Display**
- Three-section layout: Departure / Cruise / Arrival
- Real-time aircraft data integration
- Flight phase detection (PARKED, TAXI, CLIMB, CRZ, APPR)

✅ **Weather Information**
- Current QNH (barometric pressure)
- Temperature and wind data
- METAR parsing (planned)

✅ **Navigation Data**
- GPS distance to destination
- Estimated time of arrival
- Flight progress tracking

✅ **ATC Integration** (Planned)
- Active controller information
- Current FIR (Flight Information Region)
- Next ATC frequency

✅ **SimBrief Integration** (Planned)
- Automatic flight plan loading
- Route information (SID, STAR, runways)
- Gate and parking information

✅ **VATSIM Integration** (Planned)
- Online status indication
- Live controller data
- Pilot position matching

### Display Sections

#### DEPARTURE (Left)
```
DEP | Callsign | ATC | Freq | Gate | SID | RWY | SQWK | QNH | METAR | TA | ETD | DIST
```

#### CRUISE (Center)
```
FIR:Freq | NextFIR
```

#### ARRIVAL (Right)
```
ARR | ETA | QNH | METAR | Temp | Wind | STAR | APPR | RWY
```

## Installation

### Requirements
- X-Plane 12 (Windows 64-bit)
- Visual C++ Runtime 2019 or later
- SimBrief account (optional, for flight plan integration)
- VATSIM account (optional, for online features)

### Installation Steps

1. **Download** the latest release from the [Releases](https://github.com/vPilotKLMVA/vATC-Flightbar/releases) page

2. **Extract** the downloaded ZIP file

3. **Copy** the `vATC` folder to your X-Plane plugins directory:
   ```
   X-Plane 12\Resources\plugins\vATC\
   ```

4. **Folder structure** should look like this:
   ```
   X-Plane 12\
   └── Resources\
       └── plugins\
           └── vATC\
               └── 64\
                   └── win.xpl
   ```

5. **Restart** X-Plane 12

6. **Verify** installation:
   - Go to **Plugins** menu → **vATC Enhanced**
   - The flight bar should appear at the top of your screen

## Usage

### Menu Options

Access the plugin menu via: **Plugins → vATC Enhanced**

- **Toggle Bar**: Show/hide the flight information bar
- **Toggle Header**: Show/hide the header row with field labels
- **Settings** (Coming soon): Configure SimBrief ID, VATSIM settings, colors, fonts

### Keyboard Shortcuts

*(Coming soon)*

### Display Modes

The plugin automatically adapts its display based on available data:

#### Mode 1: VATSIM Online (Cyan)
- Active when connected to VATSIM network
- Shows live controller data
- Real-time position tracking

#### Mode 2: SimBrief/Local (Blue)
- Active when flight plan loaded but offline
- Shows planned route information
- Local simulator data

#### Mode 3: Simulator Only (White/Gray)
- Fallback mode with no external data
- Basic aircraft information only

### Status Indicators

The status indicator `[*]` in the top-right changes color:

- 🔴 **Red**: Offline (no VATSIM connection)
- 🟠 **Orange**: Prefiled (flight plan filed but not connected)
- 🟢 **Green**: Online (active on VATSIM)

### Flight Phases

The plugin automatically detects your current flight phase:

- **PARKED**: On ground, speed < 5 knots
- **TAXI**: On ground, speed ≥ 5 knots
- **CLIMB**: Airborne, altitude < 20,000 ft
- **CRZ**: Altitude ≥ 20,000 ft
- **APPR**: Descent phase, distance < 30 NM, altitude < 5,000 ft

## Configuration

### SimBrief Integration

*(Coming in next release)*

1. Open **Plugins → vATC Enhanced → Settings**
2. Enter your SimBrief Pilot ID
3. Enable "Auto-fetch SimBrief"
4. Your flight plan will be automatically loaded from:
   ```
   X-Plane 12\Output\FMS plans\simbrief.xml
   ```

### VATSIM Integration

*(Coming in next release)*

The plugin will automatically fetch VATSIM data every 15 seconds from:
```
https://data.vatsim.net/v3/vatsim-data.json
```

## Troubleshooting

### Plugin Not Loading

1. Check that the plugin is in the correct folder:
   ```
   X-Plane 12\Resources\plugins\vATC\64\win.xpl
   ```

2. Check `Log.txt` in your X-Plane root folder for errors:
   ```
   X-Plane 12\Log.txt
   ```
   Look for lines containing "vATC Enhanced"

3. Verify you have Visual C++ Runtime installed:
   - Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe

### Display Issues

- **Bar not visible**: Press **Plugins → vATC Enhanced → Toggle Bar**
- **Text too small/large**: Adjust font scaling in Settings (coming soon)
- **Wrong position**: Plugin auto-adjusts to screen size, restart X-Plane if issues persist

### Data Not Showing

- **No flight plan data**: Ensure SimBrief XML is in `X-Plane 12\Output\FMS plans\`
- **No VATSIM data**: Check internet connection and VATSIM network status
- **Incomplete data**: Some fields require specific integrations (see Roadmap)

## Roadmap

### v2.2.0 (Next Release)
- [ ] Settings window with configuration options
- [ ] SimBrief XML parsing and integration
- [ ] Basic VATSIM data fetching

### v2.3.0
- [ ] Full VATSIM integration (controllers, FIR detection)
- [ ] METAR parsing for QNH
- [ ] Dynamic font scaling
- [ ] Custom color schemes

### v2.4.0
- [ ] Step climb FL calculation
- [ ] Data change alarms
- [ ] ETD/ETA tracking
- [ ] Keyboard shortcuts

### Future
- [ ] macOS support
- [ ] Linux support
- [ ] VR compatibility
- [ ] Multi-monitor support

## Development

This is a native C plugin using the X-Plane SDK.

**Development repository**: https://github.com/vPilotKLMVA/Developement (private)

### Building from Source

Requirements:
- Visual Studio Build Tools 2019+
- CMake 3.16+
- X-Plane SDK

See [CLAUDE.md](https://github.com/vPilotKLMVA/Developement/blob/main/CLAUDE.md) in the development repo for detailed build instructions.

## Support

### Getting Help

- **Issues**: Report bugs on [GitHub Issues](https://github.com/vPilotKLMVA/vATC-Flightbar/issues)
- **Forum**: [X-Plane.org Forums](https://forums.x-plane.org/profile/422092-pilot-mcwillem/)
- **Documentation**: See [Wiki](https://github.com/vPilotKLMVA/vATC-Flightbar/wiki) (coming soon)

### Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Credits

**Author**: Pilot McWillem (vPilot KLMVA)
**License**: MIT License (see LICENSE file)
**X-Plane SDK**: © Laminar Research

### Third-Party Libraries (Planned)
- **cJSON**: JSON parsing (MIT License)
- **libxml2**: XML parsing (MIT License)
- **libcurl**: HTTP requests (MIT License)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for the X-Plane and VATSIM communities**

[GitHub](https://github.com/vPilotKLMVA/vATC-Flightbar) | [Releases](https://github.com/vPilotKLMVA/vATC-Flightbar/releases) | [Issues](https://github.com/vPilotKLMVA/vATC-Flightbar/issues)
