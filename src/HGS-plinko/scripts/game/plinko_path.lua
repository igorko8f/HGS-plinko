-- Generates the sequence of board nodes (spawn -> pegs -> basket) a ball
-- will be steered along, and picks which basket a new ball should target
-- based on configured basket probabilities. The physical bounce/steering
-- simulation lives in ball_simulation.lua.
local math_utils = require("scripts.helpers.math_utils")

local M = {}

local EXIT_LEFT = -1
local EXIT_RIGHT = 1

local function copy_node(node)
    local result = {
        type = node.type,
        pos = vmath.vector3(node.pos),
        row = node.row,
        col = node.col,
    }

    if node.bucket_index ~= nil then
        result.bucket_index = node.bucket_index
    end

    return result
end

local function create_spawn_node(position)
    return {
        type = "spawn",
        pos = vmath.vector3(position),
        row = 0,
        col = 1,
    }
end

local function create_terminal_node(position, bucket_index, row, col)
    return {
        type = "terminal",
        pos = vmath.vector3(position),
        row = row,
        col = col,
        bucket_index = bucket_index,
    }
end

local function create_path_node(node, exit_dir)
    local path_node = copy_node(node)
    path_node.exit_dir = exit_dir
    return path_node
end

function M.create_rng(seed)
    return math_utils.create_rng(seed)
end

function M.select_bucket_index(baskets, weights, rng)
    local total = 0
    for i = 1, #baskets do
        local basket = weights[i]
        total = total + (basket and basket.probability or 0)
    end

    if total <= 0 then
        return math.ceil(#baskets * 0.5)
    end

    local threshold = rng() * total
    local cumulative = 0

    for i = 1, #baskets do
        local basket = weights[i]
        cumulative = cumulative + (basket and basket.probability or 0)
        if threshold <= cumulative then
            return i
        end
    end

    return #baskets
end

function M.generate(board_state, bucket_index, seed)
    local peg_grid = board_state.pegs
    local baskets = board_state.baskets
    local rows = #peg_grid
    local target = math_utils.clamp(bucket_index, 1, #baskets)
    local rng = math_utils.create_rng(seed)
    local path_nodes = {
        create_spawn_node(board_state.spawn),
    }
    local cursor = 1

    for row = 1, rows do
        local next_cursor = cursor
        local steps_remaining = rows - row
        local target_cursor = math_utils.clamp(target, 1, row + 1)

        if next_cursor < target_cursor then
            next_cursor = next_cursor + 1
        elseif next_cursor > target_cursor then
            next_cursor = next_cursor - 1
        else
            local min_target = math.max(1, target - steps_remaining)
            local max_target = math.min(row + 1, target)
            local can_move_right = next_cursor < row and target <= max_target
            local can_stay_left = target >= min_target

            if can_move_right and can_stay_left and rng() > 0.5 then
                next_cursor = next_cursor + 1
            end
        end

        local peg_col = math_utils.clamp(cursor, 1, row)
        local exit_dir = next_cursor > cursor and EXIT_RIGHT or EXIT_LEFT
        local peg_node = peg_grid[row][peg_col]
        path_nodes[#path_nodes + 1] = create_path_node(peg_node, exit_dir)
        cursor = next_cursor
    end

    local basket_node = baskets[target]
    path_nodes[#path_nodes + 1] = create_terminal_node(
        basket_node.pos,
        target,
        basket_node.row,
        basket_node.col
    )

    return {
        seed = seed,
        bucket_index = target,
        nodes = path_nodes,
    }
end

return M
