-- Constants
local GRAVITY = 980
local BOUNCINESS = 0.999
local CENTER_X = 400
local CENTER_Y = 300
local BALL_RADIUS = 20


local N_RINGS = 50
local RING_SPACING = 8
local RING_THICKNESS = 10  
local RING_RADIUS_START = 40
local GAP_ARC = math.rad(45) -- 45° arc missing
local ROTATION_SPEED = math.rad(30) -- radians/sec

local BOUNCE_RANDOMNESS = 0.05 -- 0 = realistic, higher = more chaotic

-- Rings table
local rings = {}

-- Ball
local ball = {
    x = CENTER_X,
    y = CENTER_Y - RING_RADIUS_START + BALL_RADIUS,
    vx = 120,
    vy = 0,
    radius = BALL_RADIUS,
    is_outside = false
}

function love.load()
    for i = 1, N_RINGS do
        local radius = RING_RADIUS_START + (i - 1) * RING_SPACING
        -- Random offset for starting rotation
        local initial_rotation = i * 0.02 --love.math.random() * math.pi * 2
        -- Add wiggle (sine-based movement)
        table.insert(rings, {
            radius = radius,
            rotation = initial_rotation,
            wiggle_offset = love.math.random() * 2 * math.pi -- random sine phase
        })
    end
end

function isInGap(angle, ring)
    -- Compute current rotated gap range
    local start_angle = ring.rotation
    local end_angle = ring.rotation + GAP_ARC

    -- Normalize angle to [0, 2π]
    angle = (angle % (2 * math.pi))
    start_angle = (start_angle % (2 * math.pi))
    end_angle = (end_angle % (2 * math.pi))

    if start_angle < end_angle then
        return angle >= start_angle and angle <= end_angle
    else
        -- Wraparound case
        return angle >= start_angle or angle <= end_angle
    end
end

function destroyRing(ringIndex)
    -- Remove the ring at the specified index
    table.remove(rings, ringIndex)
end

function love.update(dt)
    -- Rotate all rings
    for i, ring in ipairs(rings) do
        -- Apply a sine wave offset to add wiggle to the rotation
        ring.rotation = ring.rotation + ROTATION_SPEED * dt + math.sin(love.timer.getTime() + ring.wiggle_offset) * 0.01

        -- Check if ball enters the gap of this ring
        local dx = ball.x - CENTER_X
        local dy = ball.y - CENTER_Y
        local dist = math.sqrt(dx * dx + dy * dy)
        local angle = math.atan2(dy, dx)
        if angle < 0 then angle = angle + 2 * math.pi end

        -- If the ball is inside the gap of the current ring, destroy it
        if dist >= (ring.radius - BALL_RADIUS) and dist <= ring.radius and isInGap(angle, ring) then
            destroyRing(i)
            break -- Exit loop since the ring is destroyed
        end
    end

    if ball.is_outside then
        -- Free fall
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
    if angle < 0 then angle = angle + 2 * math.pi end

    for i, ring in ipairs(rings) do
        local max_dist = ring.radius - ball.radius

        if dist > max_dist and not isInGap(angle, ring) then
            -- Bounce off this ring
            local nx = dx / dist
            local ny = dy / dist

            ball.x = CENTER_X + nx * max_dist
            ball.y = CENTER_Y + ny * max_dist

            local dot = ball.vx * nx + ball.vy * ny
-- Reflect velocity
ball.vx = ball.vx - 2 * dot * nx
ball.vy = ball.vy - 2 * dot * ny

-- Add randomness
if BOUNCE_RANDOMNESS > 0 then
    -- Random rotation (small angle in radians)
    local angle_offset = (love.math.random() * 2 - 1) * BOUNCE_RANDOMNESS * math.pi
    local cos_a = math.cos(angle_offset)
    local sin_a = math.sin(angle_offset)

    local new_vx = ball.vx * cos_a - ball.vy * sin_a
    local new_vy = ball.vx * sin_a + ball.vy * cos_a
    ball.vx, ball.vy = new_vx, new_vy

    -- Random energy gain/loss (scale from 1 to 1 + BOUNCE_RANDOMNESS)
    local energy_factor = 1 + (love.math.random() * BOUNCE_RANDOMNESS)
    ball.vx = ball.vx * energy_factor
    ball.vy = ball.vy * energy_factor
end

-- Apply bounciness
ball.vx = ball.vx * BOUNCINESS
ball.vy = ball.vy * BOUNCINESS
            return
        end
    end

    -- If it passed through all rings without hitting any, it's outside
    local outer_radius = rings[#rings].radius
    if dist > outer_radius then
        ball.is_outside = true
    end
end

function love.draw()
    -- Draw remaining rotating rings with gaps
    love.graphics.setColor(0.3, 0.3, 0.3)
    local segments = 60
    for _, ring in ipairs(rings) do
        local angle_step = 2 * math.pi / segments
        for i = 0, segments - 1 do
            local a1 = i * angle_step
            local a2 = (i + 1) * angle_step

            local rotated_a1 = a1
            local rotated_a2 = a2

            if not (isInGap(rotated_a1, ring) and isInGap(rotated_a2, ring)) then
                local x1 = CENTER_X + math.cos(rotated_a1 + ring.rotation) * ring.radius
                local y1 = CENTER_Y + math.sin(rotated_a1 + ring.rotation) * ring.radius
                local x2 = CENTER_X + math.cos(rotated_a2 + ring.rotation) * ring.radius
                local y2 = CENTER_Y + math.sin(rotated_a2 + ring.rotation) * ring.radius
                love.graphics.line(x1, y1, x2, y2)
            end
        end
    end

    -- Draw ball
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)

    if ball.is_outside then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("The ball escaped through the rotating rings!", 10, 10)
    end
end

