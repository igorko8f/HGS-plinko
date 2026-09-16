local M = {}

local function calculate_jump_duration(from, to, speed)
    local distance = vmath.length(to - from)

    if speed <= 0.0001 then
        return 0.01
    end

    return math.max(distance / speed, 0.01)
end

local function calculate_jump_position(from, to, t, height)
    local position = from + (to - from) * t
    position.y = position.y + math.sin(t * math.pi) * height

    return position
end

local function begin_jump(state)
    local from_node = state.path.nodes[state.node_index - 1]
    local target_node = state.path.nodes[state.node_index]

    if not from_node or not target_node then
        return false
    end

    state.jump.from = vmath.vector3(from_node.pos)
    state.jump.to = vmath.vector3(target_node.pos)

    state.jump.elapsed = 0

    state.jump.duration = calculate_jump_duration(
        state.jump.from,
        state.jump.to,
        state.config.speed
    )

    state.jump.height = state.config.height

    return true
end

local function finish_jump(state)
    local target = state.path.nodes[state.node_index]
    state.position = vmath.vector3(target.pos)

    if target.type == "terminal" then
        state.phase = "landed"
        state.landed = true
        state.landing_bucket_index = target.bucket_index

        return
    end

    state.node_index = state.node_index + 1

    if not begin_jump(state) then
        state.landed = true
        state.phase = "landed"
    end
end

function M.create(path, config)
    local spawn = path.nodes[1]

    local state = {
        path = path,
        config = config,

        position = vmath.vector3(spawn.pos),
        node_index = 2,

        jump = {
            from = nil,
            to = nil,
            elapsed = 0,
            duration = 0,
            height = 0,
        },

        phase = "spawn",

        landed = false,
        landing_bucket_index = nil,
    }

    begin_jump(state)

    return state
end

function M.update(state, dt)
    if state.landed then
        return state
    end

    local jump = state.jump

    jump.elapsed = jump.elapsed + dt

    local t = math.min(
        jump.elapsed / jump.duration,
        1
    )

    state.position = calculate_jump_position(
        jump.from,
        jump.to,
        t,
        jump.height
    )

    state.phase = "jump"

    if t >= 1 then
        finish_jump(state)
    end

    return state
end

return M