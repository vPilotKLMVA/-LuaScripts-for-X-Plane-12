---@diagnostic disable: undefined-global
-- X-Plane 12 Advanced Dynamic Graphics Optimizer Script for FlyWithLua NG 2.8+
-- Author: Your Name

-- Path to X-Plane's main settings file and history log file
local settings_path = "Output/preferences/X-Plane.prf"
local history_path = "Output/preferences/optimization_history.txt"
local saved_state_path = "Output/preferences/saved_state.txt"

-- Default settings values
local default_settings = {
    renopt_planet = 1, -- Planet Render
    renopt_trees = 1,  -- Tree Render
    renopt_obj = 1,    -- Object Render
    renopt_veg = 1,    -- Vegetation Render
}

-- Adjustable Parameters
local min_frame_rate = 20  -- Minimum frame rate for calculations
local target_frame_rate = 30  -- Target frame rate in FPS
local adjustment_interval = 30 -- Base number of frames to wait before adjusting settings again
local min_interval = 10  -- Minimum interval in frames
local max_interval = 60  -- Maximum interval in frames
local performance_threshold = 0.5  -- Ratio of current to target frame rate to adjust frequency
local prediction_window = 10 -- Number of samples to consider for predicting frame rate
local min_render_quality = 0
local max_render_quality = 3
local learning_rate = 0.1  -- Learning rate for the Q-learning model
local log_file_size_limit = 1024  -- Size limit for the history log file in KB

-- Initialize frame count
local frame_count = 0

-- Frame rate averaging
local frame_rate_samples = {}

-- Cached settings
local current_settings = {}

-- Define a Q-table for Reinforcement Learning
local Q_table = {}

-- Cache the frame rate data reference
local frame_rate_period_ref = XPLMFindDataRef("sim/operation/misc/frame_rate_period")
local scenery_loading_ref = XPLMFindDataRef("sim/graphics/scenery/loading_percentage")

-- Ensure the settings file exists and initialize it if necessary
local function ensure_file_exists(file_path, default_content)
    local file = io.open(file_path, "r")
    if not file then
        file = io.open(file_path, "w")
        if file then
            if default_content then
                for key, value in pairs(default_content) do
                    file:write(string.format("%s %d\n", key, value))
                end
            end
            file:close()
            print("Created file at: " .. file_path)
        else
            print("Error: Could not create file at: " .. file_path)
        end
    else
        file:close()
    end
end

-- Ensure the settings file exists
local function ensure_settings_file()
    ensure_file_exists(settings_path, default_settings)
end

-- Ensure the history log file exists
local function ensure_history_file()
    ensure_file_exists(history_path)
end

-- Ensure the saved state file exists
local function ensure_saved_state_file()
    ensure_file_exists(saved_state_path)
end

-- Function to log optimization history
local function log_history(frame_rate, settings)
    local file = io.open(history_path, "a")  -- Open in append mode to create if not exist
    if not file then
        file = io.open(history_path, "w")  -- Create the file if it does not exist
        if not file then
            print("Error: Could not create history log file at: " .. history_path)
            return
        end
    end

    -- Check the file size and perform log rotation if necessary
    local current_size, err = file:seek("end")
    if not current_size or err then
        print("Error: Could not get file size.")
    else
        local file_size_kb = current_size / 1024
        if file_size_kb > log_file_size_limit then
            file:close()
            local backup_path = history_path .. ".bak"
            local success, rename_err = os.rename(history_path, backup_path)
            if not success then
                print("Error: Could not backup history log file. - " .. (rename_err or "unknown error"))
            else
                file = io.open(history_path, "w")  -- Create a new history log file
                if not file then
                    print("Error: Could not create new history log file at: " .. history_path)
                    return
                end
                print("History log file exceeded size limit. Backup created at: " .. backup_path)
            end
        end
    end

    local log_message = string.format("Frame Rate: %.2f, Settings: ", frame_rate)
    for key, value in pairs(settings) do
        log_message = log_message .. string.format("%s=%d, ", key, value)
    end
    log_message = log_message .. string.format("Timestamp: %s\n", os.date("%Y-%m-%d %H:%M:%S"))

    file:write(log_message)
    file:close()
    print("Logged history at: " .. history_path)
end

-- Function to save the current state
local function save_state()
    local file = io.open(saved_state_path, "w")
    if file then
        for key, value in pairs(current_settings) do
            file:write(string.format("%s=%d\n", key, value))
        end
        file:close()
        print("Saved state at: " .. saved_state_path)
    else
        print("Error: Could not save state to file at: " .. saved_state_path)
    end
end

-- Function to load the saved state
local function load_saved_state()
    local file = io.open(saved_state_path, "r")
    if file then
        for line in file:lines() do
            local key, value = line:match("([^=]+)=([^=]+)")
            if key and value then
                current_settings[key] = tonumber(value)
            end
        end
        file:close()
        print("Loaded saved state from: " .. saved_state_path)
    else
        current_settings = default_settings
        print("No saved state found. Using default settings.")
    end
end

-- Function to calculate the moving average of frame rate
local function calculate_moving_average(new_frame_rate)
    table.insert(frame_rate_samples, new_frame_rate)
    if #frame_rate_samples > prediction_window then
        table.remove(frame_rate_samples, 1)
    end
    local sum = 0
    for _, rate in ipairs(frame_rate_samples) do
        sum = sum + rate
    end
    return sum / #frame_rate_samples
end

-- Function to get the state representation
local function get_state()
    local state = 0
    for key, value in pairs(current_settings) do
        state = state + value * 10^key  -- Simple encoding of the settings as a state identifier
    end
    return state
end

-- Function to update the Q-table
local function update_Q_table(state, action, reward, next_state)
    local best_next_action = min_render_quality
    for a = min_render_quality, max_render_quality do
        if Q_table[next_state] and Q_table[next_state][a] then
            if Q_table[next_state][a] > (Q_table[next_state] and Q_table[next_state][best_next_action] or 0) then
                best_next_action = a
            end
        end
    end
    local old_value = Q_table[state] and Q_table[state][action] or 0
    local best_next_value = Q_table[next_state] and Q_table[next_state][best_next_action] or 0
    local new_value = old_value + learning_rate * (reward + best_next_value - old_value)
    Q_table[state] = Q_table[state] or {}
    Q_table[state][action] = new_value
end

-- Function to choose the best action based on the Q-table
local function choose_action()
    local state = get_state()
    local action = min_render_quality
    if Q_table[state] then
        local max_value = -math.huge
        for a = min_render_quality, max_render_quality do
            if Q_table[state][a] and Q_table[state][a] > max_value then
                max_value = Q_table[state][a]
                action = a
            end
        end
    end
    return action
end

-- Function to adjust settings based on the chosen action
local function adjust_settings(action)
    for key in pairs(current_settings) do
        local new_value = math.max(min_render_quality, math.min(max_render_quality, current_settings[key] + action))
        current_settings[key] = new_value
    end
end

-- Function to adjust quality settings during loading
local function adjust_quality_during_loading()
    local loading_percentage = XPLMGetDatai(scenery_loading_ref)
    if loading_percentage > 0 then
        -- Reduce settings during loading
        for key, value in pairs(current_settings) do
            if value > min_render_quality then
                current_settings[key] = current_settings[key] - 1
            end
        end
    else
        -- Restore settings after loading
        for key, value in pairs(current_settings) do
            if value < default_settings[key] then
                current_settings[key] = current_settings[key] + 1
            end
        end
    end
end

-- Function to get the frame rate
local function get_frame_rate()
    if frame_rate_period_ref then
        local frame_time = XPLMGetDataf(frame_rate_period_ref)
        if frame_time > 0 then
            return 1.0 / frame_time
        end
    end
    return 0
end

-- Function to write updated settings to the settings file
local function write_settings(settings)
    local file = io.open(settings_path, "w")
    if file then
        for key, value in pairs(settings) do
            file:write(string.format("%s %d\n", key, value))
        end
        file:close()
        print("Wrote updated settings to: " .. settings_path)
    else
        print("Error: Could not write settings to file at: " .. settings_path)
    end
end

-- Main optimization function
local function optimize_settings()
    -- Ensure the settings file exists
    ensure_history_file()  -- Ensure the history file exists
    ensure_saved_state_file()  -- Ensure the saved state file exists

    local frame_rate = get_frame_rate()
    if frame_rate == 0 then
        return
    end
    frame_rate = calculate_moving_average(frame_rate)

    -- Update target frame rate dynamically
    target_frame_rate = frame_rate

    -- Update adjustment interval based on performance
    adjustment_interval = math.max(min_interval, math.min(max_interval, math.floor(30 * (frame_rate / min_frame_rate))))

    -- Get the current state
    local state = get_state()

    -- Choose the best action based on the Q-table
    local action = choose_action()

    -- Adjust settings based on the chosen action
    adjust_settings(action)

    -- Calculate reward and update the Q-table
    local next_state = get_state()
    local reward = math.abs(target_frame_rate - frame_rate)  -- Reward based on proximity to target FPS
    update_Q_table(state, action, reward, next_state)

    -- Adjust quality during loading
    adjust_quality_during_loading()

    -- Write updated settings and log history
    write_settings(current_settings)
    log_history(frame_rate, current_settings)
    save_state()
end

-- Function to be called every frame
local function every_frame_handler()
    frame_count = frame_count + 1
    if frame_count >= adjustment_interval then
        optimize_settings()
        frame_count = 0
    end
end

-- Load saved state at startup
load_saved_state()

-- Ensure necessary files exist
ensure_settings_file()
ensure_history_file()
ensure_saved_state_file()

-- Register the function to be called every frame
do_every_frame(every_frame_handler)
