local data = require("scripts.data.game_data")

local M = {}

local SAVE_FILE = "game_data"
local dirty = false

function M.mark_dirty()
    dirty = true
end

function M.save_if_dirty()
    if not dirty then
        return false
    end

    local success = M.save()
    if success then 
        dirty = false
    end

    return success
end

function M.save()
    local data_to_save = data.get_data()
    local success = sys.save(SAVE_FILE, data_to_save)

    if not success then
        print("Failed to save game data")
        return false
    end

    print("Game data saved")
    return true
end

function M.load()
    local saved_data = sys.load(SAVE_FILE)

    if not saved_data then
        print("No save data found")
        return false
    end

    data.set_data(saved_data)

    print("Game data loaded")

    return true
end

return M