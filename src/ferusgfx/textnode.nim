import drawable, pixie, bumpy, fontmgr

type TextNode* = ref object of Drawable
  textContent*: string
  arrangement*: Arrangement
  globalBounds*: Rect
  imageSpace*: Mat3

  font*: Font
  fPath: string

  wrap*: bool

proc compute*(textNode: TextNode) =
  let transform = translate textNode.position
  textNode.arrangement = typeset(@[newSpan(textNode.textContent, textNode.font)])
  textNode.globalBounds = textNode.arrangement.computeBounds(transform)

  textNode.imageSpace = translate(-textNode.globalBounds.xy) * transform

method draw*(textNode: TextNode) =
  #textNode.drawAABB(context)
  textNode.image.fill(rgba(255, 255, 255, 1))

  textNode.image.fillText(textNode.arrangement, textNode.imageSpace)

  textNode.markRedraw(false)

proc computeSize(textContent: string, font: Font): Vec2 =
  let
    width = textContent.len * font.size.int
    height = font.size.int

  vec2(width.float32, height.float32)

proc newTextNode*(
    textContent: string, pos: Vec2, id: uint, fontMgr: FontManager
): TextNode =
  let size = computeSize(textContent, fontMgr.get("Default"))

  result = TextNode(
    id: id,
    textContent: textContent,
    position: pos,
    image: newImage(size.x.int, size.y.int),
    font: fontMgr.get("Default"),
    bounds: rect(pos.x, pos.y, size.x, size.y),
    fPath: fontMgr.getPath("Default"),
    config: (needsRedraw: true),
  )

  compute result
