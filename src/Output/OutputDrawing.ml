open Util
open OutputCommon
open Fonts.FTypes


let output paragraphs (figures:drawingBox array) env (opt_pages:(parameters*line) list array)=
  let draw_page i p=
    let pageContents=ref [] in
    let y0=ref infinity in
    let y0'=ref infinity in
    let y1=ref (-.infinity) in
    let x0=ref infinity in
    let x1=ref (-.infinity) in
      List.iter (
        fun (param,line)->
          let y=270.0-.line.height in
            if line.isFigure then (
              let fig=figures.(line.lastFigure) in
                y1:=max !y1 y;
                y0':=min !y0' (y-.fig.drawing_y1+.fig.drawing_y0);
                y0:=min !y0 (y-.fig.drawing_y1+.fig.drawing_y0);
                pageContents := (List.map (translate param.left_margin (y-.fig.drawing_y1))
                                   (fig.drawing_contents fig.drawing_nominal_width)) @ !pageContents
            ) else if line.paragraph<Array.length paragraphs then (
              let (yy0,yy1)=line_height paragraphs line in
                y1:=max (y+.yy1) !y1;
                y0:=min y !y0;
                y0':=min (y+.yy0) !y0';
              let comp=compression paragraphs (param,line) in
              let rec draw_box x y=function
                  Kerning kbox ->(
                    let w=draw_box (x+.kbox.kern_x0) (y+.kbox.kern_y0) kbox.kern_contents in
                      w+.kbox.advance_width
                  )
                | Hyphen h->(
                    (Array.fold_left (fun x' box->
                                        let w=draw_box (x+.x') y box in
                                          x'+.w) 0. h.hyphen_normal)
                  )
                | GlyphBox a->(
                    pageContents:=
                      (Glyph { a with glyph_x=a.glyph_x+.x;glyph_y=a.glyph_y+.y })
                    :: !pageContents;
                    a.glyph_size*.Fonts.glyphWidth a.glyph/.1000.
                  )
                | Glue g
                | Drawing g ->(
                    let w=g.drawing_min_width+.comp*.(g.drawing_max_width-.g.drawing_min_width) in
                      pageContents := (List.map (translate x y) (g.drawing_contents w)) @ !pageContents;
                      w
                  )
                | b->box_width comp b
              in
                x0:=min !x0 param.left_margin;
                x1:=max !x1 (fold_left_line paragraphs (fun x b->x+.draw_box x y b) param.left_margin line)
            )
      ) p;
      pageContents:=List.map (translate (-. !x0) (-. !y0')) !pageContents;
      { drawing_min_width= !x1-. !x0;
        drawing_nominal_width= !x1-. !x0;
        drawing_max_width= !x1-. !x0;
        drawing_y0= !y0-. !y0';
        drawing_y1= env.Document.normalLead *. (ceil ((!y1-. !y0')/.env.Document.normalLead));
        drawing_badness=(fun _->0.);
        drawing_contents=(fun _-> !pageContents) }
  in
    Array.mapi draw_page opt_pages
