import scene, displaylist, vectors

type Camera* = ref object of RootObj
 scene: Scene
 displayList: DisplayList

proc setScene*(camera: Camera, scene: Scene) =
 camera.scene = scene

proc update*(camera: Camera, displayList: DisplayList) =
 camera.displayList = displayList

proc scrollTo*(camera: Camera, factor: float64) =
 for drawable in camera.scene.tree:
  camera.displayList.setPos(
   drawable,
   newVector2(
    drawable.position.x.float64, 
    drawable.position.y.float64 + factor
   )
  )
  camera.displayList.doClearAll = true

proc newCamera*(): Camera =
 Camera()