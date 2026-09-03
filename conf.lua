function love.conf(t)
    t.identity = "tag_love2d"
    t.version = "11.5"
    t.console = false
    t.window.title = "TAG"
    t.window.icon = nil
    t.window.width = 1280
    t.window.height = 720
    t.window.borderless = false
    t.window.resizable = true
    t.window.minwidth = 800
    t.window.minheight = 450
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 4
    t.window.highdpi = true

    t.modules.audio = true
    t.modules.sound = true
    t.modules.graphics = true
    t.modules.timer = true
    t.modules.keyboard = true
    t.modules.mouse = true
    t.modules.math = true
    t.modules.image = true
    t.modules.physics = false
    t.modules.system = true
    t.modules.touch = true
end
