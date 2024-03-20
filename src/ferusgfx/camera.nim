import std/tables, vmath

type
  Camera* = ref object
    position*: Vec2
    delta*: Vec2

proc update*(camera: Camera) =
  let y = camera.delta.y * 1.5
  
  camera.position = vec2(camera.position.x - camera.delta.x, camera.position.y - y)
  camera.delta = vec2(camera.delta.x, camera.delta.y - (y / 32))

proc scroll*(camera: Camera, delta: Vec2) {.inline.} =
  camera.delta += vec2(0, delta.y) / 2

proc apply*(camera: Camera, pos: Vec2): Vec2 {.inline.} =
  pos - camera.position

proc newCamera*: Camera =
  Camera(
    position: vec2(0, 0)
  )
