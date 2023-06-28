#[
 A 2D scene

 This code is licensed under the MIT license
]#
import canvas, drawable, pixie

type Scene* = ref object of RootObj
 canvas*: Canvas
 tree*: seq[Drawable]

proc draw*(scene: Scene) =
 for drawObj in scene.tree:
  # Allocate context for this drawable
  let context = newContext(scene.canvas.image)
  drawObj.draw(context)

proc newScene*(width, height: int): Scene =
 Scene(canvas: newCanvas(width, height))