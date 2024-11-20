## A 2D scene
##
## Copyright (C) 2024 Trayambak Rai and Ferus Authors

import std/[options, times, logging, strutils]
import pixie, boxy, opengl, weave
import ./[fontmgr, drawable, camera, events, gifnode, imagenode, textnode, touchnode]

# Since we've imported this, pass everything needed for this to compile.
{.passC: "-march=native -mtune=native -msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mpclmul -mavx -mavx2".}

type 
  OpenGLData* = object
    version*, vendor*, device*: string

  DraggingState* = object
    startDrag*: Vec2
    endDrag*: Option[Vec2]

  CursorState* = object
    currentPosition*: Vec2
    drag*: Option[DraggingState]

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
    
    backgroundColor*: ColorRGBA
    redrawBackground: bool = false

    cursor*: CursorState

proc getDt*(scene: Scene): float {.inline.} =
  let time = epochTime() - scene.lastTime
  time

proc onCursorMotion*(scene: var Scene, position: sink Vec2) =
  scene.cursor.currentPosition = move(position)
  let relativeCursorPos = scene.camera.position + scene.cursor.currentPosition # scene.camera.apply(scene.cursor.currentPosition)

  # should we just do this alongside the draw iteration?
  for i, _ in scene.tree:
    if scene.tree[i].getNodeKind() == dkTouchInterestNode:
      var interest = TouchInterestNode(scene.tree[i])
      if interest.hovered:
        interest.hovered = false
        interest.markRedraw(true)
      
      if relativeCursorPos.overlaps(interest.bounds):
        interest.hovered = true
        interest.markRedraw(true)

        if interest.hoverCb != nil:
          interest.hoverCb()

      scene.tree[i] = move(interest)

proc onCursorClick*(scene: var Scene, pressed: bool, button: MouseClick) =
  let relativeCursorPos = scene.camera.position + scene.cursor.currentPosition # scene.camera.apply(scene.cursor.currentPosition)
  for i, _ in scene.tree:
    if scene.tree[i].getNodeKind() == dkTouchInterestNode:
      var interest = TouchInterestNode(scene.tree[i])
      if interest.pressed:
        interest.pressed = false
        interest.markRedraw(true)

      if relativeCursorPos.overlaps(interest.bounds):
        interest.pressed = pressed
        interest.markRedraw(true)

        if interest.hoverCb != nil:
          interest.clickCb(button)

      scene.tree[i] = move(interest)

proc onResize*(scene: var Scene, nDimensions: tuple[w, h: int]) {.inline.} =
  scene.background = newImage(nDimensions.w, nDimensions.h)
  scene.background.fill(scene.backgroundColor)

  scene.camera.calculateFrustum((width: nDimensions.w.float32, height: nDimensions.h.float32))

proc setBackgroundColor*(scene: var Scene, color: ColorRGBA) {.inline.} =
  scene.backgroundColor = color
  scene.background.fill(color)

proc beginSelection*(scene: var Scene) =
  info "scene: begin selection/drag"
  scene.cursor.drag = some(
    DraggingState(
      startDrag: scene.cursor.currentPosition
    )
  )

proc endSelection*(scene: var Scene) =
  if scene.cursor.drag.isSome:
    # we're selecting/dragging
    info "scene: stop selection/dragging"
    var state = scene.cursor.drag.get()
    state.endDrag = scene.cursor.currentPosition.some()

    scene.cursor.drag = move(state).some()

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
  when not defined(ferusInJail): debug "scene: performing full damage on scene; marking all drawables as needing a redraw. This will tank the performance!"
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
        img: Image
        uploaded = newSeq[Image](0)
      
      when not defined(ferusgfxUseSinglethreadedRenderer):
        init(Weave)
        spawn drawObj.draw(addr img, scene.getDt())
        spawn drawObj.upload(addr uploaded, scene.getDt())
        exit(Weave)
      else:
        drawObj.draw(addr img, scene.getDt())
        drawObj.upload(addr uploaded, scene.getDt())

      when defined(ferusgfxDrawDamagedRegions):
        if drawObj.damageImage != nil:
          scene.bxContext.addImage(id & "-dmg", drawObj.damageImage)
      
      if uploaded.len < 1:
        if img != nil:
          scene.bxContext.addImage(id, img)
        else:
          continue
      else:
        for iu, imgu in uploaded:
          scene.bxContext.addImage(id & '-' & $iu, imgu)
          multidraw.add(iu)
    
    if multidraw.len < 1:
      if scene.bxContext.contains(id):
        scene.bxContext.drawImage(id, scene.camera.apply(drawObj.position))
    else:
      for mid in multidraw:
        scene.bxContext.drawImage(id & '-' & $mid, scene.camera.apply(drawObj.position))
    
    when defined(ferusgfxDrawDamagedRegions):
      if drawDamageRegion and scene.bxContext.contains(id & "-dmg"):
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
  
  if scene.cursor.drag.isSome:
    let dragState = scene.cursor.drag.get()
    if dragState.endDrag.isSome:
      debug "scene: assigning DraggingState as none"
      scene.cursor.drag = none(DraggingState)

    debug "scene: selection in progress (start=$1, current=$2)" % [$dragState.startDrag, $scene.cursor.currentPosition]

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
    info "scene: new ferusgfx scene instantiating."
    info "scene: OpenGL: " & version
    info "scene: device: " & renderer
    info "scene: vendor: " & vendor
    info "scene: extensions: " & extensions
    info "scene: viewport: " & $width & 'x' & $height

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
  result.backgroundColor = rgba(255, 255, 255, 255)

  result.background = bg
  result.bxContext.addImage("background", bg)
