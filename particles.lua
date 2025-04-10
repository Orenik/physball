local ParticleManager = {}
ParticleManager.__index = ParticleManager

function ParticleManager:new()
    return setmetatable({
        emitters = {}
    }, ParticleManager)
end

setmetatable(ParticleManager, { __call = ParticleManager.new })

function ParticleManager:update(dt)
    for i = #self.emitters, 1, -1 do
        local emitter = self.emitters[i]
        emitter.ps:update(dt)
        if emitter.ps:isStopped() and emitter.ps:getCount() == 0 then
            table.remove(self.emitters, i)
        end
    end
end

function ParticleManager:draw()
    for _, emitter in ipairs(self.emitters) do
        love.graphics.draw(emitter.ps, emitter.x, emitter.y)
    end
end

function ParticleManager:emit(x, y)
    if not ParticleManager.particleImage then
    local imageData = love.image.newImageData(8, 8)
    local cx, cy = 4, 4
    for y = 0, 7 do
        for x = 0, 7 do
            local dx, dy = x - cx, y - cy
            local dist = math.sqrt(dx * dx + dy * dy)
            local alpha = dist <= 3 and 1 or 0
            imageData:setPixel(x, y, 1, 1, 1, alpha)
        end
    end
    ParticleManager.particleImage = love.graphics.newImage(imageData)
    end

    local ps = love.graphics.newParticleSystem(ParticleManager.particleImage, 50)
    ps:setParticleLifetime(0.2, 0.5)
    ps:setSpeed(50, 150)
    ps:setLinearAcceleration(-50, -50, 50, 50)
    ps:setSizes(0.5, 0.1)
    ps:setSpread(math.pi * 2)
    
    ps:setColors(
    1, 0, 0, 1,   -- red
    1, 0.5, 0, 1, -- orange
    1, 1, 0, 1,   -- yellow
    0, 1, 0, 1,   -- green
    0, 1, 1, 1,   -- cyan
    0, 0, 1, 1,   -- blue
    0.6, 0, 1, 1, -- violet
    1, 1, 1, 0    -- fade to transparent white
    )

    ps:emit(30)

    table.insert(self.emitters, {
        x = x,
        y = y,
        ps = ps
    })
end

return ParticleManager
