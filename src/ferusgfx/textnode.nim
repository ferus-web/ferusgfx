import ferusgfx/[drawable, fontmgr]
import pixie, bumpy

type TextNode* = ref object of Drawable
  textContent: string
  arrangement: Arrangement
  globalBounds: Rect
  imageSpace: Mat3

  font: Font
  wrap: bool

proc compute*(textNode: var TextNode) =
  let transform = translate textNode.position
  textNode.arrangement = typeset(@[newSpan(textNode.textContent, textNode.font)])
  textNode.globalBounds = textNode.arrangement.computeBounds(transform)

  textNode.imageSpace = translate(-textNode.globalBounds.xy) * transform

method getNodeKind*(textNode: TextNode): DrawableKind {.inline.} =
  dkTextNode

method draw*(textNode: TextNode, image: ptr Image, dt: float32) =
  image[] = newImage(textNode.bounds.w.int, textNode.bounds.h.int)
  image[].fill(rgba(255, 255, 255, 1))
  image[].fillText(textNode.arrangement, textNode.imageSpace)

  textNode.markRedraw(false)

proc computeSize(textContent: string, font: Font): Vec2 =
  let
    width = textContent.len * font.size.int
    height = font.size.int

  vec2(width.float32, height.float32)

proc newTextNode*(
    textContent: sink string, pos: Vec2, fontMgr: FontManager,
    fontSize: float32 = 14f
): TextNode {.inline.} =
  let size = computeSize(textContent, fontMgr.get("Default"))
  
  when defined(ferusgfxDrawDamagedRegions):
    var paint = newPaint(SolidPaint)
    paint.opacity = 0.5f
    paint.color = color(1, 0, 0, 0.5)
  
  var font = fontMgr.get("Default")
  font.size = fontSize
  result = TextNode(
    textContent: move(textContent),
    position: pos,
    font: font,
    bounds: rect(pos.x, pos.y, size.x, size.y),
    config: (needsRedraw: true)
  )

  when defined(ferusgfxDrawDamagedRegions):
    result.damageImage = newImage(result.bounds.w.int32, result.bounds.y.int32)
    result.damageImage.fill(paint)

  compute result

proc newTextNode*(
  textContent: sink string,
  pos: Vec2,
  size: Vec2,
  fontMgr: FontManager
): TextNode {.inline.} =
  when defined(ferusgfxDrawDamagedRegions):
    var paint = newPaint(SolidPaint)
    paint.opacity = 0.5f
    paint.color = color(1, 0, 0, 0.5)
  
  var font = fontMgr.get("Default")

  result = TextNode(
    textContent: move(textContent),
    position: pos,
    font: font,
    bounds: rect(pos.x, pos.y, size.x, size.y),
    config: (needsRedraw: true)
  )

  when defined(ferusgfxDrawDamagedRegions):
    result.damageImage = newImage(result.bounds.w.int32, result.bounds.y.int32)
    result.damageImage.fill(paint)

  compute result

proc newTextNode*(
  textContent: sink string,
  pos, size: Vec2,
  typeface: Typeface,
  fontSize: float32 = 14f,
  color: Color = color(0, 0, 0, 1)
): TextNode {.inline.} =
  when defined(ferusgfxDrawDamagedRegions):
    var paint = newPaint(SolidPaint)
    paint.opacity = 0.5f
    paint.color = color(1, 0, 0, 0.5)

  var font = newFont(typeface)
  font.size = fontSize
  font.paint.color = color

  result = TextNode(
    textContent: move(textContent),
    position: pos,
    font: font,
    bounds: rect(pos.x, pos.y, size.x, size.y),
    config: (needsRedraw: true),
    damageImage: newImage(1, 1)
  )

  when defined(ferusgfxDrawDamagedRegions):
    let paint2 = newPaint(SolidPaint)
    paint2.opacity = 0.5f
    paint2.color = color(1, 0, 0, 0.5)

  compute result
