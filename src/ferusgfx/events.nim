## An event system for ferusgfx

type
  EventCallback* = proc(age: uint) ## A function that's part of an event.
  EventTag* = distinct uint64 ## An event tag.
  ## Internal event tags
  ## 0 - this event is triggered when a redraw occurs and everything is gradually redrawn
  Event* = object ## An event object.
    cb: EventCallback ## The callback 
    lifespan: uint ## The lifespan/how many frames the event lasts
    age: uint = 0 ## How many frames this event has lived

    tags*: seq[EventTag] ## Tags carried by this event

  EventManager* = ref object
    ## The event manager object. Just carries a sequence of events
    events: seq[Event]

proc tag*(x: SomeInteger): EventTag {.inline.} =
  cast[EventTag](x)

proc `==`*(x, y: EventTag): bool {.borrow.}

proc remove[T](s: var seq[T], idxs: seq[int]) {.inline.} =
  # dumb crap
  var alignment = 0

  for rm in idxs:
    let idx =
      if rm != 0:
        rm - alignment
      else:
        0

    inc alignment
    s.del idx

proc poll*(mgr: EventManager) =
  ## Update all events - this is to be called every frame
  var removes: seq[int]

  for i, _ in mgr.events:
    var mEvent = mgr.events[i]
    if mEvent.age >= mEvent.lifespan:
      removes.add(i)
      continue

    mEvent.cb(mEvent.age)
    mEvent.age += 1

    mgr.events[i] = mEvent

  mgr.events.remove(removes)

proc add*(
    mgr: EventManager,
    cb: EventCallback,
    lifespan: uint,
    tags: seq[EventTag] = @[],
    exclusive: bool = false,
) {.inline.} =
  if exclusive:
    var removes: seq[int]
    for i, event in mgr.events:
      for eTag in tags:
        if eTag in event.tags:
          removes.add(i)

    mgr.events.remove(removes)

  mgr.events.add(Event(cb: cb, lifespan: lifespan, tags: tags))

proc newEventManager*(): EventManager {.inline.} =
  EventManager(events: @[])
