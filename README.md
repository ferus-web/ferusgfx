# ferusgfx - a high performance rendering engine
![ferusgfx's example compositor](https://github.com/ferus-web/ferusgfx/main/media/example_compositor.jpg)

ferusgfx is a rendering engine made for the Ferus web engine, made with the concept of "display lists" in mind. \

It uses OpenGL as its primary backend, but there are plans to add Vulkan support later on.

# Installation
ferusgfx can be installed directly from Nimble. It requires a recent Nim version (>=2.0).
```bash
# nimble install ferusgfx
```

# How it works
ferusgfx's main object is a `Scene`. It essentially acts as the rendering context and contains a tree full of `Drawable` objects (or types descending from `Drawable`). \
The tree is not meant to be edited manually, rather, you should use `DisplayList`(s) to manipulate the scene tree and perform actions like adding drawables, removing them, etc. \
And as expected, `Drawable`s are not redrawn each frame unless they are marked as needing a redraw (or you call `fullDamage` on the scene).

# Features
ferusgfx is primarily meant for applications that show a lot of text and images. It can be used for a plethora of things, ranging from a PDF reader, an image viewer, a web engine (duh) and other things. Here is what it currently does.
- Render stuff for you, providing a neat little API that ensures you don't need to have a headache fighting with lower level APIs (it itself is an abstraction over boxy).
- Provide a camera with smooth scrolling support.

# Roadmap
- Fetch fonts from the system instead of making the programmer manually specify them.
- Vulkan rendering (not coming soon!)

# Bare bones example
A more fleshed out example can be seen in `tests/example_compositor.nim`. \
[windy](https://github.com/treeform/windy) is used here but ferusgfx is window-library-agnostic so anything can be used here.
```nim
import ferusgfx, windy, opengl

const
  WIDTH = 1280
  HEIGHT = 720

let window = newWindow("ferusgfx barebones compositor", ivec2(WIDTH, HEIGHT))
window.makeContextCurrent()

loadExtensions()

var scene = newScene(WIDTH, HEIGHT)

# hooking up windy events to ferusgfx's internal ones
window.onResize = proc() =
  scene.onResize((w: window.size.x.int, h: window.size.y.int))

window.onScroll = proc() =
  # ferusgfx sends this info to the camera, which applies some math to scroll the view
  # each frame a little bit, making it pretty smooth.
  scene.onScroll(
    vec2(window.scrollDelta.x, window.scrollDelta.y)
  )

scene.fontManager.load("Default", "/path/to/your/font.font_extension")

var displayList = newDisplayList(addr scene) # pass a pointer to the scene
displayList.add(
  newTextNode(
    "This is a very barebones example of what ferusgfx can do.",
    vec2(100f, 300f),
    scene.fontManager
  )
)

displayList.add(
  newImageNode(
    "/path/to/your/image.image_extension",
    vec2(100f, 800f)
  )
)

displayList.commit() # commit our changes, the scene tree will be mutated by the display list accordingly.

while not window.closeRequested:
  # tell the scene to draw itself
  scene.draw()
  
  # windy stuff
  window.swapBuffers()
  pollEvents()
```
