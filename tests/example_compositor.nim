# requires: windy, lorem

import windy, lorem, unittest, opengl, ../src/ferusgfx

test "example compositor":
  const
    WIDTH = 1280
    HEIGHT = 720

  let window = newWindow("ferusgfx example compositor", ivec2(WIDTH, HEIGHT))
  window.makeContextCurrent()

  loadExtensions()

  let scene = newScene(WIDTH, HEIGHT)

  window.onResize = proc() =
    echo "resize!!!!"
    scene.onResize((w: window.size.x.int, h: window.size.y.int))

  window.onScroll = proc() =
    let delta = vec2(window.scrollDelta.x, window.scrollDelta.y)
    scene.onScroll(delta)

  # Load a font
  scene.fontManager.load("Default", "tests/IBMPlexSans-Regular.ttf")

  var displayList = newDisplayList(scene)

  let baseY = HEIGHT / 2
  
  for y in 0 .. 1:
    displayList.add(
      newTextNode(sentence(), vec2(100f, baseY + float32(y * 16)), scene.tree.len.uint, scene.fontManager)
    )

  displayList.commit()
  while not window.closeRequested:
    scene.draw()
    window.swapBuffers()
    pollEvents()
