-- Sound engine.

local sf = require("moonsndfile")
local al = require("moonal")

local Device, Context

local function Init()
-- Initialize the module.
   assert(not Device, "double call")
   Device = al.open_device()
   Context = al.create_context(Device)
end

local function Load(filename)
-- Load sound data and metadata from the given sound file.
   local sndfile, info = sf.open(filename, "r")
   local data = sndfile:read('float', info.frames)
   local format
   if info.channels == 1 then format = 'mono float32'
   elseif info.channels == 2 then format = 'stereo float32'
   else error("unexpected number of channels in sound file")
   end
   sf.close(sndfile) -- we don't need it any more
   return data, format, info.samplerate
end

local Sample = {}
local function NewSample(filename)
-- Create a new sound sample from the given sound file.
-- A 'sound sample' here is an object holding a dedicated OpenAL source,
-- whose buffer is set with the data from the given file.
-- The sample object has methods to play/pause/stop/rewind it.
   local sample = setmetatable({}, {__index = Sample})
   local data, format, srate = Load(filename)
   local buffer = al.create_buffer(Context)
   al.buffer_data(buffer, format, data, srate)
   data = nil; collectgarbage()
   local source = al.create_source(Context)
   source:set('buffer', buffer)
   sample.source = source
   sample.buffer = buffer
   return sample
end

function Sample.delete(sample)
   al.delete_source(sample.source)
   al.delete_buffer(sample.buffer)
   sample.source, sample.buffer = nil, nil
end

function Sample.play(sample, loop)
-- Play the sound sample, optionally looping it (if loop=true).
   sample.source:set('looping', loop and true or false)
   sample.source:play()
end

function Sample.stop(sample) sample.source:stop() end
function Sample.pause(sample) sample.source:pause() end
function Sample.rewind(sample) sample.source:rewind() end

return {
   init = Init,
   new = NewSample,
}

