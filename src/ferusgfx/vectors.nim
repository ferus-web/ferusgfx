#[
 Vectors
]#
import std/[strformat, math]

type
 Vector2* = ref object of RootObj
  x*: float64
  y*: float64

proc `$`*(v2: Vector2): string =
 fmt"x: {v2.x}; y: {v2.y}"

#[proc magnitude*(vec2, othervec2: Vector2): float {.inline.} =
 sqrt(
  (othervec2.x - vec2.x) ^ 2 + (othervec2.y - vec2.y) ^ 2
 )

proc magnitude*(vec3, othervec3: Vector3): float {.inline.} =
 sqrt(
  (othervec3.x - vec3.x) ^ 2 + (othervec3.y - vec3.y) ^ 2 + (othervec3.z - vec3.z)
 )]#

proc newVector2*(x, y: float64): Vector2 =
 Vector2(x: x, y: y)

proc newVector2*(x, y: int): Vector2 =
 Vector2(x: x.float64, y: y.float64)