# requires: windy
import windy, unittest, opengl, ../src/ferusgfx

test "example compositor":
 const
  WIDTH = 1280
  HEIGHT = 720

 let window = newWindow("ferusgfx example compositor", ivec2(WIDTH, HEIGHT))
 window.makeContextCurrent()

 loadExtensions()

 let 
  scene = newScene(WIDTH, HEIGHT)
  text = "Hello World!"
  text2 = "This scene is fully rendered using ferusgfx!"

 window.onResize = proc() =
  scene.onResize(
   (w: window.size.x.int, h: window.size.y.int)
  )

 #[window.onScroll = proc() =
  scene.onScroll(window.scrollDelta.y)]#

 # Load a font
 scene.fontManager.load("Default", "tests/IBMPlexSans-Regular.ttf")

 var displayList = newDisplayList(scene)

 displayList.add(
  newTextNode(
   text,
   vec2(100f, HEIGHT / 2), 
   scene.tree.len.uint,
   scene.fontManager
  )
 )

 displayList.add(
  newTextNode(
   text2,
   vec2(100f, (HEIGHT / 2) + 20f),
   scene.tree.len.uint,
   scene.fontManager
  )
 )

 displayList.commit()
 while not window.closeRequested:
  let frameId = scene.blit()
  
  scene.draw(frameId)
  window.swapBuffers()
  pollEvents()
