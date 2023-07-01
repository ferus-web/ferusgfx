#[
 A drawable, can be included in a display list
]#

import pixie, vectors

type Drawable* = ref object of RootObj
 id*: uint
 position*: Vector2
 bounds*: tuple[min: Vector2, max: Vector2]

proc drawAABB*(drawable: Drawable, context: Context) =
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
 )

method draw*(drawable: Drawable, context: Context) {.base.} =
 return