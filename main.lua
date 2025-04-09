-- Constants
local GRAVITY = 980
local BOUNCINESS = 0.9
local CENTER_X = 400
local CENTER_Y = 300
local RING_RADIUS = 200
local BALL_RADIUS = 20

-- Open arc (in radians)
local OPEN_ANGLE_START = math.rad(240)
local OPEN_ANGLE_END = math.rad(300)

-- Ball properties
local ball = {
    x = CENTER_X,
    y = CENTER_Y - RING_RADIUS + BALL_RADIUS,
    vx = 120,
    vy = 0,
    radius = BALL_RADIUS,
    is_outside = false
}

function love.update(dt)
    if ball.is_outside then
        -- Free fall once outside
        ball.vy = ball.vy + GRAVITY * dt
        ball.x = ball.x + ball.vx * dt
        ball.y = ball.y + ball.vy * dt
        return
    end

    -- Apply gravity
    ball.vy = ball.vy + GRAVITY * dt

    -- Move ball
    ball.x = ball.x + ball.vx * dt
    ball.y = ball.y + ball.vy * dt

    -- Vector from center
    local dx = ball.x - CENTER_X
    local dy = ball.y - CENTER_Y
    local dist = math.sqrt(dx * dx + dy * dy)
    local angle = math.atan2(dy, dx)

    -- Normalize angle to [0, 2π]
    if angle < 0 then angle = angle + 2 * math.pi end

    local max_dist = RING_RADIUS - ball.radius

    -- Only reflect if angle is NOT within open arc
    local is_in_open_arc = angle >= OPEN_ANGLE_START and angle <= OPEN_ANGLE_END

    if dist > max_dist and not is_in_open_arc then
        -- Collision normal
        local nx = dx / dist
        local ny = dy / dist

        -- Push ball back to edge
        ball.x = CENTER_X + nx * max_dist
        ball.y = CENTER_Y + ny * max_dist

        -- Reflect velocity
        local dot = ball.vx * nx + ball.vy * ny
        ball.vx = ball.vx - 2 * dot * nx
        ball.vy = ball.vy - 2 * dot * ny

        -- Apply bounciness
        ball.vx = ball.vx * BOUNCINESS
        ball.vy = ball.vy * BOUNCINESS
    elseif dist > RING_RADIUS then
        ball.is_outside = true -- Ball has escaped!
    end
end

function love.draw()
    -- Draw partial ring
    love.graphics.setColor(0.3, 0.3, 0.3)
    local segments = 100
    local angle_step = 2 * math.pi / segments
    for i = 0, segments - 1 do
        local a1 = i * angle_step
        local a2 = (i + 1) * angle_step

        -- Only draw if outside open arc
        if not (a1 >= OPEN_ANGLE_START and a2 <= OPEN_ANGLE_END) then
            local x1 = CENTER_X + math.cos(a1) * RING_RADIUS
            local y1 = CENTER_Y + math.sin(a1) * RING_RADIUS
            local x2 = CENTER_X + math.cos(a2) * RING_RADIUS
            local y2 = CENTER_Y + math.sin(a2) * RING_RADIUS
            love.graphics.line(x1, y1, x2, y2)
        end
    end

    -- Draw ball
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)

    -- If ball escaped, show a message
    if ball.is_outside then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("The ball escaped!", 10, 10)
    end
end
