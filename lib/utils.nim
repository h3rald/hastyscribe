import
  base64,
  os,
  strutils,
  sequtils,
  pegs,
  times

import
  consts

proc parse_date*(date: string, timeinfo: var DateTime): bool =
  var parts = date.split('-').map(proc(i:string): int =
    try:
      i.parseInt
    except:
      0
  )
  if parts.len < 3:
    return false
  try:
    timeinfo = DateTime(year: parts[0], month: Month(parts[1]-1), monthday: parts[2])
    # Fix invalid dates (e.g. Feb 31st -> Mar 3rd)
    timeinfo = local(timeinfo.toTime);
    return true
  except:
    return false

proc style_tag*(css: string): string =
  result = "<style>$1</style>" % [css]

proc encode_image*(contents, format: string): string =
    let enc_contents = contents.encode(contents.len*3)
    return "data:image/$format;base64,$enc_contents" % ["format", format, "enc_contents", enc_contents]

proc encode_image_file*(file, format: string): string =
  if (file.existsFile):
    let contents = file.readFile
    return encode_image(contents, format)
  else:
    stderr.writeLine("Warning: image '" & file & "' not found.")
    return file

proc image_format*(imgfile: string): string =
  let peg_imgformat = peg"i'.png' / i'.jpg' / i'.jpeg' / i'.gif' / i'.svg' / i'.bmp' / i'.webp' @$"
  return imgfile.substr(imgfile.find(peg_imgformat)+1, imgfile.len-1)

proc watermark_css*(imgfile: string): string =
  if imgfile.isNil:
    result = ""
  else:
    let img = imgfile.encode_image_file(imgfile.image_format)
    result = (watermark_style % [img]).style_tag

proc encode_font*(font, format: string): string =
    let enc_contents = font.encode(font.len*3)
    return "data:application/$format;charset=utf-8;base64,$enc_contents" % ["format", format, "enc_contents", enc_contents]

proc create_font_face*(font, family, style: string, weight: int): string=
  return """
    @font-face {
      font-family:"$family";
      src:url($font) format('woff');
      font-style:$style;
      font-weight:$weight;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }
  """ % ["family", family, "font", encode_font(font, "x-font-woff"), "style", style, "weight", $weight]


