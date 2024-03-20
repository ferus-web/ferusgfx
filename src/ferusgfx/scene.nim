#[
 A 2D scene

 This code is licensed under the MIT license
]#
import std/[strutils, times]
import pixie, boxy, librng, opengl
import ./[fontmgr, drawable, canvas, camera]

var ALPHABETS: seq[char] = @[]

# populate ALPHABETS
for a in 'a' .. 'z':
  ALPHABETS.add(a)

for a in 'A' .. 'Z':
  ALPHABETS.add(a)

for n in '0' .. '9':
  ALPHABETS.add(n)

proc genImageId(rng: RNG): string =
  var x = ""

  for _ in 0 .. 16:
    x &= rng.choice(ALPHABETS)

  x

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

  rng: RNG

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

  for drawObj in scene.tree:
    var id = genImageId(scene.rng)

    while id in scene.drawIds:
      `=destroy`(id)
      id = genImageId(scene.rng)

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
  scene.bxContext.addImage("background", scene.canvas.image)
  scene.lastTime = cpuTime()

proc newScene*(width, height: int): Scene =
  result = Scene(
    bxContext: newBoxy(),
    lastTime: 0f,
    tree: @[],
    fontManager: newFontManager(),
    rng: newRNG(),
    camera: newCamera(),
    canvas: newCanvas(width, height),
  )
  var bg = newImage(width, height)
  bg.fill(rgba(255, 255, 255, 255))
  result.bxContext.addImage("background", bg)
