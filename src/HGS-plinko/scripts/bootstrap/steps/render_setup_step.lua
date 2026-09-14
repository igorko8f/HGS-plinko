local M = {}

function M.run(context, complete)

    msg.post("@render:", "use_fixed_fit_projection", {
        near = -1,
        far = 1
    })
    
    complete(true)
    
end

return M    