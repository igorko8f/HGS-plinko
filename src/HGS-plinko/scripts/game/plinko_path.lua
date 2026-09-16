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
    position.z = math_utils.clamp(position.z, 0.0, 0.5)
    
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

    local reverse_nodes = {
        create_terminal_node(
            baskets[target].pos,
            target,
            baskets[target].row,
            baskets[target].col
        ),
    }

    -- Начинаем с колонки выбранной корзины.
    local cursor = target

    for row = rows, 1, -1 do
        local target_cursor = math_utils.clamp(cursor, 1, row)
        local next_cursor = cursor

        if next_cursor > target_cursor then
            next_cursor = next_cursor - 1
        elseif next_cursor < target_cursor then
            next_cursor = next_cursor + 1
        else
           
            local can_move_left = cursor > 1
            local can_move_right = cursor < row

            if can_move_left and can_move_right then
                if rng() > 0.5 then
                    next_cursor = cursor - 1
                else
                    next_cursor = cursor
                end
            elseif can_move_left then
                next_cursor = cursor - 1
            elseif can_move_right then
                next_cursor = cursor + 1
            end
        end

        local peg_col = math_utils.clamp(next_cursor, 1, row)
        local peg_node = peg_grid[row][peg_col]

        local exit_dir

        if next_cursor > cursor then
            exit_dir = EXIT_RIGHT
        else
            exit_dir = EXIT_LEFT
        end

        reverse_nodes[#reverse_nodes + 1] =
            create_path_node(peg_node, exit_dir)

        cursor = next_cursor
    end

    local path_nodes = {}

    for i = #reverse_nodes, 1, -1 do
        path_nodes[#path_nodes + 1] = reverse_nodes[i]
    end

    path_nodes[1] = create_spawn_node(board_state.spawn)

    return {
        seed = seed,
        bucket_index = target,
        nodes = path_nodes,
    }
end

return M
