cubes = {}

Cube = Object:extend()

local cube_sheet = love.graphics.newImage(PNG_PATH .. "cube-sheet.png")


local cube_imgs = {
    love.graphics.newQuad(0, 0, 8, 8, cube_sheet),
}

function Cube:new()
    self.is_cube = true
    self.name = "cube"
    self.x = 30
    self.y = 20
    self.w = 8
    self.h = 8
    self.dy = 0
    self.dx = 0
    self.is_on_ground = false
    self.img = cube_imgs[1]
    self.speed = 20 --  speeds[math.random(#speeds)]
    world:add(self, self.x, self.y, self.w, self.h)
    table.insert(cubes, self)
end

function Cube:update()
    self.dy = math.clamp(-10, self.dy + 1, 2)
    if self.dx ~= 0 or self.dy ~= 0 then
        local cols
        self.x, self.y, cols, cols_len = world:move(self, self.x + self.dx, self.y + self.dy, cubeFilter)
        for i = 1, cols_len do
            local col = cols[i]
            if col.other.name == "ground" then
                self.is_on_ground = true
                --print(col.normal.x, col.normal.y)
                --self:bounce(15)
                --elseif col.name == "cube" and col.normal.x == 0 and col.normal.y == -1 then -- self:jump()
                --  self:jump()
            end
            --consolePrint(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(col.other, col.type, col.normal.x,
            -- col.normal.y))
            --print(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(col.other.name, col.type, col.normal.x, col.normal.y))
        end
    end
end

function Cube:draw()
    love.graphics.draw(cube_sheet, self.img, self.x, self.y)
end

function Cube:bounce(amount)
    if self.is_on_ground then
        self.is_on_ground = false
        self.dy = self.dy - amount --math.clamp(0, self.dy - 1, -30)
    end
end

local cubeFilter = function(item, other)
    --if other.isCoin then
    --    return 'cross'
    if other.is_player then
        return 'slide'
    elseif other.isExit then
        return 'touch'
    elseif other.is_cube then
        return 'bounce'
    end
    -- else return nil
end
