local M = {}

M.initial_balls = 12
M.regeneration = {
    enabled = true,
    interval = 0.75,
}
M.basket_count = 4
M.board = {
    name = "classic",
    rows = 8,
    columns = 7,
    width = 560,
    height = 780,
}

return M
