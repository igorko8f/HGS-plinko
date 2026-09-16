-- Small vmath.vector3 helpers that aren't provided by the Defold vmath API.
local M = {}

function M.normalize_or_zero(vector)
    local length = vmath.length(vector)
    if length <= 0.0001 then
        return vmath.vector3()
    end

    return vector / length
end

function M.reflect(vector, normal)
    local scale = 2 * vmath.dot(vector, normal)
    return vector - (normal * scale)
end

return M