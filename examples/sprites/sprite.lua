-- Sprite Renderer
--
-- Based on Joey De Vries' tutorial at learnopengl.com
-- (https://learnopengl.com/#!In-Practice/2D-Game/Rendering-Sprites )

local gl = require("moongl")
local mi = require("moonimage")
local glmath = require("moonglmath")
local translate, rotate, scale = glmath.translate, glmath.rotate, glmath.scale

local Vertex_shader = [[
#version 330 core
layout (location = 0) in vec4 vertex; /* <vec2 Position, vec2 TexCoords> */
out vec2 TexCoords;
uniform mat4 Model;
uniform mat4 Projection;
uniform vec4 Portion;

void main()
   {
   TexCoords = Portion.xy + vertex.zw*(Portion.zw - Portion.xy);
   gl_Position = Projection * Model * vec4(vertex.xy, 0.0, 1.0);
   }
]]

local Fragment_shader = [[
#version 330 core
in vec2 TexCoords;
out vec4 color;
uniform sampler2D image;
uniform vec4 SpriteColor;

void main()
   {    
   color = SpriteColor * texture(image, TexCoords);
   }
]]

-------------------------------------------------------------------------------

local Program, Vsh, Fsh, Vao -- Shader program, shaders, and vertex array object (OpenGL names)
local TextureUnit = 0 --@@ configurable?
local Model_loc, Projection_loc, Color_loc, Portion_loc -- locations of uniform variables

local function SetProjection(projection)
-- Set the the projection matrix (mat4).
-- Call this at window resize.
   gl.use_program(Program)
   gl.uniform_matrix(Projection_loc, 'float', '4x4', true, gl.flatten(projection))
end

local function Init(projection)
-- projection: projection matrix (mat4)
-- eg. glmath.ortho(0, width, height, 0, -1, 1)
   assert(not Program, "double initialization")
   Program, Vsh, Fsh = gl.make_program_s('vertex', Vertex_shader, 'fragment', Fragment_shader)

   -- Get locations for uniform variables
   Model_loc = gl.get_uniform_location(Program, "Model")
   Color_loc = gl.get_uniform_location(Program, "SpriteColor")
   Portion_loc = gl.get_uniform_location(Program, "Portion")
   Projection_loc = gl.get_uniform_location(Program, "Projection")
   SetProjection(projection)

   -- Set defaults
   gl.uniform(Portion_loc, 'float', 0, 0, 1, 1)
   gl.uniform(Color_loc, 'float', 1, 1, 1, 1)

   -- Initialize and configure the quad's buffer and vertex attributes
   Vao = gl.new_vertex_array()
   local vbo = gl.new_buffer('array')

   local vertices = gl.pack('float', {
   -- Position    TexCoord
      -.5,  .5,   0.0, 1.0,   -- C     A---B
       .5, -.5,   1.0, 0.0,   -- B     | ./|___ x
      -.5, -.5,   0.0, 0.0,   -- A     |/| |
      -.5,  .5,   0.0, 1.0,   -- C     C---D
       .5,  .5,   1.0, 1.0,   -- D       |
       .5, -.5,   1.0, 0.0,   -- B       V y
   })

   gl.buffer_data('array', vertices, 'static draw')
   gl.enable_vertex_attrib_array(0)
   gl.vertex_attrib_pointer(0, 4, 'float', false, 4*gl.sizeof('float'), 0)
   gl.unbind_buffer('array')
   gl.unbind_vertex_array()
end

local function Destroy()
   gl.delete_vertex_array(Vao)
   gl.clean_program(Program, Vsh, Fsh)
end

local function Draw(texid, pos, size, rot, color, portion)
-- pos: where to draw the center of the quad (vec2)
-- size: optional scaling factors in the x and y directions (vec2)
-- rot: optional angle of rotation around the quad center (radians)
-- color: optional color to apply to the sprite (vec3 or vec4)
-- portion: optional description of the texture portion (vec4)
--
-- To select only the portion of the texture delimited by P1=(u1,v1) and P2=(u2,v2),
-- set the portion parameter to portion = vec4(u1,v1,u2,v2).
--
-- (0,0)-----------> x               (0,0)---------(1,0)
--   |    A___B                        |             |
--   |    | ./|    |                   |   P1---.    |
--   |    |/__|   / rotation           |    |   |<---|-- portion
--   |    C   D  /                     |    '---P2   |
--   v       <--'                    (0,1----------(1,1)
--   y
--   

   gl.use_program(Program)

   -- Prepare the model matrix and send it to the shader
   local model = translate(pos.x, pos.y, 0)
   if rot then model = model*rotate(rot, 0, 0, 1) end
   if size then model = model*scale(size.x, size.y, 1) end
   gl.uniform_matrix(Model_loc, 'float', '4x4', true, gl.flatten(model))

   if color then gl.uniform(Color_loc, 'float', color.r, color.g, color.b, color.a or 1) end
   if portion then gl.uniform(Portion_loc, 'float', table.unpack(portion)) end

   -- Render textured quad
   gl.enable('blend')
   gl.blend_func('src alpha', 'one minus src alpha')
   gl.active_texture(TextureUnit)
   gl.bind_texture('2d', texid)
   gl.bind_vertex_array(Vao)
   gl.draw_arrays('triangles', 0, 6)
   gl.unbind_vertex_array()

   -- Restore defaults
   if portion then gl.uniform(Portion_loc, 'float', 0, 0, 1, 1) end
   if color then gl.uniform(Color_loc, 'float', 1, 1, 1, 1) end
end


-------------------------------------------------------------------------------

local Sprite = {}
local function NewSprite(w, h, data, intformat, format, wrap_s, wrap_t, min_filter, mag_filter)
   local texid = gl.new_texture('2d')
   gl.texture_image('2d', 0, intformat or 'rgb', format or 'rgb', 'ubyte', data, w, h)
   -- Set Texture wrap and filter modes
   gl.texture_parameter('2d', 'wrap s', wrap_s or 'repeat')
   gl.texture_parameter('2d', 'wrap t', wrap_t or 'repeat')
   gl.texture_parameter('2d', 'min filter', min_filter or 'linear')
   gl.texture_parameter('2d', 'mag filter', mag_filter or 'linear')
   gl.unbind_texture('2d')
   local sprite = setmetatable({}, {__index=Sprite})
   sprite.texid = texid
   return sprite
end

local function FromImage(filename, channels, wrap_s, wrap_t, min_filter, mag_filter)
-- Creates a sprite loading the texture data from filename.
   -- channels = 'rgba' | 'rgb'
   local data, w, h = mi.load(filename, channels)
   local sprite = NewSprite(w, h, data, channels, channels, wrap_s, wrap_t, min_filter, mag_filter)
   data = nil; collectgarbage()
   return sprite
end

function Sprite.draw(sprite, pos, size, rot, color, portion)
   return Draw(sprite.texid, pos, size, rot, color, portion)
end


-------------------------------------------------------------------------------
return {
   init = Init,
   set_projection = SetProjection,
   destroy = Destroy,
   from_image = FromImage,
   from_data = NewSprite,
}

