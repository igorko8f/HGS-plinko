local M = {}

function M.default_viewport_size()
    local width = tonumber(sys.get_config("display.width"))
    local height = tonumber(sys.get_config("display.height"))
    
    return width, height
end

function M.root_position()
    local width, height = M.default_viewport_size()

    return vmath.vector3(width * 0.5, height * 0.5, 0)
end

return M
