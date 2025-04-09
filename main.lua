local Ball = require("ball")
local Ring = require("ring")
local constants = require("constants")

local rings = {}
local ball

function love.load()
    love.graphics.setLineWidth(constants.RING_THICKNESS)

    ball = Ball(constants.CENTER_X, constants.CENTER_Y - constants.RING_RADIUS_START + constants.BALL_RADIUS)

    for i = 1, constants.N_RINGS do
        table.insert(rings, Ring(i))
    end
end

function love.update(dt)
    for i = #rings, 1, -1 do
        rings[i]:update(dt, ball)
        if rings[i].is_destroyed then
            table.remove(rings, i)
        end
    end

    ball:update(dt, rings)
    ball:updateParticles(dt)
end

function love.draw()
    for _, ring in ipairs(rings) do
        ring:draw()
    end
    ball:drawParticles()
    ball:draw()
end
