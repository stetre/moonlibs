#!/usr/bin/env lua

local glfw = require("moonglfw")
local gl = require("moongl")
local glmath = require("moonglmath")
local spritesheet = require("spritesheet")

local vec2, vec4 = glmath.vec2, glmath.vec4

local W, H = 800, 600 -- Width and height of the screen
local BGCOLOR = vec4(1,1,1,1)

local function Resize(window, width, height)
   W, H = width, height
   local projection = glmath.ortho(0, W, H, 0, -1, 1)
   spritesheet.set_projection(projection)
   gl.viewport(0, 0, width, height)
end

-- GLFW/OpenGL initialization
glfw.version_hint(3, 3, 'core')
local window = glfw.create_window(W, H, "Rendering Sprites")
glfw.make_context_current(window)
gl.init()
spritesheet.init(glmath.mat4())
Resize(window, W, H)

mysheet = spritesheet.new("mysheet.png", 'rgba', require("mysheet"))

glfw.set_key_callback(window, function(window, key, scancode, action)
   if key == 'escape' and action == 'press' then
      glfw.set_window_should_close(window, true)
   end
end)

glfw.set_window_size_callback(window, function(window, width, height)
   Resize(window, width, height)
end)

local deltaTime, lastFrame = 0.0, 0.0

collectgarbage()
collectgarbage('stop')
gl.clear_color(table.unpack(BGCOLOR))

local rot = 0
while not glfw.window_should_close(window) do
   local currentFrame = glfw.get_time()
   deltaTime = currentFrame - lastFrame
   lastFrame = currentFrame
   glfw.wait_events_timeout(1/60) -- glfw.poll_events()
   gl.clear('color')
   rot = rot + deltaTime
   mysheet:bind()
   mysheet:draw(nil, vec2(.25*W,.25*H), vec2(W/2,H/2))  -- render the whole sheet
   mysheet:draw("sprite1", vec2(.75*W, .725*H), vec2(W/4,H/4), rot) -- render one rotating sprite
   glfw.swap_buffers(window)
   collectgarbage()
end

