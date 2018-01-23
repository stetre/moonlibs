#!/usr/bin/env lua
-- Joystick usage example.

local glfw = require("moonglfw")
local joystick = require("joystick")

local function printf(...) io.write(string.format(...)) end

window = glfw.create_window(320, 280, "Callbacks example")
glfw.set_key_callback(window, function(window, key, scancode, action) 
   if key == 'escape' and action == 'press' then
      glfw.set_window_should_close(window, true)
   end
end)

-- Add mappings for a particular gamepad type:
joystick.add_mappings("PowerA Xbox One wired controller", { 
   axes = { 'left stick x', 'left stick y', 'left trigger', 
            'right stick x', 'right stick y', 'right trigger', 
            'pad x', 'pad y' },
   buttons = { 'a', 'b', 'x', 'y', 'left bumper', 'right bumper',
            'back', 'start', 'home', 'left stick', 'right stick' }
})
-- ... add other mappings (as many as you like) ...


-- Register the joystick callback. It will be called at the occurring
-- of any joystick related event.
joystick.set_callback(function(id, action, n, val, mapping)
   local name = joystick.name(id)
   if action == 'joins' then
      printf("Joystick-%d '%s' joins\n", id, name)
   elseif action == 'leaves' then
      printf("Joystick-%d '%s' leaves\n", id, name)
   elseif action == 'axis' then
      printf("Joystick-%d '%s' axis[%d] = %.5f %s\n", id, name, n, val,
         mapping and "('"..mapping.."')" or "(???)")
   elseif action == 'button' then
      printf("Joystick-%d '%s' button[%d] = %s %s\n", id, name, n, val,
         mapping and "('"..mapping.."')" or "(???)")
   end
end)

-- Start detecting joysticks. Any joystick joining or leaving will
-- cause the execution of the callback.
joystick.detect()

-- Enter the event loop.
collectgarbage()
collectgarbage('stop')
while not glfw.window_should_close(window) do
   glfw.wait_events_timeout(1/60)
   -- Poll for changes in joysticks' axes and buttons.
   -- Again, any change will be notified via the callback.
   joystick.poll()
   collectgarbage()
end

