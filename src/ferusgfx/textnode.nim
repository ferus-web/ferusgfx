import drawable, pixie, fontmgr

type
 TextNode* = ref object of Drawable
  textContent*: string
  font*: Font
  fPath: string

  wrap*: bool

method draw*(textNode: TextNode, image: Image) =
 #textNode.drawAABB(context)

 image.fillText(
  # This is horribly, horribly inefficient.
  # aaand, I somehow never caught it. God damn it!
  #[textNode.font, 
  textNode.textContent, 
  vec2(
   textNode.position.x.float32, 
   textNode.position.y.float32
  ).translate() ]#

  textNode.font.typeset(
    textNode.textContent,
    vec2(8, 8),
    LeftAlign, TopAlign,
    textNode.wrap
  ),
  translate(
    textNode.position
  )
 )

 textNode.markRedraw(false)

proc computeSize(textContent: string, font: Font): Vec2 =
 let
  width = textContent.len * font.size.int
  height = font.size.int

 vec2(
  width.float32, height.float32
 )

proc newTextNode*(
  textContent: string, 
  pos: Vec2, id: uint, fontMgr: FontManager): TextNode =
 let size = computeSize(textContent, fontMgr.get("Default"))

 TextNode(
  id: id,
  textContent: textContent, 
  position: pos,
  font: fontMgr.get("Default"),
  bounds: rect(pos.x, pos.y, size.x, size.y),
  fPath: fontMgr.getPath("Default"),
  config: (
   needsRedraw: true
  )
 )
