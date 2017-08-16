## MoonLibs - Graphics and Audio Lua Libraries

A collection of libraries for graphics and audio programming in [Lua](https://www.lua.org) (>= 5.3),
mostly bindings to popular C/C++ libraries.

They currently run 
[on GNU/Linux](#installing-on-ubuntu) and (most of them) [on Windows](#installing-on-windows) with MSYS2/MinGW-w64.

The libraries do not depend on each other, so they can be selectively installed.

_Author:_ _[Stefano Trettel](https://www.linkedin.com/in/stetre)_

[![Lua logo](./powered-by-lua.gif)](https://www.lua.org/)

#### Rendering
* [**MoonGL**](https://github.com/stetre/moongl) - bindings to **OpenGL 3.x - 4.x**
([manual](https://stetre.github.io/moongl/doc/index.html)).
* [**MoonVulkan**](https://github.com/stetre/moonvulkan) - bindings to **Vulkan** ([manual](https://stetre.github.io/moonvulkan/doc/index.html)).

#### Windowing and GUI

* [**MoonFLTK**](https://github.com/stetre/moonfltk) - bindings to the **Fast Light Toolkit (FLTK)**
([manual](https://stetre.github.io/moonfltk/doc/index.html)).
* [**MoonGLFW**](https://github.com/stetre/moonglfw) - bindings to **GLFW**
([manual](https://stetre.github.io/moonglfw/doc/index.html)).
* [**MoonGLUT**](https://github.com/stetre/moonglut) - bindings to **FreeGLUT**
([manual](https://stetre.github.io/moonglut/doc/index.html)).

#### Math
* [**MoonGLMATH**](https://github.com/stetre/moonglmath) - **graphics math library** for MoonGL
([manual](https://stetre.github.io/moonglmath/doc/index.html)).

#### Asset loading
* [**MoonAssimp**](https://github.com/stetre/moonassimp) - bindings to the **Open Asset Import Library (Assimp)**
([manual](https://stetre.github.io/moonassimp/doc/index.html)). 
* [**MoonSOIL**](https://github.com/stetre/moonsoil) - bindings to the **Simple OpenGL Image Library (SOIL)**
([manual](https://stetre.github.io/moonsoil/doc/index.html)).

#### Text rendering
* [**MoonFreeType**](https://github.com/stetre/moonfreetype) - bindings to the **FreeType** font rendering library
([manual](https://stetre.github.io/moonfreetype/doc/index.html)).
* [**MoonFonts**](https://github.com/stetre/moonfonts) - bitmap fonts, bindings to **STB fonts**
([manual](https://stetre.github.io/moonfonts/doc/index.html)).

#### Audio
* [**MoonSndFile**](https://github.com/stetre/moonsndfile) - bindings to **libsndfile**
([manual](https://stetre.github.io/moonsndfile/doc/index.html)).
* [**MoonAL**](https://github.com/stetre/moonal) - bindings to **OpenAL**
([manual](https://stetre.github.io/moonal/doc/index.html)).
* [**LuaJACK**](https://github.com/stetre/luajack) - bindings to the **JACK Audio Connection Kit**
([manual](https://stetre.github.io/luajack/doc/index.html)).

---

#### Installation instructions

* [Installing on Ubuntu](#installing-on-ubuntu).
* [Installing on Windows](#installing-on-windows).

---

#### Installing on Ubuntu

The following instructions show how to install the libraries on Ubuntu.
To install on a Linux distribution other than Ubuntu, replace _apt_ with the package manager used by
the distribution.

##### Install the toolchain and Lua

Install the following packages (if you don't have them already installed):

```bash
$ sudo apt install make
$ sudo apt install binutils
$ sudo apt install gcc
$ sudo apt install git
```

Install the [latest version](https://www.lua.org/download.html) of Lua:

```bash
$ sudo apt install libreadline-dev
$ wget https://www.lua.org/ftp/lua-5.3.4.tar.gz
$ tar -zxpvf lua-5.3.4.tar.gz
$ cd lua-5.3.4
lua-5.3.4$ make linux
lua-5.3.4$ sudo make install
```

##### Install a library

The following instructions show how to install MoonFLTK, but the same procedure applies to any other any other MoonLibs library.

First, install any dependency needed by the library. MoonFLTK needs FLTK, which you can install by typing:

```bash
$ sudo apt install libfltk1.3-dev
```

Then clone the library (or, if you prefer, download the latest release tarball and decompress, it),
enter its base directory, compile, and install:

```bash
$ git clone https://github.com/stetre/moonfltk
$ cd moonfltk
moonfltk$ make
moonfltk$ sudo make install
```

To uninstall the library:

```bash
moonfltk$ sudo make uninstall
```

The same procedure we saw here for MoonFLTK applies to any other MoonLibs library. Below is a list of the dependencies needed by the different libraries:

```bash
$ sudo apt install libfltk1.3-dev     # needed only by MoonFLTK
$ sudo apt install libglfw3-dev       # needed only by MoonGLFW
$ sudo apt install freeglut3-dev      # needed only by MoonGLUT
$ sudo apt install libglew-dev        # needed only by MoonGL
$ sudo apt install libassimp-dev      # needed only by MoonAssimp
$ sudo apt install libfreetype6-dev   # needed only by MoonFreeType
$ sudo apt install libsndfile1-dev    # needed only by MoonSndFile
$ sudo apt install libopenal-dev      # needed only by MoonAL
$ sudo apt install libjack-jackd2-dev # needed only by LuaJack
```
##### Running the examples

Every MoonLibs library comes with a few examples, which are located in the _example/_ directory of the
source package (or in its subdirectories). These examples are usually Lua scripts that can be executed with the standard Lua interpreter.

To run, say, the _fltk/valuators.lua_ example, assuming the MoonFLTK source package is located in _/home/ste/moonfltk_:

```bash
$ cd /home/ste/moonfltk/examples/fltk
fltk$ lua valuators.lua
```

---

#### Installing on Windows

The following instructions show how to install the libraries on Windows with MSYS/MinGW-w64.

##### Install MSYS/MinGw-w64

Download the [MSYS2 installer](https://msys2.github.io/) and
follow the instructions from the download page.

##### Install the toolchain and Lua

In the following, we'll assume that you installed MSYS2 in the default location _C:\msys32_. If not, change the paths below accordingly to your chosen location.

Open a MinGW shell (using the shell launcher _C:\msys32\mingw32.exe_ or _mingw64.exe_, depending on your architecture), and install the following packages:

```bash
$ pacman -S make
$ pacman -S tar
$ pacman -S git
$ pacman -S ${MINGW_PACKAGE_PREFIX}-gcc
$ pacman -S ${MINGW_PACKAGE_PREFIX}-lua
```

Append one of the following two paths, depending on your architecture, to the PATH environment variable:
- _C:\msys32\mingw32\bin_   (corresponding to _/mingw32/bin_ under MSYS2, for 32-bit), or
- _C:\msys32\mingw64\bin_   (corresponding to _/mingw64/bin_ under MSYS2, for 64-bit).

(To do so, right click _Computer -> Properties -> Advanced System Settings ->  Environment variables_,
then search for the PATH or Path system variable, edit it, and append a semicolon (;) followed by the path).

Now your environment is ready and you should be able to execute the Lua interpreter from the Windows command prompt, by just typing _lua_ in it (to exit from the interpreter, type _os.exit()_ or _Ctrl-C_ in it).

##### Install a library

The following instructions show how to install MoonFLTK, but the same procedure applies to any other any other MoonLibs library, provided it is supported on Windows.

First, open a MinGW shell and from there install any dependency needed by the library. MoonFLTK needs FLTK, which you can install by typing:

```bash
$ pacman -S ${MINGW_PACKAGE_PREFIX}-fltk
```

Then clone the library (or, if you prefer, download the latest release tarball and decompress, it),
enter its base directory, compile, and install:

```bash
$ git clone https://github.com/stetre/moonfltk
$ cd moonfltk
moonfltk$ make
moonfltk$ make install
```

To uninstall the library:

```bash
moonfltk$ make uninstall
```

The same procedure we saw here for MoonFLTK applies to any other MoonLibs library, provided it is supported on Windows. Below is a list of the dependencies needed by the different libraries:

```bash
$ pacman -S ${MINGW_PACKAGE_PREFIX}-fltk        # needed only by MoonFLTK
$ pacman -S ${MINGW_PACKAGE_PREFIX}-glfw        # needed only by MoonGLFW
$ pacman -S ${MINGW_PACKAGE_PREFIX}-freeglut    # needed only by MoonGLUT
$ pacman -S ${MINGW_PACKAGE_PREFIX}-glew        # needed only by MoonGL
$ pacman -S ${MINGW_PACKAGE_PREFIX}-assimp      # needed only by MoonAssimp
$ pacman -S ${MINGW_PACKAGE_PREFIX}-freetype    # needed only by MoonFreeType
$ pacman -S ${MINGW_PACKAGE_PREFIX}-sndfile     # needed only by MoonSndFile
$ pacman -S ${MINGW_PACKAGE_PREFIX}-openal      # needed only by MoonAL
```

##### Running the examples

Every MoonLibs library comes with a few examples, which are located in the _example/_ directory of the
source package (or in its subdirectories). These examples are usually Lua scripts that can be executed with the standard Lua interpreter, either in a MinGW shell or from a Windows command prompt.

Let's assume the MoonFLTK source package is located in _/home/ste/moonfltk_ under MSYS2, which corresponds to the _C:\msys32\home\ste\moonfltk_ folder under Windows.

To run, say, the _fltk/valuators.lua_ example in a MinGW shell:

```bash
$ cd /home/ste/moonfltk/examples/fltk
fltk$ lua valuators.lua
```

To run the same example from a Windows command prompt:

```dos
C:\> cd \msys32\home\ste\moonfltk\examples\fltk
C:\msys32\home\ste\moonfltk\examples\fltk> lua valuators.lua
```

