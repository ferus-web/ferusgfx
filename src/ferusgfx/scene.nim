##
## A 2D scene
##
## This code is licensed under the MIT license
##

import std/[options, times, logging]
import pixie, boxy, opengl, weave
import ./[fontmgr, drawable, camera, events, gifnode, imagenode, textnode]

# Since we've imported this, pass everything needed for this to compile.
{.passC: "-march=native -mtune=native -msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mpclmul -mavx -mavx2".}

type
  OpenGLData* = object
    version*, vendor*, device*: string

  Scene* = object
    bxContext*: Boxy
    tree*: seq[Drawable]
    camera*: Camera
    background*: Image

    fontManager*: FontManager
    eventManager*: EventManager

    minimized: bool
    maximized: bool
    openglData*: OpenGLData
    lastTime: float

proc getDt*(scene: Scene): float {.inline.} =
  let time = epochTime() - scene.lastTime
  time

proc onResize*(scene: var Scene, nDimensions: tuple[w, h: int]) {.inline.} =
  scene.background = newImage(nDimensions.w, nDimensions.h)
  scene.background.fill(rgba(255, 255, 255, 255))

  scene.camera.calculateFrustum((width: nDimensions.w.float32, height: nDimensions.h.float32))

proc onMinimize*(scene: var Scene) {.inline.} =
  if scene.minimized:
    return

  scene.maximized = false
  scene.minimized = true

proc onScroll*(scene: var Scene, delta: Vec2) {.inline.} =
  scene.camera.scroll(delta)
  scene.camera.calculateFrustum((width: scene.background.width.float32, height: scene.background.height.float32))

proc get*(scene: Scene, id: int): Option[Drawable] {.inline.} =
  if id < (scene.tree.len - 1):
    some scene.tree[id]
  else:
    none Drawable

proc set*(scene: var Scene, id: int, node: Drawable) {.inline.} =
  scene.tree[id] = node

proc add*(scene: var Scene, drawable: var Drawable) {.inline.} =
  drawable.id = scene.tree.len.uint
  scene.tree.add(drawable)

proc onMaximize*(scene: var Scene) {.inline.} =
  if scene.maximized:
    return

  scene.maximized = true
  scene.minimized = false

proc fullDamage*(scene: var Scene) {.inline.} =
  when not defined(ferusInJail): debug "Performing full damage on scene; marking all drawables as needing a redraw. This will tank the performance!"
  for i, _ in scene.tree:
    var drawObj = scene.tree[i]
    drawObj.markRedraw(true)

proc blit*(scene: var Scene) {.inline.} =
  scene.bxContext.drawImage("background", vec2(0, 0))

  for i, drawObj in scene.tree:
    if scene.camera.isCulled(drawObj.bounds):
      continue

    let id = $i

    var multidraw: seq[int]

    when defined(ferusgfxDrawDamagedRegions):
      var drawDamageRegion = false
    
    if drawObj.needsRedraw():
      when defined(ferusgfxDrawDamagedRegions):
        drawDamageRegion = true

      var 
        img = newImage(drawObj.bounds.w.int, drawObj.bounds.h.int)
        uploaded: seq[Image]
      
      when not defined(ferusgfxUseSinglethreadedRenderer):
        init(Weave)
        spawn drawObj.draw(addr img, scene.getDt())
        spawn drawObj.upload(addr uploaded, scene.getDt())
        exit(Weave)
      else:
        drawObj.draw(addr img, scene.getDt())
        drawObj.upload(addr uploaded, scene.getDt())

      when defined(ferusgfxDrawDamagedRegions):
        scene.bxContext.addImage(id & "-dmg", drawObj.damageImage)

      if uploaded.len < 1:
        scene.bxContext.addImage(id, img)
      else:
        for iu, imgu in uploaded:
          scene.bxContext.addImage(id & '-' & $iu, imgu)
          multidraw.add(iu)
    
    if multidraw.len < 1:
      scene.bxContext.drawImage(id, scene.camera.apply(drawObj.position))
    else:
      for mid in multidraw:
        scene.bxContext.drawImage(id & '-' & $mid, scene.camera.apply(drawObj.position))
    
    when defined(ferusgfxDrawDamagedRegions):
      if drawDamageRegion:
        scene.bxContext.drawImage(id & "-dmg", scene.camera.apply(drawObj.position))

proc draw*(scene: var Scene) =
  ## Clears the screen, blits all drawables to the screen and
  ## finishes a frame.
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glClearColor(0f, 0.5f, 0.5f, 1f)
  
  scene.bxContext.beginFrame(
    ivec2(scene.background.width.int32, scene.background.height.int32)
  )
  scene.camera.update()
  scene.eventManager.poll()
  scene.blit()
  scene.bxContext.endFrame()
  scene.bxContext.addImage("background", scene.background)
  scene.lastTime = epochTime()

proc newScene*(width, height: int): Scene =
  ## Create a new scene with the provided dimensions.
  
  let 
    vendor = $cast[cstring](glGetString(GL_VENDOR))
    version = $cast[cstring](glGetString(GL_VERSION))
    renderer = $cast[cstring](glGetString(GL_RENDERER))
    extensions = $cast[cstring](glGetString(GL_EXTENSIONS))
  
  when not defined(ferusInJail):
    info "New ferusgfx scene instantiating."
    info "OpenGL: " & version
    info "Renderer: " & renderer
    info "Vendor: " & vendor
    info "Extensions: " & extensions
    info "Viewport: " & $width & 'x' & $height

  result = Scene(
    bxContext: newBoxy(),
    lastTime: 0f,
    tree: @[],
    fontManager: newFontManager(),
    camera: newCamera(),
    eventManager: newEventManager(),

    openglData: OpenGLData(
      version: version,
      device: renderer,
      vendor: vendor
    )
  )
  var bg = newImage(width, height)
  bg.fill(rgba(255, 255, 255, 255))

  result.background = bg
  result.bxContext.addImage("background", bg)
