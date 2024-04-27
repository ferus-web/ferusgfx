import std/times
import drawable, pixie, pixie/fileformats/gif, boxy

type GIFNode* = ref object of Drawable
  path*: string
  gif*: Gif
  
  prevFrame: float # moral of the story: don't trust floats, those sneaky bastards...
  timer: float

  paused: bool = false
  firstRun*: bool = true

proc pause*(node: GIFNode) {.inline.} =
  node.paused = true

proc toggle*(node: GIFNode) {.inline.} =
  node.paused = not node.paused

proc pause*(node: GIFNode, value: bool) {.inline.} =
  node.paused = value

method upload*(node: GIFNode, src: var seq[Image], dt: float32) =
  if node.firstRun:
    node.firstRun = false
    node.prevFrame = epochTime()

  let
    frameTime = epochTime()
    frameDeltaTime = frameTime - node.prevFrame
  
  node.prevFrame = frameTime
  node.timer += frameDeltaTime
  
  if node.timer < node.gif.duration:
    var intervalSum: float32

    for i in 0 ..< node.gif.frames.len:
      src.add(node.gif.frames[i])
      intervalSum += node.gif.intervals[i]

      if intervalSum > node.timer:
        break
  else:
    node.timer = 0f
    src.add(node.gif.frames[0])

proc newGIFNodeFromMemory*(content: string, pos: Vec2): GIFNode {.inline.} =
  let
    gif = decodeGif(content)
    dims = decodeGifDimensions(content)

  when defined(ferusgfxDrawDamagedRegions):
    var paint = newPaint(SolidPaint)
    paint.opacity = 0.5f
    paint.color = color(1, 0, 0, 0.5)

  result = GIFNode(
    path: "<in-memory GIF>",
    config: (needsRedraw: true),
    position: pos,
    bounds: rect(pos.x, pos.y, dims.width.float32, dims.height.float32),
    gif: gif,
    firstRun: true
  )

  when defined(ferusgfxDrawDamagedRegions):
    result.damageImage = newImage(result.bounds.w.int32, result.bounds.y.int32)
    result.damageImage.fill(paint)

proc newGIFNode*(path: string, pos: Vec2): GIFNode {.inline.} =
  let
    contents = path.readFile()
    dims = decodeGifDimensions(contents)
    gif = decodeGif(contents)
 
  when defined(ferusgfxDrawDamagedRegions):
    var paint = newPaint(SolidPaint)
    paint.opacity = 0.5f
    paint.color = color(1, 0, 0, 0.5)

  result = GIFNode(
    path: path,
    config: (needsRedraw: true),
    position: pos,
    bounds: rect(pos.x, pos.y, dims.width.float32, dims.height.float32),
    gif: gif,
    firstRun: true
  )

  when defined(ferusgfxDrawDamagedRegions):
    result.damageImage = newImage(result.bounds.w.int32, result.bounds.y.int32)
    result.damageImage.fill(paint)
