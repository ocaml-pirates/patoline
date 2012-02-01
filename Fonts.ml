(** This module defines the common interface to font faces. All
"submodules" should define at least the same functions, although there
does not seem to be a way in OCaml to express this while leaving the
subtype constructors accessible

    Here is how to load glyphs from a char :
    [let font=loadFont file in loadGlyph font (glyph_of_char font char)]
 *)

open Binary
open Bezier
open FontsTypes
open CamomileLibrary


exception Not_supported


type font = CFF of CFF.font | Opentype of FontOpentype.font
type glyph = CFFGlyph of CFF.glyph | OpentypeGlyph of FontOpentype.glyph

module Opentype=(FontOpentype:Font)

(** loadFont pretends it can recognize font file types, but it
    actually only looks at the extension in the file name *)
let loadFont ?offset:(off=0) f=
  if Filename.check_suffix f ".otf" then
    Opentype (FontOpentype.loadFont ~offset:off f)
  else
    if Filename.check_suffix f ".cff" then
      CFF (CFF.loadFont ~offset:off f)
    else
      raise Not_supported

let glyph_of_char f c=
  match f with
      CFF x->CFF.glyph_of_char x c
    | Opentype x->FontOpentype.glyph_of_char x c


let loadGlyph f g=
  match f with
      CFF x->CFFGlyph (CFF.loadGlyph x g)
    | Opentype x->OpentypeGlyph (FontOpentype.loadGlyph x g)
        
let outlines gl=
  match gl with
      CFFGlyph x->CFF.outlines x
    | OpentypeGlyph x->FontOpentype.outlines x
        
let glyphFont gl=
  match gl with
      CFFGlyph x->CFF (CFF.glyphFont x)
    | OpentypeGlyph x->Opentype (FontOpentype.glyphFont x)

let glyphNumber gl=
  match gl with
      CFFGlyph x->CFF.glyphNumber x
    | OpentypeGlyph x->FontOpentype.glyphNumber x

let glyphWidth gl=
  match gl with
      CFFGlyph x->CFF.glyphWidth x
    | OpentypeGlyph x->FontOpentype.glyphWidth x

let fontName f=
  match f with
      CFF x->CFF.fontName x
    | Opentype x->FontOpentype.fontName x

let substitutions f glyphs=
  match f with
      CFF _->glyphs
    | Opentype x->FontOpentype.substitutions x glyphs

let kerning f glyphs=
  match f with
      CFF _->glyphs
    | Opentype x->FontOpentype.positioning x glyphs

