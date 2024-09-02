import std/[os, strutils, distros, options, tables]
import pixie, iniplus

type
  SystemAppearance* = object
    fontName*: string
    fontSize*: uint

    when defined(linux):
      theme*: string

  FontManager* = ref object
    fonts: TableRef[string, Font]
    paths: TableRef[string, string]

proc get*(fontMgr: FontManager, name: string): Font {.inline.} =
  if name in fontMgr.fonts:
    return fontMgr.fonts[name]
  
  when not defined(ferusInJail):
    raise newException(ValueError, "Could not find font '" & name & "'")

proc set*(
    fontMgr: FontManager, name: string, font: Font, path: string = ""
) {.inline.} =
  if path.len > 1:
    fontMgr.paths[name] = path
  fontMgr.fonts[name] = font

proc load*(fontMgr: FontManager, name, path: string) {.inline.} =
  fontMgr.set(name, readFont(path), path)

proc getPath*(fontMgr: FontManager, name: string): string {.inline.} =
  fontMgr.paths[name]

proc getDefaultsFromGtkrc*(fontMgr: FontManager): Option[SystemAppearance] =
  # Step 1: try to fetch it from ~/.gtkrc-2.0
  let 
    gtkrc2 = getHomeDir() / ".gtkrc-2.0"
    gtkrc3 = getConfigDir() / "gtk-3.0" / "settings.ini"
    gtkrc4 = getConfigDir() / "gtk-4.0" / "settings.ini"

    rc2Exists = when not defined(ferusgfxDontUseGtkrc2): fileExists gtkrc2 else: false
    rc3Exists = when not defined(ferusgfxDontUseGtkrc3): fileExists gtkrc3 else: false
    rc4Exists = when not defined(ferusgfxDontUseGtkrc4): fileExists gtkrc4 else: false

  var appearance: SystemAppearance

  if rc2Exists:
    let rc = readFile gtkrc2

    for content in rc.splitLines():
      let splitted = content.split('=')

      if splitted.len < 2:
        continue

      let attribute = splitted[0][0 .. splitted[0].len - 2]
      var value = splitted[1][1 .. splitted[1].len - 1]

      if value.startsWith '"':
        value = value[1 ..< value.len]

      if value.endsWith '"':
        value = value[0 ..< value.len - 1]
      
      case attribute
      of "gtk-font-name":
        let
          splittedFont = value.split(' ')
          name = splittedFont[0]
          size = splittedFont[1].parseUint()

        appearance.fontName = name
        appearance.fontSize = size
      of "gtk-theme-name":
        when defined(linux):
          appearance.theme = value
        else: discard
      else: discard
    
    return some appearance
  elif rc3Exists:
    let
      rc = parseString (readFile gtkrc3)
      font = rc.getString("Settings", "gtk-font-name")
      splitted = font.split(' ')

      fontName = splitted[0]
      fontSize = splitted[1].parseUint()

    appearance.fontName = fontName
    appearance.fontSize = fontSize
    appearance.theme = rc.getString("Settings", "gtk-theme-name")
    return some appearance
  elif rc4Exists:
    # FIXME: do we just let duplicate code float around here?
    let 
      rc = parseString (readFile gtkrc3)
      font = rc.getString("Settings", "gtk-font-name")
      splitted = font.split(' ')

      fontName = splitted[0]
      fontSize = splitted[1].parseUint()

    appearance.fontName = fontName
    appearance.fontSize = fontSize
    appearance.theme = rc.getString("Settings", "gtk-theme-name")
    return some appearance

#proc linuxLoadSystemFonts*(fontMgr: FontManager) =
#  vhsLoadSystemFonts(fontMgr)

#proc loadSystemFonts*(fontMgr: FontManager)

proc newFontManager*(): FontManager {.inline.} =
  FontManager(fonts: newTable[string, Font](), paths: newTable[string, string]())
