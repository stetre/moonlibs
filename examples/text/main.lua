#!/usr/bin/env lua

local glfw = require("moonglfw")
local gl = require("moongl")
local glmath = require("moonglmath")
local font = require("font")

local vec2, vec4 = glmath.vec2, glmath.vec4

local W, H = 800, 600 -- Width and height of the screen

local function Resize(window, width, height)
   W, H = width, height
   font.window_resize(W,H)
   gl.viewport(0, 0, width, height)
end

-- GLFW/OpenGL initialization
glfw.version_hint(3, 3, 'core')
local window = glfw.create_window(W, H, "Text rendering example")
glfw.make_context_current(window)
gl.init()

-- Init the font rendering module:
font.init(W,H)

Resize(window, W, H)

glfw.set_key_callback(window, function(window, key, scancode, action)
   if key == 'escape' and action == 'press' then
      glfw.set_window_should_close(window, true)
   end
end)

glfw.set_window_size_callback(window, Resize)

-- Load fonts:
Regular = font.new("Nobile-Regular.ttf", .1)
Italic = font.new("Nobile-Italic.ttf", .1)

collectgarbage()
collectgarbage('stop')
BLACK = vec4(0,0,0,1)
RED = vec4(1,0,0,1)
GREEN = vec4(0,1,0,1)
BLUE = vec4(0,0,1,1)

while not glfw.window_should_close(window) do
   glfw.wait_events()
   gl.clear_color(1,1,1,1)
   gl.clear('color')

   local y = .2
   Regular:render("Hello, World!", 0, .2, .1, BLACK)
   local y = y + Regular.size 
   Regular:render("Hello, World!", 0, y, .1)
   Regular:render("Hello, World!", .01, y, .1, vec4(1,0,0,.3))
   Regular:render("Hello, World!", .02, y, .1, vec4(0,1,0,.3))
   Regular:render("Hello, World!", .03, y, .1, vec4(0,1,1,.3))

   local size = .02
   local text, textwidth, color

   color = RED
   text = "top left"
   Italic:render(text, 0, 0, size, color)
   text = "top center"
   textwidth = Italic:text_width(text, size)
   Italic:render(text, .5-textwidth/2, 0, size, color)
   text = "top right"
   textwidth = Italic:text_width(text, size)
   Italic:render(text, 1-textwidth, 0, size, color)

   color = GREEN
   text = "left"
   Italic:render(text, 0, .5-size/2, size, color)
   text = "center"
   textwidth = Italic:text_width(text, size)
   Italic:render(text, .5-textwidth/2, .5-size/2, size, color)
   text = "right"
   textwidth = Italic:text_width(text, size)
   Italic:render(text, 1-textwidth, .5-size/2, size, color)

   color = BLUE
   text = "bottom left"
   Italic:render(text, 0, 1-size, size, color)
   text = "bottom center"
   textwidth = Italic:text_width(text, size)
   Italic:render(text, .5 -textwidth/2, 1-size, size, color)
   text = "bottom right"
   textwidth = Italic:text_width(text, size)
   Italic:render(text, 1-textwidth, 1-size, size, color)

   glfw.swap_buffers(window)
   collectgarbage()
end

