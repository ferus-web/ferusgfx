import pixie

type Canvas* = ref object
  image*: Image
  width*: int
  height*: int

proc createContext*(canvas: Canvas): Context =
  newContext(canvas.image)

proc newCanvas*(w, h: int): Canvas =
  Canvas(image: newImage(w, h), width: w, height: h)
