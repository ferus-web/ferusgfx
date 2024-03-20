import vmath, drawable, scene

type DisplayList* = object
  scene: Scene
  doClearAll*: bool
  adds: seq[Drawable]
  removes: seq[uint]
  posChange: seq[tuple[drawable: Drawable, pos: Vec2]]

proc reset*(displayList: var DisplayList) =
  displayList.doClearAll = false
  displayList.adds.reset()
  displayList.removes.reset()
  displayList.posChange.reset()

proc add*(displayList: var DisplayList, drawObj: Drawable) =
  displayList.adds.add(drawObj)

proc remove*(displayList: var DisplayList, drawObj: Drawable) =
  displayList.removes.add(drawObj.id)

proc setPos*(displayList: var DisplayList, drawObj: Drawable, position: Vec2) =
  displayList.posChange.add((drawable: drawObj, pos: position))
  # displayList.doClearAll = true

proc commit*(displayList: var DisplayList) =
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

  displayList.reset()

proc newDisplayList*(scene: Scene, doClearAll: bool = false): DisplayList =
  DisplayList(scene: scene, adds: @[], removes: @[], doClearAll: doClearAll)
