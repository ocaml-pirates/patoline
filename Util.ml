open Drivers
open Binary
open Boxes
open Constants

open CamomileLibrary

let array_of_rev_list l0=
  match l0 with
      []->[||]
    | h0::_->
        let arr=Array.create (List.length l0) h0 in
        let rec do_it l i=match l with
            []->arr
          | h::s->(arr.(i)<-h; do_it s (i-1))
        in
          do_it l0 (Array.length arr-1)

let glyphCache_=ref StrMap.empty

let glyphCache gl=
  let font=try StrMap.find (Fonts.fontName !current_font) !glyphCache_ with
        Not_found->(let fontCache=ref IntMap.empty in
                      glyphCache_:=StrMap.add (Fonts.fontName !current_font) fontCache !glyphCache_;
                      fontCache)
  in
  let code=UChar.code gl in
    try IntMap.find code !font with
        Not_found->
          (let loaded=Fonts.loadGlyph !current_font (Fonts.glyph_of_char !current_font gl) in
             font:=IntMap.add code loaded !font;
             loaded)

let glyph_of_string fsize str =
  let len = UTF8.length str in
  let res = ref [] in
  for i = 0 to len - 1 do 
    res := UTF8.get str i :: ! res
  done ;
  List.map (fun c ->
    let gl=glyphCache c in
    GlyphBox { contents=UTF8.init 1 (fun _->c); glyph=gl; size = fsize; width=fsize*.(Fonts.glyphWidth gl)/.1000. }) !res 
