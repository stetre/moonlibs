-- ===========================================================================
-- Lua/MoonGLMATH Shell Calculator
-- ===========================================================================
--
-- Usage:  $ lua -i calculator.lua
--
-- Turns the Lua shell into a shell calculator, enhanced with facilities for
-- graphics math.
--
-- Functions and variable of the standard math library and of moonglmath are
-- made global, so that one can call (for example) sqrt instead of math.sqrt,
-- or vec3 instead of math.vec3.
--
-- The shell calculator also supports switching angle units from radians to
-- degrees and viceversa (see 'Angle units' below), and adds a few extra
-- functions (see 'Extras' below).
--
print("Lua/MoonGLMATH Shell Calculator")

-- Add the contents of the standard math library to the global space:
for k, t in pairs(math) do
   if _ENV[k] == nil then _ENV[k] = t end
end
print("- math library added to the global space")

-- Add the contents of the moonglmath library to the global space (if available):
ok, glmath = pcall(require, "moonglmath")
if not ok then
   print("- moonglmath not found")
else
   for k, t in pairs(glmath) do
      if _ENV[k] == nil then _ENV[k] = t end
   end
   print("- moonglmath library added to the global space")
end

-- Seed random() with the current time:
math.randomseed(os.time())  

------------------------------------------------------------------------------
-- Angle units (radians or degrees)
------------------------------------------------------------------------------
-- By default, the calculator uses angles in radians (same as standard Lua).
-- The following code allows to switch from radians to degrees and viceversa.
-- The trigonometric functions in the global space are overridden so that they
-- work corectly with the current unit.
ang_ = nil -- current angle units ('radians' or 'degrees')
torad_ = function(x) end -- converts x from ang_ to radians
toang_ = function(x) end -- converts x from radians to ang_

print_angle_units_ = function ()
-- Switch between 'rad' and 'deg' in trigonometric functions.
   if ang_ == "radians" then
      print("- angles are in radians (call degrees() to switch to degrees)")
   else
      print("- angles are in degrees (call radians() to switch to radians)")
   end
end

radians = function () -- switch to radians
   ang_ = "radians"
   torad_ = function (x) return x end -- convert to radians
   toang_ = function (x) return x end -- convert to the current angle units
   print_angle_units_()
end

degrees = function () -- switch to degrees
   ang_ = "degrees"
   torad_ = function (x) return math.rad(x) end -- convert to radians
   toang_ = function (x) return math.deg(x) end -- convert to the current angle units
   print_angle_units_()
end

radians()  -- set default

-- Override trigonometric functions so that they work with the
-- current units for angles (degree or radians)
sin = function (x) return math.sin(torad_(x)) end
cos = function (x) return math.cos(torad_(x)) end
tan = function (x) return math.tan(torad_(x)) end
acos = function (x) return toang_(math.acos(x)) end
asin = function (x) return toang_(math.asin(x)) end
atan = function (x) return toang_(math.atan(x)) end
atan2 = function (y,x) return toang_(math.atan2(y, x)) end

------------------------------------------------------------------------------
-- Extras
------------------------------------------------------------------------------

round = function(x) return math.floor(x + 0.5) end

fract = function(x) -- fractional part of x
-- e.g. fract(pi)  --> .14159265358978
-- e.g. fract(-pi) --> .85840734641021
   return x%1 -- see PIL3/3.1
   -- Alt: return x - floor(x)
end

int = function (x) -- integer part of x
-- e.g. int(pi)   --> 3
--      int(-pi)  --> -3
   return math.tointeger(x>=0 and (x - x%1) or (x + (-x%1)))
   -- Alt: return x >= 0 and floor(x) or ceil(x)
end

trunc = function(x, n) -- truncates x to n decimal digits
-- e.g. trunc(pi, 5) --> 3.14519
   return x >= 0 and x - x%10^-n or (x + (-x%10^-n)) 
end

e = math.exp(1)  -- Euler's (or Neper's number)
ln = log -- log (x [, base])     base=e by default
log10 = function (x) return math.log(x,10) end

