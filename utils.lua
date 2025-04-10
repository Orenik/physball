local constants = require("constants")

local function isInGap(world_angle, ring)
    -- Undo the ring's rotation to bring world angle to ring-local angle
    local local_angle = (world_angle - ring.rotation) % (2 * math.pi)

    -- The gap always starts at 0 and ends at GAP_ARC in local space
    return local_angle >= 0 and local_angle <= constants.GAP_ARC
end

return {
    isInGap = isInGap
}
