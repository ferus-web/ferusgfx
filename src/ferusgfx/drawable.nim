#[
 A drawable, can be included in a display list
]#

import pixie, bumpy, boxy

type
  DrawableKind* = enum
    dkDrawable
    dkTextNode
    dkImageNode
    dkGIFNode
    dkTouchInterestNode

type Drawable* = ref object of RootObj
  id*: uint
  position*: Vec2
  bounds*: Rect
  config*: tuple[needsRedraw: bool] = (needsRedraw: true)
  
  when defined(ferusgfxDrawDamagedRegions):
    damageImage*: Image

method getNodeKind*(drawable: Drawable): DrawableKind {.inline, base.} =
  dkDrawable

#[proc `=copy`*(dest: var Drawable, src: Drawable) =
  `=destroy`(dest)
  wasMoved(dest)

  dest.id = src.id
  dest.position = src.position
  dest.boxy = src.boxy
  dest.bounds = src.bounds
  dest.image = src.image
  dest.config = src.config]#

proc markRedraw*(drawable: Drawable, val: bool = true) {.inline.} =
  drawable.config.needsRedraw = val

proc needsRedraw*(drawable: Drawable): bool {.inline.} =
  drawable.config.needsRedraw

#[proc drawAABB*(drawable: Drawable, context: Context) =
 context.strokeStyle = "#FF5C00"
 context.lineWidth = 8

 # Example for these commands: 
 # min = Vector2(x: 0, y: 0), max = Vector2(x: 10, y: 10)


 # | } (0, 10)
 # |
 # |
 # | } (0, 0)
 context.strokeSegment(
  segment(
   vec2(
    drawable.bounds.min.x.float32,
    drawable.bounds.min.y.float32
   ),
   vec2(
    drawable.bounds.min.x.float32,
    drawable.bounds.max.y.float32
   )
  )
 )

 #             | } (10, 10)
 #             |
 #             |
 #             | } (10, 0)
 context.strokeSegment(
  segment(
   vec2(
    drawable.bounds.max.x.float32,
    drawable.bounds.max.y.float32
   ),
   vec2(
    drawable.bounds.max.x.float32,
    drawable.bounds.min.y.float32
   )
  )
 )

 # -------------
 # ^           ^
 # (0, 10)   (10, 10)
 #
 context.strokeSegment(
  segment(
   vec2(
    drawable.bounds.min.x.float32,
    drawable.bounds.max.y.float32
   ),
   vec2(
    drawable.bounds.max.x.float32,
    drawable.bounds.max.y.float32
   )
  )
 )

 #
 # (0, 0)    (10, 0)
 # v           v
 # -------------
 context.strokeSegment(
  segment(
   vec2(
    drawable.bounds.min.x.float32,
    drawable.bounds.min.y.float32
   ),
   vec2(
    drawable.bounds.max.x.float32,
    drawable.bounds.min.y.float32
   )
  )
 )]#

method update*(drawable: Drawable, dt: float32) {.base.} = discard
method draw*(drawable: Drawable, image: ptr Image, dt: float32) {.base.} = discard
method upload*(drawable: Drawable, images: ptr seq[Image], dt: float32) {.base.} = discard
