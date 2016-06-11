import 
  os, 
  parseopt2, 
  strutils, 
  sequtils,
  times, 
  pegs, 
  base64, 
  markdown, 
  tables,
  httpclient

import
  config

let usage* = "  HastyScribe v" & version & " - Self-contained Markdown Compiler" & """

  (c) 2013-2016 Fabio Cevasco

  Usage:
    hastyscribe <markdown_file_or_glob> [options]

  Arguments:
    markdown_file_or_glob   The markdown (or glob expression) file to compile into HTML.
  Options:
    --field/<name>=<value>  Define a new field called <name> with value <value>.
    --notoc                 Do not generate a Table of Contents.
    --user-css=<file>       Insert contents of <file> as a CSS stylesheet.
    --output-file=<file>    Write output to <file>.
                            (Use "--output-file=-" to output to stdout)"""


var generate_toc* = true
var output_file*: string = nil
var user_css*: string = nil
const 
  stylesheet* = "assets/styles/hastyscribe.css".slurp
  hastyscribe_font* = "assets/fonts/hastyscribe.woff".slurp 
  fontawesome_font* = "assets/fonts/fontawesome-webfont.woff".slurp
  sourcecodepro_font* = "assets/fonts/SourceCodePro-Regular.ttf.woff".slurp
  sourcesanspro_font* = "assets/fonts/SourceSansPro-Regular.ttf.woff".slurp
  sourcesanspro_bold_font* = "assets/fonts/SourceSansPro-Bold.ttf.woff".slurp
  sourcesanspro_it_font* = "assets/fonts/SourceSansPro-It.ttf.woff".slurp
  sourcesanspro_boldit_font* = "assets/fonts/SourceSansPro-BoldIt.ttf.woff".slurp

let 
  peg_imgformat = peg"i'.png' / i'.jpg' / i'.jpeg' / i'.gif' / i'.svg' / i'.bmp' / i'.webp' @$"
  peg_img = peg"""
    image <- '<img' \s+ 'src=' ["] {file} ["]
    file <- [^"]+
  """
  peg_def = peg"""
    definition <- '{{' \s* {id} \s* '->' {@} '}}'
    id <- [a-zA-Z0-9_-]+
  """
  peg_snippet = peg"""
    snippet <- '{{' \s* {id} \s* '}}'
    id <- [a-zA-Z0-9_-]+
  """
  peg_field = peg"""
    field <- '{{' \s* '$' {id} \s* '}}'
    id <- [a-zA-Z0-9_-]+
  """

var FIELDS = initTable[string, proc():string]()


var NOW:TimeInfo

FIELDS["timestamp"] = proc():string =
  return $NOW.toTime.toSeconds().int



FIELDS["date"] = proc():string =
  return $NOW.format("yyyy-MM-dd")

FIELDS["full-date"] = proc():string =
  return $NOW.format("dddd, MMMM d, yyyy")

FIELDS["long-date"] = proc():string =
  return $NOW.format("MMMM d, yyyy")

FIELDS["medium-date"] = proc():string =
  return $NOW.format("MMM d, yyyy")

FIELDS["short-date"] = proc():string =
  return $NOW.format("M/d/yy")



FIELDS["short-time-24"] = proc():string =
  return $NOW.format("HH:mm")

FIELDS["short-time"] = proc():string =
  return $NOW.format("HH:mm tt")

FIELDS["time-24"] = proc():string =
  return $NOW.format("HH:mm:ss")

FIELDS["time"] = proc():string =
  return $NOW.format("HH:mm:ss tt")



FIELDS["day"] = proc():string =
  return $NOW.format("dd")

FIELDS["month"] = proc():string =
  return $NOW.format("MM")

FIELDS["year"] = proc():string =
  return $NOW.format("yyyy")

FIELDS["short-day"] = proc():string =
  return $NOW.format("d")

FIELDS["short-month"] = proc():string =
  return $NOW.format("M")

FIELDS["short-year"] = proc():string =
  return $NOW.format("yy")



FIELDS["weekday"] = proc():string =
  return $NOW.format("dddd")

FIELDS["weekday-abbr"] = proc():string =
  return $NOW.format("dd")



FIELDS["month-name"] = proc():string =
  return $NOW.format("MMMM")

FIELDS["month-name-abbr"] = proc():string =
  return $NOW.format("MMM")



FIELDS["timezone-offset"] = proc():string =
  return $NOW.format("zzz")

FIELDS["timezone"] = proc():string =
  return $NOW.format("ZZZ")



# Procedures

proc parse_date*(date: string, timeinfo: var TimeInfo): bool =
  var parts = date.split('-').map(proc(i:string): int =
    try:
      i.parseInt
    except:
      0
  )
  if parts.len < 3:
    return false
  try:
    timeinfo = TimeInfo(year: parts[0], month: Month(parts[1]-1), monthday: parts[2])
    # Fix invalid dates (e.g. Feb 31st -> Mar 3rd)
    timeinfo = getLocalTime(timeinfo.toTime);
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

proc encode_font*(font, format: string): string =
    let enc_contents = font.encode(font.len*3)
    return "data:application/$format;charset=utf-8;base64,$enc_contents" % ["format", format, "enc_contents", enc_contents]

proc embed_images*(document, dir: string): string =
  var current_dir:string
  if dir.len == 0:
    current_dir = ""
  else:
    current_dir = dir & "/"
  type
    TImgTagStart = array[0..0, string]
  var doc = document
  for img in findAll(document, peg_img):
    var matches:TImgTagStart
    discard img.match(peg_img, matches)
    let imgfile = matches[0]
    let imgformat = imgfile.substr(imgfile.find(peg_imgformat)+1, imgfile.len-1)
    var imgcontent = ""
    if imgfile.startsWith(peg"'data:'"): 
      continue
    elif imgfile.startsWith(peg"http[s]?'://'"):
      try:
        imgcontent = encode_image(getContent(imgfile, timeout = 5000), imgformat)
      except:
        stderr.writeLine "Warning: Unable to download '" & imgfile & "'"
        stderr.writeLine "  Reason: " & getCurrentExceptionMsg()
        stderr.writeLine "  -> Image will be linked instead"
        continue
    else:
      imgcontent = encode_image_file(current_dir & imgfile, imgformat)
    let imgrep = img.replace("\"" & img_file & "\"", "\"" & imgcontent & "\"")
    doc = doc.replace(img, imgrep)
  return doc


proc add_jump_to_top_links*(document: string): string =
  return document.replacef(peg"{'</h' [23456] '>'}", "<a href=\"#document-top\" title=\"Go to top\"></a>$1")


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

var fonts* = [
  create_font_face(hastyscribe_font, "HastyScribe", "normal", 400),
  create_font_face(fontawesome_font, "FontAwesome", "normal", 400),
  create_font_face(sourcecodepro_font, "Source Code Pro", "normal", 400),
  create_font_face(sourcesanspro_font,  "Source Sans Pro", "normal", 400),
  create_font_face(sourcesanspro_bold_font, "Source Sans Pro", "normal", 800),
  create_font_face(sourcesanspro_it_font, "Source Sans Pro", "italic", 400),
  create_font_face(sourcesanspro_boldit_font,  "Source Sans Pro", "italic", 800)
  ]

proc embed_fonts*(): string=
  return style_tag(fonts.join);


# Field Usage:
# {{$timestamp}}

proc parse_fields*(document: string): string =
  NOW = getTime().getLocalTime()
  var doc = document
  for field in document.findAll(peg_field):
    var matches:array[0..0, string]
    discard field.match(peg_field, matches)
    var id = matches[0].strip
    if FIELDS.hasKey(id):
      doc = doc.replace(field, FIELDS[id]())
    else:
      stderr.writeLine "Warning: Field '" & id & "' not defined."
      doc = doc.replace(field, "")
  return doc

# Snippet Definition:
# {{test -> My test snippet}}
#
# Snippet Usage:
# {{test}}

proc parse_snippets*(document: string): string =
  var snippets:Table[string, string] = initTable[string, string]()
  type
    TSnippetDef = array[0..1, string]
    TSnippet = array[0..0, string]
  var doc = document
  for def in findAll(document, peg_def):
    var matches:TSnippetDef
    discard def.match(peg_def, matches)
    var id = matches[0].strip
    var value = matches[1].strip(true, false)
    snippets[id] = value
    doc = doc.replace(def, value)
  for snippet in findAll(document, peg_snippet):
    var matches:TSnippet
    discard snippet.match(peg_snippet, matches)
    var id = matches[0].strip
    if snippets[id] == nil:
      stderr.writeLine "Warning: Snippet '" & id & "' not defined."
      doc = doc.replace(snippet, "")
    else:
      doc = doc.replace(snippet, snippets[id])
  return doc

proc compile*(input_file: string) =
  let inputsplit = input_file.splitFile

  # Output file name
  if output_file == nil:
    output_file = inputsplit.dir/inputsplit.name & ".htm"

  var source = input_file.readFile

  # Parse fields and snippets
  source = parse_fields(source)
  source = parse_snippets(source)

  # Document Variables
  var metadata = TMDMetaData(title:"", author:"", date:"", toc:"", css:"")
  var body = source.md(MKD_DOTOC or MKD_EXTRA_FOOTNOTE, metadata)
  var main_css_tag = stylesheet.style_tag
  var user_css_tag = ""
  var headings = " class=\"headings\""
  var author_footer = ""

  # Manage metadata
  if metadata.author != "":
    author_footer = "<span class=\"copy\"></span> " & metadata.author & " &ndash;"

  var title_tag, header_tag, toc: string

  if metadata.title != "":
    title_tag = "<title>" & metadata.title & "</title>"
    header_tag = "<div id=\"header\"><h1>" & metadata.title & "</h1></div>"
  else:
    title_tag = ""
    header_tag = ""

  if generate_toc == true and metadata.toc != "":
    toc = "<div id=\"toc\">" & metadata.toc & "</div>"
  else:
    headings = ""
    toc = ""

  if user_css != nil:
    user_css_tag = user_css.readFile.style_tag




  # Date parsing and validation
  var timeinfo: TimeInfo = getLocalTime(getTime())

  if parse_date(metadata.date, timeinfo) == false:
    discard parse_date(getDateStr(), timeinfo)

  var document = """<!doctype html>
<html lang="en">
<head>
  $title_tag
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="author" content="$author">
  <meta name="generator" content="HastyScribe">
  $fonts_css_tag
  $main_css_tag
  $user_css_tag
  $internal_css_tag
</head>
<body$headings>
  <a id="document-top"></a>
  $header_tag
  $toc
  <div id="main">
$body
  </div>
  <div id="footer">
    <p>$author_footer $date</p>
    <p><span>Powered by</span> <a href="https://h3rald.com/hastyscribe"><span class="hastyscribe"></span></a></p>
  </div>
</body>""" % ["title_tag", title_tag, "header_tag", header_tag, "author", metadata.author, "author_footer", author_footer, "date", timeinfo.format("MMMM d, yyyy"), "toc", toc, "main_css_tag", main_css_tag, "user_css_tag", user_css_tag, "headings", headings, "body", body,
"fonts_css_tag", embed_fonts(), "internal_css_tag", metadata.css]
  document = embed_images(document, inputsplit.dir)
  document = add_jump_to_top_links(document)
  if output_file != "-":
    output_file.writeFile(document)
  else:
    stdout.write(document)

### MAIN

when isMainModule:
  var input = ""
  var files = @[""]

  discard files.pop

  # Parse Parameters

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      input = key
    of cmdLongOption:
      case key
      of "notoc":
        generate_toc = false
      of "user-css":
        user_css = val
      of "output-file":
        output_file = val
      else:
        if key.startsWith("field/"):
          FIELDS[key.replace("field/", "")] = proc(): string =
            return val
        discard
    else: 
      discard

  if input == "":
    quit(usage, 1)
  elif user_css == "":
    quit(usage, 4)
  elif output_file == "":
    quit(usage, 5)

  for file in walkFiles(input):
    files.add(file)

  if files.len == 0:
    quit("Error: \"$1\" does not match any file" % [input], 2)
  else:
    try:
      for file in files:
        compile(file)
    except IOError:
      let msg = getCurrentExceptionMsg()
      quit("Error: $1" % [msg], 3)
