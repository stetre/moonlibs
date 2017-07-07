## MoonLibs - Graphics and Audio Lua Libraries

A collection of libraries for graphics and audio programming in [Lua](https://www.lua.org) (>= 5.3),
mostly bindings to popular C/C++ libraries.

They currently run 
[on GNU/Linux](#installing-on-ubuntu) (and a few of them also [on Windows with MSYS2/MinGW-w64](#installing-on-windows)).

The libraries do not depend on each other, so they can be selectively installed.

_Author:_ _[Stefano Trettel](https://www.linkedin.com/in/stetre)_

[![Lua logo](./powered-by-lua.gif)](https://www.lua.org/)

#### Rendering
* [MoonGL](https://github.com/stetre/moongl) - bindings to OpenGL 3.x
([manual](https://stetre.github.io/moongl/doc/index.html)).
* [MoonVulkan](https://github.com/stetre/moonvulkan) (GNU/Linux only) - bindings to Vulkan ([manual](https://stetre.github.io/moonvulkan/doc/index.html)).

#### Windowing and GUI

* [MoonFLTK](https://github.com/stetre/moonfltk) - bindings to the Fast Light Toolkit
([manual](https://stetre.github.io/moonfltk/doc/index.html)).
* [MoonGLFW](https://github.com/stetre/moonglfw) - bindings to GLFW
([manual](https://stetre.github.io/moonglfw/doc/index.html)).
* [MoonGLUT](https://github.com/stetre/moonglut) - bindings to FreeGLUT
([manual](https://stetre.github.io/moonglut/doc/index.html)).

#### Math
* [MoonGLMATH](https://github.com/stetre/moonglmath) - graphics math library for MoonGL
([manual](https://stetre.github.io/moonglmath/doc/index.html)).

#### Asset loading
* [MoonAssimp](https://github.com/stetre/moonassimp) - bindings to the Open Asset Import Library
([manual](https://stetre.github.io/moonassimp/doc/index.html)). 
* [MoonSOIL](https://github.com/stetre/moonsoil) - bindings to the Simple OpenGL Image Library
([manual](https://stetre.github.io/moonsoil/doc/index.html)).

#### Text rendering
* [MoonFreeType](https://github.com/stetre/moonfreetype) - bindings to the FreeType font rendering library
([manual](https://stetre.github.io/moonfreetype/doc/index.html)).
* [MoonFonts](https://github.com/stetre/moonfonts) - bitmap fonts, bindings to STB fonts
([manual](https://stetre.github.io/moonfonts/doc/index.html)).

#### Audio
* [LuaJACK](https://github.com/stetre/luajack) (GNU/Linux only) - bindings to the JACK Audio Connection Kit
([manual](https://stetre.github.io/luajack/doc/index.html)).

---

#### Installing on Ubuntu

The following instructions show how to install the libraries on Ubuntu
(to install on a Linux distribution other than Ubuntu, replacing apt-get with the package manager it uses
should work).

Install the [latest version](https:www.lua.org/download.html) of Lua:

```sh
$ sudo apt-get install libreadline-dev
$ wget https://www.lua.org/ftp/lua-5.3.3.tar.gz
$ tar -zxpvf lua-5.3.3.tar.gz
$ cd lua-5.3.3
lua-5.3.3$ make linux
lua-5.3.3$ sudo make install
```

Install the dependencies:

```sh
$ sudo apt-get install libfltk1.3-dev     # needed only by MoonFLTK
$ sudo apt-get install libglfw3-dev       # needed only by MoonGLFW
$ sudo apt-get install freeglut3-dev      # needed only by MoonGLUT
$ sudo apt-get install libglew-dev        # needed only by MoonGL
$ sudo apt-get install libassimp-dev      # needed only by MoonAssimp
$ sudo apt-get install libfreetype6-dev   # needed only by MoonFreeType
$ sudo apt-get install libjack-jackd2-dev # needed only by LuaJack
```

Install a MoonXXX library (MoonXXX is one of MoonGL, MoonGLFW, etc):

```sh
$ git clone https://github.com/stetre/moonxxx
$ cd moonxxx
moonxxx$ make
moonxxx$ sudo make install
```

To uninstall it:

```sh
moonxxx$ sudo make uninstall
```
---

#### Installing on Windows

The following instructions show how to install the libraries on Windows with MSYS/MinGW-w64.

Download the [MSYS2 installer](https://msys2.github.io/) and
follow the instructions from the download page.

From the MSYS2 MinGW-w64 Win32 or Win64 shell:

```sh
$ pacman -S make tar git 
$ pacman -S ${MINGW_PACKAGE_PREFIX}-gcc
$ pacman -S ${MINGW_PACKAGE_PREFIX}-lua
```

Assuming MSYS2 is installed in _C:\msys32_, append the following path
to the PATH environment variable:
- _C:\msys32\mingw32\bin_   (corresponding to _/mingw32/bin_ under MSYS2, for 32-bit), or
- _C:\msys32\mingw64\bin_   (corresponding to _/mingw64/bin_ under MSYS2, for 64-bit).

(To edit PATH, right click My Computer -> Properties -> Advanced ->  Environment variables).

Install the dependencies:

```sh
$ pacman -S ${MINGW_PACKAGE_PREFIX}-fltk        # needed only by MoonFLTK
$ pacman -S ${MINGW_PACKAGE_PREFIX}-glfw        # needed only by MoonGLFW
$ pacman -S ${MINGW_PACKAGE_PREFIX}-freeglut    # needed only by MoonGLUT
$ pacman -S ${MINGW_PACKAGE_PREFIX}-glew        # needed only by MoonGL
$ pacman -S ${MINGW_PACKAGE_PREFIX}-assimp      # needed only by MoonAssimp
$ pacman -S ${MINGW_PACKAGE_PREFIX}-freetype    # needed only by MoonFreeType
```

Install a MoonXXX library (MoonXXX is one of MoonGL, MoonGLFW, etc):

```sh
$ git clone https://github.com/stetre/moonxxx
$ cd moonxxx
moonxxx$ make
moonxxx$ make install
```

To uninstall it:

```sh
moonxxx$ make uninstall
```


