local function get_screen_size()
    return render.get_width(), render.get_height()
end

local function get_screen_center()
    local width, height = get_screen_size()
    
    return vmath.vector3(
        width / 2,
        height / 2,
        0
    )
end
