local M = {}

M.rows = 9
M.width = 560
M.height = 780

M.origin = {
    x = 0.5,
    y = 0.8,
}

M.spawn = {
    y = 720,
}

M.peg = {
    spacing_x = 52,
    spacing_y = 56,
    scale = 1,
}

M.basket = {
    base_width = 64,
    base_y = 50,
    cover_ratio = 0.95,
}

return M
