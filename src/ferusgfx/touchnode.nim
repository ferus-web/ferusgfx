## Touch interest node
## Copyright (C) 2024 Trayambak Rai
import ferusgfx/[drawable]
import pixie, bumpy

type
  MouseClick* {.pure.} = enum
    Left
    Right

  TouchInterestClick* = proc(mouse: MouseClick)
  TouchInterestHover* = proc()
  TouchInterestNode* = ref object of Drawable
    clickCb*: TouchInterestClick
    hoverCb*: TouchInterestHover

    hovered*: bool = false
    pressed*: bool = false

    prevHoveredState: bool = false

method getNodeKind*(node: TouchInterestNode): DrawableKind {.inline.} =
  dkTouchInterestNode

method draw*(node: TouchInterestNode, image: ptr Image, dt: float32) =
  when defined(ferusgfxDrawTouchInterestNodeBounds):
    image[] = newImage(node.bounds.w.int, node.bounds.h.int)
    var paint = newPaint(SolidPaint)
    
    if node.pressed:
      paint.color = color(0, 0, 1, 0.5)
    elif node.hovered:
      paint.color = color(0, 1, 0, 0.5)
    else:
      paint.color = color(1, 0, 0, 0.5)

    paint.opacity = 0.5f
    image[].fill(paint)

  node.markRedraw(false)

proc newTouchInterestNode*(
  bounds: Rect,
  clickCb: TouchInterestClick, hoverCb: TouchInterestHover
): TouchInterestNode {.inline.} =
  TouchInterestNode(
    bounds: bounds,
    position: vec2(bounds.x, bounds.y),
    clickCb: clickCb,
    hoverCb: hoverCb,
    config: (needsRedraw: true)
  )
