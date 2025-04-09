-- Constants
local GRAVITY = 980      -- pixels/s² (realistic gravity)
local BOUNCINESS = 0.8   -- 80% energy retained on bounce
local FLOOR_Y = 500      -- Y position of the floor

-- Ball properties
local ball = {
    x = 400,
    y = 100,
    radius = 20,
    vy = 0
}

function love.update(dt)
    -- Apply gravity
    ball.vy = ball.vy + GRAVITY * dt
    ball.y = ball.y + ball.vy * dt

    -- Collision with floor
    if ball.y + ball.radius > FLOOR_Y then
        ball.y = FLOOR_Y - ball.radius
        ball.vy = -ball.vy * BOUNCINESS

        -- Clamp small velocities to zero to stop infinite small bounces
        if math.abs(ball.vy) < 10 then
            ball.vy = 0
        end
    end
end

function love.draw()
    -- Draw the floor
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 0, FLOOR_Y, love.graphics.getWidth(), love.graphics.getHeight() - FLOOR_Y)

    -- Draw the ball
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
end
