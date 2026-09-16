-- Computes board layout (peg grid, basket slots, spawn point) in screen
-- coordinates for a given viewport size. Pure geometry — no gameplay state.
local M = {}

local function board_origin(board_config, viewport)
    local origin = board_config.origin
    return viewport.width * origin.x, viewport.height * origin.y
end

local function build_node(node_type, position, row, col)
    return {
        type = node_type,
        pos = vmath.vector3(position),
        row = row,
        col = col,
    }
end

function M.build_peg_grid(board_config, viewport)
    local rows = board_config.rows
    local peg = board_config.peg
    local peg_spacing_x = peg.spacing_x
    local peg_spacing_y = peg.spacing_y
    local center_x, top_y = board_origin(board_config, viewport)
    local grid = {}

    for row = 1, rows do
        local count = row
        local y = top_y - (row - 1) * peg_spacing_y
        local start_x = center_x - ((count - 1) * peg_spacing_x) * 0.5
        local row_nodes = {}

        for col = 1, count do
            row_nodes[col] = build_node(
                "peg",
                vmath.vector3(start_x + (col - 1) * peg_spacing_x, y, 0.2),
                row,
                col
            )
        end

        grid[row] = row_nodes
    end

    return grid
end

function M.build_peg_positions(board_config, viewport)
    -- Reuses build_peg_grid instead of recomputing peg layout math, so the
    -- two never drift out of sync with each other.
    local positions = {}

    for _, row_nodes in ipairs(M.build_peg_grid(board_config, viewport)) do
        for _, node in ipairs(row_nodes) do
            positions[#positions + 1] = node.pos
        end
    end

    return positions
end

function M.build_basket_positions(board_config, basket_count, viewport)
    local positions = {}
    local count = basket_count
    local slot_width = viewport.width / count
    local basket = board_config.basket
    local y = basket.base_y

    for i = 1, count do
        local x = (i - 0.5) * slot_width
        positions[#positions + 1] = vmath.vector3(x, y, 0.6)
    end

    return positions
end

function M.build_basket_nodes(board_config, basket_count, viewport)
    local positions = M.build_basket_positions(board_config, basket_count, viewport)
    local nodes = {}

    for i, position in ipairs(positions) do
        nodes[i] = build_node("basket", position, board_config.rows + 1, i)
        nodes[i].bucket_index = i
    end

    return nodes
end

function M.build_spawn_position(board_config, viewport)
    local center_x = viewport.width * board_config.origin.x
    local spawn_y = board_config.spawn and board_config.spawn.y or viewport.height * board_config.origin.y
    return vmath.vector3(center_x, spawn_y, 0.5)
end

function M.peg_scale(board_config)
    local peg = board_config.peg
    return peg.scale
end

function M.basket_scale(board_config, basket_count, viewport)
    local basket = board_config.basket
    local count = basket_count
    local base_width = basket.base_width
    local cover_ratio = basket.cover_ratio

    local desired_width = (viewport.width / count) * cover_ratio
    local scale = desired_width / base_width

    return scale
end

return M
