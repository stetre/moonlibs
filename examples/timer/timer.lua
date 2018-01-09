-- Frame timer.
--
-- All timestamps and time intervals are in seconds.
--
-- Derived from Cyclone-Physics engine, by Ian Millington
-- (https://github.com/idmillington/cyclone-physics )

local glfw = require("moonglfw")
local now = glfw.now

local start_time -- reset_time, relative to now()'s time zero
local fn  -- current frame number
local ft  -- current frame time, relative to start_time
local dt  -- current frame duration
local spf -- 1/fps, seconds per frame (recency weighted average of frame duration)
local paused -- true if the timer is paused, false otherwise

local function Reset()
   start_time = now()
   dt, ft, fn, spf, paused = 0.0, 0.0, 0, 0.0, false
end

local function Info()
   return dt, ft, fn, 1/spf, paused 
end

local function ToString()
   return string.format("dt=%.3f ft=%.3f fn=%d, fps=%.1f paused=%s", dt, ft, fn, 1/spf, tostring(paused))
end

local function Update()
-- Update the timing system. Call this once per frame.
   if not paused then fn = fn + 1 end
   local tmp = now() - start_time
   dt, ft = tmp - ft, tmp
   if fn > 1 then
      spf = spf <= 0 and dt or .99*spf + .01*dt -- RWA over 100 frames
   end
   return dt, ft, fn, 1/spf, paused 
end

Reset()

return {
   reset = Reset,
   update = Update,
   now = now,
   info = Info,
   tostring = ToString,
   pause = function() paused = true end,
   resume = function() paused = false end,
   paused = function() return paused end,
   start_time = function() return start_time end,
   fn = function() return fn end,
   ft = function() return ft end,
   dt = function() return dt end,
   fps = function() return 1/spf end,
}

