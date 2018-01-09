-- Simple ASCII text renderer.
--
-- Based on Joey de Vries' tutorial at learnopengl.com
-- (https://learnopengl.com/#!In-Practice/Text-Rendering )

local gl = require("moongl")
local glmath = require("moonglmath")
local ft = require("moonfreetype")

local vec2, vec4, ortho = glmath.vec2, glmath.vec4, glmath.ortho

local Vertex_shader = [[
#version 330 core
layout (location = 0) in vec4 Vertex; // <vec2 pos, vec2 tex>
out vec2 TexCoords;
uniform mat4 Projection;

void main()
   {
   gl_Position = Projection * vec4(Vertex.xy, 0.0, 1.0);
   TexCoords = Vertex.zw;
   }
]]

local Fragment_shader = [[
#version 330 core
in vec2 TexCoords;
out vec4 color;
uniform sampler2D Text;
uniform vec4 Color;

void main()
   {    
   color = Color * vec4(1.0, 1.0, 1.0, texture(Text, TexCoords).r);
   }
]]

local Program, Vsh, Fsh
local Vao, Vbo
local Color_loc, Projection_loc
local Width, Height
local Fonts = {} -- keeps track of all the loaded fonts

local function WindowResize(width, height)
   Width, Height = width, height
   gl.use_program(Program)
   local projection = ortho(0, width, height, 0, -1, 1)
   gl.uniform_matrix(Projection_loc, 'float', '4x4', true, gl.flatten(projection))
end


local function Init(width, height)
   assert(not Program, "double call")
   Program, Vsh, Fsh = gl.make_program_s('vertex', Vertex_shader, 'fragment', Fragment_shader)

   gl.use_program(Program)
   Projection_loc = gl.get_uniform_location(Program, "Projection")
   Color_loc = gl.get_uniform_location(Program, "Color")
   gl.uniform(gl.get_uniform_location(Program, "Text"), 'int', 0)

   WindowResize(width, height)

   -- Configure VAO/VBO for texture quads
   Vao = gl.new_vertex_array()
   Vbo = gl.new_buffer('array')
   gl.buffer_data('array', gl.sizeof('float')*6*4, 'dynamic draw')
   gl.enable_vertex_attrib_array(0)
   gl.vertex_attrib_pointer(0, 4, 'float', false, 4*gl.sizeof('float'), 0)
   gl.unbind_buffer('array')
   gl.unbind_vertex_array()
   gl.use_program(0)

   gl.enable('blend')
   gl.blend_func('src alpha', 'one minus src alpha')
   gl.pixel_store('unpack alignment', 1) -- disable OpenGL byte-alignment restriction
end

-------------------------------------------------------------------------------

local Font = {}
local function New(fontpathname, font_size)
-- Loads the givent font and pre-compiles a list of characters
-- font_size = 0..1, normalized size relative to the window Height
   assert(font_size > 0 and font_size <= 1, "invalid font size")

   -- Initialize and load the FreeType library, load the font face,
   -- and set the desired glyph size
   local ftlib = ft.init_freetype()
   local face = ft.new_face(ftlib, fontpathname)
   face:set_pixel_sizes(0, math.floor(font_size*Height+.5))
   
   local font = setmetatable({}, {__index = Font})

   -- Pre-load the first 128 ASCII characters
   font.char = {}
   for c = 0, 127 do 
      -- Load glyph
      face:load_char(c, ft.LOAD_RENDER)
      local glyph = face:glyph()
      local bitmap = glyph.bitmap
      -- Generate texture and set texture options
      local texid = gl.new_texture('2d')
      gl.texture_image('2d', 0, 'red', 'red', 'ubyte', bitmap.buffer, bitmap.width, bitmap.rows)
      gl.texture_parameter('2d', 'wrap s', 'clamp to edge')
      gl.texture_parameter('2d', 'wrap t', 'clamp to edge')
      gl.texture_parameter('2d', 'min filter', 'linear')
      gl.texture_parameter('2d', 'mag filter', 'linear')
       
      -- Store character info for later use
      font.char[c] = {
         texid = texid,
         size = vec2(bitmap.width, bitmap.rows), -- glyph size
         bearing = vec2(bitmap.left, bitmap.top), -- offset from baseline to left/top of glyph
         advance = glyph.advance.x -- horizontal offset to advance to next glyph
      }
      -- print("Added "..string.char(c) .. " ("..c..")")
   end
   gl.unbind_texture('2d')
   face:done()
   ftlib:done()

   font.hby = font.char[string.byte('H')].bearing.y
   font.size = font_size
   Fonts[font] = font
   return font
end

function Font.free(font)
-- Delete a previous loaded font
   assert(Fonts[font] == font)
   for _, c in pairs(font.char) do gl.delete_textures(c.texid) end
   Fonts[font] = nil
end

local BLACK = vec4(0, 0, 0, 1)

function Font.render(font, text, x, y, size, color)
-- Renders a string of text using the specified font (previously loaded).
-- text: the string of text.
-- x, y: normalized position (1,1=Width,Height) of the text's top left corner
-- size: size, relative to the window height (1=Height).
-- color: vec3 or vec4
   local color = color or BLACK
   local x, y = x*Width, y*Height
   local hby = font.hby
   local scale = size*Height/hby
    
   gl.use_program(Program)
   gl.uniform(Color_loc, 'float', color.r, color.g, color.b, color.a or 1)
   gl.active_texture(0)
   gl.bind_vertex_array(Vao)

   for i = 1, #text do
      local c = text:byte(i)  -- numeric code for the i-th character
      local ch = font.char[c] -- info for the character
      local xpos = x + ch.bearing.x*scale
      local ypos = y + (hby - ch.bearing.y)*scale
      local w = ch.size.x * scale
      local h = ch.size.y * scale

      -- Update the contents of vbo, and render the quad
      -- texturing it with this character's texture.
      gl.bind_buffer('array', Vbo)
      gl.buffer_sub_data('array', 0, gl.pack('float', {
         { xpos,     ypos + h,   0.0, 1.0 },
         { xpos + w, ypos,       1.0, 0.0 },
         { xpos,     ypos,       0.0, 0.0 },
         { xpos,     ypos + h,   0.0, 1.0 },
         { xpos + w, ypos + h,   1.0, 1.0 },
         { xpos + w, ypos,       1.0, 0.0 }
      }))
      gl.unbind_buffer('array')
      gl.bind_texture('2d', ch.texid)
      gl.draw_arrays('triangles', 0, 6)

      -- Advance x position for the next glyph, if any
      x = x + (ch.advance >> 6) * scale -- = x + ch.advance/64 *scale
   end
   gl.unbind_vertex_array()
   gl.unbind_texture('2d')
end

function Font.text_width(font, text, size)
-- Returns the width of a string of text, relative to the window width (1=Width).
-- text: the string of text.
-- size: font size relative to the window height (1=Height).
   local scale = size*Height/font.hby
   local x = 0
   for i = 1, #text do
      local ch = font.char[text:byte(i)]
      x = x + (ch.advance >> 6)*scale
   end
   return x/Width
end


return {
   init = Init,
   window_resize = WindowResize,
   new = New,
   free = Free,
}

