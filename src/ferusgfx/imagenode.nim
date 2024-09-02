import ferusgfx/drawable
import pixie, boxy

type ImageNode* = ref object of Drawable
  path*: string
  image*: Image

method draw*(node: ImageNode, src: ptr Image, dt: float32) =
  node.markRedraw(false)
  `=copy`(src[], node.image)

proc newImageNodeFromMemory*(content: string, pos: Vec2): ImageNode {.inline.} =
  let image = decodeImage content

  when defined(ferusgfxDrawDamagedRegions):
    var paint = newPaint(SolidPaint)
    paint.opacity = 0.5f
    paint.color = color(1, 0, 0, 0.5)

  result = ImageNode(
    path: "<in-memory image>",
    config: (needsRedraw: true),
    position: pos,
    bounds: rect(pos.x, pos.y, image.width.float32, image.height.float32),
    image: image
  )

  when defined(ferusgfxDrawDamagedRegions):
    result.damageImage = newImage(result.bounds.w.int32, result.bounds.y.int32)
    result.damageImage.fill(paint)

proc newImageNode*(path: string, pos: Vec2): ImageNode {.inline.} =
  let image = readImage(path)

  when defined(ferusgfxDrawDamagedRegions):
    var paint = newPaint(SolidPaint)
    paint.opacity = 0.5f
    paint.color = color(1, 0, 0, 0.5)

  result = ImageNode(
    path: path,
    config: (needsRedraw: true),
    position: pos,
    bounds: rect(pos.x, pos.y, image.width.float32, image.height.float32),
    image: image
  )

  when defined(ferusgfxDrawDamagedRegions):
    result.damageImage = newImage(result.bounds.w.int32, result.bounds.y.int32)
    result.damageImage.fill(paint)
