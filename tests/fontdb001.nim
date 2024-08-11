import ferusgfx/font_database
import pretty, colored_logger
import std/[os, unicode, options, tables, logging, sets]

addHandler newColoredLogger()
var db = newFontDatabase()
db.loadAllFontsFromPath(paramStr(1))
