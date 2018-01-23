-- Callback interface for joysticks

local glfw = require("moonglfw")

local joystick_present = glfw.joystick_present
local get_joystick_name = glfw.get_joystick_name
local get_joystick_axes = glfw.get_joystick_axes
local get_joystick_buttons = glfw.get_joystick_buttons

-------------------------------------------------------------------------------
-- Mappings
-------------------------------------------------------------------------------

local Mappings = {} -- the available mappings, indexed by joystick name

local NoMappings = {axes={}, buttons = {}}

local function AddMappings(name, mappings)
-- Adds mappings for joysticks with the given name.
-- name: the joystick name, as returned by glfw.get_joystick_name().
-- mappings: a table containing two arrays of strings, mappings.axes
--     and mappings.buttons, defining the names of axes and buttons
--     (e.g. mappings.axes = { 'a', b', 'x', 'y' } maps axes[1] to 'a',
--           axes[2] to 'b', and so on).
--
-- The module will use these informations for every joystick with this name,
-- to find the names of axes and buttons and pass them in the 'mapping'
-- variable when executing the callback for an axis or a button.
--
   -- Build reverse tables to retrieve the name from the axis (or button) number:
   local reverse_axes = {}
   for mapping, n in pairs(mappings.axes) do reverse_axes[n] = mapping end
   local reverse_buttons = {}
   for mapping, n in pairs(mappings.buttons) do reverse_buttons[n] = mapping end
   mappings.reverse_axes = reverse_axes
   mappings.reverse_buttons = reverse_buttons
   Mappings[name] = mappings
end

local function RemoveMappings(name, mappings) Mappings[name] = nil end

------------------------------------------------------------------------

local Callback = nil
local function SetCallback(func) Callback = func end
-- Set the callback to be called when a change in the status of the
-- joystick is detected.
--
-- The callback is called as func(id, action, n, val, mapping), where: 
--  - action = 'joins': joystick[id] just connected.
--  - action = 'leaves': joystick[id] just disconnected.
--  - action = 'axis': axis[n] of joystick[id] changed its value to
--              val (a number).
--  - action = 'button': button[n] of joystick[id] changed its value
--              to val ('press'|'release')
--  If the mappings for this type of joystick are defined (via the
--  add_mappings() function), then the mapping variable contains the
--  name of the affected axis or button, otherwise it is nil.
--  If action is 'joins' or 'leaves', then n, val and mapping are nil.
--

local MAX_JOYSTICK = 16
local Joystick = {} -- all joysticks, by their id (1..MAX_JOYSTICK)
local Present = {} -- only present joysticks

local function ResetJoystick(id)
   local joystick = Joystick[id]
   joystick.present = false
   joystick.id = id
-- joystick.name = keep old name (may be useful on leaves)
   joystick.axes = {}
   joystick.buttons = {}
   joystick.mappings = NoMappings
end

for id = 1, MAX_JOYSTICK do
   Joystick[id] = {}
   ResetJoystick(id)
   Joystick[id].name = "???"
end

local function Joins(id)
   local joystick = Joystick[id]
   joystick.present = true
   joystick.id = id
   joystick.name = get_joystick_name(id)
   joystick.axes = {get_joystick_axes(id)}
   joystick.buttons = {get_joystick_buttons(id)}
   joystick.mappings = Mappings[joystick.name] or NoMappings
   Present[id] = joystick
   if Callback then Callback(id, 'joins') end
end

local function Leaves(id)
   ResetJoystick(id)
   Present[id] = nil
   if Callback then Callback(id, 'leaves') end
end

local function Detect(off)
-- Start detecting joysticks that join or leave.
   if off == 'off' then
      glfw.set_joystick_callback('off')
      return
   end
   -- First, check all joysticks to update their status (e.g. to
   -- detect those that were already connected before this function
   -- was called, which the callback misses).
   local present
   for id, joystick in ipairs(Joystick) do
      present = joystick_present(id)
      if present ~= joystick.present then
         if present then Joins(id) else Leaves(id) end
      end
   end
   -- Set the callback to detect joins/leaves from now on
   glfw.set_joystick_callback(function(id, event)
      local joystick = Joystick[id]
      if not joystick then return end
      local present = (event == 'connected')
      if present == joystick.present then return end -- nothing new
      if present then Joins(id) else Leaves(id) end
   end)
end

local function Poll()
-- Polls for values of axes and buttons, and checks for value
-- changes. Executes the callback once per detected value change.
-- This function should be called at every event loop iteration.
   for id, joystick in pairs(Present) do
      local old_axes = joystick.axes
      joystick.axes = {get_joystick_axes(id)}
      local old_buttons = joystick.buttons
      joystick.buttons = {get_joystick_buttons(id)}
      if not Callback then break end
      local mappings = joystick.mappings.axes
      for n, val in ipairs(joystick.axes) do
         if val ~= old_axes[n] then
            Callback(id, 'axis', n, val, mappings[n])
         end
      end
      local mappings = joystick.mappings.buttons
      for n, val in ipairs(joystick.buttons) do
         if val ~= old_buttons[n] then
            Callback(id, 'button', n, val, mappings[n])
         end
      end
   end
end

local function Info(id)
-- If joystick[id] is not present, returns nil.
-- If it is present, returns its name, the number of axes, and
-- the number of buttons it has.
   local joystick = Joystick[id]
   if joystick.present then return end
   return joystick.name, #joystick.axes, #joystick.buttons
end

local function Name(id)
-- Returns the name of joystick[id]
   local joystick = Joystick[id]
   if not joystick then return end
   return joystick.name
end

local function Axes(id)
-- Returns a reference to the table of current values for the axes
-- of joystick[id].
   local joystick = Joystick[id]
   if not joystick then return end
   return joystick.axes
end

local function Buttons(id)
-- Returns a reference to the table of current values for the buttons
-- of joystick[id].
   local joystick = Joystick[id]
   if not joystick then return end
   return joystick.buttons
end

local function Axis(id, n)
-- Rteurns the current value for axis[n] of joystick[id].
-- n may be given as a name, if mappings for this joystick are defined.
   local joystick = Joystick[id]
   if not joystick then return end
   local n = type(n) == "number" and n or joystick.mappings.reverse_axes[n]
   return joystick.axes[n]
end

local function Button(id, n)
-- Rteurns the current value for button[n] of joystick[id].
-- n may be given as a name, if mappings for this joystick are defined.
   local joystick = Joystick[id]
   if not joystick then return end
   local n = type(n) == "number" and n or joystick.mappings.reverse_buttons[n]
   return joystick.buttons[n]
end

return {
   add_mappings = AddMappings,
   remove_mappings = RemoveMappings,
   set_callback = SetCallback,
   detect = Detect,
   poll = Poll,
   info = Info,
   axes = Axes,
   name = Name,
   buttons = Buttons,
   axis = Axis,
   button = Button,
}

