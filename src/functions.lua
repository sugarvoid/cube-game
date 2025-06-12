function get_rand_screen_x()
    -- For spawning rocks and mailboxes
    return math.random(18, 110)
end

function get_next_time(min_sec, max_sec)
    local _min = min_sec * 60
    local _max = max_sec * 60
    return math.random(_min, _max)
end

function set_color_from_hex(rgba)
    --setColorHEX(rgba)
    --where rgba is string as "#336699cc"
    local _rb = tonumber(string.sub(rgba, 2, 3), 16)
    local _gb = tonumber(string.sub(rgba, 4, 5), 16)
    local _bb = tonumber(string.sub(rgba, 6, 7), 16)
    local _ab = tonumber(string.sub(rgba, 8, 9), 16) or nil
    --print (rb, gb, bb, ab) -- prints 51102153204
    --print (love.math.colorFromBytes( rb, gb, bb, ab )) -- prints0.20.40.60.8
    love.graphics.setColor(love.math.colorFromBytes(_rb, _gb, _bb, _ab))
end

function set_bgcolor_from_hex(rgba)
    --setColorHEX(rgba)
    --where rgba is string as "#336699cc"
    local _rb = tonumber(string.sub(rgba, 2, 3), 16)
    local _gb = tonumber(string.sub(rgba, 4, 5), 16)
    local _bb = tonumber(string.sub(rgba, 6, 7), 16)
    local _ab = tonumber(string.sub(rgba, 8, 9), 16) or nil
    --print (rb, gb, bb, ab) -- prints 51102153204
    --print (love.math.colorFromBytes( rb, gb, bb, ab )) -- prints0.20.40.60.8
    love.graphics.setBackgroundColor(love.math.colorFromBytes(_rb, _gb, _bb, _ab))
end

function draw_hitbox(obj)
    love.graphics.push("all")
    set_color_from_hex("#ff0000")
    love.graphics.rectangle("line", obj.x, obj.y, obj.w, obj.h)
    love.graphics.pop()
end

function angle_lerp(angle1, angle2, t)
    angle1 = angle1 % 1
    angle2 = angle2 % 1

    if math.abs(angle1 - angle2) > 0.5 then
        if angle1 > angle2 then
            angle2 = angle2 + 1
        else
            angle1 = angle1 + 1
        end
    end

    return ((1 - t) * angle1 + t * angle2) % 1
end

function get_angle(x1, y1, x2, y2)
    return math.atan2(x2 - x1, y2 - y1)
end

function get_distance(obj_a, obj_b)
    local _dx = obj_a.x - obj_b.x
    local _dy = obj_a.y - obj_b.y
    return math.sqrt(_dx * _dx + _dy * _dy)
end

function math.clamp(low, n, high)
    return math.min(math.max(n, low), high)
end

function rnd(a)
    a = a or 1
    return math.random() * a
end

---comment
---@param t table
---@return any
function get_random_item(t)
    a = a or 1
    return t[math.random(#t)]
end

---Play a sound, even if one is playing
---@param s love.audio.Source
function play_sound(s)
    local _s = s:clone()
    _s:play()
end

function print_mem()
    print('Memory actually used (in kB): ' .. collectgarbage('count') / 1024)
end
