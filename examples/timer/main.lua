#!/usr/bin/env lua
local glfw = require("moonglfw")
local timer = require("timer")

local W, H = 400, 300 -- Width and height of the screen

-- GLFW/OpenGL initialization
glfw.version_hint(3, 3, 'core')
local window = glfw.create_window(W, H)
glfw.make_context_current(window)

glfw.set_key_callback(window, function(window, key, scancode, action)
   if key == 'escape' and action == 'press' then
      glfw.set_window_should_close(window, true)
   end
end)

collectgarbage()
collectgarbage('stop')
timer.reset()
local t = 0

while not glfw.window_should_close(window) do
   glfw.wait_events_timeout(1/60)
	--glfw.poll_events()
   dt, ft, fn, fps, paused = timer.update()
   t = t + dt
   if t >= 1 then
      t = t-1
      print(timer.tostring())
   end
   glfw.set_window_title(window, string.format("Timer Test (fps=%.1f)",fps))
   assert(ft == timer.ft())
   assert(dt == timer.dt())
   glfw.swap_buffers(window)
   collectgarbage()
end

