# Package

version       = "1.1.10"
author        = "xTrayambak"
description   = "High performance graphics pipeline for Ferus"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"
requires "windy >= 0.0.0" 
requires "vmath >= 1.1.4"
requires "pixie >= 5.0.6"
requires "https://github.com/xTrayambak/boxy >= 0.4.4"
requires "opengl >= 1.2.9"
requires "glfw >= 3.4.0.4"
requires "weave >= 0.4.10"

when defined(linux):
  requires "iniplus >= 0.2.2"

taskRequires "fmt", "nph >= 0.5.1"

task fmt, "Format code":
  exec "nph src/"

task example_compositor, "Runs a bare bones ferusgfx compositor":
 exec "nim c -r tests/example_compositor.nim"
