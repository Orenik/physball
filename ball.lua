local constants = require("constants")
local utils = require("utils")
local ParticleManager = require("particles")


local Ball = {}
Ball.__index = Ball

function Ball:new(x, y, vx, vy)
    particles = ParticleManager()
    return setmetatable({
        x = x, y = y,
        vx = vx or 0, vy = vy or 0,
        radius = constants.BALL_RADIUS,
        is_outside = false
    }, Ball)
end

setmetatable(Ball, { __call = Ball.new })

function Ball:update(dt, rings)
    if self.is_outside then
        self.vy = self.vy + constants.GRAVITY * dt
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
        return
    end

    self.vy = self.vy + constants.GRAVITY * dt
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    local dx = self.x - constants.CENTER_X
    local dy = self.y - constants.CENTER_Y
    local dist = math.sqrt(dx * dx + dy * dy)
    local angle = math.atan2(dy, dx)
    if angle < 0 then angle = angle + 2 * math.pi end

    for _, ring in ipairs(rings) do
        local max_dist = ring.radius - self.radius

        if dist > max_dist and not utils.isInGap(angle, ring) then
            local nx, ny = dx / dist, dy / dist
            self.x = constants.CENTER_X + nx * max_dist
            self.y = constants.CENTER_Y + ny * max_dist

            local dot = self.vx * nx + self.vy * ny
            self.vx = self.vx - 2 * dot * nx
            self.vy = self.vy - 2 * dot * ny

            if constants.BOUNCE_RANDOMNESS > 0 then
                local angle_offset = (love.math.random() * 2 - 1) * constants.BOUNCE_RANDOMNESS * math.pi
                local cos_a, sin_a = math.cos(angle_offset), math.sin(angle_offset)

                local new_vx = self.vx * cos_a - self.vy * sin_a
                local new_vy = self.vx * sin_a + self.vy * cos_a
                self.vx, self.vy = new_vx, new_vy

                local energy_factor = 1 + (love.math.random() * constants.BOUNCE_RANDOMNESS * 0.1)
                self.vx = self.vx * energy_factor
                self.vy = self.vy * energy_factor
            end

            self.vx = self.vx * constants.BOUNCINESS
            self.vy = self.vy * constants.BOUNCINESS
	    particles:emit(self.x, self.y)
            return
        end
    end

    if #rings > 0 and dist > rings[#rings].radius then
        self.is_outside = true
    end
end

function Ball:draw()
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    if self.is_outside then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("The ball escaped through the rotating rings!", 10, 10)
    end
end

function Ball:drawParticles()
    particles:draw()
end

function Ball:updateParticles(dt)
    particles:update(dt)
end

return Ball
