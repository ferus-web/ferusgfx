import std/[os, options, unicode, sets, logging, sequtils, importutils]
import pixie,
       pixie/fontformats/opentype {.all.},
       pretty

privateAccess(Typeface)
privateAccess(CFFTable)
privateAccess(CFFTopDict)

type
  Family* = object
    name*: string
    default*: Font
    variants*: seq[Font]

  FontDatabase* = object
    families: seq[Family]

func get*(db: FontDatabase, family: string, pointSize: float) =
  discard

iterator family*(db: FontDatabase, family: sink string): Option[Font] =
  let correctFam =
    db.families.filterIt(it.name == family)

  if correctFam.len < 1:
    warn "fonts: could not find any font family with name: " & family
    yield none(Font)

  if correctFam.len > 1:
    warn "fonts: found multiple copies of font family: " & family & "; using first index."
  
  for font in correctFam[0].variants & correctFam[0].default:
    yield some(font)

proc loadAllFontsFromPath*(db: var FontDatabase, path: string) =
  if not dirExists(path):
    warn "fonts: failed to load fonts; no such path exists: " & path
    return

  for file in walkDirRec(path):
    let ext = file.splitFile().ext

    case ext
    of ".ttf", ".otf":
      info "fonts: attempting to load TrueType/OpenType font: " & file
      try:
        let 
          font = readFont(file)
        
        if font.typeface.opentype.cff == nil:
          warn "fonts: font.typeface.opentype.cff == NULL! Failsafe triggered. Marking font as unrecognized."
          if db.families[0].default == nil:
            db.families[0].default = font
          else:
            db.families[0].variants &= font
          continue

        let
          family = font.typeface.opentype.cff.topDict.familyName
        
        var 
          contains = false
          familyIdx = -1

        for i, dfamily in db.families:
          if dfamily.name == family: 
            contains = true 
            familyIdx = i
            break

        if not contains:
          db.families &= Family(name: family, default: font, variants: newSeq[Font](4))
        else:
          assert familyIdx != -1, "`contains` was set to true, but `familyIdx` was not properly mutated to reflect the proper index!"

          db.families[familyIdx].variants &=
            font
      except PixieError as exc:
        warn "fonts: error occured whilst loading \"" & file & "\": " & exc.msg & "; skipping."
      except OSError as exc:
        warn "fonts: failed to read file: " & exc.msg & "; skipping."
    else:
      warn "fonts: unrecognized font type found in path: \"" & file & "\" with extension: " & ext

func newFontDatabase*: FontDatabase {.inline.} =
  FontDatabase(families: @[Family(name: "Default")])
