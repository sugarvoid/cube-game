Player = {}
Player.__index = Player

local player_sheet = love.graphics.newImage(PNG_PATH .. "bird-sheet.png")

local sfx_hurt = love.audio.newSource(SFX_PATH .. "player_hurt.wav", "static")
local death_timer = 0

Signal.register('test123', function()
  logger.info("player picked up Signal")
end)

-- TODO: on player reset, chute sprites are not resetting
function Player.new()
  local p = setmetatable({}, Player)
  p.hitbox = Hitbox(p, 0, 0, 4, 6, 2, 1)
  p.x = nil
  p.y = nil
  p.w = 7
  p.h = 8
  p.health = nil
  p.speed = 60
  p.score = 0
  p.x_move_speed = 1
  p.acceleration = 10
  p.health = nil
  p.is_alive = nil
  p.clothing = nil
  p.is_in_tree_zone = false

  p.sprites = {
    love.graphics.newQuad(0, 0, 10, 10, player_sheet),
    love.graphics.newQuad(8, 0, 8, 8, player_sheet),
  }

  p:reset()

  return p
end

function Player:get_cash()
  return string.format("%.2f", self._cash)
end

function Player:add_score(val)
  hud.new_score = self.score + val
end

function Player:draw()
  if is_on_screen(self) then
    love.graphics.draw(player_sheet, self.sprites[1],   self.x + 4, self.y + 1, 0, self.facing_dir, 1, 4, 1)
  end
end

function Player:update(dt)
  if self.is_alive then
   
      self.x_move_speed = 1
      self.speed = 60
  

    if self.is_chute_open then
      self.speed = math.clamp(-70, self.speed + self.acceleration, 70)
      self.y = self.y - (self.speed * dt)
    else
      self.speed = math.clamp(-80, self.speed + self.acceleration, 80)
      self.y = self.y + (self.speed * dt)
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
      self.x = math.clamp(4, self.x - self.x_move_speed, 116)
      self.facing_dir = -1
    elseif x_dir == "right" then
      self.x = math.clamp(4, self.x + self.x_move_speed, 116)
      self.facing_dir = 1
    end
  
end



function Player:reset()
  self.x = 60
  self.y = 60
  self.flutter = 3
  self.facing_dir = 1
end
