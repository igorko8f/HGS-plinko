-- Per-frame physics for a single ball: gravity + steering toward the next
-- path node, integration and peg-bounce reactions. `plinko_path` decides
-- *where* a ball should end up; this module decides *how it moves* to get
-- there.
local M = {}
local path_module = require("scripts.game.plinko_path")
local math_utils = require("scripts.helpers.math_utils")
local vector_utils = require("scripts.helpers.vector_utils")

local function clamp_speed(velocity, min_speed, max_speed)
    local speed = vmath.length(velocity)
    if speed <= 0.0001 then
        return vmath.vector3(0, min_speed, 0)
    end

    if speed < min_speed then
        return vector_utils.normalize_or_zero(velocity) * min_speed
    end

    if speed > max_speed then
        return vector_utils.normalize_or_zero(velocity) * max_speed
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

-- Nudges the ball sideways toward the current target node so it tends to
-- follow the pre-generated path instead of falling straight down.
local function apply_steering(state, dt)
    local config = state.config
    local target = current_target(state)
    local desired = target.pos - state.position
    local lateral = math_utils.clamp(desired.x * config.steering.strength,
        -config.steering.max_lateral_acceleration, config.steering.max_lateral_acceleration)
    state.velocity = vmath.vector3(state.velocity.x + lateral * dt, state.velocity.y, state.velocity.z)
end

local function apply_gravity(state, dt)
    state.velocity = vmath.vector3(state.velocity.x, state.velocity.y + state.config.gravity * dt, state.velocity.z)
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

    local movement = state.position - previous_position
    local movement_length_sq = vmath.dot(movement, movement)
    if movement_length_sq <= 0.0001 then
        return false
    end

    local to_target = target.pos - previous_position
    local t = math_utils.clamp(vmath.dot(to_target, movement) / movement_length_sq, 0, 1)
    local closest = previous_position + movement * t
    return vmath.length(target.pos - closest) <= capture_radius
end

local function seeded_noise(state)
    return (state.rng() * 2) - 1
end

-- Which side (-1 left, 1 right) the ball should be deflected toward when it
-- hits a peg. Prefers the actual geometric direction to the next node; only
-- falls back to the path's recorded exit_dir when the horizontal difference
-- is negligible (e.g. straight down). Using exit_dir unconditionally can
-- disagree with real node positions (peg->basket rows aren't evenly spaced
-- the same way peg->peg rows are) and send the ball the wrong way.
local function bounce_exit_sign(target, target_direction)
    if math.abs(target_direction.x) > 0.5 then
        return math_utils.horizontal_sign(target_direction.x)
    end

    return math_utils.horizontal_sign(target.exit_dir or 1)
end

-- Mirrors the incoming velocity off a normal that leans toward exit_sign,
-- simulating the ball glancing off the peg.
local function reflect_off_peg(velocity, restitution, exit_sign)
    local peg_normal = vector_utils.normalize_or_zero(vmath.vector3(-exit_sign, 1, 0))
    return vector_utils.reflect(velocity, peg_normal) * restitution
end

-- Direction toward the next node, guaranteed to have a horizontal component
-- (falls back to exit_sign) so the ball never gets stuck heading straight down.
local function bounce_direction(target_direction, exit_sign)
    local direction = vector_utils.normalize_or_zero(target_direction)
    if direction.x == 0 then
        direction = vector_utils.normalize_or_zero(vmath.vector3(exit_sign, direction.y, direction.z))
    end

    return direction
end

local function apply_bounce(state, target)
    local config = state.config
    local target_direction = next_target(state).pos - target.pos
    local exit_sign = bounce_exit_sign(target, target_direction)

    local reflected_velocity = reflect_off_peg(state.velocity, config.restitution, exit_sign)
    local direction = bounce_direction(target_direction, exit_sign)
    local speed = math.max(vmath.length(reflected_velocity), config.speed.min)
    local jitter_scale = 1 + seeded_noise(state) * config.jitter.speed_ratio

    local bounce_velocity = direction * speed * jitter_scale
    local bounce_x = math.abs(bounce_velocity.x) * exit_sign
    local bounce_y = math.min(-math.abs(bounce_velocity.y), -config.speed.min * 0.45)
    state.velocity = clamp_speed(vmath.vector3(bounce_x, bounce_y, bounce_velocity.z), config.speed.min, config.speed.max)
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
        velocity = vmath.vector3(0, -config.speed.min, 0),
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
            state.velocity = vmath.vector3(0, 0, 0)
            state.landing_bucket_index = target.bucket_index
        end
    end

    if state.phase == "terminal" then
        state.velocity = clamp_speed(state.velocity, state.config.speed.min, state.config.speed.terminal_max)
    end

    return state
end

return M
