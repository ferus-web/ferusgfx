#[
 A drawable, can be included in a display list
]#

import pixie

type Drawable* = ref object of RootObj
 id*: uint
 position*: Vector2
 bounds*: tuple[min: Vector2, max: Vector2]

proc drawAABB*(drawable: Drawable, context: Context) =
 context.strokeStyle = "#FF5C00"
 context.lineWidth = 16

 # Example for these commands: 
 # min = Vector2(x: 0, y: 0), max = Vector2(x: 10, y: 10)


 # | } (0, 10)
 # |
 # |
 # | } (0, 0)
 ctx.strokeSegment(
  vec2(
   drawable.bounds.min.x,
   drawable.bounds.min.y
  ),
  vec2(
   drawable.bounds.min.x,
   drawable.bounds.max.y
  )
 )

 #             | } (10, 10)
 #             |
 #             |
 #             | } (10, 0)
 ctx.strokeSegment(
  vec2(
   drawable.bounds.max.x,
   drawable.bounds.max.y
  ),
  vec2(
   drawable.bounds.max.x,
   drawable.bounds.min.y
  )
 )

 # -------------
 # ^           ^
 # (0, 10)   (10, 10)
 #
 ctx.strokeSegment(
  vec2(
   drawable.bounds.min.x,
   drawable.bounds.max.y
  ),
  vec2(
   drawable.bounds.max.x,
   drawable.bounds.max.y
  )
 )

 #
 # (0, 0)    (10, 0)
 # v           v
 # -------------
 ctx.strokeSegment(
  vec2(
   drawable.bounds.min.x,
   drawable.bounds.min.y
  ),
  vec2(
   drawable.bounds.max.x,
   drawable.bounds.min.y
  )
 )

method draw*(drawable: Drawable, context: Context) {.base.} =
 return