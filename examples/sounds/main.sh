#!/bin/bash
# Executes the lua script with the PulseAudio OSS wrapper (see man padsp(1) for details).
# Use this instead of the plain Lua interpreter if, when running the example on GNU/Linux,
# you get an error such as "Could not open /dev/dsp (etc.)", or if sounds are not played
# properly.

padsp lua main.lua
