local constants = require("constants")
local utils = require("utils")

local Ring = {}
Ring.__index = Ring

function Ring:new(index)
    local radius = constants.RING_RADIUS_START + (index - 1) * constants.RING_SPACING
    return setmetatable({
        radius = radius,
        rotation = index * 0.02,
        wiggle_offset = index * 0.04 * math.pi,
        is_destroyed = false
    }, Ring)
end

setmetatable(Ring, { __call = Ring.new })

function Ring:update(dt, ball)
    local sine_effect = math.sin(love.timer.getTime() * 0.5 + self.wiggle_offset) * 0.005
    self.rotation = self.rotation + constants.ROTATION_SPEED * dt + sine_effect

    local dx = ball.x - constants.CENTER_X
    local dy = ball.y - constants.CENTER_Y
    local dist = math.sqrt(dx * dx + dy * dy)
    local angle = math.atan2(dy, dx)
    if angle < 0 then angle = angle + 2 * math.pi end

    if dist >= (self.radius - ball.radius) and dist <= self.radius and utils.isInGap(angle, self) then
        self.is_destroyed = true
    end
end

function Ring:draw()
    love.graphics.setColor(0.3, 0.3, 0.3)
    local segments = 250
    local angle_step = 2 * math.pi / segments

    for i = 0, segments - 1 do
        local world_angle1 = i * angle_step
        local world_angle2 = (i + 1) * angle_step

        if not (utils.isInGap(world_angle1, self) and utils.isInGap(world_angle2, self)) then
            local x1 = constants.CENTER_X + math.cos(world_angle1) * self.radius
            local y1 = constants.CENTER_Y + math.sin(world_angle1) * self.radius
            local x2 = constants.CENTER_X + math.cos(world_angle2) * self.radius
            local y2 = constants.CENTER_Y + math.sin(world_angle2) * self.radius
            love.graphics.line(x1, y1, x2, y2)
        end
    end
end

return Ring
