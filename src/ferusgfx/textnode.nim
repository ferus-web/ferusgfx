import drawable, vectors, pixie, fontmgr

type
 TextNode* = ref object of Drawable
  textContent*: string
  font*: Font
  fPath*: string

method draw*(textNode: TextNode, context: Context) =
 context.font = textNode.fPath
 textNode.drawAABB(context)
 
 context.fillText(
  textNode.textContent, 
  vec2(textNode.position.x.float32, textNode.position.y.float32)
 )

proc computeSize(textContent: string, font: Font): Vector2 =
 let
  width = textContent.len * font.size.int
  height = font.size.int

 Vector2(x: width, y: height)

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
  fPath: fontMgr.getPath("Default")
 )