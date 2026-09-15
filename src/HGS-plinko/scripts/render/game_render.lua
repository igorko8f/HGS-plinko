local config = require("scripts.config.board_config")

local M = {}

function M.default_viewport_size()
    local width = sys.get_config_int("display.width", config.width)
    local height = sys.get_config_int("display.height", config.height)
    
    return width, height
end

function M.root_position()
    local width, height = M.default_viewport_size()

    return vmath.vector3(width * 0.5, height * 0.5, 0)
end

return M
