-- ============================================================================
-- vATC Sync - XPLM FFI Integration
-- ============================================================================
--
-- Copyright (c) 2025 vPilot KLMVA
-- Licensed under the MIT License
-- GitHub: https://github.com/vPilotKLMVA/-LuaScripts-for-X-Plane-12
--
-- Provides fallback data access via X-Plane datarefs when offline
--
-- ============================================================================

local XPLM_FFI = {}

local ffi_available = false
local ffi = nil
local XPLM = nil

-- Initialize FFI
function XPLM_FFI.init()
    local ok, result = pcall(function() return require("ffi") end)
    if not ok or not result then
        return false
    end

    ffi = result
    ffi_available = true

    -- Determine XPLM library path
    local XPLMlib = ""
    if SYSTEM == "IBM" then
        XPLMlib = "XPLM_64"  -- Windows
    elseif SYSTEM == "LIN" then
        XPLMlib = "Resources/plugins/XPLM_64.so"  -- Linux
    elseif SYSTEM == "APL" then
        XPLMlib = "Resources/plugins/XPLM.framework/XPLM"  -- macOS
    else
        return false
    end

    -- Load XPLM library
    local ok_load, lib = pcall(function() return ffi.load(XPLMlib) end)
    if not ok_load then
        ffi_available = false
        return false
    end

    XPLM = lib

    -- Define C types
    ffi.cdef[[
        typedef void *XPLMDataRef;
        XPLMDataRef XPLMFindDataRef(const char *inDataRefName);
        int XPLMGetDatab(XPLMDataRef inDataRef, void *outValue, int inOffset, int inMaxBytes);
        int XPLMGetDatai(XPLMDataRef inDataRef);
        float XPLMGetDataf(XPLMDataRef inDataRef);
        double XPLMGetDatad(XPLMDataRef inDataRef);
    ]]

    return true
end

-- Get aircraft livery path
function XPLM_FFI.get_aircraft_livery()
    if not ffi_available then return nil end

    local acf_livery_path_dr = XPLM.XPLMFindDataRef("sim/aircraft/view/acf_livery_path")
    if acf_livery_path_dr == nil then return nil end

    local buffer = ffi.new("char[256]")
    local n = XPLM.XPLMGetDatab(acf_livery_path_dr, buffer, 0, 255)
    if n > 0 then
        return ffi.string(buffer)
    end

    return nil
end

-- Get aircraft type (ICAO code)
function XPLM_FFI.get_aircraft_type()
    if not ffi_available then return nil end

    local acf_icao_dr = XPLM.XPLMFindDataRef("sim/aircraft/view/acf_ICAO")
    if acf_icao_dr == nil then return nil end

    local buffer = ffi.new("char[40]")
    local n = XPLM.XPLMGetDatab(acf_icao_dr, buffer, 0, 39)
    if n > 0 then
        return ffi.string(buffer)
    end

    return nil
end

-- Get tail number
function XPLM_FFI.get_tail_number()
    if not ffi_available then return nil end

    local tail_dr = XPLM.XPLMFindDataRef("sim/aircraft/view/acf_tailnum")
    if tail_dr == nil then return nil end

    local buffer = ffi.new("char[40]")
    local n = XPLM.XPLMGetDatab(tail_dr, buffer, 0, 39)
    if n > 0 then
        return ffi.string(buffer)
    end

    return nil
end

-- Check if aircraft data matches flight plan
function XPLM_FFI.validate_aircraft(expected_icao)
    if not ffi_available or not expected_icao then return true end

    local actual_icao = XPLM_FFI.get_aircraft_type()
    if not actual_icao then return true  -- Can't validate, assume OK

    -- Normalize comparison (remove whitespace, uppercase)
    local exp = expected_icao:gsub("%s+", ""):upper()
    local act = actual_icao:gsub("%s+", ""):upper()

    return exp == act
end

return XPLM_FFI
