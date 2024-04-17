# requires: windy, lorem, colored_logger
import std/[logging, options]
import windy, lorem, colored_logger, opengl, ../src/ferusgfx

const
  WIDTH = 1280
  HEIGHT = 720

proc main {.inline.} =
  let logger = newColoredLogger()
  addHandler logger
  let window = newWindow("ferusgfx example compositor", ivec2(WIDTH, HEIGHT))
  window.makeContextCurrent()

  loadExtensions()

  var scene = newScene(WIDTH, HEIGHT)
  scene.camera.setBoundaries(
    vec2(0, -300),
    vec2(0, 256 * 18)
  )

  window.onResize = proc() =
    scene.onResize((w: window.size.x.int, h: window.size.y.int))

  window.onScroll = proc() =
    let delta = vec2(window.scrollDelta.x, window.scrollDelta.y)
    scene.onScroll(delta)

  window.onRune = proc(rune: Rune) =
    if rune.char == 'r':
      scene.fullDamage()

  # Load a font
  scene.fontManager.load("Default", "tests/IBMPlexSans-Regular.ttf")

  var displayList = newDisplayList(addr scene)

  var baseY = HEIGHT / 2
 
  for y in 0 .. 256:
    let content = sentence()
    baseY += 16
    displayList.add(
      newTextNode(content, vec2(100f, baseY), scene.fontManager)
    )

  displayList.add(
    newImageNode(
      "test_assets/tux.png",
      vec2(100f, baseY + 100f)
    )
  )

  displayList.commit()
  while not window.closeRequested:
    scene.draw()
    window.swapBuffers()
    
    pollEvents()

when isMainModule:
  main()
