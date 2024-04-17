import vmath, drawable, scene

type
  DrawableMutationUnion*[T, M] = object
    drawable*: T
    mut*: M

  DisplayList* = object
    scene: ptr Scene
    doClearAll*: bool

    adds: seq[Drawable]
    removes: seq[uint]
    posChange: seq[DrawableMutationUnion[Drawable, Vec2]]

iterator items*[T, M](
    unions: seq[DrawableMutationUnion[T, M]]
): DrawableMutationUnion[T, M] =
  for i, _ in unions:
    yield unions[i]

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
  displayList.posChange.add(
    DrawableMutationUnion[Drawable, Vec2](drawable: drawObj, mut: position)
  )

proc commit*(displayList: var DisplayList) =
  var rmList: seq[int] = @[]

  for idx, drawObj in displayList.scene.tree:
    if drawObj.id in displayList.removes:
      rmList.add(idx)

  if not displayList.doClearAll:
    for i, _ in rmList:
      var toRemove = rmList[i]
      displayList.scene[].tree.delete(toRemove)
  else:
    displayList.scene[].tree.reset()

  for i, _ in displayList.adds:
    var toAdd = displayList.adds[i]
    displayList.scene[].add(toAdd)

  displayList.reset()

proc newDisplayList*(scene: ptr Scene, doClearAll: bool = false): DisplayList =
  DisplayList(scene: scene, adds: @[], removes: @[], doClearAll: doClearAll)
