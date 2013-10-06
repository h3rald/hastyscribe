import os, parseopt, strutils, times, base64, markdown

let v = "0.1"
let usage = "  HastyScribe v" & v & " - Self-contained Markdown Compiler" & """

  (c) 2013 Fabio Cevasco
  
  Usage:
    hastyscribe markdown_file

  Arguments:
    markdown_file          the markdown file to compile into HTML."""

# Source
const src_css = "assets/hastyscribe.css".slurp


proc style_tag(css): string =
  result = "<style>$1</style>" % [css]

let css = src_css.style_tag

proc encode_image(file, format): string =
  let contents = file.readFile
  let enc_contents = contents.encode(contents.len*3) 
  return "data:image/$format;base64,$enc_contents" % ["format", format, "enc_contents", enc_contents]


### MAIN

var input_file = ""

var opt = initOptParser()

opt.next

if opt.kind == cmdArgument:
  # Input file name
  input_file = opt.key

if input_file == "":
  quit(usage, 1)

if input_file.existsFile == false:
  quit("Error: file \"$1\" does not exist" % [input_file], 2)

let inputsplit = input_file.splitFile

# Output file name
let output_file = inputsplit.dir/inputsplit.name & ".htm"

let source = input_file.readFile

# URL callback to base64-encode and embed images
proc callback(url: cstring, size: cint, p: pointer): cstring =
  let str_url = $url
  var target = str_url[0..size-1]
  let file = inputsplit.dir/target
  if file.existsFile:
    let filesplit = target.splitFile
    case filesplit.ext
    of ".png":
      target = encode_image(file, "png")
    of ".jpg":
      target = encode_image(file, "jpeg")
    of ".gif":
      target = encode_image(file, "gif")
    else: nil
  return target

# Document Variables
var metadata = TMDMetaData(title:"", author:"", date:"")
let body = source.md(MKD_DOTOC or MKD_EXTRA_FOOTNOTE, metadata, callback)


# Manage metadata
if metadata.author != "":
  metadata.author = "by <em>" & metadata.author & "</em> &ndash;"

var title_tag, header_tag, toc: string

if metadata.title != "":
  title_tag = "<title>" & metadata.title & "</title>"
  header_tag = "<div id=\"header\"><h1>" & metadata.title & "</h1></div>"
else:
  title_tag = ""
  header_tag = ""

if metadata.toc != "":
  toc = "<div id=\"toc\">" & metadata.toc & "</div>"
else:
  toc = ""

# Date parsing and validation
var timeinfo: TTimeInfo

proc parse_date(date: string, timeinfo: var TTimeInfo): bool = 
  var parts = metadata.date.split('-').map(proc(i:string): int = i.parseInt)
  try:
    timeinfo = TTimeInfo(year: parts[0], month: TMonth(parts[1]-1), monthday: parts[2])
    # Fix invalid dates (e.g. Feb 31st -> Mar 3rd)
    timeinfo = getLocalTime(timeinfo.TimeInfoToTime);
    return true
  except:
    return false

if metadata.date == "":
  discard parse_date(getDateStr(), timeinfo)
else:
  if parse_date(metadata.date, timeinfo) == false:
    discard parse_date(getDateStr(), timeinfo)

let document = """<!doctype html>
<html lang="en">
<head>
  $title_tag
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="author" content="$author">
  $css
</head> 
<body>
  $header_tag
  <div id="toc">
    $toc
  </div>
  <div id="main">
$body
  </div>
  <div id="footer">
    <p>$author Generated with <a href="https://github.com/h3rald/hastyscribe/">HastyScribe</a> on $date</p>
  </div>
</body>""" % ["title_tag", title_tag, "header_tag", header_tag, "author", metadata.author, "date", timeinfo.format("MMMM d, yyyy"), "toc", toc, "css", css, "body", body]

output_file.writeFile(document)
