#[
 A 2D scene

 This code is licensed under the MIT license
]#
import canvas, drawable, 
       pixie, boxy,
       opengl, fontmgr, std/times

type Scene* = ref object of RootObj
 bxContext*: Boxy
 canvas*: Canvas
 tree*: seq[Drawable]

 fontManager*: FontManager

 minimized: bool
 maximized: bool

 # window lib-agnostic way of getting dt
 lastTime: float

proc getDt*(scene: Scene): float =
 let time = cpuTime() - scene.lastTime
 time

proc onResize*(scene: Scene, nDimensions: tuple[w, h: int]) =
 scene.canvas.width = nDimensions.w
 scene.canvas.height = nDimensions.h
 scene.canvas.image = newImage(nDimensions.w, nDimensions.h)

proc onMinimize*(scene: Scene) =
 if scene.minimized: return
 scene.maximized = false
 scene.minimized = true

proc onMaximize*(scene: Scene) =
 if scene.maximized: return
 scene.maximized = true
 scene.minimized = false

proc blit*(scene: Scene) =
 scene.canvas.image.fill(rgba(255, 255, 255, 255))
 
 for drawObj in scene.tree:
  # Only create contexts and re-draw drawables onto the
  # image if they are marked in need to be redrawn.
  if drawObj.needsRedraw():
   echo "redraw " & $drawObj.id
   # Allocate context for this drawable
   let context = scene.canvas.createContext()
   drawObj.draw(context)

 scene.bxContext.addImage("final_image", scene.canvas.image)

proc draw*(scene: Scene) =
 # Now that every drawable has blitted itself to the
 # screen, let's go ahead and draw it to the window.
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
 glClearColor(0f, 0.5f, 0.5f, 1f)

 scene.bxContext.beginFrame(
  ivec2(scene.canvas.width.int32, scene.canvas.height.int32)
 )
 scene.bxContext.drawImage("final_image", vec2(0, 0))
 scene.bxContext.endFrame()
 scene.lastTime = cpuTime()

proc newScene*(canvas: Canvas): Scene =
 Scene(
  canvas: canvas,
  bxContext: newBoxy(), lastTime: 0f,
  tree: @[], fontManager: newFontManager()
 )