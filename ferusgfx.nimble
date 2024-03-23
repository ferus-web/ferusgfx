# Package

version       = "0.1.2"
author        = "xTrayambak"
description   = "High performance graphics pipeline for Ferus"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"
requires "windy >= 0.0.0" 
requires "vmath >= 1.1.4"
requires "pixie >= 5.0.6"
requires "boxy >= 0.4.2"
requires "opengl >= 1.2.9"

taskRequires "fmt", "nph >= 0.5"

task fmt, "Format code":
  exec "nph src/"

task example_compositor, "Runs a bare bones ferusgfx compositor":
 exec "nim c -r tests/example_compositor.nim"
