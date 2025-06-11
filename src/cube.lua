cubes = {}

Cube = Object:extend()

local cube_sheet = love.graphics.newImage(PNG_PATH .. "cube-sheet.png")


local cube_imgs = {
    love.graphics.newQuad(0, 0, 8, 8, cube_sheet),
}

function Cube:new()
    self.name = "cube"
    self.y = -60
    self.w = 8
    self.h = 8
    self.dy = 0
    self.dx = 0
    self.img = cube_imgs[1]
    self.speed = 20 --  speeds[math.random(#speeds)]
    world:add(self, self.x, self.y, self.w, self.h)
end

function Cube:update()
    self.y = self.y + self.speed
    self.danger_time = self.danger_time - 2
    if self.y >= 130 then
        update_lane(self.lane, false)
        table.remove_item(cubes, self)
    end

    if is_colliding(self, player.hitbox) then
        logger.info("rock hit player")
        player:take_damage()
        update_lane(self.lane, false)
        table.remove_item(rocks, self)
    end
end

function Cube:draw()
    love.graphics.draw(cube_sheet, self.img, self.x, self.y)
    if is_debug_on then
        draw_hitbox(self)
    end
end

function reset_rock_timer()
    next_rock = 140 + math.random(20)
end

local cubeFilter = function(item, other)
    if other.isCoin then
        return 'cross'
    elseif other.isWall then
        return 'slide'
    elseif other.isExit then
        return 'touch'
    elseif other.isSpring then
        return 'bounce'
    end
    -- else return nil
end
