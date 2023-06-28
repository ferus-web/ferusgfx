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

 proc render =
  let displayList = newDisplayList(scene)
  displayList.add(
   newTextNode(
    text,
    newVector2(0, 0), 
    scene.tree.len.uint
   )
  )

  displayList.commit()

 while not window.closeRequested:
  render()
  scene.draw()
  window.swapBuffers()
  pollEvents()