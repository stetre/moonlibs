#!/usr/bin/env lua

local glfw = require("moonglfw")
local gl = require("moongl")
local glmath = require("moonglmath")
local shape = require("shape")

local vec2, vec4 = glmath.vec2, glmath.vec4

local W, H = 800, 600 -- Width and height of the screen
local BGCOLOR = vec4(1,1,1,1)

local function Resize(window, width, height)
   W, H = width, height
   local projection = glmath.ortho(0, W, H, 0, -1, 1)
   shape.set_projection(projection)
   gl.viewport(0, 0, width, height)
end

-- GLFW/OpenGL initialization
glfw.version_hint(3, 3, 'core')
local window = glfw.create_window(W, H, "Shape Test")
glfw.make_context_current(window)
gl.init()
shape.init(glmath.mat4())
Resize(window, W, H)

glfw.set_key_callback(window, function(window, key, scancode, action)
   if key == 'escape' and action == 'press' then
      glfw.set_window_should_close(window, true)
   end
end)

glfw.set_window_size_callback(window, Resize)

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

   shape.point(vec2(W/2,H/2), 48, vec4(1,0,0,1))
   shape.point(vec2(W/2,H/2), 24, vec4(0,1,0,1))
   shape.line(vec2(0,0), vec2(W/3,H/3), 2, vec4(0,0,0,1), 8)
   P = vec2(W,0)
   dir = vec2(-W,H):normalize()
   shape.point(P, 48, vec4(1,1,0,1))
   shape.linedir(P, dir*100, 8, vec4(0,0,0,1))

   P1 = vec2(W/2,H/2)
   P2 = P1/2
   shape.rect(P1, P2, 0, 4, vec4(0,0,0,.7), 8)
   shape.box(P1-P2, P1+P2, 0.2, 'fill', vec4(1,0,0,.2), 12)
   shape.square(vec2(W/2, H/2), W/2, 0, 'fill', vec4(0,1,0,.2))
   shape.circle(vec2(W/2,H/2), H/8, 16, vec4(0,0,1,1))
   shape.circle(vec2(W/2,H/2), H/8, 'fill', vec4(0,1,0,.4))
   shape.circle(vec2(W/2,H/2), H/8, 16, vec4(0,0,1,1))
   shape.circle(.75*vec2(W,H), H/10, 'fill', vec4(1,0,0,1))
   shape.circle(.75*vec2(W,H), H/9, 1, vec4(0,0,0,1), 4)
   shape.point(vec2(0,0), 24, vec4(0,0,1,1))
   shape.point(vec2(W/3,H/3), 24, vec4(0,0,1,1))
   shape.box(vec2(0,H/2), vec2(W/2,H), math.pi/4, 'fill', vec4(.5,.5,.5,.7))
   shape.box(vec2(W/2,H/2), vec2(W,H), .2, 8, vec4(1,.5,.5,.7))
   shape.square(vec2(W/2,H/2), W/4, .6, 4, vec4(1,0,1,.7))
   shape.rect(vec2(W/2,H/2), vec2(1,1)*W/3, 0.5, 'fill', vec4(1,.5,.5,.7))
   shape.rect(vec2(W/2,H/2), vec2(1,1)*W/3, 0.2, 4, vec4(0,0,0,.7))


   glfw.swap_buffers(window)
   collectgarbage()
end

