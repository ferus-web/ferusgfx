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
  text = "ferusgfx is cool!"

 # Load a font
 scene.fontManager.load("Default", "tests/IBMPlexSans-Regular.ttf")

 proc render =
  let displayList = newDisplayList(scene)
  displayList.add(
   newTextNode(
    text,
    newVector2(600, 480), 
    scene.tree.len.uint,
    scene.fontManager
   )
  )

  displayList.commit()

 while not window.closeRequested:
  render()
  scene.draw()
  window.swapBuffers()
  pollEvents()