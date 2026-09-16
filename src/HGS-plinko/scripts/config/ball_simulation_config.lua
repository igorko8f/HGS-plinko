local M = {}

M.gravity = -1180
M.restitution = 0.78

M.speed = {
    min = 180,
    max = 920,
    terminal_max = 680,
}

M.steering = {
    strength = 5.2,
    max_lateral_acceleration = 1450,
    node_capture_radius = 18,
    terminal_capture_radius = 20,
}

M.jitter = {
    speed_ratio = 0.06,
}


return M
