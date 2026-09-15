local M = {}

local function board_origin(board_config, viewport)
    local origin = board_config.origin
    return viewport.width * origin.x, viewport.height * origin.y
end

function M.build_peg_positions(board_config, viewport)
    local rows = board_config.rows
    local peg = board_config.peg
    local peg_spacing_x = peg.spacing_x
    local peg_spacing_y = peg.spacing_y
    local center_x, top_y = board_origin(board_config, viewport)
    local positions = {}

    for row = 1, rows do
        local count = row
        local y = top_y - (row - 1) * peg_spacing_y
        local start_x = center_x - ((count - 1) * peg_spacing_x) * 0.5

        for i = 1, count do
            positions[#positions + 1] = vmath.vector3(start_x + (i - 1) * peg_spacing_x, y, 0.2)
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
        positions[#positions + 1] = vmath.vector3(x, y, 0.2)
    end

    return positions
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
