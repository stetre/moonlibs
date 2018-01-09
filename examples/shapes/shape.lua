-- Simple 2D shapes renderer 
-- (points, lines, circles, squares, ...)

local gl = require("moongl")
local glmath = require("moonglmath")
local translate, rotate, scale = glmath.translate, glmath.rotate, glmath.scale
local vec2 = glmath.vec2
local vec4 = glmath.vec4

local Vertex_shader = [[
#version 330 core
layout (location = 0) in vec2 position;
uniform mat4 Model;
uniform mat4 Projection;

void main()
   {
   gl_Position = Projection * Model * vec4(position.xy, 0.0, 1.0);
   }
]]

local Fragment_shader = [[
#version 330 core
uniform vec4 Color;
out vec4 color;

void main()
   {
   color = Color;
   }
]]

-------------------------------------------------------------------------------

local Program, Vsh, Fsh, Vao -- Shader program, shaders, and vertex array object (OpenGL names)
local Model_loc, Projection_loc, Color_loc -- locations of uniform variables
local Rect0, RectN
local Circle0, CircleN

local function SetProjection(projection)
-- Set the the projection matrix (mat4).
-- Call this at window resize.
   gl.use_program(Program)
   gl.uniform_matrix(Projection_loc, 'float', '4x4', true, gl.flatten(projection))
end

local function AddRectVertices(vertices)
-- Adds the vertices of a rect of side 2 centered at the origin.
-- Returns the 0-based index of the first vertex and the no. of appended vertices.
   local first = #vertices
   table.insert(vertices, {0,0}) -- center
   table.insert(vertices, {1,1})
   table.insert(vertices, {-1,1})
   table.insert(vertices, {-1,-1})
   table.insert(vertices, {1,-1})
   table.insert(vertices, {1,1})
   return first, 6
end

local function AddCircleVertices(vertices, N)
-- Generates the vertices for a circle of radius 1 centered at (0,0),
-- and appends them to the table 'vertices'. 
-- Returns the 0-based index of the first vertex and the no. of appended vertices.
   local first = #vertices
   table.insert(vertices, {0,0}) -- center
   local alpha, delta_alpha = 0, 2*math.pi/N
   for i = 1, N+1 do
      table.insert(vertices, {math.cos(alpha), math.sin(alpha)})
      alpha = alpha + delta_alpha
   end
   return first, N+2
end

local function Init(projection)
-- projection: projection matrix (mat4)
-- e.g. glmath.ortho(0, window_width, window_height, 0, -1, 1)
   assert(not Program, "double initialization")
   Program, Vsh, Fsh = gl.make_program_s('vertex', Vertex_shader, 'fragment', Fragment_shader)

   -- Get locations for uniform variables
   Model_loc = gl.get_uniform_location(Program, "Model")
   Color_loc = gl.get_uniform_location(Program, "Color")
   Projection_loc = gl.get_uniform_location(Program, "Projection")
   SetProjection(projection)
   

   -- Set defaults
   gl.uniform(Color_loc, 'float', 1, 1, 1, 1)

   -- Generate vertex data
   local vertices = { {0.0, 0.0}, {1.0, 0.0} }
   Rect0, RectN = AddRectVertices(vertices)
   Circle0, CircleN = AddCircleVertices(vertices, 64)
   vertices = gl.pack('float', vertices)

   -- Initialize and configure the vertex buffer
   Vao = gl.new_vertex_array()
   local vbo = gl.new_buffer('array')
   gl.buffer_data('array', vertices, 'static draw')
   gl.enable_vertex_attrib_array(0)
   gl.vertex_attrib_pointer(0, 2, 'float', false, 2*gl.sizeof('float'), 0)
   gl.unbind_buffer('array')
   gl.unbind_vertex_array()

   gl.enable('blend')
   gl.blend_func('src alpha', 'one minus src alpha')
   gl.enable('line smooth') -- enable line antialiasing
end

local function Destroy()
   gl.delete_vertex_array(Vao)
   gl.clean_program(Program, Vsh, Fsh)
end

-------------------------------------------------------------------------------

local PointSize, LineWidth

local function SetPointSize(val)
   PointSize = gl.get("point size") 
   gl.point_size(val)
end

local function SetLineWidth(val)
   LineWidth = gl.get("line width")
   gl.line_width(val)
end

local function RestorePointSize() gl.point_size(PointSize) end

local function RestoreLineWidth() gl.line_width(LineWidth) end

local function SetModel(model)
   gl.uniform_matrix(Model_loc, 'float', '4x4', true, gl.flatten(model))
end

local function SetColor(color)
   if not color then gl.uniform(Color_loc, 'float', 1, 1, 1, 1) return end
   gl.uniform(Color_loc, 'float', color.r, color.g, color.b, color.a or 1)
end

-------------------------------------------------------------------------------

local function DrawPoint(pos, point_size, color)
-- pos: where to draw the pont (vec2)
-- point_size: point size in pixels
-- color: optional color (vec3 or vec4)
   gl.use_program(Program)
   SetPointSize(point_size)
   SetColor(color)
   SetModel(translate(pos.x, pos.y, 0))
   gl.bind_vertex_array(Vao)
   gl.draw_arrays('points', 0, 1)
   gl.unbind_vertex_array()
   RestorePointSize()
end

local function DrawPoints(positions, point_size, color)
   for _, pos in ipairs(positions) do
      DrawPoint(pos, point_size, color)
   end
end
-------------------------------------------------------------------------------

local function DrawLine(p1, p2, line_width, color, point_size)
-- Draw a line.
-- p1, p2: the endpoints (vec2)
-- line_width: optional line width (float)
-- color: optional color (vec3 or vec4)
-- point_size: if not nil, draw also the points with the given size
   gl.use_program(Program)
   SetLineWidth(line_width)
   SetColor(color)

   local p12 = p2 - p1
   local len = p12:norm()
   local rot = math.acos(p12.x/len)
   SetModel(translate(p1.x, p1.y, 0) * rotate(rot, 0, 0, 1) *scale(len, 1, 1))

   gl.bind_vertex_array(Vao)
   gl.draw_arrays('lines', 0, 2)
   if point_size then
      SetPointSize(point_size)
      gl.draw_arrays('points', 0, 2)
      RestorePointSize()
   end
   gl.unbind_vertex_array()
   RestoreLineWidth()
end

local function DrawLinedir(point, dir, line_width, color, point_size)
   DrawLine(point, point+dir, line_width, color, point_size)
end

-------------------------------------------------------------------------------

local function DrawRect(center, half, rot, line_width, color, point_size)
-- Draw a rectangle.
-- center: center of the rectangle (vec2)
-- half: half diagonal (vec2)
-- rot: rotation around the center (radians)
-- line_width: line width or 'fill'
-- color: optional color (vec3 or vec4)
-- point_size: if not nil, draw also the points with the given size
   gl.use_program(Program)
   SetColor(color)

   local sx, sy = math.abs(half.x), math.abs(half.y)
   SetModel(translate(center.x, center.y, 0)*rotate(rot, 0, 0, 1)*scale(sx, sy, 1))

   gl.bind_vertex_array(Vao)
   if line_width == 'fill' then
      gl.draw_arrays('triangle fan', Rect0, RectN)
   else
      SetLineWidth(line_width)
      gl.draw_arrays('line loop', Rect0+1, RectN-1)
      RestoreLineWidth()
      if point_size then
         SetPointSize(point_size)
         gl.draw_arrays('points', Rect0+1, RectN-1)
         RestorePointSize()
      end
   end
   
   gl.unbind_vertex_array()
end

local function DrawSquare(p1, side, rot, line_width, color, point_size)
   DrawRect(p1, vec2(side/2, side/2), rot, line_width, color, point_size)
end

local function DrawBox(p1, p2, rot, line_width, color, point_size)
   DrawRect((p1+p2)/2, (p2-p1)/2, rot, line_width, color, point_size)
end

-------------------------------------------------------------------------------

local function DrawCircle(center, radius, line_width, color, point_size)
-- Draw a circle.
-- center: center point (vec2)
-- radius: radius of the circle (float)
-- line_width: line width or 'fill'
-- color: optional color (vec3 or vec4)
-- point_size: if not nil, draw also the center point with the given size
   gl.use_program(Program)

   local model = translate(center.x, center.y, 0)*scale(radius, radius, 1)
   gl.uniform_matrix(Model_loc, 'float', '4x4', true, gl.flatten(model))

   if color then gl.uniform(Color_loc, 'float', color.r, color.g, color.b, color.a or 1) end

   gl.bind_vertex_array(Vao)
   if line_width == 'fill' then
      gl.draw_arrays('triangle fan', Circle0, CircleN)
   else
      local old_line_width = gl.get("line width")
      gl.line_width(line_width)
      gl.draw_arrays('line loop', Circle0+1, CircleN-1)
      gl.line_width(old_line_width)
      if point_size then
         SetPointSize(point_size)
         gl.draw_arrays('points', Circle0, 1)
         RestorePointSize()
      end
   end
   gl.unbind_vertex_array()

   if color then gl.uniform(Color_loc, 'float', 1, 1, 1, 1) end
end

local function DrawDisc(center, radius, color, point_size)
   return DrawCircle(center, radius, 'fill', color, point_size)
end

-------------------------------------------------------------------------------

return {
   init = Init,
   set_projection = SetProjection,
   destroy = Destroy,
   point = DrawPoint,
   points = DrawPoints,
   line = DrawLine,
   linedir = DrawLinedir,
   rect = DrawRect,
   square = DrawSquare,
   box = DrawBox,
   circle = DrawCircle,
   disc = DrawDisc,
}

