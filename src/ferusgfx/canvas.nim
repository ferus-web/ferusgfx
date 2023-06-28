import pixie

type Canvas* = ref object of RootObj
 image*: Image

proc newCanvas*(w, h: int): Canvas =
 Canvas(image: newImage(w, h))