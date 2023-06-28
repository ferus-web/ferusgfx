# Package

version       = "0.1.0"
author        = "xTrayambak"
description   = "High performance graphics pipeline for Ferus"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.12"
requires "windy"
requires "pixie"
requires "boxy"
requires "opengl"

task example_compositor, "Runs a bare bones ferusgfx compositor":
 exec "nim c -r tests/example_compositor.nim"