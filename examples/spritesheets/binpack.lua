#!/usr/bin/env lua
-- Bin packer. This module can be used to create a sprite-sheet
-- from a set of individual sprites.

local mi = require("moonimage")
local max = math.max

-------------------------------------------------------------------------------
-- Node
-------------------------------------------------------------------------------
-- A Node represents a rectangular portion of the bin.
-- A Node's children represent a partition of that portion.
-- The bin-packing algorithm creates a binary tree of Nodes, and
-- populates its leaves with the sprites (the leaves of the tree
-- make up a partition of the bin).
-- If a leaf does not contain a sprite (rect) then the portion
-- of the bin it represents is empty, ie wasted space.

local Node = {}
local function NewNode(x, y, width, height)
   local node = setmetatable({}, {__index = Node})
   node.x, node.y = x, y  -- top-left corner of the node's area
   node.width, node.height = width, height -- dimensions of the node's area
   node.id = nil -- the id of the rectangle (if any) placed in the node's area
   node.rotate = false -- the rectangle is rotated
   node.left, node.right = nil, nil  -- children nodes
   node.area = width*height
   return node
end

function Node.fits(node, rect)
-- Returns true if rect fits in node's area, false otherwise.
-- May rotate rect to make it fit.
   if node.width >= rect.width and node.height >= rect.height then
      return true, false
   end
   if node.width >= rect.height and node.height >= rect.width then
      -- rotate rect to make it fit in the node's area
      rect.rotate = not rect.rotate
      return true, true
   end
   return false
end

function Node.insert(node, rect)
-- Select (create) a node where rect can fit, and place rect in it.
--
-- This function implements the bin-packing algorithm described here: 
-- http://blackpawn.com/texts/lightmaps/default.html
--
-- A survey of alternative bin-packing algorithms can be found in
-- "A Thousand Ways to Pack the Bin", Jukka Jylänki, 2010.
-- http://clb.demon.fi/files/RectangleBinPack.pdf
--
   if node.left then -- not a leaf
      return node.left:insert(rect) or node.right:insert(rect)
   else -- leaf
      if node.id then return false end -- already used
      local fits, rotate = node:fits(rect)
      if not fits then return false end
      local x, y, w, h = node.x, node.y, node.width, node.height
      local sw, sh = rect.width, rect.height
      local dw, dh = w - sw, h - sh

      if dw == 0 and dh == 0 then -- fits perfectly
         node.id = rect.id
         node.data = rect.data
         node.rotate = rotate
         if rotate then Rotate(node) end
         return true
      end
      -- create children and insert into first created
      if dw > dh then -- split vertically
         node.left = NewNode(x, y, sw, h)
         node.right = NewNode(x + sw, y, dw, h)
      else -- split horizontally
         node.left = NewNode(x, y, w, sh)
         node.right = NewNode(x, y + sh, w, dh)
      end
      return node.left:insert(rect)
   end
end

function Node.traverse(node, func, ...)
-- Each time a leaf is reached during the traversal, the passed
-- function is executed as func(node, ...) where node is the leaf.
   if node.left then node.left:traverse(func, ...) end
   if not node.left then func(node, ...) end
   if node.right then node.right:traverse(func, ...) end
end

local function Pixel(duck, i, j, nchannels)
-- Returns pixel[i, j] as a binary string
   local k = ((j-1)*duck.width + (i-1))*nchannels + 1
   return duck.data:sub(k, k + nchannels-1)
end

local function Rotate(duck)
-- Rotates data by -pi/2 
   local w, h = duck.width, duck.height
   duck.width, duck.height = h, w
   if not duck.data then return end
   local nchannels = #duck.data/(w*h)
   print(nchannels)
   local t = {}
   for i = w, 1, -1 do
      for j = 1, h do
         table.insert(t, Pixel(duck, i, j, nchannels))
      end
   end
   duck.data = table.concat(t)
end

function Node.topartition(node)
   local t = {}
   node:traverse(function(node, t)
      local s = {}
      s.x, s.y = node.x, node.y
      s.width, s.height = node.width, node.height
      s.id = node.id
      s.rotate = node.rotate
      s.data = node.data
      table.insert(t, s)
   end, t)
   return t
end

-------------------------------------------------------------------------------
-- Bin
-------------------------------------------------------------------------------

local function NewBin()
   local rects = {} -- contains the rectangles indexed by id
   local count = 0 -- no. of rects
   local area = 0 -- total area of rects
   local width, height = 2, 2 -- current size of the bin
   local partition = nil
   return setmetatable({}, {
      __index = {
         ----------------------------------------------------------------------
         add = function(bin, id, w, h, data)
         -- Add a rect (a sprite) to the bin.
         -- id: unique id to assign to it
         -- w, h: dimensions of the rect
         -- data: pixel data (binary string), required only if write() is used
               assert(id, "missing or invalid id")
               assert(not rects[id], "id '"..id.."' in use")
               rects[id] = {
                  id = id,                -- rect identifier
                  width = w, height = h,  -- dimensions of the rect
                  data = data,            -- optional data
                  area = w*h,             
               }
               count = count + 1
               area = area + w*h
         end,
         ----------------------------------------------------------------------
         increase = function(bin)
         -- increases the bin size
            if width > height then height = height*2 else width=width*2 end
            while width*height < area do bin:increase() end
         end,
         ----------------------------------------------------------------------
         clear = function(bin)
         -- Clear the bin, throwing away all the rectangles.
            width, height = 2, 2
            area = 0
            count = 0
            rects = {}
            partition = nil
         end,
         ----------------------------------------------------------------------
         pack = function(bin)
         -- Pack the bin.
         -- Returns (partition, width, height, fill_ratio), where
         -- * partition is an array of tables, each representing a rectangular
         --   sub-area of the bin, and having the following fields:
         --    partition[i] = {
         --       x, y: integer,          top left corner of the sub-area
         --       width, height: integer  dimensions of the sub-area
         --       id: string or nil,      the id of the rectangle packed in it, if any
         --       rotate: boolean         true if the rectangle is rotated by pi/2
         --       data: binary string     rect data (if any)
         --    }
         -- * width and height: integer, the dimensions of the bin
         -- * fill_ratio: float, the ratio between the total area of the rectangles
         --   and the area of the bin.
         --
            -- Sort rects
            local rects1 = {}
            for _, s in pairs(rects) do table.insert(rects1, s) end
            table.sort(rects1, function (s1, s2) 
               -- return max(s1.width, s1.height) > max(s2.width, s2.height)
               return s1.width + s1.height > s2.width + s2.height
            end)

            local root
            width, height = 2, 2
            while not root do
               bin:increase()
               root = NewNode(0, 0, width, height)
               for _, s in ipairs(rects1) do
                  if not root:insert(s) then -- packing failed
                     root = nil -- retry with increased size
                     break
                  end
               end
            end
            partition = root:topartition()
            return partition, width, height, area/(width*height)
         end,
         ----------------------------------------------------------------------
         write = function(bin, outfile, channels)
         -- Writes the spritesheet image on outfile.png, and the metadata
         -- on outfile.lua
            assert(outfile and type(outfile)=='string', "missing or invalid outfile")
            assert(partition, "bin is not packed")
            local nchannels = #channels
            local zero = string.pack(string.rep("B", nchannels), 0, 0, 0, 0)
            local pixels = {}
            local f = io.open(outfile..".lua", "w")
            f:write("return {\n")

            for _, node in ipairs(partition) do
               for j = 1, node.height do
                  local offset = (node.y + j - 1)*width + node.x
                  for i = 1, node.width do
                     pixels[offset + i] = node.data and Pixel(node, i, j, nchannels) or zero
                  end
               end
               if node.id then
                  f:write(string.format(
                     "   %s = { x=%d, y=%d, width=%d, height=%d, rotate=%s },\n",
                     node.id, node.x, node.y, node.width, node.height, 
                     node.rotate and 'true' or 'false'))
               end
            end
            f:write("}\n")
            f:close()
            mi.write_png(outfile..".png", width, height, channels, table.concat(pixels))
         end,
      },
   })
end

return NewBin

