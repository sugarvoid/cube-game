Trigger = Object:extend()

function Trigger:new(callback, seconds, is_repeat)
    self.callback = nil
    self.sec = nil
    self.is_repeat = nil
end

-----------------------

Clock = Object:extend()

function Clock:new()
    self.seconds = 0
    self.t = 0
    self.is_running = false
    self.triggers = nil
end

function Clock:add_trigger(callback, seconds, is_repeat)
    local _trig = Trigger(callback, seconds, is_repeat)
    if self.triggers == nil then
        self.triggers = {}
    end
    table.insert(self.triggers, _trig)
end

function Clock:tick()
    self.seconds = self.seconds + 1
    self.t = 0
end

function Clock:update()
    if self.is_running then
        self.t = self.t + 1
        if self.t >= 60 then
            self:tick()
        end
    end
end

function Clock:stop()
    self.is_running = false
end

function Clock:start()
    self.is_running = true
end

function Clock:restart()
    self.t = 0
    self.seconds = 0
end
