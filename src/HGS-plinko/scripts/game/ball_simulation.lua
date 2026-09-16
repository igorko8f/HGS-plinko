local M = {}
local path_module = require("scripts.game.plinko_path")

local function clamp(value, min_value, max_value)
    return math.max(min_value, math.min(max_value, value))
end

local function horizontal_sign(value)
    if value < 0 then
        return -1
    end

    return 1
end

local function normalize_or_zero(vector)
    local length = vmath.length(vector)
    if length <= 0.0001 then
        return vmath.vector3()
    end

    return vector / length
end

local function reflect(vector, normal)
    local scale = 2 * vmath.dot(vector, normal)
    return vector - (normal * scale)
end

local function vec3(x, y, z)
    return vmath.vector3(x, y, z or 0)
end

local function x_of(vector)
    return vector.x
end

local function y_of(vector)
    return vector.y
end

local function z_of(vector)
    return vector.z or 0
end

local function length3(vector)
    local x = x_of(vector)
    local y = y_of(vector)
    local z = z_of(vector)
    return math.sqrt((x * x) + (y * y) + (z * z))
end

local function clamp_speed(velocity, min_speed, max_speed)
    local speed = vmath.length(velocity)
    if speed <= 0.0001 then
        return vec3(0, min_speed, 0)
    end

    if speed < min_speed then
        return normalize_or_zero(velocity) * min_speed
    end

    if speed > max_speed then
        return normalize_or_zero(velocity) * max_speed
    end

    return velocity
end

local function advance_node(state)
    state.node_index = math.min(state.node_index + 1, #state.path.nodes)
end

local function current_target(state)
    return state.path.nodes[state.node_index]
end

local function next_target(state)
    return state.path.nodes[math.min(state.node_index + 1, #state.path.nodes)]
end

local function apply_steering(state, dt)
    local config = state.config
    local target = current_target(state)
    local desired = target.pos - state.position
    local lateral = clamp(x_of(desired) * config.steering.strength, -config.steering.max_lateral_acceleration, config.steering.max_lateral_acceleration)
    state.velocity = vec3(x_of(state.velocity) + lateral * dt, y_of(state.velocity), z_of(state.velocity))
end

local function apply_gravity(state, dt)
    state.velocity = vec3(x_of(state.velocity), y_of(state.velocity) + state.config.gravity * dt, z_of(state.velocity))
end

local function integrate(state, dt)
    state.position = state.position + state.velocity * dt
end

local function capture_target(state, target, previous_position)
    local capture_radius = state.config.steering.node_capture_radius
    if target.type == "terminal" then
        capture_radius = state.config.steering.terminal_capture_radius
    end

    if vmath.length(target.pos - state.position) <= capture_radius then
        return true
    end

    -- Swept check: also capture if the target was crossed during this frame's
    -- movement (prevents missing a node when velocity is high relative to dt).
    local movement = state.position - previous_position
    local movement_length_sq = vmath.dot(movement, movement)
    if movement_length_sq <= 0.0001 then
        return false
    end

    local to_target = target.pos - previous_position
    local t = clamp(vmath.dot(to_target, movement) / movement_length_sq, 0, 1)
    local closest = previous_position + movement * t
    return vmath.length(target.pos - closest) <= capture_radius
end

local function seeded_noise(state)
    return (state.rng() * 2) - 1
end

local function apply_bounce(state, target)
    local config = state.config
    local target_direction = next_target(state).pos - target.pos
    -- Prefer the actual geometric direction to the next node; only fall back
    -- to the path's recorded exit_dir when the horizontal difference is
    -- negligible (e.g. straight down). Using exit_dir unconditionally can
    -- disagree with real node positions (peg->basket rows aren't evenly
    -- spaced the same way peg->peg rows are) and send the ball the wrong way.
    local desired_exit_sign
    if math.abs(x_of(target_direction)) > 0.5 then
        desired_exit_sign = horizontal_sign(x_of(target_direction))
    else
        desired_exit_sign = horizontal_sign(target.exit_dir or 1)
    end

    local guided_normal = normalize_or_zero(vmath.vector3(-desired_exit_sign, 1, 0))
    local bounce_velocity = reflect(state.velocity, guided_normal) * config.restitution
    local aligned = normalize_or_zero(target_direction)
    local aligned_speed = math.max(length3(bounce_velocity), config.speed.min)
    local jitter_scale = 1 + seeded_noise(state) * config.jitter.speed_ratio
    local bounce_x
    local bounce_y

    if x_of(aligned) == 0 then
        aligned = normalize_or_zero(vec3(desired_exit_sign, y_of(aligned), z_of(aligned)))
    end

    bounce_velocity = aligned * aligned_speed * jitter_scale
    bounce_x = math.abs(x_of(bounce_velocity)) * desired_exit_sign
    bounce_y = math.min(-math.abs(y_of(bounce_velocity)), -config.speed.min * 0.45)
    state.velocity = clamp_speed(vec3(bounce_x, bounce_y, z_of(bounce_velocity)), config.speed.min, config.speed.max)

    local angle_jitter = seeded_noise(state) * config.jitter.bounce_angle
    state.angular_velocity = clamp(
        state.angular_velocity + state.velocity.x * config.spin.bounce_impulse + angle_jitter,
        -config.spin.max_angular_velocity,
        config.spin.max_angular_velocity
    )
end

local function update_spin(state, dt)
    local spin = state.config.spin
    local velocity_spin = state.velocity.x * spin.velocity_to_angular
    state.angular_velocity = state.angular_velocity + (velocity_spin - state.angular_velocity) * math.min(1, spin.damping * dt)
    state.rotation = state.rotation + state.angular_velocity * dt
end

local function update_phase(state, target)
    if target.type == "terminal" then
        state.phase = "terminal"
    elseif target.type == "peg" then
        state.phase = "fly"
    end
end

function M.create(path, config)
    local spawn = path.nodes[1]

    return {
        path = path,
        config = config,
        position = vmath.vector3(spawn.pos),
        velocity = vec3(0, -config.speed.min, 0),
        rotation = 0,
        angular_velocity = 0,
        node_index = 2,
        phase = "spawn",
        landed = false,
        landing_bucket_index = nil,
        rng = path_module.create_rng(path.seed + 97),
    }
end

function M.update(state, dt)
    if state.landed then
        return state
    end

    local target = current_target(state)
    update_phase(state, target)
    apply_gravity(state, dt)
    apply_steering(state, dt)
    state.velocity = clamp_speed(state.velocity, state.config.speed.min, state.config.speed.max)
    local previous_position = vmath.vector3(state.position)
    integrate(state, dt)

    if capture_target(state, target, previous_position) then
        state.position = vmath.vector3(target.pos)

        if target.type == "peg" then
            state.phase = "peg-bounce"
            apply_bounce(state, target)
            advance_node(state)
        elseif target.type == "terminal" then
            state.phase = "landed"
            state.landed = true
            state.velocity = vec3(0, 0, 0)
            state.landing_bucket_index = target.bucket_index
        end
    end

    if state.phase == "terminal" then
        state.velocity = clamp_speed(state.velocity, state.config.speed.min, state.config.speed.terminal_max)
    end

    update_spin(state, dt)
    return state
end

return M
