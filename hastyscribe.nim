import os, parseopt2, strutils, times, pegs, base64, markdown, tables

from version import v

let usage* = "  HastyScribe v" & v & " - Self-contained Markdown Compiler" & """

  (c) 2013-2014 Fabio Cevasco
  
  Usage:
    hastyscribe markdown_file_or_glob.md [--notoc]

  Arguments:
    markdown_file_or_glob  The markdown (or glob expression) file to compile into HTML.
  Options:
    --notoc                Do not generate a Table of Contents."""


var generate_toc* = true
const stylesheet* = "assets/styles/hastyscribe.css".slurp
const hastyscribe_font* = "assets/fonts/hastyscribe.woff".slurp
const fontawesome_font* = "assets/fonts/fontawesome-webfont.woff".slurp
const sourcecodepro_font* = "assets/fonts/SourceCodePro-Regular.ttf.woff".slurp
const sourcesanspro_font* = "assets/fonts/SourceSansPro-Regular.ttf.woff".slurp
const sourcesanspro_bold_font* = "assets/fonts/SourceSansPro-Bold.ttf.woff".slurp
const sourcesanspro_it_font* = "assets/fonts/SourceSansPro-It.ttf.woff".slurp
const sourcesanspro_boldit_font* = "assets/fonts/SourceSansPro-BoldIt.ttf.woff".slurp


# Procedures

proc parse_date*(date: string, timeinfo: var TTimeInfo): bool = 
  var parts = date.split('-').map(proc(i:string): int = 
    try:
      i.parseInt
    except:
      0
  )
  if parts.len < 3:
    return false
  try:
    timeinfo = TTimeInfo(year: parts[0], month: TMonth(parts[1]-1), monthday: parts[2])
    # Fix invalid dates (e.g. Feb 31st -> Mar 3rd)
    timeinfo = getLocalTime(timeinfo.TimeInfoToTime);
    return true
  except:
    return false

proc style_tag*(css): string =
  result = "<style>$1</style>" % [css]

proc encode_image*(contents, format): string =
    let enc_contents = contents.encode(contents.len*3) 
    return "data:image/$format;base64,$enc_contents" % ["format", format, "enc_contents", enc_contents]

proc encode_image_file*(file, format): string =
  if (file.existsFile):
    let contents = file.readFile
    return encode_image(contents, format)
  else: 
    echo("Warning: image '"& file &"' not found.")
    return file

proc encode_font*(font, format): string =
    let enc_contents = font.encode(font.len*3) 
    return "data:application/$format;charset=utf-8;base64,$enc_contents" % ["format", format, "enc_contents", enc_contents]

proc embed_images*(document, dir): string =
  var current_dir:string
  if dir.len == 0:
    current_dir = ""
  else:
    current_dir = dir & "/"
  type 
    TImgTagStart = array[0..0, string]
  let img_peg = peg"""
    image <- '<img' \s+ 'src=' ["] {file} ["]
    file <- [^"]+
  """
  var doc = document
  for img in findAll(document, img_peg):
    var matches:TImgTagStart
    discard img.match(img_peg, matches)
    let imgfile = matches[0]
    if imgfile.startsWith(peg"'data:'"): continue
    let pegimgformat = peg"i'.png' / i'.jpg' / i'.jpeg' / i'.gif' / i'.svg' / i'.bmp' / i'.webp' @$"
    let imgformat = imgfile.substr(imgfile.find(pegimgformat)+1, imgfile.len-1)
    let imgcontent = encode_image_file(current_dir & imgfile, imgformat)
    let imgrep = img.replace("\"" & img_file & "\"", "\"" & imgcontent & "\"")
    doc = doc.replace(img, imgrep)
  return doc


proc add_jump_to_top_links*(document): string =
  return document.replacef(peg"{'</h' [23456] '>'}", "<a href=\"#document-top\" title=\"Go to top\"></a>$1")


proc create_font_face*(font, family, style, weight): string=
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

# Snippet Definition:
# {{test -> My test snippet}}
# 
# Snippet Usage:
# {{test}}

proc parse_snippets*(document): string =
  var snippets:TTable[string, string] = initTable[string, string]()
  let peg_def = peg"""
    definition <- '{{' \s* {id} \s* '->' {@} '}}'
    id <- [a-zA-Z0-9_-]+
  """
  let peg_snippet = peg"""
    snippet <- '{{' \s* {id} \s* '}}'
    id <- [a-zA-Z0-9_-]+
  """
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
      echo "Warning: Snippet '" & id & "' not defined." 
      doc = doc.replace(snippet, "")
    else:
      doc = doc.replace(snippet, snippets[id])
  return doc

proc compile*(input_file: string) =
  let inputsplit = input_file.splitFile

  # Output file name
  let output_file = inputsplit.dir/inputsplit.name & ".htm"
  var source = input_file.readFile

  # Parse snippets
  source = parse_snippets(source)

  # Document Variables
  var metadata = TMDMetaData(title:"", author:"", date:"")
  var body = source.md(MKD_DOTOC or MKD_EXTRA_FOOTNOTE, metadata)
  var main_css = stylesheet.style_tag
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

  # Date parsing and validation
  var timeinfo: TTimeInfo = getLocalTime(getTime())

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
  $fonts_css
  $main_css
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
</body>""" % ["title_tag", title_tag, "header_tag", header_tag, "author", metadata.author, "author_footer", author_footer, "date", timeinfo.format("MMMM d, yyyy"), "toc", toc, "main_css", main_css, "headings", headings, "body", body, 
"fonts_css", embed_fonts()]
  document = embed_images(document, inputsplit.dir)
  document = add_jump_to_top_links(document)
  output_file.writeFile(document)

 
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
      if key == "notoc":
        generate_toc = false
    else: discard
  
  if input == "":
    quit(usage, 1)
  
  for file in walkFiles(input):
    files.add(file)
 
  if files.len == 0:
    quit("Error: \"$1\" does not match any file" % [input], 2)
  else:
    for file in files:
      compile(file)
