import drawable, scene

type
 DisplayList* = ref object of RootObj
  scene: Scene
  doClearAll*: bool
  adds: seq[Drawable]
  removes: seq[uint]

proc add*(displayList: DisplayList, drawObj: Drawable) =
 displayList.adds.add(drawObj)

proc remove*(displayList: DisplayList, drawObj: Drawable) =
 displayList.removes.add(drawObj.id)

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
  displayList.scene.tree.add(toAdd)

proc newDisplayList*(scene: Scene, doClearAll: bool = true): DisplayList =
 DisplayList(scene: scene, adds: @[], removes: @[], doClearAll: doClearAll)