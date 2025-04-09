local constants = require("constants")

local function isInGap(angle, ring)
    local start_angle = ring.rotation
    local end_angle = ring.rotation + constants.GAP_ARC

    angle = angle % (2 * math.pi)
    start_angle = start_angle % (2 * math.pi)
    end_angle = end_angle % (2 * math.pi)

    if start_angle < end_angle then
        return angle >= start_angle and angle <= end_angle
    else
        return angle >= start_angle or angle <= end_angle
    end
end

return {
    isInGap = isInGap
}
