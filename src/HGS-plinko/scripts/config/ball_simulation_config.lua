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
    bounce_angle = 0.08,
    speed_ratio = 0.06,
}

M.spin = {
    velocity_to_angular = 0.065,
    bounce_impulse = 0.11,
    damping = 6,
    max_angular_velocity = 12,
}

return M
