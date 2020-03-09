#!/usr/bin/env lua

local glfw = require("moonglfw")
local gl = require("moongl")
local glmath = require("moonglmath")
local sprite = require("sprite")

local vec2, vec4 = glmath.vec2, glmath.vec4

local W, H = 800, 600 -- Width and height of the screen
local BGCOLOR = vec4(1,1,1,1)

local function resize(window, width, height)
   W, H = width, height
   local projection = glmath.ortho(0, W, H, 0, -1, 1)
   sprite.set_projection(projection)
   gl.viewport(0, 0, width, height)
end

-- GLFW/OpenGL initialization
glfw.version_hint(3, 3, 'core')
local window = glfw.create_window(W, H, "Rendering Sprites")
glfw.make_context_current(window)
gl.init()
sprite.init(glmath.mat4())
resize(window, W, H)

face = sprite.from_image("awesomeface.png", 'rgba')
block = sprite.from_image("block.png", 'rgb')

glfw.set_key_callback(window, function(window, key, scancode, action)
   if key == 'escape' and action == 'press' then
      glfw.set_window_should_close(window, true)
   end
end)

glfw.set_window_size_callback(window, resize)

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
   face:draw(vec2(.1*W,.1*W), vec2(.2*W,.2*W))
   face:draw(vec2(W/2, W/2), vec2(.1*W, .1*W), rot)
   face:draw(vec2(.7*W, .4*W/2), vec2(.1*W, .1*W), rot, vec4(.8,.2,.5,.6), vec4(.1,.2,.4,.4))
   block:draw(vec2(.2*W, H/2), vec2(.1*W, .1*H), -rot, vec4(0,1,0,.5))
   local size = vec2(.2*W, .1*H)
   local pos = vec2(size.x/2, H-size.y/2)
   block:draw(pos, size, nil, vec4(1,0,0,1))
   pos.x = pos.x + size.x
   block:draw(pos, size, nil, vec4(0,1,0,1))
   pos.x = pos.x + size.x
   block:draw(pos, size, nil, vec4(0,0,1,1))

   glfw.swap_buffers(window)
   collectgarbage()
end

