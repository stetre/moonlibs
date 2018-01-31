#!/usr/bin/env lua
-- This example creates a spritesheet using the binpack.lua module.
-- The sprites to be packed in the spritesheet are randomly generated.
-- The example outputs a .png file containing the spritesheet image,
-- and a .lua file containing the descriptions of the sprites.
-- These two files can then be used by the rendering example.

local mi = require("moonimage")
local binpack = require("binpack")

local N = 25 -- no. of sprites
local minsz, maxsz = 16, 64 -- limits to the rects' dimensions

--------------------------------------------------------------------------------
-- Sprites generation
--------------------------------------------------------------------------------
-- This is our random artist. It creates a bunch of sprites having random sizes.
-- Our task is to pack them in a single atlas.

local floor = math.floor

local function create_sprite(width, height, outfile)
   local pixels = {}
   for j = height-1, 0, -1 do
      for i = 0, width-1, 1 do
         pixels[#pixels+1] = string.pack("BBBB", 
            floor(255*i/width), floor(255*j/height), 0, 255)
      end
   end
   local filename = outfile..".png"
   mi.write_png(filename, width, height, 'rgba', table.concat(pixels))
end

math.randomseed(os.time())
local sprites = {} -- will hold the sprites' ids (and implicitly their filenames)
for i = 1, N do
   local w, h = math.random(minsz,maxsz), math.random(minsz,maxsz)
   local id = "sprite"..i
   create_sprite(w, h, id)
   table.insert(sprites, id)
end

--------------------------------------------------------------------------------
-- Spritesheet creation
--------------------------------------------------------------------------------

-- Create a new bin:
local bin = binpack()

-- Load the sprites from their files, and add them to the bin:
for _, id in ipairs(sprites) do
   local filename = id..".png"
   local data, w, h = mi.load(filename, 'rgba')
   bin:add(id, w, h, data)
   -- delete sprites files, since we do not need them any more
   os.execute("rm -f "..filename) 
end

-- Pack the rectangles in the bin:
bin:pack()
-- Write the texture file (mysheet.png) and the metadata file (mysheet.lua):
bin:write("mysheet", 'rgba') 

-- os.execute("eog mysheet.png")

