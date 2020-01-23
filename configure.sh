#!/bin/sh
# A shell script that sets the LUA_PATH and LUA_CPATH environment variables,
# adding to them the paths to where the MoonLibs libraries are installed.
#
# This script can be used to configure the shell where to run examples and
# applications that use the libraries, running it as:
# $ . configure.sh
#
# (Don't forget the leading dot, otherwise the script won't be executed in the
# shell you want to configure, but in a child shell).
#
# For this to work, the PREFIX and LUAVER variables below must be set to the
# same values used when building the libraries (see the MoonLibs README).

tmp()
    {
    local PREFIX="/usr/local" 
    local LUAVER="5.3"

    # Add the path to .lua modules to LUA_PATH
    local TMP="$PREFIX/share/lua/"$LUAVER"/?.lua;;"
    case :$LUA_PATH: in
     *$TMP*) ;; # already in
     *) export LUA_PATH=$LUA_PATH$TMP;;
    esac

    # Add the path to .so modules to LUA_CPATH
    local TMP="$PREFIX/lib/lua/"$LUAVER"/?.so;;"
    case :$LUA_CPATH: in
     *$TMP*) ;; # already in
     *) export LUA_CPATH=$LUA_CPATH$TMP
    esac
    }

tmp
unset tmp
