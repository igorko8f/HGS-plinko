local M = {}

M.rows = 9
M.width = 560
M.height = 780

M.origin = {
    x = 0.5,
    y = 0.62,
}

M.peg = {
    spacing_x = 32,
    spacing_y = 36,
    scale = 0.35,
}

M.basket = {
    base_y = 72,
    min_scale = 0.22,
    max_scale = 0.9,
}
    
M.hole = {
    x = 0.5,
    y = 0.92,
    scale = 0.18,
}

return M
