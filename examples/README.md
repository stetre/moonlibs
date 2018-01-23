
# MoonLibs Examples

This directory contains a few examples that show how one may combine different
libraries from the [MoonLibs](https://github.com/stetre/moonlibs) collection to
perform basic tasks (please keep in mind that the examples do not aim to show
the *best* way to perform those tasks, however).

* [**joysticks**](#joysticks): get input from joysticks.
* [**shapes**](#shapes): render simple 2D shapes.
* [**sounds**](#sounds): play sound samples.
* [**sprites**](#sprites): render 2D sprites.
* [**text**](#text): render text.
* [**timer**](#text): a simple frame timer.

----

## joysticks

This example shows how to detect and use joysticks and gamepads, using
[MoonGLFW](https://github.com/stetre/moonglfw) to implement a callback interface.

## shapes

This example shows how one may render simple 2D shapes, such as points, lines, rectangles, and circles,
using 
[MoonGL](https://github.com/stetre/moongl),
[MoonGLFW](https://github.com/stetre/moonglfw), and
[MoonGLMATH](https://github.com/stetre/moonglmath).

## sounds

This example shows how to load sound samples from file using
[MoonSndFile](https://github.com/stetre/moonsndfile), and how to play them with
[MoonAL](https://github.com/stetre/moonal).

The sound samples used in the example are taken from the 
[8 Bit Sound Effects Library](https://opengameart.org/content/8-bit-sound-effects-library)
([CC-BY 3.0](https://creativecommons.org/licenses/by/3.0/) licensed), by Little Robot Sound Factory.


## sprites

This example shows how one can render 2D sprites using 
[MoonGL](https://github.com/stetre/moongl),
[MoonGLFW](https://github.com/stetre/moonglfw), and
[MoonGLMATH](https://github.com/stetre/moonglmath). The example also uses
[MoonImage](https://github.com/stetre/moonimage) to load the textures from file.

The sprite renderer is based on the [tutorial](https://learnopengl.com/#!In-Practice/2D-Game/Rendering-Sprites) by Joey de Vries. The textures used in the example are also from [learnopengl.com](https://learnopengl.com) and are covered by the [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/) license.

## text

This example shows how one can render text using 
[MoonGL](https://github.com/stetre/moongl),
[MoonGLFW](https://github.com/stetre/moonglfw), and
[MoonGLMATH](https://github.com/stetre/moonglmath). The example also shows how to use
[MoonFreeType](https://github.com/stetre/moonfreetype) to load fonts from TTF files.

The text renderer is again based on a [tutorial](https://learnopengl.com/#!In-Practice/Text-Rendering)
by Joey de Vries, from his awesome [learnopengl.com](https://learnopengl.com) book.

The font used in this example is the
[Nobile Font Free](https://www.fontsquirrel.com/fonts/Nobile) ([SIL Open Font License v1.10](https://www.fontsquirrel.com/license/Nobile) licensed), by Vernon Adams.

## timer

This example implements a simple but useful frame timer, using 
[MoonGLFW](https://github.com/stetre/moonglfw).

The frame timer is derived from the [Cyclone Physics engine](https://github.com/idmillington/cyclone-physics) (MIT license), by Ian Millington.

