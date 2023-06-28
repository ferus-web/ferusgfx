#[
 Vectors
]#
import math

type
 Vector3* = ref object of RootObj
  x*: int
  y*: int
  z*: int

 Vector2* = ref object of RootObj
  x*: int
  y*: int

proc magnitude*(vec2, othervec2: Vector2): float {.inline.} =
 sqrt(
  (othervec2.x - vec2.x) ^ 2 + (othervec2.y - vec2.y) ^ 2
 )

proc magnitude*(vec3, othervec3: Vector3): float {.inline.} =
 sqrt(
  (othervec3.x - vec3.x) ^ 2 + (othervec3.y - vec3.y) ^ 2 + (othervec3.z - vec3.z)
 )