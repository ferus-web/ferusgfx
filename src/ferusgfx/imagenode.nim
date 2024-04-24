import drawable, pixie, boxy

type ImageNode* = ref object of Drawable
  path*: string
  image*: Image

method draw*(node: ImageNode, src: var Image, dt: float32) =
  node.markRedraw(false)
  `=copy`(src, node.image)

proc newImageNode*(path: string, pos: Vec2): ImageNode {.inline.} =
  let image = readImage(path)

  ImageNode(
    path: path,
    config: (needsRedraw: true),
    position: pos,
    bounds: rect(pos.x, pos.y, image.width.float32, image.height.float32),
    image: image
  )
