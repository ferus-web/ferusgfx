# requires: windy/glfw, lorem, colored_logger
import std/[logging, options, random]
import lorem, colored_logger, opengl, weave, ../src/ferusgfx

when defined(compositorUseWindy):
  import windy
else:
  import glfw
  import std/unicode

const
  WIDTH = 1280
  HEIGHT = 720

proc main {.inline.} =
  let logger = newColoredLogger()
  addHandler logger

  when defined(compositorUseWindy):
    let window = newWindow("ferusgfx example compositor - windy backend", ivec2(WIDTH, HEIGHT))
    window.makeContextCurrent()
  else:
    glfw.initialize()

    var c = DefaultOpenglWindowConfig
    c.title = "ferusgfx example compositor - glfw backend"
    
    var window = newWindow(c)

  loadExtensions()

  var scene = newScene(WIDTH, HEIGHT)
  scene.camera.setBoundaries(
    vec2(0, -300),
    vec2(0, 256 * 18)
  )
  
  when defined(compositorUseWindy):
    window.onResize = proc =
      scene.onResize((w: window.size.x.int, h: window.size.y.int))

    window.onScroll = proc =
      let delta = vec2(window.scrollDelta.x, window.scrollDelta.y)
      scene.onScroll(delta)

    window.onRune = proc(rune: Rune) =
      if rune.char == 'r':
        scene.fullDamage()
  else:
    window.windowSizeCb = proc(w: Window, size: tuple[w, h: int32]) =
      scene.onResize((w: size.w.int, h: size.h.int))

    window.mouseButtonCb = proc(w: Window, b: MouseButton, pressed: bool, mods: set[ModifierKey]) =
      if b == mbLeft:
        scene.onCursorClick(pressed, MouseClick.Left)
      elif b == mbRight:
        scene.onCursorClick(pressed, MouseClick.Right)

    window.scrollCb = proc(w: Window, offset: tuple[x, y: float64]) =
      scene.onScroll(
        vec2(offset.x, offset.y)
      )

    window.cursorPositionCb = proc(w: Window, pos: tuple[x, y: float64]) =
      scene.onCursorMotion(vec2(pos.x, pos.y))

    window.charCb = proc(window: Window, codepoint: Rune) =
      if codepoint.toUTF8() == "r":
        scene.fullDamage()

  # Load a font
  scene.fontManager.load("Default", "tests/IBMPlexSans-Regular.ttf")

  var displayList = newDisplayList(addr scene)

  var baseY = HEIGHT / 2
  
  randomize()
  for y in 0 .. 256:
    var pY = addr y
    let content = $pY[]
    baseY += 16
    let text = newTextNode(content, vec2(100f, baseY), scene.fontManager)

    displayList &=
      text

    displayList &=
      newTouchInterestNode(
        text.bounds,
        clickCb = (proc(button: MouseClick) =
          echo "click: " & $pY[]
          echo "button: " & $button
          echo "click at " & $text.position
        ),
        hoverCb = (proc() =
          echo "hover: " & $pY[]
          echo "hover at " & $text.position
        )
      )
  
  displayList.add(
    newGIFNode(
      "test_assets/test003.gif", #& $(rand(1 .. 3)) & ".gif",
      vec2(100f, baseY + 100f)
    )
  )

  displayList.commit()

  when defined(compositorUseWindy):
    while not window.closeRequested:
      scene.draw()
      window.swapBuffers()
    
      pollEvents()
  else:
    while not window.shouldClose:
      scene.draw()

      glfw.swapBuffers(window)
      glfw.pollEvents()

    window.destroy()
    glfw.terminate()

when isMainModule:
  main()
