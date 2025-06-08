function love.conf(t)
    t.identity = "cube-bop"
    t.window.title = "Cube Hop"
    t.window.icon = "asset/image/icon.png"
    t.window.resizable = true
    t.window.width = 128 * 5
    t.window.height = 128 * 5
    t.window.vsync = 1
    t.window.fullscreen = false
    t.modules.touch = false
    t.console = true --TODO: Remove after debugging.
end
