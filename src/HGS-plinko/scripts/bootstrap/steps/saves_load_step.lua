local saves = require("scripts.data.save_system")

local M = {}

function M.run(context, complete)

    saves.load()
    complete(true)
    
end

return M