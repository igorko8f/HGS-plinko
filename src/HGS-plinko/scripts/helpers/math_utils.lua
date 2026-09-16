local M = {}

function M.clamp(value, min_value, max_value)
    return math.max(min_value, math.min(max_value, value))
end

function M.create_rng(seed)
    local state = seed % 2147483647
    if state <= 0 then
        state = state + 2147483646
    end

    return function()
        state = (state * 48271) % 2147483647
        return state / 2147483647
    end
end

function M.horizontal_sign(value)
    if value < 0 then
        return -1
    end

    return 1
end

return M