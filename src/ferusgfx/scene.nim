#[
 A 2D scene

 This code is licensed under the MIT license
]#
import canvas, drawable, 
       pixie, boxy,
       opengl

type Scene* = ref object of RootObj
 bxContext*: Boxy
 canvas*: Canvas
 tree*: seq[Drawable]

proc draw*(scene: Scene) =
 scene.canvas.image.fill(rgba(255, 255, 255, 255))
 for drawObj in scene.tree:
  # Allocate context for this drawable
  let context = newContext(scene.canvas.image)
  drawObj.draw(context)

 # Now that every drawable has blitted itself to the
 # screen, let's go ahead and draw it to the window.
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
 glClearColor(0f, 0.5f, 0.5f, 1f)

 scene.bxContext.addImage(
  "final_image", scene.canvas.image
 )
 scene.bxContext.beginFrame(
  ivec2(scene.canvas.width.int32, scene.canvas.height.int32)
 )
 scene.bxContext.drawImage("final_image", vec2(0, 0))
 scene.bxContext.endFrame()

proc newScene*(width, height: int): Scene =
 Scene(
  canvas: newCanvas(width, height),
  bxContext: newBoxy(),
  tree: @[]
 )