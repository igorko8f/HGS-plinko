local math_utils = require("scripts.helpers.math_utils")
local config = require("scripts.config.game_config")

local M = {}

local data = {
    score = 0,
    balls_count = config.initial_balls,
    recovery_end_time = (os.time() + config.regeneration.interval),
    balls_for_play_count = 1
}

function M.get_score()
    return data.score
end

function M.add_score(amount)
    data.score = math_utils.clamp(data.score + amount, 0, math.huge)
end

function M.get_balls_count()
    return data.balls_count
end

function M.add_balls(count)
    data.balls_count = math_utils.clamp(data.balls_count + count, 0, config.maximum_balls)
end

function M.get_playable_balls_count()
    return data.balls_for_play_count
end

function M.add_playable_balls_count(count)
    data.balls_for_play_count = math_utils.clamp(data.balls_for_play_count + count, 1, config.maximum_balls)
end

function M.get_recovery_end_time()
    return data.recovery_end_time
end

function M.set_recovery_end_time(count)
    data.recovery_end_time = count
end

function M.get_recovery_time_left()
    return math.max(0, data.recovery_end_time - os.time())
end

function M.get_data()
    return data
end

function M.set_data(saved_data)
    if not saved_data then
        return
    end

    data.score = saved_data.score or 0
    data.balls_count = saved_data.balls_count or config.initial_balls
    data.recovery_end_time = saved_data.recovery_end_time or (os.time() + config.regeneration.interval)
    data.balls_for_play_count = saved_data.balls_for_play_count or 1
end

return M