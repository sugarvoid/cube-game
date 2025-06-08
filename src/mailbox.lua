MailBox = Object:extend()

local good_sfx = love.audio.newSource(SFX_PATH .. "good_mail.wav", "static")
local was_hit = love.audio.newSource(SFX_PATH .. "mailbox_hit.wav", "static")
local MB_SHEET = love.graphics.newImage(PNG_PATH .. "mailboxes.png")
local ground_img = love.graphics.newImage(PNG_PATH .. "ground.png")
local m_types = { "customer", "non_customer" }

local RED_FRAMES = {
	love.graphics.newQuad(0, 0, 8, 8, MB_SHEET),
	love.graphics.newQuad(8, 0, 8, 8, MB_SHEET),
	love.graphics.newQuad(16, 0, 8, 8, MB_SHEET),
}

local BLUE_FRAMES = {
	love.graphics.newQuad(24, 0, 8, 8, MB_SHEET),
	love.graphics.newQuad(32, 0, 8, 8, MB_SHEET),
	love.graphics.newQuad(40, 0, 8, 8, MB_SHEET),
}

local GRAY_FRAMES = {
	love.graphics.newQuad(48, 0, 8, 8, MB_SHEET),
	love.graphics.newQuad(56, 0, 8, 8, MB_SHEET),
	love.graphics.newQuad(64, 0, 8, 8, MB_SHEET),
}


function MailBox:new(lane, id)
	self.resident_id = id
	self.is_empty = true
	self.is_collidable = true
	self.y = 130
	self.w = 8
	self.h = 10
	self.has_letter = false
	self.speed = lume.randomchoice({ 0.6, 0.7, 0.8 })
	self.is_customer = residents[self.resident_id]
	self.frame = 2

	if self.is_customer then
		self.frames = batteries.tablex.copy(BLUE_FRAMES)
	else
		self.frames = batteries.tablex.copy(RED_FRAMES)
	end

	self.sprite = self.frames[self.frame]
	self.lane = lane
	self.x = lanes[lane][1]
	if self.x < 128 / 2 then
		self.facing_dir = 1
	else
		self.facing_dir = -1
	end
	update_lane(lane, true)
end

function MailBox:draw()
	love.graphics.draw(MB_SHEET, self.sprite, self.x + 4, self.y + 1, 0, self.facing_dir, 1, 4, 1)
	love.graphics.draw(ground_img, self.x + 4, self.y + 9, 0, 1, 1, 4, 1)
	if is_debug_on then
		draw_hitbox(self)
	end
end

function mb_explode(mb, col)
	explode(mb.x, mb.y, 3, 5, col)
end

function MailBox:update(dt)
	for l in table.for_each(all_letters) do
		if is_colliding(l, self) and not self.has_letter then
			table.remove_item(all_letters, l)
			if self.x < l.x then
				if self.facing_dir == 1 then
					self:on_letter(l.score_mul)
				else
					l:explode()
				end
			else
				if self.facing_dir == -1 then
					self:on_letter(l.score_mul)
				else
					l:explode()
				end
			end
		end
	end

	self.y = self.y - self.speed

	if self.y <= -30 then
		if not self.has_letter and self.is_customer then
			self:unsubscribe("no letter")
		end
		update_lane(self.lane, false)
		table.remove_item(mailboxes, self)
	end

	if self.y >= 130 then
		update_lane(self.lane, false)
		table.remove_item(mailboxes, self)
	end
end

function MailBox:on_letter(score)
	player.deliveries = player.deliveries + 1
	if self.is_customer then
		player:add_score(math.floor(score) * 10)
	end
	--self.is_empty = false
	self.has_letter = true
	local _clone = good_sfx:clone()
	_clone:play()
	self.frame = self.frame - 1
	self.sprite = self.frames[self.frame]
	self.speed = 2
end

function MailBox:unsubscribe(reason)
	-- Change mailbox to a non-customer (red one)
	residents[self.resident_id] = false
	logger.info("resident #" .. tostring(self.resident_id) .. " has unsubscribed. " .. reason)
end

function resubscribe()
    -- Change mailbox to a non-customer (red one)
    for i, value in ipairs(residents) do
        if value == false then
            got_new_customer = true
            residents[i] = true -- Change the false to true
            --customer_count += 1
            break               -- Stop after changing the first false
        end
    end
end

function MailBox:reset()
	self.y = 0
	self.ey = self.y + 3
	self.x = math.random(1, 127)
end

function MailBox:take_damage()
	if not self.has_letter and self.is_collidable then
		self.is_collidable = false
		print(self.frame)
		--self.is_empty = false
		self.frame = self.frame + 1
		self.sprite = self.frames[self.frame]
		self.speed = (self.speed + 0.5) * -1
		play_sound(was_hit)
		if self.is_customer then
			self:unsubscribe("crashed")
		end
	end
end

function update_mailboxes(dt)
	for m in table.for_each(mailboxes) do
		m:update(dt)
	end
end

function draw_mailboxes()
	for m in table.for_each(mailboxes) do
		m:draw()
	end
end
