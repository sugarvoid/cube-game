
Letter = Object:extend("letter")

all_letters = {}

local spr_w = love.graphics.newImage(PNG_PATH .. "letter_w.png")
local center_x = spr_w:getWidth() / 2
local center_y = spr_w:getHeight() / 2

function Letter:new(x, y, dir)
    self.spr = spr_w
    self.rot = 0
    self.x = x
    self.y = y
    self.start_x = x
    self.score_mul = 0
    self.hitbox = Hitbox(self, self.x, self.y, 5, 5)

    self.h = 6
    self.w = 6
    self.dir = dir
    self.frame_time = 0.2
    self.facing_dir = 1
    self.speed = 1
    self.accel = 0.05
    self.moving_dir = 2 * dir
end

function Letter:draw()
    love.graphics.draw(self.spr, self.x + 3, self.y + 3, math.rad(self.rot), 1, 1, center_x, center_y)
end

function Letter:explode()
    explode(self.x, self.y, 4, 3, PALETTE.WHITE)
end

function Letter:update(dt)
    self.score_mul = self.score_mul + 0.2
    self.speed = math.clamp(-2, self.speed + self.accel, 2)
    self.x = self.x + self.speed * self.moving_dir

    if self.x <= 11 or self.x >= 120 then
        self:explode()
        if #twisters < 12 then
            spawn_twister(self.x, self.y)
        end

        table.remove_item(all_letters, self)
    end

    self.rot = self.rot + (10 * self.moving_dir)
    self.hitbox:update()
end

function Letter:reset()
    self.y = 0
    self.ey = self.y + 3
    self.x = math.random(1, 127)
end