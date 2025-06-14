Player = {}
Player.__index = Player

local player_sheet = love.graphics.newImage(PNG_PATH .. "bird-sheet.png")


Signal.register('test123', function()
  logger.info("player picked up Signal")
end)



-- https://github.com/andriadze/Love2D_Platformer_Example/blob/master/player.lua


function Player.new()
  local p        = setmetatable({}, Player)
  --p.hitbox       = Hitbox(p, 0, 0, 4, 6, 2, 1)
  --p.cubeFilter      = true
  p.name         = "player"
  p.x            = nil
  p.y            = nil
  p.w            = 8
  p.h            = 8
  p.dx           = 0
  p.dy           = 1
  p.speed        = 60
  p.score        = 0
  p.jumps        = 1
  p.x_move_speed = 100
  p.health       = nil
  p.is_on_ground = true
  p.flutter      = 100

  p.sprites      = {
    love.graphics.newQuad(0, 0, 10, 10, player_sheet),
    love.graphics.newQuad(8, 0, 8, 8, player_sheet),
  }

  p:reset()

  world:add(p, p.x, p.y, p.w, p.h)

  return p
end

function Player:add_score(val)
  hud.new_score = self.score + val
end

function Player:jump(kind)
  --self.dy = self.dy - 10
  if kind == "jump" then
    --if self.is_on_ground then
    --self.is_on_ground = false
    self.jumps = math.clamp(0, self.jumps - 1, 3)
    self.dy = self.dy - 11 --math.clamp(0, self.dy - 1, -30)
    --end
  elseif kind == "cube" then
    shake_duration = 0.05
    self.is_on_ground = false
    self.dy = self.dy - 9 --math.clamp(0, self.dy - 1, -30)
  end
end

function Player:draw()
  if is_on_screen(self) then
    love.graphics.draw(player_sheet, self.sprites[1], self.x + 4, self.y, 0, self.facing_dir, 1, 4, 1)
  end
end

function Player:update(dt)
  self.dx = 0

  if input:down 'left' then
    self.dx = -self.x_move_speed * dt
  end
  if input:down 'right' then
    self.dx = self.x_move_speed * dt
  end
  if input:pressed 'jump' then
    if self.jumps > 0 then
      self:jump("jump")
    end
  end

  self.dy = math.clamp(-10, self.dy + 1, 2)

  if self.dx ~= 0 or self.dy ~= 0 then
    local cols
    self.x, self.y, cols, cols_len = world:move(self, self.x + self.dx, self.y + self.dy, player_filter)
    for i = 1, cols_len do
      local col = cols[i]
      if col.other.name == "ground" then
        self.is_on_ground = true
        self.jumps = 1
        --print(col.normal.x, col.normal.y)
      elseif col.other.name == "cube" and col.normal.x == 0 and col.normal.y == -1 then -- self:jump()
        self.is_on_ground = true
        self:jump("cube")
        col.other:on_player_bop()
        Signal.emit('test123')
      end
      --consolePrint(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(col.other, col.type, col.normal.x,
      -- col.normal.y))
      --print(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(col.other.name, col.type, col.normal.x, col.normal.y))
    end
  end
end

function Player:reset()
  self.x = 60
  self.y = 60
  self.flutter = 3
  self.facing_dir = 1
end

local function player_filter(item, other)
  if other.name == "ground" then
    return 'slide'
  elseif other.name == "cube" then
    return 'slide'
  elseif other.name == "wall" then
    return 'slide'
  end
end
