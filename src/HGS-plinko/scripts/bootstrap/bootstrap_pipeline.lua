local Pipeline = {}

local function validate_step(step, index)
    assert(
        type(step) == "table",
        string.format("Bootstrap step %d must be a table", index)
    )

    assert(
        type(step.run) == "function",
        string.format("Bootstrap step %d must have a run() function", index)
    )
end

function Pipeline.run(context, steps, complete)

    -- Simple runtime validation to ensure that the steps has run function
    for i, step in ipairs(steps) do
        validate_step(step, i)
    end

    local index = 1

    local function run_next(success, error)

        if not success then
            complete(false, error)
            return
        end

        if index > #steps then
            complete(true)
            return
        end

        local step = steps[index]

        Pipeline.current_step = steps[index]
        Pipeline.context = context
        
        index = index + 1
        step.run(context, run_next)
    end

    run_next(true)
end

function Pipeline.on_message(message_id, message, sender)
    if Pipeline.current_step == nil then
        return
    end

    Pipeline.current_step.handle_message(
        Pipeline.context,
        message_id
    )
end

return Pipeline