-- Table to hold all particles
all_particles = {}

-- Function to update particle properties (physics and movement)
function update_particles()
    for p in table.for_each(all_particles) do
        p.timer = p.timer + 1
        if p.timer > p.life then
            table.remove(all_particles, i) -- Remove the particle if its life has expired
        end

        -- Physics: Apply gravity and size change
        if p.grav then
            p.dy = p.dy + 0.5 -- Gravity acceleration
        end
        if p.grow then
            p.r = p.r + 0.1 -- Grow particle radius
        end
        if p.shrink then
            p.r = p.r - 0.1 -- Shrink particle radius
        end

        -- Move the particle
        p.x = p.x + p.dx
        p.y = p.y + p.dy
    end
end


function draw_particles()
    love.graphics.push("all")

    for p in table.for_each(all_particles) do
        love.graphics.setPointSize(p.r * 4)
        set_color_from_hex(p.c)
        love.graphics.points(p.x, p.y)
    end
    love.graphics.pop()
end

function explode(x, y, r, num, c)
    for i = 1, num do
        local p = {
            x = x,
            y = y,
            timer = 0,
            life = 10 + math.random(20), -- Particle life
            dx = math.random() * 2 - 1,  -- Random X velocity
            dy = math.random() * 2 - 1,  -- Random Y velocity
            grav = false,                -- No gravity for explosion particles
            shrink = true,               -- Shrink over time
            grow = false,                -- Do not grow over time
            r = r,                       -- Initial radius
            c = c,                       -- Color
        }
        table.insert(all_particles, p)
    end
end