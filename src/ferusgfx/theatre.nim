import scene, camera, canvas, displaylist

#[
 A theatre is just a data structure holding scenes
 which allows for easy switching between scenes with minimal overhead
]#
type Theatre* = ref object of RootObj
 canvas: Canvas
 scenes: seq[Scene]
 camera: Camera

 current: int

proc setCurrentScene*(theatre: Theatre, idx: int) =
 doAssert idx <= theatre.scenes.len()

 theatre.camera.setScene(theatre.scenes[idx])
 theatre.current = idx

proc getCurrentScene*(theatre: Theatre): Scene =
 theatre.scenes[theatre.current]

proc draw*(theatre: Theatre, displayList: DisplayList) =
 # All transforms need to happen before the commit()
 theatre.camera.update(displayList)

 # Draw into the image and reset
 displayList.commit()

 let imgId = theatre.scenes[theatre.current].blit()
 theatre.scenes[theatre.current].draw(imgId)

proc onResize*(theatre: Theatre, dimensions: tuple[w, h: int]) =
 theatre.scenes[theatre.current].onResize(dimensions)

proc onScroll*(theatre: Theatre, factor: float64) =
 theatre.camera.scrollTo(factor)

proc addScene*(theatre: Theatre, scene: Scene) =
 scene.canvas = theatre.canvas
 theatre.scenes.add(scene)

proc newTheatre*(width, height: int): Theatre =
 Theatre(
  canvas: newCanvas(width, height), 
  scenes: @[], 
  current: -1,
  camera: newCamera()
 )