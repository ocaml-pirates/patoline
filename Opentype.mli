open CamomileLibrary

exception Table_not_found
type font = CFF of (CFF.font*int)
type glyph = CFFGlyph of (font*CFF.glyph)
val loadFont : ?offset:int -> ?size:int->string->font
val glyph_of_char:font->UChar.t->int
val loadGlyph : font -> ?index:int->int -> glyph
val outlines : glyph -> (float*float) array list
val glyphFont : glyph -> font
val glyphNumber : glyph -> int
val glyphWidth : glyph->float
val fontName:?index:int->font -> string
