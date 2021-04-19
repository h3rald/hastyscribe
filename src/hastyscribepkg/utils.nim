import
  base64,
  os,
  strutils,
  pegs

import
  consts

proc style_tag*(css: string): string =
  result = "<style>$1</style>" % [css]

proc style_link_tag*(css: string): string =
  result = "<link rel=\"stylesheet\" href=\"$1\"/>" % [css]

proc encode_image*(contents, format: string): string =
    let enc_contents = contents.encode
    return "data:image/$format;base64,$enc_contents" % ["format", format, "enc_contents", enc_contents]

proc encode_image_file*(file, format: string): string =
  if (file.fileExists):
    let contents = file.readFile
    return encode_image(contents, format)
  else:
    stderr.writeLine("Warning: image '" & file & "' not found.")
    return file

proc image_format*(imgfile: string): string =
  let peg_imgformat = peg"i'.png' / i'.jpg' / i'.jpeg' / i'.gif' / i'.svg' / i'.bmp' / i'.webp' @$"
  return imgfile.substr(imgfile.find(peg_imgformat)+1, imgfile.len-1)

proc watermark_css*(imgfile: string): string =
  if imgfile == "":
    result = ""
  else:
    let img = imgfile.encode_image_file(imgfile.image_format)
    result = (watermark_style % [img]).style_tag

proc add_jump_to_top_links*(document: string): string =
  result = document.replacef(peg"{'</h' [23456] '>'}", "<a href=\"#document-top\" title=\"Go to top\"></a>$1")

proc encode_font*(font, format: string): string =
    let enc_contents = font.encode
    return "data:application/$format;charset=utf-8;base64,$enc_contents" % ["format", format, "enc_contents", enc_contents]

proc create_font_face*(font, family, style: string, weight: int, embed=true): string=
  var font_src = ""
  if embed:
    font_src = encode_font(font, "x-font-woff")
  else:
    font_src = font  
  return """
    @font-face {
      font-family:"$family";
      src:url($font) format('woff');
      font-style:$style;
      font-weight:$weight;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }
  """ % ["family", family, "font", font_src, "style", style, "weight", $weight]


