-- ============================================================================
-- vATC Sync - Configuration
-- ============================================================================
--
-- Copyright (c) 2025 vPilot KLMVA
-- Licensed under the MIT License
-- GitHub: https://github.com/vPilotKLMVA/-LuaScripts-for-X-Plane-12
--
-- ============================================================================

local CONFIG = {
    callsign = "AUTO",
    poll_interval = 15,
    simbrief_pilot_id = "",

    auto_tune_com1 = false,
    auto_set_squawk = false,
    auto_fetch_simbrief = true,
    show_header_row = true,

-- if vatsimm dat is not available, or no atc controllers set auto default
    unicom_freq = 122.800,
    vfr_squawk = 2000,

    controller_priority = {
        DEL = 1, GND = 2, TWR = 3, APP = 4, DEP = 4, CTR = 5, FSS = 6
    },

    max_range_gnd_twr = 10,
    max_range_app = 50,
    max_range_ctr = 500,

    show_bar = true,
    bar_color = {0.12, 0.12, 0.12, 0.9},

    data_file = "vatsim_data.json",
    settings_file = "vATC_sync_settings.ini"
}

function CONFIG:get_data_path()
    return SCRIPT_DIRECTORY or "./"
end

return CONFIG
