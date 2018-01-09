#!/usr/bin/env lua
-- Sound engine usage example.

local sound = require("sound")

local function sleep(seconds)
-- Gross sleep function (sleeps for seconds +/- 1)
   local exptime = os.time() + seconds
   while os.time() < exptime do end
end

-- Init the sound engine
sound.init()

-- Create a few sound samples
local Shoot = sound.new("Shoot_00.wav")
local Explosion = sound.new("Explosion_00.wav")
local Win = sound.new("Jingle_Win_00.wav")

-- Play sound samples at different times
Shoot:play()
sleep(2)
Explosion:play()
sleep(2)
Shoot:play()
sleep(2)
Explosion:play()
sleep(2)
Win:play()
sleep(3)

