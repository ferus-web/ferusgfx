## Cameras are used by ferusgfx to implement scrolling.
import vmath, bumpy, boxy

type
  ScrollingOpts* = object ## Options for how scrolling should be done.
    deltaMultiplier*: float = 1.5
      ## How much should we scroll every time the camera is updated? Setting this too high can cause problems.

    longetivity*: float32 = 48
      ## How long does the scrolling last for before it completely stops? 
      ## Setting this too high can cause the compositor to feel very slippery and setting it too low can cause it to feel
      ## very rigid. **Setting this to 0 will cause a crash due to how the delta is calculated!**

  Camera* = object ## A camera object.
    position*: Vec2
    opts: ScrollingOpts
    bounds*: Rect

    hi: Vec2
    lo: Vec2
    delta: Vec2

proc setScrollingOpts*(camera: var Camera, opts: ScrollingOpts) {.inline.} =
  camera.opts = opts

proc setScrollingDeltaMultiplier*(camera: var Camera, value: float32) {.inline.} =
  camera.opts.deltaMultiplier = value

proc setScrollingLongetivity*(camera: var Camera, value: float32) {.inline.} =
  camera.opts.longetivity = value

proc update*(camera: var Camera) {.thread, nimcall.} =
  ## Update the camera's state by calculating how much we've scrolled and where the camera is positioned on the basis of that.
  let y = camera.delta.y * camera.opts.deltaMultiplier

  camera.position = vec2(camera.position.x - camera.delta.x, camera.position.y - y)
  camera.delta = vec2(camera.delta.x, camera.delta.y - (y / camera.opts.longetivity))

  # Camera bounds checks
  if camera.position.y < camera.lo.y:
    camera.delta = vec2(camera.delta.x, -1) # apply a small "thrust" backwards as in to indicate that the viewport's border has been hit
    camera.position = vec2(camera.position.x, camera.lo.y)

  if camera.position.y > camera.hi.y:
    camera.delta = vec2(camera.delta.x, 1) # same as the above comment except it pushes you forwards
    camera.position = vec2(camera.position.x, camera.hi.y)

proc stopScrolling*(camera: var Camera) {.inline.} =
  ## Immediately stop the camera from scrolling. This does nothing but set the camera's delta vector to a zero-vector.
  ##
  ## **See also**:
  ## - `scroll(camera: Camera, delta: Vec2)`_ to increment/decrement the camera's delta vector.
  camera.delta = vec2(0, 0)

proc calculateFrustum*(
  camera: var Camera,
  viewport: tuple[width, height: float32]
) {.inline.} =
  camera.bounds.x = camera.position.x
  camera.bounds.y = camera.position.y

  camera.bounds.w = viewport.width
  camera.bounds.h = viewport.height

proc isCulled*(
  camera: Camera, 
  rect: Rect
): bool {.inline.} =
  var bounds = camera.bounds
  bounds.w += 150f # really stupid fix to prevent pop-ins
  bounds.h += 150f
  not bounds.overlaps(rect)

proc scroll*(camera: var Camera, delta: Vec2) {.inline.} =
  ## Cause the camera's scrolling delta to be incremented/decremented by a `Vec2`.
  ## This is incremental, unless the delta's Y coordinate is extremely high, it won't be able to cancel the scrolling immediately.
  ##
  ## **See also**:
  ## - `stopScrolling(camera: Camera)`_ to abruptly stop the camera.
  camera.delta += vec2(0, delta.y) / 2

proc apply*(camera: Camera, pos: Vec2): Vec2 {.inline.} =
  ## Get the position of an object as seen by the camera, by subtracting its real position from the camera's position.
  pos - camera.position

proc setBoundaries*(camera: var Camera, lo, hi: Vec2) {.inline.} =
  ## Set the highest and lowest points where the camera can go.
  camera.lo = lo
  camera.hi = hi

proc newCamera*(): Camera {.inline.} =
  ## Create a new camera object.
  Camera(position: vec2(0, 0), opts: ScrollingOpts())
