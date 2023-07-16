import drawable, scene, vectors

type
 DisplayList* = ref object of RootObj
  scene: Scene
  doClearAll*: bool
  adds: seq[Drawable]
  removes: seq[uint]
  posChange: seq[tuple[drawable: Drawable, pos: Vector2]]

proc reset*(displayList: DisplayList) =
 displayList.doClearAll = false
 displayList.adds.reset()
 displayList.removes.reset()
 displayList.posChange.reset()

proc add*(displayList: DisplayList, drawObj: Drawable) =
 displayList.adds.add(drawObj)

proc remove*(displayList: DisplayList, drawObj: Drawable) =
 displayList.removes.add(drawObj.id)

proc setPos*(displayList: DisplayList, drawObj: Drawable, position: Vector2) =
 displayList.posChange.add(
  (drawable: drawObj, pos: position)
 )
 # displayList.doClearAll = true

proc commit*(displayList: DisplayList) =
 var rmList: seq[int] = @[]
 for idx, drawObj in displayList.scene.tree:
  if drawObj.id in displayList.removes:
   rmList.add(idx)

 if not displayList.doClearAll:
  for toRemove in rmList:
   displayList.scene.tree.delete(toRemove)
 else:
  displayList.scene.tree.reset()

 for toAdd in displayList.adds:
  if toAdd notin displayList.scene.tree:
   displayList.scene.tree.add(toAdd)

 for toChangePos in displayList.posChange:
   toChangePos.drawable.position = toChangePos.pos
   toChangePos.drawable.markRedraw()

 #displayList.reset()

proc newDisplayList*(scene: Scene, doClearAll: bool = false): DisplayList =
 DisplayList(scene: scene, adds: @[], removes: @[], doClearAll: doClearAll)