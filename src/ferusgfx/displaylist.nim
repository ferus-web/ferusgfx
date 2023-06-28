import drawable, scene

type
 DisplayList* = ref object of RootObj
  scene*: Scene
  adds*: seq[Drawable]
  removes*: seq[uint]

proc commit*(displayList: DisplayList) =
 var rmList: seq[int] = @[]
 for 