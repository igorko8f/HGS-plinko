local M = {}

function M.run(context, complete)

    context.bootstrap_complete = complete
    
    msg.post("/gameProxy", "load")
end


function M.handle_message(context, message_id)

    if message_id == hash("proxy_loaded") then
        msg.post("/gameProxy", "enable")
        context.bootstrap_complete(true)
    end

end

return M