Player = {}
Player.__index = Player

local player_sheet = love.graphics.newImage(PNG_PATH .. "bird-sheet.png")
local death_timer = 0

Signal.register('test123', function()
  logger.info("player picked up Signal")
end)


-- https://github.com/andriadze/Love2D_Platformer_Example/blob/master/player.lua



-- TODO: on player reset, chute sprites are not resetting
function Player.new()
  local p           = setmetatable({}, Player)
  p.hitbox          = Hitbox(p, 0, 0, 4, 6, 2, 1)
  p.cubeFilter      = true
  p.name            = "player"
  p.x               = nil
  p.y               = nil
  p.w               = 8
  p.h               = 8
  p.dx              = 0
  p.dy              = 1
  p.health          = nil
  p.speed           = 60
  p.score           = 0
  p.jumps           = 1
  p.x_move_speed    = 1
  p.acceleration    = 10
  p.health          = nil
  p.is_alive        = nil
  p.clothing        = nil
  p.is_in_tree_zone = false
  p.is_on_ground    = true

  p.sprites         = {
    love.graphics.newQuad(0, 0, 10, 10, player_sheet),
    love.graphics.newQuad(8, 0, 8, 8, player_sheet),
  }

  p:reset()

  world:add(p, p.x, p.y, p.w, p.h)

  return p
end

function Player:get_cash()
  return string.format("%.2f", self._cash)
end

function Player:add_score(val)
  hud.new_score = self.score + val
end

function Player:jump(kind)
  --self.dy = self.dy - 10
  if kind == "jump" then
    if self.is_on_ground then
      self.is_on_ground = false
      self.dy = self.dy - 11 --math.clamp(0, self.dy - 1, -30)
    end
  elseif kind == "cube" then
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
  local speed = self.x_move_speed
  speed = 100

  self.dx = 0
  --self.dy = 0

  if input:down 'left' then
    self.dx = -speed * dt
  end
  if input:down 'right' then
    self.dx = speed * dt
  end
  if input:pressed 'jump' then
    self:jump("jump")
  end
  if love.keyboard.isDown('right') then

  elseif love.keyboard.isDown('left') then

  end
  if love.keyboard.isDown('down') then
    self.dy = speed * dt
  elseif love.keyboard.isDown('up') then

  end

  --print(self.dy)

  --if self.dy ~= 0 then
  --if not self.is_on_ground then
  --self.dy = self.dy + 1
  self.dy = math.clamp(-10, self.dy + 1, 2)
  --end

  --else

  --end

  if self.dx ~= 0 or self.dy ~= 0 then
    local cols
    self.x, self.y, cols, cols_len = world:move(self, self.x + self.dx, self.y + self.dy, playerFilter)
    for i = 1, cols_len do
      local col = cols[i]
      if col.other.name == "ground" then
        self.is_on_ground = true
        --print(col.normal.x, col.normal.y)
      elseif col.other.name == "cube" and col.normal.x == 0 and col.normal.y == -1 then -- self:jump()
        self.is_on_ground = true
        self:jump("cube")
        print("player on cube")
      end
      --consolePrint(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(col.other, col.type, col.normal.x,
      -- col.normal.y))
      --print(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(col.other.name, col.type, col.normal.x, col.normal.y))
    end
  end



  if self.is_alive then
    for m in table.for_each(cubes) do
      if is_colliding(m, self.hitbox) then
        m:take_damage()
        shake_duration = 0.3
      end
    end
  end


  if self.y == 150 then
    death_timer = death_timer + 1
    if death_timer >= 60 then
      goto_gameover("fell")
    end
  end

  self.hitbox:update()
end

function Player:throw_letter()
  if self.is_alive then
    self.throw_anim = 10
    if self.letters > 0 and not show_results then
      local _new_letter = Letter(self.x, self.y - 2, self.facing_dir)
      table.insert(all_letters, _new_letter)
      self.letters = self.letters - 1
    else
      --TODO: Spawn something other than letter?
    end
  end
end

function Player:move(x_dir)
  if x_dir == "left" then
    --self.x = math.clamp(4, self.x - self.x_move_speed, 116)
    self.facing_dir = -1
  elseif x_dir == "right" then
    --self.x = math.clamp(4, self.x + self.x_move_speed, 116)
    self.facing_dir = 1
  end
end

function Player:reset()
  self.x = 60
  self.y = 60
  self.flutter = 3
  self.facing_dir = 1
end

playerFilter = function(item, other)
  --if other.isCoin then
  --return 'cross'
  if other.name == "ground" then
    return 'slide'
  elseif other.name == "cube" then
    return 'slide'
  elseif other.isSpring then
    return 'bounce'
  end
  -- else return nil
end
