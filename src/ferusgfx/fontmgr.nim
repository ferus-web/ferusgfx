import std/tables, pixie

type FontManager* = ref object of RootObj
 fonts: TableRef[string, Font]
 paths: TableRef[string, string]

proc get*(fontMgr: FontManager, name: string): Font {.inline.} =
 if name in fontMgr.fonts:
  return fontMgr.fonts[name]

 raise newException(ValueError, "Could not find font '" & name & "'")

proc set*(fontMgr: FontManager, name: string, font: Font, path: string = "") {.inline.} =
 if path.len > 1:
  fontMgr.paths[name] = path
 fontMgr.fonts[name] = font

proc load*(fontMgr: FontManager, name, path: string) {.inline.} =
 fontMgr.set(
  name,
  readFont(path),
  path
 )

proc getPath*(fontMgr: FontManager, name: string): string =
 fontMgr.paths[name]

proc newFontManager*: FontManager =
 FontManager(fonts: newTable[string, Font](), paths: newTable[string, string]())