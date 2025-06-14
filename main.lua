is_debug_on = false

love = require("love")
Object = require "lib.classic"
logger = require("lib.log")
baton = require("lib.baton")
lume = require("lib.lume")
flux = require("lib.flux")
anim8 = require("lib.anim8")
bump = require("lib.bump")
bump_debug = require("lib.bump_debug")

--local cols_len = 0 -- how many collisions are happening
-- local consoleBuffer = {}
-- local consoleBufferSize = 15
-- for i = 1, consoleBufferSize do consoleBuffer[i] = "" end
-- function consolePrint(msg)
--     table.remove(consoleBuffer, 1)
--     consoleBuffer[consoleBufferSize] = msg
-- end

Signal = require("lib.signal")

if is_debug_on then
    love.profiler = require('lib.profile')
end

love.graphics.setDefaultFilter("nearest", "nearest")

PNG_PATH = "asset/image/"
SFX_PATH = "asset/sound/"

local GAME_STATES = {
    game = 6,
    pause = 9
}
local game_state = nil
local high_score = 0
local pause_index = 1
local menu_index = 1

world = bump.newWorld(16)



all_clocks = {
    __clocks = {},
    update = function(self)
        for c in table.for_each(self.__clocks) do
            c:update()
        end
    end,
    add = function(self, c)
        table.insert(self.__clocks, c)
    end,
}

COLORS = {
    BLACK = "#181425",
    BROWN = "#733e39",
    DARK_GRAY = "#5a6988",
    WHITE = "#ffffff",
    LIGHT_BROWN = "#ead4aa",
    BLUE = "#29adff"
}

--TODO: Replace places wher I used COLORS
PALETTE = {
    BRICK_RED    = "#be4a2f",
    BURNT_ORANGE = "#d77643",
    PALE_BEIGE   = "#ead4aa",
    PEACH        = "#e4a672",
    BROWN        = "#b86f50",
    DARK_BROWN   = "#733e39",
    DEEP_PLUM    = "#3e2731",
    CRIMSON      = "#a22633",
    RED          = "#e43b44",
    ORANGE       = "#f77622",
    GOLDENROD    = "#feae34",
    LEMON        = "#fee761",
    LIME_GREEN   = "#63c74d",
    GREEN        = "#3e8948",
    FOREST_GREEN = "#265c42",
    TEAL         = "#193c3e",
    ROYAL_BLUE   = "#124e89",
    SKY_BLUE     = "#0099db",
    CYAN         = "#2ce8f5",
    WHITE        = "#ffffff",
    LIGHT_GRAY   = "#c0cbdc",
    GRAY_BLUE    = "#8b9bb4",
    SLATE        = "#5a6988",
    NAVY_BLUE    = "#3a4466",
    DARK_NAVY    = "#262b44",
    NEAR_BLACK   = "#181425",
    HOT_PINK     = "#ff0044",
    PURPLE_GRAY  = "#68386c",
    MAUVE        = "#b55088",
    PINK         = "#f6757a",
    TAN          = "#e8b796",
    TAUPE        = "#c28569"
}

input = baton.new {
    controls = {
        left = { 'key:left', 'key:a', 'axis:leftx-', 'button:dpleft' },
        right = { 'key:right', 'key:d', 'axis:leftx+', 'button:dpright' },
        --up = { 'key:up', 'key:w', 'axis:lefty-', 'button:dpup' },
        --down = { 'key:down', 'key:s', 'axis:lefty+', 'button:dpdown' },
        jump = { 'key:x', 'button:a' },
        slam = { 'key:z', 'button:x' },
        quit = { 'key:p', 'button:back', 'key:escape' },
        pause = { 'key:return', 'button:start' } },
    --pairs = {
    --   move = { 'left', 'right', 'up', 'down' } },
    joystick = love.joystick.getJoysticks()[1],
}

local pause_img = love.graphics.newImage(PNG_PATH .. "pause.png")
local ground_img = love.graphics.newImage(PNG_PATH .. "ground.png")

shake_duration = 0
shake_wait = 0
shake_offset = { x = 0, y = 0 }

require("src.ground")
require("src.clock")
require("src.hitbox")
require("src.functions")
require("lib.timer")
require("src.player")
require("src.cube")



local screen_rect = { x = 0, y = 0, w = 128, h = 128 }
player = Player.new()
game_clock = Clock()
results_clock = Clock()

all_clocks:add(game_clock)
all_clocks:add(results_clock)

function love.load()
    set_bgcolor_from_hex(COLORS.BLACK)

    change_gamestate(GAME_STATES.title)
    change_gamestate(GAME_STATES.game)



    high_score = load_high_score()

    if is_debug_on then
        logger.level = logger.Level.DEBUG
        logger.debug("Entering debug mode")
        love.profiler.start()
    else
        logger.level = logger.Level.DEBUG
        logger.info("logger in INFO mode")
    end

    math.randomseed(os.time())
    font = love.graphics.newFont("asset/font/mago2.ttf", 32)
    font_hud = love.graphics.newFont("asset/font/PICO-8.ttf", 64)
    font:setFilter("nearest")
    font_hud:setFilter("nearest")

    love.graphics.setFont(font)

    -- if your code was optimized for fullHD:
    window = { translateX = 0, translateY = 0, scale = 4, width = 128, height = 128 }
    width, height = love.graphics.getDimensions()
    love.window.setMode(width, height, { resizable = true, borderless = false })
    resize(width, height) -- update new translation and scale

    Cube()
end

function love.quit()
    logger.info("The game is closing.")
    if is_debug_on then
        love.profiler.stop()
        print(love.profiler.report(30))
    end
end

function love.update(dt)
    all_clocks:update()
    check_inputs()
    if game_state == GAME_STATES.game then
        if shake_duration > 0 then
            shake_duration = shake_duration - dt
            if shake_wait > 0 then
                shake_wait = shake_wait - dt
            else
                shake_offset.x = love.math.random(-5, 5)
                shake_offset.y = love.math.random(-5, 5)
                shake_wait = 0.02
            end
        end
        update_game(dt)
    end

    if game_state == GAME_STATES.pause then
        update_pause()
    end

    -- if gamestate == GAMESTATES.day_intro then
    --     update_day_intro()
    -- end

    -- if game_state == GAME_STATES.day_title then
    --     update_day_title()
    -- end

    --print((collectgarbage('count') / 1024))
    input:update()
    --print_mem()
end

function check_inputs()
    --if game_state == GAME_STATES.title then
    if game_state == GAME_STATES.game then
        if input:pressed('pause') then
            game_state = GAME_STATES.pause
            is_paused = true
            return
        end

        -- if input:down 'left' then
        --     player:move("left")
        -- end
        -- if input:down 'right' then
        --     player:move("right")
        -- end
        if input:down 'slam' then

        end
    elseif game_state == GAME_STATES.pause then
        if input:pressed('pause') then
            print("on pause pressing pause")
            game_state = GAME_STATES.game
            is_paused = false
            return
        end
        --elseif game_state == GAME_STATES.gameover then
        --if input:pressed 'jump' then
        --reset_game()
        --change_gamestate(GAME_STATES.title)
        --return
        --end
    end

    if input:pressed 'quit' then
        quit_game()
    end
end

function change_gamestate(state)
    menu_index = 1
    game_state = state
end

function love.draw()
    -- first translate, then scale
    love.graphics.translate(window.translateX, window.translateY)
    if shake_duration > 0 then
        love.graphics.translate(shake_offset.x, shake_offset.y)
    end
    love.graphics.scale(window.scale)
    -- your graphics code here, optimized for fullHD

    love.graphics.push("all")
    set_color_from_hex(COLORS.BLUE)
    --love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
    love.graphics.rectangle("fill", 0, 0, 128, 128)
    love.graphics.pop()

    if game_state == GAME_STATES.game then
        draw_game()
        --hud:draw()
    end

    --love.graphics.push("all")
    --set_color_from_hex(COLORS.DARK_PURPLE)
    --love.graphics.rectangle("fill", -50, 0, 50, 128)
    --love.graphics.rectangle("fill", 128, 0, 50, 128)
    --love.graphics.pop()

    if game_state == GAME_STATES.pause then
        draw_game()
        draw_pause()
    end

    --print("Current FPS: "..tostring(love.timer.getFPS( )))
    --print('Memory used: ' .. string.format("%.2f", collectgarbage('count')/1000) .. " MB")
end

function resize(w, h)
    --[[]
    update new translation and scale:
    target rendering resolution
    ]]
    --                  --
    local _w1, _h1 = window.width, window.height
    local _scale = math.min(w / _w1, h / _h1)
    window.translateX, window.translateY, window.scale = (w - _w1 * _scale) / 2, (h - _h1 * _scale) / 2, _scale
end

function love.resize(w, h)
    resize(w, h) -- update new translation and scale
end

function quit_game()
    love.event.quit()
end

function table.for_each(list)
    local _i = 0
    return function()
        _i = _i + 1; return list[_i]
    end
end

function table.remove_item(tbl, item)
    for i, v in ipairs(tbl) do
        if v == item then
            tbl[i] = tbl[#tbl]
            tbl[#tbl] = nil
            return
        end
    end
end

function draw_game()
    love.graphics.draw(ground_img, 0, 105)
    for c in table.for_each(cubes) do
        c:draw()
    end

    player:draw()

    --drawDebug()
    --drawConsole()
    drawBox(ground)
    drawBox(wall_left)
    drawBox(wall_right)
    drawBox(player)
    for c in table.for_each(cubes) do
        drawBox(c)
    end
    draw_hud()
end

function draw_pause()
    love.graphics.draw(pause_img, -50, 0)
    love.graphics.print("_", 49, 40 + (pause_index * 8))
    love.graphics.print("Resume", 57, 50, 0, 0.5, 0.5)
    love.graphics.print("quit", 57, 66, 0, 0.5, 0.5)
end

function is_on_screen(obj)
    if ((obj.x >= screen_rect.x + screen_rect.w) or
            (obj.x + obj.w <= screen_rect.x) or
            (obj.y >= screen_rect.y + screen_rect.h) or
            (obj.y + obj.h <= screen_rect.y)) then
        return false
    else
        return true
    end
end

function is_colliding(rect_a, rect_b)
    if ((rect_a.x >= rect_b.x + rect_b.w) or
            (rect_a.x + rect_a.w <= rect_b.x) or
            (rect_a.y >= rect_b.y + rect_b.h) or
            (rect_a.y + rect_a.h <= rect_b.y)) then
        return false
    else
        return true
    end
end

function start_game()
    -- TODO: fix player score getting reset after each day
    --reset_game()
    game_clock:start()

    high_score = load_high_score()
    change_gamestate(GAME_STATES.game)
    bg_music:setVolume(0.2)
    bg_music:play()
    player:reset()

    shake_duration = 0
    shake_wait = 0
    shake_offset = { x = 0, y = 0 }
    hud:reset()
end

function reset_game()
    player.score = 0
    change_gamestate(GAME_STATES.title)
end

function update_game(dt)
    flux.update(dt)

    --hud:update()

    --results_clock:update(

    --if #twisters == 3 and not wormhole_active then
    --spawn_wormhole(player.x, player.y)
    --wormhole_active = true
    --end
    -- for _, t in ipairs(timers) do
    --     t:update()
    -- end

    player:update(dt)
    --update_things(dt)

    for c in table.for_each(cubes) do
        c:update(dt)
    end
end

function update_pause()

end

function table.for_each(_list)
    local i = 0
    return function()
        i = i + 1; return _list[i]
    end
end

function save_high_score(score)
    if score > high_score then
        local file = love.filesystem.newFile("data.sav")
        file:open("w")
        file:write(score)
        file:close()
    end
end

function load_high_score()
    local score, _ = love.filesystem.read("data.sav")
    score = tonumber(score)
    return score or 0
end

local groundFilter = function(item, other)
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


-- function drawDebug()
--     bump_debug.draw(world)

--     local statistics = ("fps: %d\nmem: %dKB\nitems: %d"):format(love.timer.getFPS(),
--         collectgarbage("count"), world:countItems())
--     love.graphics.setColor(1, 1, 1)
--     love.graphics.printf(statistics, 0, 0, 300, 'left', 0, 0.5, 0.5)
-- end

function drawConsole()
    local str = table.concat(consoleBuffer, "\n")
    for i = 1, consoleBufferSize do
        love.graphics.setColor(1, 1, 1, i / consoleBufferSize)
        love.graphics.printf(consoleBuffer[i], 10, 580 - (consoleBufferSize - i) * 12, 790, "left")
    end
end

function drawBox(box)
    love.graphics.push("all")
    set_color_from_hex(PALETTE.RED)
    --love.graphics.setColor(r,g,b,0.25)
    --love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    --love.graphics.setColor(r,g,b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.pop()
end

function draw_hud()
    love.graphics.push("all")
    set_color_from_hex(COLORS.BLACK)
    --love.graphics.rectangle("fill", 12, 120, 100, 20)
    --set_color_from_hex(COLORS.BLACK)
    love.graphics.setFont(font_hud)
    love.graphics.print("Score:" .. player.score, 10, 2, 0, 0.1, 0.1)
    love.graphics.pop()
end
