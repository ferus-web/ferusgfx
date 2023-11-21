import drawable, vectors, pixie, fontmgr

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
    vec2(textNode.position.x.float32, textNode.position.y.float32)
  )
 )

proc computeSize(textContent: string, font: Font): Vector2 =
 let
  width = textContent.len * font.size.int
  height = font.size.int

 newVector2(
  width, height
 )

proc newTextNode*(
  textContent: string, 
  pos: Vector2, id: uint, fontMgr: FontManager): TextNode =
 TextNode(
  id: id,
  textContent: textContent, 
  position: pos,
  font: fontMgr.get("Default"),
  bounds: (
   min: pos,
   max: computeSize(textContent, fontMgr.get("Default"))
  ),
  fPath: fontMgr.getPath("Default"),
  config: (
   needsRedraw: true
  )
 )
