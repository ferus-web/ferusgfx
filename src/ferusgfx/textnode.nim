import drawable, pixie, bumpy, fontmgr

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

method draw*(textNode: TextNode, image: var Image, dt: float32) =
  #textNode.drawAABB(context)
  image.fill(rgba(255, 255, 255, 1))
  image.fillText(textNode.arrangement, textNode.imageSpace)
  textNode.markRedraw(false)

proc computeSize(textContent: string, font: Font): Vec2 =
  let
    width = textContent.len * font.size.int
    height = font.size.int

  vec2(width.float32, height.float32)

proc newTextNode*(
    textContent: string, pos: Vec2, fontMgr: FontManager
): TextNode {.inline.} =
  let size = computeSize(textContent, fontMgr.get("Default"))
  
  when defined(ferusgfxDrawDamagedRegions):
    var paint = newPaint(SolidPaint)
    paint.opacity = 0.5f
    paint.color = color(1, 0, 0, 0.5)

  result = TextNode(
    textContent: textContent,
    position: pos,
    font: fontMgr.get("Default"),
    bounds: rect(pos.x, pos.y, size.x, size.y),
    config: (needsRedraw: true)
  )

  when defined(ferusgfxDrawDamagedRegions):
    result.damageImage = newImage(result.bounds.w.int32, result.bounds.y.int32)
    result.damageImage.fill(paint)

  compute result
