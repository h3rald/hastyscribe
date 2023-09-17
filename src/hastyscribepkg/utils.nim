import std/[
    base64,
    os,
    strutils,
    pegs,
  ]

import
  consts

template style_tag*(css: string): string =
  "<style>" & css & "</style>"

proc style_link_tag*(css: string): string =
  result = "<link rel=\"stylesheet\" href=\"$1\"/>" % [css]

proc encode_image*(contents, format: string): string =
  if format == "svg":
    let encoded_svg = contents.multireplace([
        ("\"", "'"),
        ("%", "%25"),
        ("#", "%23"),
        ("{", "%7B"),
        ("}", "%7D"),
        ("<", "%3C"),
        (">", "%3E"),
        (" ", "%20"),
      ])
    "data:image/svg+xml,$#" % [encoded_svg]
  else:
    "data:image/$format;base64,$enc_contents" % ["format", format, "enc_contents", contents.encode]

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
