#[
 A 2D scene

 This code is licensed under the MIT license
]#
import std/times
import pixie, boxy, opengl
import ./[fontmgr, drawable, canvas, camera]

type Scene* = ref object
  bxContext*: Boxy
  canvas*: Canvas
  tree*: seq[Drawable]
  camera*: Camera

  fontManager*: FontManager

  minimized: bool
  maximized: bool

  # window lib-agnostic way of getting delta time
  lastTime: float
  drawIds*: seq[string]

  lastImageId: string

proc getDt*(scene: Scene): float =
  let time = cpuTime() - scene.lastTime
  time

proc onResize*(scene: Scene, nDimensions: tuple[w, h: int]) =
  scene.canvas.width = nDimensions.w
  scene.canvas.height = nDimensions.h
  scene.canvas.image = newImage(nDimensions.w, nDimensions.h)
  scene.canvas.image.fill(rgba(255, 255, 255, 255))
 
  for drawObj in scene.tree:
    drawObj.markRedraw(true)

proc onMinimize*(scene: Scene) =
  if scene.minimized:
    return

  scene.maximized = false
  scene.minimized = true

proc onScroll*(scene: Scene, delta: Vec2) =
  scene.camera.scroll(delta)

proc onMaximize*(scene: Scene) =
  if scene.maximized:
    return

  scene.maximized = true
  scene.minimized = false

proc blit*(scene: Scene) =
  scene.bxContext.drawImage("background", vec2(0, 0))

  for i, drawObj in scene.tree:
    let id = $i

    drawObj.draw()
    scene.bxContext.addImage(id, drawObj.image)
    scene.bxContext.drawImage(id, scene.camera.apply(drawObj.position))
  
proc draw*(scene: Scene) =
  ## Clears the screen, blits all drawables to the screen and
  ## finishes a frame.
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glClearColor(0f, 0.5f, 0.5f, 1f)

  scene.bxContext.beginFrame(ivec2(scene.canvas.width.int32, scene.canvas.height.int32))
  scene.camera.update()
  scene.blit()
  scene.bxContext.endFrame()
  scene.bxContext.removeImage("background")
  scene.bxContext.addImage("background", scene.canvas.image)
  scene.lastTime = cpuTime()

proc newScene*(width, height: int): Scene =
  result = Scene(
    bxContext: newBoxy(),
    lastTime: 0f,
    tree: @[],
    fontManager: newFontManager(),
    camera: newCamera(),
    canvas: newCanvas(width, height),
  )
  var bg = newImage(width, height)
  bg.fill(rgba(255, 255, 255, 255))
  result.bxContext.addImage("background", bg)
