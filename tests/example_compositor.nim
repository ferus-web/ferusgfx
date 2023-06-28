# requires: windy
import windy, ../src/ferusgfx

const
 WIDTH = 1280
 HEIGHT = 720

let window = newWindow("ferusgfx example compositor", ivec(WIDTH, HEIGHT))
window.makeContextCurrent()

let scene = newScene(WIDTH, HEIGHT)

proc render =

while not window.closeRequested:
  render()
  scene.draw()
  pollEvents()