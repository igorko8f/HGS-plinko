local M = {}

M.initial_balls = 10
M.maximum_balls = 10
M.regeneration = {
    interval = 180,
    balls_count = 3,
}

M.baskets = {
    { probability = 5, score = 10 },
    { probability = 4, score = 20 },
    { probability = 5, score = 30 },
    { probability = 3, score = 40 },
    { probability = 1, score = 50 },
    { probability = 1, score = 50 },
    { probability = 3, score = 40 },
    { probability = 5, score = 30 },
    { probability = 4, score = 20 },
    { probability = 5, score = 10 },
}

return M
