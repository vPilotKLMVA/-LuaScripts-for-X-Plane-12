-- ============================================================================
-- vATC SYNC for X-Plane 12 - Main Loader
-- ============================================================================
--
-- Copyright (c) 2025 vPilot KLMVA
-- Licensed under the MIT License
-- GitHub: https://github.com/vPilotKLMVA/-LuaScripts-for-X-Plane-12
-- Forum: https://forums.x-plane.org/profile/422092-pilot-mcwillem/
--
-- This is the main loader file for vATC Sync.
-- FlyWithLua loads this file, which then loads the vATC_sync module.
--
-- ============================================================================

-- Load the main vATC_sync module
if not SUPPORTS_FLOATING_WINDOWS then
    logMsg("vATC Sync: ERROR - Requires floating windows support (FlyWithLua NG)")
    return
end

if not SCRIPT_DIRECTORY then
    logMsg("vATC Sync: ERROR - SCRIPT_DIRECTORY not available")
    return
end

-- Ensure trailing slash/backslash on SCRIPT_DIRECTORY before concatenation
local script_dir = SCRIPT_DIRECTORY
local last_char = script_dir:sub(-1)
if last_char ~= '/' and last_char ~= '\\' then
    script_dir = script_dir .. '/'
end

-- Load the init.lua from vATC_sync folder
local module_path = script_dir .. "vATC_sync/init.lua"

-- Use loadfile so we get clear load/compile errors, then pcall the loaded chunk
local chunk, load_err = loadfile(module_path)
if not chunk then
    logMsg("vATC Sync: ERROR - Cannot load " .. module_path .. " - " .. tostring(load_err))
    return
end

local ok, exec_err = pcall(chunk)
if not ok then
    logMsg("vATC Sync: ERROR executing module - " .. tostring(exec_err))
else
    logMsg("vATC Sync: Main loader complete")
end
