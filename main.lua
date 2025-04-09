-- Constants
local GRAVITY = 980          -- pixels/s²
local BOUNCINESS = 0.9       -- 90% energy retained
local CENTER_X = 400         -- Center of the ring
local CENTER_Y = 300
local RING_RADIUS = 200      -- Radius of the ring
local BALL_RADIUS = 20

-- Ball properties
local ball = {
    x = CENTER_X,
    y = CENTER_Y - RING_RADIUS + BALL_RADIUS,
    vx = 100,
    vy = 0,
    radius = BALL_RADIUS
}

function love.update(dt)
    -- Apply gravity
    ball.vy = ball.vy + GRAVITY * dt

    -- Move the ball
    ball.x = ball.x + ball.vx * dt
    ball.y = ball.y + ball.vy * dt

    -- Vector from center to ball
    local dx = ball.x - CENTER_X
    local dy = ball.y - CENTER_Y
    local dist = math.sqrt(dx * dx + dy * dy)

    -- Collision with ring wall
    local max_dist = RING_RADIUS - ball.radius
    if dist > max_dist then
        -- Normalize direction vector
        local nx = dx / dist
        local ny = dy / dist

        -- Push ball back to the edge
        ball.x = CENTER_X + nx * max_dist
        ball.y = CENTER_Y + ny * max_dist

        -- Reflect velocity over the normal
        local dot = ball.vx * nx + ball.vy * ny
        ball.vx = ball.vx - 2 * dot * nx
        ball.vy = ball.vy - 2 * dot * ny

        -- Apply bounciness
        ball.vx = ball.vx * BOUNCINESS
        ball.vy = ball.vy * BOUNCINESS
    end
end

function love.draw()
    -- Draw the ring
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.circle("line", CENTER_X, CENTER_Y, RING_RADIUS)

    -- Draw the ball
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
end
