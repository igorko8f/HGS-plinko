local M = {}

M.initial_balls = 10
M.regeneration_interval = 1
M.regeneration_balls_count = 3
M.basket_count = 4

M.baskets = {
    {
        probability = 0.5,
        score = 10
    },
    {
        probability = 0.4,
        score = 20
    },
    {
        probability = 0.3,
        score = 30
    },
    {
        probability = 0.2,
        score = 40
    },
    {
        probability = 0.1,
        score = 50
    },
    {
        probability = 0.1,
        score = 50
    },
    {
        probability = 0.2,
        score = 40
    },
    {
        probability = 0.3,
        score = 30
    },
    {
        probability = 0.4,
        score = 20
    },
    {
        probability = 0.5,
        score = 10
    }
}

M.board = {
    rows = 9,
    columns = 9,
    width = 560,
    height = 780,
}

return M
