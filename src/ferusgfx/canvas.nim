import pixie

type Canvas* = ref object of RootObj
 image*: Image
 width*: int
 height*: int

proc newCanvas*(w, h: int): Canvas =
 Canvas(image: newImage(w, h), width: w, height: h)