import os, parseopt, strutils, times, pegs, base65, markdown

let v = "1.0"
let usage = "  HastyScribe v" & v & " - Self-contained Markdown Compiler" & """

  (c) 2013 Fabio Cevasco
  
  Usage:
    hastyscribe markdown_file [--notoc]

  Arguments:
    markdown_file          The markdown file to compile into HTML.
  Options:
    --notoc                Do not generate a Table of Contents."""

var generate_toc = true
const src_css = "assets/hastyscribe.css".slurp
const src_highlight_js = "assets/highlight.pack.js".slurp

# Procedures

proc parse_date(date: string, timeinfo: var TTimeInfo): bool = 
  var parts = date.split('-').map(proc(i:string): int = 
    try:
      i.parseInt
    except:
      0
  )
  try:
    timeinfo = TTimeInfo(year: parts[0], month: TMonth(parts[1]-1), monthday: parts[2])
    # Fix invalid dates (e.g. Feb 31st -> Mar 3rd)
    timeinfo = getLocalTime(timeinfo.TimeInfoToTime);
    return true
  except:
    return false


proc style_tag(css): string =
  result = "<style>$1</style>" % [css]

proc encode_image(file, format): string =
  if (file.existsFile):
    let contents = file.readFile
    let enc_contents = contents.encode(contents.len*3) 
    return "data:image/$format;base64,$enc_contents" % ["format", format, "enc_contents", enc_contents]
  else: 
    echo("Warning: image '"& file &"' not found.")
    return file

proc embed_images(document): string =
  type TImgData = tuple[img: string, rep: string] 
  var imgdata: seq[TImgData] = @[]
  let imgpeg = peg"'<img src=""' [^""]+ '""'"
  let imgpegs = peg"@'<img src=""' [^""]+ '""'"
  let imgpegf = peg"'""' [^""]+ '""'"
  var doc = document
  for img in findAll(document, imgpegs):
    let imgsrc = img.substr(img.find(imgpeg), img.len-1)
    let imgfile = imgsrc.substr(imgsrc.find(imgpegf)+1, imgsrc.len-2)
    let imgformat = imgfile.substr(imgfile.find(peg"'.' [^.]+$")+1, imgfile.len-1)
    let imgcontent = encode_image(imgfile, imgformat)
    let imgrep = imgsrc.replace(imgpegf, "\""& imgcontent &"\"")
    imgdata.add((img: imgsrc, rep: imgrep))
  for i in imgdata:
    doc = document.replace(i.img, i.rep)
  return doc

proc convert_file(input_file: string) =
  let inputsplit = input_file.splitFile

  # Output file name
  let output_file = inputsplit.dir/inputsplit.name & ".htm"
  let source = input_file.readFile

  # Document Variables
  var metadata = TMDMetaData(title:"", author:"", date:"")
  var body = source.md(MKD_DOTOC or MKD_EXTRA_FOOTNOTE, metadata)
  var main_css = src_css.style_tag
  var headings = " class=\"headings\""
  var author_footer = ""

  # Manage metadata
  if metadata.author != "":
    author_footer = metadata.author & " &ndash;"

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
  var timeinfo: TTimeInfo

  if metadata.date == "":
    discard parse_date(getDateStr(), timeinfo)
  else:
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
  $main_css
</head> 
<body$headings>
  $header_tag
  $toc
  <div id="main">
$body
  </div>
  <div id="footer">
    <p>$author_footer $date</p>
  </div>
  <script type="text/javascript">
    $highlight
    hljs.tabReplace = '  ';
    hljs.initHighlightingOnLoad();
  </script>
</body>""" % ["title_tag", title_tag, "header_tag", header_tag, "author", metadata.author, "author_footer", author_footer, "date", timeinfo.format("MMMM d, yyyy"), "toc", toc, "main_css", main_css, "headings", headings, "body", body, "highlight", src_highlight_js]
  document = embed_images(document)
  output_file.writeFile(document)

 
### MAIN

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
  else: nil

if input == "":
  quit(usage, 1)

for file in walkFiles(input):
  let filesplit = file.splitFile
  if (filesplit.ext == ".md" or filesplit.ext == ".markdown"):
    files.add(file)

if files.len == 0:
  quit("Error: \"$1\" does not match any markdown file" % [input], 2)
else:
  for file in files:
    convert_file(file)
