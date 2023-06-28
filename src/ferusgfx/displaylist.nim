import drawable, scene

type
 DisplayList* = ref object of RootObj
  scene: Scene
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

 for toRemove in rmList:
  displayList.scene.tree.delete(toRemove)

 for toAdd in displayList.adds:
  displayList.scene.tree.add(toAdd)

proc newDisplayList*(scene: Scene): DisplayList =
 DisplayList(scene: scene, adds: @[], removes: @[])