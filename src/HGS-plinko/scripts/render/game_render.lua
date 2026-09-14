local M = {}

function M.viewport_size()
    return render.get_width(), render.get_height()
end

function M.root_position()
    local width, height = M.viewport_size()

    return vmath.vector3(width * 0.5, height * 0.5, 0)
end

return M
