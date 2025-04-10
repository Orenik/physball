local Ball = require("ball")
local Ring = require("ring")
local constants = require("constants")
local ParticleManager = require("particles")
local particles = ParticleManager()

local rings = {}
local ball

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600


function love.load()
    love.window.setMode(800, 600, {resizable=true, vsync=0, minwidth=400, minheight=300})
    love.graphics.setLineWidth(constants.RING_THICKNESS)

    ball = Ball(constants.CENTER_X, constants.CENTER_Y - constants.RING_RADIUS_START + constants.BALL_RADIUS)

    for i = 1, constants.N_RINGS do
        table.insert(rings, Ring(i, particles))
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
    particles:update(dt)
end

function love.draw()
    for _, ring in ipairs(rings) do
        ring:draw()
    end
    ball:drawParticles()
    particles:draw()
    ball:draw()
end

function love.resize( w, h )
    WINDOW_WIDTH = w
    WINDOW_HEIGHT = h
end
