local M = {}

M.initial_balls = 10
M.regeneration = {
    enabled = true,
    interval = 1,
    balls_count = 3,
}
M.basket_count = 10

M.baskets = {
    { probability = 1, score = 10 },
    { probability = 0, score = 20 },
    { probability = 0, score = 30 },
    { probability = 0, score = 40 },
    { probability = 0, score = 50 },
    { probability = 0, score = 50 },
    { probability = 0, score = 40 },
    { probability = 0, score = 30 },
    { probability = 0, score = 20 },
    { probability = 1, score = 10 },
}

return M
