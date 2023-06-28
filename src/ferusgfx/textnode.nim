import drawable, vectors, pixie

type
 TextNode* = ref object of Drawable
  textContent*: string

method draw*(textNode: TextNode, context: Context) =
 textNode.drawAABB(context)

proc newTextNode*(
  textContent: string, 
  pos: Vector2, id: uint): TextNode =
 TextNode(
  id: id,
  textContent: textContent, 
  position: pos,
  bounds: (
   min: newVector2(0, 0),
   max: newVector2(10, 10)
  )
 )