# requires: windy
import windy, unittest, opengl, ../src/ferusgfx

test "example compositor":
 const
  WIDTH = 1280
  HEIGHT = 720

 let window = newWindow("ferusgfx example compositor", ivec2(WIDTH, HEIGHT))
 window.makeContextCurrent()

 loadExtensions()

 let 
  scene = newScene(WIDTH, HEIGHT)
  text = """
MaryLou wore the tiara with pride. 
There was something that made doing anything she didn't really want to do a bit easier when she wore it. 
She really didn't care what those staring through the window were thinking as she vacuumed her apartment.

"It's never good to give them details," Janice told her sister. 
"Always be a little vague and keep them guessing." Her sister listened intently and nodded in agreement. 
She didn't fully understand what her sister was saying but that didn't matter. 
She loved her so much that she would have agreed to whatever came out of her mouth.

She asked the question even though she didn't really want to hear the answer. 
It was a no-win situation since she already knew. 
If he told the truth, she'd get confirmation of her worst fears. 
If he lied, she'd know that he wasn't who she thought he was which would be almost as bad. 
Yet she asked the question anyway and waited for his answer.
"""

 window.onResize = proc() =
  scene.onResize(
   (w: window.size.x.int, h: window.size.y.int)
  )

 #[window.onScroll = proc() =
  scene.onScroll(window.scrollDelta.y)]#

 # Load a font
 scene.fontManager.load("Default", "tests/IBMPlexSans-Regular.ttf")

 var displayList = newDisplayList(scene)

 displayList.add(
  newTextNode(
   text,
   newVector2(100, (HEIGHT / 2).int), 
   scene.tree.len.uint,
   scene.fontManager
  )
 )

 displayList.commit()
 while not window.closeRequested:
  let frameId = scene.blit()
  
  echo frameId
  scene.draw(frameId)
  window.swapBuffers()
  pollEvents()
